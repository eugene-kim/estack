#!/usr/bin/env bash
# Update estack clones and plugin installs on configured SSH hosts.
set -euo pipefail

REPO_DIR="${ESTACK_SYNC_REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SKIP_REMOTE_SYNC="${ESTACK_SKIP_REMOTE_SYNC:-0}"
SSH_BIN="${ESTACK_SYNC_SSH_BIN:-ssh}"
SSH_TIMEOUT="${ESTACK_SYNC_SSH_TIMEOUT:-10}"

if [[ -f "$REPO_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$REPO_DIR/.env"
  set +a
fi

if [[ $SKIP_REMOTE_SYNC == 1 || -z ${ESTACK_SYNC_HOSTS:-} ]]; then
  exit 0
fi

cd "$REPO_DIR"

if [[ -n $(git status --porcelain) ]]; then
  echo "Remote refresh: skipped because the estack worktree has uncommitted changes." >&2
  exit 0
fi

if ! git fetch --quiet origin main; then
  echo "Remote refresh: skipped because 'git fetch origin main' failed." >&2
  exit 0
fi

LOCAL_HEAD="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git rev-parse FETCH_HEAD)"
if [[ $LOCAL_HEAD != "$REMOTE_HEAD" ]]; then
  echo "Remote refresh: skipped because HEAD does not match origin/main. Pull or push first, then refresh." >&2
  exit 0
fi

read -r -a hosts <<<"$ESTACK_SYNC_HOSTS"
failures=0

for host in "${hosts[@]}"; do
  if [[ ! $host =~ ^[A-Za-z0-9._@:-]+$ || $host == -* ]]; then
    echo "Remote refresh: skipped invalid SSH destination '$host'." >&2
    failures=$((failures + 1))
    continue
  fi

  echo
  echo "Remote refresh: syncing $host"
  if "$SSH_BIN" \
    -o BatchMode=yes \
    -o "ConnectTimeout=$SSH_TIMEOUT" \
    -o ServerAliveInterval=15 \
    -o ServerAliveCountMax=3 \
    "$host" \
    'bash -s' <<'REMOTE_SCRIPT'
set -euo pipefail
repo="$( {
  sed -n '/"estack"/,/}/s/.*"path": "\(.*\)".*/\1/p' ~/.claude/plugins/known_marketplaces.json
  sed -n '/^\[marketplaces\.estack\]/,/^\[/s/^source = "\(.*\)"/\1/p' ~/.codex/config.toml
  readlink ~/.cursor/plugins/local/estack
} 2>/dev/null | head -1 || true )"
repo="$(git -C "${repo:?no estack marketplace record found}" rev-parse --show-toplevel)"

# Older sync scripts require Claude Code and stop before pulling. Bring a clean,
# non-diverged clone forward once so it understands the Codex-only remote mode.
if ! grep -q 'ESTACK_SYNC_REQUIRE_CLAUDE' "$repo/scripts/sync.sh"; then
  cd "$repo"
  [[ -z $(git status --porcelain) ]]
  git fetch --quiet origin main
  read -r ahead behind <<<"$(git rev-list --count --left-right HEAD...FETCH_HEAD)"
  [[ $ahead -eq 0 ]]
  if [[ $behind -gt 0 ]]; then
    git pull --quiet --ff-only origin main
  fi
fi

ESTACK_SKIP_REMOTE_SYNC=1 \
ESTACK_SYNC_REQUIRE_CLAUDE=0 \
ESTACK_SYNC_STRICT=1 \
  "$repo/scripts/sync.sh"
REMOTE_SCRIPT
  then
    echo "Remote refresh: $host is synchronized."
  else
    echo "Remote refresh: $host failed; local refresh remains complete." >&2
    failures=$((failures + 1))
  fi
done

if [[ $failures -gt 0 ]]; then
  echo "Remote refresh: completed with $failures failure(s)." >&2
fi
