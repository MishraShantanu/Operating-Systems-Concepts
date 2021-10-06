#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>



typedef struct _command {
    char name[25];                          //Store the name of the command.
    struct _command *next;                 //The next command.
    struct _command *prev;                 //The previous command.

} Command;


//Typedef: Doubly linked list with element counter.
//TODO: Write tokens to a doubly linked list.
//TODO: Make a function that steps through the list.
//TODO: Make a function that appends to the list.
//TODO: Make a function that reverses the list. [Read right to left].


//TODO: find a way to handle bad inputs
//TODO: find a way to decern between executable programs and parameters.


int shellLoop()
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

        //Grab each word.
        while (token)
        {
            printf("Current token [loop]: %s\n",token);
            token = strtok(NULL, " ");
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
        shellStatus = shellLoop();
        //printf("Shell returned %d.\n",shellStatus);
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