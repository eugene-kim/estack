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

It runs on `SessionStart` for the main conversation and on `SubagentStart` for
each subagent, since `SessionStart` context reaches only the main conversation
while a local session's subagents read `~/CLAUDE.local.md` like their parent.
The output names the event it answers.

The text is bundled beside this script for the same reason as the Fable lead
frame: the plugin cache holds copied files, so `home/estack-instructions.md`
links here rather than the other way round. Only the shared instructions are
injected. The Claude overlay adds the Fable frame, which
`inject-fable-orchestration.py` already injects, and guidance on `spawn_task`
chips, a tool the cloud sessions this hook was written for did not have.

HTML comments are stripped before the text is emitted, because Claude Code
strips them from the imported file in a local session and the file's trailing
comment is a note for maintainers.

In a cloud session a missing or unreadable instructions file is a packaging
bug, so the hook lets the error exit non-zero. Claude Code records a failed
hook with its stderr and carries on with the session.
"""

import json
import os
import re
import sys


def main() -> int:
    if os.environ.get("CLAUDE_CODE_REMOTE") != "true":
        return 0

    event = json.load(sys.stdin)
    instructions_path = os.path.join(
        os.path.dirname(os.path.dirname(__file__)), "estack-instructions.md"
    )
    with open(instructions_path, encoding="utf-8") as f:
        instructions = re.sub(r"<!--.*?-->", "", f.read(), flags=re.DOTALL).strip()

    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": event["hook_event_name"],
                "additionalContext": instructions,
            }
        },
        sys.stdout,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
