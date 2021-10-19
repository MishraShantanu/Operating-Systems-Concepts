/*
Assignment 2 Part C.

Computer Science 332.3
Prof: Dr. Derek Eager
University of Saskatchewan - Arts & Science
	Department of Computer Science
A project by: Spencer Tracy | Spt631 | 11236962 and Shantanu Mishra | Shm572 | 11255997
__________________________________________________
 */


#include "M_Init.h"


/* PURPOSE: Initialize a new memory allocator (via mmap).
 * PRE-CONDITIONS: size -- the size (in bytes) you wish to initialize the allocator with.
 *                 M_Init can only be called once.
 * POST-CONDITIONS: Virtual memory is allocated via mmap, global variables initialized.
                        * (freeList, freeListSize, magicNumber, currentBlock).
 * RETURN: 0 on successful call to mmap and allocation. -1 on failure.
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
    if (size%16 != 0) memChunks++;
    memChunks = memChunks * 16;

    //Create the mmap space for storing nodes.
    //   freeList = mmap((void *) 0xdead0000,    //<-- EXTREMELY useful for debugging!!
    freeList = mmap(NULL,
                    memChunks  + (2*sizeof(memStruct)),
                    PROT_READ |PROT_WRITE, MAP_ANON | MAP_SHARED,
                    -1, 0);
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

    //Define the last footer -- loop it back to the first block.
    memStruct *end = freeList + (freeListSize);
    end->size = 0;
    end->memptr = freeList;

    //Set current at the start of the freeList.
    currentBlock = freeList;

    return 0;
}
