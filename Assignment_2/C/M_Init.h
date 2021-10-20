/*
Assignment 2 Part C.

Computer Science 332.3
Prof: Dr. Derek Eager
University of Saskatchewan - Arts & Science
	Department of Computer Science
A project by: Spencer Tracy | Spt631 | 11236962 and Shantanu Mishra | Shm572 | 11255997
__________________________________________________
 */


#ifndef M_INIT_H
#define M_INIT_H

#include <sys/mman.h> //mmap
#include <stdio.h>


typedef struct memStruct  //Structure for all headers and footers.
{
    unsigned long size;
    struct memStruct* memptr;
}memStruct;


int M_Init(int size); //The function itself.

//Global variables relied upon by M_Display, M_Alloc, M_Free and M_Init itself.
void* freeList;
unsigned long freeListSize;
void* magicNumber;
memStruct* currentBlock;


#endif //M_INIT_H
