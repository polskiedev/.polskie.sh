#!/bin/bash

trim() {
    # echo "trim()"
    local input
    local trimmed

    # To make the trim function pipeable
    if [ -t 0 ]; then
        input="$1"
    else
        input=$(cat)
    fi
   
    # Use sed to trim leading and trailing whitespace
    trimmed="$(echo -e "$input" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    echo "$trimmed"
}
