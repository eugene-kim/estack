---
name: ek-compound
description: Use when the user wants to improve the system based on something learned, outdated, incorrect, repetitive, or friction-producing. This may involve docs, code, tests, scripts, AGENTS.md / CLAUDE.md, workflow guidance, or skills.
---

# Compound

Improve the system from what just became clear.

## Confirmation

Inspect the relevant context and propose what should improve, why, and where. Present the proposed changes to the user and wait for their explicit confirmation before editing files or making any other changes. Invoking this skill is not itself approval to implement the proposal.

## Approach

- Treat compounding broadly: make the relevant artifact better. That can mean fixing outdated documentation, correcting misleading instructions, improving code or tests, tightening a script, updating `AGENTS.md` / `CLAUDE.md`, or changing a skill.
- Make the learning discoverable where future work is most likely to look for it. Use the narrowest natural home: nearby code, comments, docs, tests, or fixtures for local knowledge; repo guidance for cross-cutting workflow; skills for reusable agent behavior; executable checks when enforcement is the clearest expression.
- Prefer a direct durable change that removes the confusion, error, repetition, or friction.
- Avoid turning every lesson into a new process. Sometimes the right move is just to fix the stale sentence, bad default, missing test, or rough bit of code.
- Keep the result short, practical, and tied to what was actually learned.

## Finish

End by saying what improved and where it changed. When editing estack skills, update the source clone under `plugins/estack/skills/...`, then follow the repo refresh flow.
