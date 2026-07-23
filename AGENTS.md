# estack

This repo is a personal Claude Code and Codex plugin scaffold.

Skills must work in both Claude Code and Codex. Tool-specific features are
allowed only when paired with a fallback that gives the other tool equivalent
behavior.

## Current shape

The old bundled skill suite was removed. Skills now live under
`plugins/estack/skills/` and should be added back one at a time as real needs
come up.

Keep plugin and refresh machinery working:

- `plugins/estack/.claude-plugin/plugin.json`
- `plugins/estack/.codex-plugin/plugin.json`
- `plugins/estack-fable/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
- `.agents/plugins/marketplace.json`
- `scripts/refresh.sh`
- `scripts/install-codex.sh`
- `scripts/install-home-instructions.sh`

`plugins/estack/` is shared by Claude Code and Codex. `plugins/estack-fable/`
is a Claude Code-only plugin for the Fable SessionStart hook. Do not add its
hook or its Claude manifest to the shared plugin.

## Adding skills

When asked to add a skill, create `plugins/estack/skills/ek-<skill-name>/SKILL.md`.
Skill names and folders should use the `ek-` prefix so they remain distinct when
many skills are installed.
When the user refers to a skill without the prefix, treat the `ek-` prefix as
implied unless they explicitly say otherwise.
Keep the skill focused. Do not recreate the old bundled suite unless the user asks
for a specific skill because the need has come up again.

## Skill writing style

Write skills as lightweight judgment aids, not rigid menus of allowed outputs.
Default to broad principles, natural next steps, and examples of possible homes
for the work rather than exhaustive lists.

- Prefer wording that leaves the agent room to improve the relevant artifact.
- Write for durability across model improvements. Capture enduring intent,
  constraints, and quality bars rather than instructions that compensate for
  current model limitations.
- Avoid phrases like "produce one of" unless the skill truly has a closed set of
  valid outputs.
- Do not hard-code scale unless the user or domain requires it. Let the agent
  choose the number of approaches, agents, checks, examples, or artifacts based
  on task size, complexity, uncertainty, and risk.
- Do not require repetition before improvement. A stale doc, misleading
  instruction, missing test, rough script, or bad default can be enough.
- Put guidance where future work will naturally encounter it: code, tests,
  scripts, docs, `AGENTS.md` / `CLAUDE.md`, or a skill.
- Add strict steps only when the workflow is fragile, externally constrained, or
  easy to corrupt without them.

## Default landing flow

This repo is managed by one person. When the user asks for a change and is happy
with the result, commit it, run `scripts/refresh.sh`, and push `main` by default.
Skip that only when the user explicitly asks to hold the diff locally, use a
branch or PR, or avoid refreshing.
