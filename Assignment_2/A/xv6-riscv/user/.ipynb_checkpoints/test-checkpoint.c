#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[]){

    int rc;
    int AturnaroundTime=0, BturnaroundTime=0, CturnaroundTime=0, ArunningTime=0, BrunningTime=0, CrunningTime=0 ;
    int startPid=-1;

    for(int f=0;f<45;f++){
        
        
        rc=fork();
       

        if(rc==0){

            int sum = 0 , jStop;

            for ( int i=1; i<=atoi(argv[1]);i++){

                 if(f<15){
                        
                 jStop = atoi(argv[2]);
                 }else if(f>=15 && f < 30){
                    
                  jStop = atoi(argv[3]);  
                    
                     
                 }else{

                    jStop = atoi(argv[4]);  

                 }

                for(int j=1; j<=jStop;j++){

                        sum += i -j;
                }
                
            }
            exit(0);
        }else{
            
            if(f==0 && startPid==-1){
                startPid = rc;
               // printf("setting start pid: %d\n", startPid);
            }
            
        }
    }
    
    // printf("startpid: %d \n",startPid);

    for(int i=0;i<45;i++){
        
         int  turnaroundTime=0, runningTime=0;
         int pid;
    
           pid = waitstat(0,&turnaroundTime,&runningTime);
        //   printf("Pid: %d \n",pid);
           if(pid <startPid+15){
               // printf("A %d %d\n",pid,startPid+15);
                AturnaroundTime += turnaroundTime;
                ArunningTime += runningTime;
                
            }else if(pid >=startPid+15 &&  pid < startPid+30){
              //  printf("B %d %d %d\n",pid,startPid+15,startPid+30);
                BturnaroundTime += turnaroundTime;
                BrunningTime += runningTime;   
            }else{
              // printf("C %d %d\n",pid,startPid);

               CturnaroundTime += turnaroundTime;
                CrunningTime += runningTime;

            }
        

            // printf("turnaround %d, runT %d", turnaroundTime, runningTime);
        
    }
    printf("A TT: %d, RT: %d | B TT: %d, RT: %d | C TT: %d, RT: %d\n",AturnaroundTime,ArunningTime,BturnaroundTime,BrunningTime,CturnaroundTime,CrunningTime );
   //printf("A TT: %d, RT: %d ",AturnaroundTime,ArunningTime);
  // printf("%d\n", getpid());
  exit(0);
}  