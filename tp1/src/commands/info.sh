#!/usr/bin/env bash

#-------------------------------------------------------------------------------

verificarEstruturaDoProjeto() {
    mensagemVerbose "Verificando Estrutura de Diretórios e Arquivos Fonte do Projeto"
    mensagemDebug "[[ ! -d "$CBUILD_TARGET_DIR" ]]"
    if [[ ! -d $CBUILD_TARGET_DIR ]];
        then saidaDeErro 201 "O diretório '$CBUILD_TARGET_DIR' não existe."
        else
            mensagemVerbose "Verificando se '$CBUILD_TARGET_DIR' contém a estrutura de diretórios esperada"
            mensagemDebug "[[ ! -d "$CBUILD_TARGET_DIR/src" ]]"
            [[ ! -d $CBUILD_TARGET_DIR/src ]] &&
                saidaDeErro 202 "O diretório '$CBUILD_TARGET_DIR' não contém a estrutura de diretórios esperada.\n> $CBUILD_TARGET_DIR/src ausente."
            
            mensagemVerbose "Verificando se '$CBUILD_TARGET_DIR/src' contém arquivos de código-fonte"
            mensagemDebug "find "$CBUILD_TARGET_DIR/src/" -type f -name "*.h""
            if [[ -n $(find "$CBUILD_TARGET_DIR/src/" -type f -name "*.c") ]];
                then mensagemVerbose "Arquivos de código-fonte encontrados em '$CBUILD_TARGET_DIR/src'"
                else saidaDeErro 203 "O diretório '$CBUILD_TARGET_DIR/src' não contém arquivos de código-fonte."
            fi

            mensagemVerbose "Verificando existência de '$CBUILD_TARGET_DIR/include'"
            mensagemDebug "[[ ! -d "$CBUILD_TARGET_DIR/include" ]]"    
            [[ ! -d $CBUILD_TARGET_DIR/include ]] &&
                mensagemVerbose "Diretório '$CBUILD_TARGET_DIR/include' ausente" aviso sublinhado

            mensagemVerbose "Verificando existência de arquivos header em '$CBUILD_TARGET_DIR/include'"
            mensagemDebug "find "$CBUILD_TARGET_DIR/include" -type f -name "*.h""
            if [[ -n $(find "$CBUILD_TARGET_DIR/include" -type f -name "*.h") ]];
                then mensagemVerbose "Arquivos header encontrados em '$CBUILD_TARGET_DIR/include'"
                else mensagemVerbose "O diretório '$CBUILD_TARGET_DIR/include' não contém arquivos header" aviso sublinhado
            fi
    fi
}

#-------------------------------------------------------------------------------

contabilizarEstatisticasProjeto() {
    local arquivosProjeto
    local totalArquivos=-1
    local totalLinhas=0
    local tamanhoExecutavel=-1

    mensagemVerbose "Buscando arquivos do projeto para contabilização"
    mensagemDebug "mapfile -t arquivosProjeto < <(find "$CBUILD_TARGET_DIR/src" -type f -name '*.c' -o -name '*.h')"
    ! mapfile -t arquivosProjeto < <(
        find "$CBUILD_TARGET_DIR" -type f -name "*.c" -o -name "*.h" -o -name "*.md"
    ) && saidaDeErro 204 "Falha ao buscar arquivos do projeto para contabilização"

    mensagemVerbose "Quantidade de arquivos do projeto contabilizada"
    totalArquivos=${#arquivosProjeto[@]}

    if (( ${#arquivosProjeto[@]} > 0 ));
        then
            mensagemVerbose "Contabilizando linhas de código dos arquivos do projeto"
            mensagemDebug "read -r totalLinhas _ < <(wc -l "\${arquivosProjeto[@]}")"

            if ! read -r totalLinhas _ < <(wc -l "${arquivosProjeto[@]}" | tail -n 1);
                then saidaDeErro 205 "Falha ao contabilizar linhas de código do projeto"
            fi

        else totalLinhas=-1
    fi

    mensagemVerbose "Buscando arquivo executável do projeto para contabilização"
    if [[ -f "$CBUILD_TARGET_DIR/build/$(basename $CBUILD_TARGET_DIR).exe" ]];
        then
            mensagemDebug "stat -c %s "$CBUILD_TARGET_DIR/build/$(basename $CBUILD_TARGET_DIR).exe""
            if ! tamanhoExecutavel=$(stat -c %s "$CBUILD_TARGET_DIR/build/$(basename $CBUILD_TARGET_DIR).exe");
                then saidaDeErro 206 "Falha ao buscar tamanho do executável do projeto para contabilização"
            fi

        else
            tamanhoExecutavel=-1
            mensagemVerbose "Arquivo executável do projeto não encontrado para contabilização" aviso sublinhado
    fi

    printf "%-28s" "TAM. EXECUTÁVEL PROJETO:"
    (( tamanhoExecutavel >= 0 )) &&
        imprimirMensagem "${tamanhoExecutavel}(bytes)" sucesso sublinhado ||
        imprimirMensagem "N/A" erro sublinhado

    printf "%-28s" "QTD. LINHAS DO PROJETO:"
    (( totalLinhas >= 0 )) &&
        imprimirMensagem "$totalLinhas" sucesso sublinhado ||
        imprimirMensagem "N/A" erro sublinhado

    printf "%-28s" "QTD. ARQUIVOS DO PROJETO:"
    (( totalArquivos >= 0 )) &&
        imprimirMensagem "$totalArquivos" sucesso sublinhado ||
        imprimirMensagem "N/A" erro sublinhado
}

#-------------------------------------------------------------------------------

verificarEstruturaDoProjeto
contabilizarEstatisticasProjeto