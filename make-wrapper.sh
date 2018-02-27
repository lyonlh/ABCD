#!/usr/bin/env bash

path_name=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cc_wrapper="$path_name/cc-wrapper.sh"
cxx_wrapper="$path_name/cxx-wrapper.sh"
config="$path_name/config"
utils="$path_name/utils"
source $utils

usage="usage: make-wrapper.sh <options of make> [-- [-a] [-d] [-h]]\n \
-a\tuse 'arguments' field in compilation database (default use 'command' field)\n \
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

# Generate file from which CC/CXX-wrapper can read config
db_file="$(pwd)/compile_commands.json"
echo "db_file=$(quote $db_file)" >$config
echo "CC=$(quote $ORIGIN_CC)" >>$config
echo "CXX=$(quote $ORIGIN_CXX)" >>$config
echo "debug=$(quote $debug)" >>$config
echo "use_arg_field=$(quote $use_arg_field)" >>$config

debug_log ====================
debug_log $(cat $config)
debug_log ====================

echo "[" > $db_file
make -j1 -k $make_opts CC="$cc_wrapper" CXX="$cxx_wrapper"
echo "]" >> $db_file

rm -f $config &>/dev/null
