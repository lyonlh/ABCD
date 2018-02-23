#!/bin/bash

path_name=$_

source "$(dirname $path_name)/utils"

compiler_wrapper="$(dirname $path_name)/compiler-wrapper.sh"
config="$(dirname $path_name)/config"

# Retrive CC/CXX from make database
ORIGIN_CC="cc"
ORIGIN_CXX="c++"

while read compiler assign value; do \
    if [[ $assign =~ :?= && "$value" ]]; then \
        if [[ "$compiler" == "CC" ]]; then \
            ORIGIN_CC=$value; \
        elif [[ "$compiler" == "CXX" ]]; then \
            ORIGIN_CXX=$value; \
        fi \
    fi \
    done <<EOF
$(make -spqr "$@" 2>/dev/null)
EOF

COMPILER_CC="$compiler_wrapper $ORIGIN_CC"
COMPILER_CXX="$compiler_wrapper $ORIGIN_CXX"

# Generate file from which compiler-wrapper.sh can read config
printf "db_file=$(pwd)/compile_commands.json\n" >$config
source $config

echo "[" > $db_file
make -j -Bsk "$@" CC="$(one_word $COMPILER_CC)" CXX="$(one_word $COMPILER_CXX)"
echo "]" >> $db_file

rm -f $config &>/dev/null
