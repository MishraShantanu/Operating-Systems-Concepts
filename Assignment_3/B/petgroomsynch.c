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
#define MAX_BLOCKS 5

//pet_t   ==    cat = 0       dog = 1     other = 2

pthread_mutex_t mutex;

pthread_cond_t emptyBeds;
pthread_cond_t noDogs;
pthread_cond_t noCats;
pthread_cond_t tooManyAttempts;



int totalStations;
int beenInitialized;
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
    //*Error checking: Calling init while already initialized.
    if (beenInitialized == 1)
    {
        printf("petgroom_init failed! Petgroom_init has already been initialized!\n");
        return -1;
    }
    //*Error checking: Do mutexes and condition variables fail to initialize?
    if (pthread_mutex_init(&mutex,NULL) != 0)
    {
        printf("Mutex failed to initialize!\n");
        return -1;
    }
    if (pthread_cond_init(&noDogs,NULL) != 0)
    {
        printf("Condition variable noDogs failed to initialize!\n");
        return -1;
    }
    if (pthread_cond_init(&noCats,NULL) != 0)
    {
        printf("Condition variable noCats failed to initialize!\n");
        return -1;
    }
    if (pthread_cond_init(&emptyBeds,NULL) != 0)
    {
        printf("Condition variable emptyBeds failed to initialize!\n");
        return -1;
    }
    if (pthread_cond_init(&tooManyAttempts,NULL) != 0)
    {
        printf("Condition variable tooManyAttempts failed to initialize!\n");
        return -1;
    }
    //Declaration of global variables.
    totalStations = numstations;
    openStations = numstations;
    catCount = 0;
    dogCount = 0;
    otherCount = 0;
    blockedAttempts = 0;

    beenInitialized = 1;
    return 0;
}

/* PURPOSE: Called when a new pet arrives to the facility to be groomed.
 * PRE-CONDITIONS: pet_t pet --> the type of pet to be groomed.
 * POST-CONDITIONS: Blocks until the given pet can be allocated to a grooming station.
 * RETURN: 0 --> Success.    -1 --> Failure.
 * [Note: As checked with TA, failure should not be possible to occur, so function always returns 0].
 */
int newpet(pet_t pet)
{

    //Easy case: when pet is other, it can always be queued if there's an empty bed.
    if (pet == other)
    {
        pthread_mutex_lock(&mutex);     //Start critical section
        while (openStations <= 0) pthread_cond_wait(&emptyBeds, &mutex);
        printf("other given\t");
        otherCount++;
        openStations -= 1;
        printf("\topen stations: %d\t cats [%d] dogs [%d] other [%d]\n",openStations,catCount,dogCount,otherCount);
        pthread_mutex_unlock(&mutex);   //End critical section.
    }
    else //There are dogs and cats involved, this may get messy.
    {
        pthread_mutex_lock(&mutex); //Start critical section.
        int typeWaiting = 4;
        while (blockedAttempts > MAX_BLOCKS)
        {  //Check if we've waited more than MAX_BLOCKS amount of time for adding new dog or new cat.
            if (catCount > 0) typeWaiting=dog;
            if (dogCount > 0) typeWaiting=cat;

            char* output;
            if (typeWaiting == cat) output = "cat";
            if (typeWaiting == dog) output = "dog";


            printf("Too many blocks. Waiting for %s to clear. \n",output);
            pthread_cond_wait(&tooManyAttempts, &mutex); //Wait until all of typeWaiting have cleared.
            blockedAttempts = 0; //Ensure the complete reset of blocked attempts (also done in petdone())
        }
        if (pet == dog && catCount != 0) //Trying to add a dog while there are cats. Wait.
        {
            blockedAttempts += 1;
            while (catCount != 0) pthread_cond_wait(&noCats, &mutex);
        }
        if (pet == cat && dogCount != 0) //Trying to add cat when there are dogs. Wait.
        {
            blockedAttempts += 1;
            while (dogCount != 0) pthread_cond_wait(&noDogs, &mutex);
        }
        while (openStations <= 0) pthread_cond_wait(&emptyBeds, &mutex); //Ensure there's an empty bed.
        if (typeWaiting == cat && pet == cat)
            //An attempt at forcing ordering, but when many blocked pets queued it sometimes
            // fails especially if MAX_BLOCKS is high (MAX_BLOCKS achieved before all queued pets have been cleared).
        {
            //printf("CATS GIVEN PRIORITY.\n");
            catCount++;
            printf("cat given\t");
        }
        else if (typeWaiting == dog && pet == dog)
        {
            //printf("DOGS GIVEN PRIORITY.\n");
            dogCount++;
            printf("dog given\t");
        }
        else //Neither have been waiting for too long, regular addition of the pet.
        {
            if (pet == cat)
            {
                catCount++;
                printf("cat given\t");
            }
            if (pet == dog)
            {
                dogCount++;
                printf("dog given\t");
            }
        }

        openStations -= 1;
        //Optional print statement, useful in readability.
        printf("\topen stations: %d\t cats [%d] dogs [%d] other [%d]\n",openStations,catCount,dogCount,otherCount);
        pthread_mutex_unlock(&mutex); //End critical section.
    }
    return 0;
}

/* PURPOSE: Called when a given pet has finished grooming and the station is now free.
 * PRE-CONDITIONS: pet_t pet --> the type of pet that has been groomed.
 * POST-CONDITIONS: Pet is removed from the grooming station, and the station is now free.
 * RETURN: 0 --> Success.    -1 --> Failure.
 */
int petdone(pet_t pet)
{
    //For ease of print statements, define pets as strings.
    char* output;
    if (pet == 0) output = "cat";
    if (pet == 1) output = "dog";
    if (pet == 2) output = "other";

    //Begin critical section.
    pthread_mutex_lock(&mutex);

    //Failure checks: Did we try to clear an animal that wasn't being groomed?
    if (pet == cat && catCount == 0)
    {
        printf("TRIED TO CLEAR A PET CAT WHEN IT WASN'T BEING GROOMED.\n");
        pthread_mutex_unlock(&mutex);
        return -1;
    }
    if (pet == dog && dogCount == 0)
    {
        printf("TRIED TO CLEAR A PET DOG WHEN IT WASN'T BEING GROOMED.\n");
        pthread_mutex_unlock(&mutex);
        return -1;
    }
    if (pet == other && otherCount == 0)
    {
        printf("TRIED TO CLEAR A PET OTHER WHEN IT WASN'T BEING GROOMED.\n");
        pthread_mutex_unlock(&mutex);
        return -1;
    }

    //Modify attributes to clear the animal.
    if (pet == cat) catCount -= 1;
    if (pet == dog) dogCount -= 1;
    if (pet == other) otherCount -= 1;

    openStations +=1;

    //Optional print statement, but quite useful in understanding what's going on.
    printf("\t%s done\topen stations: %d\t cats [%d] dogs [%d] other [%d]\n",output,openStations,catCount,dogCount,otherCount);

    //Wake up a thread waiting for an empty bed.
    pthread_cond_signal(&emptyBeds);

    //Signal to threads waiting for mutual exclusion between cats and dogs.
    if (catCount == 0)
    {
        //printf("No cats, signal noCats.\n");
        pthread_cond_signal(&noCats);
    }
    else if (dogCount == 0)
    {
        //printf("No dogs, signal noDogs.\n");
        pthread_cond_signal(&noDogs);
    }
    //When both are empty, reset blockedAttempts as either a dog or a cat can be queued.
    if (dogCount == 0 && catCount == 0)
    {
        if (blockedAttempts > MAX_BLOCKS)
        {
            printf("Max blocks cleared, broadcast as free to all waiting threads.\n");
            pthread_cond_broadcast(&tooManyAttempts);
            blockedAttempts = 0;
        }
        //printf("noDogs and noCats, signalling to both\n");
        pthread_cond_signal(&noDogs);
        pthread_cond_signal(&noCats);
    }
    //End of critical section.
    pthread_mutex_unlock(&mutex);
    return 0;
}


/* PURPOSE: Called when all pets have been groomed, closes down the grooming facility.
 * PRE-CONDITIONS:
 * POST-CONDITIONS: Global variables de-initialized, petgroom_init() can now be used again.
 * RETURN: 0 --> Success.    -1 --> Failure.
 */
int petgroom_done()
{
    if (beenInitialized != 1)
    {
        printf("petgroom_done failed! Tried to call petgroom_done but petgroom has not been initialized.\n");
        return -1;
    }

    if (catCount != 0 || dogCount != 0 || otherCount != 0)
    {
        printf("petgroom_done failed! Tried to de-initialize petgroom while there was still pets.\n");
        return -1;
    }

    if (pthread_mutex_destroy(&mutex) != 0)
    {
        printf("Mutex failed to be destroyed!\n");
        return -1;
    }

    if (pthread_cond_destroy(&noDogs) != 0)
    {
        printf("Condition variable noDogs failed to be destroyed!\n");
        return -1;
    }

    if (pthread_cond_destroy(&noCats) != 0)
    {
        printf("Condition variable noCats failed to be destroyed!\n");
        return -1;
    }

    if (pthread_cond_destroy(&emptyBeds) != 0)
    {
        printf("Condition variable emptyBeds failed to be destroyed!\n");
        return -1;
    }

    if (pthread_cond_destroy(&tooManyAttempts) != 0)
    {
        printf("Condition variable tooManyAttempts failed to be destroyed!\n");
        return -1;
    }

    totalStations = 0;
    openStations = 0;
    catCount = 0;
    dogCount = 0;
    otherCount = 0;
    blockedAttempts = 0;

    beenInitialized = 0;

    return 0;
}