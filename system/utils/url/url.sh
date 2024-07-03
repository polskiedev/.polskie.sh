#!/bin/bash

urlencode() {
    local raw_string="$1"
    local encoded_string=""

    for (( i=0; i<${#raw_string}; i++ )); do
        local char="${raw_string:$i:1}"
        case "$char" in
            [a-zA-Z0-9.~_-]) encoded_string+="$char" ;;
            ' ') encoded_string+="%20" ;;
            *) printf -v encoded_char '%%%02X' "'$char"
               encoded_string+="$encoded_char" ;;
        esac
    done

    echo "$encoded_string"
}