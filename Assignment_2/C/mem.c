/*
Assignment 2 Part C.

Computer Science 332.3
Prof: Dr. Derek Eager
University of Saskatchewan - Arts & Science
	Department of Computer Science
A project by: Spencer Tracy | Spt631 | 11236962 and Shantanu Mishra | Shm572 | 11255997
__________________________________________________
 */
 
#include <sys/mman.h> //mmap
#include <stdio.h>

#include "mem.h"

typedef struct memStruct  //Structure for all headers and footers.
{
    unsigned long size;
    struct memStruct* memptr;
}memStruct;

//Global variables relied upon by M_Display, M_Alloc, M_Free and M_Init.

void* freeList;
unsigned long freeListSize;
void* magicNumber;
memStruct* currentBlock;


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

    //Check if the current block is suitable.
    if (currentBlock->size < (memChunks +32) || currentBlock->memptr != magicNumber) //Fails this test? Start searching.
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
    long unsigned currentSize = currentBlock->size; //Save me for later (and easier reading).
    //Detect & set header and footer.
    memStruct *header = (void*) currentBlock;
    memStruct *footer = (void*) currentBlock + 16 + memChunks; //Move past the header + allocated length of node.
    header->size = memChunks;
    footer->size = memChunks;
    header->memptr = (void*)currentBlock + 32 + memChunks; //Point to next header. [past head, past block, past footer].

    if (currentBlock != (void*) freeList) //Do this unless we're on the very first block.
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


/* PURPOSE: Free a given chunk of memory and coalesce if possible.
 * PRE-CONDITIONS:
 *              void *pointer --> Free the block held at this pointer.
 *                pointer cannot be null or outside the allocated memory of mmap [by M_Init].
 *              M_Init must have already been called by program.
 * POST-CONDITIONS: The block of memory at the pointer is cleared and declared writable.
 * RETURN: 0 if M_Free was successful, -1 if M_Free failed.
 */
int M_Free(void *pointer)
{
    if (freeList == NULL)
    {
        printf("Failure! M_Init has not been called yet.\n");
        return -1;
    }
    if (pointer == NULL || pointer < freeList || pointer > freeList+freeListSize)
    {
        printf("Failure! M_Free was given an invalid pointer. \n");
        return -1;
    }
    memStruct *currentHeader = pointer-16;
    memStruct *currentFooter = pointer + currentHeader->size;
    memStruct *prevBlockFooter = NULL;
    memStruct *prevBlockHeader = NULL;

    if (pointer - 16 == freeList)
    {
        memStruct *endBlockFooter = (void*)freeList+freeListSize - 16;
        prevBlockFooter = (void*)endBlockFooter;
        prevBlockHeader = (void*)endBlockFooter - endBlockFooter->size;
    }
    else
    {
        prevBlockFooter = pointer-32;
        prevBlockHeader = pointer-32 - (prevBlockFooter->size + 16);
    }

    memStruct *nextBlockHeader = pointer + currentHeader->size + 16;
    memStruct *nextBlockFooter = (void*) nextBlockHeader + (nextBlockHeader->size) +16;

    if (nextBlockHeader->memptr == magicNumber) //Next block is free. Combine with next block.
    {
        long unsigned combinedSize = currentHeader->size + nextBlockHeader->size+32;
        currentHeader->memptr = nextBlockHeader->memptr;
        currentHeader->size = combinedSize;
        currentFooter->size = combinedSize;
        nextBlockFooter->size = combinedSize;
    }

    if (prevBlockHeader->memptr == magicNumber) //Previous block is free. Combine with previous block.
    {
        long unsigned combinedSize = currentHeader->size + prevBlockHeader->size+32;
        prevBlockHeader->memptr = currentHeader->memptr;
        prevBlockHeader->size = combinedSize;
        nextBlockFooter->size = combinedSize;
        nextBlockFooter->memptr = prevBlockFooter;
    }
    //Set the current block as writable.
    currentHeader->memptr = magicNumber;
    currentFooter->memptr = magicNumber;
    return 0;
}


/* PURPOSE: To print to the console each block stored in freeList [Defined in M_Init].
 * PRE-CONDITIONS: freeList cannot be null.
 *                 M_Init must have already been called by program.
 * POST-CONDITIONS: Blocks of memory and their size are printed to the console.
 * RETURN: None.
 */
void M_Display()
{
    if (freeList == NULL)
    {
        printf("Failure! M_Init has not been called yet.\n");
        return;
    }

    int nodeNumber = 1;
    memStruct *cur = freeList;
    printf("\nM_Display triggered. \n"
           "Freelist total size: %lu\n"
           "Freelist starts at %p and ends at %p\t\t All blocks have 32-bytes for header and footer.\n",
           freeListSize,freeList,freeList+freeListSize);

    while (cur->size != 0)
    {
        if (cur->memptr == magicNumber)
        {
            if ((void*)cur + cur->size > freeList + freeListSize-16)
                printf("\tFREE block %d: %p --> %p [due to size %lu]\n",
                       nodeNumber,cur,(void*)cur + cur->size,cur->size);
            else
                printf("\tFREE block %d: %p --> %p [due to size %lu]\n",
                       nodeNumber,cur,(void*)cur + cur->size+32,cur->size);
        }
        else
        {
            printf("\tBlock %d: %p --> %p [due to size %lu]\n",nodeNumber,cur,(void*)cur->memptr,cur->size);
        }
        cur = (void*) cur + (cur->size+32);
        nodeNumber++;
    }
}
