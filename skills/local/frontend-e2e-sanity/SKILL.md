---
name: frontend-e2e-sanity
description: Minimal browser-based E2E smoke test for the frontend using Playwright via npm, so the agent can automatically detect client-side console errors and page-load issues.
---

# Frontend E2E Sanity

## Objective

Provide a **lightweight end-to-end sanity check** for the frontend so that the agent can:

- start the built/served application,
- open it in a real browser (via Playwright),
- capture browser console errors (including Service Worker/MSW issues),
- and fail fast if critical client-side errors occur, even when build and unit/smoke tests pass.

This skill complements:

- bundler checks (e.g. `npm run build`), and  
- runtime smoke tests (e.g. `npm run test:smoke` with Vitest),

by adding a **real-browser smoke test** focused on page load and console errors.

---

## Quick Start (exactly in this order)

1. **Create** `frontend/e2e-smoke.mjs` with the script below (copy-paste, do not modify)
2. **Start server**: `cd frontend && npm run preview -- --port 5173 &`
3. **Wait** 5 seconds for server to be ready
4. **Run smoke**: `cd frontend && node e2e-smoke.mjs`
5. **Stop server** when done (Ctrl+C or kill the process)

**Do not invent alternatives. Do not try to use Python, with_server.py, or custom scripts.** This exact workflow is required.

---

## When to Use

Use this skill when:

- the project includes a web frontend (React + Vite SPA in this repository), and  
- the agent needs to validate that the application:
  - loads without hard errors in the browser (no blank screen due to runtime JS errors), and  
  - does not emit critical console errors (e.g. MSW registration failures) on initial load.

It is particularly important **after**:

- significant changes to frontend bootstrapping (e.g. MSW setup, theming, routing),
- changes to Service Worker or mocking logic,
- changes to global configuration or environment handling.

---

## Dependencies & Environment

This skill assumes:

- Node.js and npm are available in the agent's execution environment.
- The project has a `frontend/` directory with a `package.json`.

### Installation Model (always local)

The agent installs Playwright **inside the project's node_modules**, not globally:

```bash
cd frontend
npm install --cache .npm-cache -D playwright
npx playwright install chromium
```

If the environment ne permet pas d’exécuter ces commandes (npm indisponible, cache non inscriptible, etc.) :

- considérer l’E2E comme **non exécuté** pour cette itération,
- documenter clairement dans la réponse :
  - pourquoi l’E2E n’a pas été lancé,
  - quelles commandes le mainteneur doit lancer localement pour l’activer.

---

## Recommended Workflow (React + Vite frontend)

### Step 1 – Ensure the app can be built

Before running E2E, the agent should already have:

- `cd frontend && npm run build` passing (as required by `AGENTS.md`).

### Step 2 – Install Playwright

```bash
cd frontend
npm install -D playwright
npx playwright install chromium
```

### Step 3 – Serve the built app

Serve the built app de façon minimale :

```bash
cd frontend
npm run preview -- --port 5173
```

Le smoke test suppose que l’application est disponible sur `http://localhost:5173`.

### Step 4 – Run E2E smoke test (canonical script)

Create a minimal smoke test script inside the project:

```javascript
// e2e-smoke.mjs
import { chromium } from 'playwright'

const CRITICAL_PATTERNS = [
  'Failed to register the Service Worker',
  'Uncaught',
  'Unexpected token',
  'is not valid JSON',
  '404 (Not Found)',
]

async function main() {
  const browser = await chromium.launch({ headless: true })
  const page = await browser.newPage()
  const errors = []

  page.on('console', (msg) => {
    const text = msg.text()
    if (CRITICAL_PATTERNS.some((pattern) => text.includes(pattern))) {
      errors.push(text)
    }
  })

  await page.goto('http://localhost:5173', { waitUntil: 'networkidle' })

  // Minimal user flow: create one todo and ensure it appears.
  await page.getByRole('textbox', { name: /titre de la todo/i }).fill('Todo E2E')
  await page.getByRole('button', { name: /ajouter à la liste/i }).click()
  await page.getByText('Todo E2E').first().waitFor()

  if (errors.length > 0) {
    console.error('Critical errors found:', errors)
    await browser.close()
    process.exit(1)
  }

  await browser.close()
  console.log('E2E smoke test passed')
}

main().catch((error) => {
  console.error(error)
  process.exit(1)
})
```

Run it:

```bash
cd frontend
node e2e-smoke.mjs
```

---

## Agent Responsibilities

When applying this skill, the agent must:

1. Install Playwright via npm inside the project (`npm install -D playwright`).
2. Install Chromium browser via `npx playwright install chromium`.
3. Ensure the smoke E2E test is run as part of the post-implementation validation, alongside:
   - `cd frontend && npm run build`
   - `cd frontend && npm run test:smoke`
4. If E2E cannot be run (for example, npm is not available), explicitly state that E2E validation was not executed and provide a workaround plan.
