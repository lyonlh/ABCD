#!/bin/bash

path_name=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
compiler_wrapper="$path_name/compiler-wrapper.sh"
config="$path_name/config"
source $config

$compiler_wrapper "$CC" "$@"
