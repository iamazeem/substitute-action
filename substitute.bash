#!/bin/bash

if ! which envsubst; then
  echo ""
  exit 1
fi

envsubst --version
