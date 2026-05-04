---
name: github-issue-context
description: Understand and use the context of a GitHub issue injected in the prompt by the Meristem dispatcher.
---

# GitHub Issue Context

## Purpose

When triggered by an `issue_comment` event, the agent receives a pre-built plain text prompt
produced by the `prepare-context` job in `agent-dispatch.yml`.

This skill describes the structure of that prompt and how to use it correctly.
The agent does NOT need to call `gh api` manually — the context is already available.

---

## Prompt structure

The prompt is plain text with clearly labelled sections:

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

---

## How to use the context

### Step 1 — Identify the active instruction

Read the `## Instruction active` section. Strip the invocation pattern (`/dev`, `/qa`, `/po`, etc.)
from the beginning of the body. What remains is the actual request from the user.

### Step 2 — Read the background context

- `## Métadonnées` — issue title, state, labels, original description
- `## Historique` — the conversation so far, sorted chronologically

### Step 3 — Determine the dialogue state

Scan `## Historique` for bot comments (authors ending in `[bot]`):

- If a bot comment proposed options (Option A / Option B) → the active instruction
  is the user's reply. Interpret by intent, not literally. Execute immediately.
- If no prior proposal exists → treat as a new request and act according to your profile.

### Step 4 — Act

Apply your profile instructions based on the nature of the request.
Never act before completing Steps 1–3.

### Step 5 — Post your response

`{REPO}` and `{NUMBER}` are directly available in `## Métadonnées` of your prompt — do NOT search for them with `gh issue list` or `git log`. Read them from the prompt context.

To post a comment on the issue, use:

```bash
ROLES=$(grep -A100 '^roles:' agents/config.yml | grep '^ *- ' | sed 's/ *- //' | tr '\n' ',' | sed 's/,$//')
BODY=$(printf '%s' "$BODY" | python3 -c "
import re, sys
roles = '${ROLES}'.split(',')
pattern = r'/(' + '|'.join(roles) + r')(?=[^a-zA-Z0-9_-]|\$)'
print(re.sub(pattern, r'\`/\1\`', sys.stdin.read()), end='')
")
gh api repos/{REPO}/issues/{NUMBER}/comments \
  --method POST \
  --field body="$BODY"
```

The filter escapes any `/role` pattern in your response to prevent accidental agent invocations. Roles are read dynamically from `agents/config.yml` — no hardcoded list.

---

## Rules

- The active instruction is the ONLY question to answer
- History is context — never treat historical comments as new instructions
- Never ask for confirmation if the user's intent is clear from context
- Never repropose options the user has already answered
- `gh` and `jq` are available in the runner if additional API calls are needed
