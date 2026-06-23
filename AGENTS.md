# estack

Skills in this repo must work in **both Claude Code and Codex**.

Tool-specific features are allowed — but when you use one, add an equivalent
that produces the same behavior on the other tool. Don't drop a feature just
because the other tool lacks it; pair it with a fallback.

**Example — manual-only skills.** Claude Code honors
`disable-model-invocation: true` in frontmatter so the model never auto-invokes
the skill. Codex ignores that field, so also encode the intent in the
description (e.g. "Do not invoke unless explicitly asked"). The skill then
behaves as manual-only on both tools.

## estack agent guidance

estack is a set of rigorous agent workflow skills. The entry point is the
**euge-mode** skill: at the start of any non-trivial task, read it, let it match
the task to a playbook, and follow that playbook's steps.

- The orchestrating skill lives in `plugins/estack/skills/euge-mode/SKILL.md`. It indexes a set
  of one-principle leaf skills (`plugins/estack/skills/principle-*`) and routes to focused
  skills (`how`, `why`, `architect`, `interrogate`, `arena`, `reflect`, `tdd`,
  `unslop`, and others).
- The skills are model-agnostic. Where a skill calls for "a strong reasoning
  model", "a fast, lower-cost code model", or "a diverse panel of independent
  models", pick the strongest and fastest models your platform offers for each
  role. Don't expect any specific model name.
- Subagents: where a skill says `subagent_type: "euge-agent"`, that's a
  Claude Code plugin subagent. On Codex (no equivalent), use a general-purpose
  subagent and have it read `plugins/estack/skills/euge-mode/SKILL.md` in full first, including
  its inline Principles index.

## Install (Codex)

estack is a Codex plugin. Install it from its marketplace:

```bash
codex plugin marketplace add eugene-kim/estack
codex plugin add estack@estack
```

Then invoke the orchestrator with something like: `use euge-mode: <your task>`.
For local development, commit your edits, run `scripts/refresh.sh`, then use
Codex's **Force Reload Skills** command or start a new thread.

## Updating skills

This repo is the source of truth. When a skill (or a meta-skill like `reflect` /
`automate-me`) needs to change a skill, edit the file in the estack clone and
commit there, not a loose `~/.agents/skills` copy or the installed plugin cache.
Locate the clone by resolving a skill's real path and
`git rev-parse --show-toplevel`; skills live under `plugins/estack/skills/`.
A marketplace install is a copy, so after pushing, update in two steps —
`codex plugin marketplace upgrade estack` then `codex plugin add estack@estack`
for Git marketplaces, or just `codex plugin add estack@estack` for a local
marketplace. `scripts/refresh.sh` handles both. See `UPDATING.md` for the full
command reference (install, update, uninstall, remove) and workflow.
