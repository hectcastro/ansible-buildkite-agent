# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

* Added: macOS installation now creates a user to run the service as, optionally as an administrator.

## 3.1.1: 2020-07-31

* Fixed: systemd path to buildkite agent logs; needs to be a file, not a directory.

## 3.1.0: 2020-02-26

Add support for shims/scripts wrapping the `buildkite-agent` binary, instead of directly calling the binary.
This can be useful, for example, if you need to fetch your agent registration token from a secret store before running `buildkite-agent`.

If not using a shim/script, no changes are needed.
To use a shim instead of directly calling the `buildkite-agent` binary, point `buildkite_agent_executable`
to your shim, and `buildkite_agent_start_command` to your shim's args.

* Added `buildkite_agent_executable` option.
* Added `buildkite_agent_start_command` option.

## 3.0.0: 2019-11-13

Version bump for breaking change. This is the same as 2.2.1 with corrected meta/main.yml.

## 2.2.1: 2019-11-12

* fixes to ansible 2.9.0 updates.

## 2.2.0: 2019-11-07

* porting to support ansible 2.9.0.

## 2.1.0: 2019-08-20

* `buildkite_agent_username` option for configuring the name of the user to run the service as.
* `buildkite_agent_user_description` option for configuring the description of the user to run the service as.

## 2.0.0: 2019-08-11

* require ansible `2.8.x` for `win_user_profile` support.
* take care of `win_nssm` deprecations within ansible 2.8.x.

## 1.2.1: 2019-04-25

* `buildkite_agent_nssm_exe` option.
* `buildkite_agent_tags_including_queue` option.

## 1.2.0: 2019-03-16

### Added

* `buildkite_agent_allow_service_startup` option.
* `buildkite_agent_expose_secrets` option.
* `buildkite_agent_tags_from_gcp_labels` option.
* `buildkite_agent_start_parameters` option for Debian and Windows.
* Debian `buildkite_agent_systemd_override_template` option.
    * Related - stop using systemd _template_ unit file (because `buildkite_agent_start_parameters` and v3.6.0+ allow `--spawn` for multiple job-runners).

## 1.1.0: 2018-12-11

### Added

* macOS support - #7
* Windows support - #6

## 1.0.0: 2018-04-18

### Added

* Support for Buildkite Agent v3.
* Support for Ubuntu 16.04.

### Removed

* Remove support for Ubuntu 14.04.
* Remove support for Buildkite Agent v2.

## 0.1.0

* Initial release.
