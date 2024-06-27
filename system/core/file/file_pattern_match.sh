#!/bin/bash

file_pattern_match() {
    local file="$1"
    local pattern="$2"
    local matches=()

    while IFS= read -r line; do
        # Check if the line matches the pattern
        if [[ "$line" =~ $pattern ]]; then
            matches+=("$line")
        fi
    done < "$file"

    # Return the matches array
    # echo "${matches[@]}"

    # Print the matches array as newline-separated values
    printf '%s\n' "${matches[@]}"
}
