---
name: ek-simplify
description: Use when the user asks to simplify, refine, clean up, or improve recently modified code for clarity, consistency, and maintainability while preserving behavior.
---

# Simplify

Refine code without changing what it does.

## Approach

- Focus on code recently modified or touched in the current session unless the user asks for a broader pass.
- Preserve functionality exactly: original features, outputs, side effects, public interfaces, data shapes, and error behavior should remain intact.
- Read and follow the project's own standards, conventions, formatter, linter, tests, `AGENTS.md`, `CLAUDE.md`, and nearby code patterns.
- Prefer readable, explicit code over clever or overly compact code.
- Reduce unnecessary complexity, duplication, nesting, indirection, and dead weight.
- Improve names, structure, and grouping when doing so makes the code easier to understand.
- Remove comments that merely restate obvious code; keep or improve comments that explain non-obvious intent, constraints, or tradeoffs.
- Avoid nested ternary operators and dense one-liners when a straightforward branch or helper would be clearer.
- Keep helpful abstractions that make the code easier to reason about; remove abstractions that only hide simple logic.
- Do not add speculative fallbacks, APIs, configuration, validators, parsers, guards, or compatibility layers unless the existing requirements call for them.

## Process

- Identify the changed code and its tests.
- Inspect nearby project patterns before editing.
- Apply refinements whose scope matches the code and risk.
- Run meaningful checks sized to the change, broadening when the simplification touches shared behavior.
- If a possible simplification could change behavior or intent, leave it alone or call it out instead of guessing.

## Finish

End with what changed, why it is simpler, and what verification ran.
