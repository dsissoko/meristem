---
name: frontend-runtime-sanity
description: Ensure a minimal runtime smoke-test setup for the frontend so the agent can automatically verify that the app renders without crashing after code changes.
---

# Frontend Runtime Sanity

## Objective

Provide a **small but systematic safety net** for frontend applications in this repository so that:

- the agent always sets up at least one **runtime smoke test** for the UI, and  
- the agent **runs** that smoke test after significant frontend changes, before handing control back to the user.

This skill is tailored to this template and its conventions:

- monorepo layout with `frontend/` and future `backend/`,
- product and architecture knowledge in `business.md` and `architecture.md`,
- specs under `docs/specs/`.

It complements generic error-handling patterns (e.g. `wshobson/error-handling-patterns`) by focusing on **practical runtime checks for the frontend**.

---

## When to Use

Use this skill when **any** of the following is true:

- `architecture.md` describes a graphical frontend (web SPA, mobile, desktop), and the code lives under `frontend/`;  
- the agent is generating a **new frontend application** for the first time;  
- the agent is making **non-trivial changes** to existing frontend code (logic, components, routing, state, theming).

For the current stack:

- `architecture.md` specifies a React SPA with Vite and Primer UI,  
- the frontend lives under `frontend/`,  
- this skill assumes `frontend/` is the root of the React app.

---

## Expected Baseline (React + Vite)

For a React + Vite frontend under `frontend/`, the minimal runtime test setup is:

1. **Testing stack present**
   - `frontend/package.json` includes at least the following devDependencies (or equivalent):
     - `vitest`
     - `@testing-library/react`
     - `jsdom`
   - Vite config (`frontend/vite.config.ts`) configures Vitest with:
     - `test.environment = "jsdom"`
     - `test.globals = true` (optional but convenient)

2. **Smoke test file**
   - A test file such as `frontend/src/root/App.test.tsx` that:
     - imports React, `render` from Testing Library, and the top-level `App` component,  
     - wraps `App` in any required providers (theme, query client, router, etc.),  
     - renders `<App />` **without asserting UI details**, only that it does not throw.

3. **NPM scripts**
   - In `frontend/package.json`:
     - `"test": "vitest"`  
     - `"test:smoke": "vitest run"`

4. **Match the real runtime as much as reasonable**
   - If the app uses browser APIs not present in jsdom (for example `window.matchMedia` for theming):
     - configure them in the Vitest setup file (e.g. `frontend/src/test/setup.ts`) as lightweight shims,  
     - so that the smoke test exercises the same paths as the browser while staying deterministic.

5. **UI libraries that import CSS**
   - Some UI libs (design systems, component kits, etc.) import CSS files under `node_modules/`.  
   - In this repository, the smoke test should remain **minimal et robuste** :
     - soit en configurant Vitest pour ignorer/stubber ces imports de CSS,
     - soit, le plus simple, en **mockant la librairie UI** dans `frontend/src/test/setup.ts` pour ne garder que des wrappers HTML (boutons, inputs, etc.).
   - Le but du smoke test n’est pas de vérifier la mise en page pixel-perfect mais de s’assurer que :
     - l’application démarre,
     - les composants racines se montent sans erreur runtime,
     - les dépendances critiques (mocking, providers, etc.) sont correctement initialisées.

---

## Process

### Step 1 – Confirm the frontend context

1. Read `architecture.md` and confirm:
   - the presence of a web frontend (React SPA in the current project), and  
   - that `frontend/` is the application root (as described in the monorepo structure).
2. If the frontend stack is not React + Vite:
   - still apply the **principle** of a runtime smoke test,  
   - but adapt the concrete tools (e.g. a different test runner) based on `architecture.md`.

### Step 2 – Ensure a minimal runtime test setup exists

For React + Vite under `frontend/`:

1. Inspect `frontend/package.json`:
   - if `vitest` (and necessary test dependencies) are missing:
     - propose adding them and wait for user confirmation before modifying dependencies.
2. Inspect `frontend/vite.config.ts`:
   - if no `test` block is defined, add one with:
     - `environment: "jsdom"`,
     - `globals: true` (optional).
3. Ensure a smoke test file exists:
   - if no `App.test.tsx` (or equivalent) exists under `frontend/src/`:
     - propose creating a minimal smoke test that renders `App` with required providers.

### Step 3 – Define and use build + `test:smoke`

1. Ensure `frontend/package.json` includes:
   - `"test": "vitest"` and `"test:smoke": "vitest run"`.
2. After **any significant frontend change** in a React + Vite frontend under `frontend/`, the agent must:
   - run `cd frontend && npm run build`,  
   - then run `cd frontend && npm run test:smoke`,  
   - treat any failure (build ou smoke test) as **blocking**: fix the underlying issue or clearly report why it cannot be resolved.

### Step 4 – Keep it minimal and non-intrusive

This skill is intentionally narrow:

- it does **not** require full unit test coverage,  
- it does **not** define complex CI pipelines,  
- it only enforces, for the React + Vite frontend under `frontend/`:
  - un build du bundle (`cd frontend && npm run build`),  
  - un runtime smoke test (`cd frontend && npm run test:smoke`),  
  - et leur exécution automatique par l’agent après les changements significatifs.

For more advanced testing strategies (integration, end-to-end, performance), use other skills or describe them explicitly in `architecture.md` and `docs/specs/`.

### Step 5 – Watch for common runtime error patterns

Even when `npm run test:smoke` passes, the agent must pay attention to
**runtime error patterns** that frequently indicate misconfigured mocks
or server responses. In particular:

- `Unexpected token '<'` or `"is not valid JSON"` in stack traces or
  console output typically means that a `fetch(...).json()` call has
  received HTML (for example `index.html`) instead of JSON.
- MSW-related messages such as:
  - `Failed to register the Service Worker`,
  - `Failed to load resource: the server responded with a status of 404`
    for `/mockServiceWorker.js` or `/api/...`
  must be treated as **blocking** until MSW is correctly configured.

When such messages appear:

- treat the iteration as **failed** even if Vitest/JSDOM does not
  surface them as hard test failures, and  
- either:
  - fix the underlying issue (for example: missing MSW worker script,
    wrong bootstrap condition, wrong API URL), then rerun
    `npm run build && npm run test:smoke`, or  
  - explicitly record the limitation and provide concrete follow-up
    steps (commands, config) for maintainers.
