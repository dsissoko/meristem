# Skill Presets

This file is maintained by experts.  
It defines recommended skill sets ("presets") for common stacks.

Agents read it during **Step 2 – capabilities** described in `AGENTS.md`, before completing the list with additional skills discovered from the user context.

---

## spec-phase

- **Match condition**
  - Loaded when the user explicitly accepts the specification phase (Step 3 of `AGENTS.md`)
  - Independent of the implementation stack — applies to any project type

- **Description**
  Structured specification phase: functional side (epics → user stories) and architecture side (C4 diagrams + Mermaid diagrams). Guides the agent through a dialogue-first, file-generation-second approach to produce `docs/specs/` content.

- **Recommended skills**
  - `deanpeters/epic-breakdown-advisor`
    - Source: `https://github.com/deanpeters/Product-Manager-Skills`
    - Path: `skills/deanpeters/epic-breakdown-advisor`
    - Role: Break down epics into actionable user stories using Richard Lawrence's 9 splitting patterns. Applied after the spec tree is validated by the user.
    - Iteration: `spec-phase`
  - `softaworks/c4-architecture`
    - Source: `https://github.com/softaworks/agent-toolkit`
    - Path: `skills/softaworks/c4-architecture`
    - Role: Generate C4 architecture diagrams (Context, Container, Component, Deployment) in Mermaid syntax. Used for the architecture side of the spec tree.
    - Iteration: `spec-phase`
  - `softaworks/mermaid-diagrams`
    - Source: `https://github.com/softaworks/agent-toolkit`
    - Path: `skills/softaworks/mermaid-diagrams`
    - Role: General-purpose Mermaid diagram generation (sequence, ERD, flowchart, state, etc.). Complements c4-architecture for data models, flows, and any non-C4 diagrams needed in specs.
    - Iteration: `spec-phase`
  - `local/spec-to-site`
    - Path: `skills/local/spec-to-site`
    - Role: Generate a browsable static site from `docs/specs/` using docsify + Mermaid. Produces `docs/site/index.html` and `_sidebar.md`. Preview via `npx docsify-cli serve docs/site`. Node.js/npx only.
    - Iteration: `spec-phase`

---

## react-primer-spa

- **Match stack**  
  - `domain`: `frontend`  
  - `frontend`: `react`  
  - `ui_library`: `primer`  
  - `backend`: `mock`

- **Description**  
  React + Primer SPA with a mocked backend (MSW), simple and polished UI, with theme/skin support and dark/light mode.

- **Recommended skills (baseline for MVP)**  
  - `local/vite-react-agent-cookbook`  
    - Path: `skills/local/vite-react-agent-cookbook`  
    - Role: Scaffolds projects using interactive CLIs (Vite, CRA) without prompts via manual scaffolding.  
    - Iteration: `MVP`
  - `local/react-primer-feature-architecture`  
    - Path: `skills/local/react-primer-feature-architecture`  
    - Role: feature-based architecture for React + Primer (UI / hooks / model / api / view-model).  
    - Iteration: `MVP`
  - `local/monorepo-simple-structure`  
    - Path: `skills/local/monorepo-simple-structure`  
    - Role: minimal monorepo layout with explicit frontend/backend separation aligned with this template.  
    - Iteration: `MVP`
  - `local/frontend-runtime-sanity`  
    - Path: `skills/local/frontend-runtime-sanity`  
    - Role: minimal frontend runtime smoke-test setup (Vitest + test:smoke) so the agent can verify the app renders without crashing.  
    - Iteration: `MVP`
  - `local/primer-vitest-runtime`  
    - Path: `skills/local/primer-vitest-runtime`  
    - Role: specialize the runtime smoke-test setup when using `@primer/react` with Vitest, so design-system CSS does not make tests brittle.  
    - Iteration: `MVP`
  - `local/app-first-gen-safety`  
    - Path: `skills/local/app-first-gen-safety`  
    - Role: ensure a minimal startup and UI error boundary is present for the first generation of the app.  
    - Iteration: `MVP`
  - `vercel-labs/react-best-practices`  
    - Source: `https://github.com/vercel-labs/agent-skills`  
    - Path: `skills/vercel-labs/react-best-practices`  
    - Role: React best practices (structure, performance).  
    - Iteration: `MVP`
  - `anthropics/frontend-design`  
    - Source: `https://github.com/anthropics/skills`  
    - Path: `skills/anthropics/frontend-design`  
    - Role: minimal, readable, production-grade frontend design.  
    - Iteration: `MVP`
  - `openclaw/msw-skill`
    - Source: `https://github.com/openclaw/skills` (path: `skills/anivar/msw-skill`)
    - Path: `skills/openclaw/msw-skill`
    - Role: MSW v2 best practices for a clean mocked backend.
    - Iteration: `MVP`
  - `anthropics/xlsx`  
    - Source: `https://github.com/anthropics/skills`  
    - Path: `skills/anthropics/xlsx`  
    - Role: Excel file generation/handling (todo list export).  
    - Iteration: `MVP`
  - `wshobson/error-handling-patterns`
    - Source: `https://github.com/wshobson/agents` (path: `plugins/developer-essentials/skills/error-handling-patterns`)
    - Path: `skills/wshobson/error-handling-patterns`
    - Role: Cross-language error handling patterns, including UI error boundaries and global handlers.
    - Iteration: `MVP`
  - `anthropics/webapp-testing`  
    - Source: `https://github.com/anthropics/skills`  
    - Path: `skills/anthropics/webapp-testing`  
    - Role: Toolkit for running Playwright-based E2E checks (browser logs, screenshots) against the local webapp.  
    - Iteration: `MVP`
  - `local/frontend-e2e-sanity`  
    - Path: `skills/local/frontend-e2e-sanity`  
    - Role: minimal browser-based E2E smoke test flow (with Playwright) to detect client-side console errors and blank-screen issues.  
    - Iteration: `MVP`
  - `bas/primer-design`  
    - Source: `https://skillkit.io/skills/claude-code/primer-design`  
    - Path: `skills/bas/primer-design`  
    - Role: design and implementation patterns for React UIs using the Primer design system (`@primer/react`) in a clear, production-ready way.  
    - Iteration: `MVP`
  - `bagustris/primer-style`  
    - Source: `https://skillsmp.com/skills/bagustris-skills-primer-style-skill-md`  
    - Path: `skills/bagustris/primer-style`  
    - Role: style and refactoring guidelines to keep existing React + Primer UIs simple, consistent and aligned with Primer conventions.  
    - Iteration: `MVP`

---

## react-primer-spa-github-style

- **Match stack**  
  - `domain`: `frontend`  
  - `frontend`: `react`  
  - `ui_library`: `primer`  
  - `backend`: `mock`  
  - `brand`: `github`  <!-- À utiliser lorsque l’utilisateur mentionne explicitement GitHub / un style GitHub -->

- **Description**  
  React + Primer SPA with a mocked backend (MSW), but with a GitHub-inspired layout and theming (topbar with Octicon, PageLayout, Panel/Stack primitives, skins + explicit dark/light toggle).

- **Recommended skills (baseline for MVP)**  
  - `local/vite-react-agent-cookbook`  
    - Path: `skills/local/vite-react-agent-cookbook`  
    - Role: Scaffolds projects using interactive CLIs (Vite, CRA) without prompts via manual scaffolding.  
    - Iteration: `MVP`
  - `local/react-primer-feature-architecture`  
    - Path: `skills/local/react-primer-feature-architecture`  
    - Role: feature-based architecture for React + Primer (UI / hooks / model / api / view-model).  
    - Iteration: `MVP`
  - `local/monorepo-simple-structure`  
    - Path: `skills/local/monorepo-simple-structure`  
    - Role: minimal monorepo layout with explicit frontend/backend separation aligned with this template.  
    - Iteration: `MVP`
  - `local/frontend-runtime-sanity`  
    - Path: `skills/local/frontend-runtime-sanity`  
    - Role: minimal frontend runtime smoke-test setup (Vitest + test:smoke) so the agent can verify the app renders without crashing.  
    - Iteration: `MVP`
  - `local/primer-vitest-runtime`  
    - Path: `skills/local/primer-vitest-runtime`  
    - Role: specialize the runtime smoke-test setup when using `@primer/react` with Vitest, so design-system CSS does not make tests brittle.  
    - Iteration: `MVP`
  - `local/app-first-gen-safety`  
    - Path: `skills/local/app-first-gen-safety`  
    - Role: ensure a minimal startup and UI error boundary is present for the first generation of the app.  
    - Iteration: `MVP`
  - `vercel-labs/react-best-practices`  
    - Source: `https://github.com/vercel-labs/agent-skills`  
    - Path: `skills/vercel-labs/react-best-practices`  
    - Role: React best practices (structure, performance).  
    - Iteration: `MVP`
  - `anthropics/frontend-design`  
    - Source: `https://github.com/anthropics/skills`  
    - Path: `skills/anthropics/frontend-design`  
    - Role: minimal, readable, production-grade frontend design.  
    - Iteration: `MVP`
  - `openclaw/msw-skill`
    - Source: `https://github.com/openclaw/skills` (path: `skills/anivar/msw-skill`)
    - Path: `skills/openclaw/msw-skill`
    - Role: MSW v2 best practices for a clean mocked backend.
    - Iteration: `MVP`
  - `anthropics/xlsx`  
    - Source: `https://github.com/anthropics/skills`  
    - Path: `skills/anthropics/xlsx`  
    - Role: Excel file generation/handling (todo list export).  
    - Iteration: `MVP`
  - `wshobson/error-handling-patterns`
    - Source: `https://github.com/wshobson/agents` (path: `plugins/developer-essentials/skills/error-handling-patterns`)
    - Path: `skills/wshobson/error-handling-patterns`
    - Role: Cross-language error handling patterns, including UI error boundaries and global handlers.
    - Iteration: `MVP`
  - `anthropics/webapp-testing`  
    - Source: `https://github.com/anthropics/skills`  
    - Path: `skills/anthropics/webapp-testing`  
    - Role: Toolkit for running Playwright-based E2E checks (browser logs, screenshots) against the local webapp.  
    - Iteration: `MVP`
  - `local/frontend-e2e-sanity`  
    - Path: `skills/local/frontend-e2e-sanity`  
    - Role: minimal browser-based E2E smoke test flow (with Playwright) to detect client-side console errors and blank-screen issues.  
    - Iteration: `MVP`
  - `bas/primer-design`  
    - Source: `https://skillkit.io/skills/claude-code/primer-design`  
    - Path: `skills/bas/primer-design`  
    - Role: design and implementation patterns for React UIs using the Primer design system (`@primer/react`) in a clear, production-ready way.  
    - Iteration: `MVP`
  - `bagustris/primer-style`  
    - Source: `https://skillsmp.com/skills/bagustris-skills-primer-style-skill-md`  
    - Path: `skills/bagustris/primer-style`  
    - Role: style and refactoring guidelines to keep existing React + Primer UIs simple, consistent and aligned with Primer conventions.  
    - Iteration: `MVP`

---

## react-primer-spa-github-style

- **Match stack**  
  - `domain`: `frontend`  
  - `frontend`: `react`  
  - `ui_library`: `primer`  
  - `backend`: `mock`  
  - `brand`: `github`

- **Description**  
  React + Primer SPA with a mocked backend (MSW), but with a GitHub-inspired layout and theming (topbar with Octicon, PageLayout, Panel/Stack primitives, skins + explicit dark/light toggle).

- **Recommended skills (baseline for MVP)**  
  - `local/vite-react-agent-cookbook`  
    - Path: `skills/local/vite-react-agent-cookbook`  
    - Role: Scaffolds projects using interactive CLIs (Vite, CRA) without prompts via manual scaffolding.  
    - Iteration: `MVP`
  - `local/react-primer-feature-architecture`  
    - Path: `skills/local/react-primer-feature-architecture`  
    - Role: feature-based architecture for React + Primer (UI / hooks / model / api / view-model).  
    - Iteration: `MVP`
  - `local/monorepo-simple-structure`  
    - Path: `skills/local/monorepo-simple-structure`  
    - Role: minimal monorepo layout with explicit frontend/backend separation aligned with this template.  
    - Iteration: `MVP`
  - `local/frontend-runtime-sanity`  
    - Path: `skills/local/frontend-runtime-sanity`  
    - Role: minimal frontend runtime smoke-test setup (Vitest + test:smoke) so the agent can verify the app renders without crashing.  
    - Iteration: `MVP`
  - `local/primer-vitest-runtime`  
    - Path: `skills/local/primer-vitest-runtime`  
    - Role: specialize the runtime smoke-test setup when using `@primer/react` with Vitest, so design-system CSS does not make tests brittle.  
    - Iteration: `MVP`
  - `local/app-first-gen-safety`  
    - Path: `skills/local/app-first-gen-safety`  
    - Role: ensure a minimal startup and UI error boundary is present for the first generation of the app.  
    - Iteration: `MVP`
  - `vercel-labs/react-best-practices`  
    - Source: `https://github.com/vercel-labs/agent-skills`  
    - Path: `skills/vercel-labs/react-best-practices`  
    - Role: React best practices (structure, performance).  
    - Iteration: `MVP`
  - `anthropics/frontend-design`  
    - Source: `https://github.com/anthropics/skills`  
    - Path: `skills/anthropics/frontend-design`  
    - Role: distinctive, production-grade frontend design with a clear aesthetic direction.  
    - Iteration: `MVP`
  - `openclaw/msw-skill`
    - Source: `https://github.com/openclaw/skills` (path: `skills/anivar/msw-skill`)
    - Path: `skills/openclaw/msw-skill`
    - Role: MSW v2 best practices for a clean mocked backend.
    - Iteration: `MVP`
  - `anthropics/xlsx`  
    - Source: `https://github.com/anthropics/skills`  
    - Path: `skills/anthropics/xlsx`  
    - Role: Excel file generation/handling (todo list export).  
    - Iteration: `MVP`
  - `wshobson/error-handling-patterns`
    - Source: `https://github.com/wshobson/agents` (path: `plugins/developer-essentials/skills/error-handling-patterns`)
    - Path: `skills/wshobson/error-handling-patterns`
    - Role: Cross-language error handling patterns, including UI error boundaries and global handlers.
    - Iteration: `MVP`
  - `anthropics/webapp-testing`  
    - Source: `https://github.com/anthropics/skills`  
    - Path: `skills/anthropics/webapp-testing`  
    - Role: Toolkit for running Playwright-based E2E checks (browser logs, screenshots) against the local webapp.  
    - Iteration: `MVP`
  - `local/frontend-e2e-sanity`  
    - Path: `skills/local/frontend-e2e-sanity`  
    - Role: minimal browser-based E2E smoke test flow (with Playwright) to detect client-side console errors and blank-screen issues.  
    - Iteration: `MVP`
  - `bas/primer-design`  
    - Source: `https://skillkit.io/skills/claude-code/primer-design`  
    - Path: `skills/bas/primer-design`  
    - Role: design and implementation patterns for React UIs using the Primer design system (`@primer/react`) in a clear, production-ready way.  
    - Iteration: `MVP`
  - `bagustris/primer-style`  
    - Source: `https://skillsmp.com/skills/bagustris-skills-primer-style-skill-md`  
    - Path: `skills/bagustris/primer-style`  
    - Role: style and refactoring guidelines to keep existing React + Primer UIs simple, consistent and aligned with Primer conventions.  
    - Iteration: `MVP`
  - `local/react-primer-github-style-ui`  
    - Path: `skills/local/react-primer-github-style-ui`  
    - Role: GitHub-inspired layout and theming for React + Primer SPA (topbar, PageLayout, Panel/Stack, skins + dark/light).  
    - Iteration: `MVP`
