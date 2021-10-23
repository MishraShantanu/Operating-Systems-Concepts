
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
    80000066:	dce78793          	addi	a5,a5,-562 # 80005e30 <timervec>
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
    8000012e:	460080e7          	jalr	1120(ra) # 8000258a <either_copyin>
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
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7d6080e7          	jalr	2006(ra) # 80001996 <myproc>
    800001c8:	551c                	lw	a5,40(a0)
    800001ca:	e7b5                	bnez	a5,80000236 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001cc:	85a6                	mv	a1,s1
    800001ce:	854a                	mv	a0,s2
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	f94080e7          	jalr	-108(ra) # 80002164 <sleep>
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
    80000210:	328080e7          	jalr	808(ra) # 80002534 <either_copyout>
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
    800002f0:	2f4080e7          	jalr	756(ra) # 800025e0 <procdump>
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
    80000444:	eb0080e7          	jalr	-336(ra) # 800022f0 <wakeup>
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
    80000476:	4a678793          	addi	a5,a5,1190 # 80021918 <devsw>
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
    80000892:	a62080e7          	jalr	-1438(ra) # 800022f0 <wakeup>
    
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
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	84a080e7          	jalr	-1974(ra) # 80002164 <sleep>
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
    80000b6e:	e10080e7          	jalr	-496(ra) # 8000197a <mycpu>
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
    80000ba0:	dde080e7          	jalr	-546(ra) # 8000197a <mycpu>
    80000ba4:	5d3c                	lw	a5,120(a0)
    80000ba6:	cf89                	beqz	a5,80000bc0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ba8:	00001097          	auipc	ra,0x1
    80000bac:	dd2080e7          	jalr	-558(ra) # 8000197a <mycpu>
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
    80000bc4:	dba080e7          	jalr	-582(ra) # 8000197a <mycpu>
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
    80000c04:	d7a080e7          	jalr	-646(ra) # 8000197a <mycpu>
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
    80000c30:	d4e080e7          	jalr	-690(ra) # 8000197a <mycpu>
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
    80000e7e:	af0080e7          	jalr	-1296(ra) # 8000196a <cpuid>
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
    80000e9a:	ad4080e7          	jalr	-1324(ra) # 8000196a <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6dc080e7          	jalr	1756(ra) # 80000584 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	9d6080e7          	jalr	-1578(ra) # 8000288e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	fb0080e7          	jalr	-80(ra) # 80005e70 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	016080e7          	jalr	22(ra) # 80001ede <scheduler>
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
    80000f2c:	992080e7          	jalr	-1646(ra) # 800018ba <procinit>
    trapinit();      // trap vectors
    80000f30:	00002097          	auipc	ra,0x2
    80000f34:	936080e7          	jalr	-1738(ra) # 80002866 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	956080e7          	jalr	-1706(ra) # 8000288e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	f1a080e7          	jalr	-230(ra) # 80005e5a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	f28080e7          	jalr	-216(ra) # 80005e70 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	0e4080e7          	jalr	228(ra) # 80003034 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	772080e7          	jalr	1906(ra) # 800036ca <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	724080e7          	jalr	1828(ra) # 80004684 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	028080e7          	jalr	40(ra) # 80005f90 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d34080e7          	jalr	-716(ra) # 80001ca4 <userinit>
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
    80001228:	600080e7          	jalr	1536(ra) # 80001824 <proc_mapstacks>
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

0000000080001824 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001824:	7139                	addi	sp,sp,-64
    80001826:	fc06                	sd	ra,56(sp)
    80001828:	f822                	sd	s0,48(sp)
    8000182a:	f426                	sd	s1,40(sp)
    8000182c:	f04a                	sd	s2,32(sp)
    8000182e:	ec4e                	sd	s3,24(sp)
    80001830:	e852                	sd	s4,16(sp)
    80001832:	e456                	sd	s5,8(sp)
    80001834:	e05a                	sd	s6,0(sp)
    80001836:	0080                	addi	s0,sp,64
    80001838:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183a:	00010497          	auipc	s1,0x10
    8000183e:	e9648493          	addi	s1,s1,-362 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001842:	8b26                	mv	s6,s1
    80001844:	00006a97          	auipc	s5,0x6
    80001848:	7bca8a93          	addi	s5,s5,1980 # 80008000 <etext>
    8000184c:	04000937          	lui	s2,0x4000
    80001850:	197d                	addi	s2,s2,-1
    80001852:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001854:	00016a17          	auipc	s4,0x16
    80001858:	e7ca0a13          	addi	s4,s4,-388 # 800176d0 <tickslock>
    char *pa = kalloc();
    8000185c:	fffff097          	auipc	ra,0xfffff
    80001860:	284080e7          	jalr	644(ra) # 80000ae0 <kalloc>
    80001864:	862a                	mv	a2,a0
    if(pa == 0)
    80001866:	c131                	beqz	a0,800018aa <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001868:	416485b3          	sub	a1,s1,s6
    8000186c:	859d                	srai	a1,a1,0x7
    8000186e:	000ab783          	ld	a5,0(s5)
    80001872:	02f585b3          	mul	a1,a1,a5
    80001876:	2585                	addiw	a1,a1,1
    80001878:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000187c:	4719                	li	a4,6
    8000187e:	6685                	lui	a3,0x1
    80001880:	40b905b3          	sub	a1,s2,a1
    80001884:	854e                	mv	a0,s3
    80001886:	00000097          	auipc	ra,0x0
    8000188a:	8ae080e7          	jalr	-1874(ra) # 80001134 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188e:	18048493          	addi	s1,s1,384
    80001892:	fd4495e3          	bne	s1,s4,8000185c <proc_mapstacks+0x38>
  }
}
    80001896:	70e2                	ld	ra,56(sp)
    80001898:	7442                	ld	s0,48(sp)
    8000189a:	74a2                	ld	s1,40(sp)
    8000189c:	7902                	ld	s2,32(sp)
    8000189e:	69e2                	ld	s3,24(sp)
    800018a0:	6a42                	ld	s4,16(sp)
    800018a2:	6aa2                	ld	s5,8(sp)
    800018a4:	6b02                	ld	s6,0(sp)
    800018a6:	6121                	addi	sp,sp,64
    800018a8:	8082                	ret
      panic("kalloc");
    800018aa:	00007517          	auipc	a0,0x7
    800018ae:	92e50513          	addi	a0,a0,-1746 # 800081d8 <digits+0x198>
    800018b2:	fffff097          	auipc	ra,0xfffff
    800018b6:	c88080e7          	jalr	-888(ra) # 8000053a <panic>

00000000800018ba <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018ba:	7139                	addi	sp,sp,-64
    800018bc:	fc06                	sd	ra,56(sp)
    800018be:	f822                	sd	s0,48(sp)
    800018c0:	f426                	sd	s1,40(sp)
    800018c2:	f04a                	sd	s2,32(sp)
    800018c4:	ec4e                	sd	s3,24(sp)
    800018c6:	e852                	sd	s4,16(sp)
    800018c8:	e456                	sd	s5,8(sp)
    800018ca:	e05a                	sd	s6,0(sp)
    800018cc:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018ce:	00007597          	auipc	a1,0x7
    800018d2:	91258593          	addi	a1,a1,-1774 # 800081e0 <digits+0x1a0>
    800018d6:	00010517          	auipc	a0,0x10
    800018da:	9ca50513          	addi	a0,a0,-1590 # 800112a0 <pid_lock>
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	262080e7          	jalr	610(ra) # 80000b40 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018e6:	00007597          	auipc	a1,0x7
    800018ea:	90258593          	addi	a1,a1,-1790 # 800081e8 <digits+0x1a8>
    800018ee:	00010517          	auipc	a0,0x10
    800018f2:	9ca50513          	addi	a0,a0,-1590 # 800112b8 <wait_lock>
    800018f6:	fffff097          	auipc	ra,0xfffff
    800018fa:	24a080e7          	jalr	586(ra) # 80000b40 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fe:	00010497          	auipc	s1,0x10
    80001902:	dd248493          	addi	s1,s1,-558 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001906:	00007b17          	auipc	s6,0x7
    8000190a:	8f2b0b13          	addi	s6,s6,-1806 # 800081f8 <digits+0x1b8>
      p->kstack = KSTACK((int) (p - proc));
    8000190e:	8aa6                	mv	s5,s1
    80001910:	00006a17          	auipc	s4,0x6
    80001914:	6f0a0a13          	addi	s4,s4,1776 # 80008000 <etext>
    80001918:	04000937          	lui	s2,0x4000
    8000191c:	197d                	addi	s2,s2,-1
    8000191e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001920:	00016997          	auipc	s3,0x16
    80001924:	db098993          	addi	s3,s3,-592 # 800176d0 <tickslock>
      initlock(&p->lock, "proc");
    80001928:	85da                	mv	a1,s6
    8000192a:	8526                	mv	a0,s1
    8000192c:	fffff097          	auipc	ra,0xfffff
    80001930:	214080e7          	jalr	532(ra) # 80000b40 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001934:	415487b3          	sub	a5,s1,s5
    80001938:	879d                	srai	a5,a5,0x7
    8000193a:	000a3703          	ld	a4,0(s4)
    8000193e:	02e787b3          	mul	a5,a5,a4
    80001942:	2785                	addiw	a5,a5,1
    80001944:	00d7979b          	slliw	a5,a5,0xd
    80001948:	40f907b3          	sub	a5,s2,a5
    8000194c:	e8bc                	sd	a5,80(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194e:	18048493          	addi	s1,s1,384
    80001952:	fd349be3          	bne	s1,s3,80001928 <procinit+0x6e>
  }
}
    80001956:	70e2                	ld	ra,56(sp)
    80001958:	7442                	ld	s0,48(sp)
    8000195a:	74a2                	ld	s1,40(sp)
    8000195c:	7902                	ld	s2,32(sp)
    8000195e:	69e2                	ld	s3,24(sp)
    80001960:	6a42                	ld	s4,16(sp)
    80001962:	6aa2                	ld	s5,8(sp)
    80001964:	6b02                	ld	s6,0(sp)
    80001966:	6121                	addi	sp,sp,64
    80001968:	8082                	ret

000000008000196a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000196a:	1141                	addi	sp,sp,-16
    8000196c:	e422                	sd	s0,8(sp)
    8000196e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001970:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001972:	2501                	sext.w	a0,a0
    80001974:	6422                	ld	s0,8(sp)
    80001976:	0141                	addi	sp,sp,16
    80001978:	8082                	ret

000000008000197a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    8000197a:	1141                	addi	sp,sp,-16
    8000197c:	e422                	sd	s0,8(sp)
    8000197e:	0800                	addi	s0,sp,16
    80001980:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001982:	2781                	sext.w	a5,a5
    80001984:	079e                	slli	a5,a5,0x7
  return c;
}
    80001986:	00010517          	auipc	a0,0x10
    8000198a:	94a50513          	addi	a0,a0,-1718 # 800112d0 <cpus>
    8000198e:	953e                	add	a0,a0,a5
    80001990:	6422                	ld	s0,8(sp)
    80001992:	0141                	addi	sp,sp,16
    80001994:	8082                	ret

0000000080001996 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001996:	1101                	addi	sp,sp,-32
    80001998:	ec06                	sd	ra,24(sp)
    8000199a:	e822                	sd	s0,16(sp)
    8000199c:	e426                	sd	s1,8(sp)
    8000199e:	1000                	addi	s0,sp,32
  push_off();
    800019a0:	fffff097          	auipc	ra,0xfffff
    800019a4:	1e4080e7          	jalr	484(ra) # 80000b84 <push_off>
    800019a8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019aa:	2781                	sext.w	a5,a5
    800019ac:	079e                	slli	a5,a5,0x7
    800019ae:	00010717          	auipc	a4,0x10
    800019b2:	8f270713          	addi	a4,a4,-1806 # 800112a0 <pid_lock>
    800019b6:	97ba                	add	a5,a5,a4
    800019b8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ba:	fffff097          	auipc	ra,0xfffff
    800019be:	26a080e7          	jalr	618(ra) # 80000c24 <pop_off>
  return p;
}
    800019c2:	8526                	mv	a0,s1
    800019c4:	60e2                	ld	ra,24(sp)
    800019c6:	6442                	ld	s0,16(sp)
    800019c8:	64a2                	ld	s1,8(sp)
    800019ca:	6105                	addi	sp,sp,32
    800019cc:	8082                	ret

00000000800019ce <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019ce:	1141                	addi	sp,sp,-16
    800019d0:	e406                	sd	ra,8(sp)
    800019d2:	e022                	sd	s0,0(sp)
    800019d4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019d6:	00000097          	auipc	ra,0x0
    800019da:	fc0080e7          	jalr	-64(ra) # 80001996 <myproc>
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	2a6080e7          	jalr	678(ra) # 80000c84 <release>

  if (first) {
    800019e6:	00007797          	auipc	a5,0x7
    800019ea:	e3a7a783          	lw	a5,-454(a5) # 80008820 <first.1>
    800019ee:	eb89                	bnez	a5,80001a00 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019f0:	00001097          	auipc	ra,0x1
    800019f4:	eb6080e7          	jalr	-330(ra) # 800028a6 <usertrapret>
}
    800019f8:	60a2                	ld	ra,8(sp)
    800019fa:	6402                	ld	s0,0(sp)
    800019fc:	0141                	addi	sp,sp,16
    800019fe:	8082                	ret
    first = 0;
    80001a00:	00007797          	auipc	a5,0x7
    80001a04:	e207a023          	sw	zero,-480(a5) # 80008820 <first.1>
    fsinit(ROOTDEV);
    80001a08:	4505                	li	a0,1
    80001a0a:	00002097          	auipc	ra,0x2
    80001a0e:	c40080e7          	jalr	-960(ra) # 8000364a <fsinit>
    80001a12:	bff9                	j	800019f0 <forkret+0x22>

0000000080001a14 <allocpid>:
allocpid() {
    80001a14:	1101                	addi	sp,sp,-32
    80001a16:	ec06                	sd	ra,24(sp)
    80001a18:	e822                	sd	s0,16(sp)
    80001a1a:	e426                	sd	s1,8(sp)
    80001a1c:	e04a                	sd	s2,0(sp)
    80001a1e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a20:	00010917          	auipc	s2,0x10
    80001a24:	88090913          	addi	s2,s2,-1920 # 800112a0 <pid_lock>
    80001a28:	854a                	mv	a0,s2
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	1a6080e7          	jalr	422(ra) # 80000bd0 <acquire>
  pid = nextpid;
    80001a32:	00007797          	auipc	a5,0x7
    80001a36:	df278793          	addi	a5,a5,-526 # 80008824 <nextpid>
    80001a3a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a3c:	0014871b          	addiw	a4,s1,1
    80001a40:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a42:	854a                	mv	a0,s2
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	240080e7          	jalr	576(ra) # 80000c84 <release>
}
    80001a4c:	8526                	mv	a0,s1
    80001a4e:	60e2                	ld	ra,24(sp)
    80001a50:	6442                	ld	s0,16(sp)
    80001a52:	64a2                	ld	s1,8(sp)
    80001a54:	6902                	ld	s2,0(sp)
    80001a56:	6105                	addi	sp,sp,32
    80001a58:	8082                	ret

0000000080001a5a <proc_pagetable>:
{
    80001a5a:	1101                	addi	sp,sp,-32
    80001a5c:	ec06                	sd	ra,24(sp)
    80001a5e:	e822                	sd	s0,16(sp)
    80001a60:	e426                	sd	s1,8(sp)
    80001a62:	e04a                	sd	s2,0(sp)
    80001a64:	1000                	addi	s0,sp,32
    80001a66:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a68:	00000097          	auipc	ra,0x0
    80001a6c:	8b6080e7          	jalr	-1866(ra) # 8000131e <uvmcreate>
    80001a70:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a72:	c121                	beqz	a0,80001ab2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a74:	4729                	li	a4,10
    80001a76:	00005697          	auipc	a3,0x5
    80001a7a:	58a68693          	addi	a3,a3,1418 # 80007000 <_trampoline>
    80001a7e:	6605                	lui	a2,0x1
    80001a80:	040005b7          	lui	a1,0x4000
    80001a84:	15fd                	addi	a1,a1,-1
    80001a86:	05b2                	slli	a1,a1,0xc
    80001a88:	fffff097          	auipc	ra,0xfffff
    80001a8c:	60c080e7          	jalr	1548(ra) # 80001094 <mappages>
    80001a90:	02054863          	bltz	a0,80001ac0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a94:	4719                	li	a4,6
    80001a96:	06893683          	ld	a3,104(s2)
    80001a9a:	6605                	lui	a2,0x1
    80001a9c:	020005b7          	lui	a1,0x2000
    80001aa0:	15fd                	addi	a1,a1,-1
    80001aa2:	05b6                	slli	a1,a1,0xd
    80001aa4:	8526                	mv	a0,s1
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	5ee080e7          	jalr	1518(ra) # 80001094 <mappages>
    80001aae:	02054163          	bltz	a0,80001ad0 <proc_pagetable+0x76>
}
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	60e2                	ld	ra,24(sp)
    80001ab6:	6442                	ld	s0,16(sp)
    80001ab8:	64a2                	ld	s1,8(sp)
    80001aba:	6902                	ld	s2,0(sp)
    80001abc:	6105                	addi	sp,sp,32
    80001abe:	8082                	ret
    uvmfree(pagetable, 0);
    80001ac0:	4581                	li	a1,0
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	00000097          	auipc	ra,0x0
    80001ac8:	a58080e7          	jalr	-1448(ra) # 8000151c <uvmfree>
    return 0;
    80001acc:	4481                	li	s1,0
    80001ace:	b7d5                	j	80001ab2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad0:	4681                	li	a3,0
    80001ad2:	4605                	li	a2,1
    80001ad4:	040005b7          	lui	a1,0x4000
    80001ad8:	15fd                	addi	a1,a1,-1
    80001ada:	05b2                	slli	a1,a1,0xc
    80001adc:	8526                	mv	a0,s1
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	77c080e7          	jalr	1916(ra) # 8000125a <uvmunmap>
    uvmfree(pagetable, 0);
    80001ae6:	4581                	li	a1,0
    80001ae8:	8526                	mv	a0,s1
    80001aea:	00000097          	auipc	ra,0x0
    80001aee:	a32080e7          	jalr	-1486(ra) # 8000151c <uvmfree>
    return 0;
    80001af2:	4481                	li	s1,0
    80001af4:	bf7d                	j	80001ab2 <proc_pagetable+0x58>

0000000080001af6 <proc_freepagetable>:
{
    80001af6:	1101                	addi	sp,sp,-32
    80001af8:	ec06                	sd	ra,24(sp)
    80001afa:	e822                	sd	s0,16(sp)
    80001afc:	e426                	sd	s1,8(sp)
    80001afe:	e04a                	sd	s2,0(sp)
    80001b00:	1000                	addi	s0,sp,32
    80001b02:	84aa                	mv	s1,a0
    80001b04:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b06:	4681                	li	a3,0
    80001b08:	4605                	li	a2,1
    80001b0a:	040005b7          	lui	a1,0x4000
    80001b0e:	15fd                	addi	a1,a1,-1
    80001b10:	05b2                	slli	a1,a1,0xc
    80001b12:	fffff097          	auipc	ra,0xfffff
    80001b16:	748080e7          	jalr	1864(ra) # 8000125a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b1a:	4681                	li	a3,0
    80001b1c:	4605                	li	a2,1
    80001b1e:	020005b7          	lui	a1,0x2000
    80001b22:	15fd                	addi	a1,a1,-1
    80001b24:	05b6                	slli	a1,a1,0xd
    80001b26:	8526                	mv	a0,s1
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	732080e7          	jalr	1842(ra) # 8000125a <uvmunmap>
  uvmfree(pagetable, sz);
    80001b30:	85ca                	mv	a1,s2
    80001b32:	8526                	mv	a0,s1
    80001b34:	00000097          	auipc	ra,0x0
    80001b38:	9e8080e7          	jalr	-1560(ra) # 8000151c <uvmfree>
}
    80001b3c:	60e2                	ld	ra,24(sp)
    80001b3e:	6442                	ld	s0,16(sp)
    80001b40:	64a2                	ld	s1,8(sp)
    80001b42:	6902                	ld	s2,0(sp)
    80001b44:	6105                	addi	sp,sp,32
    80001b46:	8082                	ret

0000000080001b48 <freeproc>:
{
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
    80001b52:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b54:	7528                	ld	a0,104(a0)
    80001b56:	c509                	beqz	a0,80001b60 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	e8a080e7          	jalr	-374(ra) # 800009e2 <kfree>
  p->trapframe = 0;
    80001b60:	0604b423          	sd	zero,104(s1)
  if(p->pagetable)
    80001b64:	70a8                	ld	a0,96(s1)
    80001b66:	c511                	beqz	a0,80001b72 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b68:	6cac                	ld	a1,88(s1)
    80001b6a:	00000097          	auipc	ra,0x0
    80001b6e:	f8c080e7          	jalr	-116(ra) # 80001af6 <proc_freepagetable>
  p->pagetable = 0;
    80001b72:	0604b023          	sd	zero,96(s1)
  p->sz = 0;
    80001b76:	0404bc23          	sd	zero,88(s1)
  p->pid = 0;
    80001b7a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b7e:	0404b423          	sd	zero,72(s1)
  p->name[0] = 0;
    80001b82:	16048423          	sb	zero,360(s1)
  p->chan = 0;
    80001b86:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b8a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b8e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b92:	0004ac23          	sw	zero,24(s1)
}
    80001b96:	60e2                	ld	ra,24(sp)
    80001b98:	6442                	ld	s0,16(sp)
    80001b9a:	64a2                	ld	s1,8(sp)
    80001b9c:	6105                	addi	sp,sp,32
    80001b9e:	8082                	ret

0000000080001ba0 <allocproc>:
{
    80001ba0:	1101                	addi	sp,sp,-32
    80001ba2:	ec06                	sd	ra,24(sp)
    80001ba4:	e822                	sd	s0,16(sp)
    80001ba6:	e426                	sd	s1,8(sp)
    80001ba8:	e04a                	sd	s2,0(sp)
    80001baa:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bac:	00010497          	auipc	s1,0x10
    80001bb0:	b2448493          	addi	s1,s1,-1244 # 800116d0 <proc>
    80001bb4:	00016917          	auipc	s2,0x16
    80001bb8:	b1c90913          	addi	s2,s2,-1252 # 800176d0 <tickslock>
    acquire(&p->lock);
    80001bbc:	8526                	mv	a0,s1
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	012080e7          	jalr	18(ra) # 80000bd0 <acquire>
    if(p->state == UNUSED) {
    80001bc6:	4c9c                	lw	a5,24(s1)
    80001bc8:	cf81                	beqz	a5,80001be0 <allocproc+0x40>
      release(&p->lock);
    80001bca:	8526                	mv	a0,s1
    80001bcc:	fffff097          	auipc	ra,0xfffff
    80001bd0:	0b8080e7          	jalr	184(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bd4:	18048493          	addi	s1,s1,384
    80001bd8:	ff2492e3          	bne	s1,s2,80001bbc <allocproc+0x1c>
  return 0;
    80001bdc:	4481                	li	s1,0
    80001bde:	a061                	j	80001c66 <allocproc+0xc6>
  p->pid = allocpid();
    80001be0:	00000097          	auipc	ra,0x0
    80001be4:	e34080e7          	jalr	-460(ra) # 80001a14 <allocpid>
    80001be8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bea:	4785                	li	a5,1
    80001bec:	cc9c                	sw	a5,24(s1)
    acquire(&tickslock);
    80001bee:	00016517          	auipc	a0,0x16
    80001bf2:	ae250513          	addi	a0,a0,-1310 # 800176d0 <tickslock>
    80001bf6:	fffff097          	auipc	ra,0xfffff
    80001bfa:	fda080e7          	jalr	-38(ra) # 80000bd0 <acquire>
    p->created = ticks;
    80001bfe:	00007797          	auipc	a5,0x7
    80001c02:	43a7a783          	lw	a5,1082(a5) # 80009038 <ticks>
    80001c06:	dcdc                	sw	a5,60(s1)
    release(&tickslock);
    80001c08:	00016517          	auipc	a0,0x16
    80001c0c:	ac850513          	addi	a0,a0,-1336 # 800176d0 <tickslock>
    80001c10:	fffff097          	auipc	ra,0xfffff
    80001c14:	074080e7          	jalr	116(ra) # 80000c84 <release>
    p->runtime = 0;
    80001c18:	1604ac23          	sw	zero,376(s1)
    p->priority = HIGH;
    80001c1c:	0204ac23          	sw	zero,56(s1)
    p->running = 0;
    80001c20:	0204aa23          	sw	zero,52(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c24:	fffff097          	auipc	ra,0xfffff
    80001c28:	ebc080e7          	jalr	-324(ra) # 80000ae0 <kalloc>
    80001c2c:	892a                	mv	s2,a0
    80001c2e:	f4a8                	sd	a0,104(s1)
    80001c30:	c131                	beqz	a0,80001c74 <allocproc+0xd4>
  p->pagetable = proc_pagetable(p);
    80001c32:	8526                	mv	a0,s1
    80001c34:	00000097          	auipc	ra,0x0
    80001c38:	e26080e7          	jalr	-474(ra) # 80001a5a <proc_pagetable>
    80001c3c:	892a                	mv	s2,a0
    80001c3e:	f0a8                	sd	a0,96(s1)
  if(p->pagetable == 0){
    80001c40:	c531                	beqz	a0,80001c8c <allocproc+0xec>
  memset(&p->context, 0, sizeof(p->context));
    80001c42:	07000613          	li	a2,112
    80001c46:	4581                	li	a1,0
    80001c48:	07048513          	addi	a0,s1,112
    80001c4c:	fffff097          	auipc	ra,0xfffff
    80001c50:	080080e7          	jalr	128(ra) # 80000ccc <memset>
  p->context.ra = (uint64)forkret;
    80001c54:	00000797          	auipc	a5,0x0
    80001c58:	d7a78793          	addi	a5,a5,-646 # 800019ce <forkret>
    80001c5c:	f8bc                	sd	a5,112(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c5e:	68bc                	ld	a5,80(s1)
    80001c60:	6705                	lui	a4,0x1
    80001c62:	97ba                	add	a5,a5,a4
    80001c64:	fcbc                	sd	a5,120(s1)
}
    80001c66:	8526                	mv	a0,s1
    80001c68:	60e2                	ld	ra,24(sp)
    80001c6a:	6442                	ld	s0,16(sp)
    80001c6c:	64a2                	ld	s1,8(sp)
    80001c6e:	6902                	ld	s2,0(sp)
    80001c70:	6105                	addi	sp,sp,32
    80001c72:	8082                	ret
    freeproc(p);
    80001c74:	8526                	mv	a0,s1
    80001c76:	00000097          	auipc	ra,0x0
    80001c7a:	ed2080e7          	jalr	-302(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	004080e7          	jalr	4(ra) # 80000c84 <release>
    return 0;
    80001c88:	84ca                	mv	s1,s2
    80001c8a:	bff1                	j	80001c66 <allocproc+0xc6>
    freeproc(p);
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	00000097          	auipc	ra,0x0
    80001c92:	eba080e7          	jalr	-326(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001c96:	8526                	mv	a0,s1
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	fec080e7          	jalr	-20(ra) # 80000c84 <release>
    return 0;
    80001ca0:	84ca                	mv	s1,s2
    80001ca2:	b7d1                	j	80001c66 <allocproc+0xc6>

0000000080001ca4 <userinit>:
{
    80001ca4:	1101                	addi	sp,sp,-32
    80001ca6:	ec06                	sd	ra,24(sp)
    80001ca8:	e822                	sd	s0,16(sp)
    80001caa:	e426                	sd	s1,8(sp)
    80001cac:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cae:	00000097          	auipc	ra,0x0
    80001cb2:	ef2080e7          	jalr	-270(ra) # 80001ba0 <allocproc>
    80001cb6:	84aa                	mv	s1,a0
  initproc = p;
    80001cb8:	00007797          	auipc	a5,0x7
    80001cbc:	36a7b823          	sd	a0,880(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cc0:	03400613          	li	a2,52
    80001cc4:	00007597          	auipc	a1,0x7
    80001cc8:	b6c58593          	addi	a1,a1,-1172 # 80008830 <initcode>
    80001ccc:	7128                	ld	a0,96(a0)
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	67e080e7          	jalr	1662(ra) # 8000134c <uvminit>
  p->sz = PGSIZE;
    80001cd6:	6785                	lui	a5,0x1
    80001cd8:	ecbc                	sd	a5,88(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cda:	74b8                	ld	a4,104(s1)
    80001cdc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001ce0:	74b8                	ld	a4,104(s1)
    80001ce2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ce4:	4641                	li	a2,16
    80001ce6:	00006597          	auipc	a1,0x6
    80001cea:	51a58593          	addi	a1,a1,1306 # 80008200 <digits+0x1c0>
    80001cee:	16848513          	addi	a0,s1,360
    80001cf2:	fffff097          	auipc	ra,0xfffff
    80001cf6:	124080e7          	jalr	292(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cfa:	00006517          	auipc	a0,0x6
    80001cfe:	51650513          	addi	a0,a0,1302 # 80008210 <digits+0x1d0>
    80001d02:	00002097          	auipc	ra,0x2
    80001d06:	37e080e7          	jalr	894(ra) # 80004080 <namei>
    80001d0a:	16a4b023          	sd	a0,352(s1)
  p->state = RUNNABLE;
    80001d0e:	478d                	li	a5,3
    80001d10:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d12:	8526                	mv	a0,s1
    80001d14:	fffff097          	auipc	ra,0xfffff
    80001d18:	f70080e7          	jalr	-144(ra) # 80000c84 <release>
}
    80001d1c:	60e2                	ld	ra,24(sp)
    80001d1e:	6442                	ld	s0,16(sp)
    80001d20:	64a2                	ld	s1,8(sp)
    80001d22:	6105                	addi	sp,sp,32
    80001d24:	8082                	ret

0000000080001d26 <growproc>:
{
    80001d26:	1101                	addi	sp,sp,-32
    80001d28:	ec06                	sd	ra,24(sp)
    80001d2a:	e822                	sd	s0,16(sp)
    80001d2c:	e426                	sd	s1,8(sp)
    80001d2e:	e04a                	sd	s2,0(sp)
    80001d30:	1000                	addi	s0,sp,32
    80001d32:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d34:	00000097          	auipc	ra,0x0
    80001d38:	c62080e7          	jalr	-926(ra) # 80001996 <myproc>
    80001d3c:	892a                	mv	s2,a0
  sz = p->sz;
    80001d3e:	6d2c                	ld	a1,88(a0)
    80001d40:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001d44:	00904f63          	bgtz	s1,80001d62 <growproc+0x3c>
  } else if(n < 0){
    80001d48:	0204cd63          	bltz	s1,80001d82 <growproc+0x5c>
  p->sz = sz;
    80001d4c:	1782                	slli	a5,a5,0x20
    80001d4e:	9381                	srli	a5,a5,0x20
    80001d50:	04f93c23          	sd	a5,88(s2)
  return 0;
    80001d54:	4501                	li	a0,0
}
    80001d56:	60e2                	ld	ra,24(sp)
    80001d58:	6442                	ld	s0,16(sp)
    80001d5a:	64a2                	ld	s1,8(sp)
    80001d5c:	6902                	ld	s2,0(sp)
    80001d5e:	6105                	addi	sp,sp,32
    80001d60:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d62:	00f4863b          	addw	a2,s1,a5
    80001d66:	1602                	slli	a2,a2,0x20
    80001d68:	9201                	srli	a2,a2,0x20
    80001d6a:	1582                	slli	a1,a1,0x20
    80001d6c:	9181                	srli	a1,a1,0x20
    80001d6e:	7128                	ld	a0,96(a0)
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	696080e7          	jalr	1686(ra) # 80001406 <uvmalloc>
    80001d78:	0005079b          	sext.w	a5,a0
    80001d7c:	fbe1                	bnez	a5,80001d4c <growproc+0x26>
      return -1;
    80001d7e:	557d                	li	a0,-1
    80001d80:	bfd9                	j	80001d56 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d82:	00f4863b          	addw	a2,s1,a5
    80001d86:	1602                	slli	a2,a2,0x20
    80001d88:	9201                	srli	a2,a2,0x20
    80001d8a:	1582                	slli	a1,a1,0x20
    80001d8c:	9181                	srli	a1,a1,0x20
    80001d8e:	7128                	ld	a0,96(a0)
    80001d90:	fffff097          	auipc	ra,0xfffff
    80001d94:	62e080e7          	jalr	1582(ra) # 800013be <uvmdealloc>
    80001d98:	0005079b          	sext.w	a5,a0
    80001d9c:	bf45                	j	80001d4c <growproc+0x26>

0000000080001d9e <fork>:
{
    80001d9e:	7139                	addi	sp,sp,-64
    80001da0:	fc06                	sd	ra,56(sp)
    80001da2:	f822                	sd	s0,48(sp)
    80001da4:	f426                	sd	s1,40(sp)
    80001da6:	f04a                	sd	s2,32(sp)
    80001da8:	ec4e                	sd	s3,24(sp)
    80001daa:	e852                	sd	s4,16(sp)
    80001dac:	e456                	sd	s5,8(sp)
    80001dae:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001db0:	00000097          	auipc	ra,0x0
    80001db4:	be6080e7          	jalr	-1050(ra) # 80001996 <myproc>
    80001db8:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001dba:	00000097          	auipc	ra,0x0
    80001dbe:	de6080e7          	jalr	-538(ra) # 80001ba0 <allocproc>
    80001dc2:	10050c63          	beqz	a0,80001eda <fork+0x13c>
    80001dc6:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dc8:	058ab603          	ld	a2,88(s5)
    80001dcc:	712c                	ld	a1,96(a0)
    80001dce:	060ab503          	ld	a0,96(s5)
    80001dd2:	fffff097          	auipc	ra,0xfffff
    80001dd6:	784080e7          	jalr	1924(ra) # 80001556 <uvmcopy>
    80001dda:	04054863          	bltz	a0,80001e2a <fork+0x8c>
  np->sz = p->sz;
    80001dde:	058ab783          	ld	a5,88(s5)
    80001de2:	04fa3c23          	sd	a5,88(s4)
  *(np->trapframe) = *(p->trapframe);
    80001de6:	068ab683          	ld	a3,104(s5)
    80001dea:	87b6                	mv	a5,a3
    80001dec:	068a3703          	ld	a4,104(s4)
    80001df0:	12068693          	addi	a3,a3,288
    80001df4:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001df8:	6788                	ld	a0,8(a5)
    80001dfa:	6b8c                	ld	a1,16(a5)
    80001dfc:	6f90                	ld	a2,24(a5)
    80001dfe:	01073023          	sd	a6,0(a4)
    80001e02:	e708                	sd	a0,8(a4)
    80001e04:	eb0c                	sd	a1,16(a4)
    80001e06:	ef10                	sd	a2,24(a4)
    80001e08:	02078793          	addi	a5,a5,32
    80001e0c:	02070713          	addi	a4,a4,32
    80001e10:	fed792e3          	bne	a5,a3,80001df4 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e14:	068a3783          	ld	a5,104(s4)
    80001e18:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e1c:	0e0a8493          	addi	s1,s5,224
    80001e20:	0e0a0913          	addi	s2,s4,224
    80001e24:	160a8993          	addi	s3,s5,352
    80001e28:	a00d                	j	80001e4a <fork+0xac>
    freeproc(np);
    80001e2a:	8552                	mv	a0,s4
    80001e2c:	00000097          	auipc	ra,0x0
    80001e30:	d1c080e7          	jalr	-740(ra) # 80001b48 <freeproc>
    release(&np->lock);
    80001e34:	8552                	mv	a0,s4
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	e4e080e7          	jalr	-434(ra) # 80000c84 <release>
    return -1;
    80001e3e:	597d                	li	s2,-1
    80001e40:	a059                	j	80001ec6 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e42:	04a1                	addi	s1,s1,8
    80001e44:	0921                	addi	s2,s2,8
    80001e46:	01348b63          	beq	s1,s3,80001e5c <fork+0xbe>
    if(p->ofile[i])
    80001e4a:	6088                	ld	a0,0(s1)
    80001e4c:	d97d                	beqz	a0,80001e42 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e4e:	00003097          	auipc	ra,0x3
    80001e52:	8c8080e7          	jalr	-1848(ra) # 80004716 <filedup>
    80001e56:	00a93023          	sd	a0,0(s2)
    80001e5a:	b7e5                	j	80001e42 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e5c:	160ab503          	ld	a0,352(s5)
    80001e60:	00002097          	auipc	ra,0x2
    80001e64:	a26080e7          	jalr	-1498(ra) # 80003886 <idup>
    80001e68:	16aa3023          	sd	a0,352(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e6c:	4641                	li	a2,16
    80001e6e:	168a8593          	addi	a1,s5,360
    80001e72:	168a0513          	addi	a0,s4,360
    80001e76:	fffff097          	auipc	ra,0xfffff
    80001e7a:	fa0080e7          	jalr	-96(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e7e:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e82:	8552                	mv	a0,s4
    80001e84:	fffff097          	auipc	ra,0xfffff
    80001e88:	e00080e7          	jalr	-512(ra) # 80000c84 <release>
  acquire(&wait_lock);
    80001e8c:	0000f497          	auipc	s1,0xf
    80001e90:	42c48493          	addi	s1,s1,1068 # 800112b8 <wait_lock>
    80001e94:	8526                	mv	a0,s1
    80001e96:	fffff097          	auipc	ra,0xfffff
    80001e9a:	d3a080e7          	jalr	-710(ra) # 80000bd0 <acquire>
  np->parent = p;
    80001e9e:	055a3423          	sd	s5,72(s4)
  release(&wait_lock);
    80001ea2:	8526                	mv	a0,s1
    80001ea4:	fffff097          	auipc	ra,0xfffff
    80001ea8:	de0080e7          	jalr	-544(ra) # 80000c84 <release>
  acquire(&np->lock);
    80001eac:	8552                	mv	a0,s4
    80001eae:	fffff097          	auipc	ra,0xfffff
    80001eb2:	d22080e7          	jalr	-734(ra) # 80000bd0 <acquire>
  np->state = RUNNABLE;
    80001eb6:	478d                	li	a5,3
    80001eb8:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001ebc:	8552                	mv	a0,s4
    80001ebe:	fffff097          	auipc	ra,0xfffff
    80001ec2:	dc6080e7          	jalr	-570(ra) # 80000c84 <release>
}
    80001ec6:	854a                	mv	a0,s2
    80001ec8:	70e2                	ld	ra,56(sp)
    80001eca:	7442                	ld	s0,48(sp)
    80001ecc:	74a2                	ld	s1,40(sp)
    80001ece:	7902                	ld	s2,32(sp)
    80001ed0:	69e2                	ld	s3,24(sp)
    80001ed2:	6a42                	ld	s4,16(sp)
    80001ed4:	6aa2                	ld	s5,8(sp)
    80001ed6:	6121                	addi	sp,sp,64
    80001ed8:	8082                	ret
    return -1;
    80001eda:	597d                	li	s2,-1
    80001edc:	b7ed                	j	80001ec6 <fork+0x128>

0000000080001ede <scheduler>:
{
    80001ede:	711d                	addi	sp,sp,-96
    80001ee0:	ec86                	sd	ra,88(sp)
    80001ee2:	e8a2                	sd	s0,80(sp)
    80001ee4:	e4a6                	sd	s1,72(sp)
    80001ee6:	e0ca                	sd	s2,64(sp)
    80001ee8:	fc4e                	sd	s3,56(sp)
    80001eea:	f852                	sd	s4,48(sp)
    80001eec:	f456                	sd	s5,40(sp)
    80001eee:	f05a                	sd	s6,32(sp)
    80001ef0:	ec5e                	sd	s7,24(sp)
    80001ef2:	e862                	sd	s8,16(sp)
    80001ef4:	e466                	sd	s9,8(sp)
    80001ef6:	1080                	addi	s0,sp,96
    80001ef8:	8792                	mv	a5,tp
  int id = r_tp();
    80001efa:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001efc:	00779693          	slli	a3,a5,0x7
    80001f00:	0000f717          	auipc	a4,0xf
    80001f04:	3a070713          	addi	a4,a4,928 # 800112a0 <pid_lock>
    80001f08:	9736                	add	a4,a4,a3
    80001f0a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &highPriorityJob->context);
    80001f0e:	0000f717          	auipc	a4,0xf
    80001f12:	3ca70713          	addi	a4,a4,970 # 800112d8 <cpus+0x8>
    80001f16:	00e68cb3          	add	s9,a3,a4
      if(schedulerCounter==MOVEUP){
    80001f1a:	00007a17          	auipc	s4,0x7
    80001f1e:	116a0a13          	addi	s4,s4,278 # 80009030 <schedulerCounter>
    80001f22:	4b65                	li	s6,25
              if(p1->state == RUNNABLE){
    80001f24:	448d                	li	s1,3
          for(p1=proc;p1<&proc[NPROC];p1++){
    80001f26:	00015917          	auipc	s2,0x15
    80001f2a:	7aa90913          	addi	s2,s2,1962 # 800176d0 <tickslock>
      struct proc *highPriorityJob = NULL;
    80001f2e:	4a81                	li	s5,0
            c->proc = 0;
    80001f30:	0000fb97          	auipc	s7,0xf
    80001f34:	370b8b93          	addi	s7,s7,880 # 800112a0 <pid_lock>
    80001f38:	9bb6                	add	s7,s7,a3
    80001f3a:	a0ad                	j	80001fa4 <scheduler+0xc6>
          for(p1=proc;p1<&proc[NPROC];p1++){
    80001f3c:	0000f997          	auipc	s3,0xf
    80001f40:	79498993          	addi	s3,s3,1940 # 800116d0 <proc>
    80001f44:	a029                	j	80001f4e <scheduler+0x70>
    80001f46:	18098993          	addi	s3,s3,384
    80001f4a:	03298363          	beq	s3,s2,80001f70 <scheduler+0x92>
              if(p1->state == RUNNABLE){
    80001f4e:	0189a783          	lw	a5,24(s3)
    80001f52:	fe979ae3          	bne	a5,s1,80001f46 <scheduler+0x68>
                  acquire(&p1->lock);
    80001f56:	854e                	mv	a0,s3
    80001f58:	fffff097          	auipc	ra,0xfffff
    80001f5c:	c78080e7          	jalr	-904(ra) # 80000bd0 <acquire>
                p1->runtime = 0;
    80001f60:	1609ac23          	sw	zero,376(s3)
                release(&p1->lock);
    80001f64:	854e                	mv	a0,s3
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	d1e080e7          	jalr	-738(ra) # 80000c84 <release>
    80001f6e:	bfe1                	j	80001f46 <scheduler+0x68>
          schedulerCounter = 0;
    80001f70:	000a3023          	sd	zero,0(s4)
    80001f74:	a091                	j	80001fb8 <scheduler+0xda>
    80001f76:	89be                	mv	s3,a5
    for(p = proc;p < &proc[NPROC]; p++){
    80001f78:	18078793          	addi	a5,a5,384
    80001f7c:	01278e63          	beq	a5,s2,80001f98 <scheduler+0xba>
         if(p->state == RUNNABLE) {
    80001f80:	4f98                	lw	a4,24(a5)
    80001f82:	fe971be3          	bne	a4,s1,80001f78 <scheduler+0x9a>
                if( highPriorityJob!=NULL){
    80001f86:	fe0988e3          	beqz	s3,80001f76 <scheduler+0x98>
                      if(highPriorityJob->priority>p->priority){
    80001f8a:	0389a683          	lw	a3,56(s3)
    80001f8e:	5f98                	lw	a4,56(a5)
    80001f90:	fed774e3          	bgeu	a4,a3,80001f78 <scheduler+0x9a>
    80001f94:	89be                	mv	s3,a5
    80001f96:	b7cd                	j	80001f78 <scheduler+0x9a>
      if(highPriorityJob!=NULL){
    80001f98:	00098663          	beqz	s3,80001fa4 <scheduler+0xc6>
       if(highPriorityJob->state == RUNNABLE && (holding(& highPriorityJob->lock)!=1)) {
    80001f9c:	0189a783          	lw	a5,24(s3)
    80001fa0:	02978263          	beq	a5,s1,80001fc4 <scheduler+0xe6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fa4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fa8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fac:	10079073          	csrw	sstatus,a5
      if(schedulerCounter==MOVEUP){
    80001fb0:	000a3783          	ld	a5,0(s4)
    80001fb4:	f96784e3          	beq	a5,s6,80001f3c <scheduler+0x5e>
      struct proc *highPriorityJob = NULL;
    80001fb8:	89d6                	mv	s3,s5
    for(p = proc;p < &proc[NPROC]; p++){
    80001fba:	0000f797          	auipc	a5,0xf
    80001fbe:	71678793          	addi	a5,a5,1814 # 800116d0 <proc>
    80001fc2:	bf7d                	j	80001f80 <scheduler+0xa2>
       if(highPriorityJob->state == RUNNABLE && (holding(& highPriorityJob->lock)!=1)) {
    80001fc4:	8c4e                	mv	s8,s3
    80001fc6:	854e                	mv	a0,s3
    80001fc8:	fffff097          	auipc	ra,0xfffff
    80001fcc:	b8e080e7          	jalr	-1138(ra) # 80000b56 <holding>
    80001fd0:	4785                	li	a5,1
    80001fd2:	fcf509e3          	beq	a0,a5,80001fa4 <scheduler+0xc6>
        acquire(&highPriorityJob->lock);
    80001fd6:	854e                	mv	a0,s3
    80001fd8:	fffff097          	auipc	ra,0xfffff
    80001fdc:	bf8080e7          	jalr	-1032(ra) # 80000bd0 <acquire>
           if(highPriorityJob->state == RUNNABLE){
    80001fe0:	0189a783          	lw	a5,24(s3)
    80001fe4:	04979363          	bne	a5,s1,8000202a <scheduler+0x14c>
                highPriorityJob->state = RUNNING;
    80001fe8:	4791                	li	a5,4
    80001fea:	00f9ac23          	sw	a5,24(s3)
        c->proc = highPriorityJob;
    80001fee:	033bb823          	sd	s3,48(s7)
        swtch(&c->context, &highPriorityJob->context);
    80001ff2:	07098593          	addi	a1,s3,112
    80001ff6:	8566                	mv	a0,s9
    80001ff8:	00001097          	auipc	ra,0x1
    80001ffc:	804080e7          	jalr	-2044(ra) # 800027fc <swtch>
        if(highPriorityJob->priority==HIGH){
    80002000:	0389a783          	lw	a5,56(s3)
    80002004:	eb9d                	bnez	a5,8000203a <scheduler+0x15c>
             highPriorityJob->priority=MEDIUM;
    80002006:	4785                	li	a5,1
    80002008:	02f9ac23          	sw	a5,56(s3)
         } highPriorityJob->runtime++;
    8000200c:	1789a783          	lw	a5,376(s3)
    80002010:	2785                	addiw	a5,a5,1
    80002012:	16f9ac23          	sw	a5,376(s3)
           highPriorityJob->running++; 
    80002016:	0349a783          	lw	a5,52(s3)
    8000201a:	2785                	addiw	a5,a5,1
    8000201c:	02f9aa23          	sw	a5,52(s3)
           schedulerCounter++;
    80002020:	000a3783          	ld	a5,0(s4)
    80002024:	0785                	addi	a5,a5,1
    80002026:	00fa3023          	sd	a5,0(s4)
            c->proc = 0;
    8000202a:	020bb823          	sd	zero,48(s7)
           release(&highPriorityJob->lock);
    8000202e:	8562                	mv	a0,s8
    80002030:	fffff097          	auipc	ra,0xfffff
    80002034:	c54080e7          	jalr	-940(ra) # 80000c84 <release>
    80002038:	b7b5                	j	80001fa4 <scheduler+0xc6>
         }else if((highPriorityJob->priority==MEDIUM) && (highPriorityJob->runtime==MTIMES)) {
    8000203a:	4705                	li	a4,1
    8000203c:	fce798e3          	bne	a5,a4,8000200c <scheduler+0x12e>
    80002040:	1789a703          	lw	a4,376(s3)
    80002044:	4795                	li	a5,5
    80002046:	fcf713e3          	bne	a4,a5,8000200c <scheduler+0x12e>
              highPriorityJob->priority=LOW;
    8000204a:	4789                	li	a5,2
    8000204c:	02f9ac23          	sw	a5,56(s3)
    80002050:	bf75                	j	8000200c <scheduler+0x12e>

0000000080002052 <sched>:
{
    80002052:	7179                	addi	sp,sp,-48
    80002054:	f406                	sd	ra,40(sp)
    80002056:	f022                	sd	s0,32(sp)
    80002058:	ec26                	sd	s1,24(sp)
    8000205a:	e84a                	sd	s2,16(sp)
    8000205c:	e44e                	sd	s3,8(sp)
    8000205e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002060:	00000097          	auipc	ra,0x0
    80002064:	936080e7          	jalr	-1738(ra) # 80001996 <myproc>
    80002068:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000206a:	fffff097          	auipc	ra,0xfffff
    8000206e:	aec080e7          	jalr	-1300(ra) # 80000b56 <holding>
    80002072:	c93d                	beqz	a0,800020e8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002074:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002076:	2781                	sext.w	a5,a5
    80002078:	079e                	slli	a5,a5,0x7
    8000207a:	0000f717          	auipc	a4,0xf
    8000207e:	22670713          	addi	a4,a4,550 # 800112a0 <pid_lock>
    80002082:	97ba                	add	a5,a5,a4
    80002084:	0a87a703          	lw	a4,168(a5)
    80002088:	4785                	li	a5,1
    8000208a:	06f71763          	bne	a4,a5,800020f8 <sched+0xa6>
  if(p->state == RUNNING)
    8000208e:	4c98                	lw	a4,24(s1)
    80002090:	4791                	li	a5,4
    80002092:	06f70b63          	beq	a4,a5,80002108 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002096:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000209a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000209c:	efb5                	bnez	a5,80002118 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000209e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020a0:	0000f917          	auipc	s2,0xf
    800020a4:	20090913          	addi	s2,s2,512 # 800112a0 <pid_lock>
    800020a8:	2781                	sext.w	a5,a5
    800020aa:	079e                	slli	a5,a5,0x7
    800020ac:	97ca                	add	a5,a5,s2
    800020ae:	0ac7a983          	lw	s3,172(a5)
    800020b2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020b4:	2781                	sext.w	a5,a5
    800020b6:	079e                	slli	a5,a5,0x7
    800020b8:	0000f597          	auipc	a1,0xf
    800020bc:	22058593          	addi	a1,a1,544 # 800112d8 <cpus+0x8>
    800020c0:	95be                	add	a1,a1,a5
    800020c2:	07048513          	addi	a0,s1,112
    800020c6:	00000097          	auipc	ra,0x0
    800020ca:	736080e7          	jalr	1846(ra) # 800027fc <swtch>
    800020ce:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020d0:	2781                	sext.w	a5,a5
    800020d2:	079e                	slli	a5,a5,0x7
    800020d4:	993e                	add	s2,s2,a5
    800020d6:	0b392623          	sw	s3,172(s2)
}
    800020da:	70a2                	ld	ra,40(sp)
    800020dc:	7402                	ld	s0,32(sp)
    800020de:	64e2                	ld	s1,24(sp)
    800020e0:	6942                	ld	s2,16(sp)
    800020e2:	69a2                	ld	s3,8(sp)
    800020e4:	6145                	addi	sp,sp,48
    800020e6:	8082                	ret
    panic("sched p->lock");
    800020e8:	00006517          	auipc	a0,0x6
    800020ec:	13050513          	addi	a0,a0,304 # 80008218 <digits+0x1d8>
    800020f0:	ffffe097          	auipc	ra,0xffffe
    800020f4:	44a080e7          	jalr	1098(ra) # 8000053a <panic>
    panic("sched locks");
    800020f8:	00006517          	auipc	a0,0x6
    800020fc:	13050513          	addi	a0,a0,304 # 80008228 <digits+0x1e8>
    80002100:	ffffe097          	auipc	ra,0xffffe
    80002104:	43a080e7          	jalr	1082(ra) # 8000053a <panic>
    panic("sched running");
    80002108:	00006517          	auipc	a0,0x6
    8000210c:	13050513          	addi	a0,a0,304 # 80008238 <digits+0x1f8>
    80002110:	ffffe097          	auipc	ra,0xffffe
    80002114:	42a080e7          	jalr	1066(ra) # 8000053a <panic>
    panic("sched interruptible");
    80002118:	00006517          	auipc	a0,0x6
    8000211c:	13050513          	addi	a0,a0,304 # 80008248 <digits+0x208>
    80002120:	ffffe097          	auipc	ra,0xffffe
    80002124:	41a080e7          	jalr	1050(ra) # 8000053a <panic>

0000000080002128 <yield>:
{
    80002128:	1101                	addi	sp,sp,-32
    8000212a:	ec06                	sd	ra,24(sp)
    8000212c:	e822                	sd	s0,16(sp)
    8000212e:	e426                	sd	s1,8(sp)
    80002130:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002132:	00000097          	auipc	ra,0x0
    80002136:	864080e7          	jalr	-1948(ra) # 80001996 <myproc>
    8000213a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000213c:	fffff097          	auipc	ra,0xfffff
    80002140:	a94080e7          	jalr	-1388(ra) # 80000bd0 <acquire>
  p->state = RUNNABLE;
    80002144:	478d                	li	a5,3
    80002146:	cc9c                	sw	a5,24(s1)
  sched();
    80002148:	00000097          	auipc	ra,0x0
    8000214c:	f0a080e7          	jalr	-246(ra) # 80002052 <sched>
  release(&p->lock);
    80002150:	8526                	mv	a0,s1
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	b32080e7          	jalr	-1230(ra) # 80000c84 <release>
}
    8000215a:	60e2                	ld	ra,24(sp)
    8000215c:	6442                	ld	s0,16(sp)
    8000215e:	64a2                	ld	s1,8(sp)
    80002160:	6105                	addi	sp,sp,32
    80002162:	8082                	ret

0000000080002164 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002164:	7179                	addi	sp,sp,-48
    80002166:	f406                	sd	ra,40(sp)
    80002168:	f022                	sd	s0,32(sp)
    8000216a:	ec26                	sd	s1,24(sp)
    8000216c:	e84a                	sd	s2,16(sp)
    8000216e:	e44e                	sd	s3,8(sp)
    80002170:	1800                	addi	s0,sp,48
    80002172:	89aa                	mv	s3,a0
    80002174:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002176:	00000097          	auipc	ra,0x0
    8000217a:	820080e7          	jalr	-2016(ra) # 80001996 <myproc>
    8000217e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002180:	fffff097          	auipc	ra,0xfffff
    80002184:	a50080e7          	jalr	-1456(ra) # 80000bd0 <acquire>
  release(lk);
    80002188:	854a                	mv	a0,s2
    8000218a:	fffff097          	auipc	ra,0xfffff
    8000218e:	afa080e7          	jalr	-1286(ra) # 80000c84 <release>

  // Go to sleep.
  p->chan = chan;
    80002192:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002196:	4789                	li	a5,2
    80002198:	cc9c                	sw	a5,24(s1)

  sched();
    8000219a:	00000097          	auipc	ra,0x0
    8000219e:	eb8080e7          	jalr	-328(ra) # 80002052 <sched>

  // Tidy up.
  p->chan = 0;
    800021a2:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021a6:	8526                	mv	a0,s1
    800021a8:	fffff097          	auipc	ra,0xfffff
    800021ac:	adc080e7          	jalr	-1316(ra) # 80000c84 <release>
  acquire(lk);
    800021b0:	854a                	mv	a0,s2
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	a1e080e7          	jalr	-1506(ra) # 80000bd0 <acquire>
}
    800021ba:	70a2                	ld	ra,40(sp)
    800021bc:	7402                	ld	s0,32(sp)
    800021be:	64e2                	ld	s1,24(sp)
    800021c0:	6942                	ld	s2,16(sp)
    800021c2:	69a2                	ld	s3,8(sp)
    800021c4:	6145                	addi	sp,sp,48
    800021c6:	8082                	ret

00000000800021c8 <wait>:
{
    800021c8:	715d                	addi	sp,sp,-80
    800021ca:	e486                	sd	ra,72(sp)
    800021cc:	e0a2                	sd	s0,64(sp)
    800021ce:	fc26                	sd	s1,56(sp)
    800021d0:	f84a                	sd	s2,48(sp)
    800021d2:	f44e                	sd	s3,40(sp)
    800021d4:	f052                	sd	s4,32(sp)
    800021d6:	ec56                	sd	s5,24(sp)
    800021d8:	e85a                	sd	s6,16(sp)
    800021da:	e45e                	sd	s7,8(sp)
    800021dc:	e062                	sd	s8,0(sp)
    800021de:	0880                	addi	s0,sp,80
    800021e0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800021e2:	fffff097          	auipc	ra,0xfffff
    800021e6:	7b4080e7          	jalr	1972(ra) # 80001996 <myproc>
    800021ea:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021ec:	0000f517          	auipc	a0,0xf
    800021f0:	0cc50513          	addi	a0,a0,204 # 800112b8 <wait_lock>
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	9dc080e7          	jalr	-1572(ra) # 80000bd0 <acquire>
    havekids = 0;
    800021fc:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800021fe:	4a15                	li	s4,5
        havekids = 1;
    80002200:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002202:	00015997          	auipc	s3,0x15
    80002206:	4ce98993          	addi	s3,s3,1230 # 800176d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000220a:	0000fc17          	auipc	s8,0xf
    8000220e:	0aec0c13          	addi	s8,s8,174 # 800112b8 <wait_lock>
    havekids = 0;
    80002212:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002214:	0000f497          	auipc	s1,0xf
    80002218:	4bc48493          	addi	s1,s1,1212 # 800116d0 <proc>
    8000221c:	a0bd                	j	8000228a <wait+0xc2>
          pid = np->pid;
    8000221e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002222:	000b0e63          	beqz	s6,8000223e <wait+0x76>
    80002226:	4691                	li	a3,4
    80002228:	02c48613          	addi	a2,s1,44
    8000222c:	85da                	mv	a1,s6
    8000222e:	06093503          	ld	a0,96(s2)
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	428080e7          	jalr	1064(ra) # 8000165a <copyout>
    8000223a:	02054563          	bltz	a0,80002264 <wait+0x9c>
          freeproc(np);
    8000223e:	8526                	mv	a0,s1
    80002240:	00000097          	auipc	ra,0x0
    80002244:	908080e7          	jalr	-1784(ra) # 80001b48 <freeproc>
          release(&np->lock);
    80002248:	8526                	mv	a0,s1
    8000224a:	fffff097          	auipc	ra,0xfffff
    8000224e:	a3a080e7          	jalr	-1478(ra) # 80000c84 <release>
          release(&wait_lock);
    80002252:	0000f517          	auipc	a0,0xf
    80002256:	06650513          	addi	a0,a0,102 # 800112b8 <wait_lock>
    8000225a:	fffff097          	auipc	ra,0xfffff
    8000225e:	a2a080e7          	jalr	-1494(ra) # 80000c84 <release>
          return pid;
    80002262:	a09d                	j	800022c8 <wait+0x100>
            release(&np->lock);
    80002264:	8526                	mv	a0,s1
    80002266:	fffff097          	auipc	ra,0xfffff
    8000226a:	a1e080e7          	jalr	-1506(ra) # 80000c84 <release>
            release(&wait_lock);
    8000226e:	0000f517          	auipc	a0,0xf
    80002272:	04a50513          	addi	a0,a0,74 # 800112b8 <wait_lock>
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	a0e080e7          	jalr	-1522(ra) # 80000c84 <release>
            return -1;
    8000227e:	59fd                	li	s3,-1
    80002280:	a0a1                	j	800022c8 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002282:	18048493          	addi	s1,s1,384
    80002286:	03348463          	beq	s1,s3,800022ae <wait+0xe6>
      if(np->parent == p){
    8000228a:	64bc                	ld	a5,72(s1)
    8000228c:	ff279be3          	bne	a5,s2,80002282 <wait+0xba>
        acquire(&np->lock);
    80002290:	8526                	mv	a0,s1
    80002292:	fffff097          	auipc	ra,0xfffff
    80002296:	93e080e7          	jalr	-1730(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    8000229a:	4c9c                	lw	a5,24(s1)
    8000229c:	f94781e3          	beq	a5,s4,8000221e <wait+0x56>
        release(&np->lock);
    800022a0:	8526                	mv	a0,s1
    800022a2:	fffff097          	auipc	ra,0xfffff
    800022a6:	9e2080e7          	jalr	-1566(ra) # 80000c84 <release>
        havekids = 1;
    800022aa:	8756                	mv	a4,s5
    800022ac:	bfd9                	j	80002282 <wait+0xba>
    if(!havekids || p->killed){
    800022ae:	c701                	beqz	a4,800022b6 <wait+0xee>
    800022b0:	02892783          	lw	a5,40(s2)
    800022b4:	c79d                	beqz	a5,800022e2 <wait+0x11a>
      release(&wait_lock);
    800022b6:	0000f517          	auipc	a0,0xf
    800022ba:	00250513          	addi	a0,a0,2 # 800112b8 <wait_lock>
    800022be:	fffff097          	auipc	ra,0xfffff
    800022c2:	9c6080e7          	jalr	-1594(ra) # 80000c84 <release>
      return -1;
    800022c6:	59fd                	li	s3,-1
}
    800022c8:	854e                	mv	a0,s3
    800022ca:	60a6                	ld	ra,72(sp)
    800022cc:	6406                	ld	s0,64(sp)
    800022ce:	74e2                	ld	s1,56(sp)
    800022d0:	7942                	ld	s2,48(sp)
    800022d2:	79a2                	ld	s3,40(sp)
    800022d4:	7a02                	ld	s4,32(sp)
    800022d6:	6ae2                	ld	s5,24(sp)
    800022d8:	6b42                	ld	s6,16(sp)
    800022da:	6ba2                	ld	s7,8(sp)
    800022dc:	6c02                	ld	s8,0(sp)
    800022de:	6161                	addi	sp,sp,80
    800022e0:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022e2:	85e2                	mv	a1,s8
    800022e4:	854a                	mv	a0,s2
    800022e6:	00000097          	auipc	ra,0x0
    800022ea:	e7e080e7          	jalr	-386(ra) # 80002164 <sleep>
    havekids = 0;
    800022ee:	b715                	j	80002212 <wait+0x4a>

00000000800022f0 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800022f0:	7139                	addi	sp,sp,-64
    800022f2:	fc06                	sd	ra,56(sp)
    800022f4:	f822                	sd	s0,48(sp)
    800022f6:	f426                	sd	s1,40(sp)
    800022f8:	f04a                	sd	s2,32(sp)
    800022fa:	ec4e                	sd	s3,24(sp)
    800022fc:	e852                	sd	s4,16(sp)
    800022fe:	e456                	sd	s5,8(sp)
    80002300:	0080                	addi	s0,sp,64
    80002302:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002304:	0000f497          	auipc	s1,0xf
    80002308:	3cc48493          	addi	s1,s1,972 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000230c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000230e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002310:	00015917          	auipc	s2,0x15
    80002314:	3c090913          	addi	s2,s2,960 # 800176d0 <tickslock>
    80002318:	a811                	j	8000232c <wakeup+0x3c>
      }
      release(&p->lock);
    8000231a:	8526                	mv	a0,s1
    8000231c:	fffff097          	auipc	ra,0xfffff
    80002320:	968080e7          	jalr	-1688(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002324:	18048493          	addi	s1,s1,384
    80002328:	03248663          	beq	s1,s2,80002354 <wakeup+0x64>
    if(p != myproc()){
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	66a080e7          	jalr	1642(ra) # 80001996 <myproc>
    80002334:	fea488e3          	beq	s1,a0,80002324 <wakeup+0x34>
      acquire(&p->lock);
    80002338:	8526                	mv	a0,s1
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	896080e7          	jalr	-1898(ra) # 80000bd0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002342:	4c9c                	lw	a5,24(s1)
    80002344:	fd379be3          	bne	a5,s3,8000231a <wakeup+0x2a>
    80002348:	709c                	ld	a5,32(s1)
    8000234a:	fd4798e3          	bne	a5,s4,8000231a <wakeup+0x2a>
        p->state = RUNNABLE;
    8000234e:	0154ac23          	sw	s5,24(s1)
    80002352:	b7e1                	j	8000231a <wakeup+0x2a>
    }
  }
}
    80002354:	70e2                	ld	ra,56(sp)
    80002356:	7442                	ld	s0,48(sp)
    80002358:	74a2                	ld	s1,40(sp)
    8000235a:	7902                	ld	s2,32(sp)
    8000235c:	69e2                	ld	s3,24(sp)
    8000235e:	6a42                	ld	s4,16(sp)
    80002360:	6aa2                	ld	s5,8(sp)
    80002362:	6121                	addi	sp,sp,64
    80002364:	8082                	ret

0000000080002366 <reparent>:
{
    80002366:	7179                	addi	sp,sp,-48
    80002368:	f406                	sd	ra,40(sp)
    8000236a:	f022                	sd	s0,32(sp)
    8000236c:	ec26                	sd	s1,24(sp)
    8000236e:	e84a                	sd	s2,16(sp)
    80002370:	e44e                	sd	s3,8(sp)
    80002372:	e052                	sd	s4,0(sp)
    80002374:	1800                	addi	s0,sp,48
    80002376:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002378:	0000f497          	auipc	s1,0xf
    8000237c:	35848493          	addi	s1,s1,856 # 800116d0 <proc>
      pp->parent = initproc;
    80002380:	00007a17          	auipc	s4,0x7
    80002384:	ca8a0a13          	addi	s4,s4,-856 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002388:	00015997          	auipc	s3,0x15
    8000238c:	34898993          	addi	s3,s3,840 # 800176d0 <tickslock>
    80002390:	a029                	j	8000239a <reparent+0x34>
    80002392:	18048493          	addi	s1,s1,384
    80002396:	01348d63          	beq	s1,s3,800023b0 <reparent+0x4a>
    if(pp->parent == p){
    8000239a:	64bc                	ld	a5,72(s1)
    8000239c:	ff279be3          	bne	a5,s2,80002392 <reparent+0x2c>
      pp->parent = initproc;
    800023a0:	000a3503          	ld	a0,0(s4)
    800023a4:	e4a8                	sd	a0,72(s1)
      wakeup(initproc);
    800023a6:	00000097          	auipc	ra,0x0
    800023aa:	f4a080e7          	jalr	-182(ra) # 800022f0 <wakeup>
    800023ae:	b7d5                	j	80002392 <reparent+0x2c>
}
    800023b0:	70a2                	ld	ra,40(sp)
    800023b2:	7402                	ld	s0,32(sp)
    800023b4:	64e2                	ld	s1,24(sp)
    800023b6:	6942                	ld	s2,16(sp)
    800023b8:	69a2                	ld	s3,8(sp)
    800023ba:	6a02                	ld	s4,0(sp)
    800023bc:	6145                	addi	sp,sp,48
    800023be:	8082                	ret

00000000800023c0 <exit>:
{
    800023c0:	7179                	addi	sp,sp,-48
    800023c2:	f406                	sd	ra,40(sp)
    800023c4:	f022                	sd	s0,32(sp)
    800023c6:	ec26                	sd	s1,24(sp)
    800023c8:	e84a                	sd	s2,16(sp)
    800023ca:	e44e                	sd	s3,8(sp)
    800023cc:	e052                	sd	s4,0(sp)
    800023ce:	1800                	addi	s0,sp,48
    800023d0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800023d2:	fffff097          	auipc	ra,0xfffff
    800023d6:	5c4080e7          	jalr	1476(ra) # 80001996 <myproc>
    800023da:	89aa                	mv	s3,a0
  acquire(&tickslock);
    800023dc:	00015517          	auipc	a0,0x15
    800023e0:	2f450513          	addi	a0,a0,756 # 800176d0 <tickslock>
    800023e4:	ffffe097          	auipc	ra,0xffffe
    800023e8:	7ec080e7          	jalr	2028(ra) # 80000bd0 <acquire>
  p->ended = ticks;
    800023ec:	00007797          	auipc	a5,0x7
    800023f0:	c4c7a783          	lw	a5,-948(a5) # 80009038 <ticks>
    800023f4:	04f9a023          	sw	a5,64(s3)
  release(&tickslock);  
    800023f8:	00015517          	auipc	a0,0x15
    800023fc:	2d850513          	addi	a0,a0,728 # 800176d0 <tickslock>
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	884080e7          	jalr	-1916(ra) # 80000c84 <release>
  if(p == initproc)
    80002408:	00007797          	auipc	a5,0x7
    8000240c:	c207b783          	ld	a5,-992(a5) # 80009028 <initproc>
    80002410:	0e098493          	addi	s1,s3,224
    80002414:	16098913          	addi	s2,s3,352
    80002418:	03379363          	bne	a5,s3,8000243e <exit+0x7e>
    panic("init exiting");
    8000241c:	00006517          	auipc	a0,0x6
    80002420:	e4450513          	addi	a0,a0,-444 # 80008260 <digits+0x220>
    80002424:	ffffe097          	auipc	ra,0xffffe
    80002428:	116080e7          	jalr	278(ra) # 8000053a <panic>
      fileclose(f);
    8000242c:	00002097          	auipc	ra,0x2
    80002430:	33c080e7          	jalr	828(ra) # 80004768 <fileclose>
      p->ofile[fd] = 0;
    80002434:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002438:	04a1                	addi	s1,s1,8
    8000243a:	01248563          	beq	s1,s2,80002444 <exit+0x84>
    if(p->ofile[fd]){
    8000243e:	6088                	ld	a0,0(s1)
    80002440:	f575                	bnez	a0,8000242c <exit+0x6c>
    80002442:	bfdd                	j	80002438 <exit+0x78>
  begin_op();
    80002444:	00002097          	auipc	ra,0x2
    80002448:	e5c080e7          	jalr	-420(ra) # 800042a0 <begin_op>
  iput(p->cwd);
    8000244c:	1609b503          	ld	a0,352(s3)
    80002450:	00001097          	auipc	ra,0x1
    80002454:	62e080e7          	jalr	1582(ra) # 80003a7e <iput>
  end_op();
    80002458:	00002097          	auipc	ra,0x2
    8000245c:	ec6080e7          	jalr	-314(ra) # 8000431e <end_op>
  p->cwd = 0;
    80002460:	1609b023          	sd	zero,352(s3)
  acquire(&wait_lock);
    80002464:	0000f497          	auipc	s1,0xf
    80002468:	e5448493          	addi	s1,s1,-428 # 800112b8 <wait_lock>
    8000246c:	8526                	mv	a0,s1
    8000246e:	ffffe097          	auipc	ra,0xffffe
    80002472:	762080e7          	jalr	1890(ra) # 80000bd0 <acquire>
  reparent(p);
    80002476:	854e                	mv	a0,s3
    80002478:	00000097          	auipc	ra,0x0
    8000247c:	eee080e7          	jalr	-274(ra) # 80002366 <reparent>
  wakeup(p->parent);
    80002480:	0489b503          	ld	a0,72(s3)
    80002484:	00000097          	auipc	ra,0x0
    80002488:	e6c080e7          	jalr	-404(ra) # 800022f0 <wakeup>
  acquire(&p->lock);
    8000248c:	854e                	mv	a0,s3
    8000248e:	ffffe097          	auipc	ra,0xffffe
    80002492:	742080e7          	jalr	1858(ra) # 80000bd0 <acquire>
  p->xstate = status;
    80002496:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000249a:	4795                	li	a5,5
    8000249c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800024a0:	8526                	mv	a0,s1
    800024a2:	ffffe097          	auipc	ra,0xffffe
    800024a6:	7e2080e7          	jalr	2018(ra) # 80000c84 <release>
  sched();
    800024aa:	00000097          	auipc	ra,0x0
    800024ae:	ba8080e7          	jalr	-1112(ra) # 80002052 <sched>
  panic("zombie exit");
    800024b2:	00006517          	auipc	a0,0x6
    800024b6:	dbe50513          	addi	a0,a0,-578 # 80008270 <digits+0x230>
    800024ba:	ffffe097          	auipc	ra,0xffffe
    800024be:	080080e7          	jalr	128(ra) # 8000053a <panic>

00000000800024c2 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800024c2:	7179                	addi	sp,sp,-48
    800024c4:	f406                	sd	ra,40(sp)
    800024c6:	f022                	sd	s0,32(sp)
    800024c8:	ec26                	sd	s1,24(sp)
    800024ca:	e84a                	sd	s2,16(sp)
    800024cc:	e44e                	sd	s3,8(sp)
    800024ce:	1800                	addi	s0,sp,48
    800024d0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024d2:	0000f497          	auipc	s1,0xf
    800024d6:	1fe48493          	addi	s1,s1,510 # 800116d0 <proc>
    800024da:	00015997          	auipc	s3,0x15
    800024de:	1f698993          	addi	s3,s3,502 # 800176d0 <tickslock>
    acquire(&p->lock);
    800024e2:	8526                	mv	a0,s1
    800024e4:	ffffe097          	auipc	ra,0xffffe
    800024e8:	6ec080e7          	jalr	1772(ra) # 80000bd0 <acquire>
    if(p->pid == pid){
    800024ec:	589c                	lw	a5,48(s1)
    800024ee:	01278d63          	beq	a5,s2,80002508 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024f2:	8526                	mv	a0,s1
    800024f4:	ffffe097          	auipc	ra,0xffffe
    800024f8:	790080e7          	jalr	1936(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024fc:	18048493          	addi	s1,s1,384
    80002500:	ff3491e3          	bne	s1,s3,800024e2 <kill+0x20>
  }
  return -1;
    80002504:	557d                	li	a0,-1
    80002506:	a829                	j	80002520 <kill+0x5e>
      p->killed = 1;
    80002508:	4785                	li	a5,1
    8000250a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000250c:	4c98                	lw	a4,24(s1)
    8000250e:	4789                	li	a5,2
    80002510:	00f70f63          	beq	a4,a5,8000252e <kill+0x6c>
      release(&p->lock);
    80002514:	8526                	mv	a0,s1
    80002516:	ffffe097          	auipc	ra,0xffffe
    8000251a:	76e080e7          	jalr	1902(ra) # 80000c84 <release>
      return 0;
    8000251e:	4501                	li	a0,0
}
    80002520:	70a2                	ld	ra,40(sp)
    80002522:	7402                	ld	s0,32(sp)
    80002524:	64e2                	ld	s1,24(sp)
    80002526:	6942                	ld	s2,16(sp)
    80002528:	69a2                	ld	s3,8(sp)
    8000252a:	6145                	addi	sp,sp,48
    8000252c:	8082                	ret
        p->state = RUNNABLE;
    8000252e:	478d                	li	a5,3
    80002530:	cc9c                	sw	a5,24(s1)
    80002532:	b7cd                	j	80002514 <kill+0x52>

0000000080002534 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002534:	7179                	addi	sp,sp,-48
    80002536:	f406                	sd	ra,40(sp)
    80002538:	f022                	sd	s0,32(sp)
    8000253a:	ec26                	sd	s1,24(sp)
    8000253c:	e84a                	sd	s2,16(sp)
    8000253e:	e44e                	sd	s3,8(sp)
    80002540:	e052                	sd	s4,0(sp)
    80002542:	1800                	addi	s0,sp,48
    80002544:	84aa                	mv	s1,a0
    80002546:	892e                	mv	s2,a1
    80002548:	89b2                	mv	s3,a2
    8000254a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000254c:	fffff097          	auipc	ra,0xfffff
    80002550:	44a080e7          	jalr	1098(ra) # 80001996 <myproc>
  if(user_dst){
    80002554:	c08d                	beqz	s1,80002576 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002556:	86d2                	mv	a3,s4
    80002558:	864e                	mv	a2,s3
    8000255a:	85ca                	mv	a1,s2
    8000255c:	7128                	ld	a0,96(a0)
    8000255e:	fffff097          	auipc	ra,0xfffff
    80002562:	0fc080e7          	jalr	252(ra) # 8000165a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002566:	70a2                	ld	ra,40(sp)
    80002568:	7402                	ld	s0,32(sp)
    8000256a:	64e2                	ld	s1,24(sp)
    8000256c:	6942                	ld	s2,16(sp)
    8000256e:	69a2                	ld	s3,8(sp)
    80002570:	6a02                	ld	s4,0(sp)
    80002572:	6145                	addi	sp,sp,48
    80002574:	8082                	ret
    memmove((char *)dst, src, len);
    80002576:	000a061b          	sext.w	a2,s4
    8000257a:	85ce                	mv	a1,s3
    8000257c:	854a                	mv	a0,s2
    8000257e:	ffffe097          	auipc	ra,0xffffe
    80002582:	7aa080e7          	jalr	1962(ra) # 80000d28 <memmove>
    return 0;
    80002586:	8526                	mv	a0,s1
    80002588:	bff9                	j	80002566 <either_copyout+0x32>

000000008000258a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000258a:	7179                	addi	sp,sp,-48
    8000258c:	f406                	sd	ra,40(sp)
    8000258e:	f022                	sd	s0,32(sp)
    80002590:	ec26                	sd	s1,24(sp)
    80002592:	e84a                	sd	s2,16(sp)
    80002594:	e44e                	sd	s3,8(sp)
    80002596:	e052                	sd	s4,0(sp)
    80002598:	1800                	addi	s0,sp,48
    8000259a:	892a                	mv	s2,a0
    8000259c:	84ae                	mv	s1,a1
    8000259e:	89b2                	mv	s3,a2
    800025a0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025a2:	fffff097          	auipc	ra,0xfffff
    800025a6:	3f4080e7          	jalr	1012(ra) # 80001996 <myproc>
  if(user_src){
    800025aa:	c08d                	beqz	s1,800025cc <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025ac:	86d2                	mv	a3,s4
    800025ae:	864e                	mv	a2,s3
    800025b0:	85ca                	mv	a1,s2
    800025b2:	7128                	ld	a0,96(a0)
    800025b4:	fffff097          	auipc	ra,0xfffff
    800025b8:	132080e7          	jalr	306(ra) # 800016e6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025bc:	70a2                	ld	ra,40(sp)
    800025be:	7402                	ld	s0,32(sp)
    800025c0:	64e2                	ld	s1,24(sp)
    800025c2:	6942                	ld	s2,16(sp)
    800025c4:	69a2                	ld	s3,8(sp)
    800025c6:	6a02                	ld	s4,0(sp)
    800025c8:	6145                	addi	sp,sp,48
    800025ca:	8082                	ret
    memmove(dst, (char*)src, len);
    800025cc:	000a061b          	sext.w	a2,s4
    800025d0:	85ce                	mv	a1,s3
    800025d2:	854a                	mv	a0,s2
    800025d4:	ffffe097          	auipc	ra,0xffffe
    800025d8:	754080e7          	jalr	1876(ra) # 80000d28 <memmove>
    return 0;
    800025dc:	8526                	mv	a0,s1
    800025de:	bff9                	j	800025bc <either_copyin+0x32>

00000000800025e0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025e0:	715d                	addi	sp,sp,-80
    800025e2:	e486                	sd	ra,72(sp)
    800025e4:	e0a2                	sd	s0,64(sp)
    800025e6:	fc26                	sd	s1,56(sp)
    800025e8:	f84a                	sd	s2,48(sp)
    800025ea:	f44e                	sd	s3,40(sp)
    800025ec:	f052                	sd	s4,32(sp)
    800025ee:	ec56                	sd	s5,24(sp)
    800025f0:	e85a                	sd	s6,16(sp)
    800025f2:	e45e                	sd	s7,8(sp)
    800025f4:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025f6:	00006517          	auipc	a0,0x6
    800025fa:	ad250513          	addi	a0,a0,-1326 # 800080c8 <digits+0x88>
    800025fe:	ffffe097          	auipc	ra,0xffffe
    80002602:	f86080e7          	jalr	-122(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002606:	0000f497          	auipc	s1,0xf
    8000260a:	23248493          	addi	s1,s1,562 # 80011838 <proc+0x168>
    8000260e:	00015917          	auipc	s2,0x15
    80002612:	22a90913          	addi	s2,s2,554 # 80017838 <bcache+0x150>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002616:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002618:	00006997          	auipc	s3,0x6
    8000261c:	c6898993          	addi	s3,s3,-920 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002620:	00006a97          	auipc	s5,0x6
    80002624:	c68a8a93          	addi	s5,s5,-920 # 80008288 <digits+0x248>
    printf("\n");
    80002628:	00006a17          	auipc	s4,0x6
    8000262c:	aa0a0a13          	addi	s4,s4,-1376 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002630:	00006b97          	auipc	s7,0x6
    80002634:	c90b8b93          	addi	s7,s7,-880 # 800082c0 <states.0>
    80002638:	a00d                	j	8000265a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000263a:	ec86a583          	lw	a1,-312(a3)
    8000263e:	8556                	mv	a0,s5
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	f44080e7          	jalr	-188(ra) # 80000584 <printf>
    printf("\n");
    80002648:	8552                	mv	a0,s4
    8000264a:	ffffe097          	auipc	ra,0xffffe
    8000264e:	f3a080e7          	jalr	-198(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002652:	18048493          	addi	s1,s1,384
    80002656:	03248263          	beq	s1,s2,8000267a <procdump+0x9a>
    if(p->state == UNUSED)
    8000265a:	86a6                	mv	a3,s1
    8000265c:	eb04a783          	lw	a5,-336(s1)
    80002660:	dbed                	beqz	a5,80002652 <procdump+0x72>
      state = "???";
    80002662:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002664:	fcfb6be3          	bltu	s6,a5,8000263a <procdump+0x5a>
    80002668:	02079713          	slli	a4,a5,0x20
    8000266c:	01d75793          	srli	a5,a4,0x1d
    80002670:	97de                	add	a5,a5,s7
    80002672:	6390                	ld	a2,0(a5)
    80002674:	f279                	bnez	a2,8000263a <procdump+0x5a>
      state = "???";
    80002676:	864e                	mv	a2,s3
    80002678:	b7c9                	j	8000263a <procdump+0x5a>
  }
}
    8000267a:	60a6                	ld	ra,72(sp)
    8000267c:	6406                	ld	s0,64(sp)
    8000267e:	74e2                	ld	s1,56(sp)
    80002680:	7942                	ld	s2,48(sp)
    80002682:	79a2                	ld	s3,40(sp)
    80002684:	7a02                	ld	s4,32(sp)
    80002686:	6ae2                	ld	s5,24(sp)
    80002688:	6b42                	ld	s6,16(sp)
    8000268a:	6ba2                	ld	s7,8(sp)
    8000268c:	6161                	addi	sp,sp,80
    8000268e:	8082                	ret

0000000080002690 <waitstat>:


int waitstat(uint64 addr,uint64 turnaroundTime, uint64 runTime ){
    80002690:	7159                	addi	sp,sp,-112
    80002692:	f486                	sd	ra,104(sp)
    80002694:	f0a2                	sd	s0,96(sp)
    80002696:	eca6                	sd	s1,88(sp)
    80002698:	e8ca                	sd	s2,80(sp)
    8000269a:	e4ce                	sd	s3,72(sp)
    8000269c:	e0d2                	sd	s4,64(sp)
    8000269e:	fc56                	sd	s5,56(sp)
    800026a0:	f85a                	sd	s6,48(sp)
    800026a2:	f45e                	sd	s7,40(sp)
    800026a4:	f062                	sd	s8,32(sp)
    800026a6:	ec66                	sd	s9,24(sp)
    800026a8:	e86a                	sd	s10,16(sp)
    800026aa:	1880                	addi	s0,sp,112
    800026ac:	8b2a                	mv	s6,a0
    800026ae:	8c2e                	mv	s8,a1
    800026b0:	8bb2                	mv	s7,a2

    struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800026b2:	fffff097          	auipc	ra,0xfffff
    800026b6:	2e4080e7          	jalr	740(ra) # 80001996 <myproc>
    800026ba:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800026bc:	0000f517          	auipc	a0,0xf
    800026c0:	bfc50513          	addi	a0,a0,-1028 # 800112b8 <wait_lock>
    800026c4:	ffffe097          	auipc	ra,0xffffe
    800026c8:	50c080e7          	jalr	1292(ra) # 80000bd0 <acquire>

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    800026cc:	4c81                	li	s9,0
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
    800026ce:	4a15                	li	s4,5
        havekids = 1;
    800026d0:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800026d2:	00015997          	auipc	s3,0x15
    800026d6:	ffe98993          	addi	s3,s3,-2 # 800176d0 <tickslock>
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026da:	0000fd17          	auipc	s10,0xf
    800026de:	bded0d13          	addi	s10,s10,-1058 # 800112b8 <wait_lock>
    havekids = 0;
    800026e2:	8766                	mv	a4,s9
    for(np = proc; np < &proc[NPROC]; np++){
    800026e4:	0000f497          	auipc	s1,0xf
    800026e8:	fec48493          	addi	s1,s1,-20 # 800116d0 <proc>
    800026ec:	a05d                	j	80002792 <waitstat+0x102>
          int rTime = np->running;
    800026ee:	58dc                	lw	a5,52(s1)
    800026f0:	f8f42c23          	sw	a5,-104(s0)
          int tTime = np->ended - np-> created;
    800026f4:	40bc                	lw	a5,64(s1)
    800026f6:	5cd8                	lw	a4,60(s1)
    800026f8:	9f99                	subw	a5,a5,a4
    800026fa:	f8f42e23          	sw	a5,-100(s0)
          copyout(p->pagetable, turnaroundTime, (char *)&tTime,
    800026fe:	4691                	li	a3,4
    80002700:	f9c40613          	addi	a2,s0,-100
    80002704:	85e2                	mv	a1,s8
    80002706:	06093503          	ld	a0,96(s2)
    8000270a:	fffff097          	auipc	ra,0xfffff
    8000270e:	f50080e7          	jalr	-176(ra) # 8000165a <copyout>
          copyout(p->pagetable, runTime, (char *)&rTime,
    80002712:	4691                	li	a3,4
    80002714:	f9840613          	addi	a2,s0,-104
    80002718:	85de                	mv	a1,s7
    8000271a:	06093503          	ld	a0,96(s2)
    8000271e:	fffff097          	auipc	ra,0xfffff
    80002722:	f3c080e7          	jalr	-196(ra) # 8000165a <copyout>
          pid = np->pid;
    80002726:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000272a:	000b0e63          	beqz	s6,80002746 <waitstat+0xb6>
    8000272e:	4691                	li	a3,4
    80002730:	02c48613          	addi	a2,s1,44
    80002734:	85da                	mv	a1,s6
    80002736:	06093503          	ld	a0,96(s2)
    8000273a:	fffff097          	auipc	ra,0xfffff
    8000273e:	f20080e7          	jalr	-224(ra) # 8000165a <copyout>
    80002742:	02054563          	bltz	a0,8000276c <waitstat+0xdc>
          freeproc(np);
    80002746:	8526                	mv	a0,s1
    80002748:	fffff097          	auipc	ra,0xfffff
    8000274c:	400080e7          	jalr	1024(ra) # 80001b48 <freeproc>
          release(&np->lock);
    80002750:	8526                	mv	a0,s1
    80002752:	ffffe097          	auipc	ra,0xffffe
    80002756:	532080e7          	jalr	1330(ra) # 80000c84 <release>
          release(&wait_lock);
    8000275a:	0000f517          	auipc	a0,0xf
    8000275e:	b5e50513          	addi	a0,a0,-1186 # 800112b8 <wait_lock>
    80002762:	ffffe097          	auipc	ra,0xffffe
    80002766:	522080e7          	jalr	1314(ra) # 80000c84 <release>
          return pid;
    8000276a:	a09d                	j	800027d0 <waitstat+0x140>
            release(&np->lock);
    8000276c:	8526                	mv	a0,s1
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	516080e7          	jalr	1302(ra) # 80000c84 <release>
            release(&wait_lock);
    80002776:	0000f517          	auipc	a0,0xf
    8000277a:	b4250513          	addi	a0,a0,-1214 # 800112b8 <wait_lock>
    8000277e:	ffffe097          	auipc	ra,0xffffe
    80002782:	506080e7          	jalr	1286(ra) # 80000c84 <release>
            return -1;
    80002786:	59fd                	li	s3,-1
    80002788:	a0a1                	j	800027d0 <waitstat+0x140>
    for(np = proc; np < &proc[NPROC]; np++){
    8000278a:	18048493          	addi	s1,s1,384
    8000278e:	03348463          	beq	s1,s3,800027b6 <waitstat+0x126>
      if(np->parent == p){
    80002792:	64bc                	ld	a5,72(s1)
    80002794:	ff279be3          	bne	a5,s2,8000278a <waitstat+0xfa>
        acquire(&np->lock);
    80002798:	8526                	mv	a0,s1
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	436080e7          	jalr	1078(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    800027a2:	4c9c                	lw	a5,24(s1)
    800027a4:	f54785e3          	beq	a5,s4,800026ee <waitstat+0x5e>
        release(&np->lock);
    800027a8:	8526                	mv	a0,s1
    800027aa:	ffffe097          	auipc	ra,0xffffe
    800027ae:	4da080e7          	jalr	1242(ra) # 80000c84 <release>
        havekids = 1;
    800027b2:	8756                	mv	a4,s5
    800027b4:	bfd9                	j	8000278a <waitstat+0xfa>
    if(!havekids || p->killed){
    800027b6:	c701                	beqz	a4,800027be <waitstat+0x12e>
    800027b8:	02892783          	lw	a5,40(s2)
    800027bc:	cb8d                	beqz	a5,800027ee <waitstat+0x15e>
      release(&wait_lock);
    800027be:	0000f517          	auipc	a0,0xf
    800027c2:	afa50513          	addi	a0,a0,-1286 # 800112b8 <wait_lock>
    800027c6:	ffffe097          	auipc	ra,0xffffe
    800027ca:	4be080e7          	jalr	1214(ra) # 80000c84 <release>
      return -1;
    800027ce:	59fd                	li	s3,-1
  }
    

    800027d0:	854e                	mv	a0,s3
    800027d2:	70a6                	ld	ra,104(sp)
    800027d4:	7406                	ld	s0,96(sp)
    800027d6:	64e6                	ld	s1,88(sp)
    800027d8:	6946                	ld	s2,80(sp)
    800027da:	69a6                	ld	s3,72(sp)
    800027dc:	6a06                	ld	s4,64(sp)
    800027de:	7ae2                	ld	s5,56(sp)
    800027e0:	7b42                	ld	s6,48(sp)
    800027e2:	7ba2                	ld	s7,40(sp)
    800027e4:	7c02                	ld	s8,32(sp)
    800027e6:	6ce2                	ld	s9,24(sp)
    800027e8:	6d42                	ld	s10,16(sp)
    800027ea:	6165                	addi	sp,sp,112
    800027ec:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800027ee:	85ea                	mv	a1,s10
    800027f0:	854a                	mv	a0,s2
    800027f2:	00000097          	auipc	ra,0x0
    800027f6:	972080e7          	jalr	-1678(ra) # 80002164 <sleep>
    havekids = 0;
    800027fa:	b5e5                	j	800026e2 <waitstat+0x52>

00000000800027fc <swtch>:
    800027fc:	00153023          	sd	ra,0(a0)
    80002800:	00253423          	sd	sp,8(a0)
    80002804:	e900                	sd	s0,16(a0)
    80002806:	ed04                	sd	s1,24(a0)
    80002808:	03253023          	sd	s2,32(a0)
    8000280c:	03353423          	sd	s3,40(a0)
    80002810:	03453823          	sd	s4,48(a0)
    80002814:	03553c23          	sd	s5,56(a0)
    80002818:	05653023          	sd	s6,64(a0)
    8000281c:	05753423          	sd	s7,72(a0)
    80002820:	05853823          	sd	s8,80(a0)
    80002824:	05953c23          	sd	s9,88(a0)
    80002828:	07a53023          	sd	s10,96(a0)
    8000282c:	07b53423          	sd	s11,104(a0)
    80002830:	0005b083          	ld	ra,0(a1)
    80002834:	0085b103          	ld	sp,8(a1)
    80002838:	6980                	ld	s0,16(a1)
    8000283a:	6d84                	ld	s1,24(a1)
    8000283c:	0205b903          	ld	s2,32(a1)
    80002840:	0285b983          	ld	s3,40(a1)
    80002844:	0305ba03          	ld	s4,48(a1)
    80002848:	0385ba83          	ld	s5,56(a1)
    8000284c:	0405bb03          	ld	s6,64(a1)
    80002850:	0485bb83          	ld	s7,72(a1)
    80002854:	0505bc03          	ld	s8,80(a1)
    80002858:	0585bc83          	ld	s9,88(a1)
    8000285c:	0605bd03          	ld	s10,96(a1)
    80002860:	0685bd83          	ld	s11,104(a1)
    80002864:	8082                	ret

0000000080002866 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002866:	1141                	addi	sp,sp,-16
    80002868:	e406                	sd	ra,8(sp)
    8000286a:	e022                	sd	s0,0(sp)
    8000286c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000286e:	00006597          	auipc	a1,0x6
    80002872:	a8258593          	addi	a1,a1,-1406 # 800082f0 <states.0+0x30>
    80002876:	00015517          	auipc	a0,0x15
    8000287a:	e5a50513          	addi	a0,a0,-422 # 800176d0 <tickslock>
    8000287e:	ffffe097          	auipc	ra,0xffffe
    80002882:	2c2080e7          	jalr	706(ra) # 80000b40 <initlock>
}
    80002886:	60a2                	ld	ra,8(sp)
    80002888:	6402                	ld	s0,0(sp)
    8000288a:	0141                	addi	sp,sp,16
    8000288c:	8082                	ret

000000008000288e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000288e:	1141                	addi	sp,sp,-16
    80002890:	e422                	sd	s0,8(sp)
    80002892:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002894:	00003797          	auipc	a5,0x3
    80002898:	50c78793          	addi	a5,a5,1292 # 80005da0 <kernelvec>
    8000289c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028a0:	6422                	ld	s0,8(sp)
    800028a2:	0141                	addi	sp,sp,16
    800028a4:	8082                	ret

00000000800028a6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028a6:	1141                	addi	sp,sp,-16
    800028a8:	e406                	sd	ra,8(sp)
    800028aa:	e022                	sd	s0,0(sp)
    800028ac:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028ae:	fffff097          	auipc	ra,0xfffff
    800028b2:	0e8080e7          	jalr	232(ra) # 80001996 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028b6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028ba:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028bc:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800028c0:	00004697          	auipc	a3,0x4
    800028c4:	74068693          	addi	a3,a3,1856 # 80007000 <_trampoline>
    800028c8:	00004717          	auipc	a4,0x4
    800028cc:	73870713          	addi	a4,a4,1848 # 80007000 <_trampoline>
    800028d0:	8f15                	sub	a4,a4,a3
    800028d2:	040007b7          	lui	a5,0x4000
    800028d6:	17fd                	addi	a5,a5,-1
    800028d8:	07b2                	slli	a5,a5,0xc
    800028da:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028dc:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028e0:	7538                	ld	a4,104(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028e2:	18002673          	csrr	a2,satp
    800028e6:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028e8:	7530                	ld	a2,104(a0)
    800028ea:	6938                	ld	a4,80(a0)
    800028ec:	6585                	lui	a1,0x1
    800028ee:	972e                	add	a4,a4,a1
    800028f0:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800028f2:	7538                	ld	a4,104(a0)
    800028f4:	00000617          	auipc	a2,0x0
    800028f8:	13860613          	addi	a2,a2,312 # 80002a2c <usertrap>
    800028fc:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800028fe:	7538                	ld	a4,104(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002900:	8612                	mv	a2,tp
    80002902:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002904:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002908:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000290c:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002910:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002914:	7538                	ld	a4,104(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002916:	6f18                	ld	a4,24(a4)
    80002918:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000291c:	712c                	ld	a1,96(a0)
    8000291e:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002920:	00004717          	auipc	a4,0x4
    80002924:	77070713          	addi	a4,a4,1904 # 80007090 <userret>
    80002928:	8f15                	sub	a4,a4,a3
    8000292a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000292c:	577d                	li	a4,-1
    8000292e:	177e                	slli	a4,a4,0x3f
    80002930:	8dd9                	or	a1,a1,a4
    80002932:	02000537          	lui	a0,0x2000
    80002936:	157d                	addi	a0,a0,-1
    80002938:	0536                	slli	a0,a0,0xd
    8000293a:	9782                	jalr	a5
}
    8000293c:	60a2                	ld	ra,8(sp)
    8000293e:	6402                	ld	s0,0(sp)
    80002940:	0141                	addi	sp,sp,16
    80002942:	8082                	ret

0000000080002944 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002944:	1101                	addi	sp,sp,-32
    80002946:	ec06                	sd	ra,24(sp)
    80002948:	e822                	sd	s0,16(sp)
    8000294a:	e426                	sd	s1,8(sp)
    8000294c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000294e:	00015497          	auipc	s1,0x15
    80002952:	d8248493          	addi	s1,s1,-638 # 800176d0 <tickslock>
    80002956:	8526                	mv	a0,s1
    80002958:	ffffe097          	auipc	ra,0xffffe
    8000295c:	278080e7          	jalr	632(ra) # 80000bd0 <acquire>
  ticks++;
    80002960:	00006517          	auipc	a0,0x6
    80002964:	6d850513          	addi	a0,a0,1752 # 80009038 <ticks>
    80002968:	411c                	lw	a5,0(a0)
    8000296a:	2785                	addiw	a5,a5,1
    8000296c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000296e:	00000097          	auipc	ra,0x0
    80002972:	982080e7          	jalr	-1662(ra) # 800022f0 <wakeup>
  release(&tickslock);
    80002976:	8526                	mv	a0,s1
    80002978:	ffffe097          	auipc	ra,0xffffe
    8000297c:	30c080e7          	jalr	780(ra) # 80000c84 <release>
}
    80002980:	60e2                	ld	ra,24(sp)
    80002982:	6442                	ld	s0,16(sp)
    80002984:	64a2                	ld	s1,8(sp)
    80002986:	6105                	addi	sp,sp,32
    80002988:	8082                	ret

000000008000298a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000298a:	1101                	addi	sp,sp,-32
    8000298c:	ec06                	sd	ra,24(sp)
    8000298e:	e822                	sd	s0,16(sp)
    80002990:	e426                	sd	s1,8(sp)
    80002992:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002994:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002998:	00074d63          	bltz	a4,800029b2 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000299c:	57fd                	li	a5,-1
    8000299e:	17fe                	slli	a5,a5,0x3f
    800029a0:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800029a2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800029a4:	06f70363          	beq	a4,a5,80002a0a <devintr+0x80>
  }
}
    800029a8:	60e2                	ld	ra,24(sp)
    800029aa:	6442                	ld	s0,16(sp)
    800029ac:	64a2                	ld	s1,8(sp)
    800029ae:	6105                	addi	sp,sp,32
    800029b0:	8082                	ret
     (scause & 0xff) == 9){
    800029b2:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    800029b6:	46a5                	li	a3,9
    800029b8:	fed792e3          	bne	a5,a3,8000299c <devintr+0x12>
    int irq = plic_claim();
    800029bc:	00003097          	auipc	ra,0x3
    800029c0:	4ec080e7          	jalr	1260(ra) # 80005ea8 <plic_claim>
    800029c4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800029c6:	47a9                	li	a5,10
    800029c8:	02f50763          	beq	a0,a5,800029f6 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800029cc:	4785                	li	a5,1
    800029ce:	02f50963          	beq	a0,a5,80002a00 <devintr+0x76>
    return 1;
    800029d2:	4505                	li	a0,1
    } else if(irq){
    800029d4:	d8f1                	beqz	s1,800029a8 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800029d6:	85a6                	mv	a1,s1
    800029d8:	00006517          	auipc	a0,0x6
    800029dc:	92050513          	addi	a0,a0,-1760 # 800082f8 <states.0+0x38>
    800029e0:	ffffe097          	auipc	ra,0xffffe
    800029e4:	ba4080e7          	jalr	-1116(ra) # 80000584 <printf>
      plic_complete(irq);
    800029e8:	8526                	mv	a0,s1
    800029ea:	00003097          	auipc	ra,0x3
    800029ee:	4e2080e7          	jalr	1250(ra) # 80005ecc <plic_complete>
    return 1;
    800029f2:	4505                	li	a0,1
    800029f4:	bf55                	j	800029a8 <devintr+0x1e>
      uartintr();
    800029f6:	ffffe097          	auipc	ra,0xffffe
    800029fa:	f9c080e7          	jalr	-100(ra) # 80000992 <uartintr>
    800029fe:	b7ed                	j	800029e8 <devintr+0x5e>
      virtio_disk_intr();
    80002a00:	00004097          	auipc	ra,0x4
    80002a04:	958080e7          	jalr	-1704(ra) # 80006358 <virtio_disk_intr>
    80002a08:	b7c5                	j	800029e8 <devintr+0x5e>
    if(cpuid() == 0){
    80002a0a:	fffff097          	auipc	ra,0xfffff
    80002a0e:	f60080e7          	jalr	-160(ra) # 8000196a <cpuid>
    80002a12:	c901                	beqz	a0,80002a22 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a14:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a18:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a1a:	14479073          	csrw	sip,a5
    return 2;
    80002a1e:	4509                	li	a0,2
    80002a20:	b761                	j	800029a8 <devintr+0x1e>
      clockintr();
    80002a22:	00000097          	auipc	ra,0x0
    80002a26:	f22080e7          	jalr	-222(ra) # 80002944 <clockintr>
    80002a2a:	b7ed                	j	80002a14 <devintr+0x8a>

0000000080002a2c <usertrap>:
{
    80002a2c:	1101                	addi	sp,sp,-32
    80002a2e:	ec06                	sd	ra,24(sp)
    80002a30:	e822                	sd	s0,16(sp)
    80002a32:	e426                	sd	s1,8(sp)
    80002a34:	e04a                	sd	s2,0(sp)
    80002a36:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a38:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a3c:	1007f793          	andi	a5,a5,256
    80002a40:	e3ad                	bnez	a5,80002aa2 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a42:	00003797          	auipc	a5,0x3
    80002a46:	35e78793          	addi	a5,a5,862 # 80005da0 <kernelvec>
    80002a4a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a4e:	fffff097          	auipc	ra,0xfffff
    80002a52:	f48080e7          	jalr	-184(ra) # 80001996 <myproc>
    80002a56:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a58:	753c                	ld	a5,104(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a5a:	14102773          	csrr	a4,sepc
    80002a5e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a60:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a64:	47a1                	li	a5,8
    80002a66:	04f71c63          	bne	a4,a5,80002abe <usertrap+0x92>
    if(p->killed)
    80002a6a:	551c                	lw	a5,40(a0)
    80002a6c:	e3b9                	bnez	a5,80002ab2 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002a6e:	74b8                	ld	a4,104(s1)
    80002a70:	6f1c                	ld	a5,24(a4)
    80002a72:	0791                	addi	a5,a5,4
    80002a74:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a76:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a7a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a7e:	10079073          	csrw	sstatus,a5
    syscall();
    80002a82:	00000097          	auipc	ra,0x0
    80002a86:	2e0080e7          	jalr	736(ra) # 80002d62 <syscall>
  if(p->killed)
    80002a8a:	549c                	lw	a5,40(s1)
    80002a8c:	ebc1                	bnez	a5,80002b1c <usertrap+0xf0>
  usertrapret();
    80002a8e:	00000097          	auipc	ra,0x0
    80002a92:	e18080e7          	jalr	-488(ra) # 800028a6 <usertrapret>
}
    80002a96:	60e2                	ld	ra,24(sp)
    80002a98:	6442                	ld	s0,16(sp)
    80002a9a:	64a2                	ld	s1,8(sp)
    80002a9c:	6902                	ld	s2,0(sp)
    80002a9e:	6105                	addi	sp,sp,32
    80002aa0:	8082                	ret
    panic("usertrap: not from user mode");
    80002aa2:	00006517          	auipc	a0,0x6
    80002aa6:	87650513          	addi	a0,a0,-1930 # 80008318 <states.0+0x58>
    80002aaa:	ffffe097          	auipc	ra,0xffffe
    80002aae:	a90080e7          	jalr	-1392(ra) # 8000053a <panic>
      exit(-1);
    80002ab2:	557d                	li	a0,-1
    80002ab4:	00000097          	auipc	ra,0x0
    80002ab8:	90c080e7          	jalr	-1780(ra) # 800023c0 <exit>
    80002abc:	bf4d                	j	80002a6e <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002abe:	00000097          	auipc	ra,0x0
    80002ac2:	ecc080e7          	jalr	-308(ra) # 8000298a <devintr>
    80002ac6:	892a                	mv	s2,a0
    80002ac8:	c501                	beqz	a0,80002ad0 <usertrap+0xa4>
  if(p->killed)
    80002aca:	549c                	lw	a5,40(s1)
    80002acc:	c3a1                	beqz	a5,80002b0c <usertrap+0xe0>
    80002ace:	a815                	j	80002b02 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ad0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ad4:	5890                	lw	a2,48(s1)
    80002ad6:	00006517          	auipc	a0,0x6
    80002ada:	86250513          	addi	a0,a0,-1950 # 80008338 <states.0+0x78>
    80002ade:	ffffe097          	auipc	ra,0xffffe
    80002ae2:	aa6080e7          	jalr	-1370(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ae6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002aea:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002aee:	00006517          	auipc	a0,0x6
    80002af2:	87a50513          	addi	a0,a0,-1926 # 80008368 <states.0+0xa8>
    80002af6:	ffffe097          	auipc	ra,0xffffe
    80002afa:	a8e080e7          	jalr	-1394(ra) # 80000584 <printf>
    p->killed = 1;
    80002afe:	4785                	li	a5,1
    80002b00:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002b02:	557d                	li	a0,-1
    80002b04:	00000097          	auipc	ra,0x0
    80002b08:	8bc080e7          	jalr	-1860(ra) # 800023c0 <exit>
  if(which_dev == 2)
    80002b0c:	4789                	li	a5,2
    80002b0e:	f8f910e3          	bne	s2,a5,80002a8e <usertrap+0x62>
    yield();
    80002b12:	fffff097          	auipc	ra,0xfffff
    80002b16:	616080e7          	jalr	1558(ra) # 80002128 <yield>
    80002b1a:	bf95                	j	80002a8e <usertrap+0x62>
  int which_dev = 0;
    80002b1c:	4901                	li	s2,0
    80002b1e:	b7d5                	j	80002b02 <usertrap+0xd6>

0000000080002b20 <kerneltrap>:
{
    80002b20:	7179                	addi	sp,sp,-48
    80002b22:	f406                	sd	ra,40(sp)
    80002b24:	f022                	sd	s0,32(sp)
    80002b26:	ec26                	sd	s1,24(sp)
    80002b28:	e84a                	sd	s2,16(sp)
    80002b2a:	e44e                	sd	s3,8(sp)
    80002b2c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b2e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b32:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b36:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b3a:	1004f793          	andi	a5,s1,256
    80002b3e:	cb85                	beqz	a5,80002b6e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b40:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b44:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b46:	ef85                	bnez	a5,80002b7e <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002b48:	00000097          	auipc	ra,0x0
    80002b4c:	e42080e7          	jalr	-446(ra) # 8000298a <devintr>
    80002b50:	cd1d                	beqz	a0,80002b8e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b52:	4789                	li	a5,2
    80002b54:	06f50a63          	beq	a0,a5,80002bc8 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b58:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b5c:	10049073          	csrw	sstatus,s1
}
    80002b60:	70a2                	ld	ra,40(sp)
    80002b62:	7402                	ld	s0,32(sp)
    80002b64:	64e2                	ld	s1,24(sp)
    80002b66:	6942                	ld	s2,16(sp)
    80002b68:	69a2                	ld	s3,8(sp)
    80002b6a:	6145                	addi	sp,sp,48
    80002b6c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b6e:	00006517          	auipc	a0,0x6
    80002b72:	81a50513          	addi	a0,a0,-2022 # 80008388 <states.0+0xc8>
    80002b76:	ffffe097          	auipc	ra,0xffffe
    80002b7a:	9c4080e7          	jalr	-1596(ra) # 8000053a <panic>
    panic("kerneltrap: interrupts enabled");
    80002b7e:	00006517          	auipc	a0,0x6
    80002b82:	83250513          	addi	a0,a0,-1998 # 800083b0 <states.0+0xf0>
    80002b86:	ffffe097          	auipc	ra,0xffffe
    80002b8a:	9b4080e7          	jalr	-1612(ra) # 8000053a <panic>
    printf("scause %p\n", scause);
    80002b8e:	85ce                	mv	a1,s3
    80002b90:	00006517          	auipc	a0,0x6
    80002b94:	84050513          	addi	a0,a0,-1984 # 800083d0 <states.0+0x110>
    80002b98:	ffffe097          	auipc	ra,0xffffe
    80002b9c:	9ec080e7          	jalr	-1556(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ba0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ba4:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ba8:	00006517          	auipc	a0,0x6
    80002bac:	83850513          	addi	a0,a0,-1992 # 800083e0 <states.0+0x120>
    80002bb0:	ffffe097          	auipc	ra,0xffffe
    80002bb4:	9d4080e7          	jalr	-1580(ra) # 80000584 <printf>
    panic("kerneltrap");
    80002bb8:	00006517          	auipc	a0,0x6
    80002bbc:	84050513          	addi	a0,a0,-1984 # 800083f8 <states.0+0x138>
    80002bc0:	ffffe097          	auipc	ra,0xffffe
    80002bc4:	97a080e7          	jalr	-1670(ra) # 8000053a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bc8:	fffff097          	auipc	ra,0xfffff
    80002bcc:	dce080e7          	jalr	-562(ra) # 80001996 <myproc>
    80002bd0:	d541                	beqz	a0,80002b58 <kerneltrap+0x38>
    80002bd2:	fffff097          	auipc	ra,0xfffff
    80002bd6:	dc4080e7          	jalr	-572(ra) # 80001996 <myproc>
    80002bda:	4d18                	lw	a4,24(a0)
    80002bdc:	4791                	li	a5,4
    80002bde:	f6f71de3          	bne	a4,a5,80002b58 <kerneltrap+0x38>
    yield();
    80002be2:	fffff097          	auipc	ra,0xfffff
    80002be6:	546080e7          	jalr	1350(ra) # 80002128 <yield>
    80002bea:	b7bd                	j	80002b58 <kerneltrap+0x38>

0000000080002bec <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002bec:	1101                	addi	sp,sp,-32
    80002bee:	ec06                	sd	ra,24(sp)
    80002bf0:	e822                	sd	s0,16(sp)
    80002bf2:	e426                	sd	s1,8(sp)
    80002bf4:	1000                	addi	s0,sp,32
    80002bf6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002bf8:	fffff097          	auipc	ra,0xfffff
    80002bfc:	d9e080e7          	jalr	-610(ra) # 80001996 <myproc>
  switch (n) {
    80002c00:	4795                	li	a5,5
    80002c02:	0497e163          	bltu	a5,s1,80002c44 <argraw+0x58>
    80002c06:	048a                	slli	s1,s1,0x2
    80002c08:	00006717          	auipc	a4,0x6
    80002c0c:	82870713          	addi	a4,a4,-2008 # 80008430 <states.0+0x170>
    80002c10:	94ba                	add	s1,s1,a4
    80002c12:	409c                	lw	a5,0(s1)
    80002c14:	97ba                	add	a5,a5,a4
    80002c16:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c18:	753c                	ld	a5,104(a0)
    80002c1a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c1c:	60e2                	ld	ra,24(sp)
    80002c1e:	6442                	ld	s0,16(sp)
    80002c20:	64a2                	ld	s1,8(sp)
    80002c22:	6105                	addi	sp,sp,32
    80002c24:	8082                	ret
    return p->trapframe->a1;
    80002c26:	753c                	ld	a5,104(a0)
    80002c28:	7fa8                	ld	a0,120(a5)
    80002c2a:	bfcd                	j	80002c1c <argraw+0x30>
    return p->trapframe->a2;
    80002c2c:	753c                	ld	a5,104(a0)
    80002c2e:	63c8                	ld	a0,128(a5)
    80002c30:	b7f5                	j	80002c1c <argraw+0x30>
    return p->trapframe->a3;
    80002c32:	753c                	ld	a5,104(a0)
    80002c34:	67c8                	ld	a0,136(a5)
    80002c36:	b7dd                	j	80002c1c <argraw+0x30>
    return p->trapframe->a4;
    80002c38:	753c                	ld	a5,104(a0)
    80002c3a:	6bc8                	ld	a0,144(a5)
    80002c3c:	b7c5                	j	80002c1c <argraw+0x30>
    return p->trapframe->a5;
    80002c3e:	753c                	ld	a5,104(a0)
    80002c40:	6fc8                	ld	a0,152(a5)
    80002c42:	bfe9                	j	80002c1c <argraw+0x30>
  panic("argraw");
    80002c44:	00005517          	auipc	a0,0x5
    80002c48:	7c450513          	addi	a0,a0,1988 # 80008408 <states.0+0x148>
    80002c4c:	ffffe097          	auipc	ra,0xffffe
    80002c50:	8ee080e7          	jalr	-1810(ra) # 8000053a <panic>

0000000080002c54 <fetchaddr>:
{
    80002c54:	1101                	addi	sp,sp,-32
    80002c56:	ec06                	sd	ra,24(sp)
    80002c58:	e822                	sd	s0,16(sp)
    80002c5a:	e426                	sd	s1,8(sp)
    80002c5c:	e04a                	sd	s2,0(sp)
    80002c5e:	1000                	addi	s0,sp,32
    80002c60:	84aa                	mv	s1,a0
    80002c62:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c64:	fffff097          	auipc	ra,0xfffff
    80002c68:	d32080e7          	jalr	-718(ra) # 80001996 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002c6c:	6d3c                	ld	a5,88(a0)
    80002c6e:	02f4f863          	bgeu	s1,a5,80002c9e <fetchaddr+0x4a>
    80002c72:	00848713          	addi	a4,s1,8
    80002c76:	02e7e663          	bltu	a5,a4,80002ca2 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c7a:	46a1                	li	a3,8
    80002c7c:	8626                	mv	a2,s1
    80002c7e:	85ca                	mv	a1,s2
    80002c80:	7128                	ld	a0,96(a0)
    80002c82:	fffff097          	auipc	ra,0xfffff
    80002c86:	a64080e7          	jalr	-1436(ra) # 800016e6 <copyin>
    80002c8a:	00a03533          	snez	a0,a0
    80002c8e:	40a00533          	neg	a0,a0
}
    80002c92:	60e2                	ld	ra,24(sp)
    80002c94:	6442                	ld	s0,16(sp)
    80002c96:	64a2                	ld	s1,8(sp)
    80002c98:	6902                	ld	s2,0(sp)
    80002c9a:	6105                	addi	sp,sp,32
    80002c9c:	8082                	ret
    return -1;
    80002c9e:	557d                	li	a0,-1
    80002ca0:	bfcd                	j	80002c92 <fetchaddr+0x3e>
    80002ca2:	557d                	li	a0,-1
    80002ca4:	b7fd                	j	80002c92 <fetchaddr+0x3e>

0000000080002ca6 <fetchstr>:
{
    80002ca6:	7179                	addi	sp,sp,-48
    80002ca8:	f406                	sd	ra,40(sp)
    80002caa:	f022                	sd	s0,32(sp)
    80002cac:	ec26                	sd	s1,24(sp)
    80002cae:	e84a                	sd	s2,16(sp)
    80002cb0:	e44e                	sd	s3,8(sp)
    80002cb2:	1800                	addi	s0,sp,48
    80002cb4:	892a                	mv	s2,a0
    80002cb6:	84ae                	mv	s1,a1
    80002cb8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002cba:	fffff097          	auipc	ra,0xfffff
    80002cbe:	cdc080e7          	jalr	-804(ra) # 80001996 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002cc2:	86ce                	mv	a3,s3
    80002cc4:	864a                	mv	a2,s2
    80002cc6:	85a6                	mv	a1,s1
    80002cc8:	7128                	ld	a0,96(a0)
    80002cca:	fffff097          	auipc	ra,0xfffff
    80002cce:	aaa080e7          	jalr	-1366(ra) # 80001774 <copyinstr>
  if(err < 0)
    80002cd2:	00054763          	bltz	a0,80002ce0 <fetchstr+0x3a>
  return strlen(buf);
    80002cd6:	8526                	mv	a0,s1
    80002cd8:	ffffe097          	auipc	ra,0xffffe
    80002cdc:	170080e7          	jalr	368(ra) # 80000e48 <strlen>
}
    80002ce0:	70a2                	ld	ra,40(sp)
    80002ce2:	7402                	ld	s0,32(sp)
    80002ce4:	64e2                	ld	s1,24(sp)
    80002ce6:	6942                	ld	s2,16(sp)
    80002ce8:	69a2                	ld	s3,8(sp)
    80002cea:	6145                	addi	sp,sp,48
    80002cec:	8082                	ret

0000000080002cee <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002cee:	1101                	addi	sp,sp,-32
    80002cf0:	ec06                	sd	ra,24(sp)
    80002cf2:	e822                	sd	s0,16(sp)
    80002cf4:	e426                	sd	s1,8(sp)
    80002cf6:	1000                	addi	s0,sp,32
    80002cf8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cfa:	00000097          	auipc	ra,0x0
    80002cfe:	ef2080e7          	jalr	-270(ra) # 80002bec <argraw>
    80002d02:	c088                	sw	a0,0(s1)
  return 0;
}
    80002d04:	4501                	li	a0,0
    80002d06:	60e2                	ld	ra,24(sp)
    80002d08:	6442                	ld	s0,16(sp)
    80002d0a:	64a2                	ld	s1,8(sp)
    80002d0c:	6105                	addi	sp,sp,32
    80002d0e:	8082                	ret

0000000080002d10 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002d10:	1101                	addi	sp,sp,-32
    80002d12:	ec06                	sd	ra,24(sp)
    80002d14:	e822                	sd	s0,16(sp)
    80002d16:	e426                	sd	s1,8(sp)
    80002d18:	1000                	addi	s0,sp,32
    80002d1a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d1c:	00000097          	auipc	ra,0x0
    80002d20:	ed0080e7          	jalr	-304(ra) # 80002bec <argraw>
    80002d24:	e088                	sd	a0,0(s1)
  return 0;
}
    80002d26:	4501                	li	a0,0
    80002d28:	60e2                	ld	ra,24(sp)
    80002d2a:	6442                	ld	s0,16(sp)
    80002d2c:	64a2                	ld	s1,8(sp)
    80002d2e:	6105                	addi	sp,sp,32
    80002d30:	8082                	ret

0000000080002d32 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d32:	1101                	addi	sp,sp,-32
    80002d34:	ec06                	sd	ra,24(sp)
    80002d36:	e822                	sd	s0,16(sp)
    80002d38:	e426                	sd	s1,8(sp)
    80002d3a:	e04a                	sd	s2,0(sp)
    80002d3c:	1000                	addi	s0,sp,32
    80002d3e:	84ae                	mv	s1,a1
    80002d40:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002d42:	00000097          	auipc	ra,0x0
    80002d46:	eaa080e7          	jalr	-342(ra) # 80002bec <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002d4a:	864a                	mv	a2,s2
    80002d4c:	85a6                	mv	a1,s1
    80002d4e:	00000097          	auipc	ra,0x0
    80002d52:	f58080e7          	jalr	-168(ra) # 80002ca6 <fetchstr>
}
    80002d56:	60e2                	ld	ra,24(sp)
    80002d58:	6442                	ld	s0,16(sp)
    80002d5a:	64a2                	ld	s1,8(sp)
    80002d5c:	6902                	ld	s2,0(sp)
    80002d5e:	6105                	addi	sp,sp,32
    80002d60:	8082                	ret

0000000080002d62 <syscall>:
[SYS_waitstat] sys_waitstat,
};

void
syscall(void)
{
    80002d62:	1101                	addi	sp,sp,-32
    80002d64:	ec06                	sd	ra,24(sp)
    80002d66:	e822                	sd	s0,16(sp)
    80002d68:	e426                	sd	s1,8(sp)
    80002d6a:	e04a                	sd	s2,0(sp)
    80002d6c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d6e:	fffff097          	auipc	ra,0xfffff
    80002d72:	c28080e7          	jalr	-984(ra) # 80001996 <myproc>
    80002d76:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d78:	06853903          	ld	s2,104(a0)
    80002d7c:	0a893783          	ld	a5,168(s2)
    80002d80:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d84:	37fd                	addiw	a5,a5,-1
    80002d86:	4755                	li	a4,21
    80002d88:	00f76f63          	bltu	a4,a5,80002da6 <syscall+0x44>
    80002d8c:	00369713          	slli	a4,a3,0x3
    80002d90:	00005797          	auipc	a5,0x5
    80002d94:	6b878793          	addi	a5,a5,1720 # 80008448 <syscalls>
    80002d98:	97ba                	add	a5,a5,a4
    80002d9a:	639c                	ld	a5,0(a5)
    80002d9c:	c789                	beqz	a5,80002da6 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002d9e:	9782                	jalr	a5
    80002da0:	06a93823          	sd	a0,112(s2)
    80002da4:	a839                	j	80002dc2 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002da6:	16848613          	addi	a2,s1,360
    80002daa:	588c                	lw	a1,48(s1)
    80002dac:	00005517          	auipc	a0,0x5
    80002db0:	66450513          	addi	a0,a0,1636 # 80008410 <states.0+0x150>
    80002db4:	ffffd097          	auipc	ra,0xffffd
    80002db8:	7d0080e7          	jalr	2000(ra) # 80000584 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002dbc:	74bc                	ld	a5,104(s1)
    80002dbe:	577d                	li	a4,-1
    80002dc0:	fbb8                	sd	a4,112(a5)
  }
}
    80002dc2:	60e2                	ld	ra,24(sp)
    80002dc4:	6442                	ld	s0,16(sp)
    80002dc6:	64a2                	ld	s1,8(sp)
    80002dc8:	6902                	ld	s2,0(sp)
    80002dca:	6105                	addi	sp,sp,32
    80002dcc:	8082                	ret

0000000080002dce <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002dce:	1101                	addi	sp,sp,-32
    80002dd0:	ec06                	sd	ra,24(sp)
    80002dd2:	e822                	sd	s0,16(sp)
    80002dd4:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002dd6:	fec40593          	addi	a1,s0,-20
    80002dda:	4501                	li	a0,0
    80002ddc:	00000097          	auipc	ra,0x0
    80002de0:	f12080e7          	jalr	-238(ra) # 80002cee <argint>
    return -1;
    80002de4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002de6:	00054963          	bltz	a0,80002df8 <sys_exit+0x2a>
  exit(n);
    80002dea:	fec42503          	lw	a0,-20(s0)
    80002dee:	fffff097          	auipc	ra,0xfffff
    80002df2:	5d2080e7          	jalr	1490(ra) # 800023c0 <exit>
  return 0;  // not reached
    80002df6:	4781                	li	a5,0
}
    80002df8:	853e                	mv	a0,a5
    80002dfa:	60e2                	ld	ra,24(sp)
    80002dfc:	6442                	ld	s0,16(sp)
    80002dfe:	6105                	addi	sp,sp,32
    80002e00:	8082                	ret

0000000080002e02 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e02:	1141                	addi	sp,sp,-16
    80002e04:	e406                	sd	ra,8(sp)
    80002e06:	e022                	sd	s0,0(sp)
    80002e08:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e0a:	fffff097          	auipc	ra,0xfffff
    80002e0e:	b8c080e7          	jalr	-1140(ra) # 80001996 <myproc>
}
    80002e12:	5908                	lw	a0,48(a0)
    80002e14:	60a2                	ld	ra,8(sp)
    80002e16:	6402                	ld	s0,0(sp)
    80002e18:	0141                	addi	sp,sp,16
    80002e1a:	8082                	ret

0000000080002e1c <sys_fork>:

uint64
sys_fork(void)
{
    80002e1c:	1141                	addi	sp,sp,-16
    80002e1e:	e406                	sd	ra,8(sp)
    80002e20:	e022                	sd	s0,0(sp)
    80002e22:	0800                	addi	s0,sp,16
  return fork();
    80002e24:	fffff097          	auipc	ra,0xfffff
    80002e28:	f7a080e7          	jalr	-134(ra) # 80001d9e <fork>
}
    80002e2c:	60a2                	ld	ra,8(sp)
    80002e2e:	6402                	ld	s0,0(sp)
    80002e30:	0141                	addi	sp,sp,16
    80002e32:	8082                	ret

0000000080002e34 <sys_wait>:

uint64
sys_wait(void)
{
    80002e34:	1101                	addi	sp,sp,-32
    80002e36:	ec06                	sd	ra,24(sp)
    80002e38:	e822                	sd	s0,16(sp)
    80002e3a:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002e3c:	fe840593          	addi	a1,s0,-24
    80002e40:	4501                	li	a0,0
    80002e42:	00000097          	auipc	ra,0x0
    80002e46:	ece080e7          	jalr	-306(ra) # 80002d10 <argaddr>
    80002e4a:	87aa                	mv	a5,a0
    return -1;
    80002e4c:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002e4e:	0007c863          	bltz	a5,80002e5e <sys_wait+0x2a>
  return wait(p);
    80002e52:	fe843503          	ld	a0,-24(s0)
    80002e56:	fffff097          	auipc	ra,0xfffff
    80002e5a:	372080e7          	jalr	882(ra) # 800021c8 <wait>
}
    80002e5e:	60e2                	ld	ra,24(sp)
    80002e60:	6442                	ld	s0,16(sp)
    80002e62:	6105                	addi	sp,sp,32
    80002e64:	8082                	ret

0000000080002e66 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e66:	7179                	addi	sp,sp,-48
    80002e68:	f406                	sd	ra,40(sp)
    80002e6a:	f022                	sd	s0,32(sp)
    80002e6c:	ec26                	sd	s1,24(sp)
    80002e6e:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002e70:	fdc40593          	addi	a1,s0,-36
    80002e74:	4501                	li	a0,0
    80002e76:	00000097          	auipc	ra,0x0
    80002e7a:	e78080e7          	jalr	-392(ra) # 80002cee <argint>
    80002e7e:	87aa                	mv	a5,a0
    return -1;
    80002e80:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002e82:	0207c063          	bltz	a5,80002ea2 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002e86:	fffff097          	auipc	ra,0xfffff
    80002e8a:	b10080e7          	jalr	-1264(ra) # 80001996 <myproc>
    80002e8e:	4d24                	lw	s1,88(a0)
  if(growproc(n) < 0)
    80002e90:	fdc42503          	lw	a0,-36(s0)
    80002e94:	fffff097          	auipc	ra,0xfffff
    80002e98:	e92080e7          	jalr	-366(ra) # 80001d26 <growproc>
    80002e9c:	00054863          	bltz	a0,80002eac <sys_sbrk+0x46>
    return -1;
  return addr;
    80002ea0:	8526                	mv	a0,s1
}
    80002ea2:	70a2                	ld	ra,40(sp)
    80002ea4:	7402                	ld	s0,32(sp)
    80002ea6:	64e2                	ld	s1,24(sp)
    80002ea8:	6145                	addi	sp,sp,48
    80002eaa:	8082                	ret
    return -1;
    80002eac:	557d                	li	a0,-1
    80002eae:	bfd5                	j	80002ea2 <sys_sbrk+0x3c>

0000000080002eb0 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002eb0:	7139                	addi	sp,sp,-64
    80002eb2:	fc06                	sd	ra,56(sp)
    80002eb4:	f822                	sd	s0,48(sp)
    80002eb6:	f426                	sd	s1,40(sp)
    80002eb8:	f04a                	sd	s2,32(sp)
    80002eba:	ec4e                	sd	s3,24(sp)
    80002ebc:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002ebe:	fcc40593          	addi	a1,s0,-52
    80002ec2:	4501                	li	a0,0
    80002ec4:	00000097          	auipc	ra,0x0
    80002ec8:	e2a080e7          	jalr	-470(ra) # 80002cee <argint>
    return -1;
    80002ecc:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ece:	06054563          	bltz	a0,80002f38 <sys_sleep+0x88>
  acquire(&tickslock);
    80002ed2:	00014517          	auipc	a0,0x14
    80002ed6:	7fe50513          	addi	a0,a0,2046 # 800176d0 <tickslock>
    80002eda:	ffffe097          	auipc	ra,0xffffe
    80002ede:	cf6080e7          	jalr	-778(ra) # 80000bd0 <acquire>
  ticks0 = ticks;
    80002ee2:	00006917          	auipc	s2,0x6
    80002ee6:	15692903          	lw	s2,342(s2) # 80009038 <ticks>
  while(ticks - ticks0 < n){
    80002eea:	fcc42783          	lw	a5,-52(s0)
    80002eee:	cf85                	beqz	a5,80002f26 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ef0:	00014997          	auipc	s3,0x14
    80002ef4:	7e098993          	addi	s3,s3,2016 # 800176d0 <tickslock>
    80002ef8:	00006497          	auipc	s1,0x6
    80002efc:	14048493          	addi	s1,s1,320 # 80009038 <ticks>
    if(myproc()->killed){
    80002f00:	fffff097          	auipc	ra,0xfffff
    80002f04:	a96080e7          	jalr	-1386(ra) # 80001996 <myproc>
    80002f08:	551c                	lw	a5,40(a0)
    80002f0a:	ef9d                	bnez	a5,80002f48 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002f0c:	85ce                	mv	a1,s3
    80002f0e:	8526                	mv	a0,s1
    80002f10:	fffff097          	auipc	ra,0xfffff
    80002f14:	254080e7          	jalr	596(ra) # 80002164 <sleep>
  while(ticks - ticks0 < n){
    80002f18:	409c                	lw	a5,0(s1)
    80002f1a:	412787bb          	subw	a5,a5,s2
    80002f1e:	fcc42703          	lw	a4,-52(s0)
    80002f22:	fce7efe3          	bltu	a5,a4,80002f00 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002f26:	00014517          	auipc	a0,0x14
    80002f2a:	7aa50513          	addi	a0,a0,1962 # 800176d0 <tickslock>
    80002f2e:	ffffe097          	auipc	ra,0xffffe
    80002f32:	d56080e7          	jalr	-682(ra) # 80000c84 <release>
  return 0;
    80002f36:	4781                	li	a5,0
}
    80002f38:	853e                	mv	a0,a5
    80002f3a:	70e2                	ld	ra,56(sp)
    80002f3c:	7442                	ld	s0,48(sp)
    80002f3e:	74a2                	ld	s1,40(sp)
    80002f40:	7902                	ld	s2,32(sp)
    80002f42:	69e2                	ld	s3,24(sp)
    80002f44:	6121                	addi	sp,sp,64
    80002f46:	8082                	ret
      release(&tickslock);
    80002f48:	00014517          	auipc	a0,0x14
    80002f4c:	78850513          	addi	a0,a0,1928 # 800176d0 <tickslock>
    80002f50:	ffffe097          	auipc	ra,0xffffe
    80002f54:	d34080e7          	jalr	-716(ra) # 80000c84 <release>
      return -1;
    80002f58:	57fd                	li	a5,-1
    80002f5a:	bff9                	j	80002f38 <sys_sleep+0x88>

0000000080002f5c <sys_kill>:

uint64
sys_kill(void)
{
    80002f5c:	1101                	addi	sp,sp,-32
    80002f5e:	ec06                	sd	ra,24(sp)
    80002f60:	e822                	sd	s0,16(sp)
    80002f62:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002f64:	fec40593          	addi	a1,s0,-20
    80002f68:	4501                	li	a0,0
    80002f6a:	00000097          	auipc	ra,0x0
    80002f6e:	d84080e7          	jalr	-636(ra) # 80002cee <argint>
    80002f72:	87aa                	mv	a5,a0
    return -1;
    80002f74:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002f76:	0007c863          	bltz	a5,80002f86 <sys_kill+0x2a>
  return kill(pid);
    80002f7a:	fec42503          	lw	a0,-20(s0)
    80002f7e:	fffff097          	auipc	ra,0xfffff
    80002f82:	544080e7          	jalr	1348(ra) # 800024c2 <kill>
}
    80002f86:	60e2                	ld	ra,24(sp)
    80002f88:	6442                	ld	s0,16(sp)
    80002f8a:	6105                	addi	sp,sp,32
    80002f8c:	8082                	ret

0000000080002f8e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f8e:	1101                	addi	sp,sp,-32
    80002f90:	ec06                	sd	ra,24(sp)
    80002f92:	e822                	sd	s0,16(sp)
    80002f94:	e426                	sd	s1,8(sp)
    80002f96:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f98:	00014517          	auipc	a0,0x14
    80002f9c:	73850513          	addi	a0,a0,1848 # 800176d0 <tickslock>
    80002fa0:	ffffe097          	auipc	ra,0xffffe
    80002fa4:	c30080e7          	jalr	-976(ra) # 80000bd0 <acquire>
  xticks = ticks;
    80002fa8:	00006497          	auipc	s1,0x6
    80002fac:	0904a483          	lw	s1,144(s1) # 80009038 <ticks>
  release(&tickslock);
    80002fb0:	00014517          	auipc	a0,0x14
    80002fb4:	72050513          	addi	a0,a0,1824 # 800176d0 <tickslock>
    80002fb8:	ffffe097          	auipc	ra,0xffffe
    80002fbc:	ccc080e7          	jalr	-820(ra) # 80000c84 <release>
  return xticks;
}
    80002fc0:	02049513          	slli	a0,s1,0x20
    80002fc4:	9101                	srli	a0,a0,0x20
    80002fc6:	60e2                	ld	ra,24(sp)
    80002fc8:	6442                	ld	s0,16(sp)
    80002fca:	64a2                	ld	s1,8(sp)
    80002fcc:	6105                	addi	sp,sp,32
    80002fce:	8082                	ret

0000000080002fd0 <sys_waitstat>:



uint64
sys_waitstat(void){
    80002fd0:	7179                	addi	sp,sp,-48
    80002fd2:	f406                	sd	ra,40(sp)
    80002fd4:	f022                	sd	s0,32(sp)
    80002fd6:	1800                	addi	s0,sp,48
  

 // printf("reached waitsys TT: %d", *turnaroundTime);
  
  
  if(argaddr(0, &p) < 0)
    80002fd8:	fe840593          	addi	a1,s0,-24
    80002fdc:	4501                	li	a0,0
    80002fde:	00000097          	auipc	ra,0x0
    80002fe2:	d32080e7          	jalr	-718(ra) # 80002d10 <argaddr>
    return -1;
    80002fe6:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    80002fe8:	04054163          	bltz	a0,8000302a <sys_waitstat+0x5a>
  // printf("A\n");
  if(argaddr(1,&turnaroundTime)<0)
    80002fec:	fe040593          	addi	a1,s0,-32
    80002ff0:	4505                	li	a0,1
    80002ff2:	00000097          	auipc	ra,0x0
    80002ff6:	d1e080e7          	jalr	-738(ra) # 80002d10 <argaddr>
     return -1;
    80002ffa:	57fd                	li	a5,-1
  if(argaddr(1,&turnaroundTime)<0)
    80002ffc:	02054763          	bltz	a0,8000302a <sys_waitstat+0x5a>
  // printf("B\n");
  if(argaddr(2,&runningTime)<0)
    80003000:	fd840593          	addi	a1,s0,-40
    80003004:	4509                	li	a0,2
    80003006:	00000097          	auipc	ra,0x0
    8000300a:	d0a080e7          	jalr	-758(ra) # 80002d10 <argaddr>
     return -1;
    8000300e:	57fd                	li	a5,-1
  if(argaddr(2,&runningTime)<0)
    80003010:	00054d63          	bltz	a0,8000302a <sys_waitstat+0x5a>
  // printf("C\n");
  return waitstat(p,turnaroundTime,runningTime);
    80003014:	fd843603          	ld	a2,-40(s0)
    80003018:	fe043583          	ld	a1,-32(s0)
    8000301c:	fe843503          	ld	a0,-24(s0)
    80003020:	fffff097          	auipc	ra,0xfffff
    80003024:	670080e7          	jalr	1648(ra) # 80002690 <waitstat>
    80003028:	87aa                	mv	a5,a0
  // return 33;

}
    8000302a:	853e                	mv	a0,a5
    8000302c:	70a2                	ld	ra,40(sp)
    8000302e:	7402                	ld	s0,32(sp)
    80003030:	6145                	addi	sp,sp,48
    80003032:	8082                	ret

0000000080003034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003034:	7179                	addi	sp,sp,-48
    80003036:	f406                	sd	ra,40(sp)
    80003038:	f022                	sd	s0,32(sp)
    8000303a:	ec26                	sd	s1,24(sp)
    8000303c:	e84a                	sd	s2,16(sp)
    8000303e:	e44e                	sd	s3,8(sp)
    80003040:	e052                	sd	s4,0(sp)
    80003042:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003044:	00005597          	auipc	a1,0x5
    80003048:	4bc58593          	addi	a1,a1,1212 # 80008500 <syscalls+0xb8>
    8000304c:	00014517          	auipc	a0,0x14
    80003050:	69c50513          	addi	a0,a0,1692 # 800176e8 <bcache>
    80003054:	ffffe097          	auipc	ra,0xffffe
    80003058:	aec080e7          	jalr	-1300(ra) # 80000b40 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000305c:	0001c797          	auipc	a5,0x1c
    80003060:	68c78793          	addi	a5,a5,1676 # 8001f6e8 <bcache+0x8000>
    80003064:	0001d717          	auipc	a4,0x1d
    80003068:	8ec70713          	addi	a4,a4,-1812 # 8001f950 <bcache+0x8268>
    8000306c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003070:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003074:	00014497          	auipc	s1,0x14
    80003078:	68c48493          	addi	s1,s1,1676 # 80017700 <bcache+0x18>
    b->next = bcache.head.next;
    8000307c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000307e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003080:	00005a17          	auipc	s4,0x5
    80003084:	488a0a13          	addi	s4,s4,1160 # 80008508 <syscalls+0xc0>
    b->next = bcache.head.next;
    80003088:	2b893783          	ld	a5,696(s2)
    8000308c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000308e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003092:	85d2                	mv	a1,s4
    80003094:	01048513          	addi	a0,s1,16
    80003098:	00001097          	auipc	ra,0x1
    8000309c:	4c2080e7          	jalr	1218(ra) # 8000455a <initsleeplock>
    bcache.head.next->prev = b;
    800030a0:	2b893783          	ld	a5,696(s2)
    800030a4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030a6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030aa:	45848493          	addi	s1,s1,1112
    800030ae:	fd349de3          	bne	s1,s3,80003088 <binit+0x54>
  }
}
    800030b2:	70a2                	ld	ra,40(sp)
    800030b4:	7402                	ld	s0,32(sp)
    800030b6:	64e2                	ld	s1,24(sp)
    800030b8:	6942                	ld	s2,16(sp)
    800030ba:	69a2                	ld	s3,8(sp)
    800030bc:	6a02                	ld	s4,0(sp)
    800030be:	6145                	addi	sp,sp,48
    800030c0:	8082                	ret

00000000800030c2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030c2:	7179                	addi	sp,sp,-48
    800030c4:	f406                	sd	ra,40(sp)
    800030c6:	f022                	sd	s0,32(sp)
    800030c8:	ec26                	sd	s1,24(sp)
    800030ca:	e84a                	sd	s2,16(sp)
    800030cc:	e44e                	sd	s3,8(sp)
    800030ce:	1800                	addi	s0,sp,48
    800030d0:	892a                	mv	s2,a0
    800030d2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800030d4:	00014517          	auipc	a0,0x14
    800030d8:	61450513          	addi	a0,a0,1556 # 800176e8 <bcache>
    800030dc:	ffffe097          	auipc	ra,0xffffe
    800030e0:	af4080e7          	jalr	-1292(ra) # 80000bd0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800030e4:	0001d497          	auipc	s1,0x1d
    800030e8:	8bc4b483          	ld	s1,-1860(s1) # 8001f9a0 <bcache+0x82b8>
    800030ec:	0001d797          	auipc	a5,0x1d
    800030f0:	86478793          	addi	a5,a5,-1948 # 8001f950 <bcache+0x8268>
    800030f4:	02f48f63          	beq	s1,a5,80003132 <bread+0x70>
    800030f8:	873e                	mv	a4,a5
    800030fa:	a021                	j	80003102 <bread+0x40>
    800030fc:	68a4                	ld	s1,80(s1)
    800030fe:	02e48a63          	beq	s1,a4,80003132 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003102:	449c                	lw	a5,8(s1)
    80003104:	ff279ce3          	bne	a5,s2,800030fc <bread+0x3a>
    80003108:	44dc                	lw	a5,12(s1)
    8000310a:	ff3799e3          	bne	a5,s3,800030fc <bread+0x3a>
      b->refcnt++;
    8000310e:	40bc                	lw	a5,64(s1)
    80003110:	2785                	addiw	a5,a5,1
    80003112:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003114:	00014517          	auipc	a0,0x14
    80003118:	5d450513          	addi	a0,a0,1492 # 800176e8 <bcache>
    8000311c:	ffffe097          	auipc	ra,0xffffe
    80003120:	b68080e7          	jalr	-1176(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80003124:	01048513          	addi	a0,s1,16
    80003128:	00001097          	auipc	ra,0x1
    8000312c:	46c080e7          	jalr	1132(ra) # 80004594 <acquiresleep>
      return b;
    80003130:	a8b9                	j	8000318e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003132:	0001d497          	auipc	s1,0x1d
    80003136:	8664b483          	ld	s1,-1946(s1) # 8001f998 <bcache+0x82b0>
    8000313a:	0001d797          	auipc	a5,0x1d
    8000313e:	81678793          	addi	a5,a5,-2026 # 8001f950 <bcache+0x8268>
    80003142:	00f48863          	beq	s1,a5,80003152 <bread+0x90>
    80003146:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003148:	40bc                	lw	a5,64(s1)
    8000314a:	cf81                	beqz	a5,80003162 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000314c:	64a4                	ld	s1,72(s1)
    8000314e:	fee49de3          	bne	s1,a4,80003148 <bread+0x86>
  panic("bget: no buffers");
    80003152:	00005517          	auipc	a0,0x5
    80003156:	3be50513          	addi	a0,a0,958 # 80008510 <syscalls+0xc8>
    8000315a:	ffffd097          	auipc	ra,0xffffd
    8000315e:	3e0080e7          	jalr	992(ra) # 8000053a <panic>
      b->dev = dev;
    80003162:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003166:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000316a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000316e:	4785                	li	a5,1
    80003170:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003172:	00014517          	auipc	a0,0x14
    80003176:	57650513          	addi	a0,a0,1398 # 800176e8 <bcache>
    8000317a:	ffffe097          	auipc	ra,0xffffe
    8000317e:	b0a080e7          	jalr	-1270(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80003182:	01048513          	addi	a0,s1,16
    80003186:	00001097          	auipc	ra,0x1
    8000318a:	40e080e7          	jalr	1038(ra) # 80004594 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000318e:	409c                	lw	a5,0(s1)
    80003190:	cb89                	beqz	a5,800031a2 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003192:	8526                	mv	a0,s1
    80003194:	70a2                	ld	ra,40(sp)
    80003196:	7402                	ld	s0,32(sp)
    80003198:	64e2                	ld	s1,24(sp)
    8000319a:	6942                	ld	s2,16(sp)
    8000319c:	69a2                	ld	s3,8(sp)
    8000319e:	6145                	addi	sp,sp,48
    800031a0:	8082                	ret
    virtio_disk_rw(b, 0);
    800031a2:	4581                	li	a1,0
    800031a4:	8526                	mv	a0,s1
    800031a6:	00003097          	auipc	ra,0x3
    800031aa:	f2c080e7          	jalr	-212(ra) # 800060d2 <virtio_disk_rw>
    b->valid = 1;
    800031ae:	4785                	li	a5,1
    800031b0:	c09c                	sw	a5,0(s1)
  return b;
    800031b2:	b7c5                	j	80003192 <bread+0xd0>

00000000800031b4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031b4:	1101                	addi	sp,sp,-32
    800031b6:	ec06                	sd	ra,24(sp)
    800031b8:	e822                	sd	s0,16(sp)
    800031ba:	e426                	sd	s1,8(sp)
    800031bc:	1000                	addi	s0,sp,32
    800031be:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031c0:	0541                	addi	a0,a0,16
    800031c2:	00001097          	auipc	ra,0x1
    800031c6:	46c080e7          	jalr	1132(ra) # 8000462e <holdingsleep>
    800031ca:	cd01                	beqz	a0,800031e2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800031cc:	4585                	li	a1,1
    800031ce:	8526                	mv	a0,s1
    800031d0:	00003097          	auipc	ra,0x3
    800031d4:	f02080e7          	jalr	-254(ra) # 800060d2 <virtio_disk_rw>
}
    800031d8:	60e2                	ld	ra,24(sp)
    800031da:	6442                	ld	s0,16(sp)
    800031dc:	64a2                	ld	s1,8(sp)
    800031de:	6105                	addi	sp,sp,32
    800031e0:	8082                	ret
    panic("bwrite");
    800031e2:	00005517          	auipc	a0,0x5
    800031e6:	34650513          	addi	a0,a0,838 # 80008528 <syscalls+0xe0>
    800031ea:	ffffd097          	auipc	ra,0xffffd
    800031ee:	350080e7          	jalr	848(ra) # 8000053a <panic>

00000000800031f2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031f2:	1101                	addi	sp,sp,-32
    800031f4:	ec06                	sd	ra,24(sp)
    800031f6:	e822                	sd	s0,16(sp)
    800031f8:	e426                	sd	s1,8(sp)
    800031fa:	e04a                	sd	s2,0(sp)
    800031fc:	1000                	addi	s0,sp,32
    800031fe:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003200:	01050913          	addi	s2,a0,16
    80003204:	854a                	mv	a0,s2
    80003206:	00001097          	auipc	ra,0x1
    8000320a:	428080e7          	jalr	1064(ra) # 8000462e <holdingsleep>
    8000320e:	c92d                	beqz	a0,80003280 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003210:	854a                	mv	a0,s2
    80003212:	00001097          	auipc	ra,0x1
    80003216:	3d8080e7          	jalr	984(ra) # 800045ea <releasesleep>

  acquire(&bcache.lock);
    8000321a:	00014517          	auipc	a0,0x14
    8000321e:	4ce50513          	addi	a0,a0,1230 # 800176e8 <bcache>
    80003222:	ffffe097          	auipc	ra,0xffffe
    80003226:	9ae080e7          	jalr	-1618(ra) # 80000bd0 <acquire>
  b->refcnt--;
    8000322a:	40bc                	lw	a5,64(s1)
    8000322c:	37fd                	addiw	a5,a5,-1
    8000322e:	0007871b          	sext.w	a4,a5
    80003232:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003234:	eb05                	bnez	a4,80003264 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003236:	68bc                	ld	a5,80(s1)
    80003238:	64b8                	ld	a4,72(s1)
    8000323a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000323c:	64bc                	ld	a5,72(s1)
    8000323e:	68b8                	ld	a4,80(s1)
    80003240:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003242:	0001c797          	auipc	a5,0x1c
    80003246:	4a678793          	addi	a5,a5,1190 # 8001f6e8 <bcache+0x8000>
    8000324a:	2b87b703          	ld	a4,696(a5)
    8000324e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003250:	0001c717          	auipc	a4,0x1c
    80003254:	70070713          	addi	a4,a4,1792 # 8001f950 <bcache+0x8268>
    80003258:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000325a:	2b87b703          	ld	a4,696(a5)
    8000325e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003260:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003264:	00014517          	auipc	a0,0x14
    80003268:	48450513          	addi	a0,a0,1156 # 800176e8 <bcache>
    8000326c:	ffffe097          	auipc	ra,0xffffe
    80003270:	a18080e7          	jalr	-1512(ra) # 80000c84 <release>
}
    80003274:	60e2                	ld	ra,24(sp)
    80003276:	6442                	ld	s0,16(sp)
    80003278:	64a2                	ld	s1,8(sp)
    8000327a:	6902                	ld	s2,0(sp)
    8000327c:	6105                	addi	sp,sp,32
    8000327e:	8082                	ret
    panic("brelse");
    80003280:	00005517          	auipc	a0,0x5
    80003284:	2b050513          	addi	a0,a0,688 # 80008530 <syscalls+0xe8>
    80003288:	ffffd097          	auipc	ra,0xffffd
    8000328c:	2b2080e7          	jalr	690(ra) # 8000053a <panic>

0000000080003290 <bpin>:

void
bpin(struct buf *b) {
    80003290:	1101                	addi	sp,sp,-32
    80003292:	ec06                	sd	ra,24(sp)
    80003294:	e822                	sd	s0,16(sp)
    80003296:	e426                	sd	s1,8(sp)
    80003298:	1000                	addi	s0,sp,32
    8000329a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000329c:	00014517          	auipc	a0,0x14
    800032a0:	44c50513          	addi	a0,a0,1100 # 800176e8 <bcache>
    800032a4:	ffffe097          	auipc	ra,0xffffe
    800032a8:	92c080e7          	jalr	-1748(ra) # 80000bd0 <acquire>
  b->refcnt++;
    800032ac:	40bc                	lw	a5,64(s1)
    800032ae:	2785                	addiw	a5,a5,1
    800032b0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032b2:	00014517          	auipc	a0,0x14
    800032b6:	43650513          	addi	a0,a0,1078 # 800176e8 <bcache>
    800032ba:	ffffe097          	auipc	ra,0xffffe
    800032be:	9ca080e7          	jalr	-1590(ra) # 80000c84 <release>
}
    800032c2:	60e2                	ld	ra,24(sp)
    800032c4:	6442                	ld	s0,16(sp)
    800032c6:	64a2                	ld	s1,8(sp)
    800032c8:	6105                	addi	sp,sp,32
    800032ca:	8082                	ret

00000000800032cc <bunpin>:

void
bunpin(struct buf *b) {
    800032cc:	1101                	addi	sp,sp,-32
    800032ce:	ec06                	sd	ra,24(sp)
    800032d0:	e822                	sd	s0,16(sp)
    800032d2:	e426                	sd	s1,8(sp)
    800032d4:	1000                	addi	s0,sp,32
    800032d6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032d8:	00014517          	auipc	a0,0x14
    800032dc:	41050513          	addi	a0,a0,1040 # 800176e8 <bcache>
    800032e0:	ffffe097          	auipc	ra,0xffffe
    800032e4:	8f0080e7          	jalr	-1808(ra) # 80000bd0 <acquire>
  b->refcnt--;
    800032e8:	40bc                	lw	a5,64(s1)
    800032ea:	37fd                	addiw	a5,a5,-1
    800032ec:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032ee:	00014517          	auipc	a0,0x14
    800032f2:	3fa50513          	addi	a0,a0,1018 # 800176e8 <bcache>
    800032f6:	ffffe097          	auipc	ra,0xffffe
    800032fa:	98e080e7          	jalr	-1650(ra) # 80000c84 <release>
}
    800032fe:	60e2                	ld	ra,24(sp)
    80003300:	6442                	ld	s0,16(sp)
    80003302:	64a2                	ld	s1,8(sp)
    80003304:	6105                	addi	sp,sp,32
    80003306:	8082                	ret

0000000080003308 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003308:	1101                	addi	sp,sp,-32
    8000330a:	ec06                	sd	ra,24(sp)
    8000330c:	e822                	sd	s0,16(sp)
    8000330e:	e426                	sd	s1,8(sp)
    80003310:	e04a                	sd	s2,0(sp)
    80003312:	1000                	addi	s0,sp,32
    80003314:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003316:	00d5d59b          	srliw	a1,a1,0xd
    8000331a:	0001d797          	auipc	a5,0x1d
    8000331e:	aaa7a783          	lw	a5,-1366(a5) # 8001fdc4 <sb+0x1c>
    80003322:	9dbd                	addw	a1,a1,a5
    80003324:	00000097          	auipc	ra,0x0
    80003328:	d9e080e7          	jalr	-610(ra) # 800030c2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000332c:	0074f713          	andi	a4,s1,7
    80003330:	4785                	li	a5,1
    80003332:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003336:	14ce                	slli	s1,s1,0x33
    80003338:	90d9                	srli	s1,s1,0x36
    8000333a:	00950733          	add	a4,a0,s1
    8000333e:	05874703          	lbu	a4,88(a4)
    80003342:	00e7f6b3          	and	a3,a5,a4
    80003346:	c69d                	beqz	a3,80003374 <bfree+0x6c>
    80003348:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000334a:	94aa                	add	s1,s1,a0
    8000334c:	fff7c793          	not	a5,a5
    80003350:	8f7d                	and	a4,a4,a5
    80003352:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003356:	00001097          	auipc	ra,0x1
    8000335a:	120080e7          	jalr	288(ra) # 80004476 <log_write>
  brelse(bp);
    8000335e:	854a                	mv	a0,s2
    80003360:	00000097          	auipc	ra,0x0
    80003364:	e92080e7          	jalr	-366(ra) # 800031f2 <brelse>
}
    80003368:	60e2                	ld	ra,24(sp)
    8000336a:	6442                	ld	s0,16(sp)
    8000336c:	64a2                	ld	s1,8(sp)
    8000336e:	6902                	ld	s2,0(sp)
    80003370:	6105                	addi	sp,sp,32
    80003372:	8082                	ret
    panic("freeing free block");
    80003374:	00005517          	auipc	a0,0x5
    80003378:	1c450513          	addi	a0,a0,452 # 80008538 <syscalls+0xf0>
    8000337c:	ffffd097          	auipc	ra,0xffffd
    80003380:	1be080e7          	jalr	446(ra) # 8000053a <panic>

0000000080003384 <balloc>:
{
    80003384:	711d                	addi	sp,sp,-96
    80003386:	ec86                	sd	ra,88(sp)
    80003388:	e8a2                	sd	s0,80(sp)
    8000338a:	e4a6                	sd	s1,72(sp)
    8000338c:	e0ca                	sd	s2,64(sp)
    8000338e:	fc4e                	sd	s3,56(sp)
    80003390:	f852                	sd	s4,48(sp)
    80003392:	f456                	sd	s5,40(sp)
    80003394:	f05a                	sd	s6,32(sp)
    80003396:	ec5e                	sd	s7,24(sp)
    80003398:	e862                	sd	s8,16(sp)
    8000339a:	e466                	sd	s9,8(sp)
    8000339c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000339e:	0001d797          	auipc	a5,0x1d
    800033a2:	a0e7a783          	lw	a5,-1522(a5) # 8001fdac <sb+0x4>
    800033a6:	cbc1                	beqz	a5,80003436 <balloc+0xb2>
    800033a8:	8baa                	mv	s7,a0
    800033aa:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033ac:	0001db17          	auipc	s6,0x1d
    800033b0:	9fcb0b13          	addi	s6,s6,-1540 # 8001fda8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033b4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033b6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033b8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033ba:	6c89                	lui	s9,0x2
    800033bc:	a831                	j	800033d8 <balloc+0x54>
    brelse(bp);
    800033be:	854a                	mv	a0,s2
    800033c0:	00000097          	auipc	ra,0x0
    800033c4:	e32080e7          	jalr	-462(ra) # 800031f2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033c8:	015c87bb          	addw	a5,s9,s5
    800033cc:	00078a9b          	sext.w	s5,a5
    800033d0:	004b2703          	lw	a4,4(s6)
    800033d4:	06eaf163          	bgeu	s5,a4,80003436 <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    800033d8:	41fad79b          	sraiw	a5,s5,0x1f
    800033dc:	0137d79b          	srliw	a5,a5,0x13
    800033e0:	015787bb          	addw	a5,a5,s5
    800033e4:	40d7d79b          	sraiw	a5,a5,0xd
    800033e8:	01cb2583          	lw	a1,28(s6)
    800033ec:	9dbd                	addw	a1,a1,a5
    800033ee:	855e                	mv	a0,s7
    800033f0:	00000097          	auipc	ra,0x0
    800033f4:	cd2080e7          	jalr	-814(ra) # 800030c2 <bread>
    800033f8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033fa:	004b2503          	lw	a0,4(s6)
    800033fe:	000a849b          	sext.w	s1,s5
    80003402:	8762                	mv	a4,s8
    80003404:	faa4fde3          	bgeu	s1,a0,800033be <balloc+0x3a>
      m = 1 << (bi % 8);
    80003408:	00777693          	andi	a3,a4,7
    8000340c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003410:	41f7579b          	sraiw	a5,a4,0x1f
    80003414:	01d7d79b          	srliw	a5,a5,0x1d
    80003418:	9fb9                	addw	a5,a5,a4
    8000341a:	4037d79b          	sraiw	a5,a5,0x3
    8000341e:	00f90633          	add	a2,s2,a5
    80003422:	05864603          	lbu	a2,88(a2)
    80003426:	00c6f5b3          	and	a1,a3,a2
    8000342a:	cd91                	beqz	a1,80003446 <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000342c:	2705                	addiw	a4,a4,1
    8000342e:	2485                	addiw	s1,s1,1
    80003430:	fd471ae3          	bne	a4,s4,80003404 <balloc+0x80>
    80003434:	b769                	j	800033be <balloc+0x3a>
  panic("balloc: out of blocks");
    80003436:	00005517          	auipc	a0,0x5
    8000343a:	11a50513          	addi	a0,a0,282 # 80008550 <syscalls+0x108>
    8000343e:	ffffd097          	auipc	ra,0xffffd
    80003442:	0fc080e7          	jalr	252(ra) # 8000053a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003446:	97ca                	add	a5,a5,s2
    80003448:	8e55                	or	a2,a2,a3
    8000344a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000344e:	854a                	mv	a0,s2
    80003450:	00001097          	auipc	ra,0x1
    80003454:	026080e7          	jalr	38(ra) # 80004476 <log_write>
        brelse(bp);
    80003458:	854a                	mv	a0,s2
    8000345a:	00000097          	auipc	ra,0x0
    8000345e:	d98080e7          	jalr	-616(ra) # 800031f2 <brelse>
  bp = bread(dev, bno);
    80003462:	85a6                	mv	a1,s1
    80003464:	855e                	mv	a0,s7
    80003466:	00000097          	auipc	ra,0x0
    8000346a:	c5c080e7          	jalr	-932(ra) # 800030c2 <bread>
    8000346e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003470:	40000613          	li	a2,1024
    80003474:	4581                	li	a1,0
    80003476:	05850513          	addi	a0,a0,88
    8000347a:	ffffe097          	auipc	ra,0xffffe
    8000347e:	852080e7          	jalr	-1966(ra) # 80000ccc <memset>
  log_write(bp);
    80003482:	854a                	mv	a0,s2
    80003484:	00001097          	auipc	ra,0x1
    80003488:	ff2080e7          	jalr	-14(ra) # 80004476 <log_write>
  brelse(bp);
    8000348c:	854a                	mv	a0,s2
    8000348e:	00000097          	auipc	ra,0x0
    80003492:	d64080e7          	jalr	-668(ra) # 800031f2 <brelse>
}
    80003496:	8526                	mv	a0,s1
    80003498:	60e6                	ld	ra,88(sp)
    8000349a:	6446                	ld	s0,80(sp)
    8000349c:	64a6                	ld	s1,72(sp)
    8000349e:	6906                	ld	s2,64(sp)
    800034a0:	79e2                	ld	s3,56(sp)
    800034a2:	7a42                	ld	s4,48(sp)
    800034a4:	7aa2                	ld	s5,40(sp)
    800034a6:	7b02                	ld	s6,32(sp)
    800034a8:	6be2                	ld	s7,24(sp)
    800034aa:	6c42                	ld	s8,16(sp)
    800034ac:	6ca2                	ld	s9,8(sp)
    800034ae:	6125                	addi	sp,sp,96
    800034b0:	8082                	ret

00000000800034b2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800034b2:	7179                	addi	sp,sp,-48
    800034b4:	f406                	sd	ra,40(sp)
    800034b6:	f022                	sd	s0,32(sp)
    800034b8:	ec26                	sd	s1,24(sp)
    800034ba:	e84a                	sd	s2,16(sp)
    800034bc:	e44e                	sd	s3,8(sp)
    800034be:	e052                	sd	s4,0(sp)
    800034c0:	1800                	addi	s0,sp,48
    800034c2:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034c4:	47ad                	li	a5,11
    800034c6:	04b7fe63          	bgeu	a5,a1,80003522 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800034ca:	ff45849b          	addiw	s1,a1,-12
    800034ce:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034d2:	0ff00793          	li	a5,255
    800034d6:	0ae7e463          	bltu	a5,a4,8000357e <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800034da:	08052583          	lw	a1,128(a0)
    800034de:	c5b5                	beqz	a1,8000354a <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800034e0:	00092503          	lw	a0,0(s2)
    800034e4:	00000097          	auipc	ra,0x0
    800034e8:	bde080e7          	jalr	-1058(ra) # 800030c2 <bread>
    800034ec:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034ee:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800034f2:	02049713          	slli	a4,s1,0x20
    800034f6:	01e75593          	srli	a1,a4,0x1e
    800034fa:	00b784b3          	add	s1,a5,a1
    800034fe:	0004a983          	lw	s3,0(s1)
    80003502:	04098e63          	beqz	s3,8000355e <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003506:	8552                	mv	a0,s4
    80003508:	00000097          	auipc	ra,0x0
    8000350c:	cea080e7          	jalr	-790(ra) # 800031f2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003510:	854e                	mv	a0,s3
    80003512:	70a2                	ld	ra,40(sp)
    80003514:	7402                	ld	s0,32(sp)
    80003516:	64e2                	ld	s1,24(sp)
    80003518:	6942                	ld	s2,16(sp)
    8000351a:	69a2                	ld	s3,8(sp)
    8000351c:	6a02                	ld	s4,0(sp)
    8000351e:	6145                	addi	sp,sp,48
    80003520:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003522:	02059793          	slli	a5,a1,0x20
    80003526:	01e7d593          	srli	a1,a5,0x1e
    8000352a:	00b504b3          	add	s1,a0,a1
    8000352e:	0504a983          	lw	s3,80(s1)
    80003532:	fc099fe3          	bnez	s3,80003510 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003536:	4108                	lw	a0,0(a0)
    80003538:	00000097          	auipc	ra,0x0
    8000353c:	e4c080e7          	jalr	-436(ra) # 80003384 <balloc>
    80003540:	0005099b          	sext.w	s3,a0
    80003544:	0534a823          	sw	s3,80(s1)
    80003548:	b7e1                	j	80003510 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000354a:	4108                	lw	a0,0(a0)
    8000354c:	00000097          	auipc	ra,0x0
    80003550:	e38080e7          	jalr	-456(ra) # 80003384 <balloc>
    80003554:	0005059b          	sext.w	a1,a0
    80003558:	08b92023          	sw	a1,128(s2)
    8000355c:	b751                	j	800034e0 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000355e:	00092503          	lw	a0,0(s2)
    80003562:	00000097          	auipc	ra,0x0
    80003566:	e22080e7          	jalr	-478(ra) # 80003384 <balloc>
    8000356a:	0005099b          	sext.w	s3,a0
    8000356e:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003572:	8552                	mv	a0,s4
    80003574:	00001097          	auipc	ra,0x1
    80003578:	f02080e7          	jalr	-254(ra) # 80004476 <log_write>
    8000357c:	b769                	j	80003506 <bmap+0x54>
  panic("bmap: out of range");
    8000357e:	00005517          	auipc	a0,0x5
    80003582:	fea50513          	addi	a0,a0,-22 # 80008568 <syscalls+0x120>
    80003586:	ffffd097          	auipc	ra,0xffffd
    8000358a:	fb4080e7          	jalr	-76(ra) # 8000053a <panic>

000000008000358e <iget>:
{
    8000358e:	7179                	addi	sp,sp,-48
    80003590:	f406                	sd	ra,40(sp)
    80003592:	f022                	sd	s0,32(sp)
    80003594:	ec26                	sd	s1,24(sp)
    80003596:	e84a                	sd	s2,16(sp)
    80003598:	e44e                	sd	s3,8(sp)
    8000359a:	e052                	sd	s4,0(sp)
    8000359c:	1800                	addi	s0,sp,48
    8000359e:	89aa                	mv	s3,a0
    800035a0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800035a2:	0001d517          	auipc	a0,0x1d
    800035a6:	82650513          	addi	a0,a0,-2010 # 8001fdc8 <itable>
    800035aa:	ffffd097          	auipc	ra,0xffffd
    800035ae:	626080e7          	jalr	1574(ra) # 80000bd0 <acquire>
  empty = 0;
    800035b2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035b4:	0001d497          	auipc	s1,0x1d
    800035b8:	82c48493          	addi	s1,s1,-2004 # 8001fde0 <itable+0x18>
    800035bc:	0001e697          	auipc	a3,0x1e
    800035c0:	2b468693          	addi	a3,a3,692 # 80021870 <log>
    800035c4:	a039                	j	800035d2 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035c6:	02090b63          	beqz	s2,800035fc <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035ca:	08848493          	addi	s1,s1,136
    800035ce:	02d48a63          	beq	s1,a3,80003602 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035d2:	449c                	lw	a5,8(s1)
    800035d4:	fef059e3          	blez	a5,800035c6 <iget+0x38>
    800035d8:	4098                	lw	a4,0(s1)
    800035da:	ff3716e3          	bne	a4,s3,800035c6 <iget+0x38>
    800035de:	40d8                	lw	a4,4(s1)
    800035e0:	ff4713e3          	bne	a4,s4,800035c6 <iget+0x38>
      ip->ref++;
    800035e4:	2785                	addiw	a5,a5,1
    800035e6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800035e8:	0001c517          	auipc	a0,0x1c
    800035ec:	7e050513          	addi	a0,a0,2016 # 8001fdc8 <itable>
    800035f0:	ffffd097          	auipc	ra,0xffffd
    800035f4:	694080e7          	jalr	1684(ra) # 80000c84 <release>
      return ip;
    800035f8:	8926                	mv	s2,s1
    800035fa:	a03d                	j	80003628 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035fc:	f7f9                	bnez	a5,800035ca <iget+0x3c>
    800035fe:	8926                	mv	s2,s1
    80003600:	b7e9                	j	800035ca <iget+0x3c>
  if(empty == 0)
    80003602:	02090c63          	beqz	s2,8000363a <iget+0xac>
  ip->dev = dev;
    80003606:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000360a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000360e:	4785                	li	a5,1
    80003610:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003614:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003618:	0001c517          	auipc	a0,0x1c
    8000361c:	7b050513          	addi	a0,a0,1968 # 8001fdc8 <itable>
    80003620:	ffffd097          	auipc	ra,0xffffd
    80003624:	664080e7          	jalr	1636(ra) # 80000c84 <release>
}
    80003628:	854a                	mv	a0,s2
    8000362a:	70a2                	ld	ra,40(sp)
    8000362c:	7402                	ld	s0,32(sp)
    8000362e:	64e2                	ld	s1,24(sp)
    80003630:	6942                	ld	s2,16(sp)
    80003632:	69a2                	ld	s3,8(sp)
    80003634:	6a02                	ld	s4,0(sp)
    80003636:	6145                	addi	sp,sp,48
    80003638:	8082                	ret
    panic("iget: no inodes");
    8000363a:	00005517          	auipc	a0,0x5
    8000363e:	f4650513          	addi	a0,a0,-186 # 80008580 <syscalls+0x138>
    80003642:	ffffd097          	auipc	ra,0xffffd
    80003646:	ef8080e7          	jalr	-264(ra) # 8000053a <panic>

000000008000364a <fsinit>:
fsinit(int dev) {
    8000364a:	7179                	addi	sp,sp,-48
    8000364c:	f406                	sd	ra,40(sp)
    8000364e:	f022                	sd	s0,32(sp)
    80003650:	ec26                	sd	s1,24(sp)
    80003652:	e84a                	sd	s2,16(sp)
    80003654:	e44e                	sd	s3,8(sp)
    80003656:	1800                	addi	s0,sp,48
    80003658:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000365a:	4585                	li	a1,1
    8000365c:	00000097          	auipc	ra,0x0
    80003660:	a66080e7          	jalr	-1434(ra) # 800030c2 <bread>
    80003664:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003666:	0001c997          	auipc	s3,0x1c
    8000366a:	74298993          	addi	s3,s3,1858 # 8001fda8 <sb>
    8000366e:	02000613          	li	a2,32
    80003672:	05850593          	addi	a1,a0,88
    80003676:	854e                	mv	a0,s3
    80003678:	ffffd097          	auipc	ra,0xffffd
    8000367c:	6b0080e7          	jalr	1712(ra) # 80000d28 <memmove>
  brelse(bp);
    80003680:	8526                	mv	a0,s1
    80003682:	00000097          	auipc	ra,0x0
    80003686:	b70080e7          	jalr	-1168(ra) # 800031f2 <brelse>
  if(sb.magic != FSMAGIC)
    8000368a:	0009a703          	lw	a4,0(s3)
    8000368e:	102037b7          	lui	a5,0x10203
    80003692:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003696:	02f71263          	bne	a4,a5,800036ba <fsinit+0x70>
  initlog(dev, &sb);
    8000369a:	0001c597          	auipc	a1,0x1c
    8000369e:	70e58593          	addi	a1,a1,1806 # 8001fda8 <sb>
    800036a2:	854a                	mv	a0,s2
    800036a4:	00001097          	auipc	ra,0x1
    800036a8:	b56080e7          	jalr	-1194(ra) # 800041fa <initlog>
}
    800036ac:	70a2                	ld	ra,40(sp)
    800036ae:	7402                	ld	s0,32(sp)
    800036b0:	64e2                	ld	s1,24(sp)
    800036b2:	6942                	ld	s2,16(sp)
    800036b4:	69a2                	ld	s3,8(sp)
    800036b6:	6145                	addi	sp,sp,48
    800036b8:	8082                	ret
    panic("invalid file system");
    800036ba:	00005517          	auipc	a0,0x5
    800036be:	ed650513          	addi	a0,a0,-298 # 80008590 <syscalls+0x148>
    800036c2:	ffffd097          	auipc	ra,0xffffd
    800036c6:	e78080e7          	jalr	-392(ra) # 8000053a <panic>

00000000800036ca <iinit>:
{
    800036ca:	7179                	addi	sp,sp,-48
    800036cc:	f406                	sd	ra,40(sp)
    800036ce:	f022                	sd	s0,32(sp)
    800036d0:	ec26                	sd	s1,24(sp)
    800036d2:	e84a                	sd	s2,16(sp)
    800036d4:	e44e                	sd	s3,8(sp)
    800036d6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800036d8:	00005597          	auipc	a1,0x5
    800036dc:	ed058593          	addi	a1,a1,-304 # 800085a8 <syscalls+0x160>
    800036e0:	0001c517          	auipc	a0,0x1c
    800036e4:	6e850513          	addi	a0,a0,1768 # 8001fdc8 <itable>
    800036e8:	ffffd097          	auipc	ra,0xffffd
    800036ec:	458080e7          	jalr	1112(ra) # 80000b40 <initlock>
  for(i = 0; i < NINODE; i++) {
    800036f0:	0001c497          	auipc	s1,0x1c
    800036f4:	70048493          	addi	s1,s1,1792 # 8001fdf0 <itable+0x28>
    800036f8:	0001e997          	auipc	s3,0x1e
    800036fc:	18898993          	addi	s3,s3,392 # 80021880 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003700:	00005917          	auipc	s2,0x5
    80003704:	eb090913          	addi	s2,s2,-336 # 800085b0 <syscalls+0x168>
    80003708:	85ca                	mv	a1,s2
    8000370a:	8526                	mv	a0,s1
    8000370c:	00001097          	auipc	ra,0x1
    80003710:	e4e080e7          	jalr	-434(ra) # 8000455a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003714:	08848493          	addi	s1,s1,136
    80003718:	ff3498e3          	bne	s1,s3,80003708 <iinit+0x3e>
}
    8000371c:	70a2                	ld	ra,40(sp)
    8000371e:	7402                	ld	s0,32(sp)
    80003720:	64e2                	ld	s1,24(sp)
    80003722:	6942                	ld	s2,16(sp)
    80003724:	69a2                	ld	s3,8(sp)
    80003726:	6145                	addi	sp,sp,48
    80003728:	8082                	ret

000000008000372a <ialloc>:
{
    8000372a:	715d                	addi	sp,sp,-80
    8000372c:	e486                	sd	ra,72(sp)
    8000372e:	e0a2                	sd	s0,64(sp)
    80003730:	fc26                	sd	s1,56(sp)
    80003732:	f84a                	sd	s2,48(sp)
    80003734:	f44e                	sd	s3,40(sp)
    80003736:	f052                	sd	s4,32(sp)
    80003738:	ec56                	sd	s5,24(sp)
    8000373a:	e85a                	sd	s6,16(sp)
    8000373c:	e45e                	sd	s7,8(sp)
    8000373e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003740:	0001c717          	auipc	a4,0x1c
    80003744:	67472703          	lw	a4,1652(a4) # 8001fdb4 <sb+0xc>
    80003748:	4785                	li	a5,1
    8000374a:	04e7fa63          	bgeu	a5,a4,8000379e <ialloc+0x74>
    8000374e:	8aaa                	mv	s5,a0
    80003750:	8bae                	mv	s7,a1
    80003752:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003754:	0001ca17          	auipc	s4,0x1c
    80003758:	654a0a13          	addi	s4,s4,1620 # 8001fda8 <sb>
    8000375c:	00048b1b          	sext.w	s6,s1
    80003760:	0044d593          	srli	a1,s1,0x4
    80003764:	018a2783          	lw	a5,24(s4)
    80003768:	9dbd                	addw	a1,a1,a5
    8000376a:	8556                	mv	a0,s5
    8000376c:	00000097          	auipc	ra,0x0
    80003770:	956080e7          	jalr	-1706(ra) # 800030c2 <bread>
    80003774:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003776:	05850993          	addi	s3,a0,88
    8000377a:	00f4f793          	andi	a5,s1,15
    8000377e:	079a                	slli	a5,a5,0x6
    80003780:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003782:	00099783          	lh	a5,0(s3)
    80003786:	c785                	beqz	a5,800037ae <ialloc+0x84>
    brelse(bp);
    80003788:	00000097          	auipc	ra,0x0
    8000378c:	a6a080e7          	jalr	-1430(ra) # 800031f2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003790:	0485                	addi	s1,s1,1
    80003792:	00ca2703          	lw	a4,12(s4)
    80003796:	0004879b          	sext.w	a5,s1
    8000379a:	fce7e1e3          	bltu	a5,a4,8000375c <ialloc+0x32>
  panic("ialloc: no inodes");
    8000379e:	00005517          	auipc	a0,0x5
    800037a2:	e1a50513          	addi	a0,a0,-486 # 800085b8 <syscalls+0x170>
    800037a6:	ffffd097          	auipc	ra,0xffffd
    800037aa:	d94080e7          	jalr	-620(ra) # 8000053a <panic>
      memset(dip, 0, sizeof(*dip));
    800037ae:	04000613          	li	a2,64
    800037b2:	4581                	li	a1,0
    800037b4:	854e                	mv	a0,s3
    800037b6:	ffffd097          	auipc	ra,0xffffd
    800037ba:	516080e7          	jalr	1302(ra) # 80000ccc <memset>
      dip->type = type;
    800037be:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800037c2:	854a                	mv	a0,s2
    800037c4:	00001097          	auipc	ra,0x1
    800037c8:	cb2080e7          	jalr	-846(ra) # 80004476 <log_write>
      brelse(bp);
    800037cc:	854a                	mv	a0,s2
    800037ce:	00000097          	auipc	ra,0x0
    800037d2:	a24080e7          	jalr	-1500(ra) # 800031f2 <brelse>
      return iget(dev, inum);
    800037d6:	85da                	mv	a1,s6
    800037d8:	8556                	mv	a0,s5
    800037da:	00000097          	auipc	ra,0x0
    800037de:	db4080e7          	jalr	-588(ra) # 8000358e <iget>
}
    800037e2:	60a6                	ld	ra,72(sp)
    800037e4:	6406                	ld	s0,64(sp)
    800037e6:	74e2                	ld	s1,56(sp)
    800037e8:	7942                	ld	s2,48(sp)
    800037ea:	79a2                	ld	s3,40(sp)
    800037ec:	7a02                	ld	s4,32(sp)
    800037ee:	6ae2                	ld	s5,24(sp)
    800037f0:	6b42                	ld	s6,16(sp)
    800037f2:	6ba2                	ld	s7,8(sp)
    800037f4:	6161                	addi	sp,sp,80
    800037f6:	8082                	ret

00000000800037f8 <iupdate>:
{
    800037f8:	1101                	addi	sp,sp,-32
    800037fa:	ec06                	sd	ra,24(sp)
    800037fc:	e822                	sd	s0,16(sp)
    800037fe:	e426                	sd	s1,8(sp)
    80003800:	e04a                	sd	s2,0(sp)
    80003802:	1000                	addi	s0,sp,32
    80003804:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003806:	415c                	lw	a5,4(a0)
    80003808:	0047d79b          	srliw	a5,a5,0x4
    8000380c:	0001c597          	auipc	a1,0x1c
    80003810:	5b45a583          	lw	a1,1460(a1) # 8001fdc0 <sb+0x18>
    80003814:	9dbd                	addw	a1,a1,a5
    80003816:	4108                	lw	a0,0(a0)
    80003818:	00000097          	auipc	ra,0x0
    8000381c:	8aa080e7          	jalr	-1878(ra) # 800030c2 <bread>
    80003820:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003822:	05850793          	addi	a5,a0,88
    80003826:	40d8                	lw	a4,4(s1)
    80003828:	8b3d                	andi	a4,a4,15
    8000382a:	071a                	slli	a4,a4,0x6
    8000382c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000382e:	04449703          	lh	a4,68(s1)
    80003832:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003836:	04649703          	lh	a4,70(s1)
    8000383a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000383e:	04849703          	lh	a4,72(s1)
    80003842:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003846:	04a49703          	lh	a4,74(s1)
    8000384a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000384e:	44f8                	lw	a4,76(s1)
    80003850:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003852:	03400613          	li	a2,52
    80003856:	05048593          	addi	a1,s1,80
    8000385a:	00c78513          	addi	a0,a5,12
    8000385e:	ffffd097          	auipc	ra,0xffffd
    80003862:	4ca080e7          	jalr	1226(ra) # 80000d28 <memmove>
  log_write(bp);
    80003866:	854a                	mv	a0,s2
    80003868:	00001097          	auipc	ra,0x1
    8000386c:	c0e080e7          	jalr	-1010(ra) # 80004476 <log_write>
  brelse(bp);
    80003870:	854a                	mv	a0,s2
    80003872:	00000097          	auipc	ra,0x0
    80003876:	980080e7          	jalr	-1664(ra) # 800031f2 <brelse>
}
    8000387a:	60e2                	ld	ra,24(sp)
    8000387c:	6442                	ld	s0,16(sp)
    8000387e:	64a2                	ld	s1,8(sp)
    80003880:	6902                	ld	s2,0(sp)
    80003882:	6105                	addi	sp,sp,32
    80003884:	8082                	ret

0000000080003886 <idup>:
{
    80003886:	1101                	addi	sp,sp,-32
    80003888:	ec06                	sd	ra,24(sp)
    8000388a:	e822                	sd	s0,16(sp)
    8000388c:	e426                	sd	s1,8(sp)
    8000388e:	1000                	addi	s0,sp,32
    80003890:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003892:	0001c517          	auipc	a0,0x1c
    80003896:	53650513          	addi	a0,a0,1334 # 8001fdc8 <itable>
    8000389a:	ffffd097          	auipc	ra,0xffffd
    8000389e:	336080e7          	jalr	822(ra) # 80000bd0 <acquire>
  ip->ref++;
    800038a2:	449c                	lw	a5,8(s1)
    800038a4:	2785                	addiw	a5,a5,1
    800038a6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038a8:	0001c517          	auipc	a0,0x1c
    800038ac:	52050513          	addi	a0,a0,1312 # 8001fdc8 <itable>
    800038b0:	ffffd097          	auipc	ra,0xffffd
    800038b4:	3d4080e7          	jalr	980(ra) # 80000c84 <release>
}
    800038b8:	8526                	mv	a0,s1
    800038ba:	60e2                	ld	ra,24(sp)
    800038bc:	6442                	ld	s0,16(sp)
    800038be:	64a2                	ld	s1,8(sp)
    800038c0:	6105                	addi	sp,sp,32
    800038c2:	8082                	ret

00000000800038c4 <ilock>:
{
    800038c4:	1101                	addi	sp,sp,-32
    800038c6:	ec06                	sd	ra,24(sp)
    800038c8:	e822                	sd	s0,16(sp)
    800038ca:	e426                	sd	s1,8(sp)
    800038cc:	e04a                	sd	s2,0(sp)
    800038ce:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800038d0:	c115                	beqz	a0,800038f4 <ilock+0x30>
    800038d2:	84aa                	mv	s1,a0
    800038d4:	451c                	lw	a5,8(a0)
    800038d6:	00f05f63          	blez	a5,800038f4 <ilock+0x30>
  acquiresleep(&ip->lock);
    800038da:	0541                	addi	a0,a0,16
    800038dc:	00001097          	auipc	ra,0x1
    800038e0:	cb8080e7          	jalr	-840(ra) # 80004594 <acquiresleep>
  if(ip->valid == 0){
    800038e4:	40bc                	lw	a5,64(s1)
    800038e6:	cf99                	beqz	a5,80003904 <ilock+0x40>
}
    800038e8:	60e2                	ld	ra,24(sp)
    800038ea:	6442                	ld	s0,16(sp)
    800038ec:	64a2                	ld	s1,8(sp)
    800038ee:	6902                	ld	s2,0(sp)
    800038f0:	6105                	addi	sp,sp,32
    800038f2:	8082                	ret
    panic("ilock");
    800038f4:	00005517          	auipc	a0,0x5
    800038f8:	cdc50513          	addi	a0,a0,-804 # 800085d0 <syscalls+0x188>
    800038fc:	ffffd097          	auipc	ra,0xffffd
    80003900:	c3e080e7          	jalr	-962(ra) # 8000053a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003904:	40dc                	lw	a5,4(s1)
    80003906:	0047d79b          	srliw	a5,a5,0x4
    8000390a:	0001c597          	auipc	a1,0x1c
    8000390e:	4b65a583          	lw	a1,1206(a1) # 8001fdc0 <sb+0x18>
    80003912:	9dbd                	addw	a1,a1,a5
    80003914:	4088                	lw	a0,0(s1)
    80003916:	fffff097          	auipc	ra,0xfffff
    8000391a:	7ac080e7          	jalr	1964(ra) # 800030c2 <bread>
    8000391e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003920:	05850593          	addi	a1,a0,88
    80003924:	40dc                	lw	a5,4(s1)
    80003926:	8bbd                	andi	a5,a5,15
    80003928:	079a                	slli	a5,a5,0x6
    8000392a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000392c:	00059783          	lh	a5,0(a1)
    80003930:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003934:	00259783          	lh	a5,2(a1)
    80003938:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000393c:	00459783          	lh	a5,4(a1)
    80003940:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003944:	00659783          	lh	a5,6(a1)
    80003948:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000394c:	459c                	lw	a5,8(a1)
    8000394e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003950:	03400613          	li	a2,52
    80003954:	05b1                	addi	a1,a1,12
    80003956:	05048513          	addi	a0,s1,80
    8000395a:	ffffd097          	auipc	ra,0xffffd
    8000395e:	3ce080e7          	jalr	974(ra) # 80000d28 <memmove>
    brelse(bp);
    80003962:	854a                	mv	a0,s2
    80003964:	00000097          	auipc	ra,0x0
    80003968:	88e080e7          	jalr	-1906(ra) # 800031f2 <brelse>
    ip->valid = 1;
    8000396c:	4785                	li	a5,1
    8000396e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003970:	04449783          	lh	a5,68(s1)
    80003974:	fbb5                	bnez	a5,800038e8 <ilock+0x24>
      panic("ilock: no type");
    80003976:	00005517          	auipc	a0,0x5
    8000397a:	c6250513          	addi	a0,a0,-926 # 800085d8 <syscalls+0x190>
    8000397e:	ffffd097          	auipc	ra,0xffffd
    80003982:	bbc080e7          	jalr	-1092(ra) # 8000053a <panic>

0000000080003986 <iunlock>:
{
    80003986:	1101                	addi	sp,sp,-32
    80003988:	ec06                	sd	ra,24(sp)
    8000398a:	e822                	sd	s0,16(sp)
    8000398c:	e426                	sd	s1,8(sp)
    8000398e:	e04a                	sd	s2,0(sp)
    80003990:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003992:	c905                	beqz	a0,800039c2 <iunlock+0x3c>
    80003994:	84aa                	mv	s1,a0
    80003996:	01050913          	addi	s2,a0,16
    8000399a:	854a                	mv	a0,s2
    8000399c:	00001097          	auipc	ra,0x1
    800039a0:	c92080e7          	jalr	-878(ra) # 8000462e <holdingsleep>
    800039a4:	cd19                	beqz	a0,800039c2 <iunlock+0x3c>
    800039a6:	449c                	lw	a5,8(s1)
    800039a8:	00f05d63          	blez	a5,800039c2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800039ac:	854a                	mv	a0,s2
    800039ae:	00001097          	auipc	ra,0x1
    800039b2:	c3c080e7          	jalr	-964(ra) # 800045ea <releasesleep>
}
    800039b6:	60e2                	ld	ra,24(sp)
    800039b8:	6442                	ld	s0,16(sp)
    800039ba:	64a2                	ld	s1,8(sp)
    800039bc:	6902                	ld	s2,0(sp)
    800039be:	6105                	addi	sp,sp,32
    800039c0:	8082                	ret
    panic("iunlock");
    800039c2:	00005517          	auipc	a0,0x5
    800039c6:	c2650513          	addi	a0,a0,-986 # 800085e8 <syscalls+0x1a0>
    800039ca:	ffffd097          	auipc	ra,0xffffd
    800039ce:	b70080e7          	jalr	-1168(ra) # 8000053a <panic>

00000000800039d2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800039d2:	7179                	addi	sp,sp,-48
    800039d4:	f406                	sd	ra,40(sp)
    800039d6:	f022                	sd	s0,32(sp)
    800039d8:	ec26                	sd	s1,24(sp)
    800039da:	e84a                	sd	s2,16(sp)
    800039dc:	e44e                	sd	s3,8(sp)
    800039de:	e052                	sd	s4,0(sp)
    800039e0:	1800                	addi	s0,sp,48
    800039e2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800039e4:	05050493          	addi	s1,a0,80
    800039e8:	08050913          	addi	s2,a0,128
    800039ec:	a021                	j	800039f4 <itrunc+0x22>
    800039ee:	0491                	addi	s1,s1,4
    800039f0:	01248d63          	beq	s1,s2,80003a0a <itrunc+0x38>
    if(ip->addrs[i]){
    800039f4:	408c                	lw	a1,0(s1)
    800039f6:	dde5                	beqz	a1,800039ee <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800039f8:	0009a503          	lw	a0,0(s3)
    800039fc:	00000097          	auipc	ra,0x0
    80003a00:	90c080e7          	jalr	-1780(ra) # 80003308 <bfree>
      ip->addrs[i] = 0;
    80003a04:	0004a023          	sw	zero,0(s1)
    80003a08:	b7dd                	j	800039ee <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a0a:	0809a583          	lw	a1,128(s3)
    80003a0e:	e185                	bnez	a1,80003a2e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a10:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a14:	854e                	mv	a0,s3
    80003a16:	00000097          	auipc	ra,0x0
    80003a1a:	de2080e7          	jalr	-542(ra) # 800037f8 <iupdate>
}
    80003a1e:	70a2                	ld	ra,40(sp)
    80003a20:	7402                	ld	s0,32(sp)
    80003a22:	64e2                	ld	s1,24(sp)
    80003a24:	6942                	ld	s2,16(sp)
    80003a26:	69a2                	ld	s3,8(sp)
    80003a28:	6a02                	ld	s4,0(sp)
    80003a2a:	6145                	addi	sp,sp,48
    80003a2c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a2e:	0009a503          	lw	a0,0(s3)
    80003a32:	fffff097          	auipc	ra,0xfffff
    80003a36:	690080e7          	jalr	1680(ra) # 800030c2 <bread>
    80003a3a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a3c:	05850493          	addi	s1,a0,88
    80003a40:	45850913          	addi	s2,a0,1112
    80003a44:	a021                	j	80003a4c <itrunc+0x7a>
    80003a46:	0491                	addi	s1,s1,4
    80003a48:	01248b63          	beq	s1,s2,80003a5e <itrunc+0x8c>
      if(a[j])
    80003a4c:	408c                	lw	a1,0(s1)
    80003a4e:	dde5                	beqz	a1,80003a46 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003a50:	0009a503          	lw	a0,0(s3)
    80003a54:	00000097          	auipc	ra,0x0
    80003a58:	8b4080e7          	jalr	-1868(ra) # 80003308 <bfree>
    80003a5c:	b7ed                	j	80003a46 <itrunc+0x74>
    brelse(bp);
    80003a5e:	8552                	mv	a0,s4
    80003a60:	fffff097          	auipc	ra,0xfffff
    80003a64:	792080e7          	jalr	1938(ra) # 800031f2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a68:	0809a583          	lw	a1,128(s3)
    80003a6c:	0009a503          	lw	a0,0(s3)
    80003a70:	00000097          	auipc	ra,0x0
    80003a74:	898080e7          	jalr	-1896(ra) # 80003308 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a78:	0809a023          	sw	zero,128(s3)
    80003a7c:	bf51                	j	80003a10 <itrunc+0x3e>

0000000080003a7e <iput>:
{
    80003a7e:	1101                	addi	sp,sp,-32
    80003a80:	ec06                	sd	ra,24(sp)
    80003a82:	e822                	sd	s0,16(sp)
    80003a84:	e426                	sd	s1,8(sp)
    80003a86:	e04a                	sd	s2,0(sp)
    80003a88:	1000                	addi	s0,sp,32
    80003a8a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a8c:	0001c517          	auipc	a0,0x1c
    80003a90:	33c50513          	addi	a0,a0,828 # 8001fdc8 <itable>
    80003a94:	ffffd097          	auipc	ra,0xffffd
    80003a98:	13c080e7          	jalr	316(ra) # 80000bd0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a9c:	4498                	lw	a4,8(s1)
    80003a9e:	4785                	li	a5,1
    80003aa0:	02f70363          	beq	a4,a5,80003ac6 <iput+0x48>
  ip->ref--;
    80003aa4:	449c                	lw	a5,8(s1)
    80003aa6:	37fd                	addiw	a5,a5,-1
    80003aa8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003aaa:	0001c517          	auipc	a0,0x1c
    80003aae:	31e50513          	addi	a0,a0,798 # 8001fdc8 <itable>
    80003ab2:	ffffd097          	auipc	ra,0xffffd
    80003ab6:	1d2080e7          	jalr	466(ra) # 80000c84 <release>
}
    80003aba:	60e2                	ld	ra,24(sp)
    80003abc:	6442                	ld	s0,16(sp)
    80003abe:	64a2                	ld	s1,8(sp)
    80003ac0:	6902                	ld	s2,0(sp)
    80003ac2:	6105                	addi	sp,sp,32
    80003ac4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ac6:	40bc                	lw	a5,64(s1)
    80003ac8:	dff1                	beqz	a5,80003aa4 <iput+0x26>
    80003aca:	04a49783          	lh	a5,74(s1)
    80003ace:	fbf9                	bnez	a5,80003aa4 <iput+0x26>
    acquiresleep(&ip->lock);
    80003ad0:	01048913          	addi	s2,s1,16
    80003ad4:	854a                	mv	a0,s2
    80003ad6:	00001097          	auipc	ra,0x1
    80003ada:	abe080e7          	jalr	-1346(ra) # 80004594 <acquiresleep>
    release(&itable.lock);
    80003ade:	0001c517          	auipc	a0,0x1c
    80003ae2:	2ea50513          	addi	a0,a0,746 # 8001fdc8 <itable>
    80003ae6:	ffffd097          	auipc	ra,0xffffd
    80003aea:	19e080e7          	jalr	414(ra) # 80000c84 <release>
    itrunc(ip);
    80003aee:	8526                	mv	a0,s1
    80003af0:	00000097          	auipc	ra,0x0
    80003af4:	ee2080e7          	jalr	-286(ra) # 800039d2 <itrunc>
    ip->type = 0;
    80003af8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003afc:	8526                	mv	a0,s1
    80003afe:	00000097          	auipc	ra,0x0
    80003b02:	cfa080e7          	jalr	-774(ra) # 800037f8 <iupdate>
    ip->valid = 0;
    80003b06:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b0a:	854a                	mv	a0,s2
    80003b0c:	00001097          	auipc	ra,0x1
    80003b10:	ade080e7          	jalr	-1314(ra) # 800045ea <releasesleep>
    acquire(&itable.lock);
    80003b14:	0001c517          	auipc	a0,0x1c
    80003b18:	2b450513          	addi	a0,a0,692 # 8001fdc8 <itable>
    80003b1c:	ffffd097          	auipc	ra,0xffffd
    80003b20:	0b4080e7          	jalr	180(ra) # 80000bd0 <acquire>
    80003b24:	b741                	j	80003aa4 <iput+0x26>

0000000080003b26 <iunlockput>:
{
    80003b26:	1101                	addi	sp,sp,-32
    80003b28:	ec06                	sd	ra,24(sp)
    80003b2a:	e822                	sd	s0,16(sp)
    80003b2c:	e426                	sd	s1,8(sp)
    80003b2e:	1000                	addi	s0,sp,32
    80003b30:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b32:	00000097          	auipc	ra,0x0
    80003b36:	e54080e7          	jalr	-428(ra) # 80003986 <iunlock>
  iput(ip);
    80003b3a:	8526                	mv	a0,s1
    80003b3c:	00000097          	auipc	ra,0x0
    80003b40:	f42080e7          	jalr	-190(ra) # 80003a7e <iput>
}
    80003b44:	60e2                	ld	ra,24(sp)
    80003b46:	6442                	ld	s0,16(sp)
    80003b48:	64a2                	ld	s1,8(sp)
    80003b4a:	6105                	addi	sp,sp,32
    80003b4c:	8082                	ret

0000000080003b4e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b4e:	1141                	addi	sp,sp,-16
    80003b50:	e422                	sd	s0,8(sp)
    80003b52:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b54:	411c                	lw	a5,0(a0)
    80003b56:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b58:	415c                	lw	a5,4(a0)
    80003b5a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b5c:	04451783          	lh	a5,68(a0)
    80003b60:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b64:	04a51783          	lh	a5,74(a0)
    80003b68:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b6c:	04c56783          	lwu	a5,76(a0)
    80003b70:	e99c                	sd	a5,16(a1)
}
    80003b72:	6422                	ld	s0,8(sp)
    80003b74:	0141                	addi	sp,sp,16
    80003b76:	8082                	ret

0000000080003b78 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b78:	457c                	lw	a5,76(a0)
    80003b7a:	0ed7e963          	bltu	a5,a3,80003c6c <readi+0xf4>
{
    80003b7e:	7159                	addi	sp,sp,-112
    80003b80:	f486                	sd	ra,104(sp)
    80003b82:	f0a2                	sd	s0,96(sp)
    80003b84:	eca6                	sd	s1,88(sp)
    80003b86:	e8ca                	sd	s2,80(sp)
    80003b88:	e4ce                	sd	s3,72(sp)
    80003b8a:	e0d2                	sd	s4,64(sp)
    80003b8c:	fc56                	sd	s5,56(sp)
    80003b8e:	f85a                	sd	s6,48(sp)
    80003b90:	f45e                	sd	s7,40(sp)
    80003b92:	f062                	sd	s8,32(sp)
    80003b94:	ec66                	sd	s9,24(sp)
    80003b96:	e86a                	sd	s10,16(sp)
    80003b98:	e46e                	sd	s11,8(sp)
    80003b9a:	1880                	addi	s0,sp,112
    80003b9c:	8baa                	mv	s7,a0
    80003b9e:	8c2e                	mv	s8,a1
    80003ba0:	8ab2                	mv	s5,a2
    80003ba2:	84b6                	mv	s1,a3
    80003ba4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ba6:	9f35                	addw	a4,a4,a3
    return 0;
    80003ba8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003baa:	0ad76063          	bltu	a4,a3,80003c4a <readi+0xd2>
  if(off + n > ip->size)
    80003bae:	00e7f463          	bgeu	a5,a4,80003bb6 <readi+0x3e>
    n = ip->size - off;
    80003bb2:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bb6:	0a0b0963          	beqz	s6,80003c68 <readi+0xf0>
    80003bba:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bbc:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003bc0:	5cfd                	li	s9,-1
    80003bc2:	a82d                	j	80003bfc <readi+0x84>
    80003bc4:	020a1d93          	slli	s11,s4,0x20
    80003bc8:	020ddd93          	srli	s11,s11,0x20
    80003bcc:	05890613          	addi	a2,s2,88
    80003bd0:	86ee                	mv	a3,s11
    80003bd2:	963a                	add	a2,a2,a4
    80003bd4:	85d6                	mv	a1,s5
    80003bd6:	8562                	mv	a0,s8
    80003bd8:	fffff097          	auipc	ra,0xfffff
    80003bdc:	95c080e7          	jalr	-1700(ra) # 80002534 <either_copyout>
    80003be0:	05950d63          	beq	a0,s9,80003c3a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003be4:	854a                	mv	a0,s2
    80003be6:	fffff097          	auipc	ra,0xfffff
    80003bea:	60c080e7          	jalr	1548(ra) # 800031f2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bee:	013a09bb          	addw	s3,s4,s3
    80003bf2:	009a04bb          	addw	s1,s4,s1
    80003bf6:	9aee                	add	s5,s5,s11
    80003bf8:	0569f763          	bgeu	s3,s6,80003c46 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003bfc:	000ba903          	lw	s2,0(s7)
    80003c00:	00a4d59b          	srliw	a1,s1,0xa
    80003c04:	855e                	mv	a0,s7
    80003c06:	00000097          	auipc	ra,0x0
    80003c0a:	8ac080e7          	jalr	-1876(ra) # 800034b2 <bmap>
    80003c0e:	0005059b          	sext.w	a1,a0
    80003c12:	854a                	mv	a0,s2
    80003c14:	fffff097          	auipc	ra,0xfffff
    80003c18:	4ae080e7          	jalr	1198(ra) # 800030c2 <bread>
    80003c1c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c1e:	3ff4f713          	andi	a4,s1,1023
    80003c22:	40ed07bb          	subw	a5,s10,a4
    80003c26:	413b06bb          	subw	a3,s6,s3
    80003c2a:	8a3e                	mv	s4,a5
    80003c2c:	2781                	sext.w	a5,a5
    80003c2e:	0006861b          	sext.w	a2,a3
    80003c32:	f8f679e3          	bgeu	a2,a5,80003bc4 <readi+0x4c>
    80003c36:	8a36                	mv	s4,a3
    80003c38:	b771                	j	80003bc4 <readi+0x4c>
      brelse(bp);
    80003c3a:	854a                	mv	a0,s2
    80003c3c:	fffff097          	auipc	ra,0xfffff
    80003c40:	5b6080e7          	jalr	1462(ra) # 800031f2 <brelse>
      tot = -1;
    80003c44:	59fd                	li	s3,-1
  }
  return tot;
    80003c46:	0009851b          	sext.w	a0,s3
}
    80003c4a:	70a6                	ld	ra,104(sp)
    80003c4c:	7406                	ld	s0,96(sp)
    80003c4e:	64e6                	ld	s1,88(sp)
    80003c50:	6946                	ld	s2,80(sp)
    80003c52:	69a6                	ld	s3,72(sp)
    80003c54:	6a06                	ld	s4,64(sp)
    80003c56:	7ae2                	ld	s5,56(sp)
    80003c58:	7b42                	ld	s6,48(sp)
    80003c5a:	7ba2                	ld	s7,40(sp)
    80003c5c:	7c02                	ld	s8,32(sp)
    80003c5e:	6ce2                	ld	s9,24(sp)
    80003c60:	6d42                	ld	s10,16(sp)
    80003c62:	6da2                	ld	s11,8(sp)
    80003c64:	6165                	addi	sp,sp,112
    80003c66:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c68:	89da                	mv	s3,s6
    80003c6a:	bff1                	j	80003c46 <readi+0xce>
    return 0;
    80003c6c:	4501                	li	a0,0
}
    80003c6e:	8082                	ret

0000000080003c70 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c70:	457c                	lw	a5,76(a0)
    80003c72:	10d7e863          	bltu	a5,a3,80003d82 <writei+0x112>
{
    80003c76:	7159                	addi	sp,sp,-112
    80003c78:	f486                	sd	ra,104(sp)
    80003c7a:	f0a2                	sd	s0,96(sp)
    80003c7c:	eca6                	sd	s1,88(sp)
    80003c7e:	e8ca                	sd	s2,80(sp)
    80003c80:	e4ce                	sd	s3,72(sp)
    80003c82:	e0d2                	sd	s4,64(sp)
    80003c84:	fc56                	sd	s5,56(sp)
    80003c86:	f85a                	sd	s6,48(sp)
    80003c88:	f45e                	sd	s7,40(sp)
    80003c8a:	f062                	sd	s8,32(sp)
    80003c8c:	ec66                	sd	s9,24(sp)
    80003c8e:	e86a                	sd	s10,16(sp)
    80003c90:	e46e                	sd	s11,8(sp)
    80003c92:	1880                	addi	s0,sp,112
    80003c94:	8b2a                	mv	s6,a0
    80003c96:	8c2e                	mv	s8,a1
    80003c98:	8ab2                	mv	s5,a2
    80003c9a:	8936                	mv	s2,a3
    80003c9c:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003c9e:	00e687bb          	addw	a5,a3,a4
    80003ca2:	0ed7e263          	bltu	a5,a3,80003d86 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ca6:	00043737          	lui	a4,0x43
    80003caa:	0ef76063          	bltu	a4,a5,80003d8a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cae:	0c0b8863          	beqz	s7,80003d7e <writei+0x10e>
    80003cb2:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cb4:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003cb8:	5cfd                	li	s9,-1
    80003cba:	a091                	j	80003cfe <writei+0x8e>
    80003cbc:	02099d93          	slli	s11,s3,0x20
    80003cc0:	020ddd93          	srli	s11,s11,0x20
    80003cc4:	05848513          	addi	a0,s1,88
    80003cc8:	86ee                	mv	a3,s11
    80003cca:	8656                	mv	a2,s5
    80003ccc:	85e2                	mv	a1,s8
    80003cce:	953a                	add	a0,a0,a4
    80003cd0:	fffff097          	auipc	ra,0xfffff
    80003cd4:	8ba080e7          	jalr	-1862(ra) # 8000258a <either_copyin>
    80003cd8:	07950263          	beq	a0,s9,80003d3c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003cdc:	8526                	mv	a0,s1
    80003cde:	00000097          	auipc	ra,0x0
    80003ce2:	798080e7          	jalr	1944(ra) # 80004476 <log_write>
    brelse(bp);
    80003ce6:	8526                	mv	a0,s1
    80003ce8:	fffff097          	auipc	ra,0xfffff
    80003cec:	50a080e7          	jalr	1290(ra) # 800031f2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cf0:	01498a3b          	addw	s4,s3,s4
    80003cf4:	0129893b          	addw	s2,s3,s2
    80003cf8:	9aee                	add	s5,s5,s11
    80003cfa:	057a7663          	bgeu	s4,s7,80003d46 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003cfe:	000b2483          	lw	s1,0(s6)
    80003d02:	00a9559b          	srliw	a1,s2,0xa
    80003d06:	855a                	mv	a0,s6
    80003d08:	fffff097          	auipc	ra,0xfffff
    80003d0c:	7aa080e7          	jalr	1962(ra) # 800034b2 <bmap>
    80003d10:	0005059b          	sext.w	a1,a0
    80003d14:	8526                	mv	a0,s1
    80003d16:	fffff097          	auipc	ra,0xfffff
    80003d1a:	3ac080e7          	jalr	940(ra) # 800030c2 <bread>
    80003d1e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d20:	3ff97713          	andi	a4,s2,1023
    80003d24:	40ed07bb          	subw	a5,s10,a4
    80003d28:	414b86bb          	subw	a3,s7,s4
    80003d2c:	89be                	mv	s3,a5
    80003d2e:	2781                	sext.w	a5,a5
    80003d30:	0006861b          	sext.w	a2,a3
    80003d34:	f8f674e3          	bgeu	a2,a5,80003cbc <writei+0x4c>
    80003d38:	89b6                	mv	s3,a3
    80003d3a:	b749                	j	80003cbc <writei+0x4c>
      brelse(bp);
    80003d3c:	8526                	mv	a0,s1
    80003d3e:	fffff097          	auipc	ra,0xfffff
    80003d42:	4b4080e7          	jalr	1204(ra) # 800031f2 <brelse>
  }

  if(off > ip->size)
    80003d46:	04cb2783          	lw	a5,76(s6)
    80003d4a:	0127f463          	bgeu	a5,s2,80003d52 <writei+0xe2>
    ip->size = off;
    80003d4e:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d52:	855a                	mv	a0,s6
    80003d54:	00000097          	auipc	ra,0x0
    80003d58:	aa4080e7          	jalr	-1372(ra) # 800037f8 <iupdate>

  return tot;
    80003d5c:	000a051b          	sext.w	a0,s4
}
    80003d60:	70a6                	ld	ra,104(sp)
    80003d62:	7406                	ld	s0,96(sp)
    80003d64:	64e6                	ld	s1,88(sp)
    80003d66:	6946                	ld	s2,80(sp)
    80003d68:	69a6                	ld	s3,72(sp)
    80003d6a:	6a06                	ld	s4,64(sp)
    80003d6c:	7ae2                	ld	s5,56(sp)
    80003d6e:	7b42                	ld	s6,48(sp)
    80003d70:	7ba2                	ld	s7,40(sp)
    80003d72:	7c02                	ld	s8,32(sp)
    80003d74:	6ce2                	ld	s9,24(sp)
    80003d76:	6d42                	ld	s10,16(sp)
    80003d78:	6da2                	ld	s11,8(sp)
    80003d7a:	6165                	addi	sp,sp,112
    80003d7c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d7e:	8a5e                	mv	s4,s7
    80003d80:	bfc9                	j	80003d52 <writei+0xe2>
    return -1;
    80003d82:	557d                	li	a0,-1
}
    80003d84:	8082                	ret
    return -1;
    80003d86:	557d                	li	a0,-1
    80003d88:	bfe1                	j	80003d60 <writei+0xf0>
    return -1;
    80003d8a:	557d                	li	a0,-1
    80003d8c:	bfd1                	j	80003d60 <writei+0xf0>

0000000080003d8e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d8e:	1141                	addi	sp,sp,-16
    80003d90:	e406                	sd	ra,8(sp)
    80003d92:	e022                	sd	s0,0(sp)
    80003d94:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d96:	4639                	li	a2,14
    80003d98:	ffffd097          	auipc	ra,0xffffd
    80003d9c:	004080e7          	jalr	4(ra) # 80000d9c <strncmp>
}
    80003da0:	60a2                	ld	ra,8(sp)
    80003da2:	6402                	ld	s0,0(sp)
    80003da4:	0141                	addi	sp,sp,16
    80003da6:	8082                	ret

0000000080003da8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003da8:	7139                	addi	sp,sp,-64
    80003daa:	fc06                	sd	ra,56(sp)
    80003dac:	f822                	sd	s0,48(sp)
    80003dae:	f426                	sd	s1,40(sp)
    80003db0:	f04a                	sd	s2,32(sp)
    80003db2:	ec4e                	sd	s3,24(sp)
    80003db4:	e852                	sd	s4,16(sp)
    80003db6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003db8:	04451703          	lh	a4,68(a0)
    80003dbc:	4785                	li	a5,1
    80003dbe:	00f71a63          	bne	a4,a5,80003dd2 <dirlookup+0x2a>
    80003dc2:	892a                	mv	s2,a0
    80003dc4:	89ae                	mv	s3,a1
    80003dc6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dc8:	457c                	lw	a5,76(a0)
    80003dca:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003dcc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dce:	e79d                	bnez	a5,80003dfc <dirlookup+0x54>
    80003dd0:	a8a5                	j	80003e48 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003dd2:	00005517          	auipc	a0,0x5
    80003dd6:	81e50513          	addi	a0,a0,-2018 # 800085f0 <syscalls+0x1a8>
    80003dda:	ffffc097          	auipc	ra,0xffffc
    80003dde:	760080e7          	jalr	1888(ra) # 8000053a <panic>
      panic("dirlookup read");
    80003de2:	00005517          	auipc	a0,0x5
    80003de6:	82650513          	addi	a0,a0,-2010 # 80008608 <syscalls+0x1c0>
    80003dea:	ffffc097          	auipc	ra,0xffffc
    80003dee:	750080e7          	jalr	1872(ra) # 8000053a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003df2:	24c1                	addiw	s1,s1,16
    80003df4:	04c92783          	lw	a5,76(s2)
    80003df8:	04f4f763          	bgeu	s1,a5,80003e46 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dfc:	4741                	li	a4,16
    80003dfe:	86a6                	mv	a3,s1
    80003e00:	fc040613          	addi	a2,s0,-64
    80003e04:	4581                	li	a1,0
    80003e06:	854a                	mv	a0,s2
    80003e08:	00000097          	auipc	ra,0x0
    80003e0c:	d70080e7          	jalr	-656(ra) # 80003b78 <readi>
    80003e10:	47c1                	li	a5,16
    80003e12:	fcf518e3          	bne	a0,a5,80003de2 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e16:	fc045783          	lhu	a5,-64(s0)
    80003e1a:	dfe1                	beqz	a5,80003df2 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e1c:	fc240593          	addi	a1,s0,-62
    80003e20:	854e                	mv	a0,s3
    80003e22:	00000097          	auipc	ra,0x0
    80003e26:	f6c080e7          	jalr	-148(ra) # 80003d8e <namecmp>
    80003e2a:	f561                	bnez	a0,80003df2 <dirlookup+0x4a>
      if(poff)
    80003e2c:	000a0463          	beqz	s4,80003e34 <dirlookup+0x8c>
        *poff = off;
    80003e30:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e34:	fc045583          	lhu	a1,-64(s0)
    80003e38:	00092503          	lw	a0,0(s2)
    80003e3c:	fffff097          	auipc	ra,0xfffff
    80003e40:	752080e7          	jalr	1874(ra) # 8000358e <iget>
    80003e44:	a011                	j	80003e48 <dirlookup+0xa0>
  return 0;
    80003e46:	4501                	li	a0,0
}
    80003e48:	70e2                	ld	ra,56(sp)
    80003e4a:	7442                	ld	s0,48(sp)
    80003e4c:	74a2                	ld	s1,40(sp)
    80003e4e:	7902                	ld	s2,32(sp)
    80003e50:	69e2                	ld	s3,24(sp)
    80003e52:	6a42                	ld	s4,16(sp)
    80003e54:	6121                	addi	sp,sp,64
    80003e56:	8082                	ret

0000000080003e58 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e58:	711d                	addi	sp,sp,-96
    80003e5a:	ec86                	sd	ra,88(sp)
    80003e5c:	e8a2                	sd	s0,80(sp)
    80003e5e:	e4a6                	sd	s1,72(sp)
    80003e60:	e0ca                	sd	s2,64(sp)
    80003e62:	fc4e                	sd	s3,56(sp)
    80003e64:	f852                	sd	s4,48(sp)
    80003e66:	f456                	sd	s5,40(sp)
    80003e68:	f05a                	sd	s6,32(sp)
    80003e6a:	ec5e                	sd	s7,24(sp)
    80003e6c:	e862                	sd	s8,16(sp)
    80003e6e:	e466                	sd	s9,8(sp)
    80003e70:	e06a                	sd	s10,0(sp)
    80003e72:	1080                	addi	s0,sp,96
    80003e74:	84aa                	mv	s1,a0
    80003e76:	8b2e                	mv	s6,a1
    80003e78:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e7a:	00054703          	lbu	a4,0(a0)
    80003e7e:	02f00793          	li	a5,47
    80003e82:	02f70363          	beq	a4,a5,80003ea8 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e86:	ffffe097          	auipc	ra,0xffffe
    80003e8a:	b10080e7          	jalr	-1264(ra) # 80001996 <myproc>
    80003e8e:	16053503          	ld	a0,352(a0)
    80003e92:	00000097          	auipc	ra,0x0
    80003e96:	9f4080e7          	jalr	-1548(ra) # 80003886 <idup>
    80003e9a:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e9c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003ea0:	4cb5                	li	s9,13
  len = path - s;
    80003ea2:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ea4:	4c05                	li	s8,1
    80003ea6:	a87d                	j	80003f64 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003ea8:	4585                	li	a1,1
    80003eaa:	4505                	li	a0,1
    80003eac:	fffff097          	auipc	ra,0xfffff
    80003eb0:	6e2080e7          	jalr	1762(ra) # 8000358e <iget>
    80003eb4:	8a2a                	mv	s4,a0
    80003eb6:	b7dd                	j	80003e9c <namex+0x44>
      iunlockput(ip);
    80003eb8:	8552                	mv	a0,s4
    80003eba:	00000097          	auipc	ra,0x0
    80003ebe:	c6c080e7          	jalr	-916(ra) # 80003b26 <iunlockput>
      return 0;
    80003ec2:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ec4:	8552                	mv	a0,s4
    80003ec6:	60e6                	ld	ra,88(sp)
    80003ec8:	6446                	ld	s0,80(sp)
    80003eca:	64a6                	ld	s1,72(sp)
    80003ecc:	6906                	ld	s2,64(sp)
    80003ece:	79e2                	ld	s3,56(sp)
    80003ed0:	7a42                	ld	s4,48(sp)
    80003ed2:	7aa2                	ld	s5,40(sp)
    80003ed4:	7b02                	ld	s6,32(sp)
    80003ed6:	6be2                	ld	s7,24(sp)
    80003ed8:	6c42                	ld	s8,16(sp)
    80003eda:	6ca2                	ld	s9,8(sp)
    80003edc:	6d02                	ld	s10,0(sp)
    80003ede:	6125                	addi	sp,sp,96
    80003ee0:	8082                	ret
      iunlock(ip);
    80003ee2:	8552                	mv	a0,s4
    80003ee4:	00000097          	auipc	ra,0x0
    80003ee8:	aa2080e7          	jalr	-1374(ra) # 80003986 <iunlock>
      return ip;
    80003eec:	bfe1                	j	80003ec4 <namex+0x6c>
      iunlockput(ip);
    80003eee:	8552                	mv	a0,s4
    80003ef0:	00000097          	auipc	ra,0x0
    80003ef4:	c36080e7          	jalr	-970(ra) # 80003b26 <iunlockput>
      return 0;
    80003ef8:	8a4e                	mv	s4,s3
    80003efa:	b7e9                	j	80003ec4 <namex+0x6c>
  len = path - s;
    80003efc:	40998633          	sub	a2,s3,s1
    80003f00:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003f04:	09acd863          	bge	s9,s10,80003f94 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003f08:	4639                	li	a2,14
    80003f0a:	85a6                	mv	a1,s1
    80003f0c:	8556                	mv	a0,s5
    80003f0e:	ffffd097          	auipc	ra,0xffffd
    80003f12:	e1a080e7          	jalr	-486(ra) # 80000d28 <memmove>
    80003f16:	84ce                	mv	s1,s3
  while(*path == '/')
    80003f18:	0004c783          	lbu	a5,0(s1)
    80003f1c:	01279763          	bne	a5,s2,80003f2a <namex+0xd2>
    path++;
    80003f20:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f22:	0004c783          	lbu	a5,0(s1)
    80003f26:	ff278de3          	beq	a5,s2,80003f20 <namex+0xc8>
    ilock(ip);
    80003f2a:	8552                	mv	a0,s4
    80003f2c:	00000097          	auipc	ra,0x0
    80003f30:	998080e7          	jalr	-1640(ra) # 800038c4 <ilock>
    if(ip->type != T_DIR){
    80003f34:	044a1783          	lh	a5,68(s4)
    80003f38:	f98790e3          	bne	a5,s8,80003eb8 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003f3c:	000b0563          	beqz	s6,80003f46 <namex+0xee>
    80003f40:	0004c783          	lbu	a5,0(s1)
    80003f44:	dfd9                	beqz	a5,80003ee2 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f46:	865e                	mv	a2,s7
    80003f48:	85d6                	mv	a1,s5
    80003f4a:	8552                	mv	a0,s4
    80003f4c:	00000097          	auipc	ra,0x0
    80003f50:	e5c080e7          	jalr	-420(ra) # 80003da8 <dirlookup>
    80003f54:	89aa                	mv	s3,a0
    80003f56:	dd41                	beqz	a0,80003eee <namex+0x96>
    iunlockput(ip);
    80003f58:	8552                	mv	a0,s4
    80003f5a:	00000097          	auipc	ra,0x0
    80003f5e:	bcc080e7          	jalr	-1076(ra) # 80003b26 <iunlockput>
    ip = next;
    80003f62:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003f64:	0004c783          	lbu	a5,0(s1)
    80003f68:	01279763          	bne	a5,s2,80003f76 <namex+0x11e>
    path++;
    80003f6c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f6e:	0004c783          	lbu	a5,0(s1)
    80003f72:	ff278de3          	beq	a5,s2,80003f6c <namex+0x114>
  if(*path == 0)
    80003f76:	cb9d                	beqz	a5,80003fac <namex+0x154>
  while(*path != '/' && *path != 0)
    80003f78:	0004c783          	lbu	a5,0(s1)
    80003f7c:	89a6                	mv	s3,s1
  len = path - s;
    80003f7e:	8d5e                	mv	s10,s7
    80003f80:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003f82:	01278963          	beq	a5,s2,80003f94 <namex+0x13c>
    80003f86:	dbbd                	beqz	a5,80003efc <namex+0xa4>
    path++;
    80003f88:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003f8a:	0009c783          	lbu	a5,0(s3)
    80003f8e:	ff279ce3          	bne	a5,s2,80003f86 <namex+0x12e>
    80003f92:	b7ad                	j	80003efc <namex+0xa4>
    memmove(name, s, len);
    80003f94:	2601                	sext.w	a2,a2
    80003f96:	85a6                	mv	a1,s1
    80003f98:	8556                	mv	a0,s5
    80003f9a:	ffffd097          	auipc	ra,0xffffd
    80003f9e:	d8e080e7          	jalr	-626(ra) # 80000d28 <memmove>
    name[len] = 0;
    80003fa2:	9d56                	add	s10,s10,s5
    80003fa4:	000d0023          	sb	zero,0(s10)
    80003fa8:	84ce                	mv	s1,s3
    80003faa:	b7bd                	j	80003f18 <namex+0xc0>
  if(nameiparent){
    80003fac:	f00b0ce3          	beqz	s6,80003ec4 <namex+0x6c>
    iput(ip);
    80003fb0:	8552                	mv	a0,s4
    80003fb2:	00000097          	auipc	ra,0x0
    80003fb6:	acc080e7          	jalr	-1332(ra) # 80003a7e <iput>
    return 0;
    80003fba:	4a01                	li	s4,0
    80003fbc:	b721                	j	80003ec4 <namex+0x6c>

0000000080003fbe <dirlink>:
{
    80003fbe:	7139                	addi	sp,sp,-64
    80003fc0:	fc06                	sd	ra,56(sp)
    80003fc2:	f822                	sd	s0,48(sp)
    80003fc4:	f426                	sd	s1,40(sp)
    80003fc6:	f04a                	sd	s2,32(sp)
    80003fc8:	ec4e                	sd	s3,24(sp)
    80003fca:	e852                	sd	s4,16(sp)
    80003fcc:	0080                	addi	s0,sp,64
    80003fce:	892a                	mv	s2,a0
    80003fd0:	8a2e                	mv	s4,a1
    80003fd2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fd4:	4601                	li	a2,0
    80003fd6:	00000097          	auipc	ra,0x0
    80003fda:	dd2080e7          	jalr	-558(ra) # 80003da8 <dirlookup>
    80003fde:	e93d                	bnez	a0,80004054 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fe0:	04c92483          	lw	s1,76(s2)
    80003fe4:	c49d                	beqz	s1,80004012 <dirlink+0x54>
    80003fe6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fe8:	4741                	li	a4,16
    80003fea:	86a6                	mv	a3,s1
    80003fec:	fc040613          	addi	a2,s0,-64
    80003ff0:	4581                	li	a1,0
    80003ff2:	854a                	mv	a0,s2
    80003ff4:	00000097          	auipc	ra,0x0
    80003ff8:	b84080e7          	jalr	-1148(ra) # 80003b78 <readi>
    80003ffc:	47c1                	li	a5,16
    80003ffe:	06f51163          	bne	a0,a5,80004060 <dirlink+0xa2>
    if(de.inum == 0)
    80004002:	fc045783          	lhu	a5,-64(s0)
    80004006:	c791                	beqz	a5,80004012 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004008:	24c1                	addiw	s1,s1,16
    8000400a:	04c92783          	lw	a5,76(s2)
    8000400e:	fcf4ede3          	bltu	s1,a5,80003fe8 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004012:	4639                	li	a2,14
    80004014:	85d2                	mv	a1,s4
    80004016:	fc240513          	addi	a0,s0,-62
    8000401a:	ffffd097          	auipc	ra,0xffffd
    8000401e:	dbe080e7          	jalr	-578(ra) # 80000dd8 <strncpy>
  de.inum = inum;
    80004022:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004026:	4741                	li	a4,16
    80004028:	86a6                	mv	a3,s1
    8000402a:	fc040613          	addi	a2,s0,-64
    8000402e:	4581                	li	a1,0
    80004030:	854a                	mv	a0,s2
    80004032:	00000097          	auipc	ra,0x0
    80004036:	c3e080e7          	jalr	-962(ra) # 80003c70 <writei>
    8000403a:	872a                	mv	a4,a0
    8000403c:	47c1                	li	a5,16
  return 0;
    8000403e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004040:	02f71863          	bne	a4,a5,80004070 <dirlink+0xb2>
}
    80004044:	70e2                	ld	ra,56(sp)
    80004046:	7442                	ld	s0,48(sp)
    80004048:	74a2                	ld	s1,40(sp)
    8000404a:	7902                	ld	s2,32(sp)
    8000404c:	69e2                	ld	s3,24(sp)
    8000404e:	6a42                	ld	s4,16(sp)
    80004050:	6121                	addi	sp,sp,64
    80004052:	8082                	ret
    iput(ip);
    80004054:	00000097          	auipc	ra,0x0
    80004058:	a2a080e7          	jalr	-1494(ra) # 80003a7e <iput>
    return -1;
    8000405c:	557d                	li	a0,-1
    8000405e:	b7dd                	j	80004044 <dirlink+0x86>
      panic("dirlink read");
    80004060:	00004517          	auipc	a0,0x4
    80004064:	5b850513          	addi	a0,a0,1464 # 80008618 <syscalls+0x1d0>
    80004068:	ffffc097          	auipc	ra,0xffffc
    8000406c:	4d2080e7          	jalr	1234(ra) # 8000053a <panic>
    panic("dirlink");
    80004070:	00004517          	auipc	a0,0x4
    80004074:	6b850513          	addi	a0,a0,1720 # 80008728 <syscalls+0x2e0>
    80004078:	ffffc097          	auipc	ra,0xffffc
    8000407c:	4c2080e7          	jalr	1218(ra) # 8000053a <panic>

0000000080004080 <namei>:

struct inode*
namei(char *path)
{
    80004080:	1101                	addi	sp,sp,-32
    80004082:	ec06                	sd	ra,24(sp)
    80004084:	e822                	sd	s0,16(sp)
    80004086:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004088:	fe040613          	addi	a2,s0,-32
    8000408c:	4581                	li	a1,0
    8000408e:	00000097          	auipc	ra,0x0
    80004092:	dca080e7          	jalr	-566(ra) # 80003e58 <namex>
}
    80004096:	60e2                	ld	ra,24(sp)
    80004098:	6442                	ld	s0,16(sp)
    8000409a:	6105                	addi	sp,sp,32
    8000409c:	8082                	ret

000000008000409e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000409e:	1141                	addi	sp,sp,-16
    800040a0:	e406                	sd	ra,8(sp)
    800040a2:	e022                	sd	s0,0(sp)
    800040a4:	0800                	addi	s0,sp,16
    800040a6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040a8:	4585                	li	a1,1
    800040aa:	00000097          	auipc	ra,0x0
    800040ae:	dae080e7          	jalr	-594(ra) # 80003e58 <namex>
}
    800040b2:	60a2                	ld	ra,8(sp)
    800040b4:	6402                	ld	s0,0(sp)
    800040b6:	0141                	addi	sp,sp,16
    800040b8:	8082                	ret

00000000800040ba <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040ba:	1101                	addi	sp,sp,-32
    800040bc:	ec06                	sd	ra,24(sp)
    800040be:	e822                	sd	s0,16(sp)
    800040c0:	e426                	sd	s1,8(sp)
    800040c2:	e04a                	sd	s2,0(sp)
    800040c4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040c6:	0001d917          	auipc	s2,0x1d
    800040ca:	7aa90913          	addi	s2,s2,1962 # 80021870 <log>
    800040ce:	01892583          	lw	a1,24(s2)
    800040d2:	02892503          	lw	a0,40(s2)
    800040d6:	fffff097          	auipc	ra,0xfffff
    800040da:	fec080e7          	jalr	-20(ra) # 800030c2 <bread>
    800040de:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040e0:	02c92683          	lw	a3,44(s2)
    800040e4:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040e6:	02d05863          	blez	a3,80004116 <write_head+0x5c>
    800040ea:	0001d797          	auipc	a5,0x1d
    800040ee:	7b678793          	addi	a5,a5,1974 # 800218a0 <log+0x30>
    800040f2:	05c50713          	addi	a4,a0,92
    800040f6:	36fd                	addiw	a3,a3,-1
    800040f8:	02069613          	slli	a2,a3,0x20
    800040fc:	01e65693          	srli	a3,a2,0x1e
    80004100:	0001d617          	auipc	a2,0x1d
    80004104:	7a460613          	addi	a2,a2,1956 # 800218a4 <log+0x34>
    80004108:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000410a:	4390                	lw	a2,0(a5)
    8000410c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000410e:	0791                	addi	a5,a5,4
    80004110:	0711                	addi	a4,a4,4
    80004112:	fed79ce3          	bne	a5,a3,8000410a <write_head+0x50>
  }
  bwrite(buf);
    80004116:	8526                	mv	a0,s1
    80004118:	fffff097          	auipc	ra,0xfffff
    8000411c:	09c080e7          	jalr	156(ra) # 800031b4 <bwrite>
  brelse(buf);
    80004120:	8526                	mv	a0,s1
    80004122:	fffff097          	auipc	ra,0xfffff
    80004126:	0d0080e7          	jalr	208(ra) # 800031f2 <brelse>
}
    8000412a:	60e2                	ld	ra,24(sp)
    8000412c:	6442                	ld	s0,16(sp)
    8000412e:	64a2                	ld	s1,8(sp)
    80004130:	6902                	ld	s2,0(sp)
    80004132:	6105                	addi	sp,sp,32
    80004134:	8082                	ret

0000000080004136 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004136:	0001d797          	auipc	a5,0x1d
    8000413a:	7667a783          	lw	a5,1894(a5) # 8002189c <log+0x2c>
    8000413e:	0af05d63          	blez	a5,800041f8 <install_trans+0xc2>
{
    80004142:	7139                	addi	sp,sp,-64
    80004144:	fc06                	sd	ra,56(sp)
    80004146:	f822                	sd	s0,48(sp)
    80004148:	f426                	sd	s1,40(sp)
    8000414a:	f04a                	sd	s2,32(sp)
    8000414c:	ec4e                	sd	s3,24(sp)
    8000414e:	e852                	sd	s4,16(sp)
    80004150:	e456                	sd	s5,8(sp)
    80004152:	e05a                	sd	s6,0(sp)
    80004154:	0080                	addi	s0,sp,64
    80004156:	8b2a                	mv	s6,a0
    80004158:	0001da97          	auipc	s5,0x1d
    8000415c:	748a8a93          	addi	s5,s5,1864 # 800218a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004160:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004162:	0001d997          	auipc	s3,0x1d
    80004166:	70e98993          	addi	s3,s3,1806 # 80021870 <log>
    8000416a:	a00d                	j	8000418c <install_trans+0x56>
    brelse(lbuf);
    8000416c:	854a                	mv	a0,s2
    8000416e:	fffff097          	auipc	ra,0xfffff
    80004172:	084080e7          	jalr	132(ra) # 800031f2 <brelse>
    brelse(dbuf);
    80004176:	8526                	mv	a0,s1
    80004178:	fffff097          	auipc	ra,0xfffff
    8000417c:	07a080e7          	jalr	122(ra) # 800031f2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004180:	2a05                	addiw	s4,s4,1
    80004182:	0a91                	addi	s5,s5,4
    80004184:	02c9a783          	lw	a5,44(s3)
    80004188:	04fa5e63          	bge	s4,a5,800041e4 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000418c:	0189a583          	lw	a1,24(s3)
    80004190:	014585bb          	addw	a1,a1,s4
    80004194:	2585                	addiw	a1,a1,1
    80004196:	0289a503          	lw	a0,40(s3)
    8000419a:	fffff097          	auipc	ra,0xfffff
    8000419e:	f28080e7          	jalr	-216(ra) # 800030c2 <bread>
    800041a2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041a4:	000aa583          	lw	a1,0(s5)
    800041a8:	0289a503          	lw	a0,40(s3)
    800041ac:	fffff097          	auipc	ra,0xfffff
    800041b0:	f16080e7          	jalr	-234(ra) # 800030c2 <bread>
    800041b4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041b6:	40000613          	li	a2,1024
    800041ba:	05890593          	addi	a1,s2,88
    800041be:	05850513          	addi	a0,a0,88
    800041c2:	ffffd097          	auipc	ra,0xffffd
    800041c6:	b66080e7          	jalr	-1178(ra) # 80000d28 <memmove>
    bwrite(dbuf);  // write dst to disk
    800041ca:	8526                	mv	a0,s1
    800041cc:	fffff097          	auipc	ra,0xfffff
    800041d0:	fe8080e7          	jalr	-24(ra) # 800031b4 <bwrite>
    if(recovering == 0)
    800041d4:	f80b1ce3          	bnez	s6,8000416c <install_trans+0x36>
      bunpin(dbuf);
    800041d8:	8526                	mv	a0,s1
    800041da:	fffff097          	auipc	ra,0xfffff
    800041de:	0f2080e7          	jalr	242(ra) # 800032cc <bunpin>
    800041e2:	b769                	j	8000416c <install_trans+0x36>
}
    800041e4:	70e2                	ld	ra,56(sp)
    800041e6:	7442                	ld	s0,48(sp)
    800041e8:	74a2                	ld	s1,40(sp)
    800041ea:	7902                	ld	s2,32(sp)
    800041ec:	69e2                	ld	s3,24(sp)
    800041ee:	6a42                	ld	s4,16(sp)
    800041f0:	6aa2                	ld	s5,8(sp)
    800041f2:	6b02                	ld	s6,0(sp)
    800041f4:	6121                	addi	sp,sp,64
    800041f6:	8082                	ret
    800041f8:	8082                	ret

00000000800041fa <initlog>:
{
    800041fa:	7179                	addi	sp,sp,-48
    800041fc:	f406                	sd	ra,40(sp)
    800041fe:	f022                	sd	s0,32(sp)
    80004200:	ec26                	sd	s1,24(sp)
    80004202:	e84a                	sd	s2,16(sp)
    80004204:	e44e                	sd	s3,8(sp)
    80004206:	1800                	addi	s0,sp,48
    80004208:	892a                	mv	s2,a0
    8000420a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000420c:	0001d497          	auipc	s1,0x1d
    80004210:	66448493          	addi	s1,s1,1636 # 80021870 <log>
    80004214:	00004597          	auipc	a1,0x4
    80004218:	41458593          	addi	a1,a1,1044 # 80008628 <syscalls+0x1e0>
    8000421c:	8526                	mv	a0,s1
    8000421e:	ffffd097          	auipc	ra,0xffffd
    80004222:	922080e7          	jalr	-1758(ra) # 80000b40 <initlock>
  log.start = sb->logstart;
    80004226:	0149a583          	lw	a1,20(s3)
    8000422a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000422c:	0109a783          	lw	a5,16(s3)
    80004230:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004232:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004236:	854a                	mv	a0,s2
    80004238:	fffff097          	auipc	ra,0xfffff
    8000423c:	e8a080e7          	jalr	-374(ra) # 800030c2 <bread>
  log.lh.n = lh->n;
    80004240:	4d34                	lw	a3,88(a0)
    80004242:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004244:	02d05663          	blez	a3,80004270 <initlog+0x76>
    80004248:	05c50793          	addi	a5,a0,92
    8000424c:	0001d717          	auipc	a4,0x1d
    80004250:	65470713          	addi	a4,a4,1620 # 800218a0 <log+0x30>
    80004254:	36fd                	addiw	a3,a3,-1
    80004256:	02069613          	slli	a2,a3,0x20
    8000425a:	01e65693          	srli	a3,a2,0x1e
    8000425e:	06050613          	addi	a2,a0,96
    80004262:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004264:	4390                	lw	a2,0(a5)
    80004266:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004268:	0791                	addi	a5,a5,4
    8000426a:	0711                	addi	a4,a4,4
    8000426c:	fed79ce3          	bne	a5,a3,80004264 <initlog+0x6a>
  brelse(buf);
    80004270:	fffff097          	auipc	ra,0xfffff
    80004274:	f82080e7          	jalr	-126(ra) # 800031f2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004278:	4505                	li	a0,1
    8000427a:	00000097          	auipc	ra,0x0
    8000427e:	ebc080e7          	jalr	-324(ra) # 80004136 <install_trans>
  log.lh.n = 0;
    80004282:	0001d797          	auipc	a5,0x1d
    80004286:	6007ad23          	sw	zero,1562(a5) # 8002189c <log+0x2c>
  write_head(); // clear the log
    8000428a:	00000097          	auipc	ra,0x0
    8000428e:	e30080e7          	jalr	-464(ra) # 800040ba <write_head>
}
    80004292:	70a2                	ld	ra,40(sp)
    80004294:	7402                	ld	s0,32(sp)
    80004296:	64e2                	ld	s1,24(sp)
    80004298:	6942                	ld	s2,16(sp)
    8000429a:	69a2                	ld	s3,8(sp)
    8000429c:	6145                	addi	sp,sp,48
    8000429e:	8082                	ret

00000000800042a0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042a0:	1101                	addi	sp,sp,-32
    800042a2:	ec06                	sd	ra,24(sp)
    800042a4:	e822                	sd	s0,16(sp)
    800042a6:	e426                	sd	s1,8(sp)
    800042a8:	e04a                	sd	s2,0(sp)
    800042aa:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042ac:	0001d517          	auipc	a0,0x1d
    800042b0:	5c450513          	addi	a0,a0,1476 # 80021870 <log>
    800042b4:	ffffd097          	auipc	ra,0xffffd
    800042b8:	91c080e7          	jalr	-1764(ra) # 80000bd0 <acquire>
  while(1){
    if(log.committing){
    800042bc:	0001d497          	auipc	s1,0x1d
    800042c0:	5b448493          	addi	s1,s1,1460 # 80021870 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042c4:	4979                	li	s2,30
    800042c6:	a039                	j	800042d4 <begin_op+0x34>
      sleep(&log, &log.lock);
    800042c8:	85a6                	mv	a1,s1
    800042ca:	8526                	mv	a0,s1
    800042cc:	ffffe097          	auipc	ra,0xffffe
    800042d0:	e98080e7          	jalr	-360(ra) # 80002164 <sleep>
    if(log.committing){
    800042d4:	50dc                	lw	a5,36(s1)
    800042d6:	fbed                	bnez	a5,800042c8 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042d8:	5098                	lw	a4,32(s1)
    800042da:	2705                	addiw	a4,a4,1
    800042dc:	0007069b          	sext.w	a3,a4
    800042e0:	0027179b          	slliw	a5,a4,0x2
    800042e4:	9fb9                	addw	a5,a5,a4
    800042e6:	0017979b          	slliw	a5,a5,0x1
    800042ea:	54d8                	lw	a4,44(s1)
    800042ec:	9fb9                	addw	a5,a5,a4
    800042ee:	00f95963          	bge	s2,a5,80004300 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800042f2:	85a6                	mv	a1,s1
    800042f4:	8526                	mv	a0,s1
    800042f6:	ffffe097          	auipc	ra,0xffffe
    800042fa:	e6e080e7          	jalr	-402(ra) # 80002164 <sleep>
    800042fe:	bfd9                	j	800042d4 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004300:	0001d517          	auipc	a0,0x1d
    80004304:	57050513          	addi	a0,a0,1392 # 80021870 <log>
    80004308:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000430a:	ffffd097          	auipc	ra,0xffffd
    8000430e:	97a080e7          	jalr	-1670(ra) # 80000c84 <release>
      break;
    }
  }
}
    80004312:	60e2                	ld	ra,24(sp)
    80004314:	6442                	ld	s0,16(sp)
    80004316:	64a2                	ld	s1,8(sp)
    80004318:	6902                	ld	s2,0(sp)
    8000431a:	6105                	addi	sp,sp,32
    8000431c:	8082                	ret

000000008000431e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000431e:	7139                	addi	sp,sp,-64
    80004320:	fc06                	sd	ra,56(sp)
    80004322:	f822                	sd	s0,48(sp)
    80004324:	f426                	sd	s1,40(sp)
    80004326:	f04a                	sd	s2,32(sp)
    80004328:	ec4e                	sd	s3,24(sp)
    8000432a:	e852                	sd	s4,16(sp)
    8000432c:	e456                	sd	s5,8(sp)
    8000432e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004330:	0001d497          	auipc	s1,0x1d
    80004334:	54048493          	addi	s1,s1,1344 # 80021870 <log>
    80004338:	8526                	mv	a0,s1
    8000433a:	ffffd097          	auipc	ra,0xffffd
    8000433e:	896080e7          	jalr	-1898(ra) # 80000bd0 <acquire>
  log.outstanding -= 1;
    80004342:	509c                	lw	a5,32(s1)
    80004344:	37fd                	addiw	a5,a5,-1
    80004346:	0007891b          	sext.w	s2,a5
    8000434a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000434c:	50dc                	lw	a5,36(s1)
    8000434e:	e7b9                	bnez	a5,8000439c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004350:	04091e63          	bnez	s2,800043ac <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004354:	0001d497          	auipc	s1,0x1d
    80004358:	51c48493          	addi	s1,s1,1308 # 80021870 <log>
    8000435c:	4785                	li	a5,1
    8000435e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004360:	8526                	mv	a0,s1
    80004362:	ffffd097          	auipc	ra,0xffffd
    80004366:	922080e7          	jalr	-1758(ra) # 80000c84 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000436a:	54dc                	lw	a5,44(s1)
    8000436c:	06f04763          	bgtz	a5,800043da <end_op+0xbc>
    acquire(&log.lock);
    80004370:	0001d497          	auipc	s1,0x1d
    80004374:	50048493          	addi	s1,s1,1280 # 80021870 <log>
    80004378:	8526                	mv	a0,s1
    8000437a:	ffffd097          	auipc	ra,0xffffd
    8000437e:	856080e7          	jalr	-1962(ra) # 80000bd0 <acquire>
    log.committing = 0;
    80004382:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004386:	8526                	mv	a0,s1
    80004388:	ffffe097          	auipc	ra,0xffffe
    8000438c:	f68080e7          	jalr	-152(ra) # 800022f0 <wakeup>
    release(&log.lock);
    80004390:	8526                	mv	a0,s1
    80004392:	ffffd097          	auipc	ra,0xffffd
    80004396:	8f2080e7          	jalr	-1806(ra) # 80000c84 <release>
}
    8000439a:	a03d                	j	800043c8 <end_op+0xaa>
    panic("log.committing");
    8000439c:	00004517          	auipc	a0,0x4
    800043a0:	29450513          	addi	a0,a0,660 # 80008630 <syscalls+0x1e8>
    800043a4:	ffffc097          	auipc	ra,0xffffc
    800043a8:	196080e7          	jalr	406(ra) # 8000053a <panic>
    wakeup(&log);
    800043ac:	0001d497          	auipc	s1,0x1d
    800043b0:	4c448493          	addi	s1,s1,1220 # 80021870 <log>
    800043b4:	8526                	mv	a0,s1
    800043b6:	ffffe097          	auipc	ra,0xffffe
    800043ba:	f3a080e7          	jalr	-198(ra) # 800022f0 <wakeup>
  release(&log.lock);
    800043be:	8526                	mv	a0,s1
    800043c0:	ffffd097          	auipc	ra,0xffffd
    800043c4:	8c4080e7          	jalr	-1852(ra) # 80000c84 <release>
}
    800043c8:	70e2                	ld	ra,56(sp)
    800043ca:	7442                	ld	s0,48(sp)
    800043cc:	74a2                	ld	s1,40(sp)
    800043ce:	7902                	ld	s2,32(sp)
    800043d0:	69e2                	ld	s3,24(sp)
    800043d2:	6a42                	ld	s4,16(sp)
    800043d4:	6aa2                	ld	s5,8(sp)
    800043d6:	6121                	addi	sp,sp,64
    800043d8:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800043da:	0001da97          	auipc	s5,0x1d
    800043de:	4c6a8a93          	addi	s5,s5,1222 # 800218a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800043e2:	0001da17          	auipc	s4,0x1d
    800043e6:	48ea0a13          	addi	s4,s4,1166 # 80021870 <log>
    800043ea:	018a2583          	lw	a1,24(s4)
    800043ee:	012585bb          	addw	a1,a1,s2
    800043f2:	2585                	addiw	a1,a1,1
    800043f4:	028a2503          	lw	a0,40(s4)
    800043f8:	fffff097          	auipc	ra,0xfffff
    800043fc:	cca080e7          	jalr	-822(ra) # 800030c2 <bread>
    80004400:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004402:	000aa583          	lw	a1,0(s5)
    80004406:	028a2503          	lw	a0,40(s4)
    8000440a:	fffff097          	auipc	ra,0xfffff
    8000440e:	cb8080e7          	jalr	-840(ra) # 800030c2 <bread>
    80004412:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004414:	40000613          	li	a2,1024
    80004418:	05850593          	addi	a1,a0,88
    8000441c:	05848513          	addi	a0,s1,88
    80004420:	ffffd097          	auipc	ra,0xffffd
    80004424:	908080e7          	jalr	-1784(ra) # 80000d28 <memmove>
    bwrite(to);  // write the log
    80004428:	8526                	mv	a0,s1
    8000442a:	fffff097          	auipc	ra,0xfffff
    8000442e:	d8a080e7          	jalr	-630(ra) # 800031b4 <bwrite>
    brelse(from);
    80004432:	854e                	mv	a0,s3
    80004434:	fffff097          	auipc	ra,0xfffff
    80004438:	dbe080e7          	jalr	-578(ra) # 800031f2 <brelse>
    brelse(to);
    8000443c:	8526                	mv	a0,s1
    8000443e:	fffff097          	auipc	ra,0xfffff
    80004442:	db4080e7          	jalr	-588(ra) # 800031f2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004446:	2905                	addiw	s2,s2,1
    80004448:	0a91                	addi	s5,s5,4
    8000444a:	02ca2783          	lw	a5,44(s4)
    8000444e:	f8f94ee3          	blt	s2,a5,800043ea <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004452:	00000097          	auipc	ra,0x0
    80004456:	c68080e7          	jalr	-920(ra) # 800040ba <write_head>
    install_trans(0); // Now install writes to home locations
    8000445a:	4501                	li	a0,0
    8000445c:	00000097          	auipc	ra,0x0
    80004460:	cda080e7          	jalr	-806(ra) # 80004136 <install_trans>
    log.lh.n = 0;
    80004464:	0001d797          	auipc	a5,0x1d
    80004468:	4207ac23          	sw	zero,1080(a5) # 8002189c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000446c:	00000097          	auipc	ra,0x0
    80004470:	c4e080e7          	jalr	-946(ra) # 800040ba <write_head>
    80004474:	bdf5                	j	80004370 <end_op+0x52>

0000000080004476 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004476:	1101                	addi	sp,sp,-32
    80004478:	ec06                	sd	ra,24(sp)
    8000447a:	e822                	sd	s0,16(sp)
    8000447c:	e426                	sd	s1,8(sp)
    8000447e:	e04a                	sd	s2,0(sp)
    80004480:	1000                	addi	s0,sp,32
    80004482:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004484:	0001d917          	auipc	s2,0x1d
    80004488:	3ec90913          	addi	s2,s2,1004 # 80021870 <log>
    8000448c:	854a                	mv	a0,s2
    8000448e:	ffffc097          	auipc	ra,0xffffc
    80004492:	742080e7          	jalr	1858(ra) # 80000bd0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004496:	02c92603          	lw	a2,44(s2)
    8000449a:	47f5                	li	a5,29
    8000449c:	06c7c563          	blt	a5,a2,80004506 <log_write+0x90>
    800044a0:	0001d797          	auipc	a5,0x1d
    800044a4:	3ec7a783          	lw	a5,1004(a5) # 8002188c <log+0x1c>
    800044a8:	37fd                	addiw	a5,a5,-1
    800044aa:	04f65e63          	bge	a2,a5,80004506 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044ae:	0001d797          	auipc	a5,0x1d
    800044b2:	3e27a783          	lw	a5,994(a5) # 80021890 <log+0x20>
    800044b6:	06f05063          	blez	a5,80004516 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800044ba:	4781                	li	a5,0
    800044bc:	06c05563          	blez	a2,80004526 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044c0:	44cc                	lw	a1,12(s1)
    800044c2:	0001d717          	auipc	a4,0x1d
    800044c6:	3de70713          	addi	a4,a4,990 # 800218a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800044ca:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044cc:	4314                	lw	a3,0(a4)
    800044ce:	04b68c63          	beq	a3,a1,80004526 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800044d2:	2785                	addiw	a5,a5,1
    800044d4:	0711                	addi	a4,a4,4
    800044d6:	fef61be3          	bne	a2,a5,800044cc <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800044da:	0621                	addi	a2,a2,8
    800044dc:	060a                	slli	a2,a2,0x2
    800044de:	0001d797          	auipc	a5,0x1d
    800044e2:	39278793          	addi	a5,a5,914 # 80021870 <log>
    800044e6:	97b2                	add	a5,a5,a2
    800044e8:	44d8                	lw	a4,12(s1)
    800044ea:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800044ec:	8526                	mv	a0,s1
    800044ee:	fffff097          	auipc	ra,0xfffff
    800044f2:	da2080e7          	jalr	-606(ra) # 80003290 <bpin>
    log.lh.n++;
    800044f6:	0001d717          	auipc	a4,0x1d
    800044fa:	37a70713          	addi	a4,a4,890 # 80021870 <log>
    800044fe:	575c                	lw	a5,44(a4)
    80004500:	2785                	addiw	a5,a5,1
    80004502:	d75c                	sw	a5,44(a4)
    80004504:	a82d                	j	8000453e <log_write+0xc8>
    panic("too big a transaction");
    80004506:	00004517          	auipc	a0,0x4
    8000450a:	13a50513          	addi	a0,a0,314 # 80008640 <syscalls+0x1f8>
    8000450e:	ffffc097          	auipc	ra,0xffffc
    80004512:	02c080e7          	jalr	44(ra) # 8000053a <panic>
    panic("log_write outside of trans");
    80004516:	00004517          	auipc	a0,0x4
    8000451a:	14250513          	addi	a0,a0,322 # 80008658 <syscalls+0x210>
    8000451e:	ffffc097          	auipc	ra,0xffffc
    80004522:	01c080e7          	jalr	28(ra) # 8000053a <panic>
  log.lh.block[i] = b->blockno;
    80004526:	00878693          	addi	a3,a5,8
    8000452a:	068a                	slli	a3,a3,0x2
    8000452c:	0001d717          	auipc	a4,0x1d
    80004530:	34470713          	addi	a4,a4,836 # 80021870 <log>
    80004534:	9736                	add	a4,a4,a3
    80004536:	44d4                	lw	a3,12(s1)
    80004538:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000453a:	faf609e3          	beq	a2,a5,800044ec <log_write+0x76>
  }
  release(&log.lock);
    8000453e:	0001d517          	auipc	a0,0x1d
    80004542:	33250513          	addi	a0,a0,818 # 80021870 <log>
    80004546:	ffffc097          	auipc	ra,0xffffc
    8000454a:	73e080e7          	jalr	1854(ra) # 80000c84 <release>
}
    8000454e:	60e2                	ld	ra,24(sp)
    80004550:	6442                	ld	s0,16(sp)
    80004552:	64a2                	ld	s1,8(sp)
    80004554:	6902                	ld	s2,0(sp)
    80004556:	6105                	addi	sp,sp,32
    80004558:	8082                	ret

000000008000455a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000455a:	1101                	addi	sp,sp,-32
    8000455c:	ec06                	sd	ra,24(sp)
    8000455e:	e822                	sd	s0,16(sp)
    80004560:	e426                	sd	s1,8(sp)
    80004562:	e04a                	sd	s2,0(sp)
    80004564:	1000                	addi	s0,sp,32
    80004566:	84aa                	mv	s1,a0
    80004568:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000456a:	00004597          	auipc	a1,0x4
    8000456e:	10e58593          	addi	a1,a1,270 # 80008678 <syscalls+0x230>
    80004572:	0521                	addi	a0,a0,8
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	5cc080e7          	jalr	1484(ra) # 80000b40 <initlock>
  lk->name = name;
    8000457c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004580:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004584:	0204a423          	sw	zero,40(s1)
}
    80004588:	60e2                	ld	ra,24(sp)
    8000458a:	6442                	ld	s0,16(sp)
    8000458c:	64a2                	ld	s1,8(sp)
    8000458e:	6902                	ld	s2,0(sp)
    80004590:	6105                	addi	sp,sp,32
    80004592:	8082                	ret

0000000080004594 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004594:	1101                	addi	sp,sp,-32
    80004596:	ec06                	sd	ra,24(sp)
    80004598:	e822                	sd	s0,16(sp)
    8000459a:	e426                	sd	s1,8(sp)
    8000459c:	e04a                	sd	s2,0(sp)
    8000459e:	1000                	addi	s0,sp,32
    800045a0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045a2:	00850913          	addi	s2,a0,8
    800045a6:	854a                	mv	a0,s2
    800045a8:	ffffc097          	auipc	ra,0xffffc
    800045ac:	628080e7          	jalr	1576(ra) # 80000bd0 <acquire>
  while (lk->locked) {
    800045b0:	409c                	lw	a5,0(s1)
    800045b2:	cb89                	beqz	a5,800045c4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045b4:	85ca                	mv	a1,s2
    800045b6:	8526                	mv	a0,s1
    800045b8:	ffffe097          	auipc	ra,0xffffe
    800045bc:	bac080e7          	jalr	-1108(ra) # 80002164 <sleep>
  while (lk->locked) {
    800045c0:	409c                	lw	a5,0(s1)
    800045c2:	fbed                	bnez	a5,800045b4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045c4:	4785                	li	a5,1
    800045c6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045c8:	ffffd097          	auipc	ra,0xffffd
    800045cc:	3ce080e7          	jalr	974(ra) # 80001996 <myproc>
    800045d0:	591c                	lw	a5,48(a0)
    800045d2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800045d4:	854a                	mv	a0,s2
    800045d6:	ffffc097          	auipc	ra,0xffffc
    800045da:	6ae080e7          	jalr	1710(ra) # 80000c84 <release>
}
    800045de:	60e2                	ld	ra,24(sp)
    800045e0:	6442                	ld	s0,16(sp)
    800045e2:	64a2                	ld	s1,8(sp)
    800045e4:	6902                	ld	s2,0(sp)
    800045e6:	6105                	addi	sp,sp,32
    800045e8:	8082                	ret

00000000800045ea <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045ea:	1101                	addi	sp,sp,-32
    800045ec:	ec06                	sd	ra,24(sp)
    800045ee:	e822                	sd	s0,16(sp)
    800045f0:	e426                	sd	s1,8(sp)
    800045f2:	e04a                	sd	s2,0(sp)
    800045f4:	1000                	addi	s0,sp,32
    800045f6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045f8:	00850913          	addi	s2,a0,8
    800045fc:	854a                	mv	a0,s2
    800045fe:	ffffc097          	auipc	ra,0xffffc
    80004602:	5d2080e7          	jalr	1490(ra) # 80000bd0 <acquire>
  lk->locked = 0;
    80004606:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000460a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000460e:	8526                	mv	a0,s1
    80004610:	ffffe097          	auipc	ra,0xffffe
    80004614:	ce0080e7          	jalr	-800(ra) # 800022f0 <wakeup>
  release(&lk->lk);
    80004618:	854a                	mv	a0,s2
    8000461a:	ffffc097          	auipc	ra,0xffffc
    8000461e:	66a080e7          	jalr	1642(ra) # 80000c84 <release>
}
    80004622:	60e2                	ld	ra,24(sp)
    80004624:	6442                	ld	s0,16(sp)
    80004626:	64a2                	ld	s1,8(sp)
    80004628:	6902                	ld	s2,0(sp)
    8000462a:	6105                	addi	sp,sp,32
    8000462c:	8082                	ret

000000008000462e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000462e:	7179                	addi	sp,sp,-48
    80004630:	f406                	sd	ra,40(sp)
    80004632:	f022                	sd	s0,32(sp)
    80004634:	ec26                	sd	s1,24(sp)
    80004636:	e84a                	sd	s2,16(sp)
    80004638:	e44e                	sd	s3,8(sp)
    8000463a:	1800                	addi	s0,sp,48
    8000463c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000463e:	00850913          	addi	s2,a0,8
    80004642:	854a                	mv	a0,s2
    80004644:	ffffc097          	auipc	ra,0xffffc
    80004648:	58c080e7          	jalr	1420(ra) # 80000bd0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000464c:	409c                	lw	a5,0(s1)
    8000464e:	ef99                	bnez	a5,8000466c <holdingsleep+0x3e>
    80004650:	4481                	li	s1,0
  release(&lk->lk);
    80004652:	854a                	mv	a0,s2
    80004654:	ffffc097          	auipc	ra,0xffffc
    80004658:	630080e7          	jalr	1584(ra) # 80000c84 <release>
  return r;
}
    8000465c:	8526                	mv	a0,s1
    8000465e:	70a2                	ld	ra,40(sp)
    80004660:	7402                	ld	s0,32(sp)
    80004662:	64e2                	ld	s1,24(sp)
    80004664:	6942                	ld	s2,16(sp)
    80004666:	69a2                	ld	s3,8(sp)
    80004668:	6145                	addi	sp,sp,48
    8000466a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000466c:	0284a983          	lw	s3,40(s1)
    80004670:	ffffd097          	auipc	ra,0xffffd
    80004674:	326080e7          	jalr	806(ra) # 80001996 <myproc>
    80004678:	5904                	lw	s1,48(a0)
    8000467a:	413484b3          	sub	s1,s1,s3
    8000467e:	0014b493          	seqz	s1,s1
    80004682:	bfc1                	j	80004652 <holdingsleep+0x24>

0000000080004684 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004684:	1141                	addi	sp,sp,-16
    80004686:	e406                	sd	ra,8(sp)
    80004688:	e022                	sd	s0,0(sp)
    8000468a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000468c:	00004597          	auipc	a1,0x4
    80004690:	ffc58593          	addi	a1,a1,-4 # 80008688 <syscalls+0x240>
    80004694:	0001d517          	auipc	a0,0x1d
    80004698:	32450513          	addi	a0,a0,804 # 800219b8 <ftable>
    8000469c:	ffffc097          	auipc	ra,0xffffc
    800046a0:	4a4080e7          	jalr	1188(ra) # 80000b40 <initlock>
}
    800046a4:	60a2                	ld	ra,8(sp)
    800046a6:	6402                	ld	s0,0(sp)
    800046a8:	0141                	addi	sp,sp,16
    800046aa:	8082                	ret

00000000800046ac <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046ac:	1101                	addi	sp,sp,-32
    800046ae:	ec06                	sd	ra,24(sp)
    800046b0:	e822                	sd	s0,16(sp)
    800046b2:	e426                	sd	s1,8(sp)
    800046b4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046b6:	0001d517          	auipc	a0,0x1d
    800046ba:	30250513          	addi	a0,a0,770 # 800219b8 <ftable>
    800046be:	ffffc097          	auipc	ra,0xffffc
    800046c2:	512080e7          	jalr	1298(ra) # 80000bd0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046c6:	0001d497          	auipc	s1,0x1d
    800046ca:	30a48493          	addi	s1,s1,778 # 800219d0 <ftable+0x18>
    800046ce:	0001e717          	auipc	a4,0x1e
    800046d2:	2a270713          	addi	a4,a4,674 # 80022970 <ftable+0xfb8>
    if(f->ref == 0){
    800046d6:	40dc                	lw	a5,4(s1)
    800046d8:	cf99                	beqz	a5,800046f6 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046da:	02848493          	addi	s1,s1,40
    800046de:	fee49ce3          	bne	s1,a4,800046d6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046e2:	0001d517          	auipc	a0,0x1d
    800046e6:	2d650513          	addi	a0,a0,726 # 800219b8 <ftable>
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	59a080e7          	jalr	1434(ra) # 80000c84 <release>
  return 0;
    800046f2:	4481                	li	s1,0
    800046f4:	a819                	j	8000470a <filealloc+0x5e>
      f->ref = 1;
    800046f6:	4785                	li	a5,1
    800046f8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046fa:	0001d517          	auipc	a0,0x1d
    800046fe:	2be50513          	addi	a0,a0,702 # 800219b8 <ftable>
    80004702:	ffffc097          	auipc	ra,0xffffc
    80004706:	582080e7          	jalr	1410(ra) # 80000c84 <release>
}
    8000470a:	8526                	mv	a0,s1
    8000470c:	60e2                	ld	ra,24(sp)
    8000470e:	6442                	ld	s0,16(sp)
    80004710:	64a2                	ld	s1,8(sp)
    80004712:	6105                	addi	sp,sp,32
    80004714:	8082                	ret

0000000080004716 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004716:	1101                	addi	sp,sp,-32
    80004718:	ec06                	sd	ra,24(sp)
    8000471a:	e822                	sd	s0,16(sp)
    8000471c:	e426                	sd	s1,8(sp)
    8000471e:	1000                	addi	s0,sp,32
    80004720:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004722:	0001d517          	auipc	a0,0x1d
    80004726:	29650513          	addi	a0,a0,662 # 800219b8 <ftable>
    8000472a:	ffffc097          	auipc	ra,0xffffc
    8000472e:	4a6080e7          	jalr	1190(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    80004732:	40dc                	lw	a5,4(s1)
    80004734:	02f05263          	blez	a5,80004758 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004738:	2785                	addiw	a5,a5,1
    8000473a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000473c:	0001d517          	auipc	a0,0x1d
    80004740:	27c50513          	addi	a0,a0,636 # 800219b8 <ftable>
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	540080e7          	jalr	1344(ra) # 80000c84 <release>
  return f;
}
    8000474c:	8526                	mv	a0,s1
    8000474e:	60e2                	ld	ra,24(sp)
    80004750:	6442                	ld	s0,16(sp)
    80004752:	64a2                	ld	s1,8(sp)
    80004754:	6105                	addi	sp,sp,32
    80004756:	8082                	ret
    panic("filedup");
    80004758:	00004517          	auipc	a0,0x4
    8000475c:	f3850513          	addi	a0,a0,-200 # 80008690 <syscalls+0x248>
    80004760:	ffffc097          	auipc	ra,0xffffc
    80004764:	dda080e7          	jalr	-550(ra) # 8000053a <panic>

0000000080004768 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004768:	7139                	addi	sp,sp,-64
    8000476a:	fc06                	sd	ra,56(sp)
    8000476c:	f822                	sd	s0,48(sp)
    8000476e:	f426                	sd	s1,40(sp)
    80004770:	f04a                	sd	s2,32(sp)
    80004772:	ec4e                	sd	s3,24(sp)
    80004774:	e852                	sd	s4,16(sp)
    80004776:	e456                	sd	s5,8(sp)
    80004778:	0080                	addi	s0,sp,64
    8000477a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000477c:	0001d517          	auipc	a0,0x1d
    80004780:	23c50513          	addi	a0,a0,572 # 800219b8 <ftable>
    80004784:	ffffc097          	auipc	ra,0xffffc
    80004788:	44c080e7          	jalr	1100(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    8000478c:	40dc                	lw	a5,4(s1)
    8000478e:	06f05163          	blez	a5,800047f0 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004792:	37fd                	addiw	a5,a5,-1
    80004794:	0007871b          	sext.w	a4,a5
    80004798:	c0dc                	sw	a5,4(s1)
    8000479a:	06e04363          	bgtz	a4,80004800 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000479e:	0004a903          	lw	s2,0(s1)
    800047a2:	0094ca83          	lbu	s5,9(s1)
    800047a6:	0104ba03          	ld	s4,16(s1)
    800047aa:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047ae:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047b2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047b6:	0001d517          	auipc	a0,0x1d
    800047ba:	20250513          	addi	a0,a0,514 # 800219b8 <ftable>
    800047be:	ffffc097          	auipc	ra,0xffffc
    800047c2:	4c6080e7          	jalr	1222(ra) # 80000c84 <release>

  if(ff.type == FD_PIPE){
    800047c6:	4785                	li	a5,1
    800047c8:	04f90d63          	beq	s2,a5,80004822 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047cc:	3979                	addiw	s2,s2,-2
    800047ce:	4785                	li	a5,1
    800047d0:	0527e063          	bltu	a5,s2,80004810 <fileclose+0xa8>
    begin_op();
    800047d4:	00000097          	auipc	ra,0x0
    800047d8:	acc080e7          	jalr	-1332(ra) # 800042a0 <begin_op>
    iput(ff.ip);
    800047dc:	854e                	mv	a0,s3
    800047de:	fffff097          	auipc	ra,0xfffff
    800047e2:	2a0080e7          	jalr	672(ra) # 80003a7e <iput>
    end_op();
    800047e6:	00000097          	auipc	ra,0x0
    800047ea:	b38080e7          	jalr	-1224(ra) # 8000431e <end_op>
    800047ee:	a00d                	j	80004810 <fileclose+0xa8>
    panic("fileclose");
    800047f0:	00004517          	auipc	a0,0x4
    800047f4:	ea850513          	addi	a0,a0,-344 # 80008698 <syscalls+0x250>
    800047f8:	ffffc097          	auipc	ra,0xffffc
    800047fc:	d42080e7          	jalr	-702(ra) # 8000053a <panic>
    release(&ftable.lock);
    80004800:	0001d517          	auipc	a0,0x1d
    80004804:	1b850513          	addi	a0,a0,440 # 800219b8 <ftable>
    80004808:	ffffc097          	auipc	ra,0xffffc
    8000480c:	47c080e7          	jalr	1148(ra) # 80000c84 <release>
  }
}
    80004810:	70e2                	ld	ra,56(sp)
    80004812:	7442                	ld	s0,48(sp)
    80004814:	74a2                	ld	s1,40(sp)
    80004816:	7902                	ld	s2,32(sp)
    80004818:	69e2                	ld	s3,24(sp)
    8000481a:	6a42                	ld	s4,16(sp)
    8000481c:	6aa2                	ld	s5,8(sp)
    8000481e:	6121                	addi	sp,sp,64
    80004820:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004822:	85d6                	mv	a1,s5
    80004824:	8552                	mv	a0,s4
    80004826:	00000097          	auipc	ra,0x0
    8000482a:	34c080e7          	jalr	844(ra) # 80004b72 <pipeclose>
    8000482e:	b7cd                	j	80004810 <fileclose+0xa8>

0000000080004830 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004830:	715d                	addi	sp,sp,-80
    80004832:	e486                	sd	ra,72(sp)
    80004834:	e0a2                	sd	s0,64(sp)
    80004836:	fc26                	sd	s1,56(sp)
    80004838:	f84a                	sd	s2,48(sp)
    8000483a:	f44e                	sd	s3,40(sp)
    8000483c:	0880                	addi	s0,sp,80
    8000483e:	84aa                	mv	s1,a0
    80004840:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004842:	ffffd097          	auipc	ra,0xffffd
    80004846:	154080e7          	jalr	340(ra) # 80001996 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000484a:	409c                	lw	a5,0(s1)
    8000484c:	37f9                	addiw	a5,a5,-2
    8000484e:	4705                	li	a4,1
    80004850:	04f76763          	bltu	a4,a5,8000489e <filestat+0x6e>
    80004854:	892a                	mv	s2,a0
    ilock(f->ip);
    80004856:	6c88                	ld	a0,24(s1)
    80004858:	fffff097          	auipc	ra,0xfffff
    8000485c:	06c080e7          	jalr	108(ra) # 800038c4 <ilock>
    stati(f->ip, &st);
    80004860:	fb840593          	addi	a1,s0,-72
    80004864:	6c88                	ld	a0,24(s1)
    80004866:	fffff097          	auipc	ra,0xfffff
    8000486a:	2e8080e7          	jalr	744(ra) # 80003b4e <stati>
    iunlock(f->ip);
    8000486e:	6c88                	ld	a0,24(s1)
    80004870:	fffff097          	auipc	ra,0xfffff
    80004874:	116080e7          	jalr	278(ra) # 80003986 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004878:	46e1                	li	a3,24
    8000487a:	fb840613          	addi	a2,s0,-72
    8000487e:	85ce                	mv	a1,s3
    80004880:	06093503          	ld	a0,96(s2)
    80004884:	ffffd097          	auipc	ra,0xffffd
    80004888:	dd6080e7          	jalr	-554(ra) # 8000165a <copyout>
    8000488c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004890:	60a6                	ld	ra,72(sp)
    80004892:	6406                	ld	s0,64(sp)
    80004894:	74e2                	ld	s1,56(sp)
    80004896:	7942                	ld	s2,48(sp)
    80004898:	79a2                	ld	s3,40(sp)
    8000489a:	6161                	addi	sp,sp,80
    8000489c:	8082                	ret
  return -1;
    8000489e:	557d                	li	a0,-1
    800048a0:	bfc5                	j	80004890 <filestat+0x60>

00000000800048a2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048a2:	7179                	addi	sp,sp,-48
    800048a4:	f406                	sd	ra,40(sp)
    800048a6:	f022                	sd	s0,32(sp)
    800048a8:	ec26                	sd	s1,24(sp)
    800048aa:	e84a                	sd	s2,16(sp)
    800048ac:	e44e                	sd	s3,8(sp)
    800048ae:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048b0:	00854783          	lbu	a5,8(a0)
    800048b4:	c3d5                	beqz	a5,80004958 <fileread+0xb6>
    800048b6:	84aa                	mv	s1,a0
    800048b8:	89ae                	mv	s3,a1
    800048ba:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048bc:	411c                	lw	a5,0(a0)
    800048be:	4705                	li	a4,1
    800048c0:	04e78963          	beq	a5,a4,80004912 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048c4:	470d                	li	a4,3
    800048c6:	04e78d63          	beq	a5,a4,80004920 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048ca:	4709                	li	a4,2
    800048cc:	06e79e63          	bne	a5,a4,80004948 <fileread+0xa6>
    ilock(f->ip);
    800048d0:	6d08                	ld	a0,24(a0)
    800048d2:	fffff097          	auipc	ra,0xfffff
    800048d6:	ff2080e7          	jalr	-14(ra) # 800038c4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048da:	874a                	mv	a4,s2
    800048dc:	5094                	lw	a3,32(s1)
    800048de:	864e                	mv	a2,s3
    800048e0:	4585                	li	a1,1
    800048e2:	6c88                	ld	a0,24(s1)
    800048e4:	fffff097          	auipc	ra,0xfffff
    800048e8:	294080e7          	jalr	660(ra) # 80003b78 <readi>
    800048ec:	892a                	mv	s2,a0
    800048ee:	00a05563          	blez	a0,800048f8 <fileread+0x56>
      f->off += r;
    800048f2:	509c                	lw	a5,32(s1)
    800048f4:	9fa9                	addw	a5,a5,a0
    800048f6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048f8:	6c88                	ld	a0,24(s1)
    800048fa:	fffff097          	auipc	ra,0xfffff
    800048fe:	08c080e7          	jalr	140(ra) # 80003986 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004902:	854a                	mv	a0,s2
    80004904:	70a2                	ld	ra,40(sp)
    80004906:	7402                	ld	s0,32(sp)
    80004908:	64e2                	ld	s1,24(sp)
    8000490a:	6942                	ld	s2,16(sp)
    8000490c:	69a2                	ld	s3,8(sp)
    8000490e:	6145                	addi	sp,sp,48
    80004910:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004912:	6908                	ld	a0,16(a0)
    80004914:	00000097          	auipc	ra,0x0
    80004918:	3c0080e7          	jalr	960(ra) # 80004cd4 <piperead>
    8000491c:	892a                	mv	s2,a0
    8000491e:	b7d5                	j	80004902 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004920:	02451783          	lh	a5,36(a0)
    80004924:	03079693          	slli	a3,a5,0x30
    80004928:	92c1                	srli	a3,a3,0x30
    8000492a:	4725                	li	a4,9
    8000492c:	02d76863          	bltu	a4,a3,8000495c <fileread+0xba>
    80004930:	0792                	slli	a5,a5,0x4
    80004932:	0001d717          	auipc	a4,0x1d
    80004936:	fe670713          	addi	a4,a4,-26 # 80021918 <devsw>
    8000493a:	97ba                	add	a5,a5,a4
    8000493c:	639c                	ld	a5,0(a5)
    8000493e:	c38d                	beqz	a5,80004960 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004940:	4505                	li	a0,1
    80004942:	9782                	jalr	a5
    80004944:	892a                	mv	s2,a0
    80004946:	bf75                	j	80004902 <fileread+0x60>
    panic("fileread");
    80004948:	00004517          	auipc	a0,0x4
    8000494c:	d6050513          	addi	a0,a0,-672 # 800086a8 <syscalls+0x260>
    80004950:	ffffc097          	auipc	ra,0xffffc
    80004954:	bea080e7          	jalr	-1046(ra) # 8000053a <panic>
    return -1;
    80004958:	597d                	li	s2,-1
    8000495a:	b765                	j	80004902 <fileread+0x60>
      return -1;
    8000495c:	597d                	li	s2,-1
    8000495e:	b755                	j	80004902 <fileread+0x60>
    80004960:	597d                	li	s2,-1
    80004962:	b745                	j	80004902 <fileread+0x60>

0000000080004964 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004964:	715d                	addi	sp,sp,-80
    80004966:	e486                	sd	ra,72(sp)
    80004968:	e0a2                	sd	s0,64(sp)
    8000496a:	fc26                	sd	s1,56(sp)
    8000496c:	f84a                	sd	s2,48(sp)
    8000496e:	f44e                	sd	s3,40(sp)
    80004970:	f052                	sd	s4,32(sp)
    80004972:	ec56                	sd	s5,24(sp)
    80004974:	e85a                	sd	s6,16(sp)
    80004976:	e45e                	sd	s7,8(sp)
    80004978:	e062                	sd	s8,0(sp)
    8000497a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000497c:	00954783          	lbu	a5,9(a0)
    80004980:	10078663          	beqz	a5,80004a8c <filewrite+0x128>
    80004984:	892a                	mv	s2,a0
    80004986:	8b2e                	mv	s6,a1
    80004988:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000498a:	411c                	lw	a5,0(a0)
    8000498c:	4705                	li	a4,1
    8000498e:	02e78263          	beq	a5,a4,800049b2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004992:	470d                	li	a4,3
    80004994:	02e78663          	beq	a5,a4,800049c0 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004998:	4709                	li	a4,2
    8000499a:	0ee79163          	bne	a5,a4,80004a7c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000499e:	0ac05d63          	blez	a2,80004a58 <filewrite+0xf4>
    int i = 0;
    800049a2:	4981                	li	s3,0
    800049a4:	6b85                	lui	s7,0x1
    800049a6:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800049aa:	6c05                	lui	s8,0x1
    800049ac:	c00c0c1b          	addiw	s8,s8,-1024
    800049b0:	a861                	j	80004a48 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800049b2:	6908                	ld	a0,16(a0)
    800049b4:	00000097          	auipc	ra,0x0
    800049b8:	22e080e7          	jalr	558(ra) # 80004be2 <pipewrite>
    800049bc:	8a2a                	mv	s4,a0
    800049be:	a045                	j	80004a5e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049c0:	02451783          	lh	a5,36(a0)
    800049c4:	03079693          	slli	a3,a5,0x30
    800049c8:	92c1                	srli	a3,a3,0x30
    800049ca:	4725                	li	a4,9
    800049cc:	0cd76263          	bltu	a4,a3,80004a90 <filewrite+0x12c>
    800049d0:	0792                	slli	a5,a5,0x4
    800049d2:	0001d717          	auipc	a4,0x1d
    800049d6:	f4670713          	addi	a4,a4,-186 # 80021918 <devsw>
    800049da:	97ba                	add	a5,a5,a4
    800049dc:	679c                	ld	a5,8(a5)
    800049de:	cbdd                	beqz	a5,80004a94 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800049e0:	4505                	li	a0,1
    800049e2:	9782                	jalr	a5
    800049e4:	8a2a                	mv	s4,a0
    800049e6:	a8a5                	j	80004a5e <filewrite+0xfa>
    800049e8:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800049ec:	00000097          	auipc	ra,0x0
    800049f0:	8b4080e7          	jalr	-1868(ra) # 800042a0 <begin_op>
      ilock(f->ip);
    800049f4:	01893503          	ld	a0,24(s2)
    800049f8:	fffff097          	auipc	ra,0xfffff
    800049fc:	ecc080e7          	jalr	-308(ra) # 800038c4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a00:	8756                	mv	a4,s5
    80004a02:	02092683          	lw	a3,32(s2)
    80004a06:	01698633          	add	a2,s3,s6
    80004a0a:	4585                	li	a1,1
    80004a0c:	01893503          	ld	a0,24(s2)
    80004a10:	fffff097          	auipc	ra,0xfffff
    80004a14:	260080e7          	jalr	608(ra) # 80003c70 <writei>
    80004a18:	84aa                	mv	s1,a0
    80004a1a:	00a05763          	blez	a0,80004a28 <filewrite+0xc4>
        f->off += r;
    80004a1e:	02092783          	lw	a5,32(s2)
    80004a22:	9fa9                	addw	a5,a5,a0
    80004a24:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a28:	01893503          	ld	a0,24(s2)
    80004a2c:	fffff097          	auipc	ra,0xfffff
    80004a30:	f5a080e7          	jalr	-166(ra) # 80003986 <iunlock>
      end_op();
    80004a34:	00000097          	auipc	ra,0x0
    80004a38:	8ea080e7          	jalr	-1814(ra) # 8000431e <end_op>

      if(r != n1){
    80004a3c:	009a9f63          	bne	s5,s1,80004a5a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004a40:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a44:	0149db63          	bge	s3,s4,80004a5a <filewrite+0xf6>
      int n1 = n - i;
    80004a48:	413a04bb          	subw	s1,s4,s3
    80004a4c:	0004879b          	sext.w	a5,s1
    80004a50:	f8fbdce3          	bge	s7,a5,800049e8 <filewrite+0x84>
    80004a54:	84e2                	mv	s1,s8
    80004a56:	bf49                	j	800049e8 <filewrite+0x84>
    int i = 0;
    80004a58:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004a5a:	013a1f63          	bne	s4,s3,80004a78 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a5e:	8552                	mv	a0,s4
    80004a60:	60a6                	ld	ra,72(sp)
    80004a62:	6406                	ld	s0,64(sp)
    80004a64:	74e2                	ld	s1,56(sp)
    80004a66:	7942                	ld	s2,48(sp)
    80004a68:	79a2                	ld	s3,40(sp)
    80004a6a:	7a02                	ld	s4,32(sp)
    80004a6c:	6ae2                	ld	s5,24(sp)
    80004a6e:	6b42                	ld	s6,16(sp)
    80004a70:	6ba2                	ld	s7,8(sp)
    80004a72:	6c02                	ld	s8,0(sp)
    80004a74:	6161                	addi	sp,sp,80
    80004a76:	8082                	ret
    ret = (i == n ? n : -1);
    80004a78:	5a7d                	li	s4,-1
    80004a7a:	b7d5                	j	80004a5e <filewrite+0xfa>
    panic("filewrite");
    80004a7c:	00004517          	auipc	a0,0x4
    80004a80:	c3c50513          	addi	a0,a0,-964 # 800086b8 <syscalls+0x270>
    80004a84:	ffffc097          	auipc	ra,0xffffc
    80004a88:	ab6080e7          	jalr	-1354(ra) # 8000053a <panic>
    return -1;
    80004a8c:	5a7d                	li	s4,-1
    80004a8e:	bfc1                	j	80004a5e <filewrite+0xfa>
      return -1;
    80004a90:	5a7d                	li	s4,-1
    80004a92:	b7f1                	j	80004a5e <filewrite+0xfa>
    80004a94:	5a7d                	li	s4,-1
    80004a96:	b7e1                	j	80004a5e <filewrite+0xfa>

0000000080004a98 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a98:	7179                	addi	sp,sp,-48
    80004a9a:	f406                	sd	ra,40(sp)
    80004a9c:	f022                	sd	s0,32(sp)
    80004a9e:	ec26                	sd	s1,24(sp)
    80004aa0:	e84a                	sd	s2,16(sp)
    80004aa2:	e44e                	sd	s3,8(sp)
    80004aa4:	e052                	sd	s4,0(sp)
    80004aa6:	1800                	addi	s0,sp,48
    80004aa8:	84aa                	mv	s1,a0
    80004aaa:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004aac:	0005b023          	sd	zero,0(a1)
    80004ab0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ab4:	00000097          	auipc	ra,0x0
    80004ab8:	bf8080e7          	jalr	-1032(ra) # 800046ac <filealloc>
    80004abc:	e088                	sd	a0,0(s1)
    80004abe:	c551                	beqz	a0,80004b4a <pipealloc+0xb2>
    80004ac0:	00000097          	auipc	ra,0x0
    80004ac4:	bec080e7          	jalr	-1044(ra) # 800046ac <filealloc>
    80004ac8:	00aa3023          	sd	a0,0(s4)
    80004acc:	c92d                	beqz	a0,80004b3e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ace:	ffffc097          	auipc	ra,0xffffc
    80004ad2:	012080e7          	jalr	18(ra) # 80000ae0 <kalloc>
    80004ad6:	892a                	mv	s2,a0
    80004ad8:	c125                	beqz	a0,80004b38 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ada:	4985                	li	s3,1
    80004adc:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004ae0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ae4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ae8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004aec:	00004597          	auipc	a1,0x4
    80004af0:	bdc58593          	addi	a1,a1,-1060 # 800086c8 <syscalls+0x280>
    80004af4:	ffffc097          	auipc	ra,0xffffc
    80004af8:	04c080e7          	jalr	76(ra) # 80000b40 <initlock>
  (*f0)->type = FD_PIPE;
    80004afc:	609c                	ld	a5,0(s1)
    80004afe:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b02:	609c                	ld	a5,0(s1)
    80004b04:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b08:	609c                	ld	a5,0(s1)
    80004b0a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b0e:	609c                	ld	a5,0(s1)
    80004b10:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b14:	000a3783          	ld	a5,0(s4)
    80004b18:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b1c:	000a3783          	ld	a5,0(s4)
    80004b20:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b24:	000a3783          	ld	a5,0(s4)
    80004b28:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b2c:	000a3783          	ld	a5,0(s4)
    80004b30:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b34:	4501                	li	a0,0
    80004b36:	a025                	j	80004b5e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b38:	6088                	ld	a0,0(s1)
    80004b3a:	e501                	bnez	a0,80004b42 <pipealloc+0xaa>
    80004b3c:	a039                	j	80004b4a <pipealloc+0xb2>
    80004b3e:	6088                	ld	a0,0(s1)
    80004b40:	c51d                	beqz	a0,80004b6e <pipealloc+0xd6>
    fileclose(*f0);
    80004b42:	00000097          	auipc	ra,0x0
    80004b46:	c26080e7          	jalr	-986(ra) # 80004768 <fileclose>
  if(*f1)
    80004b4a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b4e:	557d                	li	a0,-1
  if(*f1)
    80004b50:	c799                	beqz	a5,80004b5e <pipealloc+0xc6>
    fileclose(*f1);
    80004b52:	853e                	mv	a0,a5
    80004b54:	00000097          	auipc	ra,0x0
    80004b58:	c14080e7          	jalr	-1004(ra) # 80004768 <fileclose>
  return -1;
    80004b5c:	557d                	li	a0,-1
}
    80004b5e:	70a2                	ld	ra,40(sp)
    80004b60:	7402                	ld	s0,32(sp)
    80004b62:	64e2                	ld	s1,24(sp)
    80004b64:	6942                	ld	s2,16(sp)
    80004b66:	69a2                	ld	s3,8(sp)
    80004b68:	6a02                	ld	s4,0(sp)
    80004b6a:	6145                	addi	sp,sp,48
    80004b6c:	8082                	ret
  return -1;
    80004b6e:	557d                	li	a0,-1
    80004b70:	b7fd                	j	80004b5e <pipealloc+0xc6>

0000000080004b72 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b72:	1101                	addi	sp,sp,-32
    80004b74:	ec06                	sd	ra,24(sp)
    80004b76:	e822                	sd	s0,16(sp)
    80004b78:	e426                	sd	s1,8(sp)
    80004b7a:	e04a                	sd	s2,0(sp)
    80004b7c:	1000                	addi	s0,sp,32
    80004b7e:	84aa                	mv	s1,a0
    80004b80:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	04e080e7          	jalr	78(ra) # 80000bd0 <acquire>
  if(writable){
    80004b8a:	02090d63          	beqz	s2,80004bc4 <pipeclose+0x52>
    pi->writeopen = 0;
    80004b8e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b92:	21848513          	addi	a0,s1,536
    80004b96:	ffffd097          	auipc	ra,0xffffd
    80004b9a:	75a080e7          	jalr	1882(ra) # 800022f0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b9e:	2204b783          	ld	a5,544(s1)
    80004ba2:	eb95                	bnez	a5,80004bd6 <pipeclose+0x64>
    release(&pi->lock);
    80004ba4:	8526                	mv	a0,s1
    80004ba6:	ffffc097          	auipc	ra,0xffffc
    80004baa:	0de080e7          	jalr	222(ra) # 80000c84 <release>
    kfree((char*)pi);
    80004bae:	8526                	mv	a0,s1
    80004bb0:	ffffc097          	auipc	ra,0xffffc
    80004bb4:	e32080e7          	jalr	-462(ra) # 800009e2 <kfree>
  } else
    release(&pi->lock);
}
    80004bb8:	60e2                	ld	ra,24(sp)
    80004bba:	6442                	ld	s0,16(sp)
    80004bbc:	64a2                	ld	s1,8(sp)
    80004bbe:	6902                	ld	s2,0(sp)
    80004bc0:	6105                	addi	sp,sp,32
    80004bc2:	8082                	ret
    pi->readopen = 0;
    80004bc4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004bc8:	21c48513          	addi	a0,s1,540
    80004bcc:	ffffd097          	auipc	ra,0xffffd
    80004bd0:	724080e7          	jalr	1828(ra) # 800022f0 <wakeup>
    80004bd4:	b7e9                	j	80004b9e <pipeclose+0x2c>
    release(&pi->lock);
    80004bd6:	8526                	mv	a0,s1
    80004bd8:	ffffc097          	auipc	ra,0xffffc
    80004bdc:	0ac080e7          	jalr	172(ra) # 80000c84 <release>
}
    80004be0:	bfe1                	j	80004bb8 <pipeclose+0x46>

0000000080004be2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004be2:	711d                	addi	sp,sp,-96
    80004be4:	ec86                	sd	ra,88(sp)
    80004be6:	e8a2                	sd	s0,80(sp)
    80004be8:	e4a6                	sd	s1,72(sp)
    80004bea:	e0ca                	sd	s2,64(sp)
    80004bec:	fc4e                	sd	s3,56(sp)
    80004bee:	f852                	sd	s4,48(sp)
    80004bf0:	f456                	sd	s5,40(sp)
    80004bf2:	f05a                	sd	s6,32(sp)
    80004bf4:	ec5e                	sd	s7,24(sp)
    80004bf6:	e862                	sd	s8,16(sp)
    80004bf8:	1080                	addi	s0,sp,96
    80004bfa:	84aa                	mv	s1,a0
    80004bfc:	8aae                	mv	s5,a1
    80004bfe:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c00:	ffffd097          	auipc	ra,0xffffd
    80004c04:	d96080e7          	jalr	-618(ra) # 80001996 <myproc>
    80004c08:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c0a:	8526                	mv	a0,s1
    80004c0c:	ffffc097          	auipc	ra,0xffffc
    80004c10:	fc4080e7          	jalr	-60(ra) # 80000bd0 <acquire>
  while(i < n){
    80004c14:	0b405363          	blez	s4,80004cba <pipewrite+0xd8>
  int i = 0;
    80004c18:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c1a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c1c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c20:	21c48b93          	addi	s7,s1,540
    80004c24:	a089                	j	80004c66 <pipewrite+0x84>
      release(&pi->lock);
    80004c26:	8526                	mv	a0,s1
    80004c28:	ffffc097          	auipc	ra,0xffffc
    80004c2c:	05c080e7          	jalr	92(ra) # 80000c84 <release>
      return -1;
    80004c30:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c32:	854a                	mv	a0,s2
    80004c34:	60e6                	ld	ra,88(sp)
    80004c36:	6446                	ld	s0,80(sp)
    80004c38:	64a6                	ld	s1,72(sp)
    80004c3a:	6906                	ld	s2,64(sp)
    80004c3c:	79e2                	ld	s3,56(sp)
    80004c3e:	7a42                	ld	s4,48(sp)
    80004c40:	7aa2                	ld	s5,40(sp)
    80004c42:	7b02                	ld	s6,32(sp)
    80004c44:	6be2                	ld	s7,24(sp)
    80004c46:	6c42                	ld	s8,16(sp)
    80004c48:	6125                	addi	sp,sp,96
    80004c4a:	8082                	ret
      wakeup(&pi->nread);
    80004c4c:	8562                	mv	a0,s8
    80004c4e:	ffffd097          	auipc	ra,0xffffd
    80004c52:	6a2080e7          	jalr	1698(ra) # 800022f0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c56:	85a6                	mv	a1,s1
    80004c58:	855e                	mv	a0,s7
    80004c5a:	ffffd097          	auipc	ra,0xffffd
    80004c5e:	50a080e7          	jalr	1290(ra) # 80002164 <sleep>
  while(i < n){
    80004c62:	05495d63          	bge	s2,s4,80004cbc <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004c66:	2204a783          	lw	a5,544(s1)
    80004c6a:	dfd5                	beqz	a5,80004c26 <pipewrite+0x44>
    80004c6c:	0289a783          	lw	a5,40(s3)
    80004c70:	fbdd                	bnez	a5,80004c26 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c72:	2184a783          	lw	a5,536(s1)
    80004c76:	21c4a703          	lw	a4,540(s1)
    80004c7a:	2007879b          	addiw	a5,a5,512
    80004c7e:	fcf707e3          	beq	a4,a5,80004c4c <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c82:	4685                	li	a3,1
    80004c84:	01590633          	add	a2,s2,s5
    80004c88:	faf40593          	addi	a1,s0,-81
    80004c8c:	0609b503          	ld	a0,96(s3)
    80004c90:	ffffd097          	auipc	ra,0xffffd
    80004c94:	a56080e7          	jalr	-1450(ra) # 800016e6 <copyin>
    80004c98:	03650263          	beq	a0,s6,80004cbc <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c9c:	21c4a783          	lw	a5,540(s1)
    80004ca0:	0017871b          	addiw	a4,a5,1
    80004ca4:	20e4ae23          	sw	a4,540(s1)
    80004ca8:	1ff7f793          	andi	a5,a5,511
    80004cac:	97a6                	add	a5,a5,s1
    80004cae:	faf44703          	lbu	a4,-81(s0)
    80004cb2:	00e78c23          	sb	a4,24(a5)
      i++;
    80004cb6:	2905                	addiw	s2,s2,1
    80004cb8:	b76d                	j	80004c62 <pipewrite+0x80>
  int i = 0;
    80004cba:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004cbc:	21848513          	addi	a0,s1,536
    80004cc0:	ffffd097          	auipc	ra,0xffffd
    80004cc4:	630080e7          	jalr	1584(ra) # 800022f0 <wakeup>
  release(&pi->lock);
    80004cc8:	8526                	mv	a0,s1
    80004cca:	ffffc097          	auipc	ra,0xffffc
    80004cce:	fba080e7          	jalr	-70(ra) # 80000c84 <release>
  return i;
    80004cd2:	b785                	j	80004c32 <pipewrite+0x50>

0000000080004cd4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004cd4:	715d                	addi	sp,sp,-80
    80004cd6:	e486                	sd	ra,72(sp)
    80004cd8:	e0a2                	sd	s0,64(sp)
    80004cda:	fc26                	sd	s1,56(sp)
    80004cdc:	f84a                	sd	s2,48(sp)
    80004cde:	f44e                	sd	s3,40(sp)
    80004ce0:	f052                	sd	s4,32(sp)
    80004ce2:	ec56                	sd	s5,24(sp)
    80004ce4:	e85a                	sd	s6,16(sp)
    80004ce6:	0880                	addi	s0,sp,80
    80004ce8:	84aa                	mv	s1,a0
    80004cea:	892e                	mv	s2,a1
    80004cec:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004cee:	ffffd097          	auipc	ra,0xffffd
    80004cf2:	ca8080e7          	jalr	-856(ra) # 80001996 <myproc>
    80004cf6:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004cf8:	8526                	mv	a0,s1
    80004cfa:	ffffc097          	auipc	ra,0xffffc
    80004cfe:	ed6080e7          	jalr	-298(ra) # 80000bd0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d02:	2184a703          	lw	a4,536(s1)
    80004d06:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d0a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d0e:	02f71463          	bne	a4,a5,80004d36 <piperead+0x62>
    80004d12:	2244a783          	lw	a5,548(s1)
    80004d16:	c385                	beqz	a5,80004d36 <piperead+0x62>
    if(pr->killed){
    80004d18:	028a2783          	lw	a5,40(s4)
    80004d1c:	ebc9                	bnez	a5,80004dae <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d1e:	85a6                	mv	a1,s1
    80004d20:	854e                	mv	a0,s3
    80004d22:	ffffd097          	auipc	ra,0xffffd
    80004d26:	442080e7          	jalr	1090(ra) # 80002164 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d2a:	2184a703          	lw	a4,536(s1)
    80004d2e:	21c4a783          	lw	a5,540(s1)
    80004d32:	fef700e3          	beq	a4,a5,80004d12 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d36:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d38:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d3a:	05505463          	blez	s5,80004d82 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80004d3e:	2184a783          	lw	a5,536(s1)
    80004d42:	21c4a703          	lw	a4,540(s1)
    80004d46:	02f70e63          	beq	a4,a5,80004d82 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d4a:	0017871b          	addiw	a4,a5,1
    80004d4e:	20e4ac23          	sw	a4,536(s1)
    80004d52:	1ff7f793          	andi	a5,a5,511
    80004d56:	97a6                	add	a5,a5,s1
    80004d58:	0187c783          	lbu	a5,24(a5)
    80004d5c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d60:	4685                	li	a3,1
    80004d62:	fbf40613          	addi	a2,s0,-65
    80004d66:	85ca                	mv	a1,s2
    80004d68:	060a3503          	ld	a0,96(s4)
    80004d6c:	ffffd097          	auipc	ra,0xffffd
    80004d70:	8ee080e7          	jalr	-1810(ra) # 8000165a <copyout>
    80004d74:	01650763          	beq	a0,s6,80004d82 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d78:	2985                	addiw	s3,s3,1
    80004d7a:	0905                	addi	s2,s2,1
    80004d7c:	fd3a91e3          	bne	s5,s3,80004d3e <piperead+0x6a>
    80004d80:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d82:	21c48513          	addi	a0,s1,540
    80004d86:	ffffd097          	auipc	ra,0xffffd
    80004d8a:	56a080e7          	jalr	1386(ra) # 800022f0 <wakeup>
  release(&pi->lock);
    80004d8e:	8526                	mv	a0,s1
    80004d90:	ffffc097          	auipc	ra,0xffffc
    80004d94:	ef4080e7          	jalr	-268(ra) # 80000c84 <release>
  return i;
}
    80004d98:	854e                	mv	a0,s3
    80004d9a:	60a6                	ld	ra,72(sp)
    80004d9c:	6406                	ld	s0,64(sp)
    80004d9e:	74e2                	ld	s1,56(sp)
    80004da0:	7942                	ld	s2,48(sp)
    80004da2:	79a2                	ld	s3,40(sp)
    80004da4:	7a02                	ld	s4,32(sp)
    80004da6:	6ae2                	ld	s5,24(sp)
    80004da8:	6b42                	ld	s6,16(sp)
    80004daa:	6161                	addi	sp,sp,80
    80004dac:	8082                	ret
      release(&pi->lock);
    80004dae:	8526                	mv	a0,s1
    80004db0:	ffffc097          	auipc	ra,0xffffc
    80004db4:	ed4080e7          	jalr	-300(ra) # 80000c84 <release>
      return -1;
    80004db8:	59fd                	li	s3,-1
    80004dba:	bff9                	j	80004d98 <piperead+0xc4>

0000000080004dbc <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004dbc:	de010113          	addi	sp,sp,-544
    80004dc0:	20113c23          	sd	ra,536(sp)
    80004dc4:	20813823          	sd	s0,528(sp)
    80004dc8:	20913423          	sd	s1,520(sp)
    80004dcc:	21213023          	sd	s2,512(sp)
    80004dd0:	ffce                	sd	s3,504(sp)
    80004dd2:	fbd2                	sd	s4,496(sp)
    80004dd4:	f7d6                	sd	s5,488(sp)
    80004dd6:	f3da                	sd	s6,480(sp)
    80004dd8:	efde                	sd	s7,472(sp)
    80004dda:	ebe2                	sd	s8,464(sp)
    80004ddc:	e7e6                	sd	s9,456(sp)
    80004dde:	e3ea                	sd	s10,448(sp)
    80004de0:	ff6e                	sd	s11,440(sp)
    80004de2:	1400                	addi	s0,sp,544
    80004de4:	892a                	mv	s2,a0
    80004de6:	dea43423          	sd	a0,-536(s0)
    80004dea:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004dee:	ffffd097          	auipc	ra,0xffffd
    80004df2:	ba8080e7          	jalr	-1112(ra) # 80001996 <myproc>
    80004df6:	84aa                	mv	s1,a0

  begin_op();
    80004df8:	fffff097          	auipc	ra,0xfffff
    80004dfc:	4a8080e7          	jalr	1192(ra) # 800042a0 <begin_op>

  if((ip = namei(path)) == 0){
    80004e00:	854a                	mv	a0,s2
    80004e02:	fffff097          	auipc	ra,0xfffff
    80004e06:	27e080e7          	jalr	638(ra) # 80004080 <namei>
    80004e0a:	c93d                	beqz	a0,80004e80 <exec+0xc4>
    80004e0c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e0e:	fffff097          	auipc	ra,0xfffff
    80004e12:	ab6080e7          	jalr	-1354(ra) # 800038c4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e16:	04000713          	li	a4,64
    80004e1a:	4681                	li	a3,0
    80004e1c:	e5040613          	addi	a2,s0,-432
    80004e20:	4581                	li	a1,0
    80004e22:	8556                	mv	a0,s5
    80004e24:	fffff097          	auipc	ra,0xfffff
    80004e28:	d54080e7          	jalr	-684(ra) # 80003b78 <readi>
    80004e2c:	04000793          	li	a5,64
    80004e30:	00f51a63          	bne	a0,a5,80004e44 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e34:	e5042703          	lw	a4,-432(s0)
    80004e38:	464c47b7          	lui	a5,0x464c4
    80004e3c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e40:	04f70663          	beq	a4,a5,80004e8c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e44:	8556                	mv	a0,s5
    80004e46:	fffff097          	auipc	ra,0xfffff
    80004e4a:	ce0080e7          	jalr	-800(ra) # 80003b26 <iunlockput>
    end_op();
    80004e4e:	fffff097          	auipc	ra,0xfffff
    80004e52:	4d0080e7          	jalr	1232(ra) # 8000431e <end_op>
  }
  return -1;
    80004e56:	557d                	li	a0,-1
}
    80004e58:	21813083          	ld	ra,536(sp)
    80004e5c:	21013403          	ld	s0,528(sp)
    80004e60:	20813483          	ld	s1,520(sp)
    80004e64:	20013903          	ld	s2,512(sp)
    80004e68:	79fe                	ld	s3,504(sp)
    80004e6a:	7a5e                	ld	s4,496(sp)
    80004e6c:	7abe                	ld	s5,488(sp)
    80004e6e:	7b1e                	ld	s6,480(sp)
    80004e70:	6bfe                	ld	s7,472(sp)
    80004e72:	6c5e                	ld	s8,464(sp)
    80004e74:	6cbe                	ld	s9,456(sp)
    80004e76:	6d1e                	ld	s10,448(sp)
    80004e78:	7dfa                	ld	s11,440(sp)
    80004e7a:	22010113          	addi	sp,sp,544
    80004e7e:	8082                	ret
    end_op();
    80004e80:	fffff097          	auipc	ra,0xfffff
    80004e84:	49e080e7          	jalr	1182(ra) # 8000431e <end_op>
    return -1;
    80004e88:	557d                	li	a0,-1
    80004e8a:	b7f9                	j	80004e58 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e8c:	8526                	mv	a0,s1
    80004e8e:	ffffd097          	auipc	ra,0xffffd
    80004e92:	bcc080e7          	jalr	-1076(ra) # 80001a5a <proc_pagetable>
    80004e96:	8b2a                	mv	s6,a0
    80004e98:	d555                	beqz	a0,80004e44 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e9a:	e7042783          	lw	a5,-400(s0)
    80004e9e:	e8845703          	lhu	a4,-376(s0)
    80004ea2:	c735                	beqz	a4,80004f0e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ea4:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ea6:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004eaa:	6a05                	lui	s4,0x1
    80004eac:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004eb0:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004eb4:	6d85                	lui	s11,0x1
    80004eb6:	7d7d                	lui	s10,0xfffff
    80004eb8:	ac1d                	j	800050ee <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004eba:	00004517          	auipc	a0,0x4
    80004ebe:	81650513          	addi	a0,a0,-2026 # 800086d0 <syscalls+0x288>
    80004ec2:	ffffb097          	auipc	ra,0xffffb
    80004ec6:	678080e7          	jalr	1656(ra) # 8000053a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004eca:	874a                	mv	a4,s2
    80004ecc:	009c86bb          	addw	a3,s9,s1
    80004ed0:	4581                	li	a1,0
    80004ed2:	8556                	mv	a0,s5
    80004ed4:	fffff097          	auipc	ra,0xfffff
    80004ed8:	ca4080e7          	jalr	-860(ra) # 80003b78 <readi>
    80004edc:	2501                	sext.w	a0,a0
    80004ede:	1aa91863          	bne	s2,a0,8000508e <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004ee2:	009d84bb          	addw	s1,s11,s1
    80004ee6:	013d09bb          	addw	s3,s10,s3
    80004eea:	1f74f263          	bgeu	s1,s7,800050ce <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004eee:	02049593          	slli	a1,s1,0x20
    80004ef2:	9181                	srli	a1,a1,0x20
    80004ef4:	95e2                	add	a1,a1,s8
    80004ef6:	855a                	mv	a0,s6
    80004ef8:	ffffc097          	auipc	ra,0xffffc
    80004efc:	15a080e7          	jalr	346(ra) # 80001052 <walkaddr>
    80004f00:	862a                	mv	a2,a0
    if(pa == 0)
    80004f02:	dd45                	beqz	a0,80004eba <exec+0xfe>
      n = PGSIZE;
    80004f04:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f06:	fd49f2e3          	bgeu	s3,s4,80004eca <exec+0x10e>
      n = sz - i;
    80004f0a:	894e                	mv	s2,s3
    80004f0c:	bf7d                	j	80004eca <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f0e:	4481                	li	s1,0
  iunlockput(ip);
    80004f10:	8556                	mv	a0,s5
    80004f12:	fffff097          	auipc	ra,0xfffff
    80004f16:	c14080e7          	jalr	-1004(ra) # 80003b26 <iunlockput>
  end_op();
    80004f1a:	fffff097          	auipc	ra,0xfffff
    80004f1e:	404080e7          	jalr	1028(ra) # 8000431e <end_op>
  p = myproc();
    80004f22:	ffffd097          	auipc	ra,0xffffd
    80004f26:	a74080e7          	jalr	-1420(ra) # 80001996 <myproc>
    80004f2a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004f2c:	05853d03          	ld	s10,88(a0)
  sz = PGROUNDUP(sz);
    80004f30:	6785                	lui	a5,0x1
    80004f32:	17fd                	addi	a5,a5,-1
    80004f34:	97a6                	add	a5,a5,s1
    80004f36:	777d                	lui	a4,0xfffff
    80004f38:	8ff9                	and	a5,a5,a4
    80004f3a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f3e:	6609                	lui	a2,0x2
    80004f40:	963e                	add	a2,a2,a5
    80004f42:	85be                	mv	a1,a5
    80004f44:	855a                	mv	a0,s6
    80004f46:	ffffc097          	auipc	ra,0xffffc
    80004f4a:	4c0080e7          	jalr	1216(ra) # 80001406 <uvmalloc>
    80004f4e:	8c2a                	mv	s8,a0
  ip = 0;
    80004f50:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f52:	12050e63          	beqz	a0,8000508e <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f56:	75f9                	lui	a1,0xffffe
    80004f58:	95aa                	add	a1,a1,a0
    80004f5a:	855a                	mv	a0,s6
    80004f5c:	ffffc097          	auipc	ra,0xffffc
    80004f60:	6cc080e7          	jalr	1740(ra) # 80001628 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f64:	7afd                	lui	s5,0xfffff
    80004f66:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004f68:	df043783          	ld	a5,-528(s0)
    80004f6c:	6388                	ld	a0,0(a5)
    80004f6e:	c925                	beqz	a0,80004fde <exec+0x222>
    80004f70:	e9040993          	addi	s3,s0,-368
    80004f74:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004f78:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004f7a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004f7c:	ffffc097          	auipc	ra,0xffffc
    80004f80:	ecc080e7          	jalr	-308(ra) # 80000e48 <strlen>
    80004f84:	0015079b          	addiw	a5,a0,1
    80004f88:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f8c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004f90:	13596363          	bltu	s2,s5,800050b6 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f94:	df043d83          	ld	s11,-528(s0)
    80004f98:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004f9c:	8552                	mv	a0,s4
    80004f9e:	ffffc097          	auipc	ra,0xffffc
    80004fa2:	eaa080e7          	jalr	-342(ra) # 80000e48 <strlen>
    80004fa6:	0015069b          	addiw	a3,a0,1
    80004faa:	8652                	mv	a2,s4
    80004fac:	85ca                	mv	a1,s2
    80004fae:	855a                	mv	a0,s6
    80004fb0:	ffffc097          	auipc	ra,0xffffc
    80004fb4:	6aa080e7          	jalr	1706(ra) # 8000165a <copyout>
    80004fb8:	10054363          	bltz	a0,800050be <exec+0x302>
    ustack[argc] = sp;
    80004fbc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004fc0:	0485                	addi	s1,s1,1
    80004fc2:	008d8793          	addi	a5,s11,8
    80004fc6:	def43823          	sd	a5,-528(s0)
    80004fca:	008db503          	ld	a0,8(s11)
    80004fce:	c911                	beqz	a0,80004fe2 <exec+0x226>
    if(argc >= MAXARG)
    80004fd0:	09a1                	addi	s3,s3,8
    80004fd2:	fb3c95e3          	bne	s9,s3,80004f7c <exec+0x1c0>
  sz = sz1;
    80004fd6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004fda:	4a81                	li	s5,0
    80004fdc:	a84d                	j	8000508e <exec+0x2d2>
  sp = sz;
    80004fde:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004fe0:	4481                	li	s1,0
  ustack[argc] = 0;
    80004fe2:	00349793          	slli	a5,s1,0x3
    80004fe6:	f9078793          	addi	a5,a5,-112 # f90 <_entry-0x7ffff070>
    80004fea:	97a2                	add	a5,a5,s0
    80004fec:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004ff0:	00148693          	addi	a3,s1,1
    80004ff4:	068e                	slli	a3,a3,0x3
    80004ff6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004ffa:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004ffe:	01597663          	bgeu	s2,s5,8000500a <exec+0x24e>
  sz = sz1;
    80005002:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005006:	4a81                	li	s5,0
    80005008:	a059                	j	8000508e <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000500a:	e9040613          	addi	a2,s0,-368
    8000500e:	85ca                	mv	a1,s2
    80005010:	855a                	mv	a0,s6
    80005012:	ffffc097          	auipc	ra,0xffffc
    80005016:	648080e7          	jalr	1608(ra) # 8000165a <copyout>
    8000501a:	0a054663          	bltz	a0,800050c6 <exec+0x30a>
  p->trapframe->a1 = sp;
    8000501e:	068bb783          	ld	a5,104(s7)
    80005022:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005026:	de843783          	ld	a5,-536(s0)
    8000502a:	0007c703          	lbu	a4,0(a5)
    8000502e:	cf11                	beqz	a4,8000504a <exec+0x28e>
    80005030:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005032:	02f00693          	li	a3,47
    80005036:	a039                	j	80005044 <exec+0x288>
      last = s+1;
    80005038:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000503c:	0785                	addi	a5,a5,1
    8000503e:	fff7c703          	lbu	a4,-1(a5)
    80005042:	c701                	beqz	a4,8000504a <exec+0x28e>
    if(*s == '/')
    80005044:	fed71ce3          	bne	a4,a3,8000503c <exec+0x280>
    80005048:	bfc5                	j	80005038 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000504a:	4641                	li	a2,16
    8000504c:	de843583          	ld	a1,-536(s0)
    80005050:	168b8513          	addi	a0,s7,360
    80005054:	ffffc097          	auipc	ra,0xffffc
    80005058:	dc2080e7          	jalr	-574(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    8000505c:	060bb503          	ld	a0,96(s7)
  p->pagetable = pagetable;
    80005060:	076bb023          	sd	s6,96(s7)
  p->sz = sz;
    80005064:	058bbc23          	sd	s8,88(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005068:	068bb783          	ld	a5,104(s7)
    8000506c:	e6843703          	ld	a4,-408(s0)
    80005070:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005072:	068bb783          	ld	a5,104(s7)
    80005076:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000507a:	85ea                	mv	a1,s10
    8000507c:	ffffd097          	auipc	ra,0xffffd
    80005080:	a7a080e7          	jalr	-1414(ra) # 80001af6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005084:	0004851b          	sext.w	a0,s1
    80005088:	bbc1                	j	80004e58 <exec+0x9c>
    8000508a:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000508e:	df843583          	ld	a1,-520(s0)
    80005092:	855a                	mv	a0,s6
    80005094:	ffffd097          	auipc	ra,0xffffd
    80005098:	a62080e7          	jalr	-1438(ra) # 80001af6 <proc_freepagetable>
  if(ip){
    8000509c:	da0a94e3          	bnez	s5,80004e44 <exec+0x88>
  return -1;
    800050a0:	557d                	li	a0,-1
    800050a2:	bb5d                	j	80004e58 <exec+0x9c>
    800050a4:	de943c23          	sd	s1,-520(s0)
    800050a8:	b7dd                	j	8000508e <exec+0x2d2>
    800050aa:	de943c23          	sd	s1,-520(s0)
    800050ae:	b7c5                	j	8000508e <exec+0x2d2>
    800050b0:	de943c23          	sd	s1,-520(s0)
    800050b4:	bfe9                	j	8000508e <exec+0x2d2>
  sz = sz1;
    800050b6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050ba:	4a81                	li	s5,0
    800050bc:	bfc9                	j	8000508e <exec+0x2d2>
  sz = sz1;
    800050be:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050c2:	4a81                	li	s5,0
    800050c4:	b7e9                	j	8000508e <exec+0x2d2>
  sz = sz1;
    800050c6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050ca:	4a81                	li	s5,0
    800050cc:	b7c9                	j	8000508e <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800050ce:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050d2:	e0843783          	ld	a5,-504(s0)
    800050d6:	0017869b          	addiw	a3,a5,1
    800050da:	e0d43423          	sd	a3,-504(s0)
    800050de:	e0043783          	ld	a5,-512(s0)
    800050e2:	0387879b          	addiw	a5,a5,56
    800050e6:	e8845703          	lhu	a4,-376(s0)
    800050ea:	e2e6d3e3          	bge	a3,a4,80004f10 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800050ee:	2781                	sext.w	a5,a5
    800050f0:	e0f43023          	sd	a5,-512(s0)
    800050f4:	03800713          	li	a4,56
    800050f8:	86be                	mv	a3,a5
    800050fa:	e1840613          	addi	a2,s0,-488
    800050fe:	4581                	li	a1,0
    80005100:	8556                	mv	a0,s5
    80005102:	fffff097          	auipc	ra,0xfffff
    80005106:	a76080e7          	jalr	-1418(ra) # 80003b78 <readi>
    8000510a:	03800793          	li	a5,56
    8000510e:	f6f51ee3          	bne	a0,a5,8000508a <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80005112:	e1842783          	lw	a5,-488(s0)
    80005116:	4705                	li	a4,1
    80005118:	fae79de3          	bne	a5,a4,800050d2 <exec+0x316>
    if(ph.memsz < ph.filesz)
    8000511c:	e4043603          	ld	a2,-448(s0)
    80005120:	e3843783          	ld	a5,-456(s0)
    80005124:	f8f660e3          	bltu	a2,a5,800050a4 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005128:	e2843783          	ld	a5,-472(s0)
    8000512c:	963e                	add	a2,a2,a5
    8000512e:	f6f66ee3          	bltu	a2,a5,800050aa <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005132:	85a6                	mv	a1,s1
    80005134:	855a                	mv	a0,s6
    80005136:	ffffc097          	auipc	ra,0xffffc
    8000513a:	2d0080e7          	jalr	720(ra) # 80001406 <uvmalloc>
    8000513e:	dea43c23          	sd	a0,-520(s0)
    80005142:	d53d                	beqz	a0,800050b0 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    80005144:	e2843c03          	ld	s8,-472(s0)
    80005148:	de043783          	ld	a5,-544(s0)
    8000514c:	00fc77b3          	and	a5,s8,a5
    80005150:	ff9d                	bnez	a5,8000508e <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005152:	e2042c83          	lw	s9,-480(s0)
    80005156:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000515a:	f60b8ae3          	beqz	s7,800050ce <exec+0x312>
    8000515e:	89de                	mv	s3,s7
    80005160:	4481                	li	s1,0
    80005162:	b371                	j	80004eee <exec+0x132>

0000000080005164 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005164:	7179                	addi	sp,sp,-48
    80005166:	f406                	sd	ra,40(sp)
    80005168:	f022                	sd	s0,32(sp)
    8000516a:	ec26                	sd	s1,24(sp)
    8000516c:	e84a                	sd	s2,16(sp)
    8000516e:	1800                	addi	s0,sp,48
    80005170:	892e                	mv	s2,a1
    80005172:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005174:	fdc40593          	addi	a1,s0,-36
    80005178:	ffffe097          	auipc	ra,0xffffe
    8000517c:	b76080e7          	jalr	-1162(ra) # 80002cee <argint>
    80005180:	04054063          	bltz	a0,800051c0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005184:	fdc42703          	lw	a4,-36(s0)
    80005188:	47bd                	li	a5,15
    8000518a:	02e7ed63          	bltu	a5,a4,800051c4 <argfd+0x60>
    8000518e:	ffffd097          	auipc	ra,0xffffd
    80005192:	808080e7          	jalr	-2040(ra) # 80001996 <myproc>
    80005196:	fdc42703          	lw	a4,-36(s0)
    8000519a:	01c70793          	addi	a5,a4,28 # fffffffffffff01c <end+0xffffffff7ffd901c>
    8000519e:	078e                	slli	a5,a5,0x3
    800051a0:	953e                	add	a0,a0,a5
    800051a2:	611c                	ld	a5,0(a0)
    800051a4:	c395                	beqz	a5,800051c8 <argfd+0x64>
    return -1;
  if(pfd)
    800051a6:	00090463          	beqz	s2,800051ae <argfd+0x4a>
    *pfd = fd;
    800051aa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051ae:	4501                	li	a0,0
  if(pf)
    800051b0:	c091                	beqz	s1,800051b4 <argfd+0x50>
    *pf = f;
    800051b2:	e09c                	sd	a5,0(s1)
}
    800051b4:	70a2                	ld	ra,40(sp)
    800051b6:	7402                	ld	s0,32(sp)
    800051b8:	64e2                	ld	s1,24(sp)
    800051ba:	6942                	ld	s2,16(sp)
    800051bc:	6145                	addi	sp,sp,48
    800051be:	8082                	ret
    return -1;
    800051c0:	557d                	li	a0,-1
    800051c2:	bfcd                	j	800051b4 <argfd+0x50>
    return -1;
    800051c4:	557d                	li	a0,-1
    800051c6:	b7fd                	j	800051b4 <argfd+0x50>
    800051c8:	557d                	li	a0,-1
    800051ca:	b7ed                	j	800051b4 <argfd+0x50>

00000000800051cc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051cc:	1101                	addi	sp,sp,-32
    800051ce:	ec06                	sd	ra,24(sp)
    800051d0:	e822                	sd	s0,16(sp)
    800051d2:	e426                	sd	s1,8(sp)
    800051d4:	1000                	addi	s0,sp,32
    800051d6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800051d8:	ffffc097          	auipc	ra,0xffffc
    800051dc:	7be080e7          	jalr	1982(ra) # 80001996 <myproc>
    800051e0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800051e2:	0e050793          	addi	a5,a0,224
    800051e6:	4501                	li	a0,0
    800051e8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800051ea:	6398                	ld	a4,0(a5)
    800051ec:	cb19                	beqz	a4,80005202 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800051ee:	2505                	addiw	a0,a0,1
    800051f0:	07a1                	addi	a5,a5,8
    800051f2:	fed51ce3          	bne	a0,a3,800051ea <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800051f6:	557d                	li	a0,-1
}
    800051f8:	60e2                	ld	ra,24(sp)
    800051fa:	6442                	ld	s0,16(sp)
    800051fc:	64a2                	ld	s1,8(sp)
    800051fe:	6105                	addi	sp,sp,32
    80005200:	8082                	ret
      p->ofile[fd] = f;
    80005202:	01c50793          	addi	a5,a0,28
    80005206:	078e                	slli	a5,a5,0x3
    80005208:	963e                	add	a2,a2,a5
    8000520a:	e204                	sd	s1,0(a2)
      return fd;
    8000520c:	b7f5                	j	800051f8 <fdalloc+0x2c>

000000008000520e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000520e:	715d                	addi	sp,sp,-80
    80005210:	e486                	sd	ra,72(sp)
    80005212:	e0a2                	sd	s0,64(sp)
    80005214:	fc26                	sd	s1,56(sp)
    80005216:	f84a                	sd	s2,48(sp)
    80005218:	f44e                	sd	s3,40(sp)
    8000521a:	f052                	sd	s4,32(sp)
    8000521c:	ec56                	sd	s5,24(sp)
    8000521e:	0880                	addi	s0,sp,80
    80005220:	89ae                	mv	s3,a1
    80005222:	8ab2                	mv	s5,a2
    80005224:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005226:	fb040593          	addi	a1,s0,-80
    8000522a:	fffff097          	auipc	ra,0xfffff
    8000522e:	e74080e7          	jalr	-396(ra) # 8000409e <nameiparent>
    80005232:	892a                	mv	s2,a0
    80005234:	12050e63          	beqz	a0,80005370 <create+0x162>
    return 0;

  ilock(dp);
    80005238:	ffffe097          	auipc	ra,0xffffe
    8000523c:	68c080e7          	jalr	1676(ra) # 800038c4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005240:	4601                	li	a2,0
    80005242:	fb040593          	addi	a1,s0,-80
    80005246:	854a                	mv	a0,s2
    80005248:	fffff097          	auipc	ra,0xfffff
    8000524c:	b60080e7          	jalr	-1184(ra) # 80003da8 <dirlookup>
    80005250:	84aa                	mv	s1,a0
    80005252:	c921                	beqz	a0,800052a2 <create+0x94>
    iunlockput(dp);
    80005254:	854a                	mv	a0,s2
    80005256:	fffff097          	auipc	ra,0xfffff
    8000525a:	8d0080e7          	jalr	-1840(ra) # 80003b26 <iunlockput>
    ilock(ip);
    8000525e:	8526                	mv	a0,s1
    80005260:	ffffe097          	auipc	ra,0xffffe
    80005264:	664080e7          	jalr	1636(ra) # 800038c4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005268:	2981                	sext.w	s3,s3
    8000526a:	4789                	li	a5,2
    8000526c:	02f99463          	bne	s3,a5,80005294 <create+0x86>
    80005270:	0444d783          	lhu	a5,68(s1)
    80005274:	37f9                	addiw	a5,a5,-2
    80005276:	17c2                	slli	a5,a5,0x30
    80005278:	93c1                	srli	a5,a5,0x30
    8000527a:	4705                	li	a4,1
    8000527c:	00f76c63          	bltu	a4,a5,80005294 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005280:	8526                	mv	a0,s1
    80005282:	60a6                	ld	ra,72(sp)
    80005284:	6406                	ld	s0,64(sp)
    80005286:	74e2                	ld	s1,56(sp)
    80005288:	7942                	ld	s2,48(sp)
    8000528a:	79a2                	ld	s3,40(sp)
    8000528c:	7a02                	ld	s4,32(sp)
    8000528e:	6ae2                	ld	s5,24(sp)
    80005290:	6161                	addi	sp,sp,80
    80005292:	8082                	ret
    iunlockput(ip);
    80005294:	8526                	mv	a0,s1
    80005296:	fffff097          	auipc	ra,0xfffff
    8000529a:	890080e7          	jalr	-1904(ra) # 80003b26 <iunlockput>
    return 0;
    8000529e:	4481                	li	s1,0
    800052a0:	b7c5                	j	80005280 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052a2:	85ce                	mv	a1,s3
    800052a4:	00092503          	lw	a0,0(s2)
    800052a8:	ffffe097          	auipc	ra,0xffffe
    800052ac:	482080e7          	jalr	1154(ra) # 8000372a <ialloc>
    800052b0:	84aa                	mv	s1,a0
    800052b2:	c521                	beqz	a0,800052fa <create+0xec>
  ilock(ip);
    800052b4:	ffffe097          	auipc	ra,0xffffe
    800052b8:	610080e7          	jalr	1552(ra) # 800038c4 <ilock>
  ip->major = major;
    800052bc:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800052c0:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800052c4:	4a05                	li	s4,1
    800052c6:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800052ca:	8526                	mv	a0,s1
    800052cc:	ffffe097          	auipc	ra,0xffffe
    800052d0:	52c080e7          	jalr	1324(ra) # 800037f8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800052d4:	2981                	sext.w	s3,s3
    800052d6:	03498a63          	beq	s3,s4,8000530a <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800052da:	40d0                	lw	a2,4(s1)
    800052dc:	fb040593          	addi	a1,s0,-80
    800052e0:	854a                	mv	a0,s2
    800052e2:	fffff097          	auipc	ra,0xfffff
    800052e6:	cdc080e7          	jalr	-804(ra) # 80003fbe <dirlink>
    800052ea:	06054b63          	bltz	a0,80005360 <create+0x152>
  iunlockput(dp);
    800052ee:	854a                	mv	a0,s2
    800052f0:	fffff097          	auipc	ra,0xfffff
    800052f4:	836080e7          	jalr	-1994(ra) # 80003b26 <iunlockput>
  return ip;
    800052f8:	b761                	j	80005280 <create+0x72>
    panic("create: ialloc");
    800052fa:	00003517          	auipc	a0,0x3
    800052fe:	3f650513          	addi	a0,a0,1014 # 800086f0 <syscalls+0x2a8>
    80005302:	ffffb097          	auipc	ra,0xffffb
    80005306:	238080e7          	jalr	568(ra) # 8000053a <panic>
    dp->nlink++;  // for ".."
    8000530a:	04a95783          	lhu	a5,74(s2)
    8000530e:	2785                	addiw	a5,a5,1
    80005310:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005314:	854a                	mv	a0,s2
    80005316:	ffffe097          	auipc	ra,0xffffe
    8000531a:	4e2080e7          	jalr	1250(ra) # 800037f8 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000531e:	40d0                	lw	a2,4(s1)
    80005320:	00003597          	auipc	a1,0x3
    80005324:	3e058593          	addi	a1,a1,992 # 80008700 <syscalls+0x2b8>
    80005328:	8526                	mv	a0,s1
    8000532a:	fffff097          	auipc	ra,0xfffff
    8000532e:	c94080e7          	jalr	-876(ra) # 80003fbe <dirlink>
    80005332:	00054f63          	bltz	a0,80005350 <create+0x142>
    80005336:	00492603          	lw	a2,4(s2)
    8000533a:	00003597          	auipc	a1,0x3
    8000533e:	3ce58593          	addi	a1,a1,974 # 80008708 <syscalls+0x2c0>
    80005342:	8526                	mv	a0,s1
    80005344:	fffff097          	auipc	ra,0xfffff
    80005348:	c7a080e7          	jalr	-902(ra) # 80003fbe <dirlink>
    8000534c:	f80557e3          	bgez	a0,800052da <create+0xcc>
      panic("create dots");
    80005350:	00003517          	auipc	a0,0x3
    80005354:	3c050513          	addi	a0,a0,960 # 80008710 <syscalls+0x2c8>
    80005358:	ffffb097          	auipc	ra,0xffffb
    8000535c:	1e2080e7          	jalr	482(ra) # 8000053a <panic>
    panic("create: dirlink");
    80005360:	00003517          	auipc	a0,0x3
    80005364:	3c050513          	addi	a0,a0,960 # 80008720 <syscalls+0x2d8>
    80005368:	ffffb097          	auipc	ra,0xffffb
    8000536c:	1d2080e7          	jalr	466(ra) # 8000053a <panic>
    return 0;
    80005370:	84aa                	mv	s1,a0
    80005372:	b739                	j	80005280 <create+0x72>

0000000080005374 <sys_dup>:
{
    80005374:	7179                	addi	sp,sp,-48
    80005376:	f406                	sd	ra,40(sp)
    80005378:	f022                	sd	s0,32(sp)
    8000537a:	ec26                	sd	s1,24(sp)
    8000537c:	e84a                	sd	s2,16(sp)
    8000537e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005380:	fd840613          	addi	a2,s0,-40
    80005384:	4581                	li	a1,0
    80005386:	4501                	li	a0,0
    80005388:	00000097          	auipc	ra,0x0
    8000538c:	ddc080e7          	jalr	-548(ra) # 80005164 <argfd>
    return -1;
    80005390:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005392:	02054363          	bltz	a0,800053b8 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005396:	fd843903          	ld	s2,-40(s0)
    8000539a:	854a                	mv	a0,s2
    8000539c:	00000097          	auipc	ra,0x0
    800053a0:	e30080e7          	jalr	-464(ra) # 800051cc <fdalloc>
    800053a4:	84aa                	mv	s1,a0
    return -1;
    800053a6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053a8:	00054863          	bltz	a0,800053b8 <sys_dup+0x44>
  filedup(f);
    800053ac:	854a                	mv	a0,s2
    800053ae:	fffff097          	auipc	ra,0xfffff
    800053b2:	368080e7          	jalr	872(ra) # 80004716 <filedup>
  return fd;
    800053b6:	87a6                	mv	a5,s1
}
    800053b8:	853e                	mv	a0,a5
    800053ba:	70a2                	ld	ra,40(sp)
    800053bc:	7402                	ld	s0,32(sp)
    800053be:	64e2                	ld	s1,24(sp)
    800053c0:	6942                	ld	s2,16(sp)
    800053c2:	6145                	addi	sp,sp,48
    800053c4:	8082                	ret

00000000800053c6 <sys_read>:
{
    800053c6:	7179                	addi	sp,sp,-48
    800053c8:	f406                	sd	ra,40(sp)
    800053ca:	f022                	sd	s0,32(sp)
    800053cc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053ce:	fe840613          	addi	a2,s0,-24
    800053d2:	4581                	li	a1,0
    800053d4:	4501                	li	a0,0
    800053d6:	00000097          	auipc	ra,0x0
    800053da:	d8e080e7          	jalr	-626(ra) # 80005164 <argfd>
    return -1;
    800053de:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053e0:	04054163          	bltz	a0,80005422 <sys_read+0x5c>
    800053e4:	fe440593          	addi	a1,s0,-28
    800053e8:	4509                	li	a0,2
    800053ea:	ffffe097          	auipc	ra,0xffffe
    800053ee:	904080e7          	jalr	-1788(ra) # 80002cee <argint>
    return -1;
    800053f2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053f4:	02054763          	bltz	a0,80005422 <sys_read+0x5c>
    800053f8:	fd840593          	addi	a1,s0,-40
    800053fc:	4505                	li	a0,1
    800053fe:	ffffe097          	auipc	ra,0xffffe
    80005402:	912080e7          	jalr	-1774(ra) # 80002d10 <argaddr>
    return -1;
    80005406:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005408:	00054d63          	bltz	a0,80005422 <sys_read+0x5c>
  return fileread(f, p, n);
    8000540c:	fe442603          	lw	a2,-28(s0)
    80005410:	fd843583          	ld	a1,-40(s0)
    80005414:	fe843503          	ld	a0,-24(s0)
    80005418:	fffff097          	auipc	ra,0xfffff
    8000541c:	48a080e7          	jalr	1162(ra) # 800048a2 <fileread>
    80005420:	87aa                	mv	a5,a0
}
    80005422:	853e                	mv	a0,a5
    80005424:	70a2                	ld	ra,40(sp)
    80005426:	7402                	ld	s0,32(sp)
    80005428:	6145                	addi	sp,sp,48
    8000542a:	8082                	ret

000000008000542c <sys_write>:
{
    8000542c:	7179                	addi	sp,sp,-48
    8000542e:	f406                	sd	ra,40(sp)
    80005430:	f022                	sd	s0,32(sp)
    80005432:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005434:	fe840613          	addi	a2,s0,-24
    80005438:	4581                	li	a1,0
    8000543a:	4501                	li	a0,0
    8000543c:	00000097          	auipc	ra,0x0
    80005440:	d28080e7          	jalr	-728(ra) # 80005164 <argfd>
    return -1;
    80005444:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005446:	04054163          	bltz	a0,80005488 <sys_write+0x5c>
    8000544a:	fe440593          	addi	a1,s0,-28
    8000544e:	4509                	li	a0,2
    80005450:	ffffe097          	auipc	ra,0xffffe
    80005454:	89e080e7          	jalr	-1890(ra) # 80002cee <argint>
    return -1;
    80005458:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000545a:	02054763          	bltz	a0,80005488 <sys_write+0x5c>
    8000545e:	fd840593          	addi	a1,s0,-40
    80005462:	4505                	li	a0,1
    80005464:	ffffe097          	auipc	ra,0xffffe
    80005468:	8ac080e7          	jalr	-1876(ra) # 80002d10 <argaddr>
    return -1;
    8000546c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000546e:	00054d63          	bltz	a0,80005488 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005472:	fe442603          	lw	a2,-28(s0)
    80005476:	fd843583          	ld	a1,-40(s0)
    8000547a:	fe843503          	ld	a0,-24(s0)
    8000547e:	fffff097          	auipc	ra,0xfffff
    80005482:	4e6080e7          	jalr	1254(ra) # 80004964 <filewrite>
    80005486:	87aa                	mv	a5,a0
}
    80005488:	853e                	mv	a0,a5
    8000548a:	70a2                	ld	ra,40(sp)
    8000548c:	7402                	ld	s0,32(sp)
    8000548e:	6145                	addi	sp,sp,48
    80005490:	8082                	ret

0000000080005492 <sys_close>:
{
    80005492:	1101                	addi	sp,sp,-32
    80005494:	ec06                	sd	ra,24(sp)
    80005496:	e822                	sd	s0,16(sp)
    80005498:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000549a:	fe040613          	addi	a2,s0,-32
    8000549e:	fec40593          	addi	a1,s0,-20
    800054a2:	4501                	li	a0,0
    800054a4:	00000097          	auipc	ra,0x0
    800054a8:	cc0080e7          	jalr	-832(ra) # 80005164 <argfd>
    return -1;
    800054ac:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054ae:	02054463          	bltz	a0,800054d6 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054b2:	ffffc097          	auipc	ra,0xffffc
    800054b6:	4e4080e7          	jalr	1252(ra) # 80001996 <myproc>
    800054ba:	fec42783          	lw	a5,-20(s0)
    800054be:	07f1                	addi	a5,a5,28
    800054c0:	078e                	slli	a5,a5,0x3
    800054c2:	953e                	add	a0,a0,a5
    800054c4:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800054c8:	fe043503          	ld	a0,-32(s0)
    800054cc:	fffff097          	auipc	ra,0xfffff
    800054d0:	29c080e7          	jalr	668(ra) # 80004768 <fileclose>
  return 0;
    800054d4:	4781                	li	a5,0
}
    800054d6:	853e                	mv	a0,a5
    800054d8:	60e2                	ld	ra,24(sp)
    800054da:	6442                	ld	s0,16(sp)
    800054dc:	6105                	addi	sp,sp,32
    800054de:	8082                	ret

00000000800054e0 <sys_fstat>:
{
    800054e0:	1101                	addi	sp,sp,-32
    800054e2:	ec06                	sd	ra,24(sp)
    800054e4:	e822                	sd	s0,16(sp)
    800054e6:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054e8:	fe840613          	addi	a2,s0,-24
    800054ec:	4581                	li	a1,0
    800054ee:	4501                	li	a0,0
    800054f0:	00000097          	auipc	ra,0x0
    800054f4:	c74080e7          	jalr	-908(ra) # 80005164 <argfd>
    return -1;
    800054f8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800054fa:	02054563          	bltz	a0,80005524 <sys_fstat+0x44>
    800054fe:	fe040593          	addi	a1,s0,-32
    80005502:	4505                	li	a0,1
    80005504:	ffffe097          	auipc	ra,0xffffe
    80005508:	80c080e7          	jalr	-2036(ra) # 80002d10 <argaddr>
    return -1;
    8000550c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000550e:	00054b63          	bltz	a0,80005524 <sys_fstat+0x44>
  return filestat(f, st);
    80005512:	fe043583          	ld	a1,-32(s0)
    80005516:	fe843503          	ld	a0,-24(s0)
    8000551a:	fffff097          	auipc	ra,0xfffff
    8000551e:	316080e7          	jalr	790(ra) # 80004830 <filestat>
    80005522:	87aa                	mv	a5,a0
}
    80005524:	853e                	mv	a0,a5
    80005526:	60e2                	ld	ra,24(sp)
    80005528:	6442                	ld	s0,16(sp)
    8000552a:	6105                	addi	sp,sp,32
    8000552c:	8082                	ret

000000008000552e <sys_link>:
{
    8000552e:	7169                	addi	sp,sp,-304
    80005530:	f606                	sd	ra,296(sp)
    80005532:	f222                	sd	s0,288(sp)
    80005534:	ee26                	sd	s1,280(sp)
    80005536:	ea4a                	sd	s2,272(sp)
    80005538:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000553a:	08000613          	li	a2,128
    8000553e:	ed040593          	addi	a1,s0,-304
    80005542:	4501                	li	a0,0
    80005544:	ffffd097          	auipc	ra,0xffffd
    80005548:	7ee080e7          	jalr	2030(ra) # 80002d32 <argstr>
    return -1;
    8000554c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000554e:	10054e63          	bltz	a0,8000566a <sys_link+0x13c>
    80005552:	08000613          	li	a2,128
    80005556:	f5040593          	addi	a1,s0,-176
    8000555a:	4505                	li	a0,1
    8000555c:	ffffd097          	auipc	ra,0xffffd
    80005560:	7d6080e7          	jalr	2006(ra) # 80002d32 <argstr>
    return -1;
    80005564:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005566:	10054263          	bltz	a0,8000566a <sys_link+0x13c>
  begin_op();
    8000556a:	fffff097          	auipc	ra,0xfffff
    8000556e:	d36080e7          	jalr	-714(ra) # 800042a0 <begin_op>
  if((ip = namei(old)) == 0){
    80005572:	ed040513          	addi	a0,s0,-304
    80005576:	fffff097          	auipc	ra,0xfffff
    8000557a:	b0a080e7          	jalr	-1270(ra) # 80004080 <namei>
    8000557e:	84aa                	mv	s1,a0
    80005580:	c551                	beqz	a0,8000560c <sys_link+0xde>
  ilock(ip);
    80005582:	ffffe097          	auipc	ra,0xffffe
    80005586:	342080e7          	jalr	834(ra) # 800038c4 <ilock>
  if(ip->type == T_DIR){
    8000558a:	04449703          	lh	a4,68(s1)
    8000558e:	4785                	li	a5,1
    80005590:	08f70463          	beq	a4,a5,80005618 <sys_link+0xea>
  ip->nlink++;
    80005594:	04a4d783          	lhu	a5,74(s1)
    80005598:	2785                	addiw	a5,a5,1
    8000559a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000559e:	8526                	mv	a0,s1
    800055a0:	ffffe097          	auipc	ra,0xffffe
    800055a4:	258080e7          	jalr	600(ra) # 800037f8 <iupdate>
  iunlock(ip);
    800055a8:	8526                	mv	a0,s1
    800055aa:	ffffe097          	auipc	ra,0xffffe
    800055ae:	3dc080e7          	jalr	988(ra) # 80003986 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055b2:	fd040593          	addi	a1,s0,-48
    800055b6:	f5040513          	addi	a0,s0,-176
    800055ba:	fffff097          	auipc	ra,0xfffff
    800055be:	ae4080e7          	jalr	-1308(ra) # 8000409e <nameiparent>
    800055c2:	892a                	mv	s2,a0
    800055c4:	c935                	beqz	a0,80005638 <sys_link+0x10a>
  ilock(dp);
    800055c6:	ffffe097          	auipc	ra,0xffffe
    800055ca:	2fe080e7          	jalr	766(ra) # 800038c4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800055ce:	00092703          	lw	a4,0(s2)
    800055d2:	409c                	lw	a5,0(s1)
    800055d4:	04f71d63          	bne	a4,a5,8000562e <sys_link+0x100>
    800055d8:	40d0                	lw	a2,4(s1)
    800055da:	fd040593          	addi	a1,s0,-48
    800055de:	854a                	mv	a0,s2
    800055e0:	fffff097          	auipc	ra,0xfffff
    800055e4:	9de080e7          	jalr	-1570(ra) # 80003fbe <dirlink>
    800055e8:	04054363          	bltz	a0,8000562e <sys_link+0x100>
  iunlockput(dp);
    800055ec:	854a                	mv	a0,s2
    800055ee:	ffffe097          	auipc	ra,0xffffe
    800055f2:	538080e7          	jalr	1336(ra) # 80003b26 <iunlockput>
  iput(ip);
    800055f6:	8526                	mv	a0,s1
    800055f8:	ffffe097          	auipc	ra,0xffffe
    800055fc:	486080e7          	jalr	1158(ra) # 80003a7e <iput>
  end_op();
    80005600:	fffff097          	auipc	ra,0xfffff
    80005604:	d1e080e7          	jalr	-738(ra) # 8000431e <end_op>
  return 0;
    80005608:	4781                	li	a5,0
    8000560a:	a085                	j	8000566a <sys_link+0x13c>
    end_op();
    8000560c:	fffff097          	auipc	ra,0xfffff
    80005610:	d12080e7          	jalr	-750(ra) # 8000431e <end_op>
    return -1;
    80005614:	57fd                	li	a5,-1
    80005616:	a891                	j	8000566a <sys_link+0x13c>
    iunlockput(ip);
    80005618:	8526                	mv	a0,s1
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	50c080e7          	jalr	1292(ra) # 80003b26 <iunlockput>
    end_op();
    80005622:	fffff097          	auipc	ra,0xfffff
    80005626:	cfc080e7          	jalr	-772(ra) # 8000431e <end_op>
    return -1;
    8000562a:	57fd                	li	a5,-1
    8000562c:	a83d                	j	8000566a <sys_link+0x13c>
    iunlockput(dp);
    8000562e:	854a                	mv	a0,s2
    80005630:	ffffe097          	auipc	ra,0xffffe
    80005634:	4f6080e7          	jalr	1270(ra) # 80003b26 <iunlockput>
  ilock(ip);
    80005638:	8526                	mv	a0,s1
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	28a080e7          	jalr	650(ra) # 800038c4 <ilock>
  ip->nlink--;
    80005642:	04a4d783          	lhu	a5,74(s1)
    80005646:	37fd                	addiw	a5,a5,-1
    80005648:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000564c:	8526                	mv	a0,s1
    8000564e:	ffffe097          	auipc	ra,0xffffe
    80005652:	1aa080e7          	jalr	426(ra) # 800037f8 <iupdate>
  iunlockput(ip);
    80005656:	8526                	mv	a0,s1
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	4ce080e7          	jalr	1230(ra) # 80003b26 <iunlockput>
  end_op();
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	cbe080e7          	jalr	-834(ra) # 8000431e <end_op>
  return -1;
    80005668:	57fd                	li	a5,-1
}
    8000566a:	853e                	mv	a0,a5
    8000566c:	70b2                	ld	ra,296(sp)
    8000566e:	7412                	ld	s0,288(sp)
    80005670:	64f2                	ld	s1,280(sp)
    80005672:	6952                	ld	s2,272(sp)
    80005674:	6155                	addi	sp,sp,304
    80005676:	8082                	ret

0000000080005678 <sys_unlink>:
{
    80005678:	7151                	addi	sp,sp,-240
    8000567a:	f586                	sd	ra,232(sp)
    8000567c:	f1a2                	sd	s0,224(sp)
    8000567e:	eda6                	sd	s1,216(sp)
    80005680:	e9ca                	sd	s2,208(sp)
    80005682:	e5ce                	sd	s3,200(sp)
    80005684:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005686:	08000613          	li	a2,128
    8000568a:	f3040593          	addi	a1,s0,-208
    8000568e:	4501                	li	a0,0
    80005690:	ffffd097          	auipc	ra,0xffffd
    80005694:	6a2080e7          	jalr	1698(ra) # 80002d32 <argstr>
    80005698:	18054163          	bltz	a0,8000581a <sys_unlink+0x1a2>
  begin_op();
    8000569c:	fffff097          	auipc	ra,0xfffff
    800056a0:	c04080e7          	jalr	-1020(ra) # 800042a0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056a4:	fb040593          	addi	a1,s0,-80
    800056a8:	f3040513          	addi	a0,s0,-208
    800056ac:	fffff097          	auipc	ra,0xfffff
    800056b0:	9f2080e7          	jalr	-1550(ra) # 8000409e <nameiparent>
    800056b4:	84aa                	mv	s1,a0
    800056b6:	c979                	beqz	a0,8000578c <sys_unlink+0x114>
  ilock(dp);
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	20c080e7          	jalr	524(ra) # 800038c4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056c0:	00003597          	auipc	a1,0x3
    800056c4:	04058593          	addi	a1,a1,64 # 80008700 <syscalls+0x2b8>
    800056c8:	fb040513          	addi	a0,s0,-80
    800056cc:	ffffe097          	auipc	ra,0xffffe
    800056d0:	6c2080e7          	jalr	1730(ra) # 80003d8e <namecmp>
    800056d4:	14050a63          	beqz	a0,80005828 <sys_unlink+0x1b0>
    800056d8:	00003597          	auipc	a1,0x3
    800056dc:	03058593          	addi	a1,a1,48 # 80008708 <syscalls+0x2c0>
    800056e0:	fb040513          	addi	a0,s0,-80
    800056e4:	ffffe097          	auipc	ra,0xffffe
    800056e8:	6aa080e7          	jalr	1706(ra) # 80003d8e <namecmp>
    800056ec:	12050e63          	beqz	a0,80005828 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800056f0:	f2c40613          	addi	a2,s0,-212
    800056f4:	fb040593          	addi	a1,s0,-80
    800056f8:	8526                	mv	a0,s1
    800056fa:	ffffe097          	auipc	ra,0xffffe
    800056fe:	6ae080e7          	jalr	1710(ra) # 80003da8 <dirlookup>
    80005702:	892a                	mv	s2,a0
    80005704:	12050263          	beqz	a0,80005828 <sys_unlink+0x1b0>
  ilock(ip);
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	1bc080e7          	jalr	444(ra) # 800038c4 <ilock>
  if(ip->nlink < 1)
    80005710:	04a91783          	lh	a5,74(s2)
    80005714:	08f05263          	blez	a5,80005798 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005718:	04491703          	lh	a4,68(s2)
    8000571c:	4785                	li	a5,1
    8000571e:	08f70563          	beq	a4,a5,800057a8 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005722:	4641                	li	a2,16
    80005724:	4581                	li	a1,0
    80005726:	fc040513          	addi	a0,s0,-64
    8000572a:	ffffb097          	auipc	ra,0xffffb
    8000572e:	5a2080e7          	jalr	1442(ra) # 80000ccc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005732:	4741                	li	a4,16
    80005734:	f2c42683          	lw	a3,-212(s0)
    80005738:	fc040613          	addi	a2,s0,-64
    8000573c:	4581                	li	a1,0
    8000573e:	8526                	mv	a0,s1
    80005740:	ffffe097          	auipc	ra,0xffffe
    80005744:	530080e7          	jalr	1328(ra) # 80003c70 <writei>
    80005748:	47c1                	li	a5,16
    8000574a:	0af51563          	bne	a0,a5,800057f4 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000574e:	04491703          	lh	a4,68(s2)
    80005752:	4785                	li	a5,1
    80005754:	0af70863          	beq	a4,a5,80005804 <sys_unlink+0x18c>
  iunlockput(dp);
    80005758:	8526                	mv	a0,s1
    8000575a:	ffffe097          	auipc	ra,0xffffe
    8000575e:	3cc080e7          	jalr	972(ra) # 80003b26 <iunlockput>
  ip->nlink--;
    80005762:	04a95783          	lhu	a5,74(s2)
    80005766:	37fd                	addiw	a5,a5,-1
    80005768:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000576c:	854a                	mv	a0,s2
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	08a080e7          	jalr	138(ra) # 800037f8 <iupdate>
  iunlockput(ip);
    80005776:	854a                	mv	a0,s2
    80005778:	ffffe097          	auipc	ra,0xffffe
    8000577c:	3ae080e7          	jalr	942(ra) # 80003b26 <iunlockput>
  end_op();
    80005780:	fffff097          	auipc	ra,0xfffff
    80005784:	b9e080e7          	jalr	-1122(ra) # 8000431e <end_op>
  return 0;
    80005788:	4501                	li	a0,0
    8000578a:	a84d                	j	8000583c <sys_unlink+0x1c4>
    end_op();
    8000578c:	fffff097          	auipc	ra,0xfffff
    80005790:	b92080e7          	jalr	-1134(ra) # 8000431e <end_op>
    return -1;
    80005794:	557d                	li	a0,-1
    80005796:	a05d                	j	8000583c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005798:	00003517          	auipc	a0,0x3
    8000579c:	f9850513          	addi	a0,a0,-104 # 80008730 <syscalls+0x2e8>
    800057a0:	ffffb097          	auipc	ra,0xffffb
    800057a4:	d9a080e7          	jalr	-614(ra) # 8000053a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057a8:	04c92703          	lw	a4,76(s2)
    800057ac:	02000793          	li	a5,32
    800057b0:	f6e7f9e3          	bgeu	a5,a4,80005722 <sys_unlink+0xaa>
    800057b4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057b8:	4741                	li	a4,16
    800057ba:	86ce                	mv	a3,s3
    800057bc:	f1840613          	addi	a2,s0,-232
    800057c0:	4581                	li	a1,0
    800057c2:	854a                	mv	a0,s2
    800057c4:	ffffe097          	auipc	ra,0xffffe
    800057c8:	3b4080e7          	jalr	948(ra) # 80003b78 <readi>
    800057cc:	47c1                	li	a5,16
    800057ce:	00f51b63          	bne	a0,a5,800057e4 <sys_unlink+0x16c>
    if(de.inum != 0)
    800057d2:	f1845783          	lhu	a5,-232(s0)
    800057d6:	e7a1                	bnez	a5,8000581e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057d8:	29c1                	addiw	s3,s3,16
    800057da:	04c92783          	lw	a5,76(s2)
    800057de:	fcf9ede3          	bltu	s3,a5,800057b8 <sys_unlink+0x140>
    800057e2:	b781                	j	80005722 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800057e4:	00003517          	auipc	a0,0x3
    800057e8:	f6450513          	addi	a0,a0,-156 # 80008748 <syscalls+0x300>
    800057ec:	ffffb097          	auipc	ra,0xffffb
    800057f0:	d4e080e7          	jalr	-690(ra) # 8000053a <panic>
    panic("unlink: writei");
    800057f4:	00003517          	auipc	a0,0x3
    800057f8:	f6c50513          	addi	a0,a0,-148 # 80008760 <syscalls+0x318>
    800057fc:	ffffb097          	auipc	ra,0xffffb
    80005800:	d3e080e7          	jalr	-706(ra) # 8000053a <panic>
    dp->nlink--;
    80005804:	04a4d783          	lhu	a5,74(s1)
    80005808:	37fd                	addiw	a5,a5,-1
    8000580a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000580e:	8526                	mv	a0,s1
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	fe8080e7          	jalr	-24(ra) # 800037f8 <iupdate>
    80005818:	b781                	j	80005758 <sys_unlink+0xe0>
    return -1;
    8000581a:	557d                	li	a0,-1
    8000581c:	a005                	j	8000583c <sys_unlink+0x1c4>
    iunlockput(ip);
    8000581e:	854a                	mv	a0,s2
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	306080e7          	jalr	774(ra) # 80003b26 <iunlockput>
  iunlockput(dp);
    80005828:	8526                	mv	a0,s1
    8000582a:	ffffe097          	auipc	ra,0xffffe
    8000582e:	2fc080e7          	jalr	764(ra) # 80003b26 <iunlockput>
  end_op();
    80005832:	fffff097          	auipc	ra,0xfffff
    80005836:	aec080e7          	jalr	-1300(ra) # 8000431e <end_op>
  return -1;
    8000583a:	557d                	li	a0,-1
}
    8000583c:	70ae                	ld	ra,232(sp)
    8000583e:	740e                	ld	s0,224(sp)
    80005840:	64ee                	ld	s1,216(sp)
    80005842:	694e                	ld	s2,208(sp)
    80005844:	69ae                	ld	s3,200(sp)
    80005846:	616d                	addi	sp,sp,240
    80005848:	8082                	ret

000000008000584a <sys_open>:

uint64
sys_open(void)
{
    8000584a:	7131                	addi	sp,sp,-192
    8000584c:	fd06                	sd	ra,184(sp)
    8000584e:	f922                	sd	s0,176(sp)
    80005850:	f526                	sd	s1,168(sp)
    80005852:	f14a                	sd	s2,160(sp)
    80005854:	ed4e                	sd	s3,152(sp)
    80005856:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005858:	08000613          	li	a2,128
    8000585c:	f5040593          	addi	a1,s0,-176
    80005860:	4501                	li	a0,0
    80005862:	ffffd097          	auipc	ra,0xffffd
    80005866:	4d0080e7          	jalr	1232(ra) # 80002d32 <argstr>
    return -1;
    8000586a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000586c:	0c054163          	bltz	a0,8000592e <sys_open+0xe4>
    80005870:	f4c40593          	addi	a1,s0,-180
    80005874:	4505                	li	a0,1
    80005876:	ffffd097          	auipc	ra,0xffffd
    8000587a:	478080e7          	jalr	1144(ra) # 80002cee <argint>
    8000587e:	0a054863          	bltz	a0,8000592e <sys_open+0xe4>

  begin_op();
    80005882:	fffff097          	auipc	ra,0xfffff
    80005886:	a1e080e7          	jalr	-1506(ra) # 800042a0 <begin_op>

  if(omode & O_CREATE){
    8000588a:	f4c42783          	lw	a5,-180(s0)
    8000588e:	2007f793          	andi	a5,a5,512
    80005892:	cbdd                	beqz	a5,80005948 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005894:	4681                	li	a3,0
    80005896:	4601                	li	a2,0
    80005898:	4589                	li	a1,2
    8000589a:	f5040513          	addi	a0,s0,-176
    8000589e:	00000097          	auipc	ra,0x0
    800058a2:	970080e7          	jalr	-1680(ra) # 8000520e <create>
    800058a6:	892a                	mv	s2,a0
    if(ip == 0){
    800058a8:	c959                	beqz	a0,8000593e <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058aa:	04491703          	lh	a4,68(s2)
    800058ae:	478d                	li	a5,3
    800058b0:	00f71763          	bne	a4,a5,800058be <sys_open+0x74>
    800058b4:	04695703          	lhu	a4,70(s2)
    800058b8:	47a5                	li	a5,9
    800058ba:	0ce7ec63          	bltu	a5,a4,80005992 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058be:	fffff097          	auipc	ra,0xfffff
    800058c2:	dee080e7          	jalr	-530(ra) # 800046ac <filealloc>
    800058c6:	89aa                	mv	s3,a0
    800058c8:	10050263          	beqz	a0,800059cc <sys_open+0x182>
    800058cc:	00000097          	auipc	ra,0x0
    800058d0:	900080e7          	jalr	-1792(ra) # 800051cc <fdalloc>
    800058d4:	84aa                	mv	s1,a0
    800058d6:	0e054663          	bltz	a0,800059c2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800058da:	04491703          	lh	a4,68(s2)
    800058de:	478d                	li	a5,3
    800058e0:	0cf70463          	beq	a4,a5,800059a8 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800058e4:	4789                	li	a5,2
    800058e6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800058ea:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800058ee:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800058f2:	f4c42783          	lw	a5,-180(s0)
    800058f6:	0017c713          	xori	a4,a5,1
    800058fa:	8b05                	andi	a4,a4,1
    800058fc:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005900:	0037f713          	andi	a4,a5,3
    80005904:	00e03733          	snez	a4,a4
    80005908:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000590c:	4007f793          	andi	a5,a5,1024
    80005910:	c791                	beqz	a5,8000591c <sys_open+0xd2>
    80005912:	04491703          	lh	a4,68(s2)
    80005916:	4789                	li	a5,2
    80005918:	08f70f63          	beq	a4,a5,800059b6 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000591c:	854a                	mv	a0,s2
    8000591e:	ffffe097          	auipc	ra,0xffffe
    80005922:	068080e7          	jalr	104(ra) # 80003986 <iunlock>
  end_op();
    80005926:	fffff097          	auipc	ra,0xfffff
    8000592a:	9f8080e7          	jalr	-1544(ra) # 8000431e <end_op>

  return fd;
}
    8000592e:	8526                	mv	a0,s1
    80005930:	70ea                	ld	ra,184(sp)
    80005932:	744a                	ld	s0,176(sp)
    80005934:	74aa                	ld	s1,168(sp)
    80005936:	790a                	ld	s2,160(sp)
    80005938:	69ea                	ld	s3,152(sp)
    8000593a:	6129                	addi	sp,sp,192
    8000593c:	8082                	ret
      end_op();
    8000593e:	fffff097          	auipc	ra,0xfffff
    80005942:	9e0080e7          	jalr	-1568(ra) # 8000431e <end_op>
      return -1;
    80005946:	b7e5                	j	8000592e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005948:	f5040513          	addi	a0,s0,-176
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	734080e7          	jalr	1844(ra) # 80004080 <namei>
    80005954:	892a                	mv	s2,a0
    80005956:	c905                	beqz	a0,80005986 <sys_open+0x13c>
    ilock(ip);
    80005958:	ffffe097          	auipc	ra,0xffffe
    8000595c:	f6c080e7          	jalr	-148(ra) # 800038c4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005960:	04491703          	lh	a4,68(s2)
    80005964:	4785                	li	a5,1
    80005966:	f4f712e3          	bne	a4,a5,800058aa <sys_open+0x60>
    8000596a:	f4c42783          	lw	a5,-180(s0)
    8000596e:	dba1                	beqz	a5,800058be <sys_open+0x74>
      iunlockput(ip);
    80005970:	854a                	mv	a0,s2
    80005972:	ffffe097          	auipc	ra,0xffffe
    80005976:	1b4080e7          	jalr	436(ra) # 80003b26 <iunlockput>
      end_op();
    8000597a:	fffff097          	auipc	ra,0xfffff
    8000597e:	9a4080e7          	jalr	-1628(ra) # 8000431e <end_op>
      return -1;
    80005982:	54fd                	li	s1,-1
    80005984:	b76d                	j	8000592e <sys_open+0xe4>
      end_op();
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	998080e7          	jalr	-1640(ra) # 8000431e <end_op>
      return -1;
    8000598e:	54fd                	li	s1,-1
    80005990:	bf79                	j	8000592e <sys_open+0xe4>
    iunlockput(ip);
    80005992:	854a                	mv	a0,s2
    80005994:	ffffe097          	auipc	ra,0xffffe
    80005998:	192080e7          	jalr	402(ra) # 80003b26 <iunlockput>
    end_op();
    8000599c:	fffff097          	auipc	ra,0xfffff
    800059a0:	982080e7          	jalr	-1662(ra) # 8000431e <end_op>
    return -1;
    800059a4:	54fd                	li	s1,-1
    800059a6:	b761                	j	8000592e <sys_open+0xe4>
    f->type = FD_DEVICE;
    800059a8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059ac:	04691783          	lh	a5,70(s2)
    800059b0:	02f99223          	sh	a5,36(s3)
    800059b4:	bf2d                	j	800058ee <sys_open+0xa4>
    itrunc(ip);
    800059b6:	854a                	mv	a0,s2
    800059b8:	ffffe097          	auipc	ra,0xffffe
    800059bc:	01a080e7          	jalr	26(ra) # 800039d2 <itrunc>
    800059c0:	bfb1                	j	8000591c <sys_open+0xd2>
      fileclose(f);
    800059c2:	854e                	mv	a0,s3
    800059c4:	fffff097          	auipc	ra,0xfffff
    800059c8:	da4080e7          	jalr	-604(ra) # 80004768 <fileclose>
    iunlockput(ip);
    800059cc:	854a                	mv	a0,s2
    800059ce:	ffffe097          	auipc	ra,0xffffe
    800059d2:	158080e7          	jalr	344(ra) # 80003b26 <iunlockput>
    end_op();
    800059d6:	fffff097          	auipc	ra,0xfffff
    800059da:	948080e7          	jalr	-1720(ra) # 8000431e <end_op>
    return -1;
    800059de:	54fd                	li	s1,-1
    800059e0:	b7b9                	j	8000592e <sys_open+0xe4>

00000000800059e2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800059e2:	7175                	addi	sp,sp,-144
    800059e4:	e506                	sd	ra,136(sp)
    800059e6:	e122                	sd	s0,128(sp)
    800059e8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800059ea:	fffff097          	auipc	ra,0xfffff
    800059ee:	8b6080e7          	jalr	-1866(ra) # 800042a0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800059f2:	08000613          	li	a2,128
    800059f6:	f7040593          	addi	a1,s0,-144
    800059fa:	4501                	li	a0,0
    800059fc:	ffffd097          	auipc	ra,0xffffd
    80005a00:	336080e7          	jalr	822(ra) # 80002d32 <argstr>
    80005a04:	02054963          	bltz	a0,80005a36 <sys_mkdir+0x54>
    80005a08:	4681                	li	a3,0
    80005a0a:	4601                	li	a2,0
    80005a0c:	4585                	li	a1,1
    80005a0e:	f7040513          	addi	a0,s0,-144
    80005a12:	fffff097          	auipc	ra,0xfffff
    80005a16:	7fc080e7          	jalr	2044(ra) # 8000520e <create>
    80005a1a:	cd11                	beqz	a0,80005a36 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a1c:	ffffe097          	auipc	ra,0xffffe
    80005a20:	10a080e7          	jalr	266(ra) # 80003b26 <iunlockput>
  end_op();
    80005a24:	fffff097          	auipc	ra,0xfffff
    80005a28:	8fa080e7          	jalr	-1798(ra) # 8000431e <end_op>
  return 0;
    80005a2c:	4501                	li	a0,0
}
    80005a2e:	60aa                	ld	ra,136(sp)
    80005a30:	640a                	ld	s0,128(sp)
    80005a32:	6149                	addi	sp,sp,144
    80005a34:	8082                	ret
    end_op();
    80005a36:	fffff097          	auipc	ra,0xfffff
    80005a3a:	8e8080e7          	jalr	-1816(ra) # 8000431e <end_op>
    return -1;
    80005a3e:	557d                	li	a0,-1
    80005a40:	b7fd                	j	80005a2e <sys_mkdir+0x4c>

0000000080005a42 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a42:	7135                	addi	sp,sp,-160
    80005a44:	ed06                	sd	ra,152(sp)
    80005a46:	e922                	sd	s0,144(sp)
    80005a48:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a4a:	fffff097          	auipc	ra,0xfffff
    80005a4e:	856080e7          	jalr	-1962(ra) # 800042a0 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a52:	08000613          	li	a2,128
    80005a56:	f7040593          	addi	a1,s0,-144
    80005a5a:	4501                	li	a0,0
    80005a5c:	ffffd097          	auipc	ra,0xffffd
    80005a60:	2d6080e7          	jalr	726(ra) # 80002d32 <argstr>
    80005a64:	04054a63          	bltz	a0,80005ab8 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005a68:	f6c40593          	addi	a1,s0,-148
    80005a6c:	4505                	li	a0,1
    80005a6e:	ffffd097          	auipc	ra,0xffffd
    80005a72:	280080e7          	jalr	640(ra) # 80002cee <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a76:	04054163          	bltz	a0,80005ab8 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005a7a:	f6840593          	addi	a1,s0,-152
    80005a7e:	4509                	li	a0,2
    80005a80:	ffffd097          	auipc	ra,0xffffd
    80005a84:	26e080e7          	jalr	622(ra) # 80002cee <argint>
     argint(1, &major) < 0 ||
    80005a88:	02054863          	bltz	a0,80005ab8 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a8c:	f6841683          	lh	a3,-152(s0)
    80005a90:	f6c41603          	lh	a2,-148(s0)
    80005a94:	458d                	li	a1,3
    80005a96:	f7040513          	addi	a0,s0,-144
    80005a9a:	fffff097          	auipc	ra,0xfffff
    80005a9e:	774080e7          	jalr	1908(ra) # 8000520e <create>
     argint(2, &minor) < 0 ||
    80005aa2:	c919                	beqz	a0,80005ab8 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005aa4:	ffffe097          	auipc	ra,0xffffe
    80005aa8:	082080e7          	jalr	130(ra) # 80003b26 <iunlockput>
  end_op();
    80005aac:	fffff097          	auipc	ra,0xfffff
    80005ab0:	872080e7          	jalr	-1934(ra) # 8000431e <end_op>
  return 0;
    80005ab4:	4501                	li	a0,0
    80005ab6:	a031                	j	80005ac2 <sys_mknod+0x80>
    end_op();
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	866080e7          	jalr	-1946(ra) # 8000431e <end_op>
    return -1;
    80005ac0:	557d                	li	a0,-1
}
    80005ac2:	60ea                	ld	ra,152(sp)
    80005ac4:	644a                	ld	s0,144(sp)
    80005ac6:	610d                	addi	sp,sp,160
    80005ac8:	8082                	ret

0000000080005aca <sys_chdir>:

uint64
sys_chdir(void)
{
    80005aca:	7135                	addi	sp,sp,-160
    80005acc:	ed06                	sd	ra,152(sp)
    80005ace:	e922                	sd	s0,144(sp)
    80005ad0:	e526                	sd	s1,136(sp)
    80005ad2:	e14a                	sd	s2,128(sp)
    80005ad4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ad6:	ffffc097          	auipc	ra,0xffffc
    80005ada:	ec0080e7          	jalr	-320(ra) # 80001996 <myproc>
    80005ade:	892a                	mv	s2,a0
  
  begin_op();
    80005ae0:	ffffe097          	auipc	ra,0xffffe
    80005ae4:	7c0080e7          	jalr	1984(ra) # 800042a0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ae8:	08000613          	li	a2,128
    80005aec:	f6040593          	addi	a1,s0,-160
    80005af0:	4501                	li	a0,0
    80005af2:	ffffd097          	auipc	ra,0xffffd
    80005af6:	240080e7          	jalr	576(ra) # 80002d32 <argstr>
    80005afa:	04054b63          	bltz	a0,80005b50 <sys_chdir+0x86>
    80005afe:	f6040513          	addi	a0,s0,-160
    80005b02:	ffffe097          	auipc	ra,0xffffe
    80005b06:	57e080e7          	jalr	1406(ra) # 80004080 <namei>
    80005b0a:	84aa                	mv	s1,a0
    80005b0c:	c131                	beqz	a0,80005b50 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	db6080e7          	jalr	-586(ra) # 800038c4 <ilock>
  if(ip->type != T_DIR){
    80005b16:	04449703          	lh	a4,68(s1)
    80005b1a:	4785                	li	a5,1
    80005b1c:	04f71063          	bne	a4,a5,80005b5c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b20:	8526                	mv	a0,s1
    80005b22:	ffffe097          	auipc	ra,0xffffe
    80005b26:	e64080e7          	jalr	-412(ra) # 80003986 <iunlock>
  iput(p->cwd);
    80005b2a:	16093503          	ld	a0,352(s2)
    80005b2e:	ffffe097          	auipc	ra,0xffffe
    80005b32:	f50080e7          	jalr	-176(ra) # 80003a7e <iput>
  end_op();
    80005b36:	ffffe097          	auipc	ra,0xffffe
    80005b3a:	7e8080e7          	jalr	2024(ra) # 8000431e <end_op>
  p->cwd = ip;
    80005b3e:	16993023          	sd	s1,352(s2)
  return 0;
    80005b42:	4501                	li	a0,0
}
    80005b44:	60ea                	ld	ra,152(sp)
    80005b46:	644a                	ld	s0,144(sp)
    80005b48:	64aa                	ld	s1,136(sp)
    80005b4a:	690a                	ld	s2,128(sp)
    80005b4c:	610d                	addi	sp,sp,160
    80005b4e:	8082                	ret
    end_op();
    80005b50:	ffffe097          	auipc	ra,0xffffe
    80005b54:	7ce080e7          	jalr	1998(ra) # 8000431e <end_op>
    return -1;
    80005b58:	557d                	li	a0,-1
    80005b5a:	b7ed                	j	80005b44 <sys_chdir+0x7a>
    iunlockput(ip);
    80005b5c:	8526                	mv	a0,s1
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	fc8080e7          	jalr	-56(ra) # 80003b26 <iunlockput>
    end_op();
    80005b66:	ffffe097          	auipc	ra,0xffffe
    80005b6a:	7b8080e7          	jalr	1976(ra) # 8000431e <end_op>
    return -1;
    80005b6e:	557d                	li	a0,-1
    80005b70:	bfd1                	j	80005b44 <sys_chdir+0x7a>

0000000080005b72 <sys_exec>:

uint64
sys_exec(void)
{
    80005b72:	7145                	addi	sp,sp,-464
    80005b74:	e786                	sd	ra,456(sp)
    80005b76:	e3a2                	sd	s0,448(sp)
    80005b78:	ff26                	sd	s1,440(sp)
    80005b7a:	fb4a                	sd	s2,432(sp)
    80005b7c:	f74e                	sd	s3,424(sp)
    80005b7e:	f352                	sd	s4,416(sp)
    80005b80:	ef56                	sd	s5,408(sp)
    80005b82:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005b84:	08000613          	li	a2,128
    80005b88:	f4040593          	addi	a1,s0,-192
    80005b8c:	4501                	li	a0,0
    80005b8e:	ffffd097          	auipc	ra,0xffffd
    80005b92:	1a4080e7          	jalr	420(ra) # 80002d32 <argstr>
    return -1;
    80005b96:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005b98:	0c054b63          	bltz	a0,80005c6e <sys_exec+0xfc>
    80005b9c:	e3840593          	addi	a1,s0,-456
    80005ba0:	4505                	li	a0,1
    80005ba2:	ffffd097          	auipc	ra,0xffffd
    80005ba6:	16e080e7          	jalr	366(ra) # 80002d10 <argaddr>
    80005baa:	0c054263          	bltz	a0,80005c6e <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005bae:	10000613          	li	a2,256
    80005bb2:	4581                	li	a1,0
    80005bb4:	e4040513          	addi	a0,s0,-448
    80005bb8:	ffffb097          	auipc	ra,0xffffb
    80005bbc:	114080e7          	jalr	276(ra) # 80000ccc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005bc0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005bc4:	89a6                	mv	s3,s1
    80005bc6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005bc8:	02000a13          	li	s4,32
    80005bcc:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005bd0:	00391513          	slli	a0,s2,0x3
    80005bd4:	e3040593          	addi	a1,s0,-464
    80005bd8:	e3843783          	ld	a5,-456(s0)
    80005bdc:	953e                	add	a0,a0,a5
    80005bde:	ffffd097          	auipc	ra,0xffffd
    80005be2:	076080e7          	jalr	118(ra) # 80002c54 <fetchaddr>
    80005be6:	02054a63          	bltz	a0,80005c1a <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005bea:	e3043783          	ld	a5,-464(s0)
    80005bee:	c3b9                	beqz	a5,80005c34 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005bf0:	ffffb097          	auipc	ra,0xffffb
    80005bf4:	ef0080e7          	jalr	-272(ra) # 80000ae0 <kalloc>
    80005bf8:	85aa                	mv	a1,a0
    80005bfa:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005bfe:	cd11                	beqz	a0,80005c1a <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c00:	6605                	lui	a2,0x1
    80005c02:	e3043503          	ld	a0,-464(s0)
    80005c06:	ffffd097          	auipc	ra,0xffffd
    80005c0a:	0a0080e7          	jalr	160(ra) # 80002ca6 <fetchstr>
    80005c0e:	00054663          	bltz	a0,80005c1a <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005c12:	0905                	addi	s2,s2,1
    80005c14:	09a1                	addi	s3,s3,8
    80005c16:	fb491be3          	bne	s2,s4,80005bcc <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c1a:	f4040913          	addi	s2,s0,-192
    80005c1e:	6088                	ld	a0,0(s1)
    80005c20:	c531                	beqz	a0,80005c6c <sys_exec+0xfa>
    kfree(argv[i]);
    80005c22:	ffffb097          	auipc	ra,0xffffb
    80005c26:	dc0080e7          	jalr	-576(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c2a:	04a1                	addi	s1,s1,8
    80005c2c:	ff2499e3          	bne	s1,s2,80005c1e <sys_exec+0xac>
  return -1;
    80005c30:	597d                	li	s2,-1
    80005c32:	a835                	j	80005c6e <sys_exec+0xfc>
      argv[i] = 0;
    80005c34:	0a8e                	slli	s5,s5,0x3
    80005c36:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd8fc0>
    80005c3a:	00878ab3          	add	s5,a5,s0
    80005c3e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005c42:	e4040593          	addi	a1,s0,-448
    80005c46:	f4040513          	addi	a0,s0,-192
    80005c4a:	fffff097          	auipc	ra,0xfffff
    80005c4e:	172080e7          	jalr	370(ra) # 80004dbc <exec>
    80005c52:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c54:	f4040993          	addi	s3,s0,-192
    80005c58:	6088                	ld	a0,0(s1)
    80005c5a:	c911                	beqz	a0,80005c6e <sys_exec+0xfc>
    kfree(argv[i]);
    80005c5c:	ffffb097          	auipc	ra,0xffffb
    80005c60:	d86080e7          	jalr	-634(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c64:	04a1                	addi	s1,s1,8
    80005c66:	ff3499e3          	bne	s1,s3,80005c58 <sys_exec+0xe6>
    80005c6a:	a011                	j	80005c6e <sys_exec+0xfc>
  return -1;
    80005c6c:	597d                	li	s2,-1
}
    80005c6e:	854a                	mv	a0,s2
    80005c70:	60be                	ld	ra,456(sp)
    80005c72:	641e                	ld	s0,448(sp)
    80005c74:	74fa                	ld	s1,440(sp)
    80005c76:	795a                	ld	s2,432(sp)
    80005c78:	79ba                	ld	s3,424(sp)
    80005c7a:	7a1a                	ld	s4,416(sp)
    80005c7c:	6afa                	ld	s5,408(sp)
    80005c7e:	6179                	addi	sp,sp,464
    80005c80:	8082                	ret

0000000080005c82 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c82:	7139                	addi	sp,sp,-64
    80005c84:	fc06                	sd	ra,56(sp)
    80005c86:	f822                	sd	s0,48(sp)
    80005c88:	f426                	sd	s1,40(sp)
    80005c8a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c8c:	ffffc097          	auipc	ra,0xffffc
    80005c90:	d0a080e7          	jalr	-758(ra) # 80001996 <myproc>
    80005c94:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005c96:	fd840593          	addi	a1,s0,-40
    80005c9a:	4501                	li	a0,0
    80005c9c:	ffffd097          	auipc	ra,0xffffd
    80005ca0:	074080e7          	jalr	116(ra) # 80002d10 <argaddr>
    return -1;
    80005ca4:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005ca6:	0e054063          	bltz	a0,80005d86 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005caa:	fc840593          	addi	a1,s0,-56
    80005cae:	fd040513          	addi	a0,s0,-48
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	de6080e7          	jalr	-538(ra) # 80004a98 <pipealloc>
    return -1;
    80005cba:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005cbc:	0c054563          	bltz	a0,80005d86 <sys_pipe+0x104>
  fd0 = -1;
    80005cc0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005cc4:	fd043503          	ld	a0,-48(s0)
    80005cc8:	fffff097          	auipc	ra,0xfffff
    80005ccc:	504080e7          	jalr	1284(ra) # 800051cc <fdalloc>
    80005cd0:	fca42223          	sw	a0,-60(s0)
    80005cd4:	08054c63          	bltz	a0,80005d6c <sys_pipe+0xea>
    80005cd8:	fc843503          	ld	a0,-56(s0)
    80005cdc:	fffff097          	auipc	ra,0xfffff
    80005ce0:	4f0080e7          	jalr	1264(ra) # 800051cc <fdalloc>
    80005ce4:	fca42023          	sw	a0,-64(s0)
    80005ce8:	06054963          	bltz	a0,80005d5a <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cec:	4691                	li	a3,4
    80005cee:	fc440613          	addi	a2,s0,-60
    80005cf2:	fd843583          	ld	a1,-40(s0)
    80005cf6:	70a8                	ld	a0,96(s1)
    80005cf8:	ffffc097          	auipc	ra,0xffffc
    80005cfc:	962080e7          	jalr	-1694(ra) # 8000165a <copyout>
    80005d00:	02054063          	bltz	a0,80005d20 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d04:	4691                	li	a3,4
    80005d06:	fc040613          	addi	a2,s0,-64
    80005d0a:	fd843583          	ld	a1,-40(s0)
    80005d0e:	0591                	addi	a1,a1,4
    80005d10:	70a8                	ld	a0,96(s1)
    80005d12:	ffffc097          	auipc	ra,0xffffc
    80005d16:	948080e7          	jalr	-1720(ra) # 8000165a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d1a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d1c:	06055563          	bgez	a0,80005d86 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d20:	fc442783          	lw	a5,-60(s0)
    80005d24:	07f1                	addi	a5,a5,28
    80005d26:	078e                	slli	a5,a5,0x3
    80005d28:	97a6                	add	a5,a5,s1
    80005d2a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d2e:	fc042783          	lw	a5,-64(s0)
    80005d32:	07f1                	addi	a5,a5,28
    80005d34:	078e                	slli	a5,a5,0x3
    80005d36:	00f48533          	add	a0,s1,a5
    80005d3a:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005d3e:	fd043503          	ld	a0,-48(s0)
    80005d42:	fffff097          	auipc	ra,0xfffff
    80005d46:	a26080e7          	jalr	-1498(ra) # 80004768 <fileclose>
    fileclose(wf);
    80005d4a:	fc843503          	ld	a0,-56(s0)
    80005d4e:	fffff097          	auipc	ra,0xfffff
    80005d52:	a1a080e7          	jalr	-1510(ra) # 80004768 <fileclose>
    return -1;
    80005d56:	57fd                	li	a5,-1
    80005d58:	a03d                	j	80005d86 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005d5a:	fc442783          	lw	a5,-60(s0)
    80005d5e:	0007c763          	bltz	a5,80005d6c <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005d62:	07f1                	addi	a5,a5,28
    80005d64:	078e                	slli	a5,a5,0x3
    80005d66:	97a6                	add	a5,a5,s1
    80005d68:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005d6c:	fd043503          	ld	a0,-48(s0)
    80005d70:	fffff097          	auipc	ra,0xfffff
    80005d74:	9f8080e7          	jalr	-1544(ra) # 80004768 <fileclose>
    fileclose(wf);
    80005d78:	fc843503          	ld	a0,-56(s0)
    80005d7c:	fffff097          	auipc	ra,0xfffff
    80005d80:	9ec080e7          	jalr	-1556(ra) # 80004768 <fileclose>
    return -1;
    80005d84:	57fd                	li	a5,-1
}
    80005d86:	853e                	mv	a0,a5
    80005d88:	70e2                	ld	ra,56(sp)
    80005d8a:	7442                	ld	s0,48(sp)
    80005d8c:	74a2                	ld	s1,40(sp)
    80005d8e:	6121                	addi	sp,sp,64
    80005d90:	8082                	ret
	...

0000000080005da0 <kernelvec>:
    80005da0:	7111                	addi	sp,sp,-256
    80005da2:	e006                	sd	ra,0(sp)
    80005da4:	e40a                	sd	sp,8(sp)
    80005da6:	e80e                	sd	gp,16(sp)
    80005da8:	ec12                	sd	tp,24(sp)
    80005daa:	f016                	sd	t0,32(sp)
    80005dac:	f41a                	sd	t1,40(sp)
    80005dae:	f81e                	sd	t2,48(sp)
    80005db0:	fc22                	sd	s0,56(sp)
    80005db2:	e0a6                	sd	s1,64(sp)
    80005db4:	e4aa                	sd	a0,72(sp)
    80005db6:	e8ae                	sd	a1,80(sp)
    80005db8:	ecb2                	sd	a2,88(sp)
    80005dba:	f0b6                	sd	a3,96(sp)
    80005dbc:	f4ba                	sd	a4,104(sp)
    80005dbe:	f8be                	sd	a5,112(sp)
    80005dc0:	fcc2                	sd	a6,120(sp)
    80005dc2:	e146                	sd	a7,128(sp)
    80005dc4:	e54a                	sd	s2,136(sp)
    80005dc6:	e94e                	sd	s3,144(sp)
    80005dc8:	ed52                	sd	s4,152(sp)
    80005dca:	f156                	sd	s5,160(sp)
    80005dcc:	f55a                	sd	s6,168(sp)
    80005dce:	f95e                	sd	s7,176(sp)
    80005dd0:	fd62                	sd	s8,184(sp)
    80005dd2:	e1e6                	sd	s9,192(sp)
    80005dd4:	e5ea                	sd	s10,200(sp)
    80005dd6:	e9ee                	sd	s11,208(sp)
    80005dd8:	edf2                	sd	t3,216(sp)
    80005dda:	f1f6                	sd	t4,224(sp)
    80005ddc:	f5fa                	sd	t5,232(sp)
    80005dde:	f9fe                	sd	t6,240(sp)
    80005de0:	d41fc0ef          	jal	ra,80002b20 <kerneltrap>
    80005de4:	6082                	ld	ra,0(sp)
    80005de6:	6122                	ld	sp,8(sp)
    80005de8:	61c2                	ld	gp,16(sp)
    80005dea:	7282                	ld	t0,32(sp)
    80005dec:	7322                	ld	t1,40(sp)
    80005dee:	73c2                	ld	t2,48(sp)
    80005df0:	7462                	ld	s0,56(sp)
    80005df2:	6486                	ld	s1,64(sp)
    80005df4:	6526                	ld	a0,72(sp)
    80005df6:	65c6                	ld	a1,80(sp)
    80005df8:	6666                	ld	a2,88(sp)
    80005dfa:	7686                	ld	a3,96(sp)
    80005dfc:	7726                	ld	a4,104(sp)
    80005dfe:	77c6                	ld	a5,112(sp)
    80005e00:	7866                	ld	a6,120(sp)
    80005e02:	688a                	ld	a7,128(sp)
    80005e04:	692a                	ld	s2,136(sp)
    80005e06:	69ca                	ld	s3,144(sp)
    80005e08:	6a6a                	ld	s4,152(sp)
    80005e0a:	7a8a                	ld	s5,160(sp)
    80005e0c:	7b2a                	ld	s6,168(sp)
    80005e0e:	7bca                	ld	s7,176(sp)
    80005e10:	7c6a                	ld	s8,184(sp)
    80005e12:	6c8e                	ld	s9,192(sp)
    80005e14:	6d2e                	ld	s10,200(sp)
    80005e16:	6dce                	ld	s11,208(sp)
    80005e18:	6e6e                	ld	t3,216(sp)
    80005e1a:	7e8e                	ld	t4,224(sp)
    80005e1c:	7f2e                	ld	t5,232(sp)
    80005e1e:	7fce                	ld	t6,240(sp)
    80005e20:	6111                	addi	sp,sp,256
    80005e22:	10200073          	sret
    80005e26:	00000013          	nop
    80005e2a:	00000013          	nop
    80005e2e:	0001                	nop

0000000080005e30 <timervec>:
    80005e30:	34051573          	csrrw	a0,mscratch,a0
    80005e34:	e10c                	sd	a1,0(a0)
    80005e36:	e510                	sd	a2,8(a0)
    80005e38:	e914                	sd	a3,16(a0)
    80005e3a:	6d0c                	ld	a1,24(a0)
    80005e3c:	7110                	ld	a2,32(a0)
    80005e3e:	6194                	ld	a3,0(a1)
    80005e40:	96b2                	add	a3,a3,a2
    80005e42:	e194                	sd	a3,0(a1)
    80005e44:	4589                	li	a1,2
    80005e46:	14459073          	csrw	sip,a1
    80005e4a:	6914                	ld	a3,16(a0)
    80005e4c:	6510                	ld	a2,8(a0)
    80005e4e:	610c                	ld	a1,0(a0)
    80005e50:	34051573          	csrrw	a0,mscratch,a0
    80005e54:	30200073          	mret
	...

0000000080005e5a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e5a:	1141                	addi	sp,sp,-16
    80005e5c:	e422                	sd	s0,8(sp)
    80005e5e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e60:	0c0007b7          	lui	a5,0xc000
    80005e64:	4705                	li	a4,1
    80005e66:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e68:	c3d8                	sw	a4,4(a5)
}
    80005e6a:	6422                	ld	s0,8(sp)
    80005e6c:	0141                	addi	sp,sp,16
    80005e6e:	8082                	ret

0000000080005e70 <plicinithart>:

void
plicinithart(void)
{
    80005e70:	1141                	addi	sp,sp,-16
    80005e72:	e406                	sd	ra,8(sp)
    80005e74:	e022                	sd	s0,0(sp)
    80005e76:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e78:	ffffc097          	auipc	ra,0xffffc
    80005e7c:	af2080e7          	jalr	-1294(ra) # 8000196a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005e80:	0085171b          	slliw	a4,a0,0x8
    80005e84:	0c0027b7          	lui	a5,0xc002
    80005e88:	97ba                	add	a5,a5,a4
    80005e8a:	40200713          	li	a4,1026
    80005e8e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e92:	00d5151b          	slliw	a0,a0,0xd
    80005e96:	0c2017b7          	lui	a5,0xc201
    80005e9a:	97aa                	add	a5,a5,a0
    80005e9c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005ea0:	60a2                	ld	ra,8(sp)
    80005ea2:	6402                	ld	s0,0(sp)
    80005ea4:	0141                	addi	sp,sp,16
    80005ea6:	8082                	ret

0000000080005ea8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ea8:	1141                	addi	sp,sp,-16
    80005eaa:	e406                	sd	ra,8(sp)
    80005eac:	e022                	sd	s0,0(sp)
    80005eae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005eb0:	ffffc097          	auipc	ra,0xffffc
    80005eb4:	aba080e7          	jalr	-1350(ra) # 8000196a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005eb8:	00d5151b          	slliw	a0,a0,0xd
    80005ebc:	0c2017b7          	lui	a5,0xc201
    80005ec0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005ec2:	43c8                	lw	a0,4(a5)
    80005ec4:	60a2                	ld	ra,8(sp)
    80005ec6:	6402                	ld	s0,0(sp)
    80005ec8:	0141                	addi	sp,sp,16
    80005eca:	8082                	ret

0000000080005ecc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005ecc:	1101                	addi	sp,sp,-32
    80005ece:	ec06                	sd	ra,24(sp)
    80005ed0:	e822                	sd	s0,16(sp)
    80005ed2:	e426                	sd	s1,8(sp)
    80005ed4:	1000                	addi	s0,sp,32
    80005ed6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ed8:	ffffc097          	auipc	ra,0xffffc
    80005edc:	a92080e7          	jalr	-1390(ra) # 8000196a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005ee0:	00d5151b          	slliw	a0,a0,0xd
    80005ee4:	0c2017b7          	lui	a5,0xc201
    80005ee8:	97aa                	add	a5,a5,a0
    80005eea:	c3c4                	sw	s1,4(a5)
}
    80005eec:	60e2                	ld	ra,24(sp)
    80005eee:	6442                	ld	s0,16(sp)
    80005ef0:	64a2                	ld	s1,8(sp)
    80005ef2:	6105                	addi	sp,sp,32
    80005ef4:	8082                	ret

0000000080005ef6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005ef6:	1141                	addi	sp,sp,-16
    80005ef8:	e406                	sd	ra,8(sp)
    80005efa:	e022                	sd	s0,0(sp)
    80005efc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005efe:	479d                	li	a5,7
    80005f00:	06a7c863          	blt	a5,a0,80005f70 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80005f04:	0001d717          	auipc	a4,0x1d
    80005f08:	0fc70713          	addi	a4,a4,252 # 80023000 <disk>
    80005f0c:	972a                	add	a4,a4,a0
    80005f0e:	6789                	lui	a5,0x2
    80005f10:	97ba                	add	a5,a5,a4
    80005f12:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005f16:	e7ad                	bnez	a5,80005f80 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f18:	00451793          	slli	a5,a0,0x4
    80005f1c:	0001f717          	auipc	a4,0x1f
    80005f20:	0e470713          	addi	a4,a4,228 # 80025000 <disk+0x2000>
    80005f24:	6314                	ld	a3,0(a4)
    80005f26:	96be                	add	a3,a3,a5
    80005f28:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005f2c:	6314                	ld	a3,0(a4)
    80005f2e:	96be                	add	a3,a3,a5
    80005f30:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005f34:	6314                	ld	a3,0(a4)
    80005f36:	96be                	add	a3,a3,a5
    80005f38:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005f3c:	6318                	ld	a4,0(a4)
    80005f3e:	97ba                	add	a5,a5,a4
    80005f40:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005f44:	0001d717          	auipc	a4,0x1d
    80005f48:	0bc70713          	addi	a4,a4,188 # 80023000 <disk>
    80005f4c:	972a                	add	a4,a4,a0
    80005f4e:	6789                	lui	a5,0x2
    80005f50:	97ba                	add	a5,a5,a4
    80005f52:	4705                	li	a4,1
    80005f54:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005f58:	0001f517          	auipc	a0,0x1f
    80005f5c:	0c050513          	addi	a0,a0,192 # 80025018 <disk+0x2018>
    80005f60:	ffffc097          	auipc	ra,0xffffc
    80005f64:	390080e7          	jalr	912(ra) # 800022f0 <wakeup>
}
    80005f68:	60a2                	ld	ra,8(sp)
    80005f6a:	6402                	ld	s0,0(sp)
    80005f6c:	0141                	addi	sp,sp,16
    80005f6e:	8082                	ret
    panic("free_desc 1");
    80005f70:	00003517          	auipc	a0,0x3
    80005f74:	80050513          	addi	a0,a0,-2048 # 80008770 <syscalls+0x328>
    80005f78:	ffffa097          	auipc	ra,0xffffa
    80005f7c:	5c2080e7          	jalr	1474(ra) # 8000053a <panic>
    panic("free_desc 2");
    80005f80:	00003517          	auipc	a0,0x3
    80005f84:	80050513          	addi	a0,a0,-2048 # 80008780 <syscalls+0x338>
    80005f88:	ffffa097          	auipc	ra,0xffffa
    80005f8c:	5b2080e7          	jalr	1458(ra) # 8000053a <panic>

0000000080005f90 <virtio_disk_init>:
{
    80005f90:	1101                	addi	sp,sp,-32
    80005f92:	ec06                	sd	ra,24(sp)
    80005f94:	e822                	sd	s0,16(sp)
    80005f96:	e426                	sd	s1,8(sp)
    80005f98:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005f9a:	00002597          	auipc	a1,0x2
    80005f9e:	7f658593          	addi	a1,a1,2038 # 80008790 <syscalls+0x348>
    80005fa2:	0001f517          	auipc	a0,0x1f
    80005fa6:	18650513          	addi	a0,a0,390 # 80025128 <disk+0x2128>
    80005faa:	ffffb097          	auipc	ra,0xffffb
    80005fae:	b96080e7          	jalr	-1130(ra) # 80000b40 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fb2:	100017b7          	lui	a5,0x10001
    80005fb6:	4398                	lw	a4,0(a5)
    80005fb8:	2701                	sext.w	a4,a4
    80005fba:	747277b7          	lui	a5,0x74727
    80005fbe:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005fc2:	0ef71063          	bne	a4,a5,800060a2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005fc6:	100017b7          	lui	a5,0x10001
    80005fca:	43dc                	lw	a5,4(a5)
    80005fcc:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fce:	4705                	li	a4,1
    80005fd0:	0ce79963          	bne	a5,a4,800060a2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fd4:	100017b7          	lui	a5,0x10001
    80005fd8:	479c                	lw	a5,8(a5)
    80005fda:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005fdc:	4709                	li	a4,2
    80005fde:	0ce79263          	bne	a5,a4,800060a2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005fe2:	100017b7          	lui	a5,0x10001
    80005fe6:	47d8                	lw	a4,12(a5)
    80005fe8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fea:	554d47b7          	lui	a5,0x554d4
    80005fee:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005ff2:	0af71863          	bne	a4,a5,800060a2 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ff6:	100017b7          	lui	a5,0x10001
    80005ffa:	4705                	li	a4,1
    80005ffc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ffe:	470d                	li	a4,3
    80006000:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006002:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006004:	c7ffe6b7          	lui	a3,0xc7ffe
    80006008:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    8000600c:	8f75                	and	a4,a4,a3
    8000600e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006010:	472d                	li	a4,11
    80006012:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006014:	473d                	li	a4,15
    80006016:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006018:	6705                	lui	a4,0x1
    8000601a:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000601c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006020:	5bdc                	lw	a5,52(a5)
    80006022:	2781                	sext.w	a5,a5
  if(max == 0)
    80006024:	c7d9                	beqz	a5,800060b2 <virtio_disk_init+0x122>
  if(max < NUM)
    80006026:	471d                	li	a4,7
    80006028:	08f77d63          	bgeu	a4,a5,800060c2 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000602c:	100014b7          	lui	s1,0x10001
    80006030:	47a1                	li	a5,8
    80006032:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006034:	6609                	lui	a2,0x2
    80006036:	4581                	li	a1,0
    80006038:	0001d517          	auipc	a0,0x1d
    8000603c:	fc850513          	addi	a0,a0,-56 # 80023000 <disk>
    80006040:	ffffb097          	auipc	ra,0xffffb
    80006044:	c8c080e7          	jalr	-884(ra) # 80000ccc <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006048:	0001d717          	auipc	a4,0x1d
    8000604c:	fb870713          	addi	a4,a4,-72 # 80023000 <disk>
    80006050:	00c75793          	srli	a5,a4,0xc
    80006054:	2781                	sext.w	a5,a5
    80006056:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006058:	0001f797          	auipc	a5,0x1f
    8000605c:	fa878793          	addi	a5,a5,-88 # 80025000 <disk+0x2000>
    80006060:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006062:	0001d717          	auipc	a4,0x1d
    80006066:	01e70713          	addi	a4,a4,30 # 80023080 <disk+0x80>
    8000606a:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    8000606c:	0001e717          	auipc	a4,0x1e
    80006070:	f9470713          	addi	a4,a4,-108 # 80024000 <disk+0x1000>
    80006074:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006076:	4705                	li	a4,1
    80006078:	00e78c23          	sb	a4,24(a5)
    8000607c:	00e78ca3          	sb	a4,25(a5)
    80006080:	00e78d23          	sb	a4,26(a5)
    80006084:	00e78da3          	sb	a4,27(a5)
    80006088:	00e78e23          	sb	a4,28(a5)
    8000608c:	00e78ea3          	sb	a4,29(a5)
    80006090:	00e78f23          	sb	a4,30(a5)
    80006094:	00e78fa3          	sb	a4,31(a5)
}
    80006098:	60e2                	ld	ra,24(sp)
    8000609a:	6442                	ld	s0,16(sp)
    8000609c:	64a2                	ld	s1,8(sp)
    8000609e:	6105                	addi	sp,sp,32
    800060a0:	8082                	ret
    panic("could not find virtio disk");
    800060a2:	00002517          	auipc	a0,0x2
    800060a6:	6fe50513          	addi	a0,a0,1790 # 800087a0 <syscalls+0x358>
    800060aa:	ffffa097          	auipc	ra,0xffffa
    800060ae:	490080e7          	jalr	1168(ra) # 8000053a <panic>
    panic("virtio disk has no queue 0");
    800060b2:	00002517          	auipc	a0,0x2
    800060b6:	70e50513          	addi	a0,a0,1806 # 800087c0 <syscalls+0x378>
    800060ba:	ffffa097          	auipc	ra,0xffffa
    800060be:	480080e7          	jalr	1152(ra) # 8000053a <panic>
    panic("virtio disk max queue too short");
    800060c2:	00002517          	auipc	a0,0x2
    800060c6:	71e50513          	addi	a0,a0,1822 # 800087e0 <syscalls+0x398>
    800060ca:	ffffa097          	auipc	ra,0xffffa
    800060ce:	470080e7          	jalr	1136(ra) # 8000053a <panic>

00000000800060d2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060d2:	7119                	addi	sp,sp,-128
    800060d4:	fc86                	sd	ra,120(sp)
    800060d6:	f8a2                	sd	s0,112(sp)
    800060d8:	f4a6                	sd	s1,104(sp)
    800060da:	f0ca                	sd	s2,96(sp)
    800060dc:	ecce                	sd	s3,88(sp)
    800060de:	e8d2                	sd	s4,80(sp)
    800060e0:	e4d6                	sd	s5,72(sp)
    800060e2:	e0da                	sd	s6,64(sp)
    800060e4:	fc5e                	sd	s7,56(sp)
    800060e6:	f862                	sd	s8,48(sp)
    800060e8:	f466                	sd	s9,40(sp)
    800060ea:	f06a                	sd	s10,32(sp)
    800060ec:	ec6e                	sd	s11,24(sp)
    800060ee:	0100                	addi	s0,sp,128
    800060f0:	8aaa                	mv	s5,a0
    800060f2:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800060f4:	00c52c83          	lw	s9,12(a0)
    800060f8:	001c9c9b          	slliw	s9,s9,0x1
    800060fc:	1c82                	slli	s9,s9,0x20
    800060fe:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006102:	0001f517          	auipc	a0,0x1f
    80006106:	02650513          	addi	a0,a0,38 # 80025128 <disk+0x2128>
    8000610a:	ffffb097          	auipc	ra,0xffffb
    8000610e:	ac6080e7          	jalr	-1338(ra) # 80000bd0 <acquire>
  for(int i = 0; i < 3; i++){
    80006112:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006114:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006116:	0001dc17          	auipc	s8,0x1d
    8000611a:	eeac0c13          	addi	s8,s8,-278 # 80023000 <disk>
    8000611e:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006120:	4b0d                	li	s6,3
    80006122:	a0ad                	j	8000618c <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006124:	00fc0733          	add	a4,s8,a5
    80006128:	975e                	add	a4,a4,s7
    8000612a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000612e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006130:	0207c563          	bltz	a5,8000615a <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006134:	2905                	addiw	s2,s2,1
    80006136:	0611                	addi	a2,a2,4
    80006138:	19690c63          	beq	s2,s6,800062d0 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    8000613c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000613e:	0001f717          	auipc	a4,0x1f
    80006142:	eda70713          	addi	a4,a4,-294 # 80025018 <disk+0x2018>
    80006146:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006148:	00074683          	lbu	a3,0(a4)
    8000614c:	fee1                	bnez	a3,80006124 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    8000614e:	2785                	addiw	a5,a5,1
    80006150:	0705                	addi	a4,a4,1
    80006152:	fe979be3          	bne	a5,s1,80006148 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006156:	57fd                	li	a5,-1
    80006158:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000615a:	01205d63          	blez	s2,80006174 <virtio_disk_rw+0xa2>
    8000615e:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006160:	000a2503          	lw	a0,0(s4)
    80006164:	00000097          	auipc	ra,0x0
    80006168:	d92080e7          	jalr	-622(ra) # 80005ef6 <free_desc>
      for(int j = 0; j < i; j++)
    8000616c:	2d85                	addiw	s11,s11,1
    8000616e:	0a11                	addi	s4,s4,4
    80006170:	ff2d98e3          	bne	s11,s2,80006160 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006174:	0001f597          	auipc	a1,0x1f
    80006178:	fb458593          	addi	a1,a1,-76 # 80025128 <disk+0x2128>
    8000617c:	0001f517          	auipc	a0,0x1f
    80006180:	e9c50513          	addi	a0,a0,-356 # 80025018 <disk+0x2018>
    80006184:	ffffc097          	auipc	ra,0xffffc
    80006188:	fe0080e7          	jalr	-32(ra) # 80002164 <sleep>
  for(int i = 0; i < 3; i++){
    8000618c:	f8040a13          	addi	s4,s0,-128
{
    80006190:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006192:	894e                	mv	s2,s3
    80006194:	b765                	j	8000613c <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006196:	0001f697          	auipc	a3,0x1f
    8000619a:	e6a6b683          	ld	a3,-406(a3) # 80025000 <disk+0x2000>
    8000619e:	96ba                	add	a3,a3,a4
    800061a0:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800061a4:	0001d817          	auipc	a6,0x1d
    800061a8:	e5c80813          	addi	a6,a6,-420 # 80023000 <disk>
    800061ac:	0001f697          	auipc	a3,0x1f
    800061b0:	e5468693          	addi	a3,a3,-428 # 80025000 <disk+0x2000>
    800061b4:	6290                	ld	a2,0(a3)
    800061b6:	963a                	add	a2,a2,a4
    800061b8:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800061bc:	0015e593          	ori	a1,a1,1
    800061c0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800061c4:	f8842603          	lw	a2,-120(s0)
    800061c8:	628c                	ld	a1,0(a3)
    800061ca:	972e                	add	a4,a4,a1
    800061cc:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800061d0:	20050593          	addi	a1,a0,512
    800061d4:	0592                	slli	a1,a1,0x4
    800061d6:	95c2                	add	a1,a1,a6
    800061d8:	577d                	li	a4,-1
    800061da:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800061de:	00461713          	slli	a4,a2,0x4
    800061e2:	6290                	ld	a2,0(a3)
    800061e4:	963a                	add	a2,a2,a4
    800061e6:	03078793          	addi	a5,a5,48
    800061ea:	97c2                	add	a5,a5,a6
    800061ec:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800061ee:	629c                	ld	a5,0(a3)
    800061f0:	97ba                	add	a5,a5,a4
    800061f2:	4605                	li	a2,1
    800061f4:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800061f6:	629c                	ld	a5,0(a3)
    800061f8:	97ba                	add	a5,a5,a4
    800061fa:	4809                	li	a6,2
    800061fc:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006200:	629c                	ld	a5,0(a3)
    80006202:	97ba                	add	a5,a5,a4
    80006204:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006208:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000620c:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006210:	6698                	ld	a4,8(a3)
    80006212:	00275783          	lhu	a5,2(a4)
    80006216:	8b9d                	andi	a5,a5,7
    80006218:	0786                	slli	a5,a5,0x1
    8000621a:	973e                	add	a4,a4,a5
    8000621c:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    80006220:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006224:	6698                	ld	a4,8(a3)
    80006226:	00275783          	lhu	a5,2(a4)
    8000622a:	2785                	addiw	a5,a5,1
    8000622c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006230:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006234:	100017b7          	lui	a5,0x10001
    80006238:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000623c:	004aa783          	lw	a5,4(s5)
    80006240:	02c79163          	bne	a5,a2,80006262 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006244:	0001f917          	auipc	s2,0x1f
    80006248:	ee490913          	addi	s2,s2,-284 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    8000624c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000624e:	85ca                	mv	a1,s2
    80006250:	8556                	mv	a0,s5
    80006252:	ffffc097          	auipc	ra,0xffffc
    80006256:	f12080e7          	jalr	-238(ra) # 80002164 <sleep>
  while(b->disk == 1) {
    8000625a:	004aa783          	lw	a5,4(s5)
    8000625e:	fe9788e3          	beq	a5,s1,8000624e <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006262:	f8042903          	lw	s2,-128(s0)
    80006266:	20090713          	addi	a4,s2,512
    8000626a:	0712                	slli	a4,a4,0x4
    8000626c:	0001d797          	auipc	a5,0x1d
    80006270:	d9478793          	addi	a5,a5,-620 # 80023000 <disk>
    80006274:	97ba                	add	a5,a5,a4
    80006276:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    8000627a:	0001f997          	auipc	s3,0x1f
    8000627e:	d8698993          	addi	s3,s3,-634 # 80025000 <disk+0x2000>
    80006282:	00491713          	slli	a4,s2,0x4
    80006286:	0009b783          	ld	a5,0(s3)
    8000628a:	97ba                	add	a5,a5,a4
    8000628c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006290:	854a                	mv	a0,s2
    80006292:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006296:	00000097          	auipc	ra,0x0
    8000629a:	c60080e7          	jalr	-928(ra) # 80005ef6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000629e:	8885                	andi	s1,s1,1
    800062a0:	f0ed                	bnez	s1,80006282 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062a2:	0001f517          	auipc	a0,0x1f
    800062a6:	e8650513          	addi	a0,a0,-378 # 80025128 <disk+0x2128>
    800062aa:	ffffb097          	auipc	ra,0xffffb
    800062ae:	9da080e7          	jalr	-1574(ra) # 80000c84 <release>
}
    800062b2:	70e6                	ld	ra,120(sp)
    800062b4:	7446                	ld	s0,112(sp)
    800062b6:	74a6                	ld	s1,104(sp)
    800062b8:	7906                	ld	s2,96(sp)
    800062ba:	69e6                	ld	s3,88(sp)
    800062bc:	6a46                	ld	s4,80(sp)
    800062be:	6aa6                	ld	s5,72(sp)
    800062c0:	6b06                	ld	s6,64(sp)
    800062c2:	7be2                	ld	s7,56(sp)
    800062c4:	7c42                	ld	s8,48(sp)
    800062c6:	7ca2                	ld	s9,40(sp)
    800062c8:	7d02                	ld	s10,32(sp)
    800062ca:	6de2                	ld	s11,24(sp)
    800062cc:	6109                	addi	sp,sp,128
    800062ce:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062d0:	f8042503          	lw	a0,-128(s0)
    800062d4:	20050793          	addi	a5,a0,512
    800062d8:	0792                	slli	a5,a5,0x4
  if(write)
    800062da:	0001d817          	auipc	a6,0x1d
    800062de:	d2680813          	addi	a6,a6,-730 # 80023000 <disk>
    800062e2:	00f80733          	add	a4,a6,a5
    800062e6:	01a036b3          	snez	a3,s10
    800062ea:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800062ee:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800062f2:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062f6:	7679                	lui	a2,0xffffe
    800062f8:	963e                	add	a2,a2,a5
    800062fa:	0001f697          	auipc	a3,0x1f
    800062fe:	d0668693          	addi	a3,a3,-762 # 80025000 <disk+0x2000>
    80006302:	6298                	ld	a4,0(a3)
    80006304:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006306:	0a878593          	addi	a1,a5,168
    8000630a:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000630c:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000630e:	6298                	ld	a4,0(a3)
    80006310:	9732                	add	a4,a4,a2
    80006312:	45c1                	li	a1,16
    80006314:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006316:	6298                	ld	a4,0(a3)
    80006318:	9732                	add	a4,a4,a2
    8000631a:	4585                	li	a1,1
    8000631c:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006320:	f8442703          	lw	a4,-124(s0)
    80006324:	628c                	ld	a1,0(a3)
    80006326:	962e                	add	a2,a2,a1
    80006328:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    8000632c:	0712                	slli	a4,a4,0x4
    8000632e:	6290                	ld	a2,0(a3)
    80006330:	963a                	add	a2,a2,a4
    80006332:	058a8593          	addi	a1,s5,88
    80006336:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006338:	6294                	ld	a3,0(a3)
    8000633a:	96ba                	add	a3,a3,a4
    8000633c:	40000613          	li	a2,1024
    80006340:	c690                	sw	a2,8(a3)
  if(write)
    80006342:	e40d1ae3          	bnez	s10,80006196 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006346:	0001f697          	auipc	a3,0x1f
    8000634a:	cba6b683          	ld	a3,-838(a3) # 80025000 <disk+0x2000>
    8000634e:	96ba                	add	a3,a3,a4
    80006350:	4609                	li	a2,2
    80006352:	00c69623          	sh	a2,12(a3)
    80006356:	b5b9                	j	800061a4 <virtio_disk_rw+0xd2>

0000000080006358 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006358:	1101                	addi	sp,sp,-32
    8000635a:	ec06                	sd	ra,24(sp)
    8000635c:	e822                	sd	s0,16(sp)
    8000635e:	e426                	sd	s1,8(sp)
    80006360:	e04a                	sd	s2,0(sp)
    80006362:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006364:	0001f517          	auipc	a0,0x1f
    80006368:	dc450513          	addi	a0,a0,-572 # 80025128 <disk+0x2128>
    8000636c:	ffffb097          	auipc	ra,0xffffb
    80006370:	864080e7          	jalr	-1948(ra) # 80000bd0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006374:	10001737          	lui	a4,0x10001
    80006378:	533c                	lw	a5,96(a4)
    8000637a:	8b8d                	andi	a5,a5,3
    8000637c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000637e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006382:	0001f797          	auipc	a5,0x1f
    80006386:	c7e78793          	addi	a5,a5,-898 # 80025000 <disk+0x2000>
    8000638a:	6b94                	ld	a3,16(a5)
    8000638c:	0207d703          	lhu	a4,32(a5)
    80006390:	0026d783          	lhu	a5,2(a3)
    80006394:	06f70163          	beq	a4,a5,800063f6 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006398:	0001d917          	auipc	s2,0x1d
    8000639c:	c6890913          	addi	s2,s2,-920 # 80023000 <disk>
    800063a0:	0001f497          	auipc	s1,0x1f
    800063a4:	c6048493          	addi	s1,s1,-928 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800063a8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800063ac:	6898                	ld	a4,16(s1)
    800063ae:	0204d783          	lhu	a5,32(s1)
    800063b2:	8b9d                	andi	a5,a5,7
    800063b4:	078e                	slli	a5,a5,0x3
    800063b6:	97ba                	add	a5,a5,a4
    800063b8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800063ba:	20078713          	addi	a4,a5,512
    800063be:	0712                	slli	a4,a4,0x4
    800063c0:	974a                	add	a4,a4,s2
    800063c2:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800063c6:	e731                	bnez	a4,80006412 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800063c8:	20078793          	addi	a5,a5,512
    800063cc:	0792                	slli	a5,a5,0x4
    800063ce:	97ca                	add	a5,a5,s2
    800063d0:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800063d2:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800063d6:	ffffc097          	auipc	ra,0xffffc
    800063da:	f1a080e7          	jalr	-230(ra) # 800022f0 <wakeup>

    disk.used_idx += 1;
    800063de:	0204d783          	lhu	a5,32(s1)
    800063e2:	2785                	addiw	a5,a5,1
    800063e4:	17c2                	slli	a5,a5,0x30
    800063e6:	93c1                	srli	a5,a5,0x30
    800063e8:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800063ec:	6898                	ld	a4,16(s1)
    800063ee:	00275703          	lhu	a4,2(a4)
    800063f2:	faf71be3          	bne	a4,a5,800063a8 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800063f6:	0001f517          	auipc	a0,0x1f
    800063fa:	d3250513          	addi	a0,a0,-718 # 80025128 <disk+0x2128>
    800063fe:	ffffb097          	auipc	ra,0xffffb
    80006402:	886080e7          	jalr	-1914(ra) # 80000c84 <release>
}
    80006406:	60e2                	ld	ra,24(sp)
    80006408:	6442                	ld	s0,16(sp)
    8000640a:	64a2                	ld	s1,8(sp)
    8000640c:	6902                	ld	s2,0(sp)
    8000640e:	6105                	addi	sp,sp,32
    80006410:	8082                	ret
      panic("virtio_disk_intr status");
    80006412:	00002517          	auipc	a0,0x2
    80006416:	3ee50513          	addi	a0,a0,1006 # 80008800 <syscalls+0x3b8>
    8000641a:	ffffa097          	auipc	ra,0xffffa
    8000641e:	120080e7          	jalr	288(ra) # 8000053a <panic>
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
