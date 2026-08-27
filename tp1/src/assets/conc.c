#include "../progConc.h"

/*----------------------------------------------------------------------------*/

typedef struct threadArgs {
    int start, qtd, threadId;
} threadArgs;

typedef struct threadRetVal {
    int threadId, isSuccessful;
} threadRetVal;

/*----------------------------------------------------------------------------*/

void *multiplicarMatrizes(void *arg);

/*----------------------------------------------------------------------------*/

matriz matriz1, matriz2, matrizResultado;

int main(int argc, char **argv) {
    double inicio, inicializacao, execucao, gravacao, finalizacao;
    int cont, T, div, mod, N;
    FILE *arquivo, *registro;
    threadArgs *threadArg;
    pthread_t *threads;
    

    if((registro = fopen("registro.csv", "a")) == NULL) {
        puts("\033[31mNão foi possível abrir o arquivo para leitura [main L16]\033[m");
        exit(-2);
    }

    GET_TIME(inicio); /*------------------------------------------------------*/

    if(argc < 5) {
        /* TODO: ajustar número da linha */
        puts("\033[31mQuantidade de argumentos inválida [main L]\033[m");
        puts("\033[33mFormato esperado: <Threads> <Arquivo de entrada> <Arquivo de entrada> <Arquivo de saída>\033[m");
        exit(-1);
    }

    T = atoi(argv[1]);
    threads = initThreadArray(T);

    if((arquivo = fopen(argv[2], "rb")) == NULL) {
        puts("\033[31mNão foi possível abrir o arquivo para leitura [main L16]\033[m");
        exit(-2);
    }
    fread(&matriz1.linhas, sizeof(int), 1, arquivo);
    fread(&matriz1.colunas, sizeof(int), 1, arquivo);
    matriz1.vetor = mallocMem(sizeof(float) * matriz1.linhas * matriz1.colunas);
    fread(matriz1.vetor, sizeof(float), matriz1.linhas * matriz1.colunas, arquivo);

    if((arquivo = fopen(argv[3], "rb")) == NULL) {
        puts("\033[31mNão foi possível abrir o arquivo para leitura [main L16]\033[m");
        exit(-2);
    }
    fread(&matriz2.linhas, sizeof(int), 1, arquivo);
    fread(&matriz2.colunas, sizeof(int), 1, arquivo);
    matriz2.vetor = mallocMem(sizeof(float) * matriz2.linhas * matriz2.colunas);
    fread(matriz2.vetor, sizeof(float), matriz2.linhas * matriz2.colunas, arquivo);

    if(matriz1.colunas != matriz2.linhas) {
        printf("\033[33mNão é possível multiplicar uma matriz %dx%d por uma %dx%d\033[m\n", matriz1.linhas, matriz1.colunas, matriz2.linhas, matriz2.colunas);
        exit(-36);
    }

    N = matriz1.linhas;
    if(T > N) T = N;
    div = N / T;
    mod = N % T;
    N = 0;

    GET_TIME(inicializacao); /*-----------------------------------------------*/

    matrizResultado.linhas = matriz1.linhas;
    matrizResultado.vetor = mallocMem(sizeof(float) * matriz1.linhas * matriz2.colunas);
    matrizResultado.colunas = matriz2.colunas;

    for(cont = 0 ; cont < T ; cont += 1) {
        threadArg = mallocMem(sizeof(threadArgs));

        threadArg->start = N;
        threadArg->threadId = cont;
        threadArg->qtd = div + (cont < mod);
        N += threadArg->qtd;

        initThread(&threads[cont], multiplicarMatrizes, threadArg);
    }

    for(cont = 0 ; cont < T ; cont += 1) {
        if(pthread_join(threads[cont], NULL)) {
            printf("--ERRO: pthread_join() da thread %d\n", cont); 
        }
    }

    GET_TIME(execucao); /*----------------------------------------------------*/

    if((arquivo = fopen(argv[4], "wb")) == NULL) {
        puts("\033[31mNão foi possível criar o arquivo para escrita [main L16]\033[m");
        exit(-2);
    }
    fwrite(&matrizResultado.linhas, sizeof(int), 1, arquivo);
    fwrite(&matrizResultado.colunas, sizeof(int), 1, arquivo);
    fwrite(matrizResultado.vetor, sizeof(float), matrizResultado.linhas * matrizResultado.colunas, arquivo);

    GET_TIME(gravacao); /*----------------------------------------------------*/

    free(matriz1.vetor);
    free(matriz2.vetor);
    free(matrizResultado.vetor);
    if(fclose(arquivo)) { 
        puts("\033[31mErro ao fechar o arquivo\033[m");
        exit(-3);
    }

    GET_TIME(finalizacao); /*-------------------------------------------------*/

    fprintf(registro, "%d,%d,%f,%f,%f,%f\n",
        matrizResultado.linhas,
        T,
        inicializacao - inicio,
        execucao - inicializacao,
        gravacao - execucao,
        finalizacao - gravacao
    );

    if(fclose(registro)) { 
        puts("\033[31mErro ao fechar o arquivo\033[m");
        exit(-3);
    }

    return 0;
}

/*----------------------------------------------------------------------------*/

void *multiplicarMatrizes(void *arg) {
    threadArgs *threadArg = (threadArgs *) arg;
    int cont, cont2, cont3;

    for(cont = threadArg->start ; cont < threadArg->qtd + threadArg->start ; cont += 1) {
        for(cont2 = 0 ; cont2 < matriz2.colunas ; cont2 += 1) {
            matrizResultado.vetor[cont * matriz2.colunas + cont2] = 0;

            for(cont3 = 0 ; cont3 < matriz1.colunas ; cont3 += 1) {
                matrizResultado.vetor[cont * matriz2.colunas + cont2] += matriz1.vetor[cont * matriz1.colunas + cont3] * matriz2.vetor[cont3 * matriz2.colunas + cont2];
            }
        }
    }

    return NULL;
}