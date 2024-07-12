#!/bin/bash

pathinfo_override_command_git_from_json() {
    declare -A pathinfo

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
		return 1
	fi

	repo_path=$(git rev-parse --show-toplevel)
	repo_name=$(basename "$repo_path")

    pathinfo["settings_dir"]="$ENV_TMP_DIR/$ENV_TMP_SETTINGS"
	pathinfo["repository"]="$repo_name"
	pathinfo["branch"]="$(git branch --show-current)"

	pathinfo["default_ticket_format"]="[[:alnum:]]{3,}-[0-9]{6}"
	pathinfo["default_ticket_prefix"]="DEV"
	pathinfo["default_ticket_max"]="6"

    pathinfo["default_file"]="default.json"
	pathinfo["repository_file"]="${repo_name}.json"
	pathinfo["temp_file"]="temp.json"

	pathinfo["label_ticket_format"]="Ticket Format"
	pathinfo["label_ticket_max"]="Max length of Ticket No."
	pathinfo["label_ticket_prefix"]="Ticket Prefix"

	pathinfo["key_previous_branch"]="previous_branch"

    # Return associative array
    echo "$(declare -p pathinfo)"
}

cleanup_override_command_git_from_json() {
    # Unset the array, to prevent leakage
    unset pathinfo
}

modify_config_file_override_command_git_from_json() {
	echo "modify_config_file_override_command_git_from_json()"
	eval "$(pathinfo_override_command_git_from_json)"
	# ###############################################
    declare -A result
    declare -a remaining_parameters
    local requested_vars=("showdata" "config")
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
	# ###############################################
	local config_type=""

	case "${result["config"]}" in
		"default" | "repository") config_type="${result["config"]}" ;;
		*)
			echo "Config type not provided."
			return 1
			;;
	esac
	# ###############################################
	local repository="${pathinfo['repository']}"

	declare -A config_files=()
	declare -a data_files=("default_file" "repository_file" "temp_file") 
	declare -a data_column=("ticket_format" "ticket_max" "ticket_prefix")
	declare -A settings_json=()
	declare -A setting_labels=()

	for item in "${data_files[@]}"; do
		config_files[$item]="${pathinfo['settings_dir']}/${pathinfo["$item"]}"
	done

	for item in "${data_column[@]}"; do
		settings_json[$item]="${pathinfo["default_$item"]}"
		setting_labels[$item]="${pathinfo["label_$item"]}"
	done

	local config_file="${config_files['default_file']}"
	local temp_file="${config_files['temp_file']}"

	if [ "$config_type" = "repository" ]; then
		config_file="${config_files['repository_file']}"
	fi

	cleanup_override_command_git_from_json

	make_json_file settings_json --file:"$config_file" --tmpfile:"$temp_file"

	if [ "$config_type" = "repository" ]; then
		declare -A json_file_data
		get_json_data json_file_data --file:"$config_file"

		# for key2 in "${!json_file_data[@]}"; do
		# 	local value2="${json_file_data[$key2]}"
		# 	echo "2: $key2: $value2"
		# done

		for key in "${!setting_labels[@]}"; do
			local ask1
			local label=${setting_labels[$key]}
			local current_value="${json_file_data["$key"]}"
			local default_value="${settings_json["$key"]}"
			local value="$current_value"
			# echo "$key: $value"

			echo "========="
			echo "Default '$label' is '$default_value'"
			read -p "What would be the '$label' in repository '$repository' (Current: '$current_value')? " ask1

			if [ -n "$ask1" ]; then
				value="$ask1"
			fi

			if [ "$current_value" != "$value" ]; then
				local jq_command="jq '." 
				jq_command+="$key = "
				jq_command+='"'
				jq_command+="$value"
				jq_command+='"'
				jq_command+="'"
				jq_command+=" \"$config_file\" > \"$temp_file\" && mv \"$temp_file\" \"$config_file\""

				# echo "jq_command: $jq_command"
				eval "$jq_command"
			fi
		done

		echo "JSON file: '$config_file'"
		echo "JSON file contents:"
		cat "$config_file"
	fi
}