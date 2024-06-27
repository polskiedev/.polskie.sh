#!/bin/bash
# devenv_precmd
source $(realpath "$HOME/.devenv.sources.sh")

get_file_name() {
    echo "test.txt"
}

makefile_test_file() {
    local file="$(get_file_name)"
    touch "$file"
    echo "Hello" >> "$file"
    echo "World!" >> "$file"
}

cleanup_test_file() {
    local file="$(get_file_name)"
    if [[ -f "$file" ]]; then
        rm "$file"
    fi
}

run_all_tests() {
    makefile_test_file
    # Get all functions starting with 'test_'
    for func in $(declare -F | awk '{print $3}' | grep -E '^test_'); do
        # Call the function
        $func
    done
    cleanup_test_file
}

test_file_count_text() {
    log_info "Testing 'file_count_text' function"
    local file="$(get_file_name)"
    local result=$(file_count_text "$file")
    local expected="2"

    echo "Text:"
    cat "$file"
    echo "Expected: $expected"
    # echo "Output: $result"
    
    [ "$result" -eq "$expected" ] && log_success "Status: Passed" || log_error "Status: Failed"
    echo "====="
}

test_file_show_text() {
    log_info "Testing 'file_show_text' function"
    local file="$(get_file_name)"
    local temp_file=$(mktemp)
    local temp_file2=$(mktemp)
    
    file_show_text "$file" > "$temp_file"

    echo "1: Hello" >> "$temp_file2"
    echo "2: World!" >> "$temp_file2"

    diff_output=$(diff "$temp_file" "$temp_file2")

    echo "Expected:"
    cat "$temp_file2"
    echo "Output:"
    cat "$temp_file"

    [ -z "$diff_output" ] && log_success "Status: Passed" || log_error "Status: Failed"

    rm "$temp_file"
    rm "$temp_file2"
}


run_all_tests
