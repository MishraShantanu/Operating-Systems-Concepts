#include "server.h"

#define SENDERPORT "30002"
#define RECEIVERPORT "30003"

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


int main(int argc, char* argv[])
{
    printf("Hello.");
    return 0;
}