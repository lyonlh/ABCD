#!/usr/bin/env bash

my_path="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_make="make"
cc_wrapper="$my_path/cc-wrapper.sh"
cxx_wrapper="$my_path/cxx-wrapper.sh"
cpp_wrapper="$my_path/cpp-wrapper.sh"
source "$my_path/utils"
db_file="$(pwd)/compile_commands.json"

usage="usage: mint.sh [make options] [-- [-a] [-d] [-h] [-m specified_make] [-o db_file]]$_NEWLINE_ \
-a\\t\\tuse 'arguments' instead of 'command' field in compilation database $_NEWLINE_ \
-d\\t\\tprint debug message$_NEWLINE_ \
-h\\t\\tdisplay this help and exit$_NEWLINE_ \
-m\\t\\tspecify path or name of 'make'$_NEWLINE_ \
-o db_file\\twrite output to the db_file$_NEWLINE_ \
"

# Extract options with respective to make and this wrapper
declare -a make_opts wrapper_opts
declare -i i
for (( i=1; i<${#@}; i++))
do
    if [[ "${!i}" == "--" ]]
    then
        break
    fi
done

make_opts=( "${@:1:(($i-1))}" )
wrapper_opts=( "${@:(($i+1))}" )

# Parse options for this wrapper
if [[ "${wrapper_opts## }" ]]
then
    while getopts abdhm:o: o "${wrapper_opts[@]}"
    do
        case $o in
            a) use_arg_field=1;;
            d) debug=1;;
            m) _make=$OPTARG;;
            o) db_file="$(cd -P "$(dirname "$OPTARG")" && pwd)/$(basename "$OPTARG")";;
            h|*) printf %b "$usage$_NEWLINE_"; exit 0;;
        esac
    done
fi

# Retrive CC/CXX from make database
# The reason to care CPP is someone misuse it as CXX
ORIGIN_CC="cc"
ORIGIN_CXX="c++"
ORIGIN_CPP=""
while read -r compiler assign value
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
$("$_make" -pqRr "${make_opts[@]}" 2>/dev/null)
EOF

# Generate file from which CC/CXX-wrapper can read global enviroment
global_env="$my_path/global-env"
printf "%s$_NEWLINE_%s$_NEWLINE_%s$_NEWLINE_%s$_NEWLINE_%s$_NEWLINE_" \
       "db_file=$(quote "$db_file")" \
       "CC=$(quote "$ORIGIN_CC")" \
       "CXX=$(quote "$ORIGIN_CXX")" \
       "CPP=$(quote "$ORIGIN_CPP")" \
       "debug=$(quote "$debug")" \
       "use_arg_field=$(quote $use_arg_field)" > "$global_env" && \
    trap "rm -f '$global_env'; exit $?" INT TERM EXIT

printf "#### Start ####$_NEWLINE_$_NEWLINE_"

debug_log "##Internal ENV##$_NEWLINE_$(< "$global_env")"
debug_log "##Command line options##$_NEWLINE_$(declare -p make_opts wrapper_opts)"

printf "[$_NEWLINE_" > "$db_file"
"$_make" "${make_opts[@]}" CC="$cc_wrapper" CXX="$cxx_wrapper" ${ORIGIN_CPP:+CPP="$cpp_wrapper"}
# Delete tail comma
sed -i -e '${s/\(^ *\}\),$/\1/}' "$db_file"
printf "]$_NEWLINE_" >> "$db_file"

printf "$_NEWLINE_#### Done ####$_NEWLINE_"
