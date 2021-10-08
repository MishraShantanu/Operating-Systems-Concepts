/*
* int M_Init(int size):
	The purpose of M_Init() is to initialize your memory allocator.
	The calling program should invoke it only once.
	It takes as its argument the size of the memory space (in bytes) that your allocator should manage.
		Round this up to the nearest multiple of 16 bytes. 			[Complete]
		You must then use mmap() to request this space from the OS.
	The function should return 0 on success and -1 for a failure return.

*/

#include <sys/mman.h>
#include <stdio.h>
#include "M_Init.h"

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


int M_Init(int size)
{

    //TODO: Check if M_Init has already been run.


    int memChunks = size/16;
    if (size%16 != 0)
    {
        memChunks++;
    }
    memChunks = memChunks * 16;

    //node_t *head = mmap(NULL, memChunks, PROT_READ|PROT_WRITE,MAP_ANON|MAP_PRIVATE, -1, 0);
    node_t *head = mmap((void *) 0xdeadbeaf, memChunks, PROT_READ | PROT_WRITE, MAP_ANON | MAP_SHARED, -1, 0);
    //node_t *head = mmap(NULL, memChunks, PROT_READ|PROT_WRITE,MAP_SHARED, -1, 0);

    //0xdeadbeaf
    if(head == MAP_FAILED)
    {
        printf("Mapping Failed\n");
        return 1;
    }

    head->size = (int)(memChunks - sizeof(node_t));
    head->next = NULL;
    head->prev = NULL;
    printf("mapfile in Init: %p\n",head);


    //printf("mapfile in Init: %p\n",head);


    //MAP_FILE
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

