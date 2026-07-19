#!/usr/bin/env bash
# Run an independent Codex review with estack's preferred reviewer.
set -euo pipefail

if ! command -v codex >/dev/null 2>&1 || ! codex --version >/dev/null 2>&1; then
  echo "Codex review unavailable: the 'codex' CLI is missing or not runnable." >&2
  exit 127
fi

exec codex review \
  -c 'model="gpt-5.6-terra"' \
  -c 'model_reasoning_effort="high"' \
  "$@"
