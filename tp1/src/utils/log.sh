#!/usr/bin/env bash

#-------------------------------------------------------------------------------

# FORMATO DE REGISTRO DO LOG:
#   data de execução | tempo de execução | comando | codigoErro | flags
#   0 para sucesso, mensagem de erro em falha
#   ===

#-------------------------------------------------------------------------------

logComando() {
    local flags=()
    local argumento
    local dataAtual=$(date +"%m/%d/%Y %H:%M:%S")
    local tempoExecucao

    tempoExecucao=$(awk -v inicio="$CBUILD_START_TIME" -v fim="$CBUILD_END_TIME" \
        'BEGIN { printf "%.6f", fim - inicio }'
    )

    [[ ! -d "$CBUILD_TARGET_DIR" ||
        ! -x "$CBUILD_TARGET_DIR" ||
        ! -w "$CBUILD_TARGET_DIR"
    ]] && saidaDeErro 400 "Sem permissão para criar o diretório de logs em $CBUILD_TARGET_DIR."

    [[ -d "$CBUILD_TARGET_DIR/logs" &&
      (! -w "$CBUILD_TARGET_DIR/logs" ||
       ! -x "$CBUILD_TARGET_DIR/logs")
    ]] && saidaDeErro 401 "Sem permissão para gravar em '$CBUILD_TARGET_DIR/logs'"

    mensagemVerbose "Verificando existência do diretório de logs em '$CBUILD_TARGET_DIR/logs'"
    mensagemDebug "[[ ! -d $CBUILD_TARGET_DIR/logs ]]"
    if [[ ! -d $CBUILD_TARGET_DIR/logs ]];
        then 
            mensagemVerbose "Criando diretório de logs em '$CBUILD_TARGET_DIR/logs'"
            mensagemDebug "mkdir -p $CBUILD_TARGET_DIR/logs"

            if mkdir -p "$CBUILD_TARGET_DIR/logs";
                then mensagemVerbose "Diretório de logs criado com sucesso em '$CBUILD_TARGET_DIR/logs'" sucesso
                else saidaDeErro 402 "Falha ao criar diretório de logs em '$CBUILD_TARGET_DIR/logs'"
            fi
    fi
    
    mensagemVerbose "Verificando existência do arquivo de logs em '$CBUILD_TARGET_DIR/logs/cbuild.log'"
    mensagemDebug "[[ ! -f $CBUILD_TARGET_DIR/logs/cbuild.log ]]"
    if [[ ! -f "$CBUILD_TARGET_DIR/logs/cbuild.log" ]];
        then
            [[ -f "$CBUILD_TARGET_DIR/logs/cbuild.log" &&
              ! -w "$CBUILD_TARGET_DIR/logs/cbuild.log"
            ]] && saidaDeErro "Sem permissão para escrever em '$CBUILD_TARGET_DIR/logs/cbuild.log'"

            mensagemVerbose "Criando arquivo de logs em '$CBUILD_TARGET_DIR/logs/cbuild.log'"
            mensagemDebug "touch $CBUILD_TARGET_DIR/logs/cbuild.log"


            if touch "$CBUILD_TARGET_DIR/logs/cbuild.log";
                then mensagemVerbose "Arquivo de logs criado com sucesso em '$CBUILD_TARGET_DIR/logs/cbuild.log'" sucesso
                else saidaDeErro 403 "Falha ao criar arquivo de logs em '$CBUILD_TARGET_DIR/logs/cbuild.log'"
            fi
    fi

    mensagemVerbose "Contabilizando flags de comando"
    for argumento in "${CBUILD_COMMAND_ALL_FLAGS[@]}"; do
        if [[ "$argumento" =~ ^-[a-zA-Z]+([0-9])?$ ]];
            then flags+=("$argumento")
        fi
    done

    mensagemVerbose "Registrando log do comando em '$CBUILD_TARGET_DIR/logs/cbuild.log'"
    mensagemDebug "printf '%s|%s|%s|%s|%s\n' $dataAtual $CBUILD_LOG_COMMAND $tempoExecucao $CBUILD_LOG_CODE ${flags[*]}"
    {
        printf '%s|%s|%s|%s|%s\n' "$dataAtual" "$tempoExecucao" "$CBUILD_LOG_COMMAND" "$CBUILD_LOG_CODE" "${flags[*]}"
        if [ -n "$CBUILD_LOG_MESSAGE" ]; then
            printf '%s\n' "$CBUILD_LOG_MESSAGE"
        fi
        printf '===\n'
    } >> "$CBUILD_TARGET_DIR/logs/cbuild.log"
    mensagemVerbose "Log do comando registrado com sucesso em '$CBUILD_TARGET_DIR/logs/cbuild.log'" sucesso
}

#-------------------------------------------------------------------------------

registrarLog() {
    local status="$?"

    [[ ! -d "$CBUILD_TARGET_DIR/src" && ! -d "$CBUILD_TARGET_DIR/include" ]] && return 1

    [[ "$CBUILD_END_TIME" == 0 ]] && CBUILD_END_TIME="${EPOCHREALTIME/,/.}"

    if [[ "$status" -ne 0 && "$CBUILD_LOG_CODE" == 0 ]];
        then CBUILD_LOG_CODE="$status"
    fi

    logComando
}