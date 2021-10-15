/*
 void *M_Alloc(int size):
	M_Alloc() is used to allocate a chunk;
		its argument is the requested size in bytes.

	The function should return a pointer to the start of the allocated chunk, or NULL if the request fails,
			e.g. satisfying the request is not possible owing to there not being enough contiguous free space.

	The actual size of the allocated chunk should be size rounded up to the nearest multiple of 16 bytes.

	Allocation should use the next fit policy.
 */

#include "M_Alloc.h"


void *M_Alloc(int size)
{
    int memChunks = size/16;
    if (size%16 != 0)
    {
        memChunks++;
    }
    memChunks = memChunks * 16;

    //Create a new block.

    currentBlock->size = memChunks;
    //printf("Size ought to be: %d\n",(int)((freeList->current + memChunks) - freeList->current));

    freeList->current->next = (void*) freeList->current + freeList->current->size;
    freeList->current->next->next = magicNumber;

    void *out = freeList->current;
    freeList->current = freeList->current->next;
    freeList->current->prev = out;
    return out;
}