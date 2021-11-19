#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[]){
    
    int startPidA=-1,endPidA=-1;
    int startPidB=-1,endPidB=-1;
    int startPidC=-1,endPidC=-1;
  
    char msgA[140] = "Tag A - Hello world!";
    char msgB[140] = "Tag B -   CMPT 332!";
    char msgC[140] = "Tag C- Xv6 A 3 part A";

    
   
    enum topic_t tag;
     
   
    int rc;
printf("************** Test case 1*********\n"); 
    printf("Test case: Calling btput 45 times from the child process then in parent process calling btget 45 times.\n Also, while start 15 tweet will be for tag A, next 15 will be tag B and the last 15 will be tag c.\n"), 
    printf("Expected output: All the sender (child process) tweet msg should be revied by the correct reciver (parent) tag\n\n");
    printf("Actual output: \n");
for(int f=0;f<45;f++){
        
        rc=fork();
       
        if(rc==0){

            if(f<15){
                btput(tag=a,msgA);
             
            }else if(f>=15 && f < 30){
                    
                btput(tag=b,msgB);
                          
            }else{
                       
                btput(tag=c,msgC);
            }

                
        exit(0);
        }else{
            
         
            if(f==0 && startPidA==-1){
                startPidA = rc;
            }else if(f==14 && endPidA==-1){
                 endPidA = rc;
            }else if(f==15 && startPidB==-1){
                startPidB = rc;
            }else if(f==29 && endPidB==-1){
                 endPidB = rc;
            }else if(f==30 && startPidC==-1){
                startPidC = rc;
            }else if(f==44 && endPidC==-1){
                 endPidC = rc;
            }
            
            
        }
    }
      
      for(int i=0;i<45;i++){
         char buf[140];
         
         int pid;
    
           pid = wait(0);
      
           if(pid>=startPidA && pid<=endPidA){
                 btget(tag=a,buf);
                 printf("btget output: %s \n",buf);           
                
            }else if(pid>=startPidB && pid<=endPidB){
                 btget(tag=b,buf);
                 printf("btget output: %s \n",buf);
            }else if(pid>=startPidC && pid<=endPidC){
                 btget(tag=c,buf);
                 printf("btget output: %s \n",buf);
             

            }
        
        
    }
    
printf("************** Test case 2*********\n");  
    printf("Test case: Calling tput and tget with tag a and a msg\n"), 
    printf("Expected output: tget should report return the tput msg\n\n");
    printf("Actual output: ");
    char buf2[140];
    tput(tag=a,msgA);
    tget(tag=a,buf2);
    printf("tget output: %s \n",buf2);

printf("************** Test case 3*********\n");   
    printf("Test case: Calling tget for tag b which does not have any tweet stored for it\n"), 
    printf("Expected output: tget should report that no tweet to read with tag b and return -1\n\n");
    printf("Actual output: ");
    tget(tag=b,buf2);

printf("************** Test case 4*********\n");
    printf("Test case: Calling tput 11 times and the maxtweet is set as 10\n"), 
    printf("Expected output: No space is available to store the tweet and end the tput call with -1\n\n");
     printf("Actual output: ");
    tput(tag=a,msgA);
    tput(tag=a,msgA);
    tput(tag=a,msgA);
    tput(tag=a,msgA);
    tput(tag=a,msgA);
    tput(tag=a,msgA);
    tput(tag=a,msgA);
    tput(tag=a,msgA);
    tput(tag=a,msgA);
 

    
    //removing the msgs from kernel space for next run.
    tget(tag=a,buf2);
    tget(tag=a,buf2);
    tget(tag=a,buf2);
    tget(tag=a,buf2);
    tget(tag=a,buf2);
    tget(tag=a,buf2);
    tget(tag=a,buf2);
    tget(tag=a,buf2);
  
  exit(0);
}  