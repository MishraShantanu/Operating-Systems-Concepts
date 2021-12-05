/*
Assignment 4.

Computer Science 332.3
Prof: Dr. Derek Eager
University of Saskatchewan - Arts & Science
	Department of Computer Science
A project by: Spencer Tracy | Spt631 | 11236962 and Shantanu Mishra | Shm572 | 11255997
__________________________________________________
 */


/*                Features of server:
 *   - XYZ                   [Complete]
 *   - ABC                  [Complete]
 *  
 */

/*      Known bugs:
 *         NA
 *
 *  
 */
#include "server.h"

#define SENDERPORT "30002"
#define RECEIVERPORT "30003"
#define BACKLOG 10
#define MAXMESSAGELENGTH 1000


//Start server
//Print ports.
//Start the listeners.

//Start listeners.
//Listen on port 30002 for new senders.
//Queue for new senders.
//Listen on port 30003 for new receivers.
//Queue for new receivers.

//New sender.
//Accept the connection on a new thread.
//Wait for a message from sender.
//Terminate.

//New receiver.
//Accept the connection on a new thread.
//wait until there is a message to be received.
//Send message to receiver(s).
//wait until receiver wants to terminate.
//Terminate (determined by receiver).

//Get message from a sender
//Pad message with their IP and port.
//Get which receivers are currently connected (and should get this message).

//Send message to a receiver.
//Get which receivers to send to.
//Queue sending the message to all current receivers.
//Send to each.

void* handleSender(int new_fd, char* givenIP)
{
    long unsigned numBytes;
    char buf[MAXMESSAGELENGTH];

    int fromLength = sizeof(struct sockaddr_storage);
    if ((numBytes = recv(new_fd,buf,MAXMESSAGELENGTH-1,fromLength)) == -1)
    {
        perror("recv");
        return NULL;
    }
    else
    {

        buf[numBytes] = '\0';
        char messageBuffer[INET6_ADDRSTRLEN + 12 + numBytes];
        strcpy(messageBuffer,"");
        strcat(messageBuffer,givenIP);
        strcat(messageBuffer,", ");
        strcat(messageBuffer,SENDERPORT);
        strcat(messageBuffer,": ");
        strcat(messageBuffer,buf);
        strcat(messageBuffer,"\0");

        struct tm * timeinfo;
        time_t receivedAt;
        time(&receivedAt);
        timeinfo = localtime(&receivedAt);
        printf("server: received '%s' [Consisting of %lu bytes] at %02d:%02d:%02d.\n"
                ,messageBuffer,strlen(messageBuffer),timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);
        return (void*) receivedAt;
    }
}

void sigchld_handler(int s)
{
    (void)s; // quiet unused variable warning

    // waitpid() might overwrite errno, so we save and restore it:
    int saved_errno = errno;

    while(waitpid(-1, NULL, WNOHANG) > 0);

    errno = saved_errno;
}

// get sockaddr, IPv4 or IPv6:
void *get_in_addr(struct sockaddr *sa)
{
    if (sa->sa_family == AF_INET) {
        return &(((struct sockaddr_in*)sa)->sin_addr);
    }

    return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

int startServer()
{
    printf("Server starting...\n");
    printf("\tAll senders should use port %s.\n",SENDERPORT);
    printf("\tAll receivers should use port %s.\n",RECEIVERPORT);

    printf("Starting listeners...\n");

    return 0;
}

void* createNewConnectionSocket(void *portNumber)
{
    struct addrinfo hints, *serverInfo, *serverInfoIterator;
    struct sockaddr_storage their_addr; // connector's address information
    struct sigaction sa;

    int newSocketFileDescriptor;
    int yes=1;
    int returnValue;


    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_PASSIVE; // use my IP


    if ((returnValue = getaddrinfo(NULL, portNumber, &hints, &serverInfo)) != 0)
    {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(returnValue));
        return NULL;
    }



    // loop through all the results and bind to the first we can
    for(serverInfoIterator = serverInfo; serverInfoIterator != NULL; serverInfoIterator = serverInfoIterator->ai_next)
    {
        if ((newSocketFileDescriptor = socket(serverInfoIterator->ai_family, serverInfoIterator->ai_socktype,
                             serverInfoIterator->ai_protocol)) == -1) {
            perror("server: socket");
            continue;
        }

        if (setsockopt(newSocketFileDescriptor, SOL_SOCKET, SO_REUSEADDR, &yes,
                       sizeof(int)) == -1) {
            perror("setsockopt");
            exit(1);
        }

        if (bind(newSocketFileDescriptor, serverInfoIterator->ai_addr, serverInfoIterator->ai_addrlen) == -1) {
            close(newSocketFileDescriptor);
            perror("server: bind");
            continue;
        }
        break;
    }


    if (serverInfoIterator == NULL)
    {
        fprintf(stderr, "server: failed to bind\n");
        exit(1);
    }

    if (listen(newSocketFileDescriptor, BACKLOG) == -1)
    {
        perror("listen");
        exit(1);
    }


    sa.sa_handler = sigchld_handler; // reap all dead processes
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_RESTART;
    if (sigaction(SIGCHLD, &sa, NULL) == -1)
    {
        perror("sigaction");
        exit(1);
    }


    struct SocketInformation *returnMe;
    returnMe = malloc(sizeof(SocketInformation));
    returnMe->fd = newSocketFileDescriptor;
    returnMe->serverInformation = serverInfo;
    freeaddrinfo(serverInfo);

    return returnMe;
}

int startListener(void *portNumber)
{
    int isSender = 0;
    if (strcmp(portNumber, SENDERPORT) == 0) isSender = 1;
    char *PORT = malloc(strlen(portNumber) + 1);
    strncpy(PORT, portNumber , strlen(portNumber));


    struct sockaddr_storage their_addr; // connector's address information
    socklen_t sin_size;
    char connectingIP[INET6_ADDRSTRLEN];

    printf("server: waiting for connections at %s...\n",PORT);
    SocketInformation *socketInfo = createNewConnectionSocket(portNumber);
    int new_fd;
    while(1)
    {  // main accept() loop
        sin_size = sizeof their_addr;
        new_fd = accept(socketInfo->fd, (struct sockaddr *)&their_addr, &sin_size);
        if (new_fd == -1)
        {
            perror("accept");
            continue;
        }

        inet_ntop(their_addr.ss_family,
                  get_in_addr((struct sockaddr *)&their_addr),
                  connectingIP, sizeof connectingIP);
        printf("server: got connection from %s\n", connectingIP);

        if (!fork())
        { // this is the child process
            close(socketInfo->fd); // child doesn't need the listener

            if (isSender == 1) //Handle receiving messages from sender clients.
            {
                long unsigned timeSent;
                if ((void*)(timeSent = (time_t) handleSender(new_fd, connectingIP)) == NULL)
                {
                    perror("handleSender");
                }
                else
                {
                    printf("RECEIVED MESSAGE AT: %lu",timeSent);
                    //TODO: Use the time returned by handleSender to determine which receivers to send to.
                }
            }
            else
            {
                //Wait for a message.
                //TODO: Use a condition variable here for waiting and broadcasting.
                if (send(new_fd, "Hello, world!", 13, 0) == -1)
                    perror("send");
            }

            close(new_fd);
            exit(0);
        }
        close(new_fd);  // parent doesn't need this
    }
}


int main(void)
{
    startServer();
    int rc = fork();
    if(rc==0)
    {
        pthread_t senderListener;
        pthread_create(&senderListener,NULL,(void*) startListener,(void*) SENDERPORT);
        pthread_join(senderListener,NULL);
    }
    else
    {
        pthread_t receiverListener;
        pthread_create(&receiverListener,NULL,(void*) startListener,(void*) RECEIVERPORT);
        pthread_join(receiverListener,NULL);
    }

    /*
For each connection, do this in order:
    1. getaddrinfo();
        //    getaddrinfo(NULL, MYPORT, &hints, &res);
    2. socket();
        //    sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    3. bind();
        //    bind(sockfd, res->ai_addr, res->ai_addrlen);
    4. listen();
        //    listen(sockfd, BACKLOG);
    5. accept();
        //    int new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &addr_size);
     */

    return 0;
}

