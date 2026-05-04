# spec-to-site

Generate the spec documentation source files in `docs/specs/`.

## Role of this skill

This skill covers **only the agent's responsibilities**. The static site build and deployment are handled automatically by the CI workflows (`deploy-pages.yml`, `pr-preview.yml`) — the agent must not attempt to build or deploy the site.

## What the agent does

The agent produces and maintains the Markdown source files under `docs/specs/`:

- Functional specs: epics (`epic.md`) and user stories (`us-<nn>-<name>.md`) under `docs/specs/functional/`
- Architecture diagrams: C4 diagrams in Mermaid syntax under `docs/specs/architecture/`

These files are committed to git. The CI picks them up and builds the static site automatically.

## What the agent must NOT do

- Do not run any build, install, or preview command
- Do not create or modify `docs/site/` — it is obsolete and gitignored
- Do not modify `docs/specs/.vitepress/` — VitePress config is not the agent's responsibility
- Do not attempt to build or serve the site — this is handled by CI
