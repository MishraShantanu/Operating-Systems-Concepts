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

node_t *freeList;
int M_Init(int size)
{

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
    //Create the mmap space for storing nodes.
    freeList = mmap((void *) 0xdead0000, memChunks, PROT_READ |
    PROT_WRITE, MAP_ANON | MAP_SHARED, -1, 0);

    if(freeList == MAP_FAILED) //Check and report failure to allocate.
    {
        printf("Mapping Failed\n");
        return -1;
    }
    //Define magic number, set next and prev as magic number to determine if a block
    //has already been allocated.
    magicNumber = (int *) 123456789;
    freeList->size = (int)(memChunks - sizeof(node_t));
    freeList->next = (struct node_t *) magicNumber;
    freeList->prev = (struct node_t *) magicNumber;
    return 0;
}


//
//int main(int argc, char *argv[])
//{
//    int givenSize = 4002;
//    //M_Init(givenSize);
//
//
//    //printf("Given %d -- rounded up is %d \n",givenSize, roundedSize);
//    //printf("size of node_t: %lu \n",sizeof (node_t));
//    //printf("size of head: %d \n",head->size);
//    return 0;
//}

