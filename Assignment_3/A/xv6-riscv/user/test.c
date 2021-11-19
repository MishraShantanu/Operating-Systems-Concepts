#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[]){
    
    int startPidA=-1,endPidA=-1;
    int startPidB=-1,endPidB=-1;
    int startPidC=-1,endPidC=-1;
  
    char msgA[140] = "Tag A - Hello world";
    char msgB[140] = "Tag B -   CMPT 332!";
    char msgC[140] = "Tag C- Xv6 A 3 part A";

    
    char buf[140];
    enum topic_t tag;
     
   
    int rc;
printf("************** Test case 1*********\n");   
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
        

            // printf("turnaround %d, runT %d", turnaroundTime, runningTime);
        
    }
    
printf("************** Test case 2*********\n");  

printf("************** Test case 3*********\n");   
    
                 
   
  exit(0);
}  