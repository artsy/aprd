#!/bin/bash

set -x

./script/wait-for-it.sh aprd-db:5432 -- echo "Database is READY... phew...."

mix test