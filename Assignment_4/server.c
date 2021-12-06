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
#define MAXCONNECTIONS 10

char buf[MAXMESSAGELENGTH];
int socket_arr[MAXCONNECTIONS];

int recevercount = 0,receverremaining = 0;

struct clientinfo {
    int fd;
    char ip[MAXMESSAGELENGTH + INET_ADDRSTRLEN];
} allclientinfo[MAXCONNECTIONS];

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

void sigchld_handler(int s)
{
    (void)s; // quiet unused variable warning

    // waitpid() might overwrite errno, so we save and restore it:
    int saved_errno = errno;

    while(waitpid(-1, NULL, WNOHANG) > 0);

    errno = saved_errno;
}



int startServer()
{
    printf("Server starting...\n");
    printf("\tAll senders should use port %s.\n",SENDERPORT);
    printf("\tAll receivers should use port %s.\n",RECEIVERPORT);

    printf("Starting listeners...\n");

    return 0;
}


// get sockaddr, IPv4 or IPv6:
void *get_in_addr(struct sockaddr *sa)
{
    if (sa->sa_family == AF_INET) {
        return &(((struct sockaddr_in*)sa)->sin_addr);
    }

    return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

void* handleSender(void *socketinfo)
{
    struct SocketInformation *tmpsocketinfo = (struct SocketInformation*) socketinfo;
    char tempBuf[MAXMESSAGELENGTH];
    int numBytes;
    int fromLength = sizeof(struct sockaddr_storage);
    while(1)
    {
        if ((numBytes = recv(tmpsocketinfo->fd,buf,MAXMESSAGELENGTH-1,fromLength)) == -1)
        {
            perror("recv");
            exit(1);
        }
        else if(numBytes==0)
        {
            perror("Server: Sender Connection Lost.\n");
        }
        else
        {
            tempBuf[numBytes] = '\0';
            char messageBuffer[INET6_ADDRSTRLEN + 12 + numBytes];
            strcpy(messageBuffer,"");
            strcat(messageBuffer,tmpsocketinfo->serverInformation->ai_canonname);
            strcat(messageBuffer,", ");
            strcat(messageBuffer,SENDERPORT);
            strcat(messageBuffer,": ");
            strcat(messageBuffer,tempBuf);
            strcpy(buf,messageBuffer);
        }
    }

    //TODO: No idea how to reach this code, nor where socket is defined...
    //close(socket);
}
void *handleReceiver(void *socketinfo)
{
    //int counter_send;
    int socket = *(int *)socketinfo;
    int sent = 0;
    
    pthread_detach(pthread_self());
    
    while(1){
        
        if((sent = send(socket,buf,MAXMESSAGELENGTH,0)) < 0 ){
            printf("Error: sendto() failed to send your message to the receiver!\n");
            exit(1);
        }
    }
}

void* createNewConnectionSocket(void *portNumber)
{
    struct addrinfo hints, *serverInfo, *serverInfoIterator;
 //   struct sockaddr_storage their_addr; // connector's address information
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



int main(void){
      
   startServer();
     SocketInformation *sendersocketInfo = createNewConnectionSocket(SENDERPORT);
     SocketInformation *receiversocketInfo = createNewConnectionSocket(RECEIVERPORT);
    
      freeaddrinfo(sendersocketInfo->serverInformation);
      freeaddrinfo(receiversocketInfo->serverInformation);
      
      fd_set listner_fdlist;
      if( (listen(sendersocketInfo->fd,BACKLOG)!=0) &&( listen(receiversocketInfo->fd,BACKLOG)!=0)){
         perror("Server failed to listen sender or receiver port \n");
      }
      pthread_t listner;

      int clientid = 0;
      while(1){
          
          FD_ZERO(&listner_fdlist);
          
          FD_SET(sendersocketInfo->fd,&listner_fdlist);
          FD_SET(receiversocketInfo->fd,&listner_fdlist);
          
          if(select(sendersocketInfo->fd+1,&listner_fdlist,NULL,NULL,NULL)<0){
              perror("Server failed to select \n");
          }else{  
                        struct sockaddr_storage their_addr; // connector's address information
                        socklen_t sin_size;
                        char connectingIP[INET6_ADDRSTRLEN];
              
              if(FD_ISSET(receiversocketInfo->fd,&listner_fdlist)){
                  
                    socket_arr[clientid] = accept(receiversocketInfo->fd, (struct sockaddr *)&their_addr, &sin_size);
                if (socket_arr[clientid] == -1)
                {
                        perror("receiver\n");
                        
                }else{
                    inet_ntop(their_addr.ss_family,
                  get_in_addr((struct sockaddr *)&their_addr),
                  connectingIP, sizeof connectingIP);
                  printf("server: got connection from %s\n", connectingIP);
                    
                    recevercount += 1;
                     if(pthread_create(&listner,NULL,(void*) handleReceiver,(void*) &socket_arr[clientid]) == -1){
                          perror("Error creating a new receiver handler thread \n");
                     };
                    clientid +=1;
                    
                    
                }

              }
              
              if(FD_ISSET(sendersocketInfo->fd,&listner_fdlist)){
                  
                    socket_arr[clientid] = accept(sendersocketInfo->fd, (struct sockaddr *)&their_addr, &sin_size);
                if (socket_arr[clientid]== -1)
                {
                        perror("receiver\n");
                        
                }else{
                    inet_ntop(their_addr.ss_family,
                  get_in_addr((struct sockaddr *)&their_addr),
                  connectingIP, sizeof connectingIP);
                  printf("server: got connection from %s\n", connectingIP);
                    
                    
                    allclientinfo[clientid].fd = socket_arr[clientid];
					strcpy(allclientinfo[clientid].ip,connectingIP);
                    
                    recevercount += 1;
                     if(pthread_create(&listner,NULL,(void*) handleSender,(void*) &allclientinfo[clientid]) == -1){
                          perror("Error creating a new receiver handler thread \n");
                     };
                    clientid +=1;
                    
                    
                }

              }
              
             
              
              
              
              
          }
      }
}