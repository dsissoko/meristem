<p align="center">
  <img src="./meristem-image.png" alt="Meristem logo" width="450" />
</p>

# Meristem – Knowledge-first Agentic App Template

Meristem is a minimal, knowledge-driven template for building applications with AI agents.

It is not a technical starter — no framework, no boilerplate code.
It is a structured environment where agents operate based on explicit product knowledge and reusable skills, from which they can generate and evolve any application.

---

## Why Meristem?

In plants, the meristem is the tissue where growth starts.
This repository plays a similar role: a small, structured core of knowledge from which agents can generate and evolve entire applications.

---

## How it works

Meristem runs on GitHub Actions. Specialized agents are invoked by a simple comment on any issue or PR:

```
/dev add a welcome footer
/po initialize the project board
/qa review this PR
/architect what is the current architecture?
```

Each agent knows its role, loads the skills it needs, and acts — or responds — directly in the thread. The process emerges from agent interactions. Nothing is hardcoded in a central file.

Agents available out of the box: `/agent` (generalist), `/dev`, `/qa`, `/po`, `/analyst`, `/architect`, `/help`.

---

## Quick Start

```bash
git clone https://github.com/dsissoko/meristem.git my-app
cd my-app
```

Configure the required secrets in GitHub Settings → Secrets → Actions:

| Secret | Required | Description |
|--------|----------|-------------|
| `OPENCODE_API_KEY` | ✅ | OpenCode API key — [opencode.ai/auth](https://opencode.ai/auth) |
| `SCRUM_PROJECT_TOKEN` | ⬜ | GitHub PAT with `project` scope — for Scrum board initialization |

Open an issue and invoke an agent:

```
/po I want to build a task manager. React + Primer frontend, mocked backend.
```

The agent reads `AGENTS.md`, loads the Meristem process, and guides you from there.
No manual setup required.

---

## Structure

```
.
├── AGENTS.md                        ← agent entry point — process and rules
├── agents/                          ← agent profiles and configuration
│   ├── config.yml                   ← active roles, runner mode, model
│   └── <role>/profile.md            ← role identity, skills, routing rules
├── skills/
│   ├── skills-set.md                ← skill sets per role
│   └── local/                       ← core and project skills
├── .github/workflows/               ← dispatcher, runners, CI/CD
├── .opencode/skills/                ← skill bootstrap for OpenCode
├── .claude/skills/                  ← skill bootstrap for Claude Code
├── .gemini/skills/                  ← skill bootstrap for Gemini
├── .agents/skills/                  ← skill bootstrap for generic agents
└── .openhands/microagents/repo.md   ← OpenHands instructions
```

After first use, the agent creates `business.md`, `architecture.md`, and `docs/specs/`.

---

## Skills

Skills are reusable instruction sets that agents load on demand. Meristem ships with a curated library covering common needs: GitHub context, PR workflow, product knowledge initialization, Scrum project setup, C4 architecture diagrams, frontend stacks, and more.

Skills are organized in sets by role — `/dev` loads technical skills, `/po` loads product skills, `/architect` loads architecture and C4 diagramming skills. When starting a new project, the agent proposes a matching set based on your stack. You validate before anything is applied.

New skills can be added at any time — from the community or written for your project — without modifying the framework.

---

## What's Next

- **Autonomous mode** — agents chain themselves without human validation between steps, implemented and ready to test
- **MCP sandbox enrichment** — equip agents with MCP servers (GitHub, documentation search, Playwright) before execution
- **More skill sets** — community-contributed sets for Vue, Svelte, Python/FastAPI, mobile, and more
- **Collaborative experiment** — a public repo where anyone can open an issue, trigger a free-model agent, and watch their feature land in a PR

---

> Contributions welcome — skills, presets, agent profiles, and workflow improvements.
> See [meristem-test](https://github.com/dsissoko/meristem-test) for a live demonstration.
