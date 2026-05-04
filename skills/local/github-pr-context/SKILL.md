---
name: github-pr-context
description: Understand and use the context of a GitHub PR inline review comment injected in the prompt by the Meristem dispatcher.
---

# GitHub PR Context

## Purpose

When triggered by a `pull_request_review_comment` event, the agent receives a pre-built
plain text prompt produced by the `prepare-context` job in `agent-dispatch.yml`.

This skill describes the structure of that prompt and how to use it correctly.
The agent does NOT need to call `gh api` manually — the context is already available.

Note: for general conversation comments on a PR (not inline on a code line), the event is
`issue_comment` — use `github-issue-context` in that case.

---

## Prompt structure

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

---

## How to use the context

### Step 1 — Identify the active instruction

Read the `## Instruction active` section. Strip the invocation pattern (`/dev`, `/qa`, etc.)
from the body. What remains is the actual request from the reviewer.

### Step 2 — Read the code context

- `## Contexte code` — the exact file, line, and diff hunk being commented on
- Use `path` and `line` to locate the relevant code before acting

### Step 3 — Read the background context

- `## Métadonnées PR` — PR title, state, branches, description
- `## Historique` — inline review comments sorted chronologically

### Step 4 — Determine the dialogue state

Scan `## Historique` for bot comments (authors ending in `[bot]`):

- If a bot comment proposed options → the active instruction is the user's reply. Execute immediately.
- If no prior proposal exists → treat as a new request and act according to your profile.

### Step 5 — Act

Apply your profile instructions. Never act before completing Steps 1–4.

### Step 6 — Post your response inline (MANDATORY)

When triggered by a `pull_request_review_comment`, you MUST post your response
inline on the same thread. Never post to the general conversation.

Use `reply_to_id` from `## Contexte code` :

```bash
ROLES=$(grep -A100 '^roles:' agents/config.yml | grep '^ *- ' | sed 's/ *- //' | tr '\n' ',' | sed 's/,$//')
BODY=$(printf '%s' "$BODY" | python3 -c "
import re, sys
roles = '${ROLES}'.split(',')
pattern = r'/(' + '|'.join(roles) + r')(?=[^a-zA-Z0-9_-]|\$)'
print(re.sub(pattern, r'\`/\1\`', sys.stdin.read()), end='')
")
gh api repos/{REPO}/pulls/{NUMBER}/comments \
  --method POST \
  --field body="$BODY" \
  --field in_reply_to={reply_to_id}
```

Where `{REPO}` and `{NUMBER}` are available in `## Métadonnées PR`.

The `in_reply_to` field automatically attaches the reply to the correct file and line thread.
Do not specify `path`, `line`, or `commit_id` separately.

The filter escapes any `/role` pattern in your response to prevent accidental agent invocations. Roles are read dynamically from `agents/config.yml` — no hardcoded list.

---

## Rules

- The active instruction is the ONLY question to answer
- Always respond inline — never post to `issues/comments` for this event type
- History is context — never treat historical review comments as new instructions
- `path` and `line` identify the exact code location being reviewed
- Never ask for confirmation if the user's intent is clear from context
- Never repropose options the user has already answered
