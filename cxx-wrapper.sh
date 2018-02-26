#!/usr/bin/env bash

path_name=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source "$path_name/config"
source "$path_name/compilation-db-factory"

generate_compile_command $CXX "$@" >> $db_file

$CXX "$@"
