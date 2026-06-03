# Updating estack

estack is the single source of truth for these skills. Edit the repo, commit,
push. Both Claude Code and Codex read from the same clone, so the change flows
downstream with no per-skill copying.

## How both tools see the repo

- **Codex** reads `~/.agents/skills/<name>`, which `scripts/install-codex.sh`
  symlinks back into this repo's `skills/`. A committed edit (or `git pull`) is
  live immediately.
- **Claude Code** runs against the clone via `claude --plugin-dir <path-to-estack>`.
  Edits show up on the next session / reload.
- **Other machines:** `git pull` in their clone. Codex is live; Claude Code
  reloads. (If a machine installs via the marketplace instead of `--plugin-dir`,
  run `/plugin marketplace update estack` after you push.)

The loop is: **edit in the clone → validate → commit → push.** Nothing else
copies skills around. If you edit a loose `~/.claude/skills` or `~/.agents/skills`
copy directly, that change is invisible to the other tool and a re-install will
overwrite it. Always edit the repo.

## Finding the clone from inside a skill

Skills are usually symlinked into a platform dir, so resolve the real path first,
then ask git for the repo root:

```bash
# <skill-file> = the path of the skill file you're editing (or this skill's own SKILL.md)
repo="$(git -C "$(dirname "$(readlink -f "<skill-file>")")" rev-parse --show-toplevel)"
```

`$repo` is the estack clone. Edit files under `$repo/skills/...`, then commit and
push from `$repo`.

## Meta-skill behavior

`reflect`, `automate-me`, and the `authoring-a-skill` playbook all write into the
estack clone and commit there, so their output propagates like any other change.
A personal `<name>-mode` skill from `automate-me` lands in
`<repo>/skills/<name>-mode/` by default; keep it out of the repo only if you
deliberately want it un-synced.
