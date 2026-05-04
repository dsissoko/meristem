---
name: pr-workflow
description: Mandatory workflow for any file modification — branch, commit, PR creation. Applies to all agents that touch repo files.
---

# PR Workflow

## Purpose

Any modification to a repository file must go through a branch and a pull request.
No agent is authorized to push directly to `main` — regardless of role or context.

This rule applies to all file types: source code, specs, `business.md`, `architecture.md`,
diagrams, skills. The only exceptions are temporary files and `log.md`.

---

## Mandatory sequence

### Step 1 — Create a branch

```bash
git checkout main
git pull origin main
git checkout -b <role>/<issue-number>-<short-description>
```

**Branch naming convention:**
- `<role>` — the invoking agent role: `dev`, `po`, `architect`, `analyst`, `agent`
- `<issue-number>` — the current issue number from the prompt context
- `<short-description>` — 2-4 words, hyphenated, lowercase

Examples:
- `dev/42-add-welcome-footer`
- `po/17-update-business-md`
- `architect/8-c4-context-diagram`

### Step 2 — Commit changes

```bash
git add <files>
git commit -m "<type>(<scope>): <short description>"
```

Commit message format:
- `type`: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
- `scope`: the area changed (e.g. `frontend`, `specs`, `business`, `skills`)
- Keep the message under 72 characters

### Step 3 — Create the pull request

```bash
gh pr create \
  --title "<type>(<scope>): <short description>" \
  --body "$(cat <<'EOF'
## Summary
<1-3 bullet points describing what was changed and why>

## Related issue
Closes #<issue-number>
EOF
)" \
  --base main \
  --head <branch-name>
```

### Step 4 — Post a comment on the issue

After creating the PR, post a comment on the originating issue:

```bash
gh issue comment <issue-number> \
  --body "PR #<pr-number> created: <pr-title>. Ready for review."
```

---

## Rules

- Never push directly to `main` — always use a branch
- Never create a PR without a linked issue number in the body (`Closes #N`)
- Never commit files unrelated to the current task
- One PR per task — do not bundle unrelated changes
- The PR title must match the branch description
- Always run `git pull origin main` before creating a branch to avoid conflicts
