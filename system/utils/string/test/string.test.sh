#!/bin/bash
# devenv_precmd
source $(realpath "$HOME/.devenv.sources.sh")

test_strtolower() {
    log_info "Testing 'strtolower()' function"

    local text="HELLO world!"
    local result=$(strtolower "$text")
    local expected="hello world!"

    echo "Text: $text"
    echo "Expected: $expected"
    echo "Output: $result"
    [ "$result" = "$expected" ] && log_success "Status: Passed" || log_error "Status: Failed"
    echo "====="
}

test_strtoupper() {
    log_info "Testing 'strtoupper()' function"

    local text="HELLO world!"
    local result=$(strtoupper "$text")
    local expected="HELLO WORLD!"

    echo "Command: strtoupper \"$text\""
    echo "Text: $text"
    echo "Expected: $expected"
    echo "Output: $result"
    [ "$result" = "$expected" ] && log_success "Status: Passed" || log_error "Status: Failed"
    echo "====="
}

test_str_pad() {
    log_info "Testing 'str_pad()' function"

    local text="HELLO world!"
    local result=$(str_pad "$text" 20 "*" "both")
    local expected="****HELLO world!****"

    echo "Command: str_pad \"$text\" 20 \"*\" \"both\""
    echo "Text: $text"
    echo "Expected: $expected"
    echo "Output: $result"
    [ "$result" = "$expected" ] && log_success "Status: Passed" || log_error "Status: Failed"
    echo "====="
}

test_str_repeat() {
    log_info "Testing 'str_repeat()' function"

    local text="HELLO world!"
    local result=$(str_repeat "$text" 3)
    local expected="HELLO world!HELLO world!HELLO world!"

    echo "Command: str_repeat \"$text\" 3"
    echo "Text: $text"
    echo "Expected: $expected"
    echo "Output: $result"
    [ "$result" = "$expected" ] && log_success "Status: Passed" || log_error "Status: Failed"
    echo "====="
}

test_str_replace() {
    log_info "Testing 'str_replace()' function"

    local text="HELLO world!"
    local search="world"
    local replace_with="everyone"
    local result=$(str_replace "$search" "$replace_with" "$text")
    local expected="HELLO $replace_with!"

    echo "Command: str_replace \"$search\" \"$replace_with\" \"$text\""
    echo "Text: $text"
    echo "Expected: $expected"
    echo "Output: $result"
    [ "$result" = "$expected" ] && log_success "Status: Passed" || log_error "Status: Failed"
    echo "====="
}

test_str_split() {
    log_info "Testing 'str_split()' function"

    local text="abcdefghij"
    local split_length=3
    local result=$(str_split "$text" $split_length)
    local expected=("abc" "def" "ghi" "j")
    local has_error=false

    echo "Command: str_repeat \"$text\" $split_length"
    echo "Text: $text"
    echo "Output vs Expected:"

    # Split the string into an array
    IFS=' ' read -r -a array <<< "$(str_split "$text" "$split_length")"

    # Loop through the array, print each element with its index, and add conditions
    for index in "${!array[@]}"; do
        local element="${array[$index]}"
        local checker="${expected[$index]}"
        
        if [ "$element" == "$checker" ]; then
            echo "Result #$((index + 1)): '$element' vs '$checker' - ok"
        else
            has_error=true
            echo "Index $index: '$element' vs '$checker' - not ok"
        fi
    done

	if $has_error; then
		log_error "Status: Failed"
	else
		log_success "Status: Passed"
	fi
    echo "====="
}

test_strlen() {
    log_info "Testing 'strlen()' function"

    local text="HELLO world!"
    local result=$(strlen "$text")
    local expected=12

    echo "Command: strlen \"$text\""
    echo "Text: $text"
    echo "Expected: $expected"
    echo "Output: $result"
    [ "$result" = "$expected" ] && log_success "Status: Passed" || log_error "Status: Failed"
    echo "====="
}

test_substr() {
    log_info "Testing 'substr()' function"

    local text="HELLO world!"
    local start=6
    local length=5
    local result=$(substr "$text" $start $length)
    local expected="world"

    echo "Command: substr \"$text\" $start $length"
    echo "Text: $text"
    echo "Expected: $expected"
    echo "Output: $result"
    [ "$result" = "$expected" ] && log_success "Status: Passed" || log_error "Status: Failed"
    echo "====="
}

test_explode() {
    log_info "Testing 'explode()' function"

    local text="one,two,three,four"
    local separator=","
    local result=$(explode "$separator" "$text")
    local expected=("one" "two" "three" "four")
    local has_error=false

    echo "Command: explode \"$separator\" \"$text\""
    echo "Text: $text"
    echo "Output vs Expected:"

    # Split the string into an array
    IFS=' ' read -r -a array <<< "$result"

    # Loop through the array, print each element with its index, and add conditions
    for index in "${!array[@]}"; do
        local element="${array[$index]}"
        local checker="${expected[$index]}"
        
        if [ "$element" == "$checker" ]; then
            echo "Result #$((index + 1)): '$element' vs '$checker' - ok"
        else
            has_error=true
            echo "Index $index: '$element' vs '$checker' - not ok"
        fi
    done

	if $has_error; then
		log_error "Status: Failed"
	else
		log_success "Status: Passed"
	fi
    echo "====="
}

# ===========================================
# run_all_tests
# ===========================================
this_file="$PATH_POLSKIE_SH/system/utils/string/test/string.test.sh"
if [ ! -f "$this_file" ]; then
	echo "Error: File '$this_file' does not exist or is not readable."
	exit 1
fi

list=($(extract_test_functions "$this_file"))
# Get all functions starting with 'test_'
# for commonfunc in $(declare -F | awk '{print $3}' | grep -E '^test_'); do
for func in "${list[@]}"; do
	# Call the function
	$func
done
