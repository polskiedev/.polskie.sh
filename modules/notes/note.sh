#!/bin/bash

notes_main() {
    local directory="$(get_note_path)"
    local formatted_directory=$(echo "$directory" | sed -e 's/[\/&]/\\&/g')
    local default_group="daily-scrum"
    local group="$default_group"
    local list=()
    if [[ ! -d "$directory" ]]; then
        echo "Directory not found: $directory"
        return 1
    fi

    # find "$directory" -maxdepth 1 -type d ! -path "$directory" | while IFS= read -r dir; do
    #     dir=$(echo "$dir" | sed -e "s/$formatted_directory\///g")
    #     list+=("$dir")
    #     # echo "Found directory: $dir"
    # done

    for dir in $(find "$directory" -maxdepth 1 -type d ! -path "$directory"); do
        dir=$(echo "$dir" | sed -e "s/$formatted_directory\///g")
        list+=("$dir")
        # echo "Found directory: $dir"
    done

    local selected_option=$(printf '%s\n' "${list[@]}" | \
        fzf \
        --prompt="Please select note group: " \
        --query="$default_group"
    )

    if [[ -n "$selected_option" ]]; then
        echo "notes_actions --group:\"$selected_option\""
        notes_actions --group:"$selected_option"
    else
        echo "No file selected."
    fi
}

notes_actions() {
    local default_group="daily-scrum"
    local group="$default_group"
    # ###############################################
    # local action="open"
    declare -A result
    declare -a remaining_parameters
    local requested_vars=("action" "group")
    local args=("$@")
    
    process_args result remaining_parameters requested_vars[@] "${args[@]}"

    # if [[ "${result["action"]}" != false ]]; then
    #     action="${result["action"]}"
    # fi
    if [[ "${result["group"]}" != false ]]; then
        group="${result["group"]}"
    fi
    # ###############################################
	declare -A options=()
	options["open"]="Create/Update"
    options["open_tomorrow"]="Create/Update (Tomorrow)"
	options["list"]="List"
	options["delete"]="Delete"

    local default_choice="Create/Update"
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
                open_note --group:"$group"
                ;;
            "open_tomorrow")
                # echo "open_tomorrow"
                open_note --group:"$group" --days:+1
                ;;
            "list")
                # echo "List"
                list_notes --action:"open" --group:"$group"
                ;;
            "delete")
                # echo "Delete"
                list_notes --action:"delete" --group:"$group"
                ;;
            *)
                echo "notes_main(): Invalid parameter action '$action'"
                return 1
                ;;
        esac
    fi
}

get_note_path() {
    local dest_path="$HOME/notes"
    echo "$dest_path"
}

get_new_note_filename() {
	local date_args=()
    date_args+=("--date")

    declare -A result
    declare -a remaining_parameters
    local requested_vars=("days" "prefix" "suffix" "label")
    local args=("$@")

    process_args result remaining_parameters requested_vars[@] "${args[@]}"
	if [[ "${result["days"]}" != false ]]; then
        date_args+=("--days:${result["days"]}")
	fi

    # Get the current date and time in the specified format
    local timestamp="$(get_datetime "${date_args[@]}")"
    local filename="${timestamp}"
    local prefix
    local suffix

    # Create the filename
	if [[ "${result["prefix"]}" != false ]]; then
        # slugify
        prefix="$(slugify "${result["prefix"]}")"
        filename="${prefix}_${filename}"
    fi

	if [[ "${result["suffix"]}" != false ]] || [[ "${result["label"]}" != false ]]; then
        # slugify
        suffix="$(slugify "${result["suffix"]}")"
        if [[ "${result["label"]}" != false ]]; then
            suffix="$(slugify "${result["label"]}")"
        fi
        filename="${filename}_${suffix}"
    fi

    echo "${filename}.txt"
}

list_notes() {
    # Todo: Bug in delete
    local search_dir="$(get_note_path)"
    local action="open"
    declare -A result
    declare -a remaining_parameters
    local requested_vars=("action" "group")
    local args=("$@")

    process_args result remaining_parameters requested_vars[@] "${args[@]}"

    case "${result["action"]}" in
		"open" | "delete")
			action="${result["action"]}"
			;;
        *)
            echo "list_notes(): Invalid parameter action '${result["action"]}'"
            return 1
            ;;
    esac

    if [[ "${result["group"]}" != false ]]; then
        group="$(slugify "${result["group"]}")"
        search_dir+="/${group}"
    fi

    if [[ ! -d "$search_dir" ]]; then
        echo "Notes folder doesn't exist yet."
        return 1
    fi

    local counter=1
    local formatted_files=()
    local list=$(find "$search_dir" -maxdepth 1 -type f -name "*.txt" | sort -r)
    local count_list=0
    local formatted_search_dir=$(printf '%s\n' "$search_dir" | sed -e 's/[\/&]/\\&/g')

    if [ -n "$list" ]; then
        count_list=$(echo "$list" | wc -l)
    fi

    if [ "$count_list" -eq 0 ]; then
        echo "Notes have no content"
        return 1
    fi

    IFS=$'\n' read -r -d '' -a files <<< "$list"

    local current_year=$(date "+%Y")
    local current_date=$(date "+%Y-%m-%d")
    local file_date_replacer="[date]"
    # Find files and print each with an index and a pipe
    for file in "${files[@]}"; do
        local formatted_file=$(printf '%s\n' "$file" | sed -e 's/[\/&]/\\&/g')
        formatted_file=$(echo "$file" | sed -e "s/$formatted_search_dir\///g")

        local extract_date=$(echo "$formatted_file" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
        local formatted_date=$(echo "$extract_date" | cut -d '.' -f1)
        local date_format="+%A, %B %-d '%y"
        local formatted_date_txt=""

        # Check if the year is the current year, don't show if current year
        if [ "$(date -d "$formatted_date" "+%Y")" -eq "$current_year" ]; then
            date_format="+%A, %B %-d"
        fi

        formatted_date_txt=$(date -d "$formatted_date" "$date_format")

        # Show today
        if [ "$formatted_date" == "$current_date" ]; then
            formatted_date_txt="$formatted_date_txt (Today)"
        fi

        local formatted_file_no_date=$(echo "$formatted_file" | sed -e "s/$extract_date/$file_date_replacer/g" -e "s/.txt//g")
        formatted_file="$counter|$formatted_date| $formatted_date_txt"

        if [ "$formatted_file_no_date" != "$file_date_replacer" ]; then
            formatted_file+=" |$formatted_file_no_date"
        fi

        formatted_files+=("$formatted_file")

        ((counter++))
    done

    local preview='echo {}'
    preview='echo "--- Preview ---"; '
    preview+='file_date=$(echo "{}" | tr -d "###" | cut -d "|" -f2); '
    preview+='file_format=$(echo "{}" | tr -d "###" | cut -d "|" -f4); '

    preview+='search_dir="'
    preview+=$search_dir
    preview+='"; '

    preview+='file_preview=$(echo "$file_format" | sed -e "s/'
    preview+=$(echo "$file_date_replacer" | sed -e 's/\[/\\[/g' -e 's/\]/\\]/g')
    preview+='/$file_date/g"); '

    preview+='file_preview=$(if [ "$file_preview" = "" ]; then echo "$file_date"; else echo "$file_preview"; fi); '
    # preview+='echo "file_date: $file_date"; '
    # preview+='echo "file_format: $file_format"; '
    # preview+='echo "file_preview: $file_preview"; '
    preview+='cat "$search_dir/${file_preview}.txt" | head -n 10'
    # echo $preview
    preview=$(echo "$preview" | sed -e "s/\$search_dir/$formatted_search_dir/g")
    preview=$(echo "$preview" | sed -e "s/###/'/g")

    case "${result["action"]}" in
		"open")
			local prompt="Open note file: "
            selected_options=$(printf '%s\n' "${formatted_files[@]}" | \
                fzf \
                --prompt="$prompt" \
                --preview="$preview" \
                --preview-window='right:50%:wrap'\
            )
			;;
        "delete")
			local prompt="Choose a note to delete: "
            selected_options=$(printf '%s\n' "${formatted_files[@]}" | \
                fzf \
                --prompt="$prompt" \
                --preview="$preview" \
                --preview-window='right:50%:wrap'\
                --multi \
            )
			;;
    esac

    # Check if a file was selected
    if [[ -n "$selected_options" ]]; then
        case "${result["action"]}" in
            "open")
                local filename
                local selected_date="$(echo "$selected_options" | cut -d "|" -f2)"
                local selected_file_format=$(echo "$selected_options" | cut -d "|" -f4 );
                local formatted_file_date_replacer=$(echo "$file_date_replacer" | sed -e 's/\[/\\[/g' -e 's/\]/\\]/g')

                filename=$(echo "$selected_file_format" | sed -e "s/$formatted_file_date_replacer/$selected_date/g");

                if [ "$filename" = "" ]; then 
                    filename="$selected_date"
                fi

                filename="${filename}.txt"

                if [[ "${result["group"]}" != false ]]; then
                    open_note --filename:"$filename" --group:"${result["group"]}"
                else
                    open_note --filename:"$filename"
                fi
                ;;
            "delete")
                # Todo: Ask for confirmation before deleting
                local option_count=$(echo "$selected_options" | wc -l)
                local answer
                echo "--- $option_count files for deletion ---"
                # echo "$selected_options" | \
                #     awk -F'|' -v search_dir="$search_dir" '{print search_dir "/" $2 ".txt"}' | \
                #     nl -w2 -s'. '
                declare -a for_deletion=()
                local counter_delete=0
                while IFS= read -r option; do
                    ((counter_delete++))
                    local filename
                    local selected_date="$(echo "$option" | cut -d "|" -f2)"
                    local selected_file_format=$(echo "$option" | cut -d "|" -f4 );
                    local formatted_file_date_replacer=$(echo "$file_date_replacer" | sed -e 's/\[/\\[/g' -e 's/\]/\\]/g')

                    filename=$(echo "$selected_file_format" | sed -e "s/$formatted_file_date_replacer/$selected_date/g");

                    if [ "$filename" = "" ]; then 
                        filename="$selected_date"
                    fi

                    filename="$search_dir/${filename}.txt"
                    for_deletion+=("$filename")
                    echo "$counter_delete. $filename"
                done <<< "$selected_options"

                read -p "Are you sure you want to delete files above? [y/N] " answer
                case "$answer" in
                    [yY])
                        # Loop through each element in the array
                        for item in "${for_deletion[@]}"; do
                            echo "Deleting '$item'..."
                            rm "$item"
                        done
                        ;;
                    *)
                        echo "Note deletion canceled."
                        ;;
                esac
            ;;
        esac
    else
        echo "No file selected."
    fi
}

open_note() {
    local dest_path="$(get_note_path)"
    local filename="$(get_new_note_filename "$@")"
    local action="edit"

    declare -A result
    declare -a remaining_parameters
    local requested_vars=("showdata" "filename" "group" "action")
    local args=("$@")

    process_args result remaining_parameters requested_vars[@] "${args[@]}"

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
    if [[ "${result["filename"]}" != false ]]; then
        filename="${result["filename"]}"
    fi

    # Ensure the destination path exists
    create_directories "$dest_path"

    local file_path="$dest_path"
    if [[ "${result["group"]}" != false ]]; then
        group="$(slugify "${result["group"]}")"
        file_path+="/${group}"
        create_directories "$file_path"
    fi

    file_path+="/${filename}"
    #Remove validation, not necessary
    # if [ -f "$file_path" ]; then
    #     echo "Note already exists. Skip note creation."
    #     return 1
    # fi

    # Create the file
    touch "$file_path"

    # Confirm the file has been created
    if [ $? -eq 0 ]; then
        echo "Note created: $file_path"
    else
        echo "Failed to create note"
    fi

    if [[ "${result["action"]}" != false ]]; then
        action="${result["action"]}"
    fi

    case "$action" in
    "edit")
        # Change below based on prefered editor
        psh_text_editor "$file_path"
        ;;
    esac
}
