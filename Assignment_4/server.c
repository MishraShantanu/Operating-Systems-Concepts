#include <time.h>
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

int startListener(void *portnumber)
{

    int isSender = 0;
    if (strcmp(portnumber,SENDERPORT) == 0)   isSender = 1;
    char *PORT = malloc(strlen(portnumber) + 1);;
    strncpy(PORT,portnumber , strlen(portnumber));


    int sockfd, new_fd;  // listen on sock_fd, new connection on new_fd
    struct addrinfo hints, *servinfo, *p;
    struct sockaddr_storage their_addr; // connector's address information
    socklen_t sin_size;
    struct sigaction sa;
    int yes=1;
    char s[INET6_ADDRSTRLEN];
    int rv;


    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_PASSIVE; // use my IP

    if ((rv = getaddrinfo(NULL, PORT, &hints, &servinfo)) != 0)
    {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        return 1;
    }

    // loop through all the results and bind to the first we can
    for(p = servinfo; p != NULL; p = p->ai_next)
    {
        if ((sockfd = socket(p->ai_family, p->ai_socktype,
                             p->ai_protocol)) == -1) {
            perror("server: socket");
            continue;
        }

        if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes,
                       sizeof(int)) == -1) {
            perror("setsockopt");
            exit(1);
        }

        if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
            close(sockfd);
            perror("server: bind");
            continue;
        }
        break;
    }

    freeaddrinfo(servinfo); // all done with this structure

    if (p == NULL)
    {
        fprintf(stderr, "server: failed to bind\n");
        exit(1);
    }

    if (listen(sockfd, BACKLOG) == -1)
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

    printf("server: waiting for connections at %s...\n",PORT);

    while(1)
    {  // main accept() loop
        sin_size = sizeof their_addr;
        new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size);
        if (new_fd == -1)
        {
            perror("accept");
            continue;
        }

        inet_ntop(their_addr.ss_family,
                  get_in_addr((struct sockaddr *)&their_addr),
                  s, sizeof s);
        //printf("server: got connection from %s\n", s);

        if (!fork())
        { // this is the child process
            close(sockfd); // child doesn't need the listener

            if (isSender == 1) //Handle receiving messages from sender clients.
            {
                long unsigned timeSent;
                if ((void*)(timeSent = (time_t) handleSender(new_fd,s)) == NULL)
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
        startListener(SENDERPORT);
    }
    else
    {
        startListener(RECEIVERPORT);
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

