# ansible-buildkite-agent

An Ansible role to install the [Buildkite Agent](https://buildkite.com/docs/agent/v3).

## Role Variables

### Core

- `buildkite_agent_allow_service_startup` - if false, this role will not attempt to re|start the buildkite-agent service. This is useful if you use alternative means to provision the registration token.
- `buildkite_agent_conf_dir` - Buildkite Agent configuration directory (default: `/etc/buildkite-agent`)
- `buildkite_agent_count` - Number of agents [if you want to run multiple per host](https://buildkite.com/docs/agent/v3/ubuntu#running-multiple-agents).
- `buildkite_agent_debug` - Flag to enable Buildkite Agent debugging.
- `buildkite_agent_executable` - The location of the buildkite-agent executable, or a shim/wrapper you wish to use.  Defaults to the default platform-specifc installation location.
- `buildkite_agent_should_install_binary` - When `yes`, use the platform-specific installation method to install the binary. When `no`, don't. Useful if you prefer to install the binary via other means.
- `buildkite_agent_start_parameters` - Command line flags to pass to the `buildkite-agent start` command to start the agent.
- `buildkite_agent_start_command` - Arguments passed verbatim to the `buildkite_agent_executable` at startup.  Wraps `buildkite_agent_start_parameters` by default - if using a shim or script for `buildkite_agent_executable`, override this instead of `buildkite_agent_start_parameters`.
- `buildkite_agent_token` - Buildkite agent registration token. Available from `https://buildkite.com/organizations/{org-slug}/agents`.

### Paths-related

- `buildkite_agent_builds_dir` - Path to where agent will perform builds.
  - Note: on Windows, this defaults to `c:/b` because long filenames still cause problems in the 21st Century.
- `buildkite_agent_hooks_dir` - Path to where agent will look for hooks.
- `buildkite_agent_plugins_dir` - Path to where agent will look for plugins.
- `buildkite_agent_logs_dir` - Path to write agent logs.
  - Note that this option only applies to Windows, and Linux platforms with [systemd versions newer than late 2017](https://github.com/systemd/systemd/issues/3991).

### Configuration settings

Variable names below map to [the agent configuration documentation](https://buildkite.com/docs/agent/v3/configuration#configuration-settings), with the same defaults, except where otherwise stated.

- `buildkite_agent_bootstrap_script`
- `buildkite_agent_git_clean_flags`
- `buildkite_agent_git_clone_flags`
- `buildkite_agent_no_color`
- `buildkite_agent_no_command_eval`
- `buildkite_agent_no_plugins`
- `buildkite_agent_no_pty`
- `buildkite_agent_no_ssh_keyscan`
- `buildkite_agent_priority`
- `buildkite_agent_queue` - Override the agent queue (default: `default`)
- `buildkite_agent_tags_from_ec2_tags`
- `buildkite_agent_tags_from_ec2`
- `buildkite_agent_tags_from_gcp`
- `buildkite_agent_tags_from_gcp_labels`
- `buildkite_agent_tags_from_host`
- `buildkite_agent_tags` - List of tags for agent; Don't use this to set `queue`, as that is handled via `buildkite_agent_queue` (default: `[]`)
- `buildkite_agent_tags_including_queue` - List of tags for the agent that include `queue`. (default: `queue={{ buildkite_agent_queue}},{{ buildkite_agent_tags }}`)
- `buildkite_agent_username` - the username to run the `buildkite-agent` process/service as.
- `buildkite_agent_user_uid` - the user ID to make the user be, if specified.
  - this is ignored on Windows.
  - This is useful because it allows the UID to be well-known, which in turn allows people to build dockers which contain a work-user with this same UID, allowing them to avoid the otherwise-usual-problems where files are written into a host-mounted volume and the UIDs mismatch, bricking the host's filesystem for future builds.
- `buildkite_agent_user_description` - the description of the user to run the `buildkite-agent` process/service as.

### Platform specific settings

#### Debian

- `buildkite_agent_allow_latest` - whether to allow the latest version to be installed, or instead use a specified version.
  - **NOTE:** ignored, on Windows (no package manager install option).
- `buildkite_agent_version` - the main semantic version number to install, when `buildkite_agent_allow_latest` is `False`.
- `buildkite_agent_build_number` - the build number (ubuntu package name includes this).
- `buildkite_agent_systemd_override_template` - the template source for the systemd unit override.

#### Windows

- `buildkite_agent_nssm_exe` - the full path to nssm.exe in case it's not on `PATH`.
- `buildkite_agent_nssm_version` - Which version of [NSSM] to use to manage the buildkite-agent process as a service.
- `buildkite_agent_user_password` - If supplied, will be used for the Windows user account, otherwise a random password will be generated.
- `buildkite_agent_windows_grant_admin` - If `True` make the `buildkite_agent_username` user be a member of the local `Administrators` group. You must assess your own security risk tradeoff with the necessity for Windows build tools needing privileges.

#### Darwin

- `buildkite_agent_homebrew_tap_url` - You could use `git@github.com:buildkite/homebrew-buildkite.git` if you clone over ssh because you find that more reliable, but your ansible connection needs an ssh key to authenticate to github then (forwarding your ssh-agent works fine). Omitted otherwise.
- `buildkite_agent_load_bash_profile` - Load `$HOME/.bash_profile` with buildkite agent environment hook. Ensures agent will load with bash environment.

### Debugging

- `buildkite_agent_hide_secrets` - if `false`, show secrets in the ansible log output. Normally they are suppressed via `no_log`.

## Example Playbook

See the [examples](./examples/) directory.

## Local workflow

```bash
# Get set up - one time. Read it first.
workflow/onboarding.sh
# Run what CI would.
workflow/ci.sh
```

[NSSM]: https://nssm.cc
