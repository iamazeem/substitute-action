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

  for ENV_FILE in $ENV_FILES; do
    echo -n "- [$ENV_FILE] "
    local ENV_FILE_STDERR="$ENV_FILE.stderr"
    set -a
    if source "$ENV_FILE" 2> "$ENV_FILE_STDERR"; then
      if [[ -s $ENV_FILE_STDERR ]]; then
        echo "[FAILED]"
        echo "Dump [$ENV_FILE_STDERR]"
        cat -n "$ENV_FILE_STDERR"
        rm -f "$ENV_FILE_STDERR"
        exit 1
      else
        rm -f "$ENV_FILE_STDERR"
        echo "[SOURCED]"
      fi
    else
      echo "[FAILED]"
      exit 1
    fi
    set +a
  done

  echo "::endgroup::"
}

dump_output_file() {
  if [[ $ENABLE_DUMP == true ]]; then
    local FILE="$1"
    echo "Dump [$FILE]:"
    cat -n "$FILE"
  fi
}

substitute() {
  source_env_files

  if [[ -n $VARIABLES ]]; then
    local ENVSUBST_VARS=""
    for VARIABLE in $VARIABLES; do
      if [[ -n $ENVSUBST_VARS ]]; then
        ENVSUBST_VARS+=" "
      fi
      ENVSUBST_VARS+="\$$VARIABLE"
    done
  fi

  if [[ -n $PREFIXES ]]; then
    local PREFIXES_REGEX=""
    for PREFIX in $PREFIXES; do
      if [[ -n $PREFIXES_REGEX ]]; then
        PREFIXES_REGEX+="|"
      fi
      PREFIXES_REGEX+="$PREFIX"
    done
    local PREFIXED_ENV_VARS=""
    PREFIXED_ENV_VARS="$(env | grep -E "^$PREFIXES_REGEX" | cut -d '=' -f1)"
    for PREFIXED_ENV_VAR in $PREFIXED_ENV_VARS; do
      if [[ -n $ENVSUBST_VARS ]]; then
        ENVSUBST_VARS+=" "
      fi
      ENVSUBST_VARS+="\$$PREFIXED_ENV_VAR"
    done
  fi

  for INPUT_FILE in $INPUT_FILES; do
    echo "::group::Substituting [$INPUT_FILE]"
    local OUTPUT_FILE=""
    if [[ -n $OUTPUT_DIRECTORY ]]; then
      OUTPUT_FILE="$OUTPUT_DIRECTORY/$(basename "$INPUT_FILE").env"
    else
      OUTPUT_FILE="$INPUT_FILE.env"
    fi
    if [[ -n $ENVSUBST_VARS ]]; then
      echo "ENVSUBST_VARS: [$ENVSUBST_VARS]"
      envsubst "$ENVSUBST_VARS" < "$INPUT_FILE" > "$OUTPUT_FILE"
    else
      envsubst < "$INPUT_FILE" > "$OUTPUT_FILE"
    fi
    if [[ $ENABLE_IN_PLACE == true ]]; then
      mv -f "$OUTPUT_FILE" "$INPUT_FILE"
      echo "File updated successfully! [$INPUT_FILE]"
      dump_output_file "$INPUT_FILE"
    else
      echo "New file generated successfully! [$OUTPUT_FILE]"
      dump_output_file "$OUTPUT_FILE"
    fi
    echo "::endgroup::"
  done
}

# start

substitute
