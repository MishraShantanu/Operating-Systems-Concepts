
user/_ln:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  if(argc != 3){
   a:	478d                	li	a5,3
   c:	02f50063          	beq	a0,a5,2c <main+0x2c>
    fprintf(2, "Usage: ln old new\n");
  10:	00000597          	auipc	a1,0x0
  14:	7f858593          	addi	a1,a1,2040 # 808 <malloc+0xea>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	61e080e7          	jalr	1566(ra) # 638 <fprintf>
    exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	2a8080e7          	jalr	680(ra) # 2cc <exit>
  2c:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  2e:	698c                	ld	a1,16(a1)
  30:	6488                	ld	a0,8(s1)
  32:	00000097          	auipc	ra,0x0
  36:	2fa080e7          	jalr	762(ra) # 32c <link>
  3a:	00054763          	bltz	a0,48 <main+0x48>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	28c080e7          	jalr	652(ra) # 2cc <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  48:	6894                	ld	a3,16(s1)
  4a:	6490                	ld	a2,8(s1)
  4c:	00000597          	auipc	a1,0x0
  50:	7d458593          	addi	a1,a1,2004 # 820 <malloc+0x102>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	5e2080e7          	jalr	1506(ra) # 638 <fprintf>
  5e:	b7c5                	j	3e <main+0x3e>

0000000000000060 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  60:	1141                	addi	sp,sp,-16
  62:	e422                	sd	s0,8(sp)
  64:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  66:	87aa                	mv	a5,a0
  68:	0585                	addi	a1,a1,1
  6a:	0785                	addi	a5,a5,1
  6c:	fff5c703          	lbu	a4,-1(a1)
  70:	fee78fa3          	sb	a4,-1(a5)
  74:	fb75                	bnez	a4,68 <strcpy+0x8>
    ;
  return os;
}
  76:	6422                	ld	s0,8(sp)
  78:	0141                	addi	sp,sp,16
  7a:	8082                	ret

000000000000007c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e422                	sd	s0,8(sp)
  80:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  82:	00054783          	lbu	a5,0(a0)
  86:	cb91                	beqz	a5,9a <strcmp+0x1e>
  88:	0005c703          	lbu	a4,0(a1)
  8c:	00f71763          	bne	a4,a5,9a <strcmp+0x1e>
    p++, q++;
  90:	0505                	addi	a0,a0,1
  92:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  94:	00054783          	lbu	a5,0(a0)
  98:	fbe5                	bnez	a5,88 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  9a:	0005c503          	lbu	a0,0(a1)
}
  9e:	40a7853b          	subw	a0,a5,a0
  a2:	6422                	ld	s0,8(sp)
  a4:	0141                	addi	sp,sp,16
  a6:	8082                	ret

00000000000000a8 <strlen>:

uint
strlen(const char *s)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ae:	00054783          	lbu	a5,0(a0)
  b2:	cf91                	beqz	a5,ce <strlen+0x26>
  b4:	0505                	addi	a0,a0,1
  b6:	87aa                	mv	a5,a0
  b8:	4685                	li	a3,1
  ba:	9e89                	subw	a3,a3,a0
  bc:	00f6853b          	addw	a0,a3,a5
  c0:	0785                	addi	a5,a5,1
  c2:	fff7c703          	lbu	a4,-1(a5)
  c6:	fb7d                	bnez	a4,bc <strlen+0x14>
    ;
  return n;
}
  c8:	6422                	ld	s0,8(sp)
  ca:	0141                	addi	sp,sp,16
  cc:	8082                	ret
  for(n = 0; s[n]; n++)
  ce:	4501                	li	a0,0
  d0:	bfe5                	j	c8 <strlen+0x20>

00000000000000d2 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d2:	1141                	addi	sp,sp,-16
  d4:	e422                	sd	s0,8(sp)
  d6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d8:	ca19                	beqz	a2,ee <memset+0x1c>
  da:	87aa                	mv	a5,a0
  dc:	1602                	slli	a2,a2,0x20
  de:	9201                	srli	a2,a2,0x20
  e0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e8:	0785                	addi	a5,a5,1
  ea:	fee79de3          	bne	a5,a4,e4 <memset+0x12>
  }
  return dst;
}
  ee:	6422                	ld	s0,8(sp)
  f0:	0141                	addi	sp,sp,16
  f2:	8082                	ret

00000000000000f4 <strchr>:

char*
strchr(const char *s, char c)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e422                	sd	s0,8(sp)
  f8:	0800                	addi	s0,sp,16
  for(; *s; s++)
  fa:	00054783          	lbu	a5,0(a0)
  fe:	cb99                	beqz	a5,114 <strchr+0x20>
    if(*s == c)
 100:	00f58763          	beq	a1,a5,10e <strchr+0x1a>
  for(; *s; s++)
 104:	0505                	addi	a0,a0,1
 106:	00054783          	lbu	a5,0(a0)
 10a:	fbfd                	bnez	a5,100 <strchr+0xc>
      return (char*)s;
  return 0;
 10c:	4501                	li	a0,0
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret
  return 0;
 114:	4501                	li	a0,0
 116:	bfe5                	j	10e <strchr+0x1a>

0000000000000118 <gets>:

char*
gets(char *buf, int max)
{
 118:	711d                	addi	sp,sp,-96
 11a:	ec86                	sd	ra,88(sp)
 11c:	e8a2                	sd	s0,80(sp)
 11e:	e4a6                	sd	s1,72(sp)
 120:	e0ca                	sd	s2,64(sp)
 122:	fc4e                	sd	s3,56(sp)
 124:	f852                	sd	s4,48(sp)
 126:	f456                	sd	s5,40(sp)
 128:	f05a                	sd	s6,32(sp)
 12a:	ec5e                	sd	s7,24(sp)
 12c:	1080                	addi	s0,sp,96
 12e:	8baa                	mv	s7,a0
 130:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 132:	892a                	mv	s2,a0
 134:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 136:	4aa9                	li	s5,10
 138:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 13a:	89a6                	mv	s3,s1
 13c:	2485                	addiw	s1,s1,1
 13e:	0344d863          	bge	s1,s4,16e <gets+0x56>
    cc = read(0, &c, 1);
 142:	4605                	li	a2,1
 144:	faf40593          	addi	a1,s0,-81
 148:	4501                	li	a0,0
 14a:	00000097          	auipc	ra,0x0
 14e:	19a080e7          	jalr	410(ra) # 2e4 <read>
    if(cc < 1)
 152:	00a05e63          	blez	a0,16e <gets+0x56>
    buf[i++] = c;
 156:	faf44783          	lbu	a5,-81(s0)
 15a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 15e:	01578763          	beq	a5,s5,16c <gets+0x54>
 162:	0905                	addi	s2,s2,1
 164:	fd679be3          	bne	a5,s6,13a <gets+0x22>
  for(i=0; i+1 < max; ){
 168:	89a6                	mv	s3,s1
 16a:	a011                	j	16e <gets+0x56>
 16c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 16e:	99de                	add	s3,s3,s7
 170:	00098023          	sb	zero,0(s3)
  return buf;
}
 174:	855e                	mv	a0,s7
 176:	60e6                	ld	ra,88(sp)
 178:	6446                	ld	s0,80(sp)
 17a:	64a6                	ld	s1,72(sp)
 17c:	6906                	ld	s2,64(sp)
 17e:	79e2                	ld	s3,56(sp)
 180:	7a42                	ld	s4,48(sp)
 182:	7aa2                	ld	s5,40(sp)
 184:	7b02                	ld	s6,32(sp)
 186:	6be2                	ld	s7,24(sp)
 188:	6125                	addi	sp,sp,96
 18a:	8082                	ret

000000000000018c <stat>:

int
stat(const char *n, struct stat *st)
{
 18c:	1101                	addi	sp,sp,-32
 18e:	ec06                	sd	ra,24(sp)
 190:	e822                	sd	s0,16(sp)
 192:	e426                	sd	s1,8(sp)
 194:	e04a                	sd	s2,0(sp)
 196:	1000                	addi	s0,sp,32
 198:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19a:	4581                	li	a1,0
 19c:	00000097          	auipc	ra,0x0
 1a0:	170080e7          	jalr	368(ra) # 30c <open>
  if(fd < 0)
 1a4:	02054563          	bltz	a0,1ce <stat+0x42>
 1a8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1aa:	85ca                	mv	a1,s2
 1ac:	00000097          	auipc	ra,0x0
 1b0:	178080e7          	jalr	376(ra) # 324 <fstat>
 1b4:	892a                	mv	s2,a0
  close(fd);
 1b6:	8526                	mv	a0,s1
 1b8:	00000097          	auipc	ra,0x0
 1bc:	13c080e7          	jalr	316(ra) # 2f4 <close>
  return r;
}
 1c0:	854a                	mv	a0,s2
 1c2:	60e2                	ld	ra,24(sp)
 1c4:	6442                	ld	s0,16(sp)
 1c6:	64a2                	ld	s1,8(sp)
 1c8:	6902                	ld	s2,0(sp)
 1ca:	6105                	addi	sp,sp,32
 1cc:	8082                	ret
    return -1;
 1ce:	597d                	li	s2,-1
 1d0:	bfc5                	j	1c0 <stat+0x34>

00000000000001d2 <atoi>:

int
atoi(const char *s)
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e422                	sd	s0,8(sp)
 1d6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1d8:	00054683          	lbu	a3,0(a0)
 1dc:	fd06879b          	addiw	a5,a3,-48
 1e0:	0ff7f793          	zext.b	a5,a5
 1e4:	4625                	li	a2,9
 1e6:	02f66863          	bltu	a2,a5,216 <atoi+0x44>
 1ea:	872a                	mv	a4,a0
  n = 0;
 1ec:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1ee:	0705                	addi	a4,a4,1
 1f0:	0025179b          	slliw	a5,a0,0x2
 1f4:	9fa9                	addw	a5,a5,a0
 1f6:	0017979b          	slliw	a5,a5,0x1
 1fa:	9fb5                	addw	a5,a5,a3
 1fc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 200:	00074683          	lbu	a3,0(a4)
 204:	fd06879b          	addiw	a5,a3,-48
 208:	0ff7f793          	zext.b	a5,a5
 20c:	fef671e3          	bgeu	a2,a5,1ee <atoi+0x1c>
  return n;
}
 210:	6422                	ld	s0,8(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret
  n = 0;
 216:	4501                	li	a0,0
 218:	bfe5                	j	210 <atoi+0x3e>

000000000000021a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 21a:	1141                	addi	sp,sp,-16
 21c:	e422                	sd	s0,8(sp)
 21e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 220:	02b57463          	bgeu	a0,a1,248 <memmove+0x2e>
    while(n-- > 0)
 224:	00c05f63          	blez	a2,242 <memmove+0x28>
 228:	1602                	slli	a2,a2,0x20
 22a:	9201                	srli	a2,a2,0x20
 22c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 230:	872a                	mv	a4,a0
      *dst++ = *src++;
 232:	0585                	addi	a1,a1,1
 234:	0705                	addi	a4,a4,1
 236:	fff5c683          	lbu	a3,-1(a1)
 23a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 23e:	fee79ae3          	bne	a5,a4,232 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret
    dst += n;
 248:	00c50733          	add	a4,a0,a2
    src += n;
 24c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 24e:	fec05ae3          	blez	a2,242 <memmove+0x28>
 252:	fff6079b          	addiw	a5,a2,-1
 256:	1782                	slli	a5,a5,0x20
 258:	9381                	srli	a5,a5,0x20
 25a:	fff7c793          	not	a5,a5
 25e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 260:	15fd                	addi	a1,a1,-1
 262:	177d                	addi	a4,a4,-1
 264:	0005c683          	lbu	a3,0(a1)
 268:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 26c:	fee79ae3          	bne	a5,a4,260 <memmove+0x46>
 270:	bfc9                	j	242 <memmove+0x28>

0000000000000272 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 272:	1141                	addi	sp,sp,-16
 274:	e422                	sd	s0,8(sp)
 276:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 278:	ca05                	beqz	a2,2a8 <memcmp+0x36>
 27a:	fff6069b          	addiw	a3,a2,-1
 27e:	1682                	slli	a3,a3,0x20
 280:	9281                	srli	a3,a3,0x20
 282:	0685                	addi	a3,a3,1
 284:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 286:	00054783          	lbu	a5,0(a0)
 28a:	0005c703          	lbu	a4,0(a1)
 28e:	00e79863          	bne	a5,a4,29e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 292:	0505                	addi	a0,a0,1
    p2++;
 294:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 296:	fed518e3          	bne	a0,a3,286 <memcmp+0x14>
  }
  return 0;
 29a:	4501                	li	a0,0
 29c:	a019                	j	2a2 <memcmp+0x30>
      return *p1 - *p2;
 29e:	40e7853b          	subw	a0,a5,a4
}
 2a2:	6422                	ld	s0,8(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret
  return 0;
 2a8:	4501                	li	a0,0
 2aa:	bfe5                	j	2a2 <memcmp+0x30>

00000000000002ac <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e406                	sd	ra,8(sp)
 2b0:	e022                	sd	s0,0(sp)
 2b2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2b4:	00000097          	auipc	ra,0x0
 2b8:	f66080e7          	jalr	-154(ra) # 21a <memmove>
}
 2bc:	60a2                	ld	ra,8(sp)
 2be:	6402                	ld	s0,0(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret

00000000000002c4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2c4:	4885                	li	a7,1
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <exit>:
.global exit
exit:
 li a7, SYS_exit
 2cc:	4889                	li	a7,2
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2d4:	488d                	li	a7,3
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2dc:	4891                	li	a7,4
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <read>:
.global read
read:
 li a7, SYS_read
 2e4:	4895                	li	a7,5
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <write>:
.global write
write:
 li a7, SYS_write
 2ec:	48c1                	li	a7,16
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <close>:
.global close
close:
 li a7, SYS_close
 2f4:	48d5                	li	a7,21
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <kill>:
.global kill
kill:
 li a7, SYS_kill
 2fc:	4899                	li	a7,6
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <exec>:
.global exec
exec:
 li a7, SYS_exec
 304:	489d                	li	a7,7
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <open>:
.global open
open:
 li a7, SYS_open
 30c:	48bd                	li	a7,15
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 314:	48c5                	li	a7,17
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 31c:	48c9                	li	a7,18
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 324:	48a1                	li	a7,8
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <link>:
.global link
link:
 li a7, SYS_link
 32c:	48cd                	li	a7,19
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 334:	48d1                	li	a7,20
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 33c:	48a5                	li	a7,9
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <dup>:
.global dup
dup:
 li a7, SYS_dup
 344:	48a9                	li	a7,10
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 34c:	48ad                	li	a7,11
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 354:	48b1                	li	a7,12
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 35c:	48b5                	li	a7,13
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 364:	48b9                	li	a7,14
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <btput>:
.global btput
btput:
 li a7, SYS_btput
 36c:	48d9                	li	a7,22
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <tput>:
.global tput
tput:
 li a7, SYS_tput
 374:	48dd                	li	a7,23
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <btget>:
.global btget
btget:
 li a7, SYS_btget
 37c:	48e1                	li	a7,24
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <tget>:
.global tget
tget:
 li a7, SYS_tget
 384:	48e5                	li	a7,25
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 38c:	1101                	addi	sp,sp,-32
 38e:	ec06                	sd	ra,24(sp)
 390:	e822                	sd	s0,16(sp)
 392:	1000                	addi	s0,sp,32
 394:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 398:	4605                	li	a2,1
 39a:	fef40593          	addi	a1,s0,-17
 39e:	00000097          	auipc	ra,0x0
 3a2:	f4e080e7          	jalr	-178(ra) # 2ec <write>
}
 3a6:	60e2                	ld	ra,24(sp)
 3a8:	6442                	ld	s0,16(sp)
 3aa:	6105                	addi	sp,sp,32
 3ac:	8082                	ret

00000000000003ae <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ae:	7139                	addi	sp,sp,-64
 3b0:	fc06                	sd	ra,56(sp)
 3b2:	f822                	sd	s0,48(sp)
 3b4:	f426                	sd	s1,40(sp)
 3b6:	f04a                	sd	s2,32(sp)
 3b8:	ec4e                	sd	s3,24(sp)
 3ba:	0080                	addi	s0,sp,64
 3bc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3be:	c299                	beqz	a3,3c4 <printint+0x16>
 3c0:	0805c963          	bltz	a1,452 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3c4:	2581                	sext.w	a1,a1
  neg = 0;
 3c6:	4881                	li	a7,0
 3c8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3cc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3ce:	2601                	sext.w	a2,a2
 3d0:	00000517          	auipc	a0,0x0
 3d4:	4c850513          	addi	a0,a0,1224 # 898 <digits>
 3d8:	883a                	mv	a6,a4
 3da:	2705                	addiw	a4,a4,1
 3dc:	02c5f7bb          	remuw	a5,a1,a2
 3e0:	1782                	slli	a5,a5,0x20
 3e2:	9381                	srli	a5,a5,0x20
 3e4:	97aa                	add	a5,a5,a0
 3e6:	0007c783          	lbu	a5,0(a5)
 3ea:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3ee:	0005879b          	sext.w	a5,a1
 3f2:	02c5d5bb          	divuw	a1,a1,a2
 3f6:	0685                	addi	a3,a3,1
 3f8:	fec7f0e3          	bgeu	a5,a2,3d8 <printint+0x2a>
  if(neg)
 3fc:	00088c63          	beqz	a7,414 <printint+0x66>
    buf[i++] = '-';
 400:	fd070793          	addi	a5,a4,-48
 404:	00878733          	add	a4,a5,s0
 408:	02d00793          	li	a5,45
 40c:	fef70823          	sb	a5,-16(a4)
 410:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 414:	02e05863          	blez	a4,444 <printint+0x96>
 418:	fc040793          	addi	a5,s0,-64
 41c:	00e78933          	add	s2,a5,a4
 420:	fff78993          	addi	s3,a5,-1
 424:	99ba                	add	s3,s3,a4
 426:	377d                	addiw	a4,a4,-1
 428:	1702                	slli	a4,a4,0x20
 42a:	9301                	srli	a4,a4,0x20
 42c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 430:	fff94583          	lbu	a1,-1(s2)
 434:	8526                	mv	a0,s1
 436:	00000097          	auipc	ra,0x0
 43a:	f56080e7          	jalr	-170(ra) # 38c <putc>
  while(--i >= 0)
 43e:	197d                	addi	s2,s2,-1
 440:	ff3918e3          	bne	s2,s3,430 <printint+0x82>
}
 444:	70e2                	ld	ra,56(sp)
 446:	7442                	ld	s0,48(sp)
 448:	74a2                	ld	s1,40(sp)
 44a:	7902                	ld	s2,32(sp)
 44c:	69e2                	ld	s3,24(sp)
 44e:	6121                	addi	sp,sp,64
 450:	8082                	ret
    x = -xx;
 452:	40b005bb          	negw	a1,a1
    neg = 1;
 456:	4885                	li	a7,1
    x = -xx;
 458:	bf85                	j	3c8 <printint+0x1a>

000000000000045a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 45a:	7119                	addi	sp,sp,-128
 45c:	fc86                	sd	ra,120(sp)
 45e:	f8a2                	sd	s0,112(sp)
 460:	f4a6                	sd	s1,104(sp)
 462:	f0ca                	sd	s2,96(sp)
 464:	ecce                	sd	s3,88(sp)
 466:	e8d2                	sd	s4,80(sp)
 468:	e4d6                	sd	s5,72(sp)
 46a:	e0da                	sd	s6,64(sp)
 46c:	fc5e                	sd	s7,56(sp)
 46e:	f862                	sd	s8,48(sp)
 470:	f466                	sd	s9,40(sp)
 472:	f06a                	sd	s10,32(sp)
 474:	ec6e                	sd	s11,24(sp)
 476:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 478:	0005c903          	lbu	s2,0(a1)
 47c:	18090f63          	beqz	s2,61a <vprintf+0x1c0>
 480:	8aaa                	mv	s5,a0
 482:	8b32                	mv	s6,a2
 484:	00158493          	addi	s1,a1,1
  state = 0;
 488:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 48a:	02500a13          	li	s4,37
 48e:	4c55                	li	s8,21
 490:	00000c97          	auipc	s9,0x0
 494:	3b0c8c93          	addi	s9,s9,944 # 840 <malloc+0x122>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 498:	02800d93          	li	s11,40
  putc(fd, 'x');
 49c:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 49e:	00000b97          	auipc	s7,0x0
 4a2:	3fab8b93          	addi	s7,s7,1018 # 898 <digits>
 4a6:	a839                	j	4c4 <vprintf+0x6a>
        putc(fd, c);
 4a8:	85ca                	mv	a1,s2
 4aa:	8556                	mv	a0,s5
 4ac:	00000097          	auipc	ra,0x0
 4b0:	ee0080e7          	jalr	-288(ra) # 38c <putc>
 4b4:	a019                	j	4ba <vprintf+0x60>
    } else if(state == '%'){
 4b6:	01498d63          	beq	s3,s4,4d0 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 4ba:	0485                	addi	s1,s1,1
 4bc:	fff4c903          	lbu	s2,-1(s1)
 4c0:	14090d63          	beqz	s2,61a <vprintf+0x1c0>
    if(state == 0){
 4c4:	fe0999e3          	bnez	s3,4b6 <vprintf+0x5c>
      if(c == '%'){
 4c8:	ff4910e3          	bne	s2,s4,4a8 <vprintf+0x4e>
        state = '%';
 4cc:	89d2                	mv	s3,s4
 4ce:	b7f5                	j	4ba <vprintf+0x60>
      if(c == 'd'){
 4d0:	11490c63          	beq	s2,s4,5e8 <vprintf+0x18e>
 4d4:	f9d9079b          	addiw	a5,s2,-99
 4d8:	0ff7f793          	zext.b	a5,a5
 4dc:	10fc6e63          	bltu	s8,a5,5f8 <vprintf+0x19e>
 4e0:	f9d9079b          	addiw	a5,s2,-99
 4e4:	0ff7f713          	zext.b	a4,a5
 4e8:	10ec6863          	bltu	s8,a4,5f8 <vprintf+0x19e>
 4ec:	00271793          	slli	a5,a4,0x2
 4f0:	97e6                	add	a5,a5,s9
 4f2:	439c                	lw	a5,0(a5)
 4f4:	97e6                	add	a5,a5,s9
 4f6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4f8:	008b0913          	addi	s2,s6,8
 4fc:	4685                	li	a3,1
 4fe:	4629                	li	a2,10
 500:	000b2583          	lw	a1,0(s6)
 504:	8556                	mv	a0,s5
 506:	00000097          	auipc	ra,0x0
 50a:	ea8080e7          	jalr	-344(ra) # 3ae <printint>
 50e:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 510:	4981                	li	s3,0
 512:	b765                	j	4ba <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 514:	008b0913          	addi	s2,s6,8
 518:	4681                	li	a3,0
 51a:	4629                	li	a2,10
 51c:	000b2583          	lw	a1,0(s6)
 520:	8556                	mv	a0,s5
 522:	00000097          	auipc	ra,0x0
 526:	e8c080e7          	jalr	-372(ra) # 3ae <printint>
 52a:	8b4a                	mv	s6,s2
      state = 0;
 52c:	4981                	li	s3,0
 52e:	b771                	j	4ba <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 530:	008b0913          	addi	s2,s6,8
 534:	4681                	li	a3,0
 536:	866a                	mv	a2,s10
 538:	000b2583          	lw	a1,0(s6)
 53c:	8556                	mv	a0,s5
 53e:	00000097          	auipc	ra,0x0
 542:	e70080e7          	jalr	-400(ra) # 3ae <printint>
 546:	8b4a                	mv	s6,s2
      state = 0;
 548:	4981                	li	s3,0
 54a:	bf85                	j	4ba <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 54c:	008b0793          	addi	a5,s6,8
 550:	f8f43423          	sd	a5,-120(s0)
 554:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 558:	03000593          	li	a1,48
 55c:	8556                	mv	a0,s5
 55e:	00000097          	auipc	ra,0x0
 562:	e2e080e7          	jalr	-466(ra) # 38c <putc>
  putc(fd, 'x');
 566:	07800593          	li	a1,120
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	e20080e7          	jalr	-480(ra) # 38c <putc>
 574:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 576:	03c9d793          	srli	a5,s3,0x3c
 57a:	97de                	add	a5,a5,s7
 57c:	0007c583          	lbu	a1,0(a5)
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	e0a080e7          	jalr	-502(ra) # 38c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 58a:	0992                	slli	s3,s3,0x4
 58c:	397d                	addiw	s2,s2,-1
 58e:	fe0914e3          	bnez	s2,576 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 592:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 596:	4981                	li	s3,0
 598:	b70d                	j	4ba <vprintf+0x60>
        s = va_arg(ap, char*);
 59a:	008b0913          	addi	s2,s6,8
 59e:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 5a2:	02098163          	beqz	s3,5c4 <vprintf+0x16a>
        while(*s != 0){
 5a6:	0009c583          	lbu	a1,0(s3)
 5aa:	c5ad                	beqz	a1,614 <vprintf+0x1ba>
          putc(fd, *s);
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	dde080e7          	jalr	-546(ra) # 38c <putc>
          s++;
 5b6:	0985                	addi	s3,s3,1
        while(*s != 0){
 5b8:	0009c583          	lbu	a1,0(s3)
 5bc:	f9e5                	bnez	a1,5ac <vprintf+0x152>
        s = va_arg(ap, char*);
 5be:	8b4a                	mv	s6,s2
      state = 0;
 5c0:	4981                	li	s3,0
 5c2:	bde5                	j	4ba <vprintf+0x60>
          s = "(null)";
 5c4:	00000997          	auipc	s3,0x0
 5c8:	27498993          	addi	s3,s3,628 # 838 <malloc+0x11a>
        while(*s != 0){
 5cc:	85ee                	mv	a1,s11
 5ce:	bff9                	j	5ac <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 5d0:	008b0913          	addi	s2,s6,8
 5d4:	000b4583          	lbu	a1,0(s6)
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	db2080e7          	jalr	-590(ra) # 38c <putc>
 5e2:	8b4a                	mv	s6,s2
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	bdd1                	j	4ba <vprintf+0x60>
        putc(fd, c);
 5e8:	85d2                	mv	a1,s4
 5ea:	8556                	mv	a0,s5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	da0080e7          	jalr	-608(ra) # 38c <putc>
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	b5d1                	j	4ba <vprintf+0x60>
        putc(fd, '%');
 5f8:	85d2                	mv	a1,s4
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	d90080e7          	jalr	-624(ra) # 38c <putc>
        putc(fd, c);
 604:	85ca                	mv	a1,s2
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	d84080e7          	jalr	-636(ra) # 38c <putc>
      state = 0;
 610:	4981                	li	s3,0
 612:	b565                	j	4ba <vprintf+0x60>
        s = va_arg(ap, char*);
 614:	8b4a                	mv	s6,s2
      state = 0;
 616:	4981                	li	s3,0
 618:	b54d                	j	4ba <vprintf+0x60>
    }
  }
}
 61a:	70e6                	ld	ra,120(sp)
 61c:	7446                	ld	s0,112(sp)
 61e:	74a6                	ld	s1,104(sp)
 620:	7906                	ld	s2,96(sp)
 622:	69e6                	ld	s3,88(sp)
 624:	6a46                	ld	s4,80(sp)
 626:	6aa6                	ld	s5,72(sp)
 628:	6b06                	ld	s6,64(sp)
 62a:	7be2                	ld	s7,56(sp)
 62c:	7c42                	ld	s8,48(sp)
 62e:	7ca2                	ld	s9,40(sp)
 630:	7d02                	ld	s10,32(sp)
 632:	6de2                	ld	s11,24(sp)
 634:	6109                	addi	sp,sp,128
 636:	8082                	ret

0000000000000638 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 638:	715d                	addi	sp,sp,-80
 63a:	ec06                	sd	ra,24(sp)
 63c:	e822                	sd	s0,16(sp)
 63e:	1000                	addi	s0,sp,32
 640:	e010                	sd	a2,0(s0)
 642:	e414                	sd	a3,8(s0)
 644:	e818                	sd	a4,16(s0)
 646:	ec1c                	sd	a5,24(s0)
 648:	03043023          	sd	a6,32(s0)
 64c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 650:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 654:	8622                	mv	a2,s0
 656:	00000097          	auipc	ra,0x0
 65a:	e04080e7          	jalr	-508(ra) # 45a <vprintf>
}
 65e:	60e2                	ld	ra,24(sp)
 660:	6442                	ld	s0,16(sp)
 662:	6161                	addi	sp,sp,80
 664:	8082                	ret

0000000000000666 <printf>:

void
printf(const char *fmt, ...)
{
 666:	711d                	addi	sp,sp,-96
 668:	ec06                	sd	ra,24(sp)
 66a:	e822                	sd	s0,16(sp)
 66c:	1000                	addi	s0,sp,32
 66e:	e40c                	sd	a1,8(s0)
 670:	e810                	sd	a2,16(s0)
 672:	ec14                	sd	a3,24(s0)
 674:	f018                	sd	a4,32(s0)
 676:	f41c                	sd	a5,40(s0)
 678:	03043823          	sd	a6,48(s0)
 67c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 680:	00840613          	addi	a2,s0,8
 684:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 688:	85aa                	mv	a1,a0
 68a:	4505                	li	a0,1
 68c:	00000097          	auipc	ra,0x0
 690:	dce080e7          	jalr	-562(ra) # 45a <vprintf>
}
 694:	60e2                	ld	ra,24(sp)
 696:	6442                	ld	s0,16(sp)
 698:	6125                	addi	sp,sp,96
 69a:	8082                	ret

000000000000069c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 69c:	1141                	addi	sp,sp,-16
 69e:	e422                	sd	s0,8(sp)
 6a0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6a2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a6:	00000797          	auipc	a5,0x0
 6aa:	20a7b783          	ld	a5,522(a5) # 8b0 <freep>
 6ae:	a02d                	j	6d8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6b0:	4618                	lw	a4,8(a2)
 6b2:	9f2d                	addw	a4,a4,a1
 6b4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6b8:	6398                	ld	a4,0(a5)
 6ba:	6310                	ld	a2,0(a4)
 6bc:	a83d                	j	6fa <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6be:	ff852703          	lw	a4,-8(a0)
 6c2:	9f31                	addw	a4,a4,a2
 6c4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6c6:	ff053683          	ld	a3,-16(a0)
 6ca:	a091                	j	70e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6cc:	6398                	ld	a4,0(a5)
 6ce:	00e7e463          	bltu	a5,a4,6d6 <free+0x3a>
 6d2:	00e6ea63          	bltu	a3,a4,6e6 <free+0x4a>
{
 6d6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d8:	fed7fae3          	bgeu	a5,a3,6cc <free+0x30>
 6dc:	6398                	ld	a4,0(a5)
 6de:	00e6e463          	bltu	a3,a4,6e6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e2:	fee7eae3          	bltu	a5,a4,6d6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6e6:	ff852583          	lw	a1,-8(a0)
 6ea:	6390                	ld	a2,0(a5)
 6ec:	02059813          	slli	a6,a1,0x20
 6f0:	01c85713          	srli	a4,a6,0x1c
 6f4:	9736                	add	a4,a4,a3
 6f6:	fae60de3          	beq	a2,a4,6b0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6fa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6fe:	4790                	lw	a2,8(a5)
 700:	02061593          	slli	a1,a2,0x20
 704:	01c5d713          	srli	a4,a1,0x1c
 708:	973e                	add	a4,a4,a5
 70a:	fae68ae3          	beq	a3,a4,6be <free+0x22>
    p->s.ptr = bp->s.ptr;
 70e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 710:	00000717          	auipc	a4,0x0
 714:	1af73023          	sd	a5,416(a4) # 8b0 <freep>
}
 718:	6422                	ld	s0,8(sp)
 71a:	0141                	addi	sp,sp,16
 71c:	8082                	ret

000000000000071e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 71e:	7139                	addi	sp,sp,-64
 720:	fc06                	sd	ra,56(sp)
 722:	f822                	sd	s0,48(sp)
 724:	f426                	sd	s1,40(sp)
 726:	f04a                	sd	s2,32(sp)
 728:	ec4e                	sd	s3,24(sp)
 72a:	e852                	sd	s4,16(sp)
 72c:	e456                	sd	s5,8(sp)
 72e:	e05a                	sd	s6,0(sp)
 730:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 732:	02051493          	slli	s1,a0,0x20
 736:	9081                	srli	s1,s1,0x20
 738:	04bd                	addi	s1,s1,15
 73a:	8091                	srli	s1,s1,0x4
 73c:	0014899b          	addiw	s3,s1,1
 740:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 742:	00000517          	auipc	a0,0x0
 746:	16e53503          	ld	a0,366(a0) # 8b0 <freep>
 74a:	c515                	beqz	a0,776 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 74c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 74e:	4798                	lw	a4,8(a5)
 750:	02977f63          	bgeu	a4,s1,78e <malloc+0x70>
 754:	8a4e                	mv	s4,s3
 756:	0009871b          	sext.w	a4,s3
 75a:	6685                	lui	a3,0x1
 75c:	00d77363          	bgeu	a4,a3,762 <malloc+0x44>
 760:	6a05                	lui	s4,0x1
 762:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 766:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 76a:	00000917          	auipc	s2,0x0
 76e:	14690913          	addi	s2,s2,326 # 8b0 <freep>
  if(p == (char*)-1)
 772:	5afd                	li	s5,-1
 774:	a895                	j	7e8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 776:	00000797          	auipc	a5,0x0
 77a:	14278793          	addi	a5,a5,322 # 8b8 <base>
 77e:	00000717          	auipc	a4,0x0
 782:	12f73923          	sd	a5,306(a4) # 8b0 <freep>
 786:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 788:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 78c:	b7e1                	j	754 <malloc+0x36>
      if(p->s.size == nunits)
 78e:	02e48c63          	beq	s1,a4,7c6 <malloc+0xa8>
        p->s.size -= nunits;
 792:	4137073b          	subw	a4,a4,s3
 796:	c798                	sw	a4,8(a5)
        p += p->s.size;
 798:	02071693          	slli	a3,a4,0x20
 79c:	01c6d713          	srli	a4,a3,0x1c
 7a0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7a2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7a6:	00000717          	auipc	a4,0x0
 7aa:	10a73523          	sd	a0,266(a4) # 8b0 <freep>
      return (void*)(p + 1);
 7ae:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7b2:	70e2                	ld	ra,56(sp)
 7b4:	7442                	ld	s0,48(sp)
 7b6:	74a2                	ld	s1,40(sp)
 7b8:	7902                	ld	s2,32(sp)
 7ba:	69e2                	ld	s3,24(sp)
 7bc:	6a42                	ld	s4,16(sp)
 7be:	6aa2                	ld	s5,8(sp)
 7c0:	6b02                	ld	s6,0(sp)
 7c2:	6121                	addi	sp,sp,64
 7c4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7c6:	6398                	ld	a4,0(a5)
 7c8:	e118                	sd	a4,0(a0)
 7ca:	bff1                	j	7a6 <malloc+0x88>
  hp->s.size = nu;
 7cc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7d0:	0541                	addi	a0,a0,16
 7d2:	00000097          	auipc	ra,0x0
 7d6:	eca080e7          	jalr	-310(ra) # 69c <free>
  return freep;
 7da:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7de:	d971                	beqz	a0,7b2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7e2:	4798                	lw	a4,8(a5)
 7e4:	fa9775e3          	bgeu	a4,s1,78e <malloc+0x70>
    if(p == freep)
 7e8:	00093703          	ld	a4,0(s2)
 7ec:	853e                	mv	a0,a5
 7ee:	fef719e3          	bne	a4,a5,7e0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7f2:	8552                	mv	a0,s4
 7f4:	00000097          	auipc	ra,0x0
 7f8:	b60080e7          	jalr	-1184(ra) # 354 <sbrk>
  if(p == (char*)-1)
 7fc:	fd5518e3          	bne	a0,s5,7cc <malloc+0xae>
        return 0;
 800:	4501                	li	a0,0
 802:	bf45                	j	7b2 <malloc+0x94>
