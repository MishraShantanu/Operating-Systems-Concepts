//
// Created by Spencer on 2021-10-14.
//

#include "M_Free.h"


int M_Free(void *pointer)
{

    int total = freeList->totalSize;

    //Get size.
    node_t *block = pointer;
    //(int)((freeList->current + memChunks) - freeList->current))
    //(int)((block + blockSize) - block))
    int blockSize = block->size;
    printf("Free is triggered on block:    %p with a hard limit at %p [due to size %d]\n",block, block->next,block->size);

    //Check for coalescing.

        //Is the space before free?
    if (block->prev == NULL)
    {
        printf("PREVIOUS BLOCK IS NULL.\n");
    }
    else
    {
        printf("\nPREVIOUS BLOCK IS NOT NULL.\n");
        printf("Previous block: %p with a hard limit at %p [due to size %d]\n", block->prev, block, block->prev->size);
    }
        //Is the space after free?
    if (block->next == NULL)
    {
        printf("NEXT BLOCK IS NULL.\n");
    }
    else
    {
        printf("\nNEXT BLOCK IS NOT NULL.\n");
        printf("Next block: %p with a hard limit at %p [due to size %d]\n",block->next,(void*)block->next + block->next->size,block->next->size);
    }

    return 0; //return 1 on fail.
}