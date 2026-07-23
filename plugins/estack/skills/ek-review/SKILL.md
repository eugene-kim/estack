---
name: ek-review
description: Use when the user asks for a code review, pre-merge review, regression check, or critique of an implementation.
---

# Review

Review the actual diff for bugs, regressions, missing tests, and scope drift. Prefer the pull request as the review surface when one exists; otherwise review the local change and state why no PR exists.

## Approach

- Inspect the diff and the surrounding code needed to understand behavior.
- Simplify recently modified code when it improves clarity, consistency, or maintainability without changing behavior. Keep that work within the review scope.
- Use adversarial review with separate agent(s). Choose their number and focus based on the size, complexity, and risk of the change, then synthesize their findings instead of treating any single pass as authoritative.
- Before reporting a finding, put it through an independent check that tries to refute it against the code, and report only what survives.
- Prioritize correctness, data loss, security, concurrency, migration risk, user-visible regressions, and missing tests.
- Check whether the implementation matches the PRD, plan, issue, or user request.
- Avoid style-only comments unless they hide a real maintainability risk.
- If there are no findings, say so clearly and name any residual risk or unrun checks.
- When the PR platform supports labels and access permits, maintain exactly one review-status label: set `ai-review:in-progress` when review begins; replace it with `ai-review:changes` for unresolved actionable findings or `ai-review:LGTM` when no such findings remain. Replace a prior status label rather than accumulating them.

## Output

Lead with findings ordered by severity. Include file and line references when possible.

Use this shape:

```markdown
## Findings

- [P1] <title> - <file:line>
  <why it matters and how to fix>

## Open Questions

## Summary
```

Keep the summary secondary to the findings.
