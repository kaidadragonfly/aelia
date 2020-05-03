#!/bin/sh

. .env                          # Source .env
elixir --erl "-detached" -S mix phx.server
