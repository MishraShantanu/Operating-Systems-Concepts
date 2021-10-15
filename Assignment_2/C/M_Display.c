//
// Created by Spencer on 2021-10-13.
//
#include <stdio.h>
#include "M_Init.h"

void M_Display()
{
    int nodeNumber = 1;
    node_t *cur = freeList;
    int total = freeList->totalSize;
    void* endAddress = (void*)freeList+total;
    printf("M_Display triggered.\n");

    printf("Freelist total size: %d\n",freeList->totalSize);
    printf("Freelist ends at %p\n", (void*)freeList+total);

    while (cur->next != magicNumber)
    {
        printf("Block %d: %p with a hard limit at %p [due to size %d]\n",nodeNumber,cur,cur->next,cur->size);
        cur = cur->next;
        nodeNumber++;
    }



    printf("Block %d is FREE from %p to end of free list [%p]\n",nodeNumber,cur,endAddress);

    //printf("End of freeList at address: %p\n",freeList + ((void*)freeList+total - (void*)cur));

    //printf("Block %d: %p with a hard limit at %p [due to size %d]\n",nodeNumber,cur,(int*)(freeList - cur + cur->totalSize),cur->size);
    //printf("post: cur %p",cur);

}
