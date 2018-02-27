#!/usr/bin/env bash

my_path=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cc_wrapper="$my_path/cc-wrapper.sh"
cxx_wrapper="$my_path/cxx-wrapper.sh"
utils="$my_path/utils"
source $utils

usage="usage: make-wrapper.sh <options of make> [-- [-a] [-d] [-h]]\n \
-a\tuse 'arguments' instead of 'command' field in compilation database \n \
-d\tprint debug message\n \
-h\tdisplay this help and exit\n \
"

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

for o in $wrapper_opts
do
    case $o in
        -a) use_arg_field=1;;
        -d) debug=1;;
        -h|*) printf %b "$usage\n"; exit 0;;
    esac
done

# Retrive CC/CXX from make database
ORIGIN_CC="cc"
ORIGIN_CXX="c++"

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
        fi
    fi
    done <<EOF
$(make -pqRr $make_opts 2>/dev/null)
EOF

# Generate file from which CC/CXX-wrapper can read global enviroment
global_env="$my_path/global-env"
db_file="$(pwd)/compile_commands.json"
printf "%s\n%s\n%s\n%s\n%s\n" \
       "db_file=$(quote $db_file)" \
       "CC=$(quote $ORIGIN_CC)" \
       "CXX=$(quote $ORIGIN_CXX)" \
       "debug=$(quote $debug)" \
       "use_arg_field=$(quote $use_arg_field)" > $global_env

debug_log ====================
debug_log $(cat $global_env)
debug_log ====================

printf "[\n" > $db_file
make -k $make_opts CC="$cc_wrapper" CXX="$cxx_wrapper"
printf "]\n" >> $db_file

rm -f $global_env &>/dev/null
