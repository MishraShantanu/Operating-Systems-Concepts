#include "M_Free.h"


/* PURPOSE: Free a given chunk of memory and coalesce if possible.
 * PRE-CONDITIONS:
 *              void *pointer --> Free the block held at this pointer.
 *              pointer cannot be null or outside the allocated memory of mmap [by M_Init].
 * POST-CONDITIONS: The block of memory at the pointer is cleared and declared writable.
 * RETURN: 0 if M_Free was successful, -1 if M_Free failed.
 */
int M_Free(void *pointer)
{
    if (freeList == NULL)
    {
        printf("Failure! M_Init has not been called yet.\n");
        return -1;
    }
    if (pointer == NULL || pointer < freeList || pointer > freeList+freeListSize)
    {
        printf("Failure! M_Free was given an invalid pointer. \n");
        return -1;
    }
    memStruct *currentHeader = pointer-16;
    memStruct *currentFooter = pointer + currentHeader->size;

    memStruct *prevBlockFooter = NULL;
    memStruct *prevBlockHeader = NULL;


    if (pointer - 16 == freeList)
    {
        memStruct *endBlockFooter = (void*)freeList+freeListSize - 16;
        prevBlockFooter = (void*)endBlockFooter;
        prevBlockHeader = (void*)endBlockFooter - endBlockFooter->size;
    }
    else
    {
        prevBlockFooter = pointer-32;
        prevBlockHeader = pointer-32 - (prevBlockFooter->size + 16);
    }

    memStruct *nextBlockHeader = pointer + currentHeader->size + 16;
    memStruct *nextBlockFooter = (void*) nextBlockHeader + (nextBlockHeader->size) +16;

    if (nextBlockHeader->memptr == magicNumber) //Next block is free. Combine with next block.
    {
        long unsigned combinedSize = currentHeader->size + nextBlockHeader->size+32;
        currentHeader->size = combinedSize;
        currentHeader->memptr = nextBlockHeader->memptr;
        nextBlockFooter->size = combinedSize;
    }

    if (prevBlockHeader->memptr == magicNumber)
    {
        long unsigned combinedSize = currentHeader->size + prevBlockHeader->size+32;
        prevBlockHeader->memptr = currentHeader->memptr;
        prevBlockHeader->size = combinedSize;

        nextBlockFooter->size = combinedSize;
        nextBlockFooter->memptr = prevBlockFooter;
    }
    currentHeader->memptr = magicNumber;
    currentFooter->memptr = magicNumber;

    return 0;
}