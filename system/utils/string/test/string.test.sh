#!/bin/bash

test() {
    echo "Testing 'to_lowercase()' function"

    local text="HELLO world!"
    local result=$(__polskiesh_to_lowercase "$text")

    echo "Text: $text"
    echo "Output: $result"
}

test