#!/usr/bin/env python3
"""Inject Fable-root orchestration guidance at session boundaries.

At startup there is no assistant message from which to recover the active
model, so the conditional guidance is emitted for every Claude model. Its first
sentence limits it to Fable-class roots. On resume and compact, the transcript
contains enough history to inject it only for a Fable-class root.

Resume/compact detection reads the JSONL transcript at `transcript_path` and
finds the last root-conversation assistant model (line["message"]["model"] on
lines where line["type"] == "assistant"). Sidechain lines (subagent messages,
line["isSidechain"] is True) are skipped because subagents may run a different
model than the root conversation. Fable-class means the Fable and Mythos model
tiers (they share an underlying model) and excludes Opus, Sonnet, and Haiku; if
that model starts with "claude-fable-" or "claude-mythos-", the guidance is
emitted; otherwise nothing is emitted. Any error (missing key,
missing file, malformed JSON) results in a silent exit 0. The guidance text is
bundled beside this script so local and remote plugin installs use the same
source that the home Claude overlay imports.
"""

import json
import os
import sys


def fable_instruction() -> str | None:
    """Return the bundled Fable lead frame text, or None if unavailable."""
    frame_path = os.path.join(
        os.path.dirname(os.path.dirname(__file__)), "fable-lead.md"
    )
    try:
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

    instruction = fable_instruction()
    if not instruction:
        return 0

    if event.get("source") != "startup":
        transcript_path = event.get("transcript_path")
        if not isinstance(transcript_path, str) or not os.path.isfile(transcript_path):
            return 0

        try:
            model = last_root_assistant_model(transcript_path)
        except OSError:
            return 0

        if not isinstance(model, str) or not model.startswith(
            ("claude-fable-", "claude-mythos-")
        ):
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
