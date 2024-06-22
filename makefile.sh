#!/bin/bash

# Function to check directories and process files
__polskiesh_makefile() {
    local module_name="$1"
    local dir="$PATH_POLSKIE_SH/$module_name"
    local output_dir="$PATH_POLSKIE_SH/.output"
    local output_file="$output_dir/${module_name}.sources.sh"
    local output_alias_file="$output_dir/alias.${module_name}.sources.sh"
    local ignore_file=".ignore"

    # Check if the first parameter is a directory
    if [[ ! -d "$dir" ]]; then
        echo "Error: $dir is not a directory"
        return 1
    fi

    # Ensure the output directory exists
    if [[ ! -d "$(realpath "$output_dir")" ]]; then
        mkdir -p "$output_dir"
        echo "Create: $output_dir directory"
    fi
    
    # Initialize an array to store ignore patterns
    local ignore_patterns=()

    # If .ignore file exists in the directory, read ignore patterns
    if [[ -s "$dir/$ignore_file" ]]; then
        while IFS= read -r pattern; do
            ignore_patterns+=("$pattern")
        done < "$dir/$ignore_file"
    fi

    # Function to check if a file or directory is ignored
    is_ignored() {
        local path="$1"
        for pattern in "${ignore_patterns[@]}"; do
            if [[ "$path" == "$pattern" ]]; then
                return 0
            fi
        done
        return 1
    }

    add_sub_dir_ignore_defaults() {
        local sub_dir="$1"
        local ignores=("_install.sh" "_setup.sh" "tests" "man")
        for ((i = 0; i < ${#ignores[@]}; i++)); do
            local ignore="${ignores[i]}"
            ignore_patterns+=("$sub_dir/$ignore")
            echo "Adding ignore defaults "$sub_dir/$ignore"..."
        done
    }

    # Write the .sh files to the output file
    > "$output_file"  # Clear the file first
    echo "#!/bin/bash" >> "$output_file"
    echo "" >> "$output_file"

    > "$output_alias_file"  # Clear the file first
    echo "#!/bin/bash" >> "$output_alias_file"
    echo "" >> "$output_alias_file"

    # Loop over each subfolder
    find "$dir" -type d | sort | while IFS= read -r sub_dir; do
        # Skip ignored subfolders
        if is_ignored "${sub_dir#$dir/}"; then
            echo "Ignoring folder ${sub_dir#$dir/}..."
            continue
        fi

        add_sub_dir_ignore_defaults "${sub_dir#$dir/}"
   
        # Check if .ignore file exists in the subfolder
        if [[ -f "$sub_dir/$ignore_file" ]]; then
            # If it exists, read additional ignore patterns
            while IFS= read -r pattern; do
                ignore_patterns+=("${sub_dir#$dir/}/$pattern")
                echo "Adding to ignoring file ${sub_dir#$dir/}/$pattern"
            done < "$sub_dir/$ignore_file"
            echo "Directory '$sub_dir' has ignore file"
        fi

        # Find .sh files in the subfolder, except .test.sh files and alias.sh files
        find "$sub_dir" -maxdepth 1 -type f -name "*.sh" | grep -v "\.test\.sh$" | grep -v "alias\.sh$" | sort | while IFS= read -r sh_file; do
            # Skip ignored files
            if is_ignored "${sh_file#$dir/}"; then
                echo "Ignoring file ${sh_file#$dir/}..."
                continue
            fi
            echo "source \"$(realpath "$sh_file")\"" >> "$output_file"
        done
        
        # Find alias.sh files to process last
        find "$sub_dir" -maxdepth 1 -type f -name "alias.sh" | sort | while IFS= read -r sh_file; do
            # Skip ignored files
            if is_ignored "${sh_file#$dir/}"; then
                echo "Ignoring file ${sh_file#$dir/}..."
                continue
            fi
            echo "source \"$(realpath "$sh_file")\"" >> "$output_alias_file"
        done
    done
}

# Check if the --run option is provided
if [ "$1" = "--run" ]; then
    shift
    if [ -n "$1" ]; then
        module_name="$1"

        echo "Makefile: $module_name"
        __polskiesh_makefile "$module_name"
    fi
elif [ "$1" = "--init" ]; then
	list=("system" "modules")
    output_dir="$PATH_POLSKIE_SH/.output"
    output_file="$output_dir/sources.sh"
    output_alias_file="$output_dir/sources.alias.sh"
    output_packages_file="$output_dir/sources.packages.sh"

    > "$output_packages_file"  # Clear the file first
    echo "#!/bin/bash" >> "$output_packages_file"
    echo "" >> "$output_packages_file"
    echo "echo \"Loaded: .polskie.sh/sources.packages.sh\"" >> "$output_packages_file"
    # echo "if [ -z \"\$IS_SOURCED_POLSKIESH\" ]; then" >> "$output_packages_file"
    # echo "  IS_SOURCED_POLSKIESH=true" >> "$output_packages_file"
    # echo "  echo \"Loaded: .polskie.sh/sources.packages.sh\"" >> "$output_packages_file"
    # echo "else" >> "$output_packages_file"
    # echo "  echo \"Script '.polskie.sh/sources.packages.sh' already sourced.\"" >> "$output_packages_file"
    # echo "  return 1" >> "$output_packages_file"
    # echo "fi" >> "$output_packages_file"
    echo "" >> "$output_packages_file"

	# Loop through each element in the array
	for item in "${list[@]}"; do
        echo "Makefile: $item"
        __polskiesh_makefile "$item"
        echo "source \"$(realpath "$output_dir/${item}.sources.sh")\"" >> "$output_packages_file"
	done

    > "$output_alias_file"
    echo "#!/bin/bash" >> "$output_alias_file"
    echo "" >> "$output_alias_file"
    echo "echo \"Loaded: .polskie.sh/sources.alias.sh\"" >> "$output_alias_file"
    echo "" >> "$output_alias_file"

	for item in "${list[@]}"; do
        echo "source \"$(realpath "$output_dir/alias.${item}.sources.sh")\"" >> "$output_alias_file"
	done

    > "$output_file"  # Clear the file first
    echo "#!/bin/bash" >> "$output_file"
    echo "" >> "$output_file"
    echo "echo \"Loaded: .polskie.sh/sources.sh\"" >> "$output_file"
    echo "source \"$(realpath "$output_dir/sources.packages.sh")\"" >> "$output_file"
    echo "source \"$(realpath "$output_dir/sources.alias.sh")\"" >> "$output_file"
    
    # source "$output_file"
fi