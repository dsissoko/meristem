# AGENTS.md

## Purpose

This repository is a knowledge-driven template for agent-based development.

It provides:
- explicit product knowledge
- reusable skills

The agent must rely on both to operate correctly.

---

## Startup (Mandatory)

**Before any task**, the agent must:
1. Read `skills/skills.lock.md` to identify locked skills
2. For each locked skill:
   a. If the execution environment provides a native skill-loading mechanism, attempt to use it
   b. **Always** read its `SKILL.md` directly from the filesystem at
      `skills/<source>/<skill-name>/SKILL.md` — this is the authoritative and mandatory step
3. All locked `SKILL.md` files must be in context before any implementation starts

This applies even for maintenance tasks (bug fixes, new features). Locked skills are the baseline.

---

## Core Principle

Always rely on repository knowledge before acting.

Order of precedence:
1. skills/skills.lock.md (loaded first)
2. business.md
3. architecture.md
4. docs/specs/
5. skills/

---

## Behavior Rules

- Do not start implementation without understanding the product context
- Do not invent requirements not present in knowledge files
- Prefer reuse of skills over custom logic
- Be explicit and deterministic

---

## Mandatory Checklist Before Any Implementation

Before creating or modifying **any** of the following:
- application code (frontend, backend, infra, scripts)
- detailed HTTP/API specs
- UI/UX flows

the agent **must** follow these steps in order:

### Step 1 – Verify knowledge files

- Check that `business.md` and `architecture.md` exist.
- Check that they are not empty and not limited to generic placeholders.
- For `business.md`, ensure it contains concrete, product-specific information about the vision, product scope, and roadmap.
- For `architecture.md`, ensure it contains concrete technical decisions about the minimal stack, application architecture, and quality/tooling.

**If any file is missing:**
- Use `skills/local/init-product-knowledge/SKILL.md` to create the structure.
- Do **not** add product content at this stage.

**If any file is empty or only contains placeholders:**
- **Suspend implementation immediately** (no code, no specs).
- Start an explicit **question/answer cycle** with the user to:
  - clarify the vision (problem, target users, value),
  - define the product (use cases, scope),
  - sketch the roadmap (phases, priorities),
  - specify the minimal stack and application architecture.
- If the product involves a graphical user interface (web, mobile, desktop) and the user has **not** specified any testing stack, the agent must explicitly propose a minimal GUI testing setup (for example: component-level runtime/smoke tests with a lightweight tool such as Vitest for React) and confirm the choice with the user before moving on to implementation.
- Update `business.md` and `architecture.md` with the answers.

---

### Step 2 – Discover and load skills

Once `business.md` and `architecture.md` are validated, and **before** anything else:

1. **Apply skill presets (sub-step 2a – default baseline)**
   - Read `skills/skills-presets.md` if the file exists.
   - Identify a preset whose "Match stack" criteria correspond to the stack described in `architecture.md`
     (for example: `domain`, `frontend`, `ui_library`, `backend`, etc.).
   - If a preset clearly matches:
     - present its skill list to the user as the **default baseline** for the first iteration,
     - ask for explicit validation (full acceptance, partial acceptance, or adjustments).

2. **Complete with skill discovery (sub-step 2b – targeted additions)**
   - Use `skills/local/discover-skills/SKILL.md` to identify any additional skills needed for the **first roadmap iteration** described in `business.md`.
   - Drive discovery primarily from `architecture.md` (stack, architecture, tooling) and secondarily from `business.md`, taking into account skills already proposed by the preset.
   - Run a question/answer cycle with the user if needed to clarify technical constraints, confirm the scope, or decide on additional skills.

3. **Download and lock skills**
   - For each approved skill:
     - download it under `skills/<source>/<skill-name>/`,
     - ensure it includes at least `SKILL.md` and `SOURCE.md`.
   - Update `skills/skills.lock.md` to reflect the exact list and sources of installed skills.

4. **Read all locked skills**
   - Read the `SKILL.md` of every skill listed in `skills/skills.lock.md`.
   - This is mandatory: skills must be in context before the specification phase and before any implementation.

---

### Step 3 – Propose a specification phase (optional but always offered)

Once skills are loaded, **explicitly ask the user** whether they want a structured specification phase before implementation.

This phase is **not mandatory**, but the agent must always offer it. Do not skip the question.

If the user declines, proceed directly to Step 4.

**If the user accepts:** load the `spec-phase` preset from `skills/skills-presets.md` — read the `SKILL.md` of each skill it contains before proceeding.

If specs already exist in `docs/specs/`, the agent must read them before implementing anything.

---

#### If the user accepts — Specification process

The specification phase follows a **dialogue-first, file-generation-second** approach.

##### Sub-step 3a – Propose the specification tree

Before writing any file, the agent must present a **2-level tree** covering both sides:

```
docs/specs/
├── functional/
│   ├── epic-01-<name>/
│   │   ├── epic.md
│   │   ├── us-01-<name>.md
│   │   └── us-02-<name>.md
│   └── epic-02-<name>/
│       └── ...
└── architecture/
    ├── software/
    │   ├── c4-context.md
    │   ├── c4-containers.md
    │   └── c4-components-<feature>.md   (only if adds value)
    └── infrastructure/
        └── c4-deployment.md
```

**Rules for proposing the tree:**
- Derive epics and architecture containers from `business.md` and `architecture.md`
- Make explicit hypotheses for each node — state them clearly
- Mark nodes as `[empty — missing information]` when the agent has no basis to fill them
- **Never invent content** to fill a section that lacks a real basis
- Keep the tree concise: 2–4 epics maximum for a first iteration

**Wait for explicit user validation of the tree before generating any file.**
The user may rename, add, remove, or reorder nodes at this stage.

---

##### Sub-step 3b – Fill the functional side

Use the `deanpeters/epic-breakdown-advisor` skill from the `spec-phase` preset to guide epic and user story production.

For each epic in the validated tree:
1. Present a short epic hypothesis (problem, scope, expected outcome)
2. Propose a breakdown into user stories using the epic-breakdown-advisor patterns
3. Wait for user feedback before writing files
4. Once validated, generate:
   - `epic.md` — epic title, problem statement, scope, success criteria
   - one `us-<nn>-<name>.md` per user story — title, narrative, acceptance criteria

**If information is missing for a story or epic:** write the file with explicit `<!-- TODO: ... -->` markers rather than invented content.

---

##### Sub-step 3c – Fill the architecture side

Use `softaworks/c4-architecture` and `softaworks/mermaid-diagrams` skills from the `spec-phase` preset to guide diagram production.

For each architecture node in the validated tree:
1. Present a short hypothesis of what the diagram will show
2. Wait for user feedback or confirmation
3. Once validated, generate the Mermaid diagram in the corresponding file

**Levels to produce (in order):**
- `c4-context.md` — always required: system + external actors
- `c4-containers.md` — always required: applications, databases, services
- `c4-components-<feature>.md` — only if it genuinely adds value for a specific feature
- `c4-deployment.md` — infrastructure nodes, runtime instances, network boundaries

**Rules:**
- Use Mermaid C4 syntax exclusively (C4Context, C4Container, C4Component, C4Deployment)
- Each file contains one diagram + a short explanatory paragraph
- If infrastructure details are unknown, mark the deployment diagram as `[empty — pending infrastructure decisions]`
- Never show more than 20 elements per diagram; split if needed

---

##### Sub-step 3d – Iterate

Once a first version of all files is generated:
- Present a summary of what was produced and what was left empty
- Explicitly invite the user to review, correct, or complete the empty sections
- The agent must **never consider the spec complete** as long as sections are marked empty

---

### Step 4 – Implementation

Resume implementation only when:
- `business.md` and `architecture.md` contain **concrete, validated information**,
- all required skills have been identified, validated, downloaded, and read,
- the specification phase has been explicitly accepted or declined by the user,
- and `skills/skills.lock.md` is up to date.

---

### Step 5 – Post-implementation validation (build, runtime sanity & E2E)

After completing any **significant implementation** on application code (frontend or backend), the agent must:
- identify one or more **minimal automated checks** for the current stack (for example: a bundler build + a runtime smoke test), and
- attempt to run them automatically. Continue unless a check fails.

For the React + Vite SPA described in `architecture.md`, when a React + Primer preset is used (for example `react-primer-spa` or `react-primer-spa-github-style`), the agent must:
- rely on the `local/frontend-runtime-sanity` skill to configure and run the "build + runtime smoke test" under `frontend/`,
- rely on the `anthropics/webapp-testing` and `local/frontend-e2e-sanity` skills for browser-based E2E smoke checks.

The **concrete commands** to run for this stack are defined by these skills and must be followed strictly.

If any check fails, the agent must either:
- fix the underlying issue and rerun the checks until they pass, or
- explicitly report the failure and the reason it cannot be resolved within the current iteration. When E2E checks cannot be run due to environment restrictions, the agent must clearly state this and provide the exact commands or CI configuration needed to run them externally.

---

Any implementation started without passing this checklist is considered a
**behavioral error** and must be corrected by:
- stopping ongoing changes,
- clarifying the knowledge with the user,
- then realigning code and specs with the updated knowledge.

---

## Skill Usage

When a task requires specific capabilities:

1. Identify if a relevant local skill exists
2. If yes:
   - read its `SKILL.md`
   - apply instructions strictly

Available local skills:
- `local/discover-skills` — find and recommend external skills
- `local/init-product-knowledge` — initialize `business.md`, `architecture.md`, `docs/specs/`
- `local/monorepo-simple-structure` — minimal monorepo layout
- `local/react-primer-feature-architecture` — feature-based architecture for React + Primer
- `local/frontend-runtime-sanity` — build + runtime smoke test setup
- `local/primer-vitest-runtime` — Vitest setup for Primer/React
- `local/frontend-e2e-sanity` — Playwright E2E smoke checks
- `local/app-first-gen-safety` — startup and error boundary for first app generation
- `local/vite-react-agent-cookbook` — Vite + React scaffolding without interactive prompts
- `local/spec-to-site` — generate a navigable docsify site from `docs/specs/` with Mermaid rendering
- `local/skills-health-check` — check filesystem integrity and source availability of all installed skills

---

## Skill Discovery

When no suitable skill is available:

1. Use `skills/local/discover-skills/SKILL.md`
2. Identify relevant external skills
3. Provide a shortlist (3–5 skills)
4. Ask for confirmation before downloading

---

## Skill Download

When a skill is selected:

- Download it locally under:

  skills/<source>/<skill-name>/

- Each downloaded skill must include:
  - SKILL.md
  - SOURCE.md

- Update `skills/skills.lock.md`

---

## Product Knowledge Initialization

When the user asks to initialize or reset project knowledge:

- Use `skills/local/init-product-knowledge/SKILL.md`

This must ensure the presence of:
- business.md
- architecture.md
- docs/specs/

---

## Skill Usage Rules

- Always read `SKILL.md` before execution
- Do not reimplement logic already covered by a skill
- Do not modify external skills directly
- For customization, create a local skill under `skills/local/`

---

## External Tools & Binaries

When a task requires an external runtime or CLI:

- Use **npm/npx** as the primary method for JavaScript/Node.js tools (Playwright, Vitest, etc.)
- Prefer installing tools via `npm install -D <package>` rather than global installs
- Use `npx` to run tools without installing them globally

For this template and environment:

- Always prefer a **local npm cache** at project level:
  - use `npm install --cache .npm-cache` dans les dossiers applicatifs (par ex. `frontend/`),
  - ou configurer un `.npmrc` local avec `cache = .npm-cache`.
- Ne jamais supposer que le cache global npm (`~/.npm/_cacache`) est disponible en écriture.
- Ne jamais supposer que Python ou des scripts auxiliaires existent parce qu’un SKILL en parle :
  - vérifier leur présence avec `ls` ou `find`,
  - si un script référencé est absent, appliquer le fallback prévu par le SKILL local (ou le documenter dans `docs/specs/`) au lieu de “deviner” une solution.

If npm/npx is not available, the agent must explicitly report the limitation.

---

## General Constraints

- No assumptions
- No hallucinated skills
- Only verifiable sources
- Prefer clarity over creativity

When modifying fichiers scaffold générés par des outils (templates Vite, config initiale, etc.) :

- si l’intention est de **remplacer entièrement** le contenu, préférer un patch de type “Delete + Add” plutôt qu’une mise à jour partielle fragile,
- éviter les diffs complexes sur de très gros fichiers générés automatiquement quand une réécriture complète est plus simple et plus lisible.
