---
name: init-product-knowledge
description: Initialize and validate business.md, architecture.md and docs/specs/ structure in a Meristem repo
---

## Objective

Initialize, structure, and validate product knowledge files in the repository.
These files are the source of truth for all agents — their quality directly impacts agent behavior.

---

## Scope

Ensure the presence and quality of:

- `business.md` — product knowledge (domain, vision, roadmap)
- `architecture.md` — technical knowledge (stack, architecture, tooling)
- `docs/specs/` — functional and architecture specifications

---

## Process

### Step 1 — Check existence

For each missing file or directory, create it with minimal placeholders:

**`business.md` sections:**
- `# Vision` — the problem being solved and the target users
- `# Product` — key features and use cases
- `# Roadmap` — phases and priorities

**`architecture.md` sections:**
- `# Minimal stack` — **(mandatory)** concrete technologies: language, framework, UI library, backend/mock, build tool
- `# Application architecture` — project structure, feature organization, key patterns
- `# Quality & tooling` — tests (unit, integration, E2E), CI/CD, linting, formatting

### Step 2 — Validate content quality

For each existing file, validate that content is concrete and not just placeholders.

**`business.md` is valid if it contains:**
- A concrete Vision statement (real problem, real users — not generic)
- At least one defined Product feature with a clear use case
- A Roadmap with at least one phase and its priorities

**`architecture.md` is valid if it contains:**
- `# Minimal stack` with **all of the following explicitly defined:**
  - Frontend framework (e.g. React, Vue, Angular — or "none" if backend only)
  - UI library (e.g. Primer, MUI, Tailwind — or "none")
  - Backend or mock layer (e.g. Express, MSW, "none")
  - Build tool (e.g. Vite, Webpack, Gradle)
  - Primary language (e.g. TypeScript, Java, Python)
- `# Application architecture` with at least a project structure description
- `# Quality & tooling` with at least one test level defined

### Step 3 — Dialogue if incomplete

If any mandatory field is missing or contains only placeholders:
- Post a comment explaining exactly what is missing
- Ask targeted questions to obtain the missing information
- Do not proceed to implementation until both files are valid
- Update the files with the answers received

---

## Behavior

- Never overwrite existing valid content
- Never invent product or technical content — only what the user explicitly provides
- Keep structure minimal and readable

---

## Rules

- `architecture.md` without a defined stack is considered invalid — block any implementation until fixed
- `business.md` without a defined domain and at least one feature is considered invalid
- These files become the source of truth after validation — all agents rely on them
