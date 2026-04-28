<p align="center">
  <img src="assets/meristem.png" alt="Meristem logo" width="260" />
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

- discover-skills  
  Finds relevant external skills for the first roadmap iteration, **after** applying any relevant presets.

- init-product-knowledge  
  Initializes business/architecture knowledge files and structure.

- presets  
  `skills/skills-presets.md` defines **expert-maintained presets** of skills for common stacks
  (for example, a preset `react-primer-spa` for React + Primer SPAs with a mocked backend).

- skills.lock.md  
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
# Clone the template
git clone https://github.com/your-org/your-repo.git my-app
cd my-app
```

### 2. Launch your agent CLI

Currently tested with **Codex CLI**:

```bash
# Interactive mode
codex

# Interactive mode but with some autonomous
codex --full-auto

# Or with exec mode
codex exec --full-auto "create a todo list app with React + Primer, MSW, dark/light mode"
```

### 3. Describe your app and target stack

Just describe what you want to build - for example:

```
I want to create a simple todo list that works on desktop and mobile. For V0: list with state change, skin management (Chrome style) and dark/light mode, GitHub-like look. 
One todo with title, detail, state - list mode in V0, kanban in V1 later. Tech: React + Primer, frontend only with MSW to mock the backend, Excel export. Clean code, MVC/MVVM patterns for maintenance.
```

The agent will:
1. Read the product knowledge (business.md, architecture.md)
2. Apply a matching skill preset from skills/skills-presets.md
3. Download and lock required skills in skills/skills.lock.md
4. Scaffold and implement your app

### Autonomous mode (Codex)

To use autonomous execution with Codex, launch with `--full-auto`:

```bash
# Recommended autonomous mode
codex --full-auto "your prompt"

# No restrictions (dangerous - only in Docker/VM)
codex --yolo
```

Or type `/permissions` during an interactive session to change the mode.

---

## Prerequisites (Agent Runtime)

This template is designed so that a capable agent can verify its own work as much as possible (build, runtime smoke tests, and browser-based E2E checks) without requiring manual setup from the user on every run.

For the CLI / local agent environment, the following tools should be available **inside the agent's sandbox**:

- Node.js + npm  
  - Used for installing frontend dependencies and running:
    - `cd frontend && npm install`
    - `cd frontend && npm run build`
    - `cd frontend && npm run dev` / `npm run preview`
    - `cd frontend && npm run test:smoke`
  - Also used to install and run Playwright for browser-based E2E smoke tests:
    - `cd frontend && npm install -D playwright`
    - `cd frontend && npx playwright install chromium`
    - puis exécuter un petit script `node smoke.mjs` ou `npx playwright test` qui ouvre l’app et vérifie les erreurs console.

These installations happen **inside the agent's own execution environment** (local sandbox or cloud container).  
If the environment empêche d’installer ou d’exécuter Playwright, l’agent doit l’indiquer explicitement et fournir des commandes ou une configuration CI équivalente.

---

## Host prerequisites (CLI & Cloud)

To use this repository as a “bare” agentic starter on a fresh Linux or WSL environment, the host (local machine or container image) should provide:

- `git` and a POSIX-compatible shell (e.g. `bash`, `zsh`)  
- **Node.js LTS** (18+ recommended, 20+ ideal) with `npm`  
  - Required so the agent can:
    - install frontend dependencies under `frontend/` (`npm install`),
    - build the app (`npm run build`),
    - run the dev/preview server (`npm run dev` / `npm run preview`),
    - run runtime smoke tests (`npm run test:smoke` with Vitest),
    - installer et exécuter Playwright pour les checks E2E (`npm install -D playwright`, `npx playwright install chromium`, puis `node smoke.mjs` ou `npx playwright test`).
- Network access (HTTP/HTTPS) from the agent's sandbox to:
  - fetch npm packages and Playwright browser binaries.

These requirements apply both to:

- a local CLI agent (e.g. Codex CLI running on your workstation), and  
- a cloud/remote agent (e.g. OpenHands running in a container image), which should be built with the same toolchain available inside the container.

---

## Goal

Provide a simple, stable base to build professional applications driven by agents.
