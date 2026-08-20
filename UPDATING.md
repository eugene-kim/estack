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

## Finding the source clone

Use the local marketplace records as described in
`home/estack-instructions.md`. Plugin caches contain copied files, not links
back to the clone. Edit the matching source directory under
`$repo/plugins/estack/`, not generated packages, plugin caches, or loose user
skill directories.
