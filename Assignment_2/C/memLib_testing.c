#include <stdio.h>
#include "M_Init.h"
//#include "M_Alloc.h"


void *M_Alloc(int size)
{
    int memChunks = size/16 + 2;
    if (size%16 != 0)
    {
        memChunks++;
    }

    memChunks = memChunks * 16;
    printf("Test print, allocated %d\n",memChunks);

    if ((int*) freeList->current == (int*) freeList)
    {
        printf("Allocating first chunk in free list!\n");
        freeList->current->header = (struct header_t *) (freeList->current);
        printf("test1\n");

        freeList->current->header->size = memChunks;
        printf("test2\n");

        freeList->current->footer = (struct footer_t *) (freeList->current);
        freeList->current->footer->size = memChunks;

        //TODO: Footer and header causing seg faults, investigate.
                //Maybe point to data from current +8 in return (omit header)?
                //How do I omit footer?
                //Should I just add an extra 32 bytes to this no matter what to fit both?


        printf("test3\n");
        printf("footersize:%d\n",freeList->current->footer->size);
        //freeList->current->next->size = memChunks;
        freeList->current->size = memChunks;


        printf("cur pointer: %p next pointer %p\n",freeList->current,freeList->current + memChunks);
        //freeList->current;
        //freeList->current = freeList->current + memChunks;
        //freeList->current = freeList->current->next;
        freeList->current = freeList->current + memChunks;
        return freeList->current;
    }
    return NULL;
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
    if (M_Init(600) == -1)
    {
        return -1;
    }

    void *ptr = M_Alloc(200);
    printf("Alloc pointer is pointing at: %p\n",ptr);
    printf("freeList.current - freelist == %ld\n",freeList->current - freeList);

    //printf("after alloc, freeList is: %p and freeList->current is: %p",freeList,freeList->current);
    printf("after alloc, freeList is: %p\n",freeList);

    printf("after alloc, freeList.current is: %p\n",freeList->current);
    //printf("after alloc, freeList.current.footer is: %\n",freeList->current->footer->size);



    //printf("footersize:%d\n",freeList->current->footer->size);

    //printf("current footer size: %d\n",);

//    freeList->header = (struct header_t *) (freeList + 200);
//    if ((int*) freeList->next != magicNumber)
//    {
//        printf("freeList->next has been detected as allocated!\n");
//    }
//    printf("Freelist root: %p\n",freeList);
//    printf("Freelist current: %p\n",freeList->current);
//    printf("Freelist next: %p\n",freeList->next);
//    printf("Freelist current.next: %p\n",freeList->current->next);


    //printf("Pointer of freeList next: %p\n",freeList->next);
    //printf("Pointer of freeList prev: %p\n",freeList->prev);
    //printf("Pointer of freeList+200: %p which should be the same as freeList->next %p\n",freeList+200,freeList->next);
    //printf("Size of freeList %lu\n", sizeof(freeList));
    //printf("Size of node_t %lu\n", sizeof(node_t));
    //printf("Size of next %lu\n", sizeof(freeList->next));
    //printf("Size of prev %lu\n", sizeof(freeList->prev));
    //printf("Size of header %lu\n", sizeof());
    //printf("Pointer of freeList: %p\n",(int *)freeList);
    //printf("freeList next: %p\n",(int*) freeList->next);
    //printf("freeList prev: %p\n",(int*) freeList->prev);


    //freeList->current = (freeList + 300);




    //freeList->next->size =100;
    //freeList->next = freeList +300;

    //printf("memchunks %d - sizeof(node_t) %lu == %d\n",memChunks, sizeof(node_t),freeList->size);
//    printf("Size of node_t %lu\n", sizeof(node_t));
//    printf("Size of freeList %lu\n", sizeof(*freeList));
//    printf("Size of header %lu\n", sizeof(header_t));
//    printf("Size of footer %lu\n", sizeof(footer_t));
//    printf("Size of next %lu\n", sizeof(freeList->next));
//    printf("Size of prev %lu\n", sizeof(freeList->prev));


}