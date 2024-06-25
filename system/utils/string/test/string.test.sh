#!/bin/bash

source $(realpath "$HOME/.devenv.sources.sh")

test() {
    # echo "Testing 'to_lowercase()' function"

    local text="HELLO world!"
    local result=$(to_lowercase "$text")
    local expected="hello world!"

    echo "Text: $text"
    echo "Expected: $expected"
    echo "Output: $result"
    [ "$result" = "$expected" ] && echo "Status: Passed" || echo "Status: Failed"
    echo "====="
}

test