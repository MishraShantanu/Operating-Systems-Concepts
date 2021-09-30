
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
    80000066:	b6e78793          	addi	a5,a5,-1170 # 80005bd0 <timervec>
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
    8000012e:	32a080e7          	jalr	810(ra) # 80002454 <either_copyin>
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
    800001d4:	e8a080e7          	jalr	-374(ra) # 8000205a <sleep>
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
    80000210:	1f2080e7          	jalr	498(ra) # 800023fe <either_copyout>
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
    800002f0:	1be080e7          	jalr	446(ra) # 800024aa <procdump>
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
    80000444:	da6080e7          	jalr	-602(ra) # 800021e6 <wakeup>
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
    80000892:	958080e7          	jalr	-1704(ra) # 800021e6 <wakeup>
    
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
    8000091e:	740080e7          	jalr	1856(ra) # 8000205a <sleep>
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
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	7c4080e7          	jalr	1988(ra) # 8000267c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	d50080e7          	jalr	-688(ra) # 80005c10 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	fe0080e7          	jalr	-32(ra) # 80001ea8 <scheduler>
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
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	724080e7          	jalr	1828(ra) # 80002654 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	744080e7          	jalr	1860(ra) # 8000267c <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	cba080e7          	jalr	-838(ra) # 80005bfa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	cc8080e7          	jalr	-824(ra) # 80005c10 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	e86080e7          	jalr	-378(ra) # 80002dd6 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	514080e7          	jalr	1300(ra) # 8000346c <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	4c6080e7          	jalr	1222(ra) # 80004426 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	dc8080e7          	jalr	-568(ra) # 80005d30 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	cfe080e7          	jalr	-770(ra) # 80001c6e <userinit>
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
    80001858:	87ca0a13          	addi	s4,s4,-1924 # 800170d0 <tickslock>
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
    8000188e:	16848493          	addi	s1,s1,360
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
    80001920:	00015997          	auipc	s3,0x15
    80001924:	7b098993          	addi	s3,s3,1968 # 800170d0 <tickslock>
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
    8000194c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194e:	16848493          	addi	s1,s1,360
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
    800019ea:	e4a7a783          	lw	a5,-438(a5) # 80008830 <first.1>
    800019ee:	eb89                	bnez	a5,80001a00 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019f0:	00001097          	auipc	ra,0x1
    800019f4:	ca4080e7          	jalr	-860(ra) # 80002694 <usertrapret>
}
    800019f8:	60a2                	ld	ra,8(sp)
    800019fa:	6402                	ld	s0,0(sp)
    800019fc:	0141                	addi	sp,sp,16
    800019fe:	8082                	ret
    first = 0;
    80001a00:	00007797          	auipc	a5,0x7
    80001a04:	e207a823          	sw	zero,-464(a5) # 80008830 <first.1>
    fsinit(ROOTDEV);
    80001a08:	4505                	li	a0,1
    80001a0a:	00002097          	auipc	ra,0x2
    80001a0e:	9e2080e7          	jalr	-1566(ra) # 800033ec <fsinit>
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
    80001a36:	e0278793          	addi	a5,a5,-510 # 80008834 <nextpid>
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
    80001a96:	05893683          	ld	a3,88(s2)
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
    80001b54:	6d28                	ld	a0,88(a0)
    80001b56:	c509                	beqz	a0,80001b60 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	e8a080e7          	jalr	-374(ra) # 800009e2 <kfree>
  p->trapframe = 0;
    80001b60:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b64:	68a8                	ld	a0,80(s1)
    80001b66:	c511                	beqz	a0,80001b72 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b68:	64ac                	ld	a1,72(s1)
    80001b6a:	00000097          	auipc	ra,0x0
    80001b6e:	f8c080e7          	jalr	-116(ra) # 80001af6 <proc_freepagetable>
  p->pagetable = 0;
    80001b72:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b76:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b7a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b7e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b82:	14048c23          	sb	zero,344(s1)
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
    80001bb4:	00015917          	auipc	s2,0x15
    80001bb8:	51c90913          	addi	s2,s2,1308 # 800170d0 <tickslock>
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
    80001bd4:	16848493          	addi	s1,s1,360
    80001bd8:	ff2492e3          	bne	s1,s2,80001bbc <allocproc+0x1c>
  return 0;
    80001bdc:	4481                	li	s1,0
    80001bde:	a889                	j	80001c30 <allocproc+0x90>
  p->pid = allocpid();
    80001be0:	00000097          	auipc	ra,0x0
    80001be4:	e34080e7          	jalr	-460(ra) # 80001a14 <allocpid>
    80001be8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bea:	4785                	li	a5,1
    80001bec:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	ef2080e7          	jalr	-270(ra) # 80000ae0 <kalloc>
    80001bf6:	892a                	mv	s2,a0
    80001bf8:	eca8                	sd	a0,88(s1)
    80001bfa:	c131                	beqz	a0,80001c3e <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001bfc:	8526                	mv	a0,s1
    80001bfe:	00000097          	auipc	ra,0x0
    80001c02:	e5c080e7          	jalr	-420(ra) # 80001a5a <proc_pagetable>
    80001c06:	892a                	mv	s2,a0
    80001c08:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c0a:	c531                	beqz	a0,80001c56 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c0c:	07000613          	li	a2,112
    80001c10:	4581                	li	a1,0
    80001c12:	06048513          	addi	a0,s1,96
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	0b6080e7          	jalr	182(ra) # 80000ccc <memset>
  p->context.ra = (uint64)forkret;
    80001c1e:	00000797          	auipc	a5,0x0
    80001c22:	db078793          	addi	a5,a5,-592 # 800019ce <forkret>
    80001c26:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c28:	60bc                	ld	a5,64(s1)
    80001c2a:	6705                	lui	a4,0x1
    80001c2c:	97ba                	add	a5,a5,a4
    80001c2e:	f4bc                	sd	a5,104(s1)
}
    80001c30:	8526                	mv	a0,s1
    80001c32:	60e2                	ld	ra,24(sp)
    80001c34:	6442                	ld	s0,16(sp)
    80001c36:	64a2                	ld	s1,8(sp)
    80001c38:	6902                	ld	s2,0(sp)
    80001c3a:	6105                	addi	sp,sp,32
    80001c3c:	8082                	ret
    freeproc(p);
    80001c3e:	8526                	mv	a0,s1
    80001c40:	00000097          	auipc	ra,0x0
    80001c44:	f08080e7          	jalr	-248(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001c48:	8526                	mv	a0,s1
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	03a080e7          	jalr	58(ra) # 80000c84 <release>
    return 0;
    80001c52:	84ca                	mv	s1,s2
    80001c54:	bff1                	j	80001c30 <allocproc+0x90>
    freeproc(p);
    80001c56:	8526                	mv	a0,s1
    80001c58:	00000097          	auipc	ra,0x0
    80001c5c:	ef0080e7          	jalr	-272(ra) # 80001b48 <freeproc>
    release(&p->lock);
    80001c60:	8526                	mv	a0,s1
    80001c62:	fffff097          	auipc	ra,0xfffff
    80001c66:	022080e7          	jalr	34(ra) # 80000c84 <release>
    return 0;
    80001c6a:	84ca                	mv	s1,s2
    80001c6c:	b7d1                	j	80001c30 <allocproc+0x90>

0000000080001c6e <userinit>:
{
    80001c6e:	1101                	addi	sp,sp,-32
    80001c70:	ec06                	sd	ra,24(sp)
    80001c72:	e822                	sd	s0,16(sp)
    80001c74:	e426                	sd	s1,8(sp)
    80001c76:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c78:	00000097          	auipc	ra,0x0
    80001c7c:	f28080e7          	jalr	-216(ra) # 80001ba0 <allocproc>
    80001c80:	84aa                	mv	s1,a0
  initproc = p;
    80001c82:	00007797          	auipc	a5,0x7
    80001c86:	3aa7b323          	sd	a0,934(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001c8a:	03400613          	li	a2,52
    80001c8e:	00007597          	auipc	a1,0x7
    80001c92:	bb258593          	addi	a1,a1,-1102 # 80008840 <initcode>
    80001c96:	6928                	ld	a0,80(a0)
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	6b4080e7          	jalr	1716(ra) # 8000134c <uvminit>
  p->sz = PGSIZE;
    80001ca0:	6785                	lui	a5,0x1
    80001ca2:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001ca4:	6cb8                	ld	a4,88(s1)
    80001ca6:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001caa:	6cb8                	ld	a4,88(s1)
    80001cac:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cae:	4641                	li	a2,16
    80001cb0:	00006597          	auipc	a1,0x6
    80001cb4:	55058593          	addi	a1,a1,1360 # 80008200 <digits+0x1c0>
    80001cb8:	15848513          	addi	a0,s1,344
    80001cbc:	fffff097          	auipc	ra,0xfffff
    80001cc0:	15a080e7          	jalr	346(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cc4:	00006517          	auipc	a0,0x6
    80001cc8:	54c50513          	addi	a0,a0,1356 # 80008210 <digits+0x1d0>
    80001ccc:	00002097          	auipc	ra,0x2
    80001cd0:	156080e7          	jalr	342(ra) # 80003e22 <namei>
    80001cd4:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cd8:	478d                	li	a5,3
    80001cda:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cdc:	8526                	mv	a0,s1
    80001cde:	fffff097          	auipc	ra,0xfffff
    80001ce2:	fa6080e7          	jalr	-90(ra) # 80000c84 <release>
}
    80001ce6:	60e2                	ld	ra,24(sp)
    80001ce8:	6442                	ld	s0,16(sp)
    80001cea:	64a2                	ld	s1,8(sp)
    80001cec:	6105                	addi	sp,sp,32
    80001cee:	8082                	ret

0000000080001cf0 <growproc>:
{
    80001cf0:	1101                	addi	sp,sp,-32
    80001cf2:	ec06                	sd	ra,24(sp)
    80001cf4:	e822                	sd	s0,16(sp)
    80001cf6:	e426                	sd	s1,8(sp)
    80001cf8:	e04a                	sd	s2,0(sp)
    80001cfa:	1000                	addi	s0,sp,32
    80001cfc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001cfe:	00000097          	auipc	ra,0x0
    80001d02:	c98080e7          	jalr	-872(ra) # 80001996 <myproc>
    80001d06:	892a                	mv	s2,a0
  sz = p->sz;
    80001d08:	652c                	ld	a1,72(a0)
    80001d0a:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001d0e:	00904f63          	bgtz	s1,80001d2c <growproc+0x3c>
  } else if(n < 0){
    80001d12:	0204cd63          	bltz	s1,80001d4c <growproc+0x5c>
  p->sz = sz;
    80001d16:	1782                	slli	a5,a5,0x20
    80001d18:	9381                	srli	a5,a5,0x20
    80001d1a:	04f93423          	sd	a5,72(s2)
  return 0;
    80001d1e:	4501                	li	a0,0
}
    80001d20:	60e2                	ld	ra,24(sp)
    80001d22:	6442                	ld	s0,16(sp)
    80001d24:	64a2                	ld	s1,8(sp)
    80001d26:	6902                	ld	s2,0(sp)
    80001d28:	6105                	addi	sp,sp,32
    80001d2a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d2c:	00f4863b          	addw	a2,s1,a5
    80001d30:	1602                	slli	a2,a2,0x20
    80001d32:	9201                	srli	a2,a2,0x20
    80001d34:	1582                	slli	a1,a1,0x20
    80001d36:	9181                	srli	a1,a1,0x20
    80001d38:	6928                	ld	a0,80(a0)
    80001d3a:	fffff097          	auipc	ra,0xfffff
    80001d3e:	6cc080e7          	jalr	1740(ra) # 80001406 <uvmalloc>
    80001d42:	0005079b          	sext.w	a5,a0
    80001d46:	fbe1                	bnez	a5,80001d16 <growproc+0x26>
      return -1;
    80001d48:	557d                	li	a0,-1
    80001d4a:	bfd9                	j	80001d20 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d4c:	00f4863b          	addw	a2,s1,a5
    80001d50:	1602                	slli	a2,a2,0x20
    80001d52:	9201                	srli	a2,a2,0x20
    80001d54:	1582                	slli	a1,a1,0x20
    80001d56:	9181                	srli	a1,a1,0x20
    80001d58:	6928                	ld	a0,80(a0)
    80001d5a:	fffff097          	auipc	ra,0xfffff
    80001d5e:	664080e7          	jalr	1636(ra) # 800013be <uvmdealloc>
    80001d62:	0005079b          	sext.w	a5,a0
    80001d66:	bf45                	j	80001d16 <growproc+0x26>

0000000080001d68 <fork>:
{
    80001d68:	7139                	addi	sp,sp,-64
    80001d6a:	fc06                	sd	ra,56(sp)
    80001d6c:	f822                	sd	s0,48(sp)
    80001d6e:	f426                	sd	s1,40(sp)
    80001d70:	f04a                	sd	s2,32(sp)
    80001d72:	ec4e                	sd	s3,24(sp)
    80001d74:	e852                	sd	s4,16(sp)
    80001d76:	e456                	sd	s5,8(sp)
    80001d78:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d7a:	00000097          	auipc	ra,0x0
    80001d7e:	c1c080e7          	jalr	-996(ra) # 80001996 <myproc>
    80001d82:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d84:	00000097          	auipc	ra,0x0
    80001d88:	e1c080e7          	jalr	-484(ra) # 80001ba0 <allocproc>
    80001d8c:	10050c63          	beqz	a0,80001ea4 <fork+0x13c>
    80001d90:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d92:	048ab603          	ld	a2,72(s5)
    80001d96:	692c                	ld	a1,80(a0)
    80001d98:	050ab503          	ld	a0,80(s5)
    80001d9c:	fffff097          	auipc	ra,0xfffff
    80001da0:	7ba080e7          	jalr	1978(ra) # 80001556 <uvmcopy>
    80001da4:	04054863          	bltz	a0,80001df4 <fork+0x8c>
  np->sz = p->sz;
    80001da8:	048ab783          	ld	a5,72(s5)
    80001dac:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001db0:	058ab683          	ld	a3,88(s5)
    80001db4:	87b6                	mv	a5,a3
    80001db6:	058a3703          	ld	a4,88(s4)
    80001dba:	12068693          	addi	a3,a3,288
    80001dbe:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dc2:	6788                	ld	a0,8(a5)
    80001dc4:	6b8c                	ld	a1,16(a5)
    80001dc6:	6f90                	ld	a2,24(a5)
    80001dc8:	01073023          	sd	a6,0(a4)
    80001dcc:	e708                	sd	a0,8(a4)
    80001dce:	eb0c                	sd	a1,16(a4)
    80001dd0:	ef10                	sd	a2,24(a4)
    80001dd2:	02078793          	addi	a5,a5,32
    80001dd6:	02070713          	addi	a4,a4,32
    80001dda:	fed792e3          	bne	a5,a3,80001dbe <fork+0x56>
  np->trapframe->a0 = 0;
    80001dde:	058a3783          	ld	a5,88(s4)
    80001de2:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001de6:	0d0a8493          	addi	s1,s5,208
    80001dea:	0d0a0913          	addi	s2,s4,208
    80001dee:	150a8993          	addi	s3,s5,336
    80001df2:	a00d                	j	80001e14 <fork+0xac>
    freeproc(np);
    80001df4:	8552                	mv	a0,s4
    80001df6:	00000097          	auipc	ra,0x0
    80001dfa:	d52080e7          	jalr	-686(ra) # 80001b48 <freeproc>
    release(&np->lock);
    80001dfe:	8552                	mv	a0,s4
    80001e00:	fffff097          	auipc	ra,0xfffff
    80001e04:	e84080e7          	jalr	-380(ra) # 80000c84 <release>
    return -1;
    80001e08:	597d                	li	s2,-1
    80001e0a:	a059                	j	80001e90 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e0c:	04a1                	addi	s1,s1,8
    80001e0e:	0921                	addi	s2,s2,8
    80001e10:	01348b63          	beq	s1,s3,80001e26 <fork+0xbe>
    if(p->ofile[i])
    80001e14:	6088                	ld	a0,0(s1)
    80001e16:	d97d                	beqz	a0,80001e0c <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e18:	00002097          	auipc	ra,0x2
    80001e1c:	6a0080e7          	jalr	1696(ra) # 800044b8 <filedup>
    80001e20:	00a93023          	sd	a0,0(s2)
    80001e24:	b7e5                	j	80001e0c <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e26:	150ab503          	ld	a0,336(s5)
    80001e2a:	00001097          	auipc	ra,0x1
    80001e2e:	7fe080e7          	jalr	2046(ra) # 80003628 <idup>
    80001e32:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e36:	4641                	li	a2,16
    80001e38:	158a8593          	addi	a1,s5,344
    80001e3c:	158a0513          	addi	a0,s4,344
    80001e40:	fffff097          	auipc	ra,0xfffff
    80001e44:	fd6080e7          	jalr	-42(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e48:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e4c:	8552                	mv	a0,s4
    80001e4e:	fffff097          	auipc	ra,0xfffff
    80001e52:	e36080e7          	jalr	-458(ra) # 80000c84 <release>
  acquire(&wait_lock);
    80001e56:	0000f497          	auipc	s1,0xf
    80001e5a:	46248493          	addi	s1,s1,1122 # 800112b8 <wait_lock>
    80001e5e:	8526                	mv	a0,s1
    80001e60:	fffff097          	auipc	ra,0xfffff
    80001e64:	d70080e7          	jalr	-656(ra) # 80000bd0 <acquire>
  np->parent = p;
    80001e68:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e6c:	8526                	mv	a0,s1
    80001e6e:	fffff097          	auipc	ra,0xfffff
    80001e72:	e16080e7          	jalr	-490(ra) # 80000c84 <release>
  acquire(&np->lock);
    80001e76:	8552                	mv	a0,s4
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	d58080e7          	jalr	-680(ra) # 80000bd0 <acquire>
  np->state = RUNNABLE;
    80001e80:	478d                	li	a5,3
    80001e82:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e86:	8552                	mv	a0,s4
    80001e88:	fffff097          	auipc	ra,0xfffff
    80001e8c:	dfc080e7          	jalr	-516(ra) # 80000c84 <release>
}
    80001e90:	854a                	mv	a0,s2
    80001e92:	70e2                	ld	ra,56(sp)
    80001e94:	7442                	ld	s0,48(sp)
    80001e96:	74a2                	ld	s1,40(sp)
    80001e98:	7902                	ld	s2,32(sp)
    80001e9a:	69e2                	ld	s3,24(sp)
    80001e9c:	6a42                	ld	s4,16(sp)
    80001e9e:	6aa2                	ld	s5,8(sp)
    80001ea0:	6121                	addi	sp,sp,64
    80001ea2:	8082                	ret
    return -1;
    80001ea4:	597d                	li	s2,-1
    80001ea6:	b7ed                	j	80001e90 <fork+0x128>

0000000080001ea8 <scheduler>:
{
    80001ea8:	7139                	addi	sp,sp,-64
    80001eaa:	fc06                	sd	ra,56(sp)
    80001eac:	f822                	sd	s0,48(sp)
    80001eae:	f426                	sd	s1,40(sp)
    80001eb0:	f04a                	sd	s2,32(sp)
    80001eb2:	ec4e                	sd	s3,24(sp)
    80001eb4:	e852                	sd	s4,16(sp)
    80001eb6:	e456                	sd	s5,8(sp)
    80001eb8:	e05a                	sd	s6,0(sp)
    80001eba:	0080                	addi	s0,sp,64
    80001ebc:	8792                	mv	a5,tp
  int id = r_tp();
    80001ebe:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ec0:	00779a93          	slli	s5,a5,0x7
    80001ec4:	0000f717          	auipc	a4,0xf
    80001ec8:	3dc70713          	addi	a4,a4,988 # 800112a0 <pid_lock>
    80001ecc:	9756                	add	a4,a4,s5
    80001ece:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ed2:	0000f717          	auipc	a4,0xf
    80001ed6:	40670713          	addi	a4,a4,1030 # 800112d8 <cpus+0x8>
    80001eda:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001edc:	498d                	li	s3,3
        p->state = RUNNING;
    80001ede:	4b11                	li	s6,4
        c->proc = p;
    80001ee0:	079e                	slli	a5,a5,0x7
    80001ee2:	0000fa17          	auipc	s4,0xf
    80001ee6:	3bea0a13          	addi	s4,s4,958 # 800112a0 <pid_lock>
    80001eea:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001eec:	00015917          	auipc	s2,0x15
    80001ef0:	1e490913          	addi	s2,s2,484 # 800170d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ef4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ef8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001efc:	10079073          	csrw	sstatus,a5
    80001f00:	0000f497          	auipc	s1,0xf
    80001f04:	7d048493          	addi	s1,s1,2000 # 800116d0 <proc>
    80001f08:	a811                	j	80001f1c <scheduler+0x74>
      release(&p->lock);
    80001f0a:	8526                	mv	a0,s1
    80001f0c:	fffff097          	auipc	ra,0xfffff
    80001f10:	d78080e7          	jalr	-648(ra) # 80000c84 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f14:	16848493          	addi	s1,s1,360
    80001f18:	fd248ee3          	beq	s1,s2,80001ef4 <scheduler+0x4c>
      acquire(&p->lock);
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	fffff097          	auipc	ra,0xfffff
    80001f22:	cb2080e7          	jalr	-846(ra) # 80000bd0 <acquire>
      if(p->state == RUNNABLE) {
    80001f26:	4c9c                	lw	a5,24(s1)
    80001f28:	ff3791e3          	bne	a5,s3,80001f0a <scheduler+0x62>
        p->state = RUNNING;
    80001f2c:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f30:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f34:	06048593          	addi	a1,s1,96
    80001f38:	8556                	mv	a0,s5
    80001f3a:	00000097          	auipc	ra,0x0
    80001f3e:	6b0080e7          	jalr	1712(ra) # 800025ea <swtch>
        c->proc = 0;
    80001f42:	020a3823          	sd	zero,48(s4)
    80001f46:	b7d1                	j	80001f0a <scheduler+0x62>

0000000080001f48 <sched>:
{
    80001f48:	7179                	addi	sp,sp,-48
    80001f4a:	f406                	sd	ra,40(sp)
    80001f4c:	f022                	sd	s0,32(sp)
    80001f4e:	ec26                	sd	s1,24(sp)
    80001f50:	e84a                	sd	s2,16(sp)
    80001f52:	e44e                	sd	s3,8(sp)
    80001f54:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f56:	00000097          	auipc	ra,0x0
    80001f5a:	a40080e7          	jalr	-1472(ra) # 80001996 <myproc>
    80001f5e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f60:	fffff097          	auipc	ra,0xfffff
    80001f64:	bf6080e7          	jalr	-1034(ra) # 80000b56 <holding>
    80001f68:	c93d                	beqz	a0,80001fde <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f6a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f6c:	2781                	sext.w	a5,a5
    80001f6e:	079e                	slli	a5,a5,0x7
    80001f70:	0000f717          	auipc	a4,0xf
    80001f74:	33070713          	addi	a4,a4,816 # 800112a0 <pid_lock>
    80001f78:	97ba                	add	a5,a5,a4
    80001f7a:	0a87a703          	lw	a4,168(a5)
    80001f7e:	4785                	li	a5,1
    80001f80:	06f71763          	bne	a4,a5,80001fee <sched+0xa6>
  if(p->state == RUNNING)
    80001f84:	4c98                	lw	a4,24(s1)
    80001f86:	4791                	li	a5,4
    80001f88:	06f70b63          	beq	a4,a5,80001ffe <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f8c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f90:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f92:	efb5                	bnez	a5,8000200e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f94:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f96:	0000f917          	auipc	s2,0xf
    80001f9a:	30a90913          	addi	s2,s2,778 # 800112a0 <pid_lock>
    80001f9e:	2781                	sext.w	a5,a5
    80001fa0:	079e                	slli	a5,a5,0x7
    80001fa2:	97ca                	add	a5,a5,s2
    80001fa4:	0ac7a983          	lw	s3,172(a5)
    80001fa8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001faa:	2781                	sext.w	a5,a5
    80001fac:	079e                	slli	a5,a5,0x7
    80001fae:	0000f597          	auipc	a1,0xf
    80001fb2:	32a58593          	addi	a1,a1,810 # 800112d8 <cpus+0x8>
    80001fb6:	95be                	add	a1,a1,a5
    80001fb8:	06048513          	addi	a0,s1,96
    80001fbc:	00000097          	auipc	ra,0x0
    80001fc0:	62e080e7          	jalr	1582(ra) # 800025ea <swtch>
    80001fc4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fc6:	2781                	sext.w	a5,a5
    80001fc8:	079e                	slli	a5,a5,0x7
    80001fca:	993e                	add	s2,s2,a5
    80001fcc:	0b392623          	sw	s3,172(s2)
}
    80001fd0:	70a2                	ld	ra,40(sp)
    80001fd2:	7402                	ld	s0,32(sp)
    80001fd4:	64e2                	ld	s1,24(sp)
    80001fd6:	6942                	ld	s2,16(sp)
    80001fd8:	69a2                	ld	s3,8(sp)
    80001fda:	6145                	addi	sp,sp,48
    80001fdc:	8082                	ret
    panic("sched p->lock");
    80001fde:	00006517          	auipc	a0,0x6
    80001fe2:	23a50513          	addi	a0,a0,570 # 80008218 <digits+0x1d8>
    80001fe6:	ffffe097          	auipc	ra,0xffffe
    80001fea:	554080e7          	jalr	1364(ra) # 8000053a <panic>
    panic("sched locks");
    80001fee:	00006517          	auipc	a0,0x6
    80001ff2:	23a50513          	addi	a0,a0,570 # 80008228 <digits+0x1e8>
    80001ff6:	ffffe097          	auipc	ra,0xffffe
    80001ffa:	544080e7          	jalr	1348(ra) # 8000053a <panic>
    panic("sched running");
    80001ffe:	00006517          	auipc	a0,0x6
    80002002:	23a50513          	addi	a0,a0,570 # 80008238 <digits+0x1f8>
    80002006:	ffffe097          	auipc	ra,0xffffe
    8000200a:	534080e7          	jalr	1332(ra) # 8000053a <panic>
    panic("sched interruptible");
    8000200e:	00006517          	auipc	a0,0x6
    80002012:	23a50513          	addi	a0,a0,570 # 80008248 <digits+0x208>
    80002016:	ffffe097          	auipc	ra,0xffffe
    8000201a:	524080e7          	jalr	1316(ra) # 8000053a <panic>

000000008000201e <yield>:
{
    8000201e:	1101                	addi	sp,sp,-32
    80002020:	ec06                	sd	ra,24(sp)
    80002022:	e822                	sd	s0,16(sp)
    80002024:	e426                	sd	s1,8(sp)
    80002026:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002028:	00000097          	auipc	ra,0x0
    8000202c:	96e080e7          	jalr	-1682(ra) # 80001996 <myproc>
    80002030:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002032:	fffff097          	auipc	ra,0xfffff
    80002036:	b9e080e7          	jalr	-1122(ra) # 80000bd0 <acquire>
  p->state = RUNNABLE;
    8000203a:	478d                	li	a5,3
    8000203c:	cc9c                	sw	a5,24(s1)
  sched();
    8000203e:	00000097          	auipc	ra,0x0
    80002042:	f0a080e7          	jalr	-246(ra) # 80001f48 <sched>
  release(&p->lock);
    80002046:	8526                	mv	a0,s1
    80002048:	fffff097          	auipc	ra,0xfffff
    8000204c:	c3c080e7          	jalr	-964(ra) # 80000c84 <release>
}
    80002050:	60e2                	ld	ra,24(sp)
    80002052:	6442                	ld	s0,16(sp)
    80002054:	64a2                	ld	s1,8(sp)
    80002056:	6105                	addi	sp,sp,32
    80002058:	8082                	ret

000000008000205a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000205a:	7179                	addi	sp,sp,-48
    8000205c:	f406                	sd	ra,40(sp)
    8000205e:	f022                	sd	s0,32(sp)
    80002060:	ec26                	sd	s1,24(sp)
    80002062:	e84a                	sd	s2,16(sp)
    80002064:	e44e                	sd	s3,8(sp)
    80002066:	1800                	addi	s0,sp,48
    80002068:	89aa                	mv	s3,a0
    8000206a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000206c:	00000097          	auipc	ra,0x0
    80002070:	92a080e7          	jalr	-1750(ra) # 80001996 <myproc>
    80002074:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002076:	fffff097          	auipc	ra,0xfffff
    8000207a:	b5a080e7          	jalr	-1190(ra) # 80000bd0 <acquire>
  release(lk);
    8000207e:	854a                	mv	a0,s2
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	c04080e7          	jalr	-1020(ra) # 80000c84 <release>

  // Go to sleep.
  p->chan = chan;
    80002088:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000208c:	4789                	li	a5,2
    8000208e:	cc9c                	sw	a5,24(s1)

  sched();
    80002090:	00000097          	auipc	ra,0x0
    80002094:	eb8080e7          	jalr	-328(ra) # 80001f48 <sched>

  // Tidy up.
  p->chan = 0;
    80002098:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000209c:	8526                	mv	a0,s1
    8000209e:	fffff097          	auipc	ra,0xfffff
    800020a2:	be6080e7          	jalr	-1050(ra) # 80000c84 <release>
  acquire(lk);
    800020a6:	854a                	mv	a0,s2
    800020a8:	fffff097          	auipc	ra,0xfffff
    800020ac:	b28080e7          	jalr	-1240(ra) # 80000bd0 <acquire>
}
    800020b0:	70a2                	ld	ra,40(sp)
    800020b2:	7402                	ld	s0,32(sp)
    800020b4:	64e2                	ld	s1,24(sp)
    800020b6:	6942                	ld	s2,16(sp)
    800020b8:	69a2                	ld	s3,8(sp)
    800020ba:	6145                	addi	sp,sp,48
    800020bc:	8082                	ret

00000000800020be <wait>:
{
    800020be:	715d                	addi	sp,sp,-80
    800020c0:	e486                	sd	ra,72(sp)
    800020c2:	e0a2                	sd	s0,64(sp)
    800020c4:	fc26                	sd	s1,56(sp)
    800020c6:	f84a                	sd	s2,48(sp)
    800020c8:	f44e                	sd	s3,40(sp)
    800020ca:	f052                	sd	s4,32(sp)
    800020cc:	ec56                	sd	s5,24(sp)
    800020ce:	e85a                	sd	s6,16(sp)
    800020d0:	e45e                	sd	s7,8(sp)
    800020d2:	e062                	sd	s8,0(sp)
    800020d4:	0880                	addi	s0,sp,80
    800020d6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800020d8:	00000097          	auipc	ra,0x0
    800020dc:	8be080e7          	jalr	-1858(ra) # 80001996 <myproc>
    800020e0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800020e2:	0000f517          	auipc	a0,0xf
    800020e6:	1d650513          	addi	a0,a0,470 # 800112b8 <wait_lock>
    800020ea:	fffff097          	auipc	ra,0xfffff
    800020ee:	ae6080e7          	jalr	-1306(ra) # 80000bd0 <acquire>
    havekids = 0;
    800020f2:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800020f4:	4a15                	li	s4,5
        havekids = 1;
    800020f6:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800020f8:	00015997          	auipc	s3,0x15
    800020fc:	fd898993          	addi	s3,s3,-40 # 800170d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002100:	0000fc17          	auipc	s8,0xf
    80002104:	1b8c0c13          	addi	s8,s8,440 # 800112b8 <wait_lock>
    havekids = 0;
    80002108:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000210a:	0000f497          	auipc	s1,0xf
    8000210e:	5c648493          	addi	s1,s1,1478 # 800116d0 <proc>
    80002112:	a0bd                	j	80002180 <wait+0xc2>
          pid = np->pid;
    80002114:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002118:	000b0e63          	beqz	s6,80002134 <wait+0x76>
    8000211c:	4691                	li	a3,4
    8000211e:	02c48613          	addi	a2,s1,44
    80002122:	85da                	mv	a1,s6
    80002124:	05093503          	ld	a0,80(s2)
    80002128:	fffff097          	auipc	ra,0xfffff
    8000212c:	532080e7          	jalr	1330(ra) # 8000165a <copyout>
    80002130:	02054563          	bltz	a0,8000215a <wait+0x9c>
          freeproc(np);
    80002134:	8526                	mv	a0,s1
    80002136:	00000097          	auipc	ra,0x0
    8000213a:	a12080e7          	jalr	-1518(ra) # 80001b48 <freeproc>
          release(&np->lock);
    8000213e:	8526                	mv	a0,s1
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	b44080e7          	jalr	-1212(ra) # 80000c84 <release>
          release(&wait_lock);
    80002148:	0000f517          	auipc	a0,0xf
    8000214c:	17050513          	addi	a0,a0,368 # 800112b8 <wait_lock>
    80002150:	fffff097          	auipc	ra,0xfffff
    80002154:	b34080e7          	jalr	-1228(ra) # 80000c84 <release>
          return pid;
    80002158:	a09d                	j	800021be <wait+0x100>
            release(&np->lock);
    8000215a:	8526                	mv	a0,s1
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	b28080e7          	jalr	-1240(ra) # 80000c84 <release>
            release(&wait_lock);
    80002164:	0000f517          	auipc	a0,0xf
    80002168:	15450513          	addi	a0,a0,340 # 800112b8 <wait_lock>
    8000216c:	fffff097          	auipc	ra,0xfffff
    80002170:	b18080e7          	jalr	-1256(ra) # 80000c84 <release>
            return -1;
    80002174:	59fd                	li	s3,-1
    80002176:	a0a1                	j	800021be <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002178:	16848493          	addi	s1,s1,360
    8000217c:	03348463          	beq	s1,s3,800021a4 <wait+0xe6>
      if(np->parent == p){
    80002180:	7c9c                	ld	a5,56(s1)
    80002182:	ff279be3          	bne	a5,s2,80002178 <wait+0xba>
        acquire(&np->lock);
    80002186:	8526                	mv	a0,s1
    80002188:	fffff097          	auipc	ra,0xfffff
    8000218c:	a48080e7          	jalr	-1464(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    80002190:	4c9c                	lw	a5,24(s1)
    80002192:	f94781e3          	beq	a5,s4,80002114 <wait+0x56>
        release(&np->lock);
    80002196:	8526                	mv	a0,s1
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	aec080e7          	jalr	-1300(ra) # 80000c84 <release>
        havekids = 1;
    800021a0:	8756                	mv	a4,s5
    800021a2:	bfd9                	j	80002178 <wait+0xba>
    if(!havekids || p->killed){
    800021a4:	c701                	beqz	a4,800021ac <wait+0xee>
    800021a6:	02892783          	lw	a5,40(s2)
    800021aa:	c79d                	beqz	a5,800021d8 <wait+0x11a>
      release(&wait_lock);
    800021ac:	0000f517          	auipc	a0,0xf
    800021b0:	10c50513          	addi	a0,a0,268 # 800112b8 <wait_lock>
    800021b4:	fffff097          	auipc	ra,0xfffff
    800021b8:	ad0080e7          	jalr	-1328(ra) # 80000c84 <release>
      return -1;
    800021bc:	59fd                	li	s3,-1
}
    800021be:	854e                	mv	a0,s3
    800021c0:	60a6                	ld	ra,72(sp)
    800021c2:	6406                	ld	s0,64(sp)
    800021c4:	74e2                	ld	s1,56(sp)
    800021c6:	7942                	ld	s2,48(sp)
    800021c8:	79a2                	ld	s3,40(sp)
    800021ca:	7a02                	ld	s4,32(sp)
    800021cc:	6ae2                	ld	s5,24(sp)
    800021ce:	6b42                	ld	s6,16(sp)
    800021d0:	6ba2                	ld	s7,8(sp)
    800021d2:	6c02                	ld	s8,0(sp)
    800021d4:	6161                	addi	sp,sp,80
    800021d6:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021d8:	85e2                	mv	a1,s8
    800021da:	854a                	mv	a0,s2
    800021dc:	00000097          	auipc	ra,0x0
    800021e0:	e7e080e7          	jalr	-386(ra) # 8000205a <sleep>
    havekids = 0;
    800021e4:	b715                	j	80002108 <wait+0x4a>

00000000800021e6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021e6:	7139                	addi	sp,sp,-64
    800021e8:	fc06                	sd	ra,56(sp)
    800021ea:	f822                	sd	s0,48(sp)
    800021ec:	f426                	sd	s1,40(sp)
    800021ee:	f04a                	sd	s2,32(sp)
    800021f0:	ec4e                	sd	s3,24(sp)
    800021f2:	e852                	sd	s4,16(sp)
    800021f4:	e456                	sd	s5,8(sp)
    800021f6:	0080                	addi	s0,sp,64
    800021f8:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021fa:	0000f497          	auipc	s1,0xf
    800021fe:	4d648493          	addi	s1,s1,1238 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002202:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002204:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002206:	00015917          	auipc	s2,0x15
    8000220a:	eca90913          	addi	s2,s2,-310 # 800170d0 <tickslock>
    8000220e:	a811                	j	80002222 <wakeup+0x3c>
      }
      release(&p->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	a72080e7          	jalr	-1422(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000221a:	16848493          	addi	s1,s1,360
    8000221e:	03248663          	beq	s1,s2,8000224a <wakeup+0x64>
    if(p != myproc()){
    80002222:	fffff097          	auipc	ra,0xfffff
    80002226:	774080e7          	jalr	1908(ra) # 80001996 <myproc>
    8000222a:	fea488e3          	beq	s1,a0,8000221a <wakeup+0x34>
      acquire(&p->lock);
    8000222e:	8526                	mv	a0,s1
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	9a0080e7          	jalr	-1632(ra) # 80000bd0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002238:	4c9c                	lw	a5,24(s1)
    8000223a:	fd379be3          	bne	a5,s3,80002210 <wakeup+0x2a>
    8000223e:	709c                	ld	a5,32(s1)
    80002240:	fd4798e3          	bne	a5,s4,80002210 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002244:	0154ac23          	sw	s5,24(s1)
    80002248:	b7e1                	j	80002210 <wakeup+0x2a>
    }
  }
}
    8000224a:	70e2                	ld	ra,56(sp)
    8000224c:	7442                	ld	s0,48(sp)
    8000224e:	74a2                	ld	s1,40(sp)
    80002250:	7902                	ld	s2,32(sp)
    80002252:	69e2                	ld	s3,24(sp)
    80002254:	6a42                	ld	s4,16(sp)
    80002256:	6aa2                	ld	s5,8(sp)
    80002258:	6121                	addi	sp,sp,64
    8000225a:	8082                	ret

000000008000225c <reparent>:
{
    8000225c:	7179                	addi	sp,sp,-48
    8000225e:	f406                	sd	ra,40(sp)
    80002260:	f022                	sd	s0,32(sp)
    80002262:	ec26                	sd	s1,24(sp)
    80002264:	e84a                	sd	s2,16(sp)
    80002266:	e44e                	sd	s3,8(sp)
    80002268:	e052                	sd	s4,0(sp)
    8000226a:	1800                	addi	s0,sp,48
    8000226c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000226e:	0000f497          	auipc	s1,0xf
    80002272:	46248493          	addi	s1,s1,1122 # 800116d0 <proc>
      pp->parent = initproc;
    80002276:	00007a17          	auipc	s4,0x7
    8000227a:	db2a0a13          	addi	s4,s4,-590 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000227e:	00015997          	auipc	s3,0x15
    80002282:	e5298993          	addi	s3,s3,-430 # 800170d0 <tickslock>
    80002286:	a029                	j	80002290 <reparent+0x34>
    80002288:	16848493          	addi	s1,s1,360
    8000228c:	01348d63          	beq	s1,s3,800022a6 <reparent+0x4a>
    if(pp->parent == p){
    80002290:	7c9c                	ld	a5,56(s1)
    80002292:	ff279be3          	bne	a5,s2,80002288 <reparent+0x2c>
      pp->parent = initproc;
    80002296:	000a3503          	ld	a0,0(s4)
    8000229a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000229c:	00000097          	auipc	ra,0x0
    800022a0:	f4a080e7          	jalr	-182(ra) # 800021e6 <wakeup>
    800022a4:	b7d5                	j	80002288 <reparent+0x2c>
}
    800022a6:	70a2                	ld	ra,40(sp)
    800022a8:	7402                	ld	s0,32(sp)
    800022aa:	64e2                	ld	s1,24(sp)
    800022ac:	6942                	ld	s2,16(sp)
    800022ae:	69a2                	ld	s3,8(sp)
    800022b0:	6a02                	ld	s4,0(sp)
    800022b2:	6145                	addi	sp,sp,48
    800022b4:	8082                	ret

00000000800022b6 <exit>:
{
    800022b6:	7179                	addi	sp,sp,-48
    800022b8:	f406                	sd	ra,40(sp)
    800022ba:	f022                	sd	s0,32(sp)
    800022bc:	ec26                	sd	s1,24(sp)
    800022be:	e84a                	sd	s2,16(sp)
    800022c0:	e44e                	sd	s3,8(sp)
    800022c2:	e052                	sd	s4,0(sp)
    800022c4:	1800                	addi	s0,sp,48
    800022c6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	6ce080e7          	jalr	1742(ra) # 80001996 <myproc>
    800022d0:	89aa                	mv	s3,a0
  if(p == initproc)
    800022d2:	00007797          	auipc	a5,0x7
    800022d6:	d567b783          	ld	a5,-682(a5) # 80009028 <initproc>
    800022da:	0d050493          	addi	s1,a0,208
    800022de:	15050913          	addi	s2,a0,336
    800022e2:	02a79363          	bne	a5,a0,80002308 <exit+0x52>
    panic("init exiting");
    800022e6:	00006517          	auipc	a0,0x6
    800022ea:	f7a50513          	addi	a0,a0,-134 # 80008260 <digits+0x220>
    800022ee:	ffffe097          	auipc	ra,0xffffe
    800022f2:	24c080e7          	jalr	588(ra) # 8000053a <panic>
      fileclose(f);
    800022f6:	00002097          	auipc	ra,0x2
    800022fa:	214080e7          	jalr	532(ra) # 8000450a <fileclose>
      p->ofile[fd] = 0;
    800022fe:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002302:	04a1                	addi	s1,s1,8
    80002304:	01248563          	beq	s1,s2,8000230e <exit+0x58>
    if(p->ofile[fd]){
    80002308:	6088                	ld	a0,0(s1)
    8000230a:	f575                	bnez	a0,800022f6 <exit+0x40>
    8000230c:	bfdd                	j	80002302 <exit+0x4c>
  begin_op();
    8000230e:	00002097          	auipc	ra,0x2
    80002312:	d34080e7          	jalr	-716(ra) # 80004042 <begin_op>
  iput(p->cwd);
    80002316:	1509b503          	ld	a0,336(s3)
    8000231a:	00001097          	auipc	ra,0x1
    8000231e:	506080e7          	jalr	1286(ra) # 80003820 <iput>
  end_op();
    80002322:	00002097          	auipc	ra,0x2
    80002326:	d9e080e7          	jalr	-610(ra) # 800040c0 <end_op>
  p->cwd = 0;
    8000232a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000232e:	0000f497          	auipc	s1,0xf
    80002332:	f8a48493          	addi	s1,s1,-118 # 800112b8 <wait_lock>
    80002336:	8526                	mv	a0,s1
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	898080e7          	jalr	-1896(ra) # 80000bd0 <acquire>
  reparent(p);
    80002340:	854e                	mv	a0,s3
    80002342:	00000097          	auipc	ra,0x0
    80002346:	f1a080e7          	jalr	-230(ra) # 8000225c <reparent>
  wakeup(p->parent);
    8000234a:	0389b503          	ld	a0,56(s3)
    8000234e:	00000097          	auipc	ra,0x0
    80002352:	e98080e7          	jalr	-360(ra) # 800021e6 <wakeup>
  acquire(&p->lock);
    80002356:	854e                	mv	a0,s3
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	878080e7          	jalr	-1928(ra) # 80000bd0 <acquire>
  p->xstate = status;
    80002360:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002364:	4795                	li	a5,5
    80002366:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000236a:	8526                	mv	a0,s1
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	918080e7          	jalr	-1768(ra) # 80000c84 <release>
  sched();
    80002374:	00000097          	auipc	ra,0x0
    80002378:	bd4080e7          	jalr	-1068(ra) # 80001f48 <sched>
  panic("zombie exit");
    8000237c:	00006517          	auipc	a0,0x6
    80002380:	ef450513          	addi	a0,a0,-268 # 80008270 <digits+0x230>
    80002384:	ffffe097          	auipc	ra,0xffffe
    80002388:	1b6080e7          	jalr	438(ra) # 8000053a <panic>

000000008000238c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000238c:	7179                	addi	sp,sp,-48
    8000238e:	f406                	sd	ra,40(sp)
    80002390:	f022                	sd	s0,32(sp)
    80002392:	ec26                	sd	s1,24(sp)
    80002394:	e84a                	sd	s2,16(sp)
    80002396:	e44e                	sd	s3,8(sp)
    80002398:	1800                	addi	s0,sp,48
    8000239a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000239c:	0000f497          	auipc	s1,0xf
    800023a0:	33448493          	addi	s1,s1,820 # 800116d0 <proc>
    800023a4:	00015997          	auipc	s3,0x15
    800023a8:	d2c98993          	addi	s3,s3,-724 # 800170d0 <tickslock>
    acquire(&p->lock);
    800023ac:	8526                	mv	a0,s1
    800023ae:	fffff097          	auipc	ra,0xfffff
    800023b2:	822080e7          	jalr	-2014(ra) # 80000bd0 <acquire>
    if(p->pid == pid){
    800023b6:	589c                	lw	a5,48(s1)
    800023b8:	01278d63          	beq	a5,s2,800023d2 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023bc:	8526                	mv	a0,s1
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	8c6080e7          	jalr	-1850(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023c6:	16848493          	addi	s1,s1,360
    800023ca:	ff3491e3          	bne	s1,s3,800023ac <kill+0x20>
  }
  return -1;
    800023ce:	557d                	li	a0,-1
    800023d0:	a829                	j	800023ea <kill+0x5e>
      p->killed = 1;
    800023d2:	4785                	li	a5,1
    800023d4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800023d6:	4c98                	lw	a4,24(s1)
    800023d8:	4789                	li	a5,2
    800023da:	00f70f63          	beq	a4,a5,800023f8 <kill+0x6c>
      release(&p->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	8a4080e7          	jalr	-1884(ra) # 80000c84 <release>
      return 0;
    800023e8:	4501                	li	a0,0
}
    800023ea:	70a2                	ld	ra,40(sp)
    800023ec:	7402                	ld	s0,32(sp)
    800023ee:	64e2                	ld	s1,24(sp)
    800023f0:	6942                	ld	s2,16(sp)
    800023f2:	69a2                	ld	s3,8(sp)
    800023f4:	6145                	addi	sp,sp,48
    800023f6:	8082                	ret
        p->state = RUNNABLE;
    800023f8:	478d                	li	a5,3
    800023fa:	cc9c                	sw	a5,24(s1)
    800023fc:	b7cd                	j	800023de <kill+0x52>

00000000800023fe <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800023fe:	7179                	addi	sp,sp,-48
    80002400:	f406                	sd	ra,40(sp)
    80002402:	f022                	sd	s0,32(sp)
    80002404:	ec26                	sd	s1,24(sp)
    80002406:	e84a                	sd	s2,16(sp)
    80002408:	e44e                	sd	s3,8(sp)
    8000240a:	e052                	sd	s4,0(sp)
    8000240c:	1800                	addi	s0,sp,48
    8000240e:	84aa                	mv	s1,a0
    80002410:	892e                	mv	s2,a1
    80002412:	89b2                	mv	s3,a2
    80002414:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	580080e7          	jalr	1408(ra) # 80001996 <myproc>
  if(user_dst){
    8000241e:	c08d                	beqz	s1,80002440 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002420:	86d2                	mv	a3,s4
    80002422:	864e                	mv	a2,s3
    80002424:	85ca                	mv	a1,s2
    80002426:	6928                	ld	a0,80(a0)
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	232080e7          	jalr	562(ra) # 8000165a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002430:	70a2                	ld	ra,40(sp)
    80002432:	7402                	ld	s0,32(sp)
    80002434:	64e2                	ld	s1,24(sp)
    80002436:	6942                	ld	s2,16(sp)
    80002438:	69a2                	ld	s3,8(sp)
    8000243a:	6a02                	ld	s4,0(sp)
    8000243c:	6145                	addi	sp,sp,48
    8000243e:	8082                	ret
    memmove((char *)dst, src, len);
    80002440:	000a061b          	sext.w	a2,s4
    80002444:	85ce                	mv	a1,s3
    80002446:	854a                	mv	a0,s2
    80002448:	fffff097          	auipc	ra,0xfffff
    8000244c:	8e0080e7          	jalr	-1824(ra) # 80000d28 <memmove>
    return 0;
    80002450:	8526                	mv	a0,s1
    80002452:	bff9                	j	80002430 <either_copyout+0x32>

0000000080002454 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002454:	7179                	addi	sp,sp,-48
    80002456:	f406                	sd	ra,40(sp)
    80002458:	f022                	sd	s0,32(sp)
    8000245a:	ec26                	sd	s1,24(sp)
    8000245c:	e84a                	sd	s2,16(sp)
    8000245e:	e44e                	sd	s3,8(sp)
    80002460:	e052                	sd	s4,0(sp)
    80002462:	1800                	addi	s0,sp,48
    80002464:	892a                	mv	s2,a0
    80002466:	84ae                	mv	s1,a1
    80002468:	89b2                	mv	s3,a2
    8000246a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	52a080e7          	jalr	1322(ra) # 80001996 <myproc>
  if(user_src){
    80002474:	c08d                	beqz	s1,80002496 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002476:	86d2                	mv	a3,s4
    80002478:	864e                	mv	a2,s3
    8000247a:	85ca                	mv	a1,s2
    8000247c:	6928                	ld	a0,80(a0)
    8000247e:	fffff097          	auipc	ra,0xfffff
    80002482:	268080e7          	jalr	616(ra) # 800016e6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002486:	70a2                	ld	ra,40(sp)
    80002488:	7402                	ld	s0,32(sp)
    8000248a:	64e2                	ld	s1,24(sp)
    8000248c:	6942                	ld	s2,16(sp)
    8000248e:	69a2                	ld	s3,8(sp)
    80002490:	6a02                	ld	s4,0(sp)
    80002492:	6145                	addi	sp,sp,48
    80002494:	8082                	ret
    memmove(dst, (char*)src, len);
    80002496:	000a061b          	sext.w	a2,s4
    8000249a:	85ce                	mv	a1,s3
    8000249c:	854a                	mv	a0,s2
    8000249e:	fffff097          	auipc	ra,0xfffff
    800024a2:	88a080e7          	jalr	-1910(ra) # 80000d28 <memmove>
    return 0;
    800024a6:	8526                	mv	a0,s1
    800024a8:	bff9                	j	80002486 <either_copyin+0x32>

00000000800024aa <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024aa:	715d                	addi	sp,sp,-80
    800024ac:	e486                	sd	ra,72(sp)
    800024ae:	e0a2                	sd	s0,64(sp)
    800024b0:	fc26                	sd	s1,56(sp)
    800024b2:	f84a                	sd	s2,48(sp)
    800024b4:	f44e                	sd	s3,40(sp)
    800024b6:	f052                	sd	s4,32(sp)
    800024b8:	ec56                	sd	s5,24(sp)
    800024ba:	e85a                	sd	s6,16(sp)
    800024bc:	e45e                	sd	s7,8(sp)
    800024be:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800024c0:	00006517          	auipc	a0,0x6
    800024c4:	c0850513          	addi	a0,a0,-1016 # 800080c8 <digits+0x88>
    800024c8:	ffffe097          	auipc	ra,0xffffe
    800024cc:	0bc080e7          	jalr	188(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800024d0:	0000f497          	auipc	s1,0xf
    800024d4:	35848493          	addi	s1,s1,856 # 80011828 <proc+0x158>
    800024d8:	00015917          	auipc	s2,0x15
    800024dc:	d5090913          	addi	s2,s2,-688 # 80017228 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024e0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800024e2:	00006997          	auipc	s3,0x6
    800024e6:	d9e98993          	addi	s3,s3,-610 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800024ea:	00006a97          	auipc	s5,0x6
    800024ee:	d9ea8a93          	addi	s5,s5,-610 # 80008288 <digits+0x248>
    printf("\n");
    800024f2:	00006a17          	auipc	s4,0x6
    800024f6:	bd6a0a13          	addi	s4,s4,-1066 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024fa:	00006b97          	auipc	s7,0x6
    800024fe:	ddeb8b93          	addi	s7,s7,-546 # 800082d8 <states.0>
    80002502:	a00d                	j	80002524 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002504:	ed86a583          	lw	a1,-296(a3)
    80002508:	8556                	mv	a0,s5
    8000250a:	ffffe097          	auipc	ra,0xffffe
    8000250e:	07a080e7          	jalr	122(ra) # 80000584 <printf>
    printf("\n");
    80002512:	8552                	mv	a0,s4
    80002514:	ffffe097          	auipc	ra,0xffffe
    80002518:	070080e7          	jalr	112(ra) # 80000584 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000251c:	16848493          	addi	s1,s1,360
    80002520:	03248263          	beq	s1,s2,80002544 <procdump+0x9a>
    if(p->state == UNUSED)
    80002524:	86a6                	mv	a3,s1
    80002526:	ec04a783          	lw	a5,-320(s1)
    8000252a:	dbed                	beqz	a5,8000251c <procdump+0x72>
      state = "???";
    8000252c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000252e:	fcfb6be3          	bltu	s6,a5,80002504 <procdump+0x5a>
    80002532:	02079713          	slli	a4,a5,0x20
    80002536:	01d75793          	srli	a5,a4,0x1d
    8000253a:	97de                	add	a5,a5,s7
    8000253c:	6390                	ld	a2,0(a5)
    8000253e:	f279                	bnez	a2,80002504 <procdump+0x5a>
      state = "???";
    80002540:	864e                	mv	a2,s3
    80002542:	b7c9                	j	80002504 <procdump+0x5a>
  }
}
    80002544:	60a6                	ld	ra,72(sp)
    80002546:	6406                	ld	s0,64(sp)
    80002548:	74e2                	ld	s1,56(sp)
    8000254a:	7942                	ld	s2,48(sp)
    8000254c:	79a2                	ld	s3,40(sp)
    8000254e:	7a02                	ld	s4,32(sp)
    80002550:	6ae2                	ld	s5,24(sp)
    80002552:	6b42                	ld	s6,16(sp)
    80002554:	6ba2                	ld	s7,8(sp)
    80002556:	6161                	addi	sp,sp,80
    80002558:	8082                	ret

000000008000255a <howmanycmpt>:


int
howmanycmpt(void)
{
    8000255a:	715d                	addi	sp,sp,-80
    8000255c:	e486                	sd	ra,72(sp)
    8000255e:	e0a2                	sd	s0,64(sp)
    80002560:	fc26                	sd	s1,56(sp)
    80002562:	f84a                	sd	s2,48(sp)
    80002564:	f44e                	sd	s3,40(sp)
    80002566:	f052                	sd	s4,32(sp)
    80002568:	ec56                	sd	s5,24(sp)
    8000256a:	0880                	addi	s0,sp,80
    struct proc *p;
    char name[4] = "cmpt";
    8000256c:	747077b7          	lui	a5,0x74707
    80002570:	d6378793          	addi	a5,a5,-669 # 74706d63 <_entry-0xb8f929d>
    80002574:	faf42c23          	sw	a5,-72(s0)
    int count = 0;
    80002578:	4a01                	li	s4,0

  for(p = proc; p < &proc[NPROC]; p++){
    8000257a:	0000f497          	auipc	s1,0xf
    8000257e:	15648493          	addi	s1,s1,342 # 800116d0 <proc>
    acquire(&p->lock);
      
      if(strncmp((const char*)&p->name,name,4)==0){
           printf("process name %s\n %", &p->name );
    80002582:	00006a97          	auipc	s5,0x6
    80002586:	d16a8a93          	addi	s5,s5,-746 # 80008298 <digits+0x258>
  for(p = proc; p < &proc[NPROC]; p++){
    8000258a:	00015997          	auipc	s3,0x15
    8000258e:	b4698993          	addi	s3,s3,-1210 # 800170d0 <tickslock>
    80002592:	a811                	j	800025a6 <howmanycmpt+0x4c>
          count++;
      }
      
        
       
    release(&p->lock);
    80002594:	8526                	mv	a0,s1
    80002596:	ffffe097          	auipc	ra,0xffffe
    8000259a:	6ee080e7          	jalr	1774(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000259e:	16848493          	addi	s1,s1,360
    800025a2:	03348a63          	beq	s1,s3,800025d6 <howmanycmpt+0x7c>
    acquire(&p->lock);
    800025a6:	8526                	mv	a0,s1
    800025a8:	ffffe097          	auipc	ra,0xffffe
    800025ac:	628080e7          	jalr	1576(ra) # 80000bd0 <acquire>
      if(strncmp((const char*)&p->name,name,4)==0){
    800025b0:	15848913          	addi	s2,s1,344
    800025b4:	4611                	li	a2,4
    800025b6:	fb840593          	addi	a1,s0,-72
    800025ba:	854a                	mv	a0,s2
    800025bc:	ffffe097          	auipc	ra,0xffffe
    800025c0:	7e0080e7          	jalr	2016(ra) # 80000d9c <strncmp>
    800025c4:	f961                	bnez	a0,80002594 <howmanycmpt+0x3a>
           printf("process name %s\n %", &p->name );
    800025c6:	85ca                	mv	a1,s2
    800025c8:	8556                	mv	a0,s5
    800025ca:	ffffe097          	auipc	ra,0xffffe
    800025ce:	fba080e7          	jalr	-70(ra) # 80000584 <printf>
          count++;
    800025d2:	2a05                	addiw	s4,s4,1
    800025d4:	b7c1                	j	80002594 <howmanycmpt+0x3a>
 }

  return count;
}
    800025d6:	8552                	mv	a0,s4
    800025d8:	60a6                	ld	ra,72(sp)
    800025da:	6406                	ld	s0,64(sp)
    800025dc:	74e2                	ld	s1,56(sp)
    800025de:	7942                	ld	s2,48(sp)
    800025e0:	79a2                	ld	s3,40(sp)
    800025e2:	7a02                	ld	s4,32(sp)
    800025e4:	6ae2                	ld	s5,24(sp)
    800025e6:	6161                	addi	sp,sp,80
    800025e8:	8082                	ret

00000000800025ea <swtch>:
    800025ea:	00153023          	sd	ra,0(a0)
    800025ee:	00253423          	sd	sp,8(a0)
    800025f2:	e900                	sd	s0,16(a0)
    800025f4:	ed04                	sd	s1,24(a0)
    800025f6:	03253023          	sd	s2,32(a0)
    800025fa:	03353423          	sd	s3,40(a0)
    800025fe:	03453823          	sd	s4,48(a0)
    80002602:	03553c23          	sd	s5,56(a0)
    80002606:	05653023          	sd	s6,64(a0)
    8000260a:	05753423          	sd	s7,72(a0)
    8000260e:	05853823          	sd	s8,80(a0)
    80002612:	05953c23          	sd	s9,88(a0)
    80002616:	07a53023          	sd	s10,96(a0)
    8000261a:	07b53423          	sd	s11,104(a0)
    8000261e:	0005b083          	ld	ra,0(a1)
    80002622:	0085b103          	ld	sp,8(a1)
    80002626:	6980                	ld	s0,16(a1)
    80002628:	6d84                	ld	s1,24(a1)
    8000262a:	0205b903          	ld	s2,32(a1)
    8000262e:	0285b983          	ld	s3,40(a1)
    80002632:	0305ba03          	ld	s4,48(a1)
    80002636:	0385ba83          	ld	s5,56(a1)
    8000263a:	0405bb03          	ld	s6,64(a1)
    8000263e:	0485bb83          	ld	s7,72(a1)
    80002642:	0505bc03          	ld	s8,80(a1)
    80002646:	0585bc83          	ld	s9,88(a1)
    8000264a:	0605bd03          	ld	s10,96(a1)
    8000264e:	0685bd83          	ld	s11,104(a1)
    80002652:	8082                	ret

0000000080002654 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002654:	1141                	addi	sp,sp,-16
    80002656:	e406                	sd	ra,8(sp)
    80002658:	e022                	sd	s0,0(sp)
    8000265a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000265c:	00006597          	auipc	a1,0x6
    80002660:	cac58593          	addi	a1,a1,-852 # 80008308 <states.0+0x30>
    80002664:	00015517          	auipc	a0,0x15
    80002668:	a6c50513          	addi	a0,a0,-1428 # 800170d0 <tickslock>
    8000266c:	ffffe097          	auipc	ra,0xffffe
    80002670:	4d4080e7          	jalr	1236(ra) # 80000b40 <initlock>
}
    80002674:	60a2                	ld	ra,8(sp)
    80002676:	6402                	ld	s0,0(sp)
    80002678:	0141                	addi	sp,sp,16
    8000267a:	8082                	ret

000000008000267c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000267c:	1141                	addi	sp,sp,-16
    8000267e:	e422                	sd	s0,8(sp)
    80002680:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002682:	00003797          	auipc	a5,0x3
    80002686:	4be78793          	addi	a5,a5,1214 # 80005b40 <kernelvec>
    8000268a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000268e:	6422                	ld	s0,8(sp)
    80002690:	0141                	addi	sp,sp,16
    80002692:	8082                	ret

0000000080002694 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002694:	1141                	addi	sp,sp,-16
    80002696:	e406                	sd	ra,8(sp)
    80002698:	e022                	sd	s0,0(sp)
    8000269a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000269c:	fffff097          	auipc	ra,0xfffff
    800026a0:	2fa080e7          	jalr	762(ra) # 80001996 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026a4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026a8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026aa:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026ae:	00005697          	auipc	a3,0x5
    800026b2:	95268693          	addi	a3,a3,-1710 # 80007000 <_trampoline>
    800026b6:	00005717          	auipc	a4,0x5
    800026ba:	94a70713          	addi	a4,a4,-1718 # 80007000 <_trampoline>
    800026be:	8f15                	sub	a4,a4,a3
    800026c0:	040007b7          	lui	a5,0x4000
    800026c4:	17fd                	addi	a5,a5,-1
    800026c6:	07b2                	slli	a5,a5,0xc
    800026c8:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026ca:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026ce:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026d0:	18002673          	csrr	a2,satp
    800026d4:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026d6:	6d30                	ld	a2,88(a0)
    800026d8:	6138                	ld	a4,64(a0)
    800026da:	6585                	lui	a1,0x1
    800026dc:	972e                	add	a4,a4,a1
    800026de:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026e0:	6d38                	ld	a4,88(a0)
    800026e2:	00000617          	auipc	a2,0x0
    800026e6:	13860613          	addi	a2,a2,312 # 8000281a <usertrap>
    800026ea:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026ec:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026ee:	8612                	mv	a2,tp
    800026f0:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026f2:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026f6:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026fa:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026fe:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002702:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002704:	6f18                	ld	a4,24(a4)
    80002706:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000270a:	692c                	ld	a1,80(a0)
    8000270c:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000270e:	00005717          	auipc	a4,0x5
    80002712:	98270713          	addi	a4,a4,-1662 # 80007090 <userret>
    80002716:	8f15                	sub	a4,a4,a3
    80002718:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000271a:	577d                	li	a4,-1
    8000271c:	177e                	slli	a4,a4,0x3f
    8000271e:	8dd9                	or	a1,a1,a4
    80002720:	02000537          	lui	a0,0x2000
    80002724:	157d                	addi	a0,a0,-1
    80002726:	0536                	slli	a0,a0,0xd
    80002728:	9782                	jalr	a5
}
    8000272a:	60a2                	ld	ra,8(sp)
    8000272c:	6402                	ld	s0,0(sp)
    8000272e:	0141                	addi	sp,sp,16
    80002730:	8082                	ret

0000000080002732 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002732:	1101                	addi	sp,sp,-32
    80002734:	ec06                	sd	ra,24(sp)
    80002736:	e822                	sd	s0,16(sp)
    80002738:	e426                	sd	s1,8(sp)
    8000273a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000273c:	00015497          	auipc	s1,0x15
    80002740:	99448493          	addi	s1,s1,-1644 # 800170d0 <tickslock>
    80002744:	8526                	mv	a0,s1
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	48a080e7          	jalr	1162(ra) # 80000bd0 <acquire>
  ticks++;
    8000274e:	00007517          	auipc	a0,0x7
    80002752:	8e250513          	addi	a0,a0,-1822 # 80009030 <ticks>
    80002756:	411c                	lw	a5,0(a0)
    80002758:	2785                	addiw	a5,a5,1
    8000275a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000275c:	00000097          	auipc	ra,0x0
    80002760:	a8a080e7          	jalr	-1398(ra) # 800021e6 <wakeup>
  release(&tickslock);
    80002764:	8526                	mv	a0,s1
    80002766:	ffffe097          	auipc	ra,0xffffe
    8000276a:	51e080e7          	jalr	1310(ra) # 80000c84 <release>
}
    8000276e:	60e2                	ld	ra,24(sp)
    80002770:	6442                	ld	s0,16(sp)
    80002772:	64a2                	ld	s1,8(sp)
    80002774:	6105                	addi	sp,sp,32
    80002776:	8082                	ret

0000000080002778 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002778:	1101                	addi	sp,sp,-32
    8000277a:	ec06                	sd	ra,24(sp)
    8000277c:	e822                	sd	s0,16(sp)
    8000277e:	e426                	sd	s1,8(sp)
    80002780:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002782:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002786:	00074d63          	bltz	a4,800027a0 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000278a:	57fd                	li	a5,-1
    8000278c:	17fe                	slli	a5,a5,0x3f
    8000278e:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002790:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002792:	06f70363          	beq	a4,a5,800027f8 <devintr+0x80>
  }
}
    80002796:	60e2                	ld	ra,24(sp)
    80002798:	6442                	ld	s0,16(sp)
    8000279a:	64a2                	ld	s1,8(sp)
    8000279c:	6105                	addi	sp,sp,32
    8000279e:	8082                	ret
     (scause & 0xff) == 9){
    800027a0:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    800027a4:	46a5                	li	a3,9
    800027a6:	fed792e3          	bne	a5,a3,8000278a <devintr+0x12>
    int irq = plic_claim();
    800027aa:	00003097          	auipc	ra,0x3
    800027ae:	49e080e7          	jalr	1182(ra) # 80005c48 <plic_claim>
    800027b2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027b4:	47a9                	li	a5,10
    800027b6:	02f50763          	beq	a0,a5,800027e4 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027ba:	4785                	li	a5,1
    800027bc:	02f50963          	beq	a0,a5,800027ee <devintr+0x76>
    return 1;
    800027c0:	4505                	li	a0,1
    } else if(irq){
    800027c2:	d8f1                	beqz	s1,80002796 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800027c4:	85a6                	mv	a1,s1
    800027c6:	00006517          	auipc	a0,0x6
    800027ca:	b4a50513          	addi	a0,a0,-1206 # 80008310 <states.0+0x38>
    800027ce:	ffffe097          	auipc	ra,0xffffe
    800027d2:	db6080e7          	jalr	-586(ra) # 80000584 <printf>
      plic_complete(irq);
    800027d6:	8526                	mv	a0,s1
    800027d8:	00003097          	auipc	ra,0x3
    800027dc:	494080e7          	jalr	1172(ra) # 80005c6c <plic_complete>
    return 1;
    800027e0:	4505                	li	a0,1
    800027e2:	bf55                	j	80002796 <devintr+0x1e>
      uartintr();
    800027e4:	ffffe097          	auipc	ra,0xffffe
    800027e8:	1ae080e7          	jalr	430(ra) # 80000992 <uartintr>
    800027ec:	b7ed                	j	800027d6 <devintr+0x5e>
      virtio_disk_intr();
    800027ee:	00004097          	auipc	ra,0x4
    800027f2:	90a080e7          	jalr	-1782(ra) # 800060f8 <virtio_disk_intr>
    800027f6:	b7c5                	j	800027d6 <devintr+0x5e>
    if(cpuid() == 0){
    800027f8:	fffff097          	auipc	ra,0xfffff
    800027fc:	172080e7          	jalr	370(ra) # 8000196a <cpuid>
    80002800:	c901                	beqz	a0,80002810 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002802:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002806:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002808:	14479073          	csrw	sip,a5
    return 2;
    8000280c:	4509                	li	a0,2
    8000280e:	b761                	j	80002796 <devintr+0x1e>
      clockintr();
    80002810:	00000097          	auipc	ra,0x0
    80002814:	f22080e7          	jalr	-222(ra) # 80002732 <clockintr>
    80002818:	b7ed                	j	80002802 <devintr+0x8a>

000000008000281a <usertrap>:
{
    8000281a:	1101                	addi	sp,sp,-32
    8000281c:	ec06                	sd	ra,24(sp)
    8000281e:	e822                	sd	s0,16(sp)
    80002820:	e426                	sd	s1,8(sp)
    80002822:	e04a                	sd	s2,0(sp)
    80002824:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002826:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000282a:	1007f793          	andi	a5,a5,256
    8000282e:	e3ad                	bnez	a5,80002890 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002830:	00003797          	auipc	a5,0x3
    80002834:	31078793          	addi	a5,a5,784 # 80005b40 <kernelvec>
    80002838:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000283c:	fffff097          	auipc	ra,0xfffff
    80002840:	15a080e7          	jalr	346(ra) # 80001996 <myproc>
    80002844:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002846:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002848:	14102773          	csrr	a4,sepc
    8000284c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000284e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002852:	47a1                	li	a5,8
    80002854:	04f71c63          	bne	a4,a5,800028ac <usertrap+0x92>
    if(p->killed)
    80002858:	551c                	lw	a5,40(a0)
    8000285a:	e3b9                	bnez	a5,800028a0 <usertrap+0x86>
    p->trapframe->epc += 4;
    8000285c:	6cb8                	ld	a4,88(s1)
    8000285e:	6f1c                	ld	a5,24(a4)
    80002860:	0791                	addi	a5,a5,4
    80002862:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002864:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002868:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000286c:	10079073          	csrw	sstatus,a5
    syscall();
    80002870:	00000097          	auipc	ra,0x0
    80002874:	2e0080e7          	jalr	736(ra) # 80002b50 <syscall>
  if(p->killed)
    80002878:	549c                	lw	a5,40(s1)
    8000287a:	ebc1                	bnez	a5,8000290a <usertrap+0xf0>
  usertrapret();
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	e18080e7          	jalr	-488(ra) # 80002694 <usertrapret>
}
    80002884:	60e2                	ld	ra,24(sp)
    80002886:	6442                	ld	s0,16(sp)
    80002888:	64a2                	ld	s1,8(sp)
    8000288a:	6902                	ld	s2,0(sp)
    8000288c:	6105                	addi	sp,sp,32
    8000288e:	8082                	ret
    panic("usertrap: not from user mode");
    80002890:	00006517          	auipc	a0,0x6
    80002894:	aa050513          	addi	a0,a0,-1376 # 80008330 <states.0+0x58>
    80002898:	ffffe097          	auipc	ra,0xffffe
    8000289c:	ca2080e7          	jalr	-862(ra) # 8000053a <panic>
      exit(-1);
    800028a0:	557d                	li	a0,-1
    800028a2:	00000097          	auipc	ra,0x0
    800028a6:	a14080e7          	jalr	-1516(ra) # 800022b6 <exit>
    800028aa:	bf4d                	j	8000285c <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800028ac:	00000097          	auipc	ra,0x0
    800028b0:	ecc080e7          	jalr	-308(ra) # 80002778 <devintr>
    800028b4:	892a                	mv	s2,a0
    800028b6:	c501                	beqz	a0,800028be <usertrap+0xa4>
  if(p->killed)
    800028b8:	549c                	lw	a5,40(s1)
    800028ba:	c3a1                	beqz	a5,800028fa <usertrap+0xe0>
    800028bc:	a815                	j	800028f0 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028be:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028c2:	5890                	lw	a2,48(s1)
    800028c4:	00006517          	auipc	a0,0x6
    800028c8:	a8c50513          	addi	a0,a0,-1396 # 80008350 <states.0+0x78>
    800028cc:	ffffe097          	auipc	ra,0xffffe
    800028d0:	cb8080e7          	jalr	-840(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028d4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028d8:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028dc:	00006517          	auipc	a0,0x6
    800028e0:	aa450513          	addi	a0,a0,-1372 # 80008380 <states.0+0xa8>
    800028e4:	ffffe097          	auipc	ra,0xffffe
    800028e8:	ca0080e7          	jalr	-864(ra) # 80000584 <printf>
    p->killed = 1;
    800028ec:	4785                	li	a5,1
    800028ee:	d49c                	sw	a5,40(s1)
    exit(-1);
    800028f0:	557d                	li	a0,-1
    800028f2:	00000097          	auipc	ra,0x0
    800028f6:	9c4080e7          	jalr	-1596(ra) # 800022b6 <exit>
  if(which_dev == 2)
    800028fa:	4789                	li	a5,2
    800028fc:	f8f910e3          	bne	s2,a5,8000287c <usertrap+0x62>
    yield();
    80002900:	fffff097          	auipc	ra,0xfffff
    80002904:	71e080e7          	jalr	1822(ra) # 8000201e <yield>
    80002908:	bf95                	j	8000287c <usertrap+0x62>
  int which_dev = 0;
    8000290a:	4901                	li	s2,0
    8000290c:	b7d5                	j	800028f0 <usertrap+0xd6>

000000008000290e <kerneltrap>:
{
    8000290e:	7179                	addi	sp,sp,-48
    80002910:	f406                	sd	ra,40(sp)
    80002912:	f022                	sd	s0,32(sp)
    80002914:	ec26                	sd	s1,24(sp)
    80002916:	e84a                	sd	s2,16(sp)
    80002918:	e44e                	sd	s3,8(sp)
    8000291a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000291c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002920:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002924:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002928:	1004f793          	andi	a5,s1,256
    8000292c:	cb85                	beqz	a5,8000295c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000292e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002932:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002934:	ef85                	bnez	a5,8000296c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002936:	00000097          	auipc	ra,0x0
    8000293a:	e42080e7          	jalr	-446(ra) # 80002778 <devintr>
    8000293e:	cd1d                	beqz	a0,8000297c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002940:	4789                	li	a5,2
    80002942:	06f50a63          	beq	a0,a5,800029b6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002946:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000294a:	10049073          	csrw	sstatus,s1
}
    8000294e:	70a2                	ld	ra,40(sp)
    80002950:	7402                	ld	s0,32(sp)
    80002952:	64e2                	ld	s1,24(sp)
    80002954:	6942                	ld	s2,16(sp)
    80002956:	69a2                	ld	s3,8(sp)
    80002958:	6145                	addi	sp,sp,48
    8000295a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000295c:	00006517          	auipc	a0,0x6
    80002960:	a4450513          	addi	a0,a0,-1468 # 800083a0 <states.0+0xc8>
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	bd6080e7          	jalr	-1066(ra) # 8000053a <panic>
    panic("kerneltrap: interrupts enabled");
    8000296c:	00006517          	auipc	a0,0x6
    80002970:	a5c50513          	addi	a0,a0,-1444 # 800083c8 <states.0+0xf0>
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	bc6080e7          	jalr	-1082(ra) # 8000053a <panic>
    printf("scause %p\n", scause);
    8000297c:	85ce                	mv	a1,s3
    8000297e:	00006517          	auipc	a0,0x6
    80002982:	a6a50513          	addi	a0,a0,-1430 # 800083e8 <states.0+0x110>
    80002986:	ffffe097          	auipc	ra,0xffffe
    8000298a:	bfe080e7          	jalr	-1026(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000298e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002992:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002996:	00006517          	auipc	a0,0x6
    8000299a:	a6250513          	addi	a0,a0,-1438 # 800083f8 <states.0+0x120>
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	be6080e7          	jalr	-1050(ra) # 80000584 <printf>
    panic("kerneltrap");
    800029a6:	00006517          	auipc	a0,0x6
    800029aa:	a6a50513          	addi	a0,a0,-1430 # 80008410 <states.0+0x138>
    800029ae:	ffffe097          	auipc	ra,0xffffe
    800029b2:	b8c080e7          	jalr	-1140(ra) # 8000053a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029b6:	fffff097          	auipc	ra,0xfffff
    800029ba:	fe0080e7          	jalr	-32(ra) # 80001996 <myproc>
    800029be:	d541                	beqz	a0,80002946 <kerneltrap+0x38>
    800029c0:	fffff097          	auipc	ra,0xfffff
    800029c4:	fd6080e7          	jalr	-42(ra) # 80001996 <myproc>
    800029c8:	4d18                	lw	a4,24(a0)
    800029ca:	4791                	li	a5,4
    800029cc:	f6f71de3          	bne	a4,a5,80002946 <kerneltrap+0x38>
    yield();
    800029d0:	fffff097          	auipc	ra,0xfffff
    800029d4:	64e080e7          	jalr	1614(ra) # 8000201e <yield>
    800029d8:	b7bd                	j	80002946 <kerneltrap+0x38>

00000000800029da <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029da:	1101                	addi	sp,sp,-32
    800029dc:	ec06                	sd	ra,24(sp)
    800029de:	e822                	sd	s0,16(sp)
    800029e0:	e426                	sd	s1,8(sp)
    800029e2:	1000                	addi	s0,sp,32
    800029e4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029e6:	fffff097          	auipc	ra,0xfffff
    800029ea:	fb0080e7          	jalr	-80(ra) # 80001996 <myproc>
  switch (n) {
    800029ee:	4795                	li	a5,5
    800029f0:	0497e163          	bltu	a5,s1,80002a32 <argraw+0x58>
    800029f4:	048a                	slli	s1,s1,0x2
    800029f6:	00006717          	auipc	a4,0x6
    800029fa:	a5270713          	addi	a4,a4,-1454 # 80008448 <states.0+0x170>
    800029fe:	94ba                	add	s1,s1,a4
    80002a00:	409c                	lw	a5,0(s1)
    80002a02:	97ba                	add	a5,a5,a4
    80002a04:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a06:	6d3c                	ld	a5,88(a0)
    80002a08:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a0a:	60e2                	ld	ra,24(sp)
    80002a0c:	6442                	ld	s0,16(sp)
    80002a0e:	64a2                	ld	s1,8(sp)
    80002a10:	6105                	addi	sp,sp,32
    80002a12:	8082                	ret
    return p->trapframe->a1;
    80002a14:	6d3c                	ld	a5,88(a0)
    80002a16:	7fa8                	ld	a0,120(a5)
    80002a18:	bfcd                	j	80002a0a <argraw+0x30>
    return p->trapframe->a2;
    80002a1a:	6d3c                	ld	a5,88(a0)
    80002a1c:	63c8                	ld	a0,128(a5)
    80002a1e:	b7f5                	j	80002a0a <argraw+0x30>
    return p->trapframe->a3;
    80002a20:	6d3c                	ld	a5,88(a0)
    80002a22:	67c8                	ld	a0,136(a5)
    80002a24:	b7dd                	j	80002a0a <argraw+0x30>
    return p->trapframe->a4;
    80002a26:	6d3c                	ld	a5,88(a0)
    80002a28:	6bc8                	ld	a0,144(a5)
    80002a2a:	b7c5                	j	80002a0a <argraw+0x30>
    return p->trapframe->a5;
    80002a2c:	6d3c                	ld	a5,88(a0)
    80002a2e:	6fc8                	ld	a0,152(a5)
    80002a30:	bfe9                	j	80002a0a <argraw+0x30>
  panic("argraw");
    80002a32:	00006517          	auipc	a0,0x6
    80002a36:	9ee50513          	addi	a0,a0,-1554 # 80008420 <states.0+0x148>
    80002a3a:	ffffe097          	auipc	ra,0xffffe
    80002a3e:	b00080e7          	jalr	-1280(ra) # 8000053a <panic>

0000000080002a42 <fetchaddr>:
{
    80002a42:	1101                	addi	sp,sp,-32
    80002a44:	ec06                	sd	ra,24(sp)
    80002a46:	e822                	sd	s0,16(sp)
    80002a48:	e426                	sd	s1,8(sp)
    80002a4a:	e04a                	sd	s2,0(sp)
    80002a4c:	1000                	addi	s0,sp,32
    80002a4e:	84aa                	mv	s1,a0
    80002a50:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a52:	fffff097          	auipc	ra,0xfffff
    80002a56:	f44080e7          	jalr	-188(ra) # 80001996 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a5a:	653c                	ld	a5,72(a0)
    80002a5c:	02f4f863          	bgeu	s1,a5,80002a8c <fetchaddr+0x4a>
    80002a60:	00848713          	addi	a4,s1,8
    80002a64:	02e7e663          	bltu	a5,a4,80002a90 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a68:	46a1                	li	a3,8
    80002a6a:	8626                	mv	a2,s1
    80002a6c:	85ca                	mv	a1,s2
    80002a6e:	6928                	ld	a0,80(a0)
    80002a70:	fffff097          	auipc	ra,0xfffff
    80002a74:	c76080e7          	jalr	-906(ra) # 800016e6 <copyin>
    80002a78:	00a03533          	snez	a0,a0
    80002a7c:	40a00533          	neg	a0,a0
}
    80002a80:	60e2                	ld	ra,24(sp)
    80002a82:	6442                	ld	s0,16(sp)
    80002a84:	64a2                	ld	s1,8(sp)
    80002a86:	6902                	ld	s2,0(sp)
    80002a88:	6105                	addi	sp,sp,32
    80002a8a:	8082                	ret
    return -1;
    80002a8c:	557d                	li	a0,-1
    80002a8e:	bfcd                	j	80002a80 <fetchaddr+0x3e>
    80002a90:	557d                	li	a0,-1
    80002a92:	b7fd                	j	80002a80 <fetchaddr+0x3e>

0000000080002a94 <fetchstr>:
{
    80002a94:	7179                	addi	sp,sp,-48
    80002a96:	f406                	sd	ra,40(sp)
    80002a98:	f022                	sd	s0,32(sp)
    80002a9a:	ec26                	sd	s1,24(sp)
    80002a9c:	e84a                	sd	s2,16(sp)
    80002a9e:	e44e                	sd	s3,8(sp)
    80002aa0:	1800                	addi	s0,sp,48
    80002aa2:	892a                	mv	s2,a0
    80002aa4:	84ae                	mv	s1,a1
    80002aa6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002aa8:	fffff097          	auipc	ra,0xfffff
    80002aac:	eee080e7          	jalr	-274(ra) # 80001996 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ab0:	86ce                	mv	a3,s3
    80002ab2:	864a                	mv	a2,s2
    80002ab4:	85a6                	mv	a1,s1
    80002ab6:	6928                	ld	a0,80(a0)
    80002ab8:	fffff097          	auipc	ra,0xfffff
    80002abc:	cbc080e7          	jalr	-836(ra) # 80001774 <copyinstr>
  if(err < 0)
    80002ac0:	00054763          	bltz	a0,80002ace <fetchstr+0x3a>
  return strlen(buf);
    80002ac4:	8526                	mv	a0,s1
    80002ac6:	ffffe097          	auipc	ra,0xffffe
    80002aca:	382080e7          	jalr	898(ra) # 80000e48 <strlen>
}
    80002ace:	70a2                	ld	ra,40(sp)
    80002ad0:	7402                	ld	s0,32(sp)
    80002ad2:	64e2                	ld	s1,24(sp)
    80002ad4:	6942                	ld	s2,16(sp)
    80002ad6:	69a2                	ld	s3,8(sp)
    80002ad8:	6145                	addi	sp,sp,48
    80002ada:	8082                	ret

0000000080002adc <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002adc:	1101                	addi	sp,sp,-32
    80002ade:	ec06                	sd	ra,24(sp)
    80002ae0:	e822                	sd	s0,16(sp)
    80002ae2:	e426                	sd	s1,8(sp)
    80002ae4:	1000                	addi	s0,sp,32
    80002ae6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ae8:	00000097          	auipc	ra,0x0
    80002aec:	ef2080e7          	jalr	-270(ra) # 800029da <argraw>
    80002af0:	c088                	sw	a0,0(s1)
  return 0;
}
    80002af2:	4501                	li	a0,0
    80002af4:	60e2                	ld	ra,24(sp)
    80002af6:	6442                	ld	s0,16(sp)
    80002af8:	64a2                	ld	s1,8(sp)
    80002afa:	6105                	addi	sp,sp,32
    80002afc:	8082                	ret

0000000080002afe <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002afe:	1101                	addi	sp,sp,-32
    80002b00:	ec06                	sd	ra,24(sp)
    80002b02:	e822                	sd	s0,16(sp)
    80002b04:	e426                	sd	s1,8(sp)
    80002b06:	1000                	addi	s0,sp,32
    80002b08:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b0a:	00000097          	auipc	ra,0x0
    80002b0e:	ed0080e7          	jalr	-304(ra) # 800029da <argraw>
    80002b12:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b14:	4501                	li	a0,0
    80002b16:	60e2                	ld	ra,24(sp)
    80002b18:	6442                	ld	s0,16(sp)
    80002b1a:	64a2                	ld	s1,8(sp)
    80002b1c:	6105                	addi	sp,sp,32
    80002b1e:	8082                	ret

0000000080002b20 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b20:	1101                	addi	sp,sp,-32
    80002b22:	ec06                	sd	ra,24(sp)
    80002b24:	e822                	sd	s0,16(sp)
    80002b26:	e426                	sd	s1,8(sp)
    80002b28:	e04a                	sd	s2,0(sp)
    80002b2a:	1000                	addi	s0,sp,32
    80002b2c:	84ae                	mv	s1,a1
    80002b2e:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b30:	00000097          	auipc	ra,0x0
    80002b34:	eaa080e7          	jalr	-342(ra) # 800029da <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b38:	864a                	mv	a2,s2
    80002b3a:	85a6                	mv	a1,s1
    80002b3c:	00000097          	auipc	ra,0x0
    80002b40:	f58080e7          	jalr	-168(ra) # 80002a94 <fetchstr>
}
    80002b44:	60e2                	ld	ra,24(sp)
    80002b46:	6442                	ld	s0,16(sp)
    80002b48:	64a2                	ld	s1,8(sp)
    80002b4a:	6902                	ld	s2,0(sp)
    80002b4c:	6105                	addi	sp,sp,32
    80002b4e:	8082                	ret

0000000080002b50 <syscall>:
[SYS_howmanycmpt] sys_howmanycmpt,
};

void
syscall(void)
{
    80002b50:	1101                	addi	sp,sp,-32
    80002b52:	ec06                	sd	ra,24(sp)
    80002b54:	e822                	sd	s0,16(sp)
    80002b56:	e426                	sd	s1,8(sp)
    80002b58:	e04a                	sd	s2,0(sp)
    80002b5a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b5c:	fffff097          	auipc	ra,0xfffff
    80002b60:	e3a080e7          	jalr	-454(ra) # 80001996 <myproc>
    80002b64:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b66:	05853903          	ld	s2,88(a0)
    80002b6a:	0a893783          	ld	a5,168(s2)
    80002b6e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b72:	37fd                	addiw	a5,a5,-1
    80002b74:	4755                	li	a4,21
    80002b76:	00f76f63          	bltu	a4,a5,80002b94 <syscall+0x44>
    80002b7a:	00369713          	slli	a4,a3,0x3
    80002b7e:	00006797          	auipc	a5,0x6
    80002b82:	8e278793          	addi	a5,a5,-1822 # 80008460 <syscalls>
    80002b86:	97ba                	add	a5,a5,a4
    80002b88:	639c                	ld	a5,0(a5)
    80002b8a:	c789                	beqz	a5,80002b94 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002b8c:	9782                	jalr	a5
    80002b8e:	06a93823          	sd	a0,112(s2)
    80002b92:	a839                	j	80002bb0 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b94:	15848613          	addi	a2,s1,344
    80002b98:	588c                	lw	a1,48(s1)
    80002b9a:	00006517          	auipc	a0,0x6
    80002b9e:	88e50513          	addi	a0,a0,-1906 # 80008428 <states.0+0x150>
    80002ba2:	ffffe097          	auipc	ra,0xffffe
    80002ba6:	9e2080e7          	jalr	-1566(ra) # 80000584 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002baa:	6cbc                	ld	a5,88(s1)
    80002bac:	577d                	li	a4,-1
    80002bae:	fbb8                	sd	a4,112(a5)
  }
}
    80002bb0:	60e2                	ld	ra,24(sp)
    80002bb2:	6442                	ld	s0,16(sp)
    80002bb4:	64a2                	ld	s1,8(sp)
    80002bb6:	6902                	ld	s2,0(sp)
    80002bb8:	6105                	addi	sp,sp,32
    80002bba:	8082                	ret

0000000080002bbc <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bbc:	1101                	addi	sp,sp,-32
    80002bbe:	ec06                	sd	ra,24(sp)
    80002bc0:	e822                	sd	s0,16(sp)
    80002bc2:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002bc4:	fec40593          	addi	a1,s0,-20
    80002bc8:	4501                	li	a0,0
    80002bca:	00000097          	auipc	ra,0x0
    80002bce:	f12080e7          	jalr	-238(ra) # 80002adc <argint>
    return -1;
    80002bd2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002bd4:	00054963          	bltz	a0,80002be6 <sys_exit+0x2a>
  exit(n);
    80002bd8:	fec42503          	lw	a0,-20(s0)
    80002bdc:	fffff097          	auipc	ra,0xfffff
    80002be0:	6da080e7          	jalr	1754(ra) # 800022b6 <exit>
  return 0;  // not reached
    80002be4:	4781                	li	a5,0
}
    80002be6:	853e                	mv	a0,a5
    80002be8:	60e2                	ld	ra,24(sp)
    80002bea:	6442                	ld	s0,16(sp)
    80002bec:	6105                	addi	sp,sp,32
    80002bee:	8082                	ret

0000000080002bf0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bf0:	1141                	addi	sp,sp,-16
    80002bf2:	e406                	sd	ra,8(sp)
    80002bf4:	e022                	sd	s0,0(sp)
    80002bf6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002bf8:	fffff097          	auipc	ra,0xfffff
    80002bfc:	d9e080e7          	jalr	-610(ra) # 80001996 <myproc>
}
    80002c00:	5908                	lw	a0,48(a0)
    80002c02:	60a2                	ld	ra,8(sp)
    80002c04:	6402                	ld	s0,0(sp)
    80002c06:	0141                	addi	sp,sp,16
    80002c08:	8082                	ret

0000000080002c0a <sys_fork>:

uint64
sys_fork(void)
{
    80002c0a:	1141                	addi	sp,sp,-16
    80002c0c:	e406                	sd	ra,8(sp)
    80002c0e:	e022                	sd	s0,0(sp)
    80002c10:	0800                	addi	s0,sp,16
  return fork();
    80002c12:	fffff097          	auipc	ra,0xfffff
    80002c16:	156080e7          	jalr	342(ra) # 80001d68 <fork>
}
    80002c1a:	60a2                	ld	ra,8(sp)
    80002c1c:	6402                	ld	s0,0(sp)
    80002c1e:	0141                	addi	sp,sp,16
    80002c20:	8082                	ret

0000000080002c22 <sys_wait>:

uint64
sys_wait(void)
{
    80002c22:	1101                	addi	sp,sp,-32
    80002c24:	ec06                	sd	ra,24(sp)
    80002c26:	e822                	sd	s0,16(sp)
    80002c28:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c2a:	fe840593          	addi	a1,s0,-24
    80002c2e:	4501                	li	a0,0
    80002c30:	00000097          	auipc	ra,0x0
    80002c34:	ece080e7          	jalr	-306(ra) # 80002afe <argaddr>
    80002c38:	87aa                	mv	a5,a0
    return -1;
    80002c3a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002c3c:	0007c863          	bltz	a5,80002c4c <sys_wait+0x2a>
  return wait(p);
    80002c40:	fe843503          	ld	a0,-24(s0)
    80002c44:	fffff097          	auipc	ra,0xfffff
    80002c48:	47a080e7          	jalr	1146(ra) # 800020be <wait>
}
    80002c4c:	60e2                	ld	ra,24(sp)
    80002c4e:	6442                	ld	s0,16(sp)
    80002c50:	6105                	addi	sp,sp,32
    80002c52:	8082                	ret

0000000080002c54 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c54:	7179                	addi	sp,sp,-48
    80002c56:	f406                	sd	ra,40(sp)
    80002c58:	f022                	sd	s0,32(sp)
    80002c5a:	ec26                	sd	s1,24(sp)
    80002c5c:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002c5e:	fdc40593          	addi	a1,s0,-36
    80002c62:	4501                	li	a0,0
    80002c64:	00000097          	auipc	ra,0x0
    80002c68:	e78080e7          	jalr	-392(ra) # 80002adc <argint>
    80002c6c:	87aa                	mv	a5,a0
    return -1;
    80002c6e:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002c70:	0207c063          	bltz	a5,80002c90 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002c74:	fffff097          	auipc	ra,0xfffff
    80002c78:	d22080e7          	jalr	-734(ra) # 80001996 <myproc>
    80002c7c:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002c7e:	fdc42503          	lw	a0,-36(s0)
    80002c82:	fffff097          	auipc	ra,0xfffff
    80002c86:	06e080e7          	jalr	110(ra) # 80001cf0 <growproc>
    80002c8a:	00054863          	bltz	a0,80002c9a <sys_sbrk+0x46>
    return -1;
  return addr;
    80002c8e:	8526                	mv	a0,s1
}
    80002c90:	70a2                	ld	ra,40(sp)
    80002c92:	7402                	ld	s0,32(sp)
    80002c94:	64e2                	ld	s1,24(sp)
    80002c96:	6145                	addi	sp,sp,48
    80002c98:	8082                	ret
    return -1;
    80002c9a:	557d                	li	a0,-1
    80002c9c:	bfd5                	j	80002c90 <sys_sbrk+0x3c>

0000000080002c9e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c9e:	7139                	addi	sp,sp,-64
    80002ca0:	fc06                	sd	ra,56(sp)
    80002ca2:	f822                	sd	s0,48(sp)
    80002ca4:	f426                	sd	s1,40(sp)
    80002ca6:	f04a                	sd	s2,32(sp)
    80002ca8:	ec4e                	sd	s3,24(sp)
    80002caa:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002cac:	fcc40593          	addi	a1,s0,-52
    80002cb0:	4501                	li	a0,0
    80002cb2:	00000097          	auipc	ra,0x0
    80002cb6:	e2a080e7          	jalr	-470(ra) # 80002adc <argint>
    return -1;
    80002cba:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002cbc:	06054563          	bltz	a0,80002d26 <sys_sleep+0x88>
  acquire(&tickslock);
    80002cc0:	00014517          	auipc	a0,0x14
    80002cc4:	41050513          	addi	a0,a0,1040 # 800170d0 <tickslock>
    80002cc8:	ffffe097          	auipc	ra,0xffffe
    80002ccc:	f08080e7          	jalr	-248(ra) # 80000bd0 <acquire>
  ticks0 = ticks;
    80002cd0:	00006917          	auipc	s2,0x6
    80002cd4:	36092903          	lw	s2,864(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002cd8:	fcc42783          	lw	a5,-52(s0)
    80002cdc:	cf85                	beqz	a5,80002d14 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cde:	00014997          	auipc	s3,0x14
    80002ce2:	3f298993          	addi	s3,s3,1010 # 800170d0 <tickslock>
    80002ce6:	00006497          	auipc	s1,0x6
    80002cea:	34a48493          	addi	s1,s1,842 # 80009030 <ticks>
    if(myproc()->killed){
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	ca8080e7          	jalr	-856(ra) # 80001996 <myproc>
    80002cf6:	551c                	lw	a5,40(a0)
    80002cf8:	ef9d                	bnez	a5,80002d36 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002cfa:	85ce                	mv	a1,s3
    80002cfc:	8526                	mv	a0,s1
    80002cfe:	fffff097          	auipc	ra,0xfffff
    80002d02:	35c080e7          	jalr	860(ra) # 8000205a <sleep>
  while(ticks - ticks0 < n){
    80002d06:	409c                	lw	a5,0(s1)
    80002d08:	412787bb          	subw	a5,a5,s2
    80002d0c:	fcc42703          	lw	a4,-52(s0)
    80002d10:	fce7efe3          	bltu	a5,a4,80002cee <sys_sleep+0x50>
  }
  release(&tickslock);
    80002d14:	00014517          	auipc	a0,0x14
    80002d18:	3bc50513          	addi	a0,a0,956 # 800170d0 <tickslock>
    80002d1c:	ffffe097          	auipc	ra,0xffffe
    80002d20:	f68080e7          	jalr	-152(ra) # 80000c84 <release>
  return 0;
    80002d24:	4781                	li	a5,0
}
    80002d26:	853e                	mv	a0,a5
    80002d28:	70e2                	ld	ra,56(sp)
    80002d2a:	7442                	ld	s0,48(sp)
    80002d2c:	74a2                	ld	s1,40(sp)
    80002d2e:	7902                	ld	s2,32(sp)
    80002d30:	69e2                	ld	s3,24(sp)
    80002d32:	6121                	addi	sp,sp,64
    80002d34:	8082                	ret
      release(&tickslock);
    80002d36:	00014517          	auipc	a0,0x14
    80002d3a:	39a50513          	addi	a0,a0,922 # 800170d0 <tickslock>
    80002d3e:	ffffe097          	auipc	ra,0xffffe
    80002d42:	f46080e7          	jalr	-186(ra) # 80000c84 <release>
      return -1;
    80002d46:	57fd                	li	a5,-1
    80002d48:	bff9                	j	80002d26 <sys_sleep+0x88>

0000000080002d4a <sys_kill>:

uint64
sys_kill(void)
{
    80002d4a:	1101                	addi	sp,sp,-32
    80002d4c:	ec06                	sd	ra,24(sp)
    80002d4e:	e822                	sd	s0,16(sp)
    80002d50:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d52:	fec40593          	addi	a1,s0,-20
    80002d56:	4501                	li	a0,0
    80002d58:	00000097          	auipc	ra,0x0
    80002d5c:	d84080e7          	jalr	-636(ra) # 80002adc <argint>
    80002d60:	87aa                	mv	a5,a0
    return -1;
    80002d62:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002d64:	0007c863          	bltz	a5,80002d74 <sys_kill+0x2a>
  return kill(pid);
    80002d68:	fec42503          	lw	a0,-20(s0)
    80002d6c:	fffff097          	auipc	ra,0xfffff
    80002d70:	620080e7          	jalr	1568(ra) # 8000238c <kill>
}
    80002d74:	60e2                	ld	ra,24(sp)
    80002d76:	6442                	ld	s0,16(sp)
    80002d78:	6105                	addi	sp,sp,32
    80002d7a:	8082                	ret

0000000080002d7c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d7c:	1101                	addi	sp,sp,-32
    80002d7e:	ec06                	sd	ra,24(sp)
    80002d80:	e822                	sd	s0,16(sp)
    80002d82:	e426                	sd	s1,8(sp)
    80002d84:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d86:	00014517          	auipc	a0,0x14
    80002d8a:	34a50513          	addi	a0,a0,842 # 800170d0 <tickslock>
    80002d8e:	ffffe097          	auipc	ra,0xffffe
    80002d92:	e42080e7          	jalr	-446(ra) # 80000bd0 <acquire>
  xticks = ticks;
    80002d96:	00006497          	auipc	s1,0x6
    80002d9a:	29a4a483          	lw	s1,666(s1) # 80009030 <ticks>
  release(&tickslock);
    80002d9e:	00014517          	auipc	a0,0x14
    80002da2:	33250513          	addi	a0,a0,818 # 800170d0 <tickslock>
    80002da6:	ffffe097          	auipc	ra,0xffffe
    80002daa:	ede080e7          	jalr	-290(ra) # 80000c84 <release>
  return xticks;
}
    80002dae:	02049513          	slli	a0,s1,0x20
    80002db2:	9101                	srli	a0,a0,0x20
    80002db4:	60e2                	ld	ra,24(sp)
    80002db6:	6442                	ld	s0,16(sp)
    80002db8:	64a2                	ld	s1,8(sp)
    80002dba:	6105                	addi	sp,sp,32
    80002dbc:	8082                	ret

0000000080002dbe <sys_howmanycmpt>:

uint64
sys_howmanycmpt(void){
    80002dbe:	1141                	addi	sp,sp,-16
    80002dc0:	e406                	sd	ra,8(sp)
    80002dc2:	e022                	sd	s0,0(sp)
    80002dc4:	0800                	addi	s0,sp,16
  
  
   return howmanycmpt();
    80002dc6:	fffff097          	auipc	ra,0xfffff
    80002dca:	794080e7          	jalr	1940(ra) # 8000255a <howmanycmpt>
  // return 33;

}
    80002dce:	60a2                	ld	ra,8(sp)
    80002dd0:	6402                	ld	s0,0(sp)
    80002dd2:	0141                	addi	sp,sp,16
    80002dd4:	8082                	ret

0000000080002dd6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002dd6:	7179                	addi	sp,sp,-48
    80002dd8:	f406                	sd	ra,40(sp)
    80002dda:	f022                	sd	s0,32(sp)
    80002ddc:	ec26                	sd	s1,24(sp)
    80002dde:	e84a                	sd	s2,16(sp)
    80002de0:	e44e                	sd	s3,8(sp)
    80002de2:	e052                	sd	s4,0(sp)
    80002de4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002de6:	00005597          	auipc	a1,0x5
    80002dea:	73258593          	addi	a1,a1,1842 # 80008518 <syscalls+0xb8>
    80002dee:	00014517          	auipc	a0,0x14
    80002df2:	2fa50513          	addi	a0,a0,762 # 800170e8 <bcache>
    80002df6:	ffffe097          	auipc	ra,0xffffe
    80002dfa:	d4a080e7          	jalr	-694(ra) # 80000b40 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002dfe:	0001c797          	auipc	a5,0x1c
    80002e02:	2ea78793          	addi	a5,a5,746 # 8001f0e8 <bcache+0x8000>
    80002e06:	0001c717          	auipc	a4,0x1c
    80002e0a:	54a70713          	addi	a4,a4,1354 # 8001f350 <bcache+0x8268>
    80002e0e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e12:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e16:	00014497          	auipc	s1,0x14
    80002e1a:	2ea48493          	addi	s1,s1,746 # 80017100 <bcache+0x18>
    b->next = bcache.head.next;
    80002e1e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e20:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e22:	00005a17          	auipc	s4,0x5
    80002e26:	6fea0a13          	addi	s4,s4,1790 # 80008520 <syscalls+0xc0>
    b->next = bcache.head.next;
    80002e2a:	2b893783          	ld	a5,696(s2)
    80002e2e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e30:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e34:	85d2                	mv	a1,s4
    80002e36:	01048513          	addi	a0,s1,16
    80002e3a:	00001097          	auipc	ra,0x1
    80002e3e:	4c2080e7          	jalr	1218(ra) # 800042fc <initsleeplock>
    bcache.head.next->prev = b;
    80002e42:	2b893783          	ld	a5,696(s2)
    80002e46:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e48:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e4c:	45848493          	addi	s1,s1,1112
    80002e50:	fd349de3          	bne	s1,s3,80002e2a <binit+0x54>
  }
}
    80002e54:	70a2                	ld	ra,40(sp)
    80002e56:	7402                	ld	s0,32(sp)
    80002e58:	64e2                	ld	s1,24(sp)
    80002e5a:	6942                	ld	s2,16(sp)
    80002e5c:	69a2                	ld	s3,8(sp)
    80002e5e:	6a02                	ld	s4,0(sp)
    80002e60:	6145                	addi	sp,sp,48
    80002e62:	8082                	ret

0000000080002e64 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e64:	7179                	addi	sp,sp,-48
    80002e66:	f406                	sd	ra,40(sp)
    80002e68:	f022                	sd	s0,32(sp)
    80002e6a:	ec26                	sd	s1,24(sp)
    80002e6c:	e84a                	sd	s2,16(sp)
    80002e6e:	e44e                	sd	s3,8(sp)
    80002e70:	1800                	addi	s0,sp,48
    80002e72:	892a                	mv	s2,a0
    80002e74:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e76:	00014517          	auipc	a0,0x14
    80002e7a:	27250513          	addi	a0,a0,626 # 800170e8 <bcache>
    80002e7e:	ffffe097          	auipc	ra,0xffffe
    80002e82:	d52080e7          	jalr	-686(ra) # 80000bd0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e86:	0001c497          	auipc	s1,0x1c
    80002e8a:	51a4b483          	ld	s1,1306(s1) # 8001f3a0 <bcache+0x82b8>
    80002e8e:	0001c797          	auipc	a5,0x1c
    80002e92:	4c278793          	addi	a5,a5,1218 # 8001f350 <bcache+0x8268>
    80002e96:	02f48f63          	beq	s1,a5,80002ed4 <bread+0x70>
    80002e9a:	873e                	mv	a4,a5
    80002e9c:	a021                	j	80002ea4 <bread+0x40>
    80002e9e:	68a4                	ld	s1,80(s1)
    80002ea0:	02e48a63          	beq	s1,a4,80002ed4 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002ea4:	449c                	lw	a5,8(s1)
    80002ea6:	ff279ce3          	bne	a5,s2,80002e9e <bread+0x3a>
    80002eaa:	44dc                	lw	a5,12(s1)
    80002eac:	ff3799e3          	bne	a5,s3,80002e9e <bread+0x3a>
      b->refcnt++;
    80002eb0:	40bc                	lw	a5,64(s1)
    80002eb2:	2785                	addiw	a5,a5,1
    80002eb4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002eb6:	00014517          	auipc	a0,0x14
    80002eba:	23250513          	addi	a0,a0,562 # 800170e8 <bcache>
    80002ebe:	ffffe097          	auipc	ra,0xffffe
    80002ec2:	dc6080e7          	jalr	-570(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80002ec6:	01048513          	addi	a0,s1,16
    80002eca:	00001097          	auipc	ra,0x1
    80002ece:	46c080e7          	jalr	1132(ra) # 80004336 <acquiresleep>
      return b;
    80002ed2:	a8b9                	j	80002f30 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ed4:	0001c497          	auipc	s1,0x1c
    80002ed8:	4c44b483          	ld	s1,1220(s1) # 8001f398 <bcache+0x82b0>
    80002edc:	0001c797          	auipc	a5,0x1c
    80002ee0:	47478793          	addi	a5,a5,1140 # 8001f350 <bcache+0x8268>
    80002ee4:	00f48863          	beq	s1,a5,80002ef4 <bread+0x90>
    80002ee8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002eea:	40bc                	lw	a5,64(s1)
    80002eec:	cf81                	beqz	a5,80002f04 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002eee:	64a4                	ld	s1,72(s1)
    80002ef0:	fee49de3          	bne	s1,a4,80002eea <bread+0x86>
  panic("bget: no buffers");
    80002ef4:	00005517          	auipc	a0,0x5
    80002ef8:	63450513          	addi	a0,a0,1588 # 80008528 <syscalls+0xc8>
    80002efc:	ffffd097          	auipc	ra,0xffffd
    80002f00:	63e080e7          	jalr	1598(ra) # 8000053a <panic>
      b->dev = dev;
    80002f04:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f08:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f0c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f10:	4785                	li	a5,1
    80002f12:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f14:	00014517          	auipc	a0,0x14
    80002f18:	1d450513          	addi	a0,a0,468 # 800170e8 <bcache>
    80002f1c:	ffffe097          	auipc	ra,0xffffe
    80002f20:	d68080e7          	jalr	-664(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80002f24:	01048513          	addi	a0,s1,16
    80002f28:	00001097          	auipc	ra,0x1
    80002f2c:	40e080e7          	jalr	1038(ra) # 80004336 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f30:	409c                	lw	a5,0(s1)
    80002f32:	cb89                	beqz	a5,80002f44 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f34:	8526                	mv	a0,s1
    80002f36:	70a2                	ld	ra,40(sp)
    80002f38:	7402                	ld	s0,32(sp)
    80002f3a:	64e2                	ld	s1,24(sp)
    80002f3c:	6942                	ld	s2,16(sp)
    80002f3e:	69a2                	ld	s3,8(sp)
    80002f40:	6145                	addi	sp,sp,48
    80002f42:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f44:	4581                	li	a1,0
    80002f46:	8526                	mv	a0,s1
    80002f48:	00003097          	auipc	ra,0x3
    80002f4c:	f2a080e7          	jalr	-214(ra) # 80005e72 <virtio_disk_rw>
    b->valid = 1;
    80002f50:	4785                	li	a5,1
    80002f52:	c09c                	sw	a5,0(s1)
  return b;
    80002f54:	b7c5                	j	80002f34 <bread+0xd0>

0000000080002f56 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f56:	1101                	addi	sp,sp,-32
    80002f58:	ec06                	sd	ra,24(sp)
    80002f5a:	e822                	sd	s0,16(sp)
    80002f5c:	e426                	sd	s1,8(sp)
    80002f5e:	1000                	addi	s0,sp,32
    80002f60:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f62:	0541                	addi	a0,a0,16
    80002f64:	00001097          	auipc	ra,0x1
    80002f68:	46c080e7          	jalr	1132(ra) # 800043d0 <holdingsleep>
    80002f6c:	cd01                	beqz	a0,80002f84 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f6e:	4585                	li	a1,1
    80002f70:	8526                	mv	a0,s1
    80002f72:	00003097          	auipc	ra,0x3
    80002f76:	f00080e7          	jalr	-256(ra) # 80005e72 <virtio_disk_rw>
}
    80002f7a:	60e2                	ld	ra,24(sp)
    80002f7c:	6442                	ld	s0,16(sp)
    80002f7e:	64a2                	ld	s1,8(sp)
    80002f80:	6105                	addi	sp,sp,32
    80002f82:	8082                	ret
    panic("bwrite");
    80002f84:	00005517          	auipc	a0,0x5
    80002f88:	5bc50513          	addi	a0,a0,1468 # 80008540 <syscalls+0xe0>
    80002f8c:	ffffd097          	auipc	ra,0xffffd
    80002f90:	5ae080e7          	jalr	1454(ra) # 8000053a <panic>

0000000080002f94 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f94:	1101                	addi	sp,sp,-32
    80002f96:	ec06                	sd	ra,24(sp)
    80002f98:	e822                	sd	s0,16(sp)
    80002f9a:	e426                	sd	s1,8(sp)
    80002f9c:	e04a                	sd	s2,0(sp)
    80002f9e:	1000                	addi	s0,sp,32
    80002fa0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fa2:	01050913          	addi	s2,a0,16
    80002fa6:	854a                	mv	a0,s2
    80002fa8:	00001097          	auipc	ra,0x1
    80002fac:	428080e7          	jalr	1064(ra) # 800043d0 <holdingsleep>
    80002fb0:	c92d                	beqz	a0,80003022 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002fb2:	854a                	mv	a0,s2
    80002fb4:	00001097          	auipc	ra,0x1
    80002fb8:	3d8080e7          	jalr	984(ra) # 8000438c <releasesleep>

  acquire(&bcache.lock);
    80002fbc:	00014517          	auipc	a0,0x14
    80002fc0:	12c50513          	addi	a0,a0,300 # 800170e8 <bcache>
    80002fc4:	ffffe097          	auipc	ra,0xffffe
    80002fc8:	c0c080e7          	jalr	-1012(ra) # 80000bd0 <acquire>
  b->refcnt--;
    80002fcc:	40bc                	lw	a5,64(s1)
    80002fce:	37fd                	addiw	a5,a5,-1
    80002fd0:	0007871b          	sext.w	a4,a5
    80002fd4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002fd6:	eb05                	bnez	a4,80003006 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002fd8:	68bc                	ld	a5,80(s1)
    80002fda:	64b8                	ld	a4,72(s1)
    80002fdc:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002fde:	64bc                	ld	a5,72(s1)
    80002fe0:	68b8                	ld	a4,80(s1)
    80002fe2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002fe4:	0001c797          	auipc	a5,0x1c
    80002fe8:	10478793          	addi	a5,a5,260 # 8001f0e8 <bcache+0x8000>
    80002fec:	2b87b703          	ld	a4,696(a5)
    80002ff0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ff2:	0001c717          	auipc	a4,0x1c
    80002ff6:	35e70713          	addi	a4,a4,862 # 8001f350 <bcache+0x8268>
    80002ffa:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ffc:	2b87b703          	ld	a4,696(a5)
    80003000:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003002:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003006:	00014517          	auipc	a0,0x14
    8000300a:	0e250513          	addi	a0,a0,226 # 800170e8 <bcache>
    8000300e:	ffffe097          	auipc	ra,0xffffe
    80003012:	c76080e7          	jalr	-906(ra) # 80000c84 <release>
}
    80003016:	60e2                	ld	ra,24(sp)
    80003018:	6442                	ld	s0,16(sp)
    8000301a:	64a2                	ld	s1,8(sp)
    8000301c:	6902                	ld	s2,0(sp)
    8000301e:	6105                	addi	sp,sp,32
    80003020:	8082                	ret
    panic("brelse");
    80003022:	00005517          	auipc	a0,0x5
    80003026:	52650513          	addi	a0,a0,1318 # 80008548 <syscalls+0xe8>
    8000302a:	ffffd097          	auipc	ra,0xffffd
    8000302e:	510080e7          	jalr	1296(ra) # 8000053a <panic>

0000000080003032 <bpin>:

void
bpin(struct buf *b) {
    80003032:	1101                	addi	sp,sp,-32
    80003034:	ec06                	sd	ra,24(sp)
    80003036:	e822                	sd	s0,16(sp)
    80003038:	e426                	sd	s1,8(sp)
    8000303a:	1000                	addi	s0,sp,32
    8000303c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000303e:	00014517          	auipc	a0,0x14
    80003042:	0aa50513          	addi	a0,a0,170 # 800170e8 <bcache>
    80003046:	ffffe097          	auipc	ra,0xffffe
    8000304a:	b8a080e7          	jalr	-1142(ra) # 80000bd0 <acquire>
  b->refcnt++;
    8000304e:	40bc                	lw	a5,64(s1)
    80003050:	2785                	addiw	a5,a5,1
    80003052:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003054:	00014517          	auipc	a0,0x14
    80003058:	09450513          	addi	a0,a0,148 # 800170e8 <bcache>
    8000305c:	ffffe097          	auipc	ra,0xffffe
    80003060:	c28080e7          	jalr	-984(ra) # 80000c84 <release>
}
    80003064:	60e2                	ld	ra,24(sp)
    80003066:	6442                	ld	s0,16(sp)
    80003068:	64a2                	ld	s1,8(sp)
    8000306a:	6105                	addi	sp,sp,32
    8000306c:	8082                	ret

000000008000306e <bunpin>:

void
bunpin(struct buf *b) {
    8000306e:	1101                	addi	sp,sp,-32
    80003070:	ec06                	sd	ra,24(sp)
    80003072:	e822                	sd	s0,16(sp)
    80003074:	e426                	sd	s1,8(sp)
    80003076:	1000                	addi	s0,sp,32
    80003078:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000307a:	00014517          	auipc	a0,0x14
    8000307e:	06e50513          	addi	a0,a0,110 # 800170e8 <bcache>
    80003082:	ffffe097          	auipc	ra,0xffffe
    80003086:	b4e080e7          	jalr	-1202(ra) # 80000bd0 <acquire>
  b->refcnt--;
    8000308a:	40bc                	lw	a5,64(s1)
    8000308c:	37fd                	addiw	a5,a5,-1
    8000308e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003090:	00014517          	auipc	a0,0x14
    80003094:	05850513          	addi	a0,a0,88 # 800170e8 <bcache>
    80003098:	ffffe097          	auipc	ra,0xffffe
    8000309c:	bec080e7          	jalr	-1044(ra) # 80000c84 <release>
}
    800030a0:	60e2                	ld	ra,24(sp)
    800030a2:	6442                	ld	s0,16(sp)
    800030a4:	64a2                	ld	s1,8(sp)
    800030a6:	6105                	addi	sp,sp,32
    800030a8:	8082                	ret

00000000800030aa <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030aa:	1101                	addi	sp,sp,-32
    800030ac:	ec06                	sd	ra,24(sp)
    800030ae:	e822                	sd	s0,16(sp)
    800030b0:	e426                	sd	s1,8(sp)
    800030b2:	e04a                	sd	s2,0(sp)
    800030b4:	1000                	addi	s0,sp,32
    800030b6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030b8:	00d5d59b          	srliw	a1,a1,0xd
    800030bc:	0001c797          	auipc	a5,0x1c
    800030c0:	7087a783          	lw	a5,1800(a5) # 8001f7c4 <sb+0x1c>
    800030c4:	9dbd                	addw	a1,a1,a5
    800030c6:	00000097          	auipc	ra,0x0
    800030ca:	d9e080e7          	jalr	-610(ra) # 80002e64 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030ce:	0074f713          	andi	a4,s1,7
    800030d2:	4785                	li	a5,1
    800030d4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800030d8:	14ce                	slli	s1,s1,0x33
    800030da:	90d9                	srli	s1,s1,0x36
    800030dc:	00950733          	add	a4,a0,s1
    800030e0:	05874703          	lbu	a4,88(a4)
    800030e4:	00e7f6b3          	and	a3,a5,a4
    800030e8:	c69d                	beqz	a3,80003116 <bfree+0x6c>
    800030ea:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030ec:	94aa                	add	s1,s1,a0
    800030ee:	fff7c793          	not	a5,a5
    800030f2:	8f7d                	and	a4,a4,a5
    800030f4:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800030f8:	00001097          	auipc	ra,0x1
    800030fc:	120080e7          	jalr	288(ra) # 80004218 <log_write>
  brelse(bp);
    80003100:	854a                	mv	a0,s2
    80003102:	00000097          	auipc	ra,0x0
    80003106:	e92080e7          	jalr	-366(ra) # 80002f94 <brelse>
}
    8000310a:	60e2                	ld	ra,24(sp)
    8000310c:	6442                	ld	s0,16(sp)
    8000310e:	64a2                	ld	s1,8(sp)
    80003110:	6902                	ld	s2,0(sp)
    80003112:	6105                	addi	sp,sp,32
    80003114:	8082                	ret
    panic("freeing free block");
    80003116:	00005517          	auipc	a0,0x5
    8000311a:	43a50513          	addi	a0,a0,1082 # 80008550 <syscalls+0xf0>
    8000311e:	ffffd097          	auipc	ra,0xffffd
    80003122:	41c080e7          	jalr	1052(ra) # 8000053a <panic>

0000000080003126 <balloc>:
{
    80003126:	711d                	addi	sp,sp,-96
    80003128:	ec86                	sd	ra,88(sp)
    8000312a:	e8a2                	sd	s0,80(sp)
    8000312c:	e4a6                	sd	s1,72(sp)
    8000312e:	e0ca                	sd	s2,64(sp)
    80003130:	fc4e                	sd	s3,56(sp)
    80003132:	f852                	sd	s4,48(sp)
    80003134:	f456                	sd	s5,40(sp)
    80003136:	f05a                	sd	s6,32(sp)
    80003138:	ec5e                	sd	s7,24(sp)
    8000313a:	e862                	sd	s8,16(sp)
    8000313c:	e466                	sd	s9,8(sp)
    8000313e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003140:	0001c797          	auipc	a5,0x1c
    80003144:	66c7a783          	lw	a5,1644(a5) # 8001f7ac <sb+0x4>
    80003148:	cbc1                	beqz	a5,800031d8 <balloc+0xb2>
    8000314a:	8baa                	mv	s7,a0
    8000314c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000314e:	0001cb17          	auipc	s6,0x1c
    80003152:	65ab0b13          	addi	s6,s6,1626 # 8001f7a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003156:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003158:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000315a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000315c:	6c89                	lui	s9,0x2
    8000315e:	a831                	j	8000317a <balloc+0x54>
    brelse(bp);
    80003160:	854a                	mv	a0,s2
    80003162:	00000097          	auipc	ra,0x0
    80003166:	e32080e7          	jalr	-462(ra) # 80002f94 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000316a:	015c87bb          	addw	a5,s9,s5
    8000316e:	00078a9b          	sext.w	s5,a5
    80003172:	004b2703          	lw	a4,4(s6)
    80003176:	06eaf163          	bgeu	s5,a4,800031d8 <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    8000317a:	41fad79b          	sraiw	a5,s5,0x1f
    8000317e:	0137d79b          	srliw	a5,a5,0x13
    80003182:	015787bb          	addw	a5,a5,s5
    80003186:	40d7d79b          	sraiw	a5,a5,0xd
    8000318a:	01cb2583          	lw	a1,28(s6)
    8000318e:	9dbd                	addw	a1,a1,a5
    80003190:	855e                	mv	a0,s7
    80003192:	00000097          	auipc	ra,0x0
    80003196:	cd2080e7          	jalr	-814(ra) # 80002e64 <bread>
    8000319a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000319c:	004b2503          	lw	a0,4(s6)
    800031a0:	000a849b          	sext.w	s1,s5
    800031a4:	8762                	mv	a4,s8
    800031a6:	faa4fde3          	bgeu	s1,a0,80003160 <balloc+0x3a>
      m = 1 << (bi % 8);
    800031aa:	00777693          	andi	a3,a4,7
    800031ae:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031b2:	41f7579b          	sraiw	a5,a4,0x1f
    800031b6:	01d7d79b          	srliw	a5,a5,0x1d
    800031ba:	9fb9                	addw	a5,a5,a4
    800031bc:	4037d79b          	sraiw	a5,a5,0x3
    800031c0:	00f90633          	add	a2,s2,a5
    800031c4:	05864603          	lbu	a2,88(a2)
    800031c8:	00c6f5b3          	and	a1,a3,a2
    800031cc:	cd91                	beqz	a1,800031e8 <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031ce:	2705                	addiw	a4,a4,1
    800031d0:	2485                	addiw	s1,s1,1
    800031d2:	fd471ae3          	bne	a4,s4,800031a6 <balloc+0x80>
    800031d6:	b769                	j	80003160 <balloc+0x3a>
  panic("balloc: out of blocks");
    800031d8:	00005517          	auipc	a0,0x5
    800031dc:	39050513          	addi	a0,a0,912 # 80008568 <syscalls+0x108>
    800031e0:	ffffd097          	auipc	ra,0xffffd
    800031e4:	35a080e7          	jalr	858(ra) # 8000053a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031e8:	97ca                	add	a5,a5,s2
    800031ea:	8e55                	or	a2,a2,a3
    800031ec:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800031f0:	854a                	mv	a0,s2
    800031f2:	00001097          	auipc	ra,0x1
    800031f6:	026080e7          	jalr	38(ra) # 80004218 <log_write>
        brelse(bp);
    800031fa:	854a                	mv	a0,s2
    800031fc:	00000097          	auipc	ra,0x0
    80003200:	d98080e7          	jalr	-616(ra) # 80002f94 <brelse>
  bp = bread(dev, bno);
    80003204:	85a6                	mv	a1,s1
    80003206:	855e                	mv	a0,s7
    80003208:	00000097          	auipc	ra,0x0
    8000320c:	c5c080e7          	jalr	-932(ra) # 80002e64 <bread>
    80003210:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003212:	40000613          	li	a2,1024
    80003216:	4581                	li	a1,0
    80003218:	05850513          	addi	a0,a0,88
    8000321c:	ffffe097          	auipc	ra,0xffffe
    80003220:	ab0080e7          	jalr	-1360(ra) # 80000ccc <memset>
  log_write(bp);
    80003224:	854a                	mv	a0,s2
    80003226:	00001097          	auipc	ra,0x1
    8000322a:	ff2080e7          	jalr	-14(ra) # 80004218 <log_write>
  brelse(bp);
    8000322e:	854a                	mv	a0,s2
    80003230:	00000097          	auipc	ra,0x0
    80003234:	d64080e7          	jalr	-668(ra) # 80002f94 <brelse>
}
    80003238:	8526                	mv	a0,s1
    8000323a:	60e6                	ld	ra,88(sp)
    8000323c:	6446                	ld	s0,80(sp)
    8000323e:	64a6                	ld	s1,72(sp)
    80003240:	6906                	ld	s2,64(sp)
    80003242:	79e2                	ld	s3,56(sp)
    80003244:	7a42                	ld	s4,48(sp)
    80003246:	7aa2                	ld	s5,40(sp)
    80003248:	7b02                	ld	s6,32(sp)
    8000324a:	6be2                	ld	s7,24(sp)
    8000324c:	6c42                	ld	s8,16(sp)
    8000324e:	6ca2                	ld	s9,8(sp)
    80003250:	6125                	addi	sp,sp,96
    80003252:	8082                	ret

0000000080003254 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003254:	7179                	addi	sp,sp,-48
    80003256:	f406                	sd	ra,40(sp)
    80003258:	f022                	sd	s0,32(sp)
    8000325a:	ec26                	sd	s1,24(sp)
    8000325c:	e84a                	sd	s2,16(sp)
    8000325e:	e44e                	sd	s3,8(sp)
    80003260:	e052                	sd	s4,0(sp)
    80003262:	1800                	addi	s0,sp,48
    80003264:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003266:	47ad                	li	a5,11
    80003268:	04b7fe63          	bgeu	a5,a1,800032c4 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000326c:	ff45849b          	addiw	s1,a1,-12
    80003270:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003274:	0ff00793          	li	a5,255
    80003278:	0ae7e463          	bltu	a5,a4,80003320 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000327c:	08052583          	lw	a1,128(a0)
    80003280:	c5b5                	beqz	a1,800032ec <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003282:	00092503          	lw	a0,0(s2)
    80003286:	00000097          	auipc	ra,0x0
    8000328a:	bde080e7          	jalr	-1058(ra) # 80002e64 <bread>
    8000328e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003290:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003294:	02049713          	slli	a4,s1,0x20
    80003298:	01e75593          	srli	a1,a4,0x1e
    8000329c:	00b784b3          	add	s1,a5,a1
    800032a0:	0004a983          	lw	s3,0(s1)
    800032a4:	04098e63          	beqz	s3,80003300 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800032a8:	8552                	mv	a0,s4
    800032aa:	00000097          	auipc	ra,0x0
    800032ae:	cea080e7          	jalr	-790(ra) # 80002f94 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800032b2:	854e                	mv	a0,s3
    800032b4:	70a2                	ld	ra,40(sp)
    800032b6:	7402                	ld	s0,32(sp)
    800032b8:	64e2                	ld	s1,24(sp)
    800032ba:	6942                	ld	s2,16(sp)
    800032bc:	69a2                	ld	s3,8(sp)
    800032be:	6a02                	ld	s4,0(sp)
    800032c0:	6145                	addi	sp,sp,48
    800032c2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800032c4:	02059793          	slli	a5,a1,0x20
    800032c8:	01e7d593          	srli	a1,a5,0x1e
    800032cc:	00b504b3          	add	s1,a0,a1
    800032d0:	0504a983          	lw	s3,80(s1)
    800032d4:	fc099fe3          	bnez	s3,800032b2 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800032d8:	4108                	lw	a0,0(a0)
    800032da:	00000097          	auipc	ra,0x0
    800032de:	e4c080e7          	jalr	-436(ra) # 80003126 <balloc>
    800032e2:	0005099b          	sext.w	s3,a0
    800032e6:	0534a823          	sw	s3,80(s1)
    800032ea:	b7e1                	j	800032b2 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800032ec:	4108                	lw	a0,0(a0)
    800032ee:	00000097          	auipc	ra,0x0
    800032f2:	e38080e7          	jalr	-456(ra) # 80003126 <balloc>
    800032f6:	0005059b          	sext.w	a1,a0
    800032fa:	08b92023          	sw	a1,128(s2)
    800032fe:	b751                	j	80003282 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003300:	00092503          	lw	a0,0(s2)
    80003304:	00000097          	auipc	ra,0x0
    80003308:	e22080e7          	jalr	-478(ra) # 80003126 <balloc>
    8000330c:	0005099b          	sext.w	s3,a0
    80003310:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003314:	8552                	mv	a0,s4
    80003316:	00001097          	auipc	ra,0x1
    8000331a:	f02080e7          	jalr	-254(ra) # 80004218 <log_write>
    8000331e:	b769                	j	800032a8 <bmap+0x54>
  panic("bmap: out of range");
    80003320:	00005517          	auipc	a0,0x5
    80003324:	26050513          	addi	a0,a0,608 # 80008580 <syscalls+0x120>
    80003328:	ffffd097          	auipc	ra,0xffffd
    8000332c:	212080e7          	jalr	530(ra) # 8000053a <panic>

0000000080003330 <iget>:
{
    80003330:	7179                	addi	sp,sp,-48
    80003332:	f406                	sd	ra,40(sp)
    80003334:	f022                	sd	s0,32(sp)
    80003336:	ec26                	sd	s1,24(sp)
    80003338:	e84a                	sd	s2,16(sp)
    8000333a:	e44e                	sd	s3,8(sp)
    8000333c:	e052                	sd	s4,0(sp)
    8000333e:	1800                	addi	s0,sp,48
    80003340:	89aa                	mv	s3,a0
    80003342:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003344:	0001c517          	auipc	a0,0x1c
    80003348:	48450513          	addi	a0,a0,1156 # 8001f7c8 <itable>
    8000334c:	ffffe097          	auipc	ra,0xffffe
    80003350:	884080e7          	jalr	-1916(ra) # 80000bd0 <acquire>
  empty = 0;
    80003354:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003356:	0001c497          	auipc	s1,0x1c
    8000335a:	48a48493          	addi	s1,s1,1162 # 8001f7e0 <itable+0x18>
    8000335e:	0001e697          	auipc	a3,0x1e
    80003362:	f1268693          	addi	a3,a3,-238 # 80021270 <log>
    80003366:	a039                	j	80003374 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003368:	02090b63          	beqz	s2,8000339e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000336c:	08848493          	addi	s1,s1,136
    80003370:	02d48a63          	beq	s1,a3,800033a4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003374:	449c                	lw	a5,8(s1)
    80003376:	fef059e3          	blez	a5,80003368 <iget+0x38>
    8000337a:	4098                	lw	a4,0(s1)
    8000337c:	ff3716e3          	bne	a4,s3,80003368 <iget+0x38>
    80003380:	40d8                	lw	a4,4(s1)
    80003382:	ff4713e3          	bne	a4,s4,80003368 <iget+0x38>
      ip->ref++;
    80003386:	2785                	addiw	a5,a5,1
    80003388:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000338a:	0001c517          	auipc	a0,0x1c
    8000338e:	43e50513          	addi	a0,a0,1086 # 8001f7c8 <itable>
    80003392:	ffffe097          	auipc	ra,0xffffe
    80003396:	8f2080e7          	jalr	-1806(ra) # 80000c84 <release>
      return ip;
    8000339a:	8926                	mv	s2,s1
    8000339c:	a03d                	j	800033ca <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000339e:	f7f9                	bnez	a5,8000336c <iget+0x3c>
    800033a0:	8926                	mv	s2,s1
    800033a2:	b7e9                	j	8000336c <iget+0x3c>
  if(empty == 0)
    800033a4:	02090c63          	beqz	s2,800033dc <iget+0xac>
  ip->dev = dev;
    800033a8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033ac:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033b0:	4785                	li	a5,1
    800033b2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033b6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800033ba:	0001c517          	auipc	a0,0x1c
    800033be:	40e50513          	addi	a0,a0,1038 # 8001f7c8 <itable>
    800033c2:	ffffe097          	auipc	ra,0xffffe
    800033c6:	8c2080e7          	jalr	-1854(ra) # 80000c84 <release>
}
    800033ca:	854a                	mv	a0,s2
    800033cc:	70a2                	ld	ra,40(sp)
    800033ce:	7402                	ld	s0,32(sp)
    800033d0:	64e2                	ld	s1,24(sp)
    800033d2:	6942                	ld	s2,16(sp)
    800033d4:	69a2                	ld	s3,8(sp)
    800033d6:	6a02                	ld	s4,0(sp)
    800033d8:	6145                	addi	sp,sp,48
    800033da:	8082                	ret
    panic("iget: no inodes");
    800033dc:	00005517          	auipc	a0,0x5
    800033e0:	1bc50513          	addi	a0,a0,444 # 80008598 <syscalls+0x138>
    800033e4:	ffffd097          	auipc	ra,0xffffd
    800033e8:	156080e7          	jalr	342(ra) # 8000053a <panic>

00000000800033ec <fsinit>:
fsinit(int dev) {
    800033ec:	7179                	addi	sp,sp,-48
    800033ee:	f406                	sd	ra,40(sp)
    800033f0:	f022                	sd	s0,32(sp)
    800033f2:	ec26                	sd	s1,24(sp)
    800033f4:	e84a                	sd	s2,16(sp)
    800033f6:	e44e                	sd	s3,8(sp)
    800033f8:	1800                	addi	s0,sp,48
    800033fa:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800033fc:	4585                	li	a1,1
    800033fe:	00000097          	auipc	ra,0x0
    80003402:	a66080e7          	jalr	-1434(ra) # 80002e64 <bread>
    80003406:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003408:	0001c997          	auipc	s3,0x1c
    8000340c:	3a098993          	addi	s3,s3,928 # 8001f7a8 <sb>
    80003410:	02000613          	li	a2,32
    80003414:	05850593          	addi	a1,a0,88
    80003418:	854e                	mv	a0,s3
    8000341a:	ffffe097          	auipc	ra,0xffffe
    8000341e:	90e080e7          	jalr	-1778(ra) # 80000d28 <memmove>
  brelse(bp);
    80003422:	8526                	mv	a0,s1
    80003424:	00000097          	auipc	ra,0x0
    80003428:	b70080e7          	jalr	-1168(ra) # 80002f94 <brelse>
  if(sb.magic != FSMAGIC)
    8000342c:	0009a703          	lw	a4,0(s3)
    80003430:	102037b7          	lui	a5,0x10203
    80003434:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003438:	02f71263          	bne	a4,a5,8000345c <fsinit+0x70>
  initlog(dev, &sb);
    8000343c:	0001c597          	auipc	a1,0x1c
    80003440:	36c58593          	addi	a1,a1,876 # 8001f7a8 <sb>
    80003444:	854a                	mv	a0,s2
    80003446:	00001097          	auipc	ra,0x1
    8000344a:	b56080e7          	jalr	-1194(ra) # 80003f9c <initlog>
}
    8000344e:	70a2                	ld	ra,40(sp)
    80003450:	7402                	ld	s0,32(sp)
    80003452:	64e2                	ld	s1,24(sp)
    80003454:	6942                	ld	s2,16(sp)
    80003456:	69a2                	ld	s3,8(sp)
    80003458:	6145                	addi	sp,sp,48
    8000345a:	8082                	ret
    panic("invalid file system");
    8000345c:	00005517          	auipc	a0,0x5
    80003460:	14c50513          	addi	a0,a0,332 # 800085a8 <syscalls+0x148>
    80003464:	ffffd097          	auipc	ra,0xffffd
    80003468:	0d6080e7          	jalr	214(ra) # 8000053a <panic>

000000008000346c <iinit>:
{
    8000346c:	7179                	addi	sp,sp,-48
    8000346e:	f406                	sd	ra,40(sp)
    80003470:	f022                	sd	s0,32(sp)
    80003472:	ec26                	sd	s1,24(sp)
    80003474:	e84a                	sd	s2,16(sp)
    80003476:	e44e                	sd	s3,8(sp)
    80003478:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000347a:	00005597          	auipc	a1,0x5
    8000347e:	14658593          	addi	a1,a1,326 # 800085c0 <syscalls+0x160>
    80003482:	0001c517          	auipc	a0,0x1c
    80003486:	34650513          	addi	a0,a0,838 # 8001f7c8 <itable>
    8000348a:	ffffd097          	auipc	ra,0xffffd
    8000348e:	6b6080e7          	jalr	1718(ra) # 80000b40 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003492:	0001c497          	auipc	s1,0x1c
    80003496:	35e48493          	addi	s1,s1,862 # 8001f7f0 <itable+0x28>
    8000349a:	0001e997          	auipc	s3,0x1e
    8000349e:	de698993          	addi	s3,s3,-538 # 80021280 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800034a2:	00005917          	auipc	s2,0x5
    800034a6:	12690913          	addi	s2,s2,294 # 800085c8 <syscalls+0x168>
    800034aa:	85ca                	mv	a1,s2
    800034ac:	8526                	mv	a0,s1
    800034ae:	00001097          	auipc	ra,0x1
    800034b2:	e4e080e7          	jalr	-434(ra) # 800042fc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034b6:	08848493          	addi	s1,s1,136
    800034ba:	ff3498e3          	bne	s1,s3,800034aa <iinit+0x3e>
}
    800034be:	70a2                	ld	ra,40(sp)
    800034c0:	7402                	ld	s0,32(sp)
    800034c2:	64e2                	ld	s1,24(sp)
    800034c4:	6942                	ld	s2,16(sp)
    800034c6:	69a2                	ld	s3,8(sp)
    800034c8:	6145                	addi	sp,sp,48
    800034ca:	8082                	ret

00000000800034cc <ialloc>:
{
    800034cc:	715d                	addi	sp,sp,-80
    800034ce:	e486                	sd	ra,72(sp)
    800034d0:	e0a2                	sd	s0,64(sp)
    800034d2:	fc26                	sd	s1,56(sp)
    800034d4:	f84a                	sd	s2,48(sp)
    800034d6:	f44e                	sd	s3,40(sp)
    800034d8:	f052                	sd	s4,32(sp)
    800034da:	ec56                	sd	s5,24(sp)
    800034dc:	e85a                	sd	s6,16(sp)
    800034de:	e45e                	sd	s7,8(sp)
    800034e0:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800034e2:	0001c717          	auipc	a4,0x1c
    800034e6:	2d272703          	lw	a4,722(a4) # 8001f7b4 <sb+0xc>
    800034ea:	4785                	li	a5,1
    800034ec:	04e7fa63          	bgeu	a5,a4,80003540 <ialloc+0x74>
    800034f0:	8aaa                	mv	s5,a0
    800034f2:	8bae                	mv	s7,a1
    800034f4:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800034f6:	0001ca17          	auipc	s4,0x1c
    800034fa:	2b2a0a13          	addi	s4,s4,690 # 8001f7a8 <sb>
    800034fe:	00048b1b          	sext.w	s6,s1
    80003502:	0044d593          	srli	a1,s1,0x4
    80003506:	018a2783          	lw	a5,24(s4)
    8000350a:	9dbd                	addw	a1,a1,a5
    8000350c:	8556                	mv	a0,s5
    8000350e:	00000097          	auipc	ra,0x0
    80003512:	956080e7          	jalr	-1706(ra) # 80002e64 <bread>
    80003516:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003518:	05850993          	addi	s3,a0,88
    8000351c:	00f4f793          	andi	a5,s1,15
    80003520:	079a                	slli	a5,a5,0x6
    80003522:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003524:	00099783          	lh	a5,0(s3)
    80003528:	c785                	beqz	a5,80003550 <ialloc+0x84>
    brelse(bp);
    8000352a:	00000097          	auipc	ra,0x0
    8000352e:	a6a080e7          	jalr	-1430(ra) # 80002f94 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003532:	0485                	addi	s1,s1,1
    80003534:	00ca2703          	lw	a4,12(s4)
    80003538:	0004879b          	sext.w	a5,s1
    8000353c:	fce7e1e3          	bltu	a5,a4,800034fe <ialloc+0x32>
  panic("ialloc: no inodes");
    80003540:	00005517          	auipc	a0,0x5
    80003544:	09050513          	addi	a0,a0,144 # 800085d0 <syscalls+0x170>
    80003548:	ffffd097          	auipc	ra,0xffffd
    8000354c:	ff2080e7          	jalr	-14(ra) # 8000053a <panic>
      memset(dip, 0, sizeof(*dip));
    80003550:	04000613          	li	a2,64
    80003554:	4581                	li	a1,0
    80003556:	854e                	mv	a0,s3
    80003558:	ffffd097          	auipc	ra,0xffffd
    8000355c:	774080e7          	jalr	1908(ra) # 80000ccc <memset>
      dip->type = type;
    80003560:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003564:	854a                	mv	a0,s2
    80003566:	00001097          	auipc	ra,0x1
    8000356a:	cb2080e7          	jalr	-846(ra) # 80004218 <log_write>
      brelse(bp);
    8000356e:	854a                	mv	a0,s2
    80003570:	00000097          	auipc	ra,0x0
    80003574:	a24080e7          	jalr	-1500(ra) # 80002f94 <brelse>
      return iget(dev, inum);
    80003578:	85da                	mv	a1,s6
    8000357a:	8556                	mv	a0,s5
    8000357c:	00000097          	auipc	ra,0x0
    80003580:	db4080e7          	jalr	-588(ra) # 80003330 <iget>
}
    80003584:	60a6                	ld	ra,72(sp)
    80003586:	6406                	ld	s0,64(sp)
    80003588:	74e2                	ld	s1,56(sp)
    8000358a:	7942                	ld	s2,48(sp)
    8000358c:	79a2                	ld	s3,40(sp)
    8000358e:	7a02                	ld	s4,32(sp)
    80003590:	6ae2                	ld	s5,24(sp)
    80003592:	6b42                	ld	s6,16(sp)
    80003594:	6ba2                	ld	s7,8(sp)
    80003596:	6161                	addi	sp,sp,80
    80003598:	8082                	ret

000000008000359a <iupdate>:
{
    8000359a:	1101                	addi	sp,sp,-32
    8000359c:	ec06                	sd	ra,24(sp)
    8000359e:	e822                	sd	s0,16(sp)
    800035a0:	e426                	sd	s1,8(sp)
    800035a2:	e04a                	sd	s2,0(sp)
    800035a4:	1000                	addi	s0,sp,32
    800035a6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035a8:	415c                	lw	a5,4(a0)
    800035aa:	0047d79b          	srliw	a5,a5,0x4
    800035ae:	0001c597          	auipc	a1,0x1c
    800035b2:	2125a583          	lw	a1,530(a1) # 8001f7c0 <sb+0x18>
    800035b6:	9dbd                	addw	a1,a1,a5
    800035b8:	4108                	lw	a0,0(a0)
    800035ba:	00000097          	auipc	ra,0x0
    800035be:	8aa080e7          	jalr	-1878(ra) # 80002e64 <bread>
    800035c2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035c4:	05850793          	addi	a5,a0,88
    800035c8:	40d8                	lw	a4,4(s1)
    800035ca:	8b3d                	andi	a4,a4,15
    800035cc:	071a                	slli	a4,a4,0x6
    800035ce:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800035d0:	04449703          	lh	a4,68(s1)
    800035d4:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800035d8:	04649703          	lh	a4,70(s1)
    800035dc:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800035e0:	04849703          	lh	a4,72(s1)
    800035e4:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800035e8:	04a49703          	lh	a4,74(s1)
    800035ec:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800035f0:	44f8                	lw	a4,76(s1)
    800035f2:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800035f4:	03400613          	li	a2,52
    800035f8:	05048593          	addi	a1,s1,80
    800035fc:	00c78513          	addi	a0,a5,12
    80003600:	ffffd097          	auipc	ra,0xffffd
    80003604:	728080e7          	jalr	1832(ra) # 80000d28 <memmove>
  log_write(bp);
    80003608:	854a                	mv	a0,s2
    8000360a:	00001097          	auipc	ra,0x1
    8000360e:	c0e080e7          	jalr	-1010(ra) # 80004218 <log_write>
  brelse(bp);
    80003612:	854a                	mv	a0,s2
    80003614:	00000097          	auipc	ra,0x0
    80003618:	980080e7          	jalr	-1664(ra) # 80002f94 <brelse>
}
    8000361c:	60e2                	ld	ra,24(sp)
    8000361e:	6442                	ld	s0,16(sp)
    80003620:	64a2                	ld	s1,8(sp)
    80003622:	6902                	ld	s2,0(sp)
    80003624:	6105                	addi	sp,sp,32
    80003626:	8082                	ret

0000000080003628 <idup>:
{
    80003628:	1101                	addi	sp,sp,-32
    8000362a:	ec06                	sd	ra,24(sp)
    8000362c:	e822                	sd	s0,16(sp)
    8000362e:	e426                	sd	s1,8(sp)
    80003630:	1000                	addi	s0,sp,32
    80003632:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003634:	0001c517          	auipc	a0,0x1c
    80003638:	19450513          	addi	a0,a0,404 # 8001f7c8 <itable>
    8000363c:	ffffd097          	auipc	ra,0xffffd
    80003640:	594080e7          	jalr	1428(ra) # 80000bd0 <acquire>
  ip->ref++;
    80003644:	449c                	lw	a5,8(s1)
    80003646:	2785                	addiw	a5,a5,1
    80003648:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000364a:	0001c517          	auipc	a0,0x1c
    8000364e:	17e50513          	addi	a0,a0,382 # 8001f7c8 <itable>
    80003652:	ffffd097          	auipc	ra,0xffffd
    80003656:	632080e7          	jalr	1586(ra) # 80000c84 <release>
}
    8000365a:	8526                	mv	a0,s1
    8000365c:	60e2                	ld	ra,24(sp)
    8000365e:	6442                	ld	s0,16(sp)
    80003660:	64a2                	ld	s1,8(sp)
    80003662:	6105                	addi	sp,sp,32
    80003664:	8082                	ret

0000000080003666 <ilock>:
{
    80003666:	1101                	addi	sp,sp,-32
    80003668:	ec06                	sd	ra,24(sp)
    8000366a:	e822                	sd	s0,16(sp)
    8000366c:	e426                	sd	s1,8(sp)
    8000366e:	e04a                	sd	s2,0(sp)
    80003670:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003672:	c115                	beqz	a0,80003696 <ilock+0x30>
    80003674:	84aa                	mv	s1,a0
    80003676:	451c                	lw	a5,8(a0)
    80003678:	00f05f63          	blez	a5,80003696 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000367c:	0541                	addi	a0,a0,16
    8000367e:	00001097          	auipc	ra,0x1
    80003682:	cb8080e7          	jalr	-840(ra) # 80004336 <acquiresleep>
  if(ip->valid == 0){
    80003686:	40bc                	lw	a5,64(s1)
    80003688:	cf99                	beqz	a5,800036a6 <ilock+0x40>
}
    8000368a:	60e2                	ld	ra,24(sp)
    8000368c:	6442                	ld	s0,16(sp)
    8000368e:	64a2                	ld	s1,8(sp)
    80003690:	6902                	ld	s2,0(sp)
    80003692:	6105                	addi	sp,sp,32
    80003694:	8082                	ret
    panic("ilock");
    80003696:	00005517          	auipc	a0,0x5
    8000369a:	f5250513          	addi	a0,a0,-174 # 800085e8 <syscalls+0x188>
    8000369e:	ffffd097          	auipc	ra,0xffffd
    800036a2:	e9c080e7          	jalr	-356(ra) # 8000053a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036a6:	40dc                	lw	a5,4(s1)
    800036a8:	0047d79b          	srliw	a5,a5,0x4
    800036ac:	0001c597          	auipc	a1,0x1c
    800036b0:	1145a583          	lw	a1,276(a1) # 8001f7c0 <sb+0x18>
    800036b4:	9dbd                	addw	a1,a1,a5
    800036b6:	4088                	lw	a0,0(s1)
    800036b8:	fffff097          	auipc	ra,0xfffff
    800036bc:	7ac080e7          	jalr	1964(ra) # 80002e64 <bread>
    800036c0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036c2:	05850593          	addi	a1,a0,88
    800036c6:	40dc                	lw	a5,4(s1)
    800036c8:	8bbd                	andi	a5,a5,15
    800036ca:	079a                	slli	a5,a5,0x6
    800036cc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036ce:	00059783          	lh	a5,0(a1)
    800036d2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036d6:	00259783          	lh	a5,2(a1)
    800036da:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800036de:	00459783          	lh	a5,4(a1)
    800036e2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800036e6:	00659783          	lh	a5,6(a1)
    800036ea:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800036ee:	459c                	lw	a5,8(a1)
    800036f0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800036f2:	03400613          	li	a2,52
    800036f6:	05b1                	addi	a1,a1,12
    800036f8:	05048513          	addi	a0,s1,80
    800036fc:	ffffd097          	auipc	ra,0xffffd
    80003700:	62c080e7          	jalr	1580(ra) # 80000d28 <memmove>
    brelse(bp);
    80003704:	854a                	mv	a0,s2
    80003706:	00000097          	auipc	ra,0x0
    8000370a:	88e080e7          	jalr	-1906(ra) # 80002f94 <brelse>
    ip->valid = 1;
    8000370e:	4785                	li	a5,1
    80003710:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003712:	04449783          	lh	a5,68(s1)
    80003716:	fbb5                	bnez	a5,8000368a <ilock+0x24>
      panic("ilock: no type");
    80003718:	00005517          	auipc	a0,0x5
    8000371c:	ed850513          	addi	a0,a0,-296 # 800085f0 <syscalls+0x190>
    80003720:	ffffd097          	auipc	ra,0xffffd
    80003724:	e1a080e7          	jalr	-486(ra) # 8000053a <panic>

0000000080003728 <iunlock>:
{
    80003728:	1101                	addi	sp,sp,-32
    8000372a:	ec06                	sd	ra,24(sp)
    8000372c:	e822                	sd	s0,16(sp)
    8000372e:	e426                	sd	s1,8(sp)
    80003730:	e04a                	sd	s2,0(sp)
    80003732:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003734:	c905                	beqz	a0,80003764 <iunlock+0x3c>
    80003736:	84aa                	mv	s1,a0
    80003738:	01050913          	addi	s2,a0,16
    8000373c:	854a                	mv	a0,s2
    8000373e:	00001097          	auipc	ra,0x1
    80003742:	c92080e7          	jalr	-878(ra) # 800043d0 <holdingsleep>
    80003746:	cd19                	beqz	a0,80003764 <iunlock+0x3c>
    80003748:	449c                	lw	a5,8(s1)
    8000374a:	00f05d63          	blez	a5,80003764 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000374e:	854a                	mv	a0,s2
    80003750:	00001097          	auipc	ra,0x1
    80003754:	c3c080e7          	jalr	-964(ra) # 8000438c <releasesleep>
}
    80003758:	60e2                	ld	ra,24(sp)
    8000375a:	6442                	ld	s0,16(sp)
    8000375c:	64a2                	ld	s1,8(sp)
    8000375e:	6902                	ld	s2,0(sp)
    80003760:	6105                	addi	sp,sp,32
    80003762:	8082                	ret
    panic("iunlock");
    80003764:	00005517          	auipc	a0,0x5
    80003768:	e9c50513          	addi	a0,a0,-356 # 80008600 <syscalls+0x1a0>
    8000376c:	ffffd097          	auipc	ra,0xffffd
    80003770:	dce080e7          	jalr	-562(ra) # 8000053a <panic>

0000000080003774 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003774:	7179                	addi	sp,sp,-48
    80003776:	f406                	sd	ra,40(sp)
    80003778:	f022                	sd	s0,32(sp)
    8000377a:	ec26                	sd	s1,24(sp)
    8000377c:	e84a                	sd	s2,16(sp)
    8000377e:	e44e                	sd	s3,8(sp)
    80003780:	e052                	sd	s4,0(sp)
    80003782:	1800                	addi	s0,sp,48
    80003784:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003786:	05050493          	addi	s1,a0,80
    8000378a:	08050913          	addi	s2,a0,128
    8000378e:	a021                	j	80003796 <itrunc+0x22>
    80003790:	0491                	addi	s1,s1,4
    80003792:	01248d63          	beq	s1,s2,800037ac <itrunc+0x38>
    if(ip->addrs[i]){
    80003796:	408c                	lw	a1,0(s1)
    80003798:	dde5                	beqz	a1,80003790 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000379a:	0009a503          	lw	a0,0(s3)
    8000379e:	00000097          	auipc	ra,0x0
    800037a2:	90c080e7          	jalr	-1780(ra) # 800030aa <bfree>
      ip->addrs[i] = 0;
    800037a6:	0004a023          	sw	zero,0(s1)
    800037aa:	b7dd                	j	80003790 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037ac:	0809a583          	lw	a1,128(s3)
    800037b0:	e185                	bnez	a1,800037d0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037b2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037b6:	854e                	mv	a0,s3
    800037b8:	00000097          	auipc	ra,0x0
    800037bc:	de2080e7          	jalr	-542(ra) # 8000359a <iupdate>
}
    800037c0:	70a2                	ld	ra,40(sp)
    800037c2:	7402                	ld	s0,32(sp)
    800037c4:	64e2                	ld	s1,24(sp)
    800037c6:	6942                	ld	s2,16(sp)
    800037c8:	69a2                	ld	s3,8(sp)
    800037ca:	6a02                	ld	s4,0(sp)
    800037cc:	6145                	addi	sp,sp,48
    800037ce:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037d0:	0009a503          	lw	a0,0(s3)
    800037d4:	fffff097          	auipc	ra,0xfffff
    800037d8:	690080e7          	jalr	1680(ra) # 80002e64 <bread>
    800037dc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800037de:	05850493          	addi	s1,a0,88
    800037e2:	45850913          	addi	s2,a0,1112
    800037e6:	a021                	j	800037ee <itrunc+0x7a>
    800037e8:	0491                	addi	s1,s1,4
    800037ea:	01248b63          	beq	s1,s2,80003800 <itrunc+0x8c>
      if(a[j])
    800037ee:	408c                	lw	a1,0(s1)
    800037f0:	dde5                	beqz	a1,800037e8 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800037f2:	0009a503          	lw	a0,0(s3)
    800037f6:	00000097          	auipc	ra,0x0
    800037fa:	8b4080e7          	jalr	-1868(ra) # 800030aa <bfree>
    800037fe:	b7ed                	j	800037e8 <itrunc+0x74>
    brelse(bp);
    80003800:	8552                	mv	a0,s4
    80003802:	fffff097          	auipc	ra,0xfffff
    80003806:	792080e7          	jalr	1938(ra) # 80002f94 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000380a:	0809a583          	lw	a1,128(s3)
    8000380e:	0009a503          	lw	a0,0(s3)
    80003812:	00000097          	auipc	ra,0x0
    80003816:	898080e7          	jalr	-1896(ra) # 800030aa <bfree>
    ip->addrs[NDIRECT] = 0;
    8000381a:	0809a023          	sw	zero,128(s3)
    8000381e:	bf51                	j	800037b2 <itrunc+0x3e>

0000000080003820 <iput>:
{
    80003820:	1101                	addi	sp,sp,-32
    80003822:	ec06                	sd	ra,24(sp)
    80003824:	e822                	sd	s0,16(sp)
    80003826:	e426                	sd	s1,8(sp)
    80003828:	e04a                	sd	s2,0(sp)
    8000382a:	1000                	addi	s0,sp,32
    8000382c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000382e:	0001c517          	auipc	a0,0x1c
    80003832:	f9a50513          	addi	a0,a0,-102 # 8001f7c8 <itable>
    80003836:	ffffd097          	auipc	ra,0xffffd
    8000383a:	39a080e7          	jalr	922(ra) # 80000bd0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000383e:	4498                	lw	a4,8(s1)
    80003840:	4785                	li	a5,1
    80003842:	02f70363          	beq	a4,a5,80003868 <iput+0x48>
  ip->ref--;
    80003846:	449c                	lw	a5,8(s1)
    80003848:	37fd                	addiw	a5,a5,-1
    8000384a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000384c:	0001c517          	auipc	a0,0x1c
    80003850:	f7c50513          	addi	a0,a0,-132 # 8001f7c8 <itable>
    80003854:	ffffd097          	auipc	ra,0xffffd
    80003858:	430080e7          	jalr	1072(ra) # 80000c84 <release>
}
    8000385c:	60e2                	ld	ra,24(sp)
    8000385e:	6442                	ld	s0,16(sp)
    80003860:	64a2                	ld	s1,8(sp)
    80003862:	6902                	ld	s2,0(sp)
    80003864:	6105                	addi	sp,sp,32
    80003866:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003868:	40bc                	lw	a5,64(s1)
    8000386a:	dff1                	beqz	a5,80003846 <iput+0x26>
    8000386c:	04a49783          	lh	a5,74(s1)
    80003870:	fbf9                	bnez	a5,80003846 <iput+0x26>
    acquiresleep(&ip->lock);
    80003872:	01048913          	addi	s2,s1,16
    80003876:	854a                	mv	a0,s2
    80003878:	00001097          	auipc	ra,0x1
    8000387c:	abe080e7          	jalr	-1346(ra) # 80004336 <acquiresleep>
    release(&itable.lock);
    80003880:	0001c517          	auipc	a0,0x1c
    80003884:	f4850513          	addi	a0,a0,-184 # 8001f7c8 <itable>
    80003888:	ffffd097          	auipc	ra,0xffffd
    8000388c:	3fc080e7          	jalr	1020(ra) # 80000c84 <release>
    itrunc(ip);
    80003890:	8526                	mv	a0,s1
    80003892:	00000097          	auipc	ra,0x0
    80003896:	ee2080e7          	jalr	-286(ra) # 80003774 <itrunc>
    ip->type = 0;
    8000389a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000389e:	8526                	mv	a0,s1
    800038a0:	00000097          	auipc	ra,0x0
    800038a4:	cfa080e7          	jalr	-774(ra) # 8000359a <iupdate>
    ip->valid = 0;
    800038a8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038ac:	854a                	mv	a0,s2
    800038ae:	00001097          	auipc	ra,0x1
    800038b2:	ade080e7          	jalr	-1314(ra) # 8000438c <releasesleep>
    acquire(&itable.lock);
    800038b6:	0001c517          	auipc	a0,0x1c
    800038ba:	f1250513          	addi	a0,a0,-238 # 8001f7c8 <itable>
    800038be:	ffffd097          	auipc	ra,0xffffd
    800038c2:	312080e7          	jalr	786(ra) # 80000bd0 <acquire>
    800038c6:	b741                	j	80003846 <iput+0x26>

00000000800038c8 <iunlockput>:
{
    800038c8:	1101                	addi	sp,sp,-32
    800038ca:	ec06                	sd	ra,24(sp)
    800038cc:	e822                	sd	s0,16(sp)
    800038ce:	e426                	sd	s1,8(sp)
    800038d0:	1000                	addi	s0,sp,32
    800038d2:	84aa                	mv	s1,a0
  iunlock(ip);
    800038d4:	00000097          	auipc	ra,0x0
    800038d8:	e54080e7          	jalr	-428(ra) # 80003728 <iunlock>
  iput(ip);
    800038dc:	8526                	mv	a0,s1
    800038de:	00000097          	auipc	ra,0x0
    800038e2:	f42080e7          	jalr	-190(ra) # 80003820 <iput>
}
    800038e6:	60e2                	ld	ra,24(sp)
    800038e8:	6442                	ld	s0,16(sp)
    800038ea:	64a2                	ld	s1,8(sp)
    800038ec:	6105                	addi	sp,sp,32
    800038ee:	8082                	ret

00000000800038f0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038f0:	1141                	addi	sp,sp,-16
    800038f2:	e422                	sd	s0,8(sp)
    800038f4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038f6:	411c                	lw	a5,0(a0)
    800038f8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038fa:	415c                	lw	a5,4(a0)
    800038fc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038fe:	04451783          	lh	a5,68(a0)
    80003902:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003906:	04a51783          	lh	a5,74(a0)
    8000390a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000390e:	04c56783          	lwu	a5,76(a0)
    80003912:	e99c                	sd	a5,16(a1)
}
    80003914:	6422                	ld	s0,8(sp)
    80003916:	0141                	addi	sp,sp,16
    80003918:	8082                	ret

000000008000391a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000391a:	457c                	lw	a5,76(a0)
    8000391c:	0ed7e963          	bltu	a5,a3,80003a0e <readi+0xf4>
{
    80003920:	7159                	addi	sp,sp,-112
    80003922:	f486                	sd	ra,104(sp)
    80003924:	f0a2                	sd	s0,96(sp)
    80003926:	eca6                	sd	s1,88(sp)
    80003928:	e8ca                	sd	s2,80(sp)
    8000392a:	e4ce                	sd	s3,72(sp)
    8000392c:	e0d2                	sd	s4,64(sp)
    8000392e:	fc56                	sd	s5,56(sp)
    80003930:	f85a                	sd	s6,48(sp)
    80003932:	f45e                	sd	s7,40(sp)
    80003934:	f062                	sd	s8,32(sp)
    80003936:	ec66                	sd	s9,24(sp)
    80003938:	e86a                	sd	s10,16(sp)
    8000393a:	e46e                	sd	s11,8(sp)
    8000393c:	1880                	addi	s0,sp,112
    8000393e:	8baa                	mv	s7,a0
    80003940:	8c2e                	mv	s8,a1
    80003942:	8ab2                	mv	s5,a2
    80003944:	84b6                	mv	s1,a3
    80003946:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003948:	9f35                	addw	a4,a4,a3
    return 0;
    8000394a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000394c:	0ad76063          	bltu	a4,a3,800039ec <readi+0xd2>
  if(off + n > ip->size)
    80003950:	00e7f463          	bgeu	a5,a4,80003958 <readi+0x3e>
    n = ip->size - off;
    80003954:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003958:	0a0b0963          	beqz	s6,80003a0a <readi+0xf0>
    8000395c:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000395e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003962:	5cfd                	li	s9,-1
    80003964:	a82d                	j	8000399e <readi+0x84>
    80003966:	020a1d93          	slli	s11,s4,0x20
    8000396a:	020ddd93          	srli	s11,s11,0x20
    8000396e:	05890613          	addi	a2,s2,88
    80003972:	86ee                	mv	a3,s11
    80003974:	963a                	add	a2,a2,a4
    80003976:	85d6                	mv	a1,s5
    80003978:	8562                	mv	a0,s8
    8000397a:	fffff097          	auipc	ra,0xfffff
    8000397e:	a84080e7          	jalr	-1404(ra) # 800023fe <either_copyout>
    80003982:	05950d63          	beq	a0,s9,800039dc <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003986:	854a                	mv	a0,s2
    80003988:	fffff097          	auipc	ra,0xfffff
    8000398c:	60c080e7          	jalr	1548(ra) # 80002f94 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003990:	013a09bb          	addw	s3,s4,s3
    80003994:	009a04bb          	addw	s1,s4,s1
    80003998:	9aee                	add	s5,s5,s11
    8000399a:	0569f763          	bgeu	s3,s6,800039e8 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000399e:	000ba903          	lw	s2,0(s7)
    800039a2:	00a4d59b          	srliw	a1,s1,0xa
    800039a6:	855e                	mv	a0,s7
    800039a8:	00000097          	auipc	ra,0x0
    800039ac:	8ac080e7          	jalr	-1876(ra) # 80003254 <bmap>
    800039b0:	0005059b          	sext.w	a1,a0
    800039b4:	854a                	mv	a0,s2
    800039b6:	fffff097          	auipc	ra,0xfffff
    800039ba:	4ae080e7          	jalr	1198(ra) # 80002e64 <bread>
    800039be:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039c0:	3ff4f713          	andi	a4,s1,1023
    800039c4:	40ed07bb          	subw	a5,s10,a4
    800039c8:	413b06bb          	subw	a3,s6,s3
    800039cc:	8a3e                	mv	s4,a5
    800039ce:	2781                	sext.w	a5,a5
    800039d0:	0006861b          	sext.w	a2,a3
    800039d4:	f8f679e3          	bgeu	a2,a5,80003966 <readi+0x4c>
    800039d8:	8a36                	mv	s4,a3
    800039da:	b771                	j	80003966 <readi+0x4c>
      brelse(bp);
    800039dc:	854a                	mv	a0,s2
    800039de:	fffff097          	auipc	ra,0xfffff
    800039e2:	5b6080e7          	jalr	1462(ra) # 80002f94 <brelse>
      tot = -1;
    800039e6:	59fd                	li	s3,-1
  }
  return tot;
    800039e8:	0009851b          	sext.w	a0,s3
}
    800039ec:	70a6                	ld	ra,104(sp)
    800039ee:	7406                	ld	s0,96(sp)
    800039f0:	64e6                	ld	s1,88(sp)
    800039f2:	6946                	ld	s2,80(sp)
    800039f4:	69a6                	ld	s3,72(sp)
    800039f6:	6a06                	ld	s4,64(sp)
    800039f8:	7ae2                	ld	s5,56(sp)
    800039fa:	7b42                	ld	s6,48(sp)
    800039fc:	7ba2                	ld	s7,40(sp)
    800039fe:	7c02                	ld	s8,32(sp)
    80003a00:	6ce2                	ld	s9,24(sp)
    80003a02:	6d42                	ld	s10,16(sp)
    80003a04:	6da2                	ld	s11,8(sp)
    80003a06:	6165                	addi	sp,sp,112
    80003a08:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a0a:	89da                	mv	s3,s6
    80003a0c:	bff1                	j	800039e8 <readi+0xce>
    return 0;
    80003a0e:	4501                	li	a0,0
}
    80003a10:	8082                	ret

0000000080003a12 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a12:	457c                	lw	a5,76(a0)
    80003a14:	10d7e863          	bltu	a5,a3,80003b24 <writei+0x112>
{
    80003a18:	7159                	addi	sp,sp,-112
    80003a1a:	f486                	sd	ra,104(sp)
    80003a1c:	f0a2                	sd	s0,96(sp)
    80003a1e:	eca6                	sd	s1,88(sp)
    80003a20:	e8ca                	sd	s2,80(sp)
    80003a22:	e4ce                	sd	s3,72(sp)
    80003a24:	e0d2                	sd	s4,64(sp)
    80003a26:	fc56                	sd	s5,56(sp)
    80003a28:	f85a                	sd	s6,48(sp)
    80003a2a:	f45e                	sd	s7,40(sp)
    80003a2c:	f062                	sd	s8,32(sp)
    80003a2e:	ec66                	sd	s9,24(sp)
    80003a30:	e86a                	sd	s10,16(sp)
    80003a32:	e46e                	sd	s11,8(sp)
    80003a34:	1880                	addi	s0,sp,112
    80003a36:	8b2a                	mv	s6,a0
    80003a38:	8c2e                	mv	s8,a1
    80003a3a:	8ab2                	mv	s5,a2
    80003a3c:	8936                	mv	s2,a3
    80003a3e:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003a40:	00e687bb          	addw	a5,a3,a4
    80003a44:	0ed7e263          	bltu	a5,a3,80003b28 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a48:	00043737          	lui	a4,0x43
    80003a4c:	0ef76063          	bltu	a4,a5,80003b2c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a50:	0c0b8863          	beqz	s7,80003b20 <writei+0x10e>
    80003a54:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a56:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a5a:	5cfd                	li	s9,-1
    80003a5c:	a091                	j	80003aa0 <writei+0x8e>
    80003a5e:	02099d93          	slli	s11,s3,0x20
    80003a62:	020ddd93          	srli	s11,s11,0x20
    80003a66:	05848513          	addi	a0,s1,88
    80003a6a:	86ee                	mv	a3,s11
    80003a6c:	8656                	mv	a2,s5
    80003a6e:	85e2                	mv	a1,s8
    80003a70:	953a                	add	a0,a0,a4
    80003a72:	fffff097          	auipc	ra,0xfffff
    80003a76:	9e2080e7          	jalr	-1566(ra) # 80002454 <either_copyin>
    80003a7a:	07950263          	beq	a0,s9,80003ade <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a7e:	8526                	mv	a0,s1
    80003a80:	00000097          	auipc	ra,0x0
    80003a84:	798080e7          	jalr	1944(ra) # 80004218 <log_write>
    brelse(bp);
    80003a88:	8526                	mv	a0,s1
    80003a8a:	fffff097          	auipc	ra,0xfffff
    80003a8e:	50a080e7          	jalr	1290(ra) # 80002f94 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a92:	01498a3b          	addw	s4,s3,s4
    80003a96:	0129893b          	addw	s2,s3,s2
    80003a9a:	9aee                	add	s5,s5,s11
    80003a9c:	057a7663          	bgeu	s4,s7,80003ae8 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003aa0:	000b2483          	lw	s1,0(s6)
    80003aa4:	00a9559b          	srliw	a1,s2,0xa
    80003aa8:	855a                	mv	a0,s6
    80003aaa:	fffff097          	auipc	ra,0xfffff
    80003aae:	7aa080e7          	jalr	1962(ra) # 80003254 <bmap>
    80003ab2:	0005059b          	sext.w	a1,a0
    80003ab6:	8526                	mv	a0,s1
    80003ab8:	fffff097          	auipc	ra,0xfffff
    80003abc:	3ac080e7          	jalr	940(ra) # 80002e64 <bread>
    80003ac0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ac2:	3ff97713          	andi	a4,s2,1023
    80003ac6:	40ed07bb          	subw	a5,s10,a4
    80003aca:	414b86bb          	subw	a3,s7,s4
    80003ace:	89be                	mv	s3,a5
    80003ad0:	2781                	sext.w	a5,a5
    80003ad2:	0006861b          	sext.w	a2,a3
    80003ad6:	f8f674e3          	bgeu	a2,a5,80003a5e <writei+0x4c>
    80003ada:	89b6                	mv	s3,a3
    80003adc:	b749                	j	80003a5e <writei+0x4c>
      brelse(bp);
    80003ade:	8526                	mv	a0,s1
    80003ae0:	fffff097          	auipc	ra,0xfffff
    80003ae4:	4b4080e7          	jalr	1204(ra) # 80002f94 <brelse>
  }

  if(off > ip->size)
    80003ae8:	04cb2783          	lw	a5,76(s6)
    80003aec:	0127f463          	bgeu	a5,s2,80003af4 <writei+0xe2>
    ip->size = off;
    80003af0:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003af4:	855a                	mv	a0,s6
    80003af6:	00000097          	auipc	ra,0x0
    80003afa:	aa4080e7          	jalr	-1372(ra) # 8000359a <iupdate>

  return tot;
    80003afe:	000a051b          	sext.w	a0,s4
}
    80003b02:	70a6                	ld	ra,104(sp)
    80003b04:	7406                	ld	s0,96(sp)
    80003b06:	64e6                	ld	s1,88(sp)
    80003b08:	6946                	ld	s2,80(sp)
    80003b0a:	69a6                	ld	s3,72(sp)
    80003b0c:	6a06                	ld	s4,64(sp)
    80003b0e:	7ae2                	ld	s5,56(sp)
    80003b10:	7b42                	ld	s6,48(sp)
    80003b12:	7ba2                	ld	s7,40(sp)
    80003b14:	7c02                	ld	s8,32(sp)
    80003b16:	6ce2                	ld	s9,24(sp)
    80003b18:	6d42                	ld	s10,16(sp)
    80003b1a:	6da2                	ld	s11,8(sp)
    80003b1c:	6165                	addi	sp,sp,112
    80003b1e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b20:	8a5e                	mv	s4,s7
    80003b22:	bfc9                	j	80003af4 <writei+0xe2>
    return -1;
    80003b24:	557d                	li	a0,-1
}
    80003b26:	8082                	ret
    return -1;
    80003b28:	557d                	li	a0,-1
    80003b2a:	bfe1                	j	80003b02 <writei+0xf0>
    return -1;
    80003b2c:	557d                	li	a0,-1
    80003b2e:	bfd1                	j	80003b02 <writei+0xf0>

0000000080003b30 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b30:	1141                	addi	sp,sp,-16
    80003b32:	e406                	sd	ra,8(sp)
    80003b34:	e022                	sd	s0,0(sp)
    80003b36:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b38:	4639                	li	a2,14
    80003b3a:	ffffd097          	auipc	ra,0xffffd
    80003b3e:	262080e7          	jalr	610(ra) # 80000d9c <strncmp>
}
    80003b42:	60a2                	ld	ra,8(sp)
    80003b44:	6402                	ld	s0,0(sp)
    80003b46:	0141                	addi	sp,sp,16
    80003b48:	8082                	ret

0000000080003b4a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b4a:	7139                	addi	sp,sp,-64
    80003b4c:	fc06                	sd	ra,56(sp)
    80003b4e:	f822                	sd	s0,48(sp)
    80003b50:	f426                	sd	s1,40(sp)
    80003b52:	f04a                	sd	s2,32(sp)
    80003b54:	ec4e                	sd	s3,24(sp)
    80003b56:	e852                	sd	s4,16(sp)
    80003b58:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b5a:	04451703          	lh	a4,68(a0)
    80003b5e:	4785                	li	a5,1
    80003b60:	00f71a63          	bne	a4,a5,80003b74 <dirlookup+0x2a>
    80003b64:	892a                	mv	s2,a0
    80003b66:	89ae                	mv	s3,a1
    80003b68:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b6a:	457c                	lw	a5,76(a0)
    80003b6c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b6e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b70:	e79d                	bnez	a5,80003b9e <dirlookup+0x54>
    80003b72:	a8a5                	j	80003bea <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b74:	00005517          	auipc	a0,0x5
    80003b78:	a9450513          	addi	a0,a0,-1388 # 80008608 <syscalls+0x1a8>
    80003b7c:	ffffd097          	auipc	ra,0xffffd
    80003b80:	9be080e7          	jalr	-1602(ra) # 8000053a <panic>
      panic("dirlookup read");
    80003b84:	00005517          	auipc	a0,0x5
    80003b88:	a9c50513          	addi	a0,a0,-1380 # 80008620 <syscalls+0x1c0>
    80003b8c:	ffffd097          	auipc	ra,0xffffd
    80003b90:	9ae080e7          	jalr	-1618(ra) # 8000053a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b94:	24c1                	addiw	s1,s1,16
    80003b96:	04c92783          	lw	a5,76(s2)
    80003b9a:	04f4f763          	bgeu	s1,a5,80003be8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b9e:	4741                	li	a4,16
    80003ba0:	86a6                	mv	a3,s1
    80003ba2:	fc040613          	addi	a2,s0,-64
    80003ba6:	4581                	li	a1,0
    80003ba8:	854a                	mv	a0,s2
    80003baa:	00000097          	auipc	ra,0x0
    80003bae:	d70080e7          	jalr	-656(ra) # 8000391a <readi>
    80003bb2:	47c1                	li	a5,16
    80003bb4:	fcf518e3          	bne	a0,a5,80003b84 <dirlookup+0x3a>
    if(de.inum == 0)
    80003bb8:	fc045783          	lhu	a5,-64(s0)
    80003bbc:	dfe1                	beqz	a5,80003b94 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003bbe:	fc240593          	addi	a1,s0,-62
    80003bc2:	854e                	mv	a0,s3
    80003bc4:	00000097          	auipc	ra,0x0
    80003bc8:	f6c080e7          	jalr	-148(ra) # 80003b30 <namecmp>
    80003bcc:	f561                	bnez	a0,80003b94 <dirlookup+0x4a>
      if(poff)
    80003bce:	000a0463          	beqz	s4,80003bd6 <dirlookup+0x8c>
        *poff = off;
    80003bd2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003bd6:	fc045583          	lhu	a1,-64(s0)
    80003bda:	00092503          	lw	a0,0(s2)
    80003bde:	fffff097          	auipc	ra,0xfffff
    80003be2:	752080e7          	jalr	1874(ra) # 80003330 <iget>
    80003be6:	a011                	j	80003bea <dirlookup+0xa0>
  return 0;
    80003be8:	4501                	li	a0,0
}
    80003bea:	70e2                	ld	ra,56(sp)
    80003bec:	7442                	ld	s0,48(sp)
    80003bee:	74a2                	ld	s1,40(sp)
    80003bf0:	7902                	ld	s2,32(sp)
    80003bf2:	69e2                	ld	s3,24(sp)
    80003bf4:	6a42                	ld	s4,16(sp)
    80003bf6:	6121                	addi	sp,sp,64
    80003bf8:	8082                	ret

0000000080003bfa <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003bfa:	711d                	addi	sp,sp,-96
    80003bfc:	ec86                	sd	ra,88(sp)
    80003bfe:	e8a2                	sd	s0,80(sp)
    80003c00:	e4a6                	sd	s1,72(sp)
    80003c02:	e0ca                	sd	s2,64(sp)
    80003c04:	fc4e                	sd	s3,56(sp)
    80003c06:	f852                	sd	s4,48(sp)
    80003c08:	f456                	sd	s5,40(sp)
    80003c0a:	f05a                	sd	s6,32(sp)
    80003c0c:	ec5e                	sd	s7,24(sp)
    80003c0e:	e862                	sd	s8,16(sp)
    80003c10:	e466                	sd	s9,8(sp)
    80003c12:	e06a                	sd	s10,0(sp)
    80003c14:	1080                	addi	s0,sp,96
    80003c16:	84aa                	mv	s1,a0
    80003c18:	8b2e                	mv	s6,a1
    80003c1a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c1c:	00054703          	lbu	a4,0(a0)
    80003c20:	02f00793          	li	a5,47
    80003c24:	02f70363          	beq	a4,a5,80003c4a <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c28:	ffffe097          	auipc	ra,0xffffe
    80003c2c:	d6e080e7          	jalr	-658(ra) # 80001996 <myproc>
    80003c30:	15053503          	ld	a0,336(a0)
    80003c34:	00000097          	auipc	ra,0x0
    80003c38:	9f4080e7          	jalr	-1548(ra) # 80003628 <idup>
    80003c3c:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c3e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c42:	4cb5                	li	s9,13
  len = path - s;
    80003c44:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c46:	4c05                	li	s8,1
    80003c48:	a87d                	j	80003d06 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003c4a:	4585                	li	a1,1
    80003c4c:	4505                	li	a0,1
    80003c4e:	fffff097          	auipc	ra,0xfffff
    80003c52:	6e2080e7          	jalr	1762(ra) # 80003330 <iget>
    80003c56:	8a2a                	mv	s4,a0
    80003c58:	b7dd                	j	80003c3e <namex+0x44>
      iunlockput(ip);
    80003c5a:	8552                	mv	a0,s4
    80003c5c:	00000097          	auipc	ra,0x0
    80003c60:	c6c080e7          	jalr	-916(ra) # 800038c8 <iunlockput>
      return 0;
    80003c64:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c66:	8552                	mv	a0,s4
    80003c68:	60e6                	ld	ra,88(sp)
    80003c6a:	6446                	ld	s0,80(sp)
    80003c6c:	64a6                	ld	s1,72(sp)
    80003c6e:	6906                	ld	s2,64(sp)
    80003c70:	79e2                	ld	s3,56(sp)
    80003c72:	7a42                	ld	s4,48(sp)
    80003c74:	7aa2                	ld	s5,40(sp)
    80003c76:	7b02                	ld	s6,32(sp)
    80003c78:	6be2                	ld	s7,24(sp)
    80003c7a:	6c42                	ld	s8,16(sp)
    80003c7c:	6ca2                	ld	s9,8(sp)
    80003c7e:	6d02                	ld	s10,0(sp)
    80003c80:	6125                	addi	sp,sp,96
    80003c82:	8082                	ret
      iunlock(ip);
    80003c84:	8552                	mv	a0,s4
    80003c86:	00000097          	auipc	ra,0x0
    80003c8a:	aa2080e7          	jalr	-1374(ra) # 80003728 <iunlock>
      return ip;
    80003c8e:	bfe1                	j	80003c66 <namex+0x6c>
      iunlockput(ip);
    80003c90:	8552                	mv	a0,s4
    80003c92:	00000097          	auipc	ra,0x0
    80003c96:	c36080e7          	jalr	-970(ra) # 800038c8 <iunlockput>
      return 0;
    80003c9a:	8a4e                	mv	s4,s3
    80003c9c:	b7e9                	j	80003c66 <namex+0x6c>
  len = path - s;
    80003c9e:	40998633          	sub	a2,s3,s1
    80003ca2:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003ca6:	09acd863          	bge	s9,s10,80003d36 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003caa:	4639                	li	a2,14
    80003cac:	85a6                	mv	a1,s1
    80003cae:	8556                	mv	a0,s5
    80003cb0:	ffffd097          	auipc	ra,0xffffd
    80003cb4:	078080e7          	jalr	120(ra) # 80000d28 <memmove>
    80003cb8:	84ce                	mv	s1,s3
  while(*path == '/')
    80003cba:	0004c783          	lbu	a5,0(s1)
    80003cbe:	01279763          	bne	a5,s2,80003ccc <namex+0xd2>
    path++;
    80003cc2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cc4:	0004c783          	lbu	a5,0(s1)
    80003cc8:	ff278de3          	beq	a5,s2,80003cc2 <namex+0xc8>
    ilock(ip);
    80003ccc:	8552                	mv	a0,s4
    80003cce:	00000097          	auipc	ra,0x0
    80003cd2:	998080e7          	jalr	-1640(ra) # 80003666 <ilock>
    if(ip->type != T_DIR){
    80003cd6:	044a1783          	lh	a5,68(s4)
    80003cda:	f98790e3          	bne	a5,s8,80003c5a <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003cde:	000b0563          	beqz	s6,80003ce8 <namex+0xee>
    80003ce2:	0004c783          	lbu	a5,0(s1)
    80003ce6:	dfd9                	beqz	a5,80003c84 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ce8:	865e                	mv	a2,s7
    80003cea:	85d6                	mv	a1,s5
    80003cec:	8552                	mv	a0,s4
    80003cee:	00000097          	auipc	ra,0x0
    80003cf2:	e5c080e7          	jalr	-420(ra) # 80003b4a <dirlookup>
    80003cf6:	89aa                	mv	s3,a0
    80003cf8:	dd41                	beqz	a0,80003c90 <namex+0x96>
    iunlockput(ip);
    80003cfa:	8552                	mv	a0,s4
    80003cfc:	00000097          	auipc	ra,0x0
    80003d00:	bcc080e7          	jalr	-1076(ra) # 800038c8 <iunlockput>
    ip = next;
    80003d04:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d06:	0004c783          	lbu	a5,0(s1)
    80003d0a:	01279763          	bne	a5,s2,80003d18 <namex+0x11e>
    path++;
    80003d0e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d10:	0004c783          	lbu	a5,0(s1)
    80003d14:	ff278de3          	beq	a5,s2,80003d0e <namex+0x114>
  if(*path == 0)
    80003d18:	cb9d                	beqz	a5,80003d4e <namex+0x154>
  while(*path != '/' && *path != 0)
    80003d1a:	0004c783          	lbu	a5,0(s1)
    80003d1e:	89a6                	mv	s3,s1
  len = path - s;
    80003d20:	8d5e                	mv	s10,s7
    80003d22:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003d24:	01278963          	beq	a5,s2,80003d36 <namex+0x13c>
    80003d28:	dbbd                	beqz	a5,80003c9e <namex+0xa4>
    path++;
    80003d2a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003d2c:	0009c783          	lbu	a5,0(s3)
    80003d30:	ff279ce3          	bne	a5,s2,80003d28 <namex+0x12e>
    80003d34:	b7ad                	j	80003c9e <namex+0xa4>
    memmove(name, s, len);
    80003d36:	2601                	sext.w	a2,a2
    80003d38:	85a6                	mv	a1,s1
    80003d3a:	8556                	mv	a0,s5
    80003d3c:	ffffd097          	auipc	ra,0xffffd
    80003d40:	fec080e7          	jalr	-20(ra) # 80000d28 <memmove>
    name[len] = 0;
    80003d44:	9d56                	add	s10,s10,s5
    80003d46:	000d0023          	sb	zero,0(s10)
    80003d4a:	84ce                	mv	s1,s3
    80003d4c:	b7bd                	j	80003cba <namex+0xc0>
  if(nameiparent){
    80003d4e:	f00b0ce3          	beqz	s6,80003c66 <namex+0x6c>
    iput(ip);
    80003d52:	8552                	mv	a0,s4
    80003d54:	00000097          	auipc	ra,0x0
    80003d58:	acc080e7          	jalr	-1332(ra) # 80003820 <iput>
    return 0;
    80003d5c:	4a01                	li	s4,0
    80003d5e:	b721                	j	80003c66 <namex+0x6c>

0000000080003d60 <dirlink>:
{
    80003d60:	7139                	addi	sp,sp,-64
    80003d62:	fc06                	sd	ra,56(sp)
    80003d64:	f822                	sd	s0,48(sp)
    80003d66:	f426                	sd	s1,40(sp)
    80003d68:	f04a                	sd	s2,32(sp)
    80003d6a:	ec4e                	sd	s3,24(sp)
    80003d6c:	e852                	sd	s4,16(sp)
    80003d6e:	0080                	addi	s0,sp,64
    80003d70:	892a                	mv	s2,a0
    80003d72:	8a2e                	mv	s4,a1
    80003d74:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d76:	4601                	li	a2,0
    80003d78:	00000097          	auipc	ra,0x0
    80003d7c:	dd2080e7          	jalr	-558(ra) # 80003b4a <dirlookup>
    80003d80:	e93d                	bnez	a0,80003df6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d82:	04c92483          	lw	s1,76(s2)
    80003d86:	c49d                	beqz	s1,80003db4 <dirlink+0x54>
    80003d88:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d8a:	4741                	li	a4,16
    80003d8c:	86a6                	mv	a3,s1
    80003d8e:	fc040613          	addi	a2,s0,-64
    80003d92:	4581                	li	a1,0
    80003d94:	854a                	mv	a0,s2
    80003d96:	00000097          	auipc	ra,0x0
    80003d9a:	b84080e7          	jalr	-1148(ra) # 8000391a <readi>
    80003d9e:	47c1                	li	a5,16
    80003da0:	06f51163          	bne	a0,a5,80003e02 <dirlink+0xa2>
    if(de.inum == 0)
    80003da4:	fc045783          	lhu	a5,-64(s0)
    80003da8:	c791                	beqz	a5,80003db4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003daa:	24c1                	addiw	s1,s1,16
    80003dac:	04c92783          	lw	a5,76(s2)
    80003db0:	fcf4ede3          	bltu	s1,a5,80003d8a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003db4:	4639                	li	a2,14
    80003db6:	85d2                	mv	a1,s4
    80003db8:	fc240513          	addi	a0,s0,-62
    80003dbc:	ffffd097          	auipc	ra,0xffffd
    80003dc0:	01c080e7          	jalr	28(ra) # 80000dd8 <strncpy>
  de.inum = inum;
    80003dc4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dc8:	4741                	li	a4,16
    80003dca:	86a6                	mv	a3,s1
    80003dcc:	fc040613          	addi	a2,s0,-64
    80003dd0:	4581                	li	a1,0
    80003dd2:	854a                	mv	a0,s2
    80003dd4:	00000097          	auipc	ra,0x0
    80003dd8:	c3e080e7          	jalr	-962(ra) # 80003a12 <writei>
    80003ddc:	872a                	mv	a4,a0
    80003dde:	47c1                	li	a5,16
  return 0;
    80003de0:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003de2:	02f71863          	bne	a4,a5,80003e12 <dirlink+0xb2>
}
    80003de6:	70e2                	ld	ra,56(sp)
    80003de8:	7442                	ld	s0,48(sp)
    80003dea:	74a2                	ld	s1,40(sp)
    80003dec:	7902                	ld	s2,32(sp)
    80003dee:	69e2                	ld	s3,24(sp)
    80003df0:	6a42                	ld	s4,16(sp)
    80003df2:	6121                	addi	sp,sp,64
    80003df4:	8082                	ret
    iput(ip);
    80003df6:	00000097          	auipc	ra,0x0
    80003dfa:	a2a080e7          	jalr	-1494(ra) # 80003820 <iput>
    return -1;
    80003dfe:	557d                	li	a0,-1
    80003e00:	b7dd                	j	80003de6 <dirlink+0x86>
      panic("dirlink read");
    80003e02:	00005517          	auipc	a0,0x5
    80003e06:	82e50513          	addi	a0,a0,-2002 # 80008630 <syscalls+0x1d0>
    80003e0a:	ffffc097          	auipc	ra,0xffffc
    80003e0e:	730080e7          	jalr	1840(ra) # 8000053a <panic>
    panic("dirlink");
    80003e12:	00005517          	auipc	a0,0x5
    80003e16:	92e50513          	addi	a0,a0,-1746 # 80008740 <syscalls+0x2e0>
    80003e1a:	ffffc097          	auipc	ra,0xffffc
    80003e1e:	720080e7          	jalr	1824(ra) # 8000053a <panic>

0000000080003e22 <namei>:

struct inode*
namei(char *path)
{
    80003e22:	1101                	addi	sp,sp,-32
    80003e24:	ec06                	sd	ra,24(sp)
    80003e26:	e822                	sd	s0,16(sp)
    80003e28:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e2a:	fe040613          	addi	a2,s0,-32
    80003e2e:	4581                	li	a1,0
    80003e30:	00000097          	auipc	ra,0x0
    80003e34:	dca080e7          	jalr	-566(ra) # 80003bfa <namex>
}
    80003e38:	60e2                	ld	ra,24(sp)
    80003e3a:	6442                	ld	s0,16(sp)
    80003e3c:	6105                	addi	sp,sp,32
    80003e3e:	8082                	ret

0000000080003e40 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e40:	1141                	addi	sp,sp,-16
    80003e42:	e406                	sd	ra,8(sp)
    80003e44:	e022                	sd	s0,0(sp)
    80003e46:	0800                	addi	s0,sp,16
    80003e48:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e4a:	4585                	li	a1,1
    80003e4c:	00000097          	auipc	ra,0x0
    80003e50:	dae080e7          	jalr	-594(ra) # 80003bfa <namex>
}
    80003e54:	60a2                	ld	ra,8(sp)
    80003e56:	6402                	ld	s0,0(sp)
    80003e58:	0141                	addi	sp,sp,16
    80003e5a:	8082                	ret

0000000080003e5c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e5c:	1101                	addi	sp,sp,-32
    80003e5e:	ec06                	sd	ra,24(sp)
    80003e60:	e822                	sd	s0,16(sp)
    80003e62:	e426                	sd	s1,8(sp)
    80003e64:	e04a                	sd	s2,0(sp)
    80003e66:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e68:	0001d917          	auipc	s2,0x1d
    80003e6c:	40890913          	addi	s2,s2,1032 # 80021270 <log>
    80003e70:	01892583          	lw	a1,24(s2)
    80003e74:	02892503          	lw	a0,40(s2)
    80003e78:	fffff097          	auipc	ra,0xfffff
    80003e7c:	fec080e7          	jalr	-20(ra) # 80002e64 <bread>
    80003e80:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e82:	02c92683          	lw	a3,44(s2)
    80003e86:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e88:	02d05863          	blez	a3,80003eb8 <write_head+0x5c>
    80003e8c:	0001d797          	auipc	a5,0x1d
    80003e90:	41478793          	addi	a5,a5,1044 # 800212a0 <log+0x30>
    80003e94:	05c50713          	addi	a4,a0,92
    80003e98:	36fd                	addiw	a3,a3,-1
    80003e9a:	02069613          	slli	a2,a3,0x20
    80003e9e:	01e65693          	srli	a3,a2,0x1e
    80003ea2:	0001d617          	auipc	a2,0x1d
    80003ea6:	40260613          	addi	a2,a2,1026 # 800212a4 <log+0x34>
    80003eaa:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003eac:	4390                	lw	a2,0(a5)
    80003eae:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003eb0:	0791                	addi	a5,a5,4
    80003eb2:	0711                	addi	a4,a4,4
    80003eb4:	fed79ce3          	bne	a5,a3,80003eac <write_head+0x50>
  }
  bwrite(buf);
    80003eb8:	8526                	mv	a0,s1
    80003eba:	fffff097          	auipc	ra,0xfffff
    80003ebe:	09c080e7          	jalr	156(ra) # 80002f56 <bwrite>
  brelse(buf);
    80003ec2:	8526                	mv	a0,s1
    80003ec4:	fffff097          	auipc	ra,0xfffff
    80003ec8:	0d0080e7          	jalr	208(ra) # 80002f94 <brelse>
}
    80003ecc:	60e2                	ld	ra,24(sp)
    80003ece:	6442                	ld	s0,16(sp)
    80003ed0:	64a2                	ld	s1,8(sp)
    80003ed2:	6902                	ld	s2,0(sp)
    80003ed4:	6105                	addi	sp,sp,32
    80003ed6:	8082                	ret

0000000080003ed8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ed8:	0001d797          	auipc	a5,0x1d
    80003edc:	3c47a783          	lw	a5,964(a5) # 8002129c <log+0x2c>
    80003ee0:	0af05d63          	blez	a5,80003f9a <install_trans+0xc2>
{
    80003ee4:	7139                	addi	sp,sp,-64
    80003ee6:	fc06                	sd	ra,56(sp)
    80003ee8:	f822                	sd	s0,48(sp)
    80003eea:	f426                	sd	s1,40(sp)
    80003eec:	f04a                	sd	s2,32(sp)
    80003eee:	ec4e                	sd	s3,24(sp)
    80003ef0:	e852                	sd	s4,16(sp)
    80003ef2:	e456                	sd	s5,8(sp)
    80003ef4:	e05a                	sd	s6,0(sp)
    80003ef6:	0080                	addi	s0,sp,64
    80003ef8:	8b2a                	mv	s6,a0
    80003efa:	0001da97          	auipc	s5,0x1d
    80003efe:	3a6a8a93          	addi	s5,s5,934 # 800212a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f02:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f04:	0001d997          	auipc	s3,0x1d
    80003f08:	36c98993          	addi	s3,s3,876 # 80021270 <log>
    80003f0c:	a00d                	j	80003f2e <install_trans+0x56>
    brelse(lbuf);
    80003f0e:	854a                	mv	a0,s2
    80003f10:	fffff097          	auipc	ra,0xfffff
    80003f14:	084080e7          	jalr	132(ra) # 80002f94 <brelse>
    brelse(dbuf);
    80003f18:	8526                	mv	a0,s1
    80003f1a:	fffff097          	auipc	ra,0xfffff
    80003f1e:	07a080e7          	jalr	122(ra) # 80002f94 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f22:	2a05                	addiw	s4,s4,1
    80003f24:	0a91                	addi	s5,s5,4
    80003f26:	02c9a783          	lw	a5,44(s3)
    80003f2a:	04fa5e63          	bge	s4,a5,80003f86 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f2e:	0189a583          	lw	a1,24(s3)
    80003f32:	014585bb          	addw	a1,a1,s4
    80003f36:	2585                	addiw	a1,a1,1
    80003f38:	0289a503          	lw	a0,40(s3)
    80003f3c:	fffff097          	auipc	ra,0xfffff
    80003f40:	f28080e7          	jalr	-216(ra) # 80002e64 <bread>
    80003f44:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f46:	000aa583          	lw	a1,0(s5)
    80003f4a:	0289a503          	lw	a0,40(s3)
    80003f4e:	fffff097          	auipc	ra,0xfffff
    80003f52:	f16080e7          	jalr	-234(ra) # 80002e64 <bread>
    80003f56:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f58:	40000613          	li	a2,1024
    80003f5c:	05890593          	addi	a1,s2,88
    80003f60:	05850513          	addi	a0,a0,88
    80003f64:	ffffd097          	auipc	ra,0xffffd
    80003f68:	dc4080e7          	jalr	-572(ra) # 80000d28 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f6c:	8526                	mv	a0,s1
    80003f6e:	fffff097          	auipc	ra,0xfffff
    80003f72:	fe8080e7          	jalr	-24(ra) # 80002f56 <bwrite>
    if(recovering == 0)
    80003f76:	f80b1ce3          	bnez	s6,80003f0e <install_trans+0x36>
      bunpin(dbuf);
    80003f7a:	8526                	mv	a0,s1
    80003f7c:	fffff097          	auipc	ra,0xfffff
    80003f80:	0f2080e7          	jalr	242(ra) # 8000306e <bunpin>
    80003f84:	b769                	j	80003f0e <install_trans+0x36>
}
    80003f86:	70e2                	ld	ra,56(sp)
    80003f88:	7442                	ld	s0,48(sp)
    80003f8a:	74a2                	ld	s1,40(sp)
    80003f8c:	7902                	ld	s2,32(sp)
    80003f8e:	69e2                	ld	s3,24(sp)
    80003f90:	6a42                	ld	s4,16(sp)
    80003f92:	6aa2                	ld	s5,8(sp)
    80003f94:	6b02                	ld	s6,0(sp)
    80003f96:	6121                	addi	sp,sp,64
    80003f98:	8082                	ret
    80003f9a:	8082                	ret

0000000080003f9c <initlog>:
{
    80003f9c:	7179                	addi	sp,sp,-48
    80003f9e:	f406                	sd	ra,40(sp)
    80003fa0:	f022                	sd	s0,32(sp)
    80003fa2:	ec26                	sd	s1,24(sp)
    80003fa4:	e84a                	sd	s2,16(sp)
    80003fa6:	e44e                	sd	s3,8(sp)
    80003fa8:	1800                	addi	s0,sp,48
    80003faa:	892a                	mv	s2,a0
    80003fac:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fae:	0001d497          	auipc	s1,0x1d
    80003fb2:	2c248493          	addi	s1,s1,706 # 80021270 <log>
    80003fb6:	00004597          	auipc	a1,0x4
    80003fba:	68a58593          	addi	a1,a1,1674 # 80008640 <syscalls+0x1e0>
    80003fbe:	8526                	mv	a0,s1
    80003fc0:	ffffd097          	auipc	ra,0xffffd
    80003fc4:	b80080e7          	jalr	-1152(ra) # 80000b40 <initlock>
  log.start = sb->logstart;
    80003fc8:	0149a583          	lw	a1,20(s3)
    80003fcc:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003fce:	0109a783          	lw	a5,16(s3)
    80003fd2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003fd4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003fd8:	854a                	mv	a0,s2
    80003fda:	fffff097          	auipc	ra,0xfffff
    80003fde:	e8a080e7          	jalr	-374(ra) # 80002e64 <bread>
  log.lh.n = lh->n;
    80003fe2:	4d34                	lw	a3,88(a0)
    80003fe4:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003fe6:	02d05663          	blez	a3,80004012 <initlog+0x76>
    80003fea:	05c50793          	addi	a5,a0,92
    80003fee:	0001d717          	auipc	a4,0x1d
    80003ff2:	2b270713          	addi	a4,a4,690 # 800212a0 <log+0x30>
    80003ff6:	36fd                	addiw	a3,a3,-1
    80003ff8:	02069613          	slli	a2,a3,0x20
    80003ffc:	01e65693          	srli	a3,a2,0x1e
    80004000:	06050613          	addi	a2,a0,96
    80004004:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004006:	4390                	lw	a2,0(a5)
    80004008:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000400a:	0791                	addi	a5,a5,4
    8000400c:	0711                	addi	a4,a4,4
    8000400e:	fed79ce3          	bne	a5,a3,80004006 <initlog+0x6a>
  brelse(buf);
    80004012:	fffff097          	auipc	ra,0xfffff
    80004016:	f82080e7          	jalr	-126(ra) # 80002f94 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000401a:	4505                	li	a0,1
    8000401c:	00000097          	auipc	ra,0x0
    80004020:	ebc080e7          	jalr	-324(ra) # 80003ed8 <install_trans>
  log.lh.n = 0;
    80004024:	0001d797          	auipc	a5,0x1d
    80004028:	2607ac23          	sw	zero,632(a5) # 8002129c <log+0x2c>
  write_head(); // clear the log
    8000402c:	00000097          	auipc	ra,0x0
    80004030:	e30080e7          	jalr	-464(ra) # 80003e5c <write_head>
}
    80004034:	70a2                	ld	ra,40(sp)
    80004036:	7402                	ld	s0,32(sp)
    80004038:	64e2                	ld	s1,24(sp)
    8000403a:	6942                	ld	s2,16(sp)
    8000403c:	69a2                	ld	s3,8(sp)
    8000403e:	6145                	addi	sp,sp,48
    80004040:	8082                	ret

0000000080004042 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004042:	1101                	addi	sp,sp,-32
    80004044:	ec06                	sd	ra,24(sp)
    80004046:	e822                	sd	s0,16(sp)
    80004048:	e426                	sd	s1,8(sp)
    8000404a:	e04a                	sd	s2,0(sp)
    8000404c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000404e:	0001d517          	auipc	a0,0x1d
    80004052:	22250513          	addi	a0,a0,546 # 80021270 <log>
    80004056:	ffffd097          	auipc	ra,0xffffd
    8000405a:	b7a080e7          	jalr	-1158(ra) # 80000bd0 <acquire>
  while(1){
    if(log.committing){
    8000405e:	0001d497          	auipc	s1,0x1d
    80004062:	21248493          	addi	s1,s1,530 # 80021270 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004066:	4979                	li	s2,30
    80004068:	a039                	j	80004076 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000406a:	85a6                	mv	a1,s1
    8000406c:	8526                	mv	a0,s1
    8000406e:	ffffe097          	auipc	ra,0xffffe
    80004072:	fec080e7          	jalr	-20(ra) # 8000205a <sleep>
    if(log.committing){
    80004076:	50dc                	lw	a5,36(s1)
    80004078:	fbed                	bnez	a5,8000406a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000407a:	5098                	lw	a4,32(s1)
    8000407c:	2705                	addiw	a4,a4,1
    8000407e:	0007069b          	sext.w	a3,a4
    80004082:	0027179b          	slliw	a5,a4,0x2
    80004086:	9fb9                	addw	a5,a5,a4
    80004088:	0017979b          	slliw	a5,a5,0x1
    8000408c:	54d8                	lw	a4,44(s1)
    8000408e:	9fb9                	addw	a5,a5,a4
    80004090:	00f95963          	bge	s2,a5,800040a2 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004094:	85a6                	mv	a1,s1
    80004096:	8526                	mv	a0,s1
    80004098:	ffffe097          	auipc	ra,0xffffe
    8000409c:	fc2080e7          	jalr	-62(ra) # 8000205a <sleep>
    800040a0:	bfd9                	j	80004076 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800040a2:	0001d517          	auipc	a0,0x1d
    800040a6:	1ce50513          	addi	a0,a0,462 # 80021270 <log>
    800040aa:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800040ac:	ffffd097          	auipc	ra,0xffffd
    800040b0:	bd8080e7          	jalr	-1064(ra) # 80000c84 <release>
      break;
    }
  }
}
    800040b4:	60e2                	ld	ra,24(sp)
    800040b6:	6442                	ld	s0,16(sp)
    800040b8:	64a2                	ld	s1,8(sp)
    800040ba:	6902                	ld	s2,0(sp)
    800040bc:	6105                	addi	sp,sp,32
    800040be:	8082                	ret

00000000800040c0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040c0:	7139                	addi	sp,sp,-64
    800040c2:	fc06                	sd	ra,56(sp)
    800040c4:	f822                	sd	s0,48(sp)
    800040c6:	f426                	sd	s1,40(sp)
    800040c8:	f04a                	sd	s2,32(sp)
    800040ca:	ec4e                	sd	s3,24(sp)
    800040cc:	e852                	sd	s4,16(sp)
    800040ce:	e456                	sd	s5,8(sp)
    800040d0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040d2:	0001d497          	auipc	s1,0x1d
    800040d6:	19e48493          	addi	s1,s1,414 # 80021270 <log>
    800040da:	8526                	mv	a0,s1
    800040dc:	ffffd097          	auipc	ra,0xffffd
    800040e0:	af4080e7          	jalr	-1292(ra) # 80000bd0 <acquire>
  log.outstanding -= 1;
    800040e4:	509c                	lw	a5,32(s1)
    800040e6:	37fd                	addiw	a5,a5,-1
    800040e8:	0007891b          	sext.w	s2,a5
    800040ec:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800040ee:	50dc                	lw	a5,36(s1)
    800040f0:	e7b9                	bnez	a5,8000413e <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800040f2:	04091e63          	bnez	s2,8000414e <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800040f6:	0001d497          	auipc	s1,0x1d
    800040fa:	17a48493          	addi	s1,s1,378 # 80021270 <log>
    800040fe:	4785                	li	a5,1
    80004100:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004102:	8526                	mv	a0,s1
    80004104:	ffffd097          	auipc	ra,0xffffd
    80004108:	b80080e7          	jalr	-1152(ra) # 80000c84 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000410c:	54dc                	lw	a5,44(s1)
    8000410e:	06f04763          	bgtz	a5,8000417c <end_op+0xbc>
    acquire(&log.lock);
    80004112:	0001d497          	auipc	s1,0x1d
    80004116:	15e48493          	addi	s1,s1,350 # 80021270 <log>
    8000411a:	8526                	mv	a0,s1
    8000411c:	ffffd097          	auipc	ra,0xffffd
    80004120:	ab4080e7          	jalr	-1356(ra) # 80000bd0 <acquire>
    log.committing = 0;
    80004124:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004128:	8526                	mv	a0,s1
    8000412a:	ffffe097          	auipc	ra,0xffffe
    8000412e:	0bc080e7          	jalr	188(ra) # 800021e6 <wakeup>
    release(&log.lock);
    80004132:	8526                	mv	a0,s1
    80004134:	ffffd097          	auipc	ra,0xffffd
    80004138:	b50080e7          	jalr	-1200(ra) # 80000c84 <release>
}
    8000413c:	a03d                	j	8000416a <end_op+0xaa>
    panic("log.committing");
    8000413e:	00004517          	auipc	a0,0x4
    80004142:	50a50513          	addi	a0,a0,1290 # 80008648 <syscalls+0x1e8>
    80004146:	ffffc097          	auipc	ra,0xffffc
    8000414a:	3f4080e7          	jalr	1012(ra) # 8000053a <panic>
    wakeup(&log);
    8000414e:	0001d497          	auipc	s1,0x1d
    80004152:	12248493          	addi	s1,s1,290 # 80021270 <log>
    80004156:	8526                	mv	a0,s1
    80004158:	ffffe097          	auipc	ra,0xffffe
    8000415c:	08e080e7          	jalr	142(ra) # 800021e6 <wakeup>
  release(&log.lock);
    80004160:	8526                	mv	a0,s1
    80004162:	ffffd097          	auipc	ra,0xffffd
    80004166:	b22080e7          	jalr	-1246(ra) # 80000c84 <release>
}
    8000416a:	70e2                	ld	ra,56(sp)
    8000416c:	7442                	ld	s0,48(sp)
    8000416e:	74a2                	ld	s1,40(sp)
    80004170:	7902                	ld	s2,32(sp)
    80004172:	69e2                	ld	s3,24(sp)
    80004174:	6a42                	ld	s4,16(sp)
    80004176:	6aa2                	ld	s5,8(sp)
    80004178:	6121                	addi	sp,sp,64
    8000417a:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000417c:	0001da97          	auipc	s5,0x1d
    80004180:	124a8a93          	addi	s5,s5,292 # 800212a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004184:	0001da17          	auipc	s4,0x1d
    80004188:	0eca0a13          	addi	s4,s4,236 # 80021270 <log>
    8000418c:	018a2583          	lw	a1,24(s4)
    80004190:	012585bb          	addw	a1,a1,s2
    80004194:	2585                	addiw	a1,a1,1
    80004196:	028a2503          	lw	a0,40(s4)
    8000419a:	fffff097          	auipc	ra,0xfffff
    8000419e:	cca080e7          	jalr	-822(ra) # 80002e64 <bread>
    800041a2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800041a4:	000aa583          	lw	a1,0(s5)
    800041a8:	028a2503          	lw	a0,40(s4)
    800041ac:	fffff097          	auipc	ra,0xfffff
    800041b0:	cb8080e7          	jalr	-840(ra) # 80002e64 <bread>
    800041b4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800041b6:	40000613          	li	a2,1024
    800041ba:	05850593          	addi	a1,a0,88
    800041be:	05848513          	addi	a0,s1,88
    800041c2:	ffffd097          	auipc	ra,0xffffd
    800041c6:	b66080e7          	jalr	-1178(ra) # 80000d28 <memmove>
    bwrite(to);  // write the log
    800041ca:	8526                	mv	a0,s1
    800041cc:	fffff097          	auipc	ra,0xfffff
    800041d0:	d8a080e7          	jalr	-630(ra) # 80002f56 <bwrite>
    brelse(from);
    800041d4:	854e                	mv	a0,s3
    800041d6:	fffff097          	auipc	ra,0xfffff
    800041da:	dbe080e7          	jalr	-578(ra) # 80002f94 <brelse>
    brelse(to);
    800041de:	8526                	mv	a0,s1
    800041e0:	fffff097          	auipc	ra,0xfffff
    800041e4:	db4080e7          	jalr	-588(ra) # 80002f94 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041e8:	2905                	addiw	s2,s2,1
    800041ea:	0a91                	addi	s5,s5,4
    800041ec:	02ca2783          	lw	a5,44(s4)
    800041f0:	f8f94ee3          	blt	s2,a5,8000418c <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800041f4:	00000097          	auipc	ra,0x0
    800041f8:	c68080e7          	jalr	-920(ra) # 80003e5c <write_head>
    install_trans(0); // Now install writes to home locations
    800041fc:	4501                	li	a0,0
    800041fe:	00000097          	auipc	ra,0x0
    80004202:	cda080e7          	jalr	-806(ra) # 80003ed8 <install_trans>
    log.lh.n = 0;
    80004206:	0001d797          	auipc	a5,0x1d
    8000420a:	0807ab23          	sw	zero,150(a5) # 8002129c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000420e:	00000097          	auipc	ra,0x0
    80004212:	c4e080e7          	jalr	-946(ra) # 80003e5c <write_head>
    80004216:	bdf5                	j	80004112 <end_op+0x52>

0000000080004218 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004218:	1101                	addi	sp,sp,-32
    8000421a:	ec06                	sd	ra,24(sp)
    8000421c:	e822                	sd	s0,16(sp)
    8000421e:	e426                	sd	s1,8(sp)
    80004220:	e04a                	sd	s2,0(sp)
    80004222:	1000                	addi	s0,sp,32
    80004224:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004226:	0001d917          	auipc	s2,0x1d
    8000422a:	04a90913          	addi	s2,s2,74 # 80021270 <log>
    8000422e:	854a                	mv	a0,s2
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	9a0080e7          	jalr	-1632(ra) # 80000bd0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004238:	02c92603          	lw	a2,44(s2)
    8000423c:	47f5                	li	a5,29
    8000423e:	06c7c563          	blt	a5,a2,800042a8 <log_write+0x90>
    80004242:	0001d797          	auipc	a5,0x1d
    80004246:	04a7a783          	lw	a5,74(a5) # 8002128c <log+0x1c>
    8000424a:	37fd                	addiw	a5,a5,-1
    8000424c:	04f65e63          	bge	a2,a5,800042a8 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004250:	0001d797          	auipc	a5,0x1d
    80004254:	0407a783          	lw	a5,64(a5) # 80021290 <log+0x20>
    80004258:	06f05063          	blez	a5,800042b8 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000425c:	4781                	li	a5,0
    8000425e:	06c05563          	blez	a2,800042c8 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004262:	44cc                	lw	a1,12(s1)
    80004264:	0001d717          	auipc	a4,0x1d
    80004268:	03c70713          	addi	a4,a4,60 # 800212a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000426c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000426e:	4314                	lw	a3,0(a4)
    80004270:	04b68c63          	beq	a3,a1,800042c8 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004274:	2785                	addiw	a5,a5,1
    80004276:	0711                	addi	a4,a4,4
    80004278:	fef61be3          	bne	a2,a5,8000426e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000427c:	0621                	addi	a2,a2,8
    8000427e:	060a                	slli	a2,a2,0x2
    80004280:	0001d797          	auipc	a5,0x1d
    80004284:	ff078793          	addi	a5,a5,-16 # 80021270 <log>
    80004288:	97b2                	add	a5,a5,a2
    8000428a:	44d8                	lw	a4,12(s1)
    8000428c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000428e:	8526                	mv	a0,s1
    80004290:	fffff097          	auipc	ra,0xfffff
    80004294:	da2080e7          	jalr	-606(ra) # 80003032 <bpin>
    log.lh.n++;
    80004298:	0001d717          	auipc	a4,0x1d
    8000429c:	fd870713          	addi	a4,a4,-40 # 80021270 <log>
    800042a0:	575c                	lw	a5,44(a4)
    800042a2:	2785                	addiw	a5,a5,1
    800042a4:	d75c                	sw	a5,44(a4)
    800042a6:	a82d                	j	800042e0 <log_write+0xc8>
    panic("too big a transaction");
    800042a8:	00004517          	auipc	a0,0x4
    800042ac:	3b050513          	addi	a0,a0,944 # 80008658 <syscalls+0x1f8>
    800042b0:	ffffc097          	auipc	ra,0xffffc
    800042b4:	28a080e7          	jalr	650(ra) # 8000053a <panic>
    panic("log_write outside of trans");
    800042b8:	00004517          	auipc	a0,0x4
    800042bc:	3b850513          	addi	a0,a0,952 # 80008670 <syscalls+0x210>
    800042c0:	ffffc097          	auipc	ra,0xffffc
    800042c4:	27a080e7          	jalr	634(ra) # 8000053a <panic>
  log.lh.block[i] = b->blockno;
    800042c8:	00878693          	addi	a3,a5,8
    800042cc:	068a                	slli	a3,a3,0x2
    800042ce:	0001d717          	auipc	a4,0x1d
    800042d2:	fa270713          	addi	a4,a4,-94 # 80021270 <log>
    800042d6:	9736                	add	a4,a4,a3
    800042d8:	44d4                	lw	a3,12(s1)
    800042da:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800042dc:	faf609e3          	beq	a2,a5,8000428e <log_write+0x76>
  }
  release(&log.lock);
    800042e0:	0001d517          	auipc	a0,0x1d
    800042e4:	f9050513          	addi	a0,a0,-112 # 80021270 <log>
    800042e8:	ffffd097          	auipc	ra,0xffffd
    800042ec:	99c080e7          	jalr	-1636(ra) # 80000c84 <release>
}
    800042f0:	60e2                	ld	ra,24(sp)
    800042f2:	6442                	ld	s0,16(sp)
    800042f4:	64a2                	ld	s1,8(sp)
    800042f6:	6902                	ld	s2,0(sp)
    800042f8:	6105                	addi	sp,sp,32
    800042fa:	8082                	ret

00000000800042fc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800042fc:	1101                	addi	sp,sp,-32
    800042fe:	ec06                	sd	ra,24(sp)
    80004300:	e822                	sd	s0,16(sp)
    80004302:	e426                	sd	s1,8(sp)
    80004304:	e04a                	sd	s2,0(sp)
    80004306:	1000                	addi	s0,sp,32
    80004308:	84aa                	mv	s1,a0
    8000430a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000430c:	00004597          	auipc	a1,0x4
    80004310:	38458593          	addi	a1,a1,900 # 80008690 <syscalls+0x230>
    80004314:	0521                	addi	a0,a0,8
    80004316:	ffffd097          	auipc	ra,0xffffd
    8000431a:	82a080e7          	jalr	-2006(ra) # 80000b40 <initlock>
  lk->name = name;
    8000431e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004322:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004326:	0204a423          	sw	zero,40(s1)
}
    8000432a:	60e2                	ld	ra,24(sp)
    8000432c:	6442                	ld	s0,16(sp)
    8000432e:	64a2                	ld	s1,8(sp)
    80004330:	6902                	ld	s2,0(sp)
    80004332:	6105                	addi	sp,sp,32
    80004334:	8082                	ret

0000000080004336 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004336:	1101                	addi	sp,sp,-32
    80004338:	ec06                	sd	ra,24(sp)
    8000433a:	e822                	sd	s0,16(sp)
    8000433c:	e426                	sd	s1,8(sp)
    8000433e:	e04a                	sd	s2,0(sp)
    80004340:	1000                	addi	s0,sp,32
    80004342:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004344:	00850913          	addi	s2,a0,8
    80004348:	854a                	mv	a0,s2
    8000434a:	ffffd097          	auipc	ra,0xffffd
    8000434e:	886080e7          	jalr	-1914(ra) # 80000bd0 <acquire>
  while (lk->locked) {
    80004352:	409c                	lw	a5,0(s1)
    80004354:	cb89                	beqz	a5,80004366 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004356:	85ca                	mv	a1,s2
    80004358:	8526                	mv	a0,s1
    8000435a:	ffffe097          	auipc	ra,0xffffe
    8000435e:	d00080e7          	jalr	-768(ra) # 8000205a <sleep>
  while (lk->locked) {
    80004362:	409c                	lw	a5,0(s1)
    80004364:	fbed                	bnez	a5,80004356 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004366:	4785                	li	a5,1
    80004368:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000436a:	ffffd097          	auipc	ra,0xffffd
    8000436e:	62c080e7          	jalr	1580(ra) # 80001996 <myproc>
    80004372:	591c                	lw	a5,48(a0)
    80004374:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004376:	854a                	mv	a0,s2
    80004378:	ffffd097          	auipc	ra,0xffffd
    8000437c:	90c080e7          	jalr	-1780(ra) # 80000c84 <release>
}
    80004380:	60e2                	ld	ra,24(sp)
    80004382:	6442                	ld	s0,16(sp)
    80004384:	64a2                	ld	s1,8(sp)
    80004386:	6902                	ld	s2,0(sp)
    80004388:	6105                	addi	sp,sp,32
    8000438a:	8082                	ret

000000008000438c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000438c:	1101                	addi	sp,sp,-32
    8000438e:	ec06                	sd	ra,24(sp)
    80004390:	e822                	sd	s0,16(sp)
    80004392:	e426                	sd	s1,8(sp)
    80004394:	e04a                	sd	s2,0(sp)
    80004396:	1000                	addi	s0,sp,32
    80004398:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000439a:	00850913          	addi	s2,a0,8
    8000439e:	854a                	mv	a0,s2
    800043a0:	ffffd097          	auipc	ra,0xffffd
    800043a4:	830080e7          	jalr	-2000(ra) # 80000bd0 <acquire>
  lk->locked = 0;
    800043a8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043ac:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800043b0:	8526                	mv	a0,s1
    800043b2:	ffffe097          	auipc	ra,0xffffe
    800043b6:	e34080e7          	jalr	-460(ra) # 800021e6 <wakeup>
  release(&lk->lk);
    800043ba:	854a                	mv	a0,s2
    800043bc:	ffffd097          	auipc	ra,0xffffd
    800043c0:	8c8080e7          	jalr	-1848(ra) # 80000c84 <release>
}
    800043c4:	60e2                	ld	ra,24(sp)
    800043c6:	6442                	ld	s0,16(sp)
    800043c8:	64a2                	ld	s1,8(sp)
    800043ca:	6902                	ld	s2,0(sp)
    800043cc:	6105                	addi	sp,sp,32
    800043ce:	8082                	ret

00000000800043d0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043d0:	7179                	addi	sp,sp,-48
    800043d2:	f406                	sd	ra,40(sp)
    800043d4:	f022                	sd	s0,32(sp)
    800043d6:	ec26                	sd	s1,24(sp)
    800043d8:	e84a                	sd	s2,16(sp)
    800043da:	e44e                	sd	s3,8(sp)
    800043dc:	1800                	addi	s0,sp,48
    800043de:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800043e0:	00850913          	addi	s2,a0,8
    800043e4:	854a                	mv	a0,s2
    800043e6:	ffffc097          	auipc	ra,0xffffc
    800043ea:	7ea080e7          	jalr	2026(ra) # 80000bd0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043ee:	409c                	lw	a5,0(s1)
    800043f0:	ef99                	bnez	a5,8000440e <holdingsleep+0x3e>
    800043f2:	4481                	li	s1,0
  release(&lk->lk);
    800043f4:	854a                	mv	a0,s2
    800043f6:	ffffd097          	auipc	ra,0xffffd
    800043fa:	88e080e7          	jalr	-1906(ra) # 80000c84 <release>
  return r;
}
    800043fe:	8526                	mv	a0,s1
    80004400:	70a2                	ld	ra,40(sp)
    80004402:	7402                	ld	s0,32(sp)
    80004404:	64e2                	ld	s1,24(sp)
    80004406:	6942                	ld	s2,16(sp)
    80004408:	69a2                	ld	s3,8(sp)
    8000440a:	6145                	addi	sp,sp,48
    8000440c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000440e:	0284a983          	lw	s3,40(s1)
    80004412:	ffffd097          	auipc	ra,0xffffd
    80004416:	584080e7          	jalr	1412(ra) # 80001996 <myproc>
    8000441a:	5904                	lw	s1,48(a0)
    8000441c:	413484b3          	sub	s1,s1,s3
    80004420:	0014b493          	seqz	s1,s1
    80004424:	bfc1                	j	800043f4 <holdingsleep+0x24>

0000000080004426 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004426:	1141                	addi	sp,sp,-16
    80004428:	e406                	sd	ra,8(sp)
    8000442a:	e022                	sd	s0,0(sp)
    8000442c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000442e:	00004597          	auipc	a1,0x4
    80004432:	27258593          	addi	a1,a1,626 # 800086a0 <syscalls+0x240>
    80004436:	0001d517          	auipc	a0,0x1d
    8000443a:	f8250513          	addi	a0,a0,-126 # 800213b8 <ftable>
    8000443e:	ffffc097          	auipc	ra,0xffffc
    80004442:	702080e7          	jalr	1794(ra) # 80000b40 <initlock>
}
    80004446:	60a2                	ld	ra,8(sp)
    80004448:	6402                	ld	s0,0(sp)
    8000444a:	0141                	addi	sp,sp,16
    8000444c:	8082                	ret

000000008000444e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000444e:	1101                	addi	sp,sp,-32
    80004450:	ec06                	sd	ra,24(sp)
    80004452:	e822                	sd	s0,16(sp)
    80004454:	e426                	sd	s1,8(sp)
    80004456:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004458:	0001d517          	auipc	a0,0x1d
    8000445c:	f6050513          	addi	a0,a0,-160 # 800213b8 <ftable>
    80004460:	ffffc097          	auipc	ra,0xffffc
    80004464:	770080e7          	jalr	1904(ra) # 80000bd0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004468:	0001d497          	auipc	s1,0x1d
    8000446c:	f6848493          	addi	s1,s1,-152 # 800213d0 <ftable+0x18>
    80004470:	0001e717          	auipc	a4,0x1e
    80004474:	f0070713          	addi	a4,a4,-256 # 80022370 <ftable+0xfb8>
    if(f->ref == 0){
    80004478:	40dc                	lw	a5,4(s1)
    8000447a:	cf99                	beqz	a5,80004498 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000447c:	02848493          	addi	s1,s1,40
    80004480:	fee49ce3          	bne	s1,a4,80004478 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004484:	0001d517          	auipc	a0,0x1d
    80004488:	f3450513          	addi	a0,a0,-204 # 800213b8 <ftable>
    8000448c:	ffffc097          	auipc	ra,0xffffc
    80004490:	7f8080e7          	jalr	2040(ra) # 80000c84 <release>
  return 0;
    80004494:	4481                	li	s1,0
    80004496:	a819                	j	800044ac <filealloc+0x5e>
      f->ref = 1;
    80004498:	4785                	li	a5,1
    8000449a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000449c:	0001d517          	auipc	a0,0x1d
    800044a0:	f1c50513          	addi	a0,a0,-228 # 800213b8 <ftable>
    800044a4:	ffffc097          	auipc	ra,0xffffc
    800044a8:	7e0080e7          	jalr	2016(ra) # 80000c84 <release>
}
    800044ac:	8526                	mv	a0,s1
    800044ae:	60e2                	ld	ra,24(sp)
    800044b0:	6442                	ld	s0,16(sp)
    800044b2:	64a2                	ld	s1,8(sp)
    800044b4:	6105                	addi	sp,sp,32
    800044b6:	8082                	ret

00000000800044b8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800044b8:	1101                	addi	sp,sp,-32
    800044ba:	ec06                	sd	ra,24(sp)
    800044bc:	e822                	sd	s0,16(sp)
    800044be:	e426                	sd	s1,8(sp)
    800044c0:	1000                	addi	s0,sp,32
    800044c2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800044c4:	0001d517          	auipc	a0,0x1d
    800044c8:	ef450513          	addi	a0,a0,-268 # 800213b8 <ftable>
    800044cc:	ffffc097          	auipc	ra,0xffffc
    800044d0:	704080e7          	jalr	1796(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    800044d4:	40dc                	lw	a5,4(s1)
    800044d6:	02f05263          	blez	a5,800044fa <filedup+0x42>
    panic("filedup");
  f->ref++;
    800044da:	2785                	addiw	a5,a5,1
    800044dc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800044de:	0001d517          	auipc	a0,0x1d
    800044e2:	eda50513          	addi	a0,a0,-294 # 800213b8 <ftable>
    800044e6:	ffffc097          	auipc	ra,0xffffc
    800044ea:	79e080e7          	jalr	1950(ra) # 80000c84 <release>
  return f;
}
    800044ee:	8526                	mv	a0,s1
    800044f0:	60e2                	ld	ra,24(sp)
    800044f2:	6442                	ld	s0,16(sp)
    800044f4:	64a2                	ld	s1,8(sp)
    800044f6:	6105                	addi	sp,sp,32
    800044f8:	8082                	ret
    panic("filedup");
    800044fa:	00004517          	auipc	a0,0x4
    800044fe:	1ae50513          	addi	a0,a0,430 # 800086a8 <syscalls+0x248>
    80004502:	ffffc097          	auipc	ra,0xffffc
    80004506:	038080e7          	jalr	56(ra) # 8000053a <panic>

000000008000450a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000450a:	7139                	addi	sp,sp,-64
    8000450c:	fc06                	sd	ra,56(sp)
    8000450e:	f822                	sd	s0,48(sp)
    80004510:	f426                	sd	s1,40(sp)
    80004512:	f04a                	sd	s2,32(sp)
    80004514:	ec4e                	sd	s3,24(sp)
    80004516:	e852                	sd	s4,16(sp)
    80004518:	e456                	sd	s5,8(sp)
    8000451a:	0080                	addi	s0,sp,64
    8000451c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000451e:	0001d517          	auipc	a0,0x1d
    80004522:	e9a50513          	addi	a0,a0,-358 # 800213b8 <ftable>
    80004526:	ffffc097          	auipc	ra,0xffffc
    8000452a:	6aa080e7          	jalr	1706(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    8000452e:	40dc                	lw	a5,4(s1)
    80004530:	06f05163          	blez	a5,80004592 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004534:	37fd                	addiw	a5,a5,-1
    80004536:	0007871b          	sext.w	a4,a5
    8000453a:	c0dc                	sw	a5,4(s1)
    8000453c:	06e04363          	bgtz	a4,800045a2 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004540:	0004a903          	lw	s2,0(s1)
    80004544:	0094ca83          	lbu	s5,9(s1)
    80004548:	0104ba03          	ld	s4,16(s1)
    8000454c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004550:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004554:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004558:	0001d517          	auipc	a0,0x1d
    8000455c:	e6050513          	addi	a0,a0,-416 # 800213b8 <ftable>
    80004560:	ffffc097          	auipc	ra,0xffffc
    80004564:	724080e7          	jalr	1828(ra) # 80000c84 <release>

  if(ff.type == FD_PIPE){
    80004568:	4785                	li	a5,1
    8000456a:	04f90d63          	beq	s2,a5,800045c4 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000456e:	3979                	addiw	s2,s2,-2
    80004570:	4785                	li	a5,1
    80004572:	0527e063          	bltu	a5,s2,800045b2 <fileclose+0xa8>
    begin_op();
    80004576:	00000097          	auipc	ra,0x0
    8000457a:	acc080e7          	jalr	-1332(ra) # 80004042 <begin_op>
    iput(ff.ip);
    8000457e:	854e                	mv	a0,s3
    80004580:	fffff097          	auipc	ra,0xfffff
    80004584:	2a0080e7          	jalr	672(ra) # 80003820 <iput>
    end_op();
    80004588:	00000097          	auipc	ra,0x0
    8000458c:	b38080e7          	jalr	-1224(ra) # 800040c0 <end_op>
    80004590:	a00d                	j	800045b2 <fileclose+0xa8>
    panic("fileclose");
    80004592:	00004517          	auipc	a0,0x4
    80004596:	11e50513          	addi	a0,a0,286 # 800086b0 <syscalls+0x250>
    8000459a:	ffffc097          	auipc	ra,0xffffc
    8000459e:	fa0080e7          	jalr	-96(ra) # 8000053a <panic>
    release(&ftable.lock);
    800045a2:	0001d517          	auipc	a0,0x1d
    800045a6:	e1650513          	addi	a0,a0,-490 # 800213b8 <ftable>
    800045aa:	ffffc097          	auipc	ra,0xffffc
    800045ae:	6da080e7          	jalr	1754(ra) # 80000c84 <release>
  }
}
    800045b2:	70e2                	ld	ra,56(sp)
    800045b4:	7442                	ld	s0,48(sp)
    800045b6:	74a2                	ld	s1,40(sp)
    800045b8:	7902                	ld	s2,32(sp)
    800045ba:	69e2                	ld	s3,24(sp)
    800045bc:	6a42                	ld	s4,16(sp)
    800045be:	6aa2                	ld	s5,8(sp)
    800045c0:	6121                	addi	sp,sp,64
    800045c2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800045c4:	85d6                	mv	a1,s5
    800045c6:	8552                	mv	a0,s4
    800045c8:	00000097          	auipc	ra,0x0
    800045cc:	34c080e7          	jalr	844(ra) # 80004914 <pipeclose>
    800045d0:	b7cd                	j	800045b2 <fileclose+0xa8>

00000000800045d2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800045d2:	715d                	addi	sp,sp,-80
    800045d4:	e486                	sd	ra,72(sp)
    800045d6:	e0a2                	sd	s0,64(sp)
    800045d8:	fc26                	sd	s1,56(sp)
    800045da:	f84a                	sd	s2,48(sp)
    800045dc:	f44e                	sd	s3,40(sp)
    800045de:	0880                	addi	s0,sp,80
    800045e0:	84aa                	mv	s1,a0
    800045e2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800045e4:	ffffd097          	auipc	ra,0xffffd
    800045e8:	3b2080e7          	jalr	946(ra) # 80001996 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800045ec:	409c                	lw	a5,0(s1)
    800045ee:	37f9                	addiw	a5,a5,-2
    800045f0:	4705                	li	a4,1
    800045f2:	04f76763          	bltu	a4,a5,80004640 <filestat+0x6e>
    800045f6:	892a                	mv	s2,a0
    ilock(f->ip);
    800045f8:	6c88                	ld	a0,24(s1)
    800045fa:	fffff097          	auipc	ra,0xfffff
    800045fe:	06c080e7          	jalr	108(ra) # 80003666 <ilock>
    stati(f->ip, &st);
    80004602:	fb840593          	addi	a1,s0,-72
    80004606:	6c88                	ld	a0,24(s1)
    80004608:	fffff097          	auipc	ra,0xfffff
    8000460c:	2e8080e7          	jalr	744(ra) # 800038f0 <stati>
    iunlock(f->ip);
    80004610:	6c88                	ld	a0,24(s1)
    80004612:	fffff097          	auipc	ra,0xfffff
    80004616:	116080e7          	jalr	278(ra) # 80003728 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000461a:	46e1                	li	a3,24
    8000461c:	fb840613          	addi	a2,s0,-72
    80004620:	85ce                	mv	a1,s3
    80004622:	05093503          	ld	a0,80(s2)
    80004626:	ffffd097          	auipc	ra,0xffffd
    8000462a:	034080e7          	jalr	52(ra) # 8000165a <copyout>
    8000462e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004632:	60a6                	ld	ra,72(sp)
    80004634:	6406                	ld	s0,64(sp)
    80004636:	74e2                	ld	s1,56(sp)
    80004638:	7942                	ld	s2,48(sp)
    8000463a:	79a2                	ld	s3,40(sp)
    8000463c:	6161                	addi	sp,sp,80
    8000463e:	8082                	ret
  return -1;
    80004640:	557d                	li	a0,-1
    80004642:	bfc5                	j	80004632 <filestat+0x60>

0000000080004644 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004644:	7179                	addi	sp,sp,-48
    80004646:	f406                	sd	ra,40(sp)
    80004648:	f022                	sd	s0,32(sp)
    8000464a:	ec26                	sd	s1,24(sp)
    8000464c:	e84a                	sd	s2,16(sp)
    8000464e:	e44e                	sd	s3,8(sp)
    80004650:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004652:	00854783          	lbu	a5,8(a0)
    80004656:	c3d5                	beqz	a5,800046fa <fileread+0xb6>
    80004658:	84aa                	mv	s1,a0
    8000465a:	89ae                	mv	s3,a1
    8000465c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000465e:	411c                	lw	a5,0(a0)
    80004660:	4705                	li	a4,1
    80004662:	04e78963          	beq	a5,a4,800046b4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004666:	470d                	li	a4,3
    80004668:	04e78d63          	beq	a5,a4,800046c2 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000466c:	4709                	li	a4,2
    8000466e:	06e79e63          	bne	a5,a4,800046ea <fileread+0xa6>
    ilock(f->ip);
    80004672:	6d08                	ld	a0,24(a0)
    80004674:	fffff097          	auipc	ra,0xfffff
    80004678:	ff2080e7          	jalr	-14(ra) # 80003666 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000467c:	874a                	mv	a4,s2
    8000467e:	5094                	lw	a3,32(s1)
    80004680:	864e                	mv	a2,s3
    80004682:	4585                	li	a1,1
    80004684:	6c88                	ld	a0,24(s1)
    80004686:	fffff097          	auipc	ra,0xfffff
    8000468a:	294080e7          	jalr	660(ra) # 8000391a <readi>
    8000468e:	892a                	mv	s2,a0
    80004690:	00a05563          	blez	a0,8000469a <fileread+0x56>
      f->off += r;
    80004694:	509c                	lw	a5,32(s1)
    80004696:	9fa9                	addw	a5,a5,a0
    80004698:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000469a:	6c88                	ld	a0,24(s1)
    8000469c:	fffff097          	auipc	ra,0xfffff
    800046a0:	08c080e7          	jalr	140(ra) # 80003728 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800046a4:	854a                	mv	a0,s2
    800046a6:	70a2                	ld	ra,40(sp)
    800046a8:	7402                	ld	s0,32(sp)
    800046aa:	64e2                	ld	s1,24(sp)
    800046ac:	6942                	ld	s2,16(sp)
    800046ae:	69a2                	ld	s3,8(sp)
    800046b0:	6145                	addi	sp,sp,48
    800046b2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800046b4:	6908                	ld	a0,16(a0)
    800046b6:	00000097          	auipc	ra,0x0
    800046ba:	3c0080e7          	jalr	960(ra) # 80004a76 <piperead>
    800046be:	892a                	mv	s2,a0
    800046c0:	b7d5                	j	800046a4 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800046c2:	02451783          	lh	a5,36(a0)
    800046c6:	03079693          	slli	a3,a5,0x30
    800046ca:	92c1                	srli	a3,a3,0x30
    800046cc:	4725                	li	a4,9
    800046ce:	02d76863          	bltu	a4,a3,800046fe <fileread+0xba>
    800046d2:	0792                	slli	a5,a5,0x4
    800046d4:	0001d717          	auipc	a4,0x1d
    800046d8:	c4470713          	addi	a4,a4,-956 # 80021318 <devsw>
    800046dc:	97ba                	add	a5,a5,a4
    800046de:	639c                	ld	a5,0(a5)
    800046e0:	c38d                	beqz	a5,80004702 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800046e2:	4505                	li	a0,1
    800046e4:	9782                	jalr	a5
    800046e6:	892a                	mv	s2,a0
    800046e8:	bf75                	j	800046a4 <fileread+0x60>
    panic("fileread");
    800046ea:	00004517          	auipc	a0,0x4
    800046ee:	fd650513          	addi	a0,a0,-42 # 800086c0 <syscalls+0x260>
    800046f2:	ffffc097          	auipc	ra,0xffffc
    800046f6:	e48080e7          	jalr	-440(ra) # 8000053a <panic>
    return -1;
    800046fa:	597d                	li	s2,-1
    800046fc:	b765                	j	800046a4 <fileread+0x60>
      return -1;
    800046fe:	597d                	li	s2,-1
    80004700:	b755                	j	800046a4 <fileread+0x60>
    80004702:	597d                	li	s2,-1
    80004704:	b745                	j	800046a4 <fileread+0x60>

0000000080004706 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004706:	715d                	addi	sp,sp,-80
    80004708:	e486                	sd	ra,72(sp)
    8000470a:	e0a2                	sd	s0,64(sp)
    8000470c:	fc26                	sd	s1,56(sp)
    8000470e:	f84a                	sd	s2,48(sp)
    80004710:	f44e                	sd	s3,40(sp)
    80004712:	f052                	sd	s4,32(sp)
    80004714:	ec56                	sd	s5,24(sp)
    80004716:	e85a                	sd	s6,16(sp)
    80004718:	e45e                	sd	s7,8(sp)
    8000471a:	e062                	sd	s8,0(sp)
    8000471c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000471e:	00954783          	lbu	a5,9(a0)
    80004722:	10078663          	beqz	a5,8000482e <filewrite+0x128>
    80004726:	892a                	mv	s2,a0
    80004728:	8b2e                	mv	s6,a1
    8000472a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000472c:	411c                	lw	a5,0(a0)
    8000472e:	4705                	li	a4,1
    80004730:	02e78263          	beq	a5,a4,80004754 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004734:	470d                	li	a4,3
    80004736:	02e78663          	beq	a5,a4,80004762 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000473a:	4709                	li	a4,2
    8000473c:	0ee79163          	bne	a5,a4,8000481e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004740:	0ac05d63          	blez	a2,800047fa <filewrite+0xf4>
    int i = 0;
    80004744:	4981                	li	s3,0
    80004746:	6b85                	lui	s7,0x1
    80004748:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000474c:	6c05                	lui	s8,0x1
    8000474e:	c00c0c1b          	addiw	s8,s8,-1024
    80004752:	a861                	j	800047ea <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004754:	6908                	ld	a0,16(a0)
    80004756:	00000097          	auipc	ra,0x0
    8000475a:	22e080e7          	jalr	558(ra) # 80004984 <pipewrite>
    8000475e:	8a2a                	mv	s4,a0
    80004760:	a045                	j	80004800 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004762:	02451783          	lh	a5,36(a0)
    80004766:	03079693          	slli	a3,a5,0x30
    8000476a:	92c1                	srli	a3,a3,0x30
    8000476c:	4725                	li	a4,9
    8000476e:	0cd76263          	bltu	a4,a3,80004832 <filewrite+0x12c>
    80004772:	0792                	slli	a5,a5,0x4
    80004774:	0001d717          	auipc	a4,0x1d
    80004778:	ba470713          	addi	a4,a4,-1116 # 80021318 <devsw>
    8000477c:	97ba                	add	a5,a5,a4
    8000477e:	679c                	ld	a5,8(a5)
    80004780:	cbdd                	beqz	a5,80004836 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004782:	4505                	li	a0,1
    80004784:	9782                	jalr	a5
    80004786:	8a2a                	mv	s4,a0
    80004788:	a8a5                	j	80004800 <filewrite+0xfa>
    8000478a:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000478e:	00000097          	auipc	ra,0x0
    80004792:	8b4080e7          	jalr	-1868(ra) # 80004042 <begin_op>
      ilock(f->ip);
    80004796:	01893503          	ld	a0,24(s2)
    8000479a:	fffff097          	auipc	ra,0xfffff
    8000479e:	ecc080e7          	jalr	-308(ra) # 80003666 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047a2:	8756                	mv	a4,s5
    800047a4:	02092683          	lw	a3,32(s2)
    800047a8:	01698633          	add	a2,s3,s6
    800047ac:	4585                	li	a1,1
    800047ae:	01893503          	ld	a0,24(s2)
    800047b2:	fffff097          	auipc	ra,0xfffff
    800047b6:	260080e7          	jalr	608(ra) # 80003a12 <writei>
    800047ba:	84aa                	mv	s1,a0
    800047bc:	00a05763          	blez	a0,800047ca <filewrite+0xc4>
        f->off += r;
    800047c0:	02092783          	lw	a5,32(s2)
    800047c4:	9fa9                	addw	a5,a5,a0
    800047c6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800047ca:	01893503          	ld	a0,24(s2)
    800047ce:	fffff097          	auipc	ra,0xfffff
    800047d2:	f5a080e7          	jalr	-166(ra) # 80003728 <iunlock>
      end_op();
    800047d6:	00000097          	auipc	ra,0x0
    800047da:	8ea080e7          	jalr	-1814(ra) # 800040c0 <end_op>

      if(r != n1){
    800047de:	009a9f63          	bne	s5,s1,800047fc <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800047e2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800047e6:	0149db63          	bge	s3,s4,800047fc <filewrite+0xf6>
      int n1 = n - i;
    800047ea:	413a04bb          	subw	s1,s4,s3
    800047ee:	0004879b          	sext.w	a5,s1
    800047f2:	f8fbdce3          	bge	s7,a5,8000478a <filewrite+0x84>
    800047f6:	84e2                	mv	s1,s8
    800047f8:	bf49                	j	8000478a <filewrite+0x84>
    int i = 0;
    800047fa:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800047fc:	013a1f63          	bne	s4,s3,8000481a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004800:	8552                	mv	a0,s4
    80004802:	60a6                	ld	ra,72(sp)
    80004804:	6406                	ld	s0,64(sp)
    80004806:	74e2                	ld	s1,56(sp)
    80004808:	7942                	ld	s2,48(sp)
    8000480a:	79a2                	ld	s3,40(sp)
    8000480c:	7a02                	ld	s4,32(sp)
    8000480e:	6ae2                	ld	s5,24(sp)
    80004810:	6b42                	ld	s6,16(sp)
    80004812:	6ba2                	ld	s7,8(sp)
    80004814:	6c02                	ld	s8,0(sp)
    80004816:	6161                	addi	sp,sp,80
    80004818:	8082                	ret
    ret = (i == n ? n : -1);
    8000481a:	5a7d                	li	s4,-1
    8000481c:	b7d5                	j	80004800 <filewrite+0xfa>
    panic("filewrite");
    8000481e:	00004517          	auipc	a0,0x4
    80004822:	eb250513          	addi	a0,a0,-334 # 800086d0 <syscalls+0x270>
    80004826:	ffffc097          	auipc	ra,0xffffc
    8000482a:	d14080e7          	jalr	-748(ra) # 8000053a <panic>
    return -1;
    8000482e:	5a7d                	li	s4,-1
    80004830:	bfc1                	j	80004800 <filewrite+0xfa>
      return -1;
    80004832:	5a7d                	li	s4,-1
    80004834:	b7f1                	j	80004800 <filewrite+0xfa>
    80004836:	5a7d                	li	s4,-1
    80004838:	b7e1                	j	80004800 <filewrite+0xfa>

000000008000483a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000483a:	7179                	addi	sp,sp,-48
    8000483c:	f406                	sd	ra,40(sp)
    8000483e:	f022                	sd	s0,32(sp)
    80004840:	ec26                	sd	s1,24(sp)
    80004842:	e84a                	sd	s2,16(sp)
    80004844:	e44e                	sd	s3,8(sp)
    80004846:	e052                	sd	s4,0(sp)
    80004848:	1800                	addi	s0,sp,48
    8000484a:	84aa                	mv	s1,a0
    8000484c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000484e:	0005b023          	sd	zero,0(a1)
    80004852:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004856:	00000097          	auipc	ra,0x0
    8000485a:	bf8080e7          	jalr	-1032(ra) # 8000444e <filealloc>
    8000485e:	e088                	sd	a0,0(s1)
    80004860:	c551                	beqz	a0,800048ec <pipealloc+0xb2>
    80004862:	00000097          	auipc	ra,0x0
    80004866:	bec080e7          	jalr	-1044(ra) # 8000444e <filealloc>
    8000486a:	00aa3023          	sd	a0,0(s4)
    8000486e:	c92d                	beqz	a0,800048e0 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004870:	ffffc097          	auipc	ra,0xffffc
    80004874:	270080e7          	jalr	624(ra) # 80000ae0 <kalloc>
    80004878:	892a                	mv	s2,a0
    8000487a:	c125                	beqz	a0,800048da <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000487c:	4985                	li	s3,1
    8000487e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004882:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004886:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000488a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000488e:	00004597          	auipc	a1,0x4
    80004892:	e5258593          	addi	a1,a1,-430 # 800086e0 <syscalls+0x280>
    80004896:	ffffc097          	auipc	ra,0xffffc
    8000489a:	2aa080e7          	jalr	682(ra) # 80000b40 <initlock>
  (*f0)->type = FD_PIPE;
    8000489e:	609c                	ld	a5,0(s1)
    800048a0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048a4:	609c                	ld	a5,0(s1)
    800048a6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048aa:	609c                	ld	a5,0(s1)
    800048ac:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800048b0:	609c                	ld	a5,0(s1)
    800048b2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800048b6:	000a3783          	ld	a5,0(s4)
    800048ba:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800048be:	000a3783          	ld	a5,0(s4)
    800048c2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800048c6:	000a3783          	ld	a5,0(s4)
    800048ca:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800048ce:	000a3783          	ld	a5,0(s4)
    800048d2:	0127b823          	sd	s2,16(a5)
  return 0;
    800048d6:	4501                	li	a0,0
    800048d8:	a025                	j	80004900 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800048da:	6088                	ld	a0,0(s1)
    800048dc:	e501                	bnez	a0,800048e4 <pipealloc+0xaa>
    800048de:	a039                	j	800048ec <pipealloc+0xb2>
    800048e0:	6088                	ld	a0,0(s1)
    800048e2:	c51d                	beqz	a0,80004910 <pipealloc+0xd6>
    fileclose(*f0);
    800048e4:	00000097          	auipc	ra,0x0
    800048e8:	c26080e7          	jalr	-986(ra) # 8000450a <fileclose>
  if(*f1)
    800048ec:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800048f0:	557d                	li	a0,-1
  if(*f1)
    800048f2:	c799                	beqz	a5,80004900 <pipealloc+0xc6>
    fileclose(*f1);
    800048f4:	853e                	mv	a0,a5
    800048f6:	00000097          	auipc	ra,0x0
    800048fa:	c14080e7          	jalr	-1004(ra) # 8000450a <fileclose>
  return -1;
    800048fe:	557d                	li	a0,-1
}
    80004900:	70a2                	ld	ra,40(sp)
    80004902:	7402                	ld	s0,32(sp)
    80004904:	64e2                	ld	s1,24(sp)
    80004906:	6942                	ld	s2,16(sp)
    80004908:	69a2                	ld	s3,8(sp)
    8000490a:	6a02                	ld	s4,0(sp)
    8000490c:	6145                	addi	sp,sp,48
    8000490e:	8082                	ret
  return -1;
    80004910:	557d                	li	a0,-1
    80004912:	b7fd                	j	80004900 <pipealloc+0xc6>

0000000080004914 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004914:	1101                	addi	sp,sp,-32
    80004916:	ec06                	sd	ra,24(sp)
    80004918:	e822                	sd	s0,16(sp)
    8000491a:	e426                	sd	s1,8(sp)
    8000491c:	e04a                	sd	s2,0(sp)
    8000491e:	1000                	addi	s0,sp,32
    80004920:	84aa                	mv	s1,a0
    80004922:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004924:	ffffc097          	auipc	ra,0xffffc
    80004928:	2ac080e7          	jalr	684(ra) # 80000bd0 <acquire>
  if(writable){
    8000492c:	02090d63          	beqz	s2,80004966 <pipeclose+0x52>
    pi->writeopen = 0;
    80004930:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004934:	21848513          	addi	a0,s1,536
    80004938:	ffffe097          	auipc	ra,0xffffe
    8000493c:	8ae080e7          	jalr	-1874(ra) # 800021e6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004940:	2204b783          	ld	a5,544(s1)
    80004944:	eb95                	bnez	a5,80004978 <pipeclose+0x64>
    release(&pi->lock);
    80004946:	8526                	mv	a0,s1
    80004948:	ffffc097          	auipc	ra,0xffffc
    8000494c:	33c080e7          	jalr	828(ra) # 80000c84 <release>
    kfree((char*)pi);
    80004950:	8526                	mv	a0,s1
    80004952:	ffffc097          	auipc	ra,0xffffc
    80004956:	090080e7          	jalr	144(ra) # 800009e2 <kfree>
  } else
    release(&pi->lock);
}
    8000495a:	60e2                	ld	ra,24(sp)
    8000495c:	6442                	ld	s0,16(sp)
    8000495e:	64a2                	ld	s1,8(sp)
    80004960:	6902                	ld	s2,0(sp)
    80004962:	6105                	addi	sp,sp,32
    80004964:	8082                	ret
    pi->readopen = 0;
    80004966:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000496a:	21c48513          	addi	a0,s1,540
    8000496e:	ffffe097          	auipc	ra,0xffffe
    80004972:	878080e7          	jalr	-1928(ra) # 800021e6 <wakeup>
    80004976:	b7e9                	j	80004940 <pipeclose+0x2c>
    release(&pi->lock);
    80004978:	8526                	mv	a0,s1
    8000497a:	ffffc097          	auipc	ra,0xffffc
    8000497e:	30a080e7          	jalr	778(ra) # 80000c84 <release>
}
    80004982:	bfe1                	j	8000495a <pipeclose+0x46>

0000000080004984 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004984:	711d                	addi	sp,sp,-96
    80004986:	ec86                	sd	ra,88(sp)
    80004988:	e8a2                	sd	s0,80(sp)
    8000498a:	e4a6                	sd	s1,72(sp)
    8000498c:	e0ca                	sd	s2,64(sp)
    8000498e:	fc4e                	sd	s3,56(sp)
    80004990:	f852                	sd	s4,48(sp)
    80004992:	f456                	sd	s5,40(sp)
    80004994:	f05a                	sd	s6,32(sp)
    80004996:	ec5e                	sd	s7,24(sp)
    80004998:	e862                	sd	s8,16(sp)
    8000499a:	1080                	addi	s0,sp,96
    8000499c:	84aa                	mv	s1,a0
    8000499e:	8aae                	mv	s5,a1
    800049a0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800049a2:	ffffd097          	auipc	ra,0xffffd
    800049a6:	ff4080e7          	jalr	-12(ra) # 80001996 <myproc>
    800049aa:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800049ac:	8526                	mv	a0,s1
    800049ae:	ffffc097          	auipc	ra,0xffffc
    800049b2:	222080e7          	jalr	546(ra) # 80000bd0 <acquire>
  while(i < n){
    800049b6:	0b405363          	blez	s4,80004a5c <pipewrite+0xd8>
  int i = 0;
    800049ba:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049bc:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800049be:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800049c2:	21c48b93          	addi	s7,s1,540
    800049c6:	a089                	j	80004a08 <pipewrite+0x84>
      release(&pi->lock);
    800049c8:	8526                	mv	a0,s1
    800049ca:	ffffc097          	auipc	ra,0xffffc
    800049ce:	2ba080e7          	jalr	698(ra) # 80000c84 <release>
      return -1;
    800049d2:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800049d4:	854a                	mv	a0,s2
    800049d6:	60e6                	ld	ra,88(sp)
    800049d8:	6446                	ld	s0,80(sp)
    800049da:	64a6                	ld	s1,72(sp)
    800049dc:	6906                	ld	s2,64(sp)
    800049de:	79e2                	ld	s3,56(sp)
    800049e0:	7a42                	ld	s4,48(sp)
    800049e2:	7aa2                	ld	s5,40(sp)
    800049e4:	7b02                	ld	s6,32(sp)
    800049e6:	6be2                	ld	s7,24(sp)
    800049e8:	6c42                	ld	s8,16(sp)
    800049ea:	6125                	addi	sp,sp,96
    800049ec:	8082                	ret
      wakeup(&pi->nread);
    800049ee:	8562                	mv	a0,s8
    800049f0:	ffffd097          	auipc	ra,0xffffd
    800049f4:	7f6080e7          	jalr	2038(ra) # 800021e6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800049f8:	85a6                	mv	a1,s1
    800049fa:	855e                	mv	a0,s7
    800049fc:	ffffd097          	auipc	ra,0xffffd
    80004a00:	65e080e7          	jalr	1630(ra) # 8000205a <sleep>
  while(i < n){
    80004a04:	05495d63          	bge	s2,s4,80004a5e <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004a08:	2204a783          	lw	a5,544(s1)
    80004a0c:	dfd5                	beqz	a5,800049c8 <pipewrite+0x44>
    80004a0e:	0289a783          	lw	a5,40(s3)
    80004a12:	fbdd                	bnez	a5,800049c8 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a14:	2184a783          	lw	a5,536(s1)
    80004a18:	21c4a703          	lw	a4,540(s1)
    80004a1c:	2007879b          	addiw	a5,a5,512
    80004a20:	fcf707e3          	beq	a4,a5,800049ee <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a24:	4685                	li	a3,1
    80004a26:	01590633          	add	a2,s2,s5
    80004a2a:	faf40593          	addi	a1,s0,-81
    80004a2e:	0509b503          	ld	a0,80(s3)
    80004a32:	ffffd097          	auipc	ra,0xffffd
    80004a36:	cb4080e7          	jalr	-844(ra) # 800016e6 <copyin>
    80004a3a:	03650263          	beq	a0,s6,80004a5e <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a3e:	21c4a783          	lw	a5,540(s1)
    80004a42:	0017871b          	addiw	a4,a5,1
    80004a46:	20e4ae23          	sw	a4,540(s1)
    80004a4a:	1ff7f793          	andi	a5,a5,511
    80004a4e:	97a6                	add	a5,a5,s1
    80004a50:	faf44703          	lbu	a4,-81(s0)
    80004a54:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a58:	2905                	addiw	s2,s2,1
    80004a5a:	b76d                	j	80004a04 <pipewrite+0x80>
  int i = 0;
    80004a5c:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004a5e:	21848513          	addi	a0,s1,536
    80004a62:	ffffd097          	auipc	ra,0xffffd
    80004a66:	784080e7          	jalr	1924(ra) # 800021e6 <wakeup>
  release(&pi->lock);
    80004a6a:	8526                	mv	a0,s1
    80004a6c:	ffffc097          	auipc	ra,0xffffc
    80004a70:	218080e7          	jalr	536(ra) # 80000c84 <release>
  return i;
    80004a74:	b785                	j	800049d4 <pipewrite+0x50>

0000000080004a76 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a76:	715d                	addi	sp,sp,-80
    80004a78:	e486                	sd	ra,72(sp)
    80004a7a:	e0a2                	sd	s0,64(sp)
    80004a7c:	fc26                	sd	s1,56(sp)
    80004a7e:	f84a                	sd	s2,48(sp)
    80004a80:	f44e                	sd	s3,40(sp)
    80004a82:	f052                	sd	s4,32(sp)
    80004a84:	ec56                	sd	s5,24(sp)
    80004a86:	e85a                	sd	s6,16(sp)
    80004a88:	0880                	addi	s0,sp,80
    80004a8a:	84aa                	mv	s1,a0
    80004a8c:	892e                	mv	s2,a1
    80004a8e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a90:	ffffd097          	auipc	ra,0xffffd
    80004a94:	f06080e7          	jalr	-250(ra) # 80001996 <myproc>
    80004a98:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004a9a:	8526                	mv	a0,s1
    80004a9c:	ffffc097          	auipc	ra,0xffffc
    80004aa0:	134080e7          	jalr	308(ra) # 80000bd0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004aa4:	2184a703          	lw	a4,536(s1)
    80004aa8:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004aac:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ab0:	02f71463          	bne	a4,a5,80004ad8 <piperead+0x62>
    80004ab4:	2244a783          	lw	a5,548(s1)
    80004ab8:	c385                	beqz	a5,80004ad8 <piperead+0x62>
    if(pr->killed){
    80004aba:	028a2783          	lw	a5,40(s4)
    80004abe:	ebc9                	bnez	a5,80004b50 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ac0:	85a6                	mv	a1,s1
    80004ac2:	854e                	mv	a0,s3
    80004ac4:	ffffd097          	auipc	ra,0xffffd
    80004ac8:	596080e7          	jalr	1430(ra) # 8000205a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004acc:	2184a703          	lw	a4,536(s1)
    80004ad0:	21c4a783          	lw	a5,540(s1)
    80004ad4:	fef700e3          	beq	a4,a5,80004ab4 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ad8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ada:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004adc:	05505463          	blez	s5,80004b24 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80004ae0:	2184a783          	lw	a5,536(s1)
    80004ae4:	21c4a703          	lw	a4,540(s1)
    80004ae8:	02f70e63          	beq	a4,a5,80004b24 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004aec:	0017871b          	addiw	a4,a5,1
    80004af0:	20e4ac23          	sw	a4,536(s1)
    80004af4:	1ff7f793          	andi	a5,a5,511
    80004af8:	97a6                	add	a5,a5,s1
    80004afa:	0187c783          	lbu	a5,24(a5)
    80004afe:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b02:	4685                	li	a3,1
    80004b04:	fbf40613          	addi	a2,s0,-65
    80004b08:	85ca                	mv	a1,s2
    80004b0a:	050a3503          	ld	a0,80(s4)
    80004b0e:	ffffd097          	auipc	ra,0xffffd
    80004b12:	b4c080e7          	jalr	-1204(ra) # 8000165a <copyout>
    80004b16:	01650763          	beq	a0,s6,80004b24 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b1a:	2985                	addiw	s3,s3,1
    80004b1c:	0905                	addi	s2,s2,1
    80004b1e:	fd3a91e3          	bne	s5,s3,80004ae0 <piperead+0x6a>
    80004b22:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b24:	21c48513          	addi	a0,s1,540
    80004b28:	ffffd097          	auipc	ra,0xffffd
    80004b2c:	6be080e7          	jalr	1726(ra) # 800021e6 <wakeup>
  release(&pi->lock);
    80004b30:	8526                	mv	a0,s1
    80004b32:	ffffc097          	auipc	ra,0xffffc
    80004b36:	152080e7          	jalr	338(ra) # 80000c84 <release>
  return i;
}
    80004b3a:	854e                	mv	a0,s3
    80004b3c:	60a6                	ld	ra,72(sp)
    80004b3e:	6406                	ld	s0,64(sp)
    80004b40:	74e2                	ld	s1,56(sp)
    80004b42:	7942                	ld	s2,48(sp)
    80004b44:	79a2                	ld	s3,40(sp)
    80004b46:	7a02                	ld	s4,32(sp)
    80004b48:	6ae2                	ld	s5,24(sp)
    80004b4a:	6b42                	ld	s6,16(sp)
    80004b4c:	6161                	addi	sp,sp,80
    80004b4e:	8082                	ret
      release(&pi->lock);
    80004b50:	8526                	mv	a0,s1
    80004b52:	ffffc097          	auipc	ra,0xffffc
    80004b56:	132080e7          	jalr	306(ra) # 80000c84 <release>
      return -1;
    80004b5a:	59fd                	li	s3,-1
    80004b5c:	bff9                	j	80004b3a <piperead+0xc4>

0000000080004b5e <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004b5e:	de010113          	addi	sp,sp,-544
    80004b62:	20113c23          	sd	ra,536(sp)
    80004b66:	20813823          	sd	s0,528(sp)
    80004b6a:	20913423          	sd	s1,520(sp)
    80004b6e:	21213023          	sd	s2,512(sp)
    80004b72:	ffce                	sd	s3,504(sp)
    80004b74:	fbd2                	sd	s4,496(sp)
    80004b76:	f7d6                	sd	s5,488(sp)
    80004b78:	f3da                	sd	s6,480(sp)
    80004b7a:	efde                	sd	s7,472(sp)
    80004b7c:	ebe2                	sd	s8,464(sp)
    80004b7e:	e7e6                	sd	s9,456(sp)
    80004b80:	e3ea                	sd	s10,448(sp)
    80004b82:	ff6e                	sd	s11,440(sp)
    80004b84:	1400                	addi	s0,sp,544
    80004b86:	892a                	mv	s2,a0
    80004b88:	dea43423          	sd	a0,-536(s0)
    80004b8c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b90:	ffffd097          	auipc	ra,0xffffd
    80004b94:	e06080e7          	jalr	-506(ra) # 80001996 <myproc>
    80004b98:	84aa                	mv	s1,a0

  begin_op();
    80004b9a:	fffff097          	auipc	ra,0xfffff
    80004b9e:	4a8080e7          	jalr	1192(ra) # 80004042 <begin_op>

  if((ip = namei(path)) == 0){
    80004ba2:	854a                	mv	a0,s2
    80004ba4:	fffff097          	auipc	ra,0xfffff
    80004ba8:	27e080e7          	jalr	638(ra) # 80003e22 <namei>
    80004bac:	c93d                	beqz	a0,80004c22 <exec+0xc4>
    80004bae:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004bb0:	fffff097          	auipc	ra,0xfffff
    80004bb4:	ab6080e7          	jalr	-1354(ra) # 80003666 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004bb8:	04000713          	li	a4,64
    80004bbc:	4681                	li	a3,0
    80004bbe:	e5040613          	addi	a2,s0,-432
    80004bc2:	4581                	li	a1,0
    80004bc4:	8556                	mv	a0,s5
    80004bc6:	fffff097          	auipc	ra,0xfffff
    80004bca:	d54080e7          	jalr	-684(ra) # 8000391a <readi>
    80004bce:	04000793          	li	a5,64
    80004bd2:	00f51a63          	bne	a0,a5,80004be6 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004bd6:	e5042703          	lw	a4,-432(s0)
    80004bda:	464c47b7          	lui	a5,0x464c4
    80004bde:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004be2:	04f70663          	beq	a4,a5,80004c2e <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004be6:	8556                	mv	a0,s5
    80004be8:	fffff097          	auipc	ra,0xfffff
    80004bec:	ce0080e7          	jalr	-800(ra) # 800038c8 <iunlockput>
    end_op();
    80004bf0:	fffff097          	auipc	ra,0xfffff
    80004bf4:	4d0080e7          	jalr	1232(ra) # 800040c0 <end_op>
  }
  return -1;
    80004bf8:	557d                	li	a0,-1
}
    80004bfa:	21813083          	ld	ra,536(sp)
    80004bfe:	21013403          	ld	s0,528(sp)
    80004c02:	20813483          	ld	s1,520(sp)
    80004c06:	20013903          	ld	s2,512(sp)
    80004c0a:	79fe                	ld	s3,504(sp)
    80004c0c:	7a5e                	ld	s4,496(sp)
    80004c0e:	7abe                	ld	s5,488(sp)
    80004c10:	7b1e                	ld	s6,480(sp)
    80004c12:	6bfe                	ld	s7,472(sp)
    80004c14:	6c5e                	ld	s8,464(sp)
    80004c16:	6cbe                	ld	s9,456(sp)
    80004c18:	6d1e                	ld	s10,448(sp)
    80004c1a:	7dfa                	ld	s11,440(sp)
    80004c1c:	22010113          	addi	sp,sp,544
    80004c20:	8082                	ret
    end_op();
    80004c22:	fffff097          	auipc	ra,0xfffff
    80004c26:	49e080e7          	jalr	1182(ra) # 800040c0 <end_op>
    return -1;
    80004c2a:	557d                	li	a0,-1
    80004c2c:	b7f9                	j	80004bfa <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c2e:	8526                	mv	a0,s1
    80004c30:	ffffd097          	auipc	ra,0xffffd
    80004c34:	e2a080e7          	jalr	-470(ra) # 80001a5a <proc_pagetable>
    80004c38:	8b2a                	mv	s6,a0
    80004c3a:	d555                	beqz	a0,80004be6 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c3c:	e7042783          	lw	a5,-400(s0)
    80004c40:	e8845703          	lhu	a4,-376(s0)
    80004c44:	c735                	beqz	a4,80004cb0 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c46:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c48:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004c4c:	6a05                	lui	s4,0x1
    80004c4e:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004c52:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004c56:	6d85                	lui	s11,0x1
    80004c58:	7d7d                	lui	s10,0xfffff
    80004c5a:	ac1d                	j	80004e90 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004c5c:	00004517          	auipc	a0,0x4
    80004c60:	a8c50513          	addi	a0,a0,-1396 # 800086e8 <syscalls+0x288>
    80004c64:	ffffc097          	auipc	ra,0xffffc
    80004c68:	8d6080e7          	jalr	-1834(ra) # 8000053a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c6c:	874a                	mv	a4,s2
    80004c6e:	009c86bb          	addw	a3,s9,s1
    80004c72:	4581                	li	a1,0
    80004c74:	8556                	mv	a0,s5
    80004c76:	fffff097          	auipc	ra,0xfffff
    80004c7a:	ca4080e7          	jalr	-860(ra) # 8000391a <readi>
    80004c7e:	2501                	sext.w	a0,a0
    80004c80:	1aa91863          	bne	s2,a0,80004e30 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004c84:	009d84bb          	addw	s1,s11,s1
    80004c88:	013d09bb          	addw	s3,s10,s3
    80004c8c:	1f74f263          	bgeu	s1,s7,80004e70 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004c90:	02049593          	slli	a1,s1,0x20
    80004c94:	9181                	srli	a1,a1,0x20
    80004c96:	95e2                	add	a1,a1,s8
    80004c98:	855a                	mv	a0,s6
    80004c9a:	ffffc097          	auipc	ra,0xffffc
    80004c9e:	3b8080e7          	jalr	952(ra) # 80001052 <walkaddr>
    80004ca2:	862a                	mv	a2,a0
    if(pa == 0)
    80004ca4:	dd45                	beqz	a0,80004c5c <exec+0xfe>
      n = PGSIZE;
    80004ca6:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004ca8:	fd49f2e3          	bgeu	s3,s4,80004c6c <exec+0x10e>
      n = sz - i;
    80004cac:	894e                	mv	s2,s3
    80004cae:	bf7d                	j	80004c6c <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cb0:	4481                	li	s1,0
  iunlockput(ip);
    80004cb2:	8556                	mv	a0,s5
    80004cb4:	fffff097          	auipc	ra,0xfffff
    80004cb8:	c14080e7          	jalr	-1004(ra) # 800038c8 <iunlockput>
  end_op();
    80004cbc:	fffff097          	auipc	ra,0xfffff
    80004cc0:	404080e7          	jalr	1028(ra) # 800040c0 <end_op>
  p = myproc();
    80004cc4:	ffffd097          	auipc	ra,0xffffd
    80004cc8:	cd2080e7          	jalr	-814(ra) # 80001996 <myproc>
    80004ccc:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004cce:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004cd2:	6785                	lui	a5,0x1
    80004cd4:	17fd                	addi	a5,a5,-1
    80004cd6:	97a6                	add	a5,a5,s1
    80004cd8:	777d                	lui	a4,0xfffff
    80004cda:	8ff9                	and	a5,a5,a4
    80004cdc:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004ce0:	6609                	lui	a2,0x2
    80004ce2:	963e                	add	a2,a2,a5
    80004ce4:	85be                	mv	a1,a5
    80004ce6:	855a                	mv	a0,s6
    80004ce8:	ffffc097          	auipc	ra,0xffffc
    80004cec:	71e080e7          	jalr	1822(ra) # 80001406 <uvmalloc>
    80004cf0:	8c2a                	mv	s8,a0
  ip = 0;
    80004cf2:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004cf4:	12050e63          	beqz	a0,80004e30 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004cf8:	75f9                	lui	a1,0xffffe
    80004cfa:	95aa                	add	a1,a1,a0
    80004cfc:	855a                	mv	a0,s6
    80004cfe:	ffffd097          	auipc	ra,0xffffd
    80004d02:	92a080e7          	jalr	-1750(ra) # 80001628 <uvmclear>
  stackbase = sp - PGSIZE;
    80004d06:	7afd                	lui	s5,0xfffff
    80004d08:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d0a:	df043783          	ld	a5,-528(s0)
    80004d0e:	6388                	ld	a0,0(a5)
    80004d10:	c925                	beqz	a0,80004d80 <exec+0x222>
    80004d12:	e9040993          	addi	s3,s0,-368
    80004d16:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004d1a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d1c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d1e:	ffffc097          	auipc	ra,0xffffc
    80004d22:	12a080e7          	jalr	298(ra) # 80000e48 <strlen>
    80004d26:	0015079b          	addiw	a5,a0,1
    80004d2a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d2e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004d32:	13596363          	bltu	s2,s5,80004e58 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d36:	df043d83          	ld	s11,-528(s0)
    80004d3a:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004d3e:	8552                	mv	a0,s4
    80004d40:	ffffc097          	auipc	ra,0xffffc
    80004d44:	108080e7          	jalr	264(ra) # 80000e48 <strlen>
    80004d48:	0015069b          	addiw	a3,a0,1
    80004d4c:	8652                	mv	a2,s4
    80004d4e:	85ca                	mv	a1,s2
    80004d50:	855a                	mv	a0,s6
    80004d52:	ffffd097          	auipc	ra,0xffffd
    80004d56:	908080e7          	jalr	-1784(ra) # 8000165a <copyout>
    80004d5a:	10054363          	bltz	a0,80004e60 <exec+0x302>
    ustack[argc] = sp;
    80004d5e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004d62:	0485                	addi	s1,s1,1
    80004d64:	008d8793          	addi	a5,s11,8
    80004d68:	def43823          	sd	a5,-528(s0)
    80004d6c:	008db503          	ld	a0,8(s11)
    80004d70:	c911                	beqz	a0,80004d84 <exec+0x226>
    if(argc >= MAXARG)
    80004d72:	09a1                	addi	s3,s3,8
    80004d74:	fb3c95e3          	bne	s9,s3,80004d1e <exec+0x1c0>
  sz = sz1;
    80004d78:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004d7c:	4a81                	li	s5,0
    80004d7e:	a84d                	j	80004e30 <exec+0x2d2>
  sp = sz;
    80004d80:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d82:	4481                	li	s1,0
  ustack[argc] = 0;
    80004d84:	00349793          	slli	a5,s1,0x3
    80004d88:	f9078793          	addi	a5,a5,-112 # f90 <_entry-0x7ffff070>
    80004d8c:	97a2                	add	a5,a5,s0
    80004d8e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004d92:	00148693          	addi	a3,s1,1
    80004d96:	068e                	slli	a3,a3,0x3
    80004d98:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004d9c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004da0:	01597663          	bgeu	s2,s5,80004dac <exec+0x24e>
  sz = sz1;
    80004da4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004da8:	4a81                	li	s5,0
    80004daa:	a059                	j	80004e30 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004dac:	e9040613          	addi	a2,s0,-368
    80004db0:	85ca                	mv	a1,s2
    80004db2:	855a                	mv	a0,s6
    80004db4:	ffffd097          	auipc	ra,0xffffd
    80004db8:	8a6080e7          	jalr	-1882(ra) # 8000165a <copyout>
    80004dbc:	0a054663          	bltz	a0,80004e68 <exec+0x30a>
  p->trapframe->a1 = sp;
    80004dc0:	058bb783          	ld	a5,88(s7)
    80004dc4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004dc8:	de843783          	ld	a5,-536(s0)
    80004dcc:	0007c703          	lbu	a4,0(a5)
    80004dd0:	cf11                	beqz	a4,80004dec <exec+0x28e>
    80004dd2:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004dd4:	02f00693          	li	a3,47
    80004dd8:	a039                	j	80004de6 <exec+0x288>
      last = s+1;
    80004dda:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004dde:	0785                	addi	a5,a5,1
    80004de0:	fff7c703          	lbu	a4,-1(a5)
    80004de4:	c701                	beqz	a4,80004dec <exec+0x28e>
    if(*s == '/')
    80004de6:	fed71ce3          	bne	a4,a3,80004dde <exec+0x280>
    80004dea:	bfc5                	j	80004dda <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004dec:	4641                	li	a2,16
    80004dee:	de843583          	ld	a1,-536(s0)
    80004df2:	158b8513          	addi	a0,s7,344
    80004df6:	ffffc097          	auipc	ra,0xffffc
    80004dfa:	020080e7          	jalr	32(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004dfe:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004e02:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004e06:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e0a:	058bb783          	ld	a5,88(s7)
    80004e0e:	e6843703          	ld	a4,-408(s0)
    80004e12:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e14:	058bb783          	ld	a5,88(s7)
    80004e18:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e1c:	85ea                	mv	a1,s10
    80004e1e:	ffffd097          	auipc	ra,0xffffd
    80004e22:	cd8080e7          	jalr	-808(ra) # 80001af6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e26:	0004851b          	sext.w	a0,s1
    80004e2a:	bbc1                	j	80004bfa <exec+0x9c>
    80004e2c:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004e30:	df843583          	ld	a1,-520(s0)
    80004e34:	855a                	mv	a0,s6
    80004e36:	ffffd097          	auipc	ra,0xffffd
    80004e3a:	cc0080e7          	jalr	-832(ra) # 80001af6 <proc_freepagetable>
  if(ip){
    80004e3e:	da0a94e3          	bnez	s5,80004be6 <exec+0x88>
  return -1;
    80004e42:	557d                	li	a0,-1
    80004e44:	bb5d                	j	80004bfa <exec+0x9c>
    80004e46:	de943c23          	sd	s1,-520(s0)
    80004e4a:	b7dd                	j	80004e30 <exec+0x2d2>
    80004e4c:	de943c23          	sd	s1,-520(s0)
    80004e50:	b7c5                	j	80004e30 <exec+0x2d2>
    80004e52:	de943c23          	sd	s1,-520(s0)
    80004e56:	bfe9                	j	80004e30 <exec+0x2d2>
  sz = sz1;
    80004e58:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e5c:	4a81                	li	s5,0
    80004e5e:	bfc9                	j	80004e30 <exec+0x2d2>
  sz = sz1;
    80004e60:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e64:	4a81                	li	s5,0
    80004e66:	b7e9                	j	80004e30 <exec+0x2d2>
  sz = sz1;
    80004e68:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e6c:	4a81                	li	s5,0
    80004e6e:	b7c9                	j	80004e30 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004e70:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e74:	e0843783          	ld	a5,-504(s0)
    80004e78:	0017869b          	addiw	a3,a5,1
    80004e7c:	e0d43423          	sd	a3,-504(s0)
    80004e80:	e0043783          	ld	a5,-512(s0)
    80004e84:	0387879b          	addiw	a5,a5,56
    80004e88:	e8845703          	lhu	a4,-376(s0)
    80004e8c:	e2e6d3e3          	bge	a3,a4,80004cb2 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e90:	2781                	sext.w	a5,a5
    80004e92:	e0f43023          	sd	a5,-512(s0)
    80004e96:	03800713          	li	a4,56
    80004e9a:	86be                	mv	a3,a5
    80004e9c:	e1840613          	addi	a2,s0,-488
    80004ea0:	4581                	li	a1,0
    80004ea2:	8556                	mv	a0,s5
    80004ea4:	fffff097          	auipc	ra,0xfffff
    80004ea8:	a76080e7          	jalr	-1418(ra) # 8000391a <readi>
    80004eac:	03800793          	li	a5,56
    80004eb0:	f6f51ee3          	bne	a0,a5,80004e2c <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80004eb4:	e1842783          	lw	a5,-488(s0)
    80004eb8:	4705                	li	a4,1
    80004eba:	fae79de3          	bne	a5,a4,80004e74 <exec+0x316>
    if(ph.memsz < ph.filesz)
    80004ebe:	e4043603          	ld	a2,-448(s0)
    80004ec2:	e3843783          	ld	a5,-456(s0)
    80004ec6:	f8f660e3          	bltu	a2,a5,80004e46 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004eca:	e2843783          	ld	a5,-472(s0)
    80004ece:	963e                	add	a2,a2,a5
    80004ed0:	f6f66ee3          	bltu	a2,a5,80004e4c <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004ed4:	85a6                	mv	a1,s1
    80004ed6:	855a                	mv	a0,s6
    80004ed8:	ffffc097          	auipc	ra,0xffffc
    80004edc:	52e080e7          	jalr	1326(ra) # 80001406 <uvmalloc>
    80004ee0:	dea43c23          	sd	a0,-520(s0)
    80004ee4:	d53d                	beqz	a0,80004e52 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    80004ee6:	e2843c03          	ld	s8,-472(s0)
    80004eea:	de043783          	ld	a5,-544(s0)
    80004eee:	00fc77b3          	and	a5,s8,a5
    80004ef2:	ff9d                	bnez	a5,80004e30 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ef4:	e2042c83          	lw	s9,-480(s0)
    80004ef8:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004efc:	f60b8ae3          	beqz	s7,80004e70 <exec+0x312>
    80004f00:	89de                	mv	s3,s7
    80004f02:	4481                	li	s1,0
    80004f04:	b371                	j	80004c90 <exec+0x132>

0000000080004f06 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f06:	7179                	addi	sp,sp,-48
    80004f08:	f406                	sd	ra,40(sp)
    80004f0a:	f022                	sd	s0,32(sp)
    80004f0c:	ec26                	sd	s1,24(sp)
    80004f0e:	e84a                	sd	s2,16(sp)
    80004f10:	1800                	addi	s0,sp,48
    80004f12:	892e                	mv	s2,a1
    80004f14:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004f16:	fdc40593          	addi	a1,s0,-36
    80004f1a:	ffffe097          	auipc	ra,0xffffe
    80004f1e:	bc2080e7          	jalr	-1086(ra) # 80002adc <argint>
    80004f22:	04054063          	bltz	a0,80004f62 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f26:	fdc42703          	lw	a4,-36(s0)
    80004f2a:	47bd                	li	a5,15
    80004f2c:	02e7ed63          	bltu	a5,a4,80004f66 <argfd+0x60>
    80004f30:	ffffd097          	auipc	ra,0xffffd
    80004f34:	a66080e7          	jalr	-1434(ra) # 80001996 <myproc>
    80004f38:	fdc42703          	lw	a4,-36(s0)
    80004f3c:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd901a>
    80004f40:	078e                	slli	a5,a5,0x3
    80004f42:	953e                	add	a0,a0,a5
    80004f44:	611c                	ld	a5,0(a0)
    80004f46:	c395                	beqz	a5,80004f6a <argfd+0x64>
    return -1;
  if(pfd)
    80004f48:	00090463          	beqz	s2,80004f50 <argfd+0x4a>
    *pfd = fd;
    80004f4c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f50:	4501                	li	a0,0
  if(pf)
    80004f52:	c091                	beqz	s1,80004f56 <argfd+0x50>
    *pf = f;
    80004f54:	e09c                	sd	a5,0(s1)
}
    80004f56:	70a2                	ld	ra,40(sp)
    80004f58:	7402                	ld	s0,32(sp)
    80004f5a:	64e2                	ld	s1,24(sp)
    80004f5c:	6942                	ld	s2,16(sp)
    80004f5e:	6145                	addi	sp,sp,48
    80004f60:	8082                	ret
    return -1;
    80004f62:	557d                	li	a0,-1
    80004f64:	bfcd                	j	80004f56 <argfd+0x50>
    return -1;
    80004f66:	557d                	li	a0,-1
    80004f68:	b7fd                	j	80004f56 <argfd+0x50>
    80004f6a:	557d                	li	a0,-1
    80004f6c:	b7ed                	j	80004f56 <argfd+0x50>

0000000080004f6e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f6e:	1101                	addi	sp,sp,-32
    80004f70:	ec06                	sd	ra,24(sp)
    80004f72:	e822                	sd	s0,16(sp)
    80004f74:	e426                	sd	s1,8(sp)
    80004f76:	1000                	addi	s0,sp,32
    80004f78:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f7a:	ffffd097          	auipc	ra,0xffffd
    80004f7e:	a1c080e7          	jalr	-1508(ra) # 80001996 <myproc>
    80004f82:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f84:	0d050793          	addi	a5,a0,208
    80004f88:	4501                	li	a0,0
    80004f8a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f8c:	6398                	ld	a4,0(a5)
    80004f8e:	cb19                	beqz	a4,80004fa4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f90:	2505                	addiw	a0,a0,1
    80004f92:	07a1                	addi	a5,a5,8
    80004f94:	fed51ce3          	bne	a0,a3,80004f8c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f98:	557d                	li	a0,-1
}
    80004f9a:	60e2                	ld	ra,24(sp)
    80004f9c:	6442                	ld	s0,16(sp)
    80004f9e:	64a2                	ld	s1,8(sp)
    80004fa0:	6105                	addi	sp,sp,32
    80004fa2:	8082                	ret
      p->ofile[fd] = f;
    80004fa4:	01a50793          	addi	a5,a0,26
    80004fa8:	078e                	slli	a5,a5,0x3
    80004faa:	963e                	add	a2,a2,a5
    80004fac:	e204                	sd	s1,0(a2)
      return fd;
    80004fae:	b7f5                	j	80004f9a <fdalloc+0x2c>

0000000080004fb0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004fb0:	715d                	addi	sp,sp,-80
    80004fb2:	e486                	sd	ra,72(sp)
    80004fb4:	e0a2                	sd	s0,64(sp)
    80004fb6:	fc26                	sd	s1,56(sp)
    80004fb8:	f84a                	sd	s2,48(sp)
    80004fba:	f44e                	sd	s3,40(sp)
    80004fbc:	f052                	sd	s4,32(sp)
    80004fbe:	ec56                	sd	s5,24(sp)
    80004fc0:	0880                	addi	s0,sp,80
    80004fc2:	89ae                	mv	s3,a1
    80004fc4:	8ab2                	mv	s5,a2
    80004fc6:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004fc8:	fb040593          	addi	a1,s0,-80
    80004fcc:	fffff097          	auipc	ra,0xfffff
    80004fd0:	e74080e7          	jalr	-396(ra) # 80003e40 <nameiparent>
    80004fd4:	892a                	mv	s2,a0
    80004fd6:	12050e63          	beqz	a0,80005112 <create+0x162>
    return 0;

  ilock(dp);
    80004fda:	ffffe097          	auipc	ra,0xffffe
    80004fde:	68c080e7          	jalr	1676(ra) # 80003666 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004fe2:	4601                	li	a2,0
    80004fe4:	fb040593          	addi	a1,s0,-80
    80004fe8:	854a                	mv	a0,s2
    80004fea:	fffff097          	auipc	ra,0xfffff
    80004fee:	b60080e7          	jalr	-1184(ra) # 80003b4a <dirlookup>
    80004ff2:	84aa                	mv	s1,a0
    80004ff4:	c921                	beqz	a0,80005044 <create+0x94>
    iunlockput(dp);
    80004ff6:	854a                	mv	a0,s2
    80004ff8:	fffff097          	auipc	ra,0xfffff
    80004ffc:	8d0080e7          	jalr	-1840(ra) # 800038c8 <iunlockput>
    ilock(ip);
    80005000:	8526                	mv	a0,s1
    80005002:	ffffe097          	auipc	ra,0xffffe
    80005006:	664080e7          	jalr	1636(ra) # 80003666 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000500a:	2981                	sext.w	s3,s3
    8000500c:	4789                	li	a5,2
    8000500e:	02f99463          	bne	s3,a5,80005036 <create+0x86>
    80005012:	0444d783          	lhu	a5,68(s1)
    80005016:	37f9                	addiw	a5,a5,-2
    80005018:	17c2                	slli	a5,a5,0x30
    8000501a:	93c1                	srli	a5,a5,0x30
    8000501c:	4705                	li	a4,1
    8000501e:	00f76c63          	bltu	a4,a5,80005036 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005022:	8526                	mv	a0,s1
    80005024:	60a6                	ld	ra,72(sp)
    80005026:	6406                	ld	s0,64(sp)
    80005028:	74e2                	ld	s1,56(sp)
    8000502a:	7942                	ld	s2,48(sp)
    8000502c:	79a2                	ld	s3,40(sp)
    8000502e:	7a02                	ld	s4,32(sp)
    80005030:	6ae2                	ld	s5,24(sp)
    80005032:	6161                	addi	sp,sp,80
    80005034:	8082                	ret
    iunlockput(ip);
    80005036:	8526                	mv	a0,s1
    80005038:	fffff097          	auipc	ra,0xfffff
    8000503c:	890080e7          	jalr	-1904(ra) # 800038c8 <iunlockput>
    return 0;
    80005040:	4481                	li	s1,0
    80005042:	b7c5                	j	80005022 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005044:	85ce                	mv	a1,s3
    80005046:	00092503          	lw	a0,0(s2)
    8000504a:	ffffe097          	auipc	ra,0xffffe
    8000504e:	482080e7          	jalr	1154(ra) # 800034cc <ialloc>
    80005052:	84aa                	mv	s1,a0
    80005054:	c521                	beqz	a0,8000509c <create+0xec>
  ilock(ip);
    80005056:	ffffe097          	auipc	ra,0xffffe
    8000505a:	610080e7          	jalr	1552(ra) # 80003666 <ilock>
  ip->major = major;
    8000505e:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005062:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005066:	4a05                	li	s4,1
    80005068:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000506c:	8526                	mv	a0,s1
    8000506e:	ffffe097          	auipc	ra,0xffffe
    80005072:	52c080e7          	jalr	1324(ra) # 8000359a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005076:	2981                	sext.w	s3,s3
    80005078:	03498a63          	beq	s3,s4,800050ac <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000507c:	40d0                	lw	a2,4(s1)
    8000507e:	fb040593          	addi	a1,s0,-80
    80005082:	854a                	mv	a0,s2
    80005084:	fffff097          	auipc	ra,0xfffff
    80005088:	cdc080e7          	jalr	-804(ra) # 80003d60 <dirlink>
    8000508c:	06054b63          	bltz	a0,80005102 <create+0x152>
  iunlockput(dp);
    80005090:	854a                	mv	a0,s2
    80005092:	fffff097          	auipc	ra,0xfffff
    80005096:	836080e7          	jalr	-1994(ra) # 800038c8 <iunlockput>
  return ip;
    8000509a:	b761                	j	80005022 <create+0x72>
    panic("create: ialloc");
    8000509c:	00003517          	auipc	a0,0x3
    800050a0:	66c50513          	addi	a0,a0,1644 # 80008708 <syscalls+0x2a8>
    800050a4:	ffffb097          	auipc	ra,0xffffb
    800050a8:	496080e7          	jalr	1174(ra) # 8000053a <panic>
    dp->nlink++;  // for ".."
    800050ac:	04a95783          	lhu	a5,74(s2)
    800050b0:	2785                	addiw	a5,a5,1
    800050b2:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800050b6:	854a                	mv	a0,s2
    800050b8:	ffffe097          	auipc	ra,0xffffe
    800050bc:	4e2080e7          	jalr	1250(ra) # 8000359a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050c0:	40d0                	lw	a2,4(s1)
    800050c2:	00003597          	auipc	a1,0x3
    800050c6:	65658593          	addi	a1,a1,1622 # 80008718 <syscalls+0x2b8>
    800050ca:	8526                	mv	a0,s1
    800050cc:	fffff097          	auipc	ra,0xfffff
    800050d0:	c94080e7          	jalr	-876(ra) # 80003d60 <dirlink>
    800050d4:	00054f63          	bltz	a0,800050f2 <create+0x142>
    800050d8:	00492603          	lw	a2,4(s2)
    800050dc:	00003597          	auipc	a1,0x3
    800050e0:	64458593          	addi	a1,a1,1604 # 80008720 <syscalls+0x2c0>
    800050e4:	8526                	mv	a0,s1
    800050e6:	fffff097          	auipc	ra,0xfffff
    800050ea:	c7a080e7          	jalr	-902(ra) # 80003d60 <dirlink>
    800050ee:	f80557e3          	bgez	a0,8000507c <create+0xcc>
      panic("create dots");
    800050f2:	00003517          	auipc	a0,0x3
    800050f6:	63650513          	addi	a0,a0,1590 # 80008728 <syscalls+0x2c8>
    800050fa:	ffffb097          	auipc	ra,0xffffb
    800050fe:	440080e7          	jalr	1088(ra) # 8000053a <panic>
    panic("create: dirlink");
    80005102:	00003517          	auipc	a0,0x3
    80005106:	63650513          	addi	a0,a0,1590 # 80008738 <syscalls+0x2d8>
    8000510a:	ffffb097          	auipc	ra,0xffffb
    8000510e:	430080e7          	jalr	1072(ra) # 8000053a <panic>
    return 0;
    80005112:	84aa                	mv	s1,a0
    80005114:	b739                	j	80005022 <create+0x72>

0000000080005116 <sys_dup>:
{
    80005116:	7179                	addi	sp,sp,-48
    80005118:	f406                	sd	ra,40(sp)
    8000511a:	f022                	sd	s0,32(sp)
    8000511c:	ec26                	sd	s1,24(sp)
    8000511e:	e84a                	sd	s2,16(sp)
    80005120:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005122:	fd840613          	addi	a2,s0,-40
    80005126:	4581                	li	a1,0
    80005128:	4501                	li	a0,0
    8000512a:	00000097          	auipc	ra,0x0
    8000512e:	ddc080e7          	jalr	-548(ra) # 80004f06 <argfd>
    return -1;
    80005132:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005134:	02054363          	bltz	a0,8000515a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005138:	fd843903          	ld	s2,-40(s0)
    8000513c:	854a                	mv	a0,s2
    8000513e:	00000097          	auipc	ra,0x0
    80005142:	e30080e7          	jalr	-464(ra) # 80004f6e <fdalloc>
    80005146:	84aa                	mv	s1,a0
    return -1;
    80005148:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000514a:	00054863          	bltz	a0,8000515a <sys_dup+0x44>
  filedup(f);
    8000514e:	854a                	mv	a0,s2
    80005150:	fffff097          	auipc	ra,0xfffff
    80005154:	368080e7          	jalr	872(ra) # 800044b8 <filedup>
  return fd;
    80005158:	87a6                	mv	a5,s1
}
    8000515a:	853e                	mv	a0,a5
    8000515c:	70a2                	ld	ra,40(sp)
    8000515e:	7402                	ld	s0,32(sp)
    80005160:	64e2                	ld	s1,24(sp)
    80005162:	6942                	ld	s2,16(sp)
    80005164:	6145                	addi	sp,sp,48
    80005166:	8082                	ret

0000000080005168 <sys_read>:
{
    80005168:	7179                	addi	sp,sp,-48
    8000516a:	f406                	sd	ra,40(sp)
    8000516c:	f022                	sd	s0,32(sp)
    8000516e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005170:	fe840613          	addi	a2,s0,-24
    80005174:	4581                	li	a1,0
    80005176:	4501                	li	a0,0
    80005178:	00000097          	auipc	ra,0x0
    8000517c:	d8e080e7          	jalr	-626(ra) # 80004f06 <argfd>
    return -1;
    80005180:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005182:	04054163          	bltz	a0,800051c4 <sys_read+0x5c>
    80005186:	fe440593          	addi	a1,s0,-28
    8000518a:	4509                	li	a0,2
    8000518c:	ffffe097          	auipc	ra,0xffffe
    80005190:	950080e7          	jalr	-1712(ra) # 80002adc <argint>
    return -1;
    80005194:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005196:	02054763          	bltz	a0,800051c4 <sys_read+0x5c>
    8000519a:	fd840593          	addi	a1,s0,-40
    8000519e:	4505                	li	a0,1
    800051a0:	ffffe097          	auipc	ra,0xffffe
    800051a4:	95e080e7          	jalr	-1698(ra) # 80002afe <argaddr>
    return -1;
    800051a8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051aa:	00054d63          	bltz	a0,800051c4 <sys_read+0x5c>
  return fileread(f, p, n);
    800051ae:	fe442603          	lw	a2,-28(s0)
    800051b2:	fd843583          	ld	a1,-40(s0)
    800051b6:	fe843503          	ld	a0,-24(s0)
    800051ba:	fffff097          	auipc	ra,0xfffff
    800051be:	48a080e7          	jalr	1162(ra) # 80004644 <fileread>
    800051c2:	87aa                	mv	a5,a0
}
    800051c4:	853e                	mv	a0,a5
    800051c6:	70a2                	ld	ra,40(sp)
    800051c8:	7402                	ld	s0,32(sp)
    800051ca:	6145                	addi	sp,sp,48
    800051cc:	8082                	ret

00000000800051ce <sys_write>:
{
    800051ce:	7179                	addi	sp,sp,-48
    800051d0:	f406                	sd	ra,40(sp)
    800051d2:	f022                	sd	s0,32(sp)
    800051d4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051d6:	fe840613          	addi	a2,s0,-24
    800051da:	4581                	li	a1,0
    800051dc:	4501                	li	a0,0
    800051de:	00000097          	auipc	ra,0x0
    800051e2:	d28080e7          	jalr	-728(ra) # 80004f06 <argfd>
    return -1;
    800051e6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051e8:	04054163          	bltz	a0,8000522a <sys_write+0x5c>
    800051ec:	fe440593          	addi	a1,s0,-28
    800051f0:	4509                	li	a0,2
    800051f2:	ffffe097          	auipc	ra,0xffffe
    800051f6:	8ea080e7          	jalr	-1814(ra) # 80002adc <argint>
    return -1;
    800051fa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051fc:	02054763          	bltz	a0,8000522a <sys_write+0x5c>
    80005200:	fd840593          	addi	a1,s0,-40
    80005204:	4505                	li	a0,1
    80005206:	ffffe097          	auipc	ra,0xffffe
    8000520a:	8f8080e7          	jalr	-1800(ra) # 80002afe <argaddr>
    return -1;
    8000520e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005210:	00054d63          	bltz	a0,8000522a <sys_write+0x5c>
  return filewrite(f, p, n);
    80005214:	fe442603          	lw	a2,-28(s0)
    80005218:	fd843583          	ld	a1,-40(s0)
    8000521c:	fe843503          	ld	a0,-24(s0)
    80005220:	fffff097          	auipc	ra,0xfffff
    80005224:	4e6080e7          	jalr	1254(ra) # 80004706 <filewrite>
    80005228:	87aa                	mv	a5,a0
}
    8000522a:	853e                	mv	a0,a5
    8000522c:	70a2                	ld	ra,40(sp)
    8000522e:	7402                	ld	s0,32(sp)
    80005230:	6145                	addi	sp,sp,48
    80005232:	8082                	ret

0000000080005234 <sys_close>:
{
    80005234:	1101                	addi	sp,sp,-32
    80005236:	ec06                	sd	ra,24(sp)
    80005238:	e822                	sd	s0,16(sp)
    8000523a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000523c:	fe040613          	addi	a2,s0,-32
    80005240:	fec40593          	addi	a1,s0,-20
    80005244:	4501                	li	a0,0
    80005246:	00000097          	auipc	ra,0x0
    8000524a:	cc0080e7          	jalr	-832(ra) # 80004f06 <argfd>
    return -1;
    8000524e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005250:	02054463          	bltz	a0,80005278 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005254:	ffffc097          	auipc	ra,0xffffc
    80005258:	742080e7          	jalr	1858(ra) # 80001996 <myproc>
    8000525c:	fec42783          	lw	a5,-20(s0)
    80005260:	07e9                	addi	a5,a5,26
    80005262:	078e                	slli	a5,a5,0x3
    80005264:	953e                	add	a0,a0,a5
    80005266:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000526a:	fe043503          	ld	a0,-32(s0)
    8000526e:	fffff097          	auipc	ra,0xfffff
    80005272:	29c080e7          	jalr	668(ra) # 8000450a <fileclose>
  return 0;
    80005276:	4781                	li	a5,0
}
    80005278:	853e                	mv	a0,a5
    8000527a:	60e2                	ld	ra,24(sp)
    8000527c:	6442                	ld	s0,16(sp)
    8000527e:	6105                	addi	sp,sp,32
    80005280:	8082                	ret

0000000080005282 <sys_fstat>:
{
    80005282:	1101                	addi	sp,sp,-32
    80005284:	ec06                	sd	ra,24(sp)
    80005286:	e822                	sd	s0,16(sp)
    80005288:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000528a:	fe840613          	addi	a2,s0,-24
    8000528e:	4581                	li	a1,0
    80005290:	4501                	li	a0,0
    80005292:	00000097          	auipc	ra,0x0
    80005296:	c74080e7          	jalr	-908(ra) # 80004f06 <argfd>
    return -1;
    8000529a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000529c:	02054563          	bltz	a0,800052c6 <sys_fstat+0x44>
    800052a0:	fe040593          	addi	a1,s0,-32
    800052a4:	4505                	li	a0,1
    800052a6:	ffffe097          	auipc	ra,0xffffe
    800052aa:	858080e7          	jalr	-1960(ra) # 80002afe <argaddr>
    return -1;
    800052ae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052b0:	00054b63          	bltz	a0,800052c6 <sys_fstat+0x44>
  return filestat(f, st);
    800052b4:	fe043583          	ld	a1,-32(s0)
    800052b8:	fe843503          	ld	a0,-24(s0)
    800052bc:	fffff097          	auipc	ra,0xfffff
    800052c0:	316080e7          	jalr	790(ra) # 800045d2 <filestat>
    800052c4:	87aa                	mv	a5,a0
}
    800052c6:	853e                	mv	a0,a5
    800052c8:	60e2                	ld	ra,24(sp)
    800052ca:	6442                	ld	s0,16(sp)
    800052cc:	6105                	addi	sp,sp,32
    800052ce:	8082                	ret

00000000800052d0 <sys_link>:
{
    800052d0:	7169                	addi	sp,sp,-304
    800052d2:	f606                	sd	ra,296(sp)
    800052d4:	f222                	sd	s0,288(sp)
    800052d6:	ee26                	sd	s1,280(sp)
    800052d8:	ea4a                	sd	s2,272(sp)
    800052da:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052dc:	08000613          	li	a2,128
    800052e0:	ed040593          	addi	a1,s0,-304
    800052e4:	4501                	li	a0,0
    800052e6:	ffffe097          	auipc	ra,0xffffe
    800052ea:	83a080e7          	jalr	-1990(ra) # 80002b20 <argstr>
    return -1;
    800052ee:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052f0:	10054e63          	bltz	a0,8000540c <sys_link+0x13c>
    800052f4:	08000613          	li	a2,128
    800052f8:	f5040593          	addi	a1,s0,-176
    800052fc:	4505                	li	a0,1
    800052fe:	ffffe097          	auipc	ra,0xffffe
    80005302:	822080e7          	jalr	-2014(ra) # 80002b20 <argstr>
    return -1;
    80005306:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005308:	10054263          	bltz	a0,8000540c <sys_link+0x13c>
  begin_op();
    8000530c:	fffff097          	auipc	ra,0xfffff
    80005310:	d36080e7          	jalr	-714(ra) # 80004042 <begin_op>
  if((ip = namei(old)) == 0){
    80005314:	ed040513          	addi	a0,s0,-304
    80005318:	fffff097          	auipc	ra,0xfffff
    8000531c:	b0a080e7          	jalr	-1270(ra) # 80003e22 <namei>
    80005320:	84aa                	mv	s1,a0
    80005322:	c551                	beqz	a0,800053ae <sys_link+0xde>
  ilock(ip);
    80005324:	ffffe097          	auipc	ra,0xffffe
    80005328:	342080e7          	jalr	834(ra) # 80003666 <ilock>
  if(ip->type == T_DIR){
    8000532c:	04449703          	lh	a4,68(s1)
    80005330:	4785                	li	a5,1
    80005332:	08f70463          	beq	a4,a5,800053ba <sys_link+0xea>
  ip->nlink++;
    80005336:	04a4d783          	lhu	a5,74(s1)
    8000533a:	2785                	addiw	a5,a5,1
    8000533c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005340:	8526                	mv	a0,s1
    80005342:	ffffe097          	auipc	ra,0xffffe
    80005346:	258080e7          	jalr	600(ra) # 8000359a <iupdate>
  iunlock(ip);
    8000534a:	8526                	mv	a0,s1
    8000534c:	ffffe097          	auipc	ra,0xffffe
    80005350:	3dc080e7          	jalr	988(ra) # 80003728 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005354:	fd040593          	addi	a1,s0,-48
    80005358:	f5040513          	addi	a0,s0,-176
    8000535c:	fffff097          	auipc	ra,0xfffff
    80005360:	ae4080e7          	jalr	-1308(ra) # 80003e40 <nameiparent>
    80005364:	892a                	mv	s2,a0
    80005366:	c935                	beqz	a0,800053da <sys_link+0x10a>
  ilock(dp);
    80005368:	ffffe097          	auipc	ra,0xffffe
    8000536c:	2fe080e7          	jalr	766(ra) # 80003666 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005370:	00092703          	lw	a4,0(s2)
    80005374:	409c                	lw	a5,0(s1)
    80005376:	04f71d63          	bne	a4,a5,800053d0 <sys_link+0x100>
    8000537a:	40d0                	lw	a2,4(s1)
    8000537c:	fd040593          	addi	a1,s0,-48
    80005380:	854a                	mv	a0,s2
    80005382:	fffff097          	auipc	ra,0xfffff
    80005386:	9de080e7          	jalr	-1570(ra) # 80003d60 <dirlink>
    8000538a:	04054363          	bltz	a0,800053d0 <sys_link+0x100>
  iunlockput(dp);
    8000538e:	854a                	mv	a0,s2
    80005390:	ffffe097          	auipc	ra,0xffffe
    80005394:	538080e7          	jalr	1336(ra) # 800038c8 <iunlockput>
  iput(ip);
    80005398:	8526                	mv	a0,s1
    8000539a:	ffffe097          	auipc	ra,0xffffe
    8000539e:	486080e7          	jalr	1158(ra) # 80003820 <iput>
  end_op();
    800053a2:	fffff097          	auipc	ra,0xfffff
    800053a6:	d1e080e7          	jalr	-738(ra) # 800040c0 <end_op>
  return 0;
    800053aa:	4781                	li	a5,0
    800053ac:	a085                	j	8000540c <sys_link+0x13c>
    end_op();
    800053ae:	fffff097          	auipc	ra,0xfffff
    800053b2:	d12080e7          	jalr	-750(ra) # 800040c0 <end_op>
    return -1;
    800053b6:	57fd                	li	a5,-1
    800053b8:	a891                	j	8000540c <sys_link+0x13c>
    iunlockput(ip);
    800053ba:	8526                	mv	a0,s1
    800053bc:	ffffe097          	auipc	ra,0xffffe
    800053c0:	50c080e7          	jalr	1292(ra) # 800038c8 <iunlockput>
    end_op();
    800053c4:	fffff097          	auipc	ra,0xfffff
    800053c8:	cfc080e7          	jalr	-772(ra) # 800040c0 <end_op>
    return -1;
    800053cc:	57fd                	li	a5,-1
    800053ce:	a83d                	j	8000540c <sys_link+0x13c>
    iunlockput(dp);
    800053d0:	854a                	mv	a0,s2
    800053d2:	ffffe097          	auipc	ra,0xffffe
    800053d6:	4f6080e7          	jalr	1270(ra) # 800038c8 <iunlockput>
  ilock(ip);
    800053da:	8526                	mv	a0,s1
    800053dc:	ffffe097          	auipc	ra,0xffffe
    800053e0:	28a080e7          	jalr	650(ra) # 80003666 <ilock>
  ip->nlink--;
    800053e4:	04a4d783          	lhu	a5,74(s1)
    800053e8:	37fd                	addiw	a5,a5,-1
    800053ea:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053ee:	8526                	mv	a0,s1
    800053f0:	ffffe097          	auipc	ra,0xffffe
    800053f4:	1aa080e7          	jalr	426(ra) # 8000359a <iupdate>
  iunlockput(ip);
    800053f8:	8526                	mv	a0,s1
    800053fa:	ffffe097          	auipc	ra,0xffffe
    800053fe:	4ce080e7          	jalr	1230(ra) # 800038c8 <iunlockput>
  end_op();
    80005402:	fffff097          	auipc	ra,0xfffff
    80005406:	cbe080e7          	jalr	-834(ra) # 800040c0 <end_op>
  return -1;
    8000540a:	57fd                	li	a5,-1
}
    8000540c:	853e                	mv	a0,a5
    8000540e:	70b2                	ld	ra,296(sp)
    80005410:	7412                	ld	s0,288(sp)
    80005412:	64f2                	ld	s1,280(sp)
    80005414:	6952                	ld	s2,272(sp)
    80005416:	6155                	addi	sp,sp,304
    80005418:	8082                	ret

000000008000541a <sys_unlink>:
{
    8000541a:	7151                	addi	sp,sp,-240
    8000541c:	f586                	sd	ra,232(sp)
    8000541e:	f1a2                	sd	s0,224(sp)
    80005420:	eda6                	sd	s1,216(sp)
    80005422:	e9ca                	sd	s2,208(sp)
    80005424:	e5ce                	sd	s3,200(sp)
    80005426:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005428:	08000613          	li	a2,128
    8000542c:	f3040593          	addi	a1,s0,-208
    80005430:	4501                	li	a0,0
    80005432:	ffffd097          	auipc	ra,0xffffd
    80005436:	6ee080e7          	jalr	1774(ra) # 80002b20 <argstr>
    8000543a:	18054163          	bltz	a0,800055bc <sys_unlink+0x1a2>
  begin_op();
    8000543e:	fffff097          	auipc	ra,0xfffff
    80005442:	c04080e7          	jalr	-1020(ra) # 80004042 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005446:	fb040593          	addi	a1,s0,-80
    8000544a:	f3040513          	addi	a0,s0,-208
    8000544e:	fffff097          	auipc	ra,0xfffff
    80005452:	9f2080e7          	jalr	-1550(ra) # 80003e40 <nameiparent>
    80005456:	84aa                	mv	s1,a0
    80005458:	c979                	beqz	a0,8000552e <sys_unlink+0x114>
  ilock(dp);
    8000545a:	ffffe097          	auipc	ra,0xffffe
    8000545e:	20c080e7          	jalr	524(ra) # 80003666 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005462:	00003597          	auipc	a1,0x3
    80005466:	2b658593          	addi	a1,a1,694 # 80008718 <syscalls+0x2b8>
    8000546a:	fb040513          	addi	a0,s0,-80
    8000546e:	ffffe097          	auipc	ra,0xffffe
    80005472:	6c2080e7          	jalr	1730(ra) # 80003b30 <namecmp>
    80005476:	14050a63          	beqz	a0,800055ca <sys_unlink+0x1b0>
    8000547a:	00003597          	auipc	a1,0x3
    8000547e:	2a658593          	addi	a1,a1,678 # 80008720 <syscalls+0x2c0>
    80005482:	fb040513          	addi	a0,s0,-80
    80005486:	ffffe097          	auipc	ra,0xffffe
    8000548a:	6aa080e7          	jalr	1706(ra) # 80003b30 <namecmp>
    8000548e:	12050e63          	beqz	a0,800055ca <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005492:	f2c40613          	addi	a2,s0,-212
    80005496:	fb040593          	addi	a1,s0,-80
    8000549a:	8526                	mv	a0,s1
    8000549c:	ffffe097          	auipc	ra,0xffffe
    800054a0:	6ae080e7          	jalr	1710(ra) # 80003b4a <dirlookup>
    800054a4:	892a                	mv	s2,a0
    800054a6:	12050263          	beqz	a0,800055ca <sys_unlink+0x1b0>
  ilock(ip);
    800054aa:	ffffe097          	auipc	ra,0xffffe
    800054ae:	1bc080e7          	jalr	444(ra) # 80003666 <ilock>
  if(ip->nlink < 1)
    800054b2:	04a91783          	lh	a5,74(s2)
    800054b6:	08f05263          	blez	a5,8000553a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800054ba:	04491703          	lh	a4,68(s2)
    800054be:	4785                	li	a5,1
    800054c0:	08f70563          	beq	a4,a5,8000554a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800054c4:	4641                	li	a2,16
    800054c6:	4581                	li	a1,0
    800054c8:	fc040513          	addi	a0,s0,-64
    800054cc:	ffffc097          	auipc	ra,0xffffc
    800054d0:	800080e7          	jalr	-2048(ra) # 80000ccc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054d4:	4741                	li	a4,16
    800054d6:	f2c42683          	lw	a3,-212(s0)
    800054da:	fc040613          	addi	a2,s0,-64
    800054de:	4581                	li	a1,0
    800054e0:	8526                	mv	a0,s1
    800054e2:	ffffe097          	auipc	ra,0xffffe
    800054e6:	530080e7          	jalr	1328(ra) # 80003a12 <writei>
    800054ea:	47c1                	li	a5,16
    800054ec:	0af51563          	bne	a0,a5,80005596 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800054f0:	04491703          	lh	a4,68(s2)
    800054f4:	4785                	li	a5,1
    800054f6:	0af70863          	beq	a4,a5,800055a6 <sys_unlink+0x18c>
  iunlockput(dp);
    800054fa:	8526                	mv	a0,s1
    800054fc:	ffffe097          	auipc	ra,0xffffe
    80005500:	3cc080e7          	jalr	972(ra) # 800038c8 <iunlockput>
  ip->nlink--;
    80005504:	04a95783          	lhu	a5,74(s2)
    80005508:	37fd                	addiw	a5,a5,-1
    8000550a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000550e:	854a                	mv	a0,s2
    80005510:	ffffe097          	auipc	ra,0xffffe
    80005514:	08a080e7          	jalr	138(ra) # 8000359a <iupdate>
  iunlockput(ip);
    80005518:	854a                	mv	a0,s2
    8000551a:	ffffe097          	auipc	ra,0xffffe
    8000551e:	3ae080e7          	jalr	942(ra) # 800038c8 <iunlockput>
  end_op();
    80005522:	fffff097          	auipc	ra,0xfffff
    80005526:	b9e080e7          	jalr	-1122(ra) # 800040c0 <end_op>
  return 0;
    8000552a:	4501                	li	a0,0
    8000552c:	a84d                	j	800055de <sys_unlink+0x1c4>
    end_op();
    8000552e:	fffff097          	auipc	ra,0xfffff
    80005532:	b92080e7          	jalr	-1134(ra) # 800040c0 <end_op>
    return -1;
    80005536:	557d                	li	a0,-1
    80005538:	a05d                	j	800055de <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000553a:	00003517          	auipc	a0,0x3
    8000553e:	20e50513          	addi	a0,a0,526 # 80008748 <syscalls+0x2e8>
    80005542:	ffffb097          	auipc	ra,0xffffb
    80005546:	ff8080e7          	jalr	-8(ra) # 8000053a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000554a:	04c92703          	lw	a4,76(s2)
    8000554e:	02000793          	li	a5,32
    80005552:	f6e7f9e3          	bgeu	a5,a4,800054c4 <sys_unlink+0xaa>
    80005556:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000555a:	4741                	li	a4,16
    8000555c:	86ce                	mv	a3,s3
    8000555e:	f1840613          	addi	a2,s0,-232
    80005562:	4581                	li	a1,0
    80005564:	854a                	mv	a0,s2
    80005566:	ffffe097          	auipc	ra,0xffffe
    8000556a:	3b4080e7          	jalr	948(ra) # 8000391a <readi>
    8000556e:	47c1                	li	a5,16
    80005570:	00f51b63          	bne	a0,a5,80005586 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005574:	f1845783          	lhu	a5,-232(s0)
    80005578:	e7a1                	bnez	a5,800055c0 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000557a:	29c1                	addiw	s3,s3,16
    8000557c:	04c92783          	lw	a5,76(s2)
    80005580:	fcf9ede3          	bltu	s3,a5,8000555a <sys_unlink+0x140>
    80005584:	b781                	j	800054c4 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005586:	00003517          	auipc	a0,0x3
    8000558a:	1da50513          	addi	a0,a0,474 # 80008760 <syscalls+0x300>
    8000558e:	ffffb097          	auipc	ra,0xffffb
    80005592:	fac080e7          	jalr	-84(ra) # 8000053a <panic>
    panic("unlink: writei");
    80005596:	00003517          	auipc	a0,0x3
    8000559a:	1e250513          	addi	a0,a0,482 # 80008778 <syscalls+0x318>
    8000559e:	ffffb097          	auipc	ra,0xffffb
    800055a2:	f9c080e7          	jalr	-100(ra) # 8000053a <panic>
    dp->nlink--;
    800055a6:	04a4d783          	lhu	a5,74(s1)
    800055aa:	37fd                	addiw	a5,a5,-1
    800055ac:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055b0:	8526                	mv	a0,s1
    800055b2:	ffffe097          	auipc	ra,0xffffe
    800055b6:	fe8080e7          	jalr	-24(ra) # 8000359a <iupdate>
    800055ba:	b781                	j	800054fa <sys_unlink+0xe0>
    return -1;
    800055bc:	557d                	li	a0,-1
    800055be:	a005                	j	800055de <sys_unlink+0x1c4>
    iunlockput(ip);
    800055c0:	854a                	mv	a0,s2
    800055c2:	ffffe097          	auipc	ra,0xffffe
    800055c6:	306080e7          	jalr	774(ra) # 800038c8 <iunlockput>
  iunlockput(dp);
    800055ca:	8526                	mv	a0,s1
    800055cc:	ffffe097          	auipc	ra,0xffffe
    800055d0:	2fc080e7          	jalr	764(ra) # 800038c8 <iunlockput>
  end_op();
    800055d4:	fffff097          	auipc	ra,0xfffff
    800055d8:	aec080e7          	jalr	-1300(ra) # 800040c0 <end_op>
  return -1;
    800055dc:	557d                	li	a0,-1
}
    800055de:	70ae                	ld	ra,232(sp)
    800055e0:	740e                	ld	s0,224(sp)
    800055e2:	64ee                	ld	s1,216(sp)
    800055e4:	694e                	ld	s2,208(sp)
    800055e6:	69ae                	ld	s3,200(sp)
    800055e8:	616d                	addi	sp,sp,240
    800055ea:	8082                	ret

00000000800055ec <sys_open>:

uint64
sys_open(void)
{
    800055ec:	7131                	addi	sp,sp,-192
    800055ee:	fd06                	sd	ra,184(sp)
    800055f0:	f922                	sd	s0,176(sp)
    800055f2:	f526                	sd	s1,168(sp)
    800055f4:	f14a                	sd	s2,160(sp)
    800055f6:	ed4e                	sd	s3,152(sp)
    800055f8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800055fa:	08000613          	li	a2,128
    800055fe:	f5040593          	addi	a1,s0,-176
    80005602:	4501                	li	a0,0
    80005604:	ffffd097          	auipc	ra,0xffffd
    80005608:	51c080e7          	jalr	1308(ra) # 80002b20 <argstr>
    return -1;
    8000560c:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000560e:	0c054163          	bltz	a0,800056d0 <sys_open+0xe4>
    80005612:	f4c40593          	addi	a1,s0,-180
    80005616:	4505                	li	a0,1
    80005618:	ffffd097          	auipc	ra,0xffffd
    8000561c:	4c4080e7          	jalr	1220(ra) # 80002adc <argint>
    80005620:	0a054863          	bltz	a0,800056d0 <sys_open+0xe4>

  begin_op();
    80005624:	fffff097          	auipc	ra,0xfffff
    80005628:	a1e080e7          	jalr	-1506(ra) # 80004042 <begin_op>

  if(omode & O_CREATE){
    8000562c:	f4c42783          	lw	a5,-180(s0)
    80005630:	2007f793          	andi	a5,a5,512
    80005634:	cbdd                	beqz	a5,800056ea <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005636:	4681                	li	a3,0
    80005638:	4601                	li	a2,0
    8000563a:	4589                	li	a1,2
    8000563c:	f5040513          	addi	a0,s0,-176
    80005640:	00000097          	auipc	ra,0x0
    80005644:	970080e7          	jalr	-1680(ra) # 80004fb0 <create>
    80005648:	892a                	mv	s2,a0
    if(ip == 0){
    8000564a:	c959                	beqz	a0,800056e0 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000564c:	04491703          	lh	a4,68(s2)
    80005650:	478d                	li	a5,3
    80005652:	00f71763          	bne	a4,a5,80005660 <sys_open+0x74>
    80005656:	04695703          	lhu	a4,70(s2)
    8000565a:	47a5                	li	a5,9
    8000565c:	0ce7ec63          	bltu	a5,a4,80005734 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	dee080e7          	jalr	-530(ra) # 8000444e <filealloc>
    80005668:	89aa                	mv	s3,a0
    8000566a:	10050263          	beqz	a0,8000576e <sys_open+0x182>
    8000566e:	00000097          	auipc	ra,0x0
    80005672:	900080e7          	jalr	-1792(ra) # 80004f6e <fdalloc>
    80005676:	84aa                	mv	s1,a0
    80005678:	0e054663          	bltz	a0,80005764 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000567c:	04491703          	lh	a4,68(s2)
    80005680:	478d                	li	a5,3
    80005682:	0cf70463          	beq	a4,a5,8000574a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005686:	4789                	li	a5,2
    80005688:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000568c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005690:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005694:	f4c42783          	lw	a5,-180(s0)
    80005698:	0017c713          	xori	a4,a5,1
    8000569c:	8b05                	andi	a4,a4,1
    8000569e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800056a2:	0037f713          	andi	a4,a5,3
    800056a6:	00e03733          	snez	a4,a4
    800056aa:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800056ae:	4007f793          	andi	a5,a5,1024
    800056b2:	c791                	beqz	a5,800056be <sys_open+0xd2>
    800056b4:	04491703          	lh	a4,68(s2)
    800056b8:	4789                	li	a5,2
    800056ba:	08f70f63          	beq	a4,a5,80005758 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800056be:	854a                	mv	a0,s2
    800056c0:	ffffe097          	auipc	ra,0xffffe
    800056c4:	068080e7          	jalr	104(ra) # 80003728 <iunlock>
  end_op();
    800056c8:	fffff097          	auipc	ra,0xfffff
    800056cc:	9f8080e7          	jalr	-1544(ra) # 800040c0 <end_op>

  return fd;
}
    800056d0:	8526                	mv	a0,s1
    800056d2:	70ea                	ld	ra,184(sp)
    800056d4:	744a                	ld	s0,176(sp)
    800056d6:	74aa                	ld	s1,168(sp)
    800056d8:	790a                	ld	s2,160(sp)
    800056da:	69ea                	ld	s3,152(sp)
    800056dc:	6129                	addi	sp,sp,192
    800056de:	8082                	ret
      end_op();
    800056e0:	fffff097          	auipc	ra,0xfffff
    800056e4:	9e0080e7          	jalr	-1568(ra) # 800040c0 <end_op>
      return -1;
    800056e8:	b7e5                	j	800056d0 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800056ea:	f5040513          	addi	a0,s0,-176
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	734080e7          	jalr	1844(ra) # 80003e22 <namei>
    800056f6:	892a                	mv	s2,a0
    800056f8:	c905                	beqz	a0,80005728 <sys_open+0x13c>
    ilock(ip);
    800056fa:	ffffe097          	auipc	ra,0xffffe
    800056fe:	f6c080e7          	jalr	-148(ra) # 80003666 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005702:	04491703          	lh	a4,68(s2)
    80005706:	4785                	li	a5,1
    80005708:	f4f712e3          	bne	a4,a5,8000564c <sys_open+0x60>
    8000570c:	f4c42783          	lw	a5,-180(s0)
    80005710:	dba1                	beqz	a5,80005660 <sys_open+0x74>
      iunlockput(ip);
    80005712:	854a                	mv	a0,s2
    80005714:	ffffe097          	auipc	ra,0xffffe
    80005718:	1b4080e7          	jalr	436(ra) # 800038c8 <iunlockput>
      end_op();
    8000571c:	fffff097          	auipc	ra,0xfffff
    80005720:	9a4080e7          	jalr	-1628(ra) # 800040c0 <end_op>
      return -1;
    80005724:	54fd                	li	s1,-1
    80005726:	b76d                	j	800056d0 <sys_open+0xe4>
      end_op();
    80005728:	fffff097          	auipc	ra,0xfffff
    8000572c:	998080e7          	jalr	-1640(ra) # 800040c0 <end_op>
      return -1;
    80005730:	54fd                	li	s1,-1
    80005732:	bf79                	j	800056d0 <sys_open+0xe4>
    iunlockput(ip);
    80005734:	854a                	mv	a0,s2
    80005736:	ffffe097          	auipc	ra,0xffffe
    8000573a:	192080e7          	jalr	402(ra) # 800038c8 <iunlockput>
    end_op();
    8000573e:	fffff097          	auipc	ra,0xfffff
    80005742:	982080e7          	jalr	-1662(ra) # 800040c0 <end_op>
    return -1;
    80005746:	54fd                	li	s1,-1
    80005748:	b761                	j	800056d0 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000574a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000574e:	04691783          	lh	a5,70(s2)
    80005752:	02f99223          	sh	a5,36(s3)
    80005756:	bf2d                	j	80005690 <sys_open+0xa4>
    itrunc(ip);
    80005758:	854a                	mv	a0,s2
    8000575a:	ffffe097          	auipc	ra,0xffffe
    8000575e:	01a080e7          	jalr	26(ra) # 80003774 <itrunc>
    80005762:	bfb1                	j	800056be <sys_open+0xd2>
      fileclose(f);
    80005764:	854e                	mv	a0,s3
    80005766:	fffff097          	auipc	ra,0xfffff
    8000576a:	da4080e7          	jalr	-604(ra) # 8000450a <fileclose>
    iunlockput(ip);
    8000576e:	854a                	mv	a0,s2
    80005770:	ffffe097          	auipc	ra,0xffffe
    80005774:	158080e7          	jalr	344(ra) # 800038c8 <iunlockput>
    end_op();
    80005778:	fffff097          	auipc	ra,0xfffff
    8000577c:	948080e7          	jalr	-1720(ra) # 800040c0 <end_op>
    return -1;
    80005780:	54fd                	li	s1,-1
    80005782:	b7b9                	j	800056d0 <sys_open+0xe4>

0000000080005784 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005784:	7175                	addi	sp,sp,-144
    80005786:	e506                	sd	ra,136(sp)
    80005788:	e122                	sd	s0,128(sp)
    8000578a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000578c:	fffff097          	auipc	ra,0xfffff
    80005790:	8b6080e7          	jalr	-1866(ra) # 80004042 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005794:	08000613          	li	a2,128
    80005798:	f7040593          	addi	a1,s0,-144
    8000579c:	4501                	li	a0,0
    8000579e:	ffffd097          	auipc	ra,0xffffd
    800057a2:	382080e7          	jalr	898(ra) # 80002b20 <argstr>
    800057a6:	02054963          	bltz	a0,800057d8 <sys_mkdir+0x54>
    800057aa:	4681                	li	a3,0
    800057ac:	4601                	li	a2,0
    800057ae:	4585                	li	a1,1
    800057b0:	f7040513          	addi	a0,s0,-144
    800057b4:	fffff097          	auipc	ra,0xfffff
    800057b8:	7fc080e7          	jalr	2044(ra) # 80004fb0 <create>
    800057bc:	cd11                	beqz	a0,800057d8 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057be:	ffffe097          	auipc	ra,0xffffe
    800057c2:	10a080e7          	jalr	266(ra) # 800038c8 <iunlockput>
  end_op();
    800057c6:	fffff097          	auipc	ra,0xfffff
    800057ca:	8fa080e7          	jalr	-1798(ra) # 800040c0 <end_op>
  return 0;
    800057ce:	4501                	li	a0,0
}
    800057d0:	60aa                	ld	ra,136(sp)
    800057d2:	640a                	ld	s0,128(sp)
    800057d4:	6149                	addi	sp,sp,144
    800057d6:	8082                	ret
    end_op();
    800057d8:	fffff097          	auipc	ra,0xfffff
    800057dc:	8e8080e7          	jalr	-1816(ra) # 800040c0 <end_op>
    return -1;
    800057e0:	557d                	li	a0,-1
    800057e2:	b7fd                	j	800057d0 <sys_mkdir+0x4c>

00000000800057e4 <sys_mknod>:

uint64
sys_mknod(void)
{
    800057e4:	7135                	addi	sp,sp,-160
    800057e6:	ed06                	sd	ra,152(sp)
    800057e8:	e922                	sd	s0,144(sp)
    800057ea:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800057ec:	fffff097          	auipc	ra,0xfffff
    800057f0:	856080e7          	jalr	-1962(ra) # 80004042 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057f4:	08000613          	li	a2,128
    800057f8:	f7040593          	addi	a1,s0,-144
    800057fc:	4501                	li	a0,0
    800057fe:	ffffd097          	auipc	ra,0xffffd
    80005802:	322080e7          	jalr	802(ra) # 80002b20 <argstr>
    80005806:	04054a63          	bltz	a0,8000585a <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000580a:	f6c40593          	addi	a1,s0,-148
    8000580e:	4505                	li	a0,1
    80005810:	ffffd097          	auipc	ra,0xffffd
    80005814:	2cc080e7          	jalr	716(ra) # 80002adc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005818:	04054163          	bltz	a0,8000585a <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    8000581c:	f6840593          	addi	a1,s0,-152
    80005820:	4509                	li	a0,2
    80005822:	ffffd097          	auipc	ra,0xffffd
    80005826:	2ba080e7          	jalr	698(ra) # 80002adc <argint>
     argint(1, &major) < 0 ||
    8000582a:	02054863          	bltz	a0,8000585a <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000582e:	f6841683          	lh	a3,-152(s0)
    80005832:	f6c41603          	lh	a2,-148(s0)
    80005836:	458d                	li	a1,3
    80005838:	f7040513          	addi	a0,s0,-144
    8000583c:	fffff097          	auipc	ra,0xfffff
    80005840:	774080e7          	jalr	1908(ra) # 80004fb0 <create>
     argint(2, &minor) < 0 ||
    80005844:	c919                	beqz	a0,8000585a <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005846:	ffffe097          	auipc	ra,0xffffe
    8000584a:	082080e7          	jalr	130(ra) # 800038c8 <iunlockput>
  end_op();
    8000584e:	fffff097          	auipc	ra,0xfffff
    80005852:	872080e7          	jalr	-1934(ra) # 800040c0 <end_op>
  return 0;
    80005856:	4501                	li	a0,0
    80005858:	a031                	j	80005864 <sys_mknod+0x80>
    end_op();
    8000585a:	fffff097          	auipc	ra,0xfffff
    8000585e:	866080e7          	jalr	-1946(ra) # 800040c0 <end_op>
    return -1;
    80005862:	557d                	li	a0,-1
}
    80005864:	60ea                	ld	ra,152(sp)
    80005866:	644a                	ld	s0,144(sp)
    80005868:	610d                	addi	sp,sp,160
    8000586a:	8082                	ret

000000008000586c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000586c:	7135                	addi	sp,sp,-160
    8000586e:	ed06                	sd	ra,152(sp)
    80005870:	e922                	sd	s0,144(sp)
    80005872:	e526                	sd	s1,136(sp)
    80005874:	e14a                	sd	s2,128(sp)
    80005876:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005878:	ffffc097          	auipc	ra,0xffffc
    8000587c:	11e080e7          	jalr	286(ra) # 80001996 <myproc>
    80005880:	892a                	mv	s2,a0
  
  begin_op();
    80005882:	ffffe097          	auipc	ra,0xffffe
    80005886:	7c0080e7          	jalr	1984(ra) # 80004042 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000588a:	08000613          	li	a2,128
    8000588e:	f6040593          	addi	a1,s0,-160
    80005892:	4501                	li	a0,0
    80005894:	ffffd097          	auipc	ra,0xffffd
    80005898:	28c080e7          	jalr	652(ra) # 80002b20 <argstr>
    8000589c:	04054b63          	bltz	a0,800058f2 <sys_chdir+0x86>
    800058a0:	f6040513          	addi	a0,s0,-160
    800058a4:	ffffe097          	auipc	ra,0xffffe
    800058a8:	57e080e7          	jalr	1406(ra) # 80003e22 <namei>
    800058ac:	84aa                	mv	s1,a0
    800058ae:	c131                	beqz	a0,800058f2 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800058b0:	ffffe097          	auipc	ra,0xffffe
    800058b4:	db6080e7          	jalr	-586(ra) # 80003666 <ilock>
  if(ip->type != T_DIR){
    800058b8:	04449703          	lh	a4,68(s1)
    800058bc:	4785                	li	a5,1
    800058be:	04f71063          	bne	a4,a5,800058fe <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800058c2:	8526                	mv	a0,s1
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	e64080e7          	jalr	-412(ra) # 80003728 <iunlock>
  iput(p->cwd);
    800058cc:	15093503          	ld	a0,336(s2)
    800058d0:	ffffe097          	auipc	ra,0xffffe
    800058d4:	f50080e7          	jalr	-176(ra) # 80003820 <iput>
  end_op();
    800058d8:	ffffe097          	auipc	ra,0xffffe
    800058dc:	7e8080e7          	jalr	2024(ra) # 800040c0 <end_op>
  p->cwd = ip;
    800058e0:	14993823          	sd	s1,336(s2)
  return 0;
    800058e4:	4501                	li	a0,0
}
    800058e6:	60ea                	ld	ra,152(sp)
    800058e8:	644a                	ld	s0,144(sp)
    800058ea:	64aa                	ld	s1,136(sp)
    800058ec:	690a                	ld	s2,128(sp)
    800058ee:	610d                	addi	sp,sp,160
    800058f0:	8082                	ret
    end_op();
    800058f2:	ffffe097          	auipc	ra,0xffffe
    800058f6:	7ce080e7          	jalr	1998(ra) # 800040c0 <end_op>
    return -1;
    800058fa:	557d                	li	a0,-1
    800058fc:	b7ed                	j	800058e6 <sys_chdir+0x7a>
    iunlockput(ip);
    800058fe:	8526                	mv	a0,s1
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	fc8080e7          	jalr	-56(ra) # 800038c8 <iunlockput>
    end_op();
    80005908:	ffffe097          	auipc	ra,0xffffe
    8000590c:	7b8080e7          	jalr	1976(ra) # 800040c0 <end_op>
    return -1;
    80005910:	557d                	li	a0,-1
    80005912:	bfd1                	j	800058e6 <sys_chdir+0x7a>

0000000080005914 <sys_exec>:

uint64
sys_exec(void)
{
    80005914:	7145                	addi	sp,sp,-464
    80005916:	e786                	sd	ra,456(sp)
    80005918:	e3a2                	sd	s0,448(sp)
    8000591a:	ff26                	sd	s1,440(sp)
    8000591c:	fb4a                	sd	s2,432(sp)
    8000591e:	f74e                	sd	s3,424(sp)
    80005920:	f352                	sd	s4,416(sp)
    80005922:	ef56                	sd	s5,408(sp)
    80005924:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005926:	08000613          	li	a2,128
    8000592a:	f4040593          	addi	a1,s0,-192
    8000592e:	4501                	li	a0,0
    80005930:	ffffd097          	auipc	ra,0xffffd
    80005934:	1f0080e7          	jalr	496(ra) # 80002b20 <argstr>
    return -1;
    80005938:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000593a:	0c054b63          	bltz	a0,80005a10 <sys_exec+0xfc>
    8000593e:	e3840593          	addi	a1,s0,-456
    80005942:	4505                	li	a0,1
    80005944:	ffffd097          	auipc	ra,0xffffd
    80005948:	1ba080e7          	jalr	442(ra) # 80002afe <argaddr>
    8000594c:	0c054263          	bltz	a0,80005a10 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005950:	10000613          	li	a2,256
    80005954:	4581                	li	a1,0
    80005956:	e4040513          	addi	a0,s0,-448
    8000595a:	ffffb097          	auipc	ra,0xffffb
    8000595e:	372080e7          	jalr	882(ra) # 80000ccc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005962:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005966:	89a6                	mv	s3,s1
    80005968:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000596a:	02000a13          	li	s4,32
    8000596e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005972:	00391513          	slli	a0,s2,0x3
    80005976:	e3040593          	addi	a1,s0,-464
    8000597a:	e3843783          	ld	a5,-456(s0)
    8000597e:	953e                	add	a0,a0,a5
    80005980:	ffffd097          	auipc	ra,0xffffd
    80005984:	0c2080e7          	jalr	194(ra) # 80002a42 <fetchaddr>
    80005988:	02054a63          	bltz	a0,800059bc <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    8000598c:	e3043783          	ld	a5,-464(s0)
    80005990:	c3b9                	beqz	a5,800059d6 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005992:	ffffb097          	auipc	ra,0xffffb
    80005996:	14e080e7          	jalr	334(ra) # 80000ae0 <kalloc>
    8000599a:	85aa                	mv	a1,a0
    8000599c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800059a0:	cd11                	beqz	a0,800059bc <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800059a2:	6605                	lui	a2,0x1
    800059a4:	e3043503          	ld	a0,-464(s0)
    800059a8:	ffffd097          	auipc	ra,0xffffd
    800059ac:	0ec080e7          	jalr	236(ra) # 80002a94 <fetchstr>
    800059b0:	00054663          	bltz	a0,800059bc <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    800059b4:	0905                	addi	s2,s2,1
    800059b6:	09a1                	addi	s3,s3,8
    800059b8:	fb491be3          	bne	s2,s4,8000596e <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059bc:	f4040913          	addi	s2,s0,-192
    800059c0:	6088                	ld	a0,0(s1)
    800059c2:	c531                	beqz	a0,80005a0e <sys_exec+0xfa>
    kfree(argv[i]);
    800059c4:	ffffb097          	auipc	ra,0xffffb
    800059c8:	01e080e7          	jalr	30(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059cc:	04a1                	addi	s1,s1,8
    800059ce:	ff2499e3          	bne	s1,s2,800059c0 <sys_exec+0xac>
  return -1;
    800059d2:	597d                	li	s2,-1
    800059d4:	a835                	j	80005a10 <sys_exec+0xfc>
      argv[i] = 0;
    800059d6:	0a8e                	slli	s5,s5,0x3
    800059d8:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd8fc0>
    800059dc:	00878ab3          	add	s5,a5,s0
    800059e0:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800059e4:	e4040593          	addi	a1,s0,-448
    800059e8:	f4040513          	addi	a0,s0,-192
    800059ec:	fffff097          	auipc	ra,0xfffff
    800059f0:	172080e7          	jalr	370(ra) # 80004b5e <exec>
    800059f4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059f6:	f4040993          	addi	s3,s0,-192
    800059fa:	6088                	ld	a0,0(s1)
    800059fc:	c911                	beqz	a0,80005a10 <sys_exec+0xfc>
    kfree(argv[i]);
    800059fe:	ffffb097          	auipc	ra,0xffffb
    80005a02:	fe4080e7          	jalr	-28(ra) # 800009e2 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a06:	04a1                	addi	s1,s1,8
    80005a08:	ff3499e3          	bne	s1,s3,800059fa <sys_exec+0xe6>
    80005a0c:	a011                	j	80005a10 <sys_exec+0xfc>
  return -1;
    80005a0e:	597d                	li	s2,-1
}
    80005a10:	854a                	mv	a0,s2
    80005a12:	60be                	ld	ra,456(sp)
    80005a14:	641e                	ld	s0,448(sp)
    80005a16:	74fa                	ld	s1,440(sp)
    80005a18:	795a                	ld	s2,432(sp)
    80005a1a:	79ba                	ld	s3,424(sp)
    80005a1c:	7a1a                	ld	s4,416(sp)
    80005a1e:	6afa                	ld	s5,408(sp)
    80005a20:	6179                	addi	sp,sp,464
    80005a22:	8082                	ret

0000000080005a24 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a24:	7139                	addi	sp,sp,-64
    80005a26:	fc06                	sd	ra,56(sp)
    80005a28:	f822                	sd	s0,48(sp)
    80005a2a:	f426                	sd	s1,40(sp)
    80005a2c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a2e:	ffffc097          	auipc	ra,0xffffc
    80005a32:	f68080e7          	jalr	-152(ra) # 80001996 <myproc>
    80005a36:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005a38:	fd840593          	addi	a1,s0,-40
    80005a3c:	4501                	li	a0,0
    80005a3e:	ffffd097          	auipc	ra,0xffffd
    80005a42:	0c0080e7          	jalr	192(ra) # 80002afe <argaddr>
    return -1;
    80005a46:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005a48:	0e054063          	bltz	a0,80005b28 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005a4c:	fc840593          	addi	a1,s0,-56
    80005a50:	fd040513          	addi	a0,s0,-48
    80005a54:	fffff097          	auipc	ra,0xfffff
    80005a58:	de6080e7          	jalr	-538(ra) # 8000483a <pipealloc>
    return -1;
    80005a5c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a5e:	0c054563          	bltz	a0,80005b28 <sys_pipe+0x104>
  fd0 = -1;
    80005a62:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a66:	fd043503          	ld	a0,-48(s0)
    80005a6a:	fffff097          	auipc	ra,0xfffff
    80005a6e:	504080e7          	jalr	1284(ra) # 80004f6e <fdalloc>
    80005a72:	fca42223          	sw	a0,-60(s0)
    80005a76:	08054c63          	bltz	a0,80005b0e <sys_pipe+0xea>
    80005a7a:	fc843503          	ld	a0,-56(s0)
    80005a7e:	fffff097          	auipc	ra,0xfffff
    80005a82:	4f0080e7          	jalr	1264(ra) # 80004f6e <fdalloc>
    80005a86:	fca42023          	sw	a0,-64(s0)
    80005a8a:	06054963          	bltz	a0,80005afc <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a8e:	4691                	li	a3,4
    80005a90:	fc440613          	addi	a2,s0,-60
    80005a94:	fd843583          	ld	a1,-40(s0)
    80005a98:	68a8                	ld	a0,80(s1)
    80005a9a:	ffffc097          	auipc	ra,0xffffc
    80005a9e:	bc0080e7          	jalr	-1088(ra) # 8000165a <copyout>
    80005aa2:	02054063          	bltz	a0,80005ac2 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005aa6:	4691                	li	a3,4
    80005aa8:	fc040613          	addi	a2,s0,-64
    80005aac:	fd843583          	ld	a1,-40(s0)
    80005ab0:	0591                	addi	a1,a1,4
    80005ab2:	68a8                	ld	a0,80(s1)
    80005ab4:	ffffc097          	auipc	ra,0xffffc
    80005ab8:	ba6080e7          	jalr	-1114(ra) # 8000165a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005abc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005abe:	06055563          	bgez	a0,80005b28 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005ac2:	fc442783          	lw	a5,-60(s0)
    80005ac6:	07e9                	addi	a5,a5,26
    80005ac8:	078e                	slli	a5,a5,0x3
    80005aca:	97a6                	add	a5,a5,s1
    80005acc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005ad0:	fc042783          	lw	a5,-64(s0)
    80005ad4:	07e9                	addi	a5,a5,26
    80005ad6:	078e                	slli	a5,a5,0x3
    80005ad8:	00f48533          	add	a0,s1,a5
    80005adc:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005ae0:	fd043503          	ld	a0,-48(s0)
    80005ae4:	fffff097          	auipc	ra,0xfffff
    80005ae8:	a26080e7          	jalr	-1498(ra) # 8000450a <fileclose>
    fileclose(wf);
    80005aec:	fc843503          	ld	a0,-56(s0)
    80005af0:	fffff097          	auipc	ra,0xfffff
    80005af4:	a1a080e7          	jalr	-1510(ra) # 8000450a <fileclose>
    return -1;
    80005af8:	57fd                	li	a5,-1
    80005afa:	a03d                	j	80005b28 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005afc:	fc442783          	lw	a5,-60(s0)
    80005b00:	0007c763          	bltz	a5,80005b0e <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005b04:	07e9                	addi	a5,a5,26
    80005b06:	078e                	slli	a5,a5,0x3
    80005b08:	97a6                	add	a5,a5,s1
    80005b0a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005b0e:	fd043503          	ld	a0,-48(s0)
    80005b12:	fffff097          	auipc	ra,0xfffff
    80005b16:	9f8080e7          	jalr	-1544(ra) # 8000450a <fileclose>
    fileclose(wf);
    80005b1a:	fc843503          	ld	a0,-56(s0)
    80005b1e:	fffff097          	auipc	ra,0xfffff
    80005b22:	9ec080e7          	jalr	-1556(ra) # 8000450a <fileclose>
    return -1;
    80005b26:	57fd                	li	a5,-1
}
    80005b28:	853e                	mv	a0,a5
    80005b2a:	70e2                	ld	ra,56(sp)
    80005b2c:	7442                	ld	s0,48(sp)
    80005b2e:	74a2                	ld	s1,40(sp)
    80005b30:	6121                	addi	sp,sp,64
    80005b32:	8082                	ret
	...

0000000080005b40 <kernelvec>:
    80005b40:	7111                	addi	sp,sp,-256
    80005b42:	e006                	sd	ra,0(sp)
    80005b44:	e40a                	sd	sp,8(sp)
    80005b46:	e80e                	sd	gp,16(sp)
    80005b48:	ec12                	sd	tp,24(sp)
    80005b4a:	f016                	sd	t0,32(sp)
    80005b4c:	f41a                	sd	t1,40(sp)
    80005b4e:	f81e                	sd	t2,48(sp)
    80005b50:	fc22                	sd	s0,56(sp)
    80005b52:	e0a6                	sd	s1,64(sp)
    80005b54:	e4aa                	sd	a0,72(sp)
    80005b56:	e8ae                	sd	a1,80(sp)
    80005b58:	ecb2                	sd	a2,88(sp)
    80005b5a:	f0b6                	sd	a3,96(sp)
    80005b5c:	f4ba                	sd	a4,104(sp)
    80005b5e:	f8be                	sd	a5,112(sp)
    80005b60:	fcc2                	sd	a6,120(sp)
    80005b62:	e146                	sd	a7,128(sp)
    80005b64:	e54a                	sd	s2,136(sp)
    80005b66:	e94e                	sd	s3,144(sp)
    80005b68:	ed52                	sd	s4,152(sp)
    80005b6a:	f156                	sd	s5,160(sp)
    80005b6c:	f55a                	sd	s6,168(sp)
    80005b6e:	f95e                	sd	s7,176(sp)
    80005b70:	fd62                	sd	s8,184(sp)
    80005b72:	e1e6                	sd	s9,192(sp)
    80005b74:	e5ea                	sd	s10,200(sp)
    80005b76:	e9ee                	sd	s11,208(sp)
    80005b78:	edf2                	sd	t3,216(sp)
    80005b7a:	f1f6                	sd	t4,224(sp)
    80005b7c:	f5fa                	sd	t5,232(sp)
    80005b7e:	f9fe                	sd	t6,240(sp)
    80005b80:	d8ffc0ef          	jal	ra,8000290e <kerneltrap>
    80005b84:	6082                	ld	ra,0(sp)
    80005b86:	6122                	ld	sp,8(sp)
    80005b88:	61c2                	ld	gp,16(sp)
    80005b8a:	7282                	ld	t0,32(sp)
    80005b8c:	7322                	ld	t1,40(sp)
    80005b8e:	73c2                	ld	t2,48(sp)
    80005b90:	7462                	ld	s0,56(sp)
    80005b92:	6486                	ld	s1,64(sp)
    80005b94:	6526                	ld	a0,72(sp)
    80005b96:	65c6                	ld	a1,80(sp)
    80005b98:	6666                	ld	a2,88(sp)
    80005b9a:	7686                	ld	a3,96(sp)
    80005b9c:	7726                	ld	a4,104(sp)
    80005b9e:	77c6                	ld	a5,112(sp)
    80005ba0:	7866                	ld	a6,120(sp)
    80005ba2:	688a                	ld	a7,128(sp)
    80005ba4:	692a                	ld	s2,136(sp)
    80005ba6:	69ca                	ld	s3,144(sp)
    80005ba8:	6a6a                	ld	s4,152(sp)
    80005baa:	7a8a                	ld	s5,160(sp)
    80005bac:	7b2a                	ld	s6,168(sp)
    80005bae:	7bca                	ld	s7,176(sp)
    80005bb0:	7c6a                	ld	s8,184(sp)
    80005bb2:	6c8e                	ld	s9,192(sp)
    80005bb4:	6d2e                	ld	s10,200(sp)
    80005bb6:	6dce                	ld	s11,208(sp)
    80005bb8:	6e6e                	ld	t3,216(sp)
    80005bba:	7e8e                	ld	t4,224(sp)
    80005bbc:	7f2e                	ld	t5,232(sp)
    80005bbe:	7fce                	ld	t6,240(sp)
    80005bc0:	6111                	addi	sp,sp,256
    80005bc2:	10200073          	sret
    80005bc6:	00000013          	nop
    80005bca:	00000013          	nop
    80005bce:	0001                	nop

0000000080005bd0 <timervec>:
    80005bd0:	34051573          	csrrw	a0,mscratch,a0
    80005bd4:	e10c                	sd	a1,0(a0)
    80005bd6:	e510                	sd	a2,8(a0)
    80005bd8:	e914                	sd	a3,16(a0)
    80005bda:	6d0c                	ld	a1,24(a0)
    80005bdc:	7110                	ld	a2,32(a0)
    80005bde:	6194                	ld	a3,0(a1)
    80005be0:	96b2                	add	a3,a3,a2
    80005be2:	e194                	sd	a3,0(a1)
    80005be4:	4589                	li	a1,2
    80005be6:	14459073          	csrw	sip,a1
    80005bea:	6914                	ld	a3,16(a0)
    80005bec:	6510                	ld	a2,8(a0)
    80005bee:	610c                	ld	a1,0(a0)
    80005bf0:	34051573          	csrrw	a0,mscratch,a0
    80005bf4:	30200073          	mret
	...

0000000080005bfa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005bfa:	1141                	addi	sp,sp,-16
    80005bfc:	e422                	sd	s0,8(sp)
    80005bfe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c00:	0c0007b7          	lui	a5,0xc000
    80005c04:	4705                	li	a4,1
    80005c06:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c08:	c3d8                	sw	a4,4(a5)
}
    80005c0a:	6422                	ld	s0,8(sp)
    80005c0c:	0141                	addi	sp,sp,16
    80005c0e:	8082                	ret

0000000080005c10 <plicinithart>:

void
plicinithart(void)
{
    80005c10:	1141                	addi	sp,sp,-16
    80005c12:	e406                	sd	ra,8(sp)
    80005c14:	e022                	sd	s0,0(sp)
    80005c16:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c18:	ffffc097          	auipc	ra,0xffffc
    80005c1c:	d52080e7          	jalr	-686(ra) # 8000196a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c20:	0085171b          	slliw	a4,a0,0x8
    80005c24:	0c0027b7          	lui	a5,0xc002
    80005c28:	97ba                	add	a5,a5,a4
    80005c2a:	40200713          	li	a4,1026
    80005c2e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c32:	00d5151b          	slliw	a0,a0,0xd
    80005c36:	0c2017b7          	lui	a5,0xc201
    80005c3a:	97aa                	add	a5,a5,a0
    80005c3c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005c40:	60a2                	ld	ra,8(sp)
    80005c42:	6402                	ld	s0,0(sp)
    80005c44:	0141                	addi	sp,sp,16
    80005c46:	8082                	ret

0000000080005c48 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c48:	1141                	addi	sp,sp,-16
    80005c4a:	e406                	sd	ra,8(sp)
    80005c4c:	e022                	sd	s0,0(sp)
    80005c4e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c50:	ffffc097          	auipc	ra,0xffffc
    80005c54:	d1a080e7          	jalr	-742(ra) # 8000196a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c58:	00d5151b          	slliw	a0,a0,0xd
    80005c5c:	0c2017b7          	lui	a5,0xc201
    80005c60:	97aa                	add	a5,a5,a0
  return irq;
}
    80005c62:	43c8                	lw	a0,4(a5)
    80005c64:	60a2                	ld	ra,8(sp)
    80005c66:	6402                	ld	s0,0(sp)
    80005c68:	0141                	addi	sp,sp,16
    80005c6a:	8082                	ret

0000000080005c6c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c6c:	1101                	addi	sp,sp,-32
    80005c6e:	ec06                	sd	ra,24(sp)
    80005c70:	e822                	sd	s0,16(sp)
    80005c72:	e426                	sd	s1,8(sp)
    80005c74:	1000                	addi	s0,sp,32
    80005c76:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c78:	ffffc097          	auipc	ra,0xffffc
    80005c7c:	cf2080e7          	jalr	-782(ra) # 8000196a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c80:	00d5151b          	slliw	a0,a0,0xd
    80005c84:	0c2017b7          	lui	a5,0xc201
    80005c88:	97aa                	add	a5,a5,a0
    80005c8a:	c3c4                	sw	s1,4(a5)
}
    80005c8c:	60e2                	ld	ra,24(sp)
    80005c8e:	6442                	ld	s0,16(sp)
    80005c90:	64a2                	ld	s1,8(sp)
    80005c92:	6105                	addi	sp,sp,32
    80005c94:	8082                	ret

0000000080005c96 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c96:	1141                	addi	sp,sp,-16
    80005c98:	e406                	sd	ra,8(sp)
    80005c9a:	e022                	sd	s0,0(sp)
    80005c9c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c9e:	479d                	li	a5,7
    80005ca0:	06a7c863          	blt	a5,a0,80005d10 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80005ca4:	0001d717          	auipc	a4,0x1d
    80005ca8:	35c70713          	addi	a4,a4,860 # 80023000 <disk>
    80005cac:	972a                	add	a4,a4,a0
    80005cae:	6789                	lui	a5,0x2
    80005cb0:	97ba                	add	a5,a5,a4
    80005cb2:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005cb6:	e7ad                	bnez	a5,80005d20 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005cb8:	00451793          	slli	a5,a0,0x4
    80005cbc:	0001f717          	auipc	a4,0x1f
    80005cc0:	34470713          	addi	a4,a4,836 # 80025000 <disk+0x2000>
    80005cc4:	6314                	ld	a3,0(a4)
    80005cc6:	96be                	add	a3,a3,a5
    80005cc8:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005ccc:	6314                	ld	a3,0(a4)
    80005cce:	96be                	add	a3,a3,a5
    80005cd0:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005cd4:	6314                	ld	a3,0(a4)
    80005cd6:	96be                	add	a3,a3,a5
    80005cd8:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005cdc:	6318                	ld	a4,0(a4)
    80005cde:	97ba                	add	a5,a5,a4
    80005ce0:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005ce4:	0001d717          	auipc	a4,0x1d
    80005ce8:	31c70713          	addi	a4,a4,796 # 80023000 <disk>
    80005cec:	972a                	add	a4,a4,a0
    80005cee:	6789                	lui	a5,0x2
    80005cf0:	97ba                	add	a5,a5,a4
    80005cf2:	4705                	li	a4,1
    80005cf4:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005cf8:	0001f517          	auipc	a0,0x1f
    80005cfc:	32050513          	addi	a0,a0,800 # 80025018 <disk+0x2018>
    80005d00:	ffffc097          	auipc	ra,0xffffc
    80005d04:	4e6080e7          	jalr	1254(ra) # 800021e6 <wakeup>
}
    80005d08:	60a2                	ld	ra,8(sp)
    80005d0a:	6402                	ld	s0,0(sp)
    80005d0c:	0141                	addi	sp,sp,16
    80005d0e:	8082                	ret
    panic("free_desc 1");
    80005d10:	00003517          	auipc	a0,0x3
    80005d14:	a7850513          	addi	a0,a0,-1416 # 80008788 <syscalls+0x328>
    80005d18:	ffffb097          	auipc	ra,0xffffb
    80005d1c:	822080e7          	jalr	-2014(ra) # 8000053a <panic>
    panic("free_desc 2");
    80005d20:	00003517          	auipc	a0,0x3
    80005d24:	a7850513          	addi	a0,a0,-1416 # 80008798 <syscalls+0x338>
    80005d28:	ffffb097          	auipc	ra,0xffffb
    80005d2c:	812080e7          	jalr	-2030(ra) # 8000053a <panic>

0000000080005d30 <virtio_disk_init>:
{
    80005d30:	1101                	addi	sp,sp,-32
    80005d32:	ec06                	sd	ra,24(sp)
    80005d34:	e822                	sd	s0,16(sp)
    80005d36:	e426                	sd	s1,8(sp)
    80005d38:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d3a:	00003597          	auipc	a1,0x3
    80005d3e:	a6e58593          	addi	a1,a1,-1426 # 800087a8 <syscalls+0x348>
    80005d42:	0001f517          	auipc	a0,0x1f
    80005d46:	3e650513          	addi	a0,a0,998 # 80025128 <disk+0x2128>
    80005d4a:	ffffb097          	auipc	ra,0xffffb
    80005d4e:	df6080e7          	jalr	-522(ra) # 80000b40 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d52:	100017b7          	lui	a5,0x10001
    80005d56:	4398                	lw	a4,0(a5)
    80005d58:	2701                	sext.w	a4,a4
    80005d5a:	747277b7          	lui	a5,0x74727
    80005d5e:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d62:	0ef71063          	bne	a4,a5,80005e42 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005d66:	100017b7          	lui	a5,0x10001
    80005d6a:	43dc                	lw	a5,4(a5)
    80005d6c:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d6e:	4705                	li	a4,1
    80005d70:	0ce79963          	bne	a5,a4,80005e42 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d74:	100017b7          	lui	a5,0x10001
    80005d78:	479c                	lw	a5,8(a5)
    80005d7a:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005d7c:	4709                	li	a4,2
    80005d7e:	0ce79263          	bne	a5,a4,80005e42 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d82:	100017b7          	lui	a5,0x10001
    80005d86:	47d8                	lw	a4,12(a5)
    80005d88:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d8a:	554d47b7          	lui	a5,0x554d4
    80005d8e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d92:	0af71863          	bne	a4,a5,80005e42 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d96:	100017b7          	lui	a5,0x10001
    80005d9a:	4705                	li	a4,1
    80005d9c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d9e:	470d                	li	a4,3
    80005da0:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005da2:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005da4:	c7ffe6b7          	lui	a3,0xc7ffe
    80005da8:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005dac:	8f75                	and	a4,a4,a3
    80005dae:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005db0:	472d                	li	a4,11
    80005db2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005db4:	473d                	li	a4,15
    80005db6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005db8:	6705                	lui	a4,0x1
    80005dba:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005dbc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005dc0:	5bdc                	lw	a5,52(a5)
    80005dc2:	2781                	sext.w	a5,a5
  if(max == 0)
    80005dc4:	c7d9                	beqz	a5,80005e52 <virtio_disk_init+0x122>
  if(max < NUM)
    80005dc6:	471d                	li	a4,7
    80005dc8:	08f77d63          	bgeu	a4,a5,80005e62 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005dcc:	100014b7          	lui	s1,0x10001
    80005dd0:	47a1                	li	a5,8
    80005dd2:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005dd4:	6609                	lui	a2,0x2
    80005dd6:	4581                	li	a1,0
    80005dd8:	0001d517          	auipc	a0,0x1d
    80005ddc:	22850513          	addi	a0,a0,552 # 80023000 <disk>
    80005de0:	ffffb097          	auipc	ra,0xffffb
    80005de4:	eec080e7          	jalr	-276(ra) # 80000ccc <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005de8:	0001d717          	auipc	a4,0x1d
    80005dec:	21870713          	addi	a4,a4,536 # 80023000 <disk>
    80005df0:	00c75793          	srli	a5,a4,0xc
    80005df4:	2781                	sext.w	a5,a5
    80005df6:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005df8:	0001f797          	auipc	a5,0x1f
    80005dfc:	20878793          	addi	a5,a5,520 # 80025000 <disk+0x2000>
    80005e00:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005e02:	0001d717          	auipc	a4,0x1d
    80005e06:	27e70713          	addi	a4,a4,638 # 80023080 <disk+0x80>
    80005e0a:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005e0c:	0001e717          	auipc	a4,0x1e
    80005e10:	1f470713          	addi	a4,a4,500 # 80024000 <disk+0x1000>
    80005e14:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005e16:	4705                	li	a4,1
    80005e18:	00e78c23          	sb	a4,24(a5)
    80005e1c:	00e78ca3          	sb	a4,25(a5)
    80005e20:	00e78d23          	sb	a4,26(a5)
    80005e24:	00e78da3          	sb	a4,27(a5)
    80005e28:	00e78e23          	sb	a4,28(a5)
    80005e2c:	00e78ea3          	sb	a4,29(a5)
    80005e30:	00e78f23          	sb	a4,30(a5)
    80005e34:	00e78fa3          	sb	a4,31(a5)
}
    80005e38:	60e2                	ld	ra,24(sp)
    80005e3a:	6442                	ld	s0,16(sp)
    80005e3c:	64a2                	ld	s1,8(sp)
    80005e3e:	6105                	addi	sp,sp,32
    80005e40:	8082                	ret
    panic("could not find virtio disk");
    80005e42:	00003517          	auipc	a0,0x3
    80005e46:	97650513          	addi	a0,a0,-1674 # 800087b8 <syscalls+0x358>
    80005e4a:	ffffa097          	auipc	ra,0xffffa
    80005e4e:	6f0080e7          	jalr	1776(ra) # 8000053a <panic>
    panic("virtio disk has no queue 0");
    80005e52:	00003517          	auipc	a0,0x3
    80005e56:	98650513          	addi	a0,a0,-1658 # 800087d8 <syscalls+0x378>
    80005e5a:	ffffa097          	auipc	ra,0xffffa
    80005e5e:	6e0080e7          	jalr	1760(ra) # 8000053a <panic>
    panic("virtio disk max queue too short");
    80005e62:	00003517          	auipc	a0,0x3
    80005e66:	99650513          	addi	a0,a0,-1642 # 800087f8 <syscalls+0x398>
    80005e6a:	ffffa097          	auipc	ra,0xffffa
    80005e6e:	6d0080e7          	jalr	1744(ra) # 8000053a <panic>

0000000080005e72 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005e72:	7119                	addi	sp,sp,-128
    80005e74:	fc86                	sd	ra,120(sp)
    80005e76:	f8a2                	sd	s0,112(sp)
    80005e78:	f4a6                	sd	s1,104(sp)
    80005e7a:	f0ca                	sd	s2,96(sp)
    80005e7c:	ecce                	sd	s3,88(sp)
    80005e7e:	e8d2                	sd	s4,80(sp)
    80005e80:	e4d6                	sd	s5,72(sp)
    80005e82:	e0da                	sd	s6,64(sp)
    80005e84:	fc5e                	sd	s7,56(sp)
    80005e86:	f862                	sd	s8,48(sp)
    80005e88:	f466                	sd	s9,40(sp)
    80005e8a:	f06a                	sd	s10,32(sp)
    80005e8c:	ec6e                	sd	s11,24(sp)
    80005e8e:	0100                	addi	s0,sp,128
    80005e90:	8aaa                	mv	s5,a0
    80005e92:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005e94:	00c52c83          	lw	s9,12(a0)
    80005e98:	001c9c9b          	slliw	s9,s9,0x1
    80005e9c:	1c82                	slli	s9,s9,0x20
    80005e9e:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005ea2:	0001f517          	auipc	a0,0x1f
    80005ea6:	28650513          	addi	a0,a0,646 # 80025128 <disk+0x2128>
    80005eaa:	ffffb097          	auipc	ra,0xffffb
    80005eae:	d26080e7          	jalr	-730(ra) # 80000bd0 <acquire>
  for(int i = 0; i < 3; i++){
    80005eb2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005eb4:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005eb6:	0001dc17          	auipc	s8,0x1d
    80005eba:	14ac0c13          	addi	s8,s8,330 # 80023000 <disk>
    80005ebe:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80005ec0:	4b0d                	li	s6,3
    80005ec2:	a0ad                	j	80005f2c <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80005ec4:	00fc0733          	add	a4,s8,a5
    80005ec8:	975e                	add	a4,a4,s7
    80005eca:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005ece:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005ed0:	0207c563          	bltz	a5,80005efa <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005ed4:	2905                	addiw	s2,s2,1
    80005ed6:	0611                	addi	a2,a2,4
    80005ed8:	19690c63          	beq	s2,s6,80006070 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    80005edc:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005ede:	0001f717          	auipc	a4,0x1f
    80005ee2:	13a70713          	addi	a4,a4,314 # 80025018 <disk+0x2018>
    80005ee6:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005ee8:	00074683          	lbu	a3,0(a4)
    80005eec:	fee1                	bnez	a3,80005ec4 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005eee:	2785                	addiw	a5,a5,1
    80005ef0:	0705                	addi	a4,a4,1
    80005ef2:	fe979be3          	bne	a5,s1,80005ee8 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005ef6:	57fd                	li	a5,-1
    80005ef8:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005efa:	01205d63          	blez	s2,80005f14 <virtio_disk_rw+0xa2>
    80005efe:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005f00:	000a2503          	lw	a0,0(s4)
    80005f04:	00000097          	auipc	ra,0x0
    80005f08:	d92080e7          	jalr	-622(ra) # 80005c96 <free_desc>
      for(int j = 0; j < i; j++)
    80005f0c:	2d85                	addiw	s11,s11,1
    80005f0e:	0a11                	addi	s4,s4,4
    80005f10:	ff2d98e3          	bne	s11,s2,80005f00 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f14:	0001f597          	auipc	a1,0x1f
    80005f18:	21458593          	addi	a1,a1,532 # 80025128 <disk+0x2128>
    80005f1c:	0001f517          	auipc	a0,0x1f
    80005f20:	0fc50513          	addi	a0,a0,252 # 80025018 <disk+0x2018>
    80005f24:	ffffc097          	auipc	ra,0xffffc
    80005f28:	136080e7          	jalr	310(ra) # 8000205a <sleep>
  for(int i = 0; i < 3; i++){
    80005f2c:	f8040a13          	addi	s4,s0,-128
{
    80005f30:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005f32:	894e                	mv	s2,s3
    80005f34:	b765                	j	80005edc <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005f36:	0001f697          	auipc	a3,0x1f
    80005f3a:	0ca6b683          	ld	a3,202(a3) # 80025000 <disk+0x2000>
    80005f3e:	96ba                	add	a3,a3,a4
    80005f40:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005f44:	0001d817          	auipc	a6,0x1d
    80005f48:	0bc80813          	addi	a6,a6,188 # 80023000 <disk>
    80005f4c:	0001f697          	auipc	a3,0x1f
    80005f50:	0b468693          	addi	a3,a3,180 # 80025000 <disk+0x2000>
    80005f54:	6290                	ld	a2,0(a3)
    80005f56:	963a                	add	a2,a2,a4
    80005f58:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80005f5c:	0015e593          	ori	a1,a1,1
    80005f60:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80005f64:	f8842603          	lw	a2,-120(s0)
    80005f68:	628c                	ld	a1,0(a3)
    80005f6a:	972e                	add	a4,a4,a1
    80005f6c:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005f70:	20050593          	addi	a1,a0,512
    80005f74:	0592                	slli	a1,a1,0x4
    80005f76:	95c2                	add	a1,a1,a6
    80005f78:	577d                	li	a4,-1
    80005f7a:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005f7e:	00461713          	slli	a4,a2,0x4
    80005f82:	6290                	ld	a2,0(a3)
    80005f84:	963a                	add	a2,a2,a4
    80005f86:	03078793          	addi	a5,a5,48
    80005f8a:	97c2                	add	a5,a5,a6
    80005f8c:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80005f8e:	629c                	ld	a5,0(a3)
    80005f90:	97ba                	add	a5,a5,a4
    80005f92:	4605                	li	a2,1
    80005f94:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005f96:	629c                	ld	a5,0(a3)
    80005f98:	97ba                	add	a5,a5,a4
    80005f9a:	4809                	li	a6,2
    80005f9c:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80005fa0:	629c                	ld	a5,0(a3)
    80005fa2:	97ba                	add	a5,a5,a4
    80005fa4:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005fa8:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80005fac:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005fb0:	6698                	ld	a4,8(a3)
    80005fb2:	00275783          	lhu	a5,2(a4)
    80005fb6:	8b9d                	andi	a5,a5,7
    80005fb8:	0786                	slli	a5,a5,0x1
    80005fba:	973e                	add	a4,a4,a5
    80005fbc:	00a71223          	sh	a0,4(a4)

  __sync_synchronize();
    80005fc0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005fc4:	6698                	ld	a4,8(a3)
    80005fc6:	00275783          	lhu	a5,2(a4)
    80005fca:	2785                	addiw	a5,a5,1
    80005fcc:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005fd0:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005fd4:	100017b7          	lui	a5,0x10001
    80005fd8:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005fdc:	004aa783          	lw	a5,4(s5)
    80005fe0:	02c79163          	bne	a5,a2,80006002 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80005fe4:	0001f917          	auipc	s2,0x1f
    80005fe8:	14490913          	addi	s2,s2,324 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80005fec:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005fee:	85ca                	mv	a1,s2
    80005ff0:	8556                	mv	a0,s5
    80005ff2:	ffffc097          	auipc	ra,0xffffc
    80005ff6:	068080e7          	jalr	104(ra) # 8000205a <sleep>
  while(b->disk == 1) {
    80005ffa:	004aa783          	lw	a5,4(s5)
    80005ffe:	fe9788e3          	beq	a5,s1,80005fee <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006002:	f8042903          	lw	s2,-128(s0)
    80006006:	20090713          	addi	a4,s2,512
    8000600a:	0712                	slli	a4,a4,0x4
    8000600c:	0001d797          	auipc	a5,0x1d
    80006010:	ff478793          	addi	a5,a5,-12 # 80023000 <disk>
    80006014:	97ba                	add	a5,a5,a4
    80006016:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    8000601a:	0001f997          	auipc	s3,0x1f
    8000601e:	fe698993          	addi	s3,s3,-26 # 80025000 <disk+0x2000>
    80006022:	00491713          	slli	a4,s2,0x4
    80006026:	0009b783          	ld	a5,0(s3)
    8000602a:	97ba                	add	a5,a5,a4
    8000602c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006030:	854a                	mv	a0,s2
    80006032:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006036:	00000097          	auipc	ra,0x0
    8000603a:	c60080e7          	jalr	-928(ra) # 80005c96 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000603e:	8885                	andi	s1,s1,1
    80006040:	f0ed                	bnez	s1,80006022 <virtio_disk_rw+0x1b0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006042:	0001f517          	auipc	a0,0x1f
    80006046:	0e650513          	addi	a0,a0,230 # 80025128 <disk+0x2128>
    8000604a:	ffffb097          	auipc	ra,0xffffb
    8000604e:	c3a080e7          	jalr	-966(ra) # 80000c84 <release>
}
    80006052:	70e6                	ld	ra,120(sp)
    80006054:	7446                	ld	s0,112(sp)
    80006056:	74a6                	ld	s1,104(sp)
    80006058:	7906                	ld	s2,96(sp)
    8000605a:	69e6                	ld	s3,88(sp)
    8000605c:	6a46                	ld	s4,80(sp)
    8000605e:	6aa6                	ld	s5,72(sp)
    80006060:	6b06                	ld	s6,64(sp)
    80006062:	7be2                	ld	s7,56(sp)
    80006064:	7c42                	ld	s8,48(sp)
    80006066:	7ca2                	ld	s9,40(sp)
    80006068:	7d02                	ld	s10,32(sp)
    8000606a:	6de2                	ld	s11,24(sp)
    8000606c:	6109                	addi	sp,sp,128
    8000606e:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006070:	f8042503          	lw	a0,-128(s0)
    80006074:	20050793          	addi	a5,a0,512
    80006078:	0792                	slli	a5,a5,0x4
  if(write)
    8000607a:	0001d817          	auipc	a6,0x1d
    8000607e:	f8680813          	addi	a6,a6,-122 # 80023000 <disk>
    80006082:	00f80733          	add	a4,a6,a5
    80006086:	01a036b3          	snez	a3,s10
    8000608a:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    8000608e:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006092:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006096:	7679                	lui	a2,0xffffe
    80006098:	963e                	add	a2,a2,a5
    8000609a:	0001f697          	auipc	a3,0x1f
    8000609e:	f6668693          	addi	a3,a3,-154 # 80025000 <disk+0x2000>
    800060a2:	6298                	ld	a4,0(a3)
    800060a4:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060a6:	0a878593          	addi	a1,a5,168
    800060aa:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800060ac:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800060ae:	6298                	ld	a4,0(a3)
    800060b0:	9732                	add	a4,a4,a2
    800060b2:	45c1                	li	a1,16
    800060b4:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800060b6:	6298                	ld	a4,0(a3)
    800060b8:	9732                	add	a4,a4,a2
    800060ba:	4585                	li	a1,1
    800060bc:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800060c0:	f8442703          	lw	a4,-124(s0)
    800060c4:	628c                	ld	a1,0(a3)
    800060c6:	962e                	add	a2,a2,a1
    800060c8:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800060cc:	0712                	slli	a4,a4,0x4
    800060ce:	6290                	ld	a2,0(a3)
    800060d0:	963a                	add	a2,a2,a4
    800060d2:	058a8593          	addi	a1,s5,88
    800060d6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800060d8:	6294                	ld	a3,0(a3)
    800060da:	96ba                	add	a3,a3,a4
    800060dc:	40000613          	li	a2,1024
    800060e0:	c690                	sw	a2,8(a3)
  if(write)
    800060e2:	e40d1ae3          	bnez	s10,80005f36 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800060e6:	0001f697          	auipc	a3,0x1f
    800060ea:	f1a6b683          	ld	a3,-230(a3) # 80025000 <disk+0x2000>
    800060ee:	96ba                	add	a3,a3,a4
    800060f0:	4609                	li	a2,2
    800060f2:	00c69623          	sh	a2,12(a3)
    800060f6:	b5b9                	j	80005f44 <virtio_disk_rw+0xd2>

00000000800060f8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800060f8:	1101                	addi	sp,sp,-32
    800060fa:	ec06                	sd	ra,24(sp)
    800060fc:	e822                	sd	s0,16(sp)
    800060fe:	e426                	sd	s1,8(sp)
    80006100:	e04a                	sd	s2,0(sp)
    80006102:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006104:	0001f517          	auipc	a0,0x1f
    80006108:	02450513          	addi	a0,a0,36 # 80025128 <disk+0x2128>
    8000610c:	ffffb097          	auipc	ra,0xffffb
    80006110:	ac4080e7          	jalr	-1340(ra) # 80000bd0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006114:	10001737          	lui	a4,0x10001
    80006118:	533c                	lw	a5,96(a4)
    8000611a:	8b8d                	andi	a5,a5,3
    8000611c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000611e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006122:	0001f797          	auipc	a5,0x1f
    80006126:	ede78793          	addi	a5,a5,-290 # 80025000 <disk+0x2000>
    8000612a:	6b94                	ld	a3,16(a5)
    8000612c:	0207d703          	lhu	a4,32(a5)
    80006130:	0026d783          	lhu	a5,2(a3)
    80006134:	06f70163          	beq	a4,a5,80006196 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006138:	0001d917          	auipc	s2,0x1d
    8000613c:	ec890913          	addi	s2,s2,-312 # 80023000 <disk>
    80006140:	0001f497          	auipc	s1,0x1f
    80006144:	ec048493          	addi	s1,s1,-320 # 80025000 <disk+0x2000>
    __sync_synchronize();
    80006148:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000614c:	6898                	ld	a4,16(s1)
    8000614e:	0204d783          	lhu	a5,32(s1)
    80006152:	8b9d                	andi	a5,a5,7
    80006154:	078e                	slli	a5,a5,0x3
    80006156:	97ba                	add	a5,a5,a4
    80006158:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000615a:	20078713          	addi	a4,a5,512
    8000615e:	0712                	slli	a4,a4,0x4
    80006160:	974a                	add	a4,a4,s2
    80006162:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006166:	e731                	bnez	a4,800061b2 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006168:	20078793          	addi	a5,a5,512
    8000616c:	0792                	slli	a5,a5,0x4
    8000616e:	97ca                	add	a5,a5,s2
    80006170:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006172:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006176:	ffffc097          	auipc	ra,0xffffc
    8000617a:	070080e7          	jalr	112(ra) # 800021e6 <wakeup>

    disk.used_idx += 1;
    8000617e:	0204d783          	lhu	a5,32(s1)
    80006182:	2785                	addiw	a5,a5,1
    80006184:	17c2                	slli	a5,a5,0x30
    80006186:	93c1                	srli	a5,a5,0x30
    80006188:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000618c:	6898                	ld	a4,16(s1)
    8000618e:	00275703          	lhu	a4,2(a4)
    80006192:	faf71be3          	bne	a4,a5,80006148 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006196:	0001f517          	auipc	a0,0x1f
    8000619a:	f9250513          	addi	a0,a0,-110 # 80025128 <disk+0x2128>
    8000619e:	ffffb097          	auipc	ra,0xffffb
    800061a2:	ae6080e7          	jalr	-1306(ra) # 80000c84 <release>
}
    800061a6:	60e2                	ld	ra,24(sp)
    800061a8:	6442                	ld	s0,16(sp)
    800061aa:	64a2                	ld	s1,8(sp)
    800061ac:	6902                	ld	s2,0(sp)
    800061ae:	6105                	addi	sp,sp,32
    800061b0:	8082                	ret
      panic("virtio_disk_intr status");
    800061b2:	00002517          	auipc	a0,0x2
    800061b6:	66650513          	addi	a0,a0,1638 # 80008818 <syscalls+0x3b8>
    800061ba:	ffffa097          	auipc	ra,0xffffa
    800061be:	380080e7          	jalr	896(ra) # 8000053a <panic>
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
