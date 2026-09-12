# estack

estack is set up on this machine.

The source of truth is the Git repository at https://github.com/eugene-kim/estack.
Eugene controls it, so changes go there as ordinary commits on `main`. On
Eugene's Mac laptop the clone is at `/Users/euge/code/estack`. The installed
plugin copies that `refresh.sh` produces are replaced on every refresh, so an
edit made there is lost; edit the clone, commit, push, and refresh.

## Finding the estack clone

On another machine, do not assume estack lives at a fixed path. Different
machines may install the clone in different locations.

When editing estack skills, first locate the source clone. Each tool records the
clone path when `refresh.sh` registers it as a local marketplace. Read that
record, then ask Git for the repo root:

```bash
repo="$( { sed -n '/"estack"/,/}/s/.*"path": "\(.*\)".*/\1/p' ~/.claude/plugins/known_marketplaces.json
           sed -n '/^\[marketplaces\.estack\]/,/^\[/s/^source = "\(.*\)"/\1/p' ~/.codex/config.toml
           readlink ~/.cursor/plugins/local/estack
         } 2>/dev/null | head -1 )"
repo="$(git -C "${repo:?no estack marketplace record found}" rev-parse --show-toplevel)"
```

The first `sed` reads Claude Code's marketplace record, the second reads Codex's,
and `readlink` reads Cursor's local plugin link. Any one is enough. The `git`
call confirms the path is a real clone. Keep the `:?` guard: `git -C ""` does not fail, it
returns the repo you are standing in, so an empty result would quietly point at
the wrong repository. Do not resolve a cached `SKILL.md` with `readlink -f`: the
plugin caches hold real files, not symlinks into the clone, so that path leads
out of the repo.

Edit shared skills under `$repo/plugins/estack/skills/...`, Claude-only skills
under `$repo/plugins/estack/skills-claude/...`, Codex-only skills under
`$repo/plugins/estack/skills-codex/...`, and Cursor-only skills under
`$repo/plugins/estack/skills-cursor/...`. Do not edit generated or cached plugin
copies, or loose user-level copies such as `~/.claude/skills` or
`~/.agents/skills`.

After changing estack skills, commit and push from the clone, then run
`$repo/scripts/refresh.sh` so Claude Code, Codex, and Cursor pick up the plugin
update.

## Working preferences

- When independent work can run while the main thread is busy, delegate it so the user gets useful results sooner. Keep dependent work in the main thread, and do not parallelize work that shares unsafe state.
- Store preferences that should apply across coding agents in this platform-agnostic estack source, not in Claude Code- or Codex-specific memory. Put each preference where both tools will load it and keep the wording tool-agnostic.
- Once the user invokes `estack:dev` for an increment, keep that workflow active across follow-up turns on the same branch or PR until merge, an explicit stop, or a blocker. The user does not need to invoke the skill again.
- The user sometimes dictates messages, so transcription may introduce errors. If wording is unclear or inconsistent, ask a focused clarification question rather than guessing.
- For one-off scripts, use TypeScript unless it cannot reasonably do the job. Do not use Python when TypeScript is viable.
- Secrets come from the checkout `.env`, which `bun run env:make:local` generates from 1Password once. Read every secret from `.env` (or copy the primary checkout `.env` into a worktree). Never run `op` for a value that `.env` has, and never run `op` once per secret: every `op` process is a separate approval prompt on the user screen. If `.env` lacks a key, add it to `.env.tpl` and regenerate once. If values must come from a vault that `.env` does not cover, make one `op inject` call into one mode-600 file, then set everything from that file (for a Worker, `wrangler secret bulk`). A script that runs `op` more than once is wrong.
- Open pull requests as ready for review. In the estack workflow, a missing `ai-review:LGTM` remains active work owned by the PR manager.

## Writing rules

Follow the ASD-STE100 Simplified Technical English spec for prose: docs, PR text, messages, and comments written for humans. Never change code, repo symbols, or other technical terms.

<!-- This file is estack's global instructions, surfaced to both Claude Code and
     Codex by scripts/install-home-instructions.sh. Keep it tool-agnostic; where
     guidance differs, phrase it inline ("In Claude Code... / In Codex..."). -->
