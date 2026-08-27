#include "./progConc.h"

void *generateRandNumberArray(int qtt, char* numberType, int fator) {
    int cont;
    void *numberArray;

    if(!strcmp(numberType, "float")) {
        if((numberArray = malloc(sizeof(float) * qtt)) == NULL) {
            puts("\033[31mNão foi possível alocar o vetor de float [generateIntArray L8]\033[m");
            exit (-18);
        }

        for(cont = 0 ; cont < qtt ; cont += 1) {
            ((float *)numberArray)[cont] = ((float)rand() / (float)RAND_MAX) * fator;
        }
    }
    else if(!strcmp(numberType, "int")) {
        if((numberArray = malloc(sizeof(int) * qtt)) == NULL) {
            puts("\033[31mNão foi possível alocar o vetor de int [generateIntArray L18]\033[m");
            exit (-118);
        }

        for(cont = 0 ; cont < qtt ; cont += 1) {
            ((int *)numberArray)[cont] = (rand() / RAND_MAX) * fator;
        }
    }
    else if(!strcmp(numberType, "double")) {
        if((numberArray = malloc(sizeof(double) * qtt)) == NULL) {
            puts("\033[31mNão foi possível alocar o vetor de double [generateIntArray L28]\033[m");
            exit (-128);
        }

        for(cont = 0 ; cont < qtt ; cont += 1) {
            ((double *)numberArray)[cont] = ((double)rand() / (double)RAND_MAX) * fator;
        }
    }
    else {
        puts("Tipo de número desconhecido [generateRand]");
        exit(-38);
    }

    return numberArray;
}

/*----------------------------------------------------------------------------*/

void initThread(pthread_t *threadLocal, void *threadFunction(void *arg), void* args) {
    if(pthread_create(threadLocal, NULL, threadFunction, args)) {
        puts("\033[31mNão foi possível instaciar uma nova thread [initThreads L2]\033[m");
        exit(-22);
    }
}

/*----------------------------------------------------------------------------*/

pthread_t *initThreadArray(int size_arr) {
    pthread_t *threads;

    if((threads = malloc(sizeof(pthread_t) * size_arr)) == NULL) {
        puts("\033[31mNão foi possível inicializar o array de threads [initThreadArray L4]\033[m");
        exit(-34);
    }

    return threads;
}

/*----------------------------------------------------------------------------*/

void *allocMem(size_t size, size_t qtt, char *alloc_type, void *oldPointer) {
    void *newPointer;

    if(qtt <= 0) {
        puts("\033[31;1mQuantidade inválida de elementos\033[m");
        return NULL;
    }

    if(!strcmp(alloc_type, "malloc")) {
        if((newPointer = malloc(size * qtt)) == NULL) {
            puts("\033[31mNão foi possível alocar o espaço de memória\033[m");
            exit(-45);
        }
    }
    else if(!strcmp(alloc_type, "calloc")) {
        if((newPointer = calloc(qtt, size)) == NULL) {
            puts("\033[31mNão foi possível alocar o espaço de memória\033[m");
            exit(-45);
        }
    }
    else if(!strcmp(alloc_type, "realloc")) {
        if((newPointer = realloc(oldPointer, size * qtt)) == NULL) {
            puts("\033[31mNão foi possível alocar o espaço de memória\033[m");
            exit(-45);
        }
    }
    else {
        puts("\033[31;1mOpção inválida [allocMem]");
        exit(-1);
    }

    return newPointer;
}

/*----------------------------------------------------------------------------*/

void printMatriz(matriz *matriz) {
    int cont, cont2;

    printf("Linhas: %d\nColunas: %d\n", matriz->linhas, matriz->colunas);
    for(cont = 0 ; cont < matriz->linhas ; cont += 1) {
        for(cont2 = 0 ; cont2 < matriz->colunas ; cont2 += 1) {
            printf("%f ", matriz->vetor[(cont * matriz->colunas) + cont2]);
        }
        puts("");
    }
    puts("");
}