#!/bin/bash

quote()
{
    printf "\"%s\"" "$*"
}

generate_compile_command()
{
    local command="$@"
    local DIR=$(pwd)
    local dir_key='"directory"'
    local cmd_key='"command"'
    local file_key='"file"'

    if [[ $command =~ ^([^[:blank:]]+)[[:blank:]]+(.*)[[:blank:]]+([^[:blank:]]+)$ ]]
    then
        COMPILER="${BASH_REMATCH[1]}"
        ARGUMENTS="${BASH_REMATCH[2]}"
        FILE_NAME="${BASH_REMATCH[3]}"
        printf "{\n \
  $dir_key: %s,\n \
  $cmd_key: %s,\n \
  $file_key: %s,\n \
},\n" \
               "$(quote "$DIR")" "$(quote "$command")" "$(quote "$FILE_NAME")"
    else
        echo "Something is wrong:(" $command ")" >&2
    fi
}

generate_compile_command "$@" 2>/dev/null

"$@"
