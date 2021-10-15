#include <stdio.h>
#include "M_Init.h"
#include "M_Display.h"
#include "M_Alloc.h"
//#include "M_Free.h"

int main(int argc, char *argv[])
{

    //Pick an arbitrary size to init, exit if failed.
    if (M_Init(16000) == -1)
    {
        return -1;
    }

    void* ptr = M_Alloc(200);
    //printf("Alloc pointer is pointing at: %p with a hard limit at %p [due to size %d]\n",ptr,ptr->current,ptr->size);


    void* ptr2 = M_Alloc(50);
    //printf("Alloc pointer is pointing at: %p with a hard limit at %p [due to size %d]\n",ptr2,ptr2->next,ptr2->size);

    void* ptr3 = M_Alloc(145);
    //printf("Alloc pointer is pointing at: %p with a hard limit at %p [due to size %d]\n",ptr3,ptr3->next,ptr3->size);

    //printf("Does seg fault happen before here?\n");
    void* ptr4 = M_Alloc(10);

    void* ptr5 = M_Alloc(134);
    //printf("Alloc pointer is pointing at: %p with a hard limit at %p [due to size %d]\n",ptr4,ptr4->next,ptr4->size);
    M_Display();
    //M_Free(ptr4);

    //printf("Does seg fault happen before here?\n");
    //void* ptr5 = M_Alloc(3012);


}