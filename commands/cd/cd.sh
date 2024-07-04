#!/bin/bash

get_pathinfo_cd_list() {
    declare -A pathinfo

    pathinfo["destination"]="$ENV_TMP_DIR/$ENV_TMP_LIST"
    
    # Return associative array
    echo "$(declare -p pathinfo)"
}

dump_pathinfo_cd_list() {
    # Evaluate the associative array returned by get_pathinfo_cd_list
    eval "$(get_pathinfo_cd_list)"

    # Loop through each item in the associative array
    for key in "${!pathinfo[@]}"; do
        echo "$key: ${pathinfo[$key]}"
    done
}

add_cd_list() {
    eval "$(get_pathinfo_cd_list)"

	local dest_path="${pathinfo['destination']}"
	local filename="cd.txt"
	local filepath="$dest_path/$filename"
	local type="list"

	add_to_temp "$type" "$filename" "$PWD"

	# echo "================="
	# echo "History: '$filepath'"
	# cat $filepath
}

show_cd_list() {
    # Evaluate the associative array returned by get_pathinfo_cd_list
    eval "$(get_pathinfo_cd_list)"

	local dest_path="${pathinfo['destination']}"
	local filename="cd.txt"
	local filepath="$dest_path/$filename"

    # Use fzf to select a directory from the list
    selected_dir=$(fzf  --prompt="Go to what directory? " < "$filepath")

    # Check if a directory was selected
    if [[ -n "$selected_dir" ]]; then
        # Change to the selected directory
        cd "$selected_dir" || return 1
        echo "Changed directory to: $selected_dir"
    else
        echo "No directory selected."
    fi
}