#!/usr/bin/env python3
"""Inject estack's shared home instructions into Claude Code cloud sessions.

On a machine where `scripts/refresh.sh` has run, Claude Code loads the shared
instructions through `~/CLAUDE.local.md`, which links to the Claude overlay
that imports them. A cloud session never reads that file: its checkout is not
under the home directory, so the home `CLAUDE.local.md` is not on the path
Claude Code walks for instruction files, and the container starts fresh each
session. The plugin's hooks are the only estack code a cloud session runs, so
this hook emits the instructions there. Claude Code sets `CLAUDE_CODE_REMOTE`
to `true` in its cloud sessions, and gating on it keeps local sessions from
loading the same text twice.

The text is bundled beside this script for the same reason as the Fable lead
frame: the plugin cache holds copied files, so `home/estack-instructions.md`
links here rather than the other way round. Only the shared instructions are
injected. The Claude overlay adds the Fable frame, which
`inject-fable-orchestration.py` already injects, and guidance on `spawn_task`
chips, a tool the cloud sessions this hook was written for did not have.

Any error (unreadable file, empty text) results in a silent exit 0.
"""

import json
import os
import sys


def main() -> int:
    if os.environ.get("CLAUDE_CODE_REMOTE") != "true":
        return 0

    instructions_path = os.path.join(
        os.path.dirname(os.path.dirname(__file__)), "estack-instructions.md"
    )
    try:
        with open(instructions_path, encoding="utf-8") as f:
            instructions = f.read().strip()
    except OSError:
        return 0
    if not instructions:
        return 0

    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": instructions,
            }
        },
        sys.stdout,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
