#!/bin/bash

echo "::group:: Substitue environment variables"

echo "::debug:: Running $0"

if ! which envsubst; then
  echo "::error:: \`envsubst\` not found, exiting"
  exit 1
fi

envsubst --version

if [[ -n $ENV_FILES ]]; then
  echo "::notice:: Listing env files [$ENV_FILES]"
fi

if [[ -n $INPUT_FILES ]]; then
  echo "::notice:: Listing input files [$INPUT_FILES]"
fi

echo "::notice:: in-place = $IN_PLACE"

# set -a
# source file.env
# set +a

echo "::endgroup:: "
