/*
Assignment 4.

Computer Science 332.3
Prof: Dr. Derek Eager
University of Saskatchewan - Arts & Science
	Department of Computer Science
A project by: Spencer Tracy | Spt631 | 11236962 and Shantanu Mishra | Shm572 | 11255997
__________________________________________________
 */

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

/* PURPOSE:
 * Stores the stocket information for connecting & communicating with server 
 * 
 */
typedef struct SocketInformation
{
    int fd;//stores the file descriptor number which is used for read/write of info 
    struct addrinfo *serverInformation; //info of the host server 
}SocketInformation;

#define MAXMSGLEN 500 //max length of a msg
#endif //ASSIGNMENT_4_RECEIVER_H
