# envsubst-action

[![CI](https://github.com/iamazeem/envsubst-action/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/iamAzeem/envsubst-action/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-darkgreen.svg?style=flat-square)](https://github.com/iamAzeem/envsubst-action/blob/master/LICENSE)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/iamAzeem/envsubst-action?style=flat-square)
[![Buy Me a Coffee](https://img.shields.io/badge/Support-Buy%20Me%20A%20Coffee-orange.svg?style=flat-square)](https://www.buymeacoffee.com/iamazeem)

GitHub Action to substitute environment variables.

Tested on Linux, macOS, and Windows runners.
See [CI workflow](.github/workflows/ci.yml) for more details.

## Flow Diagram

```mermaid
flowchart TD
    A(env) --> |export env vars| B(env-files)
    B --> |export .env files| C(variables)
    C --> |select listed env vars only| D(prefixes)
    D --> |select env vars by prefixes| E(input-files)
    E --> |"substitute [enable-in-place: true]"| F(updated files)
    E --> |"substitute [enable-in-place: false]"| G(newly generated files with .env suffix)
    G --> |move if configured| I(output-directory)
    F --> |"[enable-dump: true]"| J(STDOUT)
    G --> |"if not moved [enable-dump: true]"| J
    I --> |"[enable-dump: true]"| J
```

Created with [mermaid.js](https://mermaid.js.org/.). See its
[flowchart](https://mermaid.js.org/syntax/flowchart.html) docs for more details.

## Usage

### Inputs

|       Input        | Required | Default | Description                                               |
| :----------------: | :------: | :-----: | :-------------------------------------------------------- |
|    `env-files`     | `false`  |         | List of `.env` files containing `VARIABLE=VALUE` per line |
|   `input-files`    |  `true`  |         | List of input files to substitute environment variables   |
|    `variables`     | `false`  |         | List of variables to substitute; the rest is ignored      |
| `output-directory` | `false`  |         | Output directory path when `enable-in-place: false`       |
| `enable-in-place`  | `false`  | `true`  | Enable/disable in-place substitution                      |
|   `enable-dump`    | `false`  | `false` | Enable/disable dumping of updated/generated files         |

### Examples

TODO

## Contribute

You may [create
issues](https://github.com/iamazeem/envsubst-action/issues/new/choose) to report
bugs or propose new features and enhancements.

PRs are always welcome. Please follow this workflow for submitting PRs:

- [Fork](https://github.com/iamazeem/envsubst-action/fork) the repo.
- Check out the latest `main` branch.
- Create a `feature` or `bugfix` branch from `main`.
- Commit and push changes to your forked repo.
- Make sure to add tests. See [CI](./.github/workflows/ci.yml).
- Lint and fix
  [Bash](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html)
  issues with [shellcheck](https://www.shellcheck.net/) online or with
  [vscode-shellcheck](https://github.com/vscode-shellcheck/vscode-shellcheck)
  extension.
- Lint and fix README Markdown issues with
  [vscode-markdownlint](https://github.com/DavidAnson/vscode-markdownlint)
  extension.
- Submit the PR.

## License

[MIT](LICENSE)
