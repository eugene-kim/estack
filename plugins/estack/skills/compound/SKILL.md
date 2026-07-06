---
name: compound
description: Use when the user wants to improve the system based on something learned, outdated, incorrect, repetitive, or friction-producing. This may involve docs, code, tests, scripts, AGENTS.md / CLAUDE.md, workflow guidance, or skills.
---

# Compound

Improve the system from what just became clear.

## Approach

- Treat compounding broadly: make the relevant artifact better. That can mean fixing outdated documentation, correcting misleading instructions, improving code or tests, tightening a script, updating `AGENTS.md` / `CLAUDE.md`, or changing a skill.
- Put the improvement where future work will naturally encounter it.
- Prefer a direct durable change that removes the confusion, error, repetition, or friction.
- Avoid turning every lesson into a new process. Sometimes the right move is just to fix the stale sentence, bad default, missing test, or rough bit of code.
- Keep the result short, practical, and tied to what was actually learned.

## Finish

End by saying what improved and where it changed. When editing estack skills, update the source clone under `plugins/estack/skills/...`, then follow the repo refresh flow.
