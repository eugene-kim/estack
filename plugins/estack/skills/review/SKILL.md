---
name: review
description: Use when the user asks for a code review, pre-merge review, regression check, or critique of an implementation.
---

# Review

Review the actual diff for bugs, regressions, missing tests, and scope drift. Prefer the pull request as the review surface when one exists; otherwise review the local change and state why no PR exists.

## Approach

- Inspect the diff and the surrounding code needed to understand behavior.
- Invoke `estack:simplify` when recently modified code would benefit from behavior-preserving cleanup. Keep that work within the review scope.
- Use adversarial review with separate agent(s). Choose their number and focus based on the size, complexity, and risk of the change, then synthesize their findings instead of treating any single pass as authoritative.
- When the change warrants another model family, include a reviewer from a different provider when available. From Codex, use `estack:claude-agent`; from Claude Code, use `estack:codex-agent`. If the external CLI is unavailable or out of usage, continue with independent reviewers in the current platform.
- Before reporting a finding, check the code for evidence that disproves it. Lead with findings that remain. Then report potential findings you ruled out and why.
- Prioritize correctness, data loss, security, concurrency, migration risk, user-visible regressions, and missing tests.
- Check whether the implementation matches the PRD, plan, issue, or user request.
- A change that sits under live pipelines, harnesses, or other operational surfaces is not merge-ready until those surfaces have run against it. The change's own tests prove it works in isolation, not that the system above it still runs.
- Call a failure pre-existing only after it reproduces on the base branch for the same cause — same error, same stack, matching environment. A baseline that fails for a different reason proves nothing.
- Avoid style-only comments unless they hide a real maintainability risk.
- If there are no findings, say so clearly and name any residual risk or unrun checks.
- The agent coordinating review owns the review state. Reviewer agents return findings; the coordinating agent synthesizes them and maintains the PR label and draft status.
- When the PR platform supports labels and access permits, maintain exactly one review-status label. Set `ai-review:in-progress` when review begins. Replace it with `ai-review:changes` for unresolved actionable findings or `ai-review:LGTM` when no such findings remain. The label is the authoritative outcome; comments may explain it but never replace it. When applying `ai-review:LGTM`, mark a complete and verified draft ready for review. If required verification remains, leave it draft; the coordinating agent remains responsible for marking it ready when verification passes.

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
