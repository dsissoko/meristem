---
name: monorepo-simple-structure
description: Minimal monorepo layout for this template, with explicit frontend/backend separation and integration with business.md, architecture.md, and docs/specs/.
---

# Monorepo Simple Structure

## Objective

Define a **minimal monorepo layout** for this project with:

- a `frontend/` directory for the React app (and future frontends),
- a `backend/` directory reserved for a future backend,
- specifications centralized in `docs/specs/`,
- full compatibility with `AGENTS.md`, `business.md`, and `architecture.md`.

This skill is inspired by `monorepo-spec-kit-structure` but **only adopts directory structure conventions**.  
It does **not** prescribe tooling (Nx, Turborepo, workspaces, CI, etc.) or extra complexity.

---

## Existing conventions (from this template)

The following conventions are **authoritative**:

- `AGENTS.md` at repository root = main agent rules.
- `business.md` = product vision, scope, roadmap.
- `architecture.md` = minimal stack, application architecture, quality/tooling.
- `docs/specs/` = single place for detailed specifications.
- `skills/` = all skills (local and external) live here.

No additional sources of truth are introduced (e.g. no `CLAUDE.md`, no `specs/overview.md`, no `specs/architecture.md`).

---

## Target monorepo layout

Once the monorepo structure is in place, the target layout is:

```text
/
  AGENTS.md
  business.md
  architecture.md
  docs/
    specs/
      ... (internal organisation is flexible)
  skills/
    ... (local and external skills)
  frontend/
    AGENTS.md (optional, frontend-specific rules)
    package.json
    src/
    ...
  backend/
    AGENTS.md (optional, backend-specific rules)
    ... (future backend code)
```

### Key points

- `frontend/` contains **all frontend code** (e.g. the test-seed React app).
- `backend/` is **reserved** for a future backend (API, services, etc.), even if initially empty.
- `docs/specs/` remains the **only** place for detailed specs (no extra `/specs/` at repo root).
- Root `AGENTS.md` stays the global reference; `AGENTS.md` under `frontend/` or `backend/` may refine rules **without contradicting** the root.

---

## Placement rules

When creating or modifying files:

1. **Application code**
   - UI, frontend logic, frontend assets → always under `frontend/`.
   - API / domain services / jobs, etc. → under `backend/` (when it exists).

2. **Specifications**
   - Product specs, use cases, APIs, flows, UI, infra → under `docs/specs/`.
   - `business.md` and `architecture.md` remain high-level synthesis documents above `docs/specs/`.

3. **Agent rules**
   - Global rules → root `AGENTS.md` (already present).
   - Frontend-specific conventions (e.g. React/Primer rules) → `frontend/AGENTS.md` (optional).
   - Backend-specific conventions → `backend/AGENTS.md` (optional, later).

---

## Progressive migration (when code already lives at repo root)

If frontend code already exists at the repository root (e.g. `src/`, `package.json`):

1. **Do not infer intentions silently**  
   Always check `business.md` / `architecture.md` and the product goals first.

2. **Plan an explicit migration**  
   - Move `src/`, `package.json`, and frontend config into `frontend/`.
   - Update paths and scripts accordingly (e.g. `frontend/package.json`, npm scripts).

3. **Keep it simple**  
   - Do not introduce workspaces or advanced monorepo tooling unless explicitly requested in `architecture.md`.
   - The goal is a clear `frontend/` / `backend/` layout, not a complex tool stack.

---

## Out of scope

This skill **does not cover**:

- workspace configuration (npm, pnpm, yarn, Nx, Turborepo, etc.),
- CI/CD, caching, multi-project pipelines,
- detailed API or database conventions.

For those topics, either:

- describe them in `architecture.md` + `docs/specs/`, or
- create dedicated skills (local or external) if/when needed.

