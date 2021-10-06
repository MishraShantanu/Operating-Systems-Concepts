#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(int argc, char *argv[])
{
    int fileDescriptors[2];
    pipe(fileDescriptors);
    int returnCode = fork();
    if (returnCode < 0)
    {
        // fork failed; exit
        fprintf(stderr, "fork failed\n");
        exit(1);
    }
    else if (returnCode == 0)
    {
        // child

        close(fileDescriptors[0]);  // close read end of pipe
        dup2(fileDescriptors[1],STDOUT_FILENO);  //STDIN_FILENO(?)
        // if do exec now, the program we run will have write end of pipe
        // as its standard output

        //printf("hello parent! I am child.\n          I am rc == 0. My returnCode -> %d\n",returnCode);
        printf("I am child 1.\n");
        printf("do I print? [child]"); //NO I DO NOT.

        //Interesting! Anything up to new line in the
        // "hello parent" is transmitted, but stops after first "\n" encountered

    }
    else
    {
        printf("I am the parent of all parents. I am rc > 0. My returnCode -> %d\n",returnCode);
        //printf("do I print? [parent]\n"); //YES I DO.

        // parent goes down this path (original process)
        // do a second fork here, if want to run a different program
        // for the backend of the pipeline, and have the child from
        // this second fork execute the following ...

        /*CREATING A SECOND CHILD */
        int secondReturnCode = fork();
        if (secondReturnCode < 0)
        {
            // fork failed; exit
            fprintf(stderr, "fork failed\n");
            exit(1);
        }
        else if (secondReturnCode == 0)
        {
            printf("I am child 2.\n");
            //printf("\ndo I print? [second child]\n"); //YES I DO.
        }
        else
        {
            printf("I am parent 2. I am rc > 0. My returnCode -> %d\n",returnCode);
            //printf("\ndo I print? [second parent]\n"); //YES I DO.
        }



        close(fileDescriptors[1]);  // close write end of pipe
        dup2(fileDescriptors[0],STDIN_FILENO);
        // if do exec now the program we run will
        // have the read end of pipe as standard input
        //
        char *message;
        size_t size = 100;
        message = (char *) malloc (size + 1);
        int newRead = getline(&message, &size, stdin);
        //printf("I have hit newRead. My newRead is: %d\n",newRead);

        if (newRead > 0) printf("My newRead is greater than zero. \n My stdin is:\n      '\n%s      '\n", message);
                //Wonder why \n is getting cut from this message. Strange.
            printf("I am waiting for my child...\n");
            int waitChild = wait(NULL);
    }
    return 0;
}
