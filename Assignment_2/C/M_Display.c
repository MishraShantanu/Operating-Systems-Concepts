/*
Assignment 2 Part C.

Computer Science 332.3
Prof: Dr. Derek Eager
University of Saskatchewan - Arts & Science
	Department of Computer Science
A project by: Spencer Tracy | Spt631 | 11236962 and Shantanu Mishra | Shm572 | 11255997
__________________________________________________
 */


#include <stdio.h>
#include "M_Init.h"


/* PURPOSE: To print to the console each block stored in freeList [Defined in M_Init].
 * PRE-CONDITIONS: freeList cannot be null.
 *                 M_Init must have already been called by program.
 * POST-CONDITIONS: Blocks of memory and their size are printed to the console.
 * RETURN: None.
 */
void M_Display()
{
    if (freeList == NULL)
    {
        printf("Failure! M_Init has not been called yet.\n");
        return;
    }

    int nodeNumber = 1;
    memStruct *cur = freeList;
    printf("\nM_Display triggered. \n"
           "Freelist total size: %lu\n"
           "Freelist starts at %p and ends at %p\t\t All blocks have 32-bytes for header and footer.\n",
        freeListSize,freeList,freeList+freeListSize);

    while (cur->size != 0)
    {
        if (cur->memptr == magicNumber)
        {
            if ((void*)cur + cur->size > freeList + freeListSize-16)
                printf("\tFREE block %d: %p --> %p [due to size %lu]\n",
                       nodeNumber,cur,(void*)cur + cur->size,cur->size);
            else
                printf("\tFREE block %d: %p --> %p [due to size %lu]\n",
                       nodeNumber,cur,(void*)cur + cur->size+32,cur->size);
        }
        else
        {
            printf("\tBlock %d: %p --> %p [due to size %lu]\n",nodeNumber,cur,(void*)cur->memptr,cur->size);
        }
        cur = (void*) cur + (cur->size+32);
        nodeNumber++;
    }
}
