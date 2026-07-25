---
name: ek-claude-agent
description: Use from Codex when delegating repository work, an independent review, or a focused investigation to a Claude model through the Claude Code CLI. Covers fresh headless runs, model and permission choices, JSON result capture, follow-up turns, and graceful fallback when Claude Code is unavailable.
---

# Claude agent

Use Claude Code when another model family would add a useful independent view.
Run it from the repository it should inspect so it can read the real code and
project instructions.

Run this skill from Codex. A Claude Code session should use its native agent
tools instead.

For review, start a fresh session. Give the reviewer the scope and source
material, but not the root agent's conclusions. This preserves the value of a
separate context window. Resume that session only to clarify its findings.

## Choose the model

Use Opus unless the user asks for another Claude model. Set the model
explicitly so local defaults and inherited settings do not change the delegate.
Choose the effort from the task's complexity and risk.

## Write the assignment

State the objective, scope, source of truth, constraints, expected output, and
conditions for success. For code review, ask for concrete findings with file
and line references, the evidence behind each finding, and the checks run.
Ask the reviewer to distinguish actionable findings from concerns it checked
and ruled out.

Do not prime an independent review with suspected bugs or findings from another
reviewer unless the task is to verify one specific concern.

## Run a fresh agent

Check `claude --help` before relying on flags that may have changed. Keep the
assignment and result outside the repository.

```bash
repo_root=<absolute path to the repository>
claude_model=opus
claude_effort=high
claude_run=$(mktemp -d)
assignment_file="$claude_run/assignment.md"

cd "$repo_root"
claude -p \
  --model "$claude_model" \
  --effort "$claude_effort" \
  --permission-mode dontAsk \
  --tools "Read,Glob,Grep,Bash" \
  --output-format json \
  "Complete the assignment provided on stdin." \
  <"$assignment_file" >"$claude_run/result.json" 2>"$claude_run/stderr.log"
claude_status=$?
```

Write the complete assignment to `assignment_file` before starting the command.
The tool list omits direct file-editing tools, but Bash can still write. Tell
the reviewer not to modify the repository. `dontAsk` denies any action that
still needs permission instead of stalling the headless run. Use a disposable
worktree when review commands may generate or modify files. Grant more access
only when the task requires it. Do not bypass all permissions for a review.

Do not use `--bare` or `--safe-mode` for repository work. Both suppress project
context that the reviewer should normally see.

Check `claude_status` before reading the result. On success, read only the final
answer and keep the session id for a possible follow-up:

```bash
claude_session=$(jq -r '.session_id' "$claude_run/result.json")
jq -r '.result' "$claude_run/result.json"
printf 'claude_run=%s\nclaude_session=%s\n' "$claude_run" "$claude_session"
```

Retain both printed values. Shell variables may not survive the next tool call.

## Continue the same review

Use a fresh session for a new review pass. Resume only when answering a question
or asking the same reviewer to explain or verify its own finding.

```bash
repo_root=<the same repository>
claude_model=<the same model>
claude_effort=<the same effort>
claude_run=<the run directory printed at launch>
claude_session=<the session id printed at launch>
follow_up_file="$claude_run/follow-up.md"

if [ -z "$repo_root" ] || [ -z "$claude_run" ] || [ -z "$claude_session" ]; then
  printf '%s\n' "Missing Claude resume state" >&2
  exit 1
fi
cd "$repo_root"
claude -p \
  --resume "$claude_session" \
  --model "$claude_model" \
  --effort "$claude_effort" \
  --permission-mode dontAsk \
  --tools "Read,Glob,Grep,Bash" \
  --output-format json \
  "Respond to the follow-up provided on stdin." \
  <"$follow_up_file" >"$claude_run/follow-up.json" 2>"$claude_run/follow-up.stderr.log"
claude_status=$?
```

Write the follow-up to `follow_up_file` before resuming.
The JSON result includes the final text, session id, usage, and cost metadata.
Do not use `--no-session-persistence` when a follow-up may be needed.

## Fall back cleanly

If Claude Code is missing, unauthenticated, unavailable, or out of usage, record
that the external review did not run. Continue with independent reviewers in
the current platform. Never present a current-platform review as the requested
cross-model review.
