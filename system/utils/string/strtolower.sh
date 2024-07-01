#!/bin/bash

strtolower() {
    # echo "function: to_lowercase()"
    local input="$1"
    if [ -n "$BASH_VERSION" ]; then
        strtolower_default "$@"
    elif [ -n "$ZSH_VERSION" ]; then
        strtolower_zsh "$@"
    else
        echo "$input"
    fi
}

strtolower_default() {
    local input="$1"
    echo "${input,,}"
}

strtolower_zsh() {
    local input="$1"
    echo "${input:l}"
}