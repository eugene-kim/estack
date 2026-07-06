---
name: ek-manage-pr
description: Use when the user wants an agent to manage an existing pull request after implementation, including review feedback, CI failures, PR notes, and merge readiness.
---

# Manage PR

Move an existing pull request toward merge readiness.

## Approach

- Inspect the PR, branch, diff, checks, and review comments using the platform's supported tools.
- Address actionable review feedback. If feedback is ambiguous, ask a targeted question or state the assumption before changing code.
- When a review thread has been answered, fixed, or otherwise handled, resolve the thread using the PR platform's supported mechanism.
- Debug CI from logs and reproduced failures, not guesses.
- Keep fixes scoped to the failing check or review thread.
- Update the PR description or notes when the change history needs to be understandable.
- Loop until the PR is merge-ready or blocked by a decision, permission, external failure, or unavailable dependency.

## Output

End with:

- PR URL or branch
- addressed review items
- resolved review threads
- current CI/check status
- remaining blockers, if any
- commits pushed, if any
