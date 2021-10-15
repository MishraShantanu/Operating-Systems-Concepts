//
// Created by Spencer on 2021-10-14.
//

//#include "M_Free.h"
//
//
//int M_Free(void *pointer)
//{
//    node_t *block = pointer;
//    printf("Free is triggered on block:    %p with a hard limit at %p [due to size %d]\n",block, block->next,block->size);
//
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
//
//    return 0; //return 1 on fail.
//}