#!/bin/bash

set -eE -o functrace

fatal() {
  local LINE="$1"
  local CMD="$2"
  echo "[FATAL] $LINE: $CMD"
  exit 1
}

trap 'fatal ${LINENO} "$BASH_COMMAND"' ERR

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
      echo -n "- [$ENV_FILE] "
      if [[ -f $ENV_FILE ]]; then
        echo "[EXISTS]"
      else
        echo "[DOES NOT EXIST]"
        exit 1
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
      echo -n "- [$INPUT_FILE] "
      if [[ -f $INPUT_FILE ]]; then
        echo "[EXISTS]"
      else
        echo "[DOES NOT EXIST]"
        exit 1
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
  if [[ $ENABLE_IN_PLACE == false && -n $OUTPUT_DIRECTORY ]]; then
    echo "output-directory:"
    if [[ -d $OUTPUT_DIRECTORY ]]; then
      echo "- [$OUTPUT_DIRECTORY] [EXISTS]"
    else
      echo "- [$OUTPUT_DIRECTORY] does not exist!"
      echo "- Creating [$OUTPUT_DIRECTORY]"
      if ! mkdir -p "$OUTPUT_DIRECTORY"; then
        echo "- Unable to create [$OUTPUT_DIRECTORY]!"
        exit 1
      fi
      echo "- output-directory: [$OUTPUT_DIRECTORY] [CREATED]"
    fi
    echo -n "- Is [$OUTPUT_DIRECTORY] directory writeable? "
    if [[ -w $OUTPUT_DIRECTORY ]]; then
      echo "[YES]"
    else
      echo "[NO]"
      echo "- output-directory must be writeable!"
      echo "- Possible permissions issue! See:"
      ls -hl "$OUTPUT_DIRECTORY"
      exit 1
    fi
  fi
}

validate_enable_in_place() {
  echo "enable-in-place: [$ENABLE_IN_PLACE]"
}

validate_enable_dump() {
  echo "enable-dump: [$ENABLE_DUMP]"
}

validate_inputs() {
  echo "::group::Validating inputs"

  validate_env_files
  validate_input_files
  validate_variables
  validate_output_directory
  validate_enable_in_place
  validate_enable_dump

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
