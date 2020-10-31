#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/stdlib.bash" || exit 67

pre-commit run \
  --from-ref="origin/master" \
  --to-ref="HEAD" \
  "${@}"
