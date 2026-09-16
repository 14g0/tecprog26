#!/usr/bin/env bash

#-------------------------------------------------------------------------------

# FORMATO DE REGISTRO DO LOG:
#   data de execução | tempo de execução | comando | codigoErro | flags
#   0 para sucesso, mensagem de erro em falha
#   ============================================================================

#-------------------------------------------------------------------------------

logComando() {
    local flags=()
    local argumento
    local dataAtual=$(date +"%m/%d/%Y_%H:%M:%S")
    local tempoExecucao

    tempoExecucao=$(awk -v inicio="$CBUILD_START_TIME" -v fim="$CBUILD_END_TIME" \
        'BEGIN { printf "%.6f", fim - inicio }'
    )

    mensagemVerbose "Verificando existência do diretório de logs em '$CBUILD_TARGET_DIR/logs'"
    mensagemDebug "[[ ! -d $CBUILD_TARGET_DIR/logs ]]"
    if [[ ! -d $CBUILD_TARGET_DIR/logs ]];
        then 
            mensagemVerbose "Criando diretório de logs em '$CBUILD_TARGET_DIR/logs'"
            mensagemDebug "mkdir -p "$CBUILD_TARGET_DIR/logs""

            if mkdir -p "$CBUILD_TARGET_DIR/logs";
                then mensagemVerbose "Diretório de logs criado com sucesso em '$CBUILD_TARGET_DIR/logs'" sucesso
                else saidaDeErro 401 "Falha ao criar diretório de logs em '$CBUILD_TARGET_DIR/logs'"
            fi
    fi
    
    mensagemVerbose "Verificando existência do arquivo de logs em '$CBUILD_TARGET_DIR/logs/cbuild.log'"
    mensagemDebug "[[ ! -f $CBUILD_TARGET_DIR/logs/cbuild.log ]]"
    if [[ ! -f $CBUILD_TARGET_DIR/logs/cbuild.log ]];
        then
            mensagemVerbose "Criando arquivo de logs em '$CBUILD_TARGET_DIR/logs/cbuild.log'"
            mensagemDebug "touch "$CBUILD_TARGET_DIR/logs/cbuild.log""

            if touch "$CBUILD_TARGET_DIR/logs/cbuild.log";
                then mensagemVerbose "Arquivo de logs criado com sucesso em '$CBUILD_TARGET_DIR/logs/cbuild.log'" sucesso
                else saidaDeErro 402 "Falha ao criar arquivo de logs em '$CBUILD_TARGET_DIR/logs/cbuild.log'"
            fi
    fi

    mensagemVerbose "Contabilizar flags de comando"
    for argumento in "$@"; do
        if [[ "$argumento" =~ ^-[a-zA-Z]+([0-9])?$ ]];
            then flags+=("$argumento")
        fi
    done

    mensagemVerbose "Registrando log do comando em '$CBUILD_TARGET_DIR/logs/cbuild.log'"
    mensagemDebug "printf '%s|%s|%s|%s|%s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$comando" "$tempo" "$CBUILD_LOG_CODE" "$flags""
    {
        printf '%s|%s|%s|%s|%s\n' "$dataAtual" "$tempoExecucao" "$CBUILD_LOG_COMMAND" "$CBUILD_LOG_CODE" "${flags[*]}"
        if [ -n "$CBUILD_LOG_MESSAGE" ]; then
            printf '%s\n' "$CBUILD_LOG_MESSAGE"
        fi
        printf '===\n'
    } >> "$CBUILD_TARGET_DIR/logs/cbuild.log"
}

registrarLog() {
    local status="$?"

    [[ "$CBUILD_END_TIME" == 0 ]] && CBUILD_END_TIME=$EPOCHREALTIME

    if [[ "$status" -ne 0 && "$CBUILD_LOG_CODE" == 0 ]];
        then CBUILD_LOG_CODE="$status"
    fi

    logComando
}