# estack

estack is set up on this machine.

## Finding the estack clone

Do not assume estack lives at a fixed path. Different machines may install the
clone in different locations.

When editing estack skills, first locate the source clone by resolving the real
path of an estack `SKILL.md`, then ask Git for the repo root:

```bash
skill_file="<path-to-an-estack-SKILL.md>"
repo="$(git -C "$(dirname "$(readlink -f "$skill_file")")" rev-parse --show-toplevel)"
```

Edit shared skills under `$repo/plugins/estack/skills/...`, Claude-only skills
under `$repo/plugins/estack/skills-claude/...`, and Codex-only skills under
`$repo/plugins/estack/skills-codex/...`. Do not edit generated or cached plugin
copies, or loose user-level copies such as `~/.claude/skills` or
`~/.agents/skills`.

After changing estack skills, commit and push from the clone, then run
`$repo/scripts/refresh.sh` so Claude Code and Codex pick up the plugin update.

## Working preferences

- When independent work can run while the main thread is busy, delegate it so the user gets useful results sooner. Keep dependent work in the main thread, and do not parallelize work that shares unsafe state.
- Store preferences that should apply across coding agents in this platform-agnostic estack source, not in Claude Code- or Codex-specific memory. Put each preference where both tools will load it and keep the wording tool-agnostic.
- Once the user invokes `estack:dev` for an increment, keep that workflow active across follow-up turns on the same branch or PR until merge, an explicit stop, or a blocker. The user does not need to invoke the skill again.
- The user sometimes dictates messages, so transcription may introduce errors. If wording is unclear or inconsistent, ask a focused clarification question rather than guessing.
- For one-off scripts, use TypeScript unless it cannot reasonably do the job. Do not use Python when TypeScript is viable.
- Open pull requests as drafts by default. Mark a PR ready only when the change is complete and verified, or when the user explicitly requests otherwise. In the estack workflow, keep it draft until review records `ai-review:LGTM`; once that label and the required verification are present, mark it ready.

## Writing rules

Follow the ASD-STE100 Simplified Technical English spec for prose: docs, PR text, messages, and comments written for humans. Never change code, repo symbols, or other technical terms.

<!-- This file is estack's global instructions, surfaced to both Claude Code and
     Codex by scripts/install-home-instructions.sh. Keep it tool-agnostic; where
     guidance differs, phrase it inline ("In Claude Code... / In Codex..."). -->
