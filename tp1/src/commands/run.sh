#!/usr/bin/env bash

mensagemVerbose "Procurando executável do projeto em '$CBUILD_TARGET_DIR/build'"
mensagemDebug "[[ ! -f "$CBUILD_TARGET_DIR/build/$(basename "$CBUILD_TARGET_DIR").exe" ]]"
if [[ ! -f "$CBUILD_TARGET_DIR/build/$(basename "$CBUILD_TARGET_DIR").exe" ]];
    then saidaDeErro 601 "O executável do projeto não foi encontrado"
fi

if ! "$CBUILD_TARGET_DIR/build/$(basename "$CBUILD_TARGET_DIR").exe";
    then saidaDeErro 602 "Falha ao executar o projeto"
fi