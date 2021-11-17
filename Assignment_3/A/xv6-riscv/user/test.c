#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[]){
  
    char s[140] = "Btput: test hello world! cmpt 332";
   // char s1[140] = "tput: test hello world! cmpt 332";
    
    char buf[140];
    enum topic_t tag;
     
    
    
    int rc;
    
    for(int f=0;f<12;f++){
        
         rc=fork();
        
         if(rc==0){
              
 //            if(f<21){
                 //0-9
                 btput(tag=a,s);
//             }
//              else if(f<20&& f>9){ 
//                  //10 - 19
//                   btget(tag=a,buf);
//                  printf("btget output: %s \n",buf);
                 
//              }else if(f<30&& f>19){
//                  //20 - 29
//                  tput(tag=a,s1);
//              }
//              else{
//                 // 30-39
//                  btput(tag=a,s1);
                 
//              }
                 
              exit(0);
             
         }
    }
    
    
    for(int i=0;i<12;i++){
    
        wait(0);
        
  //       if(i<20){
                 //0-19
                 btget(tag=a,buf);
                 printf("btget output: %s \n",buf);
//             }
//         else{
//                 // 20-39
//                  tget(tag=a,buf);
//                  printf("btget output: %s \n",buf);
                 
//              }
        
    }
    
   // tget(tag=a,buf);
    
    
   
    
    
   
  exit(0);
}  