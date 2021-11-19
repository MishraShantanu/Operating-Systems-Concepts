
user/_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[]){
   0:	d4010113          	addi	sp,sp,-704
   4:	2a113c23          	sd	ra,696(sp)
   8:	2a813823          	sd	s0,688(sp)
   c:	2a913423          	sd	s1,680(sp)
  10:	2b213023          	sd	s2,672(sp)
  14:	29313c23          	sd	s3,664(sp)
  18:	29413823          	sd	s4,656(sp)
  1c:	29513423          	sd	s5,648(sp)
  20:	29613023          	sd	s6,640(sp)
  24:	27713c23          	sd	s7,632(sp)
  28:	27813823          	sd	s8,624(sp)
  2c:	27913423          	sd	s9,616(sp)
  30:	27a13023          	sd	s10,608(sp)
  34:	25b13c23          	sd	s11,600(sp)
  38:	0580                	addi	s0,sp,704
    
    int startPidA=-1,endPidA=-1;
    int startPidB=-1,endPidB=-1;
    int startPidC=-1,endPidC=-1;
  
    char msgA[140] = "Tag A - Hello world";
  3a:	4651                	li	a2,20
  3c:	00001597          	auipc	a1,0x1
  40:	a4458593          	addi	a1,a1,-1468 # a80 <malloc+0x176>
  44:	f0040513          	addi	a0,s0,-256
  48:	00000097          	auipc	ra,0x0
  4c:	450080e7          	jalr	1104(ra) # 498 <memcpy>
  50:	07800613          	li	a2,120
  54:	4581                	li	a1,0
  56:	f1440513          	addi	a0,s0,-236
  5a:	00000097          	auipc	ra,0x0
  5e:	264080e7          	jalr	612(ra) # 2be <memset>
    char msgB[140] = "Tag B -   CMPT 332!";
  62:	4651                	li	a2,20
  64:	00001597          	auipc	a1,0x1
  68:	a3458593          	addi	a1,a1,-1484 # a98 <malloc+0x18e>
  6c:	e7040513          	addi	a0,s0,-400
  70:	00000097          	auipc	ra,0x0
  74:	428080e7          	jalr	1064(ra) # 498 <memcpy>
  78:	07800613          	li	a2,120
  7c:	4581                	li	a1,0
  7e:	e8440513          	addi	a0,s0,-380
  82:	00000097          	auipc	ra,0x0
  86:	23c080e7          	jalr	572(ra) # 2be <memset>
    char msgC[140] = "Tag C- Xv6 A 3 part A";
  8a:	4659                	li	a2,22
  8c:	00001597          	auipc	a1,0x1
  90:	a2458593          	addi	a1,a1,-1500 # ab0 <malloc+0x1a6>
  94:	de040513          	addi	a0,s0,-544
  98:	00000097          	auipc	ra,0x0
  9c:	400080e7          	jalr	1024(ra) # 498 <memcpy>
  a0:	07600613          	li	a2,118
  a4:	4581                	li	a1,0
  a6:	df640513          	addi	a0,s0,-522
  aa:	00000097          	auipc	ra,0x0
  ae:	214080e7          	jalr	532(ra) # 2be <memset>
    char buf[140];
    enum topic_t tag;
     
   
    int rc;
printf("************** Test case 1*********\n");   
  b2:	00001517          	auipc	a0,0x1
  b6:	93e50513          	addi	a0,a0,-1730 # 9f0 <malloc+0xe6>
  ba:	00000097          	auipc	ra,0x0
  be:	798080e7          	jalr	1944(ra) # 852 <printf>
  c2:	4a05                	li	s4,1
  c4:	4981                	li	s3,0
    int startPidC=-1,endPidC=-1;
  c6:	5c7d                	li	s8,-1
    int startPidB=-1,endPidB=-1;
  c8:	57fd                	li	a5,-1
  ca:	d4f43423          	sd	a5,-696(s0)
  ce:	5b7d                	li	s6,-1
    int startPidA=-1,endPidA=-1;
  d0:	5d7d                	li	s10,-1
  d2:	5afd                	li	s5,-1
for(int f=0;f<45;f++){
  d4:	02c00d93          	li	s11,44
            }else{
            
         
            if(f==0 && startPidA==-1){
                startPidA = rc;
            }else if(f==14 && endPidA==-1){
  d8:	4cb9                	li	s9,14
                 endPidA = rc;
            }else if(f==15 && startPidB==-1){
                startPidB = rc;
            }else if(f==29 && endPidB==-1){
                 endPidB = rc;
            }else if(f==30 && startPidC==-1){
  da:	5bfd                	li	s7,-1
  dc:	a8a1                	j	134 <main+0x134>
                 if(f<15){
  de:	47b9                	li	a5,14
  e0:	0327d263          	bge	a5,s2,104 <main+0x104>
                 }else if(f>=15 && f < 30){
  e4:	39c5                	addiw	s3,s3,-15
  e6:	47b9                	li	a5,14
  e8:	0337e663          	bltu	a5,s3,114 <main+0x114>
                         btput(tag=b,msgB);
  ec:	e7040593          	addi	a1,s0,-400
  f0:	4505                	li	a0,1
  f2:	00000097          	auipc	ra,0x0
  f6:	466080e7          	jalr	1126(ra) # 558 <btput>
                exit(0);
  fa:	4501                	li	a0,0
  fc:	00000097          	auipc	ra,0x0
 100:	3bc080e7          	jalr	956(ra) # 4b8 <exit>
                        btput(tag=a,msgA);
 104:	f0040593          	addi	a1,s0,-256
 108:	4501                	li	a0,0
 10a:	00000097          	auipc	ra,0x0
 10e:	44e080e7          	jalr	1102(ra) # 558 <btput>
 112:	b7e5                	j	fa <main+0xfa>
                         btput(tag=c,msgC);
 114:	de040593          	addi	a1,s0,-544
 118:	4509                	li	a0,2
 11a:	00000097          	auipc	ra,0x0
 11e:	43e080e7          	jalr	1086(ra) # 558 <btput>
 122:	bfe1                	j	fa <main+0xfa>
            if(f==0 && startPidA==-1){
 124:	137a8263          	beq	s5,s7,248 <main+0x248>
for(int f=0;f<45;f++){
 128:	000a079b          	sext.w	a5,s4
 12c:	06fdc563          	blt	s11,a5,196 <main+0x196>
 130:	2985                	addiw	s3,s3,1
 132:	2a05                	addiw	s4,s4,1
 134:	0009891b          	sext.w	s2,s3
        rc=fork();
 138:	00000097          	auipc	ra,0x0
 13c:	378080e7          	jalr	888(ra) # 4b0 <fork>
 140:	84aa                	mv	s1,a0
        if(rc==0){
 142:	dd51                	beqz	a0,de <main+0xde>
            if(f==0 && startPidA==-1){
 144:	fe0900e3          	beqz	s2,124 <main+0x124>
            }else if(f==14 && endPidA==-1){
 148:	01990f63          	beq	s2,s9,166 <main+0x166>
            }else if(f==15 && startPidB==-1){
 14c:	47bd                	li	a5,15
 14e:	02f90063          	beq	s2,a5,16e <main+0x16e>
            }else if(f==29 && endPidB==-1){
 152:	47f5                	li	a5,29
 154:	02f90163          	beq	s2,a5,176 <main+0x176>
            }else if(f==30 && startPidC==-1){
 158:	47f9                	li	a5,30
 15a:	02f91563          	bne	s2,a5,184 <main+0x184>
 15e:	fd7c15e3          	bne	s8,s7,128 <main+0x128>
        rc=fork();
 162:	8c2a                	mv	s8,a0
for(int f=0;f<45;f++){
 164:	b7f1                	j	130 <main+0x130>
            }else if(f==14 && endPidA==-1){
 166:	fd7d11e3          	bne	s10,s7,128 <main+0x128>
        rc=fork();
 16a:	8d2a                	mv	s10,a0
 16c:	b7d1                	j	130 <main+0x130>
            }else if(f==15 && startPidB==-1){
 16e:	fb7b1de3          	bne	s6,s7,128 <main+0x128>
        rc=fork();
 172:	8b2a                	mv	s6,a0
 174:	bf75                	j	130 <main+0x130>
            }else if(f==29 && endPidB==-1){
 176:	d4843783          	ld	a5,-696(s0)
 17a:	fb7797e3          	bne	a5,s7,128 <main+0x128>
        rc=fork();
 17e:	d4a43423          	sd	a0,-696(s0)
 182:	b77d                	j	130 <main+0x130>
                startPidC = rc;
            }else if(f==44 && endPidC==-1){
 184:	fbb912e3          	bne	s2,s11,128 <main+0x128>
            
            
        }
    }
      
      for(int i=0;i<45;i++){
 188:	02d00913          	li	s2,45
            }else if(pid>=startPidB && pid<=endPidB){
                 btget(tag=b,buf);
                 printf("btget output: %s \n",buf);
            }else if(pid>=startPidC && pid<=endPidC){
                 btget(tag=c,buf);
                 printf("btget output: %s \n",buf);
 18c:	00001997          	auipc	s3,0x1
 190:	88c98993          	addi	s3,s3,-1908 # a18 <malloc+0x10e>
 194:	a025                	j	1bc <main+0x1bc>
 196:	54fd                	li	s1,-1
 198:	bfc5                	j	188 <main+0x188>
                 btget(tag=a,buf);
 19a:	d5040593          	addi	a1,s0,-688
 19e:	4501                	li	a0,0
 1a0:	00000097          	auipc	ra,0x0
 1a4:	3c8080e7          	jalr	968(ra) # 568 <btget>
                 printf("btget output: %s \n",buf);
 1a8:	d5040593          	addi	a1,s0,-688
 1ac:	854e                	mv	a0,s3
 1ae:	00000097          	auipc	ra,0x0
 1b2:	6a4080e7          	jalr	1700(ra) # 852 <printf>
      for(int i=0;i<45;i++){
 1b6:	397d                	addiw	s2,s2,-1
 1b8:	06090363          	beqz	s2,21e <main+0x21e>
           pid = wait(0);
 1bc:	4501                	li	a0,0
 1be:	00000097          	auipc	ra,0x0
 1c2:	302080e7          	jalr	770(ra) # 4c0 <wait>
           if(pid>=startPidA && pid<=endPidA){
 1c6:	01554463          	blt	a0,s5,1ce <main+0x1ce>
 1ca:	fcad58e3          	bge	s10,a0,19a <main+0x19a>
            }else if(pid>=startPidB && pid<=endPidB){
 1ce:	01654663          	blt	a0,s6,1da <main+0x1da>
 1d2:	d4843783          	ld	a5,-696(s0)
 1d6:	02a7d563          	bge	a5,a0,200 <main+0x200>
            }else if(pid>=startPidC && pid<=endPidC){
 1da:	fd854ee3          	blt	a0,s8,1b6 <main+0x1b6>
 1de:	fca4cce3          	blt	s1,a0,1b6 <main+0x1b6>
                 btget(tag=c,buf);
 1e2:	d5040593          	addi	a1,s0,-688
 1e6:	4509                	li	a0,2
 1e8:	00000097          	auipc	ra,0x0
 1ec:	380080e7          	jalr	896(ra) # 568 <btget>
                 printf("btget output: %s \n",buf);
 1f0:	d5040593          	addi	a1,s0,-688
 1f4:	854e                	mv	a0,s3
 1f6:	00000097          	auipc	ra,0x0
 1fa:	65c080e7          	jalr	1628(ra) # 852 <printf>
 1fe:	bf65                	j	1b6 <main+0x1b6>
                 btget(tag=b,buf);
 200:	d5040593          	addi	a1,s0,-688
 204:	4505                	li	a0,1
 206:	00000097          	auipc	ra,0x0
 20a:	362080e7          	jalr	866(ra) # 568 <btget>
                 printf("btget output: %s \n",buf);
 20e:	d5040593          	addi	a1,s0,-688
 212:	854e                	mv	a0,s3
 214:	00000097          	auipc	ra,0x0
 218:	63e080e7          	jalr	1598(ra) # 852 <printf>
 21c:	bf69                	j	1b6 <main+0x1b6>

            // printf("turnaround %d, runT %d", turnaroundTime, runningTime);
        
    }
    
printf("************** Test case 2*********\n");  
 21e:	00001517          	auipc	a0,0x1
 222:	81250513          	addi	a0,a0,-2030 # a30 <malloc+0x126>
 226:	00000097          	auipc	ra,0x0
 22a:	62c080e7          	jalr	1580(ra) # 852 <printf>

printf("************** Test case 3*********\n");   
 22e:	00001517          	auipc	a0,0x1
 232:	82a50513          	addi	a0,a0,-2006 # a58 <malloc+0x14e>
 236:	00000097          	auipc	ra,0x0
 23a:	61c080e7          	jalr	1564(ra) # 852 <printf>
    
                 
   
  exit(0);
 23e:	4501                	li	a0,0
 240:	00000097          	auipc	ra,0x0
 244:	278080e7          	jalr	632(ra) # 4b8 <exit>
        rc=fork();
 248:	8aaa                	mv	s5,a0
 24a:	b5dd                	j	130 <main+0x130>

000000000000024c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 24c:	1141                	addi	sp,sp,-16
 24e:	e422                	sd	s0,8(sp)
 250:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 252:	87aa                	mv	a5,a0
 254:	0585                	addi	a1,a1,1
 256:	0785                	addi	a5,a5,1
 258:	fff5c703          	lbu	a4,-1(a1)
 25c:	fee78fa3          	sb	a4,-1(a5)
 260:	fb75                	bnez	a4,254 <strcpy+0x8>
    ;
  return os;
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret

0000000000000268 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e422                	sd	s0,8(sp)
 26c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 26e:	00054783          	lbu	a5,0(a0)
 272:	cb91                	beqz	a5,286 <strcmp+0x1e>
 274:	0005c703          	lbu	a4,0(a1)
 278:	00f71763          	bne	a4,a5,286 <strcmp+0x1e>
    p++, q++;
 27c:	0505                	addi	a0,a0,1
 27e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 280:	00054783          	lbu	a5,0(a0)
 284:	fbe5                	bnez	a5,274 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 286:	0005c503          	lbu	a0,0(a1)
}
 28a:	40a7853b          	subw	a0,a5,a0
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret

0000000000000294 <strlen>:

uint
strlen(const char *s)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 29a:	00054783          	lbu	a5,0(a0)
 29e:	cf91                	beqz	a5,2ba <strlen+0x26>
 2a0:	0505                	addi	a0,a0,1
 2a2:	87aa                	mv	a5,a0
 2a4:	4685                	li	a3,1
 2a6:	9e89                	subw	a3,a3,a0
 2a8:	00f6853b          	addw	a0,a3,a5
 2ac:	0785                	addi	a5,a5,1
 2ae:	fff7c703          	lbu	a4,-1(a5)
 2b2:	fb7d                	bnez	a4,2a8 <strlen+0x14>
    ;
  return n;
}
 2b4:	6422                	ld	s0,8(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret
  for(n = 0; s[n]; n++)
 2ba:	4501                	li	a0,0
 2bc:	bfe5                	j	2b4 <strlen+0x20>

00000000000002be <memset>:

void*
memset(void *dst, int c, uint n)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e422                	sd	s0,8(sp)
 2c2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2c4:	ca19                	beqz	a2,2da <memset+0x1c>
 2c6:	87aa                	mv	a5,a0
 2c8:	1602                	slli	a2,a2,0x20
 2ca:	9201                	srli	a2,a2,0x20
 2cc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2d0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2d4:	0785                	addi	a5,a5,1
 2d6:	fee79de3          	bne	a5,a4,2d0 <memset+0x12>
  }
  return dst;
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret

00000000000002e0 <strchr>:

char*
strchr(const char *s, char c)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2e6:	00054783          	lbu	a5,0(a0)
 2ea:	cb99                	beqz	a5,300 <strchr+0x20>
    if(*s == c)
 2ec:	00f58763          	beq	a1,a5,2fa <strchr+0x1a>
  for(; *s; s++)
 2f0:	0505                	addi	a0,a0,1
 2f2:	00054783          	lbu	a5,0(a0)
 2f6:	fbfd                	bnez	a5,2ec <strchr+0xc>
      return (char*)s;
  return 0;
 2f8:	4501                	li	a0,0
}
 2fa:	6422                	ld	s0,8(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret
  return 0;
 300:	4501                	li	a0,0
 302:	bfe5                	j	2fa <strchr+0x1a>

0000000000000304 <gets>:

char*
gets(char *buf, int max)
{
 304:	711d                	addi	sp,sp,-96
 306:	ec86                	sd	ra,88(sp)
 308:	e8a2                	sd	s0,80(sp)
 30a:	e4a6                	sd	s1,72(sp)
 30c:	e0ca                	sd	s2,64(sp)
 30e:	fc4e                	sd	s3,56(sp)
 310:	f852                	sd	s4,48(sp)
 312:	f456                	sd	s5,40(sp)
 314:	f05a                	sd	s6,32(sp)
 316:	ec5e                	sd	s7,24(sp)
 318:	1080                	addi	s0,sp,96
 31a:	8baa                	mv	s7,a0
 31c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 31e:	892a                	mv	s2,a0
 320:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 322:	4aa9                	li	s5,10
 324:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 326:	89a6                	mv	s3,s1
 328:	2485                	addiw	s1,s1,1
 32a:	0344d863          	bge	s1,s4,35a <gets+0x56>
    cc = read(0, &c, 1);
 32e:	4605                	li	a2,1
 330:	faf40593          	addi	a1,s0,-81
 334:	4501                	li	a0,0
 336:	00000097          	auipc	ra,0x0
 33a:	19a080e7          	jalr	410(ra) # 4d0 <read>
    if(cc < 1)
 33e:	00a05e63          	blez	a0,35a <gets+0x56>
    buf[i++] = c;
 342:	faf44783          	lbu	a5,-81(s0)
 346:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 34a:	01578763          	beq	a5,s5,358 <gets+0x54>
 34e:	0905                	addi	s2,s2,1
 350:	fd679be3          	bne	a5,s6,326 <gets+0x22>
  for(i=0; i+1 < max; ){
 354:	89a6                	mv	s3,s1
 356:	a011                	j	35a <gets+0x56>
 358:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 35a:	99de                	add	s3,s3,s7
 35c:	00098023          	sb	zero,0(s3)
  return buf;
}
 360:	855e                	mv	a0,s7
 362:	60e6                	ld	ra,88(sp)
 364:	6446                	ld	s0,80(sp)
 366:	64a6                	ld	s1,72(sp)
 368:	6906                	ld	s2,64(sp)
 36a:	79e2                	ld	s3,56(sp)
 36c:	7a42                	ld	s4,48(sp)
 36e:	7aa2                	ld	s5,40(sp)
 370:	7b02                	ld	s6,32(sp)
 372:	6be2                	ld	s7,24(sp)
 374:	6125                	addi	sp,sp,96
 376:	8082                	ret

0000000000000378 <stat>:

int
stat(const char *n, struct stat *st)
{
 378:	1101                	addi	sp,sp,-32
 37a:	ec06                	sd	ra,24(sp)
 37c:	e822                	sd	s0,16(sp)
 37e:	e426                	sd	s1,8(sp)
 380:	e04a                	sd	s2,0(sp)
 382:	1000                	addi	s0,sp,32
 384:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 386:	4581                	li	a1,0
 388:	00000097          	auipc	ra,0x0
 38c:	170080e7          	jalr	368(ra) # 4f8 <open>
  if(fd < 0)
 390:	02054563          	bltz	a0,3ba <stat+0x42>
 394:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 396:	85ca                	mv	a1,s2
 398:	00000097          	auipc	ra,0x0
 39c:	178080e7          	jalr	376(ra) # 510 <fstat>
 3a0:	892a                	mv	s2,a0
  close(fd);
 3a2:	8526                	mv	a0,s1
 3a4:	00000097          	auipc	ra,0x0
 3a8:	13c080e7          	jalr	316(ra) # 4e0 <close>
  return r;
}
 3ac:	854a                	mv	a0,s2
 3ae:	60e2                	ld	ra,24(sp)
 3b0:	6442                	ld	s0,16(sp)
 3b2:	64a2                	ld	s1,8(sp)
 3b4:	6902                	ld	s2,0(sp)
 3b6:	6105                	addi	sp,sp,32
 3b8:	8082                	ret
    return -1;
 3ba:	597d                	li	s2,-1
 3bc:	bfc5                	j	3ac <stat+0x34>

00000000000003be <atoi>:

int
atoi(const char *s)
{
 3be:	1141                	addi	sp,sp,-16
 3c0:	e422                	sd	s0,8(sp)
 3c2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3c4:	00054683          	lbu	a3,0(a0)
 3c8:	fd06879b          	addiw	a5,a3,-48
 3cc:	0ff7f793          	zext.b	a5,a5
 3d0:	4625                	li	a2,9
 3d2:	02f66863          	bltu	a2,a5,402 <atoi+0x44>
 3d6:	872a                	mv	a4,a0
  n = 0;
 3d8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3da:	0705                	addi	a4,a4,1
 3dc:	0025179b          	slliw	a5,a0,0x2
 3e0:	9fa9                	addw	a5,a5,a0
 3e2:	0017979b          	slliw	a5,a5,0x1
 3e6:	9fb5                	addw	a5,a5,a3
 3e8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3ec:	00074683          	lbu	a3,0(a4)
 3f0:	fd06879b          	addiw	a5,a3,-48
 3f4:	0ff7f793          	zext.b	a5,a5
 3f8:	fef671e3          	bgeu	a2,a5,3da <atoi+0x1c>
  return n;
}
 3fc:	6422                	ld	s0,8(sp)
 3fe:	0141                	addi	sp,sp,16
 400:	8082                	ret
  n = 0;
 402:	4501                	li	a0,0
 404:	bfe5                	j	3fc <atoi+0x3e>

0000000000000406 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 406:	1141                	addi	sp,sp,-16
 408:	e422                	sd	s0,8(sp)
 40a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 40c:	02b57463          	bgeu	a0,a1,434 <memmove+0x2e>
    while(n-- > 0)
 410:	00c05f63          	blez	a2,42e <memmove+0x28>
 414:	1602                	slli	a2,a2,0x20
 416:	9201                	srli	a2,a2,0x20
 418:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 41c:	872a                	mv	a4,a0
      *dst++ = *src++;
 41e:	0585                	addi	a1,a1,1
 420:	0705                	addi	a4,a4,1
 422:	fff5c683          	lbu	a3,-1(a1)
 426:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 42a:	fee79ae3          	bne	a5,a4,41e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 42e:	6422                	ld	s0,8(sp)
 430:	0141                	addi	sp,sp,16
 432:	8082                	ret
    dst += n;
 434:	00c50733          	add	a4,a0,a2
    src += n;
 438:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 43a:	fec05ae3          	blez	a2,42e <memmove+0x28>
 43e:	fff6079b          	addiw	a5,a2,-1
 442:	1782                	slli	a5,a5,0x20
 444:	9381                	srli	a5,a5,0x20
 446:	fff7c793          	not	a5,a5
 44a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 44c:	15fd                	addi	a1,a1,-1
 44e:	177d                	addi	a4,a4,-1
 450:	0005c683          	lbu	a3,0(a1)
 454:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 458:	fee79ae3          	bne	a5,a4,44c <memmove+0x46>
 45c:	bfc9                	j	42e <memmove+0x28>

000000000000045e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 45e:	1141                	addi	sp,sp,-16
 460:	e422                	sd	s0,8(sp)
 462:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 464:	ca05                	beqz	a2,494 <memcmp+0x36>
 466:	fff6069b          	addiw	a3,a2,-1
 46a:	1682                	slli	a3,a3,0x20
 46c:	9281                	srli	a3,a3,0x20
 46e:	0685                	addi	a3,a3,1
 470:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 472:	00054783          	lbu	a5,0(a0)
 476:	0005c703          	lbu	a4,0(a1)
 47a:	00e79863          	bne	a5,a4,48a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 47e:	0505                	addi	a0,a0,1
    p2++;
 480:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 482:	fed518e3          	bne	a0,a3,472 <memcmp+0x14>
  }
  return 0;
 486:	4501                	li	a0,0
 488:	a019                	j	48e <memcmp+0x30>
      return *p1 - *p2;
 48a:	40e7853b          	subw	a0,a5,a4
}
 48e:	6422                	ld	s0,8(sp)
 490:	0141                	addi	sp,sp,16
 492:	8082                	ret
  return 0;
 494:	4501                	li	a0,0
 496:	bfe5                	j	48e <memcmp+0x30>

0000000000000498 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 498:	1141                	addi	sp,sp,-16
 49a:	e406                	sd	ra,8(sp)
 49c:	e022                	sd	s0,0(sp)
 49e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4a0:	00000097          	auipc	ra,0x0
 4a4:	f66080e7          	jalr	-154(ra) # 406 <memmove>
}
 4a8:	60a2                	ld	ra,8(sp)
 4aa:	6402                	ld	s0,0(sp)
 4ac:	0141                	addi	sp,sp,16
 4ae:	8082                	ret

00000000000004b0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4b0:	4885                	li	a7,1
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4b8:	4889                	li	a7,2
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4c0:	488d                	li	a7,3
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4c8:	4891                	li	a7,4
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <read>:
.global read
read:
 li a7, SYS_read
 4d0:	4895                	li	a7,5
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <write>:
.global write
write:
 li a7, SYS_write
 4d8:	48c1                	li	a7,16
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <close>:
.global close
close:
 li a7, SYS_close
 4e0:	48d5                	li	a7,21
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4e8:	4899                	li	a7,6
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4f0:	489d                	li	a7,7
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <open>:
.global open
open:
 li a7, SYS_open
 4f8:	48bd                	li	a7,15
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 500:	48c5                	li	a7,17
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 508:	48c9                	li	a7,18
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 510:	48a1                	li	a7,8
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <link>:
.global link
link:
 li a7, SYS_link
 518:	48cd                	li	a7,19
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 520:	48d1                	li	a7,20
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 528:	48a5                	li	a7,9
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <dup>:
.global dup
dup:
 li a7, SYS_dup
 530:	48a9                	li	a7,10
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 538:	48ad                	li	a7,11
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 540:	48b1                	li	a7,12
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 548:	48b5                	li	a7,13
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 550:	48b9                	li	a7,14
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <btput>:
.global btput
btput:
 li a7, SYS_btput
 558:	48d9                	li	a7,22
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <tput>:
.global tput
tput:
 li a7, SYS_tput
 560:	48dd                	li	a7,23
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <btget>:
.global btget
btget:
 li a7, SYS_btget
 568:	48e1                	li	a7,24
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <tget>:
.global tget
tget:
 li a7, SYS_tget
 570:	48e5                	li	a7,25
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 578:	1101                	addi	sp,sp,-32
 57a:	ec06                	sd	ra,24(sp)
 57c:	e822                	sd	s0,16(sp)
 57e:	1000                	addi	s0,sp,32
 580:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 584:	4605                	li	a2,1
 586:	fef40593          	addi	a1,s0,-17
 58a:	00000097          	auipc	ra,0x0
 58e:	f4e080e7          	jalr	-178(ra) # 4d8 <write>
}
 592:	60e2                	ld	ra,24(sp)
 594:	6442                	ld	s0,16(sp)
 596:	6105                	addi	sp,sp,32
 598:	8082                	ret

000000000000059a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 59a:	7139                	addi	sp,sp,-64
 59c:	fc06                	sd	ra,56(sp)
 59e:	f822                	sd	s0,48(sp)
 5a0:	f426                	sd	s1,40(sp)
 5a2:	f04a                	sd	s2,32(sp)
 5a4:	ec4e                	sd	s3,24(sp)
 5a6:	0080                	addi	s0,sp,64
 5a8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5aa:	c299                	beqz	a3,5b0 <printint+0x16>
 5ac:	0805c963          	bltz	a1,63e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5b0:	2581                	sext.w	a1,a1
  neg = 0;
 5b2:	4881                	li	a7,0
 5b4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5b8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5ba:	2601                	sext.w	a2,a2
 5bc:	00000517          	auipc	a0,0x0
 5c0:	56c50513          	addi	a0,a0,1388 # b28 <digits>
 5c4:	883a                	mv	a6,a4
 5c6:	2705                	addiw	a4,a4,1
 5c8:	02c5f7bb          	remuw	a5,a1,a2
 5cc:	1782                	slli	a5,a5,0x20
 5ce:	9381                	srli	a5,a5,0x20
 5d0:	97aa                	add	a5,a5,a0
 5d2:	0007c783          	lbu	a5,0(a5)
 5d6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5da:	0005879b          	sext.w	a5,a1
 5de:	02c5d5bb          	divuw	a1,a1,a2
 5e2:	0685                	addi	a3,a3,1
 5e4:	fec7f0e3          	bgeu	a5,a2,5c4 <printint+0x2a>
  if(neg)
 5e8:	00088c63          	beqz	a7,600 <printint+0x66>
    buf[i++] = '-';
 5ec:	fd070793          	addi	a5,a4,-48
 5f0:	00878733          	add	a4,a5,s0
 5f4:	02d00793          	li	a5,45
 5f8:	fef70823          	sb	a5,-16(a4)
 5fc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 600:	02e05863          	blez	a4,630 <printint+0x96>
 604:	fc040793          	addi	a5,s0,-64
 608:	00e78933          	add	s2,a5,a4
 60c:	fff78993          	addi	s3,a5,-1
 610:	99ba                	add	s3,s3,a4
 612:	377d                	addiw	a4,a4,-1
 614:	1702                	slli	a4,a4,0x20
 616:	9301                	srli	a4,a4,0x20
 618:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 61c:	fff94583          	lbu	a1,-1(s2)
 620:	8526                	mv	a0,s1
 622:	00000097          	auipc	ra,0x0
 626:	f56080e7          	jalr	-170(ra) # 578 <putc>
  while(--i >= 0)
 62a:	197d                	addi	s2,s2,-1
 62c:	ff3918e3          	bne	s2,s3,61c <printint+0x82>
}
 630:	70e2                	ld	ra,56(sp)
 632:	7442                	ld	s0,48(sp)
 634:	74a2                	ld	s1,40(sp)
 636:	7902                	ld	s2,32(sp)
 638:	69e2                	ld	s3,24(sp)
 63a:	6121                	addi	sp,sp,64
 63c:	8082                	ret
    x = -xx;
 63e:	40b005bb          	negw	a1,a1
    neg = 1;
 642:	4885                	li	a7,1
    x = -xx;
 644:	bf85                	j	5b4 <printint+0x1a>

0000000000000646 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 646:	7119                	addi	sp,sp,-128
 648:	fc86                	sd	ra,120(sp)
 64a:	f8a2                	sd	s0,112(sp)
 64c:	f4a6                	sd	s1,104(sp)
 64e:	f0ca                	sd	s2,96(sp)
 650:	ecce                	sd	s3,88(sp)
 652:	e8d2                	sd	s4,80(sp)
 654:	e4d6                	sd	s5,72(sp)
 656:	e0da                	sd	s6,64(sp)
 658:	fc5e                	sd	s7,56(sp)
 65a:	f862                	sd	s8,48(sp)
 65c:	f466                	sd	s9,40(sp)
 65e:	f06a                	sd	s10,32(sp)
 660:	ec6e                	sd	s11,24(sp)
 662:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 664:	0005c903          	lbu	s2,0(a1)
 668:	18090f63          	beqz	s2,806 <vprintf+0x1c0>
 66c:	8aaa                	mv	s5,a0
 66e:	8b32                	mv	s6,a2
 670:	00158493          	addi	s1,a1,1
  state = 0;
 674:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 676:	02500a13          	li	s4,37
 67a:	4c55                	li	s8,21
 67c:	00000c97          	auipc	s9,0x0
 680:	454c8c93          	addi	s9,s9,1108 # ad0 <malloc+0x1c6>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 684:	02800d93          	li	s11,40
  putc(fd, 'x');
 688:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 68a:	00000b97          	auipc	s7,0x0
 68e:	49eb8b93          	addi	s7,s7,1182 # b28 <digits>
 692:	a839                	j	6b0 <vprintf+0x6a>
        putc(fd, c);
 694:	85ca                	mv	a1,s2
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	ee0080e7          	jalr	-288(ra) # 578 <putc>
 6a0:	a019                	j	6a6 <vprintf+0x60>
    } else if(state == '%'){
 6a2:	01498d63          	beq	s3,s4,6bc <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 6a6:	0485                	addi	s1,s1,1
 6a8:	fff4c903          	lbu	s2,-1(s1)
 6ac:	14090d63          	beqz	s2,806 <vprintf+0x1c0>
    if(state == 0){
 6b0:	fe0999e3          	bnez	s3,6a2 <vprintf+0x5c>
      if(c == '%'){
 6b4:	ff4910e3          	bne	s2,s4,694 <vprintf+0x4e>
        state = '%';
 6b8:	89d2                	mv	s3,s4
 6ba:	b7f5                	j	6a6 <vprintf+0x60>
      if(c == 'd'){
 6bc:	11490c63          	beq	s2,s4,7d4 <vprintf+0x18e>
 6c0:	f9d9079b          	addiw	a5,s2,-99
 6c4:	0ff7f793          	zext.b	a5,a5
 6c8:	10fc6e63          	bltu	s8,a5,7e4 <vprintf+0x19e>
 6cc:	f9d9079b          	addiw	a5,s2,-99
 6d0:	0ff7f713          	zext.b	a4,a5
 6d4:	10ec6863          	bltu	s8,a4,7e4 <vprintf+0x19e>
 6d8:	00271793          	slli	a5,a4,0x2
 6dc:	97e6                	add	a5,a5,s9
 6de:	439c                	lw	a5,0(a5)
 6e0:	97e6                	add	a5,a5,s9
 6e2:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6e4:	008b0913          	addi	s2,s6,8
 6e8:	4685                	li	a3,1
 6ea:	4629                	li	a2,10
 6ec:	000b2583          	lw	a1,0(s6)
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	ea8080e7          	jalr	-344(ra) # 59a <printint>
 6fa:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	b765                	j	6a6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 700:	008b0913          	addi	s2,s6,8
 704:	4681                	li	a3,0
 706:	4629                	li	a2,10
 708:	000b2583          	lw	a1,0(s6)
 70c:	8556                	mv	a0,s5
 70e:	00000097          	auipc	ra,0x0
 712:	e8c080e7          	jalr	-372(ra) # 59a <printint>
 716:	8b4a                	mv	s6,s2
      state = 0;
 718:	4981                	li	s3,0
 71a:	b771                	j	6a6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 71c:	008b0913          	addi	s2,s6,8
 720:	4681                	li	a3,0
 722:	866a                	mv	a2,s10
 724:	000b2583          	lw	a1,0(s6)
 728:	8556                	mv	a0,s5
 72a:	00000097          	auipc	ra,0x0
 72e:	e70080e7          	jalr	-400(ra) # 59a <printint>
 732:	8b4a                	mv	s6,s2
      state = 0;
 734:	4981                	li	s3,0
 736:	bf85                	j	6a6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 738:	008b0793          	addi	a5,s6,8
 73c:	f8f43423          	sd	a5,-120(s0)
 740:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 744:	03000593          	li	a1,48
 748:	8556                	mv	a0,s5
 74a:	00000097          	auipc	ra,0x0
 74e:	e2e080e7          	jalr	-466(ra) # 578 <putc>
  putc(fd, 'x');
 752:	07800593          	li	a1,120
 756:	8556                	mv	a0,s5
 758:	00000097          	auipc	ra,0x0
 75c:	e20080e7          	jalr	-480(ra) # 578 <putc>
 760:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 762:	03c9d793          	srli	a5,s3,0x3c
 766:	97de                	add	a5,a5,s7
 768:	0007c583          	lbu	a1,0(a5)
 76c:	8556                	mv	a0,s5
 76e:	00000097          	auipc	ra,0x0
 772:	e0a080e7          	jalr	-502(ra) # 578 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 776:	0992                	slli	s3,s3,0x4
 778:	397d                	addiw	s2,s2,-1
 77a:	fe0914e3          	bnez	s2,762 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 77e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 782:	4981                	li	s3,0
 784:	b70d                	j	6a6 <vprintf+0x60>
        s = va_arg(ap, char*);
 786:	008b0913          	addi	s2,s6,8
 78a:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 78e:	02098163          	beqz	s3,7b0 <vprintf+0x16a>
        while(*s != 0){
 792:	0009c583          	lbu	a1,0(s3)
 796:	c5ad                	beqz	a1,800 <vprintf+0x1ba>
          putc(fd, *s);
 798:	8556                	mv	a0,s5
 79a:	00000097          	auipc	ra,0x0
 79e:	dde080e7          	jalr	-546(ra) # 578 <putc>
          s++;
 7a2:	0985                	addi	s3,s3,1
        while(*s != 0){
 7a4:	0009c583          	lbu	a1,0(s3)
 7a8:	f9e5                	bnez	a1,798 <vprintf+0x152>
        s = va_arg(ap, char*);
 7aa:	8b4a                	mv	s6,s2
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	bde5                	j	6a6 <vprintf+0x60>
          s = "(null)";
 7b0:	00000997          	auipc	s3,0x0
 7b4:	31898993          	addi	s3,s3,792 # ac8 <malloc+0x1be>
        while(*s != 0){
 7b8:	85ee                	mv	a1,s11
 7ba:	bff9                	j	798 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 7bc:	008b0913          	addi	s2,s6,8
 7c0:	000b4583          	lbu	a1,0(s6)
 7c4:	8556                	mv	a0,s5
 7c6:	00000097          	auipc	ra,0x0
 7ca:	db2080e7          	jalr	-590(ra) # 578 <putc>
 7ce:	8b4a                	mv	s6,s2
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	bdd1                	j	6a6 <vprintf+0x60>
        putc(fd, c);
 7d4:	85d2                	mv	a1,s4
 7d6:	8556                	mv	a0,s5
 7d8:	00000097          	auipc	ra,0x0
 7dc:	da0080e7          	jalr	-608(ra) # 578 <putc>
      state = 0;
 7e0:	4981                	li	s3,0
 7e2:	b5d1                	j	6a6 <vprintf+0x60>
        putc(fd, '%');
 7e4:	85d2                	mv	a1,s4
 7e6:	8556                	mv	a0,s5
 7e8:	00000097          	auipc	ra,0x0
 7ec:	d90080e7          	jalr	-624(ra) # 578 <putc>
        putc(fd, c);
 7f0:	85ca                	mv	a1,s2
 7f2:	8556                	mv	a0,s5
 7f4:	00000097          	auipc	ra,0x0
 7f8:	d84080e7          	jalr	-636(ra) # 578 <putc>
      state = 0;
 7fc:	4981                	li	s3,0
 7fe:	b565                	j	6a6 <vprintf+0x60>
        s = va_arg(ap, char*);
 800:	8b4a                	mv	s6,s2
      state = 0;
 802:	4981                	li	s3,0
 804:	b54d                	j	6a6 <vprintf+0x60>
    }
  }
}
 806:	70e6                	ld	ra,120(sp)
 808:	7446                	ld	s0,112(sp)
 80a:	74a6                	ld	s1,104(sp)
 80c:	7906                	ld	s2,96(sp)
 80e:	69e6                	ld	s3,88(sp)
 810:	6a46                	ld	s4,80(sp)
 812:	6aa6                	ld	s5,72(sp)
 814:	6b06                	ld	s6,64(sp)
 816:	7be2                	ld	s7,56(sp)
 818:	7c42                	ld	s8,48(sp)
 81a:	7ca2                	ld	s9,40(sp)
 81c:	7d02                	ld	s10,32(sp)
 81e:	6de2                	ld	s11,24(sp)
 820:	6109                	addi	sp,sp,128
 822:	8082                	ret

0000000000000824 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 824:	715d                	addi	sp,sp,-80
 826:	ec06                	sd	ra,24(sp)
 828:	e822                	sd	s0,16(sp)
 82a:	1000                	addi	s0,sp,32
 82c:	e010                	sd	a2,0(s0)
 82e:	e414                	sd	a3,8(s0)
 830:	e818                	sd	a4,16(s0)
 832:	ec1c                	sd	a5,24(s0)
 834:	03043023          	sd	a6,32(s0)
 838:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 83c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 840:	8622                	mv	a2,s0
 842:	00000097          	auipc	ra,0x0
 846:	e04080e7          	jalr	-508(ra) # 646 <vprintf>
}
 84a:	60e2                	ld	ra,24(sp)
 84c:	6442                	ld	s0,16(sp)
 84e:	6161                	addi	sp,sp,80
 850:	8082                	ret

0000000000000852 <printf>:

void
printf(const char *fmt, ...)
{
 852:	711d                	addi	sp,sp,-96
 854:	ec06                	sd	ra,24(sp)
 856:	e822                	sd	s0,16(sp)
 858:	1000                	addi	s0,sp,32
 85a:	e40c                	sd	a1,8(s0)
 85c:	e810                	sd	a2,16(s0)
 85e:	ec14                	sd	a3,24(s0)
 860:	f018                	sd	a4,32(s0)
 862:	f41c                	sd	a5,40(s0)
 864:	03043823          	sd	a6,48(s0)
 868:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 86c:	00840613          	addi	a2,s0,8
 870:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 874:	85aa                	mv	a1,a0
 876:	4505                	li	a0,1
 878:	00000097          	auipc	ra,0x0
 87c:	dce080e7          	jalr	-562(ra) # 646 <vprintf>
}
 880:	60e2                	ld	ra,24(sp)
 882:	6442                	ld	s0,16(sp)
 884:	6125                	addi	sp,sp,96
 886:	8082                	ret

0000000000000888 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 888:	1141                	addi	sp,sp,-16
 88a:	e422                	sd	s0,8(sp)
 88c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 88e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 892:	00000797          	auipc	a5,0x0
 896:	2ae7b783          	ld	a5,686(a5) # b40 <freep>
 89a:	a02d                	j	8c4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 89c:	4618                	lw	a4,8(a2)
 89e:	9f2d                	addw	a4,a4,a1
 8a0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a4:	6398                	ld	a4,0(a5)
 8a6:	6310                	ld	a2,0(a4)
 8a8:	a83d                	j	8e6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8aa:	ff852703          	lw	a4,-8(a0)
 8ae:	9f31                	addw	a4,a4,a2
 8b0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8b2:	ff053683          	ld	a3,-16(a0)
 8b6:	a091                	j	8fa <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b8:	6398                	ld	a4,0(a5)
 8ba:	00e7e463          	bltu	a5,a4,8c2 <free+0x3a>
 8be:	00e6ea63          	bltu	a3,a4,8d2 <free+0x4a>
{
 8c2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c4:	fed7fae3          	bgeu	a5,a3,8b8 <free+0x30>
 8c8:	6398                	ld	a4,0(a5)
 8ca:	00e6e463          	bltu	a3,a4,8d2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ce:	fee7eae3          	bltu	a5,a4,8c2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8d2:	ff852583          	lw	a1,-8(a0)
 8d6:	6390                	ld	a2,0(a5)
 8d8:	02059813          	slli	a6,a1,0x20
 8dc:	01c85713          	srli	a4,a6,0x1c
 8e0:	9736                	add	a4,a4,a3
 8e2:	fae60de3          	beq	a2,a4,89c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8e6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8ea:	4790                	lw	a2,8(a5)
 8ec:	02061593          	slli	a1,a2,0x20
 8f0:	01c5d713          	srli	a4,a1,0x1c
 8f4:	973e                	add	a4,a4,a5
 8f6:	fae68ae3          	beq	a3,a4,8aa <free+0x22>
    p->s.ptr = bp->s.ptr;
 8fa:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8fc:	00000717          	auipc	a4,0x0
 900:	24f73223          	sd	a5,580(a4) # b40 <freep>
}
 904:	6422                	ld	s0,8(sp)
 906:	0141                	addi	sp,sp,16
 908:	8082                	ret

000000000000090a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 90a:	7139                	addi	sp,sp,-64
 90c:	fc06                	sd	ra,56(sp)
 90e:	f822                	sd	s0,48(sp)
 910:	f426                	sd	s1,40(sp)
 912:	f04a                	sd	s2,32(sp)
 914:	ec4e                	sd	s3,24(sp)
 916:	e852                	sd	s4,16(sp)
 918:	e456                	sd	s5,8(sp)
 91a:	e05a                	sd	s6,0(sp)
 91c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 91e:	02051493          	slli	s1,a0,0x20
 922:	9081                	srli	s1,s1,0x20
 924:	04bd                	addi	s1,s1,15
 926:	8091                	srli	s1,s1,0x4
 928:	0014899b          	addiw	s3,s1,1
 92c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 92e:	00000517          	auipc	a0,0x0
 932:	21253503          	ld	a0,530(a0) # b40 <freep>
 936:	c515                	beqz	a0,962 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 938:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 93a:	4798                	lw	a4,8(a5)
 93c:	02977f63          	bgeu	a4,s1,97a <malloc+0x70>
 940:	8a4e                	mv	s4,s3
 942:	0009871b          	sext.w	a4,s3
 946:	6685                	lui	a3,0x1
 948:	00d77363          	bgeu	a4,a3,94e <malloc+0x44>
 94c:	6a05                	lui	s4,0x1
 94e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 952:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 956:	00000917          	auipc	s2,0x0
 95a:	1ea90913          	addi	s2,s2,490 # b40 <freep>
  if(p == (char*)-1)
 95e:	5afd                	li	s5,-1
 960:	a895                	j	9d4 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 962:	00000797          	auipc	a5,0x0
 966:	1e678793          	addi	a5,a5,486 # b48 <base>
 96a:	00000717          	auipc	a4,0x0
 96e:	1cf73b23          	sd	a5,470(a4) # b40 <freep>
 972:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 974:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 978:	b7e1                	j	940 <malloc+0x36>
      if(p->s.size == nunits)
 97a:	02e48c63          	beq	s1,a4,9b2 <malloc+0xa8>
        p->s.size -= nunits;
 97e:	4137073b          	subw	a4,a4,s3
 982:	c798                	sw	a4,8(a5)
        p += p->s.size;
 984:	02071693          	slli	a3,a4,0x20
 988:	01c6d713          	srli	a4,a3,0x1c
 98c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 98e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 992:	00000717          	auipc	a4,0x0
 996:	1aa73723          	sd	a0,430(a4) # b40 <freep>
      return (void*)(p + 1);
 99a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 99e:	70e2                	ld	ra,56(sp)
 9a0:	7442                	ld	s0,48(sp)
 9a2:	74a2                	ld	s1,40(sp)
 9a4:	7902                	ld	s2,32(sp)
 9a6:	69e2                	ld	s3,24(sp)
 9a8:	6a42                	ld	s4,16(sp)
 9aa:	6aa2                	ld	s5,8(sp)
 9ac:	6b02                	ld	s6,0(sp)
 9ae:	6121                	addi	sp,sp,64
 9b0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9b2:	6398                	ld	a4,0(a5)
 9b4:	e118                	sd	a4,0(a0)
 9b6:	bff1                	j	992 <malloc+0x88>
  hp->s.size = nu;
 9b8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9bc:	0541                	addi	a0,a0,16
 9be:	00000097          	auipc	ra,0x0
 9c2:	eca080e7          	jalr	-310(ra) # 888 <free>
  return freep;
 9c6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9ca:	d971                	beqz	a0,99e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9cc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ce:	4798                	lw	a4,8(a5)
 9d0:	fa9775e3          	bgeu	a4,s1,97a <malloc+0x70>
    if(p == freep)
 9d4:	00093703          	ld	a4,0(s2)
 9d8:	853e                	mv	a0,a5
 9da:	fef719e3          	bne	a4,a5,9cc <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9de:	8552                	mv	a0,s4
 9e0:	00000097          	auipc	ra,0x0
 9e4:	b60080e7          	jalr	-1184(ra) # 540 <sbrk>
  if(p == (char*)-1)
 9e8:	fd5518e3          	bne	a0,s5,9b8 <malloc+0xae>
        return 0;
 9ec:	4501                	li	a0,0
 9ee:	bf45                	j	99e <malloc+0x94>
