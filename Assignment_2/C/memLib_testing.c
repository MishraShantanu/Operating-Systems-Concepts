#include <stdio.h>
#include "M_Init.h"


typedef struct
{
    int size;
    int magic;
} footer_t;

int main(int argc, char *argv[])
{

    //Pick an arbitrary size to init, exit if failed.
    if (M_Init(654321) == -1)
    {
        return -1;
    }

    printf("freeList: %d\n",freeList->size);
    printf("freeList next: %p\n",freeList->next);

    printf("Pointer of freeList: %p\n",(int *)freeList);

    freeList->next = freeList+200;
    if ((int*) freeList->next != magicNumber)
    {
        printf("freeList->next has been detected as allocated!\n");
    }
    printf("Pointer of freeList next: %p\n",freeList->next);
    printf("Pointer of freeList prev: %p\n",freeList->prev);
    printf("Pointer of freeList+200: %p\n",freeList+200);

}