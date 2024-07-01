#!/bin/bash

str_repeat() {
    local input="$1"
    local repeat_count="$2"
    local result=""

    for ((i = 0; i < repeat_count; i++)); do
        result+="$input"
    done

    echo "$result"
}