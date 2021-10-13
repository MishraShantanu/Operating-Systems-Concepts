
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
    80000066:	cfe78793          	addi	a5,a5,-770 # 80005d60 <timervec>
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
    8000012e:	38e080e7          	jalr	910(ra) # 800024b8 <either_copyin>
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
    800001d4:	ec2080e7          	jalr	-318(ra) # 80002092 <sleep>
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
    80000210:	256080e7          	jalr	598(ra) # 80002462 <either_copyout>
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
    800002f0:	222080e7          	jalr	546(ra) # 8000250e <procdump>
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
    80000444:	dde080e7          	jalr	-546(ra) # 8000221e <wakeup>
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
    80000476:	2a678793          	addi	a5,a5,678 # 80021718 <devsw>
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
    80000892:	990080e7          	jalr	-1648(ra) # 8000221e <wakeup>
    
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
    8000091e:	778080e7          	jalr	1912(ra) # 80002092 <sleep>
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
    80000ebc:	906080e7          	jalr	-1786(ra) # 800027be <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	ee0080e7          	jalr	-288(ra) # 80005da0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	00e080e7          	jalr	14(ra) # 80001ed6 <scheduler>
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
    80000f34:	866080e7          	jalr	-1946(ra) # 80002796 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	886080e7          	jalr	-1914(ra) # 800027be <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	e4a080e7          	jalr	-438(ra) # 80005d8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	e58080e7          	jalr	-424(ra) # 80005da0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	014080e7          	jalr	20(ra) # 80002f64 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	6a2080e7          	jalr	1698(ra) # 800035fa <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	654080e7          	jalr	1620(ra) # 800045b4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	f58080e7          	jalr	-168(ra) # 80005ec0 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d2c080e7          	jalr	-724(ra) # 80001c9c <userinit>
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
    80001858:	c7ca0a13          	addi	s4,s4,-900 # 800174d0 <tickslock>
    char *pa = kalloc();
    8000185c:	fffff097          	auipc	ra,0xfffff
    80001860:	284080e7          	jalr	644(ra) # 80000ae0 <kalloc>
    80001864:	862a                	mv	a2,a0
    if(pa == 0)
    80001866:	c131                	beqz	a0,800018aa <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001868:	416485b3          	sub	a1,s1,s6
    8000186c:	858d                	srai	a1,a1,0x3
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
    8000188e:	17848493          	addi	s1,s1,376
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
    80001924:	bb098993          	addi	s3,s3,-1104 # 800174d0 <tickslock>
      initlock(&p->lock, "proc");
    80001928:	85da                	mv	a1,s6
    8000192a:	8526                	mv	a0,s1
    8000192c:	fffff097          	auipc	ra,0xfffff
    80001930:	214080e7          	jalr	532(ra) # 80000b40 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001934:	415487b3          	sub	a5,s1,s5
    80001938:	878d                	srai	a5,a5,0x3
    8000193a:	000a3703          	ld	a4,0(s4)
    8000193e:	02e787b3          	mul	a5,a5,a4
    80001942:	2785                	addiw	a5,a5,1
    80001944:	00d7979b          	slliw	a5,a5,0xd
    80001948:	40f907b3          	sub	a5,s2,a5
    8000194c:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194e:	17848493          	addi	s1,s1,376
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
    800019f4:	de6080e7          	jalr	-538(ra) # 800027d6 <usertrapret>
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
    80001a0e:	b70080e7          	jalr	-1168(ra) # 8000357a <fsinit>
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
    80001a96:	06093683          	ld	a3,96(s2)
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
    80001b54:	7128                	ld	a0,96(a0)
    80001b56:	c509                	beqz	a0,80001b60 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	e8a080e7          	jalr	-374(ra) # 800009e2 <kfree>
  p->trapframe = 0;
    80001b60:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001b64:	6ca8                	ld	a0,88(s1)
    80001b66:	c511                	beqz	a0,80001b72 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b68:	68ac                	ld	a1,80(s1)
    80001b6a:	00000097          	auipc	ra,0x0
    80001b6e:	f8c080e7          	jalr	-116(ra) # 80001af6 <proc_freepagetable>
  p->pagetable = 0;
    80001b72:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001b76:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001b7a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b7e:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001b82:	16048023          	sb	zero,352(s1)
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
    80001bb8:	91c90913          	addi	s2,s2,-1764 # 800174d0 <tickslock>
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
    80001bd4:	17848493          	addi	s1,s1,376
    80001bd8:	ff2492e3          	bne	s1,s2,80001bbc <allocproc+0x1c>
  return 0;
    80001bdc:	4481                	li	s1,0
    80001bde:	a041                	j	80001c5e <allocproc+0xbe>
  p->pid = allocpid();
    80001be0:	00000097          	auipc	ra,0x0
    80001be4:	e34080e7          	jalr	-460(ra) # 80001a14 <allocpid>
    80001be8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bea:	4785                	li	a5,1
    80001bec:	cc9c                	sw	a5,24(s1)
    acquire(&tickslock);
    80001bee:	00016517          	auipc	a0,0x16
    80001bf2:	8e250513          	addi	a0,a0,-1822 # 800174d0 <tickslock>
    80001bf6:	fffff097          	auipc	ra,0xfffff
    80001bfa:	fda080e7          	jalr	-38(ra) # 80000bd0 <acquire>
    p->created = ticks;
    80001bfe:	00007797          	auipc	a5,0x7
    80001c02:	4327a783          	lw	a5,1074(a5) # 80009030 <ticks>
    80001c06:	d8dc                	sw	a5,52(s1)
    release(&tickslock);
    80001c08:	00016517          	auipc	a0,0x16
    80001c0c:	8c850513          	addi	a0,a0,-1848 # 800174d0 <tickslock>
    80001c10:	fffff097          	auipc	ra,0xfffff
    80001c14:	074080e7          	jalr	116(ra) # 80000c84 <release>
    p->running = 0;
    80001c18:	1604a823          	sw	zero,368(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c1c:	fffff097          	auipc	ra,0xfffff
    80001c20:	ec4080e7          	jalr	-316(ra) # 80000ae0 <kalloc>
    80001c24:	892a                	mv	s2,a0
    80001c26:	f0a8                	sd	a0,96(s1)
    80001c28:	c131                	beqz	a0,80001c6c <allocproc+0xcc>
  p->pagetable = proc_pagetable(p);
    80001c2a:	8526                	mv	a0,s1
    80001c2c:	00000097          	auipc	ra,0x0
    80001c30:	e2e080e7          	jalr	-466(ra) # 80001a5a <proc_pagetable>
    80001c34:	892a                	mv	s2,a0
    80001c36:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001c38:	c531                	beqz	a0,80001c84 <allocproc+0xe4>
  memset(&p->context, 0, sizeof(p->context));
    80001c3a:	07000613          	li	a2,112
    80001c3e:	4581                	li	a1,0
    80001c40:	06848513          	addi	a0,s1,104
    80001c44:	fffff097          	auipc	ra,0xfffff
    80001c48:	088080e7          	jalr	136(ra) # 80000ccc <memset>
  p->context.ra = (uint64)forkret;
    80001c4c:	00000797          	auipc	a5,0x0
    80001c50:	d8278793          	addi	a5,a5,-638 # 800019ce <forkret>
    80001c54:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c56:	64bc                	ld	a5,72(s1)
    80001c58:	6705                	lui	a4,0x1
    80001c5a:	97ba                	add	a5,a5,a4
    80001c5c:	f8bc                	sd	a5,112(s1)
}
    80001c5e:	8526                	mv	a0,s1
    80001c60:	60e2                	ld	ra,24(sp)
    80001c62:	6442                	ld	s0,16(sp)
    80001c64:	64a2                	ld	s1,8(sp)
    80001c66:	6902                	ld	s2,0(sp)
    80001c68:	6105                	addi	sp,sp,32
    80001c6a:	8082                	ret
    freeproc(p);
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	00000097          	auipc	ra,0x0
    80001c72:	eda080e7          	jalr	-294(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001c76:	8526                	mv	a0,s1
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	00c080e7          	jalr	12(ra) # 80000c84 <release>
    return 0;
    80001c80:	84ca                	mv	s1,s2
    80001c82:	bff1                	j	80001c5e <allocproc+0xbe>
    freeproc(p);
    80001c84:	8526                	mv	a0,s1
    80001c86:	00000097          	auipc	ra,0x0
    80001c8a:	ec2080e7          	jalr	-318(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001c8e:	8526                	mv	a0,s1
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	ff4080e7          	jalr	-12(ra) # 80000c84 <release>
    return 0;
    80001c98:	84ca                	mv	s1,s2
    80001c9a:	b7d1                	j	80001c5e <allocproc+0xbe>

0000000080001c9c <userinit>:
{
    80001c9c:	1101                	addi	sp,sp,-32
    80001c9e:	ec06                	sd	ra,24(sp)
    80001ca0:	e822                	sd	s0,16(sp)
    80001ca2:	e426                	sd	s1,8(sp)
    80001ca4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ca6:	00000097          	auipc	ra,0x0
    80001caa:	efa080e7          	jalr	-262(ra) # 80001ba0 <allocproc>
    80001cae:	84aa                	mv	s1,a0
  initproc = p;
    80001cb0:	00007797          	auipc	a5,0x7
    80001cb4:	36a7bc23          	sd	a0,888(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cb8:	03400613          	li	a2,52
    80001cbc:	00007597          	auipc	a1,0x7
    80001cc0:	b7458593          	addi	a1,a1,-1164 # 80008830 <initcode>
    80001cc4:	6d28                	ld	a0,88(a0)
    80001cc6:	fffff097          	auipc	ra,0xfffff
    80001cca:	686080e7          	jalr	1670(ra) # 8000134c <uvminit>
  p->sz = PGSIZE;
    80001cce:	6785                	lui	a5,0x1
    80001cd0:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cd2:	70b8                	ld	a4,96(s1)
    80001cd4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cd8:	70b8                	ld	a4,96(s1)
    80001cda:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cdc:	4641                	li	a2,16
    80001cde:	00006597          	auipc	a1,0x6
    80001ce2:	52258593          	addi	a1,a1,1314 # 80008200 <digits+0x1c0>
    80001ce6:	16048513          	addi	a0,s1,352
    80001cea:	fffff097          	auipc	ra,0xfffff
    80001cee:	12c080e7          	jalr	300(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cf2:	00006517          	auipc	a0,0x6
    80001cf6:	51e50513          	addi	a0,a0,1310 # 80008210 <digits+0x1d0>
    80001cfa:	00002097          	auipc	ra,0x2
    80001cfe:	2b6080e7          	jalr	694(ra) # 80003fb0 <namei>
    80001d02:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001d06:	478d                	li	a5,3
    80001d08:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	fffff097          	auipc	ra,0xfffff
    80001d10:	f78080e7          	jalr	-136(ra) # 80000c84 <release>
}
    80001d14:	60e2                	ld	ra,24(sp)
    80001d16:	6442                	ld	s0,16(sp)
    80001d18:	64a2                	ld	s1,8(sp)
    80001d1a:	6105                	addi	sp,sp,32
    80001d1c:	8082                	ret

0000000080001d1e <growproc>:
{
    80001d1e:	1101                	addi	sp,sp,-32
    80001d20:	ec06                	sd	ra,24(sp)
    80001d22:	e822                	sd	s0,16(sp)
    80001d24:	e426                	sd	s1,8(sp)
    80001d26:	e04a                	sd	s2,0(sp)
    80001d28:	1000                	addi	s0,sp,32
    80001d2a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d2c:	00000097          	auipc	ra,0x0
    80001d30:	c6a080e7          	jalr	-918(ra) # 80001996 <myproc>
    80001d34:	892a                	mv	s2,a0
  sz = p->sz;
    80001d36:	692c                	ld	a1,80(a0)
    80001d38:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001d3c:	00904f63          	bgtz	s1,80001d5a <growproc+0x3c>
  } else if(n < 0){
    80001d40:	0204cd63          	bltz	s1,80001d7a <growproc+0x5c>
  p->sz = sz;
    80001d44:	1782                	slli	a5,a5,0x20
    80001d46:	9381                	srli	a5,a5,0x20
    80001d48:	04f93823          	sd	a5,80(s2)
  return 0;
    80001d4c:	4501                	li	a0,0
}
    80001d4e:	60e2                	ld	ra,24(sp)
    80001d50:	6442                	ld	s0,16(sp)
    80001d52:	64a2                	ld	s1,8(sp)
    80001d54:	6902                	ld	s2,0(sp)
    80001d56:	6105                	addi	sp,sp,32
    80001d58:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d5a:	00f4863b          	addw	a2,s1,a5
    80001d5e:	1602                	slli	a2,a2,0x20
    80001d60:	9201                	srli	a2,a2,0x20
    80001d62:	1582                	slli	a1,a1,0x20
    80001d64:	9181                	srli	a1,a1,0x20
    80001d66:	6d28                	ld	a0,88(a0)
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	69e080e7          	jalr	1694(ra) # 80001406 <uvmalloc>
    80001d70:	0005079b          	sext.w	a5,a0
    80001d74:	fbe1                	bnez	a5,80001d44 <growproc+0x26>
      return -1;
    80001d76:	557d                	li	a0,-1
    80001d78:	bfd9                	j	80001d4e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d7a:	00f4863b          	addw	a2,s1,a5
    80001d7e:	1602                	slli	a2,a2,0x20
    80001d80:	9201                	srli	a2,a2,0x20
    80001d82:	1582                	slli	a1,a1,0x20
    80001d84:	9181                	srli	a1,a1,0x20
    80001d86:	6d28                	ld	a0,88(a0)
    80001d88:	fffff097          	auipc	ra,0xfffff
    80001d8c:	636080e7          	jalr	1590(ra) # 800013be <uvmdealloc>
    80001d90:	0005079b          	sext.w	a5,a0
    80001d94:	bf45                	j	80001d44 <growproc+0x26>

0000000080001d96 <fork>:
{
    80001d96:	7139                	addi	sp,sp,-64
    80001d98:	fc06                	sd	ra,56(sp)
    80001d9a:	f822                	sd	s0,48(sp)
    80001d9c:	f426                	sd	s1,40(sp)
    80001d9e:	f04a                	sd	s2,32(sp)
    80001da0:	ec4e                	sd	s3,24(sp)
    80001da2:	e852                	sd	s4,16(sp)
    80001da4:	e456                	sd	s5,8(sp)
    80001da6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001da8:	00000097          	auipc	ra,0x0
    80001dac:	bee080e7          	jalr	-1042(ra) # 80001996 <myproc>
    80001db0:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001db2:	00000097          	auipc	ra,0x0
    80001db6:	dee080e7          	jalr	-530(ra) # 80001ba0 <allocproc>
    80001dba:	10050c63          	beqz	a0,80001ed2 <fork+0x13c>
    80001dbe:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dc0:	050ab603          	ld	a2,80(s5)
    80001dc4:	6d2c                	ld	a1,88(a0)
    80001dc6:	058ab503          	ld	a0,88(s5)
    80001dca:	fffff097          	auipc	ra,0xfffff
    80001dce:	78c080e7          	jalr	1932(ra) # 80001556 <uvmcopy>
    80001dd2:	04054863          	bltz	a0,80001e22 <fork+0x8c>
  np->sz = p->sz;
    80001dd6:	050ab783          	ld	a5,80(s5)
    80001dda:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dde:	060ab683          	ld	a3,96(s5)
    80001de2:	87b6                	mv	a5,a3
    80001de4:	060a3703          	ld	a4,96(s4)
    80001de8:	12068693          	addi	a3,a3,288
    80001dec:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001df0:	6788                	ld	a0,8(a5)
    80001df2:	6b8c                	ld	a1,16(a5)
    80001df4:	6f90                	ld	a2,24(a5)
    80001df6:	01073023          	sd	a6,0(a4)
    80001dfa:	e708                	sd	a0,8(a4)
    80001dfc:	eb0c                	sd	a1,16(a4)
    80001dfe:	ef10                	sd	a2,24(a4)
    80001e00:	02078793          	addi	a5,a5,32
    80001e04:	02070713          	addi	a4,a4,32
    80001e08:	fed792e3          	bne	a5,a3,80001dec <fork+0x56>
  np->trapframe->a0 = 0;
    80001e0c:	060a3783          	ld	a5,96(s4)
    80001e10:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e14:	0d8a8493          	addi	s1,s5,216
    80001e18:	0d8a0913          	addi	s2,s4,216
    80001e1c:	158a8993          	addi	s3,s5,344
    80001e20:	a00d                	j	80001e42 <fork+0xac>
    freeproc(np);
    80001e22:	8552                	mv	a0,s4
    80001e24:	00000097          	auipc	ra,0x0
    80001e28:	d24080e7          	jalr	-732(ra) # 80001b48 <freeproc>
    release(&np->lock);
    80001e2c:	8552                	mv	a0,s4
    80001e2e:	fffff097          	auipc	ra,0xfffff
    80001e32:	e56080e7          	jalr	-426(ra) # 80000c84 <release>
    return -1;
    80001e36:	597d                	li	s2,-1
    80001e38:	a059                	j	80001ebe <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e3a:	04a1                	addi	s1,s1,8
    80001e3c:	0921                	addi	s2,s2,8
    80001e3e:	01348b63          	beq	s1,s3,80001e54 <fork+0xbe>
    if(p->ofile[i])
    80001e42:	6088                	ld	a0,0(s1)
    80001e44:	d97d                	beqz	a0,80001e3a <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e46:	00003097          	auipc	ra,0x3
    80001e4a:	800080e7          	jalr	-2048(ra) # 80004646 <filedup>
    80001e4e:	00a93023          	sd	a0,0(s2)
    80001e52:	b7e5                	j	80001e3a <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e54:	158ab503          	ld	a0,344(s5)
    80001e58:	00002097          	auipc	ra,0x2
    80001e5c:	95e080e7          	jalr	-1698(ra) # 800037b6 <idup>
    80001e60:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e64:	4641                	li	a2,16
    80001e66:	160a8593          	addi	a1,s5,352
    80001e6a:	160a0513          	addi	a0,s4,352
    80001e6e:	fffff097          	auipc	ra,0xfffff
    80001e72:	fa8080e7          	jalr	-88(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e76:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e7a:	8552                	mv	a0,s4
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	e08080e7          	jalr	-504(ra) # 80000c84 <release>
  acquire(&wait_lock);
    80001e84:	0000f497          	auipc	s1,0xf
    80001e88:	43448493          	addi	s1,s1,1076 # 800112b8 <wait_lock>
    80001e8c:	8526                	mv	a0,s1
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	d42080e7          	jalr	-702(ra) # 80000bd0 <acquire>
  np->parent = p;
    80001e96:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80001e9a:	8526                	mv	a0,s1
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	de8080e7          	jalr	-536(ra) # 80000c84 <release>
  acquire(&np->lock);
    80001ea4:	8552                	mv	a0,s4
    80001ea6:	fffff097          	auipc	ra,0xfffff
    80001eaa:	d2a080e7          	jalr	-726(ra) # 80000bd0 <acquire>
  np->state = RUNNABLE;
    80001eae:	478d                	li	a5,3
    80001eb0:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001eb4:	8552                	mv	a0,s4
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	dce080e7          	jalr	-562(ra) # 80000c84 <release>
}
    80001ebe:	854a                	mv	a0,s2
    80001ec0:	70e2                	ld	ra,56(sp)
    80001ec2:	7442                	ld	s0,48(sp)
    80001ec4:	74a2                	ld	s1,40(sp)
    80001ec6:	7902                	ld	s2,32(sp)
    80001ec8:	69e2                	ld	s3,24(sp)
    80001eca:	6a42                	ld	s4,16(sp)
    80001ecc:	6aa2                	ld	s5,8(sp)
    80001ece:	6121                	addi	sp,sp,64
    80001ed0:	8082                	ret
    return -1;
    80001ed2:	597d                	li	s2,-1
    80001ed4:	b7ed                	j	80001ebe <fork+0x128>

0000000080001ed6 <scheduler>:
{
    80001ed6:	7139                	addi	sp,sp,-64
    80001ed8:	fc06                	sd	ra,56(sp)
    80001eda:	f822                	sd	s0,48(sp)
    80001edc:	f426                	sd	s1,40(sp)
    80001ede:	f04a                	sd	s2,32(sp)
    80001ee0:	ec4e                	sd	s3,24(sp)
    80001ee2:	e852                	sd	s4,16(sp)
    80001ee4:	e456                	sd	s5,8(sp)
    80001ee6:	e05a                	sd	s6,0(sp)
    80001ee8:	0080                	addi	s0,sp,64
    80001eea:	8792                	mv	a5,tp
  int id = r_tp();
    80001eec:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001eee:	00779a93          	slli	s5,a5,0x7
    80001ef2:	0000f717          	auipc	a4,0xf
    80001ef6:	3ae70713          	addi	a4,a4,942 # 800112a0 <pid_lock>
    80001efa:	9756                	add	a4,a4,s5
    80001efc:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f00:	0000f717          	auipc	a4,0xf
    80001f04:	3d870713          	addi	a4,a4,984 # 800112d8 <cpus+0x8>
    80001f08:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f0a:	498d                	li	s3,3
        p->state = RUNNING;
    80001f0c:	4b11                	li	s6,4
        c->proc = p;
    80001f0e:	079e                	slli	a5,a5,0x7
    80001f10:	0000fa17          	auipc	s4,0xf
    80001f14:	390a0a13          	addi	s4,s4,912 # 800112a0 <pid_lock>
    80001f18:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f1a:	00015917          	auipc	s2,0x15
    80001f1e:	5b690913          	addi	s2,s2,1462 # 800174d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f22:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f26:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f2a:	10079073          	csrw	sstatus,a5
    80001f2e:	0000f497          	auipc	s1,0xf
    80001f32:	7a248493          	addi	s1,s1,1954 # 800116d0 <proc>
    80001f36:	a811                	j	80001f4a <scheduler+0x74>
      release(&p->lock);
    80001f38:	8526                	mv	a0,s1
    80001f3a:	fffff097          	auipc	ra,0xfffff
    80001f3e:	d4a080e7          	jalr	-694(ra) # 80000c84 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f42:	17848493          	addi	s1,s1,376
    80001f46:	fd248ee3          	beq	s1,s2,80001f22 <scheduler+0x4c>
      acquire(&p->lock);
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	c84080e7          	jalr	-892(ra) # 80000bd0 <acquire>
      if(p->state == RUNNABLE) {
    80001f54:	4c9c                	lw	a5,24(s1)
    80001f56:	ff3791e3          	bne	a5,s3,80001f38 <scheduler+0x62>
        p->state = RUNNING;
    80001f5a:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f5e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f62:	06848593          	addi	a1,s1,104
    80001f66:	8556                	mv	a0,s5
    80001f68:	00000097          	auipc	ra,0x0
    80001f6c:	7c4080e7          	jalr	1988(ra) # 8000272c <swtch>
        p->running++;
    80001f70:	1704a783          	lw	a5,368(s1)
    80001f74:	2785                	addiw	a5,a5,1
    80001f76:	16f4a823          	sw	a5,368(s1)
        c->proc = 0;
    80001f7a:	020a3823          	sd	zero,48(s4)
    80001f7e:	bf6d                	j	80001f38 <scheduler+0x62>

0000000080001f80 <sched>:
{
    80001f80:	7179                	addi	sp,sp,-48
    80001f82:	f406                	sd	ra,40(sp)
    80001f84:	f022                	sd	s0,32(sp)
    80001f86:	ec26                	sd	s1,24(sp)
    80001f88:	e84a                	sd	s2,16(sp)
    80001f8a:	e44e                	sd	s3,8(sp)
    80001f8c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f8e:	00000097          	auipc	ra,0x0
    80001f92:	a08080e7          	jalr	-1528(ra) # 80001996 <myproc>
    80001f96:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f98:	fffff097          	auipc	ra,0xfffff
    80001f9c:	bbe080e7          	jalr	-1090(ra) # 80000b56 <holding>
    80001fa0:	c93d                	beqz	a0,80002016 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fa2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fa4:	2781                	sext.w	a5,a5
    80001fa6:	079e                	slli	a5,a5,0x7
    80001fa8:	0000f717          	auipc	a4,0xf
    80001fac:	2f870713          	addi	a4,a4,760 # 800112a0 <pid_lock>
    80001fb0:	97ba                	add	a5,a5,a4
    80001fb2:	0a87a703          	lw	a4,168(a5)
    80001fb6:	4785                	li	a5,1
    80001fb8:	06f71763          	bne	a4,a5,80002026 <sched+0xa6>
  if(p->state == RUNNING)
    80001fbc:	4c98                	lw	a4,24(s1)
    80001fbe:	4791                	li	a5,4
    80001fc0:	06f70b63          	beq	a4,a5,80002036 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fc4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fc8:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001fca:	efb5                	bnez	a5,80002046 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fcc:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fce:	0000f917          	auipc	s2,0xf
    80001fd2:	2d290913          	addi	s2,s2,722 # 800112a0 <pid_lock>
    80001fd6:	2781                	sext.w	a5,a5
    80001fd8:	079e                	slli	a5,a5,0x7
    80001fda:	97ca                	add	a5,a5,s2
    80001fdc:	0ac7a983          	lw	s3,172(a5)
    80001fe0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fe2:	2781                	sext.w	a5,a5
    80001fe4:	079e                	slli	a5,a5,0x7
    80001fe6:	0000f597          	auipc	a1,0xf
    80001fea:	2f258593          	addi	a1,a1,754 # 800112d8 <cpus+0x8>
    80001fee:	95be                	add	a1,a1,a5
    80001ff0:	06848513          	addi	a0,s1,104
    80001ff4:	00000097          	auipc	ra,0x0
    80001ff8:	738080e7          	jalr	1848(ra) # 8000272c <swtch>
    80001ffc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ffe:	2781                	sext.w	a5,a5
    80002000:	079e                	slli	a5,a5,0x7
    80002002:	993e                	add	s2,s2,a5
    80002004:	0b392623          	sw	s3,172(s2)
}
    80002008:	70a2                	ld	ra,40(sp)
    8000200a:	7402                	ld	s0,32(sp)
    8000200c:	64e2                	ld	s1,24(sp)
    8000200e:	6942                	ld	s2,16(sp)
    80002010:	69a2                	ld	s3,8(sp)
    80002012:	6145                	addi	sp,sp,48
    80002014:	8082                	ret
    panic("sched p->lock");
    80002016:	00006517          	auipc	a0,0x6
    8000201a:	20250513          	addi	a0,a0,514 # 80008218 <digits+0x1d8>
    8000201e:	ffffe097          	auipc	ra,0xffffe
    80002022:	51c080e7          	jalr	1308(ra) # 8000053a <panic>
    panic("sched locks");
    80002026:	00006517          	auipc	a0,0x6
    8000202a:	20250513          	addi	a0,a0,514 # 80008228 <digits+0x1e8>
    8000202e:	ffffe097          	auipc	ra,0xffffe
    80002032:	50c080e7          	jalr	1292(ra) # 8000053a <panic>
    panic("sched running");
    80002036:	00006517          	auipc	a0,0x6
    8000203a:	20250513          	addi	a0,a0,514 # 80008238 <digits+0x1f8>
    8000203e:	ffffe097          	auipc	ra,0xffffe
    80002042:	4fc080e7          	jalr	1276(ra) # 8000053a <panic>
    panic("sched interruptible");
    80002046:	00006517          	auipc	a0,0x6
    8000204a:	20250513          	addi	a0,a0,514 # 80008248 <digits+0x208>
    8000204e:	ffffe097          	auipc	ra,0xffffe
    80002052:	4ec080e7          	jalr	1260(ra) # 8000053a <panic>

0000000080002056 <yield>:
{
    80002056:	1101                	addi	sp,sp,-32
    80002058:	ec06                	sd	ra,24(sp)
    8000205a:	e822                	sd	s0,16(sp)
    8000205c:	e426                	sd	s1,8(sp)
    8000205e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002060:	00000097          	auipc	ra,0x0
    80002064:	936080e7          	jalr	-1738(ra) # 80001996 <myproc>
    80002068:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000206a:	fffff097          	auipc	ra,0xfffff
    8000206e:	b66080e7          	jalr	-1178(ra) # 80000bd0 <acquire>
  p->state = RUNNABLE;
    80002072:	478d                	li	a5,3
    80002074:	cc9c                	sw	a5,24(s1)
  sched();
    80002076:	00000097          	auipc	ra,0x0
    8000207a:	f0a080e7          	jalr	-246(ra) # 80001f80 <sched>
  release(&p->lock);
    8000207e:	8526                	mv	a0,s1
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	c04080e7          	jalr	-1020(ra) # 80000c84 <release>
}
    80002088:	60e2                	ld	ra,24(sp)
    8000208a:	6442                	ld	s0,16(sp)
    8000208c:	64a2                	ld	s1,8(sp)
    8000208e:	6105                	addi	sp,sp,32
    80002090:	8082                	ret

0000000080002092 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002092:	7179                	addi	sp,sp,-48
    80002094:	f406                	sd	ra,40(sp)
    80002096:	f022                	sd	s0,32(sp)
    80002098:	ec26                	sd	s1,24(sp)
    8000209a:	e84a                	sd	s2,16(sp)
    8000209c:	e44e                	sd	s3,8(sp)
    8000209e:	1800                	addi	s0,sp,48
    800020a0:	89aa                	mv	s3,a0
    800020a2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020a4:	00000097          	auipc	ra,0x0
    800020a8:	8f2080e7          	jalr	-1806(ra) # 80001996 <myproc>
    800020ac:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020ae:	fffff097          	auipc	ra,0xfffff
    800020b2:	b22080e7          	jalr	-1246(ra) # 80000bd0 <acquire>
  release(lk);
    800020b6:	854a                	mv	a0,s2
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	bcc080e7          	jalr	-1076(ra) # 80000c84 <release>

  // Go to sleep.
  p->chan = chan;
    800020c0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020c4:	4789                	li	a5,2
    800020c6:	cc9c                	sw	a5,24(s1)

  sched();
    800020c8:	00000097          	auipc	ra,0x0
    800020cc:	eb8080e7          	jalr	-328(ra) # 80001f80 <sched>

  // Tidy up.
  p->chan = 0;
    800020d0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020d4:	8526                	mv	a0,s1
    800020d6:	fffff097          	auipc	ra,0xfffff
    800020da:	bae080e7          	jalr	-1106(ra) # 80000c84 <release>
  acquire(lk);
    800020de:	854a                	mv	a0,s2
    800020e0:	fffff097          	auipc	ra,0xfffff
    800020e4:	af0080e7          	jalr	-1296(ra) # 80000bd0 <acquire>
}
    800020e8:	70a2                	ld	ra,40(sp)
    800020ea:	7402                	ld	s0,32(sp)
    800020ec:	64e2                	ld	s1,24(sp)
    800020ee:	6942                	ld	s2,16(sp)
    800020f0:	69a2                	ld	s3,8(sp)
    800020f2:	6145                	addi	sp,sp,48
    800020f4:	8082                	ret

00000000800020f6 <wait>:
{
    800020f6:	715d                	addi	sp,sp,-80
    800020f8:	e486                	sd	ra,72(sp)
    800020fa:	e0a2                	sd	s0,64(sp)
    800020fc:	fc26                	sd	s1,56(sp)
    800020fe:	f84a                	sd	s2,48(sp)
    80002100:	f44e                	sd	s3,40(sp)
    80002102:	f052                	sd	s4,32(sp)
    80002104:	ec56                	sd	s5,24(sp)
    80002106:	e85a                	sd	s6,16(sp)
    80002108:	e45e                	sd	s7,8(sp)
    8000210a:	e062                	sd	s8,0(sp)
    8000210c:	0880                	addi	s0,sp,80
    8000210e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002110:	00000097          	auipc	ra,0x0
    80002114:	886080e7          	jalr	-1914(ra) # 80001996 <myproc>
    80002118:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000211a:	0000f517          	auipc	a0,0xf
    8000211e:	19e50513          	addi	a0,a0,414 # 800112b8 <wait_lock>
    80002122:	fffff097          	auipc	ra,0xfffff
    80002126:	aae080e7          	jalr	-1362(ra) # 80000bd0 <acquire>
    havekids = 0;
    8000212a:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000212c:	4a15                	li	s4,5
        havekids = 1;
    8000212e:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002130:	00015997          	auipc	s3,0x15
    80002134:	3a098993          	addi	s3,s3,928 # 800174d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002138:	0000fc17          	auipc	s8,0xf
    8000213c:	180c0c13          	addi	s8,s8,384 # 800112b8 <wait_lock>
    havekids = 0;
    80002140:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002142:	0000f497          	auipc	s1,0xf
    80002146:	58e48493          	addi	s1,s1,1422 # 800116d0 <proc>
    8000214a:	a0bd                	j	800021b8 <wait+0xc2>
          pid = np->pid;
    8000214c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002150:	000b0e63          	beqz	s6,8000216c <wait+0x76>
    80002154:	4691                	li	a3,4
    80002156:	02c48613          	addi	a2,s1,44
    8000215a:	85da                	mv	a1,s6
    8000215c:	05893503          	ld	a0,88(s2)
    80002160:	fffff097          	auipc	ra,0xfffff
    80002164:	4fa080e7          	jalr	1274(ra) # 8000165a <copyout>
    80002168:	02054563          	bltz	a0,80002192 <wait+0x9c>
          freeproc(np);
    8000216c:	8526                	mv	a0,s1
    8000216e:	00000097          	auipc	ra,0x0
    80002172:	9da080e7          	jalr	-1574(ra) # 80001b48 <freeproc>
          release(&np->lock);
    80002176:	8526                	mv	a0,s1
    80002178:	fffff097          	auipc	ra,0xfffff
    8000217c:	b0c080e7          	jalr	-1268(ra) # 80000c84 <release>
          release(&wait_lock);
    80002180:	0000f517          	auipc	a0,0xf
    80002184:	13850513          	addi	a0,a0,312 # 800112b8 <wait_lock>
    80002188:	fffff097          	auipc	ra,0xfffff
    8000218c:	afc080e7          	jalr	-1284(ra) # 80000c84 <release>
          return pid;
    80002190:	a09d                	j	800021f6 <wait+0x100>
            release(&np->lock);
    80002192:	8526                	mv	a0,s1
    80002194:	fffff097          	auipc	ra,0xfffff
    80002198:	af0080e7          	jalr	-1296(ra) # 80000c84 <release>
            release(&wait_lock);
    8000219c:	0000f517          	auipc	a0,0xf
    800021a0:	11c50513          	addi	a0,a0,284 # 800112b8 <wait_lock>
    800021a4:	fffff097          	auipc	ra,0xfffff
    800021a8:	ae0080e7          	jalr	-1312(ra) # 80000c84 <release>
            return -1;
    800021ac:	59fd                	li	s3,-1
    800021ae:	a0a1                	j	800021f6 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800021b0:	17848493          	addi	s1,s1,376
    800021b4:	03348463          	beq	s1,s3,800021dc <wait+0xe6>
      if(np->parent == p){
    800021b8:	60bc                	ld	a5,64(s1)
    800021ba:	ff279be3          	bne	a5,s2,800021b0 <wait+0xba>
        acquire(&np->lock);
    800021be:	8526                	mv	a0,s1
    800021c0:	fffff097          	auipc	ra,0xfffff
    800021c4:	a10080e7          	jalr	-1520(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    800021c8:	4c9c                	lw	a5,24(s1)
    800021ca:	f94781e3          	beq	a5,s4,8000214c <wait+0x56>
        release(&np->lock);
    800021ce:	8526                	mv	a0,s1
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	ab4080e7          	jalr	-1356(ra) # 80000c84 <release>
        havekids = 1;
    800021d8:	8756                	mv	a4,s5
    800021da:	bfd9                	j	800021b0 <wait+0xba>
    if(!havekids || p->killed){
    800021dc:	c701                	beqz	a4,800021e4 <wait+0xee>
    800021de:	02892783          	lw	a5,40(s2)
    800021e2:	c79d                	beqz	a5,80002210 <wait+0x11a>
      release(&wait_lock);
    800021e4:	0000f517          	auipc	a0,0xf
    800021e8:	0d450513          	addi	a0,a0,212 # 800112b8 <wait_lock>
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	a98080e7          	jalr	-1384(ra) # 80000c84 <release>
      return -1;
    800021f4:	59fd                	li	s3,-1
}
    800021f6:	854e                	mv	a0,s3
    800021f8:	60a6                	ld	ra,72(sp)
    800021fa:	6406                	ld	s0,64(sp)
    800021fc:	74e2                	ld	s1,56(sp)
    800021fe:	7942                	ld	s2,48(sp)
    80002200:	79a2                	ld	s3,40(sp)
    80002202:	7a02                	ld	s4,32(sp)
    80002204:	6ae2                	ld	s5,24(sp)
    80002206:	6b42                	ld	s6,16(sp)
    80002208:	6ba2                	ld	s7,8(sp)
    8000220a:	6c02                	ld	s8,0(sp)
    8000220c:	6161                	addi	sp,sp,80
    8000220e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002210:	85e2                	mv	a1,s8
    80002212:	854a                	mv	a0,s2
    80002214:	00000097          	auipc	ra,0x0
    80002218:	e7e080e7          	jalr	-386(ra) # 80002092 <sleep>
    havekids = 0;
    8000221c:	b715                	j	80002140 <wait+0x4a>

000000008000221e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000221e:	7139                	addi	sp,sp,-64
    80002220:	fc06                	sd	ra,56(sp)
    80002222:	f822                	sd	s0,48(sp)
    80002224:	f426                	sd	s1,40(sp)
    80002226:	f04a                	sd	s2,32(sp)
    80002228:	ec4e                	sd	s3,24(sp)
    8000222a:	e852                	sd	s4,16(sp)
    8000222c:	e456                	sd	s5,8(sp)
    8000222e:	0080                	addi	s0,sp,64
    80002230:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002232:	0000f497          	auipc	s1,0xf
    80002236:	49e48493          	addi	s1,s1,1182 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000223a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000223c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000223e:	00015917          	auipc	s2,0x15
    80002242:	29290913          	addi	s2,s2,658 # 800174d0 <tickslock>
    80002246:	a811                	j	8000225a <wakeup+0x3c>
      }
      release(&p->lock);
    80002248:	8526                	mv	a0,s1
    8000224a:	fffff097          	auipc	ra,0xfffff
    8000224e:	a3a080e7          	jalr	-1478(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002252:	17848493          	addi	s1,s1,376
    80002256:	03248663          	beq	s1,s2,80002282 <wakeup+0x64>
    if(p != myproc()){
    8000225a:	fffff097          	auipc	ra,0xfffff
    8000225e:	73c080e7          	jalr	1852(ra) # 80001996 <myproc>
    80002262:	fea488e3          	beq	s1,a0,80002252 <wakeup+0x34>
      acquire(&p->lock);
    80002266:	8526                	mv	a0,s1
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	968080e7          	jalr	-1688(ra) # 80000bd0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002270:	4c9c                	lw	a5,24(s1)
    80002272:	fd379be3          	bne	a5,s3,80002248 <wakeup+0x2a>
    80002276:	709c                	ld	a5,32(s1)
    80002278:	fd4798e3          	bne	a5,s4,80002248 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000227c:	0154ac23          	sw	s5,24(s1)
    80002280:	b7e1                	j	80002248 <wakeup+0x2a>
    }
  }
}
    80002282:	70e2                	ld	ra,56(sp)
    80002284:	7442                	ld	s0,48(sp)
    80002286:	74a2                	ld	s1,40(sp)
    80002288:	7902                	ld	s2,32(sp)
    8000228a:	69e2                	ld	s3,24(sp)
    8000228c:	6a42                	ld	s4,16(sp)
    8000228e:	6aa2                	ld	s5,8(sp)
    80002290:	6121                	addi	sp,sp,64
    80002292:	8082                	ret

0000000080002294 <reparent>:
{
    80002294:	7179                	addi	sp,sp,-48
    80002296:	f406                	sd	ra,40(sp)
    80002298:	f022                	sd	s0,32(sp)
    8000229a:	ec26                	sd	s1,24(sp)
    8000229c:	e84a                	sd	s2,16(sp)
    8000229e:	e44e                	sd	s3,8(sp)
    800022a0:	e052                	sd	s4,0(sp)
    800022a2:	1800                	addi	s0,sp,48
    800022a4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022a6:	0000f497          	auipc	s1,0xf
    800022aa:	42a48493          	addi	s1,s1,1066 # 800116d0 <proc>
      pp->parent = initproc;
    800022ae:	00007a17          	auipc	s4,0x7
    800022b2:	d7aa0a13          	addi	s4,s4,-646 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022b6:	00015997          	auipc	s3,0x15
    800022ba:	21a98993          	addi	s3,s3,538 # 800174d0 <tickslock>
    800022be:	a029                	j	800022c8 <reparent+0x34>
    800022c0:	17848493          	addi	s1,s1,376
    800022c4:	01348d63          	beq	s1,s3,800022de <reparent+0x4a>
    if(pp->parent == p){
    800022c8:	60bc                	ld	a5,64(s1)
    800022ca:	ff279be3          	bne	a5,s2,800022c0 <reparent+0x2c>
      pp->parent = initproc;
    800022ce:	000a3503          	ld	a0,0(s4)
    800022d2:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    800022d4:	00000097          	auipc	ra,0x0
    800022d8:	f4a080e7          	jalr	-182(ra) # 8000221e <wakeup>
    800022dc:	b7d5                	j	800022c0 <reparent+0x2c>
}
    800022de:	70a2                	ld	ra,40(sp)
    800022e0:	7402                	ld	s0,32(sp)
    800022e2:	64e2                	ld	s1,24(sp)
    800022e4:	6942                	ld	s2,16(sp)
    800022e6:	69a2                	ld	s3,8(sp)
    800022e8:	6a02                	ld	s4,0(sp)
    800022ea:	6145                	addi	sp,sp,48
    800022ec:	8082                	ret

00000000800022ee <exit>:
{
    800022ee:	7179                	addi	sp,sp,-48
    800022f0:	f406                	sd	ra,40(sp)
    800022f2:	f022                	sd	s0,32(sp)
    800022f4:	ec26                	sd	s1,24(sp)
    800022f6:	e84a                	sd	s2,16(sp)
    800022f8:	e44e                	sd	s3,8(sp)
    800022fa:	e052                	sd	s4,0(sp)
    800022fc:	1800                	addi	s0,sp,48
    800022fe:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002300:	fffff097          	auipc	ra,0xfffff
    80002304:	696080e7          	jalr	1686(ra) # 80001996 <myproc>
    80002308:	89aa                	mv	s3,a0
  acquire(&tickslock);
    8000230a:	00015517          	auipc	a0,0x15
    8000230e:	1c650513          	addi	a0,a0,454 # 800174d0 <tickslock>
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	8be080e7          	jalr	-1858(ra) # 80000bd0 <acquire>
  p->ended = ticks;
    8000231a:	00007797          	auipc	a5,0x7
    8000231e:	d167a783          	lw	a5,-746(a5) # 80009030 <ticks>
    80002322:	02f9ac23          	sw	a5,56(s3)
  release(&tickslock);
    80002326:	00015517          	auipc	a0,0x15
    8000232a:	1aa50513          	addi	a0,a0,426 # 800174d0 <tickslock>
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	956080e7          	jalr	-1706(ra) # 80000c84 <release>
  if(p == initproc)
    80002336:	00007797          	auipc	a5,0x7
    8000233a:	cf27b783          	ld	a5,-782(a5) # 80009028 <initproc>
    8000233e:	0d898493          	addi	s1,s3,216
    80002342:	15898913          	addi	s2,s3,344
    80002346:	03379363          	bne	a5,s3,8000236c <exit+0x7e>
    panic("init exiting");
    8000234a:	00006517          	auipc	a0,0x6
    8000234e:	f1650513          	addi	a0,a0,-234 # 80008260 <digits+0x220>
    80002352:	ffffe097          	auipc	ra,0xffffe
    80002356:	1e8080e7          	jalr	488(ra) # 8000053a <panic>
      fileclose(f);
    8000235a:	00002097          	auipc	ra,0x2
    8000235e:	33e080e7          	jalr	830(ra) # 80004698 <fileclose>
      p->ofile[fd] = 0;
    80002362:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002366:	04a1                	addi	s1,s1,8
    80002368:	01248563          	beq	s1,s2,80002372 <exit+0x84>
    if(p->ofile[fd]){
    8000236c:	6088                	ld	a0,0(s1)
    8000236e:	f575                	bnez	a0,8000235a <exit+0x6c>
    80002370:	bfdd                	j	80002366 <exit+0x78>
  begin_op();
    80002372:	00002097          	auipc	ra,0x2
    80002376:	e5e080e7          	jalr	-418(ra) # 800041d0 <begin_op>
  iput(p->cwd);
    8000237a:	1589b503          	ld	a0,344(s3)
    8000237e:	00001097          	auipc	ra,0x1
    80002382:	630080e7          	jalr	1584(ra) # 800039ae <iput>
  end_op();
    80002386:	00002097          	auipc	ra,0x2
    8000238a:	ec8080e7          	jalr	-312(ra) # 8000424e <end_op>
  p->cwd = 0;
    8000238e:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    80002392:	0000f497          	auipc	s1,0xf
    80002396:	f2648493          	addi	s1,s1,-218 # 800112b8 <wait_lock>
    8000239a:	8526                	mv	a0,s1
    8000239c:	fffff097          	auipc	ra,0xfffff
    800023a0:	834080e7          	jalr	-1996(ra) # 80000bd0 <acquire>
  reparent(p);
    800023a4:	854e                	mv	a0,s3
    800023a6:	00000097          	auipc	ra,0x0
    800023aa:	eee080e7          	jalr	-274(ra) # 80002294 <reparent>
  wakeup(p->parent);
    800023ae:	0409b503          	ld	a0,64(s3)
    800023b2:	00000097          	auipc	ra,0x0
    800023b6:	e6c080e7          	jalr	-404(ra) # 8000221e <wakeup>
  acquire(&p->lock);
    800023ba:	854e                	mv	a0,s3
    800023bc:	fffff097          	auipc	ra,0xfffff
    800023c0:	814080e7          	jalr	-2028(ra) # 80000bd0 <acquire>
  p->xstate = status;
    800023c4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023c8:	4795                	li	a5,5
    800023ca:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800023ce:	8526                	mv	a0,s1
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	8b4080e7          	jalr	-1868(ra) # 80000c84 <release>
  sched();
    800023d8:	00000097          	auipc	ra,0x0
    800023dc:	ba8080e7          	jalr	-1112(ra) # 80001f80 <sched>
  panic("zombie exit");
    800023e0:	00006517          	auipc	a0,0x6
    800023e4:	e9050513          	addi	a0,a0,-368 # 80008270 <digits+0x230>
    800023e8:	ffffe097          	auipc	ra,0xffffe
    800023ec:	152080e7          	jalr	338(ra) # 8000053a <panic>

00000000800023f0 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800023f0:	7179                	addi	sp,sp,-48
    800023f2:	f406                	sd	ra,40(sp)
    800023f4:	f022                	sd	s0,32(sp)
    800023f6:	ec26                	sd	s1,24(sp)
    800023f8:	e84a                	sd	s2,16(sp)
    800023fa:	e44e                	sd	s3,8(sp)
    800023fc:	1800                	addi	s0,sp,48
    800023fe:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002400:	0000f497          	auipc	s1,0xf
    80002404:	2d048493          	addi	s1,s1,720 # 800116d0 <proc>
    80002408:	00015997          	auipc	s3,0x15
    8000240c:	0c898993          	addi	s3,s3,200 # 800174d0 <tickslock>
    acquire(&p->lock);
    80002410:	8526                	mv	a0,s1
    80002412:	ffffe097          	auipc	ra,0xffffe
    80002416:	7be080e7          	jalr	1982(ra) # 80000bd0 <acquire>
    if(p->pid == pid){
    8000241a:	589c                	lw	a5,48(s1)
    8000241c:	01278d63          	beq	a5,s2,80002436 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002420:	8526                	mv	a0,s1
    80002422:	fffff097          	auipc	ra,0xfffff
    80002426:	862080e7          	jalr	-1950(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000242a:	17848493          	addi	s1,s1,376
    8000242e:	ff3491e3          	bne	s1,s3,80002410 <kill+0x20>
  }
  return -1;
    80002432:	557d                	li	a0,-1
    80002434:	a829                	j	8000244e <kill+0x5e>
      p->killed = 1;
    80002436:	4785                	li	a5,1
    80002438:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000243a:	4c98                	lw	a4,24(s1)
    8000243c:	4789                	li	a5,2
    8000243e:	00f70f63          	beq	a4,a5,8000245c <kill+0x6c>
      release(&p->lock);
    80002442:	8526                	mv	a0,s1
    80002444:	fffff097          	auipc	ra,0xfffff
    80002448:	840080e7          	jalr	-1984(ra) # 80000c84 <release>
      return 0;
    8000244c:	4501                	li	a0,0
}
    8000244e:	70a2                	ld	ra,40(sp)
    80002450:	7402                	ld	s0,32(sp)
    80002452:	64e2                	ld	s1,24(sp)
    80002454:	6942                	ld	s2,16(sp)
    80002456:	69a2                	ld	s3,8(sp)
    80002458:	6145                	addi	sp,sp,48
    8000245a:	8082                	ret
        p->state = RUNNABLE;
    8000245c:	478d                	li	a5,3
    8000245e:	cc9c                	sw	a5,24(s1)
    80002460:	b7cd                	j	80002442 <kill+0x52>

0000000080002462 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002462:	7179                	addi	sp,sp,-48
    80002464:	f406                	sd	ra,40(sp)
    80002466:	f022                	sd	s0,32(sp)
    80002468:	ec26                	sd	s1,24(sp)
    8000246a:	e84a                	sd	s2,16(sp)
    8000246c:	e44e                	sd	s3,8(sp)
    8000246e:	e052                	sd	s4,0(sp)
    80002470:	1800                	addi	s0,sp,48
    80002472:	84aa                	mv	s1,a0
    80002474:	892e                	mv	s2,a1
    80002476:	89b2                	mv	s3,a2
    80002478:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	51c080e7          	jalr	1308(ra) # 80001996 <myproc>
  if(user_dst){
    80002482:	c08d                	beqz	s1,800024a4 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002484:	86d2                	mv	a3,s4
    80002486:	864e                	mv	a2,s3
    80002488:	85ca                	mv	a1,s2
    8000248a:	6d28                	ld	a0,88(a0)
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	1ce080e7          	jalr	462(ra) # 8000165a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002494:	70a2                	ld	ra,40(sp)
    80002496:	7402                	ld	s0,32(sp)
    80002498:	64e2                	ld	s1,24(sp)
    8000249a:	6942                	ld	s2,16(sp)
    8000249c:	69a2                	ld	s3,8(sp)
    8000249e:	6a02                	ld	s4,0(sp)
    800024a0:	6145                	addi	sp,sp,48
    800024a2:	8082                	ret
    memmove((char *)dst, src, len);
    800024a4:	000a061b          	sext.w	a2,s4
    800024a8:	85ce                	mv	a1,s3
    800024aa:	854a                	mv	a0,s2
    800024ac:	fffff097          	auipc	ra,0xfffff
    800024b0:	87c080e7          	jalr	-1924(ra) # 80000d28 <memmove>
    return 0;
    800024b4:	8526                	mv	a0,s1
    800024b6:	bff9                	j	80002494 <either_copyout+0x32>

00000000800024b8 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024b8:	7179                	addi	sp,sp,-48
    800024ba:	f406                	sd	ra,40(sp)
    800024bc:	f022                	sd	s0,32(sp)
    800024be:	ec26                	sd	s1,24(sp)
    800024c0:	e84a                	sd	s2,16(sp)
    800024c2:	e44e                	sd	s3,8(sp)
    800024c4:	e052                	sd	s4,0(sp)
    800024c6:	1800                	addi	s0,sp,48
    800024c8:	892a                	mv	s2,a0
    800024ca:	84ae                	mv	s1,a1
    800024cc:	89b2                	mv	s3,a2
    800024ce:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024d0:	fffff097          	auipc	ra,0xfffff
    800024d4:	4c6080e7          	jalr	1222(ra) # 80001996 <myproc>
  if(user_src){
    800024d8:	c08d                	beqz	s1,800024fa <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024da:	86d2                	mv	a3,s4
    800024dc:	864e                	mv	a2,s3
    800024de:	85ca                	mv	a1,s2
    800024e0:	6d28                	ld	a0,88(a0)
    800024e2:	fffff097          	auipc	ra,0xfffff
    800024e6:	204080e7          	jalr	516(ra) # 800016e6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024ea:	70a2                	ld	ra,40(sp)
    800024ec:	7402                	ld	s0,32(sp)
    800024ee:	64e2                	ld	s1,24(sp)
    800024f0:	6942                	ld	s2,16(sp)
    800024f2:	69a2                	ld	s3,8(sp)
    800024f4:	6a02                	ld	s4,0(sp)
    800024f6:	6145                	addi	sp,sp,48
    800024f8:	8082                	ret
    memmove(dst, (char*)src, len);
    800024fa:	000a061b          	sext.w	a2,s4
    800024fe:	85ce                	mv	a1,s3
    80002500:	854a                	mv	a0,s2
    80002502:	fffff097          	auipc	ra,0xfffff
    80002506:	826080e7          	jalr	-2010(ra) # 80000d28 <memmove>
    return 0;
    8000250a:	8526                	mv	a0,s1
    8000250c:	bff9                	j	800024ea <either_copyin+0x32>

000000008000250e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000250e:	715d                	addi	sp,sp,-80
    80002510:	e486                	sd	ra,72(sp)
    80002512:	e0a2                	sd	s0,64(sp)
    80002514:	fc26                	sd	s1,56(sp)
    80002516:	f84a                	sd	s2,48(sp)
    80002518:	f44e                	sd	s3,40(sp)
    8000251a:	f052                	sd	s4,32(sp)
    8000251c:	ec56                	sd	s5,24(sp)
    8000251e:	e85a                	sd	s6,16(sp)
    80002520:	e45e                	sd	s7,8(sp)
    80002522:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002524:	00006517          	auipc	a0,0x6
    80002528:	ba450513          	addi	a0,a0,-1116 # 800080c8 <digits+0x88>
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	058080e7          	jalr	88(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002534:	0000f497          	auipc	s1,0xf
    80002538:	2fc48493          	addi	s1,s1,764 # 80011830 <proc+0x160>
    8000253c:	00015917          	auipc	s2,0x15
    80002540:	0f490913          	addi	s2,s2,244 # 80017630 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002544:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002546:	00006997          	auipc	s3,0x6
    8000254a:	d3a98993          	addi	s3,s3,-710 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    8000254e:	00006a97          	auipc	s5,0x6
    80002552:	d3aa8a93          	addi	s5,s5,-710 # 80008288 <digits+0x248>
    printf("\n");
    80002556:	00006a17          	auipc	s4,0x6
    8000255a:	b72a0a13          	addi	s4,s4,-1166 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000255e:	00006b97          	auipc	s7,0x6
    80002562:	d62b8b93          	addi	s7,s7,-670 # 800082c0 <states.0>
    80002566:	a00d                	j	80002588 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002568:	ed06a583          	lw	a1,-304(a3)
    8000256c:	8556                	mv	a0,s5
    8000256e:	ffffe097          	auipc	ra,0xffffe
    80002572:	016080e7          	jalr	22(ra) # 80000584 <printf>
    printf("\n");
    80002576:	8552                	mv	a0,s4
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	00c080e7          	jalr	12(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002580:	17848493          	addi	s1,s1,376
    80002584:	03248263          	beq	s1,s2,800025a8 <procdump+0x9a>
    if(p->state == UNUSED)
    80002588:	86a6                	mv	a3,s1
    8000258a:	eb84a783          	lw	a5,-328(s1)
    8000258e:	dbed                	beqz	a5,80002580 <procdump+0x72>
      state = "???";
    80002590:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002592:	fcfb6be3          	bltu	s6,a5,80002568 <procdump+0x5a>
    80002596:	02079713          	slli	a4,a5,0x20
    8000259a:	01d75793          	srli	a5,a4,0x1d
    8000259e:	97de                	add	a5,a5,s7
    800025a0:	6390                	ld	a2,0(a5)
    800025a2:	f279                	bnez	a2,80002568 <procdump+0x5a>
      state = "???";
    800025a4:	864e                	mv	a2,s3
    800025a6:	b7c9                	j	80002568 <procdump+0x5a>
  }
}
    800025a8:	60a6                	ld	ra,72(sp)
    800025aa:	6406                	ld	s0,64(sp)
    800025ac:	74e2                	ld	s1,56(sp)
    800025ae:	7942                	ld	s2,48(sp)
    800025b0:	79a2                	ld	s3,40(sp)
    800025b2:	7a02                	ld	s4,32(sp)
    800025b4:	6ae2                	ld	s5,24(sp)
    800025b6:	6b42                	ld	s6,16(sp)
    800025b8:	6ba2                	ld	s7,8(sp)
    800025ba:	6161                	addi	sp,sp,80
    800025bc:	8082                	ret

00000000800025be <waitstat>:
//     return 101;
// }

//,uint64* turnaroundTime, uint64* runTime

int waitstat(uint64 addr,uint64 turnaroundTime, uint64 runTime ){
    800025be:	7159                	addi	sp,sp,-112
    800025c0:	f486                	sd	ra,104(sp)
    800025c2:	f0a2                	sd	s0,96(sp)
    800025c4:	eca6                	sd	s1,88(sp)
    800025c6:	e8ca                	sd	s2,80(sp)
    800025c8:	e4ce                	sd	s3,72(sp)
    800025ca:	e0d2                	sd	s4,64(sp)
    800025cc:	fc56                	sd	s5,56(sp)
    800025ce:	f85a                	sd	s6,48(sp)
    800025d0:	f45e                	sd	s7,40(sp)
    800025d2:	f062                	sd	s8,32(sp)
    800025d4:	ec66                	sd	s9,24(sp)
    800025d6:	e86a                	sd	s10,16(sp)
    800025d8:	1880                	addi	s0,sp,112
    800025da:	8b2a                	mv	s6,a0
    800025dc:	8c2e                	mv	s8,a1
    800025de:	8bb2                	mv	s7,a2

    struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800025e0:	fffff097          	auipc	ra,0xfffff
    800025e4:	3b6080e7          	jalr	950(ra) # 80001996 <myproc>
    800025e8:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800025ea:	0000f517          	auipc	a0,0xf
    800025ee:	cce50513          	addi	a0,a0,-818 # 800112b8 <wait_lock>
    800025f2:	ffffe097          	auipc	ra,0xffffe
    800025f6:	5de080e7          	jalr	1502(ra) # 80000bd0 <acquire>

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    800025fa:	4c81                	li	s9,0
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
    800025fc:	4a15                	li	s4,5
        havekids = 1;
    800025fe:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002600:	00015997          	auipc	s3,0x15
    80002604:	ed098993          	addi	s3,s3,-304 # 800174d0 <tickslock>
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002608:	0000fd17          	auipc	s10,0xf
    8000260c:	cb0d0d13          	addi	s10,s10,-848 # 800112b8 <wait_lock>
    havekids = 0;
    80002610:	8766                	mv	a4,s9
    for(np = proc; np < &proc[NPROC]; np++){
    80002612:	0000f497          	auipc	s1,0xf
    80002616:	0be48493          	addi	s1,s1,190 # 800116d0 <proc>
    8000261a:	a065                	j	800026c2 <waitstat+0x104>
          int rTime = np->running;
    8000261c:	1704a783          	lw	a5,368(s1)
    80002620:	f8f42c23          	sw	a5,-104(s0)
          int tTime = np->ended - np-> created;
    80002624:	5c9c                	lw	a5,56(s1)
    80002626:	58d8                	lw	a4,52(s1)
    80002628:	9f99                	subw	a5,a5,a4
    8000262a:	f8f42e23          	sw	a5,-100(s0)
          copyout(p->pagetable, turnaroundTime, (char *)&tTime,
    8000262e:	4691                	li	a3,4
    80002630:	f9c40613          	addi	a2,s0,-100
    80002634:	85e2                	mv	a1,s8
    80002636:	05893503          	ld	a0,88(s2)
    8000263a:	fffff097          	auipc	ra,0xfffff
    8000263e:	020080e7          	jalr	32(ra) # 8000165a <copyout>
          copyout(p->pagetable, runTime, (char *)&rTime,
    80002642:	4691                	li	a3,4
    80002644:	f9840613          	addi	a2,s0,-104
    80002648:	85de                	mv	a1,s7
    8000264a:	05893503          	ld	a0,88(s2)
    8000264e:	fffff097          	auipc	ra,0xfffff
    80002652:	00c080e7          	jalr	12(ra) # 8000165a <copyout>
          pid = np->pid;
    80002656:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000265a:	000b0e63          	beqz	s6,80002676 <waitstat+0xb8>
    8000265e:	4691                	li	a3,4
    80002660:	02c48613          	addi	a2,s1,44
    80002664:	85da                	mv	a1,s6
    80002666:	05893503          	ld	a0,88(s2)
    8000266a:	fffff097          	auipc	ra,0xfffff
    8000266e:	ff0080e7          	jalr	-16(ra) # 8000165a <copyout>
    80002672:	02054563          	bltz	a0,8000269c <waitstat+0xde>
          freeproc(np);
    80002676:	8526                	mv	a0,s1
    80002678:	fffff097          	auipc	ra,0xfffff
    8000267c:	4d0080e7          	jalr	1232(ra) # 80001b48 <freeproc>
          release(&np->lock);
    80002680:	8526                	mv	a0,s1
    80002682:	ffffe097          	auipc	ra,0xffffe
    80002686:	602080e7          	jalr	1538(ra) # 80000c84 <release>
          release(&wait_lock);
    8000268a:	0000f517          	auipc	a0,0xf
    8000268e:	c2e50513          	addi	a0,a0,-978 # 800112b8 <wait_lock>
    80002692:	ffffe097          	auipc	ra,0xffffe
    80002696:	5f2080e7          	jalr	1522(ra) # 80000c84 <release>
          return pid;
    8000269a:	a09d                	j	80002700 <waitstat+0x142>
            release(&np->lock);
    8000269c:	8526                	mv	a0,s1
    8000269e:	ffffe097          	auipc	ra,0xffffe
    800026a2:	5e6080e7          	jalr	1510(ra) # 80000c84 <release>
            release(&wait_lock);
    800026a6:	0000f517          	auipc	a0,0xf
    800026aa:	c1250513          	addi	a0,a0,-1006 # 800112b8 <wait_lock>
    800026ae:	ffffe097          	auipc	ra,0xffffe
    800026b2:	5d6080e7          	jalr	1494(ra) # 80000c84 <release>
            return -1;
    800026b6:	59fd                	li	s3,-1
    800026b8:	a0a1                	j	80002700 <waitstat+0x142>
    for(np = proc; np < &proc[NPROC]; np++){
    800026ba:	17848493          	addi	s1,s1,376
    800026be:	03348463          	beq	s1,s3,800026e6 <waitstat+0x128>
      if(np->parent == p){
    800026c2:	60bc                	ld	a5,64(s1)
    800026c4:	ff279be3          	bne	a5,s2,800026ba <waitstat+0xfc>
        acquire(&np->lock);
    800026c8:	8526                	mv	a0,s1
    800026ca:	ffffe097          	auipc	ra,0xffffe
    800026ce:	506080e7          	jalr	1286(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    800026d2:	4c9c                	lw	a5,24(s1)
    800026d4:	f54784e3          	beq	a5,s4,8000261c <waitstat+0x5e>
        release(&np->lock);
    800026d8:	8526                	mv	a0,s1
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	5aa080e7          	jalr	1450(ra) # 80000c84 <release>
        havekids = 1;
    800026e2:	8756                	mv	a4,s5
    800026e4:	bfd9                	j	800026ba <waitstat+0xfc>
    if(!havekids || p->killed){
    800026e6:	c701                	beqz	a4,800026ee <waitstat+0x130>
    800026e8:	02892783          	lw	a5,40(s2)
    800026ec:	cb8d                	beqz	a5,8000271e <waitstat+0x160>
      release(&wait_lock);
    800026ee:	0000f517          	auipc	a0,0xf
    800026f2:	bca50513          	addi	a0,a0,-1078 # 800112b8 <wait_lock>
    800026f6:	ffffe097          	auipc	ra,0xffffe
    800026fa:	58e080e7          	jalr	1422(ra) # 80000c84 <release>
      return -1;
    800026fe:	59fd                	li	s3,-1
  }
    

    80002700:	854e                	mv	a0,s3
    80002702:	70a6                	ld	ra,104(sp)
    80002704:	7406                	ld	s0,96(sp)
    80002706:	64e6                	ld	s1,88(sp)
    80002708:	6946                	ld	s2,80(sp)
    8000270a:	69a6                	ld	s3,72(sp)
    8000270c:	6a06                	ld	s4,64(sp)
    8000270e:	7ae2                	ld	s5,56(sp)
    80002710:	7b42                	ld	s6,48(sp)
    80002712:	7ba2                	ld	s7,40(sp)
    80002714:	7c02                	ld	s8,32(sp)
    80002716:	6ce2                	ld	s9,24(sp)
    80002718:	6d42                	ld	s10,16(sp)
    8000271a:	6165                	addi	sp,sp,112
    8000271c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000271e:	85ea                	mv	a1,s10
    80002720:	854a                	mv	a0,s2
    80002722:	00000097          	auipc	ra,0x0
    80002726:	970080e7          	jalr	-1680(ra) # 80002092 <sleep>
    havekids = 0;
    8000272a:	b5dd                	j	80002610 <waitstat+0x52>

000000008000272c <swtch>:
    8000272c:	00153023          	sd	ra,0(a0)
    80002730:	00253423          	sd	sp,8(a0)
    80002734:	e900                	sd	s0,16(a0)
    80002736:	ed04                	sd	s1,24(a0)
    80002738:	03253023          	sd	s2,32(a0)
    8000273c:	03353423          	sd	s3,40(a0)
    80002740:	03453823          	sd	s4,48(a0)
    80002744:	03553c23          	sd	s5,56(a0)
    80002748:	05653023          	sd	s6,64(a0)
    8000274c:	05753423          	sd	s7,72(a0)
    80002750:	05853823          	sd	s8,80(a0)
    80002754:	05953c23          	sd	s9,88(a0)
    80002758:	07a53023          	sd	s10,96(a0)
    8000275c:	07b53423          	sd	s11,104(a0)
    80002760:	0005b083          	ld	ra,0(a1)
    80002764:	0085b103          	ld	sp,8(a1)
    80002768:	6980                	ld	s0,16(a1)
    8000276a:	6d84                	ld	s1,24(a1)
    8000276c:	0205b903          	ld	s2,32(a1)
    80002770:	0285b983          	ld	s3,40(a1)
    80002774:	0305ba03          	ld	s4,48(a1)
    80002778:	0385ba83          	ld	s5,56(a1)
    8000277c:	0405bb03          	ld	s6,64(a1)
    80002780:	0485bb83          	ld	s7,72(a1)
    80002784:	0505bc03          	ld	s8,80(a1)
    80002788:	0585bc83          	ld	s9,88(a1)
    8000278c:	0605bd03          	ld	s10,96(a1)
    80002790:	0685bd83          	ld	s11,104(a1)
    80002794:	8082                	ret

0000000080002796 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002796:	1141                	addi	sp,sp,-16
    80002798:	e406                	sd	ra,8(sp)
    8000279a:	e022                	sd	s0,0(sp)
    8000279c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000279e:	00006597          	auipc	a1,0x6
    800027a2:	b5258593          	addi	a1,a1,-1198 # 800082f0 <states.0+0x30>
    800027a6:	00015517          	auipc	a0,0x15
    800027aa:	d2a50513          	addi	a0,a0,-726 # 800174d0 <tickslock>
    800027ae:	ffffe097          	auipc	ra,0xffffe
    800027b2:	392080e7          	jalr	914(ra) # 80000b40 <initlock>
}
    800027b6:	60a2                	ld	ra,8(sp)
    800027b8:	6402                	ld	s0,0(sp)
    800027ba:	0141                	addi	sp,sp,16
    800027bc:	8082                	ret

00000000800027be <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800027be:	1141                	addi	sp,sp,-16
    800027c0:	e422                	sd	s0,8(sp)
    800027c2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027c4:	00003797          	auipc	a5,0x3
    800027c8:	50c78793          	addi	a5,a5,1292 # 80005cd0 <kernelvec>
    800027cc:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800027d0:	6422                	ld	s0,8(sp)
    800027d2:	0141                	addi	sp,sp,16
    800027d4:	8082                	ret

00000000800027d6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800027d6:	1141                	addi	sp,sp,-16
    800027d8:	e406                	sd	ra,8(sp)
    800027da:	e022                	sd	s0,0(sp)
    800027dc:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800027de:	fffff097          	auipc	ra,0xfffff
    800027e2:	1b8080e7          	jalr	440(ra) # 80001996 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027e6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027ea:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027ec:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800027f0:	00005697          	auipc	a3,0x5
    800027f4:	81068693          	addi	a3,a3,-2032 # 80007000 <_trampoline>
    800027f8:	00005717          	auipc	a4,0x5
    800027fc:	80870713          	addi	a4,a4,-2040 # 80007000 <_trampoline>
    80002800:	8f15                	sub	a4,a4,a3
    80002802:	040007b7          	lui	a5,0x4000
    80002806:	17fd                	addi	a5,a5,-1
    80002808:	07b2                	slli	a5,a5,0xc
    8000280a:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000280c:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002810:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002812:	18002673          	csrr	a2,satp
    80002816:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002818:	7130                	ld	a2,96(a0)
    8000281a:	6538                	ld	a4,72(a0)
    8000281c:	6585                	lui	a1,0x1
    8000281e:	972e                	add	a4,a4,a1
    80002820:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002822:	7138                	ld	a4,96(a0)
    80002824:	00000617          	auipc	a2,0x0
    80002828:	13860613          	addi	a2,a2,312 # 8000295c <usertrap>
    8000282c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000282e:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002830:	8612                	mv	a2,tp
    80002832:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002834:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002838:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000283c:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002840:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002844:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002846:	6f18                	ld	a4,24(a4)
    80002848:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000284c:	6d2c                	ld	a1,88(a0)
    8000284e:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002850:	00005717          	auipc	a4,0x5
    80002854:	84070713          	addi	a4,a4,-1984 # 80007090 <userret>
    80002858:	8f15                	sub	a4,a4,a3
    8000285a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000285c:	577d                	li	a4,-1
    8000285e:	177e                	slli	a4,a4,0x3f
    80002860:	8dd9                	or	a1,a1,a4
    80002862:	02000537          	lui	a0,0x2000
    80002866:	157d                	addi	a0,a0,-1
    80002868:	0536                	slli	a0,a0,0xd
    8000286a:	9782                	jalr	a5
}
    8000286c:	60a2                	ld	ra,8(sp)
    8000286e:	6402                	ld	s0,0(sp)
    80002870:	0141                	addi	sp,sp,16
    80002872:	8082                	ret

0000000080002874 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002874:	1101                	addi	sp,sp,-32
    80002876:	ec06                	sd	ra,24(sp)
    80002878:	e822                	sd	s0,16(sp)
    8000287a:	e426                	sd	s1,8(sp)
    8000287c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000287e:	00015497          	auipc	s1,0x15
    80002882:	c5248493          	addi	s1,s1,-942 # 800174d0 <tickslock>
    80002886:	8526                	mv	a0,s1
    80002888:	ffffe097          	auipc	ra,0xffffe
    8000288c:	348080e7          	jalr	840(ra) # 80000bd0 <acquire>
  ticks++;
    80002890:	00006517          	auipc	a0,0x6
    80002894:	7a050513          	addi	a0,a0,1952 # 80009030 <ticks>
    80002898:	411c                	lw	a5,0(a0)
    8000289a:	2785                	addiw	a5,a5,1
    8000289c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000289e:	00000097          	auipc	ra,0x0
    800028a2:	980080e7          	jalr	-1664(ra) # 8000221e <wakeup>
  release(&tickslock);
    800028a6:	8526                	mv	a0,s1
    800028a8:	ffffe097          	auipc	ra,0xffffe
    800028ac:	3dc080e7          	jalr	988(ra) # 80000c84 <release>
}
    800028b0:	60e2                	ld	ra,24(sp)
    800028b2:	6442                	ld	s0,16(sp)
    800028b4:	64a2                	ld	s1,8(sp)
    800028b6:	6105                	addi	sp,sp,32
    800028b8:	8082                	ret

00000000800028ba <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800028ba:	1101                	addi	sp,sp,-32
    800028bc:	ec06                	sd	ra,24(sp)
    800028be:	e822                	sd	s0,16(sp)
    800028c0:	e426                	sd	s1,8(sp)
    800028c2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028c4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800028c8:	00074d63          	bltz	a4,800028e2 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800028cc:	57fd                	li	a5,-1
    800028ce:	17fe                	slli	a5,a5,0x3f
    800028d0:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800028d2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800028d4:	06f70363          	beq	a4,a5,8000293a <devintr+0x80>
  }
}
    800028d8:	60e2                	ld	ra,24(sp)
    800028da:	6442                	ld	s0,16(sp)
    800028dc:	64a2                	ld	s1,8(sp)
    800028de:	6105                	addi	sp,sp,32
    800028e0:	8082                	ret
     (scause & 0xff) == 9){
    800028e2:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    800028e6:	46a5                	li	a3,9
    800028e8:	fed792e3          	bne	a5,a3,800028cc <devintr+0x12>
    int irq = plic_claim();
    800028ec:	00003097          	auipc	ra,0x3
    800028f0:	4ec080e7          	jalr	1260(ra) # 80005dd8 <plic_claim>
    800028f4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028f6:	47a9                	li	a5,10
    800028f8:	02f50763          	beq	a0,a5,80002926 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800028fc:	4785                	li	a5,1
    800028fe:	02f50963          	beq	a0,a5,80002930 <devintr+0x76>
    return 1;
    80002902:	4505                	li	a0,1
    } else if(irq){
    80002904:	d8f1                	beqz	s1,800028d8 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002906:	85a6                	mv	a1,s1
    80002908:	00006517          	auipc	a0,0x6
    8000290c:	9f050513          	addi	a0,a0,-1552 # 800082f8 <states.0+0x38>
    80002910:	ffffe097          	auipc	ra,0xffffe
    80002914:	c74080e7          	jalr	-908(ra) # 80000584 <printf>
      plic_complete(irq);
    80002918:	8526                	mv	a0,s1
    8000291a:	00003097          	auipc	ra,0x3
    8000291e:	4e2080e7          	jalr	1250(ra) # 80005dfc <plic_complete>
    return 1;
    80002922:	4505                	li	a0,1
    80002924:	bf55                	j	800028d8 <devintr+0x1e>
      uartintr();
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	06c080e7          	jalr	108(ra) # 80000992 <uartintr>
    8000292e:	b7ed                	j	80002918 <devintr+0x5e>
      virtio_disk_intr();
    80002930:	00004097          	auipc	ra,0x4
    80002934:	958080e7          	jalr	-1704(ra) # 80006288 <virtio_disk_intr>
    80002938:	b7c5                	j	80002918 <devintr+0x5e>
    if(cpuid() == 0){
    8000293a:	fffff097          	auipc	ra,0xfffff
    8000293e:	030080e7          	jalr	48(ra) # 8000196a <cpuid>
    80002942:	c901                	beqz	a0,80002952 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002944:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002948:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000294a:	14479073          	csrw	sip,a5
    return 2;
    8000294e:	4509                	li	a0,2
    80002950:	b761                	j	800028d8 <devintr+0x1e>
      clockintr();
    80002952:	00000097          	auipc	ra,0x0
    80002956:	f22080e7          	jalr	-222(ra) # 80002874 <clockintr>
    8000295a:	b7ed                	j	80002944 <devintr+0x8a>

000000008000295c <usertrap>:
{
    8000295c:	1101                	addi	sp,sp,-32
    8000295e:	ec06                	sd	ra,24(sp)
    80002960:	e822                	sd	s0,16(sp)
    80002962:	e426                	sd	s1,8(sp)
    80002964:	e04a                	sd	s2,0(sp)
    80002966:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002968:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000296c:	1007f793          	andi	a5,a5,256
    80002970:	e3ad                	bnez	a5,800029d2 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002972:	00003797          	auipc	a5,0x3
    80002976:	35e78793          	addi	a5,a5,862 # 80005cd0 <kernelvec>
    8000297a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000297e:	fffff097          	auipc	ra,0xfffff
    80002982:	018080e7          	jalr	24(ra) # 80001996 <myproc>
    80002986:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002988:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000298a:	14102773          	csrr	a4,sepc
    8000298e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002990:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002994:	47a1                	li	a5,8
    80002996:	04f71c63          	bne	a4,a5,800029ee <usertrap+0x92>
    if(p->killed)
    8000299a:	551c                	lw	a5,40(a0)
    8000299c:	e3b9                	bnez	a5,800029e2 <usertrap+0x86>
    p->trapframe->epc += 4;
    8000299e:	70b8                	ld	a4,96(s1)
    800029a0:	6f1c                	ld	a5,24(a4)
    800029a2:	0791                	addi	a5,a5,4
    800029a4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029a6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029aa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029ae:	10079073          	csrw	sstatus,a5
    syscall();
    800029b2:	00000097          	auipc	ra,0x0
    800029b6:	2e0080e7          	jalr	736(ra) # 80002c92 <syscall>
  if(p->killed)
    800029ba:	549c                	lw	a5,40(s1)
    800029bc:	ebc1                	bnez	a5,80002a4c <usertrap+0xf0>
  usertrapret();
    800029be:	00000097          	auipc	ra,0x0
    800029c2:	e18080e7          	jalr	-488(ra) # 800027d6 <usertrapret>
}
    800029c6:	60e2                	ld	ra,24(sp)
    800029c8:	6442                	ld	s0,16(sp)
    800029ca:	64a2                	ld	s1,8(sp)
    800029cc:	6902                	ld	s2,0(sp)
    800029ce:	6105                	addi	sp,sp,32
    800029d0:	8082                	ret
    panic("usertrap: not from user mode");
    800029d2:	00006517          	auipc	a0,0x6
    800029d6:	94650513          	addi	a0,a0,-1722 # 80008318 <states.0+0x58>
    800029da:	ffffe097          	auipc	ra,0xffffe
    800029de:	b60080e7          	jalr	-1184(ra) # 8000053a <panic>
      exit(-1);
    800029e2:	557d                	li	a0,-1
    800029e4:	00000097          	auipc	ra,0x0
    800029e8:	90a080e7          	jalr	-1782(ra) # 800022ee <exit>
    800029ec:	bf4d                	j	8000299e <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800029ee:	00000097          	auipc	ra,0x0
    800029f2:	ecc080e7          	jalr	-308(ra) # 800028ba <devintr>
    800029f6:	892a                	mv	s2,a0
    800029f8:	c501                	beqz	a0,80002a00 <usertrap+0xa4>
  if(p->killed)
    800029fa:	549c                	lw	a5,40(s1)
    800029fc:	c3a1                	beqz	a5,80002a3c <usertrap+0xe0>
    800029fe:	a815                	j	80002a32 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a00:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a04:	5890                	lw	a2,48(s1)
    80002a06:	00006517          	auipc	a0,0x6
    80002a0a:	93250513          	addi	a0,a0,-1742 # 80008338 <states.0+0x78>
    80002a0e:	ffffe097          	auipc	ra,0xffffe
    80002a12:	b76080e7          	jalr	-1162(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a16:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a1a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a1e:	00006517          	auipc	a0,0x6
    80002a22:	94a50513          	addi	a0,a0,-1718 # 80008368 <states.0+0xa8>
    80002a26:	ffffe097          	auipc	ra,0xffffe
    80002a2a:	b5e080e7          	jalr	-1186(ra) # 80000584 <printf>
    p->killed = 1;
    80002a2e:	4785                	li	a5,1
    80002a30:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002a32:	557d                	li	a0,-1
    80002a34:	00000097          	auipc	ra,0x0
    80002a38:	8ba080e7          	jalr	-1862(ra) # 800022ee <exit>
  if(which_dev == 2)
    80002a3c:	4789                	li	a5,2
    80002a3e:	f8f910e3          	bne	s2,a5,800029be <usertrap+0x62>
    yield();
    80002a42:	fffff097          	auipc	ra,0xfffff
    80002a46:	614080e7          	jalr	1556(ra) # 80002056 <yield>
    80002a4a:	bf95                	j	800029be <usertrap+0x62>
  int which_dev = 0;
    80002a4c:	4901                	li	s2,0
    80002a4e:	b7d5                	j	80002a32 <usertrap+0xd6>

0000000080002a50 <kerneltrap>:
{
    80002a50:	7179                	addi	sp,sp,-48
    80002a52:	f406                	sd	ra,40(sp)
    80002a54:	f022                	sd	s0,32(sp)
    80002a56:	ec26                	sd	s1,24(sp)
    80002a58:	e84a                	sd	s2,16(sp)
    80002a5a:	e44e                	sd	s3,8(sp)
    80002a5c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a5e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a62:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a66:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a6a:	1004f793          	andi	a5,s1,256
    80002a6e:	cb85                	beqz	a5,80002a9e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a70:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a74:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a76:	ef85                	bnez	a5,80002aae <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a78:	00000097          	auipc	ra,0x0
    80002a7c:	e42080e7          	jalr	-446(ra) # 800028ba <devintr>
    80002a80:	cd1d                	beqz	a0,80002abe <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a82:	4789                	li	a5,2
    80002a84:	06f50a63          	beq	a0,a5,80002af8 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a88:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a8c:	10049073          	csrw	sstatus,s1
}
    80002a90:	70a2                	ld	ra,40(sp)
    80002a92:	7402                	ld	s0,32(sp)
    80002a94:	64e2                	ld	s1,24(sp)
    80002a96:	6942                	ld	s2,16(sp)
    80002a98:	69a2                	ld	s3,8(sp)
    80002a9a:	6145                	addi	sp,sp,48
    80002a9c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a9e:	00006517          	auipc	a0,0x6
    80002aa2:	8ea50513          	addi	a0,a0,-1814 # 80008388 <states.0+0xc8>
    80002aa6:	ffffe097          	auipc	ra,0xffffe
    80002aaa:	a94080e7          	jalr	-1388(ra) # 8000053a <panic>
    panic("kerneltrap: interrupts enabled");
    80002aae:	00006517          	auipc	a0,0x6
    80002ab2:	90250513          	addi	a0,a0,-1790 # 800083b0 <states.0+0xf0>
    80002ab6:	ffffe097          	auipc	ra,0xffffe
    80002aba:	a84080e7          	jalr	-1404(ra) # 8000053a <panic>
    printf("scause %p\n", scause);
    80002abe:	85ce                	mv	a1,s3
    80002ac0:	00006517          	auipc	a0,0x6
    80002ac4:	91050513          	addi	a0,a0,-1776 # 800083d0 <states.0+0x110>
    80002ac8:	ffffe097          	auipc	ra,0xffffe
    80002acc:	abc080e7          	jalr	-1348(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ad0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ad4:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ad8:	00006517          	auipc	a0,0x6
    80002adc:	90850513          	addi	a0,a0,-1784 # 800083e0 <states.0+0x120>
    80002ae0:	ffffe097          	auipc	ra,0xffffe
    80002ae4:	aa4080e7          	jalr	-1372(ra) # 80000584 <printf>
    panic("kerneltrap");
    80002ae8:	00006517          	auipc	a0,0x6
    80002aec:	91050513          	addi	a0,a0,-1776 # 800083f8 <states.0+0x138>
    80002af0:	ffffe097          	auipc	ra,0xffffe
    80002af4:	a4a080e7          	jalr	-1462(ra) # 8000053a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002af8:	fffff097          	auipc	ra,0xfffff
    80002afc:	e9e080e7          	jalr	-354(ra) # 80001996 <myproc>
    80002b00:	d541                	beqz	a0,80002a88 <kerneltrap+0x38>
    80002b02:	fffff097          	auipc	ra,0xfffff
    80002b06:	e94080e7          	jalr	-364(ra) # 80001996 <myproc>
    80002b0a:	4d18                	lw	a4,24(a0)
    80002b0c:	4791                	li	a5,4
    80002b0e:	f6f71de3          	bne	a4,a5,80002a88 <kerneltrap+0x38>
    yield();
    80002b12:	fffff097          	auipc	ra,0xfffff
    80002b16:	544080e7          	jalr	1348(ra) # 80002056 <yield>
    80002b1a:	b7bd                	j	80002a88 <kerneltrap+0x38>

0000000080002b1c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b1c:	1101                	addi	sp,sp,-32
    80002b1e:	ec06                	sd	ra,24(sp)
    80002b20:	e822                	sd	s0,16(sp)
    80002b22:	e426                	sd	s1,8(sp)
    80002b24:	1000                	addi	s0,sp,32
    80002b26:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b28:	fffff097          	auipc	ra,0xfffff
    80002b2c:	e6e080e7          	jalr	-402(ra) # 80001996 <myproc>
  switch (n) {
    80002b30:	4795                	li	a5,5
    80002b32:	0497e163          	bltu	a5,s1,80002b74 <argraw+0x58>
    80002b36:	048a                	slli	s1,s1,0x2
    80002b38:	00006717          	auipc	a4,0x6
    80002b3c:	8f870713          	addi	a4,a4,-1800 # 80008430 <states.0+0x170>
    80002b40:	94ba                	add	s1,s1,a4
    80002b42:	409c                	lw	a5,0(s1)
    80002b44:	97ba                	add	a5,a5,a4
    80002b46:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b48:	713c                	ld	a5,96(a0)
    80002b4a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b4c:	60e2                	ld	ra,24(sp)
    80002b4e:	6442                	ld	s0,16(sp)
    80002b50:	64a2                	ld	s1,8(sp)
    80002b52:	6105                	addi	sp,sp,32
    80002b54:	8082                	ret
    return p->trapframe->a1;
    80002b56:	713c                	ld	a5,96(a0)
    80002b58:	7fa8                	ld	a0,120(a5)
    80002b5a:	bfcd                	j	80002b4c <argraw+0x30>
    return p->trapframe->a2;
    80002b5c:	713c                	ld	a5,96(a0)
    80002b5e:	63c8                	ld	a0,128(a5)
    80002b60:	b7f5                	j	80002b4c <argraw+0x30>
    return p->trapframe->a3;
    80002b62:	713c                	ld	a5,96(a0)
    80002b64:	67c8                	ld	a0,136(a5)
    80002b66:	b7dd                	j	80002b4c <argraw+0x30>
    return p->trapframe->a4;
    80002b68:	713c                	ld	a5,96(a0)
    80002b6a:	6bc8                	ld	a0,144(a5)
    80002b6c:	b7c5                	j	80002b4c <argraw+0x30>
    return p->trapframe->a5;
    80002b6e:	713c                	ld	a5,96(a0)
    80002b70:	6fc8                	ld	a0,152(a5)
    80002b72:	bfe9                	j	80002b4c <argraw+0x30>
  panic("argraw");
    80002b74:	00006517          	auipc	a0,0x6
    80002b78:	89450513          	addi	a0,a0,-1900 # 80008408 <states.0+0x148>
    80002b7c:	ffffe097          	auipc	ra,0xffffe
    80002b80:	9be080e7          	jalr	-1602(ra) # 8000053a <panic>

0000000080002b84 <fetchaddr>:
{
    80002b84:	1101                	addi	sp,sp,-32
    80002b86:	ec06                	sd	ra,24(sp)
    80002b88:	e822                	sd	s0,16(sp)
    80002b8a:	e426                	sd	s1,8(sp)
    80002b8c:	e04a                	sd	s2,0(sp)
    80002b8e:	1000                	addi	s0,sp,32
    80002b90:	84aa                	mv	s1,a0
    80002b92:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b94:	fffff097          	auipc	ra,0xfffff
    80002b98:	e02080e7          	jalr	-510(ra) # 80001996 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002b9c:	693c                	ld	a5,80(a0)
    80002b9e:	02f4f863          	bgeu	s1,a5,80002bce <fetchaddr+0x4a>
    80002ba2:	00848713          	addi	a4,s1,8
    80002ba6:	02e7e663          	bltu	a5,a4,80002bd2 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002baa:	46a1                	li	a3,8
    80002bac:	8626                	mv	a2,s1
    80002bae:	85ca                	mv	a1,s2
    80002bb0:	6d28                	ld	a0,88(a0)
    80002bb2:	fffff097          	auipc	ra,0xfffff
    80002bb6:	b34080e7          	jalr	-1228(ra) # 800016e6 <copyin>
    80002bba:	00a03533          	snez	a0,a0
    80002bbe:	40a00533          	neg	a0,a0
}
    80002bc2:	60e2                	ld	ra,24(sp)
    80002bc4:	6442                	ld	s0,16(sp)
    80002bc6:	64a2                	ld	s1,8(sp)
    80002bc8:	6902                	ld	s2,0(sp)
    80002bca:	6105                	addi	sp,sp,32
    80002bcc:	8082                	ret
    return -1;
    80002bce:	557d                	li	a0,-1
    80002bd0:	bfcd                	j	80002bc2 <fetchaddr+0x3e>
    80002bd2:	557d                	li	a0,-1
    80002bd4:	b7fd                	j	80002bc2 <fetchaddr+0x3e>

0000000080002bd6 <fetchstr>:
{
    80002bd6:	7179                	addi	sp,sp,-48
    80002bd8:	f406                	sd	ra,40(sp)
    80002bda:	f022                	sd	s0,32(sp)
    80002bdc:	ec26                	sd	s1,24(sp)
    80002bde:	e84a                	sd	s2,16(sp)
    80002be0:	e44e                	sd	s3,8(sp)
    80002be2:	1800                	addi	s0,sp,48
    80002be4:	892a                	mv	s2,a0
    80002be6:	84ae                	mv	s1,a1
    80002be8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bea:	fffff097          	auipc	ra,0xfffff
    80002bee:	dac080e7          	jalr	-596(ra) # 80001996 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002bf2:	86ce                	mv	a3,s3
    80002bf4:	864a                	mv	a2,s2
    80002bf6:	85a6                	mv	a1,s1
    80002bf8:	6d28                	ld	a0,88(a0)
    80002bfa:	fffff097          	auipc	ra,0xfffff
    80002bfe:	b7a080e7          	jalr	-1158(ra) # 80001774 <copyinstr>
  if(err < 0)
    80002c02:	00054763          	bltz	a0,80002c10 <fetchstr+0x3a>
  return strlen(buf);
    80002c06:	8526                	mv	a0,s1
    80002c08:	ffffe097          	auipc	ra,0xffffe
    80002c0c:	240080e7          	jalr	576(ra) # 80000e48 <strlen>
}
    80002c10:	70a2                	ld	ra,40(sp)
    80002c12:	7402                	ld	s0,32(sp)
    80002c14:	64e2                	ld	s1,24(sp)
    80002c16:	6942                	ld	s2,16(sp)
    80002c18:	69a2                	ld	s3,8(sp)
    80002c1a:	6145                	addi	sp,sp,48
    80002c1c:	8082                	ret

0000000080002c1e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002c1e:	1101                	addi	sp,sp,-32
    80002c20:	ec06                	sd	ra,24(sp)
    80002c22:	e822                	sd	s0,16(sp)
    80002c24:	e426                	sd	s1,8(sp)
    80002c26:	1000                	addi	s0,sp,32
    80002c28:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c2a:	00000097          	auipc	ra,0x0
    80002c2e:	ef2080e7          	jalr	-270(ra) # 80002b1c <argraw>
    80002c32:	c088                	sw	a0,0(s1)
  return 0;
}
    80002c34:	4501                	li	a0,0
    80002c36:	60e2                	ld	ra,24(sp)
    80002c38:	6442                	ld	s0,16(sp)
    80002c3a:	64a2                	ld	s1,8(sp)
    80002c3c:	6105                	addi	sp,sp,32
    80002c3e:	8082                	ret

0000000080002c40 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002c40:	1101                	addi	sp,sp,-32
    80002c42:	ec06                	sd	ra,24(sp)
    80002c44:	e822                	sd	s0,16(sp)
    80002c46:	e426                	sd	s1,8(sp)
    80002c48:	1000                	addi	s0,sp,32
    80002c4a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c4c:	00000097          	auipc	ra,0x0
    80002c50:	ed0080e7          	jalr	-304(ra) # 80002b1c <argraw>
    80002c54:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c56:	4501                	li	a0,0
    80002c58:	60e2                	ld	ra,24(sp)
    80002c5a:	6442                	ld	s0,16(sp)
    80002c5c:	64a2                	ld	s1,8(sp)
    80002c5e:	6105                	addi	sp,sp,32
    80002c60:	8082                	ret

0000000080002c62 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c62:	1101                	addi	sp,sp,-32
    80002c64:	ec06                	sd	ra,24(sp)
    80002c66:	e822                	sd	s0,16(sp)
    80002c68:	e426                	sd	s1,8(sp)
    80002c6a:	e04a                	sd	s2,0(sp)
    80002c6c:	1000                	addi	s0,sp,32
    80002c6e:	84ae                	mv	s1,a1
    80002c70:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c72:	00000097          	auipc	ra,0x0
    80002c76:	eaa080e7          	jalr	-342(ra) # 80002b1c <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c7a:	864a                	mv	a2,s2
    80002c7c:	85a6                	mv	a1,s1
    80002c7e:	00000097          	auipc	ra,0x0
    80002c82:	f58080e7          	jalr	-168(ra) # 80002bd6 <fetchstr>
}
    80002c86:	60e2                	ld	ra,24(sp)
    80002c88:	6442                	ld	s0,16(sp)
    80002c8a:	64a2                	ld	s1,8(sp)
    80002c8c:	6902                	ld	s2,0(sp)
    80002c8e:	6105                	addi	sp,sp,32
    80002c90:	8082                	ret

0000000080002c92 <syscall>:
[SYS_waitstat] sys_waitstat,
};

void
syscall(void)
{
    80002c92:	1101                	addi	sp,sp,-32
    80002c94:	ec06                	sd	ra,24(sp)
    80002c96:	e822                	sd	s0,16(sp)
    80002c98:	e426                	sd	s1,8(sp)
    80002c9a:	e04a                	sd	s2,0(sp)
    80002c9c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	cf8080e7          	jalr	-776(ra) # 80001996 <myproc>
    80002ca6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ca8:	06053903          	ld	s2,96(a0)
    80002cac:	0a893783          	ld	a5,168(s2)
    80002cb0:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002cb4:	37fd                	addiw	a5,a5,-1
    80002cb6:	4755                	li	a4,21
    80002cb8:	00f76f63          	bltu	a4,a5,80002cd6 <syscall+0x44>
    80002cbc:	00369713          	slli	a4,a3,0x3
    80002cc0:	00005797          	auipc	a5,0x5
    80002cc4:	78878793          	addi	a5,a5,1928 # 80008448 <syscalls>
    80002cc8:	97ba                	add	a5,a5,a4
    80002cca:	639c                	ld	a5,0(a5)
    80002ccc:	c789                	beqz	a5,80002cd6 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002cce:	9782                	jalr	a5
    80002cd0:	06a93823          	sd	a0,112(s2)
    80002cd4:	a839                	j	80002cf2 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002cd6:	16048613          	addi	a2,s1,352
    80002cda:	588c                	lw	a1,48(s1)
    80002cdc:	00005517          	auipc	a0,0x5
    80002ce0:	73450513          	addi	a0,a0,1844 # 80008410 <states.0+0x150>
    80002ce4:	ffffe097          	auipc	ra,0xffffe
    80002ce8:	8a0080e7          	jalr	-1888(ra) # 80000584 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002cec:	70bc                	ld	a5,96(s1)
    80002cee:	577d                	li	a4,-1
    80002cf0:	fbb8                	sd	a4,112(a5)
  }
}
    80002cf2:	60e2                	ld	ra,24(sp)
    80002cf4:	6442                	ld	s0,16(sp)
    80002cf6:	64a2                	ld	s1,8(sp)
    80002cf8:	6902                	ld	s2,0(sp)
    80002cfa:	6105                	addi	sp,sp,32
    80002cfc:	8082                	ret

0000000080002cfe <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cfe:	1101                	addi	sp,sp,-32
    80002d00:	ec06                	sd	ra,24(sp)
    80002d02:	e822                	sd	s0,16(sp)
    80002d04:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002d06:	fec40593          	addi	a1,s0,-20
    80002d0a:	4501                	li	a0,0
    80002d0c:	00000097          	auipc	ra,0x0
    80002d10:	f12080e7          	jalr	-238(ra) # 80002c1e <argint>
    return -1;
    80002d14:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d16:	00054963          	bltz	a0,80002d28 <sys_exit+0x2a>
  exit(n);
    80002d1a:	fec42503          	lw	a0,-20(s0)
    80002d1e:	fffff097          	auipc	ra,0xfffff
    80002d22:	5d0080e7          	jalr	1488(ra) # 800022ee <exit>
  return 0;  // not reached
    80002d26:	4781                	li	a5,0
}
    80002d28:	853e                	mv	a0,a5
    80002d2a:	60e2                	ld	ra,24(sp)
    80002d2c:	6442                	ld	s0,16(sp)
    80002d2e:	6105                	addi	sp,sp,32
    80002d30:	8082                	ret

0000000080002d32 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d32:	1141                	addi	sp,sp,-16
    80002d34:	e406                	sd	ra,8(sp)
    80002d36:	e022                	sd	s0,0(sp)
    80002d38:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d3a:	fffff097          	auipc	ra,0xfffff
    80002d3e:	c5c080e7          	jalr	-932(ra) # 80001996 <myproc>
}
    80002d42:	5908                	lw	a0,48(a0)
    80002d44:	60a2                	ld	ra,8(sp)
    80002d46:	6402                	ld	s0,0(sp)
    80002d48:	0141                	addi	sp,sp,16
    80002d4a:	8082                	ret

0000000080002d4c <sys_fork>:

uint64
sys_fork(void)
{
    80002d4c:	1141                	addi	sp,sp,-16
    80002d4e:	e406                	sd	ra,8(sp)
    80002d50:	e022                	sd	s0,0(sp)
    80002d52:	0800                	addi	s0,sp,16
  return fork();
    80002d54:	fffff097          	auipc	ra,0xfffff
    80002d58:	042080e7          	jalr	66(ra) # 80001d96 <fork>
}
    80002d5c:	60a2                	ld	ra,8(sp)
    80002d5e:	6402                	ld	s0,0(sp)
    80002d60:	0141                	addi	sp,sp,16
    80002d62:	8082                	ret

0000000080002d64 <sys_wait>:

uint64
sys_wait(void)
{
    80002d64:	1101                	addi	sp,sp,-32
    80002d66:	ec06                	sd	ra,24(sp)
    80002d68:	e822                	sd	s0,16(sp)
    80002d6a:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d6c:	fe840593          	addi	a1,s0,-24
    80002d70:	4501                	li	a0,0
    80002d72:	00000097          	auipc	ra,0x0
    80002d76:	ece080e7          	jalr	-306(ra) # 80002c40 <argaddr>
    80002d7a:	87aa                	mv	a5,a0
    return -1;
    80002d7c:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002d7e:	0007c863          	bltz	a5,80002d8e <sys_wait+0x2a>
  return wait(p);
    80002d82:	fe843503          	ld	a0,-24(s0)
    80002d86:	fffff097          	auipc	ra,0xfffff
    80002d8a:	370080e7          	jalr	880(ra) # 800020f6 <wait>
}
    80002d8e:	60e2                	ld	ra,24(sp)
    80002d90:	6442                	ld	s0,16(sp)
    80002d92:	6105                	addi	sp,sp,32
    80002d94:	8082                	ret

0000000080002d96 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d96:	7179                	addi	sp,sp,-48
    80002d98:	f406                	sd	ra,40(sp)
    80002d9a:	f022                	sd	s0,32(sp)
    80002d9c:	ec26                	sd	s1,24(sp)
    80002d9e:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002da0:	fdc40593          	addi	a1,s0,-36
    80002da4:	4501                	li	a0,0
    80002da6:	00000097          	auipc	ra,0x0
    80002daa:	e78080e7          	jalr	-392(ra) # 80002c1e <argint>
    80002dae:	87aa                	mv	a5,a0
    return -1;
    80002db0:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002db2:	0207c063          	bltz	a5,80002dd2 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002db6:	fffff097          	auipc	ra,0xfffff
    80002dba:	be0080e7          	jalr	-1056(ra) # 80001996 <myproc>
    80002dbe:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002dc0:	fdc42503          	lw	a0,-36(s0)
    80002dc4:	fffff097          	auipc	ra,0xfffff
    80002dc8:	f5a080e7          	jalr	-166(ra) # 80001d1e <growproc>
    80002dcc:	00054863          	bltz	a0,80002ddc <sys_sbrk+0x46>
    return -1;
  return addr;
    80002dd0:	8526                	mv	a0,s1
}
    80002dd2:	70a2                	ld	ra,40(sp)
    80002dd4:	7402                	ld	s0,32(sp)
    80002dd6:	64e2                	ld	s1,24(sp)
    80002dd8:	6145                	addi	sp,sp,48
    80002dda:	8082                	ret
    return -1;
    80002ddc:	557d                	li	a0,-1
    80002dde:	bfd5                	j	80002dd2 <sys_sbrk+0x3c>

0000000080002de0 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002de0:	7139                	addi	sp,sp,-64
    80002de2:	fc06                	sd	ra,56(sp)
    80002de4:	f822                	sd	s0,48(sp)
    80002de6:	f426                	sd	s1,40(sp)
    80002de8:	f04a                	sd	s2,32(sp)
    80002dea:	ec4e                	sd	s3,24(sp)
    80002dec:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002dee:	fcc40593          	addi	a1,s0,-52
    80002df2:	4501                	li	a0,0
    80002df4:	00000097          	auipc	ra,0x0
    80002df8:	e2a080e7          	jalr	-470(ra) # 80002c1e <argint>
    return -1;
    80002dfc:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002dfe:	06054563          	bltz	a0,80002e68 <sys_sleep+0x88>
  acquire(&tickslock);
    80002e02:	00014517          	auipc	a0,0x14
    80002e06:	6ce50513          	addi	a0,a0,1742 # 800174d0 <tickslock>
    80002e0a:	ffffe097          	auipc	ra,0xffffe
    80002e0e:	dc6080e7          	jalr	-570(ra) # 80000bd0 <acquire>
  ticks0 = ticks;
    80002e12:	00006917          	auipc	s2,0x6
    80002e16:	21e92903          	lw	s2,542(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002e1a:	fcc42783          	lw	a5,-52(s0)
    80002e1e:	cf85                	beqz	a5,80002e56 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e20:	00014997          	auipc	s3,0x14
    80002e24:	6b098993          	addi	s3,s3,1712 # 800174d0 <tickslock>
    80002e28:	00006497          	auipc	s1,0x6
    80002e2c:	20848493          	addi	s1,s1,520 # 80009030 <ticks>
    if(myproc()->killed){
    80002e30:	fffff097          	auipc	ra,0xfffff
    80002e34:	b66080e7          	jalr	-1178(ra) # 80001996 <myproc>
    80002e38:	551c                	lw	a5,40(a0)
    80002e3a:	ef9d                	bnez	a5,80002e78 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002e3c:	85ce                	mv	a1,s3
    80002e3e:	8526                	mv	a0,s1
    80002e40:	fffff097          	auipc	ra,0xfffff
    80002e44:	252080e7          	jalr	594(ra) # 80002092 <sleep>
  while(ticks - ticks0 < n){
    80002e48:	409c                	lw	a5,0(s1)
    80002e4a:	412787bb          	subw	a5,a5,s2
    80002e4e:	fcc42703          	lw	a4,-52(s0)
    80002e52:	fce7efe3          	bltu	a5,a4,80002e30 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002e56:	00014517          	auipc	a0,0x14
    80002e5a:	67a50513          	addi	a0,a0,1658 # 800174d0 <tickslock>
    80002e5e:	ffffe097          	auipc	ra,0xffffe
    80002e62:	e26080e7          	jalr	-474(ra) # 80000c84 <release>
  return 0;
    80002e66:	4781                	li	a5,0
}
    80002e68:	853e                	mv	a0,a5
    80002e6a:	70e2                	ld	ra,56(sp)
    80002e6c:	7442                	ld	s0,48(sp)
    80002e6e:	74a2                	ld	s1,40(sp)
    80002e70:	7902                	ld	s2,32(sp)
    80002e72:	69e2                	ld	s3,24(sp)
    80002e74:	6121                	addi	sp,sp,64
    80002e76:	8082                	ret
      release(&tickslock);
    80002e78:	00014517          	auipc	a0,0x14
    80002e7c:	65850513          	addi	a0,a0,1624 # 800174d0 <tickslock>
    80002e80:	ffffe097          	auipc	ra,0xffffe
    80002e84:	e04080e7          	jalr	-508(ra) # 80000c84 <release>
      return -1;
    80002e88:	57fd                	li	a5,-1
    80002e8a:	bff9                	j	80002e68 <sys_sleep+0x88>

0000000080002e8c <sys_kill>:

uint64
sys_kill(void)
{
    80002e8c:	1101                	addi	sp,sp,-32
    80002e8e:	ec06                	sd	ra,24(sp)
    80002e90:	e822                	sd	s0,16(sp)
    80002e92:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002e94:	fec40593          	addi	a1,s0,-20
    80002e98:	4501                	li	a0,0
    80002e9a:	00000097          	auipc	ra,0x0
    80002e9e:	d84080e7          	jalr	-636(ra) # 80002c1e <argint>
    80002ea2:	87aa                	mv	a5,a0
    return -1;
    80002ea4:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002ea6:	0007c863          	bltz	a5,80002eb6 <sys_kill+0x2a>
  return kill(pid);
    80002eaa:	fec42503          	lw	a0,-20(s0)
    80002eae:	fffff097          	auipc	ra,0xfffff
    80002eb2:	542080e7          	jalr	1346(ra) # 800023f0 <kill>
}
    80002eb6:	60e2                	ld	ra,24(sp)
    80002eb8:	6442                	ld	s0,16(sp)
    80002eba:	6105                	addi	sp,sp,32
    80002ebc:	8082                	ret

0000000080002ebe <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ebe:	1101                	addi	sp,sp,-32
    80002ec0:	ec06                	sd	ra,24(sp)
    80002ec2:	e822                	sd	s0,16(sp)
    80002ec4:	e426                	sd	s1,8(sp)
    80002ec6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ec8:	00014517          	auipc	a0,0x14
    80002ecc:	60850513          	addi	a0,a0,1544 # 800174d0 <tickslock>
    80002ed0:	ffffe097          	auipc	ra,0xffffe
    80002ed4:	d00080e7          	jalr	-768(ra) # 80000bd0 <acquire>
  xticks = ticks;
    80002ed8:	00006497          	auipc	s1,0x6
    80002edc:	1584a483          	lw	s1,344(s1) # 80009030 <ticks>
  release(&tickslock);
    80002ee0:	00014517          	auipc	a0,0x14
    80002ee4:	5f050513          	addi	a0,a0,1520 # 800174d0 <tickslock>
    80002ee8:	ffffe097          	auipc	ra,0xffffe
    80002eec:	d9c080e7          	jalr	-612(ra) # 80000c84 <release>
  return xticks;
}
    80002ef0:	02049513          	slli	a0,s1,0x20
    80002ef4:	9101                	srli	a0,a0,0x20
    80002ef6:	60e2                	ld	ra,24(sp)
    80002ef8:	6442                	ld	s0,16(sp)
    80002efa:	64a2                	ld	s1,8(sp)
    80002efc:	6105                	addi	sp,sp,32
    80002efe:	8082                	ret

0000000080002f00 <sys_waitstat>:


uint64
sys_waitstat(void){
    80002f00:	7179                	addi	sp,sp,-48
    80002f02:	f406                	sd	ra,40(sp)
    80002f04:	f022                	sd	s0,32(sp)
    80002f06:	1800                	addi	s0,sp,48
  

 // printf("reached waitsys TT: %d", *turnaroundTime);
  
  
  if(argaddr(0, &p) < 0)
    80002f08:	fe840593          	addi	a1,s0,-24
    80002f0c:	4501                	li	a0,0
    80002f0e:	00000097          	auipc	ra,0x0
    80002f12:	d32080e7          	jalr	-718(ra) # 80002c40 <argaddr>
    return -1;
    80002f16:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    80002f18:	04054163          	bltz	a0,80002f5a <sys_waitstat+0x5a>
  // printf("A\n");
  if(argaddr(1,&turnaroundTime)<0)
    80002f1c:	fe040593          	addi	a1,s0,-32
    80002f20:	4505                	li	a0,1
    80002f22:	00000097          	auipc	ra,0x0
    80002f26:	d1e080e7          	jalr	-738(ra) # 80002c40 <argaddr>
     return -1;
    80002f2a:	57fd                	li	a5,-1
  if(argaddr(1,&turnaroundTime)<0)
    80002f2c:	02054763          	bltz	a0,80002f5a <sys_waitstat+0x5a>
  // printf("B\n");
  if(argaddr(2,&runningTime)<0)
    80002f30:	fd840593          	addi	a1,s0,-40
    80002f34:	4509                	li	a0,2
    80002f36:	00000097          	auipc	ra,0x0
    80002f3a:	d0a080e7          	jalr	-758(ra) # 80002c40 <argaddr>
     return -1;
    80002f3e:	57fd                	li	a5,-1
  if(argaddr(2,&runningTime)<0)
    80002f40:	00054d63          	bltz	a0,80002f5a <sys_waitstat+0x5a>
  // printf("C\n");
  return waitstat(p,turnaroundTime,runningTime);
    80002f44:	fd843603          	ld	a2,-40(s0)
    80002f48:	fe043583          	ld	a1,-32(s0)
    80002f4c:	fe843503          	ld	a0,-24(s0)
    80002f50:	fffff097          	auipc	ra,0xfffff
    80002f54:	66e080e7          	jalr	1646(ra) # 800025be <waitstat>
    80002f58:	87aa                	mv	a5,a0
  // return 33;

}
    80002f5a:	853e                	mv	a0,a5
    80002f5c:	70a2                	ld	ra,40(sp)
    80002f5e:	7402                	ld	s0,32(sp)
    80002f60:	6145                	addi	sp,sp,48
    80002f62:	8082                	ret

0000000080002f64 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f64:	7179                	addi	sp,sp,-48
    80002f66:	f406                	sd	ra,40(sp)
    80002f68:	f022                	sd	s0,32(sp)
    80002f6a:	ec26                	sd	s1,24(sp)
    80002f6c:	e84a                	sd	s2,16(sp)
    80002f6e:	e44e                	sd	s3,8(sp)
    80002f70:	e052                	sd	s4,0(sp)
    80002f72:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f74:	00005597          	auipc	a1,0x5
    80002f78:	58c58593          	addi	a1,a1,1420 # 80008500 <syscalls+0xb8>
    80002f7c:	00014517          	auipc	a0,0x14
    80002f80:	56c50513          	addi	a0,a0,1388 # 800174e8 <bcache>
    80002f84:	ffffe097          	auipc	ra,0xffffe
    80002f88:	bbc080e7          	jalr	-1092(ra) # 80000b40 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f8c:	0001c797          	auipc	a5,0x1c
    80002f90:	55c78793          	addi	a5,a5,1372 # 8001f4e8 <bcache+0x8000>
    80002f94:	0001c717          	auipc	a4,0x1c
    80002f98:	7bc70713          	addi	a4,a4,1980 # 8001f750 <bcache+0x8268>
    80002f9c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002fa0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fa4:	00014497          	auipc	s1,0x14
    80002fa8:	55c48493          	addi	s1,s1,1372 # 80017500 <bcache+0x18>
    b->next = bcache.head.next;
    80002fac:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002fae:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002fb0:	00005a17          	auipc	s4,0x5
    80002fb4:	558a0a13          	addi	s4,s4,1368 # 80008508 <syscalls+0xc0>
    b->next = bcache.head.next;
    80002fb8:	2b893783          	ld	a5,696(s2)
    80002fbc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002fbe:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002fc2:	85d2                	mv	a1,s4
    80002fc4:	01048513          	addi	a0,s1,16
    80002fc8:	00001097          	auipc	ra,0x1
    80002fcc:	4c2080e7          	jalr	1218(ra) # 8000448a <initsleeplock>
    bcache.head.next->prev = b;
    80002fd0:	2b893783          	ld	a5,696(s2)
    80002fd4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002fd6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fda:	45848493          	addi	s1,s1,1112
    80002fde:	fd349de3          	bne	s1,s3,80002fb8 <binit+0x54>
  }
}
    80002fe2:	70a2                	ld	ra,40(sp)
    80002fe4:	7402                	ld	s0,32(sp)
    80002fe6:	64e2                	ld	s1,24(sp)
    80002fe8:	6942                	ld	s2,16(sp)
    80002fea:	69a2                	ld	s3,8(sp)
    80002fec:	6a02                	ld	s4,0(sp)
    80002fee:	6145                	addi	sp,sp,48
    80002ff0:	8082                	ret

0000000080002ff2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ff2:	7179                	addi	sp,sp,-48
    80002ff4:	f406                	sd	ra,40(sp)
    80002ff6:	f022                	sd	s0,32(sp)
    80002ff8:	ec26                	sd	s1,24(sp)
    80002ffa:	e84a                	sd	s2,16(sp)
    80002ffc:	e44e                	sd	s3,8(sp)
    80002ffe:	1800                	addi	s0,sp,48
    80003000:	892a                	mv	s2,a0
    80003002:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003004:	00014517          	auipc	a0,0x14
    80003008:	4e450513          	addi	a0,a0,1252 # 800174e8 <bcache>
    8000300c:	ffffe097          	auipc	ra,0xffffe
    80003010:	bc4080e7          	jalr	-1084(ra) # 80000bd0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003014:	0001c497          	auipc	s1,0x1c
    80003018:	78c4b483          	ld	s1,1932(s1) # 8001f7a0 <bcache+0x82b8>
    8000301c:	0001c797          	auipc	a5,0x1c
    80003020:	73478793          	addi	a5,a5,1844 # 8001f750 <bcache+0x8268>
    80003024:	02f48f63          	beq	s1,a5,80003062 <bread+0x70>
    80003028:	873e                	mv	a4,a5
    8000302a:	a021                	j	80003032 <bread+0x40>
    8000302c:	68a4                	ld	s1,80(s1)
    8000302e:	02e48a63          	beq	s1,a4,80003062 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003032:	449c                	lw	a5,8(s1)
    80003034:	ff279ce3          	bne	a5,s2,8000302c <bread+0x3a>
    80003038:	44dc                	lw	a5,12(s1)
    8000303a:	ff3799e3          	bne	a5,s3,8000302c <bread+0x3a>
      b->refcnt++;
    8000303e:	40bc                	lw	a5,64(s1)
    80003040:	2785                	addiw	a5,a5,1
    80003042:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003044:	00014517          	auipc	a0,0x14
    80003048:	4a450513          	addi	a0,a0,1188 # 800174e8 <bcache>
    8000304c:	ffffe097          	auipc	ra,0xffffe
    80003050:	c38080e7          	jalr	-968(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80003054:	01048513          	addi	a0,s1,16
    80003058:	00001097          	auipc	ra,0x1
    8000305c:	46c080e7          	jalr	1132(ra) # 800044c4 <acquiresleep>
      return b;
    80003060:	a8b9                	j	800030be <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003062:	0001c497          	auipc	s1,0x1c
    80003066:	7364b483          	ld	s1,1846(s1) # 8001f798 <bcache+0x82b0>
    8000306a:	0001c797          	auipc	a5,0x1c
    8000306e:	6e678793          	addi	a5,a5,1766 # 8001f750 <bcache+0x8268>
    80003072:	00f48863          	beq	s1,a5,80003082 <bread+0x90>
    80003076:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003078:	40bc                	lw	a5,64(s1)
    8000307a:	cf81                	beqz	a5,80003092 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000307c:	64a4                	ld	s1,72(s1)
    8000307e:	fee49de3          	bne	s1,a4,80003078 <bread+0x86>
  panic("bget: no buffers");
    80003082:	00005517          	auipc	a0,0x5
    80003086:	48e50513          	addi	a0,a0,1166 # 80008510 <syscalls+0xc8>
    8000308a:	ffffd097          	auipc	ra,0xffffd
    8000308e:	4b0080e7          	jalr	1200(ra) # 8000053a <panic>
      b->dev = dev;
    80003092:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003096:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000309a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000309e:	4785                	li	a5,1
    800030a0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030a2:	00014517          	auipc	a0,0x14
    800030a6:	44650513          	addi	a0,a0,1094 # 800174e8 <bcache>
    800030aa:	ffffe097          	auipc	ra,0xffffe
    800030ae:	bda080e7          	jalr	-1062(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    800030b2:	01048513          	addi	a0,s1,16
    800030b6:	00001097          	auipc	ra,0x1
    800030ba:	40e080e7          	jalr	1038(ra) # 800044c4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800030be:	409c                	lw	a5,0(s1)
    800030c0:	cb89                	beqz	a5,800030d2 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800030c2:	8526                	mv	a0,s1
    800030c4:	70a2                	ld	ra,40(sp)
    800030c6:	7402                	ld	s0,32(sp)
    800030c8:	64e2                	ld	s1,24(sp)
    800030ca:	6942                	ld	s2,16(sp)
    800030cc:	69a2                	ld	s3,8(sp)
    800030ce:	6145                	addi	sp,sp,48
    800030d0:	8082                	ret
    virtio_disk_rw(b, 0);
    800030d2:	4581                	li	a1,0
    800030d4:	8526                	mv	a0,s1
    800030d6:	00003097          	auipc	ra,0x3
    800030da:	f2c080e7          	jalr	-212(ra) # 80006002 <virtio_disk_rw>
    b->valid = 1;
    800030de:	4785                	li	a5,1
    800030e0:	c09c                	sw	a5,0(s1)
  return b;
    800030e2:	b7c5                	j	800030c2 <bread+0xd0>

00000000800030e4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800030e4:	1101                	addi	sp,sp,-32
    800030e6:	ec06                	sd	ra,24(sp)
    800030e8:	e822                	sd	s0,16(sp)
    800030ea:	e426                	sd	s1,8(sp)
    800030ec:	1000                	addi	s0,sp,32
    800030ee:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030f0:	0541                	addi	a0,a0,16
    800030f2:	00001097          	auipc	ra,0x1
    800030f6:	46c080e7          	jalr	1132(ra) # 8000455e <holdingsleep>
    800030fa:	cd01                	beqz	a0,80003112 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800030fc:	4585                	li	a1,1
    800030fe:	8526                	mv	a0,s1
    80003100:	00003097          	auipc	ra,0x3
    80003104:	f02080e7          	jalr	-254(ra) # 80006002 <virtio_disk_rw>
}
    80003108:	60e2                	ld	ra,24(sp)
    8000310a:	6442                	ld	s0,16(sp)
    8000310c:	64a2                	ld	s1,8(sp)
    8000310e:	6105                	addi	sp,sp,32
    80003110:	8082                	ret
    panic("bwrite");
    80003112:	00005517          	auipc	a0,0x5
    80003116:	41650513          	addi	a0,a0,1046 # 80008528 <syscalls+0xe0>
    8000311a:	ffffd097          	auipc	ra,0xffffd
    8000311e:	420080e7          	jalr	1056(ra) # 8000053a <panic>

0000000080003122 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003122:	1101                	addi	sp,sp,-32
    80003124:	ec06                	sd	ra,24(sp)
    80003126:	e822                	sd	s0,16(sp)
    80003128:	e426                	sd	s1,8(sp)
    8000312a:	e04a                	sd	s2,0(sp)
    8000312c:	1000                	addi	s0,sp,32
    8000312e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003130:	01050913          	addi	s2,a0,16
    80003134:	854a                	mv	a0,s2
    80003136:	00001097          	auipc	ra,0x1
    8000313a:	428080e7          	jalr	1064(ra) # 8000455e <holdingsleep>
    8000313e:	c92d                	beqz	a0,800031b0 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003140:	854a                	mv	a0,s2
    80003142:	00001097          	auipc	ra,0x1
    80003146:	3d8080e7          	jalr	984(ra) # 8000451a <releasesleep>

  acquire(&bcache.lock);
    8000314a:	00014517          	auipc	a0,0x14
    8000314e:	39e50513          	addi	a0,a0,926 # 800174e8 <bcache>
    80003152:	ffffe097          	auipc	ra,0xffffe
    80003156:	a7e080e7          	jalr	-1410(ra) # 80000bd0 <acquire>
  b->refcnt--;
    8000315a:	40bc                	lw	a5,64(s1)
    8000315c:	37fd                	addiw	a5,a5,-1
    8000315e:	0007871b          	sext.w	a4,a5
    80003162:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003164:	eb05                	bnez	a4,80003194 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003166:	68bc                	ld	a5,80(s1)
    80003168:	64b8                	ld	a4,72(s1)
    8000316a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000316c:	64bc                	ld	a5,72(s1)
    8000316e:	68b8                	ld	a4,80(s1)
    80003170:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003172:	0001c797          	auipc	a5,0x1c
    80003176:	37678793          	addi	a5,a5,886 # 8001f4e8 <bcache+0x8000>
    8000317a:	2b87b703          	ld	a4,696(a5)
    8000317e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003180:	0001c717          	auipc	a4,0x1c
    80003184:	5d070713          	addi	a4,a4,1488 # 8001f750 <bcache+0x8268>
    80003188:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000318a:	2b87b703          	ld	a4,696(a5)
    8000318e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003190:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003194:	00014517          	auipc	a0,0x14
    80003198:	35450513          	addi	a0,a0,852 # 800174e8 <bcache>
    8000319c:	ffffe097          	auipc	ra,0xffffe
    800031a0:	ae8080e7          	jalr	-1304(ra) # 80000c84 <release>
}
    800031a4:	60e2                	ld	ra,24(sp)
    800031a6:	6442                	ld	s0,16(sp)
    800031a8:	64a2                	ld	s1,8(sp)
    800031aa:	6902                	ld	s2,0(sp)
    800031ac:	6105                	addi	sp,sp,32
    800031ae:	8082                	ret
    panic("brelse");
    800031b0:	00005517          	auipc	a0,0x5
    800031b4:	38050513          	addi	a0,a0,896 # 80008530 <syscalls+0xe8>
    800031b8:	ffffd097          	auipc	ra,0xffffd
    800031bc:	382080e7          	jalr	898(ra) # 8000053a <panic>

00000000800031c0 <bpin>:

void
bpin(struct buf *b) {
    800031c0:	1101                	addi	sp,sp,-32
    800031c2:	ec06                	sd	ra,24(sp)
    800031c4:	e822                	sd	s0,16(sp)
    800031c6:	e426                	sd	s1,8(sp)
    800031c8:	1000                	addi	s0,sp,32
    800031ca:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031cc:	00014517          	auipc	a0,0x14
    800031d0:	31c50513          	addi	a0,a0,796 # 800174e8 <bcache>
    800031d4:	ffffe097          	auipc	ra,0xffffe
    800031d8:	9fc080e7          	jalr	-1540(ra) # 80000bd0 <acquire>
  b->refcnt++;
    800031dc:	40bc                	lw	a5,64(s1)
    800031de:	2785                	addiw	a5,a5,1
    800031e0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031e2:	00014517          	auipc	a0,0x14
    800031e6:	30650513          	addi	a0,a0,774 # 800174e8 <bcache>
    800031ea:	ffffe097          	auipc	ra,0xffffe
    800031ee:	a9a080e7          	jalr	-1382(ra) # 80000c84 <release>
}
    800031f2:	60e2                	ld	ra,24(sp)
    800031f4:	6442                	ld	s0,16(sp)
    800031f6:	64a2                	ld	s1,8(sp)
    800031f8:	6105                	addi	sp,sp,32
    800031fa:	8082                	ret

00000000800031fc <bunpin>:

void
bunpin(struct buf *b) {
    800031fc:	1101                	addi	sp,sp,-32
    800031fe:	ec06                	sd	ra,24(sp)
    80003200:	e822                	sd	s0,16(sp)
    80003202:	e426                	sd	s1,8(sp)
    80003204:	1000                	addi	s0,sp,32
    80003206:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003208:	00014517          	auipc	a0,0x14
    8000320c:	2e050513          	addi	a0,a0,736 # 800174e8 <bcache>
    80003210:	ffffe097          	auipc	ra,0xffffe
    80003214:	9c0080e7          	jalr	-1600(ra) # 80000bd0 <acquire>
  b->refcnt--;
    80003218:	40bc                	lw	a5,64(s1)
    8000321a:	37fd                	addiw	a5,a5,-1
    8000321c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000321e:	00014517          	auipc	a0,0x14
    80003222:	2ca50513          	addi	a0,a0,714 # 800174e8 <bcache>
    80003226:	ffffe097          	auipc	ra,0xffffe
    8000322a:	a5e080e7          	jalr	-1442(ra) # 80000c84 <release>
}
    8000322e:	60e2                	ld	ra,24(sp)
    80003230:	6442                	ld	s0,16(sp)
    80003232:	64a2                	ld	s1,8(sp)
    80003234:	6105                	addi	sp,sp,32
    80003236:	8082                	ret

0000000080003238 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003238:	1101                	addi	sp,sp,-32
    8000323a:	ec06                	sd	ra,24(sp)
    8000323c:	e822                	sd	s0,16(sp)
    8000323e:	e426                	sd	s1,8(sp)
    80003240:	e04a                	sd	s2,0(sp)
    80003242:	1000                	addi	s0,sp,32
    80003244:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003246:	00d5d59b          	srliw	a1,a1,0xd
    8000324a:	0001d797          	auipc	a5,0x1d
    8000324e:	97a7a783          	lw	a5,-1670(a5) # 8001fbc4 <sb+0x1c>
    80003252:	9dbd                	addw	a1,a1,a5
    80003254:	00000097          	auipc	ra,0x0
    80003258:	d9e080e7          	jalr	-610(ra) # 80002ff2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000325c:	0074f713          	andi	a4,s1,7
    80003260:	4785                	li	a5,1
    80003262:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003266:	14ce                	slli	s1,s1,0x33
    80003268:	90d9                	srli	s1,s1,0x36
    8000326a:	00950733          	add	a4,a0,s1
    8000326e:	05874703          	lbu	a4,88(a4)
    80003272:	00e7f6b3          	and	a3,a5,a4
    80003276:	c69d                	beqz	a3,800032a4 <bfree+0x6c>
    80003278:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000327a:	94aa                	add	s1,s1,a0
    8000327c:	fff7c793          	not	a5,a5
    80003280:	8f7d                	and	a4,a4,a5
    80003282:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003286:	00001097          	auipc	ra,0x1
    8000328a:	120080e7          	jalr	288(ra) # 800043a6 <log_write>
  brelse(bp);
    8000328e:	854a                	mv	a0,s2
    80003290:	00000097          	auipc	ra,0x0
    80003294:	e92080e7          	jalr	-366(ra) # 80003122 <brelse>
}
    80003298:	60e2                	ld	ra,24(sp)
    8000329a:	6442                	ld	s0,16(sp)
    8000329c:	64a2                	ld	s1,8(sp)
    8000329e:	6902                	ld	s2,0(sp)
    800032a0:	6105                	addi	sp,sp,32
    800032a2:	8082                	ret
    panic("freeing free block");
    800032a4:	00005517          	auipc	a0,0x5
    800032a8:	29450513          	addi	a0,a0,660 # 80008538 <syscalls+0xf0>
    800032ac:	ffffd097          	auipc	ra,0xffffd
    800032b0:	28e080e7          	jalr	654(ra) # 8000053a <panic>

00000000800032b4 <balloc>:
{
    800032b4:	711d                	addi	sp,sp,-96
    800032b6:	ec86                	sd	ra,88(sp)
    800032b8:	e8a2                	sd	s0,80(sp)
    800032ba:	e4a6                	sd	s1,72(sp)
    800032bc:	e0ca                	sd	s2,64(sp)
    800032be:	fc4e                	sd	s3,56(sp)
    800032c0:	f852                	sd	s4,48(sp)
    800032c2:	f456                	sd	s5,40(sp)
    800032c4:	f05a                	sd	s6,32(sp)
    800032c6:	ec5e                	sd	s7,24(sp)
    800032c8:	e862                	sd	s8,16(sp)
    800032ca:	e466                	sd	s9,8(sp)
    800032cc:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800032ce:	0001d797          	auipc	a5,0x1d
    800032d2:	8de7a783          	lw	a5,-1826(a5) # 8001fbac <sb+0x4>
    800032d6:	cbc1                	beqz	a5,80003366 <balloc+0xb2>
    800032d8:	8baa                	mv	s7,a0
    800032da:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800032dc:	0001db17          	auipc	s6,0x1d
    800032e0:	8ccb0b13          	addi	s6,s6,-1844 # 8001fba8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032e4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800032e6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032e8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800032ea:	6c89                	lui	s9,0x2
    800032ec:	a831                	j	80003308 <balloc+0x54>
    brelse(bp);
    800032ee:	854a                	mv	a0,s2
    800032f0:	00000097          	auipc	ra,0x0
    800032f4:	e32080e7          	jalr	-462(ra) # 80003122 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032f8:	015c87bb          	addw	a5,s9,s5
    800032fc:	00078a9b          	sext.w	s5,a5
    80003300:	004b2703          	lw	a4,4(s6)
    80003304:	06eaf163          	bgeu	s5,a4,80003366 <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    80003308:	41fad79b          	sraiw	a5,s5,0x1f
    8000330c:	0137d79b          	srliw	a5,a5,0x13
    80003310:	015787bb          	addw	a5,a5,s5
    80003314:	40d7d79b          	sraiw	a5,a5,0xd
    80003318:	01cb2583          	lw	a1,28(s6)
    8000331c:	9dbd                	addw	a1,a1,a5
    8000331e:	855e                	mv	a0,s7
    80003320:	00000097          	auipc	ra,0x0
    80003324:	cd2080e7          	jalr	-814(ra) # 80002ff2 <bread>
    80003328:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000332a:	004b2503          	lw	a0,4(s6)
    8000332e:	000a849b          	sext.w	s1,s5
    80003332:	8762                	mv	a4,s8
    80003334:	faa4fde3          	bgeu	s1,a0,800032ee <balloc+0x3a>
      m = 1 << (bi % 8);
    80003338:	00777693          	andi	a3,a4,7
    8000333c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003340:	41f7579b          	sraiw	a5,a4,0x1f
    80003344:	01d7d79b          	srliw	a5,a5,0x1d
    80003348:	9fb9                	addw	a5,a5,a4
    8000334a:	4037d79b          	sraiw	a5,a5,0x3
    8000334e:	00f90633          	add	a2,s2,a5
    80003352:	05864603          	lbu	a2,88(a2)
    80003356:	00c6f5b3          	and	a1,a3,a2
    8000335a:	cd91                	beqz	a1,80003376 <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000335c:	2705                	addiw	a4,a4,1
    8000335e:	2485                	addiw	s1,s1,1
    80003360:	fd471ae3          	bne	a4,s4,80003334 <balloc+0x80>
    80003364:	b769                	j	800032ee <balloc+0x3a>
  panic("balloc: out of blocks");
    80003366:	00005517          	auipc	a0,0x5
    8000336a:	1ea50513          	addi	a0,a0,490 # 80008550 <syscalls+0x108>
    8000336e:	ffffd097          	auipc	ra,0xffffd
    80003372:	1cc080e7          	jalr	460(ra) # 8000053a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003376:	97ca                	add	a5,a5,s2
    80003378:	8e55                	or	a2,a2,a3
    8000337a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000337e:	854a                	mv	a0,s2
    80003380:	00001097          	auipc	ra,0x1
    80003384:	026080e7          	jalr	38(ra) # 800043a6 <log_write>
        brelse(bp);
    80003388:	854a                	mv	a0,s2
    8000338a:	00000097          	auipc	ra,0x0
    8000338e:	d98080e7          	jalr	-616(ra) # 80003122 <brelse>
  bp = bread(dev, bno);
    80003392:	85a6                	mv	a1,s1
    80003394:	855e                	mv	a0,s7
    80003396:	00000097          	auipc	ra,0x0
    8000339a:	c5c080e7          	jalr	-932(ra) # 80002ff2 <bread>
    8000339e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800033a0:	40000613          	li	a2,1024
    800033a4:	4581                	li	a1,0
    800033a6:	05850513          	addi	a0,a0,88
    800033aa:	ffffe097          	auipc	ra,0xffffe
    800033ae:	922080e7          	jalr	-1758(ra) # 80000ccc <memset>
  log_write(bp);
    800033b2:	854a                	mv	a0,s2
    800033b4:	00001097          	auipc	ra,0x1
    800033b8:	ff2080e7          	jalr	-14(ra) # 800043a6 <log_write>
  brelse(bp);
    800033bc:	854a                	mv	a0,s2
    800033be:	00000097          	auipc	ra,0x0
    800033c2:	d64080e7          	jalr	-668(ra) # 80003122 <brelse>
}
    800033c6:	8526                	mv	a0,s1
    800033c8:	60e6                	ld	ra,88(sp)
    800033ca:	6446                	ld	s0,80(sp)
    800033cc:	64a6                	ld	s1,72(sp)
    800033ce:	6906                	ld	s2,64(sp)
    800033d0:	79e2                	ld	s3,56(sp)
    800033d2:	7a42                	ld	s4,48(sp)
    800033d4:	7aa2                	ld	s5,40(sp)
    800033d6:	7b02                	ld	s6,32(sp)
    800033d8:	6be2                	ld	s7,24(sp)
    800033da:	6c42                	ld	s8,16(sp)
    800033dc:	6ca2                	ld	s9,8(sp)
    800033de:	6125                	addi	sp,sp,96
    800033e0:	8082                	ret

00000000800033e2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800033e2:	7179                	addi	sp,sp,-48
    800033e4:	f406                	sd	ra,40(sp)
    800033e6:	f022                	sd	s0,32(sp)
    800033e8:	ec26                	sd	s1,24(sp)
    800033ea:	e84a                	sd	s2,16(sp)
    800033ec:	e44e                	sd	s3,8(sp)
    800033ee:	e052                	sd	s4,0(sp)
    800033f0:	1800                	addi	s0,sp,48
    800033f2:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800033f4:	47ad                	li	a5,11
    800033f6:	04b7fe63          	bgeu	a5,a1,80003452 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800033fa:	ff45849b          	addiw	s1,a1,-12
    800033fe:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003402:	0ff00793          	li	a5,255
    80003406:	0ae7e463          	bltu	a5,a4,800034ae <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000340a:	08052583          	lw	a1,128(a0)
    8000340e:	c5b5                	beqz	a1,8000347a <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003410:	00092503          	lw	a0,0(s2)
    80003414:	00000097          	auipc	ra,0x0
    80003418:	bde080e7          	jalr	-1058(ra) # 80002ff2 <bread>
    8000341c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000341e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003422:	02049713          	slli	a4,s1,0x20
    80003426:	01e75593          	srli	a1,a4,0x1e
    8000342a:	00b784b3          	add	s1,a5,a1
    8000342e:	0004a983          	lw	s3,0(s1)
    80003432:	04098e63          	beqz	s3,8000348e <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003436:	8552                	mv	a0,s4
    80003438:	00000097          	auipc	ra,0x0
    8000343c:	cea080e7          	jalr	-790(ra) # 80003122 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003440:	854e                	mv	a0,s3
    80003442:	70a2                	ld	ra,40(sp)
    80003444:	7402                	ld	s0,32(sp)
    80003446:	64e2                	ld	s1,24(sp)
    80003448:	6942                	ld	s2,16(sp)
    8000344a:	69a2                	ld	s3,8(sp)
    8000344c:	6a02                	ld	s4,0(sp)
    8000344e:	6145                	addi	sp,sp,48
    80003450:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003452:	02059793          	slli	a5,a1,0x20
    80003456:	01e7d593          	srli	a1,a5,0x1e
    8000345a:	00b504b3          	add	s1,a0,a1
    8000345e:	0504a983          	lw	s3,80(s1)
    80003462:	fc099fe3          	bnez	s3,80003440 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003466:	4108                	lw	a0,0(a0)
    80003468:	00000097          	auipc	ra,0x0
    8000346c:	e4c080e7          	jalr	-436(ra) # 800032b4 <balloc>
    80003470:	0005099b          	sext.w	s3,a0
    80003474:	0534a823          	sw	s3,80(s1)
    80003478:	b7e1                	j	80003440 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000347a:	4108                	lw	a0,0(a0)
    8000347c:	00000097          	auipc	ra,0x0
    80003480:	e38080e7          	jalr	-456(ra) # 800032b4 <balloc>
    80003484:	0005059b          	sext.w	a1,a0
    80003488:	08b92023          	sw	a1,128(s2)
    8000348c:	b751                	j	80003410 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000348e:	00092503          	lw	a0,0(s2)
    80003492:	00000097          	auipc	ra,0x0
    80003496:	e22080e7          	jalr	-478(ra) # 800032b4 <balloc>
    8000349a:	0005099b          	sext.w	s3,a0
    8000349e:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800034a2:	8552                	mv	a0,s4
    800034a4:	00001097          	auipc	ra,0x1
    800034a8:	f02080e7          	jalr	-254(ra) # 800043a6 <log_write>
    800034ac:	b769                	j	80003436 <bmap+0x54>
  panic("bmap: out of range");
    800034ae:	00005517          	auipc	a0,0x5
    800034b2:	0ba50513          	addi	a0,a0,186 # 80008568 <syscalls+0x120>
    800034b6:	ffffd097          	auipc	ra,0xffffd
    800034ba:	084080e7          	jalr	132(ra) # 8000053a <panic>

00000000800034be <iget>:
{
    800034be:	7179                	addi	sp,sp,-48
    800034c0:	f406                	sd	ra,40(sp)
    800034c2:	f022                	sd	s0,32(sp)
    800034c4:	ec26                	sd	s1,24(sp)
    800034c6:	e84a                	sd	s2,16(sp)
    800034c8:	e44e                	sd	s3,8(sp)
    800034ca:	e052                	sd	s4,0(sp)
    800034cc:	1800                	addi	s0,sp,48
    800034ce:	89aa                	mv	s3,a0
    800034d0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800034d2:	0001c517          	auipc	a0,0x1c
    800034d6:	6f650513          	addi	a0,a0,1782 # 8001fbc8 <itable>
    800034da:	ffffd097          	auipc	ra,0xffffd
    800034de:	6f6080e7          	jalr	1782(ra) # 80000bd0 <acquire>
  empty = 0;
    800034e2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034e4:	0001c497          	auipc	s1,0x1c
    800034e8:	6fc48493          	addi	s1,s1,1788 # 8001fbe0 <itable+0x18>
    800034ec:	0001e697          	auipc	a3,0x1e
    800034f0:	18468693          	addi	a3,a3,388 # 80021670 <log>
    800034f4:	a039                	j	80003502 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034f6:	02090b63          	beqz	s2,8000352c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034fa:	08848493          	addi	s1,s1,136
    800034fe:	02d48a63          	beq	s1,a3,80003532 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003502:	449c                	lw	a5,8(s1)
    80003504:	fef059e3          	blez	a5,800034f6 <iget+0x38>
    80003508:	4098                	lw	a4,0(s1)
    8000350a:	ff3716e3          	bne	a4,s3,800034f6 <iget+0x38>
    8000350e:	40d8                	lw	a4,4(s1)
    80003510:	ff4713e3          	bne	a4,s4,800034f6 <iget+0x38>
      ip->ref++;
    80003514:	2785                	addiw	a5,a5,1
    80003516:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003518:	0001c517          	auipc	a0,0x1c
    8000351c:	6b050513          	addi	a0,a0,1712 # 8001fbc8 <itable>
    80003520:	ffffd097          	auipc	ra,0xffffd
    80003524:	764080e7          	jalr	1892(ra) # 80000c84 <release>
      return ip;
    80003528:	8926                	mv	s2,s1
    8000352a:	a03d                	j	80003558 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000352c:	f7f9                	bnez	a5,800034fa <iget+0x3c>
    8000352e:	8926                	mv	s2,s1
    80003530:	b7e9                	j	800034fa <iget+0x3c>
  if(empty == 0)
    80003532:	02090c63          	beqz	s2,8000356a <iget+0xac>
  ip->dev = dev;
    80003536:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000353a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000353e:	4785                	li	a5,1
    80003540:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003544:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003548:	0001c517          	auipc	a0,0x1c
    8000354c:	68050513          	addi	a0,a0,1664 # 8001fbc8 <itable>
    80003550:	ffffd097          	auipc	ra,0xffffd
    80003554:	734080e7          	jalr	1844(ra) # 80000c84 <release>
}
    80003558:	854a                	mv	a0,s2
    8000355a:	70a2                	ld	ra,40(sp)
    8000355c:	7402                	ld	s0,32(sp)
    8000355e:	64e2                	ld	s1,24(sp)
    80003560:	6942                	ld	s2,16(sp)
    80003562:	69a2                	ld	s3,8(sp)
    80003564:	6a02                	ld	s4,0(sp)
    80003566:	6145                	addi	sp,sp,48
    80003568:	8082                	ret
    panic("iget: no inodes");
    8000356a:	00005517          	auipc	a0,0x5
    8000356e:	01650513          	addi	a0,a0,22 # 80008580 <syscalls+0x138>
    80003572:	ffffd097          	auipc	ra,0xffffd
    80003576:	fc8080e7          	jalr	-56(ra) # 8000053a <panic>

000000008000357a <fsinit>:
fsinit(int dev) {
    8000357a:	7179                	addi	sp,sp,-48
    8000357c:	f406                	sd	ra,40(sp)
    8000357e:	f022                	sd	s0,32(sp)
    80003580:	ec26                	sd	s1,24(sp)
    80003582:	e84a                	sd	s2,16(sp)
    80003584:	e44e                	sd	s3,8(sp)
    80003586:	1800                	addi	s0,sp,48
    80003588:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000358a:	4585                	li	a1,1
    8000358c:	00000097          	auipc	ra,0x0
    80003590:	a66080e7          	jalr	-1434(ra) # 80002ff2 <bread>
    80003594:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003596:	0001c997          	auipc	s3,0x1c
    8000359a:	61298993          	addi	s3,s3,1554 # 8001fba8 <sb>
    8000359e:	02000613          	li	a2,32
    800035a2:	05850593          	addi	a1,a0,88
    800035a6:	854e                	mv	a0,s3
    800035a8:	ffffd097          	auipc	ra,0xffffd
    800035ac:	780080e7          	jalr	1920(ra) # 80000d28 <memmove>
  brelse(bp);
    800035b0:	8526                	mv	a0,s1
    800035b2:	00000097          	auipc	ra,0x0
    800035b6:	b70080e7          	jalr	-1168(ra) # 80003122 <brelse>
  if(sb.magic != FSMAGIC)
    800035ba:	0009a703          	lw	a4,0(s3)
    800035be:	102037b7          	lui	a5,0x10203
    800035c2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035c6:	02f71263          	bne	a4,a5,800035ea <fsinit+0x70>
  initlog(dev, &sb);
    800035ca:	0001c597          	auipc	a1,0x1c
    800035ce:	5de58593          	addi	a1,a1,1502 # 8001fba8 <sb>
    800035d2:	854a                	mv	a0,s2
    800035d4:	00001097          	auipc	ra,0x1
    800035d8:	b56080e7          	jalr	-1194(ra) # 8000412a <initlog>
}
    800035dc:	70a2                	ld	ra,40(sp)
    800035de:	7402                	ld	s0,32(sp)
    800035e0:	64e2                	ld	s1,24(sp)
    800035e2:	6942                	ld	s2,16(sp)
    800035e4:	69a2                	ld	s3,8(sp)
    800035e6:	6145                	addi	sp,sp,48
    800035e8:	8082                	ret
    panic("invalid file system");
    800035ea:	00005517          	auipc	a0,0x5
    800035ee:	fa650513          	addi	a0,a0,-90 # 80008590 <syscalls+0x148>
    800035f2:	ffffd097          	auipc	ra,0xffffd
    800035f6:	f48080e7          	jalr	-184(ra) # 8000053a <panic>

00000000800035fa <iinit>:
{
    800035fa:	7179                	addi	sp,sp,-48
    800035fc:	f406                	sd	ra,40(sp)
    800035fe:	f022                	sd	s0,32(sp)
    80003600:	ec26                	sd	s1,24(sp)
    80003602:	e84a                	sd	s2,16(sp)
    80003604:	e44e                	sd	s3,8(sp)
    80003606:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003608:	00005597          	auipc	a1,0x5
    8000360c:	fa058593          	addi	a1,a1,-96 # 800085a8 <syscalls+0x160>
    80003610:	0001c517          	auipc	a0,0x1c
    80003614:	5b850513          	addi	a0,a0,1464 # 8001fbc8 <itable>
    80003618:	ffffd097          	auipc	ra,0xffffd
    8000361c:	528080e7          	jalr	1320(ra) # 80000b40 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003620:	0001c497          	auipc	s1,0x1c
    80003624:	5d048493          	addi	s1,s1,1488 # 8001fbf0 <itable+0x28>
    80003628:	0001e997          	auipc	s3,0x1e
    8000362c:	05898993          	addi	s3,s3,88 # 80021680 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003630:	00005917          	auipc	s2,0x5
    80003634:	f8090913          	addi	s2,s2,-128 # 800085b0 <syscalls+0x168>
    80003638:	85ca                	mv	a1,s2
    8000363a:	8526                	mv	a0,s1
    8000363c:	00001097          	auipc	ra,0x1
    80003640:	e4e080e7          	jalr	-434(ra) # 8000448a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003644:	08848493          	addi	s1,s1,136
    80003648:	ff3498e3          	bne	s1,s3,80003638 <iinit+0x3e>
}
    8000364c:	70a2                	ld	ra,40(sp)
    8000364e:	7402                	ld	s0,32(sp)
    80003650:	64e2                	ld	s1,24(sp)
    80003652:	6942                	ld	s2,16(sp)
    80003654:	69a2                	ld	s3,8(sp)
    80003656:	6145                	addi	sp,sp,48
    80003658:	8082                	ret

000000008000365a <ialloc>:
{
    8000365a:	715d                	addi	sp,sp,-80
    8000365c:	e486                	sd	ra,72(sp)
    8000365e:	e0a2                	sd	s0,64(sp)
    80003660:	fc26                	sd	s1,56(sp)
    80003662:	f84a                	sd	s2,48(sp)
    80003664:	f44e                	sd	s3,40(sp)
    80003666:	f052                	sd	s4,32(sp)
    80003668:	ec56                	sd	s5,24(sp)
    8000366a:	e85a                	sd	s6,16(sp)
    8000366c:	e45e                	sd	s7,8(sp)
    8000366e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003670:	0001c717          	auipc	a4,0x1c
    80003674:	54472703          	lw	a4,1348(a4) # 8001fbb4 <sb+0xc>
    80003678:	4785                	li	a5,1
    8000367a:	04e7fa63          	bgeu	a5,a4,800036ce <ialloc+0x74>
    8000367e:	8aaa                	mv	s5,a0
    80003680:	8bae                	mv	s7,a1
    80003682:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003684:	0001ca17          	auipc	s4,0x1c
    80003688:	524a0a13          	addi	s4,s4,1316 # 8001fba8 <sb>
    8000368c:	00048b1b          	sext.w	s6,s1
    80003690:	0044d593          	srli	a1,s1,0x4
    80003694:	018a2783          	lw	a5,24(s4)
    80003698:	9dbd                	addw	a1,a1,a5
    8000369a:	8556                	mv	a0,s5
    8000369c:	00000097          	auipc	ra,0x0
    800036a0:	956080e7          	jalr	-1706(ra) # 80002ff2 <bread>
    800036a4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800036a6:	05850993          	addi	s3,a0,88
    800036aa:	00f4f793          	andi	a5,s1,15
    800036ae:	079a                	slli	a5,a5,0x6
    800036b0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800036b2:	00099783          	lh	a5,0(s3)
    800036b6:	c785                	beqz	a5,800036de <ialloc+0x84>
    brelse(bp);
    800036b8:	00000097          	auipc	ra,0x0
    800036bc:	a6a080e7          	jalr	-1430(ra) # 80003122 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036c0:	0485                	addi	s1,s1,1
    800036c2:	00ca2703          	lw	a4,12(s4)
    800036c6:	0004879b          	sext.w	a5,s1
    800036ca:	fce7e1e3          	bltu	a5,a4,8000368c <ialloc+0x32>
  panic("ialloc: no inodes");
    800036ce:	00005517          	auipc	a0,0x5
    800036d2:	eea50513          	addi	a0,a0,-278 # 800085b8 <syscalls+0x170>
    800036d6:	ffffd097          	auipc	ra,0xffffd
    800036da:	e64080e7          	jalr	-412(ra) # 8000053a <panic>
      memset(dip, 0, sizeof(*dip));
    800036de:	04000613          	li	a2,64
    800036e2:	4581                	li	a1,0
    800036e4:	854e                	mv	a0,s3
    800036e6:	ffffd097          	auipc	ra,0xffffd
    800036ea:	5e6080e7          	jalr	1510(ra) # 80000ccc <memset>
      dip->type = type;
    800036ee:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800036f2:	854a                	mv	a0,s2
    800036f4:	00001097          	auipc	ra,0x1
    800036f8:	cb2080e7          	jalr	-846(ra) # 800043a6 <log_write>
      brelse(bp);
    800036fc:	854a                	mv	a0,s2
    800036fe:	00000097          	auipc	ra,0x0
    80003702:	a24080e7          	jalr	-1500(ra) # 80003122 <brelse>
      return iget(dev, inum);
    80003706:	85da                	mv	a1,s6
    80003708:	8556                	mv	a0,s5
    8000370a:	00000097          	auipc	ra,0x0
    8000370e:	db4080e7          	jalr	-588(ra) # 800034be <iget>
}
    80003712:	60a6                	ld	ra,72(sp)
    80003714:	6406                	ld	s0,64(sp)
    80003716:	74e2                	ld	s1,56(sp)
    80003718:	7942                	ld	s2,48(sp)
    8000371a:	79a2                	ld	s3,40(sp)
    8000371c:	7a02                	ld	s4,32(sp)
    8000371e:	6ae2                	ld	s5,24(sp)
    80003720:	6b42                	ld	s6,16(sp)
    80003722:	6ba2                	ld	s7,8(sp)
    80003724:	6161                	addi	sp,sp,80
    80003726:	8082                	ret

0000000080003728 <iupdate>:
{
    80003728:	1101                	addi	sp,sp,-32
    8000372a:	ec06                	sd	ra,24(sp)
    8000372c:	e822                	sd	s0,16(sp)
    8000372e:	e426                	sd	s1,8(sp)
    80003730:	e04a                	sd	s2,0(sp)
    80003732:	1000                	addi	s0,sp,32
    80003734:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003736:	415c                	lw	a5,4(a0)
    80003738:	0047d79b          	srliw	a5,a5,0x4
    8000373c:	0001c597          	auipc	a1,0x1c
    80003740:	4845a583          	lw	a1,1156(a1) # 8001fbc0 <sb+0x18>
    80003744:	9dbd                	addw	a1,a1,a5
    80003746:	4108                	lw	a0,0(a0)
    80003748:	00000097          	auipc	ra,0x0
    8000374c:	8aa080e7          	jalr	-1878(ra) # 80002ff2 <bread>
    80003750:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003752:	05850793          	addi	a5,a0,88
    80003756:	40d8                	lw	a4,4(s1)
    80003758:	8b3d                	andi	a4,a4,15
    8000375a:	071a                	slli	a4,a4,0x6
    8000375c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000375e:	04449703          	lh	a4,68(s1)
    80003762:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003766:	04649703          	lh	a4,70(s1)
    8000376a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000376e:	04849703          	lh	a4,72(s1)
    80003772:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003776:	04a49703          	lh	a4,74(s1)
    8000377a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000377e:	44f8                	lw	a4,76(s1)
    80003780:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003782:	03400613          	li	a2,52
    80003786:	05048593          	addi	a1,s1,80
    8000378a:	00c78513          	addi	a0,a5,12
    8000378e:	ffffd097          	auipc	ra,0xffffd
    80003792:	59a080e7          	jalr	1434(ra) # 80000d28 <memmove>
  log_write(bp);
    80003796:	854a                	mv	a0,s2
    80003798:	00001097          	auipc	ra,0x1
    8000379c:	c0e080e7          	jalr	-1010(ra) # 800043a6 <log_write>
  brelse(bp);
    800037a0:	854a                	mv	a0,s2
    800037a2:	00000097          	auipc	ra,0x0
    800037a6:	980080e7          	jalr	-1664(ra) # 80003122 <brelse>
}
    800037aa:	60e2                	ld	ra,24(sp)
    800037ac:	6442                	ld	s0,16(sp)
    800037ae:	64a2                	ld	s1,8(sp)
    800037b0:	6902                	ld	s2,0(sp)
    800037b2:	6105                	addi	sp,sp,32
    800037b4:	8082                	ret

00000000800037b6 <idup>:
{
    800037b6:	1101                	addi	sp,sp,-32
    800037b8:	ec06                	sd	ra,24(sp)
    800037ba:	e822                	sd	s0,16(sp)
    800037bc:	e426                	sd	s1,8(sp)
    800037be:	1000                	addi	s0,sp,32
    800037c0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037c2:	0001c517          	auipc	a0,0x1c
    800037c6:	40650513          	addi	a0,a0,1030 # 8001fbc8 <itable>
    800037ca:	ffffd097          	auipc	ra,0xffffd
    800037ce:	406080e7          	jalr	1030(ra) # 80000bd0 <acquire>
  ip->ref++;
    800037d2:	449c                	lw	a5,8(s1)
    800037d4:	2785                	addiw	a5,a5,1
    800037d6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037d8:	0001c517          	auipc	a0,0x1c
    800037dc:	3f050513          	addi	a0,a0,1008 # 8001fbc8 <itable>
    800037e0:	ffffd097          	auipc	ra,0xffffd
    800037e4:	4a4080e7          	jalr	1188(ra) # 80000c84 <release>
}
    800037e8:	8526                	mv	a0,s1
    800037ea:	60e2                	ld	ra,24(sp)
    800037ec:	6442                	ld	s0,16(sp)
    800037ee:	64a2                	ld	s1,8(sp)
    800037f0:	6105                	addi	sp,sp,32
    800037f2:	8082                	ret

00000000800037f4 <ilock>:
{
    800037f4:	1101                	addi	sp,sp,-32
    800037f6:	ec06                	sd	ra,24(sp)
    800037f8:	e822                	sd	s0,16(sp)
    800037fa:	e426                	sd	s1,8(sp)
    800037fc:	e04a                	sd	s2,0(sp)
    800037fe:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003800:	c115                	beqz	a0,80003824 <ilock+0x30>
    80003802:	84aa                	mv	s1,a0
    80003804:	451c                	lw	a5,8(a0)
    80003806:	00f05f63          	blez	a5,80003824 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000380a:	0541                	addi	a0,a0,16
    8000380c:	00001097          	auipc	ra,0x1
    80003810:	cb8080e7          	jalr	-840(ra) # 800044c4 <acquiresleep>
  if(ip->valid == 0){
    80003814:	40bc                	lw	a5,64(s1)
    80003816:	cf99                	beqz	a5,80003834 <ilock+0x40>
}
    80003818:	60e2                	ld	ra,24(sp)
    8000381a:	6442                	ld	s0,16(sp)
    8000381c:	64a2                	ld	s1,8(sp)
    8000381e:	6902                	ld	s2,0(sp)
    80003820:	6105                	addi	sp,sp,32
    80003822:	8082                	ret
    panic("ilock");
    80003824:	00005517          	auipc	a0,0x5
    80003828:	dac50513          	addi	a0,a0,-596 # 800085d0 <syscalls+0x188>
    8000382c:	ffffd097          	auipc	ra,0xffffd
    80003830:	d0e080e7          	jalr	-754(ra) # 8000053a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003834:	40dc                	lw	a5,4(s1)
    80003836:	0047d79b          	srliw	a5,a5,0x4
    8000383a:	0001c597          	auipc	a1,0x1c
    8000383e:	3865a583          	lw	a1,902(a1) # 8001fbc0 <sb+0x18>
    80003842:	9dbd                	addw	a1,a1,a5
    80003844:	4088                	lw	a0,0(s1)
    80003846:	fffff097          	auipc	ra,0xfffff
    8000384a:	7ac080e7          	jalr	1964(ra) # 80002ff2 <bread>
    8000384e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003850:	05850593          	addi	a1,a0,88
    80003854:	40dc                	lw	a5,4(s1)
    80003856:	8bbd                	andi	a5,a5,15
    80003858:	079a                	slli	a5,a5,0x6
    8000385a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000385c:	00059783          	lh	a5,0(a1)
    80003860:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003864:	00259783          	lh	a5,2(a1)
    80003868:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000386c:	00459783          	lh	a5,4(a1)
    80003870:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003874:	00659783          	lh	a5,6(a1)
    80003878:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000387c:	459c                	lw	a5,8(a1)
    8000387e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003880:	03400613          	li	a2,52
    80003884:	05b1                	addi	a1,a1,12
    80003886:	05048513          	addi	a0,s1,80
    8000388a:	ffffd097          	auipc	ra,0xffffd
    8000388e:	49e080e7          	jalr	1182(ra) # 80000d28 <memmove>
    brelse(bp);
    80003892:	854a                	mv	a0,s2
    80003894:	00000097          	auipc	ra,0x0
    80003898:	88e080e7          	jalr	-1906(ra) # 80003122 <brelse>
    ip->valid = 1;
    8000389c:	4785                	li	a5,1
    8000389e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800038a0:	04449783          	lh	a5,68(s1)
    800038a4:	fbb5                	bnez	a5,80003818 <ilock+0x24>
      panic("ilock: no type");
    800038a6:	00005517          	auipc	a0,0x5
    800038aa:	d3250513          	addi	a0,a0,-718 # 800085d8 <syscalls+0x190>
    800038ae:	ffffd097          	auipc	ra,0xffffd
    800038b2:	c8c080e7          	jalr	-884(ra) # 8000053a <panic>

00000000800038b6 <iunlock>:
{
    800038b6:	1101                	addi	sp,sp,-32
    800038b8:	ec06                	sd	ra,24(sp)
    800038ba:	e822                	sd	s0,16(sp)
    800038bc:	e426                	sd	s1,8(sp)
    800038be:	e04a                	sd	s2,0(sp)
    800038c0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800038c2:	c905                	beqz	a0,800038f2 <iunlock+0x3c>
    800038c4:	84aa                	mv	s1,a0
    800038c6:	01050913          	addi	s2,a0,16
    800038ca:	854a                	mv	a0,s2
    800038cc:	00001097          	auipc	ra,0x1
    800038d0:	c92080e7          	jalr	-878(ra) # 8000455e <holdingsleep>
    800038d4:	cd19                	beqz	a0,800038f2 <iunlock+0x3c>
    800038d6:	449c                	lw	a5,8(s1)
    800038d8:	00f05d63          	blez	a5,800038f2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800038dc:	854a                	mv	a0,s2
    800038de:	00001097          	auipc	ra,0x1
    800038e2:	c3c080e7          	jalr	-964(ra) # 8000451a <releasesleep>
}
    800038e6:	60e2                	ld	ra,24(sp)
    800038e8:	6442                	ld	s0,16(sp)
    800038ea:	64a2                	ld	s1,8(sp)
    800038ec:	6902                	ld	s2,0(sp)
    800038ee:	6105                	addi	sp,sp,32
    800038f0:	8082                	ret
    panic("iunlock");
    800038f2:	00005517          	auipc	a0,0x5
    800038f6:	cf650513          	addi	a0,a0,-778 # 800085e8 <syscalls+0x1a0>
    800038fa:	ffffd097          	auipc	ra,0xffffd
    800038fe:	c40080e7          	jalr	-960(ra) # 8000053a <panic>

0000000080003902 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003902:	7179                	addi	sp,sp,-48
    80003904:	f406                	sd	ra,40(sp)
    80003906:	f022                	sd	s0,32(sp)
    80003908:	ec26                	sd	s1,24(sp)
    8000390a:	e84a                	sd	s2,16(sp)
    8000390c:	e44e                	sd	s3,8(sp)
    8000390e:	e052                	sd	s4,0(sp)
    80003910:	1800                	addi	s0,sp,48
    80003912:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003914:	05050493          	addi	s1,a0,80
    80003918:	08050913          	addi	s2,a0,128
    8000391c:	a021                	j	80003924 <itrunc+0x22>
    8000391e:	0491                	addi	s1,s1,4
    80003920:	01248d63          	beq	s1,s2,8000393a <itrunc+0x38>
    if(ip->addrs[i]){
    80003924:	408c                	lw	a1,0(s1)
    80003926:	dde5                	beqz	a1,8000391e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003928:	0009a503          	lw	a0,0(s3)
    8000392c:	00000097          	auipc	ra,0x0
    80003930:	90c080e7          	jalr	-1780(ra) # 80003238 <bfree>
      ip->addrs[i] = 0;
    80003934:	0004a023          	sw	zero,0(s1)
    80003938:	b7dd                	j	8000391e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000393a:	0809a583          	lw	a1,128(s3)
    8000393e:	e185                	bnez	a1,8000395e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003940:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003944:	854e                	mv	a0,s3
    80003946:	00000097          	auipc	ra,0x0
    8000394a:	de2080e7          	jalr	-542(ra) # 80003728 <iupdate>
}
    8000394e:	70a2                	ld	ra,40(sp)
    80003950:	7402                	ld	s0,32(sp)
    80003952:	64e2                	ld	s1,24(sp)
    80003954:	6942                	ld	s2,16(sp)
    80003956:	69a2                	ld	s3,8(sp)
    80003958:	6a02                	ld	s4,0(sp)
    8000395a:	6145                	addi	sp,sp,48
    8000395c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000395e:	0009a503          	lw	a0,0(s3)
    80003962:	fffff097          	auipc	ra,0xfffff
    80003966:	690080e7          	jalr	1680(ra) # 80002ff2 <bread>
    8000396a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000396c:	05850493          	addi	s1,a0,88
    80003970:	45850913          	addi	s2,a0,1112
    80003974:	a021                	j	8000397c <itrunc+0x7a>
    80003976:	0491                	addi	s1,s1,4
    80003978:	01248b63          	beq	s1,s2,8000398e <itrunc+0x8c>
      if(a[j])
    8000397c:	408c                	lw	a1,0(s1)
    8000397e:	dde5                	beqz	a1,80003976 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003980:	0009a503          	lw	a0,0(s3)
    80003984:	00000097          	auipc	ra,0x0
    80003988:	8b4080e7          	jalr	-1868(ra) # 80003238 <bfree>
    8000398c:	b7ed                	j	80003976 <itrunc+0x74>
    brelse(bp);
    8000398e:	8552                	mv	a0,s4
    80003990:	fffff097          	auipc	ra,0xfffff
    80003994:	792080e7          	jalr	1938(ra) # 80003122 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003998:	0809a583          	lw	a1,128(s3)
    8000399c:	0009a503          	lw	a0,0(s3)
    800039a0:	00000097          	auipc	ra,0x0
    800039a4:	898080e7          	jalr	-1896(ra) # 80003238 <bfree>
    ip->addrs[NDIRECT] = 0;
    800039a8:	0809a023          	sw	zero,128(s3)
    800039ac:	bf51                	j	80003940 <itrunc+0x3e>

00000000800039ae <iput>:
{
    800039ae:	1101                	addi	sp,sp,-32
    800039b0:	ec06                	sd	ra,24(sp)
    800039b2:	e822                	sd	s0,16(sp)
    800039b4:	e426                	sd	s1,8(sp)
    800039b6:	e04a                	sd	s2,0(sp)
    800039b8:	1000                	addi	s0,sp,32
    800039ba:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039bc:	0001c517          	auipc	a0,0x1c
    800039c0:	20c50513          	addi	a0,a0,524 # 8001fbc8 <itable>
    800039c4:	ffffd097          	auipc	ra,0xffffd
    800039c8:	20c080e7          	jalr	524(ra) # 80000bd0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039cc:	4498                	lw	a4,8(s1)
    800039ce:	4785                	li	a5,1
    800039d0:	02f70363          	beq	a4,a5,800039f6 <iput+0x48>
  ip->ref--;
    800039d4:	449c                	lw	a5,8(s1)
    800039d6:	37fd                	addiw	a5,a5,-1
    800039d8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039da:	0001c517          	auipc	a0,0x1c
    800039de:	1ee50513          	addi	a0,a0,494 # 8001fbc8 <itable>
    800039e2:	ffffd097          	auipc	ra,0xffffd
    800039e6:	2a2080e7          	jalr	674(ra) # 80000c84 <release>
}
    800039ea:	60e2                	ld	ra,24(sp)
    800039ec:	6442                	ld	s0,16(sp)
    800039ee:	64a2                	ld	s1,8(sp)
    800039f0:	6902                	ld	s2,0(sp)
    800039f2:	6105                	addi	sp,sp,32
    800039f4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039f6:	40bc                	lw	a5,64(s1)
    800039f8:	dff1                	beqz	a5,800039d4 <iput+0x26>
    800039fa:	04a49783          	lh	a5,74(s1)
    800039fe:	fbf9                	bnez	a5,800039d4 <iput+0x26>
    acquiresleep(&ip->lock);
    80003a00:	01048913          	addi	s2,s1,16
    80003a04:	854a                	mv	a0,s2
    80003a06:	00001097          	auipc	ra,0x1
    80003a0a:	abe080e7          	jalr	-1346(ra) # 800044c4 <acquiresleep>
    release(&itable.lock);
    80003a0e:	0001c517          	auipc	a0,0x1c
    80003a12:	1ba50513          	addi	a0,a0,442 # 8001fbc8 <itable>
    80003a16:	ffffd097          	auipc	ra,0xffffd
    80003a1a:	26e080e7          	jalr	622(ra) # 80000c84 <release>
    itrunc(ip);
    80003a1e:	8526                	mv	a0,s1
    80003a20:	00000097          	auipc	ra,0x0
    80003a24:	ee2080e7          	jalr	-286(ra) # 80003902 <itrunc>
    ip->type = 0;
    80003a28:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a2c:	8526                	mv	a0,s1
    80003a2e:	00000097          	auipc	ra,0x0
    80003a32:	cfa080e7          	jalr	-774(ra) # 80003728 <iupdate>
    ip->valid = 0;
    80003a36:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a3a:	854a                	mv	a0,s2
    80003a3c:	00001097          	auipc	ra,0x1
    80003a40:	ade080e7          	jalr	-1314(ra) # 8000451a <releasesleep>
    acquire(&itable.lock);
    80003a44:	0001c517          	auipc	a0,0x1c
    80003a48:	18450513          	addi	a0,a0,388 # 8001fbc8 <itable>
    80003a4c:	ffffd097          	auipc	ra,0xffffd
    80003a50:	184080e7          	jalr	388(ra) # 80000bd0 <acquire>
    80003a54:	b741                	j	800039d4 <iput+0x26>

0000000080003a56 <iunlockput>:
{
    80003a56:	1101                	addi	sp,sp,-32
    80003a58:	ec06                	sd	ra,24(sp)
    80003a5a:	e822                	sd	s0,16(sp)
    80003a5c:	e426                	sd	s1,8(sp)
    80003a5e:	1000                	addi	s0,sp,32
    80003a60:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a62:	00000097          	auipc	ra,0x0
    80003a66:	e54080e7          	jalr	-428(ra) # 800038b6 <iunlock>
  iput(ip);
    80003a6a:	8526                	mv	a0,s1
    80003a6c:	00000097          	auipc	ra,0x0
    80003a70:	f42080e7          	jalr	-190(ra) # 800039ae <iput>
}
    80003a74:	60e2                	ld	ra,24(sp)
    80003a76:	6442                	ld	s0,16(sp)
    80003a78:	64a2                	ld	s1,8(sp)
    80003a7a:	6105                	addi	sp,sp,32
    80003a7c:	8082                	ret

0000000080003a7e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a7e:	1141                	addi	sp,sp,-16
    80003a80:	e422                	sd	s0,8(sp)
    80003a82:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a84:	411c                	lw	a5,0(a0)
    80003a86:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a88:	415c                	lw	a5,4(a0)
    80003a8a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a8c:	04451783          	lh	a5,68(a0)
    80003a90:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a94:	04a51783          	lh	a5,74(a0)
    80003a98:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a9c:	04c56783          	lwu	a5,76(a0)
    80003aa0:	e99c                	sd	a5,16(a1)
}
    80003aa2:	6422                	ld	s0,8(sp)
    80003aa4:	0141                	addi	sp,sp,16
    80003aa6:	8082                	ret

0000000080003aa8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003aa8:	457c                	lw	a5,76(a0)
    80003aaa:	0ed7e963          	bltu	a5,a3,80003b9c <readi+0xf4>
{
    80003aae:	7159                	addi	sp,sp,-112
    80003ab0:	f486                	sd	ra,104(sp)
    80003ab2:	f0a2                	sd	s0,96(sp)
    80003ab4:	eca6                	sd	s1,88(sp)
    80003ab6:	e8ca                	sd	s2,80(sp)
    80003ab8:	e4ce                	sd	s3,72(sp)
    80003aba:	e0d2                	sd	s4,64(sp)
    80003abc:	fc56                	sd	s5,56(sp)
    80003abe:	f85a                	sd	s6,48(sp)
    80003ac0:	f45e                	sd	s7,40(sp)
    80003ac2:	f062                	sd	s8,32(sp)
    80003ac4:	ec66                	sd	s9,24(sp)
    80003ac6:	e86a                	sd	s10,16(sp)
    80003ac8:	e46e                	sd	s11,8(sp)
    80003aca:	1880                	addi	s0,sp,112
    80003acc:	8baa                	mv	s7,a0
    80003ace:	8c2e                	mv	s8,a1
    80003ad0:	8ab2                	mv	s5,a2
    80003ad2:	84b6                	mv	s1,a3
    80003ad4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ad6:	9f35                	addw	a4,a4,a3
    return 0;
    80003ad8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ada:	0ad76063          	bltu	a4,a3,80003b7a <readi+0xd2>
  if(off + n > ip->size)
    80003ade:	00e7f463          	bgeu	a5,a4,80003ae6 <readi+0x3e>
    n = ip->size - off;
    80003ae2:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ae6:	0a0b0963          	beqz	s6,80003b98 <readi+0xf0>
    80003aea:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aec:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003af0:	5cfd                	li	s9,-1
    80003af2:	a82d                	j	80003b2c <readi+0x84>
    80003af4:	020a1d93          	slli	s11,s4,0x20
    80003af8:	020ddd93          	srli	s11,s11,0x20
    80003afc:	05890613          	addi	a2,s2,88
    80003b00:	86ee                	mv	a3,s11
    80003b02:	963a                	add	a2,a2,a4
    80003b04:	85d6                	mv	a1,s5
    80003b06:	8562                	mv	a0,s8
    80003b08:	fffff097          	auipc	ra,0xfffff
    80003b0c:	95a080e7          	jalr	-1702(ra) # 80002462 <either_copyout>
    80003b10:	05950d63          	beq	a0,s9,80003b6a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b14:	854a                	mv	a0,s2
    80003b16:	fffff097          	auipc	ra,0xfffff
    80003b1a:	60c080e7          	jalr	1548(ra) # 80003122 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b1e:	013a09bb          	addw	s3,s4,s3
    80003b22:	009a04bb          	addw	s1,s4,s1
    80003b26:	9aee                	add	s5,s5,s11
    80003b28:	0569f763          	bgeu	s3,s6,80003b76 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b2c:	000ba903          	lw	s2,0(s7)
    80003b30:	00a4d59b          	srliw	a1,s1,0xa
    80003b34:	855e                	mv	a0,s7
    80003b36:	00000097          	auipc	ra,0x0
    80003b3a:	8ac080e7          	jalr	-1876(ra) # 800033e2 <bmap>
    80003b3e:	0005059b          	sext.w	a1,a0
    80003b42:	854a                	mv	a0,s2
    80003b44:	fffff097          	auipc	ra,0xfffff
    80003b48:	4ae080e7          	jalr	1198(ra) # 80002ff2 <bread>
    80003b4c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b4e:	3ff4f713          	andi	a4,s1,1023
    80003b52:	40ed07bb          	subw	a5,s10,a4
    80003b56:	413b06bb          	subw	a3,s6,s3
    80003b5a:	8a3e                	mv	s4,a5
    80003b5c:	2781                	sext.w	a5,a5
    80003b5e:	0006861b          	sext.w	a2,a3
    80003b62:	f8f679e3          	bgeu	a2,a5,80003af4 <readi+0x4c>
    80003b66:	8a36                	mv	s4,a3
    80003b68:	b771                	j	80003af4 <readi+0x4c>
      brelse(bp);
    80003b6a:	854a                	mv	a0,s2
    80003b6c:	fffff097          	auipc	ra,0xfffff
    80003b70:	5b6080e7          	jalr	1462(ra) # 80003122 <brelse>
      tot = -1;
    80003b74:	59fd                	li	s3,-1
  }
  return tot;
    80003b76:	0009851b          	sext.w	a0,s3
}
    80003b7a:	70a6                	ld	ra,104(sp)
    80003b7c:	7406                	ld	s0,96(sp)
    80003b7e:	64e6                	ld	s1,88(sp)
    80003b80:	6946                	ld	s2,80(sp)
    80003b82:	69a6                	ld	s3,72(sp)
    80003b84:	6a06                	ld	s4,64(sp)
    80003b86:	7ae2                	ld	s5,56(sp)
    80003b88:	7b42                	ld	s6,48(sp)
    80003b8a:	7ba2                	ld	s7,40(sp)
    80003b8c:	7c02                	ld	s8,32(sp)
    80003b8e:	6ce2                	ld	s9,24(sp)
    80003b90:	6d42                	ld	s10,16(sp)
    80003b92:	6da2                	ld	s11,8(sp)
    80003b94:	6165                	addi	sp,sp,112
    80003b96:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b98:	89da                	mv	s3,s6
    80003b9a:	bff1                	j	80003b76 <readi+0xce>
    return 0;
    80003b9c:	4501                	li	a0,0
}
    80003b9e:	8082                	ret

0000000080003ba0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ba0:	457c                	lw	a5,76(a0)
    80003ba2:	10d7e863          	bltu	a5,a3,80003cb2 <writei+0x112>
{
    80003ba6:	7159                	addi	sp,sp,-112
    80003ba8:	f486                	sd	ra,104(sp)
    80003baa:	f0a2                	sd	s0,96(sp)
    80003bac:	eca6                	sd	s1,88(sp)
    80003bae:	e8ca                	sd	s2,80(sp)
    80003bb0:	e4ce                	sd	s3,72(sp)
    80003bb2:	e0d2                	sd	s4,64(sp)
    80003bb4:	fc56                	sd	s5,56(sp)
    80003bb6:	f85a                	sd	s6,48(sp)
    80003bb8:	f45e                	sd	s7,40(sp)
    80003bba:	f062                	sd	s8,32(sp)
    80003bbc:	ec66                	sd	s9,24(sp)
    80003bbe:	e86a                	sd	s10,16(sp)
    80003bc0:	e46e                	sd	s11,8(sp)
    80003bc2:	1880                	addi	s0,sp,112
    80003bc4:	8b2a                	mv	s6,a0
    80003bc6:	8c2e                	mv	s8,a1
    80003bc8:	8ab2                	mv	s5,a2
    80003bca:	8936                	mv	s2,a3
    80003bcc:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003bce:	00e687bb          	addw	a5,a3,a4
    80003bd2:	0ed7e263          	bltu	a5,a3,80003cb6 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003bd6:	00043737          	lui	a4,0x43
    80003bda:	0ef76063          	bltu	a4,a5,80003cba <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bde:	0c0b8863          	beqz	s7,80003cae <writei+0x10e>
    80003be2:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003be4:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003be8:	5cfd                	li	s9,-1
    80003bea:	a091                	j	80003c2e <writei+0x8e>
    80003bec:	02099d93          	slli	s11,s3,0x20
    80003bf0:	020ddd93          	srli	s11,s11,0x20
    80003bf4:	05848513          	addi	a0,s1,88
    80003bf8:	86ee                	mv	a3,s11
    80003bfa:	8656                	mv	a2,s5
    80003bfc:	85e2                	mv	a1,s8
    80003bfe:	953a                	add	a0,a0,a4
    80003c00:	fffff097          	auipc	ra,0xfffff
    80003c04:	8b8080e7          	jalr	-1864(ra) # 800024b8 <either_copyin>
    80003c08:	07950263          	beq	a0,s9,80003c6c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c0c:	8526                	mv	a0,s1
    80003c0e:	00000097          	auipc	ra,0x0
    80003c12:	798080e7          	jalr	1944(ra) # 800043a6 <log_write>
    brelse(bp);
    80003c16:	8526                	mv	a0,s1
    80003c18:	fffff097          	auipc	ra,0xfffff
    80003c1c:	50a080e7          	jalr	1290(ra) # 80003122 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c20:	01498a3b          	addw	s4,s3,s4
    80003c24:	0129893b          	addw	s2,s3,s2
    80003c28:	9aee                	add	s5,s5,s11
    80003c2a:	057a7663          	bgeu	s4,s7,80003c76 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c2e:	000b2483          	lw	s1,0(s6)
    80003c32:	00a9559b          	srliw	a1,s2,0xa
    80003c36:	855a                	mv	a0,s6
    80003c38:	fffff097          	auipc	ra,0xfffff
    80003c3c:	7aa080e7          	jalr	1962(ra) # 800033e2 <bmap>
    80003c40:	0005059b          	sext.w	a1,a0
    80003c44:	8526                	mv	a0,s1
    80003c46:	fffff097          	auipc	ra,0xfffff
    80003c4a:	3ac080e7          	jalr	940(ra) # 80002ff2 <bread>
    80003c4e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c50:	3ff97713          	andi	a4,s2,1023
    80003c54:	40ed07bb          	subw	a5,s10,a4
    80003c58:	414b86bb          	subw	a3,s7,s4
    80003c5c:	89be                	mv	s3,a5
    80003c5e:	2781                	sext.w	a5,a5
    80003c60:	0006861b          	sext.w	a2,a3
    80003c64:	f8f674e3          	bgeu	a2,a5,80003bec <writei+0x4c>
    80003c68:	89b6                	mv	s3,a3
    80003c6a:	b749                	j	80003bec <writei+0x4c>
      brelse(bp);
    80003c6c:	8526                	mv	a0,s1
    80003c6e:	fffff097          	auipc	ra,0xfffff
    80003c72:	4b4080e7          	jalr	1204(ra) # 80003122 <brelse>
  }

  if(off > ip->size)
    80003c76:	04cb2783          	lw	a5,76(s6)
    80003c7a:	0127f463          	bgeu	a5,s2,80003c82 <writei+0xe2>
    ip->size = off;
    80003c7e:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c82:	855a                	mv	a0,s6
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	aa4080e7          	jalr	-1372(ra) # 80003728 <iupdate>

  return tot;
    80003c8c:	000a051b          	sext.w	a0,s4
}
    80003c90:	70a6                	ld	ra,104(sp)
    80003c92:	7406                	ld	s0,96(sp)
    80003c94:	64e6                	ld	s1,88(sp)
    80003c96:	6946                	ld	s2,80(sp)
    80003c98:	69a6                	ld	s3,72(sp)
    80003c9a:	6a06                	ld	s4,64(sp)
    80003c9c:	7ae2                	ld	s5,56(sp)
    80003c9e:	7b42                	ld	s6,48(sp)
    80003ca0:	7ba2                	ld	s7,40(sp)
    80003ca2:	7c02                	ld	s8,32(sp)
    80003ca4:	6ce2                	ld	s9,24(sp)
    80003ca6:	6d42                	ld	s10,16(sp)
    80003ca8:	6da2                	ld	s11,8(sp)
    80003caa:	6165                	addi	sp,sp,112
    80003cac:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cae:	8a5e                	mv	s4,s7
    80003cb0:	bfc9                	j	80003c82 <writei+0xe2>
    return -1;
    80003cb2:	557d                	li	a0,-1
}
    80003cb4:	8082                	ret
    return -1;
    80003cb6:	557d                	li	a0,-1
    80003cb8:	bfe1                	j	80003c90 <writei+0xf0>
    return -1;
    80003cba:	557d                	li	a0,-1
    80003cbc:	bfd1                	j	80003c90 <writei+0xf0>

0000000080003cbe <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003cbe:	1141                	addi	sp,sp,-16
    80003cc0:	e406                	sd	ra,8(sp)
    80003cc2:	e022                	sd	s0,0(sp)
    80003cc4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003cc6:	4639                	li	a2,14
    80003cc8:	ffffd097          	auipc	ra,0xffffd
    80003ccc:	0d4080e7          	jalr	212(ra) # 80000d9c <strncmp>
}
    80003cd0:	60a2                	ld	ra,8(sp)
    80003cd2:	6402                	ld	s0,0(sp)
    80003cd4:	0141                	addi	sp,sp,16
    80003cd6:	8082                	ret

0000000080003cd8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003cd8:	7139                	addi	sp,sp,-64
    80003cda:	fc06                	sd	ra,56(sp)
    80003cdc:	f822                	sd	s0,48(sp)
    80003cde:	f426                	sd	s1,40(sp)
    80003ce0:	f04a                	sd	s2,32(sp)
    80003ce2:	ec4e                	sd	s3,24(sp)
    80003ce4:	e852                	sd	s4,16(sp)
    80003ce6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ce8:	04451703          	lh	a4,68(a0)
    80003cec:	4785                	li	a5,1
    80003cee:	00f71a63          	bne	a4,a5,80003d02 <dirlookup+0x2a>
    80003cf2:	892a                	mv	s2,a0
    80003cf4:	89ae                	mv	s3,a1
    80003cf6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cf8:	457c                	lw	a5,76(a0)
    80003cfa:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003cfc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cfe:	e79d                	bnez	a5,80003d2c <dirlookup+0x54>
    80003d00:	a8a5                	j	80003d78 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d02:	00005517          	auipc	a0,0x5
    80003d06:	8ee50513          	addi	a0,a0,-1810 # 800085f0 <syscalls+0x1a8>
    80003d0a:	ffffd097          	auipc	ra,0xffffd
    80003d0e:	830080e7          	jalr	-2000(ra) # 8000053a <panic>
      panic("dirlookup read");
    80003d12:	00005517          	auipc	a0,0x5
    80003d16:	8f650513          	addi	a0,a0,-1802 # 80008608 <syscalls+0x1c0>
    80003d1a:	ffffd097          	auipc	ra,0xffffd
    80003d1e:	820080e7          	jalr	-2016(ra) # 8000053a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d22:	24c1                	addiw	s1,s1,16
    80003d24:	04c92783          	lw	a5,76(s2)
    80003d28:	04f4f763          	bgeu	s1,a5,80003d76 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d2c:	4741                	li	a4,16
    80003d2e:	86a6                	mv	a3,s1
    80003d30:	fc040613          	addi	a2,s0,-64
    80003d34:	4581                	li	a1,0
    80003d36:	854a                	mv	a0,s2
    80003d38:	00000097          	auipc	ra,0x0
    80003d3c:	d70080e7          	jalr	-656(ra) # 80003aa8 <readi>
    80003d40:	47c1                	li	a5,16
    80003d42:	fcf518e3          	bne	a0,a5,80003d12 <dirlookup+0x3a>
    if(de.inum == 0)
    80003d46:	fc045783          	lhu	a5,-64(s0)
    80003d4a:	dfe1                	beqz	a5,80003d22 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003d4c:	fc240593          	addi	a1,s0,-62
    80003d50:	854e                	mv	a0,s3
    80003d52:	00000097          	auipc	ra,0x0
    80003d56:	f6c080e7          	jalr	-148(ra) # 80003cbe <namecmp>
    80003d5a:	f561                	bnez	a0,80003d22 <dirlookup+0x4a>
      if(poff)
    80003d5c:	000a0463          	beqz	s4,80003d64 <dirlookup+0x8c>
        *poff = off;
    80003d60:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d64:	fc045583          	lhu	a1,-64(s0)
    80003d68:	00092503          	lw	a0,0(s2)
    80003d6c:	fffff097          	auipc	ra,0xfffff
    80003d70:	752080e7          	jalr	1874(ra) # 800034be <iget>
    80003d74:	a011                	j	80003d78 <dirlookup+0xa0>
  return 0;
    80003d76:	4501                	li	a0,0
}
    80003d78:	70e2                	ld	ra,56(sp)
    80003d7a:	7442                	ld	s0,48(sp)
    80003d7c:	74a2                	ld	s1,40(sp)
    80003d7e:	7902                	ld	s2,32(sp)
    80003d80:	69e2                	ld	s3,24(sp)
    80003d82:	6a42                	ld	s4,16(sp)
    80003d84:	6121                	addi	sp,sp,64
    80003d86:	8082                	ret

0000000080003d88 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d88:	711d                	addi	sp,sp,-96
    80003d8a:	ec86                	sd	ra,88(sp)
    80003d8c:	e8a2                	sd	s0,80(sp)
    80003d8e:	e4a6                	sd	s1,72(sp)
    80003d90:	e0ca                	sd	s2,64(sp)
    80003d92:	fc4e                	sd	s3,56(sp)
    80003d94:	f852                	sd	s4,48(sp)
    80003d96:	f456                	sd	s5,40(sp)
    80003d98:	f05a                	sd	s6,32(sp)
    80003d9a:	ec5e                	sd	s7,24(sp)
    80003d9c:	e862                	sd	s8,16(sp)
    80003d9e:	e466                	sd	s9,8(sp)
    80003da0:	e06a                	sd	s10,0(sp)
    80003da2:	1080                	addi	s0,sp,96
    80003da4:	84aa                	mv	s1,a0
    80003da6:	8b2e                	mv	s6,a1
    80003da8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003daa:	00054703          	lbu	a4,0(a0)
    80003dae:	02f00793          	li	a5,47
    80003db2:	02f70363          	beq	a4,a5,80003dd8 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003db6:	ffffe097          	auipc	ra,0xffffe
    80003dba:	be0080e7          	jalr	-1056(ra) # 80001996 <myproc>
    80003dbe:	15853503          	ld	a0,344(a0)
    80003dc2:	00000097          	auipc	ra,0x0
    80003dc6:	9f4080e7          	jalr	-1548(ra) # 800037b6 <idup>
    80003dca:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003dcc:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003dd0:	4cb5                	li	s9,13
  len = path - s;
    80003dd2:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003dd4:	4c05                	li	s8,1
    80003dd6:	a87d                	j	80003e94 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003dd8:	4585                	li	a1,1
    80003dda:	4505                	li	a0,1
    80003ddc:	fffff097          	auipc	ra,0xfffff
    80003de0:	6e2080e7          	jalr	1762(ra) # 800034be <iget>
    80003de4:	8a2a                	mv	s4,a0
    80003de6:	b7dd                	j	80003dcc <namex+0x44>
      iunlockput(ip);
    80003de8:	8552                	mv	a0,s4
    80003dea:	00000097          	auipc	ra,0x0
    80003dee:	c6c080e7          	jalr	-916(ra) # 80003a56 <iunlockput>
      return 0;
    80003df2:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003df4:	8552                	mv	a0,s4
    80003df6:	60e6                	ld	ra,88(sp)
    80003df8:	6446                	ld	s0,80(sp)
    80003dfa:	64a6                	ld	s1,72(sp)
    80003dfc:	6906                	ld	s2,64(sp)
    80003dfe:	79e2                	ld	s3,56(sp)
    80003e00:	7a42                	ld	s4,48(sp)
    80003e02:	7aa2                	ld	s5,40(sp)
    80003e04:	7b02                	ld	s6,32(sp)
    80003e06:	6be2                	ld	s7,24(sp)
    80003e08:	6c42                	ld	s8,16(sp)
    80003e0a:	6ca2                	ld	s9,8(sp)
    80003e0c:	6d02                	ld	s10,0(sp)
    80003e0e:	6125                	addi	sp,sp,96
    80003e10:	8082                	ret
      iunlock(ip);
    80003e12:	8552                	mv	a0,s4
    80003e14:	00000097          	auipc	ra,0x0
    80003e18:	aa2080e7          	jalr	-1374(ra) # 800038b6 <iunlock>
      return ip;
    80003e1c:	bfe1                	j	80003df4 <namex+0x6c>
      iunlockput(ip);
    80003e1e:	8552                	mv	a0,s4
    80003e20:	00000097          	auipc	ra,0x0
    80003e24:	c36080e7          	jalr	-970(ra) # 80003a56 <iunlockput>
      return 0;
    80003e28:	8a4e                	mv	s4,s3
    80003e2a:	b7e9                	j	80003df4 <namex+0x6c>
  len = path - s;
    80003e2c:	40998633          	sub	a2,s3,s1
    80003e30:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003e34:	09acd863          	bge	s9,s10,80003ec4 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003e38:	4639                	li	a2,14
    80003e3a:	85a6                	mv	a1,s1
    80003e3c:	8556                	mv	a0,s5
    80003e3e:	ffffd097          	auipc	ra,0xffffd
    80003e42:	eea080e7          	jalr	-278(ra) # 80000d28 <memmove>
    80003e46:	84ce                	mv	s1,s3
  while(*path == '/')
    80003e48:	0004c783          	lbu	a5,0(s1)
    80003e4c:	01279763          	bne	a5,s2,80003e5a <namex+0xd2>
    path++;
    80003e50:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e52:	0004c783          	lbu	a5,0(s1)
    80003e56:	ff278de3          	beq	a5,s2,80003e50 <namex+0xc8>
    ilock(ip);
    80003e5a:	8552                	mv	a0,s4
    80003e5c:	00000097          	auipc	ra,0x0
    80003e60:	998080e7          	jalr	-1640(ra) # 800037f4 <ilock>
    if(ip->type != T_DIR){
    80003e64:	044a1783          	lh	a5,68(s4)
    80003e68:	f98790e3          	bne	a5,s8,80003de8 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003e6c:	000b0563          	beqz	s6,80003e76 <namex+0xee>
    80003e70:	0004c783          	lbu	a5,0(s1)
    80003e74:	dfd9                	beqz	a5,80003e12 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e76:	865e                	mv	a2,s7
    80003e78:	85d6                	mv	a1,s5
    80003e7a:	8552                	mv	a0,s4
    80003e7c:	00000097          	auipc	ra,0x0
    80003e80:	e5c080e7          	jalr	-420(ra) # 80003cd8 <dirlookup>
    80003e84:	89aa                	mv	s3,a0
    80003e86:	dd41                	beqz	a0,80003e1e <namex+0x96>
    iunlockput(ip);
    80003e88:	8552                	mv	a0,s4
    80003e8a:	00000097          	auipc	ra,0x0
    80003e8e:	bcc080e7          	jalr	-1076(ra) # 80003a56 <iunlockput>
    ip = next;
    80003e92:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003e94:	0004c783          	lbu	a5,0(s1)
    80003e98:	01279763          	bne	a5,s2,80003ea6 <namex+0x11e>
    path++;
    80003e9c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e9e:	0004c783          	lbu	a5,0(s1)
    80003ea2:	ff278de3          	beq	a5,s2,80003e9c <namex+0x114>
  if(*path == 0)
    80003ea6:	cb9d                	beqz	a5,80003edc <namex+0x154>
  while(*path != '/' && *path != 0)
    80003ea8:	0004c783          	lbu	a5,0(s1)
    80003eac:	89a6                	mv	s3,s1
  len = path - s;
    80003eae:	8d5e                	mv	s10,s7
    80003eb0:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003eb2:	01278963          	beq	a5,s2,80003ec4 <namex+0x13c>
    80003eb6:	dbbd                	beqz	a5,80003e2c <namex+0xa4>
    path++;
    80003eb8:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003eba:	0009c783          	lbu	a5,0(s3)
    80003ebe:	ff279ce3          	bne	a5,s2,80003eb6 <namex+0x12e>
    80003ec2:	b7ad                	j	80003e2c <namex+0xa4>
    memmove(name, s, len);
    80003ec4:	2601                	sext.w	a2,a2
    80003ec6:	85a6                	mv	a1,s1
    80003ec8:	8556                	mv	a0,s5
    80003eca:	ffffd097          	auipc	ra,0xffffd
    80003ece:	e5e080e7          	jalr	-418(ra) # 80000d28 <memmove>
    name[len] = 0;
    80003ed2:	9d56                	add	s10,s10,s5
    80003ed4:	000d0023          	sb	zero,0(s10)
    80003ed8:	84ce                	mv	s1,s3
    80003eda:	b7bd                	j	80003e48 <namex+0xc0>
  if(nameiparent){
    80003edc:	f00b0ce3          	beqz	s6,80003df4 <namex+0x6c>
    iput(ip);
    80003ee0:	8552                	mv	a0,s4
    80003ee2:	00000097          	auipc	ra,0x0
    80003ee6:	acc080e7          	jalr	-1332(ra) # 800039ae <iput>
    return 0;
    80003eea:	4a01                	li	s4,0
    80003eec:	b721                	j	80003df4 <namex+0x6c>

0000000080003eee <dirlink>:
{
    80003eee:	7139                	addi	sp,sp,-64
    80003ef0:	fc06                	sd	ra,56(sp)
    80003ef2:	f822                	sd	s0,48(sp)
    80003ef4:	f426                	sd	s1,40(sp)
    80003ef6:	f04a                	sd	s2,32(sp)
    80003ef8:	ec4e                	sd	s3,24(sp)
    80003efa:	e852                	sd	s4,16(sp)
    80003efc:	0080                	addi	s0,sp,64
    80003efe:	892a                	mv	s2,a0
    80003f00:	8a2e                	mv	s4,a1
    80003f02:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f04:	4601                	li	a2,0
    80003f06:	00000097          	auipc	ra,0x0
    80003f0a:	dd2080e7          	jalr	-558(ra) # 80003cd8 <dirlookup>
    80003f0e:	e93d                	bnez	a0,80003f84 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f10:	04c92483          	lw	s1,76(s2)
    80003f14:	c49d                	beqz	s1,80003f42 <dirlink+0x54>
    80003f16:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f18:	4741                	li	a4,16
    80003f1a:	86a6                	mv	a3,s1
    80003f1c:	fc040613          	addi	a2,s0,-64
    80003f20:	4581                	li	a1,0
    80003f22:	854a                	mv	a0,s2
    80003f24:	00000097          	auipc	ra,0x0
    80003f28:	b84080e7          	jalr	-1148(ra) # 80003aa8 <readi>
    80003f2c:	47c1                	li	a5,16
    80003f2e:	06f51163          	bne	a0,a5,80003f90 <dirlink+0xa2>
    if(de.inum == 0)
    80003f32:	fc045783          	lhu	a5,-64(s0)
    80003f36:	c791                	beqz	a5,80003f42 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f38:	24c1                	addiw	s1,s1,16
    80003f3a:	04c92783          	lw	a5,76(s2)
    80003f3e:	fcf4ede3          	bltu	s1,a5,80003f18 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003f42:	4639                	li	a2,14
    80003f44:	85d2                	mv	a1,s4
    80003f46:	fc240513          	addi	a0,s0,-62
    80003f4a:	ffffd097          	auipc	ra,0xffffd
    80003f4e:	e8e080e7          	jalr	-370(ra) # 80000dd8 <strncpy>
  de.inum = inum;
    80003f52:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f56:	4741                	li	a4,16
    80003f58:	86a6                	mv	a3,s1
    80003f5a:	fc040613          	addi	a2,s0,-64
    80003f5e:	4581                	li	a1,0
    80003f60:	854a                	mv	a0,s2
    80003f62:	00000097          	auipc	ra,0x0
    80003f66:	c3e080e7          	jalr	-962(ra) # 80003ba0 <writei>
    80003f6a:	872a                	mv	a4,a0
    80003f6c:	47c1                	li	a5,16
  return 0;
    80003f6e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f70:	02f71863          	bne	a4,a5,80003fa0 <dirlink+0xb2>
}
    80003f74:	70e2                	ld	ra,56(sp)
    80003f76:	7442                	ld	s0,48(sp)
    80003f78:	74a2                	ld	s1,40(sp)
    80003f7a:	7902                	ld	s2,32(sp)
    80003f7c:	69e2                	ld	s3,24(sp)
    80003f7e:	6a42                	ld	s4,16(sp)
    80003f80:	6121                	addi	sp,sp,64
    80003f82:	8082                	ret
    iput(ip);
    80003f84:	00000097          	auipc	ra,0x0
    80003f88:	a2a080e7          	jalr	-1494(ra) # 800039ae <iput>
    return -1;
    80003f8c:	557d                	li	a0,-1
    80003f8e:	b7dd                	j	80003f74 <dirlink+0x86>
      panic("dirlink read");
    80003f90:	00004517          	auipc	a0,0x4
    80003f94:	68850513          	addi	a0,a0,1672 # 80008618 <syscalls+0x1d0>
    80003f98:	ffffc097          	auipc	ra,0xffffc
    80003f9c:	5a2080e7          	jalr	1442(ra) # 8000053a <panic>
    panic("dirlink");
    80003fa0:	00004517          	auipc	a0,0x4
    80003fa4:	78850513          	addi	a0,a0,1928 # 80008728 <syscalls+0x2e0>
    80003fa8:	ffffc097          	auipc	ra,0xffffc
    80003fac:	592080e7          	jalr	1426(ra) # 8000053a <panic>

0000000080003fb0 <namei>:

struct inode*
namei(char *path)
{
    80003fb0:	1101                	addi	sp,sp,-32
    80003fb2:	ec06                	sd	ra,24(sp)
    80003fb4:	e822                	sd	s0,16(sp)
    80003fb6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003fb8:	fe040613          	addi	a2,s0,-32
    80003fbc:	4581                	li	a1,0
    80003fbe:	00000097          	auipc	ra,0x0
    80003fc2:	dca080e7          	jalr	-566(ra) # 80003d88 <namex>
}
    80003fc6:	60e2                	ld	ra,24(sp)
    80003fc8:	6442                	ld	s0,16(sp)
    80003fca:	6105                	addi	sp,sp,32
    80003fcc:	8082                	ret

0000000080003fce <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003fce:	1141                	addi	sp,sp,-16
    80003fd0:	e406                	sd	ra,8(sp)
    80003fd2:	e022                	sd	s0,0(sp)
    80003fd4:	0800                	addi	s0,sp,16
    80003fd6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003fd8:	4585                	li	a1,1
    80003fda:	00000097          	auipc	ra,0x0
    80003fde:	dae080e7          	jalr	-594(ra) # 80003d88 <namex>
}
    80003fe2:	60a2                	ld	ra,8(sp)
    80003fe4:	6402                	ld	s0,0(sp)
    80003fe6:	0141                	addi	sp,sp,16
    80003fe8:	8082                	ret

0000000080003fea <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003fea:	1101                	addi	sp,sp,-32
    80003fec:	ec06                	sd	ra,24(sp)
    80003fee:	e822                	sd	s0,16(sp)
    80003ff0:	e426                	sd	s1,8(sp)
    80003ff2:	e04a                	sd	s2,0(sp)
    80003ff4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ff6:	0001d917          	auipc	s2,0x1d
    80003ffa:	67a90913          	addi	s2,s2,1658 # 80021670 <log>
    80003ffe:	01892583          	lw	a1,24(s2)
    80004002:	02892503          	lw	a0,40(s2)
    80004006:	fffff097          	auipc	ra,0xfffff
    8000400a:	fec080e7          	jalr	-20(ra) # 80002ff2 <bread>
    8000400e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004010:	02c92683          	lw	a3,44(s2)
    80004014:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004016:	02d05863          	blez	a3,80004046 <write_head+0x5c>
    8000401a:	0001d797          	auipc	a5,0x1d
    8000401e:	68678793          	addi	a5,a5,1670 # 800216a0 <log+0x30>
    80004022:	05c50713          	addi	a4,a0,92
    80004026:	36fd                	addiw	a3,a3,-1
    80004028:	02069613          	slli	a2,a3,0x20
    8000402c:	01e65693          	srli	a3,a2,0x1e
    80004030:	0001d617          	auipc	a2,0x1d
    80004034:	67460613          	addi	a2,a2,1652 # 800216a4 <log+0x34>
    80004038:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000403a:	4390                	lw	a2,0(a5)
    8000403c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000403e:	0791                	addi	a5,a5,4
    80004040:	0711                	addi	a4,a4,4
    80004042:	fed79ce3          	bne	a5,a3,8000403a <write_head+0x50>
  }
  bwrite(buf);
    80004046:	8526                	mv	a0,s1
    80004048:	fffff097          	auipc	ra,0xfffff
    8000404c:	09c080e7          	jalr	156(ra) # 800030e4 <bwrite>
  brelse(buf);
    80004050:	8526                	mv	a0,s1
    80004052:	fffff097          	auipc	ra,0xfffff
    80004056:	0d0080e7          	jalr	208(ra) # 80003122 <brelse>
}
    8000405a:	60e2                	ld	ra,24(sp)
    8000405c:	6442                	ld	s0,16(sp)
    8000405e:	64a2                	ld	s1,8(sp)
    80004060:	6902                	ld	s2,0(sp)
    80004062:	6105                	addi	sp,sp,32
    80004064:	8082                	ret

0000000080004066 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004066:	0001d797          	auipc	a5,0x1d
    8000406a:	6367a783          	lw	a5,1590(a5) # 8002169c <log+0x2c>
    8000406e:	0af05d63          	blez	a5,80004128 <install_trans+0xc2>
{
    80004072:	7139                	addi	sp,sp,-64
    80004074:	fc06                	sd	ra,56(sp)
    80004076:	f822                	sd	s0,48(sp)
    80004078:	f426                	sd	s1,40(sp)
    8000407a:	f04a                	sd	s2,32(sp)
    8000407c:	ec4e                	sd	s3,24(sp)
    8000407e:	e852                	sd	s4,16(sp)
    80004080:	e456                	sd	s5,8(sp)
    80004082:	e05a                	sd	s6,0(sp)
    80004084:	0080                	addi	s0,sp,64
    80004086:	8b2a                	mv	s6,a0
    80004088:	0001da97          	auipc	s5,0x1d
    8000408c:	618a8a93          	addi	s5,s5,1560 # 800216a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004090:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004092:	0001d997          	auipc	s3,0x1d
    80004096:	5de98993          	addi	s3,s3,1502 # 80021670 <log>
    8000409a:	a00d                	j	800040bc <install_trans+0x56>
    brelse(lbuf);
    8000409c:	854a                	mv	a0,s2
    8000409e:	fffff097          	auipc	ra,0xfffff
    800040a2:	084080e7          	jalr	132(ra) # 80003122 <brelse>
    brelse(dbuf);
    800040a6:	8526                	mv	a0,s1
    800040a8:	fffff097          	auipc	ra,0xfffff
    800040ac:	07a080e7          	jalr	122(ra) # 80003122 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040b0:	2a05                	addiw	s4,s4,1
    800040b2:	0a91                	addi	s5,s5,4
    800040b4:	02c9a783          	lw	a5,44(s3)
    800040b8:	04fa5e63          	bge	s4,a5,80004114 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040bc:	0189a583          	lw	a1,24(s3)
    800040c0:	014585bb          	addw	a1,a1,s4
    800040c4:	2585                	addiw	a1,a1,1
    800040c6:	0289a503          	lw	a0,40(s3)
    800040ca:	fffff097          	auipc	ra,0xfffff
    800040ce:	f28080e7          	jalr	-216(ra) # 80002ff2 <bread>
    800040d2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800040d4:	000aa583          	lw	a1,0(s5)
    800040d8:	0289a503          	lw	a0,40(s3)
    800040dc:	fffff097          	auipc	ra,0xfffff
    800040e0:	f16080e7          	jalr	-234(ra) # 80002ff2 <bread>
    800040e4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800040e6:	40000613          	li	a2,1024
    800040ea:	05890593          	addi	a1,s2,88
    800040ee:	05850513          	addi	a0,a0,88
    800040f2:	ffffd097          	auipc	ra,0xffffd
    800040f6:	c36080e7          	jalr	-970(ra) # 80000d28 <memmove>
    bwrite(dbuf);  // write dst to disk
    800040fa:	8526                	mv	a0,s1
    800040fc:	fffff097          	auipc	ra,0xfffff
    80004100:	fe8080e7          	jalr	-24(ra) # 800030e4 <bwrite>
    if(recovering == 0)
    80004104:	f80b1ce3          	bnez	s6,8000409c <install_trans+0x36>
      bunpin(dbuf);
    80004108:	8526                	mv	a0,s1
    8000410a:	fffff097          	auipc	ra,0xfffff
    8000410e:	0f2080e7          	jalr	242(ra) # 800031fc <bunpin>
    80004112:	b769                	j	8000409c <install_trans+0x36>
}
    80004114:	70e2                	ld	ra,56(sp)
    80004116:	7442                	ld	s0,48(sp)
    80004118:	74a2                	ld	s1,40(sp)
    8000411a:	7902                	ld	s2,32(sp)
    8000411c:	69e2                	ld	s3,24(sp)
    8000411e:	6a42                	ld	s4,16(sp)
    80004120:	6aa2                	ld	s5,8(sp)
    80004122:	6b02                	ld	s6,0(sp)
    80004124:	6121                	addi	sp,sp,64
    80004126:	8082                	ret
    80004128:	8082                	ret

000000008000412a <initlog>:
{
    8000412a:	7179                	addi	sp,sp,-48
    8000412c:	f406                	sd	ra,40(sp)
    8000412e:	f022                	sd	s0,32(sp)
    80004130:	ec26                	sd	s1,24(sp)
    80004132:	e84a                	sd	s2,16(sp)
    80004134:	e44e                	sd	s3,8(sp)
    80004136:	1800                	addi	s0,sp,48
    80004138:	892a                	mv	s2,a0
    8000413a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000413c:	0001d497          	auipc	s1,0x1d
    80004140:	53448493          	addi	s1,s1,1332 # 80021670 <log>
    80004144:	00004597          	auipc	a1,0x4
    80004148:	4e458593          	addi	a1,a1,1252 # 80008628 <syscalls+0x1e0>
    8000414c:	8526                	mv	a0,s1
    8000414e:	ffffd097          	auipc	ra,0xffffd
    80004152:	9f2080e7          	jalr	-1550(ra) # 80000b40 <initlock>
  log.start = sb->logstart;
    80004156:	0149a583          	lw	a1,20(s3)
    8000415a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000415c:	0109a783          	lw	a5,16(s3)
    80004160:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004162:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004166:	854a                	mv	a0,s2
    80004168:	fffff097          	auipc	ra,0xfffff
    8000416c:	e8a080e7          	jalr	-374(ra) # 80002ff2 <bread>
  log.lh.n = lh->n;
    80004170:	4d34                	lw	a3,88(a0)
    80004172:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004174:	02d05663          	blez	a3,800041a0 <initlog+0x76>
    80004178:	05c50793          	addi	a5,a0,92
    8000417c:	0001d717          	auipc	a4,0x1d
    80004180:	52470713          	addi	a4,a4,1316 # 800216a0 <log+0x30>
    80004184:	36fd                	addiw	a3,a3,-1
    80004186:	02069613          	slli	a2,a3,0x20
    8000418a:	01e65693          	srli	a3,a2,0x1e
    8000418e:	06050613          	addi	a2,a0,96
    80004192:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004194:	4390                	lw	a2,0(a5)
    80004196:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004198:	0791                	addi	a5,a5,4
    8000419a:	0711                	addi	a4,a4,4
    8000419c:	fed79ce3          	bne	a5,a3,80004194 <initlog+0x6a>
  brelse(buf);
    800041a0:	fffff097          	auipc	ra,0xfffff
    800041a4:	f82080e7          	jalr	-126(ra) # 80003122 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800041a8:	4505                	li	a0,1
    800041aa:	00000097          	auipc	ra,0x0
    800041ae:	ebc080e7          	jalr	-324(ra) # 80004066 <install_trans>
  log.lh.n = 0;
    800041b2:	0001d797          	auipc	a5,0x1d
    800041b6:	4e07a523          	sw	zero,1258(a5) # 8002169c <log+0x2c>
  write_head(); // clear the log
    800041ba:	00000097          	auipc	ra,0x0
    800041be:	e30080e7          	jalr	-464(ra) # 80003fea <write_head>
}
    800041c2:	70a2                	ld	ra,40(sp)
    800041c4:	7402                	ld	s0,32(sp)
    800041c6:	64e2                	ld	s1,24(sp)
    800041c8:	6942                	ld	s2,16(sp)
    800041ca:	69a2                	ld	s3,8(sp)
    800041cc:	6145                	addi	sp,sp,48
    800041ce:	8082                	ret

00000000800041d0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800041d0:	1101                	addi	sp,sp,-32
    800041d2:	ec06                	sd	ra,24(sp)
    800041d4:	e822                	sd	s0,16(sp)
    800041d6:	e426                	sd	s1,8(sp)
    800041d8:	e04a                	sd	s2,0(sp)
    800041da:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800041dc:	0001d517          	auipc	a0,0x1d
    800041e0:	49450513          	addi	a0,a0,1172 # 80021670 <log>
    800041e4:	ffffd097          	auipc	ra,0xffffd
    800041e8:	9ec080e7          	jalr	-1556(ra) # 80000bd0 <acquire>
  while(1){
    if(log.committing){
    800041ec:	0001d497          	auipc	s1,0x1d
    800041f0:	48448493          	addi	s1,s1,1156 # 80021670 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041f4:	4979                	li	s2,30
    800041f6:	a039                	j	80004204 <begin_op+0x34>
      sleep(&log, &log.lock);
    800041f8:	85a6                	mv	a1,s1
    800041fa:	8526                	mv	a0,s1
    800041fc:	ffffe097          	auipc	ra,0xffffe
    80004200:	e96080e7          	jalr	-362(ra) # 80002092 <sleep>
    if(log.committing){
    80004204:	50dc                	lw	a5,36(s1)
    80004206:	fbed                	bnez	a5,800041f8 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004208:	5098                	lw	a4,32(s1)
    8000420a:	2705                	addiw	a4,a4,1
    8000420c:	0007069b          	sext.w	a3,a4
    80004210:	0027179b          	slliw	a5,a4,0x2
    80004214:	9fb9                	addw	a5,a5,a4
    80004216:	0017979b          	slliw	a5,a5,0x1
    8000421a:	54d8                	lw	a4,44(s1)
    8000421c:	9fb9                	addw	a5,a5,a4
    8000421e:	00f95963          	bge	s2,a5,80004230 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004222:	85a6                	mv	a1,s1
    80004224:	8526                	mv	a0,s1
    80004226:	ffffe097          	auipc	ra,0xffffe
    8000422a:	e6c080e7          	jalr	-404(ra) # 80002092 <sleep>
    8000422e:	bfd9                	j	80004204 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004230:	0001d517          	auipc	a0,0x1d
    80004234:	44050513          	addi	a0,a0,1088 # 80021670 <log>
    80004238:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000423a:	ffffd097          	auipc	ra,0xffffd
    8000423e:	a4a080e7          	jalr	-1462(ra) # 80000c84 <release>
      break;
    }
  }
}
    80004242:	60e2                	ld	ra,24(sp)
    80004244:	6442                	ld	s0,16(sp)
    80004246:	64a2                	ld	s1,8(sp)
    80004248:	6902                	ld	s2,0(sp)
    8000424a:	6105                	addi	sp,sp,32
    8000424c:	8082                	ret

000000008000424e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000424e:	7139                	addi	sp,sp,-64
    80004250:	fc06                	sd	ra,56(sp)
    80004252:	f822                	sd	s0,48(sp)
    80004254:	f426                	sd	s1,40(sp)
    80004256:	f04a                	sd	s2,32(sp)
    80004258:	ec4e                	sd	s3,24(sp)
    8000425a:	e852                	sd	s4,16(sp)
    8000425c:	e456                	sd	s5,8(sp)
    8000425e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004260:	0001d497          	auipc	s1,0x1d
    80004264:	41048493          	addi	s1,s1,1040 # 80021670 <log>
    80004268:	8526                	mv	a0,s1
    8000426a:	ffffd097          	auipc	ra,0xffffd
    8000426e:	966080e7          	jalr	-1690(ra) # 80000bd0 <acquire>
  log.outstanding -= 1;
    80004272:	509c                	lw	a5,32(s1)
    80004274:	37fd                	addiw	a5,a5,-1
    80004276:	0007891b          	sext.w	s2,a5
    8000427a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000427c:	50dc                	lw	a5,36(s1)
    8000427e:	e7b9                	bnez	a5,800042cc <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004280:	04091e63          	bnez	s2,800042dc <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004284:	0001d497          	auipc	s1,0x1d
    80004288:	3ec48493          	addi	s1,s1,1004 # 80021670 <log>
    8000428c:	4785                	li	a5,1
    8000428e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004290:	8526                	mv	a0,s1
    80004292:	ffffd097          	auipc	ra,0xffffd
    80004296:	9f2080e7          	jalr	-1550(ra) # 80000c84 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000429a:	54dc                	lw	a5,44(s1)
    8000429c:	06f04763          	bgtz	a5,8000430a <end_op+0xbc>
    acquire(&log.lock);
    800042a0:	0001d497          	auipc	s1,0x1d
    800042a4:	3d048493          	addi	s1,s1,976 # 80021670 <log>
    800042a8:	8526                	mv	a0,s1
    800042aa:	ffffd097          	auipc	ra,0xffffd
    800042ae:	926080e7          	jalr	-1754(ra) # 80000bd0 <acquire>
    log.committing = 0;
    800042b2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800042b6:	8526                	mv	a0,s1
    800042b8:	ffffe097          	auipc	ra,0xffffe
    800042bc:	f66080e7          	jalr	-154(ra) # 8000221e <wakeup>
    release(&log.lock);
    800042c0:	8526                	mv	a0,s1
    800042c2:	ffffd097          	auipc	ra,0xffffd
    800042c6:	9c2080e7          	jalr	-1598(ra) # 80000c84 <release>
}
    800042ca:	a03d                	j	800042f8 <end_op+0xaa>
    panic("log.committing");
    800042cc:	00004517          	auipc	a0,0x4
    800042d0:	36450513          	addi	a0,a0,868 # 80008630 <syscalls+0x1e8>
    800042d4:	ffffc097          	auipc	ra,0xffffc
    800042d8:	266080e7          	jalr	614(ra) # 8000053a <panic>
    wakeup(&log);
    800042dc:	0001d497          	auipc	s1,0x1d
    800042e0:	39448493          	addi	s1,s1,916 # 80021670 <log>
    800042e4:	8526                	mv	a0,s1
    800042e6:	ffffe097          	auipc	ra,0xffffe
    800042ea:	f38080e7          	jalr	-200(ra) # 8000221e <wakeup>
  release(&log.lock);
    800042ee:	8526                	mv	a0,s1
    800042f0:	ffffd097          	auipc	ra,0xffffd
    800042f4:	994080e7          	jalr	-1644(ra) # 80000c84 <release>
}
    800042f8:	70e2                	ld	ra,56(sp)
    800042fa:	7442                	ld	s0,48(sp)
    800042fc:	74a2                	ld	s1,40(sp)
    800042fe:	7902                	ld	s2,32(sp)
    80004300:	69e2                	ld	s3,24(sp)
    80004302:	6a42                	ld	s4,16(sp)
    80004304:	6aa2                	ld	s5,8(sp)
    80004306:	6121                	addi	sp,sp,64
    80004308:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000430a:	0001da97          	auipc	s5,0x1d
    8000430e:	396a8a93          	addi	s5,s5,918 # 800216a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004312:	0001da17          	auipc	s4,0x1d
    80004316:	35ea0a13          	addi	s4,s4,862 # 80021670 <log>
    8000431a:	018a2583          	lw	a1,24(s4)
    8000431e:	012585bb          	addw	a1,a1,s2
    80004322:	2585                	addiw	a1,a1,1
    80004324:	028a2503          	lw	a0,40(s4)
    80004328:	fffff097          	auipc	ra,0xfffff
    8000432c:	cca080e7          	jalr	-822(ra) # 80002ff2 <bread>
    80004330:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004332:	000aa583          	lw	a1,0(s5)
    80004336:	028a2503          	lw	a0,40(s4)
    8000433a:	fffff097          	auipc	ra,0xfffff
    8000433e:	cb8080e7          	jalr	-840(ra) # 80002ff2 <bread>
    80004342:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004344:	40000613          	li	a2,1024
    80004348:	05850593          	addi	a1,a0,88
    8000434c:	05848513          	addi	a0,s1,88
    80004350:	ffffd097          	auipc	ra,0xffffd
    80004354:	9d8080e7          	jalr	-1576(ra) # 80000d28 <memmove>
    bwrite(to);  // write the log
    80004358:	8526                	mv	a0,s1
    8000435a:	fffff097          	auipc	ra,0xfffff
    8000435e:	d8a080e7          	jalr	-630(ra) # 800030e4 <bwrite>
    brelse(from);
    80004362:	854e                	mv	a0,s3
    80004364:	fffff097          	auipc	ra,0xfffff
    80004368:	dbe080e7          	jalr	-578(ra) # 80003122 <brelse>
    brelse(to);
    8000436c:	8526                	mv	a0,s1
    8000436e:	fffff097          	auipc	ra,0xfffff
    80004372:	db4080e7          	jalr	-588(ra) # 80003122 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004376:	2905                	addiw	s2,s2,1
    80004378:	0a91                	addi	s5,s5,4
    8000437a:	02ca2783          	lw	a5,44(s4)
    8000437e:	f8f94ee3          	blt	s2,a5,8000431a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004382:	00000097          	auipc	ra,0x0
    80004386:	c68080e7          	jalr	-920(ra) # 80003fea <write_head>
    install_trans(0); // Now install writes to home locations
    8000438a:	4501                	li	a0,0
    8000438c:	00000097          	auipc	ra,0x0
    80004390:	cda080e7          	jalr	-806(ra) # 80004066 <install_trans>
    log.lh.n = 0;
    80004394:	0001d797          	auipc	a5,0x1d
    80004398:	3007a423          	sw	zero,776(a5) # 8002169c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000439c:	00000097          	auipc	ra,0x0
    800043a0:	c4e080e7          	jalr	-946(ra) # 80003fea <write_head>
    800043a4:	bdf5                	j	800042a0 <end_op+0x52>

00000000800043a6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800043a6:	1101                	addi	sp,sp,-32
    800043a8:	ec06                	sd	ra,24(sp)
    800043aa:	e822                	sd	s0,16(sp)
    800043ac:	e426                	sd	s1,8(sp)
    800043ae:	e04a                	sd	s2,0(sp)
    800043b0:	1000                	addi	s0,sp,32
    800043b2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800043b4:	0001d917          	auipc	s2,0x1d
    800043b8:	2bc90913          	addi	s2,s2,700 # 80021670 <log>
    800043bc:	854a                	mv	a0,s2
    800043be:	ffffd097          	auipc	ra,0xffffd
    800043c2:	812080e7          	jalr	-2030(ra) # 80000bd0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800043c6:	02c92603          	lw	a2,44(s2)
    800043ca:	47f5                	li	a5,29
    800043cc:	06c7c563          	blt	a5,a2,80004436 <log_write+0x90>
    800043d0:	0001d797          	auipc	a5,0x1d
    800043d4:	2bc7a783          	lw	a5,700(a5) # 8002168c <log+0x1c>
    800043d8:	37fd                	addiw	a5,a5,-1
    800043da:	04f65e63          	bge	a2,a5,80004436 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800043de:	0001d797          	auipc	a5,0x1d
    800043e2:	2b27a783          	lw	a5,690(a5) # 80021690 <log+0x20>
    800043e6:	06f05063          	blez	a5,80004446 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800043ea:	4781                	li	a5,0
    800043ec:	06c05563          	blez	a2,80004456 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043f0:	44cc                	lw	a1,12(s1)
    800043f2:	0001d717          	auipc	a4,0x1d
    800043f6:	2ae70713          	addi	a4,a4,686 # 800216a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800043fa:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043fc:	4314                	lw	a3,0(a4)
    800043fe:	04b68c63          	beq	a3,a1,80004456 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004402:	2785                	addiw	a5,a5,1
    80004404:	0711                	addi	a4,a4,4
    80004406:	fef61be3          	bne	a2,a5,800043fc <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000440a:	0621                	addi	a2,a2,8
    8000440c:	060a                	slli	a2,a2,0x2
    8000440e:	0001d797          	auipc	a5,0x1d
    80004412:	26278793          	addi	a5,a5,610 # 80021670 <log>
    80004416:	97b2                	add	a5,a5,a2
    80004418:	44d8                	lw	a4,12(s1)
    8000441a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000441c:	8526                	mv	a0,s1
    8000441e:	fffff097          	auipc	ra,0xfffff
    80004422:	da2080e7          	jalr	-606(ra) # 800031c0 <bpin>
    log.lh.n++;
    80004426:	0001d717          	auipc	a4,0x1d
    8000442a:	24a70713          	addi	a4,a4,586 # 80021670 <log>
    8000442e:	575c                	lw	a5,44(a4)
    80004430:	2785                	addiw	a5,a5,1
    80004432:	d75c                	sw	a5,44(a4)
    80004434:	a82d                	j	8000446e <log_write+0xc8>
    panic("too big a transaction");
    80004436:	00004517          	auipc	a0,0x4
    8000443a:	20a50513          	addi	a0,a0,522 # 80008640 <syscalls+0x1f8>
    8000443e:	ffffc097          	auipc	ra,0xffffc
    80004442:	0fc080e7          	jalr	252(ra) # 8000053a <panic>
    panic("log_write outside of trans");
    80004446:	00004517          	auipc	a0,0x4
    8000444a:	21250513          	addi	a0,a0,530 # 80008658 <syscalls+0x210>
    8000444e:	ffffc097          	auipc	ra,0xffffc
    80004452:	0ec080e7          	jalr	236(ra) # 8000053a <panic>
  log.lh.block[i] = b->blockno;
    80004456:	00878693          	addi	a3,a5,8
    8000445a:	068a                	slli	a3,a3,0x2
    8000445c:	0001d717          	auipc	a4,0x1d
    80004460:	21470713          	addi	a4,a4,532 # 80021670 <log>
    80004464:	9736                	add	a4,a4,a3
    80004466:	44d4                	lw	a3,12(s1)
    80004468:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000446a:	faf609e3          	beq	a2,a5,8000441c <log_write+0x76>
  }
  release(&log.lock);
    8000446e:	0001d517          	auipc	a0,0x1d
    80004472:	20250513          	addi	a0,a0,514 # 80021670 <log>
    80004476:	ffffd097          	auipc	ra,0xffffd
    8000447a:	80e080e7          	jalr	-2034(ra) # 80000c84 <release>
}
    8000447e:	60e2                	ld	ra,24(sp)
    80004480:	6442                	ld	s0,16(sp)
    80004482:	64a2                	ld	s1,8(sp)
    80004484:	6902                	ld	s2,0(sp)
    80004486:	6105                	addi	sp,sp,32
    80004488:	8082                	ret

000000008000448a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000448a:	1101                	addi	sp,sp,-32
    8000448c:	ec06                	sd	ra,24(sp)
    8000448e:	e822                	sd	s0,16(sp)
    80004490:	e426                	sd	s1,8(sp)
    80004492:	e04a                	sd	s2,0(sp)
    80004494:	1000                	addi	s0,sp,32
    80004496:	84aa                	mv	s1,a0
    80004498:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000449a:	00004597          	auipc	a1,0x4
    8000449e:	1de58593          	addi	a1,a1,478 # 80008678 <syscalls+0x230>
    800044a2:	0521                	addi	a0,a0,8
    800044a4:	ffffc097          	auipc	ra,0xffffc
    800044a8:	69c080e7          	jalr	1692(ra) # 80000b40 <initlock>
  lk->name = name;
    800044ac:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800044b0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044b4:	0204a423          	sw	zero,40(s1)
}
    800044b8:	60e2                	ld	ra,24(sp)
    800044ba:	6442                	ld	s0,16(sp)
    800044bc:	64a2                	ld	s1,8(sp)
    800044be:	6902                	ld	s2,0(sp)
    800044c0:	6105                	addi	sp,sp,32
    800044c2:	8082                	ret

00000000800044c4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044c4:	1101                	addi	sp,sp,-32
    800044c6:	ec06                	sd	ra,24(sp)
    800044c8:	e822                	sd	s0,16(sp)
    800044ca:	e426                	sd	s1,8(sp)
    800044cc:	e04a                	sd	s2,0(sp)
    800044ce:	1000                	addi	s0,sp,32
    800044d0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044d2:	00850913          	addi	s2,a0,8
    800044d6:	854a                	mv	a0,s2
    800044d8:	ffffc097          	auipc	ra,0xffffc
    800044dc:	6f8080e7          	jalr	1784(ra) # 80000bd0 <acquire>
  while (lk->locked) {
    800044e0:	409c                	lw	a5,0(s1)
    800044e2:	cb89                	beqz	a5,800044f4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800044e4:	85ca                	mv	a1,s2
    800044e6:	8526                	mv	a0,s1
    800044e8:	ffffe097          	auipc	ra,0xffffe
    800044ec:	baa080e7          	jalr	-1110(ra) # 80002092 <sleep>
  while (lk->locked) {
    800044f0:	409c                	lw	a5,0(s1)
    800044f2:	fbed                	bnez	a5,800044e4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800044f4:	4785                	li	a5,1
    800044f6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800044f8:	ffffd097          	auipc	ra,0xffffd
    800044fc:	49e080e7          	jalr	1182(ra) # 80001996 <myproc>
    80004500:	591c                	lw	a5,48(a0)
    80004502:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004504:	854a                	mv	a0,s2
    80004506:	ffffc097          	auipc	ra,0xffffc
    8000450a:	77e080e7          	jalr	1918(ra) # 80000c84 <release>
}
    8000450e:	60e2                	ld	ra,24(sp)
    80004510:	6442                	ld	s0,16(sp)
    80004512:	64a2                	ld	s1,8(sp)
    80004514:	6902                	ld	s2,0(sp)
    80004516:	6105                	addi	sp,sp,32
    80004518:	8082                	ret

000000008000451a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000451a:	1101                	addi	sp,sp,-32
    8000451c:	ec06                	sd	ra,24(sp)
    8000451e:	e822                	sd	s0,16(sp)
    80004520:	e426                	sd	s1,8(sp)
    80004522:	e04a                	sd	s2,0(sp)
    80004524:	1000                	addi	s0,sp,32
    80004526:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004528:	00850913          	addi	s2,a0,8
    8000452c:	854a                	mv	a0,s2
    8000452e:	ffffc097          	auipc	ra,0xffffc
    80004532:	6a2080e7          	jalr	1698(ra) # 80000bd0 <acquire>
  lk->locked = 0;
    80004536:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000453a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000453e:	8526                	mv	a0,s1
    80004540:	ffffe097          	auipc	ra,0xffffe
    80004544:	cde080e7          	jalr	-802(ra) # 8000221e <wakeup>
  release(&lk->lk);
    80004548:	854a                	mv	a0,s2
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	73a080e7          	jalr	1850(ra) # 80000c84 <release>
}
    80004552:	60e2                	ld	ra,24(sp)
    80004554:	6442                	ld	s0,16(sp)
    80004556:	64a2                	ld	s1,8(sp)
    80004558:	6902                	ld	s2,0(sp)
    8000455a:	6105                	addi	sp,sp,32
    8000455c:	8082                	ret

000000008000455e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000455e:	7179                	addi	sp,sp,-48
    80004560:	f406                	sd	ra,40(sp)
    80004562:	f022                	sd	s0,32(sp)
    80004564:	ec26                	sd	s1,24(sp)
    80004566:	e84a                	sd	s2,16(sp)
    80004568:	e44e                	sd	s3,8(sp)
    8000456a:	1800                	addi	s0,sp,48
    8000456c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000456e:	00850913          	addi	s2,a0,8
    80004572:	854a                	mv	a0,s2
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	65c080e7          	jalr	1628(ra) # 80000bd0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000457c:	409c                	lw	a5,0(s1)
    8000457e:	ef99                	bnez	a5,8000459c <holdingsleep+0x3e>
    80004580:	4481                	li	s1,0
  release(&lk->lk);
    80004582:	854a                	mv	a0,s2
    80004584:	ffffc097          	auipc	ra,0xffffc
    80004588:	700080e7          	jalr	1792(ra) # 80000c84 <release>
  return r;
}
    8000458c:	8526                	mv	a0,s1
    8000458e:	70a2                	ld	ra,40(sp)
    80004590:	7402                	ld	s0,32(sp)
    80004592:	64e2                	ld	s1,24(sp)
    80004594:	6942                	ld	s2,16(sp)
    80004596:	69a2                	ld	s3,8(sp)
    80004598:	6145                	addi	sp,sp,48
    8000459a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000459c:	0284a983          	lw	s3,40(s1)
    800045a0:	ffffd097          	auipc	ra,0xffffd
    800045a4:	3f6080e7          	jalr	1014(ra) # 80001996 <myproc>
    800045a8:	5904                	lw	s1,48(a0)
    800045aa:	413484b3          	sub	s1,s1,s3
    800045ae:	0014b493          	seqz	s1,s1
    800045b2:	bfc1                	j	80004582 <holdingsleep+0x24>

00000000800045b4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800045b4:	1141                	addi	sp,sp,-16
    800045b6:	e406                	sd	ra,8(sp)
    800045b8:	e022                	sd	s0,0(sp)
    800045ba:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800045bc:	00004597          	auipc	a1,0x4
    800045c0:	0cc58593          	addi	a1,a1,204 # 80008688 <syscalls+0x240>
    800045c4:	0001d517          	auipc	a0,0x1d
    800045c8:	1f450513          	addi	a0,a0,500 # 800217b8 <ftable>
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	574080e7          	jalr	1396(ra) # 80000b40 <initlock>
}
    800045d4:	60a2                	ld	ra,8(sp)
    800045d6:	6402                	ld	s0,0(sp)
    800045d8:	0141                	addi	sp,sp,16
    800045da:	8082                	ret

00000000800045dc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045dc:	1101                	addi	sp,sp,-32
    800045de:	ec06                	sd	ra,24(sp)
    800045e0:	e822                	sd	s0,16(sp)
    800045e2:	e426                	sd	s1,8(sp)
    800045e4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045e6:	0001d517          	auipc	a0,0x1d
    800045ea:	1d250513          	addi	a0,a0,466 # 800217b8 <ftable>
    800045ee:	ffffc097          	auipc	ra,0xffffc
    800045f2:	5e2080e7          	jalr	1506(ra) # 80000bd0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045f6:	0001d497          	auipc	s1,0x1d
    800045fa:	1da48493          	addi	s1,s1,474 # 800217d0 <ftable+0x18>
    800045fe:	0001e717          	auipc	a4,0x1e
    80004602:	17270713          	addi	a4,a4,370 # 80022770 <ftable+0xfb8>
    if(f->ref == 0){
    80004606:	40dc                	lw	a5,4(s1)
    80004608:	cf99                	beqz	a5,80004626 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000460a:	02848493          	addi	s1,s1,40
    8000460e:	fee49ce3          	bne	s1,a4,80004606 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004612:	0001d517          	auipc	a0,0x1d
    80004616:	1a650513          	addi	a0,a0,422 # 800217b8 <ftable>
    8000461a:	ffffc097          	auipc	ra,0xffffc
    8000461e:	66a080e7          	jalr	1642(ra) # 80000c84 <release>
  return 0;
    80004622:	4481                	li	s1,0
    80004624:	a819                	j	8000463a <filealloc+0x5e>
      f->ref = 1;
    80004626:	4785                	li	a5,1
    80004628:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000462a:	0001d517          	auipc	a0,0x1d
    8000462e:	18e50513          	addi	a0,a0,398 # 800217b8 <ftable>
    80004632:	ffffc097          	auipc	ra,0xffffc
    80004636:	652080e7          	jalr	1618(ra) # 80000c84 <release>
}
    8000463a:	8526                	mv	a0,s1
    8000463c:	60e2                	ld	ra,24(sp)
    8000463e:	6442                	ld	s0,16(sp)
    80004640:	64a2                	ld	s1,8(sp)
    80004642:	6105                	addi	sp,sp,32
    80004644:	8082                	ret

0000000080004646 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004646:	1101                	addi	sp,sp,-32
    80004648:	ec06                	sd	ra,24(sp)
    8000464a:	e822                	sd	s0,16(sp)
    8000464c:	e426                	sd	s1,8(sp)
    8000464e:	1000                	addi	s0,sp,32
    80004650:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004652:	0001d517          	auipc	a0,0x1d
    80004656:	16650513          	addi	a0,a0,358 # 800217b8 <ftable>
    8000465a:	ffffc097          	auipc	ra,0xffffc
    8000465e:	576080e7          	jalr	1398(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    80004662:	40dc                	lw	a5,4(s1)
    80004664:	02f05263          	blez	a5,80004688 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004668:	2785                	addiw	a5,a5,1
    8000466a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000466c:	0001d517          	auipc	a0,0x1d
    80004670:	14c50513          	addi	a0,a0,332 # 800217b8 <ftable>
    80004674:	ffffc097          	auipc	ra,0xffffc
    80004678:	610080e7          	jalr	1552(ra) # 80000c84 <release>
  return f;
}
    8000467c:	8526                	mv	a0,s1
    8000467e:	60e2                	ld	ra,24(sp)
    80004680:	6442                	ld	s0,16(sp)
    80004682:	64a2                	ld	s1,8(sp)
    80004684:	6105                	addi	sp,sp,32
    80004686:	8082                	ret
    panic("filedup");
    80004688:	00004517          	auipc	a0,0x4
    8000468c:	00850513          	addi	a0,a0,8 # 80008690 <syscalls+0x248>
    80004690:	ffffc097          	auipc	ra,0xffffc
    80004694:	eaa080e7          	jalr	-342(ra) # 8000053a <panic>

0000000080004698 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004698:	7139                	addi	sp,sp,-64
    8000469a:	fc06                	sd	ra,56(sp)
    8000469c:	f822                	sd	s0,48(sp)
    8000469e:	f426                	sd	s1,40(sp)
    800046a0:	f04a                	sd	s2,32(sp)
    800046a2:	ec4e                	sd	s3,24(sp)
    800046a4:	e852                	sd	s4,16(sp)
    800046a6:	e456                	sd	s5,8(sp)
    800046a8:	0080                	addi	s0,sp,64
    800046aa:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800046ac:	0001d517          	auipc	a0,0x1d
    800046b0:	10c50513          	addi	a0,a0,268 # 800217b8 <ftable>
    800046b4:	ffffc097          	auipc	ra,0xffffc
    800046b8:	51c080e7          	jalr	1308(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    800046bc:	40dc                	lw	a5,4(s1)
    800046be:	06f05163          	blez	a5,80004720 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800046c2:	37fd                	addiw	a5,a5,-1
    800046c4:	0007871b          	sext.w	a4,a5
    800046c8:	c0dc                	sw	a5,4(s1)
    800046ca:	06e04363          	bgtz	a4,80004730 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046ce:	0004a903          	lw	s2,0(s1)
    800046d2:	0094ca83          	lbu	s5,9(s1)
    800046d6:	0104ba03          	ld	s4,16(s1)
    800046da:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800046de:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800046e2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800046e6:	0001d517          	auipc	a0,0x1d
    800046ea:	0d250513          	addi	a0,a0,210 # 800217b8 <ftable>
    800046ee:	ffffc097          	auipc	ra,0xffffc
    800046f2:	596080e7          	jalr	1430(ra) # 80000c84 <release>

  if(ff.type == FD_PIPE){
    800046f6:	4785                	li	a5,1
    800046f8:	04f90d63          	beq	s2,a5,80004752 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800046fc:	3979                	addiw	s2,s2,-2
    800046fe:	4785                	li	a5,1
    80004700:	0527e063          	bltu	a5,s2,80004740 <fileclose+0xa8>
    begin_op();
    80004704:	00000097          	auipc	ra,0x0
    80004708:	acc080e7          	jalr	-1332(ra) # 800041d0 <begin_op>
    iput(ff.ip);
    8000470c:	854e                	mv	a0,s3
    8000470e:	fffff097          	auipc	ra,0xfffff
    80004712:	2a0080e7          	jalr	672(ra) # 800039ae <iput>
    end_op();
    80004716:	00000097          	auipc	ra,0x0
    8000471a:	b38080e7          	jalr	-1224(ra) # 8000424e <end_op>
    8000471e:	a00d                	j	80004740 <fileclose+0xa8>
    panic("fileclose");
    80004720:	00004517          	auipc	a0,0x4
    80004724:	f7850513          	addi	a0,a0,-136 # 80008698 <syscalls+0x250>
    80004728:	ffffc097          	auipc	ra,0xffffc
    8000472c:	e12080e7          	jalr	-494(ra) # 8000053a <panic>
    release(&ftable.lock);
    80004730:	0001d517          	auipc	a0,0x1d
    80004734:	08850513          	addi	a0,a0,136 # 800217b8 <ftable>
    80004738:	ffffc097          	auipc	ra,0xffffc
    8000473c:	54c080e7          	jalr	1356(ra) # 80000c84 <release>
  }
}
    80004740:	70e2                	ld	ra,56(sp)
    80004742:	7442                	ld	s0,48(sp)
    80004744:	74a2                	ld	s1,40(sp)
    80004746:	7902                	ld	s2,32(sp)
    80004748:	69e2                	ld	s3,24(sp)
    8000474a:	6a42                	ld	s4,16(sp)
    8000474c:	6aa2                	ld	s5,8(sp)
    8000474e:	6121                	addi	sp,sp,64
    80004750:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004752:	85d6                	mv	a1,s5
    80004754:	8552                	mv	a0,s4
    80004756:	00000097          	auipc	ra,0x0
    8000475a:	34c080e7          	jalr	844(ra) # 80004aa2 <pipeclose>
    8000475e:	b7cd                	j	80004740 <fileclose+0xa8>

0000000080004760 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004760:	715d                	addi	sp,sp,-80
    80004762:	e486                	sd	ra,72(sp)
    80004764:	e0a2                	sd	s0,64(sp)
    80004766:	fc26                	sd	s1,56(sp)
    80004768:	f84a                	sd	s2,48(sp)
    8000476a:	f44e                	sd	s3,40(sp)
    8000476c:	0880                	addi	s0,sp,80
    8000476e:	84aa                	mv	s1,a0
    80004770:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004772:	ffffd097          	auipc	ra,0xffffd
    80004776:	224080e7          	jalr	548(ra) # 80001996 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000477a:	409c                	lw	a5,0(s1)
    8000477c:	37f9                	addiw	a5,a5,-2
    8000477e:	4705                	li	a4,1
    80004780:	04f76763          	bltu	a4,a5,800047ce <filestat+0x6e>
    80004784:	892a                	mv	s2,a0
    ilock(f->ip);
    80004786:	6c88                	ld	a0,24(s1)
    80004788:	fffff097          	auipc	ra,0xfffff
    8000478c:	06c080e7          	jalr	108(ra) # 800037f4 <ilock>
    stati(f->ip, &st);
    80004790:	fb840593          	addi	a1,s0,-72
    80004794:	6c88                	ld	a0,24(s1)
    80004796:	fffff097          	auipc	ra,0xfffff
    8000479a:	2e8080e7          	jalr	744(ra) # 80003a7e <stati>
    iunlock(f->ip);
    8000479e:	6c88                	ld	a0,24(s1)
    800047a0:	fffff097          	auipc	ra,0xfffff
    800047a4:	116080e7          	jalr	278(ra) # 800038b6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800047a8:	46e1                	li	a3,24
    800047aa:	fb840613          	addi	a2,s0,-72
    800047ae:	85ce                	mv	a1,s3
    800047b0:	05893503          	ld	a0,88(s2)
    800047b4:	ffffd097          	auipc	ra,0xffffd
    800047b8:	ea6080e7          	jalr	-346(ra) # 8000165a <copyout>
    800047bc:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800047c0:	60a6                	ld	ra,72(sp)
    800047c2:	6406                	ld	s0,64(sp)
    800047c4:	74e2                	ld	s1,56(sp)
    800047c6:	7942                	ld	s2,48(sp)
    800047c8:	79a2                	ld	s3,40(sp)
    800047ca:	6161                	addi	sp,sp,80
    800047cc:	8082                	ret
  return -1;
    800047ce:	557d                	li	a0,-1
    800047d0:	bfc5                	j	800047c0 <filestat+0x60>

00000000800047d2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800047d2:	7179                	addi	sp,sp,-48
    800047d4:	f406                	sd	ra,40(sp)
    800047d6:	f022                	sd	s0,32(sp)
    800047d8:	ec26                	sd	s1,24(sp)
    800047da:	e84a                	sd	s2,16(sp)
    800047dc:	e44e                	sd	s3,8(sp)
    800047de:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800047e0:	00854783          	lbu	a5,8(a0)
    800047e4:	c3d5                	beqz	a5,80004888 <fileread+0xb6>
    800047e6:	84aa                	mv	s1,a0
    800047e8:	89ae                	mv	s3,a1
    800047ea:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800047ec:	411c                	lw	a5,0(a0)
    800047ee:	4705                	li	a4,1
    800047f0:	04e78963          	beq	a5,a4,80004842 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047f4:	470d                	li	a4,3
    800047f6:	04e78d63          	beq	a5,a4,80004850 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800047fa:	4709                	li	a4,2
    800047fc:	06e79e63          	bne	a5,a4,80004878 <fileread+0xa6>
    ilock(f->ip);
    80004800:	6d08                	ld	a0,24(a0)
    80004802:	fffff097          	auipc	ra,0xfffff
    80004806:	ff2080e7          	jalr	-14(ra) # 800037f4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000480a:	874a                	mv	a4,s2
    8000480c:	5094                	lw	a3,32(s1)
    8000480e:	864e                	mv	a2,s3
    80004810:	4585                	li	a1,1
    80004812:	6c88                	ld	a0,24(s1)
    80004814:	fffff097          	auipc	ra,0xfffff
    80004818:	294080e7          	jalr	660(ra) # 80003aa8 <readi>
    8000481c:	892a                	mv	s2,a0
    8000481e:	00a05563          	blez	a0,80004828 <fileread+0x56>
      f->off += r;
    80004822:	509c                	lw	a5,32(s1)
    80004824:	9fa9                	addw	a5,a5,a0
    80004826:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004828:	6c88                	ld	a0,24(s1)
    8000482a:	fffff097          	auipc	ra,0xfffff
    8000482e:	08c080e7          	jalr	140(ra) # 800038b6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004832:	854a                	mv	a0,s2
    80004834:	70a2                	ld	ra,40(sp)
    80004836:	7402                	ld	s0,32(sp)
    80004838:	64e2                	ld	s1,24(sp)
    8000483a:	6942                	ld	s2,16(sp)
    8000483c:	69a2                	ld	s3,8(sp)
    8000483e:	6145                	addi	sp,sp,48
    80004840:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004842:	6908                	ld	a0,16(a0)
    80004844:	00000097          	auipc	ra,0x0
    80004848:	3c0080e7          	jalr	960(ra) # 80004c04 <piperead>
    8000484c:	892a                	mv	s2,a0
    8000484e:	b7d5                	j	80004832 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004850:	02451783          	lh	a5,36(a0)
    80004854:	03079693          	slli	a3,a5,0x30
    80004858:	92c1                	srli	a3,a3,0x30
    8000485a:	4725                	li	a4,9
    8000485c:	02d76863          	bltu	a4,a3,8000488c <fileread+0xba>
    80004860:	0792                	slli	a5,a5,0x4
    80004862:	0001d717          	auipc	a4,0x1d
    80004866:	eb670713          	addi	a4,a4,-330 # 80021718 <devsw>
    8000486a:	97ba                	add	a5,a5,a4
    8000486c:	639c                	ld	a5,0(a5)
    8000486e:	c38d                	beqz	a5,80004890 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004870:	4505                	li	a0,1
    80004872:	9782                	jalr	a5
    80004874:	892a                	mv	s2,a0
    80004876:	bf75                	j	80004832 <fileread+0x60>
    panic("fileread");
    80004878:	00004517          	auipc	a0,0x4
    8000487c:	e3050513          	addi	a0,a0,-464 # 800086a8 <syscalls+0x260>
    80004880:	ffffc097          	auipc	ra,0xffffc
    80004884:	cba080e7          	jalr	-838(ra) # 8000053a <panic>
    return -1;
    80004888:	597d                	li	s2,-1
    8000488a:	b765                	j	80004832 <fileread+0x60>
      return -1;
    8000488c:	597d                	li	s2,-1
    8000488e:	b755                	j	80004832 <fileread+0x60>
    80004890:	597d                	li	s2,-1
    80004892:	b745                	j	80004832 <fileread+0x60>

0000000080004894 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004894:	715d                	addi	sp,sp,-80
    80004896:	e486                	sd	ra,72(sp)
    80004898:	e0a2                	sd	s0,64(sp)
    8000489a:	fc26                	sd	s1,56(sp)
    8000489c:	f84a                	sd	s2,48(sp)
    8000489e:	f44e                	sd	s3,40(sp)
    800048a0:	f052                	sd	s4,32(sp)
    800048a2:	ec56                	sd	s5,24(sp)
    800048a4:	e85a                	sd	s6,16(sp)
    800048a6:	e45e                	sd	s7,8(sp)
    800048a8:	e062                	sd	s8,0(sp)
    800048aa:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800048ac:	00954783          	lbu	a5,9(a0)
    800048b0:	10078663          	beqz	a5,800049bc <filewrite+0x128>
    800048b4:	892a                	mv	s2,a0
    800048b6:	8b2e                	mv	s6,a1
    800048b8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800048ba:	411c                	lw	a5,0(a0)
    800048bc:	4705                	li	a4,1
    800048be:	02e78263          	beq	a5,a4,800048e2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048c2:	470d                	li	a4,3
    800048c4:	02e78663          	beq	a5,a4,800048f0 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800048c8:	4709                	li	a4,2
    800048ca:	0ee79163          	bne	a5,a4,800049ac <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800048ce:	0ac05d63          	blez	a2,80004988 <filewrite+0xf4>
    int i = 0;
    800048d2:	4981                	li	s3,0
    800048d4:	6b85                	lui	s7,0x1
    800048d6:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800048da:	6c05                	lui	s8,0x1
    800048dc:	c00c0c1b          	addiw	s8,s8,-1024
    800048e0:	a861                	j	80004978 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800048e2:	6908                	ld	a0,16(a0)
    800048e4:	00000097          	auipc	ra,0x0
    800048e8:	22e080e7          	jalr	558(ra) # 80004b12 <pipewrite>
    800048ec:	8a2a                	mv	s4,a0
    800048ee:	a045                	j	8000498e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800048f0:	02451783          	lh	a5,36(a0)
    800048f4:	03079693          	slli	a3,a5,0x30
    800048f8:	92c1                	srli	a3,a3,0x30
    800048fa:	4725                	li	a4,9
    800048fc:	0cd76263          	bltu	a4,a3,800049c0 <filewrite+0x12c>
    80004900:	0792                	slli	a5,a5,0x4
    80004902:	0001d717          	auipc	a4,0x1d
    80004906:	e1670713          	addi	a4,a4,-490 # 80021718 <devsw>
    8000490a:	97ba                	add	a5,a5,a4
    8000490c:	679c                	ld	a5,8(a5)
    8000490e:	cbdd                	beqz	a5,800049c4 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004910:	4505                	li	a0,1
    80004912:	9782                	jalr	a5
    80004914:	8a2a                	mv	s4,a0
    80004916:	a8a5                	j	8000498e <filewrite+0xfa>
    80004918:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000491c:	00000097          	auipc	ra,0x0
    80004920:	8b4080e7          	jalr	-1868(ra) # 800041d0 <begin_op>
      ilock(f->ip);
    80004924:	01893503          	ld	a0,24(s2)
    80004928:	fffff097          	auipc	ra,0xfffff
    8000492c:	ecc080e7          	jalr	-308(ra) # 800037f4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004930:	8756                	mv	a4,s5
    80004932:	02092683          	lw	a3,32(s2)
    80004936:	01698633          	add	a2,s3,s6
    8000493a:	4585                	li	a1,1
    8000493c:	01893503          	ld	a0,24(s2)
    80004940:	fffff097          	auipc	ra,0xfffff
    80004944:	260080e7          	jalr	608(ra) # 80003ba0 <writei>
    80004948:	84aa                	mv	s1,a0
    8000494a:	00a05763          	blez	a0,80004958 <filewrite+0xc4>
        f->off += r;
    8000494e:	02092783          	lw	a5,32(s2)
    80004952:	9fa9                	addw	a5,a5,a0
    80004954:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004958:	01893503          	ld	a0,24(s2)
    8000495c:	fffff097          	auipc	ra,0xfffff
    80004960:	f5a080e7          	jalr	-166(ra) # 800038b6 <iunlock>
      end_op();
    80004964:	00000097          	auipc	ra,0x0
    80004968:	8ea080e7          	jalr	-1814(ra) # 8000424e <end_op>

      if(r != n1){
    8000496c:	009a9f63          	bne	s5,s1,8000498a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004970:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004974:	0149db63          	bge	s3,s4,8000498a <filewrite+0xf6>
      int n1 = n - i;
    80004978:	413a04bb          	subw	s1,s4,s3
    8000497c:	0004879b          	sext.w	a5,s1
    80004980:	f8fbdce3          	bge	s7,a5,80004918 <filewrite+0x84>
    80004984:	84e2                	mv	s1,s8
    80004986:	bf49                	j	80004918 <filewrite+0x84>
    int i = 0;
    80004988:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000498a:	013a1f63          	bne	s4,s3,800049a8 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000498e:	8552                	mv	a0,s4
    80004990:	60a6                	ld	ra,72(sp)
    80004992:	6406                	ld	s0,64(sp)
    80004994:	74e2                	ld	s1,56(sp)
    80004996:	7942                	ld	s2,48(sp)
    80004998:	79a2                	ld	s3,40(sp)
    8000499a:	7a02                	ld	s4,32(sp)
    8000499c:	6ae2                	ld	s5,24(sp)
    8000499e:	6b42                	ld	s6,16(sp)
    800049a0:	6ba2                	ld	s7,8(sp)
    800049a2:	6c02                	ld	s8,0(sp)
    800049a4:	6161                	addi	sp,sp,80
    800049a6:	8082                	ret
    ret = (i == n ? n : -1);
    800049a8:	5a7d                	li	s4,-1
    800049aa:	b7d5                	j	8000498e <filewrite+0xfa>
    panic("filewrite");
    800049ac:	00004517          	auipc	a0,0x4
    800049b0:	d0c50513          	addi	a0,a0,-756 # 800086b8 <syscalls+0x270>
    800049b4:	ffffc097          	auipc	ra,0xffffc
    800049b8:	b86080e7          	jalr	-1146(ra) # 8000053a <panic>
    return -1;
    800049bc:	5a7d                	li	s4,-1
    800049be:	bfc1                	j	8000498e <filewrite+0xfa>
      return -1;
    800049c0:	5a7d                	li	s4,-1
    800049c2:	b7f1                	j	8000498e <filewrite+0xfa>
    800049c4:	5a7d                	li	s4,-1
    800049c6:	b7e1                	j	8000498e <filewrite+0xfa>

00000000800049c8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800049c8:	7179                	addi	sp,sp,-48
    800049ca:	f406                	sd	ra,40(sp)
    800049cc:	f022                	sd	s0,32(sp)
    800049ce:	ec26                	sd	s1,24(sp)
    800049d0:	e84a                	sd	s2,16(sp)
    800049d2:	e44e                	sd	s3,8(sp)
    800049d4:	e052                	sd	s4,0(sp)
    800049d6:	1800                	addi	s0,sp,48
    800049d8:	84aa                	mv	s1,a0
    800049da:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800049dc:	0005b023          	sd	zero,0(a1)
    800049e0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800049e4:	00000097          	auipc	ra,0x0
    800049e8:	bf8080e7          	jalr	-1032(ra) # 800045dc <filealloc>
    800049ec:	e088                	sd	a0,0(s1)
    800049ee:	c551                	beqz	a0,80004a7a <pipealloc+0xb2>
    800049f0:	00000097          	auipc	ra,0x0
    800049f4:	bec080e7          	jalr	-1044(ra) # 800045dc <filealloc>
    800049f8:	00aa3023          	sd	a0,0(s4)
    800049fc:	c92d                	beqz	a0,80004a6e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800049fe:	ffffc097          	auipc	ra,0xffffc
    80004a02:	0e2080e7          	jalr	226(ra) # 80000ae0 <kalloc>
    80004a06:	892a                	mv	s2,a0
    80004a08:	c125                	beqz	a0,80004a68 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a0a:	4985                	li	s3,1
    80004a0c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004a10:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004a14:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a18:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a1c:	00004597          	auipc	a1,0x4
    80004a20:	cac58593          	addi	a1,a1,-852 # 800086c8 <syscalls+0x280>
    80004a24:	ffffc097          	auipc	ra,0xffffc
    80004a28:	11c080e7          	jalr	284(ra) # 80000b40 <initlock>
  (*f0)->type = FD_PIPE;
    80004a2c:	609c                	ld	a5,0(s1)
    80004a2e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a32:	609c                	ld	a5,0(s1)
    80004a34:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a38:	609c                	ld	a5,0(s1)
    80004a3a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a3e:	609c                	ld	a5,0(s1)
    80004a40:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a44:	000a3783          	ld	a5,0(s4)
    80004a48:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a4c:	000a3783          	ld	a5,0(s4)
    80004a50:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a54:	000a3783          	ld	a5,0(s4)
    80004a58:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a5c:	000a3783          	ld	a5,0(s4)
    80004a60:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a64:	4501                	li	a0,0
    80004a66:	a025                	j	80004a8e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a68:	6088                	ld	a0,0(s1)
    80004a6a:	e501                	bnez	a0,80004a72 <pipealloc+0xaa>
    80004a6c:	a039                	j	80004a7a <pipealloc+0xb2>
    80004a6e:	6088                	ld	a0,0(s1)
    80004a70:	c51d                	beqz	a0,80004a9e <pipealloc+0xd6>
    fileclose(*f0);
    80004a72:	00000097          	auipc	ra,0x0
    80004a76:	c26080e7          	jalr	-986(ra) # 80004698 <fileclose>
  if(*f1)
    80004a7a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a7e:	557d                	li	a0,-1
  if(*f1)
    80004a80:	c799                	beqz	a5,80004a8e <pipealloc+0xc6>
    fileclose(*f1);
    80004a82:	853e                	mv	a0,a5
    80004a84:	00000097          	auipc	ra,0x0
    80004a88:	c14080e7          	jalr	-1004(ra) # 80004698 <fileclose>
  return -1;
    80004a8c:	557d                	li	a0,-1
}
    80004a8e:	70a2                	ld	ra,40(sp)
    80004a90:	7402                	ld	s0,32(sp)
    80004a92:	64e2                	ld	s1,24(sp)
    80004a94:	6942                	ld	s2,16(sp)
    80004a96:	69a2                	ld	s3,8(sp)
    80004a98:	6a02                	ld	s4,0(sp)
    80004a9a:	6145                	addi	sp,sp,48
    80004a9c:	8082                	ret
  return -1;
    80004a9e:	557d                	li	a0,-1
    80004aa0:	b7fd                	j	80004a8e <pipealloc+0xc6>

0000000080004aa2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004aa2:	1101                	addi	sp,sp,-32
    80004aa4:	ec06                	sd	ra,24(sp)
    80004aa6:	e822                	sd	s0,16(sp)
    80004aa8:	e426                	sd	s1,8(sp)
    80004aaa:	e04a                	sd	s2,0(sp)
    80004aac:	1000                	addi	s0,sp,32
    80004aae:	84aa                	mv	s1,a0
    80004ab0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ab2:	ffffc097          	auipc	ra,0xffffc
    80004ab6:	11e080e7          	jalr	286(ra) # 80000bd0 <acquire>
  if(writable){
    80004aba:	02090d63          	beqz	s2,80004af4 <pipeclose+0x52>
    pi->writeopen = 0;
    80004abe:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ac2:	21848513          	addi	a0,s1,536
    80004ac6:	ffffd097          	auipc	ra,0xffffd
    80004aca:	758080e7          	jalr	1880(ra) # 8000221e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ace:	2204b783          	ld	a5,544(s1)
    80004ad2:	eb95                	bnez	a5,80004b06 <pipeclose+0x64>
    release(&pi->lock);
    80004ad4:	8526                	mv	a0,s1
    80004ad6:	ffffc097          	auipc	ra,0xffffc
    80004ada:	1ae080e7          	jalr	430(ra) # 80000c84 <release>
    kfree((char*)pi);
    80004ade:	8526                	mv	a0,s1
    80004ae0:	ffffc097          	auipc	ra,0xffffc
    80004ae4:	f02080e7          	jalr	-254(ra) # 800009e2 <kfree>
  } else
    release(&pi->lock);
}
    80004ae8:	60e2                	ld	ra,24(sp)
    80004aea:	6442                	ld	s0,16(sp)
    80004aec:	64a2                	ld	s1,8(sp)
    80004aee:	6902                	ld	s2,0(sp)
    80004af0:	6105                	addi	sp,sp,32
    80004af2:	8082                	ret
    pi->readopen = 0;
    80004af4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004af8:	21c48513          	addi	a0,s1,540
    80004afc:	ffffd097          	auipc	ra,0xffffd
    80004b00:	722080e7          	jalr	1826(ra) # 8000221e <wakeup>
    80004b04:	b7e9                	j	80004ace <pipeclose+0x2c>
    release(&pi->lock);
    80004b06:	8526                	mv	a0,s1
    80004b08:	ffffc097          	auipc	ra,0xffffc
    80004b0c:	17c080e7          	jalr	380(ra) # 80000c84 <release>
}
    80004b10:	bfe1                	j	80004ae8 <pipeclose+0x46>

0000000080004b12 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b12:	711d                	addi	sp,sp,-96
    80004b14:	ec86                	sd	ra,88(sp)
    80004b16:	e8a2                	sd	s0,80(sp)
    80004b18:	e4a6                	sd	s1,72(sp)
    80004b1a:	e0ca                	sd	s2,64(sp)
    80004b1c:	fc4e                	sd	s3,56(sp)
    80004b1e:	f852                	sd	s4,48(sp)
    80004b20:	f456                	sd	s5,40(sp)
    80004b22:	f05a                	sd	s6,32(sp)
    80004b24:	ec5e                	sd	s7,24(sp)
    80004b26:	e862                	sd	s8,16(sp)
    80004b28:	1080                	addi	s0,sp,96
    80004b2a:	84aa                	mv	s1,a0
    80004b2c:	8aae                	mv	s5,a1
    80004b2e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004b30:	ffffd097          	auipc	ra,0xffffd
    80004b34:	e66080e7          	jalr	-410(ra) # 80001996 <myproc>
    80004b38:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	ffffc097          	auipc	ra,0xffffc
    80004b40:	094080e7          	jalr	148(ra) # 80000bd0 <acquire>
  while(i < n){
    80004b44:	0b405363          	blez	s4,80004bea <pipewrite+0xd8>
  int i = 0;
    80004b48:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b4a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004b4c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004b50:	21c48b93          	addi	s7,s1,540
    80004b54:	a089                	j	80004b96 <pipewrite+0x84>
      release(&pi->lock);
    80004b56:	8526                	mv	a0,s1
    80004b58:	ffffc097          	auipc	ra,0xffffc
    80004b5c:	12c080e7          	jalr	300(ra) # 80000c84 <release>
      return -1;
    80004b60:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004b62:	854a                	mv	a0,s2
    80004b64:	60e6                	ld	ra,88(sp)
    80004b66:	6446                	ld	s0,80(sp)
    80004b68:	64a6                	ld	s1,72(sp)
    80004b6a:	6906                	ld	s2,64(sp)
    80004b6c:	79e2                	ld	s3,56(sp)
    80004b6e:	7a42                	ld	s4,48(sp)
    80004b70:	7aa2                	ld	s5,40(sp)
    80004b72:	7b02                	ld	s6,32(sp)
    80004b74:	6be2                	ld	s7,24(sp)
    80004b76:	6c42                	ld	s8,16(sp)
    80004b78:	6125                	addi	sp,sp,96
    80004b7a:	8082                	ret
      wakeup(&pi->nread);
    80004b7c:	8562                	mv	a0,s8
    80004b7e:	ffffd097          	auipc	ra,0xffffd
    80004b82:	6a0080e7          	jalr	1696(ra) # 8000221e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b86:	85a6                	mv	a1,s1
    80004b88:	855e                	mv	a0,s7
    80004b8a:	ffffd097          	auipc	ra,0xffffd
    80004b8e:	508080e7          	jalr	1288(ra) # 80002092 <sleep>
  while(i < n){
    80004b92:	05495d63          	bge	s2,s4,80004bec <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004b96:	2204a783          	lw	a5,544(s1)
    80004b9a:	dfd5                	beqz	a5,80004b56 <pipewrite+0x44>
    80004b9c:	0289a783          	lw	a5,40(s3)
    80004ba0:	fbdd                	bnez	a5,80004b56 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ba2:	2184a783          	lw	a5,536(s1)
    80004ba6:	21c4a703          	lw	a4,540(s1)
    80004baa:	2007879b          	addiw	a5,a5,512
    80004bae:	fcf707e3          	beq	a4,a5,80004b7c <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bb2:	4685                	li	a3,1
    80004bb4:	01590633          	add	a2,s2,s5
    80004bb8:	faf40593          	addi	a1,s0,-81
    80004bbc:	0589b503          	ld	a0,88(s3)
    80004bc0:	ffffd097          	auipc	ra,0xffffd
    80004bc4:	b26080e7          	jalr	-1242(ra) # 800016e6 <copyin>
    80004bc8:	03650263          	beq	a0,s6,80004bec <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004bcc:	21c4a783          	lw	a5,540(s1)
    80004bd0:	0017871b          	addiw	a4,a5,1
    80004bd4:	20e4ae23          	sw	a4,540(s1)
    80004bd8:	1ff7f793          	andi	a5,a5,511
    80004bdc:	97a6                	add	a5,a5,s1
    80004bde:	faf44703          	lbu	a4,-81(s0)
    80004be2:	00e78c23          	sb	a4,24(a5)
      i++;
    80004be6:	2905                	addiw	s2,s2,1
    80004be8:	b76d                	j	80004b92 <pipewrite+0x80>
  int i = 0;
    80004bea:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004bec:	21848513          	addi	a0,s1,536
    80004bf0:	ffffd097          	auipc	ra,0xffffd
    80004bf4:	62e080e7          	jalr	1582(ra) # 8000221e <wakeup>
  release(&pi->lock);
    80004bf8:	8526                	mv	a0,s1
    80004bfa:	ffffc097          	auipc	ra,0xffffc
    80004bfe:	08a080e7          	jalr	138(ra) # 80000c84 <release>
  return i;
    80004c02:	b785                	j	80004b62 <pipewrite+0x50>

0000000080004c04 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c04:	715d                	addi	sp,sp,-80
    80004c06:	e486                	sd	ra,72(sp)
    80004c08:	e0a2                	sd	s0,64(sp)
    80004c0a:	fc26                	sd	s1,56(sp)
    80004c0c:	f84a                	sd	s2,48(sp)
    80004c0e:	f44e                	sd	s3,40(sp)
    80004c10:	f052                	sd	s4,32(sp)
    80004c12:	ec56                	sd	s5,24(sp)
    80004c14:	e85a                	sd	s6,16(sp)
    80004c16:	0880                	addi	s0,sp,80
    80004c18:	84aa                	mv	s1,a0
    80004c1a:	892e                	mv	s2,a1
    80004c1c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c1e:	ffffd097          	auipc	ra,0xffffd
    80004c22:	d78080e7          	jalr	-648(ra) # 80001996 <myproc>
    80004c26:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c28:	8526                	mv	a0,s1
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	fa6080e7          	jalr	-90(ra) # 80000bd0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c32:	2184a703          	lw	a4,536(s1)
    80004c36:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c3a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c3e:	02f71463          	bne	a4,a5,80004c66 <piperead+0x62>
    80004c42:	2244a783          	lw	a5,548(s1)
    80004c46:	c385                	beqz	a5,80004c66 <piperead+0x62>
    if(pr->killed){
    80004c48:	028a2783          	lw	a5,40(s4)
    80004c4c:	ebc9                	bnez	a5,80004cde <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c4e:	85a6                	mv	a1,s1
    80004c50:	854e                	mv	a0,s3
    80004c52:	ffffd097          	auipc	ra,0xffffd
    80004c56:	440080e7          	jalr	1088(ra) # 80002092 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c5a:	2184a703          	lw	a4,536(s1)
    80004c5e:	21c4a783          	lw	a5,540(s1)
    80004c62:	fef700e3          	beq	a4,a5,80004c42 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c66:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c68:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c6a:	05505463          	blez	s5,80004cb2 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80004c6e:	2184a783          	lw	a5,536(s1)
    80004c72:	21c4a703          	lw	a4,540(s1)
    80004c76:	02f70e63          	beq	a4,a5,80004cb2 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c7a:	0017871b          	addiw	a4,a5,1
    80004c7e:	20e4ac23          	sw	a4,536(s1)
    80004c82:	1ff7f793          	andi	a5,a5,511
    80004c86:	97a6                	add	a5,a5,s1
    80004c88:	0187c783          	lbu	a5,24(a5)
    80004c8c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c90:	4685                	li	a3,1
    80004c92:	fbf40613          	addi	a2,s0,-65
    80004c96:	85ca                	mv	a1,s2
    80004c98:	058a3503          	ld	a0,88(s4)
    80004c9c:	ffffd097          	auipc	ra,0xffffd
    80004ca0:	9be080e7          	jalr	-1602(ra) # 8000165a <copyout>
    80004ca4:	01650763          	beq	a0,s6,80004cb2 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ca8:	2985                	addiw	s3,s3,1
    80004caa:	0905                	addi	s2,s2,1
    80004cac:	fd3a91e3          	bne	s5,s3,80004c6e <piperead+0x6a>
    80004cb0:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004cb2:	21c48513          	addi	a0,s1,540
    80004cb6:	ffffd097          	auipc	ra,0xffffd
    80004cba:	568080e7          	jalr	1384(ra) # 8000221e <wakeup>
  release(&pi->lock);
    80004cbe:	8526                	mv	a0,s1
    80004cc0:	ffffc097          	auipc	ra,0xffffc
    80004cc4:	fc4080e7          	jalr	-60(ra) # 80000c84 <release>
  return i;
}
    80004cc8:	854e                	mv	a0,s3
    80004cca:	60a6                	ld	ra,72(sp)
    80004ccc:	6406                	ld	s0,64(sp)
    80004cce:	74e2                	ld	s1,56(sp)
    80004cd0:	7942                	ld	s2,48(sp)
    80004cd2:	79a2                	ld	s3,40(sp)
    80004cd4:	7a02                	ld	s4,32(sp)
    80004cd6:	6ae2                	ld	s5,24(sp)
    80004cd8:	6b42                	ld	s6,16(sp)
    80004cda:	6161                	addi	sp,sp,80
    80004cdc:	8082                	ret
      release(&pi->lock);
    80004cde:	8526                	mv	a0,s1
    80004ce0:	ffffc097          	auipc	ra,0xffffc
    80004ce4:	fa4080e7          	jalr	-92(ra) # 80000c84 <release>
      return -1;
    80004ce8:	59fd                	li	s3,-1
    80004cea:	bff9                	j	80004cc8 <piperead+0xc4>

0000000080004cec <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004cec:	de010113          	addi	sp,sp,-544
    80004cf0:	20113c23          	sd	ra,536(sp)
    80004cf4:	20813823          	sd	s0,528(sp)
    80004cf8:	20913423          	sd	s1,520(sp)
    80004cfc:	21213023          	sd	s2,512(sp)
    80004d00:	ffce                	sd	s3,504(sp)
    80004d02:	fbd2                	sd	s4,496(sp)
    80004d04:	f7d6                	sd	s5,488(sp)
    80004d06:	f3da                	sd	s6,480(sp)
    80004d08:	efde                	sd	s7,472(sp)
    80004d0a:	ebe2                	sd	s8,464(sp)
    80004d0c:	e7e6                	sd	s9,456(sp)
    80004d0e:	e3ea                	sd	s10,448(sp)
    80004d10:	ff6e                	sd	s11,440(sp)
    80004d12:	1400                	addi	s0,sp,544
    80004d14:	892a                	mv	s2,a0
    80004d16:	dea43423          	sd	a0,-536(s0)
    80004d1a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d1e:	ffffd097          	auipc	ra,0xffffd
    80004d22:	c78080e7          	jalr	-904(ra) # 80001996 <myproc>
    80004d26:	84aa                	mv	s1,a0

  begin_op();
    80004d28:	fffff097          	auipc	ra,0xfffff
    80004d2c:	4a8080e7          	jalr	1192(ra) # 800041d0 <begin_op>

  if((ip = namei(path)) == 0){
    80004d30:	854a                	mv	a0,s2
    80004d32:	fffff097          	auipc	ra,0xfffff
    80004d36:	27e080e7          	jalr	638(ra) # 80003fb0 <namei>
    80004d3a:	c93d                	beqz	a0,80004db0 <exec+0xc4>
    80004d3c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d3e:	fffff097          	auipc	ra,0xfffff
    80004d42:	ab6080e7          	jalr	-1354(ra) # 800037f4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d46:	04000713          	li	a4,64
    80004d4a:	4681                	li	a3,0
    80004d4c:	e5040613          	addi	a2,s0,-432
    80004d50:	4581                	li	a1,0
    80004d52:	8556                	mv	a0,s5
    80004d54:	fffff097          	auipc	ra,0xfffff
    80004d58:	d54080e7          	jalr	-684(ra) # 80003aa8 <readi>
    80004d5c:	04000793          	li	a5,64
    80004d60:	00f51a63          	bne	a0,a5,80004d74 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004d64:	e5042703          	lw	a4,-432(s0)
    80004d68:	464c47b7          	lui	a5,0x464c4
    80004d6c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d70:	04f70663          	beq	a4,a5,80004dbc <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d74:	8556                	mv	a0,s5
    80004d76:	fffff097          	auipc	ra,0xfffff
    80004d7a:	ce0080e7          	jalr	-800(ra) # 80003a56 <iunlockput>
    end_op();
    80004d7e:	fffff097          	auipc	ra,0xfffff
    80004d82:	4d0080e7          	jalr	1232(ra) # 8000424e <end_op>
  }
  return -1;
    80004d86:	557d                	li	a0,-1
}
    80004d88:	21813083          	ld	ra,536(sp)
    80004d8c:	21013403          	ld	s0,528(sp)
    80004d90:	20813483          	ld	s1,520(sp)
    80004d94:	20013903          	ld	s2,512(sp)
    80004d98:	79fe                	ld	s3,504(sp)
    80004d9a:	7a5e                	ld	s4,496(sp)
    80004d9c:	7abe                	ld	s5,488(sp)
    80004d9e:	7b1e                	ld	s6,480(sp)
    80004da0:	6bfe                	ld	s7,472(sp)
    80004da2:	6c5e                	ld	s8,464(sp)
    80004da4:	6cbe                	ld	s9,456(sp)
    80004da6:	6d1e                	ld	s10,448(sp)
    80004da8:	7dfa                	ld	s11,440(sp)
    80004daa:	22010113          	addi	sp,sp,544
    80004dae:	8082                	ret
    end_op();
    80004db0:	fffff097          	auipc	ra,0xfffff
    80004db4:	49e080e7          	jalr	1182(ra) # 8000424e <end_op>
    return -1;
    80004db8:	557d                	li	a0,-1
    80004dba:	b7f9                	j	80004d88 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004dbc:	8526                	mv	a0,s1
    80004dbe:	ffffd097          	auipc	ra,0xffffd
    80004dc2:	c9c080e7          	jalr	-868(ra) # 80001a5a <proc_pagetable>
    80004dc6:	8b2a                	mv	s6,a0
    80004dc8:	d555                	beqz	a0,80004d74 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dca:	e7042783          	lw	a5,-400(s0)
    80004dce:	e8845703          	lhu	a4,-376(s0)
    80004dd2:	c735                	beqz	a4,80004e3e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004dd4:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dd6:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004dda:	6a05                	lui	s4,0x1
    80004ddc:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004de0:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004de4:	6d85                	lui	s11,0x1
    80004de6:	7d7d                	lui	s10,0xfffff
    80004de8:	ac1d                	j	8000501e <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004dea:	00004517          	auipc	a0,0x4
    80004dee:	8e650513          	addi	a0,a0,-1818 # 800086d0 <syscalls+0x288>
    80004df2:	ffffb097          	auipc	ra,0xffffb
    80004df6:	748080e7          	jalr	1864(ra) # 8000053a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004dfa:	874a                	mv	a4,s2
    80004dfc:	009c86bb          	addw	a3,s9,s1
    80004e00:	4581                	li	a1,0
    80004e02:	8556                	mv	a0,s5
    80004e04:	fffff097          	auipc	ra,0xfffff
    80004e08:	ca4080e7          	jalr	-860(ra) # 80003aa8 <readi>
    80004e0c:	2501                	sext.w	a0,a0
    80004e0e:	1aa91863          	bne	s2,a0,80004fbe <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004e12:	009d84bb          	addw	s1,s11,s1
    80004e16:	013d09bb          	addw	s3,s10,s3
    80004e1a:	1f74f263          	bgeu	s1,s7,80004ffe <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004e1e:	02049593          	slli	a1,s1,0x20
    80004e22:	9181                	srli	a1,a1,0x20
    80004e24:	95e2                	add	a1,a1,s8
    80004e26:	855a                	mv	a0,s6
    80004e28:	ffffc097          	auipc	ra,0xffffc
    80004e2c:	22a080e7          	jalr	554(ra) # 80001052 <walkaddr>
    80004e30:	862a                	mv	a2,a0
    if(pa == 0)
    80004e32:	dd45                	beqz	a0,80004dea <exec+0xfe>
      n = PGSIZE;
    80004e34:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004e36:	fd49f2e3          	bgeu	s3,s4,80004dfa <exec+0x10e>
      n = sz - i;
    80004e3a:	894e                	mv	s2,s3
    80004e3c:	bf7d                	j	80004dfa <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e3e:	4481                	li	s1,0
  iunlockput(ip);
    80004e40:	8556                	mv	a0,s5
    80004e42:	fffff097          	auipc	ra,0xfffff
    80004e46:	c14080e7          	jalr	-1004(ra) # 80003a56 <iunlockput>
  end_op();
    80004e4a:	fffff097          	auipc	ra,0xfffff
    80004e4e:	404080e7          	jalr	1028(ra) # 8000424e <end_op>
  p = myproc();
    80004e52:	ffffd097          	auipc	ra,0xffffd
    80004e56:	b44080e7          	jalr	-1212(ra) # 80001996 <myproc>
    80004e5a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004e5c:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004e60:	6785                	lui	a5,0x1
    80004e62:	17fd                	addi	a5,a5,-1
    80004e64:	97a6                	add	a5,a5,s1
    80004e66:	777d                	lui	a4,0xfffff
    80004e68:	8ff9                	and	a5,a5,a4
    80004e6a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e6e:	6609                	lui	a2,0x2
    80004e70:	963e                	add	a2,a2,a5
    80004e72:	85be                	mv	a1,a5
    80004e74:	855a                	mv	a0,s6
    80004e76:	ffffc097          	auipc	ra,0xffffc
    80004e7a:	590080e7          	jalr	1424(ra) # 80001406 <uvmalloc>
    80004e7e:	8c2a                	mv	s8,a0
  ip = 0;
    80004e80:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e82:	12050e63          	beqz	a0,80004fbe <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e86:	75f9                	lui	a1,0xffffe
    80004e88:	95aa                	add	a1,a1,a0
    80004e8a:	855a                	mv	a0,s6
    80004e8c:	ffffc097          	auipc	ra,0xffffc
    80004e90:	79c080e7          	jalr	1948(ra) # 80001628 <uvmclear>
  stackbase = sp - PGSIZE;
    80004e94:	7afd                	lui	s5,0xfffff
    80004e96:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e98:	df043783          	ld	a5,-528(s0)
    80004e9c:	6388                	ld	a0,0(a5)
    80004e9e:	c925                	beqz	a0,80004f0e <exec+0x222>
    80004ea0:	e9040993          	addi	s3,s0,-368
    80004ea4:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004ea8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004eaa:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004eac:	ffffc097          	auipc	ra,0xffffc
    80004eb0:	f9c080e7          	jalr	-100(ra) # 80000e48 <strlen>
    80004eb4:	0015079b          	addiw	a5,a0,1
    80004eb8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ebc:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ec0:	13596363          	bltu	s2,s5,80004fe6 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ec4:	df043d83          	ld	s11,-528(s0)
    80004ec8:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004ecc:	8552                	mv	a0,s4
    80004ece:	ffffc097          	auipc	ra,0xffffc
    80004ed2:	f7a080e7          	jalr	-134(ra) # 80000e48 <strlen>
    80004ed6:	0015069b          	addiw	a3,a0,1
    80004eda:	8652                	mv	a2,s4
    80004edc:	85ca                	mv	a1,s2
    80004ede:	855a                	mv	a0,s6
    80004ee0:	ffffc097          	auipc	ra,0xffffc
    80004ee4:	77a080e7          	jalr	1914(ra) # 8000165a <copyout>
    80004ee8:	10054363          	bltz	a0,80004fee <exec+0x302>
    ustack[argc] = sp;
    80004eec:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004ef0:	0485                	addi	s1,s1,1
    80004ef2:	008d8793          	addi	a5,s11,8
    80004ef6:	def43823          	sd	a5,-528(s0)
    80004efa:	008db503          	ld	a0,8(s11)
    80004efe:	c911                	beqz	a0,80004f12 <exec+0x226>
    if(argc >= MAXARG)
    80004f00:	09a1                	addi	s3,s3,8
    80004f02:	fb3c95e3          	bne	s9,s3,80004eac <exec+0x1c0>
  sz = sz1;
    80004f06:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f0a:	4a81                	li	s5,0
    80004f0c:	a84d                	j	80004fbe <exec+0x2d2>
  sp = sz;
    80004f0e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004f10:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f12:	00349793          	slli	a5,s1,0x3
    80004f16:	f9078793          	addi	a5,a5,-112 # f90 <_entry-0x7ffff070>
    80004f1a:	97a2                	add	a5,a5,s0
    80004f1c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f20:	00148693          	addi	a3,s1,1
    80004f24:	068e                	slli	a3,a3,0x3
    80004f26:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f2a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004f2e:	01597663          	bgeu	s2,s5,80004f3a <exec+0x24e>
  sz = sz1;
    80004f32:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f36:	4a81                	li	s5,0
    80004f38:	a059                	j	80004fbe <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f3a:	e9040613          	addi	a2,s0,-368
    80004f3e:	85ca                	mv	a1,s2
    80004f40:	855a                	mv	a0,s6
    80004f42:	ffffc097          	auipc	ra,0xffffc
    80004f46:	718080e7          	jalr	1816(ra) # 8000165a <copyout>
    80004f4a:	0a054663          	bltz	a0,80004ff6 <exec+0x30a>
  p->trapframe->a1 = sp;
    80004f4e:	060bb783          	ld	a5,96(s7)
    80004f52:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f56:	de843783          	ld	a5,-536(s0)
    80004f5a:	0007c703          	lbu	a4,0(a5)
    80004f5e:	cf11                	beqz	a4,80004f7a <exec+0x28e>
    80004f60:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f62:	02f00693          	li	a3,47
    80004f66:	a039                	j	80004f74 <exec+0x288>
      last = s+1;
    80004f68:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004f6c:	0785                	addi	a5,a5,1
    80004f6e:	fff7c703          	lbu	a4,-1(a5)
    80004f72:	c701                	beqz	a4,80004f7a <exec+0x28e>
    if(*s == '/')
    80004f74:	fed71ce3          	bne	a4,a3,80004f6c <exec+0x280>
    80004f78:	bfc5                	j	80004f68 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f7a:	4641                	li	a2,16
    80004f7c:	de843583          	ld	a1,-536(s0)
    80004f80:	160b8513          	addi	a0,s7,352
    80004f84:	ffffc097          	auipc	ra,0xffffc
    80004f88:	e92080e7          	jalr	-366(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f8c:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80004f90:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    80004f94:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f98:	060bb783          	ld	a5,96(s7)
    80004f9c:	e6843703          	ld	a4,-408(s0)
    80004fa0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004fa2:	060bb783          	ld	a5,96(s7)
    80004fa6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004faa:	85ea                	mv	a1,s10
    80004fac:	ffffd097          	auipc	ra,0xffffd
    80004fb0:	b4a080e7          	jalr	-1206(ra) # 80001af6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fb4:	0004851b          	sext.w	a0,s1
    80004fb8:	bbc1                	j	80004d88 <exec+0x9c>
    80004fba:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004fbe:	df843583          	ld	a1,-520(s0)
    80004fc2:	855a                	mv	a0,s6
    80004fc4:	ffffd097          	auipc	ra,0xffffd
    80004fc8:	b32080e7          	jalr	-1230(ra) # 80001af6 <proc_freepagetable>
  if(ip){
    80004fcc:	da0a94e3          	bnez	s5,80004d74 <exec+0x88>
  return -1;
    80004fd0:	557d                	li	a0,-1
    80004fd2:	bb5d                	j	80004d88 <exec+0x9c>
    80004fd4:	de943c23          	sd	s1,-520(s0)
    80004fd8:	b7dd                	j	80004fbe <exec+0x2d2>
    80004fda:	de943c23          	sd	s1,-520(s0)
    80004fde:	b7c5                	j	80004fbe <exec+0x2d2>
    80004fe0:	de943c23          	sd	s1,-520(s0)
    80004fe4:	bfe9                	j	80004fbe <exec+0x2d2>
  sz = sz1;
    80004fe6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004fea:	4a81                	li	s5,0
    80004fec:	bfc9                	j	80004fbe <exec+0x2d2>
  sz = sz1;
    80004fee:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ff2:	4a81                	li	s5,0
    80004ff4:	b7e9                	j	80004fbe <exec+0x2d2>
  sz = sz1;
    80004ff6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ffa:	4a81                	li	s5,0
    80004ffc:	b7c9                	j	80004fbe <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004ffe:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005002:	e0843783          	ld	a5,-504(s0)
    80005006:	0017869b          	addiw	a3,a5,1
    8000500a:	e0d43423          	sd	a3,-504(s0)
    8000500e:	e0043783          	ld	a5,-512(s0)
    80005012:	0387879b          	addiw	a5,a5,56
    80005016:	e8845703          	lhu	a4,-376(s0)
    8000501a:	e2e6d3e3          	bge	a3,a4,80004e40 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000501e:	2781                	sext.w	a5,a5
    80005020:	e0f43023          	sd	a5,-512(s0)
    80005024:	03800713          	li	a4,56
    80005028:	86be                	mv	a3,a5
    8000502a:	e1840613          	addi	a2,s0,-488
    8000502e:	4581                	li	a1,0
    80005030:	8556                	mv	a0,s5
    80005032:	fffff097          	auipc	ra,0xfffff
    80005036:	a76080e7          	jalr	-1418(ra) # 80003aa8 <readi>
    8000503a:	03800793          	li	a5,56
    8000503e:	f6f51ee3          	bne	a0,a5,80004fba <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80005042:	e1842783          	lw	a5,-488(s0)
    80005046:	4705                	li	a4,1
    80005048:	fae79de3          	bne	a5,a4,80005002 <exec+0x316>
    if(ph.memsz < ph.filesz)
    8000504c:	e4043603          	ld	a2,-448(s0)
    80005050:	e3843783          	ld	a5,-456(s0)
    80005054:	f8f660e3          	bltu	a2,a5,80004fd4 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005058:	e2843783          	ld	a5,-472(s0)
    8000505c:	963e                	add	a2,a2,a5
    8000505e:	f6f66ee3          	bltu	a2,a5,80004fda <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005062:	85a6                	mv	a1,s1
    80005064:	855a                	mv	a0,s6
    80005066:	ffffc097          	auipc	ra,0xffffc
    8000506a:	3a0080e7          	jalr	928(ra) # 80001406 <uvmalloc>
    8000506e:	dea43c23          	sd	a0,-520(s0)
    80005072:	d53d                	beqz	a0,80004fe0 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    80005074:	e2843c03          	ld	s8,-472(s0)
    80005078:	de043783          	ld	a5,-544(s0)
    8000507c:	00fc77b3          	and	a5,s8,a5
    80005080:	ff9d                	bnez	a5,80004fbe <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005082:	e2042c83          	lw	s9,-480(s0)
    80005086:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000508a:	f60b8ae3          	beqz	s7,80004ffe <exec+0x312>
    8000508e:	89de                	mv	s3,s7
    80005090:	4481                	li	s1,0
    80005092:	b371                	j	80004e1e <exec+0x132>

0000000080005094 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005094:	7179                	addi	sp,sp,-48
    80005096:	f406                	sd	ra,40(sp)
    80005098:	f022                	sd	s0,32(sp)
    8000509a:	ec26                	sd	s1,24(sp)
    8000509c:	e84a                	sd	s2,16(sp)
    8000509e:	1800                	addi	s0,sp,48
    800050a0:	892e                	mv	s2,a1
    800050a2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800050a4:	fdc40593          	addi	a1,s0,-36
    800050a8:	ffffe097          	auipc	ra,0xffffe
    800050ac:	b76080e7          	jalr	-1162(ra) # 80002c1e <argint>
    800050b0:	04054063          	bltz	a0,800050f0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800050b4:	fdc42703          	lw	a4,-36(s0)
    800050b8:	47bd                	li	a5,15
    800050ba:	02e7ed63          	bltu	a5,a4,800050f4 <argfd+0x60>
    800050be:	ffffd097          	auipc	ra,0xffffd
    800050c2:	8d8080e7          	jalr	-1832(ra) # 80001996 <myproc>
    800050c6:	fdc42703          	lw	a4,-36(s0)
    800050ca:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd901a>
    800050ce:	078e                	slli	a5,a5,0x3
    800050d0:	953e                	add	a0,a0,a5
    800050d2:	651c                	ld	a5,8(a0)
    800050d4:	c395                	beqz	a5,800050f8 <argfd+0x64>
    return -1;
  if(pfd)
    800050d6:	00090463          	beqz	s2,800050de <argfd+0x4a>
    *pfd = fd;
    800050da:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800050de:	4501                	li	a0,0
  if(pf)
    800050e0:	c091                	beqz	s1,800050e4 <argfd+0x50>
    *pf = f;
    800050e2:	e09c                	sd	a5,0(s1)
}
    800050e4:	70a2                	ld	ra,40(sp)
    800050e6:	7402                	ld	s0,32(sp)
    800050e8:	64e2                	ld	s1,24(sp)
    800050ea:	6942                	ld	s2,16(sp)
    800050ec:	6145                	addi	sp,sp,48
    800050ee:	8082                	ret
    return -1;
    800050f0:	557d                	li	a0,-1
    800050f2:	bfcd                	j	800050e4 <argfd+0x50>
    return -1;
    800050f4:	557d                	li	a0,-1
    800050f6:	b7fd                	j	800050e4 <argfd+0x50>
    800050f8:	557d                	li	a0,-1
    800050fa:	b7ed                	j	800050e4 <argfd+0x50>

00000000800050fc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800050fc:	1101                	addi	sp,sp,-32
    800050fe:	ec06                	sd	ra,24(sp)
    80005100:	e822                	sd	s0,16(sp)
    80005102:	e426                	sd	s1,8(sp)
    80005104:	1000                	addi	s0,sp,32
    80005106:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005108:	ffffd097          	auipc	ra,0xffffd
    8000510c:	88e080e7          	jalr	-1906(ra) # 80001996 <myproc>
    80005110:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005112:	0d850793          	addi	a5,a0,216
    80005116:	4501                	li	a0,0
    80005118:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000511a:	6398                	ld	a4,0(a5)
    8000511c:	cb19                	beqz	a4,80005132 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000511e:	2505                	addiw	a0,a0,1
    80005120:	07a1                	addi	a5,a5,8
    80005122:	fed51ce3          	bne	a0,a3,8000511a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005126:	557d                	li	a0,-1
}
    80005128:	60e2                	ld	ra,24(sp)
    8000512a:	6442                	ld	s0,16(sp)
    8000512c:	64a2                	ld	s1,8(sp)
    8000512e:	6105                	addi	sp,sp,32
    80005130:	8082                	ret
      p->ofile[fd] = f;
    80005132:	01a50793          	addi	a5,a0,26
    80005136:	078e                	slli	a5,a5,0x3
    80005138:	963e                	add	a2,a2,a5
    8000513a:	e604                	sd	s1,8(a2)
      return fd;
    8000513c:	b7f5                	j	80005128 <fdalloc+0x2c>

000000008000513e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000513e:	715d                	addi	sp,sp,-80
    80005140:	e486                	sd	ra,72(sp)
    80005142:	e0a2                	sd	s0,64(sp)
    80005144:	fc26                	sd	s1,56(sp)
    80005146:	f84a                	sd	s2,48(sp)
    80005148:	f44e                	sd	s3,40(sp)
    8000514a:	f052                	sd	s4,32(sp)
    8000514c:	ec56                	sd	s5,24(sp)
    8000514e:	0880                	addi	s0,sp,80
    80005150:	89ae                	mv	s3,a1
    80005152:	8ab2                	mv	s5,a2
    80005154:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005156:	fb040593          	addi	a1,s0,-80
    8000515a:	fffff097          	auipc	ra,0xfffff
    8000515e:	e74080e7          	jalr	-396(ra) # 80003fce <nameiparent>
    80005162:	892a                	mv	s2,a0
    80005164:	12050e63          	beqz	a0,800052a0 <create+0x162>
    return 0;

  ilock(dp);
    80005168:	ffffe097          	auipc	ra,0xffffe
    8000516c:	68c080e7          	jalr	1676(ra) # 800037f4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005170:	4601                	li	a2,0
    80005172:	fb040593          	addi	a1,s0,-80
    80005176:	854a                	mv	a0,s2
    80005178:	fffff097          	auipc	ra,0xfffff
    8000517c:	b60080e7          	jalr	-1184(ra) # 80003cd8 <dirlookup>
    80005180:	84aa                	mv	s1,a0
    80005182:	c921                	beqz	a0,800051d2 <create+0x94>
    iunlockput(dp);
    80005184:	854a                	mv	a0,s2
    80005186:	fffff097          	auipc	ra,0xfffff
    8000518a:	8d0080e7          	jalr	-1840(ra) # 80003a56 <iunlockput>
    ilock(ip);
    8000518e:	8526                	mv	a0,s1
    80005190:	ffffe097          	auipc	ra,0xffffe
    80005194:	664080e7          	jalr	1636(ra) # 800037f4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005198:	2981                	sext.w	s3,s3
    8000519a:	4789                	li	a5,2
    8000519c:	02f99463          	bne	s3,a5,800051c4 <create+0x86>
    800051a0:	0444d783          	lhu	a5,68(s1)
    800051a4:	37f9                	addiw	a5,a5,-2
    800051a6:	17c2                	slli	a5,a5,0x30
    800051a8:	93c1                	srli	a5,a5,0x30
    800051aa:	4705                	li	a4,1
    800051ac:	00f76c63          	bltu	a4,a5,800051c4 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800051b0:	8526                	mv	a0,s1
    800051b2:	60a6                	ld	ra,72(sp)
    800051b4:	6406                	ld	s0,64(sp)
    800051b6:	74e2                	ld	s1,56(sp)
    800051b8:	7942                	ld	s2,48(sp)
    800051ba:	79a2                	ld	s3,40(sp)
    800051bc:	7a02                	ld	s4,32(sp)
    800051be:	6ae2                	ld	s5,24(sp)
    800051c0:	6161                	addi	sp,sp,80
    800051c2:	8082                	ret
    iunlockput(ip);
    800051c4:	8526                	mv	a0,s1
    800051c6:	fffff097          	auipc	ra,0xfffff
    800051ca:	890080e7          	jalr	-1904(ra) # 80003a56 <iunlockput>
    return 0;
    800051ce:	4481                	li	s1,0
    800051d0:	b7c5                	j	800051b0 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800051d2:	85ce                	mv	a1,s3
    800051d4:	00092503          	lw	a0,0(s2)
    800051d8:	ffffe097          	auipc	ra,0xffffe
    800051dc:	482080e7          	jalr	1154(ra) # 8000365a <ialloc>
    800051e0:	84aa                	mv	s1,a0
    800051e2:	c521                	beqz	a0,8000522a <create+0xec>
  ilock(ip);
    800051e4:	ffffe097          	auipc	ra,0xffffe
    800051e8:	610080e7          	jalr	1552(ra) # 800037f4 <ilock>
  ip->major = major;
    800051ec:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800051f0:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800051f4:	4a05                	li	s4,1
    800051f6:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800051fa:	8526                	mv	a0,s1
    800051fc:	ffffe097          	auipc	ra,0xffffe
    80005200:	52c080e7          	jalr	1324(ra) # 80003728 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005204:	2981                	sext.w	s3,s3
    80005206:	03498a63          	beq	s3,s4,8000523a <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000520a:	40d0                	lw	a2,4(s1)
    8000520c:	fb040593          	addi	a1,s0,-80
    80005210:	854a                	mv	a0,s2
    80005212:	fffff097          	auipc	ra,0xfffff
    80005216:	cdc080e7          	jalr	-804(ra) # 80003eee <dirlink>
    8000521a:	06054b63          	bltz	a0,80005290 <create+0x152>
  iunlockput(dp);
    8000521e:	854a                	mv	a0,s2
    80005220:	fffff097          	auipc	ra,0xfffff
    80005224:	836080e7          	jalr	-1994(ra) # 80003a56 <iunlockput>
  return ip;
    80005228:	b761                	j	800051b0 <create+0x72>
    panic("create: ialloc");
    8000522a:	00003517          	auipc	a0,0x3
    8000522e:	4c650513          	addi	a0,a0,1222 # 800086f0 <syscalls+0x2a8>
    80005232:	ffffb097          	auipc	ra,0xffffb
    80005236:	308080e7          	jalr	776(ra) # 8000053a <panic>
    dp->nlink++;  // for ".."
    8000523a:	04a95783          	lhu	a5,74(s2)
    8000523e:	2785                	addiw	a5,a5,1
    80005240:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005244:	854a                	mv	a0,s2
    80005246:	ffffe097          	auipc	ra,0xffffe
    8000524a:	4e2080e7          	jalr	1250(ra) # 80003728 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000524e:	40d0                	lw	a2,4(s1)
    80005250:	00003597          	auipc	a1,0x3
    80005254:	4b058593          	addi	a1,a1,1200 # 80008700 <syscalls+0x2b8>
    80005258:	8526                	mv	a0,s1
    8000525a:	fffff097          	auipc	ra,0xfffff
    8000525e:	c94080e7          	jalr	-876(ra) # 80003eee <dirlink>
    80005262:	00054f63          	bltz	a0,80005280 <create+0x142>
    80005266:	00492603          	lw	a2,4(s2)
    8000526a:	00003597          	auipc	a1,0x3
    8000526e:	49e58593          	addi	a1,a1,1182 # 80008708 <syscalls+0x2c0>
    80005272:	8526                	mv	a0,s1
    80005274:	fffff097          	auipc	ra,0xfffff
    80005278:	c7a080e7          	jalr	-902(ra) # 80003eee <dirlink>
    8000527c:	f80557e3          	bgez	a0,8000520a <create+0xcc>
      panic("create dots");
    80005280:	00003517          	auipc	a0,0x3
    80005284:	49050513          	addi	a0,a0,1168 # 80008710 <syscalls+0x2c8>
    80005288:	ffffb097          	auipc	ra,0xffffb
    8000528c:	2b2080e7          	jalr	690(ra) # 8000053a <panic>
    panic("create: dirlink");
    80005290:	00003517          	auipc	a0,0x3
    80005294:	49050513          	addi	a0,a0,1168 # 80008720 <syscalls+0x2d8>
    80005298:	ffffb097          	auipc	ra,0xffffb
    8000529c:	2a2080e7          	jalr	674(ra) # 8000053a <panic>
    return 0;
    800052a0:	84aa                	mv	s1,a0
    800052a2:	b739                	j	800051b0 <create+0x72>

00000000800052a4 <sys_dup>:
{
    800052a4:	7179                	addi	sp,sp,-48
    800052a6:	f406                	sd	ra,40(sp)
    800052a8:	f022                	sd	s0,32(sp)
    800052aa:	ec26                	sd	s1,24(sp)
    800052ac:	e84a                	sd	s2,16(sp)
    800052ae:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800052b0:	fd840613          	addi	a2,s0,-40
    800052b4:	4581                	li	a1,0
    800052b6:	4501                	li	a0,0
    800052b8:	00000097          	auipc	ra,0x0
    800052bc:	ddc080e7          	jalr	-548(ra) # 80005094 <argfd>
    return -1;
    800052c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800052c2:	02054363          	bltz	a0,800052e8 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800052c6:	fd843903          	ld	s2,-40(s0)
    800052ca:	854a                	mv	a0,s2
    800052cc:	00000097          	auipc	ra,0x0
    800052d0:	e30080e7          	jalr	-464(ra) # 800050fc <fdalloc>
    800052d4:	84aa                	mv	s1,a0
    return -1;
    800052d6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800052d8:	00054863          	bltz	a0,800052e8 <sys_dup+0x44>
  filedup(f);
    800052dc:	854a                	mv	a0,s2
    800052de:	fffff097          	auipc	ra,0xfffff
    800052e2:	368080e7          	jalr	872(ra) # 80004646 <filedup>
  return fd;
    800052e6:	87a6                	mv	a5,s1
}
    800052e8:	853e                	mv	a0,a5
    800052ea:	70a2                	ld	ra,40(sp)
    800052ec:	7402                	ld	s0,32(sp)
    800052ee:	64e2                	ld	s1,24(sp)
    800052f0:	6942                	ld	s2,16(sp)
    800052f2:	6145                	addi	sp,sp,48
    800052f4:	8082                	ret

00000000800052f6 <sys_read>:
{
    800052f6:	7179                	addi	sp,sp,-48
    800052f8:	f406                	sd	ra,40(sp)
    800052fa:	f022                	sd	s0,32(sp)
    800052fc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052fe:	fe840613          	addi	a2,s0,-24
    80005302:	4581                	li	a1,0
    80005304:	4501                	li	a0,0
    80005306:	00000097          	auipc	ra,0x0
    8000530a:	d8e080e7          	jalr	-626(ra) # 80005094 <argfd>
    return -1;
    8000530e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005310:	04054163          	bltz	a0,80005352 <sys_read+0x5c>
    80005314:	fe440593          	addi	a1,s0,-28
    80005318:	4509                	li	a0,2
    8000531a:	ffffe097          	auipc	ra,0xffffe
    8000531e:	904080e7          	jalr	-1788(ra) # 80002c1e <argint>
    return -1;
    80005322:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005324:	02054763          	bltz	a0,80005352 <sys_read+0x5c>
    80005328:	fd840593          	addi	a1,s0,-40
    8000532c:	4505                	li	a0,1
    8000532e:	ffffe097          	auipc	ra,0xffffe
    80005332:	912080e7          	jalr	-1774(ra) # 80002c40 <argaddr>
    return -1;
    80005336:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005338:	00054d63          	bltz	a0,80005352 <sys_read+0x5c>
  return fileread(f, p, n);
    8000533c:	fe442603          	lw	a2,-28(s0)
    80005340:	fd843583          	ld	a1,-40(s0)
    80005344:	fe843503          	ld	a0,-24(s0)
    80005348:	fffff097          	auipc	ra,0xfffff
    8000534c:	48a080e7          	jalr	1162(ra) # 800047d2 <fileread>
    80005350:	87aa                	mv	a5,a0
}
    80005352:	853e                	mv	a0,a5
    80005354:	70a2                	ld	ra,40(sp)
    80005356:	7402                	ld	s0,32(sp)
    80005358:	6145                	addi	sp,sp,48
    8000535a:	8082                	ret

000000008000535c <sys_write>:
{
    8000535c:	7179                	addi	sp,sp,-48
    8000535e:	f406                	sd	ra,40(sp)
    80005360:	f022                	sd	s0,32(sp)
    80005362:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005364:	fe840613          	addi	a2,s0,-24
    80005368:	4581                	li	a1,0
    8000536a:	4501                	li	a0,0
    8000536c:	00000097          	auipc	ra,0x0
    80005370:	d28080e7          	jalr	-728(ra) # 80005094 <argfd>
    return -1;
    80005374:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005376:	04054163          	bltz	a0,800053b8 <sys_write+0x5c>
    8000537a:	fe440593          	addi	a1,s0,-28
    8000537e:	4509                	li	a0,2
    80005380:	ffffe097          	auipc	ra,0xffffe
    80005384:	89e080e7          	jalr	-1890(ra) # 80002c1e <argint>
    return -1;
    80005388:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000538a:	02054763          	bltz	a0,800053b8 <sys_write+0x5c>
    8000538e:	fd840593          	addi	a1,s0,-40
    80005392:	4505                	li	a0,1
    80005394:	ffffe097          	auipc	ra,0xffffe
    80005398:	8ac080e7          	jalr	-1876(ra) # 80002c40 <argaddr>
    return -1;
    8000539c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000539e:	00054d63          	bltz	a0,800053b8 <sys_write+0x5c>
  return filewrite(f, p, n);
    800053a2:	fe442603          	lw	a2,-28(s0)
    800053a6:	fd843583          	ld	a1,-40(s0)
    800053aa:	fe843503          	ld	a0,-24(s0)
    800053ae:	fffff097          	auipc	ra,0xfffff
    800053b2:	4e6080e7          	jalr	1254(ra) # 80004894 <filewrite>
    800053b6:	87aa                	mv	a5,a0
}
    800053b8:	853e                	mv	a0,a5
    800053ba:	70a2                	ld	ra,40(sp)
    800053bc:	7402                	ld	s0,32(sp)
    800053be:	6145                	addi	sp,sp,48
    800053c0:	8082                	ret

00000000800053c2 <sys_close>:
{
    800053c2:	1101                	addi	sp,sp,-32
    800053c4:	ec06                	sd	ra,24(sp)
    800053c6:	e822                	sd	s0,16(sp)
    800053c8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800053ca:	fe040613          	addi	a2,s0,-32
    800053ce:	fec40593          	addi	a1,s0,-20
    800053d2:	4501                	li	a0,0
    800053d4:	00000097          	auipc	ra,0x0
    800053d8:	cc0080e7          	jalr	-832(ra) # 80005094 <argfd>
    return -1;
    800053dc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800053de:	02054463          	bltz	a0,80005406 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800053e2:	ffffc097          	auipc	ra,0xffffc
    800053e6:	5b4080e7          	jalr	1460(ra) # 80001996 <myproc>
    800053ea:	fec42783          	lw	a5,-20(s0)
    800053ee:	07e9                	addi	a5,a5,26
    800053f0:	078e                	slli	a5,a5,0x3
    800053f2:	953e                	add	a0,a0,a5
    800053f4:	00053423          	sd	zero,8(a0)
  fileclose(f);
    800053f8:	fe043503          	ld	a0,-32(s0)
    800053fc:	fffff097          	auipc	ra,0xfffff
    80005400:	29c080e7          	jalr	668(ra) # 80004698 <fileclose>
  return 0;
    80005404:	4781                	li	a5,0
}
    80005406:	853e                	mv	a0,a5
    80005408:	60e2                	ld	ra,24(sp)
    8000540a:	6442                	ld	s0,16(sp)
    8000540c:	6105                	addi	sp,sp,32
    8000540e:	8082                	ret

0000000080005410 <sys_fstat>:
{
    80005410:	1101                	addi	sp,sp,-32
    80005412:	ec06                	sd	ra,24(sp)
    80005414:	e822                	sd	s0,16(sp)
    80005416:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005418:	fe840613          	addi	a2,s0,-24
    8000541c:	4581                	li	a1,0
    8000541e:	4501                	li	a0,0
    80005420:	00000097          	auipc	ra,0x0
    80005424:	c74080e7          	jalr	-908(ra) # 80005094 <argfd>
    return -1;
    80005428:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000542a:	02054563          	bltz	a0,80005454 <sys_fstat+0x44>
    8000542e:	fe040593          	addi	a1,s0,-32
    80005432:	4505                	li	a0,1
    80005434:	ffffe097          	auipc	ra,0xffffe
    80005438:	80c080e7          	jalr	-2036(ra) # 80002c40 <argaddr>
    return -1;
    8000543c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000543e:	00054b63          	bltz	a0,80005454 <sys_fstat+0x44>
  return filestat(f, st);
    80005442:	fe043583          	ld	a1,-32(s0)
    80005446:	fe843503          	ld	a0,-24(s0)
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	316080e7          	jalr	790(ra) # 80004760 <filestat>
    80005452:	87aa                	mv	a5,a0
}
    80005454:	853e                	mv	a0,a5
    80005456:	60e2                	ld	ra,24(sp)
    80005458:	6442                	ld	s0,16(sp)
    8000545a:	6105                	addi	sp,sp,32
    8000545c:	8082                	ret

000000008000545e <sys_link>:
{
    8000545e:	7169                	addi	sp,sp,-304
    80005460:	f606                	sd	ra,296(sp)
    80005462:	f222                	sd	s0,288(sp)
    80005464:	ee26                	sd	s1,280(sp)
    80005466:	ea4a                	sd	s2,272(sp)
    80005468:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000546a:	08000613          	li	a2,128
    8000546e:	ed040593          	addi	a1,s0,-304
    80005472:	4501                	li	a0,0
    80005474:	ffffd097          	auipc	ra,0xffffd
    80005478:	7ee080e7          	jalr	2030(ra) # 80002c62 <argstr>
    return -1;
    8000547c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000547e:	10054e63          	bltz	a0,8000559a <sys_link+0x13c>
    80005482:	08000613          	li	a2,128
    80005486:	f5040593          	addi	a1,s0,-176
    8000548a:	4505                	li	a0,1
    8000548c:	ffffd097          	auipc	ra,0xffffd
    80005490:	7d6080e7          	jalr	2006(ra) # 80002c62 <argstr>
    return -1;
    80005494:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005496:	10054263          	bltz	a0,8000559a <sys_link+0x13c>
  begin_op();
    8000549a:	fffff097          	auipc	ra,0xfffff
    8000549e:	d36080e7          	jalr	-714(ra) # 800041d0 <begin_op>
  if((ip = namei(old)) == 0){
    800054a2:	ed040513          	addi	a0,s0,-304
    800054a6:	fffff097          	auipc	ra,0xfffff
    800054aa:	b0a080e7          	jalr	-1270(ra) # 80003fb0 <namei>
    800054ae:	84aa                	mv	s1,a0
    800054b0:	c551                	beqz	a0,8000553c <sys_link+0xde>
  ilock(ip);
    800054b2:	ffffe097          	auipc	ra,0xffffe
    800054b6:	342080e7          	jalr	834(ra) # 800037f4 <ilock>
  if(ip->type == T_DIR){
    800054ba:	04449703          	lh	a4,68(s1)
    800054be:	4785                	li	a5,1
    800054c0:	08f70463          	beq	a4,a5,80005548 <sys_link+0xea>
  ip->nlink++;
    800054c4:	04a4d783          	lhu	a5,74(s1)
    800054c8:	2785                	addiw	a5,a5,1
    800054ca:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054ce:	8526                	mv	a0,s1
    800054d0:	ffffe097          	auipc	ra,0xffffe
    800054d4:	258080e7          	jalr	600(ra) # 80003728 <iupdate>
  iunlock(ip);
    800054d8:	8526                	mv	a0,s1
    800054da:	ffffe097          	auipc	ra,0xffffe
    800054de:	3dc080e7          	jalr	988(ra) # 800038b6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800054e2:	fd040593          	addi	a1,s0,-48
    800054e6:	f5040513          	addi	a0,s0,-176
    800054ea:	fffff097          	auipc	ra,0xfffff
    800054ee:	ae4080e7          	jalr	-1308(ra) # 80003fce <nameiparent>
    800054f2:	892a                	mv	s2,a0
    800054f4:	c935                	beqz	a0,80005568 <sys_link+0x10a>
  ilock(dp);
    800054f6:	ffffe097          	auipc	ra,0xffffe
    800054fa:	2fe080e7          	jalr	766(ra) # 800037f4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800054fe:	00092703          	lw	a4,0(s2)
    80005502:	409c                	lw	a5,0(s1)
    80005504:	04f71d63          	bne	a4,a5,8000555e <sys_link+0x100>
    80005508:	40d0                	lw	a2,4(s1)
    8000550a:	fd040593          	addi	a1,s0,-48
    8000550e:	854a                	mv	a0,s2
    80005510:	fffff097          	auipc	ra,0xfffff
    80005514:	9de080e7          	jalr	-1570(ra) # 80003eee <dirlink>
    80005518:	04054363          	bltz	a0,8000555e <sys_link+0x100>
  iunlockput(dp);
    8000551c:	854a                	mv	a0,s2
    8000551e:	ffffe097          	auipc	ra,0xffffe
    80005522:	538080e7          	jalr	1336(ra) # 80003a56 <iunlockput>
  iput(ip);
    80005526:	8526                	mv	a0,s1
    80005528:	ffffe097          	auipc	ra,0xffffe
    8000552c:	486080e7          	jalr	1158(ra) # 800039ae <iput>
  end_op();
    80005530:	fffff097          	auipc	ra,0xfffff
    80005534:	d1e080e7          	jalr	-738(ra) # 8000424e <end_op>
  return 0;
    80005538:	4781                	li	a5,0
    8000553a:	a085                	j	8000559a <sys_link+0x13c>
    end_op();
    8000553c:	fffff097          	auipc	ra,0xfffff
    80005540:	d12080e7          	jalr	-750(ra) # 8000424e <end_op>
    return -1;
    80005544:	57fd                	li	a5,-1
    80005546:	a891                	j	8000559a <sys_link+0x13c>
    iunlockput(ip);
    80005548:	8526                	mv	a0,s1
    8000554a:	ffffe097          	auipc	ra,0xffffe
    8000554e:	50c080e7          	jalr	1292(ra) # 80003a56 <iunlockput>
    end_op();
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	cfc080e7          	jalr	-772(ra) # 8000424e <end_op>
    return -1;
    8000555a:	57fd                	li	a5,-1
    8000555c:	a83d                	j	8000559a <sys_link+0x13c>
    iunlockput(dp);
    8000555e:	854a                	mv	a0,s2
    80005560:	ffffe097          	auipc	ra,0xffffe
    80005564:	4f6080e7          	jalr	1270(ra) # 80003a56 <iunlockput>
  ilock(ip);
    80005568:	8526                	mv	a0,s1
    8000556a:	ffffe097          	auipc	ra,0xffffe
    8000556e:	28a080e7          	jalr	650(ra) # 800037f4 <ilock>
  ip->nlink--;
    80005572:	04a4d783          	lhu	a5,74(s1)
    80005576:	37fd                	addiw	a5,a5,-1
    80005578:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000557c:	8526                	mv	a0,s1
    8000557e:	ffffe097          	auipc	ra,0xffffe
    80005582:	1aa080e7          	jalr	426(ra) # 80003728 <iupdate>
  iunlockput(ip);
    80005586:	8526                	mv	a0,s1
    80005588:	ffffe097          	auipc	ra,0xffffe
    8000558c:	4ce080e7          	jalr	1230(ra) # 80003a56 <iunlockput>
  end_op();
    80005590:	fffff097          	auipc	ra,0xfffff
    80005594:	cbe080e7          	jalr	-834(ra) # 8000424e <end_op>
  return -1;
    80005598:	57fd                	li	a5,-1
}
    8000559a:	853e                	mv	a0,a5
    8000559c:	70b2                	ld	ra,296(sp)
    8000559e:	7412                	ld	s0,288(sp)
    800055a0:	64f2                	ld	s1,280(sp)
    800055a2:	6952                	ld	s2,272(sp)
    800055a4:	6155                	addi	sp,sp,304
    800055a6:	8082                	ret

00000000800055a8 <sys_unlink>:
{
    800055a8:	7151                	addi	sp,sp,-240
    800055aa:	f586                	sd	ra,232(sp)
    800055ac:	f1a2                	sd	s0,224(sp)
    800055ae:	eda6                	sd	s1,216(sp)
    800055b0:	e9ca                	sd	s2,208(sp)
    800055b2:	e5ce                	sd	s3,200(sp)
    800055b4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800055b6:	08000613          	li	a2,128
    800055ba:	f3040593          	addi	a1,s0,-208
    800055be:	4501                	li	a0,0
    800055c0:	ffffd097          	auipc	ra,0xffffd
    800055c4:	6a2080e7          	jalr	1698(ra) # 80002c62 <argstr>
    800055c8:	18054163          	bltz	a0,8000574a <sys_unlink+0x1a2>
  begin_op();
    800055cc:	fffff097          	auipc	ra,0xfffff
    800055d0:	c04080e7          	jalr	-1020(ra) # 800041d0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800055d4:	fb040593          	addi	a1,s0,-80
    800055d8:	f3040513          	addi	a0,s0,-208
    800055dc:	fffff097          	auipc	ra,0xfffff
    800055e0:	9f2080e7          	jalr	-1550(ra) # 80003fce <nameiparent>
    800055e4:	84aa                	mv	s1,a0
    800055e6:	c979                	beqz	a0,800056bc <sys_unlink+0x114>
  ilock(dp);
    800055e8:	ffffe097          	auipc	ra,0xffffe
    800055ec:	20c080e7          	jalr	524(ra) # 800037f4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800055f0:	00003597          	auipc	a1,0x3
    800055f4:	11058593          	addi	a1,a1,272 # 80008700 <syscalls+0x2b8>
    800055f8:	fb040513          	addi	a0,s0,-80
    800055fc:	ffffe097          	auipc	ra,0xffffe
    80005600:	6c2080e7          	jalr	1730(ra) # 80003cbe <namecmp>
    80005604:	14050a63          	beqz	a0,80005758 <sys_unlink+0x1b0>
    80005608:	00003597          	auipc	a1,0x3
    8000560c:	10058593          	addi	a1,a1,256 # 80008708 <syscalls+0x2c0>
    80005610:	fb040513          	addi	a0,s0,-80
    80005614:	ffffe097          	auipc	ra,0xffffe
    80005618:	6aa080e7          	jalr	1706(ra) # 80003cbe <namecmp>
    8000561c:	12050e63          	beqz	a0,80005758 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005620:	f2c40613          	addi	a2,s0,-212
    80005624:	fb040593          	addi	a1,s0,-80
    80005628:	8526                	mv	a0,s1
    8000562a:	ffffe097          	auipc	ra,0xffffe
    8000562e:	6ae080e7          	jalr	1710(ra) # 80003cd8 <dirlookup>
    80005632:	892a                	mv	s2,a0
    80005634:	12050263          	beqz	a0,80005758 <sys_unlink+0x1b0>
  ilock(ip);
    80005638:	ffffe097          	auipc	ra,0xffffe
    8000563c:	1bc080e7          	jalr	444(ra) # 800037f4 <ilock>
  if(ip->nlink < 1)
    80005640:	04a91783          	lh	a5,74(s2)
    80005644:	08f05263          	blez	a5,800056c8 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005648:	04491703          	lh	a4,68(s2)
    8000564c:	4785                	li	a5,1
    8000564e:	08f70563          	beq	a4,a5,800056d8 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005652:	4641                	li	a2,16
    80005654:	4581                	li	a1,0
    80005656:	fc040513          	addi	a0,s0,-64
    8000565a:	ffffb097          	auipc	ra,0xffffb
    8000565e:	672080e7          	jalr	1650(ra) # 80000ccc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005662:	4741                	li	a4,16
    80005664:	f2c42683          	lw	a3,-212(s0)
    80005668:	fc040613          	addi	a2,s0,-64
    8000566c:	4581                	li	a1,0
    8000566e:	8526                	mv	a0,s1
    80005670:	ffffe097          	auipc	ra,0xffffe
    80005674:	530080e7          	jalr	1328(ra) # 80003ba0 <writei>
    80005678:	47c1                	li	a5,16
    8000567a:	0af51563          	bne	a0,a5,80005724 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000567e:	04491703          	lh	a4,68(s2)
    80005682:	4785                	li	a5,1
    80005684:	0af70863          	beq	a4,a5,80005734 <sys_unlink+0x18c>
  iunlockput(dp);
    80005688:	8526                	mv	a0,s1
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	3cc080e7          	jalr	972(ra) # 80003a56 <iunlockput>
  ip->nlink--;
    80005692:	04a95783          	lhu	a5,74(s2)
    80005696:	37fd                	addiw	a5,a5,-1
    80005698:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000569c:	854a                	mv	a0,s2
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	08a080e7          	jalr	138(ra) # 80003728 <iupdate>
  iunlockput(ip);
    800056a6:	854a                	mv	a0,s2
    800056a8:	ffffe097          	auipc	ra,0xffffe
    800056ac:	3ae080e7          	jalr	942(ra) # 80003a56 <iunlockput>
  end_op();
    800056b0:	fffff097          	auipc	ra,0xfffff
    800056b4:	b9e080e7          	jalr	-1122(ra) # 8000424e <end_op>
  return 0;
    800056b8:	4501                	li	a0,0
    800056ba:	a84d                	j	8000576c <sys_unlink+0x1c4>
    end_op();
    800056bc:	fffff097          	auipc	ra,0xfffff
    800056c0:	b92080e7          	jalr	-1134(ra) # 8000424e <end_op>
    return -1;
    800056c4:	557d                	li	a0,-1
    800056c6:	a05d                	j	8000576c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800056c8:	00003517          	auipc	a0,0x3
    800056cc:	06850513          	addi	a0,a0,104 # 80008730 <syscalls+0x2e8>
    800056d0:	ffffb097          	auipc	ra,0xffffb
    800056d4:	e6a080e7          	jalr	-406(ra) # 8000053a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056d8:	04c92703          	lw	a4,76(s2)
    800056dc:	02000793          	li	a5,32
    800056e0:	f6e7f9e3          	bgeu	a5,a4,80005652 <sys_unlink+0xaa>
    800056e4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056e8:	4741                	li	a4,16
    800056ea:	86ce                	mv	a3,s3
    800056ec:	f1840613          	addi	a2,s0,-232
    800056f0:	4581                	li	a1,0
    800056f2:	854a                	mv	a0,s2
    800056f4:	ffffe097          	auipc	ra,0xffffe
    800056f8:	3b4080e7          	jalr	948(ra) # 80003aa8 <readi>
    800056fc:	47c1                	li	a5,16
    800056fe:	00f51b63          	bne	a0,a5,80005714 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005702:	f1845783          	lhu	a5,-232(s0)
    80005706:	e7a1                	bnez	a5,8000574e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005708:	29c1                	addiw	s3,s3,16
    8000570a:	04c92783          	lw	a5,76(s2)
    8000570e:	fcf9ede3          	bltu	s3,a5,800056e8 <sys_unlink+0x140>
    80005712:	b781                	j	80005652 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005714:	00003517          	auipc	a0,0x3
    80005718:	03450513          	addi	a0,a0,52 # 80008748 <syscalls+0x300>
    8000571c:	ffffb097          	auipc	ra,0xffffb
    80005720:	e1e080e7          	jalr	-482(ra) # 8000053a <panic>
    panic("unlink: writei");
    80005724:	00003517          	auipc	a0,0x3
    80005728:	03c50513          	addi	a0,a0,60 # 80008760 <syscalls+0x318>
    8000572c:	ffffb097          	auipc	ra,0xffffb
    80005730:	e0e080e7          	jalr	-498(ra) # 8000053a <panic>
    dp->nlink--;
    80005734:	04a4d783          	lhu	a5,74(s1)
    80005738:	37fd                	addiw	a5,a5,-1
    8000573a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000573e:	8526                	mv	a0,s1
    80005740:	ffffe097          	auipc	ra,0xffffe
    80005744:	fe8080e7          	jalr	-24(ra) # 80003728 <iupdate>
    80005748:	b781                	j	80005688 <sys_unlink+0xe0>
    return -1;
    8000574a:	557d                	li	a0,-1
    8000574c:	a005                	j	8000576c <sys_unlink+0x1c4>
    iunlockput(ip);
    8000574e:	854a                	mv	a0,s2
    80005750:	ffffe097          	auipc	ra,0xffffe
    80005754:	306080e7          	jalr	774(ra) # 80003a56 <iunlockput>
  iunlockput(dp);
    80005758:	8526                	mv	a0,s1
    8000575a:	ffffe097          	auipc	ra,0xffffe
    8000575e:	2fc080e7          	jalr	764(ra) # 80003a56 <iunlockput>
  end_op();
    80005762:	fffff097          	auipc	ra,0xfffff
    80005766:	aec080e7          	jalr	-1300(ra) # 8000424e <end_op>
  return -1;
    8000576a:	557d                	li	a0,-1
}
    8000576c:	70ae                	ld	ra,232(sp)
    8000576e:	740e                	ld	s0,224(sp)
    80005770:	64ee                	ld	s1,216(sp)
    80005772:	694e                	ld	s2,208(sp)
    80005774:	69ae                	ld	s3,200(sp)
    80005776:	616d                	addi	sp,sp,240
    80005778:	8082                	ret

000000008000577a <sys_open>:

uint64
sys_open(void)
{
    8000577a:	7131                	addi	sp,sp,-192
    8000577c:	fd06                	sd	ra,184(sp)
    8000577e:	f922                	sd	s0,176(sp)
    80005780:	f526                	sd	s1,168(sp)
    80005782:	f14a                	sd	s2,160(sp)
    80005784:	ed4e                	sd	s3,152(sp)
    80005786:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005788:	08000613          	li	a2,128
    8000578c:	f5040593          	addi	a1,s0,-176
    80005790:	4501                	li	a0,0
    80005792:	ffffd097          	auipc	ra,0xffffd
    80005796:	4d0080e7          	jalr	1232(ra) # 80002c62 <argstr>
    return -1;
    8000579a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000579c:	0c054163          	bltz	a0,8000585e <sys_open+0xe4>
    800057a0:	f4c40593          	addi	a1,s0,-180
    800057a4:	4505                	li	a0,1
    800057a6:	ffffd097          	auipc	ra,0xffffd
    800057aa:	478080e7          	jalr	1144(ra) # 80002c1e <argint>
    800057ae:	0a054863          	bltz	a0,8000585e <sys_open+0xe4>

  begin_op();
    800057b2:	fffff097          	auipc	ra,0xfffff
    800057b6:	a1e080e7          	jalr	-1506(ra) # 800041d0 <begin_op>

  if(omode & O_CREATE){
    800057ba:	f4c42783          	lw	a5,-180(s0)
    800057be:	2007f793          	andi	a5,a5,512
    800057c2:	cbdd                	beqz	a5,80005878 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800057c4:	4681                	li	a3,0
    800057c6:	4601                	li	a2,0
    800057c8:	4589                	li	a1,2
    800057ca:	f5040513          	addi	a0,s0,-176
    800057ce:	00000097          	auipc	ra,0x0
    800057d2:	970080e7          	jalr	-1680(ra) # 8000513e <create>
    800057d6:	892a                	mv	s2,a0
    if(ip == 0){
    800057d8:	c959                	beqz	a0,8000586e <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800057da:	04491703          	lh	a4,68(s2)
    800057de:	478d                	li	a5,3
    800057e0:	00f71763          	bne	a4,a5,800057ee <sys_open+0x74>
    800057e4:	04695703          	lhu	a4,70(s2)
    800057e8:	47a5                	li	a5,9
    800057ea:	0ce7ec63          	bltu	a5,a4,800058c2 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800057ee:	fffff097          	auipc	ra,0xfffff
    800057f2:	dee080e7          	jalr	-530(ra) # 800045dc <filealloc>
    800057f6:	89aa                	mv	s3,a0
    800057f8:	10050263          	beqz	a0,800058fc <sys_open+0x182>
    800057fc:	00000097          	auipc	ra,0x0
    80005800:	900080e7          	jalr	-1792(ra) # 800050fc <fdalloc>
    80005804:	84aa                	mv	s1,a0
    80005806:	0e054663          	bltz	a0,800058f2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000580a:	04491703          	lh	a4,68(s2)
    8000580e:	478d                	li	a5,3
    80005810:	0cf70463          	beq	a4,a5,800058d8 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005814:	4789                	li	a5,2
    80005816:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000581a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000581e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005822:	f4c42783          	lw	a5,-180(s0)
    80005826:	0017c713          	xori	a4,a5,1
    8000582a:	8b05                	andi	a4,a4,1
    8000582c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005830:	0037f713          	andi	a4,a5,3
    80005834:	00e03733          	snez	a4,a4
    80005838:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000583c:	4007f793          	andi	a5,a5,1024
    80005840:	c791                	beqz	a5,8000584c <sys_open+0xd2>
    80005842:	04491703          	lh	a4,68(s2)
    80005846:	4789                	li	a5,2
    80005848:	08f70f63          	beq	a4,a5,800058e6 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000584c:	854a                	mv	a0,s2
    8000584e:	ffffe097          	auipc	ra,0xffffe
    80005852:	068080e7          	jalr	104(ra) # 800038b6 <iunlock>
  end_op();
    80005856:	fffff097          	auipc	ra,0xfffff
    8000585a:	9f8080e7          	jalr	-1544(ra) # 8000424e <end_op>

  return fd;
}
    8000585e:	8526                	mv	a0,s1
    80005860:	70ea                	ld	ra,184(sp)
    80005862:	744a                	ld	s0,176(sp)
    80005864:	74aa                	ld	s1,168(sp)
    80005866:	790a                	ld	s2,160(sp)
    80005868:	69ea                	ld	s3,152(sp)
    8000586a:	6129                	addi	sp,sp,192
    8000586c:	8082                	ret
      end_op();
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	9e0080e7          	jalr	-1568(ra) # 8000424e <end_op>
      return -1;
    80005876:	b7e5                	j	8000585e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005878:	f5040513          	addi	a0,s0,-176
    8000587c:	ffffe097          	auipc	ra,0xffffe
    80005880:	734080e7          	jalr	1844(ra) # 80003fb0 <namei>
    80005884:	892a                	mv	s2,a0
    80005886:	c905                	beqz	a0,800058b6 <sys_open+0x13c>
    ilock(ip);
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	f6c080e7          	jalr	-148(ra) # 800037f4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005890:	04491703          	lh	a4,68(s2)
    80005894:	4785                	li	a5,1
    80005896:	f4f712e3          	bne	a4,a5,800057da <sys_open+0x60>
    8000589a:	f4c42783          	lw	a5,-180(s0)
    8000589e:	dba1                	beqz	a5,800057ee <sys_open+0x74>
      iunlockput(ip);
    800058a0:	854a                	mv	a0,s2
    800058a2:	ffffe097          	auipc	ra,0xffffe
    800058a6:	1b4080e7          	jalr	436(ra) # 80003a56 <iunlockput>
      end_op();
    800058aa:	fffff097          	auipc	ra,0xfffff
    800058ae:	9a4080e7          	jalr	-1628(ra) # 8000424e <end_op>
      return -1;
    800058b2:	54fd                	li	s1,-1
    800058b4:	b76d                	j	8000585e <sys_open+0xe4>
      end_op();
    800058b6:	fffff097          	auipc	ra,0xfffff
    800058ba:	998080e7          	jalr	-1640(ra) # 8000424e <end_op>
      return -1;
    800058be:	54fd                	li	s1,-1
    800058c0:	bf79                	j	8000585e <sys_open+0xe4>
    iunlockput(ip);
    800058c2:	854a                	mv	a0,s2
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	192080e7          	jalr	402(ra) # 80003a56 <iunlockput>
    end_op();
    800058cc:	fffff097          	auipc	ra,0xfffff
    800058d0:	982080e7          	jalr	-1662(ra) # 8000424e <end_op>
    return -1;
    800058d4:	54fd                	li	s1,-1
    800058d6:	b761                	j	8000585e <sys_open+0xe4>
    f->type = FD_DEVICE;
    800058d8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800058dc:	04691783          	lh	a5,70(s2)
    800058e0:	02f99223          	sh	a5,36(s3)
    800058e4:	bf2d                	j	8000581e <sys_open+0xa4>
    itrunc(ip);
    800058e6:	854a                	mv	a0,s2
    800058e8:	ffffe097          	auipc	ra,0xffffe
    800058ec:	01a080e7          	jalr	26(ra) # 80003902 <itrunc>
    800058f0:	bfb1                	j	8000584c <sys_open+0xd2>
      fileclose(f);
    800058f2:	854e                	mv	a0,s3
    800058f4:	fffff097          	auipc	ra,0xfffff
    800058f8:	da4080e7          	jalr	-604(ra) # 80004698 <fileclose>
    iunlockput(ip);
    800058fc:	854a                	mv	a0,s2
    800058fe:	ffffe097          	auipc	ra,0xffffe
    80005902:	158080e7          	jalr	344(ra) # 80003a56 <iunlockput>
    end_op();
    80005906:	fffff097          	auipc	ra,0xfffff
    8000590a:	948080e7          	jalr	-1720(ra) # 8000424e <end_op>
    return -1;
    8000590e:	54fd                	li	s1,-1
    80005910:	b7b9                	j	8000585e <sys_open+0xe4>

0000000080005912 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005912:	7175                	addi	sp,sp,-144
    80005914:	e506                	sd	ra,136(sp)
    80005916:	e122                	sd	s0,128(sp)
    80005918:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000591a:	fffff097          	auipc	ra,0xfffff
    8000591e:	8b6080e7          	jalr	-1866(ra) # 800041d0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005922:	08000613          	li	a2,128
    80005926:	f7040593          	addi	a1,s0,-144
    8000592a:	4501                	li	a0,0
    8000592c:	ffffd097          	auipc	ra,0xffffd
    80005930:	336080e7          	jalr	822(ra) # 80002c62 <argstr>
    80005934:	02054963          	bltz	a0,80005966 <sys_mkdir+0x54>
    80005938:	4681                	li	a3,0
    8000593a:	4601                	li	a2,0
    8000593c:	4585                	li	a1,1
    8000593e:	f7040513          	addi	a0,s0,-144
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	7fc080e7          	jalr	2044(ra) # 8000513e <create>
    8000594a:	cd11                	beqz	a0,80005966 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	10a080e7          	jalr	266(ra) # 80003a56 <iunlockput>
  end_op();
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	8fa080e7          	jalr	-1798(ra) # 8000424e <end_op>
  return 0;
    8000595c:	4501                	li	a0,0
}
    8000595e:	60aa                	ld	ra,136(sp)
    80005960:	640a                	ld	s0,128(sp)
    80005962:	6149                	addi	sp,sp,144
    80005964:	8082                	ret
    end_op();
    80005966:	fffff097          	auipc	ra,0xfffff
    8000596a:	8e8080e7          	jalr	-1816(ra) # 8000424e <end_op>
    return -1;
    8000596e:	557d                	li	a0,-1
    80005970:	b7fd                	j	8000595e <sys_mkdir+0x4c>

0000000080005972 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005972:	7135                	addi	sp,sp,-160
    80005974:	ed06                	sd	ra,152(sp)
    80005976:	e922                	sd	s0,144(sp)
    80005978:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000597a:	fffff097          	auipc	ra,0xfffff
    8000597e:	856080e7          	jalr	-1962(ra) # 800041d0 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005982:	08000613          	li	a2,128
    80005986:	f7040593          	addi	a1,s0,-144
    8000598a:	4501                	li	a0,0
    8000598c:	ffffd097          	auipc	ra,0xffffd
    80005990:	2d6080e7          	jalr	726(ra) # 80002c62 <argstr>
    80005994:	04054a63          	bltz	a0,800059e8 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005998:	f6c40593          	addi	a1,s0,-148
    8000599c:	4505                	li	a0,1
    8000599e:	ffffd097          	auipc	ra,0xffffd
    800059a2:	280080e7          	jalr	640(ra) # 80002c1e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059a6:	04054163          	bltz	a0,800059e8 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800059aa:	f6840593          	addi	a1,s0,-152
    800059ae:	4509                	li	a0,2
    800059b0:	ffffd097          	auipc	ra,0xffffd
    800059b4:	26e080e7          	jalr	622(ra) # 80002c1e <argint>
     argint(1, &major) < 0 ||
    800059b8:	02054863          	bltz	a0,800059e8 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800059bc:	f6841683          	lh	a3,-152(s0)
    800059c0:	f6c41603          	lh	a2,-148(s0)
    800059c4:	458d                	li	a1,3
    800059c6:	f7040513          	addi	a0,s0,-144
    800059ca:	fffff097          	auipc	ra,0xfffff
    800059ce:	774080e7          	jalr	1908(ra) # 8000513e <create>
     argint(2, &minor) < 0 ||
    800059d2:	c919                	beqz	a0,800059e8 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059d4:	ffffe097          	auipc	ra,0xffffe
    800059d8:	082080e7          	jalr	130(ra) # 80003a56 <iunlockput>
  end_op();
    800059dc:	fffff097          	auipc	ra,0xfffff
    800059e0:	872080e7          	jalr	-1934(ra) # 8000424e <end_op>
  return 0;
    800059e4:	4501                	li	a0,0
    800059e6:	a031                	j	800059f2 <sys_mknod+0x80>
    end_op();
    800059e8:	fffff097          	auipc	ra,0xfffff
    800059ec:	866080e7          	jalr	-1946(ra) # 8000424e <end_op>
    return -1;
    800059f0:	557d                	li	a0,-1
}
    800059f2:	60ea                	ld	ra,152(sp)
    800059f4:	644a                	ld	s0,144(sp)
    800059f6:	610d                	addi	sp,sp,160
    800059f8:	8082                	ret

00000000800059fa <sys_chdir>:

uint64
sys_chdir(void)
{
    800059fa:	7135                	addi	sp,sp,-160
    800059fc:	ed06                	sd	ra,152(sp)
    800059fe:	e922                	sd	s0,144(sp)
    80005a00:	e526                	sd	s1,136(sp)
    80005a02:	e14a                	sd	s2,128(sp)
    80005a04:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a06:	ffffc097          	auipc	ra,0xffffc
    80005a0a:	f90080e7          	jalr	-112(ra) # 80001996 <myproc>
    80005a0e:	892a                	mv	s2,a0
  
  begin_op();
    80005a10:	ffffe097          	auipc	ra,0xffffe
    80005a14:	7c0080e7          	jalr	1984(ra) # 800041d0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a18:	08000613          	li	a2,128
    80005a1c:	f6040593          	addi	a1,s0,-160
    80005a20:	4501                	li	a0,0
    80005a22:	ffffd097          	auipc	ra,0xffffd
    80005a26:	240080e7          	jalr	576(ra) # 80002c62 <argstr>
    80005a2a:	04054b63          	bltz	a0,80005a80 <sys_chdir+0x86>
    80005a2e:	f6040513          	addi	a0,s0,-160
    80005a32:	ffffe097          	auipc	ra,0xffffe
    80005a36:	57e080e7          	jalr	1406(ra) # 80003fb0 <namei>
    80005a3a:	84aa                	mv	s1,a0
    80005a3c:	c131                	beqz	a0,80005a80 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a3e:	ffffe097          	auipc	ra,0xffffe
    80005a42:	db6080e7          	jalr	-586(ra) # 800037f4 <ilock>
  if(ip->type != T_DIR){
    80005a46:	04449703          	lh	a4,68(s1)
    80005a4a:	4785                	li	a5,1
    80005a4c:	04f71063          	bne	a4,a5,80005a8c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a50:	8526                	mv	a0,s1
    80005a52:	ffffe097          	auipc	ra,0xffffe
    80005a56:	e64080e7          	jalr	-412(ra) # 800038b6 <iunlock>
  iput(p->cwd);
    80005a5a:	15893503          	ld	a0,344(s2)
    80005a5e:	ffffe097          	auipc	ra,0xffffe
    80005a62:	f50080e7          	jalr	-176(ra) # 800039ae <iput>
  end_op();
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	7e8080e7          	jalr	2024(ra) # 8000424e <end_op>
  p->cwd = ip;
    80005a6e:	14993c23          	sd	s1,344(s2)
  return 0;
    80005a72:	4501                	li	a0,0
}
    80005a74:	60ea                	ld	ra,152(sp)
    80005a76:	644a                	ld	s0,144(sp)
    80005a78:	64aa                	ld	s1,136(sp)
    80005a7a:	690a                	ld	s2,128(sp)
    80005a7c:	610d                	addi	sp,sp,160
    80005a7e:	8082                	ret
    end_op();
    80005a80:	ffffe097          	auipc	ra,0xffffe
    80005a84:	7ce080e7          	jalr	1998(ra) # 8000424e <end_op>
    return -1;
    80005a88:	557d                	li	a0,-1
    80005a8a:	b7ed                	j	80005a74 <sys_chdir+0x7a>
    iunlockput(ip);
    80005a8c:	8526                	mv	a0,s1
    80005a8e:	ffffe097          	auipc	ra,0xffffe
    80005a92:	fc8080e7          	jalr	-56(ra) # 80003a56 <iunlockput>
    end_op();
    80005a96:	ffffe097          	auipc	ra,0xffffe
    80005a9a:	7b8080e7          	jalr	1976(ra) # 8000424e <end_op>
    return -1;
    80005a9e:	557d                	li	a0,-1
    80005aa0:	bfd1                	j	80005a74 <sys_chdir+0x7a>

0000000080005aa2 <sys_exec>:

uint64
sys_exec(void)
{
    80005aa2:	7145                	addi	sp,sp,-464
    80005aa4:	e786                	sd	ra,456(sp)
    80005aa6:	e3a2                	sd	s0,448(sp)
    80005aa8:	ff26                	sd	s1,440(sp)
    80005aaa:	fb4a                	sd	s2,432(sp)
    80005aac:	f74e                	sd	s3,424(sp)
    80005aae:	f352                	sd	s4,416(sp)
    80005ab0:	ef56                	sd	s5,408(sp)
    80005ab2:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ab4:	08000613          	li	a2,128
    80005ab8:	f4040593          	addi	a1,s0,-192
    80005abc:	4501                	li	a0,0
    80005abe:	ffffd097          	auipc	ra,0xffffd
    80005ac2:	1a4080e7          	jalr	420(ra) # 80002c62 <argstr>
    return -1;
    80005ac6:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ac8:	0c054b63          	bltz	a0,80005b9e <sys_exec+0xfc>
    80005acc:	e3840593          	addi	a1,s0,-456
    80005ad0:	4505                	li	a0,1
    80005ad2:	ffffd097          	auipc	ra,0xffffd
    80005ad6:	16e080e7          	jalr	366(ra) # 80002c40 <argaddr>
    80005ada:	0c054263          	bltz	a0,80005b9e <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005ade:	10000613          	li	a2,256
    80005ae2:	4581                	li	a1,0
    80005ae4:	e4040513          	addi	a0,s0,-448
    80005ae8:	ffffb097          	auipc	ra,0xffffb
    80005aec:	1e4080e7          	jalr	484(ra) # 80000ccc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005af0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005af4:	89a6                	mv	s3,s1
    80005af6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005af8:	02000a13          	li	s4,32
    80005afc:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b00:	00391513          	slli	a0,s2,0x3
    80005b04:	e3040593          	addi	a1,s0,-464
    80005b08:	e3843783          	ld	a5,-456(s0)
    80005b0c:	953e                	add	a0,a0,a5
    80005b0e:	ffffd097          	auipc	ra,0xffffd
    80005b12:	076080e7          	jalr	118(ra) # 80002b84 <fetchaddr>
    80005b16:	02054a63          	bltz	a0,80005b4a <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005b1a:	e3043783          	ld	a5,-464(s0)
    80005b1e:	c3b9                	beqz	a5,80005b64 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b20:	ffffb097          	auipc	ra,0xffffb
    80005b24:	fc0080e7          	jalr	-64(ra) # 80000ae0 <kalloc>
    80005b28:	85aa                	mv	a1,a0
    80005b2a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b2e:	cd11                	beqz	a0,80005b4a <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b30:	6605                	lui	a2,0x1
    80005b32:	e3043503          	ld	a0,-464(s0)
    80005b36:	ffffd097          	auipc	ra,0xffffd
    80005b3a:	0a0080e7          	jalr	160(ra) # 80002bd6 <fetchstr>
    80005b3e:	00054663          	bltz	a0,80005b4a <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005b42:	0905                	addi	s2,s2,1
    80005b44:	09a1                	addi	s3,s3,8
    80005b46:	fb491be3          	bne	s2,s4,80005afc <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b4a:	f4040913          	addi	s2,s0,-192
    80005b4e:	6088                	ld	a0,0(s1)
    80005b50:	c531                	beqz	a0,80005b9c <sys_exec+0xfa>
    kfree(argv[i]);
    80005b52:	ffffb097          	auipc	ra,0xffffb
    80005b56:	e90080e7          	jalr	-368(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b5a:	04a1                	addi	s1,s1,8
    80005b5c:	ff2499e3          	bne	s1,s2,80005b4e <sys_exec+0xac>
  return -1;
    80005b60:	597d                	li	s2,-1
    80005b62:	a835                	j	80005b9e <sys_exec+0xfc>
      argv[i] = 0;
    80005b64:	0a8e                	slli	s5,s5,0x3
    80005b66:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd8fc0>
    80005b6a:	00878ab3          	add	s5,a5,s0
    80005b6e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005b72:	e4040593          	addi	a1,s0,-448
    80005b76:	f4040513          	addi	a0,s0,-192
    80005b7a:	fffff097          	auipc	ra,0xfffff
    80005b7e:	172080e7          	jalr	370(ra) # 80004cec <exec>
    80005b82:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b84:	f4040993          	addi	s3,s0,-192
    80005b88:	6088                	ld	a0,0(s1)
    80005b8a:	c911                	beqz	a0,80005b9e <sys_exec+0xfc>
    kfree(argv[i]);
    80005b8c:	ffffb097          	auipc	ra,0xffffb
    80005b90:	e56080e7          	jalr	-426(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b94:	04a1                	addi	s1,s1,8
    80005b96:	ff3499e3          	bne	s1,s3,80005b88 <sys_exec+0xe6>
    80005b9a:	a011                	j	80005b9e <sys_exec+0xfc>
  return -1;
    80005b9c:	597d                	li	s2,-1
}
    80005b9e:	854a                	mv	a0,s2
    80005ba0:	60be                	ld	ra,456(sp)
    80005ba2:	641e                	ld	s0,448(sp)
    80005ba4:	74fa                	ld	s1,440(sp)
    80005ba6:	795a                	ld	s2,432(sp)
    80005ba8:	79ba                	ld	s3,424(sp)
    80005baa:	7a1a                	ld	s4,416(sp)
    80005bac:	6afa                	ld	s5,408(sp)
    80005bae:	6179                	addi	sp,sp,464
    80005bb0:	8082                	ret

0000000080005bb2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005bb2:	7139                	addi	sp,sp,-64
    80005bb4:	fc06                	sd	ra,56(sp)
    80005bb6:	f822                	sd	s0,48(sp)
    80005bb8:	f426                	sd	s1,40(sp)
    80005bba:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005bbc:	ffffc097          	auipc	ra,0xffffc
    80005bc0:	dda080e7          	jalr	-550(ra) # 80001996 <myproc>
    80005bc4:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005bc6:	fd840593          	addi	a1,s0,-40
    80005bca:	4501                	li	a0,0
    80005bcc:	ffffd097          	auipc	ra,0xffffd
    80005bd0:	074080e7          	jalr	116(ra) # 80002c40 <argaddr>
    return -1;
    80005bd4:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005bd6:	0e054063          	bltz	a0,80005cb6 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005bda:	fc840593          	addi	a1,s0,-56
    80005bde:	fd040513          	addi	a0,s0,-48
    80005be2:	fffff097          	auipc	ra,0xfffff
    80005be6:	de6080e7          	jalr	-538(ra) # 800049c8 <pipealloc>
    return -1;
    80005bea:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005bec:	0c054563          	bltz	a0,80005cb6 <sys_pipe+0x104>
  fd0 = -1;
    80005bf0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005bf4:	fd043503          	ld	a0,-48(s0)
    80005bf8:	fffff097          	auipc	ra,0xfffff
    80005bfc:	504080e7          	jalr	1284(ra) # 800050fc <fdalloc>
    80005c00:	fca42223          	sw	a0,-60(s0)
    80005c04:	08054c63          	bltz	a0,80005c9c <sys_pipe+0xea>
    80005c08:	fc843503          	ld	a0,-56(s0)
    80005c0c:	fffff097          	auipc	ra,0xfffff
    80005c10:	4f0080e7          	jalr	1264(ra) # 800050fc <fdalloc>
    80005c14:	fca42023          	sw	a0,-64(s0)
    80005c18:	06054963          	bltz	a0,80005c8a <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c1c:	4691                	li	a3,4
    80005c1e:	fc440613          	addi	a2,s0,-60
    80005c22:	fd843583          	ld	a1,-40(s0)
    80005c26:	6ca8                	ld	a0,88(s1)
    80005c28:	ffffc097          	auipc	ra,0xffffc
    80005c2c:	a32080e7          	jalr	-1486(ra) # 8000165a <copyout>
    80005c30:	02054063          	bltz	a0,80005c50 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c34:	4691                	li	a3,4
    80005c36:	fc040613          	addi	a2,s0,-64
    80005c3a:	fd843583          	ld	a1,-40(s0)
    80005c3e:	0591                	addi	a1,a1,4
    80005c40:	6ca8                	ld	a0,88(s1)
    80005c42:	ffffc097          	auipc	ra,0xffffc
    80005c46:	a18080e7          	jalr	-1512(ra) # 8000165a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c4a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c4c:	06055563          	bgez	a0,80005cb6 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005c50:	fc442783          	lw	a5,-60(s0)
    80005c54:	07e9                	addi	a5,a5,26
    80005c56:	078e                	slli	a5,a5,0x3
    80005c58:	97a6                	add	a5,a5,s1
    80005c5a:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005c5e:	fc042783          	lw	a5,-64(s0)
    80005c62:	07e9                	addi	a5,a5,26
    80005c64:	078e                	slli	a5,a5,0x3
    80005c66:	00f48533          	add	a0,s1,a5
    80005c6a:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005c6e:	fd043503          	ld	a0,-48(s0)
    80005c72:	fffff097          	auipc	ra,0xfffff
    80005c76:	a26080e7          	jalr	-1498(ra) # 80004698 <fileclose>
    fileclose(wf);
    80005c7a:	fc843503          	ld	a0,-56(s0)
    80005c7e:	fffff097          	auipc	ra,0xfffff
    80005c82:	a1a080e7          	jalr	-1510(ra) # 80004698 <fileclose>
    return -1;
    80005c86:	57fd                	li	a5,-1
    80005c88:	a03d                	j	80005cb6 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005c8a:	fc442783          	lw	a5,-60(s0)
    80005c8e:	0007c763          	bltz	a5,80005c9c <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005c92:	07e9                	addi	a5,a5,26
    80005c94:	078e                	slli	a5,a5,0x3
    80005c96:	97a6                	add	a5,a5,s1
    80005c98:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005c9c:	fd043503          	ld	a0,-48(s0)
    80005ca0:	fffff097          	auipc	ra,0xfffff
    80005ca4:	9f8080e7          	jalr	-1544(ra) # 80004698 <fileclose>
    fileclose(wf);
    80005ca8:	fc843503          	ld	a0,-56(s0)
    80005cac:	fffff097          	auipc	ra,0xfffff
    80005cb0:	9ec080e7          	jalr	-1556(ra) # 80004698 <fileclose>
    return -1;
    80005cb4:	57fd                	li	a5,-1
}
    80005cb6:	853e                	mv	a0,a5
    80005cb8:	70e2                	ld	ra,56(sp)
    80005cba:	7442                	ld	s0,48(sp)
    80005cbc:	74a2                	ld	s1,40(sp)
    80005cbe:	6121                	addi	sp,sp,64
    80005cc0:	8082                	ret
	...

0000000080005cd0 <kernelvec>:
    80005cd0:	7111                	addi	sp,sp,-256
    80005cd2:	e006                	sd	ra,0(sp)
    80005cd4:	e40a                	sd	sp,8(sp)
    80005cd6:	e80e                	sd	gp,16(sp)
    80005cd8:	ec12                	sd	tp,24(sp)
    80005cda:	f016                	sd	t0,32(sp)
    80005cdc:	f41a                	sd	t1,40(sp)
    80005cde:	f81e                	sd	t2,48(sp)
    80005ce0:	fc22                	sd	s0,56(sp)
    80005ce2:	e0a6                	sd	s1,64(sp)
    80005ce4:	e4aa                	sd	a0,72(sp)
    80005ce6:	e8ae                	sd	a1,80(sp)
    80005ce8:	ecb2                	sd	a2,88(sp)
    80005cea:	f0b6                	sd	a3,96(sp)
    80005cec:	f4ba                	sd	a4,104(sp)
    80005cee:	f8be                	sd	a5,112(sp)
    80005cf0:	fcc2                	sd	a6,120(sp)
    80005cf2:	e146                	sd	a7,128(sp)
    80005cf4:	e54a                	sd	s2,136(sp)
    80005cf6:	e94e                	sd	s3,144(sp)
    80005cf8:	ed52                	sd	s4,152(sp)
    80005cfa:	f156                	sd	s5,160(sp)
    80005cfc:	f55a                	sd	s6,168(sp)
    80005cfe:	f95e                	sd	s7,176(sp)
    80005d00:	fd62                	sd	s8,184(sp)
    80005d02:	e1e6                	sd	s9,192(sp)
    80005d04:	e5ea                	sd	s10,200(sp)
    80005d06:	e9ee                	sd	s11,208(sp)
    80005d08:	edf2                	sd	t3,216(sp)
    80005d0a:	f1f6                	sd	t4,224(sp)
    80005d0c:	f5fa                	sd	t5,232(sp)
    80005d0e:	f9fe                	sd	t6,240(sp)
    80005d10:	d41fc0ef          	jal	ra,80002a50 <kerneltrap>
    80005d14:	6082                	ld	ra,0(sp)
    80005d16:	6122                	ld	sp,8(sp)
    80005d18:	61c2                	ld	gp,16(sp)
    80005d1a:	7282                	ld	t0,32(sp)
    80005d1c:	7322                	ld	t1,40(sp)
    80005d1e:	73c2                	ld	t2,48(sp)
    80005d20:	7462                	ld	s0,56(sp)
    80005d22:	6486                	ld	s1,64(sp)
    80005d24:	6526                	ld	a0,72(sp)
    80005d26:	65c6                	ld	a1,80(sp)
    80005d28:	6666                	ld	a2,88(sp)
    80005d2a:	7686                	ld	a3,96(sp)
    80005d2c:	7726                	ld	a4,104(sp)
    80005d2e:	77c6                	ld	a5,112(sp)
    80005d30:	7866                	ld	a6,120(sp)
    80005d32:	688a                	ld	a7,128(sp)
    80005d34:	692a                	ld	s2,136(sp)
    80005d36:	69ca                	ld	s3,144(sp)
    80005d38:	6a6a                	ld	s4,152(sp)
    80005d3a:	7a8a                	ld	s5,160(sp)
    80005d3c:	7b2a                	ld	s6,168(sp)
    80005d3e:	7bca                	ld	s7,176(sp)
    80005d40:	7c6a                	ld	s8,184(sp)
    80005d42:	6c8e                	ld	s9,192(sp)
    80005d44:	6d2e                	ld	s10,200(sp)
    80005d46:	6dce                	ld	s11,208(sp)
    80005d48:	6e6e                	ld	t3,216(sp)
    80005d4a:	7e8e                	ld	t4,224(sp)
    80005d4c:	7f2e                	ld	t5,232(sp)
    80005d4e:	7fce                	ld	t6,240(sp)
    80005d50:	6111                	addi	sp,sp,256
    80005d52:	10200073          	sret
    80005d56:	00000013          	nop
    80005d5a:	00000013          	nop
    80005d5e:	0001                	nop

0000000080005d60 <timervec>:
    80005d60:	34051573          	csrrw	a0,mscratch,a0
    80005d64:	e10c                	sd	a1,0(a0)
    80005d66:	e510                	sd	a2,8(a0)
    80005d68:	e914                	sd	a3,16(a0)
    80005d6a:	6d0c                	ld	a1,24(a0)
    80005d6c:	7110                	ld	a2,32(a0)
    80005d6e:	6194                	ld	a3,0(a1)
    80005d70:	96b2                	add	a3,a3,a2
    80005d72:	e194                	sd	a3,0(a1)
    80005d74:	4589                	li	a1,2
    80005d76:	14459073          	csrw	sip,a1
    80005d7a:	6914                	ld	a3,16(a0)
    80005d7c:	6510                	ld	a2,8(a0)
    80005d7e:	610c                	ld	a1,0(a0)
    80005d80:	34051573          	csrrw	a0,mscratch,a0
    80005d84:	30200073          	mret
	...

0000000080005d8a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d8a:	1141                	addi	sp,sp,-16
    80005d8c:	e422                	sd	s0,8(sp)
    80005d8e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d90:	0c0007b7          	lui	a5,0xc000
    80005d94:	4705                	li	a4,1
    80005d96:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d98:	c3d8                	sw	a4,4(a5)
}
    80005d9a:	6422                	ld	s0,8(sp)
    80005d9c:	0141                	addi	sp,sp,16
    80005d9e:	8082                	ret

0000000080005da0 <plicinithart>:

void
plicinithart(void)
{
    80005da0:	1141                	addi	sp,sp,-16
    80005da2:	e406                	sd	ra,8(sp)
    80005da4:	e022                	sd	s0,0(sp)
    80005da6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005da8:	ffffc097          	auipc	ra,0xffffc
    80005dac:	bc2080e7          	jalr	-1086(ra) # 8000196a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005db0:	0085171b          	slliw	a4,a0,0x8
    80005db4:	0c0027b7          	lui	a5,0xc002
    80005db8:	97ba                	add	a5,a5,a4
    80005dba:	40200713          	li	a4,1026
    80005dbe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005dc2:	00d5151b          	slliw	a0,a0,0xd
    80005dc6:	0c2017b7          	lui	a5,0xc201
    80005dca:	97aa                	add	a5,a5,a0
    80005dcc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005dd0:	60a2                	ld	ra,8(sp)
    80005dd2:	6402                	ld	s0,0(sp)
    80005dd4:	0141                	addi	sp,sp,16
    80005dd6:	8082                	ret

0000000080005dd8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005dd8:	1141                	addi	sp,sp,-16
    80005dda:	e406                	sd	ra,8(sp)
    80005ddc:	e022                	sd	s0,0(sp)
    80005dde:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005de0:	ffffc097          	auipc	ra,0xffffc
    80005de4:	b8a080e7          	jalr	-1142(ra) # 8000196a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005de8:	00d5151b          	slliw	a0,a0,0xd
    80005dec:	0c2017b7          	lui	a5,0xc201
    80005df0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005df2:	43c8                	lw	a0,4(a5)
    80005df4:	60a2                	ld	ra,8(sp)
    80005df6:	6402                	ld	s0,0(sp)
    80005df8:	0141                	addi	sp,sp,16
    80005dfa:	8082                	ret

0000000080005dfc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005dfc:	1101                	addi	sp,sp,-32
    80005dfe:	ec06                	sd	ra,24(sp)
    80005e00:	e822                	sd	s0,16(sp)
    80005e02:	e426                	sd	s1,8(sp)
    80005e04:	1000                	addi	s0,sp,32
    80005e06:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e08:	ffffc097          	auipc	ra,0xffffc
    80005e0c:	b62080e7          	jalr	-1182(ra) # 8000196a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e10:	00d5151b          	slliw	a0,a0,0xd
    80005e14:	0c2017b7          	lui	a5,0xc201
    80005e18:	97aa                	add	a5,a5,a0
    80005e1a:	c3c4                	sw	s1,4(a5)
}
    80005e1c:	60e2                	ld	ra,24(sp)
    80005e1e:	6442                	ld	s0,16(sp)
    80005e20:	64a2                	ld	s1,8(sp)
    80005e22:	6105                	addi	sp,sp,32
    80005e24:	8082                	ret

0000000080005e26 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e26:	1141                	addi	sp,sp,-16
    80005e28:	e406                	sd	ra,8(sp)
    80005e2a:	e022                	sd	s0,0(sp)
    80005e2c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e2e:	479d                	li	a5,7
    80005e30:	06a7c863          	blt	a5,a0,80005ea0 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80005e34:	0001d717          	auipc	a4,0x1d
    80005e38:	1cc70713          	addi	a4,a4,460 # 80023000 <disk>
    80005e3c:	972a                	add	a4,a4,a0
    80005e3e:	6789                	lui	a5,0x2
    80005e40:	97ba                	add	a5,a5,a4
    80005e42:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005e46:	e7ad                	bnez	a5,80005eb0 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005e48:	00451793          	slli	a5,a0,0x4
    80005e4c:	0001f717          	auipc	a4,0x1f
    80005e50:	1b470713          	addi	a4,a4,436 # 80025000 <disk+0x2000>
    80005e54:	6314                	ld	a3,0(a4)
    80005e56:	96be                	add	a3,a3,a5
    80005e58:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005e5c:	6314                	ld	a3,0(a4)
    80005e5e:	96be                	add	a3,a3,a5
    80005e60:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005e64:	6314                	ld	a3,0(a4)
    80005e66:	96be                	add	a3,a3,a5
    80005e68:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005e6c:	6318                	ld	a4,0(a4)
    80005e6e:	97ba                	add	a5,a5,a4
    80005e70:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005e74:	0001d717          	auipc	a4,0x1d
    80005e78:	18c70713          	addi	a4,a4,396 # 80023000 <disk>
    80005e7c:	972a                	add	a4,a4,a0
    80005e7e:	6789                	lui	a5,0x2
    80005e80:	97ba                	add	a5,a5,a4
    80005e82:	4705                	li	a4,1
    80005e84:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005e88:	0001f517          	auipc	a0,0x1f
    80005e8c:	19050513          	addi	a0,a0,400 # 80025018 <disk+0x2018>
    80005e90:	ffffc097          	auipc	ra,0xffffc
    80005e94:	38e080e7          	jalr	910(ra) # 8000221e <wakeup>
}
    80005e98:	60a2                	ld	ra,8(sp)
    80005e9a:	6402                	ld	s0,0(sp)
    80005e9c:	0141                	addi	sp,sp,16
    80005e9e:	8082                	ret
    panic("free_desc 1");
    80005ea0:	00003517          	auipc	a0,0x3
    80005ea4:	8d050513          	addi	a0,a0,-1840 # 80008770 <syscalls+0x328>
    80005ea8:	ffffa097          	auipc	ra,0xffffa
    80005eac:	692080e7          	jalr	1682(ra) # 8000053a <panic>
    panic("free_desc 2");
    80005eb0:	00003517          	auipc	a0,0x3
    80005eb4:	8d050513          	addi	a0,a0,-1840 # 80008780 <syscalls+0x338>
    80005eb8:	ffffa097          	auipc	ra,0xffffa
    80005ebc:	682080e7          	jalr	1666(ra) # 8000053a <panic>

0000000080005ec0 <virtio_disk_init>:
{
    80005ec0:	1101                	addi	sp,sp,-32
    80005ec2:	ec06                	sd	ra,24(sp)
    80005ec4:	e822                	sd	s0,16(sp)
    80005ec6:	e426                	sd	s1,8(sp)
    80005ec8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005eca:	00003597          	auipc	a1,0x3
    80005ece:	8c658593          	addi	a1,a1,-1850 # 80008790 <syscalls+0x348>
    80005ed2:	0001f517          	auipc	a0,0x1f
    80005ed6:	25650513          	addi	a0,a0,598 # 80025128 <disk+0x2128>
    80005eda:	ffffb097          	auipc	ra,0xffffb
    80005ede:	c66080e7          	jalr	-922(ra) # 80000b40 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ee2:	100017b7          	lui	a5,0x10001
    80005ee6:	4398                	lw	a4,0(a5)
    80005ee8:	2701                	sext.w	a4,a4
    80005eea:	747277b7          	lui	a5,0x74727
    80005eee:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ef2:	0ef71063          	bne	a4,a5,80005fd2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005ef6:	100017b7          	lui	a5,0x10001
    80005efa:	43dc                	lw	a5,4(a5)
    80005efc:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005efe:	4705                	li	a4,1
    80005f00:	0ce79963          	bne	a5,a4,80005fd2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f04:	100017b7          	lui	a5,0x10001
    80005f08:	479c                	lw	a5,8(a5)
    80005f0a:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005f0c:	4709                	li	a4,2
    80005f0e:	0ce79263          	bne	a5,a4,80005fd2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f12:	100017b7          	lui	a5,0x10001
    80005f16:	47d8                	lw	a4,12(a5)
    80005f18:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f1a:	554d47b7          	lui	a5,0x554d4
    80005f1e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f22:	0af71863          	bne	a4,a5,80005fd2 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f26:	100017b7          	lui	a5,0x10001
    80005f2a:	4705                	li	a4,1
    80005f2c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f2e:	470d                	li	a4,3
    80005f30:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005f32:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f34:	c7ffe6b7          	lui	a3,0xc7ffe
    80005f38:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005f3c:	8f75                	and	a4,a4,a3
    80005f3e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f40:	472d                	li	a4,11
    80005f42:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f44:	473d                	li	a4,15
    80005f46:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005f48:	6705                	lui	a4,0x1
    80005f4a:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f4c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005f50:	5bdc                	lw	a5,52(a5)
    80005f52:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f54:	c7d9                	beqz	a5,80005fe2 <virtio_disk_init+0x122>
  if(max < NUM)
    80005f56:	471d                	li	a4,7
    80005f58:	08f77d63          	bgeu	a4,a5,80005ff2 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f5c:	100014b7          	lui	s1,0x10001
    80005f60:	47a1                	li	a5,8
    80005f62:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005f64:	6609                	lui	a2,0x2
    80005f66:	4581                	li	a1,0
    80005f68:	0001d517          	auipc	a0,0x1d
    80005f6c:	09850513          	addi	a0,a0,152 # 80023000 <disk>
    80005f70:	ffffb097          	auipc	ra,0xffffb
    80005f74:	d5c080e7          	jalr	-676(ra) # 80000ccc <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005f78:	0001d717          	auipc	a4,0x1d
    80005f7c:	08870713          	addi	a4,a4,136 # 80023000 <disk>
    80005f80:	00c75793          	srli	a5,a4,0xc
    80005f84:	2781                	sext.w	a5,a5
    80005f86:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005f88:	0001f797          	auipc	a5,0x1f
    80005f8c:	07878793          	addi	a5,a5,120 # 80025000 <disk+0x2000>
    80005f90:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005f92:	0001d717          	auipc	a4,0x1d
    80005f96:	0ee70713          	addi	a4,a4,238 # 80023080 <disk+0x80>
    80005f9a:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005f9c:	0001e717          	auipc	a4,0x1e
    80005fa0:	06470713          	addi	a4,a4,100 # 80024000 <disk+0x1000>
    80005fa4:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005fa6:	4705                	li	a4,1
    80005fa8:	00e78c23          	sb	a4,24(a5)
    80005fac:	00e78ca3          	sb	a4,25(a5)
    80005fb0:	00e78d23          	sb	a4,26(a5)
    80005fb4:	00e78da3          	sb	a4,27(a5)
    80005fb8:	00e78e23          	sb	a4,28(a5)
    80005fbc:	00e78ea3          	sb	a4,29(a5)
    80005fc0:	00e78f23          	sb	a4,30(a5)
    80005fc4:	00e78fa3          	sb	a4,31(a5)
}
    80005fc8:	60e2                	ld	ra,24(sp)
    80005fca:	6442                	ld	s0,16(sp)
    80005fcc:	64a2                	ld	s1,8(sp)
    80005fce:	6105                	addi	sp,sp,32
    80005fd0:	8082                	ret
    panic("could not find virtio disk");
    80005fd2:	00002517          	auipc	a0,0x2
    80005fd6:	7ce50513          	addi	a0,a0,1998 # 800087a0 <syscalls+0x358>
    80005fda:	ffffa097          	auipc	ra,0xffffa
    80005fde:	560080e7          	jalr	1376(ra) # 8000053a <panic>
    panic("virtio disk has no queue 0");
    80005fe2:	00002517          	auipc	a0,0x2
    80005fe6:	7de50513          	addi	a0,a0,2014 # 800087c0 <syscalls+0x378>
    80005fea:	ffffa097          	auipc	ra,0xffffa
    80005fee:	550080e7          	jalr	1360(ra) # 8000053a <panic>
    panic("virtio disk max queue too short");
    80005ff2:	00002517          	auipc	a0,0x2
    80005ff6:	7ee50513          	addi	a0,a0,2030 # 800087e0 <syscalls+0x398>
    80005ffa:	ffffa097          	auipc	ra,0xffffa
    80005ffe:	540080e7          	jalr	1344(ra) # 8000053a <panic>

0000000080006002 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006002:	7119                	addi	sp,sp,-128
    80006004:	fc86                	sd	ra,120(sp)
    80006006:	f8a2                	sd	s0,112(sp)
    80006008:	f4a6                	sd	s1,104(sp)
    8000600a:	f0ca                	sd	s2,96(sp)
    8000600c:	ecce                	sd	s3,88(sp)
    8000600e:	e8d2                	sd	s4,80(sp)
    80006010:	e4d6                	sd	s5,72(sp)
    80006012:	e0da                	sd	s6,64(sp)
    80006014:	fc5e                	sd	s7,56(sp)
    80006016:	f862                	sd	s8,48(sp)
    80006018:	f466                	sd	s9,40(sp)
    8000601a:	f06a                	sd	s10,32(sp)
    8000601c:	ec6e                	sd	s11,24(sp)
    8000601e:	0100                	addi	s0,sp,128
    80006020:	8aaa                	mv	s5,a0
    80006022:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006024:	00c52c83          	lw	s9,12(a0)
    80006028:	001c9c9b          	slliw	s9,s9,0x1
    8000602c:	1c82                	slli	s9,s9,0x20
    8000602e:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006032:	0001f517          	auipc	a0,0x1f
    80006036:	0f650513          	addi	a0,a0,246 # 80025128 <disk+0x2128>
    8000603a:	ffffb097          	auipc	ra,0xffffb
    8000603e:	b96080e7          	jalr	-1130(ra) # 80000bd0 <acquire>
  for(int i = 0; i < 3; i++){
    80006042:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006044:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006046:	0001dc17          	auipc	s8,0x1d
    8000604a:	fbac0c13          	addi	s8,s8,-70 # 80023000 <disk>
    8000604e:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006050:	4b0d                	li	s6,3
    80006052:	a0ad                	j	800060bc <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006054:	00fc0733          	add	a4,s8,a5
    80006058:	975e                	add	a4,a4,s7
    8000605a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000605e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006060:	0207c563          	bltz	a5,8000608a <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006064:	2905                	addiw	s2,s2,1
    80006066:	0611                	addi	a2,a2,4
    80006068:	19690c63          	beq	s2,s6,80006200 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    8000606c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000606e:	0001f717          	auipc	a4,0x1f
    80006072:	faa70713          	addi	a4,a4,-86 # 80025018 <disk+0x2018>
    80006076:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006078:	00074683          	lbu	a3,0(a4)
    8000607c:	fee1                	bnez	a3,80006054 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    8000607e:	2785                	addiw	a5,a5,1
    80006080:	0705                	addi	a4,a4,1
    80006082:	fe979be3          	bne	a5,s1,80006078 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006086:	57fd                	li	a5,-1
    80006088:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000608a:	01205d63          	blez	s2,800060a4 <virtio_disk_rw+0xa2>
    8000608e:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006090:	000a2503          	lw	a0,0(s4)
    80006094:	00000097          	auipc	ra,0x0
    80006098:	d92080e7          	jalr	-622(ra) # 80005e26 <free_desc>
      for(int j = 0; j < i; j++)
    8000609c:	2d85                	addiw	s11,s11,1
    8000609e:	0a11                	addi	s4,s4,4
    800060a0:	ff2d98e3          	bne	s11,s2,80006090 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800060a4:	0001f597          	auipc	a1,0x1f
    800060a8:	08458593          	addi	a1,a1,132 # 80025128 <disk+0x2128>
    800060ac:	0001f517          	auipc	a0,0x1f
    800060b0:	f6c50513          	addi	a0,a0,-148 # 80025018 <disk+0x2018>
    800060b4:	ffffc097          	auipc	ra,0xffffc
    800060b8:	fde080e7          	jalr	-34(ra) # 80002092 <sleep>
  for(int i = 0; i < 3; i++){
    800060bc:	f8040a13          	addi	s4,s0,-128
{
    800060c0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800060c2:	894e                	mv	s2,s3
    800060c4:	b765                	j	8000606c <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800060c6:	0001f697          	auipc	a3,0x1f
    800060ca:	f3a6b683          	ld	a3,-198(a3) # 80025000 <disk+0x2000>
    800060ce:	96ba                	add	a3,a3,a4
    800060d0:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060d4:	0001d817          	auipc	a6,0x1d
    800060d8:	f2c80813          	addi	a6,a6,-212 # 80023000 <disk>
    800060dc:	0001f697          	auipc	a3,0x1f
    800060e0:	f2468693          	addi	a3,a3,-220 # 80025000 <disk+0x2000>
    800060e4:	6290                	ld	a2,0(a3)
    800060e6:	963a                	add	a2,a2,a4
    800060e8:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800060ec:	0015e593          	ori	a1,a1,1
    800060f0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800060f4:	f8842603          	lw	a2,-120(s0)
    800060f8:	628c                	ld	a1,0(a3)
    800060fa:	972e                	add	a4,a4,a1
    800060fc:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006100:	20050593          	addi	a1,a0,512
    80006104:	0592                	slli	a1,a1,0x4
    80006106:	95c2                	add	a1,a1,a6
    80006108:	577d                	li	a4,-1
    8000610a:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000610e:	00461713          	slli	a4,a2,0x4
    80006112:	6290                	ld	a2,0(a3)
    80006114:	963a                	add	a2,a2,a4
    80006116:	03078793          	addi	a5,a5,48
    8000611a:	97c2                	add	a5,a5,a6
    8000611c:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    8000611e:	629c                	ld	a5,0(a3)
    80006120:	97ba                	add	a5,a5,a4
    80006122:	4605                	li	a2,1
    80006124:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006126:	629c                	ld	a5,0(a3)
    80006128:	97ba                	add	a5,a5,a4
    8000612a:	4809                	li	a6,2
    8000612c:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006130:	629c                	ld	a5,0(a3)
    80006132:	97ba                	add	a5,a5,a4
    80006134:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006138:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000613c:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006140:	6698                	ld	a4,8(a3)
    80006142:	00275783          	lhu	a5,2(a4)
    80006146:	8b9d                	andi	a5,a5,7
    80006148:	0786                	slli	a5,a5,0x1
    8000614a:	973e                	add	a4,a4,a5
    8000614c:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    80006150:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006154:	6698                	ld	a4,8(a3)
    80006156:	00275783          	lhu	a5,2(a4)
    8000615a:	2785                	addiw	a5,a5,1
    8000615c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006160:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006164:	100017b7          	lui	a5,0x10001
    80006168:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000616c:	004aa783          	lw	a5,4(s5)
    80006170:	02c79163          	bne	a5,a2,80006192 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006174:	0001f917          	auipc	s2,0x1f
    80006178:	fb490913          	addi	s2,s2,-76 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    8000617c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000617e:	85ca                	mv	a1,s2
    80006180:	8556                	mv	a0,s5
    80006182:	ffffc097          	auipc	ra,0xffffc
    80006186:	f10080e7          	jalr	-240(ra) # 80002092 <sleep>
  while(b->disk == 1) {
    8000618a:	004aa783          	lw	a5,4(s5)
    8000618e:	fe9788e3          	beq	a5,s1,8000617e <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006192:	f8042903          	lw	s2,-128(s0)
    80006196:	20090713          	addi	a4,s2,512
    8000619a:	0712                	slli	a4,a4,0x4
    8000619c:	0001d797          	auipc	a5,0x1d
    800061a0:	e6478793          	addi	a5,a5,-412 # 80023000 <disk>
    800061a4:	97ba                	add	a5,a5,a4
    800061a6:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800061aa:	0001f997          	auipc	s3,0x1f
    800061ae:	e5698993          	addi	s3,s3,-426 # 80025000 <disk+0x2000>
    800061b2:	00491713          	slli	a4,s2,0x4
    800061b6:	0009b783          	ld	a5,0(s3)
    800061ba:	97ba                	add	a5,a5,a4
    800061bc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800061c0:	854a                	mv	a0,s2
    800061c2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800061c6:	00000097          	auipc	ra,0x0
    800061ca:	c60080e7          	jalr	-928(ra) # 80005e26 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800061ce:	8885                	andi	s1,s1,1
    800061d0:	f0ed                	bnez	s1,800061b2 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061d2:	0001f517          	auipc	a0,0x1f
    800061d6:	f5650513          	addi	a0,a0,-170 # 80025128 <disk+0x2128>
    800061da:	ffffb097          	auipc	ra,0xffffb
    800061de:	aaa080e7          	jalr	-1366(ra) # 80000c84 <release>
}
    800061e2:	70e6                	ld	ra,120(sp)
    800061e4:	7446                	ld	s0,112(sp)
    800061e6:	74a6                	ld	s1,104(sp)
    800061e8:	7906                	ld	s2,96(sp)
    800061ea:	69e6                	ld	s3,88(sp)
    800061ec:	6a46                	ld	s4,80(sp)
    800061ee:	6aa6                	ld	s5,72(sp)
    800061f0:	6b06                	ld	s6,64(sp)
    800061f2:	7be2                	ld	s7,56(sp)
    800061f4:	7c42                	ld	s8,48(sp)
    800061f6:	7ca2                	ld	s9,40(sp)
    800061f8:	7d02                	ld	s10,32(sp)
    800061fa:	6de2                	ld	s11,24(sp)
    800061fc:	6109                	addi	sp,sp,128
    800061fe:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006200:	f8042503          	lw	a0,-128(s0)
    80006204:	20050793          	addi	a5,a0,512
    80006208:	0792                	slli	a5,a5,0x4
  if(write)
    8000620a:	0001d817          	auipc	a6,0x1d
    8000620e:	df680813          	addi	a6,a6,-522 # 80023000 <disk>
    80006212:	00f80733          	add	a4,a6,a5
    80006216:	01a036b3          	snez	a3,s10
    8000621a:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    8000621e:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006222:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006226:	7679                	lui	a2,0xffffe
    80006228:	963e                	add	a2,a2,a5
    8000622a:	0001f697          	auipc	a3,0x1f
    8000622e:	dd668693          	addi	a3,a3,-554 # 80025000 <disk+0x2000>
    80006232:	6298                	ld	a4,0(a3)
    80006234:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006236:	0a878593          	addi	a1,a5,168
    8000623a:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000623c:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000623e:	6298                	ld	a4,0(a3)
    80006240:	9732                	add	a4,a4,a2
    80006242:	45c1                	li	a1,16
    80006244:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006246:	6298                	ld	a4,0(a3)
    80006248:	9732                	add	a4,a4,a2
    8000624a:	4585                	li	a1,1
    8000624c:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006250:	f8442703          	lw	a4,-124(s0)
    80006254:	628c                	ld	a1,0(a3)
    80006256:	962e                	add	a2,a2,a1
    80006258:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    8000625c:	0712                	slli	a4,a4,0x4
    8000625e:	6290                	ld	a2,0(a3)
    80006260:	963a                	add	a2,a2,a4
    80006262:	058a8593          	addi	a1,s5,88
    80006266:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006268:	6294                	ld	a3,0(a3)
    8000626a:	96ba                	add	a3,a3,a4
    8000626c:	40000613          	li	a2,1024
    80006270:	c690                	sw	a2,8(a3)
  if(write)
    80006272:	e40d1ae3          	bnez	s10,800060c6 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006276:	0001f697          	auipc	a3,0x1f
    8000627a:	d8a6b683          	ld	a3,-630(a3) # 80025000 <disk+0x2000>
    8000627e:	96ba                	add	a3,a3,a4
    80006280:	4609                	li	a2,2
    80006282:	00c69623          	sh	a2,12(a3)
    80006286:	b5b9                	j	800060d4 <virtio_disk_rw+0xd2>

0000000080006288 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006288:	1101                	addi	sp,sp,-32
    8000628a:	ec06                	sd	ra,24(sp)
    8000628c:	e822                	sd	s0,16(sp)
    8000628e:	e426                	sd	s1,8(sp)
    80006290:	e04a                	sd	s2,0(sp)
    80006292:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006294:	0001f517          	auipc	a0,0x1f
    80006298:	e9450513          	addi	a0,a0,-364 # 80025128 <disk+0x2128>
    8000629c:	ffffb097          	auipc	ra,0xffffb
    800062a0:	934080e7          	jalr	-1740(ra) # 80000bd0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800062a4:	10001737          	lui	a4,0x10001
    800062a8:	533c                	lw	a5,96(a4)
    800062aa:	8b8d                	andi	a5,a5,3
    800062ac:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800062ae:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800062b2:	0001f797          	auipc	a5,0x1f
    800062b6:	d4e78793          	addi	a5,a5,-690 # 80025000 <disk+0x2000>
    800062ba:	6b94                	ld	a3,16(a5)
    800062bc:	0207d703          	lhu	a4,32(a5)
    800062c0:	0026d783          	lhu	a5,2(a3)
    800062c4:	06f70163          	beq	a4,a5,80006326 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800062c8:	0001d917          	auipc	s2,0x1d
    800062cc:	d3890913          	addi	s2,s2,-712 # 80023000 <disk>
    800062d0:	0001f497          	auipc	s1,0x1f
    800062d4:	d3048493          	addi	s1,s1,-720 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800062d8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800062dc:	6898                	ld	a4,16(s1)
    800062de:	0204d783          	lhu	a5,32(s1)
    800062e2:	8b9d                	andi	a5,a5,7
    800062e4:	078e                	slli	a5,a5,0x3
    800062e6:	97ba                	add	a5,a5,a4
    800062e8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800062ea:	20078713          	addi	a4,a5,512
    800062ee:	0712                	slli	a4,a4,0x4
    800062f0:	974a                	add	a4,a4,s2
    800062f2:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800062f6:	e731                	bnez	a4,80006342 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800062f8:	20078793          	addi	a5,a5,512
    800062fc:	0792                	slli	a5,a5,0x4
    800062fe:	97ca                	add	a5,a5,s2
    80006300:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006302:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006306:	ffffc097          	auipc	ra,0xffffc
    8000630a:	f18080e7          	jalr	-232(ra) # 8000221e <wakeup>

    disk.used_idx += 1;
    8000630e:	0204d783          	lhu	a5,32(s1)
    80006312:	2785                	addiw	a5,a5,1
    80006314:	17c2                	slli	a5,a5,0x30
    80006316:	93c1                	srli	a5,a5,0x30
    80006318:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000631c:	6898                	ld	a4,16(s1)
    8000631e:	00275703          	lhu	a4,2(a4)
    80006322:	faf71be3          	bne	a4,a5,800062d8 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006326:	0001f517          	auipc	a0,0x1f
    8000632a:	e0250513          	addi	a0,a0,-510 # 80025128 <disk+0x2128>
    8000632e:	ffffb097          	auipc	ra,0xffffb
    80006332:	956080e7          	jalr	-1706(ra) # 80000c84 <release>
}
    80006336:	60e2                	ld	ra,24(sp)
    80006338:	6442                	ld	s0,16(sp)
    8000633a:	64a2                	ld	s1,8(sp)
    8000633c:	6902                	ld	s2,0(sp)
    8000633e:	6105                	addi	sp,sp,32
    80006340:	8082                	ret
      panic("virtio_disk_intr status");
    80006342:	00002517          	auipc	a0,0x2
    80006346:	4be50513          	addi	a0,a0,1214 # 80008800 <syscalls+0x3b8>
    8000634a:	ffffa097          	auipc	ra,0xffffa
    8000634e:	1f0080e7          	jalr	496(ra) # 8000053a <panic>
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
