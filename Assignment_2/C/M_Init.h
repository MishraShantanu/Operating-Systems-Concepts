//
// Created by Spencer on 2021-10-07.
//

#ifndef M_INIT_H
#define M_INIT_H

typedef struct __node_t
{
    int size;
    struct __node_t *next;
    struct __node_t *prev;
}node_t;

node_t *freeList;

int M_Init(int size);

#endif //M_INIT_H
