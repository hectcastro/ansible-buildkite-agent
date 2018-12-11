# CONTRIBUTING

## Overview

Contributions are welcome!

* Please make sure that existing tests pass, and new coverage is added where changes happen.

## Local workflow

### Setup

1. Install [pyenv]
1. Set up pyenv:

    ```bash
    pyenv install 2.7.15
    pyenv install 3.7.1
    pyenv global 2.7.15 3.7.1
    python -m pip install virtualenv
    unset PYTHONPATH
    ```

1. Set up virtualenv:

    ```bash
    python -m virtualenv .venv
    source .venv/bin/activate
    python -m pip install -r requirements.txt
    ```

### Iterate

1. Fork the repository via github.
1. Clone it, add `upstream` remote.

    ```bash
    git clone git@github.com:{you}/ansible-buildkite-agent.git
    cd ansible-buildkite-agent
    git checkout devel
    git remote add upstream git@github.com:azavea/ansible-buildkite-agent.git
    ```

1. Make a new branch. `git checkout -b {branch name}`.
1. Make some changes, covered by tests. `git commit -m "some message"`.
1. Run the tests via `molecule test`.
1. Push the changes to your github fork. `git push -u origin {branch name}`
1. Open a pull-request via github (should be a hyperlink inside the git push output to click on).

#### Once you're done

Leave the virtualenv:

```bash
deactivate
```

[pyenv]: https://github.com/pyenv/pyenv#installation
