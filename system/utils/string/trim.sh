#!/bin/bash

trim() {
    local input="$1"
    local trimmed

    # Use sed to trim leading and trailing whitespace
    trimmed="$(echo -e "$input" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    echo "$trimmed"
}