#!/bin/bash
# devenv_precmd
source $(realpath "$HOME/.devenv.sources.sh")

test() {
    log_info "Testing 'to_lowercase()' function"

    local text="HELLO world!"
    local result=$(to_lowercase "$text")
    local expected="hello world!"

    echo "Text: $text"
    echo "Expected: $expected"
    echo "Output: $result"
    [ "$result" = "$expected" ] && log_success "Status: Passed"; return 0 || log_error "Status: Failed"; return 1
    echo "====="
}

test
