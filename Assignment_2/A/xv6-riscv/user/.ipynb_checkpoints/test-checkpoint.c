#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[]){

    int rc = fork();
    if(rc==0){
        exit(0);
    }else{
         int i = 0;
       // wait(0);
   i = waitstat();
   printf("i: %d\n", i);
  exit(0);
    }
    
 
        
        
}