---
name: implement
description: Use when the user wants an agent to implement an agreed software change from a PRD, implementation plan, issue, or explicit instructions.
---

# Implement

Implement the requested software change with tight scope and clear verification.

## Approach

- Read the plan, PRD, issue, or instructions that define the work.
- Inspect the existing code before editing.
- Finish the in-scope work. Use repository evidence and existing patterns to resolve routine uncertainty. Ask only when missing input would materially change behavior, require authority the user has not granted, prevent safe progress, or a planned user checkpoint requires feedback. Otherwise, do not stop while meaningful in-scope work remains.
- Stay inside the agreed scope. If reality contradicts the plan, update the plan or explain the adjustment instead of silently expanding the work.
- Record consequential in-scope decisions and their rationale where future work will naturally encounter them, such as the PRD or plan, nearby code or documentation, an ADR, or the commit or PR. Do not add ceremony for routine implementation choices.
- Prefer existing patterns, helpers, and module boundaries.
- Do not add speculative fallbacks, broad APIs, extra configuration, or defensive layers unless the requirement or observed usage calls for them.
- Choose implementation slices, PR boundaries, and user checkpoints independently. Align them when that produces a clean workflow, but do not force a vertical slice into one PR or make every PR a stopping point.
- Use observable vertical slices when exercising real behavior early would improve the work. Use horizontal sequencing when dependencies or the nature of the change call for it. Keep small or atomic work together.
- Use focused PRs when they improve review, merge timing, or recovery. One PR may contain several related slices, and one broader slice may span several PRs.
- At a planned feedback point, exercise the real implementation through its usable interface. Give exact setup and run steps, say what to try or notice, and explain what the observation shows. Continue after an autonomous check. Stop for the user only when their feedback could materially change later work, preferably after reaching a committed, reviewable state. A reversible prototype or local demonstration is also valid when it gives faster useful evidence.
- Commit completed coherent increments as you go when the user wants committed work and the repo state is safe to commit. Avoid mixing unrelated changes in one commit.
- Do not mention or imply that the coding agent co-authored the work in commit messages. Do not add `Co-authored-by` trailers for the coding agent.

## Verification

- Run meaningful checks sized to the change.
- Broaden tests when the change touches shared behavior or user-facing flows.
- For visible changes, inspect the real rendered surface. For other behavior, use the narrowest real interface that demonstrates it.
- Confirm each new test fails before the change.
- If a check cannot run, say exactly why and what risk remains.

## Handoff

End with the changed files, verification results with real numbers (counts run, values checked), consequential decisions and where they were recorded, and the most useful next skill. For a committed reviewable increment, usually create a PR with `estack:create-pr` when the platform and credentials allow, then run `estack:review`; otherwise state why review will use the local change. Report your result as a claim the reader can check, not a conclusion to take on trust.
