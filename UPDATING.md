# Updating estack

estack is the source of truth for this personal plugin scaffold. Shared skills
belong under `plugins/estack/skills/`. Host-only skills belong under
`plugins/estack/skills-claude/` or `plugins/estack/skills-codex/`.

The old bundled skill suite was removed. Add only the skill that is needed now.

## Add or change a skill

1. Create or edit the skill in the matching source directory.
2. Validate the skill shape.
3. Commit the source change.
4. Run `scripts/refresh.sh`.
5. Push `main`.

The refresh script validates a mirrored Claude package, builds the Codex
package, then updates each local install. Claude installs the tracked source
plugin; Codex installs its generated host package. In Codex, use Force Reload
Skills or start a new thread. Restart Claude Code for its refreshed plugin
install to apply.

## Command reference

| Action | Claude Code | Codex |
|---|---|---|
| Add the marketplace | `claude plugin marketplace add eugene-kim/estack` | `codex plugin marketplace add eugene-kim/estack` |
| Install the plugin | `claude plugin install estack@estack` | `codex plugin add estack@estack` |
| List installed / marketplaces | `claude plugin list` / `claude plugin marketplace list` | `codex plugin list` / `codex plugin marketplace list` |
| Update released install | `claude plugin marketplace update estack` then `claude plugin update estack` | `codex plugin marketplace upgrade estack` then `codex plugin add estack@estack` |
| Local refresh | `./scripts/refresh.sh` | `./scripts/refresh.sh` |

## Finding the source clone

Use the local marketplace records as described in
`home/estack-instructions.md`. Plugin caches contain copied files, not links
back to the clone. Edit the matching source directory under
`$repo/plugins/estack/`, not generated packages, plugin caches, or loose user
skill directories.
