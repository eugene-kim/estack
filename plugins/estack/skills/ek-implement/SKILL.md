---
name: ek-implement
description: Use when the user wants an agent to implement an agreed software change from a PRD, implementation plan, issue, or explicit instructions.
---

# Implement

Implement the requested software change with tight scope and clear verification.

## Approach

- Read the plan, PRD, issue, or instructions that define the work.
- Inspect the existing code before editing.
- Work autonomously toward a complete implementation. Resolve routine uncertainty through repository evidence, existing patterns, and reasonable in-scope judgment. Ask the user only when missing input would materially change the intended behavior, require authority the user has not granted, or make safe progress impossible. Do not stop at a proposal, partial implementation, or list of next steps while meaningful in-scope work remains.
- Stay inside the agreed scope. If reality contradicts the plan, update the plan or explain the adjustment instead of silently expanding the work.
- Record consequential in-scope decisions and their rationale where future work will naturally encounter them, such as the PRD or plan, nearby code or documentation, an ADR, or the commit or PR. Do not add ceremony for routine implementation choices.
- Prefer existing patterns, helpers, and module boundaries.
- Do not add speculative fallbacks, broad APIs, extra configuration, or defensive layers unless the requirement or observed usage calls for them.
- Commit completed coherent increments as you go when the user wants committed work and the repo state is safe to commit. Avoid mixing unrelated changes in one commit.
- Do not mention or imply that the coding agent co-authored the work in commit messages. Do not add `Co-authored-by` trailers for the coding agent.

## Verification

- Run meaningful checks sized to the change.
- Broaden tests when the change touches shared behavior or user-facing flows.
- For each new test, confirm it fails without the change; a test that passes either way proves nothing.
- If a check cannot run, say exactly why and what risk remains.

## Handoff

End with the changed files, verification results with real numbers (counts run, values checked), consequential decisions and where they were recorded, and the most useful next skill, usually `ek-review`. Report your result as a claim the reader can check, not a conclusion to take on trust.
