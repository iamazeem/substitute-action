#!/bin/bash

set -eE -o functrace

fatal() {
  local LINE="$1"
  local CMD="$2"
  echo "[FATAL] $LINE: $CMD"
  exit 1
}

trap 'fatal "$LINENO" "$BASH_COMMAND"' ERR

# functions

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
  source_env_files

  if [[ -n $VARIABLES ]]; then
    local VARS_LIST=""
    for VARIABLE in $VARIABLES; do
      if [[ -n $VARS_LIST ]]; then
        VARS_LIST+=" "
      fi
      VARS_LIST+="\$$VARIABLE"
    done
    echo "::debug::VARS_LIST: [$VARS_LIST]"
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
      envsubst "$VARS_LIST" < "$INPUT_FILE" > "$OUTPUT_FILE"
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

substitute
