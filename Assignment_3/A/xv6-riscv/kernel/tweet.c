#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "proc.h"


struct tweet{
    topic_t tag;
    char msg[MAXTWEETLENGTH];
}tweetbuffer[MAXTWEETTOTAL];

struct spinlock tweetlock;

int getchan = 10, putchan = 20;


void inittweetlock(void){
    initlock(&tweetlock,"tweetlock");
}


int gettagindex(topic_t tag){
    
    int index =-1;
    for(int i=0;i<MAXTWEETTOTAL;i++){
        //printf("get tag idx msg %d len %d\n",i,strlen(tweetbuffer[i].msg ));
        if(tweetbuffer[i].tag==tag&&strlen(tweetbuffer[i].msg)>0){
          index = i;
          break;
          
        }
    }
    
    return index;
}

int getemptyindex(topic_t tag){
    int index =-1;
    for(int i=0;i<MAXTWEETTOTAL;i++){
        
        //printf("msg %d len %d\n",i,strlen(tweetbuffer[i].msg ));
        if(strlen(tweetbuffer[i].msg)==0){
           index = i;
          break;
          
        }
    }
    
    return index;
}

int
btput(topic_t tag,char* msg)
{

    //printf("btput Hello world in tweet.c, recvid msg: %s\n",msg);
    acquire(&tweetlock);
    
   // printf("Acquiring lock\n");
    int index = getemptyindex(tag);
    
    while(index==-1){
//         printf("Started sleeping for btput\n");
        sleep(&getchan,&tweetlock);
        index = getemptyindex(tag);
 //         printf("index after sleep %d \n", index);
    }
//     printf("index after wakeup %d0 \n", index);
//     if(index!=-1){
         strncpy(tweetbuffer[index].msg,msg,strlen(msg));
         tweetbuffer[index].tag=tag;
         wakeup(&putchan);
         //wakeup get
//     }else{
//         printf("No space available to put new msg\n");
//     }
   // printf("release lock\n");
    release(&tweetlock);
    
    return 0;
}

int
tput(topic_t tag,char* msg){
   // printf("ttput Hello world in tweet.c\n");
   
    acquire(&tweetlock);
   // printf("Acquiring lock\n");
    int index = getemptyindex(tag);
    
    if(index!=-1){
         strncpy(tweetbuffer[index].msg,msg,strlen(msg));
         tweetbuffer[index].tag=tag;
         //wakeup get
    }else{
        
        printf("No space available to put new msg returing -1\n");
         release(&tweetlock);
        return -1;
    }
   // printf("release lock\n");
    release(&tweetlock);
   
    
    return 0;
}

int 
btget(topic_t tag,uint64 buf){
   
//    for(int i=0;i<10;i++){
//     printf("btget %d -- %s\n",i,tweetbuffer[i].msg);
//    }
   
    struct proc *p = myproc();
   // printf("btget Hello world in tweet.c\n");
    acquire(&tweetlock);
  //  printf("Acquiring lock\n");
    int index = gettagindex(tag);
    
     while(index==-1){
  //      printf("Started sleeping for btget \n");
        sleep(&putchan,&tweetlock);
        index = getemptyindex(tag);
  //      printf("index after sleep %d\n ", index);
    }
   // printf("index after wakeup %d \n", index);
//     if(index!=-1){
//          printf("tag idx %d \n",index);
//          printf("at i found: %d\n",index,strlen(tweetbuffer[index].msg ));
         char *temp = tweetbuffer[index].msg;
         copyout(p->pagetable,buf,temp,strlen(temp));

        memset(tweetbuffer[index].msg, 0, MAXTWEETLENGTH);
        wakeup(&getchan);
         
         //wakeup put
         
//         printf("at i found: %d\n",index,strlen(tweetbuffer[index].msg ));
         
//     }else{
//         printf("no element msg available to read\n");
//     }
   
  //  printf("release lock\n");
    release(&tweetlock);
    
     return 0;
}

int
tget(topic_t tag,uint64 buf){
   // printf("tget Hello world in tweet.c\n");
      

   
    struct proc *p = myproc();

    acquire(&tweetlock);
   // printf("Acquiring lock\n");
    int index = gettagindex(tag);
    if(index!=-1){

        char *temp = tweetbuffer[index].msg;
        copyout(p->pagetable,buf,temp,strlen(temp));

        memset(tweetbuffer[index].msg, 0, MAXTWEETLENGTH);
        
        //wakeup put
         
         
    }else{
        printf("no element msg available to read  returing -1\n");
         release(&tweetlock);
        return -1;
    }
   
  //  printf("release lock\n");
    release(&tweetlock);
    
     return 0;
}
