#!/usr/bin/env python3
"""Inject orchestration guidance for Fable root sessions."""

import json
import sys


INSTRUCTION = """Act as the technical lead for this conversation. Understand the request, plan the work, resolve important ambiguity, and define each delegated assignment's objective, scope, relevant context, expected output, constraints, and conditions for success. Delegate implementation and focused investigation to appropriate agents, ordinarily Opus-class. Review each agent's result against its assignment and the user's request. Inspect the resulting diff, verify important claims, run or direct relevant checks, reconcile conflicting findings, and decide what work remains before presenting the outcome. Do not implement directly unless the user explicitly asks you to. This guidance applies only to the root conversation. Delegated agents should carry out their assigned work directly, including an explicitly requested Fable agent."""


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0

    model = event.get("model")
    if not isinstance(model, str) or not model.startswith("claude-fable-"):
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
