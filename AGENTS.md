# estack

This repo is a personal Claude Code, Codex, and Cursor plugin scaffold.

Shared skills must work in Claude Code, Codex, and Cursor. Tool-specific
features are allowed only when paired with a fallback that gives the other
tools equivalent behavior.

## Current shape

The old bundled skill suite was removed. Shared skills live under
`plugins/estack/skills/` and should be added back one at a time as real needs
come up.

Keep plugin and refresh machinery working:

- `plugins/estack/.claude-plugin/plugin.json`
- `plugins/estack/.codex-plugin/plugin.json`
- `plugins/estack/skills-claude/`
- `plugins/estack/skills-codex/`
- `plugins/estack/skills-cursor/`
- `plugins/estack/claude/`
- `plugins/estack/cursor/`
- `.claude-plugin/marketplace.json`
- `.agents/plugins/marketplace.json`
- `scripts/build-plugins.sh`
- `scripts/refresh.sh`
- `scripts/install-codex.sh`
- `scripts/install-cursor.sh`
- `scripts/install-home-instructions.sh`

`scripts/build-plugins.sh` composes host-specific packages under `.generated/`.
All hosts install a plugin named `estack`. Never edit generated packages.

## Adding skills

When asked to add a skill, create `plugins/estack/skills/<skill-name>/SKILL.md`.
A skill that only makes sense in Claude Code belongs in
`plugins/estack/skills-claude/`. A Codex-only skill belongs in
`plugins/estack/skills-codex/`. A Cursor-only skill belongs in
`plugins/estack/skills-cursor/`.
Use the plain skill name for its folder and frontmatter. Claude Code, Codex, and
Cursor expose it under the `estack` plugin namespace, so no extra skill-name
prefix is needed.
Keep the skill focused. Do not recreate the old bundled suite unless the user asks
for a specific skill because the need has come up again.

## Skill writing style

Write skills as lightweight judgment aids, not rigid menus of allowed outputs.
Default to broad principles, natural next steps, and examples of possible homes
for the work rather than exhaustive lists.

- Prefer wording that leaves the agent room to improve the relevant artifact.
- Write for durability across model families, not just newer versions of one.
  Shared skills run on Claude and on GPT-class models through Codex, so one
  model handling something unaided is not grounds to cut it. Capture enduring
  intent, constraints, and quality bars rather than instructions that
  compensate for current model limitations.
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
