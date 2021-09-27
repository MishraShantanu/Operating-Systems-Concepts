/*
Assignment 1 Part B.

Computer Science 332.3
Prof: Dr. Derek Eager
University of Saskatchewan - Arts & Science
	Department of Computer Science
A project by: Spencer Tracy | Spt631 | 11236962 and Shantanu Mishra | Shm572 | TODO: ENTER YOUR STUDENT #
__________________________________________________
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>
#include <ctype.h>

#define MAX_COMMAND_LENGTH 400

/*                Features of wrdsh:
 *   - Parses a given line of input into executable commands.
 *   - Executes commands from right-to-left.
 *   - Supports pipes [ | ] and stdout redirection [ > ].
 *   - Duplicates letters of "c" "m" "p" "t" found in stdout.
 *
 *
 */


//TODO:
/*      Known bugs:
 *          Currently strips double-spacing contained within "  std   out quotes"
 *          Forwarding ( use of > ) is currently not handled correctly.
 *          Outputs mangled text when command is not found.
 *
 *      Features to implement:
 *          Handle "command not found" situations gracefully.
 *          Handle incorrect syntax (IE, ls |)
 *          Store args separately from desired executable within command.
 *
 */

/* PURPOSE:
 * Stores the given input in a doubly linked list of commands.
 */
typedef struct _command
{
    char name[MAX_COMMAND_LENGTH];         //Store the name of the command.
    struct _command *next;                 //The next command.
    struct _command *prev;                 //The previous command.
    struct _command *tail;                 //The last node in the chain.
    int forwards;                          //0 -> command does not need to forward stdout.  1-> forward stdout.
    char forwardsTo[MAX_COMMAND_LENGTH/2]; //If forwards is 1, where does cmd forward output to?
    int cmdCount;                          //The # of commands contained within this node chain.
} Command;


/* PURPOSE: executes individual commands by creating a child process using fork and later uses
 * execvp to execute the system call
 * PRE-CONDITIONS: - command: the command object which contains the name of command to be executed
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
 //  int fd[2];
 //   pipe(fd);


    while (token!=NULL)
    {
        tokens[counter] = token;
        counter+=1;
        token = strtok(NULL," ");
    }

    //The command should have null at end to show the end of command
    tokens[counter] =NULL;

    //forking to call the child process
    int rc= fork();
    if(rc<0)
    {
           //forking failed exit
        fprintf(stderr, "Fork failed \n");
        exit(1);
    }
    else if(rc==0)
    {
        if(command->prev!=NULL&command->next!=NULL){
            printf(" Middle command %s\n",command->name);
            close(fd[1]);
            dup2(fd[0],STDIN_FILENO);

            dup2(fd[1],STDOUT_FILENO);
            close(fd[0]);
            close(fd[1]);
            if (execvp(tokens[0], tokens) == -1)
            {
                perror("wrdsh");
            }



        }else if(command->prev==NULL&command->next!=NULL){
            printf(" Last command%s\n",command->name);

            close(fd[1]);
            dup2(fd[0],STDIN_FILENO);
            close(fd[0]);
            if (execvp(tokens[0], tokens) == -1)
            {
                perror("wrdsh");
            }


        }else if(command->prev!=NULL&command->next==NULL){
            printf(" First command%s\n",command->name);


            close(fd[0]);
            dup2(fd[1],STDOUT_FILENO);
            close(fd[1]);
            if (execvp(tokens[0], tokens) == -1)
            {\
                perror("wrdsh");
            }


        }else {
            //single command
            //child (new process)
           printf(tokens);
            if (execvp(tokens[0], tokens) == -1)
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

/* PURPOSE: Removes duplicate spaces (and trailing \n) from a given string.
 * PRE-CONDITIONS: - stripMe -> The string you wish to remove redundant spacing from.
 * POST-CONDITIONS: stripMe is modified (without redundant spacing or trailing \n).
 * RETURN: The given string without extra spaces.
 */
char *stripRedundantSpacing(char *stripMe)
{
    int currentInChar;
    int currentOutChar;

    currentInChar = 0;
    currentOutChar = 0;

    //Strip tailing new line if present.
    if (stripMe[strlen(stripMe) - 1] == '\n') stripMe[strlen(stripMe) - 1] = '\0';

    while (stripMe[currentInChar])
    {
        if (isspace(stripMe[currentInChar]) || iscntrl(stripMe[currentInChar]))
        {
            if (currentOutChar > 0 && !isspace(stripMe[currentOutChar-1]))
            {
                stripMe[currentOutChar++] = ' ';
            }
        }
        else
        {
            stripMe[currentOutChar++] = stripMe[currentInChar];
        }
        currentInChar++;
    }
    stripMe[currentOutChar] = 0;
    return stripMe;
}


/* PURPOSE: Appends a given token/command to the end of the node chain.
 * PRE-CONDITIONS: srcChain -- the first node in the node chain to append to.
 *                 endNode  -- the node to append at the end of the chain.
 * POST-CONDITIONS: srcChain is modified to include endNode.
 * RETURN: None.
 */
void setLastNode(Command *srcChain,Command *endNode)
{
    if (srcChain->cmdCount == 1)
    {
        srcChain->tail = endNode; //Update reference to tail.
        return;
    }

    Command *walker = srcChain;
    while (walker->next != NULL) //Step to the end of the node-chain
    {
        walker->next->prev = walker; //backlink the node.
        walker = walker->next;
    }
    walker->next = endNode; // insert the new node at the end of the chain.
    endNode->prev = walker; // Link new tail to the old.
    srcChain->tail = endNode; //Update reference to tail.
}



/* PURPOSE: Executes the given command (from right-to-left)
 * PRE-CONDITIONS: srcChain -- Node chain representing the sequence of commands to execute.
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
    while (walker->prev != NULL) //Walk back from the end of the chain towards the beginning.
    {
        runCommand(walker,fd);
        walker = walker->prev;
    }
    runCommand(walker,fd);
    return 0;
}


/* PURPOSE: Reads and parses a line of user input into a node chain of commands.
 * PRE-CONDITIONS: cmd -- Empty Command struct.
 * POST-CONDITIONS: cmd is modified such that it contains the user's command.
 * RETURN: 1 if user is trying to exit, 0 otherwise.
 */
int shellLoop(Command *cmd)
{
    printf("wrdsh> "); //Prompt for input.
    //Prepare to get user input, tokenized.
    char userInput[MAX_COMMAND_LENGTH];
    char buffer[MAX_COMMAND_LENGTH];
    char *token;
    const char forwardChar = '>';
    //Sanitization check: did input work? If so, parse it. If not, skip.
    if (fgets(userInput,sizeof(userInput),stdin) != NULL)
    {
        //Special case: Did user just hit enter without input?
        if (strcmp(userInput,"\n") == 0)
        {
            return (0); //Try again.
        }
        //Special case: User is trying to exit the shell.
        if (strcmp(userInput,"exit\n") == 0)
        {
            return (1);
        }
        //Copy input to a buffer (with redundant spaces removed)
        strcpy(buffer,userInput);
        strcpy(buffer,stripRedundantSpacing(buffer));
        //Separate commands by pipe:
        token = strtok(buffer, "|");
        strncpy(cmd->name,token,sizeof(cmd->name)); //Copy the first token's string to cmd->name.
        while (token)
        {
            cmd->cmdCount++; //Count each executable in the chain.
            Command *newCmd = calloc(1, sizeof(Command)); //Allocate a fresh cmd to append.

            char *cmdForwards = strchr(token,forwardChar); //Detect if the current command intends to forward stdout.
            if (cmdForwards)
            {
                newCmd->forwards++; //Set int boolean indicating this command has to forward.
                cmdForwards++; //skip the > char
                strncpy(newCmd->forwardsTo, cmdForwards, sizeof(newCmd->forwardsTo)); //Set where cmd wishes to forward.
                token = strtok(token,">");
                strncpy(newCmd->name, token, sizeof(newCmd->name));
                newCmd->forwards = 1;
                printf("Forward found! Forward %s to %s\n",newCmd->name,newCmd->forwardsTo);
            }
            else
            {
                strncpy(newCmd->name, token, sizeof(newCmd->name)); //Store the token as the current command's name.
            }
            setLastNode(cmd, newCmd); //Append to the end of the linked list.
            token = strtok(NULL, "|"); //Move to next cmd in pipe.
        }
    }
    return (0);
}


int main(int argc, char *argv[])
{
    int fileDescriptors[2]; //File descriptors. fd[0] = read  |   fd[1] = write
    pipe(fileDescriptors);

    //The following is the continuous input loop for the shell.
    int shellStatus = 0;
    printf("\nShell first run:\n");
    while(shellStatus != 1)
    {
        Command *getCmd = calloc(1, sizeof(Command));//Allocate an empty Command to store the loop's output.
        shellStatus = shellLoop(getCmd);//Trigger the 'get input' loop.
        execReverseOrder(getCmd,&fileDescriptors);
        printf("Shell returned %d.\n",shellStatus);
    }
    return 0;
}
