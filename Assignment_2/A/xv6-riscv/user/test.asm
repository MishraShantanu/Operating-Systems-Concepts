
user/_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[]){
   0:	7155                	addi	sp,sp,-208
   2:	e586                	sd	ra,200(sp)
   4:	e1a2                	sd	s0,192(sp)
   6:	fd26                	sd	s1,184(sp)
   8:	f94a                	sd	s2,176(sp)
   a:	f54e                	sd	s3,168(sp)
   c:	f152                	sd	s4,160(sp)
   e:	ed56                	sd	s5,152(sp)
  10:	e95a                	sd	s6,144(sp)
  12:	e55e                	sd	s7,136(sp)
  14:	e162                	sd	s8,128(sp)
  16:	fce6                	sd	s9,120(sp)
  18:	f8ea                	sd	s10,112(sp)
  1a:	f4ee                	sd	s11,104(sp)
  1c:	0980                	addi	s0,sp,208
    int startPidB=-1,endPidB=-1;
    int startPidC=-1,endPidC=-1;
    
    
    //check if user provides 4 values as an argument 
    if(argc==5){
  1e:	4795                	li	a5,5
  20:	20f51063          	bne	a0,a5,220 <main+0x220>
  24:	8b2e                	mv	s6,a1
  26:	4a05                	li	s4,1
  28:	4981                	li	s3,0
    int startPidC=-1,endPidC=-1;
  2a:	5d7d                	li	s10,-1
    int startPidB=-1,endPidB=-1;
  2c:	57fd                	li	a5,-1
  2e:	f6f43823          	sd	a5,-144(s0)
  32:	5c7d                	li	s8,-1
    int startPidA=-1,endPidA=-1;
  34:	f6f43c23          	sd	a5,-136(s0)
  38:	5afd                	li	s5,-1
        
        
    for(int f=0;f<45;f++){
  3a:	02c00d93          	li	s11,44
            exit(0);
        }else{
            //record the start and end pid for each group
            if(f==0 && startPidA==-1){
                startPidA = rc;
            }else if(f==14 && endPidA==-1){
  3e:	4cb9                	li	s9,14
                 endPidA = rc;
            }else if(f==15 && startPidB==-1){
                startPidB = rc;
            }else if(f==29 && endPidB==-1){
                 endPidB = rc;
            }else if(f==30 && startPidC==-1){
  40:	5bfd                	li	s7,-1
  42:	a89d                	j	b8 <main+0xb8>
                 jStop = atoi(argv[2]);
  44:	010b3503          	ld	a0,16(s6)
  48:	00000097          	auipc	ra,0x0
  4c:	368080e7          	jalr	872(ra) # 3b0 <atoi>
  50:	a039                	j	5e <main+0x5e>
                    jStop = atoi(argv[4]);  
  52:	020b3503          	ld	a0,32(s6)
  56:	00000097          	auipc	ra,0x0
  5a:	35a080e7          	jalr	858(ra) # 3b0 <atoi>
                for(int j=1; j<=jStop;j++){
  5e:	00a05763          	blez	a0,6c <main+0x6c>
  62:	2505                	addiw	a0,a0,1
  64:	87d6                	mv	a5,s5
  66:	2785                	addiw	a5,a5,1
  68:	fea79fe3          	bne	a5,a0,66 <main+0x66>
            for ( int i=1; i<=atoi(argv[1]);i++){
  6c:	2905                	addiw	s2,s2,1
  6e:	008b3503          	ld	a0,8(s6)
  72:	00000097          	auipc	ra,0x0
  76:	33e080e7          	jalr	830(ra) # 3b0 <atoi>
  7a:	03254263          	blt	a0,s2,9e <main+0x9e>
                 if(f<15){ 
  7e:	fc9a53e3          	bge	s4,s1,44 <main+0x44>
                 }else if(f>=15 && f < 30){
  82:	fd3a68e3          	bltu	s4,s3,52 <main+0x52>
                  jStop = atoi(argv[3]);  
  86:	018b3503          	ld	a0,24(s6)
  8a:	00000097          	auipc	ra,0x0
  8e:	326080e7          	jalr	806(ra) # 3b0 <atoi>
  92:	b7f1                	j	5e <main+0x5e>
            for ( int i=1; i<=atoi(argv[1]);i++){
  94:	4905                	li	s2,1
                 if(f<15){ 
  96:	4a39                	li	s4,14
                 }else if(f>=15 && f < 30){
  98:	39c5                	addiw	s3,s3,-15
                for(int j=1; j<=jStop;j++){
  9a:	4a85                	li	s5,1
  9c:	bfc9                	j	6e <main+0x6e>
            exit(0);
  9e:	4501                	li	a0,0
  a0:	00000097          	auipc	ra,0x0
  a4:	40a080e7          	jalr	1034(ra) # 4aa <exit>
            if(f==0 && startPidA==-1){
  a8:	197a8963          	beq	s5,s7,23a <main+0x23a>
    for(int f=0;f<45;f++){
  ac:	000a079b          	sext.w	a5,s4
  b0:	06fdca63          	blt	s11,a5,124 <main+0x124>
  b4:	2985                	addiw	s3,s3,1
  b6:	2a05                	addiw	s4,s4,1
  b8:	0009849b          	sext.w	s1,s3
        rc=fork();
  bc:	00000097          	auipc	ra,0x0
  c0:	3e6080e7          	jalr	998(ra) # 4a2 <fork>
  c4:	892a                	mv	s2,a0
        if(rc==0){
  c6:	d579                	beqz	a0,94 <main+0x94>
            if(f==0 && startPidA==-1){
  c8:	d0e5                	beqz	s1,a8 <main+0xa8>
            }else if(f==14 && endPidA==-1){
  ca:	01948f63          	beq	s1,s9,e8 <main+0xe8>
            }else if(f==15 && startPidB==-1){
  ce:	47bd                	li	a5,15
  d0:	02f48363          	beq	s1,a5,f6 <main+0xf6>
            }else if(f==29 && endPidB==-1){
  d4:	47f5                	li	a5,29
  d6:	02f48463          	beq	s1,a5,fe <main+0xfe>
            }else if(f==30 && startPidC==-1){
  da:	47f9                	li	a5,30
  dc:	02f49863          	bne	s1,a5,10c <main+0x10c>
  e0:	fd7d16e3          	bne	s10,s7,ac <main+0xac>
        rc=fork();
  e4:	8d2a                	mv	s10,a0
    for(int f=0;f<45;f++){
  e6:	b7f9                	j	b4 <main+0xb4>
            }else if(f==14 && endPidA==-1){
  e8:	f7843783          	ld	a5,-136(s0)
  ec:	fd7790e3          	bne	a5,s7,ac <main+0xac>
        rc=fork();
  f0:	f6a43c23          	sd	a0,-136(s0)
  f4:	b7c1                	j	b4 <main+0xb4>
            }else if(f==15 && startPidB==-1){
  f6:	fb7c1be3          	bne	s8,s7,ac <main+0xac>
        rc=fork();
  fa:	8c2a                	mv	s8,a0
  fc:	bf65                	j	b4 <main+0xb4>
            }else if(f==29 && endPidB==-1){
  fe:	f7043783          	ld	a5,-144(s0)
 102:	fb7795e3          	bne	a5,s7,ac <main+0xac>
        rc=fork();
 106:	f6a43823          	sd	a0,-144(s0)
 10a:	b76d                	j	b4 <main+0xb4>
                startPidC = rc;
            }else if(f==44 && endPidC==-1){
 10c:	fbb490e3          	bne	s1,s11,ac <main+0xac>
    }
    
   //once the fork for loop ends, loop 45 times to wait for all the 45 child 
        //using waitstat, also waitstat would return the pid, turnaround time and run time for each process

    for(int i=0;i<45;i++){
 110:	02d00493          	li	s1,45
    int AturnaroundTime=0, BturnaroundTime=0, CturnaroundTime=0, ArunningTime=0, BrunningTime=0, CrunningTime=0 ;
 114:	4d81                	li	s11,0
 116:	4b81                	li	s7,0
 118:	4a01                	li	s4,0
 11a:	f6043423          	sd	zero,-152(s0)
 11e:	4c81                	li	s9,0
 120:	4981                	li	s3,0
 122:	a01d                	j	148 <main+0x148>
 124:	597d                	li	s2,-1
 126:	b7ed                	j	110 <main+0x110>
           if(pid>=startPidA && pid<=endPidA){
              //  printf("A %d %d %d\n",pid,startPidA,endPidA);
                AturnaroundTime += turnaroundTime;
                ArunningTime += runningTime;
                
            }else if(pid>=startPidB && pid<=endPidB){
 128:	05854c63          	blt	a0,s8,180 <main+0x180>
 12c:	f7043783          	ld	a5,-144(s0)
 130:	04a7c863          	blt	a5,a0,180 <main+0x180>
              // printf("B %d %d %d\n",pid,startPidA,endPidA);
                BturnaroundTime += turnaroundTime;
 134:	f8842783          	lw	a5,-120(s0)
 138:	01978cbb          	addw	s9,a5,s9
                BrunningTime += runningTime;   
 13c:	f8c42783          	lw	a5,-116(s0)
 140:	01778bbb          	addw	s7,a5,s7
    for(int i=0;i<45;i++){
 144:	34fd                	addiw	s1,s1,-1
 146:	cca9                	beqz	s1,1a0 <main+0x1a0>
         int  turnaroundTime=0, runningTime=0;
 148:	f8042423          	sw	zero,-120(s0)
 14c:	f8042623          	sw	zero,-116(s0)
           pid = waitstat(0,&turnaroundTime,&runningTime);
 150:	f8c40613          	addi	a2,s0,-116
 154:	f8840593          	addi	a1,s0,-120
 158:	4501                	li	a0,0
 15a:	00000097          	auipc	ra,0x0
 15e:	3f0080e7          	jalr	1008(ra) # 54a <waitstat>
           if(pid>=startPidA && pid<=endPidA){
 162:	fd5543e3          	blt	a0,s5,128 <main+0x128>
 166:	f7843783          	ld	a5,-136(s0)
 16a:	faa7cfe3          	blt	a5,a0,128 <main+0x128>
                AturnaroundTime += turnaroundTime;
 16e:	f8842783          	lw	a5,-120(s0)
 172:	013789bb          	addw	s3,a5,s3
                ArunningTime += runningTime;
 176:	f8c42783          	lw	a5,-116(s0)
 17a:	01478a3b          	addw	s4,a5,s4
 17e:	b7d9                	j	144 <main+0x144>
            }else if(pid>=startPidC && pid<=endPidC){
 180:	fda542e3          	blt	a0,s10,144 <main+0x144>
 184:	fca940e3          	blt	s2,a0,144 <main+0x144>
              // printf("C %d %d %d\n",pid,startPidA,endPidA);

               CturnaroundTime += turnaroundTime;
 188:	f8842783          	lw	a5,-120(s0)
 18c:	f6843703          	ld	a4,-152(s0)
 190:	9fb9                	addw	a5,a5,a4
 192:	f6f43423          	sd	a5,-152(s0)
                CrunningTime += runningTime;
 196:	f8c42783          	lw	a5,-116(s0)
 19a:	01b78dbb          	addw	s11,a5,s11
 19e:	b75d                	j	144 <main+0x144>
        

            // printf("turnaround %d, runT %d", turnaroundTime, runningTime);
        
    }
    printf("Group 1 where K = %d & L = %d Turn Around Time: %d, Run Time: %d\nGroup 2 where K = %d & M = %d Turn Around Time: %d, Run Time: %d\nGroup 3 where K = %d & N = %d Turn Around Time: %d, Run Time: %d\n",atoi(argv[1]),atoi(argv[2]),AturnaroundTime,ArunningTime,atoi(argv[1]),atoi(argv[3]),BturnaroundTime,BrunningTime,atoi(argv[1]),atoi(argv[4]),CturnaroundTime,CrunningTime );
 1a0:	008b3503          	ld	a0,8(s6)
 1a4:	00000097          	auipc	ra,0x0
 1a8:	20c080e7          	jalr	524(ra) # 3b0 <atoi>
 1ac:	8d2a                	mv	s10,a0
 1ae:	010b3503          	ld	a0,16(s6)
 1b2:	00000097          	auipc	ra,0x0
 1b6:	1fe080e7          	jalr	510(ra) # 3b0 <atoi>
 1ba:	84aa                	mv	s1,a0
 1bc:	008b3503          	ld	a0,8(s6)
 1c0:	00000097          	auipc	ra,0x0
 1c4:	1f0080e7          	jalr	496(ra) # 3b0 <atoi>
 1c8:	892a                	mv	s2,a0
 1ca:	018b3503          	ld	a0,24(s6)
 1ce:	00000097          	auipc	ra,0x0
 1d2:	1e2080e7          	jalr	482(ra) # 3b0 <atoi>
 1d6:	8aaa                	mv	s5,a0
 1d8:	008b3503          	ld	a0,8(s6)
 1dc:	00000097          	auipc	ra,0x0
 1e0:	1d4080e7          	jalr	468(ra) # 3b0 <atoi>
 1e4:	8c2a                	mv	s8,a0
 1e6:	020b3503          	ld	a0,32(s6)
 1ea:	00000097          	auipc	ra,0x0
 1ee:	1c6080e7          	jalr	454(ra) # 3b0 <atoi>
 1f2:	f06e                	sd	s11,32(sp)
 1f4:	f6843783          	ld	a5,-152(s0)
 1f8:	ec3e                	sd	a5,24(sp)
 1fa:	e82a                	sd	a0,16(sp)
 1fc:	e462                	sd	s8,8(sp)
 1fe:	e05e                	sd	s7,0(sp)
 200:	88e6                	mv	a7,s9
 202:	8856                	mv	a6,s5
 204:	87ca                	mv	a5,s2
 206:	8752                	mv	a4,s4
 208:	86ce                	mv	a3,s3
 20a:	8626                	mv	a2,s1
 20c:	85ea                	mv	a1,s10
 20e:	00000517          	auipc	a0,0x0
 212:	7c250513          	addi	a0,a0,1986 # 9d0 <malloc+0xec>
 216:	00000097          	auipc	ra,0x0
 21a:	616080e7          	jalr	1558(ra) # 82c <printf>
 21e:	a809                	j	230 <main+0x230>
        
    }else {
        
         printf("Please pass four argument, example test 5000 5000 5000 5000\n");
 220:	00001517          	auipc	a0,0x1
 224:	87850513          	addi	a0,a0,-1928 # a98 <malloc+0x1b4>
 228:	00000097          	auipc	ra,0x0
 22c:	604080e7          	jalr	1540(ra) # 82c <printf>
    }

   //printf("A TT: %d, RT: %d ",AturnaroundTime,ArunningTime);
  // printf("%d\n", getpid());
  exit(0);
 230:	4501                	li	a0,0
 232:	00000097          	auipc	ra,0x0
 236:	278080e7          	jalr	632(ra) # 4aa <exit>
        rc=fork();
 23a:	8aaa                	mv	s5,a0
 23c:	bda5                	j	b4 <main+0xb4>

000000000000023e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 23e:	1141                	addi	sp,sp,-16
 240:	e422                	sd	s0,8(sp)
 242:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 244:	87aa                	mv	a5,a0
 246:	0585                	addi	a1,a1,1
 248:	0785                	addi	a5,a5,1
 24a:	fff5c703          	lbu	a4,-1(a1)
 24e:	fee78fa3          	sb	a4,-1(a5)
 252:	fb75                	bnez	a4,246 <strcpy+0x8>
    ;
  return os;
}
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret

000000000000025a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 260:	00054783          	lbu	a5,0(a0)
 264:	cb91                	beqz	a5,278 <strcmp+0x1e>
 266:	0005c703          	lbu	a4,0(a1)
 26a:	00f71763          	bne	a4,a5,278 <strcmp+0x1e>
    p++, q++;
 26e:	0505                	addi	a0,a0,1
 270:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 272:	00054783          	lbu	a5,0(a0)
 276:	fbe5                	bnez	a5,266 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 278:	0005c503          	lbu	a0,0(a1)
}
 27c:	40a7853b          	subw	a0,a5,a0
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret

0000000000000286 <strlen>:

uint
strlen(const char *s)
{
 286:	1141                	addi	sp,sp,-16
 288:	e422                	sd	s0,8(sp)
 28a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 28c:	00054783          	lbu	a5,0(a0)
 290:	cf91                	beqz	a5,2ac <strlen+0x26>
 292:	0505                	addi	a0,a0,1
 294:	87aa                	mv	a5,a0
 296:	4685                	li	a3,1
 298:	9e89                	subw	a3,a3,a0
 29a:	00f6853b          	addw	a0,a3,a5
 29e:	0785                	addi	a5,a5,1
 2a0:	fff7c703          	lbu	a4,-1(a5)
 2a4:	fb7d                	bnez	a4,29a <strlen+0x14>
    ;
  return n;
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
  for(n = 0; s[n]; n++)
 2ac:	4501                	li	a0,0
 2ae:	bfe5                	j	2a6 <strlen+0x20>

00000000000002b0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e422                	sd	s0,8(sp)
 2b4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2b6:	ca19                	beqz	a2,2cc <memset+0x1c>
 2b8:	87aa                	mv	a5,a0
 2ba:	1602                	slli	a2,a2,0x20
 2bc:	9201                	srli	a2,a2,0x20
 2be:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2c2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2c6:	0785                	addi	a5,a5,1
 2c8:	fee79de3          	bne	a5,a4,2c2 <memset+0x12>
  }
  return dst;
}
 2cc:	6422                	ld	s0,8(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret

00000000000002d2 <strchr>:

char*
strchr(const char *s, char c)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e422                	sd	s0,8(sp)
 2d6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2d8:	00054783          	lbu	a5,0(a0)
 2dc:	cb99                	beqz	a5,2f2 <strchr+0x20>
    if(*s == c)
 2de:	00f58763          	beq	a1,a5,2ec <strchr+0x1a>
  for(; *s; s++)
 2e2:	0505                	addi	a0,a0,1
 2e4:	00054783          	lbu	a5,0(a0)
 2e8:	fbfd                	bnez	a5,2de <strchr+0xc>
      return (char*)s;
  return 0;
 2ea:	4501                	li	a0,0
}
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret
  return 0;
 2f2:	4501                	li	a0,0
 2f4:	bfe5                	j	2ec <strchr+0x1a>

00000000000002f6 <gets>:

char*
gets(char *buf, int max)
{
 2f6:	711d                	addi	sp,sp,-96
 2f8:	ec86                	sd	ra,88(sp)
 2fa:	e8a2                	sd	s0,80(sp)
 2fc:	e4a6                	sd	s1,72(sp)
 2fe:	e0ca                	sd	s2,64(sp)
 300:	fc4e                	sd	s3,56(sp)
 302:	f852                	sd	s4,48(sp)
 304:	f456                	sd	s5,40(sp)
 306:	f05a                	sd	s6,32(sp)
 308:	ec5e                	sd	s7,24(sp)
 30a:	1080                	addi	s0,sp,96
 30c:	8baa                	mv	s7,a0
 30e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 310:	892a                	mv	s2,a0
 312:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 314:	4aa9                	li	s5,10
 316:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 318:	89a6                	mv	s3,s1
 31a:	2485                	addiw	s1,s1,1
 31c:	0344d863          	bge	s1,s4,34c <gets+0x56>
    cc = read(0, &c, 1);
 320:	4605                	li	a2,1
 322:	faf40593          	addi	a1,s0,-81
 326:	4501                	li	a0,0
 328:	00000097          	auipc	ra,0x0
 32c:	19a080e7          	jalr	410(ra) # 4c2 <read>
    if(cc < 1)
 330:	00a05e63          	blez	a0,34c <gets+0x56>
    buf[i++] = c;
 334:	faf44783          	lbu	a5,-81(s0)
 338:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 33c:	01578763          	beq	a5,s5,34a <gets+0x54>
 340:	0905                	addi	s2,s2,1
 342:	fd679be3          	bne	a5,s6,318 <gets+0x22>
  for(i=0; i+1 < max; ){
 346:	89a6                	mv	s3,s1
 348:	a011                	j	34c <gets+0x56>
 34a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 34c:	99de                	add	s3,s3,s7
 34e:	00098023          	sb	zero,0(s3)
  return buf;
}
 352:	855e                	mv	a0,s7
 354:	60e6                	ld	ra,88(sp)
 356:	6446                	ld	s0,80(sp)
 358:	64a6                	ld	s1,72(sp)
 35a:	6906                	ld	s2,64(sp)
 35c:	79e2                	ld	s3,56(sp)
 35e:	7a42                	ld	s4,48(sp)
 360:	7aa2                	ld	s5,40(sp)
 362:	7b02                	ld	s6,32(sp)
 364:	6be2                	ld	s7,24(sp)
 366:	6125                	addi	sp,sp,96
 368:	8082                	ret

000000000000036a <stat>:

int
stat(const char *n, struct stat *st)
{
 36a:	1101                	addi	sp,sp,-32
 36c:	ec06                	sd	ra,24(sp)
 36e:	e822                	sd	s0,16(sp)
 370:	e426                	sd	s1,8(sp)
 372:	e04a                	sd	s2,0(sp)
 374:	1000                	addi	s0,sp,32
 376:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 378:	4581                	li	a1,0
 37a:	00000097          	auipc	ra,0x0
 37e:	170080e7          	jalr	368(ra) # 4ea <open>
  if(fd < 0)
 382:	02054563          	bltz	a0,3ac <stat+0x42>
 386:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 388:	85ca                	mv	a1,s2
 38a:	00000097          	auipc	ra,0x0
 38e:	178080e7          	jalr	376(ra) # 502 <fstat>
 392:	892a                	mv	s2,a0
  close(fd);
 394:	8526                	mv	a0,s1
 396:	00000097          	auipc	ra,0x0
 39a:	13c080e7          	jalr	316(ra) # 4d2 <close>
  return r;
}
 39e:	854a                	mv	a0,s2
 3a0:	60e2                	ld	ra,24(sp)
 3a2:	6442                	ld	s0,16(sp)
 3a4:	64a2                	ld	s1,8(sp)
 3a6:	6902                	ld	s2,0(sp)
 3a8:	6105                	addi	sp,sp,32
 3aa:	8082                	ret
    return -1;
 3ac:	597d                	li	s2,-1
 3ae:	bfc5                	j	39e <stat+0x34>

00000000000003b0 <atoi>:

int
atoi(const char *s)
{
 3b0:	1141                	addi	sp,sp,-16
 3b2:	e422                	sd	s0,8(sp)
 3b4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3b6:	00054683          	lbu	a3,0(a0)
 3ba:	fd06879b          	addiw	a5,a3,-48
 3be:	0ff7f793          	zext.b	a5,a5
 3c2:	4625                	li	a2,9
 3c4:	02f66863          	bltu	a2,a5,3f4 <atoi+0x44>
 3c8:	872a                	mv	a4,a0
  n = 0;
 3ca:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3cc:	0705                	addi	a4,a4,1
 3ce:	0025179b          	slliw	a5,a0,0x2
 3d2:	9fa9                	addw	a5,a5,a0
 3d4:	0017979b          	slliw	a5,a5,0x1
 3d8:	9fb5                	addw	a5,a5,a3
 3da:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3de:	00074683          	lbu	a3,0(a4)
 3e2:	fd06879b          	addiw	a5,a3,-48
 3e6:	0ff7f793          	zext.b	a5,a5
 3ea:	fef671e3          	bgeu	a2,a5,3cc <atoi+0x1c>
  return n;
}
 3ee:	6422                	ld	s0,8(sp)
 3f0:	0141                	addi	sp,sp,16
 3f2:	8082                	ret
  n = 0;
 3f4:	4501                	li	a0,0
 3f6:	bfe5                	j	3ee <atoi+0x3e>

00000000000003f8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3f8:	1141                	addi	sp,sp,-16
 3fa:	e422                	sd	s0,8(sp)
 3fc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3fe:	02b57463          	bgeu	a0,a1,426 <memmove+0x2e>
    while(n-- > 0)
 402:	00c05f63          	blez	a2,420 <memmove+0x28>
 406:	1602                	slli	a2,a2,0x20
 408:	9201                	srli	a2,a2,0x20
 40a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 40e:	872a                	mv	a4,a0
      *dst++ = *src++;
 410:	0585                	addi	a1,a1,1
 412:	0705                	addi	a4,a4,1
 414:	fff5c683          	lbu	a3,-1(a1)
 418:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 41c:	fee79ae3          	bne	a5,a4,410 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 420:	6422                	ld	s0,8(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret
    dst += n;
 426:	00c50733          	add	a4,a0,a2
    src += n;
 42a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 42c:	fec05ae3          	blez	a2,420 <memmove+0x28>
 430:	fff6079b          	addiw	a5,a2,-1
 434:	1782                	slli	a5,a5,0x20
 436:	9381                	srli	a5,a5,0x20
 438:	fff7c793          	not	a5,a5
 43c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 43e:	15fd                	addi	a1,a1,-1
 440:	177d                	addi	a4,a4,-1
 442:	0005c683          	lbu	a3,0(a1)
 446:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 44a:	fee79ae3          	bne	a5,a4,43e <memmove+0x46>
 44e:	bfc9                	j	420 <memmove+0x28>

0000000000000450 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 450:	1141                	addi	sp,sp,-16
 452:	e422                	sd	s0,8(sp)
 454:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 456:	ca05                	beqz	a2,486 <memcmp+0x36>
 458:	fff6069b          	addiw	a3,a2,-1
 45c:	1682                	slli	a3,a3,0x20
 45e:	9281                	srli	a3,a3,0x20
 460:	0685                	addi	a3,a3,1
 462:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 464:	00054783          	lbu	a5,0(a0)
 468:	0005c703          	lbu	a4,0(a1)
 46c:	00e79863          	bne	a5,a4,47c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 470:	0505                	addi	a0,a0,1
    p2++;
 472:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 474:	fed518e3          	bne	a0,a3,464 <memcmp+0x14>
  }
  return 0;
 478:	4501                	li	a0,0
 47a:	a019                	j	480 <memcmp+0x30>
      return *p1 - *p2;
 47c:	40e7853b          	subw	a0,a5,a4
}
 480:	6422                	ld	s0,8(sp)
 482:	0141                	addi	sp,sp,16
 484:	8082                	ret
  return 0;
 486:	4501                	li	a0,0
 488:	bfe5                	j	480 <memcmp+0x30>

000000000000048a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 48a:	1141                	addi	sp,sp,-16
 48c:	e406                	sd	ra,8(sp)
 48e:	e022                	sd	s0,0(sp)
 490:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 492:	00000097          	auipc	ra,0x0
 496:	f66080e7          	jalr	-154(ra) # 3f8 <memmove>
}
 49a:	60a2                	ld	ra,8(sp)
 49c:	6402                	ld	s0,0(sp)
 49e:	0141                	addi	sp,sp,16
 4a0:	8082                	ret

00000000000004a2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4a2:	4885                	li	a7,1
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <exit>:
.global exit
exit:
 li a7, SYS_exit
 4aa:	4889                	li	a7,2
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4b2:	488d                	li	a7,3
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4ba:	4891                	li	a7,4
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <read>:
.global read
read:
 li a7, SYS_read
 4c2:	4895                	li	a7,5
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <write>:
.global write
write:
 li a7, SYS_write
 4ca:	48c1                	li	a7,16
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <close>:
.global close
close:
 li a7, SYS_close
 4d2:	48d5                	li	a7,21
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <kill>:
.global kill
kill:
 li a7, SYS_kill
 4da:	4899                	li	a7,6
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4e2:	489d                	li	a7,7
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <open>:
.global open
open:
 li a7, SYS_open
 4ea:	48bd                	li	a7,15
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4f2:	48c5                	li	a7,17
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4fa:	48c9                	li	a7,18
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 502:	48a1                	li	a7,8
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <link>:
.global link
link:
 li a7, SYS_link
 50a:	48cd                	li	a7,19
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 512:	48d1                	li	a7,20
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 51a:	48a5                	li	a7,9
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <dup>:
.global dup
dup:
 li a7, SYS_dup
 522:	48a9                	li	a7,10
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 52a:	48ad                	li	a7,11
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 532:	48b1                	li	a7,12
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 53a:	48b5                	li	a7,13
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 542:	48b9                	li	a7,14
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <waitstat>:
.global waitstat
waitstat:
 li a7, SYS_waitstat
 54a:	48d9                	li	a7,22
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 552:	1101                	addi	sp,sp,-32
 554:	ec06                	sd	ra,24(sp)
 556:	e822                	sd	s0,16(sp)
 558:	1000                	addi	s0,sp,32
 55a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 55e:	4605                	li	a2,1
 560:	fef40593          	addi	a1,s0,-17
 564:	00000097          	auipc	ra,0x0
 568:	f66080e7          	jalr	-154(ra) # 4ca <write>
}
 56c:	60e2                	ld	ra,24(sp)
 56e:	6442                	ld	s0,16(sp)
 570:	6105                	addi	sp,sp,32
 572:	8082                	ret

0000000000000574 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 574:	7139                	addi	sp,sp,-64
 576:	fc06                	sd	ra,56(sp)
 578:	f822                	sd	s0,48(sp)
 57a:	f426                	sd	s1,40(sp)
 57c:	f04a                	sd	s2,32(sp)
 57e:	ec4e                	sd	s3,24(sp)
 580:	0080                	addi	s0,sp,64
 582:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 584:	c299                	beqz	a3,58a <printint+0x16>
 586:	0805c963          	bltz	a1,618 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 58a:	2581                	sext.w	a1,a1
  neg = 0;
 58c:	4881                	li	a7,0
 58e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 592:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 594:	2601                	sext.w	a2,a2
 596:	00000517          	auipc	a0,0x0
 59a:	5a250513          	addi	a0,a0,1442 # b38 <digits>
 59e:	883a                	mv	a6,a4
 5a0:	2705                	addiw	a4,a4,1
 5a2:	02c5f7bb          	remuw	a5,a1,a2
 5a6:	1782                	slli	a5,a5,0x20
 5a8:	9381                	srli	a5,a5,0x20
 5aa:	97aa                	add	a5,a5,a0
 5ac:	0007c783          	lbu	a5,0(a5)
 5b0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5b4:	0005879b          	sext.w	a5,a1
 5b8:	02c5d5bb          	divuw	a1,a1,a2
 5bc:	0685                	addi	a3,a3,1
 5be:	fec7f0e3          	bgeu	a5,a2,59e <printint+0x2a>
  if(neg)
 5c2:	00088c63          	beqz	a7,5da <printint+0x66>
    buf[i++] = '-';
 5c6:	fd070793          	addi	a5,a4,-48
 5ca:	00878733          	add	a4,a5,s0
 5ce:	02d00793          	li	a5,45
 5d2:	fef70823          	sb	a5,-16(a4)
 5d6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5da:	02e05863          	blez	a4,60a <printint+0x96>
 5de:	fc040793          	addi	a5,s0,-64
 5e2:	00e78933          	add	s2,a5,a4
 5e6:	fff78993          	addi	s3,a5,-1
 5ea:	99ba                	add	s3,s3,a4
 5ec:	377d                	addiw	a4,a4,-1
 5ee:	1702                	slli	a4,a4,0x20
 5f0:	9301                	srli	a4,a4,0x20
 5f2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5f6:	fff94583          	lbu	a1,-1(s2)
 5fa:	8526                	mv	a0,s1
 5fc:	00000097          	auipc	ra,0x0
 600:	f56080e7          	jalr	-170(ra) # 552 <putc>
  while(--i >= 0)
 604:	197d                	addi	s2,s2,-1
 606:	ff3918e3          	bne	s2,s3,5f6 <printint+0x82>
}
 60a:	70e2                	ld	ra,56(sp)
 60c:	7442                	ld	s0,48(sp)
 60e:	74a2                	ld	s1,40(sp)
 610:	7902                	ld	s2,32(sp)
 612:	69e2                	ld	s3,24(sp)
 614:	6121                	addi	sp,sp,64
 616:	8082                	ret
    x = -xx;
 618:	40b005bb          	negw	a1,a1
    neg = 1;
 61c:	4885                	li	a7,1
    x = -xx;
 61e:	bf85                	j	58e <printint+0x1a>

0000000000000620 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 620:	7119                	addi	sp,sp,-128
 622:	fc86                	sd	ra,120(sp)
 624:	f8a2                	sd	s0,112(sp)
 626:	f4a6                	sd	s1,104(sp)
 628:	f0ca                	sd	s2,96(sp)
 62a:	ecce                	sd	s3,88(sp)
 62c:	e8d2                	sd	s4,80(sp)
 62e:	e4d6                	sd	s5,72(sp)
 630:	e0da                	sd	s6,64(sp)
 632:	fc5e                	sd	s7,56(sp)
 634:	f862                	sd	s8,48(sp)
 636:	f466                	sd	s9,40(sp)
 638:	f06a                	sd	s10,32(sp)
 63a:	ec6e                	sd	s11,24(sp)
 63c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 63e:	0005c903          	lbu	s2,0(a1)
 642:	18090f63          	beqz	s2,7e0 <vprintf+0x1c0>
 646:	8aaa                	mv	s5,a0
 648:	8b32                	mv	s6,a2
 64a:	00158493          	addi	s1,a1,1
  state = 0;
 64e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 650:	02500a13          	li	s4,37
 654:	4c55                	li	s8,21
 656:	00000c97          	auipc	s9,0x0
 65a:	48ac8c93          	addi	s9,s9,1162 # ae0 <malloc+0x1fc>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 65e:	02800d93          	li	s11,40
  putc(fd, 'x');
 662:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 664:	00000b97          	auipc	s7,0x0
 668:	4d4b8b93          	addi	s7,s7,1236 # b38 <digits>
 66c:	a839                	j	68a <vprintf+0x6a>
        putc(fd, c);
 66e:	85ca                	mv	a1,s2
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	ee0080e7          	jalr	-288(ra) # 552 <putc>
 67a:	a019                	j	680 <vprintf+0x60>
    } else if(state == '%'){
 67c:	01498d63          	beq	s3,s4,696 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 680:	0485                	addi	s1,s1,1
 682:	fff4c903          	lbu	s2,-1(s1)
 686:	14090d63          	beqz	s2,7e0 <vprintf+0x1c0>
    if(state == 0){
 68a:	fe0999e3          	bnez	s3,67c <vprintf+0x5c>
      if(c == '%'){
 68e:	ff4910e3          	bne	s2,s4,66e <vprintf+0x4e>
        state = '%';
 692:	89d2                	mv	s3,s4
 694:	b7f5                	j	680 <vprintf+0x60>
      if(c == 'd'){
 696:	11490c63          	beq	s2,s4,7ae <vprintf+0x18e>
 69a:	f9d9079b          	addiw	a5,s2,-99
 69e:	0ff7f793          	zext.b	a5,a5
 6a2:	10fc6e63          	bltu	s8,a5,7be <vprintf+0x19e>
 6a6:	f9d9079b          	addiw	a5,s2,-99
 6aa:	0ff7f713          	zext.b	a4,a5
 6ae:	10ec6863          	bltu	s8,a4,7be <vprintf+0x19e>
 6b2:	00271793          	slli	a5,a4,0x2
 6b6:	97e6                	add	a5,a5,s9
 6b8:	439c                	lw	a5,0(a5)
 6ba:	97e6                	add	a5,a5,s9
 6bc:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6be:	008b0913          	addi	s2,s6,8
 6c2:	4685                	li	a3,1
 6c4:	4629                	li	a2,10
 6c6:	000b2583          	lw	a1,0(s6)
 6ca:	8556                	mv	a0,s5
 6cc:	00000097          	auipc	ra,0x0
 6d0:	ea8080e7          	jalr	-344(ra) # 574 <printint>
 6d4:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	b765                	j	680 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6da:	008b0913          	addi	s2,s6,8
 6de:	4681                	li	a3,0
 6e0:	4629                	li	a2,10
 6e2:	000b2583          	lw	a1,0(s6)
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	e8c080e7          	jalr	-372(ra) # 574 <printint>
 6f0:	8b4a                	mv	s6,s2
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	b771                	j	680 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6f6:	008b0913          	addi	s2,s6,8
 6fa:	4681                	li	a3,0
 6fc:	866a                	mv	a2,s10
 6fe:	000b2583          	lw	a1,0(s6)
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	e70080e7          	jalr	-400(ra) # 574 <printint>
 70c:	8b4a                	mv	s6,s2
      state = 0;
 70e:	4981                	li	s3,0
 710:	bf85                	j	680 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 712:	008b0793          	addi	a5,s6,8
 716:	f8f43423          	sd	a5,-120(s0)
 71a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 71e:	03000593          	li	a1,48
 722:	8556                	mv	a0,s5
 724:	00000097          	auipc	ra,0x0
 728:	e2e080e7          	jalr	-466(ra) # 552 <putc>
  putc(fd, 'x');
 72c:	07800593          	li	a1,120
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	e20080e7          	jalr	-480(ra) # 552 <putc>
 73a:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 73c:	03c9d793          	srli	a5,s3,0x3c
 740:	97de                	add	a5,a5,s7
 742:	0007c583          	lbu	a1,0(a5)
 746:	8556                	mv	a0,s5
 748:	00000097          	auipc	ra,0x0
 74c:	e0a080e7          	jalr	-502(ra) # 552 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 750:	0992                	slli	s3,s3,0x4
 752:	397d                	addiw	s2,s2,-1
 754:	fe0914e3          	bnez	s2,73c <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 758:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 75c:	4981                	li	s3,0
 75e:	b70d                	j	680 <vprintf+0x60>
        s = va_arg(ap, char*);
 760:	008b0913          	addi	s2,s6,8
 764:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 768:	02098163          	beqz	s3,78a <vprintf+0x16a>
        while(*s != 0){
 76c:	0009c583          	lbu	a1,0(s3)
 770:	c5ad                	beqz	a1,7da <vprintf+0x1ba>
          putc(fd, *s);
 772:	8556                	mv	a0,s5
 774:	00000097          	auipc	ra,0x0
 778:	dde080e7          	jalr	-546(ra) # 552 <putc>
          s++;
 77c:	0985                	addi	s3,s3,1
        while(*s != 0){
 77e:	0009c583          	lbu	a1,0(s3)
 782:	f9e5                	bnez	a1,772 <vprintf+0x152>
        s = va_arg(ap, char*);
 784:	8b4a                	mv	s6,s2
      state = 0;
 786:	4981                	li	s3,0
 788:	bde5                	j	680 <vprintf+0x60>
          s = "(null)";
 78a:	00000997          	auipc	s3,0x0
 78e:	34e98993          	addi	s3,s3,846 # ad8 <malloc+0x1f4>
        while(*s != 0){
 792:	85ee                	mv	a1,s11
 794:	bff9                	j	772 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 796:	008b0913          	addi	s2,s6,8
 79a:	000b4583          	lbu	a1,0(s6)
 79e:	8556                	mv	a0,s5
 7a0:	00000097          	auipc	ra,0x0
 7a4:	db2080e7          	jalr	-590(ra) # 552 <putc>
 7a8:	8b4a                	mv	s6,s2
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	bdd1                	j	680 <vprintf+0x60>
        putc(fd, c);
 7ae:	85d2                	mv	a1,s4
 7b0:	8556                	mv	a0,s5
 7b2:	00000097          	auipc	ra,0x0
 7b6:	da0080e7          	jalr	-608(ra) # 552 <putc>
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	b5d1                	j	680 <vprintf+0x60>
        putc(fd, '%');
 7be:	85d2                	mv	a1,s4
 7c0:	8556                	mv	a0,s5
 7c2:	00000097          	auipc	ra,0x0
 7c6:	d90080e7          	jalr	-624(ra) # 552 <putc>
        putc(fd, c);
 7ca:	85ca                	mv	a1,s2
 7cc:	8556                	mv	a0,s5
 7ce:	00000097          	auipc	ra,0x0
 7d2:	d84080e7          	jalr	-636(ra) # 552 <putc>
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	b565                	j	680 <vprintf+0x60>
        s = va_arg(ap, char*);
 7da:	8b4a                	mv	s6,s2
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	b54d                	j	680 <vprintf+0x60>
    }
  }
}
 7e0:	70e6                	ld	ra,120(sp)
 7e2:	7446                	ld	s0,112(sp)
 7e4:	74a6                	ld	s1,104(sp)
 7e6:	7906                	ld	s2,96(sp)
 7e8:	69e6                	ld	s3,88(sp)
 7ea:	6a46                	ld	s4,80(sp)
 7ec:	6aa6                	ld	s5,72(sp)
 7ee:	6b06                	ld	s6,64(sp)
 7f0:	7be2                	ld	s7,56(sp)
 7f2:	7c42                	ld	s8,48(sp)
 7f4:	7ca2                	ld	s9,40(sp)
 7f6:	7d02                	ld	s10,32(sp)
 7f8:	6de2                	ld	s11,24(sp)
 7fa:	6109                	addi	sp,sp,128
 7fc:	8082                	ret

00000000000007fe <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7fe:	715d                	addi	sp,sp,-80
 800:	ec06                	sd	ra,24(sp)
 802:	e822                	sd	s0,16(sp)
 804:	1000                	addi	s0,sp,32
 806:	e010                	sd	a2,0(s0)
 808:	e414                	sd	a3,8(s0)
 80a:	e818                	sd	a4,16(s0)
 80c:	ec1c                	sd	a5,24(s0)
 80e:	03043023          	sd	a6,32(s0)
 812:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 816:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 81a:	8622                	mv	a2,s0
 81c:	00000097          	auipc	ra,0x0
 820:	e04080e7          	jalr	-508(ra) # 620 <vprintf>
}
 824:	60e2                	ld	ra,24(sp)
 826:	6442                	ld	s0,16(sp)
 828:	6161                	addi	sp,sp,80
 82a:	8082                	ret

000000000000082c <printf>:

void
printf(const char *fmt, ...)
{
 82c:	711d                	addi	sp,sp,-96
 82e:	ec06                	sd	ra,24(sp)
 830:	e822                	sd	s0,16(sp)
 832:	1000                	addi	s0,sp,32
 834:	e40c                	sd	a1,8(s0)
 836:	e810                	sd	a2,16(s0)
 838:	ec14                	sd	a3,24(s0)
 83a:	f018                	sd	a4,32(s0)
 83c:	f41c                	sd	a5,40(s0)
 83e:	03043823          	sd	a6,48(s0)
 842:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 846:	00840613          	addi	a2,s0,8
 84a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 84e:	85aa                	mv	a1,a0
 850:	4505                	li	a0,1
 852:	00000097          	auipc	ra,0x0
 856:	dce080e7          	jalr	-562(ra) # 620 <vprintf>
}
 85a:	60e2                	ld	ra,24(sp)
 85c:	6442                	ld	s0,16(sp)
 85e:	6125                	addi	sp,sp,96
 860:	8082                	ret

0000000000000862 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 862:	1141                	addi	sp,sp,-16
 864:	e422                	sd	s0,8(sp)
 866:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 868:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86c:	00000797          	auipc	a5,0x0
 870:	2e47b783          	ld	a5,740(a5) # b50 <freep>
 874:	a02d                	j	89e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 876:	4618                	lw	a4,8(a2)
 878:	9f2d                	addw	a4,a4,a1
 87a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 87e:	6398                	ld	a4,0(a5)
 880:	6310                	ld	a2,0(a4)
 882:	a83d                	j	8c0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 884:	ff852703          	lw	a4,-8(a0)
 888:	9f31                	addw	a4,a4,a2
 88a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 88c:	ff053683          	ld	a3,-16(a0)
 890:	a091                	j	8d4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 892:	6398                	ld	a4,0(a5)
 894:	00e7e463          	bltu	a5,a4,89c <free+0x3a>
 898:	00e6ea63          	bltu	a3,a4,8ac <free+0x4a>
{
 89c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89e:	fed7fae3          	bgeu	a5,a3,892 <free+0x30>
 8a2:	6398                	ld	a4,0(a5)
 8a4:	00e6e463          	bltu	a3,a4,8ac <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a8:	fee7eae3          	bltu	a5,a4,89c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8ac:	ff852583          	lw	a1,-8(a0)
 8b0:	6390                	ld	a2,0(a5)
 8b2:	02059813          	slli	a6,a1,0x20
 8b6:	01c85713          	srli	a4,a6,0x1c
 8ba:	9736                	add	a4,a4,a3
 8bc:	fae60de3          	beq	a2,a4,876 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8c0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8c4:	4790                	lw	a2,8(a5)
 8c6:	02061593          	slli	a1,a2,0x20
 8ca:	01c5d713          	srli	a4,a1,0x1c
 8ce:	973e                	add	a4,a4,a5
 8d0:	fae68ae3          	beq	a3,a4,884 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8d4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8d6:	00000717          	auipc	a4,0x0
 8da:	26f73d23          	sd	a5,634(a4) # b50 <freep>
}
 8de:	6422                	ld	s0,8(sp)
 8e0:	0141                	addi	sp,sp,16
 8e2:	8082                	ret

00000000000008e4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e4:	7139                	addi	sp,sp,-64
 8e6:	fc06                	sd	ra,56(sp)
 8e8:	f822                	sd	s0,48(sp)
 8ea:	f426                	sd	s1,40(sp)
 8ec:	f04a                	sd	s2,32(sp)
 8ee:	ec4e                	sd	s3,24(sp)
 8f0:	e852                	sd	s4,16(sp)
 8f2:	e456                	sd	s5,8(sp)
 8f4:	e05a                	sd	s6,0(sp)
 8f6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f8:	02051493          	slli	s1,a0,0x20
 8fc:	9081                	srli	s1,s1,0x20
 8fe:	04bd                	addi	s1,s1,15
 900:	8091                	srli	s1,s1,0x4
 902:	0014899b          	addiw	s3,s1,1
 906:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 908:	00000517          	auipc	a0,0x0
 90c:	24853503          	ld	a0,584(a0) # b50 <freep>
 910:	c515                	beqz	a0,93c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 912:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 914:	4798                	lw	a4,8(a5)
 916:	02977f63          	bgeu	a4,s1,954 <malloc+0x70>
 91a:	8a4e                	mv	s4,s3
 91c:	0009871b          	sext.w	a4,s3
 920:	6685                	lui	a3,0x1
 922:	00d77363          	bgeu	a4,a3,928 <malloc+0x44>
 926:	6a05                	lui	s4,0x1
 928:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 92c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 930:	00000917          	auipc	s2,0x0
 934:	22090913          	addi	s2,s2,544 # b50 <freep>
  if(p == (char*)-1)
 938:	5afd                	li	s5,-1
 93a:	a895                	j	9ae <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 93c:	00000797          	auipc	a5,0x0
 940:	21c78793          	addi	a5,a5,540 # b58 <base>
 944:	00000717          	auipc	a4,0x0
 948:	20f73623          	sd	a5,524(a4) # b50 <freep>
 94c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 94e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 952:	b7e1                	j	91a <malloc+0x36>
      if(p->s.size == nunits)
 954:	02e48c63          	beq	s1,a4,98c <malloc+0xa8>
        p->s.size -= nunits;
 958:	4137073b          	subw	a4,a4,s3
 95c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 95e:	02071693          	slli	a3,a4,0x20
 962:	01c6d713          	srli	a4,a3,0x1c
 966:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 968:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 96c:	00000717          	auipc	a4,0x0
 970:	1ea73223          	sd	a0,484(a4) # b50 <freep>
      return (void*)(p + 1);
 974:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 978:	70e2                	ld	ra,56(sp)
 97a:	7442                	ld	s0,48(sp)
 97c:	74a2                	ld	s1,40(sp)
 97e:	7902                	ld	s2,32(sp)
 980:	69e2                	ld	s3,24(sp)
 982:	6a42                	ld	s4,16(sp)
 984:	6aa2                	ld	s5,8(sp)
 986:	6b02                	ld	s6,0(sp)
 988:	6121                	addi	sp,sp,64
 98a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 98c:	6398                	ld	a4,0(a5)
 98e:	e118                	sd	a4,0(a0)
 990:	bff1                	j	96c <malloc+0x88>
  hp->s.size = nu;
 992:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 996:	0541                	addi	a0,a0,16
 998:	00000097          	auipc	ra,0x0
 99c:	eca080e7          	jalr	-310(ra) # 862 <free>
  return freep;
 9a0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9a4:	d971                	beqz	a0,978 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9a8:	4798                	lw	a4,8(a5)
 9aa:	fa9775e3          	bgeu	a4,s1,954 <malloc+0x70>
    if(p == freep)
 9ae:	00093703          	ld	a4,0(s2)
 9b2:	853e                	mv	a0,a5
 9b4:	fef719e3          	bne	a4,a5,9a6 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9b8:	8552                	mv	a0,s4
 9ba:	00000097          	auipc	ra,0x0
 9be:	b78080e7          	jalr	-1160(ra) # 532 <sbrk>
  if(p == (char*)-1)
 9c2:	fd5518e3          	bne	a0,s5,992 <malloc+0xae>
        return 0;
 9c6:	4501                	li	a0,0
 9c8:	bf45                	j	978 <malloc+0x94>
