---
name: ek-compound
description: Use when the user wants to improve the system based on something learned, outdated, incorrect, repetitive, or friction-producing. This may involve docs, code, tests, scripts, AGENTS.md / CLAUDE.md, workflow guidance, or skills.
---

# Compound

Use what you learned to improve the system.

## Confirmation

Inspect the relevant context and propose what should improve, why, and where. Present the proposed changes to the user and wait for their explicit confirmation before editing files or making any other changes. Invoking this skill is not itself approval to implement the proposal.

## Approach

- Treat compounding broadly: make the relevant artifact better. That can mean fixing outdated documentation, correcting misleading instructions, improving code or tests, tightening a script, updating `AGENTS.md` / `CLAUDE.md`, or changing a skill.
- Put the lesson where future work will look for it. Use the narrowest natural home: nearby code, comments, docs, tests, or fixtures for local knowledge; repo guidance for cross-cutting workflow; skills for reusable agent behavior; executable checks when enforcement is the clearest expression.
- Prefer a direct durable change that removes the confusion, error, repetition, or friction.
- Avoid turning every lesson into a new process. Sometimes the right move is just to fix the stale sentence, bad default, missing test, or rough bit of code.
- Keep the result short, practical, and tied to what was actually learned.

## Finish

End by saying what improved and where it changed. When editing estack skills, update the source clone under `plugins/estack/skills/...`, then follow the repo refresh flow.
