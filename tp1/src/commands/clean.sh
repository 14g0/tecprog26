#!/usr/bin/env bash

limparProjeto() {
    mensagemComando "-Limpando projeto..." aviso

    mensagemVerbose "Removendo diretório de arquivos temporários gerados pela ferramenta"
    mensagemDebug "find "$CBUILD_TARGET_DIR/build" -delete"
    find "$CBUILD_TARGET_DIR/build" -delete &&
        mensagemVerbose "Diretório de arquivos temporários removido com sucesso" sucesso ||
        imprimirMensagem "-Falha ao remover diretório de arquivos temporários" aviso sublinhado

    mensagemVerbose "Removendo arquivos de objeto intermediários gerados pelo compilador"
    mensagemDebug "find "$CBUILD_TARGET_DIR/src" -type f -name "*.o" -delete"
    find "$CBUILD_TARGET_DIR/src" -type f -name "*.o" -delete &&
        mensagemVerbose "Arquivos de objeto intermediários removidos com sucesso" sucesso ||
        imprimirMensagem "-Falha ao remover arquivos de objeto intermediários" aviso sublinhado

    mensagemVerbose "Removendo arquivos de dependência intermediários gerados pelo compilador"
    mensagemDebug "find "$CBUILD_TARGET_DIR/src" -type f -name "*.d" -delete"
    find "$CBUILD_TARGET_DIR/src" -type f -name "*.d" -delete &&
        mensagemVerbose "Arquivos de dependência intermediários removidos com sucesso" sucesso ||
        imprimirMensagem "-Falha ao remover arquivos de dependência intermediários" aviso sublinhado

    mensagemComando "Projeto limpo com sucesso" sucesso 1
}

limparProjeto
return 0