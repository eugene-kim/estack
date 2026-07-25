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
Use `xhigh` effort for review and `medium` effort for implementation. For other
assignments, choose the effort from the task's complexity and risk.

## Write the assignment

State the objective, scope, source of truth, constraints, expected output, and
conditions for success. For code review, ask for concrete findings with file
and line references, the evidence behind each finding, and the checks run.
Ask the reviewer to distinguish actionable findings from concerns it checked
and ruled out.

Do not prime an independent review with suspected bugs or findings from another
reviewer unless the task is to verify one specific concern.

## Prepare the source

Materialize the source the agent needs before starting it. For GitHub work,
fetch the relevant refs and include the issue or PR body, base SHA, and head SHA
in the neutral assignment. For other work, supply the applicable source
material rather than assuming the headless agent can recover missing context.

Choose isolation from the assignment:

- For a ref-based PR review or a check that may write or regenerate files,
  default to a disposable worktree at the exact source ref.
- When local or uncommitted state is part of the assignment, use that working
  tree.
- A read-only investigation may use the normal checkout.

## Choose access

Grant only the tools and integrations the assignment needs. The runner disables
Chrome by default. Use `--no-mcp` when no MCP server is needed. Use
`--mcp-config <path>` to load only selected servers. Omit both only when the
assignment specifically needs the caller's configured MCP servers.

For review, omit editing tools and tell the reviewer not to modify the
repository. `dontAsk` denies actions that still need permission instead of
stalling the headless run. Use broader permissions only when the assignment
requires them. Do not bypass all permissions for a review.

## Run an agent

Use `scripts/run_claude.py` from this skill. It creates one
`/tmp/ek-claude-.../` directory for the assignment, raw stream, final result,
stderr, and manifest. The stream stays out of Codex context unless you read it.

Check `claude --help` before relying on flags that may have changed. Write the
complete assignment outside the repository, then run:

```bash
repo_root=<absolute path to the prepared source>
claude_model=opus
claude_effort=<xhigh for review; medium for implementation>
claude_tools=<assignment-required built-in tools>
assignment_file=<path to the completed assignment>
runner=<path to this skill>/scripts/run_claude.py

python3 "$runner" \
  --cwd "$repo_root" \
  --assignment "$assignment_file" \
  --model "$claude_model" \
  --effort "$claude_effort" \
  --tools "$claude_tools" \
  --no-mcp
claude_status=$?
```

Do not use `--bare` or `--safe-mode` for repository work. Both suppress project
context that the agent should normally see.

The runner prints a small start event with the run directory and PID, then a
finish event with status and session ID. Check `claude_status` and
`manifest.json` before reading `result.json`. Read the raw stream only when
diagnosing the run.

```bash
jq -r '.result' /tmp/ek-claude-.../result.json
```

The manifest records the run directory, cwd, model, effort, PID, timestamps,
status, session ID, and output paths. Keep task-specific refs and identifiers
in the assignment, not the generic manifest.

## Continue the same session

Use a fresh session for a new review pass. Resume only when answering a question
or asking the same agent to explain or verify its own result. Run the helper
again with a new assignment and the saved session ID:

```bash
python3 "$runner" \
  --resume "$claude_session" \
  --cwd "$repo_root" \
  --assignment "$follow_up_file" \
  --model "$claude_model" \
  --effort "$claude_effort" \
  --tools "$claude_tools" \
  --no-mcp
```

Each turn gets its own run directory and evidence. Do not disable session
persistence when a follow-up may be needed.

## Gate ultrareview on user approval

Claude Code also offers `claude ultrareview` for a remote multi-agent review.
It uploads the branch or clones the pull request into Anthropic's cloud review
service. After any trial runs, it may bill usage credits.

Never start ultrareview based on the model's judgment alone. The user must
explicitly approve the specific run. The agent may suggest it, but must wait for
that approval before running:

```bash
ultrareview_run=$(mktemp -d /tmp/ek-claude-ultrareview-XXXXXX)
claude ultrareview <pr-number-or-base-branch> \
  --json >"$ultrareview_run/result.json" 2>"$ultrareview_run/stderr.log"
claude_status=$?
```

A successful ultrareview exits zero whether or not it found bugs. Read the
result to determine the review outcome.

## Fall back cleanly

If Claude Code is missing, unauthenticated, unavailable, or out of usage, record
that the external review did not run. Continue with independent reviewers in
the current platform. Never present a current-platform review as the requested
cross-model review.
