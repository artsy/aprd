#!/usr/bin/env bash

set -e

# load env files in order
export $(grep -v '^#' .env.shared | xargs) > /dev/null
export $(grep -v '^#' .env | xargs) > /dev/null

# start phoenix
mix phx.server

