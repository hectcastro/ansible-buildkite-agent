#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/stdlib.bash" || exit 67

workflow/incremental-pre-commit.sh
