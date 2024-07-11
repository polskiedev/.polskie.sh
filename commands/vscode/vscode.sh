#!/bin/bash

pathinfo_override_command_vscode() {
    declare -A pathinfo

    pathinfo["destination"]="$ENV_TMP_DIR/$ENV_TMP_LIST"
    pathinfo["filename"]="cd.txt"
    
    # Return associative array
    echo "$(declare -p pathinfo)"
}

cleanup_override_command_vscode() {
    # Unset the array, to prevent leakage
    unset pathinfo
}

dump_pathinfo_override_command_vscode() {
    # Evaluate the associative array returned by get_pathinfo_cd
    eval "$(pathinfo_override_command_vscode)"

    # Loop through each item in the associative array
    for key in "${!pathinfo[@]}"; do
        echo "$key: ${pathinfo[$key]}"
    done

    cleanup_override_command_vscode
}


go_to_list_override_command_vscode() {
    # Evaluate the associative array returned by get_pathinfo_cd
    eval "$(pathinfo_override_command_vscode)"

	local dest_path="${pathinfo['destination']}"
	local filename="${pathinfo['filename']}"
    local group_filename="$filename"
    local group="$1" 

    if [[ -n "$group" ]]; then
        group_filename="cd.group.${group}.txt"
        if [[ -f "$dest_path/$group_filename" ]]; then
            filename="$group_filename"
        fi
    fi

    local filepath="$dest_path/$filename"

    echo "Listing from '$filepath'"

    # Use fzf to select a directory from the list
    selected_dir=$(fzf  --prompt="Go to what directory? " < "$filepath")

    # Check if a directory was selected
    if [[ -n "$selected_dir" ]]; then
        # Change to the selected directory
        code "$selected_dir" || return 1
        echo "Opening VSCode Project: $selected_dir"
    else
        echo "No VSCode Project selected."
    fi

    cleanup_override_command_vscode
}
