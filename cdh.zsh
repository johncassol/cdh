cdh() {
    # Define the path to the directory history file.
    local history_file=~/.dir_history

    # Handle different commands based on the first argument.
    case "$1" in
        add)
            echo "Adicionando novo diretório ao histórico..."
            shift
            local new_dir="$*"

            # Change to the new directory and check if successful.
            if cd "$new_dir"; then
                # Check if the current directory is already the last in history to avoid duplicates.
                local last_dir=$(tail -n 1 $history_file 2>/dev/null)
                if [[ "$(pwd)" != "$last_dir" ]]; then
                    # Add the current directory to the history file.
                    echo "$(pwd)" >> $history_file
                    echo "Diretório adicionado ao histórico."
                else
                    echo "Diretório já está no histórico como a última entrada, não adicionando duplicata."
                fi
            else
                echo "Falha ao mudar para o diretório: $new_dir"
            fi
            ;;
        clean)
            # 'clean' command clears the history file.
            : > $history_file
            echo "Histórico de diretórios limpo."
            ;;
        -h)
            # Display help message.
            echo "Uso:"
            echo "  cdh                    - Lista todos os diretórios no arquivo de histórico com números de linha."
            echo "  cdh add <diretório>    - Adiciona o caminho atual no histórico."
            echo "  cdh <índice>           - Muda para o diretório correspondente ao <índice> no arquivo de histórico."
            echo "  cdh clean              - Limpa o arquivo de histórico de diretórios."
            echo "  cdh -h                 - Exibe esta mensagem de ajuda."
            ;;
        *)
            # By default, list all directories in the history file with line numbers.
            if [ -s $history_file ]; then
                if [[ "$1" =~ ^[0-9]+$ ]]; then
                    local dir=$(sed "${1}q;d" $history_file)
                    if [ -d "$dir" ]; then
                        cd "$dir" || { echo "Erro ao tentar mover para $dir"; return; }
                        echo "Movido para $dir"
                    else
                        echo "Diretório não encontrado no índice $1: $dir"
                    fi
                else
                    echo "Listando todos os diretórios no histórico:"
                    nl -w1 -s': ' $history_file
                fi
            else
                echo "Nenhum diretório no histórico."
            fi
            ;;
    esac
}

# Ensure this function is loaded and available in your shell
autoload -Uz cdh
