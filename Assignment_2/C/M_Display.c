//
// Created by Spencer on 2021-10-13.
//
#include <stdio.h>
#include "M_Init.h"

void M_Display()
{
    int nodeNumber = 0;
    node_t *cur = freeList;
    printf("M_Display triggered.\n");

    while (cur->next != magicNumber)
    {
        printf("%p with a hard limit at %p [due to size %d]\n",cur,cur->next,cur->size);
        cur = cur->next;
    }
}
