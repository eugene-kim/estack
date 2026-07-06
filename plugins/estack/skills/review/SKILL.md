---
name: review
description: Use when the user asks for a code review, pre-merge review, regression check, or critique of an implementation.
---

# Review

Review the actual diff for bugs, regressions, missing tests, and scope drift.

## Approach

- Inspect the diff and the surrounding code needed to understand behavior.
- Prioritize correctness, data loss, security, concurrency, migration risk, user-visible regressions, and missing tests.
- Check whether the implementation matches the PRD, plan, issue, or user request.
- Avoid style-only comments unless they hide a real maintainability risk.
- If there are no findings, say so clearly and name any residual risk or unrun checks.

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
