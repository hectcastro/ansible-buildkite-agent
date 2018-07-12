# ansible-buildkite-agent

An Ansible role to install the [Buildkite Agent](https://buildkite.com/docs/agent/v3).

## Role Variables

- `buildkite_agent_count` - Number of agents [if you want to run multiple per host](https://buildkite.com/docs/agent/v3/ubuntu#running-multiple-agents).
- `buildkite_agent_conf_dir` - Buildkite Agent configuration directory (default: `/etc/buildkite-agent`)
- `buildkite_agent_token` - Buildkite API token
- `buildkite_agent_debug` - Flag to enable Buildkite Agent debugging

Variable names below map to [the agent configuration documentation](https://buildkite.com/docs/agent/v3/configuration#configuration-settings), with the same defaults, except where otherwise stated.

- `buildkite_agent_priority`
- `buildkite_agent_queue` - Override the agent queue (default: `default`)
- `buildkite_agent_tags` - List of tags for agent; Don't use this to set `queue`, as that is handled via `buildkite_agent_queue` (default: `[]`)
- `buildkite_agent_tags_from_ec2`
- `buildkite_agent_tags_from_ec2_tags`
- `buildkite_agent_tags_from_gcp`
- `buildkite_agent_tags_from_host`
- `buildkite_agent_bootstrap_script`
- `buildkite_agent_git_clone_flags`
- `buildkite_agent_git_clean_flags`
- `buildkite_agent_no_pty`
- `buildkite_agent_no_ssh_keyscan`
- `buildkite_agent_no_command_eval`
- `buildkite_agent_no_plugins`
- `buildkite_agent_no_color`

## Example Playbook

See the [examples](./examples/) directory.
