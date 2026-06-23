# estack

estack is set up on this machine.

## Finding the estack clone

Do not assume estack lives at a fixed path. Different machines may install the
clone in different locations.

When editing estack skills, first locate the source clone by resolving the real
path of an estack `SKILL.md`, then ask Git for the repo root:

```bash
skill_file="<path-to-an-estack-SKILL.md>"
repo="$(git -C "$(dirname "$(readlink -f "$skill_file")")" rev-parse --show-toplevel)"
```

Edit files under `$repo/plugins/estack/skills/...`. Do not edit active copied
skills under the Codex plugin cache, and do not edit loose user-level skill
copies such as `~/.claude/skills` or `~/.agents/skills`.

After changing estack skills, commit and push from the clone, then run
`$repo/scripts/refresh.sh` so Claude Code and Codex pick up the plugin update.

<!-- This file is estack's global instructions, surfaced to both Claude Code and
     Codex by scripts/install-home-instructions.sh. Keep it tool-agnostic; where
     guidance differs, phrase it inline ("In Claude Code… / In Codex…"). -->
