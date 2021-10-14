#include <stdio.h>
#include "M_Init.h"
//#include "M_Alloc.h"


void *M_Alloc(int size)
{
    int memChunks = size/16;
    if (size%16 != 0)
    {
        memChunks++;
    }
    memChunks = memChunks * 16;



    printf("Test print, allocated %d\n",memChunks);

    //if (freeList->current->next == magicNumber)
    //{


    freeList->current->size = memChunks;
    freeList->current->next = (struct node_t *) ((int *) freeList->current + memChunks);
    freeList->current->next->next = magicNumber;
    void *out = freeList->current;

    freeList->current = (struct node_t *) ((int *) freeList->current + memChunks);





    //
    //


    //freeList->current = freeList->current + memChunks;


    //freeList->current->next->prev = freeList->current;
    //freeList->current = freeList->current->next;

    return out;
    //}
    //printf("Magic next. doing nothing.\n");
    //return NULL;
//    else
//    {
//
//        while ((int*) freeList->current->next != magicNumber)
//        {
//            freeList->current = (struct node_t *) freeList->current->next;
//            if ((int*) freeList->current > (int*)(freeList + freeList->size))
//            {
//                printf("Cannot alloc -- exceeded maximum size of freeList!");
//                return NULL;
//            }
//        }
//    }
//    return freeList->current;



}


int main(int argc, char *argv[])
{

    //Pick an arbitrary size to init, exit if failed.
    if (M_Init(16000) == -1)
    {
        return -1;
    }

    node_t *ptr = M_Alloc(200);
    printf("Alloc pointer is pointing at: %p with a hard limit at %p [due to size %d]\n",ptr,ptr->current,ptr->size);


    node_t *ptr2 = M_Alloc(50);
    printf("Alloc pointer is pointing at: %p with a hard limit at %p [due to size %d]\n",ptr2,ptr2->next,ptr2->size);

    node_t *ptr3 = M_Alloc(145);
    printf("Alloc pointer is pointing at: %p with a hard limit at %p [due to size %d]\n",ptr3,ptr3->next,ptr3->size);

    node_t *ptr4 = M_Alloc(1212);
    printf("Alloc pointer is pointing at: %p with a hard limit at %p [due to size %d]\n",ptr4,ptr4->next,ptr4->size);


    //printf("Alloc pointer is pointing at: %p with a hard limit at %p [due to size %d]\n",ptr,ptr->next,ptr->size);

}