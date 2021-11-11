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



//pet_t   ==    cat = 0       dog = 1     other = 2

//Cond variable catDogExclusion -- 0 is open, 1 is cats in grooming, 2 is dogs in grooming.
//Cond variable -- remaining pets, 1 or 0.   [1 means there is indeed pets remaining].

pthread_cond_t openCond;
pthread_cond_t catsBeingGroomed;
pthread_cond_t dogsBeingGroomed;

pthread_mutex_t openMutex;
pthread_mutex_t catDogExclusion;


volatile int blockedAttempts;
volatile int currentCats;
volatile int currentDogs;
volatile int currentOthers;
int TotalStationCount;
struct Station *stationArray;
volatile int openStations;
/* PURPOSE: This function is used to instantiate a new pet grooming facility
 *          and initialize the required variables for the facility.
 * PRE-CONDITIONS:   int numstations --> The # of grooming stations in the facility.
 * POST-CONDITIONS:  Global variables initialized.
 * RETURN: 0 --> Success.    -1 --> Failure.
 */
int petgroom_init(int numstations)
{
    TotalStationCount = numstations;
    stationArray = malloc(numstations*sizeof(Station));
    const pthread_condattr_t *open;

    for (int i = 0; i<numstations;i++)
    {
        stationArray[i].occupied = 0;
    }
    openStations = numstations;
    currentCats = 0;
    currentDogs = 0;
    currentOthers = 0;
    blockedAttempts = 0;
    pthread_mutex_init(&openMutex,NULL);
    pthread_mutex_init(&catDogExclusion,NULL);
    pthread_cond_init(&openCond,NULL);
    pthread_cond_init(&catsBeingGroomed,NULL);
    pthread_cond_init(&dogsBeingGroomed,NULL);
    return 1;
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

    pthread_mutex_lock(&openMutex);

    while (blockedAttempts > 5)
    {
        //printf("Too many blocks, switching.\n");
        pthread_cond_wait(&dogsBeingGroomed, &openMutex);
    }
    while (openStations <= 0)
    {
        pthread_cond_wait(&openCond, &openMutex);
    }

    if (pet == 0)
    {
        while (currentDogs > 0)
        {
            printf("Blocked, waiting for cat or dog to clear.\n");
            blockedAttempts++;
            pthread_cond_wait(&dogsBeingGroomed, &openMutex);
            pthread_cond_wait(&catsBeingGroomed, &openMutex);
        }
        blockedAttempts = 0;
        currentCats++;
    }
    if (pet == 1)
    {
        while (currentCats > 0)
        {
            blockedAttempts++;
            pthread_cond_wait(&catsBeingGroomed, &openMutex);
        }
        blockedAttempts = 0;
        currentDogs++;
    }
    if (pet == 2) currentOthers++;
    printf("%s recieved.\tRooms open: %d.\t cats: %d, dogs: %d, other: %d.\n",output,openStations,currentCats,currentDogs,currentOthers);
    //printf("New %s.\t cats: %d, dogs: %d, other: %d.\n",output,currentCats,currentDogs,currentOthers);
    openStations -= 1;
    pthread_mutex_unlock(&openMutex);
    return 1;
}

/* PURPOSE: Called when a given pet has finished grooming and the station is now free.
 * PRE-CONDITIONS: pet_t pet --> the type of pet that has been groomed.
 * POST-CONDITIONS: Pet is removed from the grooming station, and the station is now free.
 * RETURN: 0 --> Success.    -1 --> Failure.
 */
int petdone(pet_t pet)
{
    pthread_mutex_lock(&openMutex);
    openStations++;
    char *output;
    if (pet == 0) output = "cat";
    if (pet == 1) output = "dog";
    if (pet == 2) output = "other";

    printf("\t\t\t%s done.\n",output);
    //pthread_mutex_lock(&catDogExclusion);
    if (pet == 0) currentCats--;
    if (pet == 1) currentDogs--;
    if (pet == 2) currentOthers--;


    if (currentDogs == 0)
    {
        //printf("trapped3?");
        pthread_cond_broadcast(&catsBeingGroomed);
    }
    if (currentCats == 0)
    {
        //printf("trapped4?");
        pthread_cond_broadcast(&dogsBeingGroomed);
    }
    //pthread_mutex_unlock(&catDogExclusion);
    pthread_mutex_unlock(&openMutex);
    pthread_cond_signal(&openCond);


    //Modify grooming station -- set as free.
    //check/modify if cat or dog has been completed.
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
