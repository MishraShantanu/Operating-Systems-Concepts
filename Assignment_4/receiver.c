#include "receiver.h"
#define SERVERPORT "30003"


void printMessage(char* message)
{
    printf("Message recived: %s len : %ld \n",message, strlen(message));
    
}


int waitingForMessage(SocketInformation *socketInfo)
{   char buf[MAXMSGLEN];
    int  numberofbytes;  
    
        while(1) { //run a infinite loop to keep checking for new msgs 
        
            memset(buf,'\0',MAXMSGLEN*sizeof(char));
    
       if ((numberofbytes = recv(socketInfo->fd, buf, MAXMSGLEN-1, 0)) == -1) { //receive the msg and check if its successfully received 
                       perror("recv");
                     exit(1);
       }
       if(numberofbytes==0){ //check if the connection is lost from the server 
            perror("Receiver: Connection Lost.\n");
        }
        if(strlen(buf)>0){ //if the msg length is greater then 0 the print the msg
            print("msg found %d ",numberofbytes);
            buf[numberofbytes] = '\0';
            printMessage(buf);    
            numberofbytes = 0;
        }
//       printf("MSG recived form: %s ",buf);
       
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
            perror("listner: socket");
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
        printf("Error: The host name was not specified as command line argument.\n");
        return -1;
    }
      
    //get the hostname from args 
    char *desiredHost = argv[1];
    
    //attempt a connectio, try to resolve the hostname and create a socket connection 
    // to the host 
    SocketInformation *socketInfo = attemptConnection(desiredHost);
    
    //if connetion failed exit the program
    if (socketInfo == NULL) exit(-1);
    
    else printf("Connection successful!\n");
    
    //if connection was successfull the free the serverinfo
    freeaddrinfo(socketInfo->serverInformation);
    
    //loop in a infinite to keep checking if server fwd any msg 
    waitingForMessage(socketInfo);
    
    //close the fd
    close(socketInfo->fd);
    
    //releas the memory accquire by the socket
    free(socketInfo);
    
    return 0;
}

