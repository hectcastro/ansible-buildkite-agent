# ansible-buildkite-agent

An Ansible role to install the [Buildkite Agent](https://github.com/buildkite/agent).

## Role Variables

### common

- `buildkite_agent_count` - Number of agents [if you want to run multiple per host](https://buildkite.com/docs/agent/v3/ubuntu#running-multiple-agents).
- `buildkite_agent_major_version` - whether to install agent v`2` or `3`. Defaults to `3`.
- `buildkite_agent_conf_dir` - Buildkite Agent configuration directory (default: `/etc/buildkite-agent`)
- `buildkite_agent_token` - Buildkite API token
- `buildkite_agent_debug` - Flag to enable Buildkite Agent debugging

### [v3-specific](https://buildkite.com/docs/agent/v3/configuration#configuration-settings)

The variable names map to [the agent configuration documentation](https://buildkite.com/docs/agent/v3/configuration#configuration-settings), with the same defaults, except where otherwise stated.

- `buildkite_agent_priority`
- `buildkite_agent_queue` - override the agent queue from the default `default`
- `buildkite_agent_tags` - array - don't use this to set `queue`, that is explicitly handled via `buildkite_agent_queue` above.
- `buildkite_agent_tags_from_ec2`
- `buildkite_agent_tags_from_ec2_tags`
- `buildkite_agent_tags_from_gcp`
- `buildkite_agent_bootstrap_script`
- `buildkite_agent_git_clone_flags`
- `buildkite_agent_git_clean_flags`
- `buildkite_agent_no_pty`
- `buildkite_agent_no_ssh_keyscan`
- `buildkite_agent_no_command_eval`
- `buildkite_agent_no_plugins`
- `buildkite_agent_no_color`


### v2-specific

- `buildkite_agent_name` - Buildkite Agent name
- `buildkite_agent_meta_data` - Buildkite Agent metadata (default: `queue=default`)
- `buildkite_agent_meta_data_ec2_tags` - Flag to determine if EC2 metadata tags should be added to the agent

## Example Playbook

See the [examples](./examples/) directory.
