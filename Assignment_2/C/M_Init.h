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
    struct node_t *current;
    struct node_t *next;
    struct node_t *prev;
    int totalSize;
}node_t;



typedef struct memStruct
{
    unsigned long size;
    struct memStruct* memptr;
}memStruct;


//typedef struct header_t
//{
//    int size;
//    //void* next;
//    void* next;
//} header_t;
//
//typedef struct footer_t
//{
//    int size;
//    //node_t *prev;
//    void* prev;
//} footer_t;


node_t *freeList;
void* magicNumber;

int M_Init(int size);

#endif //M_INIT_H
