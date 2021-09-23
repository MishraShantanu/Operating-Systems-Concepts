#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

#define MAX_COMMAND_LENGTH 100


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
 *          Stripping more than one space at the beginning of the command is not working as intended.
 *
 *
 *      Features to implement:
 *          Handle "command not found" situations gracefully.
 *          Handle incorrect syntax
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
    int cmdCount;                          //The # of commands contained within this node chain.
} Command;


/* PURPOSE: executes individual commands by creating a child process using fork and later uses
 * execvp to execute the system call
 * PRE-CONDITIONS: - command: the command object which contains the name of command to be executed
 * POST-CONDITIONS: Individual command is executed.
 * RETURN: None.
 */
void runCommand(Command *command){
    //initialize variable to tokenize the given command
    char **tokens[100];
    int counter = 0;
    char * token = strtok(command->name," ");


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
        //child (new process)
        printf(tokens);
        if (execvp(tokens[0], tokens) == -1)
        {
            perror("wrdsh");
        }
    }
    else
    {

        //original parent process

        int wait_count =wait(NULL);
       // printf("parent return code: %d ", wait_count);
    }
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
int execReverseOrder(Command *srcChain)
{
    //TODO: Handle "no such command"

    if (srcChain->cmdCount == 0) // Check if given an empty srcChain.
    {
        return (1);
    }

    Command *walker = srcChain->tail;
    while (walker->prev != NULL) //Walk back from the end of the chain towards the beginning.
    {
        runCommand(walker);
        walker = walker->prev;
    }
    runCommand(walker);
    return 0;
}

/* PURPOSE: Sanitizes user input, storing commands, arguments, and parameters into the Command structure.
 * PRE-CONDITIONS: givenCmd -- the Command to parse out.
 * POST-CONDITIONS: givenCmd is modified to reflect the desired command.
 * RETURN: None.
 */
Command parseInput(char* givenInput)
{
    //Store the desired command in a buffer:
    char cmdBuffer[MAX_COMMAND_LENGTH];
    strcpy(cmdBuffer,givenInput);

    int cmdForwards = 0;
    int cmdPipes = 0;
    int cmdArgs = 0;



    //Check if the cmd is meant to forward output to another program:
    const char redirect = '>';
    char *forwardTo = strchr(cmdBuffer, redirect);
    char *execCMD = strtok(cmdBuffer, " ");
    if (forwardTo != NULL) {cmdForwards++;}

    //printf("users input: %s    after %c    is %s.\n",givenCmd->name,redirect,forwardTo);



    printf("User wants to execute command: %s  -- does command forward?  %d \n",execCMD,cmdForwards);
    if (cmdForwards == 1) printf("Command forwards to: %s\n",forwardTo);

    //Tokenize next -- does it start with "? does it start with -? does it start with --?


    //Handle syntax errors (ie wrdsh> ls |)
    //Handle spacing issues (ie wrdsh>   echo   "hello"  )


    //Strip new line char at the end of given command.
    //if (token[strlen(token) - 1] == '\n') token[strlen(token) - 1] = '\0';

    //Strip leading and trailing spaces
    //Strip space at beginning and end of inputted command.
    //Any time two or more spaces discovered, change to only one.

    //Delimit by |
    //Run pipe?

    //Delimit by "sample string text"
    //Store in args?

    //Delimit by -
    //Single character commands.
    //Delimit by --
    //sub-routine (word-like commands)

    //Delimit by >  [stdout]

    //Store parameters different from desired executable.

}

/* PURPOSE: Reads and parses a line of user input into a node chain of commands.
 * PRE-CONDITIONS: cmd -- Empty Command struct.
 * POST-CONDITIONS: cmd is modified such that it contains the user's command.
 * RETURN: 1 if user is trying to exit, 0 otherwise.
 */
int shellLoop(Command *cmd)
{
    printf("wrdsh> ");
    //Prepare to get user input, tokenized.
    char userInput[MAX_COMMAND_LENGTH];
    char buffer[MAX_COMMAND_LENGTH];
    char *token;

    //Sanitization check: did input work? If so, parse it. If not, skip.
    if (fgets(userInput,sizeof(userInput),stdin) != NULL)
    {
        //Copy to a buffer for tokenization, so we don't overwrite the user's input.
        strcpy(buffer, userInput);
        token = strtok(buffer, "|");
        //token = strtok(buffer, "|");

        //Special case: Did user just hit enter without input?
        if (strcmp(token,"\n") == 0)
        {
            return (0); //Try again.
        }

        //Special case: User is trying to exit the shell.
        if (strcmp(token,"exit\n") == 0)
        //if (strcmp(buffer,"exit\n") == 0)
        {
            return (1);
        }

        //parseInput(token);

        /*
        //for removing newline character from the user input
        for(int i=0;i<= strlen(buffer);i++)
        {
            if(buffer[i]=='\n'){
                buffer[i]='\0';
            }
        }
        */
        //Start parsing the input.



        strncpy(cmd->name,token,sizeof(cmd->name)); //Copy the first token's string to cmd->name.

            while (token)
            {

                //Strip leading spaces and trailing \n from each token if they exist.
                if (token[0] == ' ') token++;
                if (token[strlen(token) - 1] == '\n') token[strlen(token) - 1] = '\0';
                cmd->cmdCount++;

                Command *newCmd = calloc(1, sizeof(Command));
                strncpy(newCmd->name, token, sizeof(newCmd->name)); //Store the token as the current command's name.
                setLastNode(cmd, newCmd); //Append to the end of the list.
                //parseInput(cmd);
                token = strtok(NULL, "|"); //Move to next token.
            }
    }
    return (0);
}


int main(int argc, char *argv[])
{
    int fileDescriptors[2]; //File descriptors. fd[0] = read  |   fd[1] = write

    //The following is the continuous input loop for the shell.
    int shellStatus = 0;
    printf("\nShell first run:\n");
    while(shellStatus != 1)
    {
        Command *getCmd = calloc(1, sizeof(Command));//Allocate an empty Command to store the loop's output.
        shellStatus = shellLoop(getCmd);//Trigger the 'get input' loop.
        execReverseOrder(getCmd);
        printf("Shell returned %d.\n",shellStatus);
    }
    return 0;
}
