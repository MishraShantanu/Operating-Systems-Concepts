#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "proc.h"

int tweetcounter = 0;
struct tweet{
    topic_t tag;
    char msg[MAXTWEETLENGTH];
};



struct alltweet{
    struct tweet tagtweetbuffer[MAXTAGTWEET];
    struct spinlock tweettaglock;
        
} alltweetbuff[NUMTWEETTOPICS];



int getchan = 10, putchan = 20;


void inittweetlock(void){
    
    for(int i=0; i<NUMTWEETTOPICS;i++){
        initlock(&alltweetbuff[i].tweettaglock,"tweetlock");
    }
    
}


int gettagindex(topic_t tag){
    
    int index =-1;
    for(int i=0;i<MAXTAGTWEET;i++){
        if(alltweetbuff[tag].tagtweetbuffer[i].tag==tag&&strlen(alltweetbuff[tag].tagtweetbuffer[i].msg)>0){
          index = i;
          break;
          
        }
    }
    
    return index;
}

int getemptyindex(topic_t tag){
    int index =-1;
    for(int i=0;i<MAXTAGTWEET;i++){
        if(strlen(alltweetbuff[tag].tagtweetbuffer[i].msg)==0){
           index = i;
          break;
          
        }
    }
    
    return index;
}

int
btput(topic_t tag,char* msg)
{
    acquire(&alltweetbuff[tag].tweettaglock);
    
//    printf("Acquiring lock\n");
    int index = getemptyindex(tag);
     //    printf("index after sleep %d\n ", index);
       //  printf("max tweet %d\n",tweetcounter>MAXTWEETTOTAL);
    while(index==-1||tweetcounter>MAXTWEETTOTAL){
        
//       printf("Started sleeping for btput\n");
        sleep(&getchan,&alltweetbuff[tag].tweettaglock);
        index = getemptyindex(tag);
//         printf("index after sleep %d \n", index);
    }
   //printf("index after wakeup %d0 \n", index);
//     if(index!=-1){
         strncpy(alltweetbuff[tag].tagtweetbuffer[index].msg,msg,strlen(msg));
         alltweetbuff[tag].tagtweetbuffer[index].tag=tag;
         tweetcounter++;
         wakeup(&putchan);
         
         //wakeup get
//     }else{
//         printf("No space available to put new msg\n");
//     }
  //  printf("release lock\n");
    release(&alltweetbuff[tag].tweettaglock);
    
    return 0;
}

int
tput(topic_t tag,char* msg){
   // printf("ttput Hello world in tweet.c\n");
   
    acquire(&alltweetbuff[tag].tweettaglock);
   // printf("Acquiring lock\n");
    int index = getemptyindex(tag);
    
    if(index!=-1||tweetcounter>MAXTWEETTOTAL){
         strncpy(alltweetbuff[tag].tagtweetbuffer[index].msg,msg,strlen(msg));
         alltweetbuff[tag].tagtweetbuffer[index].tag=tag;
         tweetcounter++;
         //wakeup get
    }else{
        
        printf("No space available to put new msg returing -1\n");
         release(&alltweetbuff[tag].tweettaglock);
        return -1;
    }
   // printf("release lock\n");
    release(&alltweetbuff[tag].tweettaglock);
   
    
    return 0;
}

int 
btget(topic_t tag,uint64 buf){
   
//    for(int i=0;i<10;i++){
//     printf("btget %d -- %s\n",i,tweetbuffer[i].msg);
//    }
   
    struct proc *p = myproc();
   // printf("btget Hello world in tweet.c\n");
    acquire(&alltweetbuff[tag].tweettaglock);
//   printf("btget Acquiring lock\n");
    int index = gettagindex(tag);
    
     while(index==-1){
     // printf("Started sleeping for btget \n");
        sleep(&putchan,&alltweetbuff[tag].tweettaglock);
        index = getemptyindex(tag);
  //     printf("index after sleep %d\n ", index);
    }
 //  printf("index after wakeup %d \n", index);
//     if(index!=-1){
//          printf("tag idx %d \n",index);
//          printf("at i found: %d\n",index,strlen(tweetbuffer[index].msg ));
         char *temp = alltweetbuff[tag].tagtweetbuffer[index].msg;
   //      printf("**** Msg found: %s\n", temp);
         copyout(p->pagetable,buf,temp,strlen(temp));

        memset(alltweetbuff[tag].tagtweetbuffer[index].msg, 0, MAXTWEETLENGTH);
        
        tweetcounter--;
        wakeup(&getchan);
         
         //wakeup put
         
//         printf("at i found: %d\n",index,strlen(tweetbuffer[index].msg ));
         
//     }else{
//         printf("no element msg available to read\n");
//     }
   
//    printf("btget release lock\n");
    release(&alltweetbuff[tag].tweettaglock);
    
     return 0;
}

int
tget(topic_t tag,uint64 buf){
   // printf("tget Hello world in tweet.c\n");
      

   
    struct proc *p = myproc();

    acquire(&alltweetbuff[tag].tweettaglock);
   // printf("Acquiring lock\n");
    int index = gettagindex(tag);
    if(index!=-1){

        char *temp = alltweetbuff[tag].tagtweetbuffer[index].msg;
        copyout(p->pagetable,buf,temp,strlen(temp));

        memset(alltweetbuff[tag].tagtweetbuffer[index].msg, 0, MAXTWEETLENGTH);
        
         tweetcounter--;
      
         
         
    }else{
        printf("no element msg available to read  returing -1\n");
         release(&alltweetbuff[tag].tweettaglock);
        return -1;
    }
   
  //  printf("release lock\n");
    release(&alltweetbuff[tag].tweettaglock);
    
     return 0;
}
