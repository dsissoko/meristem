# skills/local/discover-skills/SKILL.md

## Objective

Identify and recommend relevant external skills based on a user request and repository context.

---

## Input

- User request (or implementation intent for the next iteration)
- Repository knowledge:
  - business.md (Vision / Product / Roadmap)
  - architecture.md (Minimal stack / Application architecture / Quality & tooling)
  - docs/specs/ (when available)
- Optional preset configuration:
  - skills/skills-presets.md (when present)

---

## Process

1. **Read any presets (if available)**
   - Check whether `skills/skills-presets.md` exists.
   - If it does, read the file and identify the preset whose “Match stack” criteria best correspond to the stack described in `architecture.md`
     (for example: `domain`, `frontend`, `ui_library`, `backend`, etc.).
   - If a relevant preset is found, treat its skills as a **proposed baseline** for the targeted iteration.
   - Do not download skills at this stage: only prepare a structured proposal.

2. **Analyse the iteration context**
   - Extract key elements from `architecture.md` and the user request:
     - domain (frontend, backend, fullstack, infra, etc.)
     - target stack (frameworks, languages, services)
     - quality and tooling constraints (tests, CI, monitoring, etc.)
     - roadmap focus (which iteration from `business.md` is targeted)
   - Take into account skills already covered by the preset (if any) to avoid duplicates.

3. **Search for complementary skills**
   - Look for additional candidate skills in trusted sources:
     - https://officialskills.sh/
     - public GitHub repositories
     - known skill collections
   - For each candidate, identify:
     - name
     - source
     - short description
     - scope

4. **Evaluate overall relevance**
   - For each skill (from the preset or discovered), evaluate:
     - alignment with `business.md` and `architecture.md`
     - coverage of requested capabilities for the targeted roadmap iteration
   - Keep the final set reasonable (typically 3–5 main skills plus at most 1–2 well‑justified complementary skills).

5. **Prepare the final proposal**
   - Build a **structured shortlist** that clearly distinguishes:
     - skills coming from a preset (expert-recommended baseline),
     - complementary skills discovered for this specific case.

---

## Output

Return a structured shortlist including:
- skill name
- source
- justification
and, when possible:
- suggested installation path under `skills/<source>/<skill-name>/`

When the user has validated the shortlist and the agent proceeds to download/install skills, this skill also governs the **canonical format** of `skills/skills.lock.md`.

---

## Lock File Format (`skills/skills.lock.md`)

### Purpose

`skills.lock.md` is the canonical registry of installed skills for the project.  
It MUST describe exactly which skills are present under `skills/` and how they were obtained.

### Canonical structure

The lock file is a Markdown document with:

- a title:
  - `# skills.lock.md`
- an optional introductory paragraph,
- a section describing installed skills (for example `## Installed skills – <iteration>`),
- then one bullet list entry per skill with the following keys:

Required keys (for every skill):

- `name`: short skill name (e.g. `frontend-runtime-sanity`)
- `source`: either `local` or the remote repository URL
- `local_path`: path under `skills/` where the skill is stored
- `iteration`: logical iteration label (e.g. `MVP`)

Optional keys (when applicable):

- `original_path`: path inside the source repository (for remote skills)
- `version`: branch/tag/commit used for installation
- `installed_at`: ISO-like date of installation (YYYY-MM-DD)

Example (abbreviated):

- name: frontend-runtime-sanity  
  source: local  
  local_path: skills/local/frontend-runtime-sanity  
  version: n/a (local)  
  installed_at: 2026-04-27  
  iteration: MVP  

Formatting details such as blank lines or section headings may vary, but the per-skill bullet entries and their keys MUST follow this structure so that tools and agents can reliably parse them.

### Regeneration rules

When applying this skill, the agent must:

1. **Detect lock state**
   - If `skills/skills.lock.md` is missing or clearly invalid (e.g. empty, unrelated content), treat it as needing regeneration.
2. **Rebuild from the actual skills**
   - Inspect the `skills/` directory and the active preset to determine which skills are installed.
   - Reconstruct the list of skills (local and remote) with their required keys.
3. **Write the lock file**
   - Generate a new `skills/skills.lock.md` using the canonical structure above.
   - Do not drop valid information that is available (e.g. known `version`, `original_path`).

The goal is that **any future iteration** can rely on `skills.lock.md` as a stable, parseable description of the installed skills set, even if the file has been deleted or corrupted between runs.

---

## Rules

- Only return verifiable skills
- Do not invent skills
- Prefer general-purpose and reusable skills
- Explicitly state limitations when relevant
- Never download or modify skills directly when only doing discovery: always let the agent present a shortlist and request explicit user confirmation before download
