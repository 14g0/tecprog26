imprimirMensagem() {
    local mensagem="$1"
    local tipo="$2"
    local modo="$3" # 1=negrito, 4=sublinhado, 7=inverter cores

    case $modo in
        negrito) modo="1";;
        sublinhado) modo="4";;
        invertido) modo="7";;
    esac

    if [[ -n "$tipo" ]]; then
        case $tipo in
            erro) tipo="31";;
            sucesso) tipo="32";;
            aviso) tipo="33";;
            informação) tipo="36";;
        esac
    fi

    printf '%b' "\033[${modo};${tipo}m$mensagem\033[m\n"
}

mensagemVerbose() { # $mensagem $tipo $modo
    if [[ $VERBOSE == true ]];
        then imprimirMensagem "$1" "$2" "$3"
    fi
}

mensagemDebug() { # $mensagem $tipo $modo
    if [[ $DEBUG == true ]];
        then
            printf "[DEBUG] "
            imprimirMensagem "${BASH_SOURCE[1]##*/}: $1" "$2" "$3"
    fi
}

saidaDeErro() { # $mensagem
    imprimirMensagem "ERRO: $1" "erro" "4" >&2 # Força a mensagem para o terminal através da stderr
    exit 1
}