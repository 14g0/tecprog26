#!/usr/bin/env bash
#!/usr/bin/env bash

#-------------------------------------------------------------------------------

removerDiretorioBuildEmErro() {
    if [[ $? -ne 0 ]];
        then
            mensagemVerbose "Removendo diretório de build em erro: '$CBUILD_TARGET_DIR/build'" aviso
            mensagemDebug "rm -rf "$CBUILD_TARGET_DIR/build""
            rm -rf "$CBUILD_TARGET_DIR/build"
            imprimirMensagem "'$CBUILD_TARGET_DIR/build' removido com sucesso" erro 1
    fi
}

trap removerDiretorioBuildEmErro EXIT

#-------------------------------------------------------------------------------

verificarEstruturaDoProjeto() {
    mensagemVerbose "Verificando Estrutura de Diretórios e Arquivos Fonte do Projeto"

    if [[ ! -d $CBUILD_TARGET_DIR ]];
        then saidaDeErro "O diretório '$CBUILD_TARGET_DIR' não existe."
        else
            mensagemVerbose "Verificando se '$CBUILD_TARGET_DIR' contém a estrutura de diretórios esperada"
            mensagemDebug "[[ ! -d "$CBUILD_TARGET_DIR/src" ]]"
            [[ ! -d $CBUILD_TARGET_DIR/src ]] &&
                saidaDeErro "O diretório '$CBUILD_TARGET_DIR' não contém a estrutura de diretórios esperada.\n> $CBUILD_TARGET_DIR/src ausente."
            
            mensagemVerbose "Verificando se '$CBUILD_TARGET_DIR/src' contém arquivos de código-fonte"
            mensagemDebug "find "$CBUILD_TARGET_DIR/src/" -type f -name "*.h""
            if [[ -n $(find "$CBUILD_TARGET_DIR/src/" -type f -name "*.c") ]];
                then mensagemVerbose "Arquivos de código-fonte encontrados em '$CBUILD_TARGET_DIR/src'"
                else saidaDeErro "O diretório '$CBUILD_TARGET_DIR/src' não contém arquivos de código-fonte."
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

    mensagemComando "-Estrutura de diretórios e arquivos fonte do projeto verificada" informacao
}

#-------------------------------------------------------------------------------

validarFlagsCompilacao() {
    local flag
    local indiceFlag

    mensagemVerbose "Validando flags de compilação passadas via CLI"

    for indiceFlag in "${!COMMAND_FLAGS[@]}"; do
        flag="${COMMAND_FLAGS[$indiceFlag]}"

        mensagemDebug "! printf 'int main(void){return 0;}' | gcc "$flag" -x c - -fsyntax-only >/dev/null 2>&1"
        # -x c: indica que o arquivo de entrada é C | - : lê o código-fonte do stdin | -fsyntax-only: apenas verifica a sintaxe, não gera código objeto
        if ! printf 'int main(void){return 0;}\n' | gcc "$flag" -x c - -fsyntax-only >/dev/null 2>&1;
            then
                mensagemVerbose "Removendo flag de compilação inválida: '$flag'" aviso sublinhado
                mensagemDebug "unset 'COMMAND_FLAGS[$indiceFlag]'"
                unset "COMMAND_FLAGS[$indiceFlag]"
        fi
    done

    mensagemComando "-Flags de compilação validadas, flags inválidas removidas" informacao

    return 0
}

#-------------------------------------------------------------------------------

checarMtimeDependencias() {
    local arrayArquivosDependencia

    mensagemVerbose "Buscando dependências para '$arquivoObjeto' em '$arquivoDependencia'"
    mensagemDebug "mapfile -t arrayArquivosDependencia < <(\n \
    grep -E '^[^[:space:]].*\.o:|^[[:space:]]+[^[:space:]]' "$arquivoDependencia" |\n \
    grep -oE '[^[:space:]]+\.(c|h)'\n \
)"
    mapfile -t arrayArquivosDependencia < <(
        grep -E '^[^[:space:]].*\.o:|^[[:space:]]+[^[:space:]]' "$arquivoDependencia" |
        grep -oE '[^[:space:]]+\.(c|h)'
    )

    mensagemVerbose "Checando atualização de dependências para '$arquivoObjeto'"
    for arquivo in "${arrayArquivosDependencia[@]}"; do
        if [[ $arquivo -nt $arquivoObjeto ]];
            then
                mensagemVerbose "Dependência '$arquivo' é mais recente que '$arquivoObjeto'" aviso
                return 0
        fi
    done

    return 1
}

#-------------------------------------------------------------------------------

gerarArquivosLinkedicao() {
    local arrayArquivosFonte
    local arquivoFonte
    local arquivoObjeto
    local arquivoDependencia

    mensagemVerbose "Verificando existência de'$CBUILD_TARGET_DIR/build'"
    if [[ ! -d $CBUILD_TARGET_DIR/build ]];
        then
            mensagemVerbose "Criando diretório de build em '$CBUILD_TARGET_DIR/build'"
            mensagemDebug "mkdir -p "$CBUILD_TARGET_DIR/build""
            if mkdir -p "$CBUILD_TARGET_DIR/build";
                then mensagemVerbose "Diretório de build criado com sucesso em '$CBUILD_TARGET_DIR/build'" sucesso
                else saidaDeErro "Falha ao criar diretório de build em '$CBUILD_TARGET_DIR/build'"
            fi
    fi

    mensagemVerbose "Verificando existência de '$CBUILD_TARGET_DIR/build/bin'"
    if [[ ! -d $CBUILD_TARGET_DIR/build/bin ]];
        then
            mensagemVerbose "Criando diretório de objetos em '$CBUILD_TARGET_DIR/build/bin'"
            mensagemDebug "mkdir -p "$CBUILD_TARGET_DIR/build/bin""
            if mkdir -p "$CBUILD_TARGET_DIR/build/bin";
                then mensagemVerbose "Diretório de objetos criado com sucesso em '$CBUILD_TARGET_DIR/build/bin'" sucesso
                else saidaDeErro "Falha ao criar diretório de objetos em '$CBUILD_TARGET_DIR/build/bin'"
            fi
    fi

    mensagemVerbose "Verificando existência de '$CBUILD_TARGET_DIR/build/dependencies'"
    if [[ ! -d $CBUILD_TARGET_DIR/build/dependencies ]];
        then
            mensagemVerbose "Criando diretório de dependências em '$CBUILD_TARGET_DIR/build/dependencies'"
            mensagemDebug "mkdir -p "$CBUILD_TARGET_DIR/build/dependencies""
            if mkdir -p "$CBUILD_TARGET_DIR/build/dependencies";
                then mensagemVerbose "Diretório de dependências criado com sucesso em '$CBUILD_TARGET_DIR/build/dependencies'" sucesso
                else saidaDeErro "Falha ao criar diretório de dependências em '$CBUILD_TARGET_DIR/build/dependencies'"
            fi
    fi

    mensagemVerbose "Varrendo arquivos fonte para compilação em '$CBUILD_TARGET_DIR/src'"
    mensagemDebug "mapfile -t arrayArquivosFonte < <(find "$CBUILD_TARGET_DIR/src" -name '*.c')"

    # <(...) é redirecionamento da saída de um comando como um arquivo, mesma ideia de $()
    mapfile -t arrayArquivosFonte  < <(
        find "$CBUILD_TARGET_DIR/src" -name '*.c'
    )
    (( ${#arrayArquivosFonte[@]} < 1 )) && \
        saidaDeErro "Nenhum arquivo fonte encontrado em '$CBUILD_TARGET_DIR/src'"

    for arquivoFonte in "${arrayArquivosFonte[@]}"; do
        arquivoObjeto="$CBUILD_TARGET_DIR/build/bin/$(basename "${arquivoFonte%.c}.o")"
        arquivoDependencia="$CBUILD_TARGET_DIR/build/dependencies/$(basename "${arquivoFonte%.c}.d")"

        if [[ ! -f $arquivoObjeto  || ! -f $arquivoDependencia ]] || ! checarMtimeDependencias;
            then
                mensagemVerbose "Arquivos de linkedição ausentes para '$arquivoFonte'" aviso
                mensagemVerbose "Gerando arquivos de linkedição para '$arquivoFonte'"
                mensagemDebug "gcc -c -Iinclude -MMD -MP -MF "$arquivoDependencia" "$arquivoFonte" -o "$arquivoObjeto" ${COMMAND_FLAGS[*]}"

                if gcc -c -Iinclude -MMD -MP -MF "$arquivoDependencia" "$arquivoFonte" -o "$arquivoObjeto" ${COMMAND_FLAGS[*]};
                    then
                        mensagemVerbose "Arquivos de linkedição gerados com sucesso para '$arquivoFonte'" sucesso 1
                    else
                        saidaDeErro "Falha ao gerar arquivos de linkedição para '$arquivoFonte'"
                fi
        fi
    done

    mensagemComando "-Arquivos de linkedição gerados com sucesso" informacao

    return 0
}

#-------------------------------------------------------------------------------

linkeditarArquivos() {
    local arrayArquivosObjeto=()
    local arquivoObjeto

    mensagemVerbose "Separando arquivos objeto para linkedição"
    mapfile -t arrayArquivosObjeto < <(
        find "$CBUILD_TARGET_DIR/build/bin" -name '*.o'
    )

    mensagemVerbose "Linkeditando arquivos objeto em '$CBUILD_TARGET_DIR/build/bin'"
    mensagemDebug "gcc -o $CBUILD_TARGET_DIR/build/$(dirname "$CBUILD_TARGET_DIR") ${arrayArquivosObjeto[*]} ${COMMAND_FLAGS[*]}"

    if ! gcc -o "$CBUILD_TARGET_DIR/build/$(basename "$CBUILD_TARGET_DIR").exe" "${arrayArquivosObjeto[@]}" "${COMMAND_FLAGS[@]}";
        then
            saidaDeErro "Falha ao linkeditar arquivos objeto em '$CBUILD_TARGET_DIR/build/bin'"
    fi

    mensagemComando "Compilação concluída com sucesso" sucesso 1
}
  
#-------------------------------------------------------------------------------

verificarEstruturaDoProjeto
gerarArquivosLinkedicao
validarFlagsCompilacao
linkeditarArquivos
return 0