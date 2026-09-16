#!/usr/bin/env bash

imprimirMensagem() {
    local mensagem="$1"
    local tipo="$2"
    local modo="$3" # 1=negrito, 4=sublinhado, 7=inverter cores

    case $modo in
        negrito) modo="1";;
        sublinhado) modo="4";;
        invertido) modo="7";;
    esac

    case $tipo in
        erro) tipo="31";;
        sucesso) tipo="32";;
        aviso) tipo="33";;
        informacao) tipo="36";;
    esac

    printf '%b' "\033[${modo}${tipo:+;$tipo}m$mensagem\033[m\n"
}

mensagemComando() { # $mensagem $tipo $modo
    if [[ $VERBOSE == false && $DEBUG == false && $SETX == false ]]; then
        imprimirMensagem "$1" "$2" "$3"
    fi
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

saidaDeErro() { # $codigoErro $mensagem
    CBUILD_END_TIME=$EPOCHREALTIME
    CBUILD_LOG_CODE="$1"
    CBUILD_LOG_MESSAGE="$2"

    imprimirMensagem "ERRO: $2" erro 4 >&2 # Força a mensagem para o terminal através da stderr
    exit "$1"
}