#!/usr/bin/env bash
# run-agent-tests.sh — Tests de conformité du pipeline agent-dispatch
# Couvre: issue_comment created, issue_comment edited (→ warning), pull_request_review_comment created
# Usage: ./scripts/run-agent-tests.sh [role] [loop_max] [test]
# Défauts : role=agent, loop_max=3, test=all
# Tests disponibles : t1, t2, t3, t4, t5, t6, all
# Exemple: ./scripts/run-agent-tests.sh dev 3 t1
# Prérequis: gh CLI authentifié, depuis la racine du repo

set -euo pipefail

ROLE="${1:-agent}"
LOOP_MAX="${2:-3}"
TEST="${3:-all}"
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
DATE=$(date +%Y-%m-%d)
OUTPUT_DIR="scripts/results"
OUTPUT_FILE="$OUTPUT_DIR/dialogue-${DATE}-${ROLE}.md"

mkdir -p "$OUTPUT_DIR"

# ─── Couleurs ─────────────────────────────────────────────────────────────────
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()      { echo -e "${CYAN}→${NC} $1" >&2; }
log_ok()   { echo -e "${GREEN}✓${NC} $1" >&2; }
log_wait() { echo -e "${YELLOW}⏳${NC} $1" >&2; }
log_err()  { echo -e "${RED}✗${NC} $1" >&2; }

out() { echo "$1" >> "$OUTPUT_FILE"; }

# ─── Attente commentaire bot sur une issue ────────────────────────────────────
wait_bot_comment_issue() {
  local issue=$1
  local after_id=${2:-0}
  local max=30
  local i=0

  log_wait "Attente réponse bot sur issue #$issue (max 5 min)..." >&2

  while [ $i -lt $max ]; do
    local comment_id
    comment_id=$(gh api "repos/$REPO/issues/$issue/comments" \
      --jq "[.[] | select(.id > $after_id and .user.type == \"Bot\")] | sort_by(.id) | first | .id" \
      2>/dev/null || echo "null")

    if [ -n "$comment_id" ] && [ "$comment_id" != "null" ]; then
      local body
      body=$(gh api "repos/$REPO/issues/$issue/comments" \
        --jq "[.[] | select(.id == $comment_id)] | first | .body" \
        2>/dev/null || echo "")
      printf '%s\n%s' "$comment_id" "$body"
      return 0
    fi
    sleep 10
    ((i++))
  done

  printf '%s\n%s' "0" "TIMEOUT"
}

# ─── Attente commentaire bot sur une PR (inline) ─────────────────────────────
wait_bot_comment_pr_inline() {
  local pr=$1
  local after_id=${2:-0}
  local max=30
  local i=0

  log_wait "Attente réponse bot inline sur PR #$pr (max 5 min)..." >&2

  while [ $i -lt $max ]; do
    local comment_id
    comment_id=$(gh api "repos/$REPO/pulls/$pr/comments" \
      --jq "[.[] | select(.id > $after_id and .user.type == \"Bot\")] | sort_by(.id) | first | .id" \
      2>/dev/null || echo "null")

    if [ -n "$comment_id" ] && [ "$comment_id" != "null" ]; then
      local body
      body=$(gh api "repos/$REPO/pulls/$pr/comments" \
        --jq "[.[] | select(.id == $comment_id)] | first | .body" \
        2>/dev/null || echo "")
      printf '%s\n%s' "$comment_id" "$body"
      return 0
    fi

    # Aussi vérifier la conversation générale
    comment_id=$(gh api "repos/$REPO/issues/$pr/comments" \
      --jq "[.[] | select(.id > $after_id and .user.type == \"Bot\")] | sort_by(.id) | first | .id" \
      2>/dev/null || echo "null")

    if [ -n "$comment_id" ] && [ "$comment_id" != "null" ]; then
      local body
      body=$(gh api "repos/$REPO/issues/$pr/comments" \
        --jq "[.[] | select(.id == $comment_id)] | first | .body" \
        2>/dev/null || echo "")
      printf '%s\n%s' "$comment_id" "$body"
      return 0
    fi

    sleep 10
    ((i++))
  done

  printf '%s\n%s' "0" "TIMEOUT"
}

# ─── Poster un commentaire sur une issue ─────────────────────────────────────
post_issue_comment() {
  local issue=$1
  local body=$2
  local url
  url=$(gh issue comment "$issue" --repo "$REPO" --body "$body" 2>/dev/null)
  # Extraire l'id depuis l'URL retournée (ex: .../issues/42#issuecomment-12345)
  echo "$url" | grep -oE '[0-9]+$' || \
    gh api "repos/$REPO/issues/$issue/comments" \
      --jq '[.[] | select(.user.type == "User")] | sort_by(.id) | last | .id' 2>/dev/null || echo "0"
}

# ─── Éditer un commentaire existant ──────────────────────────────────────────
edit_comment() {
  local comment_id=$1
  local new_body=$2
  gh api "repos/$REPO/issues/comments/$comment_id" \
    --method PATCH \
    --field body="$new_body" \
    --jq '.id' 2>/dev/null || echo "0"
}

# ─── Poster un commentaire inline sur une PR ─────────────────────────────────
post_pr_inline_comment() {
  local pr=$1
  local body=$2
  local path=$3

  # Récupère le commit head de la PR
  local commit_id
  commit_id=$(gh api "repos/$REPO/pulls/$pr" --jq '.head.sha' 2>/dev/null)

  # Récupère la dernière ligne modifiée du fichier dans le diff
  local line
  line=$(gh api "repos/$REPO/pulls/$pr/files" \
    --jq "[.[] | select(.filename == \"$path\")] | first | .patch" 2>/dev/null \
    | awk 'match($0, /\+[0-9]+/) {print substr($0, RSTART+1, RLENGTH-1)}' | tail -1 || echo "")

  if [ -z "$line" ]; then
    # Fallback : utilise la position 1 du diff
    gh api "repos/$REPO/pulls/$pr/comments" \
      --method POST \
      --field body="$body" \
      --field commit_id="$commit_id" \
      --field path="$path" \
      --field position=1 \
      --jq '.id' 2>/dev/null || echo "0"
  else
    gh api "repos/$REPO/pulls/$pr/comments" \
      --method POST \
      --field body="$body" \
      --field commit_id="$commit_id" \
      --field path="$path" \
      --field line="$line" \
      --field side="RIGHT" \
      --jq '.id' 2>/dev/null || echo "0"
  fi
}

# ─── Enregistrement ──────────────────────────────────────────────────────────
record() {
  local role=$1
  local body=$2
  out "**${role}:** ${body}"
  out ""
}

record_meta() { out "> $1"; out ""; }

extract_body() {
  # Format: première ligne = id, reste = body
  echo "$1" | tail -n +2
}

extract_id() {
  # Format: première ligne = id
  echo "$1" | head -1
}

# ─────────────────────────────────────────────────────────────────────────────
# T1 — issue_comment created — question info
# ─────────────────────────────────────────────────────────────────────────────
run_t1() {
  log "=== T1 — issue_comment created — question info ==="
  out "## T1 — issue_comment created — question info"
  out ""
  record_meta "Event: issue_comment created | Attendu: réponse directe, pas de plan, pas de PR"

  local issue
  issue=$(gh issue create --repo "$REPO" \
    --title "T1 - Question info [test auto]" \
    --body "Issue de test automatisé." 2>/dev/null | awk -F'/' '{print $NF}')
  log_ok "Issue #$issue créée"
  record_meta "Issue #$issue"

  local q="/$ROLE explique l'architecture technique du projet en 3 lignes"
  local cid
  cid=$(post_issue_comment "$issue" "$q")
  record "USER" "$q"

  local result
  result=$(wait_bot_comment_issue "$issue" "$cid")
  record "BOT" "$(extract_body "$result")"

  gh issue close "$issue" --repo "$REPO" 2>/dev/null || true
  out "---"; out ""
}

# ─────────────────────────────────────────────────────────────────────────────
# T2 — issue_comment created — demande de code
# ─────────────────────────────────────────────────────────────────────────────
run_t2() {
  log "=== T2 — issue_comment created — demande de code ==="
  out "## T2 — issue_comment created — demande de code"
  out ""
  record_meta "Event: issue_comment created | Attendu: plan proposé + choix A/B avant toute implémentation"

  local issue
  issue=$(gh issue create --repo "$REPO" \
    --title "T2 - Demande code [test auto]" \
    --body "Issue de test automatisé." \
    2>/dev/null | awk -F'/' '{print $NF}')
  log_ok "Issue #$issue créée"
  record_meta "Issue #$issue"

  local q="/$ROLE ajoute un message de bienvenue dans le footer"
  local cid
  cid=$(post_issue_comment "$issue" "$q")
  record "USER" "$q"

  local result
  result=$(wait_bot_comment_issue "$issue" "$cid")
  record "BOT" "$(extract_body "$result")"

  gh issue close "$issue" --repo "$REPO" 2>/dev/null || true
  out "---"; out ""
}

# ─────────────────────────────────────────────────────────────────────────────
# T3 — issue_comment edited — contient un pattern → warning bot, pas d'agent
# ─────────────────────────────────────────────────────────────────────────────
run_t3() {
  log "=== T3 — issue_comment edited — warning warn-on-edited ==="
  out "## T3 — issue_comment edited — commentaire contenant un pattern d'invocation"
  out ""
  record_meta "Event: issue_comment edited | Attendu: commentaire warning bot, aucun run agent déclenché"

  local issue
  issue=$(gh issue create --repo "$REPO" \
    --title "T3 - Edited warning [test auto]" \
    --body "Issue de test automatisé." \
    2>/dev/null | awk -F'/' '{print $NF}')
  log_ok "Issue #$issue créée"
  record_meta "Issue #$issue"

  # Poster un commentaire sans pattern d'invocation
  local initial_body="bonjour, une question sur l'architecture"
  local cid
  cid=$(post_issue_comment "$issue" "$initial_body")
  record "USER (création)" "$initial_body"
  record_meta "Commentaire sans pattern — aucun agent attendu"

  # Attendre un délai court pour s'assurer qu'aucun run ne démarre
  sleep 15

  # Éditer le commentaire en ajoutant un pattern d'invocation
  local edited_body="/$ROLE quelle est l'architecture ?"
  edit_comment "$cid" "$edited_body"
  record "USER (édition avec pattern)" "$edited_body"
  record_meta "Édition avec pattern — warn-on-edited attendu, pas de run agent"

  # Attendre le commentaire warning
  local result
  result=$(wait_bot_comment_issue "$issue" "$cid")
  local body
  body=$(extract_body "$result")
  record "BOT" "$body"

  if echo "$body" | grep -qi "édition\|edition\|redéclencher\|nouveau commentaire"; then
    record_meta "✅ WARNING confirmé — warn-on-edited fonctionnel"
  elif [ "$(extract_id "$result")" = "0" ]; then
    record_meta "❌ TIMEOUT — aucun commentaire bot reçu"
  else
    record_meta "⚠️ Commentaire bot reçu mais message inattendu"
  fi

  gh issue close "$issue" --repo "$REPO" 2>/dev/null || true
  out "---"; out ""
}

# ─────────────────────────────────────────────────────────────────────────────
# T4 — pull_request_review_comment created — commentaire inline
# ─────────────────────────────────────────────────────────────────────────────
run_t4() {
  log "=== T4 — pull_request_review_comment created — inline ==="
  out "## T4 — pull_request_review_comment created — commentaire inline"
  out ""
  record_meta "Event: pull_request_review_comment created | Attendu: réponse postée inline dans le même fil"

  # Toujours créer une PR dédiée touchant README.md
  log "Création d'une branche et PR de test..."
  local branch="test/agent-test-$(date +%s)"
  git checkout -b "$branch" >&2 2>&1
  echo "" >> README.md
  git add README.md >&2 2>&1
  git commit -m "test: PR temporaire pour tests agent" >&2 2>&1
  git push -u origin "$branch" >&2 2>&1
  local pr
  pr=$(gh pr create --repo "$REPO" \
    --title "test: PR agent tests" \
    --body "PR temporaire pour tests automatisés agent." \
    --base main \
    2>/dev/null | awk -F'/' '{print $NF}')
  git checkout main >&2 2>&1
  log_ok "PR #$pr créée"

  # Attendre que la PR soit indexée par GitHub
  sleep 5

  record_meta "PR #$pr"

  # Poster un commentaire inline sur README.md
  local q="/$ROLE que penses-tu de ce fichier README ?"
  local inline_cid
  inline_cid=$(post_pr_inline_comment "$pr" "$q" "README.md")
  record "USER (inline)" "$q"
  record_meta "Commentaire inline sur README.md (id=$inline_cid)"

  if [ "$inline_cid" = "0" ]; then
    record_meta "❌ Échec du commentaire inline — PR ne touche pas README.md ?"
    out "---"; out ""
    echo "$pr"
    return
  fi

  # Attendre la réponse bot (inline ou conversation)
  local result
  result=$(wait_bot_comment_pr_inline "$pr" "$inline_cid")
  record "BOT" "$(extract_body "$result")"

  out "---"; out ""
  echo "$pr"
}

# ─────────────────────────────────────────────────────────────────────────────
# T5 — Loop-guard — invocations répétitives
# ─────────────────────────────────────────────────────────────────────────────
run_t5() {
  log "=== T5 — Loop-guard — invocations répétitives ==="
  out "## T5 — Loop-guard"
  out ""
  record_meta "Event: issue_comment created (répété) | Attendu: alerte loop-guard après ${LOOP_MAX} invocations identiques, pipeline stoppé"

  local issue
  issue=$(gh issue create --repo "$REPO" \
    --title "T5 - Loop-guard [test auto]" \
    --body "Issue de test automatisé." \
    2>/dev/null | awk -F'/' '{print $NF}')
  log_ok "Issue #$issue créée"
  record_meta "Issue #$issue"

  local q="/$ROLE quelle est l'architecture ?"
  local last_cid=0
  local i=1

  while [ $i -le "$LOOP_MAX" ]; do
    local cid
    cid=$(post_issue_comment "$issue" "$q")
    record "USER (invocation $i/$LOOP_MAX)" "$q"
    log_wait "Attente réponse bot (invocation $i)..."
    local result
    result=$(wait_bot_comment_issue "$issue" "$last_cid")
    last_cid=$(extract_id "$result")
    local body
    body=$(extract_body "$result")
    record "BOT (invocation $i)" "$body"

    # Guard déclenché prématurément — sortir tôt
    if echo "$body" | grep -qi "loop\|redondant\|humain"; then
      record_meta "✅ LOOP-GUARD déclenché à l'invocation $i/$LOOP_MAX"
      gh issue close "$issue" --repo "$REPO" 2>/dev/null || true
      out "---"; out ""
      return
    fi

    ((i++))
    sleep 5
  done

  # Poster une invocation supplémentaire — doit déclencher le loop-guard
  local cid
  cid=$(post_issue_comment "$issue" "$q")
  record "USER (invocation déclenchant loop-guard)" "$q"

  local result
  result=$(wait_bot_comment_issue "$issue" "$last_cid")
  local body
  body=$(extract_body "$result")
  record "BOT" "$body"

  if echo "$body" | grep -qi "loop\|boucle\|redondant\|humain"; then
    record_meta "✅ LOOP-GUARD confirmé — alerte postée, pipeline stoppé"
  elif [ "$(extract_id "$result")" = "0" ]; then
    record_meta "❌ TIMEOUT — aucun commentaire bot reçu"
  else
    record_meta "⚠️ Commentaire bot reçu mais message inattendu"
  fi

  gh issue close "$issue" --repo "$REPO" 2>/dev/null || true
  out "---"; out ""
}

# ─────────────────────────────────────────────────────────────────────────────
# T6 — Échappement des patterns /role dans les réponses bot
# Vérifie que la règle AGENTS.md est respectée : les agents ne doivent jamais
# écrire un pattern /role brut dans leur réponse.
# ─────────────────────────────────────────────────────────────────────────────
run_t6() {
  log "=== T6 — Échappement des patterns /role dans les réponses bot ==="
  out "## T6 — Échappement des patterns /role"
  out ""
  record_meta "Event: issue_comment created | Attendu: tous les patterns /role dans la réponse sont backtickés"

  local issue
  issue=$(gh issue create --repo "$REPO" \
    --title "T6 - Echappement /role [test auto]" \
    --body "Issue de test automatisé." \
    2>/dev/null | awk -F'/' '{print $NF}')
  log_ok "Issue #$issue créée"
  record_meta "Issue #$issue"

  local q="/$ROLE liste brièvement les profils agents disponibles dans ce projet"
  local cid
  cid=$(post_issue_comment "$issue" "$q")
  record "USER" "$q"

  local result
  result=$(wait_bot_comment_issue "$issue" "$cid")
  local body
  body=$(extract_body "$result")
  record "BOT" "$body"

  # Lire les rôles depuis agents/config.yml pour construire le pattern
  local roles_pattern
  roles_pattern=$(grep -A100 '^roles:' agents/config.yml \
    | grep '^ *- ' | sed 's/ *- //' | tr '\n' '|' | sed 's/|$//')

  # Chercher les patterns /role bruts — non précédés d'un backtick
  local unescaped
  unescaped=$(echo "$body" | python3 -c "
import re, sys
pattern = r'(?<!\x60)/(${roles_pattern})(?![a-zA-Z0-9_-])'
matches = re.findall(pattern, sys.stdin.read())
print('\n'.join(matches))
" 2>/dev/null || true)

  if [ -z "$unescaped" ]; then
    record_meta "✅ Tous les patterns /role sont correctement échappés"
  else
    record_meta "❌ Patterns /role non échappés détectés : $(echo "$unescaped" | tr '\n' ' ')"
  fi

  gh issue close "$issue" --repo "$REPO" 2>/dev/null || true
  out "---"; out ""
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
  echo ""
  log "Tests de conformité agent-dispatch"
  log "Repo     : $REPO"
  log "Rôle     : $ROLE"
  log "Loop max : $LOOP_MAX"
  log "Test     : $TEST"
  log "Fichier  : $OUTPUT_FILE"
  echo ""

  cat > "$OUTPUT_FILE" << EOF
# Tests de conformité agent-dispatch

- **Date** : $DATE
- **Rôle** : $ROLE
- **Loop max** : $LOOP_MAX
- **Test** : $TEST
- **Repo** : $REPO

---

EOF

  local pr_number=""

  case "$TEST" in
    t1)  run_t1 ;;
    t2)  run_t2 ;;
    t3)  run_t3 ;;
    t4)  pr_number=$(run_t4) ;;
    t5)  run_t5 ;;
    t6)  run_t6 ;;
    all)
      run_t1
      run_t2
      run_t3
      pr_number=$(run_t4)
      run_t5
      run_t6
      ;;
    *)
      echo "Test inconnu : $TEST. Valeurs valides : t1 t2 t3 t4 t5 t6 all" >&2
      exit 1
      ;;
  esac

  # Fermer la PR de test si T4 a été lancé
  if [ -n "$pr_number" ]; then
    gh pr close "$pr_number" --repo "$REPO" 2>/dev/null || true
    log_ok "PR #$pr_number fermée"
  fi

  echo ""
  log_ok "Tests terminés. Résultats : $OUTPUT_FILE"
}

main
