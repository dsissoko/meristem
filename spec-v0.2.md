# Meristem v0.2 — Spécification générale

## Table des matières

1. [Vision](#vision)
2. [Principes fondateurs](#principes-fondateurs)
3. [Architecture des fichiers](#architecture-des-fichiers)
4. [Concepts](#concepts)
   - 4.1 [Rôles disponibles](#rôles-disponibles)
   - 4.2 [Chargement des skills](#chargement-des-skills)
   - 4.3 [Modes d'exécution](#modes-dexécution)
5. [Référence fichiers](#référence-fichiers)
   - 5.1 [AGENTS.md](#agentsmd--porte-dentrée-universelle)
   - 5.2 [agents/config.yml](#agentsconfigyml)
   - 5.3 [agents/role/profile.md](#agentsroleprofilemd)
   - 5.4 [skills/skills-set.md](#skillsskills-setmd)
6. [Pipeline CI](#pipeline-ci)
   - 6.1 [Workflows v0.2](#workflows-v02)
   - 6.2 [agent-dispatch.yml — flux détaillé](#agent-dispatchyml--flux-détaillé)
   - 6.3 [Runners — architecture interchangeable](#runners--architecture-interchangeable)
   - 6.4 [run-agent-anomalyco.yml](#run-agent-anomalycoyml)
   - 6.5 [run-agent-generic-cli.yml](#run-agent-generic-cliyml)
   - 6.6 [init-project.yml](#init-projectyml)
7. [Bonnes pratiques](#bonnes-pratiques)
   - 7.1 [Pattern manifest](#pattern-manifest--production-agentique--exécution-déterministe)
   - 7.2 [Réponse inline sur PR](#réponse-inline-sur-pr)
8. [Features](#features)
   - 8.1 [Initialisation de projet GitHub](#initialisation-de-projet-github)
9. [Annexes](#annexes)
    - A. [Démarrer avec Meristem](#a-démarrer-avec-meristem)
    - B. [Plan de test](#b-plan-de-test)
    - C. [Points ouverts / Dette technique](#c-points-ouverts--dette-technique)
    - D. [Gestion du comportement agentique](#d-gestion-du-comportement-agentique)

---

## Vision

Meristem v0.2 est une architecture multi-agents distribuée pilotée par GitHub Actions. Chaque agent connaît son rôle, ses skills, et à qui passer la balle. Le process émerge des interactions entre agents — il n'est plus imposé par un fichier central.

`AGENTS.md` est le panneau d'entrée. Le process émerge au grès des interactions entre agents.

---

## Principes fondateurs

1. **Agents spécialisés** — chaque agent a un profil, des sets de skills, et des règles de routing
2. **Contexte minimal et ciblé** — issue courante + fichiers ciblés, jamais "tout le repo"
3. **Agnosticisme runtime** — la logique vit dans les fichiers du repo, pas dans les workflows
4. **Deux modes d'exécution** — classique (humain orchestre) ou autonome (agents s'auto-invoquent)
5. **Déterminisme maximal** — tout ce qui peut être fait en bash déterministe ne doit pas être agentique

---

## Architecture des fichiers

```
repo/
├── AGENTS.md                         # Porte d'entrée universelle (mode interactif)
├── business.md                       # Référence produit
├── architecture.md                   # Référence technique
├── agents/
│   ├── config.yml                    # Liste des rôles et aliases — lu par le dispatcher
│   ├── agent/profile.md              # Profil généraliste
│   ├── dev/profile.md
│   ├── qa/profile.md
│   ├── po/profile.md
│   └── architect/profile.md
├── skills/
│   ├── skills-set.md                 # Sets de skills par rôle — géré par l'humain
│   └── <source>/<skill>/SKILL.md    # Bibliothèque de skills
└── .github/workflows/
    ├── agent-dispatch.yml            # Filter, loop-guard, prepare-context, resolve-runner, dispatch
    ├── run-agent-anomalyco.yml       # Runner action native anomalyco/opencode/github@latest
    ├── run-agent-generic-cli.yml     # Runner CLI opencode générique (MOCK_EVENT)
    └── init-project.yml             # Initialisation projet (workflow_dispatch)
```

---

## Concepts

### Routing et handoff — définitions

Ces deux termes désignent des mécanismes distincts de collaboration entre agents.

**Routing** — tous modes (classique et autonome)

Le routing est le mécanisme par lequel un agent renvoie une requête vers un spécialiste
quand elle dépasse son périmètre. C'est un mécanisme **passif** : l'agent constate qu'il
n'est pas le bon interlocuteur et suggère ou invoque l'agent adapté.
Le routing est défini dans la section `## Routing` de chaque profil.

**Handoff** — mode autonome uniquement (`autonomous_mode: true`)

Le handoff est l'invocation **active** de l'agent suivant après qu'un agent a terminé sa
tâche. L'agent ne délègue pas parce qu'il ne peut pas traiter — il passe la balle parce
qu'il a fini et que la chaîne doit continuer.
Le handoff est porté par le skill `agent-handoff` (set `autonomous`) et défini dans la
section `## Autonomous mode` de chaque profil.

| | Routing | Handoff |
|---|---|---|
| Mode | Classique et autonome | Autonome uniquement |
| Déclencheur | Requête hors périmètre | Tâche terminée |
| Nature | Passif — délégation | Actif — passage de relais |
| Porté par | `## Routing` du profil | Skill `agent-handoff` + `## Autonomous mode` |

---

### Rôles disponibles

Mécanisme évolutif : ajouter `agents/<role>/profile.md` + une entrée dans `agents/config.yml` suffit.

**Rôles Meristem par défaut :**

| Pattern | Profil | Rôle |
|---|---|---|
| `/agent` | `agents/agent/profile.md` | Généraliste |
| `/dev` | `agents/dev/profile.md` | Implémentation |
| `/qa` | `agents/qa/profile.md` | Tests, qualité, review |
| `/po` | `agents/po/profile.md` | Produit, specs, Scrum |
| `/analyst` | `agents/analyst/profile.md` | Analyse métier, modélisation du domaine, flux de processus |
| `/architect` | `agents/architect/profile.md` | Architecture |
| `/help` | `agents/help/profile.md` | FAQ, onboarding, questions sur le framework |

**Aliases projet (fournis par défaut) :**

Les patterns `/my-dev`, `/my-qa`, `/my-po`, `/my-archi` sont des **aliases** vers les rôles de base (`dev`, `qa`, `po`, `architect`). Ils sont déclarés dans `agents/config.yml#aliases` — aucun profil dédié n'est nécessaire.

Pour créer un rôle projet **vraiment distinct** (profil et comportement différents) : créer `agents/<role>/profile.md` + ajouter l'entrée dans `roles:` de `agents/config.yml`.

---

### Chargement des skills

#### Contexte GitHub Actions

```
prompt → agents/{role}/profile.md → skills/skills-set.md#{set} → SKILL.md
```

#### Contexte interactif (OpenCode, Claude Code, Gemini CLI, Codex CLI)

Chaque runtime a son répertoire bootstrap avec un `meristem-skills-index/SKILL.md` identique :

| Runtime | Répertoire |
|---|---|
| OpenCode | `.opencode/skills/meristem-skills-index/` |
| Claude Code | `.claude/skills/meristem-skills-index/` |
| Gemini CLI | `.gemini/skills/meristem-skills-index/` |
| Codex CLI | `.agents/skills/meristem-skills-index/` |

**Séquence :**
1. Lire `skills/skills-set.md` et charger chaque `SKILL.md` du set `core`
2. Sur invocation `/role` → lire `agents/{role}/profile.md`
3. Charger chaque `SKILL.md` des sets déclarés dans `## Skill loading` du profil

#### OpenHands

Point d'entrée : `.openhands/microagents/repo.md` — maintenu manuellement en cohérence avec `AGENTS.md`. `config.toml` conservé (`max_iterations`, agent par défaut).

---

### Modes d'exécution

#### Mode classique (défaut)

```
/dev ajoute un footer de bienvenue
```
L'humain invoque un agent. L'agent agit et poste son résultat. L'humain invoque le prochain agent.

#### Mode autonome

```
/dev ajoute un footer de bienvenue
```
Même invocation qu'en mode classique. Le mode est défini globalement dans `agents/config.yml` :

```yaml
autonomous_mode: true
```

Quand activé, chaque agent — après sa tâche — invoque le prochain agent selon les règles de routing définies dans son profil. L'humain n'intervient que sur les sorties de route.

**Sorties de route — l'agent s'arrête et attend :**
- Décision produit nécessitant modification de `business.md`
- Merge vers `main`
- Échec de build ou tests après 2 tentatives
- Détection de boucle (loop-guard)

---

## Référence fichiers

### `AGENTS.md` — porte d'entrée universelle

Lu automatiquement par tous les runtimes (OpenCode, Claude Code, Gemini CLI, Codex CLI).

**Contenu (~80 lignes) :**
- Description du repo
- Liste des agents disponibles et leurs patterns d'invocation
- Séquence de démarrage :
  1. Lire `skills/skills-set.md` et charger chaque `SKILL.md` du set `core`
  2. Sur invocation `/role` → lire `agents/{role}/profile.md`
  3. Charger chaque `SKILL.md` des sets déclarés dans `## Skill loading` du profil
- Règles transversales (routing, langue, échappement `/role`, validation humaine...)

---

### `agents/config.yml`

Lu dynamiquement en bash par le job `filter`. Aucune logique de routing hardcodée dans les workflows.

```yaml
# Aliases : mappent un pattern vers un rôle existant
# Ex : /my-dev déclenche le rôle dev
aliases:
  my-dev: dev
  my-qa: qa
  my-po: po
  my-archi: architect

# Rôles Meristem — chaque rôle doit avoir un agents/<role>/profile.md
roles:
  - agent
  - dev
  - qa
  - po
  - analyst
  - architect
  - help

autonomous_mode: false  # true → les bots sont autorisés à déclencher des runs

runner_mode: anomalyco  # anomalyco | generic-cli

# Paramètres dispatcher
max_comments: 10              # Nombre max de commentaires injectés dans le prompt
loop_max_invocations: 3       # Nb max d'invocations consécutives avant loop-guard
loop_diff_threshold: 20       # % minimum de nouveau contenu pour ne pas déclencher loop-guard

# Configuration OpenCode — convertie en opencode.json au moment du run
agent_config:
  opencode:
    $schema: "https://opencode.ai/config.json"
    model: "opencode/<model-name>"
    small_model: "opencode/<model-name>"
    share: "disabled"
    autoupdate: false
    disabled_providers:
      - openai
      - gemini
      - anthropic
```

---

### `agents/<role>/profile.md`

Chargé par l'agent sur instruction du prompt injecté par le workflow.

**Structure type (`agents/dev/profile.md`) :**

```markdown
# Agent Dev — Implementation

## Identity
I am the developer agent. I read, I implement, I test.
I never implement without a validated plan.

## Responsibilities
- Analyze the request and produce a plan before any implementation
- Load the skill sets for this role
- Read `business.md` and `architecture.md` before implementing
- Implement according to loaded skills
- Validate before pushing — see "Code validation" below
- Post a result comment on the issue

## What I don't do
- I don't make product decisions (→ `/po`)
- I don't validate specs (→ `/architect`)

## Autonomous mode
If mode=auto, the `agent-handoff` skill is loaded.
After pushing a PR → invoke `/qa` from the PR thread.

## Skill loading
Read `skills/skills-set.md` and load the SKILL.md files from sets: core, dev, technical

## Code validation
Before any commit/push:
1. Existing unit tests pass (non-regression)
2. New tests compile and pass
3. Modified source code compiles without error
4. E2E smoke test passes

If any condition fails → fix before pushing. Never push broken code.
```

**Règles de structure d'un profil :**
- Sections obligatoires dans cet ordre : `## Identity`, `## Responsibilities`, `## What I don't do`, `## Key processes`, `## Routing`, `## Autonomous mode`, `## Skill loading`
- Section additionnelle : `## Merge authorization` — uniquement pour les agents autorisés à merger (`/agent`, `/qa`, `/po`)
- `## Skill loading` déclare uniquement des **sets** — jamais des skills individuels
  - ✅ `Read skills/skills-set.md and load the SKILL.md files from sets: core, dev`
  - ❌ `Load skills/local/epic-breakdown-advisor/SKILL.md`
- Les sections de process (`## Key processes`) peuvent nommer des skills individuels à titre indicatif, uniquement accompagnés de leur set d'appartenance (ex: `apply the domain-analysis skill from the analyst set`)
- Les patterns `/role` dans les profils doivent toujours être en prose ou backtickés — jamais bruts

---

### `skills/skills-set.md`

Fichier unique géré par l'humain. Source de vérité pour tous les sets de skills.
Un set = une liste de chemins vers des SKILL.md. Le profil agent déclare les sets qu'il charge.

**Contenu à jour : [`skills/skills-set.md`](skills/skills-set.md)**

**Règles :**
- Géré manuellement par l'humain
- Ajouter un rôle = ajouter un set + un profil + une entrée dans `agents/config.yml`
- Le set `core` est chargé par tous les agents sans exception — il contient : `github-issue-context`, `github-pr-context`, `init-product-knowledge`, `discover-skills`, `agent-response-format`, `pr-workflow`
- Le set `autonomous` est ajouté automatiquement par le dispatcher quand `autonomous_mode: true`
- Un profil déclare des **sets**, pas des skills individuels — la section `## Skill loading` référence uniquement des sets de `skills-set.md`
- Créer un nouveau set = ajouter une section `## Set: <name>` dans `skills/skills-set.md` avec un champ `description:` et une liste de chemins `skills/<source>/<skill-name>`

---

## Pipeline CI

### Workflows v0.2

**Principe :** agnostiques du domaine et des profils agents. L'intelligence est dans les fichiers du repo.

| Workflow | Rôle | Trigger |
|---|---|---|
| `agent-dispatch.yml` | Filter → loop-guard → prepare-context → resolve-runner → dispatch | `issue_comment` created, `pull_request_review_comment` created |
| `run-agent-anomalyco.yml` | Runner action native `anomalyco/opencode/github@latest` | `workflow_call` |
| `run-agent-generic-cli.yml` | Runner CLI opencode via MOCK_EVENT | `workflow_call` |
| `init-project.yml` | Vérifie la structure `agents/`, `business.md`/`architecture.md` | `workflow_dispatch` |
| `deploy-pages.yml` | Déploiement frontend + docs | `push main` |
| `pr-preview.yml` | Preview PR | `pull_request` |

**Événements `edited` :** ne déclenchent pas l'agent. Sur `edited` contenant un pattern d'invocation, le dispatcher poste un commentaire warning ("⚠️ l'édition ne peut pas redéclencher le process, veuillez créer un nouveau commentaire") et stoppe.

---

### `agent-dispatch.yml` — flux détaillé

#### Job `filter`

**Condition de déclenchement (évaluée sans runner) :**
Le commentaire contient au moins un pattern présent dans `agents/config.yml#roles` ou `#aliases`.

**Steps :**
1. Lire `agents/config.yml` en bash — extraire `roles`, `aliases` et `autonomous_mode`
2. Sur `edited` avec pattern d'invocation → poster warning, stoppe
3. Détecter le pattern dans le corps du commentaire
4. Résoudre les aliases (`moncds` → `agent`)
5. Si pattern inconnu → poster commentaire d'erreur listant les patterns valides, stoppe
6. Si `autonomous_mode: true` dans `agents/config.yml` → output `mode=auto`, sinon `mode=classic`

**Outputs :** `agent`, `mode`

Le prompt construit par `prepare-context` inclut `mode` et liste les sets à charger — le set `autonomous` est ajouté si `mode=auto`.

---

#### Job `loop-guard`

Détecte les boucles stériles — invocations répétitives sans progression.

**Algorithme :**
1. Récupérer les `LOOP_MAX_INVOCATIONS` derniers commentaires contenant un pattern d'invocation sur l'issue/PR (`gh api repos/{repo}/issues/{number}/comments` ou `/pulls/{number}/comments`)
2. Si moins de `LOOP_MAX_INVOCATIONS` invocations → safe
3. Extraire le texte après le pattern d'invocation pour les deux dernières invocations
4. Calculer le ratio de nouveau contenu : `nouveaux_chars / longueur_actuelle * 100`
5. Si ratio < `LOOP_DIFF_THRESHOLD` → loop détectée → poster alerte, output `safe=false`
6. Sinon → output `safe=true`

**Message d'alerte :**
> ⚠️ Agent loop detected — les N dernières invocations sont redondantes (moins de X% de nouveau contenu). Un humain doit reprendre la conversation.

**Output :** `safe`

---

#### Job `prepare-context`

Construit le prompt texte brut et l'uploade en artifact éphémère.

**Sur `issue_comment` — APIs appelées :**
- `GET /repos/{repo}/issues/{number}` → titre, état, auteur, labels, body
- `GET /repos/{repo}/issues/{number}/comments` → historique (max `MAX_COMMENTS`, hors commentaire déclencheur, triés chronologiquement)

**Sur `pull_request_review_comment` — APIs appelées :**
- `GET /repos/{repo}/pulls/{number}` → titre, état, branches, body
- `GET /repos/{repo}/pulls/{number}/comments` → historique inline (max `MAX_COMMENTS`)
- `GET /repos/{repo}/pulls/comments/{comment_id}` → `diff_hunk`, `path`, `line`, `commit_id`

**Prompt généré sur `issue_comment` :**
```
Tu es l'agent {role}.
Charge agents/{role}/profile.md et suis ses instructions.
Mode : {classic|auto}

## Instruction active
Auteur : {author}
Date   : {created_at}
{body}

## Métadonnées
{titre, état, labels, body de l'issue}

## Historique ({N} derniers commentaires)
{liste chronologique : auteur, date, body}
```

**Prompt généré sur `pull_request_review_comment` :**
```
Tu es l'agent {role}.
Charge agents/{role}/profile.md et suis ses instructions.
Mode : {classic|auto}

## Instruction active
Auteur : {author}
Date   : {created_at}
{body}

## Contexte code
Fichier     : {path}
Ligne       : {line}
Diff        :
{diff_hunk}
reply_to_id : {comment_id}

## Métadonnées PR
{titre, état, branches, body}

## Historique ({N} derniers commentaires inline)
{liste chronologique : auteur, date, fichier, ligne, body}
```

**Upload :** artifact éphémère `prompt-{run_id}.txt`, retention 1 jour.

**Contrainte de taille :** prompt borné à 1 Mo (limite variable d'environnement GitHub Actions). En pratique : 20-50 Ko.

**Output :** `run_id`

---

#### Job `resolve-runner`

Lit `runner_mode` depuis `agents/config.yml` et l'expose en output pour les jobs dispatch.

```bash
echo "runner_mode=$(grep '^runner_mode:' agents/config.yml | awk '{print $2}')" >> "$GITHUB_OUTPUT"
```

**Output :** `runner_mode` (`anomalyco` | `generic-cli`)

---

#### Job `dispatch-anomalyco`

Appelle `run-agent-anomalyco.yml` via `workflow_call` si `runner_mode == anomalyco`.

**Inputs passés :** `role`, `run_id`, `issue_number`, `comment_id`, `mode`

---

#### Job `dispatch-generic-cli`

Appelle `run-agent-generic-cli.yml` via `workflow_call` si `runner_mode == generic-cli`.

**Inputs passés :** `role`, `run_id`, `issue_number`, `comment_id`, `mode`

---

### Runners — architecture interchangeable

Les runners sont des **implémentations alternatives** d'un même contrat :
- Mêmes inputs (`workflow_call`)
- Même step `Handle manifest artifact`
- Même source de config opencode (`agents/config.yml` → `agent_config.opencode`)

Le runner actif est contrôlé par une seule clé dans `agents/config.yml` :

```yaml
runner_mode: anomalyco  # anomalyco | generic-cli
```

**Pour ajouter un troisième runner :**
1. Créer `run-agent-<name>.yml` respectant le même contrat
2. Ajouter un job `dispatch-<name>` dans `agent-dispatch.yml` avec la condition `needs.resolve-runner.outputs.runner_mode == '<name>'`
3. Ajouter la valeur dans le commentaire de `runner_mode` dans `agents/config.yml`

---

### `run-agent-anomalyco.yml`

Utilise l'action officielle `anomalyco/opencode/github@latest`.

**Steps :**
1. Checkout repo
2. `actions/download-artifact@v4` — télécharge `prompt-{run_id}.txt`
3. Lire le contenu dans `GITHUB_ENV`
4. Générer `.opencode/opencode.json` depuis `agents/config.yml` via `yq`
5. Invoquer `anomalyco/opencode/github@latest` avec `model` lu depuis `agents/config.yml`
6. Cleanup `opencode.json`
7. Step `Handle manifest` — exécute le manifest si présent

**Avantages :** gère le token GitHub, la config git et le contexte issue/PR nativement.

---

### `run-agent-generic-cli.yml`

Utilise la CLI opencode (`opencode github run`) avec un MOCK_EVENT construit en bash.

**Steps :**
1. Checkout repo
2. `actions/download-artifact@v4` — télécharge `prompt-{run_id}.txt`
3. Lire le contenu dans `GITHUB_ENV` + `$RUNNER_TEMP/prompt.txt`
4. Install CLI opencode + PATH
5. Configure git identity (`opencode-agent` / `opencode-agent@users.noreply.github.com`)
6. Générer `.opencode/opencode.json` depuis `agents/config.yml` via `yq`
7. Construire `MOCK_EVENT` (jq) avec `owner`, `repo`, `issue_number`, `comment_id`, `actor`, `body=/oc {prompt}`
8. Invoquer `opencode github run --event "$MOCK_EVENT" --token "$MOCK_TOKEN"`
9. Cleanup `opencode.json`
10. Step `Handle manifest` — exécute le manifest si présent

**Variables d'env requises :** `OPENCODE_API_KEY`, `GITHUB_TOKEN`, `USE_GITHUB_TOKEN=true`, `MODEL` (lu depuis `agents/config.yml`), `SHARE=false`

**Contrainte :** nécessite que le `comment.body` du MOCK_EVENT commence par `/oc` pour que l'action CLI extraie le prompt.

---

### `init-project.yml`

Déclenché manuellement (`workflow_dispatch`). Point d'entrée officiel avant le premier run agent.

**Steps :**
1. Vérifier que `business.md` et `architecture.md` existent et ne sont pas vides — stoppe avec erreur sinon
2. Vérifier la structure `agents/` et les profils
3. Vérifier que `skills/skills-set.md` existe — warning sinon

---

## Bonnes pratiques

### Pattern manifest — production agentique + exécution déterministe

**Problème adressé :** certaines actions nécessitent des décisions complexes (analyser un backlog, proposer une structure de projet) suivies d'une exécution fiable de nombreux appels API. Laisser l'agent tout exécuter lui-même est risqué — une erreur en milieu de séquence laisse le projet dans un état partiel.

**Pattern :**
1. L'agent produit un fichier JSON structuré (le manifest) décrivant les actions à exécuter
2. L'humain valide le manifest (via le dialogue dans l'issue)
3. Un step bash post-run exécute les appels API de façon déterministe

**Mécanisme de transmission — fichier local dans le workspace :**
- L'agent écrit le manifest directement dans le workspace du runner :
  ```bash
  echo '{...}' > manifest-${RUN_ID}.json
  ```
- Le step post-run du **même job** lit le fichier localement — pas d'artifact, pas de download
- Isolation garantie entre runs parallèles via `run_id` dans le nom du fichier
- Séquentialité garantie par l'ordre des steps dans le job (`if: always()`)

**Ce qu'on n'utilise pas :**
- Manifest embarqué dans un commentaire HTML parsé par `sed` — fragile, cassant sur tout reformatage
- Commit du manifest dans le repo — les fichiers temporaires ne doivent pas polluer l'historique git
- `actions/upload-artifact` / `actions/download-artifact` — inutile ici car les steps sont dans le même job (contrairement au prompt `prompt-{run_id}.txt` qui lui transite entre jobs via artifact)

**Schéma :**
```
Runner actif (run-agent-anomalyco.yml ou run-agent-generic-cli.yml)
  → dialogue avec l'humain via commentaires issue
  → produit manifest-{run_id}.json dans le workspace

Step post-run (même job, if: always())
  → lit manifest-{run_id}.json depuis le filesystem local
  → si manifest présent : exécute les appels gh api / GraphQL
  → poste un commentaire de résultat sur l'issue
```

---

### Réponse inline sur PR

Quand l'agent est déclenché par un `pull_request_review_comment`, il doit répondre dans le fil inline — pas dans le fil général de la PR.

Le skill `skills/local/github-pr-context/SKILL.md` porte cette instruction. L'agent exécute via son outil bash :

```bash
gh api repos/{repo}/pulls/{number}/comments \
  --method POST \
  --field body="SA RÉPONSE" \
  --field in_reply_to={reply_to_id}
```

`reply_to_id` est injecté dans le prompt par `prepare-context`. Le champ `in_reply_to` attache automatiquement la réponse au bon fil de ligne — pas besoin de spécifier `path`, `line` ou `commit_id`.

---

## Features

### Initialisation de projet GitHub

**Objectif :** créer un projet GitHub v2 avec un backlog complet (epics, user stories, labels, board) depuis le contenu de `business.md` et `docs/specs/`.

**Invocation :** language naturel via `/po` — ex : `/po initialise le projet GitHub`

L'agent `/po` charge le skill `scrum-project-init` qui porte le process complet en 5 gates :
- Gate 1 — Vérification des prérequis (`business.md`, `architecture.md`)
- Gate 2 — Inventaire des specs existantes + gap analysis
- Gate 3 — Dialogue de configuration du board (nom, colonnes, champs)
- Gate 4 — Plan A/B : backlog complet + ordre de mise en place, validation humaine
- Gate 5 — Production du manifest JSON

**Implémentation via le pattern manifest :**

Gate 5 écrit `manifest-{run_id}.json` dans le workspace. Le step post-run du runner actif lit le manifest et exécute :
- Création des labels (`epic`, `user-story`, `task`, `todo`)
- Création des issues epics (body depuis `docs/specs/` si disponible, sinon minimal)
- Création des issues user stories (mode A uniquement)
- Création du projet GitHub v2 via GraphQL
- Ajout des issues au board avec champs `Status` et `Epic`
- Post d'un commentaire de résumé sur l'issue

**Format du manifest :**
```json
{
  "version": "1",
  "type": "scrum-init",
  "issue_number": 42,
  "project_name": "Mon Projet",
  "mode": "A",
  "epics": [
    {
      "title": "[TECH-01] Initialisation stack",
      "is_gap": true,
      "user_stories": [
        { "title": "[TECH-01-US-01] Configurer Vite", "is_gap": true }
      ]
    }
  ],
  "planning": [
    {
      "order": 1,
      "epic_title": "[TECH-01] Initialisation stack",
      "type": "technical",
      "rationale": "Débloque toutes les autres epics",
      "depends_on": []
    }
  ]
}
```

Le champ `type` permet au step post-run d'identifier le bon handler bash à exécuter — extensible à d'autres types de manifest.

---

## Annexes

### A. Démarrer avec Meristem

#### Fichiers à configurer

Ces fichiers doivent exister et être valides pour que Meristem fonctionne.

| Fichier | Contenu | Géré par |
|---|---|---|
| `business.md` | Vision produit, périmètre, roadmap | Agents `/po` et `/analyst` |
| `architecture.md` | Stack technique, patterns, outils | Agent `/architect` |
| `agents/config.yml` | Rôles actifs, aliases, paramètres dispatcher, autonomous_mode | Humain |
| `agents/<role>/profile.md` | Identité, responsabilités, sets de skills, règles de routing | Humain |
| `skills/skills-set.md` | Sets de skills par rôle | Humain |
| `skills/<source>/<skill>/SKILL.md` | Contenu de chaque skill | Humain / externe |

**Secrets GitHub à configurer (Settings → Secrets → Actions) :**

| Secret | Requis pour | Scope token |
|---|---|---|
| `OPENCODE_API_KEY` | Invocation OpenCode | — |
| `GITHUB_TOKEN` | Commentaires, PR, issues | Fourni automatiquement par GitHub Actions |
| `SCRUM_PROJECT_TOKEN` | Création projet GitHub v2 via GraphQL | `repo` + `project` |

---

#### Cas 1 — Nouveau projet

1. **Générer le contenu métier et technique**
   - Invoquer `/analyst` ou `/po` sur une issue dédiée pour générer `business.md`
   - Invoquer `/architect` pour générer `architecture.md`
   - Valider les deux fichiers avant de continuer

2. **Bootstrapper le repo Meristem**
   - Lancer `init-project.yml` (workflow_dispatch) — crée `log.md`, vérifie la structure

3. **Initialiser le backlog** *(optionnel)*
   - Invoquer `/po initialise le projet GitHub` — crée le projet GitHub v2, les epics, les user stories, le board

---

#### Cas 2 — Reprise d'un projet existant

1. **Vérifier les fichiers minimum**
   - S'assurer que `business.md` et `architecture.md` sont complets et à jour
   - Si incomplets → invoquer `/analyst` ou `/po` pour les enrichir

2. **Bootstrapper le repo Meristem**
   - Lancer `init-project.yml` — crée `log.md` si absent, vérifie la structure

3. **Vérifier la cohérence des skills**
   - Invoquer `/architect update-skills` pour s'assurer que `skills/skills-set.md` correspond bien au stack décrit dans `architecture.md`

---

### B. Plan de test

#### Tests unitaires

Testent un composant isolé du pipeline sans déclencher de run agent complet.

---

##### T0 — Pipeline mécanique — invocation OpenCode via `PROMPT` env

**Objectif :** valider que le mécanisme de passage du prompt depuis un artifact vers `opencode github run` fonctionne en conditions réelles.

**Points de risque à surveiller :**
- Caractères spéciaux dans le corps des commentaires (backticks, `$(...)`) — le `printf` dans `prepare-context` doit les gérer sans interprétation bash
- Taille du prompt proche de la limite 1 Mo
- Comportement si `PROMPT_CONTENT` est vide ou tronqué

**Test :** poster un commentaire `/agent bonjour` sur une issue. Vérifier que le prompt est bien construit, uploadé, téléchargé et passé à OpenCode sans erreur. Inspecter les logs GitHub Actions à chaque step.

---

##### T3 — `edited` → warning

Poster puis éditer un commentaire contenant `/dev`.

**Attendu :** job `warn-on-edited` déclenché, commentaire warning posté ("L'édition d'un commentaire ne peut pas redéclencher le process"), aucun run agent déclenché.

---

##### T5 — Loop-guard

Poster le même commentaire `/dev` plusieurs fois consécutivement sur la même issue sans modifier le texte.

**Attendu :** après `loop_max_invocations` fois, le job `loop-guard` poste une alerte et output `safe=false`. Le pipeline stoppe, aucun run agent déclenché.

---

#### Tests de fonctionnement

Testent le pipeline complet end-to-end avec un vrai run agent.

---

##### T1 — issue_comment created — question info

Poster `/agent quelle est l'architecture technique du projet ?` sur une issue.

**Attendu :** réponse directe en commentaire, pas de plan, pas de PR.

---

##### T2 — issue_comment created — demande de code

Poster `/dev ajoute un message de bienvenue dans le footer` sur une issue.

**Attendu :** plan proposé avec choix A/B avant toute implémentation.

---

##### T4 — pull_request_review_comment — réponse inline

Poster `/qa` en commentaire inline sur une ligne de code dans une PR.

**Attendu :** réponse postée inline dans le même fil, pas dans le fil général de la PR.

---

### C. Points ouverts / Dette technique

#### `scripts/run-agent-tests.sh` — mise à jour v0.2

Prérequis avant toute campagne de tests automatisés.

**Ce qui doit changer :**
1. Lecture du modèle — lire depuis `agents/config.yml` (`agent_config.opencode.model`) via `yq`
2. Patterns d'invocation — remplacer `/moncds` par les patterns v0.2 (`/agent`, `/dev`, `/qa`, etc.)
3. T3 — vérifier la présence du commentaire warning au lieu de vérifier l'absence de réponse
4. T4 — vérifier que l'agent ne se déclenche PAS (comportement inverse de v0.1)
5. CLI interactif — hors scope v0.2, à exclure du script

---

#### Audit qualité workflows — fragilités identifiées

Résultat d'un audit statique des workflows.

**Fragilités silencieuses :**

| # | Fichier | Problème |
|---|---|---|
| 1 | `agent-dispatch.yml` | `gh api` sans `--paginate` — loop-guard incomplet sur >100 commentaires |
| 2 | `agent-dispatch.yml` | `tr -d '"'` supprime silencieusement les guillemets du contenu |
| 3 | `run-agent-anomalyco.yml` / `run-agent-generic-cli.yml` | Aucun `timeout-minutes` — agent bloqué consomme jusqu'à 6h de CI |

**Anti-patterns :**

| # | Fichier | Problème |
|---|---|---|
| 4 | `agent-dispatch.yml` | `${{ github.run_id }}` dans `run:` — doit passer par `env:` |
| 5 | `agent-dispatch.yml` | Parsing YAML avec grep/awk/sed — fragile si le format évolue |
| 6 | `run-agent-generic-cli.yml` | `curl pipe bash` sans vérification d'intégrité — supply chain risk |

**Incohérences :**

| # | Fichier | Problème |
|---|---|---|
| 7 | `init-project.yml` | WARNING vs ERROR inconsistant selon les fichiers vérifiés |
| 8 | `init-project.yml` | Liste de rôles codée en dur, duplique `agents/config.yml` |

---

#### Faux déclenchements sur réponses agent — partiellement sous contrôle

Un commentaire posté par un agent contenant un pattern `/role` dans son texte (ex: citation informative) peut déclencher un run parasite.

**État actuel :**
- Le crash du `filter` sur caractères spéciaux est corrigé (`printf + 2>/dev/null`)
- Une directive agentique dans `github-issue-context` et `github-pr-context` demande à l'agent d'échapper les patterns `/role` non intentionnels avant de poster (filtre python, rôles lus depuis `agents/config.yml`)
- Le loop-guard ne couvre pas ce cas — il détecte uniquement les invocations répétitives, pas les réponses

**Risque résiduel :** si l'agent ne suit pas la directive (oubli, reformulation libre), un faux déclenchement reste possible. Pas de garde-fou côté workflow.

---

#### `run-agent-generic-cli.yml` — enrichissement du sandbox avec MCP et outils agentiques

OpenCode supporte nativement les serveurs MCP via `opencode.json`. Le runner générique
pourrait provisionner ces outils (MCP GitHub, Context7, Playwright MCP, etc.) avant le
lancement du CLI, offrant à l'agent un environnement d'exécution enrichi sans modifier
son prompt ni son architecture.

**Statut :** À explorer

---

### D. Gestion du comportement agentique

#### Fichiers de comportement

Le comportement d'un agent émerge de la concaténation de plusieurs contextes assemblés au moment du run : le prompt injecté par le dispatcher (instruction active, métadonnées GitHub, historique), le profil du rôle invoqué, et les skills chargés par ce profil. Aucun workflow ne décrit le process — c'est cette composition de fichiers texte qui le fait émerger.

Les fichiers listés ci-dessous sont ceux qui portent exclusivement du comportement : identité, responsabilités, règles de dialogue, orchestration entre agents. Ils sont distincts des skills de capacité technique (stack, tests, design system, etc.).

**Porte d'entrée**

| Fichier | Rôle |
|---|---|
| `AGENTS.md` | Point d'entrée universel — séquence de boot, liste des agents disponibles |

**Profils agents**

| Fichier | Rôle |
|---|---|
| `agents/agent/profile.md` | Généraliste |
| `agents/dev/profile.md` | Implémentation |
| `agents/qa/profile.md` | Tests, qualité, review |
| `agents/po/profile.md` | Produit, specs, Scrum |
| `agents/analyst/profile.md` | Analyse métier, modélisation du domaine |
| `agents/architect/profile.md` | Architecture |
| `agents/help/profile.md` | FAQ, onboarding, framework |

**Skills de comportement**

| Fichier | Rôle |
|---|---|
| `skills/local/github-issue-context/SKILL.md` | Lecture du contexte issue, état du dialogue, quand agir |
| `skills/local/github-pr-context/SKILL.md` | Lecture du contexte PR, réponse inline obligatoire |
| `skills/local/agent-handoff/SKILL.md` | Invocation active de l'agent suivant — mode autonome uniquement, règles de merge |
| `skills/local/init-product-knowledge/SKILL.md` | Validation des prérequis communs à tous les agents |

---

#### Routing et handoffs entre agents

Voir les définitions en tête de `## Concepts` pour la distinction routing / handoff.

**Routing — tous modes**

| De ↓ \ Vers → | `/dev` | `/qa` | `/po` | `/analyst` | `/architect` | `/help` | Humain |
|---|---|---|---|---|---|---|---|
| Humain | Implémenter une feature | Revoir / tester une PR | Définir / prioriser | Analyser un domaine | Décider une architecture | Question framework | — |
| `/agent` | Implémentation technique | Tests / review | Décision produit | Analyse métier | Décision architecture | Questions framework | Validation `business.md` / `architecture.md` |
| `/dev` | — | Tests / review après impl | Décision produit requise | Ambiguïté métier en cours d'impl | Décision architecture requise | Questions framework | Boucle qa/dev > 2 cycles |
| `/qa` | Correction requise | — | Critères acceptance flous | — | Problème architecture détecté | Questions framework | Boucle qa/dev > 2 cycles sans résolution |
| `/po` | Impl spec validé | Qualité / tests | — | Clarification domaine | Question architecture | Questions framework | Validation `business.md` avant commit |
| `/analyst` | Impl spec validé | — | Structuration backlog | — | Implications architecture | Questions framework | Validation `business.md` avant commit |
| `/architect` | Impl décision validée | — | Implications produit | Clarification domaine | — | Questions framework | Validation `architecture.md` avant commit |
| `/help` | Implémentation | Tests / qualité | Produit / backlog | Analyse métier | Architecture | — | — |

---

**Handoffs autonomes — mode=auto uniquement**

| Agent | Condition | Cible | Fil |
|---|---|---|---|
| `/dev` | PR poussée | `/qa` | PR |
| `/dev` | Renvoyé par `/qa` > 2 fois sur la même PR | stop → humain | Issue |
| `/qa` | PR approuvée | `/po` | Issue |
| `/qa` | Corrections requises (≤ 2 cycles) | `/dev` | PR |
| `/qa` | Même PR renvoyée > 2 fois sans résolution | stop → humain | Issue |
| `/po` | PR mergée | `/dev` (priorité suivante) | Issue |
| `/po` | Clarification domaine nécessaire | `/analyst` | Issue |
| `/architect` | Décision validée débloque impl | `/dev` | Issue |
| `/analyst` | Gaps identifiés | `/po` | Issue |
| `/analyst` | Aucun gap | stop | — |
| `/help` | Toujours | stop | — |
