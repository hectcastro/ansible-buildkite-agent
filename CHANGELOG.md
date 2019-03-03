# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- `buildkite_agent_allow_service_startup` option.
- `buildkite_agent_expose_secrets` option.
- `buildkite_agent_tags_from_gcp_labels` option.
- `buildkite_agent_start_parameters` option for Debian and Windows.
- Debian `buildkite_agent_systemd_override_template` option.
  - Related - stop using systemd _template_ unit file (because `buildkite_agent_start_parameters` and v3.6.0+ allow `--spawn` for multiple job-runners).

## 1.1.0 - 2018-12-11

### Added

- macOS support - #7
- Windows support - #6

## 1.0.0 - 2018-04-18

### Added

- Support for Buildkite Agent v3.
- Support for Ubuntu 16.04.

### Removed

- Remove support for Ubuntu 14.04.
- Remove support for Buildkite Agent v2.

## 0.1.0

- Initial release.
