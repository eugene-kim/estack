---
name: ek-manage-pr
description: Use when the user wants an agent to manage an existing pull request after implementation, including review feedback, CI failures, PR notes, and merge readiness.
---

# Manage PR

Move an existing pull request toward merge readiness.

## Approach

- Inspect the PR, branch, diff, checks, and review comments using the platform's supported tools.
- Synthesize findings before acting. Decide whether each one needs a fix, an answer, deferral, or rejection with evidence; make or delegate implementation work only after that decision.
- Address actionable review feedback. If feedback is ambiguous, ask a targeted question or state the assumption before changing code.
- When a review thread has been answered, fixed, or otherwise handled, resolve the thread using the PR platform's supported mechanism.
- Debug CI from logs and reproduced failures, not guesses.
- Keep fixes scoped to the failing check or review thread.
- Update the PR description or notes when the change history needs to be understandable.
- Preserve the dispositions of prior findings, resolved-thread context, new commits, and current diff for a later review pass.
- When another review pass begins, replace any existing review-status label with `ai-review:in-progress` when the platform supports labels and access permits.
- Loop until the PR is merge-ready or needs a user decision. Let `ek-dev` enforce its review-cycle limit when it coordinates the workflow.

## Output

End with:

- PR URL or branch
- addressed review items
- resolved review threads
- current CI/check status
- remaining blockers, if any
- commits pushed, if any
