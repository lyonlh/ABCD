#!/usr/bin/env bash

my_path="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$my_path/global-env"
source "$my_path/compilation-db-factory"

generate_compile_command "$CPP" "$@"

$CPP "$@"
