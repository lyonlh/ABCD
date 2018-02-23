#!/bin/bash

path_name=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
# path_name=$_

source "$path_name/utils"

cc_wrapper="$path_name/cc-wrapper.sh"
cxx_wrapper="$path_name/cxx-wrapper.sh"
config="$path_name/config"

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
$(make -spqRr "$@" 2>/dev/null)
EOF

# Generate file from which compiler-wrapper.sh can read config
echo "db_file=$(pwd)/compile_commands.json" >$config
echo "CC=$(quote $ORIGIN_CC)" >>$config
echo "CXX=$(quote $ORIGIN_CXX)" >>$config
source $config

echo ====================
cat $config
echo ====================

echo "[" > $db_file
make -j1 -Bsk "$@" CC="$(one_word $cc_wrapper)" CXX="$(one_word $cxx_wrapper)"
echo "]" >> $db_file

rm -f $config &>/dev/null
