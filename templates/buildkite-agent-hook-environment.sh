#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

# shellcheck disable=SC1090
[[ -f "${HOME}/.bash_profile" ]] && source "${HOME}/.bash_profile"
