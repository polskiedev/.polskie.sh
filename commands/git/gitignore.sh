#!/bin/bash

add_gitignore() {
	local dir_path="$1"
    if [ -n "$dir_path" ]; then
		if [[ -d "$dir_path" ]]; then
        	cp "$PATH_DOTFILES/git/.gitignore" "$dir_path"
		fi
	else
		cp "$PATH_DOTFILES/git/.gitignore" "$PWD"
    fi
}