#!/bin/bash

echo "::group::Validating envsubst command"

if ! which envsubst; then
  echo "envsubst command not found!"
  echo "::error::envsubst command not found!"
  exit 1
fi

echo "::debug::Printing envsubst version"
envsubst --version

echo "::endgroup::"

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

if [[ $IN_PLACE == true ]]; then
  echo "In-place substitution is enabled!"
else
  echo "In-place substitution is disabled!"
fi

echo "::endgroup::"

echo "::group::Substituting"

# set -a
# source file.env
# set +a

echo "::endgroup::"
