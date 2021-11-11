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
#define MAX_ATTEMPTS 5


//pet_t   ==    cat = 0       dog = 1     other = 2

//Cond variable catDogExclusion -- 0 is open, 1 is cats in grooming, 2 is dogs in grooming.
//Cond variable -- remaining pets, 1 or 0.   [1 means there is indeed pets remaining].

pthread_cond_t openCond;
pthread_cond_t noCats;
pthread_cond_t noDogs;

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
    pthread_cond_init(&noCats, NULL);
    pthread_cond_init(&noDogs, NULL);
    return 1;
}

/* PURPOSE: Called when a new pet arrives to the facility to be groomed.
 * PRE-CONDITIONS: pet_t pet --> the type of pet to be groomed.
 * POST-CONDITIONS: Blocks until the given pet can be allocated to a grooming station.
 * RETURN: 0 --> Success.    -1 --> Failure.
 */
int newpet(pet_t pet)
{

    printf("Newthread. locking mutex...\n");
    char *output;
    if (pet == 0) output = "cat";
    if (pet == 1) output = "dog";
    if (pet == 2) output = "other";

    pthread_mutex_lock(&openMutex);

    printf("Open Mutex locked successfully\n");


    while (openStations == 0)
    {

        printf("No open stations, waiting.\n");
        pthread_mutex_unlock(&openMutex);
        pthread_cond_wait(&openCond, &openMutex);
    }

    // pthread_mutex_lock(&catDogExclusion);
    if (pet == 2)
    {

        printf("Allocating new other...\n");
        currentOthers++;

        printf("New other allocated.\n");
    }
    else if (currentDogs > 0 || currentCats > 0)
    {

        printf("Either no dogs or no cats\n");
        while (blockedAttempts > MAX_ATTEMPTS && currentDogs > 0)
        {

            printf("New cats blocked too much. Wait for dogs to be done.\n");
            //while (currentCats > 0)  pthread_cond_wait(&noCats, &openMutex);
            pthread_mutex_unlock(&openMutex);
            pthread_cond_wait(&noDogs, &openMutex);
            blockedAttempts = 0;
        }
        while (blockedAttempts > MAX_ATTEMPTS && currentCats > 0)
        {

            printf("New dogs blocked too much. Wait for cats to be done.\n");
            pthread_mutex_unlock(&openMutex);
            pthread_cond_wait(&noCats, &openMutex);
            blockedAttempts = 0;
        }
    }
    //blockedAttempts = 0;


    if (pet == 0)
    {
        while (currentDogs > 0) {

            printf("Attempted to receive cat, but there were dogs. Blocked attempts: %d\n", blockedAttempts);
            blockedAttempts++;

            pthread_mutex_unlock(&openMutex);
            pthread_cond_wait(&noDogs, &openMutex);

            printf("No dogs achieved, allocating new cat...\n");
            //pthread_mutex_lock(&openMutex);
            //pthread_cond_wait(&noCats, &openMutex);
        }

        printf("Allocated new cat\n");
        currentCats++;
    }
    if (pet == 1) {
        while (currentCats > 0) {

            printf("Attempted to receive dog, but there were cats. Blocked attempts: %d\n", blockedAttempts);
            blockedAttempts++;
            pthread_mutex_unlock(&openMutex);
            pthread_cond_wait(&noCats, &openMutex);

            printf("No cats achieved, allocating new dog...\n");

            //pthread_mutex_lock(&openMutex);

        }
        currentDogs++;
    }
    //pthread_mutex_unlock(&catDogExclusion);





    //
    // printf("New %s.\t cats: %d, dogs: %d, other: %d.\n",output,currentCats,currentDogs,currentOthers);
    openStations -= 1;

    printf("%s recieved.\tRooms open: %d.\t cats: %d, dogs: %d, other: %d. Thread complete, unlocking...\n",output,openStations,currentCats,currentDogs,currentOthers);
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


    if (currentCats == 0 && currentDogs == 0)
    {

        printf("\tAny allowed. Signal dog....\t");
        pthread_cond_signal(&noDogs);

        printf("Signal to dog success. Signal to cat...\t");
        pthread_cond_signal(&noCats);

        printf("Signal to cat success. Resetting attempts...\t");

        blockedAttempts = 0;

        printf(" attempts reset.\n");
    }
    if (currentCats == 0 && blockedAttempts < MAX_ATTEMPTS)
    {

        printf("\t\t\tnoCats... dogs allowed.  \n");
        pthread_cond_signal(&noCats);
    }
    if (currentDogs == 0 && blockedAttempts < MAX_ATTEMPTS)
    {

        printf("\t\t\tnoDogs... cats allowed.  \n");
        pthread_cond_signal(&noDogs);
    }
    else
    {

        printf("Trap 1. dog count: %d \tcat count: %d \tblocked attempts: %d\n",currentDogs,currentCats,blockedAttempts);
        while (blockedAttempts > MAX_ATTEMPTS)
        {
            printf("\ttrap 2\t");
            if (currentCats > 0)
            {

                printf("\t cats in trap 2\n");

                pthread_mutex_unlock(&openMutex);
                while (currentCats > 0) pthread_cond_wait(&noCats,&openMutex);

                blockedAttempts = 0;
            }
            if (currentDogs > 0)
            {
                printf("\t dogs in trap 2\n");
                pthread_mutex_unlock(&openMutex);
                while (currentDogs > 0) pthread_cond_wait(&noDogs,&openMutex);
                blockedAttempts = 0;
            }
            blockedAttempts = 0;
            printf("end of trap2.");
        }


        printf("End of trap 1.");
    }


    if (pet == 0) currentCats--;
    if (pet == 1) currentDogs--;
    if (pet == 2) currentOthers--;
    //pthread_mutex_unlock(&catDogExclusion)
    printf("\t\t\t%s done.\n",output);
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
