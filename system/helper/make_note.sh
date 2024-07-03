#!/bin/bash

get_note_path() {
    local dest_path="$HOME/notes"
    echo "$dest_path"
}

get_note_filename() {
    # Get the current date and time in the specified format
    local timestamp=$(date +"%Y-%m-%d_%I%M%p")
    timestamp=$(date +"%Y-%m-%d")
    local filename
    local prefix

    # Create the filename
    if [ -n "$1" ]; then
        # slugify
        prefix=echo "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]/-/g' -e 's/--*/-/g' -e 's/-$//' -e 's/^-//'
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
    note_editor "$dest_path/$filename"
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

note_editor() {
    if [ -n "$1" ]; then
        nvim "$1"
    else
        echo "File not passed."
    fi
}