#!/bin/bash

open_fzf_nvim() {
	file=$(fzf --preview 'cat -n {}' --preview-window=right:60%:wrap) && nvim "$file"
}