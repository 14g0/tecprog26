#!/usr/bin/env bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! chmod +x "$PROJECT_DIR/src/cbuild"; then
    printf "\033[31mErro ao fornecer permissão para a CLI\033[m\n"
    return 1
fi

export PATH="$PROJECT_DIR/src:$PATH"

printf "\033[32;1mComando 'cbuild' adicionado ao PATH com sucesso\033[m\n"
printf "O comando ficará disponível apenas neste terminal.\n"