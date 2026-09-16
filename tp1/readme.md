# PROBLEMAS ENCONTRADOS
## (Iago) Como seria a árvore de dependência de um .c para identificação dos arquivos relacionados a ele
- Dado um .c específico, como eu identificaria todos os arquivos relacionados a ele uma vez que somente o header não basta,
já que a implementação de funções que 1.c usa, a partir da declaração do header, pode estar em 2.c que não tem menção alguma ao 1.c,
somente as funções utilizadas em 1.c
### Solução:
Não tem que identificar, o linker do gcc faz a compilação em duas etapas, transformando cada arquivo em um .o
e após isso a árvore de dependências para gerar o executável com apenas as dependências necessárias corretamente.

## (Iago) Que parâmetro eu utilizaria para compilação incremental sem ter que fazer logs constantes de compilação
- Uma vez que eu tenho o executável do projeto, como eu sei que ele é o mais atualizado em relação à todas as suas dependências, sem ter que criar diversos logs para cada uma delas
### Solução:
Não precisa criar vários logs