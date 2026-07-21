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

The guidance text has a single source of truth: `home/fable-lead.md` in the
estack repo, which ~/CLAUDE.local.md imports at session start. This hook reads
that same file rather than embedding its own copy, so the two can never drift.
~/CLAUDE.local.md is a symlink into the repo's `home/` dir, so resolving it to
its real path and reading the sibling `fable-lead.md` recovers the source. If it
cannot be read (not installed, not a symlink, moved), the hook exits 0 silently
and the guidance simply isn't re-asserted on that boundary.
"""

import json
import os
import sys


def fable_instruction() -> str | None:
    """Return the Fable lead frame text, or None if it cannot be read.

    Resolves ~/CLAUDE.local.md (honoring CLAUDE_LOCAL_MD, as the installer does)
    to its real path and reads the sibling `fable-lead.md`.
    """
    local_md = os.environ.get("CLAUDE_LOCAL_MD") or os.path.join(
        os.path.expanduser("~"), "CLAUDE.local.md"
    )
    try:
        frame_path = os.path.join(
            os.path.dirname(os.path.realpath(local_md)), "fable-lead.md"
        )
        with open(frame_path, encoding="utf-8") as f:
            text = f.read().strip()
    except OSError:
        return None
    return text or None


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

    instruction = fable_instruction()
    if not instruction:
        return 0

    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": instruction,
            }
        },
        sys.stdout,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
