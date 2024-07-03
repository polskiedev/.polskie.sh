#!/bin/bash

slugify() {
    local input="$1"
    # Convert to lowercase
    local lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    # Replace spaces with dashes
    local no_spaces=$(echo "$lower" | tr ' ' '-')
    # Remove all characters except lowercase letters, digits, dashes, and underscores
    local cleaned=$(echo "$no_spaces" | sed 's/[^a-z0-9_\-]//g')
    # Replace multiple dashes with a single dash
    local single_dash=$(echo "$cleaned" | tr -s '-')
    # Trim dashes from the start and end of the text
    local trimmed=$(echo "$single_dash" | sed 's/^-//;s/-$//')
    echo "$trimmed"

	# echo "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]/-/g' -e 's/--*/-/g' -e 's/-$//' -e 's/^-//'
}