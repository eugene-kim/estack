---
name: compound
description: Use when the user wants to capture reusable lessons, improve docs, code, agent instructions, workflow guidance, or decide whether repeated work should become a skill.
---

# Compound

Turn repeated experience into durable improvements.

## Approach

- Look for patterns that actually occurred more than once or caused enough friction to justify capture.
- Decide where the lesson belongs before editing. It may belong in documentation, code, tests, scripts, `AGENTS.md` / `CLAUDE.md`, another repo instruction file, or a skill.
- Prefer the smallest durable change over creating a new skill.
- Create or expand a skill only when it will prevent future re-explanation or repeated mistakes.
- Do not encode one-off implementation details as permanent process.
- Keep new guidance short, tool-agnostic, and tied to observed use.

## Output

Produce one of:

- a documentation update
- a code, test, or script improvement
- a proposed instruction change
- a new or updated skill
- a note that nothing should be captured yet

When editing estack skills, update the source clone under `plugins/estack/skills/...`, then follow the repo refresh flow. When the right home is `AGENTS.md`, `CLAUDE.md`, docs, scripts, or code, edit that source file instead.
