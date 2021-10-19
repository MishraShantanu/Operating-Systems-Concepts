//
// Created by Spencer on 2021-10-14.
//

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

    if (pointer == NULL)
    {
        printf("M_Free given a null pointer! Failure.\n");
        return -1;
    }
    //memStruct *next = pointer + current->size;
    memStruct *currentHeader = pointer-16;
    memStruct *currentFooter = pointer + currentHeader->size;


    memStruct *prevBlockFooter = NULL;
    memStruct *prevBlockHeader = NULL;


    if (pointer - 16 == freeList)
    {
        memStruct *endBlockFooter = (void*)freeList+freeListSize - 16;
        prevBlockFooter = (void*)endBlockFooter;
        prevBlockHeader = (void*)endBlockFooter - endBlockFooter->size;
        //prevBlockHeader = endBlockFooter - endBlockFooter->size;
    }
    else
    {
        prevBlockFooter = pointer-32;
        prevBlockHeader = pointer-32 - (prevBlockFooter->size + 16);
    }


    memStruct *nextBlockHeader = pointer + currentHeader->size + 16;
    memStruct *nextBlockFooter = (void*) nextBlockHeader + (nextBlockHeader->size) +16;

    //printf("\tFor block %p --> %p [due to size %lu]\n",currentHeader,(void*)currentHeader + currentHeader->size,currentHeader->size);


    if (nextBlockHeader->memptr == magicNumber) //Next block is free. Combine with next block.
    {
//        printf("\tNEXT is FREE:  block %p --> %p [due to size %lu]\n",nextBlockHeader,(void*)nextBlockHeader + nextBlockHeader->size,nextBlockHeader->size);
        long unsigned combinedSize = currentHeader->size + nextBlockHeader->size+32;
        currentHeader->size = combinedSize;
        currentHeader->memptr = nextBlockHeader->memptr;
        nextBlockFooter->size = combinedSize;
    }
    else
    {
        //printf("\tNEXT is NOT FREE:  block %p --> %p [due to size %lu]\n",nextBlockHeader,(void*)nextBlockHeader + nextBlockHeader->size,nextBlockHeader->size);
    }



    if (prevBlockHeader->memptr == magicNumber)
    {
        long unsigned combinedSize = currentHeader->size + prevBlockHeader->size+32;
        //printf("\tPREV is FREE:  block %p --> %p [due to size %lu]\n",prevBlockHeader,(void*)prevBlockHeader + prevBlockHeader->size,prevBlockHeader->size);

        prevBlockHeader->memptr = currentHeader->memptr;
        prevBlockHeader->size = combinedSize;

        nextBlockFooter->size = combinedSize;
        nextBlockFooter->memptr = prevBlockFooter;
    }
    else
    {
        //printf("\tPREV is NOT FREE:  block %p --> %p [due to size %lu]\n",prevBlockHeader,(void*)prevBlockHeader + prevBlockHeader->size,prevBlockHeader->size);
    }



            //Combine size, adjust pointers.
        //Is prev free?
            //Combine size, adjust pointers/
    //Do I need a separate case for when both? Or can I just solve this in two if else statements?

    currentHeader->memptr = magicNumber;
    currentFooter->memptr = magicNumber;



    return 0; //return 1 on fail.
}