# Skill: agent-handoff

## Purpose

This skill is loaded only when `autonomous_mode: true` in `agents/config.yml`.

It gives the agent the ability to solicit another agent when relevant — either to
request additional information or to hand off its results for the next step.

This is not a directive. The agent uses its judgment to decide whether a handoff
is needed and which agent is the right one.

---

## When to use

Use this skill when:
- You need information or analysis that another agent is better positioned to provide
- Your output is an input for another agent's work (e.g. implementation is done, QA should review)
- You have reached the boundary of your role and another agent should continue

Do **not** use this skill if:
- The task is complete and no further action is needed
- You are uncertain — post a summary and let the human decide

---

## How to invoke another agent

**Rule — where to post the invocation :**
- If a PR exists → post the invocation as a comment on the PR
- If no PR exists yet → post the invocation as a comment on the issue
- After a PR is merged → post a summary on the originating issue and invoke `/po`

All exchanges (code review, spec feedback, validation) happen on the PR thread
until the PR is merged. The issue thread resumes only after merge.

Post using `gh` :

```bash
# On a PR
gh pr comment {pr_number} --body "/role your concise handoff message"

# On an issue (before PR exists, or after merge)
gh issue comment {issue_number} --body "/role your concise handoff message"
```

Both `{pr_number}` and `{issue_number}` are available in the prompt context.

**Example — dev handing off to qa after pushing a PR:**
```
/qa PR #42 is ready for review. Implemented the tag filtering feature.
All unit tests pass. Please review and validate.
```

**Example — after PR merge, handing off to po:**
```
/po PR #42 has been merged. Feature implemented and validated.
Please close this issue and move to the next priority.
```

---

## How to merge a PR (authorized agents only)

Only agents with "Merge authorization" in their profile may merge a PR.

### Step 1 — Check for conflicts

```bash
gh pr view {pr_number} --json mergeable,mergeStateStatus \
  --jq '"mergeable: \(.mergeable) | state: \(.mergeStateStatus)"'
```

- `mergeable: MERGEABLE` + `mergeStateStatus: CLEAN` → proceed to merge
- `mergeable: CONFLICTING` → do NOT merge. Post a comment on the PR explaining the conflict and invoke `/dev` to resolve it
- Any other state → post a comment and wait for human intervention

### Step 2 — Merge

Only if Step 1 confirms no conflict :

```bash
gh pr merge {pr_number} --squash --auto --delete-branch
```

- `--squash` — squashes all commits into one clean commit on main
- `--auto` — merges automatically once all checks pass
- `--delete-branch` — cleans up the feature branch after merge

### Step 3 — Post summary on originating issue

After merge :

```bash
gh issue comment {issue_number} --body "PR #{pr_number} merged. [brief summary of what was done]"
```

---

## Rules

- Always respond in the issue/PR thread first before invoking another agent
- The handoff comment must be concise — one or two sentences maximum
- Never invoke more than one agent per run
- Never invoke an agent in a loop — check the log to avoid redundant invocations
- Never merge if there are conflicts — always resolve first
- Never merge without checking `mergeable` status first
