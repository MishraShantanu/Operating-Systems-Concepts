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

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include "petgroomsynch.h"

/* PURPOSE: Processes a new thread to randomly generate a pet, call newpet(), sleep for specified time, then call petdone().
 * PRE-CONDITIONS: long sleepTime --> how long to pause between newpet() and petdone().
 * POST-CONDITIONS: petgroomsynch.c will print to console (unless prints are disabled).
 * RETURN: None.
 */
void* newThread(long sleepTime)
{
    int randPetID = rand()%3;
    newpet(randPetID);
    sleep(sleepTime);
    if (petdone(randPetID) == -1)
        printf("Petdone failed!");
    pthread_exit(0);
}

/* PURPOSE: Spawns petTotal threads, used to randomly generate that many pets, and initSleepTime between thread spawns.
 * PRE-CONDITIONS: long initSleepTime --> how long to wait between new thread spawns.
 * POST-CONDITIONS: calls newThread petTotal amount of times, petgroomsynch will print to console.
 * RETURN: 0 == success, -1 == failure.
 */
int createThreadArray(long petTotal,long initSleepTime, long doneSleepTime)
{
    pthread_t threadIDs[petTotal];
    for (int i = 0; i < petTotal;i++)
    {
        sleep(initSleepTime);
        if (pthread_create(&threadIDs[i],NULL,(void *) newThread, (void*) doneSleepTime) != 0)
        {
            printf("pthread_create failed! Execution of program haulting...");
            return(-1);
        }
    }
    for (int i = 0; i < petTotal;i++)
    {
        pthread_join(threadIDs[i],NULL);
    }
    return 0;
}

//Main testing functions. Can be modified to include or exclude certain testing.
int main()
{
    unsigned int seed = time(NULL);
    srand(seed);


    //TESTER CONTROL OPTIONS: set test to 1 if you want to perform that test.
    int doFailureChecksTest = 1; // Quick test ensuring that invalid use of functions returns expected
                                //errors.
    int doSmallTest = 1; //Relatively short sample,
                            // 40 pets, 5 stations. 1 second delay between spawns, 5 seconds before petdone.
    int doMediumTest = 0; //This test is larger than the first, and takes a good bit of time to complete.
                            //100 pets, 15 stations. 2 second delay between spawns, 15 seconds before petdone.
    int doLargeTest = 0; //I don't recommend this unless you've got some serious time to kill.
                            //300 pets, 40 stations. 1 second delay between spawns, 12 seconds before petdone.
    int doFloodTest = 0; //Flood with new threads. Outside the design spec of this assignment.
                            //Contains bugs -- mutual exclusion between dogs and cats failures. Rare cases of hangs.
                            // 300 pets, 40 stations. No delay between newpet()s, 1 sec delay between petdone()s.



    //FailureChecksTest: Failure checks: double petgroom_init(), double petgroom_done(), petdone() on non-existing pet.
    if (doFailureChecksTest == 1)
    {
        printf("****BEGIN OF ERROR TESTING: Expect anything that doesn't start with 'ERROR!' to be "
               "expected errors from petgroomsych.c itself.\n\n");
        if (petgroom_init(10) != 0)
            printf("ERROR! First call to init should not have failed!\n");


        if (petgroom_init(20) != -1) //THIS WILL PRINT TO CONSOLE FROM petgroom_init() itself!
            printf("ERROR! Calling petgroom_init twice should have failed but did not.\n");

        newpet(cat);

        if (petdone(dog) != -1) //should generate an error in console -- clearing a non-existing pet.
            printf("ERROR! petdone succeeded on non-existing pet.");

        if (petgroom_done() == 0)   //should generate an error - done while pets still in grooming.
            printf("ERROR! petgroom_done succeeded while pets were not done being groomed.\n");

        if(petdone(cat) != 0)
            printf("ERROR! petdone failed when it should not have.");

        if (petgroom_done() != 0)
            printf("ERROR! petgroom_done should have succeeded but did not.\n");
        if (petgroom_done() == 0)
            printf("ERROR! petgroom_done called twice should not have succeeded but it did\n");
        printf("\n\n** END OF FAILURE TESTING**\nPlease disregard all errors generated above "
               "unless it starts with 'ERROR!'. Those were expected errors.\n\n");
    }

    //SmallTest: Small sample, randomly generated pets. Should complete successfully.
    if (doSmallTest ==1)
    {
        long stations = 5;
        long petTotal = 40;
        int initSleep = 1;
        int petDoneSleep = 5;
        if (petgroom_init((int) stations) != 0) {
            printf("ERROR![Small sample] First call to init should not have failed!"
                   "Previous petgroom_done() may have failed to mark as uninitialized.\n");
        } else {
            printf("***BEGINNING OF SmallTest**** (small sample, randomly generated)...\n"
                   "Initialized %lu stations and %lu pets.\nHas %d delay between thread spawns,"
                   "and a %d delay between newpet() and petdone()\n", stations, petTotal,initSleep,petDoneSleep);
            if (createThreadArray(petTotal, initSleep, petDoneSleep) == -1) {
                printf("One or more threads failed to create! Stopped execution of smallTest.");
            }
        }
        if (petgroom_done() != 0)
            printf("ERROR! [Small sample] petgroom_done should have succeeded but did not.\n");
        printf("\n\n\n***END OF SmallTest****\n\n\n");
    }

    if (doMediumTest == 1)
    {
        long stations = 15;
        long petTotal = 100;
        int initSleep = 2;
        int petDoneSleep = 15;
        if (petgroom_init((int) stations) != 0)
        {
            printf("ERROR![Medium sample] First call to init should not have failed!"
                   "Previous petgroom_done() may have failed to mark as uninitialized.\n");
        }
        else
        {
            printf("***BEGINNING OF MediumTest**** (medium sample, randomly generated)...\n"
                   "Initialized %lu stations and %lu pets.\nHas %d delay between thread spawns,"
                   "and a %d delay between newpet() and petdone()\n", stations, petTotal,initSleep,petDoneSleep);
            if (createThreadArray(petTotal, initSleep, petDoneSleep) == -1)
            {
                printf("One or more threads failed to create! Stopped execution of mediumTest.");
            }
       }
        if (petgroom_done() != 0)
            printf("ERROR! [medium sample] petgroom_done should have succeeded but did not.\n");

        printf("\n\n\n***END OF MediumTest****\n\n\n");
    }


    if (doLargeTest == 1)
    {
        long stations = 40;
        long petTotal = 300;
        int initSleep = 1;
        int petDoneSleep = 12;
        if (petgroom_init((int) stations) != 0)
        {
            printf("ERROR![Large sample] First call to init should not have failed!"
                   "Previous petgroom_done() may have failed to mark as uninitialized.\n");
        }
        else
        {
            printf("***BEGINNING OF LargeTest**** (Large sample, randomly generated)...\n"
                   "Initialized %lu stations and %lu pets.\nHas %d delay between thread spawns,"
                   "and a %d delay between newpet() and petdone()\n", stations, petTotal,initSleep,petDoneSleep);
            if (createThreadArray(petTotal, initSleep, petDoneSleep) == -1)
            {
                printf("One or more threads failed to create! Stopped execution of largeTest.");
            }
       }
        if (petgroom_done() != 0)
            printf("ERROR! [large sample] petgroom_done should have succeeded but did not.\n");
        printf("\n\n\n***END OF LargeTest  [Nice, you've been here a while I bet]. ****\n\n\n");


    }


    if (doFloodTest == 1)
    {
        long stations = 40;
        long petTotal = 300;
        int initSleep = 0;
        int petDoneSleep = 1;
        if (petgroom_init((int) stations) != 0)
        {
            printf("ERROR![FloodTest sample] First call to init should not have failed!"
                   "Previous petgroom_done() may have failed to mark as uninitialized.\n");
        }
        else
        {
            printf("***BEGINNING OF FloodTest**** (Large sample, randomly generated, no waits.)...\n"
                   "Initialized %lu stations and %lu pets.\nHas %d delay between thread spawns,"
                   "and a %d delay between newpet() and petdone()\n", stations, petTotal,initSleep,petDoneSleep);
            if (createThreadArray(petTotal, initSleep, petDoneSleep) == -1)
            {
                printf("One or more threads failed to create! Stopped execution of largeTest.");
            }
        }
        if (petgroom_done() != 0)
            printf("ERROR! [FloodTest] petgroom_done should have succeeded but did not.\n");
        printf("\n\n\n***END OF FloodTest  [Likely to have bugs]. ****\n\n\n");
    }
}
