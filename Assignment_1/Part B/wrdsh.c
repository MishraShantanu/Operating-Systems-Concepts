/*
Assignment 1 Part B.

Computer Science 332.3
Prof: Dr. Derek Eager
University of Saskatchewan - Arts & Science
	Department of Computer Science
A project by: Spencer Tracy | Spt631 | 11236962 and Shantanu Mishra | Shm572 | 11255997
__________________________________________________
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

#define MAX_COMMAND_LENGTH 400
#define INPUT_FD 0
#define OUTPUT_FD 1

/*                Features of wrdsh:
 *   - Parses a given line of input into executable commands.    [Complete]
 *   - Executes commands from right-to-left.                     [Complete]
 *   - Supports pipes [ | ] and stdout redirection [ > ].
 *   - Duplicates letters of "c" "m" "p" "t" found in stdout.
 */


//A simple comment.

//TODO:
/*      Known bugs:
 *          Currently strips double-spacing contained within "  std   out quotes"
 *          Forwarding ( use of > ) is currently not handled correctly.
 *
 *      Features to implement:
 *          Handle "command not found" situations gracefully.
 *          Handle incorrect syntax (IE, ls |)
 *          Store args separately from desired executable within command.
 *          Duplicate letters of c - m - p - t in stdout.
 */

/* PURPOSE:
 * Stores the given input in a doubly linked list of commands to be executed.
 */
typedef struct command
{
    char name[MAX_COMMAND_LENGTH];         //Store the name of the command.
    struct command *next;                  //The next command in the node chain.
    struct command *prev;                  //The previous command in the node chain.
    struct command *tail;                  //The last node in the chain.
    int forwards;                          //0 -> command does not need to forward stdout.  1-> forward stdout.
    char forwardsTo[MAX_COMMAND_LENGTH/2]; //If forwards == 1, the location which the command will forward stdout to.
    int cmdCount;                          //The # of commands contained within this node chain.
} Command;


/* PURPOSE: Executes individual commands by creating a child process using fork and later uses
 * execvp to execute the system call
 * PRE-CONDITIONS: - command -- The command object which contains the name of command to be executed.
 *                   fd      -- The intended file descriptors inherited by execReverseOrder.
 * POST-CONDITIONS: Individual command is executed.
 * RETURN: None.
 */
void runCommand(Command *command, int *fd)
{
    //TODO: Handle "no such command found"
    //TODO: Handle cmd.forwards == 1  [forward stdout to destination]
    //initialize variable to tokenize the given command
    char **tokens[100];
    int counter = 0;
    char *token = strtok(command->name," ");
    while (token!=NULL)
    {
        tokens[counter] = (char **) token;
        counter+=1;
        token = strtok(NULL," ");
    }
    //The command should have null at end to show the end of command
    tokens[counter] =NULL;

    //forking to call the child process
    int rc= fork();
    if(rc<0) //forking failed exit
    {
        fprintf(stderr, "Fork failed \n");
        exit(1);
    }
    else if(rc==0)
    {
        if(((command->prev)!=NULL)&((command->next)!=NULL))
        {
            printf(" Middle command %s\n",command->name);
            close(fd[OUTPUT_FD]);
            dup2(fd[INPUT_FD],STDIN_FILENO);
            dup2(fd[OUTPUT_FD],STDOUT_FILENO);
            //close(fd[0]);
            //close(fd[1]);
            if (execvp((const char *) tokens[0], (char *const *) tokens) == -1)
            {
                perror("wrdsh");
            }
        }
        else if(((command->prev)==NULL)&((command->next)!=NULL))
        {
            printf(" Last command%s\n",command->name);

            close(fd[OUTPUT_FD]);
            dup2(fd[INPUT_FD],STDIN_FILENO);
            close(fd[INPUT_FD]);
            if (execvp((const char *) tokens[0], (char *const *) tokens) == -1)
            {
                perror("wrdsh");
            }
        }
        else if(((command->prev)!=NULL)&((command->next)==NULL))
        {
            printf(" First command%s\n",command->name);

            close(fd[INPUT_FD]);
            dup2(fd[OUTPUT_FD],STDOUT_FILENO);
            close(fd[OUTPUT_FD]);
            if (execvp((const char *) tokens[0], (char *const *) tokens) == -1)
            {
                perror("wrdsh");
            }
        }
        else
        {
            //single command
            //child (new process)
          // printf(tokens);
            if (execvp((const char *) tokens[0], (char *const *) tokens) == -1)
            {
                perror("wrdsh");
            }
        }
    }
    else
    {
        //original parent process
        int wait_count =wait(NULL);
        printf("parent return code: %d ", wait_count);
    }
    printf("command completed\n");
}

/* PURPOSE: Executes the given command (from right-to-left)
 * PRE-CONDITIONS: srcChain -- Node chain representing the sequence of commands to execute.
 *                 fd       -- File descriptors to be passed to each command.
 * POST-CONDITIONS: Triggers runCommand() on each node in srcChain.
 * RETURN: 0 if execution was successful, 1 when execution has failed.
 */
int execReverseOrder(Command *srcChain, int *fd)
{
    if (srcChain->cmdCount == 0) // Check if given an empty srcChain.
    {
        return (1);
    }

    Command *walker = srcChain->tail;
    while (walker->prev != NULL) //Walk back from the end of the chain towards the beginning, executing each command.
    {
        runCommand(walker,fd);
        walker = walker->prev;
    }
    runCommand(walker,fd);
    return 0;
}


/* PURPOSE: Appends a given token/command to the end of the node chain.
 * PRE-CONDITIONS: srcChain -- the first node in the node chain to append to.
 *                 endNode  -- the node to append at the end of the chain.
 * POST-CONDITIONS: srcChain is modified to include endNode.
 * RETURN: None.
 */
void setLastNode(Command *srcChain,Command *endNode)
{
    if (srcChain->cmdCount == 0)
    {
        srcChain->tail = endNode; //Update reference to tail.
        srcChain->cmdCount++;
        return;
    }
    Command *walker = srcChain;
    while (walker->next != NULL) //Step to the end of the node-chain
    {
        walker->next->prev = walker; //Backlink each node.
        walker = walker->next;
    }
    walker->next = endNode;     //Insert the new node at the end of the chain.
    endNode->prev = walker;     //Link new tail to the old.
    srcChain->tail = endNode;   //Update reference to tail.
    srcChain->cmdCount++;
}

/* PURPOSE: To take a line of input and parse it into a struct Command.
 * PRE-CONDITIONS: parseMe -- The text to be transformed into a command.
 * POST-CONDITIONS: parseMe is modified via tokenization (only when forwarding is detected).
 * RETURN: A command consistent with the properties of parseMe.
 */
Command * createCommand(char* parseMe)
{
    Command *newPipe = calloc(1,sizeof(Command));
    strcpy(newPipe->name,parseMe);  //Create a new command, copy given text as name.
    if (strrchr(parseMe,'<'))    //Does this new command expect to forward stdout somewhere else?
    {
        char *token;
        char *savePointer;
        char cmdBuffer[MAX_COMMAND_LENGTH] = "";

        token = strtok_r(parseMe, " ", &savePointer); //Crawl over each word in the input.
        while (token)
        {
            if (strcmp(token,"<") == 0)   //Once we have found where the command intends to forward stdout,
            {
                strcpy(newPipe->name,savePointer);     //Save the command's name.
                newPipe->forwards = 1;                 //Declare this command intends to forward.
                strcpy(newPipe->forwardsTo,cmdBuffer); //Save the destination of the intended forward.
            }
            strcat(cmdBuffer,token);                   //Keep copying words into the buffer for each token.
            token = strtok_r(0," ",&savePointer);
        }
    }
    return newPipe;
}


/* PURPOSE: Reads and parses a line of user input into a node chain of commands.
 * PRE-CONDITIONS: userCommands -- Empty Command struct.
 * POST-CONDITIONS: userCommands is modified such that it contains the user's command.
 * RETURN: 1 if user is trying to exit, 0 otherwise.
 */
int shellLoop(Command *userCommands)
{
    printf("wrdsh> "); //Prompt for input.
    char userInput[MAX_COMMAND_LENGTH];
    char buffer[MAX_COMMAND_LENGTH];

    //Sanitization check: did input work? If so, parse it. If not, skip.
    if (fgets(userInput, sizeof(userInput), stdin) != NULL)
    {
        strcpy(buffer, userInput);
        if (strcmp(userInput, "\n") == 0) return (0);            //Special case: Did user just hit enter without input?
        if (strcmp(userInput, "exit\n") == 0) return (1);        //Special case: User is trying to exit the shell.
        if (buffer[strlen(buffer) - 1] == '\n') buffer[strlen(buffer) - 1] = '\0'; //Replace \n with \0
        char *token;
        char *savePointer;
        char cmdBuffer[MAX_COMMAND_LENGTH] = "";
        token = strtok_r(buffer, " ", &savePointer);  //Step through each separate word given by the user.
        while (token)
        {
            if (strcmp(token,"|") == 0)  //When a pipe is detected, create a command from everything that preceded it.
            {
                token = strtok_r(0," ",&savePointer);       //Move past the "|" to the next found word.
                setLastNode(userCommands,createCommand(cmdBuffer)); //Link this new command to userCommands.
                strcpy(cmdBuffer,""); //Reset the buffer so a new command can be created.
            }
            strcat(cmdBuffer,token);  //Continue to step through each word, saving each one to cmdBuffer.
            strcat(cmdBuffer," ");
            token = strtok_r(0," ",&savePointer);
        }
        setLastNode(userCommands,createCommand(cmdBuffer)); //Create a command from buffer and link it to userCommands.
    }
    return 0;
}



int main(__attribute__((unused)) int argc, __attribute__((unused)) char *argv[])
{
    int fileDescriptors[2]; //File descriptors. fd[0] = read  |   fd[1] = write
    pipe(fileDescriptors);

    //The following is the continuous input loop for the shell.
    int shellStatus = 0;
    printf("\nShell first run:\n");
    while(shellStatus != 1)
    {
        Command *getCmd = calloc(1, sizeof(Command));//Allocate an empty Command to store the loop's output.
        shellStatus = shellLoop(getCmd);                    //Trigger the 'get input' loop.
        execReverseOrder(getCmd, (int *) &fileDescriptors); //Execute all commands given by the shell.
        printf("Shell returned %d.\n",shellStatus);
    }
    return 0;
}
