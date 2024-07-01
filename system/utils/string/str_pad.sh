#!/bin/bash

str_pad() {
    local input="$1"
    local pad_length="$2"
    local pad_string="${3:- }"
    local pad_type="${4:-right}"
    local pad_result="$input"

    while [ "${#pad_result}" -lt "$pad_length" ]; do
        case "$pad_type" in
            left)
                pad_result="${pad_string}${pad_result}"
                ;;
            right)
                pad_result="${pad_result}${pad_string}"
                ;;
            both)
                pad_result="${pad_string}${pad_result}${pad_string}"
                ;;
        esac
    done

    echo "${pad_result:0:pad_length}"
}