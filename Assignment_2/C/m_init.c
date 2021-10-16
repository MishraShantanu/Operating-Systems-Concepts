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

/* PURPOSE:
 * PRE-CONDITIONS:
 * POST-CONDITIONS:
 * RETURN:
 */
int M_Init(int size)
{
    //Error detection: User called M_Init more than once.
    if (freeList != NULL)
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
    freeListSize = memChunks;

    //Define the first header.
    memStruct *head = freeList;
    head->memptr = magicNumber;
    head->size = freeListSize;

    //Define the last footer.
    memStruct *end = freeList + (freeListSize);
    end->size = 0;
    end->memptr = freeList;

    //Set current at the start of the freeList.
    currentBlock = freeList;

    return 0;
}
