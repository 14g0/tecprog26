#!/usr/bin/env bash

limparProjeto() {
    mensagemComando "-Limpando projeto..." aviso

    if [[ ! -d "$CBUILD_TARGET_DIR/build" ]];
        then
            mensagemVerbose "Diretório de arquivos temporários não existe, nada a remover" sucesso 1
            return 0
    fi

    [[ ! -w "$CBUILD_TARGET_DIR/build" || ! -x "$CBUILD_TARGET_DIR/build" ]] &&
        saidaDeErro 1 "Sem permissão para remover arquivos de '$CBUILD_TARGET_DIR/build'."

    mensagemVerbose "Removendo diretório de arquivos temporários gerados pela ferramenta"
    mensagemDebug "find $CBUILD_TARGET_DIR/build -delete"
    find "$CBUILD_TARGET_DIR/build" -delete &&
        mensagemVerbose "Diretório de arquivos temporários removido com sucesso" sucesso ||
        imprimirMensagem "-Falha ao remover diretório de arquivos temporários" aviso sublinhado

    mensagemComando "Projeto limpo com sucesso" sucesso 1
}

limparProjeto
return 0