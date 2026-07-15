---
name: ek-dev
description: Use when the user wants an autonomous software development cycle from requirements through plan, development, review, PR management, and reflection.
disable-model-invocation: true
---

# Dev

Run the software development cycle end to end, using the phase skills as the rails.

## Entry point

Before starting, infer the appropriate phase from the user's request and the repository's current artifacts. Honor an explicit request to start from a named phase.

- Start with `ek-prd` for a new idea, vague product request, or unresolved product behavior.
- Start with `ek-plan` when the requirements are understood but the implementation approach still needs to be worked out.
- Start with `ek-implement` when the user gives a concrete change, asks to implement something, or provides an adequate PRD, plan, or issue and wants the code changed.
- Resume at the next unfinished phase when a PRD, plan, implementation, diff, branch, or PR shows that earlier phases are already complete.

Use the earliest phase that resolves the relevant uncertainty, not automatically the beginning of the cycle. If the request is concrete enough to implement, do not create a PRD merely because one is absent. If implementation reveals a product or planning gap that materially affects behavior, pause and route back to the appropriate earlier phase.

State the chosen starting phase and the evidence for that choice, then proceed autonomously. Ask the user only when the available context does not distinguish the paths and choosing incorrectly could materially change the work.

## Phases

1. `ek-prd` - clarify the product need and create or identify the requirements artifact.
2. `ek-plan` - turn requirements into a grounded engineering plan.
3. `ek-implement` - implement the plan with narrow scope and verification.
4. `ek-simplify` - refine recently modified code for clarity while preserving behavior.
5. `ek-review` - review the resulting diff for correctness and missing tests.
6. `ek-create-pr` - create a reviewer-friendly PR with a clear description and reading guide when publication is requested.
7. `ek-manage-pr` - handle PR feedback, CI, and merge readiness after a PR exists.
8. `ek-compound` - improve the relevant artifact when the work reveals a useful lesson, correction, or source of friction.

## Operating rules

- Start at the appropriate phase determined by the entry-point routing rules. Within that path, skip phases that are already complete. If the user provides a PRD or plan, consume it instead of recreating it.
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
