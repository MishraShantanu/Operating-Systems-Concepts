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
    //memStruct *next = pointer + current->size;
    memStruct *currentHeader = pointer-16;
    memStruct *currentFooter = pointer + currentHeader->size;


    memStruct *nextBlockHeader = pointer + currentHeader->size + 16;
    memStruct *nextBlockFooter = (void*) nextBlockHeader + (nextBlockHeader->size + 16);



    memStruct *prevBlockFooter = pointer-32;
    memStruct *prevBlockHeader = pointer-32 - (prevBlockFooter->size + 16);


    printf("\n\nROUND 1 BEFORE DELETE!!!!\n");
    printf("  CURRENT BLOCK HEADER:\t\t%p --> %p [due to size %lu]\n",currentHeader,currentHeader->memptr,currentHeader->size);
    printf("  CURRENT BLOCK FOOTER:\t\t%p --> %p [due to size %lu]\n\n",currentFooter,currentFooter->memptr,currentFooter->size);

    printf("  NEXT BLOCK HEADER:\t\t\t%p --> %p [due to size %lu]\n",nextBlockHeader, nextBlockHeader->memptr,nextBlockHeader->size);
    printf("  NEXT BLOCK FOOTER:\t\t\t%p --> %p [due to size %lu]\n\n",nextBlockFooter, nextBlockFooter->memptr,nextBlockFooter->size);

    printf("  PREVIOUS BLOCK HEADER:\t\t%p --> %p [due to size %lu]\n",prevBlockHeader, prevBlockHeader->memptr,prevBlockHeader->size);
    printf("  PREVIOUS BLOCK FOOTER:\t\t%p --> %p [due to size %lu]\n",prevBlockFooter, prevBlockFooter->memptr,prevBlockFooter->size);


    //prevBlockHeader->memptr = magicNumber;
    //nextBlockFooter->memptr = magicNumber;

    currentHeader->memptr = magicNumber;
    currentFooter->memptr = magicNumber;


    printf("\n\nROUND 1 AFTER DELETE!!!!\n");
    printf("  CURRENT BLOCK HEADER:\t\t%p --> %p [due to size %lu]\n",currentHeader,currentHeader->memptr,currentHeader->size);
    printf("  CURRENT BLOCK FOOTER:\t\t%p --> %p [due to size %lu]\n\n",currentFooter,currentFooter->memptr,currentFooter->size);

    printf("  NEXT BLOCK HEADER:\t\t\t%p --> %p [due to size %lu]\n",nextBlockHeader, nextBlockHeader->memptr,nextBlockHeader->size);
    printf("  NEXT BLOCK FOOTER:\t\t\t%p --> %p [due to size %lu]\n\n",nextBlockFooter, nextBlockFooter->memptr,nextBlockFooter->size);

    printf("  PREVIOUS BLOCK HEADER:\t\t%p --> %p [due to size %lu]\n",prevBlockHeader, prevBlockHeader->memptr,prevBlockHeader->size);
    printf("  PREVIOUS BLOCK FOOTER:\t\t%p --> %p [due to size %lu]\n",prevBlockFooter, prevBlockFooter->memptr,prevBlockFooter->size);

    //printf("size of next block: %lu, mempointer of next block header: %p\n",prevBlockHeader->memptr->size,prevBlockHeader->memptr->memptr);

    //printf("Next footer = %p with size %lu --- header at: %p with size:",nextBlockFooter->memptr,nextBlockFooter->memptr->size,(void*)nextBlockFooter->memptr - nextBlockFooter->memptr->size - 16);


//    printf("\nYOU WANT TO CLEAR:\t\t%p --> %p [due to size %lu]\n",current,current->memptr,current->size);
//
//    if (current != freeList)
//    {
//        memStruct *prev = pointer-32;
//        prev = prev->memptr;
//    }
//    else
//    {
//        printf("There is no previous block to clear.\n");
//    }
//



//    if (current->memptr->memptr != magicNumber)
//        printf("There is NOT free space after the node!\n");
//    else
//        printf("There is free space after the node!\n");
//
//
//    if (footer->memptr != magicNumber || (void*) footer + (footer->size) == freeList + freeListSize)
//        printf("There is NOT free space before the node!\n");
//    else
//        printf("There is free space before the node!\n");
//

    return 0; //return 1 on fail.
}