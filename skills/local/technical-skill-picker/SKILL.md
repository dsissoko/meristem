# Skill: technical-skill-picker

## Purpose

Dynamically select and load the stack-specific skill sets appropriate for the current project,
based on the technical context described in `architecture.md`.

This skill is loaded by technical agents (dev, qa, architect) via the `technical` set.
It acts as a bridge between the generic role sets and the stack-specific sets.

---

## When to apply

Apply this skill after loading your role set (dev, qa, or architect) and before starting
any technical task that requires stack-specific knowledge.

---

## Process

1. **Read `architecture.md`**
   - Identify the technical stack : frontend framework, UI library, backend, testing tools, build tools, etc.

2. **Read `skills/skills-set.md`**
   - List all available sets
   - For each set prefixed with `stack-`, read its `description` field
   - Match the description against the identified stack

3. **Select relevant sets**
   - Select the sets whose description matches the current stack
   - If no set matches exactly, select the closest match and note the gap
   - If multiple sets match, load all of them

4. **Load selected sets**
   - For each selected set, load every SKILL.md listed

5. **Report**
   - State which sets were loaded and why
   - If no matching set was found, report it explicitly — do not invent stack-specific instructions

---

## Example

For a project with `architecture.md` describing React + Vite + Primer UI + MSW :

- Matches `stack-fullstack-vite-react-primer` → load its skills
- Does not match `stack-java-spring` (hypothetical) → skip

---

## Rules

- Never load a stack set without reading its description first
- Never invent stack-specific instructions not covered by a loaded skill
- If the stack in `architecture.md` is ambiguous or incomplete, post a comment asking for clarification before proceeding
- Stack sets are managed by humans in `skills/skills-set.md` — do not modify them
