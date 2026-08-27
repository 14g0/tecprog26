#!/bin/bash

COMANDOS="create help clean"

#-------------------------------------------------------------------------------

imprimirComandos() {
    if [[ -z "$2" ]]; then
        cat <<EOF
Comandos disponíveis:
    create <nome_projeto> <diretório>: Cria um template de projeto com o nome fornecido.
    clean                            : Remove o template de projeto do diretório especificado.
    help <comando>                   : Exibe informações detalhadas sobre o comando fornecido.
EOF
    else
        if [[ "$COMANDOS" == *"$2"* ]]; then
            case "$2" in
                "create")
                    cat <<EOF
    Comando: create
    -template                             : Cria um template de projeto, com arquivos sem conteúdo.
    -complete <nome_projeto> <diretório>  : Cria um projeto com o nome fornecido, no diretório especificado.
EOF
                ;;
                *)
                echo "O comando '$2' não possui ajuda detalhada."
                ;;
            esac
        else
            printf "\033[31;1mErro: Comando desconhecido '$2'.\033[m\n"
            return 1
        fi
    fi
}

#-------------------------------------------------------------------------------

projetoTemplate() {
    local pathCompleto="${4:-.}/${3:-template}"

    if mkdir -p \
        "$pathCompleto/src" \
        "$pathCompleto/tests" \
        "$pathCompleto/include" \
        "$pathCompleto/docs" && \
        touch \
        "$pathCompleto/src/main.c" \
        "$pathCompleto/tests/test.c" \
        "$pathCompleto/include/main.h" \
        "$pathCompleto/docs/README.md";
        then
            printf "\033[32;1mProjeto criado com sucesso\033[m\n";
            return 0;
        else
            printf "\033[31;1mErro ao criar o projeto\033[m\n";
            rm -rf "$pathCompleto";
            return 1;
    fi
}

criarProjeto() {
    case "$2" in
        "template")
            echo "Criando projeto template..."
            projetoTemplate
        ;;
        "complete")
            echo "Criando projeto ${3}${4:+ no diretório $4}..."
            projetoTemplate "$@"
        ;;
        *)
            printf "Argumento desconhecido.\nUse \033[33m teste --help create\033[m para ver os comandos disponíveis\n"
            return 1
        ;;
    esac
}

#-------------------------------------------------------------------------------

case "$1" in
    "create")
        criarProjeto "$@"
    ;;
    "clean")
        rm -rf ./template
    ;;
    "help")
        imprimirComandos "$@"
    ;;
    *)
        printf "Argumento desconhecido.\nUse\033[33m make test help\033[m para ver os comandos disponíveis\n"
    ;;
esac