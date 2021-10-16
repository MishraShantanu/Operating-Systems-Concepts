#include "M_Alloc.h"

/* PURPOSE: To allocate
 * PRE-CONDITIONS:
 *              int size --> Size (in bytes) you wish to allocate for your data.
 *              Must have called M_Init before using.
 * POST-CONDITIONS: The block of memory at the pointer is cleared and declared writable.
 * RETURN: A void pointer to the writable portion of the newly allocated block.
 */
void *M_Alloc(int size)
{
    long unsigned memChunks = size/16;
    if (size%16 != 0)
    {
        memChunks++;
    }
    memChunks = memChunks * 16;

    printf("Current address: [%p] size: [%lu]  points to:[%p]\n",currentBlock,currentBlock->size,currentBlock->memptr);


    //Detect header and footer.
    memStruct *header = (void*) currentBlock;
    memStruct *footer = (void*) currentBlock + 16 + memChunks; //Move past the header + allocated length of node.

    //Set footer values:
    footer->size = currentBlock->size - (memChunks + 16); //Subtract size of node + room for footer from the free space.
    footer->memptr = currentBlock;
      //Set header values.
    header->size = memChunks;
    header->memptr = footer;


    printf("\tNew header address: [%p] size: [%lu]  points to:[%p]\n",header,header->size,header->memptr);
    printf("\tNew footer address: [%p] size: [%lu]  points to:[%p]\n\n",footer,footer->size,footer->memptr);


    void* out = currentBlock;
    currentBlock = currentBlock->memptr;
    currentBlock->memptr = magicNumber;
    return out+16;
}
