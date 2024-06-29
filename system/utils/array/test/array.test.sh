#!/bin/bash
# devenv_precmd
source $(realpath "$HOME/.devenv.sources.sh")

test() {
    log_info "Testing 'in_array()' function"
    local list=("var1" "var2" "var3" "var4")
    local search="var1"
    local expected="hello world!"

    IFS=','; joined_string="${list[*]}"; unset IFS
    echo "Search: $search"
    echo "List: ($joined_string)"

    if in_array "$search" "${list[@]}"; then
        log_success "Status: Passed"
        echo "====="
        return 0
    else
        log_error "Status: Failed"
        echo "====="
        return 1
    fi
}

test
