---
name: compound
description: Use when the user wants to capture reusable lessons, improve workflow instructions, or decide whether repeated work should become a skill.
---

# Compound

Turn repeated experience into lightweight reusable guidance.

## Approach

- Look for patterns that actually occurred more than once or caused enough friction to justify capture.
- Prefer updating the smallest existing instruction over creating a new skill.
- Create or expand a skill only when it will prevent future re-explanation or repeated mistakes.
- Do not encode one-off implementation details as permanent process.
- Keep new guidance short, tool-agnostic, and tied to observed use.

## Output

Produce one of:

- a proposed instruction change
- a new or updated skill
- a note that nothing should be captured yet

When editing estack itself, update the source clone under `plugins/estack/skills/...`, then follow the repo refresh flow.
