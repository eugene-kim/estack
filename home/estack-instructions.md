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

## Writing rules

Writing rules, from Orwell, 1946. These govern prose: docs, PR text, messages. Never touch code or technical terms; swap in everyday words only where precision survives.

1. Never use a metaphor, simile, or other figure of speech which you are used to seeing in print.
2. Never use a long word where a short one will do.
3. If it is possible to cut a word out, always cut it out.
4. Never use the passive where you can use the active.
5. Never use a foreign phrase, a scientific word, or a jargon word if you can think of an everyday English equivalent.
6. Break any of these rules sooner than say anything outright barbarous.

Review every prose output against these rules before delivering.

<!-- This file is estack's global instructions, surfaced to both Claude Code and
     Codex by scripts/install-home-instructions.sh. Keep it tool-agnostic; where
     guidance differs, phrase it inline ("In Claude Code… / In Codex…"). -->
