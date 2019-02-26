# ansible-buildkite-agent

An Ansible role to install the [Buildkite Agent](https://buildkite.com/docs/agent/v3).

## Role Variables

### Core

- `buildkite_agent_allow_service_startup` - if false, this role will not attempt to re|start the buildkite-agent service. This is useful if you use alternative means to provision the registration token.
- `buildkite_agent_conf_dir` - Buildkite Agent configuration directory (default: `/etc/buildkite-agent`)
- `buildkite_agent_count` - Number of agents [if you want to run multiple per host](https://buildkite.com/docs/agent/v3/ubuntu#running-multiple-agents).
- `buildkite_agent_debug` - Flag to enable Buildkite Agent debugging.
- `buildkite_agent_start_parameters` - supply parameters for the `buildkite start` command.
- `buildkite_agent_token` - Buildkite agent registration token. Available from `https://buildkite.com/organizations/{org-slug}/agents`.

### Paths-related

- `buildkite_agent_builds_dir` - Path to where agent will perform builds.
  - Note: on Windows, this defaults to `c:/b` because long filenames still cause problems in the 21st Century.
- `buildkite_agent_hooks_dir` - Path to where agent will look for hooks.
- `buildkite_agent_plugins_dir` - Path to where agent will look for plugins.

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
- `buildkite_agent_tags_from_host`
- `buildkite_agent_tags` - List of tags for agent; Don't use this to set `queue`, as that is handled via `buildkite_agent_queue` (default: `[]`)

### Platform specific settings

#### Debian

- `buildkite_agent_allow_latest` - whether to allow the latest version to be installed, or instead use a specified version.
  - **NOTE:** ignored, on Windows (no package manager install option).
- `buildkite_agent_version` - the main semantic version number to install, when `buildkite_agent_allow_latest` is `False`.
- `buildkite_agent_build_number` - the build number (ubuntu package name includes this).
- `buildkite_agent_systemd_override_template` - the template source for the systemd unit override.

#### Windows

- `buildkite_agent_nssm_version` - Which version of [NSSM] to use to manage the buildkite-agent process as a service.
- `buildkite_agent_windows_grant_admin` - If `True` make the `buildkite-agent` user be a member of the local `Administrators` group. You must assess your own security risk tradeoff with the necessity for Windows build tools needing privileges.

##### Windows gotchas

- Don't use the buildkite-agent user-profile directory for anything. It will not exist until _after_ the service has been started for the first time, because ... Windows.

#### Darwin

- `buildkite_agent_load_bash_profile` - Load `$HOME/.bash_profile` with buildkite agent environment hook. Ensures agent will load with bash environment.

### Debugging

- `buildkite_agent_hide_secrets` - if `false`, show secrets in the ansible log output. Normally they are suppressed via `no_log`.

## Example Playbook

See the [examples](./examples/) directory.

[NSSM]: https://nssm.cc
