# estack

estack is a personal Claude Code and Codex plugin scaffold.

The previous bundled skill suite has been removed. New skills are added only
when a real need appears, then installed through the same plugin refresh flow.

## Layout

- `plugins/estack/` is the plugin root shared by Claude Code and Codex.
- `plugins/estack/skills/` contains the focused skills that have been added back
  as needs came up.
- `scripts/refresh.sh` refreshes the plugin install for both tools.
- `scripts/install-codex.sh` installs or refreshes the Codex plugin and cleans
  old estack-owned personal skill symlinks.
- `scripts/install-home-instructions.sh` surfaces estack's global instructions
  to Claude Code and Codex.

## Add a skill

Create a folder under `plugins/estack/skills/ek-<skill-name>/` with a `SKILL.md`.
Keep each skill focused and tied to a workflow that has actually come up.

Write skills as lightweight judgment aids. Avoid over-prescribing outputs or
turning broad ideas into closed menus unless the workflow really is closed. A
skill should usually help the agent decide where the improvement belongs: code,
tests, scripts, docs, repo instructions, or another skill. Do not hard-code
scale, such as agent counts or numbers of approaches, unless the user or domain
requires it. Prefer durable intent, constraints, and quality bars over guidance
that bakes in assumptions about current model limitations.

After editing:

```bash
git add .
git commit -m "Add <skill-name> skill"
./scripts/refresh.sh
git push origin main
```

In Codex, use Force Reload Skills or start a new thread. Restart Claude Code for
its refreshed plugin install to apply.

## Current skills

- `ek-explain` creates a rich, printable HTML explanation of a code change, concept, architecture, PRD, or plan.
- `ek-bundle-context` creates a self-contained temporary context bundle for an external model, reviewer, or fresh agent.
- `ek-prd` turns a product idea or feature request into a concise PRD.
- `ek-plan` turns requirements into a grounded engineering plan.
- `ek-implement` implements an agreed change with tight scope and verification.
- `ek-simplify` refines recently modified code while preserving behavior.
- `ek-review` checks a diff for correctness, regressions, and missing tests.
- `ek-create-pr` creates a reviewer-friendly PR with a reading guide.
- `ek-manage-pr` handles PR feedback, CI failures, notes, and readiness.
- `ek-compound` improves the relevant artifact based on what became clear.
- `ek-dev` runs the software development cycle across the phase skills.

## Install or refresh on another machine

```bash
git clone https://github.com/eugene-kim/estack.git
cd estack
./scripts/refresh.sh
```

For an existing clone:

```bash
cd /path/to/estack
git pull
./scripts/refresh.sh
```

## Notes

This repo is managed by one person. If the user asks for a change and is happy
with it, commit it, run `scripts/refresh.sh`, and push `main` by default.

The plugin should remain usable even with no skills installed. The empty
`skills/` directory is tracked with `.gitkeep` when no skills exist so future
skills have a stable home.

## License

MIT. See [LICENSE](LICENSE).
