/*
Assignment 3 Part B -- petgroomsynch
    Efficient concurrency for a pet grooming program.

Computer Science 332.3
Prof: Dr. Derek Eager
University of Saskatchewan - Arts & Science
	Department of Computer Science
A project by: Spencer Tracy | Spt631 | 11236962 and Shantanu Mishra | Shm572 | 11255997
__________________________________________________
 */

#ifndef B_PETGROOMSYNCH_H
#define B_PETGROOMSYNCH_H
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <stddef.h>

typedef enum {cat, dog, other} pet_t;


int petgroom_init(int numstations);
int newpet(pet_t pet);
int petdone(pet_t pet);
int petgroom_done();

#endif //B_PETGROOMSYNCH_H
