//
// Created by Spencer on 2021-11-08.
//

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include "petgroomsynch.h"



struct Groom
{
    int stations;
    int petTotal;

    int catTotal;
    int catTime;

    int dogTotal;
    int dogTime;

    int otherTotal;
    int otherTime;

    pet_t *petArray;
}Groom;


void populateArray(struct Groom* groom)
{
    groom->petArray = malloc(groom->petTotal * sizeof(pet_t));
    for (int i = 0; i < groom->catTotal; i++){ groom->petArray[i] = cat;}
    for (int i = groom->catTotal; i < groom->dogTotal + groom->catTotal; i++){ groom->petArray[i] = dog;}
    for (int i = groom->dogTotal + groom->catTotal; i < groom->petTotal; i++){ groom->petArray[i] = other;}
}

struct Groom* promptUser()
{
    struct Groom *userGen = malloc(sizeof(Groom));
    //Prompt user: How many grooming stations do you want?
    printf("How many grooming stations do you want?\n");
    int groomingStations;

    scanf("%d",&groomingStations);
    while(getchar() != '\n');
    printf("You want %d grooming stations.\n",groomingStations);

    //fflush(stdin);



    //How many pets do you intend to groom?
    printf("How many pets do you intend to groom?\n");
    int petCount;
    scanf("%d",&petCount);
    printf("You want to groom %d animals.\n",petCount);

    //Do you want to set custom groom time lengths for each animal type[y,n]?
    printf("Do you want to set custom groom time lengths for each animal type[y,n]?\n");
    char customTimeLengths;
    scanf("%c",&customTimeLengths);
    while(getchar() != '\n');
    int catTime = 10;
    int dogTime = 7;
    int otherTime = 5;
    if (customTimeLengths == 'y' || customTimeLengths == 'Y')
    {
        //How long should a cat take to groom?  [Default: 10]
        printf("How long should a cat take to groom?  [Default: 10]\n");
        scanf("%d",&catTime);
        printf("You want cats to take %d seconds.\n",catTime);

        //How long should a dog take to groom?  [Default: 7]
        printf("How long should a dog take to groom?  [Default: 7]\n");
        scanf("%d",&dogTime);
        printf("You want dogs to take %d seconds.\n",dogTime);


        //How long should other animals take to groom? [Default: 5]
        printf("How long should other animals take to groom?  [Default: 5]\n");
        scanf("%d",&otherTime);
        printf("You want other animals to take %d seconds.\n",otherTime);
    }
    else
    {
        printf("Using defaults. [Cat = 10, dog = 7, other = 5]\n");
    }

    //Randomize pet types?
    printf("Do you want to randomize animal types? [y/n]\n");
    char response;

    //while(getchar() != '\n');
    scanf("%c",&response);
    while(getchar() != '\n');
    int catCount, dogCount, otherCount;

    if (response == 'n' || response == 'N')
    {
        int temp = petCount;
        printf("Out of %d animals, how many should be cats?\n",temp);
        scanf("%d",&catCount);
        temp -= catCount;

        printf("Out of %d animals, how many should be dogs?\n",temp);
        scanf("%d",&dogCount);
        temp -= dogCount;

        if (temp < 0)
        {
            printf("Invalid amount of pets!");
            exit(-1);
        }
        else
        {
            otherCount = temp;
        }
    }
    else
    {
        unsigned int seed = time(NULL);
        srand(seed);
        int temp = petCount;
        catCount = rand() % (petCount / 2);
        temp -= catCount;
        dogCount = rand() % temp;
        temp -= dogCount;
        otherCount = temp;
    }
    printf("Spawned %d cats, %d dogs, and %d other-type animals.\n",catCount,dogCount,otherCount);


    userGen->catTotal = catCount;
    userGen->catTime = catTime;
    userGen->dogTotal = dogCount;
    userGen->dogTime = dogTime;
    userGen->otherTotal = otherCount;
    userGen->otherTime = otherTime;
    userGen->petTotal = petCount;
    userGen->stations = groomingStations;
    populateArray(userGen);
    return userGen;
}

struct Groom* autoGenerate()
{

    struct Groom *autoGen = malloc(sizeof(Groom));


    autoGen->stations = rand() % 50 +3;
    autoGen->petTotal = (rand() % (autoGen->stations*2) + autoGen->stations);

    int temp = autoGen->petTotal;
    autoGen->catTotal = rand() % temp;
    temp -= autoGen->catTotal;
    autoGen->dogTotal = rand() % temp;
    temp -= autoGen->dogTotal;
    autoGen->otherTotal = temp;

    autoGen->dogTime = 7;
    autoGen->catTime = 10;
    autoGen->otherTime = 5;

    printf("Initialized %d stations and %d pets.\n%d cats (10 sec each), %d dogs (7 sec each), %d others (5 sec each).\n"
            ,autoGen->stations,autoGen->petTotal,autoGen->catTotal,autoGen->dogTotal,autoGen->otherTotal);
    populateArray(autoGen);
    petgroom_init(autoGen->stations);
    return autoGen;
}

struct Groom* staticGenerate()
{
    struct Groom *staticGen = malloc(sizeof(Groom));
    staticGen->stations = 15;
    staticGen->petTotal = 200;
    staticGen->catTotal=75;
    staticGen->catTime=3;
    staticGen->dogTotal=60;
    staticGen->dogTime= 2;
    staticGen->otherTotal=65;
    staticGen->otherTime= 1;
    populateArray(staticGen);

    printf("Initialized %d stations and %d pets.\n%d cats (3 sec each), %d dogs (2 sec each), %d others (1 sec each).\n"
            ,staticGen->stations,staticGen->petTotal,staticGen->catTotal,staticGen->dogTotal,staticGen->otherTotal);
    populateArray(staticGen);

    petgroom_init(staticGen->stations);
    return staticGen;
}

void* newThread ()
{
    //sleep(1);
    sleep(rand()%2);
    int randPetID = rand()%3;
    char *output;
    if (randPetID == 0) output = "cat";
    if (randPetID == 1) output = "dog";
    if (randPetID == 2) output = "other";
    //printf("Randpet was a: %s.\n",output);
    //printf("Randpets should still be a: %s.\n",output);
    newpet(randPetID);
    //sleep(1);
    sleep(5);
    petdone(randPetID);
    pthread_exit(0);
}


void* parseArray(struct Groom *me)
{
    pthread_t threadIDs[me->petTotal];
    for (int i = 0; i < me->petTotal;i++)
    {
        pthread_attr_t attr;
        pthread_attr_init(&attr);
        pthread_create(&threadIDs[i], &attr,(void *) newThread, NULL);
    }
    for (int i = 0; i < me->petTotal;i++)
    {
        pthread_join(threadIDs[i],NULL);
    }
    return 0;
}

int main()
{
    unsigned int seed = time(NULL);
    srand(seed);
    //struct Groom *GroomingSalon = promptUser();
    struct Groom *GroomingSalon = staticGenerate();
    //struct Groom *GroomingSalon = autoGenerate();

    //pthread_t startMe;
    //pthread_create(&startMe, NULL,(void *) parseArray, (void *) GroomingSalon);
    //pthread_join(startMe,NULL);
    parseArray(GroomingSalon);
}