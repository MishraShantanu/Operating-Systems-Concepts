#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[]){
    

        int rc;
        for(int i = 0; i < atoi(argv[1]); i++){
       // printf("Forking %d\n",i);
            
            rc = fork();
            if(rc==0){
               // printf("closing child %d ",i);
                    exit(-1);
            }
            
            wait(0);
             
            
        }
       printf("%d\n",howmanycmpt());wait(0);
    exit(0);
}