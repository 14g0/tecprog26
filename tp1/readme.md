# cbuild

`cbuild` e uma CLI para compilar, executar, limpar e consultar projetos em C.

## Instalacao

Na raiz do repositorio, execute:

```bash
source tp1/init.sh
```

O comando `cbuild` ficara disponivel apenas no terminal atual.

## Sintaxe

```text
cbuild <comando> [diretorio] [flags]
```

Se o diretorio nao for informado, o diretorio atual (`.`) sera usado.

Comandos disponiveis:

| Comando | Funcao |
| --- | --- |
| `build` | Compila o projeto e gera o executavel. |
| `run` | Executa o executavel gerado pelo `build`. |
| `clean` | Remove os arquivos gerados em `build/`. |
| `rebuild` | Executa `clean` e depois `build`. |
| `info` | Mostra estatisticas do projeto e o historico de comandos. |

Exemplos:

```bash
cbuild build template/
cbuild run template/
cbuild clean template/
cbuild rebuild template/
cbuild info template/
```

## Flags gerais

As flags gerais controlam a exibicao de mensagens da CLI:

| Flag | Funcao |
| --- | --- |
| `-v` | Ativa mensagens detalhadas (`verbose`). |
| `-d` | Ativa mensagens de depuracao (`debug`). |
| `-x` | Ativa o rastreamento de comandos do Bash (`set -x`). |

Elas podem ser combinadas:

```bash
cbuild build template/ -v
cbuild build template/ -d
cbuild build template/ -x
cbuild build template/ -vd
```

Quando `-x` e usada, `verbose` e `debug` sao desativados e o Bash mostra os
comandos executados.

## Flags do GCC no `build`

Argumentos iniciados por `-` que nao sejam flags gerais sao encaminhados ao
GCC durante a compilacao. Cada flag deve ser um argumento separado:

```bash
cbuild build template/ -Iinclude -O2 -Wall -ansi -pedantic
```

Essas flags tambem podem ser configuradas no arquivo `.config` do projeto:

```ini
VERBOSE=true
COMMAND_FLAGS=-Iinclude -O2 -Wall -ansi -pedantic
```

O `COMMAND_FLAGS` e separado por espacos e cada item e passado ao GCC como um
argumento independente. As flags sao validadas antes da compilacao; flags
invalidas sao removidas.

O `-I` informa um diretorio onde o GCC deve procurar arquivos de cabecalho:

```bash
-Iinclude
```

Quando existe um `.config`, suas configuracoes sao importadas para o projeto.
Nesse caso, use o arquivo para definir `VERBOSE`, `DEBUG`, `SETX` e
`COMMAND_FLAGS`.

As configuracoes do `.config` substituem os valores recebidos pela linha de
comando. Portanto, para usar flags do GCC ou filtros do `info`, defina-os no
`.config` ou remova temporariamente esse arquivo.

## Flags do `info`

O comando `info` aceita filtros para o historico de execucao:

| Flag | Funcao |
| --- | --- |
| `-run` | Mostra apenas execucoes de `run`. |
| `-build` | Mostra apenas execucoes de `build`. |
| `-clean` | Mostra apenas execucoes de `clean`. |
| `-rebuild` | Mostra apenas execucoes de `rebuild`. |
| `-<codigo>` | Mostra apenas registros com o codigo informado. |

Exemplos:

```bash
cbuild info template/ -build
cbuild info template/ -run
cbuild info template/ -0
cbuild info template/ -build -0
```

Os filtros podem ser combinados. Se o mesmo tipo de filtro for informado mais
de uma vez, o ultimo valor substitui o anterior. A listagem e aberta no
`less`; pressione `q` para sair.

> Atualmente, `COMMAND_FLAGS` e compartilhado entre o `build` e o `info`.
> Um `.config` preparado com flags do GCC nao fornece filtros do `info` pela
> linha de comando, pois o arquivo substitui esses argumentos.

## Estrutura esperada

O projeto precisa conter um diretorio `src/` com pelo menos um arquivo `.c`.
O diretorio `include/` e opcional e pode conter arquivos `.h`.

Arquivos gerados pelo `build` ficam em:

```text
build/bin/             arquivos objeto
build/dependencies/    arquivos de dependencias
build/<projeto>.exe    executavel
logs/cbuild.log        historico dos comandos
```
