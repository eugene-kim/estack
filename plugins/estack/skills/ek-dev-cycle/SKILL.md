---
name: ek-dev-cycle
description: Use when the user wants an autonomous software development cycle from requirements through plan, development, review, PR management, and reflection.
---

# Dev Cycle

Run the software development cycle end to end, using the phase skills as the rails.

## Phases

1. `ek-prd` - clarify the product need and create or identify the requirements artifact.
2. `ek-implementation-plan` - turn requirements into a grounded engineering plan.
3. `ek-implement` - implement the plan with narrow scope and verification.
4. `ek-simplify` - refine recently modified code for clarity while preserving behavior.
5. `ek-review` - review the resulting diff for correctness and missing tests.
6. `ek-create-pr` - create a reviewer-friendly PR with a clear description and reading guide when publication is requested.
7. `ek-manage-pr` - handle PR feedback, CI, and merge readiness after a PR exists.
8. `ek-compound` - improve the relevant artifact when the work reveals a useful lesson, correction, or source of friction.

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
- Create PR: pending / done / skipped
- Manage PR: pending / done / skipped
- Compound: pending / done / skipped
```

End with the final artifact links, verification status, PR status if relevant, and any captured follow-up.
