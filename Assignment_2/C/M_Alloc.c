#include "M_Alloc.h"

/* PURPOSE: To allocate a new memory block for use by the caller.
 * PRE-CONDITIONS:
 *              int size --> Size (in bytes) you wish to allocate for your data.
 *              Must have called M_Init before using.
 * POST-CONDITIONS: The block of memory at the pointer is cleared and declared writable.
 * RETURN: A void pointer to the writable portion of the newly allocated block of memory for use.
 */
void *M_Alloc(int size)
{
    if (freeList == NULL) //Special case: User has not called M_Init before trying to allocate memory.
    {
        printf("Failure! M_Init has not been called yet.\n");
        return NULL;
    }

    long unsigned memChunks = size/16;
    if (size%16 != 0) memChunks++;
    memChunks = memChunks * 16;

    long unsigned currentSize = currentBlock->size; //Save me for later (and easier reading).

    //Check if the current block is suitable.
    if (currentSize < (memChunks +32) || currentBlock->memptr != magicNumber) //Fails this test? Start searching.
    {
        memStruct *walker = currentBlock;
        int success = 0;
        do //Check each block -- right size? Free?
        {
            if (walker->size == 0) walker = (void*) freeList; //Hit the end of the freeList? Reset.
            else if (walker->size >= memChunks+32 && walker->memptr == magicNumber) //Win condition.
            {
                currentBlock = (void*) walker;
                success = 1;
            }
            else  walker = (void*) walker + (walker->size +32); //Walk to next block.
        } while (walker != (void*) currentBlock);
        if (success != 1)
        {
            printf("No suitable block found for the request of %d bytes. Sorry!\n",size);
            return NULL;
        }
    }
    //Detect & set header and footer.
    memStruct *header = (void*) currentBlock;
    memStruct *footer = (void*) currentBlock + 16 + memChunks; //Move past the header + allocated length of node.

    header->size = memChunks;
    footer->size = memChunks;
    header->memptr = (void*)currentBlock + 32 + memChunks; //Point to next header. [past head, past block, past footer].

    if (currentBlock != freeList) //Do this unless we're on the very first block.
    {
        footer->memptr = (void*)currentBlock-16; //Point to previous footer.
    }
    else //Link to the end of the freeList.
    {
        footer->memptr = (void*)freeList+ (freeListSize-16);
    }
    void* outputToUser = (void*)currentBlock;
    currentBlock = (void*)currentBlock + (32 + memChunks); //Move to the next header space.
    if ((void*) currentBlock < (void*) freeList + freeListSize) //Make sure we haven't stepped out of freeList bounds.
    {
        currentBlock->memptr = magicNumber; //Mark this area as unallocated.
        currentBlock->size = currentSize - (memChunks + 32); //Subtract size of this block from remaining free-space.
    }
    return outputToUser + 16; //Ensure caller can't overwrite the block's header.
}
