#!/bin/bash

pathinfo_override_command_cd() {
    declare -A pathinfo

    pathinfo["destination"]="$ENV_TMP_DIR/$ENV_TMP_LIST"
    pathinfo["filename"]="cd.txt"
    
    # Return associative array
    echo "$(declare -p pathinfo)"
}

cleanup_override_command_cd() {
    # Unset the array, to prevent leakage
    unset pathinfo
}

dump_pathinfo_override_command_cd() {
    # Evaluate the associative array returned by get_pathinfo_cd
    eval "$(pathinfo_override_command_cd)"

    # Loop through each item in the associative array
    for key in "${!pathinfo[@]}"; do
        echo "$key: ${pathinfo[$key]}"
    done

    cleanup_override_command_cd
}

add_to_list_override_command_cd() {
    eval "$(pathinfo_override_command_cd)"

	local dest_path="${pathinfo['destination']}"
	local filename="${pathinfo['filename']}"
    local group_filename="$filename"
	local type="list"
    local group="$1" 

    if [[ -n "$group" ]]; then
        group_filename="cd.group.${group}.txt"
        # if [[ -f "$dest_path/$group_filename" ]]; then
            filename="$group_filename"
        # fi
    fi

	add_to_temp "$type" "$filename" "$PWD"

    cleanup_override_command_cd

	# local filepath="$dest_path/$filename"
	# echo "================="
	# echo "History: '$filepath'"
	# cat $filepath

}

go_to_list_override_command_cd() {
    # Evaluate the associative array returned by get_pathinfo_cd
    eval "$(pathinfo_override_command_cd)"

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

    cleanup_override_command_cd
}

override_command_cd() {
    declare -A result
    declare -a remaining_parameters
    local requested_vars=("psh" "showdata")
    local args=("$@")

    process_args result remaining_parameters requested_vars[@] "${args[@]}"
    count=${#remaining_parameters[@]}

    if [[ "${result["showdata"]}" = true ]]; then
        IFS=','; joined_string="${args[*]}"; unset IFS
        echo "Passed Arguments: ($joined_string)"

        echo "Request Parameters:"
        for key in "${!result[@]}"; do
            echo "$key: ${result[$key]}"
        done

        echo "Remaining Parameters:"
        for param in "${remaining_parameters[@]}"; do
            echo "$param"
        done
    fi

    if [[ "${result["psh"]}" = true ]]; then
        go_to_list_override_command_cd "${remaining_parameters[@]}"
    # elif [ $count -eq 0 ]; then
    #     echo "cd: No arguments passed."
    else
        # echo "Remaining Parameters:"
        # for param in "${remaining_parameters[@]}"; do
        #     echo "$param"
        # done
        
        # Just pass it all to cd
        command cd "${remaining_parameters[@]}"
    fi
}