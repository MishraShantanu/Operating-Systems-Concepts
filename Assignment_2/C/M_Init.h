//
// Created by Spencer on 2021-10-07.
//

#ifndef M_INIT_H
#define M_INIT_H

#include <sys/mman.h>
#include <stdio.h>



typedef struct memStruct
{
    unsigned long size;
    struct memStruct* memptr;
}memStruct;

void* freeList;
unsigned long freeListSize;
void* magicNumber;
memStruct* currentBlock;

int M_Init(int size);

#endif //M_INIT_H
