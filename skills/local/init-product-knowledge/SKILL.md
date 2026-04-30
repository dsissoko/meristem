---
name: init-product-knowledge
description: Initialize business.md, architecture.md and docs/specs/ structure in a Meristem repo
compatibility: opencode
---

## Objective

Initialize and structure product knowledge files in the repository.

---

## Scope

Ensure the presence of the following elements:

- business.md
- architecture.md
- docs/specs/
- (optionally) a presets file `skills/skills-presets.md` for future expert-maintained skill presets

---

## Process

1. Check existence of required files and directories:
   - business.md
   - architecture.md
   - docs/specs/
   - skills/skills-presets.md (file only, if experts choose to create it; never overwrite existing content)

2. For each missing element:
   - create the file or directory

3. For newly created files:
   - insert minimal placeholders to guide future completion
   - in `business.md`, create sections:
     - `# Vision`
     - `# Product`
      - `# Roadmap`
   - in `architecture.md`, create sections:
     - `# Minimal stack`
     - `# Application architecture`
     - `# Quality & tooling`

4. Ensure global consistency:
   - files follow a simple and readable structure
   - no duplication of content
   - the optional `skills/skills-presets.md` file, when present, is considered as the place where experts can define stack-based presets (for example, a `react-primer-spa` preset for a React + Primer SPA)

---

## Behavior

- Do not overwrite existing content
- Do not modify files unless necessary
- Keep structure minimal and explicit

---

## Rules

- Knowledge files become the source of truth after creation
- This skill only initializes structure, not full content
