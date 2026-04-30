---
name: spec
type: knowledge
version: 1
agent: CodeActAgent
triggers:
  - spec
  - spécification
  - specification
  - user story
  - epic
  - feature
  - fonctionnel
  - functional
---

# Instructions — Phase de spécification

## Charger les skills de spec

Avant de produire quoi que ce soit, lire les skills suivants :

```bash
cat skills/skills-presets.md
cat skills/deanpeters/epic-breakdown-advisor/SKILL.md
cat skills/softaworks/c4-architecture/SKILL.md
cat skills/softaworks/mermaid-diagrams/SKILL.md
```

## Processus de spécification

Suivre le processus en deux temps : **dialogue d'abord, génération ensuite**.

### Étape 1 — Proposer l'arborescence en commentaire

Avant de créer le moindre fichier, poster un commentaire sur l'issue avec :
- L'arborescence proposée sous `docs/specs/` (2 niveaux maximum)
- Les hypothèses pour chaque nœud de l'arborescence
- Les sections marquées `[empty — à préciser]` si l'information est manquante
- Les questions à l'utilisateur pour compléter le contexte

**Attendre une confirmation explicite avant de générer les fichiers.**

### Étape 2 — Générer les fichiers après confirmation

Une fois l'arborescence validée :

**Côté fonctionnel** (`docs/specs/functional/`) :
- `epic-XX-<nom>/epic.md` — titre, problème, périmètre, critères de succès
- `epic-XX-<nom>/us-XX-<nom>.md` — titre, narrative, critères d'acceptance (Given/When/Then)
- Utiliser `epic-breakdown-advisor` pour le découpage des epics en user stories

**Côté architecture** (`docs/specs/architecture/`) :
- `software/c4-context.md` — système + acteurs externes
- `software/c4-containers.md` — applications, bases de données, services
- `infrastructure/c4-deployment.md` — infra, instances, réseau
- Utiliser `c4-architecture` et `mermaid-diagrams` pour les diagrammes Mermaid

## Règles

- Sections sans information → `[empty — à préciser]`, jamais de contenu inventé
- Diagrammes en syntaxe Mermaid C4 exclusivement
- Maximum 20 éléments par diagramme
- Maximum 2-4 epics pour une première itération
