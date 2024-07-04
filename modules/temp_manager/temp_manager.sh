#!/bin/bash

add_to_temp() {
	local dest_path="$ENV_TMP_DIR"
	local filename="list.txt"
	local filepath=""
	local type=""

    if [ -z "$1" ]; then
		echo "Please input temp type"
        return 1
	fi

    if [ -z "$2" ]; then
		echo "Please input list filename"
        return 1
	fi

    if [ -z "$3" ]; then
		echo "Please input string content"
        return 1
	fi

    case "$type" in
		"list")
			dest_path="$ENV_TMP_DIR/$ENV_TMP_LIST"
			;;
        *)
            echo "add_to_temp(): Invalid parameter."
             return 1
            ;;
	esac

	filename="$2"
	text="$3"

	filepath="$dest_path/$filename"

	create_directories "$dest_path"

	if [[ ! -f "$filepath" ]]; then
		echo -n > "$filepath"
	fi
	
	file_save_text "$filepath" "$text"
}