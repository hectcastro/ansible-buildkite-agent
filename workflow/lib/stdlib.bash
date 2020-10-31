#!/usr/bin/env bash
#
# This sourcable script provides a standard script environment setup.
# It should be sourced directly from runnable scripts, using a line like:
#
#   # to use, fix path from running script's directory to setup.sh
#   source "$(dirname "${BASH_SOURCE[0]}")/../workflow/lib/setup.sh"
#
# Any script sourcing this should have a usage comment, where each line starts
# with a double-hash, i.e. "##":
#
#   #!/usr/bin/env bash
#   # See https://brevi.link/shell-style and https://explainshell.com
#   ## Script that does a thing
#   ## Usage: script.sh <arg>
#   ## Etc...
#   source "$(dirname "${BASH_SOURCE[0]}")/../lib/setup.sh"
#
# Sourcing this script will ensure -h/--help flags have been processed, and
# following globals are defined:
#
# - START_DIR, the original working dir when the script was invoked.
# - SCRIPT_DIR, the directory of the script that was invoked.
# - TOP_SCRIPT, the full path of the original script being invoked.
# - print_usage, function that prints usage info from file comments as
#   described above.
# - the functions from workflow/lib/log.bash
#
# Additionally, this will cause unhandled errors to print ugly stack traces and
# exit the (sub)shell. Errors should be handled using constructs such as:
#   some_cmd || log_fatal "Failed to run some command"
#   wrapped_cmd || err=$?  # then do something with $err

# prints the usage info of the executed script. The usage information must be
# put in the script using comments starting with "##"
print_usage() {
  grep '^##' "${TOP_SCRIPT}" | cut -c4-
}

# configure cwd, vars and logging
_setup_env() {
  # -ET: propagate DEBUG/RETURN/ERR traps to functions and subshells
  set -ET
  # exit on unhandled error
  set -o errexit
  # exit on unset variable
  set -o nounset
  # pipefail: any failure in a pipe causes the pipe to fail
  set -o pipefail

  if [[ -n "${SCRIPT_DEBUG:-}" ]]; then
    set -o xtrace
    # http://www.skybert.net/bash/debugging-bash-scripts-on-the-command-line/
    export PS4='# ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:-}() - [${SHLVL},${BASH_SUBSHELL},$?] '
  fi
  trap _err_trap ERR

  if [[ -z "${ALLOW_SOURCE_FROM_SOURCE:-}" && "${#BASH_SOURCE[@]}" -ne 3 ]]; then
    echo >&2 -e "setup.sh:\tMust be sourced directly from an executed script."
    return 1
  fi

  # shellcheck disable=SC2034
  # START_DIR is used elsewhere.
  START_DIR="${PWD}"
  export START_DIR
  readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[2]}")" && pwd)"
  readonly TOP_SCRIPT="${SCRIPT_DIR}/$(basename "${BASH_SOURCE[2]}")"
  if [[ -z "${SCRIPT_DIR}" ]]; then
    echo >&2 -e "setup.sh:\tFailed to determine directory containing executed script."
    return 1
  fi
  if ! cd "$(dirname "${BASH_SOURCE[0]}")/../.."; then
    echo >&2 -e "setup.sh:\tFailed to cd to repository root"
    return 1
  fi
  REPO_ROOT="$(pwd)"
  export REPO_ROOT

  if ! source workflow/lib/log.bash; then
    echo >&2 -e "setup.sh:\tFailed to source logging library"
    return 1
  fi
}

# check for -h/--help
_handle_help_flag() {
  for arg in "$@"; do
    case "${arg}" in
    -h | --help)
      print_usage
      return 1
      ;;
    --)
      return 0
      ;;
    *)
      shift
      ;;
    esac
  done
  return 0
}

_err_trap() {
  local err=$?
  local cmd="${BASH_COMMAND:-}"
  # Disable echoing all commands as this makes the traceback really hard to follow
  set +x
  if [[ -n "${SKIP_BASH_STACKTRACE:-}" ]]; then
    log_debug "SKIP_BASH_STACKTRACE was set to something; silencing bash stack-trace."
    exit "${err}"
  fi

  echo >&2 "panic: uncaught error" 1>&2
  print_traceback 1
  echo >&2 "${cmd} exited ${err}" 1>&2
}

_setup_constants() {
  export EXIT_SUCCESS=0
  export EXIT_INVALID_ARGUMENT=66
  export EXIT_FAILED_TO_SOURCE=67
  export EXIT_FAILED_TO_CD=68
  export EXIT_FAILED_AFTER_RETRY=69
  export EXIT_NOT_FOUND=70
}

# Print traceback of call stack, starting from the call location.
# An optional argument can specify how many additional stack frames to skip.
print_traceback() {
  local skip=${1:-0}
  local start=$((skip + 1))
  local end=${#BASH_SOURCE[@]}
  local curr=0
  echo >&2 "Traceback (most recent call first):" 1>&2
  for ((curr = start; curr < end; curr++)); do
    local prev=$((curr - 1))
    local func="${FUNCNAME[$curr]}"
    local file="${BASH_SOURCE[$curr]}"
    local line="${BASH_LINENO[$prev]}"
    echo >&2 "  at ${file}:${line} in ${func}()" 1>&2
  done
}

_setup_constants || exit $?
_setup_env || exit $?
# terminate immediately when usage info is requested
_handle_help_flag "$@" || exit "${EXIT_SUCCESS}"
