---
name: develop
description: Use when the user wants an agent to implement an agreed software change from a PRD, implementation plan, issue, or explicit instructions.
---

# Develop

Implement the requested software change with tight scope and clear verification.

## Approach

- Read the plan, PRD, issue, or instructions that define the work.
- Inspect the existing code before editing.
- Stay inside the agreed scope. If reality contradicts the plan, update the plan or explain the adjustment instead of silently expanding the work.
- Prefer existing patterns, helpers, and module boundaries.
- Do not add speculative fallbacks, broad APIs, extra configuration, or defensive layers unless the requirement or observed usage calls for them.
- Keep commits coherent when the user wants the change committed.

## Verification

- Run the narrowest meaningful checks first.
- Broaden tests when the change touches shared behavior or user-facing flows.
- If a check cannot run, say exactly why and what risk remains.

## Handoff

End with changed files, verification results, and the most useful next skill, usually `review`.
