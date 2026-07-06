---
name: ek-create-pr
description: Use when the user wants to create, publish, or draft a pull request from local changes or a branch, with a reviewer-friendly description and reading guide.
---

# Create PR

Create a pull request that helps reviewers understand the change quickly.

## Approach

- Inspect the branch, diff, commits, status, related issue, PRD, implementation plan, and verification evidence before writing.
- Confirm the branch is ready to publish: intended files are included, unrelated changes are excluded or explained, and required checks have been run or clearly noted.
- Use the PR platform's supported tools to create the PR. Choose draft or ready-for-review based on the user's request, repo convention, and current confidence.
- Do not duplicate long artifacts. Reference issues, PRDs, plans, ADRs, prior PRs, or generated explanations by URL or path when they already contain the detail.

## PR description

Write the description for a human reviewer. Include:

- Summary of what changed and why.
- Key review framing: important schema, signature, migration, API, data model, config, dependency, generated-code, or behavior changes when present.
- Review guide: suggest a useful file-reading order, starting with the files that explain the intent or main behavior.
- Attention map: call out files that deserve close review, and distinguish supportive, mechanical, generated, or test-only files that can be skimmed.
- Verification: checks, tests, manual validation, screenshots, logs, or reasons verification could not run.
- Risks, rollout notes, follow-ups, or open questions when relevant.

Let the review guide scale with the diff. A tiny change may need one sentence; a broad change may need grouped file paths and context for each group.

## Finish

End with the PR URL, draft/ready status, verification status, and any reviewer notes worth preserving.
