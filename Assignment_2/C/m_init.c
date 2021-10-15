/*
* int M_Init(int size):
	The purpose of M_Init() is to initialize your memory allocator.
	The calling program should invoke it only once.
	It takes as its argument the size of the memory space (in bytes) that your allocator should manage.
		Round this up to the nearest multiple of 16 bytes. 			[Complete]
		You must then use mmap() to request this space from the OS.
	The function should return 0 on success and -1 for a failure return.

*/
#include "M_Init.h"

int M_Init(int size)
{
    printf("Function called\n");
    if (freeList != NULL) //freeList should be null on the first call.
    {
        printf("Failure: M_Init was called twice!\n");
        return -1;
    }
    //Round up to the nearest multiple of 16.
    int memChunks = size/16;
    if (size%16 != 0)
    {
        memChunks++;
    }
    memChunks = memChunks * 16;

    printf("using mmap.\n");


    //Create the mmap space for storing nodes.
    freeList = mmap((void *) 0xdead0000, memChunks, PROT_READ |
                                         PROT_WRITE, MAP_ANON | MAP_SHARED, -1, 0);

    if(freeList == MAP_FAILED) //Check and report failure to allocate.
    {
        printf("Mapping Failed\n");
        return -1;
    }
    //Define global variables for magic number, and the total size of freeList.
    magicNumber = (void *) 123456789;
    freeListSize = (int)(memChunks - (sizeof(memStruct)));

    printf("Global variables declared.\n");

    //Define the first header.
    memStruct *list = freeList;
    list->memptr = magicNumber;
    list->size = freeListSize;
    //Define the last footer.
    memStruct *end = freeList + (freeListSize-16);
    end->size = 0;
    end->memptr = freeList;

    //Set current at the start of the freeList.
    currentBlock = freeList;

    printf("Returning 0.\n");
    return 0;
}



int main(int argc, char *argv[])
{
    int givenSize = 4002;
    printf("Given size: %d\n",givenSize);
    M_Init(givenSize);


    memStruct *header = freeList;
    memStruct *footer = freeList + freeListSize - 16;

    printf("FreeListSize = %d\n",freeListSize);
    printf("FreeList Start: %p\n",freeList);

    printf("FreeList header -- size: %lu\n",header->size);
    printf("FreeList header -- pointer: %p\n",header->memptr);

    printf("FreeList footer -- size: %lu\n",footer->size);
    printf("FreeList footer -- pointer: %p\n",footer->memptr);

    printf("FreeList current -- Starting address: %p\n",currentBlock);
    printf("FreeList current -- size: %lu\n",currentBlock->size);
    printf("FreeList current -- pointer: %p\n",currentBlock->memptr);

    return 0;
}

