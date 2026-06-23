# Updating estack

estack is the single source of truth for these skills. Edit the repo, commit,
push. The plugin content lives in `plugins/estack/` (skills under
`plugins/estack/skills/`); the repo root holds the two marketplace files
(`.claude-plugin/marketplace.json` for Claude Code, `.agents/plugins/marketplace.json`
for Codex).

## How updates reach each tool

A marketplace install is a **copy**, so it updates on an explicit refresh. The
default loop is **edit in the clone → validate → commit → push →
`scripts/refresh.sh`**. Never edit a loose
`~/.claude/skills` / `~/.agents/skills` copy or the installed plugin cache — that
change is invisible to the other tool and an upgrade overwrites it. Always edit
the repo.

## Command reference

All commands are verified against the installed `claude` and `codex` CLIs. In
Claude Code the same commands also work as `/plugin …` inside a session; in Codex
the `/plugins` TUI is the interactive equivalent.

| Action | Claude Code | Codex |
|---|---|---|
| Add the marketplace | `claude plugin marketplace add eugene-kim/estack` | `codex plugin marketplace add eugene-kim/estack` |
| Install the plugin | `claude plugin install estack@estack` | `codex plugin add estack@estack` |
| List installed / marketplaces | `claude plugin list` / `claude plugin marketplace list` | `codex plugin list` / `codex plugin marketplace list` |
| Update (released) — two steps | `claude plugin marketplace update estack` then `claude plugin update estack` (restart to apply) | `codex plugin marketplace upgrade estack` then `codex plugin add estack@estack` |
| Uninstall the plugin | `claude plugin uninstall estack` | `codex plugin remove estack@estack` |
| Remove the marketplace | `claude plugin marketplace remove estack` | `codex plugin marketplace remove estack` |
| Local refresh | `./scripts/refresh.sh` (reinstalls cached plugin; restart Claude Code) | `./scripts/refresh.sh` (plugin install flow; Force Reload Skills or start a new thread) |

Released update is **two steps**: refresh the marketplace from GitHub, then
update/re-add the installed plugin. `scripts/refresh.sh` handles the local
machine refresh for both tools. For Codex marketplaces backed by a local path,
there is no Git snapshot to upgrade, so the script skips marketplace upgrade and
re-adds the plugin from the local marketplace.

## Finding the clone from inside a skill

Skills may be symlinked or copied into a platform dir, so resolve the real path
first, then ask git for the repo root:

```bash
# <skill-file> = the path of the skill file you're editing (or this skill's own SKILL.md)
repo="$(git -C "$(dirname "$(readlink -f "<skill-file>")")" rev-parse --show-toplevel)"
```

`$repo` is the estack clone. Edit files under `$repo/plugins/estack/skills/...`,
then commit and push from `$repo`.

## Meta-skill behavior

`reflect`, `automate-me`, and the `authoring-a-skill` playbook all write into the
estack clone (`plugins/estack/skills/`) and commit there, so their output
propagates like any other change. A personal `<name>-mode` skill from
`automate-me` lands in `plugins/estack/skills/<name>-mode/` by default; keep it
out of the repo only if you deliberately want it un-synced.
