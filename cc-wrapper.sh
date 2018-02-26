#!/bin/bash

path_name=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
compiler_wrapper="$path_name/compiler-wrapper"
config="$path_name/config"

source $compiler_wrapper
source $config

generate_compile_command $CC "$@"
echo -n -e "$item" >> $db_file

$CC "$@"
