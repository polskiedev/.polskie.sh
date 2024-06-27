#!/bin/bash

file_choose_text() {
    local file="$1"
    local texts=($(<"$file"))
    local index=1

    for text in "${texts[@]}"; do
        echo "$index: $text"
        ((index++))
    done

    read -p "Choose an index: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 )) && (( choice <= ${#texts[@]} )); then
        # log_info "You chose index $choice: ${texts[choice-1]}"
        echo "${texts[choice-1]}"
    else
        # log_info "Invalid choice."
        echo ""
    fi
}
