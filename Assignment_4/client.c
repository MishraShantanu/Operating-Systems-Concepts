//
// Created by Spencer on 2021-11-23.
//

#include "client.h"

#define PORT "30001" // the port client will be connecting to
#define MAX_MESSAGE_SIZE 100

void* get_in_addr(struct sockaddr *sa)
{
    if (sa->sa_family == AF_INET)
    {
        return &(((struct sockaddr_in*)sa)->sin_addr);
    }
    return &(((struct sockaddr_in6*)sa)->sin6_addr);

}

char* getInput()
{
    long bytesRead;
    int size = 100;
    char* message;

    message = (char *) malloc(MAX_MESSAGE_SIZE+1);

    puts("Please enter the message you wish to send to the server.\n");
    bytesRead = getline(&message, (size_t *) &size, stdin);

    if (bytesRead == -1)
    {
        printf("Fail.\n");
    }
    else
    {
        puts ("You typed:");
        puts (message);
    }
    return message;
}

int main(int argc, char *argv[])
{



    //void* x = getaddrinfo("me",NULL,NULL,NULL);
    //send(0,100,MAX_MESSAGE_SIZE,NULL);
    //char* hostname= malloc(100);
    size_t size = 100;
    char *hostname = malloc(size);
    int err = gethostname(hostname, size);
    if (err != 0)
    {
        printf("Fail! \n");
    }
    else
    {
        printf("Hi! Your hostname is: %s \n", hostname);
    }
    return 0;
}
