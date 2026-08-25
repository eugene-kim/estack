#!/usr/bin/env python3
"""Report estack sync drift at session start.

`scripts/sync.sh` runs unattended (cron) and records what it did in
`$XDG_STATE_HOME/estack/sync-state.json`. This hook surfaces the states sync.sh
refused to fix on its own, notes a reinstall that has just landed, and reports a
state file old enough to mean the scheduled job has stopped running.

It does not tell the running session to restart. Hooks ship inside the plugin,
so the plugin is already loaded by the time this runs: a session that reads a
just-refreshed state loaded the new snapshot at startup. Only a session that was
already open when the sync ran keeps the stale one, and no SessionStart hook can
reach that session.

It reads one small JSON file and nothing else -- no network, no git, no
subprocess -- so it adds no perceptible session-start latency.

Silent by design when there is nothing worth interrupting for: an up-to-date,
recent state prints nothing. It is also silent on every failure mode (missing
file, bad JSON, unreadable path, unexpected schema), because a drift report is
never worth failing a session start over.
"""

import json
import os
import sys
from datetime import datetime, timedelta, timezone

# The scheduled sync runs hourly, so a state file more than a few hours old
# means the job itself has stopped -- and drift it would have caught is
# invisible from here otherwise. Widen this if the schedule is ever loosened.
STALE_AFTER = timedelta(hours=6)

# Outcomes sync.sh recorded because it deliberately refused to act, or could
# not. Each needs a human, so each is always reported.
BLOCKED_OUTCOMES = {
    "blocked-dirty": "estack sync is blocked by uncommitted changes in the clone",
    "blocked-diverged": "estack sync is blocked: local main has diverged from origin/main",
    "error-fetch": "estack sync could not reach origin",
    "error-refresh": "estack sync ran scripts/refresh.sh and it failed",
    "error-no-claude": "estack sync found no runnable 'claude' executable, so it refused to refresh",
    "error-repo": "estack sync could not read the clone as a git worktree",
}


def state_path() -> str:
    """Return the sync state file path, honoring the same overrides as sync.sh."""
    state_dir = os.environ.get("ESTACK_SYNC_STATE_DIR")
    if not state_dir:
        base = os.environ.get("XDG_STATE_HOME") or os.path.join(
            os.path.expanduser("~"), ".local", "state"
        )
        state_dir = os.path.join(base, "estack")
    return os.path.join(state_dir, "sync-state.json")


def load_state(path: str) -> dict | None:
    """Return the parsed state object, or None if it cannot be used."""
    try:
        with open(path, encoding="utf-8") as f:
            state = json.load(f)
    except (OSError, ValueError):
        return None
    return state if isinstance(state, dict) else None


def age(state: dict) -> timedelta | None:
    """Return how long ago the state was written, or None if untellable."""
    stamp = state.get("timestamp")
    if not isinstance(stamp, str):
        return None
    try:
        written = datetime.fromisoformat(stamp.replace("Z", "+00:00"))
    except ValueError:
        return None
    if written.tzinfo is None:
        written = written.replace(tzinfo=timezone.utc)
    return datetime.now(timezone.utc) - written


def message(state: dict) -> str | None:
    """Return the report for this state, or None if there is nothing to say."""
    outcome = state.get("outcome")
    if not isinstance(outcome, str):
        return None
    detail = state.get("detail")
    detail = detail if isinstance(detail, str) else ""

    lines: list[str] = []

    if outcome in BLOCKED_OUTCOMES:
        lines.append(f"{BLOCKED_OUTCOMES[outcome]}.")
        if detail:
            lines.append(f"Details: {detail}")
        lines.append(
            "The estack clone and the installed plugin may be out of date until this "
            "is resolved by hand. Run `scripts/sync.sh --dry-run` in the clone to see "
            "the current classification."
        )
    elif outcome in ("updated", "refreshed"):
        head = state.get("head_after")
        head = head[:12] if isinstance(head, str) else "a newer commit"
        lines.append(
            f"The scheduled estack sync reinstalled the plugin at {head}."
        )
        if detail:
            lines.append(f"Details: {detail}")
        lines.append(
            "A session that was already open when that ran still holds the old "
            "snapshot and needs a restart; one started afterwards does not."
        )

    elapsed = age(state)
    if elapsed is not None and elapsed > STALE_AFTER:
        lines.append(
            f"The estack sync state was last written {int(elapsed.total_seconds() // 3600)}h "
            "ago, which suggests the scheduled sync is no longer running. Check the "
            "cron entry for scripts/sync.sh."
        )

    if not lines:
        return None

    lines.append("Mention this to the user; do not act on it unasked.")
    return "\n".join(lines)


def main() -> int:
    try:
        json.load(sys.stdin)
    except ValueError:
        return 0

    state = load_state(state_path())
    if state is None:
        return 0

    try:
        text = message(state)
    except Exception:
        # A schema surprise must never take a session start with it.
        return 0
    if not text:
        return 0

    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": text,
            }
        },
        sys.stdout,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
