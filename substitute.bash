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
  echo "Listing env files"
  for FILE in $ENV_FILES; do
    if [[ ! -f $FILE ]]; then
      echo "$FILE does not exist!"
      exit 1
    else
      echo "::debug::$FILE exists!"
    fi
  done
fi

if [[ -n $INPUT_FILES ]]; then
  echo "Listing input files"
  for FILE in $INPUT_FILES; do
    if [[ ! -f $FILE ]]; then
      echo "$FILE does not exist!"
      exit 1
    else
      echo "::debug::$FILE exists!"
    fi
  done
fi

echo "In-place substitution? [$IN_PLACE]"

echo "::endgroup::"

echo "::group::Substituting"

# set -a
# source file.env
# set +a

echo "::endgroup::"
