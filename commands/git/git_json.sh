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

	if [[ ! -f "$json_file" ]]; then
		echo "Creating default configuration for repository: '$repository'"
		echo '{}' > "$json_file"

		# Process json file creation
		local jq_command_list=()
		local jq_command_str
		local jq_command="jq"
		local jq_command2="'{"

		for key in "${!settings_json[@]}"; do
			value=${settings_json[$key]}
			# echo "$key: $value"
			jq_command+=" --arg $key \"$value\" [newline]"
			jq_command_list+=("\"$key\": \$$key")
		done

		jq_command_str=$(IFS=,; echo "${jq_command_list[*]}")
		jq_command_str="${jq_command_str//,/, }"

		jq_command2+=$jq_command_str
		jq_command2+="}' [newline]"

		jq_command+=" $jq_command2"
		jq_command+=" \"$json_file\" [newline]> \"$temp_json_file\" [newline]"
		jq_command+=" && mv \"$temp_json_file\" \"$json_file\""

		jq_command="$(echo $jq_command | sed -e 's/\[newline\]/\\'\\n'/g')"

		# echo "jq_command: $jq_command"
		eval "$jq_command"
	fi

	if [ "$for_config_type" = "repository" ]; then
		compressed_output=$(jq -c '.' "$json_file")
		jq_output=$(echo "$compressed_output" | jq -r 'to_entries[] | "\(.key) \(.value)"')

		declare -A json_data
	
		# Read compressed JSON output line by line
		while IFS= read -r line; do
			key=$(echo "$line" | awk '{print $1}')
			value=$(echo "$line" | awk '{$1=""; print $0}' | xargs)
			json_data["$key"]=$value
		done <<< "$jq_output"

		# for key in "${!json_data[@]}"; do
		# 	echo "$key: $value"
		# done

		for key in "${!setting_labels[@]}"; do
			local ask1
			local label=${setting_labels[$key]}
			local current_value="${json_data["$key"]}"
			local default_value="${settings_json["$key"]}"
			local value="$current_value"
			# echo "$key: $value"

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

	echo "Config File: $json_file"
}