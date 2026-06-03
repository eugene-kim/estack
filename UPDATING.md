# Updating estack

estack is the single source of truth for these skills. Edit the repo, commit,
push. The plugin content lives in `plugins/estack/` (skills under
`plugins/estack/skills/`); the repo root holds the two marketplace files
(`.claude-plugin/marketplace.json` for Claude Code, `.agents/plugins/marketplace.json`
for Codex).

## How updates reach each tool

A marketplace install is a **copy**, so it updates on an explicit upgrade. A
live-dev install reads the clone in place, so it updates on reload.

| Tool | Released (marketplace) | Live dev |
|---|---|---|
| Claude Code | `/plugin marketplace update estack`, then reload | `claude --plugin-dir ./plugins/estack` — reads the clone; reloads on next session |
| Codex | `codex plugin marketplace upgrade estack` | `scripts/install-codex.sh` — symlinks `plugins/estack/skills/*` into `~/.agents/skills`, so a commit or `git pull` is live |

The loop is: **edit in the clone → validate → commit → push.** Other machines
`git pull`, then upgrade (released) or just reload (live dev). Never edit a loose
`~/.claude/skills` / `~/.agents/skills` copy or the installed plugin cache — that
change is invisible to the other tool and an upgrade overwrites it. Always edit
the repo.

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
