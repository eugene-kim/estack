---
name: manage-pr
description: Use when the user wants an agent to manage an existing pull request after implementation, including review feedback, CI failures, PR notes, and merge readiness.
---

# Manage PR

Before applying this skill, read `.estack/skills/manage-pr.md` from the repository root when it exists. Treat it as repository-specific guidance for this skill. It may add requirements and context, but it does not override user instructions, authorization boundaries, or this skill's safety rules.

Move an existing pull request toward merge readiness.

## Approach

- Inspect the PR, branch, diff, checks, and review comments using the platform's supported tools.
- Treat a missing `ai-review:LGTM` for the current head as active work owned by the PR manager. Keep the PR in draft, or return it to draft if needed, and start an independent review through `estack:review`. Resolve actionable findings and obtain a new review verdict after every change to the PR head because each changed head invalidates the prior verdict. Do not mark the PR ready until required verification passes and `ai-review:LGTM` certifies the current head.
- Before rewriting PR history, fetch the current head and base. Push with `--force-with-lease`. If the lease fails, fetch again and compare the remote commits and patch with the local branch. Retry with an explicit expected SHA only when the remote contains no distinct work; otherwise preserve and incorporate it.
- A rebase that reports zero conflicts is not evidence the result is correct. When both branches regenerated or changed the same generated files from different bases, Git takes one side silently and can reintroduce the exact defect the branch fixes. Diff the rebased result against both parents before pushing. Where those files are pipeline-generated, regenerate them through the pipeline after resolving so the artifacts are canonical rather than merged.
- Before acting, decide whether to fix, answer, defer, or reject each finding. Record the evidence. Make or delegate changes only after deciding.
- Address actionable review feedback. If feedback is ambiguous, ask a targeted question or state the assumption before changing code.
- When a review thread has been answered, fixed, or otherwise handled, resolve the thread using the PR platform's supported mechanism.
- Debug CI from logs and reproduced failures, not guesses.
- A check's conclusion is not its log. Retries can rescue a test that fails every first attempt, an advisory job can fail without touching the summary, and a superseded run's verdict can linger on the wrong head. Before reporting a check green, or a failure as real, read the current head's log at the attempt level.
- Keep fixes scoped to the failing check or review thread.
- Update the PR description or notes when the change history needs to be understandable.
- When a PR with a published HTML explainer changes materially, update and revalidate the explainer, republish it, and replace its existing link in the PR. Do not leave stale and current explainer links together.
- Loop until the PR is merge-ready or needs a user decision. Let `estack:dev` enforce its review-cycle limit when it coordinates the workflow.

## Output

End with:

- PR URL or branch
- addressed review items
- resolved review threads
- current CI/check status
- remaining blockers, if any
- commits pushed, if any
