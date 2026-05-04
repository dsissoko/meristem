# Skills Set — Meristem v0.2

All skill sets used by Meristem agents.
Each set has a description to help `technical-skill-picker` select the right stack sets.

---

## Set: core
description: Skills chargés par tous les agents — contexte GitHub, initialisation produit, découverte de skills, format de réponse, workflow PR
- skills/local/github-issue-context
- skills/local/github-pr-context
- skills/local/init-product-knowledge
- skills/local/discover-skills
- skills/local/agent-response-format
- skills/local/pr-workflow

## Set: dev
description: Skills communs à tout agent développeur, indépendants de la stack technique
- skills/vercel-labs/react-best-practices
- skills/wshobson/error-handling-patterns
- skills/wshobson/javascript-testing-patterns
- skills/local/frontend-runtime-sanity
- skills/local/frontend-e2e-sanity
- skills/getsentry/code-review
- skills/leonxlnx/redesign-skill

## Set: qa
description: Tests, qualité et revue de code — indépendants de la stack
- skills/anthropics/webapp-testing
- skills/local/frontend-e2e-sanity
- skills/getsentry/code-review
- skills/leonxlnx/redesign-skill

## Set: po
description: Produit, backlog Scrum, diagrammes de flux pour les specs fonctionnelles
- skills/local/scrum-project-init
- skills/deanpeters/epic-breakdown-advisor
- skills/softaworks/mermaid-diagrams
- skills/local/spec-to-site

## Set: analyst
description: Analyse métier, modélisation du domaine, flux de processus, diagrammes
- skills/local/domain-analysis
- skills/deanpeters/jobs-to-be-done
- skills/deanpeters/opportunity-solution-tree
- skills/deanpeters/business-health-diagnostic
- skills/deanpeters/customer-journey-map
- skills/softaworks/c4-architecture
- skills/softaworks/mermaid-diagrams
- skills/local/spec-to-site

## Set: architect
description: Architecture C4, diagrammes techniques, gestion des skills
- skills/softaworks/c4-architecture
- skills/softaworks/mermaid-diagrams
- skills/local/skills-health-check
- skills/local/spec-to-site

## Set: help
description: FAQ et onboarding sur le framework Meristem
- skills/local/faq

## Set: design-references
description: Design de référence — extraction de tokens depuis un site public (GitHub, Stripe, Linear...) et direction artistique premium anti-slop pour éviter les interfaces génériques
- skills/arvindrk/extract-design-system
- skills/leonxlnx/taste-skill

## Set: autonomous
description: Capacité de passer la balle à un autre agent — chargé uniquement en mode autonome
- skills/local/agent-handoff

## Set: technical
description: Sélection dynamique des skills de stack — chargé par dev, qa, architect
- skills/local/technical-skill-picker

## Set: stack-fullstack-vite-react-primer
description: Stack frontend React + Vite + Primer UI + MSW — composants, tests, style, architecture feature-based
- skills/local/vite-react-agent-cookbook
- skills/local/react-primer-feature-architecture
- skills/local/react-primer-github-style-ui
- skills/local/frontend-runtime-sanity
- skills/local/monorepo-simple-structure
- skills/local/app-first-gen-safety
- skills/local/msw-vite-setup
- skills/openclaw/msw-skill
- skills/anthropics/frontend-design
- skills/bagustris/primer-style
- skills/bas/primer-design
- skills/local/primer-vitest-runtime
