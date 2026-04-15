# gstack and RS Slash Setup Guide

## 1) Purpose

This guide covers two related but different things:

1. How to generate and use RS aliases like /rs-autoplan
2. How to make a fresh host install gstack completely, not just show slash entries

The common mistake is assuming these are the same step:

1. .github/prompts/rs-*.prompt.md makes RS commands discoverable
2. gstack skills still need a runtime root to execute reliably

Seeing /rs-autoplan in the slash menu is not the same as having a complete working install.

## 2) Directory and Mapping Rules

RS entry points:

1. .github/prompts/rs-*.prompt.md

Skill discovery supports two layouts:

1. Layout A, vendored: .agents/skills/gstack-*/SKILL.md
2. Layout B, gstack source repo: <skill>/SKILL.md, for example autoplan/SKILL.md

Slash target mapping:

1. If skill directory is gstack-xxx, generate rs-xxx with body Use /gstack-xxx for this task.
2. If skill directory is xxx, generate rs-xxx with body Use /xxx for this task.

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

```bash
bash scripts/generate_rs_prompts.sh
```

Preview only:

```bash
bash scripts/generate_rs_prompts.sh --dry-run
```

Overwrite all rs prompt files:

```bash
bash scripts/generate_rs_prompts.sh --force
```

## 5) Invocation Style

Use slug commands:

1. /rs-autoplan
2. /rs-review
3. /rs-qa

Avoid typing display labels as command tokens.

## 6) Fresh-Host Installation Models

For Codex-compatible hosts, there are two standard installation models.

### Option A: user-level install, recommended

Use this when:

1. Your app repo already vendors .agents/skills/gstack-*
2. Your app repo already has .github/prompts/rs-*.prompt.md
3. You only need the gstack runtime root

Install command:

```bash
git clone https://github.com/garrytan/gstack.git ~/gstack
cd ~/gstack
./setup --host codex
```

After setup, the important runtime assets should exist under:

1. ~/.codex/skills/gstack
2. ~/.codex/skills/gstack-*

### Option B: repo-local install, self-contained project

Use this when:

1. You want runtime assets inside the project
2. You want a real .agents/skills/gstack directory in the repo

Install command:

```bash
git clone https://github.com/garrytan/gstack.git .agents/skills/gstack
cd .agents/skills/gstack
./setup --host codex
```

After setup, the important runtime assets should exist under:

1. .agents/skills/gstack/bin
2. .agents/skills/gstack/browse/dist
3. .agents/skills/gstack/review
4. .agents/skills/gstack/qa

## 7) Why Commands Sometimes Show Up But Fail At Runtime

Generating RS prompts only solves command discovery. It does not automatically guarantee runtime completeness.

Many gstack skills look for one of these runtime roots:

1. Repo-local .agents/skills/gstack
2. User-level ~/.codex/skills/gstack

If a repo only vendors .agents/skills/gstack-* but does not include .agents/skills/gstack, and the machine also lacks ~/.codex/skills/gstack, you can end up in this state:

1. /rs-autoplan or /gstack-autoplan appears in the slash menu
2. Actual execution fails because bin, browse, review, or other runtime assets are missing

## 8) Prerequisites

A fresh host should have at least:

1. Git installed
2. Bun 1.0+ installed
3. A host that supports SKILL.md and .github/prompts
4. On Windows, Node.js as well

Minimum checks:

```bash
command -v git
command -v bun
```

Windows extra check:

```bash
command -v node
```

## 9) Validation Checklist

Check prompt files:

```bash
find .github/prompts -maxdepth 1 -name "rs-*.prompt.md" | sort
```

Check skills in both layouts:

```bash
find .agents/skills -maxdepth 2 -name "SKILL.md" 2>/dev/null | sort
find . -mindepth 2 -maxdepth 2 -name "SKILL.md" | sort
```

Check that a runtime root exists:

```bash
test -f ~/.codex/skills/gstack/SKILL.md || test -f .agents/skills/gstack/SKILL.md
test -x ~/.codex/skills/gstack/bin/gstack-update-check || test -x .agents/skills/gstack/bin/gstack-update-check
test -x ~/.codex/skills/gstack/browse/dist/browse || test -x .agents/skills/gstack/browse/dist/browse
```

## 10) Troubleshooting

Problem: /rs-autoplan does not appear

1. Run the generator script
2. Confirm files are under .github/prompts/
3. Confirm valid YAML frontmatter
4. Start a new chat session

Problem: display-name typing is unstable

1. Use /rs-xxx slug commands

Problem: slash commands appear, but execution reports missing gstack resources

1. Check whether ~/.codex/skills/gstack exists
2. If not, check whether repo-local .agents/skills/gstack exists
3. If neither exists, rerun ./setup --host codex

## 11) Which Installation Mode To Choose

Recommended priority:

1. User-level install first, most stable for fresh hosts
2. Repo-local install when you want a self-contained project

If your app repo already has .agents/skills/gstack-* and .github/prompts/rs-* but lacks .agents/skills/gstack, the best next step is usually not to rebuild prompts. It is to add the missing runtime root.

## 12) Delivered Assets

This repo currently provides:

1. docs/gstack-rs-setup.md
2. docs/gstack-rs-setup.en.md
3. scripts/generate_rs_prompts.sh
4. .github/prompts/rs-*.prompt.md
