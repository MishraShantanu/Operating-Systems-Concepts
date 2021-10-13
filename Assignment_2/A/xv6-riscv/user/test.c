#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[]){

    int rc;
    int AturnaroundTime=0, BturnaroundTime=0, CturnaroundTime=0, ArunningTime=0, BrunningTime=0, CrunningTime=0 ;

    for(int i=0;i<45;i++){
        
        
        rc=fork();
        int  turnaroundTime=0, runningTime=0;

        if(rc==0){

            int sum = 0 , jStop;

            for ( int i=1; i<=atoi(argv[1]);i++){

                if(i<15){
                   
                 jStop = atoi(argv[2]);
                 }else if(i>=15 && i < 30){
                  jStop = atoi(argv[3]);   
                     
                
                 }else{

                jStop = atoi(argv[4]);  

                }

                for(int j=1; j<=jStop;j++){

                        sum += i -j;
                }
                
            }
            exit(0);
        }else if(rc>0){
           waitstat(0,&turnaroundTime,&runningTime);
           if(i<15){

                AturnaroundTime += turnaroundTime;
                ArunningTime += runningTime;
                
            }else if(i>=15 && i < 30){
                
                BturnaroundTime += turnaroundTime;
                BrunningTime += runningTime;   
            }else{

               CturnaroundTime += turnaroundTime;
                CrunningTime += runningTime;

            }

            // printf("turnaround %d, runT %d", turnaroundTime, runningTime);
        }
    }
    printf("A TT: %d, RT: %d | B TT: %d, RT: %d | C TT: %d, RT: %d\n",AturnaroundTime,ArunningTime,BturnaroundTime,BrunningTime,CturnaroundTime,CrunningTime );
   //printf("A TT: %d, RT: %d ",AturnaroundTime,ArunningTime);
  // printf("%d\n", getpid());
  exit(0);
}  