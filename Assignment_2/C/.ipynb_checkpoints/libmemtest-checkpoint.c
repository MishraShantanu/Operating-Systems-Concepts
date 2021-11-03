/*
Assignment 2 Part C.

Computer Science 332.3
Prof: Dr. Derek Eager
University of Saskatchewan - Arts & Science
	Department of Computer Science
A project by: Spencer Tracy | Spt631 | 11236962 and Shantanu Mishra | Shm572 | 11255997
__________________________________________________
 */


#include "mem.h"

int main()
{

    //Pick an arbitrary size to init, exit if failed.
    if (M_Init(3000) == -1)
    {
        return -1;
    }

    M_Display();

    void* ptr = M_Alloc(200);
    void* ptr2 = M_Alloc(50);
    void* ptr3 = M_Alloc(145);
    void* ptr4 = M_Alloc(344);
    void* ptr5 = M_Alloc(134);
	//void* ptr6 = M_Alloc(605);
    void* ptr7 = M_Alloc(866);
    void* ptr8 = M_Alloc(6);

//Test for coalescence from both sides:
    M_Free(ptr3);
    M_Free(ptr5);
    M_Free(ptr4);

    M_Alloc(424);
    M_Alloc(745);
    M_Alloc(111);


    M_Display();


//Test for coalescence from a following block:
    M_Free(ptr2);
    M_Free(ptr);
    //M_Display();

//Test for coalescence from a preceding block.
    M_Free(ptr7);
    M_Free(ptr8);
    //M_Display();


    M_Display();
	
}