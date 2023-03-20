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

validate_output_directory() {
  if [[ $ENABLE_IN_PLACE == true ]]; then
    return
  elif [[ -n $OUTPUT_DIRECTORY ]]; then
    local STATUS=""
    if [[ -d $OUTPUT_DIRECTORY ]]; then
      STATUS="EXISTS"
    else
      mkdir -p "$OUTPUT_DIRECTORY"
      STATUS="CREATED"
    fi
    echo "output-directory: [$OUTPUT_DIRECTORY] [$STATUS]"
  fi
}

validate_inputs() {
  echo "::group::Validating inputs"

  validate_env_files
  validate_input_files
  validate_variables
  validate_output_directory

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
  if [[ -n $VARIABLES ]]; then
    local VARS=""
    for VARIABLE in $VARIABLES; do
      if [[ -n $VARS ]]; then
        VARS+=" "
      fi
      VARS+="\$$VARIABLE"
    done
    echo "::debug::VARS: [$VARS]"
  fi

  for INPUT_FILE in $INPUT_FILES; do
    echo "::group::Substituting [$INPUT_FILE]"
    local OUTPUT_FILE=""
    if [[ -n $OUTPUT_DIRECTORY ]]; then
      OUTPUT_FILE="$OUTPUT_DIRECTORY/$(basename "$INPUT_FILE").env"
    else
      OUTPUT_FILE="$INPUT_FILE.env"
    fi
    if [[ -n $VARIABLES ]]; then
      envsubst "$VARS" < "$INPUT_FILE" > "$OUTPUT_FILE"
    else
      envsubst < "$INPUT_FILE" > "$OUTPUT_FILE"
    fi
    if [[ $ENABLE_IN_PLACE == true ]]; then
      mv -f "$OUTPUT_FILE" "$INPUT_FILE"
      echo "File updated successfully! [$INPUT_FILE]"
      if [[ $ENABLE_DUMP == true ]]; then
        echo "Dump [$INPUT_FILE]:"
        cat -n "$INPUT_FILE"
      fi
    else
      echo "New file generated successfully! [$OUTPUT_FILE]"
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
