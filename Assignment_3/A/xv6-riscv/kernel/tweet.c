#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "proc.h"

//counter to keep track of number of tweets at a time in the buffer
//this will be used to enusre that put msg does not add msg if the max tweet count is reached 
int tweetcounter = 0;

//structure to store a array of tweet
struct tweet{
    topic_t tag;
    char msg[MAXTWEETLENGTH];
};


//struct to store tweets of each tag in its own list/array
//so that other tweets can access the DS concurrenctly 
struct alltweet{
    struct tweet tagtweetbuffer[MAXTAGTWEET];
    struct spinlock tweettaglock;
        
} alltweetbuff[NUMTWEETTOPICS];


//Channels to notify the get and put processes
//of addition or removal of a msg in buffer
int getchan = 10, putchan = 20;


//initalize the the tweet lock for each tag array
void inittweetlock(void){
    
    for(int i=0; i<NUMTWEETTOPICS;i++){
        initlock(&alltweetbuff[i].tweettaglock,"tweetlock");
    }
    
}

//returns the index of msg stored with a given tag, 
//if not found then returns -1 for failure
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

//returns the index of empty storage block, 
//if not found then returns -1 for failure
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

//stores the msg in the tweet buffer, if space is avaiable and max tweet threshold is not reached 
// then the tweet is stored. else it goes to sleep mode until the one of the get method calls wakeup 
int
btput(topic_t tag,char* msg)
{
    acquire(&alltweetbuff[tag].tweettaglock);
    
    int index = getemptyindex(tag);
     
    while(index==-1||tweetcounter>MAXTWEETTOTAL){

        sleep(&getchan,&alltweetbuff[tag].tweettaglock);
        index = getemptyindex(tag);

    }

         if(strncpy(alltweetbuff[tag].tagtweetbuffer[index].msg,msg,strlen(msg))==0){
             printf("strcpy failed");
             release(&alltweetbuff[tag].tweettaglock);
             return -1;
         }
         alltweetbuff[tag].tagtweetbuffer[index].tag=tag;
         tweetcounter++;
         wakeup(&putchan);
    
    release(&alltweetbuff[tag].tweettaglock);
    
    return 0;
}
//stores the msg in the tweet buffer, if space is avaiable and max tweet threshold is not reached 
// then the tweet is stored. else it returns -1
int
tput(topic_t tag,char* msg){
   
    acquire(&alltweetbuff[tag].tweettaglock);
  
    int index = getemptyindex(tag);
    
    if(index!=-1||tweetcounter>MAXTWEETTOTAL){
         strncpy(alltweetbuff[tag].tagtweetbuffer[index].msg,msg,strlen(msg));
         alltweetbuff[tag].tagtweetbuffer[index].tag=tag;
         tweetcounter++;
         wakeup(&getchan);
        
    }else{
        
        printf("No space available to put new msg returing -1\n");
         release(&alltweetbuff[tag].tweettaglock);
        return -1;
    }
   
    release(&alltweetbuff[tag].tweettaglock);
   
    
    return 0;
}
//gets the msg from the tweet buffer, if msg is avaiable with a given tag
// then the tweet is returned to user program. else it goes to sleep mode until the one of the put method calls wakeup 
//Also returns -1 if the copyout fails 
int 
btget(topic_t tag,uint64 buf){
   
    struct proc *p = myproc();
 
    acquire(&alltweetbuff[tag].tweettaglock);

    int index = gettagindex(tag);
    
     while(index==-1){

        sleep(&putchan,&alltweetbuff[tag].tweettaglock);
        index = getemptyindex(tag);

    }
         char *temp = alltweetbuff[tag].tagtweetbuffer[index].msg;

         if(copyout(p->pagetable,buf,temp,strlen(temp))!=0){
             printf("copyout failed");
             release(&alltweetbuff[tag].tweettaglock);
             return -1;
         }

        memset(alltweetbuff[tag].tagtweetbuffer[index].msg, 0, MAXTWEETLENGTH);
        
        tweetcounter--;
        wakeup(&getchan);
         
    release(&alltweetbuff[tag].tweettaglock);
    
     return 0;
}

//gets the msg from the tweet buffer, if msg is avaiable with a given tag
// then the tweet is returned to user program. else it returns -1
int
tget(topic_t tag,uint64 buf){
  
   struct proc *p = myproc();

    acquire(&alltweetbuff[tag].tweettaglock);
  
    int index = gettagindex(tag);
    if(index!=-1){

        char *temp = alltweetbuff[tag].tagtweetbuffer[index].msg;
        copyout(p->pagetable,buf,temp,strlen(temp));

        memset(alltweetbuff[tag].tagtweetbuffer[index].msg, 0, MAXTWEETLENGTH);
        
         tweetcounter--;
         wakeup(&getchan);
         
         
    }else{
        printf("no tweet msg available to read  with provided tag returing -1\n");
         release(&alltweetbuff[tag].tweettaglock);
        return -1;
    }
   
 
    release(&alltweetbuff[tag].tweettaglock);
    
     return 0;
}
