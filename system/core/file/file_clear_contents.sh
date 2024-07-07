#!/bin/bash

file_clear_contents() {
	echo "file_clear_contents()"
	local writefile="$1"
	> "$writefile"  # Overwrite the existing file with an empty content
	# truncate -s 0 "$writefile"
}