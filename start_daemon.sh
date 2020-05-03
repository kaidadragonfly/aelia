#!/usr/bin/env bash

source .env
elixir --erl "-detached" -S mix phx.server
