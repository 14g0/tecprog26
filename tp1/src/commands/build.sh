#!/usr/bin/env bash

#-------------------------------------------------------------------------------

removerDiretorioBuildEmErro() {
    if [[ $status -ne 0 ]];
        then
            mensagemVerbose "Removendo diretório de build em erro: '$CBUILD_TARGET_DIR/build'" aviso
            mensagemDebug "rm -rf "$CBUILD_TARGET_DIR/build""
            rm -rf "$CBUILD_TARGET_DIR/build"
            imprimirMensagem "'$CBUILD_TARGET_DIR/build' removido com sucesso" erro 4
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
                saidaDeErro "O diretório '$CBUILD_TARGET_DIR' não contém a estrutura de diretórios esperada.\n>$CBUILD_TARGET_DIR/src ausente."
            
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
}

#-------------------------------------------------------------------------------

checarMtimeDependencias() {
    mensagemComando "Verificando última modificação dos arquivos fonte e dependências"
    mensagemVerbose "Checando mtime das dependências"
}


compilarProjeto() {
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
    # <(...) é redirecionamento da saída de um comando como um arquivo, mesma ideia de $()
    mensagemDebug "mapfile -t arrayArquivosFonte < <(find "$CBUILD_TARGET_DIR/src" -name '*.c')"
    mapfile -t arrayArquivosFonte  < <(find "$CBUILD_TARGET_DIR/src" -name '*.c')

    for arquivoFonte in "${arrayArquivosFonte[@]}"; do
        arquivoObjeto="$CBUILD_TARGET_DIR/build/bin/$(basename "${arquivoFonte%.c}.o")"
        arquivoDependencia="$CBUILD_TARGET_DIR/build/dependencies/$(basename "${arquivoFonte%.c}.d")"

        if [[ ! -f $arquivoObjeto  || ! -f $arquivoDependencia ]];
            then
                mensagemVerbose "Arquivos de compilação ausentes para '$arquivoFonte'" aviso
                mensagemVerbose "Gerando arquivos de compilação para '$arquivoFonte'"
                mensagemDebug "gcc -c -Iinclude -MMD -MP -MF "$arquivoDependencia" "$arquivoFonte" -o "$arquivoObjeto" ${COMMAND_FLAGS[*]}"
                if gcc -c -Iinclude -MMD -MP -MF "$arquivoDependencia" "$arquivoFonte" -o "$arquivoObjeto" ${COMMAND_FLAGS[*]};
                    then
                        mensagemVerbose "Arquivos de compilação gerados com sucesso para '$arquivoFonte'" sucesso 1
                    else
                        saidaDeErro "Falha ao gerar arquivos de compilação para '$arquivoFonte'"
                fi
        fi
    done

    mensagemComando "-Compilação do projeto [$(basename $CBUILD_TARGET_DIR)] concluída com sucesso" sucesso
}

#-------------------------------------------------------------------------------

verificarEstruturaDoProjeto
validarFlagsCompilacao
compilarProjeto
return 0
