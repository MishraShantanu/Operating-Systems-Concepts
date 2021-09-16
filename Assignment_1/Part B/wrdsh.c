#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

#define MAX_COMMAND_LENGTH 30

//Doubly linked list for commands given by user.
typedef struct _command {
    char name[MAX_COMMAND_LENGTH];        //Store the name of the command.
    //char* name;                         //Store the name of the command.
    struct _command *next;                 //The next command.
    struct _command *prev;                 //The previous command.

} Command;


//Typedef: Doubly linked list with element counter.
//TODO: Write tokens to a doubly linked list.
//TODO: Make a function that steps through the list.
//TODO: Make a function that appends to the list.
//TODO: Make a function that reverses the list. [Read right to left].

//TODO: RESOLVE CURRENT BUG WITH PRINTING NODES.

//TODO: find a way to handle bad inputs
//TODO: find a way to decern between executable programs and parameters.

void setLastNode(Command *srcChain,Command *endNode)
{
    printf("Apprending to last: %s\n",endNode->name);

    Command *walker = srcChain;
    while (walker->next != NULL) //Step to the end of the node-chain
    {
        walker = walker->next;
    }
    walker->next = endNode; // insert the new node at the end of the chain.
}

void printAllNodes(Command *srcChain)
{
    Command *walker = srcChain->next;
    printf("%s: ",srcChain->name);
    while (walker->next != NULL) //Step to the end of the node-chain
    {
        printf("%s, ",walker->name);
        walker = walker->next;
    }
    printf("%s\n",walker->name);
}


int shellLoop(Command *cmd)
{
    //printf("SHELL LOOP TRIGGERED.");
    printf("wrdsh> ");
    //Prepare to get user input, tokenized.
    char userInput[100];
    char buffer[100];
    char *token;

    //Sanitization check: did input work? If so, do stuff. If not, skip.
    if (fgets(userInput,sizeof(userInput),stdin))
    {
        //Copy to a buffer for tokenization, so we don't overwrite the user's input.
        strcpy(buffer, userInput);
        token = strtok(buffer, " ");

        //Special case: User is trying to exit the shell.
        if (strcmp("exit",token) == 0)
        {
            return (1);
        }

        /* SANITIZATION OF INPUT */
            //Did user just hit enter without input?
        if (strcmp(token,"\n") == 0)
        {
            return (0); //Try again.
        }

        //Start parsing the input.

        strncpy(cmd->name,token,sizeof(cmd->name));
        while (token)
        {
            Command *newcmd = calloc(1,sizeof(Command));
            strncpy(newcmd->name,token,sizeof(newcmd->name)); //Store the token as the current command's name.
            printf("cmdname: %s\n",cmd->name);
            setLastNode(cmd,newcmd); //Append to the end of the list.
            token = strtok(NULL, " ");
            free(newcmd);
        }
    }
    return (0);
}

int main(int argc, char *argv[])
{
    //int fileDescriptors[2]; //File descriptors. fd[0] = read  |   fd[1] = write

    //The following is the continuous input loop for the shell.
    int shellStatus = 0;
    printf("\nShell first run:\n");
    while(shellStatus != 1)
    {
        Command *getCmd = calloc(1,sizeof(Command));
        shellStatus = shellLoop(getCmd);
        printAllNodes(getCmd);
        // printf("cmd's next: %s",getCmd->next->name);
        //free(givenCommand);
        printf("Shell returned %d.\n",shellStatus);

    }





    //pipe(fileDescriptors);
    //int rc = fork(); // returns 0 to child, pid to parent

        //getpid();

    //Lets make a process via pipe.
    //pid_t p;
    //pipe(&p);   //FIFO
    //Lets learn about fork.



    //pipe(fd);   //FIFO




    //p = fork();
        //< 0 -> Fork failed.
        //

    //printf("%d\n", fd[1]);
    return 0;
}