#!/bin/bash

file_remove_text() {
    local file="$1"
    local text_to_remove="$2"

    if grep -qF "$text_to_remove" "$file"; then
        sed -i "/$text_to_remove/d" "$file"
        log_info "Text '$text_to_remove' removed from '$file'."
    else
        log_verbose "Text '$text_to_remove' not found in '$file'."
    fi
}
