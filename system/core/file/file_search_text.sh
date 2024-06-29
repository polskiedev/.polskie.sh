#!/bin/bash

file_search_text() {
    local file="$1"
    local search="$2"
    local verbose="$3"

    while IFS= read -r line; do
        # Check if the line matches the text to check
        if [ "$line" = "$search" ]; then
            log_verbose "Text '$search' exists in '$file'." "$verbose"
            return 0  # Return success code
        fi
    done < "$file"

    return 1  # Return failure code1
}
