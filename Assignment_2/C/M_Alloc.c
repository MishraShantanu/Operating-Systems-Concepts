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
    long unsigned memChunks = size/16;
    if (size%16 != 0)
    {
        memChunks++;
    }
    memChunks = memChunks * 16;



    //Check for magic number:
//    if (currentBlock->memptr == magicNumber)
//    {
//        printf("Current block [%p with size %lu] "
//               "points to magic number\n",currentBlock,currentBlock->size);
//    }
//    else
//    {
//        printf("Current block [%p with size %lu] DOES NOT point to magic number! "
//               "(points to: [%p with size %lu])!\n",currentBlock,currentBlock->size,currentBlock->memptr,currentBlock->memptr->size);
//        if (currentBlock->memptr->size == 0)
//        {
//            printf("END OF LIST REACHED");
//            return NULL;
//        }
//    }


    printf("Current address: [%p] size: [%lu]  points to:[%p]\n",currentBlock,currentBlock->size,currentBlock->memptr);


    //Create a new block.

    //Header:
    memStruct *header = (void*) currentBlock;

    //Footer:
    memStruct *footer = (void*) currentBlock + 16 + memChunks; //Move past the header + allocated length of node.

    //Set footer values:
    footer->size = currentBlock->size - (memChunks + 16); //Subtract size of node + room for footer from the free space.
    footer->memptr = currentBlock;

    //Set header values.
    header->size = memChunks;
    //header->memptr = currentBlock + memChunks;
    header->memptr = footer;


    //footer->size = currentBlock->size - memChunks;



    printf("Header address: [%p] size: [%lu]  points to:[%p]\n",header,header->size,header->memptr);
    printf("Footer address: [%p] size: [%lu]  points to:[%p]\n\n",footer,footer->size,footer->memptr);


//    currentBlock->size = memChunks; //How big is the new block?
//    currentBlock->memptr = currentBlock + memChunks; //Where is next header?
//
    //currentBlock->memptr->memptr = magicNumber; //Next's header should be a magic number.
//    currentBlock->memptr->size = memChunks;

    void* out = currentBlock;
    currentBlock = currentBlock->memptr;
    currentBlock->memptr = magicNumber;
    return out+16;
    //return out+16;
}
//
//int main(int argc, char *argv[])
//{
//
//    M_Init(1590);
//    M_Alloc(30);
//    return 0;
//}