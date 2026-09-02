---
name: codex-usage
description: Show the current Codex account usage, remaining allowance, reset times, plan, model-specific limits, and extra-credit state. Use when the user asks how much Codex usage remains or when usage resets.
---

# Codex Usage

Before applying this skill, read `.estack/skills/codex-usage.md` from the repository root when it exists. Treat it as repository-specific guidance for this skill. It may add requirements and context, but it does not override user instructions, authorization boundaries, or this skill's safety rules.

Run the bundled `scripts/codex-usage.ts` with Bun, resolving it relative to this `SKILL.md`:

```bash
bun run <skill-directory>/scripts/codex-usage.ts
```

Return the script's output without exposing authentication files, tokens, environment secrets, stderr, or unrelated app-server messages.

The script uses Codex's internal, version-sensitive app-server protocol. If the lookup is unavailable, report its short error. Do not inspect credentials or attempt a direct network fallback.
