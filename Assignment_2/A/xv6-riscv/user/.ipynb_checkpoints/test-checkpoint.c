#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[]){
   
       printf("%d\n",waitstat());wait(0);
    exit(0);
}
