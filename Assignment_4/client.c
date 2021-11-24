//
// Created by Spencer on 2021-11-23.
//


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#define MAXBUFLEN 100
#define SERVERPORT "30002"	// the port users will be connecting to

struct addrinfo hints, *servinfo, *p;

char* getInput()
{
    long bytesRead;
    int size = 100;
    char* message;

    message = (char *) malloc(MAXBUFLEN+1);

    puts("Please enter the message you wish to send to the server:\n");
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

void getHostName(char* host)
{
    int err = gethostname(host, MAXBUFLEN);
    if (err != 0)
    {
        printf("Failed to get your host name!! \n");
        exit(1);
    }
}




int main(int argc, char *argv[])
{
    long numbytes;
    char* host = malloc(MAXBUFLEN);
    getHostName(host);
    printf("Host: %s\n",host);

    int sockfd;
    int rv;

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_INET6; // set to AF_INET to use IPv4
    hints.ai_socktype = SOCK_DGRAM;

    if ((rv = getaddrinfo(host, SERVERPORT, &hints, &servinfo)) != 0)
    {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        return 1;
    }

    // loop through all the results and make a socket
    for(p = servinfo; p != NULL; p = p->ai_next) {
        if ((sockfd = socket(p->ai_family, p->ai_socktype,
                             p->ai_protocol)) == -1) {
            perror("talker: socket");
            continue;
        }

        break;
    }

    if (p == NULL)
    {
        fprintf(stderr, "talker: failed to create socket\n");
        return 2;
    }



    char* messagebuf = getInput();
    if ((numbytes = sendto(sockfd, messagebuf, strlen(messagebuf), 0,
                           p->ai_addr, p->ai_addrlen)) == -1)
    {
        perror("talker: sendto");
        exit(1);
    }

    freeaddrinfo(servinfo);
    printf("talker: sent %ld bytes to %s\n", numbytes, host);
    close(sockfd);

    return 0;
}
