//
// Created by Spencer on 2021-10-14.
//

#include "M_Free.h"


int M_Free(void *pointer)
{
    memStruct *header = pointer-16; //Step back to the header for the current block.
    memStruct *footer = pointer + header->size;
    printf("\n\n\nFree is triggered on block[header]:    %p with a hard limit at %p [due to size %lu]\n",header,header->memptr,header->size);


    //CHECK THE HEADER:
    if (header->memptr->memptr == magicNumber)    //Is next a magic number?
    {
        printf("There is free space after the node!\n");
    }
    else
    {
        printf("next is not a magic number!\n");
    }

    //CHECK FOOTER:
    //printf("block[footer]:    %p with a hard limit at %p [due to size %lu]\n",footer, footer->memptr,footer->size);


    memStruct *endList = freeList + (freeListSize-16);



    if (footer->memptr == magicNumber)
    {
        printf("footer address: %p   footer size: %lu  \n",footer,footer->size);
        printf("footer + size = %p\n", (void*) footer + footer->size);
        printf("endlist address: %p   endlist size: %lu \n",endList, endList->size);
    }


    //printf("END LIST IS AT: %p\n",endList);

    if (footer->memptr == magicNumber)    //Is prev a magic number?
    {
        printf("There is free space before the node!\n");
    }
    else
    {
        printf("prev is not a magic number!\n");
    }
//    //Check for coalescing.
//    if (block->prev != magicNumber && block->next != magicNumber) //Nothing free above and below. Leave as is.
//    {
//        printf("Prev and next block are not free.\n");
//        printf("Previous block: %p with a hard limit at %p [due to size %d]\n", block->prev, block, block->prev->size);
//        printf("Next block: %p with a hard limit at %p [due to size %d]\n",block->next,(void*)block->next + block->next->size,block->next->size);
//        block->prev->next = magicNumber;
//        block->next->prev = magicNumber;
//    }
//    //else if (block->prev != magicNumber || block->next->size == 0) // Combine cur with prev as one big free node.
//    else if (block->prev != magicNumber || block->next->size == 0) // Combine cur with prev as one big free node.
//    {
//        printf("Prev block is NULL, next is not.\n");
//        printf("Next block: %p with a hard limit at %p [due to size %d]\n",block->next,(void*)block->next + block->next->size,block->next->size);
//        block->prev->next = block->next;
//
//    }
//    else //Combine cur with next as one big free node.
//    {
//        printf("Next block is NULL, prev is not.\n");
//        printf("Previous block: %p with a hard limit at %p [due to size %d]\n", block->prev, block, block->prev->size);
//        block->next = block->next->next;
//    }
//

    return 0; //return 1 on fail.
}