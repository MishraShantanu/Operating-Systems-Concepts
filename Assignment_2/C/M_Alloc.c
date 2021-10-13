/*
 void *M_Alloc(int size):
	M_Alloc() is used to allocate a chunk;
		its argument is the requested size in bytes.

	The function should return a pointer to the start of the allocated chunk, or NULL if the request fails,
			e.g. satisfying the request is not possible owing to there not being enough contiguous free space.

	The actual size of the allocated chunk should be size rounded up to the nearest multiple of 16 bytes.

	Allocation should use the next fit policy.
 */



#include <sys/mman.h>
#include <stdio.h>
#include "M_Alloc.h"



void *M_Alloc(int size)
{
    int memChunks = size/16;
    if (size%16 != 0)
    {
        memChunks++;
    }
    memChunks = memChunks * 16;
    printf("Test print, allocated %d\n",memChunks);
    return (void *) 1;
}


//int main(int argc, char *argv[])
//{
//    //Access the initialized M_Init
//            //Handle if M_Init is not yet initialized.
//
//    int givenSize = 4002;
//    int roundedSize = roundChunks(givenSize);
//
//
//
//
//    return 0;
//}