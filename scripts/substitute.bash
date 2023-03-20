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

  echo "Printing envsubst version"
  envsubst --version

  echo "::endgroup::"
}

validate_env_files() {
  echo "::group::Validating env files"

  if [[ -n $ENV_FILES ]]; then
    echo "env-files:"
    for FILE in $ENV_FILES; do
      if [[ ! -f $FILE ]]; then
        echo "$FILE does not exist!"
        exit 1
      else
        echo "- $FILE"
      fi
    done
  fi

  echo "::endgroup::"
}

validate_input_files() {
  echo "::group::Validating input files"

  if [[ -z $INPUT_FILES ]]; then
    echo "input-files cannot be empty!"
    exit 1
  else
    echo "input-files:"
    for FILE in $INPUT_FILES; do
      if [[ ! -f $FILE ]]; then
        echo "$FILE does not exist!"
        exit 1
      else
        echo "- $FILE"
      fi
    done
  fi

  echo "::endgroup::"
}

validate_variables() {
  echo "::group::Validating variables"

  if [[ -n $VARIABLES ]]; then
    echo "variables:"
    for VARIABLE in $VARIABLES; do
      echo "- $VARIABLE"
    done
  fi

  echo "::endgroup::"
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
  for FILE in $ENV_FILES; do
    echo "Sourcing $FILE"
    . "$FILE"
  done
  set +a

  echo "::endgroup::"
}

substitute() {
  echo "::group::Substituting"

  if [[ -n $VARIABLES ]]; then
    echo "Preparing variables list"
    local VARS=""
    for VARIABLE in $VARIABLES; do
      VARS+="\$$VARIABLE "
    done
    if [[ -n $VARS ]]; then
      VARS=${VARS: 0:-1}
    fi
    echo "VARIABLES: [$VARS]"
  fi

  for FILE in $INPUT_FILES; do
    echo "::group::Substituting [$FILE]"
    FILE_ENV="$FILE.env"
    if [[ -n $VARIABLES ]]; then
      envsubst "$VARS" < "$FILE" > "$FILE_ENV"
    else
      envsubst < "$FILE" > "$FILE_ENV"
    fi
    if [[ $ENABLE_IN_PLACE == true ]]; then
      mv "$FILE_ENV" "$FILE"
      echo "File updated successfully! [$FILE]"
      if [[ $ENABLE_DUMP == true ]]; then
        echo "Dumping [$FILE]:"
        cat -n "$FILE"
      fi
    else
      echo "New file generated successfully! [$FILE_ENV] "
      if [[ $ENABLE_DUMP == true ]]; then
        echo "Dumping [$FILE_ENV]"
        cat -n "$FILE_ENV"
      fi
    fi
    echo "::endgroup::"
  done

  echo "::endgroup::"
}

# start

validate_envsubst
validate_inputs
source_env_files
substitute
