//
// Created by Spencer on 2021-10-13.
//
#include <stdio.h>
#include "M_Init.h"

void M_Display()
{
    int nodeNumber = 1;
    memStruct *cur = freeList;
    void* endAddress = (void*)freeList+freeListSize;
    printf("M_Display triggered.\n");

    printf("Freelist total size: %d\n",freeListSize);
    printf("Freelist ends at %p\n", freeList+freeListSize);

    while (cur->memptr != magicNumber)
    {
        printf("Block %d: %p with a hard limit at %p [due to size %lu]\n",nodeNumber,cur,(void*)cur->memptr - 16,cur->size);
        cur = cur->memptr;
        nodeNumber++;
    }



    printf("Block %d is FREE from %p to end of free list [%p]\n",nodeNumber,cur,endAddress);

    //printf("End of freeList at address: %p\n",freeList + ((void*)freeList+total - (void*)cur));

    //printf("Block %d: %p with a hard limit at %p [due to size %d]\n",nodeNumber,cur,(int*)(freeList - cur + cur->totalSize),cur->size);
    //printf("post: cur %p",cur);

}
