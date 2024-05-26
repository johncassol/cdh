cdh() {
    # Define the path to the directory history file.
    local history_file=~/.dir_history

    # Handle different commands based on the first argument.
    case "$1" in
        add)
            echo "Adding new directory to history..."
            shift
            local new_dir="$*"

            # Change to the new directory and check if successful.
            if cd "$new_dir"; then
                # Check if the current directory is already the last in history to avoid duplicates.
                local last_dir=$(tail -n 1 $history_file 2>/dev/null)
                if [[ "$(pwd)" != "$last_dir" ]]; then
                    # Add the current directory to the history file.
                    echo "$(pwd)" >> $history_file
                    echo "Directory added to history."
                else
                    echo "Directory is already the last entry in history, not adding duplicate."
                fi
            else
                echo "Failed to change to directory: $new_dir"
            fi
            ;;
        clean)
            # 'clean' command clears the history file.
            : > $history_file
            echo "Directory history cleaned."
            ;;
        -h)
            # Display help message.
            echo "Usage:"
            echo "  cdh                    - Lists all directories in the history file with line numbers."
            echo "  cdh add <directory>    - Adds the current path to the history."
            echo "  cdh <index>            - Changes to the directory corresponding to <index> in the history file."
            echo "  cdh clean              - Clears the directory history file."
            echo "  cdh -h                 - Displays this help message."
            ;;
        *)
            # By default, list all directories in the history file with line numbers.
            if [ -s $history_file ]; then
                if [[ "$1" =~ ^[0-9]+$ ]]; then
                    local dir=$(sed "${1}q;d" $history_file)
                    if [ -d "$dir" ]; then
                        cd "$dir" || { echo "Error trying to move to $dir"; return; }
                        echo "Moved to $dir"
                    else
                        echo "Directory not found at index $1: $dir"
                    fi
                else
                    echo "Listing all directories in history:"
                    nl -w1 -s': ' $history_file
                fi
            else
                echo "No directories in history."
            fi
            ;;
    esac
}

# Ensure this function is loaded and available in your shell
autoload -Uz cdh
