#!/bin/bash

__polskiesh_to_lowercase() {
    # echo "function: to_lowercase()"
    local input="$1"
    if [ -n "$BASH_VERSION" ]; then
        echo "${input,,}"
    elif [ -n "$ZSH_VERSION" ]; then
        echo "${input:l}"
    else
        echo "$input"
    fi
}