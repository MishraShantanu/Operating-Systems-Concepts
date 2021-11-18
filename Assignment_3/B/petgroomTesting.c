//
// Created by Spencer on 2021-11-08.
//

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include "petgroomsynch.h"




//struct Groom* autoGenerate()
//{
//    struct Groom *autoGen = malloc(sizeof(Groom));
//
//    autoGen->stations = rand() % 50 +3;
//    autoGen->petTotal = (rand() % (autoGen->stations*2) + autoGen->stations);
//
//    int temp = autoGen->petTotal;
//    autoGen->catTotal = rand() % temp;
//    temp -= autoGen->catTotal;
//    autoGen->dogTotal = rand() % temp;
//    temp -= autoGen->dogTotal;
//    autoGen->otherTotal = temp;
//
//    autoGen->dogTime = 7;
//    autoGen->catTime = 10;
//    autoGen->otherTime = 5;
//
//    printf("Initialized %d stations and %d pets.\n%d cats (10 sec each), %d dogs (7 sec each), %d others (5 sec each).\n"
//            ,autoGen->stations,autoGen->petTotal,autoGen->catTotal,autoGen->dogTotal,autoGen->otherTotal);
//    populateArray(autoGen);
//    petgroom_init(autoGen->stations);
//    return autoGen;
//}


void* newThread ()
{
    //sleep(1);
    int randPetID = rand()%3;
    char *output;
    if (randPetID == 0) output = "cat";
    if (randPetID == 1) output = "dog";
    if (randPetID == 2) output = "other";
    newpet(randPetID);
    printf("%s given\n",output);
    sleep(5);
    if (petdone(randPetID) != -1)
    {
        printf("\t%s done\n",output);
    }
    else
    {
        printf("Petdone failed!");
    }
    pthread_exit(0);
}


void* parseArray(long petTotal)
{
    pthread_t threadIDs[petTotal];
    for (int i = 0; i < petTotal;i++)
    {
        sleep(1);
        pthread_create(&threadIDs[i],NULL,(void *) newThread, NULL);
    }
    for (int i = 0; i < petTotal;i++)
    {
        pthread_join(threadIDs[i],NULL);
    }
    return 0;
}

int main()
{
    unsigned int seed = time(NULL);
    srand(seed);
    long stations = 5;
    long petTotal = 40;
    petgroom_init((int) stations);
    printf("Initialized %lu stations and %lu pets.\n" ,stations,petTotal);
    parseArray(petTotal);

    //TODO: Test init fails.
        //DOUBLE INIT?
        //FAILURE TO CREATE OBJECTS (mutex's, cond's)
    //TODO: Test petDone fails.
    //TODO: Test groomDone() fails.

}