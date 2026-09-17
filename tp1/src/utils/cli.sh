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
    [[ ! -r "$CBUILD_TARGET_DIR/.config" ]] &&
        saidaDeErro 304 "O arquivo de configuração '$CBUILD_TARGET_DIR/.config' não é legível."

    local configVar
    local linhaExecutavel
    local valorConfig

    imprimirMensagem ".CONFIG encontrado no diretório do projeto " "sucesso" "1"

    for configVar in "${CBUILD_ALLOWED_CONFIG_VARS_ARRAY[@]}"; do
        linhaExecutavel="$(grep -E "^$configVar=" "$CBUILD_TARGET_DIR/.config")"
        if [[ -n "$linhaExecutavel" ]]; then
            valorConfig="${linhaExecutavel#*=}"
            if [[ $configVar == COMMAND_FLAGS ]]; then
                read -r -a COMMAND_FLAGS <<< "$valorConfig"
            else
                printf -v "$configVar" "%s" "$valorConfig"
            fi
        fi
    done

    mensagemVerbose "Arquivo de configuração importado com sucesso" sucesso
}

#-------------------------------------------------------------------------------

validarCLI() {
    local flagsCLI=()
    local quantidadeDiretorios=0
    local configPath

    for argumento in "$@"; do
        if [[ "$argumento" =~ ^-([a-zA-Z]+([0-9])?|[0-9]{1,3})$ ]];
            then
                CBUILD_COMMAND_ALL_FLAGS+=("$argumento")
                if [[ "$argumento" =~ ^-[$CBUILD_ALLOWED_CLI_FLAGS]+$ ]];
                    then flagsCLI+=("$argumento")
                    else COMMAND_FLAGS+=("$argumento")
                fi
            else
                ((quantidadeDiretorios+=1))
                if ((quantidadeDiretorios > 1)); then
                    saidaDeErro 302 "Apenas um diretório de destino é permitido."
                fi
                CBUILD_TARGET_DIR="$(realpath "${argumento:-.}")"
        fi
    done

    [[ -z "$CBUILD_TARGET_DIR" ]] && CBUILD_TARGET_DIR="$(realpath .)"

    [[  
        ! -d "$CBUILD_TARGET_DIR" ||
        ! -x "$CBUILD_TARGET_DIR"
    ]] && saidaDeErro 303 "O diretório de destino '$CBUILD_TARGET_DIR' não existe."

    if [[ -f "$CBUILD_TARGET_DIR/.config" ]];
        then
            importarArquivoConfig
        else
            modificarFlagsCLI "${flagsCLI[@]}"
    fi

    verificarSetX
}

#-------------------------------------------------------------------------------

validarCLI $CLI_ARGS