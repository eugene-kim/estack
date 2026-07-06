---
name: dev-cycle
description: Use when the user wants an autonomous software development cycle from requirements through plan, development, review, PR management, and reflection.
---

# Dev Cycle

Run the software development cycle end to end, using the phase skills as the rails.

## Phases

1. `prd` - clarify the product need and create or identify the requirements artifact.
2. `implementation-plan` - turn requirements into a grounded engineering plan.
3. `implement` - implement the plan with narrow scope and verification.
4. `simplify` - refine recently modified code for clarity while preserving behavior.
5. `review` - review the resulting diff for correctness and missing tests.
6. `manage-pr` - handle PR publication, feedback, CI, and merge readiness when a PR exists or is requested.
7. `compound` - improve the relevant artifact when the work reveals a useful lesson, correction, or source of friction.

## Operating rules

- Start at the earliest phase that is not already done. If the user provides a PRD or plan, consume it instead of recreating it.
- Keep phase artifacts linked. Each phase should reference the artifact it consumed.
- Ask only the questions that block useful progress. Prefer making reversible assumptions and recording them.
- Do not invent requirements, APIs, fallbacks, abstractions, or edge-case handling beyond what the evidence supports.
- Stop and report when the next action requires user permission, external access, unavailable credentials, or a product decision.
- When the platform supports delegated agents, use them for independent review or parallel investigation; otherwise run the phases directly.

## Output

Maintain a short phase log in the conversation:

```markdown
- PRD: pending / done / skipped
- Plan: pending / done / skipped
- Implement: pending / done / skipped
- Simplify: pending / done / skipped
- Review: pending / done / skipped
- PR: pending / done / skipped
- Compound: pending / done / skipped
```

End with the final artifact links, verification status, PR status if relevant, and any captured follow-up.
