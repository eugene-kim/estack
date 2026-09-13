#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

git init --bare --initial-branch=main "$TEST_ROOT/origin.git" >/dev/null
git clone "$TEST_ROOT/origin.git" "$TEST_ROOT/repo" >/dev/null 2>&1
git -C "$TEST_ROOT/repo" config user.name Test
git -C "$TEST_ROOT/repo" config user.email test@example.com
printf 'fixture\n' >"$TEST_ROOT/repo/file"
git -C "$TEST_ROOT/repo" add file
git -C "$TEST_ROOT/repo" commit -m fixture >/dev/null
git -C "$TEST_ROOT/repo" push origin main >/dev/null 2>&1

cat >"$TEST_ROOT/ssh" <<'EOF'
#!/usr/bin/env bash
cat >"$SSH_STDIN_LOG"
printf '%s\n' "$*" >>"$SSH_ARGS_LOG"
[[ $* != *unavailable* ]]
EOF
chmod +x "$TEST_ROOT/ssh"

cat >"$TEST_ROOT/repo/.env" <<'EOF'
ESTACK_SYNC_HOSTS="box-a unavailable invalid/host box-b"
EOF
printf '.env\n' >>"$TEST_ROOT/repo/.git/info/exclude"

export SSH_ARGS_LOG="$TEST_ROOT/ssh-args"
export SSH_STDIN_LOG="$TEST_ROOT/ssh-stdin"

ESTACK_SYNC_REPO_DIR="$TEST_ROOT/repo" \
ESTACK_SYNC_SSH_BIN="$TEST_ROOT/ssh" \
  "$REPO_DIR/scripts/refresh-remotes.sh" >"$TEST_ROOT/output" 2>"$TEST_ROOT/error"

if [[ ! -f $SSH_ARGS_LOG ]]; then
  cat "$TEST_ROOT/output" "$TEST_ROOT/error" >&2
  echo "refresh-remotes.sh did not invoke SSH" >&2
  exit 1
fi

grep -Fq 'box-a bash -s' "$SSH_ARGS_LOG"
grep -Fq 'unavailable bash -s' "$SSH_ARGS_LOG"
grep -Fq 'box-b bash -s' "$SSH_ARGS_LOG"
grep -Fq "skipped invalid SSH destination 'invalid/host'" "$TEST_ROOT/error"
grep -Fq 'completed with 2 failure(s)' "$TEST_ROOT/error"
grep -Fq "ESTACK_SKIP_REMOTE_SYNC=1 \"\$repo/scripts/sync.sh\"" "$SSH_STDIN_LOG"

mkdir -p "$TEST_ROOT/remote-home/.claude/plugins" "$TEST_ROOT/remote-repo/scripts"
cat >"$TEST_ROOT/remote-home/.claude/plugins/known_marketplaces.json" <<EOF
{"estack": {"path": "$TEST_ROOT/remote-repo"}}
EOF
cat >"$TEST_ROOT/remote-repo/scripts/sync.sh" <<'EOF'
#!/usr/bin/env bash
[[ ${ESTACK_SKIP_REMOTE_SYNC:-0} == 1 ]]
EOF
chmod +x "$TEST_ROOT/remote-repo/scripts/sync.sh"
git -C "$TEST_ROOT/remote-repo" init >/dev/null
HOME="$TEST_ROOT/remote-home" bash "$SSH_STDIN_LOG"

: >"$SSH_ARGS_LOG"
ESTACK_SKIP_REMOTE_SYNC=1 \
ESTACK_SYNC_REPO_DIR="$TEST_ROOT/repo" \
ESTACK_SYNC_SSH_BIN="$TEST_ROOT/ssh" \
  "$REPO_DIR/scripts/refresh-remotes.sh"
[[ ! -s $SSH_ARGS_LOG ]]

printf 'dirty\n' >>"$TEST_ROOT/repo/file"
ESTACK_SYNC_REPO_DIR="$TEST_ROOT/repo" \
ESTACK_SYNC_SSH_BIN="$TEST_ROOT/ssh" \
  "$REPO_DIR/scripts/refresh-remotes.sh" >"$TEST_ROOT/dirty-output" 2>"$TEST_ROOT/dirty-error"
[[ ! -s $SSH_ARGS_LOG ]]
grep -Fq 'worktree has uncommitted changes' "$TEST_ROOT/dirty-error"
git -C "$TEST_ROOT/repo" restore file

printf 'unpushed\n' >>"$TEST_ROOT/repo/file"
git -C "$TEST_ROOT/repo" add file
git -C "$TEST_ROOT/repo" commit -m unpushed >/dev/null
ESTACK_SYNC_REPO_DIR="$TEST_ROOT/repo" \
ESTACK_SYNC_SSH_BIN="$TEST_ROOT/ssh" \
  "$REPO_DIR/scripts/refresh-remotes.sh" >"$TEST_ROOT/unpushed-output" 2>"$TEST_ROOT/unpushed-error"
[[ ! -s $SSH_ARGS_LOG ]]
grep -Fq 'HEAD does not match origin/main' "$TEST_ROOT/unpushed-error"
