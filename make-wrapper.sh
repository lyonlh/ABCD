#!/bin/bash

path_name=$_
compiler_wrapper="$(dirname $path_name)/compiler-wrapper.sh"
compile_command_db=$(dirname $path_name)/compile_commands.json
db_file_assign="compile_command_db=$compile_command_db"

one_word()
{
    echo "$*"
}

while read compiler assign value; do \
    if [[ "$assign" == "=" && "$value" ]]; then \
        if [[ "$compiler" == "CC" ]]; then \
            ORIGIN_CC=$value; \
        elif [[ "$compiler" == "CXX" ]]; then \
            ORIGIN_CXX=$value; \
        fi \
    fi \
    done <<EOF
$(make -spqRr "$@" 2>/dev/null)
EOF

COMPILER_CC="$compiler_wrapper $ORIGIN_CC"
COMPILER_CXX="$compiler_wrapper $ORIGIN_CXX"

make -j -Bks "$@" CC="$(one_word $COMPILER_CC)" CXX="$(one_word $COMPILER_CXX)"
