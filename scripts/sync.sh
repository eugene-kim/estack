#!/usr/bin/env bash
# Keep this clone, and the plugin installs built from it, in sync with
# origin/main.
#
# Two kinds of drift happen when the repo is edited from more than one machine:
# the clone falls behind origin/main, and the clone gets pulled but never
# refreshed, so the installed plugin snapshot lags the working tree. This
# script detects both, fixes them when it is safe to do so unattended, and
# leaves a state file that the SessionStart hook reports.
#
# Designed to be idempotent, non-interactive, and cron-safe: it never prompts,
# never leaves the repo mid-operation, and never exits non-zero for a condition
# it has already recorded in the state file.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BRANCH="main"
REMOTE="origin"

# Every path and timeout is env-overridable so the classification logic can be
# exercised against throwaway fixture clones without touching the live install.
STATE_DIR="${ESTACK_SYNC_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/estack}"
STATE_FILE="$STATE_DIR/sync-state.json"
LOG_FILE="$STATE_DIR/sync.log"
LOCK_FILE="$STATE_DIR/sync.lock"
INSTALLED_PLUGINS="${ESTACK_SYNC_INSTALLED_PLUGINS:-$HOME/.claude/plugins/installed_plugins.json}"
REFRESH_CMD="${ESTACK_SYNC_REFRESH_CMD:-$REPO_DIR/scripts/refresh.sh}"
FETCH_TIMEOUT="${ESTACK_SYNC_FETCH_TIMEOUT:-120}"
REFRESH_TIMEOUT="${ESTACK_SYNC_REFRESH_TIMEOUT:-900}"
CLAUDE_PROBE_TIMEOUT="${ESTACK_SYNC_CLAUDE_PROBE_TIMEOUT:-60}"

DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: sync.sh [--dry-run]

Fast-forwards this estack clone to origin/main and reinstalls the plugin when
either the clone or the installed snapshot has drifted. Writes
sync-state.json / sync.log under $XDG_STATE_HOME/estack (default
~/.local/state/estack).

  --dry-run   Classify and report the action that would be taken. Fetches (so
              the classification is accurate) but performs no pull, no
              refresh, and no state write.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

# --- output -----------------------------------------------------------------

# Human-readable trail. Cron discards stdout, so a dry run prints and a real
# run also appends to the log.
log() {
  local line
  line="$(date -u '+%Y-%m-%dT%H:%M:%SZ') $*"
  printf '%s\n' "$line"
  if [[ $DRY_RUN -eq 0 ]]; then
    printf '%s\n' "$line" >>"$LOG_FILE"
  fi
}

json_escape() {
  local s=${1-}
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

json_string_or_null() {
  if [[ -z ${1-} ]]; then
    printf 'null'
  else
    printf '"%s"' "$(json_escape "$1")"
  fi
}

# The state file is rewritten whole on every run, via a temp file and an atomic
# rename, so a reader (the SessionStart hook) never sees a half-written file
# and always parses valid JSON.
write_state() {
  local outcome=$1 detail=$2
  if [[ $DRY_RUN -eq 1 ]]; then
    return 0
  fi

  local tmp
  tmp="$(mktemp "$STATE_FILE.XXXXXX")"
  cat >"$tmp" <<EOF
{
  "schema": 1,
  "timestamp": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "outcome": "$(json_escape "$outcome")",
  "repo_dir": "$(json_escape "$REPO_DIR")",
  "head_before": $(json_string_or_null "${HEAD_BEFORE-}"),
  "head_after": $(json_string_or_null "${HEAD_AFTER-}"),
  "remote_head": $(json_string_or_null "${REMOTE_HEAD-}"),
  "ahead": ${AHEAD:-null},
  "behind": ${BEHIND:-null},
  "dirty": ${DIRTY_JSON:-null},
  "installed_sha": $(json_string_or_null "${INSTALLED_SHA-}"),
  "detail": "$(json_escape "$detail")"
}
EOF
  mv -f "$tmp" "$STATE_FILE"
}

# Record the outcome, say it out loud, and stop. Exit 0 even for the error
# outcomes: a recorded, reported failure is not a reason to make cron mail
# noise, and the hook is what surfaces it.
# The outcome alone says whether the install changed (updated/refreshed did,
# nothing else does), so there is no separate restart flag to keep in step.
finish() {
  local outcome=$1 detail=$2
  log "outcome=$outcome $detail"
  write_state "$outcome" "$detail"
  exit 0
}

# --- lock -------------------------------------------------------------------

# Overlapping cron runs must not both pull and refresh; a second run that finds
# the lock held has nothing useful to add, so it leaves quietly. A dry run
# mutates nothing, so it does not need the lock (and must not create the state
# directory to take one).
if [[ $DRY_RUN -eq 0 ]]; then
  mkdir -p "$STATE_DIR"
  exec 9>"$LOCK_FILE"
  if ! flock -n 9; then
    exit 0
  fi
fi

# --- inspect ----------------------------------------------------------------

cd "$REPO_DIR"

# Everything below assumes a working git checkout. Without this guard the first
# git call fails, `set -e` aborts, and nothing is recorded -- the silent failure
# this script exists to prevent. Fail loudly into the state file instead.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  finish "error-repo" "$REPO_DIR is not a git worktree; cannot determine sync state"
fi

# refresh.sh registers REPO_DIR as each host's local plugin marketplace by
# absolute path, so a run from a linked worktree would point both installs at a
# throwaway directory. Make that structural instead of conventional.
if [[ "$(git rev-parse --git-common-dir)" != "$(git rev-parse --git-dir)" ]]; then
  finish "error-repo" \
    "$REPO_DIR is a linked worktree; run sync from the main clone so refresh.sh registers the right marketplace path"
fi

HEAD_BEFORE="$(git rev-parse HEAD)"
HEAD_AFTER="$HEAD_BEFORE"

if [[ -n "$(git status --porcelain)" ]]; then
  DIRTY=1
  DIRTY_JSON=true
else
  DIRTY=0
  DIRTY_JSON=false
fi

# The installed snapshot's commit. Claude Code records the full sha it installed
# from, which is the only reliable way to tell "pulled but never refreshed"
# from "already refreshed". An unreadable file or an absent entry leaves this
# empty, which is treated as drift below: refreshing again is harmless, and
# skipping a needed refresh is not.
read_installed_sha() {
  [[ -r $INSTALLED_PLUGINS ]] || return 0
  command -v python3 >/dev/null 2>&1 || return 0
  INSTALLED_PLUGINS="$INSTALLED_PLUGINS" python3 - <<'PY' 2>/dev/null || true
import json, os

try:
    with open(os.environ["INSTALLED_PLUGINS"], encoding="utf-8") as f:
        data = json.load(f)
    entries = data["plugins"]["estack@estack"]
    sha = entries[0]["gitCommitSha"]
except (OSError, ValueError, KeyError, IndexError, TypeError):
    raise SystemExit(0)
if isinstance(sha, str):
    print(sha.strip())
PY
}

INSTALLED_SHA="$(read_installed_sha)"

# Assert a real, runnable `claude` before asking refresh.sh to do the Claude
# half of its job. Two traps make `command -v` alone insufficient here:
# interactively `claude` is a shell *alias* while the executable lives in
# ~/.local/bin, and refresh.sh guards its whole Claude Code section on
# `command -v claude`, printing "not on PATH; skipped" and still exiting 0. Run
# from cron's minimal PATH that combination silently skips the reinstall on
# every run while looking like success, so probe the binary the way refresh.sh
# probes codex and make a missing one a loud, recorded error instead. The cron
# entry invokes this script through a login shell so the PATH that installed
# the node-based launcher is present; do not paper over it with a hardcoded nvm
# path, which breaks at the next Node upgrade.
claude_runnable() {
  local bin
  bin="$(command -v claude 2>/dev/null || true)"
  [[ -n $bin && -x $bin ]] || return 1
  timeout "$CLAUDE_PROBE_TIMEOUT" claude --version >/dev/null 2>&1
}

# refresh.sh skips its Codex half with a warning when `codex` is missing or
# unrunnable rather than failing. That is the right call -- Claude Code is the
# host this script is protecting -- but a half-done reinstall should not be
# recorded as an unqualified success, so probe it and note it in the outcome.
codex_runnable() {
  local bin
  bin="$(command -v codex 2>/dev/null || true)"
  [[ -n $bin && -x $bin ]] || return 1
  timeout "$CLAUDE_PROBE_TIMEOUT" codex --version >/dev/null 2>&1
}

# --- fetch ------------------------------------------------------------------

# A hung fetch in cron would hold the lock forever, so bound it. Network
# failure is a recorded outcome, not a crash.
if ! timeout "$FETCH_TIMEOUT" git fetch --quiet "$REMOTE" "$BRANCH" 2>&1; then
  finish "error-fetch" "git fetch $REMOTE $BRANCH failed or timed out after ${FETCH_TIMEOUT}s"
fi

REMOTE_REF="refs/remotes/$REMOTE/$BRANCH"
if ! REMOTE_HEAD="$(git rev-parse --verify --quiet "$REMOTE_REF")"; then
  finish "error-fetch" "$REMOTE_REF does not exist after fetch"
fi

# left = commits on HEAD only (ahead), right = commits on origin/main only
# (behind).
read -r AHEAD BEHIND <<<"$(git rev-list --count --left-right "HEAD...$REMOTE_REF")"

# --- classify ---------------------------------------------------------------

NEED_PULL=0
NEED_REFRESH=0
if [[ $INSTALLED_SHA == "$HEAD_BEFORE" ]]; then
  CACHE_DRIFT=0
else
  CACHE_DRIFT=1
fi

log "head=$HEAD_BEFORE remote=$REMOTE_HEAD ahead=$AHEAD behind=$BEHIND dirty=$DIRTY installed=${INSTALLED_SHA:-unknown}"

if [[ $AHEAD -gt 0 && $BEHIND -gt 0 ]]; then
  # Reconciling a divergence needs a merge, rebase, or reset. All three can
  # conflict and none of them belong in an unattended job, so stop and say so.
  finish "blocked-diverged" \
    "local main has diverged from $REMOTE/$BRANCH ($AHEAD ahead, $BEHIND behind); resolve by hand"
fi

if [[ $BEHIND -gt 0 ]]; then
  NEED_PULL=1
  NEED_REFRESH=1
elif [[ $CACHE_DRIFT -eq 1 ]]; then
  # Up to date with the remote (or carrying unpushed local commits, which are
  # never pulled over) but the installed snapshot is built from a different
  # commit: refresh only, no git movement.
  NEED_REFRESH=1
fi

if [[ $NEED_PULL -eq 0 && $NEED_REFRESH -eq 0 ]]; then
  detail="clone and install both at $HEAD_BEFORE"
  if [[ $DIRTY -eq 1 ]]; then
    detail="$detail (worktree has uncommitted changes)"
  fi
  if [[ $AHEAD -gt 0 ]]; then
    detail="$detail ($AHEAD unpushed local commit(s))"
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    log "dry-run: would do nothing"
  fi
  finish "up-to-date" "$detail"
fi

# A dirty worktree blocks both halves: pulling risks a conflict this script
# must not resolve, and refreshing would install uncommitted work as though it
# were the committed source of truth. Only report it as blocking when there was
# something to do, so a normal mid-edit worktree does not raise an alarm on
# every run.
if [[ $DIRTY -eq 1 ]]; then
  pending=""
  if [[ $NEED_PULL -eq 1 ]]; then
    pending="$BEHIND commit(s) to fast-forward"
  fi
  if [[ $CACHE_DRIFT -eq 1 ]]; then
    if [[ -n $pending ]]; then
      pending="$pending; "
    fi
    pending="${pending}installed snapshot at ${INSTALLED_SHA:-unknown} != HEAD $HEAD_BEFORE"
  fi
  finish "blocked-dirty" "uncommitted changes in $REPO_DIR; skipped ($pending)"
fi

if [[ $DRY_RUN -eq 1 ]]; then
  if [[ $NEED_PULL -eq 1 ]]; then
    log "dry-run: would fast-forward $HEAD_BEFORE -> $REMOTE_HEAD ($BEHIND commit(s)), then run $REFRESH_CMD"
  else
    log "dry-run: would run $REFRESH_CMD only (installed ${INSTALLED_SHA:-unknown} != HEAD $HEAD_BEFORE)"
  fi
  if claude_runnable; then
    log "dry-run: 'claude' resolves and is runnable"
  else
    log "dry-run: WARNING 'claude' is missing or not runnable; a real run would record error-no-claude"
  fi
  exit 0
fi

# --- act --------------------------------------------------------------------

# Refresh reinstalls into both hosts, so assert the Claude binary before moving
# any git state: a run that pulls and then silently skips half the reinstall is
# worse than one that pulls nothing.
if ! claude_runnable; then
  finish "error-no-claude" \
    "no runnable 'claude' executable on PATH ($(command -v claude 2>/dev/null || echo 'not found')); refusing to run refresh.sh, which would silently skip its Claude Code half"
fi

if [[ $NEED_PULL -eq 1 ]]; then
  # Fast-forward only, always. This script has no business creating merge
  # commits, rewriting local history, or discarding work, so if the pull cannot
  # be a pure fast-forward it must fail rather than improvise.
  if ! timeout "$FETCH_TIMEOUT" git pull --quiet --ff-only "$REMOTE" "$BRANCH" 2>&1; then
    finish "error-fetch" "git pull --ff-only $REMOTE $BRANCH failed"
  fi
  HEAD_AFTER="$(git rev-parse HEAD)"
  log "fast-forwarded $HEAD_BEFORE -> $HEAD_AFTER"
fi

# Check refresh.sh's own exit status. Deliberately not piped through
# tail/grep/head: the pipeline's status would be the filter's, so a failing
# refresh would read as success.
set +e
timeout "$REFRESH_TIMEOUT" "$REFRESH_CMD" >>"$LOG_FILE" 2>&1
refresh_rc=$?
set -e

if [[ $refresh_rc -ne 0 ]]; then
  finish "error-refresh" "$REFRESH_CMD exited $refresh_rc (see $LOG_FILE); repo is at $HEAD_AFTER"
fi

INSTALLED_SHA="$(read_installed_sha)"

CODEX_NOTE=""
if ! codex_runnable; then
  CODEX_NOTE="; Codex half skipped (no runnable 'codex' on PATH)"
fi

# refresh.sh only rebuilds the plugin cache; Claude Code reads plugins at
# startup, so a session already open when this ran keeps the old snapshot.
if [[ $NEED_PULL -eq 1 ]]; then
  finish "updated" \
    "fast-forwarded $HEAD_BEFORE -> $HEAD_AFTER ($BEHIND commit(s)) and reinstalled the plugin$CODEX_NOTE"
fi

finish "refreshed" \
  "reinstalled the plugin at $HEAD_AFTER (installed snapshot had drifted)$CODEX_NOTE"
