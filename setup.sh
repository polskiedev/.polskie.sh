#!/bin/bash

# Define the help function
help() {
    echo "Usage: ./setup.sh [command]"
    echo
    echo "Commands:"
    echo "  first-run      Run after download"
    echo "  init           Run the initialize function"
    echo "  update         Run the update function"
    echo "  help           Display this help message"
    echo "  make:links     Make symlinks for packages"
    echo "  make:file      Generate source files for the package"
    echo
    echo "If no command is provided, 'help' will be run by default."
}

# Define the initialize function
initialize() {
    echo "Running initialize function..."
}

# Define the update function
update() {
    echo "Running update function..."
}

make_symlinks() {
    echo "Creating symlinks..."
}

# Define the function to check and create a symlink
__create_symlink() {
    local from="$1"
    local to="$2"

    if [ -e "$from" ]; then
        if [ -L "$from" ]; then
            echo "$from is already a symlink."
        else
            echo "Error: $from already exists as a directory."
        fi
    else
        echo "$from is not a symlink. Creating a symlink..."
        ln -s "$from" "$to"
        echo "Symlink created from source '$from' to '$to'."
    fi
}

source .env/vars.sh

makefile() {
    echo "Running makefile function..."
    ./makefile.sh --init
}

first_run() {
    initialize
    makefile
    make_symlinks
}

deploy() {
    echo "Run: deploy()"
    initialize
    makefile
    make_symlinks
    source "$PATH_POLSKIE_SH/.output/sources.sh"
    source "$PATH_POLSKIE_SH/.output/sources.alias.sh"
}

test() {
    echo "Run: test()"
    deploy
    list=("system" "modules")
    
    # Define the find command and filter based on the presence of $1
    if [ -z "$1" ]; then
        filter=(-name "*.test.sh")
    else
        filter=(-name "*$1*" -name "*.test.sh")
    fi

    # Iterate over the list of items and process test files
    for item in "${list[@]}"; do
        find "$item" -type f "${filter[@]}" | sort | while read -r file; do
            # chmod +x "$item"
            echo "Processing test file: $file"
            source "$file"
        done
    done
}

docker_console() {
    docker run --rm -it "devenv-test" bash
}

docker_start() {
    ./.shared/docker/start.docker.sh
}

# Check the parameter and call the corresponding function
if [ -z "$1" ]; then
    # No parameter passed, default to help
    help
    hero
else
    # Parameter passed, execute the corresponding function
    case "$1" in
		"help")
			help
			;;
        "init")
            initialize
            ;;
        "update")
            update
            ;;
        "make:file")
            makefile
            ;;
        "make:links")
            make_symlinks
            ;;
        "first-run")
            first_run
            ;;
        "deploy")
            deploy
            ;;
        "test")
            shift
            test "$@"
            ;;
        "docker:start" | "d:s")
            docker_start
            ;;
        "docker:console" | "d:c")
            docker_start
            docker_console
            ;;
        *)
            echo "Invalid parameter. Usage: ./setup.sh ["first-run"|init|update|"make:links"|"make:file"]"
            exit 1
            ;;
    esac
fi
