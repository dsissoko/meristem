<p align="center">
  <img src="./meristem-image.png" alt="Meristem logo" width="450" />
</p>

# Meristem – Knowledge-first Agentic App Template

## Purpose

Meristem is a minimal, knowledge-driven template for building applications using agent capabilities, with a specification-first workflow.

It is not a technical starter (no framework, no boilerplate code).  
It is a structured environment where agents operate based on explicit product knowledge and reusable skills.

---

## Why Meristem?

In plants, the meristem is the tissue where growth starts.  
This repository plays a similar role for agentic applications: a small, structured core of knowledge (business, architecture, specs) from which agents can generate and evolve applications.

---

## Core Idea

The repository is based on a strict separation:

- Knowledge → what to build  
- Skills → how to build  
- Agent rules → how to behave  

AGENTS.md + docs = behavior  
skills = capabilities  

---

## Structure

Raw template (before first use):

```txt
.
├── AGENTS.md
├── README.md
├── .opencode/
│   └── skills/
│       └── meristem-skills-index/   ← skill bootstrap for OpenCode
├── .claude/
│   └── skills/
│       └── meristem-skills-index/   ← skill bootstrap for Claude Code
├── .gemini/
│   └── skills/
│       └── meristem-skills-index/   ← skill bootstrap for Gemini
├── .agents/
│   └── skills/
│       └── meristem-skills-index/   ← skill bootstrap for generic agents
├── .openhands/
│   └── microagents/
│       └── repo.md                  ← OpenHands instructions
└── skills/
    ├── local/
    │   ├── discover-skills/
    │   └── init-product-knowledge/
    └── skills-presets.md
```

Target layout after the first initialization of a concrete application (artifacts created by the agent):
```txt
.
├── AGENTS.md
├── business.md
├── architecture.md
├── docs/
│   └── specs/
├── skills/
│   ├── local/
│   │   ├── discover-skills/
│   │   └── init-product-knowledge/
│   └── skills.lock.md
└── README.md
```

---

## Knowledge

- business.md  
  Gathers the product vision, product scope, and roadmap.

- architecture.md  
  Defines the minimal technical stack and the application architecture.

- docs/specs/  
  Contains detailed execution specifications

These knowledge files do **not** exist in the bare template; they are created and maintained by the agent (typically via the `init-product-knowledge` skill) when you start working on a concrete application.

---

## Skills

- **discover-skills**
  Finds relevant external skills for the first roadmap iteration, after applying any relevant presets.

- **init-product-knowledge**
  Initializes business/architecture knowledge files and structure.

- **meristem-skills-index**
  Bootstrap skill placed in each agent's native skill directory (`.opencode/skills/`, `.claude/skills/`, `.gemini/skills/`, `.agents/skills/`). Tells the agent where Meristem skills are stored (`skills/<source>/<name>/SKILL.md`) and how to load them. Enables native skill discovery for OpenCode, Claude Code, Gemini, and generic agents.

- **presets**
  `skills/skills-presets.md` defines expert-maintained presets of skills for common stacks
  (for example, a preset `react-primer-spa` for React + Primer SPAs with a mocked backend).

- **skills.lock.md**
  Ensures reproducibility of downloaded skills and records which preset/iteration they belong to.

`skills.lock.md` is also an artifact of usage: it is created once the agent has downloaded and locked the selected skills for a given application; it is not present in the raw template.

---

## How It Works

1. Initialize knowledge (Step 1 – business & technical)  
   → use `init-product-knowledge` to create/structure `business.md`, `architecture.md`, `docs/specs/`

2. Complete business & architecture  
   → fill `business.md` (Vision / Product / Roadmap) and `architecture.md` (Stack / Architecture / Quality & tooling) through a question–answer cycle with the user  

3. Write specifications  
   → add content in docs/specs/  

4. Discover implementation capabilities (Step 2 – skills)  
   → use `discover-skills` based primarily on `architecture.md` (and `business.md`) to identify required external skills for the first roadmap iteration  

5. Download and lock skills  
   → download approved skills under `skills/<source>/<skill-name>/` and update `skills/skills.lock.md` to reflect the installed set  

6. Execute tasks  
   → guided by AGENTS.md and knowledge files  

---

## Principles

- Knowledge first  
- Reuse over reinvention  
- Explicit over implicit  
- Deterministic over heuristic  

---

## Positioning

This repository is not:

- a framework  
- a boilerplate  
- a code generator  

It is:

a minimal foundation for agent-driven software development

---

## Usage

### 1. Clone this repository as a template

```bash
git clone https://github.com/dsissoko/meristem.git my-app
cd my-app
```

### 2. Launch your agent

Meristem has been tested with several agent runtimes:

**OpenCode** (CLI or GitHub Actions):
```bash
opencode
```
OpenCode natively discovers the `meristem-skills-index` skill from `.opencode/skills/` and loads the Meristem process automatically.

**OpenHands** (cloud sandbox):
Trigger via the All Hands interface or GitHub Actions. OpenHands reads `.openhands/microagents/repo.md` and delegates to `AGENTS.md`.

**Claude Code / Codex CLI / other agents**:
Any agent that supports `.claude/skills/`, `.agents/skills/`, or `AGENTS.md` will pick up the Meristem process automatically.

### 3. Describe your app and target stack

```
I want to create a simple todo list that works on desktop and mobile.
Tech: React + Primer, frontend only with MSW to mock the backend.
Clean code, feature-based architecture.
```

The agent will:
1. Read `AGENTS.md` and load the Meristem process
2. Load the `meristem-skills-index` bootstrap skill
3. Ask you to fill `business.md` and `architecture.md`
4. Apply a matching skill preset from `skills/skills-presets.md`
5. Download and lock required skills in `skills/skills.lock.md`
6. Scaffold and implement your app

### Autonomous mode

For agents that support autonomous execution (OpenCode GitHub Actions, OpenHands):

- OpenCode: triggered by a comment on a GitHub issue or PR
- OpenHands: triggered via the All Hands interface or a GitHub issue label

Both follow the qualification logic defined in `AGENTS.md` (Autonomous Mode section).

---

## Prerequisites

The only hard requirement is that the agent runtime has access to the repository files and can read them.

For agents that execute code (build, test, install dependencies), the execution environment must provide the toolchain defined in `architecture.md` for the project. This varies per project and stack — the relevant locked skills define the exact commands to run.

For cloud agents (OpenHands, OpenCode GitHub Actions), the execution environment is managed by the platform.

---

## Goal

Provide a simple, stable base to build professional applications driven by agents.
