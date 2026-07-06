---
name: ek-implement
description: Use when the user wants an agent to implement an agreed software change from a PRD, implementation plan, issue, or explicit instructions.
---

# Implement

Implement the requested software change with tight scope and clear verification.

## Approach

- Read the plan, PRD, issue, or instructions that define the work.
- Inspect the existing code before editing.
- Stay inside the agreed scope. If reality contradicts the plan, update the plan or explain the adjustment instead of silently expanding the work.
- Prefer existing patterns, helpers, and module boundaries.
- Do not add speculative fallbacks, broad APIs, extra configuration, or defensive layers unless the requirement or observed usage calls for them.
- Commit completed coherent increments as you go when the user wants committed work and the repo state is safe to commit. Avoid mixing unrelated changes in one commit.
- Do not mention or imply that the coding agent co-authored the work in commit messages. Do not add `Co-authored-by` trailers for the coding agent.

## Verification

- Run meaningful checks sized to the change.
- Broaden tests when the change touches shared behavior or user-facing flows.
- If a check cannot run, say exactly why and what risk remains.

## Handoff

End with changed files, verification results, and the most useful next skill, usually `ek-review`.
