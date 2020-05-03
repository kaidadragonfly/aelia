#!/usr/bin/env bash

source .env
mix deps.get --only prod
MIX_ENV=prod mix compile
npm run deploy --prefix ./assets
mix phx.digest
