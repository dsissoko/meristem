---
name: implement
type: knowledge
version: 1
agent: CodeActAgent
triggers:
  - implémente
  - implémenter
  - implementation
  - implémentation
  - code
  - développe
  - développer
  - bug
  - fix
  - corriger
  - feature
---

# Instructions — Phase d'implémentation

## Lire les fichiers de connaissance

Avant toute implémentation, lire dans cet ordre :

```bash
cat business.md
cat architecture.md
cat skills/skills.lock.md
```

Puis lire le `SKILL.md` de chaque skill listé dans `skills/skills.lock.md` :

```bash
# Pour chaque skill dans skills/skills.lock.md :
cat skills/<source>/<skill-name>/SKILL.md
```

Si des specs existent, les lire avant de coder :

```bash
ls docs/specs/
# Lire les specs pertinentes pour la tâche
```

## Conditions pour démarrer l'implémentation

Ne commencer à coder que si :
- `business.md` et `architecture.md` contiennent des informations concrètes
- Tous les skills lockés ont été lus
- Les specs existantes dans `docs/specs/` ont été lues
- Le plan a été posté en commentaire et validé par l'utilisateur

## Conventions techniques

Suivre strictement les patterns définis dans `AGENTS.md` Step 4 et dans les skills chargés :

- Architecture feature-based : `frontend/src/features/<feature>/ui/`, `hooks/`, `model/`, `api/`
- MSW handlers dans `frontend/src/mocks/handlers.ts`
- `worker.start()` appelé AVANT `ReactDOM.createRoot().render()` dans `main.tsx`
- Toujours utiliser `import.meta.env.BASE_URL` comme préfixe pour les URLs de fetch

## Validation post-implémentation

Après toute implémentation significative :

```bash
cd frontend && npm run build
```

Si des tests sont disponibles :

```bash
cd frontend && npm run test:smoke
```

Signaler tout échec explicitement en commentaire sur l'issue.
Ne pas déclarer la tâche terminée si le build échoue.
