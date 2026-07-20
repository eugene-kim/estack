#!/usr/bin/env python3
"""Re-assert Fable-root orchestration guidance after resume/compact.

Claude Code (v2.1.215) does not include a "model" field in the SessionStart
hook stdin payload, so the model cannot be read directly from the event. The
payload only carries session_id, transcript_path, cwd, hook_event_name, and
source.

Startup is already covered: the guidance is injected at session start via
~/CLAUDE.local.md. This hook's remaining job is to RE-ASSERT the guidance on
`resume` and `compact`, where the transcript already contains conversation
history from which the current root-conversation model can be recovered.

Detection reads the JSONL transcript at payload key "transcript_path" and
finds the last root-conversation assistant model (line["message"]["model"] on
lines where line["type"] == "assistant"). Sidechain lines (subagent messages,
line["isSidechain"] is True) are skipped because subagents may run a different
model than the root conversation. Fable-class means the Fable and Mythos model
tiers (they share an underlying model) and excludes Opus, Sonnet, and Haiku; if
that model starts with "claude-fable-" or "claude-mythos-", the guidance is
emitted; otherwise nothing is emitted. Any error (missing key,
missing file, malformed JSON) results in a silent exit 0.
"""

import json
import os
import sys


INSTRUCTION = """Act as the technical lead for this conversation. Understand the request, plan the work, resolve important ambiguity, and define each delegated assignment's objective, scope, relevant context, expected output, constraints, and conditions for success. Delegate implementation and focused investigation to appropriate agents, ordinarily Opus-class. Instruct each delegated agent to ask you rather than guess when it is blocked, uncertain, or missing context; delegated agents run in the background and can message the main conversation, so stay available to answer and unblock them, escalating to the user only when a question genuinely needs the human. Review each agent's result against its assignment and the user's request. Inspect the resulting diff, verify important claims, run or direct relevant checks, reconcile conflicting findings, and decide what work remains before presenting the outcome. Do not implement directly unless the user explicitly asks you to. This guidance applies only to the root conversation. Delegated agents should carry out their assigned work directly, including an explicitly requested Fable agent."""


def last_root_assistant_model(transcript_path: str) -> str | None:
    """Return the model of the last root-conversation assistant line, or None.

    Iterates every line, parsing each as JSON and remembering the most recent
    root (non-sidechain) assistant model. Malformed lines are skipped.
    """
    last_model: str | None = None
    with open(transcript_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            if not isinstance(obj, dict):
                continue
            if obj.get("type") != "assistant":
                continue
            if obj.get("isSidechain") is True:
                continue
            message = obj.get("message")
            if not isinstance(message, dict):
                continue
            model = message.get("model")
            if isinstance(model, str):
                last_model = model
    return last_model


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0

    transcript_path = event.get("transcript_path")
    if not isinstance(transcript_path, str) or not os.path.isfile(transcript_path):
        return 0

    try:
        model = last_root_assistant_model(transcript_path)
    except OSError:
        return 0

    if not isinstance(model, str) or not model.startswith(("claude-fable-", "claude-mythos-")):
        return 0

    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": INSTRUCTION,
            }
        },
        sys.stdout,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
