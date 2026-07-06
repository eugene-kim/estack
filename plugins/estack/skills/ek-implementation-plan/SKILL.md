---
name: ek-implementation-plan
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
- Include a verification step in every plan. Say what checks, tests, inspections, or manual validation would give confidence that the change works.
- For non-trivial tasks, have agent(s) adversarially review the plan before implementation. Choose review scope based on task risk, ask them to look for incorrect assumptions, missed requirements, overreach, sequencing problems, and missing verification, then iterate on the plan.

## Output

Create a plan artifact where it best fits the work. Keep it in the conversation, a temporary file, an issue, a PR description, or another workspace when it is mainly a working artifact. Save it in the repo only when future work should treat it as durable project knowledge.

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

End with the plan location or summary, adversarial review status for non-trivial work, the verification step, and the most useful next skill, usually `ek-implement`.
