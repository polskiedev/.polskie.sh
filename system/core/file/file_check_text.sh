#!/bin/bash

file_check_text() {
    local file="$1"
    local text_to_check="$2"

    while IFS= read -r line; do
        # Check if the line matches the text to check
        if [ "$line" = "$text_to_check" ]; then
            log_verbose "Text '$text_to_check' exists in '$file'."
            return 1  # Return success code
        fi
    done < "$file"

    return 0  # Return failure code1
}
