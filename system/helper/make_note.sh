#!/bin/bash

make_note() {
    # Get the current date and time in the specified format
    local timestamp=$(date +"%Y-%m-%d_%I%M%p")
    timestamp=$(date +"%Y-%m-%d")
    local filename
    local prefix
    local dest_path="$HOME/notes"

    # Create the filename
    if [ -n "$1" ]; then
        # slugify
        prefix=echo "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]/-/g' -e 's/--*/-/g' -e 's/-$//' -e 's/^-//'
        filename="${prefix}_${timestamp}.txt"
    else
        filename="${timestamp}.txt"
    fi

    # Ensure the destination path exists
    mkdir -p "$dest_path"

    # Create the file
    touch "$dest_path/$filename"

    # Confirm the file has been created
    if [ $? -eq 0 ]; then
        echo "Note created: $dest_path/$filename"
        # Change below based on prefered editor
        note_editor "$dest_path/$filename"
    else
        echo "Failed to create note"
    fi
}

note_editor() {
    if [ -n "$1" ]; then
        nano "$1"
    else
        echo "File not passed."
    fi
}