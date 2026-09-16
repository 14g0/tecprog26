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

validarFlagsInformacao() {
    local argumento

    mensagemVerbose "Validando flags de comando para filtragem de informações"

    for argumento in "${COMMAND_FLAGS[@]}"; do
        mensagemDebug "[[ ! "$argumento" =~ ^-run|build|clean|rebuild|[0-9]{1,3}$ ]]"

        if [[ ! "$argumento" =~ ^-(run|build|clean|rebuild|[0-9]{1,3})$ ]]
            then
                mensagemVerbose "Flag de comando inválida removida: '$argumento'" aviso sublinhado
                mensagemDebug "unset 'COMMAND_FLAGS[$argumento]'"
                unset "COMMAND_FLAGS[$argumento]"
        fi
    done
}

#-------------------------------------------------------------------------------

mostrarLog() {
    local flagComando
    local flagCodigo
    local argumento

    # TODO: por algum motivo \n no início desfaz a estilização | imprimirMensagem "\nHISTÓRICO DE COMANDOS" informacao negrito
    printf "\n\033[1mHISTÓRIO DE COMANDOS\033[m\n"

    if [[ ! -s "$CBUILD_TARGET_DIR/logs/cbuild.log" ]]; then
        imprimirMensagem "Nenhum log encontrado" aviso
        return 0
    fi

    for argumento in "${COMMAND_FLAGS[@]}"; do
        if [[ "$argumento" =~ ^-(run|build|clean|rebuild)$ ]];
            then
                [[ -n "$flagComando" ]] &&
                    imprimirMensagem "Substituindo flag de comando '$flagComando'->'$argumento'" aviso sublinhado
                flagComando="${argumento#-}"

        elif [[ "$argumento" =~ ^-[0-9]{1,3}$ ]];
            then
                [[ -n "$flagCodigo" ]] &&
                    imprimirMensagem "Substituindo flag de código '$flagCodigo'->'$argumento'" aviso sublinhado
                flagCodigo="${argumento#-}"
        fi
    done

    local registros=()
    local registroAtual=""
    local linha
    local indice
    local linhasRegistro=()
    local cabecalho
    local data
    local tempo
    local comando
    local codigo
    local flags
    local cor

    while IFS= read -r linha || [[ -n "$linha" ]]; do
        registroAtual+="$linha"$'\n'

        if [[ "$linha" == '===' ]];
            then
                registros+=("$registroAtual")
                registroAtual=""
        fi
    done < "$CBUILD_TARGET_DIR/logs/cbuild.log"

    [[ -n "$registroAtual" ]] && registros+=("$registroAtual")

    for (( indice=${#registros[@]} - 1 ; indice >= 0 ; indice-- )); do
        mapfile -t linhasRegistro <<< "${registros[$indice]}"
        cabecalho="${linhasRegistro[0]}"
        IFS='|' read -r data tempo comando codigo flags <<< "$cabecalho"

        [[ -n "$flagComando" && "$comando" != "$flagComando" ]] && continue
        [[ -n "$flagCodigo" && "$codigo" != "$flagCodigo" ]] && continue

        if [[ "$codigo" == 0 ]];
            then cor=32
            else cor=31
        fi

        printf '\033[%sm%-19s  %-8s  %8ss  código %-3s\033[m' \
            "$cor" "$data" "$comando" "$tempo" "$codigo"

        [[ -n "$flags" ]] && printf '  flags: %s' "$flags"
        printf '\n'

        for (( linha=1; linha<${#linhasRegistro[@]}; linha++ )); do
            [[ -n "${linhasRegistro[$linha]}" && "${linhasRegistro[$linha]}" != '===' ]] &&
                printf '  mensagem: %b\n' "${linhasRegistro[$linha]}"
        done
        printf '\033[90m------------------------------------------------------------\033[m\n'
    done
}

#-------------------------------------------------------------------------------


verificarEstruturaDoProjeto
validarFlagsInformacao
{
    contabilizarEstatisticasProjeto
    mostrarLog
} | less -R # -R permite cor ansi no less