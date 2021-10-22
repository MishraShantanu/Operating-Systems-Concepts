/*
Assignment 2 Part C.

Computer Science 332.3
Prof: Dr. Derek Eager
University of Saskatchewan - Arts & Science
	Department of Computer Science
A project by: Spencer Tracy | Spt631 | 11236962 and Shantanu Mishra | Shm572 | 11255997
__________________________________________________
 */
#ifndef MEMORYLIBRARY_A_MEMORYLIBRARY_H
#define MEMORYLIBRARY_A_MEMORYLIBRARY_H


int M_Init(int size);

void *M_Alloc(int size);

void M_Display();

int M_Free(void *pointer);



#endif //MEMORYLIBRARY_A_MEMORYLIBRARY_H
