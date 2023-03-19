#!/bin/bash

echo "::group:: Substitue environment variables"

echo "Running $0"

if ! which envsubst; then
  echo "envsubst command not found"
  echo "::error:: envsubst command not found"
  exit 1
fi

envsubst --version

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

echo "in-place = $IN_PLACE"

# set -a
# source file.env
# set +a

echo "::endgroup:: "
