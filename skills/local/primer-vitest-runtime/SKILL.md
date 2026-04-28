---
name: primer-vitest-runtime
description: Bridge React + Primer with Vitest runtime smoke tests in this template, reusing frontend-runtime-sanity while keeping tests robust when @primer/react imports CSS.
---

# Primer + Vitest Runtime Sanity

## Objective

Provide a **repeatable way** to combine:
- React + Vite frontend using `@primer/react` (Primer), and
- the Vitest-based runtime smoke test described in `local/frontend-runtime-sanity`,

so that:
- the app can freely use Primer in runtime code, and  
- the **runtime smoke test** stays simple and stable, sans être bloqué par les imports CSS internes d’`@primer/react`.

This skill does **not** replace `frontend-runtime-sanity`, it **specializes** it for the React + Primer stack described by the `react-primer-spa` preset.

---

## Scope

- Stack: React + `@primer/react` + Vite + TypeScript.
- Tests: Vitest + Testing Library (`test:smoke`), JSDOM environment.
- Focus: interaction entre `@primer/react` (design system) et Vitest en environnement Node.

Out of scope:
- E2E tests (couverts par `frontend-e2e-sanity` + `anthropics/webapp-testing`),
- MSW configuration (couverte par `msw-skill` + `msw-vite-setup`),
- architecture globale (couverte par `react-primer-feature-architecture`).

---

## Core Principles

1. **HTML pour le layout, Primer pour les contrôles**  
   - Respecter `bas/primer-design` :  
     - layout global et structure → HTML + CSS du projet,  
     - contrôles interactifs (boutons, inputs, labels de statut, spinners) → `@primer/react`.

2. **Surface Primer minimale dans le smoke test**  
   - Le but du smoke test n’est pas de tester Primer, mais de vérifier que **l’app et son environnement** démarrent sans crash.  
   - On évite de laisser les imports CSS internes d’`@primer/react` faire échouer Vitest.

3. **Réutiliser `frontend-runtime-sanity`**  
   - Garder la structure de test demandée par ce skill (Vitest + `test:smoke`),  
   - appliquer sa section “UI libraries that import CSS”, spécialisée ici pour Primer.

---

## Pattern A – Smoke test indépendant de Primer (recommandé)

1. **Smoke test minimal**  
   - Créer un fichier de test (par ex. `src/App.test.tsx`) qui :
     - n’importe **pas** directement `@primer/react`,  
     - peut utiliser un composant factice (mock d’app) pour vérifier que Vitest + JSDOM + Testing Library sont bien câblés.

   Exemple :
   ```ts
   import { render } from '@testing-library/react'
   import { describe, it } from 'vitest'

   const MockApp = () => <div>test-seed</div>

   describe('smoke', () => {
     it('test runner is configured', () => {
       render(<MockApp />)
     })
   })
   ```

2. **Runtime réel**  
   - L’app réelle (entrypoint, features, theming, MSW) continue d’utiliser Primer librement.  
   - Le build Vite (`npm run build`) reste la validation forte que l’ensemble compile (y compris Primer).

3. **Quand appliquer ce pattern**  
   - Dès qu’un import CSS de Primer (`dist/*.css`) provoque des erreurs du type `Unknown file extension ".css"` dans Vitest,  
   - ou quand un mock complet d’`@primer/react` serait trop fragile à maintenir.

---

## Pattern B – Mock ciblé de Primer dans Vitest (option avancée)

Si l’on souhaite que le smoke test monte le vrai `App` qui utilise Primer, appliquer :

1. Dans `src/test/setup.ts` :  
   - **Mocker `@primer/react`** avec `vi.mock('@primer/react', () => ({ ... }))` pour les composants utilisés par le smoke test (Button, TextInput, etc.),  
   - retourner des wrappers HTML simples qui n’importent aucun CSS Primer.

2. Règles essentielles :
   - La factory de `vi.mock` doit être **synchrone** (pas d’`async` ni d’import dynamique),  
   - elle doit retourner seulement les exports nécessaires au code testé,  
   - elle ne doit pas ré-importer le module réel (sinon les CSS Primer reviennent dans le pipeline).

3. Ce pattern est plus puissant mais aussi plus fragile, à réserver aux cas où Pattern A ne suffit pas.

---

## Process dans ce template

1. **Suivre `frontend-runtime-sanity`**  
   - Installer Vitest + Testing Library,  
   - configurer `vite.config.ts` (`test.environment = 'jsdom'`, `globals = true`, `setupFiles`),  
   - ajouter les scripts `test` et `test:smoke`.

2. **Choisir le pattern de smoke test**  
   - Par défaut : Pattern A (smoke test indépendant de Primer).  
   - Pattern B uniquement si une User Story demande explicitement un smoke sur le vrai `App` Primer.

3. **Toujours exécuter** :
   - `cd frontend && npm run build`  
   - `cd frontend && npm run test:smoke`  
   après les changements significatifs, comme exigé par `AGENTS.md` et `frontend-runtime-sanity`.

---

## Rules

- Ne pas multiplier les hacks dans la config Vite/Vitest : les adaptations Primer doivent vivre dans ce skill et/ou `src/test/setup.ts`.  
- Ne pas bloquer une itération parce qu’un design system importe du CSS : adapter le smoke test (Pattern A) ou mocker Primer (Pattern B).  
- Utiliser conjointement :
  - `bas/primer-design` pour la conception UI,  
  - `bagustris/primer-style` pour le polish,  
  - `primer-vitest-runtime` pour garder les tests runtime simples et robustes.

