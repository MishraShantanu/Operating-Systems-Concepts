
user/_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[]){
   0:	7175                	addi	sp,sp,-144
   2:	e506                	sd	ra,136(sp)
   4:	e122                	sd	s0,128(sp)
   6:	fca6                	sd	s1,120(sp)
   8:	f8ca                	sd	s2,112(sp)
   a:	f4ce                	sd	s3,104(sp)
   c:	f0d2                	sd	s4,96(sp)
   e:	ecd6                	sd	s5,88(sp)
  10:	e8da                	sd	s6,80(sp)
  12:	e4de                	sd	s7,72(sp)
  14:	e0e2                	sd	s8,64(sp)
  16:	fc66                	sd	s9,56(sp)
  18:	f86a                	sd	s10,48(sp)
  1a:	f46e                	sd	s11,40(sp)
  1c:	0900                	addi	s0,sp,144
  1e:	8b2e                	mv	s6,a1
  20:	4a05                	li	s4,1
  22:	4981                	li	s3,0
    int rc;
    int AturnaroundTime=0, BturnaroundTime=0, CturnaroundTime=0, ArunningTime=0, BrunningTime=0, CrunningTime=0 ;
    
    int startPidA=-1,endPidA=-1;
    int startPidB=-1,endPidB=-1;
    int startPidC=-1,endPidC=-1;
  24:	5d7d                	li	s10,-1
    int startPidB=-1,endPidB=-1;
  26:	57fd                	li	a5,-1
  28:	f6f43823          	sd	a5,-144(s0)
  2c:	5c7d                	li	s8,-1
    int startPidA=-1,endPidA=-1;
  2e:	f6f43c23          	sd	a5,-136(s0)
  32:	5afd                	li	s5,-1

    for(int f=0;f<45;f++){
  34:	02c00d93          	li	s11,44
            exit(0);
        }else{
            
            if(f==0 && startPidA==-1){
                startPidA = rc;
            }else if(f==14 && endPidA==-1){
  38:	4cb9                	li	s9,14
                 endPidA = rc;
            }else if(f==15 && startPidB==-1){
                startPidB = rc;
            }else if(f==29 && endPidB==-1){
                 endPidB = rc;
            }else if(f==30 && startPidC==-1){
  3a:	5bfd                	li	s7,-1
  3c:	a89d                	j	b2 <main+0xb2>
                 jStop = atoi(argv[2]);
  3e:	010b3503          	ld	a0,16(s6)
  42:	00000097          	auipc	ra,0x0
  46:	2ec080e7          	jalr	748(ra) # 32e <atoi>
  4a:	a039                	j	58 <main+0x58>
                    jStop = atoi(argv[4]);  
  4c:	020b3503          	ld	a0,32(s6)
  50:	00000097          	auipc	ra,0x0
  54:	2de080e7          	jalr	734(ra) # 32e <atoi>
                for(int j=1; j<=jStop;j++){
  58:	00a05763          	blez	a0,66 <main+0x66>
  5c:	2505                	addiw	a0,a0,1
  5e:	87d6                	mv	a5,s5
  60:	2785                	addiw	a5,a5,1
  62:	fea79fe3          	bne	a5,a0,60 <main+0x60>
            for ( int i=1; i<=atoi(argv[1]);i++){
  66:	2905                	addiw	s2,s2,1
  68:	008b3503          	ld	a0,8(s6)
  6c:	00000097          	auipc	ra,0x0
  70:	2c2080e7          	jalr	706(ra) # 32e <atoi>
  74:	03254263          	blt	a0,s2,98 <main+0x98>
                 if(f<15){
  78:	fc9a53e3          	bge	s4,s1,3e <main+0x3e>
                 }else if(f>=15 && f < 30){
  7c:	fd3a68e3          	bltu	s4,s3,4c <main+0x4c>
                  jStop = atoi(argv[3]);  
  80:	018b3503          	ld	a0,24(s6)
  84:	00000097          	auipc	ra,0x0
  88:	2aa080e7          	jalr	682(ra) # 32e <atoi>
  8c:	b7f1                	j	58 <main+0x58>
            for ( int i=1; i<=atoi(argv[1]);i++){
  8e:	4905                	li	s2,1
                 if(f<15){
  90:	4a39                	li	s4,14
                 }else if(f>=15 && f < 30){
  92:	39c5                	addiw	s3,s3,-15
                for(int j=1; j<=jStop;j++){
  94:	4a85                	li	s5,1
  96:	bfc9                	j	68 <main+0x68>
            exit(0);
  98:	4501                	li	a0,0
  9a:	00000097          	auipc	ra,0x0
  9e:	38e080e7          	jalr	910(ra) # 428 <exit>
            if(f==0 && startPidA==-1){
  a2:	117a8b63          	beq	s5,s7,1b8 <main+0x1b8>
    for(int f=0;f<45;f++){
  a6:	000a079b          	sext.w	a5,s4
  aa:	06fdc963          	blt	s11,a5,11c <main+0x11c>
  ae:	2985                	addiw	s3,s3,1
  b0:	2a05                	addiw	s4,s4,1
  b2:	0009849b          	sext.w	s1,s3
        rc=fork();
  b6:	00000097          	auipc	ra,0x0
  ba:	36a080e7          	jalr	874(ra) # 420 <fork>
  be:	892a                	mv	s2,a0
        if(rc==0){
  c0:	d579                	beqz	a0,8e <main+0x8e>
            if(f==0 && startPidA==-1){
  c2:	d0e5                	beqz	s1,a2 <main+0xa2>
            }else if(f==14 && endPidA==-1){
  c4:	01948f63          	beq	s1,s9,e2 <main+0xe2>
            }else if(f==15 && startPidB==-1){
  c8:	47bd                	li	a5,15
  ca:	02f48363          	beq	s1,a5,f0 <main+0xf0>
            }else if(f==29 && endPidB==-1){
  ce:	47f5                	li	a5,29
  d0:	02f48463          	beq	s1,a5,f8 <main+0xf8>
            }else if(f==30 && startPidC==-1){
  d4:	47f9                	li	a5,30
  d6:	02f49863          	bne	s1,a5,106 <main+0x106>
  da:	fd7d16e3          	bne	s10,s7,a6 <main+0xa6>
        rc=fork();
  de:	8d2a                	mv	s10,a0
    for(int f=0;f<45;f++){
  e0:	b7f9                	j	ae <main+0xae>
            }else if(f==14 && endPidA==-1){
  e2:	f7843783          	ld	a5,-136(s0)
  e6:	fd7790e3          	bne	a5,s7,a6 <main+0xa6>
        rc=fork();
  ea:	f6a43c23          	sd	a0,-136(s0)
  ee:	b7c1                	j	ae <main+0xae>
            }else if(f==15 && startPidB==-1){
  f0:	fb7c1be3          	bne	s8,s7,a6 <main+0xa6>
        rc=fork();
  f4:	8c2a                	mv	s8,a0
  f6:	bf65                	j	ae <main+0xae>
            }else if(f==29 && endPidB==-1){
  f8:	f7043783          	ld	a5,-144(s0)
  fc:	fb7795e3          	bne	a5,s7,a6 <main+0xa6>
        rc=fork();
 100:	f6a43823          	sd	a0,-144(s0)
 104:	b76d                	j	ae <main+0xae>
                startPidC = rc;
            }else if(f==44 && endPidC==-1){
 106:	fbb490e3          	bne	s1,s11,a6 <main+0xa6>
        }
    }
    
    // printf("startpid: %d \n",startPid);

    for(int i=0;i<45;i++){
 10a:	02d00493          	li	s1,45
    int AturnaroundTime=0, BturnaroundTime=0, CturnaroundTime=0, ArunningTime=0, BrunningTime=0, CrunningTime=0 ;
 10e:	4c81                	li	s9,0
 110:	4b81                	li	s7,0
 112:	4a01                	li	s4,0
 114:	4d81                	li	s11,0
 116:	4b01                	li	s6,0
 118:	4981                	li	s3,0
 11a:	a01d                	j	140 <main+0x140>
 11c:	597d                	li	s2,-1
 11e:	b7f5                	j	10a <main+0x10a>
           if(pid>=startPidA && pid<=endPidA){
              //  printf("A %d %d %d\n",pid,startPidA,endPidA);
                AturnaroundTime += turnaroundTime;
                ArunningTime += runningTime;
                
            }else if(pid>=startPidB && pid<=endPidB){
 120:	05854c63          	blt	a0,s8,178 <main+0x178>
 124:	f7043783          	ld	a5,-144(s0)
 128:	04a7c863          	blt	a5,a0,178 <main+0x178>
              // printf("B %d %d %d\n",pid,startPidA,endPidA);
                BturnaroundTime += turnaroundTime;
 12c:	f8842783          	lw	a5,-120(s0)
 130:	01678b3b          	addw	s6,a5,s6
                BrunningTime += runningTime;   
 134:	f8c42783          	lw	a5,-116(s0)
 138:	01778bbb          	addw	s7,a5,s7
    for(int i=0;i<45;i++){
 13c:	34fd                	addiw	s1,s1,-1
 13e:	c8b1                	beqz	s1,192 <main+0x192>
         int  turnaroundTime=0, runningTime=0;
 140:	f8042423          	sw	zero,-120(s0)
 144:	f8042623          	sw	zero,-116(s0)
           pid = waitstat(0,&turnaroundTime,&runningTime);
 148:	f8c40613          	addi	a2,s0,-116
 14c:	f8840593          	addi	a1,s0,-120
 150:	4501                	li	a0,0
 152:	00000097          	auipc	ra,0x0
 156:	376080e7          	jalr	886(ra) # 4c8 <waitstat>
           if(pid>=startPidA && pid<=endPidA){
 15a:	fd5543e3          	blt	a0,s5,120 <main+0x120>
 15e:	f7843783          	ld	a5,-136(s0)
 162:	faa7cfe3          	blt	a5,a0,120 <main+0x120>
                AturnaroundTime += turnaroundTime;
 166:	f8842783          	lw	a5,-120(s0)
 16a:	013789bb          	addw	s3,a5,s3
                ArunningTime += runningTime;
 16e:	f8c42783          	lw	a5,-116(s0)
 172:	01478a3b          	addw	s4,a5,s4
 176:	b7d9                	j	13c <main+0x13c>
            }else if(pid>=startPidC && pid<=endPidC){
 178:	fda542e3          	blt	a0,s10,13c <main+0x13c>
 17c:	fca940e3          	blt	s2,a0,13c <main+0x13c>
              // printf("C %d %d %d\n",pid,startPidA,endPidA);

               CturnaroundTime += turnaroundTime;
 180:	f8842783          	lw	a5,-120(s0)
 184:	01b78dbb          	addw	s11,a5,s11
                CrunningTime += runningTime;
 188:	f8c42783          	lw	a5,-116(s0)
 18c:	01978cbb          	addw	s9,a5,s9
 190:	b775                	j	13c <main+0x13c>
        

            // printf("turnaround %d, runT %d", turnaroundTime, runningTime);
        
    }
    printf("A TT: %d, RT: %d | B TT: %d, RT: %d | C TT: %d, RT: %d\n",AturnaroundTime,ArunningTime,BturnaroundTime,BrunningTime,CturnaroundTime,CrunningTime );
 192:	8866                	mv	a6,s9
 194:	87ee                	mv	a5,s11
 196:	875e                	mv	a4,s7
 198:	86da                	mv	a3,s6
 19a:	8652                	mv	a2,s4
 19c:	85ce                	mv	a1,s3
 19e:	00000517          	auipc	a0,0x0
 1a2:	7aa50513          	addi	a0,a0,1962 # 948 <malloc+0xe6>
 1a6:	00000097          	auipc	ra,0x0
 1aa:	604080e7          	jalr	1540(ra) # 7aa <printf>
   //printf("A TT: %d, RT: %d ",AturnaroundTime,ArunningTime);
  // printf("%d\n", getpid());
  exit(0);
 1ae:	4501                	li	a0,0
 1b0:	00000097          	auipc	ra,0x0
 1b4:	278080e7          	jalr	632(ra) # 428 <exit>
        rc=fork();
 1b8:	8aaa                	mv	s5,a0
 1ba:	bdd5                	j	ae <main+0xae>

00000000000001bc <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e422                	sd	s0,8(sp)
 1c0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1c2:	87aa                	mv	a5,a0
 1c4:	0585                	addi	a1,a1,1
 1c6:	0785                	addi	a5,a5,1
 1c8:	fff5c703          	lbu	a4,-1(a1)
 1cc:	fee78fa3          	sb	a4,-1(a5)
 1d0:	fb75                	bnez	a4,1c4 <strcpy+0x8>
    ;
  return os;
}
 1d2:	6422                	ld	s0,8(sp)
 1d4:	0141                	addi	sp,sp,16
 1d6:	8082                	ret

00000000000001d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e422                	sd	s0,8(sp)
 1dc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1de:	00054783          	lbu	a5,0(a0)
 1e2:	cb91                	beqz	a5,1f6 <strcmp+0x1e>
 1e4:	0005c703          	lbu	a4,0(a1)
 1e8:	00f71763          	bne	a4,a5,1f6 <strcmp+0x1e>
    p++, q++;
 1ec:	0505                	addi	a0,a0,1
 1ee:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1f0:	00054783          	lbu	a5,0(a0)
 1f4:	fbe5                	bnez	a5,1e4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1f6:	0005c503          	lbu	a0,0(a1)
}
 1fa:	40a7853b          	subw	a0,a5,a0
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret

0000000000000204 <strlen>:

uint
strlen(const char *s)
{
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	cf91                	beqz	a5,22a <strlen+0x26>
 210:	0505                	addi	a0,a0,1
 212:	87aa                	mv	a5,a0
 214:	4685                	li	a3,1
 216:	9e89                	subw	a3,a3,a0
 218:	00f6853b          	addw	a0,a3,a5
 21c:	0785                	addi	a5,a5,1
 21e:	fff7c703          	lbu	a4,-1(a5)
 222:	fb7d                	bnez	a4,218 <strlen+0x14>
    ;
  return n;
}
 224:	6422                	ld	s0,8(sp)
 226:	0141                	addi	sp,sp,16
 228:	8082                	ret
  for(n = 0; s[n]; n++)
 22a:	4501                	li	a0,0
 22c:	bfe5                	j	224 <strlen+0x20>

000000000000022e <memset>:

void*
memset(void *dst, int c, uint n)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 234:	ca19                	beqz	a2,24a <memset+0x1c>
 236:	87aa                	mv	a5,a0
 238:	1602                	slli	a2,a2,0x20
 23a:	9201                	srli	a2,a2,0x20
 23c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 240:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 244:	0785                	addi	a5,a5,1
 246:	fee79de3          	bne	a5,a4,240 <memset+0x12>
  }
  return dst;
}
 24a:	6422                	ld	s0,8(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret

0000000000000250 <strchr>:

char*
strchr(const char *s, char c)
{
 250:	1141                	addi	sp,sp,-16
 252:	e422                	sd	s0,8(sp)
 254:	0800                	addi	s0,sp,16
  for(; *s; s++)
 256:	00054783          	lbu	a5,0(a0)
 25a:	cb99                	beqz	a5,270 <strchr+0x20>
    if(*s == c)
 25c:	00f58763          	beq	a1,a5,26a <strchr+0x1a>
  for(; *s; s++)
 260:	0505                	addi	a0,a0,1
 262:	00054783          	lbu	a5,0(a0)
 266:	fbfd                	bnez	a5,25c <strchr+0xc>
      return (char*)s;
  return 0;
 268:	4501                	li	a0,0
}
 26a:	6422                	ld	s0,8(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret
  return 0;
 270:	4501                	li	a0,0
 272:	bfe5                	j	26a <strchr+0x1a>

0000000000000274 <gets>:

char*
gets(char *buf, int max)
{
 274:	711d                	addi	sp,sp,-96
 276:	ec86                	sd	ra,88(sp)
 278:	e8a2                	sd	s0,80(sp)
 27a:	e4a6                	sd	s1,72(sp)
 27c:	e0ca                	sd	s2,64(sp)
 27e:	fc4e                	sd	s3,56(sp)
 280:	f852                	sd	s4,48(sp)
 282:	f456                	sd	s5,40(sp)
 284:	f05a                	sd	s6,32(sp)
 286:	ec5e                	sd	s7,24(sp)
 288:	1080                	addi	s0,sp,96
 28a:	8baa                	mv	s7,a0
 28c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 28e:	892a                	mv	s2,a0
 290:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 292:	4aa9                	li	s5,10
 294:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 296:	89a6                	mv	s3,s1
 298:	2485                	addiw	s1,s1,1
 29a:	0344d863          	bge	s1,s4,2ca <gets+0x56>
    cc = read(0, &c, 1);
 29e:	4605                	li	a2,1
 2a0:	faf40593          	addi	a1,s0,-81
 2a4:	4501                	li	a0,0
 2a6:	00000097          	auipc	ra,0x0
 2aa:	19a080e7          	jalr	410(ra) # 440 <read>
    if(cc < 1)
 2ae:	00a05e63          	blez	a0,2ca <gets+0x56>
    buf[i++] = c;
 2b2:	faf44783          	lbu	a5,-81(s0)
 2b6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ba:	01578763          	beq	a5,s5,2c8 <gets+0x54>
 2be:	0905                	addi	s2,s2,1
 2c0:	fd679be3          	bne	a5,s6,296 <gets+0x22>
  for(i=0; i+1 < max; ){
 2c4:	89a6                	mv	s3,s1
 2c6:	a011                	j	2ca <gets+0x56>
 2c8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2ca:	99de                	add	s3,s3,s7
 2cc:	00098023          	sb	zero,0(s3)
  return buf;
}
 2d0:	855e                	mv	a0,s7
 2d2:	60e6                	ld	ra,88(sp)
 2d4:	6446                	ld	s0,80(sp)
 2d6:	64a6                	ld	s1,72(sp)
 2d8:	6906                	ld	s2,64(sp)
 2da:	79e2                	ld	s3,56(sp)
 2dc:	7a42                	ld	s4,48(sp)
 2de:	7aa2                	ld	s5,40(sp)
 2e0:	7b02                	ld	s6,32(sp)
 2e2:	6be2                	ld	s7,24(sp)
 2e4:	6125                	addi	sp,sp,96
 2e6:	8082                	ret

00000000000002e8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2e8:	1101                	addi	sp,sp,-32
 2ea:	ec06                	sd	ra,24(sp)
 2ec:	e822                	sd	s0,16(sp)
 2ee:	e426                	sd	s1,8(sp)
 2f0:	e04a                	sd	s2,0(sp)
 2f2:	1000                	addi	s0,sp,32
 2f4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2f6:	4581                	li	a1,0
 2f8:	00000097          	auipc	ra,0x0
 2fc:	170080e7          	jalr	368(ra) # 468 <open>
  if(fd < 0)
 300:	02054563          	bltz	a0,32a <stat+0x42>
 304:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 306:	85ca                	mv	a1,s2
 308:	00000097          	auipc	ra,0x0
 30c:	178080e7          	jalr	376(ra) # 480 <fstat>
 310:	892a                	mv	s2,a0
  close(fd);
 312:	8526                	mv	a0,s1
 314:	00000097          	auipc	ra,0x0
 318:	13c080e7          	jalr	316(ra) # 450 <close>
  return r;
}
 31c:	854a                	mv	a0,s2
 31e:	60e2                	ld	ra,24(sp)
 320:	6442                	ld	s0,16(sp)
 322:	64a2                	ld	s1,8(sp)
 324:	6902                	ld	s2,0(sp)
 326:	6105                	addi	sp,sp,32
 328:	8082                	ret
    return -1;
 32a:	597d                	li	s2,-1
 32c:	bfc5                	j	31c <stat+0x34>

000000000000032e <atoi>:

int
atoi(const char *s)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e422                	sd	s0,8(sp)
 332:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 334:	00054683          	lbu	a3,0(a0)
 338:	fd06879b          	addiw	a5,a3,-48
 33c:	0ff7f793          	zext.b	a5,a5
 340:	4625                	li	a2,9
 342:	02f66863          	bltu	a2,a5,372 <atoi+0x44>
 346:	872a                	mv	a4,a0
  n = 0;
 348:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 34a:	0705                	addi	a4,a4,1
 34c:	0025179b          	slliw	a5,a0,0x2
 350:	9fa9                	addw	a5,a5,a0
 352:	0017979b          	slliw	a5,a5,0x1
 356:	9fb5                	addw	a5,a5,a3
 358:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 35c:	00074683          	lbu	a3,0(a4)
 360:	fd06879b          	addiw	a5,a3,-48
 364:	0ff7f793          	zext.b	a5,a5
 368:	fef671e3          	bgeu	a2,a5,34a <atoi+0x1c>
  return n;
}
 36c:	6422                	ld	s0,8(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret
  n = 0;
 372:	4501                	li	a0,0
 374:	bfe5                	j	36c <atoi+0x3e>

0000000000000376 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 376:	1141                	addi	sp,sp,-16
 378:	e422                	sd	s0,8(sp)
 37a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 37c:	02b57463          	bgeu	a0,a1,3a4 <memmove+0x2e>
    while(n-- > 0)
 380:	00c05f63          	blez	a2,39e <memmove+0x28>
 384:	1602                	slli	a2,a2,0x20
 386:	9201                	srli	a2,a2,0x20
 388:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 38c:	872a                	mv	a4,a0
      *dst++ = *src++;
 38e:	0585                	addi	a1,a1,1
 390:	0705                	addi	a4,a4,1
 392:	fff5c683          	lbu	a3,-1(a1)
 396:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 39a:	fee79ae3          	bne	a5,a4,38e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 39e:	6422                	ld	s0,8(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret
    dst += n;
 3a4:	00c50733          	add	a4,a0,a2
    src += n;
 3a8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3aa:	fec05ae3          	blez	a2,39e <memmove+0x28>
 3ae:	fff6079b          	addiw	a5,a2,-1
 3b2:	1782                	slli	a5,a5,0x20
 3b4:	9381                	srli	a5,a5,0x20
 3b6:	fff7c793          	not	a5,a5
 3ba:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3bc:	15fd                	addi	a1,a1,-1
 3be:	177d                	addi	a4,a4,-1
 3c0:	0005c683          	lbu	a3,0(a1)
 3c4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3c8:	fee79ae3          	bne	a5,a4,3bc <memmove+0x46>
 3cc:	bfc9                	j	39e <memmove+0x28>

00000000000003ce <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ce:	1141                	addi	sp,sp,-16
 3d0:	e422                	sd	s0,8(sp)
 3d2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3d4:	ca05                	beqz	a2,404 <memcmp+0x36>
 3d6:	fff6069b          	addiw	a3,a2,-1
 3da:	1682                	slli	a3,a3,0x20
 3dc:	9281                	srli	a3,a3,0x20
 3de:	0685                	addi	a3,a3,1
 3e0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3e2:	00054783          	lbu	a5,0(a0)
 3e6:	0005c703          	lbu	a4,0(a1)
 3ea:	00e79863          	bne	a5,a4,3fa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3ee:	0505                	addi	a0,a0,1
    p2++;
 3f0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3f2:	fed518e3          	bne	a0,a3,3e2 <memcmp+0x14>
  }
  return 0;
 3f6:	4501                	li	a0,0
 3f8:	a019                	j	3fe <memcmp+0x30>
      return *p1 - *p2;
 3fa:	40e7853b          	subw	a0,a5,a4
}
 3fe:	6422                	ld	s0,8(sp)
 400:	0141                	addi	sp,sp,16
 402:	8082                	ret
  return 0;
 404:	4501                	li	a0,0
 406:	bfe5                	j	3fe <memcmp+0x30>

0000000000000408 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 408:	1141                	addi	sp,sp,-16
 40a:	e406                	sd	ra,8(sp)
 40c:	e022                	sd	s0,0(sp)
 40e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 410:	00000097          	auipc	ra,0x0
 414:	f66080e7          	jalr	-154(ra) # 376 <memmove>
}
 418:	60a2                	ld	ra,8(sp)
 41a:	6402                	ld	s0,0(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret

0000000000000420 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 420:	4885                	li	a7,1
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <exit>:
.global exit
exit:
 li a7, SYS_exit
 428:	4889                	li	a7,2
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <wait>:
.global wait
wait:
 li a7, SYS_wait
 430:	488d                	li	a7,3
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 438:	4891                	li	a7,4
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <read>:
.global read
read:
 li a7, SYS_read
 440:	4895                	li	a7,5
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <write>:
.global write
write:
 li a7, SYS_write
 448:	48c1                	li	a7,16
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <close>:
.global close
close:
 li a7, SYS_close
 450:	48d5                	li	a7,21
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <kill>:
.global kill
kill:
 li a7, SYS_kill
 458:	4899                	li	a7,6
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <exec>:
.global exec
exec:
 li a7, SYS_exec
 460:	489d                	li	a7,7
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <open>:
.global open
open:
 li a7, SYS_open
 468:	48bd                	li	a7,15
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 470:	48c5                	li	a7,17
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 478:	48c9                	li	a7,18
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 480:	48a1                	li	a7,8
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <link>:
.global link
link:
 li a7, SYS_link
 488:	48cd                	li	a7,19
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 490:	48d1                	li	a7,20
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 498:	48a5                	li	a7,9
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4a0:	48a9                	li	a7,10
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4a8:	48ad                	li	a7,11
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4b0:	48b1                	li	a7,12
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4b8:	48b5                	li	a7,13
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4c0:	48b9                	li	a7,14
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <waitstat>:
.global waitstat
waitstat:
 li a7, SYS_waitstat
 4c8:	48d9                	li	a7,22
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d0:	1101                	addi	sp,sp,-32
 4d2:	ec06                	sd	ra,24(sp)
 4d4:	e822                	sd	s0,16(sp)
 4d6:	1000                	addi	s0,sp,32
 4d8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4dc:	4605                	li	a2,1
 4de:	fef40593          	addi	a1,s0,-17
 4e2:	00000097          	auipc	ra,0x0
 4e6:	f66080e7          	jalr	-154(ra) # 448 <write>
}
 4ea:	60e2                	ld	ra,24(sp)
 4ec:	6442                	ld	s0,16(sp)
 4ee:	6105                	addi	sp,sp,32
 4f0:	8082                	ret

00000000000004f2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4f2:	7139                	addi	sp,sp,-64
 4f4:	fc06                	sd	ra,56(sp)
 4f6:	f822                	sd	s0,48(sp)
 4f8:	f426                	sd	s1,40(sp)
 4fa:	f04a                	sd	s2,32(sp)
 4fc:	ec4e                	sd	s3,24(sp)
 4fe:	0080                	addi	s0,sp,64
 500:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 502:	c299                	beqz	a3,508 <printint+0x16>
 504:	0805c963          	bltz	a1,596 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 508:	2581                	sext.w	a1,a1
  neg = 0;
 50a:	4881                	li	a7,0
 50c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 510:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 512:	2601                	sext.w	a2,a2
 514:	00000517          	auipc	a0,0x0
 518:	4cc50513          	addi	a0,a0,1228 # 9e0 <digits>
 51c:	883a                	mv	a6,a4
 51e:	2705                	addiw	a4,a4,1
 520:	02c5f7bb          	remuw	a5,a1,a2
 524:	1782                	slli	a5,a5,0x20
 526:	9381                	srli	a5,a5,0x20
 528:	97aa                	add	a5,a5,a0
 52a:	0007c783          	lbu	a5,0(a5)
 52e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 532:	0005879b          	sext.w	a5,a1
 536:	02c5d5bb          	divuw	a1,a1,a2
 53a:	0685                	addi	a3,a3,1
 53c:	fec7f0e3          	bgeu	a5,a2,51c <printint+0x2a>
  if(neg)
 540:	00088c63          	beqz	a7,558 <printint+0x66>
    buf[i++] = '-';
 544:	fd070793          	addi	a5,a4,-48
 548:	00878733          	add	a4,a5,s0
 54c:	02d00793          	li	a5,45
 550:	fef70823          	sb	a5,-16(a4)
 554:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 558:	02e05863          	blez	a4,588 <printint+0x96>
 55c:	fc040793          	addi	a5,s0,-64
 560:	00e78933          	add	s2,a5,a4
 564:	fff78993          	addi	s3,a5,-1
 568:	99ba                	add	s3,s3,a4
 56a:	377d                	addiw	a4,a4,-1
 56c:	1702                	slli	a4,a4,0x20
 56e:	9301                	srli	a4,a4,0x20
 570:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 574:	fff94583          	lbu	a1,-1(s2)
 578:	8526                	mv	a0,s1
 57a:	00000097          	auipc	ra,0x0
 57e:	f56080e7          	jalr	-170(ra) # 4d0 <putc>
  while(--i >= 0)
 582:	197d                	addi	s2,s2,-1
 584:	ff3918e3          	bne	s2,s3,574 <printint+0x82>
}
 588:	70e2                	ld	ra,56(sp)
 58a:	7442                	ld	s0,48(sp)
 58c:	74a2                	ld	s1,40(sp)
 58e:	7902                	ld	s2,32(sp)
 590:	69e2                	ld	s3,24(sp)
 592:	6121                	addi	sp,sp,64
 594:	8082                	ret
    x = -xx;
 596:	40b005bb          	negw	a1,a1
    neg = 1;
 59a:	4885                	li	a7,1
    x = -xx;
 59c:	bf85                	j	50c <printint+0x1a>

000000000000059e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 59e:	7119                	addi	sp,sp,-128
 5a0:	fc86                	sd	ra,120(sp)
 5a2:	f8a2                	sd	s0,112(sp)
 5a4:	f4a6                	sd	s1,104(sp)
 5a6:	f0ca                	sd	s2,96(sp)
 5a8:	ecce                	sd	s3,88(sp)
 5aa:	e8d2                	sd	s4,80(sp)
 5ac:	e4d6                	sd	s5,72(sp)
 5ae:	e0da                	sd	s6,64(sp)
 5b0:	fc5e                	sd	s7,56(sp)
 5b2:	f862                	sd	s8,48(sp)
 5b4:	f466                	sd	s9,40(sp)
 5b6:	f06a                	sd	s10,32(sp)
 5b8:	ec6e                	sd	s11,24(sp)
 5ba:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5bc:	0005c903          	lbu	s2,0(a1)
 5c0:	18090f63          	beqz	s2,75e <vprintf+0x1c0>
 5c4:	8aaa                	mv	s5,a0
 5c6:	8b32                	mv	s6,a2
 5c8:	00158493          	addi	s1,a1,1
  state = 0;
 5cc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5ce:	02500a13          	li	s4,37
 5d2:	4c55                	li	s8,21
 5d4:	00000c97          	auipc	s9,0x0
 5d8:	3b4c8c93          	addi	s9,s9,948 # 988 <malloc+0x126>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5dc:	02800d93          	li	s11,40
  putc(fd, 'x');
 5e0:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5e2:	00000b97          	auipc	s7,0x0
 5e6:	3feb8b93          	addi	s7,s7,1022 # 9e0 <digits>
 5ea:	a839                	j	608 <vprintf+0x6a>
        putc(fd, c);
 5ec:	85ca                	mv	a1,s2
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	ee0080e7          	jalr	-288(ra) # 4d0 <putc>
 5f8:	a019                	j	5fe <vprintf+0x60>
    } else if(state == '%'){
 5fa:	01498d63          	beq	s3,s4,614 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 5fe:	0485                	addi	s1,s1,1
 600:	fff4c903          	lbu	s2,-1(s1)
 604:	14090d63          	beqz	s2,75e <vprintf+0x1c0>
    if(state == 0){
 608:	fe0999e3          	bnez	s3,5fa <vprintf+0x5c>
      if(c == '%'){
 60c:	ff4910e3          	bne	s2,s4,5ec <vprintf+0x4e>
        state = '%';
 610:	89d2                	mv	s3,s4
 612:	b7f5                	j	5fe <vprintf+0x60>
      if(c == 'd'){
 614:	11490c63          	beq	s2,s4,72c <vprintf+0x18e>
 618:	f9d9079b          	addiw	a5,s2,-99
 61c:	0ff7f793          	zext.b	a5,a5
 620:	10fc6e63          	bltu	s8,a5,73c <vprintf+0x19e>
 624:	f9d9079b          	addiw	a5,s2,-99
 628:	0ff7f713          	zext.b	a4,a5
 62c:	10ec6863          	bltu	s8,a4,73c <vprintf+0x19e>
 630:	00271793          	slli	a5,a4,0x2
 634:	97e6                	add	a5,a5,s9
 636:	439c                	lw	a5,0(a5)
 638:	97e6                	add	a5,a5,s9
 63a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 63c:	008b0913          	addi	s2,s6,8
 640:	4685                	li	a3,1
 642:	4629                	li	a2,10
 644:	000b2583          	lw	a1,0(s6)
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	ea8080e7          	jalr	-344(ra) # 4f2 <printint>
 652:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 654:	4981                	li	s3,0
 656:	b765                	j	5fe <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 658:	008b0913          	addi	s2,s6,8
 65c:	4681                	li	a3,0
 65e:	4629                	li	a2,10
 660:	000b2583          	lw	a1,0(s6)
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	e8c080e7          	jalr	-372(ra) # 4f2 <printint>
 66e:	8b4a                	mv	s6,s2
      state = 0;
 670:	4981                	li	s3,0
 672:	b771                	j	5fe <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 674:	008b0913          	addi	s2,s6,8
 678:	4681                	li	a3,0
 67a:	866a                	mv	a2,s10
 67c:	000b2583          	lw	a1,0(s6)
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e70080e7          	jalr	-400(ra) # 4f2 <printint>
 68a:	8b4a                	mv	s6,s2
      state = 0;
 68c:	4981                	li	s3,0
 68e:	bf85                	j	5fe <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 690:	008b0793          	addi	a5,s6,8
 694:	f8f43423          	sd	a5,-120(s0)
 698:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 69c:	03000593          	li	a1,48
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	e2e080e7          	jalr	-466(ra) # 4d0 <putc>
  putc(fd, 'x');
 6aa:	07800593          	li	a1,120
 6ae:	8556                	mv	a0,s5
 6b0:	00000097          	auipc	ra,0x0
 6b4:	e20080e7          	jalr	-480(ra) # 4d0 <putc>
 6b8:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ba:	03c9d793          	srli	a5,s3,0x3c
 6be:	97de                	add	a5,a5,s7
 6c0:	0007c583          	lbu	a1,0(a5)
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	e0a080e7          	jalr	-502(ra) # 4d0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ce:	0992                	slli	s3,s3,0x4
 6d0:	397d                	addiw	s2,s2,-1
 6d2:	fe0914e3          	bnez	s2,6ba <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 6d6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	b70d                	j	5fe <vprintf+0x60>
        s = va_arg(ap, char*);
 6de:	008b0913          	addi	s2,s6,8
 6e2:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 6e6:	02098163          	beqz	s3,708 <vprintf+0x16a>
        while(*s != 0){
 6ea:	0009c583          	lbu	a1,0(s3)
 6ee:	c5ad                	beqz	a1,758 <vprintf+0x1ba>
          putc(fd, *s);
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	dde080e7          	jalr	-546(ra) # 4d0 <putc>
          s++;
 6fa:	0985                	addi	s3,s3,1
        while(*s != 0){
 6fc:	0009c583          	lbu	a1,0(s3)
 700:	f9e5                	bnez	a1,6f0 <vprintf+0x152>
        s = va_arg(ap, char*);
 702:	8b4a                	mv	s6,s2
      state = 0;
 704:	4981                	li	s3,0
 706:	bde5                	j	5fe <vprintf+0x60>
          s = "(null)";
 708:	00000997          	auipc	s3,0x0
 70c:	27898993          	addi	s3,s3,632 # 980 <malloc+0x11e>
        while(*s != 0){
 710:	85ee                	mv	a1,s11
 712:	bff9                	j	6f0 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 714:	008b0913          	addi	s2,s6,8
 718:	000b4583          	lbu	a1,0(s6)
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	db2080e7          	jalr	-590(ra) # 4d0 <putc>
 726:	8b4a                	mv	s6,s2
      state = 0;
 728:	4981                	li	s3,0
 72a:	bdd1                	j	5fe <vprintf+0x60>
        putc(fd, c);
 72c:	85d2                	mv	a1,s4
 72e:	8556                	mv	a0,s5
 730:	00000097          	auipc	ra,0x0
 734:	da0080e7          	jalr	-608(ra) # 4d0 <putc>
      state = 0;
 738:	4981                	li	s3,0
 73a:	b5d1                	j	5fe <vprintf+0x60>
        putc(fd, '%');
 73c:	85d2                	mv	a1,s4
 73e:	8556                	mv	a0,s5
 740:	00000097          	auipc	ra,0x0
 744:	d90080e7          	jalr	-624(ra) # 4d0 <putc>
        putc(fd, c);
 748:	85ca                	mv	a1,s2
 74a:	8556                	mv	a0,s5
 74c:	00000097          	auipc	ra,0x0
 750:	d84080e7          	jalr	-636(ra) # 4d0 <putc>
      state = 0;
 754:	4981                	li	s3,0
 756:	b565                	j	5fe <vprintf+0x60>
        s = va_arg(ap, char*);
 758:	8b4a                	mv	s6,s2
      state = 0;
 75a:	4981                	li	s3,0
 75c:	b54d                	j	5fe <vprintf+0x60>
    }
  }
}
 75e:	70e6                	ld	ra,120(sp)
 760:	7446                	ld	s0,112(sp)
 762:	74a6                	ld	s1,104(sp)
 764:	7906                	ld	s2,96(sp)
 766:	69e6                	ld	s3,88(sp)
 768:	6a46                	ld	s4,80(sp)
 76a:	6aa6                	ld	s5,72(sp)
 76c:	6b06                	ld	s6,64(sp)
 76e:	7be2                	ld	s7,56(sp)
 770:	7c42                	ld	s8,48(sp)
 772:	7ca2                	ld	s9,40(sp)
 774:	7d02                	ld	s10,32(sp)
 776:	6de2                	ld	s11,24(sp)
 778:	6109                	addi	sp,sp,128
 77a:	8082                	ret

000000000000077c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 77c:	715d                	addi	sp,sp,-80
 77e:	ec06                	sd	ra,24(sp)
 780:	e822                	sd	s0,16(sp)
 782:	1000                	addi	s0,sp,32
 784:	e010                	sd	a2,0(s0)
 786:	e414                	sd	a3,8(s0)
 788:	e818                	sd	a4,16(s0)
 78a:	ec1c                	sd	a5,24(s0)
 78c:	03043023          	sd	a6,32(s0)
 790:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 794:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 798:	8622                	mv	a2,s0
 79a:	00000097          	auipc	ra,0x0
 79e:	e04080e7          	jalr	-508(ra) # 59e <vprintf>
}
 7a2:	60e2                	ld	ra,24(sp)
 7a4:	6442                	ld	s0,16(sp)
 7a6:	6161                	addi	sp,sp,80
 7a8:	8082                	ret

00000000000007aa <printf>:

void
printf(const char *fmt, ...)
{
 7aa:	711d                	addi	sp,sp,-96
 7ac:	ec06                	sd	ra,24(sp)
 7ae:	e822                	sd	s0,16(sp)
 7b0:	1000                	addi	s0,sp,32
 7b2:	e40c                	sd	a1,8(s0)
 7b4:	e810                	sd	a2,16(s0)
 7b6:	ec14                	sd	a3,24(s0)
 7b8:	f018                	sd	a4,32(s0)
 7ba:	f41c                	sd	a5,40(s0)
 7bc:	03043823          	sd	a6,48(s0)
 7c0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7c4:	00840613          	addi	a2,s0,8
 7c8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7cc:	85aa                	mv	a1,a0
 7ce:	4505                	li	a0,1
 7d0:	00000097          	auipc	ra,0x0
 7d4:	dce080e7          	jalr	-562(ra) # 59e <vprintf>
}
 7d8:	60e2                	ld	ra,24(sp)
 7da:	6442                	ld	s0,16(sp)
 7dc:	6125                	addi	sp,sp,96
 7de:	8082                	ret

00000000000007e0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7e0:	1141                	addi	sp,sp,-16
 7e2:	e422                	sd	s0,8(sp)
 7e4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ea:	00000797          	auipc	a5,0x0
 7ee:	20e7b783          	ld	a5,526(a5) # 9f8 <freep>
 7f2:	a02d                	j	81c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7f4:	4618                	lw	a4,8(a2)
 7f6:	9f2d                	addw	a4,a4,a1
 7f8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7fc:	6398                	ld	a4,0(a5)
 7fe:	6310                	ld	a2,0(a4)
 800:	a83d                	j	83e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 802:	ff852703          	lw	a4,-8(a0)
 806:	9f31                	addw	a4,a4,a2
 808:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 80a:	ff053683          	ld	a3,-16(a0)
 80e:	a091                	j	852 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 810:	6398                	ld	a4,0(a5)
 812:	00e7e463          	bltu	a5,a4,81a <free+0x3a>
 816:	00e6ea63          	bltu	a3,a4,82a <free+0x4a>
{
 81a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81c:	fed7fae3          	bgeu	a5,a3,810 <free+0x30>
 820:	6398                	ld	a4,0(a5)
 822:	00e6e463          	bltu	a3,a4,82a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 826:	fee7eae3          	bltu	a5,a4,81a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 82a:	ff852583          	lw	a1,-8(a0)
 82e:	6390                	ld	a2,0(a5)
 830:	02059813          	slli	a6,a1,0x20
 834:	01c85713          	srli	a4,a6,0x1c
 838:	9736                	add	a4,a4,a3
 83a:	fae60de3          	beq	a2,a4,7f4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 83e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 842:	4790                	lw	a2,8(a5)
 844:	02061593          	slli	a1,a2,0x20
 848:	01c5d713          	srli	a4,a1,0x1c
 84c:	973e                	add	a4,a4,a5
 84e:	fae68ae3          	beq	a3,a4,802 <free+0x22>
    p->s.ptr = bp->s.ptr;
 852:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 854:	00000717          	auipc	a4,0x0
 858:	1af73223          	sd	a5,420(a4) # 9f8 <freep>
}
 85c:	6422                	ld	s0,8(sp)
 85e:	0141                	addi	sp,sp,16
 860:	8082                	ret

0000000000000862 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 862:	7139                	addi	sp,sp,-64
 864:	fc06                	sd	ra,56(sp)
 866:	f822                	sd	s0,48(sp)
 868:	f426                	sd	s1,40(sp)
 86a:	f04a                	sd	s2,32(sp)
 86c:	ec4e                	sd	s3,24(sp)
 86e:	e852                	sd	s4,16(sp)
 870:	e456                	sd	s5,8(sp)
 872:	e05a                	sd	s6,0(sp)
 874:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 876:	02051493          	slli	s1,a0,0x20
 87a:	9081                	srli	s1,s1,0x20
 87c:	04bd                	addi	s1,s1,15
 87e:	8091                	srli	s1,s1,0x4
 880:	0014899b          	addiw	s3,s1,1
 884:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 886:	00000517          	auipc	a0,0x0
 88a:	17253503          	ld	a0,370(a0) # 9f8 <freep>
 88e:	c515                	beqz	a0,8ba <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 890:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 892:	4798                	lw	a4,8(a5)
 894:	02977f63          	bgeu	a4,s1,8d2 <malloc+0x70>
 898:	8a4e                	mv	s4,s3
 89a:	0009871b          	sext.w	a4,s3
 89e:	6685                	lui	a3,0x1
 8a0:	00d77363          	bgeu	a4,a3,8a6 <malloc+0x44>
 8a4:	6a05                	lui	s4,0x1
 8a6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8aa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ae:	00000917          	auipc	s2,0x0
 8b2:	14a90913          	addi	s2,s2,330 # 9f8 <freep>
  if(p == (char*)-1)
 8b6:	5afd                	li	s5,-1
 8b8:	a895                	j	92c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8ba:	00000797          	auipc	a5,0x0
 8be:	14678793          	addi	a5,a5,326 # a00 <base>
 8c2:	00000717          	auipc	a4,0x0
 8c6:	12f73b23          	sd	a5,310(a4) # 9f8 <freep>
 8ca:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8cc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8d0:	b7e1                	j	898 <malloc+0x36>
      if(p->s.size == nunits)
 8d2:	02e48c63          	beq	s1,a4,90a <malloc+0xa8>
        p->s.size -= nunits;
 8d6:	4137073b          	subw	a4,a4,s3
 8da:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8dc:	02071693          	slli	a3,a4,0x20
 8e0:	01c6d713          	srli	a4,a3,0x1c
 8e4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ea:	00000717          	auipc	a4,0x0
 8ee:	10a73723          	sd	a0,270(a4) # 9f8 <freep>
      return (void*)(p + 1);
 8f2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8f6:	70e2                	ld	ra,56(sp)
 8f8:	7442                	ld	s0,48(sp)
 8fa:	74a2                	ld	s1,40(sp)
 8fc:	7902                	ld	s2,32(sp)
 8fe:	69e2                	ld	s3,24(sp)
 900:	6a42                	ld	s4,16(sp)
 902:	6aa2                	ld	s5,8(sp)
 904:	6b02                	ld	s6,0(sp)
 906:	6121                	addi	sp,sp,64
 908:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 90a:	6398                	ld	a4,0(a5)
 90c:	e118                	sd	a4,0(a0)
 90e:	bff1                	j	8ea <malloc+0x88>
  hp->s.size = nu;
 910:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 914:	0541                	addi	a0,a0,16
 916:	00000097          	auipc	ra,0x0
 91a:	eca080e7          	jalr	-310(ra) # 7e0 <free>
  return freep;
 91e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 922:	d971                	beqz	a0,8f6 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 924:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 926:	4798                	lw	a4,8(a5)
 928:	fa9775e3          	bgeu	a4,s1,8d2 <malloc+0x70>
    if(p == freep)
 92c:	00093703          	ld	a4,0(s2)
 930:	853e                	mv	a0,a5
 932:	fef719e3          	bne	a4,a5,924 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 936:	8552                	mv	a0,s4
 938:	00000097          	auipc	ra,0x0
 93c:	b78080e7          	jalr	-1160(ra) # 4b0 <sbrk>
  if(p == (char*)-1)
 940:	fd5518e3          	bne	a0,s5,910 <malloc+0xae>
        return 0;
 944:	4501                	li	a0,0
 946:	bf45                	j	8f6 <malloc+0x94>
