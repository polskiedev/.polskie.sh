#!/bin/bash

get_note_path() {
    local dest_path="$HOME/notes"
    echo "$dest_path"
}

list_notes() {
    local search_dir="$(get_note_path)"
    if [[ ! -d "$search_dir" ]]; then
        echo "Notes folder doesn't exist yet."
        return 1
    fi

    selected_option=$(find "$search_dir" -type f -name "*.txt" | fzf --prompt="Open note file: ")

    # Check if a file was selected
    if [[ -n "$selected_option" ]]; then
        psh_text_editor "$selected_option"
    else
        echo "No file selected."
    fi
}

get_note_filename() {
    # Get the current date and time in the specified format
    local timestamp="$(get_datetime --date)"
    local filename
    local prefix

    # Create the filename
    if [ -n "$1" ]; then
        # slugify
        prefix="$(slugify "$1")"
        filename="${prefix}_${timestamp}.txt"
    else
        filename="${timestamp}.txt"
    fi

    echo "$filename"
}

write_note() {
    local dest_path="$(get_note_path)"
    local filename="$(get_note_filename "$@")"

    if ! [[ -f "$dest_path/$filename" ]]; then
        make_note "$filename"
    fi

    # Change below based on prefered editor
    psh_text_editor "$dest_path/$filename"
}

make_note() {
    local dest_path="$(get_note_path)"
    local filename="$(get_note_filename "$@")"

    if [ -n "$1" ]; then
        filename="$1"
    fi

    # Ensure the destination path exists
    mkdir -p "$dest_path"

    # Create the file
    touch "$dest_path/$filename"

    # Confirm the file has been created
    if [ $? -eq 0 ]; then
        echo "Note created: $dest_path/$filename"
    else
        echo "Failed to create note"
    fi
}

