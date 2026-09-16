#!/usr/bin/env bash

limparProjeto() {
    mensagemComando "-Limpando projeto..." aviso
    mensagemVerbose "Removendo arquivos temporários gerados pela ferramenta" aviso
    mensagemDebug "rm -rf "$CBUILD_TARGET_DIR/build""

    if ! rm -rf "$CBUILD_TARGET_DIR/build"; then
        saidaDeErro 501 "Falha ao remover diretório de build"
    fi

    mensagemVerbose "Projeto limpo com sucesso" sucesso
    mensagemComando "Projeto limpo com sucesso" sucesso 1
}

limparProjeto
return 0