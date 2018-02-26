#!/usr/bin/env bash

path_name=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cc_wrapper="$path_name/cc-wrapper.sh"
cxx_wrapper="$path_name/cxx-wrapper.sh"
config="$path_name/config"
utils="$path_name/utils"
source $utils

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
$(make -pqRr "$@" 2>/dev/null)
EOF

# Generate file from which CC/CXX-wrapper can read config
db_file="$(pwd)/compile_commands.json"
echo "db_file=$(quote $db_file)" >$config
echo "CC=$(quote $ORIGIN_CC)" >>$config
echo "CXX=$(quote $ORIGIN_CXX)" >>$config

echo ====================
cat $config
echo ====================

echo "[" > $db_file
make -j1 -k "$@" CC="$cc_wrapper" CXX="$cxx_wrapper"
echo "]" >> $db_file

rm -f $config &>/dev/null
