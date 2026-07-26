---
name: codex-agent
description: Use when delegating work to a GPT-5.6-class agent through the Codex CLI from Claude Code, whether running one, answering a question it stopped on, or reading what it did. Covers the flags that are load-bearing, keeping its output out of your context, and the round trip.
---

# Codex Agent

Claude Code's Agent tool only reaches Anthropic models, so a GPT-class delegate
comes from Bash through `codex exec`. Reach for one when you want a second,
independent read rather than more of the same.

The agent inherits your shared instructions through `~/.codex/AGENTS.override.md`
and the skills from the estack Codex plugin, so you can name an `estack:*`
skill in the assignment. It inherits no lead framing.

## Choosing the model

Route the work; do not reach for the top tier by reflex.

- **Luna.** Cleanup, summaries, tagging, anything high-volume.
- **Terra.** Research, ordinary code, daily work.
- **Sol.** Strategy, hard debugging, decisions that are costly to get wrong.

Model and effort trade against each other, so pick the pair. Delegating from a
lead, Sol at low or medium and Terra at high are the ones that earn their cost;
Terra at high suits a review, where breadth matters more than depth on any one
line. Every tier takes low, medium, high, xhigh, and max.

## Running one

The working root must be inside a Git repository, or the run dies before it
reaches the model with `Not inside a trusted directory`. Add
`--skip-git-repo-check` when it is not.

Keep the log and result out of the repository. Left inside, they show up
untracked in the diff you are about to review, and two agents running at once
overwrite each other's, including the log holding the thread id you need.

```bash
dir=<absolute path to the working root>
model=gpt-5.6-terra          # or -sol, -luna; see above
effort=high                  # pair it with the model
run=$(mktemp -d)
codex exec -m "$model" -c model_reasoning_effort="$effort" \
  -c 'approval_policy="never"' -c 'notify=[]' -c 'mcp_servers={}' \
  --sandbox workspace-write -C "$dir" -o "$run/result.txt" --json \
  -- "$assignment" </dev/null >"$run/log.jsonl" 2>&1
echo "run=$run thread=$(sed -n 's/.*"thread_id": *"\([^"]*\)".*/\1/p' "$run/log.jsonl" | head -1)"
```

That last line matters: shell variables do not survive between tool calls, and
the round trip always spans several. Keep the printed run directory and thread
id, and set them again in any later call.

Read `$run/result.txt` when the run exits. Background anything long, but the
result file does not exist until it finishes, so do not read it in the same
call.


## Why these flags

The redirect is the one that earns the most. The event stream dwarfs the final
message, often by an order of magnitude and sometimes far more. All of it lands
in your context if it reaches stdout. That is the cost delegation exists to
avoid. Keep it on disk and read the `-o` file.

`approval_policy="never"` stops the run stalling the first time the agent wants
to escalate. `mcp_servers={}` drops servers it never needs. `notify=[]`
suppresses the desktop notification hook, which fires per turn and has no
audience here.

`</dev/null` is insurance rather than a fix for something you will see. With an
open stdin `codex exec` blocks even when the prompt is an argument, but the Bash
tool already hands it a null stdin, so the command works here without it. Keep
it anyway; this is not the only place the recipe runs.

## What the sandbox forbids

The agent has no network. It cannot install dependencies, clone, or fetch
anything, so do that yourself before handing over the workspace.

It also cannot write `.git`, so no commits, and no `git worktree add` either,
since that writes there too. Build the worktree yourself and point `-C` at it.

## Reading the outcome

A zero exit means the agent produced a message. It does not mean the agent
finished, because stopping to ask also exits zero. Read the result file to tell
those apart. A nonzero exit means the run itself failed, and then no result file
exists at all: the cause is at the end of `$run/log.jsonl`.

Nothing forces the shape of the report, so ask for what you need: what changed,
which checks it ran and what they said, what it left undone.

When you need to see how the agent got there, the whole thread is at
`~/.codex/sessions/<yyyy>/<mm>/<dd>/rollout-<timestamp>-<thread-id>.jsonl`. It
holds the prompts, the messages, and every command and output, and it grows
across resumes. That directory is local time, not UTC, so a run just past
midnight UTC sits under the previous day. Reasoning appears only above `low`
effort. Find the file by thread id, take the slice you want, and never read it
whole.

## The round trip

A Codex agent cannot message you mid-run, so tell it in the assignment how it is
being run: that nothing it says reaches you until the run ends, that stopping to
ask costs it nothing because you will reopen the thread with your answer, and
that it should stop on any decision that would change the work rather than
guess.

By the time a question reaches you the run has ended. Read it, decide, and
reopen the same thread:

```bash
dir=<the same working root>
run=<the run directory printed at launch>
thread=<the thread id printed at launch>
model=<the same model>       # resume falls back to the config default otherwise
effort=<the same effort>

cd "$dir"   # resume has no -C and must run inside the working root
codex exec resume "$thread" -m "$model" -c model_reasoning_effort="$effort" \
  -c 'approval_policy="never"' -c 'notify=[]' -c 'mcp_servers={}' \
  -c 'sandbox_mode="workspace-write"' -o "$run/reply.txt" --json \
  -- "$answer" </dev/null >"$run/resume.jsonl" 2>&1
```

Resume rejects `--sandbox` and `-C` but takes everything else, and needs it for
the same reasons the launch does. Drop `-o` and the redirect and the whole
growing thread lands in your context; drop the effort setting and the thread
silently reverts to the config default.

An empty `$dir` is the trap to avoid: `cd ""` succeeds in zsh and stays where it
is, so a resume with an unset variable runs against whatever workspace you
happen to be in.

The thread id comes from the `thread.started` event in the launch log. Match it
by line, as the launch block does, rather than parsing that file as strict JSON.
A stray stderr line can land mid-stream.
