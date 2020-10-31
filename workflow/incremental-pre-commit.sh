#!/usr/bin/env bash
# shellcheck source=lib/stdlib.bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/stdlib.bash" || exit 67

log_action "Running pre-commit, incrementally. (You can supply pre-commit flags to this script)..."
pre-commit run \
  --from-ref "origin/develop" \
  --to-ref "HEAD" \
  "${@}"
