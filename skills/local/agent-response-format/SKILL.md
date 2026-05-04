---
name: agent-response-format
description: Rules for structuring agent responses — one output type per turn, no internal monologue, structured questions, standardized A/B choice blocks.
---

# Agent Response Format

## Purpose

Define the expected format for all agent responses. These rules apply regardless of the agent role,
the nature of the request, or the execution mode (classic or autonomous).

---

## Rule 1 — One output type per turn

Each turn produces exactly one of the following:

- a **response** — information, analysis, or the result of a completed action
- a **question** — a clarification or validation required before acting
- an **action** — file modification, commit, PR creation, GitHub comment

**If the turn ends with a question → no action in that turn. No exceptions.**

Corollary: never create a PR, push a commit, or post a GitHub comment in the same turn as
a question waiting for a human reply.

---

## Rule 2 — Response format

Structure every response in this order:

1. **What was done or understood** — 1 sentence maximum
2. **The result or proposal** — the body, as long as necessary
3. **What is expected next** — one explicit thing, or nothing if the work is complete

**Never include in a response:**
- intermediate reasoning or visible hesitation
- unsolicited alternatives
- restatement of context the human already knows
- preambles ("I will now...", "As requested...", "Sure! I'll...")
- apologies or unnecessary hedging

---

## Rule 3 — Question format

When clarification is required before acting:

- 1 to 3 questions maximum, numbered
- Lettered options (A / B / C) with the default marked `(default)`
- Fast-path: tell the human that replying `A` or `1b 2a` is enough
- Close with a single closing line: "Reply to continue."
- Nothing after that line — no action, no anticipation of the human's choice

**Example — simple question:**

```
Before continuing:

1) Scope of the change?
   A) Target file only (default)
   B) All files in the component

Reply A or B to continue.
```

---

## Rule 4 — Multi-topic question format (matrix)

When several correlated choices are needed across different themes, use a Markdown table
instead of a list. This keeps the question compact and scannable.

```
Before continuing:

| # | Theme      | A                     | B                        | C                    |
|---|------------|-----------------------|--------------------------|----------------------|
| 1 | Scope      | Target file (default) | Full component           | —                    |
| 2 | Tests      | Non-regression only   | New tests included (default) | —               |
| 3 | Style      | Keep existing (default) | Apply conventions      | Full refactor        |

Reply with compact choices (e.g. `1A 2B 3A`) or `defaults` to accept all defaults.
```

**Rules:**
- Use this format only when 3 or more correlated choices are needed
- Always provide a `defaults` fast-path
- Never mix table format and list format in the same question block

---

## Rule 5 — A/B choice block format

When a profile requires a plan/execution choice (e.g. `/dev` plan proposal), use this
exact structure:

```
**A —** [description of option A]
**B —** [description of option B]

Reply A or B to continue.
```

**Rules:**
- Nothing after the closing line
- No comment, no hint toward one option, no anticipation of the human's choice
- The closing line is always: "Reply A or B to continue." (adapt language to match the issue)

---

## Rule 6 — Escaping `/role` patterns in responses

Any `/role` pattern written unescaped in a comment triggers the dispatcher — including patterns
inside Markdown tables, code blocks descriptions, or inline text.

**Always wrap `/role` patterns in backticks** when mentioning them in a response:

- ✅ `` `/dev` ``, `` `/qa` ``, `` `/po` ``
- ❌ `/dev`, `/qa`, `/po`

This applies everywhere: prose, tables, lists, examples. No exception.

**In Markdown tables**, cell content is not escaped by `|` — a cell containing `/dev` is read
by the dispatcher exactly like a standalone `/dev` comment.

Before posting any comment, pass the body through the escape filter defined in
`github-issue-context` (Step 5) or `github-pr-context` (Step 6). This filter wraps all
unescaped `/role` patterns in backticks automatically.
