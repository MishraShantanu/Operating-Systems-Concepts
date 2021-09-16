#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int
main(int argc, char *argv[])
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
        int newWrite = write(fileDescriptors[1],"hello parent!\n", 14);
        close(fileDescriptors[1]); // done writing, close write end of pipe
        if (newWrite != 14) exit(1);
    }

    else
    {
            // parent goes down this path (original process)
        char message[100];
        close(fileDescriptors[1]);  // close write end of pipe
        int newRead = read(fileDescriptors[0],message,100);
        close(fileDescriptors[0]); // done reading, close read end of pipe
        if (newRead > 0) write(STDOUT_FILENO,message,newRead);
            int waitChild = wait(NULL);
    }

    return 0;
}
