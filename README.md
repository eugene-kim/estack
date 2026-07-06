# estack

estack is a personal Claude Code and Codex plugin scaffold.

The previous bundled skill suite has been removed. New skills are added only
when a real need appears, then installed through the same plugin refresh flow.

## Layout

- `plugins/estack/` is the plugin root shared by Claude Code and Codex.
- `plugins/estack/skills/` contains the small skills that have been added back
  as needs came up.
- `scripts/refresh.sh` refreshes the plugin install for both tools.
- `scripts/install-codex.sh` installs or refreshes the Codex plugin and cleans
  old estack-owned personal skill symlinks.
- `scripts/install-home-instructions.sh` surfaces estack's global instructions
  to Claude Code and Codex.

## Add a skill

Create a folder under `plugins/estack/skills/<skill-name>/` with a `SKILL.md`.
Keep each skill small and tied to a workflow that has actually come up.

After editing:

```bash
git add .
git commit -m "Add <skill-name> skill"
./scripts/refresh.sh
git push origin main
```

In Codex, use Force Reload Skills or start a new thread. Restart Claude Code for
its refreshed plugin install to apply.

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
