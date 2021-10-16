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
    memStruct *current = pointer-16;
    memStruct *next = pointer + current->size + 16;
    memStruct *prev = pointer-32;
    printf("\nYOU WANT TO CLEAR:\t\t%p --> %p [due to size %lu]\n",current,current->memptr,current->size);



//    printf("\nYOU WANT TO CLEAR:\t\t%p --> %p [due to size %lu]\n",current,current->memptr,current->size);
//    printf("  NEXT BLOCK:\t\t\t%p --> %p [due to size %lu]\n",next, next->memptr,next->size);
//
//    if (current != freeList)
//    {
//        memStruct *prev = pointer-32;
//        prev = prev->memptr;
//        printf("  PREVIOUS BLOCK:\t\t%p --> %p [due to size %lu]\n",prev, prev->memptr,prev->size);
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