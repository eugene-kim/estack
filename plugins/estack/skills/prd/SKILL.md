---
name: prd
description: Use when the user wants to turn a product idea, feature request, or vague software change into a concise PRD before implementation.
---

# PRD

Turn the request into a durable product requirements document.

## Approach

- Ask independent questions together in a short batch. Ask dependent questions in sequence after earlier answers.
- Separate the user's desired behavior from possible implementation strategies.
- Explore multiple product approaches when the request is still open-ended, using the number of approaches that fits the uncertainty, then recommend one.
- Pressure-test gaps: users, jobs-to-be-done, scope boundaries, non-goals, edge cases, rollout, observability, and success criteria.
- Keep implementation details out unless they are truly product constraints.

## Output

Write or update a PRD at `docs/prds/YYYY-MM-DD-<slug>.md` unless the user asks for another location.

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

End with the PRD path and the most useful next skill, usually `estack:plan`.
