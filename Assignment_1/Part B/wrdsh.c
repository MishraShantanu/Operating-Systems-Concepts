#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

#define MAX_COMMAND_LENGTH 30


/* PURPOSE:
 * Stores the given input in a doubly linked list of commands.
 */
typedef struct _command
{
    char name[MAX_COMMAND_LENGTH];         //Store the name of the command.
    struct _command *next;                 //The next command.
    struct _command *prev;                 //The previous command.
    int cmdCount;
} Command;



//TODO: Write tokens to a doubly linked list.
        //*Have it linking one way so far [cmd.next] -- cmd.prev not coded yet.
//TODO: Make a function that steps through the list.
        //Can use a function similar to setLastNode.
//TODO: Make a function that reverses the list. [Read right to left].
        //Walk backwards from the end of the node chain?
        //Set to cmd.prev instead of cmd.next in shellLoop?

//TODO: find a way to handle bad inputs
        //[Currently handles redundant spaces, or user enters nothing into the shell]
//TODO: find a way to discern between executable programs and parameters.
        //Likely tokenize by " | " as delimiter first, then by " " after.



/* PURPOSE: Appends a given token/command to the end of the node chain.
 * PRE-CONDITIONS: srcChain -- the first node in the node chain to append to.
 *                 endNode  -- the node to append at the end of the chain.
 * POST-CONDITIONS: srcChain is modified to include endNode.
 * RETURN: None.
 */
void setLastNode(Command *srcChain,Command *endNode)
{
    printf("Apprending to last: %s\n",endNode->name);

    Command *walker = srcChain;
    while (walker->next != NULL) //Step to the end of the node-chain
    {
        walker->next->prev = walker; //backlink the node.
        walker = walker->next;
    }
    walker->next = endNode; // insert the new node at the end of the chain.
}


/* PURPOSE: Prints all the tokens/items stored in the given node chain.
 * PRE-CONDITIONS: srcChain -- the first node in the node chain to print.
 * POST-CONDITIONS: Prints the entire chain to the console.
 * RETURN: None.
 */
int printAllNodes(Command *srcChain)
{
    if (srcChain->cmdCount == 0) // Check if given an empty srcChain.
    {
        return (1);
    }

    int count = 0;
    Command *walker = srcChain;

    while (walker->next != NULL) //Step to the end of the node-chain, printing each node.
    {
        count++;
        printf("cmd %d --> %s \n",count,walker->name);
        walker = walker->next;
    }
    count++;
    printf("cmd %d --> %s \n",count,walker->name);
    return (0);
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
    char userInput[100];
    char buffer[100];
    char *token;

    //Sanitization check: did input work? If so, do stuff. If not, skip.
    if (fgets(userInput,sizeof(userInput),stdin))
    {
        //Copy to a buffer for tokenization, so we don't overwrite the user's input.
        strcpy(buffer, userInput);
        token = strtok(buffer, " ");

        //Special case: Did user just hit enter without input?
        if (strcmp(token,"\n") == 0)
        {
            return (0); //Try again.
        }

        //Special case: User is trying to exit the shell.
        if (strcmp(token,"exit\n") == 0)
        {
            return (1);
        }

        //Start parsing the input.
        strncpy(cmd->name,token,sizeof(cmd->name)); //Copy the first token's string to cmd->name.
        token = strtok(NULL, " "); //Move to next token.
        while (token)
        {
            cmd->cmdCount++;
            Command *newCmd = calloc(1,sizeof(Command));
            strncpy(newCmd->name,token,sizeof(newCmd->name)); //Store the token as the current command's name.
            setLastNode(cmd,newCmd); //Append to the end of the list.
            token = strtok(NULL, " "); //Move to next token.
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
        printf("Shell returned %d.\n",shellStatus);
        Command *getCmd = calloc(1, sizeof(Command));//Allocate an empty Command to store the loop's output.
        shellStatus = shellLoop(getCmd);//Trigger the 'get input' loop.
        printAllNodes(getCmd);//TESTING PURPOSES: Prints to console to confirm proper parsing of nodes.
    }
    return 0;
}
