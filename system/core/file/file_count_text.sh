#!/bin/bash

file_count_text() {
    local file="$1"
    local texts=($(<"$file"))

    echo "${#texts[@]}"
}
