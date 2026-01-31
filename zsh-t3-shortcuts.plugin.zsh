# t3-directory-jumper plugin
# A smart directory navigation tool for zsh

# Storage file for all shortcuts
SHORTCUTS_FILE="$HOME/.t3-shortcuts"

# Main t3 function
t3() {
    # Create shortcuts file only if it doesn't exist
    if [[ ! -f "$SHORTCUTS_FILE" ]]; then
        touch "$SHORTCUTS_FILE"
        echo "### PATH SHORTCUTS ###" >> "$SHORTCUTS_FILE"
        echo "" >> "$SHORTCUTS_FILE"
        echo "### JUMP FUNCTIONS ###" >> "$SHORTCUTS_FILE"
    fi

    # Parse command and type
    local action="$1"
    local type="$2"

    case "$action" in
        add)
            case "$type" in
                -path)
                    _t3_add_path
                    ;;
                -jump)
                    _t3_add_jump
                    ;;
                *)
                    echo "Usage: t3 add {-path|-jump}"
                    return 1
                    ;;
            esac
            ;;
        remove)
            case "$type" in
                -path)
                    _t3_remove_path
                    ;;
                -jump)
                    _t3_remove_jump
                    ;;
                *)
                    echo "Usage: t3 remove {-path|-jump}"
                    return 1
                    ;;
            esac
            ;;
        edit)
            case "$type" in
                -path)
                    _t3_edit_path "$3"
                    ;;
                -jump)
                    _t3_edit_jump "$3"
                    ;;
                *)
                    echo "Usage: t3 edit {-path|-jump} <name>"
                    return 1
                    ;;
            esac
            ;;
        list)
            case "$type" in
                -path)
                    _t3_list_paths
                    ;;
                -jump)
                    _t3_list_jumps
                    ;;
                "")
                    _t3_list_all
                    ;;
                *)
                    echo "Usage: t3 list [-path|-jump]"
                    return 1
                    ;;
            esac
            ;;
        *)
            echo "Usage: t3 {add|remove|edit|list} {-path|-jump} [name]"
            echo ""
            echo "Commands:"
            echo "  add -path        Add a path shortcut for current directory"
            echo "  add -jump        Add a jump function to search in project tree"
            echo "  remove -path     Remove an existing path shortcut"
            echo "  remove -jump     Remove an existing jump function"
            echo "  edit -path NAME  Edit an existing path shortcut"
            echo "  edit -jump NAME  Edit an existing jump function"
            echo "  list             List all shortcuts (paths and jumps)"
            echo "  list -path       List only path shortcuts"
            echo "  list -jump       List only jump functions"
            return 1
            ;;
    esac
}

# Add path shortcut
_t3_add_path() {
    # Get current directory
    local current_dir=$(pwd)

    echo "Your current directory is: $current_dir"

    # Loop until Y or N is entered
    while true; do
        read "confirm?Would you like to add a path shortcut for this directory? (Y/N) "
        if [[ "$confirm" =~ ^[YyNn]$ ]]; then
            break
        fi
        echo "Please enter Y or N."
    done

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        return 0
    fi

    # Loop until valid alias is entered or Ctrl+C is pressed
    while true; do
        read "user_alias?Enter your alias for this directory: "

        # Check if empty input
        if [[ -z "$user_alias" ]]; then
            echo "Error: Alias cannot be empty. Please try again (or press Ctrl+C to cancel)."
            continue
        fi

        # Create the full alias with "3" prefix
        local full_alias="3$user_alias"

        # Check if name already exists (in both paths and jumps)
        if _t3_name_exists "$full_alias"; then
            echo "Error: The shortcut '$full_alias' already exists. Please try a different name."
            continue
        fi

        # Valid alias entered, break the loop
        break
    done

    # Loop until Y or N is entered for final confirmation
    while true; do
        read "final_confirm?Are you sure to assign the alias '$full_alias'? (Y/N) "
        if [[ "$final_confirm" =~ ^[YyNn]$ ]]; then
            break
        fi
        echo "Please enter Y or N."
    done

    if [[ ! "$final_confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        return 0
    fi

    # Add alias to shortcuts file (in PATH SHORTCUTS section)
    local temp_file=$(mktemp)
    local in_path_section=false
    local alias_added=false

    while IFS= read -r line || [[ -n "$line" ]]; do
        echo "$line" >> "$temp_file"
        if [[ "$line" == "### PATH SHORTCUTS ###" ]]; then
            in_path_section=true
        elif [[ "$line" == "### JUMP FUNCTIONS ###" ]]; then
            if [[ "$in_path_section" == true ]] && [[ "$alias_added" == false ]]; then
                echo "alias $full_alias='cd \"$current_dir\" && ls -l'" >> "$temp_file"
                alias_added=true
            fi
            in_path_section=false
        fi
    done < "$SHORTCUTS_FILE"

    # If we never hit the JUMP FUNCTIONS section, add at end
    if [[ "$alias_added" == false ]]; then
        echo "alias $full_alias='cd \"$current_dir\" && ls -l'" >> "$temp_file"
    fi

    mv "$temp_file" "$SHORTCUTS_FILE"

    # Load the alias in current session
    alias "$full_alias"="cd \"$current_dir\" && ls -l"

    echo "The \"$full_alias\" path shortcut has been assigned to \"$current_dir\" directory!"
}

# Add jump function
_t3_add_jump() {
    # Loop until Y or N is entered for initial confirmation
    while true; do
        read "confirm?Would you like to add a jump function? (Y/N) "
        if [[ "$confirm" =~ ^[YyNn]$ ]]; then
            break
        fi
        echo "Please enter Y or N."
    done

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        return 0
    fi

    # Loop until valid shortcut name is entered or Ctrl+C is pressed
    while true; do
        read "shortcut?Enter the shortcut name: "

        # Check if empty input
        if [[ -z "$shortcut" ]]; then
            echo "Error: Shortcut name cannot be empty. Please try again (or press Ctrl+C to cancel)."
            continue
        fi

        # Create the function name with "3" prefix
        local func_name="3$shortcut"

        # Check if name already exists (in both paths and jumps)
        if _t3_name_exists "$func_name"; then
            echo "Error: The shortcut '$func_name' already exists. Please try a different name."
            continue
        fi

        # Valid shortcut entered, break the loop
        break
    done

    # Loop until valid directory is confirmed
    while true; do
        read "target_dir?Enter the directory for \"$func_name\" shortcut: "

        # Validate directory input
        if [[ -z "$target_dir" ]]; then
            echo "Error: Directory cannot be empty. Please try again (or press Ctrl+C to cancel)."
            continue
        fi

        # Show the directory and ask for confirmation
        echo "Directory: $target_dir"

        # Loop until Y or N is entered
        while true; do
            read "dir_confirm?Is this correct? (Y/N) "
            if [[ "$dir_confirm" =~ ^[YyNn]$ ]]; then
                break
            fi
            echo "Please enter Y or N."
        done

        if [[ "$dir_confirm" =~ ^[Yy]$ ]]; then
            # User confirmed, break the outer loop
            break
        else
            # User wants to re-enter
            echo "Let's try again..."
            continue
        fi
    done

    # Final confirmation before creating the function
    while true; do
        read "final_confirm?Are you sure to create the jump function '$func_name' for '$target_dir'? (Y/N) "
        if [[ "$final_confirm" =~ ^[YyNn]$ ]]; then
            break
        fi
        echo "Please enter Y or N."
    done

    if [[ ! "$final_confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        return 0
    fi

    # Create the function definition with proper escaping
    local func_definition="function ${func_name}() {
        local current_dir=\$(pwd)
        while [[ \"\$current_dir\" != \"/\" && \"\$current_dir\" != \"\$HOME\" ]]; do
            if [[ -d \"\$current_dir/${target_dir}\" ]]; then
                cd \"\$current_dir/${target_dir}\" && ls -l
                return
            fi
            current_dir=\$(dirname \"\$current_dir\")
        done
        echo \"Not in a project directory or '${target_dir}' not found\"
    }"

    # Append the new function to the file (in JUMP FUNCTIONS section)
    echo "$func_definition" >> "$SHORTCUTS_FILE"

    # Also define it in the current session
    eval "$func_definition"

    echo "The \"${func_name}\" jump function has been created!"
    echo "You can now use '${func_name}' to navigate to '${target_dir}' from anywhere in your project tree."
}

# Remove path shortcut
_t3_remove_path() {
    # Loop until valid alias is entered or Ctrl+C is pressed
    while true; do
        read "user_alias?Enter the path shortcut to delete: "

        # Check if empty input
        if [[ -z "$user_alias" ]]; then
            echo "Error: Alias cannot be empty. Please try again (or press Ctrl+C to cancel)."
            continue
        fi

        # Check if alias starts with 3
        if [[ ! "$user_alias" =~ ^3 ]]; then
            echo "Error: Only shortcuts starting with '3' can be removed. Please try again."
            continue
        fi

        # Check if alias exists in shortcuts file
        if ! grep -q "^alias $user_alias=" "$SHORTCUTS_FILE" 2>/dev/null; then
            echo "Error: The path shortcut '$user_alias' does not exist. Please try again."
            continue
        fi

        # Valid alias found, break the loop
        break
    done

    # Get the directory path for confirmation
    local alias_path=$(grep "^alias $user_alias=" "$SHORTCUTS_FILE" | sed "s/^alias $user_alias='cd \"\(.*\)\" && ls -l'/\1/")

    # Loop until Y or N is entered for delete confirmation
    while true; do
        read "confirm?Are you sure to delete \"$user_alias\" path shortcut to \"$alias_path\"? (Y/N) "
        if [[ "$confirm" =~ ^[YyNn]$ ]]; then
            break
        fi
        echo "Please enter Y or N."
    done

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        return 0
    fi

    # Remove alias from shortcuts file
    local temp_file=$(mktemp)
    grep -v "^alias $user_alias=" "$SHORTCUTS_FILE" > "$temp_file"
    mv "$temp_file" "$SHORTCUTS_FILE"

    # Unalias from current session if it exists
    unalias "$user_alias" 2>/dev/null

    echo "The \"$user_alias\" path shortcut has been removed!"
}

# Remove jump function
_t3_remove_jump() {
    # Loop until valid function name is entered or Ctrl+C is pressed
    while true; do
        read "func_name?Enter the jump function to delete: "

        # Check if empty input
        if [[ -z "$func_name" ]]; then
            echo "Error: Function name cannot be empty. Please try again (or press Ctrl+C to cancel)."
            continue
        fi

        # Check if function starts with 3
        if [[ ! "$func_name" =~ ^3 ]]; then
            echo "Error: Only jump functions starting with '3' can be removed. Please try again."
            continue
        fi

        # Check if function exists in shortcuts file
        if ! grep -q "^function ${func_name}()" "$SHORTCUTS_FILE" 2>/dev/null; then
            echo "Error: The jump function '$func_name' does not exist. Please try again."
            continue
        fi

        # Valid function found, break the loop
        break
    done

    # Get the target directory for confirmation
    local target_dir=$(grep -A 10 "^function ${func_name}()" "$SHORTCUTS_FILE" | grep -o '\$current_dir/[^"]*' | head -1 | sed 's/\$current_dir\///')

    # Loop until Y or N is entered for delete confirmation
    while true; do
        read "confirm?Are you sure to delete \"$func_name\" jump function for \"$target_dir\"? (Y/N) "
        if [[ "$confirm" =~ ^[YyNn]$ ]]; then
            break
        fi
        echo "Please enter Y or N."
    done

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        return 0
    fi

    # Remove function from shortcuts file (including all lines until closing brace)
    local temp_file=$(mktemp)
    local skip=false
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^function\ ${func_name}\(\) ]]; then
            skip=true
        elif [[ "$skip" == true ]] && [[ "$line" == "}" ]]; then
            skip=false
            continue
        fi
        if [[ "$skip" == false ]]; then
            echo "$line" >> "$temp_file"
        fi
    done < "$SHORTCUTS_FILE"
    mv "$temp_file" "$SHORTCUTS_FILE"

    # Unset function from current session if it exists
    unset -f "$func_name" 2>/dev/null

    echo "The \"$func_name\" jump function has been removed!"
}

# Edit path shortcut
_t3_edit_path() {
    local shortcut_name="$1"

    if [[ -z "$shortcut_name" ]]; then
        read "shortcut_name?Enter the path shortcut name to edit: "
    fi

    # Check if empty input
    if [[ -z "$shortcut_name" ]]; then
        echo "Error: Shortcut name cannot be empty."
        return 1
    fi

    # Check if shortcut exists
    if ! grep -q "^alias $shortcut_name=" "$SHORTCUTS_FILE" 2>/dev/null; then
        echo "Error: The path shortcut '$shortcut_name' does not exist."
        return 1
    fi

    # Get current path
    local current_path=$(grep "^alias $shortcut_name=" "$SHORTCUTS_FILE" | sed "s/^alias $shortcut_name='cd \"\(.*\)\" && ls -l'/\1/")
    echo "Current path: $current_path"

    # Ask for new path
    read "new_path?Enter new path (or press Enter to keep current): "

    if [[ -z "$new_path" ]]; then
        new_path="$current_path"
    fi

    # Confirm change
    while true; do
        read "confirm?Update '$shortcut_name' to point to '$new_path'? (Y/N) "
        if [[ "$confirm" =~ ^[YyNn]$ ]]; then
            break
        fi
        echo "Please enter Y or N."
    done

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        return 0
    fi

    # Update the shortcut
    local temp_file=$(mktemp)
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^alias\ $shortcut_name= ]]; then
            echo "alias $shortcut_name='cd \"$new_path\" && ls -l'" >> "$temp_file"
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$SHORTCUTS_FILE"
    mv "$temp_file" "$SHORTCUTS_FILE"

    # Update current session
    alias "$shortcut_name"="cd \"$new_path\" && ls -l"

    echo "The \"$shortcut_name\" path shortcut has been updated!"
}

# Edit jump function
_t3_edit_jump() {
    local func_name="$1"

    if [[ -z "$func_name" ]]; then
        read "func_name?Enter the jump function name to edit: "
    fi

    # Check if empty input
    if [[ -z "$func_name" ]]; then
        echo "Error: Function name cannot be empty."
        return 1
    fi

    # Check if function exists
    if ! grep -q "^function ${func_name}()" "$SHORTCUTS_FILE" 2>/dev/null; then
        echo "Error: The jump function '$func_name' does not exist."
        return 1
    fi

    # Get current target directory
    local current_target=$(grep -A 10 "^function ${func_name}()" "$SHORTCUTS_FILE" | grep -o '\$current_dir/[^"]*' | head -1 | sed 's/\$current_dir\///')
    echo "Current target directory: $current_target"

    # Ask for new target
    read "new_target?Enter new target directory (or press Enter to keep current): "

    if [[ -z "$new_target" ]]; then
        new_target="$current_target"
    fi

    # Confirm change
    while true; do
        read "confirm?Update '$func_name' to search for '$new_target'? (Y/N) "
        if [[ "$confirm" =~ ^[YyNn]$ ]]; then
            break
        fi
        echo "Please enter Y or N."
    done

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        return 0
    fi

    # Remove old function and add new one
    local temp_file=$(mktemp)
    local skip=false
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^function\ ${func_name}\(\) ]]; then
            skip=true
        elif [[ "$skip" == true ]] && [[ "$line" == "}" ]]; then
            skip=false
            continue
        fi
        if [[ "$skip" == false ]]; then
            echo "$line" >> "$temp_file"
        fi
    done < "$SHORTCUTS_FILE"

    # Add updated function
    local func_definition="function ${func_name}() {
        local current_dir=\$(pwd)
        while [[ \"\$current_dir\" != \"/\" && \"\$current_dir\" != \"\$HOME\" ]]; do
            if [[ -d \"\$current_dir/${new_target}\" ]]; then
                cd \"\$current_dir/${new_target}\" && ls -l
                return
            fi
            current_dir=\$(dirname \"\$current_dir\")
        done
        echo \"Not in a project directory or '${new_target}' not found\"
    }"
    echo "$func_definition" >> "$temp_file"
    mv "$temp_file" "$SHORTCUTS_FILE"

    # Update current session
    eval "$func_definition"

    echo "The \"$func_name\" jump function has been updated!"
}

# List all shortcuts
_t3_list_all() {
    if [[ ! -f "$SHORTCUTS_FILE" ]] || [[ ! -s "$SHORTCUTS_FILE" ]]; then
        echo "No shortcuts found."
        return 0
    fi

    echo "All shortcuts:"
    echo "=============="
    echo ""
    _t3_list_paths
    echo ""
    _t3_list_jumps
}

# List path shortcuts
_t3_list_paths() {
    local found=false

    echo "Path Shortcuts:"
    echo "---------------"

    while IFS= read -r line; do
        if [[ "$line" =~ ^alias\ ([^=]+)= ]]; then
            local alias_name="${match[1]}"
            local alias_path=$(echo "$line" | sed "s/^alias [^=]*='cd \"\(.*\)\" && ls -l'/\1/")
            echo "$alias_name -> $alias_path"
            found=true
        fi
    done < "$SHORTCUTS_FILE"

    if [[ "$found" == false ]]; then
        echo "No path shortcuts found."
    fi
}

# List jump functions
_t3_list_jumps() {
    local found=false

    echo "Jump Functions:"
    echo "---------------"

    [[ -f "$SHORTCUTS_FILE" ]] || return

    local lines=("${(@f)$(<"$SHORTCUTS_FILE")}")
    local total=${#lines[@]}

    # regex definitions (IMPORTANT!)
    local func_regex='^function[[:space:]]+([^(]+)\(\)'
    local dir_regex='current_dir[^/]*/([^"'"'"'}]+)'

    for (( i=1; i<=total; i++ )); do
        local line="${lines[i]}"

        if [[ $line =~ $func_regex ]]; then
            local func_name="${match[1]}"
            local target_dir=""

            for (( j=i+1; j<=total; j++ )); do
                local next_line="${lines[j]}"

                if [[ $next_line =~ $dir_regex ]]; then
                    target_dir="${match[1]}"
                    break
                fi

                [[ $next_line == '}' ]] && break
            done

            echo "$func_name -> searches for '$target_dir' in project tree"
            found=true
        fi
    done

    [[ $found == false ]] && echo "No jump functions found."
}


# Check if a name exists (in both paths and jumps)
_t3_name_exists() {
    local name="$1"

    # Check in aliases
    if alias "$name" &>/dev/null || grep -q "^alias $name=" "$SHORTCUTS_FILE" 2>/dev/null; then
        return 0
    fi

    # Check in functions
    if declare -f "$name" &>/dev/null || grep -q "^function ${name}()" "$SHORTCUTS_FILE" 2>/dev/null; then
        return 0
    fi

    return 1
}

# Up function - navigate up N directories
up() {
    local count=${1:-1}

    # Validate input is a number
    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        echo "Error: Please provide a valid number"
        return 1
    fi

    for ((i=0; i<$count; i++)); do
        cd ..
    done
}

# Load existing shortcuts when this script is sourced
if [[ -f "$SHORTCUTS_FILE" ]]; then
    source "$SHORTCUTS_FILE"
fi