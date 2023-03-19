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

  echo "::endgroup::Validation of envsubst commmand completed successfully!"
}

validate_inputs() {
  echo "::group::Validating inputs"

  if [[ -n $ENV_FILES ]]; then
    echo "Validating env files"
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
    echo "Validating input files"
    for FILE in $INPUT_FILES; do
      if [[ ! -f $FILE ]]; then
        echo "$FILE does not exist!"
        exit 1
      else
        echo "- $FILE"
      fi
    done
  fi

  echo "Enable in-place substitution? [$ENABLE_IN_PLACE]"
  echo "Enable dump after substitution? [$ENABLE_DUMP]"

  echo "::endgroup::Validating of inputs completed successfully!"
}

source_env_files() {
  echo "::group::Sourcing env files"

  set -a
  for FILE in $ENV_FILES; do
    echo "Sourcing $FILE"
    source "$FILE"
  done
  set +a

  echo "::endgroup::Sourcing completed successfully!"
}

substitute() {
  echo "::group::Substituting"

  for FILE in $INPUT_FILES; do
    echo "::group::Substituting [$FILE]"
    FILE_ENV="$FILE.env"
    envsubst < "$FILE" > "$FILE_ENV"
    if [[ $ENABLE_IN_PLACE == true ]]; then
      mv "$FILE_ENV" "$FILE"
      echo "File updated successfully! [$FILE]"
      if [[ $ENABLE_DUMP == true ]]; then
        echo "Dumping [$FILE]"
        cat "$FILE"
      fi
    else
      echo "New file generated successfully! [$FILE_ENV] "
      if [[ $ENABLE_DUMP == true ]]; then
        echo "Dumping [$FILE_ENV]"
        cat "$FILE_ENV"
      fi
    fi
    echo "::endgroup::"
  done

  echo "::endgroup::"
}

validate_envsubst
validate_inputs
source_env_files
substitute
