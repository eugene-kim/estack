# estack — agent guidance

estack is a set of rigorous agent workflow skills. The entry point is the
**euge-mode** skill: at the start of any non-trivial task, read it, let it match
the task to a playbook, and follow that playbook's steps.

- The orchestrating skill lives in `skills/euge-mode/SKILL.md`. It indexes a set
  of one-principle leaf skills (`skills/principle-*`) and routes to focused
  skills (`how`, `why`, `architect`, `interrogate`, `arena`, `reflect`, `tdd`,
  `unslop`, and others).
- The skills are model-agnostic. Where a skill calls for "a strong reasoning
  model", "a fast, lower-cost code model", or "a diverse panel of independent
  models", pick the strongest and fastest models your platform offers for each
  role. Don't expect any specific model name.
- Subagents: where a skill says `subagent_type: "euge-agent"`, that's a
  Claude Code plugin subagent. On Codex (no equivalent), use a general-purpose
  subagent and have it read `skills/euge-mode/SKILL.md` in full first, including
  its inline Principles index.

## Install (Codex)

Run `scripts/install-codex.sh` to symlink every skill into `~/.agents/skills`.
Then invoke the orchestrator with something like: `use euge-mode: <your task>`.
