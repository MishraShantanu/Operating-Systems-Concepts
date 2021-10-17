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

    long unsigned currentSize = currentBlock->size;


    //Detect header and footer.
    memStruct *header = (void*) currentBlock;
    memStruct *footer = (void*) currentBlock + 16 + memChunks; //Move past the header + allocated length of node.

    header->size = memChunks; //Size of this block.
    footer->size = memChunks;
    header->memptr = (void*)currentBlock + 32 + memChunks; //Point to next header. [past head, past node, past footer].

    //Set footer values:


    if (currentBlock != freeList) //Do this unless we're on the first block.
    {
        footer->memptr = (void*)currentBlock-16; //Point to previous footer.
    }
    else //Link to the end of the freeList.
    {
        footer->memptr = (void*)freeList+ (freeListSize-16);
    }
    void* out = (void*)currentBlock;

    currentBlock = (void*)currentBlock + 32 + memChunks; //Move to the next header space.
    currentBlock->memptr = magicNumber; //Mark this area as unallocated.
    currentBlock->size = currentSize - (memChunks + 32); //Subtract the size of this entire node from following freespace.

    return out+16;
}
