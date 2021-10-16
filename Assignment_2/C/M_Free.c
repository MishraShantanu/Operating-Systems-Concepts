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
    memStruct *header = pointer-16; //Step back to the header for the current block.
    memStruct *footer = pointer + header->size;

    printf("\nblock[header]:    %p --> %p [due to size %lu]\n",header,header->memptr,header->size);
    printf("block[footer]:    %p --> %p [due to size %lu]\n",footer, footer->memptr,footer->size);


    if (header->memptr->memptr != magicNumber)
        printf("There is NOT free space after the node!\n");
    else
        printf("There is free space after the node!\n");


    if (footer->memptr != magicNumber || (void*) footer + (footer->size) == freeList + freeListSize)
        printf("There is NOT free space before the node!\n");
    else
        printf("There is free space before the node!\n");


    return 0; //return 1 on fail.
}