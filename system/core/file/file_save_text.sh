#!/bin/bash

file_save_text() {
    local file="$1"
    local text="$2"
    local option="${3:---append}"
    local quiet_mode="${4:---quiet}"

    # echo "textman_save_text $file $text $option"

    if ! grep -qF "$text" "$file"; then
        if [[ "$option" == "--prepend" ]]; then
            tmpfile=$(mktemp)
            { echo "$text"; cat "$file"; } > "$tmpfile" && mv "$tmpfile" "$file"
            rm -f "$tmpfile"  # Delete the temporary file
            if ! [ "$quiet_mode" == "--quiet" ]; then
                log_info "Text '$text' prepended to '$file'."
            fi
        else
            echo "$text" >> "$file"
            if ! [ "$quiet_mode" == "--quiet" ]; then
                log_info "Text '$text' appended to '$file'."
            fi
        fi
    else
        log_verbose "Text '$text' already exists in '$file'."
    fi
}