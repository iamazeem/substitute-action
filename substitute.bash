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

if [[ -n $INPUT_FILES ]]; then
  echo "Listing input files [$INPUT_FILES]"
fi

echo "in-place = $IN_PLACE"

# set -a
# source file.env
# set +a

echo "::endgroup:: "
