#!/usr/bin/env bash

#-------------------------------------------------------------------------------

verificarSetX() {
    if [[ $SETX == true ]]; then
        VERBOSE=false
        DEBUG=false
        set -x
    fi
}

#-------------------------------------------------------------------------------

modificarFlagsCLI() { # $Array(flags)
    while getopts "$CBUILD_ALLOWED_CLI_FLAGS" opt; do
        case $opt in
            v) VERBOSE=true;;
            d) DEBUG=true;;
            x) SETX=true;;
            *) saidaDeErro 301 "Opção inválida: -$OPTARG"
        esac
    done
}

#-------------------------------------------------------------------------------

importarArquivoConfig() {
    local configVar
    local linhaExecutavel

    imprimirMensagem ".CONFIG encontrado no diretório do projeto " "sucesso" "1"

    for configVar in "${CBUILD_ALLOWED_CONFIG_VARS_ARRAY[@]}"; do
        linhaExecutavel="$(grep -E "^$configVar=" "$1")"
        if [[ -n "$linhaExecutavel" ]]; then
            printf -v "$configVar" "%s" "${linhaExecutavel#*=}"
        fi
    done

    mensagemVerbose "Arquivo de configuração importado com sucesso" sucesso
}

#-------------------------------------------------------------------------------

validarCLI() {
    local flagsCLI=()
    local quantidadeDiretorios=0
    local configPath

    if [[ (( $# == 0 )) ]]; 
        then CBUILD_TARGET_DIR="$(realpath .)"
        else
            for argumento in "$@"; do
                if [[ "$argumento" =~ ^-[a-zA-Z]+([0-9])?$ ]];
                    then
                        if [[ "$argumento" =~ ^-[$CBUILD_ALLOWED_CLI_FLAGS]+$ ]];
                            then flagsCLI+=("$argumento")
                            else COMMAND_FLAGS+=("$argumento")
                        fi
                    else
                        ((quantidadeDiretorios+=1))
                        if ((quantidadeDiretorios > 1)); then
                            saidaDeErro 302 "Apenas um diretório de destino é permitido."
                        fi
                        CBUILD_TARGET_DIR="$(realpath $argumento)"
                fi
            done

            configPath="$CBUILD_TARGET_DIR/.config"
            if [[ -f "$configPath" ]];
                then
                    importarArquivoConfig "$configPath"
                else
                    modificarFlagsCLI "${flagsCLI[@]}"
            fi

            verificarSetX
    fi
}

#-------------------------------------------------------------------------------

validarCLI $CLI_ARGS