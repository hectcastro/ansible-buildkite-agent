#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/stdlib.bash" || exit 67

log_warn "This script will check whether your computer is set up ok for development. You should read it first. If it detects that you're not, it will fail and try to tell you what to do to proceed."
read -n1 -r -p "Press any key to continue..."

command -v pyenv >"/dev/null" || log_fatal "You need pyenv. Please use https://github.com/pyenv/pyenv-installer. It must be init'd within your shell, also, so when you cd into here, the right python and virtualenv are selected."
pyenv virtualenv --help >"/dev/null" || log_fatal "You need pyenv-virtualenv. Please use https://github.com/pyenv/pyenv-installer"

! [[ "$(python3 --version)" == "$(cat .python-version) ansible-buildkite-agent" ]] || log_fatal "Please run \`pyenv install && pyenv virtualenv ansible-buildkite-agent\`"

log_action "Installing pip requirements..."
pip3 install -r requirements.txt
