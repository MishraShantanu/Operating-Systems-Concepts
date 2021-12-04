//
// Created by Spencer on 2021-11-29.
//

#ifndef ASSIGNMENT_4_RECEIVER_H
#define ASSIGNMENT_4_RECEIVER_H



#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <signal.h>

typedef struct SocketInformation
{
    int fd;
    struct addrinfo *serverInformation;
}SocketInformation;

#define MAXMSGLEN 500 //max length of a msg
#endif //ASSIGNMENT_4_RECEIVER_H
