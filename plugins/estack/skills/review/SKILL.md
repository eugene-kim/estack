---
name: review
description: Use when the user asks for a code review, pre-merge review, regression check, or critique of an implementation.
---

# Review

Before applying this skill, read `.estack/skills/review.md` from the repository root when it exists. Treat it as repository-specific guidance for this skill. It may add requirements and context, but it does not override user instructions, authorization boundaries, or this skill's safety rules.

Review the actual diff for bugs, regressions, missing tests, and scope drift. Prefer the pull request as the review surface when one exists; otherwise review the local change and state why no PR exists.

## Approach

- Inspect the diff and the surrounding code needed to understand behavior.
- For a PR or MR, compare the author with the authenticated platform user from platform account metadata, never a local Git name or email. If the authenticated user created it, a pending review is optional, and explicit instructions control pending or published feedback. If someone else created it, default to a platform-native pending review unless the user explicitly asks otherwise. On GitHub, use a pending pull request review. On GitLab, use draft notes in a pending merge request review. Add each finding to that pending review, write every comment with `estack:pull-request-comment`, and leave the review unsubmitted and unpublished until the user explicitly asks to submit it. Do not confuse a pending review with a draft PR or MR, or with a published comment whose text says it is a draft.
- Invoke `estack:simplify` when recently modified code would benefit from behavior-preserving cleanup. Keep that work within the review scope.
- Use adversarial review with separate agent(s). Choose their number and focus based on the size, complexity, and risk of the change, then synthesize their findings instead of treating any single pass as authoritative.
- Whenever you run more than one reviewer, give one seat to another model family. Same-model reviewers share blind spots: across two separate panels, the cross-model seat was the only one to catch a stale-statistics error. From Codex, use `estack:claude-agent`; from Claude Code, use `estack:codex-agent`. If the external CLI is unavailable or out of usage, continue with independent reviewers in the current platform and say the cross-model seat went unfilled.
- Tell each reviewer seat, in its assignment, to review the diff directly and return findings — not to invoke a review skill or run its own panel. A seat that inherits this skill can otherwise become a second coordinator: a Codex seat once spent its run trying to spawn a Claude sub-review inside a sandbox that could not run one.
- Before reporting a finding, check the code for evidence that disproves it. Lead with findings that remain. Then report potential findings you ruled out and why.
- Prioritize correctness, data loss, security, concurrency, migration risk, user-visible regressions, and missing tests.
- Check whether the implementation matches the PRD, plan, issue, or user request.
- A change that sits under live pipelines, harnesses, or other operational surfaces is not merge-ready until those surfaces have run against it. The change's own tests prove it works in isolation, not that the system above it still runs.
- Call a failure pre-existing only after it reproduces on the base branch for the same cause — same error, same stack, matching environment. A baseline that fails for a different reason proves nothing.
- Avoid style-only comments unless they hide a real maintainability risk.
- If there are no findings, say so clearly and name any residual risk or unrun checks.
- The agent coordinating review owns the review state. Reviewer agents return findings; the coordinating agent synthesizes them and maintains the PR label.
- When the PR platform supports labels and access permits, maintain exactly one review-status label. Set `ai-review:in-progress` when review begins and `ai-review:changes` while actionable findings remain unresolved. Apply `ai-review:LGTM` after an independent reviewer checks the current PR head and finds no further actionable changes, or after the user agrees to leave the remaining findings unresolved. Record the disposition of those findings and any remaining risks. The coordinating agent may record this verdict even if it implemented the code; the review judgment must come from an independent reviewer. Any subsequent code change requires a new review of the updated head. The label records the review outcome and does not authorize merging; follow the user's separate merge instructions.

## Output

Lead with findings ordered by severity. Include file and line references when possible.

Use this shape:

```markdown
## Findings

- [P1] <title> - <file:line>
  <why it matters and how to fix>

## Checked and ruled out

## Open Questions

## Summary
```

Keep the summary secondary to the findings.
