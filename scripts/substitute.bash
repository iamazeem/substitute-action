#!/bin/bash

# error handling

set -eE -o functrace

failure() {
  local LINE="$1"
  local CMD="$2"
  echo >&2 "[FATAL] $LINE: $CMD"
  echo "::error::$LINE: $CMD"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

# functions

validate_envsubst() {
  echo "::group::Validating envsubst command"

  if ! which envsubst; then
    echo "envsubst command not found!"
    exit 1
  fi

  envsubst --version

  echo "::endgroup::"
}

validate_env_files() {
  if [[ -n $ENV_FILES ]]; then
    echo "env-files:"
    for ENV_FILE in $ENV_FILES; do
      if [[ ! -f $ENV_FILE ]]; then
        echo "[$ENV_FILE] file does not exist!"
        exit 1
      else
        echo "- $ENV_FILE"
      fi
    done
  fi
}

validate_input_files() {
  if [[ -z $INPUT_FILES ]]; then
    echo "input-files cannot be empty!"
    exit 1
  else
    echo "input-files:"
    for INPUT_FILE in $INPUT_FILES; do
      if [[ ! -f $INPUT_FILE ]]; then
        echo "[$INPUT_FILE] file does not exist!"
        exit 1
      else
        echo "- $INPUT_FILE"
      fi
    done
  fi
}

validate_variables() {
  if [[ -n $VARIABLES ]]; then
    echo "variables:"
    for VARIABLE in $VARIABLES; do
      echo "- $VARIABLE"
    done
  fi
}

validate_inputs() {
  echo "::group::Validating inputs"

  validate_env_files
  validate_input_files
  validate_variables

  echo "enable-in-place: [$ENABLE_IN_PLACE]"
  echo "enable-dump: [$ENABLE_DUMP]"

  echo "::endgroup::"
}

source_env_files() {
  echo "::group::Sourcing env files"

  set -a
  for ENV_FILE in $ENV_FILES; do
    echo "Sourcing [$ENV_FILE]"
    . "$ENV_FILE"
  done
  set +a

  echo "::endgroup::"
}

substitute() {
  local VARS=""
  for VARIABLE in $VARIABLES; do
    if [[ -n $VARS ]]; then
      VARS+=" "
    fi
    VARS+="\$$VARIABLE"
  done

  for INPUT_FILE in $INPUT_FILES; do
    echo "::group::Substituting [$INPUT_FILE]"
    OUTPUT_FILE="$INPUT_FILE.env"
    envsubst "$VARS" < "$INPUT_FILE" > "$OUTPUT_FILE"
    if [[ $ENABLE_IN_PLACE == true ]]; then
      mv "$OUTPUT_FILE" "$INPUT_FILE"
      echo "File updated successfully! [$INPUT_FILE]"
      if [[ $ENABLE_DUMP == true ]]; then
        echo "Dump [$INPUT_FILE]:"
        cat -n "$INPUT_FILE"
      fi
    else
      echo "New file generated successfully! [$OUTPUT_FILE] "
      if [[ $ENABLE_DUMP == true ]]; then
        echo "Dump [$OUTPUT_FILE]"
        cat -n "$OUTPUT_FILE"
      fi
    fi
    echo "::endgroup::"
  done
}

# start

validate_envsubst
validate_inputs
source_env_files
substitute
