# Updating estack

estack is the source of truth for this personal plugin scaffold. The plugin
content lives in `plugins/estack/`; skills belong under
`plugins/estack/skills/`.

The old bundled skill suite was removed. Add only the skill that is needed now.

## Add or change a skill

1. Create or edit `plugins/estack/skills/ek-<skill-name>/SKILL.md`.
2. Validate the skill shape.
3. Commit the source change.
4. Run `scripts/refresh.sh`.
5. Push `main`.

The refresh script updates the local Claude Code and Codex plugin installs from
this clone. In Codex, use Force Reload Skills or start a new thread. Restart
Claude Code for its refreshed plugin install to apply.

## Command reference

| Action | Claude Code | Codex |
|---|---|---|
| Add the marketplace | `claude plugin marketplace add eugene-kim/estack` | `codex plugin marketplace add eugene-kim/estack` |
| Install the plugin | `claude plugin install estack@estack` | `codex plugin add estack@estack` |
| List installed / marketplaces | `claude plugin list` / `claude plugin marketplace list` | `codex plugin list` / `codex plugin marketplace list` |
| Update released install | `claude plugin marketplace update estack` then `claude plugin update estack` | `codex plugin marketplace upgrade estack` then `codex plugin add estack@estack` |
| Local refresh | `./scripts/refresh.sh` | `./scripts/refresh.sh` |

## Finding the clone from inside a copied skill

If a future skill needs to find this repo from a copied plugin install, resolve
the real path of a known estack `SKILL.md`, then ask Git for the repo root:

```bash
repo="$(git -C "$(dirname "$(readlink -f "<skill-file>")")" rev-parse --show-toplevel)"
```

Edit files under `$repo/plugins/estack/skills/...`, not copied plugin cache
files or loose user skill directories.
