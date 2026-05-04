---
name: meristem-skills-index
description: Bootstrap skill for Meristem-based repositories
compatibility: gemini
---

## Purpose

This skill is the entry point for a Meristem-based repository.

## Step 1 — Load core skills

Read `skills/skills-set.md` and load every SKILL.md listed under `## Set: core`.

Do not skip this step. Core skills are required for all agent runs.

## Skill location

All skills follow this path pattern:

```
skills/<source>/<skill-name>/SKILL.md
```

## Rules

- `skills/` is the authoritative source for all Meristem skills
- Never modify skills from external sources (`skills/<source>/` where source ≠ `local`)
- To customize an external skill, create a new one under `skills/local/`
