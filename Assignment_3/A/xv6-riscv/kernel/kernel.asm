
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	18010113          	addi	sp,sp,384 # 80009180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	ff070713          	addi	a4,a4,-16 # 80009040 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	bee78793          	addi	a5,a5,-1042 # 80005c50 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	addi	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	3aa080e7          	jalr	938(ra) # 800024d4 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	77e080e7          	jalr	1918(ra) # 800008b8 <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	ff650513          	addi	a0,a0,-10 # 80011180 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a3e080e7          	jalr	-1474(ra) # 80000bd0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	fe648493          	addi	s1,s1,-26 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	07690913          	addi	s2,s2,118 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305863          	blez	s3,80000220 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71463          	bne	a4,a5,800001e4 <consoleread+0x80>
      if(myproc()->killed){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	856080e7          	jalr	-1962(ra) # 80001a16 <myproc>
    800001c8:	551c                	lw	a5,40(a0)
    800001ca:	e7b5                	bnez	a5,80000236 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001cc:	85a6                	mv	a1,s1
    800001ce:	854a                	mv	a0,s2
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	f0a080e7          	jalr	-246(ra) # 800020da <sleep>
    while(cons.r == cons.w){
    800001d8:	0984a783          	lw	a5,152(s1)
    800001dc:	09c4a703          	lw	a4,156(s1)
    800001e0:	fef700e3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e4:	0017871b          	addiw	a4,a5,1
    800001e8:	08e4ac23          	sw	a4,152(s1)
    800001ec:	07f7f713          	andi	a4,a5,127
    800001f0:	9726                	add	a4,a4,s1
    800001f2:	01874703          	lbu	a4,24(a4)
    800001f6:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001fa:	077d0563          	beq	s10,s7,80000264 <consoleread+0x100>
    cbuf = c;
    800001fe:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000202:	4685                	li	a3,1
    80000204:	f9f40613          	addi	a2,s0,-97
    80000208:	85d2                	mv	a1,s4
    8000020a:	8556                	mv	a0,s5
    8000020c:	00002097          	auipc	ra,0x2
    80000210:	272080e7          	jalr	626(ra) # 8000247e <either_copyout>
    80000214:	01850663          	beq	a0,s8,80000220 <consoleread+0xbc>
    dst++;
    80000218:	0a05                	addi	s4,s4,1
    --n;
    8000021a:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000021c:	f99d1ae3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000220:	00011517          	auipc	a0,0x11
    80000224:	f6050513          	addi	a0,a0,-160 # 80011180 <cons>
    80000228:	00001097          	auipc	ra,0x1
    8000022c:	a5c080e7          	jalr	-1444(ra) # 80000c84 <release>

  return target - n;
    80000230:	413b053b          	subw	a0,s6,s3
    80000234:	a811                	j	80000248 <consoleread+0xe4>
        release(&cons.lock);
    80000236:	00011517          	auipc	a0,0x11
    8000023a:	f4a50513          	addi	a0,a0,-182 # 80011180 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	a46080e7          	jalr	-1466(ra) # 80000c84 <release>
        return -1;
    80000246:	557d                	li	a0,-1
}
    80000248:	70a6                	ld	ra,104(sp)
    8000024a:	7406                	ld	s0,96(sp)
    8000024c:	64e6                	ld	s1,88(sp)
    8000024e:	6946                	ld	s2,80(sp)
    80000250:	69a6                	ld	s3,72(sp)
    80000252:	6a06                	ld	s4,64(sp)
    80000254:	7ae2                	ld	s5,56(sp)
    80000256:	7b42                	ld	s6,48(sp)
    80000258:	7ba2                	ld	s7,40(sp)
    8000025a:	7c02                	ld	s8,32(sp)
    8000025c:	6ce2                	ld	s9,24(sp)
    8000025e:	6d42                	ld	s10,16(sp)
    80000260:	6165                	addi	sp,sp,112
    80000262:	8082                	ret
      if(n < target){
    80000264:	0009871b          	sext.w	a4,s3
    80000268:	fb677ce3          	bgeu	a4,s6,80000220 <consoleread+0xbc>
        cons.r--;
    8000026c:	00011717          	auipc	a4,0x11
    80000270:	faf72623          	sw	a5,-84(a4) # 80011218 <cons+0x98>
    80000274:	b775                	j	80000220 <consoleread+0xbc>

0000000080000276 <consputc>:
{
    80000276:	1141                	addi	sp,sp,-16
    80000278:	e406                	sd	ra,8(sp)
    8000027a:	e022                	sd	s0,0(sp)
    8000027c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000027e:	10000793          	li	a5,256
    80000282:	00f50a63          	beq	a0,a5,80000296 <consputc+0x20>
    uartputc_sync(c);
    80000286:	00000097          	auipc	ra,0x0
    8000028a:	560080e7          	jalr	1376(ra) # 800007e6 <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	00000097          	auipc	ra,0x0
    8000029c:	54e080e7          	jalr	1358(ra) # 800007e6 <uartputc_sync>
    800002a0:	02000513          	li	a0,32
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	542080e7          	jalr	1346(ra) # 800007e6 <uartputc_sync>
    800002ac:	4521                	li	a0,8
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	538080e7          	jalr	1336(ra) # 800007e6 <uartputc_sync>
    800002b6:	bfe1                	j	8000028e <consputc+0x18>

00000000800002b8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b8:	1101                	addi	sp,sp,-32
    800002ba:	ec06                	sd	ra,24(sp)
    800002bc:	e822                	sd	s0,16(sp)
    800002be:	e426                	sd	s1,8(sp)
    800002c0:	e04a                	sd	s2,0(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	00011517          	auipc	a0,0x11
    800002ca:	eba50513          	addi	a0,a0,-326 # 80011180 <cons>
    800002ce:	00001097          	auipc	ra,0x1
    800002d2:	902080e7          	jalr	-1790(ra) # 80000bd0 <acquire>

  switch(c){
    800002d6:	47d5                	li	a5,21
    800002d8:	0af48663          	beq	s1,a5,80000384 <consoleintr+0xcc>
    800002dc:	0297ca63          	blt	a5,s1,80000310 <consoleintr+0x58>
    800002e0:	47a1                	li	a5,8
    800002e2:	0ef48763          	beq	s1,a5,800003d0 <consoleintr+0x118>
    800002e6:	47c1                	li	a5,16
    800002e8:	10f49a63          	bne	s1,a5,800003fc <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ec:	00002097          	auipc	ra,0x2
    800002f0:	23e080e7          	jalr	574(ra) # 8000252a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f4:	00011517          	auipc	a0,0x11
    800002f8:	e8c50513          	addi	a0,a0,-372 # 80011180 <cons>
    800002fc:	00001097          	auipc	ra,0x1
    80000300:	988080e7          	jalr	-1656(ra) # 80000c84 <release>
}
    80000304:	60e2                	ld	ra,24(sp)
    80000306:	6442                	ld	s0,16(sp)
    80000308:	64a2                	ld	s1,8(sp)
    8000030a:	6902                	ld	s2,0(sp)
    8000030c:	6105                	addi	sp,sp,32
    8000030e:	8082                	ret
  switch(c){
    80000310:	07f00793          	li	a5,127
    80000314:	0af48e63          	beq	s1,a5,800003d0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000318:	00011717          	auipc	a4,0x11
    8000031c:	e6870713          	addi	a4,a4,-408 # 80011180 <cons>
    80000320:	0a072783          	lw	a5,160(a4)
    80000324:	09872703          	lw	a4,152(a4)
    80000328:	9f99                	subw	a5,a5,a4
    8000032a:	07f00713          	li	a4,127
    8000032e:	fcf763e3          	bltu	a4,a5,800002f4 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000332:	47b5                	li	a5,13
    80000334:	0cf48763          	beq	s1,a5,80000402 <consoleintr+0x14a>
      consputc(c);
    80000338:	8526                	mv	a0,s1
    8000033a:	00000097          	auipc	ra,0x0
    8000033e:	f3c080e7          	jalr	-196(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000342:	00011797          	auipc	a5,0x11
    80000346:	e3e78793          	addi	a5,a5,-450 # 80011180 <cons>
    8000034a:	0a07a703          	lw	a4,160(a5)
    8000034e:	0017069b          	addiw	a3,a4,1
    80000352:	0006861b          	sext.w	a2,a3
    80000356:	0ad7a023          	sw	a3,160(a5)
    8000035a:	07f77713          	andi	a4,a4,127
    8000035e:	97ba                	add	a5,a5,a4
    80000360:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000364:	47a9                	li	a5,10
    80000366:	0cf48563          	beq	s1,a5,80000430 <consoleintr+0x178>
    8000036a:	4791                	li	a5,4
    8000036c:	0cf48263          	beq	s1,a5,80000430 <consoleintr+0x178>
    80000370:	00011797          	auipc	a5,0x11
    80000374:	ea87a783          	lw	a5,-344(a5) # 80011218 <cons+0x98>
    80000378:	0807879b          	addiw	a5,a5,128
    8000037c:	f6f61ce3          	bne	a2,a5,800002f4 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000380:	863e                	mv	a2,a5
    80000382:	a07d                	j	80000430 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000384:	00011717          	auipc	a4,0x11
    80000388:	dfc70713          	addi	a4,a4,-516 # 80011180 <cons>
    8000038c:	0a072783          	lw	a5,160(a4)
    80000390:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	00011497          	auipc	s1,0x11
    80000398:	dec48493          	addi	s1,s1,-532 # 80011180 <cons>
    while(cons.e != cons.w &&
    8000039c:	4929                	li	s2,10
    8000039e:	f4f70be3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a2:	37fd                	addiw	a5,a5,-1
    800003a4:	07f7f713          	andi	a4,a5,127
    800003a8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003aa:	01874703          	lbu	a4,24(a4)
    800003ae:	f52703e3          	beq	a4,s2,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003b2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b6:	10000513          	li	a0,256
    800003ba:	00000097          	auipc	ra,0x0
    800003be:	ebc080e7          	jalr	-324(ra) # 80000276 <consputc>
    while(cons.e != cons.w &&
    800003c2:	0a04a783          	lw	a5,160(s1)
    800003c6:	09c4a703          	lw	a4,156(s1)
    800003ca:	fcf71ce3          	bne	a4,a5,800003a2 <consoleintr+0xea>
    800003ce:	b71d                	j	800002f4 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d0:	00011717          	auipc	a4,0x11
    800003d4:	db070713          	addi	a4,a4,-592 # 80011180 <cons>
    800003d8:	0a072783          	lw	a5,160(a4)
    800003dc:	09c72703          	lw	a4,156(a4)
    800003e0:	f0f70ae3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003e4:	37fd                	addiw	a5,a5,-1
    800003e6:	00011717          	auipc	a4,0x11
    800003ea:	e2f72d23          	sw	a5,-454(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003ee:	10000513          	li	a0,256
    800003f2:	00000097          	auipc	ra,0x0
    800003f6:	e84080e7          	jalr	-380(ra) # 80000276 <consputc>
    800003fa:	bded                	j	800002f4 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003fc:	ee048ce3          	beqz	s1,800002f4 <consoleintr+0x3c>
    80000400:	bf21                	j	80000318 <consoleintr+0x60>
      consputc(c);
    80000402:	4529                	li	a0,10
    80000404:	00000097          	auipc	ra,0x0
    80000408:	e72080e7          	jalr	-398(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000040c:	00011797          	auipc	a5,0x11
    80000410:	d7478793          	addi	a5,a5,-652 # 80011180 <cons>
    80000414:	0a07a703          	lw	a4,160(a5)
    80000418:	0017069b          	addiw	a3,a4,1
    8000041c:	0006861b          	sext.w	a2,a3
    80000420:	0ad7a023          	sw	a3,160(a5)
    80000424:	07f77713          	andi	a4,a4,127
    80000428:	97ba                	add	a5,a5,a4
    8000042a:	4729                	li	a4,10
    8000042c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000430:	00011797          	auipc	a5,0x11
    80000434:	dec7a623          	sw	a2,-532(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    80000438:	00011517          	auipc	a0,0x11
    8000043c:	de050513          	addi	a0,a0,-544 # 80011218 <cons+0x98>
    80000440:	00002097          	auipc	ra,0x2
    80000444:	e26080e7          	jalr	-474(ra) # 80002266 <wakeup>
    80000448:	b575                	j	800002f4 <consoleintr+0x3c>

000000008000044a <consoleinit>:

void
consoleinit(void)
{
    8000044a:	1141                	addi	sp,sp,-16
    8000044c:	e406                	sd	ra,8(sp)
    8000044e:	e022                	sd	s0,0(sp)
    80000450:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000452:	00008597          	auipc	a1,0x8
    80000456:	bbe58593          	addi	a1,a1,-1090 # 80008010 <etext+0x10>
    8000045a:	00011517          	auipc	a0,0x11
    8000045e:	d2650513          	addi	a0,a0,-730 # 80011180 <cons>
    80000462:	00000097          	auipc	ra,0x0
    80000466:	6de080e7          	jalr	1758(ra) # 80000b40 <initlock>

  uartinit();
    8000046a:	00000097          	auipc	ra,0x0
    8000046e:	32c080e7          	jalr	812(ra) # 80000796 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000472:	00021797          	auipc	a5,0x21
    80000476:	ea678793          	addi	a5,a5,-346 # 80021318 <devsw>
    8000047a:	00000717          	auipc	a4,0x0
    8000047e:	cea70713          	addi	a4,a4,-790 # 80000164 <consoleread>
    80000482:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000484:	00000717          	auipc	a4,0x0
    80000488:	c7c70713          	addi	a4,a4,-900 # 80000100 <consolewrite>
    8000048c:	ef98                	sd	a4,24(a5)
}
    8000048e:	60a2                	ld	ra,8(sp)
    80000490:	6402                	ld	s0,0(sp)
    80000492:	0141                	addi	sp,sp,16
    80000494:	8082                	ret

0000000080000496 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000496:	7179                	addi	sp,sp,-48
    80000498:	f406                	sd	ra,40(sp)
    8000049a:	f022                	sd	s0,32(sp)
    8000049c:	ec26                	sd	s1,24(sp)
    8000049e:	e84a                	sd	s2,16(sp)
    800004a0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a2:	c219                	beqz	a2,800004a8 <printint+0x12>
    800004a4:	08054763          	bltz	a0,80000532 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004a8:	2501                	sext.w	a0,a0
    800004aa:	4881                	li	a7,0
    800004ac:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b2:	2581                	sext.w	a1,a1
    800004b4:	00008617          	auipc	a2,0x8
    800004b8:	b8c60613          	addi	a2,a2,-1140 # 80008040 <digits>
    800004bc:	883a                	mv	a6,a4
    800004be:	2705                	addiw	a4,a4,1
    800004c0:	02b577bb          	remuw	a5,a0,a1
    800004c4:	1782                	slli	a5,a5,0x20
    800004c6:	9381                	srli	a5,a5,0x20
    800004c8:	97b2                	add	a5,a5,a2
    800004ca:	0007c783          	lbu	a5,0(a5)
    800004ce:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d2:	0005079b          	sext.w	a5,a0
    800004d6:	02b5553b          	divuw	a0,a0,a1
    800004da:	0685                	addi	a3,a3,1
    800004dc:	feb7f0e3          	bgeu	a5,a1,800004bc <printint+0x26>

  if(sign)
    800004e0:	00088c63          	beqz	a7,800004f8 <printint+0x62>
    buf[i++] = '-';
    800004e4:	fe070793          	addi	a5,a4,-32
    800004e8:	00878733          	add	a4,a5,s0
    800004ec:	02d00793          	li	a5,45
    800004f0:	fef70823          	sb	a5,-16(a4)
    800004f4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004f8:	02e05763          	blez	a4,80000526 <printint+0x90>
    800004fc:	fd040793          	addi	a5,s0,-48
    80000500:	00e784b3          	add	s1,a5,a4
    80000504:	fff78913          	addi	s2,a5,-1
    80000508:	993a                	add	s2,s2,a4
    8000050a:	377d                	addiw	a4,a4,-1
    8000050c:	1702                	slli	a4,a4,0x20
    8000050e:	9301                	srli	a4,a4,0x20
    80000510:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000514:	fff4c503          	lbu	a0,-1(s1)
    80000518:	00000097          	auipc	ra,0x0
    8000051c:	d5e080e7          	jalr	-674(ra) # 80000276 <consputc>
  while(--i >= 0)
    80000520:	14fd                	addi	s1,s1,-1
    80000522:	ff2499e3          	bne	s1,s2,80000514 <printint+0x7e>
}
    80000526:	70a2                	ld	ra,40(sp)
    80000528:	7402                	ld	s0,32(sp)
    8000052a:	64e2                	ld	s1,24(sp)
    8000052c:	6942                	ld	s2,16(sp)
    8000052e:	6145                	addi	sp,sp,48
    80000530:	8082                	ret
    x = -xx;
    80000532:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000536:	4885                	li	a7,1
    x = -xx;
    80000538:	bf95                	j	800004ac <printint+0x16>

000000008000053a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053a:	1101                	addi	sp,sp,-32
    8000053c:	ec06                	sd	ra,24(sp)
    8000053e:	e822                	sd	s0,16(sp)
    80000540:	e426                	sd	s1,8(sp)
    80000542:	1000                	addi	s0,sp,32
    80000544:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000546:	00011797          	auipc	a5,0x11
    8000054a:	ce07ad23          	sw	zero,-774(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    8000054e:	00008517          	auipc	a0,0x8
    80000552:	aca50513          	addi	a0,a0,-1334 # 80008018 <etext+0x18>
    80000556:	00000097          	auipc	ra,0x0
    8000055a:	02e080e7          	jalr	46(ra) # 80000584 <printf>
  printf(s);
    8000055e:	8526                	mv	a0,s1
    80000560:	00000097          	auipc	ra,0x0
    80000564:	024080e7          	jalr	36(ra) # 80000584 <printf>
  printf("\n");
    80000568:	00008517          	auipc	a0,0x8
    8000056c:	b6050513          	addi	a0,a0,-1184 # 800080c8 <digits+0x88>
    80000570:	00000097          	auipc	ra,0x0
    80000574:	014080e7          	jalr	20(ra) # 80000584 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000578:	4785                	li	a5,1
    8000057a:	00009717          	auipc	a4,0x9
    8000057e:	a8f72323          	sw	a5,-1402(a4) # 80009000 <panicked>
  for(;;)
    80000582:	a001                	j	80000582 <panic+0x48>

0000000080000584 <printf>:
{
    80000584:	7131                	addi	sp,sp,-192
    80000586:	fc86                	sd	ra,120(sp)
    80000588:	f8a2                	sd	s0,112(sp)
    8000058a:	f4a6                	sd	s1,104(sp)
    8000058c:	f0ca                	sd	s2,96(sp)
    8000058e:	ecce                	sd	s3,88(sp)
    80000590:	e8d2                	sd	s4,80(sp)
    80000592:	e4d6                	sd	s5,72(sp)
    80000594:	e0da                	sd	s6,64(sp)
    80000596:	fc5e                	sd	s7,56(sp)
    80000598:	f862                	sd	s8,48(sp)
    8000059a:	f466                	sd	s9,40(sp)
    8000059c:	f06a                	sd	s10,32(sp)
    8000059e:	ec6e                	sd	s11,24(sp)
    800005a0:	0100                	addi	s0,sp,128
    800005a2:	8a2a                	mv	s4,a0
    800005a4:	e40c                	sd	a1,8(s0)
    800005a6:	e810                	sd	a2,16(s0)
    800005a8:	ec14                	sd	a3,24(s0)
    800005aa:	f018                	sd	a4,32(s0)
    800005ac:	f41c                	sd	a5,40(s0)
    800005ae:	03043823          	sd	a6,48(s0)
    800005b2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b6:	00011d97          	auipc	s11,0x11
    800005ba:	c8adad83          	lw	s11,-886(s11) # 80011240 <pr+0x18>
  if(locking)
    800005be:	020d9b63          	bnez	s11,800005f4 <printf+0x70>
  if (fmt == 0)
    800005c2:	040a0263          	beqz	s4,80000606 <printf+0x82>
  va_start(ap, fmt);
    800005c6:	00840793          	addi	a5,s0,8
    800005ca:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005ce:	000a4503          	lbu	a0,0(s4)
    800005d2:	14050f63          	beqz	a0,80000730 <printf+0x1ac>
    800005d6:	4981                	li	s3,0
    if(c != '%'){
    800005d8:	02500a93          	li	s5,37
    switch(c){
    800005dc:	07000b93          	li	s7,112
  consputc('x');
    800005e0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e2:	00008b17          	auipc	s6,0x8
    800005e6:	a5eb0b13          	addi	s6,s6,-1442 # 80008040 <digits>
    switch(c){
    800005ea:	07300c93          	li	s9,115
    800005ee:	06400c13          	li	s8,100
    800005f2:	a82d                	j	8000062c <printf+0xa8>
    acquire(&pr.lock);
    800005f4:	00011517          	auipc	a0,0x11
    800005f8:	c3450513          	addi	a0,a0,-972 # 80011228 <pr>
    800005fc:	00000097          	auipc	ra,0x0
    80000600:	5d4080e7          	jalr	1492(ra) # 80000bd0 <acquire>
    80000604:	bf7d                	j	800005c2 <printf+0x3e>
    panic("null fmt");
    80000606:	00008517          	auipc	a0,0x8
    8000060a:	a2250513          	addi	a0,a0,-1502 # 80008028 <etext+0x28>
    8000060e:	00000097          	auipc	ra,0x0
    80000612:	f2c080e7          	jalr	-212(ra) # 8000053a <panic>
      consputc(c);
    80000616:	00000097          	auipc	ra,0x0
    8000061a:	c60080e7          	jalr	-928(ra) # 80000276 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000061e:	2985                	addiw	s3,s3,1
    80000620:	013a07b3          	add	a5,s4,s3
    80000624:	0007c503          	lbu	a0,0(a5)
    80000628:	10050463          	beqz	a0,80000730 <printf+0x1ac>
    if(c != '%'){
    8000062c:	ff5515e3          	bne	a0,s5,80000616 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000630:	2985                	addiw	s3,s3,1
    80000632:	013a07b3          	add	a5,s4,s3
    80000636:	0007c783          	lbu	a5,0(a5)
    8000063a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000063e:	cbed                	beqz	a5,80000730 <printf+0x1ac>
    switch(c){
    80000640:	05778a63          	beq	a5,s7,80000694 <printf+0x110>
    80000644:	02fbf663          	bgeu	s7,a5,80000670 <printf+0xec>
    80000648:	09978863          	beq	a5,s9,800006d8 <printf+0x154>
    8000064c:	07800713          	li	a4,120
    80000650:	0ce79563          	bne	a5,a4,8000071a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000654:	f8843783          	ld	a5,-120(s0)
    80000658:	00878713          	addi	a4,a5,8
    8000065c:	f8e43423          	sd	a4,-120(s0)
    80000660:	4605                	li	a2,1
    80000662:	85ea                	mv	a1,s10
    80000664:	4388                	lw	a0,0(a5)
    80000666:	00000097          	auipc	ra,0x0
    8000066a:	e30080e7          	jalr	-464(ra) # 80000496 <printint>
      break;
    8000066e:	bf45                	j	8000061e <printf+0x9a>
    switch(c){
    80000670:	09578f63          	beq	a5,s5,8000070e <printf+0x18a>
    80000674:	0b879363          	bne	a5,s8,8000071a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4605                	li	a2,1
    80000686:	45a9                	li	a1,10
    80000688:	4388                	lw	a0,0(a5)
    8000068a:	00000097          	auipc	ra,0x0
    8000068e:	e0c080e7          	jalr	-500(ra) # 80000496 <printint>
      break;
    80000692:	b771                	j	8000061e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a4:	03000513          	li	a0,48
    800006a8:	00000097          	auipc	ra,0x0
    800006ac:	bce080e7          	jalr	-1074(ra) # 80000276 <consputc>
  consputc('x');
    800006b0:	07800513          	li	a0,120
    800006b4:	00000097          	auipc	ra,0x0
    800006b8:	bc2080e7          	jalr	-1086(ra) # 80000276 <consputc>
    800006bc:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006be:	03c95793          	srli	a5,s2,0x3c
    800006c2:	97da                	add	a5,a5,s6
    800006c4:	0007c503          	lbu	a0,0(a5)
    800006c8:	00000097          	auipc	ra,0x0
    800006cc:	bae080e7          	jalr	-1106(ra) # 80000276 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d0:	0912                	slli	s2,s2,0x4
    800006d2:	34fd                	addiw	s1,s1,-1
    800006d4:	f4ed                	bnez	s1,800006be <printf+0x13a>
    800006d6:	b7a1                	j	8000061e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006d8:	f8843783          	ld	a5,-120(s0)
    800006dc:	00878713          	addi	a4,a5,8
    800006e0:	f8e43423          	sd	a4,-120(s0)
    800006e4:	6384                	ld	s1,0(a5)
    800006e6:	cc89                	beqz	s1,80000700 <printf+0x17c>
      for(; *s; s++)
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	d90d                	beqz	a0,8000061e <printf+0x9a>
        consputc(*s);
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	b88080e7          	jalr	-1144(ra) # 80000276 <consputc>
      for(; *s; s++)
    800006f6:	0485                	addi	s1,s1,1
    800006f8:	0004c503          	lbu	a0,0(s1)
    800006fc:	f96d                	bnez	a0,800006ee <printf+0x16a>
    800006fe:	b705                	j	8000061e <printf+0x9a>
        s = "(null)";
    80000700:	00008497          	auipc	s1,0x8
    80000704:	92048493          	addi	s1,s1,-1760 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000708:	02800513          	li	a0,40
    8000070c:	b7cd                	j	800006ee <printf+0x16a>
      consputc('%');
    8000070e:	8556                	mv	a0,s5
    80000710:	00000097          	auipc	ra,0x0
    80000714:	b66080e7          	jalr	-1178(ra) # 80000276 <consputc>
      break;
    80000718:	b719                	j	8000061e <printf+0x9a>
      consputc('%');
    8000071a:	8556                	mv	a0,s5
    8000071c:	00000097          	auipc	ra,0x0
    80000720:	b5a080e7          	jalr	-1190(ra) # 80000276 <consputc>
      consputc(c);
    80000724:	8526                	mv	a0,s1
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b50080e7          	jalr	-1200(ra) # 80000276 <consputc>
      break;
    8000072e:	bdc5                	j	8000061e <printf+0x9a>
  if(locking)
    80000730:	020d9163          	bnez	s11,80000752 <printf+0x1ce>
}
    80000734:	70e6                	ld	ra,120(sp)
    80000736:	7446                	ld	s0,112(sp)
    80000738:	74a6                	ld	s1,104(sp)
    8000073a:	7906                	ld	s2,96(sp)
    8000073c:	69e6                	ld	s3,88(sp)
    8000073e:	6a46                	ld	s4,80(sp)
    80000740:	6aa6                	ld	s5,72(sp)
    80000742:	6b06                	ld	s6,64(sp)
    80000744:	7be2                	ld	s7,56(sp)
    80000746:	7c42                	ld	s8,48(sp)
    80000748:	7ca2                	ld	s9,40(sp)
    8000074a:	7d02                	ld	s10,32(sp)
    8000074c:	6de2                	ld	s11,24(sp)
    8000074e:	6129                	addi	sp,sp,192
    80000750:	8082                	ret
    release(&pr.lock);
    80000752:	00011517          	auipc	a0,0x11
    80000756:	ad650513          	addi	a0,a0,-1322 # 80011228 <pr>
    8000075a:	00000097          	auipc	ra,0x0
    8000075e:	52a080e7          	jalr	1322(ra) # 80000c84 <release>
}
    80000762:	bfc9                	j	80000734 <printf+0x1b0>

0000000080000764 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000764:	1101                	addi	sp,sp,-32
    80000766:	ec06                	sd	ra,24(sp)
    80000768:	e822                	sd	s0,16(sp)
    8000076a:	e426                	sd	s1,8(sp)
    8000076c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000076e:	00011497          	auipc	s1,0x11
    80000772:	aba48493          	addi	s1,s1,-1350 # 80011228 <pr>
    80000776:	00008597          	auipc	a1,0x8
    8000077a:	8c258593          	addi	a1,a1,-1854 # 80008038 <etext+0x38>
    8000077e:	8526                	mv	a0,s1
    80000780:	00000097          	auipc	ra,0x0
    80000784:	3c0080e7          	jalr	960(ra) # 80000b40 <initlock>
  pr.locking = 1;
    80000788:	4785                	li	a5,1
    8000078a:	cc9c                	sw	a5,24(s1)
}
    8000078c:	60e2                	ld	ra,24(sp)
    8000078e:	6442                	ld	s0,16(sp)
    80000790:	64a2                	ld	s1,8(sp)
    80000792:	6105                	addi	sp,sp,32
    80000794:	8082                	ret

0000000080000796 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000796:	1141                	addi	sp,sp,-16
    80000798:	e406                	sd	ra,8(sp)
    8000079a:	e022                	sd	s0,0(sp)
    8000079c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000079e:	100007b7          	lui	a5,0x10000
    800007a2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a6:	f8000713          	li	a4,-128
    800007aa:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ae:	470d                	li	a4,3
    800007b0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007b8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007bc:	469d                	li	a3,7
    800007be:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c6:	00008597          	auipc	a1,0x8
    800007ca:	89258593          	addi	a1,a1,-1902 # 80008058 <digits+0x18>
    800007ce:	00011517          	auipc	a0,0x11
    800007d2:	a7a50513          	addi	a0,a0,-1414 # 80011248 <uart_tx_lock>
    800007d6:	00000097          	auipc	ra,0x0
    800007da:	36a080e7          	jalr	874(ra) # 80000b40 <initlock>
}
    800007de:	60a2                	ld	ra,8(sp)
    800007e0:	6402                	ld	s0,0(sp)
    800007e2:	0141                	addi	sp,sp,16
    800007e4:	8082                	ret

00000000800007e6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e6:	1101                	addi	sp,sp,-32
    800007e8:	ec06                	sd	ra,24(sp)
    800007ea:	e822                	sd	s0,16(sp)
    800007ec:	e426                	sd	s1,8(sp)
    800007ee:	1000                	addi	s0,sp,32
    800007f0:	84aa                	mv	s1,a0
  push_off();
    800007f2:	00000097          	auipc	ra,0x0
    800007f6:	392080e7          	jalr	914(ra) # 80000b84 <push_off>

  if(panicked){
    800007fa:	00009797          	auipc	a5,0x9
    800007fe:	8067a783          	lw	a5,-2042(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000802:	10000737          	lui	a4,0x10000
  if(panicked){
    80000806:	c391                	beqz	a5,8000080a <uartputc_sync+0x24>
    for(;;)
    80000808:	a001                	j	80000808 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000080e:	0207f793          	andi	a5,a5,32
    80000812:	dfe5                	beqz	a5,8000080a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000814:	0ff4f513          	zext.b	a0,s1
    80000818:	100007b7          	lui	a5,0x10000
    8000081c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000820:	00000097          	auipc	ra,0x0
    80000824:	404080e7          	jalr	1028(ra) # 80000c24 <pop_off>
}
    80000828:	60e2                	ld	ra,24(sp)
    8000082a:	6442                	ld	s0,16(sp)
    8000082c:	64a2                	ld	s1,8(sp)
    8000082e:	6105                	addi	sp,sp,32
    80000830:	8082                	ret

0000000080000832 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000832:	00008797          	auipc	a5,0x8
    80000836:	7d67b783          	ld	a5,2006(a5) # 80009008 <uart_tx_r>
    8000083a:	00008717          	auipc	a4,0x8
    8000083e:	7d673703          	ld	a4,2006(a4) # 80009010 <uart_tx_w>
    80000842:	06f70a63          	beq	a4,a5,800008b6 <uartstart+0x84>
{
    80000846:	7139                	addi	sp,sp,-64
    80000848:	fc06                	sd	ra,56(sp)
    8000084a:	f822                	sd	s0,48(sp)
    8000084c:	f426                	sd	s1,40(sp)
    8000084e:	f04a                	sd	s2,32(sp)
    80000850:	ec4e                	sd	s3,24(sp)
    80000852:	e852                	sd	s4,16(sp)
    80000854:	e456                	sd	s5,8(sp)
    80000856:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000858:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085c:	00011a17          	auipc	s4,0x11
    80000860:	9eca0a13          	addi	s4,s4,-1556 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000864:	00008497          	auipc	s1,0x8
    80000868:	7a448493          	addi	s1,s1,1956 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086c:	00008997          	auipc	s3,0x8
    80000870:	7a498993          	addi	s3,s3,1956 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000874:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000878:	02077713          	andi	a4,a4,32
    8000087c:	c705                	beqz	a4,800008a4 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000087e:	01f7f713          	andi	a4,a5,31
    80000882:	9752                	add	a4,a4,s4
    80000884:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000888:	0785                	addi	a5,a5,1
    8000088a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088c:	8526                	mv	a0,s1
    8000088e:	00002097          	auipc	ra,0x2
    80000892:	9d8080e7          	jalr	-1576(ra) # 80002266 <wakeup>
    
    WriteReg(THR, c);
    80000896:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089a:	609c                	ld	a5,0(s1)
    8000089c:	0009b703          	ld	a4,0(s3)
    800008a0:	fcf71ae3          	bne	a4,a5,80000874 <uartstart+0x42>
  }
}
    800008a4:	70e2                	ld	ra,56(sp)
    800008a6:	7442                	ld	s0,48(sp)
    800008a8:	74a2                	ld	s1,40(sp)
    800008aa:	7902                	ld	s2,32(sp)
    800008ac:	69e2                	ld	s3,24(sp)
    800008ae:	6a42                	ld	s4,16(sp)
    800008b0:	6aa2                	ld	s5,8(sp)
    800008b2:	6121                	addi	sp,sp,64
    800008b4:	8082                	ret
    800008b6:	8082                	ret

00000000800008b8 <uartputc>:
{
    800008b8:	7179                	addi	sp,sp,-48
    800008ba:	f406                	sd	ra,40(sp)
    800008bc:	f022                	sd	s0,32(sp)
    800008be:	ec26                	sd	s1,24(sp)
    800008c0:	e84a                	sd	s2,16(sp)
    800008c2:	e44e                	sd	s3,8(sp)
    800008c4:	e052                	sd	s4,0(sp)
    800008c6:	1800                	addi	s0,sp,48
    800008c8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ca:	00011517          	auipc	a0,0x11
    800008ce:	97e50513          	addi	a0,a0,-1666 # 80011248 <uart_tx_lock>
    800008d2:	00000097          	auipc	ra,0x0
    800008d6:	2fe080e7          	jalr	766(ra) # 80000bd0 <acquire>
  if(panicked){
    800008da:	00008797          	auipc	a5,0x8
    800008de:	7267a783          	lw	a5,1830(a5) # 80009000 <panicked>
    800008e2:	c391                	beqz	a5,800008e6 <uartputc+0x2e>
    for(;;)
    800008e4:	a001                	j	800008e4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	72a73703          	ld	a4,1834(a4) # 80009010 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	71a7b783          	ld	a5,1818(a5) # 80009008 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    800008fa:	02e79b63          	bne	a5,a4,80000930 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00011997          	auipc	s3,0x11
    80000902:	94a98993          	addi	s3,s3,-1718 # 80011248 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	70248493          	addi	s1,s1,1794 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	70290913          	addi	s2,s2,1794 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	7c0080e7          	jalr	1984(ra) # 800020da <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00011497          	auipc	s1,0x11
    80000934:	91848493          	addi	s1,s1,-1768 # 80011248 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	6ce7b623          	sd	a4,1740(a5) # 80009010 <uart_tx_w>
      uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee6080e7          	jalr	-282(ra) # 80000832 <uartstart>
      release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	32e080e7          	jalr	814(ra) # 80000c84 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret

000000008000096e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000096e:	1141                	addi	sp,sp,-16
    80000970:	e422                	sd	s0,8(sp)
    80000972:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000974:	100007b7          	lui	a5,0x10000
    80000978:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097c:	8b85                	andi	a5,a5,1
    8000097e:	cb81                	beqz	a5,8000098e <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000980:	100007b7          	lui	a5,0x10000
    80000984:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000988:	6422                	ld	s0,8(sp)
    8000098a:	0141                	addi	sp,sp,16
    8000098c:	8082                	ret
    return -1;
    8000098e:	557d                	li	a0,-1
    80000990:	bfe5                	j	80000988 <uartgetc+0x1a>

0000000080000992 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000992:	1101                	addi	sp,sp,-32
    80000994:	ec06                	sd	ra,24(sp)
    80000996:	e822                	sd	s0,16(sp)
    80000998:	e426                	sd	s1,8(sp)
    8000099a:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099c:	54fd                	li	s1,-1
    8000099e:	a029                	j	800009a8 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a0:	00000097          	auipc	ra,0x0
    800009a4:	918080e7          	jalr	-1768(ra) # 800002b8 <consoleintr>
    int c = uartgetc();
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	fc6080e7          	jalr	-58(ra) # 8000096e <uartgetc>
    if(c == -1)
    800009b0:	fe9518e3          	bne	a0,s1,800009a0 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b4:	00011497          	auipc	s1,0x11
    800009b8:	89448493          	addi	s1,s1,-1900 # 80011248 <uart_tx_lock>
    800009bc:	8526                	mv	a0,s1
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	212080e7          	jalr	530(ra) # 80000bd0 <acquire>
  uartstart();
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	e6c080e7          	jalr	-404(ra) # 80000832 <uartstart>
  release(&uart_tx_lock);
    800009ce:	8526                	mv	a0,s1
    800009d0:	00000097          	auipc	ra,0x0
    800009d4:	2b4080e7          	jalr	692(ra) # 80000c84 <release>
}
    800009d8:	60e2                	ld	ra,24(sp)
    800009da:	6442                	ld	s0,16(sp)
    800009dc:	64a2                	ld	s1,8(sp)
    800009de:	6105                	addi	sp,sp,32
    800009e0:	8082                	ret

00000000800009e2 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e2:	1101                	addi	sp,sp,-32
    800009e4:	ec06                	sd	ra,24(sp)
    800009e6:	e822                	sd	s0,16(sp)
    800009e8:	e426                	sd	s1,8(sp)
    800009ea:	e04a                	sd	s2,0(sp)
    800009ec:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009ee:	03451793          	slli	a5,a0,0x34
    800009f2:	ebb9                	bnez	a5,80000a48 <kfree+0x66>
    800009f4:	84aa                	mv	s1,a0
    800009f6:	00025797          	auipc	a5,0x25
    800009fa:	60a78793          	addi	a5,a5,1546 # 80026000 <end>
    800009fe:	04f56563          	bltu	a0,a5,80000a48 <kfree+0x66>
    80000a02:	47c5                	li	a5,17
    80000a04:	07ee                	slli	a5,a5,0x1b
    80000a06:	04f57163          	bgeu	a0,a5,80000a48 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0a:	6605                	lui	a2,0x1
    80000a0c:	4585                	li	a1,1
    80000a0e:	00000097          	auipc	ra,0x0
    80000a12:	2be080e7          	jalr	702(ra) # 80000ccc <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a16:	00011917          	auipc	s2,0x11
    80000a1a:	86a90913          	addi	s2,s2,-1942 # 80011280 <kmem>
    80000a1e:	854a                	mv	a0,s2
    80000a20:	00000097          	auipc	ra,0x0
    80000a24:	1b0080e7          	jalr	432(ra) # 80000bd0 <acquire>
  r->next = kmem.freelist;
    80000a28:	01893783          	ld	a5,24(s2)
    80000a2c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a32:	854a                	mv	a0,s2
    80000a34:	00000097          	auipc	ra,0x0
    80000a38:	250080e7          	jalr	592(ra) # 80000c84 <release>
}
    80000a3c:	60e2                	ld	ra,24(sp)
    80000a3e:	6442                	ld	s0,16(sp)
    80000a40:	64a2                	ld	s1,8(sp)
    80000a42:	6902                	ld	s2,0(sp)
    80000a44:	6105                	addi	sp,sp,32
    80000a46:	8082                	ret
    panic("kfree");
    80000a48:	00007517          	auipc	a0,0x7
    80000a4c:	61850513          	addi	a0,a0,1560 # 80008060 <digits+0x20>
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	aea080e7          	jalr	-1302(ra) # 8000053a <panic>

0000000080000a58 <freerange>:
{
    80000a58:	7179                	addi	sp,sp,-48
    80000a5a:	f406                	sd	ra,40(sp)
    80000a5c:	f022                	sd	s0,32(sp)
    80000a5e:	ec26                	sd	s1,24(sp)
    80000a60:	e84a                	sd	s2,16(sp)
    80000a62:	e44e                	sd	s3,8(sp)
    80000a64:	e052                	sd	s4,0(sp)
    80000a66:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a68:	6785                	lui	a5,0x1
    80000a6a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a6e:	00e504b3          	add	s1,a0,a4
    80000a72:	777d                	lui	a4,0xfffff
    80000a74:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a76:	94be                	add	s1,s1,a5
    80000a78:	0095ee63          	bltu	a1,s1,80000a94 <freerange+0x3c>
    80000a7c:	892e                	mv	s2,a1
    kfree(p);
    80000a7e:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	6985                	lui	s3,0x1
    kfree(p);
    80000a82:	01448533          	add	a0,s1,s4
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	f5c080e7          	jalr	-164(ra) # 800009e2 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8e:	94ce                	add	s1,s1,s3
    80000a90:	fe9979e3          	bgeu	s2,s1,80000a82 <freerange+0x2a>
}
    80000a94:	70a2                	ld	ra,40(sp)
    80000a96:	7402                	ld	s0,32(sp)
    80000a98:	64e2                	ld	s1,24(sp)
    80000a9a:	6942                	ld	s2,16(sp)
    80000a9c:	69a2                	ld	s3,8(sp)
    80000a9e:	6a02                	ld	s4,0(sp)
    80000aa0:	6145                	addi	sp,sp,48
    80000aa2:	8082                	ret

0000000080000aa4 <kinit>:
{
    80000aa4:	1141                	addi	sp,sp,-16
    80000aa6:	e406                	sd	ra,8(sp)
    80000aa8:	e022                	sd	s0,0(sp)
    80000aaa:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aac:	00007597          	auipc	a1,0x7
    80000ab0:	5bc58593          	addi	a1,a1,1468 # 80008068 <digits+0x28>
    80000ab4:	00010517          	auipc	a0,0x10
    80000ab8:	7cc50513          	addi	a0,a0,1996 # 80011280 <kmem>
    80000abc:	00000097          	auipc	ra,0x0
    80000ac0:	084080e7          	jalr	132(ra) # 80000b40 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac4:	45c5                	li	a1,17
    80000ac6:	05ee                	slli	a1,a1,0x1b
    80000ac8:	00025517          	auipc	a0,0x25
    80000acc:	53850513          	addi	a0,a0,1336 # 80026000 <end>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	f88080e7          	jalr	-120(ra) # 80000a58 <freerange>
}
    80000ad8:	60a2                	ld	ra,8(sp)
    80000ada:	6402                	ld	s0,0(sp)
    80000adc:	0141                	addi	sp,sp,16
    80000ade:	8082                	ret

0000000080000ae0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae0:	1101                	addi	sp,sp,-32
    80000ae2:	ec06                	sd	ra,24(sp)
    80000ae4:	e822                	sd	s0,16(sp)
    80000ae6:	e426                	sd	s1,8(sp)
    80000ae8:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aea:	00010497          	auipc	s1,0x10
    80000aee:	79648493          	addi	s1,s1,1942 # 80011280 <kmem>
    80000af2:	8526                	mv	a0,s1
    80000af4:	00000097          	auipc	ra,0x0
    80000af8:	0dc080e7          	jalr	220(ra) # 80000bd0 <acquire>
  r = kmem.freelist;
    80000afc:	6c84                	ld	s1,24(s1)
  if(r)
    80000afe:	c885                	beqz	s1,80000b2e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b00:	609c                	ld	a5,0(s1)
    80000b02:	00010517          	auipc	a0,0x10
    80000b06:	77e50513          	addi	a0,a0,1918 # 80011280 <kmem>
    80000b0a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	178080e7          	jalr	376(ra) # 80000c84 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b14:	6605                	lui	a2,0x1
    80000b16:	4595                	li	a1,5
    80000b18:	8526                	mv	a0,s1
    80000b1a:	00000097          	auipc	ra,0x0
    80000b1e:	1b2080e7          	jalr	434(ra) # 80000ccc <memset>
  return (void*)r;
}
    80000b22:	8526                	mv	a0,s1
    80000b24:	60e2                	ld	ra,24(sp)
    80000b26:	6442                	ld	s0,16(sp)
    80000b28:	64a2                	ld	s1,8(sp)
    80000b2a:	6105                	addi	sp,sp,32
    80000b2c:	8082                	ret
  release(&kmem.lock);
    80000b2e:	00010517          	auipc	a0,0x10
    80000b32:	75250513          	addi	a0,a0,1874 # 80011280 <kmem>
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	14e080e7          	jalr	334(ra) # 80000c84 <release>
  if(r)
    80000b3e:	b7d5                	j	80000b22 <kalloc+0x42>

0000000080000b40 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b40:	1141                	addi	sp,sp,-16
    80000b42:	e422                	sd	s0,8(sp)
    80000b44:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b46:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b48:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4c:	00053823          	sd	zero,16(a0)
}
    80000b50:	6422                	ld	s0,8(sp)
    80000b52:	0141                	addi	sp,sp,16
    80000b54:	8082                	ret

0000000080000b56 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b56:	411c                	lw	a5,0(a0)
    80000b58:	e399                	bnez	a5,80000b5e <holding+0x8>
    80000b5a:	4501                	li	a0,0
  return r;
}
    80000b5c:	8082                	ret
{
    80000b5e:	1101                	addi	sp,sp,-32
    80000b60:	ec06                	sd	ra,24(sp)
    80000b62:	e822                	sd	s0,16(sp)
    80000b64:	e426                	sd	s1,8(sp)
    80000b66:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b68:	6904                	ld	s1,16(a0)
    80000b6a:	00001097          	auipc	ra,0x1
    80000b6e:	e90080e7          	jalr	-368(ra) # 800019fa <mycpu>
    80000b72:	40a48533          	sub	a0,s1,a0
    80000b76:	00153513          	seqz	a0,a0
}
    80000b7a:	60e2                	ld	ra,24(sp)
    80000b7c:	6442                	ld	s0,16(sp)
    80000b7e:	64a2                	ld	s1,8(sp)
    80000b80:	6105                	addi	sp,sp,32
    80000b82:	8082                	ret

0000000080000b84 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b84:	1101                	addi	sp,sp,-32
    80000b86:	ec06                	sd	ra,24(sp)
    80000b88:	e822                	sd	s0,16(sp)
    80000b8a:	e426                	sd	s1,8(sp)
    80000b8c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b8e:	100024f3          	csrr	s1,sstatus
    80000b92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b96:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b98:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9c:	00001097          	auipc	ra,0x1
    80000ba0:	e5e080e7          	jalr	-418(ra) # 800019fa <mycpu>
    80000ba4:	5d3c                	lw	a5,120(a0)
    80000ba6:	cf89                	beqz	a5,80000bc0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ba8:	00001097          	auipc	ra,0x1
    80000bac:	e52080e7          	jalr	-430(ra) # 800019fa <mycpu>
    80000bb0:	5d3c                	lw	a5,120(a0)
    80000bb2:	2785                	addiw	a5,a5,1
    80000bb4:	dd3c                	sw	a5,120(a0)
}
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret
    mycpu()->intena = old;
    80000bc0:	00001097          	auipc	ra,0x1
    80000bc4:	e3a080e7          	jalr	-454(ra) # 800019fa <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc8:	8085                	srli	s1,s1,0x1
    80000bca:	8885                	andi	s1,s1,1
    80000bcc:	dd64                	sw	s1,124(a0)
    80000bce:	bfe9                	j	80000ba8 <push_off+0x24>

0000000080000bd0 <acquire>:
{
    80000bd0:	1101                	addi	sp,sp,-32
    80000bd2:	ec06                	sd	ra,24(sp)
    80000bd4:	e822                	sd	s0,16(sp)
    80000bd6:	e426                	sd	s1,8(sp)
    80000bd8:	1000                	addi	s0,sp,32
    80000bda:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bdc:	00000097          	auipc	ra,0x0
    80000be0:	fa8080e7          	jalr	-88(ra) # 80000b84 <push_off>
  if(holding(lk))
    80000be4:	8526                	mv	a0,s1
    80000be6:	00000097          	auipc	ra,0x0
    80000bea:	f70080e7          	jalr	-144(ra) # 80000b56 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bee:	4705                	li	a4,1
  if(holding(lk))
    80000bf0:	e115                	bnez	a0,80000c14 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf2:	87ba                	mv	a5,a4
    80000bf4:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bf8:	2781                	sext.w	a5,a5
    80000bfa:	ffe5                	bnez	a5,80000bf2 <acquire+0x22>
  __sync_synchronize();
    80000bfc:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c00:	00001097          	auipc	ra,0x1
    80000c04:	dfa080e7          	jalr	-518(ra) # 800019fa <mycpu>
    80000c08:	e888                	sd	a0,16(s1)
}
    80000c0a:	60e2                	ld	ra,24(sp)
    80000c0c:	6442                	ld	s0,16(sp)
    80000c0e:	64a2                	ld	s1,8(sp)
    80000c10:	6105                	addi	sp,sp,32
    80000c12:	8082                	ret
    panic("acquire");
    80000c14:	00007517          	auipc	a0,0x7
    80000c18:	45c50513          	addi	a0,a0,1116 # 80008070 <digits+0x30>
    80000c1c:	00000097          	auipc	ra,0x0
    80000c20:	91e080e7          	jalr	-1762(ra) # 8000053a <panic>

0000000080000c24 <pop_off>:

void
pop_off(void)
{
    80000c24:	1141                	addi	sp,sp,-16
    80000c26:	e406                	sd	ra,8(sp)
    80000c28:	e022                	sd	s0,0(sp)
    80000c2a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2c:	00001097          	auipc	ra,0x1
    80000c30:	dce080e7          	jalr	-562(ra) # 800019fa <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c34:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c38:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3a:	e78d                	bnez	a5,80000c64 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3c:	5d3c                	lw	a5,120(a0)
    80000c3e:	02f05b63          	blez	a5,80000c74 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c42:	37fd                	addiw	a5,a5,-1
    80000c44:	0007871b          	sext.w	a4,a5
    80000c48:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4a:	eb09                	bnez	a4,80000c5c <pop_off+0x38>
    80000c4c:	5d7c                	lw	a5,124(a0)
    80000c4e:	c799                	beqz	a5,80000c5c <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c50:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c54:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c58:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5c:	60a2                	ld	ra,8(sp)
    80000c5e:	6402                	ld	s0,0(sp)
    80000c60:	0141                	addi	sp,sp,16
    80000c62:	8082                	ret
    panic("pop_off - interruptible");
    80000c64:	00007517          	auipc	a0,0x7
    80000c68:	41450513          	addi	a0,a0,1044 # 80008078 <digits+0x38>
    80000c6c:	00000097          	auipc	ra,0x0
    80000c70:	8ce080e7          	jalr	-1842(ra) # 8000053a <panic>
    panic("pop_off");
    80000c74:	00007517          	auipc	a0,0x7
    80000c78:	41c50513          	addi	a0,a0,1052 # 80008090 <digits+0x50>
    80000c7c:	00000097          	auipc	ra,0x0
    80000c80:	8be080e7          	jalr	-1858(ra) # 8000053a <panic>

0000000080000c84 <release>:
{
    80000c84:	1101                	addi	sp,sp,-32
    80000c86:	ec06                	sd	ra,24(sp)
    80000c88:	e822                	sd	s0,16(sp)
    80000c8a:	e426                	sd	s1,8(sp)
    80000c8c:	1000                	addi	s0,sp,32
    80000c8e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	ec6080e7          	jalr	-314(ra) # 80000b56 <holding>
    80000c98:	c115                	beqz	a0,80000cbc <release+0x38>
  lk->cpu = 0;
    80000c9a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c9e:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca2:	0f50000f          	fence	iorw,ow
    80000ca6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	f7a080e7          	jalr	-134(ra) # 80000c24 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00007517          	auipc	a0,0x7
    80000cc0:	3dc50513          	addi	a0,a0,988 # 80008098 <digits+0x58>
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	876080e7          	jalr	-1930(ra) # 8000053a <panic>

0000000080000ccc <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ccc:	1141                	addi	sp,sp,-16
    80000cce:	e422                	sd	s0,8(sp)
    80000cd0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd2:	ca19                	beqz	a2,80000ce8 <memset+0x1c>
    80000cd4:	87aa                	mv	a5,a0
    80000cd6:	1602                	slli	a2,a2,0x20
    80000cd8:	9201                	srli	a2,a2,0x20
    80000cda:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cde:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce2:	0785                	addi	a5,a5,1
    80000ce4:	fee79de3          	bne	a5,a4,80000cde <memset+0x12>
  }
  return dst;
}
    80000ce8:	6422                	ld	s0,8(sp)
    80000cea:	0141                	addi	sp,sp,16
    80000cec:	8082                	ret

0000000080000cee <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cee:	1141                	addi	sp,sp,-16
    80000cf0:	e422                	sd	s0,8(sp)
    80000cf2:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf4:	ca05                	beqz	a2,80000d24 <memcmp+0x36>
    80000cf6:	fff6069b          	addiw	a3,a2,-1
    80000cfa:	1682                	slli	a3,a3,0x20
    80000cfc:	9281                	srli	a3,a3,0x20
    80000cfe:	0685                	addi	a3,a3,1
    80000d00:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d02:	00054783          	lbu	a5,0(a0)
    80000d06:	0005c703          	lbu	a4,0(a1)
    80000d0a:	00e79863          	bne	a5,a4,80000d1a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0e:	0505                	addi	a0,a0,1
    80000d10:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d12:	fed518e3          	bne	a0,a3,80000d02 <memcmp+0x14>
  }

  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	a019                	j	80000d1e <memcmp+0x30>
      return *s1 - *s2;
    80000d1a:	40e7853b          	subw	a0,a5,a4
}
    80000d1e:	6422                	ld	s0,8(sp)
    80000d20:	0141                	addi	sp,sp,16
    80000d22:	8082                	ret
  return 0;
    80000d24:	4501                	li	a0,0
    80000d26:	bfe5                	j	80000d1e <memcmp+0x30>

0000000080000d28 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d28:	1141                	addi	sp,sp,-16
    80000d2a:	e422                	sd	s0,8(sp)
    80000d2c:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2e:	c205                	beqz	a2,80000d4e <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d30:	02a5e263          	bltu	a1,a0,80000d54 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d34:	1602                	slli	a2,a2,0x20
    80000d36:	9201                	srli	a2,a2,0x20
    80000d38:	00c587b3          	add	a5,a1,a2
{
    80000d3c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3e:	0585                	addi	a1,a1,1
    80000d40:	0705                	addi	a4,a4,1
    80000d42:	fff5c683          	lbu	a3,-1(a1)
    80000d46:	fed70fa3          	sb	a3,-1(a4) # ffffffffffffefff <end+0xffffffff7ffd8fff>
    while(n-- > 0)
    80000d4a:	fef59ae3          	bne	a1,a5,80000d3e <memmove+0x16>

  return dst;
}
    80000d4e:	6422                	ld	s0,8(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  if(s < d && s + n > d){
    80000d54:	02061693          	slli	a3,a2,0x20
    80000d58:	9281                	srli	a3,a3,0x20
    80000d5a:	00d58733          	add	a4,a1,a3
    80000d5e:	fce57be3          	bgeu	a0,a4,80000d34 <memmove+0xc>
    d += n;
    80000d62:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d64:	fff6079b          	addiw	a5,a2,-1
    80000d68:	1782                	slli	a5,a5,0x20
    80000d6a:	9381                	srli	a5,a5,0x20
    80000d6c:	fff7c793          	not	a5,a5
    80000d70:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d72:	177d                	addi	a4,a4,-1
    80000d74:	16fd                	addi	a3,a3,-1
    80000d76:	00074603          	lbu	a2,0(a4)
    80000d7a:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7e:	fee79ae3          	bne	a5,a4,80000d72 <memmove+0x4a>
    80000d82:	b7f1                	j	80000d4e <memmove+0x26>

0000000080000d84 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d84:	1141                	addi	sp,sp,-16
    80000d86:	e406                	sd	ra,8(sp)
    80000d88:	e022                	sd	s0,0(sp)
    80000d8a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8c:	00000097          	auipc	ra,0x0
    80000d90:	f9c080e7          	jalr	-100(ra) # 80000d28 <memmove>
}
    80000d94:	60a2                	ld	ra,8(sp)
    80000d96:	6402                	ld	s0,0(sp)
    80000d98:	0141                	addi	sp,sp,16
    80000d9a:	8082                	ret

0000000080000d9c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9c:	1141                	addi	sp,sp,-16
    80000d9e:	e422                	sd	s0,8(sp)
    80000da0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da2:	ce11                	beqz	a2,80000dbe <strncmp+0x22>
    80000da4:	00054783          	lbu	a5,0(a0)
    80000da8:	cf89                	beqz	a5,80000dc2 <strncmp+0x26>
    80000daa:	0005c703          	lbu	a4,0(a1)
    80000dae:	00f71a63          	bne	a4,a5,80000dc2 <strncmp+0x26>
    n--, p++, q++;
    80000db2:	367d                	addiw	a2,a2,-1
    80000db4:	0505                	addi	a0,a0,1
    80000db6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db8:	f675                	bnez	a2,80000da4 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dba:	4501                	li	a0,0
    80000dbc:	a809                	j	80000dce <strncmp+0x32>
    80000dbe:	4501                	li	a0,0
    80000dc0:	a039                	j	80000dce <strncmp+0x32>
  if(n == 0)
    80000dc2:	ca09                	beqz	a2,80000dd4 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc4:	00054503          	lbu	a0,0(a0)
    80000dc8:	0005c783          	lbu	a5,0(a1)
    80000dcc:	9d1d                	subw	a0,a0,a5
}
    80000dce:	6422                	ld	s0,8(sp)
    80000dd0:	0141                	addi	sp,sp,16
    80000dd2:	8082                	ret
    return 0;
    80000dd4:	4501                	li	a0,0
    80000dd6:	bfe5                	j	80000dce <strncmp+0x32>

0000000080000dd8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd8:	1141                	addi	sp,sp,-16
    80000dda:	e422                	sd	s0,8(sp)
    80000ddc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dde:	872a                	mv	a4,a0
    80000de0:	8832                	mv	a6,a2
    80000de2:	367d                	addiw	a2,a2,-1
    80000de4:	01005963          	blez	a6,80000df6 <strncpy+0x1e>
    80000de8:	0705                	addi	a4,a4,1
    80000dea:	0005c783          	lbu	a5,0(a1)
    80000dee:	fef70fa3          	sb	a5,-1(a4)
    80000df2:	0585                	addi	a1,a1,1
    80000df4:	f7f5                	bnez	a5,80000de0 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df6:	86ba                	mv	a3,a4
    80000df8:	00c05c63          	blez	a2,80000e10 <strncpy+0x38>
    *s++ = 0;
    80000dfc:	0685                	addi	a3,a3,1
    80000dfe:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e02:	40d707bb          	subw	a5,a4,a3
    80000e06:	37fd                	addiw	a5,a5,-1
    80000e08:	010787bb          	addw	a5,a5,a6
    80000e0c:	fef048e3          	bgtz	a5,80000dfc <strncpy+0x24>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	4685                	li	a3,1
    80000e5a:	9e89                	subw	a3,a3,a0
    80000e5c:	00f6853b          	addw	a0,a3,a5
    80000e60:	0785                	addi	a5,a5,1
    80000e62:	fff7c703          	lbu	a4,-1(a5)
    80000e66:	fb7d                	bnez	a4,80000e5c <strlen+0x14>
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b70080e7          	jalr	-1168(ra) # 800019ea <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	19670713          	addi	a4,a4,406 # 80009018 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	b54080e7          	jalr	-1196(ra) # 800019ea <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6dc080e7          	jalr	1756(ra) # 80000584 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	7b4080e7          	jalr	1972(ra) # 8000266c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	dd0080e7          	jalr	-560(ra) # 80005c90 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	060080e7          	jalr	96(ra) # 80001f28 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57a080e7          	jalr	1402(ra) # 8000044a <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88c080e7          	jalr	-1908(ra) # 80000764 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	addi	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69c080e7          	jalr	1692(ra) # 80000584 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68c080e7          	jalr	1676(ra) # 80000584 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	addi	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67c080e7          	jalr	1660(ra) # 80000584 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b94080e7          	jalr	-1132(ra) # 80000aa4 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	322080e7          	jalr	802(ra) # 8000123a <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	a12080e7          	jalr	-1518(ra) # 8000193a <procinit>
    trapinit();      // trap vectors
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	714080e7          	jalr	1812(ra) # 80002644 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	734080e7          	jalr	1844(ra) # 8000266c <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	d3a080e7          	jalr	-710(ra) # 80005c7a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	d48080e7          	jalr	-696(ra) # 80005c90 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	f06080e7          	jalr	-250(ra) # 80002e56 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	594080e7          	jalr	1428(ra) # 800034ec <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	546080e7          	jalr	1350(ra) # 800044a6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	e48080e7          	jalr	-440(ra) # 80005db0 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d7e080e7          	jalr	-642(ra) # 80001cee <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	08f72d23          	sw	a5,154(a4) # 80009018 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f8e:	00008797          	auipc	a5,0x8
    80000f92:	0927b783          	ld	a5,146(a5) # 80009020 <kernel_pagetable>
    80000f96:	83b1                	srli	a5,a5,0xc
    80000f98:	577d                	li	a4,-1
    80000f9a:	177e                	slli	a4,a4,0x3f
    80000f9c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f9e:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fa2:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa6:	6422                	ld	s0,8(sp)
    80000fa8:	0141                	addi	sp,sp,16
    80000faa:	8082                	ret

0000000080000fac <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fac:	7139                	addi	sp,sp,-64
    80000fae:	fc06                	sd	ra,56(sp)
    80000fb0:	f822                	sd	s0,48(sp)
    80000fb2:	f426                	sd	s1,40(sp)
    80000fb4:	f04a                	sd	s2,32(sp)
    80000fb6:	ec4e                	sd	s3,24(sp)
    80000fb8:	e852                	sd	s4,16(sp)
    80000fba:	e456                	sd	s5,8(sp)
    80000fbc:	e05a                	sd	s6,0(sp)
    80000fbe:	0080                	addi	s0,sp,64
    80000fc0:	84aa                	mv	s1,a0
    80000fc2:	89ae                	mv	s3,a1
    80000fc4:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc6:	57fd                	li	a5,-1
    80000fc8:	83e9                	srli	a5,a5,0x1a
    80000fca:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fcc:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fce:	04b7f263          	bgeu	a5,a1,80001012 <walk+0x66>
    panic("walk");
    80000fd2:	00007517          	auipc	a0,0x7
    80000fd6:	0fe50513          	addi	a0,a0,254 # 800080d0 <digits+0x90>
    80000fda:	fffff097          	auipc	ra,0xfffff
    80000fde:	560080e7          	jalr	1376(ra) # 8000053a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe2:	060a8663          	beqz	s5,8000104e <walk+0xa2>
    80000fe6:	00000097          	auipc	ra,0x0
    80000fea:	afa080e7          	jalr	-1286(ra) # 80000ae0 <kalloc>
    80000fee:	84aa                	mv	s1,a0
    80000ff0:	c529                	beqz	a0,8000103a <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff2:	6605                	lui	a2,0x1
    80000ff4:	4581                	li	a1,0
    80000ff6:	00000097          	auipc	ra,0x0
    80000ffa:	cd6080e7          	jalr	-810(ra) # 80000ccc <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ffe:	00c4d793          	srli	a5,s1,0xc
    80001002:	07aa                	slli	a5,a5,0xa
    80001004:	0017e793          	ori	a5,a5,1
    80001008:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000100c:	3a5d                	addiw	s4,s4,-9
    8000100e:	036a0063          	beq	s4,s6,8000102e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001012:	0149d933          	srl	s2,s3,s4
    80001016:	1ff97913          	andi	s2,s2,511
    8000101a:	090e                	slli	s2,s2,0x3
    8000101c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000101e:	00093483          	ld	s1,0(s2)
    80001022:	0014f793          	andi	a5,s1,1
    80001026:	dfd5                	beqz	a5,80000fe2 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001028:	80a9                	srli	s1,s1,0xa
    8000102a:	04b2                	slli	s1,s1,0xc
    8000102c:	b7c5                	j	8000100c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000102e:	00c9d513          	srli	a0,s3,0xc
    80001032:	1ff57513          	andi	a0,a0,511
    80001036:	050e                	slli	a0,a0,0x3
    80001038:	9526                	add	a0,a0,s1
}
    8000103a:	70e2                	ld	ra,56(sp)
    8000103c:	7442                	ld	s0,48(sp)
    8000103e:	74a2                	ld	s1,40(sp)
    80001040:	7902                	ld	s2,32(sp)
    80001042:	69e2                	ld	s3,24(sp)
    80001044:	6a42                	ld	s4,16(sp)
    80001046:	6aa2                	ld	s5,8(sp)
    80001048:	6b02                	ld	s6,0(sp)
    8000104a:	6121                	addi	sp,sp,64
    8000104c:	8082                	ret
        return 0;
    8000104e:	4501                	li	a0,0
    80001050:	b7ed                	j	8000103a <walk+0x8e>

0000000080001052 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001052:	57fd                	li	a5,-1
    80001054:	83e9                	srli	a5,a5,0x1a
    80001056:	00b7f463          	bgeu	a5,a1,8000105e <walkaddr+0xc>
    return 0;
    8000105a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000105c:	8082                	ret
{
    8000105e:	1141                	addi	sp,sp,-16
    80001060:	e406                	sd	ra,8(sp)
    80001062:	e022                	sd	s0,0(sp)
    80001064:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001066:	4601                	li	a2,0
    80001068:	00000097          	auipc	ra,0x0
    8000106c:	f44080e7          	jalr	-188(ra) # 80000fac <walk>
  if(pte == 0)
    80001070:	c105                	beqz	a0,80001090 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001072:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001074:	0117f693          	andi	a3,a5,17
    80001078:	4745                	li	a4,17
    return 0;
    8000107a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000107c:	00e68663          	beq	a3,a4,80001088 <walkaddr+0x36>
}
    80001080:	60a2                	ld	ra,8(sp)
    80001082:	6402                	ld	s0,0(sp)
    80001084:	0141                	addi	sp,sp,16
    80001086:	8082                	ret
  pa = PTE2PA(*pte);
    80001088:	83a9                	srli	a5,a5,0xa
    8000108a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000108e:	bfcd                	j	80001080 <walkaddr+0x2e>
    return 0;
    80001090:	4501                	li	a0,0
    80001092:	b7fd                	j	80001080 <walkaddr+0x2e>

0000000080001094 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001094:	715d                	addi	sp,sp,-80
    80001096:	e486                	sd	ra,72(sp)
    80001098:	e0a2                	sd	s0,64(sp)
    8000109a:	fc26                	sd	s1,56(sp)
    8000109c:	f84a                	sd	s2,48(sp)
    8000109e:	f44e                	sd	s3,40(sp)
    800010a0:	f052                	sd	s4,32(sp)
    800010a2:	ec56                	sd	s5,24(sp)
    800010a4:	e85a                	sd	s6,16(sp)
    800010a6:	e45e                	sd	s7,8(sp)
    800010a8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010aa:	c639                	beqz	a2,800010f8 <mappages+0x64>
    800010ac:	8aaa                	mv	s5,a0
    800010ae:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b0:	777d                	lui	a4,0xfffff
    800010b2:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010b6:	fff58993          	addi	s3,a1,-1
    800010ba:	99b2                	add	s3,s3,a2
    800010bc:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c0:	893e                	mv	s2,a5
    800010c2:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010c6:	6b85                	lui	s7,0x1
    800010c8:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010cc:	4605                	li	a2,1
    800010ce:	85ca                	mv	a1,s2
    800010d0:	8556                	mv	a0,s5
    800010d2:	00000097          	auipc	ra,0x0
    800010d6:	eda080e7          	jalr	-294(ra) # 80000fac <walk>
    800010da:	cd1d                	beqz	a0,80001118 <mappages+0x84>
    if(*pte & PTE_V)
    800010dc:	611c                	ld	a5,0(a0)
    800010de:	8b85                	andi	a5,a5,1
    800010e0:	e785                	bnez	a5,80001108 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e2:	80b1                	srli	s1,s1,0xc
    800010e4:	04aa                	slli	s1,s1,0xa
    800010e6:	0164e4b3          	or	s1,s1,s6
    800010ea:	0014e493          	ori	s1,s1,1
    800010ee:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f0:	05390063          	beq	s2,s3,80001130 <mappages+0x9c>
    a += PGSIZE;
    800010f4:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010f6:	bfc9                	j	800010c8 <mappages+0x34>
    panic("mappages: size");
    800010f8:	00007517          	auipc	a0,0x7
    800010fc:	fe050513          	addi	a0,a0,-32 # 800080d8 <digits+0x98>
    80001100:	fffff097          	auipc	ra,0xfffff
    80001104:	43a080e7          	jalr	1082(ra) # 8000053a <panic>
      panic("mappages: remap");
    80001108:	00007517          	auipc	a0,0x7
    8000110c:	fe050513          	addi	a0,a0,-32 # 800080e8 <digits+0xa8>
    80001110:	fffff097          	auipc	ra,0xfffff
    80001114:	42a080e7          	jalr	1066(ra) # 8000053a <panic>
      return -1;
    80001118:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111a:	60a6                	ld	ra,72(sp)
    8000111c:	6406                	ld	s0,64(sp)
    8000111e:	74e2                	ld	s1,56(sp)
    80001120:	7942                	ld	s2,48(sp)
    80001122:	79a2                	ld	s3,40(sp)
    80001124:	7a02                	ld	s4,32(sp)
    80001126:	6ae2                	ld	s5,24(sp)
    80001128:	6b42                	ld	s6,16(sp)
    8000112a:	6ba2                	ld	s7,8(sp)
    8000112c:	6161                	addi	sp,sp,80
    8000112e:	8082                	ret
  return 0;
    80001130:	4501                	li	a0,0
    80001132:	b7e5                	j	8000111a <mappages+0x86>

0000000080001134 <kvmmap>:
{
    80001134:	1141                	addi	sp,sp,-16
    80001136:	e406                	sd	ra,8(sp)
    80001138:	e022                	sd	s0,0(sp)
    8000113a:	0800                	addi	s0,sp,16
    8000113c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000113e:	86b2                	mv	a3,a2
    80001140:	863e                	mv	a2,a5
    80001142:	00000097          	auipc	ra,0x0
    80001146:	f52080e7          	jalr	-174(ra) # 80001094 <mappages>
    8000114a:	e509                	bnez	a0,80001154 <kvmmap+0x20>
}
    8000114c:	60a2                	ld	ra,8(sp)
    8000114e:	6402                	ld	s0,0(sp)
    80001150:	0141                	addi	sp,sp,16
    80001152:	8082                	ret
    panic("kvmmap");
    80001154:	00007517          	auipc	a0,0x7
    80001158:	fa450513          	addi	a0,a0,-92 # 800080f8 <digits+0xb8>
    8000115c:	fffff097          	auipc	ra,0xfffff
    80001160:	3de080e7          	jalr	990(ra) # 8000053a <panic>

0000000080001164 <kvmmake>:
{
    80001164:	1101                	addi	sp,sp,-32
    80001166:	ec06                	sd	ra,24(sp)
    80001168:	e822                	sd	s0,16(sp)
    8000116a:	e426                	sd	s1,8(sp)
    8000116c:	e04a                	sd	s2,0(sp)
    8000116e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001170:	00000097          	auipc	ra,0x0
    80001174:	970080e7          	jalr	-1680(ra) # 80000ae0 <kalloc>
    80001178:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117a:	6605                	lui	a2,0x1
    8000117c:	4581                	li	a1,0
    8000117e:	00000097          	auipc	ra,0x0
    80001182:	b4e080e7          	jalr	-1202(ra) # 80000ccc <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001186:	4719                	li	a4,6
    80001188:	6685                	lui	a3,0x1
    8000118a:	10000637          	lui	a2,0x10000
    8000118e:	100005b7          	lui	a1,0x10000
    80001192:	8526                	mv	a0,s1
    80001194:	00000097          	auipc	ra,0x0
    80001198:	fa0080e7          	jalr	-96(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000119c:	4719                	li	a4,6
    8000119e:	6685                	lui	a3,0x1
    800011a0:	10001637          	lui	a2,0x10001
    800011a4:	100015b7          	lui	a1,0x10001
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f8a080e7          	jalr	-118(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b2:	4719                	li	a4,6
    800011b4:	004006b7          	lui	a3,0x400
    800011b8:	0c000637          	lui	a2,0xc000
    800011bc:	0c0005b7          	lui	a1,0xc000
    800011c0:	8526                	mv	a0,s1
    800011c2:	00000097          	auipc	ra,0x0
    800011c6:	f72080e7          	jalr	-142(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ca:	00007917          	auipc	s2,0x7
    800011ce:	e3690913          	addi	s2,s2,-458 # 80008000 <etext>
    800011d2:	4729                	li	a4,10
    800011d4:	80007697          	auipc	a3,0x80007
    800011d8:	e2c68693          	addi	a3,a3,-468 # 8000 <_entry-0x7fff8000>
    800011dc:	4605                	li	a2,1
    800011de:	067e                	slli	a2,a2,0x1f
    800011e0:	85b2                	mv	a1,a2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f50080e7          	jalr	-176(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011ec:	4719                	li	a4,6
    800011ee:	46c5                	li	a3,17
    800011f0:	06ee                	slli	a3,a3,0x1b
    800011f2:	412686b3          	sub	a3,a3,s2
    800011f6:	864a                	mv	a2,s2
    800011f8:	85ca                	mv	a1,s2
    800011fa:	8526                	mv	a0,s1
    800011fc:	00000097          	auipc	ra,0x0
    80001200:	f38080e7          	jalr	-200(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001204:	4729                	li	a4,10
    80001206:	6685                	lui	a3,0x1
    80001208:	00006617          	auipc	a2,0x6
    8000120c:	df860613          	addi	a2,a2,-520 # 80007000 <_trampoline>
    80001210:	040005b7          	lui	a1,0x4000
    80001214:	15fd                	addi	a1,a1,-1
    80001216:	05b2                	slli	a1,a1,0xc
    80001218:	8526                	mv	a0,s1
    8000121a:	00000097          	auipc	ra,0x0
    8000121e:	f1a080e7          	jalr	-230(ra) # 80001134 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	680080e7          	jalr	1664(ra) # 800018a4 <proc_mapstacks>
}
    8000122c:	8526                	mv	a0,s1
    8000122e:	60e2                	ld	ra,24(sp)
    80001230:	6442                	ld	s0,16(sp)
    80001232:	64a2                	ld	s1,8(sp)
    80001234:	6902                	ld	s2,0(sp)
    80001236:	6105                	addi	sp,sp,32
    80001238:	8082                	ret

000000008000123a <kvminit>:
{
    8000123a:	1141                	addi	sp,sp,-16
    8000123c:	e406                	sd	ra,8(sp)
    8000123e:	e022                	sd	s0,0(sp)
    80001240:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001242:	00000097          	auipc	ra,0x0
    80001246:	f22080e7          	jalr	-222(ra) # 80001164 <kvmmake>
    8000124a:	00008797          	auipc	a5,0x8
    8000124e:	dca7bb23          	sd	a0,-554(a5) # 80009020 <kernel_pagetable>
}
    80001252:	60a2                	ld	ra,8(sp)
    80001254:	6402                	ld	s0,0(sp)
    80001256:	0141                	addi	sp,sp,16
    80001258:	8082                	ret

000000008000125a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125a:	715d                	addi	sp,sp,-80
    8000125c:	e486                	sd	ra,72(sp)
    8000125e:	e0a2                	sd	s0,64(sp)
    80001260:	fc26                	sd	s1,56(sp)
    80001262:	f84a                	sd	s2,48(sp)
    80001264:	f44e                	sd	s3,40(sp)
    80001266:	f052                	sd	s4,32(sp)
    80001268:	ec56                	sd	s5,24(sp)
    8000126a:	e85a                	sd	s6,16(sp)
    8000126c:	e45e                	sd	s7,8(sp)
    8000126e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001270:	03459793          	slli	a5,a1,0x34
    80001274:	e795                	bnez	a5,800012a0 <uvmunmap+0x46>
    80001276:	8a2a                	mv	s4,a0
    80001278:	892e                	mv	s2,a1
    8000127a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000127c:	0632                	slli	a2,a2,0xc
    8000127e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001282:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001284:	6b05                	lui	s6,0x1
    80001286:	0735e263          	bltu	a1,s3,800012ea <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128a:	60a6                	ld	ra,72(sp)
    8000128c:	6406                	ld	s0,64(sp)
    8000128e:	74e2                	ld	s1,56(sp)
    80001290:	7942                	ld	s2,48(sp)
    80001292:	79a2                	ld	s3,40(sp)
    80001294:	7a02                	ld	s4,32(sp)
    80001296:	6ae2                	ld	s5,24(sp)
    80001298:	6b42                	ld	s6,16(sp)
    8000129a:	6ba2                	ld	s7,8(sp)
    8000129c:	6161                	addi	sp,sp,80
    8000129e:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a0:	00007517          	auipc	a0,0x7
    800012a4:	e6050513          	addi	a0,a0,-416 # 80008100 <digits+0xc0>
    800012a8:	fffff097          	auipc	ra,0xfffff
    800012ac:	292080e7          	jalr	658(ra) # 8000053a <panic>
      panic("uvmunmap: walk");
    800012b0:	00007517          	auipc	a0,0x7
    800012b4:	e6850513          	addi	a0,a0,-408 # 80008118 <digits+0xd8>
    800012b8:	fffff097          	auipc	ra,0xfffff
    800012bc:	282080e7          	jalr	642(ra) # 8000053a <panic>
      panic("uvmunmap: not mapped");
    800012c0:	00007517          	auipc	a0,0x7
    800012c4:	e6850513          	addi	a0,a0,-408 # 80008128 <digits+0xe8>
    800012c8:	fffff097          	auipc	ra,0xfffff
    800012cc:	272080e7          	jalr	626(ra) # 8000053a <panic>
      panic("uvmunmap: not a leaf");
    800012d0:	00007517          	auipc	a0,0x7
    800012d4:	e7050513          	addi	a0,a0,-400 # 80008140 <digits+0x100>
    800012d8:	fffff097          	auipc	ra,0xfffff
    800012dc:	262080e7          	jalr	610(ra) # 8000053a <panic>
    *pte = 0;
    800012e0:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e4:	995a                	add	s2,s2,s6
    800012e6:	fb3972e3          	bgeu	s2,s3,8000128a <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ea:	4601                	li	a2,0
    800012ec:	85ca                	mv	a1,s2
    800012ee:	8552                	mv	a0,s4
    800012f0:	00000097          	auipc	ra,0x0
    800012f4:	cbc080e7          	jalr	-836(ra) # 80000fac <walk>
    800012f8:	84aa                	mv	s1,a0
    800012fa:	d95d                	beqz	a0,800012b0 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012fc:	6108                	ld	a0,0(a0)
    800012fe:	00157793          	andi	a5,a0,1
    80001302:	dfdd                	beqz	a5,800012c0 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001304:	3ff57793          	andi	a5,a0,1023
    80001308:	fd7784e3          	beq	a5,s7,800012d0 <uvmunmap+0x76>
    if(do_free){
    8000130c:	fc0a8ae3          	beqz	s5,800012e0 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001310:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001312:	0532                	slli	a0,a0,0xc
    80001314:	fffff097          	auipc	ra,0xfffff
    80001318:	6ce080e7          	jalr	1742(ra) # 800009e2 <kfree>
    8000131c:	b7d1                	j	800012e0 <uvmunmap+0x86>

000000008000131e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000131e:	1101                	addi	sp,sp,-32
    80001320:	ec06                	sd	ra,24(sp)
    80001322:	e822                	sd	s0,16(sp)
    80001324:	e426                	sd	s1,8(sp)
    80001326:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	7b8080e7          	jalr	1976(ra) # 80000ae0 <kalloc>
    80001330:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001332:	c519                	beqz	a0,80001340 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001334:	6605                	lui	a2,0x1
    80001336:	4581                	li	a1,0
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	994080e7          	jalr	-1644(ra) # 80000ccc <memset>
  return pagetable;
}
    80001340:	8526                	mv	a0,s1
    80001342:	60e2                	ld	ra,24(sp)
    80001344:	6442                	ld	s0,16(sp)
    80001346:	64a2                	ld	s1,8(sp)
    80001348:	6105                	addi	sp,sp,32
    8000134a:	8082                	ret

000000008000134c <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000134c:	7179                	addi	sp,sp,-48
    8000134e:	f406                	sd	ra,40(sp)
    80001350:	f022                	sd	s0,32(sp)
    80001352:	ec26                	sd	s1,24(sp)
    80001354:	e84a                	sd	s2,16(sp)
    80001356:	e44e                	sd	s3,8(sp)
    80001358:	e052                	sd	s4,0(sp)
    8000135a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000135c:	6785                	lui	a5,0x1
    8000135e:	04f67863          	bgeu	a2,a5,800013ae <uvminit+0x62>
    80001362:	8a2a                	mv	s4,a0
    80001364:	89ae                	mv	s3,a1
    80001366:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001368:	fffff097          	auipc	ra,0xfffff
    8000136c:	778080e7          	jalr	1912(ra) # 80000ae0 <kalloc>
    80001370:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001372:	6605                	lui	a2,0x1
    80001374:	4581                	li	a1,0
    80001376:	00000097          	auipc	ra,0x0
    8000137a:	956080e7          	jalr	-1706(ra) # 80000ccc <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000137e:	4779                	li	a4,30
    80001380:	86ca                	mv	a3,s2
    80001382:	6605                	lui	a2,0x1
    80001384:	4581                	li	a1,0
    80001386:	8552                	mv	a0,s4
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	d0c080e7          	jalr	-756(ra) # 80001094 <mappages>
  memmove(mem, src, sz);
    80001390:	8626                	mv	a2,s1
    80001392:	85ce                	mv	a1,s3
    80001394:	854a                	mv	a0,s2
    80001396:	00000097          	auipc	ra,0x0
    8000139a:	992080e7          	jalr	-1646(ra) # 80000d28 <memmove>
}
    8000139e:	70a2                	ld	ra,40(sp)
    800013a0:	7402                	ld	s0,32(sp)
    800013a2:	64e2                	ld	s1,24(sp)
    800013a4:	6942                	ld	s2,16(sp)
    800013a6:	69a2                	ld	s3,8(sp)
    800013a8:	6a02                	ld	s4,0(sp)
    800013aa:	6145                	addi	sp,sp,48
    800013ac:	8082                	ret
    panic("inituvm: more than a page");
    800013ae:	00007517          	auipc	a0,0x7
    800013b2:	daa50513          	addi	a0,a0,-598 # 80008158 <digits+0x118>
    800013b6:	fffff097          	auipc	ra,0xfffff
    800013ba:	184080e7          	jalr	388(ra) # 8000053a <panic>

00000000800013be <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013be:	1101                	addi	sp,sp,-32
    800013c0:	ec06                	sd	ra,24(sp)
    800013c2:	e822                	sd	s0,16(sp)
    800013c4:	e426                	sd	s1,8(sp)
    800013c6:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013c8:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ca:	00b67d63          	bgeu	a2,a1,800013e4 <uvmdealloc+0x26>
    800013ce:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d0:	6785                	lui	a5,0x1
    800013d2:	17fd                	addi	a5,a5,-1
    800013d4:	00f60733          	add	a4,a2,a5
    800013d8:	76fd                	lui	a3,0xfffff
    800013da:	8f75                	and	a4,a4,a3
    800013dc:	97ae                	add	a5,a5,a1
    800013de:	8ff5                	and	a5,a5,a3
    800013e0:	00f76863          	bltu	a4,a5,800013f0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e4:	8526                	mv	a0,s1
    800013e6:	60e2                	ld	ra,24(sp)
    800013e8:	6442                	ld	s0,16(sp)
    800013ea:	64a2                	ld	s1,8(sp)
    800013ec:	6105                	addi	sp,sp,32
    800013ee:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f0:	8f99                	sub	a5,a5,a4
    800013f2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f4:	4685                	li	a3,1
    800013f6:	0007861b          	sext.w	a2,a5
    800013fa:	85ba                	mv	a1,a4
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	e5e080e7          	jalr	-418(ra) # 8000125a <uvmunmap>
    80001404:	b7c5                	j	800013e4 <uvmdealloc+0x26>

0000000080001406 <uvmalloc>:
  if(newsz < oldsz)
    80001406:	0ab66163          	bltu	a2,a1,800014a8 <uvmalloc+0xa2>
{
    8000140a:	7139                	addi	sp,sp,-64
    8000140c:	fc06                	sd	ra,56(sp)
    8000140e:	f822                	sd	s0,48(sp)
    80001410:	f426                	sd	s1,40(sp)
    80001412:	f04a                	sd	s2,32(sp)
    80001414:	ec4e                	sd	s3,24(sp)
    80001416:	e852                	sd	s4,16(sp)
    80001418:	e456                	sd	s5,8(sp)
    8000141a:	0080                	addi	s0,sp,64
    8000141c:	8aaa                	mv	s5,a0
    8000141e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001420:	6785                	lui	a5,0x1
    80001422:	17fd                	addi	a5,a5,-1
    80001424:	95be                	add	a1,a1,a5
    80001426:	77fd                	lui	a5,0xfffff
    80001428:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000142c:	08c9f063          	bgeu	s3,a2,800014ac <uvmalloc+0xa6>
    80001430:	894e                	mv	s2,s3
    mem = kalloc();
    80001432:	fffff097          	auipc	ra,0xfffff
    80001436:	6ae080e7          	jalr	1710(ra) # 80000ae0 <kalloc>
    8000143a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000143c:	c51d                	beqz	a0,8000146a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000143e:	6605                	lui	a2,0x1
    80001440:	4581                	li	a1,0
    80001442:	00000097          	auipc	ra,0x0
    80001446:	88a080e7          	jalr	-1910(ra) # 80000ccc <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000144a:	4779                	li	a4,30
    8000144c:	86a6                	mv	a3,s1
    8000144e:	6605                	lui	a2,0x1
    80001450:	85ca                	mv	a1,s2
    80001452:	8556                	mv	a0,s5
    80001454:	00000097          	auipc	ra,0x0
    80001458:	c40080e7          	jalr	-960(ra) # 80001094 <mappages>
    8000145c:	e905                	bnez	a0,8000148c <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000145e:	6785                	lui	a5,0x1
    80001460:	993e                	add	s2,s2,a5
    80001462:	fd4968e3          	bltu	s2,s4,80001432 <uvmalloc+0x2c>
  return newsz;
    80001466:	8552                	mv	a0,s4
    80001468:	a809                	j	8000147a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000146a:	864e                	mv	a2,s3
    8000146c:	85ca                	mv	a1,s2
    8000146e:	8556                	mv	a0,s5
    80001470:	00000097          	auipc	ra,0x0
    80001474:	f4e080e7          	jalr	-178(ra) # 800013be <uvmdealloc>
      return 0;
    80001478:	4501                	li	a0,0
}
    8000147a:	70e2                	ld	ra,56(sp)
    8000147c:	7442                	ld	s0,48(sp)
    8000147e:	74a2                	ld	s1,40(sp)
    80001480:	7902                	ld	s2,32(sp)
    80001482:	69e2                	ld	s3,24(sp)
    80001484:	6a42                	ld	s4,16(sp)
    80001486:	6aa2                	ld	s5,8(sp)
    80001488:	6121                	addi	sp,sp,64
    8000148a:	8082                	ret
      kfree(mem);
    8000148c:	8526                	mv	a0,s1
    8000148e:	fffff097          	auipc	ra,0xfffff
    80001492:	554080e7          	jalr	1364(ra) # 800009e2 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001496:	864e                	mv	a2,s3
    80001498:	85ca                	mv	a1,s2
    8000149a:	8556                	mv	a0,s5
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	f22080e7          	jalr	-222(ra) # 800013be <uvmdealloc>
      return 0;
    800014a4:	4501                	li	a0,0
    800014a6:	bfd1                	j	8000147a <uvmalloc+0x74>
    return oldsz;
    800014a8:	852e                	mv	a0,a1
}
    800014aa:	8082                	ret
  return newsz;
    800014ac:	8532                	mv	a0,a2
    800014ae:	b7f1                	j	8000147a <uvmalloc+0x74>

00000000800014b0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014b0:	7179                	addi	sp,sp,-48
    800014b2:	f406                	sd	ra,40(sp)
    800014b4:	f022                	sd	s0,32(sp)
    800014b6:	ec26                	sd	s1,24(sp)
    800014b8:	e84a                	sd	s2,16(sp)
    800014ba:	e44e                	sd	s3,8(sp)
    800014bc:	e052                	sd	s4,0(sp)
    800014be:	1800                	addi	s0,sp,48
    800014c0:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014c2:	84aa                	mv	s1,a0
    800014c4:	6905                	lui	s2,0x1
    800014c6:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014c8:	4985                	li	s3,1
    800014ca:	a829                	j	800014e4 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014cc:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014ce:	00c79513          	slli	a0,a5,0xc
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	fde080e7          	jalr	-34(ra) # 800014b0 <freewalk>
      pagetable[i] = 0;
    800014da:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014de:	04a1                	addi	s1,s1,8
    800014e0:	03248163          	beq	s1,s2,80001502 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014e4:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e6:	00f7f713          	andi	a4,a5,15
    800014ea:	ff3701e3          	beq	a4,s3,800014cc <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014ee:	8b85                	andi	a5,a5,1
    800014f0:	d7fd                	beqz	a5,800014de <freewalk+0x2e>
      panic("freewalk: leaf");
    800014f2:	00007517          	auipc	a0,0x7
    800014f6:	c8650513          	addi	a0,a0,-890 # 80008178 <digits+0x138>
    800014fa:	fffff097          	auipc	ra,0xfffff
    800014fe:	040080e7          	jalr	64(ra) # 8000053a <panic>
    }
  }
  kfree((void*)pagetable);
    80001502:	8552                	mv	a0,s4
    80001504:	fffff097          	auipc	ra,0xfffff
    80001508:	4de080e7          	jalr	1246(ra) # 800009e2 <kfree>
}
    8000150c:	70a2                	ld	ra,40(sp)
    8000150e:	7402                	ld	s0,32(sp)
    80001510:	64e2                	ld	s1,24(sp)
    80001512:	6942                	ld	s2,16(sp)
    80001514:	69a2                	ld	s3,8(sp)
    80001516:	6a02                	ld	s4,0(sp)
    80001518:	6145                	addi	sp,sp,48
    8000151a:	8082                	ret

000000008000151c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000151c:	1101                	addi	sp,sp,-32
    8000151e:	ec06                	sd	ra,24(sp)
    80001520:	e822                	sd	s0,16(sp)
    80001522:	e426                	sd	s1,8(sp)
    80001524:	1000                	addi	s0,sp,32
    80001526:	84aa                	mv	s1,a0
  if(sz > 0)
    80001528:	e999                	bnez	a1,8000153e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000152a:	8526                	mv	a0,s1
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	f84080e7          	jalr	-124(ra) # 800014b0 <freewalk>
}
    80001534:	60e2                	ld	ra,24(sp)
    80001536:	6442                	ld	s0,16(sp)
    80001538:	64a2                	ld	s1,8(sp)
    8000153a:	6105                	addi	sp,sp,32
    8000153c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000153e:	6785                	lui	a5,0x1
    80001540:	17fd                	addi	a5,a5,-1
    80001542:	95be                	add	a1,a1,a5
    80001544:	4685                	li	a3,1
    80001546:	00c5d613          	srli	a2,a1,0xc
    8000154a:	4581                	li	a1,0
    8000154c:	00000097          	auipc	ra,0x0
    80001550:	d0e080e7          	jalr	-754(ra) # 8000125a <uvmunmap>
    80001554:	bfd9                	j	8000152a <uvmfree+0xe>

0000000080001556 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001556:	c679                	beqz	a2,80001624 <uvmcopy+0xce>
{
    80001558:	715d                	addi	sp,sp,-80
    8000155a:	e486                	sd	ra,72(sp)
    8000155c:	e0a2                	sd	s0,64(sp)
    8000155e:	fc26                	sd	s1,56(sp)
    80001560:	f84a                	sd	s2,48(sp)
    80001562:	f44e                	sd	s3,40(sp)
    80001564:	f052                	sd	s4,32(sp)
    80001566:	ec56                	sd	s5,24(sp)
    80001568:	e85a                	sd	s6,16(sp)
    8000156a:	e45e                	sd	s7,8(sp)
    8000156c:	0880                	addi	s0,sp,80
    8000156e:	8b2a                	mv	s6,a0
    80001570:	8aae                	mv	s5,a1
    80001572:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001574:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001576:	4601                	li	a2,0
    80001578:	85ce                	mv	a1,s3
    8000157a:	855a                	mv	a0,s6
    8000157c:	00000097          	auipc	ra,0x0
    80001580:	a30080e7          	jalr	-1488(ra) # 80000fac <walk>
    80001584:	c531                	beqz	a0,800015d0 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001586:	6118                	ld	a4,0(a0)
    80001588:	00177793          	andi	a5,a4,1
    8000158c:	cbb1                	beqz	a5,800015e0 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000158e:	00a75593          	srli	a1,a4,0xa
    80001592:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001596:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000159a:	fffff097          	auipc	ra,0xfffff
    8000159e:	546080e7          	jalr	1350(ra) # 80000ae0 <kalloc>
    800015a2:	892a                	mv	s2,a0
    800015a4:	c939                	beqz	a0,800015fa <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015a6:	6605                	lui	a2,0x1
    800015a8:	85de                	mv	a1,s7
    800015aa:	fffff097          	auipc	ra,0xfffff
    800015ae:	77e080e7          	jalr	1918(ra) # 80000d28 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015b2:	8726                	mv	a4,s1
    800015b4:	86ca                	mv	a3,s2
    800015b6:	6605                	lui	a2,0x1
    800015b8:	85ce                	mv	a1,s3
    800015ba:	8556                	mv	a0,s5
    800015bc:	00000097          	auipc	ra,0x0
    800015c0:	ad8080e7          	jalr	-1320(ra) # 80001094 <mappages>
    800015c4:	e515                	bnez	a0,800015f0 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015c6:	6785                	lui	a5,0x1
    800015c8:	99be                	add	s3,s3,a5
    800015ca:	fb49e6e3          	bltu	s3,s4,80001576 <uvmcopy+0x20>
    800015ce:	a081                	j	8000160e <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015d0:	00007517          	auipc	a0,0x7
    800015d4:	bb850513          	addi	a0,a0,-1096 # 80008188 <digits+0x148>
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	f62080e7          	jalr	-158(ra) # 8000053a <panic>
      panic("uvmcopy: page not present");
    800015e0:	00007517          	auipc	a0,0x7
    800015e4:	bc850513          	addi	a0,a0,-1080 # 800081a8 <digits+0x168>
    800015e8:	fffff097          	auipc	ra,0xfffff
    800015ec:	f52080e7          	jalr	-174(ra) # 8000053a <panic>
      kfree(mem);
    800015f0:	854a                	mv	a0,s2
    800015f2:	fffff097          	auipc	ra,0xfffff
    800015f6:	3f0080e7          	jalr	1008(ra) # 800009e2 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015fa:	4685                	li	a3,1
    800015fc:	00c9d613          	srli	a2,s3,0xc
    80001600:	4581                	li	a1,0
    80001602:	8556                	mv	a0,s5
    80001604:	00000097          	auipc	ra,0x0
    80001608:	c56080e7          	jalr	-938(ra) # 8000125a <uvmunmap>
  return -1;
    8000160c:	557d                	li	a0,-1
}
    8000160e:	60a6                	ld	ra,72(sp)
    80001610:	6406                	ld	s0,64(sp)
    80001612:	74e2                	ld	s1,56(sp)
    80001614:	7942                	ld	s2,48(sp)
    80001616:	79a2                	ld	s3,40(sp)
    80001618:	7a02                	ld	s4,32(sp)
    8000161a:	6ae2                	ld	s5,24(sp)
    8000161c:	6b42                	ld	s6,16(sp)
    8000161e:	6ba2                	ld	s7,8(sp)
    80001620:	6161                	addi	sp,sp,80
    80001622:	8082                	ret
  return 0;
    80001624:	4501                	li	a0,0
}
    80001626:	8082                	ret

0000000080001628 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001628:	1141                	addi	sp,sp,-16
    8000162a:	e406                	sd	ra,8(sp)
    8000162c:	e022                	sd	s0,0(sp)
    8000162e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001630:	4601                	li	a2,0
    80001632:	00000097          	auipc	ra,0x0
    80001636:	97a080e7          	jalr	-1670(ra) # 80000fac <walk>
  if(pte == 0)
    8000163a:	c901                	beqz	a0,8000164a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000163c:	611c                	ld	a5,0(a0)
    8000163e:	9bbd                	andi	a5,a5,-17
    80001640:	e11c                	sd	a5,0(a0)
}
    80001642:	60a2                	ld	ra,8(sp)
    80001644:	6402                	ld	s0,0(sp)
    80001646:	0141                	addi	sp,sp,16
    80001648:	8082                	ret
    panic("uvmclear");
    8000164a:	00007517          	auipc	a0,0x7
    8000164e:	b7e50513          	addi	a0,a0,-1154 # 800081c8 <digits+0x188>
    80001652:	fffff097          	auipc	ra,0xfffff
    80001656:	ee8080e7          	jalr	-280(ra) # 8000053a <panic>

000000008000165a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000165a:	c6bd                	beqz	a3,800016c8 <copyout+0x6e>
{
    8000165c:	715d                	addi	sp,sp,-80
    8000165e:	e486                	sd	ra,72(sp)
    80001660:	e0a2                	sd	s0,64(sp)
    80001662:	fc26                	sd	s1,56(sp)
    80001664:	f84a                	sd	s2,48(sp)
    80001666:	f44e                	sd	s3,40(sp)
    80001668:	f052                	sd	s4,32(sp)
    8000166a:	ec56                	sd	s5,24(sp)
    8000166c:	e85a                	sd	s6,16(sp)
    8000166e:	e45e                	sd	s7,8(sp)
    80001670:	e062                	sd	s8,0(sp)
    80001672:	0880                	addi	s0,sp,80
    80001674:	8b2a                	mv	s6,a0
    80001676:	8c2e                	mv	s8,a1
    80001678:	8a32                	mv	s4,a2
    8000167a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000167c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000167e:	6a85                	lui	s5,0x1
    80001680:	a015                	j	800016a4 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001682:	9562                	add	a0,a0,s8
    80001684:	0004861b          	sext.w	a2,s1
    80001688:	85d2                	mv	a1,s4
    8000168a:	41250533          	sub	a0,a0,s2
    8000168e:	fffff097          	auipc	ra,0xfffff
    80001692:	69a080e7          	jalr	1690(ra) # 80000d28 <memmove>

    len -= n;
    80001696:	409989b3          	sub	s3,s3,s1
    src += n;
    8000169a:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000169c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016a0:	02098263          	beqz	s3,800016c4 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016a4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016a8:	85ca                	mv	a1,s2
    800016aa:	855a                	mv	a0,s6
    800016ac:	00000097          	auipc	ra,0x0
    800016b0:	9a6080e7          	jalr	-1626(ra) # 80001052 <walkaddr>
    if(pa0 == 0)
    800016b4:	cd01                	beqz	a0,800016cc <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016b6:	418904b3          	sub	s1,s2,s8
    800016ba:	94d6                	add	s1,s1,s5
    800016bc:	fc99f3e3          	bgeu	s3,s1,80001682 <copyout+0x28>
    800016c0:	84ce                	mv	s1,s3
    800016c2:	b7c1                	j	80001682 <copyout+0x28>
  }
  return 0;
    800016c4:	4501                	li	a0,0
    800016c6:	a021                	j	800016ce <copyout+0x74>
    800016c8:	4501                	li	a0,0
}
    800016ca:	8082                	ret
      return -1;
    800016cc:	557d                	li	a0,-1
}
    800016ce:	60a6                	ld	ra,72(sp)
    800016d0:	6406                	ld	s0,64(sp)
    800016d2:	74e2                	ld	s1,56(sp)
    800016d4:	7942                	ld	s2,48(sp)
    800016d6:	79a2                	ld	s3,40(sp)
    800016d8:	7a02                	ld	s4,32(sp)
    800016da:	6ae2                	ld	s5,24(sp)
    800016dc:	6b42                	ld	s6,16(sp)
    800016de:	6ba2                	ld	s7,8(sp)
    800016e0:	6c02                	ld	s8,0(sp)
    800016e2:	6161                	addi	sp,sp,80
    800016e4:	8082                	ret

00000000800016e6 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e6:	caa5                	beqz	a3,80001756 <copyin+0x70>
{
    800016e8:	715d                	addi	sp,sp,-80
    800016ea:	e486                	sd	ra,72(sp)
    800016ec:	e0a2                	sd	s0,64(sp)
    800016ee:	fc26                	sd	s1,56(sp)
    800016f0:	f84a                	sd	s2,48(sp)
    800016f2:	f44e                	sd	s3,40(sp)
    800016f4:	f052                	sd	s4,32(sp)
    800016f6:	ec56                	sd	s5,24(sp)
    800016f8:	e85a                	sd	s6,16(sp)
    800016fa:	e45e                	sd	s7,8(sp)
    800016fc:	e062                	sd	s8,0(sp)
    800016fe:	0880                	addi	s0,sp,80
    80001700:	8b2a                	mv	s6,a0
    80001702:	8a2e                	mv	s4,a1
    80001704:	8c32                	mv	s8,a2
    80001706:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001708:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000170a:	6a85                	lui	s5,0x1
    8000170c:	a01d                	j	80001732 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000170e:	018505b3          	add	a1,a0,s8
    80001712:	0004861b          	sext.w	a2,s1
    80001716:	412585b3          	sub	a1,a1,s2
    8000171a:	8552                	mv	a0,s4
    8000171c:	fffff097          	auipc	ra,0xfffff
    80001720:	60c080e7          	jalr	1548(ra) # 80000d28 <memmove>

    len -= n;
    80001724:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001728:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000172a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000172e:	02098263          	beqz	s3,80001752 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001732:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001736:	85ca                	mv	a1,s2
    80001738:	855a                	mv	a0,s6
    8000173a:	00000097          	auipc	ra,0x0
    8000173e:	918080e7          	jalr	-1768(ra) # 80001052 <walkaddr>
    if(pa0 == 0)
    80001742:	cd01                	beqz	a0,8000175a <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001744:	418904b3          	sub	s1,s2,s8
    80001748:	94d6                	add	s1,s1,s5
    8000174a:	fc99f2e3          	bgeu	s3,s1,8000170e <copyin+0x28>
    8000174e:	84ce                	mv	s1,s3
    80001750:	bf7d                	j	8000170e <copyin+0x28>
  }
  return 0;
    80001752:	4501                	li	a0,0
    80001754:	a021                	j	8000175c <copyin+0x76>
    80001756:	4501                	li	a0,0
}
    80001758:	8082                	ret
      return -1;
    8000175a:	557d                	li	a0,-1
}
    8000175c:	60a6                	ld	ra,72(sp)
    8000175e:	6406                	ld	s0,64(sp)
    80001760:	74e2                	ld	s1,56(sp)
    80001762:	7942                	ld	s2,48(sp)
    80001764:	79a2                	ld	s3,40(sp)
    80001766:	7a02                	ld	s4,32(sp)
    80001768:	6ae2                	ld	s5,24(sp)
    8000176a:	6b42                	ld	s6,16(sp)
    8000176c:	6ba2                	ld	s7,8(sp)
    8000176e:	6c02                	ld	s8,0(sp)
    80001770:	6161                	addi	sp,sp,80
    80001772:	8082                	ret

0000000080001774 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001774:	c2dd                	beqz	a3,8000181a <copyinstr+0xa6>
{
    80001776:	715d                	addi	sp,sp,-80
    80001778:	e486                	sd	ra,72(sp)
    8000177a:	e0a2                	sd	s0,64(sp)
    8000177c:	fc26                	sd	s1,56(sp)
    8000177e:	f84a                	sd	s2,48(sp)
    80001780:	f44e                	sd	s3,40(sp)
    80001782:	f052                	sd	s4,32(sp)
    80001784:	ec56                	sd	s5,24(sp)
    80001786:	e85a                	sd	s6,16(sp)
    80001788:	e45e                	sd	s7,8(sp)
    8000178a:	0880                	addi	s0,sp,80
    8000178c:	8a2a                	mv	s4,a0
    8000178e:	8b2e                	mv	s6,a1
    80001790:	8bb2                	mv	s7,a2
    80001792:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001794:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001796:	6985                	lui	s3,0x1
    80001798:	a02d                	j	800017c2 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000179a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000179e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017a0:	37fd                	addiw	a5,a5,-1
    800017a2:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017a6:	60a6                	ld	ra,72(sp)
    800017a8:	6406                	ld	s0,64(sp)
    800017aa:	74e2                	ld	s1,56(sp)
    800017ac:	7942                	ld	s2,48(sp)
    800017ae:	79a2                	ld	s3,40(sp)
    800017b0:	7a02                	ld	s4,32(sp)
    800017b2:	6ae2                	ld	s5,24(sp)
    800017b4:	6b42                	ld	s6,16(sp)
    800017b6:	6ba2                	ld	s7,8(sp)
    800017b8:	6161                	addi	sp,sp,80
    800017ba:	8082                	ret
    srcva = va0 + PGSIZE;
    800017bc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017c0:	c8a9                	beqz	s1,80001812 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017c2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017c6:	85ca                	mv	a1,s2
    800017c8:	8552                	mv	a0,s4
    800017ca:	00000097          	auipc	ra,0x0
    800017ce:	888080e7          	jalr	-1912(ra) # 80001052 <walkaddr>
    if(pa0 == 0)
    800017d2:	c131                	beqz	a0,80001816 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017d4:	417906b3          	sub	a3,s2,s7
    800017d8:	96ce                	add	a3,a3,s3
    800017da:	00d4f363          	bgeu	s1,a3,800017e0 <copyinstr+0x6c>
    800017de:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017e0:	955e                	add	a0,a0,s7
    800017e2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017e6:	daf9                	beqz	a3,800017bc <copyinstr+0x48>
    800017e8:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017ea:	41650633          	sub	a2,a0,s6
    800017ee:	fff48593          	addi	a1,s1,-1
    800017f2:	95da                	add	a1,a1,s6
    while(n > 0){
    800017f4:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800017f6:	00f60733          	add	a4,a2,a5
    800017fa:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800017fe:	df51                	beqz	a4,8000179a <copyinstr+0x26>
        *dst = *p;
    80001800:	00e78023          	sb	a4,0(a5)
      --max;
    80001804:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001808:	0785                	addi	a5,a5,1
    while(n > 0){
    8000180a:	fed796e3          	bne	a5,a3,800017f6 <copyinstr+0x82>
      dst++;
    8000180e:	8b3e                	mv	s6,a5
    80001810:	b775                	j	800017bc <copyinstr+0x48>
    80001812:	4781                	li	a5,0
    80001814:	b771                	j	800017a0 <copyinstr+0x2c>
      return -1;
    80001816:	557d                	li	a0,-1
    80001818:	b779                	j	800017a6 <copyinstr+0x32>
  int got_null = 0;
    8000181a:	4781                	li	a5,0
  if(got_null){
    8000181c:	37fd                	addiw	a5,a5,-1
    8000181e:	0007851b          	sext.w	a0,a5
}
    80001822:	8082                	ret

0000000080001824 <btput>:

void
btput(void)
{
    80001824:	1141                	addi	sp,sp,-16
    80001826:	e406                	sd	ra,8(sp)
    80001828:	e022                	sd	s0,0(sp)
    8000182a:	0800                	addi	s0,sp,16
  
    printf("btput Hello world in tweet.c\n");
    8000182c:	00007517          	auipc	a0,0x7
    80001830:	9ac50513          	addi	a0,a0,-1620 # 800081d8 <digits+0x198>
    80001834:	fffff097          	auipc	ra,0xfffff
    80001838:	d50080e7          	jalr	-688(ra) # 80000584 <printf>
}
    8000183c:	60a2                	ld	ra,8(sp)
    8000183e:	6402                	ld	s0,0(sp)
    80001840:	0141                	addi	sp,sp,16
    80001842:	8082                	ret

0000000080001844 <tput>:

void 
tput(void){
    80001844:	1141                	addi	sp,sp,-16
    80001846:	e406                	sd	ra,8(sp)
    80001848:	e022                	sd	s0,0(sp)
    8000184a:	0800                	addi	s0,sp,16
    printf("ttput Hello world in tweet.c\n");
    8000184c:	00007517          	auipc	a0,0x7
    80001850:	9ac50513          	addi	a0,a0,-1620 # 800081f8 <digits+0x1b8>
    80001854:	fffff097          	auipc	ra,0xfffff
    80001858:	d30080e7          	jalr	-720(ra) # 80000584 <printf>
}
    8000185c:	60a2                	ld	ra,8(sp)
    8000185e:	6402                	ld	s0,0(sp)
    80001860:	0141                	addi	sp,sp,16
    80001862:	8082                	ret

0000000080001864 <btget>:

void 
btget(void){
    80001864:	1141                	addi	sp,sp,-16
    80001866:	e406                	sd	ra,8(sp)
    80001868:	e022                	sd	s0,0(sp)
    8000186a:	0800                	addi	s0,sp,16
    printf("btget Hello world in tweet.c\n");
    8000186c:	00007517          	auipc	a0,0x7
    80001870:	9ac50513          	addi	a0,a0,-1620 # 80008218 <digits+0x1d8>
    80001874:	fffff097          	auipc	ra,0xfffff
    80001878:	d10080e7          	jalr	-752(ra) # 80000584 <printf>
}
    8000187c:	60a2                	ld	ra,8(sp)
    8000187e:	6402                	ld	s0,0(sp)
    80001880:	0141                	addi	sp,sp,16
    80001882:	8082                	ret

0000000080001884 <tget>:

void 
tget(void){
    80001884:	1141                	addi	sp,sp,-16
    80001886:	e406                	sd	ra,8(sp)
    80001888:	e022                	sd	s0,0(sp)
    8000188a:	0800                	addi	s0,sp,16
    printf("tget Hello world in tweet.c\n");
    8000188c:	00007517          	auipc	a0,0x7
    80001890:	9ac50513          	addi	a0,a0,-1620 # 80008238 <digits+0x1f8>
    80001894:	fffff097          	auipc	ra,0xfffff
    80001898:	cf0080e7          	jalr	-784(ra) # 80000584 <printf>
}
    8000189c:	60a2                	ld	ra,8(sp)
    8000189e:	6402                	ld	s0,0(sp)
    800018a0:	0141                	addi	sp,sp,16
    800018a2:	8082                	ret

00000000800018a4 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    800018a4:	7139                	addi	sp,sp,-64
    800018a6:	fc06                	sd	ra,56(sp)
    800018a8:	f822                	sd	s0,48(sp)
    800018aa:	f426                	sd	s1,40(sp)
    800018ac:	f04a                	sd	s2,32(sp)
    800018ae:	ec4e                	sd	s3,24(sp)
    800018b0:	e852                	sd	s4,16(sp)
    800018b2:	e456                	sd	s5,8(sp)
    800018b4:	e05a                	sd	s6,0(sp)
    800018b6:	0080                	addi	s0,sp,64
    800018b8:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ba:	00010497          	auipc	s1,0x10
    800018be:	e1648493          	addi	s1,s1,-490 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018c2:	8b26                	mv	s6,s1
    800018c4:	00006a97          	auipc	s5,0x6
    800018c8:	73ca8a93          	addi	s5,s5,1852 # 80008000 <etext>
    800018cc:	04000937          	lui	s2,0x4000
    800018d0:	197d                	addi	s2,s2,-1
    800018d2:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018d4:	00015a17          	auipc	s4,0x15
    800018d8:	7fca0a13          	addi	s4,s4,2044 # 800170d0 <tickslock>
    char *pa = kalloc();
    800018dc:	fffff097          	auipc	ra,0xfffff
    800018e0:	204080e7          	jalr	516(ra) # 80000ae0 <kalloc>
    800018e4:	862a                	mv	a2,a0
    if(pa == 0)
    800018e6:	c131                	beqz	a0,8000192a <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    800018e8:	416485b3          	sub	a1,s1,s6
    800018ec:	858d                	srai	a1,a1,0x3
    800018ee:	000ab783          	ld	a5,0(s5)
    800018f2:	02f585b3          	mul	a1,a1,a5
    800018f6:	2585                	addiw	a1,a1,1
    800018f8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018fc:	4719                	li	a4,6
    800018fe:	6685                	lui	a3,0x1
    80001900:	40b905b3          	sub	a1,s2,a1
    80001904:	854e                	mv	a0,s3
    80001906:	00000097          	auipc	ra,0x0
    8000190a:	82e080e7          	jalr	-2002(ra) # 80001134 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190e:	16848493          	addi	s1,s1,360
    80001912:	fd4495e3          	bne	s1,s4,800018dc <proc_mapstacks+0x38>
  }
}
    80001916:	70e2                	ld	ra,56(sp)
    80001918:	7442                	ld	s0,48(sp)
    8000191a:	74a2                	ld	s1,40(sp)
    8000191c:	7902                	ld	s2,32(sp)
    8000191e:	69e2                	ld	s3,24(sp)
    80001920:	6a42                	ld	s4,16(sp)
    80001922:	6aa2                	ld	s5,8(sp)
    80001924:	6b02                	ld	s6,0(sp)
    80001926:	6121                	addi	sp,sp,64
    80001928:	8082                	ret
      panic("kalloc");
    8000192a:	00007517          	auipc	a0,0x7
    8000192e:	92e50513          	addi	a0,a0,-1746 # 80008258 <digits+0x218>
    80001932:	fffff097          	auipc	ra,0xfffff
    80001936:	c08080e7          	jalr	-1016(ra) # 8000053a <panic>

000000008000193a <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    8000193a:	7139                	addi	sp,sp,-64
    8000193c:	fc06                	sd	ra,56(sp)
    8000193e:	f822                	sd	s0,48(sp)
    80001940:	f426                	sd	s1,40(sp)
    80001942:	f04a                	sd	s2,32(sp)
    80001944:	ec4e                	sd	s3,24(sp)
    80001946:	e852                	sd	s4,16(sp)
    80001948:	e456                	sd	s5,8(sp)
    8000194a:	e05a                	sd	s6,0(sp)
    8000194c:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000194e:	00007597          	auipc	a1,0x7
    80001952:	91258593          	addi	a1,a1,-1774 # 80008260 <digits+0x220>
    80001956:	00010517          	auipc	a0,0x10
    8000195a:	94a50513          	addi	a0,a0,-1718 # 800112a0 <pid_lock>
    8000195e:	fffff097          	auipc	ra,0xfffff
    80001962:	1e2080e7          	jalr	482(ra) # 80000b40 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001966:	00007597          	auipc	a1,0x7
    8000196a:	90258593          	addi	a1,a1,-1790 # 80008268 <digits+0x228>
    8000196e:	00010517          	auipc	a0,0x10
    80001972:	94a50513          	addi	a0,a0,-1718 # 800112b8 <wait_lock>
    80001976:	fffff097          	auipc	ra,0xfffff
    8000197a:	1ca080e7          	jalr	458(ra) # 80000b40 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197e:	00010497          	auipc	s1,0x10
    80001982:	d5248493          	addi	s1,s1,-686 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001986:	00007b17          	auipc	s6,0x7
    8000198a:	8f2b0b13          	addi	s6,s6,-1806 # 80008278 <digits+0x238>
      p->kstack = KSTACK((int) (p - proc));
    8000198e:	8aa6                	mv	s5,s1
    80001990:	00006a17          	auipc	s4,0x6
    80001994:	670a0a13          	addi	s4,s4,1648 # 80008000 <etext>
    80001998:	04000937          	lui	s2,0x4000
    8000199c:	197d                	addi	s2,s2,-1
    8000199e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a0:	00015997          	auipc	s3,0x15
    800019a4:	73098993          	addi	s3,s3,1840 # 800170d0 <tickslock>
      initlock(&p->lock, "proc");
    800019a8:	85da                	mv	a1,s6
    800019aa:	8526                	mv	a0,s1
    800019ac:	fffff097          	auipc	ra,0xfffff
    800019b0:	194080e7          	jalr	404(ra) # 80000b40 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    800019b4:	415487b3          	sub	a5,s1,s5
    800019b8:	878d                	srai	a5,a5,0x3
    800019ba:	000a3703          	ld	a4,0(s4)
    800019be:	02e787b3          	mul	a5,a5,a4
    800019c2:	2785                	addiw	a5,a5,1
    800019c4:	00d7979b          	slliw	a5,a5,0xd
    800019c8:	40f907b3          	sub	a5,s2,a5
    800019cc:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ce:	16848493          	addi	s1,s1,360
    800019d2:	fd349be3          	bne	s1,s3,800019a8 <procinit+0x6e>
  }
}
    800019d6:	70e2                	ld	ra,56(sp)
    800019d8:	7442                	ld	s0,48(sp)
    800019da:	74a2                	ld	s1,40(sp)
    800019dc:	7902                	ld	s2,32(sp)
    800019de:	69e2                	ld	s3,24(sp)
    800019e0:	6a42                	ld	s4,16(sp)
    800019e2:	6aa2                	ld	s5,8(sp)
    800019e4:	6b02                	ld	s6,0(sp)
    800019e6:	6121                	addi	sp,sp,64
    800019e8:	8082                	ret

00000000800019ea <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019ea:	1141                	addi	sp,sp,-16
    800019ec:	e422                	sd	s0,8(sp)
    800019ee:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019f0:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019f2:	2501                	sext.w	a0,a0
    800019f4:	6422                	ld	s0,8(sp)
    800019f6:	0141                	addi	sp,sp,16
    800019f8:	8082                	ret

00000000800019fa <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    800019fa:	1141                	addi	sp,sp,-16
    800019fc:	e422                	sd	s0,8(sp)
    800019fe:	0800                	addi	s0,sp,16
    80001a00:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a02:	2781                	sext.w	a5,a5
    80001a04:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a06:	00010517          	auipc	a0,0x10
    80001a0a:	8ca50513          	addi	a0,a0,-1846 # 800112d0 <cpus>
    80001a0e:	953e                	add	a0,a0,a5
    80001a10:	6422                	ld	s0,8(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret

0000000080001a16 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001a16:	1101                	addi	sp,sp,-32
    80001a18:	ec06                	sd	ra,24(sp)
    80001a1a:	e822                	sd	s0,16(sp)
    80001a1c:	e426                	sd	s1,8(sp)
    80001a1e:	1000                	addi	s0,sp,32
  push_off();
    80001a20:	fffff097          	auipc	ra,0xfffff
    80001a24:	164080e7          	jalr	356(ra) # 80000b84 <push_off>
    80001a28:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a2a:	2781                	sext.w	a5,a5
    80001a2c:	079e                	slli	a5,a5,0x7
    80001a2e:	00010717          	auipc	a4,0x10
    80001a32:	87270713          	addi	a4,a4,-1934 # 800112a0 <pid_lock>
    80001a36:	97ba                	add	a5,a5,a4
    80001a38:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	1ea080e7          	jalr	490(ra) # 80000c24 <pop_off>
  return p;
}
    80001a42:	8526                	mv	a0,s1
    80001a44:	60e2                	ld	ra,24(sp)
    80001a46:	6442                	ld	s0,16(sp)
    80001a48:	64a2                	ld	s1,8(sp)
    80001a4a:	6105                	addi	sp,sp,32
    80001a4c:	8082                	ret

0000000080001a4e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a4e:	1141                	addi	sp,sp,-16
    80001a50:	e406                	sd	ra,8(sp)
    80001a52:	e022                	sd	s0,0(sp)
    80001a54:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a56:	00000097          	auipc	ra,0x0
    80001a5a:	fc0080e7          	jalr	-64(ra) # 80001a16 <myproc>
    80001a5e:	fffff097          	auipc	ra,0xfffff
    80001a62:	226080e7          	jalr	550(ra) # 80000c84 <release>

  if (first) {
    80001a66:	00007797          	auipc	a5,0x7
    80001a6a:	eaa7a783          	lw	a5,-342(a5) # 80008910 <first.1>
    80001a6e:	eb89                	bnez	a5,80001a80 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a70:	00001097          	auipc	ra,0x1
    80001a74:	c14080e7          	jalr	-1004(ra) # 80002684 <usertrapret>
}
    80001a78:	60a2                	ld	ra,8(sp)
    80001a7a:	6402                	ld	s0,0(sp)
    80001a7c:	0141                	addi	sp,sp,16
    80001a7e:	8082                	ret
    first = 0;
    80001a80:	00007797          	auipc	a5,0x7
    80001a84:	e807a823          	sw	zero,-368(a5) # 80008910 <first.1>
    fsinit(ROOTDEV);
    80001a88:	4505                	li	a0,1
    80001a8a:	00002097          	auipc	ra,0x2
    80001a8e:	9e2080e7          	jalr	-1566(ra) # 8000346c <fsinit>
    80001a92:	bff9                	j	80001a70 <forkret+0x22>

0000000080001a94 <allocpid>:
allocpid() {
    80001a94:	1101                	addi	sp,sp,-32
    80001a96:	ec06                	sd	ra,24(sp)
    80001a98:	e822                	sd	s0,16(sp)
    80001a9a:	e426                	sd	s1,8(sp)
    80001a9c:	e04a                	sd	s2,0(sp)
    80001a9e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001aa0:	00010917          	auipc	s2,0x10
    80001aa4:	80090913          	addi	s2,s2,-2048 # 800112a0 <pid_lock>
    80001aa8:	854a                	mv	a0,s2
    80001aaa:	fffff097          	auipc	ra,0xfffff
    80001aae:	126080e7          	jalr	294(ra) # 80000bd0 <acquire>
  pid = nextpid;
    80001ab2:	00007797          	auipc	a5,0x7
    80001ab6:	e6278793          	addi	a5,a5,-414 # 80008914 <nextpid>
    80001aba:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001abc:	0014871b          	addiw	a4,s1,1
    80001ac0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ac2:	854a                	mv	a0,s2
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	1c0080e7          	jalr	448(ra) # 80000c84 <release>
}
    80001acc:	8526                	mv	a0,s1
    80001ace:	60e2                	ld	ra,24(sp)
    80001ad0:	6442                	ld	s0,16(sp)
    80001ad2:	64a2                	ld	s1,8(sp)
    80001ad4:	6902                	ld	s2,0(sp)
    80001ad6:	6105                	addi	sp,sp,32
    80001ad8:	8082                	ret

0000000080001ada <proc_pagetable>:
{
    80001ada:	1101                	addi	sp,sp,-32
    80001adc:	ec06                	sd	ra,24(sp)
    80001ade:	e822                	sd	s0,16(sp)
    80001ae0:	e426                	sd	s1,8(sp)
    80001ae2:	e04a                	sd	s2,0(sp)
    80001ae4:	1000                	addi	s0,sp,32
    80001ae6:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ae8:	00000097          	auipc	ra,0x0
    80001aec:	836080e7          	jalr	-1994(ra) # 8000131e <uvmcreate>
    80001af0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001af2:	c121                	beqz	a0,80001b32 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001af4:	4729                	li	a4,10
    80001af6:	00005697          	auipc	a3,0x5
    80001afa:	50a68693          	addi	a3,a3,1290 # 80007000 <_trampoline>
    80001afe:	6605                	lui	a2,0x1
    80001b00:	040005b7          	lui	a1,0x4000
    80001b04:	15fd                	addi	a1,a1,-1
    80001b06:	05b2                	slli	a1,a1,0xc
    80001b08:	fffff097          	auipc	ra,0xfffff
    80001b0c:	58c080e7          	jalr	1420(ra) # 80001094 <mappages>
    80001b10:	02054863          	bltz	a0,80001b40 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b14:	4719                	li	a4,6
    80001b16:	05893683          	ld	a3,88(s2)
    80001b1a:	6605                	lui	a2,0x1
    80001b1c:	020005b7          	lui	a1,0x2000
    80001b20:	15fd                	addi	a1,a1,-1
    80001b22:	05b6                	slli	a1,a1,0xd
    80001b24:	8526                	mv	a0,s1
    80001b26:	fffff097          	auipc	ra,0xfffff
    80001b2a:	56e080e7          	jalr	1390(ra) # 80001094 <mappages>
    80001b2e:	02054163          	bltz	a0,80001b50 <proc_pagetable+0x76>
}
    80001b32:	8526                	mv	a0,s1
    80001b34:	60e2                	ld	ra,24(sp)
    80001b36:	6442                	ld	s0,16(sp)
    80001b38:	64a2                	ld	s1,8(sp)
    80001b3a:	6902                	ld	s2,0(sp)
    80001b3c:	6105                	addi	sp,sp,32
    80001b3e:	8082                	ret
    uvmfree(pagetable, 0);
    80001b40:	4581                	li	a1,0
    80001b42:	8526                	mv	a0,s1
    80001b44:	00000097          	auipc	ra,0x0
    80001b48:	9d8080e7          	jalr	-1576(ra) # 8000151c <uvmfree>
    return 0;
    80001b4c:	4481                	li	s1,0
    80001b4e:	b7d5                	j	80001b32 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b50:	4681                	li	a3,0
    80001b52:	4605                	li	a2,1
    80001b54:	040005b7          	lui	a1,0x4000
    80001b58:	15fd                	addi	a1,a1,-1
    80001b5a:	05b2                	slli	a1,a1,0xc
    80001b5c:	8526                	mv	a0,s1
    80001b5e:	fffff097          	auipc	ra,0xfffff
    80001b62:	6fc080e7          	jalr	1788(ra) # 8000125a <uvmunmap>
    uvmfree(pagetable, 0);
    80001b66:	4581                	li	a1,0
    80001b68:	8526                	mv	a0,s1
    80001b6a:	00000097          	auipc	ra,0x0
    80001b6e:	9b2080e7          	jalr	-1614(ra) # 8000151c <uvmfree>
    return 0;
    80001b72:	4481                	li	s1,0
    80001b74:	bf7d                	j	80001b32 <proc_pagetable+0x58>

0000000080001b76 <proc_freepagetable>:
{
    80001b76:	1101                	addi	sp,sp,-32
    80001b78:	ec06                	sd	ra,24(sp)
    80001b7a:	e822                	sd	s0,16(sp)
    80001b7c:	e426                	sd	s1,8(sp)
    80001b7e:	e04a                	sd	s2,0(sp)
    80001b80:	1000                	addi	s0,sp,32
    80001b82:	84aa                	mv	s1,a0
    80001b84:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b86:	4681                	li	a3,0
    80001b88:	4605                	li	a2,1
    80001b8a:	040005b7          	lui	a1,0x4000
    80001b8e:	15fd                	addi	a1,a1,-1
    80001b90:	05b2                	slli	a1,a1,0xc
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	6c8080e7          	jalr	1736(ra) # 8000125a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b9a:	4681                	li	a3,0
    80001b9c:	4605                	li	a2,1
    80001b9e:	020005b7          	lui	a1,0x2000
    80001ba2:	15fd                	addi	a1,a1,-1
    80001ba4:	05b6                	slli	a1,a1,0xd
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	fffff097          	auipc	ra,0xfffff
    80001bac:	6b2080e7          	jalr	1714(ra) # 8000125a <uvmunmap>
  uvmfree(pagetable, sz);
    80001bb0:	85ca                	mv	a1,s2
    80001bb2:	8526                	mv	a0,s1
    80001bb4:	00000097          	auipc	ra,0x0
    80001bb8:	968080e7          	jalr	-1688(ra) # 8000151c <uvmfree>
}
    80001bbc:	60e2                	ld	ra,24(sp)
    80001bbe:	6442                	ld	s0,16(sp)
    80001bc0:	64a2                	ld	s1,8(sp)
    80001bc2:	6902                	ld	s2,0(sp)
    80001bc4:	6105                	addi	sp,sp,32
    80001bc6:	8082                	ret

0000000080001bc8 <freeproc>:
{
    80001bc8:	1101                	addi	sp,sp,-32
    80001bca:	ec06                	sd	ra,24(sp)
    80001bcc:	e822                	sd	s0,16(sp)
    80001bce:	e426                	sd	s1,8(sp)
    80001bd0:	1000                	addi	s0,sp,32
    80001bd2:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bd4:	6d28                	ld	a0,88(a0)
    80001bd6:	c509                	beqz	a0,80001be0 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bd8:	fffff097          	auipc	ra,0xfffff
    80001bdc:	e0a080e7          	jalr	-502(ra) # 800009e2 <kfree>
  p->trapframe = 0;
    80001be0:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001be4:	68a8                	ld	a0,80(s1)
    80001be6:	c511                	beqz	a0,80001bf2 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001be8:	64ac                	ld	a1,72(s1)
    80001bea:	00000097          	auipc	ra,0x0
    80001bee:	f8c080e7          	jalr	-116(ra) # 80001b76 <proc_freepagetable>
  p->pagetable = 0;
    80001bf2:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bf6:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bfa:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bfe:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c02:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c06:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c0a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c0e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c12:	0004ac23          	sw	zero,24(s1)
}
    80001c16:	60e2                	ld	ra,24(sp)
    80001c18:	6442                	ld	s0,16(sp)
    80001c1a:	64a2                	ld	s1,8(sp)
    80001c1c:	6105                	addi	sp,sp,32
    80001c1e:	8082                	ret

0000000080001c20 <allocproc>:
{
    80001c20:	1101                	addi	sp,sp,-32
    80001c22:	ec06                	sd	ra,24(sp)
    80001c24:	e822                	sd	s0,16(sp)
    80001c26:	e426                	sd	s1,8(sp)
    80001c28:	e04a                	sd	s2,0(sp)
    80001c2a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c2c:	00010497          	auipc	s1,0x10
    80001c30:	aa448493          	addi	s1,s1,-1372 # 800116d0 <proc>
    80001c34:	00015917          	auipc	s2,0x15
    80001c38:	49c90913          	addi	s2,s2,1180 # 800170d0 <tickslock>
    acquire(&p->lock);
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	fffff097          	auipc	ra,0xfffff
    80001c42:	f92080e7          	jalr	-110(ra) # 80000bd0 <acquire>
    if(p->state == UNUSED) {
    80001c46:	4c9c                	lw	a5,24(s1)
    80001c48:	cf81                	beqz	a5,80001c60 <allocproc+0x40>
      release(&p->lock);
    80001c4a:	8526                	mv	a0,s1
    80001c4c:	fffff097          	auipc	ra,0xfffff
    80001c50:	038080e7          	jalr	56(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c54:	16848493          	addi	s1,s1,360
    80001c58:	ff2492e3          	bne	s1,s2,80001c3c <allocproc+0x1c>
  return 0;
    80001c5c:	4481                	li	s1,0
    80001c5e:	a889                	j	80001cb0 <allocproc+0x90>
  p->pid = allocpid();
    80001c60:	00000097          	auipc	ra,0x0
    80001c64:	e34080e7          	jalr	-460(ra) # 80001a94 <allocpid>
    80001c68:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c6a:	4785                	li	a5,1
    80001c6c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c6e:	fffff097          	auipc	ra,0xfffff
    80001c72:	e72080e7          	jalr	-398(ra) # 80000ae0 <kalloc>
    80001c76:	892a                	mv	s2,a0
    80001c78:	eca8                	sd	a0,88(s1)
    80001c7a:	c131                	beqz	a0,80001cbe <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	00000097          	auipc	ra,0x0
    80001c82:	e5c080e7          	jalr	-420(ra) # 80001ada <proc_pagetable>
    80001c86:	892a                	mv	s2,a0
    80001c88:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c8a:	c531                	beqz	a0,80001cd6 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c8c:	07000613          	li	a2,112
    80001c90:	4581                	li	a1,0
    80001c92:	06048513          	addi	a0,s1,96
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	036080e7          	jalr	54(ra) # 80000ccc <memset>
  p->context.ra = (uint64)forkret;
    80001c9e:	00000797          	auipc	a5,0x0
    80001ca2:	db078793          	addi	a5,a5,-592 # 80001a4e <forkret>
    80001ca6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ca8:	60bc                	ld	a5,64(s1)
    80001caa:	6705                	lui	a4,0x1
    80001cac:	97ba                	add	a5,a5,a4
    80001cae:	f4bc                	sd	a5,104(s1)
}
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	60e2                	ld	ra,24(sp)
    80001cb4:	6442                	ld	s0,16(sp)
    80001cb6:	64a2                	ld	s1,8(sp)
    80001cb8:	6902                	ld	s2,0(sp)
    80001cba:	6105                	addi	sp,sp,32
    80001cbc:	8082                	ret
    freeproc(p);
    80001cbe:	8526                	mv	a0,s1
    80001cc0:	00000097          	auipc	ra,0x0
    80001cc4:	f08080e7          	jalr	-248(ra) # 80001bc8 <freeproc>
    release(&p->lock);
    80001cc8:	8526                	mv	a0,s1
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	fba080e7          	jalr	-70(ra) # 80000c84 <release>
    return 0;
    80001cd2:	84ca                	mv	s1,s2
    80001cd4:	bff1                	j	80001cb0 <allocproc+0x90>
    freeproc(p);
    80001cd6:	8526                	mv	a0,s1
    80001cd8:	00000097          	auipc	ra,0x0
    80001cdc:	ef0080e7          	jalr	-272(ra) # 80001bc8 <freeproc>
    release(&p->lock);
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	fa2080e7          	jalr	-94(ra) # 80000c84 <release>
    return 0;
    80001cea:	84ca                	mv	s1,s2
    80001cec:	b7d1                	j	80001cb0 <allocproc+0x90>

0000000080001cee <userinit>:
{
    80001cee:	1101                	addi	sp,sp,-32
    80001cf0:	ec06                	sd	ra,24(sp)
    80001cf2:	e822                	sd	s0,16(sp)
    80001cf4:	e426                	sd	s1,8(sp)
    80001cf6:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cf8:	00000097          	auipc	ra,0x0
    80001cfc:	f28080e7          	jalr	-216(ra) # 80001c20 <allocproc>
    80001d00:	84aa                	mv	s1,a0
  initproc = p;
    80001d02:	00007797          	auipc	a5,0x7
    80001d06:	32a7b323          	sd	a0,806(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d0a:	03400613          	li	a2,52
    80001d0e:	00007597          	auipc	a1,0x7
    80001d12:	c1258593          	addi	a1,a1,-1006 # 80008920 <initcode>
    80001d16:	6928                	ld	a0,80(a0)
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	634080e7          	jalr	1588(ra) # 8000134c <uvminit>
  p->sz = PGSIZE;
    80001d20:	6785                	lui	a5,0x1
    80001d22:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d24:	6cb8                	ld	a4,88(s1)
    80001d26:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d2a:	6cb8                	ld	a4,88(s1)
    80001d2c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d2e:	4641                	li	a2,16
    80001d30:	00006597          	auipc	a1,0x6
    80001d34:	55058593          	addi	a1,a1,1360 # 80008280 <digits+0x240>
    80001d38:	15848513          	addi	a0,s1,344
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	0da080e7          	jalr	218(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001d44:	00006517          	auipc	a0,0x6
    80001d48:	54c50513          	addi	a0,a0,1356 # 80008290 <digits+0x250>
    80001d4c:	00002097          	auipc	ra,0x2
    80001d50:	156080e7          	jalr	342(ra) # 80003ea2 <namei>
    80001d54:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d58:	478d                	li	a5,3
    80001d5a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d5c:	8526                	mv	a0,s1
    80001d5e:	fffff097          	auipc	ra,0xfffff
    80001d62:	f26080e7          	jalr	-218(ra) # 80000c84 <release>
}
    80001d66:	60e2                	ld	ra,24(sp)
    80001d68:	6442                	ld	s0,16(sp)
    80001d6a:	64a2                	ld	s1,8(sp)
    80001d6c:	6105                	addi	sp,sp,32
    80001d6e:	8082                	ret

0000000080001d70 <growproc>:
{
    80001d70:	1101                	addi	sp,sp,-32
    80001d72:	ec06                	sd	ra,24(sp)
    80001d74:	e822                	sd	s0,16(sp)
    80001d76:	e426                	sd	s1,8(sp)
    80001d78:	e04a                	sd	s2,0(sp)
    80001d7a:	1000                	addi	s0,sp,32
    80001d7c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d7e:	00000097          	auipc	ra,0x0
    80001d82:	c98080e7          	jalr	-872(ra) # 80001a16 <myproc>
    80001d86:	892a                	mv	s2,a0
  sz = p->sz;
    80001d88:	652c                	ld	a1,72(a0)
    80001d8a:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001d8e:	00904f63          	bgtz	s1,80001dac <growproc+0x3c>
  } else if(n < 0){
    80001d92:	0204cd63          	bltz	s1,80001dcc <growproc+0x5c>
  p->sz = sz;
    80001d96:	1782                	slli	a5,a5,0x20
    80001d98:	9381                	srli	a5,a5,0x20
    80001d9a:	04f93423          	sd	a5,72(s2)
  return 0;
    80001d9e:	4501                	li	a0,0
}
    80001da0:	60e2                	ld	ra,24(sp)
    80001da2:	6442                	ld	s0,16(sp)
    80001da4:	64a2                	ld	s1,8(sp)
    80001da6:	6902                	ld	s2,0(sp)
    80001da8:	6105                	addi	sp,sp,32
    80001daa:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dac:	00f4863b          	addw	a2,s1,a5
    80001db0:	1602                	slli	a2,a2,0x20
    80001db2:	9201                	srli	a2,a2,0x20
    80001db4:	1582                	slli	a1,a1,0x20
    80001db6:	9181                	srli	a1,a1,0x20
    80001db8:	6928                	ld	a0,80(a0)
    80001dba:	fffff097          	auipc	ra,0xfffff
    80001dbe:	64c080e7          	jalr	1612(ra) # 80001406 <uvmalloc>
    80001dc2:	0005079b          	sext.w	a5,a0
    80001dc6:	fbe1                	bnez	a5,80001d96 <growproc+0x26>
      return -1;
    80001dc8:	557d                	li	a0,-1
    80001dca:	bfd9                	j	80001da0 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dcc:	00f4863b          	addw	a2,s1,a5
    80001dd0:	1602                	slli	a2,a2,0x20
    80001dd2:	9201                	srli	a2,a2,0x20
    80001dd4:	1582                	slli	a1,a1,0x20
    80001dd6:	9181                	srli	a1,a1,0x20
    80001dd8:	6928                	ld	a0,80(a0)
    80001dda:	fffff097          	auipc	ra,0xfffff
    80001dde:	5e4080e7          	jalr	1508(ra) # 800013be <uvmdealloc>
    80001de2:	0005079b          	sext.w	a5,a0
    80001de6:	bf45                	j	80001d96 <growproc+0x26>

0000000080001de8 <fork>:
{
    80001de8:	7139                	addi	sp,sp,-64
    80001dea:	fc06                	sd	ra,56(sp)
    80001dec:	f822                	sd	s0,48(sp)
    80001dee:	f426                	sd	s1,40(sp)
    80001df0:	f04a                	sd	s2,32(sp)
    80001df2:	ec4e                	sd	s3,24(sp)
    80001df4:	e852                	sd	s4,16(sp)
    80001df6:	e456                	sd	s5,8(sp)
    80001df8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dfa:	00000097          	auipc	ra,0x0
    80001dfe:	c1c080e7          	jalr	-996(ra) # 80001a16 <myproc>
    80001e02:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e04:	00000097          	auipc	ra,0x0
    80001e08:	e1c080e7          	jalr	-484(ra) # 80001c20 <allocproc>
    80001e0c:	10050c63          	beqz	a0,80001f24 <fork+0x13c>
    80001e10:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e12:	048ab603          	ld	a2,72(s5)
    80001e16:	692c                	ld	a1,80(a0)
    80001e18:	050ab503          	ld	a0,80(s5)
    80001e1c:	fffff097          	auipc	ra,0xfffff
    80001e20:	73a080e7          	jalr	1850(ra) # 80001556 <uvmcopy>
    80001e24:	04054863          	bltz	a0,80001e74 <fork+0x8c>
  np->sz = p->sz;
    80001e28:	048ab783          	ld	a5,72(s5)
    80001e2c:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e30:	058ab683          	ld	a3,88(s5)
    80001e34:	87b6                	mv	a5,a3
    80001e36:	058a3703          	ld	a4,88(s4)
    80001e3a:	12068693          	addi	a3,a3,288
    80001e3e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e42:	6788                	ld	a0,8(a5)
    80001e44:	6b8c                	ld	a1,16(a5)
    80001e46:	6f90                	ld	a2,24(a5)
    80001e48:	01073023          	sd	a6,0(a4)
    80001e4c:	e708                	sd	a0,8(a4)
    80001e4e:	eb0c                	sd	a1,16(a4)
    80001e50:	ef10                	sd	a2,24(a4)
    80001e52:	02078793          	addi	a5,a5,32
    80001e56:	02070713          	addi	a4,a4,32
    80001e5a:	fed792e3          	bne	a5,a3,80001e3e <fork+0x56>
  np->trapframe->a0 = 0;
    80001e5e:	058a3783          	ld	a5,88(s4)
    80001e62:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e66:	0d0a8493          	addi	s1,s5,208
    80001e6a:	0d0a0913          	addi	s2,s4,208
    80001e6e:	150a8993          	addi	s3,s5,336
    80001e72:	a00d                	j	80001e94 <fork+0xac>
    freeproc(np);
    80001e74:	8552                	mv	a0,s4
    80001e76:	00000097          	auipc	ra,0x0
    80001e7a:	d52080e7          	jalr	-686(ra) # 80001bc8 <freeproc>
    release(&np->lock);
    80001e7e:	8552                	mv	a0,s4
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	e04080e7          	jalr	-508(ra) # 80000c84 <release>
    return -1;
    80001e88:	597d                	li	s2,-1
    80001e8a:	a059                	j	80001f10 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e8c:	04a1                	addi	s1,s1,8
    80001e8e:	0921                	addi	s2,s2,8
    80001e90:	01348b63          	beq	s1,s3,80001ea6 <fork+0xbe>
    if(p->ofile[i])
    80001e94:	6088                	ld	a0,0(s1)
    80001e96:	d97d                	beqz	a0,80001e8c <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e98:	00002097          	auipc	ra,0x2
    80001e9c:	6a0080e7          	jalr	1696(ra) # 80004538 <filedup>
    80001ea0:	00a93023          	sd	a0,0(s2)
    80001ea4:	b7e5                	j	80001e8c <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ea6:	150ab503          	ld	a0,336(s5)
    80001eaa:	00001097          	auipc	ra,0x1
    80001eae:	7fe080e7          	jalr	2046(ra) # 800036a8 <idup>
    80001eb2:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eb6:	4641                	li	a2,16
    80001eb8:	158a8593          	addi	a1,s5,344
    80001ebc:	158a0513          	addi	a0,s4,344
    80001ec0:	fffff097          	auipc	ra,0xfffff
    80001ec4:	f56080e7          	jalr	-170(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001ec8:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ecc:	8552                	mv	a0,s4
    80001ece:	fffff097          	auipc	ra,0xfffff
    80001ed2:	db6080e7          	jalr	-586(ra) # 80000c84 <release>
  acquire(&wait_lock);
    80001ed6:	0000f497          	auipc	s1,0xf
    80001eda:	3e248493          	addi	s1,s1,994 # 800112b8 <wait_lock>
    80001ede:	8526                	mv	a0,s1
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	cf0080e7          	jalr	-784(ra) # 80000bd0 <acquire>
  np->parent = p;
    80001ee8:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001eec:	8526                	mv	a0,s1
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	d96080e7          	jalr	-618(ra) # 80000c84 <release>
  acquire(&np->lock);
    80001ef6:	8552                	mv	a0,s4
    80001ef8:	fffff097          	auipc	ra,0xfffff
    80001efc:	cd8080e7          	jalr	-808(ra) # 80000bd0 <acquire>
  np->state = RUNNABLE;
    80001f00:	478d                	li	a5,3
    80001f02:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f06:	8552                	mv	a0,s4
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	d7c080e7          	jalr	-644(ra) # 80000c84 <release>
}
    80001f10:	854a                	mv	a0,s2
    80001f12:	70e2                	ld	ra,56(sp)
    80001f14:	7442                	ld	s0,48(sp)
    80001f16:	74a2                	ld	s1,40(sp)
    80001f18:	7902                	ld	s2,32(sp)
    80001f1a:	69e2                	ld	s3,24(sp)
    80001f1c:	6a42                	ld	s4,16(sp)
    80001f1e:	6aa2                	ld	s5,8(sp)
    80001f20:	6121                	addi	sp,sp,64
    80001f22:	8082                	ret
    return -1;
    80001f24:	597d                	li	s2,-1
    80001f26:	b7ed                	j	80001f10 <fork+0x128>

0000000080001f28 <scheduler>:
{
    80001f28:	7139                	addi	sp,sp,-64
    80001f2a:	fc06                	sd	ra,56(sp)
    80001f2c:	f822                	sd	s0,48(sp)
    80001f2e:	f426                	sd	s1,40(sp)
    80001f30:	f04a                	sd	s2,32(sp)
    80001f32:	ec4e                	sd	s3,24(sp)
    80001f34:	e852                	sd	s4,16(sp)
    80001f36:	e456                	sd	s5,8(sp)
    80001f38:	e05a                	sd	s6,0(sp)
    80001f3a:	0080                	addi	s0,sp,64
    80001f3c:	8792                	mv	a5,tp
  int id = r_tp();
    80001f3e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f40:	00779a93          	slli	s5,a5,0x7
    80001f44:	0000f717          	auipc	a4,0xf
    80001f48:	35c70713          	addi	a4,a4,860 # 800112a0 <pid_lock>
    80001f4c:	9756                	add	a4,a4,s5
    80001f4e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f52:	0000f717          	auipc	a4,0xf
    80001f56:	38670713          	addi	a4,a4,902 # 800112d8 <cpus+0x8>
    80001f5a:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f5c:	498d                	li	s3,3
        p->state = RUNNING;
    80001f5e:	4b11                	li	s6,4
        c->proc = p;
    80001f60:	079e                	slli	a5,a5,0x7
    80001f62:	0000fa17          	auipc	s4,0xf
    80001f66:	33ea0a13          	addi	s4,s4,830 # 800112a0 <pid_lock>
    80001f6a:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f6c:	00015917          	auipc	s2,0x15
    80001f70:	16490913          	addi	s2,s2,356 # 800170d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f74:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f78:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f7c:	10079073          	csrw	sstatus,a5
    80001f80:	0000f497          	auipc	s1,0xf
    80001f84:	75048493          	addi	s1,s1,1872 # 800116d0 <proc>
    80001f88:	a811                	j	80001f9c <scheduler+0x74>
      release(&p->lock);
    80001f8a:	8526                	mv	a0,s1
    80001f8c:	fffff097          	auipc	ra,0xfffff
    80001f90:	cf8080e7          	jalr	-776(ra) # 80000c84 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f94:	16848493          	addi	s1,s1,360
    80001f98:	fd248ee3          	beq	s1,s2,80001f74 <scheduler+0x4c>
      acquire(&p->lock);
    80001f9c:	8526                	mv	a0,s1
    80001f9e:	fffff097          	auipc	ra,0xfffff
    80001fa2:	c32080e7          	jalr	-974(ra) # 80000bd0 <acquire>
      if(p->state == RUNNABLE) {
    80001fa6:	4c9c                	lw	a5,24(s1)
    80001fa8:	ff3791e3          	bne	a5,s3,80001f8a <scheduler+0x62>
        p->state = RUNNING;
    80001fac:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fb0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fb4:	06048593          	addi	a1,s1,96
    80001fb8:	8556                	mv	a0,s5
    80001fba:	00000097          	auipc	ra,0x0
    80001fbe:	620080e7          	jalr	1568(ra) # 800025da <swtch>
        c->proc = 0;
    80001fc2:	020a3823          	sd	zero,48(s4)
    80001fc6:	b7d1                	j	80001f8a <scheduler+0x62>

0000000080001fc8 <sched>:
{
    80001fc8:	7179                	addi	sp,sp,-48
    80001fca:	f406                	sd	ra,40(sp)
    80001fcc:	f022                	sd	s0,32(sp)
    80001fce:	ec26                	sd	s1,24(sp)
    80001fd0:	e84a                	sd	s2,16(sp)
    80001fd2:	e44e                	sd	s3,8(sp)
    80001fd4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fd6:	00000097          	auipc	ra,0x0
    80001fda:	a40080e7          	jalr	-1472(ra) # 80001a16 <myproc>
    80001fde:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fe0:	fffff097          	auipc	ra,0xfffff
    80001fe4:	b76080e7          	jalr	-1162(ra) # 80000b56 <holding>
    80001fe8:	c93d                	beqz	a0,8000205e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fea:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fec:	2781                	sext.w	a5,a5
    80001fee:	079e                	slli	a5,a5,0x7
    80001ff0:	0000f717          	auipc	a4,0xf
    80001ff4:	2b070713          	addi	a4,a4,688 # 800112a0 <pid_lock>
    80001ff8:	97ba                	add	a5,a5,a4
    80001ffa:	0a87a703          	lw	a4,168(a5)
    80001ffe:	4785                	li	a5,1
    80002000:	06f71763          	bne	a4,a5,8000206e <sched+0xa6>
  if(p->state == RUNNING)
    80002004:	4c98                	lw	a4,24(s1)
    80002006:	4791                	li	a5,4
    80002008:	06f70b63          	beq	a4,a5,8000207e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000200c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002010:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002012:	efb5                	bnez	a5,8000208e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002014:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002016:	0000f917          	auipc	s2,0xf
    8000201a:	28a90913          	addi	s2,s2,650 # 800112a0 <pid_lock>
    8000201e:	2781                	sext.w	a5,a5
    80002020:	079e                	slli	a5,a5,0x7
    80002022:	97ca                	add	a5,a5,s2
    80002024:	0ac7a983          	lw	s3,172(a5)
    80002028:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000202a:	2781                	sext.w	a5,a5
    8000202c:	079e                	slli	a5,a5,0x7
    8000202e:	0000f597          	auipc	a1,0xf
    80002032:	2aa58593          	addi	a1,a1,682 # 800112d8 <cpus+0x8>
    80002036:	95be                	add	a1,a1,a5
    80002038:	06048513          	addi	a0,s1,96
    8000203c:	00000097          	auipc	ra,0x0
    80002040:	59e080e7          	jalr	1438(ra) # 800025da <swtch>
    80002044:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002046:	2781                	sext.w	a5,a5
    80002048:	079e                	slli	a5,a5,0x7
    8000204a:	993e                	add	s2,s2,a5
    8000204c:	0b392623          	sw	s3,172(s2)
}
    80002050:	70a2                	ld	ra,40(sp)
    80002052:	7402                	ld	s0,32(sp)
    80002054:	64e2                	ld	s1,24(sp)
    80002056:	6942                	ld	s2,16(sp)
    80002058:	69a2                	ld	s3,8(sp)
    8000205a:	6145                	addi	sp,sp,48
    8000205c:	8082                	ret
    panic("sched p->lock");
    8000205e:	00006517          	auipc	a0,0x6
    80002062:	23a50513          	addi	a0,a0,570 # 80008298 <digits+0x258>
    80002066:	ffffe097          	auipc	ra,0xffffe
    8000206a:	4d4080e7          	jalr	1236(ra) # 8000053a <panic>
    panic("sched locks");
    8000206e:	00006517          	auipc	a0,0x6
    80002072:	23a50513          	addi	a0,a0,570 # 800082a8 <digits+0x268>
    80002076:	ffffe097          	auipc	ra,0xffffe
    8000207a:	4c4080e7          	jalr	1220(ra) # 8000053a <panic>
    panic("sched running");
    8000207e:	00006517          	auipc	a0,0x6
    80002082:	23a50513          	addi	a0,a0,570 # 800082b8 <digits+0x278>
    80002086:	ffffe097          	auipc	ra,0xffffe
    8000208a:	4b4080e7          	jalr	1204(ra) # 8000053a <panic>
    panic("sched interruptible");
    8000208e:	00006517          	auipc	a0,0x6
    80002092:	23a50513          	addi	a0,a0,570 # 800082c8 <digits+0x288>
    80002096:	ffffe097          	auipc	ra,0xffffe
    8000209a:	4a4080e7          	jalr	1188(ra) # 8000053a <panic>

000000008000209e <yield>:
{
    8000209e:	1101                	addi	sp,sp,-32
    800020a0:	ec06                	sd	ra,24(sp)
    800020a2:	e822                	sd	s0,16(sp)
    800020a4:	e426                	sd	s1,8(sp)
    800020a6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020a8:	00000097          	auipc	ra,0x0
    800020ac:	96e080e7          	jalr	-1682(ra) # 80001a16 <myproc>
    800020b0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020b2:	fffff097          	auipc	ra,0xfffff
    800020b6:	b1e080e7          	jalr	-1250(ra) # 80000bd0 <acquire>
  p->state = RUNNABLE;
    800020ba:	478d                	li	a5,3
    800020bc:	cc9c                	sw	a5,24(s1)
  sched();
    800020be:	00000097          	auipc	ra,0x0
    800020c2:	f0a080e7          	jalr	-246(ra) # 80001fc8 <sched>
  release(&p->lock);
    800020c6:	8526                	mv	a0,s1
    800020c8:	fffff097          	auipc	ra,0xfffff
    800020cc:	bbc080e7          	jalr	-1092(ra) # 80000c84 <release>
}
    800020d0:	60e2                	ld	ra,24(sp)
    800020d2:	6442                	ld	s0,16(sp)
    800020d4:	64a2                	ld	s1,8(sp)
    800020d6:	6105                	addi	sp,sp,32
    800020d8:	8082                	ret

00000000800020da <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020da:	7179                	addi	sp,sp,-48
    800020dc:	f406                	sd	ra,40(sp)
    800020de:	f022                	sd	s0,32(sp)
    800020e0:	ec26                	sd	s1,24(sp)
    800020e2:	e84a                	sd	s2,16(sp)
    800020e4:	e44e                	sd	s3,8(sp)
    800020e6:	1800                	addi	s0,sp,48
    800020e8:	89aa                	mv	s3,a0
    800020ea:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020ec:	00000097          	auipc	ra,0x0
    800020f0:	92a080e7          	jalr	-1750(ra) # 80001a16 <myproc>
    800020f4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	ada080e7          	jalr	-1318(ra) # 80000bd0 <acquire>
  release(lk);
    800020fe:	854a                	mv	a0,s2
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	b84080e7          	jalr	-1148(ra) # 80000c84 <release>

  // Go to sleep.
  p->chan = chan;
    80002108:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000210c:	4789                	li	a5,2
    8000210e:	cc9c                	sw	a5,24(s1)

  sched();
    80002110:	00000097          	auipc	ra,0x0
    80002114:	eb8080e7          	jalr	-328(ra) # 80001fc8 <sched>

  // Tidy up.
  p->chan = 0;
    80002118:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000211c:	8526                	mv	a0,s1
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	b66080e7          	jalr	-1178(ra) # 80000c84 <release>
  acquire(lk);
    80002126:	854a                	mv	a0,s2
    80002128:	fffff097          	auipc	ra,0xfffff
    8000212c:	aa8080e7          	jalr	-1368(ra) # 80000bd0 <acquire>
}
    80002130:	70a2                	ld	ra,40(sp)
    80002132:	7402                	ld	s0,32(sp)
    80002134:	64e2                	ld	s1,24(sp)
    80002136:	6942                	ld	s2,16(sp)
    80002138:	69a2                	ld	s3,8(sp)
    8000213a:	6145                	addi	sp,sp,48
    8000213c:	8082                	ret

000000008000213e <wait>:
{
    8000213e:	715d                	addi	sp,sp,-80
    80002140:	e486                	sd	ra,72(sp)
    80002142:	e0a2                	sd	s0,64(sp)
    80002144:	fc26                	sd	s1,56(sp)
    80002146:	f84a                	sd	s2,48(sp)
    80002148:	f44e                	sd	s3,40(sp)
    8000214a:	f052                	sd	s4,32(sp)
    8000214c:	ec56                	sd	s5,24(sp)
    8000214e:	e85a                	sd	s6,16(sp)
    80002150:	e45e                	sd	s7,8(sp)
    80002152:	e062                	sd	s8,0(sp)
    80002154:	0880                	addi	s0,sp,80
    80002156:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002158:	00000097          	auipc	ra,0x0
    8000215c:	8be080e7          	jalr	-1858(ra) # 80001a16 <myproc>
    80002160:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002162:	0000f517          	auipc	a0,0xf
    80002166:	15650513          	addi	a0,a0,342 # 800112b8 <wait_lock>
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	a66080e7          	jalr	-1434(ra) # 80000bd0 <acquire>
    havekids = 0;
    80002172:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002174:	4a15                	li	s4,5
        havekids = 1;
    80002176:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002178:	00015997          	auipc	s3,0x15
    8000217c:	f5898993          	addi	s3,s3,-168 # 800170d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002180:	0000fc17          	auipc	s8,0xf
    80002184:	138c0c13          	addi	s8,s8,312 # 800112b8 <wait_lock>
    havekids = 0;
    80002188:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000218a:	0000f497          	auipc	s1,0xf
    8000218e:	54648493          	addi	s1,s1,1350 # 800116d0 <proc>
    80002192:	a0bd                	j	80002200 <wait+0xc2>
          pid = np->pid;
    80002194:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002198:	000b0e63          	beqz	s6,800021b4 <wait+0x76>
    8000219c:	4691                	li	a3,4
    8000219e:	02c48613          	addi	a2,s1,44
    800021a2:	85da                	mv	a1,s6
    800021a4:	05093503          	ld	a0,80(s2)
    800021a8:	fffff097          	auipc	ra,0xfffff
    800021ac:	4b2080e7          	jalr	1202(ra) # 8000165a <copyout>
    800021b0:	02054563          	bltz	a0,800021da <wait+0x9c>
          freeproc(np);
    800021b4:	8526                	mv	a0,s1
    800021b6:	00000097          	auipc	ra,0x0
    800021ba:	a12080e7          	jalr	-1518(ra) # 80001bc8 <freeproc>
          release(&np->lock);
    800021be:	8526                	mv	a0,s1
    800021c0:	fffff097          	auipc	ra,0xfffff
    800021c4:	ac4080e7          	jalr	-1340(ra) # 80000c84 <release>
          release(&wait_lock);
    800021c8:	0000f517          	auipc	a0,0xf
    800021cc:	0f050513          	addi	a0,a0,240 # 800112b8 <wait_lock>
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	ab4080e7          	jalr	-1356(ra) # 80000c84 <release>
          return pid;
    800021d8:	a09d                	j	8000223e <wait+0x100>
            release(&np->lock);
    800021da:	8526                	mv	a0,s1
    800021dc:	fffff097          	auipc	ra,0xfffff
    800021e0:	aa8080e7          	jalr	-1368(ra) # 80000c84 <release>
            release(&wait_lock);
    800021e4:	0000f517          	auipc	a0,0xf
    800021e8:	0d450513          	addi	a0,a0,212 # 800112b8 <wait_lock>
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	a98080e7          	jalr	-1384(ra) # 80000c84 <release>
            return -1;
    800021f4:	59fd                	li	s3,-1
    800021f6:	a0a1                	j	8000223e <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800021f8:	16848493          	addi	s1,s1,360
    800021fc:	03348463          	beq	s1,s3,80002224 <wait+0xe6>
      if(np->parent == p){
    80002200:	7c9c                	ld	a5,56(s1)
    80002202:	ff279be3          	bne	a5,s2,800021f8 <wait+0xba>
        acquire(&np->lock);
    80002206:	8526                	mv	a0,s1
    80002208:	fffff097          	auipc	ra,0xfffff
    8000220c:	9c8080e7          	jalr	-1592(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    80002210:	4c9c                	lw	a5,24(s1)
    80002212:	f94781e3          	beq	a5,s4,80002194 <wait+0x56>
        release(&np->lock);
    80002216:	8526                	mv	a0,s1
    80002218:	fffff097          	auipc	ra,0xfffff
    8000221c:	a6c080e7          	jalr	-1428(ra) # 80000c84 <release>
        havekids = 1;
    80002220:	8756                	mv	a4,s5
    80002222:	bfd9                	j	800021f8 <wait+0xba>
    if(!havekids || p->killed){
    80002224:	c701                	beqz	a4,8000222c <wait+0xee>
    80002226:	02892783          	lw	a5,40(s2)
    8000222a:	c79d                	beqz	a5,80002258 <wait+0x11a>
      release(&wait_lock);
    8000222c:	0000f517          	auipc	a0,0xf
    80002230:	08c50513          	addi	a0,a0,140 # 800112b8 <wait_lock>
    80002234:	fffff097          	auipc	ra,0xfffff
    80002238:	a50080e7          	jalr	-1456(ra) # 80000c84 <release>
      return -1;
    8000223c:	59fd                	li	s3,-1
}
    8000223e:	854e                	mv	a0,s3
    80002240:	60a6                	ld	ra,72(sp)
    80002242:	6406                	ld	s0,64(sp)
    80002244:	74e2                	ld	s1,56(sp)
    80002246:	7942                	ld	s2,48(sp)
    80002248:	79a2                	ld	s3,40(sp)
    8000224a:	7a02                	ld	s4,32(sp)
    8000224c:	6ae2                	ld	s5,24(sp)
    8000224e:	6b42                	ld	s6,16(sp)
    80002250:	6ba2                	ld	s7,8(sp)
    80002252:	6c02                	ld	s8,0(sp)
    80002254:	6161                	addi	sp,sp,80
    80002256:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002258:	85e2                	mv	a1,s8
    8000225a:	854a                	mv	a0,s2
    8000225c:	00000097          	auipc	ra,0x0
    80002260:	e7e080e7          	jalr	-386(ra) # 800020da <sleep>
    havekids = 0;
    80002264:	b715                	j	80002188 <wait+0x4a>

0000000080002266 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002266:	7139                	addi	sp,sp,-64
    80002268:	fc06                	sd	ra,56(sp)
    8000226a:	f822                	sd	s0,48(sp)
    8000226c:	f426                	sd	s1,40(sp)
    8000226e:	f04a                	sd	s2,32(sp)
    80002270:	ec4e                	sd	s3,24(sp)
    80002272:	e852                	sd	s4,16(sp)
    80002274:	e456                	sd	s5,8(sp)
    80002276:	0080                	addi	s0,sp,64
    80002278:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000227a:	0000f497          	auipc	s1,0xf
    8000227e:	45648493          	addi	s1,s1,1110 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002282:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002284:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002286:	00015917          	auipc	s2,0x15
    8000228a:	e4a90913          	addi	s2,s2,-438 # 800170d0 <tickslock>
    8000228e:	a811                	j	800022a2 <wakeup+0x3c>
      }
      release(&p->lock);
    80002290:	8526                	mv	a0,s1
    80002292:	fffff097          	auipc	ra,0xfffff
    80002296:	9f2080e7          	jalr	-1550(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000229a:	16848493          	addi	s1,s1,360
    8000229e:	03248663          	beq	s1,s2,800022ca <wakeup+0x64>
    if(p != myproc()){
    800022a2:	fffff097          	auipc	ra,0xfffff
    800022a6:	774080e7          	jalr	1908(ra) # 80001a16 <myproc>
    800022aa:	fea488e3          	beq	s1,a0,8000229a <wakeup+0x34>
      acquire(&p->lock);
    800022ae:	8526                	mv	a0,s1
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	920080e7          	jalr	-1760(ra) # 80000bd0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022b8:	4c9c                	lw	a5,24(s1)
    800022ba:	fd379be3          	bne	a5,s3,80002290 <wakeup+0x2a>
    800022be:	709c                	ld	a5,32(s1)
    800022c0:	fd4798e3          	bne	a5,s4,80002290 <wakeup+0x2a>
        p->state = RUNNABLE;
    800022c4:	0154ac23          	sw	s5,24(s1)
    800022c8:	b7e1                	j	80002290 <wakeup+0x2a>
    }
  }
}
    800022ca:	70e2                	ld	ra,56(sp)
    800022cc:	7442                	ld	s0,48(sp)
    800022ce:	74a2                	ld	s1,40(sp)
    800022d0:	7902                	ld	s2,32(sp)
    800022d2:	69e2                	ld	s3,24(sp)
    800022d4:	6a42                	ld	s4,16(sp)
    800022d6:	6aa2                	ld	s5,8(sp)
    800022d8:	6121                	addi	sp,sp,64
    800022da:	8082                	ret

00000000800022dc <reparent>:
{
    800022dc:	7179                	addi	sp,sp,-48
    800022de:	f406                	sd	ra,40(sp)
    800022e0:	f022                	sd	s0,32(sp)
    800022e2:	ec26                	sd	s1,24(sp)
    800022e4:	e84a                	sd	s2,16(sp)
    800022e6:	e44e                	sd	s3,8(sp)
    800022e8:	e052                	sd	s4,0(sp)
    800022ea:	1800                	addi	s0,sp,48
    800022ec:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022ee:	0000f497          	auipc	s1,0xf
    800022f2:	3e248493          	addi	s1,s1,994 # 800116d0 <proc>
      pp->parent = initproc;
    800022f6:	00007a17          	auipc	s4,0x7
    800022fa:	d32a0a13          	addi	s4,s4,-718 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022fe:	00015997          	auipc	s3,0x15
    80002302:	dd298993          	addi	s3,s3,-558 # 800170d0 <tickslock>
    80002306:	a029                	j	80002310 <reparent+0x34>
    80002308:	16848493          	addi	s1,s1,360
    8000230c:	01348d63          	beq	s1,s3,80002326 <reparent+0x4a>
    if(pp->parent == p){
    80002310:	7c9c                	ld	a5,56(s1)
    80002312:	ff279be3          	bne	a5,s2,80002308 <reparent+0x2c>
      pp->parent = initproc;
    80002316:	000a3503          	ld	a0,0(s4)
    8000231a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000231c:	00000097          	auipc	ra,0x0
    80002320:	f4a080e7          	jalr	-182(ra) # 80002266 <wakeup>
    80002324:	b7d5                	j	80002308 <reparent+0x2c>
}
    80002326:	70a2                	ld	ra,40(sp)
    80002328:	7402                	ld	s0,32(sp)
    8000232a:	64e2                	ld	s1,24(sp)
    8000232c:	6942                	ld	s2,16(sp)
    8000232e:	69a2                	ld	s3,8(sp)
    80002330:	6a02                	ld	s4,0(sp)
    80002332:	6145                	addi	sp,sp,48
    80002334:	8082                	ret

0000000080002336 <exit>:
{
    80002336:	7179                	addi	sp,sp,-48
    80002338:	f406                	sd	ra,40(sp)
    8000233a:	f022                	sd	s0,32(sp)
    8000233c:	ec26                	sd	s1,24(sp)
    8000233e:	e84a                	sd	s2,16(sp)
    80002340:	e44e                	sd	s3,8(sp)
    80002342:	e052                	sd	s4,0(sp)
    80002344:	1800                	addi	s0,sp,48
    80002346:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002348:	fffff097          	auipc	ra,0xfffff
    8000234c:	6ce080e7          	jalr	1742(ra) # 80001a16 <myproc>
    80002350:	89aa                	mv	s3,a0
  if(p == initproc)
    80002352:	00007797          	auipc	a5,0x7
    80002356:	cd67b783          	ld	a5,-810(a5) # 80009028 <initproc>
    8000235a:	0d050493          	addi	s1,a0,208
    8000235e:	15050913          	addi	s2,a0,336
    80002362:	02a79363          	bne	a5,a0,80002388 <exit+0x52>
    panic("init exiting");
    80002366:	00006517          	auipc	a0,0x6
    8000236a:	f7a50513          	addi	a0,a0,-134 # 800082e0 <digits+0x2a0>
    8000236e:	ffffe097          	auipc	ra,0xffffe
    80002372:	1cc080e7          	jalr	460(ra) # 8000053a <panic>
      fileclose(f);
    80002376:	00002097          	auipc	ra,0x2
    8000237a:	214080e7          	jalr	532(ra) # 8000458a <fileclose>
      p->ofile[fd] = 0;
    8000237e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002382:	04a1                	addi	s1,s1,8
    80002384:	01248563          	beq	s1,s2,8000238e <exit+0x58>
    if(p->ofile[fd]){
    80002388:	6088                	ld	a0,0(s1)
    8000238a:	f575                	bnez	a0,80002376 <exit+0x40>
    8000238c:	bfdd                	j	80002382 <exit+0x4c>
  begin_op();
    8000238e:	00002097          	auipc	ra,0x2
    80002392:	d34080e7          	jalr	-716(ra) # 800040c2 <begin_op>
  iput(p->cwd);
    80002396:	1509b503          	ld	a0,336(s3)
    8000239a:	00001097          	auipc	ra,0x1
    8000239e:	506080e7          	jalr	1286(ra) # 800038a0 <iput>
  end_op();
    800023a2:	00002097          	auipc	ra,0x2
    800023a6:	d9e080e7          	jalr	-610(ra) # 80004140 <end_op>
  p->cwd = 0;
    800023aa:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800023ae:	0000f497          	auipc	s1,0xf
    800023b2:	f0a48493          	addi	s1,s1,-246 # 800112b8 <wait_lock>
    800023b6:	8526                	mv	a0,s1
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	818080e7          	jalr	-2024(ra) # 80000bd0 <acquire>
  reparent(p);
    800023c0:	854e                	mv	a0,s3
    800023c2:	00000097          	auipc	ra,0x0
    800023c6:	f1a080e7          	jalr	-230(ra) # 800022dc <reparent>
  wakeup(p->parent);
    800023ca:	0389b503          	ld	a0,56(s3)
    800023ce:	00000097          	auipc	ra,0x0
    800023d2:	e98080e7          	jalr	-360(ra) # 80002266 <wakeup>
  acquire(&p->lock);
    800023d6:	854e                	mv	a0,s3
    800023d8:	ffffe097          	auipc	ra,0xffffe
    800023dc:	7f8080e7          	jalr	2040(ra) # 80000bd0 <acquire>
  p->xstate = status;
    800023e0:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023e4:	4795                	li	a5,5
    800023e6:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800023ea:	8526                	mv	a0,s1
    800023ec:	fffff097          	auipc	ra,0xfffff
    800023f0:	898080e7          	jalr	-1896(ra) # 80000c84 <release>
  sched();
    800023f4:	00000097          	auipc	ra,0x0
    800023f8:	bd4080e7          	jalr	-1068(ra) # 80001fc8 <sched>
  panic("zombie exit");
    800023fc:	00006517          	auipc	a0,0x6
    80002400:	ef450513          	addi	a0,a0,-268 # 800082f0 <digits+0x2b0>
    80002404:	ffffe097          	auipc	ra,0xffffe
    80002408:	136080e7          	jalr	310(ra) # 8000053a <panic>

000000008000240c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000240c:	7179                	addi	sp,sp,-48
    8000240e:	f406                	sd	ra,40(sp)
    80002410:	f022                	sd	s0,32(sp)
    80002412:	ec26                	sd	s1,24(sp)
    80002414:	e84a                	sd	s2,16(sp)
    80002416:	e44e                	sd	s3,8(sp)
    80002418:	1800                	addi	s0,sp,48
    8000241a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000241c:	0000f497          	auipc	s1,0xf
    80002420:	2b448493          	addi	s1,s1,692 # 800116d0 <proc>
    80002424:	00015997          	auipc	s3,0x15
    80002428:	cac98993          	addi	s3,s3,-852 # 800170d0 <tickslock>
    acquire(&p->lock);
    8000242c:	8526                	mv	a0,s1
    8000242e:	ffffe097          	auipc	ra,0xffffe
    80002432:	7a2080e7          	jalr	1954(ra) # 80000bd0 <acquire>
    if(p->pid == pid){
    80002436:	589c                	lw	a5,48(s1)
    80002438:	01278d63          	beq	a5,s2,80002452 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000243c:	8526                	mv	a0,s1
    8000243e:	fffff097          	auipc	ra,0xfffff
    80002442:	846080e7          	jalr	-1978(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002446:	16848493          	addi	s1,s1,360
    8000244a:	ff3491e3          	bne	s1,s3,8000242c <kill+0x20>
  }
  return -1;
    8000244e:	557d                	li	a0,-1
    80002450:	a829                	j	8000246a <kill+0x5e>
      p->killed = 1;
    80002452:	4785                	li	a5,1
    80002454:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002456:	4c98                	lw	a4,24(s1)
    80002458:	4789                	li	a5,2
    8000245a:	00f70f63          	beq	a4,a5,80002478 <kill+0x6c>
      release(&p->lock);
    8000245e:	8526                	mv	a0,s1
    80002460:	fffff097          	auipc	ra,0xfffff
    80002464:	824080e7          	jalr	-2012(ra) # 80000c84 <release>
      return 0;
    80002468:	4501                	li	a0,0
}
    8000246a:	70a2                	ld	ra,40(sp)
    8000246c:	7402                	ld	s0,32(sp)
    8000246e:	64e2                	ld	s1,24(sp)
    80002470:	6942                	ld	s2,16(sp)
    80002472:	69a2                	ld	s3,8(sp)
    80002474:	6145                	addi	sp,sp,48
    80002476:	8082                	ret
        p->state = RUNNABLE;
    80002478:	478d                	li	a5,3
    8000247a:	cc9c                	sw	a5,24(s1)
    8000247c:	b7cd                	j	8000245e <kill+0x52>

000000008000247e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000247e:	7179                	addi	sp,sp,-48
    80002480:	f406                	sd	ra,40(sp)
    80002482:	f022                	sd	s0,32(sp)
    80002484:	ec26                	sd	s1,24(sp)
    80002486:	e84a                	sd	s2,16(sp)
    80002488:	e44e                	sd	s3,8(sp)
    8000248a:	e052                	sd	s4,0(sp)
    8000248c:	1800                	addi	s0,sp,48
    8000248e:	84aa                	mv	s1,a0
    80002490:	892e                	mv	s2,a1
    80002492:	89b2                	mv	s3,a2
    80002494:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002496:	fffff097          	auipc	ra,0xfffff
    8000249a:	580080e7          	jalr	1408(ra) # 80001a16 <myproc>
  if(user_dst){
    8000249e:	c08d                	beqz	s1,800024c0 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024a0:	86d2                	mv	a3,s4
    800024a2:	864e                	mv	a2,s3
    800024a4:	85ca                	mv	a1,s2
    800024a6:	6928                	ld	a0,80(a0)
    800024a8:	fffff097          	auipc	ra,0xfffff
    800024ac:	1b2080e7          	jalr	434(ra) # 8000165a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024b0:	70a2                	ld	ra,40(sp)
    800024b2:	7402                	ld	s0,32(sp)
    800024b4:	64e2                	ld	s1,24(sp)
    800024b6:	6942                	ld	s2,16(sp)
    800024b8:	69a2                	ld	s3,8(sp)
    800024ba:	6a02                	ld	s4,0(sp)
    800024bc:	6145                	addi	sp,sp,48
    800024be:	8082                	ret
    memmove((char *)dst, src, len);
    800024c0:	000a061b          	sext.w	a2,s4
    800024c4:	85ce                	mv	a1,s3
    800024c6:	854a                	mv	a0,s2
    800024c8:	fffff097          	auipc	ra,0xfffff
    800024cc:	860080e7          	jalr	-1952(ra) # 80000d28 <memmove>
    return 0;
    800024d0:	8526                	mv	a0,s1
    800024d2:	bff9                	j	800024b0 <either_copyout+0x32>

00000000800024d4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024d4:	7179                	addi	sp,sp,-48
    800024d6:	f406                	sd	ra,40(sp)
    800024d8:	f022                	sd	s0,32(sp)
    800024da:	ec26                	sd	s1,24(sp)
    800024dc:	e84a                	sd	s2,16(sp)
    800024de:	e44e                	sd	s3,8(sp)
    800024e0:	e052                	sd	s4,0(sp)
    800024e2:	1800                	addi	s0,sp,48
    800024e4:	892a                	mv	s2,a0
    800024e6:	84ae                	mv	s1,a1
    800024e8:	89b2                	mv	s3,a2
    800024ea:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	52a080e7          	jalr	1322(ra) # 80001a16 <myproc>
  if(user_src){
    800024f4:	c08d                	beqz	s1,80002516 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024f6:	86d2                	mv	a3,s4
    800024f8:	864e                	mv	a2,s3
    800024fa:	85ca                	mv	a1,s2
    800024fc:	6928                	ld	a0,80(a0)
    800024fe:	fffff097          	auipc	ra,0xfffff
    80002502:	1e8080e7          	jalr	488(ra) # 800016e6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002506:	70a2                	ld	ra,40(sp)
    80002508:	7402                	ld	s0,32(sp)
    8000250a:	64e2                	ld	s1,24(sp)
    8000250c:	6942                	ld	s2,16(sp)
    8000250e:	69a2                	ld	s3,8(sp)
    80002510:	6a02                	ld	s4,0(sp)
    80002512:	6145                	addi	sp,sp,48
    80002514:	8082                	ret
    memmove(dst, (char*)src, len);
    80002516:	000a061b          	sext.w	a2,s4
    8000251a:	85ce                	mv	a1,s3
    8000251c:	854a                	mv	a0,s2
    8000251e:	fffff097          	auipc	ra,0xfffff
    80002522:	80a080e7          	jalr	-2038(ra) # 80000d28 <memmove>
    return 0;
    80002526:	8526                	mv	a0,s1
    80002528:	bff9                	j	80002506 <either_copyin+0x32>

000000008000252a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000252a:	715d                	addi	sp,sp,-80
    8000252c:	e486                	sd	ra,72(sp)
    8000252e:	e0a2                	sd	s0,64(sp)
    80002530:	fc26                	sd	s1,56(sp)
    80002532:	f84a                	sd	s2,48(sp)
    80002534:	f44e                	sd	s3,40(sp)
    80002536:	f052                	sd	s4,32(sp)
    80002538:	ec56                	sd	s5,24(sp)
    8000253a:	e85a                	sd	s6,16(sp)
    8000253c:	e45e                	sd	s7,8(sp)
    8000253e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002540:	00006517          	auipc	a0,0x6
    80002544:	b8850513          	addi	a0,a0,-1144 # 800080c8 <digits+0x88>
    80002548:	ffffe097          	auipc	ra,0xffffe
    8000254c:	03c080e7          	jalr	60(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002550:	0000f497          	auipc	s1,0xf
    80002554:	2d848493          	addi	s1,s1,728 # 80011828 <proc+0x158>
    80002558:	00015917          	auipc	s2,0x15
    8000255c:	cd090913          	addi	s2,s2,-816 # 80017228 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002560:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002562:	00006997          	auipc	s3,0x6
    80002566:	d9e98993          	addi	s3,s3,-610 # 80008300 <digits+0x2c0>
    printf("%d %s %s", p->pid, state, p->name);
    8000256a:	00006a97          	auipc	s5,0x6
    8000256e:	d9ea8a93          	addi	s5,s5,-610 # 80008308 <digits+0x2c8>
    printf("\n");
    80002572:	00006a17          	auipc	s4,0x6
    80002576:	b56a0a13          	addi	s4,s4,-1194 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000257a:	00006b97          	auipc	s7,0x6
    8000257e:	dc6b8b93          	addi	s7,s7,-570 # 80008340 <states.0>
    80002582:	a00d                	j	800025a4 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002584:	ed86a583          	lw	a1,-296(a3)
    80002588:	8556                	mv	a0,s5
    8000258a:	ffffe097          	auipc	ra,0xffffe
    8000258e:	ffa080e7          	jalr	-6(ra) # 80000584 <printf>
    printf("\n");
    80002592:	8552                	mv	a0,s4
    80002594:	ffffe097          	auipc	ra,0xffffe
    80002598:	ff0080e7          	jalr	-16(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000259c:	16848493          	addi	s1,s1,360
    800025a0:	03248263          	beq	s1,s2,800025c4 <procdump+0x9a>
    if(p->state == UNUSED)
    800025a4:	86a6                	mv	a3,s1
    800025a6:	ec04a783          	lw	a5,-320(s1)
    800025aa:	dbed                	beqz	a5,8000259c <procdump+0x72>
      state = "???";
    800025ac:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ae:	fcfb6be3          	bltu	s6,a5,80002584 <procdump+0x5a>
    800025b2:	02079713          	slli	a4,a5,0x20
    800025b6:	01d75793          	srli	a5,a4,0x1d
    800025ba:	97de                	add	a5,a5,s7
    800025bc:	6390                	ld	a2,0(a5)
    800025be:	f279                	bnez	a2,80002584 <procdump+0x5a>
      state = "???";
    800025c0:	864e                	mv	a2,s3
    800025c2:	b7c9                	j	80002584 <procdump+0x5a>
  }
}
    800025c4:	60a6                	ld	ra,72(sp)
    800025c6:	6406                	ld	s0,64(sp)
    800025c8:	74e2                	ld	s1,56(sp)
    800025ca:	7942                	ld	s2,48(sp)
    800025cc:	79a2                	ld	s3,40(sp)
    800025ce:	7a02                	ld	s4,32(sp)
    800025d0:	6ae2                	ld	s5,24(sp)
    800025d2:	6b42                	ld	s6,16(sp)
    800025d4:	6ba2                	ld	s7,8(sp)
    800025d6:	6161                	addi	sp,sp,80
    800025d8:	8082                	ret

00000000800025da <swtch>:
    800025da:	00153023          	sd	ra,0(a0)
    800025de:	00253423          	sd	sp,8(a0)
    800025e2:	e900                	sd	s0,16(a0)
    800025e4:	ed04                	sd	s1,24(a0)
    800025e6:	03253023          	sd	s2,32(a0)
    800025ea:	03353423          	sd	s3,40(a0)
    800025ee:	03453823          	sd	s4,48(a0)
    800025f2:	03553c23          	sd	s5,56(a0)
    800025f6:	05653023          	sd	s6,64(a0)
    800025fa:	05753423          	sd	s7,72(a0)
    800025fe:	05853823          	sd	s8,80(a0)
    80002602:	05953c23          	sd	s9,88(a0)
    80002606:	07a53023          	sd	s10,96(a0)
    8000260a:	07b53423          	sd	s11,104(a0)
    8000260e:	0005b083          	ld	ra,0(a1)
    80002612:	0085b103          	ld	sp,8(a1)
    80002616:	6980                	ld	s0,16(a1)
    80002618:	6d84                	ld	s1,24(a1)
    8000261a:	0205b903          	ld	s2,32(a1)
    8000261e:	0285b983          	ld	s3,40(a1)
    80002622:	0305ba03          	ld	s4,48(a1)
    80002626:	0385ba83          	ld	s5,56(a1)
    8000262a:	0405bb03          	ld	s6,64(a1)
    8000262e:	0485bb83          	ld	s7,72(a1)
    80002632:	0505bc03          	ld	s8,80(a1)
    80002636:	0585bc83          	ld	s9,88(a1)
    8000263a:	0605bd03          	ld	s10,96(a1)
    8000263e:	0685bd83          	ld	s11,104(a1)
    80002642:	8082                	ret

0000000080002644 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002644:	1141                	addi	sp,sp,-16
    80002646:	e406                	sd	ra,8(sp)
    80002648:	e022                	sd	s0,0(sp)
    8000264a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000264c:	00006597          	auipc	a1,0x6
    80002650:	d2458593          	addi	a1,a1,-732 # 80008370 <states.0+0x30>
    80002654:	00015517          	auipc	a0,0x15
    80002658:	a7c50513          	addi	a0,a0,-1412 # 800170d0 <tickslock>
    8000265c:	ffffe097          	auipc	ra,0xffffe
    80002660:	4e4080e7          	jalr	1252(ra) # 80000b40 <initlock>
}
    80002664:	60a2                	ld	ra,8(sp)
    80002666:	6402                	ld	s0,0(sp)
    80002668:	0141                	addi	sp,sp,16
    8000266a:	8082                	ret

000000008000266c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000266c:	1141                	addi	sp,sp,-16
    8000266e:	e422                	sd	s0,8(sp)
    80002670:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002672:	00003797          	auipc	a5,0x3
    80002676:	54e78793          	addi	a5,a5,1358 # 80005bc0 <kernelvec>
    8000267a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000267e:	6422                	ld	s0,8(sp)
    80002680:	0141                	addi	sp,sp,16
    80002682:	8082                	ret

0000000080002684 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002684:	1141                	addi	sp,sp,-16
    80002686:	e406                	sd	ra,8(sp)
    80002688:	e022                	sd	s0,0(sp)
    8000268a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000268c:	fffff097          	auipc	ra,0xfffff
    80002690:	38a080e7          	jalr	906(ra) # 80001a16 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002694:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002698:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000269a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000269e:	00005697          	auipc	a3,0x5
    800026a2:	96268693          	addi	a3,a3,-1694 # 80007000 <_trampoline>
    800026a6:	00005717          	auipc	a4,0x5
    800026aa:	95a70713          	addi	a4,a4,-1702 # 80007000 <_trampoline>
    800026ae:	8f15                	sub	a4,a4,a3
    800026b0:	040007b7          	lui	a5,0x4000
    800026b4:	17fd                	addi	a5,a5,-1
    800026b6:	07b2                	slli	a5,a5,0xc
    800026b8:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026ba:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026be:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026c0:	18002673          	csrr	a2,satp
    800026c4:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026c6:	6d30                	ld	a2,88(a0)
    800026c8:	6138                	ld	a4,64(a0)
    800026ca:	6585                	lui	a1,0x1
    800026cc:	972e                	add	a4,a4,a1
    800026ce:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026d0:	6d38                	ld	a4,88(a0)
    800026d2:	00000617          	auipc	a2,0x0
    800026d6:	13860613          	addi	a2,a2,312 # 8000280a <usertrap>
    800026da:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026dc:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026de:	8612                	mv	a2,tp
    800026e0:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026e2:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026e6:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026ea:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ee:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026f2:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026f4:	6f18                	ld	a4,24(a4)
    800026f6:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026fa:	692c                	ld	a1,80(a0)
    800026fc:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800026fe:	00005717          	auipc	a4,0x5
    80002702:	99270713          	addi	a4,a4,-1646 # 80007090 <userret>
    80002706:	8f15                	sub	a4,a4,a3
    80002708:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000270a:	577d                	li	a4,-1
    8000270c:	177e                	slli	a4,a4,0x3f
    8000270e:	8dd9                	or	a1,a1,a4
    80002710:	02000537          	lui	a0,0x2000
    80002714:	157d                	addi	a0,a0,-1
    80002716:	0536                	slli	a0,a0,0xd
    80002718:	9782                	jalr	a5
}
    8000271a:	60a2                	ld	ra,8(sp)
    8000271c:	6402                	ld	s0,0(sp)
    8000271e:	0141                	addi	sp,sp,16
    80002720:	8082                	ret

0000000080002722 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002722:	1101                	addi	sp,sp,-32
    80002724:	ec06                	sd	ra,24(sp)
    80002726:	e822                	sd	s0,16(sp)
    80002728:	e426                	sd	s1,8(sp)
    8000272a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000272c:	00015497          	auipc	s1,0x15
    80002730:	9a448493          	addi	s1,s1,-1628 # 800170d0 <tickslock>
    80002734:	8526                	mv	a0,s1
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	49a080e7          	jalr	1178(ra) # 80000bd0 <acquire>
  ticks++;
    8000273e:	00007517          	auipc	a0,0x7
    80002742:	8f250513          	addi	a0,a0,-1806 # 80009030 <ticks>
    80002746:	411c                	lw	a5,0(a0)
    80002748:	2785                	addiw	a5,a5,1
    8000274a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000274c:	00000097          	auipc	ra,0x0
    80002750:	b1a080e7          	jalr	-1254(ra) # 80002266 <wakeup>
  release(&tickslock);
    80002754:	8526                	mv	a0,s1
    80002756:	ffffe097          	auipc	ra,0xffffe
    8000275a:	52e080e7          	jalr	1326(ra) # 80000c84 <release>
}
    8000275e:	60e2                	ld	ra,24(sp)
    80002760:	6442                	ld	s0,16(sp)
    80002762:	64a2                	ld	s1,8(sp)
    80002764:	6105                	addi	sp,sp,32
    80002766:	8082                	ret

0000000080002768 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002768:	1101                	addi	sp,sp,-32
    8000276a:	ec06                	sd	ra,24(sp)
    8000276c:	e822                	sd	s0,16(sp)
    8000276e:	e426                	sd	s1,8(sp)
    80002770:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002772:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002776:	00074d63          	bltz	a4,80002790 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000277a:	57fd                	li	a5,-1
    8000277c:	17fe                	slli	a5,a5,0x3f
    8000277e:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002780:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002782:	06f70363          	beq	a4,a5,800027e8 <devintr+0x80>
  }
}
    80002786:	60e2                	ld	ra,24(sp)
    80002788:	6442                	ld	s0,16(sp)
    8000278a:	64a2                	ld	s1,8(sp)
    8000278c:	6105                	addi	sp,sp,32
    8000278e:	8082                	ret
     (scause & 0xff) == 9){
    80002790:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80002794:	46a5                	li	a3,9
    80002796:	fed792e3          	bne	a5,a3,8000277a <devintr+0x12>
    int irq = plic_claim();
    8000279a:	00003097          	auipc	ra,0x3
    8000279e:	52e080e7          	jalr	1326(ra) # 80005cc8 <plic_claim>
    800027a2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027a4:	47a9                	li	a5,10
    800027a6:	02f50763          	beq	a0,a5,800027d4 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027aa:	4785                	li	a5,1
    800027ac:	02f50963          	beq	a0,a5,800027de <devintr+0x76>
    return 1;
    800027b0:	4505                	li	a0,1
    } else if(irq){
    800027b2:	d8f1                	beqz	s1,80002786 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800027b4:	85a6                	mv	a1,s1
    800027b6:	00006517          	auipc	a0,0x6
    800027ba:	bc250513          	addi	a0,a0,-1086 # 80008378 <states.0+0x38>
    800027be:	ffffe097          	auipc	ra,0xffffe
    800027c2:	dc6080e7          	jalr	-570(ra) # 80000584 <printf>
      plic_complete(irq);
    800027c6:	8526                	mv	a0,s1
    800027c8:	00003097          	auipc	ra,0x3
    800027cc:	524080e7          	jalr	1316(ra) # 80005cec <plic_complete>
    return 1;
    800027d0:	4505                	li	a0,1
    800027d2:	bf55                	j	80002786 <devintr+0x1e>
      uartintr();
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	1be080e7          	jalr	446(ra) # 80000992 <uartintr>
    800027dc:	b7ed                	j	800027c6 <devintr+0x5e>
      virtio_disk_intr();
    800027de:	00004097          	auipc	ra,0x4
    800027e2:	99a080e7          	jalr	-1638(ra) # 80006178 <virtio_disk_intr>
    800027e6:	b7c5                	j	800027c6 <devintr+0x5e>
    if(cpuid() == 0){
    800027e8:	fffff097          	auipc	ra,0xfffff
    800027ec:	202080e7          	jalr	514(ra) # 800019ea <cpuid>
    800027f0:	c901                	beqz	a0,80002800 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027f2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027f6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027f8:	14479073          	csrw	sip,a5
    return 2;
    800027fc:	4509                	li	a0,2
    800027fe:	b761                	j	80002786 <devintr+0x1e>
      clockintr();
    80002800:	00000097          	auipc	ra,0x0
    80002804:	f22080e7          	jalr	-222(ra) # 80002722 <clockintr>
    80002808:	b7ed                	j	800027f2 <devintr+0x8a>

000000008000280a <usertrap>:
{
    8000280a:	1101                	addi	sp,sp,-32
    8000280c:	ec06                	sd	ra,24(sp)
    8000280e:	e822                	sd	s0,16(sp)
    80002810:	e426                	sd	s1,8(sp)
    80002812:	e04a                	sd	s2,0(sp)
    80002814:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002816:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000281a:	1007f793          	andi	a5,a5,256
    8000281e:	e3ad                	bnez	a5,80002880 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002820:	00003797          	auipc	a5,0x3
    80002824:	3a078793          	addi	a5,a5,928 # 80005bc0 <kernelvec>
    80002828:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000282c:	fffff097          	auipc	ra,0xfffff
    80002830:	1ea080e7          	jalr	490(ra) # 80001a16 <myproc>
    80002834:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002836:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002838:	14102773          	csrr	a4,sepc
    8000283c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000283e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002842:	47a1                	li	a5,8
    80002844:	04f71c63          	bne	a4,a5,8000289c <usertrap+0x92>
    if(p->killed)
    80002848:	551c                	lw	a5,40(a0)
    8000284a:	e3b9                	bnez	a5,80002890 <usertrap+0x86>
    p->trapframe->epc += 4;
    8000284c:	6cb8                	ld	a4,88(s1)
    8000284e:	6f1c                	ld	a5,24(a4)
    80002850:	0791                	addi	a5,a5,4
    80002852:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002854:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002858:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000285c:	10079073          	csrw	sstatus,a5
    syscall();
    80002860:	00000097          	auipc	ra,0x0
    80002864:	2e0080e7          	jalr	736(ra) # 80002b40 <syscall>
  if(p->killed)
    80002868:	549c                	lw	a5,40(s1)
    8000286a:	ebc1                	bnez	a5,800028fa <usertrap+0xf0>
  usertrapret();
    8000286c:	00000097          	auipc	ra,0x0
    80002870:	e18080e7          	jalr	-488(ra) # 80002684 <usertrapret>
}
    80002874:	60e2                	ld	ra,24(sp)
    80002876:	6442                	ld	s0,16(sp)
    80002878:	64a2                	ld	s1,8(sp)
    8000287a:	6902                	ld	s2,0(sp)
    8000287c:	6105                	addi	sp,sp,32
    8000287e:	8082                	ret
    panic("usertrap: not from user mode");
    80002880:	00006517          	auipc	a0,0x6
    80002884:	b1850513          	addi	a0,a0,-1256 # 80008398 <states.0+0x58>
    80002888:	ffffe097          	auipc	ra,0xffffe
    8000288c:	cb2080e7          	jalr	-846(ra) # 8000053a <panic>
      exit(-1);
    80002890:	557d                	li	a0,-1
    80002892:	00000097          	auipc	ra,0x0
    80002896:	aa4080e7          	jalr	-1372(ra) # 80002336 <exit>
    8000289a:	bf4d                	j	8000284c <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    8000289c:	00000097          	auipc	ra,0x0
    800028a0:	ecc080e7          	jalr	-308(ra) # 80002768 <devintr>
    800028a4:	892a                	mv	s2,a0
    800028a6:	c501                	beqz	a0,800028ae <usertrap+0xa4>
  if(p->killed)
    800028a8:	549c                	lw	a5,40(s1)
    800028aa:	c3a1                	beqz	a5,800028ea <usertrap+0xe0>
    800028ac:	a815                	j	800028e0 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028ae:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028b2:	5890                	lw	a2,48(s1)
    800028b4:	00006517          	auipc	a0,0x6
    800028b8:	b0450513          	addi	a0,a0,-1276 # 800083b8 <states.0+0x78>
    800028bc:	ffffe097          	auipc	ra,0xffffe
    800028c0:	cc8080e7          	jalr	-824(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028c4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028c8:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028cc:	00006517          	auipc	a0,0x6
    800028d0:	b1c50513          	addi	a0,a0,-1252 # 800083e8 <states.0+0xa8>
    800028d4:	ffffe097          	auipc	ra,0xffffe
    800028d8:	cb0080e7          	jalr	-848(ra) # 80000584 <printf>
    p->killed = 1;
    800028dc:	4785                	li	a5,1
    800028de:	d49c                	sw	a5,40(s1)
    exit(-1);
    800028e0:	557d                	li	a0,-1
    800028e2:	00000097          	auipc	ra,0x0
    800028e6:	a54080e7          	jalr	-1452(ra) # 80002336 <exit>
  if(which_dev == 2)
    800028ea:	4789                	li	a5,2
    800028ec:	f8f910e3          	bne	s2,a5,8000286c <usertrap+0x62>
    yield();
    800028f0:	fffff097          	auipc	ra,0xfffff
    800028f4:	7ae080e7          	jalr	1966(ra) # 8000209e <yield>
    800028f8:	bf95                	j	8000286c <usertrap+0x62>
  int which_dev = 0;
    800028fa:	4901                	li	s2,0
    800028fc:	b7d5                	j	800028e0 <usertrap+0xd6>

00000000800028fe <kerneltrap>:
{
    800028fe:	7179                	addi	sp,sp,-48
    80002900:	f406                	sd	ra,40(sp)
    80002902:	f022                	sd	s0,32(sp)
    80002904:	ec26                	sd	s1,24(sp)
    80002906:	e84a                	sd	s2,16(sp)
    80002908:	e44e                	sd	s3,8(sp)
    8000290a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000290c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002910:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002914:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002918:	1004f793          	andi	a5,s1,256
    8000291c:	cb85                	beqz	a5,8000294c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002922:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002924:	ef85                	bnez	a5,8000295c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002926:	00000097          	auipc	ra,0x0
    8000292a:	e42080e7          	jalr	-446(ra) # 80002768 <devintr>
    8000292e:	cd1d                	beqz	a0,8000296c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002930:	4789                	li	a5,2
    80002932:	06f50a63          	beq	a0,a5,800029a6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002936:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000293a:	10049073          	csrw	sstatus,s1
}
    8000293e:	70a2                	ld	ra,40(sp)
    80002940:	7402                	ld	s0,32(sp)
    80002942:	64e2                	ld	s1,24(sp)
    80002944:	6942                	ld	s2,16(sp)
    80002946:	69a2                	ld	s3,8(sp)
    80002948:	6145                	addi	sp,sp,48
    8000294a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000294c:	00006517          	auipc	a0,0x6
    80002950:	abc50513          	addi	a0,a0,-1348 # 80008408 <states.0+0xc8>
    80002954:	ffffe097          	auipc	ra,0xffffe
    80002958:	be6080e7          	jalr	-1050(ra) # 8000053a <panic>
    panic("kerneltrap: interrupts enabled");
    8000295c:	00006517          	auipc	a0,0x6
    80002960:	ad450513          	addi	a0,a0,-1324 # 80008430 <states.0+0xf0>
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	bd6080e7          	jalr	-1066(ra) # 8000053a <panic>
    printf("scause %p\n", scause);
    8000296c:	85ce                	mv	a1,s3
    8000296e:	00006517          	auipc	a0,0x6
    80002972:	ae250513          	addi	a0,a0,-1310 # 80008450 <states.0+0x110>
    80002976:	ffffe097          	auipc	ra,0xffffe
    8000297a:	c0e080e7          	jalr	-1010(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000297e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002982:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002986:	00006517          	auipc	a0,0x6
    8000298a:	ada50513          	addi	a0,a0,-1318 # 80008460 <states.0+0x120>
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	bf6080e7          	jalr	-1034(ra) # 80000584 <printf>
    panic("kerneltrap");
    80002996:	00006517          	auipc	a0,0x6
    8000299a:	ae250513          	addi	a0,a0,-1310 # 80008478 <states.0+0x138>
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	b9c080e7          	jalr	-1124(ra) # 8000053a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029a6:	fffff097          	auipc	ra,0xfffff
    800029aa:	070080e7          	jalr	112(ra) # 80001a16 <myproc>
    800029ae:	d541                	beqz	a0,80002936 <kerneltrap+0x38>
    800029b0:	fffff097          	auipc	ra,0xfffff
    800029b4:	066080e7          	jalr	102(ra) # 80001a16 <myproc>
    800029b8:	4d18                	lw	a4,24(a0)
    800029ba:	4791                	li	a5,4
    800029bc:	f6f71de3          	bne	a4,a5,80002936 <kerneltrap+0x38>
    yield();
    800029c0:	fffff097          	auipc	ra,0xfffff
    800029c4:	6de080e7          	jalr	1758(ra) # 8000209e <yield>
    800029c8:	b7bd                	j	80002936 <kerneltrap+0x38>

00000000800029ca <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029ca:	1101                	addi	sp,sp,-32
    800029cc:	ec06                	sd	ra,24(sp)
    800029ce:	e822                	sd	s0,16(sp)
    800029d0:	e426                	sd	s1,8(sp)
    800029d2:	1000                	addi	s0,sp,32
    800029d4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029d6:	fffff097          	auipc	ra,0xfffff
    800029da:	040080e7          	jalr	64(ra) # 80001a16 <myproc>
  switch (n) {
    800029de:	4795                	li	a5,5
    800029e0:	0497e163          	bltu	a5,s1,80002a22 <argraw+0x58>
    800029e4:	048a                	slli	s1,s1,0x2
    800029e6:	00006717          	auipc	a4,0x6
    800029ea:	aca70713          	addi	a4,a4,-1334 # 800084b0 <states.0+0x170>
    800029ee:	94ba                	add	s1,s1,a4
    800029f0:	409c                	lw	a5,0(s1)
    800029f2:	97ba                	add	a5,a5,a4
    800029f4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029f6:	6d3c                	ld	a5,88(a0)
    800029f8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029fa:	60e2                	ld	ra,24(sp)
    800029fc:	6442                	ld	s0,16(sp)
    800029fe:	64a2                	ld	s1,8(sp)
    80002a00:	6105                	addi	sp,sp,32
    80002a02:	8082                	ret
    return p->trapframe->a1;
    80002a04:	6d3c                	ld	a5,88(a0)
    80002a06:	7fa8                	ld	a0,120(a5)
    80002a08:	bfcd                	j	800029fa <argraw+0x30>
    return p->trapframe->a2;
    80002a0a:	6d3c                	ld	a5,88(a0)
    80002a0c:	63c8                	ld	a0,128(a5)
    80002a0e:	b7f5                	j	800029fa <argraw+0x30>
    return p->trapframe->a3;
    80002a10:	6d3c                	ld	a5,88(a0)
    80002a12:	67c8                	ld	a0,136(a5)
    80002a14:	b7dd                	j	800029fa <argraw+0x30>
    return p->trapframe->a4;
    80002a16:	6d3c                	ld	a5,88(a0)
    80002a18:	6bc8                	ld	a0,144(a5)
    80002a1a:	b7c5                	j	800029fa <argraw+0x30>
    return p->trapframe->a5;
    80002a1c:	6d3c                	ld	a5,88(a0)
    80002a1e:	6fc8                	ld	a0,152(a5)
    80002a20:	bfe9                	j	800029fa <argraw+0x30>
  panic("argraw");
    80002a22:	00006517          	auipc	a0,0x6
    80002a26:	a6650513          	addi	a0,a0,-1434 # 80008488 <states.0+0x148>
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	b10080e7          	jalr	-1264(ra) # 8000053a <panic>

0000000080002a32 <fetchaddr>:
{
    80002a32:	1101                	addi	sp,sp,-32
    80002a34:	ec06                	sd	ra,24(sp)
    80002a36:	e822                	sd	s0,16(sp)
    80002a38:	e426                	sd	s1,8(sp)
    80002a3a:	e04a                	sd	s2,0(sp)
    80002a3c:	1000                	addi	s0,sp,32
    80002a3e:	84aa                	mv	s1,a0
    80002a40:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a42:	fffff097          	auipc	ra,0xfffff
    80002a46:	fd4080e7          	jalr	-44(ra) # 80001a16 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a4a:	653c                	ld	a5,72(a0)
    80002a4c:	02f4f863          	bgeu	s1,a5,80002a7c <fetchaddr+0x4a>
    80002a50:	00848713          	addi	a4,s1,8
    80002a54:	02e7e663          	bltu	a5,a4,80002a80 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a58:	46a1                	li	a3,8
    80002a5a:	8626                	mv	a2,s1
    80002a5c:	85ca                	mv	a1,s2
    80002a5e:	6928                	ld	a0,80(a0)
    80002a60:	fffff097          	auipc	ra,0xfffff
    80002a64:	c86080e7          	jalr	-890(ra) # 800016e6 <copyin>
    80002a68:	00a03533          	snez	a0,a0
    80002a6c:	40a00533          	neg	a0,a0
}
    80002a70:	60e2                	ld	ra,24(sp)
    80002a72:	6442                	ld	s0,16(sp)
    80002a74:	64a2                	ld	s1,8(sp)
    80002a76:	6902                	ld	s2,0(sp)
    80002a78:	6105                	addi	sp,sp,32
    80002a7a:	8082                	ret
    return -1;
    80002a7c:	557d                	li	a0,-1
    80002a7e:	bfcd                	j	80002a70 <fetchaddr+0x3e>
    80002a80:	557d                	li	a0,-1
    80002a82:	b7fd                	j	80002a70 <fetchaddr+0x3e>

0000000080002a84 <fetchstr>:
{
    80002a84:	7179                	addi	sp,sp,-48
    80002a86:	f406                	sd	ra,40(sp)
    80002a88:	f022                	sd	s0,32(sp)
    80002a8a:	ec26                	sd	s1,24(sp)
    80002a8c:	e84a                	sd	s2,16(sp)
    80002a8e:	e44e                	sd	s3,8(sp)
    80002a90:	1800                	addi	s0,sp,48
    80002a92:	892a                	mv	s2,a0
    80002a94:	84ae                	mv	s1,a1
    80002a96:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a98:	fffff097          	auipc	ra,0xfffff
    80002a9c:	f7e080e7          	jalr	-130(ra) # 80001a16 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002aa0:	86ce                	mv	a3,s3
    80002aa2:	864a                	mv	a2,s2
    80002aa4:	85a6                	mv	a1,s1
    80002aa6:	6928                	ld	a0,80(a0)
    80002aa8:	fffff097          	auipc	ra,0xfffff
    80002aac:	ccc080e7          	jalr	-820(ra) # 80001774 <copyinstr>
  if(err < 0)
    80002ab0:	00054763          	bltz	a0,80002abe <fetchstr+0x3a>
  return strlen(buf);
    80002ab4:	8526                	mv	a0,s1
    80002ab6:	ffffe097          	auipc	ra,0xffffe
    80002aba:	392080e7          	jalr	914(ra) # 80000e48 <strlen>
}
    80002abe:	70a2                	ld	ra,40(sp)
    80002ac0:	7402                	ld	s0,32(sp)
    80002ac2:	64e2                	ld	s1,24(sp)
    80002ac4:	6942                	ld	s2,16(sp)
    80002ac6:	69a2                	ld	s3,8(sp)
    80002ac8:	6145                	addi	sp,sp,48
    80002aca:	8082                	ret

0000000080002acc <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002acc:	1101                	addi	sp,sp,-32
    80002ace:	ec06                	sd	ra,24(sp)
    80002ad0:	e822                	sd	s0,16(sp)
    80002ad2:	e426                	sd	s1,8(sp)
    80002ad4:	1000                	addi	s0,sp,32
    80002ad6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ad8:	00000097          	auipc	ra,0x0
    80002adc:	ef2080e7          	jalr	-270(ra) # 800029ca <argraw>
    80002ae0:	c088                	sw	a0,0(s1)
  return 0;
}
    80002ae2:	4501                	li	a0,0
    80002ae4:	60e2                	ld	ra,24(sp)
    80002ae6:	6442                	ld	s0,16(sp)
    80002ae8:	64a2                	ld	s1,8(sp)
    80002aea:	6105                	addi	sp,sp,32
    80002aec:	8082                	ret

0000000080002aee <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002aee:	1101                	addi	sp,sp,-32
    80002af0:	ec06                	sd	ra,24(sp)
    80002af2:	e822                	sd	s0,16(sp)
    80002af4:	e426                	sd	s1,8(sp)
    80002af6:	1000                	addi	s0,sp,32
    80002af8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002afa:	00000097          	auipc	ra,0x0
    80002afe:	ed0080e7          	jalr	-304(ra) # 800029ca <argraw>
    80002b02:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b04:	4501                	li	a0,0
    80002b06:	60e2                	ld	ra,24(sp)
    80002b08:	6442                	ld	s0,16(sp)
    80002b0a:	64a2                	ld	s1,8(sp)
    80002b0c:	6105                	addi	sp,sp,32
    80002b0e:	8082                	ret

0000000080002b10 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b10:	1101                	addi	sp,sp,-32
    80002b12:	ec06                	sd	ra,24(sp)
    80002b14:	e822                	sd	s0,16(sp)
    80002b16:	e426                	sd	s1,8(sp)
    80002b18:	e04a                	sd	s2,0(sp)
    80002b1a:	1000                	addi	s0,sp,32
    80002b1c:	84ae                	mv	s1,a1
    80002b1e:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b20:	00000097          	auipc	ra,0x0
    80002b24:	eaa080e7          	jalr	-342(ra) # 800029ca <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b28:	864a                	mv	a2,s2
    80002b2a:	85a6                	mv	a1,s1
    80002b2c:	00000097          	auipc	ra,0x0
    80002b30:	f58080e7          	jalr	-168(ra) # 80002a84 <fetchstr>
}
    80002b34:	60e2                	ld	ra,24(sp)
    80002b36:	6442                	ld	s0,16(sp)
    80002b38:	64a2                	ld	s1,8(sp)
    80002b3a:	6902                	ld	s2,0(sp)
    80002b3c:	6105                	addi	sp,sp,32
    80002b3e:	8082                	ret

0000000080002b40 <syscall>:
[SYS_tget]   sys_tget,
};

void
syscall(void)
{
    80002b40:	1101                	addi	sp,sp,-32
    80002b42:	ec06                	sd	ra,24(sp)
    80002b44:	e822                	sd	s0,16(sp)
    80002b46:	e426                	sd	s1,8(sp)
    80002b48:	e04a                	sd	s2,0(sp)
    80002b4a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	eca080e7          	jalr	-310(ra) # 80001a16 <myproc>
    80002b54:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b56:	05853903          	ld	s2,88(a0)
    80002b5a:	0a893783          	ld	a5,168(s2)
    80002b5e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b62:	37fd                	addiw	a5,a5,-1
    80002b64:	4761                	li	a4,24
    80002b66:	00f76f63          	bltu	a4,a5,80002b84 <syscall+0x44>
    80002b6a:	00369713          	slli	a4,a3,0x3
    80002b6e:	00006797          	auipc	a5,0x6
    80002b72:	95a78793          	addi	a5,a5,-1702 # 800084c8 <syscalls>
    80002b76:	97ba                	add	a5,a5,a4
    80002b78:	639c                	ld	a5,0(a5)
    80002b7a:	c789                	beqz	a5,80002b84 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002b7c:	9782                	jalr	a5
    80002b7e:	06a93823          	sd	a0,112(s2)
    80002b82:	a839                	j	80002ba0 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b84:	15848613          	addi	a2,s1,344
    80002b88:	588c                	lw	a1,48(s1)
    80002b8a:	00006517          	auipc	a0,0x6
    80002b8e:	90650513          	addi	a0,a0,-1786 # 80008490 <states.0+0x150>
    80002b92:	ffffe097          	auipc	ra,0xffffe
    80002b96:	9f2080e7          	jalr	-1550(ra) # 80000584 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b9a:	6cbc                	ld	a5,88(s1)
    80002b9c:	577d                	li	a4,-1
    80002b9e:	fbb8                	sd	a4,112(a5)
  }
}
    80002ba0:	60e2                	ld	ra,24(sp)
    80002ba2:	6442                	ld	s0,16(sp)
    80002ba4:	64a2                	ld	s1,8(sp)
    80002ba6:	6902                	ld	s2,0(sp)
    80002ba8:	6105                	addi	sp,sp,32
    80002baa:	8082                	ret

0000000080002bac <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bac:	1101                	addi	sp,sp,-32
    80002bae:	ec06                	sd	ra,24(sp)
    80002bb0:	e822                	sd	s0,16(sp)
    80002bb2:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002bb4:	fec40593          	addi	a1,s0,-20
    80002bb8:	4501                	li	a0,0
    80002bba:	00000097          	auipc	ra,0x0
    80002bbe:	f12080e7          	jalr	-238(ra) # 80002acc <argint>
    return -1;
    80002bc2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002bc4:	00054963          	bltz	a0,80002bd6 <sys_exit+0x2a>
  exit(n);
    80002bc8:	fec42503          	lw	a0,-20(s0)
    80002bcc:	fffff097          	auipc	ra,0xfffff
    80002bd0:	76a080e7          	jalr	1898(ra) # 80002336 <exit>
  return 0;  // not reached
    80002bd4:	4781                	li	a5,0
}
    80002bd6:	853e                	mv	a0,a5
    80002bd8:	60e2                	ld	ra,24(sp)
    80002bda:	6442                	ld	s0,16(sp)
    80002bdc:	6105                	addi	sp,sp,32
    80002bde:	8082                	ret

0000000080002be0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002be0:	1141                	addi	sp,sp,-16
    80002be2:	e406                	sd	ra,8(sp)
    80002be4:	e022                	sd	s0,0(sp)
    80002be6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002be8:	fffff097          	auipc	ra,0xfffff
    80002bec:	e2e080e7          	jalr	-466(ra) # 80001a16 <myproc>
}
    80002bf0:	5908                	lw	a0,48(a0)
    80002bf2:	60a2                	ld	ra,8(sp)
    80002bf4:	6402                	ld	s0,0(sp)
    80002bf6:	0141                	addi	sp,sp,16
    80002bf8:	8082                	ret

0000000080002bfa <sys_fork>:

uint64
sys_fork(void)
{
    80002bfa:	1141                	addi	sp,sp,-16
    80002bfc:	e406                	sd	ra,8(sp)
    80002bfe:	e022                	sd	s0,0(sp)
    80002c00:	0800                	addi	s0,sp,16
  return fork();
    80002c02:	fffff097          	auipc	ra,0xfffff
    80002c06:	1e6080e7          	jalr	486(ra) # 80001de8 <fork>
}
    80002c0a:	60a2                	ld	ra,8(sp)
    80002c0c:	6402                	ld	s0,0(sp)
    80002c0e:	0141                	addi	sp,sp,16
    80002c10:	8082                	ret

0000000080002c12 <sys_wait>:

uint64
sys_wait(void)
{
    80002c12:	1101                	addi	sp,sp,-32
    80002c14:	ec06                	sd	ra,24(sp)
    80002c16:	e822                	sd	s0,16(sp)
    80002c18:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c1a:	fe840593          	addi	a1,s0,-24
    80002c1e:	4501                	li	a0,0
    80002c20:	00000097          	auipc	ra,0x0
    80002c24:	ece080e7          	jalr	-306(ra) # 80002aee <argaddr>
    80002c28:	87aa                	mv	a5,a0
    return -1;
    80002c2a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002c2c:	0007c863          	bltz	a5,80002c3c <sys_wait+0x2a>
  return wait(p);
    80002c30:	fe843503          	ld	a0,-24(s0)
    80002c34:	fffff097          	auipc	ra,0xfffff
    80002c38:	50a080e7          	jalr	1290(ra) # 8000213e <wait>
}
    80002c3c:	60e2                	ld	ra,24(sp)
    80002c3e:	6442                	ld	s0,16(sp)
    80002c40:	6105                	addi	sp,sp,32
    80002c42:	8082                	ret

0000000080002c44 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c44:	7179                	addi	sp,sp,-48
    80002c46:	f406                	sd	ra,40(sp)
    80002c48:	f022                	sd	s0,32(sp)
    80002c4a:	ec26                	sd	s1,24(sp)
    80002c4c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002c4e:	fdc40593          	addi	a1,s0,-36
    80002c52:	4501                	li	a0,0
    80002c54:	00000097          	auipc	ra,0x0
    80002c58:	e78080e7          	jalr	-392(ra) # 80002acc <argint>
    80002c5c:	87aa                	mv	a5,a0
    return -1;
    80002c5e:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002c60:	0207c063          	bltz	a5,80002c80 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002c64:	fffff097          	auipc	ra,0xfffff
    80002c68:	db2080e7          	jalr	-590(ra) # 80001a16 <myproc>
    80002c6c:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002c6e:	fdc42503          	lw	a0,-36(s0)
    80002c72:	fffff097          	auipc	ra,0xfffff
    80002c76:	0fe080e7          	jalr	254(ra) # 80001d70 <growproc>
    80002c7a:	00054863          	bltz	a0,80002c8a <sys_sbrk+0x46>
    return -1;
  return addr;
    80002c7e:	8526                	mv	a0,s1
}
    80002c80:	70a2                	ld	ra,40(sp)
    80002c82:	7402                	ld	s0,32(sp)
    80002c84:	64e2                	ld	s1,24(sp)
    80002c86:	6145                	addi	sp,sp,48
    80002c88:	8082                	ret
    return -1;
    80002c8a:	557d                	li	a0,-1
    80002c8c:	bfd5                	j	80002c80 <sys_sbrk+0x3c>

0000000080002c8e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c8e:	7139                	addi	sp,sp,-64
    80002c90:	fc06                	sd	ra,56(sp)
    80002c92:	f822                	sd	s0,48(sp)
    80002c94:	f426                	sd	s1,40(sp)
    80002c96:	f04a                	sd	s2,32(sp)
    80002c98:	ec4e                	sd	s3,24(sp)
    80002c9a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002c9c:	fcc40593          	addi	a1,s0,-52
    80002ca0:	4501                	li	a0,0
    80002ca2:	00000097          	auipc	ra,0x0
    80002ca6:	e2a080e7          	jalr	-470(ra) # 80002acc <argint>
    return -1;
    80002caa:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002cac:	06054563          	bltz	a0,80002d16 <sys_sleep+0x88>
  acquire(&tickslock);
    80002cb0:	00014517          	auipc	a0,0x14
    80002cb4:	42050513          	addi	a0,a0,1056 # 800170d0 <tickslock>
    80002cb8:	ffffe097          	auipc	ra,0xffffe
    80002cbc:	f18080e7          	jalr	-232(ra) # 80000bd0 <acquire>
  ticks0 = ticks;
    80002cc0:	00006917          	auipc	s2,0x6
    80002cc4:	37092903          	lw	s2,880(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002cc8:	fcc42783          	lw	a5,-52(s0)
    80002ccc:	cf85                	beqz	a5,80002d04 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cce:	00014997          	auipc	s3,0x14
    80002cd2:	40298993          	addi	s3,s3,1026 # 800170d0 <tickslock>
    80002cd6:	00006497          	auipc	s1,0x6
    80002cda:	35a48493          	addi	s1,s1,858 # 80009030 <ticks>
    if(myproc()->killed){
    80002cde:	fffff097          	auipc	ra,0xfffff
    80002ce2:	d38080e7          	jalr	-712(ra) # 80001a16 <myproc>
    80002ce6:	551c                	lw	a5,40(a0)
    80002ce8:	ef9d                	bnez	a5,80002d26 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002cea:	85ce                	mv	a1,s3
    80002cec:	8526                	mv	a0,s1
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	3ec080e7          	jalr	1004(ra) # 800020da <sleep>
  while(ticks - ticks0 < n){
    80002cf6:	409c                	lw	a5,0(s1)
    80002cf8:	412787bb          	subw	a5,a5,s2
    80002cfc:	fcc42703          	lw	a4,-52(s0)
    80002d00:	fce7efe3          	bltu	a5,a4,80002cde <sys_sleep+0x50>
  }
  release(&tickslock);
    80002d04:	00014517          	auipc	a0,0x14
    80002d08:	3cc50513          	addi	a0,a0,972 # 800170d0 <tickslock>
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	f78080e7          	jalr	-136(ra) # 80000c84 <release>
  return 0;
    80002d14:	4781                	li	a5,0
}
    80002d16:	853e                	mv	a0,a5
    80002d18:	70e2                	ld	ra,56(sp)
    80002d1a:	7442                	ld	s0,48(sp)
    80002d1c:	74a2                	ld	s1,40(sp)
    80002d1e:	7902                	ld	s2,32(sp)
    80002d20:	69e2                	ld	s3,24(sp)
    80002d22:	6121                	addi	sp,sp,64
    80002d24:	8082                	ret
      release(&tickslock);
    80002d26:	00014517          	auipc	a0,0x14
    80002d2a:	3aa50513          	addi	a0,a0,938 # 800170d0 <tickslock>
    80002d2e:	ffffe097          	auipc	ra,0xffffe
    80002d32:	f56080e7          	jalr	-170(ra) # 80000c84 <release>
      return -1;
    80002d36:	57fd                	li	a5,-1
    80002d38:	bff9                	j	80002d16 <sys_sleep+0x88>

0000000080002d3a <sys_kill>:

uint64
sys_kill(void)
{
    80002d3a:	1101                	addi	sp,sp,-32
    80002d3c:	ec06                	sd	ra,24(sp)
    80002d3e:	e822                	sd	s0,16(sp)
    80002d40:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d42:	fec40593          	addi	a1,s0,-20
    80002d46:	4501                	li	a0,0
    80002d48:	00000097          	auipc	ra,0x0
    80002d4c:	d84080e7          	jalr	-636(ra) # 80002acc <argint>
    80002d50:	87aa                	mv	a5,a0
    return -1;
    80002d52:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002d54:	0007c863          	bltz	a5,80002d64 <sys_kill+0x2a>
  return kill(pid);
    80002d58:	fec42503          	lw	a0,-20(s0)
    80002d5c:	fffff097          	auipc	ra,0xfffff
    80002d60:	6b0080e7          	jalr	1712(ra) # 8000240c <kill>
}
    80002d64:	60e2                	ld	ra,24(sp)
    80002d66:	6442                	ld	s0,16(sp)
    80002d68:	6105                	addi	sp,sp,32
    80002d6a:	8082                	ret

0000000080002d6c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d6c:	1101                	addi	sp,sp,-32
    80002d6e:	ec06                	sd	ra,24(sp)
    80002d70:	e822                	sd	s0,16(sp)
    80002d72:	e426                	sd	s1,8(sp)
    80002d74:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d76:	00014517          	auipc	a0,0x14
    80002d7a:	35a50513          	addi	a0,a0,858 # 800170d0 <tickslock>
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	e52080e7          	jalr	-430(ra) # 80000bd0 <acquire>
  xticks = ticks;
    80002d86:	00006497          	auipc	s1,0x6
    80002d8a:	2aa4a483          	lw	s1,682(s1) # 80009030 <ticks>
  release(&tickslock);
    80002d8e:	00014517          	auipc	a0,0x14
    80002d92:	34250513          	addi	a0,a0,834 # 800170d0 <tickslock>
    80002d96:	ffffe097          	auipc	ra,0xffffe
    80002d9a:	eee080e7          	jalr	-274(ra) # 80000c84 <release>
  return xticks;
}
    80002d9e:	02049513          	slli	a0,s1,0x20
    80002da2:	9101                	srli	a0,a0,0x20
    80002da4:	60e2                	ld	ra,24(sp)
    80002da6:	6442                	ld	s0,16(sp)
    80002da8:	64a2                	ld	s1,8(sp)
    80002daa:	6105                	addi	sp,sp,32
    80002dac:	8082                	ret

0000000080002dae <sys_btput>:


uint64
sys_btput(void)
{
    80002dae:	1141                	addi	sp,sp,-16
    80002db0:	e406                	sd	ra,8(sp)
    80002db2:	e022                	sd	s0,0(sp)
    80002db4:	0800                	addi	s0,sp,16
    printf(" btput in syspoc.c \n");
    80002db6:	00005517          	auipc	a0,0x5
    80002dba:	7e250513          	addi	a0,a0,2018 # 80008598 <syscalls+0xd0>
    80002dbe:	ffffd097          	auipc	ra,0xffffd
    80002dc2:	7c6080e7          	jalr	1990(ra) # 80000584 <printf>
    btput();
    80002dc6:	fffff097          	auipc	ra,0xfffff
    80002dca:	a5e080e7          	jalr	-1442(ra) # 80001824 <btput>
    return 0;
}
    80002dce:	4501                	li	a0,0
    80002dd0:	60a2                	ld	ra,8(sp)
    80002dd2:	6402                	ld	s0,0(sp)
    80002dd4:	0141                	addi	sp,sp,16
    80002dd6:	8082                	ret

0000000080002dd8 <sys_tput>:

uint64
sys_tput(void)
{
    80002dd8:	1141                	addi	sp,sp,-16
    80002dda:	e406                	sd	ra,8(sp)
    80002ddc:	e022                	sd	s0,0(sp)
    80002dde:	0800                	addi	s0,sp,16
    printf("tput in syspoc.c \n");
    80002de0:	00005517          	auipc	a0,0x5
    80002de4:	7d050513          	addi	a0,a0,2000 # 800085b0 <syscalls+0xe8>
    80002de8:	ffffd097          	auipc	ra,0xffffd
    80002dec:	79c080e7          	jalr	1948(ra) # 80000584 <printf>
    tput();
    80002df0:	fffff097          	auipc	ra,0xfffff
    80002df4:	a54080e7          	jalr	-1452(ra) # 80001844 <tput>
    return 0;
}
    80002df8:	4501                	li	a0,0
    80002dfa:	60a2                	ld	ra,8(sp)
    80002dfc:	6402                	ld	s0,0(sp)
    80002dfe:	0141                	addi	sp,sp,16
    80002e00:	8082                	ret

0000000080002e02 <sys_btget>:

uint64
sys_btget(void)
{
    80002e02:	1141                	addi	sp,sp,-16
    80002e04:	e406                	sd	ra,8(sp)
    80002e06:	e022                	sd	s0,0(sp)
    80002e08:	0800                	addi	s0,sp,16
    printf("btget in syspoc.c \n");
    80002e0a:	00005517          	auipc	a0,0x5
    80002e0e:	7be50513          	addi	a0,a0,1982 # 800085c8 <syscalls+0x100>
    80002e12:	ffffd097          	auipc	ra,0xffffd
    80002e16:	772080e7          	jalr	1906(ra) # 80000584 <printf>
    btget();
    80002e1a:	fffff097          	auipc	ra,0xfffff
    80002e1e:	a4a080e7          	jalr	-1462(ra) # 80001864 <btget>
    return 0;
}
    80002e22:	4501                	li	a0,0
    80002e24:	60a2                	ld	ra,8(sp)
    80002e26:	6402                	ld	s0,0(sp)
    80002e28:	0141                	addi	sp,sp,16
    80002e2a:	8082                	ret

0000000080002e2c <sys_tget>:

uint64
sys_tget(void)
{
    80002e2c:	1141                	addi	sp,sp,-16
    80002e2e:	e406                	sd	ra,8(sp)
    80002e30:	e022                	sd	s0,0(sp)
    80002e32:	0800                	addi	s0,sp,16
    printf("tget in syspoc.c \n");
    80002e34:	00005517          	auipc	a0,0x5
    80002e38:	7ac50513          	addi	a0,a0,1964 # 800085e0 <syscalls+0x118>
    80002e3c:	ffffd097          	auipc	ra,0xffffd
    80002e40:	748080e7          	jalr	1864(ra) # 80000584 <printf>
    tget();
    80002e44:	fffff097          	auipc	ra,0xfffff
    80002e48:	a40080e7          	jalr	-1472(ra) # 80001884 <tget>
    return 0;
    80002e4c:	4501                	li	a0,0
    80002e4e:	60a2                	ld	ra,8(sp)
    80002e50:	6402                	ld	s0,0(sp)
    80002e52:	0141                	addi	sp,sp,16
    80002e54:	8082                	ret

0000000080002e56 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e56:	7179                	addi	sp,sp,-48
    80002e58:	f406                	sd	ra,40(sp)
    80002e5a:	f022                	sd	s0,32(sp)
    80002e5c:	ec26                	sd	s1,24(sp)
    80002e5e:	e84a                	sd	s2,16(sp)
    80002e60:	e44e                	sd	s3,8(sp)
    80002e62:	e052                	sd	s4,0(sp)
    80002e64:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e66:	00005597          	auipc	a1,0x5
    80002e6a:	79258593          	addi	a1,a1,1938 # 800085f8 <syscalls+0x130>
    80002e6e:	00014517          	auipc	a0,0x14
    80002e72:	27a50513          	addi	a0,a0,634 # 800170e8 <bcache>
    80002e76:	ffffe097          	auipc	ra,0xffffe
    80002e7a:	cca080e7          	jalr	-822(ra) # 80000b40 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e7e:	0001c797          	auipc	a5,0x1c
    80002e82:	26a78793          	addi	a5,a5,618 # 8001f0e8 <bcache+0x8000>
    80002e86:	0001c717          	auipc	a4,0x1c
    80002e8a:	4ca70713          	addi	a4,a4,1226 # 8001f350 <bcache+0x8268>
    80002e8e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e92:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e96:	00014497          	auipc	s1,0x14
    80002e9a:	26a48493          	addi	s1,s1,618 # 80017100 <bcache+0x18>
    b->next = bcache.head.next;
    80002e9e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ea0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ea2:	00005a17          	auipc	s4,0x5
    80002ea6:	75ea0a13          	addi	s4,s4,1886 # 80008600 <syscalls+0x138>
    b->next = bcache.head.next;
    80002eaa:	2b893783          	ld	a5,696(s2)
    80002eae:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002eb0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002eb4:	85d2                	mv	a1,s4
    80002eb6:	01048513          	addi	a0,s1,16
    80002eba:	00001097          	auipc	ra,0x1
    80002ebe:	4c2080e7          	jalr	1218(ra) # 8000437c <initsleeplock>
    bcache.head.next->prev = b;
    80002ec2:	2b893783          	ld	a5,696(s2)
    80002ec6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002ec8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ecc:	45848493          	addi	s1,s1,1112
    80002ed0:	fd349de3          	bne	s1,s3,80002eaa <binit+0x54>
  }
}
    80002ed4:	70a2                	ld	ra,40(sp)
    80002ed6:	7402                	ld	s0,32(sp)
    80002ed8:	64e2                	ld	s1,24(sp)
    80002eda:	6942                	ld	s2,16(sp)
    80002edc:	69a2                	ld	s3,8(sp)
    80002ede:	6a02                	ld	s4,0(sp)
    80002ee0:	6145                	addi	sp,sp,48
    80002ee2:	8082                	ret

0000000080002ee4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ee4:	7179                	addi	sp,sp,-48
    80002ee6:	f406                	sd	ra,40(sp)
    80002ee8:	f022                	sd	s0,32(sp)
    80002eea:	ec26                	sd	s1,24(sp)
    80002eec:	e84a                	sd	s2,16(sp)
    80002eee:	e44e                	sd	s3,8(sp)
    80002ef0:	1800                	addi	s0,sp,48
    80002ef2:	892a                	mv	s2,a0
    80002ef4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ef6:	00014517          	auipc	a0,0x14
    80002efa:	1f250513          	addi	a0,a0,498 # 800170e8 <bcache>
    80002efe:	ffffe097          	auipc	ra,0xffffe
    80002f02:	cd2080e7          	jalr	-814(ra) # 80000bd0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f06:	0001c497          	auipc	s1,0x1c
    80002f0a:	49a4b483          	ld	s1,1178(s1) # 8001f3a0 <bcache+0x82b8>
    80002f0e:	0001c797          	auipc	a5,0x1c
    80002f12:	44278793          	addi	a5,a5,1090 # 8001f350 <bcache+0x8268>
    80002f16:	02f48f63          	beq	s1,a5,80002f54 <bread+0x70>
    80002f1a:	873e                	mv	a4,a5
    80002f1c:	a021                	j	80002f24 <bread+0x40>
    80002f1e:	68a4                	ld	s1,80(s1)
    80002f20:	02e48a63          	beq	s1,a4,80002f54 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f24:	449c                	lw	a5,8(s1)
    80002f26:	ff279ce3          	bne	a5,s2,80002f1e <bread+0x3a>
    80002f2a:	44dc                	lw	a5,12(s1)
    80002f2c:	ff3799e3          	bne	a5,s3,80002f1e <bread+0x3a>
      b->refcnt++;
    80002f30:	40bc                	lw	a5,64(s1)
    80002f32:	2785                	addiw	a5,a5,1
    80002f34:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f36:	00014517          	auipc	a0,0x14
    80002f3a:	1b250513          	addi	a0,a0,434 # 800170e8 <bcache>
    80002f3e:	ffffe097          	auipc	ra,0xffffe
    80002f42:	d46080e7          	jalr	-698(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80002f46:	01048513          	addi	a0,s1,16
    80002f4a:	00001097          	auipc	ra,0x1
    80002f4e:	46c080e7          	jalr	1132(ra) # 800043b6 <acquiresleep>
      return b;
    80002f52:	a8b9                	j	80002fb0 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f54:	0001c497          	auipc	s1,0x1c
    80002f58:	4444b483          	ld	s1,1092(s1) # 8001f398 <bcache+0x82b0>
    80002f5c:	0001c797          	auipc	a5,0x1c
    80002f60:	3f478793          	addi	a5,a5,1012 # 8001f350 <bcache+0x8268>
    80002f64:	00f48863          	beq	s1,a5,80002f74 <bread+0x90>
    80002f68:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f6a:	40bc                	lw	a5,64(s1)
    80002f6c:	cf81                	beqz	a5,80002f84 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f6e:	64a4                	ld	s1,72(s1)
    80002f70:	fee49de3          	bne	s1,a4,80002f6a <bread+0x86>
  panic("bget: no buffers");
    80002f74:	00005517          	auipc	a0,0x5
    80002f78:	69450513          	addi	a0,a0,1684 # 80008608 <syscalls+0x140>
    80002f7c:	ffffd097          	auipc	ra,0xffffd
    80002f80:	5be080e7          	jalr	1470(ra) # 8000053a <panic>
      b->dev = dev;
    80002f84:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f88:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f8c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f90:	4785                	li	a5,1
    80002f92:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f94:	00014517          	auipc	a0,0x14
    80002f98:	15450513          	addi	a0,a0,340 # 800170e8 <bcache>
    80002f9c:	ffffe097          	auipc	ra,0xffffe
    80002fa0:	ce8080e7          	jalr	-792(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80002fa4:	01048513          	addi	a0,s1,16
    80002fa8:	00001097          	auipc	ra,0x1
    80002fac:	40e080e7          	jalr	1038(ra) # 800043b6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002fb0:	409c                	lw	a5,0(s1)
    80002fb2:	cb89                	beqz	a5,80002fc4 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002fb4:	8526                	mv	a0,s1
    80002fb6:	70a2                	ld	ra,40(sp)
    80002fb8:	7402                	ld	s0,32(sp)
    80002fba:	64e2                	ld	s1,24(sp)
    80002fbc:	6942                	ld	s2,16(sp)
    80002fbe:	69a2                	ld	s3,8(sp)
    80002fc0:	6145                	addi	sp,sp,48
    80002fc2:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fc4:	4581                	li	a1,0
    80002fc6:	8526                	mv	a0,s1
    80002fc8:	00003097          	auipc	ra,0x3
    80002fcc:	f2a080e7          	jalr	-214(ra) # 80005ef2 <virtio_disk_rw>
    b->valid = 1;
    80002fd0:	4785                	li	a5,1
    80002fd2:	c09c                	sw	a5,0(s1)
  return b;
    80002fd4:	b7c5                	j	80002fb4 <bread+0xd0>

0000000080002fd6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fd6:	1101                	addi	sp,sp,-32
    80002fd8:	ec06                	sd	ra,24(sp)
    80002fda:	e822                	sd	s0,16(sp)
    80002fdc:	e426                	sd	s1,8(sp)
    80002fde:	1000                	addi	s0,sp,32
    80002fe0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fe2:	0541                	addi	a0,a0,16
    80002fe4:	00001097          	auipc	ra,0x1
    80002fe8:	46c080e7          	jalr	1132(ra) # 80004450 <holdingsleep>
    80002fec:	cd01                	beqz	a0,80003004 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fee:	4585                	li	a1,1
    80002ff0:	8526                	mv	a0,s1
    80002ff2:	00003097          	auipc	ra,0x3
    80002ff6:	f00080e7          	jalr	-256(ra) # 80005ef2 <virtio_disk_rw>
}
    80002ffa:	60e2                	ld	ra,24(sp)
    80002ffc:	6442                	ld	s0,16(sp)
    80002ffe:	64a2                	ld	s1,8(sp)
    80003000:	6105                	addi	sp,sp,32
    80003002:	8082                	ret
    panic("bwrite");
    80003004:	00005517          	auipc	a0,0x5
    80003008:	61c50513          	addi	a0,a0,1564 # 80008620 <syscalls+0x158>
    8000300c:	ffffd097          	auipc	ra,0xffffd
    80003010:	52e080e7          	jalr	1326(ra) # 8000053a <panic>

0000000080003014 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003014:	1101                	addi	sp,sp,-32
    80003016:	ec06                	sd	ra,24(sp)
    80003018:	e822                	sd	s0,16(sp)
    8000301a:	e426                	sd	s1,8(sp)
    8000301c:	e04a                	sd	s2,0(sp)
    8000301e:	1000                	addi	s0,sp,32
    80003020:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003022:	01050913          	addi	s2,a0,16
    80003026:	854a                	mv	a0,s2
    80003028:	00001097          	auipc	ra,0x1
    8000302c:	428080e7          	jalr	1064(ra) # 80004450 <holdingsleep>
    80003030:	c92d                	beqz	a0,800030a2 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003032:	854a                	mv	a0,s2
    80003034:	00001097          	auipc	ra,0x1
    80003038:	3d8080e7          	jalr	984(ra) # 8000440c <releasesleep>

  acquire(&bcache.lock);
    8000303c:	00014517          	auipc	a0,0x14
    80003040:	0ac50513          	addi	a0,a0,172 # 800170e8 <bcache>
    80003044:	ffffe097          	auipc	ra,0xffffe
    80003048:	b8c080e7          	jalr	-1140(ra) # 80000bd0 <acquire>
  b->refcnt--;
    8000304c:	40bc                	lw	a5,64(s1)
    8000304e:	37fd                	addiw	a5,a5,-1
    80003050:	0007871b          	sext.w	a4,a5
    80003054:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003056:	eb05                	bnez	a4,80003086 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003058:	68bc                	ld	a5,80(s1)
    8000305a:	64b8                	ld	a4,72(s1)
    8000305c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000305e:	64bc                	ld	a5,72(s1)
    80003060:	68b8                	ld	a4,80(s1)
    80003062:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003064:	0001c797          	auipc	a5,0x1c
    80003068:	08478793          	addi	a5,a5,132 # 8001f0e8 <bcache+0x8000>
    8000306c:	2b87b703          	ld	a4,696(a5)
    80003070:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003072:	0001c717          	auipc	a4,0x1c
    80003076:	2de70713          	addi	a4,a4,734 # 8001f350 <bcache+0x8268>
    8000307a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000307c:	2b87b703          	ld	a4,696(a5)
    80003080:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003082:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003086:	00014517          	auipc	a0,0x14
    8000308a:	06250513          	addi	a0,a0,98 # 800170e8 <bcache>
    8000308e:	ffffe097          	auipc	ra,0xffffe
    80003092:	bf6080e7          	jalr	-1034(ra) # 80000c84 <release>
}
    80003096:	60e2                	ld	ra,24(sp)
    80003098:	6442                	ld	s0,16(sp)
    8000309a:	64a2                	ld	s1,8(sp)
    8000309c:	6902                	ld	s2,0(sp)
    8000309e:	6105                	addi	sp,sp,32
    800030a0:	8082                	ret
    panic("brelse");
    800030a2:	00005517          	auipc	a0,0x5
    800030a6:	58650513          	addi	a0,a0,1414 # 80008628 <syscalls+0x160>
    800030aa:	ffffd097          	auipc	ra,0xffffd
    800030ae:	490080e7          	jalr	1168(ra) # 8000053a <panic>

00000000800030b2 <bpin>:

void
bpin(struct buf *b) {
    800030b2:	1101                	addi	sp,sp,-32
    800030b4:	ec06                	sd	ra,24(sp)
    800030b6:	e822                	sd	s0,16(sp)
    800030b8:	e426                	sd	s1,8(sp)
    800030ba:	1000                	addi	s0,sp,32
    800030bc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030be:	00014517          	auipc	a0,0x14
    800030c2:	02a50513          	addi	a0,a0,42 # 800170e8 <bcache>
    800030c6:	ffffe097          	auipc	ra,0xffffe
    800030ca:	b0a080e7          	jalr	-1270(ra) # 80000bd0 <acquire>
  b->refcnt++;
    800030ce:	40bc                	lw	a5,64(s1)
    800030d0:	2785                	addiw	a5,a5,1
    800030d2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030d4:	00014517          	auipc	a0,0x14
    800030d8:	01450513          	addi	a0,a0,20 # 800170e8 <bcache>
    800030dc:	ffffe097          	auipc	ra,0xffffe
    800030e0:	ba8080e7          	jalr	-1112(ra) # 80000c84 <release>
}
    800030e4:	60e2                	ld	ra,24(sp)
    800030e6:	6442                	ld	s0,16(sp)
    800030e8:	64a2                	ld	s1,8(sp)
    800030ea:	6105                	addi	sp,sp,32
    800030ec:	8082                	ret

00000000800030ee <bunpin>:

void
bunpin(struct buf *b) {
    800030ee:	1101                	addi	sp,sp,-32
    800030f0:	ec06                	sd	ra,24(sp)
    800030f2:	e822                	sd	s0,16(sp)
    800030f4:	e426                	sd	s1,8(sp)
    800030f6:	1000                	addi	s0,sp,32
    800030f8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030fa:	00014517          	auipc	a0,0x14
    800030fe:	fee50513          	addi	a0,a0,-18 # 800170e8 <bcache>
    80003102:	ffffe097          	auipc	ra,0xffffe
    80003106:	ace080e7          	jalr	-1330(ra) # 80000bd0 <acquire>
  b->refcnt--;
    8000310a:	40bc                	lw	a5,64(s1)
    8000310c:	37fd                	addiw	a5,a5,-1
    8000310e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003110:	00014517          	auipc	a0,0x14
    80003114:	fd850513          	addi	a0,a0,-40 # 800170e8 <bcache>
    80003118:	ffffe097          	auipc	ra,0xffffe
    8000311c:	b6c080e7          	jalr	-1172(ra) # 80000c84 <release>
}
    80003120:	60e2                	ld	ra,24(sp)
    80003122:	6442                	ld	s0,16(sp)
    80003124:	64a2                	ld	s1,8(sp)
    80003126:	6105                	addi	sp,sp,32
    80003128:	8082                	ret

000000008000312a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000312a:	1101                	addi	sp,sp,-32
    8000312c:	ec06                	sd	ra,24(sp)
    8000312e:	e822                	sd	s0,16(sp)
    80003130:	e426                	sd	s1,8(sp)
    80003132:	e04a                	sd	s2,0(sp)
    80003134:	1000                	addi	s0,sp,32
    80003136:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003138:	00d5d59b          	srliw	a1,a1,0xd
    8000313c:	0001c797          	auipc	a5,0x1c
    80003140:	6887a783          	lw	a5,1672(a5) # 8001f7c4 <sb+0x1c>
    80003144:	9dbd                	addw	a1,a1,a5
    80003146:	00000097          	auipc	ra,0x0
    8000314a:	d9e080e7          	jalr	-610(ra) # 80002ee4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000314e:	0074f713          	andi	a4,s1,7
    80003152:	4785                	li	a5,1
    80003154:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003158:	14ce                	slli	s1,s1,0x33
    8000315a:	90d9                	srli	s1,s1,0x36
    8000315c:	00950733          	add	a4,a0,s1
    80003160:	05874703          	lbu	a4,88(a4)
    80003164:	00e7f6b3          	and	a3,a5,a4
    80003168:	c69d                	beqz	a3,80003196 <bfree+0x6c>
    8000316a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000316c:	94aa                	add	s1,s1,a0
    8000316e:	fff7c793          	not	a5,a5
    80003172:	8f7d                	and	a4,a4,a5
    80003174:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003178:	00001097          	auipc	ra,0x1
    8000317c:	120080e7          	jalr	288(ra) # 80004298 <log_write>
  brelse(bp);
    80003180:	854a                	mv	a0,s2
    80003182:	00000097          	auipc	ra,0x0
    80003186:	e92080e7          	jalr	-366(ra) # 80003014 <brelse>
}
    8000318a:	60e2                	ld	ra,24(sp)
    8000318c:	6442                	ld	s0,16(sp)
    8000318e:	64a2                	ld	s1,8(sp)
    80003190:	6902                	ld	s2,0(sp)
    80003192:	6105                	addi	sp,sp,32
    80003194:	8082                	ret
    panic("freeing free block");
    80003196:	00005517          	auipc	a0,0x5
    8000319a:	49a50513          	addi	a0,a0,1178 # 80008630 <syscalls+0x168>
    8000319e:	ffffd097          	auipc	ra,0xffffd
    800031a2:	39c080e7          	jalr	924(ra) # 8000053a <panic>

00000000800031a6 <balloc>:
{
    800031a6:	711d                	addi	sp,sp,-96
    800031a8:	ec86                	sd	ra,88(sp)
    800031aa:	e8a2                	sd	s0,80(sp)
    800031ac:	e4a6                	sd	s1,72(sp)
    800031ae:	e0ca                	sd	s2,64(sp)
    800031b0:	fc4e                	sd	s3,56(sp)
    800031b2:	f852                	sd	s4,48(sp)
    800031b4:	f456                	sd	s5,40(sp)
    800031b6:	f05a                	sd	s6,32(sp)
    800031b8:	ec5e                	sd	s7,24(sp)
    800031ba:	e862                	sd	s8,16(sp)
    800031bc:	e466                	sd	s9,8(sp)
    800031be:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031c0:	0001c797          	auipc	a5,0x1c
    800031c4:	5ec7a783          	lw	a5,1516(a5) # 8001f7ac <sb+0x4>
    800031c8:	cbc1                	beqz	a5,80003258 <balloc+0xb2>
    800031ca:	8baa                	mv	s7,a0
    800031cc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031ce:	0001cb17          	auipc	s6,0x1c
    800031d2:	5dab0b13          	addi	s6,s6,1498 # 8001f7a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031d6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031d8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031da:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031dc:	6c89                	lui	s9,0x2
    800031de:	a831                	j	800031fa <balloc+0x54>
    brelse(bp);
    800031e0:	854a                	mv	a0,s2
    800031e2:	00000097          	auipc	ra,0x0
    800031e6:	e32080e7          	jalr	-462(ra) # 80003014 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031ea:	015c87bb          	addw	a5,s9,s5
    800031ee:	00078a9b          	sext.w	s5,a5
    800031f2:	004b2703          	lw	a4,4(s6)
    800031f6:	06eaf163          	bgeu	s5,a4,80003258 <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    800031fa:	41fad79b          	sraiw	a5,s5,0x1f
    800031fe:	0137d79b          	srliw	a5,a5,0x13
    80003202:	015787bb          	addw	a5,a5,s5
    80003206:	40d7d79b          	sraiw	a5,a5,0xd
    8000320a:	01cb2583          	lw	a1,28(s6)
    8000320e:	9dbd                	addw	a1,a1,a5
    80003210:	855e                	mv	a0,s7
    80003212:	00000097          	auipc	ra,0x0
    80003216:	cd2080e7          	jalr	-814(ra) # 80002ee4 <bread>
    8000321a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000321c:	004b2503          	lw	a0,4(s6)
    80003220:	000a849b          	sext.w	s1,s5
    80003224:	8762                	mv	a4,s8
    80003226:	faa4fde3          	bgeu	s1,a0,800031e0 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000322a:	00777693          	andi	a3,a4,7
    8000322e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003232:	41f7579b          	sraiw	a5,a4,0x1f
    80003236:	01d7d79b          	srliw	a5,a5,0x1d
    8000323a:	9fb9                	addw	a5,a5,a4
    8000323c:	4037d79b          	sraiw	a5,a5,0x3
    80003240:	00f90633          	add	a2,s2,a5
    80003244:	05864603          	lbu	a2,88(a2)
    80003248:	00c6f5b3          	and	a1,a3,a2
    8000324c:	cd91                	beqz	a1,80003268 <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000324e:	2705                	addiw	a4,a4,1
    80003250:	2485                	addiw	s1,s1,1
    80003252:	fd471ae3          	bne	a4,s4,80003226 <balloc+0x80>
    80003256:	b769                	j	800031e0 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003258:	00005517          	auipc	a0,0x5
    8000325c:	3f050513          	addi	a0,a0,1008 # 80008648 <syscalls+0x180>
    80003260:	ffffd097          	auipc	ra,0xffffd
    80003264:	2da080e7          	jalr	730(ra) # 8000053a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003268:	97ca                	add	a5,a5,s2
    8000326a:	8e55                	or	a2,a2,a3
    8000326c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003270:	854a                	mv	a0,s2
    80003272:	00001097          	auipc	ra,0x1
    80003276:	026080e7          	jalr	38(ra) # 80004298 <log_write>
        brelse(bp);
    8000327a:	854a                	mv	a0,s2
    8000327c:	00000097          	auipc	ra,0x0
    80003280:	d98080e7          	jalr	-616(ra) # 80003014 <brelse>
  bp = bread(dev, bno);
    80003284:	85a6                	mv	a1,s1
    80003286:	855e                	mv	a0,s7
    80003288:	00000097          	auipc	ra,0x0
    8000328c:	c5c080e7          	jalr	-932(ra) # 80002ee4 <bread>
    80003290:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003292:	40000613          	li	a2,1024
    80003296:	4581                	li	a1,0
    80003298:	05850513          	addi	a0,a0,88
    8000329c:	ffffe097          	auipc	ra,0xffffe
    800032a0:	a30080e7          	jalr	-1488(ra) # 80000ccc <memset>
  log_write(bp);
    800032a4:	854a                	mv	a0,s2
    800032a6:	00001097          	auipc	ra,0x1
    800032aa:	ff2080e7          	jalr	-14(ra) # 80004298 <log_write>
  brelse(bp);
    800032ae:	854a                	mv	a0,s2
    800032b0:	00000097          	auipc	ra,0x0
    800032b4:	d64080e7          	jalr	-668(ra) # 80003014 <brelse>
}
    800032b8:	8526                	mv	a0,s1
    800032ba:	60e6                	ld	ra,88(sp)
    800032bc:	6446                	ld	s0,80(sp)
    800032be:	64a6                	ld	s1,72(sp)
    800032c0:	6906                	ld	s2,64(sp)
    800032c2:	79e2                	ld	s3,56(sp)
    800032c4:	7a42                	ld	s4,48(sp)
    800032c6:	7aa2                	ld	s5,40(sp)
    800032c8:	7b02                	ld	s6,32(sp)
    800032ca:	6be2                	ld	s7,24(sp)
    800032cc:	6c42                	ld	s8,16(sp)
    800032ce:	6ca2                	ld	s9,8(sp)
    800032d0:	6125                	addi	sp,sp,96
    800032d2:	8082                	ret

00000000800032d4 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800032d4:	7179                	addi	sp,sp,-48
    800032d6:	f406                	sd	ra,40(sp)
    800032d8:	f022                	sd	s0,32(sp)
    800032da:	ec26                	sd	s1,24(sp)
    800032dc:	e84a                	sd	s2,16(sp)
    800032de:	e44e                	sd	s3,8(sp)
    800032e0:	e052                	sd	s4,0(sp)
    800032e2:	1800                	addi	s0,sp,48
    800032e4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032e6:	47ad                	li	a5,11
    800032e8:	04b7fe63          	bgeu	a5,a1,80003344 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800032ec:	ff45849b          	addiw	s1,a1,-12
    800032f0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800032f4:	0ff00793          	li	a5,255
    800032f8:	0ae7e463          	bltu	a5,a4,800033a0 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800032fc:	08052583          	lw	a1,128(a0)
    80003300:	c5b5                	beqz	a1,8000336c <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003302:	00092503          	lw	a0,0(s2)
    80003306:	00000097          	auipc	ra,0x0
    8000330a:	bde080e7          	jalr	-1058(ra) # 80002ee4 <bread>
    8000330e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003310:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003314:	02049713          	slli	a4,s1,0x20
    80003318:	01e75593          	srli	a1,a4,0x1e
    8000331c:	00b784b3          	add	s1,a5,a1
    80003320:	0004a983          	lw	s3,0(s1)
    80003324:	04098e63          	beqz	s3,80003380 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003328:	8552                	mv	a0,s4
    8000332a:	00000097          	auipc	ra,0x0
    8000332e:	cea080e7          	jalr	-790(ra) # 80003014 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003332:	854e                	mv	a0,s3
    80003334:	70a2                	ld	ra,40(sp)
    80003336:	7402                	ld	s0,32(sp)
    80003338:	64e2                	ld	s1,24(sp)
    8000333a:	6942                	ld	s2,16(sp)
    8000333c:	69a2                	ld	s3,8(sp)
    8000333e:	6a02                	ld	s4,0(sp)
    80003340:	6145                	addi	sp,sp,48
    80003342:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003344:	02059793          	slli	a5,a1,0x20
    80003348:	01e7d593          	srli	a1,a5,0x1e
    8000334c:	00b504b3          	add	s1,a0,a1
    80003350:	0504a983          	lw	s3,80(s1)
    80003354:	fc099fe3          	bnez	s3,80003332 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003358:	4108                	lw	a0,0(a0)
    8000335a:	00000097          	auipc	ra,0x0
    8000335e:	e4c080e7          	jalr	-436(ra) # 800031a6 <balloc>
    80003362:	0005099b          	sext.w	s3,a0
    80003366:	0534a823          	sw	s3,80(s1)
    8000336a:	b7e1                	j	80003332 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000336c:	4108                	lw	a0,0(a0)
    8000336e:	00000097          	auipc	ra,0x0
    80003372:	e38080e7          	jalr	-456(ra) # 800031a6 <balloc>
    80003376:	0005059b          	sext.w	a1,a0
    8000337a:	08b92023          	sw	a1,128(s2)
    8000337e:	b751                	j	80003302 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003380:	00092503          	lw	a0,0(s2)
    80003384:	00000097          	auipc	ra,0x0
    80003388:	e22080e7          	jalr	-478(ra) # 800031a6 <balloc>
    8000338c:	0005099b          	sext.w	s3,a0
    80003390:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003394:	8552                	mv	a0,s4
    80003396:	00001097          	auipc	ra,0x1
    8000339a:	f02080e7          	jalr	-254(ra) # 80004298 <log_write>
    8000339e:	b769                	j	80003328 <bmap+0x54>
  panic("bmap: out of range");
    800033a0:	00005517          	auipc	a0,0x5
    800033a4:	2c050513          	addi	a0,a0,704 # 80008660 <syscalls+0x198>
    800033a8:	ffffd097          	auipc	ra,0xffffd
    800033ac:	192080e7          	jalr	402(ra) # 8000053a <panic>

00000000800033b0 <iget>:
{
    800033b0:	7179                	addi	sp,sp,-48
    800033b2:	f406                	sd	ra,40(sp)
    800033b4:	f022                	sd	s0,32(sp)
    800033b6:	ec26                	sd	s1,24(sp)
    800033b8:	e84a                	sd	s2,16(sp)
    800033ba:	e44e                	sd	s3,8(sp)
    800033bc:	e052                	sd	s4,0(sp)
    800033be:	1800                	addi	s0,sp,48
    800033c0:	89aa                	mv	s3,a0
    800033c2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033c4:	0001c517          	auipc	a0,0x1c
    800033c8:	40450513          	addi	a0,a0,1028 # 8001f7c8 <itable>
    800033cc:	ffffe097          	auipc	ra,0xffffe
    800033d0:	804080e7          	jalr	-2044(ra) # 80000bd0 <acquire>
  empty = 0;
    800033d4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033d6:	0001c497          	auipc	s1,0x1c
    800033da:	40a48493          	addi	s1,s1,1034 # 8001f7e0 <itable+0x18>
    800033de:	0001e697          	auipc	a3,0x1e
    800033e2:	e9268693          	addi	a3,a3,-366 # 80021270 <log>
    800033e6:	a039                	j	800033f4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033e8:	02090b63          	beqz	s2,8000341e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033ec:	08848493          	addi	s1,s1,136
    800033f0:	02d48a63          	beq	s1,a3,80003424 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033f4:	449c                	lw	a5,8(s1)
    800033f6:	fef059e3          	blez	a5,800033e8 <iget+0x38>
    800033fa:	4098                	lw	a4,0(s1)
    800033fc:	ff3716e3          	bne	a4,s3,800033e8 <iget+0x38>
    80003400:	40d8                	lw	a4,4(s1)
    80003402:	ff4713e3          	bne	a4,s4,800033e8 <iget+0x38>
      ip->ref++;
    80003406:	2785                	addiw	a5,a5,1
    80003408:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000340a:	0001c517          	auipc	a0,0x1c
    8000340e:	3be50513          	addi	a0,a0,958 # 8001f7c8 <itable>
    80003412:	ffffe097          	auipc	ra,0xffffe
    80003416:	872080e7          	jalr	-1934(ra) # 80000c84 <release>
      return ip;
    8000341a:	8926                	mv	s2,s1
    8000341c:	a03d                	j	8000344a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000341e:	f7f9                	bnez	a5,800033ec <iget+0x3c>
    80003420:	8926                	mv	s2,s1
    80003422:	b7e9                	j	800033ec <iget+0x3c>
  if(empty == 0)
    80003424:	02090c63          	beqz	s2,8000345c <iget+0xac>
  ip->dev = dev;
    80003428:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000342c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003430:	4785                	li	a5,1
    80003432:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003436:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000343a:	0001c517          	auipc	a0,0x1c
    8000343e:	38e50513          	addi	a0,a0,910 # 8001f7c8 <itable>
    80003442:	ffffe097          	auipc	ra,0xffffe
    80003446:	842080e7          	jalr	-1982(ra) # 80000c84 <release>
}
    8000344a:	854a                	mv	a0,s2
    8000344c:	70a2                	ld	ra,40(sp)
    8000344e:	7402                	ld	s0,32(sp)
    80003450:	64e2                	ld	s1,24(sp)
    80003452:	6942                	ld	s2,16(sp)
    80003454:	69a2                	ld	s3,8(sp)
    80003456:	6a02                	ld	s4,0(sp)
    80003458:	6145                	addi	sp,sp,48
    8000345a:	8082                	ret
    panic("iget: no inodes");
    8000345c:	00005517          	auipc	a0,0x5
    80003460:	21c50513          	addi	a0,a0,540 # 80008678 <syscalls+0x1b0>
    80003464:	ffffd097          	auipc	ra,0xffffd
    80003468:	0d6080e7          	jalr	214(ra) # 8000053a <panic>

000000008000346c <fsinit>:
fsinit(int dev) {
    8000346c:	7179                	addi	sp,sp,-48
    8000346e:	f406                	sd	ra,40(sp)
    80003470:	f022                	sd	s0,32(sp)
    80003472:	ec26                	sd	s1,24(sp)
    80003474:	e84a                	sd	s2,16(sp)
    80003476:	e44e                	sd	s3,8(sp)
    80003478:	1800                	addi	s0,sp,48
    8000347a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000347c:	4585                	li	a1,1
    8000347e:	00000097          	auipc	ra,0x0
    80003482:	a66080e7          	jalr	-1434(ra) # 80002ee4 <bread>
    80003486:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003488:	0001c997          	auipc	s3,0x1c
    8000348c:	32098993          	addi	s3,s3,800 # 8001f7a8 <sb>
    80003490:	02000613          	li	a2,32
    80003494:	05850593          	addi	a1,a0,88
    80003498:	854e                	mv	a0,s3
    8000349a:	ffffe097          	auipc	ra,0xffffe
    8000349e:	88e080e7          	jalr	-1906(ra) # 80000d28 <memmove>
  brelse(bp);
    800034a2:	8526                	mv	a0,s1
    800034a4:	00000097          	auipc	ra,0x0
    800034a8:	b70080e7          	jalr	-1168(ra) # 80003014 <brelse>
  if(sb.magic != FSMAGIC)
    800034ac:	0009a703          	lw	a4,0(s3)
    800034b0:	102037b7          	lui	a5,0x10203
    800034b4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034b8:	02f71263          	bne	a4,a5,800034dc <fsinit+0x70>
  initlog(dev, &sb);
    800034bc:	0001c597          	auipc	a1,0x1c
    800034c0:	2ec58593          	addi	a1,a1,748 # 8001f7a8 <sb>
    800034c4:	854a                	mv	a0,s2
    800034c6:	00001097          	auipc	ra,0x1
    800034ca:	b56080e7          	jalr	-1194(ra) # 8000401c <initlog>
}
    800034ce:	70a2                	ld	ra,40(sp)
    800034d0:	7402                	ld	s0,32(sp)
    800034d2:	64e2                	ld	s1,24(sp)
    800034d4:	6942                	ld	s2,16(sp)
    800034d6:	69a2                	ld	s3,8(sp)
    800034d8:	6145                	addi	sp,sp,48
    800034da:	8082                	ret
    panic("invalid file system");
    800034dc:	00005517          	auipc	a0,0x5
    800034e0:	1ac50513          	addi	a0,a0,428 # 80008688 <syscalls+0x1c0>
    800034e4:	ffffd097          	auipc	ra,0xffffd
    800034e8:	056080e7          	jalr	86(ra) # 8000053a <panic>

00000000800034ec <iinit>:
{
    800034ec:	7179                	addi	sp,sp,-48
    800034ee:	f406                	sd	ra,40(sp)
    800034f0:	f022                	sd	s0,32(sp)
    800034f2:	ec26                	sd	s1,24(sp)
    800034f4:	e84a                	sd	s2,16(sp)
    800034f6:	e44e                	sd	s3,8(sp)
    800034f8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034fa:	00005597          	auipc	a1,0x5
    800034fe:	1a658593          	addi	a1,a1,422 # 800086a0 <syscalls+0x1d8>
    80003502:	0001c517          	auipc	a0,0x1c
    80003506:	2c650513          	addi	a0,a0,710 # 8001f7c8 <itable>
    8000350a:	ffffd097          	auipc	ra,0xffffd
    8000350e:	636080e7          	jalr	1590(ra) # 80000b40 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003512:	0001c497          	auipc	s1,0x1c
    80003516:	2de48493          	addi	s1,s1,734 # 8001f7f0 <itable+0x28>
    8000351a:	0001e997          	auipc	s3,0x1e
    8000351e:	d6698993          	addi	s3,s3,-666 # 80021280 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003522:	00005917          	auipc	s2,0x5
    80003526:	18690913          	addi	s2,s2,390 # 800086a8 <syscalls+0x1e0>
    8000352a:	85ca                	mv	a1,s2
    8000352c:	8526                	mv	a0,s1
    8000352e:	00001097          	auipc	ra,0x1
    80003532:	e4e080e7          	jalr	-434(ra) # 8000437c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003536:	08848493          	addi	s1,s1,136
    8000353a:	ff3498e3          	bne	s1,s3,8000352a <iinit+0x3e>
}
    8000353e:	70a2                	ld	ra,40(sp)
    80003540:	7402                	ld	s0,32(sp)
    80003542:	64e2                	ld	s1,24(sp)
    80003544:	6942                	ld	s2,16(sp)
    80003546:	69a2                	ld	s3,8(sp)
    80003548:	6145                	addi	sp,sp,48
    8000354a:	8082                	ret

000000008000354c <ialloc>:
{
    8000354c:	715d                	addi	sp,sp,-80
    8000354e:	e486                	sd	ra,72(sp)
    80003550:	e0a2                	sd	s0,64(sp)
    80003552:	fc26                	sd	s1,56(sp)
    80003554:	f84a                	sd	s2,48(sp)
    80003556:	f44e                	sd	s3,40(sp)
    80003558:	f052                	sd	s4,32(sp)
    8000355a:	ec56                	sd	s5,24(sp)
    8000355c:	e85a                	sd	s6,16(sp)
    8000355e:	e45e                	sd	s7,8(sp)
    80003560:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003562:	0001c717          	auipc	a4,0x1c
    80003566:	25272703          	lw	a4,594(a4) # 8001f7b4 <sb+0xc>
    8000356a:	4785                	li	a5,1
    8000356c:	04e7fa63          	bgeu	a5,a4,800035c0 <ialloc+0x74>
    80003570:	8aaa                	mv	s5,a0
    80003572:	8bae                	mv	s7,a1
    80003574:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003576:	0001ca17          	auipc	s4,0x1c
    8000357a:	232a0a13          	addi	s4,s4,562 # 8001f7a8 <sb>
    8000357e:	00048b1b          	sext.w	s6,s1
    80003582:	0044d593          	srli	a1,s1,0x4
    80003586:	018a2783          	lw	a5,24(s4)
    8000358a:	9dbd                	addw	a1,a1,a5
    8000358c:	8556                	mv	a0,s5
    8000358e:	00000097          	auipc	ra,0x0
    80003592:	956080e7          	jalr	-1706(ra) # 80002ee4 <bread>
    80003596:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003598:	05850993          	addi	s3,a0,88
    8000359c:	00f4f793          	andi	a5,s1,15
    800035a0:	079a                	slli	a5,a5,0x6
    800035a2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035a4:	00099783          	lh	a5,0(s3)
    800035a8:	c785                	beqz	a5,800035d0 <ialloc+0x84>
    brelse(bp);
    800035aa:	00000097          	auipc	ra,0x0
    800035ae:	a6a080e7          	jalr	-1430(ra) # 80003014 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035b2:	0485                	addi	s1,s1,1
    800035b4:	00ca2703          	lw	a4,12(s4)
    800035b8:	0004879b          	sext.w	a5,s1
    800035bc:	fce7e1e3          	bltu	a5,a4,8000357e <ialloc+0x32>
  panic("ialloc: no inodes");
    800035c0:	00005517          	auipc	a0,0x5
    800035c4:	0f050513          	addi	a0,a0,240 # 800086b0 <syscalls+0x1e8>
    800035c8:	ffffd097          	auipc	ra,0xffffd
    800035cc:	f72080e7          	jalr	-142(ra) # 8000053a <panic>
      memset(dip, 0, sizeof(*dip));
    800035d0:	04000613          	li	a2,64
    800035d4:	4581                	li	a1,0
    800035d6:	854e                	mv	a0,s3
    800035d8:	ffffd097          	auipc	ra,0xffffd
    800035dc:	6f4080e7          	jalr	1780(ra) # 80000ccc <memset>
      dip->type = type;
    800035e0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035e4:	854a                	mv	a0,s2
    800035e6:	00001097          	auipc	ra,0x1
    800035ea:	cb2080e7          	jalr	-846(ra) # 80004298 <log_write>
      brelse(bp);
    800035ee:	854a                	mv	a0,s2
    800035f0:	00000097          	auipc	ra,0x0
    800035f4:	a24080e7          	jalr	-1500(ra) # 80003014 <brelse>
      return iget(dev, inum);
    800035f8:	85da                	mv	a1,s6
    800035fa:	8556                	mv	a0,s5
    800035fc:	00000097          	auipc	ra,0x0
    80003600:	db4080e7          	jalr	-588(ra) # 800033b0 <iget>
}
    80003604:	60a6                	ld	ra,72(sp)
    80003606:	6406                	ld	s0,64(sp)
    80003608:	74e2                	ld	s1,56(sp)
    8000360a:	7942                	ld	s2,48(sp)
    8000360c:	79a2                	ld	s3,40(sp)
    8000360e:	7a02                	ld	s4,32(sp)
    80003610:	6ae2                	ld	s5,24(sp)
    80003612:	6b42                	ld	s6,16(sp)
    80003614:	6ba2                	ld	s7,8(sp)
    80003616:	6161                	addi	sp,sp,80
    80003618:	8082                	ret

000000008000361a <iupdate>:
{
    8000361a:	1101                	addi	sp,sp,-32
    8000361c:	ec06                	sd	ra,24(sp)
    8000361e:	e822                	sd	s0,16(sp)
    80003620:	e426                	sd	s1,8(sp)
    80003622:	e04a                	sd	s2,0(sp)
    80003624:	1000                	addi	s0,sp,32
    80003626:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003628:	415c                	lw	a5,4(a0)
    8000362a:	0047d79b          	srliw	a5,a5,0x4
    8000362e:	0001c597          	auipc	a1,0x1c
    80003632:	1925a583          	lw	a1,402(a1) # 8001f7c0 <sb+0x18>
    80003636:	9dbd                	addw	a1,a1,a5
    80003638:	4108                	lw	a0,0(a0)
    8000363a:	00000097          	auipc	ra,0x0
    8000363e:	8aa080e7          	jalr	-1878(ra) # 80002ee4 <bread>
    80003642:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003644:	05850793          	addi	a5,a0,88
    80003648:	40d8                	lw	a4,4(s1)
    8000364a:	8b3d                	andi	a4,a4,15
    8000364c:	071a                	slli	a4,a4,0x6
    8000364e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003650:	04449703          	lh	a4,68(s1)
    80003654:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003658:	04649703          	lh	a4,70(s1)
    8000365c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003660:	04849703          	lh	a4,72(s1)
    80003664:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003668:	04a49703          	lh	a4,74(s1)
    8000366c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003670:	44f8                	lw	a4,76(s1)
    80003672:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003674:	03400613          	li	a2,52
    80003678:	05048593          	addi	a1,s1,80
    8000367c:	00c78513          	addi	a0,a5,12
    80003680:	ffffd097          	auipc	ra,0xffffd
    80003684:	6a8080e7          	jalr	1704(ra) # 80000d28 <memmove>
  log_write(bp);
    80003688:	854a                	mv	a0,s2
    8000368a:	00001097          	auipc	ra,0x1
    8000368e:	c0e080e7          	jalr	-1010(ra) # 80004298 <log_write>
  brelse(bp);
    80003692:	854a                	mv	a0,s2
    80003694:	00000097          	auipc	ra,0x0
    80003698:	980080e7          	jalr	-1664(ra) # 80003014 <brelse>
}
    8000369c:	60e2                	ld	ra,24(sp)
    8000369e:	6442                	ld	s0,16(sp)
    800036a0:	64a2                	ld	s1,8(sp)
    800036a2:	6902                	ld	s2,0(sp)
    800036a4:	6105                	addi	sp,sp,32
    800036a6:	8082                	ret

00000000800036a8 <idup>:
{
    800036a8:	1101                	addi	sp,sp,-32
    800036aa:	ec06                	sd	ra,24(sp)
    800036ac:	e822                	sd	s0,16(sp)
    800036ae:	e426                	sd	s1,8(sp)
    800036b0:	1000                	addi	s0,sp,32
    800036b2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036b4:	0001c517          	auipc	a0,0x1c
    800036b8:	11450513          	addi	a0,a0,276 # 8001f7c8 <itable>
    800036bc:	ffffd097          	auipc	ra,0xffffd
    800036c0:	514080e7          	jalr	1300(ra) # 80000bd0 <acquire>
  ip->ref++;
    800036c4:	449c                	lw	a5,8(s1)
    800036c6:	2785                	addiw	a5,a5,1
    800036c8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036ca:	0001c517          	auipc	a0,0x1c
    800036ce:	0fe50513          	addi	a0,a0,254 # 8001f7c8 <itable>
    800036d2:	ffffd097          	auipc	ra,0xffffd
    800036d6:	5b2080e7          	jalr	1458(ra) # 80000c84 <release>
}
    800036da:	8526                	mv	a0,s1
    800036dc:	60e2                	ld	ra,24(sp)
    800036de:	6442                	ld	s0,16(sp)
    800036e0:	64a2                	ld	s1,8(sp)
    800036e2:	6105                	addi	sp,sp,32
    800036e4:	8082                	ret

00000000800036e6 <ilock>:
{
    800036e6:	1101                	addi	sp,sp,-32
    800036e8:	ec06                	sd	ra,24(sp)
    800036ea:	e822                	sd	s0,16(sp)
    800036ec:	e426                	sd	s1,8(sp)
    800036ee:	e04a                	sd	s2,0(sp)
    800036f0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036f2:	c115                	beqz	a0,80003716 <ilock+0x30>
    800036f4:	84aa                	mv	s1,a0
    800036f6:	451c                	lw	a5,8(a0)
    800036f8:	00f05f63          	blez	a5,80003716 <ilock+0x30>
  acquiresleep(&ip->lock);
    800036fc:	0541                	addi	a0,a0,16
    800036fe:	00001097          	auipc	ra,0x1
    80003702:	cb8080e7          	jalr	-840(ra) # 800043b6 <acquiresleep>
  if(ip->valid == 0){
    80003706:	40bc                	lw	a5,64(s1)
    80003708:	cf99                	beqz	a5,80003726 <ilock+0x40>
}
    8000370a:	60e2                	ld	ra,24(sp)
    8000370c:	6442                	ld	s0,16(sp)
    8000370e:	64a2                	ld	s1,8(sp)
    80003710:	6902                	ld	s2,0(sp)
    80003712:	6105                	addi	sp,sp,32
    80003714:	8082                	ret
    panic("ilock");
    80003716:	00005517          	auipc	a0,0x5
    8000371a:	fb250513          	addi	a0,a0,-78 # 800086c8 <syscalls+0x200>
    8000371e:	ffffd097          	auipc	ra,0xffffd
    80003722:	e1c080e7          	jalr	-484(ra) # 8000053a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003726:	40dc                	lw	a5,4(s1)
    80003728:	0047d79b          	srliw	a5,a5,0x4
    8000372c:	0001c597          	auipc	a1,0x1c
    80003730:	0945a583          	lw	a1,148(a1) # 8001f7c0 <sb+0x18>
    80003734:	9dbd                	addw	a1,a1,a5
    80003736:	4088                	lw	a0,0(s1)
    80003738:	fffff097          	auipc	ra,0xfffff
    8000373c:	7ac080e7          	jalr	1964(ra) # 80002ee4 <bread>
    80003740:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003742:	05850593          	addi	a1,a0,88
    80003746:	40dc                	lw	a5,4(s1)
    80003748:	8bbd                	andi	a5,a5,15
    8000374a:	079a                	slli	a5,a5,0x6
    8000374c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000374e:	00059783          	lh	a5,0(a1)
    80003752:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003756:	00259783          	lh	a5,2(a1)
    8000375a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000375e:	00459783          	lh	a5,4(a1)
    80003762:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003766:	00659783          	lh	a5,6(a1)
    8000376a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000376e:	459c                	lw	a5,8(a1)
    80003770:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003772:	03400613          	li	a2,52
    80003776:	05b1                	addi	a1,a1,12
    80003778:	05048513          	addi	a0,s1,80
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	5ac080e7          	jalr	1452(ra) # 80000d28 <memmove>
    brelse(bp);
    80003784:	854a                	mv	a0,s2
    80003786:	00000097          	auipc	ra,0x0
    8000378a:	88e080e7          	jalr	-1906(ra) # 80003014 <brelse>
    ip->valid = 1;
    8000378e:	4785                	li	a5,1
    80003790:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003792:	04449783          	lh	a5,68(s1)
    80003796:	fbb5                	bnez	a5,8000370a <ilock+0x24>
      panic("ilock: no type");
    80003798:	00005517          	auipc	a0,0x5
    8000379c:	f3850513          	addi	a0,a0,-200 # 800086d0 <syscalls+0x208>
    800037a0:	ffffd097          	auipc	ra,0xffffd
    800037a4:	d9a080e7          	jalr	-614(ra) # 8000053a <panic>

00000000800037a8 <iunlock>:
{
    800037a8:	1101                	addi	sp,sp,-32
    800037aa:	ec06                	sd	ra,24(sp)
    800037ac:	e822                	sd	s0,16(sp)
    800037ae:	e426                	sd	s1,8(sp)
    800037b0:	e04a                	sd	s2,0(sp)
    800037b2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037b4:	c905                	beqz	a0,800037e4 <iunlock+0x3c>
    800037b6:	84aa                	mv	s1,a0
    800037b8:	01050913          	addi	s2,a0,16
    800037bc:	854a                	mv	a0,s2
    800037be:	00001097          	auipc	ra,0x1
    800037c2:	c92080e7          	jalr	-878(ra) # 80004450 <holdingsleep>
    800037c6:	cd19                	beqz	a0,800037e4 <iunlock+0x3c>
    800037c8:	449c                	lw	a5,8(s1)
    800037ca:	00f05d63          	blez	a5,800037e4 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037ce:	854a                	mv	a0,s2
    800037d0:	00001097          	auipc	ra,0x1
    800037d4:	c3c080e7          	jalr	-964(ra) # 8000440c <releasesleep>
}
    800037d8:	60e2                	ld	ra,24(sp)
    800037da:	6442                	ld	s0,16(sp)
    800037dc:	64a2                	ld	s1,8(sp)
    800037de:	6902                	ld	s2,0(sp)
    800037e0:	6105                	addi	sp,sp,32
    800037e2:	8082                	ret
    panic("iunlock");
    800037e4:	00005517          	auipc	a0,0x5
    800037e8:	efc50513          	addi	a0,a0,-260 # 800086e0 <syscalls+0x218>
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	d4e080e7          	jalr	-690(ra) # 8000053a <panic>

00000000800037f4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037f4:	7179                	addi	sp,sp,-48
    800037f6:	f406                	sd	ra,40(sp)
    800037f8:	f022                	sd	s0,32(sp)
    800037fa:	ec26                	sd	s1,24(sp)
    800037fc:	e84a                	sd	s2,16(sp)
    800037fe:	e44e                	sd	s3,8(sp)
    80003800:	e052                	sd	s4,0(sp)
    80003802:	1800                	addi	s0,sp,48
    80003804:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003806:	05050493          	addi	s1,a0,80
    8000380a:	08050913          	addi	s2,a0,128
    8000380e:	a021                	j	80003816 <itrunc+0x22>
    80003810:	0491                	addi	s1,s1,4
    80003812:	01248d63          	beq	s1,s2,8000382c <itrunc+0x38>
    if(ip->addrs[i]){
    80003816:	408c                	lw	a1,0(s1)
    80003818:	dde5                	beqz	a1,80003810 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000381a:	0009a503          	lw	a0,0(s3)
    8000381e:	00000097          	auipc	ra,0x0
    80003822:	90c080e7          	jalr	-1780(ra) # 8000312a <bfree>
      ip->addrs[i] = 0;
    80003826:	0004a023          	sw	zero,0(s1)
    8000382a:	b7dd                	j	80003810 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000382c:	0809a583          	lw	a1,128(s3)
    80003830:	e185                	bnez	a1,80003850 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003832:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003836:	854e                	mv	a0,s3
    80003838:	00000097          	auipc	ra,0x0
    8000383c:	de2080e7          	jalr	-542(ra) # 8000361a <iupdate>
}
    80003840:	70a2                	ld	ra,40(sp)
    80003842:	7402                	ld	s0,32(sp)
    80003844:	64e2                	ld	s1,24(sp)
    80003846:	6942                	ld	s2,16(sp)
    80003848:	69a2                	ld	s3,8(sp)
    8000384a:	6a02                	ld	s4,0(sp)
    8000384c:	6145                	addi	sp,sp,48
    8000384e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003850:	0009a503          	lw	a0,0(s3)
    80003854:	fffff097          	auipc	ra,0xfffff
    80003858:	690080e7          	jalr	1680(ra) # 80002ee4 <bread>
    8000385c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000385e:	05850493          	addi	s1,a0,88
    80003862:	45850913          	addi	s2,a0,1112
    80003866:	a021                	j	8000386e <itrunc+0x7a>
    80003868:	0491                	addi	s1,s1,4
    8000386a:	01248b63          	beq	s1,s2,80003880 <itrunc+0x8c>
      if(a[j])
    8000386e:	408c                	lw	a1,0(s1)
    80003870:	dde5                	beqz	a1,80003868 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003872:	0009a503          	lw	a0,0(s3)
    80003876:	00000097          	auipc	ra,0x0
    8000387a:	8b4080e7          	jalr	-1868(ra) # 8000312a <bfree>
    8000387e:	b7ed                	j	80003868 <itrunc+0x74>
    brelse(bp);
    80003880:	8552                	mv	a0,s4
    80003882:	fffff097          	auipc	ra,0xfffff
    80003886:	792080e7          	jalr	1938(ra) # 80003014 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000388a:	0809a583          	lw	a1,128(s3)
    8000388e:	0009a503          	lw	a0,0(s3)
    80003892:	00000097          	auipc	ra,0x0
    80003896:	898080e7          	jalr	-1896(ra) # 8000312a <bfree>
    ip->addrs[NDIRECT] = 0;
    8000389a:	0809a023          	sw	zero,128(s3)
    8000389e:	bf51                	j	80003832 <itrunc+0x3e>

00000000800038a0 <iput>:
{
    800038a0:	1101                	addi	sp,sp,-32
    800038a2:	ec06                	sd	ra,24(sp)
    800038a4:	e822                	sd	s0,16(sp)
    800038a6:	e426                	sd	s1,8(sp)
    800038a8:	e04a                	sd	s2,0(sp)
    800038aa:	1000                	addi	s0,sp,32
    800038ac:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038ae:	0001c517          	auipc	a0,0x1c
    800038b2:	f1a50513          	addi	a0,a0,-230 # 8001f7c8 <itable>
    800038b6:	ffffd097          	auipc	ra,0xffffd
    800038ba:	31a080e7          	jalr	794(ra) # 80000bd0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038be:	4498                	lw	a4,8(s1)
    800038c0:	4785                	li	a5,1
    800038c2:	02f70363          	beq	a4,a5,800038e8 <iput+0x48>
  ip->ref--;
    800038c6:	449c                	lw	a5,8(s1)
    800038c8:	37fd                	addiw	a5,a5,-1
    800038ca:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038cc:	0001c517          	auipc	a0,0x1c
    800038d0:	efc50513          	addi	a0,a0,-260 # 8001f7c8 <itable>
    800038d4:	ffffd097          	auipc	ra,0xffffd
    800038d8:	3b0080e7          	jalr	944(ra) # 80000c84 <release>
}
    800038dc:	60e2                	ld	ra,24(sp)
    800038de:	6442                	ld	s0,16(sp)
    800038e0:	64a2                	ld	s1,8(sp)
    800038e2:	6902                	ld	s2,0(sp)
    800038e4:	6105                	addi	sp,sp,32
    800038e6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038e8:	40bc                	lw	a5,64(s1)
    800038ea:	dff1                	beqz	a5,800038c6 <iput+0x26>
    800038ec:	04a49783          	lh	a5,74(s1)
    800038f0:	fbf9                	bnez	a5,800038c6 <iput+0x26>
    acquiresleep(&ip->lock);
    800038f2:	01048913          	addi	s2,s1,16
    800038f6:	854a                	mv	a0,s2
    800038f8:	00001097          	auipc	ra,0x1
    800038fc:	abe080e7          	jalr	-1346(ra) # 800043b6 <acquiresleep>
    release(&itable.lock);
    80003900:	0001c517          	auipc	a0,0x1c
    80003904:	ec850513          	addi	a0,a0,-312 # 8001f7c8 <itable>
    80003908:	ffffd097          	auipc	ra,0xffffd
    8000390c:	37c080e7          	jalr	892(ra) # 80000c84 <release>
    itrunc(ip);
    80003910:	8526                	mv	a0,s1
    80003912:	00000097          	auipc	ra,0x0
    80003916:	ee2080e7          	jalr	-286(ra) # 800037f4 <itrunc>
    ip->type = 0;
    8000391a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000391e:	8526                	mv	a0,s1
    80003920:	00000097          	auipc	ra,0x0
    80003924:	cfa080e7          	jalr	-774(ra) # 8000361a <iupdate>
    ip->valid = 0;
    80003928:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000392c:	854a                	mv	a0,s2
    8000392e:	00001097          	auipc	ra,0x1
    80003932:	ade080e7          	jalr	-1314(ra) # 8000440c <releasesleep>
    acquire(&itable.lock);
    80003936:	0001c517          	auipc	a0,0x1c
    8000393a:	e9250513          	addi	a0,a0,-366 # 8001f7c8 <itable>
    8000393e:	ffffd097          	auipc	ra,0xffffd
    80003942:	292080e7          	jalr	658(ra) # 80000bd0 <acquire>
    80003946:	b741                	j	800038c6 <iput+0x26>

0000000080003948 <iunlockput>:
{
    80003948:	1101                	addi	sp,sp,-32
    8000394a:	ec06                	sd	ra,24(sp)
    8000394c:	e822                	sd	s0,16(sp)
    8000394e:	e426                	sd	s1,8(sp)
    80003950:	1000                	addi	s0,sp,32
    80003952:	84aa                	mv	s1,a0
  iunlock(ip);
    80003954:	00000097          	auipc	ra,0x0
    80003958:	e54080e7          	jalr	-428(ra) # 800037a8 <iunlock>
  iput(ip);
    8000395c:	8526                	mv	a0,s1
    8000395e:	00000097          	auipc	ra,0x0
    80003962:	f42080e7          	jalr	-190(ra) # 800038a0 <iput>
}
    80003966:	60e2                	ld	ra,24(sp)
    80003968:	6442                	ld	s0,16(sp)
    8000396a:	64a2                	ld	s1,8(sp)
    8000396c:	6105                	addi	sp,sp,32
    8000396e:	8082                	ret

0000000080003970 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003970:	1141                	addi	sp,sp,-16
    80003972:	e422                	sd	s0,8(sp)
    80003974:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003976:	411c                	lw	a5,0(a0)
    80003978:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000397a:	415c                	lw	a5,4(a0)
    8000397c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000397e:	04451783          	lh	a5,68(a0)
    80003982:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003986:	04a51783          	lh	a5,74(a0)
    8000398a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000398e:	04c56783          	lwu	a5,76(a0)
    80003992:	e99c                	sd	a5,16(a1)
}
    80003994:	6422                	ld	s0,8(sp)
    80003996:	0141                	addi	sp,sp,16
    80003998:	8082                	ret

000000008000399a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000399a:	457c                	lw	a5,76(a0)
    8000399c:	0ed7e963          	bltu	a5,a3,80003a8e <readi+0xf4>
{
    800039a0:	7159                	addi	sp,sp,-112
    800039a2:	f486                	sd	ra,104(sp)
    800039a4:	f0a2                	sd	s0,96(sp)
    800039a6:	eca6                	sd	s1,88(sp)
    800039a8:	e8ca                	sd	s2,80(sp)
    800039aa:	e4ce                	sd	s3,72(sp)
    800039ac:	e0d2                	sd	s4,64(sp)
    800039ae:	fc56                	sd	s5,56(sp)
    800039b0:	f85a                	sd	s6,48(sp)
    800039b2:	f45e                	sd	s7,40(sp)
    800039b4:	f062                	sd	s8,32(sp)
    800039b6:	ec66                	sd	s9,24(sp)
    800039b8:	e86a                	sd	s10,16(sp)
    800039ba:	e46e                	sd	s11,8(sp)
    800039bc:	1880                	addi	s0,sp,112
    800039be:	8baa                	mv	s7,a0
    800039c0:	8c2e                	mv	s8,a1
    800039c2:	8ab2                	mv	s5,a2
    800039c4:	84b6                	mv	s1,a3
    800039c6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039c8:	9f35                	addw	a4,a4,a3
    return 0;
    800039ca:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039cc:	0ad76063          	bltu	a4,a3,80003a6c <readi+0xd2>
  if(off + n > ip->size)
    800039d0:	00e7f463          	bgeu	a5,a4,800039d8 <readi+0x3e>
    n = ip->size - off;
    800039d4:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039d8:	0a0b0963          	beqz	s6,80003a8a <readi+0xf0>
    800039dc:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800039de:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039e2:	5cfd                	li	s9,-1
    800039e4:	a82d                	j	80003a1e <readi+0x84>
    800039e6:	020a1d93          	slli	s11,s4,0x20
    800039ea:	020ddd93          	srli	s11,s11,0x20
    800039ee:	05890613          	addi	a2,s2,88
    800039f2:	86ee                	mv	a3,s11
    800039f4:	963a                	add	a2,a2,a4
    800039f6:	85d6                	mv	a1,s5
    800039f8:	8562                	mv	a0,s8
    800039fa:	fffff097          	auipc	ra,0xfffff
    800039fe:	a84080e7          	jalr	-1404(ra) # 8000247e <either_copyout>
    80003a02:	05950d63          	beq	a0,s9,80003a5c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a06:	854a                	mv	a0,s2
    80003a08:	fffff097          	auipc	ra,0xfffff
    80003a0c:	60c080e7          	jalr	1548(ra) # 80003014 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a10:	013a09bb          	addw	s3,s4,s3
    80003a14:	009a04bb          	addw	s1,s4,s1
    80003a18:	9aee                	add	s5,s5,s11
    80003a1a:	0569f763          	bgeu	s3,s6,80003a68 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a1e:	000ba903          	lw	s2,0(s7)
    80003a22:	00a4d59b          	srliw	a1,s1,0xa
    80003a26:	855e                	mv	a0,s7
    80003a28:	00000097          	auipc	ra,0x0
    80003a2c:	8ac080e7          	jalr	-1876(ra) # 800032d4 <bmap>
    80003a30:	0005059b          	sext.w	a1,a0
    80003a34:	854a                	mv	a0,s2
    80003a36:	fffff097          	auipc	ra,0xfffff
    80003a3a:	4ae080e7          	jalr	1198(ra) # 80002ee4 <bread>
    80003a3e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a40:	3ff4f713          	andi	a4,s1,1023
    80003a44:	40ed07bb          	subw	a5,s10,a4
    80003a48:	413b06bb          	subw	a3,s6,s3
    80003a4c:	8a3e                	mv	s4,a5
    80003a4e:	2781                	sext.w	a5,a5
    80003a50:	0006861b          	sext.w	a2,a3
    80003a54:	f8f679e3          	bgeu	a2,a5,800039e6 <readi+0x4c>
    80003a58:	8a36                	mv	s4,a3
    80003a5a:	b771                	j	800039e6 <readi+0x4c>
      brelse(bp);
    80003a5c:	854a                	mv	a0,s2
    80003a5e:	fffff097          	auipc	ra,0xfffff
    80003a62:	5b6080e7          	jalr	1462(ra) # 80003014 <brelse>
      tot = -1;
    80003a66:	59fd                	li	s3,-1
  }
  return tot;
    80003a68:	0009851b          	sext.w	a0,s3
}
    80003a6c:	70a6                	ld	ra,104(sp)
    80003a6e:	7406                	ld	s0,96(sp)
    80003a70:	64e6                	ld	s1,88(sp)
    80003a72:	6946                	ld	s2,80(sp)
    80003a74:	69a6                	ld	s3,72(sp)
    80003a76:	6a06                	ld	s4,64(sp)
    80003a78:	7ae2                	ld	s5,56(sp)
    80003a7a:	7b42                	ld	s6,48(sp)
    80003a7c:	7ba2                	ld	s7,40(sp)
    80003a7e:	7c02                	ld	s8,32(sp)
    80003a80:	6ce2                	ld	s9,24(sp)
    80003a82:	6d42                	ld	s10,16(sp)
    80003a84:	6da2                	ld	s11,8(sp)
    80003a86:	6165                	addi	sp,sp,112
    80003a88:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a8a:	89da                	mv	s3,s6
    80003a8c:	bff1                	j	80003a68 <readi+0xce>
    return 0;
    80003a8e:	4501                	li	a0,0
}
    80003a90:	8082                	ret

0000000080003a92 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a92:	457c                	lw	a5,76(a0)
    80003a94:	10d7e863          	bltu	a5,a3,80003ba4 <writei+0x112>
{
    80003a98:	7159                	addi	sp,sp,-112
    80003a9a:	f486                	sd	ra,104(sp)
    80003a9c:	f0a2                	sd	s0,96(sp)
    80003a9e:	eca6                	sd	s1,88(sp)
    80003aa0:	e8ca                	sd	s2,80(sp)
    80003aa2:	e4ce                	sd	s3,72(sp)
    80003aa4:	e0d2                	sd	s4,64(sp)
    80003aa6:	fc56                	sd	s5,56(sp)
    80003aa8:	f85a                	sd	s6,48(sp)
    80003aaa:	f45e                	sd	s7,40(sp)
    80003aac:	f062                	sd	s8,32(sp)
    80003aae:	ec66                	sd	s9,24(sp)
    80003ab0:	e86a                	sd	s10,16(sp)
    80003ab2:	e46e                	sd	s11,8(sp)
    80003ab4:	1880                	addi	s0,sp,112
    80003ab6:	8b2a                	mv	s6,a0
    80003ab8:	8c2e                	mv	s8,a1
    80003aba:	8ab2                	mv	s5,a2
    80003abc:	8936                	mv	s2,a3
    80003abe:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003ac0:	00e687bb          	addw	a5,a3,a4
    80003ac4:	0ed7e263          	bltu	a5,a3,80003ba8 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ac8:	00043737          	lui	a4,0x43
    80003acc:	0ef76063          	bltu	a4,a5,80003bac <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ad0:	0c0b8863          	beqz	s7,80003ba0 <writei+0x10e>
    80003ad4:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ad6:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ada:	5cfd                	li	s9,-1
    80003adc:	a091                	j	80003b20 <writei+0x8e>
    80003ade:	02099d93          	slli	s11,s3,0x20
    80003ae2:	020ddd93          	srli	s11,s11,0x20
    80003ae6:	05848513          	addi	a0,s1,88
    80003aea:	86ee                	mv	a3,s11
    80003aec:	8656                	mv	a2,s5
    80003aee:	85e2                	mv	a1,s8
    80003af0:	953a                	add	a0,a0,a4
    80003af2:	fffff097          	auipc	ra,0xfffff
    80003af6:	9e2080e7          	jalr	-1566(ra) # 800024d4 <either_copyin>
    80003afa:	07950263          	beq	a0,s9,80003b5e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003afe:	8526                	mv	a0,s1
    80003b00:	00000097          	auipc	ra,0x0
    80003b04:	798080e7          	jalr	1944(ra) # 80004298 <log_write>
    brelse(bp);
    80003b08:	8526                	mv	a0,s1
    80003b0a:	fffff097          	auipc	ra,0xfffff
    80003b0e:	50a080e7          	jalr	1290(ra) # 80003014 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b12:	01498a3b          	addw	s4,s3,s4
    80003b16:	0129893b          	addw	s2,s3,s2
    80003b1a:	9aee                	add	s5,s5,s11
    80003b1c:	057a7663          	bgeu	s4,s7,80003b68 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b20:	000b2483          	lw	s1,0(s6)
    80003b24:	00a9559b          	srliw	a1,s2,0xa
    80003b28:	855a                	mv	a0,s6
    80003b2a:	fffff097          	auipc	ra,0xfffff
    80003b2e:	7aa080e7          	jalr	1962(ra) # 800032d4 <bmap>
    80003b32:	0005059b          	sext.w	a1,a0
    80003b36:	8526                	mv	a0,s1
    80003b38:	fffff097          	auipc	ra,0xfffff
    80003b3c:	3ac080e7          	jalr	940(ra) # 80002ee4 <bread>
    80003b40:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b42:	3ff97713          	andi	a4,s2,1023
    80003b46:	40ed07bb          	subw	a5,s10,a4
    80003b4a:	414b86bb          	subw	a3,s7,s4
    80003b4e:	89be                	mv	s3,a5
    80003b50:	2781                	sext.w	a5,a5
    80003b52:	0006861b          	sext.w	a2,a3
    80003b56:	f8f674e3          	bgeu	a2,a5,80003ade <writei+0x4c>
    80003b5a:	89b6                	mv	s3,a3
    80003b5c:	b749                	j	80003ade <writei+0x4c>
      brelse(bp);
    80003b5e:	8526                	mv	a0,s1
    80003b60:	fffff097          	auipc	ra,0xfffff
    80003b64:	4b4080e7          	jalr	1204(ra) # 80003014 <brelse>
  }

  if(off > ip->size)
    80003b68:	04cb2783          	lw	a5,76(s6)
    80003b6c:	0127f463          	bgeu	a5,s2,80003b74 <writei+0xe2>
    ip->size = off;
    80003b70:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b74:	855a                	mv	a0,s6
    80003b76:	00000097          	auipc	ra,0x0
    80003b7a:	aa4080e7          	jalr	-1372(ra) # 8000361a <iupdate>

  return tot;
    80003b7e:	000a051b          	sext.w	a0,s4
}
    80003b82:	70a6                	ld	ra,104(sp)
    80003b84:	7406                	ld	s0,96(sp)
    80003b86:	64e6                	ld	s1,88(sp)
    80003b88:	6946                	ld	s2,80(sp)
    80003b8a:	69a6                	ld	s3,72(sp)
    80003b8c:	6a06                	ld	s4,64(sp)
    80003b8e:	7ae2                	ld	s5,56(sp)
    80003b90:	7b42                	ld	s6,48(sp)
    80003b92:	7ba2                	ld	s7,40(sp)
    80003b94:	7c02                	ld	s8,32(sp)
    80003b96:	6ce2                	ld	s9,24(sp)
    80003b98:	6d42                	ld	s10,16(sp)
    80003b9a:	6da2                	ld	s11,8(sp)
    80003b9c:	6165                	addi	sp,sp,112
    80003b9e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ba0:	8a5e                	mv	s4,s7
    80003ba2:	bfc9                	j	80003b74 <writei+0xe2>
    return -1;
    80003ba4:	557d                	li	a0,-1
}
    80003ba6:	8082                	ret
    return -1;
    80003ba8:	557d                	li	a0,-1
    80003baa:	bfe1                	j	80003b82 <writei+0xf0>
    return -1;
    80003bac:	557d                	li	a0,-1
    80003bae:	bfd1                	j	80003b82 <writei+0xf0>

0000000080003bb0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003bb0:	1141                	addi	sp,sp,-16
    80003bb2:	e406                	sd	ra,8(sp)
    80003bb4:	e022                	sd	s0,0(sp)
    80003bb6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bb8:	4639                	li	a2,14
    80003bba:	ffffd097          	auipc	ra,0xffffd
    80003bbe:	1e2080e7          	jalr	482(ra) # 80000d9c <strncmp>
}
    80003bc2:	60a2                	ld	ra,8(sp)
    80003bc4:	6402                	ld	s0,0(sp)
    80003bc6:	0141                	addi	sp,sp,16
    80003bc8:	8082                	ret

0000000080003bca <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003bca:	7139                	addi	sp,sp,-64
    80003bcc:	fc06                	sd	ra,56(sp)
    80003bce:	f822                	sd	s0,48(sp)
    80003bd0:	f426                	sd	s1,40(sp)
    80003bd2:	f04a                	sd	s2,32(sp)
    80003bd4:	ec4e                	sd	s3,24(sp)
    80003bd6:	e852                	sd	s4,16(sp)
    80003bd8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003bda:	04451703          	lh	a4,68(a0)
    80003bde:	4785                	li	a5,1
    80003be0:	00f71a63          	bne	a4,a5,80003bf4 <dirlookup+0x2a>
    80003be4:	892a                	mv	s2,a0
    80003be6:	89ae                	mv	s3,a1
    80003be8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bea:	457c                	lw	a5,76(a0)
    80003bec:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bee:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bf0:	e79d                	bnez	a5,80003c1e <dirlookup+0x54>
    80003bf2:	a8a5                	j	80003c6a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003bf4:	00005517          	auipc	a0,0x5
    80003bf8:	af450513          	addi	a0,a0,-1292 # 800086e8 <syscalls+0x220>
    80003bfc:	ffffd097          	auipc	ra,0xffffd
    80003c00:	93e080e7          	jalr	-1730(ra) # 8000053a <panic>
      panic("dirlookup read");
    80003c04:	00005517          	auipc	a0,0x5
    80003c08:	afc50513          	addi	a0,a0,-1284 # 80008700 <syscalls+0x238>
    80003c0c:	ffffd097          	auipc	ra,0xffffd
    80003c10:	92e080e7          	jalr	-1746(ra) # 8000053a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c14:	24c1                	addiw	s1,s1,16
    80003c16:	04c92783          	lw	a5,76(s2)
    80003c1a:	04f4f763          	bgeu	s1,a5,80003c68 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c1e:	4741                	li	a4,16
    80003c20:	86a6                	mv	a3,s1
    80003c22:	fc040613          	addi	a2,s0,-64
    80003c26:	4581                	li	a1,0
    80003c28:	854a                	mv	a0,s2
    80003c2a:	00000097          	auipc	ra,0x0
    80003c2e:	d70080e7          	jalr	-656(ra) # 8000399a <readi>
    80003c32:	47c1                	li	a5,16
    80003c34:	fcf518e3          	bne	a0,a5,80003c04 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c38:	fc045783          	lhu	a5,-64(s0)
    80003c3c:	dfe1                	beqz	a5,80003c14 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c3e:	fc240593          	addi	a1,s0,-62
    80003c42:	854e                	mv	a0,s3
    80003c44:	00000097          	auipc	ra,0x0
    80003c48:	f6c080e7          	jalr	-148(ra) # 80003bb0 <namecmp>
    80003c4c:	f561                	bnez	a0,80003c14 <dirlookup+0x4a>
      if(poff)
    80003c4e:	000a0463          	beqz	s4,80003c56 <dirlookup+0x8c>
        *poff = off;
    80003c52:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c56:	fc045583          	lhu	a1,-64(s0)
    80003c5a:	00092503          	lw	a0,0(s2)
    80003c5e:	fffff097          	auipc	ra,0xfffff
    80003c62:	752080e7          	jalr	1874(ra) # 800033b0 <iget>
    80003c66:	a011                	j	80003c6a <dirlookup+0xa0>
  return 0;
    80003c68:	4501                	li	a0,0
}
    80003c6a:	70e2                	ld	ra,56(sp)
    80003c6c:	7442                	ld	s0,48(sp)
    80003c6e:	74a2                	ld	s1,40(sp)
    80003c70:	7902                	ld	s2,32(sp)
    80003c72:	69e2                	ld	s3,24(sp)
    80003c74:	6a42                	ld	s4,16(sp)
    80003c76:	6121                	addi	sp,sp,64
    80003c78:	8082                	ret

0000000080003c7a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c7a:	711d                	addi	sp,sp,-96
    80003c7c:	ec86                	sd	ra,88(sp)
    80003c7e:	e8a2                	sd	s0,80(sp)
    80003c80:	e4a6                	sd	s1,72(sp)
    80003c82:	e0ca                	sd	s2,64(sp)
    80003c84:	fc4e                	sd	s3,56(sp)
    80003c86:	f852                	sd	s4,48(sp)
    80003c88:	f456                	sd	s5,40(sp)
    80003c8a:	f05a                	sd	s6,32(sp)
    80003c8c:	ec5e                	sd	s7,24(sp)
    80003c8e:	e862                	sd	s8,16(sp)
    80003c90:	e466                	sd	s9,8(sp)
    80003c92:	e06a                	sd	s10,0(sp)
    80003c94:	1080                	addi	s0,sp,96
    80003c96:	84aa                	mv	s1,a0
    80003c98:	8b2e                	mv	s6,a1
    80003c9a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c9c:	00054703          	lbu	a4,0(a0)
    80003ca0:	02f00793          	li	a5,47
    80003ca4:	02f70363          	beq	a4,a5,80003cca <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ca8:	ffffe097          	auipc	ra,0xffffe
    80003cac:	d6e080e7          	jalr	-658(ra) # 80001a16 <myproc>
    80003cb0:	15053503          	ld	a0,336(a0)
    80003cb4:	00000097          	auipc	ra,0x0
    80003cb8:	9f4080e7          	jalr	-1548(ra) # 800036a8 <idup>
    80003cbc:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003cbe:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003cc2:	4cb5                	li	s9,13
  len = path - s;
    80003cc4:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cc6:	4c05                	li	s8,1
    80003cc8:	a87d                	j	80003d86 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003cca:	4585                	li	a1,1
    80003ccc:	4505                	li	a0,1
    80003cce:	fffff097          	auipc	ra,0xfffff
    80003cd2:	6e2080e7          	jalr	1762(ra) # 800033b0 <iget>
    80003cd6:	8a2a                	mv	s4,a0
    80003cd8:	b7dd                	j	80003cbe <namex+0x44>
      iunlockput(ip);
    80003cda:	8552                	mv	a0,s4
    80003cdc:	00000097          	auipc	ra,0x0
    80003ce0:	c6c080e7          	jalr	-916(ra) # 80003948 <iunlockput>
      return 0;
    80003ce4:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ce6:	8552                	mv	a0,s4
    80003ce8:	60e6                	ld	ra,88(sp)
    80003cea:	6446                	ld	s0,80(sp)
    80003cec:	64a6                	ld	s1,72(sp)
    80003cee:	6906                	ld	s2,64(sp)
    80003cf0:	79e2                	ld	s3,56(sp)
    80003cf2:	7a42                	ld	s4,48(sp)
    80003cf4:	7aa2                	ld	s5,40(sp)
    80003cf6:	7b02                	ld	s6,32(sp)
    80003cf8:	6be2                	ld	s7,24(sp)
    80003cfa:	6c42                	ld	s8,16(sp)
    80003cfc:	6ca2                	ld	s9,8(sp)
    80003cfe:	6d02                	ld	s10,0(sp)
    80003d00:	6125                	addi	sp,sp,96
    80003d02:	8082                	ret
      iunlock(ip);
    80003d04:	8552                	mv	a0,s4
    80003d06:	00000097          	auipc	ra,0x0
    80003d0a:	aa2080e7          	jalr	-1374(ra) # 800037a8 <iunlock>
      return ip;
    80003d0e:	bfe1                	j	80003ce6 <namex+0x6c>
      iunlockput(ip);
    80003d10:	8552                	mv	a0,s4
    80003d12:	00000097          	auipc	ra,0x0
    80003d16:	c36080e7          	jalr	-970(ra) # 80003948 <iunlockput>
      return 0;
    80003d1a:	8a4e                	mv	s4,s3
    80003d1c:	b7e9                	j	80003ce6 <namex+0x6c>
  len = path - s;
    80003d1e:	40998633          	sub	a2,s3,s1
    80003d22:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003d26:	09acd863          	bge	s9,s10,80003db6 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003d2a:	4639                	li	a2,14
    80003d2c:	85a6                	mv	a1,s1
    80003d2e:	8556                	mv	a0,s5
    80003d30:	ffffd097          	auipc	ra,0xffffd
    80003d34:	ff8080e7          	jalr	-8(ra) # 80000d28 <memmove>
    80003d38:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d3a:	0004c783          	lbu	a5,0(s1)
    80003d3e:	01279763          	bne	a5,s2,80003d4c <namex+0xd2>
    path++;
    80003d42:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d44:	0004c783          	lbu	a5,0(s1)
    80003d48:	ff278de3          	beq	a5,s2,80003d42 <namex+0xc8>
    ilock(ip);
    80003d4c:	8552                	mv	a0,s4
    80003d4e:	00000097          	auipc	ra,0x0
    80003d52:	998080e7          	jalr	-1640(ra) # 800036e6 <ilock>
    if(ip->type != T_DIR){
    80003d56:	044a1783          	lh	a5,68(s4)
    80003d5a:	f98790e3          	bne	a5,s8,80003cda <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003d5e:	000b0563          	beqz	s6,80003d68 <namex+0xee>
    80003d62:	0004c783          	lbu	a5,0(s1)
    80003d66:	dfd9                	beqz	a5,80003d04 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d68:	865e                	mv	a2,s7
    80003d6a:	85d6                	mv	a1,s5
    80003d6c:	8552                	mv	a0,s4
    80003d6e:	00000097          	auipc	ra,0x0
    80003d72:	e5c080e7          	jalr	-420(ra) # 80003bca <dirlookup>
    80003d76:	89aa                	mv	s3,a0
    80003d78:	dd41                	beqz	a0,80003d10 <namex+0x96>
    iunlockput(ip);
    80003d7a:	8552                	mv	a0,s4
    80003d7c:	00000097          	auipc	ra,0x0
    80003d80:	bcc080e7          	jalr	-1076(ra) # 80003948 <iunlockput>
    ip = next;
    80003d84:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d86:	0004c783          	lbu	a5,0(s1)
    80003d8a:	01279763          	bne	a5,s2,80003d98 <namex+0x11e>
    path++;
    80003d8e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d90:	0004c783          	lbu	a5,0(s1)
    80003d94:	ff278de3          	beq	a5,s2,80003d8e <namex+0x114>
  if(*path == 0)
    80003d98:	cb9d                	beqz	a5,80003dce <namex+0x154>
  while(*path != '/' && *path != 0)
    80003d9a:	0004c783          	lbu	a5,0(s1)
    80003d9e:	89a6                	mv	s3,s1
  len = path - s;
    80003da0:	8d5e                	mv	s10,s7
    80003da2:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003da4:	01278963          	beq	a5,s2,80003db6 <namex+0x13c>
    80003da8:	dbbd                	beqz	a5,80003d1e <namex+0xa4>
    path++;
    80003daa:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003dac:	0009c783          	lbu	a5,0(s3)
    80003db0:	ff279ce3          	bne	a5,s2,80003da8 <namex+0x12e>
    80003db4:	b7ad                	j	80003d1e <namex+0xa4>
    memmove(name, s, len);
    80003db6:	2601                	sext.w	a2,a2
    80003db8:	85a6                	mv	a1,s1
    80003dba:	8556                	mv	a0,s5
    80003dbc:	ffffd097          	auipc	ra,0xffffd
    80003dc0:	f6c080e7          	jalr	-148(ra) # 80000d28 <memmove>
    name[len] = 0;
    80003dc4:	9d56                	add	s10,s10,s5
    80003dc6:	000d0023          	sb	zero,0(s10)
    80003dca:	84ce                	mv	s1,s3
    80003dcc:	b7bd                	j	80003d3a <namex+0xc0>
  if(nameiparent){
    80003dce:	f00b0ce3          	beqz	s6,80003ce6 <namex+0x6c>
    iput(ip);
    80003dd2:	8552                	mv	a0,s4
    80003dd4:	00000097          	auipc	ra,0x0
    80003dd8:	acc080e7          	jalr	-1332(ra) # 800038a0 <iput>
    return 0;
    80003ddc:	4a01                	li	s4,0
    80003dde:	b721                	j	80003ce6 <namex+0x6c>

0000000080003de0 <dirlink>:
{
    80003de0:	7139                	addi	sp,sp,-64
    80003de2:	fc06                	sd	ra,56(sp)
    80003de4:	f822                	sd	s0,48(sp)
    80003de6:	f426                	sd	s1,40(sp)
    80003de8:	f04a                	sd	s2,32(sp)
    80003dea:	ec4e                	sd	s3,24(sp)
    80003dec:	e852                	sd	s4,16(sp)
    80003dee:	0080                	addi	s0,sp,64
    80003df0:	892a                	mv	s2,a0
    80003df2:	8a2e                	mv	s4,a1
    80003df4:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003df6:	4601                	li	a2,0
    80003df8:	00000097          	auipc	ra,0x0
    80003dfc:	dd2080e7          	jalr	-558(ra) # 80003bca <dirlookup>
    80003e00:	e93d                	bnez	a0,80003e76 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e02:	04c92483          	lw	s1,76(s2)
    80003e06:	c49d                	beqz	s1,80003e34 <dirlink+0x54>
    80003e08:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e0a:	4741                	li	a4,16
    80003e0c:	86a6                	mv	a3,s1
    80003e0e:	fc040613          	addi	a2,s0,-64
    80003e12:	4581                	li	a1,0
    80003e14:	854a                	mv	a0,s2
    80003e16:	00000097          	auipc	ra,0x0
    80003e1a:	b84080e7          	jalr	-1148(ra) # 8000399a <readi>
    80003e1e:	47c1                	li	a5,16
    80003e20:	06f51163          	bne	a0,a5,80003e82 <dirlink+0xa2>
    if(de.inum == 0)
    80003e24:	fc045783          	lhu	a5,-64(s0)
    80003e28:	c791                	beqz	a5,80003e34 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e2a:	24c1                	addiw	s1,s1,16
    80003e2c:	04c92783          	lw	a5,76(s2)
    80003e30:	fcf4ede3          	bltu	s1,a5,80003e0a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e34:	4639                	li	a2,14
    80003e36:	85d2                	mv	a1,s4
    80003e38:	fc240513          	addi	a0,s0,-62
    80003e3c:	ffffd097          	auipc	ra,0xffffd
    80003e40:	f9c080e7          	jalr	-100(ra) # 80000dd8 <strncpy>
  de.inum = inum;
    80003e44:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e48:	4741                	li	a4,16
    80003e4a:	86a6                	mv	a3,s1
    80003e4c:	fc040613          	addi	a2,s0,-64
    80003e50:	4581                	li	a1,0
    80003e52:	854a                	mv	a0,s2
    80003e54:	00000097          	auipc	ra,0x0
    80003e58:	c3e080e7          	jalr	-962(ra) # 80003a92 <writei>
    80003e5c:	872a                	mv	a4,a0
    80003e5e:	47c1                	li	a5,16
  return 0;
    80003e60:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e62:	02f71863          	bne	a4,a5,80003e92 <dirlink+0xb2>
}
    80003e66:	70e2                	ld	ra,56(sp)
    80003e68:	7442                	ld	s0,48(sp)
    80003e6a:	74a2                	ld	s1,40(sp)
    80003e6c:	7902                	ld	s2,32(sp)
    80003e6e:	69e2                	ld	s3,24(sp)
    80003e70:	6a42                	ld	s4,16(sp)
    80003e72:	6121                	addi	sp,sp,64
    80003e74:	8082                	ret
    iput(ip);
    80003e76:	00000097          	auipc	ra,0x0
    80003e7a:	a2a080e7          	jalr	-1494(ra) # 800038a0 <iput>
    return -1;
    80003e7e:	557d                	li	a0,-1
    80003e80:	b7dd                	j	80003e66 <dirlink+0x86>
      panic("dirlink read");
    80003e82:	00005517          	auipc	a0,0x5
    80003e86:	88e50513          	addi	a0,a0,-1906 # 80008710 <syscalls+0x248>
    80003e8a:	ffffc097          	auipc	ra,0xffffc
    80003e8e:	6b0080e7          	jalr	1712(ra) # 8000053a <panic>
    panic("dirlink");
    80003e92:	00005517          	auipc	a0,0x5
    80003e96:	98e50513          	addi	a0,a0,-1650 # 80008820 <syscalls+0x358>
    80003e9a:	ffffc097          	auipc	ra,0xffffc
    80003e9e:	6a0080e7          	jalr	1696(ra) # 8000053a <panic>

0000000080003ea2 <namei>:

struct inode*
namei(char *path)
{
    80003ea2:	1101                	addi	sp,sp,-32
    80003ea4:	ec06                	sd	ra,24(sp)
    80003ea6:	e822                	sd	s0,16(sp)
    80003ea8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003eaa:	fe040613          	addi	a2,s0,-32
    80003eae:	4581                	li	a1,0
    80003eb0:	00000097          	auipc	ra,0x0
    80003eb4:	dca080e7          	jalr	-566(ra) # 80003c7a <namex>
}
    80003eb8:	60e2                	ld	ra,24(sp)
    80003eba:	6442                	ld	s0,16(sp)
    80003ebc:	6105                	addi	sp,sp,32
    80003ebe:	8082                	ret

0000000080003ec0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ec0:	1141                	addi	sp,sp,-16
    80003ec2:	e406                	sd	ra,8(sp)
    80003ec4:	e022                	sd	s0,0(sp)
    80003ec6:	0800                	addi	s0,sp,16
    80003ec8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003eca:	4585                	li	a1,1
    80003ecc:	00000097          	auipc	ra,0x0
    80003ed0:	dae080e7          	jalr	-594(ra) # 80003c7a <namex>
}
    80003ed4:	60a2                	ld	ra,8(sp)
    80003ed6:	6402                	ld	s0,0(sp)
    80003ed8:	0141                	addi	sp,sp,16
    80003eda:	8082                	ret

0000000080003edc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003edc:	1101                	addi	sp,sp,-32
    80003ede:	ec06                	sd	ra,24(sp)
    80003ee0:	e822                	sd	s0,16(sp)
    80003ee2:	e426                	sd	s1,8(sp)
    80003ee4:	e04a                	sd	s2,0(sp)
    80003ee6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ee8:	0001d917          	auipc	s2,0x1d
    80003eec:	38890913          	addi	s2,s2,904 # 80021270 <log>
    80003ef0:	01892583          	lw	a1,24(s2)
    80003ef4:	02892503          	lw	a0,40(s2)
    80003ef8:	fffff097          	auipc	ra,0xfffff
    80003efc:	fec080e7          	jalr	-20(ra) # 80002ee4 <bread>
    80003f00:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f02:	02c92683          	lw	a3,44(s2)
    80003f06:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f08:	02d05863          	blez	a3,80003f38 <write_head+0x5c>
    80003f0c:	0001d797          	auipc	a5,0x1d
    80003f10:	39478793          	addi	a5,a5,916 # 800212a0 <log+0x30>
    80003f14:	05c50713          	addi	a4,a0,92
    80003f18:	36fd                	addiw	a3,a3,-1
    80003f1a:	02069613          	slli	a2,a3,0x20
    80003f1e:	01e65693          	srli	a3,a2,0x1e
    80003f22:	0001d617          	auipc	a2,0x1d
    80003f26:	38260613          	addi	a2,a2,898 # 800212a4 <log+0x34>
    80003f2a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f2c:	4390                	lw	a2,0(a5)
    80003f2e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f30:	0791                	addi	a5,a5,4
    80003f32:	0711                	addi	a4,a4,4
    80003f34:	fed79ce3          	bne	a5,a3,80003f2c <write_head+0x50>
  }
  bwrite(buf);
    80003f38:	8526                	mv	a0,s1
    80003f3a:	fffff097          	auipc	ra,0xfffff
    80003f3e:	09c080e7          	jalr	156(ra) # 80002fd6 <bwrite>
  brelse(buf);
    80003f42:	8526                	mv	a0,s1
    80003f44:	fffff097          	auipc	ra,0xfffff
    80003f48:	0d0080e7          	jalr	208(ra) # 80003014 <brelse>
}
    80003f4c:	60e2                	ld	ra,24(sp)
    80003f4e:	6442                	ld	s0,16(sp)
    80003f50:	64a2                	ld	s1,8(sp)
    80003f52:	6902                	ld	s2,0(sp)
    80003f54:	6105                	addi	sp,sp,32
    80003f56:	8082                	ret

0000000080003f58 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f58:	0001d797          	auipc	a5,0x1d
    80003f5c:	3447a783          	lw	a5,836(a5) # 8002129c <log+0x2c>
    80003f60:	0af05d63          	blez	a5,8000401a <install_trans+0xc2>
{
    80003f64:	7139                	addi	sp,sp,-64
    80003f66:	fc06                	sd	ra,56(sp)
    80003f68:	f822                	sd	s0,48(sp)
    80003f6a:	f426                	sd	s1,40(sp)
    80003f6c:	f04a                	sd	s2,32(sp)
    80003f6e:	ec4e                	sd	s3,24(sp)
    80003f70:	e852                	sd	s4,16(sp)
    80003f72:	e456                	sd	s5,8(sp)
    80003f74:	e05a                	sd	s6,0(sp)
    80003f76:	0080                	addi	s0,sp,64
    80003f78:	8b2a                	mv	s6,a0
    80003f7a:	0001da97          	auipc	s5,0x1d
    80003f7e:	326a8a93          	addi	s5,s5,806 # 800212a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f82:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f84:	0001d997          	auipc	s3,0x1d
    80003f88:	2ec98993          	addi	s3,s3,748 # 80021270 <log>
    80003f8c:	a00d                	j	80003fae <install_trans+0x56>
    brelse(lbuf);
    80003f8e:	854a                	mv	a0,s2
    80003f90:	fffff097          	auipc	ra,0xfffff
    80003f94:	084080e7          	jalr	132(ra) # 80003014 <brelse>
    brelse(dbuf);
    80003f98:	8526                	mv	a0,s1
    80003f9a:	fffff097          	auipc	ra,0xfffff
    80003f9e:	07a080e7          	jalr	122(ra) # 80003014 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fa2:	2a05                	addiw	s4,s4,1
    80003fa4:	0a91                	addi	s5,s5,4
    80003fa6:	02c9a783          	lw	a5,44(s3)
    80003faa:	04fa5e63          	bge	s4,a5,80004006 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fae:	0189a583          	lw	a1,24(s3)
    80003fb2:	014585bb          	addw	a1,a1,s4
    80003fb6:	2585                	addiw	a1,a1,1
    80003fb8:	0289a503          	lw	a0,40(s3)
    80003fbc:	fffff097          	auipc	ra,0xfffff
    80003fc0:	f28080e7          	jalr	-216(ra) # 80002ee4 <bread>
    80003fc4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fc6:	000aa583          	lw	a1,0(s5)
    80003fca:	0289a503          	lw	a0,40(s3)
    80003fce:	fffff097          	auipc	ra,0xfffff
    80003fd2:	f16080e7          	jalr	-234(ra) # 80002ee4 <bread>
    80003fd6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003fd8:	40000613          	li	a2,1024
    80003fdc:	05890593          	addi	a1,s2,88
    80003fe0:	05850513          	addi	a0,a0,88
    80003fe4:	ffffd097          	auipc	ra,0xffffd
    80003fe8:	d44080e7          	jalr	-700(ra) # 80000d28 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fec:	8526                	mv	a0,s1
    80003fee:	fffff097          	auipc	ra,0xfffff
    80003ff2:	fe8080e7          	jalr	-24(ra) # 80002fd6 <bwrite>
    if(recovering == 0)
    80003ff6:	f80b1ce3          	bnez	s6,80003f8e <install_trans+0x36>
      bunpin(dbuf);
    80003ffa:	8526                	mv	a0,s1
    80003ffc:	fffff097          	auipc	ra,0xfffff
    80004000:	0f2080e7          	jalr	242(ra) # 800030ee <bunpin>
    80004004:	b769                	j	80003f8e <install_trans+0x36>
}
    80004006:	70e2                	ld	ra,56(sp)
    80004008:	7442                	ld	s0,48(sp)
    8000400a:	74a2                	ld	s1,40(sp)
    8000400c:	7902                	ld	s2,32(sp)
    8000400e:	69e2                	ld	s3,24(sp)
    80004010:	6a42                	ld	s4,16(sp)
    80004012:	6aa2                	ld	s5,8(sp)
    80004014:	6b02                	ld	s6,0(sp)
    80004016:	6121                	addi	sp,sp,64
    80004018:	8082                	ret
    8000401a:	8082                	ret

000000008000401c <initlog>:
{
    8000401c:	7179                	addi	sp,sp,-48
    8000401e:	f406                	sd	ra,40(sp)
    80004020:	f022                	sd	s0,32(sp)
    80004022:	ec26                	sd	s1,24(sp)
    80004024:	e84a                	sd	s2,16(sp)
    80004026:	e44e                	sd	s3,8(sp)
    80004028:	1800                	addi	s0,sp,48
    8000402a:	892a                	mv	s2,a0
    8000402c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000402e:	0001d497          	auipc	s1,0x1d
    80004032:	24248493          	addi	s1,s1,578 # 80021270 <log>
    80004036:	00004597          	auipc	a1,0x4
    8000403a:	6ea58593          	addi	a1,a1,1770 # 80008720 <syscalls+0x258>
    8000403e:	8526                	mv	a0,s1
    80004040:	ffffd097          	auipc	ra,0xffffd
    80004044:	b00080e7          	jalr	-1280(ra) # 80000b40 <initlock>
  log.start = sb->logstart;
    80004048:	0149a583          	lw	a1,20(s3)
    8000404c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000404e:	0109a783          	lw	a5,16(s3)
    80004052:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004054:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004058:	854a                	mv	a0,s2
    8000405a:	fffff097          	auipc	ra,0xfffff
    8000405e:	e8a080e7          	jalr	-374(ra) # 80002ee4 <bread>
  log.lh.n = lh->n;
    80004062:	4d34                	lw	a3,88(a0)
    80004064:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004066:	02d05663          	blez	a3,80004092 <initlog+0x76>
    8000406a:	05c50793          	addi	a5,a0,92
    8000406e:	0001d717          	auipc	a4,0x1d
    80004072:	23270713          	addi	a4,a4,562 # 800212a0 <log+0x30>
    80004076:	36fd                	addiw	a3,a3,-1
    80004078:	02069613          	slli	a2,a3,0x20
    8000407c:	01e65693          	srli	a3,a2,0x1e
    80004080:	06050613          	addi	a2,a0,96
    80004084:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004086:	4390                	lw	a2,0(a5)
    80004088:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000408a:	0791                	addi	a5,a5,4
    8000408c:	0711                	addi	a4,a4,4
    8000408e:	fed79ce3          	bne	a5,a3,80004086 <initlog+0x6a>
  brelse(buf);
    80004092:	fffff097          	auipc	ra,0xfffff
    80004096:	f82080e7          	jalr	-126(ra) # 80003014 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000409a:	4505                	li	a0,1
    8000409c:	00000097          	auipc	ra,0x0
    800040a0:	ebc080e7          	jalr	-324(ra) # 80003f58 <install_trans>
  log.lh.n = 0;
    800040a4:	0001d797          	auipc	a5,0x1d
    800040a8:	1e07ac23          	sw	zero,504(a5) # 8002129c <log+0x2c>
  write_head(); // clear the log
    800040ac:	00000097          	auipc	ra,0x0
    800040b0:	e30080e7          	jalr	-464(ra) # 80003edc <write_head>
}
    800040b4:	70a2                	ld	ra,40(sp)
    800040b6:	7402                	ld	s0,32(sp)
    800040b8:	64e2                	ld	s1,24(sp)
    800040ba:	6942                	ld	s2,16(sp)
    800040bc:	69a2                	ld	s3,8(sp)
    800040be:	6145                	addi	sp,sp,48
    800040c0:	8082                	ret

00000000800040c2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040c2:	1101                	addi	sp,sp,-32
    800040c4:	ec06                	sd	ra,24(sp)
    800040c6:	e822                	sd	s0,16(sp)
    800040c8:	e426                	sd	s1,8(sp)
    800040ca:	e04a                	sd	s2,0(sp)
    800040cc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040ce:	0001d517          	auipc	a0,0x1d
    800040d2:	1a250513          	addi	a0,a0,418 # 80021270 <log>
    800040d6:	ffffd097          	auipc	ra,0xffffd
    800040da:	afa080e7          	jalr	-1286(ra) # 80000bd0 <acquire>
  while(1){
    if(log.committing){
    800040de:	0001d497          	auipc	s1,0x1d
    800040e2:	19248493          	addi	s1,s1,402 # 80021270 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040e6:	4979                	li	s2,30
    800040e8:	a039                	j	800040f6 <begin_op+0x34>
      sleep(&log, &log.lock);
    800040ea:	85a6                	mv	a1,s1
    800040ec:	8526                	mv	a0,s1
    800040ee:	ffffe097          	auipc	ra,0xffffe
    800040f2:	fec080e7          	jalr	-20(ra) # 800020da <sleep>
    if(log.committing){
    800040f6:	50dc                	lw	a5,36(s1)
    800040f8:	fbed                	bnez	a5,800040ea <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040fa:	5098                	lw	a4,32(s1)
    800040fc:	2705                	addiw	a4,a4,1
    800040fe:	0007069b          	sext.w	a3,a4
    80004102:	0027179b          	slliw	a5,a4,0x2
    80004106:	9fb9                	addw	a5,a5,a4
    80004108:	0017979b          	slliw	a5,a5,0x1
    8000410c:	54d8                	lw	a4,44(s1)
    8000410e:	9fb9                	addw	a5,a5,a4
    80004110:	00f95963          	bge	s2,a5,80004122 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004114:	85a6                	mv	a1,s1
    80004116:	8526                	mv	a0,s1
    80004118:	ffffe097          	auipc	ra,0xffffe
    8000411c:	fc2080e7          	jalr	-62(ra) # 800020da <sleep>
    80004120:	bfd9                	j	800040f6 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004122:	0001d517          	auipc	a0,0x1d
    80004126:	14e50513          	addi	a0,a0,334 # 80021270 <log>
    8000412a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000412c:	ffffd097          	auipc	ra,0xffffd
    80004130:	b58080e7          	jalr	-1192(ra) # 80000c84 <release>
      break;
    }
  }
}
    80004134:	60e2                	ld	ra,24(sp)
    80004136:	6442                	ld	s0,16(sp)
    80004138:	64a2                	ld	s1,8(sp)
    8000413a:	6902                	ld	s2,0(sp)
    8000413c:	6105                	addi	sp,sp,32
    8000413e:	8082                	ret

0000000080004140 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004140:	7139                	addi	sp,sp,-64
    80004142:	fc06                	sd	ra,56(sp)
    80004144:	f822                	sd	s0,48(sp)
    80004146:	f426                	sd	s1,40(sp)
    80004148:	f04a                	sd	s2,32(sp)
    8000414a:	ec4e                	sd	s3,24(sp)
    8000414c:	e852                	sd	s4,16(sp)
    8000414e:	e456                	sd	s5,8(sp)
    80004150:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004152:	0001d497          	auipc	s1,0x1d
    80004156:	11e48493          	addi	s1,s1,286 # 80021270 <log>
    8000415a:	8526                	mv	a0,s1
    8000415c:	ffffd097          	auipc	ra,0xffffd
    80004160:	a74080e7          	jalr	-1420(ra) # 80000bd0 <acquire>
  log.outstanding -= 1;
    80004164:	509c                	lw	a5,32(s1)
    80004166:	37fd                	addiw	a5,a5,-1
    80004168:	0007891b          	sext.w	s2,a5
    8000416c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000416e:	50dc                	lw	a5,36(s1)
    80004170:	e7b9                	bnez	a5,800041be <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004172:	04091e63          	bnez	s2,800041ce <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004176:	0001d497          	auipc	s1,0x1d
    8000417a:	0fa48493          	addi	s1,s1,250 # 80021270 <log>
    8000417e:	4785                	li	a5,1
    80004180:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004182:	8526                	mv	a0,s1
    80004184:	ffffd097          	auipc	ra,0xffffd
    80004188:	b00080e7          	jalr	-1280(ra) # 80000c84 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000418c:	54dc                	lw	a5,44(s1)
    8000418e:	06f04763          	bgtz	a5,800041fc <end_op+0xbc>
    acquire(&log.lock);
    80004192:	0001d497          	auipc	s1,0x1d
    80004196:	0de48493          	addi	s1,s1,222 # 80021270 <log>
    8000419a:	8526                	mv	a0,s1
    8000419c:	ffffd097          	auipc	ra,0xffffd
    800041a0:	a34080e7          	jalr	-1484(ra) # 80000bd0 <acquire>
    log.committing = 0;
    800041a4:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800041a8:	8526                	mv	a0,s1
    800041aa:	ffffe097          	auipc	ra,0xffffe
    800041ae:	0bc080e7          	jalr	188(ra) # 80002266 <wakeup>
    release(&log.lock);
    800041b2:	8526                	mv	a0,s1
    800041b4:	ffffd097          	auipc	ra,0xffffd
    800041b8:	ad0080e7          	jalr	-1328(ra) # 80000c84 <release>
}
    800041bc:	a03d                	j	800041ea <end_op+0xaa>
    panic("log.committing");
    800041be:	00004517          	auipc	a0,0x4
    800041c2:	56a50513          	addi	a0,a0,1386 # 80008728 <syscalls+0x260>
    800041c6:	ffffc097          	auipc	ra,0xffffc
    800041ca:	374080e7          	jalr	884(ra) # 8000053a <panic>
    wakeup(&log);
    800041ce:	0001d497          	auipc	s1,0x1d
    800041d2:	0a248493          	addi	s1,s1,162 # 80021270 <log>
    800041d6:	8526                	mv	a0,s1
    800041d8:	ffffe097          	auipc	ra,0xffffe
    800041dc:	08e080e7          	jalr	142(ra) # 80002266 <wakeup>
  release(&log.lock);
    800041e0:	8526                	mv	a0,s1
    800041e2:	ffffd097          	auipc	ra,0xffffd
    800041e6:	aa2080e7          	jalr	-1374(ra) # 80000c84 <release>
}
    800041ea:	70e2                	ld	ra,56(sp)
    800041ec:	7442                	ld	s0,48(sp)
    800041ee:	74a2                	ld	s1,40(sp)
    800041f0:	7902                	ld	s2,32(sp)
    800041f2:	69e2                	ld	s3,24(sp)
    800041f4:	6a42                	ld	s4,16(sp)
    800041f6:	6aa2                	ld	s5,8(sp)
    800041f8:	6121                	addi	sp,sp,64
    800041fa:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041fc:	0001da97          	auipc	s5,0x1d
    80004200:	0a4a8a93          	addi	s5,s5,164 # 800212a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004204:	0001da17          	auipc	s4,0x1d
    80004208:	06ca0a13          	addi	s4,s4,108 # 80021270 <log>
    8000420c:	018a2583          	lw	a1,24(s4)
    80004210:	012585bb          	addw	a1,a1,s2
    80004214:	2585                	addiw	a1,a1,1
    80004216:	028a2503          	lw	a0,40(s4)
    8000421a:	fffff097          	auipc	ra,0xfffff
    8000421e:	cca080e7          	jalr	-822(ra) # 80002ee4 <bread>
    80004222:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004224:	000aa583          	lw	a1,0(s5)
    80004228:	028a2503          	lw	a0,40(s4)
    8000422c:	fffff097          	auipc	ra,0xfffff
    80004230:	cb8080e7          	jalr	-840(ra) # 80002ee4 <bread>
    80004234:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004236:	40000613          	li	a2,1024
    8000423a:	05850593          	addi	a1,a0,88
    8000423e:	05848513          	addi	a0,s1,88
    80004242:	ffffd097          	auipc	ra,0xffffd
    80004246:	ae6080e7          	jalr	-1306(ra) # 80000d28 <memmove>
    bwrite(to);  // write the log
    8000424a:	8526                	mv	a0,s1
    8000424c:	fffff097          	auipc	ra,0xfffff
    80004250:	d8a080e7          	jalr	-630(ra) # 80002fd6 <bwrite>
    brelse(from);
    80004254:	854e                	mv	a0,s3
    80004256:	fffff097          	auipc	ra,0xfffff
    8000425a:	dbe080e7          	jalr	-578(ra) # 80003014 <brelse>
    brelse(to);
    8000425e:	8526                	mv	a0,s1
    80004260:	fffff097          	auipc	ra,0xfffff
    80004264:	db4080e7          	jalr	-588(ra) # 80003014 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004268:	2905                	addiw	s2,s2,1
    8000426a:	0a91                	addi	s5,s5,4
    8000426c:	02ca2783          	lw	a5,44(s4)
    80004270:	f8f94ee3          	blt	s2,a5,8000420c <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004274:	00000097          	auipc	ra,0x0
    80004278:	c68080e7          	jalr	-920(ra) # 80003edc <write_head>
    install_trans(0); // Now install writes to home locations
    8000427c:	4501                	li	a0,0
    8000427e:	00000097          	auipc	ra,0x0
    80004282:	cda080e7          	jalr	-806(ra) # 80003f58 <install_trans>
    log.lh.n = 0;
    80004286:	0001d797          	auipc	a5,0x1d
    8000428a:	0007ab23          	sw	zero,22(a5) # 8002129c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000428e:	00000097          	auipc	ra,0x0
    80004292:	c4e080e7          	jalr	-946(ra) # 80003edc <write_head>
    80004296:	bdf5                	j	80004192 <end_op+0x52>

0000000080004298 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004298:	1101                	addi	sp,sp,-32
    8000429a:	ec06                	sd	ra,24(sp)
    8000429c:	e822                	sd	s0,16(sp)
    8000429e:	e426                	sd	s1,8(sp)
    800042a0:	e04a                	sd	s2,0(sp)
    800042a2:	1000                	addi	s0,sp,32
    800042a4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800042a6:	0001d917          	auipc	s2,0x1d
    800042aa:	fca90913          	addi	s2,s2,-54 # 80021270 <log>
    800042ae:	854a                	mv	a0,s2
    800042b0:	ffffd097          	auipc	ra,0xffffd
    800042b4:	920080e7          	jalr	-1760(ra) # 80000bd0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042b8:	02c92603          	lw	a2,44(s2)
    800042bc:	47f5                	li	a5,29
    800042be:	06c7c563          	blt	a5,a2,80004328 <log_write+0x90>
    800042c2:	0001d797          	auipc	a5,0x1d
    800042c6:	fca7a783          	lw	a5,-54(a5) # 8002128c <log+0x1c>
    800042ca:	37fd                	addiw	a5,a5,-1
    800042cc:	04f65e63          	bge	a2,a5,80004328 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042d0:	0001d797          	auipc	a5,0x1d
    800042d4:	fc07a783          	lw	a5,-64(a5) # 80021290 <log+0x20>
    800042d8:	06f05063          	blez	a5,80004338 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042dc:	4781                	li	a5,0
    800042de:	06c05563          	blez	a2,80004348 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042e2:	44cc                	lw	a1,12(s1)
    800042e4:	0001d717          	auipc	a4,0x1d
    800042e8:	fbc70713          	addi	a4,a4,-68 # 800212a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800042ec:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042ee:	4314                	lw	a3,0(a4)
    800042f0:	04b68c63          	beq	a3,a1,80004348 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800042f4:	2785                	addiw	a5,a5,1
    800042f6:	0711                	addi	a4,a4,4
    800042f8:	fef61be3          	bne	a2,a5,800042ee <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042fc:	0621                	addi	a2,a2,8
    800042fe:	060a                	slli	a2,a2,0x2
    80004300:	0001d797          	auipc	a5,0x1d
    80004304:	f7078793          	addi	a5,a5,-144 # 80021270 <log>
    80004308:	97b2                	add	a5,a5,a2
    8000430a:	44d8                	lw	a4,12(s1)
    8000430c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000430e:	8526                	mv	a0,s1
    80004310:	fffff097          	auipc	ra,0xfffff
    80004314:	da2080e7          	jalr	-606(ra) # 800030b2 <bpin>
    log.lh.n++;
    80004318:	0001d717          	auipc	a4,0x1d
    8000431c:	f5870713          	addi	a4,a4,-168 # 80021270 <log>
    80004320:	575c                	lw	a5,44(a4)
    80004322:	2785                	addiw	a5,a5,1
    80004324:	d75c                	sw	a5,44(a4)
    80004326:	a82d                	j	80004360 <log_write+0xc8>
    panic("too big a transaction");
    80004328:	00004517          	auipc	a0,0x4
    8000432c:	41050513          	addi	a0,a0,1040 # 80008738 <syscalls+0x270>
    80004330:	ffffc097          	auipc	ra,0xffffc
    80004334:	20a080e7          	jalr	522(ra) # 8000053a <panic>
    panic("log_write outside of trans");
    80004338:	00004517          	auipc	a0,0x4
    8000433c:	41850513          	addi	a0,a0,1048 # 80008750 <syscalls+0x288>
    80004340:	ffffc097          	auipc	ra,0xffffc
    80004344:	1fa080e7          	jalr	506(ra) # 8000053a <panic>
  log.lh.block[i] = b->blockno;
    80004348:	00878693          	addi	a3,a5,8
    8000434c:	068a                	slli	a3,a3,0x2
    8000434e:	0001d717          	auipc	a4,0x1d
    80004352:	f2270713          	addi	a4,a4,-222 # 80021270 <log>
    80004356:	9736                	add	a4,a4,a3
    80004358:	44d4                	lw	a3,12(s1)
    8000435a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000435c:	faf609e3          	beq	a2,a5,8000430e <log_write+0x76>
  }
  release(&log.lock);
    80004360:	0001d517          	auipc	a0,0x1d
    80004364:	f1050513          	addi	a0,a0,-240 # 80021270 <log>
    80004368:	ffffd097          	auipc	ra,0xffffd
    8000436c:	91c080e7          	jalr	-1764(ra) # 80000c84 <release>
}
    80004370:	60e2                	ld	ra,24(sp)
    80004372:	6442                	ld	s0,16(sp)
    80004374:	64a2                	ld	s1,8(sp)
    80004376:	6902                	ld	s2,0(sp)
    80004378:	6105                	addi	sp,sp,32
    8000437a:	8082                	ret

000000008000437c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000437c:	1101                	addi	sp,sp,-32
    8000437e:	ec06                	sd	ra,24(sp)
    80004380:	e822                	sd	s0,16(sp)
    80004382:	e426                	sd	s1,8(sp)
    80004384:	e04a                	sd	s2,0(sp)
    80004386:	1000                	addi	s0,sp,32
    80004388:	84aa                	mv	s1,a0
    8000438a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000438c:	00004597          	auipc	a1,0x4
    80004390:	3e458593          	addi	a1,a1,996 # 80008770 <syscalls+0x2a8>
    80004394:	0521                	addi	a0,a0,8
    80004396:	ffffc097          	auipc	ra,0xffffc
    8000439a:	7aa080e7          	jalr	1962(ra) # 80000b40 <initlock>
  lk->name = name;
    8000439e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043a2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043a6:	0204a423          	sw	zero,40(s1)
}
    800043aa:	60e2                	ld	ra,24(sp)
    800043ac:	6442                	ld	s0,16(sp)
    800043ae:	64a2                	ld	s1,8(sp)
    800043b0:	6902                	ld	s2,0(sp)
    800043b2:	6105                	addi	sp,sp,32
    800043b4:	8082                	ret

00000000800043b6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043b6:	1101                	addi	sp,sp,-32
    800043b8:	ec06                	sd	ra,24(sp)
    800043ba:	e822                	sd	s0,16(sp)
    800043bc:	e426                	sd	s1,8(sp)
    800043be:	e04a                	sd	s2,0(sp)
    800043c0:	1000                	addi	s0,sp,32
    800043c2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043c4:	00850913          	addi	s2,a0,8
    800043c8:	854a                	mv	a0,s2
    800043ca:	ffffd097          	auipc	ra,0xffffd
    800043ce:	806080e7          	jalr	-2042(ra) # 80000bd0 <acquire>
  while (lk->locked) {
    800043d2:	409c                	lw	a5,0(s1)
    800043d4:	cb89                	beqz	a5,800043e6 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043d6:	85ca                	mv	a1,s2
    800043d8:	8526                	mv	a0,s1
    800043da:	ffffe097          	auipc	ra,0xffffe
    800043de:	d00080e7          	jalr	-768(ra) # 800020da <sleep>
  while (lk->locked) {
    800043e2:	409c                	lw	a5,0(s1)
    800043e4:	fbed                	bnez	a5,800043d6 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043e6:	4785                	li	a5,1
    800043e8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043ea:	ffffd097          	auipc	ra,0xffffd
    800043ee:	62c080e7          	jalr	1580(ra) # 80001a16 <myproc>
    800043f2:	591c                	lw	a5,48(a0)
    800043f4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043f6:	854a                	mv	a0,s2
    800043f8:	ffffd097          	auipc	ra,0xffffd
    800043fc:	88c080e7          	jalr	-1908(ra) # 80000c84 <release>
}
    80004400:	60e2                	ld	ra,24(sp)
    80004402:	6442                	ld	s0,16(sp)
    80004404:	64a2                	ld	s1,8(sp)
    80004406:	6902                	ld	s2,0(sp)
    80004408:	6105                	addi	sp,sp,32
    8000440a:	8082                	ret

000000008000440c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000440c:	1101                	addi	sp,sp,-32
    8000440e:	ec06                	sd	ra,24(sp)
    80004410:	e822                	sd	s0,16(sp)
    80004412:	e426                	sd	s1,8(sp)
    80004414:	e04a                	sd	s2,0(sp)
    80004416:	1000                	addi	s0,sp,32
    80004418:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000441a:	00850913          	addi	s2,a0,8
    8000441e:	854a                	mv	a0,s2
    80004420:	ffffc097          	auipc	ra,0xffffc
    80004424:	7b0080e7          	jalr	1968(ra) # 80000bd0 <acquire>
  lk->locked = 0;
    80004428:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000442c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004430:	8526                	mv	a0,s1
    80004432:	ffffe097          	auipc	ra,0xffffe
    80004436:	e34080e7          	jalr	-460(ra) # 80002266 <wakeup>
  release(&lk->lk);
    8000443a:	854a                	mv	a0,s2
    8000443c:	ffffd097          	auipc	ra,0xffffd
    80004440:	848080e7          	jalr	-1976(ra) # 80000c84 <release>
}
    80004444:	60e2                	ld	ra,24(sp)
    80004446:	6442                	ld	s0,16(sp)
    80004448:	64a2                	ld	s1,8(sp)
    8000444a:	6902                	ld	s2,0(sp)
    8000444c:	6105                	addi	sp,sp,32
    8000444e:	8082                	ret

0000000080004450 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004450:	7179                	addi	sp,sp,-48
    80004452:	f406                	sd	ra,40(sp)
    80004454:	f022                	sd	s0,32(sp)
    80004456:	ec26                	sd	s1,24(sp)
    80004458:	e84a                	sd	s2,16(sp)
    8000445a:	e44e                	sd	s3,8(sp)
    8000445c:	1800                	addi	s0,sp,48
    8000445e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004460:	00850913          	addi	s2,a0,8
    80004464:	854a                	mv	a0,s2
    80004466:	ffffc097          	auipc	ra,0xffffc
    8000446a:	76a080e7          	jalr	1898(ra) # 80000bd0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000446e:	409c                	lw	a5,0(s1)
    80004470:	ef99                	bnez	a5,8000448e <holdingsleep+0x3e>
    80004472:	4481                	li	s1,0
  release(&lk->lk);
    80004474:	854a                	mv	a0,s2
    80004476:	ffffd097          	auipc	ra,0xffffd
    8000447a:	80e080e7          	jalr	-2034(ra) # 80000c84 <release>
  return r;
}
    8000447e:	8526                	mv	a0,s1
    80004480:	70a2                	ld	ra,40(sp)
    80004482:	7402                	ld	s0,32(sp)
    80004484:	64e2                	ld	s1,24(sp)
    80004486:	6942                	ld	s2,16(sp)
    80004488:	69a2                	ld	s3,8(sp)
    8000448a:	6145                	addi	sp,sp,48
    8000448c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000448e:	0284a983          	lw	s3,40(s1)
    80004492:	ffffd097          	auipc	ra,0xffffd
    80004496:	584080e7          	jalr	1412(ra) # 80001a16 <myproc>
    8000449a:	5904                	lw	s1,48(a0)
    8000449c:	413484b3          	sub	s1,s1,s3
    800044a0:	0014b493          	seqz	s1,s1
    800044a4:	bfc1                	j	80004474 <holdingsleep+0x24>

00000000800044a6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044a6:	1141                	addi	sp,sp,-16
    800044a8:	e406                	sd	ra,8(sp)
    800044aa:	e022                	sd	s0,0(sp)
    800044ac:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044ae:	00004597          	auipc	a1,0x4
    800044b2:	2d258593          	addi	a1,a1,722 # 80008780 <syscalls+0x2b8>
    800044b6:	0001d517          	auipc	a0,0x1d
    800044ba:	f0250513          	addi	a0,a0,-254 # 800213b8 <ftable>
    800044be:	ffffc097          	auipc	ra,0xffffc
    800044c2:	682080e7          	jalr	1666(ra) # 80000b40 <initlock>
}
    800044c6:	60a2                	ld	ra,8(sp)
    800044c8:	6402                	ld	s0,0(sp)
    800044ca:	0141                	addi	sp,sp,16
    800044cc:	8082                	ret

00000000800044ce <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044ce:	1101                	addi	sp,sp,-32
    800044d0:	ec06                	sd	ra,24(sp)
    800044d2:	e822                	sd	s0,16(sp)
    800044d4:	e426                	sd	s1,8(sp)
    800044d6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044d8:	0001d517          	auipc	a0,0x1d
    800044dc:	ee050513          	addi	a0,a0,-288 # 800213b8 <ftable>
    800044e0:	ffffc097          	auipc	ra,0xffffc
    800044e4:	6f0080e7          	jalr	1776(ra) # 80000bd0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044e8:	0001d497          	auipc	s1,0x1d
    800044ec:	ee848493          	addi	s1,s1,-280 # 800213d0 <ftable+0x18>
    800044f0:	0001e717          	auipc	a4,0x1e
    800044f4:	e8070713          	addi	a4,a4,-384 # 80022370 <ftable+0xfb8>
    if(f->ref == 0){
    800044f8:	40dc                	lw	a5,4(s1)
    800044fa:	cf99                	beqz	a5,80004518 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044fc:	02848493          	addi	s1,s1,40
    80004500:	fee49ce3          	bne	s1,a4,800044f8 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004504:	0001d517          	auipc	a0,0x1d
    80004508:	eb450513          	addi	a0,a0,-332 # 800213b8 <ftable>
    8000450c:	ffffc097          	auipc	ra,0xffffc
    80004510:	778080e7          	jalr	1912(ra) # 80000c84 <release>
  return 0;
    80004514:	4481                	li	s1,0
    80004516:	a819                	j	8000452c <filealloc+0x5e>
      f->ref = 1;
    80004518:	4785                	li	a5,1
    8000451a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000451c:	0001d517          	auipc	a0,0x1d
    80004520:	e9c50513          	addi	a0,a0,-356 # 800213b8 <ftable>
    80004524:	ffffc097          	auipc	ra,0xffffc
    80004528:	760080e7          	jalr	1888(ra) # 80000c84 <release>
}
    8000452c:	8526                	mv	a0,s1
    8000452e:	60e2                	ld	ra,24(sp)
    80004530:	6442                	ld	s0,16(sp)
    80004532:	64a2                	ld	s1,8(sp)
    80004534:	6105                	addi	sp,sp,32
    80004536:	8082                	ret

0000000080004538 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004538:	1101                	addi	sp,sp,-32
    8000453a:	ec06                	sd	ra,24(sp)
    8000453c:	e822                	sd	s0,16(sp)
    8000453e:	e426                	sd	s1,8(sp)
    80004540:	1000                	addi	s0,sp,32
    80004542:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004544:	0001d517          	auipc	a0,0x1d
    80004548:	e7450513          	addi	a0,a0,-396 # 800213b8 <ftable>
    8000454c:	ffffc097          	auipc	ra,0xffffc
    80004550:	684080e7          	jalr	1668(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    80004554:	40dc                	lw	a5,4(s1)
    80004556:	02f05263          	blez	a5,8000457a <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000455a:	2785                	addiw	a5,a5,1
    8000455c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000455e:	0001d517          	auipc	a0,0x1d
    80004562:	e5a50513          	addi	a0,a0,-422 # 800213b8 <ftable>
    80004566:	ffffc097          	auipc	ra,0xffffc
    8000456a:	71e080e7          	jalr	1822(ra) # 80000c84 <release>
  return f;
}
    8000456e:	8526                	mv	a0,s1
    80004570:	60e2                	ld	ra,24(sp)
    80004572:	6442                	ld	s0,16(sp)
    80004574:	64a2                	ld	s1,8(sp)
    80004576:	6105                	addi	sp,sp,32
    80004578:	8082                	ret
    panic("filedup");
    8000457a:	00004517          	auipc	a0,0x4
    8000457e:	20e50513          	addi	a0,a0,526 # 80008788 <syscalls+0x2c0>
    80004582:	ffffc097          	auipc	ra,0xffffc
    80004586:	fb8080e7          	jalr	-72(ra) # 8000053a <panic>

000000008000458a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000458a:	7139                	addi	sp,sp,-64
    8000458c:	fc06                	sd	ra,56(sp)
    8000458e:	f822                	sd	s0,48(sp)
    80004590:	f426                	sd	s1,40(sp)
    80004592:	f04a                	sd	s2,32(sp)
    80004594:	ec4e                	sd	s3,24(sp)
    80004596:	e852                	sd	s4,16(sp)
    80004598:	e456                	sd	s5,8(sp)
    8000459a:	0080                	addi	s0,sp,64
    8000459c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000459e:	0001d517          	auipc	a0,0x1d
    800045a2:	e1a50513          	addi	a0,a0,-486 # 800213b8 <ftable>
    800045a6:	ffffc097          	auipc	ra,0xffffc
    800045aa:	62a080e7          	jalr	1578(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    800045ae:	40dc                	lw	a5,4(s1)
    800045b0:	06f05163          	blez	a5,80004612 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800045b4:	37fd                	addiw	a5,a5,-1
    800045b6:	0007871b          	sext.w	a4,a5
    800045ba:	c0dc                	sw	a5,4(s1)
    800045bc:	06e04363          	bgtz	a4,80004622 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045c0:	0004a903          	lw	s2,0(s1)
    800045c4:	0094ca83          	lbu	s5,9(s1)
    800045c8:	0104ba03          	ld	s4,16(s1)
    800045cc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045d0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045d4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045d8:	0001d517          	auipc	a0,0x1d
    800045dc:	de050513          	addi	a0,a0,-544 # 800213b8 <ftable>
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	6a4080e7          	jalr	1700(ra) # 80000c84 <release>

  if(ff.type == FD_PIPE){
    800045e8:	4785                	li	a5,1
    800045ea:	04f90d63          	beq	s2,a5,80004644 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045ee:	3979                	addiw	s2,s2,-2
    800045f0:	4785                	li	a5,1
    800045f2:	0527e063          	bltu	a5,s2,80004632 <fileclose+0xa8>
    begin_op();
    800045f6:	00000097          	auipc	ra,0x0
    800045fa:	acc080e7          	jalr	-1332(ra) # 800040c2 <begin_op>
    iput(ff.ip);
    800045fe:	854e                	mv	a0,s3
    80004600:	fffff097          	auipc	ra,0xfffff
    80004604:	2a0080e7          	jalr	672(ra) # 800038a0 <iput>
    end_op();
    80004608:	00000097          	auipc	ra,0x0
    8000460c:	b38080e7          	jalr	-1224(ra) # 80004140 <end_op>
    80004610:	a00d                	j	80004632 <fileclose+0xa8>
    panic("fileclose");
    80004612:	00004517          	auipc	a0,0x4
    80004616:	17e50513          	addi	a0,a0,382 # 80008790 <syscalls+0x2c8>
    8000461a:	ffffc097          	auipc	ra,0xffffc
    8000461e:	f20080e7          	jalr	-224(ra) # 8000053a <panic>
    release(&ftable.lock);
    80004622:	0001d517          	auipc	a0,0x1d
    80004626:	d9650513          	addi	a0,a0,-618 # 800213b8 <ftable>
    8000462a:	ffffc097          	auipc	ra,0xffffc
    8000462e:	65a080e7          	jalr	1626(ra) # 80000c84 <release>
  }
}
    80004632:	70e2                	ld	ra,56(sp)
    80004634:	7442                	ld	s0,48(sp)
    80004636:	74a2                	ld	s1,40(sp)
    80004638:	7902                	ld	s2,32(sp)
    8000463a:	69e2                	ld	s3,24(sp)
    8000463c:	6a42                	ld	s4,16(sp)
    8000463e:	6aa2                	ld	s5,8(sp)
    80004640:	6121                	addi	sp,sp,64
    80004642:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004644:	85d6                	mv	a1,s5
    80004646:	8552                	mv	a0,s4
    80004648:	00000097          	auipc	ra,0x0
    8000464c:	34c080e7          	jalr	844(ra) # 80004994 <pipeclose>
    80004650:	b7cd                	j	80004632 <fileclose+0xa8>

0000000080004652 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004652:	715d                	addi	sp,sp,-80
    80004654:	e486                	sd	ra,72(sp)
    80004656:	e0a2                	sd	s0,64(sp)
    80004658:	fc26                	sd	s1,56(sp)
    8000465a:	f84a                	sd	s2,48(sp)
    8000465c:	f44e                	sd	s3,40(sp)
    8000465e:	0880                	addi	s0,sp,80
    80004660:	84aa                	mv	s1,a0
    80004662:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004664:	ffffd097          	auipc	ra,0xffffd
    80004668:	3b2080e7          	jalr	946(ra) # 80001a16 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000466c:	409c                	lw	a5,0(s1)
    8000466e:	37f9                	addiw	a5,a5,-2
    80004670:	4705                	li	a4,1
    80004672:	04f76763          	bltu	a4,a5,800046c0 <filestat+0x6e>
    80004676:	892a                	mv	s2,a0
    ilock(f->ip);
    80004678:	6c88                	ld	a0,24(s1)
    8000467a:	fffff097          	auipc	ra,0xfffff
    8000467e:	06c080e7          	jalr	108(ra) # 800036e6 <ilock>
    stati(f->ip, &st);
    80004682:	fb840593          	addi	a1,s0,-72
    80004686:	6c88                	ld	a0,24(s1)
    80004688:	fffff097          	auipc	ra,0xfffff
    8000468c:	2e8080e7          	jalr	744(ra) # 80003970 <stati>
    iunlock(f->ip);
    80004690:	6c88                	ld	a0,24(s1)
    80004692:	fffff097          	auipc	ra,0xfffff
    80004696:	116080e7          	jalr	278(ra) # 800037a8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000469a:	46e1                	li	a3,24
    8000469c:	fb840613          	addi	a2,s0,-72
    800046a0:	85ce                	mv	a1,s3
    800046a2:	05093503          	ld	a0,80(s2)
    800046a6:	ffffd097          	auipc	ra,0xffffd
    800046aa:	fb4080e7          	jalr	-76(ra) # 8000165a <copyout>
    800046ae:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800046b2:	60a6                	ld	ra,72(sp)
    800046b4:	6406                	ld	s0,64(sp)
    800046b6:	74e2                	ld	s1,56(sp)
    800046b8:	7942                	ld	s2,48(sp)
    800046ba:	79a2                	ld	s3,40(sp)
    800046bc:	6161                	addi	sp,sp,80
    800046be:	8082                	ret
  return -1;
    800046c0:	557d                	li	a0,-1
    800046c2:	bfc5                	j	800046b2 <filestat+0x60>

00000000800046c4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046c4:	7179                	addi	sp,sp,-48
    800046c6:	f406                	sd	ra,40(sp)
    800046c8:	f022                	sd	s0,32(sp)
    800046ca:	ec26                	sd	s1,24(sp)
    800046cc:	e84a                	sd	s2,16(sp)
    800046ce:	e44e                	sd	s3,8(sp)
    800046d0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046d2:	00854783          	lbu	a5,8(a0)
    800046d6:	c3d5                	beqz	a5,8000477a <fileread+0xb6>
    800046d8:	84aa                	mv	s1,a0
    800046da:	89ae                	mv	s3,a1
    800046dc:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046de:	411c                	lw	a5,0(a0)
    800046e0:	4705                	li	a4,1
    800046e2:	04e78963          	beq	a5,a4,80004734 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046e6:	470d                	li	a4,3
    800046e8:	04e78d63          	beq	a5,a4,80004742 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046ec:	4709                	li	a4,2
    800046ee:	06e79e63          	bne	a5,a4,8000476a <fileread+0xa6>
    ilock(f->ip);
    800046f2:	6d08                	ld	a0,24(a0)
    800046f4:	fffff097          	auipc	ra,0xfffff
    800046f8:	ff2080e7          	jalr	-14(ra) # 800036e6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046fc:	874a                	mv	a4,s2
    800046fe:	5094                	lw	a3,32(s1)
    80004700:	864e                	mv	a2,s3
    80004702:	4585                	li	a1,1
    80004704:	6c88                	ld	a0,24(s1)
    80004706:	fffff097          	auipc	ra,0xfffff
    8000470a:	294080e7          	jalr	660(ra) # 8000399a <readi>
    8000470e:	892a                	mv	s2,a0
    80004710:	00a05563          	blez	a0,8000471a <fileread+0x56>
      f->off += r;
    80004714:	509c                	lw	a5,32(s1)
    80004716:	9fa9                	addw	a5,a5,a0
    80004718:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000471a:	6c88                	ld	a0,24(s1)
    8000471c:	fffff097          	auipc	ra,0xfffff
    80004720:	08c080e7          	jalr	140(ra) # 800037a8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004724:	854a                	mv	a0,s2
    80004726:	70a2                	ld	ra,40(sp)
    80004728:	7402                	ld	s0,32(sp)
    8000472a:	64e2                	ld	s1,24(sp)
    8000472c:	6942                	ld	s2,16(sp)
    8000472e:	69a2                	ld	s3,8(sp)
    80004730:	6145                	addi	sp,sp,48
    80004732:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004734:	6908                	ld	a0,16(a0)
    80004736:	00000097          	auipc	ra,0x0
    8000473a:	3c0080e7          	jalr	960(ra) # 80004af6 <piperead>
    8000473e:	892a                	mv	s2,a0
    80004740:	b7d5                	j	80004724 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004742:	02451783          	lh	a5,36(a0)
    80004746:	03079693          	slli	a3,a5,0x30
    8000474a:	92c1                	srli	a3,a3,0x30
    8000474c:	4725                	li	a4,9
    8000474e:	02d76863          	bltu	a4,a3,8000477e <fileread+0xba>
    80004752:	0792                	slli	a5,a5,0x4
    80004754:	0001d717          	auipc	a4,0x1d
    80004758:	bc470713          	addi	a4,a4,-1084 # 80021318 <devsw>
    8000475c:	97ba                	add	a5,a5,a4
    8000475e:	639c                	ld	a5,0(a5)
    80004760:	c38d                	beqz	a5,80004782 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004762:	4505                	li	a0,1
    80004764:	9782                	jalr	a5
    80004766:	892a                	mv	s2,a0
    80004768:	bf75                	j	80004724 <fileread+0x60>
    panic("fileread");
    8000476a:	00004517          	auipc	a0,0x4
    8000476e:	03650513          	addi	a0,a0,54 # 800087a0 <syscalls+0x2d8>
    80004772:	ffffc097          	auipc	ra,0xffffc
    80004776:	dc8080e7          	jalr	-568(ra) # 8000053a <panic>
    return -1;
    8000477a:	597d                	li	s2,-1
    8000477c:	b765                	j	80004724 <fileread+0x60>
      return -1;
    8000477e:	597d                	li	s2,-1
    80004780:	b755                	j	80004724 <fileread+0x60>
    80004782:	597d                	li	s2,-1
    80004784:	b745                	j	80004724 <fileread+0x60>

0000000080004786 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004786:	715d                	addi	sp,sp,-80
    80004788:	e486                	sd	ra,72(sp)
    8000478a:	e0a2                	sd	s0,64(sp)
    8000478c:	fc26                	sd	s1,56(sp)
    8000478e:	f84a                	sd	s2,48(sp)
    80004790:	f44e                	sd	s3,40(sp)
    80004792:	f052                	sd	s4,32(sp)
    80004794:	ec56                	sd	s5,24(sp)
    80004796:	e85a                	sd	s6,16(sp)
    80004798:	e45e                	sd	s7,8(sp)
    8000479a:	e062                	sd	s8,0(sp)
    8000479c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000479e:	00954783          	lbu	a5,9(a0)
    800047a2:	10078663          	beqz	a5,800048ae <filewrite+0x128>
    800047a6:	892a                	mv	s2,a0
    800047a8:	8b2e                	mv	s6,a1
    800047aa:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047ac:	411c                	lw	a5,0(a0)
    800047ae:	4705                	li	a4,1
    800047b0:	02e78263          	beq	a5,a4,800047d4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047b4:	470d                	li	a4,3
    800047b6:	02e78663          	beq	a5,a4,800047e2 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047ba:	4709                	li	a4,2
    800047bc:	0ee79163          	bne	a5,a4,8000489e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047c0:	0ac05d63          	blez	a2,8000487a <filewrite+0xf4>
    int i = 0;
    800047c4:	4981                	li	s3,0
    800047c6:	6b85                	lui	s7,0x1
    800047c8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800047cc:	6c05                	lui	s8,0x1
    800047ce:	c00c0c1b          	addiw	s8,s8,-1024
    800047d2:	a861                	j	8000486a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800047d4:	6908                	ld	a0,16(a0)
    800047d6:	00000097          	auipc	ra,0x0
    800047da:	22e080e7          	jalr	558(ra) # 80004a04 <pipewrite>
    800047de:	8a2a                	mv	s4,a0
    800047e0:	a045                	j	80004880 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047e2:	02451783          	lh	a5,36(a0)
    800047e6:	03079693          	slli	a3,a5,0x30
    800047ea:	92c1                	srli	a3,a3,0x30
    800047ec:	4725                	li	a4,9
    800047ee:	0cd76263          	bltu	a4,a3,800048b2 <filewrite+0x12c>
    800047f2:	0792                	slli	a5,a5,0x4
    800047f4:	0001d717          	auipc	a4,0x1d
    800047f8:	b2470713          	addi	a4,a4,-1244 # 80021318 <devsw>
    800047fc:	97ba                	add	a5,a5,a4
    800047fe:	679c                	ld	a5,8(a5)
    80004800:	cbdd                	beqz	a5,800048b6 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004802:	4505                	li	a0,1
    80004804:	9782                	jalr	a5
    80004806:	8a2a                	mv	s4,a0
    80004808:	a8a5                	j	80004880 <filewrite+0xfa>
    8000480a:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000480e:	00000097          	auipc	ra,0x0
    80004812:	8b4080e7          	jalr	-1868(ra) # 800040c2 <begin_op>
      ilock(f->ip);
    80004816:	01893503          	ld	a0,24(s2)
    8000481a:	fffff097          	auipc	ra,0xfffff
    8000481e:	ecc080e7          	jalr	-308(ra) # 800036e6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004822:	8756                	mv	a4,s5
    80004824:	02092683          	lw	a3,32(s2)
    80004828:	01698633          	add	a2,s3,s6
    8000482c:	4585                	li	a1,1
    8000482e:	01893503          	ld	a0,24(s2)
    80004832:	fffff097          	auipc	ra,0xfffff
    80004836:	260080e7          	jalr	608(ra) # 80003a92 <writei>
    8000483a:	84aa                	mv	s1,a0
    8000483c:	00a05763          	blez	a0,8000484a <filewrite+0xc4>
        f->off += r;
    80004840:	02092783          	lw	a5,32(s2)
    80004844:	9fa9                	addw	a5,a5,a0
    80004846:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000484a:	01893503          	ld	a0,24(s2)
    8000484e:	fffff097          	auipc	ra,0xfffff
    80004852:	f5a080e7          	jalr	-166(ra) # 800037a8 <iunlock>
      end_op();
    80004856:	00000097          	auipc	ra,0x0
    8000485a:	8ea080e7          	jalr	-1814(ra) # 80004140 <end_op>

      if(r != n1){
    8000485e:	009a9f63          	bne	s5,s1,8000487c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004862:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004866:	0149db63          	bge	s3,s4,8000487c <filewrite+0xf6>
      int n1 = n - i;
    8000486a:	413a04bb          	subw	s1,s4,s3
    8000486e:	0004879b          	sext.w	a5,s1
    80004872:	f8fbdce3          	bge	s7,a5,8000480a <filewrite+0x84>
    80004876:	84e2                	mv	s1,s8
    80004878:	bf49                	j	8000480a <filewrite+0x84>
    int i = 0;
    8000487a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000487c:	013a1f63          	bne	s4,s3,8000489a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004880:	8552                	mv	a0,s4
    80004882:	60a6                	ld	ra,72(sp)
    80004884:	6406                	ld	s0,64(sp)
    80004886:	74e2                	ld	s1,56(sp)
    80004888:	7942                	ld	s2,48(sp)
    8000488a:	79a2                	ld	s3,40(sp)
    8000488c:	7a02                	ld	s4,32(sp)
    8000488e:	6ae2                	ld	s5,24(sp)
    80004890:	6b42                	ld	s6,16(sp)
    80004892:	6ba2                	ld	s7,8(sp)
    80004894:	6c02                	ld	s8,0(sp)
    80004896:	6161                	addi	sp,sp,80
    80004898:	8082                	ret
    ret = (i == n ? n : -1);
    8000489a:	5a7d                	li	s4,-1
    8000489c:	b7d5                	j	80004880 <filewrite+0xfa>
    panic("filewrite");
    8000489e:	00004517          	auipc	a0,0x4
    800048a2:	f1250513          	addi	a0,a0,-238 # 800087b0 <syscalls+0x2e8>
    800048a6:	ffffc097          	auipc	ra,0xffffc
    800048aa:	c94080e7          	jalr	-876(ra) # 8000053a <panic>
    return -1;
    800048ae:	5a7d                	li	s4,-1
    800048b0:	bfc1                	j	80004880 <filewrite+0xfa>
      return -1;
    800048b2:	5a7d                	li	s4,-1
    800048b4:	b7f1                	j	80004880 <filewrite+0xfa>
    800048b6:	5a7d                	li	s4,-1
    800048b8:	b7e1                	j	80004880 <filewrite+0xfa>

00000000800048ba <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048ba:	7179                	addi	sp,sp,-48
    800048bc:	f406                	sd	ra,40(sp)
    800048be:	f022                	sd	s0,32(sp)
    800048c0:	ec26                	sd	s1,24(sp)
    800048c2:	e84a                	sd	s2,16(sp)
    800048c4:	e44e                	sd	s3,8(sp)
    800048c6:	e052                	sd	s4,0(sp)
    800048c8:	1800                	addi	s0,sp,48
    800048ca:	84aa                	mv	s1,a0
    800048cc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048ce:	0005b023          	sd	zero,0(a1)
    800048d2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048d6:	00000097          	auipc	ra,0x0
    800048da:	bf8080e7          	jalr	-1032(ra) # 800044ce <filealloc>
    800048de:	e088                	sd	a0,0(s1)
    800048e0:	c551                	beqz	a0,8000496c <pipealloc+0xb2>
    800048e2:	00000097          	auipc	ra,0x0
    800048e6:	bec080e7          	jalr	-1044(ra) # 800044ce <filealloc>
    800048ea:	00aa3023          	sd	a0,0(s4)
    800048ee:	c92d                	beqz	a0,80004960 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048f0:	ffffc097          	auipc	ra,0xffffc
    800048f4:	1f0080e7          	jalr	496(ra) # 80000ae0 <kalloc>
    800048f8:	892a                	mv	s2,a0
    800048fa:	c125                	beqz	a0,8000495a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048fc:	4985                	li	s3,1
    800048fe:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004902:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004906:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000490a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000490e:	00004597          	auipc	a1,0x4
    80004912:	eb258593          	addi	a1,a1,-334 # 800087c0 <syscalls+0x2f8>
    80004916:	ffffc097          	auipc	ra,0xffffc
    8000491a:	22a080e7          	jalr	554(ra) # 80000b40 <initlock>
  (*f0)->type = FD_PIPE;
    8000491e:	609c                	ld	a5,0(s1)
    80004920:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004924:	609c                	ld	a5,0(s1)
    80004926:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000492a:	609c                	ld	a5,0(s1)
    8000492c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004930:	609c                	ld	a5,0(s1)
    80004932:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004936:	000a3783          	ld	a5,0(s4)
    8000493a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000493e:	000a3783          	ld	a5,0(s4)
    80004942:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004946:	000a3783          	ld	a5,0(s4)
    8000494a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000494e:	000a3783          	ld	a5,0(s4)
    80004952:	0127b823          	sd	s2,16(a5)
  return 0;
    80004956:	4501                	li	a0,0
    80004958:	a025                	j	80004980 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000495a:	6088                	ld	a0,0(s1)
    8000495c:	e501                	bnez	a0,80004964 <pipealloc+0xaa>
    8000495e:	a039                	j	8000496c <pipealloc+0xb2>
    80004960:	6088                	ld	a0,0(s1)
    80004962:	c51d                	beqz	a0,80004990 <pipealloc+0xd6>
    fileclose(*f0);
    80004964:	00000097          	auipc	ra,0x0
    80004968:	c26080e7          	jalr	-986(ra) # 8000458a <fileclose>
  if(*f1)
    8000496c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004970:	557d                	li	a0,-1
  if(*f1)
    80004972:	c799                	beqz	a5,80004980 <pipealloc+0xc6>
    fileclose(*f1);
    80004974:	853e                	mv	a0,a5
    80004976:	00000097          	auipc	ra,0x0
    8000497a:	c14080e7          	jalr	-1004(ra) # 8000458a <fileclose>
  return -1;
    8000497e:	557d                	li	a0,-1
}
    80004980:	70a2                	ld	ra,40(sp)
    80004982:	7402                	ld	s0,32(sp)
    80004984:	64e2                	ld	s1,24(sp)
    80004986:	6942                	ld	s2,16(sp)
    80004988:	69a2                	ld	s3,8(sp)
    8000498a:	6a02                	ld	s4,0(sp)
    8000498c:	6145                	addi	sp,sp,48
    8000498e:	8082                	ret
  return -1;
    80004990:	557d                	li	a0,-1
    80004992:	b7fd                	j	80004980 <pipealloc+0xc6>

0000000080004994 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004994:	1101                	addi	sp,sp,-32
    80004996:	ec06                	sd	ra,24(sp)
    80004998:	e822                	sd	s0,16(sp)
    8000499a:	e426                	sd	s1,8(sp)
    8000499c:	e04a                	sd	s2,0(sp)
    8000499e:	1000                	addi	s0,sp,32
    800049a0:	84aa                	mv	s1,a0
    800049a2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049a4:	ffffc097          	auipc	ra,0xffffc
    800049a8:	22c080e7          	jalr	556(ra) # 80000bd0 <acquire>
  if(writable){
    800049ac:	02090d63          	beqz	s2,800049e6 <pipeclose+0x52>
    pi->writeopen = 0;
    800049b0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049b4:	21848513          	addi	a0,s1,536
    800049b8:	ffffe097          	auipc	ra,0xffffe
    800049bc:	8ae080e7          	jalr	-1874(ra) # 80002266 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049c0:	2204b783          	ld	a5,544(s1)
    800049c4:	eb95                	bnez	a5,800049f8 <pipeclose+0x64>
    release(&pi->lock);
    800049c6:	8526                	mv	a0,s1
    800049c8:	ffffc097          	auipc	ra,0xffffc
    800049cc:	2bc080e7          	jalr	700(ra) # 80000c84 <release>
    kfree((char*)pi);
    800049d0:	8526                	mv	a0,s1
    800049d2:	ffffc097          	auipc	ra,0xffffc
    800049d6:	010080e7          	jalr	16(ra) # 800009e2 <kfree>
  } else
    release(&pi->lock);
}
    800049da:	60e2                	ld	ra,24(sp)
    800049dc:	6442                	ld	s0,16(sp)
    800049de:	64a2                	ld	s1,8(sp)
    800049e0:	6902                	ld	s2,0(sp)
    800049e2:	6105                	addi	sp,sp,32
    800049e4:	8082                	ret
    pi->readopen = 0;
    800049e6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049ea:	21c48513          	addi	a0,s1,540
    800049ee:	ffffe097          	auipc	ra,0xffffe
    800049f2:	878080e7          	jalr	-1928(ra) # 80002266 <wakeup>
    800049f6:	b7e9                	j	800049c0 <pipeclose+0x2c>
    release(&pi->lock);
    800049f8:	8526                	mv	a0,s1
    800049fa:	ffffc097          	auipc	ra,0xffffc
    800049fe:	28a080e7          	jalr	650(ra) # 80000c84 <release>
}
    80004a02:	bfe1                	j	800049da <pipeclose+0x46>

0000000080004a04 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a04:	711d                	addi	sp,sp,-96
    80004a06:	ec86                	sd	ra,88(sp)
    80004a08:	e8a2                	sd	s0,80(sp)
    80004a0a:	e4a6                	sd	s1,72(sp)
    80004a0c:	e0ca                	sd	s2,64(sp)
    80004a0e:	fc4e                	sd	s3,56(sp)
    80004a10:	f852                	sd	s4,48(sp)
    80004a12:	f456                	sd	s5,40(sp)
    80004a14:	f05a                	sd	s6,32(sp)
    80004a16:	ec5e                	sd	s7,24(sp)
    80004a18:	e862                	sd	s8,16(sp)
    80004a1a:	1080                	addi	s0,sp,96
    80004a1c:	84aa                	mv	s1,a0
    80004a1e:	8aae                	mv	s5,a1
    80004a20:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a22:	ffffd097          	auipc	ra,0xffffd
    80004a26:	ff4080e7          	jalr	-12(ra) # 80001a16 <myproc>
    80004a2a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a2c:	8526                	mv	a0,s1
    80004a2e:	ffffc097          	auipc	ra,0xffffc
    80004a32:	1a2080e7          	jalr	418(ra) # 80000bd0 <acquire>
  while(i < n){
    80004a36:	0b405363          	blez	s4,80004adc <pipewrite+0xd8>
  int i = 0;
    80004a3a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a3c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a3e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a42:	21c48b93          	addi	s7,s1,540
    80004a46:	a089                	j	80004a88 <pipewrite+0x84>
      release(&pi->lock);
    80004a48:	8526                	mv	a0,s1
    80004a4a:	ffffc097          	auipc	ra,0xffffc
    80004a4e:	23a080e7          	jalr	570(ra) # 80000c84 <release>
      return -1;
    80004a52:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a54:	854a                	mv	a0,s2
    80004a56:	60e6                	ld	ra,88(sp)
    80004a58:	6446                	ld	s0,80(sp)
    80004a5a:	64a6                	ld	s1,72(sp)
    80004a5c:	6906                	ld	s2,64(sp)
    80004a5e:	79e2                	ld	s3,56(sp)
    80004a60:	7a42                	ld	s4,48(sp)
    80004a62:	7aa2                	ld	s5,40(sp)
    80004a64:	7b02                	ld	s6,32(sp)
    80004a66:	6be2                	ld	s7,24(sp)
    80004a68:	6c42                	ld	s8,16(sp)
    80004a6a:	6125                	addi	sp,sp,96
    80004a6c:	8082                	ret
      wakeup(&pi->nread);
    80004a6e:	8562                	mv	a0,s8
    80004a70:	ffffd097          	auipc	ra,0xffffd
    80004a74:	7f6080e7          	jalr	2038(ra) # 80002266 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a78:	85a6                	mv	a1,s1
    80004a7a:	855e                	mv	a0,s7
    80004a7c:	ffffd097          	auipc	ra,0xffffd
    80004a80:	65e080e7          	jalr	1630(ra) # 800020da <sleep>
  while(i < n){
    80004a84:	05495d63          	bge	s2,s4,80004ade <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004a88:	2204a783          	lw	a5,544(s1)
    80004a8c:	dfd5                	beqz	a5,80004a48 <pipewrite+0x44>
    80004a8e:	0289a783          	lw	a5,40(s3)
    80004a92:	fbdd                	bnez	a5,80004a48 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a94:	2184a783          	lw	a5,536(s1)
    80004a98:	21c4a703          	lw	a4,540(s1)
    80004a9c:	2007879b          	addiw	a5,a5,512
    80004aa0:	fcf707e3          	beq	a4,a5,80004a6e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004aa4:	4685                	li	a3,1
    80004aa6:	01590633          	add	a2,s2,s5
    80004aaa:	faf40593          	addi	a1,s0,-81
    80004aae:	0509b503          	ld	a0,80(s3)
    80004ab2:	ffffd097          	auipc	ra,0xffffd
    80004ab6:	c34080e7          	jalr	-972(ra) # 800016e6 <copyin>
    80004aba:	03650263          	beq	a0,s6,80004ade <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004abe:	21c4a783          	lw	a5,540(s1)
    80004ac2:	0017871b          	addiw	a4,a5,1
    80004ac6:	20e4ae23          	sw	a4,540(s1)
    80004aca:	1ff7f793          	andi	a5,a5,511
    80004ace:	97a6                	add	a5,a5,s1
    80004ad0:	faf44703          	lbu	a4,-81(s0)
    80004ad4:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ad8:	2905                	addiw	s2,s2,1
    80004ada:	b76d                	j	80004a84 <pipewrite+0x80>
  int i = 0;
    80004adc:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004ade:	21848513          	addi	a0,s1,536
    80004ae2:	ffffd097          	auipc	ra,0xffffd
    80004ae6:	784080e7          	jalr	1924(ra) # 80002266 <wakeup>
  release(&pi->lock);
    80004aea:	8526                	mv	a0,s1
    80004aec:	ffffc097          	auipc	ra,0xffffc
    80004af0:	198080e7          	jalr	408(ra) # 80000c84 <release>
  return i;
    80004af4:	b785                	j	80004a54 <pipewrite+0x50>

0000000080004af6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004af6:	715d                	addi	sp,sp,-80
    80004af8:	e486                	sd	ra,72(sp)
    80004afa:	e0a2                	sd	s0,64(sp)
    80004afc:	fc26                	sd	s1,56(sp)
    80004afe:	f84a                	sd	s2,48(sp)
    80004b00:	f44e                	sd	s3,40(sp)
    80004b02:	f052                	sd	s4,32(sp)
    80004b04:	ec56                	sd	s5,24(sp)
    80004b06:	e85a                	sd	s6,16(sp)
    80004b08:	0880                	addi	s0,sp,80
    80004b0a:	84aa                	mv	s1,a0
    80004b0c:	892e                	mv	s2,a1
    80004b0e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b10:	ffffd097          	auipc	ra,0xffffd
    80004b14:	f06080e7          	jalr	-250(ra) # 80001a16 <myproc>
    80004b18:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b1a:	8526                	mv	a0,s1
    80004b1c:	ffffc097          	auipc	ra,0xffffc
    80004b20:	0b4080e7          	jalr	180(ra) # 80000bd0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b24:	2184a703          	lw	a4,536(s1)
    80004b28:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b2c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b30:	02f71463          	bne	a4,a5,80004b58 <piperead+0x62>
    80004b34:	2244a783          	lw	a5,548(s1)
    80004b38:	c385                	beqz	a5,80004b58 <piperead+0x62>
    if(pr->killed){
    80004b3a:	028a2783          	lw	a5,40(s4)
    80004b3e:	ebc9                	bnez	a5,80004bd0 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b40:	85a6                	mv	a1,s1
    80004b42:	854e                	mv	a0,s3
    80004b44:	ffffd097          	auipc	ra,0xffffd
    80004b48:	596080e7          	jalr	1430(ra) # 800020da <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b4c:	2184a703          	lw	a4,536(s1)
    80004b50:	21c4a783          	lw	a5,540(s1)
    80004b54:	fef700e3          	beq	a4,a5,80004b34 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b58:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b5a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b5c:	05505463          	blez	s5,80004ba4 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80004b60:	2184a783          	lw	a5,536(s1)
    80004b64:	21c4a703          	lw	a4,540(s1)
    80004b68:	02f70e63          	beq	a4,a5,80004ba4 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b6c:	0017871b          	addiw	a4,a5,1
    80004b70:	20e4ac23          	sw	a4,536(s1)
    80004b74:	1ff7f793          	andi	a5,a5,511
    80004b78:	97a6                	add	a5,a5,s1
    80004b7a:	0187c783          	lbu	a5,24(a5)
    80004b7e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b82:	4685                	li	a3,1
    80004b84:	fbf40613          	addi	a2,s0,-65
    80004b88:	85ca                	mv	a1,s2
    80004b8a:	050a3503          	ld	a0,80(s4)
    80004b8e:	ffffd097          	auipc	ra,0xffffd
    80004b92:	acc080e7          	jalr	-1332(ra) # 8000165a <copyout>
    80004b96:	01650763          	beq	a0,s6,80004ba4 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b9a:	2985                	addiw	s3,s3,1
    80004b9c:	0905                	addi	s2,s2,1
    80004b9e:	fd3a91e3          	bne	s5,s3,80004b60 <piperead+0x6a>
    80004ba2:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ba4:	21c48513          	addi	a0,s1,540
    80004ba8:	ffffd097          	auipc	ra,0xffffd
    80004bac:	6be080e7          	jalr	1726(ra) # 80002266 <wakeup>
  release(&pi->lock);
    80004bb0:	8526                	mv	a0,s1
    80004bb2:	ffffc097          	auipc	ra,0xffffc
    80004bb6:	0d2080e7          	jalr	210(ra) # 80000c84 <release>
  return i;
}
    80004bba:	854e                	mv	a0,s3
    80004bbc:	60a6                	ld	ra,72(sp)
    80004bbe:	6406                	ld	s0,64(sp)
    80004bc0:	74e2                	ld	s1,56(sp)
    80004bc2:	7942                	ld	s2,48(sp)
    80004bc4:	79a2                	ld	s3,40(sp)
    80004bc6:	7a02                	ld	s4,32(sp)
    80004bc8:	6ae2                	ld	s5,24(sp)
    80004bca:	6b42                	ld	s6,16(sp)
    80004bcc:	6161                	addi	sp,sp,80
    80004bce:	8082                	ret
      release(&pi->lock);
    80004bd0:	8526                	mv	a0,s1
    80004bd2:	ffffc097          	auipc	ra,0xffffc
    80004bd6:	0b2080e7          	jalr	178(ra) # 80000c84 <release>
      return -1;
    80004bda:	59fd                	li	s3,-1
    80004bdc:	bff9                	j	80004bba <piperead+0xc4>

0000000080004bde <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004bde:	de010113          	addi	sp,sp,-544
    80004be2:	20113c23          	sd	ra,536(sp)
    80004be6:	20813823          	sd	s0,528(sp)
    80004bea:	20913423          	sd	s1,520(sp)
    80004bee:	21213023          	sd	s2,512(sp)
    80004bf2:	ffce                	sd	s3,504(sp)
    80004bf4:	fbd2                	sd	s4,496(sp)
    80004bf6:	f7d6                	sd	s5,488(sp)
    80004bf8:	f3da                	sd	s6,480(sp)
    80004bfa:	efde                	sd	s7,472(sp)
    80004bfc:	ebe2                	sd	s8,464(sp)
    80004bfe:	e7e6                	sd	s9,456(sp)
    80004c00:	e3ea                	sd	s10,448(sp)
    80004c02:	ff6e                	sd	s11,440(sp)
    80004c04:	1400                	addi	s0,sp,544
    80004c06:	892a                	mv	s2,a0
    80004c08:	dea43423          	sd	a0,-536(s0)
    80004c0c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c10:	ffffd097          	auipc	ra,0xffffd
    80004c14:	e06080e7          	jalr	-506(ra) # 80001a16 <myproc>
    80004c18:	84aa                	mv	s1,a0

  begin_op();
    80004c1a:	fffff097          	auipc	ra,0xfffff
    80004c1e:	4a8080e7          	jalr	1192(ra) # 800040c2 <begin_op>

  if((ip = namei(path)) == 0){
    80004c22:	854a                	mv	a0,s2
    80004c24:	fffff097          	auipc	ra,0xfffff
    80004c28:	27e080e7          	jalr	638(ra) # 80003ea2 <namei>
    80004c2c:	c93d                	beqz	a0,80004ca2 <exec+0xc4>
    80004c2e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c30:	fffff097          	auipc	ra,0xfffff
    80004c34:	ab6080e7          	jalr	-1354(ra) # 800036e6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c38:	04000713          	li	a4,64
    80004c3c:	4681                	li	a3,0
    80004c3e:	e5040613          	addi	a2,s0,-432
    80004c42:	4581                	li	a1,0
    80004c44:	8556                	mv	a0,s5
    80004c46:	fffff097          	auipc	ra,0xfffff
    80004c4a:	d54080e7          	jalr	-684(ra) # 8000399a <readi>
    80004c4e:	04000793          	li	a5,64
    80004c52:	00f51a63          	bne	a0,a5,80004c66 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004c56:	e5042703          	lw	a4,-432(s0)
    80004c5a:	464c47b7          	lui	a5,0x464c4
    80004c5e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c62:	04f70663          	beq	a4,a5,80004cae <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c66:	8556                	mv	a0,s5
    80004c68:	fffff097          	auipc	ra,0xfffff
    80004c6c:	ce0080e7          	jalr	-800(ra) # 80003948 <iunlockput>
    end_op();
    80004c70:	fffff097          	auipc	ra,0xfffff
    80004c74:	4d0080e7          	jalr	1232(ra) # 80004140 <end_op>
  }
  return -1;
    80004c78:	557d                	li	a0,-1
}
    80004c7a:	21813083          	ld	ra,536(sp)
    80004c7e:	21013403          	ld	s0,528(sp)
    80004c82:	20813483          	ld	s1,520(sp)
    80004c86:	20013903          	ld	s2,512(sp)
    80004c8a:	79fe                	ld	s3,504(sp)
    80004c8c:	7a5e                	ld	s4,496(sp)
    80004c8e:	7abe                	ld	s5,488(sp)
    80004c90:	7b1e                	ld	s6,480(sp)
    80004c92:	6bfe                	ld	s7,472(sp)
    80004c94:	6c5e                	ld	s8,464(sp)
    80004c96:	6cbe                	ld	s9,456(sp)
    80004c98:	6d1e                	ld	s10,448(sp)
    80004c9a:	7dfa                	ld	s11,440(sp)
    80004c9c:	22010113          	addi	sp,sp,544
    80004ca0:	8082                	ret
    end_op();
    80004ca2:	fffff097          	auipc	ra,0xfffff
    80004ca6:	49e080e7          	jalr	1182(ra) # 80004140 <end_op>
    return -1;
    80004caa:	557d                	li	a0,-1
    80004cac:	b7f9                	j	80004c7a <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004cae:	8526                	mv	a0,s1
    80004cb0:	ffffd097          	auipc	ra,0xffffd
    80004cb4:	e2a080e7          	jalr	-470(ra) # 80001ada <proc_pagetable>
    80004cb8:	8b2a                	mv	s6,a0
    80004cba:	d555                	beqz	a0,80004c66 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cbc:	e7042783          	lw	a5,-400(s0)
    80004cc0:	e8845703          	lhu	a4,-376(s0)
    80004cc4:	c735                	beqz	a4,80004d30 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cc6:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cc8:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004ccc:	6a05                	lui	s4,0x1
    80004cce:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004cd2:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004cd6:	6d85                	lui	s11,0x1
    80004cd8:	7d7d                	lui	s10,0xfffff
    80004cda:	ac1d                	j	80004f10 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004cdc:	00004517          	auipc	a0,0x4
    80004ce0:	aec50513          	addi	a0,a0,-1300 # 800087c8 <syscalls+0x300>
    80004ce4:	ffffc097          	auipc	ra,0xffffc
    80004ce8:	856080e7          	jalr	-1962(ra) # 8000053a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004cec:	874a                	mv	a4,s2
    80004cee:	009c86bb          	addw	a3,s9,s1
    80004cf2:	4581                	li	a1,0
    80004cf4:	8556                	mv	a0,s5
    80004cf6:	fffff097          	auipc	ra,0xfffff
    80004cfa:	ca4080e7          	jalr	-860(ra) # 8000399a <readi>
    80004cfe:	2501                	sext.w	a0,a0
    80004d00:	1aa91863          	bne	s2,a0,80004eb0 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004d04:	009d84bb          	addw	s1,s11,s1
    80004d08:	013d09bb          	addw	s3,s10,s3
    80004d0c:	1f74f263          	bgeu	s1,s7,80004ef0 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004d10:	02049593          	slli	a1,s1,0x20
    80004d14:	9181                	srli	a1,a1,0x20
    80004d16:	95e2                	add	a1,a1,s8
    80004d18:	855a                	mv	a0,s6
    80004d1a:	ffffc097          	auipc	ra,0xffffc
    80004d1e:	338080e7          	jalr	824(ra) # 80001052 <walkaddr>
    80004d22:	862a                	mv	a2,a0
    if(pa == 0)
    80004d24:	dd45                	beqz	a0,80004cdc <exec+0xfe>
      n = PGSIZE;
    80004d26:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004d28:	fd49f2e3          	bgeu	s3,s4,80004cec <exec+0x10e>
      n = sz - i;
    80004d2c:	894e                	mv	s2,s3
    80004d2e:	bf7d                	j	80004cec <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d30:	4481                	li	s1,0
  iunlockput(ip);
    80004d32:	8556                	mv	a0,s5
    80004d34:	fffff097          	auipc	ra,0xfffff
    80004d38:	c14080e7          	jalr	-1004(ra) # 80003948 <iunlockput>
  end_op();
    80004d3c:	fffff097          	auipc	ra,0xfffff
    80004d40:	404080e7          	jalr	1028(ra) # 80004140 <end_op>
  p = myproc();
    80004d44:	ffffd097          	auipc	ra,0xffffd
    80004d48:	cd2080e7          	jalr	-814(ra) # 80001a16 <myproc>
    80004d4c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004d4e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004d52:	6785                	lui	a5,0x1
    80004d54:	17fd                	addi	a5,a5,-1
    80004d56:	97a6                	add	a5,a5,s1
    80004d58:	777d                	lui	a4,0xfffff
    80004d5a:	8ff9                	and	a5,a5,a4
    80004d5c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d60:	6609                	lui	a2,0x2
    80004d62:	963e                	add	a2,a2,a5
    80004d64:	85be                	mv	a1,a5
    80004d66:	855a                	mv	a0,s6
    80004d68:	ffffc097          	auipc	ra,0xffffc
    80004d6c:	69e080e7          	jalr	1694(ra) # 80001406 <uvmalloc>
    80004d70:	8c2a                	mv	s8,a0
  ip = 0;
    80004d72:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d74:	12050e63          	beqz	a0,80004eb0 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d78:	75f9                	lui	a1,0xffffe
    80004d7a:	95aa                	add	a1,a1,a0
    80004d7c:	855a                	mv	a0,s6
    80004d7e:	ffffd097          	auipc	ra,0xffffd
    80004d82:	8aa080e7          	jalr	-1878(ra) # 80001628 <uvmclear>
  stackbase = sp - PGSIZE;
    80004d86:	7afd                	lui	s5,0xfffff
    80004d88:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d8a:	df043783          	ld	a5,-528(s0)
    80004d8e:	6388                	ld	a0,0(a5)
    80004d90:	c925                	beqz	a0,80004e00 <exec+0x222>
    80004d92:	e9040993          	addi	s3,s0,-368
    80004d96:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004d9a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d9c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d9e:	ffffc097          	auipc	ra,0xffffc
    80004da2:	0aa080e7          	jalr	170(ra) # 80000e48 <strlen>
    80004da6:	0015079b          	addiw	a5,a0,1
    80004daa:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004dae:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004db2:	13596363          	bltu	s2,s5,80004ed8 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004db6:	df043d83          	ld	s11,-528(s0)
    80004dba:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004dbe:	8552                	mv	a0,s4
    80004dc0:	ffffc097          	auipc	ra,0xffffc
    80004dc4:	088080e7          	jalr	136(ra) # 80000e48 <strlen>
    80004dc8:	0015069b          	addiw	a3,a0,1
    80004dcc:	8652                	mv	a2,s4
    80004dce:	85ca                	mv	a1,s2
    80004dd0:	855a                	mv	a0,s6
    80004dd2:	ffffd097          	auipc	ra,0xffffd
    80004dd6:	888080e7          	jalr	-1912(ra) # 8000165a <copyout>
    80004dda:	10054363          	bltz	a0,80004ee0 <exec+0x302>
    ustack[argc] = sp;
    80004dde:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004de2:	0485                	addi	s1,s1,1
    80004de4:	008d8793          	addi	a5,s11,8
    80004de8:	def43823          	sd	a5,-528(s0)
    80004dec:	008db503          	ld	a0,8(s11)
    80004df0:	c911                	beqz	a0,80004e04 <exec+0x226>
    if(argc >= MAXARG)
    80004df2:	09a1                	addi	s3,s3,8
    80004df4:	fb3c95e3          	bne	s9,s3,80004d9e <exec+0x1c0>
  sz = sz1;
    80004df8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004dfc:	4a81                	li	s5,0
    80004dfe:	a84d                	j	80004eb0 <exec+0x2d2>
  sp = sz;
    80004e00:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e02:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e04:	00349793          	slli	a5,s1,0x3
    80004e08:	f9078793          	addi	a5,a5,-112 # f90 <_entry-0x7ffff070>
    80004e0c:	97a2                	add	a5,a5,s0
    80004e0e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e12:	00148693          	addi	a3,s1,1
    80004e16:	068e                	slli	a3,a3,0x3
    80004e18:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e1c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e20:	01597663          	bgeu	s2,s5,80004e2c <exec+0x24e>
  sz = sz1;
    80004e24:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e28:	4a81                	li	s5,0
    80004e2a:	a059                	j	80004eb0 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e2c:	e9040613          	addi	a2,s0,-368
    80004e30:	85ca                	mv	a1,s2
    80004e32:	855a                	mv	a0,s6
    80004e34:	ffffd097          	auipc	ra,0xffffd
    80004e38:	826080e7          	jalr	-2010(ra) # 8000165a <copyout>
    80004e3c:	0a054663          	bltz	a0,80004ee8 <exec+0x30a>
  p->trapframe->a1 = sp;
    80004e40:	058bb783          	ld	a5,88(s7)
    80004e44:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e48:	de843783          	ld	a5,-536(s0)
    80004e4c:	0007c703          	lbu	a4,0(a5)
    80004e50:	cf11                	beqz	a4,80004e6c <exec+0x28e>
    80004e52:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e54:	02f00693          	li	a3,47
    80004e58:	a039                	j	80004e66 <exec+0x288>
      last = s+1;
    80004e5a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004e5e:	0785                	addi	a5,a5,1
    80004e60:	fff7c703          	lbu	a4,-1(a5)
    80004e64:	c701                	beqz	a4,80004e6c <exec+0x28e>
    if(*s == '/')
    80004e66:	fed71ce3          	bne	a4,a3,80004e5e <exec+0x280>
    80004e6a:	bfc5                	j	80004e5a <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e6c:	4641                	li	a2,16
    80004e6e:	de843583          	ld	a1,-536(s0)
    80004e72:	158b8513          	addi	a0,s7,344
    80004e76:	ffffc097          	auipc	ra,0xffffc
    80004e7a:	fa0080e7          	jalr	-96(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004e7e:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004e82:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004e86:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e8a:	058bb783          	ld	a5,88(s7)
    80004e8e:	e6843703          	ld	a4,-408(s0)
    80004e92:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e94:	058bb783          	ld	a5,88(s7)
    80004e98:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e9c:	85ea                	mv	a1,s10
    80004e9e:	ffffd097          	auipc	ra,0xffffd
    80004ea2:	cd8080e7          	jalr	-808(ra) # 80001b76 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ea6:	0004851b          	sext.w	a0,s1
    80004eaa:	bbc1                	j	80004c7a <exec+0x9c>
    80004eac:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004eb0:	df843583          	ld	a1,-520(s0)
    80004eb4:	855a                	mv	a0,s6
    80004eb6:	ffffd097          	auipc	ra,0xffffd
    80004eba:	cc0080e7          	jalr	-832(ra) # 80001b76 <proc_freepagetable>
  if(ip){
    80004ebe:	da0a94e3          	bnez	s5,80004c66 <exec+0x88>
  return -1;
    80004ec2:	557d                	li	a0,-1
    80004ec4:	bb5d                	j	80004c7a <exec+0x9c>
    80004ec6:	de943c23          	sd	s1,-520(s0)
    80004eca:	b7dd                	j	80004eb0 <exec+0x2d2>
    80004ecc:	de943c23          	sd	s1,-520(s0)
    80004ed0:	b7c5                	j	80004eb0 <exec+0x2d2>
    80004ed2:	de943c23          	sd	s1,-520(s0)
    80004ed6:	bfe9                	j	80004eb0 <exec+0x2d2>
  sz = sz1;
    80004ed8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004edc:	4a81                	li	s5,0
    80004ede:	bfc9                	j	80004eb0 <exec+0x2d2>
  sz = sz1;
    80004ee0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ee4:	4a81                	li	s5,0
    80004ee6:	b7e9                	j	80004eb0 <exec+0x2d2>
  sz = sz1;
    80004ee8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004eec:	4a81                	li	s5,0
    80004eee:	b7c9                	j	80004eb0 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004ef0:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ef4:	e0843783          	ld	a5,-504(s0)
    80004ef8:	0017869b          	addiw	a3,a5,1
    80004efc:	e0d43423          	sd	a3,-504(s0)
    80004f00:	e0043783          	ld	a5,-512(s0)
    80004f04:	0387879b          	addiw	a5,a5,56
    80004f08:	e8845703          	lhu	a4,-376(s0)
    80004f0c:	e2e6d3e3          	bge	a3,a4,80004d32 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f10:	2781                	sext.w	a5,a5
    80004f12:	e0f43023          	sd	a5,-512(s0)
    80004f16:	03800713          	li	a4,56
    80004f1a:	86be                	mv	a3,a5
    80004f1c:	e1840613          	addi	a2,s0,-488
    80004f20:	4581                	li	a1,0
    80004f22:	8556                	mv	a0,s5
    80004f24:	fffff097          	auipc	ra,0xfffff
    80004f28:	a76080e7          	jalr	-1418(ra) # 8000399a <readi>
    80004f2c:	03800793          	li	a5,56
    80004f30:	f6f51ee3          	bne	a0,a5,80004eac <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80004f34:	e1842783          	lw	a5,-488(s0)
    80004f38:	4705                	li	a4,1
    80004f3a:	fae79de3          	bne	a5,a4,80004ef4 <exec+0x316>
    if(ph.memsz < ph.filesz)
    80004f3e:	e4043603          	ld	a2,-448(s0)
    80004f42:	e3843783          	ld	a5,-456(s0)
    80004f46:	f8f660e3          	bltu	a2,a5,80004ec6 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f4a:	e2843783          	ld	a5,-472(s0)
    80004f4e:	963e                	add	a2,a2,a5
    80004f50:	f6f66ee3          	bltu	a2,a5,80004ecc <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f54:	85a6                	mv	a1,s1
    80004f56:	855a                	mv	a0,s6
    80004f58:	ffffc097          	auipc	ra,0xffffc
    80004f5c:	4ae080e7          	jalr	1198(ra) # 80001406 <uvmalloc>
    80004f60:	dea43c23          	sd	a0,-520(s0)
    80004f64:	d53d                	beqz	a0,80004ed2 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    80004f66:	e2843c03          	ld	s8,-472(s0)
    80004f6a:	de043783          	ld	a5,-544(s0)
    80004f6e:	00fc77b3          	and	a5,s8,a5
    80004f72:	ff9d                	bnez	a5,80004eb0 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f74:	e2042c83          	lw	s9,-480(s0)
    80004f78:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f7c:	f60b8ae3          	beqz	s7,80004ef0 <exec+0x312>
    80004f80:	89de                	mv	s3,s7
    80004f82:	4481                	li	s1,0
    80004f84:	b371                	j	80004d10 <exec+0x132>

0000000080004f86 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f86:	7179                	addi	sp,sp,-48
    80004f88:	f406                	sd	ra,40(sp)
    80004f8a:	f022                	sd	s0,32(sp)
    80004f8c:	ec26                	sd	s1,24(sp)
    80004f8e:	e84a                	sd	s2,16(sp)
    80004f90:	1800                	addi	s0,sp,48
    80004f92:	892e                	mv	s2,a1
    80004f94:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004f96:	fdc40593          	addi	a1,s0,-36
    80004f9a:	ffffe097          	auipc	ra,0xffffe
    80004f9e:	b32080e7          	jalr	-1230(ra) # 80002acc <argint>
    80004fa2:	04054063          	bltz	a0,80004fe2 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004fa6:	fdc42703          	lw	a4,-36(s0)
    80004faa:	47bd                	li	a5,15
    80004fac:	02e7ed63          	bltu	a5,a4,80004fe6 <argfd+0x60>
    80004fb0:	ffffd097          	auipc	ra,0xffffd
    80004fb4:	a66080e7          	jalr	-1434(ra) # 80001a16 <myproc>
    80004fb8:	fdc42703          	lw	a4,-36(s0)
    80004fbc:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd901a>
    80004fc0:	078e                	slli	a5,a5,0x3
    80004fc2:	953e                	add	a0,a0,a5
    80004fc4:	611c                	ld	a5,0(a0)
    80004fc6:	c395                	beqz	a5,80004fea <argfd+0x64>
    return -1;
  if(pfd)
    80004fc8:	00090463          	beqz	s2,80004fd0 <argfd+0x4a>
    *pfd = fd;
    80004fcc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004fd0:	4501                	li	a0,0
  if(pf)
    80004fd2:	c091                	beqz	s1,80004fd6 <argfd+0x50>
    *pf = f;
    80004fd4:	e09c                	sd	a5,0(s1)
}
    80004fd6:	70a2                	ld	ra,40(sp)
    80004fd8:	7402                	ld	s0,32(sp)
    80004fda:	64e2                	ld	s1,24(sp)
    80004fdc:	6942                	ld	s2,16(sp)
    80004fde:	6145                	addi	sp,sp,48
    80004fe0:	8082                	ret
    return -1;
    80004fe2:	557d                	li	a0,-1
    80004fe4:	bfcd                	j	80004fd6 <argfd+0x50>
    return -1;
    80004fe6:	557d                	li	a0,-1
    80004fe8:	b7fd                	j	80004fd6 <argfd+0x50>
    80004fea:	557d                	li	a0,-1
    80004fec:	b7ed                	j	80004fd6 <argfd+0x50>

0000000080004fee <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004fee:	1101                	addi	sp,sp,-32
    80004ff0:	ec06                	sd	ra,24(sp)
    80004ff2:	e822                	sd	s0,16(sp)
    80004ff4:	e426                	sd	s1,8(sp)
    80004ff6:	1000                	addi	s0,sp,32
    80004ff8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004ffa:	ffffd097          	auipc	ra,0xffffd
    80004ffe:	a1c080e7          	jalr	-1508(ra) # 80001a16 <myproc>
    80005002:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005004:	0d050793          	addi	a5,a0,208
    80005008:	4501                	li	a0,0
    8000500a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000500c:	6398                	ld	a4,0(a5)
    8000500e:	cb19                	beqz	a4,80005024 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005010:	2505                	addiw	a0,a0,1
    80005012:	07a1                	addi	a5,a5,8
    80005014:	fed51ce3          	bne	a0,a3,8000500c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005018:	557d                	li	a0,-1
}
    8000501a:	60e2                	ld	ra,24(sp)
    8000501c:	6442                	ld	s0,16(sp)
    8000501e:	64a2                	ld	s1,8(sp)
    80005020:	6105                	addi	sp,sp,32
    80005022:	8082                	ret
      p->ofile[fd] = f;
    80005024:	01a50793          	addi	a5,a0,26
    80005028:	078e                	slli	a5,a5,0x3
    8000502a:	963e                	add	a2,a2,a5
    8000502c:	e204                	sd	s1,0(a2)
      return fd;
    8000502e:	b7f5                	j	8000501a <fdalloc+0x2c>

0000000080005030 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005030:	715d                	addi	sp,sp,-80
    80005032:	e486                	sd	ra,72(sp)
    80005034:	e0a2                	sd	s0,64(sp)
    80005036:	fc26                	sd	s1,56(sp)
    80005038:	f84a                	sd	s2,48(sp)
    8000503a:	f44e                	sd	s3,40(sp)
    8000503c:	f052                	sd	s4,32(sp)
    8000503e:	ec56                	sd	s5,24(sp)
    80005040:	0880                	addi	s0,sp,80
    80005042:	89ae                	mv	s3,a1
    80005044:	8ab2                	mv	s5,a2
    80005046:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005048:	fb040593          	addi	a1,s0,-80
    8000504c:	fffff097          	auipc	ra,0xfffff
    80005050:	e74080e7          	jalr	-396(ra) # 80003ec0 <nameiparent>
    80005054:	892a                	mv	s2,a0
    80005056:	12050e63          	beqz	a0,80005192 <create+0x162>
    return 0;

  ilock(dp);
    8000505a:	ffffe097          	auipc	ra,0xffffe
    8000505e:	68c080e7          	jalr	1676(ra) # 800036e6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005062:	4601                	li	a2,0
    80005064:	fb040593          	addi	a1,s0,-80
    80005068:	854a                	mv	a0,s2
    8000506a:	fffff097          	auipc	ra,0xfffff
    8000506e:	b60080e7          	jalr	-1184(ra) # 80003bca <dirlookup>
    80005072:	84aa                	mv	s1,a0
    80005074:	c921                	beqz	a0,800050c4 <create+0x94>
    iunlockput(dp);
    80005076:	854a                	mv	a0,s2
    80005078:	fffff097          	auipc	ra,0xfffff
    8000507c:	8d0080e7          	jalr	-1840(ra) # 80003948 <iunlockput>
    ilock(ip);
    80005080:	8526                	mv	a0,s1
    80005082:	ffffe097          	auipc	ra,0xffffe
    80005086:	664080e7          	jalr	1636(ra) # 800036e6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000508a:	2981                	sext.w	s3,s3
    8000508c:	4789                	li	a5,2
    8000508e:	02f99463          	bne	s3,a5,800050b6 <create+0x86>
    80005092:	0444d783          	lhu	a5,68(s1)
    80005096:	37f9                	addiw	a5,a5,-2
    80005098:	17c2                	slli	a5,a5,0x30
    8000509a:	93c1                	srli	a5,a5,0x30
    8000509c:	4705                	li	a4,1
    8000509e:	00f76c63          	bltu	a4,a5,800050b6 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800050a2:	8526                	mv	a0,s1
    800050a4:	60a6                	ld	ra,72(sp)
    800050a6:	6406                	ld	s0,64(sp)
    800050a8:	74e2                	ld	s1,56(sp)
    800050aa:	7942                	ld	s2,48(sp)
    800050ac:	79a2                	ld	s3,40(sp)
    800050ae:	7a02                	ld	s4,32(sp)
    800050b0:	6ae2                	ld	s5,24(sp)
    800050b2:	6161                	addi	sp,sp,80
    800050b4:	8082                	ret
    iunlockput(ip);
    800050b6:	8526                	mv	a0,s1
    800050b8:	fffff097          	auipc	ra,0xfffff
    800050bc:	890080e7          	jalr	-1904(ra) # 80003948 <iunlockput>
    return 0;
    800050c0:	4481                	li	s1,0
    800050c2:	b7c5                	j	800050a2 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800050c4:	85ce                	mv	a1,s3
    800050c6:	00092503          	lw	a0,0(s2)
    800050ca:	ffffe097          	auipc	ra,0xffffe
    800050ce:	482080e7          	jalr	1154(ra) # 8000354c <ialloc>
    800050d2:	84aa                	mv	s1,a0
    800050d4:	c521                	beqz	a0,8000511c <create+0xec>
  ilock(ip);
    800050d6:	ffffe097          	auipc	ra,0xffffe
    800050da:	610080e7          	jalr	1552(ra) # 800036e6 <ilock>
  ip->major = major;
    800050de:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800050e2:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800050e6:	4a05                	li	s4,1
    800050e8:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800050ec:	8526                	mv	a0,s1
    800050ee:	ffffe097          	auipc	ra,0xffffe
    800050f2:	52c080e7          	jalr	1324(ra) # 8000361a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050f6:	2981                	sext.w	s3,s3
    800050f8:	03498a63          	beq	s3,s4,8000512c <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800050fc:	40d0                	lw	a2,4(s1)
    800050fe:	fb040593          	addi	a1,s0,-80
    80005102:	854a                	mv	a0,s2
    80005104:	fffff097          	auipc	ra,0xfffff
    80005108:	cdc080e7          	jalr	-804(ra) # 80003de0 <dirlink>
    8000510c:	06054b63          	bltz	a0,80005182 <create+0x152>
  iunlockput(dp);
    80005110:	854a                	mv	a0,s2
    80005112:	fffff097          	auipc	ra,0xfffff
    80005116:	836080e7          	jalr	-1994(ra) # 80003948 <iunlockput>
  return ip;
    8000511a:	b761                	j	800050a2 <create+0x72>
    panic("create: ialloc");
    8000511c:	00003517          	auipc	a0,0x3
    80005120:	6cc50513          	addi	a0,a0,1740 # 800087e8 <syscalls+0x320>
    80005124:	ffffb097          	auipc	ra,0xffffb
    80005128:	416080e7          	jalr	1046(ra) # 8000053a <panic>
    dp->nlink++;  // for ".."
    8000512c:	04a95783          	lhu	a5,74(s2)
    80005130:	2785                	addiw	a5,a5,1
    80005132:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005136:	854a                	mv	a0,s2
    80005138:	ffffe097          	auipc	ra,0xffffe
    8000513c:	4e2080e7          	jalr	1250(ra) # 8000361a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005140:	40d0                	lw	a2,4(s1)
    80005142:	00003597          	auipc	a1,0x3
    80005146:	6b658593          	addi	a1,a1,1718 # 800087f8 <syscalls+0x330>
    8000514a:	8526                	mv	a0,s1
    8000514c:	fffff097          	auipc	ra,0xfffff
    80005150:	c94080e7          	jalr	-876(ra) # 80003de0 <dirlink>
    80005154:	00054f63          	bltz	a0,80005172 <create+0x142>
    80005158:	00492603          	lw	a2,4(s2)
    8000515c:	00003597          	auipc	a1,0x3
    80005160:	6a458593          	addi	a1,a1,1700 # 80008800 <syscalls+0x338>
    80005164:	8526                	mv	a0,s1
    80005166:	fffff097          	auipc	ra,0xfffff
    8000516a:	c7a080e7          	jalr	-902(ra) # 80003de0 <dirlink>
    8000516e:	f80557e3          	bgez	a0,800050fc <create+0xcc>
      panic("create dots");
    80005172:	00003517          	auipc	a0,0x3
    80005176:	69650513          	addi	a0,a0,1686 # 80008808 <syscalls+0x340>
    8000517a:	ffffb097          	auipc	ra,0xffffb
    8000517e:	3c0080e7          	jalr	960(ra) # 8000053a <panic>
    panic("create: dirlink");
    80005182:	00003517          	auipc	a0,0x3
    80005186:	69650513          	addi	a0,a0,1686 # 80008818 <syscalls+0x350>
    8000518a:	ffffb097          	auipc	ra,0xffffb
    8000518e:	3b0080e7          	jalr	944(ra) # 8000053a <panic>
    return 0;
    80005192:	84aa                	mv	s1,a0
    80005194:	b739                	j	800050a2 <create+0x72>

0000000080005196 <sys_dup>:
{
    80005196:	7179                	addi	sp,sp,-48
    80005198:	f406                	sd	ra,40(sp)
    8000519a:	f022                	sd	s0,32(sp)
    8000519c:	ec26                	sd	s1,24(sp)
    8000519e:	e84a                	sd	s2,16(sp)
    800051a0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051a2:	fd840613          	addi	a2,s0,-40
    800051a6:	4581                	li	a1,0
    800051a8:	4501                	li	a0,0
    800051aa:	00000097          	auipc	ra,0x0
    800051ae:	ddc080e7          	jalr	-548(ra) # 80004f86 <argfd>
    return -1;
    800051b2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051b4:	02054363          	bltz	a0,800051da <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800051b8:	fd843903          	ld	s2,-40(s0)
    800051bc:	854a                	mv	a0,s2
    800051be:	00000097          	auipc	ra,0x0
    800051c2:	e30080e7          	jalr	-464(ra) # 80004fee <fdalloc>
    800051c6:	84aa                	mv	s1,a0
    return -1;
    800051c8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051ca:	00054863          	bltz	a0,800051da <sys_dup+0x44>
  filedup(f);
    800051ce:	854a                	mv	a0,s2
    800051d0:	fffff097          	auipc	ra,0xfffff
    800051d4:	368080e7          	jalr	872(ra) # 80004538 <filedup>
  return fd;
    800051d8:	87a6                	mv	a5,s1
}
    800051da:	853e                	mv	a0,a5
    800051dc:	70a2                	ld	ra,40(sp)
    800051de:	7402                	ld	s0,32(sp)
    800051e0:	64e2                	ld	s1,24(sp)
    800051e2:	6942                	ld	s2,16(sp)
    800051e4:	6145                	addi	sp,sp,48
    800051e6:	8082                	ret

00000000800051e8 <sys_read>:
{
    800051e8:	7179                	addi	sp,sp,-48
    800051ea:	f406                	sd	ra,40(sp)
    800051ec:	f022                	sd	s0,32(sp)
    800051ee:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051f0:	fe840613          	addi	a2,s0,-24
    800051f4:	4581                	li	a1,0
    800051f6:	4501                	li	a0,0
    800051f8:	00000097          	auipc	ra,0x0
    800051fc:	d8e080e7          	jalr	-626(ra) # 80004f86 <argfd>
    return -1;
    80005200:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005202:	04054163          	bltz	a0,80005244 <sys_read+0x5c>
    80005206:	fe440593          	addi	a1,s0,-28
    8000520a:	4509                	li	a0,2
    8000520c:	ffffe097          	auipc	ra,0xffffe
    80005210:	8c0080e7          	jalr	-1856(ra) # 80002acc <argint>
    return -1;
    80005214:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005216:	02054763          	bltz	a0,80005244 <sys_read+0x5c>
    8000521a:	fd840593          	addi	a1,s0,-40
    8000521e:	4505                	li	a0,1
    80005220:	ffffe097          	auipc	ra,0xffffe
    80005224:	8ce080e7          	jalr	-1842(ra) # 80002aee <argaddr>
    return -1;
    80005228:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000522a:	00054d63          	bltz	a0,80005244 <sys_read+0x5c>
  return fileread(f, p, n);
    8000522e:	fe442603          	lw	a2,-28(s0)
    80005232:	fd843583          	ld	a1,-40(s0)
    80005236:	fe843503          	ld	a0,-24(s0)
    8000523a:	fffff097          	auipc	ra,0xfffff
    8000523e:	48a080e7          	jalr	1162(ra) # 800046c4 <fileread>
    80005242:	87aa                	mv	a5,a0
}
    80005244:	853e                	mv	a0,a5
    80005246:	70a2                	ld	ra,40(sp)
    80005248:	7402                	ld	s0,32(sp)
    8000524a:	6145                	addi	sp,sp,48
    8000524c:	8082                	ret

000000008000524e <sys_write>:
{
    8000524e:	7179                	addi	sp,sp,-48
    80005250:	f406                	sd	ra,40(sp)
    80005252:	f022                	sd	s0,32(sp)
    80005254:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005256:	fe840613          	addi	a2,s0,-24
    8000525a:	4581                	li	a1,0
    8000525c:	4501                	li	a0,0
    8000525e:	00000097          	auipc	ra,0x0
    80005262:	d28080e7          	jalr	-728(ra) # 80004f86 <argfd>
    return -1;
    80005266:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005268:	04054163          	bltz	a0,800052aa <sys_write+0x5c>
    8000526c:	fe440593          	addi	a1,s0,-28
    80005270:	4509                	li	a0,2
    80005272:	ffffe097          	auipc	ra,0xffffe
    80005276:	85a080e7          	jalr	-1958(ra) # 80002acc <argint>
    return -1;
    8000527a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000527c:	02054763          	bltz	a0,800052aa <sys_write+0x5c>
    80005280:	fd840593          	addi	a1,s0,-40
    80005284:	4505                	li	a0,1
    80005286:	ffffe097          	auipc	ra,0xffffe
    8000528a:	868080e7          	jalr	-1944(ra) # 80002aee <argaddr>
    return -1;
    8000528e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005290:	00054d63          	bltz	a0,800052aa <sys_write+0x5c>
  return filewrite(f, p, n);
    80005294:	fe442603          	lw	a2,-28(s0)
    80005298:	fd843583          	ld	a1,-40(s0)
    8000529c:	fe843503          	ld	a0,-24(s0)
    800052a0:	fffff097          	auipc	ra,0xfffff
    800052a4:	4e6080e7          	jalr	1254(ra) # 80004786 <filewrite>
    800052a8:	87aa                	mv	a5,a0
}
    800052aa:	853e                	mv	a0,a5
    800052ac:	70a2                	ld	ra,40(sp)
    800052ae:	7402                	ld	s0,32(sp)
    800052b0:	6145                	addi	sp,sp,48
    800052b2:	8082                	ret

00000000800052b4 <sys_close>:
{
    800052b4:	1101                	addi	sp,sp,-32
    800052b6:	ec06                	sd	ra,24(sp)
    800052b8:	e822                	sd	s0,16(sp)
    800052ba:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800052bc:	fe040613          	addi	a2,s0,-32
    800052c0:	fec40593          	addi	a1,s0,-20
    800052c4:	4501                	li	a0,0
    800052c6:	00000097          	auipc	ra,0x0
    800052ca:	cc0080e7          	jalr	-832(ra) # 80004f86 <argfd>
    return -1;
    800052ce:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800052d0:	02054463          	bltz	a0,800052f8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800052d4:	ffffc097          	auipc	ra,0xffffc
    800052d8:	742080e7          	jalr	1858(ra) # 80001a16 <myproc>
    800052dc:	fec42783          	lw	a5,-20(s0)
    800052e0:	07e9                	addi	a5,a5,26
    800052e2:	078e                	slli	a5,a5,0x3
    800052e4:	953e                	add	a0,a0,a5
    800052e6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800052ea:	fe043503          	ld	a0,-32(s0)
    800052ee:	fffff097          	auipc	ra,0xfffff
    800052f2:	29c080e7          	jalr	668(ra) # 8000458a <fileclose>
  return 0;
    800052f6:	4781                	li	a5,0
}
    800052f8:	853e                	mv	a0,a5
    800052fa:	60e2                	ld	ra,24(sp)
    800052fc:	6442                	ld	s0,16(sp)
    800052fe:	6105                	addi	sp,sp,32
    80005300:	8082                	ret

0000000080005302 <sys_fstat>:
{
    80005302:	1101                	addi	sp,sp,-32
    80005304:	ec06                	sd	ra,24(sp)
    80005306:	e822                	sd	s0,16(sp)
    80005308:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000530a:	fe840613          	addi	a2,s0,-24
    8000530e:	4581                	li	a1,0
    80005310:	4501                	li	a0,0
    80005312:	00000097          	auipc	ra,0x0
    80005316:	c74080e7          	jalr	-908(ra) # 80004f86 <argfd>
    return -1;
    8000531a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000531c:	02054563          	bltz	a0,80005346 <sys_fstat+0x44>
    80005320:	fe040593          	addi	a1,s0,-32
    80005324:	4505                	li	a0,1
    80005326:	ffffd097          	auipc	ra,0xffffd
    8000532a:	7c8080e7          	jalr	1992(ra) # 80002aee <argaddr>
    return -1;
    8000532e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005330:	00054b63          	bltz	a0,80005346 <sys_fstat+0x44>
  return filestat(f, st);
    80005334:	fe043583          	ld	a1,-32(s0)
    80005338:	fe843503          	ld	a0,-24(s0)
    8000533c:	fffff097          	auipc	ra,0xfffff
    80005340:	316080e7          	jalr	790(ra) # 80004652 <filestat>
    80005344:	87aa                	mv	a5,a0
}
    80005346:	853e                	mv	a0,a5
    80005348:	60e2                	ld	ra,24(sp)
    8000534a:	6442                	ld	s0,16(sp)
    8000534c:	6105                	addi	sp,sp,32
    8000534e:	8082                	ret

0000000080005350 <sys_link>:
{
    80005350:	7169                	addi	sp,sp,-304
    80005352:	f606                	sd	ra,296(sp)
    80005354:	f222                	sd	s0,288(sp)
    80005356:	ee26                	sd	s1,280(sp)
    80005358:	ea4a                	sd	s2,272(sp)
    8000535a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000535c:	08000613          	li	a2,128
    80005360:	ed040593          	addi	a1,s0,-304
    80005364:	4501                	li	a0,0
    80005366:	ffffd097          	auipc	ra,0xffffd
    8000536a:	7aa080e7          	jalr	1962(ra) # 80002b10 <argstr>
    return -1;
    8000536e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005370:	10054e63          	bltz	a0,8000548c <sys_link+0x13c>
    80005374:	08000613          	li	a2,128
    80005378:	f5040593          	addi	a1,s0,-176
    8000537c:	4505                	li	a0,1
    8000537e:	ffffd097          	auipc	ra,0xffffd
    80005382:	792080e7          	jalr	1938(ra) # 80002b10 <argstr>
    return -1;
    80005386:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005388:	10054263          	bltz	a0,8000548c <sys_link+0x13c>
  begin_op();
    8000538c:	fffff097          	auipc	ra,0xfffff
    80005390:	d36080e7          	jalr	-714(ra) # 800040c2 <begin_op>
  if((ip = namei(old)) == 0){
    80005394:	ed040513          	addi	a0,s0,-304
    80005398:	fffff097          	auipc	ra,0xfffff
    8000539c:	b0a080e7          	jalr	-1270(ra) # 80003ea2 <namei>
    800053a0:	84aa                	mv	s1,a0
    800053a2:	c551                	beqz	a0,8000542e <sys_link+0xde>
  ilock(ip);
    800053a4:	ffffe097          	auipc	ra,0xffffe
    800053a8:	342080e7          	jalr	834(ra) # 800036e6 <ilock>
  if(ip->type == T_DIR){
    800053ac:	04449703          	lh	a4,68(s1)
    800053b0:	4785                	li	a5,1
    800053b2:	08f70463          	beq	a4,a5,8000543a <sys_link+0xea>
  ip->nlink++;
    800053b6:	04a4d783          	lhu	a5,74(s1)
    800053ba:	2785                	addiw	a5,a5,1
    800053bc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053c0:	8526                	mv	a0,s1
    800053c2:	ffffe097          	auipc	ra,0xffffe
    800053c6:	258080e7          	jalr	600(ra) # 8000361a <iupdate>
  iunlock(ip);
    800053ca:	8526                	mv	a0,s1
    800053cc:	ffffe097          	auipc	ra,0xffffe
    800053d0:	3dc080e7          	jalr	988(ra) # 800037a8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800053d4:	fd040593          	addi	a1,s0,-48
    800053d8:	f5040513          	addi	a0,s0,-176
    800053dc:	fffff097          	auipc	ra,0xfffff
    800053e0:	ae4080e7          	jalr	-1308(ra) # 80003ec0 <nameiparent>
    800053e4:	892a                	mv	s2,a0
    800053e6:	c935                	beqz	a0,8000545a <sys_link+0x10a>
  ilock(dp);
    800053e8:	ffffe097          	auipc	ra,0xffffe
    800053ec:	2fe080e7          	jalr	766(ra) # 800036e6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800053f0:	00092703          	lw	a4,0(s2)
    800053f4:	409c                	lw	a5,0(s1)
    800053f6:	04f71d63          	bne	a4,a5,80005450 <sys_link+0x100>
    800053fa:	40d0                	lw	a2,4(s1)
    800053fc:	fd040593          	addi	a1,s0,-48
    80005400:	854a                	mv	a0,s2
    80005402:	fffff097          	auipc	ra,0xfffff
    80005406:	9de080e7          	jalr	-1570(ra) # 80003de0 <dirlink>
    8000540a:	04054363          	bltz	a0,80005450 <sys_link+0x100>
  iunlockput(dp);
    8000540e:	854a                	mv	a0,s2
    80005410:	ffffe097          	auipc	ra,0xffffe
    80005414:	538080e7          	jalr	1336(ra) # 80003948 <iunlockput>
  iput(ip);
    80005418:	8526                	mv	a0,s1
    8000541a:	ffffe097          	auipc	ra,0xffffe
    8000541e:	486080e7          	jalr	1158(ra) # 800038a0 <iput>
  end_op();
    80005422:	fffff097          	auipc	ra,0xfffff
    80005426:	d1e080e7          	jalr	-738(ra) # 80004140 <end_op>
  return 0;
    8000542a:	4781                	li	a5,0
    8000542c:	a085                	j	8000548c <sys_link+0x13c>
    end_op();
    8000542e:	fffff097          	auipc	ra,0xfffff
    80005432:	d12080e7          	jalr	-750(ra) # 80004140 <end_op>
    return -1;
    80005436:	57fd                	li	a5,-1
    80005438:	a891                	j	8000548c <sys_link+0x13c>
    iunlockput(ip);
    8000543a:	8526                	mv	a0,s1
    8000543c:	ffffe097          	auipc	ra,0xffffe
    80005440:	50c080e7          	jalr	1292(ra) # 80003948 <iunlockput>
    end_op();
    80005444:	fffff097          	auipc	ra,0xfffff
    80005448:	cfc080e7          	jalr	-772(ra) # 80004140 <end_op>
    return -1;
    8000544c:	57fd                	li	a5,-1
    8000544e:	a83d                	j	8000548c <sys_link+0x13c>
    iunlockput(dp);
    80005450:	854a                	mv	a0,s2
    80005452:	ffffe097          	auipc	ra,0xffffe
    80005456:	4f6080e7          	jalr	1270(ra) # 80003948 <iunlockput>
  ilock(ip);
    8000545a:	8526                	mv	a0,s1
    8000545c:	ffffe097          	auipc	ra,0xffffe
    80005460:	28a080e7          	jalr	650(ra) # 800036e6 <ilock>
  ip->nlink--;
    80005464:	04a4d783          	lhu	a5,74(s1)
    80005468:	37fd                	addiw	a5,a5,-1
    8000546a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000546e:	8526                	mv	a0,s1
    80005470:	ffffe097          	auipc	ra,0xffffe
    80005474:	1aa080e7          	jalr	426(ra) # 8000361a <iupdate>
  iunlockput(ip);
    80005478:	8526                	mv	a0,s1
    8000547a:	ffffe097          	auipc	ra,0xffffe
    8000547e:	4ce080e7          	jalr	1230(ra) # 80003948 <iunlockput>
  end_op();
    80005482:	fffff097          	auipc	ra,0xfffff
    80005486:	cbe080e7          	jalr	-834(ra) # 80004140 <end_op>
  return -1;
    8000548a:	57fd                	li	a5,-1
}
    8000548c:	853e                	mv	a0,a5
    8000548e:	70b2                	ld	ra,296(sp)
    80005490:	7412                	ld	s0,288(sp)
    80005492:	64f2                	ld	s1,280(sp)
    80005494:	6952                	ld	s2,272(sp)
    80005496:	6155                	addi	sp,sp,304
    80005498:	8082                	ret

000000008000549a <sys_unlink>:
{
    8000549a:	7151                	addi	sp,sp,-240
    8000549c:	f586                	sd	ra,232(sp)
    8000549e:	f1a2                	sd	s0,224(sp)
    800054a0:	eda6                	sd	s1,216(sp)
    800054a2:	e9ca                	sd	s2,208(sp)
    800054a4:	e5ce                	sd	s3,200(sp)
    800054a6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800054a8:	08000613          	li	a2,128
    800054ac:	f3040593          	addi	a1,s0,-208
    800054b0:	4501                	li	a0,0
    800054b2:	ffffd097          	auipc	ra,0xffffd
    800054b6:	65e080e7          	jalr	1630(ra) # 80002b10 <argstr>
    800054ba:	18054163          	bltz	a0,8000563c <sys_unlink+0x1a2>
  begin_op();
    800054be:	fffff097          	auipc	ra,0xfffff
    800054c2:	c04080e7          	jalr	-1020(ra) # 800040c2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800054c6:	fb040593          	addi	a1,s0,-80
    800054ca:	f3040513          	addi	a0,s0,-208
    800054ce:	fffff097          	auipc	ra,0xfffff
    800054d2:	9f2080e7          	jalr	-1550(ra) # 80003ec0 <nameiparent>
    800054d6:	84aa                	mv	s1,a0
    800054d8:	c979                	beqz	a0,800055ae <sys_unlink+0x114>
  ilock(dp);
    800054da:	ffffe097          	auipc	ra,0xffffe
    800054de:	20c080e7          	jalr	524(ra) # 800036e6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800054e2:	00003597          	auipc	a1,0x3
    800054e6:	31658593          	addi	a1,a1,790 # 800087f8 <syscalls+0x330>
    800054ea:	fb040513          	addi	a0,s0,-80
    800054ee:	ffffe097          	auipc	ra,0xffffe
    800054f2:	6c2080e7          	jalr	1730(ra) # 80003bb0 <namecmp>
    800054f6:	14050a63          	beqz	a0,8000564a <sys_unlink+0x1b0>
    800054fa:	00003597          	auipc	a1,0x3
    800054fe:	30658593          	addi	a1,a1,774 # 80008800 <syscalls+0x338>
    80005502:	fb040513          	addi	a0,s0,-80
    80005506:	ffffe097          	auipc	ra,0xffffe
    8000550a:	6aa080e7          	jalr	1706(ra) # 80003bb0 <namecmp>
    8000550e:	12050e63          	beqz	a0,8000564a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005512:	f2c40613          	addi	a2,s0,-212
    80005516:	fb040593          	addi	a1,s0,-80
    8000551a:	8526                	mv	a0,s1
    8000551c:	ffffe097          	auipc	ra,0xffffe
    80005520:	6ae080e7          	jalr	1710(ra) # 80003bca <dirlookup>
    80005524:	892a                	mv	s2,a0
    80005526:	12050263          	beqz	a0,8000564a <sys_unlink+0x1b0>
  ilock(ip);
    8000552a:	ffffe097          	auipc	ra,0xffffe
    8000552e:	1bc080e7          	jalr	444(ra) # 800036e6 <ilock>
  if(ip->nlink < 1)
    80005532:	04a91783          	lh	a5,74(s2)
    80005536:	08f05263          	blez	a5,800055ba <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000553a:	04491703          	lh	a4,68(s2)
    8000553e:	4785                	li	a5,1
    80005540:	08f70563          	beq	a4,a5,800055ca <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005544:	4641                	li	a2,16
    80005546:	4581                	li	a1,0
    80005548:	fc040513          	addi	a0,s0,-64
    8000554c:	ffffb097          	auipc	ra,0xffffb
    80005550:	780080e7          	jalr	1920(ra) # 80000ccc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005554:	4741                	li	a4,16
    80005556:	f2c42683          	lw	a3,-212(s0)
    8000555a:	fc040613          	addi	a2,s0,-64
    8000555e:	4581                	li	a1,0
    80005560:	8526                	mv	a0,s1
    80005562:	ffffe097          	auipc	ra,0xffffe
    80005566:	530080e7          	jalr	1328(ra) # 80003a92 <writei>
    8000556a:	47c1                	li	a5,16
    8000556c:	0af51563          	bne	a0,a5,80005616 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005570:	04491703          	lh	a4,68(s2)
    80005574:	4785                	li	a5,1
    80005576:	0af70863          	beq	a4,a5,80005626 <sys_unlink+0x18c>
  iunlockput(dp);
    8000557a:	8526                	mv	a0,s1
    8000557c:	ffffe097          	auipc	ra,0xffffe
    80005580:	3cc080e7          	jalr	972(ra) # 80003948 <iunlockput>
  ip->nlink--;
    80005584:	04a95783          	lhu	a5,74(s2)
    80005588:	37fd                	addiw	a5,a5,-1
    8000558a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000558e:	854a                	mv	a0,s2
    80005590:	ffffe097          	auipc	ra,0xffffe
    80005594:	08a080e7          	jalr	138(ra) # 8000361a <iupdate>
  iunlockput(ip);
    80005598:	854a                	mv	a0,s2
    8000559a:	ffffe097          	auipc	ra,0xffffe
    8000559e:	3ae080e7          	jalr	942(ra) # 80003948 <iunlockput>
  end_op();
    800055a2:	fffff097          	auipc	ra,0xfffff
    800055a6:	b9e080e7          	jalr	-1122(ra) # 80004140 <end_op>
  return 0;
    800055aa:	4501                	li	a0,0
    800055ac:	a84d                	j	8000565e <sys_unlink+0x1c4>
    end_op();
    800055ae:	fffff097          	auipc	ra,0xfffff
    800055b2:	b92080e7          	jalr	-1134(ra) # 80004140 <end_op>
    return -1;
    800055b6:	557d                	li	a0,-1
    800055b8:	a05d                	j	8000565e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800055ba:	00003517          	auipc	a0,0x3
    800055be:	26e50513          	addi	a0,a0,622 # 80008828 <syscalls+0x360>
    800055c2:	ffffb097          	auipc	ra,0xffffb
    800055c6:	f78080e7          	jalr	-136(ra) # 8000053a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055ca:	04c92703          	lw	a4,76(s2)
    800055ce:	02000793          	li	a5,32
    800055d2:	f6e7f9e3          	bgeu	a5,a4,80005544 <sys_unlink+0xaa>
    800055d6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055da:	4741                	li	a4,16
    800055dc:	86ce                	mv	a3,s3
    800055de:	f1840613          	addi	a2,s0,-232
    800055e2:	4581                	li	a1,0
    800055e4:	854a                	mv	a0,s2
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	3b4080e7          	jalr	948(ra) # 8000399a <readi>
    800055ee:	47c1                	li	a5,16
    800055f0:	00f51b63          	bne	a0,a5,80005606 <sys_unlink+0x16c>
    if(de.inum != 0)
    800055f4:	f1845783          	lhu	a5,-232(s0)
    800055f8:	e7a1                	bnez	a5,80005640 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055fa:	29c1                	addiw	s3,s3,16
    800055fc:	04c92783          	lw	a5,76(s2)
    80005600:	fcf9ede3          	bltu	s3,a5,800055da <sys_unlink+0x140>
    80005604:	b781                	j	80005544 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005606:	00003517          	auipc	a0,0x3
    8000560a:	23a50513          	addi	a0,a0,570 # 80008840 <syscalls+0x378>
    8000560e:	ffffb097          	auipc	ra,0xffffb
    80005612:	f2c080e7          	jalr	-212(ra) # 8000053a <panic>
    panic("unlink: writei");
    80005616:	00003517          	auipc	a0,0x3
    8000561a:	24250513          	addi	a0,a0,578 # 80008858 <syscalls+0x390>
    8000561e:	ffffb097          	auipc	ra,0xffffb
    80005622:	f1c080e7          	jalr	-228(ra) # 8000053a <panic>
    dp->nlink--;
    80005626:	04a4d783          	lhu	a5,74(s1)
    8000562a:	37fd                	addiw	a5,a5,-1
    8000562c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005630:	8526                	mv	a0,s1
    80005632:	ffffe097          	auipc	ra,0xffffe
    80005636:	fe8080e7          	jalr	-24(ra) # 8000361a <iupdate>
    8000563a:	b781                	j	8000557a <sys_unlink+0xe0>
    return -1;
    8000563c:	557d                	li	a0,-1
    8000563e:	a005                	j	8000565e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005640:	854a                	mv	a0,s2
    80005642:	ffffe097          	auipc	ra,0xffffe
    80005646:	306080e7          	jalr	774(ra) # 80003948 <iunlockput>
  iunlockput(dp);
    8000564a:	8526                	mv	a0,s1
    8000564c:	ffffe097          	auipc	ra,0xffffe
    80005650:	2fc080e7          	jalr	764(ra) # 80003948 <iunlockput>
  end_op();
    80005654:	fffff097          	auipc	ra,0xfffff
    80005658:	aec080e7          	jalr	-1300(ra) # 80004140 <end_op>
  return -1;
    8000565c:	557d                	li	a0,-1
}
    8000565e:	70ae                	ld	ra,232(sp)
    80005660:	740e                	ld	s0,224(sp)
    80005662:	64ee                	ld	s1,216(sp)
    80005664:	694e                	ld	s2,208(sp)
    80005666:	69ae                	ld	s3,200(sp)
    80005668:	616d                	addi	sp,sp,240
    8000566a:	8082                	ret

000000008000566c <sys_open>:

uint64
sys_open(void)
{
    8000566c:	7131                	addi	sp,sp,-192
    8000566e:	fd06                	sd	ra,184(sp)
    80005670:	f922                	sd	s0,176(sp)
    80005672:	f526                	sd	s1,168(sp)
    80005674:	f14a                	sd	s2,160(sp)
    80005676:	ed4e                	sd	s3,152(sp)
    80005678:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000567a:	08000613          	li	a2,128
    8000567e:	f5040593          	addi	a1,s0,-176
    80005682:	4501                	li	a0,0
    80005684:	ffffd097          	auipc	ra,0xffffd
    80005688:	48c080e7          	jalr	1164(ra) # 80002b10 <argstr>
    return -1;
    8000568c:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000568e:	0c054163          	bltz	a0,80005750 <sys_open+0xe4>
    80005692:	f4c40593          	addi	a1,s0,-180
    80005696:	4505                	li	a0,1
    80005698:	ffffd097          	auipc	ra,0xffffd
    8000569c:	434080e7          	jalr	1076(ra) # 80002acc <argint>
    800056a0:	0a054863          	bltz	a0,80005750 <sys_open+0xe4>

  begin_op();
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	a1e080e7          	jalr	-1506(ra) # 800040c2 <begin_op>

  if(omode & O_CREATE){
    800056ac:	f4c42783          	lw	a5,-180(s0)
    800056b0:	2007f793          	andi	a5,a5,512
    800056b4:	cbdd                	beqz	a5,8000576a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800056b6:	4681                	li	a3,0
    800056b8:	4601                	li	a2,0
    800056ba:	4589                	li	a1,2
    800056bc:	f5040513          	addi	a0,s0,-176
    800056c0:	00000097          	auipc	ra,0x0
    800056c4:	970080e7          	jalr	-1680(ra) # 80005030 <create>
    800056c8:	892a                	mv	s2,a0
    if(ip == 0){
    800056ca:	c959                	beqz	a0,80005760 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800056cc:	04491703          	lh	a4,68(s2)
    800056d0:	478d                	li	a5,3
    800056d2:	00f71763          	bne	a4,a5,800056e0 <sys_open+0x74>
    800056d6:	04695703          	lhu	a4,70(s2)
    800056da:	47a5                	li	a5,9
    800056dc:	0ce7ec63          	bltu	a5,a4,800057b4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800056e0:	fffff097          	auipc	ra,0xfffff
    800056e4:	dee080e7          	jalr	-530(ra) # 800044ce <filealloc>
    800056e8:	89aa                	mv	s3,a0
    800056ea:	10050263          	beqz	a0,800057ee <sys_open+0x182>
    800056ee:	00000097          	auipc	ra,0x0
    800056f2:	900080e7          	jalr	-1792(ra) # 80004fee <fdalloc>
    800056f6:	84aa                	mv	s1,a0
    800056f8:	0e054663          	bltz	a0,800057e4 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800056fc:	04491703          	lh	a4,68(s2)
    80005700:	478d                	li	a5,3
    80005702:	0cf70463          	beq	a4,a5,800057ca <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005706:	4789                	li	a5,2
    80005708:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000570c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005710:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005714:	f4c42783          	lw	a5,-180(s0)
    80005718:	0017c713          	xori	a4,a5,1
    8000571c:	8b05                	andi	a4,a4,1
    8000571e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005722:	0037f713          	andi	a4,a5,3
    80005726:	00e03733          	snez	a4,a4
    8000572a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000572e:	4007f793          	andi	a5,a5,1024
    80005732:	c791                	beqz	a5,8000573e <sys_open+0xd2>
    80005734:	04491703          	lh	a4,68(s2)
    80005738:	4789                	li	a5,2
    8000573a:	08f70f63          	beq	a4,a5,800057d8 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000573e:	854a                	mv	a0,s2
    80005740:	ffffe097          	auipc	ra,0xffffe
    80005744:	068080e7          	jalr	104(ra) # 800037a8 <iunlock>
  end_op();
    80005748:	fffff097          	auipc	ra,0xfffff
    8000574c:	9f8080e7          	jalr	-1544(ra) # 80004140 <end_op>

  return fd;
}
    80005750:	8526                	mv	a0,s1
    80005752:	70ea                	ld	ra,184(sp)
    80005754:	744a                	ld	s0,176(sp)
    80005756:	74aa                	ld	s1,168(sp)
    80005758:	790a                	ld	s2,160(sp)
    8000575a:	69ea                	ld	s3,152(sp)
    8000575c:	6129                	addi	sp,sp,192
    8000575e:	8082                	ret
      end_op();
    80005760:	fffff097          	auipc	ra,0xfffff
    80005764:	9e0080e7          	jalr	-1568(ra) # 80004140 <end_op>
      return -1;
    80005768:	b7e5                	j	80005750 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000576a:	f5040513          	addi	a0,s0,-176
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	734080e7          	jalr	1844(ra) # 80003ea2 <namei>
    80005776:	892a                	mv	s2,a0
    80005778:	c905                	beqz	a0,800057a8 <sys_open+0x13c>
    ilock(ip);
    8000577a:	ffffe097          	auipc	ra,0xffffe
    8000577e:	f6c080e7          	jalr	-148(ra) # 800036e6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005782:	04491703          	lh	a4,68(s2)
    80005786:	4785                	li	a5,1
    80005788:	f4f712e3          	bne	a4,a5,800056cc <sys_open+0x60>
    8000578c:	f4c42783          	lw	a5,-180(s0)
    80005790:	dba1                	beqz	a5,800056e0 <sys_open+0x74>
      iunlockput(ip);
    80005792:	854a                	mv	a0,s2
    80005794:	ffffe097          	auipc	ra,0xffffe
    80005798:	1b4080e7          	jalr	436(ra) # 80003948 <iunlockput>
      end_op();
    8000579c:	fffff097          	auipc	ra,0xfffff
    800057a0:	9a4080e7          	jalr	-1628(ra) # 80004140 <end_op>
      return -1;
    800057a4:	54fd                	li	s1,-1
    800057a6:	b76d                	j	80005750 <sys_open+0xe4>
      end_op();
    800057a8:	fffff097          	auipc	ra,0xfffff
    800057ac:	998080e7          	jalr	-1640(ra) # 80004140 <end_op>
      return -1;
    800057b0:	54fd                	li	s1,-1
    800057b2:	bf79                	j	80005750 <sys_open+0xe4>
    iunlockput(ip);
    800057b4:	854a                	mv	a0,s2
    800057b6:	ffffe097          	auipc	ra,0xffffe
    800057ba:	192080e7          	jalr	402(ra) # 80003948 <iunlockput>
    end_op();
    800057be:	fffff097          	auipc	ra,0xfffff
    800057c2:	982080e7          	jalr	-1662(ra) # 80004140 <end_op>
    return -1;
    800057c6:	54fd                	li	s1,-1
    800057c8:	b761                	j	80005750 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800057ca:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800057ce:	04691783          	lh	a5,70(s2)
    800057d2:	02f99223          	sh	a5,36(s3)
    800057d6:	bf2d                	j	80005710 <sys_open+0xa4>
    itrunc(ip);
    800057d8:	854a                	mv	a0,s2
    800057da:	ffffe097          	auipc	ra,0xffffe
    800057de:	01a080e7          	jalr	26(ra) # 800037f4 <itrunc>
    800057e2:	bfb1                	j	8000573e <sys_open+0xd2>
      fileclose(f);
    800057e4:	854e                	mv	a0,s3
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	da4080e7          	jalr	-604(ra) # 8000458a <fileclose>
    iunlockput(ip);
    800057ee:	854a                	mv	a0,s2
    800057f0:	ffffe097          	auipc	ra,0xffffe
    800057f4:	158080e7          	jalr	344(ra) # 80003948 <iunlockput>
    end_op();
    800057f8:	fffff097          	auipc	ra,0xfffff
    800057fc:	948080e7          	jalr	-1720(ra) # 80004140 <end_op>
    return -1;
    80005800:	54fd                	li	s1,-1
    80005802:	b7b9                	j	80005750 <sys_open+0xe4>

0000000080005804 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005804:	7175                	addi	sp,sp,-144
    80005806:	e506                	sd	ra,136(sp)
    80005808:	e122                	sd	s0,128(sp)
    8000580a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000580c:	fffff097          	auipc	ra,0xfffff
    80005810:	8b6080e7          	jalr	-1866(ra) # 800040c2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005814:	08000613          	li	a2,128
    80005818:	f7040593          	addi	a1,s0,-144
    8000581c:	4501                	li	a0,0
    8000581e:	ffffd097          	auipc	ra,0xffffd
    80005822:	2f2080e7          	jalr	754(ra) # 80002b10 <argstr>
    80005826:	02054963          	bltz	a0,80005858 <sys_mkdir+0x54>
    8000582a:	4681                	li	a3,0
    8000582c:	4601                	li	a2,0
    8000582e:	4585                	li	a1,1
    80005830:	f7040513          	addi	a0,s0,-144
    80005834:	fffff097          	auipc	ra,0xfffff
    80005838:	7fc080e7          	jalr	2044(ra) # 80005030 <create>
    8000583c:	cd11                	beqz	a0,80005858 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000583e:	ffffe097          	auipc	ra,0xffffe
    80005842:	10a080e7          	jalr	266(ra) # 80003948 <iunlockput>
  end_op();
    80005846:	fffff097          	auipc	ra,0xfffff
    8000584a:	8fa080e7          	jalr	-1798(ra) # 80004140 <end_op>
  return 0;
    8000584e:	4501                	li	a0,0
}
    80005850:	60aa                	ld	ra,136(sp)
    80005852:	640a                	ld	s0,128(sp)
    80005854:	6149                	addi	sp,sp,144
    80005856:	8082                	ret
    end_op();
    80005858:	fffff097          	auipc	ra,0xfffff
    8000585c:	8e8080e7          	jalr	-1816(ra) # 80004140 <end_op>
    return -1;
    80005860:	557d                	li	a0,-1
    80005862:	b7fd                	j	80005850 <sys_mkdir+0x4c>

0000000080005864 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005864:	7135                	addi	sp,sp,-160
    80005866:	ed06                	sd	ra,152(sp)
    80005868:	e922                	sd	s0,144(sp)
    8000586a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000586c:	fffff097          	auipc	ra,0xfffff
    80005870:	856080e7          	jalr	-1962(ra) # 800040c2 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005874:	08000613          	li	a2,128
    80005878:	f7040593          	addi	a1,s0,-144
    8000587c:	4501                	li	a0,0
    8000587e:	ffffd097          	auipc	ra,0xffffd
    80005882:	292080e7          	jalr	658(ra) # 80002b10 <argstr>
    80005886:	04054a63          	bltz	a0,800058da <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000588a:	f6c40593          	addi	a1,s0,-148
    8000588e:	4505                	li	a0,1
    80005890:	ffffd097          	auipc	ra,0xffffd
    80005894:	23c080e7          	jalr	572(ra) # 80002acc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005898:	04054163          	bltz	a0,800058da <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000589c:	f6840593          	addi	a1,s0,-152
    800058a0:	4509                	li	a0,2
    800058a2:	ffffd097          	auipc	ra,0xffffd
    800058a6:	22a080e7          	jalr	554(ra) # 80002acc <argint>
     argint(1, &major) < 0 ||
    800058aa:	02054863          	bltz	a0,800058da <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800058ae:	f6841683          	lh	a3,-152(s0)
    800058b2:	f6c41603          	lh	a2,-148(s0)
    800058b6:	458d                	li	a1,3
    800058b8:	f7040513          	addi	a0,s0,-144
    800058bc:	fffff097          	auipc	ra,0xfffff
    800058c0:	774080e7          	jalr	1908(ra) # 80005030 <create>
     argint(2, &minor) < 0 ||
    800058c4:	c919                	beqz	a0,800058da <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058c6:	ffffe097          	auipc	ra,0xffffe
    800058ca:	082080e7          	jalr	130(ra) # 80003948 <iunlockput>
  end_op();
    800058ce:	fffff097          	auipc	ra,0xfffff
    800058d2:	872080e7          	jalr	-1934(ra) # 80004140 <end_op>
  return 0;
    800058d6:	4501                	li	a0,0
    800058d8:	a031                	j	800058e4 <sys_mknod+0x80>
    end_op();
    800058da:	fffff097          	auipc	ra,0xfffff
    800058de:	866080e7          	jalr	-1946(ra) # 80004140 <end_op>
    return -1;
    800058e2:	557d                	li	a0,-1
}
    800058e4:	60ea                	ld	ra,152(sp)
    800058e6:	644a                	ld	s0,144(sp)
    800058e8:	610d                	addi	sp,sp,160
    800058ea:	8082                	ret

00000000800058ec <sys_chdir>:

uint64
sys_chdir(void)
{
    800058ec:	7135                	addi	sp,sp,-160
    800058ee:	ed06                	sd	ra,152(sp)
    800058f0:	e922                	sd	s0,144(sp)
    800058f2:	e526                	sd	s1,136(sp)
    800058f4:	e14a                	sd	s2,128(sp)
    800058f6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800058f8:	ffffc097          	auipc	ra,0xffffc
    800058fc:	11e080e7          	jalr	286(ra) # 80001a16 <myproc>
    80005900:	892a                	mv	s2,a0
  
  begin_op();
    80005902:	ffffe097          	auipc	ra,0xffffe
    80005906:	7c0080e7          	jalr	1984(ra) # 800040c2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000590a:	08000613          	li	a2,128
    8000590e:	f6040593          	addi	a1,s0,-160
    80005912:	4501                	li	a0,0
    80005914:	ffffd097          	auipc	ra,0xffffd
    80005918:	1fc080e7          	jalr	508(ra) # 80002b10 <argstr>
    8000591c:	04054b63          	bltz	a0,80005972 <sys_chdir+0x86>
    80005920:	f6040513          	addi	a0,s0,-160
    80005924:	ffffe097          	auipc	ra,0xffffe
    80005928:	57e080e7          	jalr	1406(ra) # 80003ea2 <namei>
    8000592c:	84aa                	mv	s1,a0
    8000592e:	c131                	beqz	a0,80005972 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005930:	ffffe097          	auipc	ra,0xffffe
    80005934:	db6080e7          	jalr	-586(ra) # 800036e6 <ilock>
  if(ip->type != T_DIR){
    80005938:	04449703          	lh	a4,68(s1)
    8000593c:	4785                	li	a5,1
    8000593e:	04f71063          	bne	a4,a5,8000597e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005942:	8526                	mv	a0,s1
    80005944:	ffffe097          	auipc	ra,0xffffe
    80005948:	e64080e7          	jalr	-412(ra) # 800037a8 <iunlock>
  iput(p->cwd);
    8000594c:	15093503          	ld	a0,336(s2)
    80005950:	ffffe097          	auipc	ra,0xffffe
    80005954:	f50080e7          	jalr	-176(ra) # 800038a0 <iput>
  end_op();
    80005958:	ffffe097          	auipc	ra,0xffffe
    8000595c:	7e8080e7          	jalr	2024(ra) # 80004140 <end_op>
  p->cwd = ip;
    80005960:	14993823          	sd	s1,336(s2)
  return 0;
    80005964:	4501                	li	a0,0
}
    80005966:	60ea                	ld	ra,152(sp)
    80005968:	644a                	ld	s0,144(sp)
    8000596a:	64aa                	ld	s1,136(sp)
    8000596c:	690a                	ld	s2,128(sp)
    8000596e:	610d                	addi	sp,sp,160
    80005970:	8082                	ret
    end_op();
    80005972:	ffffe097          	auipc	ra,0xffffe
    80005976:	7ce080e7          	jalr	1998(ra) # 80004140 <end_op>
    return -1;
    8000597a:	557d                	li	a0,-1
    8000597c:	b7ed                	j	80005966 <sys_chdir+0x7a>
    iunlockput(ip);
    8000597e:	8526                	mv	a0,s1
    80005980:	ffffe097          	auipc	ra,0xffffe
    80005984:	fc8080e7          	jalr	-56(ra) # 80003948 <iunlockput>
    end_op();
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	7b8080e7          	jalr	1976(ra) # 80004140 <end_op>
    return -1;
    80005990:	557d                	li	a0,-1
    80005992:	bfd1                	j	80005966 <sys_chdir+0x7a>

0000000080005994 <sys_exec>:

uint64
sys_exec(void)
{
    80005994:	7145                	addi	sp,sp,-464
    80005996:	e786                	sd	ra,456(sp)
    80005998:	e3a2                	sd	s0,448(sp)
    8000599a:	ff26                	sd	s1,440(sp)
    8000599c:	fb4a                	sd	s2,432(sp)
    8000599e:	f74e                	sd	s3,424(sp)
    800059a0:	f352                	sd	s4,416(sp)
    800059a2:	ef56                	sd	s5,408(sp)
    800059a4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800059a6:	08000613          	li	a2,128
    800059aa:	f4040593          	addi	a1,s0,-192
    800059ae:	4501                	li	a0,0
    800059b0:	ffffd097          	auipc	ra,0xffffd
    800059b4:	160080e7          	jalr	352(ra) # 80002b10 <argstr>
    return -1;
    800059b8:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800059ba:	0c054b63          	bltz	a0,80005a90 <sys_exec+0xfc>
    800059be:	e3840593          	addi	a1,s0,-456
    800059c2:	4505                	li	a0,1
    800059c4:	ffffd097          	auipc	ra,0xffffd
    800059c8:	12a080e7          	jalr	298(ra) # 80002aee <argaddr>
    800059cc:	0c054263          	bltz	a0,80005a90 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800059d0:	10000613          	li	a2,256
    800059d4:	4581                	li	a1,0
    800059d6:	e4040513          	addi	a0,s0,-448
    800059da:	ffffb097          	auipc	ra,0xffffb
    800059de:	2f2080e7          	jalr	754(ra) # 80000ccc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800059e2:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800059e6:	89a6                	mv	s3,s1
    800059e8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800059ea:	02000a13          	li	s4,32
    800059ee:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800059f2:	00391513          	slli	a0,s2,0x3
    800059f6:	e3040593          	addi	a1,s0,-464
    800059fa:	e3843783          	ld	a5,-456(s0)
    800059fe:	953e                	add	a0,a0,a5
    80005a00:	ffffd097          	auipc	ra,0xffffd
    80005a04:	032080e7          	jalr	50(ra) # 80002a32 <fetchaddr>
    80005a08:	02054a63          	bltz	a0,80005a3c <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005a0c:	e3043783          	ld	a5,-464(s0)
    80005a10:	c3b9                	beqz	a5,80005a56 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a12:	ffffb097          	auipc	ra,0xffffb
    80005a16:	0ce080e7          	jalr	206(ra) # 80000ae0 <kalloc>
    80005a1a:	85aa                	mv	a1,a0
    80005a1c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a20:	cd11                	beqz	a0,80005a3c <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a22:	6605                	lui	a2,0x1
    80005a24:	e3043503          	ld	a0,-464(s0)
    80005a28:	ffffd097          	auipc	ra,0xffffd
    80005a2c:	05c080e7          	jalr	92(ra) # 80002a84 <fetchstr>
    80005a30:	00054663          	bltz	a0,80005a3c <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005a34:	0905                	addi	s2,s2,1
    80005a36:	09a1                	addi	s3,s3,8
    80005a38:	fb491be3          	bne	s2,s4,800059ee <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a3c:	f4040913          	addi	s2,s0,-192
    80005a40:	6088                	ld	a0,0(s1)
    80005a42:	c531                	beqz	a0,80005a8e <sys_exec+0xfa>
    kfree(argv[i]);
    80005a44:	ffffb097          	auipc	ra,0xffffb
    80005a48:	f9e080e7          	jalr	-98(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a4c:	04a1                	addi	s1,s1,8
    80005a4e:	ff2499e3          	bne	s1,s2,80005a40 <sys_exec+0xac>
  return -1;
    80005a52:	597d                	li	s2,-1
    80005a54:	a835                	j	80005a90 <sys_exec+0xfc>
      argv[i] = 0;
    80005a56:	0a8e                	slli	s5,s5,0x3
    80005a58:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd8fc0>
    80005a5c:	00878ab3          	add	s5,a5,s0
    80005a60:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005a64:	e4040593          	addi	a1,s0,-448
    80005a68:	f4040513          	addi	a0,s0,-192
    80005a6c:	fffff097          	auipc	ra,0xfffff
    80005a70:	172080e7          	jalr	370(ra) # 80004bde <exec>
    80005a74:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a76:	f4040993          	addi	s3,s0,-192
    80005a7a:	6088                	ld	a0,0(s1)
    80005a7c:	c911                	beqz	a0,80005a90 <sys_exec+0xfc>
    kfree(argv[i]);
    80005a7e:	ffffb097          	auipc	ra,0xffffb
    80005a82:	f64080e7          	jalr	-156(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a86:	04a1                	addi	s1,s1,8
    80005a88:	ff3499e3          	bne	s1,s3,80005a7a <sys_exec+0xe6>
    80005a8c:	a011                	j	80005a90 <sys_exec+0xfc>
  return -1;
    80005a8e:	597d                	li	s2,-1
}
    80005a90:	854a                	mv	a0,s2
    80005a92:	60be                	ld	ra,456(sp)
    80005a94:	641e                	ld	s0,448(sp)
    80005a96:	74fa                	ld	s1,440(sp)
    80005a98:	795a                	ld	s2,432(sp)
    80005a9a:	79ba                	ld	s3,424(sp)
    80005a9c:	7a1a                	ld	s4,416(sp)
    80005a9e:	6afa                	ld	s5,408(sp)
    80005aa0:	6179                	addi	sp,sp,464
    80005aa2:	8082                	ret

0000000080005aa4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005aa4:	7139                	addi	sp,sp,-64
    80005aa6:	fc06                	sd	ra,56(sp)
    80005aa8:	f822                	sd	s0,48(sp)
    80005aaa:	f426                	sd	s1,40(sp)
    80005aac:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005aae:	ffffc097          	auipc	ra,0xffffc
    80005ab2:	f68080e7          	jalr	-152(ra) # 80001a16 <myproc>
    80005ab6:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005ab8:	fd840593          	addi	a1,s0,-40
    80005abc:	4501                	li	a0,0
    80005abe:	ffffd097          	auipc	ra,0xffffd
    80005ac2:	030080e7          	jalr	48(ra) # 80002aee <argaddr>
    return -1;
    80005ac6:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005ac8:	0e054063          	bltz	a0,80005ba8 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005acc:	fc840593          	addi	a1,s0,-56
    80005ad0:	fd040513          	addi	a0,s0,-48
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	de6080e7          	jalr	-538(ra) # 800048ba <pipealloc>
    return -1;
    80005adc:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ade:	0c054563          	bltz	a0,80005ba8 <sys_pipe+0x104>
  fd0 = -1;
    80005ae2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005ae6:	fd043503          	ld	a0,-48(s0)
    80005aea:	fffff097          	auipc	ra,0xfffff
    80005aee:	504080e7          	jalr	1284(ra) # 80004fee <fdalloc>
    80005af2:	fca42223          	sw	a0,-60(s0)
    80005af6:	08054c63          	bltz	a0,80005b8e <sys_pipe+0xea>
    80005afa:	fc843503          	ld	a0,-56(s0)
    80005afe:	fffff097          	auipc	ra,0xfffff
    80005b02:	4f0080e7          	jalr	1264(ra) # 80004fee <fdalloc>
    80005b06:	fca42023          	sw	a0,-64(s0)
    80005b0a:	06054963          	bltz	a0,80005b7c <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b0e:	4691                	li	a3,4
    80005b10:	fc440613          	addi	a2,s0,-60
    80005b14:	fd843583          	ld	a1,-40(s0)
    80005b18:	68a8                	ld	a0,80(s1)
    80005b1a:	ffffc097          	auipc	ra,0xffffc
    80005b1e:	b40080e7          	jalr	-1216(ra) # 8000165a <copyout>
    80005b22:	02054063          	bltz	a0,80005b42 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b26:	4691                	li	a3,4
    80005b28:	fc040613          	addi	a2,s0,-64
    80005b2c:	fd843583          	ld	a1,-40(s0)
    80005b30:	0591                	addi	a1,a1,4
    80005b32:	68a8                	ld	a0,80(s1)
    80005b34:	ffffc097          	auipc	ra,0xffffc
    80005b38:	b26080e7          	jalr	-1242(ra) # 8000165a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b3c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b3e:	06055563          	bgez	a0,80005ba8 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005b42:	fc442783          	lw	a5,-60(s0)
    80005b46:	07e9                	addi	a5,a5,26
    80005b48:	078e                	slli	a5,a5,0x3
    80005b4a:	97a6                	add	a5,a5,s1
    80005b4c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b50:	fc042783          	lw	a5,-64(s0)
    80005b54:	07e9                	addi	a5,a5,26
    80005b56:	078e                	slli	a5,a5,0x3
    80005b58:	00f48533          	add	a0,s1,a5
    80005b5c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b60:	fd043503          	ld	a0,-48(s0)
    80005b64:	fffff097          	auipc	ra,0xfffff
    80005b68:	a26080e7          	jalr	-1498(ra) # 8000458a <fileclose>
    fileclose(wf);
    80005b6c:	fc843503          	ld	a0,-56(s0)
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	a1a080e7          	jalr	-1510(ra) # 8000458a <fileclose>
    return -1;
    80005b78:	57fd                	li	a5,-1
    80005b7a:	a03d                	j	80005ba8 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005b7c:	fc442783          	lw	a5,-60(s0)
    80005b80:	0007c763          	bltz	a5,80005b8e <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005b84:	07e9                	addi	a5,a5,26
    80005b86:	078e                	slli	a5,a5,0x3
    80005b88:	97a6                	add	a5,a5,s1
    80005b8a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005b8e:	fd043503          	ld	a0,-48(s0)
    80005b92:	fffff097          	auipc	ra,0xfffff
    80005b96:	9f8080e7          	jalr	-1544(ra) # 8000458a <fileclose>
    fileclose(wf);
    80005b9a:	fc843503          	ld	a0,-56(s0)
    80005b9e:	fffff097          	auipc	ra,0xfffff
    80005ba2:	9ec080e7          	jalr	-1556(ra) # 8000458a <fileclose>
    return -1;
    80005ba6:	57fd                	li	a5,-1
}
    80005ba8:	853e                	mv	a0,a5
    80005baa:	70e2                	ld	ra,56(sp)
    80005bac:	7442                	ld	s0,48(sp)
    80005bae:	74a2                	ld	s1,40(sp)
    80005bb0:	6121                	addi	sp,sp,64
    80005bb2:	8082                	ret
	...

0000000080005bc0 <kernelvec>:
    80005bc0:	7111                	addi	sp,sp,-256
    80005bc2:	e006                	sd	ra,0(sp)
    80005bc4:	e40a                	sd	sp,8(sp)
    80005bc6:	e80e                	sd	gp,16(sp)
    80005bc8:	ec12                	sd	tp,24(sp)
    80005bca:	f016                	sd	t0,32(sp)
    80005bcc:	f41a                	sd	t1,40(sp)
    80005bce:	f81e                	sd	t2,48(sp)
    80005bd0:	fc22                	sd	s0,56(sp)
    80005bd2:	e0a6                	sd	s1,64(sp)
    80005bd4:	e4aa                	sd	a0,72(sp)
    80005bd6:	e8ae                	sd	a1,80(sp)
    80005bd8:	ecb2                	sd	a2,88(sp)
    80005bda:	f0b6                	sd	a3,96(sp)
    80005bdc:	f4ba                	sd	a4,104(sp)
    80005bde:	f8be                	sd	a5,112(sp)
    80005be0:	fcc2                	sd	a6,120(sp)
    80005be2:	e146                	sd	a7,128(sp)
    80005be4:	e54a                	sd	s2,136(sp)
    80005be6:	e94e                	sd	s3,144(sp)
    80005be8:	ed52                	sd	s4,152(sp)
    80005bea:	f156                	sd	s5,160(sp)
    80005bec:	f55a                	sd	s6,168(sp)
    80005bee:	f95e                	sd	s7,176(sp)
    80005bf0:	fd62                	sd	s8,184(sp)
    80005bf2:	e1e6                	sd	s9,192(sp)
    80005bf4:	e5ea                	sd	s10,200(sp)
    80005bf6:	e9ee                	sd	s11,208(sp)
    80005bf8:	edf2                	sd	t3,216(sp)
    80005bfa:	f1f6                	sd	t4,224(sp)
    80005bfc:	f5fa                	sd	t5,232(sp)
    80005bfe:	f9fe                	sd	t6,240(sp)
    80005c00:	cfffc0ef          	jal	ra,800028fe <kerneltrap>
    80005c04:	6082                	ld	ra,0(sp)
    80005c06:	6122                	ld	sp,8(sp)
    80005c08:	61c2                	ld	gp,16(sp)
    80005c0a:	7282                	ld	t0,32(sp)
    80005c0c:	7322                	ld	t1,40(sp)
    80005c0e:	73c2                	ld	t2,48(sp)
    80005c10:	7462                	ld	s0,56(sp)
    80005c12:	6486                	ld	s1,64(sp)
    80005c14:	6526                	ld	a0,72(sp)
    80005c16:	65c6                	ld	a1,80(sp)
    80005c18:	6666                	ld	a2,88(sp)
    80005c1a:	7686                	ld	a3,96(sp)
    80005c1c:	7726                	ld	a4,104(sp)
    80005c1e:	77c6                	ld	a5,112(sp)
    80005c20:	7866                	ld	a6,120(sp)
    80005c22:	688a                	ld	a7,128(sp)
    80005c24:	692a                	ld	s2,136(sp)
    80005c26:	69ca                	ld	s3,144(sp)
    80005c28:	6a6a                	ld	s4,152(sp)
    80005c2a:	7a8a                	ld	s5,160(sp)
    80005c2c:	7b2a                	ld	s6,168(sp)
    80005c2e:	7bca                	ld	s7,176(sp)
    80005c30:	7c6a                	ld	s8,184(sp)
    80005c32:	6c8e                	ld	s9,192(sp)
    80005c34:	6d2e                	ld	s10,200(sp)
    80005c36:	6dce                	ld	s11,208(sp)
    80005c38:	6e6e                	ld	t3,216(sp)
    80005c3a:	7e8e                	ld	t4,224(sp)
    80005c3c:	7f2e                	ld	t5,232(sp)
    80005c3e:	7fce                	ld	t6,240(sp)
    80005c40:	6111                	addi	sp,sp,256
    80005c42:	10200073          	sret
    80005c46:	00000013          	nop
    80005c4a:	00000013          	nop
    80005c4e:	0001                	nop

0000000080005c50 <timervec>:
    80005c50:	34051573          	csrrw	a0,mscratch,a0
    80005c54:	e10c                	sd	a1,0(a0)
    80005c56:	e510                	sd	a2,8(a0)
    80005c58:	e914                	sd	a3,16(a0)
    80005c5a:	6d0c                	ld	a1,24(a0)
    80005c5c:	7110                	ld	a2,32(a0)
    80005c5e:	6194                	ld	a3,0(a1)
    80005c60:	96b2                	add	a3,a3,a2
    80005c62:	e194                	sd	a3,0(a1)
    80005c64:	4589                	li	a1,2
    80005c66:	14459073          	csrw	sip,a1
    80005c6a:	6914                	ld	a3,16(a0)
    80005c6c:	6510                	ld	a2,8(a0)
    80005c6e:	610c                	ld	a1,0(a0)
    80005c70:	34051573          	csrrw	a0,mscratch,a0
    80005c74:	30200073          	mret
	...

0000000080005c7a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c7a:	1141                	addi	sp,sp,-16
    80005c7c:	e422                	sd	s0,8(sp)
    80005c7e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c80:	0c0007b7          	lui	a5,0xc000
    80005c84:	4705                	li	a4,1
    80005c86:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c88:	c3d8                	sw	a4,4(a5)
}
    80005c8a:	6422                	ld	s0,8(sp)
    80005c8c:	0141                	addi	sp,sp,16
    80005c8e:	8082                	ret

0000000080005c90 <plicinithart>:

void
plicinithart(void)
{
    80005c90:	1141                	addi	sp,sp,-16
    80005c92:	e406                	sd	ra,8(sp)
    80005c94:	e022                	sd	s0,0(sp)
    80005c96:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c98:	ffffc097          	auipc	ra,0xffffc
    80005c9c:	d52080e7          	jalr	-686(ra) # 800019ea <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ca0:	0085171b          	slliw	a4,a0,0x8
    80005ca4:	0c0027b7          	lui	a5,0xc002
    80005ca8:	97ba                	add	a5,a5,a4
    80005caa:	40200713          	li	a4,1026
    80005cae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005cb2:	00d5151b          	slliw	a0,a0,0xd
    80005cb6:	0c2017b7          	lui	a5,0xc201
    80005cba:	97aa                	add	a5,a5,a0
    80005cbc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005cc0:	60a2                	ld	ra,8(sp)
    80005cc2:	6402                	ld	s0,0(sp)
    80005cc4:	0141                	addi	sp,sp,16
    80005cc6:	8082                	ret

0000000080005cc8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005cc8:	1141                	addi	sp,sp,-16
    80005cca:	e406                	sd	ra,8(sp)
    80005ccc:	e022                	sd	s0,0(sp)
    80005cce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005cd0:	ffffc097          	auipc	ra,0xffffc
    80005cd4:	d1a080e7          	jalr	-742(ra) # 800019ea <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005cd8:	00d5151b          	slliw	a0,a0,0xd
    80005cdc:	0c2017b7          	lui	a5,0xc201
    80005ce0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005ce2:	43c8                	lw	a0,4(a5)
    80005ce4:	60a2                	ld	ra,8(sp)
    80005ce6:	6402                	ld	s0,0(sp)
    80005ce8:	0141                	addi	sp,sp,16
    80005cea:	8082                	ret

0000000080005cec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005cec:	1101                	addi	sp,sp,-32
    80005cee:	ec06                	sd	ra,24(sp)
    80005cf0:	e822                	sd	s0,16(sp)
    80005cf2:	e426                	sd	s1,8(sp)
    80005cf4:	1000                	addi	s0,sp,32
    80005cf6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005cf8:	ffffc097          	auipc	ra,0xffffc
    80005cfc:	cf2080e7          	jalr	-782(ra) # 800019ea <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d00:	00d5151b          	slliw	a0,a0,0xd
    80005d04:	0c2017b7          	lui	a5,0xc201
    80005d08:	97aa                	add	a5,a5,a0
    80005d0a:	c3c4                	sw	s1,4(a5)
}
    80005d0c:	60e2                	ld	ra,24(sp)
    80005d0e:	6442                	ld	s0,16(sp)
    80005d10:	64a2                	ld	s1,8(sp)
    80005d12:	6105                	addi	sp,sp,32
    80005d14:	8082                	ret

0000000080005d16 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d16:	1141                	addi	sp,sp,-16
    80005d18:	e406                	sd	ra,8(sp)
    80005d1a:	e022                	sd	s0,0(sp)
    80005d1c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d1e:	479d                	li	a5,7
    80005d20:	06a7c863          	blt	a5,a0,80005d90 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80005d24:	0001d717          	auipc	a4,0x1d
    80005d28:	2dc70713          	addi	a4,a4,732 # 80023000 <disk>
    80005d2c:	972a                	add	a4,a4,a0
    80005d2e:	6789                	lui	a5,0x2
    80005d30:	97ba                	add	a5,a5,a4
    80005d32:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005d36:	e7ad                	bnez	a5,80005da0 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d38:	00451793          	slli	a5,a0,0x4
    80005d3c:	0001f717          	auipc	a4,0x1f
    80005d40:	2c470713          	addi	a4,a4,708 # 80025000 <disk+0x2000>
    80005d44:	6314                	ld	a3,0(a4)
    80005d46:	96be                	add	a3,a3,a5
    80005d48:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005d4c:	6314                	ld	a3,0(a4)
    80005d4e:	96be                	add	a3,a3,a5
    80005d50:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005d54:	6314                	ld	a3,0(a4)
    80005d56:	96be                	add	a3,a3,a5
    80005d58:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005d5c:	6318                	ld	a4,0(a4)
    80005d5e:	97ba                	add	a5,a5,a4
    80005d60:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005d64:	0001d717          	auipc	a4,0x1d
    80005d68:	29c70713          	addi	a4,a4,668 # 80023000 <disk>
    80005d6c:	972a                	add	a4,a4,a0
    80005d6e:	6789                	lui	a5,0x2
    80005d70:	97ba                	add	a5,a5,a4
    80005d72:	4705                	li	a4,1
    80005d74:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005d78:	0001f517          	auipc	a0,0x1f
    80005d7c:	2a050513          	addi	a0,a0,672 # 80025018 <disk+0x2018>
    80005d80:	ffffc097          	auipc	ra,0xffffc
    80005d84:	4e6080e7          	jalr	1254(ra) # 80002266 <wakeup>
}
    80005d88:	60a2                	ld	ra,8(sp)
    80005d8a:	6402                	ld	s0,0(sp)
    80005d8c:	0141                	addi	sp,sp,16
    80005d8e:	8082                	ret
    panic("free_desc 1");
    80005d90:	00003517          	auipc	a0,0x3
    80005d94:	ad850513          	addi	a0,a0,-1320 # 80008868 <syscalls+0x3a0>
    80005d98:	ffffa097          	auipc	ra,0xffffa
    80005d9c:	7a2080e7          	jalr	1954(ra) # 8000053a <panic>
    panic("free_desc 2");
    80005da0:	00003517          	auipc	a0,0x3
    80005da4:	ad850513          	addi	a0,a0,-1320 # 80008878 <syscalls+0x3b0>
    80005da8:	ffffa097          	auipc	ra,0xffffa
    80005dac:	792080e7          	jalr	1938(ra) # 8000053a <panic>

0000000080005db0 <virtio_disk_init>:
{
    80005db0:	1101                	addi	sp,sp,-32
    80005db2:	ec06                	sd	ra,24(sp)
    80005db4:	e822                	sd	s0,16(sp)
    80005db6:	e426                	sd	s1,8(sp)
    80005db8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005dba:	00003597          	auipc	a1,0x3
    80005dbe:	ace58593          	addi	a1,a1,-1330 # 80008888 <syscalls+0x3c0>
    80005dc2:	0001f517          	auipc	a0,0x1f
    80005dc6:	36650513          	addi	a0,a0,870 # 80025128 <disk+0x2128>
    80005dca:	ffffb097          	auipc	ra,0xffffb
    80005dce:	d76080e7          	jalr	-650(ra) # 80000b40 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005dd2:	100017b7          	lui	a5,0x10001
    80005dd6:	4398                	lw	a4,0(a5)
    80005dd8:	2701                	sext.w	a4,a4
    80005dda:	747277b7          	lui	a5,0x74727
    80005dde:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005de2:	0ef71063          	bne	a4,a5,80005ec2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005de6:	100017b7          	lui	a5,0x10001
    80005dea:	43dc                	lw	a5,4(a5)
    80005dec:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005dee:	4705                	li	a4,1
    80005df0:	0ce79963          	bne	a5,a4,80005ec2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005df4:	100017b7          	lui	a5,0x10001
    80005df8:	479c                	lw	a5,8(a5)
    80005dfa:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005dfc:	4709                	li	a4,2
    80005dfe:	0ce79263          	bne	a5,a4,80005ec2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e02:	100017b7          	lui	a5,0x10001
    80005e06:	47d8                	lw	a4,12(a5)
    80005e08:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e0a:	554d47b7          	lui	a5,0x554d4
    80005e0e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e12:	0af71863          	bne	a4,a5,80005ec2 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e16:	100017b7          	lui	a5,0x10001
    80005e1a:	4705                	li	a4,1
    80005e1c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e1e:	470d                	li	a4,3
    80005e20:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e22:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e24:	c7ffe6b7          	lui	a3,0xc7ffe
    80005e28:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005e2c:	8f75                	and	a4,a4,a3
    80005e2e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e30:	472d                	li	a4,11
    80005e32:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e34:	473d                	li	a4,15
    80005e36:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005e38:	6705                	lui	a4,0x1
    80005e3a:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e3c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e40:	5bdc                	lw	a5,52(a5)
    80005e42:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e44:	c7d9                	beqz	a5,80005ed2 <virtio_disk_init+0x122>
  if(max < NUM)
    80005e46:	471d                	li	a4,7
    80005e48:	08f77d63          	bgeu	a4,a5,80005ee2 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e4c:	100014b7          	lui	s1,0x10001
    80005e50:	47a1                	li	a5,8
    80005e52:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005e54:	6609                	lui	a2,0x2
    80005e56:	4581                	li	a1,0
    80005e58:	0001d517          	auipc	a0,0x1d
    80005e5c:	1a850513          	addi	a0,a0,424 # 80023000 <disk>
    80005e60:	ffffb097          	auipc	ra,0xffffb
    80005e64:	e6c080e7          	jalr	-404(ra) # 80000ccc <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005e68:	0001d717          	auipc	a4,0x1d
    80005e6c:	19870713          	addi	a4,a4,408 # 80023000 <disk>
    80005e70:	00c75793          	srli	a5,a4,0xc
    80005e74:	2781                	sext.w	a5,a5
    80005e76:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005e78:	0001f797          	auipc	a5,0x1f
    80005e7c:	18878793          	addi	a5,a5,392 # 80025000 <disk+0x2000>
    80005e80:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005e82:	0001d717          	auipc	a4,0x1d
    80005e86:	1fe70713          	addi	a4,a4,510 # 80023080 <disk+0x80>
    80005e8a:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005e8c:	0001e717          	auipc	a4,0x1e
    80005e90:	17470713          	addi	a4,a4,372 # 80024000 <disk+0x1000>
    80005e94:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005e96:	4705                	li	a4,1
    80005e98:	00e78c23          	sb	a4,24(a5)
    80005e9c:	00e78ca3          	sb	a4,25(a5)
    80005ea0:	00e78d23          	sb	a4,26(a5)
    80005ea4:	00e78da3          	sb	a4,27(a5)
    80005ea8:	00e78e23          	sb	a4,28(a5)
    80005eac:	00e78ea3          	sb	a4,29(a5)
    80005eb0:	00e78f23          	sb	a4,30(a5)
    80005eb4:	00e78fa3          	sb	a4,31(a5)
}
    80005eb8:	60e2                	ld	ra,24(sp)
    80005eba:	6442                	ld	s0,16(sp)
    80005ebc:	64a2                	ld	s1,8(sp)
    80005ebe:	6105                	addi	sp,sp,32
    80005ec0:	8082                	ret
    panic("could not find virtio disk");
    80005ec2:	00003517          	auipc	a0,0x3
    80005ec6:	9d650513          	addi	a0,a0,-1578 # 80008898 <syscalls+0x3d0>
    80005eca:	ffffa097          	auipc	ra,0xffffa
    80005ece:	670080e7          	jalr	1648(ra) # 8000053a <panic>
    panic("virtio disk has no queue 0");
    80005ed2:	00003517          	auipc	a0,0x3
    80005ed6:	9e650513          	addi	a0,a0,-1562 # 800088b8 <syscalls+0x3f0>
    80005eda:	ffffa097          	auipc	ra,0xffffa
    80005ede:	660080e7          	jalr	1632(ra) # 8000053a <panic>
    panic("virtio disk max queue too short");
    80005ee2:	00003517          	auipc	a0,0x3
    80005ee6:	9f650513          	addi	a0,a0,-1546 # 800088d8 <syscalls+0x410>
    80005eea:	ffffa097          	auipc	ra,0xffffa
    80005eee:	650080e7          	jalr	1616(ra) # 8000053a <panic>

0000000080005ef2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ef2:	7119                	addi	sp,sp,-128
    80005ef4:	fc86                	sd	ra,120(sp)
    80005ef6:	f8a2                	sd	s0,112(sp)
    80005ef8:	f4a6                	sd	s1,104(sp)
    80005efa:	f0ca                	sd	s2,96(sp)
    80005efc:	ecce                	sd	s3,88(sp)
    80005efe:	e8d2                	sd	s4,80(sp)
    80005f00:	e4d6                	sd	s5,72(sp)
    80005f02:	e0da                	sd	s6,64(sp)
    80005f04:	fc5e                	sd	s7,56(sp)
    80005f06:	f862                	sd	s8,48(sp)
    80005f08:	f466                	sd	s9,40(sp)
    80005f0a:	f06a                	sd	s10,32(sp)
    80005f0c:	ec6e                	sd	s11,24(sp)
    80005f0e:	0100                	addi	s0,sp,128
    80005f10:	8aaa                	mv	s5,a0
    80005f12:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f14:	00c52c83          	lw	s9,12(a0)
    80005f18:	001c9c9b          	slliw	s9,s9,0x1
    80005f1c:	1c82                	slli	s9,s9,0x20
    80005f1e:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005f22:	0001f517          	auipc	a0,0x1f
    80005f26:	20650513          	addi	a0,a0,518 # 80025128 <disk+0x2128>
    80005f2a:	ffffb097          	auipc	ra,0xffffb
    80005f2e:	ca6080e7          	jalr	-858(ra) # 80000bd0 <acquire>
  for(int i = 0; i < 3; i++){
    80005f32:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005f34:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f36:	0001dc17          	auipc	s8,0x1d
    80005f3a:	0cac0c13          	addi	s8,s8,202 # 80023000 <disk>
    80005f3e:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80005f40:	4b0d                	li	s6,3
    80005f42:	a0ad                	j	80005fac <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80005f44:	00fc0733          	add	a4,s8,a5
    80005f48:	975e                	add	a4,a4,s7
    80005f4a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005f4e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005f50:	0207c563          	bltz	a5,80005f7a <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005f54:	2905                	addiw	s2,s2,1
    80005f56:	0611                	addi	a2,a2,4
    80005f58:	19690c63          	beq	s2,s6,800060f0 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    80005f5c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005f5e:	0001f717          	auipc	a4,0x1f
    80005f62:	0ba70713          	addi	a4,a4,186 # 80025018 <disk+0x2018>
    80005f66:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005f68:	00074683          	lbu	a3,0(a4)
    80005f6c:	fee1                	bnez	a3,80005f44 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005f6e:	2785                	addiw	a5,a5,1
    80005f70:	0705                	addi	a4,a4,1
    80005f72:	fe979be3          	bne	a5,s1,80005f68 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005f76:	57fd                	li	a5,-1
    80005f78:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005f7a:	01205d63          	blez	s2,80005f94 <virtio_disk_rw+0xa2>
    80005f7e:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005f80:	000a2503          	lw	a0,0(s4)
    80005f84:	00000097          	auipc	ra,0x0
    80005f88:	d92080e7          	jalr	-622(ra) # 80005d16 <free_desc>
      for(int j = 0; j < i; j++)
    80005f8c:	2d85                	addiw	s11,s11,1
    80005f8e:	0a11                	addi	s4,s4,4
    80005f90:	ff2d98e3          	bne	s11,s2,80005f80 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f94:	0001f597          	auipc	a1,0x1f
    80005f98:	19458593          	addi	a1,a1,404 # 80025128 <disk+0x2128>
    80005f9c:	0001f517          	auipc	a0,0x1f
    80005fa0:	07c50513          	addi	a0,a0,124 # 80025018 <disk+0x2018>
    80005fa4:	ffffc097          	auipc	ra,0xffffc
    80005fa8:	136080e7          	jalr	310(ra) # 800020da <sleep>
  for(int i = 0; i < 3; i++){
    80005fac:	f8040a13          	addi	s4,s0,-128
{
    80005fb0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005fb2:	894e                	mv	s2,s3
    80005fb4:	b765                	j	80005f5c <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005fb6:	0001f697          	auipc	a3,0x1f
    80005fba:	04a6b683          	ld	a3,74(a3) # 80025000 <disk+0x2000>
    80005fbe:	96ba                	add	a3,a3,a4
    80005fc0:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005fc4:	0001d817          	auipc	a6,0x1d
    80005fc8:	03c80813          	addi	a6,a6,60 # 80023000 <disk>
    80005fcc:	0001f697          	auipc	a3,0x1f
    80005fd0:	03468693          	addi	a3,a3,52 # 80025000 <disk+0x2000>
    80005fd4:	6290                	ld	a2,0(a3)
    80005fd6:	963a                	add	a2,a2,a4
    80005fd8:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80005fdc:	0015e593          	ori	a1,a1,1
    80005fe0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80005fe4:	f8842603          	lw	a2,-120(s0)
    80005fe8:	628c                	ld	a1,0(a3)
    80005fea:	972e                	add	a4,a4,a1
    80005fec:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005ff0:	20050593          	addi	a1,a0,512
    80005ff4:	0592                	slli	a1,a1,0x4
    80005ff6:	95c2                	add	a1,a1,a6
    80005ff8:	577d                	li	a4,-1
    80005ffa:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005ffe:	00461713          	slli	a4,a2,0x4
    80006002:	6290                	ld	a2,0(a3)
    80006004:	963a                	add	a2,a2,a4
    80006006:	03078793          	addi	a5,a5,48
    8000600a:	97c2                	add	a5,a5,a6
    8000600c:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    8000600e:	629c                	ld	a5,0(a3)
    80006010:	97ba                	add	a5,a5,a4
    80006012:	4605                	li	a2,1
    80006014:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006016:	629c                	ld	a5,0(a3)
    80006018:	97ba                	add	a5,a5,a4
    8000601a:	4809                	li	a6,2
    8000601c:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006020:	629c                	ld	a5,0(a3)
    80006022:	97ba                	add	a5,a5,a4
    80006024:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006028:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000602c:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006030:	6698                	ld	a4,8(a3)
    80006032:	00275783          	lhu	a5,2(a4)
    80006036:	8b9d                	andi	a5,a5,7
    80006038:	0786                	slli	a5,a5,0x1
    8000603a:	973e                	add	a4,a4,a5
    8000603c:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    80006040:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006044:	6698                	ld	a4,8(a3)
    80006046:	00275783          	lhu	a5,2(a4)
    8000604a:	2785                	addiw	a5,a5,1
    8000604c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006050:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006054:	100017b7          	lui	a5,0x10001
    80006058:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000605c:	004aa783          	lw	a5,4(s5)
    80006060:	02c79163          	bne	a5,a2,80006082 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006064:	0001f917          	auipc	s2,0x1f
    80006068:	0c490913          	addi	s2,s2,196 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    8000606c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000606e:	85ca                	mv	a1,s2
    80006070:	8556                	mv	a0,s5
    80006072:	ffffc097          	auipc	ra,0xffffc
    80006076:	068080e7          	jalr	104(ra) # 800020da <sleep>
  while(b->disk == 1) {
    8000607a:	004aa783          	lw	a5,4(s5)
    8000607e:	fe9788e3          	beq	a5,s1,8000606e <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006082:	f8042903          	lw	s2,-128(s0)
    80006086:	20090713          	addi	a4,s2,512
    8000608a:	0712                	slli	a4,a4,0x4
    8000608c:	0001d797          	auipc	a5,0x1d
    80006090:	f7478793          	addi	a5,a5,-140 # 80023000 <disk>
    80006094:	97ba                	add	a5,a5,a4
    80006096:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    8000609a:	0001f997          	auipc	s3,0x1f
    8000609e:	f6698993          	addi	s3,s3,-154 # 80025000 <disk+0x2000>
    800060a2:	00491713          	slli	a4,s2,0x4
    800060a6:	0009b783          	ld	a5,0(s3)
    800060aa:	97ba                	add	a5,a5,a4
    800060ac:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800060b0:	854a                	mv	a0,s2
    800060b2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800060b6:	00000097          	auipc	ra,0x0
    800060ba:	c60080e7          	jalr	-928(ra) # 80005d16 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800060be:	8885                	andi	s1,s1,1
    800060c0:	f0ed                	bnez	s1,800060a2 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800060c2:	0001f517          	auipc	a0,0x1f
    800060c6:	06650513          	addi	a0,a0,102 # 80025128 <disk+0x2128>
    800060ca:	ffffb097          	auipc	ra,0xffffb
    800060ce:	bba080e7          	jalr	-1094(ra) # 80000c84 <release>
}
    800060d2:	70e6                	ld	ra,120(sp)
    800060d4:	7446                	ld	s0,112(sp)
    800060d6:	74a6                	ld	s1,104(sp)
    800060d8:	7906                	ld	s2,96(sp)
    800060da:	69e6                	ld	s3,88(sp)
    800060dc:	6a46                	ld	s4,80(sp)
    800060de:	6aa6                	ld	s5,72(sp)
    800060e0:	6b06                	ld	s6,64(sp)
    800060e2:	7be2                	ld	s7,56(sp)
    800060e4:	7c42                	ld	s8,48(sp)
    800060e6:	7ca2                	ld	s9,40(sp)
    800060e8:	7d02                	ld	s10,32(sp)
    800060ea:	6de2                	ld	s11,24(sp)
    800060ec:	6109                	addi	sp,sp,128
    800060ee:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060f0:	f8042503          	lw	a0,-128(s0)
    800060f4:	20050793          	addi	a5,a0,512
    800060f8:	0792                	slli	a5,a5,0x4
  if(write)
    800060fa:	0001d817          	auipc	a6,0x1d
    800060fe:	f0680813          	addi	a6,a6,-250 # 80023000 <disk>
    80006102:	00f80733          	add	a4,a6,a5
    80006106:	01a036b3          	snez	a3,s10
    8000610a:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    8000610e:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006112:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006116:	7679                	lui	a2,0xffffe
    80006118:	963e                	add	a2,a2,a5
    8000611a:	0001f697          	auipc	a3,0x1f
    8000611e:	ee668693          	addi	a3,a3,-282 # 80025000 <disk+0x2000>
    80006122:	6298                	ld	a4,0(a3)
    80006124:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006126:	0a878593          	addi	a1,a5,168
    8000612a:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000612c:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000612e:	6298                	ld	a4,0(a3)
    80006130:	9732                	add	a4,a4,a2
    80006132:	45c1                	li	a1,16
    80006134:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006136:	6298                	ld	a4,0(a3)
    80006138:	9732                	add	a4,a4,a2
    8000613a:	4585                	li	a1,1
    8000613c:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006140:	f8442703          	lw	a4,-124(s0)
    80006144:	628c                	ld	a1,0(a3)
    80006146:	962e                	add	a2,a2,a1
    80006148:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    8000614c:	0712                	slli	a4,a4,0x4
    8000614e:	6290                	ld	a2,0(a3)
    80006150:	963a                	add	a2,a2,a4
    80006152:	058a8593          	addi	a1,s5,88
    80006156:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006158:	6294                	ld	a3,0(a3)
    8000615a:	96ba                	add	a3,a3,a4
    8000615c:	40000613          	li	a2,1024
    80006160:	c690                	sw	a2,8(a3)
  if(write)
    80006162:	e40d1ae3          	bnez	s10,80005fb6 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006166:	0001f697          	auipc	a3,0x1f
    8000616a:	e9a6b683          	ld	a3,-358(a3) # 80025000 <disk+0x2000>
    8000616e:	96ba                	add	a3,a3,a4
    80006170:	4609                	li	a2,2
    80006172:	00c69623          	sh	a2,12(a3)
    80006176:	b5b9                	j	80005fc4 <virtio_disk_rw+0xd2>

0000000080006178 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006178:	1101                	addi	sp,sp,-32
    8000617a:	ec06                	sd	ra,24(sp)
    8000617c:	e822                	sd	s0,16(sp)
    8000617e:	e426                	sd	s1,8(sp)
    80006180:	e04a                	sd	s2,0(sp)
    80006182:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006184:	0001f517          	auipc	a0,0x1f
    80006188:	fa450513          	addi	a0,a0,-92 # 80025128 <disk+0x2128>
    8000618c:	ffffb097          	auipc	ra,0xffffb
    80006190:	a44080e7          	jalr	-1468(ra) # 80000bd0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006194:	10001737          	lui	a4,0x10001
    80006198:	533c                	lw	a5,96(a4)
    8000619a:	8b8d                	andi	a5,a5,3
    8000619c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000619e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800061a2:	0001f797          	auipc	a5,0x1f
    800061a6:	e5e78793          	addi	a5,a5,-418 # 80025000 <disk+0x2000>
    800061aa:	6b94                	ld	a3,16(a5)
    800061ac:	0207d703          	lhu	a4,32(a5)
    800061b0:	0026d783          	lhu	a5,2(a3)
    800061b4:	06f70163          	beq	a4,a5,80006216 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800061b8:	0001d917          	auipc	s2,0x1d
    800061bc:	e4890913          	addi	s2,s2,-440 # 80023000 <disk>
    800061c0:	0001f497          	auipc	s1,0x1f
    800061c4:	e4048493          	addi	s1,s1,-448 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800061c8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800061cc:	6898                	ld	a4,16(s1)
    800061ce:	0204d783          	lhu	a5,32(s1)
    800061d2:	8b9d                	andi	a5,a5,7
    800061d4:	078e                	slli	a5,a5,0x3
    800061d6:	97ba                	add	a5,a5,a4
    800061d8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800061da:	20078713          	addi	a4,a5,512
    800061de:	0712                	slli	a4,a4,0x4
    800061e0:	974a                	add	a4,a4,s2
    800061e2:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800061e6:	e731                	bnez	a4,80006232 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800061e8:	20078793          	addi	a5,a5,512
    800061ec:	0792                	slli	a5,a5,0x4
    800061ee:	97ca                	add	a5,a5,s2
    800061f0:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800061f2:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800061f6:	ffffc097          	auipc	ra,0xffffc
    800061fa:	070080e7          	jalr	112(ra) # 80002266 <wakeup>

    disk.used_idx += 1;
    800061fe:	0204d783          	lhu	a5,32(s1)
    80006202:	2785                	addiw	a5,a5,1
    80006204:	17c2                	slli	a5,a5,0x30
    80006206:	93c1                	srli	a5,a5,0x30
    80006208:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000620c:	6898                	ld	a4,16(s1)
    8000620e:	00275703          	lhu	a4,2(a4)
    80006212:	faf71be3          	bne	a4,a5,800061c8 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006216:	0001f517          	auipc	a0,0x1f
    8000621a:	f1250513          	addi	a0,a0,-238 # 80025128 <disk+0x2128>
    8000621e:	ffffb097          	auipc	ra,0xffffb
    80006222:	a66080e7          	jalr	-1434(ra) # 80000c84 <release>
}
    80006226:	60e2                	ld	ra,24(sp)
    80006228:	6442                	ld	s0,16(sp)
    8000622a:	64a2                	ld	s1,8(sp)
    8000622c:	6902                	ld	s2,0(sp)
    8000622e:	6105                	addi	sp,sp,32
    80006230:	8082                	ret
      panic("virtio_disk_intr status");
    80006232:	00002517          	auipc	a0,0x2
    80006236:	6c650513          	addi	a0,a0,1734 # 800088f8 <syscalls+0x430>
    8000623a:	ffffa097          	auipc	ra,0xffffa
    8000623e:	300080e7          	jalr	768(ra) # 8000053a <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
