#include <stdio.h>
#include <stdlib.h>
#include "M_Init.h"



typedef struct
{
    int size;
    int magic;
} header_t;

typedef struct
{
    int size;
    int magic;
} footer_t;

int main(int argc, char *argv[])
{

    if (M_Init(4002) == 1)
    {
        exit(1);
    }

    printf("freeList: %d\n",freeList->size);

    printf("Pointer of freeList: %p\n",freeList);
    printf("Pointer of freeList+200: %p\n",freeList+200);

}