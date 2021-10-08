//
// Created by Spencer on 2021-10-07.
//

#ifndef M_INIT_H
#define M_INIT_H

#include <sys/mman.h>
#include <stdio.h>
typedef struct node_t
{
    int size;
    struct node_t *next;
    struct node_t *prev;
}node_t;

node_t *freeList;
int *magicNumber;

int M_Init(int size);

#endif //M_INIT_H
