//
// Created by Spencer on 2021-10-07.
//

#ifndef M_ALLOC_H
#define M_ALLOC_H

typedef struct __node_t
{
    int size;
} node_t;


typedef struct header_t
{
    int size;
    node_t next;
} header_t;


typedef struct footer_t
{
    int size;
    node_t prev;  //Insert magic number check here.
} footer_t;


void *M_Alloc(int size);


#endif //M_ALLOC_H
