# gstack and RS Slash Setup Guide

## 1) Purpose

Store RS command mapping knowledge and an automation script inside the gstack repository, so anyone can clone once and quickly bootstrap rs prompt templates.

## 2) Directory and Mapping Rules

RS entry points:

1. .github/prompts/rs-*.prompt.md

Skill discovery supports two layouts:

1. Layout A (vendored): .agents/skills/gstack-*/SKILL.md
2. Layout B (gstack source repo): <skill>/SKILL.md, for example autoplan/SKILL.md

Slash target mapping:

1. If skill directory is gstack-xxx, generate rs-xxx and body Use /gstack-xxx for this task.
2. If skill directory is xxx, generate rs-xxx and body Use /xxx for this task.

## 3) One-Click Script

Script path: scripts/generate_rs_prompts.sh

What it does:

1. Scans supported skill layouts automatically
2. Generates .github/prompts/rs-*.prompt.md files
3. Skips existing files by default
4. Supports --dry-run preview
5. Supports --force overwrite

## 4) Usage

Create missing prompt files:

bash scripts/generate_rs_prompts.sh

Preview only:

bash scripts/generate_rs_prompts.sh --dry-run

Overwrite all rs prompt files:

bash scripts/generate_rs_prompts.sh --force

## 5) Invocation Style

Use slug commands:

1. /rs-autoplan
2. /rs-review
3. /rs-qa

Avoid typing display labels as command tokens.

## 6) Validation Checklist

Check prompt files:

find .github/prompts -maxdepth 1 -name "rs-*.prompt.md" | sort

Check skills in both layouts:

find .agents/skills -maxdepth 2 -name "SKILL.md" 2>/dev/null | sort
find . -mindepth 2 -maxdepth 2 -name "SKILL.md" | sort

## 7) Troubleshooting

Problem: /rs-autoplan does not appear

1. Run the generator script
2. Confirm files are under .github/prompts/
3. Confirm valid YAML frontmatter
4. Start a new chat session

Problem: display-name typing is unstable

1. Use /rs-xxx slug commands

## 8) Delivered Assets

This update writes:

1. docs/gstack-rs-setup.md
2. docs/gstack-rs-setup.en.md
3. scripts/generate_rs_prompts.sh
