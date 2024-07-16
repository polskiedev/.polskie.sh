#!/bin/bash

pathinfo_worker_tasks() {
    declare -A pathinfo
	pathinfo["caller"]="worker_tasks"
    pathinfo["working_directory"]="$ENV_TMP_DIR/$ENV_TMP_WORKER_TASKS"
	pathinfo["temp_file"]="temp.json"
    # Return associative array
    echo "$(declare -p pathinfo)"
}

cleanup_worker_tasks() {
    # Unset the array, to prevent leakage
    unset pathinfo
}

worker_tasks_main() {
	echo "worker_tasks_main()"
	worker_tasks_actions
}

worker_tasks_actions() {
    # ###############################################
    # local action="open"
    declare -A result
    declare -a remaining_parameters
    local requested_vars=("action")
    local args=("$@")
    
    process_args result remaining_parameters requested_vars[@] "${args[@]}"

    # ###############################################
	declare -A options=()
	options["open"]="Create"
	options["list"]="List"
	options["test"]="Test"

    local default_choice="Create"
    default_choice=""

	# Transform the associative array into the desired format
	formatted_options=()
	for key in "${!options[@]}"; do
		formatted_options+=("${key}:${options[$key]}")
	done

    selected_option=$(printf "%s\n" "${formatted_options[@]}" | fzf --query="$default_choice" --delimiter=":" --with-nth=2)
	# Handle the selected option
	if [[ -n "$selected_option" ]]; then
        local predefined_output=$(echo "$selected_option" | cut -d: -f1)
        case "$predefined_output" in
            "open")
                # echo "Open"
                add_worker_task
                ;;
            "list")
                # echo "List"
                list_worker_tasks
                ;;
			"test")
				echo "test"
				;;
            *)
                echo "worker_tasks_actions(): Invalid parameter action '$action'"
                return 1
                ;;
        esac
    fi
}

add_worker_task() {
	echo "add_worker_task()"
	eval "$(pathinfo_worker_tasks)"

	local working_directory="${pathinfo['working_directory']}"
	local config_file="$working_directory/test.json"
	local temp_file="$working_directory/${pathinfo['temp_file']}"

	create_directories "$working_directory"
	cleanup_worker_tasks
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
	declare -A settings_json=()
	settings_json["name"]="Sample Worker Task"
	settings_json["Description"]="Worker Task Description"
	settings_json["current"]="25"
	settings_json["total"]="100"
	settings_json["status"]="on-going"
	settings_json["pid"]="1234"
	make_json_file settings_json --file:"$config_file" --tmpfile:"$temp_file"
}

list_worker_tasks() {
	echo "worker_task_list()"
	eval "$(pathinfo_worker_tasks)"

	local working_directory="${pathinfo['working_directory']}"
	local config_file="$working_directory/test.json"
	local temp_file="$working_directory/${pathinfo['temp_file']}"

	create_directories "$working_directory"
	cleanup_worker_tasks
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
	local default_choice=""
	local search_dir="$working_directory"
    local formatted_search_dir=$(printf '%s\n' "$search_dir" | sed -e 's/[\/&]/\\&/g')
	local formatted_files=()
    local list=$(find "$search_dir" -maxdepth 1 -type f -name "*.json" | sort -r)
    local count_list=0

    if [ -n "$list" ]; then
        count_list=$(echo "$list" | wc -l)
    fi

    if [ "$count_list" -eq 0 ]; then
        echo "Worker Task is empty"
        return 1
    fi

	IFS=$'\n' read -r -d '' -a files <<< "$list"

	local counter=0
    # Find files and print each with an index and a pipe
    for file in "${files[@]}"; do
        local formatted_file=$(printf '%s\n' "$file" | sed -e 's/[\/&]/\\&/g')
		formatted_file=$(echo "$file" | sed -e "s/$formatted_search_dir\///g")
		((counter++))

		declare -A json_file_data
		get_json_data json_file_data --file:"$file"

		local task_name="${json_file_data["name"]}"

		formatted_files+=("$formatted_file:$task_name")
	done

	local prompt="Select a Worker Task: "
	local preview='echo {}'
	selected_option=$(printf '%s\n' "${formatted_files[@]}" | \
		fzf \
		--prompt="$prompt" \
		--preview="$preview" \
		--query="$default_choice" \
		--delimiter=":" \
		--with-nth=2 \
		--preview-window='right:50%:wrap'\
	)

    # Check if a file was selected
    if [[ -n "$selected_option" ]]; then
		local predefined_output=$(echo "$selected_option" | cut -d: -f1)
		local selected_file="$working_directory/$predefined_output"
		# echo "$predefined_output"

		declare -A json_file_data2
		get_json_data json_file_data2 --file:"$selected_file"

		local min="${json_file_data["current"]}"
		local max="${json_file_data["total"]}"

		# echo "Min: $min, Max: $max"
		for i in $(seq $min $max); do
			progressbar "$i" "$max"
			sleep 0.1
		done
		echo ""
    else
        echo "No file selected."
    fi
}