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

#include "petgroomsynch.h"
#include <pthread.h>

#define MAX_BLOCKS 4

//pet_t   ==    cat = 0       dog = 1     other = 2

//Cond variable catDogExclusion -- 0 is open, 1 is cats in grooming, 2 is dogs in grooming.
//Cond variable -- remaining pets, 1 or 0.   [1 means there is indeed pets remaining].

//pthread_mutex_t mutex;
//
//pthread_cond_t emptyBeds;
//pthread_cond_t noDogs;
//pthread_cond_t noCats;
//pthread_cond_t tooManyAttempts;

struct Station
{
    pthread_mutex_t locked;
    pthread_cond_t hasAnimal;
    volatile int animalType;  //0 = cat, 1 = dog, 2 = other, 3 = empty.
}Station;

struct GroomBusiness
{
    int totalStations;
    volatile int openStations;
    volatile int blockedAttempts;
    pthread_cond_t hasDogs;
    pthread_cond_t hasCats;
    struct Station *stationArray;
} GroomBusiness;

struct GroomBusiness *groom;


/* PURPOSE: This function is used to instantiate a new pet grooming facility
 *          and initialize the required variables for the facility.
 * PRE-CONDITIONS:   int numstations --> The # of grooming stations in the facility.
 * POST-CONDITIONS:  Global variables initialized.
 * RETURN: 0 --> Success.    -1 --> Failure.
 */
int petgroom_init(int numstations)
{
    groom = malloc(sizeof(GroomBusiness));
    groom->totalStations = numstations;
    groom->openStations = numstations;
    groom->blockedAttempts = 0;
    pthread_cond_init(&groom->hasCats,NULL);
    pthread_cond_init(&groom->hasDogs,NULL);
    groom->stationArray = malloc(numstations*sizeof(Station));

    for (int i = 0; i < numstations; i++)
    {
        groom->stationArray[i].animalType = 3;
        pthread_mutex_init(&groom->stationArray[i].locked,NULL);
        pthread_cond_init(&groom->stationArray[i].hasAnimal,NULL);
    }
    return 0;
}

/* PURPOSE: Called when a new pet arrives to the facility to be groomed.
 * PRE-CONDITIONS: pet_t pet --> the type of pet to be groomed.
 * POST-CONDITIONS: Blocks until the given pet can be allocated to a grooming station.
 * RETURN: 0 --> Success.    -1 --> Failure.
 */
int newpet(pet_t pet)
{
    char *output;
    if (pet == 0) output = "cat";
    if (pet == 1) output = "dog";
    if (pet == 2) output = "other";

    printf("received: %s\n",output);

    return 0;
}

/* PURPOSE: Called when a given pet has finished grooming and the station is now free.
 * PRE-CONDITIONS: pet_t pet --> the type of pet that has been groomed.
 * POST-CONDITIONS: Pet is removed from the grooming station, and the station is now free.
 * RETURN: 0 --> Success.    -1 --> Failure.
 */
int petdone(pet_t pet)
{
    char *output;
    if (pet == 0) output = "cat";
    if (pet == 1) output = "dog";
    if (pet == 2) output = "other";

    printf("finished: %s",output);

    return 1;
}


/* PURPOSE: Called when all pets have been groomed, closes down the grooming facility.
 * PRE-CONDITIONS:
 * POST-CONDITIONS: Global variables de-initialized, petgroom_init() can now be used again.
 * RETURN: 0 --> Success.    -1 --> Failure.
 */
int petgroom_done()
{
    //Confirm all pets have been cleared.
    //Deallocate
    return 1;
}