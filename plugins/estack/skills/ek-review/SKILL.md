---
name: ek-review
description: Use when the user asks for a code review, pre-merge review, regression check, or critique of an implementation.
---

# Review

Review the actual diff for bugs, regressions, missing tests, and scope drift.

## Approach

- Inspect the diff and the surrounding code needed to understand behavior.
- Prefer an independent Codex CLI review when `scripts/codex-review.sh` is available. Invoke it with the appropriate review target, such as `scripts/codex-review.sh --base main`. It uses the configured Terra reviewer at high reasoning.
- If the Codex CLI is unavailable, unauthenticated, or out of usage, continue with the independent review approach below. Do not silently substitute another Codex model; briefly note that the preferred Codex pass was unavailable.
- When the platform supports delegated agents, ask a team of independent agents to review the change. Choose the number and focus of agents based on the size, complexity, and risk of the change, then synthesize their findings instead of treating any single pass as authoritative.
- Before reporting a finding, put it through an independent check that tries to refute it against the code, and report only what survives.
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
