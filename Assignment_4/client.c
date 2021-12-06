/*
Assignment 4.

Computer Science 332.3
Prof: Dr. Derek Eager
University of Saskatchewan - Arts & Science
	Department of Computer Science
A project by: Spencer Tracy | Spt631 | 11236962 and Shantanu Mishra | Shm572 | 11255997
__________________________________________________
 */

/*                Features of client:
 *   - XYZ                   [Complete]
 *   - ABC                  [Complete]
 *  
 */

/*      Known bugs:
 *         NA
 *
 *  
 */

#include "client.h"
//#define SERVERPORT "30002"	// the port users will be connecting to

/* PURPOSE: Checks if user provided the right amount of arguments to run the program 
 * PRE-CONDITIONS: - argCount -- the count of the arguments provided by the user while running the program  
 *               
 * POST-CONDITIONS: Continues to next step if successful
 * RETURN: if successful then retuns 0 else return -1 or exits the program 
 */
int checkArgs(int argCount)
{
    if (argCount == 1)
    {
        printf("Error: You must specify the host and port you want to connect to as a command line argument.\n");
        return -1;
    }
    else if (argCount == 2)
    {
        printf("Error: You must provide the port used to communicate with the server.");
        return -1;
    }
    else if (argCount == 3)
    {
        return 0;
    }
    else
    {
        printf("Error: too many commandline arguments! Only need hostname and port.\n");
    }
    return -1;
}



/* PURPOSE: try connecting to the server by resoliving the host name creating sockets. Later tries to connect to the server and
   gets a fd value to return
 * PRE-CONDITIONS: - hostname -- name of the host to which receiver wants to connect
 *               
 * POST-CONDITIONS: receiver gets connected to the server. if error is generated in btw then it retuen null 
 * RETURN: fd - on success and on failure returns null 
 */
void* attemptConnection(char* hostName, char* SERVERPORT)
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


/* PURPOSE: Run the user program to send the broadcasted msgs
 * PRE-CONDITIONS: - argv[] -- user needs to provide the host name while running the program  
 *               
 * POST-CONDITIONS: user program starts and if the connection to the server is successfull then ask user for  broadcasted msg
 * and fwd it to the server 
 * 
 * RETURN: if successful then retuns 0 else return -1 or exits the program 
 */
int main(int argc, char *argv[])
{
    //Ensure user has inputted a proper amount of command line arguments.
    if (checkArgs(argc) != 0)
    {
        exit(-1);
    }

    char *desiredHost = argv[1];
    char *desiredPort = argv[2];

    int userinput;
    size_t userinput_size = MAXMSGLEN;
    char *userinput_string = (char *) malloc (userinput_size*sizeof(char));
 
    SocketInformation *socketInfo = attemptConnection(desiredHost,desiredPort);

    if (socketInfo == NULL)
    {
        exit(-1);
    }
    else
    {
        printf("Connection successful!\n");
    }
    
    
    while(1){ //keep looping in infinite loop 
         
         memset(userinput_string,'\0',MAXMSGLEN*sizeof(char));
         printf("Please enter a msg to broadcast: ");
         
         //gets broadcast msg from the user 
         userinput = getline(&userinput_string, &userinput_size, stdin);
//          printf("user input len %ld: ",strlen(userinput_string));
        
        if( userinput>-1)
        { //if user input was successfull
            unsigned long bytesSent;
            userinput_string[strlen(userinput_string+1)] = '\0';
            if ((bytesSent = sendto(socketInfo->fd,userinput_string, strlen(userinput_string), 0,socketInfo->serverInformation->ai_addr,
                             socketInfo->serverInformation->ai_addrlen)) == -1)
            {
                 //the sentto server failed 
                printf("Error: sendto() failed to send your message!\n");
               exit(-1);
            }
            
             printf("talker: sent %ld bytes to %s\n", bytesSent, desiredHost);
        }
    }
   
   //close the fd and relase the memory 
    close(socketInfo->fd);
    freeaddrinfo(socketInfo->serverInformation);
    free(socketInfo);
}

