#!/bin/bash

COMANDOS="create help clean"

#-------------------------------------------------------------------------------

imprimirComandos() {
    if [[ -z "$2" ]]; then
        cat <<EOF
Comandos disponíveis:
    create template|completo <nome_projeto> <diretório> : Cria um template de projeto com o nome fornecido.
    clean  <nome_projeto> <diretório>                   : Remove o template de projeto do diretório especificado.
    help <comando>                                      : Exibe informações detalhadas sobre o comando fornecido.
EOF
    else
        if [[ "$COMANDOS" == *"$2"* ]]; then
            case "$2" in
                "create")
                    cat <<EOF
    Comando: create
    -template                             : Cria um template de projeto, com arquivos sem conteúdo.
    -completo <nome_projeto> <diretório>  : Cria um projeto com o nome fornecido, no diretório especificado.
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

criarProjeto() {
    local opcoesDisponiveis="completo template"
    if [[ ! "$opcoesDisponiveis" == *"$2" ]]; then
        printf "\033[31mOpção inválida para o comando create\033[m\n"
        return 1
    fi

    local pathCompleto="${4:-.}/${3:-template}"
    if mkdir -p \
        "$pathCompleto/src" \
        "$pathCompleto/tests" \
        "$pathCompleto/include" \
        "$pathCompleto/docs";
    then
        printf "\033[32m    -Diretórios criados com sucesso\033[m\n"
    else
        printf "\033[31mNão foi possível criar todos os diretórios\n"
        printf "Abortando operação.\033[m\n"
        return 1
    fi

    case "$2" in
        "template")
            if touch \
                "$pathCompleto/src/main.c" \
                "$pathCompleto/tests/test.c" \
                "$pathCompleto/include/main.h" \
                "$pathCompleto/docs/README.md";
            then
                printf "\033[32m    -Arquivos template criados com sucesso nas pastas\033[m\n"
                return 0
            else
                printf "\033[31mNão foi possível criar todos os arquivos template\033[m\n"
                return 1
            fi
        ;;
        "completo")
            for arquivo in ./src/assets/*; do
                case "$arquivo" in
                    */test*)
                        if ! cp -a "$arquivo" "$pathCompleto/tests/";
                        then
                            printf "\033[31mNão foi possível copiar o arquivo $arquivo\033[m\n"
                            echo "Abortando operação."
                            return 1
                        fi
                    ;;
                    *.c)
                        if ! cp -a "$arquivo" "$pathCompleto/src/";
                        then
                            printf "\033[31mNão foi possível copiar o arquivo $arquivo\033[m\n"
                            return 1
                        fi
                    ;;
                    *.h)
                        if ! cp -a "$arquivo" "$pathCompleto/include/";
                        then
                            printf "\033[31mNão foi possível copiar o arquivo $arquivo\033[m\n"
                            return 1
                        fi
                    ;;
                esac
            done
            
            if ! touch "$pathCompleto/docs/README.md";
            then printf "\033[31mNão foi possível criar o README.md em docs\033[m\n"
            fi
        ;;
    esac
    printf "\033[32m    -Assets alocados corretamente\033[m\n"
    printf "\033[32;1mProjeto criado com sucesso\033[m\n"
    return 0
}

verificarTipoDeProjeto() {
    case "$2" in
        template|completo)
            echo "Criando projeto ${3:-template} ${4:+ no diretório $4}..."
            criarProjeto "$@"
        ;;
        *)
            printf "Argumento desconhecido.\nUse \033[33m teste --help create\033[m para ver os comandos disponíveis\n"
            return 1
        ;;
    esac
}

#-------------------------------------------------------------------------------

limparProjeto() {
    echo "Removendo projeto ${3:-template}${4:+ no diretório $4}..."

    local pathCompleto="${4:-.}/${3:-template}"
    rm -rf "$pathCompleto" && \
        printf "\033[32;1mProjeto removido com sucesso\033[m\n" || \
        printf "\033[31;1mErro ao remover o projeto\033[m\n"
}

#-------------------------------------------------------------------------------

case "$1" in
    "create")
        verificarTipoDeProjeto "$@"
    ;;
    "clean")
        limparProjeto "$@"
    ;;
    "help")
        imprimirComandos "$@"
    ;;
    *)
        printf "Argumento desconhecido.\nUse\033[33m make test help\033[m para ver os comandos disponíveis\n"
    ;;
esac