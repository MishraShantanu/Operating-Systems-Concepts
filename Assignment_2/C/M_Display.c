//
// Created by Spencer on 2021-10-13.
//
#include <stdio.h>
#include "M_Init.h"


/* PURPOSE: To print to the console each block stored in freeList [Defined in M_Init].
 * PRE-CONDITIONS: freeList cannot be null.
 * POST-CONDITIONS: Blocks of memory and their size are printed to the console.
 * RETURN: None.
 */
void M_Display()
{
    int nodeNumber = 1;
    memStruct *cur = freeList;
    void* endAddress = (void*)freeList+freeListSize;
    printf("\nM_Display triggered.\n"
           "Freelist total size: %d\n"
           "Freelist starts at %p and ends at %p\n",
        freeListSize,freeList,freeList+freeListSize);

    while (cur->size != 0)
    {
        //printf("\tCurr %d: %p --> %p [due to size %lu]\n",nodeNumber,cur,(void*)cur->memptr,cur->size);

        if (cur->memptr == magicNumber)
        {
            printf("\tFREE block %d: %p --> %p [due to size %lu]\n",nodeNumber,cur,(void*)cur + cur->size,cur->size);

        }
        else
        {
            printf("\tBlock %d: %p --> %p [due to size %lu]\n",nodeNumber,cur,(void*)cur->memptr,cur->size);
        }
        cur = (void*) cur + cur->size+32;
        //printf("New cur: %p\n",cur);
        nodeNumber++;
    }

    //printf("\tBlock %d is FREE from %p to end of free list [%p]\n",nodeNumber,cur,endAddress);

}
