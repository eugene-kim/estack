# Updating estack

estack is the source of truth for this personal plugin scaffold. Shared skills
belong under `plugins/estack/skills/`. Host-only skills belong under
`plugins/estack/skills-claude/`, `plugins/estack/skills-codex/`, or
`plugins/estack/skills-cursor/`.

The old bundled skill suite was removed. Add only the skill that is needed now.

## Add or change a skill

1. Create or edit the skill in the matching source directory.
2. Validate the skill shape.
3. Commit the source change.
4. Run `scripts/refresh.sh`.
5. Push `main`.

The refresh script builds each host package, then updates each available local
install. Claude installs the tracked source plugin; Codex installs its generated
host package; Cursor uses a local symlink to its generated portable plugin. In
Codex, use Force Reload Skills or start a new thread. Restart Claude Code for its
refreshed plugin install to apply. In Cursor, run `Developer: Reload Window`.

## Command reference

| Action | Claude Code | Codex | Cursor |
|---|---|---|---|
| Add the marketplace | `claude plugin marketplace add eugene-kim/estack` | `codex plugin marketplace add eugene-kim/estack` | Use Customize for published plugins |
| Install the plugin | `claude plugin install estack@estack` | `codex plugin add estack@estack` | Local install is handled by refresh |
| List installed / marketplaces | `claude plugin list` / `claude plugin marketplace list` | `codex plugin list` / `codex plugin marketplace list` | Open Customize |
| Update released install | `claude plugin marketplace update estack` then `claude plugin update estack` | `codex plugin marketplace upgrade estack` then `codex plugin add estack@estack` | Reload after refresh |
| Local refresh | `./scripts/refresh.sh` | `./scripts/refresh.sh` | `./scripts/refresh.sh` |

## Unattended sync

This repo is edited from more than one machine, so a clone drifts two ways: it
falls behind `origin/main`, or it gets pulled and never refreshed, leaving the
installed snapshot older than the working tree. `scripts/sync.sh` detects both
and fixes them when it is safe to do so without a human present. It is one
script for every host, since it works by rerunning `refresh.sh`.

```
./scripts/sync.sh             # fetch, fast-forward if safe, refresh if needed
./scripts/sync.sh --dry-run   # report the classification, change nothing
```

It fast-forwards only. A dirty worktree, a divergence from `origin/main`, a
failed fetch or refresh, or a missing `claude` executable each stop it, and it
records why rather than improvising. Every run rewrites
`$XDG_STATE_HOME/estack/sync-state.json` (default `~/.local/state/estack/`) and
appends to `sync.log` beside it.

Two traps are worth knowing if you schedule it. `refresh.sh` treats a missing
host CLI as a skip rather than a failure, so an unattended run could quietly do
half its job; `sync.sh` therefore asserts a runnable `claude` before it starts,
and notes a skipped Codex half in the recorded outcome. And because `refresh.sh`
registers the containing clone as each host's local marketplace by absolute
path, `sync.sh` refuses to run from a linked worktree, which would otherwise
point the installs at a throwaway directory.

Schedule it however the machine prefers — a crontab entry invoking a login
shell, for example, so the PATH that provides the host CLIs is present. Note
that a bare cron PATH may resolve a different `claude` build than your
interactive shell does. The schedule is machine-local and deliberately not
checked in.

Claude Code loads plugins at startup, so a refresh that lands while a session is
open cannot reach it. The `SessionStart` hook
(`plugins/estack/claude/scripts/report-sync-state.py`) reads the state file and
speaks up when the sync is stuck, when a reinstall has just landed, or when the
state is old enough to mean the schedule has stopped running. It stays silent
when there is nothing to say.

## Finding the source clone

Use the local marketplace records as described in
`home/estack-instructions.md`. Plugin caches contain copied files, not links
back to the clone. Edit the matching source directory under
`$repo/plugins/estack/`, not generated packages, plugin caches, or loose user
skill directories.
