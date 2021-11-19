
user/_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[]){
   0:	cb010113          	addi	sp,sp,-848
   4:	34113423          	sd	ra,840(sp)
   8:	34813023          	sd	s0,832(sp)
   c:	32913c23          	sd	s1,824(sp)
  10:	33213823          	sd	s2,816(sp)
  14:	33313423          	sd	s3,808(sp)
  18:	33413023          	sd	s4,800(sp)
  1c:	31513c23          	sd	s5,792(sp)
  20:	31613823          	sd	s6,784(sp)
  24:	31713423          	sd	s7,776(sp)
  28:	31813023          	sd	s8,768(sp)
  2c:	2f913c23          	sd	s9,760(sp)
  30:	2fa13823          	sd	s10,752(sp)
  34:	2fb13423          	sd	s11,744(sp)
  38:	0e80                	addi	s0,sp,848
    
    int startPidA=-1,endPidA=-1;
    int startPidB=-1,endPidB=-1;
    int startPidC=-1,endPidC=-1;
  
    char msgA[140] = "Tag A - Hello world!";
  3a:	4655                	li	a2,21
  3c:	00001597          	auipc	a1,0x1
  40:	fb458593          	addi	a1,a1,-76 # ff0 <malloc+0x4ea>
  44:	f0040513          	addi	a0,s0,-256
  48:	00000097          	auipc	ra,0x0
  4c:	64c080e7          	jalr	1612(ra) # 694 <memcpy>
  50:	07700613          	li	a2,119
  54:	4581                	li	a1,0
  56:	f1540513          	addi	a0,s0,-235
  5a:	00000097          	auipc	ra,0x0
  5e:	460080e7          	jalr	1120(ra) # 4ba <memset>
    char msgB[140] = "Tag B -   CMPT 332!";
  62:	4651                	li	a2,20
  64:	00001597          	auipc	a1,0x1
  68:	fa458593          	addi	a1,a1,-92 # 1008 <malloc+0x502>
  6c:	e7040513          	addi	a0,s0,-400
  70:	00000097          	auipc	ra,0x0
  74:	624080e7          	jalr	1572(ra) # 694 <memcpy>
  78:	07800613          	li	a2,120
  7c:	4581                	li	a1,0
  7e:	e8440513          	addi	a0,s0,-380
  82:	00000097          	auipc	ra,0x0
  86:	438080e7          	jalr	1080(ra) # 4ba <memset>
    char msgC[140] = "Tag C- Xv6 A 3 part A";
  8a:	4659                	li	a2,22
  8c:	00001597          	auipc	a1,0x1
  90:	f9458593          	addi	a1,a1,-108 # 1020 <malloc+0x51a>
  94:	de040513          	addi	a0,s0,-544
  98:	00000097          	auipc	ra,0x0
  9c:	5fc080e7          	jalr	1532(ra) # 694 <memcpy>
  a0:	07600613          	li	a2,118
  a4:	4581                	li	a1,0
  a6:	df640513          	addi	a0,s0,-522
  aa:	00000097          	auipc	ra,0x0
  ae:	410080e7          	jalr	1040(ra) # 4ba <memset>
   
    enum topic_t tag;
     
   
    int rc;
printf("************** Test case 1*********\n"); 
  b2:	00001517          	auipc	a0,0x1
  b6:	b3e50513          	addi	a0,a0,-1218 # bf0 <malloc+0xea>
  ba:	00001097          	auipc	ra,0x1
  be:	994080e7          	jalr	-1644(ra) # a4e <printf>
    printf("Test case: Calling btput 45 times from the child process then in parent process calling btget 45 times.\n Also, while start 15 tweet will be for tag A, next 15 will be tag B and the last 15 will be tag c.\n"), 
  c2:	00001517          	auipc	a0,0x1
  c6:	b5650513          	addi	a0,a0,-1194 # c18 <malloc+0x112>
  ca:	00001097          	auipc	ra,0x1
  ce:	984080e7          	jalr	-1660(ra) # a4e <printf>
    printf("Expected output: All the sender (child process) tweet msg should be revied by the correct reciver (parent) tag\n\n");
  d2:	00001517          	auipc	a0,0x1
  d6:	c1650513          	addi	a0,a0,-1002 # ce8 <malloc+0x1e2>
  da:	00001097          	auipc	ra,0x1
  de:	974080e7          	jalr	-1676(ra) # a4e <printf>
    printf("Actual output: \n");
  e2:	00001517          	auipc	a0,0x1
  e6:	c7e50513          	addi	a0,a0,-898 # d60 <malloc+0x25a>
  ea:	00001097          	auipc	ra,0x1
  ee:	964080e7          	jalr	-1692(ra) # a4e <printf>
  f2:	4a05                	li	s4,1
  f4:	4981                	li	s3,0
    int startPidC=-1,endPidC=-1;
  f6:	5c7d                	li	s8,-1
    int startPidB=-1,endPidB=-1;
  f8:	57fd                	li	a5,-1
  fa:	caf43c23          	sd	a5,-840(s0)
  fe:	5b7d                	li	s6,-1
    int startPidA=-1,endPidA=-1;
 100:	5d7d                	li	s10,-1
 102:	5afd                	li	s5,-1
for(int f=0;f<45;f++){
 104:	02c00d93          	li	s11,44
        }else{
            
         
            if(f==0 && startPidA==-1){
                startPidA = rc;
            }else if(f==14 && endPidA==-1){
 108:	4cb9                	li	s9,14
                 endPidA = rc;
            }else if(f==15 && startPidB==-1){
                startPidB = rc;
            }else if(f==29 && endPidB==-1){
                 endPidB = rc;
            }else if(f==30 && startPidC==-1){
 10a:	5bfd                	li	s7,-1
 10c:	a8a1                	j	164 <main+0x164>
            if(f<15){
 10e:	47b9                	li	a5,14
 110:	0327d263          	bge	a5,s2,134 <main+0x134>
            }else if(f>=15 && f < 30){
 114:	39c5                	addiw	s3,s3,-15
 116:	47b9                	li	a5,14
 118:	0337e663          	bltu	a5,s3,144 <main+0x144>
                btput(tag=b,msgB);
 11c:	e7040593          	addi	a1,s0,-400
 120:	4505                	li	a0,1
 122:	00000097          	auipc	ra,0x0
 126:	632080e7          	jalr	1586(ra) # 754 <btput>
        exit(0);
 12a:	4501                	li	a0,0
 12c:	00000097          	auipc	ra,0x0
 130:	588080e7          	jalr	1416(ra) # 6b4 <exit>
                btput(tag=a,msgA);
 134:	f0040593          	addi	a1,s0,-256
 138:	4501                	li	a0,0
 13a:	00000097          	auipc	ra,0x0
 13e:	61a080e7          	jalr	1562(ra) # 754 <btput>
 142:	b7e5                	j	12a <main+0x12a>
                btput(tag=c,msgC);
 144:	de040593          	addi	a1,s0,-544
 148:	4509                	li	a0,2
 14a:	00000097          	auipc	ra,0x0
 14e:	60a080e7          	jalr	1546(ra) # 754 <btput>
 152:	bfe1                	j	12a <main+0x12a>
            if(f==0 && startPidA==-1){
 154:	2f7a8863          	beq	s5,s7,444 <main+0x444>
for(int f=0;f<45;f++){
 158:	000a079b          	sext.w	a5,s4
 15c:	06fdc563          	blt	s11,a5,1c6 <main+0x1c6>
 160:	2985                	addiw	s3,s3,1
 162:	2a05                	addiw	s4,s4,1
 164:	0009891b          	sext.w	s2,s3
        rc=fork();
 168:	00000097          	auipc	ra,0x0
 16c:	544080e7          	jalr	1348(ra) # 6ac <fork>
 170:	84aa                	mv	s1,a0
        if(rc==0){
 172:	dd51                	beqz	a0,10e <main+0x10e>
            if(f==0 && startPidA==-1){
 174:	fe0900e3          	beqz	s2,154 <main+0x154>
            }else if(f==14 && endPidA==-1){
 178:	01990f63          	beq	s2,s9,196 <main+0x196>
            }else if(f==15 && startPidB==-1){
 17c:	47bd                	li	a5,15
 17e:	02f90063          	beq	s2,a5,19e <main+0x19e>
            }else if(f==29 && endPidB==-1){
 182:	47f5                	li	a5,29
 184:	02f90163          	beq	s2,a5,1a6 <main+0x1a6>
            }else if(f==30 && startPidC==-1){
 188:	47f9                	li	a5,30
 18a:	02f91563          	bne	s2,a5,1b4 <main+0x1b4>
 18e:	fd7c15e3          	bne	s8,s7,158 <main+0x158>
        rc=fork();
 192:	8c2a                	mv	s8,a0
for(int f=0;f<45;f++){
 194:	b7f1                	j	160 <main+0x160>
            }else if(f==14 && endPidA==-1){
 196:	fd7d11e3          	bne	s10,s7,158 <main+0x158>
        rc=fork();
 19a:	8d2a                	mv	s10,a0
 19c:	b7d1                	j	160 <main+0x160>
            }else if(f==15 && startPidB==-1){
 19e:	fb7b1de3          	bne	s6,s7,158 <main+0x158>
        rc=fork();
 1a2:	8b2a                	mv	s6,a0
 1a4:	bf75                	j	160 <main+0x160>
            }else if(f==29 && endPidB==-1){
 1a6:	cb843783          	ld	a5,-840(s0)
 1aa:	fb7797e3          	bne	a5,s7,158 <main+0x158>
        rc=fork();
 1ae:	caa43c23          	sd	a0,-840(s0)
 1b2:	b77d                	j	160 <main+0x160>
                startPidC = rc;
            }else if(f==44 && endPidC==-1){
 1b4:	fbb912e3          	bne	s2,s11,158 <main+0x158>
            
            
        }
    }
      
      for(int i=0;i<45;i++){
 1b8:	02d00913          	li	s2,45
            }else if(pid>=startPidB && pid<=endPidB){
                 btget(tag=b,buf);
                 printf("btget output: %s \n",buf);
            }else if(pid>=startPidC && pid<=endPidC){
                 btget(tag=c,buf);
                 printf("btget output: %s \n",buf);
 1bc:	00001997          	auipc	s3,0x1
 1c0:	bbc98993          	addi	s3,s3,-1092 # d78 <malloc+0x272>
 1c4:	a025                	j	1ec <main+0x1ec>
 1c6:	54fd                	li	s1,-1
 1c8:	bfc5                	j	1b8 <main+0x1b8>
                 btget(tag=a,buf);
 1ca:	cc040593          	addi	a1,s0,-832
 1ce:	4501                	li	a0,0
 1d0:	00000097          	auipc	ra,0x0
 1d4:	594080e7          	jalr	1428(ra) # 764 <btget>
                 printf("btget output: %s \n",buf);           
 1d8:	cc040593          	addi	a1,s0,-832
 1dc:	854e                	mv	a0,s3
 1de:	00001097          	auipc	ra,0x1
 1e2:	870080e7          	jalr	-1936(ra) # a4e <printf>
      for(int i=0;i<45;i++){
 1e6:	397d                	addiw	s2,s2,-1
 1e8:	06090363          	beqz	s2,24e <main+0x24e>
           pid = wait(0);
 1ec:	4501                	li	a0,0
 1ee:	00000097          	auipc	ra,0x0
 1f2:	4ce080e7          	jalr	1230(ra) # 6bc <wait>
           if(pid>=startPidA && pid<=endPidA){
 1f6:	01554463          	blt	a0,s5,1fe <main+0x1fe>
 1fa:	fcad58e3          	bge	s10,a0,1ca <main+0x1ca>
            }else if(pid>=startPidB && pid<=endPidB){
 1fe:	01654663          	blt	a0,s6,20a <main+0x20a>
 202:	cb843783          	ld	a5,-840(s0)
 206:	02a7d563          	bge	a5,a0,230 <main+0x230>
            }else if(pid>=startPidC && pid<=endPidC){
 20a:	fd854ee3          	blt	a0,s8,1e6 <main+0x1e6>
 20e:	fca4cce3          	blt	s1,a0,1e6 <main+0x1e6>
                 btget(tag=c,buf);
 212:	cc040593          	addi	a1,s0,-832
 216:	4509                	li	a0,2
 218:	00000097          	auipc	ra,0x0
 21c:	54c080e7          	jalr	1356(ra) # 764 <btget>
                 printf("btget output: %s \n",buf);
 220:	cc040593          	addi	a1,s0,-832
 224:	854e                	mv	a0,s3
 226:	00001097          	auipc	ra,0x1
 22a:	828080e7          	jalr	-2008(ra) # a4e <printf>
 22e:	bf65                	j	1e6 <main+0x1e6>
                 btget(tag=b,buf);
 230:	cc040593          	addi	a1,s0,-832
 234:	4505                	li	a0,1
 236:	00000097          	auipc	ra,0x0
 23a:	52e080e7          	jalr	1326(ra) # 764 <btget>
                 printf("btget output: %s \n",buf);
 23e:	cc040593          	addi	a1,s0,-832
 242:	854e                	mv	a0,s3
 244:	00001097          	auipc	ra,0x1
 248:	80a080e7          	jalr	-2038(ra) # a4e <printf>
 24c:	bf69                	j	1e6 <main+0x1e6>
            }
        
        
    }
    
printf("************** Test case 2*********\n");  
 24e:	00001517          	auipc	a0,0x1
 252:	b4250513          	addi	a0,a0,-1214 # d90 <malloc+0x28a>
 256:	00000097          	auipc	ra,0x0
 25a:	7f8080e7          	jalr	2040(ra) # a4e <printf>
    printf("Test case: Calling tput and tget with tag a and a msg\n"), 
 25e:	00001517          	auipc	a0,0x1
 262:	b5a50513          	addi	a0,a0,-1190 # db8 <malloc+0x2b2>
 266:	00000097          	auipc	ra,0x0
 26a:	7e8080e7          	jalr	2024(ra) # a4e <printf>
    printf("Expected output: tget should report return the tput msg\n\n");
 26e:	00001517          	auipc	a0,0x1
 272:	b8250513          	addi	a0,a0,-1150 # df0 <malloc+0x2ea>
 276:	00000097          	auipc	ra,0x0
 27a:	7d8080e7          	jalr	2008(ra) # a4e <printf>
    printf("Actual output: ");
 27e:	00001517          	auipc	a0,0x1
 282:	bb250513          	addi	a0,a0,-1102 # e30 <malloc+0x32a>
 286:	00000097          	auipc	ra,0x0
 28a:	7c8080e7          	jalr	1992(ra) # a4e <printf>
    char buf2[140];
    tput(tag=a,msgA);
 28e:	f0040593          	addi	a1,s0,-256
 292:	4501                	li	a0,0
 294:	00000097          	auipc	ra,0x0
 298:	4c8080e7          	jalr	1224(ra) # 75c <tput>
    tget(tag=a,buf2);
 29c:	d5040593          	addi	a1,s0,-688
 2a0:	4501                	li	a0,0
 2a2:	00000097          	auipc	ra,0x0
 2a6:	4ca080e7          	jalr	1226(ra) # 76c <tget>
    printf("tget output: %s \n",buf2);
 2aa:	d5040593          	addi	a1,s0,-688
 2ae:	00001517          	auipc	a0,0x1
 2b2:	b9250513          	addi	a0,a0,-1134 # e40 <malloc+0x33a>
 2b6:	00000097          	auipc	ra,0x0
 2ba:	798080e7          	jalr	1944(ra) # a4e <printf>

printf("************** Test case 3*********\n");   
 2be:	00001517          	auipc	a0,0x1
 2c2:	b9a50513          	addi	a0,a0,-1126 # e58 <malloc+0x352>
 2c6:	00000097          	auipc	ra,0x0
 2ca:	788080e7          	jalr	1928(ra) # a4e <printf>
    printf("Test case: Calling tget for tag b which does not have any tweet stored for it\n"), 
 2ce:	00001517          	auipc	a0,0x1
 2d2:	bb250513          	addi	a0,a0,-1102 # e80 <malloc+0x37a>
 2d6:	00000097          	auipc	ra,0x0
 2da:	778080e7          	jalr	1912(ra) # a4e <printf>
    printf("Expected output: tget should report that no tweet to read with tag b and return -1\n\n");
 2de:	00001517          	auipc	a0,0x1
 2e2:	bf250513          	addi	a0,a0,-1038 # ed0 <malloc+0x3ca>
 2e6:	00000097          	auipc	ra,0x0
 2ea:	768080e7          	jalr	1896(ra) # a4e <printf>
    printf("Actual output: ");
 2ee:	00001517          	auipc	a0,0x1
 2f2:	b4250513          	addi	a0,a0,-1214 # e30 <malloc+0x32a>
 2f6:	00000097          	auipc	ra,0x0
 2fa:	758080e7          	jalr	1880(ra) # a4e <printf>
    tget(tag=b,buf2);
 2fe:	d5040593          	addi	a1,s0,-688
 302:	4505                	li	a0,1
 304:	00000097          	auipc	ra,0x0
 308:	468080e7          	jalr	1128(ra) # 76c <tget>

printf("************** Test case 4*********\n");
 30c:	00001517          	auipc	a0,0x1
 310:	c1c50513          	addi	a0,a0,-996 # f28 <malloc+0x422>
 314:	00000097          	auipc	ra,0x0
 318:	73a080e7          	jalr	1850(ra) # a4e <printf>
    printf("Test case: Calling tput 11 times and the maxtweet is set as 10\n"), 
 31c:	00001517          	auipc	a0,0x1
 320:	c3450513          	addi	a0,a0,-972 # f50 <malloc+0x44a>
 324:	00000097          	auipc	ra,0x0
 328:	72a080e7          	jalr	1834(ra) # a4e <printf>
    printf("Expected output: No space is available to store the tweet and end the tput call with -1\n\n");
 32c:	00001517          	auipc	a0,0x1
 330:	c6450513          	addi	a0,a0,-924 # f90 <malloc+0x48a>
 334:	00000097          	auipc	ra,0x0
 338:	71a080e7          	jalr	1818(ra) # a4e <printf>
     printf("Actual output: ");
 33c:	00001517          	auipc	a0,0x1
 340:	af450513          	addi	a0,a0,-1292 # e30 <malloc+0x32a>
 344:	00000097          	auipc	ra,0x0
 348:	70a080e7          	jalr	1802(ra) # a4e <printf>
    tput(tag=a,msgA);
 34c:	f0040593          	addi	a1,s0,-256
 350:	4501                	li	a0,0
 352:	00000097          	auipc	ra,0x0
 356:	40a080e7          	jalr	1034(ra) # 75c <tput>
    tput(tag=a,msgA);
 35a:	f0040593          	addi	a1,s0,-256
 35e:	4501                	li	a0,0
 360:	00000097          	auipc	ra,0x0
 364:	3fc080e7          	jalr	1020(ra) # 75c <tput>
    tput(tag=a,msgA);
 368:	f0040593          	addi	a1,s0,-256
 36c:	4501                	li	a0,0
 36e:	00000097          	auipc	ra,0x0
 372:	3ee080e7          	jalr	1006(ra) # 75c <tput>
    tput(tag=a,msgA);
 376:	f0040593          	addi	a1,s0,-256
 37a:	4501                	li	a0,0
 37c:	00000097          	auipc	ra,0x0
 380:	3e0080e7          	jalr	992(ra) # 75c <tput>
    tput(tag=a,msgA);
 384:	f0040593          	addi	a1,s0,-256
 388:	4501                	li	a0,0
 38a:	00000097          	auipc	ra,0x0
 38e:	3d2080e7          	jalr	978(ra) # 75c <tput>
    tput(tag=a,msgA);
 392:	f0040593          	addi	a1,s0,-256
 396:	4501                	li	a0,0
 398:	00000097          	auipc	ra,0x0
 39c:	3c4080e7          	jalr	964(ra) # 75c <tput>
    tput(tag=a,msgA);
 3a0:	f0040593          	addi	a1,s0,-256
 3a4:	4501                	li	a0,0
 3a6:	00000097          	auipc	ra,0x0
 3aa:	3b6080e7          	jalr	950(ra) # 75c <tput>
    tput(tag=a,msgA);
 3ae:	f0040593          	addi	a1,s0,-256
 3b2:	4501                	li	a0,0
 3b4:	00000097          	auipc	ra,0x0
 3b8:	3a8080e7          	jalr	936(ra) # 75c <tput>
    tput(tag=a,msgA);
 3bc:	f0040593          	addi	a1,s0,-256
 3c0:	4501                	li	a0,0
 3c2:	00000097          	auipc	ra,0x0
 3c6:	39a080e7          	jalr	922(ra) # 75c <tput>
 

    
    //removing the msgs from kernel space for next run.
    tget(tag=a,buf2);
 3ca:	d5040593          	addi	a1,s0,-688
 3ce:	4501                	li	a0,0
 3d0:	00000097          	auipc	ra,0x0
 3d4:	39c080e7          	jalr	924(ra) # 76c <tget>
    tget(tag=a,buf2);
 3d8:	d5040593          	addi	a1,s0,-688
 3dc:	4501                	li	a0,0
 3de:	00000097          	auipc	ra,0x0
 3e2:	38e080e7          	jalr	910(ra) # 76c <tget>
    tget(tag=a,buf2);
 3e6:	d5040593          	addi	a1,s0,-688
 3ea:	4501                	li	a0,0
 3ec:	00000097          	auipc	ra,0x0
 3f0:	380080e7          	jalr	896(ra) # 76c <tget>
    tget(tag=a,buf2);
 3f4:	d5040593          	addi	a1,s0,-688
 3f8:	4501                	li	a0,0
 3fa:	00000097          	auipc	ra,0x0
 3fe:	372080e7          	jalr	882(ra) # 76c <tget>
    tget(tag=a,buf2);
 402:	d5040593          	addi	a1,s0,-688
 406:	4501                	li	a0,0
 408:	00000097          	auipc	ra,0x0
 40c:	364080e7          	jalr	868(ra) # 76c <tget>
    tget(tag=a,buf2);
 410:	d5040593          	addi	a1,s0,-688
 414:	4501                	li	a0,0
 416:	00000097          	auipc	ra,0x0
 41a:	356080e7          	jalr	854(ra) # 76c <tget>
    tget(tag=a,buf2);
 41e:	d5040593          	addi	a1,s0,-688
 422:	4501                	li	a0,0
 424:	00000097          	auipc	ra,0x0
 428:	348080e7          	jalr	840(ra) # 76c <tget>
    tget(tag=a,buf2);
 42c:	d5040593          	addi	a1,s0,-688
 430:	4501                	li	a0,0
 432:	00000097          	auipc	ra,0x0
 436:	33a080e7          	jalr	826(ra) # 76c <tget>
  
  exit(0);
 43a:	4501                	li	a0,0
 43c:	00000097          	auipc	ra,0x0
 440:	278080e7          	jalr	632(ra) # 6b4 <exit>
        rc=fork();
 444:	8aaa                	mv	s5,a0
 446:	bb29                	j	160 <main+0x160>

0000000000000448 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 448:	1141                	addi	sp,sp,-16
 44a:	e422                	sd	s0,8(sp)
 44c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 44e:	87aa                	mv	a5,a0
 450:	0585                	addi	a1,a1,1
 452:	0785                	addi	a5,a5,1
 454:	fff5c703          	lbu	a4,-1(a1)
 458:	fee78fa3          	sb	a4,-1(a5)
 45c:	fb75                	bnez	a4,450 <strcpy+0x8>
    ;
  return os;
}
 45e:	6422                	ld	s0,8(sp)
 460:	0141                	addi	sp,sp,16
 462:	8082                	ret

0000000000000464 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 464:	1141                	addi	sp,sp,-16
 466:	e422                	sd	s0,8(sp)
 468:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 46a:	00054783          	lbu	a5,0(a0)
 46e:	cb91                	beqz	a5,482 <strcmp+0x1e>
 470:	0005c703          	lbu	a4,0(a1)
 474:	00f71763          	bne	a4,a5,482 <strcmp+0x1e>
    p++, q++;
 478:	0505                	addi	a0,a0,1
 47a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 47c:	00054783          	lbu	a5,0(a0)
 480:	fbe5                	bnez	a5,470 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 482:	0005c503          	lbu	a0,0(a1)
}
 486:	40a7853b          	subw	a0,a5,a0
 48a:	6422                	ld	s0,8(sp)
 48c:	0141                	addi	sp,sp,16
 48e:	8082                	ret

0000000000000490 <strlen>:

uint
strlen(const char *s)
{
 490:	1141                	addi	sp,sp,-16
 492:	e422                	sd	s0,8(sp)
 494:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 496:	00054783          	lbu	a5,0(a0)
 49a:	cf91                	beqz	a5,4b6 <strlen+0x26>
 49c:	0505                	addi	a0,a0,1
 49e:	87aa                	mv	a5,a0
 4a0:	4685                	li	a3,1
 4a2:	9e89                	subw	a3,a3,a0
 4a4:	00f6853b          	addw	a0,a3,a5
 4a8:	0785                	addi	a5,a5,1
 4aa:	fff7c703          	lbu	a4,-1(a5)
 4ae:	fb7d                	bnez	a4,4a4 <strlen+0x14>
    ;
  return n;
}
 4b0:	6422                	ld	s0,8(sp)
 4b2:	0141                	addi	sp,sp,16
 4b4:	8082                	ret
  for(n = 0; s[n]; n++)
 4b6:	4501                	li	a0,0
 4b8:	bfe5                	j	4b0 <strlen+0x20>

00000000000004ba <memset>:

void*
memset(void *dst, int c, uint n)
{
 4ba:	1141                	addi	sp,sp,-16
 4bc:	e422                	sd	s0,8(sp)
 4be:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 4c0:	ca19                	beqz	a2,4d6 <memset+0x1c>
 4c2:	87aa                	mv	a5,a0
 4c4:	1602                	slli	a2,a2,0x20
 4c6:	9201                	srli	a2,a2,0x20
 4c8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 4cc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 4d0:	0785                	addi	a5,a5,1
 4d2:	fee79de3          	bne	a5,a4,4cc <memset+0x12>
  }
  return dst;
}
 4d6:	6422                	ld	s0,8(sp)
 4d8:	0141                	addi	sp,sp,16
 4da:	8082                	ret

00000000000004dc <strchr>:

char*
strchr(const char *s, char c)
{
 4dc:	1141                	addi	sp,sp,-16
 4de:	e422                	sd	s0,8(sp)
 4e0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 4e2:	00054783          	lbu	a5,0(a0)
 4e6:	cb99                	beqz	a5,4fc <strchr+0x20>
    if(*s == c)
 4e8:	00f58763          	beq	a1,a5,4f6 <strchr+0x1a>
  for(; *s; s++)
 4ec:	0505                	addi	a0,a0,1
 4ee:	00054783          	lbu	a5,0(a0)
 4f2:	fbfd                	bnez	a5,4e8 <strchr+0xc>
      return (char*)s;
  return 0;
 4f4:	4501                	li	a0,0
}
 4f6:	6422                	ld	s0,8(sp)
 4f8:	0141                	addi	sp,sp,16
 4fa:	8082                	ret
  return 0;
 4fc:	4501                	li	a0,0
 4fe:	bfe5                	j	4f6 <strchr+0x1a>

0000000000000500 <gets>:

char*
gets(char *buf, int max)
{
 500:	711d                	addi	sp,sp,-96
 502:	ec86                	sd	ra,88(sp)
 504:	e8a2                	sd	s0,80(sp)
 506:	e4a6                	sd	s1,72(sp)
 508:	e0ca                	sd	s2,64(sp)
 50a:	fc4e                	sd	s3,56(sp)
 50c:	f852                	sd	s4,48(sp)
 50e:	f456                	sd	s5,40(sp)
 510:	f05a                	sd	s6,32(sp)
 512:	ec5e                	sd	s7,24(sp)
 514:	1080                	addi	s0,sp,96
 516:	8baa                	mv	s7,a0
 518:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 51a:	892a                	mv	s2,a0
 51c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 51e:	4aa9                	li	s5,10
 520:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 522:	89a6                	mv	s3,s1
 524:	2485                	addiw	s1,s1,1
 526:	0344d863          	bge	s1,s4,556 <gets+0x56>
    cc = read(0, &c, 1);
 52a:	4605                	li	a2,1
 52c:	faf40593          	addi	a1,s0,-81
 530:	4501                	li	a0,0
 532:	00000097          	auipc	ra,0x0
 536:	19a080e7          	jalr	410(ra) # 6cc <read>
    if(cc < 1)
 53a:	00a05e63          	blez	a0,556 <gets+0x56>
    buf[i++] = c;
 53e:	faf44783          	lbu	a5,-81(s0)
 542:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 546:	01578763          	beq	a5,s5,554 <gets+0x54>
 54a:	0905                	addi	s2,s2,1
 54c:	fd679be3          	bne	a5,s6,522 <gets+0x22>
  for(i=0; i+1 < max; ){
 550:	89a6                	mv	s3,s1
 552:	a011                	j	556 <gets+0x56>
 554:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 556:	99de                	add	s3,s3,s7
 558:	00098023          	sb	zero,0(s3)
  return buf;
}
 55c:	855e                	mv	a0,s7
 55e:	60e6                	ld	ra,88(sp)
 560:	6446                	ld	s0,80(sp)
 562:	64a6                	ld	s1,72(sp)
 564:	6906                	ld	s2,64(sp)
 566:	79e2                	ld	s3,56(sp)
 568:	7a42                	ld	s4,48(sp)
 56a:	7aa2                	ld	s5,40(sp)
 56c:	7b02                	ld	s6,32(sp)
 56e:	6be2                	ld	s7,24(sp)
 570:	6125                	addi	sp,sp,96
 572:	8082                	ret

0000000000000574 <stat>:

int
stat(const char *n, struct stat *st)
{
 574:	1101                	addi	sp,sp,-32
 576:	ec06                	sd	ra,24(sp)
 578:	e822                	sd	s0,16(sp)
 57a:	e426                	sd	s1,8(sp)
 57c:	e04a                	sd	s2,0(sp)
 57e:	1000                	addi	s0,sp,32
 580:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 582:	4581                	li	a1,0
 584:	00000097          	auipc	ra,0x0
 588:	170080e7          	jalr	368(ra) # 6f4 <open>
  if(fd < 0)
 58c:	02054563          	bltz	a0,5b6 <stat+0x42>
 590:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 592:	85ca                	mv	a1,s2
 594:	00000097          	auipc	ra,0x0
 598:	178080e7          	jalr	376(ra) # 70c <fstat>
 59c:	892a                	mv	s2,a0
  close(fd);
 59e:	8526                	mv	a0,s1
 5a0:	00000097          	auipc	ra,0x0
 5a4:	13c080e7          	jalr	316(ra) # 6dc <close>
  return r;
}
 5a8:	854a                	mv	a0,s2
 5aa:	60e2                	ld	ra,24(sp)
 5ac:	6442                	ld	s0,16(sp)
 5ae:	64a2                	ld	s1,8(sp)
 5b0:	6902                	ld	s2,0(sp)
 5b2:	6105                	addi	sp,sp,32
 5b4:	8082                	ret
    return -1;
 5b6:	597d                	li	s2,-1
 5b8:	bfc5                	j	5a8 <stat+0x34>

00000000000005ba <atoi>:

int
atoi(const char *s)
{
 5ba:	1141                	addi	sp,sp,-16
 5bc:	e422                	sd	s0,8(sp)
 5be:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5c0:	00054683          	lbu	a3,0(a0)
 5c4:	fd06879b          	addiw	a5,a3,-48
 5c8:	0ff7f793          	zext.b	a5,a5
 5cc:	4625                	li	a2,9
 5ce:	02f66863          	bltu	a2,a5,5fe <atoi+0x44>
 5d2:	872a                	mv	a4,a0
  n = 0;
 5d4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 5d6:	0705                	addi	a4,a4,1
 5d8:	0025179b          	slliw	a5,a0,0x2
 5dc:	9fa9                	addw	a5,a5,a0
 5de:	0017979b          	slliw	a5,a5,0x1
 5e2:	9fb5                	addw	a5,a5,a3
 5e4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 5e8:	00074683          	lbu	a3,0(a4)
 5ec:	fd06879b          	addiw	a5,a3,-48
 5f0:	0ff7f793          	zext.b	a5,a5
 5f4:	fef671e3          	bgeu	a2,a5,5d6 <atoi+0x1c>
  return n;
}
 5f8:	6422                	ld	s0,8(sp)
 5fa:	0141                	addi	sp,sp,16
 5fc:	8082                	ret
  n = 0;
 5fe:	4501                	li	a0,0
 600:	bfe5                	j	5f8 <atoi+0x3e>

0000000000000602 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 602:	1141                	addi	sp,sp,-16
 604:	e422                	sd	s0,8(sp)
 606:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 608:	02b57463          	bgeu	a0,a1,630 <memmove+0x2e>
    while(n-- > 0)
 60c:	00c05f63          	blez	a2,62a <memmove+0x28>
 610:	1602                	slli	a2,a2,0x20
 612:	9201                	srli	a2,a2,0x20
 614:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 618:	872a                	mv	a4,a0
      *dst++ = *src++;
 61a:	0585                	addi	a1,a1,1
 61c:	0705                	addi	a4,a4,1
 61e:	fff5c683          	lbu	a3,-1(a1)
 622:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 626:	fee79ae3          	bne	a5,a4,61a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 62a:	6422                	ld	s0,8(sp)
 62c:	0141                	addi	sp,sp,16
 62e:	8082                	ret
    dst += n;
 630:	00c50733          	add	a4,a0,a2
    src += n;
 634:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 636:	fec05ae3          	blez	a2,62a <memmove+0x28>
 63a:	fff6079b          	addiw	a5,a2,-1
 63e:	1782                	slli	a5,a5,0x20
 640:	9381                	srli	a5,a5,0x20
 642:	fff7c793          	not	a5,a5
 646:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 648:	15fd                	addi	a1,a1,-1
 64a:	177d                	addi	a4,a4,-1
 64c:	0005c683          	lbu	a3,0(a1)
 650:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 654:	fee79ae3          	bne	a5,a4,648 <memmove+0x46>
 658:	bfc9                	j	62a <memmove+0x28>

000000000000065a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 65a:	1141                	addi	sp,sp,-16
 65c:	e422                	sd	s0,8(sp)
 65e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 660:	ca05                	beqz	a2,690 <memcmp+0x36>
 662:	fff6069b          	addiw	a3,a2,-1
 666:	1682                	slli	a3,a3,0x20
 668:	9281                	srli	a3,a3,0x20
 66a:	0685                	addi	a3,a3,1
 66c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 66e:	00054783          	lbu	a5,0(a0)
 672:	0005c703          	lbu	a4,0(a1)
 676:	00e79863          	bne	a5,a4,686 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 67a:	0505                	addi	a0,a0,1
    p2++;
 67c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 67e:	fed518e3          	bne	a0,a3,66e <memcmp+0x14>
  }
  return 0;
 682:	4501                	li	a0,0
 684:	a019                	j	68a <memcmp+0x30>
      return *p1 - *p2;
 686:	40e7853b          	subw	a0,a5,a4
}
 68a:	6422                	ld	s0,8(sp)
 68c:	0141                	addi	sp,sp,16
 68e:	8082                	ret
  return 0;
 690:	4501                	li	a0,0
 692:	bfe5                	j	68a <memcmp+0x30>

0000000000000694 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 694:	1141                	addi	sp,sp,-16
 696:	e406                	sd	ra,8(sp)
 698:	e022                	sd	s0,0(sp)
 69a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 69c:	00000097          	auipc	ra,0x0
 6a0:	f66080e7          	jalr	-154(ra) # 602 <memmove>
}
 6a4:	60a2                	ld	ra,8(sp)
 6a6:	6402                	ld	s0,0(sp)
 6a8:	0141                	addi	sp,sp,16
 6aa:	8082                	ret

00000000000006ac <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6ac:	4885                	li	a7,1
 ecall
 6ae:	00000073          	ecall
 ret
 6b2:	8082                	ret

00000000000006b4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 6b4:	4889                	li	a7,2
 ecall
 6b6:	00000073          	ecall
 ret
 6ba:	8082                	ret

00000000000006bc <wait>:
.global wait
wait:
 li a7, SYS_wait
 6bc:	488d                	li	a7,3
 ecall
 6be:	00000073          	ecall
 ret
 6c2:	8082                	ret

00000000000006c4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6c4:	4891                	li	a7,4
 ecall
 6c6:	00000073          	ecall
 ret
 6ca:	8082                	ret

00000000000006cc <read>:
.global read
read:
 li a7, SYS_read
 6cc:	4895                	li	a7,5
 ecall
 6ce:	00000073          	ecall
 ret
 6d2:	8082                	ret

00000000000006d4 <write>:
.global write
write:
 li a7, SYS_write
 6d4:	48c1                	li	a7,16
 ecall
 6d6:	00000073          	ecall
 ret
 6da:	8082                	ret

00000000000006dc <close>:
.global close
close:
 li a7, SYS_close
 6dc:	48d5                	li	a7,21
 ecall
 6de:	00000073          	ecall
 ret
 6e2:	8082                	ret

00000000000006e4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 6e4:	4899                	li	a7,6
 ecall
 6e6:	00000073          	ecall
 ret
 6ea:	8082                	ret

00000000000006ec <exec>:
.global exec
exec:
 li a7, SYS_exec
 6ec:	489d                	li	a7,7
 ecall
 6ee:	00000073          	ecall
 ret
 6f2:	8082                	ret

00000000000006f4 <open>:
.global open
open:
 li a7, SYS_open
 6f4:	48bd                	li	a7,15
 ecall
 6f6:	00000073          	ecall
 ret
 6fa:	8082                	ret

00000000000006fc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 6fc:	48c5                	li	a7,17
 ecall
 6fe:	00000073          	ecall
 ret
 702:	8082                	ret

0000000000000704 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 704:	48c9                	li	a7,18
 ecall
 706:	00000073          	ecall
 ret
 70a:	8082                	ret

000000000000070c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 70c:	48a1                	li	a7,8
 ecall
 70e:	00000073          	ecall
 ret
 712:	8082                	ret

0000000000000714 <link>:
.global link
link:
 li a7, SYS_link
 714:	48cd                	li	a7,19
 ecall
 716:	00000073          	ecall
 ret
 71a:	8082                	ret

000000000000071c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 71c:	48d1                	li	a7,20
 ecall
 71e:	00000073          	ecall
 ret
 722:	8082                	ret

0000000000000724 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 724:	48a5                	li	a7,9
 ecall
 726:	00000073          	ecall
 ret
 72a:	8082                	ret

000000000000072c <dup>:
.global dup
dup:
 li a7, SYS_dup
 72c:	48a9                	li	a7,10
 ecall
 72e:	00000073          	ecall
 ret
 732:	8082                	ret

0000000000000734 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 734:	48ad                	li	a7,11
 ecall
 736:	00000073          	ecall
 ret
 73a:	8082                	ret

000000000000073c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 73c:	48b1                	li	a7,12
 ecall
 73e:	00000073          	ecall
 ret
 742:	8082                	ret

0000000000000744 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 744:	48b5                	li	a7,13
 ecall
 746:	00000073          	ecall
 ret
 74a:	8082                	ret

000000000000074c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 74c:	48b9                	li	a7,14
 ecall
 74e:	00000073          	ecall
 ret
 752:	8082                	ret

0000000000000754 <btput>:
.global btput
btput:
 li a7, SYS_btput
 754:	48d9                	li	a7,22
 ecall
 756:	00000073          	ecall
 ret
 75a:	8082                	ret

000000000000075c <tput>:
.global tput
tput:
 li a7, SYS_tput
 75c:	48dd                	li	a7,23
 ecall
 75e:	00000073          	ecall
 ret
 762:	8082                	ret

0000000000000764 <btget>:
.global btget
btget:
 li a7, SYS_btget
 764:	48e1                	li	a7,24
 ecall
 766:	00000073          	ecall
 ret
 76a:	8082                	ret

000000000000076c <tget>:
.global tget
tget:
 li a7, SYS_tget
 76c:	48e5                	li	a7,25
 ecall
 76e:	00000073          	ecall
 ret
 772:	8082                	ret

0000000000000774 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 774:	1101                	addi	sp,sp,-32
 776:	ec06                	sd	ra,24(sp)
 778:	e822                	sd	s0,16(sp)
 77a:	1000                	addi	s0,sp,32
 77c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 780:	4605                	li	a2,1
 782:	fef40593          	addi	a1,s0,-17
 786:	00000097          	auipc	ra,0x0
 78a:	f4e080e7          	jalr	-178(ra) # 6d4 <write>
}
 78e:	60e2                	ld	ra,24(sp)
 790:	6442                	ld	s0,16(sp)
 792:	6105                	addi	sp,sp,32
 794:	8082                	ret

0000000000000796 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 796:	7139                	addi	sp,sp,-64
 798:	fc06                	sd	ra,56(sp)
 79a:	f822                	sd	s0,48(sp)
 79c:	f426                	sd	s1,40(sp)
 79e:	f04a                	sd	s2,32(sp)
 7a0:	ec4e                	sd	s3,24(sp)
 7a2:	0080                	addi	s0,sp,64
 7a4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 7a6:	c299                	beqz	a3,7ac <printint+0x16>
 7a8:	0805c963          	bltz	a1,83a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 7ac:	2581                	sext.w	a1,a1
  neg = 0;
 7ae:	4881                	li	a7,0
 7b0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 7b4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 7b6:	2601                	sext.w	a2,a2
 7b8:	00001517          	auipc	a0,0x1
 7bc:	8e050513          	addi	a0,a0,-1824 # 1098 <digits>
 7c0:	883a                	mv	a6,a4
 7c2:	2705                	addiw	a4,a4,1
 7c4:	02c5f7bb          	remuw	a5,a1,a2
 7c8:	1782                	slli	a5,a5,0x20
 7ca:	9381                	srli	a5,a5,0x20
 7cc:	97aa                	add	a5,a5,a0
 7ce:	0007c783          	lbu	a5,0(a5)
 7d2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 7d6:	0005879b          	sext.w	a5,a1
 7da:	02c5d5bb          	divuw	a1,a1,a2
 7de:	0685                	addi	a3,a3,1
 7e0:	fec7f0e3          	bgeu	a5,a2,7c0 <printint+0x2a>
  if(neg)
 7e4:	00088c63          	beqz	a7,7fc <printint+0x66>
    buf[i++] = '-';
 7e8:	fd070793          	addi	a5,a4,-48
 7ec:	00878733          	add	a4,a5,s0
 7f0:	02d00793          	li	a5,45
 7f4:	fef70823          	sb	a5,-16(a4)
 7f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 7fc:	02e05863          	blez	a4,82c <printint+0x96>
 800:	fc040793          	addi	a5,s0,-64
 804:	00e78933          	add	s2,a5,a4
 808:	fff78993          	addi	s3,a5,-1
 80c:	99ba                	add	s3,s3,a4
 80e:	377d                	addiw	a4,a4,-1
 810:	1702                	slli	a4,a4,0x20
 812:	9301                	srli	a4,a4,0x20
 814:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 818:	fff94583          	lbu	a1,-1(s2)
 81c:	8526                	mv	a0,s1
 81e:	00000097          	auipc	ra,0x0
 822:	f56080e7          	jalr	-170(ra) # 774 <putc>
  while(--i >= 0)
 826:	197d                	addi	s2,s2,-1
 828:	ff3918e3          	bne	s2,s3,818 <printint+0x82>
}
 82c:	70e2                	ld	ra,56(sp)
 82e:	7442                	ld	s0,48(sp)
 830:	74a2                	ld	s1,40(sp)
 832:	7902                	ld	s2,32(sp)
 834:	69e2                	ld	s3,24(sp)
 836:	6121                	addi	sp,sp,64
 838:	8082                	ret
    x = -xx;
 83a:	40b005bb          	negw	a1,a1
    neg = 1;
 83e:	4885                	li	a7,1
    x = -xx;
 840:	bf85                	j	7b0 <printint+0x1a>

0000000000000842 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 842:	7119                	addi	sp,sp,-128
 844:	fc86                	sd	ra,120(sp)
 846:	f8a2                	sd	s0,112(sp)
 848:	f4a6                	sd	s1,104(sp)
 84a:	f0ca                	sd	s2,96(sp)
 84c:	ecce                	sd	s3,88(sp)
 84e:	e8d2                	sd	s4,80(sp)
 850:	e4d6                	sd	s5,72(sp)
 852:	e0da                	sd	s6,64(sp)
 854:	fc5e                	sd	s7,56(sp)
 856:	f862                	sd	s8,48(sp)
 858:	f466                	sd	s9,40(sp)
 85a:	f06a                	sd	s10,32(sp)
 85c:	ec6e                	sd	s11,24(sp)
 85e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 860:	0005c903          	lbu	s2,0(a1)
 864:	18090f63          	beqz	s2,a02 <vprintf+0x1c0>
 868:	8aaa                	mv	s5,a0
 86a:	8b32                	mv	s6,a2
 86c:	00158493          	addi	s1,a1,1
  state = 0;
 870:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 872:	02500a13          	li	s4,37
 876:	4c55                	li	s8,21
 878:	00000c97          	auipc	s9,0x0
 87c:	7c8c8c93          	addi	s9,s9,1992 # 1040 <malloc+0x53a>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 880:	02800d93          	li	s11,40
  putc(fd, 'x');
 884:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 886:	00001b97          	auipc	s7,0x1
 88a:	812b8b93          	addi	s7,s7,-2030 # 1098 <digits>
 88e:	a839                	j	8ac <vprintf+0x6a>
        putc(fd, c);
 890:	85ca                	mv	a1,s2
 892:	8556                	mv	a0,s5
 894:	00000097          	auipc	ra,0x0
 898:	ee0080e7          	jalr	-288(ra) # 774 <putc>
 89c:	a019                	j	8a2 <vprintf+0x60>
    } else if(state == '%'){
 89e:	01498d63          	beq	s3,s4,8b8 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 8a2:	0485                	addi	s1,s1,1
 8a4:	fff4c903          	lbu	s2,-1(s1)
 8a8:	14090d63          	beqz	s2,a02 <vprintf+0x1c0>
    if(state == 0){
 8ac:	fe0999e3          	bnez	s3,89e <vprintf+0x5c>
      if(c == '%'){
 8b0:	ff4910e3          	bne	s2,s4,890 <vprintf+0x4e>
        state = '%';
 8b4:	89d2                	mv	s3,s4
 8b6:	b7f5                	j	8a2 <vprintf+0x60>
      if(c == 'd'){
 8b8:	11490c63          	beq	s2,s4,9d0 <vprintf+0x18e>
 8bc:	f9d9079b          	addiw	a5,s2,-99
 8c0:	0ff7f793          	zext.b	a5,a5
 8c4:	10fc6e63          	bltu	s8,a5,9e0 <vprintf+0x19e>
 8c8:	f9d9079b          	addiw	a5,s2,-99
 8cc:	0ff7f713          	zext.b	a4,a5
 8d0:	10ec6863          	bltu	s8,a4,9e0 <vprintf+0x19e>
 8d4:	00271793          	slli	a5,a4,0x2
 8d8:	97e6                	add	a5,a5,s9
 8da:	439c                	lw	a5,0(a5)
 8dc:	97e6                	add	a5,a5,s9
 8de:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 8e0:	008b0913          	addi	s2,s6,8
 8e4:	4685                	li	a3,1
 8e6:	4629                	li	a2,10
 8e8:	000b2583          	lw	a1,0(s6)
 8ec:	8556                	mv	a0,s5
 8ee:	00000097          	auipc	ra,0x0
 8f2:	ea8080e7          	jalr	-344(ra) # 796 <printint>
 8f6:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 8f8:	4981                	li	s3,0
 8fa:	b765                	j	8a2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8fc:	008b0913          	addi	s2,s6,8
 900:	4681                	li	a3,0
 902:	4629                	li	a2,10
 904:	000b2583          	lw	a1,0(s6)
 908:	8556                	mv	a0,s5
 90a:	00000097          	auipc	ra,0x0
 90e:	e8c080e7          	jalr	-372(ra) # 796 <printint>
 912:	8b4a                	mv	s6,s2
      state = 0;
 914:	4981                	li	s3,0
 916:	b771                	j	8a2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 918:	008b0913          	addi	s2,s6,8
 91c:	4681                	li	a3,0
 91e:	866a                	mv	a2,s10
 920:	000b2583          	lw	a1,0(s6)
 924:	8556                	mv	a0,s5
 926:	00000097          	auipc	ra,0x0
 92a:	e70080e7          	jalr	-400(ra) # 796 <printint>
 92e:	8b4a                	mv	s6,s2
      state = 0;
 930:	4981                	li	s3,0
 932:	bf85                	j	8a2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 934:	008b0793          	addi	a5,s6,8
 938:	f8f43423          	sd	a5,-120(s0)
 93c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 940:	03000593          	li	a1,48
 944:	8556                	mv	a0,s5
 946:	00000097          	auipc	ra,0x0
 94a:	e2e080e7          	jalr	-466(ra) # 774 <putc>
  putc(fd, 'x');
 94e:	07800593          	li	a1,120
 952:	8556                	mv	a0,s5
 954:	00000097          	auipc	ra,0x0
 958:	e20080e7          	jalr	-480(ra) # 774 <putc>
 95c:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 95e:	03c9d793          	srli	a5,s3,0x3c
 962:	97de                	add	a5,a5,s7
 964:	0007c583          	lbu	a1,0(a5)
 968:	8556                	mv	a0,s5
 96a:	00000097          	auipc	ra,0x0
 96e:	e0a080e7          	jalr	-502(ra) # 774 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 972:	0992                	slli	s3,s3,0x4
 974:	397d                	addiw	s2,s2,-1
 976:	fe0914e3          	bnez	s2,95e <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 97a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 97e:	4981                	li	s3,0
 980:	b70d                	j	8a2 <vprintf+0x60>
        s = va_arg(ap, char*);
 982:	008b0913          	addi	s2,s6,8
 986:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 98a:	02098163          	beqz	s3,9ac <vprintf+0x16a>
        while(*s != 0){
 98e:	0009c583          	lbu	a1,0(s3)
 992:	c5ad                	beqz	a1,9fc <vprintf+0x1ba>
          putc(fd, *s);
 994:	8556                	mv	a0,s5
 996:	00000097          	auipc	ra,0x0
 99a:	dde080e7          	jalr	-546(ra) # 774 <putc>
          s++;
 99e:	0985                	addi	s3,s3,1
        while(*s != 0){
 9a0:	0009c583          	lbu	a1,0(s3)
 9a4:	f9e5                	bnez	a1,994 <vprintf+0x152>
        s = va_arg(ap, char*);
 9a6:	8b4a                	mv	s6,s2
      state = 0;
 9a8:	4981                	li	s3,0
 9aa:	bde5                	j	8a2 <vprintf+0x60>
          s = "(null)";
 9ac:	00000997          	auipc	s3,0x0
 9b0:	68c98993          	addi	s3,s3,1676 # 1038 <malloc+0x532>
        while(*s != 0){
 9b4:	85ee                	mv	a1,s11
 9b6:	bff9                	j	994 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 9b8:	008b0913          	addi	s2,s6,8
 9bc:	000b4583          	lbu	a1,0(s6)
 9c0:	8556                	mv	a0,s5
 9c2:	00000097          	auipc	ra,0x0
 9c6:	db2080e7          	jalr	-590(ra) # 774 <putc>
 9ca:	8b4a                	mv	s6,s2
      state = 0;
 9cc:	4981                	li	s3,0
 9ce:	bdd1                	j	8a2 <vprintf+0x60>
        putc(fd, c);
 9d0:	85d2                	mv	a1,s4
 9d2:	8556                	mv	a0,s5
 9d4:	00000097          	auipc	ra,0x0
 9d8:	da0080e7          	jalr	-608(ra) # 774 <putc>
      state = 0;
 9dc:	4981                	li	s3,0
 9de:	b5d1                	j	8a2 <vprintf+0x60>
        putc(fd, '%');
 9e0:	85d2                	mv	a1,s4
 9e2:	8556                	mv	a0,s5
 9e4:	00000097          	auipc	ra,0x0
 9e8:	d90080e7          	jalr	-624(ra) # 774 <putc>
        putc(fd, c);
 9ec:	85ca                	mv	a1,s2
 9ee:	8556                	mv	a0,s5
 9f0:	00000097          	auipc	ra,0x0
 9f4:	d84080e7          	jalr	-636(ra) # 774 <putc>
      state = 0;
 9f8:	4981                	li	s3,0
 9fa:	b565                	j	8a2 <vprintf+0x60>
        s = va_arg(ap, char*);
 9fc:	8b4a                	mv	s6,s2
      state = 0;
 9fe:	4981                	li	s3,0
 a00:	b54d                	j	8a2 <vprintf+0x60>
    }
  }
}
 a02:	70e6                	ld	ra,120(sp)
 a04:	7446                	ld	s0,112(sp)
 a06:	74a6                	ld	s1,104(sp)
 a08:	7906                	ld	s2,96(sp)
 a0a:	69e6                	ld	s3,88(sp)
 a0c:	6a46                	ld	s4,80(sp)
 a0e:	6aa6                	ld	s5,72(sp)
 a10:	6b06                	ld	s6,64(sp)
 a12:	7be2                	ld	s7,56(sp)
 a14:	7c42                	ld	s8,48(sp)
 a16:	7ca2                	ld	s9,40(sp)
 a18:	7d02                	ld	s10,32(sp)
 a1a:	6de2                	ld	s11,24(sp)
 a1c:	6109                	addi	sp,sp,128
 a1e:	8082                	ret

0000000000000a20 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a20:	715d                	addi	sp,sp,-80
 a22:	ec06                	sd	ra,24(sp)
 a24:	e822                	sd	s0,16(sp)
 a26:	1000                	addi	s0,sp,32
 a28:	e010                	sd	a2,0(s0)
 a2a:	e414                	sd	a3,8(s0)
 a2c:	e818                	sd	a4,16(s0)
 a2e:	ec1c                	sd	a5,24(s0)
 a30:	03043023          	sd	a6,32(s0)
 a34:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a38:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a3c:	8622                	mv	a2,s0
 a3e:	00000097          	auipc	ra,0x0
 a42:	e04080e7          	jalr	-508(ra) # 842 <vprintf>
}
 a46:	60e2                	ld	ra,24(sp)
 a48:	6442                	ld	s0,16(sp)
 a4a:	6161                	addi	sp,sp,80
 a4c:	8082                	ret

0000000000000a4e <printf>:

void
printf(const char *fmt, ...)
{
 a4e:	711d                	addi	sp,sp,-96
 a50:	ec06                	sd	ra,24(sp)
 a52:	e822                	sd	s0,16(sp)
 a54:	1000                	addi	s0,sp,32
 a56:	e40c                	sd	a1,8(s0)
 a58:	e810                	sd	a2,16(s0)
 a5a:	ec14                	sd	a3,24(s0)
 a5c:	f018                	sd	a4,32(s0)
 a5e:	f41c                	sd	a5,40(s0)
 a60:	03043823          	sd	a6,48(s0)
 a64:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a68:	00840613          	addi	a2,s0,8
 a6c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a70:	85aa                	mv	a1,a0
 a72:	4505                	li	a0,1
 a74:	00000097          	auipc	ra,0x0
 a78:	dce080e7          	jalr	-562(ra) # 842 <vprintf>
}
 a7c:	60e2                	ld	ra,24(sp)
 a7e:	6442                	ld	s0,16(sp)
 a80:	6125                	addi	sp,sp,96
 a82:	8082                	ret

0000000000000a84 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a84:	1141                	addi	sp,sp,-16
 a86:	e422                	sd	s0,8(sp)
 a88:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a8a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a8e:	00000797          	auipc	a5,0x0
 a92:	6227b783          	ld	a5,1570(a5) # 10b0 <freep>
 a96:	a02d                	j	ac0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a98:	4618                	lw	a4,8(a2)
 a9a:	9f2d                	addw	a4,a4,a1
 a9c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 aa0:	6398                	ld	a4,0(a5)
 aa2:	6310                	ld	a2,0(a4)
 aa4:	a83d                	j	ae2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 aa6:	ff852703          	lw	a4,-8(a0)
 aaa:	9f31                	addw	a4,a4,a2
 aac:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 aae:	ff053683          	ld	a3,-16(a0)
 ab2:	a091                	j	af6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ab4:	6398                	ld	a4,0(a5)
 ab6:	00e7e463          	bltu	a5,a4,abe <free+0x3a>
 aba:	00e6ea63          	bltu	a3,a4,ace <free+0x4a>
{
 abe:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ac0:	fed7fae3          	bgeu	a5,a3,ab4 <free+0x30>
 ac4:	6398                	ld	a4,0(a5)
 ac6:	00e6e463          	bltu	a3,a4,ace <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aca:	fee7eae3          	bltu	a5,a4,abe <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 ace:	ff852583          	lw	a1,-8(a0)
 ad2:	6390                	ld	a2,0(a5)
 ad4:	02059813          	slli	a6,a1,0x20
 ad8:	01c85713          	srli	a4,a6,0x1c
 adc:	9736                	add	a4,a4,a3
 ade:	fae60de3          	beq	a2,a4,a98 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 ae2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 ae6:	4790                	lw	a2,8(a5)
 ae8:	02061593          	slli	a1,a2,0x20
 aec:	01c5d713          	srli	a4,a1,0x1c
 af0:	973e                	add	a4,a4,a5
 af2:	fae68ae3          	beq	a3,a4,aa6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 af6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 af8:	00000717          	auipc	a4,0x0
 afc:	5af73c23          	sd	a5,1464(a4) # 10b0 <freep>
}
 b00:	6422                	ld	s0,8(sp)
 b02:	0141                	addi	sp,sp,16
 b04:	8082                	ret

0000000000000b06 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b06:	7139                	addi	sp,sp,-64
 b08:	fc06                	sd	ra,56(sp)
 b0a:	f822                	sd	s0,48(sp)
 b0c:	f426                	sd	s1,40(sp)
 b0e:	f04a                	sd	s2,32(sp)
 b10:	ec4e                	sd	s3,24(sp)
 b12:	e852                	sd	s4,16(sp)
 b14:	e456                	sd	s5,8(sp)
 b16:	e05a                	sd	s6,0(sp)
 b18:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b1a:	02051493          	slli	s1,a0,0x20
 b1e:	9081                	srli	s1,s1,0x20
 b20:	04bd                	addi	s1,s1,15
 b22:	8091                	srli	s1,s1,0x4
 b24:	0014899b          	addiw	s3,s1,1
 b28:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b2a:	00000517          	auipc	a0,0x0
 b2e:	58653503          	ld	a0,1414(a0) # 10b0 <freep>
 b32:	c515                	beqz	a0,b5e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b34:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b36:	4798                	lw	a4,8(a5)
 b38:	02977f63          	bgeu	a4,s1,b76 <malloc+0x70>
 b3c:	8a4e                	mv	s4,s3
 b3e:	0009871b          	sext.w	a4,s3
 b42:	6685                	lui	a3,0x1
 b44:	00d77363          	bgeu	a4,a3,b4a <malloc+0x44>
 b48:	6a05                	lui	s4,0x1
 b4a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b4e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b52:	00000917          	auipc	s2,0x0
 b56:	55e90913          	addi	s2,s2,1374 # 10b0 <freep>
  if(p == (char*)-1)
 b5a:	5afd                	li	s5,-1
 b5c:	a895                	j	bd0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 b5e:	00000797          	auipc	a5,0x0
 b62:	55a78793          	addi	a5,a5,1370 # 10b8 <base>
 b66:	00000717          	auipc	a4,0x0
 b6a:	54f73523          	sd	a5,1354(a4) # 10b0 <freep>
 b6e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b70:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b74:	b7e1                	j	b3c <malloc+0x36>
      if(p->s.size == nunits)
 b76:	02e48c63          	beq	s1,a4,bae <malloc+0xa8>
        p->s.size -= nunits;
 b7a:	4137073b          	subw	a4,a4,s3
 b7e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b80:	02071693          	slli	a3,a4,0x20
 b84:	01c6d713          	srli	a4,a3,0x1c
 b88:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b8a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b8e:	00000717          	auipc	a4,0x0
 b92:	52a73123          	sd	a0,1314(a4) # 10b0 <freep>
      return (void*)(p + 1);
 b96:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b9a:	70e2                	ld	ra,56(sp)
 b9c:	7442                	ld	s0,48(sp)
 b9e:	74a2                	ld	s1,40(sp)
 ba0:	7902                	ld	s2,32(sp)
 ba2:	69e2                	ld	s3,24(sp)
 ba4:	6a42                	ld	s4,16(sp)
 ba6:	6aa2                	ld	s5,8(sp)
 ba8:	6b02                	ld	s6,0(sp)
 baa:	6121                	addi	sp,sp,64
 bac:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 bae:	6398                	ld	a4,0(a5)
 bb0:	e118                	sd	a4,0(a0)
 bb2:	bff1                	j	b8e <malloc+0x88>
  hp->s.size = nu;
 bb4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 bb8:	0541                	addi	a0,a0,16
 bba:	00000097          	auipc	ra,0x0
 bbe:	eca080e7          	jalr	-310(ra) # a84 <free>
  return freep;
 bc2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 bc6:	d971                	beqz	a0,b9a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bc8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bca:	4798                	lw	a4,8(a5)
 bcc:	fa9775e3          	bgeu	a4,s1,b76 <malloc+0x70>
    if(p == freep)
 bd0:	00093703          	ld	a4,0(s2)
 bd4:	853e                	mv	a0,a5
 bd6:	fef719e3          	bne	a4,a5,bc8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 bda:	8552                	mv	a0,s4
 bdc:	00000097          	auipc	ra,0x0
 be0:	b60080e7          	jalr	-1184(ra) # 73c <sbrk>
  if(p == (char*)-1)
 be4:	fd5518e3          	bne	a0,s5,bb4 <malloc+0xae>
        return 0;
 be8:	4501                	li	a0,0
 bea:	bf45                	j	b9a <malloc+0x94>
