#!/usr/bin/env bash

modificarFlagsGlobais() { # $Array(flags)
    while getopts "vd" opt; do
        case $opt in
            v)
                VERBOSE=true;;
            d) DEBUG=true;;
            *) echo "Opção inválida: -$OPTARG" >&2; exit 1;;
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
    local flagsGlobais=()
    local quantidadeDiretorios=0
    local configPath

    for argumento in "$@"; do
        if [[ "$argumento" =~ ^-[a-zA-Z]+([0-9])?$ ]];
            then
                if [[ "$argumento" =~ ^-[$CBUILD_ALLOWED_GLOBAL_FLAGS]{1,2}$ ]];
                    then
                        flagsGlobais+=("$argumento")
                    else COMMAND_FLAGS+=("$argumento")
                fi
            else
                ((quantidadeDiretorios+=1))
                if ((quantidadeDiretorios > 1)); then
                    saidaDeErro "Apenas um diretório de destino é permitido."
                fi
                CBUILD_TARGET_DIR="$(realpath $argumento)"
        fi
    done

    configPath="$CBUILD_TARGET_DIR/.config"
    if [[ -f "$configPath" ]];
        then
            importarArquivoConfig "$configPath"
        else
            modificarFlagsGlobais "${flagsGlobais[@]}"
    fi
    
}