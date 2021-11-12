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

#define MAX_BLOCKS 5

//pet_t   ==    cat = 0       dog = 1     other = 2

//Cond variable catDogExclusion -- 0 is open, 1 is cats in grooming, 2 is dogs in grooming.
//Cond variable -- remaining pets, 1 or 0.   [1 means there is indeed pets remaining].

pthread_mutex_t mutex;

pthread_cond_t emptyBeds;
pthread_cond_t noDogs;
pthread_cond_t noCats;
pthread_cond_t tooManyAttempts;



int totalStations;
volatile int openStations;
volatile int catCount;
volatile int dogCount;
volatile int otherCount;
volatile int blockedAttempts;

/* PURPOSE: This function is used to instantiate a new pet grooming facility
 *          and initialize the required variables for the facility.
 * PRE-CONDITIONS:   int numstations --> The # of grooming stations in the facility.
 * POST-CONDITIONS:  Global variables initialized.
 * RETURN: 0 --> Success.    -1 --> Failure.
 */
int petgroom_init(int numstations)
{
    totalStations = numstations;
    openStations = numstations;
    catCount = 0;
    dogCount = 0;
    otherCount = 0;
    pthread_mutex_init(&mutex,NULL);
    pthread_cond_init(&noDogs,NULL);
    pthread_cond_init(&noCats,NULL);
    pthread_cond_init(&emptyBeds,NULL);
    pthread_cond_init(&tooManyAttempts,NULL);

    return 1;
}

/* PURPOSE: Called when a new pet arrives to the facility to be groomed.
 * PRE-CONDITIONS: pet_t pet --> the type of pet to be groomed.
 * POST-CONDITIONS: Blocks until the given pet can be allocated to a grooming station.
 * RETURN: 0 --> Success.    -1 --> Failure.
 */
int newpet(pet_t pet)
{
    pthread_mutex_lock(&mutex);

    while (openStations <= 0)
    {
        //printf("waiting.");
        pthread_cond_wait(&emptyBeds,&mutex);
    }
    while (blockedAttempts > 5)
    {
        //printf("TOO MANY BLOCKS (%d) I WANT TO SWITCH NOW.\n",blockedAttempts);
        pthread_cond_wait(&tooManyAttempts,&mutex);
    }



    if (pet == cat)
    {
        if (dogCount != 0)
        {
            blockedAttempts+=1;
            printf("Attempted to add cat, but had dogs. block#: %d\n",blockedAttempts);
        }
        while(dogCount != 0)
        {
            pthread_cond_wait(&noDogs,&mutex);

        }
        printf("cat given\t");
        catCount += 1;
    }
    if (pet == dog)
    {
        if (catCount != 0)
        {
            blockedAttempts+=1;
            printf("Attempted to add dog, but had cats. block#: %d\n",blockedAttempts);
        }
        while(catCount != 0)
        {
            pthread_cond_wait(&noCats,&mutex);
        }
        printf("dog given\t");
        dogCount += 1;
    }
    if (pet == other)
    {
        printf("other given\t");
        otherCount += 1;
    }
    openStations -= 1;
    printf("\topen stations: %d\t cats [%d] dogs [%d] other [%d]\n",openStations,catCount,dogCount,otherCount);

    pthread_mutex_unlock(&mutex);

    return 1;
}

/* PURPOSE: Called when a given pet has finished grooming and the station is now free.
 * PRE-CONDITIONS: pet_t pet --> the type of pet that has been groomed.
 * POST-CONDITIONS: Pet is removed from the grooming station, and the station is now free.
 * RETURN: 0 --> Success.    -1 --> Failure.
 */
int petdone(pet_t pet)
{
    pthread_mutex_lock(&mutex);
    char* output;
    if (pet == 0) output = "cat";
    if (pet == 1) output = "dog";
    if (pet == 2) output = "other";

    if (pet == cat)
    {
        catCount -= 1;

    }
    if (pet == dog)
    {
        dogCount -= 1;

    }
    if (pet == other)
    {
        otherCount -= 1;
    }


    openStations +=1;
    printf("\t%s done\topen stations: %d\t cats [%d] dogs [%d] other [%d]\n",output,openStations,catCount,dogCount,otherCount);

    if (dogCount == 0 && catCount == 0)
    {
        if (blockedAttempts > 5)
        {
            blockedAttempts = 0;
            pthread_cond_signal(&tooManyAttempts);
        }
        pthread_cond_signal(&noDogs);
        pthread_cond_signal(&noCats);
    }
    else if (catCount == 0)
    {
        pthread_cond_signal(&noCats);
    }
    else if (dogCount == 0)
    {
        pthread_cond_signal(&noDogs);
    }

    pthread_cond_signal(&emptyBeds);
    pthread_mutex_unlock(&mutex);

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