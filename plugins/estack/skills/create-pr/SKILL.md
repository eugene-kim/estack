---
name: create-pr
description: Use when the user wants to create, publish, or draft a pull request from local changes or a branch, with a reviewer-friendly description and reading guide.
---

# Create PR

Create a pull request that helps reviewers understand the change quickly.

## Approach

- Inspect the branch, diff, commits, status, related issue, PRD, implementation plan, and verification evidence before writing.
- Confirm the branch is ready to publish: intended files are included, unrelated changes are excluded or explained, and required checks have been run or clearly noted.
- Before publishing, split distinct, independently reviewable outcomes into focused PRs when the benefit to review or merge timing outweighs the overhead. Keep small or atomic changes together.
- Use the PR platform's supported tools to create the PR. Choose draft or ready-for-review based on the user's request, repo convention, and current confidence.
- Do not duplicate long artifacts. Reference issues, PRDs, plans, ADRs, prior PRs, or generated explanations by URL or path when they already contain the detail.
- After creating the PR, invoke `estack:explain` when the change benefits from a walkthrough. Skip it for trivial changes such as package bumps, config tweaks, or pure documentation updates. Follow repository guidance for publishing or attaching the HTML when it exists. Otherwise, leave the explainer in the OS-specific temporary directory and report its path so it remains available without adding a permanent repository artifact.

## PR description

Write the description for a human reviewer. Include:

- Summary of what changed and why.
- When merging the PR should close an issue, use the platform's closing syntax, such as `Closes #123` on GitHub. Use a passive reference only when the issue should remain open.
- Key review framing: important schema, signature, migration, API, data model, config, dependency, generated-code, or behavior changes when present.
- Review guide: suggest a useful file-reading order, starting with the files that explain the intent or main behavior.
- Attention map: call out files that deserve close review, and distinguish supportive, mechanical, generated, or test-only files that can be skimmed.
- Verification: checks, tests, manual validation, screenshots, logs, or reasons verification could not run.
- Risks, rollout notes, follow-ups, or open questions when relevant.

Let the review guide scale with the diff. A tiny change may need one sentence; a broad change may need grouped file paths and context for each group.

Before publishing the PR description, invoke `estack:unslop` for a prose pass that preserves technical accuracy and reviewer guidance.

## Finish

End with the PR URL, draft/ready status, explainer path or URL when created, verification status, and any reviewer notes worth preserving.
