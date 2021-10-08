//
// Created by Spencer on 2021-10-07.
//
#include <sys/mman.h>
#include <stdio.h>
#include <stdlib.h>
#include "M_Init.h"
#include "M_Alloc.h"


int main(int argc, char *argv[])
{
    int givenSize = 4002;
    if (M_Init(givenSize) == 1)
    {
        printf("Initialization of M_Init failed!");
        return 1;
    }

    void *ptr = (void *) 0xdeadbeaf;
    printf("what happens?  %p\n",ptr);
    //printf("location of code : %p\n", main);
    printf("location of heap : %p\n", malloc(100e6));
    int x = 3;
    printf("location of stack: %p\n", &x);

    //printf("mapfile in test: %d\n",MAP);
    M_Alloc(givenSize/2);
    return 0;
}
