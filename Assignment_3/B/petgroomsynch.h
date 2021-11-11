//
// Created by Spencer on 2021-11-08.
//

#ifndef B_PETGROOMSYNCH_H
#define B_PETGROOMSYNCH_H
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

typedef enum {cat, dog, other} pet_t;

struct Station
{
    int occupied;
    //pthread_cond_t occupuied;
}Station;
struct Station *stationArray;

int petgroom_init(int numstations);
int newpet(pet_t pet);
int petdone(pet_t pet);
int petgroom_done();

#endif //B_PETGROOMSYNCH_H
