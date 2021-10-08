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

/* Purpose: Round up an integer to the nearest multiple of 16 [bytes].
 * Pre-conditions: size -- must be > 0.
 * Post-conditions: None.
 * Return: The nearest (rounded if needed) multiple of 16.
 */
int roundChunks(int size)
{
    int memChunks = size/16;
    if (size%16 != 0)
    {
        memChunks++;
    }
    return memChunks * 16;
}


typedef struct
{
    int size;
    int magic;
} header_t;

typedef struct
{
    int size;
    int magic;
} footer_t;

typedef struct __node_t
{
    int size;
    struct __node_t *next;
    struct __node_t *prev;
} node_t;


//void *M_Alloc(int size)
void M_Alloc(int size)
{
    int memChunks = size/16;
    if (size%16 != 0)
    {
        memChunks++;
    }
    memChunks = memChunks * 16;
    printf("Test print, allocated %d\n",memChunks);

    void *ptr = (void *) 0xdeadb000;
    node_t *head = mmap((void *) 0xdeadbeaf, memChunks, PROT_READ | PROT_WRITE, MAP_ANON | MAP_SHARED, -1, 0);

    //return (void *) 1;
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