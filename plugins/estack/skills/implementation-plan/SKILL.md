---
name: implementation-plan
description: Use when the user wants an implementation plan for a PRD, issue, feature request, bug, or code change before development.
---

# Implementation Plan

Turn agreed requirements into a concrete, testable engineering plan.

## Approach

- Read the PRD, issue, discussion, or code context that defines the work.
- Do not invent product behavior. If a requirement is missing, either ask or mark it as an explicit open question.
- Ground claims in repo evidence: cite files, APIs, tests, data paths, and constraints discovered while reading.
- Prefer a focused coherent change that satisfies the requirement.
- Avoid speculative APIs, fallbacks, validators, parsers, abstractions, or compatibility layers unless the requirement or observed usage demands them.
- Split the work into phases only when it reduces risk or enables review.

## Output

Write or update a plan at `docs/plans/YYYY-MM-DD-<slug>.md` unless the user asks for another location.

Use this structure:

```markdown
# <Change Name> Implementation Plan

## Inputs
## Current System
## Proposed Change
## Steps
## Tests / Verification
## Risks
## Open Questions
```

## Handoff

End with the plan path and the most useful next skill, usually `implement`.
