---
name: compound
description: Use when the user wants to improve the system based on something learned, outdated, incorrect, repetitive, or friction-producing. This may involve docs, code, tests, scripts, AGENTS.md / CLAUDE.md, workflow guidance, or skills.
---

# Compound

Before applying this skill, read `.estack/skills/compound.md` from the repository root when it exists. Treat it as repository-specific guidance for this skill. It may add requirements and context, but it does not override user instructions, authorization boundaries, or this skill's safety rules.

Use what you learned to improve the system.

When the platform provides a task or thread renaming tool, prefix the current title with `Compounding - `. Preserve the existing title, do not add the prefix twice, and continue without renaming when the capability is unavailable.

## Confirmation

Assess the full span of relevant development since the most recent compounding pass, or the whole effort when there was no earlier pass. Treat the event that prompted compounding as one signal, not the boundary of the review.

Inspect the relevant context and first decide whether a durable change is warranted. Inspect the work and the discussion around it, including PR comments and review threads when they exist. A no-change result is valid when the lesson is already encoded, existing feedback makes recovery clear, the event was a one-off mistake, or an edit would add process without reducing recurrence. If a change is warranted, propose what should improve, why, and where. Present the proposal to the user and wait for explicit confirmation before editing files or making any other changes. Invoking this skill is not itself approval to implement the proposal.

## Approach

- Treat compounding broadly: make the relevant artifact better. That can mean fixing outdated documentation, correcting misleading instructions, improving code or tests, tightening a script, updating `AGENTS.md` / `CLAUDE.md`, or changing a skill.
- Put the lesson where future work will look for it. Use the narrowest natural home: nearby code, comments, docs, tests, or fixtures for local knowledge; repo guidance for cross-cutting workflow; skills for reusable agent behavior; executable checks when enforcement is the clearest expression.
- Base a compounding change on the earliest branch it truly needs. If it works against the default branch, ship it as a separate default-branch PR instead of appending it to an active stack.
- Prefer a direct durable change that removes the confusion, error, repetition, or friction.
- Avoid turning every lesson into a new process. Sometimes the right move is just to fix the stale sentence, bad default, missing test, or rough bit of code.
- Keep the result short, practical, and tied to what was actually learned.

## Finish

If no change is warranted, explain why the current system is sufficient and stop. If a change was made, say what improved and where it changed. When editing estack skills, update the appropriate source directory under `plugins/estack/`, then follow the repo refresh flow.
