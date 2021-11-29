#include "client.h"
#define SERVERPORT "30002"	// the port users will be connecting to


int checkArgs(int argCount)
{
    if (argCount == 1)
    {
        printf("Error: You must specify the hostname and your message as cmdline args.\n");
        exit(-1);
    }
    else if (argCount == 2)
    {
        printf("Error: The host name was not specified as command line argument (or desired message was not included).\n");
    }
    else if (argCount == 3)
    {
        return 0;
    }
    else
    {
        printf("Error: Cannot parse the given command line arguments -- too many given!\n"
               "(Did you forget to put your message in quotes?)\n");
    }
    return -1;
}

void* attemptConnection(char* hostName)
{
    printf("Attempting to connect to host %s on port %s...\n",hostName,SERVERPORT);

    //Setup for printing IP Address.
    char ipstr[INET6_ADDRSTRLEN + 11]; //IPv6 length + room for printing.
    void *addr;
    char *ipver;

    int socketFileDescriptor;
    int returnValue;
    struct addrinfo hints, *serverInfo, *serverInfoIterator;
    memset(&hints, 0, sizeof hints);

    hints.ai_family = AF_UNSPEC; //IPv4 and IPv6 are fine.
    hints.ai_socktype = SOCK_STREAM; //TCP connection

    if ((returnValue = getaddrinfo(hostName, SERVERPORT, &hints, &serverInfo)) != 0)
    {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(returnValue));
        return NULL;
    }
    // loop through all the results and make a socket

    //Populate and create a socket.
    for(serverInfoIterator = serverInfo; serverInfoIterator != NULL; serverInfoIterator = serverInfoIterator->ai_next)
    {
        if (serverInfoIterator->ai_family == AF_INET)
        { // IPv4
            struct sockaddr_in *ipv4 = (struct sockaddr_in *)serverInfoIterator->ai_addr;
            addr = &(ipv4->sin_addr);
            ipver = "Host IPv4: ";
        }
        else
        { // IPv6
            struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)serverInfoIterator->ai_addr;
            addr = &(ipv6->sin6_addr);
            ipver = "Host IPv6: ";
        }
        if ((socketFileDescriptor = socket(serverInfoIterator->ai_family,
                             serverInfoIterator->ai_socktype,
                             serverInfoIterator->ai_protocol)) == -1)
        {
            perror("talker: socket");
            continue;
        }
        break;
    }

    //Did socket creation fail?
    if (serverInfoIterator == NULL)
    {
        fprintf(stderr, "Error: failed to create socket for connection attempt.\n");
        return NULL;
    }

    //Print host IP.
    inet_ntop(serverInfoIterator->ai_family, addr, ipstr, sizeof ipstr);
    printf("\t%s%s\n", ipver, ipstr);

    //Attempt connection to server.
    if (connect(socketFileDescriptor, serverInfo->ai_addr, serverInfo->ai_addrlen) != 0)
    {
        printf("Error: Connection refused by server.\n");
        return NULL;
    }
    //Return socket file descriptor and server information.
    struct SocketInformation *returnMe;
    returnMe = malloc(sizeof(SocketInformation));
    returnMe->fd = socketFileDescriptor;
    returnMe->serverInformation = serverInfo;

    return returnMe;
}



int main(int argc, char *argv[])
{
    //Ensure user has inputted a proper amount of command line arguments.
    if (checkArgs(argc) != 0)
    {
        exit(-1);
    }

    char *desiredHost = argv[1];
    char *desiredMessage = argv[2];
    unsigned long messageLength = strlen(desiredMessage);

    SocketInformation *socketInfo = attemptConnection(desiredHost);

    if (socketInfo == NULL)
    {
        exit(-1);
    }
    else
    {
        printf("Connection successful!\n");
    }

    unsigned long bytesSent;
    if ((bytesSent = sendto(socketInfo->fd, desiredMessage, messageLength, 0,
                         socketInfo->serverInformation->ai_addr,
                         socketInfo->serverInformation->ai_addrlen)) == -1)
    {
        printf("Error: sendto() failed to send your message!\n");
        exit(-1);
    }
    printf("talker: sent %ld bytes to %s\n", bytesSent, desiredHost);
    close(socketInfo->fd);
    freeaddrinfo(socketInfo->serverInformation);
    free(socketInfo);
}

//    if ((numbytes = sendto(sockfd, messagebuf, strlen(messagebuf), 0,
//                           p->ai_addr, p->ai_addrlen)) == -1)
//    {
//        perror("talker: sendto");
//        exit(1);
//    }
//
//    freeaddrinfo(servinfo);
//    printf("talker: sent %ld bytes to %s\n", numbytes, host);
//    close(sockfd);
//
//    return 0;
//}
