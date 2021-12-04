#include "receiver.h"
#define SERVERPORT "30003"

// int startConnection()
// {
//     //get host
//     //create socket
//     //attempt to connect.
    
// }

void printMessage(char* message)
{
    printf("Message recived: %s\n",message);
    
    exit(0);
}


int waitingForMessage(SocketInformation *socketInfo)
{   char buf[140];
    int  numbytes;  
    //check if server sent message.
    
        while(1) {
       
    
	    if ((numbytes = recv(socketInfo->fd, buf, 140-1, 0)) == -1) {
	        perror("recv");
	        exit(1);
	    }
        
        
        if(strlen(buf)>0){
            buf[numbytes] = '\0';
            printMessage(buf);
            
        }
        
       
    }
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

int checkArgs(int argCount)
{
    if (argCount == 1)
    {
        printf("Error: You must specify the host you want to connect to as a command line argument.\n");
        exit(-1);
    }
    else if (argCount == 2)
    {
        return 0;
    }
    else
    {
        printf("Error: too many commandline arguments! Only need hostname.\n");
    }
    return -1;
}


int main(int argc, char* argv[])
{   
    //Ensure user has inputted a proper amount of command line arguments.
    if (checkArgs(argc) != 0)
    {
        exit(-1);
    }

    char *desiredHost = argv[1];

    SocketInformation *socketInfo = attemptConnection(desiredHost);
    if (socketInfo == NULL) exit(-1);
    else printf("Connection successful!\n");
    
    freeaddrinfo(socketInfo->serverInformation);
    
    
     waitingForMessage(socketInfo);
    

    close(socketInfo->fd);
    
    free(socketInfo);
    
    return 0;
}

