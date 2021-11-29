//
// Created by Spencer on 2021-11-23.
//

#ifndef ASSIGNMENT_4_CLIENT_H
#define ASSIGNMENT_4_CLIENT_H

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <netdb.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>

typedef struct SocketInformation
{
    int fd;
    struct addrinfo *serverInformation;
}SocketInformation;

int checkArgs(int argCount);
void* attemptConnection(char* hostName);

#endif //ASSIGNMENT_4_CLIENT_H
