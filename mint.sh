#!/usr/bin/env bash

my_path=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cc_wrapper="$my_path/cc-wrapper.sh"
cxx_wrapper="$my_path/cxx-wrapper.sh"
cpp_wrapper="$my_path/cpp-wrapper.sh"
utils="$my_path/utils"
source $utils
db_file="$(pwd)/compile_commands.json"

usage="usage: mint.sh [make options] [-- [-a] [-d] [-h] [-o db_file]]\n \
-a\t\tuse 'arguments' instead of 'command' field in compilation database \n \
-d\t\tprint debug message\n \
-h\t\tdisplay this help and exit\n \
-o db_file\twrite output to the db_file\n \
"

# Extract options with respective to make and this wrapper
if [[ $@ =~ (.*)--(.*) ]]
then
    make_opts=${BASH_REMATCH[1]}
    if [[ ${#BASH_REMATCH[@]} == 3 ]]
    then
        wrapper_opts=${BASH_REMATCH[2]}
    fi
else
    make_opts=$@
fi

# Parse options for this wrapper
if [[ "${wrapper_opts## }" ]]
then
    while getopts abdho: o $wrapper_opts
    do
        case $o in
            a) use_arg_field=1;;
            d) debug=1;;
            o) db_file="$(cd $(dirname $OPTARG) && pwd)/$(basename $OPTARG)";;
            h|*) printf %b "$usage\n"; exit 0;;
        esac
    done
fi

# Retrive CC/CXX from make database
# The reason to care CPP is someone misuse it as CXX
ORIGIN_CC="cc"
ORIGIN_CXX="c++"
ORIGIN_CPP=""
while read compiler assign value
do
    if [[ $assign =~ :?= && "$value" ]]
    then
        if [[ "$compiler" == "CC" ]]
        then
            ORIGIN_CC=$value;
        elif [[ "$compiler" == "CXX" ]]
        then
            ORIGIN_CXX=$value;
        elif [[ "$compiler" == "CPP" ]]
        then
            ORIGIN_CPP=$value;
        fi
    fi
    done <<EOF
$(make -pqRr $make_opts 2>/dev/null)
EOF

# Generate file from which CC/CXX-wrapper can read global enviroment
global_env="$my_path/global-env"
printf "%s\n%s\n%s\n%s\n%s\n" \
       "db_file=$(quote $db_file)" \
       "CC=$(quote $ORIGIN_CC)" \
       "CXX=$(quote $ORIGIN_CXX)" \
       "CPP=$(quote $ORIGIN_CPP)" \
       "debug=$(quote $debug)" \
       "use_arg_field=$(quote $use_arg_field)" > $global_env && \
    trap "rm -f $global_env" INT TERM EXIT

debug_log $(cat $global_env)

printf "[\n" > $db_file
make $make_opts CC="$cc_wrapper" CXX="$cxx_wrapper" ${ORIGIN_CPP:+CPP="$cpp_wrapper"}
printf "]\n" >> $db_file
