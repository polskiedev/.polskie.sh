#!/bin/bash

pathinfo_override_command_git_from_json() {
    declare -A pathinfo

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
		return 1
	fi

	repo_path=$(git rev-parse --show-toplevel)
	repo_name=$(basename "$repo_path")

    pathinfo["settings_dir"]="$ENV_TMP_DIR/$ENV_TMP_SETTINGS"
    pathinfo["default_file"]="default.json"
	pathinfo["default_ticket_format"]="[[:alnum:]]{3,}-[0-9]{6}"
	pathinfo["default_ticket_prefix"]="DEV"
	pathinfo["default_ticket_max"]="6"
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

add_default_setting_override_command_git_from_json() {
	echo "add_default_setting_override_command_git_from_json()"
	eval "$(pathinfo_override_command_git_from_json)"

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

	echo '{}' > "$json_file"

	settings_json["ticket_format"]="$default_ticket_format"
	settings_json["ticket_prefix"]="$default_ticket_prefix"
	settings_json["ticket_max"]="$default_ticket_max"

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

	echo "jq_command: $jq_command"
	eval "$jq_command"
}

add_custom_setting_override_command_git_from_json() {
	echo "add_default_setting_override_command_git_from_json()"
	eval "$(pathinfo_override_command_git_from_json)"

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

	local json_file="${settings_dir}/${settings_file}"
	local temp_json_file="${settings_dir}/${settings_temp_file}"
	declare -A settings_json=()

	settings_json["repository"]="$repository"
	settings_json["ticket_format"]="$default_ticket_format"
	settings_json["ticket_prefix"]="$default_ticket_prefix"
	settings_json["ticket_max"]="$default_ticket_max"

	while true; do
		local ask0
		read -p "Would you like to create configuration file for repository '$repository'? (y/n) " ask0
		case "$ask0" in
			[Yy]|[Yy][Ee][Ss])
				break
				;;
			[Nn]|[Nn][Oo])
				echo "No problem!"
				return 1
				break
				;;
			*)
				echo "Please enter yes or no."
				;;
		esac
	done

	local ask1
	local ask2
	local ask3

	read -p "What would be the ticket format (default: '$default_ticket_format')? " ask1

	if [ -n "$ask1" ]; then
		settings_json["ticket_format"]t="$ask1"
	fi

	read -p "What would be the ticket prefix (default: '$default_ticket_prefix')? " ask2

	if [ -n "$ask2" ]; then
		settings_json["ticket_prefix"]="$ask2"
	fi

	read -p "What would be ticket max (default: '$default_ticket_max')? " ask3

	if [ -n "$ask3" ]; then
		settings_json["ticket_max"]="$ask2"
	fi

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

	echo "jq_command: $jq_command"
	eval "$jq_command"
}
