#!/bin/bash

source "$HOME/.devenv/packages/.polskie.sh/.env/vars.sh"
source "$HOME/.devenv/common/sources.sh" #temp
# source $(realpath "$HOME/.devenv.sources.sh")

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

makefile() {
    echo "Running makefile function..."
    bash "$PATH_POLSKIE_SH/makefile.sh" --init
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
    source $(realpath "$HOME/.devenv.sources.sh")
}

run_tests() {
    echo "Run: run_tests()"
    deploy
    compile_test_files
    bash "$PATH_POLSKIE_SH/.output/package.tests.sh"
    # source $(realpath "$HOME/.devenv.sources.sh")
}

compile_test_files() {
    list=("system" "modules" "common")

    # Define the find command and filter based on the presence of $1
    if [ -z "$1" ]; then
        filter=(-name "*.test.sh")
    else
        filter=(-name "*$1*" -name "*.test.sh")
    fi

    local output_file_name="package.tests.sh"
    local output_dir="$PATH_POLSKIE_SH/.output"
    local output_file="$output_dir/$output_file_name"

    > "$output_file"  # Clear the file first
    echo "#!/bin/bash" >> "$output_file"
    echo "" >> "$output_file"
    echo "echo \"Loaded: $output_file_name\"" >> "$output_file"
    echo "" >> "$output_file"

    # Iterate over the list of items and process test files
    for item in "${list[@]}"; do

        if [ "$item" = "common" ]; then
            item="$(realpath "$PATH_POLSKIE_SH/.shared/.devenv/common")"
        fi

        find "$item" -type f "${filter[@]}" | sort | while read -r file; do
            # chmod +x "$item"
            echo "Processing test file: $file"
            # bash "$file"
            echo "source \"$file\" || echo \"Failed to source '$file'\"" >> "$output_file"
        done
    done
}

docker_console() {
    docker run --rm -it "devenv-test" bash
}

docker_start() {
    ./.shared/.devenv/docker/start.docker.sh
}

test() {
    echo "Run: test()"
    run_tests "$@"
    # run_tests --title="title test" --content="content text" --header:"header:in:colon" -a -r -g -s
}

# Check the parameter and call the corresponding function
if [ -z "$1" ]; then
    # No parameter passed, default to help
    help
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
