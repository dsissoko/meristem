# Skill: faq

## Purpose

Answer questions about the Meristem framework — how it works, how to configure it,
where to start, and what each component does.

This skill is loaded by the `/help` agent.

---

## Scope

Questions this skill covers:

- What is Meristem and what does it do?
- How do I start a new project with Meristem?
- What are agents, profiles, skills, and sets?
- How do I add a new agent role?
- How do I add a new skill?
- How does the autonomous mode work?
- What is `agents/config.yml` for?
- What is `skills/skills-set.md` for?
- How does the GitHub Actions pipeline work?
- What is the difference between `business.md` and `architecture.md`?

---

## Key answers

### What is Meristem?
A multi-agent framework driven by GitHub Actions. Specialized agents (dev, qa, po, analyst, architect) are invoked by commenting `/role` on a GitHub issue or PR. Each agent has a profile, skill sets, and routing rules. The process emerges from agent interactions.

### Where to start?
1. Run `init-project.yml` (workflow_dispatch) — creates `log.md` and `agents/` structure
2. Ensure `business.md` and `architecture.md` exist and are complete
3. Configure `agents/config.yml` with your roles
4. Invoke an agent by commenting `/role your request` on any issue

### What are the key files?
| File | Purpose |
|---|---|
| `agents/config.yml` | Active roles, aliases, dispatcher parameters |
| `agents/<role>/profile.md` | Agent identity, responsibilities, skill sets |
| `skills/skills-set.md` | All skill sets — one per role + stack sets |
| `business.md` | Product knowledge — maintained by `/po` |
| `architecture.md` | Technical knowledge — maintained by `/architect` |
| `log.md` | Operational log — written by the workflow |

### How to add a new agent role?
1. Create `agents/<role>/profile.md`
2. Add an entry in `agents/config.yml` under `roles`
3. Add a `## Set: <role>` section in `skills/skills-set.md`

### How to add a new skill?
1. Create `skills/<source>/<skill-name>/SKILL.md`
2. Add it to the appropriate set in `skills/skills-set.md`

### How does autonomous mode work?
Set `autonomous_mode: true` in `agents/config.yml`. All runs are then in auto mode.
Each agent can invoke another agent after completing its task, using the `agent-handoff` skill.

---

## Rules

- Always answer directly and concisely
- If the question implies an action → suggest the correct agent invocation
- Never modify any file
- If the question is outside this skill's scope → say so and suggest the right agent
