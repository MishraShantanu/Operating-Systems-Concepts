//
// Created by Spencer on 2021-11-12.
//
#include "queue.h"
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

typedef enum {cat, dog, other} pet_t;



struct Groom
{
    int stations;
    int petTotal;

    int catTotal;

    int dogTotal;

    int otherTotal;
    pet_t *petArray;
}Groom;






struct queue_head {
    struct queue_head *next;
}queue_head;

struct queue_root {
    struct queue_head *head;
    struct queue_head *tail;
    struct queue_head divider;
    pthread_mutex_t head_lock;
    pthread_mutex_t tail_lock;
}queue_root;

#define QUEUE_POISON1 ((void*)0xCAFEBAB5)

void init()
{
    pthread_mutex_init(&queue_root.head_lock,NULL);
    pthread_mutex_init(&queue_root.tail_lock,NULL);
}

void queue_put(struct queue_head *new,
               struct queue_root *root)
{
    new->next = NULL;

    pthread_mutex_lock(&root->tail_lock);
    root->tail->next = new;
    root->tail = new;
    pthread_mutex_unlock(&root->tail_lock);
}


struct queue_head *queue_get(struct queue_root *root) {
    struct queue_head *head, *next;

    while (1) {
        pthread_mutex_lock(&root->head_lock);
        head = root->head;
        next = head->next;
        if (next == NULL) {
            // Only a single item enqueued:
            // queue is empty
            pthread_mutex_unlock(&root->head_lock);
            return NULL;
        }
        root->head = next;
        pthread_mutex_unlock(&root->head_lock);

        if (head == &root->divider) {
            // Special marker - put it back.
            queue_put(head, root);
            continue;
        }

        head->next = QUEUE_POISON1;
        return head;
    }
}



void populateArray(struct Groom* groom)
{
    groom->petArray = malloc(groom->petTotal * sizeof(pet_t));
    for (int i = 0; i < groom->catTotal; i++){ groom->petArray[i] = cat;}
    for (int i = groom->catTotal; i < groom->dogTotal + groom->catTotal; i++){ groom->petArray[i] = dog;}
    for (int i = groom->dogTotal + groom->catTotal; i < groom->petTotal; i++){ groom->petArray[i] = other;}
}

struct Groom* staticGenerate()
{
    struct Groom *staticGen = malloc(sizeof(Groom));
    staticGen->stations = 10;
    staticGen->petTotal = 50;
    staticGen->catTotal=15;
    staticGen->dogTotal=20;
    staticGen->otherTotal=15;
    populateArray(staticGen);

    printf("Initialized %d stations and %d pets.\n%d cats (3 sec each), %d dogs (2 sec each), %d others (1 sec each).\n"
            ,staticGen->stations,staticGen->petTotal,staticGen->catTotal,staticGen->dogTotal,staticGen->otherTotal);
    populateArray(staticGen);

    return staticGen;
}
void* newThread ()
{

    int randPetID = rand()%3;
    (randPetID);
    sleep(rand()%10);
    petdone(randPetID);
    pthread_exit(0);
}






int main()
{
    init();

    //3 queues, one dog, one cat, one other.
}