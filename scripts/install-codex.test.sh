#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p \
  "$TEST_ROOT/bin" \
  "$TEST_ROOT/cache/estack-skills-revision/estack-bro" \
  "$TEST_ROOT/other" \
  "$TEST_ROOT/skills"

printf '#!/usr/bin/env bash\nexit 0\n' > "$TEST_ROOT/bin/codex"
chmod +x "$TEST_ROOT/bin/codex"
ln -s \
  "$TEST_ROOT/cache/estack-skills-revision/estack-bro" \
  "$TEST_ROOT/skills/estack-bro"
ln -s "$TEST_ROOT/other" "$TEST_ROOT/skills/unrelated"

PATH="$TEST_ROOT/bin:$PATH" \
HOME="$TEST_ROOT/home" \
CODEX_SKILLS_DIR="$TEST_ROOT/skills" \
ESTACK_LEGACY_CLOUD_CACHE="$TEST_ROOT/cache" \
  "$REPO_DIR/scripts/install-codex.sh" > "$TEST_ROOT/output"

if [ -e "$TEST_ROOT/skills/estack-bro" ]; then
  echo "install-codex.sh left an estack direct-fallback link installed" >&2
  exit 1
fi

if [ ! -L "$TEST_ROOT/skills/unrelated" ]; then
  echo "install-codex.sh removed an unrelated personal skill" >&2
  exit 1
fi

grep -Fq \
  "removed legacy link: $TEST_ROOT/skills/estack-bro" \
  "$TEST_ROOT/output"
