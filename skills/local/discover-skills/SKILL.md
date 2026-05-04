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
- Current skill sets:
  - skills/skills-set.md

---

## Process

1. **Read current skill sets**
   - Read `skills/skills-set.md` to identify already installed skills.
   - Avoid recommending skills already present.

2. **Analyse the iteration context**
   - Extract key elements from `architecture.md` and the user request:
     - domain (frontend, backend, fullstack, infra, etc.)
     - target stack (frameworks, languages, services)
     - quality and tooling constraints (tests, CI, monitoring, etc.)
     - roadmap focus (which iteration from `business.md` is targeted)

3. **Search for complementary skills**
   - Look for additional candidate skills in trusted sources:
     - https://officialskills.sh/
     - https://github.com/VoltAgent/awesome-agent-skills (community registry)
     - Verified GitHub repositories — confirmed sources used in this project:
       - https://github.com/vercel-labs/agent-skills
       - https://github.com/anthropics/skills
       - https://github.com/openclaw/skills (skill path prefix: `skills/anivar/`)
       - https://github.com/wshobson/agents (skill path prefix: `plugins/developer-essentials/skills/`)
       - https://github.com/deanpeters/Product-Manager-Skills (skill path prefix: `skills/`)
       - https://github.com/softaworks/agent-toolkit (skill path prefix: `skills/`)
       - https://skillkit.io/skills/claude-code/ (bas/ skills)
       - https://skillsmp.com/skills/ (bagustris/ skills)
   - For each candidate, identify:
     - name
     - source
     - short description
     - scope
   - **Always verify** that the SKILL.md exists at the resolved URL before recommending a skill

4. **Evaluate overall relevance**
   - For each discovered skill, evaluate:
     - alignment with `business.md` and `architecture.md`
     - coverage of requested capabilities for the targeted roadmap iteration
   - Keep the final set reasonable (typically 3–5 main skills plus at most 1–2 well-justified complementary skills).

5. **Prepare the final proposal**
   - Build a structured shortlist with:
     - skill name
     - source
     - justification
     - suggested path under `skills/<source>/<skill-name>/`

---

## Output

Return a structured shortlist. On user validation, the agent downloads each skill under `skills/<source>/<skill-name>/` and adds it to the appropriate set in `skills/skills-set.md`.

---

## Rules

- Only return verifiable skills
- Do not invent skills
- Prefer general-purpose and reusable skills
- Explicitly state limitations when relevant
- Never download or modify skills without explicit user confirmation

