#!/usr/bin/env bash

set -e

cd "${0%/*}/.."

echo "Running tests"
bundle exec rspec  --fail-fast --format documentation --tag ~skip