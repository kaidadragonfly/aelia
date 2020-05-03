#!/usr/bin/env bash

BIN_DIR=$(dirname "$(python -c "import os; print(os.path.realpath('$0'))")")
ROOT_DIR="$BIN_DIR/.."
cd "$ROOT_DIR" || exit 1

source .env
elixir --erl "-detached" -S mix phx.server
