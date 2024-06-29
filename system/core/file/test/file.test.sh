#!/bin/bash
# devenv_precmd
source $(realpath "$HOME/.devenv.sources.sh")

test_file_count_text() {
    log_info "Testing 'file_count_text' function"
    local file="$1"
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
    local file="$1"
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
    echo "====="
}

test_file_search_text() {
    log_info "Testing 'file_search_text' function"
    local file="$1"
    local search="World!"
    
    file_search_text "$file" "$search"
    echo "File: $file"
    echo "Search: $search"
    echo "File Content:"
    cat "$file"

    [ $? -eq 0 ] && log_success "Status: Passed" || log_error "Status: Failed"
    echo "====="
}

# ===========================================
# run_all_tests
# ===========================================

tmp_file_name="test.txt"
tmp_folder="$(realpath "$ENV_TMP_DIR")/.others"
tmp_file_path="$tmp_folder/$tmp_file_name"
log_info "Creating temporary file: $tmp_file_path"

# Make test file
touch "$tmp_file_path"
echo "Hello" >> "$tmp_file_path"
echo "World!" >> "$tmp_file_path"

this_file="$PATH_POLSKIE_SH/system/core/file/test/file.test.sh"
if [ ! -f "$this_file" ]; then
	echo "Error: File '$this_file' does not exist or is not readable."
	exit 1
fi

list=($(extract_test_functions "$this_file"))
# Get all functions starting with 'test_'
# for commonfunc in $(declare -F | awk '{print $3}' | grep -E '^test_'); do
for func in "${list[@]}"; do
	# Call the function
	$func $tmp_file_path
done

# Cleanup
log_info "Cleaning up temporary file: $tmp_file_path"
if [[ -f "$tmp_file_path" ]]; then
    rm "$tmp_file_path"
fi