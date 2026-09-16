#!/bin/bash

COMANDOS="create help clean"

#-------------------------------------------------------------------------------

imprimirComandos() {
    if [[ -z "$2" ]]; then
    printf "\033[1mComandos disponíveis:\033[m\n\
    -create <diretório> : Cria um template de projeto com o nome fornecido.\n\
    -clean  <diretório> : Remove o template de projeto do diretório especificado.\n\
    -help   <comando>   : Exibe informações detalhadas sobre o comando fornecido.\n"
    else
        if [[ "$COMANDOS" == *"$2"* ]]; then
            case "$2" in
                "create")
                    printf "Comando: create\n\
    -create <nome_projeto> <diretório>  : Cria um projeto com o nome fornecido, no diretório especificado.\n"
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

criarProjeto() {
    echo "Criando projeto em ${2:-template}..."
    local pathBase="${2:-./template}"

    if mkdir -p \
        "$pathBase/src" \
        "$pathBase/tests" \
        "$pathBase/include" \
        "$pathBase/docs";
    then
        printf "\033[32m    -Diretórios criados com sucesso\033[m\n"
    else
        printf "\033[31mNão foi possível criar todos os diretórios\n"
        printf "Abortando operação.\033[m\n"
        return 1
    fi
    
    if [[ -z "$2" ]];
        then
            if touch \
                "$pathBase/src/main.c" \
                "$pathBase/tests/test.c" \
                "$pathBase/include/main.h" \
                "$pathBase/docs/README.md";
                then
                    printf "\033[32m    -Arquivos template criados com sucesso nas pastas\033[m\n"
                    return 0
                else
                    printf "\033[31mNão foi possível criar todos os arquivos template\033[m\n"
                    return 1
            fi
        else
            for arquivo in "$CBUILD_ASSETS"/*; do
                case "$arquivo" in
                    */test*)
                        if ! cp -a "$arquivo" "$pathBase/tests/";
                            then
                                printf "\033[31mNão foi possível copiar o arquivo $arquivo\033[m\n"
                                echo "Abortando operação."
                                return 1
                        fi
                    ;;
                    *.c)
                        if ! cp -a "$arquivo" "$pathBase/src/";
                            then
                                printf "\033[31mNão foi possível copiar o arquivo $arquivo\033[m\n"
                                return 1
                        fi
                    ;;
                    *.h)
                        if ! cp -a "$arquivo" "$pathBase/include/";
                            then
                                printf "\033[31mNão foi possível copiar o arquivo $arquivo\033[m\n"
                                return 1
                        fi
                    ;;
                esac
            done
                
            if ! touch "$pathBase/docs/README.md";
                then printf "\033[31mNão foi possível criar o README.md em docs\033[m\n"
            fi
    fi

    printf "\033[32m    -Assets alocados corretamente\033[m\n"
    printf "\033[32;1mProjeto criado com sucesso\033[m\n"
    return 0
}

#-------------------------------------------------------------------------------

limparProjeto() {
    echo "Removendo projeto ${3:-template}${4:+ no diretório $4}..."

    local pathBase="${3:-./template}"
    rm -rf "$pathBase" && \
        printf "\033[32;1mProjeto removido com sucesso\033[m\n" || \
        printf "\033[31;1mErro ao remover o projeto\033[m\n"
}

#-------------------------------------------------------------------------------

case "$1" in
    "-create")
        criarProjeto "$@"
    ;;
    "-clean")
        limparProjeto "$@"
    ;;
    "-help")
        imprimirComandos "$@"
    ;;
    *)
        printf "Argumento desconhecido.\nUse \033[33mcbuild test -help\033[m para ver os comandos disponíveis\n"
    ;;
esac