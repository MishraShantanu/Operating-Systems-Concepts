#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>


int shellLoop() {

    while (1) {
        char userInput [100];
        printf("wrdsh> ");
        //scanf("%s",userInput);
        scanf("%[^\n]*s", userInput);
        printf("You have entered: %s \n", userInput);


        char *token;
        token = strtok(userInput, "\n");
        //char *exitString = "exit";
        if (strcmp("exit", token) == 0)
        {
            printf("exit detected!");
            return (1);
        }
        return (0);
    }
}

int main(int argc, char *argv[])
{
    int fileDescriptors[2]; //File descriptors. fd[0] = read  |   fd[1] = write

    int shellStatus = shellLoop();
    while(shellStatus != 1)
    {
        printf("Shell returned: %d",shellStatus);
        shellStatus = shellLoop();
        break;
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