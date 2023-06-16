# substitute-action

[![CI](https://github.com/iamazeem/substitute-action/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/iamAzeem/substitute-action/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-darkgreen.svg?style=flat-square)](https://github.com/iamAzeem/substitute-action/blob/master/LICENSE)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/iamAzeem/substitute-action?style=flat-square)
[![Buy Me a Coffee](https://img.shields.io/badge/Support-Buy%20Me%20A%20Coffee-orange.svg?style=flat-square)](https://www.buymeacoffee.com/iamazeem)

[GitHub Action](https://docs.github.com/en/actions) to substitute environment
variables in files.

This
[composite](https://docs.github.com/en/actions/creating-actions/about-custom-actions#types-of-actions)
action uses standard
[Bash](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html)
facilities such as `ls`, `mkdir`, `mv`, `if`, `for`, `echo`, `env`, `envsubst`,
`exit`, `grep`, `cut`, `source`, etc.

It is actively being tested on Linux, macOS, and Windows runners.
See [CI workflow](.github/workflows/ci.yml) for more details.

## Features

- Supports `$VARIABLE` or `${VARIABLE}` syntax to specify variables in input
  files.
- Allows multiple `.env` files in addition to the `env` context.
- Allows nested use of variables in `.env` files from previously listed files
  and the `env` context.
- Supports multiline values but format-specific escaping is not supported. Any
  multiline substitution resulting in an ill-formed file e.g. JSON, YAML, etc.
  is the responsibility of the end user.
- Multiple input files are allowed for substitution.
- Supports filtering of the env vars by their full names and/or prefixes.
- By default, in-place substitution is performed.
- By disabling the default in-place substitution, newly substituted files are
  generated with `.env` suffixes in the same directory.
- These newly generated `.env` files may be routed to a different path by
  configuring an output directory. The output directory path will be created if
  it does not exist.
- Supports dumping of updated/generated files to STDOUT for debugging purposes.

## Flow Diagram

```mermaid
flowchart TD
    A(env) --> |export .env files| B(env-files)
    B --> |select listed env vars| C(variables)
    B --> |select prefixed env vars| D(prefixes)
    C --> |substitute| E(input-files)
    D --> |substitute| E(input-files)
    E --> |"[enable-in-place: true]"| F(updated files)
    E --> |"[enable-in-place: false]"| G(new output files with .env suffix)
    G --> |move if configured| I(output-directory)
    F --> |"[enable-dump: true]"| J(STDOUT)
    G --> |"if not moved [enable-dump: true]"| J
    I --> |"[enable-dump: true]"| J
```

## Usage

### Inputs

|       Input        | Required | Default | Description                                                    |
| :----------------: | :------: | :-----: | :------------------------------------------------------------- |
|    `env-files`     | `false`  |         | List of `.env` files containing `VARIABLE=VALUE` per line      |
|   `input-files`    |  `true`  |         | List of input files to substitute environment variables        |
|    `variables`     | `false`  |         | List of variables to substitute; the rest is ignored           |
|     `prefixes`     | `false`  |         | List of prefixes to select env vars in addition to `variables` |
| `output-directory` | `false`  |         | Output directory path when `enable-in-place: false`            |
| `enable-in-place`  | `false`  | `true`  | Enable/disable in-place substitution                           |
|   `enable-dump`    | `false`  | `false` | Enable/disable dumping of updated/generated files              |

## Examples

In the following examples, for these sample input files:

`input.json`

```json
{
  "ENV_VAR": "$ENV_VAR",
  "ENV_VAR1": "$ENV_VAR1",
  "ENV_VAR2": "$ENV_VAR2",
  "ENV_VAR3": "$ENV_VAR3",
  "TEST_VAR": "$TEST_VAR",
  "TEST_VAR1": "$TEST_VAR1",
  "TEST_VAR2": "$TEST_VAR2",
  "SAMPLE_VAR": "$SAMPLE_VAR"
}
```

`input.yaml`

```yaml
ENV_VAR: "${ENV_VAR}"
ENV_VAR1: "${ENV_VAR1}"
ENV_VAR2: "${ENV_VAR2}"
ENV_VAR3: "${ENV_VAR3}"
TEST_VAR: "${TEST_VAR}"
TEST_VAR1: "${TEST_VAR1}"
TEST_VAR2: "${TEST_VAR2}"
SAMPLE_VAR: "${SAMPLE_VAR}"
```

Only the available variables are substituted with their respective values
specified by `$VARIABLE` or `${VARIABLE}`.

### Substitute env vars from `env`

```yml
- uses: iamazeem/substitute-action@v1
  env:
    ENV_VAR1: 'env_val1'
    ENV_VAR2: 'env_val2'
  with:
    input-files: |
      input.json
      input.yaml
```

### Substitute env vars with `env` and `env-files`

```yml
- uses: iamazeem/substitute-action@v1
  env:
    ENV_VAR1: 'env_val1'
    ENV_VAR2: 'env_val2'
  with:
    env-files: |
      env-file1.env
      env-file2.env
    input-files: |
      input.json
      input.yaml
```

### Substitute env vars with `variables`

```yml
- uses: iamazeem/substitute-action@v1
  env:
    ENV_VAR1: 'env_val1'
    ENV_VAR2: 'env_val2'
    ENV_VAR3: 'env_val3'            # Ignored
  with:
    variables: |
      ENV_VAR1
      ENV_VAR2
    input-files: |
      input.json
      input.yaml
```

### Substitute env vars with `prefixes`

```yml
- uses: iamazeem/substitute-action@v1
  env:
    ENV_VAR: 'env_val'
    TEST_VAR: 'test_val'            # Ignored
    SAMPLE_VAR: 'sample_val'        # Ignored
  with:
    prefixes: |
      ENV
    input-files: |
      input.json
      input.yaml
```

### Substitute env vars with `variables` and `prefixes`

```yml
- uses: iamazeem/substitute-action@v1
  env:
    ENV_VAR1: 'env_val1'
    ENV_VAR2: 'env_val2'            # Ignored
    ENV_VAR3: 'env_val3'            # Ignored
    TEST_VAR1: 'test_val1'
    TEST_VAR2: 'test_val2'
  with:
    variables: |
      ENV_VAR1
    prefixes: |
      TEST_VAR
    input-files: |
      input.json
      input.yaml
```

## Contribute

You may [create
issues](https://github.com/iamazeem/substitute-action/issues/new/choose) to report
bugs or propose new features and enhancements.

PRs are always welcome. Please follow this workflow for submitting PRs:

- [Fork](https://github.com/iamazeem/substitute-action/fork) the repo.
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
- [mermaid.js](https://mermaid.js.org/) has been used to create the flow
  diagram. See its [flowchart](https://mermaid.js.org/syntax/flowchart.html)
  syntax to update the flow diagram if required.
- Submit the PR.

## License

[MIT](LICENSE)
