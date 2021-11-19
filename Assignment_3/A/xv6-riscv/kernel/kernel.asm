
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
    80000066:	bfe78793          	addi	a5,a5,-1026 # 80005c60 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd7a37>
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
    8000012e:	332080e7          	jalr	818(ra) # 8000245c <either_copyin>
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
    800001c4:	7de080e7          	jalr	2014(ra) # 8000199e <myproc>
    800001c8:	551c                	lw	a5,40(a0)
    800001ca:	e7b5                	bnez	a5,80000236 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001cc:	85a6                	mv	a1,s1
    800001ce:	854a                	mv	a0,s2
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	e92080e7          	jalr	-366(ra) # 80002062 <sleep>
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
    80000210:	1fa080e7          	jalr	506(ra) # 80002406 <either_copyout>
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
    800002f0:	1c6080e7          	jalr	454(ra) # 800024b2 <procdump>
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
    80000444:	dae080e7          	jalr	-594(ra) # 800021ee <wakeup>
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
    80000892:	960080e7          	jalr	-1696(ra) # 800021ee <wakeup>
    
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
    8000091e:	748080e7          	jalr	1864(ra) # 80002062 <sleep>
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
    800009f6:	00026797          	auipc	a5,0x26
    800009fa:	3d278793          	addi	a5,a5,978 # 80026dc8 <end>
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
    80000ac8:	00026517          	auipc	a0,0x26
    80000acc:	30050513          	addi	a0,a0,768 # 80026dc8 <end>
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
    80000b6e:	e18080e7          	jalr	-488(ra) # 80001982 <mycpu>
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
    80000ba0:	de6080e7          	jalr	-538(ra) # 80001982 <mycpu>
    80000ba4:	5d3c                	lw	a5,120(a0)
    80000ba6:	cf89                	beqz	a5,80000bc0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ba8:	00001097          	auipc	ra,0x1
    80000bac:	dda080e7          	jalr	-550(ra) # 80001982 <mycpu>
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
    80000bc4:	dc2080e7          	jalr	-574(ra) # 80001982 <mycpu>
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
    80000c04:	d82080e7          	jalr	-638(ra) # 80001982 <mycpu>
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
    80000c30:	d56080e7          	jalr	-682(ra) # 80001982 <mycpu>
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
    80000d46:	fed70fa3          	sb	a3,-1(a4) # ffffffffffffefff <end+0xffffffff7ffd8237>
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
    80000e7e:	af8080e7          	jalr	-1288(ra) # 80001972 <cpuid>
    userinit();      // first user process
    inittweetlock();
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
    80000e9a:	adc080e7          	jalr	-1316(ra) # 80001972 <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6dc080e7          	jalr	1756(ra) # 80000584 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0e0080e7          	jalr	224(ra) # 80000f90 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	73c080e7          	jalr	1852(ra) # 800025f4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	de0080e7          	jalr	-544(ra) # 80005ca0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	fe8080e7          	jalr	-24(ra) # 80001eb0 <scheduler>
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
    80000f1c:	32a080e7          	jalr	810(ra) # 80001242 <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	070080e7          	jalr	112(ra) # 80000f90 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	99a080e7          	jalr	-1638(ra) # 800018c2 <procinit>
    trapinit();      // trap vectors
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	69c080e7          	jalr	1692(ra) # 800025cc <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	6bc080e7          	jalr	1724(ra) # 800025f4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	d4a080e7          	jalr	-694(ra) # 80005c8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	d58080e7          	jalr	-680(ra) # 80005ca0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	f1e080e7          	jalr	-226(ra) # 80002e6e <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	5ac080e7          	jalr	1452(ra) # 80003504 <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	55e080e7          	jalr	1374(ra) # 800044be <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	e58080e7          	jalr	-424(ra) # 80005dc0 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d06080e7          	jalr	-762(ra) # 80001c76 <userinit>
    inittweetlock();
    80000f78:	00005097          	auipc	ra,0x5
    80000f7c:	2da080e7          	jalr	730(ra) # 80006252 <inittweetlock>
    __sync_synchronize();
    80000f80:	0ff0000f          	fence
    started = 1;
    80000f84:	4785                	li	a5,1
    80000f86:	00008717          	auipc	a4,0x8
    80000f8a:	08f72923          	sw	a5,146(a4) # 80009018 <started>
    80000f8e:	bf2d                	j	80000ec8 <main+0x56>

0000000080000f90 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f90:	1141                	addi	sp,sp,-16
    80000f92:	e422                	sd	s0,8(sp)
    80000f94:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f96:	00008797          	auipc	a5,0x8
    80000f9a:	08a7b783          	ld	a5,138(a5) # 80009020 <kernel_pagetable>
    80000f9e:	83b1                	srli	a5,a5,0xc
    80000fa0:	577d                	li	a4,-1
    80000fa2:	177e                	slli	a4,a4,0x3f
    80000fa4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa6:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000faa:	12000073          	sfence.vma
  sfence_vma();
}
    80000fae:	6422                	ld	s0,8(sp)
    80000fb0:	0141                	addi	sp,sp,16
    80000fb2:	8082                	ret

0000000080000fb4 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb4:	7139                	addi	sp,sp,-64
    80000fb6:	fc06                	sd	ra,56(sp)
    80000fb8:	f822                	sd	s0,48(sp)
    80000fba:	f426                	sd	s1,40(sp)
    80000fbc:	f04a                	sd	s2,32(sp)
    80000fbe:	ec4e                	sd	s3,24(sp)
    80000fc0:	e852                	sd	s4,16(sp)
    80000fc2:	e456                	sd	s5,8(sp)
    80000fc4:	e05a                	sd	s6,0(sp)
    80000fc6:	0080                	addi	s0,sp,64
    80000fc8:	84aa                	mv	s1,a0
    80000fca:	89ae                	mv	s3,a1
    80000fcc:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fce:	57fd                	li	a5,-1
    80000fd0:	83e9                	srli	a5,a5,0x1a
    80000fd2:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd4:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd6:	04b7f263          	bgeu	a5,a1,8000101a <walk+0x66>
    panic("walk");
    80000fda:	00007517          	auipc	a0,0x7
    80000fde:	0f650513          	addi	a0,a0,246 # 800080d0 <digits+0x90>
    80000fe2:	fffff097          	auipc	ra,0xfffff
    80000fe6:	558080e7          	jalr	1368(ra) # 8000053a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fea:	060a8663          	beqz	s5,80001056 <walk+0xa2>
    80000fee:	00000097          	auipc	ra,0x0
    80000ff2:	af2080e7          	jalr	-1294(ra) # 80000ae0 <kalloc>
    80000ff6:	84aa                	mv	s1,a0
    80000ff8:	c529                	beqz	a0,80001042 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffa:	6605                	lui	a2,0x1
    80000ffc:	4581                	li	a1,0
    80000ffe:	00000097          	auipc	ra,0x0
    80001002:	cce080e7          	jalr	-818(ra) # 80000ccc <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001006:	00c4d793          	srli	a5,s1,0xc
    8000100a:	07aa                	slli	a5,a5,0xa
    8000100c:	0017e793          	ori	a5,a5,1
    80001010:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001014:	3a5d                	addiw	s4,s4,-9
    80001016:	036a0063          	beq	s4,s6,80001036 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101a:	0149d933          	srl	s2,s3,s4
    8000101e:	1ff97913          	andi	s2,s2,511
    80001022:	090e                	slli	s2,s2,0x3
    80001024:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001026:	00093483          	ld	s1,0(s2)
    8000102a:	0014f793          	andi	a5,s1,1
    8000102e:	dfd5                	beqz	a5,80000fea <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001030:	80a9                	srli	s1,s1,0xa
    80001032:	04b2                	slli	s1,s1,0xc
    80001034:	b7c5                	j	80001014 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001036:	00c9d513          	srli	a0,s3,0xc
    8000103a:	1ff57513          	andi	a0,a0,511
    8000103e:	050e                	slli	a0,a0,0x3
    80001040:	9526                	add	a0,a0,s1
}
    80001042:	70e2                	ld	ra,56(sp)
    80001044:	7442                	ld	s0,48(sp)
    80001046:	74a2                	ld	s1,40(sp)
    80001048:	7902                	ld	s2,32(sp)
    8000104a:	69e2                	ld	s3,24(sp)
    8000104c:	6a42                	ld	s4,16(sp)
    8000104e:	6aa2                	ld	s5,8(sp)
    80001050:	6b02                	ld	s6,0(sp)
    80001052:	6121                	addi	sp,sp,64
    80001054:	8082                	ret
        return 0;
    80001056:	4501                	li	a0,0
    80001058:	b7ed                	j	80001042 <walk+0x8e>

000000008000105a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105a:	57fd                	li	a5,-1
    8000105c:	83e9                	srli	a5,a5,0x1a
    8000105e:	00b7f463          	bgeu	a5,a1,80001066 <walkaddr+0xc>
    return 0;
    80001062:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001064:	8082                	ret
{
    80001066:	1141                	addi	sp,sp,-16
    80001068:	e406                	sd	ra,8(sp)
    8000106a:	e022                	sd	s0,0(sp)
    8000106c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106e:	4601                	li	a2,0
    80001070:	00000097          	auipc	ra,0x0
    80001074:	f44080e7          	jalr	-188(ra) # 80000fb4 <walk>
  if(pte == 0)
    80001078:	c105                	beqz	a0,80001098 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107c:	0117f693          	andi	a3,a5,17
    80001080:	4745                	li	a4,17
    return 0;
    80001082:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001084:	00e68663          	beq	a3,a4,80001090 <walkaddr+0x36>
}
    80001088:	60a2                	ld	ra,8(sp)
    8000108a:	6402                	ld	s0,0(sp)
    8000108c:	0141                	addi	sp,sp,16
    8000108e:	8082                	ret
  pa = PTE2PA(*pte);
    80001090:	83a9                	srli	a5,a5,0xa
    80001092:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001096:	bfcd                	j	80001088 <walkaddr+0x2e>
    return 0;
    80001098:	4501                	li	a0,0
    8000109a:	b7fd                	j	80001088 <walkaddr+0x2e>

000000008000109c <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109c:	715d                	addi	sp,sp,-80
    8000109e:	e486                	sd	ra,72(sp)
    800010a0:	e0a2                	sd	s0,64(sp)
    800010a2:	fc26                	sd	s1,56(sp)
    800010a4:	f84a                	sd	s2,48(sp)
    800010a6:	f44e                	sd	s3,40(sp)
    800010a8:	f052                	sd	s4,32(sp)
    800010aa:	ec56                	sd	s5,24(sp)
    800010ac:	e85a                	sd	s6,16(sp)
    800010ae:	e45e                	sd	s7,8(sp)
    800010b0:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b2:	c639                	beqz	a2,80001100 <mappages+0x64>
    800010b4:	8aaa                	mv	s5,a0
    800010b6:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b8:	777d                	lui	a4,0xfffff
    800010ba:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010be:	fff58993          	addi	s3,a1,-1
    800010c2:	99b2                	add	s3,s3,a2
    800010c4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c8:	893e                	mv	s2,a5
    800010ca:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ce:	6b85                	lui	s7,0x1
    800010d0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d4:	4605                	li	a2,1
    800010d6:	85ca                	mv	a1,s2
    800010d8:	8556                	mv	a0,s5
    800010da:	00000097          	auipc	ra,0x0
    800010de:	eda080e7          	jalr	-294(ra) # 80000fb4 <walk>
    800010e2:	cd1d                	beqz	a0,80001120 <mappages+0x84>
    if(*pte & PTE_V)
    800010e4:	611c                	ld	a5,0(a0)
    800010e6:	8b85                	andi	a5,a5,1
    800010e8:	e785                	bnez	a5,80001110 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ea:	80b1                	srli	s1,s1,0xc
    800010ec:	04aa                	slli	s1,s1,0xa
    800010ee:	0164e4b3          	or	s1,s1,s6
    800010f2:	0014e493          	ori	s1,s1,1
    800010f6:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f8:	05390063          	beq	s2,s3,80001138 <mappages+0x9c>
    a += PGSIZE;
    800010fc:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fe:	bfc9                	j	800010d0 <mappages+0x34>
    panic("mappages: size");
    80001100:	00007517          	auipc	a0,0x7
    80001104:	fd850513          	addi	a0,a0,-40 # 800080d8 <digits+0x98>
    80001108:	fffff097          	auipc	ra,0xfffff
    8000110c:	432080e7          	jalr	1074(ra) # 8000053a <panic>
      panic("mappages: remap");
    80001110:	00007517          	auipc	a0,0x7
    80001114:	fd850513          	addi	a0,a0,-40 # 800080e8 <digits+0xa8>
    80001118:	fffff097          	auipc	ra,0xfffff
    8000111c:	422080e7          	jalr	1058(ra) # 8000053a <panic>
      return -1;
    80001120:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001122:	60a6                	ld	ra,72(sp)
    80001124:	6406                	ld	s0,64(sp)
    80001126:	74e2                	ld	s1,56(sp)
    80001128:	7942                	ld	s2,48(sp)
    8000112a:	79a2                	ld	s3,40(sp)
    8000112c:	7a02                	ld	s4,32(sp)
    8000112e:	6ae2                	ld	s5,24(sp)
    80001130:	6b42                	ld	s6,16(sp)
    80001132:	6ba2                	ld	s7,8(sp)
    80001134:	6161                	addi	sp,sp,80
    80001136:	8082                	ret
  return 0;
    80001138:	4501                	li	a0,0
    8000113a:	b7e5                	j	80001122 <mappages+0x86>

000000008000113c <kvmmap>:
{
    8000113c:	1141                	addi	sp,sp,-16
    8000113e:	e406                	sd	ra,8(sp)
    80001140:	e022                	sd	s0,0(sp)
    80001142:	0800                	addi	s0,sp,16
    80001144:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001146:	86b2                	mv	a3,a2
    80001148:	863e                	mv	a2,a5
    8000114a:	00000097          	auipc	ra,0x0
    8000114e:	f52080e7          	jalr	-174(ra) # 8000109c <mappages>
    80001152:	e509                	bnez	a0,8000115c <kvmmap+0x20>
}
    80001154:	60a2                	ld	ra,8(sp)
    80001156:	6402                	ld	s0,0(sp)
    80001158:	0141                	addi	sp,sp,16
    8000115a:	8082                	ret
    panic("kvmmap");
    8000115c:	00007517          	auipc	a0,0x7
    80001160:	f9c50513          	addi	a0,a0,-100 # 800080f8 <digits+0xb8>
    80001164:	fffff097          	auipc	ra,0xfffff
    80001168:	3d6080e7          	jalr	982(ra) # 8000053a <panic>

000000008000116c <kvmmake>:
{
    8000116c:	1101                	addi	sp,sp,-32
    8000116e:	ec06                	sd	ra,24(sp)
    80001170:	e822                	sd	s0,16(sp)
    80001172:	e426                	sd	s1,8(sp)
    80001174:	e04a                	sd	s2,0(sp)
    80001176:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001178:	00000097          	auipc	ra,0x0
    8000117c:	968080e7          	jalr	-1688(ra) # 80000ae0 <kalloc>
    80001180:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001182:	6605                	lui	a2,0x1
    80001184:	4581                	li	a1,0
    80001186:	00000097          	auipc	ra,0x0
    8000118a:	b46080e7          	jalr	-1210(ra) # 80000ccc <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118e:	4719                	li	a4,6
    80001190:	6685                	lui	a3,0x1
    80001192:	10000637          	lui	a2,0x10000
    80001196:	100005b7          	lui	a1,0x10000
    8000119a:	8526                	mv	a0,s1
    8000119c:	00000097          	auipc	ra,0x0
    800011a0:	fa0080e7          	jalr	-96(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a4:	4719                	li	a4,6
    800011a6:	6685                	lui	a3,0x1
    800011a8:	10001637          	lui	a2,0x10001
    800011ac:	100015b7          	lui	a1,0x10001
    800011b0:	8526                	mv	a0,s1
    800011b2:	00000097          	auipc	ra,0x0
    800011b6:	f8a080e7          	jalr	-118(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011ba:	4719                	li	a4,6
    800011bc:	004006b7          	lui	a3,0x400
    800011c0:	0c000637          	lui	a2,0xc000
    800011c4:	0c0005b7          	lui	a1,0xc000
    800011c8:	8526                	mv	a0,s1
    800011ca:	00000097          	auipc	ra,0x0
    800011ce:	f72080e7          	jalr	-142(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d2:	00007917          	auipc	s2,0x7
    800011d6:	e2e90913          	addi	s2,s2,-466 # 80008000 <etext>
    800011da:	4729                	li	a4,10
    800011dc:	80007697          	auipc	a3,0x80007
    800011e0:	e2468693          	addi	a3,a3,-476 # 8000 <_entry-0x7fff8000>
    800011e4:	4605                	li	a2,1
    800011e6:	067e                	slli	a2,a2,0x1f
    800011e8:	85b2                	mv	a1,a2
    800011ea:	8526                	mv	a0,s1
    800011ec:	00000097          	auipc	ra,0x0
    800011f0:	f50080e7          	jalr	-176(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f4:	4719                	li	a4,6
    800011f6:	46c5                	li	a3,17
    800011f8:	06ee                	slli	a3,a3,0x1b
    800011fa:	412686b3          	sub	a3,a3,s2
    800011fe:	864a                	mv	a2,s2
    80001200:	85ca                	mv	a1,s2
    80001202:	8526                	mv	a0,s1
    80001204:	00000097          	auipc	ra,0x0
    80001208:	f38080e7          	jalr	-200(ra) # 8000113c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120c:	4729                	li	a4,10
    8000120e:	6685                	lui	a3,0x1
    80001210:	00006617          	auipc	a2,0x6
    80001214:	df060613          	addi	a2,a2,-528 # 80007000 <_trampoline>
    80001218:	040005b7          	lui	a1,0x4000
    8000121c:	15fd                	addi	a1,a1,-1
    8000121e:	05b2                	slli	a1,a1,0xc
    80001220:	8526                	mv	a0,s1
    80001222:	00000097          	auipc	ra,0x0
    80001226:	f1a080e7          	jalr	-230(ra) # 8000113c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122a:	8526                	mv	a0,s1
    8000122c:	00000097          	auipc	ra,0x0
    80001230:	600080e7          	jalr	1536(ra) # 8000182c <proc_mapstacks>
}
    80001234:	8526                	mv	a0,s1
    80001236:	60e2                	ld	ra,24(sp)
    80001238:	6442                	ld	s0,16(sp)
    8000123a:	64a2                	ld	s1,8(sp)
    8000123c:	6902                	ld	s2,0(sp)
    8000123e:	6105                	addi	sp,sp,32
    80001240:	8082                	ret

0000000080001242 <kvminit>:
{
    80001242:	1141                	addi	sp,sp,-16
    80001244:	e406                	sd	ra,8(sp)
    80001246:	e022                	sd	s0,0(sp)
    80001248:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	f22080e7          	jalr	-222(ra) # 8000116c <kvmmake>
    80001252:	00008797          	auipc	a5,0x8
    80001256:	dca7b723          	sd	a0,-562(a5) # 80009020 <kernel_pagetable>
}
    8000125a:	60a2                	ld	ra,8(sp)
    8000125c:	6402                	ld	s0,0(sp)
    8000125e:	0141                	addi	sp,sp,16
    80001260:	8082                	ret

0000000080001262 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001262:	715d                	addi	sp,sp,-80
    80001264:	e486                	sd	ra,72(sp)
    80001266:	e0a2                	sd	s0,64(sp)
    80001268:	fc26                	sd	s1,56(sp)
    8000126a:	f84a                	sd	s2,48(sp)
    8000126c:	f44e                	sd	s3,40(sp)
    8000126e:	f052                	sd	s4,32(sp)
    80001270:	ec56                	sd	s5,24(sp)
    80001272:	e85a                	sd	s6,16(sp)
    80001274:	e45e                	sd	s7,8(sp)
    80001276:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001278:	03459793          	slli	a5,a1,0x34
    8000127c:	e795                	bnez	a5,800012a8 <uvmunmap+0x46>
    8000127e:	8a2a                	mv	s4,a0
    80001280:	892e                	mv	s2,a1
    80001282:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001284:	0632                	slli	a2,a2,0xc
    80001286:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128c:	6b05                	lui	s6,0x1
    8000128e:	0735e263          	bltu	a1,s3,800012f2 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001292:	60a6                	ld	ra,72(sp)
    80001294:	6406                	ld	s0,64(sp)
    80001296:	74e2                	ld	s1,56(sp)
    80001298:	7942                	ld	s2,48(sp)
    8000129a:	79a2                	ld	s3,40(sp)
    8000129c:	7a02                	ld	s4,32(sp)
    8000129e:	6ae2                	ld	s5,24(sp)
    800012a0:	6b42                	ld	s6,16(sp)
    800012a2:	6ba2                	ld	s7,8(sp)
    800012a4:	6161                	addi	sp,sp,80
    800012a6:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a8:	00007517          	auipc	a0,0x7
    800012ac:	e5850513          	addi	a0,a0,-424 # 80008100 <digits+0xc0>
    800012b0:	fffff097          	auipc	ra,0xfffff
    800012b4:	28a080e7          	jalr	650(ra) # 8000053a <panic>
      panic("uvmunmap: walk");
    800012b8:	00007517          	auipc	a0,0x7
    800012bc:	e6050513          	addi	a0,a0,-416 # 80008118 <digits+0xd8>
    800012c0:	fffff097          	auipc	ra,0xfffff
    800012c4:	27a080e7          	jalr	634(ra) # 8000053a <panic>
      panic("uvmunmap: not mapped");
    800012c8:	00007517          	auipc	a0,0x7
    800012cc:	e6050513          	addi	a0,a0,-416 # 80008128 <digits+0xe8>
    800012d0:	fffff097          	auipc	ra,0xfffff
    800012d4:	26a080e7          	jalr	618(ra) # 8000053a <panic>
      panic("uvmunmap: not a leaf");
    800012d8:	00007517          	auipc	a0,0x7
    800012dc:	e6850513          	addi	a0,a0,-408 # 80008140 <digits+0x100>
    800012e0:	fffff097          	auipc	ra,0xfffff
    800012e4:	25a080e7          	jalr	602(ra) # 8000053a <panic>
    *pte = 0;
    800012e8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ec:	995a                	add	s2,s2,s6
    800012ee:	fb3972e3          	bgeu	s2,s3,80001292 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f2:	4601                	li	a2,0
    800012f4:	85ca                	mv	a1,s2
    800012f6:	8552                	mv	a0,s4
    800012f8:	00000097          	auipc	ra,0x0
    800012fc:	cbc080e7          	jalr	-836(ra) # 80000fb4 <walk>
    80001300:	84aa                	mv	s1,a0
    80001302:	d95d                	beqz	a0,800012b8 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001304:	6108                	ld	a0,0(a0)
    80001306:	00157793          	andi	a5,a0,1
    8000130a:	dfdd                	beqz	a5,800012c8 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130c:	3ff57793          	andi	a5,a0,1023
    80001310:	fd7784e3          	beq	a5,s7,800012d8 <uvmunmap+0x76>
    if(do_free){
    80001314:	fc0a8ae3          	beqz	s5,800012e8 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001318:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131a:	0532                	slli	a0,a0,0xc
    8000131c:	fffff097          	auipc	ra,0xfffff
    80001320:	6c6080e7          	jalr	1734(ra) # 800009e2 <kfree>
    80001324:	b7d1                	j	800012e8 <uvmunmap+0x86>

0000000080001326 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001326:	1101                	addi	sp,sp,-32
    80001328:	ec06                	sd	ra,24(sp)
    8000132a:	e822                	sd	s0,16(sp)
    8000132c:	e426                	sd	s1,8(sp)
    8000132e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001330:	fffff097          	auipc	ra,0xfffff
    80001334:	7b0080e7          	jalr	1968(ra) # 80000ae0 <kalloc>
    80001338:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133a:	c519                	beqz	a0,80001348 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133c:	6605                	lui	a2,0x1
    8000133e:	4581                	li	a1,0
    80001340:	00000097          	auipc	ra,0x0
    80001344:	98c080e7          	jalr	-1652(ra) # 80000ccc <memset>
  return pagetable;
}
    80001348:	8526                	mv	a0,s1
    8000134a:	60e2                	ld	ra,24(sp)
    8000134c:	6442                	ld	s0,16(sp)
    8000134e:	64a2                	ld	s1,8(sp)
    80001350:	6105                	addi	sp,sp,32
    80001352:	8082                	ret

0000000080001354 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001354:	7179                	addi	sp,sp,-48
    80001356:	f406                	sd	ra,40(sp)
    80001358:	f022                	sd	s0,32(sp)
    8000135a:	ec26                	sd	s1,24(sp)
    8000135c:	e84a                	sd	s2,16(sp)
    8000135e:	e44e                	sd	s3,8(sp)
    80001360:	e052                	sd	s4,0(sp)
    80001362:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001364:	6785                	lui	a5,0x1
    80001366:	04f67863          	bgeu	a2,a5,800013b6 <uvminit+0x62>
    8000136a:	8a2a                	mv	s4,a0
    8000136c:	89ae                	mv	s3,a1
    8000136e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001370:	fffff097          	auipc	ra,0xfffff
    80001374:	770080e7          	jalr	1904(ra) # 80000ae0 <kalloc>
    80001378:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137a:	6605                	lui	a2,0x1
    8000137c:	4581                	li	a1,0
    8000137e:	00000097          	auipc	ra,0x0
    80001382:	94e080e7          	jalr	-1714(ra) # 80000ccc <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001386:	4779                	li	a4,30
    80001388:	86ca                	mv	a3,s2
    8000138a:	6605                	lui	a2,0x1
    8000138c:	4581                	li	a1,0
    8000138e:	8552                	mv	a0,s4
    80001390:	00000097          	auipc	ra,0x0
    80001394:	d0c080e7          	jalr	-756(ra) # 8000109c <mappages>
  memmove(mem, src, sz);
    80001398:	8626                	mv	a2,s1
    8000139a:	85ce                	mv	a1,s3
    8000139c:	854a                	mv	a0,s2
    8000139e:	00000097          	auipc	ra,0x0
    800013a2:	98a080e7          	jalr	-1654(ra) # 80000d28 <memmove>
}
    800013a6:	70a2                	ld	ra,40(sp)
    800013a8:	7402                	ld	s0,32(sp)
    800013aa:	64e2                	ld	s1,24(sp)
    800013ac:	6942                	ld	s2,16(sp)
    800013ae:	69a2                	ld	s3,8(sp)
    800013b0:	6a02                	ld	s4,0(sp)
    800013b2:	6145                	addi	sp,sp,48
    800013b4:	8082                	ret
    panic("inituvm: more than a page");
    800013b6:	00007517          	auipc	a0,0x7
    800013ba:	da250513          	addi	a0,a0,-606 # 80008158 <digits+0x118>
    800013be:	fffff097          	auipc	ra,0xfffff
    800013c2:	17c080e7          	jalr	380(ra) # 8000053a <panic>

00000000800013c6 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c6:	1101                	addi	sp,sp,-32
    800013c8:	ec06                	sd	ra,24(sp)
    800013ca:	e822                	sd	s0,16(sp)
    800013cc:	e426                	sd	s1,8(sp)
    800013ce:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d0:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d2:	00b67d63          	bgeu	a2,a1,800013ec <uvmdealloc+0x26>
    800013d6:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d8:	6785                	lui	a5,0x1
    800013da:	17fd                	addi	a5,a5,-1
    800013dc:	00f60733          	add	a4,a2,a5
    800013e0:	76fd                	lui	a3,0xfffff
    800013e2:	8f75                	and	a4,a4,a3
    800013e4:	97ae                	add	a5,a5,a1
    800013e6:	8ff5                	and	a5,a5,a3
    800013e8:	00f76863          	bltu	a4,a5,800013f8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ec:	8526                	mv	a0,s1
    800013ee:	60e2                	ld	ra,24(sp)
    800013f0:	6442                	ld	s0,16(sp)
    800013f2:	64a2                	ld	s1,8(sp)
    800013f4:	6105                	addi	sp,sp,32
    800013f6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f8:	8f99                	sub	a5,a5,a4
    800013fa:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fc:	4685                	li	a3,1
    800013fe:	0007861b          	sext.w	a2,a5
    80001402:	85ba                	mv	a1,a4
    80001404:	00000097          	auipc	ra,0x0
    80001408:	e5e080e7          	jalr	-418(ra) # 80001262 <uvmunmap>
    8000140c:	b7c5                	j	800013ec <uvmdealloc+0x26>

000000008000140e <uvmalloc>:
  if(newsz < oldsz)
    8000140e:	0ab66163          	bltu	a2,a1,800014b0 <uvmalloc+0xa2>
{
    80001412:	7139                	addi	sp,sp,-64
    80001414:	fc06                	sd	ra,56(sp)
    80001416:	f822                	sd	s0,48(sp)
    80001418:	f426                	sd	s1,40(sp)
    8000141a:	f04a                	sd	s2,32(sp)
    8000141c:	ec4e                	sd	s3,24(sp)
    8000141e:	e852                	sd	s4,16(sp)
    80001420:	e456                	sd	s5,8(sp)
    80001422:	0080                	addi	s0,sp,64
    80001424:	8aaa                	mv	s5,a0
    80001426:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001428:	6785                	lui	a5,0x1
    8000142a:	17fd                	addi	a5,a5,-1
    8000142c:	95be                	add	a1,a1,a5
    8000142e:	77fd                	lui	a5,0xfffff
    80001430:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001434:	08c9f063          	bgeu	s3,a2,800014b4 <uvmalloc+0xa6>
    80001438:	894e                	mv	s2,s3
    mem = kalloc();
    8000143a:	fffff097          	auipc	ra,0xfffff
    8000143e:	6a6080e7          	jalr	1702(ra) # 80000ae0 <kalloc>
    80001442:	84aa                	mv	s1,a0
    if(mem == 0){
    80001444:	c51d                	beqz	a0,80001472 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001446:	6605                	lui	a2,0x1
    80001448:	4581                	li	a1,0
    8000144a:	00000097          	auipc	ra,0x0
    8000144e:	882080e7          	jalr	-1918(ra) # 80000ccc <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001452:	4779                	li	a4,30
    80001454:	86a6                	mv	a3,s1
    80001456:	6605                	lui	a2,0x1
    80001458:	85ca                	mv	a1,s2
    8000145a:	8556                	mv	a0,s5
    8000145c:	00000097          	auipc	ra,0x0
    80001460:	c40080e7          	jalr	-960(ra) # 8000109c <mappages>
    80001464:	e905                	bnez	a0,80001494 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001466:	6785                	lui	a5,0x1
    80001468:	993e                	add	s2,s2,a5
    8000146a:	fd4968e3          	bltu	s2,s4,8000143a <uvmalloc+0x2c>
  return newsz;
    8000146e:	8552                	mv	a0,s4
    80001470:	a809                	j	80001482 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001472:	864e                	mv	a2,s3
    80001474:	85ca                	mv	a1,s2
    80001476:	8556                	mv	a0,s5
    80001478:	00000097          	auipc	ra,0x0
    8000147c:	f4e080e7          	jalr	-178(ra) # 800013c6 <uvmdealloc>
      return 0;
    80001480:	4501                	li	a0,0
}
    80001482:	70e2                	ld	ra,56(sp)
    80001484:	7442                	ld	s0,48(sp)
    80001486:	74a2                	ld	s1,40(sp)
    80001488:	7902                	ld	s2,32(sp)
    8000148a:	69e2                	ld	s3,24(sp)
    8000148c:	6a42                	ld	s4,16(sp)
    8000148e:	6aa2                	ld	s5,8(sp)
    80001490:	6121                	addi	sp,sp,64
    80001492:	8082                	ret
      kfree(mem);
    80001494:	8526                	mv	a0,s1
    80001496:	fffff097          	auipc	ra,0xfffff
    8000149a:	54c080e7          	jalr	1356(ra) # 800009e2 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000149e:	864e                	mv	a2,s3
    800014a0:	85ca                	mv	a1,s2
    800014a2:	8556                	mv	a0,s5
    800014a4:	00000097          	auipc	ra,0x0
    800014a8:	f22080e7          	jalr	-222(ra) # 800013c6 <uvmdealloc>
      return 0;
    800014ac:	4501                	li	a0,0
    800014ae:	bfd1                	j	80001482 <uvmalloc+0x74>
    return oldsz;
    800014b0:	852e                	mv	a0,a1
}
    800014b2:	8082                	ret
  return newsz;
    800014b4:	8532                	mv	a0,a2
    800014b6:	b7f1                	j	80001482 <uvmalloc+0x74>

00000000800014b8 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014b8:	7179                	addi	sp,sp,-48
    800014ba:	f406                	sd	ra,40(sp)
    800014bc:	f022                	sd	s0,32(sp)
    800014be:	ec26                	sd	s1,24(sp)
    800014c0:	e84a                	sd	s2,16(sp)
    800014c2:	e44e                	sd	s3,8(sp)
    800014c4:	e052                	sd	s4,0(sp)
    800014c6:	1800                	addi	s0,sp,48
    800014c8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ca:	84aa                	mv	s1,a0
    800014cc:	6905                	lui	s2,0x1
    800014ce:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d0:	4985                	li	s3,1
    800014d2:	a829                	j	800014ec <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d4:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014d6:	00c79513          	slli	a0,a5,0xc
    800014da:	00000097          	auipc	ra,0x0
    800014de:	fde080e7          	jalr	-34(ra) # 800014b8 <freewalk>
      pagetable[i] = 0;
    800014e2:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014e6:	04a1                	addi	s1,s1,8
    800014e8:	03248163          	beq	s1,s2,8000150a <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014ec:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014ee:	00f7f713          	andi	a4,a5,15
    800014f2:	ff3701e3          	beq	a4,s3,800014d4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014f6:	8b85                	andi	a5,a5,1
    800014f8:	d7fd                	beqz	a5,800014e6 <freewalk+0x2e>
      panic("freewalk: leaf");
    800014fa:	00007517          	auipc	a0,0x7
    800014fe:	c7e50513          	addi	a0,a0,-898 # 80008178 <digits+0x138>
    80001502:	fffff097          	auipc	ra,0xfffff
    80001506:	038080e7          	jalr	56(ra) # 8000053a <panic>
    }
  }
  kfree((void*)pagetable);
    8000150a:	8552                	mv	a0,s4
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	4d6080e7          	jalr	1238(ra) # 800009e2 <kfree>
}
    80001514:	70a2                	ld	ra,40(sp)
    80001516:	7402                	ld	s0,32(sp)
    80001518:	64e2                	ld	s1,24(sp)
    8000151a:	6942                	ld	s2,16(sp)
    8000151c:	69a2                	ld	s3,8(sp)
    8000151e:	6a02                	ld	s4,0(sp)
    80001520:	6145                	addi	sp,sp,48
    80001522:	8082                	ret

0000000080001524 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001524:	1101                	addi	sp,sp,-32
    80001526:	ec06                	sd	ra,24(sp)
    80001528:	e822                	sd	s0,16(sp)
    8000152a:	e426                	sd	s1,8(sp)
    8000152c:	1000                	addi	s0,sp,32
    8000152e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001530:	e999                	bnez	a1,80001546 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001532:	8526                	mv	a0,s1
    80001534:	00000097          	auipc	ra,0x0
    80001538:	f84080e7          	jalr	-124(ra) # 800014b8 <freewalk>
}
    8000153c:	60e2                	ld	ra,24(sp)
    8000153e:	6442                	ld	s0,16(sp)
    80001540:	64a2                	ld	s1,8(sp)
    80001542:	6105                	addi	sp,sp,32
    80001544:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001546:	6785                	lui	a5,0x1
    80001548:	17fd                	addi	a5,a5,-1
    8000154a:	95be                	add	a1,a1,a5
    8000154c:	4685                	li	a3,1
    8000154e:	00c5d613          	srli	a2,a1,0xc
    80001552:	4581                	li	a1,0
    80001554:	00000097          	auipc	ra,0x0
    80001558:	d0e080e7          	jalr	-754(ra) # 80001262 <uvmunmap>
    8000155c:	bfd9                	j	80001532 <uvmfree+0xe>

000000008000155e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000155e:	c679                	beqz	a2,8000162c <uvmcopy+0xce>
{
    80001560:	715d                	addi	sp,sp,-80
    80001562:	e486                	sd	ra,72(sp)
    80001564:	e0a2                	sd	s0,64(sp)
    80001566:	fc26                	sd	s1,56(sp)
    80001568:	f84a                	sd	s2,48(sp)
    8000156a:	f44e                	sd	s3,40(sp)
    8000156c:	f052                	sd	s4,32(sp)
    8000156e:	ec56                	sd	s5,24(sp)
    80001570:	e85a                	sd	s6,16(sp)
    80001572:	e45e                	sd	s7,8(sp)
    80001574:	0880                	addi	s0,sp,80
    80001576:	8b2a                	mv	s6,a0
    80001578:	8aae                	mv	s5,a1
    8000157a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000157c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000157e:	4601                	li	a2,0
    80001580:	85ce                	mv	a1,s3
    80001582:	855a                	mv	a0,s6
    80001584:	00000097          	auipc	ra,0x0
    80001588:	a30080e7          	jalr	-1488(ra) # 80000fb4 <walk>
    8000158c:	c531                	beqz	a0,800015d8 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000158e:	6118                	ld	a4,0(a0)
    80001590:	00177793          	andi	a5,a4,1
    80001594:	cbb1                	beqz	a5,800015e8 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001596:	00a75593          	srli	a1,a4,0xa
    8000159a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000159e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a2:	fffff097          	auipc	ra,0xfffff
    800015a6:	53e080e7          	jalr	1342(ra) # 80000ae0 <kalloc>
    800015aa:	892a                	mv	s2,a0
    800015ac:	c939                	beqz	a0,80001602 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015ae:	6605                	lui	a2,0x1
    800015b0:	85de                	mv	a1,s7
    800015b2:	fffff097          	auipc	ra,0xfffff
    800015b6:	776080e7          	jalr	1910(ra) # 80000d28 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ba:	8726                	mv	a4,s1
    800015bc:	86ca                	mv	a3,s2
    800015be:	6605                	lui	a2,0x1
    800015c0:	85ce                	mv	a1,s3
    800015c2:	8556                	mv	a0,s5
    800015c4:	00000097          	auipc	ra,0x0
    800015c8:	ad8080e7          	jalr	-1320(ra) # 8000109c <mappages>
    800015cc:	e515                	bnez	a0,800015f8 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015ce:	6785                	lui	a5,0x1
    800015d0:	99be                	add	s3,s3,a5
    800015d2:	fb49e6e3          	bltu	s3,s4,8000157e <uvmcopy+0x20>
    800015d6:	a081                	j	80001616 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015d8:	00007517          	auipc	a0,0x7
    800015dc:	bb050513          	addi	a0,a0,-1104 # 80008188 <digits+0x148>
    800015e0:	fffff097          	auipc	ra,0xfffff
    800015e4:	f5a080e7          	jalr	-166(ra) # 8000053a <panic>
      panic("uvmcopy: page not present");
    800015e8:	00007517          	auipc	a0,0x7
    800015ec:	bc050513          	addi	a0,a0,-1088 # 800081a8 <digits+0x168>
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	f4a080e7          	jalr	-182(ra) # 8000053a <panic>
      kfree(mem);
    800015f8:	854a                	mv	a0,s2
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	3e8080e7          	jalr	1000(ra) # 800009e2 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001602:	4685                	li	a3,1
    80001604:	00c9d613          	srli	a2,s3,0xc
    80001608:	4581                	li	a1,0
    8000160a:	8556                	mv	a0,s5
    8000160c:	00000097          	auipc	ra,0x0
    80001610:	c56080e7          	jalr	-938(ra) # 80001262 <uvmunmap>
  return -1;
    80001614:	557d                	li	a0,-1
}
    80001616:	60a6                	ld	ra,72(sp)
    80001618:	6406                	ld	s0,64(sp)
    8000161a:	74e2                	ld	s1,56(sp)
    8000161c:	7942                	ld	s2,48(sp)
    8000161e:	79a2                	ld	s3,40(sp)
    80001620:	7a02                	ld	s4,32(sp)
    80001622:	6ae2                	ld	s5,24(sp)
    80001624:	6b42                	ld	s6,16(sp)
    80001626:	6ba2                	ld	s7,8(sp)
    80001628:	6161                	addi	sp,sp,80
    8000162a:	8082                	ret
  return 0;
    8000162c:	4501                	li	a0,0
}
    8000162e:	8082                	ret

0000000080001630 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001630:	1141                	addi	sp,sp,-16
    80001632:	e406                	sd	ra,8(sp)
    80001634:	e022                	sd	s0,0(sp)
    80001636:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001638:	4601                	li	a2,0
    8000163a:	00000097          	auipc	ra,0x0
    8000163e:	97a080e7          	jalr	-1670(ra) # 80000fb4 <walk>
  if(pte == 0)
    80001642:	c901                	beqz	a0,80001652 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001644:	611c                	ld	a5,0(a0)
    80001646:	9bbd                	andi	a5,a5,-17
    80001648:	e11c                	sd	a5,0(a0)
}
    8000164a:	60a2                	ld	ra,8(sp)
    8000164c:	6402                	ld	s0,0(sp)
    8000164e:	0141                	addi	sp,sp,16
    80001650:	8082                	ret
    panic("uvmclear");
    80001652:	00007517          	auipc	a0,0x7
    80001656:	b7650513          	addi	a0,a0,-1162 # 800081c8 <digits+0x188>
    8000165a:	fffff097          	auipc	ra,0xfffff
    8000165e:	ee0080e7          	jalr	-288(ra) # 8000053a <panic>

0000000080001662 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001662:	c6bd                	beqz	a3,800016d0 <copyout+0x6e>
{
    80001664:	715d                	addi	sp,sp,-80
    80001666:	e486                	sd	ra,72(sp)
    80001668:	e0a2                	sd	s0,64(sp)
    8000166a:	fc26                	sd	s1,56(sp)
    8000166c:	f84a                	sd	s2,48(sp)
    8000166e:	f44e                	sd	s3,40(sp)
    80001670:	f052                	sd	s4,32(sp)
    80001672:	ec56                	sd	s5,24(sp)
    80001674:	e85a                	sd	s6,16(sp)
    80001676:	e45e                	sd	s7,8(sp)
    80001678:	e062                	sd	s8,0(sp)
    8000167a:	0880                	addi	s0,sp,80
    8000167c:	8b2a                	mv	s6,a0
    8000167e:	8c2e                	mv	s8,a1
    80001680:	8a32                	mv	s4,a2
    80001682:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001684:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001686:	6a85                	lui	s5,0x1
    80001688:	a015                	j	800016ac <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168a:	9562                	add	a0,a0,s8
    8000168c:	0004861b          	sext.w	a2,s1
    80001690:	85d2                	mv	a1,s4
    80001692:	41250533          	sub	a0,a0,s2
    80001696:	fffff097          	auipc	ra,0xfffff
    8000169a:	692080e7          	jalr	1682(ra) # 80000d28 <memmove>

    len -= n;
    8000169e:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016a8:	02098263          	beqz	s3,800016cc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ac:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b0:	85ca                	mv	a1,s2
    800016b2:	855a                	mv	a0,s6
    800016b4:	00000097          	auipc	ra,0x0
    800016b8:	9a6080e7          	jalr	-1626(ra) # 8000105a <walkaddr>
    if(pa0 == 0)
    800016bc:	cd01                	beqz	a0,800016d4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016be:	418904b3          	sub	s1,s2,s8
    800016c2:	94d6                	add	s1,s1,s5
    800016c4:	fc99f3e3          	bgeu	s3,s1,8000168a <copyout+0x28>
    800016c8:	84ce                	mv	s1,s3
    800016ca:	b7c1                	j	8000168a <copyout+0x28>
  }
  return 0;
    800016cc:	4501                	li	a0,0
    800016ce:	a021                	j	800016d6 <copyout+0x74>
    800016d0:	4501                	li	a0,0
}
    800016d2:	8082                	ret
      return -1;
    800016d4:	557d                	li	a0,-1
}
    800016d6:	60a6                	ld	ra,72(sp)
    800016d8:	6406                	ld	s0,64(sp)
    800016da:	74e2                	ld	s1,56(sp)
    800016dc:	7942                	ld	s2,48(sp)
    800016de:	79a2                	ld	s3,40(sp)
    800016e0:	7a02                	ld	s4,32(sp)
    800016e2:	6ae2                	ld	s5,24(sp)
    800016e4:	6b42                	ld	s6,16(sp)
    800016e6:	6ba2                	ld	s7,8(sp)
    800016e8:	6c02                	ld	s8,0(sp)
    800016ea:	6161                	addi	sp,sp,80
    800016ec:	8082                	ret

00000000800016ee <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016ee:	caa5                	beqz	a3,8000175e <copyin+0x70>
{
    800016f0:	715d                	addi	sp,sp,-80
    800016f2:	e486                	sd	ra,72(sp)
    800016f4:	e0a2                	sd	s0,64(sp)
    800016f6:	fc26                	sd	s1,56(sp)
    800016f8:	f84a                	sd	s2,48(sp)
    800016fa:	f44e                	sd	s3,40(sp)
    800016fc:	f052                	sd	s4,32(sp)
    800016fe:	ec56                	sd	s5,24(sp)
    80001700:	e85a                	sd	s6,16(sp)
    80001702:	e45e                	sd	s7,8(sp)
    80001704:	e062                	sd	s8,0(sp)
    80001706:	0880                	addi	s0,sp,80
    80001708:	8b2a                	mv	s6,a0
    8000170a:	8a2e                	mv	s4,a1
    8000170c:	8c32                	mv	s8,a2
    8000170e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001710:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001712:	6a85                	lui	s5,0x1
    80001714:	a01d                	j	8000173a <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001716:	018505b3          	add	a1,a0,s8
    8000171a:	0004861b          	sext.w	a2,s1
    8000171e:	412585b3          	sub	a1,a1,s2
    80001722:	8552                	mv	a0,s4
    80001724:	fffff097          	auipc	ra,0xfffff
    80001728:	604080e7          	jalr	1540(ra) # 80000d28 <memmove>

    len -= n;
    8000172c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001730:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001732:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001736:	02098263          	beqz	s3,8000175a <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000173e:	85ca                	mv	a1,s2
    80001740:	855a                	mv	a0,s6
    80001742:	00000097          	auipc	ra,0x0
    80001746:	918080e7          	jalr	-1768(ra) # 8000105a <walkaddr>
    if(pa0 == 0)
    8000174a:	cd01                	beqz	a0,80001762 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000174c:	418904b3          	sub	s1,s2,s8
    80001750:	94d6                	add	s1,s1,s5
    80001752:	fc99f2e3          	bgeu	s3,s1,80001716 <copyin+0x28>
    80001756:	84ce                	mv	s1,s3
    80001758:	bf7d                	j	80001716 <copyin+0x28>
  }
  return 0;
    8000175a:	4501                	li	a0,0
    8000175c:	a021                	j	80001764 <copyin+0x76>
    8000175e:	4501                	li	a0,0
}
    80001760:	8082                	ret
      return -1;
    80001762:	557d                	li	a0,-1
}
    80001764:	60a6                	ld	ra,72(sp)
    80001766:	6406                	ld	s0,64(sp)
    80001768:	74e2                	ld	s1,56(sp)
    8000176a:	7942                	ld	s2,48(sp)
    8000176c:	79a2                	ld	s3,40(sp)
    8000176e:	7a02                	ld	s4,32(sp)
    80001770:	6ae2                	ld	s5,24(sp)
    80001772:	6b42                	ld	s6,16(sp)
    80001774:	6ba2                	ld	s7,8(sp)
    80001776:	6c02                	ld	s8,0(sp)
    80001778:	6161                	addi	sp,sp,80
    8000177a:	8082                	ret

000000008000177c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000177c:	c2dd                	beqz	a3,80001822 <copyinstr+0xa6>
{
    8000177e:	715d                	addi	sp,sp,-80
    80001780:	e486                	sd	ra,72(sp)
    80001782:	e0a2                	sd	s0,64(sp)
    80001784:	fc26                	sd	s1,56(sp)
    80001786:	f84a                	sd	s2,48(sp)
    80001788:	f44e                	sd	s3,40(sp)
    8000178a:	f052                	sd	s4,32(sp)
    8000178c:	ec56                	sd	s5,24(sp)
    8000178e:	e85a                	sd	s6,16(sp)
    80001790:	e45e                	sd	s7,8(sp)
    80001792:	0880                	addi	s0,sp,80
    80001794:	8a2a                	mv	s4,a0
    80001796:	8b2e                	mv	s6,a1
    80001798:	8bb2                	mv	s7,a2
    8000179a:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000179c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000179e:	6985                	lui	s3,0x1
    800017a0:	a02d                	j	800017ca <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017a6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017a8:	37fd                	addiw	a5,a5,-1
    800017aa:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017ae:	60a6                	ld	ra,72(sp)
    800017b0:	6406                	ld	s0,64(sp)
    800017b2:	74e2                	ld	s1,56(sp)
    800017b4:	7942                	ld	s2,48(sp)
    800017b6:	79a2                	ld	s3,40(sp)
    800017b8:	7a02                	ld	s4,32(sp)
    800017ba:	6ae2                	ld	s5,24(sp)
    800017bc:	6b42                	ld	s6,16(sp)
    800017be:	6ba2                	ld	s7,8(sp)
    800017c0:	6161                	addi	sp,sp,80
    800017c2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017c8:	c8a9                	beqz	s1,8000181a <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017ca:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017ce:	85ca                	mv	a1,s2
    800017d0:	8552                	mv	a0,s4
    800017d2:	00000097          	auipc	ra,0x0
    800017d6:	888080e7          	jalr	-1912(ra) # 8000105a <walkaddr>
    if(pa0 == 0)
    800017da:	c131                	beqz	a0,8000181e <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017dc:	417906b3          	sub	a3,s2,s7
    800017e0:	96ce                	add	a3,a3,s3
    800017e2:	00d4f363          	bgeu	s1,a3,800017e8 <copyinstr+0x6c>
    800017e6:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017e8:	955e                	add	a0,a0,s7
    800017ea:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017ee:	daf9                	beqz	a3,800017c4 <copyinstr+0x48>
    800017f0:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017f2:	41650633          	sub	a2,a0,s6
    800017f6:	fff48593          	addi	a1,s1,-1
    800017fa:	95da                	add	a1,a1,s6
    while(n > 0){
    800017fc:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800017fe:	00f60733          	add	a4,a2,a5
    80001802:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd8238>
    80001806:	df51                	beqz	a4,800017a2 <copyinstr+0x26>
        *dst = *p;
    80001808:	00e78023          	sb	a4,0(a5)
      --max;
    8000180c:	40f584b3          	sub	s1,a1,a5
      dst++;
    80001810:	0785                	addi	a5,a5,1
    while(n > 0){
    80001812:	fed796e3          	bne	a5,a3,800017fe <copyinstr+0x82>
      dst++;
    80001816:	8b3e                	mv	s6,a5
    80001818:	b775                	j	800017c4 <copyinstr+0x48>
    8000181a:	4781                	li	a5,0
    8000181c:	b771                	j	800017a8 <copyinstr+0x2c>
      return -1;
    8000181e:	557d                	li	a0,-1
    80001820:	b779                	j	800017ae <copyinstr+0x32>
  int got_null = 0;
    80001822:	4781                	li	a5,0
  if(got_null){
    80001824:	37fd                	addiw	a5,a5,-1
    80001826:	0007851b          	sext.w	a0,a5
}
    8000182a:	8082                	ret

000000008000182c <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000182c:	7139                	addi	sp,sp,-64
    8000182e:	fc06                	sd	ra,56(sp)
    80001830:	f822                	sd	s0,48(sp)
    80001832:	f426                	sd	s1,40(sp)
    80001834:	f04a                	sd	s2,32(sp)
    80001836:	ec4e                	sd	s3,24(sp)
    80001838:	e852                	sd	s4,16(sp)
    8000183a:	e456                	sd	s5,8(sp)
    8000183c:	e05a                	sd	s6,0(sp)
    8000183e:	0080                	addi	s0,sp,64
    80001840:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001842:	00010497          	auipc	s1,0x10
    80001846:	e8e48493          	addi	s1,s1,-370 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000184a:	8b26                	mv	s6,s1
    8000184c:	00006a97          	auipc	s5,0x6
    80001850:	7b4a8a93          	addi	s5,s5,1972 # 80008000 <etext>
    80001854:	04000937          	lui	s2,0x4000
    80001858:	197d                	addi	s2,s2,-1
    8000185a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185c:	00016a17          	auipc	s4,0x16
    80001860:	874a0a13          	addi	s4,s4,-1932 # 800170d0 <tickslock>
    char *pa = kalloc();
    80001864:	fffff097          	auipc	ra,0xfffff
    80001868:	27c080e7          	jalr	636(ra) # 80000ae0 <kalloc>
    8000186c:	862a                	mv	a2,a0
    if(pa == 0)
    8000186e:	c131                	beqz	a0,800018b2 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001870:	416485b3          	sub	a1,s1,s6
    80001874:	858d                	srai	a1,a1,0x3
    80001876:	000ab783          	ld	a5,0(s5)
    8000187a:	02f585b3          	mul	a1,a1,a5
    8000187e:	2585                	addiw	a1,a1,1
    80001880:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001884:	4719                	li	a4,6
    80001886:	6685                	lui	a3,0x1
    80001888:	40b905b3          	sub	a1,s2,a1
    8000188c:	854e                	mv	a0,s3
    8000188e:	00000097          	auipc	ra,0x0
    80001892:	8ae080e7          	jalr	-1874(ra) # 8000113c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001896:	16848493          	addi	s1,s1,360
    8000189a:	fd4495e3          	bne	s1,s4,80001864 <proc_mapstacks+0x38>
  }
}
    8000189e:	70e2                	ld	ra,56(sp)
    800018a0:	7442                	ld	s0,48(sp)
    800018a2:	74a2                	ld	s1,40(sp)
    800018a4:	7902                	ld	s2,32(sp)
    800018a6:	69e2                	ld	s3,24(sp)
    800018a8:	6a42                	ld	s4,16(sp)
    800018aa:	6aa2                	ld	s5,8(sp)
    800018ac:	6b02                	ld	s6,0(sp)
    800018ae:	6121                	addi	sp,sp,64
    800018b0:	8082                	ret
      panic("kalloc");
    800018b2:	00007517          	auipc	a0,0x7
    800018b6:	92650513          	addi	a0,a0,-1754 # 800081d8 <digits+0x198>
    800018ba:	fffff097          	auipc	ra,0xfffff
    800018be:	c80080e7          	jalr	-896(ra) # 8000053a <panic>

00000000800018c2 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018c2:	7139                	addi	sp,sp,-64
    800018c4:	fc06                	sd	ra,56(sp)
    800018c6:	f822                	sd	s0,48(sp)
    800018c8:	f426                	sd	s1,40(sp)
    800018ca:	f04a                	sd	s2,32(sp)
    800018cc:	ec4e                	sd	s3,24(sp)
    800018ce:	e852                	sd	s4,16(sp)
    800018d0:	e456                	sd	s5,8(sp)
    800018d2:	e05a                	sd	s6,0(sp)
    800018d4:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018d6:	00007597          	auipc	a1,0x7
    800018da:	90a58593          	addi	a1,a1,-1782 # 800081e0 <digits+0x1a0>
    800018de:	00010517          	auipc	a0,0x10
    800018e2:	9c250513          	addi	a0,a0,-1598 # 800112a0 <pid_lock>
    800018e6:	fffff097          	auipc	ra,0xfffff
    800018ea:	25a080e7          	jalr	602(ra) # 80000b40 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018ee:	00007597          	auipc	a1,0x7
    800018f2:	8fa58593          	addi	a1,a1,-1798 # 800081e8 <digits+0x1a8>
    800018f6:	00010517          	auipc	a0,0x10
    800018fa:	9c250513          	addi	a0,a0,-1598 # 800112b8 <wait_lock>
    800018fe:	fffff097          	auipc	ra,0xfffff
    80001902:	242080e7          	jalr	578(ra) # 80000b40 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001906:	00010497          	auipc	s1,0x10
    8000190a:	dca48493          	addi	s1,s1,-566 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    8000190e:	00007b17          	auipc	s6,0x7
    80001912:	8eab0b13          	addi	s6,s6,-1814 # 800081f8 <digits+0x1b8>
      p->kstack = KSTACK((int) (p - proc));
    80001916:	8aa6                	mv	s5,s1
    80001918:	00006a17          	auipc	s4,0x6
    8000191c:	6e8a0a13          	addi	s4,s4,1768 # 80008000 <etext>
    80001920:	04000937          	lui	s2,0x4000
    80001924:	197d                	addi	s2,s2,-1
    80001926:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001928:	00015997          	auipc	s3,0x15
    8000192c:	7a898993          	addi	s3,s3,1960 # 800170d0 <tickslock>
      initlock(&p->lock, "proc");
    80001930:	85da                	mv	a1,s6
    80001932:	8526                	mv	a0,s1
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	20c080e7          	jalr	524(ra) # 80000b40 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000193c:	415487b3          	sub	a5,s1,s5
    80001940:	878d                	srai	a5,a5,0x3
    80001942:	000a3703          	ld	a4,0(s4)
    80001946:	02e787b3          	mul	a5,a5,a4
    8000194a:	2785                	addiw	a5,a5,1
    8000194c:	00d7979b          	slliw	a5,a5,0xd
    80001950:	40f907b3          	sub	a5,s2,a5
    80001954:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001956:	16848493          	addi	s1,s1,360
    8000195a:	fd349be3          	bne	s1,s3,80001930 <procinit+0x6e>
  }
}
    8000195e:	70e2                	ld	ra,56(sp)
    80001960:	7442                	ld	s0,48(sp)
    80001962:	74a2                	ld	s1,40(sp)
    80001964:	7902                	ld	s2,32(sp)
    80001966:	69e2                	ld	s3,24(sp)
    80001968:	6a42                	ld	s4,16(sp)
    8000196a:	6aa2                	ld	s5,8(sp)
    8000196c:	6b02                	ld	s6,0(sp)
    8000196e:	6121                	addi	sp,sp,64
    80001970:	8082                	ret

0000000080001972 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001972:	1141                	addi	sp,sp,-16
    80001974:	e422                	sd	s0,8(sp)
    80001976:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001978:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000197a:	2501                	sext.w	a0,a0
    8000197c:	6422                	ld	s0,8(sp)
    8000197e:	0141                	addi	sp,sp,16
    80001980:	8082                	ret

0000000080001982 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001982:	1141                	addi	sp,sp,-16
    80001984:	e422                	sd	s0,8(sp)
    80001986:	0800                	addi	s0,sp,16
    80001988:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000198a:	2781                	sext.w	a5,a5
    8000198c:	079e                	slli	a5,a5,0x7
  return c;
}
    8000198e:	00010517          	auipc	a0,0x10
    80001992:	94250513          	addi	a0,a0,-1726 # 800112d0 <cpus>
    80001996:	953e                	add	a0,a0,a5
    80001998:	6422                	ld	s0,8(sp)
    8000199a:	0141                	addi	sp,sp,16
    8000199c:	8082                	ret

000000008000199e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    8000199e:	1101                	addi	sp,sp,-32
    800019a0:	ec06                	sd	ra,24(sp)
    800019a2:	e822                	sd	s0,16(sp)
    800019a4:	e426                	sd	s1,8(sp)
    800019a6:	1000                	addi	s0,sp,32
  push_off();
    800019a8:	fffff097          	auipc	ra,0xfffff
    800019ac:	1dc080e7          	jalr	476(ra) # 80000b84 <push_off>
    800019b0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019b2:	2781                	sext.w	a5,a5
    800019b4:	079e                	slli	a5,a5,0x7
    800019b6:	00010717          	auipc	a4,0x10
    800019ba:	8ea70713          	addi	a4,a4,-1814 # 800112a0 <pid_lock>
    800019be:	97ba                	add	a5,a5,a4
    800019c0:	7b84                	ld	s1,48(a5)
  pop_off();
    800019c2:	fffff097          	auipc	ra,0xfffff
    800019c6:	262080e7          	jalr	610(ra) # 80000c24 <pop_off>
  return p;
}
    800019ca:	8526                	mv	a0,s1
    800019cc:	60e2                	ld	ra,24(sp)
    800019ce:	6442                	ld	s0,16(sp)
    800019d0:	64a2                	ld	s1,8(sp)
    800019d2:	6105                	addi	sp,sp,32
    800019d4:	8082                	ret

00000000800019d6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019d6:	1141                	addi	sp,sp,-16
    800019d8:	e406                	sd	ra,8(sp)
    800019da:	e022                	sd	s0,0(sp)
    800019dc:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019de:	00000097          	auipc	ra,0x0
    800019e2:	fc0080e7          	jalr	-64(ra) # 8000199e <myproc>
    800019e6:	fffff097          	auipc	ra,0xfffff
    800019ea:	29e080e7          	jalr	670(ra) # 80000c84 <release>

  if (first) {
    800019ee:	00007797          	auipc	a5,0x7
    800019f2:	ee27a783          	lw	a5,-286(a5) # 800088d0 <first.1>
    800019f6:	eb89                	bnez	a5,80001a08 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019f8:	00001097          	auipc	ra,0x1
    800019fc:	c14080e7          	jalr	-1004(ra) # 8000260c <usertrapret>
}
    80001a00:	60a2                	ld	ra,8(sp)
    80001a02:	6402                	ld	s0,0(sp)
    80001a04:	0141                	addi	sp,sp,16
    80001a06:	8082                	ret
    first = 0;
    80001a08:	00007797          	auipc	a5,0x7
    80001a0c:	ec07a423          	sw	zero,-312(a5) # 800088d0 <first.1>
    fsinit(ROOTDEV);
    80001a10:	4505                	li	a0,1
    80001a12:	00002097          	auipc	ra,0x2
    80001a16:	a72080e7          	jalr	-1422(ra) # 80003484 <fsinit>
    80001a1a:	bff9                	j	800019f8 <forkret+0x22>

0000000080001a1c <allocpid>:
allocpid() {
    80001a1c:	1101                	addi	sp,sp,-32
    80001a1e:	ec06                	sd	ra,24(sp)
    80001a20:	e822                	sd	s0,16(sp)
    80001a22:	e426                	sd	s1,8(sp)
    80001a24:	e04a                	sd	s2,0(sp)
    80001a26:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a28:	00010917          	auipc	s2,0x10
    80001a2c:	87890913          	addi	s2,s2,-1928 # 800112a0 <pid_lock>
    80001a30:	854a                	mv	a0,s2
    80001a32:	fffff097          	auipc	ra,0xfffff
    80001a36:	19e080e7          	jalr	414(ra) # 80000bd0 <acquire>
  pid = nextpid;
    80001a3a:	00007797          	auipc	a5,0x7
    80001a3e:	e9a78793          	addi	a5,a5,-358 # 800088d4 <nextpid>
    80001a42:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a44:	0014871b          	addiw	a4,s1,1
    80001a48:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a4a:	854a                	mv	a0,s2
    80001a4c:	fffff097          	auipc	ra,0xfffff
    80001a50:	238080e7          	jalr	568(ra) # 80000c84 <release>
}
    80001a54:	8526                	mv	a0,s1
    80001a56:	60e2                	ld	ra,24(sp)
    80001a58:	6442                	ld	s0,16(sp)
    80001a5a:	64a2                	ld	s1,8(sp)
    80001a5c:	6902                	ld	s2,0(sp)
    80001a5e:	6105                	addi	sp,sp,32
    80001a60:	8082                	ret

0000000080001a62 <proc_pagetable>:
{
    80001a62:	1101                	addi	sp,sp,-32
    80001a64:	ec06                	sd	ra,24(sp)
    80001a66:	e822                	sd	s0,16(sp)
    80001a68:	e426                	sd	s1,8(sp)
    80001a6a:	e04a                	sd	s2,0(sp)
    80001a6c:	1000                	addi	s0,sp,32
    80001a6e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a70:	00000097          	auipc	ra,0x0
    80001a74:	8b6080e7          	jalr	-1866(ra) # 80001326 <uvmcreate>
    80001a78:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a7a:	c121                	beqz	a0,80001aba <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a7c:	4729                	li	a4,10
    80001a7e:	00005697          	auipc	a3,0x5
    80001a82:	58268693          	addi	a3,a3,1410 # 80007000 <_trampoline>
    80001a86:	6605                	lui	a2,0x1
    80001a88:	040005b7          	lui	a1,0x4000
    80001a8c:	15fd                	addi	a1,a1,-1
    80001a8e:	05b2                	slli	a1,a1,0xc
    80001a90:	fffff097          	auipc	ra,0xfffff
    80001a94:	60c080e7          	jalr	1548(ra) # 8000109c <mappages>
    80001a98:	02054863          	bltz	a0,80001ac8 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a9c:	4719                	li	a4,6
    80001a9e:	05893683          	ld	a3,88(s2)
    80001aa2:	6605                	lui	a2,0x1
    80001aa4:	020005b7          	lui	a1,0x2000
    80001aa8:	15fd                	addi	a1,a1,-1
    80001aaa:	05b6                	slli	a1,a1,0xd
    80001aac:	8526                	mv	a0,s1
    80001aae:	fffff097          	auipc	ra,0xfffff
    80001ab2:	5ee080e7          	jalr	1518(ra) # 8000109c <mappages>
    80001ab6:	02054163          	bltz	a0,80001ad8 <proc_pagetable+0x76>
}
    80001aba:	8526                	mv	a0,s1
    80001abc:	60e2                	ld	ra,24(sp)
    80001abe:	6442                	ld	s0,16(sp)
    80001ac0:	64a2                	ld	s1,8(sp)
    80001ac2:	6902                	ld	s2,0(sp)
    80001ac4:	6105                	addi	sp,sp,32
    80001ac6:	8082                	ret
    uvmfree(pagetable, 0);
    80001ac8:	4581                	li	a1,0
    80001aca:	8526                	mv	a0,s1
    80001acc:	00000097          	auipc	ra,0x0
    80001ad0:	a58080e7          	jalr	-1448(ra) # 80001524 <uvmfree>
    return 0;
    80001ad4:	4481                	li	s1,0
    80001ad6:	b7d5                	j	80001aba <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad8:	4681                	li	a3,0
    80001ada:	4605                	li	a2,1
    80001adc:	040005b7          	lui	a1,0x4000
    80001ae0:	15fd                	addi	a1,a1,-1
    80001ae2:	05b2                	slli	a1,a1,0xc
    80001ae4:	8526                	mv	a0,s1
    80001ae6:	fffff097          	auipc	ra,0xfffff
    80001aea:	77c080e7          	jalr	1916(ra) # 80001262 <uvmunmap>
    uvmfree(pagetable, 0);
    80001aee:	4581                	li	a1,0
    80001af0:	8526                	mv	a0,s1
    80001af2:	00000097          	auipc	ra,0x0
    80001af6:	a32080e7          	jalr	-1486(ra) # 80001524 <uvmfree>
    return 0;
    80001afa:	4481                	li	s1,0
    80001afc:	bf7d                	j	80001aba <proc_pagetable+0x58>

0000000080001afe <proc_freepagetable>:
{
    80001afe:	1101                	addi	sp,sp,-32
    80001b00:	ec06                	sd	ra,24(sp)
    80001b02:	e822                	sd	s0,16(sp)
    80001b04:	e426                	sd	s1,8(sp)
    80001b06:	e04a                	sd	s2,0(sp)
    80001b08:	1000                	addi	s0,sp,32
    80001b0a:	84aa                	mv	s1,a0
    80001b0c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b0e:	4681                	li	a3,0
    80001b10:	4605                	li	a2,1
    80001b12:	040005b7          	lui	a1,0x4000
    80001b16:	15fd                	addi	a1,a1,-1
    80001b18:	05b2                	slli	a1,a1,0xc
    80001b1a:	fffff097          	auipc	ra,0xfffff
    80001b1e:	748080e7          	jalr	1864(ra) # 80001262 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b22:	4681                	li	a3,0
    80001b24:	4605                	li	a2,1
    80001b26:	020005b7          	lui	a1,0x2000
    80001b2a:	15fd                	addi	a1,a1,-1
    80001b2c:	05b6                	slli	a1,a1,0xd
    80001b2e:	8526                	mv	a0,s1
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	732080e7          	jalr	1842(ra) # 80001262 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b38:	85ca                	mv	a1,s2
    80001b3a:	8526                	mv	a0,s1
    80001b3c:	00000097          	auipc	ra,0x0
    80001b40:	9e8080e7          	jalr	-1560(ra) # 80001524 <uvmfree>
}
    80001b44:	60e2                	ld	ra,24(sp)
    80001b46:	6442                	ld	s0,16(sp)
    80001b48:	64a2                	ld	s1,8(sp)
    80001b4a:	6902                	ld	s2,0(sp)
    80001b4c:	6105                	addi	sp,sp,32
    80001b4e:	8082                	ret

0000000080001b50 <freeproc>:
{
    80001b50:	1101                	addi	sp,sp,-32
    80001b52:	ec06                	sd	ra,24(sp)
    80001b54:	e822                	sd	s0,16(sp)
    80001b56:	e426                	sd	s1,8(sp)
    80001b58:	1000                	addi	s0,sp,32
    80001b5a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b5c:	6d28                	ld	a0,88(a0)
    80001b5e:	c509                	beqz	a0,80001b68 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b60:	fffff097          	auipc	ra,0xfffff
    80001b64:	e82080e7          	jalr	-382(ra) # 800009e2 <kfree>
  p->trapframe = 0;
    80001b68:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b6c:	68a8                	ld	a0,80(s1)
    80001b6e:	c511                	beqz	a0,80001b7a <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b70:	64ac                	ld	a1,72(s1)
    80001b72:	00000097          	auipc	ra,0x0
    80001b76:	f8c080e7          	jalr	-116(ra) # 80001afe <proc_freepagetable>
  p->pagetable = 0;
    80001b7a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b7e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b82:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b86:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b8a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b8e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b92:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b96:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b9a:	0004ac23          	sw	zero,24(s1)
}
    80001b9e:	60e2                	ld	ra,24(sp)
    80001ba0:	6442                	ld	s0,16(sp)
    80001ba2:	64a2                	ld	s1,8(sp)
    80001ba4:	6105                	addi	sp,sp,32
    80001ba6:	8082                	ret

0000000080001ba8 <allocproc>:
{
    80001ba8:	1101                	addi	sp,sp,-32
    80001baa:	ec06                	sd	ra,24(sp)
    80001bac:	e822                	sd	s0,16(sp)
    80001bae:	e426                	sd	s1,8(sp)
    80001bb0:	e04a                	sd	s2,0(sp)
    80001bb2:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bb4:	00010497          	auipc	s1,0x10
    80001bb8:	b1c48493          	addi	s1,s1,-1252 # 800116d0 <proc>
    80001bbc:	00015917          	auipc	s2,0x15
    80001bc0:	51490913          	addi	s2,s2,1300 # 800170d0 <tickslock>
    acquire(&p->lock);
    80001bc4:	8526                	mv	a0,s1
    80001bc6:	fffff097          	auipc	ra,0xfffff
    80001bca:	00a080e7          	jalr	10(ra) # 80000bd0 <acquire>
    if(p->state == UNUSED) {
    80001bce:	4c9c                	lw	a5,24(s1)
    80001bd0:	cf81                	beqz	a5,80001be8 <allocproc+0x40>
      release(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	0b0080e7          	jalr	176(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bdc:	16848493          	addi	s1,s1,360
    80001be0:	ff2492e3          	bne	s1,s2,80001bc4 <allocproc+0x1c>
  return 0;
    80001be4:	4481                	li	s1,0
    80001be6:	a889                	j	80001c38 <allocproc+0x90>
  p->pid = allocpid();
    80001be8:	00000097          	auipc	ra,0x0
    80001bec:	e34080e7          	jalr	-460(ra) # 80001a1c <allocpid>
    80001bf0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bf2:	4785                	li	a5,1
    80001bf4:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001bf6:	fffff097          	auipc	ra,0xfffff
    80001bfa:	eea080e7          	jalr	-278(ra) # 80000ae0 <kalloc>
    80001bfe:	892a                	mv	s2,a0
    80001c00:	eca8                	sd	a0,88(s1)
    80001c02:	c131                	beqz	a0,80001c46 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c04:	8526                	mv	a0,s1
    80001c06:	00000097          	auipc	ra,0x0
    80001c0a:	e5c080e7          	jalr	-420(ra) # 80001a62 <proc_pagetable>
    80001c0e:	892a                	mv	s2,a0
    80001c10:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c12:	c531                	beqz	a0,80001c5e <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c14:	07000613          	li	a2,112
    80001c18:	4581                	li	a1,0
    80001c1a:	06048513          	addi	a0,s1,96
    80001c1e:	fffff097          	auipc	ra,0xfffff
    80001c22:	0ae080e7          	jalr	174(ra) # 80000ccc <memset>
  p->context.ra = (uint64)forkret;
    80001c26:	00000797          	auipc	a5,0x0
    80001c2a:	db078793          	addi	a5,a5,-592 # 800019d6 <forkret>
    80001c2e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c30:	60bc                	ld	a5,64(s1)
    80001c32:	6705                	lui	a4,0x1
    80001c34:	97ba                	add	a5,a5,a4
    80001c36:	f4bc                	sd	a5,104(s1)
}
    80001c38:	8526                	mv	a0,s1
    80001c3a:	60e2                	ld	ra,24(sp)
    80001c3c:	6442                	ld	s0,16(sp)
    80001c3e:	64a2                	ld	s1,8(sp)
    80001c40:	6902                	ld	s2,0(sp)
    80001c42:	6105                	addi	sp,sp,32
    80001c44:	8082                	ret
    freeproc(p);
    80001c46:	8526                	mv	a0,s1
    80001c48:	00000097          	auipc	ra,0x0
    80001c4c:	f08080e7          	jalr	-248(ra) # 80001b50 <freeproc>
    release(&p->lock);
    80001c50:	8526                	mv	a0,s1
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	032080e7          	jalr	50(ra) # 80000c84 <release>
    return 0;
    80001c5a:	84ca                	mv	s1,s2
    80001c5c:	bff1                	j	80001c38 <allocproc+0x90>
    freeproc(p);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	00000097          	auipc	ra,0x0
    80001c64:	ef0080e7          	jalr	-272(ra) # 80001b50 <freeproc>
    release(&p->lock);
    80001c68:	8526                	mv	a0,s1
    80001c6a:	fffff097          	auipc	ra,0xfffff
    80001c6e:	01a080e7          	jalr	26(ra) # 80000c84 <release>
    return 0;
    80001c72:	84ca                	mv	s1,s2
    80001c74:	b7d1                	j	80001c38 <allocproc+0x90>

0000000080001c76 <userinit>:
{
    80001c76:	1101                	addi	sp,sp,-32
    80001c78:	ec06                	sd	ra,24(sp)
    80001c7a:	e822                	sd	s0,16(sp)
    80001c7c:	e426                	sd	s1,8(sp)
    80001c7e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c80:	00000097          	auipc	ra,0x0
    80001c84:	f28080e7          	jalr	-216(ra) # 80001ba8 <allocproc>
    80001c88:	84aa                	mv	s1,a0
  initproc = p;
    80001c8a:	00007797          	auipc	a5,0x7
    80001c8e:	38a7bf23          	sd	a0,926(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001c92:	03400613          	li	a2,52
    80001c96:	00007597          	auipc	a1,0x7
    80001c9a:	c4a58593          	addi	a1,a1,-950 # 800088e0 <initcode>
    80001c9e:	6928                	ld	a0,80(a0)
    80001ca0:	fffff097          	auipc	ra,0xfffff
    80001ca4:	6b4080e7          	jalr	1716(ra) # 80001354 <uvminit>
  p->sz = PGSIZE;
    80001ca8:	6785                	lui	a5,0x1
    80001caa:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cac:	6cb8                	ld	a4,88(s1)
    80001cae:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cb2:	6cb8                	ld	a4,88(s1)
    80001cb4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cb6:	4641                	li	a2,16
    80001cb8:	00006597          	auipc	a1,0x6
    80001cbc:	54858593          	addi	a1,a1,1352 # 80008200 <digits+0x1c0>
    80001cc0:	15848513          	addi	a0,s1,344
    80001cc4:	fffff097          	auipc	ra,0xfffff
    80001cc8:	152080e7          	jalr	338(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001ccc:	00006517          	auipc	a0,0x6
    80001cd0:	54450513          	addi	a0,a0,1348 # 80008210 <digits+0x1d0>
    80001cd4:	00002097          	auipc	ra,0x2
    80001cd8:	1e6080e7          	jalr	486(ra) # 80003eba <namei>
    80001cdc:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ce0:	478d                	li	a5,3
    80001ce2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	fffff097          	auipc	ra,0xfffff
    80001cea:	f9e080e7          	jalr	-98(ra) # 80000c84 <release>
}
    80001cee:	60e2                	ld	ra,24(sp)
    80001cf0:	6442                	ld	s0,16(sp)
    80001cf2:	64a2                	ld	s1,8(sp)
    80001cf4:	6105                	addi	sp,sp,32
    80001cf6:	8082                	ret

0000000080001cf8 <growproc>:
{
    80001cf8:	1101                	addi	sp,sp,-32
    80001cfa:	ec06                	sd	ra,24(sp)
    80001cfc:	e822                	sd	s0,16(sp)
    80001cfe:	e426                	sd	s1,8(sp)
    80001d00:	e04a                	sd	s2,0(sp)
    80001d02:	1000                	addi	s0,sp,32
    80001d04:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d06:	00000097          	auipc	ra,0x0
    80001d0a:	c98080e7          	jalr	-872(ra) # 8000199e <myproc>
    80001d0e:	892a                	mv	s2,a0
  sz = p->sz;
    80001d10:	652c                	ld	a1,72(a0)
    80001d12:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001d16:	00904f63          	bgtz	s1,80001d34 <growproc+0x3c>
  } else if(n < 0){
    80001d1a:	0204cd63          	bltz	s1,80001d54 <growproc+0x5c>
  p->sz = sz;
    80001d1e:	1782                	slli	a5,a5,0x20
    80001d20:	9381                	srli	a5,a5,0x20
    80001d22:	04f93423          	sd	a5,72(s2)
  return 0;
    80001d26:	4501                	li	a0,0
}
    80001d28:	60e2                	ld	ra,24(sp)
    80001d2a:	6442                	ld	s0,16(sp)
    80001d2c:	64a2                	ld	s1,8(sp)
    80001d2e:	6902                	ld	s2,0(sp)
    80001d30:	6105                	addi	sp,sp,32
    80001d32:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d34:	00f4863b          	addw	a2,s1,a5
    80001d38:	1602                	slli	a2,a2,0x20
    80001d3a:	9201                	srli	a2,a2,0x20
    80001d3c:	1582                	slli	a1,a1,0x20
    80001d3e:	9181                	srli	a1,a1,0x20
    80001d40:	6928                	ld	a0,80(a0)
    80001d42:	fffff097          	auipc	ra,0xfffff
    80001d46:	6cc080e7          	jalr	1740(ra) # 8000140e <uvmalloc>
    80001d4a:	0005079b          	sext.w	a5,a0
    80001d4e:	fbe1                	bnez	a5,80001d1e <growproc+0x26>
      return -1;
    80001d50:	557d                	li	a0,-1
    80001d52:	bfd9                	j	80001d28 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d54:	00f4863b          	addw	a2,s1,a5
    80001d58:	1602                	slli	a2,a2,0x20
    80001d5a:	9201                	srli	a2,a2,0x20
    80001d5c:	1582                	slli	a1,a1,0x20
    80001d5e:	9181                	srli	a1,a1,0x20
    80001d60:	6928                	ld	a0,80(a0)
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	664080e7          	jalr	1636(ra) # 800013c6 <uvmdealloc>
    80001d6a:	0005079b          	sext.w	a5,a0
    80001d6e:	bf45                	j	80001d1e <growproc+0x26>

0000000080001d70 <fork>:
{
    80001d70:	7139                	addi	sp,sp,-64
    80001d72:	fc06                	sd	ra,56(sp)
    80001d74:	f822                	sd	s0,48(sp)
    80001d76:	f426                	sd	s1,40(sp)
    80001d78:	f04a                	sd	s2,32(sp)
    80001d7a:	ec4e                	sd	s3,24(sp)
    80001d7c:	e852                	sd	s4,16(sp)
    80001d7e:	e456                	sd	s5,8(sp)
    80001d80:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d82:	00000097          	auipc	ra,0x0
    80001d86:	c1c080e7          	jalr	-996(ra) # 8000199e <myproc>
    80001d8a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d8c:	00000097          	auipc	ra,0x0
    80001d90:	e1c080e7          	jalr	-484(ra) # 80001ba8 <allocproc>
    80001d94:	10050c63          	beqz	a0,80001eac <fork+0x13c>
    80001d98:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d9a:	048ab603          	ld	a2,72(s5)
    80001d9e:	692c                	ld	a1,80(a0)
    80001da0:	050ab503          	ld	a0,80(s5)
    80001da4:	fffff097          	auipc	ra,0xfffff
    80001da8:	7ba080e7          	jalr	1978(ra) # 8000155e <uvmcopy>
    80001dac:	04054863          	bltz	a0,80001dfc <fork+0x8c>
  np->sz = p->sz;
    80001db0:	048ab783          	ld	a5,72(s5)
    80001db4:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001db8:	058ab683          	ld	a3,88(s5)
    80001dbc:	87b6                	mv	a5,a3
    80001dbe:	058a3703          	ld	a4,88(s4)
    80001dc2:	12068693          	addi	a3,a3,288
    80001dc6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dca:	6788                	ld	a0,8(a5)
    80001dcc:	6b8c                	ld	a1,16(a5)
    80001dce:	6f90                	ld	a2,24(a5)
    80001dd0:	01073023          	sd	a6,0(a4)
    80001dd4:	e708                	sd	a0,8(a4)
    80001dd6:	eb0c                	sd	a1,16(a4)
    80001dd8:	ef10                	sd	a2,24(a4)
    80001dda:	02078793          	addi	a5,a5,32
    80001dde:	02070713          	addi	a4,a4,32
    80001de2:	fed792e3          	bne	a5,a3,80001dc6 <fork+0x56>
  np->trapframe->a0 = 0;
    80001de6:	058a3783          	ld	a5,88(s4)
    80001dea:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001dee:	0d0a8493          	addi	s1,s5,208
    80001df2:	0d0a0913          	addi	s2,s4,208
    80001df6:	150a8993          	addi	s3,s5,336
    80001dfa:	a00d                	j	80001e1c <fork+0xac>
    freeproc(np);
    80001dfc:	8552                	mv	a0,s4
    80001dfe:	00000097          	auipc	ra,0x0
    80001e02:	d52080e7          	jalr	-686(ra) # 80001b50 <freeproc>
    release(&np->lock);
    80001e06:	8552                	mv	a0,s4
    80001e08:	fffff097          	auipc	ra,0xfffff
    80001e0c:	e7c080e7          	jalr	-388(ra) # 80000c84 <release>
    return -1;
    80001e10:	597d                	li	s2,-1
    80001e12:	a059                	j	80001e98 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e14:	04a1                	addi	s1,s1,8
    80001e16:	0921                	addi	s2,s2,8
    80001e18:	01348b63          	beq	s1,s3,80001e2e <fork+0xbe>
    if(p->ofile[i])
    80001e1c:	6088                	ld	a0,0(s1)
    80001e1e:	d97d                	beqz	a0,80001e14 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e20:	00002097          	auipc	ra,0x2
    80001e24:	730080e7          	jalr	1840(ra) # 80004550 <filedup>
    80001e28:	00a93023          	sd	a0,0(s2)
    80001e2c:	b7e5                	j	80001e14 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e2e:	150ab503          	ld	a0,336(s5)
    80001e32:	00002097          	auipc	ra,0x2
    80001e36:	88e080e7          	jalr	-1906(ra) # 800036c0 <idup>
    80001e3a:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e3e:	4641                	li	a2,16
    80001e40:	158a8593          	addi	a1,s5,344
    80001e44:	158a0513          	addi	a0,s4,344
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	fce080e7          	jalr	-50(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e50:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e54:	8552                	mv	a0,s4
    80001e56:	fffff097          	auipc	ra,0xfffff
    80001e5a:	e2e080e7          	jalr	-466(ra) # 80000c84 <release>
  acquire(&wait_lock);
    80001e5e:	0000f497          	auipc	s1,0xf
    80001e62:	45a48493          	addi	s1,s1,1114 # 800112b8 <wait_lock>
    80001e66:	8526                	mv	a0,s1
    80001e68:	fffff097          	auipc	ra,0xfffff
    80001e6c:	d68080e7          	jalr	-664(ra) # 80000bd0 <acquire>
  np->parent = p;
    80001e70:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e74:	8526                	mv	a0,s1
    80001e76:	fffff097          	auipc	ra,0xfffff
    80001e7a:	e0e080e7          	jalr	-498(ra) # 80000c84 <release>
  acquire(&np->lock);
    80001e7e:	8552                	mv	a0,s4
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	d50080e7          	jalr	-688(ra) # 80000bd0 <acquire>
  np->state = RUNNABLE;
    80001e88:	478d                	li	a5,3
    80001e8a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e8e:	8552                	mv	a0,s4
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	df4080e7          	jalr	-524(ra) # 80000c84 <release>
}
    80001e98:	854a                	mv	a0,s2
    80001e9a:	70e2                	ld	ra,56(sp)
    80001e9c:	7442                	ld	s0,48(sp)
    80001e9e:	74a2                	ld	s1,40(sp)
    80001ea0:	7902                	ld	s2,32(sp)
    80001ea2:	69e2                	ld	s3,24(sp)
    80001ea4:	6a42                	ld	s4,16(sp)
    80001ea6:	6aa2                	ld	s5,8(sp)
    80001ea8:	6121                	addi	sp,sp,64
    80001eaa:	8082                	ret
    return -1;
    80001eac:	597d                	li	s2,-1
    80001eae:	b7ed                	j	80001e98 <fork+0x128>

0000000080001eb0 <scheduler>:
{
    80001eb0:	7139                	addi	sp,sp,-64
    80001eb2:	fc06                	sd	ra,56(sp)
    80001eb4:	f822                	sd	s0,48(sp)
    80001eb6:	f426                	sd	s1,40(sp)
    80001eb8:	f04a                	sd	s2,32(sp)
    80001eba:	ec4e                	sd	s3,24(sp)
    80001ebc:	e852                	sd	s4,16(sp)
    80001ebe:	e456                	sd	s5,8(sp)
    80001ec0:	e05a                	sd	s6,0(sp)
    80001ec2:	0080                	addi	s0,sp,64
    80001ec4:	8792                	mv	a5,tp
  int id = r_tp();
    80001ec6:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ec8:	00779a93          	slli	s5,a5,0x7
    80001ecc:	0000f717          	auipc	a4,0xf
    80001ed0:	3d470713          	addi	a4,a4,980 # 800112a0 <pid_lock>
    80001ed4:	9756                	add	a4,a4,s5
    80001ed6:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001eda:	0000f717          	auipc	a4,0xf
    80001ede:	3fe70713          	addi	a4,a4,1022 # 800112d8 <cpus+0x8>
    80001ee2:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ee4:	498d                	li	s3,3
        p->state = RUNNING;
    80001ee6:	4b11                	li	s6,4
        c->proc = p;
    80001ee8:	079e                	slli	a5,a5,0x7
    80001eea:	0000fa17          	auipc	s4,0xf
    80001eee:	3b6a0a13          	addi	s4,s4,950 # 800112a0 <pid_lock>
    80001ef2:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ef4:	00015917          	auipc	s2,0x15
    80001ef8:	1dc90913          	addi	s2,s2,476 # 800170d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001efc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f00:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f04:	10079073          	csrw	sstatus,a5
    80001f08:	0000f497          	auipc	s1,0xf
    80001f0c:	7c848493          	addi	s1,s1,1992 # 800116d0 <proc>
    80001f10:	a811                	j	80001f24 <scheduler+0x74>
      release(&p->lock);
    80001f12:	8526                	mv	a0,s1
    80001f14:	fffff097          	auipc	ra,0xfffff
    80001f18:	d70080e7          	jalr	-656(ra) # 80000c84 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f1c:	16848493          	addi	s1,s1,360
    80001f20:	fd248ee3          	beq	s1,s2,80001efc <scheduler+0x4c>
      acquire(&p->lock);
    80001f24:	8526                	mv	a0,s1
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	caa080e7          	jalr	-854(ra) # 80000bd0 <acquire>
      if(p->state == RUNNABLE) {
    80001f2e:	4c9c                	lw	a5,24(s1)
    80001f30:	ff3791e3          	bne	a5,s3,80001f12 <scheduler+0x62>
        p->state = RUNNING;
    80001f34:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f38:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f3c:	06048593          	addi	a1,s1,96
    80001f40:	8556                	mv	a0,s5
    80001f42:	00000097          	auipc	ra,0x0
    80001f46:	620080e7          	jalr	1568(ra) # 80002562 <swtch>
        c->proc = 0;
    80001f4a:	020a3823          	sd	zero,48(s4)
    80001f4e:	b7d1                	j	80001f12 <scheduler+0x62>

0000000080001f50 <sched>:
{
    80001f50:	7179                	addi	sp,sp,-48
    80001f52:	f406                	sd	ra,40(sp)
    80001f54:	f022                	sd	s0,32(sp)
    80001f56:	ec26                	sd	s1,24(sp)
    80001f58:	e84a                	sd	s2,16(sp)
    80001f5a:	e44e                	sd	s3,8(sp)
    80001f5c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f5e:	00000097          	auipc	ra,0x0
    80001f62:	a40080e7          	jalr	-1472(ra) # 8000199e <myproc>
    80001f66:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f68:	fffff097          	auipc	ra,0xfffff
    80001f6c:	bee080e7          	jalr	-1042(ra) # 80000b56 <holding>
    80001f70:	c93d                	beqz	a0,80001fe6 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f72:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f74:	2781                	sext.w	a5,a5
    80001f76:	079e                	slli	a5,a5,0x7
    80001f78:	0000f717          	auipc	a4,0xf
    80001f7c:	32870713          	addi	a4,a4,808 # 800112a0 <pid_lock>
    80001f80:	97ba                	add	a5,a5,a4
    80001f82:	0a87a703          	lw	a4,168(a5)
    80001f86:	4785                	li	a5,1
    80001f88:	06f71763          	bne	a4,a5,80001ff6 <sched+0xa6>
  if(p->state == RUNNING)
    80001f8c:	4c98                	lw	a4,24(s1)
    80001f8e:	4791                	li	a5,4
    80001f90:	06f70b63          	beq	a4,a5,80002006 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f94:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f98:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f9a:	efb5                	bnez	a5,80002016 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f9c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f9e:	0000f917          	auipc	s2,0xf
    80001fa2:	30290913          	addi	s2,s2,770 # 800112a0 <pid_lock>
    80001fa6:	2781                	sext.w	a5,a5
    80001fa8:	079e                	slli	a5,a5,0x7
    80001faa:	97ca                	add	a5,a5,s2
    80001fac:	0ac7a983          	lw	s3,172(a5)
    80001fb0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fb2:	2781                	sext.w	a5,a5
    80001fb4:	079e                	slli	a5,a5,0x7
    80001fb6:	0000f597          	auipc	a1,0xf
    80001fba:	32258593          	addi	a1,a1,802 # 800112d8 <cpus+0x8>
    80001fbe:	95be                	add	a1,a1,a5
    80001fc0:	06048513          	addi	a0,s1,96
    80001fc4:	00000097          	auipc	ra,0x0
    80001fc8:	59e080e7          	jalr	1438(ra) # 80002562 <swtch>
    80001fcc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fce:	2781                	sext.w	a5,a5
    80001fd0:	079e                	slli	a5,a5,0x7
    80001fd2:	993e                	add	s2,s2,a5
    80001fd4:	0b392623          	sw	s3,172(s2)
}
    80001fd8:	70a2                	ld	ra,40(sp)
    80001fda:	7402                	ld	s0,32(sp)
    80001fdc:	64e2                	ld	s1,24(sp)
    80001fde:	6942                	ld	s2,16(sp)
    80001fe0:	69a2                	ld	s3,8(sp)
    80001fe2:	6145                	addi	sp,sp,48
    80001fe4:	8082                	ret
    panic("sched p->lock");
    80001fe6:	00006517          	auipc	a0,0x6
    80001fea:	23250513          	addi	a0,a0,562 # 80008218 <digits+0x1d8>
    80001fee:	ffffe097          	auipc	ra,0xffffe
    80001ff2:	54c080e7          	jalr	1356(ra) # 8000053a <panic>
    panic("sched locks");
    80001ff6:	00006517          	auipc	a0,0x6
    80001ffa:	23250513          	addi	a0,a0,562 # 80008228 <digits+0x1e8>
    80001ffe:	ffffe097          	auipc	ra,0xffffe
    80002002:	53c080e7          	jalr	1340(ra) # 8000053a <panic>
    panic("sched running");
    80002006:	00006517          	auipc	a0,0x6
    8000200a:	23250513          	addi	a0,a0,562 # 80008238 <digits+0x1f8>
    8000200e:	ffffe097          	auipc	ra,0xffffe
    80002012:	52c080e7          	jalr	1324(ra) # 8000053a <panic>
    panic("sched interruptible");
    80002016:	00006517          	auipc	a0,0x6
    8000201a:	23250513          	addi	a0,a0,562 # 80008248 <digits+0x208>
    8000201e:	ffffe097          	auipc	ra,0xffffe
    80002022:	51c080e7          	jalr	1308(ra) # 8000053a <panic>

0000000080002026 <yield>:
{
    80002026:	1101                	addi	sp,sp,-32
    80002028:	ec06                	sd	ra,24(sp)
    8000202a:	e822                	sd	s0,16(sp)
    8000202c:	e426                	sd	s1,8(sp)
    8000202e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002030:	00000097          	auipc	ra,0x0
    80002034:	96e080e7          	jalr	-1682(ra) # 8000199e <myproc>
    80002038:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000203a:	fffff097          	auipc	ra,0xfffff
    8000203e:	b96080e7          	jalr	-1130(ra) # 80000bd0 <acquire>
  p->state = RUNNABLE;
    80002042:	478d                	li	a5,3
    80002044:	cc9c                	sw	a5,24(s1)
  sched();
    80002046:	00000097          	auipc	ra,0x0
    8000204a:	f0a080e7          	jalr	-246(ra) # 80001f50 <sched>
  release(&p->lock);
    8000204e:	8526                	mv	a0,s1
    80002050:	fffff097          	auipc	ra,0xfffff
    80002054:	c34080e7          	jalr	-972(ra) # 80000c84 <release>
}
    80002058:	60e2                	ld	ra,24(sp)
    8000205a:	6442                	ld	s0,16(sp)
    8000205c:	64a2                	ld	s1,8(sp)
    8000205e:	6105                	addi	sp,sp,32
    80002060:	8082                	ret

0000000080002062 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002062:	7179                	addi	sp,sp,-48
    80002064:	f406                	sd	ra,40(sp)
    80002066:	f022                	sd	s0,32(sp)
    80002068:	ec26                	sd	s1,24(sp)
    8000206a:	e84a                	sd	s2,16(sp)
    8000206c:	e44e                	sd	s3,8(sp)
    8000206e:	1800                	addi	s0,sp,48
    80002070:	89aa                	mv	s3,a0
    80002072:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002074:	00000097          	auipc	ra,0x0
    80002078:	92a080e7          	jalr	-1750(ra) # 8000199e <myproc>
    8000207c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	b52080e7          	jalr	-1198(ra) # 80000bd0 <acquire>
  release(lk);
    80002086:	854a                	mv	a0,s2
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	bfc080e7          	jalr	-1028(ra) # 80000c84 <release>

  // Go to sleep.
  p->chan = chan;
    80002090:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002094:	4789                	li	a5,2
    80002096:	cc9c                	sw	a5,24(s1)

  sched();
    80002098:	00000097          	auipc	ra,0x0
    8000209c:	eb8080e7          	jalr	-328(ra) # 80001f50 <sched>

  // Tidy up.
  p->chan = 0;
    800020a0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020a4:	8526                	mv	a0,s1
    800020a6:	fffff097          	auipc	ra,0xfffff
    800020aa:	bde080e7          	jalr	-1058(ra) # 80000c84 <release>
  acquire(lk);
    800020ae:	854a                	mv	a0,s2
    800020b0:	fffff097          	auipc	ra,0xfffff
    800020b4:	b20080e7          	jalr	-1248(ra) # 80000bd0 <acquire>
}
    800020b8:	70a2                	ld	ra,40(sp)
    800020ba:	7402                	ld	s0,32(sp)
    800020bc:	64e2                	ld	s1,24(sp)
    800020be:	6942                	ld	s2,16(sp)
    800020c0:	69a2                	ld	s3,8(sp)
    800020c2:	6145                	addi	sp,sp,48
    800020c4:	8082                	ret

00000000800020c6 <wait>:
{
    800020c6:	715d                	addi	sp,sp,-80
    800020c8:	e486                	sd	ra,72(sp)
    800020ca:	e0a2                	sd	s0,64(sp)
    800020cc:	fc26                	sd	s1,56(sp)
    800020ce:	f84a                	sd	s2,48(sp)
    800020d0:	f44e                	sd	s3,40(sp)
    800020d2:	f052                	sd	s4,32(sp)
    800020d4:	ec56                	sd	s5,24(sp)
    800020d6:	e85a                	sd	s6,16(sp)
    800020d8:	e45e                	sd	s7,8(sp)
    800020da:	e062                	sd	s8,0(sp)
    800020dc:	0880                	addi	s0,sp,80
    800020de:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800020e0:	00000097          	auipc	ra,0x0
    800020e4:	8be080e7          	jalr	-1858(ra) # 8000199e <myproc>
    800020e8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800020ea:	0000f517          	auipc	a0,0xf
    800020ee:	1ce50513          	addi	a0,a0,462 # 800112b8 <wait_lock>
    800020f2:	fffff097          	auipc	ra,0xfffff
    800020f6:	ade080e7          	jalr	-1314(ra) # 80000bd0 <acquire>
    havekids = 0;
    800020fa:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800020fc:	4a15                	li	s4,5
        havekids = 1;
    800020fe:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002100:	00015997          	auipc	s3,0x15
    80002104:	fd098993          	addi	s3,s3,-48 # 800170d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002108:	0000fc17          	auipc	s8,0xf
    8000210c:	1b0c0c13          	addi	s8,s8,432 # 800112b8 <wait_lock>
    havekids = 0;
    80002110:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002112:	0000f497          	auipc	s1,0xf
    80002116:	5be48493          	addi	s1,s1,1470 # 800116d0 <proc>
    8000211a:	a0bd                	j	80002188 <wait+0xc2>
          pid = np->pid;
    8000211c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002120:	000b0e63          	beqz	s6,8000213c <wait+0x76>
    80002124:	4691                	li	a3,4
    80002126:	02c48613          	addi	a2,s1,44
    8000212a:	85da                	mv	a1,s6
    8000212c:	05093503          	ld	a0,80(s2)
    80002130:	fffff097          	auipc	ra,0xfffff
    80002134:	532080e7          	jalr	1330(ra) # 80001662 <copyout>
    80002138:	02054563          	bltz	a0,80002162 <wait+0x9c>
          freeproc(np);
    8000213c:	8526                	mv	a0,s1
    8000213e:	00000097          	auipc	ra,0x0
    80002142:	a12080e7          	jalr	-1518(ra) # 80001b50 <freeproc>
          release(&np->lock);
    80002146:	8526                	mv	a0,s1
    80002148:	fffff097          	auipc	ra,0xfffff
    8000214c:	b3c080e7          	jalr	-1220(ra) # 80000c84 <release>
          release(&wait_lock);
    80002150:	0000f517          	auipc	a0,0xf
    80002154:	16850513          	addi	a0,a0,360 # 800112b8 <wait_lock>
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	b2c080e7          	jalr	-1236(ra) # 80000c84 <release>
          return pid;
    80002160:	a09d                	j	800021c6 <wait+0x100>
            release(&np->lock);
    80002162:	8526                	mv	a0,s1
    80002164:	fffff097          	auipc	ra,0xfffff
    80002168:	b20080e7          	jalr	-1248(ra) # 80000c84 <release>
            release(&wait_lock);
    8000216c:	0000f517          	auipc	a0,0xf
    80002170:	14c50513          	addi	a0,a0,332 # 800112b8 <wait_lock>
    80002174:	fffff097          	auipc	ra,0xfffff
    80002178:	b10080e7          	jalr	-1264(ra) # 80000c84 <release>
            return -1;
    8000217c:	59fd                	li	s3,-1
    8000217e:	a0a1                	j	800021c6 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002180:	16848493          	addi	s1,s1,360
    80002184:	03348463          	beq	s1,s3,800021ac <wait+0xe6>
      if(np->parent == p){
    80002188:	7c9c                	ld	a5,56(s1)
    8000218a:	ff279be3          	bne	a5,s2,80002180 <wait+0xba>
        acquire(&np->lock);
    8000218e:	8526                	mv	a0,s1
    80002190:	fffff097          	auipc	ra,0xfffff
    80002194:	a40080e7          	jalr	-1472(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    80002198:	4c9c                	lw	a5,24(s1)
    8000219a:	f94781e3          	beq	a5,s4,8000211c <wait+0x56>
        release(&np->lock);
    8000219e:	8526                	mv	a0,s1
    800021a0:	fffff097          	auipc	ra,0xfffff
    800021a4:	ae4080e7          	jalr	-1308(ra) # 80000c84 <release>
        havekids = 1;
    800021a8:	8756                	mv	a4,s5
    800021aa:	bfd9                	j	80002180 <wait+0xba>
    if(!havekids || p->killed){
    800021ac:	c701                	beqz	a4,800021b4 <wait+0xee>
    800021ae:	02892783          	lw	a5,40(s2)
    800021b2:	c79d                	beqz	a5,800021e0 <wait+0x11a>
      release(&wait_lock);
    800021b4:	0000f517          	auipc	a0,0xf
    800021b8:	10450513          	addi	a0,a0,260 # 800112b8 <wait_lock>
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	ac8080e7          	jalr	-1336(ra) # 80000c84 <release>
      return -1;
    800021c4:	59fd                	li	s3,-1
}
    800021c6:	854e                	mv	a0,s3
    800021c8:	60a6                	ld	ra,72(sp)
    800021ca:	6406                	ld	s0,64(sp)
    800021cc:	74e2                	ld	s1,56(sp)
    800021ce:	7942                	ld	s2,48(sp)
    800021d0:	79a2                	ld	s3,40(sp)
    800021d2:	7a02                	ld	s4,32(sp)
    800021d4:	6ae2                	ld	s5,24(sp)
    800021d6:	6b42                	ld	s6,16(sp)
    800021d8:	6ba2                	ld	s7,8(sp)
    800021da:	6c02                	ld	s8,0(sp)
    800021dc:	6161                	addi	sp,sp,80
    800021de:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021e0:	85e2                	mv	a1,s8
    800021e2:	854a                	mv	a0,s2
    800021e4:	00000097          	auipc	ra,0x0
    800021e8:	e7e080e7          	jalr	-386(ra) # 80002062 <sleep>
    havekids = 0;
    800021ec:	b715                	j	80002110 <wait+0x4a>

00000000800021ee <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021ee:	7139                	addi	sp,sp,-64
    800021f0:	fc06                	sd	ra,56(sp)
    800021f2:	f822                	sd	s0,48(sp)
    800021f4:	f426                	sd	s1,40(sp)
    800021f6:	f04a                	sd	s2,32(sp)
    800021f8:	ec4e                	sd	s3,24(sp)
    800021fa:	e852                	sd	s4,16(sp)
    800021fc:	e456                	sd	s5,8(sp)
    800021fe:	0080                	addi	s0,sp,64
    80002200:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002202:	0000f497          	auipc	s1,0xf
    80002206:	4ce48493          	addi	s1,s1,1230 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000220a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000220c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000220e:	00015917          	auipc	s2,0x15
    80002212:	ec290913          	addi	s2,s2,-318 # 800170d0 <tickslock>
    80002216:	a811                	j	8000222a <wakeup+0x3c>
      }
      release(&p->lock);
    80002218:	8526                	mv	a0,s1
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	a6a080e7          	jalr	-1430(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002222:	16848493          	addi	s1,s1,360
    80002226:	03248663          	beq	s1,s2,80002252 <wakeup+0x64>
    if(p != myproc()){
    8000222a:	fffff097          	auipc	ra,0xfffff
    8000222e:	774080e7          	jalr	1908(ra) # 8000199e <myproc>
    80002232:	fea488e3          	beq	s1,a0,80002222 <wakeup+0x34>
      acquire(&p->lock);
    80002236:	8526                	mv	a0,s1
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	998080e7          	jalr	-1640(ra) # 80000bd0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002240:	4c9c                	lw	a5,24(s1)
    80002242:	fd379be3          	bne	a5,s3,80002218 <wakeup+0x2a>
    80002246:	709c                	ld	a5,32(s1)
    80002248:	fd4798e3          	bne	a5,s4,80002218 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000224c:	0154ac23          	sw	s5,24(s1)
    80002250:	b7e1                	j	80002218 <wakeup+0x2a>
    }
  }
}
    80002252:	70e2                	ld	ra,56(sp)
    80002254:	7442                	ld	s0,48(sp)
    80002256:	74a2                	ld	s1,40(sp)
    80002258:	7902                	ld	s2,32(sp)
    8000225a:	69e2                	ld	s3,24(sp)
    8000225c:	6a42                	ld	s4,16(sp)
    8000225e:	6aa2                	ld	s5,8(sp)
    80002260:	6121                	addi	sp,sp,64
    80002262:	8082                	ret

0000000080002264 <reparent>:
{
    80002264:	7179                	addi	sp,sp,-48
    80002266:	f406                	sd	ra,40(sp)
    80002268:	f022                	sd	s0,32(sp)
    8000226a:	ec26                	sd	s1,24(sp)
    8000226c:	e84a                	sd	s2,16(sp)
    8000226e:	e44e                	sd	s3,8(sp)
    80002270:	e052                	sd	s4,0(sp)
    80002272:	1800                	addi	s0,sp,48
    80002274:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002276:	0000f497          	auipc	s1,0xf
    8000227a:	45a48493          	addi	s1,s1,1114 # 800116d0 <proc>
      pp->parent = initproc;
    8000227e:	00007a17          	auipc	s4,0x7
    80002282:	daaa0a13          	addi	s4,s4,-598 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002286:	00015997          	auipc	s3,0x15
    8000228a:	e4a98993          	addi	s3,s3,-438 # 800170d0 <tickslock>
    8000228e:	a029                	j	80002298 <reparent+0x34>
    80002290:	16848493          	addi	s1,s1,360
    80002294:	01348d63          	beq	s1,s3,800022ae <reparent+0x4a>
    if(pp->parent == p){
    80002298:	7c9c                	ld	a5,56(s1)
    8000229a:	ff279be3          	bne	a5,s2,80002290 <reparent+0x2c>
      pp->parent = initproc;
    8000229e:	000a3503          	ld	a0,0(s4)
    800022a2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800022a4:	00000097          	auipc	ra,0x0
    800022a8:	f4a080e7          	jalr	-182(ra) # 800021ee <wakeup>
    800022ac:	b7d5                	j	80002290 <reparent+0x2c>
}
    800022ae:	70a2                	ld	ra,40(sp)
    800022b0:	7402                	ld	s0,32(sp)
    800022b2:	64e2                	ld	s1,24(sp)
    800022b4:	6942                	ld	s2,16(sp)
    800022b6:	69a2                	ld	s3,8(sp)
    800022b8:	6a02                	ld	s4,0(sp)
    800022ba:	6145                	addi	sp,sp,48
    800022bc:	8082                	ret

00000000800022be <exit>:
{
    800022be:	7179                	addi	sp,sp,-48
    800022c0:	f406                	sd	ra,40(sp)
    800022c2:	f022                	sd	s0,32(sp)
    800022c4:	ec26                	sd	s1,24(sp)
    800022c6:	e84a                	sd	s2,16(sp)
    800022c8:	e44e                	sd	s3,8(sp)
    800022ca:	e052                	sd	s4,0(sp)
    800022cc:	1800                	addi	s0,sp,48
    800022ce:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	6ce080e7          	jalr	1742(ra) # 8000199e <myproc>
    800022d8:	89aa                	mv	s3,a0
  if(p == initproc)
    800022da:	00007797          	auipc	a5,0x7
    800022de:	d4e7b783          	ld	a5,-690(a5) # 80009028 <initproc>
    800022e2:	0d050493          	addi	s1,a0,208
    800022e6:	15050913          	addi	s2,a0,336
    800022ea:	02a79363          	bne	a5,a0,80002310 <exit+0x52>
    panic("init exiting");
    800022ee:	00006517          	auipc	a0,0x6
    800022f2:	f7250513          	addi	a0,a0,-142 # 80008260 <digits+0x220>
    800022f6:	ffffe097          	auipc	ra,0xffffe
    800022fa:	244080e7          	jalr	580(ra) # 8000053a <panic>
      fileclose(f);
    800022fe:	00002097          	auipc	ra,0x2
    80002302:	2a4080e7          	jalr	676(ra) # 800045a2 <fileclose>
      p->ofile[fd] = 0;
    80002306:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000230a:	04a1                	addi	s1,s1,8
    8000230c:	01248563          	beq	s1,s2,80002316 <exit+0x58>
    if(p->ofile[fd]){
    80002310:	6088                	ld	a0,0(s1)
    80002312:	f575                	bnez	a0,800022fe <exit+0x40>
    80002314:	bfdd                	j	8000230a <exit+0x4c>
  begin_op();
    80002316:	00002097          	auipc	ra,0x2
    8000231a:	dc4080e7          	jalr	-572(ra) # 800040da <begin_op>
  iput(p->cwd);
    8000231e:	1509b503          	ld	a0,336(s3)
    80002322:	00001097          	auipc	ra,0x1
    80002326:	596080e7          	jalr	1430(ra) # 800038b8 <iput>
  end_op();
    8000232a:	00002097          	auipc	ra,0x2
    8000232e:	e2e080e7          	jalr	-466(ra) # 80004158 <end_op>
  p->cwd = 0;
    80002332:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002336:	0000f497          	auipc	s1,0xf
    8000233a:	f8248493          	addi	s1,s1,-126 # 800112b8 <wait_lock>
    8000233e:	8526                	mv	a0,s1
    80002340:	fffff097          	auipc	ra,0xfffff
    80002344:	890080e7          	jalr	-1904(ra) # 80000bd0 <acquire>
  reparent(p);
    80002348:	854e                	mv	a0,s3
    8000234a:	00000097          	auipc	ra,0x0
    8000234e:	f1a080e7          	jalr	-230(ra) # 80002264 <reparent>
  wakeup(p->parent);
    80002352:	0389b503          	ld	a0,56(s3)
    80002356:	00000097          	auipc	ra,0x0
    8000235a:	e98080e7          	jalr	-360(ra) # 800021ee <wakeup>
  acquire(&p->lock);
    8000235e:	854e                	mv	a0,s3
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	870080e7          	jalr	-1936(ra) # 80000bd0 <acquire>
  p->xstate = status;
    80002368:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000236c:	4795                	li	a5,5
    8000236e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002372:	8526                	mv	a0,s1
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	910080e7          	jalr	-1776(ra) # 80000c84 <release>
  sched();
    8000237c:	00000097          	auipc	ra,0x0
    80002380:	bd4080e7          	jalr	-1068(ra) # 80001f50 <sched>
  panic("zombie exit");
    80002384:	00006517          	auipc	a0,0x6
    80002388:	eec50513          	addi	a0,a0,-276 # 80008270 <digits+0x230>
    8000238c:	ffffe097          	auipc	ra,0xffffe
    80002390:	1ae080e7          	jalr	430(ra) # 8000053a <panic>

0000000080002394 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002394:	7179                	addi	sp,sp,-48
    80002396:	f406                	sd	ra,40(sp)
    80002398:	f022                	sd	s0,32(sp)
    8000239a:	ec26                	sd	s1,24(sp)
    8000239c:	e84a                	sd	s2,16(sp)
    8000239e:	e44e                	sd	s3,8(sp)
    800023a0:	1800                	addi	s0,sp,48
    800023a2:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023a4:	0000f497          	auipc	s1,0xf
    800023a8:	32c48493          	addi	s1,s1,812 # 800116d0 <proc>
    800023ac:	00015997          	auipc	s3,0x15
    800023b0:	d2498993          	addi	s3,s3,-732 # 800170d0 <tickslock>
    acquire(&p->lock);
    800023b4:	8526                	mv	a0,s1
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	81a080e7          	jalr	-2022(ra) # 80000bd0 <acquire>
    if(p->pid == pid){
    800023be:	589c                	lw	a5,48(s1)
    800023c0:	01278d63          	beq	a5,s2,800023da <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023c4:	8526                	mv	a0,s1
    800023c6:	fffff097          	auipc	ra,0xfffff
    800023ca:	8be080e7          	jalr	-1858(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023ce:	16848493          	addi	s1,s1,360
    800023d2:	ff3491e3          	bne	s1,s3,800023b4 <kill+0x20>
  }
  return -1;
    800023d6:	557d                	li	a0,-1
    800023d8:	a829                	j	800023f2 <kill+0x5e>
      p->killed = 1;
    800023da:	4785                	li	a5,1
    800023dc:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800023de:	4c98                	lw	a4,24(s1)
    800023e0:	4789                	li	a5,2
    800023e2:	00f70f63          	beq	a4,a5,80002400 <kill+0x6c>
      release(&p->lock);
    800023e6:	8526                	mv	a0,s1
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	89c080e7          	jalr	-1892(ra) # 80000c84 <release>
      return 0;
    800023f0:	4501                	li	a0,0
}
    800023f2:	70a2                	ld	ra,40(sp)
    800023f4:	7402                	ld	s0,32(sp)
    800023f6:	64e2                	ld	s1,24(sp)
    800023f8:	6942                	ld	s2,16(sp)
    800023fa:	69a2                	ld	s3,8(sp)
    800023fc:	6145                	addi	sp,sp,48
    800023fe:	8082                	ret
        p->state = RUNNABLE;
    80002400:	478d                	li	a5,3
    80002402:	cc9c                	sw	a5,24(s1)
    80002404:	b7cd                	j	800023e6 <kill+0x52>

0000000080002406 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002406:	7179                	addi	sp,sp,-48
    80002408:	f406                	sd	ra,40(sp)
    8000240a:	f022                	sd	s0,32(sp)
    8000240c:	ec26                	sd	s1,24(sp)
    8000240e:	e84a                	sd	s2,16(sp)
    80002410:	e44e                	sd	s3,8(sp)
    80002412:	e052                	sd	s4,0(sp)
    80002414:	1800                	addi	s0,sp,48
    80002416:	84aa                	mv	s1,a0
    80002418:	892e                	mv	s2,a1
    8000241a:	89b2                	mv	s3,a2
    8000241c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	580080e7          	jalr	1408(ra) # 8000199e <myproc>
  if(user_dst){
    80002426:	c08d                	beqz	s1,80002448 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002428:	86d2                	mv	a3,s4
    8000242a:	864e                	mv	a2,s3
    8000242c:	85ca                	mv	a1,s2
    8000242e:	6928                	ld	a0,80(a0)
    80002430:	fffff097          	auipc	ra,0xfffff
    80002434:	232080e7          	jalr	562(ra) # 80001662 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002438:	70a2                	ld	ra,40(sp)
    8000243a:	7402                	ld	s0,32(sp)
    8000243c:	64e2                	ld	s1,24(sp)
    8000243e:	6942                	ld	s2,16(sp)
    80002440:	69a2                	ld	s3,8(sp)
    80002442:	6a02                	ld	s4,0(sp)
    80002444:	6145                	addi	sp,sp,48
    80002446:	8082                	ret
    memmove((char *)dst, src, len);
    80002448:	000a061b          	sext.w	a2,s4
    8000244c:	85ce                	mv	a1,s3
    8000244e:	854a                	mv	a0,s2
    80002450:	fffff097          	auipc	ra,0xfffff
    80002454:	8d8080e7          	jalr	-1832(ra) # 80000d28 <memmove>
    return 0;
    80002458:	8526                	mv	a0,s1
    8000245a:	bff9                	j	80002438 <either_copyout+0x32>

000000008000245c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000245c:	7179                	addi	sp,sp,-48
    8000245e:	f406                	sd	ra,40(sp)
    80002460:	f022                	sd	s0,32(sp)
    80002462:	ec26                	sd	s1,24(sp)
    80002464:	e84a                	sd	s2,16(sp)
    80002466:	e44e                	sd	s3,8(sp)
    80002468:	e052                	sd	s4,0(sp)
    8000246a:	1800                	addi	s0,sp,48
    8000246c:	892a                	mv	s2,a0
    8000246e:	84ae                	mv	s1,a1
    80002470:	89b2                	mv	s3,a2
    80002472:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002474:	fffff097          	auipc	ra,0xfffff
    80002478:	52a080e7          	jalr	1322(ra) # 8000199e <myproc>
  if(user_src){
    8000247c:	c08d                	beqz	s1,8000249e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000247e:	86d2                	mv	a3,s4
    80002480:	864e                	mv	a2,s3
    80002482:	85ca                	mv	a1,s2
    80002484:	6928                	ld	a0,80(a0)
    80002486:	fffff097          	auipc	ra,0xfffff
    8000248a:	268080e7          	jalr	616(ra) # 800016ee <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000248e:	70a2                	ld	ra,40(sp)
    80002490:	7402                	ld	s0,32(sp)
    80002492:	64e2                	ld	s1,24(sp)
    80002494:	6942                	ld	s2,16(sp)
    80002496:	69a2                	ld	s3,8(sp)
    80002498:	6a02                	ld	s4,0(sp)
    8000249a:	6145                	addi	sp,sp,48
    8000249c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000249e:	000a061b          	sext.w	a2,s4
    800024a2:	85ce                	mv	a1,s3
    800024a4:	854a                	mv	a0,s2
    800024a6:	fffff097          	auipc	ra,0xfffff
    800024aa:	882080e7          	jalr	-1918(ra) # 80000d28 <memmove>
    return 0;
    800024ae:	8526                	mv	a0,s1
    800024b0:	bff9                	j	8000248e <either_copyin+0x32>

00000000800024b2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024b2:	715d                	addi	sp,sp,-80
    800024b4:	e486                	sd	ra,72(sp)
    800024b6:	e0a2                	sd	s0,64(sp)
    800024b8:	fc26                	sd	s1,56(sp)
    800024ba:	f84a                	sd	s2,48(sp)
    800024bc:	f44e                	sd	s3,40(sp)
    800024be:	f052                	sd	s4,32(sp)
    800024c0:	ec56                	sd	s5,24(sp)
    800024c2:	e85a                	sd	s6,16(sp)
    800024c4:	e45e                	sd	s7,8(sp)
    800024c6:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800024c8:	00006517          	auipc	a0,0x6
    800024cc:	c0050513          	addi	a0,a0,-1024 # 800080c8 <digits+0x88>
    800024d0:	ffffe097          	auipc	ra,0xffffe
    800024d4:	0b4080e7          	jalr	180(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800024d8:	0000f497          	auipc	s1,0xf
    800024dc:	35048493          	addi	s1,s1,848 # 80011828 <proc+0x158>
    800024e0:	00015917          	auipc	s2,0x15
    800024e4:	d4890913          	addi	s2,s2,-696 # 80017228 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024e8:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800024ea:	00006997          	auipc	s3,0x6
    800024ee:	d9698993          	addi	s3,s3,-618 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800024f2:	00006a97          	auipc	s5,0x6
    800024f6:	d96a8a93          	addi	s5,s5,-618 # 80008288 <digits+0x248>
    printf("\n");
    800024fa:	00006a17          	auipc	s4,0x6
    800024fe:	bcea0a13          	addi	s4,s4,-1074 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002502:	00006b97          	auipc	s7,0x6
    80002506:	dbeb8b93          	addi	s7,s7,-578 # 800082c0 <states.0>
    8000250a:	a00d                	j	8000252c <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000250c:	ed86a583          	lw	a1,-296(a3)
    80002510:	8556                	mv	a0,s5
    80002512:	ffffe097          	auipc	ra,0xffffe
    80002516:	072080e7          	jalr	114(ra) # 80000584 <printf>
    printf("\n");
    8000251a:	8552                	mv	a0,s4
    8000251c:	ffffe097          	auipc	ra,0xffffe
    80002520:	068080e7          	jalr	104(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002524:	16848493          	addi	s1,s1,360
    80002528:	03248263          	beq	s1,s2,8000254c <procdump+0x9a>
    if(p->state == UNUSED)
    8000252c:	86a6                	mv	a3,s1
    8000252e:	ec04a783          	lw	a5,-320(s1)
    80002532:	dbed                	beqz	a5,80002524 <procdump+0x72>
      state = "???";
    80002534:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002536:	fcfb6be3          	bltu	s6,a5,8000250c <procdump+0x5a>
    8000253a:	02079713          	slli	a4,a5,0x20
    8000253e:	01d75793          	srli	a5,a4,0x1d
    80002542:	97de                	add	a5,a5,s7
    80002544:	6390                	ld	a2,0(a5)
    80002546:	f279                	bnez	a2,8000250c <procdump+0x5a>
      state = "???";
    80002548:	864e                	mv	a2,s3
    8000254a:	b7c9                	j	8000250c <procdump+0x5a>
  }
}
    8000254c:	60a6                	ld	ra,72(sp)
    8000254e:	6406                	ld	s0,64(sp)
    80002550:	74e2                	ld	s1,56(sp)
    80002552:	7942                	ld	s2,48(sp)
    80002554:	79a2                	ld	s3,40(sp)
    80002556:	7a02                	ld	s4,32(sp)
    80002558:	6ae2                	ld	s5,24(sp)
    8000255a:	6b42                	ld	s6,16(sp)
    8000255c:	6ba2                	ld	s7,8(sp)
    8000255e:	6161                	addi	sp,sp,80
    80002560:	8082                	ret

0000000080002562 <swtch>:
    80002562:	00153023          	sd	ra,0(a0)
    80002566:	00253423          	sd	sp,8(a0)
    8000256a:	e900                	sd	s0,16(a0)
    8000256c:	ed04                	sd	s1,24(a0)
    8000256e:	03253023          	sd	s2,32(a0)
    80002572:	03353423          	sd	s3,40(a0)
    80002576:	03453823          	sd	s4,48(a0)
    8000257a:	03553c23          	sd	s5,56(a0)
    8000257e:	05653023          	sd	s6,64(a0)
    80002582:	05753423          	sd	s7,72(a0)
    80002586:	05853823          	sd	s8,80(a0)
    8000258a:	05953c23          	sd	s9,88(a0)
    8000258e:	07a53023          	sd	s10,96(a0)
    80002592:	07b53423          	sd	s11,104(a0)
    80002596:	0005b083          	ld	ra,0(a1)
    8000259a:	0085b103          	ld	sp,8(a1)
    8000259e:	6980                	ld	s0,16(a1)
    800025a0:	6d84                	ld	s1,24(a1)
    800025a2:	0205b903          	ld	s2,32(a1)
    800025a6:	0285b983          	ld	s3,40(a1)
    800025aa:	0305ba03          	ld	s4,48(a1)
    800025ae:	0385ba83          	ld	s5,56(a1)
    800025b2:	0405bb03          	ld	s6,64(a1)
    800025b6:	0485bb83          	ld	s7,72(a1)
    800025ba:	0505bc03          	ld	s8,80(a1)
    800025be:	0585bc83          	ld	s9,88(a1)
    800025c2:	0605bd03          	ld	s10,96(a1)
    800025c6:	0685bd83          	ld	s11,104(a1)
    800025ca:	8082                	ret

00000000800025cc <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025cc:	1141                	addi	sp,sp,-16
    800025ce:	e406                	sd	ra,8(sp)
    800025d0:	e022                	sd	s0,0(sp)
    800025d2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800025d4:	00006597          	auipc	a1,0x6
    800025d8:	d1c58593          	addi	a1,a1,-740 # 800082f0 <states.0+0x30>
    800025dc:	00015517          	auipc	a0,0x15
    800025e0:	af450513          	addi	a0,a0,-1292 # 800170d0 <tickslock>
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	55c080e7          	jalr	1372(ra) # 80000b40 <initlock>
}
    800025ec:	60a2                	ld	ra,8(sp)
    800025ee:	6402                	ld	s0,0(sp)
    800025f0:	0141                	addi	sp,sp,16
    800025f2:	8082                	ret

00000000800025f4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800025f4:	1141                	addi	sp,sp,-16
    800025f6:	e422                	sd	s0,8(sp)
    800025f8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025fa:	00003797          	auipc	a5,0x3
    800025fe:	5d678793          	addi	a5,a5,1494 # 80005bd0 <kernelvec>
    80002602:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002606:	6422                	ld	s0,8(sp)
    80002608:	0141                	addi	sp,sp,16
    8000260a:	8082                	ret

000000008000260c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000260c:	1141                	addi	sp,sp,-16
    8000260e:	e406                	sd	ra,8(sp)
    80002610:	e022                	sd	s0,0(sp)
    80002612:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002614:	fffff097          	auipc	ra,0xfffff
    80002618:	38a080e7          	jalr	906(ra) # 8000199e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000261c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002620:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002622:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002626:	00005697          	auipc	a3,0x5
    8000262a:	9da68693          	addi	a3,a3,-1574 # 80007000 <_trampoline>
    8000262e:	00005717          	auipc	a4,0x5
    80002632:	9d270713          	addi	a4,a4,-1582 # 80007000 <_trampoline>
    80002636:	8f15                	sub	a4,a4,a3
    80002638:	040007b7          	lui	a5,0x4000
    8000263c:	17fd                	addi	a5,a5,-1
    8000263e:	07b2                	slli	a5,a5,0xc
    80002640:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002642:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002646:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002648:	18002673          	csrr	a2,satp
    8000264c:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000264e:	6d30                	ld	a2,88(a0)
    80002650:	6138                	ld	a4,64(a0)
    80002652:	6585                	lui	a1,0x1
    80002654:	972e                	add	a4,a4,a1
    80002656:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002658:	6d38                	ld	a4,88(a0)
    8000265a:	00000617          	auipc	a2,0x0
    8000265e:	13860613          	addi	a2,a2,312 # 80002792 <usertrap>
    80002662:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002664:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002666:	8612                	mv	a2,tp
    80002668:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000266a:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000266e:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002672:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002676:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000267a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000267c:	6f18                	ld	a4,24(a4)
    8000267e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002682:	692c                	ld	a1,80(a0)
    80002684:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002686:	00005717          	auipc	a4,0x5
    8000268a:	a0a70713          	addi	a4,a4,-1526 # 80007090 <userret>
    8000268e:	8f15                	sub	a4,a4,a3
    80002690:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002692:	577d                	li	a4,-1
    80002694:	177e                	slli	a4,a4,0x3f
    80002696:	8dd9                	or	a1,a1,a4
    80002698:	02000537          	lui	a0,0x2000
    8000269c:	157d                	addi	a0,a0,-1
    8000269e:	0536                	slli	a0,a0,0xd
    800026a0:	9782                	jalr	a5
}
    800026a2:	60a2                	ld	ra,8(sp)
    800026a4:	6402                	ld	s0,0(sp)
    800026a6:	0141                	addi	sp,sp,16
    800026a8:	8082                	ret

00000000800026aa <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026aa:	1101                	addi	sp,sp,-32
    800026ac:	ec06                	sd	ra,24(sp)
    800026ae:	e822                	sd	s0,16(sp)
    800026b0:	e426                	sd	s1,8(sp)
    800026b2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800026b4:	00015497          	auipc	s1,0x15
    800026b8:	a1c48493          	addi	s1,s1,-1508 # 800170d0 <tickslock>
    800026bc:	8526                	mv	a0,s1
    800026be:	ffffe097          	auipc	ra,0xffffe
    800026c2:	512080e7          	jalr	1298(ra) # 80000bd0 <acquire>
  ticks++;
    800026c6:	00007517          	auipc	a0,0x7
    800026ca:	96a50513          	addi	a0,a0,-1686 # 80009030 <ticks>
    800026ce:	411c                	lw	a5,0(a0)
    800026d0:	2785                	addiw	a5,a5,1
    800026d2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800026d4:	00000097          	auipc	ra,0x0
    800026d8:	b1a080e7          	jalr	-1254(ra) # 800021ee <wakeup>
  release(&tickslock);
    800026dc:	8526                	mv	a0,s1
    800026de:	ffffe097          	auipc	ra,0xffffe
    800026e2:	5a6080e7          	jalr	1446(ra) # 80000c84 <release>
}
    800026e6:	60e2                	ld	ra,24(sp)
    800026e8:	6442                	ld	s0,16(sp)
    800026ea:	64a2                	ld	s1,8(sp)
    800026ec:	6105                	addi	sp,sp,32
    800026ee:	8082                	ret

00000000800026f0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800026f0:	1101                	addi	sp,sp,-32
    800026f2:	ec06                	sd	ra,24(sp)
    800026f4:	e822                	sd	s0,16(sp)
    800026f6:	e426                	sd	s1,8(sp)
    800026f8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026fa:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800026fe:	00074d63          	bltz	a4,80002718 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002702:	57fd                	li	a5,-1
    80002704:	17fe                	slli	a5,a5,0x3f
    80002706:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002708:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000270a:	06f70363          	beq	a4,a5,80002770 <devintr+0x80>
  }
}
    8000270e:	60e2                	ld	ra,24(sp)
    80002710:	6442                	ld	s0,16(sp)
    80002712:	64a2                	ld	s1,8(sp)
    80002714:	6105                	addi	sp,sp,32
    80002716:	8082                	ret
     (scause & 0xff) == 9){
    80002718:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    8000271c:	46a5                	li	a3,9
    8000271e:	fed792e3          	bne	a5,a3,80002702 <devintr+0x12>
    int irq = plic_claim();
    80002722:	00003097          	auipc	ra,0x3
    80002726:	5b6080e7          	jalr	1462(ra) # 80005cd8 <plic_claim>
    8000272a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000272c:	47a9                	li	a5,10
    8000272e:	02f50763          	beq	a0,a5,8000275c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002732:	4785                	li	a5,1
    80002734:	02f50963          	beq	a0,a5,80002766 <devintr+0x76>
    return 1;
    80002738:	4505                	li	a0,1
    } else if(irq){
    8000273a:	d8f1                	beqz	s1,8000270e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000273c:	85a6                	mv	a1,s1
    8000273e:	00006517          	auipc	a0,0x6
    80002742:	bba50513          	addi	a0,a0,-1094 # 800082f8 <states.0+0x38>
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	e3e080e7          	jalr	-450(ra) # 80000584 <printf>
      plic_complete(irq);
    8000274e:	8526                	mv	a0,s1
    80002750:	00003097          	auipc	ra,0x3
    80002754:	5ac080e7          	jalr	1452(ra) # 80005cfc <plic_complete>
    return 1;
    80002758:	4505                	li	a0,1
    8000275a:	bf55                	j	8000270e <devintr+0x1e>
      uartintr();
    8000275c:	ffffe097          	auipc	ra,0xffffe
    80002760:	236080e7          	jalr	566(ra) # 80000992 <uartintr>
    80002764:	b7ed                	j	8000274e <devintr+0x5e>
      virtio_disk_intr();
    80002766:	00004097          	auipc	ra,0x4
    8000276a:	a22080e7          	jalr	-1502(ra) # 80006188 <virtio_disk_intr>
    8000276e:	b7c5                	j	8000274e <devintr+0x5e>
    if(cpuid() == 0){
    80002770:	fffff097          	auipc	ra,0xfffff
    80002774:	202080e7          	jalr	514(ra) # 80001972 <cpuid>
    80002778:	c901                	beqz	a0,80002788 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000277a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000277e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002780:	14479073          	csrw	sip,a5
    return 2;
    80002784:	4509                	li	a0,2
    80002786:	b761                	j	8000270e <devintr+0x1e>
      clockintr();
    80002788:	00000097          	auipc	ra,0x0
    8000278c:	f22080e7          	jalr	-222(ra) # 800026aa <clockintr>
    80002790:	b7ed                	j	8000277a <devintr+0x8a>

0000000080002792 <usertrap>:
{
    80002792:	1101                	addi	sp,sp,-32
    80002794:	ec06                	sd	ra,24(sp)
    80002796:	e822                	sd	s0,16(sp)
    80002798:	e426                	sd	s1,8(sp)
    8000279a:	e04a                	sd	s2,0(sp)
    8000279c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000279e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027a2:	1007f793          	andi	a5,a5,256
    800027a6:	e3ad                	bnez	a5,80002808 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027a8:	00003797          	auipc	a5,0x3
    800027ac:	42878793          	addi	a5,a5,1064 # 80005bd0 <kernelvec>
    800027b0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027b4:	fffff097          	auipc	ra,0xfffff
    800027b8:	1ea080e7          	jalr	490(ra) # 8000199e <myproc>
    800027bc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027be:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027c0:	14102773          	csrr	a4,sepc
    800027c4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027c6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027ca:	47a1                	li	a5,8
    800027cc:	04f71c63          	bne	a4,a5,80002824 <usertrap+0x92>
    if(p->killed)
    800027d0:	551c                	lw	a5,40(a0)
    800027d2:	e3b9                	bnez	a5,80002818 <usertrap+0x86>
    p->trapframe->epc += 4;
    800027d4:	6cb8                	ld	a4,88(s1)
    800027d6:	6f1c                	ld	a5,24(a4)
    800027d8:	0791                	addi	a5,a5,4
    800027da:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027dc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800027e0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027e4:	10079073          	csrw	sstatus,a5
    syscall();
    800027e8:	00000097          	auipc	ra,0x0
    800027ec:	2e0080e7          	jalr	736(ra) # 80002ac8 <syscall>
  if(p->killed)
    800027f0:	549c                	lw	a5,40(s1)
    800027f2:	ebc1                	bnez	a5,80002882 <usertrap+0xf0>
  usertrapret();
    800027f4:	00000097          	auipc	ra,0x0
    800027f8:	e18080e7          	jalr	-488(ra) # 8000260c <usertrapret>
}
    800027fc:	60e2                	ld	ra,24(sp)
    800027fe:	6442                	ld	s0,16(sp)
    80002800:	64a2                	ld	s1,8(sp)
    80002802:	6902                	ld	s2,0(sp)
    80002804:	6105                	addi	sp,sp,32
    80002806:	8082                	ret
    panic("usertrap: not from user mode");
    80002808:	00006517          	auipc	a0,0x6
    8000280c:	b1050513          	addi	a0,a0,-1264 # 80008318 <states.0+0x58>
    80002810:	ffffe097          	auipc	ra,0xffffe
    80002814:	d2a080e7          	jalr	-726(ra) # 8000053a <panic>
      exit(-1);
    80002818:	557d                	li	a0,-1
    8000281a:	00000097          	auipc	ra,0x0
    8000281e:	aa4080e7          	jalr	-1372(ra) # 800022be <exit>
    80002822:	bf4d                	j	800027d4 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002824:	00000097          	auipc	ra,0x0
    80002828:	ecc080e7          	jalr	-308(ra) # 800026f0 <devintr>
    8000282c:	892a                	mv	s2,a0
    8000282e:	c501                	beqz	a0,80002836 <usertrap+0xa4>
  if(p->killed)
    80002830:	549c                	lw	a5,40(s1)
    80002832:	c3a1                	beqz	a5,80002872 <usertrap+0xe0>
    80002834:	a815                	j	80002868 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002836:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000283a:	5890                	lw	a2,48(s1)
    8000283c:	00006517          	auipc	a0,0x6
    80002840:	afc50513          	addi	a0,a0,-1284 # 80008338 <states.0+0x78>
    80002844:	ffffe097          	auipc	ra,0xffffe
    80002848:	d40080e7          	jalr	-704(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000284c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002850:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002854:	00006517          	auipc	a0,0x6
    80002858:	b1450513          	addi	a0,a0,-1260 # 80008368 <states.0+0xa8>
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	d28080e7          	jalr	-728(ra) # 80000584 <printf>
    p->killed = 1;
    80002864:	4785                	li	a5,1
    80002866:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002868:	557d                	li	a0,-1
    8000286a:	00000097          	auipc	ra,0x0
    8000286e:	a54080e7          	jalr	-1452(ra) # 800022be <exit>
  if(which_dev == 2)
    80002872:	4789                	li	a5,2
    80002874:	f8f910e3          	bne	s2,a5,800027f4 <usertrap+0x62>
    yield();
    80002878:	fffff097          	auipc	ra,0xfffff
    8000287c:	7ae080e7          	jalr	1966(ra) # 80002026 <yield>
    80002880:	bf95                	j	800027f4 <usertrap+0x62>
  int which_dev = 0;
    80002882:	4901                	li	s2,0
    80002884:	b7d5                	j	80002868 <usertrap+0xd6>

0000000080002886 <kerneltrap>:
{
    80002886:	7179                	addi	sp,sp,-48
    80002888:	f406                	sd	ra,40(sp)
    8000288a:	f022                	sd	s0,32(sp)
    8000288c:	ec26                	sd	s1,24(sp)
    8000288e:	e84a                	sd	s2,16(sp)
    80002890:	e44e                	sd	s3,8(sp)
    80002892:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002894:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002898:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000289c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028a0:	1004f793          	andi	a5,s1,256
    800028a4:	cb85                	beqz	a5,800028d4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028a6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028aa:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028ac:	ef85                	bnez	a5,800028e4 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800028ae:	00000097          	auipc	ra,0x0
    800028b2:	e42080e7          	jalr	-446(ra) # 800026f0 <devintr>
    800028b6:	cd1d                	beqz	a0,800028f4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800028b8:	4789                	li	a5,2
    800028ba:	06f50a63          	beq	a0,a5,8000292e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028be:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028c2:	10049073          	csrw	sstatus,s1
}
    800028c6:	70a2                	ld	ra,40(sp)
    800028c8:	7402                	ld	s0,32(sp)
    800028ca:	64e2                	ld	s1,24(sp)
    800028cc:	6942                	ld	s2,16(sp)
    800028ce:	69a2                	ld	s3,8(sp)
    800028d0:	6145                	addi	sp,sp,48
    800028d2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028d4:	00006517          	auipc	a0,0x6
    800028d8:	ab450513          	addi	a0,a0,-1356 # 80008388 <states.0+0xc8>
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	c5e080e7          	jalr	-930(ra) # 8000053a <panic>
    panic("kerneltrap: interrupts enabled");
    800028e4:	00006517          	auipc	a0,0x6
    800028e8:	acc50513          	addi	a0,a0,-1332 # 800083b0 <states.0+0xf0>
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	c4e080e7          	jalr	-946(ra) # 8000053a <panic>
    printf("scause %p\n", scause);
    800028f4:	85ce                	mv	a1,s3
    800028f6:	00006517          	auipc	a0,0x6
    800028fa:	ada50513          	addi	a0,a0,-1318 # 800083d0 <states.0+0x110>
    800028fe:	ffffe097          	auipc	ra,0xffffe
    80002902:	c86080e7          	jalr	-890(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002906:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000290a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000290e:	00006517          	auipc	a0,0x6
    80002912:	ad250513          	addi	a0,a0,-1326 # 800083e0 <states.0+0x120>
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	c6e080e7          	jalr	-914(ra) # 80000584 <printf>
    panic("kerneltrap");
    8000291e:	00006517          	auipc	a0,0x6
    80002922:	ada50513          	addi	a0,a0,-1318 # 800083f8 <states.0+0x138>
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	c14080e7          	jalr	-1004(ra) # 8000053a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000292e:	fffff097          	auipc	ra,0xfffff
    80002932:	070080e7          	jalr	112(ra) # 8000199e <myproc>
    80002936:	d541                	beqz	a0,800028be <kerneltrap+0x38>
    80002938:	fffff097          	auipc	ra,0xfffff
    8000293c:	066080e7          	jalr	102(ra) # 8000199e <myproc>
    80002940:	4d18                	lw	a4,24(a0)
    80002942:	4791                	li	a5,4
    80002944:	f6f71de3          	bne	a4,a5,800028be <kerneltrap+0x38>
    yield();
    80002948:	fffff097          	auipc	ra,0xfffff
    8000294c:	6de080e7          	jalr	1758(ra) # 80002026 <yield>
    80002950:	b7bd                	j	800028be <kerneltrap+0x38>

0000000080002952 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002952:	1101                	addi	sp,sp,-32
    80002954:	ec06                	sd	ra,24(sp)
    80002956:	e822                	sd	s0,16(sp)
    80002958:	e426                	sd	s1,8(sp)
    8000295a:	1000                	addi	s0,sp,32
    8000295c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000295e:	fffff097          	auipc	ra,0xfffff
    80002962:	040080e7          	jalr	64(ra) # 8000199e <myproc>
  switch (n) {
    80002966:	4795                	li	a5,5
    80002968:	0497e163          	bltu	a5,s1,800029aa <argraw+0x58>
    8000296c:	048a                	slli	s1,s1,0x2
    8000296e:	00006717          	auipc	a4,0x6
    80002972:	ac270713          	addi	a4,a4,-1342 # 80008430 <states.0+0x170>
    80002976:	94ba                	add	s1,s1,a4
    80002978:	409c                	lw	a5,0(s1)
    8000297a:	97ba                	add	a5,a5,a4
    8000297c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000297e:	6d3c                	ld	a5,88(a0)
    80002980:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002982:	60e2                	ld	ra,24(sp)
    80002984:	6442                	ld	s0,16(sp)
    80002986:	64a2                	ld	s1,8(sp)
    80002988:	6105                	addi	sp,sp,32
    8000298a:	8082                	ret
    return p->trapframe->a1;
    8000298c:	6d3c                	ld	a5,88(a0)
    8000298e:	7fa8                	ld	a0,120(a5)
    80002990:	bfcd                	j	80002982 <argraw+0x30>
    return p->trapframe->a2;
    80002992:	6d3c                	ld	a5,88(a0)
    80002994:	63c8                	ld	a0,128(a5)
    80002996:	b7f5                	j	80002982 <argraw+0x30>
    return p->trapframe->a3;
    80002998:	6d3c                	ld	a5,88(a0)
    8000299a:	67c8                	ld	a0,136(a5)
    8000299c:	b7dd                	j	80002982 <argraw+0x30>
    return p->trapframe->a4;
    8000299e:	6d3c                	ld	a5,88(a0)
    800029a0:	6bc8                	ld	a0,144(a5)
    800029a2:	b7c5                	j	80002982 <argraw+0x30>
    return p->trapframe->a5;
    800029a4:	6d3c                	ld	a5,88(a0)
    800029a6:	6fc8                	ld	a0,152(a5)
    800029a8:	bfe9                	j	80002982 <argraw+0x30>
  panic("argraw");
    800029aa:	00006517          	auipc	a0,0x6
    800029ae:	a5e50513          	addi	a0,a0,-1442 # 80008408 <states.0+0x148>
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	b88080e7          	jalr	-1144(ra) # 8000053a <panic>

00000000800029ba <fetchaddr>:
{
    800029ba:	1101                	addi	sp,sp,-32
    800029bc:	ec06                	sd	ra,24(sp)
    800029be:	e822                	sd	s0,16(sp)
    800029c0:	e426                	sd	s1,8(sp)
    800029c2:	e04a                	sd	s2,0(sp)
    800029c4:	1000                	addi	s0,sp,32
    800029c6:	84aa                	mv	s1,a0
    800029c8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029ca:	fffff097          	auipc	ra,0xfffff
    800029ce:	fd4080e7          	jalr	-44(ra) # 8000199e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800029d2:	653c                	ld	a5,72(a0)
    800029d4:	02f4f863          	bgeu	s1,a5,80002a04 <fetchaddr+0x4a>
    800029d8:	00848713          	addi	a4,s1,8
    800029dc:	02e7e663          	bltu	a5,a4,80002a08 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800029e0:	46a1                	li	a3,8
    800029e2:	8626                	mv	a2,s1
    800029e4:	85ca                	mv	a1,s2
    800029e6:	6928                	ld	a0,80(a0)
    800029e8:	fffff097          	auipc	ra,0xfffff
    800029ec:	d06080e7          	jalr	-762(ra) # 800016ee <copyin>
    800029f0:	00a03533          	snez	a0,a0
    800029f4:	40a00533          	neg	a0,a0
}
    800029f8:	60e2                	ld	ra,24(sp)
    800029fa:	6442                	ld	s0,16(sp)
    800029fc:	64a2                	ld	s1,8(sp)
    800029fe:	6902                	ld	s2,0(sp)
    80002a00:	6105                	addi	sp,sp,32
    80002a02:	8082                	ret
    return -1;
    80002a04:	557d                	li	a0,-1
    80002a06:	bfcd                	j	800029f8 <fetchaddr+0x3e>
    80002a08:	557d                	li	a0,-1
    80002a0a:	b7fd                	j	800029f8 <fetchaddr+0x3e>

0000000080002a0c <fetchstr>:
{
    80002a0c:	7179                	addi	sp,sp,-48
    80002a0e:	f406                	sd	ra,40(sp)
    80002a10:	f022                	sd	s0,32(sp)
    80002a12:	ec26                	sd	s1,24(sp)
    80002a14:	e84a                	sd	s2,16(sp)
    80002a16:	e44e                	sd	s3,8(sp)
    80002a18:	1800                	addi	s0,sp,48
    80002a1a:	892a                	mv	s2,a0
    80002a1c:	84ae                	mv	s1,a1
    80002a1e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a20:	fffff097          	auipc	ra,0xfffff
    80002a24:	f7e080e7          	jalr	-130(ra) # 8000199e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002a28:	86ce                	mv	a3,s3
    80002a2a:	864a                	mv	a2,s2
    80002a2c:	85a6                	mv	a1,s1
    80002a2e:	6928                	ld	a0,80(a0)
    80002a30:	fffff097          	auipc	ra,0xfffff
    80002a34:	d4c080e7          	jalr	-692(ra) # 8000177c <copyinstr>
  if(err < 0)
    80002a38:	00054763          	bltz	a0,80002a46 <fetchstr+0x3a>
  return strlen(buf);
    80002a3c:	8526                	mv	a0,s1
    80002a3e:	ffffe097          	auipc	ra,0xffffe
    80002a42:	40a080e7          	jalr	1034(ra) # 80000e48 <strlen>
}
    80002a46:	70a2                	ld	ra,40(sp)
    80002a48:	7402                	ld	s0,32(sp)
    80002a4a:	64e2                	ld	s1,24(sp)
    80002a4c:	6942                	ld	s2,16(sp)
    80002a4e:	69a2                	ld	s3,8(sp)
    80002a50:	6145                	addi	sp,sp,48
    80002a52:	8082                	ret

0000000080002a54 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002a54:	1101                	addi	sp,sp,-32
    80002a56:	ec06                	sd	ra,24(sp)
    80002a58:	e822                	sd	s0,16(sp)
    80002a5a:	e426                	sd	s1,8(sp)
    80002a5c:	1000                	addi	s0,sp,32
    80002a5e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a60:	00000097          	auipc	ra,0x0
    80002a64:	ef2080e7          	jalr	-270(ra) # 80002952 <argraw>
    80002a68:	c088                	sw	a0,0(s1)
  return 0;
}
    80002a6a:	4501                	li	a0,0
    80002a6c:	60e2                	ld	ra,24(sp)
    80002a6e:	6442                	ld	s0,16(sp)
    80002a70:	64a2                	ld	s1,8(sp)
    80002a72:	6105                	addi	sp,sp,32
    80002a74:	8082                	ret

0000000080002a76 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002a76:	1101                	addi	sp,sp,-32
    80002a78:	ec06                	sd	ra,24(sp)
    80002a7a:	e822                	sd	s0,16(sp)
    80002a7c:	e426                	sd	s1,8(sp)
    80002a7e:	1000                	addi	s0,sp,32
    80002a80:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a82:	00000097          	auipc	ra,0x0
    80002a86:	ed0080e7          	jalr	-304(ra) # 80002952 <argraw>
    80002a8a:	e088                	sd	a0,0(s1)
  return 0;
}
    80002a8c:	4501                	li	a0,0
    80002a8e:	60e2                	ld	ra,24(sp)
    80002a90:	6442                	ld	s0,16(sp)
    80002a92:	64a2                	ld	s1,8(sp)
    80002a94:	6105                	addi	sp,sp,32
    80002a96:	8082                	ret

0000000080002a98 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a98:	1101                	addi	sp,sp,-32
    80002a9a:	ec06                	sd	ra,24(sp)
    80002a9c:	e822                	sd	s0,16(sp)
    80002a9e:	e426                	sd	s1,8(sp)
    80002aa0:	e04a                	sd	s2,0(sp)
    80002aa2:	1000                	addi	s0,sp,32
    80002aa4:	84ae                	mv	s1,a1
    80002aa6:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002aa8:	00000097          	auipc	ra,0x0
    80002aac:	eaa080e7          	jalr	-342(ra) # 80002952 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002ab0:	864a                	mv	a2,s2
    80002ab2:	85a6                	mv	a1,s1
    80002ab4:	00000097          	auipc	ra,0x0
    80002ab8:	f58080e7          	jalr	-168(ra) # 80002a0c <fetchstr>
}
    80002abc:	60e2                	ld	ra,24(sp)
    80002abe:	6442                	ld	s0,16(sp)
    80002ac0:	64a2                	ld	s1,8(sp)
    80002ac2:	6902                	ld	s2,0(sp)
    80002ac4:	6105                	addi	sp,sp,32
    80002ac6:	8082                	ret

0000000080002ac8 <syscall>:
[SYS_tget]   sys_tget,
};

void
syscall(void)
{
    80002ac8:	1101                	addi	sp,sp,-32
    80002aca:	ec06                	sd	ra,24(sp)
    80002acc:	e822                	sd	s0,16(sp)
    80002ace:	e426                	sd	s1,8(sp)
    80002ad0:	e04a                	sd	s2,0(sp)
    80002ad2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ad4:	fffff097          	auipc	ra,0xfffff
    80002ad8:	eca080e7          	jalr	-310(ra) # 8000199e <myproc>
    80002adc:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ade:	05853903          	ld	s2,88(a0)
    80002ae2:	0a893783          	ld	a5,168(s2)
    80002ae6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002aea:	37fd                	addiw	a5,a5,-1
    80002aec:	4761                	li	a4,24
    80002aee:	00f76f63          	bltu	a4,a5,80002b0c <syscall+0x44>
    80002af2:	00369713          	slli	a4,a3,0x3
    80002af6:	00006797          	auipc	a5,0x6
    80002afa:	95278793          	addi	a5,a5,-1710 # 80008448 <syscalls>
    80002afe:	97ba                	add	a5,a5,a4
    80002b00:	639c                	ld	a5,0(a5)
    80002b02:	c789                	beqz	a5,80002b0c <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002b04:	9782                	jalr	a5
    80002b06:	06a93823          	sd	a0,112(s2)
    80002b0a:	a839                	j	80002b28 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b0c:	15848613          	addi	a2,s1,344
    80002b10:	588c                	lw	a1,48(s1)
    80002b12:	00006517          	auipc	a0,0x6
    80002b16:	8fe50513          	addi	a0,a0,-1794 # 80008410 <states.0+0x150>
    80002b1a:	ffffe097          	auipc	ra,0xffffe
    80002b1e:	a6a080e7          	jalr	-1430(ra) # 80000584 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b22:	6cbc                	ld	a5,88(s1)
    80002b24:	577d                	li	a4,-1
    80002b26:	fbb8                	sd	a4,112(a5)
  }
}
    80002b28:	60e2                	ld	ra,24(sp)
    80002b2a:	6442                	ld	s0,16(sp)
    80002b2c:	64a2                	ld	s1,8(sp)
    80002b2e:	6902                	ld	s2,0(sp)
    80002b30:	6105                	addi	sp,sp,32
    80002b32:	8082                	ret

0000000080002b34 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002b34:	1101                	addi	sp,sp,-32
    80002b36:	ec06                	sd	ra,24(sp)
    80002b38:	e822                	sd	s0,16(sp)
    80002b3a:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002b3c:	fec40593          	addi	a1,s0,-20
    80002b40:	4501                	li	a0,0
    80002b42:	00000097          	auipc	ra,0x0
    80002b46:	f12080e7          	jalr	-238(ra) # 80002a54 <argint>
    return -1;
    80002b4a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002b4c:	00054963          	bltz	a0,80002b5e <sys_exit+0x2a>
  exit(n);
    80002b50:	fec42503          	lw	a0,-20(s0)
    80002b54:	fffff097          	auipc	ra,0xfffff
    80002b58:	76a080e7          	jalr	1898(ra) # 800022be <exit>
  return 0;  // not reached
    80002b5c:	4781                	li	a5,0
}
    80002b5e:	853e                	mv	a0,a5
    80002b60:	60e2                	ld	ra,24(sp)
    80002b62:	6442                	ld	s0,16(sp)
    80002b64:	6105                	addi	sp,sp,32
    80002b66:	8082                	ret

0000000080002b68 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b68:	1141                	addi	sp,sp,-16
    80002b6a:	e406                	sd	ra,8(sp)
    80002b6c:	e022                	sd	s0,0(sp)
    80002b6e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b70:	fffff097          	auipc	ra,0xfffff
    80002b74:	e2e080e7          	jalr	-466(ra) # 8000199e <myproc>
}
    80002b78:	5908                	lw	a0,48(a0)
    80002b7a:	60a2                	ld	ra,8(sp)
    80002b7c:	6402                	ld	s0,0(sp)
    80002b7e:	0141                	addi	sp,sp,16
    80002b80:	8082                	ret

0000000080002b82 <sys_fork>:

uint64
sys_fork(void)
{
    80002b82:	1141                	addi	sp,sp,-16
    80002b84:	e406                	sd	ra,8(sp)
    80002b86:	e022                	sd	s0,0(sp)
    80002b88:	0800                	addi	s0,sp,16
  return fork();
    80002b8a:	fffff097          	auipc	ra,0xfffff
    80002b8e:	1e6080e7          	jalr	486(ra) # 80001d70 <fork>
}
    80002b92:	60a2                	ld	ra,8(sp)
    80002b94:	6402                	ld	s0,0(sp)
    80002b96:	0141                	addi	sp,sp,16
    80002b98:	8082                	ret

0000000080002b9a <sys_wait>:

uint64
sys_wait(void)
{
    80002b9a:	1101                	addi	sp,sp,-32
    80002b9c:	ec06                	sd	ra,24(sp)
    80002b9e:	e822                	sd	s0,16(sp)
    80002ba0:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002ba2:	fe840593          	addi	a1,s0,-24
    80002ba6:	4501                	li	a0,0
    80002ba8:	00000097          	auipc	ra,0x0
    80002bac:	ece080e7          	jalr	-306(ra) # 80002a76 <argaddr>
    80002bb0:	87aa                	mv	a5,a0
    return -1;
    80002bb2:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002bb4:	0007c863          	bltz	a5,80002bc4 <sys_wait+0x2a>
  return wait(p);
    80002bb8:	fe843503          	ld	a0,-24(s0)
    80002bbc:	fffff097          	auipc	ra,0xfffff
    80002bc0:	50a080e7          	jalr	1290(ra) # 800020c6 <wait>
}
    80002bc4:	60e2                	ld	ra,24(sp)
    80002bc6:	6442                	ld	s0,16(sp)
    80002bc8:	6105                	addi	sp,sp,32
    80002bca:	8082                	ret

0000000080002bcc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002bcc:	7179                	addi	sp,sp,-48
    80002bce:	f406                	sd	ra,40(sp)
    80002bd0:	f022                	sd	s0,32(sp)
    80002bd2:	ec26                	sd	s1,24(sp)
    80002bd4:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002bd6:	fdc40593          	addi	a1,s0,-36
    80002bda:	4501                	li	a0,0
    80002bdc:	00000097          	auipc	ra,0x0
    80002be0:	e78080e7          	jalr	-392(ra) # 80002a54 <argint>
    80002be4:	87aa                	mv	a5,a0
    return -1;
    80002be6:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002be8:	0207c063          	bltz	a5,80002c08 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002bec:	fffff097          	auipc	ra,0xfffff
    80002bf0:	db2080e7          	jalr	-590(ra) # 8000199e <myproc>
    80002bf4:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002bf6:	fdc42503          	lw	a0,-36(s0)
    80002bfa:	fffff097          	auipc	ra,0xfffff
    80002bfe:	0fe080e7          	jalr	254(ra) # 80001cf8 <growproc>
    80002c02:	00054863          	bltz	a0,80002c12 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002c06:	8526                	mv	a0,s1
}
    80002c08:	70a2                	ld	ra,40(sp)
    80002c0a:	7402                	ld	s0,32(sp)
    80002c0c:	64e2                	ld	s1,24(sp)
    80002c0e:	6145                	addi	sp,sp,48
    80002c10:	8082                	ret
    return -1;
    80002c12:	557d                	li	a0,-1
    80002c14:	bfd5                	j	80002c08 <sys_sbrk+0x3c>

0000000080002c16 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c16:	7139                	addi	sp,sp,-64
    80002c18:	fc06                	sd	ra,56(sp)
    80002c1a:	f822                	sd	s0,48(sp)
    80002c1c:	f426                	sd	s1,40(sp)
    80002c1e:	f04a                	sd	s2,32(sp)
    80002c20:	ec4e                	sd	s3,24(sp)
    80002c22:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002c24:	fcc40593          	addi	a1,s0,-52
    80002c28:	4501                	li	a0,0
    80002c2a:	00000097          	auipc	ra,0x0
    80002c2e:	e2a080e7          	jalr	-470(ra) # 80002a54 <argint>
    return -1;
    80002c32:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c34:	06054563          	bltz	a0,80002c9e <sys_sleep+0x88>
  acquire(&tickslock);
    80002c38:	00014517          	auipc	a0,0x14
    80002c3c:	49850513          	addi	a0,a0,1176 # 800170d0 <tickslock>
    80002c40:	ffffe097          	auipc	ra,0xffffe
    80002c44:	f90080e7          	jalr	-112(ra) # 80000bd0 <acquire>
  ticks0 = ticks;
    80002c48:	00006917          	auipc	s2,0x6
    80002c4c:	3e892903          	lw	s2,1000(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002c50:	fcc42783          	lw	a5,-52(s0)
    80002c54:	cf85                	beqz	a5,80002c8c <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c56:	00014997          	auipc	s3,0x14
    80002c5a:	47a98993          	addi	s3,s3,1146 # 800170d0 <tickslock>
    80002c5e:	00006497          	auipc	s1,0x6
    80002c62:	3d248493          	addi	s1,s1,978 # 80009030 <ticks>
    if(myproc()->killed){
    80002c66:	fffff097          	auipc	ra,0xfffff
    80002c6a:	d38080e7          	jalr	-712(ra) # 8000199e <myproc>
    80002c6e:	551c                	lw	a5,40(a0)
    80002c70:	ef9d                	bnez	a5,80002cae <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002c72:	85ce                	mv	a1,s3
    80002c74:	8526                	mv	a0,s1
    80002c76:	fffff097          	auipc	ra,0xfffff
    80002c7a:	3ec080e7          	jalr	1004(ra) # 80002062 <sleep>
  while(ticks - ticks0 < n){
    80002c7e:	409c                	lw	a5,0(s1)
    80002c80:	412787bb          	subw	a5,a5,s2
    80002c84:	fcc42703          	lw	a4,-52(s0)
    80002c88:	fce7efe3          	bltu	a5,a4,80002c66 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002c8c:	00014517          	auipc	a0,0x14
    80002c90:	44450513          	addi	a0,a0,1092 # 800170d0 <tickslock>
    80002c94:	ffffe097          	auipc	ra,0xffffe
    80002c98:	ff0080e7          	jalr	-16(ra) # 80000c84 <release>
  return 0;
    80002c9c:	4781                	li	a5,0
}
    80002c9e:	853e                	mv	a0,a5
    80002ca0:	70e2                	ld	ra,56(sp)
    80002ca2:	7442                	ld	s0,48(sp)
    80002ca4:	74a2                	ld	s1,40(sp)
    80002ca6:	7902                	ld	s2,32(sp)
    80002ca8:	69e2                	ld	s3,24(sp)
    80002caa:	6121                	addi	sp,sp,64
    80002cac:	8082                	ret
      release(&tickslock);
    80002cae:	00014517          	auipc	a0,0x14
    80002cb2:	42250513          	addi	a0,a0,1058 # 800170d0 <tickslock>
    80002cb6:	ffffe097          	auipc	ra,0xffffe
    80002cba:	fce080e7          	jalr	-50(ra) # 80000c84 <release>
      return -1;
    80002cbe:	57fd                	li	a5,-1
    80002cc0:	bff9                	j	80002c9e <sys_sleep+0x88>

0000000080002cc2 <sys_kill>:

uint64
sys_kill(void)
{
    80002cc2:	1101                	addi	sp,sp,-32
    80002cc4:	ec06                	sd	ra,24(sp)
    80002cc6:	e822                	sd	s0,16(sp)
    80002cc8:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002cca:	fec40593          	addi	a1,s0,-20
    80002cce:	4501                	li	a0,0
    80002cd0:	00000097          	auipc	ra,0x0
    80002cd4:	d84080e7          	jalr	-636(ra) # 80002a54 <argint>
    80002cd8:	87aa                	mv	a5,a0
    return -1;
    80002cda:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002cdc:	0007c863          	bltz	a5,80002cec <sys_kill+0x2a>
  return kill(pid);
    80002ce0:	fec42503          	lw	a0,-20(s0)
    80002ce4:	fffff097          	auipc	ra,0xfffff
    80002ce8:	6b0080e7          	jalr	1712(ra) # 80002394 <kill>
}
    80002cec:	60e2                	ld	ra,24(sp)
    80002cee:	6442                	ld	s0,16(sp)
    80002cf0:	6105                	addi	sp,sp,32
    80002cf2:	8082                	ret

0000000080002cf4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002cf4:	1101                	addi	sp,sp,-32
    80002cf6:	ec06                	sd	ra,24(sp)
    80002cf8:	e822                	sd	s0,16(sp)
    80002cfa:	e426                	sd	s1,8(sp)
    80002cfc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002cfe:	00014517          	auipc	a0,0x14
    80002d02:	3d250513          	addi	a0,a0,978 # 800170d0 <tickslock>
    80002d06:	ffffe097          	auipc	ra,0xffffe
    80002d0a:	eca080e7          	jalr	-310(ra) # 80000bd0 <acquire>
  xticks = ticks;
    80002d0e:	00006497          	auipc	s1,0x6
    80002d12:	3224a483          	lw	s1,802(s1) # 80009030 <ticks>
  release(&tickslock);
    80002d16:	00014517          	auipc	a0,0x14
    80002d1a:	3ba50513          	addi	a0,a0,954 # 800170d0 <tickslock>
    80002d1e:	ffffe097          	auipc	ra,0xffffe
    80002d22:	f66080e7          	jalr	-154(ra) # 80000c84 <release>
  return xticks;
}
    80002d26:	02049513          	slli	a0,s1,0x20
    80002d2a:	9101                	srli	a0,a0,0x20
    80002d2c:	60e2                	ld	ra,24(sp)
    80002d2e:	6442                	ld	s0,16(sp)
    80002d30:	64a2                	ld	s1,8(sp)
    80002d32:	6105                	addi	sp,sp,32
    80002d34:	8082                	ret

0000000080002d36 <sys_btput>:


uint64
sys_btput(void)
{   // printf(" btput in syspoc.c \n");
    80002d36:	7135                	addi	sp,sp,-160
    80002d38:	ed06                	sd	ra,152(sp)
    80002d3a:	e922                	sd	s0,144(sp)
    80002d3c:	1100                	addi	s0,sp,160
    
    
    int tag;
    char msg[MAXTWEETLENGTH];
    
    if(argint(0,&tag)<0){
    80002d3e:	fec40593          	addi	a1,s0,-20
    80002d42:	4501                	li	a0,0
    80002d44:	00000097          	auipc	ra,0x0
    80002d48:	d10080e7          	jalr	-752(ra) # 80002a54 <argint>
        return -1;
    80002d4c:	57fd                	li	a5,-1
    if(argint(0,&tag)<0){
    80002d4e:	02054763          	bltz	a0,80002d7c <sys_btput+0x46>
    }
    if(argstr(1,msg,140)<0){
    80002d52:	08c00613          	li	a2,140
    80002d56:	f6040593          	addi	a1,s0,-160
    80002d5a:	4505                	li	a0,1
    80002d5c:	00000097          	auipc	ra,0x0
    80002d60:	d3c080e7          	jalr	-708(ra) # 80002a98 <argstr>
        return -1;
    80002d64:	57fd                	li	a5,-1
    if(argstr(1,msg,140)<0){
    80002d66:	00054b63          	bltz	a0,80002d7c <sys_btput+0x46>
    }
    
    
    return btput(tag,msg);
    80002d6a:	f6040593          	addi	a1,s0,-160
    80002d6e:	fec42503          	lw	a0,-20(s0)
    80002d72:	00003097          	auipc	ra,0x3
    80002d76:	5f0080e7          	jalr	1520(ra) # 80006362 <btput>
    80002d7a:	87aa                	mv	a5,a0
}
    80002d7c:	853e                	mv	a0,a5
    80002d7e:	60ea                	ld	ra,152(sp)
    80002d80:	644a                	ld	s0,144(sp)
    80002d82:	610d                	addi	sp,sp,160
    80002d84:	8082                	ret

0000000080002d86 <sys_tput>:

uint64
sys_tput(void)
{
    80002d86:	7135                	addi	sp,sp,-160
    80002d88:	ed06                	sd	ra,152(sp)
    80002d8a:	e922                	sd	s0,144(sp)
    80002d8c:	1100                	addi	s0,sp,160
   // printf("tput in syspoc.c \n");
    int tag;
    char msg[MAXTWEETLENGTH];
    
    if(argint(0,&tag)<0){
    80002d8e:	fec40593          	addi	a1,s0,-20
    80002d92:	4501                	li	a0,0
    80002d94:	00000097          	auipc	ra,0x0
    80002d98:	cc0080e7          	jalr	-832(ra) # 80002a54 <argint>
        return -1;
    80002d9c:	57fd                	li	a5,-1
    if(argint(0,&tag)<0){
    80002d9e:	02054763          	bltz	a0,80002dcc <sys_tput+0x46>
    }
    if(argstr(1,msg,140)<0){
    80002da2:	08c00613          	li	a2,140
    80002da6:	f6040593          	addi	a1,s0,-160
    80002daa:	4505                	li	a0,1
    80002dac:	00000097          	auipc	ra,0x0
    80002db0:	cec080e7          	jalr	-788(ra) # 80002a98 <argstr>
        return -1;
    80002db4:	57fd                	li	a5,-1
    if(argstr(1,msg,140)<0){
    80002db6:	00054b63          	bltz	a0,80002dcc <sys_tput+0x46>
    }
    
    
    return tput(tag,msg);
    80002dba:	f6040593          	addi	a1,s0,-160
    80002dbe:	fec42503          	lw	a0,-20(s0)
    80002dc2:	00003097          	auipc	ra,0x3
    80002dc6:	6de080e7          	jalr	1758(ra) # 800064a0 <tput>
    80002dca:	87aa                	mv	a5,a0
}
    80002dcc:	853e                	mv	a0,a5
    80002dce:	60ea                	ld	ra,152(sp)
    80002dd0:	644a                	ld	s0,144(sp)
    80002dd2:	610d                	addi	sp,sp,160
    80002dd4:	8082                	ret

0000000080002dd6 <sys_btget>:

uint64
sys_btget(void)
{
    80002dd6:	1101                	addi	sp,sp,-32
    80002dd8:	ec06                	sd	ra,24(sp)
    80002dda:	e822                	sd	s0,16(sp)
    80002ddc:	1000                	addi	s0,sp,32
  //  printf("btget in syspoc.c \n");
    
    int tag;
    uint64 msgbufaddr;
    
    if(argint(0,&tag)<0){
    80002dde:	fec40593          	addi	a1,s0,-20
    80002de2:	4501                	li	a0,0
    80002de4:	00000097          	auipc	ra,0x0
    80002de8:	c70080e7          	jalr	-912(ra) # 80002a54 <argint>
        return -1;
    80002dec:	57fd                	li	a5,-1
    if(argint(0,&tag)<0){
    80002dee:	02054563          	bltz	a0,80002e18 <sys_btget+0x42>
    }
    if(argaddr(1,&msgbufaddr)<0){
    80002df2:	fe040593          	addi	a1,s0,-32
    80002df6:	4505                	li	a0,1
    80002df8:	00000097          	auipc	ra,0x0
    80002dfc:	c7e080e7          	jalr	-898(ra) # 80002a76 <argaddr>
        return -1;
    80002e00:	57fd                	li	a5,-1
    if(argaddr(1,&msgbufaddr)<0){
    80002e02:	00054b63          	bltz	a0,80002e18 <sys_btget+0x42>
    }
    
    
    return btget(tag,msgbufaddr);
    80002e06:	fe043583          	ld	a1,-32(s0)
    80002e0a:	fec42503          	lw	a0,-20(s0)
    80002e0e:	00003097          	auipc	ra,0x3
    80002e12:	798080e7          	jalr	1944(ra) # 800065a6 <btget>
    80002e16:	87aa                	mv	a5,a0
}
    80002e18:	853e                	mv	a0,a5
    80002e1a:	60e2                	ld	ra,24(sp)
    80002e1c:	6442                	ld	s0,16(sp)
    80002e1e:	6105                	addi	sp,sp,32
    80002e20:	8082                	ret

0000000080002e22 <sys_tget>:

uint64
sys_tget(void)
{
    80002e22:	1101                	addi	sp,sp,-32
    80002e24:	ec06                	sd	ra,24(sp)
    80002e26:	e822                	sd	s0,16(sp)
    80002e28:	1000                	addi	s0,sp,32
  //  printf("tget in syspoc.c \n");
        int tag;
    uint64 msgbufaddr;
    
    if(argint(0,&tag)<0){
    80002e2a:	fec40593          	addi	a1,s0,-20
    80002e2e:	4501                	li	a0,0
    80002e30:	00000097          	auipc	ra,0x0
    80002e34:	c24080e7          	jalr	-988(ra) # 80002a54 <argint>
        return -1;
    80002e38:	57fd                	li	a5,-1
    if(argint(0,&tag)<0){
    80002e3a:	02054563          	bltz	a0,80002e64 <sys_tget+0x42>
    }
    if(argaddr(1,&msgbufaddr)<0){
    80002e3e:	fe040593          	addi	a1,s0,-32
    80002e42:	4505                	li	a0,1
    80002e44:	00000097          	auipc	ra,0x0
    80002e48:	c32080e7          	jalr	-974(ra) # 80002a76 <argaddr>
        return -1;
    80002e4c:	57fd                	li	a5,-1
    if(argaddr(1,&msgbufaddr)<0){
    80002e4e:	00054b63          	bltz	a0,80002e64 <sys_tget+0x42>
    }
    
    
    return tget(tag,msgbufaddr);
    80002e52:	fe043583          	ld	a1,-32(s0)
    80002e56:	fec42503          	lw	a0,-20(s0)
    80002e5a:	00004097          	auipc	ra,0x4
    80002e5e:	86e080e7          	jalr	-1938(ra) # 800066c8 <tget>
    80002e62:	87aa                	mv	a5,a0
    80002e64:	853e                	mv	a0,a5
    80002e66:	60e2                	ld	ra,24(sp)
    80002e68:	6442                	ld	s0,16(sp)
    80002e6a:	6105                	addi	sp,sp,32
    80002e6c:	8082                	ret

0000000080002e6e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e6e:	7179                	addi	sp,sp,-48
    80002e70:	f406                	sd	ra,40(sp)
    80002e72:	f022                	sd	s0,32(sp)
    80002e74:	ec26                	sd	s1,24(sp)
    80002e76:	e84a                	sd	s2,16(sp)
    80002e78:	e44e                	sd	s3,8(sp)
    80002e7a:	e052                	sd	s4,0(sp)
    80002e7c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e7e:	00005597          	auipc	a1,0x5
    80002e82:	69a58593          	addi	a1,a1,1690 # 80008518 <syscalls+0xd0>
    80002e86:	00014517          	auipc	a0,0x14
    80002e8a:	26250513          	addi	a0,a0,610 # 800170e8 <bcache>
    80002e8e:	ffffe097          	auipc	ra,0xffffe
    80002e92:	cb2080e7          	jalr	-846(ra) # 80000b40 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e96:	0001c797          	auipc	a5,0x1c
    80002e9a:	25278793          	addi	a5,a5,594 # 8001f0e8 <bcache+0x8000>
    80002e9e:	0001c717          	auipc	a4,0x1c
    80002ea2:	4b270713          	addi	a4,a4,1202 # 8001f350 <bcache+0x8268>
    80002ea6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002eaa:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002eae:	00014497          	auipc	s1,0x14
    80002eb2:	25248493          	addi	s1,s1,594 # 80017100 <bcache+0x18>
    b->next = bcache.head.next;
    80002eb6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002eb8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002eba:	00005a17          	auipc	s4,0x5
    80002ebe:	666a0a13          	addi	s4,s4,1638 # 80008520 <syscalls+0xd8>
    b->next = bcache.head.next;
    80002ec2:	2b893783          	ld	a5,696(s2)
    80002ec6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ec8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ecc:	85d2                	mv	a1,s4
    80002ece:	01048513          	addi	a0,s1,16
    80002ed2:	00001097          	auipc	ra,0x1
    80002ed6:	4c2080e7          	jalr	1218(ra) # 80004394 <initsleeplock>
    bcache.head.next->prev = b;
    80002eda:	2b893783          	ld	a5,696(s2)
    80002ede:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002ee0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ee4:	45848493          	addi	s1,s1,1112
    80002ee8:	fd349de3          	bne	s1,s3,80002ec2 <binit+0x54>
  }
}
    80002eec:	70a2                	ld	ra,40(sp)
    80002eee:	7402                	ld	s0,32(sp)
    80002ef0:	64e2                	ld	s1,24(sp)
    80002ef2:	6942                	ld	s2,16(sp)
    80002ef4:	69a2                	ld	s3,8(sp)
    80002ef6:	6a02                	ld	s4,0(sp)
    80002ef8:	6145                	addi	sp,sp,48
    80002efa:	8082                	ret

0000000080002efc <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002efc:	7179                	addi	sp,sp,-48
    80002efe:	f406                	sd	ra,40(sp)
    80002f00:	f022                	sd	s0,32(sp)
    80002f02:	ec26                	sd	s1,24(sp)
    80002f04:	e84a                	sd	s2,16(sp)
    80002f06:	e44e                	sd	s3,8(sp)
    80002f08:	1800                	addi	s0,sp,48
    80002f0a:	892a                	mv	s2,a0
    80002f0c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f0e:	00014517          	auipc	a0,0x14
    80002f12:	1da50513          	addi	a0,a0,474 # 800170e8 <bcache>
    80002f16:	ffffe097          	auipc	ra,0xffffe
    80002f1a:	cba080e7          	jalr	-838(ra) # 80000bd0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f1e:	0001c497          	auipc	s1,0x1c
    80002f22:	4824b483          	ld	s1,1154(s1) # 8001f3a0 <bcache+0x82b8>
    80002f26:	0001c797          	auipc	a5,0x1c
    80002f2a:	42a78793          	addi	a5,a5,1066 # 8001f350 <bcache+0x8268>
    80002f2e:	02f48f63          	beq	s1,a5,80002f6c <bread+0x70>
    80002f32:	873e                	mv	a4,a5
    80002f34:	a021                	j	80002f3c <bread+0x40>
    80002f36:	68a4                	ld	s1,80(s1)
    80002f38:	02e48a63          	beq	s1,a4,80002f6c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f3c:	449c                	lw	a5,8(s1)
    80002f3e:	ff279ce3          	bne	a5,s2,80002f36 <bread+0x3a>
    80002f42:	44dc                	lw	a5,12(s1)
    80002f44:	ff3799e3          	bne	a5,s3,80002f36 <bread+0x3a>
      b->refcnt++;
    80002f48:	40bc                	lw	a5,64(s1)
    80002f4a:	2785                	addiw	a5,a5,1
    80002f4c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f4e:	00014517          	auipc	a0,0x14
    80002f52:	19a50513          	addi	a0,a0,410 # 800170e8 <bcache>
    80002f56:	ffffe097          	auipc	ra,0xffffe
    80002f5a:	d2e080e7          	jalr	-722(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80002f5e:	01048513          	addi	a0,s1,16
    80002f62:	00001097          	auipc	ra,0x1
    80002f66:	46c080e7          	jalr	1132(ra) # 800043ce <acquiresleep>
      return b;
    80002f6a:	a8b9                	j	80002fc8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f6c:	0001c497          	auipc	s1,0x1c
    80002f70:	42c4b483          	ld	s1,1068(s1) # 8001f398 <bcache+0x82b0>
    80002f74:	0001c797          	auipc	a5,0x1c
    80002f78:	3dc78793          	addi	a5,a5,988 # 8001f350 <bcache+0x8268>
    80002f7c:	00f48863          	beq	s1,a5,80002f8c <bread+0x90>
    80002f80:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f82:	40bc                	lw	a5,64(s1)
    80002f84:	cf81                	beqz	a5,80002f9c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f86:	64a4                	ld	s1,72(s1)
    80002f88:	fee49de3          	bne	s1,a4,80002f82 <bread+0x86>
  panic("bget: no buffers");
    80002f8c:	00005517          	auipc	a0,0x5
    80002f90:	59c50513          	addi	a0,a0,1436 # 80008528 <syscalls+0xe0>
    80002f94:	ffffd097          	auipc	ra,0xffffd
    80002f98:	5a6080e7          	jalr	1446(ra) # 8000053a <panic>
      b->dev = dev;
    80002f9c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002fa0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002fa4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fa8:	4785                	li	a5,1
    80002faa:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fac:	00014517          	auipc	a0,0x14
    80002fb0:	13c50513          	addi	a0,a0,316 # 800170e8 <bcache>
    80002fb4:	ffffe097          	auipc	ra,0xffffe
    80002fb8:	cd0080e7          	jalr	-816(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80002fbc:	01048513          	addi	a0,s1,16
    80002fc0:	00001097          	auipc	ra,0x1
    80002fc4:	40e080e7          	jalr	1038(ra) # 800043ce <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002fc8:	409c                	lw	a5,0(s1)
    80002fca:	cb89                	beqz	a5,80002fdc <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002fcc:	8526                	mv	a0,s1
    80002fce:	70a2                	ld	ra,40(sp)
    80002fd0:	7402                	ld	s0,32(sp)
    80002fd2:	64e2                	ld	s1,24(sp)
    80002fd4:	6942                	ld	s2,16(sp)
    80002fd6:	69a2                	ld	s3,8(sp)
    80002fd8:	6145                	addi	sp,sp,48
    80002fda:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fdc:	4581                	li	a1,0
    80002fde:	8526                	mv	a0,s1
    80002fe0:	00003097          	auipc	ra,0x3
    80002fe4:	f22080e7          	jalr	-222(ra) # 80005f02 <virtio_disk_rw>
    b->valid = 1;
    80002fe8:	4785                	li	a5,1
    80002fea:	c09c                	sw	a5,0(s1)
  return b;
    80002fec:	b7c5                	j	80002fcc <bread+0xd0>

0000000080002fee <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fee:	1101                	addi	sp,sp,-32
    80002ff0:	ec06                	sd	ra,24(sp)
    80002ff2:	e822                	sd	s0,16(sp)
    80002ff4:	e426                	sd	s1,8(sp)
    80002ff6:	1000                	addi	s0,sp,32
    80002ff8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ffa:	0541                	addi	a0,a0,16
    80002ffc:	00001097          	auipc	ra,0x1
    80003000:	46c080e7          	jalr	1132(ra) # 80004468 <holdingsleep>
    80003004:	cd01                	beqz	a0,8000301c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003006:	4585                	li	a1,1
    80003008:	8526                	mv	a0,s1
    8000300a:	00003097          	auipc	ra,0x3
    8000300e:	ef8080e7          	jalr	-264(ra) # 80005f02 <virtio_disk_rw>
}
    80003012:	60e2                	ld	ra,24(sp)
    80003014:	6442                	ld	s0,16(sp)
    80003016:	64a2                	ld	s1,8(sp)
    80003018:	6105                	addi	sp,sp,32
    8000301a:	8082                	ret
    panic("bwrite");
    8000301c:	00005517          	auipc	a0,0x5
    80003020:	52450513          	addi	a0,a0,1316 # 80008540 <syscalls+0xf8>
    80003024:	ffffd097          	auipc	ra,0xffffd
    80003028:	516080e7          	jalr	1302(ra) # 8000053a <panic>

000000008000302c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000302c:	1101                	addi	sp,sp,-32
    8000302e:	ec06                	sd	ra,24(sp)
    80003030:	e822                	sd	s0,16(sp)
    80003032:	e426                	sd	s1,8(sp)
    80003034:	e04a                	sd	s2,0(sp)
    80003036:	1000                	addi	s0,sp,32
    80003038:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000303a:	01050913          	addi	s2,a0,16
    8000303e:	854a                	mv	a0,s2
    80003040:	00001097          	auipc	ra,0x1
    80003044:	428080e7          	jalr	1064(ra) # 80004468 <holdingsleep>
    80003048:	c92d                	beqz	a0,800030ba <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000304a:	854a                	mv	a0,s2
    8000304c:	00001097          	auipc	ra,0x1
    80003050:	3d8080e7          	jalr	984(ra) # 80004424 <releasesleep>

  acquire(&bcache.lock);
    80003054:	00014517          	auipc	a0,0x14
    80003058:	09450513          	addi	a0,a0,148 # 800170e8 <bcache>
    8000305c:	ffffe097          	auipc	ra,0xffffe
    80003060:	b74080e7          	jalr	-1164(ra) # 80000bd0 <acquire>
  b->refcnt--;
    80003064:	40bc                	lw	a5,64(s1)
    80003066:	37fd                	addiw	a5,a5,-1
    80003068:	0007871b          	sext.w	a4,a5
    8000306c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000306e:	eb05                	bnez	a4,8000309e <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003070:	68bc                	ld	a5,80(s1)
    80003072:	64b8                	ld	a4,72(s1)
    80003074:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003076:	64bc                	ld	a5,72(s1)
    80003078:	68b8                	ld	a4,80(s1)
    8000307a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000307c:	0001c797          	auipc	a5,0x1c
    80003080:	06c78793          	addi	a5,a5,108 # 8001f0e8 <bcache+0x8000>
    80003084:	2b87b703          	ld	a4,696(a5)
    80003088:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000308a:	0001c717          	auipc	a4,0x1c
    8000308e:	2c670713          	addi	a4,a4,710 # 8001f350 <bcache+0x8268>
    80003092:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003094:	2b87b703          	ld	a4,696(a5)
    80003098:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000309a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000309e:	00014517          	auipc	a0,0x14
    800030a2:	04a50513          	addi	a0,a0,74 # 800170e8 <bcache>
    800030a6:	ffffe097          	auipc	ra,0xffffe
    800030aa:	bde080e7          	jalr	-1058(ra) # 80000c84 <release>
}
    800030ae:	60e2                	ld	ra,24(sp)
    800030b0:	6442                	ld	s0,16(sp)
    800030b2:	64a2                	ld	s1,8(sp)
    800030b4:	6902                	ld	s2,0(sp)
    800030b6:	6105                	addi	sp,sp,32
    800030b8:	8082                	ret
    panic("brelse");
    800030ba:	00005517          	auipc	a0,0x5
    800030be:	48e50513          	addi	a0,a0,1166 # 80008548 <syscalls+0x100>
    800030c2:	ffffd097          	auipc	ra,0xffffd
    800030c6:	478080e7          	jalr	1144(ra) # 8000053a <panic>

00000000800030ca <bpin>:

void
bpin(struct buf *b) {
    800030ca:	1101                	addi	sp,sp,-32
    800030cc:	ec06                	sd	ra,24(sp)
    800030ce:	e822                	sd	s0,16(sp)
    800030d0:	e426                	sd	s1,8(sp)
    800030d2:	1000                	addi	s0,sp,32
    800030d4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030d6:	00014517          	auipc	a0,0x14
    800030da:	01250513          	addi	a0,a0,18 # 800170e8 <bcache>
    800030de:	ffffe097          	auipc	ra,0xffffe
    800030e2:	af2080e7          	jalr	-1294(ra) # 80000bd0 <acquire>
  b->refcnt++;
    800030e6:	40bc                	lw	a5,64(s1)
    800030e8:	2785                	addiw	a5,a5,1
    800030ea:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030ec:	00014517          	auipc	a0,0x14
    800030f0:	ffc50513          	addi	a0,a0,-4 # 800170e8 <bcache>
    800030f4:	ffffe097          	auipc	ra,0xffffe
    800030f8:	b90080e7          	jalr	-1136(ra) # 80000c84 <release>
}
    800030fc:	60e2                	ld	ra,24(sp)
    800030fe:	6442                	ld	s0,16(sp)
    80003100:	64a2                	ld	s1,8(sp)
    80003102:	6105                	addi	sp,sp,32
    80003104:	8082                	ret

0000000080003106 <bunpin>:

void
bunpin(struct buf *b) {
    80003106:	1101                	addi	sp,sp,-32
    80003108:	ec06                	sd	ra,24(sp)
    8000310a:	e822                	sd	s0,16(sp)
    8000310c:	e426                	sd	s1,8(sp)
    8000310e:	1000                	addi	s0,sp,32
    80003110:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003112:	00014517          	auipc	a0,0x14
    80003116:	fd650513          	addi	a0,a0,-42 # 800170e8 <bcache>
    8000311a:	ffffe097          	auipc	ra,0xffffe
    8000311e:	ab6080e7          	jalr	-1354(ra) # 80000bd0 <acquire>
  b->refcnt--;
    80003122:	40bc                	lw	a5,64(s1)
    80003124:	37fd                	addiw	a5,a5,-1
    80003126:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003128:	00014517          	auipc	a0,0x14
    8000312c:	fc050513          	addi	a0,a0,-64 # 800170e8 <bcache>
    80003130:	ffffe097          	auipc	ra,0xffffe
    80003134:	b54080e7          	jalr	-1196(ra) # 80000c84 <release>
}
    80003138:	60e2                	ld	ra,24(sp)
    8000313a:	6442                	ld	s0,16(sp)
    8000313c:	64a2                	ld	s1,8(sp)
    8000313e:	6105                	addi	sp,sp,32
    80003140:	8082                	ret

0000000080003142 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003142:	1101                	addi	sp,sp,-32
    80003144:	ec06                	sd	ra,24(sp)
    80003146:	e822                	sd	s0,16(sp)
    80003148:	e426                	sd	s1,8(sp)
    8000314a:	e04a                	sd	s2,0(sp)
    8000314c:	1000                	addi	s0,sp,32
    8000314e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003150:	00d5d59b          	srliw	a1,a1,0xd
    80003154:	0001c797          	auipc	a5,0x1c
    80003158:	6707a783          	lw	a5,1648(a5) # 8001f7c4 <sb+0x1c>
    8000315c:	9dbd                	addw	a1,a1,a5
    8000315e:	00000097          	auipc	ra,0x0
    80003162:	d9e080e7          	jalr	-610(ra) # 80002efc <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003166:	0074f713          	andi	a4,s1,7
    8000316a:	4785                	li	a5,1
    8000316c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003170:	14ce                	slli	s1,s1,0x33
    80003172:	90d9                	srli	s1,s1,0x36
    80003174:	00950733          	add	a4,a0,s1
    80003178:	05874703          	lbu	a4,88(a4)
    8000317c:	00e7f6b3          	and	a3,a5,a4
    80003180:	c69d                	beqz	a3,800031ae <bfree+0x6c>
    80003182:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003184:	94aa                	add	s1,s1,a0
    80003186:	fff7c793          	not	a5,a5
    8000318a:	8f7d                	and	a4,a4,a5
    8000318c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003190:	00001097          	auipc	ra,0x1
    80003194:	120080e7          	jalr	288(ra) # 800042b0 <log_write>
  brelse(bp);
    80003198:	854a                	mv	a0,s2
    8000319a:	00000097          	auipc	ra,0x0
    8000319e:	e92080e7          	jalr	-366(ra) # 8000302c <brelse>
}
    800031a2:	60e2                	ld	ra,24(sp)
    800031a4:	6442                	ld	s0,16(sp)
    800031a6:	64a2                	ld	s1,8(sp)
    800031a8:	6902                	ld	s2,0(sp)
    800031aa:	6105                	addi	sp,sp,32
    800031ac:	8082                	ret
    panic("freeing free block");
    800031ae:	00005517          	auipc	a0,0x5
    800031b2:	3a250513          	addi	a0,a0,930 # 80008550 <syscalls+0x108>
    800031b6:	ffffd097          	auipc	ra,0xffffd
    800031ba:	384080e7          	jalr	900(ra) # 8000053a <panic>

00000000800031be <balloc>:
{
    800031be:	711d                	addi	sp,sp,-96
    800031c0:	ec86                	sd	ra,88(sp)
    800031c2:	e8a2                	sd	s0,80(sp)
    800031c4:	e4a6                	sd	s1,72(sp)
    800031c6:	e0ca                	sd	s2,64(sp)
    800031c8:	fc4e                	sd	s3,56(sp)
    800031ca:	f852                	sd	s4,48(sp)
    800031cc:	f456                	sd	s5,40(sp)
    800031ce:	f05a                	sd	s6,32(sp)
    800031d0:	ec5e                	sd	s7,24(sp)
    800031d2:	e862                	sd	s8,16(sp)
    800031d4:	e466                	sd	s9,8(sp)
    800031d6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031d8:	0001c797          	auipc	a5,0x1c
    800031dc:	5d47a783          	lw	a5,1492(a5) # 8001f7ac <sb+0x4>
    800031e0:	cbc1                	beqz	a5,80003270 <balloc+0xb2>
    800031e2:	8baa                	mv	s7,a0
    800031e4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031e6:	0001cb17          	auipc	s6,0x1c
    800031ea:	5c2b0b13          	addi	s6,s6,1474 # 8001f7a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031ee:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031f0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031f2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031f4:	6c89                	lui	s9,0x2
    800031f6:	a831                	j	80003212 <balloc+0x54>
    brelse(bp);
    800031f8:	854a                	mv	a0,s2
    800031fa:	00000097          	auipc	ra,0x0
    800031fe:	e32080e7          	jalr	-462(ra) # 8000302c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003202:	015c87bb          	addw	a5,s9,s5
    80003206:	00078a9b          	sext.w	s5,a5
    8000320a:	004b2703          	lw	a4,4(s6)
    8000320e:	06eaf163          	bgeu	s5,a4,80003270 <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    80003212:	41fad79b          	sraiw	a5,s5,0x1f
    80003216:	0137d79b          	srliw	a5,a5,0x13
    8000321a:	015787bb          	addw	a5,a5,s5
    8000321e:	40d7d79b          	sraiw	a5,a5,0xd
    80003222:	01cb2583          	lw	a1,28(s6)
    80003226:	9dbd                	addw	a1,a1,a5
    80003228:	855e                	mv	a0,s7
    8000322a:	00000097          	auipc	ra,0x0
    8000322e:	cd2080e7          	jalr	-814(ra) # 80002efc <bread>
    80003232:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003234:	004b2503          	lw	a0,4(s6)
    80003238:	000a849b          	sext.w	s1,s5
    8000323c:	8762                	mv	a4,s8
    8000323e:	faa4fde3          	bgeu	s1,a0,800031f8 <balloc+0x3a>
      m = 1 << (bi % 8);
    80003242:	00777693          	andi	a3,a4,7
    80003246:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000324a:	41f7579b          	sraiw	a5,a4,0x1f
    8000324e:	01d7d79b          	srliw	a5,a5,0x1d
    80003252:	9fb9                	addw	a5,a5,a4
    80003254:	4037d79b          	sraiw	a5,a5,0x3
    80003258:	00f90633          	add	a2,s2,a5
    8000325c:	05864603          	lbu	a2,88(a2)
    80003260:	00c6f5b3          	and	a1,a3,a2
    80003264:	cd91                	beqz	a1,80003280 <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003266:	2705                	addiw	a4,a4,1
    80003268:	2485                	addiw	s1,s1,1
    8000326a:	fd471ae3          	bne	a4,s4,8000323e <balloc+0x80>
    8000326e:	b769                	j	800031f8 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003270:	00005517          	auipc	a0,0x5
    80003274:	2f850513          	addi	a0,a0,760 # 80008568 <syscalls+0x120>
    80003278:	ffffd097          	auipc	ra,0xffffd
    8000327c:	2c2080e7          	jalr	706(ra) # 8000053a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003280:	97ca                	add	a5,a5,s2
    80003282:	8e55                	or	a2,a2,a3
    80003284:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003288:	854a                	mv	a0,s2
    8000328a:	00001097          	auipc	ra,0x1
    8000328e:	026080e7          	jalr	38(ra) # 800042b0 <log_write>
        brelse(bp);
    80003292:	854a                	mv	a0,s2
    80003294:	00000097          	auipc	ra,0x0
    80003298:	d98080e7          	jalr	-616(ra) # 8000302c <brelse>
  bp = bread(dev, bno);
    8000329c:	85a6                	mv	a1,s1
    8000329e:	855e                	mv	a0,s7
    800032a0:	00000097          	auipc	ra,0x0
    800032a4:	c5c080e7          	jalr	-932(ra) # 80002efc <bread>
    800032a8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032aa:	40000613          	li	a2,1024
    800032ae:	4581                	li	a1,0
    800032b0:	05850513          	addi	a0,a0,88
    800032b4:	ffffe097          	auipc	ra,0xffffe
    800032b8:	a18080e7          	jalr	-1512(ra) # 80000ccc <memset>
  log_write(bp);
    800032bc:	854a                	mv	a0,s2
    800032be:	00001097          	auipc	ra,0x1
    800032c2:	ff2080e7          	jalr	-14(ra) # 800042b0 <log_write>
  brelse(bp);
    800032c6:	854a                	mv	a0,s2
    800032c8:	00000097          	auipc	ra,0x0
    800032cc:	d64080e7          	jalr	-668(ra) # 8000302c <brelse>
}
    800032d0:	8526                	mv	a0,s1
    800032d2:	60e6                	ld	ra,88(sp)
    800032d4:	6446                	ld	s0,80(sp)
    800032d6:	64a6                	ld	s1,72(sp)
    800032d8:	6906                	ld	s2,64(sp)
    800032da:	79e2                	ld	s3,56(sp)
    800032dc:	7a42                	ld	s4,48(sp)
    800032de:	7aa2                	ld	s5,40(sp)
    800032e0:	7b02                	ld	s6,32(sp)
    800032e2:	6be2                	ld	s7,24(sp)
    800032e4:	6c42                	ld	s8,16(sp)
    800032e6:	6ca2                	ld	s9,8(sp)
    800032e8:	6125                	addi	sp,sp,96
    800032ea:	8082                	ret

00000000800032ec <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800032ec:	7179                	addi	sp,sp,-48
    800032ee:	f406                	sd	ra,40(sp)
    800032f0:	f022                	sd	s0,32(sp)
    800032f2:	ec26                	sd	s1,24(sp)
    800032f4:	e84a                	sd	s2,16(sp)
    800032f6:	e44e                	sd	s3,8(sp)
    800032f8:	e052                	sd	s4,0(sp)
    800032fa:	1800                	addi	s0,sp,48
    800032fc:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032fe:	47ad                	li	a5,11
    80003300:	04b7fe63          	bgeu	a5,a1,8000335c <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003304:	ff45849b          	addiw	s1,a1,-12
    80003308:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000330c:	0ff00793          	li	a5,255
    80003310:	0ae7e463          	bltu	a5,a4,800033b8 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003314:	08052583          	lw	a1,128(a0)
    80003318:	c5b5                	beqz	a1,80003384 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000331a:	00092503          	lw	a0,0(s2)
    8000331e:	00000097          	auipc	ra,0x0
    80003322:	bde080e7          	jalr	-1058(ra) # 80002efc <bread>
    80003326:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003328:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000332c:	02049713          	slli	a4,s1,0x20
    80003330:	01e75593          	srli	a1,a4,0x1e
    80003334:	00b784b3          	add	s1,a5,a1
    80003338:	0004a983          	lw	s3,0(s1)
    8000333c:	04098e63          	beqz	s3,80003398 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003340:	8552                	mv	a0,s4
    80003342:	00000097          	auipc	ra,0x0
    80003346:	cea080e7          	jalr	-790(ra) # 8000302c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000334a:	854e                	mv	a0,s3
    8000334c:	70a2                	ld	ra,40(sp)
    8000334e:	7402                	ld	s0,32(sp)
    80003350:	64e2                	ld	s1,24(sp)
    80003352:	6942                	ld	s2,16(sp)
    80003354:	69a2                	ld	s3,8(sp)
    80003356:	6a02                	ld	s4,0(sp)
    80003358:	6145                	addi	sp,sp,48
    8000335a:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000335c:	02059793          	slli	a5,a1,0x20
    80003360:	01e7d593          	srli	a1,a5,0x1e
    80003364:	00b504b3          	add	s1,a0,a1
    80003368:	0504a983          	lw	s3,80(s1)
    8000336c:	fc099fe3          	bnez	s3,8000334a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003370:	4108                	lw	a0,0(a0)
    80003372:	00000097          	auipc	ra,0x0
    80003376:	e4c080e7          	jalr	-436(ra) # 800031be <balloc>
    8000337a:	0005099b          	sext.w	s3,a0
    8000337e:	0534a823          	sw	s3,80(s1)
    80003382:	b7e1                	j	8000334a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003384:	4108                	lw	a0,0(a0)
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	e38080e7          	jalr	-456(ra) # 800031be <balloc>
    8000338e:	0005059b          	sext.w	a1,a0
    80003392:	08b92023          	sw	a1,128(s2)
    80003396:	b751                	j	8000331a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003398:	00092503          	lw	a0,0(s2)
    8000339c:	00000097          	auipc	ra,0x0
    800033a0:	e22080e7          	jalr	-478(ra) # 800031be <balloc>
    800033a4:	0005099b          	sext.w	s3,a0
    800033a8:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800033ac:	8552                	mv	a0,s4
    800033ae:	00001097          	auipc	ra,0x1
    800033b2:	f02080e7          	jalr	-254(ra) # 800042b0 <log_write>
    800033b6:	b769                	j	80003340 <bmap+0x54>
  panic("bmap: out of range");
    800033b8:	00005517          	auipc	a0,0x5
    800033bc:	1c850513          	addi	a0,a0,456 # 80008580 <syscalls+0x138>
    800033c0:	ffffd097          	auipc	ra,0xffffd
    800033c4:	17a080e7          	jalr	378(ra) # 8000053a <panic>

00000000800033c8 <iget>:
{
    800033c8:	7179                	addi	sp,sp,-48
    800033ca:	f406                	sd	ra,40(sp)
    800033cc:	f022                	sd	s0,32(sp)
    800033ce:	ec26                	sd	s1,24(sp)
    800033d0:	e84a                	sd	s2,16(sp)
    800033d2:	e44e                	sd	s3,8(sp)
    800033d4:	e052                	sd	s4,0(sp)
    800033d6:	1800                	addi	s0,sp,48
    800033d8:	89aa                	mv	s3,a0
    800033da:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033dc:	0001c517          	auipc	a0,0x1c
    800033e0:	3ec50513          	addi	a0,a0,1004 # 8001f7c8 <itable>
    800033e4:	ffffd097          	auipc	ra,0xffffd
    800033e8:	7ec080e7          	jalr	2028(ra) # 80000bd0 <acquire>
  empty = 0;
    800033ec:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033ee:	0001c497          	auipc	s1,0x1c
    800033f2:	3f248493          	addi	s1,s1,1010 # 8001f7e0 <itable+0x18>
    800033f6:	0001e697          	auipc	a3,0x1e
    800033fa:	e7a68693          	addi	a3,a3,-390 # 80021270 <log>
    800033fe:	a039                	j	8000340c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003400:	02090b63          	beqz	s2,80003436 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003404:	08848493          	addi	s1,s1,136
    80003408:	02d48a63          	beq	s1,a3,8000343c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000340c:	449c                	lw	a5,8(s1)
    8000340e:	fef059e3          	blez	a5,80003400 <iget+0x38>
    80003412:	4098                	lw	a4,0(s1)
    80003414:	ff3716e3          	bne	a4,s3,80003400 <iget+0x38>
    80003418:	40d8                	lw	a4,4(s1)
    8000341a:	ff4713e3          	bne	a4,s4,80003400 <iget+0x38>
      ip->ref++;
    8000341e:	2785                	addiw	a5,a5,1
    80003420:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003422:	0001c517          	auipc	a0,0x1c
    80003426:	3a650513          	addi	a0,a0,934 # 8001f7c8 <itable>
    8000342a:	ffffe097          	auipc	ra,0xffffe
    8000342e:	85a080e7          	jalr	-1958(ra) # 80000c84 <release>
      return ip;
    80003432:	8926                	mv	s2,s1
    80003434:	a03d                	j	80003462 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003436:	f7f9                	bnez	a5,80003404 <iget+0x3c>
    80003438:	8926                	mv	s2,s1
    8000343a:	b7e9                	j	80003404 <iget+0x3c>
  if(empty == 0)
    8000343c:	02090c63          	beqz	s2,80003474 <iget+0xac>
  ip->dev = dev;
    80003440:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003444:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003448:	4785                	li	a5,1
    8000344a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000344e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003452:	0001c517          	auipc	a0,0x1c
    80003456:	37650513          	addi	a0,a0,886 # 8001f7c8 <itable>
    8000345a:	ffffe097          	auipc	ra,0xffffe
    8000345e:	82a080e7          	jalr	-2006(ra) # 80000c84 <release>
}
    80003462:	854a                	mv	a0,s2
    80003464:	70a2                	ld	ra,40(sp)
    80003466:	7402                	ld	s0,32(sp)
    80003468:	64e2                	ld	s1,24(sp)
    8000346a:	6942                	ld	s2,16(sp)
    8000346c:	69a2                	ld	s3,8(sp)
    8000346e:	6a02                	ld	s4,0(sp)
    80003470:	6145                	addi	sp,sp,48
    80003472:	8082                	ret
    panic("iget: no inodes");
    80003474:	00005517          	auipc	a0,0x5
    80003478:	12450513          	addi	a0,a0,292 # 80008598 <syscalls+0x150>
    8000347c:	ffffd097          	auipc	ra,0xffffd
    80003480:	0be080e7          	jalr	190(ra) # 8000053a <panic>

0000000080003484 <fsinit>:
fsinit(int dev) {
    80003484:	7179                	addi	sp,sp,-48
    80003486:	f406                	sd	ra,40(sp)
    80003488:	f022                	sd	s0,32(sp)
    8000348a:	ec26                	sd	s1,24(sp)
    8000348c:	e84a                	sd	s2,16(sp)
    8000348e:	e44e                	sd	s3,8(sp)
    80003490:	1800                	addi	s0,sp,48
    80003492:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003494:	4585                	li	a1,1
    80003496:	00000097          	auipc	ra,0x0
    8000349a:	a66080e7          	jalr	-1434(ra) # 80002efc <bread>
    8000349e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034a0:	0001c997          	auipc	s3,0x1c
    800034a4:	30898993          	addi	s3,s3,776 # 8001f7a8 <sb>
    800034a8:	02000613          	li	a2,32
    800034ac:	05850593          	addi	a1,a0,88
    800034b0:	854e                	mv	a0,s3
    800034b2:	ffffe097          	auipc	ra,0xffffe
    800034b6:	876080e7          	jalr	-1930(ra) # 80000d28 <memmove>
  brelse(bp);
    800034ba:	8526                	mv	a0,s1
    800034bc:	00000097          	auipc	ra,0x0
    800034c0:	b70080e7          	jalr	-1168(ra) # 8000302c <brelse>
  if(sb.magic != FSMAGIC)
    800034c4:	0009a703          	lw	a4,0(s3)
    800034c8:	102037b7          	lui	a5,0x10203
    800034cc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034d0:	02f71263          	bne	a4,a5,800034f4 <fsinit+0x70>
  initlog(dev, &sb);
    800034d4:	0001c597          	auipc	a1,0x1c
    800034d8:	2d458593          	addi	a1,a1,724 # 8001f7a8 <sb>
    800034dc:	854a                	mv	a0,s2
    800034de:	00001097          	auipc	ra,0x1
    800034e2:	b56080e7          	jalr	-1194(ra) # 80004034 <initlog>
}
    800034e6:	70a2                	ld	ra,40(sp)
    800034e8:	7402                	ld	s0,32(sp)
    800034ea:	64e2                	ld	s1,24(sp)
    800034ec:	6942                	ld	s2,16(sp)
    800034ee:	69a2                	ld	s3,8(sp)
    800034f0:	6145                	addi	sp,sp,48
    800034f2:	8082                	ret
    panic("invalid file system");
    800034f4:	00005517          	auipc	a0,0x5
    800034f8:	0b450513          	addi	a0,a0,180 # 800085a8 <syscalls+0x160>
    800034fc:	ffffd097          	auipc	ra,0xffffd
    80003500:	03e080e7          	jalr	62(ra) # 8000053a <panic>

0000000080003504 <iinit>:
{
    80003504:	7179                	addi	sp,sp,-48
    80003506:	f406                	sd	ra,40(sp)
    80003508:	f022                	sd	s0,32(sp)
    8000350a:	ec26                	sd	s1,24(sp)
    8000350c:	e84a                	sd	s2,16(sp)
    8000350e:	e44e                	sd	s3,8(sp)
    80003510:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003512:	00005597          	auipc	a1,0x5
    80003516:	0ae58593          	addi	a1,a1,174 # 800085c0 <syscalls+0x178>
    8000351a:	0001c517          	auipc	a0,0x1c
    8000351e:	2ae50513          	addi	a0,a0,686 # 8001f7c8 <itable>
    80003522:	ffffd097          	auipc	ra,0xffffd
    80003526:	61e080e7          	jalr	1566(ra) # 80000b40 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000352a:	0001c497          	auipc	s1,0x1c
    8000352e:	2c648493          	addi	s1,s1,710 # 8001f7f0 <itable+0x28>
    80003532:	0001e997          	auipc	s3,0x1e
    80003536:	d4e98993          	addi	s3,s3,-690 # 80021280 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000353a:	00005917          	auipc	s2,0x5
    8000353e:	08e90913          	addi	s2,s2,142 # 800085c8 <syscalls+0x180>
    80003542:	85ca                	mv	a1,s2
    80003544:	8526                	mv	a0,s1
    80003546:	00001097          	auipc	ra,0x1
    8000354a:	e4e080e7          	jalr	-434(ra) # 80004394 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000354e:	08848493          	addi	s1,s1,136
    80003552:	ff3498e3          	bne	s1,s3,80003542 <iinit+0x3e>
}
    80003556:	70a2                	ld	ra,40(sp)
    80003558:	7402                	ld	s0,32(sp)
    8000355a:	64e2                	ld	s1,24(sp)
    8000355c:	6942                	ld	s2,16(sp)
    8000355e:	69a2                	ld	s3,8(sp)
    80003560:	6145                	addi	sp,sp,48
    80003562:	8082                	ret

0000000080003564 <ialloc>:
{
    80003564:	715d                	addi	sp,sp,-80
    80003566:	e486                	sd	ra,72(sp)
    80003568:	e0a2                	sd	s0,64(sp)
    8000356a:	fc26                	sd	s1,56(sp)
    8000356c:	f84a                	sd	s2,48(sp)
    8000356e:	f44e                	sd	s3,40(sp)
    80003570:	f052                	sd	s4,32(sp)
    80003572:	ec56                	sd	s5,24(sp)
    80003574:	e85a                	sd	s6,16(sp)
    80003576:	e45e                	sd	s7,8(sp)
    80003578:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000357a:	0001c717          	auipc	a4,0x1c
    8000357e:	23a72703          	lw	a4,570(a4) # 8001f7b4 <sb+0xc>
    80003582:	4785                	li	a5,1
    80003584:	04e7fa63          	bgeu	a5,a4,800035d8 <ialloc+0x74>
    80003588:	8aaa                	mv	s5,a0
    8000358a:	8bae                	mv	s7,a1
    8000358c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000358e:	0001ca17          	auipc	s4,0x1c
    80003592:	21aa0a13          	addi	s4,s4,538 # 8001f7a8 <sb>
    80003596:	00048b1b          	sext.w	s6,s1
    8000359a:	0044d593          	srli	a1,s1,0x4
    8000359e:	018a2783          	lw	a5,24(s4)
    800035a2:	9dbd                	addw	a1,a1,a5
    800035a4:	8556                	mv	a0,s5
    800035a6:	00000097          	auipc	ra,0x0
    800035aa:	956080e7          	jalr	-1706(ra) # 80002efc <bread>
    800035ae:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035b0:	05850993          	addi	s3,a0,88
    800035b4:	00f4f793          	andi	a5,s1,15
    800035b8:	079a                	slli	a5,a5,0x6
    800035ba:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035bc:	00099783          	lh	a5,0(s3)
    800035c0:	c785                	beqz	a5,800035e8 <ialloc+0x84>
    brelse(bp);
    800035c2:	00000097          	auipc	ra,0x0
    800035c6:	a6a080e7          	jalr	-1430(ra) # 8000302c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035ca:	0485                	addi	s1,s1,1
    800035cc:	00ca2703          	lw	a4,12(s4)
    800035d0:	0004879b          	sext.w	a5,s1
    800035d4:	fce7e1e3          	bltu	a5,a4,80003596 <ialloc+0x32>
  panic("ialloc: no inodes");
    800035d8:	00005517          	auipc	a0,0x5
    800035dc:	ff850513          	addi	a0,a0,-8 # 800085d0 <syscalls+0x188>
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	f5a080e7          	jalr	-166(ra) # 8000053a <panic>
      memset(dip, 0, sizeof(*dip));
    800035e8:	04000613          	li	a2,64
    800035ec:	4581                	li	a1,0
    800035ee:	854e                	mv	a0,s3
    800035f0:	ffffd097          	auipc	ra,0xffffd
    800035f4:	6dc080e7          	jalr	1756(ra) # 80000ccc <memset>
      dip->type = type;
    800035f8:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035fc:	854a                	mv	a0,s2
    800035fe:	00001097          	auipc	ra,0x1
    80003602:	cb2080e7          	jalr	-846(ra) # 800042b0 <log_write>
      brelse(bp);
    80003606:	854a                	mv	a0,s2
    80003608:	00000097          	auipc	ra,0x0
    8000360c:	a24080e7          	jalr	-1500(ra) # 8000302c <brelse>
      return iget(dev, inum);
    80003610:	85da                	mv	a1,s6
    80003612:	8556                	mv	a0,s5
    80003614:	00000097          	auipc	ra,0x0
    80003618:	db4080e7          	jalr	-588(ra) # 800033c8 <iget>
}
    8000361c:	60a6                	ld	ra,72(sp)
    8000361e:	6406                	ld	s0,64(sp)
    80003620:	74e2                	ld	s1,56(sp)
    80003622:	7942                	ld	s2,48(sp)
    80003624:	79a2                	ld	s3,40(sp)
    80003626:	7a02                	ld	s4,32(sp)
    80003628:	6ae2                	ld	s5,24(sp)
    8000362a:	6b42                	ld	s6,16(sp)
    8000362c:	6ba2                	ld	s7,8(sp)
    8000362e:	6161                	addi	sp,sp,80
    80003630:	8082                	ret

0000000080003632 <iupdate>:
{
    80003632:	1101                	addi	sp,sp,-32
    80003634:	ec06                	sd	ra,24(sp)
    80003636:	e822                	sd	s0,16(sp)
    80003638:	e426                	sd	s1,8(sp)
    8000363a:	e04a                	sd	s2,0(sp)
    8000363c:	1000                	addi	s0,sp,32
    8000363e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003640:	415c                	lw	a5,4(a0)
    80003642:	0047d79b          	srliw	a5,a5,0x4
    80003646:	0001c597          	auipc	a1,0x1c
    8000364a:	17a5a583          	lw	a1,378(a1) # 8001f7c0 <sb+0x18>
    8000364e:	9dbd                	addw	a1,a1,a5
    80003650:	4108                	lw	a0,0(a0)
    80003652:	00000097          	auipc	ra,0x0
    80003656:	8aa080e7          	jalr	-1878(ra) # 80002efc <bread>
    8000365a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000365c:	05850793          	addi	a5,a0,88
    80003660:	40d8                	lw	a4,4(s1)
    80003662:	8b3d                	andi	a4,a4,15
    80003664:	071a                	slli	a4,a4,0x6
    80003666:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003668:	04449703          	lh	a4,68(s1)
    8000366c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003670:	04649703          	lh	a4,70(s1)
    80003674:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003678:	04849703          	lh	a4,72(s1)
    8000367c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003680:	04a49703          	lh	a4,74(s1)
    80003684:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003688:	44f8                	lw	a4,76(s1)
    8000368a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000368c:	03400613          	li	a2,52
    80003690:	05048593          	addi	a1,s1,80
    80003694:	00c78513          	addi	a0,a5,12
    80003698:	ffffd097          	auipc	ra,0xffffd
    8000369c:	690080e7          	jalr	1680(ra) # 80000d28 <memmove>
  log_write(bp);
    800036a0:	854a                	mv	a0,s2
    800036a2:	00001097          	auipc	ra,0x1
    800036a6:	c0e080e7          	jalr	-1010(ra) # 800042b0 <log_write>
  brelse(bp);
    800036aa:	854a                	mv	a0,s2
    800036ac:	00000097          	auipc	ra,0x0
    800036b0:	980080e7          	jalr	-1664(ra) # 8000302c <brelse>
}
    800036b4:	60e2                	ld	ra,24(sp)
    800036b6:	6442                	ld	s0,16(sp)
    800036b8:	64a2                	ld	s1,8(sp)
    800036ba:	6902                	ld	s2,0(sp)
    800036bc:	6105                	addi	sp,sp,32
    800036be:	8082                	ret

00000000800036c0 <idup>:
{
    800036c0:	1101                	addi	sp,sp,-32
    800036c2:	ec06                	sd	ra,24(sp)
    800036c4:	e822                	sd	s0,16(sp)
    800036c6:	e426                	sd	s1,8(sp)
    800036c8:	1000                	addi	s0,sp,32
    800036ca:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036cc:	0001c517          	auipc	a0,0x1c
    800036d0:	0fc50513          	addi	a0,a0,252 # 8001f7c8 <itable>
    800036d4:	ffffd097          	auipc	ra,0xffffd
    800036d8:	4fc080e7          	jalr	1276(ra) # 80000bd0 <acquire>
  ip->ref++;
    800036dc:	449c                	lw	a5,8(s1)
    800036de:	2785                	addiw	a5,a5,1
    800036e0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036e2:	0001c517          	auipc	a0,0x1c
    800036e6:	0e650513          	addi	a0,a0,230 # 8001f7c8 <itable>
    800036ea:	ffffd097          	auipc	ra,0xffffd
    800036ee:	59a080e7          	jalr	1434(ra) # 80000c84 <release>
}
    800036f2:	8526                	mv	a0,s1
    800036f4:	60e2                	ld	ra,24(sp)
    800036f6:	6442                	ld	s0,16(sp)
    800036f8:	64a2                	ld	s1,8(sp)
    800036fa:	6105                	addi	sp,sp,32
    800036fc:	8082                	ret

00000000800036fe <ilock>:
{
    800036fe:	1101                	addi	sp,sp,-32
    80003700:	ec06                	sd	ra,24(sp)
    80003702:	e822                	sd	s0,16(sp)
    80003704:	e426                	sd	s1,8(sp)
    80003706:	e04a                	sd	s2,0(sp)
    80003708:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000370a:	c115                	beqz	a0,8000372e <ilock+0x30>
    8000370c:	84aa                	mv	s1,a0
    8000370e:	451c                	lw	a5,8(a0)
    80003710:	00f05f63          	blez	a5,8000372e <ilock+0x30>
  acquiresleep(&ip->lock);
    80003714:	0541                	addi	a0,a0,16
    80003716:	00001097          	auipc	ra,0x1
    8000371a:	cb8080e7          	jalr	-840(ra) # 800043ce <acquiresleep>
  if(ip->valid == 0){
    8000371e:	40bc                	lw	a5,64(s1)
    80003720:	cf99                	beqz	a5,8000373e <ilock+0x40>
}
    80003722:	60e2                	ld	ra,24(sp)
    80003724:	6442                	ld	s0,16(sp)
    80003726:	64a2                	ld	s1,8(sp)
    80003728:	6902                	ld	s2,0(sp)
    8000372a:	6105                	addi	sp,sp,32
    8000372c:	8082                	ret
    panic("ilock");
    8000372e:	00005517          	auipc	a0,0x5
    80003732:	eba50513          	addi	a0,a0,-326 # 800085e8 <syscalls+0x1a0>
    80003736:	ffffd097          	auipc	ra,0xffffd
    8000373a:	e04080e7          	jalr	-508(ra) # 8000053a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000373e:	40dc                	lw	a5,4(s1)
    80003740:	0047d79b          	srliw	a5,a5,0x4
    80003744:	0001c597          	auipc	a1,0x1c
    80003748:	07c5a583          	lw	a1,124(a1) # 8001f7c0 <sb+0x18>
    8000374c:	9dbd                	addw	a1,a1,a5
    8000374e:	4088                	lw	a0,0(s1)
    80003750:	fffff097          	auipc	ra,0xfffff
    80003754:	7ac080e7          	jalr	1964(ra) # 80002efc <bread>
    80003758:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000375a:	05850593          	addi	a1,a0,88
    8000375e:	40dc                	lw	a5,4(s1)
    80003760:	8bbd                	andi	a5,a5,15
    80003762:	079a                	slli	a5,a5,0x6
    80003764:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003766:	00059783          	lh	a5,0(a1)
    8000376a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000376e:	00259783          	lh	a5,2(a1)
    80003772:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003776:	00459783          	lh	a5,4(a1)
    8000377a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000377e:	00659783          	lh	a5,6(a1)
    80003782:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003786:	459c                	lw	a5,8(a1)
    80003788:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000378a:	03400613          	li	a2,52
    8000378e:	05b1                	addi	a1,a1,12
    80003790:	05048513          	addi	a0,s1,80
    80003794:	ffffd097          	auipc	ra,0xffffd
    80003798:	594080e7          	jalr	1428(ra) # 80000d28 <memmove>
    brelse(bp);
    8000379c:	854a                	mv	a0,s2
    8000379e:	00000097          	auipc	ra,0x0
    800037a2:	88e080e7          	jalr	-1906(ra) # 8000302c <brelse>
    ip->valid = 1;
    800037a6:	4785                	li	a5,1
    800037a8:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037aa:	04449783          	lh	a5,68(s1)
    800037ae:	fbb5                	bnez	a5,80003722 <ilock+0x24>
      panic("ilock: no type");
    800037b0:	00005517          	auipc	a0,0x5
    800037b4:	e4050513          	addi	a0,a0,-448 # 800085f0 <syscalls+0x1a8>
    800037b8:	ffffd097          	auipc	ra,0xffffd
    800037bc:	d82080e7          	jalr	-638(ra) # 8000053a <panic>

00000000800037c0 <iunlock>:
{
    800037c0:	1101                	addi	sp,sp,-32
    800037c2:	ec06                	sd	ra,24(sp)
    800037c4:	e822                	sd	s0,16(sp)
    800037c6:	e426                	sd	s1,8(sp)
    800037c8:	e04a                	sd	s2,0(sp)
    800037ca:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037cc:	c905                	beqz	a0,800037fc <iunlock+0x3c>
    800037ce:	84aa                	mv	s1,a0
    800037d0:	01050913          	addi	s2,a0,16
    800037d4:	854a                	mv	a0,s2
    800037d6:	00001097          	auipc	ra,0x1
    800037da:	c92080e7          	jalr	-878(ra) # 80004468 <holdingsleep>
    800037de:	cd19                	beqz	a0,800037fc <iunlock+0x3c>
    800037e0:	449c                	lw	a5,8(s1)
    800037e2:	00f05d63          	blez	a5,800037fc <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037e6:	854a                	mv	a0,s2
    800037e8:	00001097          	auipc	ra,0x1
    800037ec:	c3c080e7          	jalr	-964(ra) # 80004424 <releasesleep>
}
    800037f0:	60e2                	ld	ra,24(sp)
    800037f2:	6442                	ld	s0,16(sp)
    800037f4:	64a2                	ld	s1,8(sp)
    800037f6:	6902                	ld	s2,0(sp)
    800037f8:	6105                	addi	sp,sp,32
    800037fa:	8082                	ret
    panic("iunlock");
    800037fc:	00005517          	auipc	a0,0x5
    80003800:	e0450513          	addi	a0,a0,-508 # 80008600 <syscalls+0x1b8>
    80003804:	ffffd097          	auipc	ra,0xffffd
    80003808:	d36080e7          	jalr	-714(ra) # 8000053a <panic>

000000008000380c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000380c:	7179                	addi	sp,sp,-48
    8000380e:	f406                	sd	ra,40(sp)
    80003810:	f022                	sd	s0,32(sp)
    80003812:	ec26                	sd	s1,24(sp)
    80003814:	e84a                	sd	s2,16(sp)
    80003816:	e44e                	sd	s3,8(sp)
    80003818:	e052                	sd	s4,0(sp)
    8000381a:	1800                	addi	s0,sp,48
    8000381c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000381e:	05050493          	addi	s1,a0,80
    80003822:	08050913          	addi	s2,a0,128
    80003826:	a021                	j	8000382e <itrunc+0x22>
    80003828:	0491                	addi	s1,s1,4
    8000382a:	01248d63          	beq	s1,s2,80003844 <itrunc+0x38>
    if(ip->addrs[i]){
    8000382e:	408c                	lw	a1,0(s1)
    80003830:	dde5                	beqz	a1,80003828 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003832:	0009a503          	lw	a0,0(s3)
    80003836:	00000097          	auipc	ra,0x0
    8000383a:	90c080e7          	jalr	-1780(ra) # 80003142 <bfree>
      ip->addrs[i] = 0;
    8000383e:	0004a023          	sw	zero,0(s1)
    80003842:	b7dd                	j	80003828 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003844:	0809a583          	lw	a1,128(s3)
    80003848:	e185                	bnez	a1,80003868 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000384a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000384e:	854e                	mv	a0,s3
    80003850:	00000097          	auipc	ra,0x0
    80003854:	de2080e7          	jalr	-542(ra) # 80003632 <iupdate>
}
    80003858:	70a2                	ld	ra,40(sp)
    8000385a:	7402                	ld	s0,32(sp)
    8000385c:	64e2                	ld	s1,24(sp)
    8000385e:	6942                	ld	s2,16(sp)
    80003860:	69a2                	ld	s3,8(sp)
    80003862:	6a02                	ld	s4,0(sp)
    80003864:	6145                	addi	sp,sp,48
    80003866:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003868:	0009a503          	lw	a0,0(s3)
    8000386c:	fffff097          	auipc	ra,0xfffff
    80003870:	690080e7          	jalr	1680(ra) # 80002efc <bread>
    80003874:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003876:	05850493          	addi	s1,a0,88
    8000387a:	45850913          	addi	s2,a0,1112
    8000387e:	a021                	j	80003886 <itrunc+0x7a>
    80003880:	0491                	addi	s1,s1,4
    80003882:	01248b63          	beq	s1,s2,80003898 <itrunc+0x8c>
      if(a[j])
    80003886:	408c                	lw	a1,0(s1)
    80003888:	dde5                	beqz	a1,80003880 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000388a:	0009a503          	lw	a0,0(s3)
    8000388e:	00000097          	auipc	ra,0x0
    80003892:	8b4080e7          	jalr	-1868(ra) # 80003142 <bfree>
    80003896:	b7ed                	j	80003880 <itrunc+0x74>
    brelse(bp);
    80003898:	8552                	mv	a0,s4
    8000389a:	fffff097          	auipc	ra,0xfffff
    8000389e:	792080e7          	jalr	1938(ra) # 8000302c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038a2:	0809a583          	lw	a1,128(s3)
    800038a6:	0009a503          	lw	a0,0(s3)
    800038aa:	00000097          	auipc	ra,0x0
    800038ae:	898080e7          	jalr	-1896(ra) # 80003142 <bfree>
    ip->addrs[NDIRECT] = 0;
    800038b2:	0809a023          	sw	zero,128(s3)
    800038b6:	bf51                	j	8000384a <itrunc+0x3e>

00000000800038b8 <iput>:
{
    800038b8:	1101                	addi	sp,sp,-32
    800038ba:	ec06                	sd	ra,24(sp)
    800038bc:	e822                	sd	s0,16(sp)
    800038be:	e426                	sd	s1,8(sp)
    800038c0:	e04a                	sd	s2,0(sp)
    800038c2:	1000                	addi	s0,sp,32
    800038c4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038c6:	0001c517          	auipc	a0,0x1c
    800038ca:	f0250513          	addi	a0,a0,-254 # 8001f7c8 <itable>
    800038ce:	ffffd097          	auipc	ra,0xffffd
    800038d2:	302080e7          	jalr	770(ra) # 80000bd0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038d6:	4498                	lw	a4,8(s1)
    800038d8:	4785                	li	a5,1
    800038da:	02f70363          	beq	a4,a5,80003900 <iput+0x48>
  ip->ref--;
    800038de:	449c                	lw	a5,8(s1)
    800038e0:	37fd                	addiw	a5,a5,-1
    800038e2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038e4:	0001c517          	auipc	a0,0x1c
    800038e8:	ee450513          	addi	a0,a0,-284 # 8001f7c8 <itable>
    800038ec:	ffffd097          	auipc	ra,0xffffd
    800038f0:	398080e7          	jalr	920(ra) # 80000c84 <release>
}
    800038f4:	60e2                	ld	ra,24(sp)
    800038f6:	6442                	ld	s0,16(sp)
    800038f8:	64a2                	ld	s1,8(sp)
    800038fa:	6902                	ld	s2,0(sp)
    800038fc:	6105                	addi	sp,sp,32
    800038fe:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003900:	40bc                	lw	a5,64(s1)
    80003902:	dff1                	beqz	a5,800038de <iput+0x26>
    80003904:	04a49783          	lh	a5,74(s1)
    80003908:	fbf9                	bnez	a5,800038de <iput+0x26>
    acquiresleep(&ip->lock);
    8000390a:	01048913          	addi	s2,s1,16
    8000390e:	854a                	mv	a0,s2
    80003910:	00001097          	auipc	ra,0x1
    80003914:	abe080e7          	jalr	-1346(ra) # 800043ce <acquiresleep>
    release(&itable.lock);
    80003918:	0001c517          	auipc	a0,0x1c
    8000391c:	eb050513          	addi	a0,a0,-336 # 8001f7c8 <itable>
    80003920:	ffffd097          	auipc	ra,0xffffd
    80003924:	364080e7          	jalr	868(ra) # 80000c84 <release>
    itrunc(ip);
    80003928:	8526                	mv	a0,s1
    8000392a:	00000097          	auipc	ra,0x0
    8000392e:	ee2080e7          	jalr	-286(ra) # 8000380c <itrunc>
    ip->type = 0;
    80003932:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003936:	8526                	mv	a0,s1
    80003938:	00000097          	auipc	ra,0x0
    8000393c:	cfa080e7          	jalr	-774(ra) # 80003632 <iupdate>
    ip->valid = 0;
    80003940:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003944:	854a                	mv	a0,s2
    80003946:	00001097          	auipc	ra,0x1
    8000394a:	ade080e7          	jalr	-1314(ra) # 80004424 <releasesleep>
    acquire(&itable.lock);
    8000394e:	0001c517          	auipc	a0,0x1c
    80003952:	e7a50513          	addi	a0,a0,-390 # 8001f7c8 <itable>
    80003956:	ffffd097          	auipc	ra,0xffffd
    8000395a:	27a080e7          	jalr	634(ra) # 80000bd0 <acquire>
    8000395e:	b741                	j	800038de <iput+0x26>

0000000080003960 <iunlockput>:
{
    80003960:	1101                	addi	sp,sp,-32
    80003962:	ec06                	sd	ra,24(sp)
    80003964:	e822                	sd	s0,16(sp)
    80003966:	e426                	sd	s1,8(sp)
    80003968:	1000                	addi	s0,sp,32
    8000396a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000396c:	00000097          	auipc	ra,0x0
    80003970:	e54080e7          	jalr	-428(ra) # 800037c0 <iunlock>
  iput(ip);
    80003974:	8526                	mv	a0,s1
    80003976:	00000097          	auipc	ra,0x0
    8000397a:	f42080e7          	jalr	-190(ra) # 800038b8 <iput>
}
    8000397e:	60e2                	ld	ra,24(sp)
    80003980:	6442                	ld	s0,16(sp)
    80003982:	64a2                	ld	s1,8(sp)
    80003984:	6105                	addi	sp,sp,32
    80003986:	8082                	ret

0000000080003988 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003988:	1141                	addi	sp,sp,-16
    8000398a:	e422                	sd	s0,8(sp)
    8000398c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000398e:	411c                	lw	a5,0(a0)
    80003990:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003992:	415c                	lw	a5,4(a0)
    80003994:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003996:	04451783          	lh	a5,68(a0)
    8000399a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000399e:	04a51783          	lh	a5,74(a0)
    800039a2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039a6:	04c56783          	lwu	a5,76(a0)
    800039aa:	e99c                	sd	a5,16(a1)
}
    800039ac:	6422                	ld	s0,8(sp)
    800039ae:	0141                	addi	sp,sp,16
    800039b0:	8082                	ret

00000000800039b2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039b2:	457c                	lw	a5,76(a0)
    800039b4:	0ed7e963          	bltu	a5,a3,80003aa6 <readi+0xf4>
{
    800039b8:	7159                	addi	sp,sp,-112
    800039ba:	f486                	sd	ra,104(sp)
    800039bc:	f0a2                	sd	s0,96(sp)
    800039be:	eca6                	sd	s1,88(sp)
    800039c0:	e8ca                	sd	s2,80(sp)
    800039c2:	e4ce                	sd	s3,72(sp)
    800039c4:	e0d2                	sd	s4,64(sp)
    800039c6:	fc56                	sd	s5,56(sp)
    800039c8:	f85a                	sd	s6,48(sp)
    800039ca:	f45e                	sd	s7,40(sp)
    800039cc:	f062                	sd	s8,32(sp)
    800039ce:	ec66                	sd	s9,24(sp)
    800039d0:	e86a                	sd	s10,16(sp)
    800039d2:	e46e                	sd	s11,8(sp)
    800039d4:	1880                	addi	s0,sp,112
    800039d6:	8baa                	mv	s7,a0
    800039d8:	8c2e                	mv	s8,a1
    800039da:	8ab2                	mv	s5,a2
    800039dc:	84b6                	mv	s1,a3
    800039de:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039e0:	9f35                	addw	a4,a4,a3
    return 0;
    800039e2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039e4:	0ad76063          	bltu	a4,a3,80003a84 <readi+0xd2>
  if(off + n > ip->size)
    800039e8:	00e7f463          	bgeu	a5,a4,800039f0 <readi+0x3e>
    n = ip->size - off;
    800039ec:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039f0:	0a0b0963          	beqz	s6,80003aa2 <readi+0xf0>
    800039f4:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800039f6:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039fa:	5cfd                	li	s9,-1
    800039fc:	a82d                	j	80003a36 <readi+0x84>
    800039fe:	020a1d93          	slli	s11,s4,0x20
    80003a02:	020ddd93          	srli	s11,s11,0x20
    80003a06:	05890613          	addi	a2,s2,88
    80003a0a:	86ee                	mv	a3,s11
    80003a0c:	963a                	add	a2,a2,a4
    80003a0e:	85d6                	mv	a1,s5
    80003a10:	8562                	mv	a0,s8
    80003a12:	fffff097          	auipc	ra,0xfffff
    80003a16:	9f4080e7          	jalr	-1548(ra) # 80002406 <either_copyout>
    80003a1a:	05950d63          	beq	a0,s9,80003a74 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a1e:	854a                	mv	a0,s2
    80003a20:	fffff097          	auipc	ra,0xfffff
    80003a24:	60c080e7          	jalr	1548(ra) # 8000302c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a28:	013a09bb          	addw	s3,s4,s3
    80003a2c:	009a04bb          	addw	s1,s4,s1
    80003a30:	9aee                	add	s5,s5,s11
    80003a32:	0569f763          	bgeu	s3,s6,80003a80 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a36:	000ba903          	lw	s2,0(s7)
    80003a3a:	00a4d59b          	srliw	a1,s1,0xa
    80003a3e:	855e                	mv	a0,s7
    80003a40:	00000097          	auipc	ra,0x0
    80003a44:	8ac080e7          	jalr	-1876(ra) # 800032ec <bmap>
    80003a48:	0005059b          	sext.w	a1,a0
    80003a4c:	854a                	mv	a0,s2
    80003a4e:	fffff097          	auipc	ra,0xfffff
    80003a52:	4ae080e7          	jalr	1198(ra) # 80002efc <bread>
    80003a56:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a58:	3ff4f713          	andi	a4,s1,1023
    80003a5c:	40ed07bb          	subw	a5,s10,a4
    80003a60:	413b06bb          	subw	a3,s6,s3
    80003a64:	8a3e                	mv	s4,a5
    80003a66:	2781                	sext.w	a5,a5
    80003a68:	0006861b          	sext.w	a2,a3
    80003a6c:	f8f679e3          	bgeu	a2,a5,800039fe <readi+0x4c>
    80003a70:	8a36                	mv	s4,a3
    80003a72:	b771                	j	800039fe <readi+0x4c>
      brelse(bp);
    80003a74:	854a                	mv	a0,s2
    80003a76:	fffff097          	auipc	ra,0xfffff
    80003a7a:	5b6080e7          	jalr	1462(ra) # 8000302c <brelse>
      tot = -1;
    80003a7e:	59fd                	li	s3,-1
  }
  return tot;
    80003a80:	0009851b          	sext.w	a0,s3
}
    80003a84:	70a6                	ld	ra,104(sp)
    80003a86:	7406                	ld	s0,96(sp)
    80003a88:	64e6                	ld	s1,88(sp)
    80003a8a:	6946                	ld	s2,80(sp)
    80003a8c:	69a6                	ld	s3,72(sp)
    80003a8e:	6a06                	ld	s4,64(sp)
    80003a90:	7ae2                	ld	s5,56(sp)
    80003a92:	7b42                	ld	s6,48(sp)
    80003a94:	7ba2                	ld	s7,40(sp)
    80003a96:	7c02                	ld	s8,32(sp)
    80003a98:	6ce2                	ld	s9,24(sp)
    80003a9a:	6d42                	ld	s10,16(sp)
    80003a9c:	6da2                	ld	s11,8(sp)
    80003a9e:	6165                	addi	sp,sp,112
    80003aa0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003aa2:	89da                	mv	s3,s6
    80003aa4:	bff1                	j	80003a80 <readi+0xce>
    return 0;
    80003aa6:	4501                	li	a0,0
}
    80003aa8:	8082                	ret

0000000080003aaa <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003aaa:	457c                	lw	a5,76(a0)
    80003aac:	10d7e863          	bltu	a5,a3,80003bbc <writei+0x112>
{
    80003ab0:	7159                	addi	sp,sp,-112
    80003ab2:	f486                	sd	ra,104(sp)
    80003ab4:	f0a2                	sd	s0,96(sp)
    80003ab6:	eca6                	sd	s1,88(sp)
    80003ab8:	e8ca                	sd	s2,80(sp)
    80003aba:	e4ce                	sd	s3,72(sp)
    80003abc:	e0d2                	sd	s4,64(sp)
    80003abe:	fc56                	sd	s5,56(sp)
    80003ac0:	f85a                	sd	s6,48(sp)
    80003ac2:	f45e                	sd	s7,40(sp)
    80003ac4:	f062                	sd	s8,32(sp)
    80003ac6:	ec66                	sd	s9,24(sp)
    80003ac8:	e86a                	sd	s10,16(sp)
    80003aca:	e46e                	sd	s11,8(sp)
    80003acc:	1880                	addi	s0,sp,112
    80003ace:	8b2a                	mv	s6,a0
    80003ad0:	8c2e                	mv	s8,a1
    80003ad2:	8ab2                	mv	s5,a2
    80003ad4:	8936                	mv	s2,a3
    80003ad6:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003ad8:	00e687bb          	addw	a5,a3,a4
    80003adc:	0ed7e263          	bltu	a5,a3,80003bc0 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ae0:	00043737          	lui	a4,0x43
    80003ae4:	0ef76063          	bltu	a4,a5,80003bc4 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ae8:	0c0b8863          	beqz	s7,80003bb8 <writei+0x10e>
    80003aec:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aee:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003af2:	5cfd                	li	s9,-1
    80003af4:	a091                	j	80003b38 <writei+0x8e>
    80003af6:	02099d93          	slli	s11,s3,0x20
    80003afa:	020ddd93          	srli	s11,s11,0x20
    80003afe:	05848513          	addi	a0,s1,88
    80003b02:	86ee                	mv	a3,s11
    80003b04:	8656                	mv	a2,s5
    80003b06:	85e2                	mv	a1,s8
    80003b08:	953a                	add	a0,a0,a4
    80003b0a:	fffff097          	auipc	ra,0xfffff
    80003b0e:	952080e7          	jalr	-1710(ra) # 8000245c <either_copyin>
    80003b12:	07950263          	beq	a0,s9,80003b76 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b16:	8526                	mv	a0,s1
    80003b18:	00000097          	auipc	ra,0x0
    80003b1c:	798080e7          	jalr	1944(ra) # 800042b0 <log_write>
    brelse(bp);
    80003b20:	8526                	mv	a0,s1
    80003b22:	fffff097          	auipc	ra,0xfffff
    80003b26:	50a080e7          	jalr	1290(ra) # 8000302c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b2a:	01498a3b          	addw	s4,s3,s4
    80003b2e:	0129893b          	addw	s2,s3,s2
    80003b32:	9aee                	add	s5,s5,s11
    80003b34:	057a7663          	bgeu	s4,s7,80003b80 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b38:	000b2483          	lw	s1,0(s6)
    80003b3c:	00a9559b          	srliw	a1,s2,0xa
    80003b40:	855a                	mv	a0,s6
    80003b42:	fffff097          	auipc	ra,0xfffff
    80003b46:	7aa080e7          	jalr	1962(ra) # 800032ec <bmap>
    80003b4a:	0005059b          	sext.w	a1,a0
    80003b4e:	8526                	mv	a0,s1
    80003b50:	fffff097          	auipc	ra,0xfffff
    80003b54:	3ac080e7          	jalr	940(ra) # 80002efc <bread>
    80003b58:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b5a:	3ff97713          	andi	a4,s2,1023
    80003b5e:	40ed07bb          	subw	a5,s10,a4
    80003b62:	414b86bb          	subw	a3,s7,s4
    80003b66:	89be                	mv	s3,a5
    80003b68:	2781                	sext.w	a5,a5
    80003b6a:	0006861b          	sext.w	a2,a3
    80003b6e:	f8f674e3          	bgeu	a2,a5,80003af6 <writei+0x4c>
    80003b72:	89b6                	mv	s3,a3
    80003b74:	b749                	j	80003af6 <writei+0x4c>
      brelse(bp);
    80003b76:	8526                	mv	a0,s1
    80003b78:	fffff097          	auipc	ra,0xfffff
    80003b7c:	4b4080e7          	jalr	1204(ra) # 8000302c <brelse>
  }

  if(off > ip->size)
    80003b80:	04cb2783          	lw	a5,76(s6)
    80003b84:	0127f463          	bgeu	a5,s2,80003b8c <writei+0xe2>
    ip->size = off;
    80003b88:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b8c:	855a                	mv	a0,s6
    80003b8e:	00000097          	auipc	ra,0x0
    80003b92:	aa4080e7          	jalr	-1372(ra) # 80003632 <iupdate>

  return tot;
    80003b96:	000a051b          	sext.w	a0,s4
}
    80003b9a:	70a6                	ld	ra,104(sp)
    80003b9c:	7406                	ld	s0,96(sp)
    80003b9e:	64e6                	ld	s1,88(sp)
    80003ba0:	6946                	ld	s2,80(sp)
    80003ba2:	69a6                	ld	s3,72(sp)
    80003ba4:	6a06                	ld	s4,64(sp)
    80003ba6:	7ae2                	ld	s5,56(sp)
    80003ba8:	7b42                	ld	s6,48(sp)
    80003baa:	7ba2                	ld	s7,40(sp)
    80003bac:	7c02                	ld	s8,32(sp)
    80003bae:	6ce2                	ld	s9,24(sp)
    80003bb0:	6d42                	ld	s10,16(sp)
    80003bb2:	6da2                	ld	s11,8(sp)
    80003bb4:	6165                	addi	sp,sp,112
    80003bb6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bb8:	8a5e                	mv	s4,s7
    80003bba:	bfc9                	j	80003b8c <writei+0xe2>
    return -1;
    80003bbc:	557d                	li	a0,-1
}
    80003bbe:	8082                	ret
    return -1;
    80003bc0:	557d                	li	a0,-1
    80003bc2:	bfe1                	j	80003b9a <writei+0xf0>
    return -1;
    80003bc4:	557d                	li	a0,-1
    80003bc6:	bfd1                	j	80003b9a <writei+0xf0>

0000000080003bc8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003bc8:	1141                	addi	sp,sp,-16
    80003bca:	e406                	sd	ra,8(sp)
    80003bcc:	e022                	sd	s0,0(sp)
    80003bce:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bd0:	4639                	li	a2,14
    80003bd2:	ffffd097          	auipc	ra,0xffffd
    80003bd6:	1ca080e7          	jalr	458(ra) # 80000d9c <strncmp>
}
    80003bda:	60a2                	ld	ra,8(sp)
    80003bdc:	6402                	ld	s0,0(sp)
    80003bde:	0141                	addi	sp,sp,16
    80003be0:	8082                	ret

0000000080003be2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003be2:	7139                	addi	sp,sp,-64
    80003be4:	fc06                	sd	ra,56(sp)
    80003be6:	f822                	sd	s0,48(sp)
    80003be8:	f426                	sd	s1,40(sp)
    80003bea:	f04a                	sd	s2,32(sp)
    80003bec:	ec4e                	sd	s3,24(sp)
    80003bee:	e852                	sd	s4,16(sp)
    80003bf0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003bf2:	04451703          	lh	a4,68(a0)
    80003bf6:	4785                	li	a5,1
    80003bf8:	00f71a63          	bne	a4,a5,80003c0c <dirlookup+0x2a>
    80003bfc:	892a                	mv	s2,a0
    80003bfe:	89ae                	mv	s3,a1
    80003c00:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c02:	457c                	lw	a5,76(a0)
    80003c04:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c06:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c08:	e79d                	bnez	a5,80003c36 <dirlookup+0x54>
    80003c0a:	a8a5                	j	80003c82 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c0c:	00005517          	auipc	a0,0x5
    80003c10:	9fc50513          	addi	a0,a0,-1540 # 80008608 <syscalls+0x1c0>
    80003c14:	ffffd097          	auipc	ra,0xffffd
    80003c18:	926080e7          	jalr	-1754(ra) # 8000053a <panic>
      panic("dirlookup read");
    80003c1c:	00005517          	auipc	a0,0x5
    80003c20:	a0450513          	addi	a0,a0,-1532 # 80008620 <syscalls+0x1d8>
    80003c24:	ffffd097          	auipc	ra,0xffffd
    80003c28:	916080e7          	jalr	-1770(ra) # 8000053a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c2c:	24c1                	addiw	s1,s1,16
    80003c2e:	04c92783          	lw	a5,76(s2)
    80003c32:	04f4f763          	bgeu	s1,a5,80003c80 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c36:	4741                	li	a4,16
    80003c38:	86a6                	mv	a3,s1
    80003c3a:	fc040613          	addi	a2,s0,-64
    80003c3e:	4581                	li	a1,0
    80003c40:	854a                	mv	a0,s2
    80003c42:	00000097          	auipc	ra,0x0
    80003c46:	d70080e7          	jalr	-656(ra) # 800039b2 <readi>
    80003c4a:	47c1                	li	a5,16
    80003c4c:	fcf518e3          	bne	a0,a5,80003c1c <dirlookup+0x3a>
    if(de.inum == 0)
    80003c50:	fc045783          	lhu	a5,-64(s0)
    80003c54:	dfe1                	beqz	a5,80003c2c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c56:	fc240593          	addi	a1,s0,-62
    80003c5a:	854e                	mv	a0,s3
    80003c5c:	00000097          	auipc	ra,0x0
    80003c60:	f6c080e7          	jalr	-148(ra) # 80003bc8 <namecmp>
    80003c64:	f561                	bnez	a0,80003c2c <dirlookup+0x4a>
      if(poff)
    80003c66:	000a0463          	beqz	s4,80003c6e <dirlookup+0x8c>
        *poff = off;
    80003c6a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c6e:	fc045583          	lhu	a1,-64(s0)
    80003c72:	00092503          	lw	a0,0(s2)
    80003c76:	fffff097          	auipc	ra,0xfffff
    80003c7a:	752080e7          	jalr	1874(ra) # 800033c8 <iget>
    80003c7e:	a011                	j	80003c82 <dirlookup+0xa0>
  return 0;
    80003c80:	4501                	li	a0,0
}
    80003c82:	70e2                	ld	ra,56(sp)
    80003c84:	7442                	ld	s0,48(sp)
    80003c86:	74a2                	ld	s1,40(sp)
    80003c88:	7902                	ld	s2,32(sp)
    80003c8a:	69e2                	ld	s3,24(sp)
    80003c8c:	6a42                	ld	s4,16(sp)
    80003c8e:	6121                	addi	sp,sp,64
    80003c90:	8082                	ret

0000000080003c92 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c92:	711d                	addi	sp,sp,-96
    80003c94:	ec86                	sd	ra,88(sp)
    80003c96:	e8a2                	sd	s0,80(sp)
    80003c98:	e4a6                	sd	s1,72(sp)
    80003c9a:	e0ca                	sd	s2,64(sp)
    80003c9c:	fc4e                	sd	s3,56(sp)
    80003c9e:	f852                	sd	s4,48(sp)
    80003ca0:	f456                	sd	s5,40(sp)
    80003ca2:	f05a                	sd	s6,32(sp)
    80003ca4:	ec5e                	sd	s7,24(sp)
    80003ca6:	e862                	sd	s8,16(sp)
    80003ca8:	e466                	sd	s9,8(sp)
    80003caa:	e06a                	sd	s10,0(sp)
    80003cac:	1080                	addi	s0,sp,96
    80003cae:	84aa                	mv	s1,a0
    80003cb0:	8b2e                	mv	s6,a1
    80003cb2:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003cb4:	00054703          	lbu	a4,0(a0)
    80003cb8:	02f00793          	li	a5,47
    80003cbc:	02f70363          	beq	a4,a5,80003ce2 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cc0:	ffffe097          	auipc	ra,0xffffe
    80003cc4:	cde080e7          	jalr	-802(ra) # 8000199e <myproc>
    80003cc8:	15053503          	ld	a0,336(a0)
    80003ccc:	00000097          	auipc	ra,0x0
    80003cd0:	9f4080e7          	jalr	-1548(ra) # 800036c0 <idup>
    80003cd4:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003cd6:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003cda:	4cb5                	li	s9,13
  len = path - s;
    80003cdc:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cde:	4c05                	li	s8,1
    80003ce0:	a87d                	j	80003d9e <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003ce2:	4585                	li	a1,1
    80003ce4:	4505                	li	a0,1
    80003ce6:	fffff097          	auipc	ra,0xfffff
    80003cea:	6e2080e7          	jalr	1762(ra) # 800033c8 <iget>
    80003cee:	8a2a                	mv	s4,a0
    80003cf0:	b7dd                	j	80003cd6 <namex+0x44>
      iunlockput(ip);
    80003cf2:	8552                	mv	a0,s4
    80003cf4:	00000097          	auipc	ra,0x0
    80003cf8:	c6c080e7          	jalr	-916(ra) # 80003960 <iunlockput>
      return 0;
    80003cfc:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cfe:	8552                	mv	a0,s4
    80003d00:	60e6                	ld	ra,88(sp)
    80003d02:	6446                	ld	s0,80(sp)
    80003d04:	64a6                	ld	s1,72(sp)
    80003d06:	6906                	ld	s2,64(sp)
    80003d08:	79e2                	ld	s3,56(sp)
    80003d0a:	7a42                	ld	s4,48(sp)
    80003d0c:	7aa2                	ld	s5,40(sp)
    80003d0e:	7b02                	ld	s6,32(sp)
    80003d10:	6be2                	ld	s7,24(sp)
    80003d12:	6c42                	ld	s8,16(sp)
    80003d14:	6ca2                	ld	s9,8(sp)
    80003d16:	6d02                	ld	s10,0(sp)
    80003d18:	6125                	addi	sp,sp,96
    80003d1a:	8082                	ret
      iunlock(ip);
    80003d1c:	8552                	mv	a0,s4
    80003d1e:	00000097          	auipc	ra,0x0
    80003d22:	aa2080e7          	jalr	-1374(ra) # 800037c0 <iunlock>
      return ip;
    80003d26:	bfe1                	j	80003cfe <namex+0x6c>
      iunlockput(ip);
    80003d28:	8552                	mv	a0,s4
    80003d2a:	00000097          	auipc	ra,0x0
    80003d2e:	c36080e7          	jalr	-970(ra) # 80003960 <iunlockput>
      return 0;
    80003d32:	8a4e                	mv	s4,s3
    80003d34:	b7e9                	j	80003cfe <namex+0x6c>
  len = path - s;
    80003d36:	40998633          	sub	a2,s3,s1
    80003d3a:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003d3e:	09acd863          	bge	s9,s10,80003dce <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003d42:	4639                	li	a2,14
    80003d44:	85a6                	mv	a1,s1
    80003d46:	8556                	mv	a0,s5
    80003d48:	ffffd097          	auipc	ra,0xffffd
    80003d4c:	fe0080e7          	jalr	-32(ra) # 80000d28 <memmove>
    80003d50:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d52:	0004c783          	lbu	a5,0(s1)
    80003d56:	01279763          	bne	a5,s2,80003d64 <namex+0xd2>
    path++;
    80003d5a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d5c:	0004c783          	lbu	a5,0(s1)
    80003d60:	ff278de3          	beq	a5,s2,80003d5a <namex+0xc8>
    ilock(ip);
    80003d64:	8552                	mv	a0,s4
    80003d66:	00000097          	auipc	ra,0x0
    80003d6a:	998080e7          	jalr	-1640(ra) # 800036fe <ilock>
    if(ip->type != T_DIR){
    80003d6e:	044a1783          	lh	a5,68(s4)
    80003d72:	f98790e3          	bne	a5,s8,80003cf2 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003d76:	000b0563          	beqz	s6,80003d80 <namex+0xee>
    80003d7a:	0004c783          	lbu	a5,0(s1)
    80003d7e:	dfd9                	beqz	a5,80003d1c <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d80:	865e                	mv	a2,s7
    80003d82:	85d6                	mv	a1,s5
    80003d84:	8552                	mv	a0,s4
    80003d86:	00000097          	auipc	ra,0x0
    80003d8a:	e5c080e7          	jalr	-420(ra) # 80003be2 <dirlookup>
    80003d8e:	89aa                	mv	s3,a0
    80003d90:	dd41                	beqz	a0,80003d28 <namex+0x96>
    iunlockput(ip);
    80003d92:	8552                	mv	a0,s4
    80003d94:	00000097          	auipc	ra,0x0
    80003d98:	bcc080e7          	jalr	-1076(ra) # 80003960 <iunlockput>
    ip = next;
    80003d9c:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d9e:	0004c783          	lbu	a5,0(s1)
    80003da2:	01279763          	bne	a5,s2,80003db0 <namex+0x11e>
    path++;
    80003da6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003da8:	0004c783          	lbu	a5,0(s1)
    80003dac:	ff278de3          	beq	a5,s2,80003da6 <namex+0x114>
  if(*path == 0)
    80003db0:	cb9d                	beqz	a5,80003de6 <namex+0x154>
  while(*path != '/' && *path != 0)
    80003db2:	0004c783          	lbu	a5,0(s1)
    80003db6:	89a6                	mv	s3,s1
  len = path - s;
    80003db8:	8d5e                	mv	s10,s7
    80003dba:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003dbc:	01278963          	beq	a5,s2,80003dce <namex+0x13c>
    80003dc0:	dbbd                	beqz	a5,80003d36 <namex+0xa4>
    path++;
    80003dc2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003dc4:	0009c783          	lbu	a5,0(s3)
    80003dc8:	ff279ce3          	bne	a5,s2,80003dc0 <namex+0x12e>
    80003dcc:	b7ad                	j	80003d36 <namex+0xa4>
    memmove(name, s, len);
    80003dce:	2601                	sext.w	a2,a2
    80003dd0:	85a6                	mv	a1,s1
    80003dd2:	8556                	mv	a0,s5
    80003dd4:	ffffd097          	auipc	ra,0xffffd
    80003dd8:	f54080e7          	jalr	-172(ra) # 80000d28 <memmove>
    name[len] = 0;
    80003ddc:	9d56                	add	s10,s10,s5
    80003dde:	000d0023          	sb	zero,0(s10)
    80003de2:	84ce                	mv	s1,s3
    80003de4:	b7bd                	j	80003d52 <namex+0xc0>
  if(nameiparent){
    80003de6:	f00b0ce3          	beqz	s6,80003cfe <namex+0x6c>
    iput(ip);
    80003dea:	8552                	mv	a0,s4
    80003dec:	00000097          	auipc	ra,0x0
    80003df0:	acc080e7          	jalr	-1332(ra) # 800038b8 <iput>
    return 0;
    80003df4:	4a01                	li	s4,0
    80003df6:	b721                	j	80003cfe <namex+0x6c>

0000000080003df8 <dirlink>:
{
    80003df8:	7139                	addi	sp,sp,-64
    80003dfa:	fc06                	sd	ra,56(sp)
    80003dfc:	f822                	sd	s0,48(sp)
    80003dfe:	f426                	sd	s1,40(sp)
    80003e00:	f04a                	sd	s2,32(sp)
    80003e02:	ec4e                	sd	s3,24(sp)
    80003e04:	e852                	sd	s4,16(sp)
    80003e06:	0080                	addi	s0,sp,64
    80003e08:	892a                	mv	s2,a0
    80003e0a:	8a2e                	mv	s4,a1
    80003e0c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e0e:	4601                	li	a2,0
    80003e10:	00000097          	auipc	ra,0x0
    80003e14:	dd2080e7          	jalr	-558(ra) # 80003be2 <dirlookup>
    80003e18:	e93d                	bnez	a0,80003e8e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e1a:	04c92483          	lw	s1,76(s2)
    80003e1e:	c49d                	beqz	s1,80003e4c <dirlink+0x54>
    80003e20:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e22:	4741                	li	a4,16
    80003e24:	86a6                	mv	a3,s1
    80003e26:	fc040613          	addi	a2,s0,-64
    80003e2a:	4581                	li	a1,0
    80003e2c:	854a                	mv	a0,s2
    80003e2e:	00000097          	auipc	ra,0x0
    80003e32:	b84080e7          	jalr	-1148(ra) # 800039b2 <readi>
    80003e36:	47c1                	li	a5,16
    80003e38:	06f51163          	bne	a0,a5,80003e9a <dirlink+0xa2>
    if(de.inum == 0)
    80003e3c:	fc045783          	lhu	a5,-64(s0)
    80003e40:	c791                	beqz	a5,80003e4c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e42:	24c1                	addiw	s1,s1,16
    80003e44:	04c92783          	lw	a5,76(s2)
    80003e48:	fcf4ede3          	bltu	s1,a5,80003e22 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e4c:	4639                	li	a2,14
    80003e4e:	85d2                	mv	a1,s4
    80003e50:	fc240513          	addi	a0,s0,-62
    80003e54:	ffffd097          	auipc	ra,0xffffd
    80003e58:	f84080e7          	jalr	-124(ra) # 80000dd8 <strncpy>
  de.inum = inum;
    80003e5c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e60:	4741                	li	a4,16
    80003e62:	86a6                	mv	a3,s1
    80003e64:	fc040613          	addi	a2,s0,-64
    80003e68:	4581                	li	a1,0
    80003e6a:	854a                	mv	a0,s2
    80003e6c:	00000097          	auipc	ra,0x0
    80003e70:	c3e080e7          	jalr	-962(ra) # 80003aaa <writei>
    80003e74:	872a                	mv	a4,a0
    80003e76:	47c1                	li	a5,16
  return 0;
    80003e78:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e7a:	02f71863          	bne	a4,a5,80003eaa <dirlink+0xb2>
}
    80003e7e:	70e2                	ld	ra,56(sp)
    80003e80:	7442                	ld	s0,48(sp)
    80003e82:	74a2                	ld	s1,40(sp)
    80003e84:	7902                	ld	s2,32(sp)
    80003e86:	69e2                	ld	s3,24(sp)
    80003e88:	6a42                	ld	s4,16(sp)
    80003e8a:	6121                	addi	sp,sp,64
    80003e8c:	8082                	ret
    iput(ip);
    80003e8e:	00000097          	auipc	ra,0x0
    80003e92:	a2a080e7          	jalr	-1494(ra) # 800038b8 <iput>
    return -1;
    80003e96:	557d                	li	a0,-1
    80003e98:	b7dd                	j	80003e7e <dirlink+0x86>
      panic("dirlink read");
    80003e9a:	00004517          	auipc	a0,0x4
    80003e9e:	79650513          	addi	a0,a0,1942 # 80008630 <syscalls+0x1e8>
    80003ea2:	ffffc097          	auipc	ra,0xffffc
    80003ea6:	698080e7          	jalr	1688(ra) # 8000053a <panic>
    panic("dirlink");
    80003eaa:	00005517          	auipc	a0,0x5
    80003eae:	89650513          	addi	a0,a0,-1898 # 80008740 <syscalls+0x2f8>
    80003eb2:	ffffc097          	auipc	ra,0xffffc
    80003eb6:	688080e7          	jalr	1672(ra) # 8000053a <panic>

0000000080003eba <namei>:

struct inode*
namei(char *path)
{
    80003eba:	1101                	addi	sp,sp,-32
    80003ebc:	ec06                	sd	ra,24(sp)
    80003ebe:	e822                	sd	s0,16(sp)
    80003ec0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ec2:	fe040613          	addi	a2,s0,-32
    80003ec6:	4581                	li	a1,0
    80003ec8:	00000097          	auipc	ra,0x0
    80003ecc:	dca080e7          	jalr	-566(ra) # 80003c92 <namex>
}
    80003ed0:	60e2                	ld	ra,24(sp)
    80003ed2:	6442                	ld	s0,16(sp)
    80003ed4:	6105                	addi	sp,sp,32
    80003ed6:	8082                	ret

0000000080003ed8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ed8:	1141                	addi	sp,sp,-16
    80003eda:	e406                	sd	ra,8(sp)
    80003edc:	e022                	sd	s0,0(sp)
    80003ede:	0800                	addi	s0,sp,16
    80003ee0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ee2:	4585                	li	a1,1
    80003ee4:	00000097          	auipc	ra,0x0
    80003ee8:	dae080e7          	jalr	-594(ra) # 80003c92 <namex>
}
    80003eec:	60a2                	ld	ra,8(sp)
    80003eee:	6402                	ld	s0,0(sp)
    80003ef0:	0141                	addi	sp,sp,16
    80003ef2:	8082                	ret

0000000080003ef4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ef4:	1101                	addi	sp,sp,-32
    80003ef6:	ec06                	sd	ra,24(sp)
    80003ef8:	e822                	sd	s0,16(sp)
    80003efa:	e426                	sd	s1,8(sp)
    80003efc:	e04a                	sd	s2,0(sp)
    80003efe:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f00:	0001d917          	auipc	s2,0x1d
    80003f04:	37090913          	addi	s2,s2,880 # 80021270 <log>
    80003f08:	01892583          	lw	a1,24(s2)
    80003f0c:	02892503          	lw	a0,40(s2)
    80003f10:	fffff097          	auipc	ra,0xfffff
    80003f14:	fec080e7          	jalr	-20(ra) # 80002efc <bread>
    80003f18:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f1a:	02c92683          	lw	a3,44(s2)
    80003f1e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f20:	02d05863          	blez	a3,80003f50 <write_head+0x5c>
    80003f24:	0001d797          	auipc	a5,0x1d
    80003f28:	37c78793          	addi	a5,a5,892 # 800212a0 <log+0x30>
    80003f2c:	05c50713          	addi	a4,a0,92
    80003f30:	36fd                	addiw	a3,a3,-1
    80003f32:	02069613          	slli	a2,a3,0x20
    80003f36:	01e65693          	srli	a3,a2,0x1e
    80003f3a:	0001d617          	auipc	a2,0x1d
    80003f3e:	36a60613          	addi	a2,a2,874 # 800212a4 <log+0x34>
    80003f42:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f44:	4390                	lw	a2,0(a5)
    80003f46:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f48:	0791                	addi	a5,a5,4
    80003f4a:	0711                	addi	a4,a4,4
    80003f4c:	fed79ce3          	bne	a5,a3,80003f44 <write_head+0x50>
  }
  bwrite(buf);
    80003f50:	8526                	mv	a0,s1
    80003f52:	fffff097          	auipc	ra,0xfffff
    80003f56:	09c080e7          	jalr	156(ra) # 80002fee <bwrite>
  brelse(buf);
    80003f5a:	8526                	mv	a0,s1
    80003f5c:	fffff097          	auipc	ra,0xfffff
    80003f60:	0d0080e7          	jalr	208(ra) # 8000302c <brelse>
}
    80003f64:	60e2                	ld	ra,24(sp)
    80003f66:	6442                	ld	s0,16(sp)
    80003f68:	64a2                	ld	s1,8(sp)
    80003f6a:	6902                	ld	s2,0(sp)
    80003f6c:	6105                	addi	sp,sp,32
    80003f6e:	8082                	ret

0000000080003f70 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f70:	0001d797          	auipc	a5,0x1d
    80003f74:	32c7a783          	lw	a5,812(a5) # 8002129c <log+0x2c>
    80003f78:	0af05d63          	blez	a5,80004032 <install_trans+0xc2>
{
    80003f7c:	7139                	addi	sp,sp,-64
    80003f7e:	fc06                	sd	ra,56(sp)
    80003f80:	f822                	sd	s0,48(sp)
    80003f82:	f426                	sd	s1,40(sp)
    80003f84:	f04a                	sd	s2,32(sp)
    80003f86:	ec4e                	sd	s3,24(sp)
    80003f88:	e852                	sd	s4,16(sp)
    80003f8a:	e456                	sd	s5,8(sp)
    80003f8c:	e05a                	sd	s6,0(sp)
    80003f8e:	0080                	addi	s0,sp,64
    80003f90:	8b2a                	mv	s6,a0
    80003f92:	0001da97          	auipc	s5,0x1d
    80003f96:	30ea8a93          	addi	s5,s5,782 # 800212a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f9a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f9c:	0001d997          	auipc	s3,0x1d
    80003fa0:	2d498993          	addi	s3,s3,724 # 80021270 <log>
    80003fa4:	a00d                	j	80003fc6 <install_trans+0x56>
    brelse(lbuf);
    80003fa6:	854a                	mv	a0,s2
    80003fa8:	fffff097          	auipc	ra,0xfffff
    80003fac:	084080e7          	jalr	132(ra) # 8000302c <brelse>
    brelse(dbuf);
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	fffff097          	auipc	ra,0xfffff
    80003fb6:	07a080e7          	jalr	122(ra) # 8000302c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fba:	2a05                	addiw	s4,s4,1
    80003fbc:	0a91                	addi	s5,s5,4
    80003fbe:	02c9a783          	lw	a5,44(s3)
    80003fc2:	04fa5e63          	bge	s4,a5,8000401e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fc6:	0189a583          	lw	a1,24(s3)
    80003fca:	014585bb          	addw	a1,a1,s4
    80003fce:	2585                	addiw	a1,a1,1
    80003fd0:	0289a503          	lw	a0,40(s3)
    80003fd4:	fffff097          	auipc	ra,0xfffff
    80003fd8:	f28080e7          	jalr	-216(ra) # 80002efc <bread>
    80003fdc:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fde:	000aa583          	lw	a1,0(s5)
    80003fe2:	0289a503          	lw	a0,40(s3)
    80003fe6:	fffff097          	auipc	ra,0xfffff
    80003fea:	f16080e7          	jalr	-234(ra) # 80002efc <bread>
    80003fee:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ff0:	40000613          	li	a2,1024
    80003ff4:	05890593          	addi	a1,s2,88
    80003ff8:	05850513          	addi	a0,a0,88
    80003ffc:	ffffd097          	auipc	ra,0xffffd
    80004000:	d2c080e7          	jalr	-724(ra) # 80000d28 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004004:	8526                	mv	a0,s1
    80004006:	fffff097          	auipc	ra,0xfffff
    8000400a:	fe8080e7          	jalr	-24(ra) # 80002fee <bwrite>
    if(recovering == 0)
    8000400e:	f80b1ce3          	bnez	s6,80003fa6 <install_trans+0x36>
      bunpin(dbuf);
    80004012:	8526                	mv	a0,s1
    80004014:	fffff097          	auipc	ra,0xfffff
    80004018:	0f2080e7          	jalr	242(ra) # 80003106 <bunpin>
    8000401c:	b769                	j	80003fa6 <install_trans+0x36>
}
    8000401e:	70e2                	ld	ra,56(sp)
    80004020:	7442                	ld	s0,48(sp)
    80004022:	74a2                	ld	s1,40(sp)
    80004024:	7902                	ld	s2,32(sp)
    80004026:	69e2                	ld	s3,24(sp)
    80004028:	6a42                	ld	s4,16(sp)
    8000402a:	6aa2                	ld	s5,8(sp)
    8000402c:	6b02                	ld	s6,0(sp)
    8000402e:	6121                	addi	sp,sp,64
    80004030:	8082                	ret
    80004032:	8082                	ret

0000000080004034 <initlog>:
{
    80004034:	7179                	addi	sp,sp,-48
    80004036:	f406                	sd	ra,40(sp)
    80004038:	f022                	sd	s0,32(sp)
    8000403a:	ec26                	sd	s1,24(sp)
    8000403c:	e84a                	sd	s2,16(sp)
    8000403e:	e44e                	sd	s3,8(sp)
    80004040:	1800                	addi	s0,sp,48
    80004042:	892a                	mv	s2,a0
    80004044:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004046:	0001d497          	auipc	s1,0x1d
    8000404a:	22a48493          	addi	s1,s1,554 # 80021270 <log>
    8000404e:	00004597          	auipc	a1,0x4
    80004052:	5f258593          	addi	a1,a1,1522 # 80008640 <syscalls+0x1f8>
    80004056:	8526                	mv	a0,s1
    80004058:	ffffd097          	auipc	ra,0xffffd
    8000405c:	ae8080e7          	jalr	-1304(ra) # 80000b40 <initlock>
  log.start = sb->logstart;
    80004060:	0149a583          	lw	a1,20(s3)
    80004064:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004066:	0109a783          	lw	a5,16(s3)
    8000406a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000406c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004070:	854a                	mv	a0,s2
    80004072:	fffff097          	auipc	ra,0xfffff
    80004076:	e8a080e7          	jalr	-374(ra) # 80002efc <bread>
  log.lh.n = lh->n;
    8000407a:	4d34                	lw	a3,88(a0)
    8000407c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000407e:	02d05663          	blez	a3,800040aa <initlog+0x76>
    80004082:	05c50793          	addi	a5,a0,92
    80004086:	0001d717          	auipc	a4,0x1d
    8000408a:	21a70713          	addi	a4,a4,538 # 800212a0 <log+0x30>
    8000408e:	36fd                	addiw	a3,a3,-1
    80004090:	02069613          	slli	a2,a3,0x20
    80004094:	01e65693          	srli	a3,a2,0x1e
    80004098:	06050613          	addi	a2,a0,96
    8000409c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000409e:	4390                	lw	a2,0(a5)
    800040a0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040a2:	0791                	addi	a5,a5,4
    800040a4:	0711                	addi	a4,a4,4
    800040a6:	fed79ce3          	bne	a5,a3,8000409e <initlog+0x6a>
  brelse(buf);
    800040aa:	fffff097          	auipc	ra,0xfffff
    800040ae:	f82080e7          	jalr	-126(ra) # 8000302c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800040b2:	4505                	li	a0,1
    800040b4:	00000097          	auipc	ra,0x0
    800040b8:	ebc080e7          	jalr	-324(ra) # 80003f70 <install_trans>
  log.lh.n = 0;
    800040bc:	0001d797          	auipc	a5,0x1d
    800040c0:	1e07a023          	sw	zero,480(a5) # 8002129c <log+0x2c>
  write_head(); // clear the log
    800040c4:	00000097          	auipc	ra,0x0
    800040c8:	e30080e7          	jalr	-464(ra) # 80003ef4 <write_head>
}
    800040cc:	70a2                	ld	ra,40(sp)
    800040ce:	7402                	ld	s0,32(sp)
    800040d0:	64e2                	ld	s1,24(sp)
    800040d2:	6942                	ld	s2,16(sp)
    800040d4:	69a2                	ld	s3,8(sp)
    800040d6:	6145                	addi	sp,sp,48
    800040d8:	8082                	ret

00000000800040da <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040da:	1101                	addi	sp,sp,-32
    800040dc:	ec06                	sd	ra,24(sp)
    800040de:	e822                	sd	s0,16(sp)
    800040e0:	e426                	sd	s1,8(sp)
    800040e2:	e04a                	sd	s2,0(sp)
    800040e4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040e6:	0001d517          	auipc	a0,0x1d
    800040ea:	18a50513          	addi	a0,a0,394 # 80021270 <log>
    800040ee:	ffffd097          	auipc	ra,0xffffd
    800040f2:	ae2080e7          	jalr	-1310(ra) # 80000bd0 <acquire>
  while(1){
    if(log.committing){
    800040f6:	0001d497          	auipc	s1,0x1d
    800040fa:	17a48493          	addi	s1,s1,378 # 80021270 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040fe:	4979                	li	s2,30
    80004100:	a039                	j	8000410e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004102:	85a6                	mv	a1,s1
    80004104:	8526                	mv	a0,s1
    80004106:	ffffe097          	auipc	ra,0xffffe
    8000410a:	f5c080e7          	jalr	-164(ra) # 80002062 <sleep>
    if(log.committing){
    8000410e:	50dc                	lw	a5,36(s1)
    80004110:	fbed                	bnez	a5,80004102 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004112:	5098                	lw	a4,32(s1)
    80004114:	2705                	addiw	a4,a4,1
    80004116:	0007069b          	sext.w	a3,a4
    8000411a:	0027179b          	slliw	a5,a4,0x2
    8000411e:	9fb9                	addw	a5,a5,a4
    80004120:	0017979b          	slliw	a5,a5,0x1
    80004124:	54d8                	lw	a4,44(s1)
    80004126:	9fb9                	addw	a5,a5,a4
    80004128:	00f95963          	bge	s2,a5,8000413a <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000412c:	85a6                	mv	a1,s1
    8000412e:	8526                	mv	a0,s1
    80004130:	ffffe097          	auipc	ra,0xffffe
    80004134:	f32080e7          	jalr	-206(ra) # 80002062 <sleep>
    80004138:	bfd9                	j	8000410e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000413a:	0001d517          	auipc	a0,0x1d
    8000413e:	13650513          	addi	a0,a0,310 # 80021270 <log>
    80004142:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004144:	ffffd097          	auipc	ra,0xffffd
    80004148:	b40080e7          	jalr	-1216(ra) # 80000c84 <release>
      break;
    }
  }
}
    8000414c:	60e2                	ld	ra,24(sp)
    8000414e:	6442                	ld	s0,16(sp)
    80004150:	64a2                	ld	s1,8(sp)
    80004152:	6902                	ld	s2,0(sp)
    80004154:	6105                	addi	sp,sp,32
    80004156:	8082                	ret

0000000080004158 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004158:	7139                	addi	sp,sp,-64
    8000415a:	fc06                	sd	ra,56(sp)
    8000415c:	f822                	sd	s0,48(sp)
    8000415e:	f426                	sd	s1,40(sp)
    80004160:	f04a                	sd	s2,32(sp)
    80004162:	ec4e                	sd	s3,24(sp)
    80004164:	e852                	sd	s4,16(sp)
    80004166:	e456                	sd	s5,8(sp)
    80004168:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000416a:	0001d497          	auipc	s1,0x1d
    8000416e:	10648493          	addi	s1,s1,262 # 80021270 <log>
    80004172:	8526                	mv	a0,s1
    80004174:	ffffd097          	auipc	ra,0xffffd
    80004178:	a5c080e7          	jalr	-1444(ra) # 80000bd0 <acquire>
  log.outstanding -= 1;
    8000417c:	509c                	lw	a5,32(s1)
    8000417e:	37fd                	addiw	a5,a5,-1
    80004180:	0007891b          	sext.w	s2,a5
    80004184:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004186:	50dc                	lw	a5,36(s1)
    80004188:	e7b9                	bnez	a5,800041d6 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000418a:	04091e63          	bnez	s2,800041e6 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000418e:	0001d497          	auipc	s1,0x1d
    80004192:	0e248493          	addi	s1,s1,226 # 80021270 <log>
    80004196:	4785                	li	a5,1
    80004198:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000419a:	8526                	mv	a0,s1
    8000419c:	ffffd097          	auipc	ra,0xffffd
    800041a0:	ae8080e7          	jalr	-1304(ra) # 80000c84 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041a4:	54dc                	lw	a5,44(s1)
    800041a6:	06f04763          	bgtz	a5,80004214 <end_op+0xbc>
    acquire(&log.lock);
    800041aa:	0001d497          	auipc	s1,0x1d
    800041ae:	0c648493          	addi	s1,s1,198 # 80021270 <log>
    800041b2:	8526                	mv	a0,s1
    800041b4:	ffffd097          	auipc	ra,0xffffd
    800041b8:	a1c080e7          	jalr	-1508(ra) # 80000bd0 <acquire>
    log.committing = 0;
    800041bc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800041c0:	8526                	mv	a0,s1
    800041c2:	ffffe097          	auipc	ra,0xffffe
    800041c6:	02c080e7          	jalr	44(ra) # 800021ee <wakeup>
    release(&log.lock);
    800041ca:	8526                	mv	a0,s1
    800041cc:	ffffd097          	auipc	ra,0xffffd
    800041d0:	ab8080e7          	jalr	-1352(ra) # 80000c84 <release>
}
    800041d4:	a03d                	j	80004202 <end_op+0xaa>
    panic("log.committing");
    800041d6:	00004517          	auipc	a0,0x4
    800041da:	47250513          	addi	a0,a0,1138 # 80008648 <syscalls+0x200>
    800041de:	ffffc097          	auipc	ra,0xffffc
    800041e2:	35c080e7          	jalr	860(ra) # 8000053a <panic>
    wakeup(&log);
    800041e6:	0001d497          	auipc	s1,0x1d
    800041ea:	08a48493          	addi	s1,s1,138 # 80021270 <log>
    800041ee:	8526                	mv	a0,s1
    800041f0:	ffffe097          	auipc	ra,0xffffe
    800041f4:	ffe080e7          	jalr	-2(ra) # 800021ee <wakeup>
  release(&log.lock);
    800041f8:	8526                	mv	a0,s1
    800041fa:	ffffd097          	auipc	ra,0xffffd
    800041fe:	a8a080e7          	jalr	-1398(ra) # 80000c84 <release>
}
    80004202:	70e2                	ld	ra,56(sp)
    80004204:	7442                	ld	s0,48(sp)
    80004206:	74a2                	ld	s1,40(sp)
    80004208:	7902                	ld	s2,32(sp)
    8000420a:	69e2                	ld	s3,24(sp)
    8000420c:	6a42                	ld	s4,16(sp)
    8000420e:	6aa2                	ld	s5,8(sp)
    80004210:	6121                	addi	sp,sp,64
    80004212:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004214:	0001da97          	auipc	s5,0x1d
    80004218:	08ca8a93          	addi	s5,s5,140 # 800212a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000421c:	0001da17          	auipc	s4,0x1d
    80004220:	054a0a13          	addi	s4,s4,84 # 80021270 <log>
    80004224:	018a2583          	lw	a1,24(s4)
    80004228:	012585bb          	addw	a1,a1,s2
    8000422c:	2585                	addiw	a1,a1,1
    8000422e:	028a2503          	lw	a0,40(s4)
    80004232:	fffff097          	auipc	ra,0xfffff
    80004236:	cca080e7          	jalr	-822(ra) # 80002efc <bread>
    8000423a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000423c:	000aa583          	lw	a1,0(s5)
    80004240:	028a2503          	lw	a0,40(s4)
    80004244:	fffff097          	auipc	ra,0xfffff
    80004248:	cb8080e7          	jalr	-840(ra) # 80002efc <bread>
    8000424c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000424e:	40000613          	li	a2,1024
    80004252:	05850593          	addi	a1,a0,88
    80004256:	05848513          	addi	a0,s1,88
    8000425a:	ffffd097          	auipc	ra,0xffffd
    8000425e:	ace080e7          	jalr	-1330(ra) # 80000d28 <memmove>
    bwrite(to);  // write the log
    80004262:	8526                	mv	a0,s1
    80004264:	fffff097          	auipc	ra,0xfffff
    80004268:	d8a080e7          	jalr	-630(ra) # 80002fee <bwrite>
    brelse(from);
    8000426c:	854e                	mv	a0,s3
    8000426e:	fffff097          	auipc	ra,0xfffff
    80004272:	dbe080e7          	jalr	-578(ra) # 8000302c <brelse>
    brelse(to);
    80004276:	8526                	mv	a0,s1
    80004278:	fffff097          	auipc	ra,0xfffff
    8000427c:	db4080e7          	jalr	-588(ra) # 8000302c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004280:	2905                	addiw	s2,s2,1
    80004282:	0a91                	addi	s5,s5,4
    80004284:	02ca2783          	lw	a5,44(s4)
    80004288:	f8f94ee3          	blt	s2,a5,80004224 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000428c:	00000097          	auipc	ra,0x0
    80004290:	c68080e7          	jalr	-920(ra) # 80003ef4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004294:	4501                	li	a0,0
    80004296:	00000097          	auipc	ra,0x0
    8000429a:	cda080e7          	jalr	-806(ra) # 80003f70 <install_trans>
    log.lh.n = 0;
    8000429e:	0001d797          	auipc	a5,0x1d
    800042a2:	fe07af23          	sw	zero,-2(a5) # 8002129c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042a6:	00000097          	auipc	ra,0x0
    800042aa:	c4e080e7          	jalr	-946(ra) # 80003ef4 <write_head>
    800042ae:	bdf5                	j	800041aa <end_op+0x52>

00000000800042b0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042b0:	1101                	addi	sp,sp,-32
    800042b2:	ec06                	sd	ra,24(sp)
    800042b4:	e822                	sd	s0,16(sp)
    800042b6:	e426                	sd	s1,8(sp)
    800042b8:	e04a                	sd	s2,0(sp)
    800042ba:	1000                	addi	s0,sp,32
    800042bc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800042be:	0001d917          	auipc	s2,0x1d
    800042c2:	fb290913          	addi	s2,s2,-78 # 80021270 <log>
    800042c6:	854a                	mv	a0,s2
    800042c8:	ffffd097          	auipc	ra,0xffffd
    800042cc:	908080e7          	jalr	-1784(ra) # 80000bd0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042d0:	02c92603          	lw	a2,44(s2)
    800042d4:	47f5                	li	a5,29
    800042d6:	06c7c563          	blt	a5,a2,80004340 <log_write+0x90>
    800042da:	0001d797          	auipc	a5,0x1d
    800042de:	fb27a783          	lw	a5,-78(a5) # 8002128c <log+0x1c>
    800042e2:	37fd                	addiw	a5,a5,-1
    800042e4:	04f65e63          	bge	a2,a5,80004340 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042e8:	0001d797          	auipc	a5,0x1d
    800042ec:	fa87a783          	lw	a5,-88(a5) # 80021290 <log+0x20>
    800042f0:	06f05063          	blez	a5,80004350 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042f4:	4781                	li	a5,0
    800042f6:	06c05563          	blez	a2,80004360 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042fa:	44cc                	lw	a1,12(s1)
    800042fc:	0001d717          	auipc	a4,0x1d
    80004300:	fa470713          	addi	a4,a4,-92 # 800212a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004304:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004306:	4314                	lw	a3,0(a4)
    80004308:	04b68c63          	beq	a3,a1,80004360 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000430c:	2785                	addiw	a5,a5,1
    8000430e:	0711                	addi	a4,a4,4
    80004310:	fef61be3          	bne	a2,a5,80004306 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004314:	0621                	addi	a2,a2,8
    80004316:	060a                	slli	a2,a2,0x2
    80004318:	0001d797          	auipc	a5,0x1d
    8000431c:	f5878793          	addi	a5,a5,-168 # 80021270 <log>
    80004320:	97b2                	add	a5,a5,a2
    80004322:	44d8                	lw	a4,12(s1)
    80004324:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004326:	8526                	mv	a0,s1
    80004328:	fffff097          	auipc	ra,0xfffff
    8000432c:	da2080e7          	jalr	-606(ra) # 800030ca <bpin>
    log.lh.n++;
    80004330:	0001d717          	auipc	a4,0x1d
    80004334:	f4070713          	addi	a4,a4,-192 # 80021270 <log>
    80004338:	575c                	lw	a5,44(a4)
    8000433a:	2785                	addiw	a5,a5,1
    8000433c:	d75c                	sw	a5,44(a4)
    8000433e:	a82d                	j	80004378 <log_write+0xc8>
    panic("too big a transaction");
    80004340:	00004517          	auipc	a0,0x4
    80004344:	31850513          	addi	a0,a0,792 # 80008658 <syscalls+0x210>
    80004348:	ffffc097          	auipc	ra,0xffffc
    8000434c:	1f2080e7          	jalr	498(ra) # 8000053a <panic>
    panic("log_write outside of trans");
    80004350:	00004517          	auipc	a0,0x4
    80004354:	32050513          	addi	a0,a0,800 # 80008670 <syscalls+0x228>
    80004358:	ffffc097          	auipc	ra,0xffffc
    8000435c:	1e2080e7          	jalr	482(ra) # 8000053a <panic>
  log.lh.block[i] = b->blockno;
    80004360:	00878693          	addi	a3,a5,8
    80004364:	068a                	slli	a3,a3,0x2
    80004366:	0001d717          	auipc	a4,0x1d
    8000436a:	f0a70713          	addi	a4,a4,-246 # 80021270 <log>
    8000436e:	9736                	add	a4,a4,a3
    80004370:	44d4                	lw	a3,12(s1)
    80004372:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004374:	faf609e3          	beq	a2,a5,80004326 <log_write+0x76>
  }
  release(&log.lock);
    80004378:	0001d517          	auipc	a0,0x1d
    8000437c:	ef850513          	addi	a0,a0,-264 # 80021270 <log>
    80004380:	ffffd097          	auipc	ra,0xffffd
    80004384:	904080e7          	jalr	-1788(ra) # 80000c84 <release>
}
    80004388:	60e2                	ld	ra,24(sp)
    8000438a:	6442                	ld	s0,16(sp)
    8000438c:	64a2                	ld	s1,8(sp)
    8000438e:	6902                	ld	s2,0(sp)
    80004390:	6105                	addi	sp,sp,32
    80004392:	8082                	ret

0000000080004394 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004394:	1101                	addi	sp,sp,-32
    80004396:	ec06                	sd	ra,24(sp)
    80004398:	e822                	sd	s0,16(sp)
    8000439a:	e426                	sd	s1,8(sp)
    8000439c:	e04a                	sd	s2,0(sp)
    8000439e:	1000                	addi	s0,sp,32
    800043a0:	84aa                	mv	s1,a0
    800043a2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043a4:	00004597          	auipc	a1,0x4
    800043a8:	2ec58593          	addi	a1,a1,748 # 80008690 <syscalls+0x248>
    800043ac:	0521                	addi	a0,a0,8
    800043ae:	ffffc097          	auipc	ra,0xffffc
    800043b2:	792080e7          	jalr	1938(ra) # 80000b40 <initlock>
  lk->name = name;
    800043b6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043ba:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043be:	0204a423          	sw	zero,40(s1)
}
    800043c2:	60e2                	ld	ra,24(sp)
    800043c4:	6442                	ld	s0,16(sp)
    800043c6:	64a2                	ld	s1,8(sp)
    800043c8:	6902                	ld	s2,0(sp)
    800043ca:	6105                	addi	sp,sp,32
    800043cc:	8082                	ret

00000000800043ce <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043ce:	1101                	addi	sp,sp,-32
    800043d0:	ec06                	sd	ra,24(sp)
    800043d2:	e822                	sd	s0,16(sp)
    800043d4:	e426                	sd	s1,8(sp)
    800043d6:	e04a                	sd	s2,0(sp)
    800043d8:	1000                	addi	s0,sp,32
    800043da:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043dc:	00850913          	addi	s2,a0,8
    800043e0:	854a                	mv	a0,s2
    800043e2:	ffffc097          	auipc	ra,0xffffc
    800043e6:	7ee080e7          	jalr	2030(ra) # 80000bd0 <acquire>
  while (lk->locked) {
    800043ea:	409c                	lw	a5,0(s1)
    800043ec:	cb89                	beqz	a5,800043fe <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043ee:	85ca                	mv	a1,s2
    800043f0:	8526                	mv	a0,s1
    800043f2:	ffffe097          	auipc	ra,0xffffe
    800043f6:	c70080e7          	jalr	-912(ra) # 80002062 <sleep>
  while (lk->locked) {
    800043fa:	409c                	lw	a5,0(s1)
    800043fc:	fbed                	bnez	a5,800043ee <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043fe:	4785                	li	a5,1
    80004400:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004402:	ffffd097          	auipc	ra,0xffffd
    80004406:	59c080e7          	jalr	1436(ra) # 8000199e <myproc>
    8000440a:	591c                	lw	a5,48(a0)
    8000440c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000440e:	854a                	mv	a0,s2
    80004410:	ffffd097          	auipc	ra,0xffffd
    80004414:	874080e7          	jalr	-1932(ra) # 80000c84 <release>
}
    80004418:	60e2                	ld	ra,24(sp)
    8000441a:	6442                	ld	s0,16(sp)
    8000441c:	64a2                	ld	s1,8(sp)
    8000441e:	6902                	ld	s2,0(sp)
    80004420:	6105                	addi	sp,sp,32
    80004422:	8082                	ret

0000000080004424 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004424:	1101                	addi	sp,sp,-32
    80004426:	ec06                	sd	ra,24(sp)
    80004428:	e822                	sd	s0,16(sp)
    8000442a:	e426                	sd	s1,8(sp)
    8000442c:	e04a                	sd	s2,0(sp)
    8000442e:	1000                	addi	s0,sp,32
    80004430:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004432:	00850913          	addi	s2,a0,8
    80004436:	854a                	mv	a0,s2
    80004438:	ffffc097          	auipc	ra,0xffffc
    8000443c:	798080e7          	jalr	1944(ra) # 80000bd0 <acquire>
  lk->locked = 0;
    80004440:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004444:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004448:	8526                	mv	a0,s1
    8000444a:	ffffe097          	auipc	ra,0xffffe
    8000444e:	da4080e7          	jalr	-604(ra) # 800021ee <wakeup>
  release(&lk->lk);
    80004452:	854a                	mv	a0,s2
    80004454:	ffffd097          	auipc	ra,0xffffd
    80004458:	830080e7          	jalr	-2000(ra) # 80000c84 <release>
}
    8000445c:	60e2                	ld	ra,24(sp)
    8000445e:	6442                	ld	s0,16(sp)
    80004460:	64a2                	ld	s1,8(sp)
    80004462:	6902                	ld	s2,0(sp)
    80004464:	6105                	addi	sp,sp,32
    80004466:	8082                	ret

0000000080004468 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004468:	7179                	addi	sp,sp,-48
    8000446a:	f406                	sd	ra,40(sp)
    8000446c:	f022                	sd	s0,32(sp)
    8000446e:	ec26                	sd	s1,24(sp)
    80004470:	e84a                	sd	s2,16(sp)
    80004472:	e44e                	sd	s3,8(sp)
    80004474:	1800                	addi	s0,sp,48
    80004476:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004478:	00850913          	addi	s2,a0,8
    8000447c:	854a                	mv	a0,s2
    8000447e:	ffffc097          	auipc	ra,0xffffc
    80004482:	752080e7          	jalr	1874(ra) # 80000bd0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004486:	409c                	lw	a5,0(s1)
    80004488:	ef99                	bnez	a5,800044a6 <holdingsleep+0x3e>
    8000448a:	4481                	li	s1,0
  release(&lk->lk);
    8000448c:	854a                	mv	a0,s2
    8000448e:	ffffc097          	auipc	ra,0xffffc
    80004492:	7f6080e7          	jalr	2038(ra) # 80000c84 <release>
  return r;
}
    80004496:	8526                	mv	a0,s1
    80004498:	70a2                	ld	ra,40(sp)
    8000449a:	7402                	ld	s0,32(sp)
    8000449c:	64e2                	ld	s1,24(sp)
    8000449e:	6942                	ld	s2,16(sp)
    800044a0:	69a2                	ld	s3,8(sp)
    800044a2:	6145                	addi	sp,sp,48
    800044a4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044a6:	0284a983          	lw	s3,40(s1)
    800044aa:	ffffd097          	auipc	ra,0xffffd
    800044ae:	4f4080e7          	jalr	1268(ra) # 8000199e <myproc>
    800044b2:	5904                	lw	s1,48(a0)
    800044b4:	413484b3          	sub	s1,s1,s3
    800044b8:	0014b493          	seqz	s1,s1
    800044bc:	bfc1                	j	8000448c <holdingsleep+0x24>

00000000800044be <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044be:	1141                	addi	sp,sp,-16
    800044c0:	e406                	sd	ra,8(sp)
    800044c2:	e022                	sd	s0,0(sp)
    800044c4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044c6:	00004597          	auipc	a1,0x4
    800044ca:	1da58593          	addi	a1,a1,474 # 800086a0 <syscalls+0x258>
    800044ce:	0001d517          	auipc	a0,0x1d
    800044d2:	eea50513          	addi	a0,a0,-278 # 800213b8 <ftable>
    800044d6:	ffffc097          	auipc	ra,0xffffc
    800044da:	66a080e7          	jalr	1642(ra) # 80000b40 <initlock>
}
    800044de:	60a2                	ld	ra,8(sp)
    800044e0:	6402                	ld	s0,0(sp)
    800044e2:	0141                	addi	sp,sp,16
    800044e4:	8082                	ret

00000000800044e6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044e6:	1101                	addi	sp,sp,-32
    800044e8:	ec06                	sd	ra,24(sp)
    800044ea:	e822                	sd	s0,16(sp)
    800044ec:	e426                	sd	s1,8(sp)
    800044ee:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044f0:	0001d517          	auipc	a0,0x1d
    800044f4:	ec850513          	addi	a0,a0,-312 # 800213b8 <ftable>
    800044f8:	ffffc097          	auipc	ra,0xffffc
    800044fc:	6d8080e7          	jalr	1752(ra) # 80000bd0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004500:	0001d497          	auipc	s1,0x1d
    80004504:	ed048493          	addi	s1,s1,-304 # 800213d0 <ftable+0x18>
    80004508:	0001e717          	auipc	a4,0x1e
    8000450c:	e6870713          	addi	a4,a4,-408 # 80022370 <ftable+0xfb8>
    if(f->ref == 0){
    80004510:	40dc                	lw	a5,4(s1)
    80004512:	cf99                	beqz	a5,80004530 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004514:	02848493          	addi	s1,s1,40
    80004518:	fee49ce3          	bne	s1,a4,80004510 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000451c:	0001d517          	auipc	a0,0x1d
    80004520:	e9c50513          	addi	a0,a0,-356 # 800213b8 <ftable>
    80004524:	ffffc097          	auipc	ra,0xffffc
    80004528:	760080e7          	jalr	1888(ra) # 80000c84 <release>
  return 0;
    8000452c:	4481                	li	s1,0
    8000452e:	a819                	j	80004544 <filealloc+0x5e>
      f->ref = 1;
    80004530:	4785                	li	a5,1
    80004532:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004534:	0001d517          	auipc	a0,0x1d
    80004538:	e8450513          	addi	a0,a0,-380 # 800213b8 <ftable>
    8000453c:	ffffc097          	auipc	ra,0xffffc
    80004540:	748080e7          	jalr	1864(ra) # 80000c84 <release>
}
    80004544:	8526                	mv	a0,s1
    80004546:	60e2                	ld	ra,24(sp)
    80004548:	6442                	ld	s0,16(sp)
    8000454a:	64a2                	ld	s1,8(sp)
    8000454c:	6105                	addi	sp,sp,32
    8000454e:	8082                	ret

0000000080004550 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004550:	1101                	addi	sp,sp,-32
    80004552:	ec06                	sd	ra,24(sp)
    80004554:	e822                	sd	s0,16(sp)
    80004556:	e426                	sd	s1,8(sp)
    80004558:	1000                	addi	s0,sp,32
    8000455a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000455c:	0001d517          	auipc	a0,0x1d
    80004560:	e5c50513          	addi	a0,a0,-420 # 800213b8 <ftable>
    80004564:	ffffc097          	auipc	ra,0xffffc
    80004568:	66c080e7          	jalr	1644(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    8000456c:	40dc                	lw	a5,4(s1)
    8000456e:	02f05263          	blez	a5,80004592 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004572:	2785                	addiw	a5,a5,1
    80004574:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004576:	0001d517          	auipc	a0,0x1d
    8000457a:	e4250513          	addi	a0,a0,-446 # 800213b8 <ftable>
    8000457e:	ffffc097          	auipc	ra,0xffffc
    80004582:	706080e7          	jalr	1798(ra) # 80000c84 <release>
  return f;
}
    80004586:	8526                	mv	a0,s1
    80004588:	60e2                	ld	ra,24(sp)
    8000458a:	6442                	ld	s0,16(sp)
    8000458c:	64a2                	ld	s1,8(sp)
    8000458e:	6105                	addi	sp,sp,32
    80004590:	8082                	ret
    panic("filedup");
    80004592:	00004517          	auipc	a0,0x4
    80004596:	11650513          	addi	a0,a0,278 # 800086a8 <syscalls+0x260>
    8000459a:	ffffc097          	auipc	ra,0xffffc
    8000459e:	fa0080e7          	jalr	-96(ra) # 8000053a <panic>

00000000800045a2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045a2:	7139                	addi	sp,sp,-64
    800045a4:	fc06                	sd	ra,56(sp)
    800045a6:	f822                	sd	s0,48(sp)
    800045a8:	f426                	sd	s1,40(sp)
    800045aa:	f04a                	sd	s2,32(sp)
    800045ac:	ec4e                	sd	s3,24(sp)
    800045ae:	e852                	sd	s4,16(sp)
    800045b0:	e456                	sd	s5,8(sp)
    800045b2:	0080                	addi	s0,sp,64
    800045b4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045b6:	0001d517          	auipc	a0,0x1d
    800045ba:	e0250513          	addi	a0,a0,-510 # 800213b8 <ftable>
    800045be:	ffffc097          	auipc	ra,0xffffc
    800045c2:	612080e7          	jalr	1554(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    800045c6:	40dc                	lw	a5,4(s1)
    800045c8:	06f05163          	blez	a5,8000462a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800045cc:	37fd                	addiw	a5,a5,-1
    800045ce:	0007871b          	sext.w	a4,a5
    800045d2:	c0dc                	sw	a5,4(s1)
    800045d4:	06e04363          	bgtz	a4,8000463a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045d8:	0004a903          	lw	s2,0(s1)
    800045dc:	0094ca83          	lbu	s5,9(s1)
    800045e0:	0104ba03          	ld	s4,16(s1)
    800045e4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045e8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045ec:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045f0:	0001d517          	auipc	a0,0x1d
    800045f4:	dc850513          	addi	a0,a0,-568 # 800213b8 <ftable>
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	68c080e7          	jalr	1676(ra) # 80000c84 <release>

  if(ff.type == FD_PIPE){
    80004600:	4785                	li	a5,1
    80004602:	04f90d63          	beq	s2,a5,8000465c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004606:	3979                	addiw	s2,s2,-2
    80004608:	4785                	li	a5,1
    8000460a:	0527e063          	bltu	a5,s2,8000464a <fileclose+0xa8>
    begin_op();
    8000460e:	00000097          	auipc	ra,0x0
    80004612:	acc080e7          	jalr	-1332(ra) # 800040da <begin_op>
    iput(ff.ip);
    80004616:	854e                	mv	a0,s3
    80004618:	fffff097          	auipc	ra,0xfffff
    8000461c:	2a0080e7          	jalr	672(ra) # 800038b8 <iput>
    end_op();
    80004620:	00000097          	auipc	ra,0x0
    80004624:	b38080e7          	jalr	-1224(ra) # 80004158 <end_op>
    80004628:	a00d                	j	8000464a <fileclose+0xa8>
    panic("fileclose");
    8000462a:	00004517          	auipc	a0,0x4
    8000462e:	08650513          	addi	a0,a0,134 # 800086b0 <syscalls+0x268>
    80004632:	ffffc097          	auipc	ra,0xffffc
    80004636:	f08080e7          	jalr	-248(ra) # 8000053a <panic>
    release(&ftable.lock);
    8000463a:	0001d517          	auipc	a0,0x1d
    8000463e:	d7e50513          	addi	a0,a0,-642 # 800213b8 <ftable>
    80004642:	ffffc097          	auipc	ra,0xffffc
    80004646:	642080e7          	jalr	1602(ra) # 80000c84 <release>
  }
}
    8000464a:	70e2                	ld	ra,56(sp)
    8000464c:	7442                	ld	s0,48(sp)
    8000464e:	74a2                	ld	s1,40(sp)
    80004650:	7902                	ld	s2,32(sp)
    80004652:	69e2                	ld	s3,24(sp)
    80004654:	6a42                	ld	s4,16(sp)
    80004656:	6aa2                	ld	s5,8(sp)
    80004658:	6121                	addi	sp,sp,64
    8000465a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000465c:	85d6                	mv	a1,s5
    8000465e:	8552                	mv	a0,s4
    80004660:	00000097          	auipc	ra,0x0
    80004664:	34c080e7          	jalr	844(ra) # 800049ac <pipeclose>
    80004668:	b7cd                	j	8000464a <fileclose+0xa8>

000000008000466a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000466a:	715d                	addi	sp,sp,-80
    8000466c:	e486                	sd	ra,72(sp)
    8000466e:	e0a2                	sd	s0,64(sp)
    80004670:	fc26                	sd	s1,56(sp)
    80004672:	f84a                	sd	s2,48(sp)
    80004674:	f44e                	sd	s3,40(sp)
    80004676:	0880                	addi	s0,sp,80
    80004678:	84aa                	mv	s1,a0
    8000467a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000467c:	ffffd097          	auipc	ra,0xffffd
    80004680:	322080e7          	jalr	802(ra) # 8000199e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004684:	409c                	lw	a5,0(s1)
    80004686:	37f9                	addiw	a5,a5,-2
    80004688:	4705                	li	a4,1
    8000468a:	04f76763          	bltu	a4,a5,800046d8 <filestat+0x6e>
    8000468e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004690:	6c88                	ld	a0,24(s1)
    80004692:	fffff097          	auipc	ra,0xfffff
    80004696:	06c080e7          	jalr	108(ra) # 800036fe <ilock>
    stati(f->ip, &st);
    8000469a:	fb840593          	addi	a1,s0,-72
    8000469e:	6c88                	ld	a0,24(s1)
    800046a0:	fffff097          	auipc	ra,0xfffff
    800046a4:	2e8080e7          	jalr	744(ra) # 80003988 <stati>
    iunlock(f->ip);
    800046a8:	6c88                	ld	a0,24(s1)
    800046aa:	fffff097          	auipc	ra,0xfffff
    800046ae:	116080e7          	jalr	278(ra) # 800037c0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046b2:	46e1                	li	a3,24
    800046b4:	fb840613          	addi	a2,s0,-72
    800046b8:	85ce                	mv	a1,s3
    800046ba:	05093503          	ld	a0,80(s2)
    800046be:	ffffd097          	auipc	ra,0xffffd
    800046c2:	fa4080e7          	jalr	-92(ra) # 80001662 <copyout>
    800046c6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800046ca:	60a6                	ld	ra,72(sp)
    800046cc:	6406                	ld	s0,64(sp)
    800046ce:	74e2                	ld	s1,56(sp)
    800046d0:	7942                	ld	s2,48(sp)
    800046d2:	79a2                	ld	s3,40(sp)
    800046d4:	6161                	addi	sp,sp,80
    800046d6:	8082                	ret
  return -1;
    800046d8:	557d                	li	a0,-1
    800046da:	bfc5                	j	800046ca <filestat+0x60>

00000000800046dc <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046dc:	7179                	addi	sp,sp,-48
    800046de:	f406                	sd	ra,40(sp)
    800046e0:	f022                	sd	s0,32(sp)
    800046e2:	ec26                	sd	s1,24(sp)
    800046e4:	e84a                	sd	s2,16(sp)
    800046e6:	e44e                	sd	s3,8(sp)
    800046e8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046ea:	00854783          	lbu	a5,8(a0)
    800046ee:	c3d5                	beqz	a5,80004792 <fileread+0xb6>
    800046f0:	84aa                	mv	s1,a0
    800046f2:	89ae                	mv	s3,a1
    800046f4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046f6:	411c                	lw	a5,0(a0)
    800046f8:	4705                	li	a4,1
    800046fa:	04e78963          	beq	a5,a4,8000474c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046fe:	470d                	li	a4,3
    80004700:	04e78d63          	beq	a5,a4,8000475a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004704:	4709                	li	a4,2
    80004706:	06e79e63          	bne	a5,a4,80004782 <fileread+0xa6>
    ilock(f->ip);
    8000470a:	6d08                	ld	a0,24(a0)
    8000470c:	fffff097          	auipc	ra,0xfffff
    80004710:	ff2080e7          	jalr	-14(ra) # 800036fe <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004714:	874a                	mv	a4,s2
    80004716:	5094                	lw	a3,32(s1)
    80004718:	864e                	mv	a2,s3
    8000471a:	4585                	li	a1,1
    8000471c:	6c88                	ld	a0,24(s1)
    8000471e:	fffff097          	auipc	ra,0xfffff
    80004722:	294080e7          	jalr	660(ra) # 800039b2 <readi>
    80004726:	892a                	mv	s2,a0
    80004728:	00a05563          	blez	a0,80004732 <fileread+0x56>
      f->off += r;
    8000472c:	509c                	lw	a5,32(s1)
    8000472e:	9fa9                	addw	a5,a5,a0
    80004730:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004732:	6c88                	ld	a0,24(s1)
    80004734:	fffff097          	auipc	ra,0xfffff
    80004738:	08c080e7          	jalr	140(ra) # 800037c0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000473c:	854a                	mv	a0,s2
    8000473e:	70a2                	ld	ra,40(sp)
    80004740:	7402                	ld	s0,32(sp)
    80004742:	64e2                	ld	s1,24(sp)
    80004744:	6942                	ld	s2,16(sp)
    80004746:	69a2                	ld	s3,8(sp)
    80004748:	6145                	addi	sp,sp,48
    8000474a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000474c:	6908                	ld	a0,16(a0)
    8000474e:	00000097          	auipc	ra,0x0
    80004752:	3c0080e7          	jalr	960(ra) # 80004b0e <piperead>
    80004756:	892a                	mv	s2,a0
    80004758:	b7d5                	j	8000473c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000475a:	02451783          	lh	a5,36(a0)
    8000475e:	03079693          	slli	a3,a5,0x30
    80004762:	92c1                	srli	a3,a3,0x30
    80004764:	4725                	li	a4,9
    80004766:	02d76863          	bltu	a4,a3,80004796 <fileread+0xba>
    8000476a:	0792                	slli	a5,a5,0x4
    8000476c:	0001d717          	auipc	a4,0x1d
    80004770:	bac70713          	addi	a4,a4,-1108 # 80021318 <devsw>
    80004774:	97ba                	add	a5,a5,a4
    80004776:	639c                	ld	a5,0(a5)
    80004778:	c38d                	beqz	a5,8000479a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000477a:	4505                	li	a0,1
    8000477c:	9782                	jalr	a5
    8000477e:	892a                	mv	s2,a0
    80004780:	bf75                	j	8000473c <fileread+0x60>
    panic("fileread");
    80004782:	00004517          	auipc	a0,0x4
    80004786:	f3e50513          	addi	a0,a0,-194 # 800086c0 <syscalls+0x278>
    8000478a:	ffffc097          	auipc	ra,0xffffc
    8000478e:	db0080e7          	jalr	-592(ra) # 8000053a <panic>
    return -1;
    80004792:	597d                	li	s2,-1
    80004794:	b765                	j	8000473c <fileread+0x60>
      return -1;
    80004796:	597d                	li	s2,-1
    80004798:	b755                	j	8000473c <fileread+0x60>
    8000479a:	597d                	li	s2,-1
    8000479c:	b745                	j	8000473c <fileread+0x60>

000000008000479e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000479e:	715d                	addi	sp,sp,-80
    800047a0:	e486                	sd	ra,72(sp)
    800047a2:	e0a2                	sd	s0,64(sp)
    800047a4:	fc26                	sd	s1,56(sp)
    800047a6:	f84a                	sd	s2,48(sp)
    800047a8:	f44e                	sd	s3,40(sp)
    800047aa:	f052                	sd	s4,32(sp)
    800047ac:	ec56                	sd	s5,24(sp)
    800047ae:	e85a                	sd	s6,16(sp)
    800047b0:	e45e                	sd	s7,8(sp)
    800047b2:	e062                	sd	s8,0(sp)
    800047b4:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800047b6:	00954783          	lbu	a5,9(a0)
    800047ba:	10078663          	beqz	a5,800048c6 <filewrite+0x128>
    800047be:	892a                	mv	s2,a0
    800047c0:	8b2e                	mv	s6,a1
    800047c2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047c4:	411c                	lw	a5,0(a0)
    800047c6:	4705                	li	a4,1
    800047c8:	02e78263          	beq	a5,a4,800047ec <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047cc:	470d                	li	a4,3
    800047ce:	02e78663          	beq	a5,a4,800047fa <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047d2:	4709                	li	a4,2
    800047d4:	0ee79163          	bne	a5,a4,800048b6 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047d8:	0ac05d63          	blez	a2,80004892 <filewrite+0xf4>
    int i = 0;
    800047dc:	4981                	li	s3,0
    800047de:	6b85                	lui	s7,0x1
    800047e0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800047e4:	6c05                	lui	s8,0x1
    800047e6:	c00c0c1b          	addiw	s8,s8,-1024
    800047ea:	a861                	j	80004882 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800047ec:	6908                	ld	a0,16(a0)
    800047ee:	00000097          	auipc	ra,0x0
    800047f2:	22e080e7          	jalr	558(ra) # 80004a1c <pipewrite>
    800047f6:	8a2a                	mv	s4,a0
    800047f8:	a045                	j	80004898 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047fa:	02451783          	lh	a5,36(a0)
    800047fe:	03079693          	slli	a3,a5,0x30
    80004802:	92c1                	srli	a3,a3,0x30
    80004804:	4725                	li	a4,9
    80004806:	0cd76263          	bltu	a4,a3,800048ca <filewrite+0x12c>
    8000480a:	0792                	slli	a5,a5,0x4
    8000480c:	0001d717          	auipc	a4,0x1d
    80004810:	b0c70713          	addi	a4,a4,-1268 # 80021318 <devsw>
    80004814:	97ba                	add	a5,a5,a4
    80004816:	679c                	ld	a5,8(a5)
    80004818:	cbdd                	beqz	a5,800048ce <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000481a:	4505                	li	a0,1
    8000481c:	9782                	jalr	a5
    8000481e:	8a2a                	mv	s4,a0
    80004820:	a8a5                	j	80004898 <filewrite+0xfa>
    80004822:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004826:	00000097          	auipc	ra,0x0
    8000482a:	8b4080e7          	jalr	-1868(ra) # 800040da <begin_op>
      ilock(f->ip);
    8000482e:	01893503          	ld	a0,24(s2)
    80004832:	fffff097          	auipc	ra,0xfffff
    80004836:	ecc080e7          	jalr	-308(ra) # 800036fe <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000483a:	8756                	mv	a4,s5
    8000483c:	02092683          	lw	a3,32(s2)
    80004840:	01698633          	add	a2,s3,s6
    80004844:	4585                	li	a1,1
    80004846:	01893503          	ld	a0,24(s2)
    8000484a:	fffff097          	auipc	ra,0xfffff
    8000484e:	260080e7          	jalr	608(ra) # 80003aaa <writei>
    80004852:	84aa                	mv	s1,a0
    80004854:	00a05763          	blez	a0,80004862 <filewrite+0xc4>
        f->off += r;
    80004858:	02092783          	lw	a5,32(s2)
    8000485c:	9fa9                	addw	a5,a5,a0
    8000485e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004862:	01893503          	ld	a0,24(s2)
    80004866:	fffff097          	auipc	ra,0xfffff
    8000486a:	f5a080e7          	jalr	-166(ra) # 800037c0 <iunlock>
      end_op();
    8000486e:	00000097          	auipc	ra,0x0
    80004872:	8ea080e7          	jalr	-1814(ra) # 80004158 <end_op>

      if(r != n1){
    80004876:	009a9f63          	bne	s5,s1,80004894 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000487a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000487e:	0149db63          	bge	s3,s4,80004894 <filewrite+0xf6>
      int n1 = n - i;
    80004882:	413a04bb          	subw	s1,s4,s3
    80004886:	0004879b          	sext.w	a5,s1
    8000488a:	f8fbdce3          	bge	s7,a5,80004822 <filewrite+0x84>
    8000488e:	84e2                	mv	s1,s8
    80004890:	bf49                	j	80004822 <filewrite+0x84>
    int i = 0;
    80004892:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004894:	013a1f63          	bne	s4,s3,800048b2 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004898:	8552                	mv	a0,s4
    8000489a:	60a6                	ld	ra,72(sp)
    8000489c:	6406                	ld	s0,64(sp)
    8000489e:	74e2                	ld	s1,56(sp)
    800048a0:	7942                	ld	s2,48(sp)
    800048a2:	79a2                	ld	s3,40(sp)
    800048a4:	7a02                	ld	s4,32(sp)
    800048a6:	6ae2                	ld	s5,24(sp)
    800048a8:	6b42                	ld	s6,16(sp)
    800048aa:	6ba2                	ld	s7,8(sp)
    800048ac:	6c02                	ld	s8,0(sp)
    800048ae:	6161                	addi	sp,sp,80
    800048b0:	8082                	ret
    ret = (i == n ? n : -1);
    800048b2:	5a7d                	li	s4,-1
    800048b4:	b7d5                	j	80004898 <filewrite+0xfa>
    panic("filewrite");
    800048b6:	00004517          	auipc	a0,0x4
    800048ba:	e1a50513          	addi	a0,a0,-486 # 800086d0 <syscalls+0x288>
    800048be:	ffffc097          	auipc	ra,0xffffc
    800048c2:	c7c080e7          	jalr	-900(ra) # 8000053a <panic>
    return -1;
    800048c6:	5a7d                	li	s4,-1
    800048c8:	bfc1                	j	80004898 <filewrite+0xfa>
      return -1;
    800048ca:	5a7d                	li	s4,-1
    800048cc:	b7f1                	j	80004898 <filewrite+0xfa>
    800048ce:	5a7d                	li	s4,-1
    800048d0:	b7e1                	j	80004898 <filewrite+0xfa>

00000000800048d2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048d2:	7179                	addi	sp,sp,-48
    800048d4:	f406                	sd	ra,40(sp)
    800048d6:	f022                	sd	s0,32(sp)
    800048d8:	ec26                	sd	s1,24(sp)
    800048da:	e84a                	sd	s2,16(sp)
    800048dc:	e44e                	sd	s3,8(sp)
    800048de:	e052                	sd	s4,0(sp)
    800048e0:	1800                	addi	s0,sp,48
    800048e2:	84aa                	mv	s1,a0
    800048e4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048e6:	0005b023          	sd	zero,0(a1)
    800048ea:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048ee:	00000097          	auipc	ra,0x0
    800048f2:	bf8080e7          	jalr	-1032(ra) # 800044e6 <filealloc>
    800048f6:	e088                	sd	a0,0(s1)
    800048f8:	c551                	beqz	a0,80004984 <pipealloc+0xb2>
    800048fa:	00000097          	auipc	ra,0x0
    800048fe:	bec080e7          	jalr	-1044(ra) # 800044e6 <filealloc>
    80004902:	00aa3023          	sd	a0,0(s4)
    80004906:	c92d                	beqz	a0,80004978 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004908:	ffffc097          	auipc	ra,0xffffc
    8000490c:	1d8080e7          	jalr	472(ra) # 80000ae0 <kalloc>
    80004910:	892a                	mv	s2,a0
    80004912:	c125                	beqz	a0,80004972 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004914:	4985                	li	s3,1
    80004916:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000491a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000491e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004922:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004926:	00004597          	auipc	a1,0x4
    8000492a:	dba58593          	addi	a1,a1,-582 # 800086e0 <syscalls+0x298>
    8000492e:	ffffc097          	auipc	ra,0xffffc
    80004932:	212080e7          	jalr	530(ra) # 80000b40 <initlock>
  (*f0)->type = FD_PIPE;
    80004936:	609c                	ld	a5,0(s1)
    80004938:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000493c:	609c                	ld	a5,0(s1)
    8000493e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004942:	609c                	ld	a5,0(s1)
    80004944:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004948:	609c                	ld	a5,0(s1)
    8000494a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000494e:	000a3783          	ld	a5,0(s4)
    80004952:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004956:	000a3783          	ld	a5,0(s4)
    8000495a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000495e:	000a3783          	ld	a5,0(s4)
    80004962:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004966:	000a3783          	ld	a5,0(s4)
    8000496a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000496e:	4501                	li	a0,0
    80004970:	a025                	j	80004998 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004972:	6088                	ld	a0,0(s1)
    80004974:	e501                	bnez	a0,8000497c <pipealloc+0xaa>
    80004976:	a039                	j	80004984 <pipealloc+0xb2>
    80004978:	6088                	ld	a0,0(s1)
    8000497a:	c51d                	beqz	a0,800049a8 <pipealloc+0xd6>
    fileclose(*f0);
    8000497c:	00000097          	auipc	ra,0x0
    80004980:	c26080e7          	jalr	-986(ra) # 800045a2 <fileclose>
  if(*f1)
    80004984:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004988:	557d                	li	a0,-1
  if(*f1)
    8000498a:	c799                	beqz	a5,80004998 <pipealloc+0xc6>
    fileclose(*f1);
    8000498c:	853e                	mv	a0,a5
    8000498e:	00000097          	auipc	ra,0x0
    80004992:	c14080e7          	jalr	-1004(ra) # 800045a2 <fileclose>
  return -1;
    80004996:	557d                	li	a0,-1
}
    80004998:	70a2                	ld	ra,40(sp)
    8000499a:	7402                	ld	s0,32(sp)
    8000499c:	64e2                	ld	s1,24(sp)
    8000499e:	6942                	ld	s2,16(sp)
    800049a0:	69a2                	ld	s3,8(sp)
    800049a2:	6a02                	ld	s4,0(sp)
    800049a4:	6145                	addi	sp,sp,48
    800049a6:	8082                	ret
  return -1;
    800049a8:	557d                	li	a0,-1
    800049aa:	b7fd                	j	80004998 <pipealloc+0xc6>

00000000800049ac <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049ac:	1101                	addi	sp,sp,-32
    800049ae:	ec06                	sd	ra,24(sp)
    800049b0:	e822                	sd	s0,16(sp)
    800049b2:	e426                	sd	s1,8(sp)
    800049b4:	e04a                	sd	s2,0(sp)
    800049b6:	1000                	addi	s0,sp,32
    800049b8:	84aa                	mv	s1,a0
    800049ba:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049bc:	ffffc097          	auipc	ra,0xffffc
    800049c0:	214080e7          	jalr	532(ra) # 80000bd0 <acquire>
  if(writable){
    800049c4:	02090d63          	beqz	s2,800049fe <pipeclose+0x52>
    pi->writeopen = 0;
    800049c8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049cc:	21848513          	addi	a0,s1,536
    800049d0:	ffffe097          	auipc	ra,0xffffe
    800049d4:	81e080e7          	jalr	-2018(ra) # 800021ee <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049d8:	2204b783          	ld	a5,544(s1)
    800049dc:	eb95                	bnez	a5,80004a10 <pipeclose+0x64>
    release(&pi->lock);
    800049de:	8526                	mv	a0,s1
    800049e0:	ffffc097          	auipc	ra,0xffffc
    800049e4:	2a4080e7          	jalr	676(ra) # 80000c84 <release>
    kfree((char*)pi);
    800049e8:	8526                	mv	a0,s1
    800049ea:	ffffc097          	auipc	ra,0xffffc
    800049ee:	ff8080e7          	jalr	-8(ra) # 800009e2 <kfree>
  } else
    release(&pi->lock);
}
    800049f2:	60e2                	ld	ra,24(sp)
    800049f4:	6442                	ld	s0,16(sp)
    800049f6:	64a2                	ld	s1,8(sp)
    800049f8:	6902                	ld	s2,0(sp)
    800049fa:	6105                	addi	sp,sp,32
    800049fc:	8082                	ret
    pi->readopen = 0;
    800049fe:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a02:	21c48513          	addi	a0,s1,540
    80004a06:	ffffd097          	auipc	ra,0xffffd
    80004a0a:	7e8080e7          	jalr	2024(ra) # 800021ee <wakeup>
    80004a0e:	b7e9                	j	800049d8 <pipeclose+0x2c>
    release(&pi->lock);
    80004a10:	8526                	mv	a0,s1
    80004a12:	ffffc097          	auipc	ra,0xffffc
    80004a16:	272080e7          	jalr	626(ra) # 80000c84 <release>
}
    80004a1a:	bfe1                	j	800049f2 <pipeclose+0x46>

0000000080004a1c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a1c:	711d                	addi	sp,sp,-96
    80004a1e:	ec86                	sd	ra,88(sp)
    80004a20:	e8a2                	sd	s0,80(sp)
    80004a22:	e4a6                	sd	s1,72(sp)
    80004a24:	e0ca                	sd	s2,64(sp)
    80004a26:	fc4e                	sd	s3,56(sp)
    80004a28:	f852                	sd	s4,48(sp)
    80004a2a:	f456                	sd	s5,40(sp)
    80004a2c:	f05a                	sd	s6,32(sp)
    80004a2e:	ec5e                	sd	s7,24(sp)
    80004a30:	e862                	sd	s8,16(sp)
    80004a32:	1080                	addi	s0,sp,96
    80004a34:	84aa                	mv	s1,a0
    80004a36:	8aae                	mv	s5,a1
    80004a38:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a3a:	ffffd097          	auipc	ra,0xffffd
    80004a3e:	f64080e7          	jalr	-156(ra) # 8000199e <myproc>
    80004a42:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a44:	8526                	mv	a0,s1
    80004a46:	ffffc097          	auipc	ra,0xffffc
    80004a4a:	18a080e7          	jalr	394(ra) # 80000bd0 <acquire>
  while(i < n){
    80004a4e:	0b405363          	blez	s4,80004af4 <pipewrite+0xd8>
  int i = 0;
    80004a52:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a54:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a56:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a5a:	21c48b93          	addi	s7,s1,540
    80004a5e:	a089                	j	80004aa0 <pipewrite+0x84>
      release(&pi->lock);
    80004a60:	8526                	mv	a0,s1
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	222080e7          	jalr	546(ra) # 80000c84 <release>
      return -1;
    80004a6a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a6c:	854a                	mv	a0,s2
    80004a6e:	60e6                	ld	ra,88(sp)
    80004a70:	6446                	ld	s0,80(sp)
    80004a72:	64a6                	ld	s1,72(sp)
    80004a74:	6906                	ld	s2,64(sp)
    80004a76:	79e2                	ld	s3,56(sp)
    80004a78:	7a42                	ld	s4,48(sp)
    80004a7a:	7aa2                	ld	s5,40(sp)
    80004a7c:	7b02                	ld	s6,32(sp)
    80004a7e:	6be2                	ld	s7,24(sp)
    80004a80:	6c42                	ld	s8,16(sp)
    80004a82:	6125                	addi	sp,sp,96
    80004a84:	8082                	ret
      wakeup(&pi->nread);
    80004a86:	8562                	mv	a0,s8
    80004a88:	ffffd097          	auipc	ra,0xffffd
    80004a8c:	766080e7          	jalr	1894(ra) # 800021ee <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a90:	85a6                	mv	a1,s1
    80004a92:	855e                	mv	a0,s7
    80004a94:	ffffd097          	auipc	ra,0xffffd
    80004a98:	5ce080e7          	jalr	1486(ra) # 80002062 <sleep>
  while(i < n){
    80004a9c:	05495d63          	bge	s2,s4,80004af6 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004aa0:	2204a783          	lw	a5,544(s1)
    80004aa4:	dfd5                	beqz	a5,80004a60 <pipewrite+0x44>
    80004aa6:	0289a783          	lw	a5,40(s3)
    80004aaa:	fbdd                	bnez	a5,80004a60 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004aac:	2184a783          	lw	a5,536(s1)
    80004ab0:	21c4a703          	lw	a4,540(s1)
    80004ab4:	2007879b          	addiw	a5,a5,512
    80004ab8:	fcf707e3          	beq	a4,a5,80004a86 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004abc:	4685                	li	a3,1
    80004abe:	01590633          	add	a2,s2,s5
    80004ac2:	faf40593          	addi	a1,s0,-81
    80004ac6:	0509b503          	ld	a0,80(s3)
    80004aca:	ffffd097          	auipc	ra,0xffffd
    80004ace:	c24080e7          	jalr	-988(ra) # 800016ee <copyin>
    80004ad2:	03650263          	beq	a0,s6,80004af6 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ad6:	21c4a783          	lw	a5,540(s1)
    80004ada:	0017871b          	addiw	a4,a5,1
    80004ade:	20e4ae23          	sw	a4,540(s1)
    80004ae2:	1ff7f793          	andi	a5,a5,511
    80004ae6:	97a6                	add	a5,a5,s1
    80004ae8:	faf44703          	lbu	a4,-81(s0)
    80004aec:	00e78c23          	sb	a4,24(a5)
      i++;
    80004af0:	2905                	addiw	s2,s2,1
    80004af2:	b76d                	j	80004a9c <pipewrite+0x80>
  int i = 0;
    80004af4:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004af6:	21848513          	addi	a0,s1,536
    80004afa:	ffffd097          	auipc	ra,0xffffd
    80004afe:	6f4080e7          	jalr	1780(ra) # 800021ee <wakeup>
  release(&pi->lock);
    80004b02:	8526                	mv	a0,s1
    80004b04:	ffffc097          	auipc	ra,0xffffc
    80004b08:	180080e7          	jalr	384(ra) # 80000c84 <release>
  return i;
    80004b0c:	b785                	j	80004a6c <pipewrite+0x50>

0000000080004b0e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b0e:	715d                	addi	sp,sp,-80
    80004b10:	e486                	sd	ra,72(sp)
    80004b12:	e0a2                	sd	s0,64(sp)
    80004b14:	fc26                	sd	s1,56(sp)
    80004b16:	f84a                	sd	s2,48(sp)
    80004b18:	f44e                	sd	s3,40(sp)
    80004b1a:	f052                	sd	s4,32(sp)
    80004b1c:	ec56                	sd	s5,24(sp)
    80004b1e:	e85a                	sd	s6,16(sp)
    80004b20:	0880                	addi	s0,sp,80
    80004b22:	84aa                	mv	s1,a0
    80004b24:	892e                	mv	s2,a1
    80004b26:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b28:	ffffd097          	auipc	ra,0xffffd
    80004b2c:	e76080e7          	jalr	-394(ra) # 8000199e <myproc>
    80004b30:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b32:	8526                	mv	a0,s1
    80004b34:	ffffc097          	auipc	ra,0xffffc
    80004b38:	09c080e7          	jalr	156(ra) # 80000bd0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b3c:	2184a703          	lw	a4,536(s1)
    80004b40:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b44:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b48:	02f71463          	bne	a4,a5,80004b70 <piperead+0x62>
    80004b4c:	2244a783          	lw	a5,548(s1)
    80004b50:	c385                	beqz	a5,80004b70 <piperead+0x62>
    if(pr->killed){
    80004b52:	028a2783          	lw	a5,40(s4)
    80004b56:	ebc9                	bnez	a5,80004be8 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b58:	85a6                	mv	a1,s1
    80004b5a:	854e                	mv	a0,s3
    80004b5c:	ffffd097          	auipc	ra,0xffffd
    80004b60:	506080e7          	jalr	1286(ra) # 80002062 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b64:	2184a703          	lw	a4,536(s1)
    80004b68:	21c4a783          	lw	a5,540(s1)
    80004b6c:	fef700e3          	beq	a4,a5,80004b4c <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b70:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b72:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b74:	05505463          	blez	s5,80004bbc <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80004b78:	2184a783          	lw	a5,536(s1)
    80004b7c:	21c4a703          	lw	a4,540(s1)
    80004b80:	02f70e63          	beq	a4,a5,80004bbc <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b84:	0017871b          	addiw	a4,a5,1
    80004b88:	20e4ac23          	sw	a4,536(s1)
    80004b8c:	1ff7f793          	andi	a5,a5,511
    80004b90:	97a6                	add	a5,a5,s1
    80004b92:	0187c783          	lbu	a5,24(a5)
    80004b96:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b9a:	4685                	li	a3,1
    80004b9c:	fbf40613          	addi	a2,s0,-65
    80004ba0:	85ca                	mv	a1,s2
    80004ba2:	050a3503          	ld	a0,80(s4)
    80004ba6:	ffffd097          	auipc	ra,0xffffd
    80004baa:	abc080e7          	jalr	-1348(ra) # 80001662 <copyout>
    80004bae:	01650763          	beq	a0,s6,80004bbc <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bb2:	2985                	addiw	s3,s3,1
    80004bb4:	0905                	addi	s2,s2,1
    80004bb6:	fd3a91e3          	bne	s5,s3,80004b78 <piperead+0x6a>
    80004bba:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004bbc:	21c48513          	addi	a0,s1,540
    80004bc0:	ffffd097          	auipc	ra,0xffffd
    80004bc4:	62e080e7          	jalr	1582(ra) # 800021ee <wakeup>
  release(&pi->lock);
    80004bc8:	8526                	mv	a0,s1
    80004bca:	ffffc097          	auipc	ra,0xffffc
    80004bce:	0ba080e7          	jalr	186(ra) # 80000c84 <release>
  return i;
}
    80004bd2:	854e                	mv	a0,s3
    80004bd4:	60a6                	ld	ra,72(sp)
    80004bd6:	6406                	ld	s0,64(sp)
    80004bd8:	74e2                	ld	s1,56(sp)
    80004bda:	7942                	ld	s2,48(sp)
    80004bdc:	79a2                	ld	s3,40(sp)
    80004bde:	7a02                	ld	s4,32(sp)
    80004be0:	6ae2                	ld	s5,24(sp)
    80004be2:	6b42                	ld	s6,16(sp)
    80004be4:	6161                	addi	sp,sp,80
    80004be6:	8082                	ret
      release(&pi->lock);
    80004be8:	8526                	mv	a0,s1
    80004bea:	ffffc097          	auipc	ra,0xffffc
    80004bee:	09a080e7          	jalr	154(ra) # 80000c84 <release>
      return -1;
    80004bf2:	59fd                	li	s3,-1
    80004bf4:	bff9                	j	80004bd2 <piperead+0xc4>

0000000080004bf6 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004bf6:	de010113          	addi	sp,sp,-544
    80004bfa:	20113c23          	sd	ra,536(sp)
    80004bfe:	20813823          	sd	s0,528(sp)
    80004c02:	20913423          	sd	s1,520(sp)
    80004c06:	21213023          	sd	s2,512(sp)
    80004c0a:	ffce                	sd	s3,504(sp)
    80004c0c:	fbd2                	sd	s4,496(sp)
    80004c0e:	f7d6                	sd	s5,488(sp)
    80004c10:	f3da                	sd	s6,480(sp)
    80004c12:	efde                	sd	s7,472(sp)
    80004c14:	ebe2                	sd	s8,464(sp)
    80004c16:	e7e6                	sd	s9,456(sp)
    80004c18:	e3ea                	sd	s10,448(sp)
    80004c1a:	ff6e                	sd	s11,440(sp)
    80004c1c:	1400                	addi	s0,sp,544
    80004c1e:	892a                	mv	s2,a0
    80004c20:	dea43423          	sd	a0,-536(s0)
    80004c24:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c28:	ffffd097          	auipc	ra,0xffffd
    80004c2c:	d76080e7          	jalr	-650(ra) # 8000199e <myproc>
    80004c30:	84aa                	mv	s1,a0

  begin_op();
    80004c32:	fffff097          	auipc	ra,0xfffff
    80004c36:	4a8080e7          	jalr	1192(ra) # 800040da <begin_op>

  if((ip = namei(path)) == 0){
    80004c3a:	854a                	mv	a0,s2
    80004c3c:	fffff097          	auipc	ra,0xfffff
    80004c40:	27e080e7          	jalr	638(ra) # 80003eba <namei>
    80004c44:	c93d                	beqz	a0,80004cba <exec+0xc4>
    80004c46:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c48:	fffff097          	auipc	ra,0xfffff
    80004c4c:	ab6080e7          	jalr	-1354(ra) # 800036fe <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c50:	04000713          	li	a4,64
    80004c54:	4681                	li	a3,0
    80004c56:	e5040613          	addi	a2,s0,-432
    80004c5a:	4581                	li	a1,0
    80004c5c:	8556                	mv	a0,s5
    80004c5e:	fffff097          	auipc	ra,0xfffff
    80004c62:	d54080e7          	jalr	-684(ra) # 800039b2 <readi>
    80004c66:	04000793          	li	a5,64
    80004c6a:	00f51a63          	bne	a0,a5,80004c7e <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004c6e:	e5042703          	lw	a4,-432(s0)
    80004c72:	464c47b7          	lui	a5,0x464c4
    80004c76:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c7a:	04f70663          	beq	a4,a5,80004cc6 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c7e:	8556                	mv	a0,s5
    80004c80:	fffff097          	auipc	ra,0xfffff
    80004c84:	ce0080e7          	jalr	-800(ra) # 80003960 <iunlockput>
    end_op();
    80004c88:	fffff097          	auipc	ra,0xfffff
    80004c8c:	4d0080e7          	jalr	1232(ra) # 80004158 <end_op>
  }
  return -1;
    80004c90:	557d                	li	a0,-1
}
    80004c92:	21813083          	ld	ra,536(sp)
    80004c96:	21013403          	ld	s0,528(sp)
    80004c9a:	20813483          	ld	s1,520(sp)
    80004c9e:	20013903          	ld	s2,512(sp)
    80004ca2:	79fe                	ld	s3,504(sp)
    80004ca4:	7a5e                	ld	s4,496(sp)
    80004ca6:	7abe                	ld	s5,488(sp)
    80004ca8:	7b1e                	ld	s6,480(sp)
    80004caa:	6bfe                	ld	s7,472(sp)
    80004cac:	6c5e                	ld	s8,464(sp)
    80004cae:	6cbe                	ld	s9,456(sp)
    80004cb0:	6d1e                	ld	s10,448(sp)
    80004cb2:	7dfa                	ld	s11,440(sp)
    80004cb4:	22010113          	addi	sp,sp,544
    80004cb8:	8082                	ret
    end_op();
    80004cba:	fffff097          	auipc	ra,0xfffff
    80004cbe:	49e080e7          	jalr	1182(ra) # 80004158 <end_op>
    return -1;
    80004cc2:	557d                	li	a0,-1
    80004cc4:	b7f9                	j	80004c92 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004cc6:	8526                	mv	a0,s1
    80004cc8:	ffffd097          	auipc	ra,0xffffd
    80004ccc:	d9a080e7          	jalr	-614(ra) # 80001a62 <proc_pagetable>
    80004cd0:	8b2a                	mv	s6,a0
    80004cd2:	d555                	beqz	a0,80004c7e <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cd4:	e7042783          	lw	a5,-400(s0)
    80004cd8:	e8845703          	lhu	a4,-376(s0)
    80004cdc:	c735                	beqz	a4,80004d48 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cde:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ce0:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004ce4:	6a05                	lui	s4,0x1
    80004ce6:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004cea:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004cee:	6d85                	lui	s11,0x1
    80004cf0:	7d7d                	lui	s10,0xfffff
    80004cf2:	ac1d                	j	80004f28 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004cf4:	00004517          	auipc	a0,0x4
    80004cf8:	9f450513          	addi	a0,a0,-1548 # 800086e8 <syscalls+0x2a0>
    80004cfc:	ffffc097          	auipc	ra,0xffffc
    80004d00:	83e080e7          	jalr	-1986(ra) # 8000053a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d04:	874a                	mv	a4,s2
    80004d06:	009c86bb          	addw	a3,s9,s1
    80004d0a:	4581                	li	a1,0
    80004d0c:	8556                	mv	a0,s5
    80004d0e:	fffff097          	auipc	ra,0xfffff
    80004d12:	ca4080e7          	jalr	-860(ra) # 800039b2 <readi>
    80004d16:	2501                	sext.w	a0,a0
    80004d18:	1aa91863          	bne	s2,a0,80004ec8 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004d1c:	009d84bb          	addw	s1,s11,s1
    80004d20:	013d09bb          	addw	s3,s10,s3
    80004d24:	1f74f263          	bgeu	s1,s7,80004f08 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004d28:	02049593          	slli	a1,s1,0x20
    80004d2c:	9181                	srli	a1,a1,0x20
    80004d2e:	95e2                	add	a1,a1,s8
    80004d30:	855a                	mv	a0,s6
    80004d32:	ffffc097          	auipc	ra,0xffffc
    80004d36:	328080e7          	jalr	808(ra) # 8000105a <walkaddr>
    80004d3a:	862a                	mv	a2,a0
    if(pa == 0)
    80004d3c:	dd45                	beqz	a0,80004cf4 <exec+0xfe>
      n = PGSIZE;
    80004d3e:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004d40:	fd49f2e3          	bgeu	s3,s4,80004d04 <exec+0x10e>
      n = sz - i;
    80004d44:	894e                	mv	s2,s3
    80004d46:	bf7d                	j	80004d04 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d48:	4481                	li	s1,0
  iunlockput(ip);
    80004d4a:	8556                	mv	a0,s5
    80004d4c:	fffff097          	auipc	ra,0xfffff
    80004d50:	c14080e7          	jalr	-1004(ra) # 80003960 <iunlockput>
  end_op();
    80004d54:	fffff097          	auipc	ra,0xfffff
    80004d58:	404080e7          	jalr	1028(ra) # 80004158 <end_op>
  p = myproc();
    80004d5c:	ffffd097          	auipc	ra,0xffffd
    80004d60:	c42080e7          	jalr	-958(ra) # 8000199e <myproc>
    80004d64:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004d66:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004d6a:	6785                	lui	a5,0x1
    80004d6c:	17fd                	addi	a5,a5,-1
    80004d6e:	97a6                	add	a5,a5,s1
    80004d70:	777d                	lui	a4,0xfffff
    80004d72:	8ff9                	and	a5,a5,a4
    80004d74:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d78:	6609                	lui	a2,0x2
    80004d7a:	963e                	add	a2,a2,a5
    80004d7c:	85be                	mv	a1,a5
    80004d7e:	855a                	mv	a0,s6
    80004d80:	ffffc097          	auipc	ra,0xffffc
    80004d84:	68e080e7          	jalr	1678(ra) # 8000140e <uvmalloc>
    80004d88:	8c2a                	mv	s8,a0
  ip = 0;
    80004d8a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d8c:	12050e63          	beqz	a0,80004ec8 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d90:	75f9                	lui	a1,0xffffe
    80004d92:	95aa                	add	a1,a1,a0
    80004d94:	855a                	mv	a0,s6
    80004d96:	ffffd097          	auipc	ra,0xffffd
    80004d9a:	89a080e7          	jalr	-1894(ra) # 80001630 <uvmclear>
  stackbase = sp - PGSIZE;
    80004d9e:	7afd                	lui	s5,0xfffff
    80004da0:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004da2:	df043783          	ld	a5,-528(s0)
    80004da6:	6388                	ld	a0,0(a5)
    80004da8:	c925                	beqz	a0,80004e18 <exec+0x222>
    80004daa:	e9040993          	addi	s3,s0,-368
    80004dae:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004db2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004db4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004db6:	ffffc097          	auipc	ra,0xffffc
    80004dba:	092080e7          	jalr	146(ra) # 80000e48 <strlen>
    80004dbe:	0015079b          	addiw	a5,a0,1
    80004dc2:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004dc6:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004dca:	13596363          	bltu	s2,s5,80004ef0 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004dce:	df043d83          	ld	s11,-528(s0)
    80004dd2:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004dd6:	8552                	mv	a0,s4
    80004dd8:	ffffc097          	auipc	ra,0xffffc
    80004ddc:	070080e7          	jalr	112(ra) # 80000e48 <strlen>
    80004de0:	0015069b          	addiw	a3,a0,1
    80004de4:	8652                	mv	a2,s4
    80004de6:	85ca                	mv	a1,s2
    80004de8:	855a                	mv	a0,s6
    80004dea:	ffffd097          	auipc	ra,0xffffd
    80004dee:	878080e7          	jalr	-1928(ra) # 80001662 <copyout>
    80004df2:	10054363          	bltz	a0,80004ef8 <exec+0x302>
    ustack[argc] = sp;
    80004df6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004dfa:	0485                	addi	s1,s1,1
    80004dfc:	008d8793          	addi	a5,s11,8
    80004e00:	def43823          	sd	a5,-528(s0)
    80004e04:	008db503          	ld	a0,8(s11)
    80004e08:	c911                	beqz	a0,80004e1c <exec+0x226>
    if(argc >= MAXARG)
    80004e0a:	09a1                	addi	s3,s3,8
    80004e0c:	fb3c95e3          	bne	s9,s3,80004db6 <exec+0x1c0>
  sz = sz1;
    80004e10:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e14:	4a81                	li	s5,0
    80004e16:	a84d                	j	80004ec8 <exec+0x2d2>
  sp = sz;
    80004e18:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e1a:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e1c:	00349793          	slli	a5,s1,0x3
    80004e20:	f9078793          	addi	a5,a5,-112 # f90 <_entry-0x7ffff070>
    80004e24:	97a2                	add	a5,a5,s0
    80004e26:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e2a:	00148693          	addi	a3,s1,1
    80004e2e:	068e                	slli	a3,a3,0x3
    80004e30:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e34:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e38:	01597663          	bgeu	s2,s5,80004e44 <exec+0x24e>
  sz = sz1;
    80004e3c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e40:	4a81                	li	s5,0
    80004e42:	a059                	j	80004ec8 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e44:	e9040613          	addi	a2,s0,-368
    80004e48:	85ca                	mv	a1,s2
    80004e4a:	855a                	mv	a0,s6
    80004e4c:	ffffd097          	auipc	ra,0xffffd
    80004e50:	816080e7          	jalr	-2026(ra) # 80001662 <copyout>
    80004e54:	0a054663          	bltz	a0,80004f00 <exec+0x30a>
  p->trapframe->a1 = sp;
    80004e58:	058bb783          	ld	a5,88(s7)
    80004e5c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e60:	de843783          	ld	a5,-536(s0)
    80004e64:	0007c703          	lbu	a4,0(a5)
    80004e68:	cf11                	beqz	a4,80004e84 <exec+0x28e>
    80004e6a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e6c:	02f00693          	li	a3,47
    80004e70:	a039                	j	80004e7e <exec+0x288>
      last = s+1;
    80004e72:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004e76:	0785                	addi	a5,a5,1
    80004e78:	fff7c703          	lbu	a4,-1(a5)
    80004e7c:	c701                	beqz	a4,80004e84 <exec+0x28e>
    if(*s == '/')
    80004e7e:	fed71ce3          	bne	a4,a3,80004e76 <exec+0x280>
    80004e82:	bfc5                	j	80004e72 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e84:	4641                	li	a2,16
    80004e86:	de843583          	ld	a1,-536(s0)
    80004e8a:	158b8513          	addi	a0,s7,344
    80004e8e:	ffffc097          	auipc	ra,0xffffc
    80004e92:	f88080e7          	jalr	-120(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004e96:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004e9a:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004e9e:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004ea2:	058bb783          	ld	a5,88(s7)
    80004ea6:	e6843703          	ld	a4,-408(s0)
    80004eaa:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004eac:	058bb783          	ld	a5,88(s7)
    80004eb0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004eb4:	85ea                	mv	a1,s10
    80004eb6:	ffffd097          	auipc	ra,0xffffd
    80004eba:	c48080e7          	jalr	-952(ra) # 80001afe <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ebe:	0004851b          	sext.w	a0,s1
    80004ec2:	bbc1                	j	80004c92 <exec+0x9c>
    80004ec4:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004ec8:	df843583          	ld	a1,-520(s0)
    80004ecc:	855a                	mv	a0,s6
    80004ece:	ffffd097          	auipc	ra,0xffffd
    80004ed2:	c30080e7          	jalr	-976(ra) # 80001afe <proc_freepagetable>
  if(ip){
    80004ed6:	da0a94e3          	bnez	s5,80004c7e <exec+0x88>
  return -1;
    80004eda:	557d                	li	a0,-1
    80004edc:	bb5d                	j	80004c92 <exec+0x9c>
    80004ede:	de943c23          	sd	s1,-520(s0)
    80004ee2:	b7dd                	j	80004ec8 <exec+0x2d2>
    80004ee4:	de943c23          	sd	s1,-520(s0)
    80004ee8:	b7c5                	j	80004ec8 <exec+0x2d2>
    80004eea:	de943c23          	sd	s1,-520(s0)
    80004eee:	bfe9                	j	80004ec8 <exec+0x2d2>
  sz = sz1;
    80004ef0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ef4:	4a81                	li	s5,0
    80004ef6:	bfc9                	j	80004ec8 <exec+0x2d2>
  sz = sz1;
    80004ef8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004efc:	4a81                	li	s5,0
    80004efe:	b7e9                	j	80004ec8 <exec+0x2d2>
  sz = sz1;
    80004f00:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f04:	4a81                	li	s5,0
    80004f06:	b7c9                	j	80004ec8 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f08:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f0c:	e0843783          	ld	a5,-504(s0)
    80004f10:	0017869b          	addiw	a3,a5,1
    80004f14:	e0d43423          	sd	a3,-504(s0)
    80004f18:	e0043783          	ld	a5,-512(s0)
    80004f1c:	0387879b          	addiw	a5,a5,56
    80004f20:	e8845703          	lhu	a4,-376(s0)
    80004f24:	e2e6d3e3          	bge	a3,a4,80004d4a <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f28:	2781                	sext.w	a5,a5
    80004f2a:	e0f43023          	sd	a5,-512(s0)
    80004f2e:	03800713          	li	a4,56
    80004f32:	86be                	mv	a3,a5
    80004f34:	e1840613          	addi	a2,s0,-488
    80004f38:	4581                	li	a1,0
    80004f3a:	8556                	mv	a0,s5
    80004f3c:	fffff097          	auipc	ra,0xfffff
    80004f40:	a76080e7          	jalr	-1418(ra) # 800039b2 <readi>
    80004f44:	03800793          	li	a5,56
    80004f48:	f6f51ee3          	bne	a0,a5,80004ec4 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80004f4c:	e1842783          	lw	a5,-488(s0)
    80004f50:	4705                	li	a4,1
    80004f52:	fae79de3          	bne	a5,a4,80004f0c <exec+0x316>
    if(ph.memsz < ph.filesz)
    80004f56:	e4043603          	ld	a2,-448(s0)
    80004f5a:	e3843783          	ld	a5,-456(s0)
    80004f5e:	f8f660e3          	bltu	a2,a5,80004ede <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f62:	e2843783          	ld	a5,-472(s0)
    80004f66:	963e                	add	a2,a2,a5
    80004f68:	f6f66ee3          	bltu	a2,a5,80004ee4 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f6c:	85a6                	mv	a1,s1
    80004f6e:	855a                	mv	a0,s6
    80004f70:	ffffc097          	auipc	ra,0xffffc
    80004f74:	49e080e7          	jalr	1182(ra) # 8000140e <uvmalloc>
    80004f78:	dea43c23          	sd	a0,-520(s0)
    80004f7c:	d53d                	beqz	a0,80004eea <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    80004f7e:	e2843c03          	ld	s8,-472(s0)
    80004f82:	de043783          	ld	a5,-544(s0)
    80004f86:	00fc77b3          	and	a5,s8,a5
    80004f8a:	ff9d                	bnez	a5,80004ec8 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f8c:	e2042c83          	lw	s9,-480(s0)
    80004f90:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f94:	f60b8ae3          	beqz	s7,80004f08 <exec+0x312>
    80004f98:	89de                	mv	s3,s7
    80004f9a:	4481                	li	s1,0
    80004f9c:	b371                	j	80004d28 <exec+0x132>

0000000080004f9e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f9e:	7179                	addi	sp,sp,-48
    80004fa0:	f406                	sd	ra,40(sp)
    80004fa2:	f022                	sd	s0,32(sp)
    80004fa4:	ec26                	sd	s1,24(sp)
    80004fa6:	e84a                	sd	s2,16(sp)
    80004fa8:	1800                	addi	s0,sp,48
    80004faa:	892e                	mv	s2,a1
    80004fac:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004fae:	fdc40593          	addi	a1,s0,-36
    80004fb2:	ffffe097          	auipc	ra,0xffffe
    80004fb6:	aa2080e7          	jalr	-1374(ra) # 80002a54 <argint>
    80004fba:	04054063          	bltz	a0,80004ffa <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004fbe:	fdc42703          	lw	a4,-36(s0)
    80004fc2:	47bd                	li	a5,15
    80004fc4:	02e7ed63          	bltu	a5,a4,80004ffe <argfd+0x60>
    80004fc8:	ffffd097          	auipc	ra,0xffffd
    80004fcc:	9d6080e7          	jalr	-1578(ra) # 8000199e <myproc>
    80004fd0:	fdc42703          	lw	a4,-36(s0)
    80004fd4:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd8252>
    80004fd8:	078e                	slli	a5,a5,0x3
    80004fda:	953e                	add	a0,a0,a5
    80004fdc:	611c                	ld	a5,0(a0)
    80004fde:	c395                	beqz	a5,80005002 <argfd+0x64>
    return -1;
  if(pfd)
    80004fe0:	00090463          	beqz	s2,80004fe8 <argfd+0x4a>
    *pfd = fd;
    80004fe4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004fe8:	4501                	li	a0,0
  if(pf)
    80004fea:	c091                	beqz	s1,80004fee <argfd+0x50>
    *pf = f;
    80004fec:	e09c                	sd	a5,0(s1)
}
    80004fee:	70a2                	ld	ra,40(sp)
    80004ff0:	7402                	ld	s0,32(sp)
    80004ff2:	64e2                	ld	s1,24(sp)
    80004ff4:	6942                	ld	s2,16(sp)
    80004ff6:	6145                	addi	sp,sp,48
    80004ff8:	8082                	ret
    return -1;
    80004ffa:	557d                	li	a0,-1
    80004ffc:	bfcd                	j	80004fee <argfd+0x50>
    return -1;
    80004ffe:	557d                	li	a0,-1
    80005000:	b7fd                	j	80004fee <argfd+0x50>
    80005002:	557d                	li	a0,-1
    80005004:	b7ed                	j	80004fee <argfd+0x50>

0000000080005006 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005006:	1101                	addi	sp,sp,-32
    80005008:	ec06                	sd	ra,24(sp)
    8000500a:	e822                	sd	s0,16(sp)
    8000500c:	e426                	sd	s1,8(sp)
    8000500e:	1000                	addi	s0,sp,32
    80005010:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005012:	ffffd097          	auipc	ra,0xffffd
    80005016:	98c080e7          	jalr	-1652(ra) # 8000199e <myproc>
    8000501a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000501c:	0d050793          	addi	a5,a0,208
    80005020:	4501                	li	a0,0
    80005022:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005024:	6398                	ld	a4,0(a5)
    80005026:	cb19                	beqz	a4,8000503c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005028:	2505                	addiw	a0,a0,1
    8000502a:	07a1                	addi	a5,a5,8
    8000502c:	fed51ce3          	bne	a0,a3,80005024 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005030:	557d                	li	a0,-1
}
    80005032:	60e2                	ld	ra,24(sp)
    80005034:	6442                	ld	s0,16(sp)
    80005036:	64a2                	ld	s1,8(sp)
    80005038:	6105                	addi	sp,sp,32
    8000503a:	8082                	ret
      p->ofile[fd] = f;
    8000503c:	01a50793          	addi	a5,a0,26
    80005040:	078e                	slli	a5,a5,0x3
    80005042:	963e                	add	a2,a2,a5
    80005044:	e204                	sd	s1,0(a2)
      return fd;
    80005046:	b7f5                	j	80005032 <fdalloc+0x2c>

0000000080005048 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005048:	715d                	addi	sp,sp,-80
    8000504a:	e486                	sd	ra,72(sp)
    8000504c:	e0a2                	sd	s0,64(sp)
    8000504e:	fc26                	sd	s1,56(sp)
    80005050:	f84a                	sd	s2,48(sp)
    80005052:	f44e                	sd	s3,40(sp)
    80005054:	f052                	sd	s4,32(sp)
    80005056:	ec56                	sd	s5,24(sp)
    80005058:	0880                	addi	s0,sp,80
    8000505a:	89ae                	mv	s3,a1
    8000505c:	8ab2                	mv	s5,a2
    8000505e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005060:	fb040593          	addi	a1,s0,-80
    80005064:	fffff097          	auipc	ra,0xfffff
    80005068:	e74080e7          	jalr	-396(ra) # 80003ed8 <nameiparent>
    8000506c:	892a                	mv	s2,a0
    8000506e:	12050e63          	beqz	a0,800051aa <create+0x162>
    return 0;

  ilock(dp);
    80005072:	ffffe097          	auipc	ra,0xffffe
    80005076:	68c080e7          	jalr	1676(ra) # 800036fe <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000507a:	4601                	li	a2,0
    8000507c:	fb040593          	addi	a1,s0,-80
    80005080:	854a                	mv	a0,s2
    80005082:	fffff097          	auipc	ra,0xfffff
    80005086:	b60080e7          	jalr	-1184(ra) # 80003be2 <dirlookup>
    8000508a:	84aa                	mv	s1,a0
    8000508c:	c921                	beqz	a0,800050dc <create+0x94>
    iunlockput(dp);
    8000508e:	854a                	mv	a0,s2
    80005090:	fffff097          	auipc	ra,0xfffff
    80005094:	8d0080e7          	jalr	-1840(ra) # 80003960 <iunlockput>
    ilock(ip);
    80005098:	8526                	mv	a0,s1
    8000509a:	ffffe097          	auipc	ra,0xffffe
    8000509e:	664080e7          	jalr	1636(ra) # 800036fe <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050a2:	2981                	sext.w	s3,s3
    800050a4:	4789                	li	a5,2
    800050a6:	02f99463          	bne	s3,a5,800050ce <create+0x86>
    800050aa:	0444d783          	lhu	a5,68(s1)
    800050ae:	37f9                	addiw	a5,a5,-2
    800050b0:	17c2                	slli	a5,a5,0x30
    800050b2:	93c1                	srli	a5,a5,0x30
    800050b4:	4705                	li	a4,1
    800050b6:	00f76c63          	bltu	a4,a5,800050ce <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800050ba:	8526                	mv	a0,s1
    800050bc:	60a6                	ld	ra,72(sp)
    800050be:	6406                	ld	s0,64(sp)
    800050c0:	74e2                	ld	s1,56(sp)
    800050c2:	7942                	ld	s2,48(sp)
    800050c4:	79a2                	ld	s3,40(sp)
    800050c6:	7a02                	ld	s4,32(sp)
    800050c8:	6ae2                	ld	s5,24(sp)
    800050ca:	6161                	addi	sp,sp,80
    800050cc:	8082                	ret
    iunlockput(ip);
    800050ce:	8526                	mv	a0,s1
    800050d0:	fffff097          	auipc	ra,0xfffff
    800050d4:	890080e7          	jalr	-1904(ra) # 80003960 <iunlockput>
    return 0;
    800050d8:	4481                	li	s1,0
    800050da:	b7c5                	j	800050ba <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800050dc:	85ce                	mv	a1,s3
    800050de:	00092503          	lw	a0,0(s2)
    800050e2:	ffffe097          	auipc	ra,0xffffe
    800050e6:	482080e7          	jalr	1154(ra) # 80003564 <ialloc>
    800050ea:	84aa                	mv	s1,a0
    800050ec:	c521                	beqz	a0,80005134 <create+0xec>
  ilock(ip);
    800050ee:	ffffe097          	auipc	ra,0xffffe
    800050f2:	610080e7          	jalr	1552(ra) # 800036fe <ilock>
  ip->major = major;
    800050f6:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800050fa:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800050fe:	4a05                	li	s4,1
    80005100:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005104:	8526                	mv	a0,s1
    80005106:	ffffe097          	auipc	ra,0xffffe
    8000510a:	52c080e7          	jalr	1324(ra) # 80003632 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000510e:	2981                	sext.w	s3,s3
    80005110:	03498a63          	beq	s3,s4,80005144 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005114:	40d0                	lw	a2,4(s1)
    80005116:	fb040593          	addi	a1,s0,-80
    8000511a:	854a                	mv	a0,s2
    8000511c:	fffff097          	auipc	ra,0xfffff
    80005120:	cdc080e7          	jalr	-804(ra) # 80003df8 <dirlink>
    80005124:	06054b63          	bltz	a0,8000519a <create+0x152>
  iunlockput(dp);
    80005128:	854a                	mv	a0,s2
    8000512a:	fffff097          	auipc	ra,0xfffff
    8000512e:	836080e7          	jalr	-1994(ra) # 80003960 <iunlockput>
  return ip;
    80005132:	b761                	j	800050ba <create+0x72>
    panic("create: ialloc");
    80005134:	00003517          	auipc	a0,0x3
    80005138:	5d450513          	addi	a0,a0,1492 # 80008708 <syscalls+0x2c0>
    8000513c:	ffffb097          	auipc	ra,0xffffb
    80005140:	3fe080e7          	jalr	1022(ra) # 8000053a <panic>
    dp->nlink++;  // for ".."
    80005144:	04a95783          	lhu	a5,74(s2)
    80005148:	2785                	addiw	a5,a5,1
    8000514a:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000514e:	854a                	mv	a0,s2
    80005150:	ffffe097          	auipc	ra,0xffffe
    80005154:	4e2080e7          	jalr	1250(ra) # 80003632 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005158:	40d0                	lw	a2,4(s1)
    8000515a:	00003597          	auipc	a1,0x3
    8000515e:	5be58593          	addi	a1,a1,1470 # 80008718 <syscalls+0x2d0>
    80005162:	8526                	mv	a0,s1
    80005164:	fffff097          	auipc	ra,0xfffff
    80005168:	c94080e7          	jalr	-876(ra) # 80003df8 <dirlink>
    8000516c:	00054f63          	bltz	a0,8000518a <create+0x142>
    80005170:	00492603          	lw	a2,4(s2)
    80005174:	00003597          	auipc	a1,0x3
    80005178:	5ac58593          	addi	a1,a1,1452 # 80008720 <syscalls+0x2d8>
    8000517c:	8526                	mv	a0,s1
    8000517e:	fffff097          	auipc	ra,0xfffff
    80005182:	c7a080e7          	jalr	-902(ra) # 80003df8 <dirlink>
    80005186:	f80557e3          	bgez	a0,80005114 <create+0xcc>
      panic("create dots");
    8000518a:	00003517          	auipc	a0,0x3
    8000518e:	59e50513          	addi	a0,a0,1438 # 80008728 <syscalls+0x2e0>
    80005192:	ffffb097          	auipc	ra,0xffffb
    80005196:	3a8080e7          	jalr	936(ra) # 8000053a <panic>
    panic("create: dirlink");
    8000519a:	00003517          	auipc	a0,0x3
    8000519e:	59e50513          	addi	a0,a0,1438 # 80008738 <syscalls+0x2f0>
    800051a2:	ffffb097          	auipc	ra,0xffffb
    800051a6:	398080e7          	jalr	920(ra) # 8000053a <panic>
    return 0;
    800051aa:	84aa                	mv	s1,a0
    800051ac:	b739                	j	800050ba <create+0x72>

00000000800051ae <sys_dup>:
{
    800051ae:	7179                	addi	sp,sp,-48
    800051b0:	f406                	sd	ra,40(sp)
    800051b2:	f022                	sd	s0,32(sp)
    800051b4:	ec26                	sd	s1,24(sp)
    800051b6:	e84a                	sd	s2,16(sp)
    800051b8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051ba:	fd840613          	addi	a2,s0,-40
    800051be:	4581                	li	a1,0
    800051c0:	4501                	li	a0,0
    800051c2:	00000097          	auipc	ra,0x0
    800051c6:	ddc080e7          	jalr	-548(ra) # 80004f9e <argfd>
    return -1;
    800051ca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051cc:	02054363          	bltz	a0,800051f2 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800051d0:	fd843903          	ld	s2,-40(s0)
    800051d4:	854a                	mv	a0,s2
    800051d6:	00000097          	auipc	ra,0x0
    800051da:	e30080e7          	jalr	-464(ra) # 80005006 <fdalloc>
    800051de:	84aa                	mv	s1,a0
    return -1;
    800051e0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051e2:	00054863          	bltz	a0,800051f2 <sys_dup+0x44>
  filedup(f);
    800051e6:	854a                	mv	a0,s2
    800051e8:	fffff097          	auipc	ra,0xfffff
    800051ec:	368080e7          	jalr	872(ra) # 80004550 <filedup>
  return fd;
    800051f0:	87a6                	mv	a5,s1
}
    800051f2:	853e                	mv	a0,a5
    800051f4:	70a2                	ld	ra,40(sp)
    800051f6:	7402                	ld	s0,32(sp)
    800051f8:	64e2                	ld	s1,24(sp)
    800051fa:	6942                	ld	s2,16(sp)
    800051fc:	6145                	addi	sp,sp,48
    800051fe:	8082                	ret

0000000080005200 <sys_read>:
{
    80005200:	7179                	addi	sp,sp,-48
    80005202:	f406                	sd	ra,40(sp)
    80005204:	f022                	sd	s0,32(sp)
    80005206:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005208:	fe840613          	addi	a2,s0,-24
    8000520c:	4581                	li	a1,0
    8000520e:	4501                	li	a0,0
    80005210:	00000097          	auipc	ra,0x0
    80005214:	d8e080e7          	jalr	-626(ra) # 80004f9e <argfd>
    return -1;
    80005218:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000521a:	04054163          	bltz	a0,8000525c <sys_read+0x5c>
    8000521e:	fe440593          	addi	a1,s0,-28
    80005222:	4509                	li	a0,2
    80005224:	ffffe097          	auipc	ra,0xffffe
    80005228:	830080e7          	jalr	-2000(ra) # 80002a54 <argint>
    return -1;
    8000522c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000522e:	02054763          	bltz	a0,8000525c <sys_read+0x5c>
    80005232:	fd840593          	addi	a1,s0,-40
    80005236:	4505                	li	a0,1
    80005238:	ffffe097          	auipc	ra,0xffffe
    8000523c:	83e080e7          	jalr	-1986(ra) # 80002a76 <argaddr>
    return -1;
    80005240:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005242:	00054d63          	bltz	a0,8000525c <sys_read+0x5c>
  return fileread(f, p, n);
    80005246:	fe442603          	lw	a2,-28(s0)
    8000524a:	fd843583          	ld	a1,-40(s0)
    8000524e:	fe843503          	ld	a0,-24(s0)
    80005252:	fffff097          	auipc	ra,0xfffff
    80005256:	48a080e7          	jalr	1162(ra) # 800046dc <fileread>
    8000525a:	87aa                	mv	a5,a0
}
    8000525c:	853e                	mv	a0,a5
    8000525e:	70a2                	ld	ra,40(sp)
    80005260:	7402                	ld	s0,32(sp)
    80005262:	6145                	addi	sp,sp,48
    80005264:	8082                	ret

0000000080005266 <sys_write>:
{
    80005266:	7179                	addi	sp,sp,-48
    80005268:	f406                	sd	ra,40(sp)
    8000526a:	f022                	sd	s0,32(sp)
    8000526c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000526e:	fe840613          	addi	a2,s0,-24
    80005272:	4581                	li	a1,0
    80005274:	4501                	li	a0,0
    80005276:	00000097          	auipc	ra,0x0
    8000527a:	d28080e7          	jalr	-728(ra) # 80004f9e <argfd>
    return -1;
    8000527e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005280:	04054163          	bltz	a0,800052c2 <sys_write+0x5c>
    80005284:	fe440593          	addi	a1,s0,-28
    80005288:	4509                	li	a0,2
    8000528a:	ffffd097          	auipc	ra,0xffffd
    8000528e:	7ca080e7          	jalr	1994(ra) # 80002a54 <argint>
    return -1;
    80005292:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005294:	02054763          	bltz	a0,800052c2 <sys_write+0x5c>
    80005298:	fd840593          	addi	a1,s0,-40
    8000529c:	4505                	li	a0,1
    8000529e:	ffffd097          	auipc	ra,0xffffd
    800052a2:	7d8080e7          	jalr	2008(ra) # 80002a76 <argaddr>
    return -1;
    800052a6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052a8:	00054d63          	bltz	a0,800052c2 <sys_write+0x5c>
  return filewrite(f, p, n);
    800052ac:	fe442603          	lw	a2,-28(s0)
    800052b0:	fd843583          	ld	a1,-40(s0)
    800052b4:	fe843503          	ld	a0,-24(s0)
    800052b8:	fffff097          	auipc	ra,0xfffff
    800052bc:	4e6080e7          	jalr	1254(ra) # 8000479e <filewrite>
    800052c0:	87aa                	mv	a5,a0
}
    800052c2:	853e                	mv	a0,a5
    800052c4:	70a2                	ld	ra,40(sp)
    800052c6:	7402                	ld	s0,32(sp)
    800052c8:	6145                	addi	sp,sp,48
    800052ca:	8082                	ret

00000000800052cc <sys_close>:
{
    800052cc:	1101                	addi	sp,sp,-32
    800052ce:	ec06                	sd	ra,24(sp)
    800052d0:	e822                	sd	s0,16(sp)
    800052d2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800052d4:	fe040613          	addi	a2,s0,-32
    800052d8:	fec40593          	addi	a1,s0,-20
    800052dc:	4501                	li	a0,0
    800052de:	00000097          	auipc	ra,0x0
    800052e2:	cc0080e7          	jalr	-832(ra) # 80004f9e <argfd>
    return -1;
    800052e6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800052e8:	02054463          	bltz	a0,80005310 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800052ec:	ffffc097          	auipc	ra,0xffffc
    800052f0:	6b2080e7          	jalr	1714(ra) # 8000199e <myproc>
    800052f4:	fec42783          	lw	a5,-20(s0)
    800052f8:	07e9                	addi	a5,a5,26
    800052fa:	078e                	slli	a5,a5,0x3
    800052fc:	953e                	add	a0,a0,a5
    800052fe:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005302:	fe043503          	ld	a0,-32(s0)
    80005306:	fffff097          	auipc	ra,0xfffff
    8000530a:	29c080e7          	jalr	668(ra) # 800045a2 <fileclose>
  return 0;
    8000530e:	4781                	li	a5,0
}
    80005310:	853e                	mv	a0,a5
    80005312:	60e2                	ld	ra,24(sp)
    80005314:	6442                	ld	s0,16(sp)
    80005316:	6105                	addi	sp,sp,32
    80005318:	8082                	ret

000000008000531a <sys_fstat>:
{
    8000531a:	1101                	addi	sp,sp,-32
    8000531c:	ec06                	sd	ra,24(sp)
    8000531e:	e822                	sd	s0,16(sp)
    80005320:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005322:	fe840613          	addi	a2,s0,-24
    80005326:	4581                	li	a1,0
    80005328:	4501                	li	a0,0
    8000532a:	00000097          	auipc	ra,0x0
    8000532e:	c74080e7          	jalr	-908(ra) # 80004f9e <argfd>
    return -1;
    80005332:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005334:	02054563          	bltz	a0,8000535e <sys_fstat+0x44>
    80005338:	fe040593          	addi	a1,s0,-32
    8000533c:	4505                	li	a0,1
    8000533e:	ffffd097          	auipc	ra,0xffffd
    80005342:	738080e7          	jalr	1848(ra) # 80002a76 <argaddr>
    return -1;
    80005346:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005348:	00054b63          	bltz	a0,8000535e <sys_fstat+0x44>
  return filestat(f, st);
    8000534c:	fe043583          	ld	a1,-32(s0)
    80005350:	fe843503          	ld	a0,-24(s0)
    80005354:	fffff097          	auipc	ra,0xfffff
    80005358:	316080e7          	jalr	790(ra) # 8000466a <filestat>
    8000535c:	87aa                	mv	a5,a0
}
    8000535e:	853e                	mv	a0,a5
    80005360:	60e2                	ld	ra,24(sp)
    80005362:	6442                	ld	s0,16(sp)
    80005364:	6105                	addi	sp,sp,32
    80005366:	8082                	ret

0000000080005368 <sys_link>:
{
    80005368:	7169                	addi	sp,sp,-304
    8000536a:	f606                	sd	ra,296(sp)
    8000536c:	f222                	sd	s0,288(sp)
    8000536e:	ee26                	sd	s1,280(sp)
    80005370:	ea4a                	sd	s2,272(sp)
    80005372:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005374:	08000613          	li	a2,128
    80005378:	ed040593          	addi	a1,s0,-304
    8000537c:	4501                	li	a0,0
    8000537e:	ffffd097          	auipc	ra,0xffffd
    80005382:	71a080e7          	jalr	1818(ra) # 80002a98 <argstr>
    return -1;
    80005386:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005388:	10054e63          	bltz	a0,800054a4 <sys_link+0x13c>
    8000538c:	08000613          	li	a2,128
    80005390:	f5040593          	addi	a1,s0,-176
    80005394:	4505                	li	a0,1
    80005396:	ffffd097          	auipc	ra,0xffffd
    8000539a:	702080e7          	jalr	1794(ra) # 80002a98 <argstr>
    return -1;
    8000539e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053a0:	10054263          	bltz	a0,800054a4 <sys_link+0x13c>
  begin_op();
    800053a4:	fffff097          	auipc	ra,0xfffff
    800053a8:	d36080e7          	jalr	-714(ra) # 800040da <begin_op>
  if((ip = namei(old)) == 0){
    800053ac:	ed040513          	addi	a0,s0,-304
    800053b0:	fffff097          	auipc	ra,0xfffff
    800053b4:	b0a080e7          	jalr	-1270(ra) # 80003eba <namei>
    800053b8:	84aa                	mv	s1,a0
    800053ba:	c551                	beqz	a0,80005446 <sys_link+0xde>
  ilock(ip);
    800053bc:	ffffe097          	auipc	ra,0xffffe
    800053c0:	342080e7          	jalr	834(ra) # 800036fe <ilock>
  if(ip->type == T_DIR){
    800053c4:	04449703          	lh	a4,68(s1)
    800053c8:	4785                	li	a5,1
    800053ca:	08f70463          	beq	a4,a5,80005452 <sys_link+0xea>
  ip->nlink++;
    800053ce:	04a4d783          	lhu	a5,74(s1)
    800053d2:	2785                	addiw	a5,a5,1
    800053d4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053d8:	8526                	mv	a0,s1
    800053da:	ffffe097          	auipc	ra,0xffffe
    800053de:	258080e7          	jalr	600(ra) # 80003632 <iupdate>
  iunlock(ip);
    800053e2:	8526                	mv	a0,s1
    800053e4:	ffffe097          	auipc	ra,0xffffe
    800053e8:	3dc080e7          	jalr	988(ra) # 800037c0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800053ec:	fd040593          	addi	a1,s0,-48
    800053f0:	f5040513          	addi	a0,s0,-176
    800053f4:	fffff097          	auipc	ra,0xfffff
    800053f8:	ae4080e7          	jalr	-1308(ra) # 80003ed8 <nameiparent>
    800053fc:	892a                	mv	s2,a0
    800053fe:	c935                	beqz	a0,80005472 <sys_link+0x10a>
  ilock(dp);
    80005400:	ffffe097          	auipc	ra,0xffffe
    80005404:	2fe080e7          	jalr	766(ra) # 800036fe <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005408:	00092703          	lw	a4,0(s2)
    8000540c:	409c                	lw	a5,0(s1)
    8000540e:	04f71d63          	bne	a4,a5,80005468 <sys_link+0x100>
    80005412:	40d0                	lw	a2,4(s1)
    80005414:	fd040593          	addi	a1,s0,-48
    80005418:	854a                	mv	a0,s2
    8000541a:	fffff097          	auipc	ra,0xfffff
    8000541e:	9de080e7          	jalr	-1570(ra) # 80003df8 <dirlink>
    80005422:	04054363          	bltz	a0,80005468 <sys_link+0x100>
  iunlockput(dp);
    80005426:	854a                	mv	a0,s2
    80005428:	ffffe097          	auipc	ra,0xffffe
    8000542c:	538080e7          	jalr	1336(ra) # 80003960 <iunlockput>
  iput(ip);
    80005430:	8526                	mv	a0,s1
    80005432:	ffffe097          	auipc	ra,0xffffe
    80005436:	486080e7          	jalr	1158(ra) # 800038b8 <iput>
  end_op();
    8000543a:	fffff097          	auipc	ra,0xfffff
    8000543e:	d1e080e7          	jalr	-738(ra) # 80004158 <end_op>
  return 0;
    80005442:	4781                	li	a5,0
    80005444:	a085                	j	800054a4 <sys_link+0x13c>
    end_op();
    80005446:	fffff097          	auipc	ra,0xfffff
    8000544a:	d12080e7          	jalr	-750(ra) # 80004158 <end_op>
    return -1;
    8000544e:	57fd                	li	a5,-1
    80005450:	a891                	j	800054a4 <sys_link+0x13c>
    iunlockput(ip);
    80005452:	8526                	mv	a0,s1
    80005454:	ffffe097          	auipc	ra,0xffffe
    80005458:	50c080e7          	jalr	1292(ra) # 80003960 <iunlockput>
    end_op();
    8000545c:	fffff097          	auipc	ra,0xfffff
    80005460:	cfc080e7          	jalr	-772(ra) # 80004158 <end_op>
    return -1;
    80005464:	57fd                	li	a5,-1
    80005466:	a83d                	j	800054a4 <sys_link+0x13c>
    iunlockput(dp);
    80005468:	854a                	mv	a0,s2
    8000546a:	ffffe097          	auipc	ra,0xffffe
    8000546e:	4f6080e7          	jalr	1270(ra) # 80003960 <iunlockput>
  ilock(ip);
    80005472:	8526                	mv	a0,s1
    80005474:	ffffe097          	auipc	ra,0xffffe
    80005478:	28a080e7          	jalr	650(ra) # 800036fe <ilock>
  ip->nlink--;
    8000547c:	04a4d783          	lhu	a5,74(s1)
    80005480:	37fd                	addiw	a5,a5,-1
    80005482:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005486:	8526                	mv	a0,s1
    80005488:	ffffe097          	auipc	ra,0xffffe
    8000548c:	1aa080e7          	jalr	426(ra) # 80003632 <iupdate>
  iunlockput(ip);
    80005490:	8526                	mv	a0,s1
    80005492:	ffffe097          	auipc	ra,0xffffe
    80005496:	4ce080e7          	jalr	1230(ra) # 80003960 <iunlockput>
  end_op();
    8000549a:	fffff097          	auipc	ra,0xfffff
    8000549e:	cbe080e7          	jalr	-834(ra) # 80004158 <end_op>
  return -1;
    800054a2:	57fd                	li	a5,-1
}
    800054a4:	853e                	mv	a0,a5
    800054a6:	70b2                	ld	ra,296(sp)
    800054a8:	7412                	ld	s0,288(sp)
    800054aa:	64f2                	ld	s1,280(sp)
    800054ac:	6952                	ld	s2,272(sp)
    800054ae:	6155                	addi	sp,sp,304
    800054b0:	8082                	ret

00000000800054b2 <sys_unlink>:
{
    800054b2:	7151                	addi	sp,sp,-240
    800054b4:	f586                	sd	ra,232(sp)
    800054b6:	f1a2                	sd	s0,224(sp)
    800054b8:	eda6                	sd	s1,216(sp)
    800054ba:	e9ca                	sd	s2,208(sp)
    800054bc:	e5ce                	sd	s3,200(sp)
    800054be:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800054c0:	08000613          	li	a2,128
    800054c4:	f3040593          	addi	a1,s0,-208
    800054c8:	4501                	li	a0,0
    800054ca:	ffffd097          	auipc	ra,0xffffd
    800054ce:	5ce080e7          	jalr	1486(ra) # 80002a98 <argstr>
    800054d2:	18054163          	bltz	a0,80005654 <sys_unlink+0x1a2>
  begin_op();
    800054d6:	fffff097          	auipc	ra,0xfffff
    800054da:	c04080e7          	jalr	-1020(ra) # 800040da <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800054de:	fb040593          	addi	a1,s0,-80
    800054e2:	f3040513          	addi	a0,s0,-208
    800054e6:	fffff097          	auipc	ra,0xfffff
    800054ea:	9f2080e7          	jalr	-1550(ra) # 80003ed8 <nameiparent>
    800054ee:	84aa                	mv	s1,a0
    800054f0:	c979                	beqz	a0,800055c6 <sys_unlink+0x114>
  ilock(dp);
    800054f2:	ffffe097          	auipc	ra,0xffffe
    800054f6:	20c080e7          	jalr	524(ra) # 800036fe <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800054fa:	00003597          	auipc	a1,0x3
    800054fe:	21e58593          	addi	a1,a1,542 # 80008718 <syscalls+0x2d0>
    80005502:	fb040513          	addi	a0,s0,-80
    80005506:	ffffe097          	auipc	ra,0xffffe
    8000550a:	6c2080e7          	jalr	1730(ra) # 80003bc8 <namecmp>
    8000550e:	14050a63          	beqz	a0,80005662 <sys_unlink+0x1b0>
    80005512:	00003597          	auipc	a1,0x3
    80005516:	20e58593          	addi	a1,a1,526 # 80008720 <syscalls+0x2d8>
    8000551a:	fb040513          	addi	a0,s0,-80
    8000551e:	ffffe097          	auipc	ra,0xffffe
    80005522:	6aa080e7          	jalr	1706(ra) # 80003bc8 <namecmp>
    80005526:	12050e63          	beqz	a0,80005662 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000552a:	f2c40613          	addi	a2,s0,-212
    8000552e:	fb040593          	addi	a1,s0,-80
    80005532:	8526                	mv	a0,s1
    80005534:	ffffe097          	auipc	ra,0xffffe
    80005538:	6ae080e7          	jalr	1710(ra) # 80003be2 <dirlookup>
    8000553c:	892a                	mv	s2,a0
    8000553e:	12050263          	beqz	a0,80005662 <sys_unlink+0x1b0>
  ilock(ip);
    80005542:	ffffe097          	auipc	ra,0xffffe
    80005546:	1bc080e7          	jalr	444(ra) # 800036fe <ilock>
  if(ip->nlink < 1)
    8000554a:	04a91783          	lh	a5,74(s2)
    8000554e:	08f05263          	blez	a5,800055d2 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005552:	04491703          	lh	a4,68(s2)
    80005556:	4785                	li	a5,1
    80005558:	08f70563          	beq	a4,a5,800055e2 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000555c:	4641                	li	a2,16
    8000555e:	4581                	li	a1,0
    80005560:	fc040513          	addi	a0,s0,-64
    80005564:	ffffb097          	auipc	ra,0xffffb
    80005568:	768080e7          	jalr	1896(ra) # 80000ccc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000556c:	4741                	li	a4,16
    8000556e:	f2c42683          	lw	a3,-212(s0)
    80005572:	fc040613          	addi	a2,s0,-64
    80005576:	4581                	li	a1,0
    80005578:	8526                	mv	a0,s1
    8000557a:	ffffe097          	auipc	ra,0xffffe
    8000557e:	530080e7          	jalr	1328(ra) # 80003aaa <writei>
    80005582:	47c1                	li	a5,16
    80005584:	0af51563          	bne	a0,a5,8000562e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005588:	04491703          	lh	a4,68(s2)
    8000558c:	4785                	li	a5,1
    8000558e:	0af70863          	beq	a4,a5,8000563e <sys_unlink+0x18c>
  iunlockput(dp);
    80005592:	8526                	mv	a0,s1
    80005594:	ffffe097          	auipc	ra,0xffffe
    80005598:	3cc080e7          	jalr	972(ra) # 80003960 <iunlockput>
  ip->nlink--;
    8000559c:	04a95783          	lhu	a5,74(s2)
    800055a0:	37fd                	addiw	a5,a5,-1
    800055a2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055a6:	854a                	mv	a0,s2
    800055a8:	ffffe097          	auipc	ra,0xffffe
    800055ac:	08a080e7          	jalr	138(ra) # 80003632 <iupdate>
  iunlockput(ip);
    800055b0:	854a                	mv	a0,s2
    800055b2:	ffffe097          	auipc	ra,0xffffe
    800055b6:	3ae080e7          	jalr	942(ra) # 80003960 <iunlockput>
  end_op();
    800055ba:	fffff097          	auipc	ra,0xfffff
    800055be:	b9e080e7          	jalr	-1122(ra) # 80004158 <end_op>
  return 0;
    800055c2:	4501                	li	a0,0
    800055c4:	a84d                	j	80005676 <sys_unlink+0x1c4>
    end_op();
    800055c6:	fffff097          	auipc	ra,0xfffff
    800055ca:	b92080e7          	jalr	-1134(ra) # 80004158 <end_op>
    return -1;
    800055ce:	557d                	li	a0,-1
    800055d0:	a05d                	j	80005676 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800055d2:	00003517          	auipc	a0,0x3
    800055d6:	17650513          	addi	a0,a0,374 # 80008748 <syscalls+0x300>
    800055da:	ffffb097          	auipc	ra,0xffffb
    800055de:	f60080e7          	jalr	-160(ra) # 8000053a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055e2:	04c92703          	lw	a4,76(s2)
    800055e6:	02000793          	li	a5,32
    800055ea:	f6e7f9e3          	bgeu	a5,a4,8000555c <sys_unlink+0xaa>
    800055ee:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055f2:	4741                	li	a4,16
    800055f4:	86ce                	mv	a3,s3
    800055f6:	f1840613          	addi	a2,s0,-232
    800055fa:	4581                	li	a1,0
    800055fc:	854a                	mv	a0,s2
    800055fe:	ffffe097          	auipc	ra,0xffffe
    80005602:	3b4080e7          	jalr	948(ra) # 800039b2 <readi>
    80005606:	47c1                	li	a5,16
    80005608:	00f51b63          	bne	a0,a5,8000561e <sys_unlink+0x16c>
    if(de.inum != 0)
    8000560c:	f1845783          	lhu	a5,-232(s0)
    80005610:	e7a1                	bnez	a5,80005658 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005612:	29c1                	addiw	s3,s3,16
    80005614:	04c92783          	lw	a5,76(s2)
    80005618:	fcf9ede3          	bltu	s3,a5,800055f2 <sys_unlink+0x140>
    8000561c:	b781                	j	8000555c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000561e:	00003517          	auipc	a0,0x3
    80005622:	14250513          	addi	a0,a0,322 # 80008760 <syscalls+0x318>
    80005626:	ffffb097          	auipc	ra,0xffffb
    8000562a:	f14080e7          	jalr	-236(ra) # 8000053a <panic>
    panic("unlink: writei");
    8000562e:	00003517          	auipc	a0,0x3
    80005632:	14a50513          	addi	a0,a0,330 # 80008778 <syscalls+0x330>
    80005636:	ffffb097          	auipc	ra,0xffffb
    8000563a:	f04080e7          	jalr	-252(ra) # 8000053a <panic>
    dp->nlink--;
    8000563e:	04a4d783          	lhu	a5,74(s1)
    80005642:	37fd                	addiw	a5,a5,-1
    80005644:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005648:	8526                	mv	a0,s1
    8000564a:	ffffe097          	auipc	ra,0xffffe
    8000564e:	fe8080e7          	jalr	-24(ra) # 80003632 <iupdate>
    80005652:	b781                	j	80005592 <sys_unlink+0xe0>
    return -1;
    80005654:	557d                	li	a0,-1
    80005656:	a005                	j	80005676 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005658:	854a                	mv	a0,s2
    8000565a:	ffffe097          	auipc	ra,0xffffe
    8000565e:	306080e7          	jalr	774(ra) # 80003960 <iunlockput>
  iunlockput(dp);
    80005662:	8526                	mv	a0,s1
    80005664:	ffffe097          	auipc	ra,0xffffe
    80005668:	2fc080e7          	jalr	764(ra) # 80003960 <iunlockput>
  end_op();
    8000566c:	fffff097          	auipc	ra,0xfffff
    80005670:	aec080e7          	jalr	-1300(ra) # 80004158 <end_op>
  return -1;
    80005674:	557d                	li	a0,-1
}
    80005676:	70ae                	ld	ra,232(sp)
    80005678:	740e                	ld	s0,224(sp)
    8000567a:	64ee                	ld	s1,216(sp)
    8000567c:	694e                	ld	s2,208(sp)
    8000567e:	69ae                	ld	s3,200(sp)
    80005680:	616d                	addi	sp,sp,240
    80005682:	8082                	ret

0000000080005684 <sys_open>:

uint64
sys_open(void)
{
    80005684:	7131                	addi	sp,sp,-192
    80005686:	fd06                	sd	ra,184(sp)
    80005688:	f922                	sd	s0,176(sp)
    8000568a:	f526                	sd	s1,168(sp)
    8000568c:	f14a                	sd	s2,160(sp)
    8000568e:	ed4e                	sd	s3,152(sp)
    80005690:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005692:	08000613          	li	a2,128
    80005696:	f5040593          	addi	a1,s0,-176
    8000569a:	4501                	li	a0,0
    8000569c:	ffffd097          	auipc	ra,0xffffd
    800056a0:	3fc080e7          	jalr	1020(ra) # 80002a98 <argstr>
    return -1;
    800056a4:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800056a6:	0c054163          	bltz	a0,80005768 <sys_open+0xe4>
    800056aa:	f4c40593          	addi	a1,s0,-180
    800056ae:	4505                	li	a0,1
    800056b0:	ffffd097          	auipc	ra,0xffffd
    800056b4:	3a4080e7          	jalr	932(ra) # 80002a54 <argint>
    800056b8:	0a054863          	bltz	a0,80005768 <sys_open+0xe4>

  begin_op();
    800056bc:	fffff097          	auipc	ra,0xfffff
    800056c0:	a1e080e7          	jalr	-1506(ra) # 800040da <begin_op>

  if(omode & O_CREATE){
    800056c4:	f4c42783          	lw	a5,-180(s0)
    800056c8:	2007f793          	andi	a5,a5,512
    800056cc:	cbdd                	beqz	a5,80005782 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800056ce:	4681                	li	a3,0
    800056d0:	4601                	li	a2,0
    800056d2:	4589                	li	a1,2
    800056d4:	f5040513          	addi	a0,s0,-176
    800056d8:	00000097          	auipc	ra,0x0
    800056dc:	970080e7          	jalr	-1680(ra) # 80005048 <create>
    800056e0:	892a                	mv	s2,a0
    if(ip == 0){
    800056e2:	c959                	beqz	a0,80005778 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800056e4:	04491703          	lh	a4,68(s2)
    800056e8:	478d                	li	a5,3
    800056ea:	00f71763          	bne	a4,a5,800056f8 <sys_open+0x74>
    800056ee:	04695703          	lhu	a4,70(s2)
    800056f2:	47a5                	li	a5,9
    800056f4:	0ce7ec63          	bltu	a5,a4,800057cc <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800056f8:	fffff097          	auipc	ra,0xfffff
    800056fc:	dee080e7          	jalr	-530(ra) # 800044e6 <filealloc>
    80005700:	89aa                	mv	s3,a0
    80005702:	10050263          	beqz	a0,80005806 <sys_open+0x182>
    80005706:	00000097          	auipc	ra,0x0
    8000570a:	900080e7          	jalr	-1792(ra) # 80005006 <fdalloc>
    8000570e:	84aa                	mv	s1,a0
    80005710:	0e054663          	bltz	a0,800057fc <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005714:	04491703          	lh	a4,68(s2)
    80005718:	478d                	li	a5,3
    8000571a:	0cf70463          	beq	a4,a5,800057e2 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000571e:	4789                	li	a5,2
    80005720:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005724:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005728:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000572c:	f4c42783          	lw	a5,-180(s0)
    80005730:	0017c713          	xori	a4,a5,1
    80005734:	8b05                	andi	a4,a4,1
    80005736:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000573a:	0037f713          	andi	a4,a5,3
    8000573e:	00e03733          	snez	a4,a4
    80005742:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005746:	4007f793          	andi	a5,a5,1024
    8000574a:	c791                	beqz	a5,80005756 <sys_open+0xd2>
    8000574c:	04491703          	lh	a4,68(s2)
    80005750:	4789                	li	a5,2
    80005752:	08f70f63          	beq	a4,a5,800057f0 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005756:	854a                	mv	a0,s2
    80005758:	ffffe097          	auipc	ra,0xffffe
    8000575c:	068080e7          	jalr	104(ra) # 800037c0 <iunlock>
  end_op();
    80005760:	fffff097          	auipc	ra,0xfffff
    80005764:	9f8080e7          	jalr	-1544(ra) # 80004158 <end_op>

  return fd;
}
    80005768:	8526                	mv	a0,s1
    8000576a:	70ea                	ld	ra,184(sp)
    8000576c:	744a                	ld	s0,176(sp)
    8000576e:	74aa                	ld	s1,168(sp)
    80005770:	790a                	ld	s2,160(sp)
    80005772:	69ea                	ld	s3,152(sp)
    80005774:	6129                	addi	sp,sp,192
    80005776:	8082                	ret
      end_op();
    80005778:	fffff097          	auipc	ra,0xfffff
    8000577c:	9e0080e7          	jalr	-1568(ra) # 80004158 <end_op>
      return -1;
    80005780:	b7e5                	j	80005768 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005782:	f5040513          	addi	a0,s0,-176
    80005786:	ffffe097          	auipc	ra,0xffffe
    8000578a:	734080e7          	jalr	1844(ra) # 80003eba <namei>
    8000578e:	892a                	mv	s2,a0
    80005790:	c905                	beqz	a0,800057c0 <sys_open+0x13c>
    ilock(ip);
    80005792:	ffffe097          	auipc	ra,0xffffe
    80005796:	f6c080e7          	jalr	-148(ra) # 800036fe <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000579a:	04491703          	lh	a4,68(s2)
    8000579e:	4785                	li	a5,1
    800057a0:	f4f712e3          	bne	a4,a5,800056e4 <sys_open+0x60>
    800057a4:	f4c42783          	lw	a5,-180(s0)
    800057a8:	dba1                	beqz	a5,800056f8 <sys_open+0x74>
      iunlockput(ip);
    800057aa:	854a                	mv	a0,s2
    800057ac:	ffffe097          	auipc	ra,0xffffe
    800057b0:	1b4080e7          	jalr	436(ra) # 80003960 <iunlockput>
      end_op();
    800057b4:	fffff097          	auipc	ra,0xfffff
    800057b8:	9a4080e7          	jalr	-1628(ra) # 80004158 <end_op>
      return -1;
    800057bc:	54fd                	li	s1,-1
    800057be:	b76d                	j	80005768 <sys_open+0xe4>
      end_op();
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	998080e7          	jalr	-1640(ra) # 80004158 <end_op>
      return -1;
    800057c8:	54fd                	li	s1,-1
    800057ca:	bf79                	j	80005768 <sys_open+0xe4>
    iunlockput(ip);
    800057cc:	854a                	mv	a0,s2
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	192080e7          	jalr	402(ra) # 80003960 <iunlockput>
    end_op();
    800057d6:	fffff097          	auipc	ra,0xfffff
    800057da:	982080e7          	jalr	-1662(ra) # 80004158 <end_op>
    return -1;
    800057de:	54fd                	li	s1,-1
    800057e0:	b761                	j	80005768 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800057e2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800057e6:	04691783          	lh	a5,70(s2)
    800057ea:	02f99223          	sh	a5,36(s3)
    800057ee:	bf2d                	j	80005728 <sys_open+0xa4>
    itrunc(ip);
    800057f0:	854a                	mv	a0,s2
    800057f2:	ffffe097          	auipc	ra,0xffffe
    800057f6:	01a080e7          	jalr	26(ra) # 8000380c <itrunc>
    800057fa:	bfb1                	j	80005756 <sys_open+0xd2>
      fileclose(f);
    800057fc:	854e                	mv	a0,s3
    800057fe:	fffff097          	auipc	ra,0xfffff
    80005802:	da4080e7          	jalr	-604(ra) # 800045a2 <fileclose>
    iunlockput(ip);
    80005806:	854a                	mv	a0,s2
    80005808:	ffffe097          	auipc	ra,0xffffe
    8000580c:	158080e7          	jalr	344(ra) # 80003960 <iunlockput>
    end_op();
    80005810:	fffff097          	auipc	ra,0xfffff
    80005814:	948080e7          	jalr	-1720(ra) # 80004158 <end_op>
    return -1;
    80005818:	54fd                	li	s1,-1
    8000581a:	b7b9                	j	80005768 <sys_open+0xe4>

000000008000581c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000581c:	7175                	addi	sp,sp,-144
    8000581e:	e506                	sd	ra,136(sp)
    80005820:	e122                	sd	s0,128(sp)
    80005822:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005824:	fffff097          	auipc	ra,0xfffff
    80005828:	8b6080e7          	jalr	-1866(ra) # 800040da <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000582c:	08000613          	li	a2,128
    80005830:	f7040593          	addi	a1,s0,-144
    80005834:	4501                	li	a0,0
    80005836:	ffffd097          	auipc	ra,0xffffd
    8000583a:	262080e7          	jalr	610(ra) # 80002a98 <argstr>
    8000583e:	02054963          	bltz	a0,80005870 <sys_mkdir+0x54>
    80005842:	4681                	li	a3,0
    80005844:	4601                	li	a2,0
    80005846:	4585                	li	a1,1
    80005848:	f7040513          	addi	a0,s0,-144
    8000584c:	fffff097          	auipc	ra,0xfffff
    80005850:	7fc080e7          	jalr	2044(ra) # 80005048 <create>
    80005854:	cd11                	beqz	a0,80005870 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005856:	ffffe097          	auipc	ra,0xffffe
    8000585a:	10a080e7          	jalr	266(ra) # 80003960 <iunlockput>
  end_op();
    8000585e:	fffff097          	auipc	ra,0xfffff
    80005862:	8fa080e7          	jalr	-1798(ra) # 80004158 <end_op>
  return 0;
    80005866:	4501                	li	a0,0
}
    80005868:	60aa                	ld	ra,136(sp)
    8000586a:	640a                	ld	s0,128(sp)
    8000586c:	6149                	addi	sp,sp,144
    8000586e:	8082                	ret
    end_op();
    80005870:	fffff097          	auipc	ra,0xfffff
    80005874:	8e8080e7          	jalr	-1816(ra) # 80004158 <end_op>
    return -1;
    80005878:	557d                	li	a0,-1
    8000587a:	b7fd                	j	80005868 <sys_mkdir+0x4c>

000000008000587c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000587c:	7135                	addi	sp,sp,-160
    8000587e:	ed06                	sd	ra,152(sp)
    80005880:	e922                	sd	s0,144(sp)
    80005882:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005884:	fffff097          	auipc	ra,0xfffff
    80005888:	856080e7          	jalr	-1962(ra) # 800040da <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000588c:	08000613          	li	a2,128
    80005890:	f7040593          	addi	a1,s0,-144
    80005894:	4501                	li	a0,0
    80005896:	ffffd097          	auipc	ra,0xffffd
    8000589a:	202080e7          	jalr	514(ra) # 80002a98 <argstr>
    8000589e:	04054a63          	bltz	a0,800058f2 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800058a2:	f6c40593          	addi	a1,s0,-148
    800058a6:	4505                	li	a0,1
    800058a8:	ffffd097          	auipc	ra,0xffffd
    800058ac:	1ac080e7          	jalr	428(ra) # 80002a54 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058b0:	04054163          	bltz	a0,800058f2 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800058b4:	f6840593          	addi	a1,s0,-152
    800058b8:	4509                	li	a0,2
    800058ba:	ffffd097          	auipc	ra,0xffffd
    800058be:	19a080e7          	jalr	410(ra) # 80002a54 <argint>
     argint(1, &major) < 0 ||
    800058c2:	02054863          	bltz	a0,800058f2 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800058c6:	f6841683          	lh	a3,-152(s0)
    800058ca:	f6c41603          	lh	a2,-148(s0)
    800058ce:	458d                	li	a1,3
    800058d0:	f7040513          	addi	a0,s0,-144
    800058d4:	fffff097          	auipc	ra,0xfffff
    800058d8:	774080e7          	jalr	1908(ra) # 80005048 <create>
     argint(2, &minor) < 0 ||
    800058dc:	c919                	beqz	a0,800058f2 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058de:	ffffe097          	auipc	ra,0xffffe
    800058e2:	082080e7          	jalr	130(ra) # 80003960 <iunlockput>
  end_op();
    800058e6:	fffff097          	auipc	ra,0xfffff
    800058ea:	872080e7          	jalr	-1934(ra) # 80004158 <end_op>
  return 0;
    800058ee:	4501                	li	a0,0
    800058f0:	a031                	j	800058fc <sys_mknod+0x80>
    end_op();
    800058f2:	fffff097          	auipc	ra,0xfffff
    800058f6:	866080e7          	jalr	-1946(ra) # 80004158 <end_op>
    return -1;
    800058fa:	557d                	li	a0,-1
}
    800058fc:	60ea                	ld	ra,152(sp)
    800058fe:	644a                	ld	s0,144(sp)
    80005900:	610d                	addi	sp,sp,160
    80005902:	8082                	ret

0000000080005904 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005904:	7135                	addi	sp,sp,-160
    80005906:	ed06                	sd	ra,152(sp)
    80005908:	e922                	sd	s0,144(sp)
    8000590a:	e526                	sd	s1,136(sp)
    8000590c:	e14a                	sd	s2,128(sp)
    8000590e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005910:	ffffc097          	auipc	ra,0xffffc
    80005914:	08e080e7          	jalr	142(ra) # 8000199e <myproc>
    80005918:	892a                	mv	s2,a0
  
  begin_op();
    8000591a:	ffffe097          	auipc	ra,0xffffe
    8000591e:	7c0080e7          	jalr	1984(ra) # 800040da <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005922:	08000613          	li	a2,128
    80005926:	f6040593          	addi	a1,s0,-160
    8000592a:	4501                	li	a0,0
    8000592c:	ffffd097          	auipc	ra,0xffffd
    80005930:	16c080e7          	jalr	364(ra) # 80002a98 <argstr>
    80005934:	04054b63          	bltz	a0,8000598a <sys_chdir+0x86>
    80005938:	f6040513          	addi	a0,s0,-160
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	57e080e7          	jalr	1406(ra) # 80003eba <namei>
    80005944:	84aa                	mv	s1,a0
    80005946:	c131                	beqz	a0,8000598a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005948:	ffffe097          	auipc	ra,0xffffe
    8000594c:	db6080e7          	jalr	-586(ra) # 800036fe <ilock>
  if(ip->type != T_DIR){
    80005950:	04449703          	lh	a4,68(s1)
    80005954:	4785                	li	a5,1
    80005956:	04f71063          	bne	a4,a5,80005996 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000595a:	8526                	mv	a0,s1
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	e64080e7          	jalr	-412(ra) # 800037c0 <iunlock>
  iput(p->cwd);
    80005964:	15093503          	ld	a0,336(s2)
    80005968:	ffffe097          	auipc	ra,0xffffe
    8000596c:	f50080e7          	jalr	-176(ra) # 800038b8 <iput>
  end_op();
    80005970:	ffffe097          	auipc	ra,0xffffe
    80005974:	7e8080e7          	jalr	2024(ra) # 80004158 <end_op>
  p->cwd = ip;
    80005978:	14993823          	sd	s1,336(s2)
  return 0;
    8000597c:	4501                	li	a0,0
}
    8000597e:	60ea                	ld	ra,152(sp)
    80005980:	644a                	ld	s0,144(sp)
    80005982:	64aa                	ld	s1,136(sp)
    80005984:	690a                	ld	s2,128(sp)
    80005986:	610d                	addi	sp,sp,160
    80005988:	8082                	ret
    end_op();
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	7ce080e7          	jalr	1998(ra) # 80004158 <end_op>
    return -1;
    80005992:	557d                	li	a0,-1
    80005994:	b7ed                	j	8000597e <sys_chdir+0x7a>
    iunlockput(ip);
    80005996:	8526                	mv	a0,s1
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	fc8080e7          	jalr	-56(ra) # 80003960 <iunlockput>
    end_op();
    800059a0:	ffffe097          	auipc	ra,0xffffe
    800059a4:	7b8080e7          	jalr	1976(ra) # 80004158 <end_op>
    return -1;
    800059a8:	557d                	li	a0,-1
    800059aa:	bfd1                	j	8000597e <sys_chdir+0x7a>

00000000800059ac <sys_exec>:

uint64
sys_exec(void)
{
    800059ac:	7145                	addi	sp,sp,-464
    800059ae:	e786                	sd	ra,456(sp)
    800059b0:	e3a2                	sd	s0,448(sp)
    800059b2:	ff26                	sd	s1,440(sp)
    800059b4:	fb4a                	sd	s2,432(sp)
    800059b6:	f74e                	sd	s3,424(sp)
    800059b8:	f352                	sd	s4,416(sp)
    800059ba:	ef56                	sd	s5,408(sp)
    800059bc:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800059be:	08000613          	li	a2,128
    800059c2:	f4040593          	addi	a1,s0,-192
    800059c6:	4501                	li	a0,0
    800059c8:	ffffd097          	auipc	ra,0xffffd
    800059cc:	0d0080e7          	jalr	208(ra) # 80002a98 <argstr>
    return -1;
    800059d0:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800059d2:	0c054b63          	bltz	a0,80005aa8 <sys_exec+0xfc>
    800059d6:	e3840593          	addi	a1,s0,-456
    800059da:	4505                	li	a0,1
    800059dc:	ffffd097          	auipc	ra,0xffffd
    800059e0:	09a080e7          	jalr	154(ra) # 80002a76 <argaddr>
    800059e4:	0c054263          	bltz	a0,80005aa8 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800059e8:	10000613          	li	a2,256
    800059ec:	4581                	li	a1,0
    800059ee:	e4040513          	addi	a0,s0,-448
    800059f2:	ffffb097          	auipc	ra,0xffffb
    800059f6:	2da080e7          	jalr	730(ra) # 80000ccc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800059fa:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800059fe:	89a6                	mv	s3,s1
    80005a00:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a02:	02000a13          	li	s4,32
    80005a06:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a0a:	00391513          	slli	a0,s2,0x3
    80005a0e:	e3040593          	addi	a1,s0,-464
    80005a12:	e3843783          	ld	a5,-456(s0)
    80005a16:	953e                	add	a0,a0,a5
    80005a18:	ffffd097          	auipc	ra,0xffffd
    80005a1c:	fa2080e7          	jalr	-94(ra) # 800029ba <fetchaddr>
    80005a20:	02054a63          	bltz	a0,80005a54 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005a24:	e3043783          	ld	a5,-464(s0)
    80005a28:	c3b9                	beqz	a5,80005a6e <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a2a:	ffffb097          	auipc	ra,0xffffb
    80005a2e:	0b6080e7          	jalr	182(ra) # 80000ae0 <kalloc>
    80005a32:	85aa                	mv	a1,a0
    80005a34:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a38:	cd11                	beqz	a0,80005a54 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a3a:	6605                	lui	a2,0x1
    80005a3c:	e3043503          	ld	a0,-464(s0)
    80005a40:	ffffd097          	auipc	ra,0xffffd
    80005a44:	fcc080e7          	jalr	-52(ra) # 80002a0c <fetchstr>
    80005a48:	00054663          	bltz	a0,80005a54 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005a4c:	0905                	addi	s2,s2,1
    80005a4e:	09a1                	addi	s3,s3,8
    80005a50:	fb491be3          	bne	s2,s4,80005a06 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a54:	f4040913          	addi	s2,s0,-192
    80005a58:	6088                	ld	a0,0(s1)
    80005a5a:	c531                	beqz	a0,80005aa6 <sys_exec+0xfa>
    kfree(argv[i]);
    80005a5c:	ffffb097          	auipc	ra,0xffffb
    80005a60:	f86080e7          	jalr	-122(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a64:	04a1                	addi	s1,s1,8
    80005a66:	ff2499e3          	bne	s1,s2,80005a58 <sys_exec+0xac>
  return -1;
    80005a6a:	597d                	li	s2,-1
    80005a6c:	a835                	j	80005aa8 <sys_exec+0xfc>
      argv[i] = 0;
    80005a6e:	0a8e                	slli	s5,s5,0x3
    80005a70:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd81f8>
    80005a74:	00878ab3          	add	s5,a5,s0
    80005a78:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005a7c:	e4040593          	addi	a1,s0,-448
    80005a80:	f4040513          	addi	a0,s0,-192
    80005a84:	fffff097          	auipc	ra,0xfffff
    80005a88:	172080e7          	jalr	370(ra) # 80004bf6 <exec>
    80005a8c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a8e:	f4040993          	addi	s3,s0,-192
    80005a92:	6088                	ld	a0,0(s1)
    80005a94:	c911                	beqz	a0,80005aa8 <sys_exec+0xfc>
    kfree(argv[i]);
    80005a96:	ffffb097          	auipc	ra,0xffffb
    80005a9a:	f4c080e7          	jalr	-180(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a9e:	04a1                	addi	s1,s1,8
    80005aa0:	ff3499e3          	bne	s1,s3,80005a92 <sys_exec+0xe6>
    80005aa4:	a011                	j	80005aa8 <sys_exec+0xfc>
  return -1;
    80005aa6:	597d                	li	s2,-1
}
    80005aa8:	854a                	mv	a0,s2
    80005aaa:	60be                	ld	ra,456(sp)
    80005aac:	641e                	ld	s0,448(sp)
    80005aae:	74fa                	ld	s1,440(sp)
    80005ab0:	795a                	ld	s2,432(sp)
    80005ab2:	79ba                	ld	s3,424(sp)
    80005ab4:	7a1a                	ld	s4,416(sp)
    80005ab6:	6afa                	ld	s5,408(sp)
    80005ab8:	6179                	addi	sp,sp,464
    80005aba:	8082                	ret

0000000080005abc <sys_pipe>:

uint64
sys_pipe(void)
{
    80005abc:	7139                	addi	sp,sp,-64
    80005abe:	fc06                	sd	ra,56(sp)
    80005ac0:	f822                	sd	s0,48(sp)
    80005ac2:	f426                	sd	s1,40(sp)
    80005ac4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ac6:	ffffc097          	auipc	ra,0xffffc
    80005aca:	ed8080e7          	jalr	-296(ra) # 8000199e <myproc>
    80005ace:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005ad0:	fd840593          	addi	a1,s0,-40
    80005ad4:	4501                	li	a0,0
    80005ad6:	ffffd097          	auipc	ra,0xffffd
    80005ada:	fa0080e7          	jalr	-96(ra) # 80002a76 <argaddr>
    return -1;
    80005ade:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005ae0:	0e054063          	bltz	a0,80005bc0 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005ae4:	fc840593          	addi	a1,s0,-56
    80005ae8:	fd040513          	addi	a0,s0,-48
    80005aec:	fffff097          	auipc	ra,0xfffff
    80005af0:	de6080e7          	jalr	-538(ra) # 800048d2 <pipealloc>
    return -1;
    80005af4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005af6:	0c054563          	bltz	a0,80005bc0 <sys_pipe+0x104>
  fd0 = -1;
    80005afa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005afe:	fd043503          	ld	a0,-48(s0)
    80005b02:	fffff097          	auipc	ra,0xfffff
    80005b06:	504080e7          	jalr	1284(ra) # 80005006 <fdalloc>
    80005b0a:	fca42223          	sw	a0,-60(s0)
    80005b0e:	08054c63          	bltz	a0,80005ba6 <sys_pipe+0xea>
    80005b12:	fc843503          	ld	a0,-56(s0)
    80005b16:	fffff097          	auipc	ra,0xfffff
    80005b1a:	4f0080e7          	jalr	1264(ra) # 80005006 <fdalloc>
    80005b1e:	fca42023          	sw	a0,-64(s0)
    80005b22:	06054963          	bltz	a0,80005b94 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b26:	4691                	li	a3,4
    80005b28:	fc440613          	addi	a2,s0,-60
    80005b2c:	fd843583          	ld	a1,-40(s0)
    80005b30:	68a8                	ld	a0,80(s1)
    80005b32:	ffffc097          	auipc	ra,0xffffc
    80005b36:	b30080e7          	jalr	-1232(ra) # 80001662 <copyout>
    80005b3a:	02054063          	bltz	a0,80005b5a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b3e:	4691                	li	a3,4
    80005b40:	fc040613          	addi	a2,s0,-64
    80005b44:	fd843583          	ld	a1,-40(s0)
    80005b48:	0591                	addi	a1,a1,4
    80005b4a:	68a8                	ld	a0,80(s1)
    80005b4c:	ffffc097          	auipc	ra,0xffffc
    80005b50:	b16080e7          	jalr	-1258(ra) # 80001662 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b54:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b56:	06055563          	bgez	a0,80005bc0 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005b5a:	fc442783          	lw	a5,-60(s0)
    80005b5e:	07e9                	addi	a5,a5,26
    80005b60:	078e                	slli	a5,a5,0x3
    80005b62:	97a6                	add	a5,a5,s1
    80005b64:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b68:	fc042783          	lw	a5,-64(s0)
    80005b6c:	07e9                	addi	a5,a5,26
    80005b6e:	078e                	slli	a5,a5,0x3
    80005b70:	00f48533          	add	a0,s1,a5
    80005b74:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b78:	fd043503          	ld	a0,-48(s0)
    80005b7c:	fffff097          	auipc	ra,0xfffff
    80005b80:	a26080e7          	jalr	-1498(ra) # 800045a2 <fileclose>
    fileclose(wf);
    80005b84:	fc843503          	ld	a0,-56(s0)
    80005b88:	fffff097          	auipc	ra,0xfffff
    80005b8c:	a1a080e7          	jalr	-1510(ra) # 800045a2 <fileclose>
    return -1;
    80005b90:	57fd                	li	a5,-1
    80005b92:	a03d                	j	80005bc0 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005b94:	fc442783          	lw	a5,-60(s0)
    80005b98:	0007c763          	bltz	a5,80005ba6 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005b9c:	07e9                	addi	a5,a5,26
    80005b9e:	078e                	slli	a5,a5,0x3
    80005ba0:	97a6                	add	a5,a5,s1
    80005ba2:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005ba6:	fd043503          	ld	a0,-48(s0)
    80005baa:	fffff097          	auipc	ra,0xfffff
    80005bae:	9f8080e7          	jalr	-1544(ra) # 800045a2 <fileclose>
    fileclose(wf);
    80005bb2:	fc843503          	ld	a0,-56(s0)
    80005bb6:	fffff097          	auipc	ra,0xfffff
    80005bba:	9ec080e7          	jalr	-1556(ra) # 800045a2 <fileclose>
    return -1;
    80005bbe:	57fd                	li	a5,-1
}
    80005bc0:	853e                	mv	a0,a5
    80005bc2:	70e2                	ld	ra,56(sp)
    80005bc4:	7442                	ld	s0,48(sp)
    80005bc6:	74a2                	ld	s1,40(sp)
    80005bc8:	6121                	addi	sp,sp,64
    80005bca:	8082                	ret
    80005bcc:	0000                	unimp
	...

0000000080005bd0 <kernelvec>:
    80005bd0:	7111                	addi	sp,sp,-256
    80005bd2:	e006                	sd	ra,0(sp)
    80005bd4:	e40a                	sd	sp,8(sp)
    80005bd6:	e80e                	sd	gp,16(sp)
    80005bd8:	ec12                	sd	tp,24(sp)
    80005bda:	f016                	sd	t0,32(sp)
    80005bdc:	f41a                	sd	t1,40(sp)
    80005bde:	f81e                	sd	t2,48(sp)
    80005be0:	fc22                	sd	s0,56(sp)
    80005be2:	e0a6                	sd	s1,64(sp)
    80005be4:	e4aa                	sd	a0,72(sp)
    80005be6:	e8ae                	sd	a1,80(sp)
    80005be8:	ecb2                	sd	a2,88(sp)
    80005bea:	f0b6                	sd	a3,96(sp)
    80005bec:	f4ba                	sd	a4,104(sp)
    80005bee:	f8be                	sd	a5,112(sp)
    80005bf0:	fcc2                	sd	a6,120(sp)
    80005bf2:	e146                	sd	a7,128(sp)
    80005bf4:	e54a                	sd	s2,136(sp)
    80005bf6:	e94e                	sd	s3,144(sp)
    80005bf8:	ed52                	sd	s4,152(sp)
    80005bfa:	f156                	sd	s5,160(sp)
    80005bfc:	f55a                	sd	s6,168(sp)
    80005bfe:	f95e                	sd	s7,176(sp)
    80005c00:	fd62                	sd	s8,184(sp)
    80005c02:	e1e6                	sd	s9,192(sp)
    80005c04:	e5ea                	sd	s10,200(sp)
    80005c06:	e9ee                	sd	s11,208(sp)
    80005c08:	edf2                	sd	t3,216(sp)
    80005c0a:	f1f6                	sd	t4,224(sp)
    80005c0c:	f5fa                	sd	t5,232(sp)
    80005c0e:	f9fe                	sd	t6,240(sp)
    80005c10:	c77fc0ef          	jal	ra,80002886 <kerneltrap>
    80005c14:	6082                	ld	ra,0(sp)
    80005c16:	6122                	ld	sp,8(sp)
    80005c18:	61c2                	ld	gp,16(sp)
    80005c1a:	7282                	ld	t0,32(sp)
    80005c1c:	7322                	ld	t1,40(sp)
    80005c1e:	73c2                	ld	t2,48(sp)
    80005c20:	7462                	ld	s0,56(sp)
    80005c22:	6486                	ld	s1,64(sp)
    80005c24:	6526                	ld	a0,72(sp)
    80005c26:	65c6                	ld	a1,80(sp)
    80005c28:	6666                	ld	a2,88(sp)
    80005c2a:	7686                	ld	a3,96(sp)
    80005c2c:	7726                	ld	a4,104(sp)
    80005c2e:	77c6                	ld	a5,112(sp)
    80005c30:	7866                	ld	a6,120(sp)
    80005c32:	688a                	ld	a7,128(sp)
    80005c34:	692a                	ld	s2,136(sp)
    80005c36:	69ca                	ld	s3,144(sp)
    80005c38:	6a6a                	ld	s4,152(sp)
    80005c3a:	7a8a                	ld	s5,160(sp)
    80005c3c:	7b2a                	ld	s6,168(sp)
    80005c3e:	7bca                	ld	s7,176(sp)
    80005c40:	7c6a                	ld	s8,184(sp)
    80005c42:	6c8e                	ld	s9,192(sp)
    80005c44:	6d2e                	ld	s10,200(sp)
    80005c46:	6dce                	ld	s11,208(sp)
    80005c48:	6e6e                	ld	t3,216(sp)
    80005c4a:	7e8e                	ld	t4,224(sp)
    80005c4c:	7f2e                	ld	t5,232(sp)
    80005c4e:	7fce                	ld	t6,240(sp)
    80005c50:	6111                	addi	sp,sp,256
    80005c52:	10200073          	sret
    80005c56:	00000013          	nop
    80005c5a:	00000013          	nop
    80005c5e:	0001                	nop

0000000080005c60 <timervec>:
    80005c60:	34051573          	csrrw	a0,mscratch,a0
    80005c64:	e10c                	sd	a1,0(a0)
    80005c66:	e510                	sd	a2,8(a0)
    80005c68:	e914                	sd	a3,16(a0)
    80005c6a:	6d0c                	ld	a1,24(a0)
    80005c6c:	7110                	ld	a2,32(a0)
    80005c6e:	6194                	ld	a3,0(a1)
    80005c70:	96b2                	add	a3,a3,a2
    80005c72:	e194                	sd	a3,0(a1)
    80005c74:	4589                	li	a1,2
    80005c76:	14459073          	csrw	sip,a1
    80005c7a:	6914                	ld	a3,16(a0)
    80005c7c:	6510                	ld	a2,8(a0)
    80005c7e:	610c                	ld	a1,0(a0)
    80005c80:	34051573          	csrrw	a0,mscratch,a0
    80005c84:	30200073          	mret
	...

0000000080005c8a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c8a:	1141                	addi	sp,sp,-16
    80005c8c:	e422                	sd	s0,8(sp)
    80005c8e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c90:	0c0007b7          	lui	a5,0xc000
    80005c94:	4705                	li	a4,1
    80005c96:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c98:	c3d8                	sw	a4,4(a5)
}
    80005c9a:	6422                	ld	s0,8(sp)
    80005c9c:	0141                	addi	sp,sp,16
    80005c9e:	8082                	ret

0000000080005ca0 <plicinithart>:

void
plicinithart(void)
{
    80005ca0:	1141                	addi	sp,sp,-16
    80005ca2:	e406                	sd	ra,8(sp)
    80005ca4:	e022                	sd	s0,0(sp)
    80005ca6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ca8:	ffffc097          	auipc	ra,0xffffc
    80005cac:	cca080e7          	jalr	-822(ra) # 80001972 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005cb0:	0085171b          	slliw	a4,a0,0x8
    80005cb4:	0c0027b7          	lui	a5,0xc002
    80005cb8:	97ba                	add	a5,a5,a4
    80005cba:	40200713          	li	a4,1026
    80005cbe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005cc2:	00d5151b          	slliw	a0,a0,0xd
    80005cc6:	0c2017b7          	lui	a5,0xc201
    80005cca:	97aa                	add	a5,a5,a0
    80005ccc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005cd0:	60a2                	ld	ra,8(sp)
    80005cd2:	6402                	ld	s0,0(sp)
    80005cd4:	0141                	addi	sp,sp,16
    80005cd6:	8082                	ret

0000000080005cd8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005cd8:	1141                	addi	sp,sp,-16
    80005cda:	e406                	sd	ra,8(sp)
    80005cdc:	e022                	sd	s0,0(sp)
    80005cde:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ce0:	ffffc097          	auipc	ra,0xffffc
    80005ce4:	c92080e7          	jalr	-878(ra) # 80001972 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ce8:	00d5151b          	slliw	a0,a0,0xd
    80005cec:	0c2017b7          	lui	a5,0xc201
    80005cf0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005cf2:	43c8                	lw	a0,4(a5)
    80005cf4:	60a2                	ld	ra,8(sp)
    80005cf6:	6402                	ld	s0,0(sp)
    80005cf8:	0141                	addi	sp,sp,16
    80005cfa:	8082                	ret

0000000080005cfc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005cfc:	1101                	addi	sp,sp,-32
    80005cfe:	ec06                	sd	ra,24(sp)
    80005d00:	e822                	sd	s0,16(sp)
    80005d02:	e426                	sd	s1,8(sp)
    80005d04:	1000                	addi	s0,sp,32
    80005d06:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d08:	ffffc097          	auipc	ra,0xffffc
    80005d0c:	c6a080e7          	jalr	-918(ra) # 80001972 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d10:	00d5151b          	slliw	a0,a0,0xd
    80005d14:	0c2017b7          	lui	a5,0xc201
    80005d18:	97aa                	add	a5,a5,a0
    80005d1a:	c3c4                	sw	s1,4(a5)
}
    80005d1c:	60e2                	ld	ra,24(sp)
    80005d1e:	6442                	ld	s0,16(sp)
    80005d20:	64a2                	ld	s1,8(sp)
    80005d22:	6105                	addi	sp,sp,32
    80005d24:	8082                	ret

0000000080005d26 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d26:	1141                	addi	sp,sp,-16
    80005d28:	e406                	sd	ra,8(sp)
    80005d2a:	e022                	sd	s0,0(sp)
    80005d2c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d2e:	479d                	li	a5,7
    80005d30:	06a7c863          	blt	a5,a0,80005da0 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80005d34:	0001d717          	auipc	a4,0x1d
    80005d38:	2cc70713          	addi	a4,a4,716 # 80023000 <disk>
    80005d3c:	972a                	add	a4,a4,a0
    80005d3e:	6789                	lui	a5,0x2
    80005d40:	97ba                	add	a5,a5,a4
    80005d42:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005d46:	e7ad                	bnez	a5,80005db0 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d48:	00451793          	slli	a5,a0,0x4
    80005d4c:	0001f717          	auipc	a4,0x1f
    80005d50:	2b470713          	addi	a4,a4,692 # 80025000 <disk+0x2000>
    80005d54:	6314                	ld	a3,0(a4)
    80005d56:	96be                	add	a3,a3,a5
    80005d58:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005d5c:	6314                	ld	a3,0(a4)
    80005d5e:	96be                	add	a3,a3,a5
    80005d60:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005d64:	6314                	ld	a3,0(a4)
    80005d66:	96be                	add	a3,a3,a5
    80005d68:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005d6c:	6318                	ld	a4,0(a4)
    80005d6e:	97ba                	add	a5,a5,a4
    80005d70:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005d74:	0001d717          	auipc	a4,0x1d
    80005d78:	28c70713          	addi	a4,a4,652 # 80023000 <disk>
    80005d7c:	972a                	add	a4,a4,a0
    80005d7e:	6789                	lui	a5,0x2
    80005d80:	97ba                	add	a5,a5,a4
    80005d82:	4705                	li	a4,1
    80005d84:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005d88:	0001f517          	auipc	a0,0x1f
    80005d8c:	29050513          	addi	a0,a0,656 # 80025018 <disk+0x2018>
    80005d90:	ffffc097          	auipc	ra,0xffffc
    80005d94:	45e080e7          	jalr	1118(ra) # 800021ee <wakeup>
}
    80005d98:	60a2                	ld	ra,8(sp)
    80005d9a:	6402                	ld	s0,0(sp)
    80005d9c:	0141                	addi	sp,sp,16
    80005d9e:	8082                	ret
    panic("free_desc 1");
    80005da0:	00003517          	auipc	a0,0x3
    80005da4:	9e850513          	addi	a0,a0,-1560 # 80008788 <syscalls+0x340>
    80005da8:	ffffa097          	auipc	ra,0xffffa
    80005dac:	792080e7          	jalr	1938(ra) # 8000053a <panic>
    panic("free_desc 2");
    80005db0:	00003517          	auipc	a0,0x3
    80005db4:	9e850513          	addi	a0,a0,-1560 # 80008798 <syscalls+0x350>
    80005db8:	ffffa097          	auipc	ra,0xffffa
    80005dbc:	782080e7          	jalr	1922(ra) # 8000053a <panic>

0000000080005dc0 <virtio_disk_init>:
{
    80005dc0:	1101                	addi	sp,sp,-32
    80005dc2:	ec06                	sd	ra,24(sp)
    80005dc4:	e822                	sd	s0,16(sp)
    80005dc6:	e426                	sd	s1,8(sp)
    80005dc8:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005dca:	00003597          	auipc	a1,0x3
    80005dce:	9de58593          	addi	a1,a1,-1570 # 800087a8 <syscalls+0x360>
    80005dd2:	0001f517          	auipc	a0,0x1f
    80005dd6:	35650513          	addi	a0,a0,854 # 80025128 <disk+0x2128>
    80005dda:	ffffb097          	auipc	ra,0xffffb
    80005dde:	d66080e7          	jalr	-666(ra) # 80000b40 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005de2:	100017b7          	lui	a5,0x10001
    80005de6:	4398                	lw	a4,0(a5)
    80005de8:	2701                	sext.w	a4,a4
    80005dea:	747277b7          	lui	a5,0x74727
    80005dee:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005df2:	0ef71063          	bne	a4,a5,80005ed2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005df6:	100017b7          	lui	a5,0x10001
    80005dfa:	43dc                	lw	a5,4(a5)
    80005dfc:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005dfe:	4705                	li	a4,1
    80005e00:	0ce79963          	bne	a5,a4,80005ed2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e04:	100017b7          	lui	a5,0x10001
    80005e08:	479c                	lw	a5,8(a5)
    80005e0a:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e0c:	4709                	li	a4,2
    80005e0e:	0ce79263          	bne	a5,a4,80005ed2 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e12:	100017b7          	lui	a5,0x10001
    80005e16:	47d8                	lw	a4,12(a5)
    80005e18:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e1a:	554d47b7          	lui	a5,0x554d4
    80005e1e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e22:	0af71863          	bne	a4,a5,80005ed2 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e26:	100017b7          	lui	a5,0x10001
    80005e2a:	4705                	li	a4,1
    80005e2c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e2e:	470d                	li	a4,3
    80005e30:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e32:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e34:	c7ffe6b7          	lui	a3,0xc7ffe
    80005e38:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd7997>
    80005e3c:	8f75                	and	a4,a4,a3
    80005e3e:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e40:	472d                	li	a4,11
    80005e42:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e44:	473d                	li	a4,15
    80005e46:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005e48:	6705                	lui	a4,0x1
    80005e4a:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e4c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e50:	5bdc                	lw	a5,52(a5)
    80005e52:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e54:	c7d9                	beqz	a5,80005ee2 <virtio_disk_init+0x122>
  if(max < NUM)
    80005e56:	471d                	li	a4,7
    80005e58:	08f77d63          	bgeu	a4,a5,80005ef2 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e5c:	100014b7          	lui	s1,0x10001
    80005e60:	47a1                	li	a5,8
    80005e62:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005e64:	6609                	lui	a2,0x2
    80005e66:	4581                	li	a1,0
    80005e68:	0001d517          	auipc	a0,0x1d
    80005e6c:	19850513          	addi	a0,a0,408 # 80023000 <disk>
    80005e70:	ffffb097          	auipc	ra,0xffffb
    80005e74:	e5c080e7          	jalr	-420(ra) # 80000ccc <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005e78:	0001d717          	auipc	a4,0x1d
    80005e7c:	18870713          	addi	a4,a4,392 # 80023000 <disk>
    80005e80:	00c75793          	srli	a5,a4,0xc
    80005e84:	2781                	sext.w	a5,a5
    80005e86:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005e88:	0001f797          	auipc	a5,0x1f
    80005e8c:	17878793          	addi	a5,a5,376 # 80025000 <disk+0x2000>
    80005e90:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005e92:	0001d717          	auipc	a4,0x1d
    80005e96:	1ee70713          	addi	a4,a4,494 # 80023080 <disk+0x80>
    80005e9a:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005e9c:	0001e717          	auipc	a4,0x1e
    80005ea0:	16470713          	addi	a4,a4,356 # 80024000 <disk+0x1000>
    80005ea4:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005ea6:	4705                	li	a4,1
    80005ea8:	00e78c23          	sb	a4,24(a5)
    80005eac:	00e78ca3          	sb	a4,25(a5)
    80005eb0:	00e78d23          	sb	a4,26(a5)
    80005eb4:	00e78da3          	sb	a4,27(a5)
    80005eb8:	00e78e23          	sb	a4,28(a5)
    80005ebc:	00e78ea3          	sb	a4,29(a5)
    80005ec0:	00e78f23          	sb	a4,30(a5)
    80005ec4:	00e78fa3          	sb	a4,31(a5)
}
    80005ec8:	60e2                	ld	ra,24(sp)
    80005eca:	6442                	ld	s0,16(sp)
    80005ecc:	64a2                	ld	s1,8(sp)
    80005ece:	6105                	addi	sp,sp,32
    80005ed0:	8082                	ret
    panic("could not find virtio disk");
    80005ed2:	00003517          	auipc	a0,0x3
    80005ed6:	8e650513          	addi	a0,a0,-1818 # 800087b8 <syscalls+0x370>
    80005eda:	ffffa097          	auipc	ra,0xffffa
    80005ede:	660080e7          	jalr	1632(ra) # 8000053a <panic>
    panic("virtio disk has no queue 0");
    80005ee2:	00003517          	auipc	a0,0x3
    80005ee6:	8f650513          	addi	a0,a0,-1802 # 800087d8 <syscalls+0x390>
    80005eea:	ffffa097          	auipc	ra,0xffffa
    80005eee:	650080e7          	jalr	1616(ra) # 8000053a <panic>
    panic("virtio disk max queue too short");
    80005ef2:	00003517          	auipc	a0,0x3
    80005ef6:	90650513          	addi	a0,a0,-1786 # 800087f8 <syscalls+0x3b0>
    80005efa:	ffffa097          	auipc	ra,0xffffa
    80005efe:	640080e7          	jalr	1600(ra) # 8000053a <panic>

0000000080005f02 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f02:	7119                	addi	sp,sp,-128
    80005f04:	fc86                	sd	ra,120(sp)
    80005f06:	f8a2                	sd	s0,112(sp)
    80005f08:	f4a6                	sd	s1,104(sp)
    80005f0a:	f0ca                	sd	s2,96(sp)
    80005f0c:	ecce                	sd	s3,88(sp)
    80005f0e:	e8d2                	sd	s4,80(sp)
    80005f10:	e4d6                	sd	s5,72(sp)
    80005f12:	e0da                	sd	s6,64(sp)
    80005f14:	fc5e                	sd	s7,56(sp)
    80005f16:	f862                	sd	s8,48(sp)
    80005f18:	f466                	sd	s9,40(sp)
    80005f1a:	f06a                	sd	s10,32(sp)
    80005f1c:	ec6e                	sd	s11,24(sp)
    80005f1e:	0100                	addi	s0,sp,128
    80005f20:	8aaa                	mv	s5,a0
    80005f22:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f24:	00c52c83          	lw	s9,12(a0)
    80005f28:	001c9c9b          	slliw	s9,s9,0x1
    80005f2c:	1c82                	slli	s9,s9,0x20
    80005f2e:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005f32:	0001f517          	auipc	a0,0x1f
    80005f36:	1f650513          	addi	a0,a0,502 # 80025128 <disk+0x2128>
    80005f3a:	ffffb097          	auipc	ra,0xffffb
    80005f3e:	c96080e7          	jalr	-874(ra) # 80000bd0 <acquire>
  for(int i = 0; i < 3; i++){
    80005f42:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005f44:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f46:	0001dc17          	auipc	s8,0x1d
    80005f4a:	0bac0c13          	addi	s8,s8,186 # 80023000 <disk>
    80005f4e:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80005f50:	4b0d                	li	s6,3
    80005f52:	a0ad                	j	80005fbc <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80005f54:	00fc0733          	add	a4,s8,a5
    80005f58:	975e                	add	a4,a4,s7
    80005f5a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005f5e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005f60:	0207c563          	bltz	a5,80005f8a <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005f64:	2905                	addiw	s2,s2,1
    80005f66:	0611                	addi	a2,a2,4
    80005f68:	19690c63          	beq	s2,s6,80006100 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    80005f6c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005f6e:	0001f717          	auipc	a4,0x1f
    80005f72:	0aa70713          	addi	a4,a4,170 # 80025018 <disk+0x2018>
    80005f76:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005f78:	00074683          	lbu	a3,0(a4)
    80005f7c:	fee1                	bnez	a3,80005f54 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005f7e:	2785                	addiw	a5,a5,1
    80005f80:	0705                	addi	a4,a4,1
    80005f82:	fe979be3          	bne	a5,s1,80005f78 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005f86:	57fd                	li	a5,-1
    80005f88:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005f8a:	01205d63          	blez	s2,80005fa4 <virtio_disk_rw+0xa2>
    80005f8e:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005f90:	000a2503          	lw	a0,0(s4)
    80005f94:	00000097          	auipc	ra,0x0
    80005f98:	d92080e7          	jalr	-622(ra) # 80005d26 <free_desc>
      for(int j = 0; j < i; j++)
    80005f9c:	2d85                	addiw	s11,s11,1
    80005f9e:	0a11                	addi	s4,s4,4
    80005fa0:	ff2d98e3          	bne	s11,s2,80005f90 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005fa4:	0001f597          	auipc	a1,0x1f
    80005fa8:	18458593          	addi	a1,a1,388 # 80025128 <disk+0x2128>
    80005fac:	0001f517          	auipc	a0,0x1f
    80005fb0:	06c50513          	addi	a0,a0,108 # 80025018 <disk+0x2018>
    80005fb4:	ffffc097          	auipc	ra,0xffffc
    80005fb8:	0ae080e7          	jalr	174(ra) # 80002062 <sleep>
  for(int i = 0; i < 3; i++){
    80005fbc:	f8040a13          	addi	s4,s0,-128
{
    80005fc0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005fc2:	894e                	mv	s2,s3
    80005fc4:	b765                	j	80005f6c <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005fc6:	0001f697          	auipc	a3,0x1f
    80005fca:	03a6b683          	ld	a3,58(a3) # 80025000 <disk+0x2000>
    80005fce:	96ba                	add	a3,a3,a4
    80005fd0:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005fd4:	0001d817          	auipc	a6,0x1d
    80005fd8:	02c80813          	addi	a6,a6,44 # 80023000 <disk>
    80005fdc:	0001f697          	auipc	a3,0x1f
    80005fe0:	02468693          	addi	a3,a3,36 # 80025000 <disk+0x2000>
    80005fe4:	6290                	ld	a2,0(a3)
    80005fe6:	963a                	add	a2,a2,a4
    80005fe8:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80005fec:	0015e593          	ori	a1,a1,1
    80005ff0:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80005ff4:	f8842603          	lw	a2,-120(s0)
    80005ff8:	628c                	ld	a1,0(a3)
    80005ffa:	972e                	add	a4,a4,a1
    80005ffc:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006000:	20050593          	addi	a1,a0,512
    80006004:	0592                	slli	a1,a1,0x4
    80006006:	95c2                	add	a1,a1,a6
    80006008:	577d                	li	a4,-1
    8000600a:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000600e:	00461713          	slli	a4,a2,0x4
    80006012:	6290                	ld	a2,0(a3)
    80006014:	963a                	add	a2,a2,a4
    80006016:	03078793          	addi	a5,a5,48
    8000601a:	97c2                	add	a5,a5,a6
    8000601c:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    8000601e:	629c                	ld	a5,0(a3)
    80006020:	97ba                	add	a5,a5,a4
    80006022:	4605                	li	a2,1
    80006024:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006026:	629c                	ld	a5,0(a3)
    80006028:	97ba                	add	a5,a5,a4
    8000602a:	4809                	li	a6,2
    8000602c:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006030:	629c                	ld	a5,0(a3)
    80006032:	97ba                	add	a5,a5,a4
    80006034:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006038:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000603c:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006040:	6698                	ld	a4,8(a3)
    80006042:	00275783          	lhu	a5,2(a4)
    80006046:	8b9d                	andi	a5,a5,7
    80006048:	0786                	slli	a5,a5,0x1
    8000604a:	973e                	add	a4,a4,a5
    8000604c:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    80006050:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006054:	6698                	ld	a4,8(a3)
    80006056:	00275783          	lhu	a5,2(a4)
    8000605a:	2785                	addiw	a5,a5,1
    8000605c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006060:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006064:	100017b7          	lui	a5,0x10001
    80006068:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000606c:	004aa783          	lw	a5,4(s5)
    80006070:	02c79163          	bne	a5,a2,80006092 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006074:	0001f917          	auipc	s2,0x1f
    80006078:	0b490913          	addi	s2,s2,180 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    8000607c:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000607e:	85ca                	mv	a1,s2
    80006080:	8556                	mv	a0,s5
    80006082:	ffffc097          	auipc	ra,0xffffc
    80006086:	fe0080e7          	jalr	-32(ra) # 80002062 <sleep>
  while(b->disk == 1) {
    8000608a:	004aa783          	lw	a5,4(s5)
    8000608e:	fe9788e3          	beq	a5,s1,8000607e <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006092:	f8042903          	lw	s2,-128(s0)
    80006096:	20090713          	addi	a4,s2,512
    8000609a:	0712                	slli	a4,a4,0x4
    8000609c:	0001d797          	auipc	a5,0x1d
    800060a0:	f6478793          	addi	a5,a5,-156 # 80023000 <disk>
    800060a4:	97ba                	add	a5,a5,a4
    800060a6:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800060aa:	0001f997          	auipc	s3,0x1f
    800060ae:	f5698993          	addi	s3,s3,-170 # 80025000 <disk+0x2000>
    800060b2:	00491713          	slli	a4,s2,0x4
    800060b6:	0009b783          	ld	a5,0(s3)
    800060ba:	97ba                	add	a5,a5,a4
    800060bc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800060c0:	854a                	mv	a0,s2
    800060c2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800060c6:	00000097          	auipc	ra,0x0
    800060ca:	c60080e7          	jalr	-928(ra) # 80005d26 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800060ce:	8885                	andi	s1,s1,1
    800060d0:	f0ed                	bnez	s1,800060b2 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800060d2:	0001f517          	auipc	a0,0x1f
    800060d6:	05650513          	addi	a0,a0,86 # 80025128 <disk+0x2128>
    800060da:	ffffb097          	auipc	ra,0xffffb
    800060de:	baa080e7          	jalr	-1110(ra) # 80000c84 <release>
}
    800060e2:	70e6                	ld	ra,120(sp)
    800060e4:	7446                	ld	s0,112(sp)
    800060e6:	74a6                	ld	s1,104(sp)
    800060e8:	7906                	ld	s2,96(sp)
    800060ea:	69e6                	ld	s3,88(sp)
    800060ec:	6a46                	ld	s4,80(sp)
    800060ee:	6aa6                	ld	s5,72(sp)
    800060f0:	6b06                	ld	s6,64(sp)
    800060f2:	7be2                	ld	s7,56(sp)
    800060f4:	7c42                	ld	s8,48(sp)
    800060f6:	7ca2                	ld	s9,40(sp)
    800060f8:	7d02                	ld	s10,32(sp)
    800060fa:	6de2                	ld	s11,24(sp)
    800060fc:	6109                	addi	sp,sp,128
    800060fe:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006100:	f8042503          	lw	a0,-128(s0)
    80006104:	20050793          	addi	a5,a0,512
    80006108:	0792                	slli	a5,a5,0x4
  if(write)
    8000610a:	0001d817          	auipc	a6,0x1d
    8000610e:	ef680813          	addi	a6,a6,-266 # 80023000 <disk>
    80006112:	00f80733          	add	a4,a6,a5
    80006116:	01a036b3          	snez	a3,s10
    8000611a:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    8000611e:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006122:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006126:	7679                	lui	a2,0xffffe
    80006128:	963e                	add	a2,a2,a5
    8000612a:	0001f697          	auipc	a3,0x1f
    8000612e:	ed668693          	addi	a3,a3,-298 # 80025000 <disk+0x2000>
    80006132:	6298                	ld	a4,0(a3)
    80006134:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006136:	0a878593          	addi	a1,a5,168
    8000613a:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000613c:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000613e:	6298                	ld	a4,0(a3)
    80006140:	9732                	add	a4,a4,a2
    80006142:	45c1                	li	a1,16
    80006144:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006146:	6298                	ld	a4,0(a3)
    80006148:	9732                	add	a4,a4,a2
    8000614a:	4585                	li	a1,1
    8000614c:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006150:	f8442703          	lw	a4,-124(s0)
    80006154:	628c                	ld	a1,0(a3)
    80006156:	962e                	add	a2,a2,a1
    80006158:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd7246>
  disk.desc[idx[1]].addr = (uint64) b->data;
    8000615c:	0712                	slli	a4,a4,0x4
    8000615e:	6290                	ld	a2,0(a3)
    80006160:	963a                	add	a2,a2,a4
    80006162:	058a8593          	addi	a1,s5,88
    80006166:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006168:	6294                	ld	a3,0(a3)
    8000616a:	96ba                	add	a3,a3,a4
    8000616c:	40000613          	li	a2,1024
    80006170:	c690                	sw	a2,8(a3)
  if(write)
    80006172:	e40d1ae3          	bnez	s10,80005fc6 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006176:	0001f697          	auipc	a3,0x1f
    8000617a:	e8a6b683          	ld	a3,-374(a3) # 80025000 <disk+0x2000>
    8000617e:	96ba                	add	a3,a3,a4
    80006180:	4609                	li	a2,2
    80006182:	00c69623          	sh	a2,12(a3)
    80006186:	b5b9                	j	80005fd4 <virtio_disk_rw+0xd2>

0000000080006188 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006188:	1101                	addi	sp,sp,-32
    8000618a:	ec06                	sd	ra,24(sp)
    8000618c:	e822                	sd	s0,16(sp)
    8000618e:	e426                	sd	s1,8(sp)
    80006190:	e04a                	sd	s2,0(sp)
    80006192:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006194:	0001f517          	auipc	a0,0x1f
    80006198:	f9450513          	addi	a0,a0,-108 # 80025128 <disk+0x2128>
    8000619c:	ffffb097          	auipc	ra,0xffffb
    800061a0:	a34080e7          	jalr	-1484(ra) # 80000bd0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800061a4:	10001737          	lui	a4,0x10001
    800061a8:	533c                	lw	a5,96(a4)
    800061aa:	8b8d                	andi	a5,a5,3
    800061ac:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800061ae:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800061b2:	0001f797          	auipc	a5,0x1f
    800061b6:	e4e78793          	addi	a5,a5,-434 # 80025000 <disk+0x2000>
    800061ba:	6b94                	ld	a3,16(a5)
    800061bc:	0207d703          	lhu	a4,32(a5)
    800061c0:	0026d783          	lhu	a5,2(a3)
    800061c4:	06f70163          	beq	a4,a5,80006226 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800061c8:	0001d917          	auipc	s2,0x1d
    800061cc:	e3890913          	addi	s2,s2,-456 # 80023000 <disk>
    800061d0:	0001f497          	auipc	s1,0x1f
    800061d4:	e3048493          	addi	s1,s1,-464 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800061d8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800061dc:	6898                	ld	a4,16(s1)
    800061de:	0204d783          	lhu	a5,32(s1)
    800061e2:	8b9d                	andi	a5,a5,7
    800061e4:	078e                	slli	a5,a5,0x3
    800061e6:	97ba                	add	a5,a5,a4
    800061e8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800061ea:	20078713          	addi	a4,a5,512
    800061ee:	0712                	slli	a4,a4,0x4
    800061f0:	974a                	add	a4,a4,s2
    800061f2:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800061f6:	e731                	bnez	a4,80006242 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800061f8:	20078793          	addi	a5,a5,512
    800061fc:	0792                	slli	a5,a5,0x4
    800061fe:	97ca                	add	a5,a5,s2
    80006200:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006202:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006206:	ffffc097          	auipc	ra,0xffffc
    8000620a:	fe8080e7          	jalr	-24(ra) # 800021ee <wakeup>

    disk.used_idx += 1;
    8000620e:	0204d783          	lhu	a5,32(s1)
    80006212:	2785                	addiw	a5,a5,1
    80006214:	17c2                	slli	a5,a5,0x30
    80006216:	93c1                	srli	a5,a5,0x30
    80006218:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000621c:	6898                	ld	a4,16(s1)
    8000621e:	00275703          	lhu	a4,2(a4)
    80006222:	faf71be3          	bne	a4,a5,800061d8 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006226:	0001f517          	auipc	a0,0x1f
    8000622a:	f0250513          	addi	a0,a0,-254 # 80025128 <disk+0x2128>
    8000622e:	ffffb097          	auipc	ra,0xffffb
    80006232:	a56080e7          	jalr	-1450(ra) # 80000c84 <release>
}
    80006236:	60e2                	ld	ra,24(sp)
    80006238:	6442                	ld	s0,16(sp)
    8000623a:	64a2                	ld	s1,8(sp)
    8000623c:	6902                	ld	s2,0(sp)
    8000623e:	6105                	addi	sp,sp,32
    80006240:	8082                	ret
      panic("virtio_disk_intr status");
    80006242:	00002517          	auipc	a0,0x2
    80006246:	5d650513          	addi	a0,a0,1494 # 80008818 <syscalls+0x3d0>
    8000624a:	ffffa097          	auipc	ra,0xffffa
    8000624e:	2f0080e7          	jalr	752(ra) # 8000053a <panic>

0000000080006252 <inittweetlock>:
//of addition or removal of a msg in buffer
int getchan = 10, putchan = 20;


//initalize the the tweet lock for each tag array
void inittweetlock(void){
    80006252:	1141                	addi	sp,sp,-16
    80006254:	e406                	sd	ra,8(sp)
    80006256:	e022                	sd	s0,0(sp)
    80006258:	0800                	addi	s0,sp,16
    
    for(int i=0; i<NUMTWEETTOPICS;i++){
        initlock(&alltweetbuff[i].tweettaglock,"tweetlock");
    8000625a:	00002597          	auipc	a1,0x2
    8000625e:	5d658593          	addi	a1,a1,1494 # 80008830 <syscalls+0x3e8>
    80006262:	00020517          	auipc	a0,0x20
    80006266:	21e50513          	addi	a0,a0,542 # 80026480 <alltweetbuff+0x480>
    8000626a:	ffffb097          	auipc	ra,0xffffb
    8000626e:	8d6080e7          	jalr	-1834(ra) # 80000b40 <initlock>
    80006272:	00002597          	auipc	a1,0x2
    80006276:	5be58593          	addi	a1,a1,1470 # 80008830 <syscalls+0x3e8>
    8000627a:	00020517          	auipc	a0,0x20
    8000627e:	69e50513          	addi	a0,a0,1694 # 80026918 <alltweetbuff+0x918>
    80006282:	ffffb097          	auipc	ra,0xffffb
    80006286:	8be080e7          	jalr	-1858(ra) # 80000b40 <initlock>
    8000628a:	00002597          	auipc	a1,0x2
    8000628e:	5a658593          	addi	a1,a1,1446 # 80008830 <syscalls+0x3e8>
    80006292:	00021517          	auipc	a0,0x21
    80006296:	b1e50513          	addi	a0,a0,-1250 # 80026db0 <alltweetbuff+0xdb0>
    8000629a:	ffffb097          	auipc	ra,0xffffb
    8000629e:	8a6080e7          	jalr	-1882(ra) # 80000b40 <initlock>
    }
    
}
    800062a2:	60a2                	ld	ra,8(sp)
    800062a4:	6402                	ld	s0,0(sp)
    800062a6:	0141                	addi	sp,sp,16
    800062a8:	8082                	ret

00000000800062aa <gettagindex>:

//returns the index of msg stored with a given tag, 
//if not found then returns -1 for failure
int gettagindex(topic_t tag){
    800062aa:	7179                	addi	sp,sp,-48
    800062ac:	f406                	sd	ra,40(sp)
    800062ae:	f022                	sd	s0,32(sp)
    800062b0:	ec26                	sd	s1,24(sp)
    800062b2:	e84a                	sd	s2,16(sp)
    800062b4:	e44e                	sd	s3,8(sp)
    800062b6:	e052                	sd	s4,0(sp)
    800062b8:	1800                	addi	s0,sp,48
    800062ba:	89aa                	mv	s3,a0
    
    int index =-1;
    for(int i=0;i<MAXTAGTWEET;i++){
    800062bc:	02051493          	slli	s1,a0,0x20
    800062c0:	9081                	srli	s1,s1,0x20
    800062c2:	49800793          	li	a5,1176
    800062c6:	02f484b3          	mul	s1,s1,a5
    800062ca:	00020797          	auipc	a5,0x20
    800062ce:	d3a78793          	addi	a5,a5,-710 # 80026004 <alltweetbuff+0x4>
    800062d2:	94be                	add	s1,s1,a5
    800062d4:	4901                	li	s2,0
    800062d6:	4a21                	li	s4,8
    800062d8:	a031                	j	800062e4 <gettagindex+0x3a>
    800062da:	2905                	addiw	s2,s2,1
    800062dc:	09048493          	addi	s1,s1,144
    800062e0:	01490e63          	beq	s2,s4,800062fc <gettagindex+0x52>
        if(alltweetbuff[tag].tagtweetbuffer[i].tag==tag&&strlen(alltweetbuff[tag].tagtweetbuffer[i].msg)>0){
    800062e4:	ffc4a783          	lw	a5,-4(s1)
    800062e8:	ff3799e3          	bne	a5,s3,800062da <gettagindex+0x30>
    800062ec:	8526                	mv	a0,s1
    800062ee:	ffffb097          	auipc	ra,0xffffb
    800062f2:	b5a080e7          	jalr	-1190(ra) # 80000e48 <strlen>
    800062f6:	fea052e3          	blez	a0,800062da <gettagindex+0x30>
    800062fa:	a011                	j	800062fe <gettagindex+0x54>
    int index =-1;
    800062fc:	597d                	li	s2,-1
          
        }
    }
    
    return index;
}
    800062fe:	854a                	mv	a0,s2
    80006300:	70a2                	ld	ra,40(sp)
    80006302:	7402                	ld	s0,32(sp)
    80006304:	64e2                	ld	s1,24(sp)
    80006306:	6942                	ld	s2,16(sp)
    80006308:	69a2                	ld	s3,8(sp)
    8000630a:	6a02                	ld	s4,0(sp)
    8000630c:	6145                	addi	sp,sp,48
    8000630e:	8082                	ret

0000000080006310 <getemptyindex>:

//returns the index of empty storage block, 
//if not found then returns -1 for failure
int getemptyindex(topic_t tag){
    80006310:	7179                	addi	sp,sp,-48
    80006312:	f406                	sd	ra,40(sp)
    80006314:	f022                	sd	s0,32(sp)
    80006316:	ec26                	sd	s1,24(sp)
    80006318:	e84a                	sd	s2,16(sp)
    8000631a:	e44e                	sd	s3,8(sp)
    8000631c:	1800                	addi	s0,sp,48
    int index =-1;
    for(int i=0;i<MAXTAGTWEET;i++){
    8000631e:	02051493          	slli	s1,a0,0x20
    80006322:	9081                	srli	s1,s1,0x20
    80006324:	49800793          	li	a5,1176
    80006328:	02f484b3          	mul	s1,s1,a5
    8000632c:	00020797          	auipc	a5,0x20
    80006330:	cd878793          	addi	a5,a5,-808 # 80026004 <alltweetbuff+0x4>
    80006334:	94be                	add	s1,s1,a5
    80006336:	4901                	li	s2,0
    80006338:	49a1                	li	s3,8
        if(strlen(alltweetbuff[tag].tagtweetbuffer[i].msg)==0){
    8000633a:	8526                	mv	a0,s1
    8000633c:	ffffb097          	auipc	ra,0xffffb
    80006340:	b0c080e7          	jalr	-1268(ra) # 80000e48 <strlen>
    80006344:	c519                	beqz	a0,80006352 <getemptyindex+0x42>
    for(int i=0;i<MAXTAGTWEET;i++){
    80006346:	2905                	addiw	s2,s2,1
    80006348:	09048493          	addi	s1,s1,144
    8000634c:	ff3917e3          	bne	s2,s3,8000633a <getemptyindex+0x2a>
    int index =-1;
    80006350:	597d                	li	s2,-1
          
        }
    }
    
    return index;
}
    80006352:	854a                	mv	a0,s2
    80006354:	70a2                	ld	ra,40(sp)
    80006356:	7402                	ld	s0,32(sp)
    80006358:	64e2                	ld	s1,24(sp)
    8000635a:	6942                	ld	s2,16(sp)
    8000635c:	69a2                	ld	s3,8(sp)
    8000635e:	6145                	addi	sp,sp,48
    80006360:	8082                	ret

0000000080006362 <btput>:

//stores the msg in the tweet buffer, if space is avaiable and max tweet threshold is not reached 
// then the tweet is stored. else it goes to sleep mode until the one of the get method calls wakeup 
int
btput(topic_t tag,char* msg)
{
    80006362:	711d                	addi	sp,sp,-96
    80006364:	ec86                	sd	ra,88(sp)
    80006366:	e8a2                	sd	s0,80(sp)
    80006368:	e4a6                	sd	s1,72(sp)
    8000636a:	e0ca                	sd	s2,64(sp)
    8000636c:	fc4e                	sd	s3,56(sp)
    8000636e:	f852                	sd	s4,48(sp)
    80006370:	f456                	sd	s5,40(sp)
    80006372:	f05a                	sd	s6,32(sp)
    80006374:	ec5e                	sd	s7,24(sp)
    80006376:	e862                	sd	s8,16(sp)
    80006378:	e466                	sd	s9,8(sp)
    8000637a:	1080                	addi	s0,sp,96
    8000637c:	892a                	mv	s2,a0
    8000637e:	8c2e                	mv	s8,a1
    acquire(&alltweetbuff[tag].tweettaglock);
    80006380:	02051c93          	slli	s9,a0,0x20
    80006384:	020cdc93          	srli	s9,s9,0x20
    80006388:	49800793          	li	a5,1176
    8000638c:	02fc8cb3          	mul	s9,s9,a5
    80006390:	00020997          	auipc	s3,0x20
    80006394:	0f098993          	addi	s3,s3,240 # 80026480 <alltweetbuff+0x480>
    80006398:	99e6                	add	s3,s3,s9
    8000639a:	854e                	mv	a0,s3
    8000639c:	ffffb097          	auipc	ra,0xffffb
    800063a0:	834080e7          	jalr	-1996(ra) # 80000bd0 <acquire>
    
    int index = getemptyindex(tag);
    800063a4:	854a                	mv	a0,s2
    800063a6:	00000097          	auipc	ra,0x0
    800063aa:	f6a080e7          	jalr	-150(ra) # 80006310 <getemptyindex>
    800063ae:	84aa                	mv	s1,a0
     
    while(index==-1||tweetcounter>MAXTWEETTOTAL){
    800063b0:	5a7d                	li	s4,-1
    800063b2:	00003b97          	auipc	s7,0x3
    800063b6:	c82b8b93          	addi	s7,s7,-894 # 80009034 <tweetcounter>
    800063ba:	4b29                	li	s6,10

        sleep(&getchan,&alltweetbuff[tag].tweettaglock);
    800063bc:	00002a97          	auipc	s5,0x2
    800063c0:	520a8a93          	addi	s5,s5,1312 # 800088dc <getchan>
    while(index==-1||tweetcounter>MAXTWEETTOTAL){
    800063c4:	a829                	j	800063de <btput+0x7c>
        sleep(&getchan,&alltweetbuff[tag].tweettaglock);
    800063c6:	85ce                	mv	a1,s3
    800063c8:	8556                	mv	a0,s5
    800063ca:	ffffc097          	auipc	ra,0xffffc
    800063ce:	c98080e7          	jalr	-872(ra) # 80002062 <sleep>
        index = getemptyindex(tag);
    800063d2:	854a                	mv	a0,s2
    800063d4:	00000097          	auipc	ra,0x0
    800063d8:	f3c080e7          	jalr	-196(ra) # 80006310 <getemptyindex>
    800063dc:	84aa                	mv	s1,a0
    while(index==-1||tweetcounter>MAXTWEETTOTAL){
    800063de:	ff4484e3          	beq	s1,s4,800063c6 <btput+0x64>
    800063e2:	000ba783          	lw	a5,0(s7)
    800063e6:	fefb40e3          	blt	s6,a5,800063c6 <btput+0x64>

    }

         if(strncpy(alltweetbuff[tag].tagtweetbuffer[index].msg,msg,strlen(msg))==0){
    800063ea:	8562                	mv	a0,s8
    800063ec:	ffffb097          	auipc	ra,0xffffb
    800063f0:	a5c080e7          	jalr	-1444(ra) # 80000e48 <strlen>
    800063f4:	862a                	mv	a2,a0
    800063f6:	00349793          	slli	a5,s1,0x3
    800063fa:	97a6                	add	a5,a5,s1
    800063fc:	0792                	slli	a5,a5,0x4
    800063fe:	0c91                	addi	s9,s9,4
    80006400:	97e6                	add	a5,a5,s9
    80006402:	85e2                	mv	a1,s8
    80006404:	00020517          	auipc	a0,0x20
    80006408:	bfc50513          	addi	a0,a0,-1028 # 80026000 <alltweetbuff>
    8000640c:	953e                	add	a0,a0,a5
    8000640e:	ffffb097          	auipc	ra,0xffffb
    80006412:	9ca080e7          	jalr	-1590(ra) # 80000dd8 <strncpy>
    80006416:	c535                	beqz	a0,80006482 <btput+0x120>
             printf("strcpy failed");
             release(&alltweetbuff[tag].tweettaglock);
             return -1;
         }
         alltweetbuff[tag].tagtweetbuffer[index].tag=tag;
    80006418:	02091713          	slli	a4,s2,0x20
    8000641c:	9301                	srli	a4,a4,0x20
    8000641e:	00349793          	slli	a5,s1,0x3
    80006422:	97a6                	add	a5,a5,s1
    80006424:	0792                	slli	a5,a5,0x4
    80006426:	49800693          	li	a3,1176
    8000642a:	02d70733          	mul	a4,a4,a3
    8000642e:	97ba                	add	a5,a5,a4
    80006430:	00020717          	auipc	a4,0x20
    80006434:	bd070713          	addi	a4,a4,-1072 # 80026000 <alltweetbuff>
    80006438:	97ba                	add	a5,a5,a4
    8000643a:	0127a023          	sw	s2,0(a5)
         tweetcounter++;
    8000643e:	00003717          	auipc	a4,0x3
    80006442:	bf670713          	addi	a4,a4,-1034 # 80009034 <tweetcounter>
    80006446:	431c                	lw	a5,0(a4)
    80006448:	2785                	addiw	a5,a5,1
    8000644a:	c31c                	sw	a5,0(a4)
         wakeup(&putchan);
    8000644c:	00002517          	auipc	a0,0x2
    80006450:	48c50513          	addi	a0,a0,1164 # 800088d8 <putchan>
    80006454:	ffffc097          	auipc	ra,0xffffc
    80006458:	d9a080e7          	jalr	-614(ra) # 800021ee <wakeup>
    
    release(&alltweetbuff[tag].tweettaglock);
    8000645c:	854e                	mv	a0,s3
    8000645e:	ffffb097          	auipc	ra,0xffffb
    80006462:	826080e7          	jalr	-2010(ra) # 80000c84 <release>
    
    return 0;
    80006466:	4501                	li	a0,0
}
    80006468:	60e6                	ld	ra,88(sp)
    8000646a:	6446                	ld	s0,80(sp)
    8000646c:	64a6                	ld	s1,72(sp)
    8000646e:	6906                	ld	s2,64(sp)
    80006470:	79e2                	ld	s3,56(sp)
    80006472:	7a42                	ld	s4,48(sp)
    80006474:	7aa2                	ld	s5,40(sp)
    80006476:	7b02                	ld	s6,32(sp)
    80006478:	6be2                	ld	s7,24(sp)
    8000647a:	6c42                	ld	s8,16(sp)
    8000647c:	6ca2                	ld	s9,8(sp)
    8000647e:	6125                	addi	sp,sp,96
    80006480:	8082                	ret
             printf("strcpy failed");
    80006482:	00002517          	auipc	a0,0x2
    80006486:	3be50513          	addi	a0,a0,958 # 80008840 <syscalls+0x3f8>
    8000648a:	ffffa097          	auipc	ra,0xffffa
    8000648e:	0fa080e7          	jalr	250(ra) # 80000584 <printf>
             release(&alltweetbuff[tag].tweettaglock);
    80006492:	854e                	mv	a0,s3
    80006494:	ffffa097          	auipc	ra,0xffffa
    80006498:	7f0080e7          	jalr	2032(ra) # 80000c84 <release>
             return -1;
    8000649c:	557d                	li	a0,-1
    8000649e:	b7e9                	j	80006468 <btput+0x106>

00000000800064a0 <tput>:
//stores the msg in the tweet buffer, if space is avaiable and max tweet threshold is not reached 
// then the tweet is stored. else it returns -1
int
tput(topic_t tag,char* msg){
    800064a0:	715d                	addi	sp,sp,-80
    800064a2:	e486                	sd	ra,72(sp)
    800064a4:	e0a2                	sd	s0,64(sp)
    800064a6:	fc26                	sd	s1,56(sp)
    800064a8:	f84a                	sd	s2,48(sp)
    800064aa:	f44e                	sd	s3,40(sp)
    800064ac:	f052                	sd	s4,32(sp)
    800064ae:	ec56                	sd	s5,24(sp)
    800064b0:	e85a                	sd	s6,16(sp)
    800064b2:	e45e                	sd	s7,8(sp)
    800064b4:	0880                	addi	s0,sp,80
    800064b6:	89aa                	mv	s3,a0
    800064b8:	8b2e                	mv	s6,a1
   
    acquire(&alltweetbuff[tag].tweettaglock);
    800064ba:	02051a13          	slli	s4,a0,0x20
    800064be:	020a5a13          	srli	s4,s4,0x20
    800064c2:	49800793          	li	a5,1176
    800064c6:	02fa0a33          	mul	s4,s4,a5
    800064ca:	00020a97          	auipc	s5,0x20
    800064ce:	fb6a8a93          	addi	s5,s5,-74 # 80026480 <alltweetbuff+0x480>
    800064d2:	9ad2                	add	s5,s5,s4
    800064d4:	8556                	mv	a0,s5
    800064d6:	ffffa097          	auipc	ra,0xffffa
    800064da:	6fa080e7          	jalr	1786(ra) # 80000bd0 <acquire>
  
    int index = getemptyindex(tag);
    800064de:	854e                	mv	a0,s3
    800064e0:	00000097          	auipc	ra,0x0
    800064e4:	e30080e7          	jalr	-464(ra) # 80006310 <getemptyindex>
    800064e8:	84aa                	mv	s1,a0
    
    if(index!=-1||tweetcounter>MAXTWEETTOTAL){
    800064ea:	57fd                	li	a5,-1
    800064ec:	00f51963          	bne	a0,a5,800064fe <tput+0x5e>
    800064f0:	00003717          	auipc	a4,0x3
    800064f4:	b4472703          	lw	a4,-1212(a4) # 80009034 <tweetcounter>
    800064f8:	47a9                	li	a5,10
    800064fa:	08e7d863          	bge	a5,a4,8000658a <tput+0xea>
         strncpy(alltweetbuff[tag].tagtweetbuffer[index].msg,msg,strlen(msg));
    800064fe:	855a                	mv	a0,s6
    80006500:	ffffb097          	auipc	ra,0xffffb
    80006504:	948080e7          	jalr	-1720(ra) # 80000e48 <strlen>
    80006508:	862a                	mv	a2,a0
    8000650a:	00349913          	slli	s2,s1,0x3
    8000650e:	009907b3          	add	a5,s2,s1
    80006512:	0792                	slli	a5,a5,0x4
    80006514:	0a11                	addi	s4,s4,4
    80006516:	9a3e                	add	s4,s4,a5
    80006518:	00020b97          	auipc	s7,0x20
    8000651c:	ae8b8b93          	addi	s7,s7,-1304 # 80026000 <alltweetbuff>
    80006520:	85da                	mv	a1,s6
    80006522:	014b8533          	add	a0,s7,s4
    80006526:	ffffb097          	auipc	ra,0xffffb
    8000652a:	8b2080e7          	jalr	-1870(ra) # 80000dd8 <strncpy>
         alltweetbuff[tag].tagtweetbuffer[index].tag=tag;
    8000652e:	02099793          	slli	a5,s3,0x20
    80006532:	9381                	srli	a5,a5,0x20
    80006534:	9926                	add	s2,s2,s1
    80006536:	0912                	slli	s2,s2,0x4
    80006538:	49800713          	li	a4,1176
    8000653c:	02e787b3          	mul	a5,a5,a4
    80006540:	993e                	add	s2,s2,a5
    80006542:	9bca                	add	s7,s7,s2
    80006544:	013ba023          	sw	s3,0(s7)
         tweetcounter++;
    80006548:	00003717          	auipc	a4,0x3
    8000654c:	aec70713          	addi	a4,a4,-1300 # 80009034 <tweetcounter>
    80006550:	431c                	lw	a5,0(a4)
    80006552:	2785                	addiw	a5,a5,1
    80006554:	c31c                	sw	a5,0(a4)
         wakeup(&getchan);
    80006556:	00002517          	auipc	a0,0x2
    8000655a:	38650513          	addi	a0,a0,902 # 800088dc <getchan>
    8000655e:	ffffc097          	auipc	ra,0xffffc
    80006562:	c90080e7          	jalr	-880(ra) # 800021ee <wakeup>
        printf("No space available to put new msg returing -1\n");
         release(&alltweetbuff[tag].tweettaglock);
        return -1;
    }
   
    release(&alltweetbuff[tag].tweettaglock);
    80006566:	8556                	mv	a0,s5
    80006568:	ffffa097          	auipc	ra,0xffffa
    8000656c:	71c080e7          	jalr	1820(ra) # 80000c84 <release>
   
    
    return 0;
    80006570:	4481                	li	s1,0
}
    80006572:	8526                	mv	a0,s1
    80006574:	60a6                	ld	ra,72(sp)
    80006576:	6406                	ld	s0,64(sp)
    80006578:	74e2                	ld	s1,56(sp)
    8000657a:	7942                	ld	s2,48(sp)
    8000657c:	79a2                	ld	s3,40(sp)
    8000657e:	7a02                	ld	s4,32(sp)
    80006580:	6ae2                	ld	s5,24(sp)
    80006582:	6b42                	ld	s6,16(sp)
    80006584:	6ba2                	ld	s7,8(sp)
    80006586:	6161                	addi	sp,sp,80
    80006588:	8082                	ret
        printf("No space available to put new msg returing -1\n");
    8000658a:	00002517          	auipc	a0,0x2
    8000658e:	2c650513          	addi	a0,a0,710 # 80008850 <syscalls+0x408>
    80006592:	ffffa097          	auipc	ra,0xffffa
    80006596:	ff2080e7          	jalr	-14(ra) # 80000584 <printf>
         release(&alltweetbuff[tag].tweettaglock);
    8000659a:	8556                	mv	a0,s5
    8000659c:	ffffa097          	auipc	ra,0xffffa
    800065a0:	6e8080e7          	jalr	1768(ra) # 80000c84 <release>
        return -1;
    800065a4:	b7f9                	j	80006572 <tput+0xd2>

00000000800065a6 <btget>:
//gets the msg from the tweet buffer, if msg is avaiable with a given tag
// then the tweet is returned to user program. else it goes to sleep mode until the one of the put method calls wakeup 
//Also returns -1 if the copyout fails 
int 
btget(topic_t tag,uint64 buf){
    800065a6:	715d                	addi	sp,sp,-80
    800065a8:	e486                	sd	ra,72(sp)
    800065aa:	e0a2                	sd	s0,64(sp)
    800065ac:	fc26                	sd	s1,56(sp)
    800065ae:	f84a                	sd	s2,48(sp)
    800065b0:	f44e                	sd	s3,40(sp)
    800065b2:	f052                	sd	s4,32(sp)
    800065b4:	ec56                	sd	s5,24(sp)
    800065b6:	e85a                	sd	s6,16(sp)
    800065b8:	e45e                	sd	s7,8(sp)
    800065ba:	0880                	addi	s0,sp,80
    800065bc:	84aa                	mv	s1,a0
    800065be:	89ae                	mv	s3,a1
   
    struct proc *p = myproc();
    800065c0:	ffffb097          	auipc	ra,0xffffb
    800065c4:	3de080e7          	jalr	990(ra) # 8000199e <myproc>
    800065c8:	8a2a                	mv	s4,a0
 
    acquire(&alltweetbuff[tag].tweettaglock);
    800065ca:	02049a93          	slli	s5,s1,0x20
    800065ce:	020ada93          	srli	s5,s5,0x20
    800065d2:	49800793          	li	a5,1176
    800065d6:	02fa8ab3          	mul	s5,s5,a5
    800065da:	00020917          	auipc	s2,0x20
    800065de:	ea690913          	addi	s2,s2,-346 # 80026480 <alltweetbuff+0x480>
    800065e2:	9956                	add	s2,s2,s5
    800065e4:	854a                	mv	a0,s2
    800065e6:	ffffa097          	auipc	ra,0xffffa
    800065ea:	5ea080e7          	jalr	1514(ra) # 80000bd0 <acquire>

    int index = gettagindex(tag);
    800065ee:	8526                	mv	a0,s1
    800065f0:	00000097          	auipc	ra,0x0
    800065f4:	cba080e7          	jalr	-838(ra) # 800062aa <gettagindex>
    
     while(index==-1){
    800065f8:	57fd                	li	a5,-1
    800065fa:	02f51463          	bne	a0,a5,80006622 <btget+0x7c>

        sleep(&putchan,&alltweetbuff[tag].tweettaglock);
    800065fe:	00002b97          	auipc	s7,0x2
    80006602:	2dab8b93          	addi	s7,s7,730 # 800088d8 <putchan>
     while(index==-1){
    80006606:	5b7d                	li	s6,-1
        sleep(&putchan,&alltweetbuff[tag].tweettaglock);
    80006608:	85ca                	mv	a1,s2
    8000660a:	855e                	mv	a0,s7
    8000660c:	ffffc097          	auipc	ra,0xffffc
    80006610:	a56080e7          	jalr	-1450(ra) # 80002062 <sleep>
        index = getemptyindex(tag);
    80006614:	8526                	mv	a0,s1
    80006616:	00000097          	auipc	ra,0x0
    8000661a:	cfa080e7          	jalr	-774(ra) # 80006310 <getemptyindex>
     while(index==-1){
    8000661e:	ff6505e3          	beq	a0,s6,80006608 <btget+0x62>

    }
         char *temp = alltweetbuff[tag].tagtweetbuffer[index].msg;
    80006622:	00351493          	slli	s1,a0,0x3
    80006626:	94aa                	add	s1,s1,a0
    80006628:	0492                	slli	s1,s1,0x4
    8000662a:	0a91                	addi	s5,s5,4
    8000662c:	94d6                	add	s1,s1,s5
    8000662e:	00020797          	auipc	a5,0x20
    80006632:	9d278793          	addi	a5,a5,-1582 # 80026000 <alltweetbuff>
    80006636:	94be                	add	s1,s1,a5

         if(copyout(p->pagetable,buf,temp,strlen(temp))!=0){
    80006638:	050a3a03          	ld	s4,80(s4)
    8000663c:	8526                	mv	a0,s1
    8000663e:	ffffb097          	auipc	ra,0xffffb
    80006642:	80a080e7          	jalr	-2038(ra) # 80000e48 <strlen>
    80006646:	86aa                	mv	a3,a0
    80006648:	8626                	mv	a2,s1
    8000664a:	85ce                	mv	a1,s3
    8000664c:	8552                	mv	a0,s4
    8000664e:	ffffb097          	auipc	ra,0xffffb
    80006652:	014080e7          	jalr	20(ra) # 80001662 <copyout>
    80006656:	89aa                	mv	s3,a0
    80006658:	e929                	bnez	a0,800066aa <btget+0x104>
             printf("copyout failed");
             release(&alltweetbuff[tag].tweettaglock);
             return -1;
         }

        memset(alltweetbuff[tag].tagtweetbuffer[index].msg, 0, MAXTWEETLENGTH);
    8000665a:	08c00613          	li	a2,140
    8000665e:	4581                	li	a1,0
    80006660:	8526                	mv	a0,s1
    80006662:	ffffa097          	auipc	ra,0xffffa
    80006666:	66a080e7          	jalr	1642(ra) # 80000ccc <memset>
        
        tweetcounter--;
    8000666a:	00003717          	auipc	a4,0x3
    8000666e:	9ca70713          	addi	a4,a4,-1590 # 80009034 <tweetcounter>
    80006672:	431c                	lw	a5,0(a4)
    80006674:	37fd                	addiw	a5,a5,-1
    80006676:	c31c                	sw	a5,0(a4)
        wakeup(&getchan);
    80006678:	00002517          	auipc	a0,0x2
    8000667c:	26450513          	addi	a0,a0,612 # 800088dc <getchan>
    80006680:	ffffc097          	auipc	ra,0xffffc
    80006684:	b6e080e7          	jalr	-1170(ra) # 800021ee <wakeup>
         
    release(&alltweetbuff[tag].tweettaglock);
    80006688:	854a                	mv	a0,s2
    8000668a:	ffffa097          	auipc	ra,0xffffa
    8000668e:	5fa080e7          	jalr	1530(ra) # 80000c84 <release>
    
     return 0;
}
    80006692:	854e                	mv	a0,s3
    80006694:	60a6                	ld	ra,72(sp)
    80006696:	6406                	ld	s0,64(sp)
    80006698:	74e2                	ld	s1,56(sp)
    8000669a:	7942                	ld	s2,48(sp)
    8000669c:	79a2                	ld	s3,40(sp)
    8000669e:	7a02                	ld	s4,32(sp)
    800066a0:	6ae2                	ld	s5,24(sp)
    800066a2:	6b42                	ld	s6,16(sp)
    800066a4:	6ba2                	ld	s7,8(sp)
    800066a6:	6161                	addi	sp,sp,80
    800066a8:	8082                	ret
             printf("copyout failed");
    800066aa:	00002517          	auipc	a0,0x2
    800066ae:	1d650513          	addi	a0,a0,470 # 80008880 <syscalls+0x438>
    800066b2:	ffffa097          	auipc	ra,0xffffa
    800066b6:	ed2080e7          	jalr	-302(ra) # 80000584 <printf>
             release(&alltweetbuff[tag].tweettaglock);
    800066ba:	854a                	mv	a0,s2
    800066bc:	ffffa097          	auipc	ra,0xffffa
    800066c0:	5c8080e7          	jalr	1480(ra) # 80000c84 <release>
             return -1;
    800066c4:	59fd                	li	s3,-1
    800066c6:	b7f1                	j	80006692 <btget+0xec>

00000000800066c8 <tget>:

//gets the msg from the tweet buffer, if msg is avaiable with a given tag
// then the tweet is returned to user program. else it returns -1
int
tget(topic_t tag,uint64 buf){
    800066c8:	7139                	addi	sp,sp,-64
    800066ca:	fc06                	sd	ra,56(sp)
    800066cc:	f822                	sd	s0,48(sp)
    800066ce:	f426                	sd	s1,40(sp)
    800066d0:	f04a                	sd	s2,32(sp)
    800066d2:	ec4e                	sd	s3,24(sp)
    800066d4:	e852                	sd	s4,16(sp)
    800066d6:	e456                	sd	s5,8(sp)
    800066d8:	e05a                	sd	s6,0(sp)
    800066da:	0080                	addi	s0,sp,64
    800066dc:	84aa                	mv	s1,a0
    800066de:	8aae                	mv	s5,a1
  
   struct proc *p = myproc();
    800066e0:	ffffb097          	auipc	ra,0xffffb
    800066e4:	2be080e7          	jalr	702(ra) # 8000199e <myproc>
    800066e8:	8b2a                	mv	s6,a0

    acquire(&alltweetbuff[tag].tweettaglock);
    800066ea:	02049993          	slli	s3,s1,0x20
    800066ee:	0209d993          	srli	s3,s3,0x20
    800066f2:	49800793          	li	a5,1176
    800066f6:	02f989b3          	mul	s3,s3,a5
    800066fa:	00020a17          	auipc	s4,0x20
    800066fe:	d86a0a13          	addi	s4,s4,-634 # 80026480 <alltweetbuff+0x480>
    80006702:	9a4e                	add	s4,s4,s3
    80006704:	8552                	mv	a0,s4
    80006706:	ffffa097          	auipc	ra,0xffffa
    8000670a:	4ca080e7          	jalr	1226(ra) # 80000bd0 <acquire>
  
    int index = gettagindex(tag);
    8000670e:	8526                	mv	a0,s1
    80006710:	00000097          	auipc	ra,0x0
    80006714:	b9a080e7          	jalr	-1126(ra) # 800062aa <gettagindex>
    80006718:	892a                	mv	s2,a0
    if(index!=-1){
    8000671a:	57fd                	li	a5,-1
    8000671c:	08f50463          	beq	a0,a5,800067a4 <tget+0xdc>

        char *temp = alltweetbuff[tag].tagtweetbuffer[index].msg;
    80006720:	00351493          	slli	s1,a0,0x3
    80006724:	94aa                	add	s1,s1,a0
    80006726:	0492                	slli	s1,s1,0x4
    80006728:	0991                	addi	s3,s3,4
    8000672a:	94ce                	add	s1,s1,s3
    8000672c:	00020797          	auipc	a5,0x20
    80006730:	8d478793          	addi	a5,a5,-1836 # 80026000 <alltweetbuff>
    80006734:	94be                	add	s1,s1,a5
        copyout(p->pagetable,buf,temp,strlen(temp));
    80006736:	050b3903          	ld	s2,80(s6)
    8000673a:	8526                	mv	a0,s1
    8000673c:	ffffa097          	auipc	ra,0xffffa
    80006740:	70c080e7          	jalr	1804(ra) # 80000e48 <strlen>
    80006744:	86aa                	mv	a3,a0
    80006746:	8626                	mv	a2,s1
    80006748:	85d6                	mv	a1,s5
    8000674a:	854a                	mv	a0,s2
    8000674c:	ffffb097          	auipc	ra,0xffffb
    80006750:	f16080e7          	jalr	-234(ra) # 80001662 <copyout>

        memset(alltweetbuff[tag].tagtweetbuffer[index].msg, 0, MAXTWEETLENGTH);
    80006754:	08c00613          	li	a2,140
    80006758:	4581                	li	a1,0
    8000675a:	8526                	mv	a0,s1
    8000675c:	ffffa097          	auipc	ra,0xffffa
    80006760:	570080e7          	jalr	1392(ra) # 80000ccc <memset>
        
         tweetcounter--;
    80006764:	00003717          	auipc	a4,0x3
    80006768:	8d070713          	addi	a4,a4,-1840 # 80009034 <tweetcounter>
    8000676c:	431c                	lw	a5,0(a4)
    8000676e:	37fd                	addiw	a5,a5,-1
    80006770:	c31c                	sw	a5,0(a4)
         wakeup(&getchan);
    80006772:	00002517          	auipc	a0,0x2
    80006776:	16a50513          	addi	a0,a0,362 # 800088dc <getchan>
    8000677a:	ffffc097          	auipc	ra,0xffffc
    8000677e:	a74080e7          	jalr	-1420(ra) # 800021ee <wakeup>
         release(&alltweetbuff[tag].tweettaglock);
        return -1;
    }
   
 
    release(&alltweetbuff[tag].tweettaglock);
    80006782:	8552                	mv	a0,s4
    80006784:	ffffa097          	auipc	ra,0xffffa
    80006788:	500080e7          	jalr	1280(ra) # 80000c84 <release>
    
     return 0;
    8000678c:	4901                	li	s2,0
}
    8000678e:	854a                	mv	a0,s2
    80006790:	70e2                	ld	ra,56(sp)
    80006792:	7442                	ld	s0,48(sp)
    80006794:	74a2                	ld	s1,40(sp)
    80006796:	7902                	ld	s2,32(sp)
    80006798:	69e2                	ld	s3,24(sp)
    8000679a:	6a42                	ld	s4,16(sp)
    8000679c:	6aa2                	ld	s5,8(sp)
    8000679e:	6b02                	ld	s6,0(sp)
    800067a0:	6121                	addi	sp,sp,64
    800067a2:	8082                	ret
        printf("no tweet msg available to read  with provided tag returing -1\n");
    800067a4:	00002517          	auipc	a0,0x2
    800067a8:	0ec50513          	addi	a0,a0,236 # 80008890 <syscalls+0x448>
    800067ac:	ffffa097          	auipc	ra,0xffffa
    800067b0:	dd8080e7          	jalr	-552(ra) # 80000584 <printf>
         release(&alltweetbuff[tag].tweettaglock);
    800067b4:	8552                	mv	a0,s4
    800067b6:	ffffa097          	auipc	ra,0xffffa
    800067ba:	4ce080e7          	jalr	1230(ra) # 80000c84 <release>
        return -1;
    800067be:	bfc1                	j	8000678e <tget+0xc6>
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
