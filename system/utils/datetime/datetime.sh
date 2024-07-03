#!/bin/bash

get_datetime() {
	local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
	# local current_datetime=$(date +"%Y%m%d_%I%M%p" | sed 's/AM/am/' | sed 's/PM/pm/')
	if [[ -n "$1" ]]; then
		case "$1" in
			"--human")
				timestamp=$(date +"%Y-%m-%d_%I%M%p")
				;;
			"--date")
				timestamp=$(date +"%Y-%m-%d")
				;;
			*)
				echo "Invalid parameter for get_datetime()"
				return 1
				;;
		esac
	fi

	echo "$timestamp"
}