#define _POSIX_C_SOURCE 199309L
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>
#include <string.h>

/*----------------------------------------------------------------------------*/

typedef struct matriz {
    int linhas, colunas;
    float *vetor;
} matriz;

/*----------------------------------------------------------------------------*/

#ifndef _CLOCK_TIMER_H
#define _CLOCK_TIMER_H

#define BILLION 1000000000L

/* The argument now should be a double (not a pointer to a double) */
#define GET_TIME(now) { \
   struct timespec time; \
   clock_gettime(CLOCK_MONOTONIC, &time); \
   now = time.tv_sec + time.tv_nsec/1000000000.0; \
}
#endif

/*----------------------------------------------------------------------------*/

void *generateRandNumberArray(int qtt, char* numberType, int fator);

void initThread(pthread_t *threadLocal, void *threadFunction(void *arg), void* args);
pthread_t *initThreadArray(int size_arr);

void *allocMem(size_t size, size_t qtt, char *alloc_type, void *oldPointer);

void printMatriz(matriz *matriz);

/*----------------------------------------------------------------------------*/