#!/bin/bash

validate_envsubst() {
  echo "::group::Validating envsubst command"

  if ! which envsubst; then
    echo "envsubst command not found!"
    echo "::error::envsubst command not found!"
    exit 1
  fi

  echo "::debug::Printing envsubst version"
  envsubst --version

  echo "::endgroup::"
}

validate_inputs() {
  echo "::group::Validating inputs"

  if [[ -n $ENV_FILES ]]; then
    echo "Validating and listing env files"
    for FILE in $ENV_FILES; do
      if [[ ! -f $FILE ]]; then
        echo "$FILE does not exist!"
        exit 1
      else
        echo "- $FILE"
      fi
    done
  fi

  if [[ -n $INPUT_FILES ]]; then
    echo "Validating and listing input files"
    for FILE in $INPUT_FILES; do
      if [[ ! -f $FILE ]]; then
        echo "$FILE does not exist!"
        exit 1
      else
        echo "- $FILE"
      fi
    done
  fi

  echo "In-place substitution? [$IN_PLACE]"

  echo "::endgroup::"
}

substitute() {
  echo "::group::Substituting"

  echo "Sourcing environment variables from env files"
  set -a
  for FILE in $ENV_FILES; do
    source "$FILE"
  done
  set +z

  echo "Substituting enviornment variables in input files"
  for FILE in $INPUT_FILES; do
    echo "Substituting [$FILE]"
    envsubst < "$FILE"
  done

  echo "::endgroup::"
}

validate_envsubst
validate_inputs
substitute
