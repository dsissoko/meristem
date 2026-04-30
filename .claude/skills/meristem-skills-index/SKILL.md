---
name: meristem-skills-index
description: Index of all Meristem skills installed in this repo and instructions to load them
compatibility: claude
---

## Purpose

This skill is the entry point for skill discovery in a Meristem-based repository.

Meristem skills are **not** stored in `.opencode/skills/`. They are stored in a
dedicated `skills/` directory at the root of the repository, organized by source.

---

## Skill location

All installed skills follow this path pattern:

```
skills/<source>/<skill-name>/SKILL.md
```

Examples:
- `skills/local/vite-react-agent-cookbook/SKILL.md`
- `skills/anthropics/frontend-design/SKILL.md`
- `skills/vercel-labs/react-best-practices/SKILL.md`

---

## How to load skills

### Step 1 — Read the lock file first

```
skills/skills.lock.md
```

This file lists all installed skills, their paths, and which iteration they belong to (MVP, spec-phase, review, etc.).
**Always start here.** Never assume a skill is installed without checking this file.

### Step 2 — Read each required SKILL.md

For each skill relevant to the current task, read its `SKILL.md` directly:

```
skills/<source>/<skill-name>/SKILL.md
```

Do not invent skill content. Do not skip this step.

### Step 3 — Apply skill instructions strictly

Once a `SKILL.md` is loaded, follow its instructions exactly.
Do not reimplement logic already covered by a skill.

---

## Important rules

- The `skills/` directory is the **authoritative source** for all Meristem skills
- `.claude/skills/` only contains Claude-native bootstrap skills (like this one)
- Skills in `skills/local/` are project-specific and always take precedence
- Never modify a skill from an external source (`skills/<source>/` where source ≠ `local`)
- To customize an external skill, create a new skill under `skills/local/`

---

## Available skill sources in this repo

| Source | Path prefix | Type |
|--------|------------|------|
| Local (project-specific) | `skills/local/` | Editable |
| anthropics | `skills/anthropics/` | External — read only |
| vercel-labs | `skills/vercel-labs/` | External — read only |
| softaworks | `skills/softaworks/` | External — read only |
| deanpeters | `skills/deanpeters/` | External — read only |
| openclaw | `skills/openclaw/` | External — read only |
| wshobson | `skills/wshobson/` | External — read only |
| bagustris | `skills/bagustris/` | External — read only |
| bas | `skills/bas/` | External — read only |
| getsentry | `skills/getsentry/` | External — read only |

---

## Reference

For the full list of installed skills and their iteration scope, see:
`skills/skills.lock.md`
