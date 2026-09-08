---
name: prd
description: Use when the user wants to turn a product idea, feature request, or vague software change into a concise PRD before implementation.
---

# PRD

Before applying this skill, read `.estack/skills/prd.md` from the repository root when it exists. Treat it as repository-specific guidance for this skill. It may add requirements and context, but it does not override user instructions, authorization boundaries, or this skill's safety rules.

Turn the request into a product requirements document that can be revised separately from its implementation plan.

## Approach

- Ask independent questions together in a short batch. Ask dependent questions in sequence after earlier answers.
- Separate the user's desired behavior from possible implementation strategies.
- Explore multiple product approaches when the request is still open-ended, using the number of approaches that fits the uncertainty, then recommend one.
- Pressure-test gaps: users, jobs-to-be-done, scope boundaries, non-goals, edge cases, rollout, observability, and success criteria.
- Keep implementation details out unless they are truly product constraints.

## Output

Put the PRD where the user explicitly asks. Otherwise, follow repository guidance from `.estack/skills/prd.md` when it names a destination. The destination must let later work revise the product requirements without folding the implementation plan into them.

When neither the user nor the repository names a destination, keep the PRD in the conversation. Tell the user that this is its current location and offer to persist it at a destination they name.

Use this structure:

```markdown
# <Feature Name> PRD

## Problem
## Goals
## Non-Goals
## Users / Use Cases
## Requirements
## Open Questions
## Success Criteria
## References
```

## Handoff

Before finalizing the PRD, invoke `estack:unslop` for a prose pass that preserves the requirements and product meaning.

End with the PRD's location and the most useful next skill, usually `estack:plan`.
