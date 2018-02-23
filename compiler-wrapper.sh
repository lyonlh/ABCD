#!/bin/bash

path_name=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
utils="$path_name/utils"
config="$path_name/config"
source $utils
source $config

generate_compile_command()
{
    local CMD="$@"
    local DIR=$(pwd)
    local dir_key='"directory"'
    local cmd_key='"command"'
    local args_key='"arguments"'
    local file_key='"file"'

    if [[ $CMD =~ ^([^[:blank:]]+)[[:blank:]]+(.*)[[:blank:]]+([^[:blank:]]+\.(c|cc|cpp|cxx|h|hxx))$ ]]
    then
        COMPILER="${BASH_REMATCH[1]}"
        ARGUMENTS="${BASH_REMATCH[2]}"
        FILE_NAME="${BASH_REMATCH[3]}"

        # ARGUMENTS="${COMPILER[@]:2}${ARGUMENTS}"
        # COMPILER="${COMPILER[@]:1:1}"

        # Treat whitespace between option and argument
        for w in $ARGUMENTS
        do
            if [[ $w =~ ^-.* ]]
            then
                args="$args $w"
            else
                args="$args$w"
            fi
        done

        args=$(printf '   "%s",\n' $args)

        item=" {\n"
        item=$item"  $dir_key: $(quote $DIR),\n"
        item=$item"  $cmd_key: $(quote $CMD),\n"
        item=$item"  $args_key: [\n   $(quote $COMPILER),\n$args\n   $(quote $FILE_NAME),\n  ],\n"
        item=$item"  $file_key: $(quote $FILE_NAME),\n },\n"
    fi
}

generate_compile_command "$@"
echo -n -e "$item" >> $db_file

"$@"
