#!/bin/bash

echo "Running $0"

echo "::group::Validating envsubst command"

if ! which envsubst; then
  echo "envsubst command not found"
  echo "::error:: envsubst command not found"
  exit 1
fi

envsubst --version

echo "::endgroup::"

echo "::group::Validating inputs"

if [[ -n $ENV_FILES ]]; then
  echo "Listing env files [$ENV_FILES]"
fi

for FILE in $ENV_FILES; do
  if [[ ! -f $FILE ]]; then
    echo "$FILE does not exist!"
    exit 1
  fi
done

if [[ -n $INPUT_FILES ]]; then
  echo "Listing input files [$INPUT_FILES]"
fi

for FILE in $INPUT_FILES; do
  if [[ ! -f $FILE ]]; then
    echo "$FILE does not exist!"
    exit 1
  fi
done

echo "In-place substitution? [$IN_PLACE]"

echo "::endgroup::"

echo "::group::Substituting"

# set -a
# source file.env
# set +a

echo "::endgroup::"
