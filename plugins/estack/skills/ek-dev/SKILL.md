---
name: ek-dev
description: Use when the user wants an autonomous software development cycle from requirements through plan, development, review, PR management, and reflection.
disable-model-invocation: true
---

# Dev

Run the software development cycle end to end, using the phase skills as guides. Treat each independently reviewable increment as its own PR lifecycle when that improves review or merge timing.

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
3. `ek-implement` - implement a reviewable increment with narrow scope and verification.
4. `ek-create-pr` - create a reviewer-friendly PR with a clear description and reading guide when the platform and credentials allow.
5. `ek-review` - simplify recently modified code as useful, then review the PR or local change for correctness and missing tests.
6. `ek-manage-pr` - synthesize feedback, address it, maintain the PR conversation, and move the PR toward merge readiness.
7. `ek-compound` - after an increment merges, reflect on that completed loop and improve relevant artifacts when it reveals a useful lesson, correction, or source of friction.

## Increment loop

For each publishable increment, implement, create its PR, review it, and manage the resulting feedback before moving to the next increment. `ek-create-pr` owns PR-specific artifacts. A PR is the preferred review surface. When a PR cannot be created because the platform, credentials, or access are unavailable, review the local change and state why no PR exists.

Creating or updating a PR starts `ek-review` immediately. Do not wait for CI or ask whether to review: CI and review run together, and `ek-manage-pr` brings their results together. An increment is not complete, and the turn must not end, until its review has started.

Use the platform's built-in task tracker for meaningful multi-step work. Track the outcome and each substantial increment or PR with its scope, success conditions, current phase, and PR link when available. Keep it current as work moves between phases; do not create task noise for trivial work.

Review is a bounded loop:

1. The root agent runs `ek-review`, launching independent review agents as the change's size, complexity, and risk warrant. Use a multi-agent review workflow when the platform provides one and the change warrants it; this instruction authorizes it. The root agent synthesizes the findings.
2. The root agent uses `ek-manage-pr` to decide and carry out the response to each finding. It may delegate code changes, but owns the decisions, PR conversation, and thread resolution.
3. After `ek-manage-pr` addresses the relevant review threads, re-run `ek-review` on the current PR with fresh review agents when the changes or findings warrant another pass.

Allow two remediation-and-re-review cycles after the initial review. If material findings remain, stop and give the user a concise decision summary. Exceed the limit only at the user's request or when new evidence materially changes the work.

After an increment merges, give that completed increment its own `ek-compound` pass before starting the next one. Use the outcome, decisions, review findings, and friction from that one loop while they are fresh. Skip the pass when there is nothing worth capturing. If another person must merge the PR, leave compounding for that increment pending until it merges.

## Operating rules

- Start at the appropriate phase determined by the entry-point routing rules. Within that path, skip phases that are already complete. If the user provides a PRD or plan, consume it instead of recreating it.
- Keep phase artifacts linked. Each phase should reference the artifact it consumed.
- Ask only the questions that block useful progress. Prefer making reversible assumptions and recording them.
- Do not invent requirements, APIs, fallbacks, abstractions, or edge-case handling beyond what the evidence supports.
- Stop and report when the next action requires user permission or a product decision. When PR access is unavailable, continue with local review and record the limitation.
- When the platform supports delegated agents, use them for independent review or parallel investigation; otherwise run the phases directly.

## Output

Maintain a short phase log in the conversation:

```markdown
- PRD: pending / done / skipped
- Plan: pending / done / skipped
- Increments / PRs: <increment>: implement / PR / review / manage / merged / compound / done
```

End with the final artifact links, verification status, PR status if relevant, and any captured follow-up.
