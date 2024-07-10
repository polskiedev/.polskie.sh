#!/bin/bash

pathinfo_override_command_git_from_json() {
    declare -A pathinfo

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
		return 1
	fi

	repo_path=$(git rev-parse --show-toplevel)
	repo_name=$(basename "$repo_path")

    pathinfo["settings_dir"]="$ENV_TMP_DIR/$ENV_TMP_SETTINGS"
	pathinfo["default_ticket_format"]="[[:alnum:]]{3,}-[0-9]{6}"
	pathinfo["default_ticket_prefix"]="DEV"
	pathinfo["default_ticket_max"]="6"

    pathinfo["default_file"]="default.json"
	pathinfo["settings_file"]="${repo_name}.json"
	pathinfo["settings_temp_file"]="temp.json"

	pathinfo["repository"]="$repo_name"

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

	local for_config_type=""
	if [[ -n "$1" ]]; then
		case "$1" in
			"--default") for_config_type="default" ;;
			"--repository") for_config_type="repository" ;;
			*)
				echo "Invalid parameter."
				return 1
				;;
		esac
	else
		echo "Config type not provided."
		return 1
	fi

	local type="settings"
	local repository="${pathinfo['repository']}"

	local settings_dir="${pathinfo['settings_dir']}"
	local settings_file="${pathinfo['settings_file']}"
	local settings_temp_file="${pathinfo['settings_temp_file']}"
	
	local default_file="${pathinfo['default_file']}"
	local default_ticket_format="${pathinfo['default_ticket_format']}"
	local default_ticket_prefix="${pathinfo['default_ticket_prefix']}"
	local default_ticket_max="${pathinfo['default_ticket_max']}"
	
	cleanup_override_command_git_from_json

	local json_file="${settings_dir}/${default_file}"
	local temp_json_file="${settings_dir}/${settings_temp_file}"

	declare -A settings_json=()
	declare -A setting_labels=()

	setting_labels["ticket_format"]="Ticket Format"
	setting_labels["ticket_max"]="Max length of Ticket No."
	setting_labels["ticket_prefix"]="Ticket Prefix"

	settings_json["ticket_format"]="$default_ticket_format"
	settings_json["ticket_prefix"]="$default_ticket_prefix"
	settings_json["ticket_max"]="$default_ticket_max"

	if [ "$for_config_type" = "repository" ]; then
		json_file="${settings_dir}/${settings_file}"
	fi

	make_json_file settings_json --file:"$json_file" --tmpfile:"$temp_json_file"

	echo "for_config_type: $for_config_type"
	if [ "$for_config_type" = "repository" ]; then
		declare -A json_file_data
		get_json_data json_file_data --file:"$json_file"

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
				jq_command+=" \"$json_file\" > \"$temp_json_file\" && mv \"$temp_json_file\" \"$json_file\""

				# echo "jq_command: $jq_command"
				eval "$jq_command"
			fi
		done
	fi

	echo "Config file '$json_file' output:"
	cat "$json_file"
}