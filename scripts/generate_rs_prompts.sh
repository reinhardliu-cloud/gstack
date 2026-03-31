#!/usr/bin/env bash
set -euo pipefail

FORCE=0
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: bash scripts/generate_rs_prompts.sh [--force] [--dry-run]

Options:
  --force    Overwrite existing rs-*.prompt.md files
  --dry-run  Print planned actions without writing files
  -h, --help Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if command -v git >/dev/null 2>&1; then
  ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
else
  ROOT_DIR="$(pwd)"
fi

PROMPTS_DIR="$ROOT_DIR/.github/prompts"

discover_skills() {
  local root="$1"
  local found=0

  # Layout A: vendored skills under .agents/skills/gstack-*/SKILL.md
  if [[ -d "$root/.agents/skills" ]]; then
    while IFS= read -r -d '' file; do
      printf "%s\n" "$file"
      found=1
    done < <(find "$root/.agents/skills" -maxdepth 2 -type f -name SKILL.md -print0 | sort -z)
  fi

  # Layout B: gstack source repo skills under <skill>/SKILL.md at repo root
  if [[ "$found" -eq 0 ]]; then
    while IFS= read -r -d '' file; do
      printf "%s\n" "$file"
      found=1
    done < <(find "$root" -mindepth 2 -maxdepth 2 -type f -name SKILL.md -print0 | sort -z)
  fi
}

mkdir -p "$PROMPTS_DIR"

to_title() {
  local s="$1"
  s="${s//-/ }"
  echo "$s" | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) tolower(substr($i,2)) } print}'
}

created=0
updated=0
skipped=0
total=0

while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_dir")"

  # Ignore root-level meta skill file if encountered.
  if [[ "$skill_name" == "." || "$skill_name" == "$ROOT_DIR" ]]; then
    continue
  fi

  slash_target="/$skill_name"
  slug="$skill_name"
  if [[ "$skill_name" == gstack-* ]]; then
    slug="${skill_name#gstack-}"
  fi

  # Skip top-level meta SKILL.md in source repos.
  if [[ "$skill_name" == "gstack" ]]; then
    continue
  fi

  rs_name="rs-$slug"
  prompt_file="$PROMPTS_DIR/$rs_name.prompt.md"
  title="$(to_title "$slug")"

  content=$(cat <<EOF
---
name: "RS $title"
description: "Run $skill_name workflow"
argument-hint: "Optional: scope/details"
---
Use $slash_target for this task.
EOF
)

  total=$((total + 1))

  if [[ -f "$prompt_file" && "$FORCE" -ne 1 ]]; then
    echo "skip: $prompt_file"
    skipped=$((skipped + 1))
    continue
  fi

  action="create"
  if [[ -f "$prompt_file" ]]; then
    action="update"
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "dry-run $action: $prompt_file"
  else
    printf "%s\n" "$content" > "$prompt_file"
    echo "$action: $prompt_file"
  fi

  if [[ "$action" == "create" ]]; then
    created=$((created + 1))
  else
    updated=$((updated + 1))
  fi
done < <(discover_skills "$ROOT_DIR")

echo
echo "done"
echo "total_skills: $total"
echo "created: $created"
echo "updated: $updated"
echo "skipped: $skipped"

if [[ "$total" -eq 0 ]]; then
  echo "warning: no skills discovered from supported layouts"
fi
