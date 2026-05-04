# AGENTS.md

## What is this repo

This repository follows the **Meristem v0.2** process — a multi-agent architecture driven by GitHub Actions.

Agents are specialized by role. Each agent has a profile, a set of skills, and routing rules.
The process emerges from agent interactions — it is not imposed by a central file.

---

## Available agents

| Pattern | Role |
|---------|------|
| `/agent` | Generalist |
| `/dev` | Implementation |
| `/qa` | Tests, quality, code review |
| `/po` | Product, specs, Scrum |
| `/analyst` | Business analysis, domain modeling, process flows |
| `/architect` | Architecture |
| `/help` | FAQ, onboarding, framework questions |

Project-specific agents (`/my-dev`, `/my-qa`, `/my-po`, `/my-archi`) can be added by creating a profile in `agents/<role>/profile.md` and an entry in `agents/config.yml`.

---

## Startup

**Before any task**, load the core skills:

1. Read `skills/skills-set.md`
2. Load every `SKILL.md` listed under `## Set: core`

**On `/role` invocation:**

3. Read `agents/{role}/profile.md`
4. Load every `SKILL.md` from the sets declared in `## Skill loading`

---

## How agents work

When invoked via `/role`, the agent:

1. Reads its profile at `agents/{role}/profile.md`
2. The profile specifies which skill sets to load from `skills/skills-set.md`
3. The agent acts according to its profile and loaded skills

---

## Key files

| File | Purpose |
|------|---------|
| `agents/config.yml` | Active roles and aliases |
| `agents/<role>/profile.md` | Agent identity, responsibilities, skill sets, routing rules |
| `skills/skills-set.md` | Skill sets by role |
| `skills/<source>/<skill>/SKILL.md` | Skill instructions |
| `business.md` | Product knowledge — maintained by `/po` |
| `architecture.md` | Technical knowledge — maintained by `/architect` |

---

## Rules

- Never modify skills from external sources — create a local override under `skills/local/`
- Never invent requirements not present in knowledge files
- Always read the relevant `SKILL.md` before acting on a task
- Always respond and invoke other agents from the thread where the call originated
- If the work involves a PR → work and communicate on the PR until it is merged
- After a PR is merged → post a summary comment on the originating issue
- Never create issues spontaneously — always work within the existing thread
- Never post a question and perform an action in the same turn — a question means stop and wait
- Never modify `business.md` or `architecture.md` without explicit human validation
- Never write a `/role` pattern unescaped in a response — always use backticks (e.g. `` `/architect` ``) to prevent accidental dispatcher triggers. This applies in prose, lists, and Markdown tables alike.
- Respond in the language used by the human in the active instruction
