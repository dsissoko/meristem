#!/usr/bin/env bash
# =============================================================================
# scrum-init-execute.sh
#
# Reads the scrum-init manifest from a JSON file and executes all GitHub API
# calls to bootstrap the project (labels, epics, user stories, board).
#
# Called by the manifest handler step in run-agent.yml after the agent run.
#
# Required env vars:
#   GH_TOKEN      — GitHub token with scopes: repo + project
#   REPO          — owner/repo (e.g. dsissoko/meristem-test)
#   ISSUE_NUMBER  — issue number that triggered the scrum init
#   MANIFEST_FILE — path to the manifest JSON file (default: manifest-{RUN_ID}.json)
# =============================================================================

set -euo pipefail

REPO="${REPO:-}"
ISSUE_NUMBER="${ISSUE_NUMBER:-}"
MANIFEST_FILE="${MANIFEST_FILE:-manifest-${GITHUB_RUN_ID:-0}.json}"

if [ -z "$REPO" ] || [ -z "$ISSUE_NUMBER" ]; then
  echo "ERROR: REPO and ISSUE_NUMBER must be set."
  exit 1
fi

echo "=== scrum-init-execute: start ==="
echo "Repo          : $REPO"
echo "Issue number  : $ISSUE_NUMBER"
echo "Manifest file : $MANIFEST_FILE"

# -----------------------------------------------------------------------------
# Step 1 — Read manifest from file
# -----------------------------------------------------------------------------
echo ""
echo "=== Step 1: Read manifest ==="

if [ ! -f "$MANIFEST_FILE" ]; then
  echo "ERROR: Manifest file not found: $MANIFEST_FILE"
  gh api "repos/$REPO/issues/$ISSUE_NUMBER/comments" \
    --method POST \
    --field body="❌ **scrum-init-execute**: Manifest file not found. Please retry."
  exit 1
fi

MANIFEST_RAW=$(cat "$MANIFEST_FILE")

if [ -z "$MANIFEST_RAW" ]; then
  echo "ERROR: Manifest file is empty."
  gh api "repos/$REPO/issues/$ISSUE_NUMBER/comments" \
    --method POST \
    --field body="❌ **scrum-init-execute**: Manifest file is empty. Please retry."
  exit 1
fi

# Validate JSON
if ! echo "$MANIFEST_RAW" | jq empty 2>/dev/null; then
  echo "ERROR: Manifest is not valid JSON."
  gh api "repos/$REPO/issues/$ISSUE_NUMBER/comments" \
    --method POST \
    --field body="❌ **scrum-init-execute**: The manifest is not valid JSON. Please retry."
  exit 1
fi

echo "Manifest loaded and valid."

echo "Manifest JSON is valid."

PROJECT_NAME=$(echo "$MANIFEST_RAW" | jq -r '.project_name')
MODE=$(echo "$MANIFEST_RAW" | jq -r '.mode')
EPICS=$(echo "$MANIFEST_RAW" | jq -c '.epics')
PLANNING=$(echo "$MANIFEST_RAW" | jq -c '.planning // []')

echo "Project name : $PROJECT_NAME"
echo "Mode         : $MODE"
echo "Epic count   : $(echo "$EPICS" | jq 'length')"

# -----------------------------------------------------------------------------
# Step 2 — Create labels
# -----------------------------------------------------------------------------
echo ""
echo "=== Step 2: Create labels ==="

gh label create "epic"       --color "8B5CF6" --description "Epic grouping multiple user stories" --repo "$REPO" --force || true
gh label create "user-story" --color "3B82F6" --description "User story"                          --repo "$REPO" --force || true
gh label create "task"       --color "6B7280" --description "Technical task"                      --repo "$REPO" --force || true
gh label create "todo"       --color "E5E7EB" --description "Empty placeholder — to be detailed"  --repo "$REPO" --force || true

echo "Labels created."

# -----------------------------------------------------------------------------
# Step 3 — Create epic issues
# Body is read from docs/specs/functional/ if available, otherwise minimal
# Gap epics (is_gap=true) get a [TODO] body and the 'todo' label
# -----------------------------------------------------------------------------
echo ""
echo "=== Step 3: Create epic issues ==="

EPIC_ISSUE_NUMBERS=()
EPIC_NODE_IDS=()
EPIC_TITLES=()
EPIC_COUNT=$(echo "$EPICS" | jq 'length')

for i in $(seq 0 $((EPIC_COUNT - 1))); do
  EPIC=$(echo "$EPICS" | jq -c ".[$i]")
  TITLE=$(echo "$EPIC" | jq -r '.title')
  IS_GAP=$(echo "$EPIC" | jq -r '.is_gap // false')

  if [ "$IS_GAP" = "true" ]; then
    BODY="## Epic — TODO

Cette epic a été identifiée comme manquante lors de l'analyse du backlog.
Elle doit être détaillée avant d'être développée.

## Critères d'acceptation
<!-- À compléter -->"
    LABELS="epic,todo"
  else
    # Try to read body from specs if epic.md exists
    SPEC_DIR=$(find docs/specs/functional -name "epic.md" 2>/dev/null | while read f; do
      if grep -qi "$(echo "$TITLE" | cut -c1-20)" "$f" 2>/dev/null; then echo "$(dirname $f)"; fi
    done | head -1)

    if [ -n "$SPEC_DIR" ] && [ -f "$SPEC_DIR/epic.md" ]; then
      BODY=$(cat "$SPEC_DIR/epic.md")
      echo "  (body from $SPEC_DIR/epic.md)"
    else
      BODY="## Epic
${TITLE}

## User Stories
<!-- Linked below after creation -->"
    fi
    LABELS="epic"
  fi

  echo "Creating epic: $TITLE (gap=$IS_GAP)"
  EPIC_URL=$(gh issue create \
    --repo "$REPO" \
    --title "$TITLE" \
    --body "$BODY" \
    --label "$LABELS")

  EPIC_NUMBER=$(echo "$EPIC_URL" | grep -oE '[0-9]+$')
  EPIC_NODE_ID=$(gh api "repos/$REPO/issues/$EPIC_NUMBER" --jq '.node_id')

  echo "  → Issue #$EPIC_NUMBER (node: $EPIC_NODE_ID)"
  EPIC_ISSUE_NUMBERS+=("$EPIC_NUMBER")
  EPIC_NODE_IDS+=("$EPIC_NODE_ID")
  EPIC_TITLES+=("$TITLE")
done

# -----------------------------------------------------------------------------
# Step 4 — Create user story issues (mode A only)
# Gap US (is_gap=true) get a [TODO] body and the 'todo' label
# Each US gets the epic title stored for later use in board field
# -----------------------------------------------------------------------------
US_ISSUE_NUMBERS=()
US_NODE_IDS=()
US_EPIC_TITLES=()

if [ "$MODE" = "A" ]; then
  echo ""
  echo "=== Step 4: Create user story issues ==="

  for i in $(seq 0 $((EPIC_COUNT - 1))); do
    EPIC=$(echo "$EPICS" | jq -c ".[$i]")
    EPIC_ISSUE_NUMBER="${EPIC_ISSUE_NUMBERS[$i]}"
    US_LIST=$(echo "$EPIC" | jq -c '.user_stories // []')
    US_COUNT=$(echo "$US_LIST" | jq 'length')

    for j in $(seq 0 $((US_COUNT - 1))); do
      US=$(echo "$US_LIST" | jq -c ".[$j]")
      US_TITLE=$(echo "$US" | jq -r '.title')
      US_IS_GAP=$(echo "$US" | jq -r '.is_gap // false')
      EPIC_TITLE="${EPIC_TITLES[$i]}"

      if [ "$US_IS_GAP" = "true" ]; then
        US_BODY="## User Story — TODO

Cette user story a été identifiée comme manquante lors de l'analyse du backlog.
Elle doit être détaillée avant d'être développée.

## Epic
Part of #${EPIC_ISSUE_NUMBER}"
        US_LABELS="user-story,todo"
      else
        # Try to read body from specs if us file exists
        US_SPEC=$(find docs/specs/functional -name "us-*.md" 2>/dev/null | while read f; do
          if grep -qi "$(echo "$US_TITLE" | cut -c1-20)" "$f" 2>/dev/null; then echo "$f"; fi
        done | head -1)

        if [ -n "$US_SPEC" ] && [ -f "$US_SPEC" ]; then
          US_BODY=$(cat "$US_SPEC")
          echo "  (body from $US_SPEC)"
        else
          US_BODY="## User Story
${US_TITLE}

## Epic
Part of #${EPIC_ISSUE_NUMBER}"
        fi
        US_LABELS="user-story"
      fi

      echo "Creating US: $US_TITLE (epic #$EPIC_ISSUE_NUMBER, gap=$US_IS_GAP)"
      US_URL=$(gh issue create \
        --repo "$REPO" \
        --title "$US_TITLE" \
        --body "$US_BODY" \
        --label "$US_LABELS")

      US_NUMBER=$(echo "$US_URL" | grep -oE '[0-9]+$')
      US_NODE_ID=$(gh api "repos/$REPO/issues/$US_NUMBER" --jq '.node_id')

      echo "  → Issue #$US_NUMBER (node: $US_NODE_ID)"
      US_ISSUE_NUMBERS+=("$US_NUMBER")
      US_NODE_IDS+=("$US_NODE_ID")
      US_EPIC_TITLES+=("$EPIC_TITLE")
    done

    # Update epic body with tasklist of its US
    if [ "${#US_ISSUE_NUMBERS[@]}" -gt 0 ] && [ "$US_COUNT" -gt 0 ]; then
      echo "  Updating epic #$EPIC_ISSUE_NUMBER body with tasklist..."

      # Get current epic body
      CURRENT_EPIC_BODY=$(gh api "repos/$REPO/issues/$EPIC_ISSUE_NUMBER" --jq '.body // ""')

      # Build tasklist for US created in this epic iteration
      TASKLIST=""
      # US created for this epic = last $US_COUNT entries in US_ISSUE_NUMBERS
      TOTAL_US=${#US_ISSUE_NUMBERS[@]}
      START_IDX=$((TOTAL_US - US_COUNT))
      for k in $(seq $START_IDX $((TOTAL_US - 1))); do
        US_NUM="${US_ISSUE_NUMBERS[$k]}"
        US_T=$(echo "$US_LIST" | jq -r ".[$((k - START_IDX))].title")
        TASKLIST="${TASKLIST}- [ ] #${US_NUM} ${US_T}
"
      done

      # Append tasklist to epic body
      NEW_EPIC_BODY="${CURRENT_EPIC_BODY}

## User Stories

${TASKLIST}"

      gh api "repos/$REPO/issues/$EPIC_ISSUE_NUMBER" \
        --method PATCH \
        --field body="$NEW_EPIC_BODY" > /dev/null

      echo "  → Epic #$EPIC_ISSUE_NUMBER tasklist updated."
    fi
  done
else
  echo ""
  echo "=== Step 4: Skipped (mode B — epics only) ==="
fi

# -----------------------------------------------------------------------------
# Step 5 — Create GitHub Project v2 (mode A only)
# Created at repo level so it appears in the repo's Projects tab
# -----------------------------------------------------------------------------
PROJECT_URL=""
PROJECT_ID=""

if [ "$MODE" = "A" ]; then
  echo ""
  echo "=== Step 5: Create GitHub Project v2 ==="

  OWNER=$(echo "$REPO" | cut -d'/' -f1)
  OWNER_ID=$(gh api "/users/$OWNER" --jq '.node_id')
  REPO_ID=$(gh api "/repos/$REPO" --jq '.node_id')
  echo "Owner: $OWNER (node: $OWNER_ID)"
  echo "Repo node id: $REPO_ID"

  PROJECT_DATA=$(gh api graphql -f query='
    mutation($ownerId: ID!, $title: String!, $repositoryId: ID!) {
      createProjectV2(input: { ownerId: $ownerId, title: $title, repositoryId: $repositoryId }) {
        projectV2 { id number url }
      }
    }' \
    -f ownerId="$OWNER_ID" \
    -f title="$PROJECT_NAME" \
    -f repositoryId="$REPO_ID")

  PROJECT_ID=$(echo "$PROJECT_DATA" | jq -r '.data.createProjectV2.projectV2.id')
  PROJECT_URL=$(echo "$PROJECT_DATA" | jq -r '.data.createProjectV2.projectV2.url')
  echo "Project created: $PROJECT_URL (id: $PROJECT_ID)"

  # ---------------------------------------------------------------------------
  # Step 6 — Read Status field and option IDs
  # ---------------------------------------------------------------------------
  echo ""
  echo "=== Step 6: Read Status and Epic fields ==="

  FIELDS_DATA=$(gh api graphql -f query='
    query($projectId: ID!) {
      node(id: $projectId) {
        ... on ProjectV2 {
          fields(first: 20) {
            nodes {
              ... on ProjectV2SingleSelectField {
                id name
                options { id name }
              }
              ... on ProjectV2Field {
                id name
              }
            }
          }
        }
      }
    }' -f projectId="$PROJECT_ID")

  STATUS_FIELD_ID=$(echo "$FIELDS_DATA" | jq -r '
    .data.node.fields.nodes[]
    | select(.name == "Status")
    | .id')

  TODO_OPTION_ID=$(echo "$FIELDS_DATA" | jq -r '
    .data.node.fields.nodes[]
    | select(.name == "Status")
    | .options[]
    | select(.name == "Todo")
    | .id')

  # Epic field (text) — may not exist yet, will be skipped if absent
  EPIC_FIELD_ID=$(echo "$FIELDS_DATA" | jq -r '
    .data.node.fields.nodes[]
    | select(.name == "Epic")
    | .id // empty' | head -1)

  echo "Status field id : $STATUS_FIELD_ID"
  echo "Todo option id  : $TODO_OPTION_ID"
  echo "Epic field id   : ${EPIC_FIELD_ID:-not found — skipping epic grouping}"

  # ---------------------------------------------------------------------------
  # Step 7 — Add all issues to the project board
  # Epics: set Status=Todo
  # US: set Status=Todo + set Epic field to parent epic title
  # ---------------------------------------------------------------------------
  echo ""
  echo "=== Step 7: Add issues to board ==="

  # Add epics first
  for NODE_ID in "${EPIC_NODE_IDS[@]}"; do
    ITEM_DATA=$(gh api graphql -f query='
      mutation($projectId: ID!, $contentId: ID!) {
        addProjectV2ItemById(input: { projectId: $projectId, contentId: $contentId }) {
          item { id }
        }
      }' \
      -f projectId="$PROJECT_ID" \
      -f contentId="$NODE_ID")

    ITEM_ID=$(echo "$ITEM_DATA" | jq -r '.data.addProjectV2ItemById.item.id')

    gh api graphql -f query='
      mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $optionId: String!) {
        updateProjectV2ItemFieldValue(input: {
          projectId: $projectId
          itemId: $itemId
          fieldId: $fieldId
          value: { singleSelectOptionId: $optionId }
        }) { projectV2Item { id } }
      }' \
      -f projectId="$PROJECT_ID" \
      -f itemId="$ITEM_ID" \
      -f fieldId="$STATUS_FIELD_ID" \
      -f optionId="$TODO_OPTION_ID" > /dev/null

    echo "  → Epic $NODE_ID added to board (item: $ITEM_ID)"
  done

  # Add US with Epic field
  US_IDX=0
  for NODE_ID in "${US_NODE_IDS[@]}"; do
    ITEM_DATA=$(gh api graphql -f query='
      mutation($projectId: ID!, $contentId: ID!) {
        addProjectV2ItemById(input: { projectId: $projectId, contentId: $contentId }) {
          item { id }
        }
      }' \
      -f projectId="$PROJECT_ID" \
      -f contentId="$NODE_ID")

    ITEM_ID=$(echo "$ITEM_DATA" | jq -r '.data.addProjectV2ItemById.item.id')

    # Set Status = Todo
    gh api graphql -f query='
      mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $optionId: String!) {
        updateProjectV2ItemFieldValue(input: {
          projectId: $projectId
          itemId: $itemId
          fieldId: $fieldId
          value: { singleSelectOptionId: $optionId }
        }) { projectV2Item { id } }
      }' \
      -f projectId="$PROJECT_ID" \
      -f itemId="$ITEM_ID" \
      -f fieldId="$STATUS_FIELD_ID" \
      -f optionId="$TODO_OPTION_ID" > /dev/null

    # Set Epic field = parent epic title (if field exists)
    if [ -n "$EPIC_FIELD_ID" ]; then
      PARENT_EPIC_TITLE="${US_EPIC_TITLES[$US_IDX]}"
      gh api graphql -f query='
        mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $text: String!) {
          updateProjectV2ItemFieldValue(input: {
            projectId: $projectId
            itemId: $itemId
            fieldId: $fieldId
            value: { text: $text }
          }) { projectV2Item { id } }
        }' \
        -f projectId="$PROJECT_ID" \
        -f itemId="$ITEM_ID" \
        -f fieldId="$EPIC_FIELD_ID" \
        -f text="$PARENT_EPIC_TITLE" > /dev/null
      echo "  → US $NODE_ID added (item: $ITEM_ID, epic: $PARENT_EPIC_TITLE)"
    else
      echo "  → US $NODE_ID added (item: $ITEM_ID, epic field not set)"
    fi

    US_IDX=$((US_IDX + 1))
  done
fi

# -----------------------------------------------------------------------------
# Step 8 — Post summary comment
# -----------------------------------------------------------------------------
echo ""
echo "=== Step 8: Post summary ==="

EPIC_LIST=""
for i in $(seq 0 $((EPIC_COUNT - 1))); do
  EPIC_TITLE=$(echo "$EPICS" | jq -r ".[$i].title")
  EPIC_NUM="${EPIC_ISSUE_NUMBERS[$i]}"
  EPIC_LIST="${EPIC_LIST}- #${EPIC_NUM} — ${EPIC_TITLE}
"
done

US_LIST_TEXT=""
if [ "$MODE" = "A" ] && [ "${#US_ISSUE_NUMBERS[@]}" -gt 0 ]; then
  US_IDX=0
  for i in $(seq 0 $((EPIC_COUNT - 1))); do
    EPIC_ISSUE_NUMBER="${EPIC_ISSUE_NUMBERS[$i]}"
    US_COUNT=$(echo "$EPICS" | jq -r ".[$i].user_stories | length")
    for j in $(seq 0 $((US_COUNT - 1))); do
      US_TITLE=$(echo "$EPICS" | jq -r ".[$i].user_stories[$j].title")
      US_NUM="${US_ISSUE_NUMBERS[$US_IDX]}"
      US_LIST_TEXT="${US_LIST_TEXT}- #${US_NUM} — ${US_TITLE} (epic #${EPIC_ISSUE_NUMBER})
"
      US_IDX=$((US_IDX + 1))
    done
  done
fi

# Build planning section from manifest
PLANNING_TEXT=""
PLANNING_COUNT=$(echo "$PLANNING" | jq 'length')
if [ "$PLANNING_COUNT" -gt 0 ]; then
  PLANNING_TEXT="### Ordre de mise en place recommandé

| # | Epic | Type | Dépend de | Pourquoi |
|---|------|------|-----------|----------|
"
  for p in $(seq 0 $((PLANNING_COUNT - 1))); do
    P_ORDER=$(echo "$PLANNING" | jq -r ".[$p].order")
    P_TITLE=$(echo "$PLANNING" | jq -r ".[$p].epic_title")
    P_TYPE=$(echo "$PLANNING" | jq -r ".[$p].type")
    P_RATIONALE=$(echo "$PLANNING" | jq -r ".[$p].rationale")
    P_DEPS=$(echo "$PLANNING" | jq -r ".[$p].depends_on | if length == 0 then \"—\" else join(\", \") end")

    # Find matching epic issue number
    EPIC_REF=""
    for i in $(seq 0 $((EPIC_COUNT - 1))); do
      T=$(echo "$EPICS" | jq -r ".[$i].title")
      if [ "$T" = "$P_TITLE" ]; then
        EPIC_REF="#${EPIC_ISSUE_NUMBERS[$i]}"
        break
      fi
    done

    TYPE_BADGE="🔧"
    if [ "$P_TYPE" = "functional" ]; then TYPE_BADGE="✨"; fi

    PLANNING_TEXT="${PLANNING_TEXT}| ${P_ORDER} | ${TYPE_BADGE} ${EPIC_REF} ${P_TITLE} | ${P_TYPE} | ${P_DEPS} | ${P_RATIONALE} |
"
  done
fi

if [ "$MODE" = "A" ]; then
  PROJECT_LINE="**Project v2 :** [${PROJECT_NAME}](${PROJECT_URL})"
  MANUAL_ACTIONS="### Actions manuelles dans les paramètres du projet
**Colonnes** — renomme ou ajoute : \`Backlog\` / \`Ready\` / \`In Progress\` / \`Review\` / \`Done\`
**Champs** → New field :
- Priority : Single select (High / Medium / Low)
- Type : Single select (Epic / Story / Task)
- Epic : Text
- Puis dans le board : grouper par le champ **Epic** pour visualiser la hiérarchie"
else
  PROJECT_LINE="*Mode B — project board non créé. Les epics sont prêtes.*"
  MANUAL_ACTIONS="Réponds \`/init-scrum A\` pour créer le project et les user stories."
fi

SUMMARY="## Initialisation Scrum terminée

${PROJECT_LINE}

### Epics créées
${EPIC_LIST}
$([ -n "$US_LIST_TEXT" ] && echo "### User Stories créées
${US_LIST_TEXT}")
${PLANNING_TEXT}
Toutes les issues ont été ajoutées au board en statut **Todo**.

---

${MANUAL_ACTIONS}"

gh api "repos/$REPO/issues/$ISSUE_NUMBER/comments" \
  --method POST \
  --field body="$SUMMARY"

echo ""
echo "=== scrum-init-execute: done ==="
