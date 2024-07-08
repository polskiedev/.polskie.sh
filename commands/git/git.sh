#!/bin/bash

pathinfo_override_command_git() {
    declare -A pathinfo

    pathinfo["settings_dir"]="$ENV_TMP_DIR/$ENV_TMP_SETTINGS"
    pathinfo["default_file"]="default"
	pathinfo["format_ticket"]=".format_ticket"
	pathinfo["ticket_prefix"]=".ticket_prefix"
	pathinfo["ticket_max"]=".ticket_max"
	
	local repo_name=$(get_git_repo_name)

	local default_file="${pathinfo['default_file']}"
	local settings_dir="${pathinfo['settings_dir']}"

	local ticket_prefix="${pathinfo['ticket_prefix']}"
	local format_ticket="${pathinfo['format_ticket']}"
	local ticket_max="${pathinfo['ticket_max']}"

	local default_file_format_ticket="${default_file}${format_ticket}.txt"
	local default_file_ticket_prefix="${default_file}${ticket_prefix}.txt"
	local default_file_ticket_max="${default_file}${ticket_max}.txt"

	local file_format_ticket="${repo_name}${format_ticket}.txt"
	local file_ticket_prefix="${repo_name}${ticket_prefix}.txt"
	local file_ticket_max="${repo_name}${ticket_max}.txt"

	local ticket_format=""
	local ticket_prefix_txt=""
	local ticket_max_num=0

	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
	# This block is using the old txt file method of saving settings @Start
	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
	if [ -f "${settings_dir}/${file_format_ticket}" ]; then
		ticket_format=$(head -n 1 "${settings_dir}/${file_format_ticket}")
	elif [ -f "${settings_dir}/${default_file_format_ticket}" ]; then
		ticket_format=$(head -n 1 "${settings_dir}/${default_file_format_ticket}")
	fi

	if [ -f "${settings_dir}/${file_ticket_prefix}" ]; then
		ticket_prefix_txt=$(head -n 1 "${settings_dir}/${file_ticket_prefix}")
	elif [ -f "${settings_dir}/${default_file_ticket_prefix}" ]; then
		ticket_prefix_txt=$(head -n 1 "${settings_dir}/${default_file_ticket_prefix}")
	fi

	if [ -f "${settings_dir}/${file_ticket_max}" ]; then
		ticket_max_num=$(head -n 1 "${settings_dir}/${file_ticket_max}")
	elif [ -f "${settings_dir}/${default_file_ticket_max}" ]; then
		ticket_max_num=$(head -n 1 "${settings_dir}/${default_file_ticket_max}")
	fi
	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
	# This block is using the old txt file method of saving settings @End
	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

	pathinfo["ticket_format"]="$ticket_format"
	pathinfo["ticket_prefix_txt"]="$ticket_prefix_txt"
	pathinfo["ticket_max_num"]=$ticket_max_num
	pathinfo["repository"]=$repo_name

	pathinfo["default_file_format_ticket"]=$default_file_format_ticket
	pathinfo["default_file_ticket_prefix"]=$default_file_ticket_prefix
	pathinfo["default_file_ticket_max"]=$default_file_ticket_max

	pathinfo["file_format_ticket"]=$file_format_ticket
	pathinfo["file_ticket_prefix"]=$file_ticket_prefix
	pathinfo["file_ticket_max"]=$file_ticket_max

	pathinfo["default_ticket_format"]="[[:alnum:]]{3,}-[0-9]{6}"
	pathinfo["default_ticket_prefix"]="DEV"
	pathinfo["default_ticket_max"]="6"

    # Return associative array
    echo "$(declare -p pathinfo)"
}

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

override_command_git() {
	echo "override_command_git()"
}

status_override_command_git() {
	log_info "status_override_command_git()"
	local repo_name=""
	local branch_name=""

    if ! repo_name=$(get_git_repo_name); then
        log_error "Current directory is not in any git repository."
		return 1
    else
        log_info "Repository: '$repo_name'"
    fi

	branch_name="$(git branch --show-current)"

	log_info "Branch: '$branch_name'"
	git status
}

add_override_command_git() {
	echo "status_override_command_git()"

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

	local repo_name=""
	local branch_name=""

    if ! repo_name=$(get_git_repo_name); then
        echo "Current directory is not in any git repository."
		return 1
    else
        echo "Repository: '$repo_name'"
    fi

	branch_name="$(git branch --show-current)"
	echo "Branch Name: '$branch_name'"

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
		git add .
	else
		local counter=1
		# Sort by status, then by path_name
		local git_status=$(git status --porcelain | sort -k1,1 -k2 -r)
		local formatted_files=()
		# Process each line of git status output
		while IFS= read -r line; do
			# Extract status and file path
			local status="${line:0:2}"
			local file="${line:3}"

			# Print status and file in the required format
			formatted_file="$counter|${status}| ${file}"
			formatted_files+=("$formatted_file")
			((counter++))
		done <<< "$git_status"

		local preview='file="$(echo "{}" | \
							tr -d "###" | \
							cut -d"|" -f3 | \
							sed -e "s/^[[:space:]]*//" -e "s/[[:space:]]*$//")"; \
						echo "File: $file"; \
						echo "================================="; \
						cat "$file"'
		preview=$(echo "$preview" | sed -e "s/###/'/g")

		local header=("Repository: '$repo_name'" \
			"Branch: '$branch_name'" \
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
		local option_count=$(echo "$selected_options" | wc -l)

		while IFS= read -r option; do
			local filename="$(echo "$option" | cut -d"|" -f3)"
			filename="$(trim "$filename")"

			if [ -n "$filename" ]; then
				echo "Added '$filename' to git"
				git add "$filename"
				((git_added++))
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
		commit_override_command_git	"$commit_msg"
	fi
}

commit_override_command_git() {
	echo "commit_override_command_git()"

	eval "$(pathinfo_override_command_git)"

	local repo_name=""
	local current_branch=""
	local all_params="$*"
	local msg="$(echo "$all_params")"

    if ! repo_name=$(get_git_repo_name); then
        echo "Current directory is not in any git repository."
		return 1
    else
        echo "Repository: '$repo_name'"
    fi

	current_branch=$(git branch --show-current)
	echo "Current Branch: '$current_branch'"
	# branch_name="$(git branch --show-current)"

	local default_file="${pathinfo['default_file']}"
	local settings_dir="${pathinfo['settings_dir']}"

	local ticket_prefix="${pathinfo['ticket_prefix']}"
	local format_ticket="${pathinfo['format_ticket']}"
	local ticket_max="${pathinfo['ticket_max']}"

	local ticket_format="${pathinfo['ticket_format']}"
	local ticket_prefix_txt="${pathinfo['ticket_prefix_txt']}"
	local ticket_max_num="${pathinfo['ticket_max_num']}"

	cleanup_override_command_git

	local new_ticket_no=""
	local has_ticket_no=false

	local current_ticket_no=$(echo "$current_branch" | \
		awk -F'/' '{print $NF}' | \
		grep -oE "$ticket_format")

    if [ -n "$current_ticket_no" ]; then
        # msg="$current_ticket_no: $(capitalize_first_letter "$all_params")"
		echo "Ticket No: $current_ticket_no"
		has_ticket_no=true
	else
		local pad_length=$((ticket_max_num - 1))
		local default_ticket_no=1
		new_ticket_no="${ticket_prefix_txt}-$(str_pad "" $pad_length "0")${default_ticket_no}"
	fi

	if [[ "$has_ticket_no" = false ]]; then
		while true; do
			local answer
			local formatted_answer
			read -p "Enter ticker number (default: $new_ticket_no): " answer

			formatted_answer=$(echo "$answer" | \
				awk -F'/' '{print $NF}' | \
				grep -oE "$ticket_format")
				
			if [ -z "$answer" ]; then
				current_ticket_no="$new_ticket_no"
				break
			elif [ -n "$formatted_answer" ]; then
				current_ticket_no="$formatted_answer"
				break
			else
				echo "'$answer' doesn't match with the required ticket pattern."
			fi
		done
	fi

	while true; do
		local commit_now
		msg="${current_ticket_no}: $(ucfirst "$msg")"
		read -p "Are you okay with this commit message \"$msg\"? (y/n) " commit_now

        case "$commit_now" in
            [Yy]|[Yy][Ee][Ss])
                echo "git commit -m \"$msg\""
                git commit -m "$msg"
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
				git push origin HEAD 
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

add_default_setting_override_command_git() {
	echo "add_default_setting_override_command_git()"
	eval "$(pathinfo_override_command_git)"

	local type="settings"
	local settings_dir="${pathinfo['settings_dir']}"

	local format_ticket="${pathinfo['default_file_format_ticket']}"
	local ticket_prefix="${pathinfo['default_file_ticket_prefix']}"
	local ticket_max="${pathinfo['default_file_ticket_max']}"

	cleanup_override_command_git

	add_to_temp "$type" "$format_ticket" "[[:alnum:]]{3,}-[0-9]{6}"
	add_to_temp "$type" "$ticket_prefix" "DEV"
	add_to_temp "$type" "$ticket_max" "6"
}

add_custom_setting_override_command_git() {
	# Todo: Fix variable naming
	# ! To deprecate, causing to many files
	echo "add_custom_setting_override_command_git()"
	eval "$(pathinfo_override_command_git)"

	local type="settings"
	local settings_dir="${pathinfo['settings_dir']}"

	local format_ticket="${pathinfo['file_format_ticket']}"
	local ticket_prefix="${pathinfo['file_ticket_prefix']}"
	local ticket_max="${pathinfo['file_ticket_max']}"

	local default_ticket_format="${pathinfo['default_ticket_format']}"
	local default_ticket_prefix="${pathinfo['default_ticket_prefix']}"
	local default_ticket_max="${pathinfo['default_ticket_max']}"
	local repository="${pathinfo['repository']}"
	
	cleanup_override_command_git

	if [ ! -f "${settings_dir}/${format_ticket}" ]; then
		local ask1
		local new_format_ticket="$default_ticket_format"
		read -p "Format ticket settings not found for repository '$repository'. \
					Creating file. What would be the format (default: '$default_ticket_format')? " ask1

		if [ -n "$ask1" ]; then
			new_format_ticket="$ask1"
		fi

		add_to_temp "$type" "$format_ticket" "$new_format_ticket"
	fi

	if [ ! -f "${settings_dir}/${ticket_prefix}" ]; then
		local ask2
		local new_ticket_prefix="$default_ticket_prefix"
		read -p "Ticket prefix settings not found for repository '$repository'. \
					What would be the ticket prefix (default: '$default_ticket_prefix')? " ask2

		if [ -n "$ask2" ]; then
			new_ticket_prefix="$ask2"
		fi
		
		add_to_temp "$type" "$ticket_prefix" "$new_ticket_prefix"
	fi

	if [ ! -f "${settings_dir}/${ticket_max}" ]; then
		local ask3
		local new_ticket_max="$default_ticket_max"
		read -p "Ticket max settings not found for repository '$repository'. \
					What would be ticket max (default: '$default_ticket_max')? " ask3

		if [ -n "$ask3" ]; then
			new_ticket_max="$ask2"
		fi
		
		add_to_temp "$type" "$ticket_max" "$new_ticket_max"
	fi
}