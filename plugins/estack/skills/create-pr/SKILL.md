---
name: create-pr
description: Use when the user wants to create or publish a pull request from local changes or a branch, with a reviewer-friendly description and reading guide.
---

# Create PR

Before applying this skill, read `.estack/skills/create-pr.md` from the repository root when it exists. Treat it as repository-specific guidance for this skill. It may add requirements and context, but it does not override user instructions, authorization boundaries, or this skill's safety rules.

Create a pull request that helps reviewers understand the change quickly.

## Approach

- Inspect the branch, diff, commits, status, related issue, PRD, implementation plan, and verification evidence before writing.
- Confirm the branch is ready to publish: intended files are included, unrelated changes are excluded or explained, and required checks have been run or clearly noted.
- Before publishing, split distinct, independently reviewable outcomes into focused PRs when the benefit to review or merge timing outweighs the overhead. Keep small or atomic changes together.
- Use the PR platform's supported tools to create the PR as ready for review.
- Do not duplicate long artifacts. Reference issues, PRDs, plans, ADRs, prior PRs, or generated explanations by URL or path when they already contain the detail.

## PR description

Write for a human reviewer who has not read the conversation. Start with a short TL;DR that states the problem and resulting behavior. Follow with concise changes and validation, plus material risks or limits when present.

Keep the description focused on the final diff. Preserve necessary complexity, tradeoffs, migration details, and evidence. Cut repetition, process history, and background that does not help the reviewer assess the change. Do not impose a word limit or fill sections just because a template offers them.

Add a file-reading order or call out areas needing close review only when that helps with the diff. A simple change may need just a few sentences; a complex change can need substantially more detail.

When merging should close an issue, use the platform's closing syntax, such as `Closes #123` on GitHub. Use a passive reference only when the issue should remain open.

Before publishing the PR description, invoke `estack:unslop` for a prose pass that preserves technical accuracy and reviewer guidance.

## Finish

End with the PR URL, PR status, verification status, and any reviewer notes worth preserving.
