#!/bin/bash

file_extract_text() {
    local file="$1"
    local texts=($(<"$file"))

    read -p "Choose an index: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 )) && (( choice <= ${#texts[@]} )); then
        echo "${texts[choice-1]}"
    else
        echo ""
    fi
}
