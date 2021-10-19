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

    //printf("Current address: [%p] size: [%lu]  points to:[%p]\n",currentBlock,currentBlock->size,currentBlock->memptr);

    long unsigned currentSize = currentBlock->size;

    //Check: Does the current node have enough space for this?
    if (currentBlock->memptr != magicNumber) //Is this block already allocated?
    {
        printf("ERROR! THIS BLOCK IS ALREADY ALLOCATED.\n");
    }

    if (currentSize < (memChunks +32)) //If the current block can't fit this node, can any?
    {
        printf("ERROR! %d requested but current block only has %lu space left.\tTraversing the list...\n",size,currentSize);
        printf("STARTING BLOCK: %p --> %p [due to size %lu]\n",currentBlock,(void*)currentBlock->memptr,currentBlock->size);

        //memStruct *walker = (void*) currentBlock + (currentBlock->size +32);
        memStruct *walker = currentBlock;
        int success = 0;
        do
        {
            if (walker->size == 0)
            {
                printf("END OF LIST, RESETTING\n");
                walker = (void*) freeList;
            }
            else if (walker->size >= memChunks+32 && walker->memptr == magicNumber)
            {
                currentBlock = (void*) walker;
                success = 1;
                printf("MATCH FOUND! yay: %p --> %p [due to size %lu]\n",walker,(void*)walker->memptr,walker->size);

            }
            else
            {
                printf("TRAVERSE: %p --> %p [due to size %lu]\n",walker,(void*)walker->memptr,walker->size);
                walker = (void*) walker + (walker->size +32);
            }
        }while (walker != (void*) currentBlock);
        if (success != 1)
        {
            printf("No suitable block found for the request of %d bytes. Sorry!\n",size);
            return NULL;
        }
    }

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

    currentBlock = (void*)currentBlock + (32 + memChunks); //Move to the next header space.
    if ((void*) currentBlock < (void*) freeList + freeListSize)
    {
        currentBlock->memptr = magicNumber; //Mark this area as unallocated.
        currentBlock->size = currentSize - (memChunks + 32); //Subtract the size of this entire node from following freespace.
    }
    //else printf("oof");


    //Check size of wanted block vs size of current.
        //Iterate through blocks until entire list, or insert succeeds.


    return out+16;
}
