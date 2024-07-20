#!/bin/bash
# Todo:
# - Make all git add to be base from repository base
# pathinfo_override_command_git() {
#     declare -A pathinfo

#     pathinfo["settings_dir"]="$ENV_TMP_DIR/$ENV_TMP_SETTINGS"
#     pathinfo["default_file"]="default"
# 	pathinfo["format_ticket"]=".format_ticket"
# 	pathinfo["ticket_prefix"]=".ticket_prefix"
# 	pathinfo["ticket_max"]=".ticket_max"
	
# 	local repo_name=$(get_git_repo_name)

# 	local default_file="${pathinfo['default_file']}"
# 	local settings_dir="${pathinfo['settings_dir']}"

# 	local ticket_prefix="${pathinfo['ticket_prefix']}"
# 	local format_ticket="${pathinfo['format_ticket']}"
# 	local ticket_max="${pathinfo['ticket_max']}"

# 	local default_file_format_ticket="${default_file}${format_ticket}.txt"
# 	local default_file_ticket_prefix="${default_file}${ticket_prefix}.txt"
# 	local default_file_ticket_max="${default_file}${ticket_max}.txt"

# 	local file_format_ticket="${repo_name}${format_ticket}.txt"
# 	local file_ticket_prefix="${repo_name}${ticket_prefix}.txt"
# 	local file_ticket_max="${repo_name}${ticket_max}.txt"

# 	local ticket_format=""
# 	local ticket_prefix_txt=""
# 	local ticket_max_num=0

# 	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# 	# This block is using the old txt file method of saving settings @Start
# 	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# 	if [ -f "${settings_dir}/${file_format_ticket}" ]; then
# 		ticket_format=$(head -n 1 "${settings_dir}/${file_format_ticket}")
# 	elif [ -f "${settings_dir}/${default_file_format_ticket}" ]; then
# 		ticket_format=$(head -n 1 "${settings_dir}/${default_file_format_ticket}")
# 	fi

# 	if [ -f "${settings_dir}/${file_ticket_prefix}" ]; then
# 		ticket_prefix_txt=$(head -n 1 "${settings_dir}/${file_ticket_prefix}")
# 	elif [ -f "${settings_dir}/${default_file_ticket_prefix}" ]; then
# 		ticket_prefix_txt=$(head -n 1 "${settings_dir}/${default_file_ticket_prefix}")
# 	fi

# 	if [ -f "${settings_dir}/${file_ticket_max}" ]; then
# 		ticket_max_num=$(head -n 1 "${settings_dir}/${file_ticket_max}")
# 	elif [ -f "${settings_dir}/${default_file_ticket_max}" ]; then
# 		ticket_max_num=$(head -n 1 "${settings_dir}/${default_file_ticket_max}")
# 	fi
# 	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# 	# This block is using the old txt file method of saving settings @End
# 	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# 	pathinfo["ticket_format"]="$ticket_format"
# 	pathinfo["ticket_prefix_txt"]="$ticket_prefix_txt"
# 	pathinfo["ticket_max_num"]=$ticket_max_num
# 	pathinfo["repository"]=$repo_name

# 	pathinfo["default_file_format_ticket"]=$default_file_format_ticket
# 	pathinfo["default_file_ticket_prefix"]=$default_file_ticket_prefix
# 	pathinfo["default_file_ticket_max"]=$default_file_ticket_max

# 	pathinfo["file_format_ticket"]=$file_format_ticket
# 	pathinfo["file_ticket_prefix"]=$file_ticket_prefix
# 	pathinfo["file_ticket_max"]=$file_ticket_max

# 	pathinfo["default_ticket_format"]="[[:alnum:]]{3,}-[0-9]{6}"
# 	pathinfo["default_ticket_prefix"]="DEV"
# 	pathinfo["default_ticket_max"]="6"

#     # Return associative array
#     echo "$(declare -p pathinfo)"
# }

cleanup_override_command_git() {
    # Unset the array, to prevent leakage
    unset pathinfo
}

get_git_repo_name() {
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        repo_path=$(git rev-parse --show-toplevel)
        repo_name=$(basename "$repo_path")
        echo "$repo_name"
		return 0
    else
        return 1
    fi
}

dump_override_command_git() {
	eval "$(pathinfo_override_command_git_from_json)"

	echo "Unsorted:"
	for key2 in "${!pathinfo[@]}"; do
		local value2="${pathinfo[$key2]}"
		echo "1: $key2: $value2"
	done

	echo "Sorted:"
	local sorted_keys=($(for key in "${!pathinfo[@]}"; do echo "$key"; done | sort))
	for key2 in "${sorted_keys[@]}"; do
		local value2="${pathinfo[$key2]}"
		echo "2: $key2: $value2"
	done
}

git_actions_list_override_command_git() {
	local default_choice=""
	declare -A options=()
	options["add_all"]="Git add all"
	options["add_picked"]="Git pick then add"
	options["create_branch"]="Create Branch"
	options["commit"]="Commit Changes"
	options["status"]="Git status"
	options["add_default_config"]="Add default JSON configuration"
	options["add_repository_config"]="Add repository JSON configuration"
	# options["test"]="Test"

	# Transform the associative array into the desired format
	formatted_options=()
	for key in "${!options[@]}"; do
		formatted_options+=("${key}:${options[$key]}")
	done

	selected_option=$(printf "%s\n" "${formatted_options[@]}" | fzf --delimiter=":" --with-nth=2 --query="$default_choice")
	if [[ -n "$selected_option" ]]; then
        local predefined_output=$(echo "$selected_option" | cut -d: -f1)
        case "$predefined_output" in
            "add_all")
				add_override_command_git .
				;;
            "add_picked")
				add_override_command_git
				;;
			"create_branch")
				create_branch_override_command_git
				;;
			"status")
				status_override_command_git
				;;
			"commit")
				commit_override_command_git
				;;
			"add_default_config")
				modify_config_file_override_command_git_from_json --config:repository
				;;
			"add_repository_config")
				modify_config_file_override_command_git_from_json --config:default
				;;
			# "test")
			# 	echo "Under maintenance: @test"
			# 	local msg
			# 	read -p "Please enter message: " msg
			# 	echo "Message: $msg"
			# 	;;
            *)
                echo "git_add_options_override_command_git(): Invalid parameter action '$predefined_output'"
                return 1
                ;;
        esac
	fi
}

create_branch_override_command_git() {
	eval "$(pathinfo_override_command_git_from_json)"
	# ###############################################
	declare -a data_files=("default_file" "repository_file" "temp_file")
	declare -a data_column=("ticket_format" "ticket_max" "ticket_prefix")
	declare -A config_files=()
	for item in "${data_files[@]}"; do
		config_files[$item]="${pathinfo['settings_dir']}/${pathinfo["$item"]}"
	done

	local config_file="${config_files['repository_file']}"
    declare -A json_result2
    get_json_data json_result2 --file:"$config_file"

	# for item in "${data_column[@]}"; do
	# 	data_json[$item]="${json_file_data["$item"]}"
	# done
	
	local ticket_format="${json_result2['ticket_format']}"
	local ticket_prefix="${json_result2['ticket_prefix']}"
	# if [ ! -v 'json_result2[$key_previous_branch]' ]; then
	# 	echo "Configuration '$key_previous_branch' not set on JSON file."
	# 	return 1
	# fi

	local repository="${pathinfo['repository']}"
	local current_branch="${pathinfo['branch']}"
	if [ "$repository" = "" ]; then
        echo "Current directory is not in any git repository."
		return 1
	fi

	cleanup_override_command_git_from_json

	# ###############################################
	while true; do
		local is_base_branch_ok
		read -p "Are you want to create a new branch based from \`${repository}\`.\`$current_branch\`? (y/n) " is_base_branch_ok

        case "$good_base_branch" in
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
	# ###############################################
	declare -A options=()
	options["bugfix"]="Bugfix"
	options["hotfix"]="Hotfix"
	options["improvement"]="Feature"
	options["feature"]="Feature"

	# Default choice
	local default_choice=""

	# Transform the associative array into the desired format
	formatted_options=()
	for key in "${!options[@]}"; do
		formatted_options+=("${options[$key]}| ${key}/")
	done

	# Use fzf to select from the list
	selected_option=$(printf "%s\n" "${formatted_options[@]}" | fzf --query="$default_choice")

	local branch_type=""
	# Handle the selected option
	if [[ -n "$selected_option" ]]; then
		value="${selected_option%|*}"
		key="${selected_option#*| }"
		key="${key%/}"

		if [ "$(strtolower "$value")" != "$key" ]; then
			echo "Selected: $value ($key)"
		else 
			echo "Selected: $key"
		fi
		
		branch_type="${key}"
	else
		echo "No option selected"
		return 1
	fi

	local ticket_no
	while true; do
		local answer
		local formatted_answer
		
		read -p "Enter ticker number (Prefix: '${ticket_prefix}', Format: ${ticket_format}): " answer

		# Validate if the input is a number
		if [[ "$answer" =~ ^[0-9]+$ ]]; then
			answer="${ticket_prefix}-$answer"
		fi

		formatted_answer=$(echo "$answer" | \
			awk -F'/' '{print $NF}' | \
			grep -oE "$ticket_format")
			
		local count_error=0

		if test "${answer#"$ticket_prefix"}" = "$answer"; then
			((count_error++))
			echo "'$answer' does not match the prefix pattern '$ticket_prefix'"
		fi

		if [ -n "$formatted_answer" ]; then
			ticket_no="$formatted_answer"
		else
			((count_error++))
			echo "'$answer' does not match the ticket format pattern '$ticket_format'"
		fi
		
		if [ "$count_error" -eq 0 ]; then
			break
		else
			echo "Errors: $count_error"
		fi
	done

	# echo "ticket_no: $ticket_no"
	local ticket_desc
	read -p "Please enter a short description of the ticket? " ticket_desc

	ticket_desc=$(slugify "$ticket_desc")
	# echo "ticket_desc: $ticket_desc"

	local branch_name="${branch_type}/${ticket_no}-${ticket_desc}"
	while true; do
		local create_now
		local commit_msg="${current_ticket_no}: $(ucfirst "$msg")"
		read -p "Are you okay with this branch name \"$branch_name\"? (y/n) " create_now

        case "$create_now" in
            [Yy]|[Yy][Ee][Ss])
				# git checkout -b <branch_name>
				# git switch -c <branch_name>

				git switch -c "$branch_name"

				# Check if the command was successful
				if [[ $? -eq 0 ]]; then
					echo "Successfully created and switched to branch '$branch_name'."
				else
					echo "Failed to create and switch to branch '$branch_name'."
					return 1
				fi
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
}

override_command_git() {
	echo "override_command_git()"
	# ###############################################
	eval "$(pathinfo_override_command_git_from_json)"

	declare -a data_files=("default_file" "repository_file" "temp_file") 
	declare -a data_column=("ticket_format" "ticket_max" "ticket_prefix")
	declare -A config_files=()
	declare -A config_filenames=()

	for item in "${data_files[@]}"; do
		config_files[$item]="${pathinfo['settings_dir']}/${pathinfo["$item"]}"
		config_filenames[$item]="${pathinfo["$item"]}"
	done

	# ###############################################
	local repository="${pathinfo['repository']}"
	local current_branch="${pathinfo['branch']}"

	if [ "$repository" = "" ]; then
        echo "Current directory is not in any git repository."
		return 1
	fi
	# ###############################################
	local config_file="${config_files['repository_file']}"
	local temp_file="${config_files['temp_file']}"

	local key_previous_branch="${pathinfo['key_previous_branch']}"
	local latest_branch=""

    declare -A json_result2
    get_json_data json_result2 --file:"$config_file"
	
	if [ ! -v 'json_result2[$key_previous_branch]' ]; then
		echo "Configuration '$key_previous_branch' not set on JSON file."
		return 1
	fi

	if [ "${json_result2["$key_previous_branch"]}" = "" ]; then
		echo "Configuration '$key_previous_branch' not set."
		return 1
	fi

	previous_branch="${json_result2["$key_previous_branch"]}"
	# echo "current_branch: $current_branch"
	# echo "previous_branch: $previous_branch"
	
	cleanup_override_command_git_from_json
	# ###############################################
	local git_command="$1"
	local git_command2="$2"
	shift 2

	# This will make default behaviour to revert to previous branch
	if [ "$git_command" = "-" ]; then
		git_command="checkout"
		git_command2="-"
	fi	
	# ###############################################
    declare -A result
    declare -a remaining_parameters
    local requested_vars=("showdata")
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
	# Temp only
	if [ "$git_command" != "checkout" ]; then
		command git "$git_command" "$@"
		git "$git_command" "$@"
		return
	fi
	# ###############################################
	if [ "$git_command" == "checkout" ]; then
		if [ "$git_command2" = "-" ]; then
			shift
			command git "$git_command" "$previous_branch" "$@"
		else
			command git "$git_command" "$git_command2" "$@"
		fi
		
		if [ $? -eq 0 ]; then
			log_info "Checkout successful"
			local latest_branch="$(git branch --show-current)"
			if [ "$current_branch" != "$latest_branch" ]; then
				modify_json_data --file:"$config_file" --tmpfile:"$tmp_file" --jsonkey:"$key_previous_branch" --jsonvalue:"$current_branch"
			fi
		else
			log_error "Failed to checkout"
		fi
	fi
}

status_override_command_git() {
	log_info "status_override_command_git()"
	eval "$(pathinfo_override_command_git_from_json)"

	local repository="${pathinfo['repository']}"
	local current_branch="${pathinfo['branch']}"

	cleanup_override_command_git_from_json

	if [ "$repository" = "" ]; then
        echo "Current directory is not in any git repository."
		return 1
	fi

    echo "Repository: '$repository'"
	echo "Branch Name: '$current_branch'"
	# ###############################################
	# local repo_name=""
	# local branch_name=""

    # if ! repo_name=$(get_git_repo_name); then
    #     log_error "Current directory is not in any git repository."
	# 	return 1
    # else
    #     log_info "Repository: '$repo_name'"
    # fi

	# branch_name="$(git branch --show-current)"

	# log_info "Branch: '$branch_name'"
	command git status
}

add_override_command_git() {
	echo "status_override_command_git()"
	eval "$(pathinfo_override_command_git_from_json)"
	# ###############################################
    declare -A result
    declare -a remaining_parameters
    local requested_vars=("showdata")
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
	local repository="${pathinfo['repository']}"
	local repository_base_directory="${pathinfo['repository_base_directory']}"
	local current_branch="${pathinfo['branch']}"
	cleanup_override_command_git_from_json
	# ###############################################
	# local repo_name=""
	# local branch_name=""
	if [ "$repository" = "" ]; then
        echo "Current directory is not in any git repository."
		return 1
	fi

    echo "Repository: '$repository'"
	echo "Branch Name: '$current_branch'"
	# ###############################################
	local git_add_all=false
	for param in "${remaining_parameters[@]}"; do
		if [ "$param" = "." ]; then
			git_add_all=true
		fi
	done

	local git_added=0
	if [[ "$git_add_all" = true ]]; then
		git_added=1
		log_info "Adding all changes to git"
		command git add .
	else
		local counter=0
		# Sort by status, then by path_name
		local git_status=$(git status --porcelain | sort -k1,1 -k2 -r)
		local formatted_files=()
		# Process each line of git status output
		while IFS= read -r line; do
			((counter++))
			# Extract status and file path
			local status="${line:0:2}"
			local file="${line:3}"

			# Print status and file in the required format
			formatted_file="$counter|${status}| ${file}"
			formatted_files+=("$formatted_file")
		done <<< "$git_status"

		if [ -z "$git_status" ]; then
			log_info "Nothing to update."
			return 1
		fi

		local preview='file="$(echo "{}" | \
							tr -d "###" | \
							cut -d"|" -f3 | \
							sed -e "s/^[[:space:]]*//" -e "s/[[:space:]]*$//")"; \
						if [ -f "$file" ]; then \
							echo "File: $file"; \
							echo "================================="; \
							cat "$file"; \
						else \
							if [ -e "$file" ]; then \
								echo "$file has no preview available"; \
							else \
								echo "$file does not exist."; \
							fi \
						fi'
		# echo "$file is a $(file -b "$file")"; \
		preview=$(echo "$preview" | sed -e "s/###/'/g")

		local header=("Repository: '$repository'" \
			"Branch: '$current_branch'" \
			"-------------------" \
			"Use [tab] key to select" \
		)

		header=$(printf '%s\n' "${header[@]}")

		local prompt="Choose files you want to add: "
		local selected_options=$(printf '%s\n' "${formatted_files[@]}" | \
					fzf \
					--prompt="$prompt" \
					--preview-window='right:50%:wrap'\
					--preview="$preview" \
					--multi \
					--header="$header"\
				)
		# local option_count=$(echo "$selected_options" | wc -l)

		if [ -z "$selected_options" ]; then
			log_info "No items selected."
			return 1
		fi

		# Loop through each selected item
		while IFS= read -r item; do
			# echo "Selected: $item"
			# Process each selected item here
			local filename="$(echo "$item" | cut -d"|" -f3 | trim)"
			
			if [[ -n "$filename" ]]; then
				if git add "$repository_base_directory/$filename"; then
					log_success "Added '$filename' to git"
					((git_added++))
				else
					log_error "Failed to add '$filename' to git"
				fi
			fi
		done <<< "$selected_options"
	fi

	local commit_now=false
	if [ $git_added -gt 0 ]; then
		while true; do
			local answer
			read -p "Do you want to commit changes? (y/n) " answer
			case "$answer" in
				[Yy]|[Yy][Ee][Ss])
					commit_now=true
					break
					;;
				[Nn]|[Nn][Oo])
					echo "No problem!"
					break
					;;
				*)
					echo "Please enter yes or no."
					;;
			esac
		done
	fi

	if [[ "$commit_now" = true ]]; then
		local commit_msg
		read -p "Please enter commit message: " commit_msg
		echo "Git Commit Message: $commit_msg"
		commit_override_command_git	"$commit_msg"
	fi
}

commit_override_command_git() {
	echo "commit_override_command_git()"
	# ###############################################
	local all_params="$*"
	local msg="$(echo "$all_params")"

	while true; do
		if [ "$msg" = "" ]; then
			local read_msg
			read -p "Please enter commit message: " read_msg
			msg="$read_msg"
		else
			break
		fi
	done
	# ###############################################
	# eval "$(pathinfo_override_command_git)"
	eval "$(pathinfo_override_command_git_from_json)"

	declare -A config_files=()
	declare -A data_json=()
	declare -a data_files=("default_file" "repository_file" "temp_file") 
	declare -a data_column=("ticket_format" "ticket_max" "ticket_prefix")

	for item in "${data_files[@]}"; do
		config_files[$item]="${pathinfo['settings_dir']}/${pathinfo["$item"]}"
	done

	local repository="${pathinfo['repository']}"
	local current_branch="${pathinfo['branch']}"

	if [ "$repository" = "" ]; then
        echo "Current directory is not in any git repository."
		return 1
	fi

    echo "Repository: '$repository'"
	echo "Current Branch: '$current_branch'"

	local config_file="${config_files['repository_file']}"
	local temp_file="${config_files['temp_file']}"

	declare -A json_file_data
	get_json_data json_file_data --file:"$config_file"

	for key2 in "${!json_file_data[@]}"; do
		local value2="${json_file_data[$key2]}"
		# echo "1: $key2: $value2"
	done

	for item in "${data_column[@]}"; do
		data_json[$item]="${json_file_data["$item"]}"
	done

	local ticket_format="${data_json['ticket_format']}"
	# return
	cleanup_override_command_git_from_json
	# ###############################################

	# local ticket_prefix="${pathinfo['ticket_prefix']}"
	# local format_ticket="${pathinfo['format_ticket']}"
	# local ticket_max="${pathinfo['ticket_max']}"

	# local ticket_prefix_txt="${pathinfo['ticket_prefix_txt']}"
	# local ticket_max_num="${pathinfo['ticket_max_num']}"

	# cleanup_override_command_git

	local new_ticket_no=""
	local has_ticket_no=false
	local ticket_max="${json_file_data['ticket_max']}"
	local ticket_prefix="${json_file_data['ticket_prefix']}"
	local pad_length=$((ticket_max - 1))
	local default_ticket_no=1
	local current_ticket_no=$(echo "$current_branch" | \
		awk -F'/' '{print $NF}' | \
		grep -oE "${json_file_data['ticket_format']}")

    if [ -n "$current_ticket_no" ]; then
        # msg="$current_ticket_no: $(capitalize_first_letter "$all_params")"
		echo "Ticket No: $current_ticket_no"
		has_ticket_no=true
	else
		new_ticket_no="$ticket_prefix-$(str_pad "" $pad_length "0")${default_ticket_no}"
	fi

	if [[ "$has_ticket_no" = false ]]; then
		while true; do
			local answer
			local formatted_answer
			read -p "Enter ticker number (default: $new_ticket_no): " answer

			if [ -z "$answer" ]; then
				current_ticket_no="$new_ticket_no"
				break
			else
				# Validate if the input is a number
				if [[ "$answer" =~ ^[0-9]+$ ]]; then
					answer="$ticket_prefix-$(str_pad "" $pad_length "0")${answer}"
				fi

				formatted_answer=$(echo "$answer" | \
					awk -F'/' '{print $NF}' | \
					grep -oE "$ticket_format")
				
				local count_error=0

				if test "${answer#"$ticket_prefix"}" = "$answer"; then
					((count_error++))
					echo "'$answer' does not match the prefix pattern '$ticket_prefix'"
				fi
					
				if [ -n "$formatted_answer" ]; then
					current_ticket_no="$formatted_answer"
				else
					((count_error++))
					echo "'$answer' does not match the ticket format pattern '$ticket_format'"
				fi

				if [ "$count_error" -eq 0 ]; then
					break
				else
					echo "Errors: $count_error"
				fi
			fi
		done
	fi

	while true; do
		local commit_now
		local commit_msg="${current_ticket_no}: $(ucfirst "$msg")"
		read -p "Are you okay with this commit message \"$commit_msg\"? (y/n) " commit_now

        case "$commit_now" in
            [Yy]|[Yy][Ee][Ss])
                echo "git commit -m \"$commit_msg\""
                command git commit -m "$commit_msg"
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

	while true; do
		local push_now
		read -p "Do you want to push changes you've made? (y/n) " push_now
		case "$push_now" in
			[Yy]|[Yy][Ee][Ss])
				command git push origin HEAD 
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
}

# add_default_setting_override_command_git() {
# 	echo "add_default_setting_override_command_git()"
# 	eval "$(pathinfo_override_command_git)"

# 	local type="settings"
# 	local settings_dir="${pathinfo['settings_dir']}"

# 	local format_ticket="${pathinfo['default_file_format_ticket']}"
# 	local ticket_prefix="${pathinfo['default_file_ticket_prefix']}"
# 	local ticket_max="${pathinfo['default_file_ticket_max']}"

# 	cleanup_override_command_git

# 	add_to_temp "$type" "$format_ticket" "[[:alnum:]]{3,}-[0-9]{6}"
# 	add_to_temp "$type" "$ticket_prefix" "DEV"
# 	add_to_temp "$type" "$ticket_max" "6"
# }

# add_custom_setting_override_command_git() {
# 	# Todo: Fix variable naming
# 	# ! To deprecate, causing to many files
# 	echo "add_custom_setting_override_command_git()"
# 	eval "$(pathinfo_override_command_git)"

# 	local type="settings"
# 	local settings_dir="${pathinfo['settings_dir']}"

# 	local format_ticket="${pathinfo['file_format_ticket']}"
# 	local ticket_prefix="${pathinfo['file_ticket_prefix']}"
# 	local ticket_max="${pathinfo['file_ticket_max']}"

# 	local default_ticket_format="${pathinfo['default_ticket_format']}"
# 	local default_ticket_prefix="${pathinfo['default_ticket_prefix']}"
# 	local default_ticket_max="${pathinfo['default_ticket_max']}"
# 	local repository="${pathinfo['repository']}"
	
# 	cleanup_override_command_git

# 	if [ ! -f "${settings_dir}/${format_ticket}" ]; then
# 		local ask1
# 		local new_format_ticket="$default_ticket_format"
# 		read -p "Format ticket settings not found for repository '$repository'. \
# 					Creating file. What would be the format (default: '$default_ticket_format')? " ask1

# 		if [ -n "$ask1" ]; then
# 			new_format_ticket="$ask1"
# 		fi

# 		add_to_temp "$type" "$format_ticket" "$new_format_ticket"
# 	fi

# 	if [ ! -f "${settings_dir}/${ticket_prefix}" ]; then
# 		local ask2
# 		local new_ticket_prefix="$default_ticket_prefix"
# 		read -p "Ticket prefix settings not found for repository '$repository'. \
# 					What would be the ticket prefix (default: '$default_ticket_prefix')? " ask2

# 		if [ -n "$ask2" ]; then
# 			new_ticket_prefix="$ask2"
# 		fi
		
# 		add_to_temp "$type" "$ticket_prefix" "$new_ticket_prefix"
# 	fi

# 	if [ ! -f "${settings_dir}/${ticket_max}" ]; then
# 		local ask3
# 		local new_ticket_max="$default_ticket_max"
# 		read -p "Ticket max settings not found for repository '$repository'. \
# 					What would be ticket max (default: '$default_ticket_max')? " ask3

# 		if [ -n "$ask3" ]; then
# 			new_ticket_max="$ask2"
# 		fi
		
# 		add_to_temp "$type" "$ticket_max" "$new_ticket_max"
# 	fi
# }