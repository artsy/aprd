#!/usr/bin/env bash

set -e

# load env files in order
export $(grep -v '^#' .env.shared | xargs)
export $(grep -v '^#' .env | xargs)

# start phoenix
mix phx.server

