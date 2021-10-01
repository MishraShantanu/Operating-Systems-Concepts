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
#include <fcntl.h>

#define MAX_COMMAND_LENGTH 400
//#define INPUT_FD 0
//#define OUTPUT_FD 1

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
    int position;                          //0 -> last, 1 -> middle, 2 -> first, 3 -> singleton.
} Command;


/* PURPOSE: Executes individual commands by creating a child process using fork and later uses
 * execvp to execute the system call
 * PRE-CONDITIONS: - command -- The command object which contains the name of command to be executed.
 *                   fd      -- The intended file descriptors inherited by execReverseOrder.
 * POST-CONDITIONS: Individual command is executed.
 * RETURN: None.
 */
void runCommand(Command *command, int *fd,int cmdCount, int numberOfpipes)
{   //printf("Command Name: %s command number %d\n", command->name, cmdCount );
    //printf("Running command: %s    position: %d\n",command->name,command->position);
    //TODO: Handle "no such command found"
    //cmd.forwards == 1  [forward stdout to destination]
    //initialize variable to tokenize the given command
    char **cmdArgs[100];
    int argCount = 0;

    char buffer[MAX_COMMAND_LENGTH] = "";
    char *savePointer;
    strcat(buffer,command->name);
    char *cmdToRun = strtok(command->name," ");
    char *argToken = strtok_r(buffer," ",&savePointer);

    while (argToken!=NULL)
    {
        cmdArgs[argCount] = (char **) argToken;
        argCount+=1;
        argToken = strtok_r(NULL," ",&savePointer);
    }
    //The command should have null at end to show the end of command
    cmdArgs[argCount] =NULL;

    //forking to call the child process
    int rc= fork();
    if(rc<0)
    {
        //forking failed exit
        fprintf(stderr, "Fork failed \n");
        exit(1);
    }
    else if(rc==0)  //Child process
    {
        if (((command->prev) != NULL) & ((command->next) != NULL)) { //middle pipe

            close(fd[(cmdCount - 2) * 2 + 1]);
            dup2(fd[(cmdCount - 2) * 2], STDIN_FILENO);
            close(fd[(cmdCount - 2) * 2]);

            close(fd[2 * cmdCount - 2]);
            dup2(fd[2 * cmdCount - 1], STDOUT_FILENO);
            close(fd[2 * cmdCount - 1]);
            //printf("Middle  Command Name: %s command number %d, will read from %d and write to %d\n", command->name, cmdCount  , (cmdCount-2)*2, 2*cmdCount - 1 );
        } else if (((command->prev) == NULL) & ((command->next) != NULL)) //Last pipe
        {
           // printf("Last  Command Name: %s command number %d, will read from %d and write to %d\n", command->name,
            //       cmdCount, 2 * cmdCount - 2, 2 * cmdCount - 1);

            close(fd[(cmdCount - 2)*2+1]);
            dup2(fd[(cmdCount - 2)*2], STDIN_FILENO);
            close(fd[(cmdCount - 2)*2]);

            close(fd[2*cmdCount - 2]);
            dup2(fd[2*cmdCount - 1], STDOUT_FILENO);
            close(fd[2*cmdCount - 1]);



        } else if (((command->prev) != NULL) & ((command->next) == NULL))// first  pipe
        {
            //printf("First Command Name: %s command number %d, write to %d\n", command->name, cmdCount, cmdCount);

            close(fd[0]);
            dup2(fd[1], STDOUT_FILENO);
            close(fd[1]);
        } else { //single command
            close(fd[0]);
            dup2(fd[1], STDOUT_FILENO);
            close(fd[1]);
        }



        if (execvp(cmdToRun, (char *const *) cmdArgs) == -1) {
            printf("here");
            for(int i=0; i<numberOfpipes;i++){
                close(fd[i]);
            }

            perror("wrdsh");



        }

    }else    //original parent process
        {
            wait(NULL);
            //printf("Parent ");
            //printf("pRC %d   ", wait_count);
            if (((command->prev) == NULL) & ((command->next) != NULL) ||
                ((command->prev) == NULL) & ((command->next) == NULL)) //last or singleton command.
                //if(command->position == 0) //last command.
            {
                close(fd[numberOfpipes-1]);
                char *temp;
                int i;
                //checks if output needs to be redirected
                if(command->forwards==1){
                    //open redirect file
                    int filedescriptor = open(command->forwardsTo,  O_WRONLY | O_CREAT | O_TRUNC,
                                              S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH | O_APPEND);

                    temp = calloc(20, MAX_COMMAND_LENGTH);
                    i = 0;

                    char fileInputText[8000];
                    int bufferSize = 0;
                    while (read(fd[numberOfpipes-2], temp, (MAX_COMMAND_LENGTH * sizeof(char *))) != 0) {
                        //check how many character to write
                        while(temp[i]!='\0'){
                            fileInputText[bufferSize] = temp[i];
                            if (temp[i] == 'c' || temp[i] == 'C' || temp[i] == 'm' || temp[i] == 'M' || temp[i] == 'p' ||
                                temp[i] == 'P' || temp[i] == 't' || temp[i] == 'T') {
                                bufferSize++;
                                fileInputText[bufferSize] = temp[i];


                            }

                            i++;
                            bufferSize++;


                          //  printf("buffer size %d and char", bufferSize);
                        }
                        write(filedescriptor,fileInputText, bufferSize);





                    }
                    free(temp);


                }

                i = 0;
                temp = calloc(20, MAX_COMMAND_LENGTH);
                while (read(fd[numberOfpipes-2], temp, (MAX_COMMAND_LENGTH * sizeof(char *))) != 0) {
                   // printf("Actual dupe loop activated \n");
                    while (temp[i] != '\0') {
                        printf("%c", temp[i]);
                        if (temp[i] == 'c' || temp[i] == 'C' || temp[i] == 'm' || temp[i] == 'M' || temp[i] == 'p' ||
                            temp[i] == 'P' || temp[i] == 't' || temp[i] == 'T') {
                            printf("%c", temp[i]);
                        }
                        i++;
                    }
                }
                free(temp);
            }
        }
    }





/* PURPOSE: Executes the given command (from right-to-left)
 * PRE-CONDITIONS: srcChain -- Node chain representing the sequence of commands to execute.
 *                 fd       -- File descriptors to be passed to each command.
 * POST-CONDITIONS: Triggers runCommand() on each node in srcChain.
 * RETURN: 0 if execution was successful, 1 when execution has failed.
 */
int execReverseOrder(Command *srcChain)
{



    int fd[srcChain->cmdCount*2];

    for (int i=0; i < srcChain->cmdCount; i++) {
        if ( pipe(fd + 2*i) < 0) {
            perror("wrdsh");
        }
    }
//    pipe(fd);
    if (srcChain->cmdCount == 0) // Check if given an empty srcChain.
    {
        return (1);
    }

    Command *walker = srcChain->tail;
    while (walker->prev != NULL) //Walk back from the end of the chain towards the beginning, executing each command.
    {
        if(walker->position==0){
            runCommand(walker,fd, srcChain->cmdCount, srcChain->cmdCount*2);
        }else {runCommand(walker,fd, (srcChain->cmdCount+1)-walker->position, srcChain->cmdCount*2); }

        walker = walker->prev;
    }

    if(walker->position==0){
        runCommand(walker,fd, srcChain->cmdCount, srcChain->cmdCount*2);
    }else {runCommand(walker,fd, (srcChain->cmdCount+1)-walker->position, srcChain->cmdCount*2); }

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
        strcpy(srcChain->name,endNode->name);
        if (endNode->forwards == 1)
        {
            strcpy(srcChain->forwardsTo,endNode->forwardsTo);
            srcChain->forwards = 1;
        }
        srcChain->cmdCount++;
        srcChain->tail = endNode;
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
    endNode->position = srcChain->cmdCount;
  //  printf("Command Name: %s command number %d\n", endNode->name, endNode->position  );


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



char * delimBySpace(char* parseMe)
{
    char *token;
    char *savePointer;
    char parseBuffer[MAX_COMMAND_LENGTH];
    char *cmdBuffer = calloc(1,MAX_COMMAND_LENGTH);
    strcpy(parseBuffer,parseMe);
    token = strtok_r(parseBuffer, " ", &savePointer);  //Step through each separate word given by the user.
    while (token)
    {
        strcat(cmdBuffer,token);  //Continue to step through each word, saving each one to cmdBuffer.
        strcat(cmdBuffer," ");
        token = strtok_r(0," ",&savePointer);
    }
    strcat(cmdBuffer," ");
    return cmdBuffer;


}


int delimByPipe(Command* userCommands, char* parseMe)
{
    char *token;
    char *savePointer;
    char parseBuffer[MAX_COMMAND_LENGTH];
    //TODO: Write a check -- does anything follow the last |? If not, throw exception (syntax error)
    strcpy(parseBuffer,parseMe);

    int pipeCount = 0;
    int tokenCount = 0;

    for (int i = 0; i < strlen(parseBuffer);i++) if (parseBuffer[i] == '|') pipeCount++; // Count # pipes in string.

    token = strtok_r(parseBuffer, "|", &savePointer);
    while (token)
    {
        tokenCount++;
        setLastNode(userCommands,createCommand(delimBySpace(token)));
        token = strtok_r(0,"|",&savePointer);
    }
    if (pipeCount != tokenCount-1)
    {
        printf("Syntax error! Please try again.\n");
        return -1;
    }
    return 0;
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
        if (strrchr(buffer, '|'))
        {
            if (delimByPipe(userCommands, buffer) == -1) return -1;
        }
        else
        {
            setLastNode(userCommands,createCommand(delimBySpace(buffer)));
        }
    }
    return 0;
}




int main(__attribute__((unused)) int argc, __attribute__((unused)) char *argv[])
{
    //The following is the continuous input loop for the shell.
    int shellStatus = 0;
    printf("\nShell first run:\n");
    while(shellStatus != 1)
    {
       // int fileDescriptors[10]; //File descriptors. fd[0] = read  |   fd[1] = write
       // pipe(fileDescriptors);

        Command *getCmd = calloc(1, sizeof(Command));//Allocate an empty Command to store the loop's output.
        shellStatus = shellLoop(getCmd);                    //Trigger the 'get input' loop.
        if (shellStatus != -1)
        {
            execReverseOrder(getCmd); //Execute all commands given by the shell.
        }
        printf("Shell returned %d.\n",shellStatus);
        free(getCmd);
    }
    return 0;
}

