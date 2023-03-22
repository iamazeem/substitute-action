# envsubst-action

[![CI](https://github.com/iamazeem/envsubst-action/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/iamAzeem/envsubst-action/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-darkgreen.svg?style=flat-square)](https://github.com/iamAzeem/envsubst-action/blob/master/LICENSE)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/iamAzeem/envsubst-action?style=flat-square)
[![Buy Me a Coffee](https://img.shields.io/badge/Support-Buy%20Me%20A%20Coffee-orange.svg?style=flat-square)](https://www.buymeacoffee.com/iamazeem)

GitHub Action to substitute environment variables.

Tested on Linux, macOS, and Windows runners.
See [CI workflow](.github/workflows/ci.yml) for more details.

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

- [Fork](https://github.com/iamazeem/envsubst-action/fork) the repo.
- Check out the latest `main` branch.
- Create a `feature` or `bugfix` branch from `main`.
- Commit and push changes to your forked repo.
- Make sure to add tests. See [CI](./.github/workflows/ci.yml).
- Lint and fix
  [Bash](https://www.gnu.org/software/bash/manual/html_node/index.html) issues
  with [shellcheck](https://www.shellcheck.net/) online or with
  [vscode-shellcheck](https://github.com/vscode-shellcheck/vscode-shellcheck)
  extension.
- Lint and fix README Markdown issues with
  [vscode-markdownlint](https://github.com/DavidAnson/vscode-markdownlint)
  extension.
- Submit the PR.

## License

[MIT](LICENSE)
