# AGENTS.md

## Purpose

This repository is a knowledge-driven template for agent-based development.

It provides:
- explicit product knowledge
- reusable skills

The agent must rely on both to operate correctly.

---

## Core Principle

Always rely on repository knowledge before acting.

Order of precedence:
1. business.md
2. architecture.md
3. docs/specs/
4. skills/

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

the agent **must**:

1. **Verify knowledge files (Step 1 – knowledge)**
   - Check that `business.md` and `architecture.md` exist.
   - Check that they are not empty and not limited to generic placeholders.
   - For `business.md`, ensure it contains concrete, product-specific information about the vision, product scope, and roadmap.
   - For `architecture.md`, ensure it contains concrete technical decisions about the minimal stack, application architecture, and quality/tooling.

2. **If any file is missing**
   - Use `skills/local/init-product-knowledge/SKILL.md` to create the structure.
   - Do **not** add product content at this stage.

3. **If any file is empty or only contains placeholders**
   - **Suspend implementation immediately** (no code, no specs).
   - Start an explicit **question/answer cycle** with the user to:
     - clarify the vision (problem, target users, value),
     - define the product (use cases, scope),
     - sketch the roadmap (phases, priorities),
     - specify the minimal stack and application architecture.
   - If the product involves a graphical user interface (web, mobile, desktop) and the user has **not** specified any testing stack, the agent must explicitly propose a minimal GUI testing setup (for example: component-level runtime/smoke tests with a lightweight tool such as Vitest for React) and confirm the choice with the user before moving on to implementation.
   - Update `business.md` and `architecture.md` with the answers.

2. **Discover implementation skills (Step 2 – capabilities)**
   - Once `business.md` and `architecture.md` are validated, and **before** writing any implementation code:
     1. **Apply skill presets (sub-step 2a – default baseline)**
        - Read `skills/skills-presets.md` if the file exists.
        - Identify a preset whose “Match stack” criteria correspond to the stack described in `architecture.md`
          (for example: `domain`, `frontend`, `ui_library`, `backend`, etc.).
        - If a preset clearly matches:
          - present its skill list to the user as the **default baseline** for the first iteration,
          - ask for explicit validation (full acceptance, partial acceptance, or adjustments).
     2. **Complete with skill discovery (sub-step 2b – targeted additions)**
        - Then use `skills/local/discover-skills/SKILL.md` to identify any additional skills needed for the **first roadmap iteration** described in `business.md`.
        - Drive discovery primarily from `architecture.md` (stack, architecture, tooling) and secondarily from `business.md`, taking into account skills already proposed by the preset.
   - Run a question/answer cycle with the user if needed to:
     - clarify technical constraints,
     - confirm the scope of the first iteration,
     - decide whether additional skills are needed beyond the preset.

3. **Post-implementation validation (Step 3 – build, runtime sanity & E2E)**
   - After completing any **significant implementation** on application code (frontend or backend), the agent must:
     - identify one or more **minimal automated checks** for the current stack (for example: a bundler build + a runtime smoke test), and  
     - attempt to run them automatically. Continue unless a check fails.
   - For the React + Vite SPA described in `architecture.md`, when a React + Primer preset is used (for example `react-primer-spa` ou `react-primer-spa-github-style`), the agent must:
     - rely on the `local/frontend-runtime-sanity` skill to configure and exécuter le couple “build + runtime smoke test” sous `frontend/`,  
     - rely on the `anthropics/webapp-testing` and `local/frontend-e2e-sanity` skills for browser-based E2E smoke checks.
   - The **concrete commands** to run for this stack (par exemple `cd frontend && npm run build`, `cd frontend && npm run test:smoke`, démarrage du `preview` Vite et exécution du smoke Playwright) are defined by these skills and must be followed strictly.
   - If any of these checks fails, the agent must either:
     - fix the underlying issue and rerun the checks until they pass, or  
     - explicitly report the failure and the reason it cannot be resolved within the current iteration. When E2E checks cannot be run due to environment restrictions, the agent must clearly state this and provide the exact commands or CI configuration needed to run them externally.

3. **Skill download and locking**
   - For each approved skill:
     - download it under `skills/<source>/<skill-name>/`,
     - ensure it includes at least `SKILL.md` and `SOURCE.md`.
   - After all skills required for the first roadmap iteration are downloaded:
     - update `skills/skills.lock.md` to reflect the exact list and sources of installed skills.

4. **Resume implementation only when**
   - `business.md` and `architecture.md` contain **concrete, validated information**,
   - the skills required for the first iteration have been identified, validated, and downloaded,
   - and `skills/skills.lock.md` has been updated accordingly.
   - **ALL locked skills have been read**: The agent must read the `SKILL.md` file of every skill listed in `skills/skills.lock.md` before starting implementation. This is mandatory to ensure the agent knows the available capabilities and follows the correct patterns.

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
- `discover-skills`
- `init-product-knowledge`
- `monorepo-simple-structure`
- `react-primer-feature-architecture`
- `frontend-runtime-sanity`
- `frontend-e2e-sanity`
- `app-first-gen-safety`

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
