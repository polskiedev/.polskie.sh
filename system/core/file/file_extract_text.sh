#!/bin/bash

file_extract_text() {
    local file="$1"
    local texts=($(<"$file"))
    local index=1

    for text in "${texts[@]}"; do
        echo "$index: $text"
        ((index++))
    done
}
