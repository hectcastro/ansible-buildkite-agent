#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset
[[ -n "${SCRIPT_DEBUG:-}" ]] && set -o xtrace

function log() {
  echo "${@}" >&2
}

function die() {
  log "${@}"
  exit 1
}

# Print traceback of call stack, starting from the call location.
# An optional argument can specify how many additional stack frames to skip.
print_traceback() {
  local skip=${1:-0}
  local start=$((skip + 1))
  local end=${#BASH_SOURCE[@]}
  local curr=0
  log "Traceback (most recent call first):"
  for ((curr = start; curr < end; curr++)); do
    local prev=$((curr - 1))
    local func="${FUNCNAME[$curr]}"
    local file="${BASH_SOURCE[$curr]}"
    local line="${BASH_LINENO[$prev]}"
    log "  at ${file}:${line} in ${func}()"
  done
}

_err_trap() {
  local err=$?
  local cmd="${BASH_COMMAND:-}"
  # Disable echoing all commands as this makes the traceback really hard to follow
  set +x
  log "panic: uncaught error"
  print_traceback 1
  log "${cmd} exited ${err}"
}
trap _err_trap ERR

function array_contains() {
  if [[ $1 =~ (^|[[:space:]])$2($|[[:space:]]) ]]; then
    return 0
  fi
  return 1
}

function has_user() {
  local user_name="${1?:"1st arg must be user name"}"
  log "has_user: ${user_name}"
  if /usr/bin/dscl . -list /Users | grep "^${user_name}$"; then
    log "Exists"
    return 0
  fi
  log "Does not exist"
  return 1
}

function random_string() {
  LC_CTYPE=C tr -dc 'a-zA-Z0-9' <"/dev/urandom" | 
    head -c 32 || log "random_string exit'd $?"
}

function find_new_user_id() {
  local highest_id
  highest_id="$(/usr/bin/dscl . -list /Users UniqueID | awk '{print $2}' | sort -ug | tail -n 1 | bc)"

  echo $(( highest_id + 1 ))
}

function user_home_dir() {
  local user_name="${1?:"1st arg must be user's username"}"

  echo "/Users/${user_name}"
}

function create_user() {
  local user_name="${1?:"1st arg must be user's username"}"
  local user_pass="${2?:"2nd arg must be user's password"}"
  local user_type="${3?:"3rd arg must be user's type [standard, admin]"}"
  log "Creating ${user_name} ..."

  local home_dir
  home_dir="$(user_home_dir "${user_name}")"

  if [[ -d "${home_dir}" ]]; then
    echo "Error: ${home_dir} folder exists already."
    return 1
  fi

  log "Finding new user ID..."
  local user_uid
  user_uid="$(find_new_user_id "${user_name}")"
  log "Using user ID ${user_uid} ."

  /usr/bin/dscl "." -create "/Users/${user_name}"
  /usr/bin/dscl "." -create "/Users/${user_name}" RealName "${user_name}"
  /usr/bin/dscl "." -create "/Users/${user_name}" UserShell "/bin/bash"
  /usr/bin/dscl "." -create "/Users/${user_name}" UniqueID "${user_uid}"
  /usr/bin/dscl "." -create "/Users/${user_name}" PrimaryGroupID "20" # '20' == 'staff'
  /usr/bin/dscl "." -create "/Users/${user_name}" NFSHomeDirectory "${home_dir}"

  /usr/bin/dscl "." -passwd "/Users/${user_name}" "${user_pass}"

  # https://superuser.com/questions/20420/what-is-the-difference-between-the-default-groups-on-mac-os-x
  /usr/bin/dscl "." -append /Groups/staff GroupMembership "${user_name}"
  # https://stackoverflow.com/questions/1837889/authorize-a-non-admin-developer-in-xcode-mac-os
  /usr/bin/dscl "." -append /Groups/_developer GroupMembership "${user_name}"
  if [[ "${user_type}" == "admin" ]]; then
    log "Making ${user_name} an admin..."
    /usr/bin/dscl "." -append /Groups/admin GroupMembership "${user_name}"
  fi

  # create home directory
  /bin/cp -R "/System/Library/User Template/English.lproj" "${home_dir}"
  /usr/sbin/chown -R "${user_name}:staff" "${home_dir}"
}

function write_user_defaults() {
  local user_name="${1?:"1st arg must be user's username"}"
  log "Writing user defaults for ${user_name} ..."

  local home_dir
  home_dir="$(user_home_dir "${user_name}")"

  # disable Apple ID, iCloud, Siri, etc
  local PRODUCT_VERSION
  PRODUCT_VERSION="$(sw_vers -productVersion)"
  local PRODUCT_BUILD
  PRODUCT_BUILD="$(/usr/bin/sw_vers -buildVersion)"
  local SETUP_ASSISTANT
  SETUP_ASSISTANT="${home_dir}/Library/Preferences/com.apple.SetupAssistant"
  /usr/bin/defaults write "${SETUP_ASSISTANT}" DidSeeApplePaySetup -bool TRUE
  /usr/bin/defaults write "${SETUP_ASSISTANT}" DidSeeAvatarSetup -bool TRUE
  /usr/bin/defaults write "${SETUP_ASSISTANT}" DidSeeCloudDiagnostics -bool TRUE
  /usr/bin/defaults write "${SETUP_ASSISTANT}" DidSeeCloudSetup -bool TRUE
  /usr/bin/defaults write "${SETUP_ASSISTANT}" DidSeeSiriSetup -bool TRUE
  /usr/bin/defaults write "${SETUP_ASSISTANT}" DidSeeSyncSetup -bool TRUE
  /usr/bin/defaults write "${SETUP_ASSISTANT}" GestureMovieSeen none
  /usr/bin/defaults write "${SETUP_ASSISTANT}" DidSeeSyncSetup2 -bool TRUE
  /usr/bin/defaults write "${SETUP_ASSISTANT}" DidSeeTouchIDSetup -bool TRUE
  /usr/bin/defaults write "${SETUP_ASSISTANT}" DidSeeiCloudLoginForStorageServices -bool TRUE
  /usr/bin/defaults write "${SETUP_ASSISTANT}" LastSeenCloudProductVersion "${PRODUCT_VERSION}"
  /usr/bin/defaults write "${SETUP_ASSISTANT}" LastSeenBuddyBuildVersion "${PRODUCT_BUILD}"
  /usr/bin/defaults write "${SETUP_ASSISTANT}" DidSeePrivacy -bool TRUE
  /usr/bin/defaults write "${SETUP_ASSISTANT}" DidSeeSiriSetup -bool TRUE
  /usr/bin/defaults write "${SETUP_ASSISTANT}" DidSeeAppearanceSetup -bool TRUE
  /usr/bin/defaults write "${SETUP_ASSISTANT}" DidSeeTrueTonePrivacy -bool TRUE

  /usr/sbin/chown "${user_name}" "${SETUP_ASSISTANT}.plist"
}

function configure_auto_login() {
  local user_name="${1?:"1st arg must be user's username"}"
  local user_pass="${2?:"2nd arg must be user's password"}"

  log "Setting up automatic login for ${user_name} ..."

  local kc_password_path
  kc_password_path="$(dirname "${BASH_SOURCE[0]}")/kcpassword"
  "${kc_password_path}" "${user_pass}"
  /bin/chmod 600 "/private/etc/kcpassword"
  /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser "${user_name}"
  /bin/chmod 644 "/Library/Preferences/com.apple.loginwindow.plist"
}

user_name="${1?:"1st arg must be user's name"}"
user_type="${2:-"standard"}"
auto_login="${3:-"true"}"
user_pass="${USER_PASSWORD:-"$(random_string)"}"

if has_user "${user_name}"; then
  die "Exiting: User exists ${user_name}."
fi

home_dir="$(user_home_dir "${user_name}")"
if [[ -d "${home_dir}" ]]; then
  die "Exiting: Home directory ${home_dir} already existed."
fi

create_user "${user_name}" "${user_pass}" "${user_type}"
write_user_defaults "${user_name}"
if [[ "${auto_login}" == "true" ]]; then
  configure_auto_login "${user_name}" "${user_pass}"
else
  log "Skip: auto_login was ${auto_login}. If you want the user to be automatically logged in, choose 'true'."
fi
