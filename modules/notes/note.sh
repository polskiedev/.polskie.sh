#!/bin/bash

get_note_path() {
    local dest_path="$HOME/notes"
    echo "$dest_path"
}

get_new_note_filename() {
	local date_args=()
    date_args+=("--date")

    declare -A result
    declare -a remaining_parameters
    local requested_vars=("days" "prefix")
    local args=("$@")

    process_args result remaining_parameters requested_vars[@] "${args[@]}"
	if [[ "${result["days"]}" != false ]]; then
        date_args+=("--days:${result["days"]}")
	fi

    # Get the current date and time in the specified format
    local timestamp="$(get_datetime "${date_args[@]}")"
    local filename
    local prefix

    # Create the filename
	if [[ "${result["prefix"]}" != false ]]; then
        # slugify
        prefix="$(slugify "${result["prefix"]}")"
        filename="${prefix}_${timestamp}.txt"
    else
        filename="${timestamp}.txt"
    fi

    echo "$filename"
}

list_notes() {
    # Todo: Not correctly opening selected file
    local search_dir="$(get_note_path)"
    local action="open"
    declare -A result
    declare -a remaining_parameters
    local requested_vars=("action")
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

    if [[ ! -d "$search_dir" ]]; then
        echo "Notes folder doesn't exist yet."
        return 1
    fi

    local counter=1
    local formatted_files=()
    local list=$(find "$search_dir" -type f -name "*.txt" | sort -r)
    local formatted_search_dir=$(printf '%s\n' "$search_dir" | sed -e 's/[\/&]/\\&/g')

    IFS=$'\n' read -r -d '' -a files <<< "$list"

    local current_year=$(date "+%Y")
    local current_date=$(date "+%Y-%m-%d")
    # Find files and print each with an index and a pipe
    for file in "${files[@]}"; do
        local formatted_file=$(printf '%s\n' "$file" | sed -e 's/[\/&]/\\&/g')
        formatted_file=$(echo "$file" | sed -e "s/$formatted_search_dir\///g")

        local formatted_date=$(echo "$formatted_file" | cut -d '.' -f1)
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

        formatted_file="$counter|$formatted_date| $formatted_date_txt"
        formatted_files+=("$formatted_file")

        ((counter++))
    done

    local preview='echo "--- Preview ---"; \
                    file=$(echo "{}" | \
                        tr -d "###" | \
                        cut -d "|" -f2\
                    ); \
                    cat "$search_dir/${file}.txt" | \
                    head -n 10'

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
                local filename="$(echo "$selected_options" | cut -d "|" -f2).txt"

                open_note --filename:"$filename"
                ;;
            "delete")
                # Todo: Ask for confirmation before deleting
                local option_count=$(echo "$selected_options" | wc -l)
                local answer
                echo "--- $option_count files for deletion ---"
                echo "$selected_options" | \
                    awk -F'|' -v search_dir="$search_dir" '{print search_dir "/" $2 ".txt"}' | \
                    nl -w2 -s'. '
                read -p "Are you sure you want to delete files above? [y/N] " answer
                case "$answer" in
                    [yY])
                        while IFS= read -r option; do
                            filename="$(echo "$option" | cut -d"|" -f2).txt"
                            echo "Deleting '$search_dir/$filename'..."
                            rm "$search_dir/$filename"
                        done <<< "$selected_options"
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

    declare -A result
    declare -a remaining_parameters
    local requested_vars=("filename")
    local args=("$@")

    process_args result remaining_parameters requested_vars[@] "${args[@]}"

    if [[ "${result["filename"]}" != false ]]; then
        filename="${result["filename"]}"
    fi

    # echo "$filename"
    # return
    create_note "$filename"

    # Change below based on prefered editor
    psh_text_editor "$dest_path/$filename"
}

create_note() {
    local dest_path="$(get_note_path)"
    local filename="$(get_new_note_filename "$@")"

    declare -A result
    declare -a remaining_parameters
    local requested_vars=("filename")
    local args=("$@")

    process_args result remaining_parameters requested_vars[@] "${args[@]}"

    if [[ "${result["filename"]}" != false ]]; then
        filename="${result["filename"]}"
    fi

    if [ -f "$dest_path/$filename" ]; then
        echo "Note already exists. Skip note creation."
        return 1
    fi

    # Ensure the destination path exists
    mkdir -p "$dest_path"

    # Create the file
    touch "$dest_path/$filename"

    # Confirm the file has been created
    if [ $? -eq 0 ]; then
        echo "Note created: $dest_path/$filename"
    else
        echo "Failed to create note"
    fi
}

