#!/bin/bash

str_split() {
    local input="$1"
    local length="$2"
    local output=()

    while [ -n "$input" ]; do
        output+=("${input:0:length}")
        input="${input:length}"
    done

    echo "${output[@]}"
}