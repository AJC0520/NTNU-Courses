
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	55013103          	ld	sp,1360(sp) # 8000b550 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
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
    asm volatile("csrr %0, mhartid" : "=r"(x));
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
    80000038:	1761                	addi	a4,a4,-8 # 200bff8 <_entry-0x7dff4008>
    8000003a:	6318                	ld	a4,0(a4)
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
    80000050:	0000b717          	auipc	a4,0xb
    80000054:	57070713          	addi	a4,a4,1392 # 8000b5c0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void
w_mscratch(uint64 x)
{
    asm volatile("csrw mscratch, %0" : : "r"(x));
    8000005e:	34071073          	csrw	mscratch,a4
    asm volatile("csrw mtvec, %0" : : "r"(x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	3be78793          	addi	a5,a5,958 # 80006420 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
    asm volatile("csrr %0, mstatus" : "=r"(x));
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
    asm volatile("csrw mstatus, %0" : : "r"(x));
    80000076:	30079073          	csrw	mstatus,a5
    asm volatile("csrr %0, mie" : "=r"(x));
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
    asm volatile("csrw mie, %0" : : "r"(x));
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
    asm volatile("csrr %0, mstatus" : "=r"(x));
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd1db7>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mstatus, %0" : : "r"(x));
    800000a8:	30079073          	csrw	mstatus,a5
    asm volatile("csrw mepc, %0" : : "r"(x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	00e78793          	addi	a5,a5,14 # 800010ba <main>
    800000b4:	34179073          	csrw	mepc,a5
    asm volatile("csrw satp, %0" : : "r"(x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
    asm volatile("csrw medeleg, %0" : : "r"(x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
    asm volatile("csrw mideleg, %0" : : "r"(x));
    800000c6:	30379073          	csrw	mideleg,a5
    asm volatile("csrr %0, sie" : "=r"(x));
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
    asm volatile("csrw sie, %0" : : "r"(x));
    800000d2:	10479073          	csrw	sie,a5
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
    asm volatile("csrr %0, mhartid" : "=r"(x));
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
    asm volatile("mv tp, %0" : : "r"(x));
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
int consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	addi	s0,sp,80
    int i;

    for (i = 0; i < n; i++)
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    {
        char c;
        if (either_copyin(&c, user_src, src + i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00003097          	auipc	ra,0x3
    8000012e:	80a080e7          	jalr	-2038(ra) # 80002934 <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
            break;
        uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7f6080e7          	jalr	2038(ra) # 80000930 <uartputc>
    for (i = 0; i < n; i++)
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    8000014c:	74e2                	ld	s1,56(sp)
    8000014e:	79a2                	ld	s3,40(sp)
    80000150:	7a02                	ld	s4,32(sp)
    80000152:	6ae2                	ld	s5,24(sp)
    80000154:	a039                	j	80000162 <consolewrite+0x62>
    80000156:	4901                	li	s2,0
    80000158:	a029                	j	80000162 <consolewrite+0x62>
    8000015a:	74e2                	ld	s1,56(sp)
    8000015c:	79a2                	ld	s3,40(sp)
    8000015e:	7a02                	ld	s4,32(sp)
    80000160:	6ae2                	ld	s5,24(sp)
    }

    return i;
}
    80000162:	854a                	mv	a0,s2
    80000164:	60a6                	ld	ra,72(sp)
    80000166:	6406                	ld	s0,64(sp)
    80000168:	7942                	ld	s2,48(sp)
    8000016a:	6161                	addi	sp,sp,80
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
    uint target;
    int c;
    char cbuf;

    target = n;
    80000188:	00060b1b          	sext.w	s6,a2
    acquire(&cons.lock);
    8000018c:	00013517          	auipc	a0,0x13
    80000190:	57450513          	addi	a0,a0,1396 # 80013700 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	c8c080e7          	jalr	-884(ra) # 80000e20 <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019c:	00013497          	auipc	s1,0x13
    800001a0:	56448493          	addi	s1,s1,1380 # 80013700 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a4:	00013917          	auipc	s2,0x13
    800001a8:	5f490913          	addi	s2,s2,1524 # 80013798 <cons+0x98>
    while (n > 0)
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
        while (cons.r == cons.w)
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
            if (killed(myproc()))
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	b68080e7          	jalr	-1176(ra) # 80001d24 <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	5ba080e7          	jalr	1466(ra) # 8000277e <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
            sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	304080e7          	jalr	772(ra) # 800024d6 <sleep>
        while (cons.r == cons.w)
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	51870713          	addi	a4,a4,1304 # 80013700 <cons>
    800001f0:	0017869b          	addiw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	andi	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

        if (c == C('D'))
    80000206:	4691                	li	a3,4
    80000208:	04db8a63          	beq	s7,a3,8000025c <consoleread+0xee>
            }
            break;
        }

        // copy the input byte to the user-space buffer.
        cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	addi	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	6c4080e7          	jalr	1732(ra) # 800028de <either_copyout>
    80000222:	57fd                	li	a5,-1
    80000224:	04f50a63          	beq	a0,a5,80000278 <consoleread+0x10a>
            break;

        dst++;
    80000228:	0a05                	addi	s4,s4,1
        --n;
    8000022a:	39fd                	addiw	s3,s3,-1

        if (c == '\n')
    8000022c:	47a9                	li	a5,10
    8000022e:	06fb8163          	beq	s7,a5,80000290 <consoleread+0x122>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	bfa5                	j	800001ac <consoleread+0x3e>
                release(&cons.lock);
    80000236:	00013517          	auipc	a0,0x13
    8000023a:	4ca50513          	addi	a0,a0,1226 # 80013700 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	c96080e7          	jalr	-874(ra) # 80000ed4 <release>
                return -1;
    80000246:	557d                	li	a0,-1
        }
    }
    release(&cons.lock);

    return target - n;
}
    80000248:	60e6                	ld	ra,88(sp)
    8000024a:	6446                	ld	s0,80(sp)
    8000024c:	64a6                	ld	s1,72(sp)
    8000024e:	6906                	ld	s2,64(sp)
    80000250:	79e2                	ld	s3,56(sp)
    80000252:	7a42                	ld	s4,48(sp)
    80000254:	7aa2                	ld	s5,40(sp)
    80000256:	7b02                	ld	s6,32(sp)
    80000258:	6125                	addi	sp,sp,96
    8000025a:	8082                	ret
            if (n < target)
    8000025c:	0009871b          	sext.w	a4,s3
    80000260:	01677a63          	bgeu	a4,s6,80000274 <consoleread+0x106>
                cons.r--;
    80000264:	00013717          	auipc	a4,0x13
    80000268:	52f72a23          	sw	a5,1332(a4) # 80013798 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
    release(&cons.lock);
    8000027a:	00013517          	auipc	a0,0x13
    8000027e:	48650513          	addi	a0,a0,1158 # 80013700 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	c52080e7          	jalr	-942(ra) # 80000ed4 <release>
    return target - n;
    8000028a:	413b053b          	subw	a0,s6,s3
    8000028e:	bf6d                	j	80000248 <consoleread+0xda>
    80000290:	6be2                	ld	s7,24(sp)
    80000292:	b7e5                	j	8000027a <consoleread+0x10c>

0000000080000294 <consputc>:
{
    80000294:	1141                	addi	sp,sp,-16
    80000296:	e406                	sd	ra,8(sp)
    80000298:	e022                	sd	s0,0(sp)
    8000029a:	0800                	addi	s0,sp,16
    if (c == BACKSPACE)
    8000029c:	10000793          	li	a5,256
    800002a0:	00f50a63          	beq	a0,a5,800002b4 <consputc+0x20>
        uartputc_sync(c);
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	5ae080e7          	jalr	1454(ra) # 80000852 <uartputc_sync>
}
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	addi	sp,sp,16
    800002b2:	8082                	ret
        uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	59c080e7          	jalr	1436(ra) # 80000852 <uartputc_sync>
        uartputc_sync(' ');
    800002be:	02000513          	li	a0,32
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	590080e7          	jalr	1424(ra) # 80000852 <uartputc_sync>
        uartputc_sync('\b');
    800002ca:	4521                	li	a0,8
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	586080e7          	jalr	1414(ra) # 80000852 <uartputc_sync>
    800002d4:	bfe1                	j	800002ac <consputc+0x18>

00000000800002d6 <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002d6:	1101                	addi	sp,sp,-32
    800002d8:	ec06                	sd	ra,24(sp)
    800002da:	e822                	sd	s0,16(sp)
    800002dc:	e426                	sd	s1,8(sp)
    800002de:	1000                	addi	s0,sp,32
    800002e0:	84aa                	mv	s1,a0
    acquire(&cons.lock);
    800002e2:	00013517          	auipc	a0,0x13
    800002e6:	41e50513          	addi	a0,a0,1054 # 80013700 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	b36080e7          	jalr	-1226(ra) # 80000e20 <acquire>

    switch (c)
    800002f2:	47d5                	li	a5,21
    800002f4:	0af48563          	beq	s1,a5,8000039e <consoleintr+0xc8>
    800002f8:	0297c963          	blt	a5,s1,8000032a <consoleintr+0x54>
    800002fc:	47a1                	li	a5,8
    800002fe:	0ef48c63          	beq	s1,a5,800003f6 <consoleintr+0x120>
    80000302:	47c1                	li	a5,16
    80000304:	10f49f63          	bne	s1,a5,80000422 <consoleintr+0x14c>
    {
    case C('P'): // Print process list.
        procdump();
    80000308:	00002097          	auipc	ra,0x2
    8000030c:	682080e7          	jalr	1666(ra) # 8000298a <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	3f050513          	addi	a0,a0,1008 # 80013700 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	bbc080e7          	jalr	-1092(ra) # 80000ed4 <release>
}
    80000320:	60e2                	ld	ra,24(sp)
    80000322:	6442                	ld	s0,16(sp)
    80000324:	64a2                	ld	s1,8(sp)
    80000326:	6105                	addi	sp,sp,32
    80000328:	8082                	ret
    switch (c)
    8000032a:	07f00793          	li	a5,127
    8000032e:	0cf48463          	beq	s1,a5,800003f6 <consoleintr+0x120>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000332:	00013717          	auipc	a4,0x13
    80000336:	3ce70713          	addi	a4,a4,974 # 80013700 <cons>
    8000033a:	0a072783          	lw	a5,160(a4)
    8000033e:	09872703          	lw	a4,152(a4)
    80000342:	9f99                	subw	a5,a5,a4
    80000344:	07f00713          	li	a4,127
    80000348:	fcf764e3          	bltu	a4,a5,80000310 <consoleintr+0x3a>
            c = (c == '\r') ? '\n' : c;
    8000034c:	47b5                	li	a5,13
    8000034e:	0cf48d63          	beq	s1,a5,80000428 <consoleintr+0x152>
            consputc(c);
    80000352:	8526                	mv	a0,s1
    80000354:	00000097          	auipc	ra,0x0
    80000358:	f40080e7          	jalr	-192(ra) # 80000294 <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000035c:	00013797          	auipc	a5,0x13
    80000360:	3a478793          	addi	a5,a5,932 # 80013700 <cons>
    80000364:	0a07a683          	lw	a3,160(a5)
    80000368:	0016871b          	addiw	a4,a3,1
    8000036c:	0007061b          	sext.w	a2,a4
    80000370:	0ae7a023          	sw	a4,160(a5)
    80000374:	07f6f693          	andi	a3,a3,127
    80000378:	97b6                	add	a5,a5,a3
    8000037a:	00978c23          	sb	s1,24(a5)
            if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    8000037e:	47a9                	li	a5,10
    80000380:	0cf48b63          	beq	s1,a5,80000456 <consoleintr+0x180>
    80000384:	4791                	li	a5,4
    80000386:	0cf48863          	beq	s1,a5,80000456 <consoleintr+0x180>
    8000038a:	00013797          	auipc	a5,0x13
    8000038e:	40e7a783          	lw	a5,1038(a5) # 80013798 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
        while (cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	36070713          	addi	a4,a4,864 # 80013700 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	35048493          	addi	s1,s1,848 # 80013700 <cons>
        while (cons.e != cons.w &&
    800003b8:	4929                	li	s2,10
    800003ba:	02f70a63          	beq	a4,a5,800003ee <consoleintr+0x118>
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003be:	37fd                	addiw	a5,a5,-1
    800003c0:	07f7f713          	andi	a4,a5,127
    800003c4:	9726                	add	a4,a4,s1
        while (cons.e != cons.w &&
    800003c6:	01874703          	lbu	a4,24(a4)
    800003ca:	03270463          	beq	a4,s2,800003f2 <consoleintr+0x11c>
            cons.e--;
    800003ce:	0af4a023          	sw	a5,160(s1)
            consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	ebe080e7          	jalr	-322(ra) # 80000294 <consputc>
        while (cons.e != cons.w &&
    800003de:	0a04a783          	lw	a5,160(s1)
    800003e2:	09c4a703          	lw	a4,156(s1)
    800003e6:	fcf71ce3          	bne	a4,a5,800003be <consoleintr+0xe8>
    800003ea:	6902                	ld	s2,0(sp)
    800003ec:	b715                	j	80000310 <consoleintr+0x3a>
    800003ee:	6902                	ld	s2,0(sp)
    800003f0:	b705                	j	80000310 <consoleintr+0x3a>
    800003f2:	6902                	ld	s2,0(sp)
    800003f4:	bf31                	j	80000310 <consoleintr+0x3a>
        if (cons.e != cons.w)
    800003f6:	00013717          	auipc	a4,0x13
    800003fa:	30a70713          	addi	a4,a4,778 # 80013700 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
            cons.e--;
    8000040a:	37fd                	addiw	a5,a5,-1
    8000040c:	00013717          	auipc	a4,0x13
    80000410:	38f72a23          	sw	a5,916(a4) # 800137a0 <cons+0xa0>
            consputc(BACKSPACE);
    80000414:	10000513          	li	a0,256
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	e7c080e7          	jalr	-388(ra) # 80000294 <consputc>
    80000420:	bdc5                	j	80000310 <consoleintr+0x3a>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000422:	ee0487e3          	beqz	s1,80000310 <consoleintr+0x3a>
    80000426:	b731                	j	80000332 <consoleintr+0x5c>
            consputc(c);
    80000428:	4529                	li	a0,10
    8000042a:	00000097          	auipc	ra,0x0
    8000042e:	e6a080e7          	jalr	-406(ra) # 80000294 <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000432:	00013797          	auipc	a5,0x13
    80000436:	2ce78793          	addi	a5,a5,718 # 80013700 <cons>
    8000043a:	0a07a703          	lw	a4,160(a5)
    8000043e:	0017069b          	addiw	a3,a4,1
    80000442:	0006861b          	sext.w	a2,a3
    80000446:	0ad7a023          	sw	a3,160(a5)
    8000044a:	07f77713          	andi	a4,a4,127
    8000044e:	97ba                	add	a5,a5,a4
    80000450:	4729                	li	a4,10
    80000452:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80000456:	00013797          	auipc	a5,0x13
    8000045a:	34c7a323          	sw	a2,838(a5) # 8001379c <cons+0x9c>
                wakeup(&cons.r);
    8000045e:	00013517          	auipc	a0,0x13
    80000462:	33a50513          	addi	a0,a0,826 # 80013798 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	0d4080e7          	jalr	212(ra) # 8000253a <wakeup>
    8000046e:	b54d                	j	80000310 <consoleintr+0x3a>

0000000080000470 <consoleinit>:

void consoleinit(void)
{
    80000470:	1141                	addi	sp,sp,-16
    80000472:	e406                	sd	ra,8(sp)
    80000474:	e022                	sd	s0,0(sp)
    80000476:	0800                	addi	s0,sp,16
    initlock(&cons.lock, "cons");
    80000478:	00008597          	auipc	a1,0x8
    8000047c:	b9858593          	addi	a1,a1,-1128 # 80008010 <__func__.1+0x8>
    80000480:	00013517          	auipc	a0,0x13
    80000484:	28050513          	addi	a0,a0,640 # 80013700 <cons>
    80000488:	00001097          	auipc	ra,0x1
    8000048c:	908080e7          	jalr	-1784(ra) # 80000d90 <initlock>

    uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	366080e7          	jalr	870(ra) # 800007f6 <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000498:	0002b797          	auipc	a5,0x2b
    8000049c:	41878793          	addi	a5,a5,1048 # 8002b8b0 <devsw>
    800004a0:	00000717          	auipc	a4,0x0
    800004a4:	cce70713          	addi	a4,a4,-818 # 8000016e <consoleread>
    800004a8:	eb98                	sd	a4,16(a5)
    devsw[CONSOLE].write = consolewrite;
    800004aa:	00000717          	auipc	a4,0x0
    800004ae:	c5670713          	addi	a4,a4,-938 # 80000100 <consolewrite>
    800004b2:	ef98                	sd	a4,24(a5)
}
    800004b4:	60a2                	ld	ra,8(sp)
    800004b6:	6402                	ld	s0,0(sp)
    800004b8:	0141                	addi	sp,sp,16
    800004ba:	8082                	ret

00000000800004bc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004bc:	7179                	addi	sp,sp,-48
    800004be:	f406                	sd	ra,40(sp)
    800004c0:	f022                	sd	s0,32(sp)
    800004c2:	1800                	addi	s0,sp,48
    char buf[16];
    int i;
    uint x;

    if (sign && (sign = xx < 0))
    800004c4:	c219                	beqz	a2,800004ca <printint+0xe>
    800004c6:	08054963          	bltz	a0,80000558 <printint+0x9c>
        x = -xx;
    else
        x = xx;
    800004ca:	2501                	sext.w	a0,a0
    800004cc:	4881                	li	a7,0
    800004ce:	fd040693          	addi	a3,s0,-48

    i = 0;
    800004d2:	4701                	li	a4,0
    do
    {
        buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	00008617          	auipc	a2,0x8
    800004da:	38a60613          	addi	a2,a2,906 # 80008860 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addiw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	slli	a5,a5,0x20
    800004e8:	9381                	srli	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
    } while ((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	addi	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x22>

    if (sign)
    80000502:	00088c63          	beqz	a7,8000051a <printint+0x5e>
        buf[i++] = '-';
    80000506:	fe070793          	addi	a5,a4,-32
    8000050a:	00878733          	add	a4,a5,s0
    8000050e:	02d00793          	li	a5,45
    80000512:	fef70823          	sb	a5,-16(a4)
    80000516:	0028071b          	addiw	a4,a6,2

    while (--i >= 0)
    8000051a:	02e05b63          	blez	a4,80000550 <printint+0x94>
    8000051e:	ec26                	sd	s1,24(sp)
    80000520:	e84a                	sd	s2,16(sp)
    80000522:	fd040793          	addi	a5,s0,-48
    80000526:	00e784b3          	add	s1,a5,a4
    8000052a:	fff78913          	addi	s2,a5,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	377d                	addiw	a4,a4,-1
    80000532:	1702                	slli	a4,a4,0x20
    80000534:	9301                	srli	a4,a4,0x20
    80000536:	40e90933          	sub	s2,s2,a4
        consputc(buf[i]);
    8000053a:	fff4c503          	lbu	a0,-1(s1)
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	d56080e7          	jalr	-682(ra) # 80000294 <consputc>
    while (--i >= 0)
    80000546:	14fd                	addi	s1,s1,-1
    80000548:	ff2499e3          	bne	s1,s2,8000053a <printint+0x7e>
    8000054c:	64e2                	ld	s1,24(sp)
    8000054e:	6942                	ld	s2,16(sp)
}
    80000550:	70a2                	ld	ra,40(sp)
    80000552:	7402                	ld	s0,32(sp)
    80000554:	6145                	addi	sp,sp,48
    80000556:	8082                	ret
        x = -xx;
    80000558:	40a0053b          	negw	a0,a0
    if (sign && (sign = xx < 0))
    8000055c:	4885                	li	a7,1
        x = -xx;
    8000055e:	bf85                	j	800004ce <printint+0x12>

0000000080000560 <panic>:
    if (locking)
        release(&pr.lock);
}

void panic(char *s, ...)
{
    80000560:	711d                	addi	sp,sp,-96
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	addi	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
    8000056c:	e40c                	sd	a1,8(s0)
    8000056e:	e810                	sd	a2,16(s0)
    80000570:	ec14                	sd	a3,24(s0)
    80000572:	f018                	sd	a4,32(s0)
    80000574:	f41c                	sd	a5,40(s0)
    80000576:	03043823          	sd	a6,48(s0)
    8000057a:	03143c23          	sd	a7,56(s0)
    pr.locking = 0;
    8000057e:	00013797          	auipc	a5,0x13
    80000582:	2407a123          	sw	zero,578(a5) # 800137c0 <pr+0x18>
    printf("panic: ");
    80000586:	00008517          	auipc	a0,0x8
    8000058a:	a9250513          	addi	a0,a0,-1390 # 80008018 <__func__.1+0x10>
    8000058e:	00000097          	auipc	ra,0x0
    80000592:	02e080e7          	jalr	46(ra) # 800005bc <printf>
    printf(s);
    80000596:	8526                	mv	a0,s1
    80000598:	00000097          	auipc	ra,0x0
    8000059c:	024080e7          	jalr	36(ra) # 800005bc <printf>
    printf("\n");
    800005a0:	00008517          	auipc	a0,0x8
    800005a4:	a8050513          	addi	a0,a0,-1408 # 80008020 <__func__.1+0x18>
    800005a8:	00000097          	auipc	ra,0x0
    800005ac:	014080e7          	jalr	20(ra) # 800005bc <printf>
    panicked = 1; // freeze uart output from other CPUs
    800005b0:	4785                	li	a5,1
    800005b2:	0000b717          	auipc	a4,0xb
    800005b6:	faf72f23          	sw	a5,-66(a4) # 8000b570 <panicked>
    for (;;)
    800005ba:	a001                	j	800005ba <panic+0x5a>

00000000800005bc <printf>:
{
    800005bc:	7131                	addi	sp,sp,-192
    800005be:	fc86                	sd	ra,120(sp)
    800005c0:	f8a2                	sd	s0,112(sp)
    800005c2:	e8d2                	sd	s4,80(sp)
    800005c4:	f06a                	sd	s10,32(sp)
    800005c6:	0100                	addi	s0,sp,128
    800005c8:	8a2a                	mv	s4,a0
    800005ca:	e40c                	sd	a1,8(s0)
    800005cc:	e810                	sd	a2,16(s0)
    800005ce:	ec14                	sd	a3,24(s0)
    800005d0:	f018                	sd	a4,32(s0)
    800005d2:	f41c                	sd	a5,40(s0)
    800005d4:	03043823          	sd	a6,48(s0)
    800005d8:	03143c23          	sd	a7,56(s0)
    locking = pr.locking;
    800005dc:	00013d17          	auipc	s10,0x13
    800005e0:	1e4d2d03          	lw	s10,484(s10) # 800137c0 <pr+0x18>
    if (locking)
    800005e4:	040d1463          	bnez	s10,8000062c <printf+0x70>
    if (fmt == 0)
    800005e8:	040a0b63          	beqz	s4,8000063e <printf+0x82>
    va_start(ap, fmt);
    800005ec:	00840793          	addi	a5,s0,8
    800005f0:	f8f43423          	sd	a5,-120(s0)
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800005f4:	000a4503          	lbu	a0,0(s4)
    800005f8:	18050b63          	beqz	a0,8000078e <printf+0x1d2>
    800005fc:	f4a6                	sd	s1,104(sp)
    800005fe:	f0ca                	sd	s2,96(sp)
    80000600:	ecce                	sd	s3,88(sp)
    80000602:	e4d6                	sd	s5,72(sp)
    80000604:	e0da                	sd	s6,64(sp)
    80000606:	fc5e                	sd	s7,56(sp)
    80000608:	f862                	sd	s8,48(sp)
    8000060a:	f466                	sd	s9,40(sp)
    8000060c:	ec6e                	sd	s11,24(sp)
    8000060e:	4981                	li	s3,0
        if (c != '%')
    80000610:	02500b13          	li	s6,37
        switch (c)
    80000614:	07000b93          	li	s7,112
    consputc('x');
    80000618:	4cc1                	li	s9,16
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000061a:	00008a97          	auipc	s5,0x8
    8000061e:	246a8a93          	addi	s5,s5,582 # 80008860 <digits>
        switch (c)
    80000622:	07300c13          	li	s8,115
    80000626:	06400d93          	li	s11,100
    8000062a:	a0b1                	j	80000676 <printf+0xba>
        acquire(&pr.lock);
    8000062c:	00013517          	auipc	a0,0x13
    80000630:	17c50513          	addi	a0,a0,380 # 800137a8 <pr>
    80000634:	00000097          	auipc	ra,0x0
    80000638:	7ec080e7          	jalr	2028(ra) # 80000e20 <acquire>
    8000063c:	b775                	j	800005e8 <printf+0x2c>
    8000063e:	f4a6                	sd	s1,104(sp)
    80000640:	f0ca                	sd	s2,96(sp)
    80000642:	ecce                	sd	s3,88(sp)
    80000644:	e4d6                	sd	s5,72(sp)
    80000646:	e0da                	sd	s6,64(sp)
    80000648:	fc5e                	sd	s7,56(sp)
    8000064a:	f862                	sd	s8,48(sp)
    8000064c:	f466                	sd	s9,40(sp)
    8000064e:	ec6e                	sd	s11,24(sp)
        panic("null fmt");
    80000650:	00008517          	auipc	a0,0x8
    80000654:	9e050513          	addi	a0,a0,-1568 # 80008030 <__func__.1+0x28>
    80000658:	00000097          	auipc	ra,0x0
    8000065c:	f08080e7          	jalr	-248(ra) # 80000560 <panic>
            consputc(c);
    80000660:	00000097          	auipc	ra,0x0
    80000664:	c34080e7          	jalr	-972(ra) # 80000294 <consputc>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    80000668:	2985                	addiw	s3,s3,1
    8000066a:	013a07b3          	add	a5,s4,s3
    8000066e:	0007c503          	lbu	a0,0(a5)
    80000672:	10050563          	beqz	a0,8000077c <printf+0x1c0>
        if (c != '%')
    80000676:	ff6515e3          	bne	a0,s6,80000660 <printf+0xa4>
        c = fmt[++i] & 0xff;
    8000067a:	2985                	addiw	s3,s3,1
    8000067c:	013a07b3          	add	a5,s4,s3
    80000680:	0007c783          	lbu	a5,0(a5)
    80000684:	0007849b          	sext.w	s1,a5
        if (c == 0)
    80000688:	10078b63          	beqz	a5,8000079e <printf+0x1e2>
        switch (c)
    8000068c:	05778a63          	beq	a5,s7,800006e0 <printf+0x124>
    80000690:	02fbf663          	bgeu	s7,a5,800006bc <printf+0x100>
    80000694:	09878863          	beq	a5,s8,80000724 <printf+0x168>
    80000698:	07800713          	li	a4,120
    8000069c:	0ce79563          	bne	a5,a4,80000766 <printf+0x1aa>
            printint(va_arg(ap, int), 16, 1);
    800006a0:	f8843783          	ld	a5,-120(s0)
    800006a4:	00878713          	addi	a4,a5,8
    800006a8:	f8e43423          	sd	a4,-120(s0)
    800006ac:	4605                	li	a2,1
    800006ae:	85e6                	mv	a1,s9
    800006b0:	4388                	lw	a0,0(a5)
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	e0a080e7          	jalr	-502(ra) # 800004bc <printint>
            break;
    800006ba:	b77d                	j	80000668 <printf+0xac>
        switch (c)
    800006bc:	09678f63          	beq	a5,s6,8000075a <printf+0x19e>
    800006c0:	0bb79363          	bne	a5,s11,80000766 <printf+0x1aa>
            printint(va_arg(ap, int), 10, 1);
    800006c4:	f8843783          	ld	a5,-120(s0)
    800006c8:	00878713          	addi	a4,a5,8
    800006cc:	f8e43423          	sd	a4,-120(s0)
    800006d0:	4605                	li	a2,1
    800006d2:	45a9                	li	a1,10
    800006d4:	4388                	lw	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	de6080e7          	jalr	-538(ra) # 800004bc <printint>
            break;
    800006de:	b769                	j	80000668 <printf+0xac>
            printptr(va_arg(ap, uint64));
    800006e0:	f8843783          	ld	a5,-120(s0)
    800006e4:	00878713          	addi	a4,a5,8
    800006e8:	f8e43423          	sd	a4,-120(s0)
    800006ec:	0007b903          	ld	s2,0(a5)
    consputc('0');
    800006f0:	03000513          	li	a0,48
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	ba0080e7          	jalr	-1120(ra) # 80000294 <consputc>
    consputc('x');
    800006fc:	07800513          	li	a0,120
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b94080e7          	jalr	-1132(ra) # 80000294 <consputc>
    80000708:	84e6                	mv	s1,s9
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000070a:	03c95793          	srli	a5,s2,0x3c
    8000070e:	97d6                	add	a5,a5,s5
    80000710:	0007c503          	lbu	a0,0(a5)
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b80080e7          	jalr	-1152(ra) # 80000294 <consputc>
    for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000071c:	0912                	slli	s2,s2,0x4
    8000071e:	34fd                	addiw	s1,s1,-1
    80000720:	f4ed                	bnez	s1,8000070a <printf+0x14e>
    80000722:	b799                	j	80000668 <printf+0xac>
            if ((s = va_arg(ap, char *)) == 0)
    80000724:	f8843783          	ld	a5,-120(s0)
    80000728:	00878713          	addi	a4,a5,8
    8000072c:	f8e43423          	sd	a4,-120(s0)
    80000730:	6384                	ld	s1,0(a5)
    80000732:	cc89                	beqz	s1,8000074c <printf+0x190>
            for (; *s; s++)
    80000734:	0004c503          	lbu	a0,0(s1)
    80000738:	d905                	beqz	a0,80000668 <printf+0xac>
                consputc(*s);
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	b5a080e7          	jalr	-1190(ra) # 80000294 <consputc>
            for (; *s; s++)
    80000742:	0485                	addi	s1,s1,1
    80000744:	0004c503          	lbu	a0,0(s1)
    80000748:	f96d                	bnez	a0,8000073a <printf+0x17e>
    8000074a:	bf39                	j	80000668 <printf+0xac>
                s = "(null)";
    8000074c:	00008497          	auipc	s1,0x8
    80000750:	8dc48493          	addi	s1,s1,-1828 # 80008028 <__func__.1+0x20>
            for (; *s; s++)
    80000754:	02800513          	li	a0,40
    80000758:	b7cd                	j	8000073a <printf+0x17e>
            consputc('%');
    8000075a:	855a                	mv	a0,s6
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	b38080e7          	jalr	-1224(ra) # 80000294 <consputc>
            break;
    80000764:	b711                	j	80000668 <printf+0xac>
            consputc('%');
    80000766:	855a                	mv	a0,s6
    80000768:	00000097          	auipc	ra,0x0
    8000076c:	b2c080e7          	jalr	-1236(ra) # 80000294 <consputc>
            consputc(c);
    80000770:	8526                	mv	a0,s1
    80000772:	00000097          	auipc	ra,0x0
    80000776:	b22080e7          	jalr	-1246(ra) # 80000294 <consputc>
            break;
    8000077a:	b5fd                	j	80000668 <printf+0xac>
    8000077c:	74a6                	ld	s1,104(sp)
    8000077e:	7906                	ld	s2,96(sp)
    80000780:	69e6                	ld	s3,88(sp)
    80000782:	6aa6                	ld	s5,72(sp)
    80000784:	6b06                	ld	s6,64(sp)
    80000786:	7be2                	ld	s7,56(sp)
    80000788:	7c42                	ld	s8,48(sp)
    8000078a:	7ca2                	ld	s9,40(sp)
    8000078c:	6de2                	ld	s11,24(sp)
    if (locking)
    8000078e:	020d1263          	bnez	s10,800007b2 <printf+0x1f6>
}
    80000792:	70e6                	ld	ra,120(sp)
    80000794:	7446                	ld	s0,112(sp)
    80000796:	6a46                	ld	s4,80(sp)
    80000798:	7d02                	ld	s10,32(sp)
    8000079a:	6129                	addi	sp,sp,192
    8000079c:	8082                	ret
    8000079e:	74a6                	ld	s1,104(sp)
    800007a0:	7906                	ld	s2,96(sp)
    800007a2:	69e6                	ld	s3,88(sp)
    800007a4:	6aa6                	ld	s5,72(sp)
    800007a6:	6b06                	ld	s6,64(sp)
    800007a8:	7be2                	ld	s7,56(sp)
    800007aa:	7c42                	ld	s8,48(sp)
    800007ac:	7ca2                	ld	s9,40(sp)
    800007ae:	6de2                	ld	s11,24(sp)
    800007b0:	bff9                	j	8000078e <printf+0x1d2>
        release(&pr.lock);
    800007b2:	00013517          	auipc	a0,0x13
    800007b6:	ff650513          	addi	a0,a0,-10 # 800137a8 <pr>
    800007ba:	00000097          	auipc	ra,0x0
    800007be:	71a080e7          	jalr	1818(ra) # 80000ed4 <release>
}
    800007c2:	bfc1                	j	80000792 <printf+0x1d6>

00000000800007c4 <printfinit>:
        ;
}

void printfinit(void)
{
    800007c4:	1101                	addi	sp,sp,-32
    800007c6:	ec06                	sd	ra,24(sp)
    800007c8:	e822                	sd	s0,16(sp)
    800007ca:	e426                	sd	s1,8(sp)
    800007cc:	1000                	addi	s0,sp,32
    initlock(&pr.lock, "pr");
    800007ce:	00013497          	auipc	s1,0x13
    800007d2:	fda48493          	addi	s1,s1,-38 # 800137a8 <pr>
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	86a58593          	addi	a1,a1,-1942 # 80008040 <__func__.1+0x38>
    800007de:	8526                	mv	a0,s1
    800007e0:	00000097          	auipc	ra,0x0
    800007e4:	5b0080e7          	jalr	1456(ra) # 80000d90 <initlock>
    pr.locking = 1;
    800007e8:	4785                	li	a5,1
    800007ea:	cc9c                	sw	a5,24(s1)
}
    800007ec:	60e2                	ld	ra,24(sp)
    800007ee:	6442                	ld	s0,16(sp)
    800007f0:	64a2                	ld	s1,8(sp)
    800007f2:	6105                	addi	sp,sp,32
    800007f4:	8082                	ret

00000000800007f6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007f6:	1141                	addi	sp,sp,-16
    800007f8:	e406                	sd	ra,8(sp)
    800007fa:	e022                	sd	s0,0(sp)
    800007fc:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007fe:	100007b7          	lui	a5,0x10000
    80000802:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000806:	10000737          	lui	a4,0x10000
    8000080a:	f8000693          	li	a3,-128
    8000080e:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000812:	468d                	li	a3,3
    80000814:	10000637          	lui	a2,0x10000
    80000818:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000081c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000820:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000824:	10000737          	lui	a4,0x10000
    80000828:	461d                	li	a2,7
    8000082a:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000082e:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000832:	00008597          	auipc	a1,0x8
    80000836:	81658593          	addi	a1,a1,-2026 # 80008048 <__func__.1+0x40>
    8000083a:	00013517          	auipc	a0,0x13
    8000083e:	f8e50513          	addi	a0,a0,-114 # 800137c8 <uart_tx_lock>
    80000842:	00000097          	auipc	ra,0x0
    80000846:	54e080e7          	jalr	1358(ra) # 80000d90 <initlock>
}
    8000084a:	60a2                	ld	ra,8(sp)
    8000084c:	6402                	ld	s0,0(sp)
    8000084e:	0141                	addi	sp,sp,16
    80000850:	8082                	ret

0000000080000852 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000852:	1101                	addi	sp,sp,-32
    80000854:	ec06                	sd	ra,24(sp)
    80000856:	e822                	sd	s0,16(sp)
    80000858:	e426                	sd	s1,8(sp)
    8000085a:	1000                	addi	s0,sp,32
    8000085c:	84aa                	mv	s1,a0
  push_off();
    8000085e:	00000097          	auipc	ra,0x0
    80000862:	576080e7          	jalr	1398(ra) # 80000dd4 <push_off>

  if(panicked){
    80000866:	0000b797          	auipc	a5,0xb
    8000086a:	d0a7a783          	lw	a5,-758(a5) # 8000b570 <panicked>
    8000086e:	eb85                	bnez	a5,8000089e <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000870:	10000737          	lui	a4,0x10000
    80000874:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000876:	00074783          	lbu	a5,0(a4)
    8000087a:	0207f793          	andi	a5,a5,32
    8000087e:	dfe5                	beqz	a5,80000876 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000880:	0ff4f513          	zext.b	a0,s1
    80000884:	100007b7          	lui	a5,0x10000
    80000888:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088c:	00000097          	auipc	ra,0x0
    80000890:	5e8080e7          	jalr	1512(ra) # 80000e74 <pop_off>
}
    80000894:	60e2                	ld	ra,24(sp)
    80000896:	6442                	ld	s0,16(sp)
    80000898:	64a2                	ld	s1,8(sp)
    8000089a:	6105                	addi	sp,sp,32
    8000089c:	8082                	ret
    for(;;)
    8000089e:	a001                	j	8000089e <uartputc_sync+0x4c>

00000000800008a0 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008a0:	0000b797          	auipc	a5,0xb
    800008a4:	cd87b783          	ld	a5,-808(a5) # 8000b578 <uart_tx_r>
    800008a8:	0000b717          	auipc	a4,0xb
    800008ac:	cd873703          	ld	a4,-808(a4) # 8000b580 <uart_tx_w>
    800008b0:	06f70f63          	beq	a4,a5,8000092e <uartstart+0x8e>
{
    800008b4:	7139                	addi	sp,sp,-64
    800008b6:	fc06                	sd	ra,56(sp)
    800008b8:	f822                	sd	s0,48(sp)
    800008ba:	f426                	sd	s1,40(sp)
    800008bc:	f04a                	sd	s2,32(sp)
    800008be:	ec4e                	sd	s3,24(sp)
    800008c0:	e852                	sd	s4,16(sp)
    800008c2:	e456                	sd	s5,8(sp)
    800008c4:	e05a                	sd	s6,0(sp)
    800008c6:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c8:	10000937          	lui	s2,0x10000
    800008cc:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ce:	00013a97          	auipc	s5,0x13
    800008d2:	efaa8a93          	addi	s5,s5,-262 # 800137c8 <uart_tx_lock>
    uart_tx_r += 1;
    800008d6:	0000b497          	auipc	s1,0xb
    800008da:	ca248493          	addi	s1,s1,-862 # 8000b578 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008de:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008e2:	0000b997          	auipc	s3,0xb
    800008e6:	c9e98993          	addi	s3,s3,-866 # 8000b580 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008ea:	00094703          	lbu	a4,0(s2)
    800008ee:	02077713          	andi	a4,a4,32
    800008f2:	c705                	beqz	a4,8000091a <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008f4:	01f7f713          	andi	a4,a5,31
    800008f8:	9756                	add	a4,a4,s5
    800008fa:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008fe:	0785                	addi	a5,a5,1
    80000900:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    80000902:	8526                	mv	a0,s1
    80000904:	00002097          	auipc	ra,0x2
    80000908:	c36080e7          	jalr	-970(ra) # 8000253a <wakeup>
    WriteReg(THR, c);
    8000090c:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000910:	609c                	ld	a5,0(s1)
    80000912:	0009b703          	ld	a4,0(s3)
    80000916:	fcf71ae3          	bne	a4,a5,800008ea <uartstart+0x4a>
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
    8000092e:	8082                	ret

0000000080000930 <uartputc>:
{
    80000930:	7179                	addi	sp,sp,-48
    80000932:	f406                	sd	ra,40(sp)
    80000934:	f022                	sd	s0,32(sp)
    80000936:	ec26                	sd	s1,24(sp)
    80000938:	e84a                	sd	s2,16(sp)
    8000093a:	e44e                	sd	s3,8(sp)
    8000093c:	e052                	sd	s4,0(sp)
    8000093e:	1800                	addi	s0,sp,48
    80000940:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000942:	00013517          	auipc	a0,0x13
    80000946:	e8650513          	addi	a0,a0,-378 # 800137c8 <uart_tx_lock>
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	4d6080e7          	jalr	1238(ra) # 80000e20 <acquire>
  if(panicked){
    80000952:	0000b797          	auipc	a5,0xb
    80000956:	c1e7a783          	lw	a5,-994(a5) # 8000b570 <panicked>
    8000095a:	e7c9                	bnez	a5,800009e4 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000095c:	0000b717          	auipc	a4,0xb
    80000960:	c2473703          	ld	a4,-988(a4) # 8000b580 <uart_tx_w>
    80000964:	0000b797          	auipc	a5,0xb
    80000968:	c147b783          	ld	a5,-1004(a5) # 8000b578 <uart_tx_r>
    8000096c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000970:	00013997          	auipc	s3,0x13
    80000974:	e5898993          	addi	s3,s3,-424 # 800137c8 <uart_tx_lock>
    80000978:	0000b497          	auipc	s1,0xb
    8000097c:	c0048493          	addi	s1,s1,-1024 # 8000b578 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000980:	0000b917          	auipc	s2,0xb
    80000984:	c0090913          	addi	s2,s2,-1024 # 8000b580 <uart_tx_w>
    80000988:	00e79f63          	bne	a5,a4,800009a6 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000098c:	85ce                	mv	a1,s3
    8000098e:	8526                	mv	a0,s1
    80000990:	00002097          	auipc	ra,0x2
    80000994:	b46080e7          	jalr	-1210(ra) # 800024d6 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000998:	00093703          	ld	a4,0(s2)
    8000099c:	609c                	ld	a5,0(s1)
    8000099e:	02078793          	addi	a5,a5,32
    800009a2:	fee785e3          	beq	a5,a4,8000098c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a6:	00013497          	auipc	s1,0x13
    800009aa:	e2248493          	addi	s1,s1,-478 # 800137c8 <uart_tx_lock>
    800009ae:	01f77793          	andi	a5,a4,31
    800009b2:	97a6                	add	a5,a5,s1
    800009b4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009b8:	0705                	addi	a4,a4,1
    800009ba:	0000b797          	auipc	a5,0xb
    800009be:	bce7b323          	sd	a4,-1082(a5) # 8000b580 <uart_tx_w>
  uartstart();
    800009c2:	00000097          	auipc	ra,0x0
    800009c6:	ede080e7          	jalr	-290(ra) # 800008a0 <uartstart>
  release(&uart_tx_lock);
    800009ca:	8526                	mv	a0,s1
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	508080e7          	jalr	1288(ra) # 80000ed4 <release>
}
    800009d4:	70a2                	ld	ra,40(sp)
    800009d6:	7402                	ld	s0,32(sp)
    800009d8:	64e2                	ld	s1,24(sp)
    800009da:	6942                	ld	s2,16(sp)
    800009dc:	69a2                	ld	s3,8(sp)
    800009de:	6a02                	ld	s4,0(sp)
    800009e0:	6145                	addi	sp,sp,48
    800009e2:	8082                	ret
    for(;;)
    800009e4:	a001                	j	800009e4 <uartputc+0xb4>

00000000800009e6 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e6:	1141                	addi	sp,sp,-16
    800009e8:	e422                	sd	s0,8(sp)
    800009ea:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009ec:	100007b7          	lui	a5,0x10000
    800009f0:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009f2:	0007c783          	lbu	a5,0(a5)
    800009f6:	8b85                	andi	a5,a5,1
    800009f8:	cb81                	beqz	a5,80000a08 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009fa:	100007b7          	lui	a5,0x10000
    800009fe:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000a02:	6422                	ld	s0,8(sp)
    80000a04:	0141                	addi	sp,sp,16
    80000a06:	8082                	ret
    return -1;
    80000a08:	557d                	li	a0,-1
    80000a0a:	bfe5                	j	80000a02 <uartgetc+0x1c>

0000000080000a0c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a0c:	1101                	addi	sp,sp,-32
    80000a0e:	ec06                	sd	ra,24(sp)
    80000a10:	e822                	sd	s0,16(sp)
    80000a12:	e426                	sd	s1,8(sp)
    80000a14:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a16:	54fd                	li	s1,-1
    80000a18:	a029                	j	80000a22 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a1a:	00000097          	auipc	ra,0x0
    80000a1e:	8bc080e7          	jalr	-1860(ra) # 800002d6 <consoleintr>
    int c = uartgetc();
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	fc4080e7          	jalr	-60(ra) # 800009e6 <uartgetc>
    if(c == -1)
    80000a2a:	fe9518e3          	bne	a0,s1,80000a1a <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a2e:	00013497          	auipc	s1,0x13
    80000a32:	d9a48493          	addi	s1,s1,-614 # 800137c8 <uart_tx_lock>
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	3e8080e7          	jalr	1000(ra) # 80000e20 <acquire>
  uartstart();
    80000a40:	00000097          	auipc	ra,0x0
    80000a44:	e60080e7          	jalr	-416(ra) # 800008a0 <uartstart>
  release(&uart_tx_lock);
    80000a48:	8526                	mv	a0,s1
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	48a080e7          	jalr	1162(ra) # 80000ed4 <release>
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <kref_inc>:
{
    return (pa - KERNBASE) / PGSIZE;
}

void kref_inc(void *pa)
{
    80000a5c:	1101                	addi	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	e04a                	sd	s2,0(sp)
    80000a66:	1000                	addi	s0,sp,32
    80000a68:	84aa                	mv	s1,a0
    acquire(&reflock);
    80000a6a:	00013917          	auipc	s2,0x13
    80000a6e:	d9690913          	addi	s2,s2,-618 # 80013800 <reflock>
    80000a72:	854a                	mv	a0,s2
    80000a74:	00000097          	auipc	ra,0x0
    80000a78:	3ac080e7          	jalr	940(ra) # 80000e20 <acquire>
    return (pa - KERNBASE) / PGSIZE;
    80000a7c:	800007b7          	lui	a5,0x80000
    80000a80:	94be                	add	s1,s1,a5
    80000a82:	80b1                	srli	s1,s1,0xc
    refcounts[pa_to_idx((uint64)pa)]++;
    80000a84:	00013797          	auipc	a5,0x13
    80000a88:	db478793          	addi	a5,a5,-588 # 80013838 <refcounts>
    80000a8c:	97a6                	add	a5,a5,s1
    80000a8e:	0007c703          	lbu	a4,0(a5)
    80000a92:	2705                	addiw	a4,a4,1
    80000a94:	00e78023          	sb	a4,0(a5)
    release(&reflock);
    80000a98:	854a                	mv	a0,s2
    80000a9a:	00000097          	auipc	ra,0x0
    80000a9e:	43a080e7          	jalr	1082(ra) # 80000ed4 <release>
}
    80000aa2:	60e2                	ld	ra,24(sp)
    80000aa4:	6442                	ld	s0,16(sp)
    80000aa6:	64a2                	ld	s1,8(sp)
    80000aa8:	6902                	ld	s2,0(sp)
    80000aaa:	6105                	addi	sp,sp,32
    80000aac:	8082                	ret

0000000080000aae <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    80000aae:	7179                	addi	sp,sp,-48
    80000ab0:	f406                	sd	ra,40(sp)
    80000ab2:	f022                	sd	s0,32(sp)
    80000ab4:	ec26                	sd	s1,24(sp)
    80000ab6:	e84a                	sd	s2,16(sp)
    80000ab8:	e44e                	sd	s3,8(sp)
    80000aba:	1800                	addi	s0,sp,48
    80000abc:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0)
    80000abe:	0000b797          	auipc	a5,0xb
    80000ac2:	ad27b783          	ld	a5,-1326(a5) # 8000b590 <MAX_PAGES>
    80000ac6:	c799                	beqz	a5,80000ad4 <kfree+0x26>
        assert(FREE_PAGES < MAX_PAGES);
    80000ac8:	0000b717          	auipc	a4,0xb
    80000acc:	ac073703          	ld	a4,-1344(a4) # 8000b588 <FREE_PAGES>
    80000ad0:	06f77b63          	bgeu	a4,a5,80000b46 <kfree+0x98>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000ad4:	03449793          	slli	a5,s1,0x34
    80000ad8:	e3cd                	bnez	a5,80000b7a <kfree+0xcc>
    80000ada:	0002c797          	auipc	a5,0x2c
    80000ade:	f6e78793          	addi	a5,a5,-146 # 8002ca48 <end>
    80000ae2:	08f4ec63          	bltu	s1,a5,80000b7a <kfree+0xcc>
    80000ae6:	47c5                	li	a5,17
    80000ae8:	07ee                	slli	a5,a5,0x1b
    80000aea:	08f4f863          	bgeu	s1,a5,80000b7a <kfree+0xcc>
        panic("kfree");

    // Fill with junk to catch dangling refs.
    memset(pa, 1, PGSIZE);
    80000aee:	6605                	lui	a2,0x1
    80000af0:	4585                	li	a1,1
    80000af2:	8526                	mv	a0,s1
    80000af4:	00000097          	auipc	ra,0x0
    80000af8:	428080e7          	jalr	1064(ra) # 80000f1c <memset>

    r = (struct run *)pa;

    acquire(&kmem.lock);
    80000afc:	00013997          	auipc	s3,0x13
    80000b00:	d0498993          	addi	s3,s3,-764 # 80013800 <reflock>
    80000b04:	00013917          	auipc	s2,0x13
    80000b08:	d1490913          	addi	s2,s2,-748 # 80013818 <kmem>
    80000b0c:	854a                	mv	a0,s2
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	312080e7          	jalr	786(ra) # 80000e20 <acquire>
    r->next = kmem.freelist;
    80000b16:	0309b783          	ld	a5,48(s3)
    80000b1a:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000b1c:	0299b823          	sd	s1,48(s3)
    FREE_PAGES++;
    80000b20:	0000b717          	auipc	a4,0xb
    80000b24:	a6870713          	addi	a4,a4,-1432 # 8000b588 <FREE_PAGES>
    80000b28:	631c                	ld	a5,0(a4)
    80000b2a:	0785                	addi	a5,a5,1
    80000b2c:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000b2e:	854a                	mv	a0,s2
    80000b30:	00000097          	auipc	ra,0x0
    80000b34:	3a4080e7          	jalr	932(ra) # 80000ed4 <release>
}
    80000b38:	70a2                	ld	ra,40(sp)
    80000b3a:	7402                	ld	s0,32(sp)
    80000b3c:	64e2                	ld	s1,24(sp)
    80000b3e:	6942                	ld	s2,16(sp)
    80000b40:	69a2                	ld	s3,8(sp)
    80000b42:	6145                	addi	sp,sp,48
    80000b44:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000b46:	05300693          	li	a3,83
    80000b4a:	00007617          	auipc	a2,0x7
    80000b4e:	4be60613          	addi	a2,a2,1214 # 80008008 <__func__.1>
    80000b52:	00007597          	auipc	a1,0x7
    80000b56:	4fe58593          	addi	a1,a1,1278 # 80008050 <__func__.1+0x48>
    80000b5a:	00007517          	auipc	a0,0x7
    80000b5e:	50650513          	addi	a0,a0,1286 # 80008060 <__func__.1+0x58>
    80000b62:	00000097          	auipc	ra,0x0
    80000b66:	a5a080e7          	jalr	-1446(ra) # 800005bc <printf>
    80000b6a:	00007517          	auipc	a0,0x7
    80000b6e:	50650513          	addi	a0,a0,1286 # 80008070 <__func__.1+0x68>
    80000b72:	00000097          	auipc	ra,0x0
    80000b76:	9ee080e7          	jalr	-1554(ra) # 80000560 <panic>
        panic("kfree");
    80000b7a:	00007517          	auipc	a0,0x7
    80000b7e:	50650513          	addi	a0,a0,1286 # 80008080 <__func__.1+0x78>
    80000b82:	00000097          	auipc	ra,0x0
    80000b86:	9de080e7          	jalr	-1570(ra) # 80000560 <panic>

0000000080000b8a <kref_dec>:
{
    80000b8a:	7179                	addi	sp,sp,-48
    80000b8c:	f406                	sd	ra,40(sp)
    80000b8e:	f022                	sd	s0,32(sp)
    80000b90:	ec26                	sd	s1,24(sp)
    80000b92:	e84a                	sd	s2,16(sp)
    80000b94:	e44e                	sd	s3,8(sp)
    80000b96:	1800                	addi	s0,sp,48
    80000b98:	892a                	mv	s2,a0
    acquire(&reflock);
    80000b9a:	00013997          	auipc	s3,0x13
    80000b9e:	c6698993          	addi	s3,s3,-922 # 80013800 <reflock>
    80000ba2:	854e                	mv	a0,s3
    80000ba4:	00000097          	auipc	ra,0x0
    80000ba8:	27c080e7          	jalr	636(ra) # 80000e20 <acquire>
    return (pa - KERNBASE) / PGSIZE;
    80000bac:	800007b7          	lui	a5,0x80000
    80000bb0:	97ca                	add	a5,a5,s2
    80000bb2:	83b1                	srli	a5,a5,0xc
    int ref = --refcounts[pa_to_idx((uint64)pa)];
    80000bb4:	00013717          	auipc	a4,0x13
    80000bb8:	c8470713          	addi	a4,a4,-892 # 80013838 <refcounts>
    80000bbc:	97ba                	add	a5,a5,a4
    80000bbe:	0007c483          	lbu	s1,0(a5) # ffffffff80000000 <end+0xfffffffefffd35b8>
    80000bc2:	34fd                	addiw	s1,s1,-1
    80000bc4:	0ff4f493          	zext.b	s1,s1
    80000bc8:	00978023          	sb	s1,0(a5)
    release(&reflock);
    80000bcc:	854e                	mv	a0,s3
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	306080e7          	jalr	774(ra) # 80000ed4 <release>
    if (ref == 0)
    80000bd6:	c881                	beqz	s1,80000be6 <kref_dec+0x5c>
}
    80000bd8:	70a2                	ld	ra,40(sp)
    80000bda:	7402                	ld	s0,32(sp)
    80000bdc:	64e2                	ld	s1,24(sp)
    80000bde:	6942                	ld	s2,16(sp)
    80000be0:	69a2                	ld	s3,8(sp)
    80000be2:	6145                	addi	sp,sp,48
    80000be4:	8082                	ret
        kfree(pa);
    80000be6:	854a                	mv	a0,s2
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	ec6080e7          	jalr	-314(ra) # 80000aae <kfree>
}
    80000bf0:	b7e5                	j	80000bd8 <kref_dec+0x4e>

0000000080000bf2 <freerange>:
{
    80000bf2:	7179                	addi	sp,sp,-48
    80000bf4:	f406                	sd	ra,40(sp)
    80000bf6:	f022                	sd	s0,32(sp)
    80000bf8:	ec26                	sd	s1,24(sp)
    80000bfa:	1800                	addi	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000bfc:	6785                	lui	a5,0x1
    80000bfe:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000c02:	00e504b3          	add	s1,a0,a4
    80000c06:	777d                	lui	a4,0xfffff
    80000c08:	8cf9                	and	s1,s1,a4
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000c0a:	94be                	add	s1,s1,a5
    80000c0c:	0295e463          	bltu	a1,s1,80000c34 <freerange+0x42>
    80000c10:	e84a                	sd	s2,16(sp)
    80000c12:	e44e                	sd	s3,8(sp)
    80000c14:	e052                	sd	s4,0(sp)
    80000c16:	892e                	mv	s2,a1
        kfree(p);
    80000c18:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000c1a:	6985                	lui	s3,0x1
        kfree(p);
    80000c1c:	01448533          	add	a0,s1,s4
    80000c20:	00000097          	auipc	ra,0x0
    80000c24:	e8e080e7          	jalr	-370(ra) # 80000aae <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000c28:	94ce                	add	s1,s1,s3
    80000c2a:	fe9979e3          	bgeu	s2,s1,80000c1c <freerange+0x2a>
    80000c2e:	6942                	ld	s2,16(sp)
    80000c30:	69a2                	ld	s3,8(sp)
    80000c32:	6a02                	ld	s4,0(sp)
}
    80000c34:	70a2                	ld	ra,40(sp)
    80000c36:	7402                	ld	s0,32(sp)
    80000c38:	64e2                	ld	s1,24(sp)
    80000c3a:	6145                	addi	sp,sp,48
    80000c3c:	8082                	ret

0000000080000c3e <kinit>:
{
    80000c3e:	1141                	addi	sp,sp,-16
    80000c40:	e406                	sd	ra,8(sp)
    80000c42:	e022                	sd	s0,0(sp)
    80000c44:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000c46:	00007597          	auipc	a1,0x7
    80000c4a:	44258593          	addi	a1,a1,1090 # 80008088 <__func__.1+0x80>
    80000c4e:	00013517          	auipc	a0,0x13
    80000c52:	bca50513          	addi	a0,a0,-1078 # 80013818 <kmem>
    80000c56:	00000097          	auipc	ra,0x0
    80000c5a:	13a080e7          	jalr	314(ra) # 80000d90 <initlock>
    initlock(&reflock, "refcounts");
    80000c5e:	00007597          	auipc	a1,0x7
    80000c62:	43258593          	addi	a1,a1,1074 # 80008090 <__func__.1+0x88>
    80000c66:	00013517          	auipc	a0,0x13
    80000c6a:	b9a50513          	addi	a0,a0,-1126 # 80013800 <reflock>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	122080e7          	jalr	290(ra) # 80000d90 <initlock>
    freerange(end, (void *)PHYSTOP);
    80000c76:	45c5                	li	a1,17
    80000c78:	05ee                	slli	a1,a1,0x1b
    80000c7a:	0002c517          	auipc	a0,0x2c
    80000c7e:	dce50513          	addi	a0,a0,-562 # 8002ca48 <end>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	f70080e7          	jalr	-144(ra) # 80000bf2 <freerange>
    MAX_PAGES = FREE_PAGES;
    80000c8a:	0000b797          	auipc	a5,0xb
    80000c8e:	8fe7b783          	ld	a5,-1794(a5) # 8000b588 <FREE_PAGES>
    80000c92:	0000b717          	auipc	a4,0xb
    80000c96:	8ef73f23          	sd	a5,-1794(a4) # 8000b590 <MAX_PAGES>
}
    80000c9a:	60a2                	ld	ra,8(sp)
    80000c9c:	6402                	ld	s0,0(sp)
    80000c9e:	0141                	addi	sp,sp,16
    80000ca0:	8082                	ret

0000000080000ca2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ca2:	1101                	addi	sp,sp,-32
    80000ca4:	ec06                	sd	ra,24(sp)
    80000ca6:	e822                	sd	s0,16(sp)
    80000ca8:	1000                	addi	s0,sp,32
    assert(FREE_PAGES > 0);
    80000caa:	0000b797          	auipc	a5,0xb
    80000cae:	8de7b783          	ld	a5,-1826(a5) # 8000b588 <FREE_PAGES>
    80000cb2:	cbd1                	beqz	a5,80000d46 <kalloc+0xa4>
    80000cb4:	e426                	sd	s1,8(sp)
    struct run *r;

    acquire(&kmem.lock);
    80000cb6:	00013517          	auipc	a0,0x13
    80000cba:	b6250513          	addi	a0,a0,-1182 # 80013818 <kmem>
    80000cbe:	00000097          	auipc	ra,0x0
    80000cc2:	162080e7          	jalr	354(ra) # 80000e20 <acquire>
    r = kmem.freelist;
    80000cc6:	00013497          	auipc	s1,0x13
    80000cca:	b6a4b483          	ld	s1,-1174(s1) # 80013830 <kmem+0x18>
    if (r)
    80000cce:	c8c5                	beqz	s1,80000d7e <kalloc+0xdc>
    80000cd0:	e04a                	sd	s2,0(sp)
        kmem.freelist = r->next;
    80000cd2:	609c                	ld	a5,0(s1)
    80000cd4:	00013917          	auipc	s2,0x13
    80000cd8:	b2c90913          	addi	s2,s2,-1236 # 80013800 <reflock>
    80000cdc:	02f93823          	sd	a5,48(s2)
    release(&kmem.lock);
    80000ce0:	00013517          	auipc	a0,0x13
    80000ce4:	b3850513          	addi	a0,a0,-1224 # 80013818 <kmem>
    80000ce8:	00000097          	auipc	ra,0x0
    80000cec:	1ec080e7          	jalr	492(ra) # 80000ed4 <release>

    if (r) {
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000cf0:	6605                	lui	a2,0x1
    80000cf2:	4595                	li	a1,5
    80000cf4:	8526                	mv	a0,s1
    80000cf6:	00000097          	auipc	ra,0x0
    80000cfa:	226080e7          	jalr	550(ra) # 80000f1c <memset>
        acquire(&reflock);
    80000cfe:	854a                	mv	a0,s2
    80000d00:	00000097          	auipc	ra,0x0
    80000d04:	120080e7          	jalr	288(ra) # 80000e20 <acquire>
    return (pa - KERNBASE) / PGSIZE;
    80000d08:	800007b7          	lui	a5,0x80000
    80000d0c:	97a6                	add	a5,a5,s1
    80000d0e:	83b1                	srli	a5,a5,0xc
        refcounts[pa_to_idx((uint64)r)] = 1;
    80000d10:	00013717          	auipc	a4,0x13
    80000d14:	b2870713          	addi	a4,a4,-1240 # 80013838 <refcounts>
    80000d18:	97ba                	add	a5,a5,a4
    80000d1a:	4705                	li	a4,1
    80000d1c:	00e78023          	sb	a4,0(a5) # ffffffff80000000 <end+0xfffffffefffd35b8>
        release(&reflock);
    80000d20:	854a                	mv	a0,s2
    80000d22:	00000097          	auipc	ra,0x0
    80000d26:	1b2080e7          	jalr	434(ra) # 80000ed4 <release>
    80000d2a:	6902                	ld	s2,0(sp)
    }
    FREE_PAGES--;
    80000d2c:	0000b717          	auipc	a4,0xb
    80000d30:	85c70713          	addi	a4,a4,-1956 # 8000b588 <FREE_PAGES>
    80000d34:	631c                	ld	a5,0(a4)
    80000d36:	17fd                	addi	a5,a5,-1
    80000d38:	e31c                	sd	a5,0(a4)
    return (void *)r;
}
    80000d3a:	8526                	mv	a0,s1
    80000d3c:	64a2                	ld	s1,8(sp)
    80000d3e:	60e2                	ld	ra,24(sp)
    80000d40:	6442                	ld	s0,16(sp)
    80000d42:	6105                	addi	sp,sp,32
    80000d44:	8082                	ret
    80000d46:	e426                	sd	s1,8(sp)
    80000d48:	e04a                	sd	s2,0(sp)
    assert(FREE_PAGES > 0);
    80000d4a:	06b00693          	li	a3,107
    80000d4e:	00007617          	auipc	a2,0x7
    80000d52:	2b260613          	addi	a2,a2,690 # 80008000 <etext>
    80000d56:	00007597          	auipc	a1,0x7
    80000d5a:	2fa58593          	addi	a1,a1,762 # 80008050 <__func__.1+0x48>
    80000d5e:	00007517          	auipc	a0,0x7
    80000d62:	30250513          	addi	a0,a0,770 # 80008060 <__func__.1+0x58>
    80000d66:	00000097          	auipc	ra,0x0
    80000d6a:	856080e7          	jalr	-1962(ra) # 800005bc <printf>
    80000d6e:	00007517          	auipc	a0,0x7
    80000d72:	30250513          	addi	a0,a0,770 # 80008070 <__func__.1+0x68>
    80000d76:	fffff097          	auipc	ra,0xfffff
    80000d7a:	7ea080e7          	jalr	2026(ra) # 80000560 <panic>
    release(&kmem.lock);
    80000d7e:	00013517          	auipc	a0,0x13
    80000d82:	a9a50513          	addi	a0,a0,-1382 # 80013818 <kmem>
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	14e080e7          	jalr	334(ra) # 80000ed4 <release>
    if (r) {
    80000d8e:	bf79                	j	80000d2c <kalloc+0x8a>

0000000080000d90 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000d90:	1141                	addi	sp,sp,-16
    80000d92:	e422                	sd	s0,8(sp)
    80000d94:	0800                	addi	s0,sp,16
  lk->name = name;
    80000d96:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000d98:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000d9c:	00053823          	sd	zero,16(a0)
}
    80000da0:	6422                	ld	s0,8(sp)
    80000da2:	0141                	addi	sp,sp,16
    80000da4:	8082                	ret

0000000080000da6 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000da6:	411c                	lw	a5,0(a0)
    80000da8:	e399                	bnez	a5,80000dae <holding+0x8>
    80000daa:	4501                	li	a0,0
  return r;
}
    80000dac:	8082                	ret
{
    80000dae:	1101                	addi	sp,sp,-32
    80000db0:	ec06                	sd	ra,24(sp)
    80000db2:	e822                	sd	s0,16(sp)
    80000db4:	e426                	sd	s1,8(sp)
    80000db6:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000db8:	6904                	ld	s1,16(a0)
    80000dba:	00001097          	auipc	ra,0x1
    80000dbe:	f4e080e7          	jalr	-178(ra) # 80001d08 <mycpu>
    80000dc2:	40a48533          	sub	a0,s1,a0
    80000dc6:	00153513          	seqz	a0,a0
}
    80000dca:	60e2                	ld	ra,24(sp)
    80000dcc:	6442                	ld	s0,16(sp)
    80000dce:	64a2                	ld	s1,8(sp)
    80000dd0:	6105                	addi	sp,sp,32
    80000dd2:	8082                	ret

0000000080000dd4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000dd4:	1101                	addi	sp,sp,-32
    80000dd6:	ec06                	sd	ra,24(sp)
    80000dd8:	e822                	sd	s0,16(sp)
    80000dda:	e426                	sd	s1,8(sp)
    80000ddc:	1000                	addi	s0,sp,32
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000dde:	100024f3          	csrr	s1,sstatus
    80000de2:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000de6:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000de8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000dec:	00001097          	auipc	ra,0x1
    80000df0:	f1c080e7          	jalr	-228(ra) # 80001d08 <mycpu>
    80000df4:	5d3c                	lw	a5,120(a0)
    80000df6:	cf89                	beqz	a5,80000e10 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000df8:	00001097          	auipc	ra,0x1
    80000dfc:	f10080e7          	jalr	-240(ra) # 80001d08 <mycpu>
    80000e00:	5d3c                	lw	a5,120(a0)
    80000e02:	2785                	addiw	a5,a5,1
    80000e04:	dd3c                	sw	a5,120(a0)
}
    80000e06:	60e2                	ld	ra,24(sp)
    80000e08:	6442                	ld	s0,16(sp)
    80000e0a:	64a2                	ld	s1,8(sp)
    80000e0c:	6105                	addi	sp,sp,32
    80000e0e:	8082                	ret
    mycpu()->intena = old;
    80000e10:	00001097          	auipc	ra,0x1
    80000e14:	ef8080e7          	jalr	-264(ra) # 80001d08 <mycpu>
    return (x & SSTATUS_SIE) != 0;
    80000e18:	8085                	srli	s1,s1,0x1
    80000e1a:	8885                	andi	s1,s1,1
    80000e1c:	dd64                	sw	s1,124(a0)
    80000e1e:	bfe9                	j	80000df8 <push_off+0x24>

0000000080000e20 <acquire>:
{
    80000e20:	1101                	addi	sp,sp,-32
    80000e22:	ec06                	sd	ra,24(sp)
    80000e24:	e822                	sd	s0,16(sp)
    80000e26:	e426                	sd	s1,8(sp)
    80000e28:	1000                	addi	s0,sp,32
    80000e2a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000e2c:	00000097          	auipc	ra,0x0
    80000e30:	fa8080e7          	jalr	-88(ra) # 80000dd4 <push_off>
  if(holding(lk))
    80000e34:	8526                	mv	a0,s1
    80000e36:	00000097          	auipc	ra,0x0
    80000e3a:	f70080e7          	jalr	-144(ra) # 80000da6 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000e3e:	4705                	li	a4,1
  if(holding(lk))
    80000e40:	e115                	bnez	a0,80000e64 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000e42:	87ba                	mv	a5,a4
    80000e44:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000e48:	2781                	sext.w	a5,a5
    80000e4a:	ffe5                	bnez	a5,80000e42 <acquire+0x22>
  __sync_synchronize();
    80000e4c:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000e50:	00001097          	auipc	ra,0x1
    80000e54:	eb8080e7          	jalr	-328(ra) # 80001d08 <mycpu>
    80000e58:	e888                	sd	a0,16(s1)
}
    80000e5a:	60e2                	ld	ra,24(sp)
    80000e5c:	6442                	ld	s0,16(sp)
    80000e5e:	64a2                	ld	s1,8(sp)
    80000e60:	6105                	addi	sp,sp,32
    80000e62:	8082                	ret
    panic("acquire");
    80000e64:	00007517          	auipc	a0,0x7
    80000e68:	23c50513          	addi	a0,a0,572 # 800080a0 <__func__.1+0x98>
    80000e6c:	fffff097          	auipc	ra,0xfffff
    80000e70:	6f4080e7          	jalr	1780(ra) # 80000560 <panic>

0000000080000e74 <pop_off>:

void
pop_off(void)
{
    80000e74:	1141                	addi	sp,sp,-16
    80000e76:	e406                	sd	ra,8(sp)
    80000e78:	e022                	sd	s0,0(sp)
    80000e7a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000e7c:	00001097          	auipc	ra,0x1
    80000e80:	e8c080e7          	jalr	-372(ra) # 80001d08 <mycpu>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000e84:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80000e88:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e8a:	e78d                	bnez	a5,80000eb4 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000e8c:	5d3c                	lw	a5,120(a0)
    80000e8e:	02f05b63          	blez	a5,80000ec4 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000e92:	37fd                	addiw	a5,a5,-1
    80000e94:	0007871b          	sext.w	a4,a5
    80000e98:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e9a:	eb09                	bnez	a4,80000eac <pop_off+0x38>
    80000e9c:	5d7c                	lw	a5,124(a0)
    80000e9e:	c799                	beqz	a5,80000eac <pop_off+0x38>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80000ea0:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000ea4:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80000ea8:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000eac:	60a2                	ld	ra,8(sp)
    80000eae:	6402                	ld	s0,0(sp)
    80000eb0:	0141                	addi	sp,sp,16
    80000eb2:	8082                	ret
    panic("pop_off - interruptible");
    80000eb4:	00007517          	auipc	a0,0x7
    80000eb8:	1f450513          	addi	a0,a0,500 # 800080a8 <__func__.1+0xa0>
    80000ebc:	fffff097          	auipc	ra,0xfffff
    80000ec0:	6a4080e7          	jalr	1700(ra) # 80000560 <panic>
    panic("pop_off");
    80000ec4:	00007517          	auipc	a0,0x7
    80000ec8:	1fc50513          	addi	a0,a0,508 # 800080c0 <__func__.1+0xb8>
    80000ecc:	fffff097          	auipc	ra,0xfffff
    80000ed0:	694080e7          	jalr	1684(ra) # 80000560 <panic>

0000000080000ed4 <release>:
{
    80000ed4:	1101                	addi	sp,sp,-32
    80000ed6:	ec06                	sd	ra,24(sp)
    80000ed8:	e822                	sd	s0,16(sp)
    80000eda:	e426                	sd	s1,8(sp)
    80000edc:	1000                	addi	s0,sp,32
    80000ede:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ee0:	00000097          	auipc	ra,0x0
    80000ee4:	ec6080e7          	jalr	-314(ra) # 80000da6 <holding>
    80000ee8:	c115                	beqz	a0,80000f0c <release+0x38>
  lk->cpu = 0;
    80000eea:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000eee:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000ef2:	0310000f          	fence	rw,w
    80000ef6:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000efa:	00000097          	auipc	ra,0x0
    80000efe:	f7a080e7          	jalr	-134(ra) # 80000e74 <pop_off>
}
    80000f02:	60e2                	ld	ra,24(sp)
    80000f04:	6442                	ld	s0,16(sp)
    80000f06:	64a2                	ld	s1,8(sp)
    80000f08:	6105                	addi	sp,sp,32
    80000f0a:	8082                	ret
    panic("release");
    80000f0c:	00007517          	auipc	a0,0x7
    80000f10:	1bc50513          	addi	a0,a0,444 # 800080c8 <__func__.1+0xc0>
    80000f14:	fffff097          	auipc	ra,0xfffff
    80000f18:	64c080e7          	jalr	1612(ra) # 80000560 <panic>

0000000080000f1c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000f1c:	1141                	addi	sp,sp,-16
    80000f1e:	e422                	sd	s0,8(sp)
    80000f20:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000f22:	ca19                	beqz	a2,80000f38 <memset+0x1c>
    80000f24:	87aa                	mv	a5,a0
    80000f26:	1602                	slli	a2,a2,0x20
    80000f28:	9201                	srli	a2,a2,0x20
    80000f2a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000f2e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000f32:	0785                	addi	a5,a5,1
    80000f34:	fee79de3          	bne	a5,a4,80000f2e <memset+0x12>
  }
  return dst;
}
    80000f38:	6422                	ld	s0,8(sp)
    80000f3a:	0141                	addi	sp,sp,16
    80000f3c:	8082                	ret

0000000080000f3e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000f3e:	1141                	addi	sp,sp,-16
    80000f40:	e422                	sd	s0,8(sp)
    80000f42:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000f44:	ca05                	beqz	a2,80000f74 <memcmp+0x36>
    80000f46:	fff6069b          	addiw	a3,a2,-1
    80000f4a:	1682                	slli	a3,a3,0x20
    80000f4c:	9281                	srli	a3,a3,0x20
    80000f4e:	0685                	addi	a3,a3,1
    80000f50:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000f52:	00054783          	lbu	a5,0(a0)
    80000f56:	0005c703          	lbu	a4,0(a1)
    80000f5a:	00e79863          	bne	a5,a4,80000f6a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000f5e:	0505                	addi	a0,a0,1
    80000f60:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000f62:	fed518e3          	bne	a0,a3,80000f52 <memcmp+0x14>
  }

  return 0;
    80000f66:	4501                	li	a0,0
    80000f68:	a019                	j	80000f6e <memcmp+0x30>
      return *s1 - *s2;
    80000f6a:	40e7853b          	subw	a0,a5,a4
}
    80000f6e:	6422                	ld	s0,8(sp)
    80000f70:	0141                	addi	sp,sp,16
    80000f72:	8082                	ret
  return 0;
    80000f74:	4501                	li	a0,0
    80000f76:	bfe5                	j	80000f6e <memcmp+0x30>

0000000080000f78 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000f78:	1141                	addi	sp,sp,-16
    80000f7a:	e422                	sd	s0,8(sp)
    80000f7c:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000f7e:	c205                	beqz	a2,80000f9e <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000f80:	02a5e263          	bltu	a1,a0,80000fa4 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000f84:	1602                	slli	a2,a2,0x20
    80000f86:	9201                	srli	a2,a2,0x20
    80000f88:	00c587b3          	add	a5,a1,a2
{
    80000f8c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000f8e:	0585                	addi	a1,a1,1
    80000f90:	0705                	addi	a4,a4,1
    80000f92:	fff5c683          	lbu	a3,-1(a1)
    80000f96:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000f9a:	feb79ae3          	bne	a5,a1,80000f8e <memmove+0x16>

  return dst;
}
    80000f9e:	6422                	ld	s0,8(sp)
    80000fa0:	0141                	addi	sp,sp,16
    80000fa2:	8082                	ret
  if(s < d && s + n > d){
    80000fa4:	02061693          	slli	a3,a2,0x20
    80000fa8:	9281                	srli	a3,a3,0x20
    80000faa:	00d58733          	add	a4,a1,a3
    80000fae:	fce57be3          	bgeu	a0,a4,80000f84 <memmove+0xc>
    d += n;
    80000fb2:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000fb4:	fff6079b          	addiw	a5,a2,-1
    80000fb8:	1782                	slli	a5,a5,0x20
    80000fba:	9381                	srli	a5,a5,0x20
    80000fbc:	fff7c793          	not	a5,a5
    80000fc0:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000fc2:	177d                	addi	a4,a4,-1
    80000fc4:	16fd                	addi	a3,a3,-1
    80000fc6:	00074603          	lbu	a2,0(a4)
    80000fca:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000fce:	fef71ae3          	bne	a4,a5,80000fc2 <memmove+0x4a>
    80000fd2:	b7f1                	j	80000f9e <memmove+0x26>

0000000080000fd4 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000fd4:	1141                	addi	sp,sp,-16
    80000fd6:	e406                	sd	ra,8(sp)
    80000fd8:	e022                	sd	s0,0(sp)
    80000fda:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000fdc:	00000097          	auipc	ra,0x0
    80000fe0:	f9c080e7          	jalr	-100(ra) # 80000f78 <memmove>
}
    80000fe4:	60a2                	ld	ra,8(sp)
    80000fe6:	6402                	ld	s0,0(sp)
    80000fe8:	0141                	addi	sp,sp,16
    80000fea:	8082                	ret

0000000080000fec <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000fec:	1141                	addi	sp,sp,-16
    80000fee:	e422                	sd	s0,8(sp)
    80000ff0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ff2:	ce11                	beqz	a2,8000100e <strncmp+0x22>
    80000ff4:	00054783          	lbu	a5,0(a0)
    80000ff8:	cf89                	beqz	a5,80001012 <strncmp+0x26>
    80000ffa:	0005c703          	lbu	a4,0(a1)
    80000ffe:	00f71a63          	bne	a4,a5,80001012 <strncmp+0x26>
    n--, p++, q++;
    80001002:	367d                	addiw	a2,a2,-1
    80001004:	0505                	addi	a0,a0,1
    80001006:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80001008:	f675                	bnez	a2,80000ff4 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000100a:	4501                	li	a0,0
    8000100c:	a801                	j	8000101c <strncmp+0x30>
    8000100e:	4501                	li	a0,0
    80001010:	a031                	j	8000101c <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80001012:	00054503          	lbu	a0,0(a0)
    80001016:	0005c783          	lbu	a5,0(a1)
    8000101a:	9d1d                	subw	a0,a0,a5
}
    8000101c:	6422                	ld	s0,8(sp)
    8000101e:	0141                	addi	sp,sp,16
    80001020:	8082                	ret

0000000080001022 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80001022:	1141                	addi	sp,sp,-16
    80001024:	e422                	sd	s0,8(sp)
    80001026:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80001028:	87aa                	mv	a5,a0
    8000102a:	86b2                	mv	a3,a2
    8000102c:	367d                	addiw	a2,a2,-1
    8000102e:	02d05563          	blez	a3,80001058 <strncpy+0x36>
    80001032:	0785                	addi	a5,a5,1
    80001034:	0005c703          	lbu	a4,0(a1)
    80001038:	fee78fa3          	sb	a4,-1(a5)
    8000103c:	0585                	addi	a1,a1,1
    8000103e:	f775                	bnez	a4,8000102a <strncpy+0x8>
    ;
  while(n-- > 0)
    80001040:	873e                	mv	a4,a5
    80001042:	9fb5                	addw	a5,a5,a3
    80001044:	37fd                	addiw	a5,a5,-1
    80001046:	00c05963          	blez	a2,80001058 <strncpy+0x36>
    *s++ = 0;
    8000104a:	0705                	addi	a4,a4,1
    8000104c:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80001050:	40e786bb          	subw	a3,a5,a4
    80001054:	fed04be3          	bgtz	a3,8000104a <strncpy+0x28>
  return os;
}
    80001058:	6422                	ld	s0,8(sp)
    8000105a:	0141                	addi	sp,sp,16
    8000105c:	8082                	ret

000000008000105e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    8000105e:	1141                	addi	sp,sp,-16
    80001060:	e422                	sd	s0,8(sp)
    80001062:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80001064:	02c05363          	blez	a2,8000108a <safestrcpy+0x2c>
    80001068:	fff6069b          	addiw	a3,a2,-1
    8000106c:	1682                	slli	a3,a3,0x20
    8000106e:	9281                	srli	a3,a3,0x20
    80001070:	96ae                	add	a3,a3,a1
    80001072:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001074:	00d58963          	beq	a1,a3,80001086 <safestrcpy+0x28>
    80001078:	0585                	addi	a1,a1,1
    8000107a:	0785                	addi	a5,a5,1
    8000107c:	fff5c703          	lbu	a4,-1(a1)
    80001080:	fee78fa3          	sb	a4,-1(a5)
    80001084:	fb65                	bnez	a4,80001074 <safestrcpy+0x16>
    ;
  *s = 0;
    80001086:	00078023          	sb	zero,0(a5)
  return os;
}
    8000108a:	6422                	ld	s0,8(sp)
    8000108c:	0141                	addi	sp,sp,16
    8000108e:	8082                	ret

0000000080001090 <strlen>:

int
strlen(const char *s)
{
    80001090:	1141                	addi	sp,sp,-16
    80001092:	e422                	sd	s0,8(sp)
    80001094:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001096:	00054783          	lbu	a5,0(a0)
    8000109a:	cf91                	beqz	a5,800010b6 <strlen+0x26>
    8000109c:	0505                	addi	a0,a0,1
    8000109e:	87aa                	mv	a5,a0
    800010a0:	86be                	mv	a3,a5
    800010a2:	0785                	addi	a5,a5,1
    800010a4:	fff7c703          	lbu	a4,-1(a5)
    800010a8:	ff65                	bnez	a4,800010a0 <strlen+0x10>
    800010aa:	40a6853b          	subw	a0,a3,a0
    800010ae:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    800010b0:	6422                	ld	s0,8(sp)
    800010b2:	0141                	addi	sp,sp,16
    800010b4:	8082                	ret
  for(n = 0; s[n]; n++)
    800010b6:	4501                	li	a0,0
    800010b8:	bfe5                	j	800010b0 <strlen+0x20>

00000000800010ba <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800010ba:	1141                	addi	sp,sp,-16
    800010bc:	e406                	sd	ra,8(sp)
    800010be:	e022                	sd	s0,0(sp)
    800010c0:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800010c2:	00001097          	auipc	ra,0x1
    800010c6:	c36080e7          	jalr	-970(ra) # 80001cf8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800010ca:	0000a717          	auipc	a4,0xa
    800010ce:	4ce70713          	addi	a4,a4,1230 # 8000b598 <started>
  if(cpuid() == 0){
    800010d2:	c139                	beqz	a0,80001118 <main+0x5e>
    while(started == 0)
    800010d4:	431c                	lw	a5,0(a4)
    800010d6:	2781                	sext.w	a5,a5
    800010d8:	dff5                	beqz	a5,800010d4 <main+0x1a>
      ;
    __sync_synchronize();
    800010da:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    800010de:	00001097          	auipc	ra,0x1
    800010e2:	c1a080e7          	jalr	-998(ra) # 80001cf8 <cpuid>
    800010e6:	85aa                	mv	a1,a0
    800010e8:	00007517          	auipc	a0,0x7
    800010ec:	00050513          	mv	a0,a0
    800010f0:	fffff097          	auipc	ra,0xfffff
    800010f4:	4cc080e7          	jalr	1228(ra) # 800005bc <printf>
    kvminithart();    // turn on paging
    800010f8:	00000097          	auipc	ra,0x0
    800010fc:	0d8080e7          	jalr	216(ra) # 800011d0 <kvminithart>
    trapinithart();   // install kernel trap vector
    80001100:	00002097          	auipc	ra,0x2
    80001104:	aae080e7          	jalr	-1362(ra) # 80002bae <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001108:	00005097          	auipc	ra,0x5
    8000110c:	35c080e7          	jalr	860(ra) # 80006464 <plicinithart>
  }

  scheduler();        
    80001110:	00001097          	auipc	ra,0x1
    80001114:	2a4080e7          	jalr	676(ra) # 800023b4 <scheduler>
    consoleinit();
    80001118:	fffff097          	auipc	ra,0xfffff
    8000111c:	358080e7          	jalr	856(ra) # 80000470 <consoleinit>
    printfinit();
    80001120:	fffff097          	auipc	ra,0xfffff
    80001124:	6a4080e7          	jalr	1700(ra) # 800007c4 <printfinit>
    printf("\n");
    80001128:	00007517          	auipc	a0,0x7
    8000112c:	ef850513          	addi	a0,a0,-264 # 80008020 <__func__.1+0x18>
    80001130:	fffff097          	auipc	ra,0xfffff
    80001134:	48c080e7          	jalr	1164(ra) # 800005bc <printf>
    printf("xv6 kernel is booting\n");
    80001138:	00007517          	auipc	a0,0x7
    8000113c:	f9850513          	addi	a0,a0,-104 # 800080d0 <__func__.1+0xc8>
    80001140:	fffff097          	auipc	ra,0xfffff
    80001144:	47c080e7          	jalr	1148(ra) # 800005bc <printf>
    printf("\n");
    80001148:	00007517          	auipc	a0,0x7
    8000114c:	ed850513          	addi	a0,a0,-296 # 80008020 <__func__.1+0x18>
    80001150:	fffff097          	auipc	ra,0xfffff
    80001154:	46c080e7          	jalr	1132(ra) # 800005bc <printf>
    kinit();         // physical page allocator
    80001158:	00000097          	auipc	ra,0x0
    8000115c:	ae6080e7          	jalr	-1306(ra) # 80000c3e <kinit>
    kvminit();       // create kernel page table
    80001160:	00000097          	auipc	ra,0x0
    80001164:	326080e7          	jalr	806(ra) # 80001486 <kvminit>
    kvminithart();   // turn on paging
    80001168:	00000097          	auipc	ra,0x0
    8000116c:	068080e7          	jalr	104(ra) # 800011d0 <kvminithart>
    procinit();      // process table
    80001170:	00001097          	auipc	ra,0x1
    80001174:	aa2080e7          	jalr	-1374(ra) # 80001c12 <procinit>
    trapinit();      // trap vectors
    80001178:	00002097          	auipc	ra,0x2
    8000117c:	a0e080e7          	jalr	-1522(ra) # 80002b86 <trapinit>
    trapinithart();  // install kernel trap vector
    80001180:	00002097          	auipc	ra,0x2
    80001184:	a2e080e7          	jalr	-1490(ra) # 80002bae <trapinithart>
    plicinit();      // set up interrupt controller
    80001188:	00005097          	auipc	ra,0x5
    8000118c:	2c2080e7          	jalr	706(ra) # 8000644a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001190:	00005097          	auipc	ra,0x5
    80001194:	2d4080e7          	jalr	724(ra) # 80006464 <plicinithart>
    binit();         // buffer cache
    80001198:	00002097          	auipc	ra,0x2
    8000119c:	39c080e7          	jalr	924(ra) # 80003534 <binit>
    iinit();         // inode table
    800011a0:	00003097          	auipc	ra,0x3
    800011a4:	a52080e7          	jalr	-1454(ra) # 80003bf2 <iinit>
    fileinit();      // file table
    800011a8:	00004097          	auipc	ra,0x4
    800011ac:	a02080e7          	jalr	-1534(ra) # 80004baa <fileinit>
    virtio_disk_init(); // emulated hard disk
    800011b0:	00005097          	auipc	ra,0x5
    800011b4:	3bc080e7          	jalr	956(ra) # 8000656c <virtio_disk_init>
    userinit();      // first user process
    800011b8:	00001097          	auipc	ra,0x1
    800011bc:	e44080e7          	jalr	-444(ra) # 80001ffc <userinit>
    __sync_synchronize();
    800011c0:	0330000f          	fence	rw,rw
    started = 1;
    800011c4:	4785                	li	a5,1
    800011c6:	0000a717          	auipc	a4,0xa
    800011ca:	3cf72923          	sw	a5,978(a4) # 8000b598 <started>
    800011ce:	b789                	j	80001110 <main+0x56>

00000000800011d0 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800011d0:	1141                	addi	sp,sp,-16
    800011d2:	e422                	sd	s0,8(sp)
    800011d4:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
    // the zero, zero means flush all TLB entries.
    asm volatile("sfence.vma zero, zero");
    800011d6:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800011da:	0000a797          	auipc	a5,0xa
    800011de:	3c67b783          	ld	a5,966(a5) # 8000b5a0 <kernel_pagetable>
    800011e2:	83b1                	srli	a5,a5,0xc
    800011e4:	577d                	li	a4,-1
    800011e6:	177e                	slli	a4,a4,0x3f
    800011e8:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    800011ea:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma zero, zero");
    800011ee:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800011f2:	6422                	ld	s0,8(sp)
    800011f4:	0141                	addi	sp,sp,16
    800011f6:	8082                	ret

00000000800011f8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800011f8:	7139                	addi	sp,sp,-64
    800011fa:	fc06                	sd	ra,56(sp)
    800011fc:	f822                	sd	s0,48(sp)
    800011fe:	f426                	sd	s1,40(sp)
    80001200:	f04a                	sd	s2,32(sp)
    80001202:	ec4e                	sd	s3,24(sp)
    80001204:	e852                	sd	s4,16(sp)
    80001206:	e456                	sd	s5,8(sp)
    80001208:	e05a                	sd	s6,0(sp)
    8000120a:	0080                	addi	s0,sp,64
    8000120c:	84aa                	mv	s1,a0
    8000120e:	89ae                	mv	s3,a1
    80001210:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001212:	57fd                	li	a5,-1
    80001214:	83e9                	srli	a5,a5,0x1a
    80001216:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001218:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000121a:	04b7f263          	bgeu	a5,a1,8000125e <walk+0x66>
    panic("walk");
    8000121e:	00007517          	auipc	a0,0x7
    80001222:	ee250513          	addi	a0,a0,-286 # 80008100 <__func__.1+0xf8>
    80001226:	fffff097          	auipc	ra,0xfffff
    8000122a:	33a080e7          	jalr	826(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000122e:	060a8663          	beqz	s5,8000129a <walk+0xa2>
    80001232:	00000097          	auipc	ra,0x0
    80001236:	a70080e7          	jalr	-1424(ra) # 80000ca2 <kalloc>
    8000123a:	84aa                	mv	s1,a0
    8000123c:	c529                	beqz	a0,80001286 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000123e:	6605                	lui	a2,0x1
    80001240:	4581                	li	a1,0
    80001242:	00000097          	auipc	ra,0x0
    80001246:	cda080e7          	jalr	-806(ra) # 80000f1c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000124a:	00c4d793          	srli	a5,s1,0xc
    8000124e:	07aa                	slli	a5,a5,0xa
    80001250:	0017e793          	ori	a5,a5,1
    80001254:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001258:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd25af>
    8000125a:	036a0063          	beq	s4,s6,8000127a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000125e:	0149d933          	srl	s2,s3,s4
    80001262:	1ff97913          	andi	s2,s2,511
    80001266:	090e                	slli	s2,s2,0x3
    80001268:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000126a:	00093483          	ld	s1,0(s2)
    8000126e:	0014f793          	andi	a5,s1,1
    80001272:	dfd5                	beqz	a5,8000122e <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001274:	80a9                	srli	s1,s1,0xa
    80001276:	04b2                	slli	s1,s1,0xc
    80001278:	b7c5                	j	80001258 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000127a:	00c9d513          	srli	a0,s3,0xc
    8000127e:	1ff57513          	andi	a0,a0,511
    80001282:	050e                	slli	a0,a0,0x3
    80001284:	9526                	add	a0,a0,s1
}
    80001286:	70e2                	ld	ra,56(sp)
    80001288:	7442                	ld	s0,48(sp)
    8000128a:	74a2                	ld	s1,40(sp)
    8000128c:	7902                	ld	s2,32(sp)
    8000128e:	69e2                	ld	s3,24(sp)
    80001290:	6a42                	ld	s4,16(sp)
    80001292:	6aa2                	ld	s5,8(sp)
    80001294:	6b02                	ld	s6,0(sp)
    80001296:	6121                	addi	sp,sp,64
    80001298:	8082                	ret
        return 0;
    8000129a:	4501                	li	a0,0
    8000129c:	b7ed                	j	80001286 <walk+0x8e>

000000008000129e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000129e:	57fd                	li	a5,-1
    800012a0:	83e9                	srli	a5,a5,0x1a
    800012a2:	00b7f463          	bgeu	a5,a1,800012aa <walkaddr+0xc>
    return 0;
    800012a6:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800012a8:	8082                	ret
{
    800012aa:	1141                	addi	sp,sp,-16
    800012ac:	e406                	sd	ra,8(sp)
    800012ae:	e022                	sd	s0,0(sp)
    800012b0:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800012b2:	4601                	li	a2,0
    800012b4:	00000097          	auipc	ra,0x0
    800012b8:	f44080e7          	jalr	-188(ra) # 800011f8 <walk>
  if(pte == 0)
    800012bc:	c105                	beqz	a0,800012dc <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800012be:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800012c0:	0117f693          	andi	a3,a5,17
    800012c4:	4745                	li	a4,17
    return 0;
    800012c6:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800012c8:	00e68663          	beq	a3,a4,800012d4 <walkaddr+0x36>
}
    800012cc:	60a2                	ld	ra,8(sp)
    800012ce:	6402                	ld	s0,0(sp)
    800012d0:	0141                	addi	sp,sp,16
    800012d2:	8082                	ret
  pa = PTE2PA(*pte);
    800012d4:	83a9                	srli	a5,a5,0xa
    800012d6:	00c79513          	slli	a0,a5,0xc
  return pa;
    800012da:	bfcd                	j	800012cc <walkaddr+0x2e>
    return 0;
    800012dc:	4501                	li	a0,0
    800012de:	b7fd                	j	800012cc <walkaddr+0x2e>

00000000800012e0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800012e0:	715d                	addi	sp,sp,-80
    800012e2:	e486                	sd	ra,72(sp)
    800012e4:	e0a2                	sd	s0,64(sp)
    800012e6:	fc26                	sd	s1,56(sp)
    800012e8:	f84a                	sd	s2,48(sp)
    800012ea:	f44e                	sd	s3,40(sp)
    800012ec:	f052                	sd	s4,32(sp)
    800012ee:	ec56                	sd	s5,24(sp)
    800012f0:	e85a                	sd	s6,16(sp)
    800012f2:	e45e                	sd	s7,8(sp)
    800012f4:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800012f6:	c639                	beqz	a2,80001344 <mappages+0x64>
    800012f8:	8aaa                	mv	s5,a0
    800012fa:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800012fc:	777d                	lui	a4,0xfffff
    800012fe:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001302:	fff58993          	addi	s3,a1,-1
    80001306:	99b2                	add	s3,s3,a2
    80001308:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000130c:	893e                	mv	s2,a5
    8000130e:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001312:	6b85                	lui	s7,0x1
    80001314:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001318:	4605                	li	a2,1
    8000131a:	85ca                	mv	a1,s2
    8000131c:	8556                	mv	a0,s5
    8000131e:	00000097          	auipc	ra,0x0
    80001322:	eda080e7          	jalr	-294(ra) # 800011f8 <walk>
    80001326:	cd1d                	beqz	a0,80001364 <mappages+0x84>
    if(*pte & PTE_V)
    80001328:	611c                	ld	a5,0(a0)
    8000132a:	8b85                	andi	a5,a5,1
    8000132c:	e785                	bnez	a5,80001354 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000132e:	80b1                	srli	s1,s1,0xc
    80001330:	04aa                	slli	s1,s1,0xa
    80001332:	0164e4b3          	or	s1,s1,s6
    80001336:	0014e493          	ori	s1,s1,1
    8000133a:	e104                	sd	s1,0(a0)
    if(a == last)
    8000133c:	05390063          	beq	s2,s3,8000137c <mappages+0x9c>
    a += PGSIZE;
    80001340:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001342:	bfc9                	j	80001314 <mappages+0x34>
    panic("mappages: size");
    80001344:	00007517          	auipc	a0,0x7
    80001348:	dc450513          	addi	a0,a0,-572 # 80008108 <__func__.1+0x100>
    8000134c:	fffff097          	auipc	ra,0xfffff
    80001350:	214080e7          	jalr	532(ra) # 80000560 <panic>
      panic("mappages: remap");
    80001354:	00007517          	auipc	a0,0x7
    80001358:	dc450513          	addi	a0,a0,-572 # 80008118 <__func__.1+0x110>
    8000135c:	fffff097          	auipc	ra,0xfffff
    80001360:	204080e7          	jalr	516(ra) # 80000560 <panic>
      return -1;
    80001364:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001366:	60a6                	ld	ra,72(sp)
    80001368:	6406                	ld	s0,64(sp)
    8000136a:	74e2                	ld	s1,56(sp)
    8000136c:	7942                	ld	s2,48(sp)
    8000136e:	79a2                	ld	s3,40(sp)
    80001370:	7a02                	ld	s4,32(sp)
    80001372:	6ae2                	ld	s5,24(sp)
    80001374:	6b42                	ld	s6,16(sp)
    80001376:	6ba2                	ld	s7,8(sp)
    80001378:	6161                	addi	sp,sp,80
    8000137a:	8082                	ret
  return 0;
    8000137c:	4501                	li	a0,0
    8000137e:	b7e5                	j	80001366 <mappages+0x86>

0000000080001380 <kvmmap>:
{
    80001380:	1141                	addi	sp,sp,-16
    80001382:	e406                	sd	ra,8(sp)
    80001384:	e022                	sd	s0,0(sp)
    80001386:	0800                	addi	s0,sp,16
    80001388:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000138a:	86b2                	mv	a3,a2
    8000138c:	863e                	mv	a2,a5
    8000138e:	00000097          	auipc	ra,0x0
    80001392:	f52080e7          	jalr	-174(ra) # 800012e0 <mappages>
    80001396:	e509                	bnez	a0,800013a0 <kvmmap+0x20>
}
    80001398:	60a2                	ld	ra,8(sp)
    8000139a:	6402                	ld	s0,0(sp)
    8000139c:	0141                	addi	sp,sp,16
    8000139e:	8082                	ret
    panic("kvmmap");
    800013a0:	00007517          	auipc	a0,0x7
    800013a4:	d8850513          	addi	a0,a0,-632 # 80008128 <__func__.1+0x120>
    800013a8:	fffff097          	auipc	ra,0xfffff
    800013ac:	1b8080e7          	jalr	440(ra) # 80000560 <panic>

00000000800013b0 <kvmmake>:
{
    800013b0:	1101                	addi	sp,sp,-32
    800013b2:	ec06                	sd	ra,24(sp)
    800013b4:	e822                	sd	s0,16(sp)
    800013b6:	e426                	sd	s1,8(sp)
    800013b8:	e04a                	sd	s2,0(sp)
    800013ba:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800013bc:	00000097          	auipc	ra,0x0
    800013c0:	8e6080e7          	jalr	-1818(ra) # 80000ca2 <kalloc>
    800013c4:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800013c6:	6605                	lui	a2,0x1
    800013c8:	4581                	li	a1,0
    800013ca:	00000097          	auipc	ra,0x0
    800013ce:	b52080e7          	jalr	-1198(ra) # 80000f1c <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800013d2:	4719                	li	a4,6
    800013d4:	6685                	lui	a3,0x1
    800013d6:	10000637          	lui	a2,0x10000
    800013da:	100005b7          	lui	a1,0x10000
    800013de:	8526                	mv	a0,s1
    800013e0:	00000097          	auipc	ra,0x0
    800013e4:	fa0080e7          	jalr	-96(ra) # 80001380 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800013e8:	4719                	li	a4,6
    800013ea:	6685                	lui	a3,0x1
    800013ec:	10001637          	lui	a2,0x10001
    800013f0:	100015b7          	lui	a1,0x10001
    800013f4:	8526                	mv	a0,s1
    800013f6:	00000097          	auipc	ra,0x0
    800013fa:	f8a080e7          	jalr	-118(ra) # 80001380 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800013fe:	4719                	li	a4,6
    80001400:	004006b7          	lui	a3,0x400
    80001404:	0c000637          	lui	a2,0xc000
    80001408:	0c0005b7          	lui	a1,0xc000
    8000140c:	8526                	mv	a0,s1
    8000140e:	00000097          	auipc	ra,0x0
    80001412:	f72080e7          	jalr	-142(ra) # 80001380 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001416:	00007917          	auipc	s2,0x7
    8000141a:	bea90913          	addi	s2,s2,-1046 # 80008000 <etext>
    8000141e:	4729                	li	a4,10
    80001420:	80007697          	auipc	a3,0x80007
    80001424:	be068693          	addi	a3,a3,-1056 # 8000 <_entry-0x7fff8000>
    80001428:	4605                	li	a2,1
    8000142a:	067e                	slli	a2,a2,0x1f
    8000142c:	85b2                	mv	a1,a2
    8000142e:	8526                	mv	a0,s1
    80001430:	00000097          	auipc	ra,0x0
    80001434:	f50080e7          	jalr	-176(ra) # 80001380 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001438:	46c5                	li	a3,17
    8000143a:	06ee                	slli	a3,a3,0x1b
    8000143c:	4719                	li	a4,6
    8000143e:	412686b3          	sub	a3,a3,s2
    80001442:	864a                	mv	a2,s2
    80001444:	85ca                	mv	a1,s2
    80001446:	8526                	mv	a0,s1
    80001448:	00000097          	auipc	ra,0x0
    8000144c:	f38080e7          	jalr	-200(ra) # 80001380 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001450:	4729                	li	a4,10
    80001452:	6685                	lui	a3,0x1
    80001454:	00006617          	auipc	a2,0x6
    80001458:	bac60613          	addi	a2,a2,-1108 # 80007000 <_trampoline>
    8000145c:	040005b7          	lui	a1,0x4000
    80001460:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001462:	05b2                	slli	a1,a1,0xc
    80001464:	8526                	mv	a0,s1
    80001466:	00000097          	auipc	ra,0x0
    8000146a:	f1a080e7          	jalr	-230(ra) # 80001380 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000146e:	8526                	mv	a0,s1
    80001470:	00000097          	auipc	ra,0x0
    80001474:	6fe080e7          	jalr	1790(ra) # 80001b6e <proc_mapstacks>
}
    80001478:	8526                	mv	a0,s1
    8000147a:	60e2                	ld	ra,24(sp)
    8000147c:	6442                	ld	s0,16(sp)
    8000147e:	64a2                	ld	s1,8(sp)
    80001480:	6902                	ld	s2,0(sp)
    80001482:	6105                	addi	sp,sp,32
    80001484:	8082                	ret

0000000080001486 <kvminit>:
{
    80001486:	1141                	addi	sp,sp,-16
    80001488:	e406                	sd	ra,8(sp)
    8000148a:	e022                	sd	s0,0(sp)
    8000148c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000148e:	00000097          	auipc	ra,0x0
    80001492:	f22080e7          	jalr	-222(ra) # 800013b0 <kvmmake>
    80001496:	0000a797          	auipc	a5,0xa
    8000149a:	10a7b523          	sd	a0,266(a5) # 8000b5a0 <kernel_pagetable>
}
    8000149e:	60a2                	ld	ra,8(sp)
    800014a0:	6402                	ld	s0,0(sp)
    800014a2:	0141                	addi	sp,sp,16
    800014a4:	8082                	ret

00000000800014a6 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800014a6:	715d                	addi	sp,sp,-80
    800014a8:	e486                	sd	ra,72(sp)
    800014aa:	e0a2                	sd	s0,64(sp)
    800014ac:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800014ae:	03459793          	slli	a5,a1,0x34
    800014b2:	e39d                	bnez	a5,800014d8 <uvmunmap+0x32>
    800014b4:	f84a                	sd	s2,48(sp)
    800014b6:	f44e                	sd	s3,40(sp)
    800014b8:	f052                	sd	s4,32(sp)
    800014ba:	ec56                	sd	s5,24(sp)
    800014bc:	e85a                	sd	s6,16(sp)
    800014be:	e45e                	sd	s7,8(sp)
    800014c0:	8a2a                	mv	s4,a0
    800014c2:	892e                	mv	s2,a1
    800014c4:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014c6:	0632                	slli	a2,a2,0xc
    800014c8:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800014cc:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014ce:	6b05                	lui	s6,0x1
    800014d0:	0935fb63          	bgeu	a1,s3,80001566 <uvmunmap+0xc0>
    800014d4:	fc26                	sd	s1,56(sp)
    800014d6:	a8a9                	j	80001530 <uvmunmap+0x8a>
    800014d8:	fc26                	sd	s1,56(sp)
    800014da:	f84a                	sd	s2,48(sp)
    800014dc:	f44e                	sd	s3,40(sp)
    800014de:	f052                	sd	s4,32(sp)
    800014e0:	ec56                	sd	s5,24(sp)
    800014e2:	e85a                	sd	s6,16(sp)
    800014e4:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800014e6:	00007517          	auipc	a0,0x7
    800014ea:	c4a50513          	addi	a0,a0,-950 # 80008130 <__func__.1+0x128>
    800014ee:	fffff097          	auipc	ra,0xfffff
    800014f2:	072080e7          	jalr	114(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    800014f6:	00007517          	auipc	a0,0x7
    800014fa:	c5250513          	addi	a0,a0,-942 # 80008148 <__func__.1+0x140>
    800014fe:	fffff097          	auipc	ra,0xfffff
    80001502:	062080e7          	jalr	98(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    80001506:	00007517          	auipc	a0,0x7
    8000150a:	c5250513          	addi	a0,a0,-942 # 80008158 <__func__.1+0x150>
    8000150e:	fffff097          	auipc	ra,0xfffff
    80001512:	052080e7          	jalr	82(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    80001516:	00007517          	auipc	a0,0x7
    8000151a:	c5a50513          	addi	a0,a0,-934 # 80008170 <__func__.1+0x168>
    8000151e:	fffff097          	auipc	ra,0xfffff
    80001522:	042080e7          	jalr	66(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kref_dec((void*)pa);
    }
    *pte = 0;
    80001526:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000152a:	995a                	add	s2,s2,s6
    8000152c:	03397c63          	bgeu	s2,s3,80001564 <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001530:	4601                	li	a2,0
    80001532:	85ca                	mv	a1,s2
    80001534:	8552                	mv	a0,s4
    80001536:	00000097          	auipc	ra,0x0
    8000153a:	cc2080e7          	jalr	-830(ra) # 800011f8 <walk>
    8000153e:	84aa                	mv	s1,a0
    80001540:	d95d                	beqz	a0,800014f6 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    80001542:	6108                	ld	a0,0(a0)
    80001544:	00157793          	andi	a5,a0,1
    80001548:	dfdd                	beqz	a5,80001506 <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000154a:	3ff57793          	andi	a5,a0,1023
    8000154e:	fd7784e3          	beq	a5,s7,80001516 <uvmunmap+0x70>
    if(do_free){
    80001552:	fc0a8ae3          	beqz	s5,80001526 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    80001556:	8129                	srli	a0,a0,0xa
      kref_dec((void*)pa);
    80001558:	0532                	slli	a0,a0,0xc
    8000155a:	fffff097          	auipc	ra,0xfffff
    8000155e:	630080e7          	jalr	1584(ra) # 80000b8a <kref_dec>
    80001562:	b7d1                	j	80001526 <uvmunmap+0x80>
    80001564:	74e2                	ld	s1,56(sp)
    80001566:	7942                	ld	s2,48(sp)
    80001568:	79a2                	ld	s3,40(sp)
    8000156a:	7a02                	ld	s4,32(sp)
    8000156c:	6ae2                	ld	s5,24(sp)
    8000156e:	6b42                	ld	s6,16(sp)
    80001570:	6ba2                	ld	s7,8(sp)
  }
}
    80001572:	60a6                	ld	ra,72(sp)
    80001574:	6406                	ld	s0,64(sp)
    80001576:	6161                	addi	sp,sp,80
    80001578:	8082                	ret

000000008000157a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000157a:	1101                	addi	sp,sp,-32
    8000157c:	ec06                	sd	ra,24(sp)
    8000157e:	e822                	sd	s0,16(sp)
    80001580:	e426                	sd	s1,8(sp)
    80001582:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001584:	fffff097          	auipc	ra,0xfffff
    80001588:	71e080e7          	jalr	1822(ra) # 80000ca2 <kalloc>
    8000158c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000158e:	c519                	beqz	a0,8000159c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001590:	6605                	lui	a2,0x1
    80001592:	4581                	li	a1,0
    80001594:	00000097          	auipc	ra,0x0
    80001598:	988080e7          	jalr	-1656(ra) # 80000f1c <memset>
  return pagetable;
}
    8000159c:	8526                	mv	a0,s1
    8000159e:	60e2                	ld	ra,24(sp)
    800015a0:	6442                	ld	s0,16(sp)
    800015a2:	64a2                	ld	s1,8(sp)
    800015a4:	6105                	addi	sp,sp,32
    800015a6:	8082                	ret

00000000800015a8 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800015a8:	7179                	addi	sp,sp,-48
    800015aa:	f406                	sd	ra,40(sp)
    800015ac:	f022                	sd	s0,32(sp)
    800015ae:	ec26                	sd	s1,24(sp)
    800015b0:	e84a                	sd	s2,16(sp)
    800015b2:	e44e                	sd	s3,8(sp)
    800015b4:	e052                	sd	s4,0(sp)
    800015b6:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800015b8:	6785                	lui	a5,0x1
    800015ba:	04f67863          	bgeu	a2,a5,8000160a <uvmfirst+0x62>
    800015be:	8a2a                	mv	s4,a0
    800015c0:	89ae                	mv	s3,a1
    800015c2:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800015c4:	fffff097          	auipc	ra,0xfffff
    800015c8:	6de080e7          	jalr	1758(ra) # 80000ca2 <kalloc>
    800015cc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800015ce:	6605                	lui	a2,0x1
    800015d0:	4581                	li	a1,0
    800015d2:	00000097          	auipc	ra,0x0
    800015d6:	94a080e7          	jalr	-1718(ra) # 80000f1c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800015da:	4779                	li	a4,30
    800015dc:	86ca                	mv	a3,s2
    800015de:	6605                	lui	a2,0x1
    800015e0:	4581                	li	a1,0
    800015e2:	8552                	mv	a0,s4
    800015e4:	00000097          	auipc	ra,0x0
    800015e8:	cfc080e7          	jalr	-772(ra) # 800012e0 <mappages>
  memmove(mem, src, sz);
    800015ec:	8626                	mv	a2,s1
    800015ee:	85ce                	mv	a1,s3
    800015f0:	854a                	mv	a0,s2
    800015f2:	00000097          	auipc	ra,0x0
    800015f6:	986080e7          	jalr	-1658(ra) # 80000f78 <memmove>
}
    800015fa:	70a2                	ld	ra,40(sp)
    800015fc:	7402                	ld	s0,32(sp)
    800015fe:	64e2                	ld	s1,24(sp)
    80001600:	6942                	ld	s2,16(sp)
    80001602:	69a2                	ld	s3,8(sp)
    80001604:	6a02                	ld	s4,0(sp)
    80001606:	6145                	addi	sp,sp,48
    80001608:	8082                	ret
    panic("uvmfirst: more than a page");
    8000160a:	00007517          	auipc	a0,0x7
    8000160e:	b7e50513          	addi	a0,a0,-1154 # 80008188 <__func__.1+0x180>
    80001612:	fffff097          	auipc	ra,0xfffff
    80001616:	f4e080e7          	jalr	-178(ra) # 80000560 <panic>

000000008000161a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000161a:	1101                	addi	sp,sp,-32
    8000161c:	ec06                	sd	ra,24(sp)
    8000161e:	e822                	sd	s0,16(sp)
    80001620:	e426                	sd	s1,8(sp)
    80001622:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001624:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001626:	00b67d63          	bgeu	a2,a1,80001640 <uvmdealloc+0x26>
    8000162a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000162c:	6785                	lui	a5,0x1
    8000162e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001630:	00f60733          	add	a4,a2,a5
    80001634:	76fd                	lui	a3,0xfffff
    80001636:	8f75                	and	a4,a4,a3
    80001638:	97ae                	add	a5,a5,a1
    8000163a:	8ff5                	and	a5,a5,a3
    8000163c:	00f76863          	bltu	a4,a5,8000164c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001640:	8526                	mv	a0,s1
    80001642:	60e2                	ld	ra,24(sp)
    80001644:	6442                	ld	s0,16(sp)
    80001646:	64a2                	ld	s1,8(sp)
    80001648:	6105                	addi	sp,sp,32
    8000164a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000164c:	8f99                	sub	a5,a5,a4
    8000164e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001650:	4685                	li	a3,1
    80001652:	0007861b          	sext.w	a2,a5
    80001656:	85ba                	mv	a1,a4
    80001658:	00000097          	auipc	ra,0x0
    8000165c:	e4e080e7          	jalr	-434(ra) # 800014a6 <uvmunmap>
    80001660:	b7c5                	j	80001640 <uvmdealloc+0x26>

0000000080001662 <uvmalloc>:
  if(newsz < oldsz)
    80001662:	0ab66b63          	bltu	a2,a1,80001718 <uvmalloc+0xb6>
{
    80001666:	7139                	addi	sp,sp,-64
    80001668:	fc06                	sd	ra,56(sp)
    8000166a:	f822                	sd	s0,48(sp)
    8000166c:	ec4e                	sd	s3,24(sp)
    8000166e:	e852                	sd	s4,16(sp)
    80001670:	e456                	sd	s5,8(sp)
    80001672:	0080                	addi	s0,sp,64
    80001674:	8aaa                	mv	s5,a0
    80001676:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001678:	6785                	lui	a5,0x1
    8000167a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000167c:	95be                	add	a1,a1,a5
    8000167e:	77fd                	lui	a5,0xfffff
    80001680:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001684:	08c9fc63          	bgeu	s3,a2,8000171c <uvmalloc+0xba>
    80001688:	f426                	sd	s1,40(sp)
    8000168a:	f04a                	sd	s2,32(sp)
    8000168c:	e05a                	sd	s6,0(sp)
    8000168e:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001690:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001694:	fffff097          	auipc	ra,0xfffff
    80001698:	60e080e7          	jalr	1550(ra) # 80000ca2 <kalloc>
    8000169c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000169e:	c915                	beqz	a0,800016d2 <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800016a0:	6605                	lui	a2,0x1
    800016a2:	4581                	li	a1,0
    800016a4:	00000097          	auipc	ra,0x0
    800016a8:	878080e7          	jalr	-1928(ra) # 80000f1c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800016ac:	875a                	mv	a4,s6
    800016ae:	86a6                	mv	a3,s1
    800016b0:	6605                	lui	a2,0x1
    800016b2:	85ca                	mv	a1,s2
    800016b4:	8556                	mv	a0,s5
    800016b6:	00000097          	auipc	ra,0x0
    800016ba:	c2a080e7          	jalr	-982(ra) # 800012e0 <mappages>
    800016be:	ed05                	bnez	a0,800016f6 <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800016c0:	6785                	lui	a5,0x1
    800016c2:	993e                	add	s2,s2,a5
    800016c4:	fd4968e3          	bltu	s2,s4,80001694 <uvmalloc+0x32>
  return newsz;
    800016c8:	8552                	mv	a0,s4
    800016ca:	74a2                	ld	s1,40(sp)
    800016cc:	7902                	ld	s2,32(sp)
    800016ce:	6b02                	ld	s6,0(sp)
    800016d0:	a821                	j	800016e8 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800016d2:	864e                	mv	a2,s3
    800016d4:	85ca                	mv	a1,s2
    800016d6:	8556                	mv	a0,s5
    800016d8:	00000097          	auipc	ra,0x0
    800016dc:	f42080e7          	jalr	-190(ra) # 8000161a <uvmdealloc>
      return 0;
    800016e0:	4501                	li	a0,0
    800016e2:	74a2                	ld	s1,40(sp)
    800016e4:	7902                	ld	s2,32(sp)
    800016e6:	6b02                	ld	s6,0(sp)
}
    800016e8:	70e2                	ld	ra,56(sp)
    800016ea:	7442                	ld	s0,48(sp)
    800016ec:	69e2                	ld	s3,24(sp)
    800016ee:	6a42                	ld	s4,16(sp)
    800016f0:	6aa2                	ld	s5,8(sp)
    800016f2:	6121                	addi	sp,sp,64
    800016f4:	8082                	ret
      kfree(mem);
    800016f6:	8526                	mv	a0,s1
    800016f8:	fffff097          	auipc	ra,0xfffff
    800016fc:	3b6080e7          	jalr	950(ra) # 80000aae <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001700:	864e                	mv	a2,s3
    80001702:	85ca                	mv	a1,s2
    80001704:	8556                	mv	a0,s5
    80001706:	00000097          	auipc	ra,0x0
    8000170a:	f14080e7          	jalr	-236(ra) # 8000161a <uvmdealloc>
      return 0;
    8000170e:	4501                	li	a0,0
    80001710:	74a2                	ld	s1,40(sp)
    80001712:	7902                	ld	s2,32(sp)
    80001714:	6b02                	ld	s6,0(sp)
    80001716:	bfc9                	j	800016e8 <uvmalloc+0x86>
    return oldsz;
    80001718:	852e                	mv	a0,a1
}
    8000171a:	8082                	ret
  return newsz;
    8000171c:	8532                	mv	a0,a2
    8000171e:	b7e9                	j	800016e8 <uvmalloc+0x86>

0000000080001720 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001720:	7179                	addi	sp,sp,-48
    80001722:	f406                	sd	ra,40(sp)
    80001724:	f022                	sd	s0,32(sp)
    80001726:	ec26                	sd	s1,24(sp)
    80001728:	e84a                	sd	s2,16(sp)
    8000172a:	e44e                	sd	s3,8(sp)
    8000172c:	e052                	sd	s4,0(sp)
    8000172e:	1800                	addi	s0,sp,48
    80001730:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001732:	84aa                	mv	s1,a0
    80001734:	6905                	lui	s2,0x1
    80001736:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001738:	4985                	li	s3,1
    8000173a:	a829                	j	80001754 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000173c:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000173e:	00c79513          	slli	a0,a5,0xc
    80001742:	00000097          	auipc	ra,0x0
    80001746:	fde080e7          	jalr	-34(ra) # 80001720 <freewalk>
      pagetable[i] = 0;
    8000174a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000174e:	04a1                	addi	s1,s1,8
    80001750:	03248163          	beq	s1,s2,80001772 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001754:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001756:	00f7f713          	andi	a4,a5,15
    8000175a:	ff3701e3          	beq	a4,s3,8000173c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000175e:	8b85                	andi	a5,a5,1
    80001760:	d7fd                	beqz	a5,8000174e <freewalk+0x2e>
      panic("freewalk: leaf");
    80001762:	00007517          	auipc	a0,0x7
    80001766:	a4650513          	addi	a0,a0,-1466 # 800081a8 <__func__.1+0x1a0>
    8000176a:	fffff097          	auipc	ra,0xfffff
    8000176e:	df6080e7          	jalr	-522(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    80001772:	8552                	mv	a0,s4
    80001774:	fffff097          	auipc	ra,0xfffff
    80001778:	33a080e7          	jalr	826(ra) # 80000aae <kfree>
}
    8000177c:	70a2                	ld	ra,40(sp)
    8000177e:	7402                	ld	s0,32(sp)
    80001780:	64e2                	ld	s1,24(sp)
    80001782:	6942                	ld	s2,16(sp)
    80001784:	69a2                	ld	s3,8(sp)
    80001786:	6a02                	ld	s4,0(sp)
    80001788:	6145                	addi	sp,sp,48
    8000178a:	8082                	ret

000000008000178c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000178c:	1101                	addi	sp,sp,-32
    8000178e:	ec06                	sd	ra,24(sp)
    80001790:	e822                	sd	s0,16(sp)
    80001792:	e426                	sd	s1,8(sp)
    80001794:	1000                	addi	s0,sp,32
    80001796:	84aa                	mv	s1,a0
  if(sz > 0)
    80001798:	e999                	bnez	a1,800017ae <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000179a:	8526                	mv	a0,s1
    8000179c:	00000097          	auipc	ra,0x0
    800017a0:	f84080e7          	jalr	-124(ra) # 80001720 <freewalk>
}
    800017a4:	60e2                	ld	ra,24(sp)
    800017a6:	6442                	ld	s0,16(sp)
    800017a8:	64a2                	ld	s1,8(sp)
    800017aa:	6105                	addi	sp,sp,32
    800017ac:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800017ae:	6785                	lui	a5,0x1
    800017b0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800017b2:	95be                	add	a1,a1,a5
    800017b4:	4685                	li	a3,1
    800017b6:	00c5d613          	srli	a2,a1,0xc
    800017ba:	4581                	li	a1,0
    800017bc:	00000097          	auipc	ra,0x0
    800017c0:	cea080e7          	jalr	-790(ra) # 800014a6 <uvmunmap>
    800017c4:	bfd9                	j	8000179a <uvmfree+0xe>

00000000800017c6 <uvmcopy>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    800017c6:	c661                	beqz	a2,8000188e <uvmcopy+0xc8>
{
    800017c8:	7139                	addi	sp,sp,-64
    800017ca:	fc06                	sd	ra,56(sp)
    800017cc:	f822                	sd	s0,48(sp)
    800017ce:	f426                	sd	s1,40(sp)
    800017d0:	f04a                	sd	s2,32(sp)
    800017d2:	ec4e                	sd	s3,24(sp)
    800017d4:	e852                	sd	s4,16(sp)
    800017d6:	e456                	sd	s5,8(sp)
    800017d8:	e05a                	sd	s6,0(sp)
    800017da:	0080                	addi	s0,sp,64
    800017dc:	8aaa                	mv	s5,a0
    800017de:	8a2e                	mv	s4,a1
    800017e0:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    800017e2:	4481                	li	s1,0
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    flags = (PTE_FLAGS(*pte) & ~PTE_W) | PTE_COW;
    *pte = PA2PTE(pa) | flags;
    800017e4:	7b7d                	lui	s6,0xfffff
    800017e6:	002b5b13          	srli	s6,s6,0x2
    if((pte = walk(old, i, 0)) == 0)
    800017ea:	4601                	li	a2,0
    800017ec:	85a6                	mv	a1,s1
    800017ee:	8556                	mv	a0,s5
    800017f0:	00000097          	auipc	ra,0x0
    800017f4:	a08080e7          	jalr	-1528(ra) # 800011f8 <walk>
    800017f8:	c125                	beqz	a0,80001858 <uvmcopy+0x92>
    if((*pte & PTE_V) == 0)
    800017fa:	611c                	ld	a5,0(a0)
    800017fc:	0017f713          	andi	a4,a5,1
    80001800:	c725                	beqz	a4,80001868 <uvmcopy+0xa2>
    pa = PTE2PA(*pte);
    80001802:	00a7d913          	srli	s2,a5,0xa
    80001806:	0932                	slli	s2,s2,0xc
    flags = (PTE_FLAGS(*pte) & ~PTE_W) | PTE_COW;
    80001808:	2fb7f713          	andi	a4,a5,763
    *pte = PA2PTE(pa) | flags;
    8000180c:	0167f7b3          	and	a5,a5,s6
    80001810:	10076693          	ori	a3,a4,256
    80001814:	8fd5                	or	a5,a5,a3
    80001816:	e11c                	sd	a5,0(a0)
    if(mappages(new, i, PGSIZE, pa, flags) != 0)
    80001818:	8736                	mv	a4,a3
    8000181a:	86ca                	mv	a3,s2
    8000181c:	6605                	lui	a2,0x1
    8000181e:	85a6                	mv	a1,s1
    80001820:	8552                	mv	a0,s4
    80001822:	00000097          	auipc	ra,0x0
    80001826:	abe080e7          	jalr	-1346(ra) # 800012e0 <mappages>
    8000182a:	e539                	bnez	a0,80001878 <uvmcopy+0xb2>
      goto err;
    kref_inc((void*)pa);
    8000182c:	854a                	mv	a0,s2
    8000182e:	fffff097          	auipc	ra,0xfffff
    80001832:	22e080e7          	jalr	558(ra) # 80000a5c <kref_inc>
  for(i = 0; i < sz; i += PGSIZE){
    80001836:	6785                	lui	a5,0x1
    80001838:	94be                	add	s1,s1,a5
    8000183a:	fb34e8e3          	bltu	s1,s3,800017ea <uvmcopy+0x24>
    8000183e:	12000073          	sfence.vma
  }
  sfence_vma();
  return 0;
    80001842:	4501                	li	a0,0

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
  return -1;
}
    80001844:	70e2                	ld	ra,56(sp)
    80001846:	7442                	ld	s0,48(sp)
    80001848:	74a2                	ld	s1,40(sp)
    8000184a:	7902                	ld	s2,32(sp)
    8000184c:	69e2                	ld	s3,24(sp)
    8000184e:	6a42                	ld	s4,16(sp)
    80001850:	6aa2                	ld	s5,8(sp)
    80001852:	6b02                	ld	s6,0(sp)
    80001854:	6121                	addi	sp,sp,64
    80001856:	8082                	ret
      panic("uvmcopy: pte should exist");
    80001858:	00007517          	auipc	a0,0x7
    8000185c:	96050513          	addi	a0,a0,-1696 # 800081b8 <__func__.1+0x1b0>
    80001860:	fffff097          	auipc	ra,0xfffff
    80001864:	d00080e7          	jalr	-768(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001868:	00007517          	auipc	a0,0x7
    8000186c:	97050513          	addi	a0,a0,-1680 # 800081d8 <__func__.1+0x1d0>
    80001870:	fffff097          	auipc	ra,0xfffff
    80001874:	cf0080e7          	jalr	-784(ra) # 80000560 <panic>
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001878:	4685                	li	a3,1
    8000187a:	00c4d613          	srli	a2,s1,0xc
    8000187e:	4581                	li	a1,0
    80001880:	8552                	mv	a0,s4
    80001882:	00000097          	auipc	ra,0x0
    80001886:	c24080e7          	jalr	-988(ra) # 800014a6 <uvmunmap>
  return -1;
    8000188a:	557d                	li	a0,-1
    8000188c:	bf65                	j	80001844 <uvmcopy+0x7e>
    8000188e:	12000073          	sfence.vma
  return 0;
    80001892:	4501                	li	a0,0
}
    80001894:	8082                	ret

0000000080001896 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001896:	1141                	addi	sp,sp,-16
    80001898:	e406                	sd	ra,8(sp)
    8000189a:	e022                	sd	s0,0(sp)
    8000189c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000189e:	4601                	li	a2,0
    800018a0:	00000097          	auipc	ra,0x0
    800018a4:	958080e7          	jalr	-1704(ra) # 800011f8 <walk>
  if(pte == 0)
    800018a8:	c901                	beqz	a0,800018b8 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800018aa:	611c                	ld	a5,0(a0)
    800018ac:	9bbd                	andi	a5,a5,-17
    800018ae:	e11c                	sd	a5,0(a0)
}
    800018b0:	60a2                	ld	ra,8(sp)
    800018b2:	6402                	ld	s0,0(sp)
    800018b4:	0141                	addi	sp,sp,16
    800018b6:	8082                	ret
    panic("uvmclear");
    800018b8:	00007517          	auipc	a0,0x7
    800018bc:	94050513          	addi	a0,a0,-1728 # 800081f8 <__func__.1+0x1f0>
    800018c0:	fffff097          	auipc	ra,0xfffff
    800018c4:	ca0080e7          	jalr	-864(ra) # 80000560 <panic>

00000000800018c8 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800018c8:	c6bd                	beqz	a3,80001936 <copyout+0x6e>
{
    800018ca:	715d                	addi	sp,sp,-80
    800018cc:	e486                	sd	ra,72(sp)
    800018ce:	e0a2                	sd	s0,64(sp)
    800018d0:	fc26                	sd	s1,56(sp)
    800018d2:	f84a                	sd	s2,48(sp)
    800018d4:	f44e                	sd	s3,40(sp)
    800018d6:	f052                	sd	s4,32(sp)
    800018d8:	ec56                	sd	s5,24(sp)
    800018da:	e85a                	sd	s6,16(sp)
    800018dc:	e45e                	sd	s7,8(sp)
    800018de:	e062                	sd	s8,0(sp)
    800018e0:	0880                	addi	s0,sp,80
    800018e2:	8b2a                	mv	s6,a0
    800018e4:	8c2e                	mv	s8,a1
    800018e6:	8a32                	mv	s4,a2
    800018e8:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800018ea:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800018ec:	6a85                	lui	s5,0x1
    800018ee:	a015                	j	80001912 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800018f0:	9562                	add	a0,a0,s8
    800018f2:	0004861b          	sext.w	a2,s1
    800018f6:	85d2                	mv	a1,s4
    800018f8:	41250533          	sub	a0,a0,s2
    800018fc:	fffff097          	auipc	ra,0xfffff
    80001900:	67c080e7          	jalr	1660(ra) # 80000f78 <memmove>

    len -= n;
    80001904:	409989b3          	sub	s3,s3,s1
    src += n;
    80001908:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000190a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000190e:	02098263          	beqz	s3,80001932 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001912:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001916:	85ca                	mv	a1,s2
    80001918:	855a                	mv	a0,s6
    8000191a:	00000097          	auipc	ra,0x0
    8000191e:	984080e7          	jalr	-1660(ra) # 8000129e <walkaddr>
    if(pa0 == 0)
    80001922:	cd01                	beqz	a0,8000193a <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001924:	418904b3          	sub	s1,s2,s8
    80001928:	94d6                	add	s1,s1,s5
    if(n > len)
    8000192a:	fc99f3e3          	bgeu	s3,s1,800018f0 <copyout+0x28>
    8000192e:	84ce                	mv	s1,s3
    80001930:	b7c1                	j	800018f0 <copyout+0x28>
  }
  return 0;
    80001932:	4501                	li	a0,0
    80001934:	a021                	j	8000193c <copyout+0x74>
    80001936:	4501                	li	a0,0
}
    80001938:	8082                	ret
      return -1;
    8000193a:	557d                	li	a0,-1
}
    8000193c:	60a6                	ld	ra,72(sp)
    8000193e:	6406                	ld	s0,64(sp)
    80001940:	74e2                	ld	s1,56(sp)
    80001942:	7942                	ld	s2,48(sp)
    80001944:	79a2                	ld	s3,40(sp)
    80001946:	7a02                	ld	s4,32(sp)
    80001948:	6ae2                	ld	s5,24(sp)
    8000194a:	6b42                	ld	s6,16(sp)
    8000194c:	6ba2                	ld	s7,8(sp)
    8000194e:	6c02                	ld	s8,0(sp)
    80001950:	6161                	addi	sp,sp,80
    80001952:	8082                	ret

0000000080001954 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001954:	caa5                	beqz	a3,800019c4 <copyin+0x70>
{
    80001956:	715d                	addi	sp,sp,-80
    80001958:	e486                	sd	ra,72(sp)
    8000195a:	e0a2                	sd	s0,64(sp)
    8000195c:	fc26                	sd	s1,56(sp)
    8000195e:	f84a                	sd	s2,48(sp)
    80001960:	f44e                	sd	s3,40(sp)
    80001962:	f052                	sd	s4,32(sp)
    80001964:	ec56                	sd	s5,24(sp)
    80001966:	e85a                	sd	s6,16(sp)
    80001968:	e45e                	sd	s7,8(sp)
    8000196a:	e062                	sd	s8,0(sp)
    8000196c:	0880                	addi	s0,sp,80
    8000196e:	8b2a                	mv	s6,a0
    80001970:	8a2e                	mv	s4,a1
    80001972:	8c32                	mv	s8,a2
    80001974:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001976:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001978:	6a85                	lui	s5,0x1
    8000197a:	a01d                	j	800019a0 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000197c:	018505b3          	add	a1,a0,s8
    80001980:	0004861b          	sext.w	a2,s1
    80001984:	412585b3          	sub	a1,a1,s2
    80001988:	8552                	mv	a0,s4
    8000198a:	fffff097          	auipc	ra,0xfffff
    8000198e:	5ee080e7          	jalr	1518(ra) # 80000f78 <memmove>

    len -= n;
    80001992:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001996:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001998:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000199c:	02098263          	beqz	s3,800019c0 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800019a0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800019a4:	85ca                	mv	a1,s2
    800019a6:	855a                	mv	a0,s6
    800019a8:	00000097          	auipc	ra,0x0
    800019ac:	8f6080e7          	jalr	-1802(ra) # 8000129e <walkaddr>
    if(pa0 == 0)
    800019b0:	cd01                	beqz	a0,800019c8 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800019b2:	418904b3          	sub	s1,s2,s8
    800019b6:	94d6                	add	s1,s1,s5
    if(n > len)
    800019b8:	fc99f2e3          	bgeu	s3,s1,8000197c <copyin+0x28>
    800019bc:	84ce                	mv	s1,s3
    800019be:	bf7d                	j	8000197c <copyin+0x28>
  }
  return 0;
    800019c0:	4501                	li	a0,0
    800019c2:	a021                	j	800019ca <copyin+0x76>
    800019c4:	4501                	li	a0,0
}
    800019c6:	8082                	ret
      return -1;
    800019c8:	557d                	li	a0,-1
}
    800019ca:	60a6                	ld	ra,72(sp)
    800019cc:	6406                	ld	s0,64(sp)
    800019ce:	74e2                	ld	s1,56(sp)
    800019d0:	7942                	ld	s2,48(sp)
    800019d2:	79a2                	ld	s3,40(sp)
    800019d4:	7a02                	ld	s4,32(sp)
    800019d6:	6ae2                	ld	s5,24(sp)
    800019d8:	6b42                	ld	s6,16(sp)
    800019da:	6ba2                	ld	s7,8(sp)
    800019dc:	6c02                	ld	s8,0(sp)
    800019de:	6161                	addi	sp,sp,80
    800019e0:	8082                	ret

00000000800019e2 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800019e2:	cacd                	beqz	a3,80001a94 <copyinstr+0xb2>
{
    800019e4:	715d                	addi	sp,sp,-80
    800019e6:	e486                	sd	ra,72(sp)
    800019e8:	e0a2                	sd	s0,64(sp)
    800019ea:	fc26                	sd	s1,56(sp)
    800019ec:	f84a                	sd	s2,48(sp)
    800019ee:	f44e                	sd	s3,40(sp)
    800019f0:	f052                	sd	s4,32(sp)
    800019f2:	ec56                	sd	s5,24(sp)
    800019f4:	e85a                	sd	s6,16(sp)
    800019f6:	e45e                	sd	s7,8(sp)
    800019f8:	0880                	addi	s0,sp,80
    800019fa:	8a2a                	mv	s4,a0
    800019fc:	8b2e                	mv	s6,a1
    800019fe:	8bb2                	mv	s7,a2
    80001a00:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80001a02:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001a04:	6985                	lui	s3,0x1
    80001a06:	a825                	j	80001a3e <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001a08:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001a0c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001a0e:	37fd                	addiw	a5,a5,-1
    80001a10:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001a14:	60a6                	ld	ra,72(sp)
    80001a16:	6406                	ld	s0,64(sp)
    80001a18:	74e2                	ld	s1,56(sp)
    80001a1a:	7942                	ld	s2,48(sp)
    80001a1c:	79a2                	ld	s3,40(sp)
    80001a1e:	7a02                	ld	s4,32(sp)
    80001a20:	6ae2                	ld	s5,24(sp)
    80001a22:	6b42                	ld	s6,16(sp)
    80001a24:	6ba2                	ld	s7,8(sp)
    80001a26:	6161                	addi	sp,sp,80
    80001a28:	8082                	ret
    80001a2a:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001a2e:	9742                	add	a4,a4,a6
      --max;
    80001a30:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001a34:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001a38:	04e58663          	beq	a1,a4,80001a84 <copyinstr+0xa2>
{
    80001a3c:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001a3e:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001a42:	85a6                	mv	a1,s1
    80001a44:	8552                	mv	a0,s4
    80001a46:	00000097          	auipc	ra,0x0
    80001a4a:	858080e7          	jalr	-1960(ra) # 8000129e <walkaddr>
    if(pa0 == 0)
    80001a4e:	cd0d                	beqz	a0,80001a88 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    80001a50:	417486b3          	sub	a3,s1,s7
    80001a54:	96ce                	add	a3,a3,s3
    if(n > max)
    80001a56:	00d97363          	bgeu	s2,a3,80001a5c <copyinstr+0x7a>
    80001a5a:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001a5c:	955e                	add	a0,a0,s7
    80001a5e:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001a60:	c695                	beqz	a3,80001a8c <copyinstr+0xaa>
    80001a62:	87da                	mv	a5,s6
    80001a64:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001a66:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001a6a:	96da                	add	a3,a3,s6
    80001a6c:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001a6e:	00f60733          	add	a4,a2,a5
    80001a72:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd25b8>
    80001a76:	db49                	beqz	a4,80001a08 <copyinstr+0x26>
        *dst = *p;
    80001a78:	00e78023          	sb	a4,0(a5)
      dst++;
    80001a7c:	0785                	addi	a5,a5,1
    while(n > 0){
    80001a7e:	fed797e3          	bne	a5,a3,80001a6c <copyinstr+0x8a>
    80001a82:	b765                	j	80001a2a <copyinstr+0x48>
    80001a84:	4781                	li	a5,0
    80001a86:	b761                	j	80001a0e <copyinstr+0x2c>
      return -1;
    80001a88:	557d                	li	a0,-1
    80001a8a:	b769                	j	80001a14 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001a8c:	6b85                	lui	s7,0x1
    80001a8e:	9ba6                	add	s7,s7,s1
    80001a90:	87da                	mv	a5,s6
    80001a92:	b76d                	j	80001a3c <copyinstr+0x5a>
  int got_null = 0;
    80001a94:	4781                	li	a5,0
  if(got_null){
    80001a96:	37fd                	addiw	a5,a5,-1
    80001a98:	0007851b          	sext.w	a0,a5
}
    80001a9c:	8082                	ret

0000000080001a9e <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001a9e:	715d                	addi	sp,sp,-80
    80001aa0:	e486                	sd	ra,72(sp)
    80001aa2:	e0a2                	sd	s0,64(sp)
    80001aa4:	fc26                	sd	s1,56(sp)
    80001aa6:	f84a                	sd	s2,48(sp)
    80001aa8:	f44e                	sd	s3,40(sp)
    80001aaa:	f052                	sd	s4,32(sp)
    80001aac:	ec56                	sd	s5,24(sp)
    80001aae:	e85a                	sd	s6,16(sp)
    80001ab0:	e45e                	sd	s7,8(sp)
    80001ab2:	e062                	sd	s8,0(sp)
    80001ab4:	0880                	addi	s0,sp,80
    asm volatile("mv %0, tp" : "=r"(x));
    80001ab6:	8792                	mv	a5,tp
    int id = r_tp();
    80001ab8:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001aba:	0001aa97          	auipc	s5,0x1a
    80001abe:	d7ea8a93          	addi	s5,s5,-642 # 8001b838 <cpus>
    80001ac2:	00779713          	slli	a4,a5,0x7
    80001ac6:	00ea86b3          	add	a3,s5,a4
    80001aca:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffd25b8>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001ace:	0721                	addi	a4,a4,8
    80001ad0:	9aba                	add	s5,s5,a4
                c->proc = p;
    80001ad2:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001ad4:	0000ac17          	auipc	s8,0xa
    80001ad8:	a04c0c13          	addi	s8,s8,-1532 # 8000b4d8 <sched_pointer>
    80001adc:	00000b97          	auipc	s7,0x0
    80001ae0:	fc2b8b93          	addi	s7,s7,-62 # 80001a9e <rr_scheduler>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80001ae4:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ae8:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80001aec:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    80001af0:	0001a497          	auipc	s1,0x1a
    80001af4:	17848493          	addi	s1,s1,376 # 8001bc68 <proc>
            if (p->state == RUNNABLE)
    80001af8:	498d                	li	s3,3
                p->state = RUNNING;
    80001afa:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    80001afc:	00020a17          	auipc	s4,0x20
    80001b00:	b6ca0a13          	addi	s4,s4,-1172 # 80021668 <tickslock>
    80001b04:	a81d                	j	80001b3a <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001b06:	8526                	mv	a0,s1
    80001b08:	fffff097          	auipc	ra,0xfffff
    80001b0c:	3cc080e7          	jalr	972(ra) # 80000ed4 <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    80001b10:	60a6                	ld	ra,72(sp)
    80001b12:	6406                	ld	s0,64(sp)
    80001b14:	74e2                	ld	s1,56(sp)
    80001b16:	7942                	ld	s2,48(sp)
    80001b18:	79a2                	ld	s3,40(sp)
    80001b1a:	7a02                	ld	s4,32(sp)
    80001b1c:	6ae2                	ld	s5,24(sp)
    80001b1e:	6b42                	ld	s6,16(sp)
    80001b20:	6ba2                	ld	s7,8(sp)
    80001b22:	6c02                	ld	s8,0(sp)
    80001b24:	6161                	addi	sp,sp,80
    80001b26:	8082                	ret
            release(&p->lock);
    80001b28:	8526                	mv	a0,s1
    80001b2a:	fffff097          	auipc	ra,0xfffff
    80001b2e:	3aa080e7          	jalr	938(ra) # 80000ed4 <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001b32:	16848493          	addi	s1,s1,360
    80001b36:	fb4487e3          	beq	s1,s4,80001ae4 <rr_scheduler+0x46>
            acquire(&p->lock);
    80001b3a:	8526                	mv	a0,s1
    80001b3c:	fffff097          	auipc	ra,0xfffff
    80001b40:	2e4080e7          	jalr	740(ra) # 80000e20 <acquire>
            if (p->state == RUNNABLE)
    80001b44:	4c9c                	lw	a5,24(s1)
    80001b46:	ff3791e3          	bne	a5,s3,80001b28 <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001b4a:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001b4e:	00993023          	sd	s1,0(s2)
                swtch(&c->context, &p->context);
    80001b52:	06048593          	addi	a1,s1,96
    80001b56:	8556                	mv	a0,s5
    80001b58:	00001097          	auipc	ra,0x1
    80001b5c:	fc4080e7          	jalr	-60(ra) # 80002b1c <swtch>
                if (sched_pointer != &rr_scheduler)
    80001b60:	000c3783          	ld	a5,0(s8)
    80001b64:	fb7791e3          	bne	a5,s7,80001b06 <rr_scheduler+0x68>
                c->proc = 0;
    80001b68:	00093023          	sd	zero,0(s2)
    80001b6c:	bf75                	j	80001b28 <rr_scheduler+0x8a>

0000000080001b6e <proc_mapstacks>:
{
    80001b6e:	7139                	addi	sp,sp,-64
    80001b70:	fc06                	sd	ra,56(sp)
    80001b72:	f822                	sd	s0,48(sp)
    80001b74:	f426                	sd	s1,40(sp)
    80001b76:	f04a                	sd	s2,32(sp)
    80001b78:	ec4e                	sd	s3,24(sp)
    80001b7a:	e852                	sd	s4,16(sp)
    80001b7c:	e456                	sd	s5,8(sp)
    80001b7e:	e05a                	sd	s6,0(sp)
    80001b80:	0080                	addi	s0,sp,64
    80001b82:	8a2a                	mv	s4,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001b84:	0001a497          	auipc	s1,0x1a
    80001b88:	0e448493          	addi	s1,s1,228 # 8001bc68 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001b8c:	8b26                	mv	s6,s1
    80001b8e:	04fa5937          	lui	s2,0x4fa5
    80001b92:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001b96:	0932                	slli	s2,s2,0xc
    80001b98:	fa590913          	addi	s2,s2,-91
    80001b9c:	0932                	slli	s2,s2,0xc
    80001b9e:	fa590913          	addi	s2,s2,-91
    80001ba2:	0932                	slli	s2,s2,0xc
    80001ba4:	fa590913          	addi	s2,s2,-91
    80001ba8:	040009b7          	lui	s3,0x4000
    80001bac:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001bae:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001bb0:	00020a97          	auipc	s5,0x20
    80001bb4:	ab8a8a93          	addi	s5,s5,-1352 # 80021668 <tickslock>
        char *pa = kalloc();
    80001bb8:	fffff097          	auipc	ra,0xfffff
    80001bbc:	0ea080e7          	jalr	234(ra) # 80000ca2 <kalloc>
    80001bc0:	862a                	mv	a2,a0
        if (pa == 0)
    80001bc2:	c121                	beqz	a0,80001c02 <proc_mapstacks+0x94>
        uint64 va = KSTACK((int)(p - proc));
    80001bc4:	416485b3          	sub	a1,s1,s6
    80001bc8:	858d                	srai	a1,a1,0x3
    80001bca:	032585b3          	mul	a1,a1,s2
    80001bce:	2585                	addiw	a1,a1,1
    80001bd0:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001bd4:	4719                	li	a4,6
    80001bd6:	6685                	lui	a3,0x1
    80001bd8:	40b985b3          	sub	a1,s3,a1
    80001bdc:	8552                	mv	a0,s4
    80001bde:	fffff097          	auipc	ra,0xfffff
    80001be2:	7a2080e7          	jalr	1954(ra) # 80001380 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001be6:	16848493          	addi	s1,s1,360
    80001bea:	fd5497e3          	bne	s1,s5,80001bb8 <proc_mapstacks+0x4a>
}
    80001bee:	70e2                	ld	ra,56(sp)
    80001bf0:	7442                	ld	s0,48(sp)
    80001bf2:	74a2                	ld	s1,40(sp)
    80001bf4:	7902                	ld	s2,32(sp)
    80001bf6:	69e2                	ld	s3,24(sp)
    80001bf8:	6a42                	ld	s4,16(sp)
    80001bfa:	6aa2                	ld	s5,8(sp)
    80001bfc:	6b02                	ld	s6,0(sp)
    80001bfe:	6121                	addi	sp,sp,64
    80001c00:	8082                	ret
            panic("kalloc");
    80001c02:	00006517          	auipc	a0,0x6
    80001c06:	60650513          	addi	a0,a0,1542 # 80008208 <__func__.1+0x200>
    80001c0a:	fffff097          	auipc	ra,0xfffff
    80001c0e:	956080e7          	jalr	-1706(ra) # 80000560 <panic>

0000000080001c12 <procinit>:
{
    80001c12:	7139                	addi	sp,sp,-64
    80001c14:	fc06                	sd	ra,56(sp)
    80001c16:	f822                	sd	s0,48(sp)
    80001c18:	f426                	sd	s1,40(sp)
    80001c1a:	f04a                	sd	s2,32(sp)
    80001c1c:	ec4e                	sd	s3,24(sp)
    80001c1e:	e852                	sd	s4,16(sp)
    80001c20:	e456                	sd	s5,8(sp)
    80001c22:	e05a                	sd	s6,0(sp)
    80001c24:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001c26:	00006597          	auipc	a1,0x6
    80001c2a:	5ea58593          	addi	a1,a1,1514 # 80008210 <__func__.1+0x208>
    80001c2e:	0001a517          	auipc	a0,0x1a
    80001c32:	00a50513          	addi	a0,a0,10 # 8001bc38 <pid_lock>
    80001c36:	fffff097          	auipc	ra,0xfffff
    80001c3a:	15a080e7          	jalr	346(ra) # 80000d90 <initlock>
    initlock(&wait_lock, "wait_lock");
    80001c3e:	00006597          	auipc	a1,0x6
    80001c42:	5da58593          	addi	a1,a1,1498 # 80008218 <__func__.1+0x210>
    80001c46:	0001a517          	auipc	a0,0x1a
    80001c4a:	00a50513          	addi	a0,a0,10 # 8001bc50 <wait_lock>
    80001c4e:	fffff097          	auipc	ra,0xfffff
    80001c52:	142080e7          	jalr	322(ra) # 80000d90 <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001c56:	0001a497          	auipc	s1,0x1a
    80001c5a:	01248493          	addi	s1,s1,18 # 8001bc68 <proc>
        initlock(&p->lock, "proc");
    80001c5e:	00006b17          	auipc	s6,0x6
    80001c62:	5cab0b13          	addi	s6,s6,1482 # 80008228 <__func__.1+0x220>
        p->kstack = KSTACK((int)(p - proc));
    80001c66:	8aa6                	mv	s5,s1
    80001c68:	04fa5937          	lui	s2,0x4fa5
    80001c6c:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001c70:	0932                	slli	s2,s2,0xc
    80001c72:	fa590913          	addi	s2,s2,-91
    80001c76:	0932                	slli	s2,s2,0xc
    80001c78:	fa590913          	addi	s2,s2,-91
    80001c7c:	0932                	slli	s2,s2,0xc
    80001c7e:	fa590913          	addi	s2,s2,-91
    80001c82:	040009b7          	lui	s3,0x4000
    80001c86:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001c88:	09b2                	slli	s3,s3,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001c8a:	00020a17          	auipc	s4,0x20
    80001c8e:	9dea0a13          	addi	s4,s4,-1570 # 80021668 <tickslock>
        initlock(&p->lock, "proc");
    80001c92:	85da                	mv	a1,s6
    80001c94:	8526                	mv	a0,s1
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	0fa080e7          	jalr	250(ra) # 80000d90 <initlock>
        p->state = UNUSED;
    80001c9e:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001ca2:	415487b3          	sub	a5,s1,s5
    80001ca6:	878d                	srai	a5,a5,0x3
    80001ca8:	032787b3          	mul	a5,a5,s2
    80001cac:	2785                	addiw	a5,a5,1
    80001cae:	00d7979b          	slliw	a5,a5,0xd
    80001cb2:	40f987b3          	sub	a5,s3,a5
    80001cb6:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001cb8:	16848493          	addi	s1,s1,360
    80001cbc:	fd449be3          	bne	s1,s4,80001c92 <procinit+0x80>
}
    80001cc0:	70e2                	ld	ra,56(sp)
    80001cc2:	7442                	ld	s0,48(sp)
    80001cc4:	74a2                	ld	s1,40(sp)
    80001cc6:	7902                	ld	s2,32(sp)
    80001cc8:	69e2                	ld	s3,24(sp)
    80001cca:	6a42                	ld	s4,16(sp)
    80001ccc:	6aa2                	ld	s5,8(sp)
    80001cce:	6b02                	ld	s6,0(sp)
    80001cd0:	6121                	addi	sp,sp,64
    80001cd2:	8082                	ret

0000000080001cd4 <copy_array>:
{
    80001cd4:	1141                	addi	sp,sp,-16
    80001cd6:	e422                	sd	s0,8(sp)
    80001cd8:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001cda:	00c05c63          	blez	a2,80001cf2 <copy_array+0x1e>
    80001cde:	87aa                	mv	a5,a0
    80001ce0:	9532                	add	a0,a0,a2
        dst[i] = src[i];
    80001ce2:	0007c703          	lbu	a4,0(a5)
    80001ce6:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001cea:	0785                	addi	a5,a5,1
    80001cec:	0585                	addi	a1,a1,1
    80001cee:	fea79ae3          	bne	a5,a0,80001ce2 <copy_array+0xe>
}
    80001cf2:	6422                	ld	s0,8(sp)
    80001cf4:	0141                	addi	sp,sp,16
    80001cf6:	8082                	ret

0000000080001cf8 <cpuid>:
{
    80001cf8:	1141                	addi	sp,sp,-16
    80001cfa:	e422                	sd	s0,8(sp)
    80001cfc:	0800                	addi	s0,sp,16
    asm volatile("mv %0, tp" : "=r"(x));
    80001cfe:	8512                	mv	a0,tp
}
    80001d00:	2501                	sext.w	a0,a0
    80001d02:	6422                	ld	s0,8(sp)
    80001d04:	0141                	addi	sp,sp,16
    80001d06:	8082                	ret

0000000080001d08 <mycpu>:
{
    80001d08:	1141                	addi	sp,sp,-16
    80001d0a:	e422                	sd	s0,8(sp)
    80001d0c:	0800                	addi	s0,sp,16
    80001d0e:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001d10:	2781                	sext.w	a5,a5
    80001d12:	079e                	slli	a5,a5,0x7
}
    80001d14:	0001a517          	auipc	a0,0x1a
    80001d18:	b2450513          	addi	a0,a0,-1244 # 8001b838 <cpus>
    80001d1c:	953e                	add	a0,a0,a5
    80001d1e:	6422                	ld	s0,8(sp)
    80001d20:	0141                	addi	sp,sp,16
    80001d22:	8082                	ret

0000000080001d24 <myproc>:
{
    80001d24:	1101                	addi	sp,sp,-32
    80001d26:	ec06                	sd	ra,24(sp)
    80001d28:	e822                	sd	s0,16(sp)
    80001d2a:	e426                	sd	s1,8(sp)
    80001d2c:	1000                	addi	s0,sp,32
    push_off();
    80001d2e:	fffff097          	auipc	ra,0xfffff
    80001d32:	0a6080e7          	jalr	166(ra) # 80000dd4 <push_off>
    80001d36:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001d38:	2781                	sext.w	a5,a5
    80001d3a:	079e                	slli	a5,a5,0x7
    80001d3c:	0001a717          	auipc	a4,0x1a
    80001d40:	afc70713          	addi	a4,a4,-1284 # 8001b838 <cpus>
    80001d44:	97ba                	add	a5,a5,a4
    80001d46:	6384                	ld	s1,0(a5)
    pop_off();
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	12c080e7          	jalr	300(ra) # 80000e74 <pop_off>
}
    80001d50:	8526                	mv	a0,s1
    80001d52:	60e2                	ld	ra,24(sp)
    80001d54:	6442                	ld	s0,16(sp)
    80001d56:	64a2                	ld	s1,8(sp)
    80001d58:	6105                	addi	sp,sp,32
    80001d5a:	8082                	ret

0000000080001d5c <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001d5c:	1141                	addi	sp,sp,-16
    80001d5e:	e406                	sd	ra,8(sp)
    80001d60:	e022                	sd	s0,0(sp)
    80001d62:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001d64:	00000097          	auipc	ra,0x0
    80001d68:	fc0080e7          	jalr	-64(ra) # 80001d24 <myproc>
    80001d6c:	fffff097          	auipc	ra,0xfffff
    80001d70:	168080e7          	jalr	360(ra) # 80000ed4 <release>

    if (first)
    80001d74:	00009797          	auipc	a5,0x9
    80001d78:	75c7a783          	lw	a5,1884(a5) # 8000b4d0 <first.1>
    80001d7c:	eb89                	bnez	a5,80001d8e <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001d7e:	00001097          	auipc	ra,0x1
    80001d82:	e48080e7          	jalr	-440(ra) # 80002bc6 <usertrapret>
}
    80001d86:	60a2                	ld	ra,8(sp)
    80001d88:	6402                	ld	s0,0(sp)
    80001d8a:	0141                	addi	sp,sp,16
    80001d8c:	8082                	ret
        first = 0;
    80001d8e:	00009797          	auipc	a5,0x9
    80001d92:	7407a123          	sw	zero,1858(a5) # 8000b4d0 <first.1>
        fsinit(ROOTDEV);
    80001d96:	4505                	li	a0,1
    80001d98:	00002097          	auipc	ra,0x2
    80001d9c:	dda080e7          	jalr	-550(ra) # 80003b72 <fsinit>
    80001da0:	bff9                	j	80001d7e <forkret+0x22>

0000000080001da2 <allocpid>:
{
    80001da2:	1101                	addi	sp,sp,-32
    80001da4:	ec06                	sd	ra,24(sp)
    80001da6:	e822                	sd	s0,16(sp)
    80001da8:	e426                	sd	s1,8(sp)
    80001daa:	e04a                	sd	s2,0(sp)
    80001dac:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001dae:	0001a917          	auipc	s2,0x1a
    80001db2:	e8a90913          	addi	s2,s2,-374 # 8001bc38 <pid_lock>
    80001db6:	854a                	mv	a0,s2
    80001db8:	fffff097          	auipc	ra,0xfffff
    80001dbc:	068080e7          	jalr	104(ra) # 80000e20 <acquire>
    pid = nextpid;
    80001dc0:	00009797          	auipc	a5,0x9
    80001dc4:	72078793          	addi	a5,a5,1824 # 8000b4e0 <nextpid>
    80001dc8:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001dca:	0014871b          	addiw	a4,s1,1
    80001dce:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001dd0:	854a                	mv	a0,s2
    80001dd2:	fffff097          	auipc	ra,0xfffff
    80001dd6:	102080e7          	jalr	258(ra) # 80000ed4 <release>
}
    80001dda:	8526                	mv	a0,s1
    80001ddc:	60e2                	ld	ra,24(sp)
    80001dde:	6442                	ld	s0,16(sp)
    80001de0:	64a2                	ld	s1,8(sp)
    80001de2:	6902                	ld	s2,0(sp)
    80001de4:	6105                	addi	sp,sp,32
    80001de6:	8082                	ret

0000000080001de8 <proc_pagetable>:
{
    80001de8:	1101                	addi	sp,sp,-32
    80001dea:	ec06                	sd	ra,24(sp)
    80001dec:	e822                	sd	s0,16(sp)
    80001dee:	e426                	sd	s1,8(sp)
    80001df0:	e04a                	sd	s2,0(sp)
    80001df2:	1000                	addi	s0,sp,32
    80001df4:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001df6:	fffff097          	auipc	ra,0xfffff
    80001dfa:	784080e7          	jalr	1924(ra) # 8000157a <uvmcreate>
    80001dfe:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001e00:	c121                	beqz	a0,80001e40 <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e02:	4729                	li	a4,10
    80001e04:	00005697          	auipc	a3,0x5
    80001e08:	1fc68693          	addi	a3,a3,508 # 80007000 <_trampoline>
    80001e0c:	6605                	lui	a2,0x1
    80001e0e:	040005b7          	lui	a1,0x4000
    80001e12:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e14:	05b2                	slli	a1,a1,0xc
    80001e16:	fffff097          	auipc	ra,0xfffff
    80001e1a:	4ca080e7          	jalr	1226(ra) # 800012e0 <mappages>
    80001e1e:	02054863          	bltz	a0,80001e4e <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001e22:	4719                	li	a4,6
    80001e24:	05893683          	ld	a3,88(s2)
    80001e28:	6605                	lui	a2,0x1
    80001e2a:	020005b7          	lui	a1,0x2000
    80001e2e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e30:	05b6                	slli	a1,a1,0xd
    80001e32:	8526                	mv	a0,s1
    80001e34:	fffff097          	auipc	ra,0xfffff
    80001e38:	4ac080e7          	jalr	1196(ra) # 800012e0 <mappages>
    80001e3c:	02054163          	bltz	a0,80001e5e <proc_pagetable+0x76>
}
    80001e40:	8526                	mv	a0,s1
    80001e42:	60e2                	ld	ra,24(sp)
    80001e44:	6442                	ld	s0,16(sp)
    80001e46:	64a2                	ld	s1,8(sp)
    80001e48:	6902                	ld	s2,0(sp)
    80001e4a:	6105                	addi	sp,sp,32
    80001e4c:	8082                	ret
        uvmfree(pagetable, 0);
    80001e4e:	4581                	li	a1,0
    80001e50:	8526                	mv	a0,s1
    80001e52:	00000097          	auipc	ra,0x0
    80001e56:	93a080e7          	jalr	-1734(ra) # 8000178c <uvmfree>
        return 0;
    80001e5a:	4481                	li	s1,0
    80001e5c:	b7d5                	j	80001e40 <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e5e:	4681                	li	a3,0
    80001e60:	4605                	li	a2,1
    80001e62:	040005b7          	lui	a1,0x4000
    80001e66:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e68:	05b2                	slli	a1,a1,0xc
    80001e6a:	8526                	mv	a0,s1
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	63a080e7          	jalr	1594(ra) # 800014a6 <uvmunmap>
        uvmfree(pagetable, 0);
    80001e74:	4581                	li	a1,0
    80001e76:	8526                	mv	a0,s1
    80001e78:	00000097          	auipc	ra,0x0
    80001e7c:	914080e7          	jalr	-1772(ra) # 8000178c <uvmfree>
        return 0;
    80001e80:	4481                	li	s1,0
    80001e82:	bf7d                	j	80001e40 <proc_pagetable+0x58>

0000000080001e84 <proc_freepagetable>:
{
    80001e84:	1101                	addi	sp,sp,-32
    80001e86:	ec06                	sd	ra,24(sp)
    80001e88:	e822                	sd	s0,16(sp)
    80001e8a:	e426                	sd	s1,8(sp)
    80001e8c:	e04a                	sd	s2,0(sp)
    80001e8e:	1000                	addi	s0,sp,32
    80001e90:	84aa                	mv	s1,a0
    80001e92:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e94:	4681                	li	a3,0
    80001e96:	4605                	li	a2,1
    80001e98:	040005b7          	lui	a1,0x4000
    80001e9c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e9e:	05b2                	slli	a1,a1,0xc
    80001ea0:	fffff097          	auipc	ra,0xfffff
    80001ea4:	606080e7          	jalr	1542(ra) # 800014a6 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ea8:	4681                	li	a3,0
    80001eaa:	4605                	li	a2,1
    80001eac:	020005b7          	lui	a1,0x2000
    80001eb0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001eb2:	05b6                	slli	a1,a1,0xd
    80001eb4:	8526                	mv	a0,s1
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	5f0080e7          	jalr	1520(ra) # 800014a6 <uvmunmap>
    uvmfree(pagetable, sz);
    80001ebe:	85ca                	mv	a1,s2
    80001ec0:	8526                	mv	a0,s1
    80001ec2:	00000097          	auipc	ra,0x0
    80001ec6:	8ca080e7          	jalr	-1846(ra) # 8000178c <uvmfree>
}
    80001eca:	60e2                	ld	ra,24(sp)
    80001ecc:	6442                	ld	s0,16(sp)
    80001ece:	64a2                	ld	s1,8(sp)
    80001ed0:	6902                	ld	s2,0(sp)
    80001ed2:	6105                	addi	sp,sp,32
    80001ed4:	8082                	ret

0000000080001ed6 <freeproc>:
{
    80001ed6:	1101                	addi	sp,sp,-32
    80001ed8:	ec06                	sd	ra,24(sp)
    80001eda:	e822                	sd	s0,16(sp)
    80001edc:	e426                	sd	s1,8(sp)
    80001ede:	1000                	addi	s0,sp,32
    80001ee0:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001ee2:	6d28                	ld	a0,88(a0)
    80001ee4:	c509                	beqz	a0,80001eee <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001ee6:	fffff097          	auipc	ra,0xfffff
    80001eea:	bc8080e7          	jalr	-1080(ra) # 80000aae <kfree>
    p->trapframe = 0;
    80001eee:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001ef2:	68a8                	ld	a0,80(s1)
    80001ef4:	c511                	beqz	a0,80001f00 <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001ef6:	64ac                	ld	a1,72(s1)
    80001ef8:	00000097          	auipc	ra,0x0
    80001efc:	f8c080e7          	jalr	-116(ra) # 80001e84 <proc_freepagetable>
    p->pagetable = 0;
    80001f00:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001f04:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001f08:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001f0c:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001f10:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001f14:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001f18:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001f1c:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001f20:	0004ac23          	sw	zero,24(s1)
}
    80001f24:	60e2                	ld	ra,24(sp)
    80001f26:	6442                	ld	s0,16(sp)
    80001f28:	64a2                	ld	s1,8(sp)
    80001f2a:	6105                	addi	sp,sp,32
    80001f2c:	8082                	ret

0000000080001f2e <allocproc>:
{
    80001f2e:	1101                	addi	sp,sp,-32
    80001f30:	ec06                	sd	ra,24(sp)
    80001f32:	e822                	sd	s0,16(sp)
    80001f34:	e426                	sd	s1,8(sp)
    80001f36:	e04a                	sd	s2,0(sp)
    80001f38:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001f3a:	0001a497          	auipc	s1,0x1a
    80001f3e:	d2e48493          	addi	s1,s1,-722 # 8001bc68 <proc>
    80001f42:	0001f917          	auipc	s2,0x1f
    80001f46:	72690913          	addi	s2,s2,1830 # 80021668 <tickslock>
        acquire(&p->lock);
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	ed4080e7          	jalr	-300(ra) # 80000e20 <acquire>
        if (p->state == UNUSED)
    80001f54:	4c9c                	lw	a5,24(s1)
    80001f56:	cf81                	beqz	a5,80001f6e <allocproc+0x40>
            release(&p->lock);
    80001f58:	8526                	mv	a0,s1
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	f7a080e7          	jalr	-134(ra) # 80000ed4 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001f62:	16848493          	addi	s1,s1,360
    80001f66:	ff2492e3          	bne	s1,s2,80001f4a <allocproc+0x1c>
    return 0;
    80001f6a:	4481                	li	s1,0
    80001f6c:	a889                	j	80001fbe <allocproc+0x90>
    p->pid = allocpid();
    80001f6e:	00000097          	auipc	ra,0x0
    80001f72:	e34080e7          	jalr	-460(ra) # 80001da2 <allocpid>
    80001f76:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001f78:	4785                	li	a5,1
    80001f7a:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001f7c:	fffff097          	auipc	ra,0xfffff
    80001f80:	d26080e7          	jalr	-730(ra) # 80000ca2 <kalloc>
    80001f84:	892a                	mv	s2,a0
    80001f86:	eca8                	sd	a0,88(s1)
    80001f88:	c131                	beqz	a0,80001fcc <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001f8a:	8526                	mv	a0,s1
    80001f8c:	00000097          	auipc	ra,0x0
    80001f90:	e5c080e7          	jalr	-420(ra) # 80001de8 <proc_pagetable>
    80001f94:	892a                	mv	s2,a0
    80001f96:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001f98:	c531                	beqz	a0,80001fe4 <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001f9a:	07000613          	li	a2,112
    80001f9e:	4581                	li	a1,0
    80001fa0:	06048513          	addi	a0,s1,96
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	f78080e7          	jalr	-136(ra) # 80000f1c <memset>
    p->context.ra = (uint64)forkret;
    80001fac:	00000797          	auipc	a5,0x0
    80001fb0:	db078793          	addi	a5,a5,-592 # 80001d5c <forkret>
    80001fb4:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001fb6:	60bc                	ld	a5,64(s1)
    80001fb8:	6705                	lui	a4,0x1
    80001fba:	97ba                	add	a5,a5,a4
    80001fbc:	f4bc                	sd	a5,104(s1)
}
    80001fbe:	8526                	mv	a0,s1
    80001fc0:	60e2                	ld	ra,24(sp)
    80001fc2:	6442                	ld	s0,16(sp)
    80001fc4:	64a2                	ld	s1,8(sp)
    80001fc6:	6902                	ld	s2,0(sp)
    80001fc8:	6105                	addi	sp,sp,32
    80001fca:	8082                	ret
        freeproc(p);
    80001fcc:	8526                	mv	a0,s1
    80001fce:	00000097          	auipc	ra,0x0
    80001fd2:	f08080e7          	jalr	-248(ra) # 80001ed6 <freeproc>
        release(&p->lock);
    80001fd6:	8526                	mv	a0,s1
    80001fd8:	fffff097          	auipc	ra,0xfffff
    80001fdc:	efc080e7          	jalr	-260(ra) # 80000ed4 <release>
        return 0;
    80001fe0:	84ca                	mv	s1,s2
    80001fe2:	bff1                	j	80001fbe <allocproc+0x90>
        freeproc(p);
    80001fe4:	8526                	mv	a0,s1
    80001fe6:	00000097          	auipc	ra,0x0
    80001fea:	ef0080e7          	jalr	-272(ra) # 80001ed6 <freeproc>
        release(&p->lock);
    80001fee:	8526                	mv	a0,s1
    80001ff0:	fffff097          	auipc	ra,0xfffff
    80001ff4:	ee4080e7          	jalr	-284(ra) # 80000ed4 <release>
        return 0;
    80001ff8:	84ca                	mv	s1,s2
    80001ffa:	b7d1                	j	80001fbe <allocproc+0x90>

0000000080001ffc <userinit>:
{
    80001ffc:	1101                	addi	sp,sp,-32
    80001ffe:	ec06                	sd	ra,24(sp)
    80002000:	e822                	sd	s0,16(sp)
    80002002:	e426                	sd	s1,8(sp)
    80002004:	1000                	addi	s0,sp,32
    p = allocproc();
    80002006:	00000097          	auipc	ra,0x0
    8000200a:	f28080e7          	jalr	-216(ra) # 80001f2e <allocproc>
    8000200e:	84aa                	mv	s1,a0
    initproc = p;
    80002010:	00009797          	auipc	a5,0x9
    80002014:	58a7bc23          	sd	a0,1432(a5) # 8000b5a8 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80002018:	03400613          	li	a2,52
    8000201c:	00009597          	auipc	a1,0x9
    80002020:	4d458593          	addi	a1,a1,1236 # 8000b4f0 <initcode>
    80002024:	6928                	ld	a0,80(a0)
    80002026:	fffff097          	auipc	ra,0xfffff
    8000202a:	582080e7          	jalr	1410(ra) # 800015a8 <uvmfirst>
    p->sz = PGSIZE;
    8000202e:	6785                	lui	a5,0x1
    80002030:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    80002032:	6cb8                	ld	a4,88(s1)
    80002034:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80002038:	6cb8                	ld	a4,88(s1)
    8000203a:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    8000203c:	4641                	li	a2,16
    8000203e:	00006597          	auipc	a1,0x6
    80002042:	1f258593          	addi	a1,a1,498 # 80008230 <__func__.1+0x228>
    80002046:	15848513          	addi	a0,s1,344
    8000204a:	fffff097          	auipc	ra,0xfffff
    8000204e:	014080e7          	jalr	20(ra) # 8000105e <safestrcpy>
    p->cwd = namei("/");
    80002052:	00006517          	auipc	a0,0x6
    80002056:	1ee50513          	addi	a0,a0,494 # 80008240 <__func__.1+0x238>
    8000205a:	00002097          	auipc	ra,0x2
    8000205e:	56a080e7          	jalr	1386(ra) # 800045c4 <namei>
    80002062:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80002066:	478d                	li	a5,3
    80002068:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    8000206a:	8526                	mv	a0,s1
    8000206c:	fffff097          	auipc	ra,0xfffff
    80002070:	e68080e7          	jalr	-408(ra) # 80000ed4 <release>
}
    80002074:	60e2                	ld	ra,24(sp)
    80002076:	6442                	ld	s0,16(sp)
    80002078:	64a2                	ld	s1,8(sp)
    8000207a:	6105                	addi	sp,sp,32
    8000207c:	8082                	ret

000000008000207e <growproc>:
{
    8000207e:	1101                	addi	sp,sp,-32
    80002080:	ec06                	sd	ra,24(sp)
    80002082:	e822                	sd	s0,16(sp)
    80002084:	e426                	sd	s1,8(sp)
    80002086:	e04a                	sd	s2,0(sp)
    80002088:	1000                	addi	s0,sp,32
    8000208a:	892a                	mv	s2,a0
    struct proc *p = myproc();
    8000208c:	00000097          	auipc	ra,0x0
    80002090:	c98080e7          	jalr	-872(ra) # 80001d24 <myproc>
    80002094:	84aa                	mv	s1,a0
    sz = p->sz;
    80002096:	652c                	ld	a1,72(a0)
    if (n > 0)
    80002098:	01204c63          	bgtz	s2,800020b0 <growproc+0x32>
    else if (n < 0)
    8000209c:	02094663          	bltz	s2,800020c8 <growproc+0x4a>
    p->sz = sz;
    800020a0:	e4ac                	sd	a1,72(s1)
    return 0;
    800020a2:	4501                	li	a0,0
}
    800020a4:	60e2                	ld	ra,24(sp)
    800020a6:	6442                	ld	s0,16(sp)
    800020a8:	64a2                	ld	s1,8(sp)
    800020aa:	6902                	ld	s2,0(sp)
    800020ac:	6105                	addi	sp,sp,32
    800020ae:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    800020b0:	4691                	li	a3,4
    800020b2:	00b90633          	add	a2,s2,a1
    800020b6:	6928                	ld	a0,80(a0)
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	5aa080e7          	jalr	1450(ra) # 80001662 <uvmalloc>
    800020c0:	85aa                	mv	a1,a0
    800020c2:	fd79                	bnez	a0,800020a0 <growproc+0x22>
            return -1;
    800020c4:	557d                	li	a0,-1
    800020c6:	bff9                	j	800020a4 <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    800020c8:	00b90633          	add	a2,s2,a1
    800020cc:	6928                	ld	a0,80(a0)
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	54c080e7          	jalr	1356(ra) # 8000161a <uvmdealloc>
    800020d6:	85aa                	mv	a1,a0
    800020d8:	b7e1                	j	800020a0 <growproc+0x22>

00000000800020da <ps>:
{
    800020da:	715d                	addi	sp,sp,-80
    800020dc:	e486                	sd	ra,72(sp)
    800020de:	e0a2                	sd	s0,64(sp)
    800020e0:	fc26                	sd	s1,56(sp)
    800020e2:	f84a                	sd	s2,48(sp)
    800020e4:	f44e                	sd	s3,40(sp)
    800020e6:	f052                	sd	s4,32(sp)
    800020e8:	ec56                	sd	s5,24(sp)
    800020ea:	e85a                	sd	s6,16(sp)
    800020ec:	e45e                	sd	s7,8(sp)
    800020ee:	e062                	sd	s8,0(sp)
    800020f0:	0880                	addi	s0,sp,80
    800020f2:	84aa                	mv	s1,a0
    800020f4:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    800020f6:	00000097          	auipc	ra,0x0
    800020fa:	c2e080e7          	jalr	-978(ra) # 80001d24 <myproc>
        return result;
    800020fe:	4901                	li	s2,0
    if (count == 0)
    80002100:	0c0b8663          	beqz	s7,800021cc <ps+0xf2>
    void *result = (void *)myproc()->sz;
    80002104:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    80002108:	003b951b          	slliw	a0,s7,0x3
    8000210c:	0175053b          	addw	a0,a0,s7
    80002110:	0025151b          	slliw	a0,a0,0x2
    80002114:	2501                	sext.w	a0,a0
    80002116:	00000097          	auipc	ra,0x0
    8000211a:	f68080e7          	jalr	-152(ra) # 8000207e <growproc>
    8000211e:	12054f63          	bltz	a0,8000225c <ps+0x182>
    struct user_proc loc_result[count];
    80002122:	003b9a13          	slli	s4,s7,0x3
    80002126:	9a5e                	add	s4,s4,s7
    80002128:	0a0a                	slli	s4,s4,0x2
    8000212a:	00fa0793          	addi	a5,s4,15
    8000212e:	8391                	srli	a5,a5,0x4
    80002130:	0792                	slli	a5,a5,0x4
    80002132:	40f10133          	sub	sp,sp,a5
    80002136:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    80002138:	16800793          	li	a5,360
    8000213c:	02f484b3          	mul	s1,s1,a5
    80002140:	0001a797          	auipc	a5,0x1a
    80002144:	b2878793          	addi	a5,a5,-1240 # 8001bc68 <proc>
    80002148:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    8000214a:	0001f797          	auipc	a5,0x1f
    8000214e:	51e78793          	addi	a5,a5,1310 # 80021668 <tickslock>
        return result;
    80002152:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    80002154:	06f4fc63          	bgeu	s1,a5,800021cc <ps+0xf2>
    acquire(&wait_lock);
    80002158:	0001a517          	auipc	a0,0x1a
    8000215c:	af850513          	addi	a0,a0,-1288 # 8001bc50 <wait_lock>
    80002160:	fffff097          	auipc	ra,0xfffff
    80002164:	cc0080e7          	jalr	-832(ra) # 80000e20 <acquire>
        if (localCount == count)
    80002168:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    8000216c:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    8000216e:	0001fc17          	auipc	s8,0x1f
    80002172:	4fac0c13          	addi	s8,s8,1274 # 80021668 <tickslock>
    80002176:	a851                	j	8000220a <ps+0x130>
            loc_result[localCount].state = UNUSED;
    80002178:	00399793          	slli	a5,s3,0x3
    8000217c:	97ce                	add	a5,a5,s3
    8000217e:	078a                	slli	a5,a5,0x2
    80002180:	97d6                	add	a5,a5,s5
    80002182:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    80002186:	8526                	mv	a0,s1
    80002188:	fffff097          	auipc	ra,0xfffff
    8000218c:	d4c080e7          	jalr	-692(ra) # 80000ed4 <release>
    release(&wait_lock);
    80002190:	0001a517          	auipc	a0,0x1a
    80002194:	ac050513          	addi	a0,a0,-1344 # 8001bc50 <wait_lock>
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	d3c080e7          	jalr	-708(ra) # 80000ed4 <release>
    if (localCount < count)
    800021a0:	0179f963          	bgeu	s3,s7,800021b2 <ps+0xd8>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    800021a4:	00399793          	slli	a5,s3,0x3
    800021a8:	97ce                	add	a5,a5,s3
    800021aa:	078a                	slli	a5,a5,0x2
    800021ac:	97d6                	add	a5,a5,s5
    800021ae:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    800021b2:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    800021b4:	00000097          	auipc	ra,0x0
    800021b8:	b70080e7          	jalr	-1168(ra) # 80001d24 <myproc>
    800021bc:	86d2                	mv	a3,s4
    800021be:	8656                	mv	a2,s5
    800021c0:	85da                	mv	a1,s6
    800021c2:	6928                	ld	a0,80(a0)
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	704080e7          	jalr	1796(ra) # 800018c8 <copyout>
}
    800021cc:	854a                	mv	a0,s2
    800021ce:	fb040113          	addi	sp,s0,-80
    800021d2:	60a6                	ld	ra,72(sp)
    800021d4:	6406                	ld	s0,64(sp)
    800021d6:	74e2                	ld	s1,56(sp)
    800021d8:	7942                	ld	s2,48(sp)
    800021da:	79a2                	ld	s3,40(sp)
    800021dc:	7a02                	ld	s4,32(sp)
    800021de:	6ae2                	ld	s5,24(sp)
    800021e0:	6b42                	ld	s6,16(sp)
    800021e2:	6ba2                	ld	s7,8(sp)
    800021e4:	6c02                	ld	s8,0(sp)
    800021e6:	6161                	addi	sp,sp,80
    800021e8:	8082                	ret
        release(&p->lock);
    800021ea:	8526                	mv	a0,s1
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	ce8080e7          	jalr	-792(ra) # 80000ed4 <release>
        localCount++;
    800021f4:	2985                	addiw	s3,s3,1
    800021f6:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    800021fa:	16848493          	addi	s1,s1,360
    800021fe:	f984f9e3          	bgeu	s1,s8,80002190 <ps+0xb6>
        if (localCount == count)
    80002202:	02490913          	addi	s2,s2,36
    80002206:	053b8d63          	beq	s7,s3,80002260 <ps+0x186>
        acquire(&p->lock);
    8000220a:	8526                	mv	a0,s1
    8000220c:	fffff097          	auipc	ra,0xfffff
    80002210:	c14080e7          	jalr	-1004(ra) # 80000e20 <acquire>
        if (p->state == UNUSED)
    80002214:	4c9c                	lw	a5,24(s1)
    80002216:	d3ad                	beqz	a5,80002178 <ps+0x9e>
        loc_result[localCount].state = p->state;
    80002218:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    8000221c:	549c                	lw	a5,40(s1)
    8000221e:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    80002222:	54dc                	lw	a5,44(s1)
    80002224:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    80002228:	589c                	lw	a5,48(s1)
    8000222a:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    8000222e:	4641                	li	a2,16
    80002230:	85ca                	mv	a1,s2
    80002232:	15848513          	addi	a0,s1,344
    80002236:	00000097          	auipc	ra,0x0
    8000223a:	a9e080e7          	jalr	-1378(ra) # 80001cd4 <copy_array>
        if (p->parent != 0) // init
    8000223e:	7c88                	ld	a0,56(s1)
    80002240:	d54d                	beqz	a0,800021ea <ps+0x110>
            acquire(&p->parent->lock);
    80002242:	fffff097          	auipc	ra,0xfffff
    80002246:	bde080e7          	jalr	-1058(ra) # 80000e20 <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    8000224a:	7c88                	ld	a0,56(s1)
    8000224c:	591c                	lw	a5,48(a0)
    8000224e:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    80002252:	fffff097          	auipc	ra,0xfffff
    80002256:	c82080e7          	jalr	-894(ra) # 80000ed4 <release>
    8000225a:	bf41                	j	800021ea <ps+0x110>
        return result;
    8000225c:	4901                	li	s2,0
    8000225e:	b7bd                	j	800021cc <ps+0xf2>
    release(&wait_lock);
    80002260:	0001a517          	auipc	a0,0x1a
    80002264:	9f050513          	addi	a0,a0,-1552 # 8001bc50 <wait_lock>
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	c6c080e7          	jalr	-916(ra) # 80000ed4 <release>
    if (localCount < count)
    80002270:	b789                	j	800021b2 <ps+0xd8>

0000000080002272 <fork>:
{
    80002272:	7139                	addi	sp,sp,-64
    80002274:	fc06                	sd	ra,56(sp)
    80002276:	f822                	sd	s0,48(sp)
    80002278:	f04a                	sd	s2,32(sp)
    8000227a:	e456                	sd	s5,8(sp)
    8000227c:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    8000227e:	00000097          	auipc	ra,0x0
    80002282:	aa6080e7          	jalr	-1370(ra) # 80001d24 <myproc>
    80002286:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    80002288:	00000097          	auipc	ra,0x0
    8000228c:	ca6080e7          	jalr	-858(ra) # 80001f2e <allocproc>
    80002290:	12050063          	beqz	a0,800023b0 <fork+0x13e>
    80002294:	e852                	sd	s4,16(sp)
    80002296:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002298:	048ab603          	ld	a2,72(s5)
    8000229c:	692c                	ld	a1,80(a0)
    8000229e:	050ab503          	ld	a0,80(s5)
    800022a2:	fffff097          	auipc	ra,0xfffff
    800022a6:	524080e7          	jalr	1316(ra) # 800017c6 <uvmcopy>
    800022aa:	04054a63          	bltz	a0,800022fe <fork+0x8c>
    800022ae:	f426                	sd	s1,40(sp)
    800022b0:	ec4e                	sd	s3,24(sp)
    np->sz = p->sz;
    800022b2:	048ab783          	ld	a5,72(s5)
    800022b6:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    800022ba:	058ab683          	ld	a3,88(s5)
    800022be:	87b6                	mv	a5,a3
    800022c0:	058a3703          	ld	a4,88(s4)
    800022c4:	12068693          	addi	a3,a3,288
    800022c8:	0007b803          	ld	a6,0(a5)
    800022cc:	6788                	ld	a0,8(a5)
    800022ce:	6b8c                	ld	a1,16(a5)
    800022d0:	6f90                	ld	a2,24(a5)
    800022d2:	01073023          	sd	a6,0(a4)
    800022d6:	e708                	sd	a0,8(a4)
    800022d8:	eb0c                	sd	a1,16(a4)
    800022da:	ef10                	sd	a2,24(a4)
    800022dc:	02078793          	addi	a5,a5,32
    800022e0:	02070713          	addi	a4,a4,32
    800022e4:	fed792e3          	bne	a5,a3,800022c8 <fork+0x56>
    np->trapframe->a0 = 0;
    800022e8:	058a3783          	ld	a5,88(s4)
    800022ec:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    800022f0:	0d0a8493          	addi	s1,s5,208
    800022f4:	0d0a0913          	addi	s2,s4,208
    800022f8:	150a8993          	addi	s3,s5,336
    800022fc:	a015                	j	80002320 <fork+0xae>
        freeproc(np);
    800022fe:	8552                	mv	a0,s4
    80002300:	00000097          	auipc	ra,0x0
    80002304:	bd6080e7          	jalr	-1066(ra) # 80001ed6 <freeproc>
        release(&np->lock);
    80002308:	8552                	mv	a0,s4
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	bca080e7          	jalr	-1078(ra) # 80000ed4 <release>
        return -1;
    80002312:	597d                	li	s2,-1
    80002314:	6a42                	ld	s4,16(sp)
    80002316:	a071                	j	800023a2 <fork+0x130>
    for (i = 0; i < NOFILE; i++)
    80002318:	04a1                	addi	s1,s1,8
    8000231a:	0921                	addi	s2,s2,8
    8000231c:	01348b63          	beq	s1,s3,80002332 <fork+0xc0>
        if (p->ofile[i])
    80002320:	6088                	ld	a0,0(s1)
    80002322:	d97d                	beqz	a0,80002318 <fork+0xa6>
            np->ofile[i] = filedup(p->ofile[i]);
    80002324:	00003097          	auipc	ra,0x3
    80002328:	918080e7          	jalr	-1768(ra) # 80004c3c <filedup>
    8000232c:	00a93023          	sd	a0,0(s2)
    80002330:	b7e5                	j	80002318 <fork+0xa6>
    np->cwd = idup(p->cwd);
    80002332:	150ab503          	ld	a0,336(s5)
    80002336:	00002097          	auipc	ra,0x2
    8000233a:	a82080e7          	jalr	-1406(ra) # 80003db8 <idup>
    8000233e:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    80002342:	4641                	li	a2,16
    80002344:	158a8593          	addi	a1,s5,344
    80002348:	158a0513          	addi	a0,s4,344
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	d12080e7          	jalr	-750(ra) # 8000105e <safestrcpy>
    pid = np->pid;
    80002354:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    80002358:	8552                	mv	a0,s4
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	b7a080e7          	jalr	-1158(ra) # 80000ed4 <release>
    acquire(&wait_lock);
    80002362:	0001a497          	auipc	s1,0x1a
    80002366:	8ee48493          	addi	s1,s1,-1810 # 8001bc50 <wait_lock>
    8000236a:	8526                	mv	a0,s1
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	ab4080e7          	jalr	-1356(ra) # 80000e20 <acquire>
    np->parent = p;
    80002374:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    80002378:	8526                	mv	a0,s1
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	b5a080e7          	jalr	-1190(ra) # 80000ed4 <release>
    acquire(&np->lock);
    80002382:	8552                	mv	a0,s4
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	a9c080e7          	jalr	-1380(ra) # 80000e20 <acquire>
    np->state = RUNNABLE;
    8000238c:	478d                	li	a5,3
    8000238e:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    80002392:	8552                	mv	a0,s4
    80002394:	fffff097          	auipc	ra,0xfffff
    80002398:	b40080e7          	jalr	-1216(ra) # 80000ed4 <release>
    return pid;
    8000239c:	74a2                	ld	s1,40(sp)
    8000239e:	69e2                	ld	s3,24(sp)
    800023a0:	6a42                	ld	s4,16(sp)
}
    800023a2:	854a                	mv	a0,s2
    800023a4:	70e2                	ld	ra,56(sp)
    800023a6:	7442                	ld	s0,48(sp)
    800023a8:	7902                	ld	s2,32(sp)
    800023aa:	6aa2                	ld	s5,8(sp)
    800023ac:	6121                	addi	sp,sp,64
    800023ae:	8082                	ret
        return -1;
    800023b0:	597d                	li	s2,-1
    800023b2:	bfc5                	j	800023a2 <fork+0x130>

00000000800023b4 <scheduler>:
{
    800023b4:	1101                	addi	sp,sp,-32
    800023b6:	ec06                	sd	ra,24(sp)
    800023b8:	e822                	sd	s0,16(sp)
    800023ba:	e426                	sd	s1,8(sp)
    800023bc:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    800023be:	00009497          	auipc	s1,0x9
    800023c2:	11a48493          	addi	s1,s1,282 # 8000b4d8 <sched_pointer>
    800023c6:	609c                	ld	a5,0(s1)
    800023c8:	9782                	jalr	a5
    while (1)
    800023ca:	bff5                	j	800023c6 <scheduler+0x12>

00000000800023cc <sched>:
{
    800023cc:	7179                	addi	sp,sp,-48
    800023ce:	f406                	sd	ra,40(sp)
    800023d0:	f022                	sd	s0,32(sp)
    800023d2:	ec26                	sd	s1,24(sp)
    800023d4:	e84a                	sd	s2,16(sp)
    800023d6:	e44e                	sd	s3,8(sp)
    800023d8:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    800023da:	00000097          	auipc	ra,0x0
    800023de:	94a080e7          	jalr	-1718(ra) # 80001d24 <myproc>
    800023e2:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	9c2080e7          	jalr	-1598(ra) # 80000da6 <holding>
    800023ec:	c53d                	beqz	a0,8000245a <sched+0x8e>
    800023ee:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    800023f0:	2781                	sext.w	a5,a5
    800023f2:	079e                	slli	a5,a5,0x7
    800023f4:	00019717          	auipc	a4,0x19
    800023f8:	44470713          	addi	a4,a4,1092 # 8001b838 <cpus>
    800023fc:	97ba                	add	a5,a5,a4
    800023fe:	5fb8                	lw	a4,120(a5)
    80002400:	4785                	li	a5,1
    80002402:	06f71463          	bne	a4,a5,8000246a <sched+0x9e>
    if (p->state == RUNNING)
    80002406:	4c98                	lw	a4,24(s1)
    80002408:	4791                	li	a5,4
    8000240a:	06f70863          	beq	a4,a5,8000247a <sched+0xae>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    8000240e:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80002412:	8b89                	andi	a5,a5,2
    if (intr_get())
    80002414:	ebbd                	bnez	a5,8000248a <sched+0xbe>
    asm volatile("mv %0, tp" : "=r"(x));
    80002416:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    80002418:	00019917          	auipc	s2,0x19
    8000241c:	42090913          	addi	s2,s2,1056 # 8001b838 <cpus>
    80002420:	2781                	sext.w	a5,a5
    80002422:	079e                	slli	a5,a5,0x7
    80002424:	97ca                	add	a5,a5,s2
    80002426:	07c7a983          	lw	s3,124(a5)
    8000242a:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    8000242c:	2581                	sext.w	a1,a1
    8000242e:	059e                	slli	a1,a1,0x7
    80002430:	05a1                	addi	a1,a1,8
    80002432:	95ca                	add	a1,a1,s2
    80002434:	06048513          	addi	a0,s1,96
    80002438:	00000097          	auipc	ra,0x0
    8000243c:	6e4080e7          	jalr	1764(ra) # 80002b1c <swtch>
    80002440:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    80002442:	2781                	sext.w	a5,a5
    80002444:	079e                	slli	a5,a5,0x7
    80002446:	993e                	add	s2,s2,a5
    80002448:	07392e23          	sw	s3,124(s2)
}
    8000244c:	70a2                	ld	ra,40(sp)
    8000244e:	7402                	ld	s0,32(sp)
    80002450:	64e2                	ld	s1,24(sp)
    80002452:	6942                	ld	s2,16(sp)
    80002454:	69a2                	ld	s3,8(sp)
    80002456:	6145                	addi	sp,sp,48
    80002458:	8082                	ret
        panic("sched p->lock");
    8000245a:	00006517          	auipc	a0,0x6
    8000245e:	dee50513          	addi	a0,a0,-530 # 80008248 <__func__.1+0x240>
    80002462:	ffffe097          	auipc	ra,0xffffe
    80002466:	0fe080e7          	jalr	254(ra) # 80000560 <panic>
        panic("sched locks");
    8000246a:	00006517          	auipc	a0,0x6
    8000246e:	dee50513          	addi	a0,a0,-530 # 80008258 <__func__.1+0x250>
    80002472:	ffffe097          	auipc	ra,0xffffe
    80002476:	0ee080e7          	jalr	238(ra) # 80000560 <panic>
        panic("sched running");
    8000247a:	00006517          	auipc	a0,0x6
    8000247e:	dee50513          	addi	a0,a0,-530 # 80008268 <__func__.1+0x260>
    80002482:	ffffe097          	auipc	ra,0xffffe
    80002486:	0de080e7          	jalr	222(ra) # 80000560 <panic>
        panic("sched interruptible");
    8000248a:	00006517          	auipc	a0,0x6
    8000248e:	dee50513          	addi	a0,a0,-530 # 80008278 <__func__.1+0x270>
    80002492:	ffffe097          	auipc	ra,0xffffe
    80002496:	0ce080e7          	jalr	206(ra) # 80000560 <panic>

000000008000249a <yield>:
{
    8000249a:	1101                	addi	sp,sp,-32
    8000249c:	ec06                	sd	ra,24(sp)
    8000249e:	e822                	sd	s0,16(sp)
    800024a0:	e426                	sd	s1,8(sp)
    800024a2:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    800024a4:	00000097          	auipc	ra,0x0
    800024a8:	880080e7          	jalr	-1920(ra) # 80001d24 <myproc>
    800024ac:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800024ae:	fffff097          	auipc	ra,0xfffff
    800024b2:	972080e7          	jalr	-1678(ra) # 80000e20 <acquire>
    p->state = RUNNABLE;
    800024b6:	478d                	li	a5,3
    800024b8:	cc9c                	sw	a5,24(s1)
    sched();
    800024ba:	00000097          	auipc	ra,0x0
    800024be:	f12080e7          	jalr	-238(ra) # 800023cc <sched>
    release(&p->lock);
    800024c2:	8526                	mv	a0,s1
    800024c4:	fffff097          	auipc	ra,0xfffff
    800024c8:	a10080e7          	jalr	-1520(ra) # 80000ed4 <release>
}
    800024cc:	60e2                	ld	ra,24(sp)
    800024ce:	6442                	ld	s0,16(sp)
    800024d0:	64a2                	ld	s1,8(sp)
    800024d2:	6105                	addi	sp,sp,32
    800024d4:	8082                	ret

00000000800024d6 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800024d6:	7179                	addi	sp,sp,-48
    800024d8:	f406                	sd	ra,40(sp)
    800024da:	f022                	sd	s0,32(sp)
    800024dc:	ec26                	sd	s1,24(sp)
    800024de:	e84a                	sd	s2,16(sp)
    800024e0:	e44e                	sd	s3,8(sp)
    800024e2:	1800                	addi	s0,sp,48
    800024e4:	89aa                	mv	s3,a0
    800024e6:	892e                	mv	s2,a1
    struct proc *p = myproc();
    800024e8:	00000097          	auipc	ra,0x0
    800024ec:	83c080e7          	jalr	-1988(ra) # 80001d24 <myproc>
    800024f0:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    800024f2:	fffff097          	auipc	ra,0xfffff
    800024f6:	92e080e7          	jalr	-1746(ra) # 80000e20 <acquire>
    release(lk);
    800024fa:	854a                	mv	a0,s2
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	9d8080e7          	jalr	-1576(ra) # 80000ed4 <release>

    // Go to sleep.
    p->chan = chan;
    80002504:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    80002508:	4789                	li	a5,2
    8000250a:	cc9c                	sw	a5,24(s1)

    sched();
    8000250c:	00000097          	auipc	ra,0x0
    80002510:	ec0080e7          	jalr	-320(ra) # 800023cc <sched>

    // Tidy up.
    p->chan = 0;
    80002514:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    80002518:	8526                	mv	a0,s1
    8000251a:	fffff097          	auipc	ra,0xfffff
    8000251e:	9ba080e7          	jalr	-1606(ra) # 80000ed4 <release>
    acquire(lk);
    80002522:	854a                	mv	a0,s2
    80002524:	fffff097          	auipc	ra,0xfffff
    80002528:	8fc080e7          	jalr	-1796(ra) # 80000e20 <acquire>
}
    8000252c:	70a2                	ld	ra,40(sp)
    8000252e:	7402                	ld	s0,32(sp)
    80002530:	64e2                	ld	s1,24(sp)
    80002532:	6942                	ld	s2,16(sp)
    80002534:	69a2                	ld	s3,8(sp)
    80002536:	6145                	addi	sp,sp,48
    80002538:	8082                	ret

000000008000253a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000253a:	7139                	addi	sp,sp,-64
    8000253c:	fc06                	sd	ra,56(sp)
    8000253e:	f822                	sd	s0,48(sp)
    80002540:	f426                	sd	s1,40(sp)
    80002542:	f04a                	sd	s2,32(sp)
    80002544:	ec4e                	sd	s3,24(sp)
    80002546:	e852                	sd	s4,16(sp)
    80002548:	e456                	sd	s5,8(sp)
    8000254a:	0080                	addi	s0,sp,64
    8000254c:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    8000254e:	00019497          	auipc	s1,0x19
    80002552:	71a48493          	addi	s1,s1,1818 # 8001bc68 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    80002556:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    80002558:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    8000255a:	0001f917          	auipc	s2,0x1f
    8000255e:	10e90913          	addi	s2,s2,270 # 80021668 <tickslock>
    80002562:	a811                	j	80002576 <wakeup+0x3c>
            }
            release(&p->lock);
    80002564:	8526                	mv	a0,s1
    80002566:	fffff097          	auipc	ra,0xfffff
    8000256a:	96e080e7          	jalr	-1682(ra) # 80000ed4 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000256e:	16848493          	addi	s1,s1,360
    80002572:	03248663          	beq	s1,s2,8000259e <wakeup+0x64>
        if (p != myproc())
    80002576:	fffff097          	auipc	ra,0xfffff
    8000257a:	7ae080e7          	jalr	1966(ra) # 80001d24 <myproc>
    8000257e:	fea488e3          	beq	s1,a0,8000256e <wakeup+0x34>
            acquire(&p->lock);
    80002582:	8526                	mv	a0,s1
    80002584:	fffff097          	auipc	ra,0xfffff
    80002588:	89c080e7          	jalr	-1892(ra) # 80000e20 <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    8000258c:	4c9c                	lw	a5,24(s1)
    8000258e:	fd379be3          	bne	a5,s3,80002564 <wakeup+0x2a>
    80002592:	709c                	ld	a5,32(s1)
    80002594:	fd4798e3          	bne	a5,s4,80002564 <wakeup+0x2a>
                p->state = RUNNABLE;
    80002598:	0154ac23          	sw	s5,24(s1)
    8000259c:	b7e1                	j	80002564 <wakeup+0x2a>
        }
    }
}
    8000259e:	70e2                	ld	ra,56(sp)
    800025a0:	7442                	ld	s0,48(sp)
    800025a2:	74a2                	ld	s1,40(sp)
    800025a4:	7902                	ld	s2,32(sp)
    800025a6:	69e2                	ld	s3,24(sp)
    800025a8:	6a42                	ld	s4,16(sp)
    800025aa:	6aa2                	ld	s5,8(sp)
    800025ac:	6121                	addi	sp,sp,64
    800025ae:	8082                	ret

00000000800025b0 <reparent>:
{
    800025b0:	7179                	addi	sp,sp,-48
    800025b2:	f406                	sd	ra,40(sp)
    800025b4:	f022                	sd	s0,32(sp)
    800025b6:	ec26                	sd	s1,24(sp)
    800025b8:	e84a                	sd	s2,16(sp)
    800025ba:	e44e                	sd	s3,8(sp)
    800025bc:	e052                	sd	s4,0(sp)
    800025be:	1800                	addi	s0,sp,48
    800025c0:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800025c2:	00019497          	auipc	s1,0x19
    800025c6:	6a648493          	addi	s1,s1,1702 # 8001bc68 <proc>
            pp->parent = initproc;
    800025ca:	00009a17          	auipc	s4,0x9
    800025ce:	fdea0a13          	addi	s4,s4,-34 # 8000b5a8 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800025d2:	0001f997          	auipc	s3,0x1f
    800025d6:	09698993          	addi	s3,s3,150 # 80021668 <tickslock>
    800025da:	a029                	j	800025e4 <reparent+0x34>
    800025dc:	16848493          	addi	s1,s1,360
    800025e0:	01348d63          	beq	s1,s3,800025fa <reparent+0x4a>
        if (pp->parent == p)
    800025e4:	7c9c                	ld	a5,56(s1)
    800025e6:	ff279be3          	bne	a5,s2,800025dc <reparent+0x2c>
            pp->parent = initproc;
    800025ea:	000a3503          	ld	a0,0(s4)
    800025ee:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    800025f0:	00000097          	auipc	ra,0x0
    800025f4:	f4a080e7          	jalr	-182(ra) # 8000253a <wakeup>
    800025f8:	b7d5                	j	800025dc <reparent+0x2c>
}
    800025fa:	70a2                	ld	ra,40(sp)
    800025fc:	7402                	ld	s0,32(sp)
    800025fe:	64e2                	ld	s1,24(sp)
    80002600:	6942                	ld	s2,16(sp)
    80002602:	69a2                	ld	s3,8(sp)
    80002604:	6a02                	ld	s4,0(sp)
    80002606:	6145                	addi	sp,sp,48
    80002608:	8082                	ret

000000008000260a <exit>:
{
    8000260a:	7179                	addi	sp,sp,-48
    8000260c:	f406                	sd	ra,40(sp)
    8000260e:	f022                	sd	s0,32(sp)
    80002610:	ec26                	sd	s1,24(sp)
    80002612:	e84a                	sd	s2,16(sp)
    80002614:	e44e                	sd	s3,8(sp)
    80002616:	e052                	sd	s4,0(sp)
    80002618:	1800                	addi	s0,sp,48
    8000261a:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    8000261c:	fffff097          	auipc	ra,0xfffff
    80002620:	708080e7          	jalr	1800(ra) # 80001d24 <myproc>
    80002624:	89aa                	mv	s3,a0
    if (p == initproc)
    80002626:	00009797          	auipc	a5,0x9
    8000262a:	f827b783          	ld	a5,-126(a5) # 8000b5a8 <initproc>
    8000262e:	0d050493          	addi	s1,a0,208
    80002632:	15050913          	addi	s2,a0,336
    80002636:	02a79363          	bne	a5,a0,8000265c <exit+0x52>
        panic("init exiting");
    8000263a:	00006517          	auipc	a0,0x6
    8000263e:	c5650513          	addi	a0,a0,-938 # 80008290 <__func__.1+0x288>
    80002642:	ffffe097          	auipc	ra,0xffffe
    80002646:	f1e080e7          	jalr	-226(ra) # 80000560 <panic>
            fileclose(f);
    8000264a:	00002097          	auipc	ra,0x2
    8000264e:	644080e7          	jalr	1604(ra) # 80004c8e <fileclose>
            p->ofile[fd] = 0;
    80002652:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    80002656:	04a1                	addi	s1,s1,8
    80002658:	01248563          	beq	s1,s2,80002662 <exit+0x58>
        if (p->ofile[fd])
    8000265c:	6088                	ld	a0,0(s1)
    8000265e:	f575                	bnez	a0,8000264a <exit+0x40>
    80002660:	bfdd                	j	80002656 <exit+0x4c>
    begin_op();
    80002662:	00002097          	auipc	ra,0x2
    80002666:	162080e7          	jalr	354(ra) # 800047c4 <begin_op>
    iput(p->cwd);
    8000266a:	1509b503          	ld	a0,336(s3)
    8000266e:	00002097          	auipc	ra,0x2
    80002672:	946080e7          	jalr	-1722(ra) # 80003fb4 <iput>
    end_op();
    80002676:	00002097          	auipc	ra,0x2
    8000267a:	1c8080e7          	jalr	456(ra) # 8000483e <end_op>
    p->cwd = 0;
    8000267e:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    80002682:	00019497          	auipc	s1,0x19
    80002686:	5ce48493          	addi	s1,s1,1486 # 8001bc50 <wait_lock>
    8000268a:	8526                	mv	a0,s1
    8000268c:	ffffe097          	auipc	ra,0xffffe
    80002690:	794080e7          	jalr	1940(ra) # 80000e20 <acquire>
    reparent(p);
    80002694:	854e                	mv	a0,s3
    80002696:	00000097          	auipc	ra,0x0
    8000269a:	f1a080e7          	jalr	-230(ra) # 800025b0 <reparent>
    wakeup(p->parent);
    8000269e:	0389b503          	ld	a0,56(s3)
    800026a2:	00000097          	auipc	ra,0x0
    800026a6:	e98080e7          	jalr	-360(ra) # 8000253a <wakeup>
    acquire(&p->lock);
    800026aa:	854e                	mv	a0,s3
    800026ac:	ffffe097          	auipc	ra,0xffffe
    800026b0:	774080e7          	jalr	1908(ra) # 80000e20 <acquire>
    p->xstate = status;
    800026b4:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    800026b8:	4795                	li	a5,5
    800026ba:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    800026be:	8526                	mv	a0,s1
    800026c0:	fffff097          	auipc	ra,0xfffff
    800026c4:	814080e7          	jalr	-2028(ra) # 80000ed4 <release>
    sched();
    800026c8:	00000097          	auipc	ra,0x0
    800026cc:	d04080e7          	jalr	-764(ra) # 800023cc <sched>
    panic("zombie exit");
    800026d0:	00006517          	auipc	a0,0x6
    800026d4:	bd050513          	addi	a0,a0,-1072 # 800082a0 <__func__.1+0x298>
    800026d8:	ffffe097          	auipc	ra,0xffffe
    800026dc:	e88080e7          	jalr	-376(ra) # 80000560 <panic>

00000000800026e0 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800026e0:	7179                	addi	sp,sp,-48
    800026e2:	f406                	sd	ra,40(sp)
    800026e4:	f022                	sd	s0,32(sp)
    800026e6:	ec26                	sd	s1,24(sp)
    800026e8:	e84a                	sd	s2,16(sp)
    800026ea:	e44e                	sd	s3,8(sp)
    800026ec:	1800                	addi	s0,sp,48
    800026ee:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800026f0:	00019497          	auipc	s1,0x19
    800026f4:	57848493          	addi	s1,s1,1400 # 8001bc68 <proc>
    800026f8:	0001f997          	auipc	s3,0x1f
    800026fc:	f7098993          	addi	s3,s3,-144 # 80021668 <tickslock>
    {
        acquire(&p->lock);
    80002700:	8526                	mv	a0,s1
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	71e080e7          	jalr	1822(ra) # 80000e20 <acquire>
        if (p->pid == pid)
    8000270a:	589c                	lw	a5,48(s1)
    8000270c:	01278d63          	beq	a5,s2,80002726 <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    80002710:	8526                	mv	a0,s1
    80002712:	ffffe097          	auipc	ra,0xffffe
    80002716:	7c2080e7          	jalr	1986(ra) # 80000ed4 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000271a:	16848493          	addi	s1,s1,360
    8000271e:	ff3491e3          	bne	s1,s3,80002700 <kill+0x20>
    }
    return -1;
    80002722:	557d                	li	a0,-1
    80002724:	a829                	j	8000273e <kill+0x5e>
            p->killed = 1;
    80002726:	4785                	li	a5,1
    80002728:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    8000272a:	4c98                	lw	a4,24(s1)
    8000272c:	4789                	li	a5,2
    8000272e:	00f70f63          	beq	a4,a5,8000274c <kill+0x6c>
            release(&p->lock);
    80002732:	8526                	mv	a0,s1
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	7a0080e7          	jalr	1952(ra) # 80000ed4 <release>
            return 0;
    8000273c:	4501                	li	a0,0
}
    8000273e:	70a2                	ld	ra,40(sp)
    80002740:	7402                	ld	s0,32(sp)
    80002742:	64e2                	ld	s1,24(sp)
    80002744:	6942                	ld	s2,16(sp)
    80002746:	69a2                	ld	s3,8(sp)
    80002748:	6145                	addi	sp,sp,48
    8000274a:	8082                	ret
                p->state = RUNNABLE;
    8000274c:	478d                	li	a5,3
    8000274e:	cc9c                	sw	a5,24(s1)
    80002750:	b7cd                	j	80002732 <kill+0x52>

0000000080002752 <setkilled>:

void setkilled(struct proc *p)
{
    80002752:	1101                	addi	sp,sp,-32
    80002754:	ec06                	sd	ra,24(sp)
    80002756:	e822                	sd	s0,16(sp)
    80002758:	e426                	sd	s1,8(sp)
    8000275a:	1000                	addi	s0,sp,32
    8000275c:	84aa                	mv	s1,a0
    acquire(&p->lock);
    8000275e:	ffffe097          	auipc	ra,0xffffe
    80002762:	6c2080e7          	jalr	1730(ra) # 80000e20 <acquire>
    p->killed = 1;
    80002766:	4785                	li	a5,1
    80002768:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    8000276a:	8526                	mv	a0,s1
    8000276c:	ffffe097          	auipc	ra,0xffffe
    80002770:	768080e7          	jalr	1896(ra) # 80000ed4 <release>
}
    80002774:	60e2                	ld	ra,24(sp)
    80002776:	6442                	ld	s0,16(sp)
    80002778:	64a2                	ld	s1,8(sp)
    8000277a:	6105                	addi	sp,sp,32
    8000277c:	8082                	ret

000000008000277e <killed>:

int killed(struct proc *p)
{
    8000277e:	1101                	addi	sp,sp,-32
    80002780:	ec06                	sd	ra,24(sp)
    80002782:	e822                	sd	s0,16(sp)
    80002784:	e426                	sd	s1,8(sp)
    80002786:	e04a                	sd	s2,0(sp)
    80002788:	1000                	addi	s0,sp,32
    8000278a:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    8000278c:	ffffe097          	auipc	ra,0xffffe
    80002790:	694080e7          	jalr	1684(ra) # 80000e20 <acquire>
    k = p->killed;
    80002794:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    80002798:	8526                	mv	a0,s1
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	73a080e7          	jalr	1850(ra) # 80000ed4 <release>
    return k;
}
    800027a2:	854a                	mv	a0,s2
    800027a4:	60e2                	ld	ra,24(sp)
    800027a6:	6442                	ld	s0,16(sp)
    800027a8:	64a2                	ld	s1,8(sp)
    800027aa:	6902                	ld	s2,0(sp)
    800027ac:	6105                	addi	sp,sp,32
    800027ae:	8082                	ret

00000000800027b0 <wait>:
{
    800027b0:	715d                	addi	sp,sp,-80
    800027b2:	e486                	sd	ra,72(sp)
    800027b4:	e0a2                	sd	s0,64(sp)
    800027b6:	fc26                	sd	s1,56(sp)
    800027b8:	f84a                	sd	s2,48(sp)
    800027ba:	f44e                	sd	s3,40(sp)
    800027bc:	f052                	sd	s4,32(sp)
    800027be:	ec56                	sd	s5,24(sp)
    800027c0:	e85a                	sd	s6,16(sp)
    800027c2:	e45e                	sd	s7,8(sp)
    800027c4:	e062                	sd	s8,0(sp)
    800027c6:	0880                	addi	s0,sp,80
    800027c8:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    800027ca:	fffff097          	auipc	ra,0xfffff
    800027ce:	55a080e7          	jalr	1370(ra) # 80001d24 <myproc>
    800027d2:	892a                	mv	s2,a0
    acquire(&wait_lock);
    800027d4:	00019517          	auipc	a0,0x19
    800027d8:	47c50513          	addi	a0,a0,1148 # 8001bc50 <wait_lock>
    800027dc:	ffffe097          	auipc	ra,0xffffe
    800027e0:	644080e7          	jalr	1604(ra) # 80000e20 <acquire>
        havekids = 0;
    800027e4:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    800027e6:	4a15                	li	s4,5
                havekids = 1;
    800027e8:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800027ea:	0001f997          	auipc	s3,0x1f
    800027ee:	e7e98993          	addi	s3,s3,-386 # 80021668 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    800027f2:	00019c17          	auipc	s8,0x19
    800027f6:	45ec0c13          	addi	s8,s8,1118 # 8001bc50 <wait_lock>
    800027fa:	a0d1                	j	800028be <wait+0x10e>
                    pid = pp->pid;
    800027fc:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002800:	000b0e63          	beqz	s6,8000281c <wait+0x6c>
    80002804:	4691                	li	a3,4
    80002806:	02c48613          	addi	a2,s1,44
    8000280a:	85da                	mv	a1,s6
    8000280c:	05093503          	ld	a0,80(s2)
    80002810:	fffff097          	auipc	ra,0xfffff
    80002814:	0b8080e7          	jalr	184(ra) # 800018c8 <copyout>
    80002818:	04054163          	bltz	a0,8000285a <wait+0xaa>
                    freeproc(pp);
    8000281c:	8526                	mv	a0,s1
    8000281e:	fffff097          	auipc	ra,0xfffff
    80002822:	6b8080e7          	jalr	1720(ra) # 80001ed6 <freeproc>
                    release(&pp->lock);
    80002826:	8526                	mv	a0,s1
    80002828:	ffffe097          	auipc	ra,0xffffe
    8000282c:	6ac080e7          	jalr	1708(ra) # 80000ed4 <release>
                    release(&wait_lock);
    80002830:	00019517          	auipc	a0,0x19
    80002834:	42050513          	addi	a0,a0,1056 # 8001bc50 <wait_lock>
    80002838:	ffffe097          	auipc	ra,0xffffe
    8000283c:	69c080e7          	jalr	1692(ra) # 80000ed4 <release>
}
    80002840:	854e                	mv	a0,s3
    80002842:	60a6                	ld	ra,72(sp)
    80002844:	6406                	ld	s0,64(sp)
    80002846:	74e2                	ld	s1,56(sp)
    80002848:	7942                	ld	s2,48(sp)
    8000284a:	79a2                	ld	s3,40(sp)
    8000284c:	7a02                	ld	s4,32(sp)
    8000284e:	6ae2                	ld	s5,24(sp)
    80002850:	6b42                	ld	s6,16(sp)
    80002852:	6ba2                	ld	s7,8(sp)
    80002854:	6c02                	ld	s8,0(sp)
    80002856:	6161                	addi	sp,sp,80
    80002858:	8082                	ret
                        release(&pp->lock);
    8000285a:	8526                	mv	a0,s1
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	678080e7          	jalr	1656(ra) # 80000ed4 <release>
                        release(&wait_lock);
    80002864:	00019517          	auipc	a0,0x19
    80002868:	3ec50513          	addi	a0,a0,1004 # 8001bc50 <wait_lock>
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	668080e7          	jalr	1640(ra) # 80000ed4 <release>
                        return -1;
    80002874:	59fd                	li	s3,-1
    80002876:	b7e9                	j	80002840 <wait+0x90>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002878:	16848493          	addi	s1,s1,360
    8000287c:	03348463          	beq	s1,s3,800028a4 <wait+0xf4>
            if (pp->parent == p)
    80002880:	7c9c                	ld	a5,56(s1)
    80002882:	ff279be3          	bne	a5,s2,80002878 <wait+0xc8>
                acquire(&pp->lock);
    80002886:	8526                	mv	a0,s1
    80002888:	ffffe097          	auipc	ra,0xffffe
    8000288c:	598080e7          	jalr	1432(ra) # 80000e20 <acquire>
                if (pp->state == ZOMBIE)
    80002890:	4c9c                	lw	a5,24(s1)
    80002892:	f74785e3          	beq	a5,s4,800027fc <wait+0x4c>
                release(&pp->lock);
    80002896:	8526                	mv	a0,s1
    80002898:	ffffe097          	auipc	ra,0xffffe
    8000289c:	63c080e7          	jalr	1596(ra) # 80000ed4 <release>
                havekids = 1;
    800028a0:	8756                	mv	a4,s5
    800028a2:	bfd9                	j	80002878 <wait+0xc8>
        if (!havekids || killed(p))
    800028a4:	c31d                	beqz	a4,800028ca <wait+0x11a>
    800028a6:	854a                	mv	a0,s2
    800028a8:	00000097          	auipc	ra,0x0
    800028ac:	ed6080e7          	jalr	-298(ra) # 8000277e <killed>
    800028b0:	ed09                	bnez	a0,800028ca <wait+0x11a>
        sleep(p, &wait_lock); // DOC: wait-sleep
    800028b2:	85e2                	mv	a1,s8
    800028b4:	854a                	mv	a0,s2
    800028b6:	00000097          	auipc	ra,0x0
    800028ba:	c20080e7          	jalr	-992(ra) # 800024d6 <sleep>
        havekids = 0;
    800028be:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800028c0:	00019497          	auipc	s1,0x19
    800028c4:	3a848493          	addi	s1,s1,936 # 8001bc68 <proc>
    800028c8:	bf65                	j	80002880 <wait+0xd0>
            release(&wait_lock);
    800028ca:	00019517          	auipc	a0,0x19
    800028ce:	38650513          	addi	a0,a0,902 # 8001bc50 <wait_lock>
    800028d2:	ffffe097          	auipc	ra,0xffffe
    800028d6:	602080e7          	jalr	1538(ra) # 80000ed4 <release>
            return -1;
    800028da:	59fd                	li	s3,-1
    800028dc:	b795                	j	80002840 <wait+0x90>

00000000800028de <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800028de:	7179                	addi	sp,sp,-48
    800028e0:	f406                	sd	ra,40(sp)
    800028e2:	f022                	sd	s0,32(sp)
    800028e4:	ec26                	sd	s1,24(sp)
    800028e6:	e84a                	sd	s2,16(sp)
    800028e8:	e44e                	sd	s3,8(sp)
    800028ea:	e052                	sd	s4,0(sp)
    800028ec:	1800                	addi	s0,sp,48
    800028ee:	84aa                	mv	s1,a0
    800028f0:	892e                	mv	s2,a1
    800028f2:	89b2                	mv	s3,a2
    800028f4:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    800028f6:	fffff097          	auipc	ra,0xfffff
    800028fa:	42e080e7          	jalr	1070(ra) # 80001d24 <myproc>
    if (user_dst)
    800028fe:	c08d                	beqz	s1,80002920 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    80002900:	86d2                	mv	a3,s4
    80002902:	864e                	mv	a2,s3
    80002904:	85ca                	mv	a1,s2
    80002906:	6928                	ld	a0,80(a0)
    80002908:	fffff097          	auipc	ra,0xfffff
    8000290c:	fc0080e7          	jalr	-64(ra) # 800018c8 <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    80002910:	70a2                	ld	ra,40(sp)
    80002912:	7402                	ld	s0,32(sp)
    80002914:	64e2                	ld	s1,24(sp)
    80002916:	6942                	ld	s2,16(sp)
    80002918:	69a2                	ld	s3,8(sp)
    8000291a:	6a02                	ld	s4,0(sp)
    8000291c:	6145                	addi	sp,sp,48
    8000291e:	8082                	ret
        memmove((char *)dst, src, len);
    80002920:	000a061b          	sext.w	a2,s4
    80002924:	85ce                	mv	a1,s3
    80002926:	854a                	mv	a0,s2
    80002928:	ffffe097          	auipc	ra,0xffffe
    8000292c:	650080e7          	jalr	1616(ra) # 80000f78 <memmove>
        return 0;
    80002930:	8526                	mv	a0,s1
    80002932:	bff9                	j	80002910 <either_copyout+0x32>

0000000080002934 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002934:	7179                	addi	sp,sp,-48
    80002936:	f406                	sd	ra,40(sp)
    80002938:	f022                	sd	s0,32(sp)
    8000293a:	ec26                	sd	s1,24(sp)
    8000293c:	e84a                	sd	s2,16(sp)
    8000293e:	e44e                	sd	s3,8(sp)
    80002940:	e052                	sd	s4,0(sp)
    80002942:	1800                	addi	s0,sp,48
    80002944:	892a                	mv	s2,a0
    80002946:	84ae                	mv	s1,a1
    80002948:	89b2                	mv	s3,a2
    8000294a:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    8000294c:	fffff097          	auipc	ra,0xfffff
    80002950:	3d8080e7          	jalr	984(ra) # 80001d24 <myproc>
    if (user_src)
    80002954:	c08d                	beqz	s1,80002976 <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    80002956:	86d2                	mv	a3,s4
    80002958:	864e                	mv	a2,s3
    8000295a:	85ca                	mv	a1,s2
    8000295c:	6928                	ld	a0,80(a0)
    8000295e:	fffff097          	auipc	ra,0xfffff
    80002962:	ff6080e7          	jalr	-10(ra) # 80001954 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    80002966:	70a2                	ld	ra,40(sp)
    80002968:	7402                	ld	s0,32(sp)
    8000296a:	64e2                	ld	s1,24(sp)
    8000296c:	6942                	ld	s2,16(sp)
    8000296e:	69a2                	ld	s3,8(sp)
    80002970:	6a02                	ld	s4,0(sp)
    80002972:	6145                	addi	sp,sp,48
    80002974:	8082                	ret
        memmove(dst, (char *)src, len);
    80002976:	000a061b          	sext.w	a2,s4
    8000297a:	85ce                	mv	a1,s3
    8000297c:	854a                	mv	a0,s2
    8000297e:	ffffe097          	auipc	ra,0xffffe
    80002982:	5fa080e7          	jalr	1530(ra) # 80000f78 <memmove>
        return 0;
    80002986:	8526                	mv	a0,s1
    80002988:	bff9                	j	80002966 <either_copyin+0x32>

000000008000298a <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    8000298a:	715d                	addi	sp,sp,-80
    8000298c:	e486                	sd	ra,72(sp)
    8000298e:	e0a2                	sd	s0,64(sp)
    80002990:	fc26                	sd	s1,56(sp)
    80002992:	f84a                	sd	s2,48(sp)
    80002994:	f44e                	sd	s3,40(sp)
    80002996:	f052                	sd	s4,32(sp)
    80002998:	ec56                	sd	s5,24(sp)
    8000299a:	e85a                	sd	s6,16(sp)
    8000299c:	e45e                	sd	s7,8(sp)
    8000299e:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    800029a0:	00005517          	auipc	a0,0x5
    800029a4:	68050513          	addi	a0,a0,1664 # 80008020 <__func__.1+0x18>
    800029a8:	ffffe097          	auipc	ra,0xffffe
    800029ac:	c14080e7          	jalr	-1004(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800029b0:	00019497          	auipc	s1,0x19
    800029b4:	41048493          	addi	s1,s1,1040 # 8001bdc0 <proc+0x158>
    800029b8:	0001f917          	auipc	s2,0x1f
    800029bc:	e0890913          	addi	s2,s2,-504 # 800217c0 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029c0:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    800029c2:	00006997          	auipc	s3,0x6
    800029c6:	8ee98993          	addi	s3,s3,-1810 # 800082b0 <__func__.1+0x2a8>
        printf("%d <%s %s", p->pid, state, p->name);
    800029ca:	00006a97          	auipc	s5,0x6
    800029ce:	8eea8a93          	addi	s5,s5,-1810 # 800082b8 <__func__.1+0x2b0>
        printf("\n");
    800029d2:	00005a17          	auipc	s4,0x5
    800029d6:	64ea0a13          	addi	s4,s4,1614 # 80008020 <__func__.1+0x18>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029da:	00006b97          	auipc	s7,0x6
    800029de:	e9eb8b93          	addi	s7,s7,-354 # 80008878 <states.0>
    800029e2:	a00d                	j	80002a04 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    800029e4:	ed86a583          	lw	a1,-296(a3)
    800029e8:	8556                	mv	a0,s5
    800029ea:	ffffe097          	auipc	ra,0xffffe
    800029ee:	bd2080e7          	jalr	-1070(ra) # 800005bc <printf>
        printf("\n");
    800029f2:	8552                	mv	a0,s4
    800029f4:	ffffe097          	auipc	ra,0xffffe
    800029f8:	bc8080e7          	jalr	-1080(ra) # 800005bc <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800029fc:	16848493          	addi	s1,s1,360
    80002a00:	03248263          	beq	s1,s2,80002a24 <procdump+0x9a>
        if (p->state == UNUSED)
    80002a04:	86a6                	mv	a3,s1
    80002a06:	ec04a783          	lw	a5,-320(s1)
    80002a0a:	dbed                	beqz	a5,800029fc <procdump+0x72>
            state = "???";
    80002a0c:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a0e:	fcfb6be3          	bltu	s6,a5,800029e4 <procdump+0x5a>
    80002a12:	02079713          	slli	a4,a5,0x20
    80002a16:	01d75793          	srli	a5,a4,0x1d
    80002a1a:	97de                	add	a5,a5,s7
    80002a1c:	6390                	ld	a2,0(a5)
    80002a1e:	f279                	bnez	a2,800029e4 <procdump+0x5a>
            state = "???";
    80002a20:	864e                	mv	a2,s3
    80002a22:	b7c9                	j	800029e4 <procdump+0x5a>
    }
}
    80002a24:	60a6                	ld	ra,72(sp)
    80002a26:	6406                	ld	s0,64(sp)
    80002a28:	74e2                	ld	s1,56(sp)
    80002a2a:	7942                	ld	s2,48(sp)
    80002a2c:	79a2                	ld	s3,40(sp)
    80002a2e:	7a02                	ld	s4,32(sp)
    80002a30:	6ae2                	ld	s5,24(sp)
    80002a32:	6b42                	ld	s6,16(sp)
    80002a34:	6ba2                	ld	s7,8(sp)
    80002a36:	6161                	addi	sp,sp,80
    80002a38:	8082                	ret

0000000080002a3a <schedls>:

void schedls()
{
    80002a3a:	1141                	addi	sp,sp,-16
    80002a3c:	e406                	sd	ra,8(sp)
    80002a3e:	e022                	sd	s0,0(sp)
    80002a40:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002a42:	00006517          	auipc	a0,0x6
    80002a46:	88650513          	addi	a0,a0,-1914 # 800082c8 <__func__.1+0x2c0>
    80002a4a:	ffffe097          	auipc	ra,0xffffe
    80002a4e:	b72080e7          	jalr	-1166(ra) # 800005bc <printf>
    printf("====================================\n");
    80002a52:	00006517          	auipc	a0,0x6
    80002a56:	89e50513          	addi	a0,a0,-1890 # 800082f0 <__func__.1+0x2e8>
    80002a5a:	ffffe097          	auipc	ra,0xffffe
    80002a5e:	b62080e7          	jalr	-1182(ra) # 800005bc <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002a62:	00009717          	auipc	a4,0x9
    80002a66:	ad673703          	ld	a4,-1322(a4) # 8000b538 <available_schedulers+0x10>
    80002a6a:	00009797          	auipc	a5,0x9
    80002a6e:	a6e7b783          	ld	a5,-1426(a5) # 8000b4d8 <sched_pointer>
    80002a72:	04f70663          	beq	a4,a5,80002abe <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    80002a76:	00006517          	auipc	a0,0x6
    80002a7a:	8aa50513          	addi	a0,a0,-1878 # 80008320 <__func__.1+0x318>
    80002a7e:	ffffe097          	auipc	ra,0xffffe
    80002a82:	b3e080e7          	jalr	-1218(ra) # 800005bc <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002a86:	00009617          	auipc	a2,0x9
    80002a8a:	aba62603          	lw	a2,-1350(a2) # 8000b540 <available_schedulers+0x18>
    80002a8e:	00009597          	auipc	a1,0x9
    80002a92:	a9a58593          	addi	a1,a1,-1382 # 8000b528 <available_schedulers>
    80002a96:	00006517          	auipc	a0,0x6
    80002a9a:	89250513          	addi	a0,a0,-1902 # 80008328 <__func__.1+0x320>
    80002a9e:	ffffe097          	auipc	ra,0xffffe
    80002aa2:	b1e080e7          	jalr	-1250(ra) # 800005bc <printf>
    }
    printf("\n*: current scheduler\n\n");
    80002aa6:	00006517          	auipc	a0,0x6
    80002aaa:	88a50513          	addi	a0,a0,-1910 # 80008330 <__func__.1+0x328>
    80002aae:	ffffe097          	auipc	ra,0xffffe
    80002ab2:	b0e080e7          	jalr	-1266(ra) # 800005bc <printf>
}
    80002ab6:	60a2                	ld	ra,8(sp)
    80002ab8:	6402                	ld	s0,0(sp)
    80002aba:	0141                	addi	sp,sp,16
    80002abc:	8082                	ret
            printf("[*]\t");
    80002abe:	00006517          	auipc	a0,0x6
    80002ac2:	85a50513          	addi	a0,a0,-1958 # 80008318 <__func__.1+0x310>
    80002ac6:	ffffe097          	auipc	ra,0xffffe
    80002aca:	af6080e7          	jalr	-1290(ra) # 800005bc <printf>
    80002ace:	bf65                	j	80002a86 <schedls+0x4c>

0000000080002ad0 <schedset>:

void schedset(int id)
{
    80002ad0:	1141                	addi	sp,sp,-16
    80002ad2:	e406                	sd	ra,8(sp)
    80002ad4:	e022                	sd	s0,0(sp)
    80002ad6:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002ad8:	e90d                	bnez	a0,80002b0a <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002ada:	00009797          	auipc	a5,0x9
    80002ade:	a5e7b783          	ld	a5,-1442(a5) # 8000b538 <available_schedulers+0x10>
    80002ae2:	00009717          	auipc	a4,0x9
    80002ae6:	9ef73b23          	sd	a5,-1546(a4) # 8000b4d8 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002aea:	00009597          	auipc	a1,0x9
    80002aee:	a3e58593          	addi	a1,a1,-1474 # 8000b528 <available_schedulers>
    80002af2:	00006517          	auipc	a0,0x6
    80002af6:	87e50513          	addi	a0,a0,-1922 # 80008370 <__func__.1+0x368>
    80002afa:	ffffe097          	auipc	ra,0xffffe
    80002afe:	ac2080e7          	jalr	-1342(ra) # 800005bc <printf>
    80002b02:	60a2                	ld	ra,8(sp)
    80002b04:	6402                	ld	s0,0(sp)
    80002b06:	0141                	addi	sp,sp,16
    80002b08:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002b0a:	00006517          	auipc	a0,0x6
    80002b0e:	83e50513          	addi	a0,a0,-1986 # 80008348 <__func__.1+0x340>
    80002b12:	ffffe097          	auipc	ra,0xffffe
    80002b16:	aaa080e7          	jalr	-1366(ra) # 800005bc <printf>
        return;
    80002b1a:	b7e5                	j	80002b02 <schedset+0x32>

0000000080002b1c <swtch>:
    80002b1c:	00153023          	sd	ra,0(a0)
    80002b20:	00253423          	sd	sp,8(a0)
    80002b24:	e900                	sd	s0,16(a0)
    80002b26:	ed04                	sd	s1,24(a0)
    80002b28:	03253023          	sd	s2,32(a0)
    80002b2c:	03353423          	sd	s3,40(a0)
    80002b30:	03453823          	sd	s4,48(a0)
    80002b34:	03553c23          	sd	s5,56(a0)
    80002b38:	05653023          	sd	s6,64(a0)
    80002b3c:	05753423          	sd	s7,72(a0)
    80002b40:	05853823          	sd	s8,80(a0)
    80002b44:	05953c23          	sd	s9,88(a0)
    80002b48:	07a53023          	sd	s10,96(a0)
    80002b4c:	07b53423          	sd	s11,104(a0)
    80002b50:	0005b083          	ld	ra,0(a1)
    80002b54:	0085b103          	ld	sp,8(a1)
    80002b58:	6980                	ld	s0,16(a1)
    80002b5a:	6d84                	ld	s1,24(a1)
    80002b5c:	0205b903          	ld	s2,32(a1)
    80002b60:	0285b983          	ld	s3,40(a1)
    80002b64:	0305ba03          	ld	s4,48(a1)
    80002b68:	0385ba83          	ld	s5,56(a1)
    80002b6c:	0405bb03          	ld	s6,64(a1)
    80002b70:	0485bb83          	ld	s7,72(a1)
    80002b74:	0505bc03          	ld	s8,80(a1)
    80002b78:	0585bc83          	ld	s9,88(a1)
    80002b7c:	0605bd03          	ld	s10,96(a1)
    80002b80:	0685bd83          	ld	s11,104(a1)
    80002b84:	8082                	ret

0000000080002b86 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002b86:	1141                	addi	sp,sp,-16
    80002b88:	e406                	sd	ra,8(sp)
    80002b8a:	e022                	sd	s0,0(sp)
    80002b8c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b8e:	00006597          	auipc	a1,0x6
    80002b92:	83a58593          	addi	a1,a1,-1990 # 800083c8 <__func__.1+0x3c0>
    80002b96:	0001f517          	auipc	a0,0x1f
    80002b9a:	ad250513          	addi	a0,a0,-1326 # 80021668 <tickslock>
    80002b9e:	ffffe097          	auipc	ra,0xffffe
    80002ba2:	1f2080e7          	jalr	498(ra) # 80000d90 <initlock>
}
    80002ba6:	60a2                	ld	ra,8(sp)
    80002ba8:	6402                	ld	s0,0(sp)
    80002baa:	0141                	addi	sp,sp,16
    80002bac:	8082                	ret

0000000080002bae <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002bae:	1141                	addi	sp,sp,-16
    80002bb0:	e422                	sd	s0,8(sp)
    80002bb2:	0800                	addi	s0,sp,16
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002bb4:	00003797          	auipc	a5,0x3
    80002bb8:	7dc78793          	addi	a5,a5,2012 # 80006390 <kernelvec>
    80002bbc:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002bc0:	6422                	ld	s0,8(sp)
    80002bc2:	0141                	addi	sp,sp,16
    80002bc4:	8082                	ret

0000000080002bc6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002bc6:	1141                	addi	sp,sp,-16
    80002bc8:	e406                	sd	ra,8(sp)
    80002bca:	e022                	sd	s0,0(sp)
    80002bcc:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002bce:	fffff097          	auipc	ra,0xfffff
    80002bd2:	156080e7          	jalr	342(ra) # 80001d24 <myproc>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002bd6:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002bda:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002bdc:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002be0:	00004697          	auipc	a3,0x4
    80002be4:	42068693          	addi	a3,a3,1056 # 80007000 <_trampoline>
    80002be8:	00004717          	auipc	a4,0x4
    80002bec:	41870713          	addi	a4,a4,1048 # 80007000 <_trampoline>
    80002bf0:	8f15                	sub	a4,a4,a3
    80002bf2:	040007b7          	lui	a5,0x4000
    80002bf6:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002bf8:	07b2                	slli	a5,a5,0xc
    80002bfa:	973e                	add	a4,a4,a5
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002bfc:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002c00:	6d38                	ld	a4,88(a0)
    asm volatile("csrr %0, satp" : "=r"(x));
    80002c02:	18002673          	csrr	a2,satp
    80002c06:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002c08:	6d30                	ld	a2,88(a0)
    80002c0a:	6138                	ld	a4,64(a0)
    80002c0c:	6585                	lui	a1,0x1
    80002c0e:	972e                	add	a4,a4,a1
    80002c10:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002c12:	6d38                	ld	a4,88(a0)
    80002c14:	00000617          	auipc	a2,0x0
    80002c18:	13860613          	addi	a2,a2,312 # 80002d4c <usertrap>
    80002c1c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002c1e:	6d38                	ld	a4,88(a0)
    asm volatile("mv %0, tp" : "=r"(x));
    80002c20:	8612                	mv	a2,tp
    80002c22:	f310                	sd	a2,32(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002c24:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002c28:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002c2c:	02076713          	ori	a4,a4,32
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002c30:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002c34:	6d38                	ld	a4,88(a0)
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002c36:	6f18                	ld	a4,24(a4)
    80002c38:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002c3c:	6928                	ld	a0,80(a0)
    80002c3e:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002c40:	00004717          	auipc	a4,0x4
    80002c44:	45c70713          	addi	a4,a4,1116 # 8000709c <userret>
    80002c48:	8f15                	sub	a4,a4,a3
    80002c4a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002c4c:	577d                	li	a4,-1
    80002c4e:	177e                	slli	a4,a4,0x3f
    80002c50:	8d59                	or	a0,a0,a4
    80002c52:	9782                	jalr	a5
}
    80002c54:	60a2                	ld	ra,8(sp)
    80002c56:	6402                	ld	s0,0(sp)
    80002c58:	0141                	addi	sp,sp,16
    80002c5a:	8082                	ret

0000000080002c5c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002c5c:	1101                	addi	sp,sp,-32
    80002c5e:	ec06                	sd	ra,24(sp)
    80002c60:	e822                	sd	s0,16(sp)
    80002c62:	e426                	sd	s1,8(sp)
    80002c64:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002c66:	0001f497          	auipc	s1,0x1f
    80002c6a:	a0248493          	addi	s1,s1,-1534 # 80021668 <tickslock>
    80002c6e:	8526                	mv	a0,s1
    80002c70:	ffffe097          	auipc	ra,0xffffe
    80002c74:	1b0080e7          	jalr	432(ra) # 80000e20 <acquire>
  ticks++;
    80002c78:	00009517          	auipc	a0,0x9
    80002c7c:	93850513          	addi	a0,a0,-1736 # 8000b5b0 <ticks>
    80002c80:	411c                	lw	a5,0(a0)
    80002c82:	2785                	addiw	a5,a5,1
    80002c84:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002c86:	00000097          	auipc	ra,0x0
    80002c8a:	8b4080e7          	jalr	-1868(ra) # 8000253a <wakeup>
  release(&tickslock);
    80002c8e:	8526                	mv	a0,s1
    80002c90:	ffffe097          	auipc	ra,0xffffe
    80002c94:	244080e7          	jalr	580(ra) # 80000ed4 <release>
}
    80002c98:	60e2                	ld	ra,24(sp)
    80002c9a:	6442                	ld	s0,16(sp)
    80002c9c:	64a2                	ld	s1,8(sp)
    80002c9e:	6105                	addi	sp,sp,32
    80002ca0:	8082                	ret

0000000080002ca2 <devintr>:
    asm volatile("csrr %0, scause" : "=r"(x));
    80002ca2:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ca6:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002ca8:	0a07d163          	bgez	a5,80002d4a <devintr+0xa8>
{
    80002cac:	1101                	addi	sp,sp,-32
    80002cae:	ec06                	sd	ra,24(sp)
    80002cb0:	e822                	sd	s0,16(sp)
    80002cb2:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002cb4:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002cb8:	46a5                	li	a3,9
    80002cba:	00d70c63          	beq	a4,a3,80002cd2 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    80002cbe:	577d                	li	a4,-1
    80002cc0:	177e                	slli	a4,a4,0x3f
    80002cc2:	0705                	addi	a4,a4,1
    return 0;
    80002cc4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002cc6:	06e78163          	beq	a5,a4,80002d28 <devintr+0x86>
  }
}
    80002cca:	60e2                	ld	ra,24(sp)
    80002ccc:	6442                	ld	s0,16(sp)
    80002cce:	6105                	addi	sp,sp,32
    80002cd0:	8082                	ret
    80002cd2:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002cd4:	00003097          	auipc	ra,0x3
    80002cd8:	7c8080e7          	jalr	1992(ra) # 8000649c <plic_claim>
    80002cdc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002cde:	47a9                	li	a5,10
    80002ce0:	00f50963          	beq	a0,a5,80002cf2 <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    80002ce4:	4785                	li	a5,1
    80002ce6:	00f50b63          	beq	a0,a5,80002cfc <devintr+0x5a>
    return 1;
    80002cea:	4505                	li	a0,1
    } else if(irq){
    80002cec:	ec89                	bnez	s1,80002d06 <devintr+0x64>
    80002cee:	64a2                	ld	s1,8(sp)
    80002cf0:	bfe9                	j	80002cca <devintr+0x28>
      uartintr();
    80002cf2:	ffffe097          	auipc	ra,0xffffe
    80002cf6:	d1a080e7          	jalr	-742(ra) # 80000a0c <uartintr>
    if(irq)
    80002cfa:	a839                	j	80002d18 <devintr+0x76>
      virtio_disk_intr();
    80002cfc:	00004097          	auipc	ra,0x4
    80002d00:	cca080e7          	jalr	-822(ra) # 800069c6 <virtio_disk_intr>
    if(irq)
    80002d04:	a811                	j	80002d18 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002d06:	85a6                	mv	a1,s1
    80002d08:	00005517          	auipc	a0,0x5
    80002d0c:	6c850513          	addi	a0,a0,1736 # 800083d0 <__func__.1+0x3c8>
    80002d10:	ffffe097          	auipc	ra,0xffffe
    80002d14:	8ac080e7          	jalr	-1876(ra) # 800005bc <printf>
      plic_complete(irq);
    80002d18:	8526                	mv	a0,s1
    80002d1a:	00003097          	auipc	ra,0x3
    80002d1e:	7a6080e7          	jalr	1958(ra) # 800064c0 <plic_complete>
    return 1;
    80002d22:	4505                	li	a0,1
    80002d24:	64a2                	ld	s1,8(sp)
    80002d26:	b755                	j	80002cca <devintr+0x28>
    if(cpuid() == 0){
    80002d28:	fffff097          	auipc	ra,0xfffff
    80002d2c:	fd0080e7          	jalr	-48(ra) # 80001cf8 <cpuid>
    80002d30:	c901                	beqz	a0,80002d40 <devintr+0x9e>
    asm volatile("csrr %0, sip" : "=r"(x));
    80002d32:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002d36:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sip, %0" : : "r"(x));
    80002d38:	14479073          	csrw	sip,a5
    return 2;
    80002d3c:	4509                	li	a0,2
    80002d3e:	b771                	j	80002cca <devintr+0x28>
      clockintr();
    80002d40:	00000097          	auipc	ra,0x0
    80002d44:	f1c080e7          	jalr	-228(ra) # 80002c5c <clockintr>
    80002d48:	b7ed                	j	80002d32 <devintr+0x90>
}
    80002d4a:	8082                	ret

0000000080002d4c <usertrap>:
{
    80002d4c:	7179                	addi	sp,sp,-48
    80002d4e:	f406                	sd	ra,40(sp)
    80002d50:	f022                	sd	s0,32(sp)
    80002d52:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002d54:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002d58:	1007f793          	andi	a5,a5,256
    80002d5c:	e7bd                	bnez	a5,80002dca <usertrap+0x7e>
    80002d5e:	ec26                	sd	s1,24(sp)
    80002d60:	e84a                	sd	s2,16(sp)
    asm volatile("csrw stvec, %0" : : "r"(x));
    80002d62:	00003797          	auipc	a5,0x3
    80002d66:	62e78793          	addi	a5,a5,1582 # 80006390 <kernelvec>
    80002d6a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d6e:	fffff097          	auipc	ra,0xfffff
    80002d72:	fb6080e7          	jalr	-74(ra) # 80001d24 <myproc>
    80002d76:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d78:	6d3c                	ld	a5,88(a0)
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002d7a:	14102773          	csrr	a4,sepc
    80002d7e:	ef98                	sd	a4,24(a5)
    asm volatile("csrr %0, scause" : "=r"(x));
    80002d80:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002d84:	47a1                	li	a5,8
    80002d86:	04f70e63          	beq	a4,a5,80002de2 <usertrap+0x96>
    80002d8a:	14202773          	csrr	a4,scause
  } else if(r_scause() == 15){
    80002d8e:	47bd                	li	a5,15
    80002d90:	12f71b63          	bne	a4,a5,80002ec6 <usertrap+0x17a>
    asm volatile("csrr %0, stval" : "=r"(x));
    80002d94:	143025f3          	csrr	a1,stval
    if(va >= MAXVA){
    80002d98:	57fd                	li	a5,-1
    80002d9a:	83e9                	srli	a5,a5,0x1a
    80002d9c:	06b7fd63          	bgeu	a5,a1,80002e16 <usertrap+0xca>
      setkilled(p);
    80002da0:	00000097          	auipc	ra,0x0
    80002da4:	9b2080e7          	jalr	-1614(ra) # 80002752 <setkilled>
  if(killed(p))
    80002da8:	8526                	mv	a0,s1
    80002daa:	00000097          	auipc	ra,0x0
    80002dae:	9d4080e7          	jalr	-1580(ra) # 8000277e <killed>
    80002db2:	16051463          	bnez	a0,80002f1a <usertrap+0x1ce>
  usertrapret();
    80002db6:	00000097          	auipc	ra,0x0
    80002dba:	e10080e7          	jalr	-496(ra) # 80002bc6 <usertrapret>
    80002dbe:	64e2                	ld	s1,24(sp)
    80002dc0:	6942                	ld	s2,16(sp)
}
    80002dc2:	70a2                	ld	ra,40(sp)
    80002dc4:	7402                	ld	s0,32(sp)
    80002dc6:	6145                	addi	sp,sp,48
    80002dc8:	8082                	ret
    80002dca:	ec26                	sd	s1,24(sp)
    80002dcc:	e84a                	sd	s2,16(sp)
    80002dce:	e44e                	sd	s3,8(sp)
    80002dd0:	e052                	sd	s4,0(sp)
    panic("usertrap: not from user mode");
    80002dd2:	00005517          	auipc	a0,0x5
    80002dd6:	61e50513          	addi	a0,a0,1566 # 800083f0 <__func__.1+0x3e8>
    80002dda:	ffffd097          	auipc	ra,0xffffd
    80002dde:	786080e7          	jalr	1926(ra) # 80000560 <panic>
    if(killed(p))
    80002de2:	00000097          	auipc	ra,0x0
    80002de6:	99c080e7          	jalr	-1636(ra) # 8000277e <killed>
    80002dea:	e105                	bnez	a0,80002e0a <usertrap+0xbe>
    p->trapframe->epc += 4;
    80002dec:	6cb8                	ld	a4,88(s1)
    80002dee:	6f1c                	ld	a5,24(a4)
    80002df0:	0791                	addi	a5,a5,4
    80002df2:	ef1c                	sd	a5,24(a4)
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002df4:	100027f3          	csrr	a5,sstatus
    w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002df8:	0027e793          	ori	a5,a5,2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002dfc:	10079073          	csrw	sstatus,a5
    syscall();
    80002e00:	00000097          	auipc	ra,0x0
    80002e04:	380080e7          	jalr	896(ra) # 80003180 <syscall>
    80002e08:	b745                	j	80002da8 <usertrap+0x5c>
      exit(-1);
    80002e0a:	557d                	li	a0,-1
    80002e0c:	fffff097          	auipc	ra,0xfffff
    80002e10:	7fe080e7          	jalr	2046(ra) # 8000260a <exit>
    80002e14:	bfe1                	j	80002dec <usertrap+0xa0>
      pte_t *pte = walk(p->pagetable, va, 0);
    80002e16:	4601                	li	a2,0
    80002e18:	6928                	ld	a0,80(a0)
    80002e1a:	ffffe097          	auipc	ra,0xffffe
    80002e1e:	3de080e7          	jalr	990(ra) # 800011f8 <walk>
    80002e22:	892a                	mv	s2,a0
      if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0){
    80002e24:	c911                	beqz	a0,80002e38 <usertrap+0xec>
    80002e26:	e44e                	sd	s3,8(sp)
    80002e28:	00053983          	ld	s3,0(a0)
    80002e2c:	0119f713          	andi	a4,s3,17
    80002e30:	47c5                	li	a5,17
    80002e32:	00f70963          	beq	a4,a5,80002e44 <usertrap+0xf8>
    80002e36:	69a2                	ld	s3,8(sp)
        setkilled(p);
    80002e38:	8526                	mv	a0,s1
    80002e3a:	00000097          	auipc	ra,0x0
    80002e3e:	918080e7          	jalr	-1768(ra) # 80002752 <setkilled>
    80002e42:	b79d                	j	80002da8 <usertrap+0x5c>
      } else if(*pte & PTE_COW){
    80002e44:	1009f793          	andi	a5,s3,256
    80002e48:	c3a5                	beqz	a5,80002ea8 <usertrap+0x15c>
    80002e4a:	e052                	sd	s4,0(sp)
        char *mem = kalloc();
    80002e4c:	ffffe097          	auipc	ra,0xffffe
    80002e50:	e56080e7          	jalr	-426(ra) # 80000ca2 <kalloc>
    80002e54:	8a2a                	mv	s4,a0
        if(mem == 0){
    80002e56:	c129                	beqz	a0,80002e98 <usertrap+0x14c>
        uint64 pa = PTE2PA(*pte);
    80002e58:	00a9d993          	srli	s3,s3,0xa
    80002e5c:	09b2                	slli	s3,s3,0xc
          memmove(mem, (char*)pa, PGSIZE);
    80002e5e:	6605                	lui	a2,0x1
    80002e60:	85ce                	mv	a1,s3
    80002e62:	ffffe097          	auipc	ra,0xffffe
    80002e66:	116080e7          	jalr	278(ra) # 80000f78 <memmove>
          uint flags = (PTE_FLAGS(*pte) & ~PTE_COW) | PTE_W;
    80002e6a:	00093783          	ld	a5,0(s2)
    80002e6e:	2fb7f793          	andi	a5,a5,763
          *pte = PA2PTE((uint64)mem) | flags;
    80002e72:	0047e793          	ori	a5,a5,4
    80002e76:	00ca5a13          	srli	s4,s4,0xc
    80002e7a:	0a2a                	slli	s4,s4,0xa
    80002e7c:	0147e7b3          	or	a5,a5,s4
    80002e80:	00f93023          	sd	a5,0(s2)
    asm volatile("sfence.vma zero, zero");
    80002e84:	12000073          	sfence.vma
          kref_dec((void*)pa);
    80002e88:	854e                	mv	a0,s3
    80002e8a:	ffffe097          	auipc	ra,0xffffe
    80002e8e:	d00080e7          	jalr	-768(ra) # 80000b8a <kref_dec>
    80002e92:	69a2                	ld	s3,8(sp)
    80002e94:	6a02                	ld	s4,0(sp)
    80002e96:	bf09                	j	80002da8 <usertrap+0x5c>
          setkilled(p);
    80002e98:	8526                	mv	a0,s1
    80002e9a:	00000097          	auipc	ra,0x0
    80002e9e:	8b8080e7          	jalr	-1864(ra) # 80002752 <setkilled>
    80002ea2:	69a2                	ld	s3,8(sp)
    80002ea4:	6a02                	ld	s4,0(sp)
    80002ea6:	b709                	j	80002da8 <usertrap+0x5c>
        printf("SEGFAULT\n");
    80002ea8:	00005517          	auipc	a0,0x5
    80002eac:	56850513          	addi	a0,a0,1384 # 80008410 <__func__.1+0x408>
    80002eb0:	ffffd097          	auipc	ra,0xffffd
    80002eb4:	70c080e7          	jalr	1804(ra) # 800005bc <printf>
        setkilled(p);
    80002eb8:	8526                	mv	a0,s1
    80002eba:	00000097          	auipc	ra,0x0
    80002ebe:	898080e7          	jalr	-1896(ra) # 80002752 <setkilled>
    80002ec2:	69a2                	ld	s3,8(sp)
    80002ec4:	b5d5                	j	80002da8 <usertrap+0x5c>
  } else if((which_dev = devintr()) != 0){
    80002ec6:	00000097          	auipc	ra,0x0
    80002eca:	ddc080e7          	jalr	-548(ra) # 80002ca2 <devintr>
    80002ece:	892a                	mv	s2,a0
    80002ed0:	c901                	beqz	a0,80002ee0 <usertrap+0x194>
  if(killed(p))
    80002ed2:	8526                	mv	a0,s1
    80002ed4:	00000097          	auipc	ra,0x0
    80002ed8:	8aa080e7          	jalr	-1878(ra) # 8000277e <killed>
    80002edc:	c529                	beqz	a0,80002f26 <usertrap+0x1da>
    80002ede:	a83d                	j	80002f1c <usertrap+0x1d0>
    asm volatile("csrr %0, scause" : "=r"(x));
    80002ee0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ee4:	5890                	lw	a2,48(s1)
    80002ee6:	00005517          	auipc	a0,0x5
    80002eea:	53a50513          	addi	a0,a0,1338 # 80008420 <__func__.1+0x418>
    80002eee:	ffffd097          	auipc	ra,0xffffd
    80002ef2:	6ce080e7          	jalr	1742(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002ef6:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80002efa:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002efe:	00005517          	auipc	a0,0x5
    80002f02:	55250513          	addi	a0,a0,1362 # 80008450 <__func__.1+0x448>
    80002f06:	ffffd097          	auipc	ra,0xffffd
    80002f0a:	6b6080e7          	jalr	1718(ra) # 800005bc <printf>
    setkilled(p);
    80002f0e:	8526                	mv	a0,s1
    80002f10:	00000097          	auipc	ra,0x0
    80002f14:	842080e7          	jalr	-1982(ra) # 80002752 <setkilled>
    80002f18:	bd41                	j	80002da8 <usertrap+0x5c>
  if(killed(p))
    80002f1a:	4901                	li	s2,0
    exit(-1);
    80002f1c:	557d                	li	a0,-1
    80002f1e:	fffff097          	auipc	ra,0xfffff
    80002f22:	6ec080e7          	jalr	1772(ra) # 8000260a <exit>
  if(which_dev == 2)
    80002f26:	4789                	li	a5,2
    80002f28:	e8f917e3          	bne	s2,a5,80002db6 <usertrap+0x6a>
    yield();
    80002f2c:	fffff097          	auipc	ra,0xfffff
    80002f30:	56e080e7          	jalr	1390(ra) # 8000249a <yield>
    80002f34:	b549                	j	80002db6 <usertrap+0x6a>

0000000080002f36 <kerneltrap>:
{
    80002f36:	7179                	addi	sp,sp,-48
    80002f38:	f406                	sd	ra,40(sp)
    80002f3a:	f022                	sd	s0,32(sp)
    80002f3c:	ec26                	sd	s1,24(sp)
    80002f3e:	e84a                	sd	s2,16(sp)
    80002f40:	e44e                	sd	s3,8(sp)
    80002f42:	1800                	addi	s0,sp,48
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002f44:	14102973          	csrr	s2,sepc
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002f48:	100024f3          	csrr	s1,sstatus
    asm volatile("csrr %0, scause" : "=r"(x));
    80002f4c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002f50:	1004f793          	andi	a5,s1,256
    80002f54:	cb85                	beqz	a5,80002f84 <kerneltrap+0x4e>
    asm volatile("csrr %0, sstatus" : "=r"(x));
    80002f56:	100027f3          	csrr	a5,sstatus
    return (x & SSTATUS_SIE) != 0;
    80002f5a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002f5c:	ef85                	bnez	a5,80002f94 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002f5e:	00000097          	auipc	ra,0x0
    80002f62:	d44080e7          	jalr	-700(ra) # 80002ca2 <devintr>
    80002f66:	cd1d                	beqz	a0,80002fa4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f68:	4789                	li	a5,2
    80002f6a:	06f50a63          	beq	a0,a5,80002fde <kerneltrap+0xa8>
    asm volatile("csrw sepc, %0" : : "r"(x));
    80002f6e:	14191073          	csrw	sepc,s2
    asm volatile("csrw sstatus, %0" : : "r"(x));
    80002f72:	10049073          	csrw	sstatus,s1
}
    80002f76:	70a2                	ld	ra,40(sp)
    80002f78:	7402                	ld	s0,32(sp)
    80002f7a:	64e2                	ld	s1,24(sp)
    80002f7c:	6942                	ld	s2,16(sp)
    80002f7e:	69a2                	ld	s3,8(sp)
    80002f80:	6145                	addi	sp,sp,48
    80002f82:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002f84:	00005517          	auipc	a0,0x5
    80002f88:	4ec50513          	addi	a0,a0,1260 # 80008470 <__func__.1+0x468>
    80002f8c:	ffffd097          	auipc	ra,0xffffd
    80002f90:	5d4080e7          	jalr	1492(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80002f94:	00005517          	auipc	a0,0x5
    80002f98:	50450513          	addi	a0,a0,1284 # 80008498 <__func__.1+0x490>
    80002f9c:	ffffd097          	auipc	ra,0xffffd
    80002fa0:	5c4080e7          	jalr	1476(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002fa4:	85ce                	mv	a1,s3
    80002fa6:	00005517          	auipc	a0,0x5
    80002faa:	51250513          	addi	a0,a0,1298 # 800084b8 <__func__.1+0x4b0>
    80002fae:	ffffd097          	auipc	ra,0xffffd
    80002fb2:	60e080e7          	jalr	1550(ra) # 800005bc <printf>
    asm volatile("csrr %0, sepc" : "=r"(x));
    80002fb6:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0, stval" : "=r"(x));
    80002fba:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002fbe:	00005517          	auipc	a0,0x5
    80002fc2:	50a50513          	addi	a0,a0,1290 # 800084c8 <__func__.1+0x4c0>
    80002fc6:	ffffd097          	auipc	ra,0xffffd
    80002fca:	5f6080e7          	jalr	1526(ra) # 800005bc <printf>
    panic("kerneltrap");
    80002fce:	00005517          	auipc	a0,0x5
    80002fd2:	51250513          	addi	a0,a0,1298 # 800084e0 <__func__.1+0x4d8>
    80002fd6:	ffffd097          	auipc	ra,0xffffd
    80002fda:	58a080e7          	jalr	1418(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002fde:	fffff097          	auipc	ra,0xfffff
    80002fe2:	d46080e7          	jalr	-698(ra) # 80001d24 <myproc>
    80002fe6:	d541                	beqz	a0,80002f6e <kerneltrap+0x38>
    80002fe8:	fffff097          	auipc	ra,0xfffff
    80002fec:	d3c080e7          	jalr	-708(ra) # 80001d24 <myproc>
    80002ff0:	4d18                	lw	a4,24(a0)
    80002ff2:	4791                	li	a5,4
    80002ff4:	f6f71de3          	bne	a4,a5,80002f6e <kerneltrap+0x38>
    yield();
    80002ff8:	fffff097          	auipc	ra,0xfffff
    80002ffc:	4a2080e7          	jalr	1186(ra) # 8000249a <yield>
    80003000:	b7bd                	j	80002f6e <kerneltrap+0x38>

0000000080003002 <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80003002:	1101                	addi	sp,sp,-32
    80003004:	ec06                	sd	ra,24(sp)
    80003006:	e822                	sd	s0,16(sp)
    80003008:	e426                	sd	s1,8(sp)
    8000300a:	1000                	addi	s0,sp,32
    8000300c:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    8000300e:	fffff097          	auipc	ra,0xfffff
    80003012:	d16080e7          	jalr	-746(ra) # 80001d24 <myproc>
    switch (n)
    80003016:	4795                	li	a5,5
    80003018:	0497e163          	bltu	a5,s1,8000305a <argraw+0x58>
    8000301c:	048a                	slli	s1,s1,0x2
    8000301e:	00006717          	auipc	a4,0x6
    80003022:	88a70713          	addi	a4,a4,-1910 # 800088a8 <states.0+0x30>
    80003026:	94ba                	add	s1,s1,a4
    80003028:	409c                	lw	a5,0(s1)
    8000302a:	97ba                	add	a5,a5,a4
    8000302c:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    8000302e:	6d3c                	ld	a5,88(a0)
    80003030:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80003032:	60e2                	ld	ra,24(sp)
    80003034:	6442                	ld	s0,16(sp)
    80003036:	64a2                	ld	s1,8(sp)
    80003038:	6105                	addi	sp,sp,32
    8000303a:	8082                	ret
        return p->trapframe->a1;
    8000303c:	6d3c                	ld	a5,88(a0)
    8000303e:	7fa8                	ld	a0,120(a5)
    80003040:	bfcd                	j	80003032 <argraw+0x30>
        return p->trapframe->a2;
    80003042:	6d3c                	ld	a5,88(a0)
    80003044:	63c8                	ld	a0,128(a5)
    80003046:	b7f5                	j	80003032 <argraw+0x30>
        return p->trapframe->a3;
    80003048:	6d3c                	ld	a5,88(a0)
    8000304a:	67c8                	ld	a0,136(a5)
    8000304c:	b7dd                	j	80003032 <argraw+0x30>
        return p->trapframe->a4;
    8000304e:	6d3c                	ld	a5,88(a0)
    80003050:	6bc8                	ld	a0,144(a5)
    80003052:	b7c5                	j	80003032 <argraw+0x30>
        return p->trapframe->a5;
    80003054:	6d3c                	ld	a5,88(a0)
    80003056:	6fc8                	ld	a0,152(a5)
    80003058:	bfe9                	j	80003032 <argraw+0x30>
    panic("argraw");
    8000305a:	00005517          	auipc	a0,0x5
    8000305e:	49650513          	addi	a0,a0,1174 # 800084f0 <__func__.1+0x4e8>
    80003062:	ffffd097          	auipc	ra,0xffffd
    80003066:	4fe080e7          	jalr	1278(ra) # 80000560 <panic>

000000008000306a <fetchaddr>:
{
    8000306a:	1101                	addi	sp,sp,-32
    8000306c:	ec06                	sd	ra,24(sp)
    8000306e:	e822                	sd	s0,16(sp)
    80003070:	e426                	sd	s1,8(sp)
    80003072:	e04a                	sd	s2,0(sp)
    80003074:	1000                	addi	s0,sp,32
    80003076:	84aa                	mv	s1,a0
    80003078:	892e                	mv	s2,a1
    struct proc *p = myproc();
    8000307a:	fffff097          	auipc	ra,0xfffff
    8000307e:	caa080e7          	jalr	-854(ra) # 80001d24 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003082:	653c                	ld	a5,72(a0)
    80003084:	02f4f863          	bgeu	s1,a5,800030b4 <fetchaddr+0x4a>
    80003088:	00848713          	addi	a4,s1,8
    8000308c:	02e7e663          	bltu	a5,a4,800030b8 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003090:	46a1                	li	a3,8
    80003092:	8626                	mv	a2,s1
    80003094:	85ca                	mv	a1,s2
    80003096:	6928                	ld	a0,80(a0)
    80003098:	fffff097          	auipc	ra,0xfffff
    8000309c:	8bc080e7          	jalr	-1860(ra) # 80001954 <copyin>
    800030a0:	00a03533          	snez	a0,a0
    800030a4:	40a00533          	neg	a0,a0
}
    800030a8:	60e2                	ld	ra,24(sp)
    800030aa:	6442                	ld	s0,16(sp)
    800030ac:	64a2                	ld	s1,8(sp)
    800030ae:	6902                	ld	s2,0(sp)
    800030b0:	6105                	addi	sp,sp,32
    800030b2:	8082                	ret
        return -1;
    800030b4:	557d                	li	a0,-1
    800030b6:	bfcd                	j	800030a8 <fetchaddr+0x3e>
    800030b8:	557d                	li	a0,-1
    800030ba:	b7fd                	j	800030a8 <fetchaddr+0x3e>

00000000800030bc <fetchstr>:
{
    800030bc:	7179                	addi	sp,sp,-48
    800030be:	f406                	sd	ra,40(sp)
    800030c0:	f022                	sd	s0,32(sp)
    800030c2:	ec26                	sd	s1,24(sp)
    800030c4:	e84a                	sd	s2,16(sp)
    800030c6:	e44e                	sd	s3,8(sp)
    800030c8:	1800                	addi	s0,sp,48
    800030ca:	892a                	mv	s2,a0
    800030cc:	84ae                	mv	s1,a1
    800030ce:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    800030d0:	fffff097          	auipc	ra,0xfffff
    800030d4:	c54080e7          	jalr	-940(ra) # 80001d24 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    800030d8:	86ce                	mv	a3,s3
    800030da:	864a                	mv	a2,s2
    800030dc:	85a6                	mv	a1,s1
    800030de:	6928                	ld	a0,80(a0)
    800030e0:	fffff097          	auipc	ra,0xfffff
    800030e4:	902080e7          	jalr	-1790(ra) # 800019e2 <copyinstr>
    800030e8:	00054e63          	bltz	a0,80003104 <fetchstr+0x48>
    return strlen(buf);
    800030ec:	8526                	mv	a0,s1
    800030ee:	ffffe097          	auipc	ra,0xffffe
    800030f2:	fa2080e7          	jalr	-94(ra) # 80001090 <strlen>
}
    800030f6:	70a2                	ld	ra,40(sp)
    800030f8:	7402                	ld	s0,32(sp)
    800030fa:	64e2                	ld	s1,24(sp)
    800030fc:	6942                	ld	s2,16(sp)
    800030fe:	69a2                	ld	s3,8(sp)
    80003100:	6145                	addi	sp,sp,48
    80003102:	8082                	ret
        return -1;
    80003104:	557d                	li	a0,-1
    80003106:	bfc5                	j	800030f6 <fetchstr+0x3a>

0000000080003108 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80003108:	1101                	addi	sp,sp,-32
    8000310a:	ec06                	sd	ra,24(sp)
    8000310c:	e822                	sd	s0,16(sp)
    8000310e:	e426                	sd	s1,8(sp)
    80003110:	1000                	addi	s0,sp,32
    80003112:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003114:	00000097          	auipc	ra,0x0
    80003118:	eee080e7          	jalr	-274(ra) # 80003002 <argraw>
    8000311c:	c088                	sw	a0,0(s1)
}
    8000311e:	60e2                	ld	ra,24(sp)
    80003120:	6442                	ld	s0,16(sp)
    80003122:	64a2                	ld	s1,8(sp)
    80003124:	6105                	addi	sp,sp,32
    80003126:	8082                	ret

0000000080003128 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80003128:	1101                	addi	sp,sp,-32
    8000312a:	ec06                	sd	ra,24(sp)
    8000312c:	e822                	sd	s0,16(sp)
    8000312e:	e426                	sd	s1,8(sp)
    80003130:	1000                	addi	s0,sp,32
    80003132:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003134:	00000097          	auipc	ra,0x0
    80003138:	ece080e7          	jalr	-306(ra) # 80003002 <argraw>
    8000313c:	e088                	sd	a0,0(s1)
}
    8000313e:	60e2                	ld	ra,24(sp)
    80003140:	6442                	ld	s0,16(sp)
    80003142:	64a2                	ld	s1,8(sp)
    80003144:	6105                	addi	sp,sp,32
    80003146:	8082                	ret

0000000080003148 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80003148:	7179                	addi	sp,sp,-48
    8000314a:	f406                	sd	ra,40(sp)
    8000314c:	f022                	sd	s0,32(sp)
    8000314e:	ec26                	sd	s1,24(sp)
    80003150:	e84a                	sd	s2,16(sp)
    80003152:	1800                	addi	s0,sp,48
    80003154:	84ae                	mv	s1,a1
    80003156:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80003158:	fd840593          	addi	a1,s0,-40
    8000315c:	00000097          	auipc	ra,0x0
    80003160:	fcc080e7          	jalr	-52(ra) # 80003128 <argaddr>
    return fetchstr(addr, buf, max);
    80003164:	864a                	mv	a2,s2
    80003166:	85a6                	mv	a1,s1
    80003168:	fd843503          	ld	a0,-40(s0)
    8000316c:	00000097          	auipc	ra,0x0
    80003170:	f50080e7          	jalr	-176(ra) # 800030bc <fetchstr>
}
    80003174:	70a2                	ld	ra,40(sp)
    80003176:	7402                	ld	s0,32(sp)
    80003178:	64e2                	ld	s1,24(sp)
    8000317a:	6942                	ld	s2,16(sp)
    8000317c:	6145                	addi	sp,sp,48
    8000317e:	8082                	ret

0000000080003180 <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    80003180:	1101                	addi	sp,sp,-32
    80003182:	ec06                	sd	ra,24(sp)
    80003184:	e822                	sd	s0,16(sp)
    80003186:	e426                	sd	s1,8(sp)
    80003188:	e04a                	sd	s2,0(sp)
    8000318a:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    8000318c:	fffff097          	auipc	ra,0xfffff
    80003190:	b98080e7          	jalr	-1128(ra) # 80001d24 <myproc>
    80003194:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    80003196:	05853903          	ld	s2,88(a0)
    8000319a:	0a893783          	ld	a5,168(s2)
    8000319e:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    800031a2:	37fd                	addiw	a5,a5,-1
    800031a4:	4765                	li	a4,25
    800031a6:	00f76f63          	bltu	a4,a5,800031c4 <syscall+0x44>
    800031aa:	00369713          	slli	a4,a3,0x3
    800031ae:	00005797          	auipc	a5,0x5
    800031b2:	71278793          	addi	a5,a5,1810 # 800088c0 <syscalls>
    800031b6:	97ba                	add	a5,a5,a4
    800031b8:	639c                	ld	a5,0(a5)
    800031ba:	c789                	beqz	a5,800031c4 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    800031bc:	9782                	jalr	a5
    800031be:	06a93823          	sd	a0,112(s2)
    800031c2:	a839                	j	800031e0 <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    800031c4:	15848613          	addi	a2,s1,344
    800031c8:	588c                	lw	a1,48(s1)
    800031ca:	00005517          	auipc	a0,0x5
    800031ce:	32e50513          	addi	a0,a0,814 # 800084f8 <__func__.1+0x4f0>
    800031d2:	ffffd097          	auipc	ra,0xffffd
    800031d6:	3ea080e7          	jalr	1002(ra) # 800005bc <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    800031da:	6cbc                	ld	a5,88(s1)
    800031dc:	577d                	li	a4,-1
    800031de:	fbb8                	sd	a4,112(a5)
    }
}
    800031e0:	60e2                	ld	ra,24(sp)
    800031e2:	6442                	ld	s0,16(sp)
    800031e4:	64a2                	ld	s1,8(sp)
    800031e6:	6902                	ld	s2,0(sp)
    800031e8:	6105                	addi	sp,sp,32
    800031ea:	8082                	ret

00000000800031ec <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    800031ec:	1101                	addi	sp,sp,-32
    800031ee:	ec06                	sd	ra,24(sp)
    800031f0:	e822                	sd	s0,16(sp)
    800031f2:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    800031f4:	fec40593          	addi	a1,s0,-20
    800031f8:	4501                	li	a0,0
    800031fa:	00000097          	auipc	ra,0x0
    800031fe:	f0e080e7          	jalr	-242(ra) # 80003108 <argint>
    exit(n);
    80003202:	fec42503          	lw	a0,-20(s0)
    80003206:	fffff097          	auipc	ra,0xfffff
    8000320a:	404080e7          	jalr	1028(ra) # 8000260a <exit>
    return 0; // not reached
}
    8000320e:	4501                	li	a0,0
    80003210:	60e2                	ld	ra,24(sp)
    80003212:	6442                	ld	s0,16(sp)
    80003214:	6105                	addi	sp,sp,32
    80003216:	8082                	ret

0000000080003218 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003218:	1141                	addi	sp,sp,-16
    8000321a:	e406                	sd	ra,8(sp)
    8000321c:	e022                	sd	s0,0(sp)
    8000321e:	0800                	addi	s0,sp,16
    return myproc()->pid;
    80003220:	fffff097          	auipc	ra,0xfffff
    80003224:	b04080e7          	jalr	-1276(ra) # 80001d24 <myproc>
}
    80003228:	5908                	lw	a0,48(a0)
    8000322a:	60a2                	ld	ra,8(sp)
    8000322c:	6402                	ld	s0,0(sp)
    8000322e:	0141                	addi	sp,sp,16
    80003230:	8082                	ret

0000000080003232 <sys_fork>:

uint64
sys_fork(void)
{
    80003232:	1141                	addi	sp,sp,-16
    80003234:	e406                	sd	ra,8(sp)
    80003236:	e022                	sd	s0,0(sp)
    80003238:	0800                	addi	s0,sp,16
    return fork();
    8000323a:	fffff097          	auipc	ra,0xfffff
    8000323e:	038080e7          	jalr	56(ra) # 80002272 <fork>
}
    80003242:	60a2                	ld	ra,8(sp)
    80003244:	6402                	ld	s0,0(sp)
    80003246:	0141                	addi	sp,sp,16
    80003248:	8082                	ret

000000008000324a <sys_wait>:

uint64
sys_wait(void)
{
    8000324a:	1101                	addi	sp,sp,-32
    8000324c:	ec06                	sd	ra,24(sp)
    8000324e:	e822                	sd	s0,16(sp)
    80003250:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    80003252:	fe840593          	addi	a1,s0,-24
    80003256:	4501                	li	a0,0
    80003258:	00000097          	auipc	ra,0x0
    8000325c:	ed0080e7          	jalr	-304(ra) # 80003128 <argaddr>
    return wait(p);
    80003260:	fe843503          	ld	a0,-24(s0)
    80003264:	fffff097          	auipc	ra,0xfffff
    80003268:	54c080e7          	jalr	1356(ra) # 800027b0 <wait>
}
    8000326c:	60e2                	ld	ra,24(sp)
    8000326e:	6442                	ld	s0,16(sp)
    80003270:	6105                	addi	sp,sp,32
    80003272:	8082                	ret

0000000080003274 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003274:	7179                	addi	sp,sp,-48
    80003276:	f406                	sd	ra,40(sp)
    80003278:	f022                	sd	s0,32(sp)
    8000327a:	ec26                	sd	s1,24(sp)
    8000327c:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    8000327e:	fdc40593          	addi	a1,s0,-36
    80003282:	4501                	li	a0,0
    80003284:	00000097          	auipc	ra,0x0
    80003288:	e84080e7          	jalr	-380(ra) # 80003108 <argint>
    addr = myproc()->sz;
    8000328c:	fffff097          	auipc	ra,0xfffff
    80003290:	a98080e7          	jalr	-1384(ra) # 80001d24 <myproc>
    80003294:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    80003296:	fdc42503          	lw	a0,-36(s0)
    8000329a:	fffff097          	auipc	ra,0xfffff
    8000329e:	de4080e7          	jalr	-540(ra) # 8000207e <growproc>
    800032a2:	00054863          	bltz	a0,800032b2 <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    800032a6:	8526                	mv	a0,s1
    800032a8:	70a2                	ld	ra,40(sp)
    800032aa:	7402                	ld	s0,32(sp)
    800032ac:	64e2                	ld	s1,24(sp)
    800032ae:	6145                	addi	sp,sp,48
    800032b0:	8082                	ret
        return -1;
    800032b2:	54fd                	li	s1,-1
    800032b4:	bfcd                	j	800032a6 <sys_sbrk+0x32>

00000000800032b6 <sys_sleep>:

uint64
sys_sleep(void)
{
    800032b6:	7139                	addi	sp,sp,-64
    800032b8:	fc06                	sd	ra,56(sp)
    800032ba:	f822                	sd	s0,48(sp)
    800032bc:	f04a                	sd	s2,32(sp)
    800032be:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    800032c0:	fcc40593          	addi	a1,s0,-52
    800032c4:	4501                	li	a0,0
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	e42080e7          	jalr	-446(ra) # 80003108 <argint>
    acquire(&tickslock);
    800032ce:	0001e517          	auipc	a0,0x1e
    800032d2:	39a50513          	addi	a0,a0,922 # 80021668 <tickslock>
    800032d6:	ffffe097          	auipc	ra,0xffffe
    800032da:	b4a080e7          	jalr	-1206(ra) # 80000e20 <acquire>
    ticks0 = ticks;
    800032de:	00008917          	auipc	s2,0x8
    800032e2:	2d292903          	lw	s2,722(s2) # 8000b5b0 <ticks>
    while (ticks - ticks0 < n)
    800032e6:	fcc42783          	lw	a5,-52(s0)
    800032ea:	c3b9                	beqz	a5,80003330 <sys_sleep+0x7a>
    800032ec:	f426                	sd	s1,40(sp)
    800032ee:	ec4e                	sd	s3,24(sp)
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    800032f0:	0001e997          	auipc	s3,0x1e
    800032f4:	37898993          	addi	s3,s3,888 # 80021668 <tickslock>
    800032f8:	00008497          	auipc	s1,0x8
    800032fc:	2b848493          	addi	s1,s1,696 # 8000b5b0 <ticks>
        if (killed(myproc()))
    80003300:	fffff097          	auipc	ra,0xfffff
    80003304:	a24080e7          	jalr	-1500(ra) # 80001d24 <myproc>
    80003308:	fffff097          	auipc	ra,0xfffff
    8000330c:	476080e7          	jalr	1142(ra) # 8000277e <killed>
    80003310:	ed15                	bnez	a0,8000334c <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    80003312:	85ce                	mv	a1,s3
    80003314:	8526                	mv	a0,s1
    80003316:	fffff097          	auipc	ra,0xfffff
    8000331a:	1c0080e7          	jalr	448(ra) # 800024d6 <sleep>
    while (ticks - ticks0 < n)
    8000331e:	409c                	lw	a5,0(s1)
    80003320:	412787bb          	subw	a5,a5,s2
    80003324:	fcc42703          	lw	a4,-52(s0)
    80003328:	fce7ece3          	bltu	a5,a4,80003300 <sys_sleep+0x4a>
    8000332c:	74a2                	ld	s1,40(sp)
    8000332e:	69e2                	ld	s3,24(sp)
    }
    release(&tickslock);
    80003330:	0001e517          	auipc	a0,0x1e
    80003334:	33850513          	addi	a0,a0,824 # 80021668 <tickslock>
    80003338:	ffffe097          	auipc	ra,0xffffe
    8000333c:	b9c080e7          	jalr	-1124(ra) # 80000ed4 <release>
    return 0;
    80003340:	4501                	li	a0,0
}
    80003342:	70e2                	ld	ra,56(sp)
    80003344:	7442                	ld	s0,48(sp)
    80003346:	7902                	ld	s2,32(sp)
    80003348:	6121                	addi	sp,sp,64
    8000334a:	8082                	ret
            release(&tickslock);
    8000334c:	0001e517          	auipc	a0,0x1e
    80003350:	31c50513          	addi	a0,a0,796 # 80021668 <tickslock>
    80003354:	ffffe097          	auipc	ra,0xffffe
    80003358:	b80080e7          	jalr	-1152(ra) # 80000ed4 <release>
            return -1;
    8000335c:	557d                	li	a0,-1
    8000335e:	74a2                	ld	s1,40(sp)
    80003360:	69e2                	ld	s3,24(sp)
    80003362:	b7c5                	j	80003342 <sys_sleep+0x8c>

0000000080003364 <sys_kill>:

uint64
sys_kill(void)
{
    80003364:	1101                	addi	sp,sp,-32
    80003366:	ec06                	sd	ra,24(sp)
    80003368:	e822                	sd	s0,16(sp)
    8000336a:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    8000336c:	fec40593          	addi	a1,s0,-20
    80003370:	4501                	li	a0,0
    80003372:	00000097          	auipc	ra,0x0
    80003376:	d96080e7          	jalr	-618(ra) # 80003108 <argint>
    return kill(pid);
    8000337a:	fec42503          	lw	a0,-20(s0)
    8000337e:	fffff097          	auipc	ra,0xfffff
    80003382:	362080e7          	jalr	866(ra) # 800026e0 <kill>
}
    80003386:	60e2                	ld	ra,24(sp)
    80003388:	6442                	ld	s0,16(sp)
    8000338a:	6105                	addi	sp,sp,32
    8000338c:	8082                	ret

000000008000338e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000338e:	1101                	addi	sp,sp,-32
    80003390:	ec06                	sd	ra,24(sp)
    80003392:	e822                	sd	s0,16(sp)
    80003394:	e426                	sd	s1,8(sp)
    80003396:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    80003398:	0001e517          	auipc	a0,0x1e
    8000339c:	2d050513          	addi	a0,a0,720 # 80021668 <tickslock>
    800033a0:	ffffe097          	auipc	ra,0xffffe
    800033a4:	a80080e7          	jalr	-1408(ra) # 80000e20 <acquire>
    xticks = ticks;
    800033a8:	00008497          	auipc	s1,0x8
    800033ac:	2084a483          	lw	s1,520(s1) # 8000b5b0 <ticks>
    release(&tickslock);
    800033b0:	0001e517          	auipc	a0,0x1e
    800033b4:	2b850513          	addi	a0,a0,696 # 80021668 <tickslock>
    800033b8:	ffffe097          	auipc	ra,0xffffe
    800033bc:	b1c080e7          	jalr	-1252(ra) # 80000ed4 <release>
    return xticks;
}
    800033c0:	02049513          	slli	a0,s1,0x20
    800033c4:	9101                	srli	a0,a0,0x20
    800033c6:	60e2                	ld	ra,24(sp)
    800033c8:	6442                	ld	s0,16(sp)
    800033ca:	64a2                	ld	s1,8(sp)
    800033cc:	6105                	addi	sp,sp,32
    800033ce:	8082                	ret

00000000800033d0 <sys_ps>:

void *
sys_ps(void)
{
    800033d0:	1101                	addi	sp,sp,-32
    800033d2:	ec06                	sd	ra,24(sp)
    800033d4:	e822                	sd	s0,16(sp)
    800033d6:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    800033d8:	fe042623          	sw	zero,-20(s0)
    800033dc:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    800033e0:	fec40593          	addi	a1,s0,-20
    800033e4:	4501                	li	a0,0
    800033e6:	00000097          	auipc	ra,0x0
    800033ea:	d22080e7          	jalr	-734(ra) # 80003108 <argint>
    argint(1, &count);
    800033ee:	fe840593          	addi	a1,s0,-24
    800033f2:	4505                	li	a0,1
    800033f4:	00000097          	auipc	ra,0x0
    800033f8:	d14080e7          	jalr	-748(ra) # 80003108 <argint>
    return ps((uint8)start, (uint8)count);
    800033fc:	fe844583          	lbu	a1,-24(s0)
    80003400:	fec44503          	lbu	a0,-20(s0)
    80003404:	fffff097          	auipc	ra,0xfffff
    80003408:	cd6080e7          	jalr	-810(ra) # 800020da <ps>
}
    8000340c:	60e2                	ld	ra,24(sp)
    8000340e:	6442                	ld	s0,16(sp)
    80003410:	6105                	addi	sp,sp,32
    80003412:	8082                	ret

0000000080003414 <sys_schedls>:

uint64 sys_schedls(void)
{
    80003414:	1141                	addi	sp,sp,-16
    80003416:	e406                	sd	ra,8(sp)
    80003418:	e022                	sd	s0,0(sp)
    8000341a:	0800                	addi	s0,sp,16
    schedls();
    8000341c:	fffff097          	auipc	ra,0xfffff
    80003420:	61e080e7          	jalr	1566(ra) # 80002a3a <schedls>
    return 0;
}
    80003424:	4501                	li	a0,0
    80003426:	60a2                	ld	ra,8(sp)
    80003428:	6402                	ld	s0,0(sp)
    8000342a:	0141                	addi	sp,sp,16
    8000342c:	8082                	ret

000000008000342e <sys_schedset>:

uint64 sys_schedset(void)
{
    8000342e:	1101                	addi	sp,sp,-32
    80003430:	ec06                	sd	ra,24(sp)
    80003432:	e822                	sd	s0,16(sp)
    80003434:	1000                	addi	s0,sp,32
    int id = 0;
    80003436:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    8000343a:	fec40593          	addi	a1,s0,-20
    8000343e:	4501                	li	a0,0
    80003440:	00000097          	auipc	ra,0x0
    80003444:	cc8080e7          	jalr	-824(ra) # 80003108 <argint>
    schedset(id - 1);
    80003448:	fec42503          	lw	a0,-20(s0)
    8000344c:	357d                	addiw	a0,a0,-1
    8000344e:	fffff097          	auipc	ra,0xfffff
    80003452:	682080e7          	jalr	1666(ra) # 80002ad0 <schedset>
    return 0;
}
    80003456:	4501                	li	a0,0
    80003458:	60e2                	ld	ra,24(sp)
    8000345a:	6442                	ld	s0,16(sp)
    8000345c:	6105                	addi	sp,sp,32
    8000345e:	8082                	ret

0000000080003460 <sys_va2pa>:

uint64 sys_va2pa(void)
{
    80003460:	7179                	addi	sp,sp,-48
    80003462:	f406                	sd	ra,40(sp)
    80003464:	f022                	sd	s0,32(sp)
    80003466:	ec26                	sd	s1,24(sp)
    80003468:	e84a                	sd	s2,16(sp)
    8000346a:	1800                	addi	s0,sp,48
    uint64 va;
    int pid;
    argaddr(0, &va);
    8000346c:	fd840593          	addi	a1,s0,-40
    80003470:	4501                	li	a0,0
    80003472:	00000097          	auipc	ra,0x0
    80003476:	cb6080e7          	jalr	-842(ra) # 80003128 <argaddr>
    argint(1, &pid);
    8000347a:	fd440593          	addi	a1,s0,-44
    8000347e:	4505                	li	a0,1
    80003480:	00000097          	auipc	ra,0x0
    80003484:	c88080e7          	jalr	-888(ra) # 80003108 <argint>

    struct proc *p;
    if (pid == 0) {
    80003488:	fd442783          	lw	a5,-44(s0)
        p = myproc();
        return walkaddr(p->pagetable, va);
    }

    extern struct proc proc[];
    for (p = proc; p < &proc[NPROC]; p++) {
    8000348c:	00018497          	auipc	s1,0x18
    80003490:	7dc48493          	addi	s1,s1,2012 # 8001bc68 <proc>
    80003494:	0001e917          	auipc	s2,0x1e
    80003498:	1d490913          	addi	s2,s2,468 # 80021668 <tickslock>
    if (pid == 0) {
    8000349c:	c795                	beqz	a5,800034c8 <sys_va2pa+0x68>
        acquire(&p->lock);
    8000349e:	8526                	mv	a0,s1
    800034a0:	ffffe097          	auipc	ra,0xffffe
    800034a4:	980080e7          	jalr	-1664(ra) # 80000e20 <acquire>
        if (p->pid == pid) {
    800034a8:	5898                	lw	a4,48(s1)
    800034aa:	fd442783          	lw	a5,-44(s0)
    800034ae:	02f70a63          	beq	a4,a5,800034e2 <sys_va2pa+0x82>
            uint64 pa = walkaddr(p->pagetable, va);
            release(&p->lock);
            return pa;
        }
        release(&p->lock);
    800034b2:	8526                	mv	a0,s1
    800034b4:	ffffe097          	auipc	ra,0xffffe
    800034b8:	a20080e7          	jalr	-1504(ra) # 80000ed4 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    800034bc:	16848493          	addi	s1,s1,360
    800034c0:	fd249fe3          	bne	s1,s2,8000349e <sys_va2pa+0x3e>
    }
    return 0;
    800034c4:	4901                	li	s2,0
    800034c6:	a81d                	j	800034fc <sys_va2pa+0x9c>
        p = myproc();
    800034c8:	fffff097          	auipc	ra,0xfffff
    800034cc:	85c080e7          	jalr	-1956(ra) # 80001d24 <myproc>
        return walkaddr(p->pagetable, va);
    800034d0:	fd843583          	ld	a1,-40(s0)
    800034d4:	6928                	ld	a0,80(a0)
    800034d6:	ffffe097          	auipc	ra,0xffffe
    800034da:	dc8080e7          	jalr	-568(ra) # 8000129e <walkaddr>
    800034de:	892a                	mv	s2,a0
    800034e0:	a831                	j	800034fc <sys_va2pa+0x9c>
            uint64 pa = walkaddr(p->pagetable, va);
    800034e2:	fd843583          	ld	a1,-40(s0)
    800034e6:	68a8                	ld	a0,80(s1)
    800034e8:	ffffe097          	auipc	ra,0xffffe
    800034ec:	db6080e7          	jalr	-586(ra) # 8000129e <walkaddr>
    800034f0:	892a                	mv	s2,a0
            release(&p->lock);
    800034f2:	8526                	mv	a0,s1
    800034f4:	ffffe097          	auipc	ra,0xffffe
    800034f8:	9e0080e7          	jalr	-1568(ra) # 80000ed4 <release>
}
    800034fc:	854a                	mv	a0,s2
    800034fe:	70a2                	ld	ra,40(sp)
    80003500:	7402                	ld	s0,32(sp)
    80003502:	64e2                	ld	s1,24(sp)
    80003504:	6942                	ld	s2,16(sp)
    80003506:	6145                	addi	sp,sp,48
    80003508:	8082                	ret

000000008000350a <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    8000350a:	1141                	addi	sp,sp,-16
    8000350c:	e406                	sd	ra,8(sp)
    8000350e:	e022                	sd	s0,0(sp)
    80003510:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    80003512:	00008597          	auipc	a1,0x8
    80003516:	0765b583          	ld	a1,118(a1) # 8000b588 <FREE_PAGES>
    8000351a:	00005517          	auipc	a0,0x5
    8000351e:	ffe50513          	addi	a0,a0,-2 # 80008518 <__func__.1+0x510>
    80003522:	ffffd097          	auipc	ra,0xffffd
    80003526:	09a080e7          	jalr	154(ra) # 800005bc <printf>
    return 0;
    8000352a:	4501                	li	a0,0
    8000352c:	60a2                	ld	ra,8(sp)
    8000352e:	6402                	ld	s0,0(sp)
    80003530:	0141                	addi	sp,sp,16
    80003532:	8082                	ret

0000000080003534 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003534:	7179                	addi	sp,sp,-48
    80003536:	f406                	sd	ra,40(sp)
    80003538:	f022                	sd	s0,32(sp)
    8000353a:	ec26                	sd	s1,24(sp)
    8000353c:	e84a                	sd	s2,16(sp)
    8000353e:	e44e                	sd	s3,8(sp)
    80003540:	e052                	sd	s4,0(sp)
    80003542:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003544:	00005597          	auipc	a1,0x5
    80003548:	fdc58593          	addi	a1,a1,-36 # 80008520 <__func__.1+0x518>
    8000354c:	0001e517          	auipc	a0,0x1e
    80003550:	13450513          	addi	a0,a0,308 # 80021680 <bcache>
    80003554:	ffffe097          	auipc	ra,0xffffe
    80003558:	83c080e7          	jalr	-1988(ra) # 80000d90 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000355c:	00026797          	auipc	a5,0x26
    80003560:	12478793          	addi	a5,a5,292 # 80029680 <bcache+0x8000>
    80003564:	00026717          	auipc	a4,0x26
    80003568:	38470713          	addi	a4,a4,900 # 800298e8 <bcache+0x8268>
    8000356c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003570:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003574:	0001e497          	auipc	s1,0x1e
    80003578:	12448493          	addi	s1,s1,292 # 80021698 <bcache+0x18>
    b->next = bcache.head.next;
    8000357c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000357e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003580:	00005a17          	auipc	s4,0x5
    80003584:	fa8a0a13          	addi	s4,s4,-88 # 80008528 <__func__.1+0x520>
    b->next = bcache.head.next;
    80003588:	2b893783          	ld	a5,696(s2)
    8000358c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000358e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003592:	85d2                	mv	a1,s4
    80003594:	01048513          	addi	a0,s1,16
    80003598:	00001097          	auipc	ra,0x1
    8000359c:	4e8080e7          	jalr	1256(ra) # 80004a80 <initsleeplock>
    bcache.head.next->prev = b;
    800035a0:	2b893783          	ld	a5,696(s2)
    800035a4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800035a6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035aa:	45848493          	addi	s1,s1,1112
    800035ae:	fd349de3          	bne	s1,s3,80003588 <binit+0x54>
  }
}
    800035b2:	70a2                	ld	ra,40(sp)
    800035b4:	7402                	ld	s0,32(sp)
    800035b6:	64e2                	ld	s1,24(sp)
    800035b8:	6942                	ld	s2,16(sp)
    800035ba:	69a2                	ld	s3,8(sp)
    800035bc:	6a02                	ld	s4,0(sp)
    800035be:	6145                	addi	sp,sp,48
    800035c0:	8082                	ret

00000000800035c2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800035c2:	7179                	addi	sp,sp,-48
    800035c4:	f406                	sd	ra,40(sp)
    800035c6:	f022                	sd	s0,32(sp)
    800035c8:	ec26                	sd	s1,24(sp)
    800035ca:	e84a                	sd	s2,16(sp)
    800035cc:	e44e                	sd	s3,8(sp)
    800035ce:	1800                	addi	s0,sp,48
    800035d0:	892a                	mv	s2,a0
    800035d2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800035d4:	0001e517          	auipc	a0,0x1e
    800035d8:	0ac50513          	addi	a0,a0,172 # 80021680 <bcache>
    800035dc:	ffffe097          	auipc	ra,0xffffe
    800035e0:	844080e7          	jalr	-1980(ra) # 80000e20 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800035e4:	00026497          	auipc	s1,0x26
    800035e8:	3544b483          	ld	s1,852(s1) # 80029938 <bcache+0x82b8>
    800035ec:	00026797          	auipc	a5,0x26
    800035f0:	2fc78793          	addi	a5,a5,764 # 800298e8 <bcache+0x8268>
    800035f4:	02f48f63          	beq	s1,a5,80003632 <bread+0x70>
    800035f8:	873e                	mv	a4,a5
    800035fa:	a021                	j	80003602 <bread+0x40>
    800035fc:	68a4                	ld	s1,80(s1)
    800035fe:	02e48a63          	beq	s1,a4,80003632 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003602:	449c                	lw	a5,8(s1)
    80003604:	ff279ce3          	bne	a5,s2,800035fc <bread+0x3a>
    80003608:	44dc                	lw	a5,12(s1)
    8000360a:	ff3799e3          	bne	a5,s3,800035fc <bread+0x3a>
      b->refcnt++;
    8000360e:	40bc                	lw	a5,64(s1)
    80003610:	2785                	addiw	a5,a5,1
    80003612:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003614:	0001e517          	auipc	a0,0x1e
    80003618:	06c50513          	addi	a0,a0,108 # 80021680 <bcache>
    8000361c:	ffffe097          	auipc	ra,0xffffe
    80003620:	8b8080e7          	jalr	-1864(ra) # 80000ed4 <release>
      acquiresleep(&b->lock);
    80003624:	01048513          	addi	a0,s1,16
    80003628:	00001097          	auipc	ra,0x1
    8000362c:	492080e7          	jalr	1170(ra) # 80004aba <acquiresleep>
      return b;
    80003630:	a8b9                	j	8000368e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003632:	00026497          	auipc	s1,0x26
    80003636:	2fe4b483          	ld	s1,766(s1) # 80029930 <bcache+0x82b0>
    8000363a:	00026797          	auipc	a5,0x26
    8000363e:	2ae78793          	addi	a5,a5,686 # 800298e8 <bcache+0x8268>
    80003642:	00f48863          	beq	s1,a5,80003652 <bread+0x90>
    80003646:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003648:	40bc                	lw	a5,64(s1)
    8000364a:	cf81                	beqz	a5,80003662 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000364c:	64a4                	ld	s1,72(s1)
    8000364e:	fee49de3          	bne	s1,a4,80003648 <bread+0x86>
  panic("bget: no buffers");
    80003652:	00005517          	auipc	a0,0x5
    80003656:	ede50513          	addi	a0,a0,-290 # 80008530 <__func__.1+0x528>
    8000365a:	ffffd097          	auipc	ra,0xffffd
    8000365e:	f06080e7          	jalr	-250(ra) # 80000560 <panic>
      b->dev = dev;
    80003662:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003666:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000366a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000366e:	4785                	li	a5,1
    80003670:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003672:	0001e517          	auipc	a0,0x1e
    80003676:	00e50513          	addi	a0,a0,14 # 80021680 <bcache>
    8000367a:	ffffe097          	auipc	ra,0xffffe
    8000367e:	85a080e7          	jalr	-1958(ra) # 80000ed4 <release>
      acquiresleep(&b->lock);
    80003682:	01048513          	addi	a0,s1,16
    80003686:	00001097          	auipc	ra,0x1
    8000368a:	434080e7          	jalr	1076(ra) # 80004aba <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000368e:	409c                	lw	a5,0(s1)
    80003690:	cb89                	beqz	a5,800036a2 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003692:	8526                	mv	a0,s1
    80003694:	70a2                	ld	ra,40(sp)
    80003696:	7402                	ld	s0,32(sp)
    80003698:	64e2                	ld	s1,24(sp)
    8000369a:	6942                	ld	s2,16(sp)
    8000369c:	69a2                	ld	s3,8(sp)
    8000369e:	6145                	addi	sp,sp,48
    800036a0:	8082                	ret
    virtio_disk_rw(b, 0);
    800036a2:	4581                	li	a1,0
    800036a4:	8526                	mv	a0,s1
    800036a6:	00003097          	auipc	ra,0x3
    800036aa:	0f2080e7          	jalr	242(ra) # 80006798 <virtio_disk_rw>
    b->valid = 1;
    800036ae:	4785                	li	a5,1
    800036b0:	c09c                	sw	a5,0(s1)
  return b;
    800036b2:	b7c5                	j	80003692 <bread+0xd0>

00000000800036b4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800036b4:	1101                	addi	sp,sp,-32
    800036b6:	ec06                	sd	ra,24(sp)
    800036b8:	e822                	sd	s0,16(sp)
    800036ba:	e426                	sd	s1,8(sp)
    800036bc:	1000                	addi	s0,sp,32
    800036be:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036c0:	0541                	addi	a0,a0,16
    800036c2:	00001097          	auipc	ra,0x1
    800036c6:	492080e7          	jalr	1170(ra) # 80004b54 <holdingsleep>
    800036ca:	cd01                	beqz	a0,800036e2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800036cc:	4585                	li	a1,1
    800036ce:	8526                	mv	a0,s1
    800036d0:	00003097          	auipc	ra,0x3
    800036d4:	0c8080e7          	jalr	200(ra) # 80006798 <virtio_disk_rw>
}
    800036d8:	60e2                	ld	ra,24(sp)
    800036da:	6442                	ld	s0,16(sp)
    800036dc:	64a2                	ld	s1,8(sp)
    800036de:	6105                	addi	sp,sp,32
    800036e0:	8082                	ret
    panic("bwrite");
    800036e2:	00005517          	auipc	a0,0x5
    800036e6:	e6650513          	addi	a0,a0,-410 # 80008548 <__func__.1+0x540>
    800036ea:	ffffd097          	auipc	ra,0xffffd
    800036ee:	e76080e7          	jalr	-394(ra) # 80000560 <panic>

00000000800036f2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800036f2:	1101                	addi	sp,sp,-32
    800036f4:	ec06                	sd	ra,24(sp)
    800036f6:	e822                	sd	s0,16(sp)
    800036f8:	e426                	sd	s1,8(sp)
    800036fa:	e04a                	sd	s2,0(sp)
    800036fc:	1000                	addi	s0,sp,32
    800036fe:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003700:	01050913          	addi	s2,a0,16
    80003704:	854a                	mv	a0,s2
    80003706:	00001097          	auipc	ra,0x1
    8000370a:	44e080e7          	jalr	1102(ra) # 80004b54 <holdingsleep>
    8000370e:	c925                	beqz	a0,8000377e <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003710:	854a                	mv	a0,s2
    80003712:	00001097          	auipc	ra,0x1
    80003716:	3fe080e7          	jalr	1022(ra) # 80004b10 <releasesleep>

  acquire(&bcache.lock);
    8000371a:	0001e517          	auipc	a0,0x1e
    8000371e:	f6650513          	addi	a0,a0,-154 # 80021680 <bcache>
    80003722:	ffffd097          	auipc	ra,0xffffd
    80003726:	6fe080e7          	jalr	1790(ra) # 80000e20 <acquire>
  b->refcnt--;
    8000372a:	40bc                	lw	a5,64(s1)
    8000372c:	37fd                	addiw	a5,a5,-1
    8000372e:	0007871b          	sext.w	a4,a5
    80003732:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003734:	e71d                	bnez	a4,80003762 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003736:	68b8                	ld	a4,80(s1)
    80003738:	64bc                	ld	a5,72(s1)
    8000373a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000373c:	68b8                	ld	a4,80(s1)
    8000373e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003740:	00026797          	auipc	a5,0x26
    80003744:	f4078793          	addi	a5,a5,-192 # 80029680 <bcache+0x8000>
    80003748:	2b87b703          	ld	a4,696(a5)
    8000374c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000374e:	00026717          	auipc	a4,0x26
    80003752:	19a70713          	addi	a4,a4,410 # 800298e8 <bcache+0x8268>
    80003756:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003758:	2b87b703          	ld	a4,696(a5)
    8000375c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000375e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003762:	0001e517          	auipc	a0,0x1e
    80003766:	f1e50513          	addi	a0,a0,-226 # 80021680 <bcache>
    8000376a:	ffffd097          	auipc	ra,0xffffd
    8000376e:	76a080e7          	jalr	1898(ra) # 80000ed4 <release>
}
    80003772:	60e2                	ld	ra,24(sp)
    80003774:	6442                	ld	s0,16(sp)
    80003776:	64a2                	ld	s1,8(sp)
    80003778:	6902                	ld	s2,0(sp)
    8000377a:	6105                	addi	sp,sp,32
    8000377c:	8082                	ret
    panic("brelse");
    8000377e:	00005517          	auipc	a0,0x5
    80003782:	dd250513          	addi	a0,a0,-558 # 80008550 <__func__.1+0x548>
    80003786:	ffffd097          	auipc	ra,0xffffd
    8000378a:	dda080e7          	jalr	-550(ra) # 80000560 <panic>

000000008000378e <bpin>:

void
bpin(struct buf *b) {
    8000378e:	1101                	addi	sp,sp,-32
    80003790:	ec06                	sd	ra,24(sp)
    80003792:	e822                	sd	s0,16(sp)
    80003794:	e426                	sd	s1,8(sp)
    80003796:	1000                	addi	s0,sp,32
    80003798:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000379a:	0001e517          	auipc	a0,0x1e
    8000379e:	ee650513          	addi	a0,a0,-282 # 80021680 <bcache>
    800037a2:	ffffd097          	auipc	ra,0xffffd
    800037a6:	67e080e7          	jalr	1662(ra) # 80000e20 <acquire>
  b->refcnt++;
    800037aa:	40bc                	lw	a5,64(s1)
    800037ac:	2785                	addiw	a5,a5,1
    800037ae:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037b0:	0001e517          	auipc	a0,0x1e
    800037b4:	ed050513          	addi	a0,a0,-304 # 80021680 <bcache>
    800037b8:	ffffd097          	auipc	ra,0xffffd
    800037bc:	71c080e7          	jalr	1820(ra) # 80000ed4 <release>
}
    800037c0:	60e2                	ld	ra,24(sp)
    800037c2:	6442                	ld	s0,16(sp)
    800037c4:	64a2                	ld	s1,8(sp)
    800037c6:	6105                	addi	sp,sp,32
    800037c8:	8082                	ret

00000000800037ca <bunpin>:

void
bunpin(struct buf *b) {
    800037ca:	1101                	addi	sp,sp,-32
    800037cc:	ec06                	sd	ra,24(sp)
    800037ce:	e822                	sd	s0,16(sp)
    800037d0:	e426                	sd	s1,8(sp)
    800037d2:	1000                	addi	s0,sp,32
    800037d4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037d6:	0001e517          	auipc	a0,0x1e
    800037da:	eaa50513          	addi	a0,a0,-342 # 80021680 <bcache>
    800037de:	ffffd097          	auipc	ra,0xffffd
    800037e2:	642080e7          	jalr	1602(ra) # 80000e20 <acquire>
  b->refcnt--;
    800037e6:	40bc                	lw	a5,64(s1)
    800037e8:	37fd                	addiw	a5,a5,-1
    800037ea:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037ec:	0001e517          	auipc	a0,0x1e
    800037f0:	e9450513          	addi	a0,a0,-364 # 80021680 <bcache>
    800037f4:	ffffd097          	auipc	ra,0xffffd
    800037f8:	6e0080e7          	jalr	1760(ra) # 80000ed4 <release>
}
    800037fc:	60e2                	ld	ra,24(sp)
    800037fe:	6442                	ld	s0,16(sp)
    80003800:	64a2                	ld	s1,8(sp)
    80003802:	6105                	addi	sp,sp,32
    80003804:	8082                	ret

0000000080003806 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003806:	1101                	addi	sp,sp,-32
    80003808:	ec06                	sd	ra,24(sp)
    8000380a:	e822                	sd	s0,16(sp)
    8000380c:	e426                	sd	s1,8(sp)
    8000380e:	e04a                	sd	s2,0(sp)
    80003810:	1000                	addi	s0,sp,32
    80003812:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003814:	00d5d59b          	srliw	a1,a1,0xd
    80003818:	00026797          	auipc	a5,0x26
    8000381c:	5447a783          	lw	a5,1348(a5) # 80029d5c <sb+0x1c>
    80003820:	9dbd                	addw	a1,a1,a5
    80003822:	00000097          	auipc	ra,0x0
    80003826:	da0080e7          	jalr	-608(ra) # 800035c2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000382a:	0074f713          	andi	a4,s1,7
    8000382e:	4785                	li	a5,1
    80003830:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003834:	14ce                	slli	s1,s1,0x33
    80003836:	90d9                	srli	s1,s1,0x36
    80003838:	00950733          	add	a4,a0,s1
    8000383c:	05874703          	lbu	a4,88(a4)
    80003840:	00e7f6b3          	and	a3,a5,a4
    80003844:	c69d                	beqz	a3,80003872 <bfree+0x6c>
    80003846:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003848:	94aa                	add	s1,s1,a0
    8000384a:	fff7c793          	not	a5,a5
    8000384e:	8f7d                	and	a4,a4,a5
    80003850:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003854:	00001097          	auipc	ra,0x1
    80003858:	148080e7          	jalr	328(ra) # 8000499c <log_write>
  brelse(bp);
    8000385c:	854a                	mv	a0,s2
    8000385e:	00000097          	auipc	ra,0x0
    80003862:	e94080e7          	jalr	-364(ra) # 800036f2 <brelse>
}
    80003866:	60e2                	ld	ra,24(sp)
    80003868:	6442                	ld	s0,16(sp)
    8000386a:	64a2                	ld	s1,8(sp)
    8000386c:	6902                	ld	s2,0(sp)
    8000386e:	6105                	addi	sp,sp,32
    80003870:	8082                	ret
    panic("freeing free block");
    80003872:	00005517          	auipc	a0,0x5
    80003876:	ce650513          	addi	a0,a0,-794 # 80008558 <__func__.1+0x550>
    8000387a:	ffffd097          	auipc	ra,0xffffd
    8000387e:	ce6080e7          	jalr	-794(ra) # 80000560 <panic>

0000000080003882 <balloc>:
{
    80003882:	711d                	addi	sp,sp,-96
    80003884:	ec86                	sd	ra,88(sp)
    80003886:	e8a2                	sd	s0,80(sp)
    80003888:	e4a6                	sd	s1,72(sp)
    8000388a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000388c:	00026797          	auipc	a5,0x26
    80003890:	4b87a783          	lw	a5,1208(a5) # 80029d44 <sb+0x4>
    80003894:	10078f63          	beqz	a5,800039b2 <balloc+0x130>
    80003898:	e0ca                	sd	s2,64(sp)
    8000389a:	fc4e                	sd	s3,56(sp)
    8000389c:	f852                	sd	s4,48(sp)
    8000389e:	f456                	sd	s5,40(sp)
    800038a0:	f05a                	sd	s6,32(sp)
    800038a2:	ec5e                	sd	s7,24(sp)
    800038a4:	e862                	sd	s8,16(sp)
    800038a6:	e466                	sd	s9,8(sp)
    800038a8:	8baa                	mv	s7,a0
    800038aa:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800038ac:	00026b17          	auipc	s6,0x26
    800038b0:	494b0b13          	addi	s6,s6,1172 # 80029d40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038b4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800038b6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038b8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800038ba:	6c89                	lui	s9,0x2
    800038bc:	a061                	j	80003944 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800038be:	97ca                	add	a5,a5,s2
    800038c0:	8e55                	or	a2,a2,a3
    800038c2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800038c6:	854a                	mv	a0,s2
    800038c8:	00001097          	auipc	ra,0x1
    800038cc:	0d4080e7          	jalr	212(ra) # 8000499c <log_write>
        brelse(bp);
    800038d0:	854a                	mv	a0,s2
    800038d2:	00000097          	auipc	ra,0x0
    800038d6:	e20080e7          	jalr	-480(ra) # 800036f2 <brelse>
  bp = bread(dev, bno);
    800038da:	85a6                	mv	a1,s1
    800038dc:	855e                	mv	a0,s7
    800038de:	00000097          	auipc	ra,0x0
    800038e2:	ce4080e7          	jalr	-796(ra) # 800035c2 <bread>
    800038e6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038e8:	40000613          	li	a2,1024
    800038ec:	4581                	li	a1,0
    800038ee:	05850513          	addi	a0,a0,88
    800038f2:	ffffd097          	auipc	ra,0xffffd
    800038f6:	62a080e7          	jalr	1578(ra) # 80000f1c <memset>
  log_write(bp);
    800038fa:	854a                	mv	a0,s2
    800038fc:	00001097          	auipc	ra,0x1
    80003900:	0a0080e7          	jalr	160(ra) # 8000499c <log_write>
  brelse(bp);
    80003904:	854a                	mv	a0,s2
    80003906:	00000097          	auipc	ra,0x0
    8000390a:	dec080e7          	jalr	-532(ra) # 800036f2 <brelse>
}
    8000390e:	6906                	ld	s2,64(sp)
    80003910:	79e2                	ld	s3,56(sp)
    80003912:	7a42                	ld	s4,48(sp)
    80003914:	7aa2                	ld	s5,40(sp)
    80003916:	7b02                	ld	s6,32(sp)
    80003918:	6be2                	ld	s7,24(sp)
    8000391a:	6c42                	ld	s8,16(sp)
    8000391c:	6ca2                	ld	s9,8(sp)
}
    8000391e:	8526                	mv	a0,s1
    80003920:	60e6                	ld	ra,88(sp)
    80003922:	6446                	ld	s0,80(sp)
    80003924:	64a6                	ld	s1,72(sp)
    80003926:	6125                	addi	sp,sp,96
    80003928:	8082                	ret
    brelse(bp);
    8000392a:	854a                	mv	a0,s2
    8000392c:	00000097          	auipc	ra,0x0
    80003930:	dc6080e7          	jalr	-570(ra) # 800036f2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003934:	015c87bb          	addw	a5,s9,s5
    80003938:	00078a9b          	sext.w	s5,a5
    8000393c:	004b2703          	lw	a4,4(s6)
    80003940:	06eaf163          	bgeu	s5,a4,800039a2 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003944:	41fad79b          	sraiw	a5,s5,0x1f
    80003948:	0137d79b          	srliw	a5,a5,0x13
    8000394c:	015787bb          	addw	a5,a5,s5
    80003950:	40d7d79b          	sraiw	a5,a5,0xd
    80003954:	01cb2583          	lw	a1,28(s6)
    80003958:	9dbd                	addw	a1,a1,a5
    8000395a:	855e                	mv	a0,s7
    8000395c:	00000097          	auipc	ra,0x0
    80003960:	c66080e7          	jalr	-922(ra) # 800035c2 <bread>
    80003964:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003966:	004b2503          	lw	a0,4(s6)
    8000396a:	000a849b          	sext.w	s1,s5
    8000396e:	8762                	mv	a4,s8
    80003970:	faa4fde3          	bgeu	s1,a0,8000392a <balloc+0xa8>
      m = 1 << (bi % 8);
    80003974:	00777693          	andi	a3,a4,7
    80003978:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000397c:	41f7579b          	sraiw	a5,a4,0x1f
    80003980:	01d7d79b          	srliw	a5,a5,0x1d
    80003984:	9fb9                	addw	a5,a5,a4
    80003986:	4037d79b          	sraiw	a5,a5,0x3
    8000398a:	00f90633          	add	a2,s2,a5
    8000398e:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003992:	00c6f5b3          	and	a1,a3,a2
    80003996:	d585                	beqz	a1,800038be <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003998:	2705                	addiw	a4,a4,1
    8000399a:	2485                	addiw	s1,s1,1
    8000399c:	fd471ae3          	bne	a4,s4,80003970 <balloc+0xee>
    800039a0:	b769                	j	8000392a <balloc+0xa8>
    800039a2:	6906                	ld	s2,64(sp)
    800039a4:	79e2                	ld	s3,56(sp)
    800039a6:	7a42                	ld	s4,48(sp)
    800039a8:	7aa2                	ld	s5,40(sp)
    800039aa:	7b02                	ld	s6,32(sp)
    800039ac:	6be2                	ld	s7,24(sp)
    800039ae:	6c42                	ld	s8,16(sp)
    800039b0:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800039b2:	00005517          	auipc	a0,0x5
    800039b6:	bbe50513          	addi	a0,a0,-1090 # 80008570 <__func__.1+0x568>
    800039ba:	ffffd097          	auipc	ra,0xffffd
    800039be:	c02080e7          	jalr	-1022(ra) # 800005bc <printf>
  return 0;
    800039c2:	4481                	li	s1,0
    800039c4:	bfa9                	j	8000391e <balloc+0x9c>

00000000800039c6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800039c6:	7179                	addi	sp,sp,-48
    800039c8:	f406                	sd	ra,40(sp)
    800039ca:	f022                	sd	s0,32(sp)
    800039cc:	ec26                	sd	s1,24(sp)
    800039ce:	e84a                	sd	s2,16(sp)
    800039d0:	e44e                	sd	s3,8(sp)
    800039d2:	1800                	addi	s0,sp,48
    800039d4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800039d6:	47ad                	li	a5,11
    800039d8:	02b7e863          	bltu	a5,a1,80003a08 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800039dc:	02059793          	slli	a5,a1,0x20
    800039e0:	01e7d593          	srli	a1,a5,0x1e
    800039e4:	00b504b3          	add	s1,a0,a1
    800039e8:	0504a903          	lw	s2,80(s1)
    800039ec:	08091263          	bnez	s2,80003a70 <bmap+0xaa>
      addr = balloc(ip->dev);
    800039f0:	4108                	lw	a0,0(a0)
    800039f2:	00000097          	auipc	ra,0x0
    800039f6:	e90080e7          	jalr	-368(ra) # 80003882 <balloc>
    800039fa:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800039fe:	06090963          	beqz	s2,80003a70 <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    80003a02:	0524a823          	sw	s2,80(s1)
    80003a06:	a0ad                	j	80003a70 <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003a08:	ff45849b          	addiw	s1,a1,-12
    80003a0c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003a10:	0ff00793          	li	a5,255
    80003a14:	08e7e863          	bltu	a5,a4,80003aa4 <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003a18:	08052903          	lw	s2,128(a0)
    80003a1c:	00091f63          	bnez	s2,80003a3a <bmap+0x74>
      addr = balloc(ip->dev);
    80003a20:	4108                	lw	a0,0(a0)
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	e60080e7          	jalr	-416(ra) # 80003882 <balloc>
    80003a2a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003a2e:	04090163          	beqz	s2,80003a70 <bmap+0xaa>
    80003a32:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003a34:	0929a023          	sw	s2,128(s3)
    80003a38:	a011                	j	80003a3c <bmap+0x76>
    80003a3a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003a3c:	85ca                	mv	a1,s2
    80003a3e:	0009a503          	lw	a0,0(s3)
    80003a42:	00000097          	auipc	ra,0x0
    80003a46:	b80080e7          	jalr	-1152(ra) # 800035c2 <bread>
    80003a4a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003a4c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003a50:	02049713          	slli	a4,s1,0x20
    80003a54:	01e75593          	srli	a1,a4,0x1e
    80003a58:	00b784b3          	add	s1,a5,a1
    80003a5c:	0004a903          	lw	s2,0(s1)
    80003a60:	02090063          	beqz	s2,80003a80 <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003a64:	8552                	mv	a0,s4
    80003a66:	00000097          	auipc	ra,0x0
    80003a6a:	c8c080e7          	jalr	-884(ra) # 800036f2 <brelse>
    return addr;
    80003a6e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003a70:	854a                	mv	a0,s2
    80003a72:	70a2                	ld	ra,40(sp)
    80003a74:	7402                	ld	s0,32(sp)
    80003a76:	64e2                	ld	s1,24(sp)
    80003a78:	6942                	ld	s2,16(sp)
    80003a7a:	69a2                	ld	s3,8(sp)
    80003a7c:	6145                	addi	sp,sp,48
    80003a7e:	8082                	ret
      addr = balloc(ip->dev);
    80003a80:	0009a503          	lw	a0,0(s3)
    80003a84:	00000097          	auipc	ra,0x0
    80003a88:	dfe080e7          	jalr	-514(ra) # 80003882 <balloc>
    80003a8c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003a90:	fc090ae3          	beqz	s2,80003a64 <bmap+0x9e>
        a[bn] = addr;
    80003a94:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003a98:	8552                	mv	a0,s4
    80003a9a:	00001097          	auipc	ra,0x1
    80003a9e:	f02080e7          	jalr	-254(ra) # 8000499c <log_write>
    80003aa2:	b7c9                	j	80003a64 <bmap+0x9e>
    80003aa4:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003aa6:	00005517          	auipc	a0,0x5
    80003aaa:	ae250513          	addi	a0,a0,-1310 # 80008588 <__func__.1+0x580>
    80003aae:	ffffd097          	auipc	ra,0xffffd
    80003ab2:	ab2080e7          	jalr	-1358(ra) # 80000560 <panic>

0000000080003ab6 <iget>:
{
    80003ab6:	7179                	addi	sp,sp,-48
    80003ab8:	f406                	sd	ra,40(sp)
    80003aba:	f022                	sd	s0,32(sp)
    80003abc:	ec26                	sd	s1,24(sp)
    80003abe:	e84a                	sd	s2,16(sp)
    80003ac0:	e44e                	sd	s3,8(sp)
    80003ac2:	e052                	sd	s4,0(sp)
    80003ac4:	1800                	addi	s0,sp,48
    80003ac6:	89aa                	mv	s3,a0
    80003ac8:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003aca:	00026517          	auipc	a0,0x26
    80003ace:	29650513          	addi	a0,a0,662 # 80029d60 <itable>
    80003ad2:	ffffd097          	auipc	ra,0xffffd
    80003ad6:	34e080e7          	jalr	846(ra) # 80000e20 <acquire>
  empty = 0;
    80003ada:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003adc:	00026497          	auipc	s1,0x26
    80003ae0:	29c48493          	addi	s1,s1,668 # 80029d78 <itable+0x18>
    80003ae4:	00028697          	auipc	a3,0x28
    80003ae8:	d2468693          	addi	a3,a3,-732 # 8002b808 <log>
    80003aec:	a039                	j	80003afa <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003aee:	02090b63          	beqz	s2,80003b24 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003af2:	08848493          	addi	s1,s1,136
    80003af6:	02d48a63          	beq	s1,a3,80003b2a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003afa:	449c                	lw	a5,8(s1)
    80003afc:	fef059e3          	blez	a5,80003aee <iget+0x38>
    80003b00:	4098                	lw	a4,0(s1)
    80003b02:	ff3716e3          	bne	a4,s3,80003aee <iget+0x38>
    80003b06:	40d8                	lw	a4,4(s1)
    80003b08:	ff4713e3          	bne	a4,s4,80003aee <iget+0x38>
      ip->ref++;
    80003b0c:	2785                	addiw	a5,a5,1
    80003b0e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003b10:	00026517          	auipc	a0,0x26
    80003b14:	25050513          	addi	a0,a0,592 # 80029d60 <itable>
    80003b18:	ffffd097          	auipc	ra,0xffffd
    80003b1c:	3bc080e7          	jalr	956(ra) # 80000ed4 <release>
      return ip;
    80003b20:	8926                	mv	s2,s1
    80003b22:	a03d                	j	80003b50 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b24:	f7f9                	bnez	a5,80003af2 <iget+0x3c>
      empty = ip;
    80003b26:	8926                	mv	s2,s1
    80003b28:	b7e9                	j	80003af2 <iget+0x3c>
  if(empty == 0)
    80003b2a:	02090c63          	beqz	s2,80003b62 <iget+0xac>
  ip->dev = dev;
    80003b2e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003b32:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003b36:	4785                	li	a5,1
    80003b38:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003b3c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003b40:	00026517          	auipc	a0,0x26
    80003b44:	22050513          	addi	a0,a0,544 # 80029d60 <itable>
    80003b48:	ffffd097          	auipc	ra,0xffffd
    80003b4c:	38c080e7          	jalr	908(ra) # 80000ed4 <release>
}
    80003b50:	854a                	mv	a0,s2
    80003b52:	70a2                	ld	ra,40(sp)
    80003b54:	7402                	ld	s0,32(sp)
    80003b56:	64e2                	ld	s1,24(sp)
    80003b58:	6942                	ld	s2,16(sp)
    80003b5a:	69a2                	ld	s3,8(sp)
    80003b5c:	6a02                	ld	s4,0(sp)
    80003b5e:	6145                	addi	sp,sp,48
    80003b60:	8082                	ret
    panic("iget: no inodes");
    80003b62:	00005517          	auipc	a0,0x5
    80003b66:	a3e50513          	addi	a0,a0,-1474 # 800085a0 <__func__.1+0x598>
    80003b6a:	ffffd097          	auipc	ra,0xffffd
    80003b6e:	9f6080e7          	jalr	-1546(ra) # 80000560 <panic>

0000000080003b72 <fsinit>:
fsinit(int dev) {
    80003b72:	7179                	addi	sp,sp,-48
    80003b74:	f406                	sd	ra,40(sp)
    80003b76:	f022                	sd	s0,32(sp)
    80003b78:	ec26                	sd	s1,24(sp)
    80003b7a:	e84a                	sd	s2,16(sp)
    80003b7c:	e44e                	sd	s3,8(sp)
    80003b7e:	1800                	addi	s0,sp,48
    80003b80:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b82:	4585                	li	a1,1
    80003b84:	00000097          	auipc	ra,0x0
    80003b88:	a3e080e7          	jalr	-1474(ra) # 800035c2 <bread>
    80003b8c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b8e:	00026997          	auipc	s3,0x26
    80003b92:	1b298993          	addi	s3,s3,434 # 80029d40 <sb>
    80003b96:	02000613          	li	a2,32
    80003b9a:	05850593          	addi	a1,a0,88
    80003b9e:	854e                	mv	a0,s3
    80003ba0:	ffffd097          	auipc	ra,0xffffd
    80003ba4:	3d8080e7          	jalr	984(ra) # 80000f78 <memmove>
  brelse(bp);
    80003ba8:	8526                	mv	a0,s1
    80003baa:	00000097          	auipc	ra,0x0
    80003bae:	b48080e7          	jalr	-1208(ra) # 800036f2 <brelse>
  if(sb.magic != FSMAGIC)
    80003bb2:	0009a703          	lw	a4,0(s3)
    80003bb6:	102037b7          	lui	a5,0x10203
    80003bba:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003bbe:	02f71263          	bne	a4,a5,80003be2 <fsinit+0x70>
  initlog(dev, &sb);
    80003bc2:	00026597          	auipc	a1,0x26
    80003bc6:	17e58593          	addi	a1,a1,382 # 80029d40 <sb>
    80003bca:	854a                	mv	a0,s2
    80003bcc:	00001097          	auipc	ra,0x1
    80003bd0:	b60080e7          	jalr	-1184(ra) # 8000472c <initlog>
}
    80003bd4:	70a2                	ld	ra,40(sp)
    80003bd6:	7402                	ld	s0,32(sp)
    80003bd8:	64e2                	ld	s1,24(sp)
    80003bda:	6942                	ld	s2,16(sp)
    80003bdc:	69a2                	ld	s3,8(sp)
    80003bde:	6145                	addi	sp,sp,48
    80003be0:	8082                	ret
    panic("invalid file system");
    80003be2:	00005517          	auipc	a0,0x5
    80003be6:	9ce50513          	addi	a0,a0,-1586 # 800085b0 <__func__.1+0x5a8>
    80003bea:	ffffd097          	auipc	ra,0xffffd
    80003bee:	976080e7          	jalr	-1674(ra) # 80000560 <panic>

0000000080003bf2 <iinit>:
{
    80003bf2:	7179                	addi	sp,sp,-48
    80003bf4:	f406                	sd	ra,40(sp)
    80003bf6:	f022                	sd	s0,32(sp)
    80003bf8:	ec26                	sd	s1,24(sp)
    80003bfa:	e84a                	sd	s2,16(sp)
    80003bfc:	e44e                	sd	s3,8(sp)
    80003bfe:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003c00:	00005597          	auipc	a1,0x5
    80003c04:	9c858593          	addi	a1,a1,-1592 # 800085c8 <__func__.1+0x5c0>
    80003c08:	00026517          	auipc	a0,0x26
    80003c0c:	15850513          	addi	a0,a0,344 # 80029d60 <itable>
    80003c10:	ffffd097          	auipc	ra,0xffffd
    80003c14:	180080e7          	jalr	384(ra) # 80000d90 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003c18:	00026497          	auipc	s1,0x26
    80003c1c:	17048493          	addi	s1,s1,368 # 80029d88 <itable+0x28>
    80003c20:	00028997          	auipc	s3,0x28
    80003c24:	bf898993          	addi	s3,s3,-1032 # 8002b818 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003c28:	00005917          	auipc	s2,0x5
    80003c2c:	9a890913          	addi	s2,s2,-1624 # 800085d0 <__func__.1+0x5c8>
    80003c30:	85ca                	mv	a1,s2
    80003c32:	8526                	mv	a0,s1
    80003c34:	00001097          	auipc	ra,0x1
    80003c38:	e4c080e7          	jalr	-436(ra) # 80004a80 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003c3c:	08848493          	addi	s1,s1,136
    80003c40:	ff3498e3          	bne	s1,s3,80003c30 <iinit+0x3e>
}
    80003c44:	70a2                	ld	ra,40(sp)
    80003c46:	7402                	ld	s0,32(sp)
    80003c48:	64e2                	ld	s1,24(sp)
    80003c4a:	6942                	ld	s2,16(sp)
    80003c4c:	69a2                	ld	s3,8(sp)
    80003c4e:	6145                	addi	sp,sp,48
    80003c50:	8082                	ret

0000000080003c52 <ialloc>:
{
    80003c52:	7139                	addi	sp,sp,-64
    80003c54:	fc06                	sd	ra,56(sp)
    80003c56:	f822                	sd	s0,48(sp)
    80003c58:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c5a:	00026717          	auipc	a4,0x26
    80003c5e:	0f272703          	lw	a4,242(a4) # 80029d4c <sb+0xc>
    80003c62:	4785                	li	a5,1
    80003c64:	06e7f463          	bgeu	a5,a4,80003ccc <ialloc+0x7a>
    80003c68:	f426                	sd	s1,40(sp)
    80003c6a:	f04a                	sd	s2,32(sp)
    80003c6c:	ec4e                	sd	s3,24(sp)
    80003c6e:	e852                	sd	s4,16(sp)
    80003c70:	e456                	sd	s5,8(sp)
    80003c72:	e05a                	sd	s6,0(sp)
    80003c74:	8aaa                	mv	s5,a0
    80003c76:	8b2e                	mv	s6,a1
    80003c78:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003c7a:	00026a17          	auipc	s4,0x26
    80003c7e:	0c6a0a13          	addi	s4,s4,198 # 80029d40 <sb>
    80003c82:	00495593          	srli	a1,s2,0x4
    80003c86:	018a2783          	lw	a5,24(s4)
    80003c8a:	9dbd                	addw	a1,a1,a5
    80003c8c:	8556                	mv	a0,s5
    80003c8e:	00000097          	auipc	ra,0x0
    80003c92:	934080e7          	jalr	-1740(ra) # 800035c2 <bread>
    80003c96:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003c98:	05850993          	addi	s3,a0,88
    80003c9c:	00f97793          	andi	a5,s2,15
    80003ca0:	079a                	slli	a5,a5,0x6
    80003ca2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003ca4:	00099783          	lh	a5,0(s3)
    80003ca8:	cf9d                	beqz	a5,80003ce6 <ialloc+0x94>
    brelse(bp);
    80003caa:	00000097          	auipc	ra,0x0
    80003cae:	a48080e7          	jalr	-1464(ra) # 800036f2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003cb2:	0905                	addi	s2,s2,1
    80003cb4:	00ca2703          	lw	a4,12(s4)
    80003cb8:	0009079b          	sext.w	a5,s2
    80003cbc:	fce7e3e3          	bltu	a5,a4,80003c82 <ialloc+0x30>
    80003cc0:	74a2                	ld	s1,40(sp)
    80003cc2:	7902                	ld	s2,32(sp)
    80003cc4:	69e2                	ld	s3,24(sp)
    80003cc6:	6a42                	ld	s4,16(sp)
    80003cc8:	6aa2                	ld	s5,8(sp)
    80003cca:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003ccc:	00005517          	auipc	a0,0x5
    80003cd0:	90c50513          	addi	a0,a0,-1780 # 800085d8 <__func__.1+0x5d0>
    80003cd4:	ffffd097          	auipc	ra,0xffffd
    80003cd8:	8e8080e7          	jalr	-1816(ra) # 800005bc <printf>
  return 0;
    80003cdc:	4501                	li	a0,0
}
    80003cde:	70e2                	ld	ra,56(sp)
    80003ce0:	7442                	ld	s0,48(sp)
    80003ce2:	6121                	addi	sp,sp,64
    80003ce4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003ce6:	04000613          	li	a2,64
    80003cea:	4581                	li	a1,0
    80003cec:	854e                	mv	a0,s3
    80003cee:	ffffd097          	auipc	ra,0xffffd
    80003cf2:	22e080e7          	jalr	558(ra) # 80000f1c <memset>
      dip->type = type;
    80003cf6:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003cfa:	8526                	mv	a0,s1
    80003cfc:	00001097          	auipc	ra,0x1
    80003d00:	ca0080e7          	jalr	-864(ra) # 8000499c <log_write>
      brelse(bp);
    80003d04:	8526                	mv	a0,s1
    80003d06:	00000097          	auipc	ra,0x0
    80003d0a:	9ec080e7          	jalr	-1556(ra) # 800036f2 <brelse>
      return iget(dev, inum);
    80003d0e:	0009059b          	sext.w	a1,s2
    80003d12:	8556                	mv	a0,s5
    80003d14:	00000097          	auipc	ra,0x0
    80003d18:	da2080e7          	jalr	-606(ra) # 80003ab6 <iget>
    80003d1c:	74a2                	ld	s1,40(sp)
    80003d1e:	7902                	ld	s2,32(sp)
    80003d20:	69e2                	ld	s3,24(sp)
    80003d22:	6a42                	ld	s4,16(sp)
    80003d24:	6aa2                	ld	s5,8(sp)
    80003d26:	6b02                	ld	s6,0(sp)
    80003d28:	bf5d                	j	80003cde <ialloc+0x8c>

0000000080003d2a <iupdate>:
{
    80003d2a:	1101                	addi	sp,sp,-32
    80003d2c:	ec06                	sd	ra,24(sp)
    80003d2e:	e822                	sd	s0,16(sp)
    80003d30:	e426                	sd	s1,8(sp)
    80003d32:	e04a                	sd	s2,0(sp)
    80003d34:	1000                	addi	s0,sp,32
    80003d36:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d38:	415c                	lw	a5,4(a0)
    80003d3a:	0047d79b          	srliw	a5,a5,0x4
    80003d3e:	00026597          	auipc	a1,0x26
    80003d42:	01a5a583          	lw	a1,26(a1) # 80029d58 <sb+0x18>
    80003d46:	9dbd                	addw	a1,a1,a5
    80003d48:	4108                	lw	a0,0(a0)
    80003d4a:	00000097          	auipc	ra,0x0
    80003d4e:	878080e7          	jalr	-1928(ra) # 800035c2 <bread>
    80003d52:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d54:	05850793          	addi	a5,a0,88
    80003d58:	40d8                	lw	a4,4(s1)
    80003d5a:	8b3d                	andi	a4,a4,15
    80003d5c:	071a                	slli	a4,a4,0x6
    80003d5e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003d60:	04449703          	lh	a4,68(s1)
    80003d64:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003d68:	04649703          	lh	a4,70(s1)
    80003d6c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003d70:	04849703          	lh	a4,72(s1)
    80003d74:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003d78:	04a49703          	lh	a4,74(s1)
    80003d7c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003d80:	44f8                	lw	a4,76(s1)
    80003d82:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003d84:	03400613          	li	a2,52
    80003d88:	05048593          	addi	a1,s1,80
    80003d8c:	00c78513          	addi	a0,a5,12
    80003d90:	ffffd097          	auipc	ra,0xffffd
    80003d94:	1e8080e7          	jalr	488(ra) # 80000f78 <memmove>
  log_write(bp);
    80003d98:	854a                	mv	a0,s2
    80003d9a:	00001097          	auipc	ra,0x1
    80003d9e:	c02080e7          	jalr	-1022(ra) # 8000499c <log_write>
  brelse(bp);
    80003da2:	854a                	mv	a0,s2
    80003da4:	00000097          	auipc	ra,0x0
    80003da8:	94e080e7          	jalr	-1714(ra) # 800036f2 <brelse>
}
    80003dac:	60e2                	ld	ra,24(sp)
    80003dae:	6442                	ld	s0,16(sp)
    80003db0:	64a2                	ld	s1,8(sp)
    80003db2:	6902                	ld	s2,0(sp)
    80003db4:	6105                	addi	sp,sp,32
    80003db6:	8082                	ret

0000000080003db8 <idup>:
{
    80003db8:	1101                	addi	sp,sp,-32
    80003dba:	ec06                	sd	ra,24(sp)
    80003dbc:	e822                	sd	s0,16(sp)
    80003dbe:	e426                	sd	s1,8(sp)
    80003dc0:	1000                	addi	s0,sp,32
    80003dc2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003dc4:	00026517          	auipc	a0,0x26
    80003dc8:	f9c50513          	addi	a0,a0,-100 # 80029d60 <itable>
    80003dcc:	ffffd097          	auipc	ra,0xffffd
    80003dd0:	054080e7          	jalr	84(ra) # 80000e20 <acquire>
  ip->ref++;
    80003dd4:	449c                	lw	a5,8(s1)
    80003dd6:	2785                	addiw	a5,a5,1
    80003dd8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003dda:	00026517          	auipc	a0,0x26
    80003dde:	f8650513          	addi	a0,a0,-122 # 80029d60 <itable>
    80003de2:	ffffd097          	auipc	ra,0xffffd
    80003de6:	0f2080e7          	jalr	242(ra) # 80000ed4 <release>
}
    80003dea:	8526                	mv	a0,s1
    80003dec:	60e2                	ld	ra,24(sp)
    80003dee:	6442                	ld	s0,16(sp)
    80003df0:	64a2                	ld	s1,8(sp)
    80003df2:	6105                	addi	sp,sp,32
    80003df4:	8082                	ret

0000000080003df6 <ilock>:
{
    80003df6:	1101                	addi	sp,sp,-32
    80003df8:	ec06                	sd	ra,24(sp)
    80003dfa:	e822                	sd	s0,16(sp)
    80003dfc:	e426                	sd	s1,8(sp)
    80003dfe:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003e00:	c10d                	beqz	a0,80003e22 <ilock+0x2c>
    80003e02:	84aa                	mv	s1,a0
    80003e04:	451c                	lw	a5,8(a0)
    80003e06:	00f05e63          	blez	a5,80003e22 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003e0a:	0541                	addi	a0,a0,16
    80003e0c:	00001097          	auipc	ra,0x1
    80003e10:	cae080e7          	jalr	-850(ra) # 80004aba <acquiresleep>
  if(ip->valid == 0){
    80003e14:	40bc                	lw	a5,64(s1)
    80003e16:	cf99                	beqz	a5,80003e34 <ilock+0x3e>
}
    80003e18:	60e2                	ld	ra,24(sp)
    80003e1a:	6442                	ld	s0,16(sp)
    80003e1c:	64a2                	ld	s1,8(sp)
    80003e1e:	6105                	addi	sp,sp,32
    80003e20:	8082                	ret
    80003e22:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003e24:	00004517          	auipc	a0,0x4
    80003e28:	7cc50513          	addi	a0,a0,1996 # 800085f0 <__func__.1+0x5e8>
    80003e2c:	ffffc097          	auipc	ra,0xffffc
    80003e30:	734080e7          	jalr	1844(ra) # 80000560 <panic>
    80003e34:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e36:	40dc                	lw	a5,4(s1)
    80003e38:	0047d79b          	srliw	a5,a5,0x4
    80003e3c:	00026597          	auipc	a1,0x26
    80003e40:	f1c5a583          	lw	a1,-228(a1) # 80029d58 <sb+0x18>
    80003e44:	9dbd                	addw	a1,a1,a5
    80003e46:	4088                	lw	a0,0(s1)
    80003e48:	fffff097          	auipc	ra,0xfffff
    80003e4c:	77a080e7          	jalr	1914(ra) # 800035c2 <bread>
    80003e50:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e52:	05850593          	addi	a1,a0,88
    80003e56:	40dc                	lw	a5,4(s1)
    80003e58:	8bbd                	andi	a5,a5,15
    80003e5a:	079a                	slli	a5,a5,0x6
    80003e5c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003e5e:	00059783          	lh	a5,0(a1)
    80003e62:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003e66:	00259783          	lh	a5,2(a1)
    80003e6a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003e6e:	00459783          	lh	a5,4(a1)
    80003e72:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003e76:	00659783          	lh	a5,6(a1)
    80003e7a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003e7e:	459c                	lw	a5,8(a1)
    80003e80:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003e82:	03400613          	li	a2,52
    80003e86:	05b1                	addi	a1,a1,12
    80003e88:	05048513          	addi	a0,s1,80
    80003e8c:	ffffd097          	auipc	ra,0xffffd
    80003e90:	0ec080e7          	jalr	236(ra) # 80000f78 <memmove>
    brelse(bp);
    80003e94:	854a                	mv	a0,s2
    80003e96:	00000097          	auipc	ra,0x0
    80003e9a:	85c080e7          	jalr	-1956(ra) # 800036f2 <brelse>
    ip->valid = 1;
    80003e9e:	4785                	li	a5,1
    80003ea0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003ea2:	04449783          	lh	a5,68(s1)
    80003ea6:	c399                	beqz	a5,80003eac <ilock+0xb6>
    80003ea8:	6902                	ld	s2,0(sp)
    80003eaa:	b7bd                	j	80003e18 <ilock+0x22>
      panic("ilock: no type");
    80003eac:	00004517          	auipc	a0,0x4
    80003eb0:	74c50513          	addi	a0,a0,1868 # 800085f8 <__func__.1+0x5f0>
    80003eb4:	ffffc097          	auipc	ra,0xffffc
    80003eb8:	6ac080e7          	jalr	1708(ra) # 80000560 <panic>

0000000080003ebc <iunlock>:
{
    80003ebc:	1101                	addi	sp,sp,-32
    80003ebe:	ec06                	sd	ra,24(sp)
    80003ec0:	e822                	sd	s0,16(sp)
    80003ec2:	e426                	sd	s1,8(sp)
    80003ec4:	e04a                	sd	s2,0(sp)
    80003ec6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ec8:	c905                	beqz	a0,80003ef8 <iunlock+0x3c>
    80003eca:	84aa                	mv	s1,a0
    80003ecc:	01050913          	addi	s2,a0,16
    80003ed0:	854a                	mv	a0,s2
    80003ed2:	00001097          	auipc	ra,0x1
    80003ed6:	c82080e7          	jalr	-894(ra) # 80004b54 <holdingsleep>
    80003eda:	cd19                	beqz	a0,80003ef8 <iunlock+0x3c>
    80003edc:	449c                	lw	a5,8(s1)
    80003ede:	00f05d63          	blez	a5,80003ef8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ee2:	854a                	mv	a0,s2
    80003ee4:	00001097          	auipc	ra,0x1
    80003ee8:	c2c080e7          	jalr	-980(ra) # 80004b10 <releasesleep>
}
    80003eec:	60e2                	ld	ra,24(sp)
    80003eee:	6442                	ld	s0,16(sp)
    80003ef0:	64a2                	ld	s1,8(sp)
    80003ef2:	6902                	ld	s2,0(sp)
    80003ef4:	6105                	addi	sp,sp,32
    80003ef6:	8082                	ret
    panic("iunlock");
    80003ef8:	00004517          	auipc	a0,0x4
    80003efc:	71050513          	addi	a0,a0,1808 # 80008608 <__func__.1+0x600>
    80003f00:	ffffc097          	auipc	ra,0xffffc
    80003f04:	660080e7          	jalr	1632(ra) # 80000560 <panic>

0000000080003f08 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003f08:	7179                	addi	sp,sp,-48
    80003f0a:	f406                	sd	ra,40(sp)
    80003f0c:	f022                	sd	s0,32(sp)
    80003f0e:	ec26                	sd	s1,24(sp)
    80003f10:	e84a                	sd	s2,16(sp)
    80003f12:	e44e                	sd	s3,8(sp)
    80003f14:	1800                	addi	s0,sp,48
    80003f16:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003f18:	05050493          	addi	s1,a0,80
    80003f1c:	08050913          	addi	s2,a0,128
    80003f20:	a021                	j	80003f28 <itrunc+0x20>
    80003f22:	0491                	addi	s1,s1,4
    80003f24:	01248d63          	beq	s1,s2,80003f3e <itrunc+0x36>
    if(ip->addrs[i]){
    80003f28:	408c                	lw	a1,0(s1)
    80003f2a:	dde5                	beqz	a1,80003f22 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003f2c:	0009a503          	lw	a0,0(s3)
    80003f30:	00000097          	auipc	ra,0x0
    80003f34:	8d6080e7          	jalr	-1834(ra) # 80003806 <bfree>
      ip->addrs[i] = 0;
    80003f38:	0004a023          	sw	zero,0(s1)
    80003f3c:	b7dd                	j	80003f22 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003f3e:	0809a583          	lw	a1,128(s3)
    80003f42:	ed99                	bnez	a1,80003f60 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003f44:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003f48:	854e                	mv	a0,s3
    80003f4a:	00000097          	auipc	ra,0x0
    80003f4e:	de0080e7          	jalr	-544(ra) # 80003d2a <iupdate>
}
    80003f52:	70a2                	ld	ra,40(sp)
    80003f54:	7402                	ld	s0,32(sp)
    80003f56:	64e2                	ld	s1,24(sp)
    80003f58:	6942                	ld	s2,16(sp)
    80003f5a:	69a2                	ld	s3,8(sp)
    80003f5c:	6145                	addi	sp,sp,48
    80003f5e:	8082                	ret
    80003f60:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003f62:	0009a503          	lw	a0,0(s3)
    80003f66:	fffff097          	auipc	ra,0xfffff
    80003f6a:	65c080e7          	jalr	1628(ra) # 800035c2 <bread>
    80003f6e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003f70:	05850493          	addi	s1,a0,88
    80003f74:	45850913          	addi	s2,a0,1112
    80003f78:	a021                	j	80003f80 <itrunc+0x78>
    80003f7a:	0491                	addi	s1,s1,4
    80003f7c:	01248b63          	beq	s1,s2,80003f92 <itrunc+0x8a>
      if(a[j])
    80003f80:	408c                	lw	a1,0(s1)
    80003f82:	dde5                	beqz	a1,80003f7a <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003f84:	0009a503          	lw	a0,0(s3)
    80003f88:	00000097          	auipc	ra,0x0
    80003f8c:	87e080e7          	jalr	-1922(ra) # 80003806 <bfree>
    80003f90:	b7ed                	j	80003f7a <itrunc+0x72>
    brelse(bp);
    80003f92:	8552                	mv	a0,s4
    80003f94:	fffff097          	auipc	ra,0xfffff
    80003f98:	75e080e7          	jalr	1886(ra) # 800036f2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003f9c:	0809a583          	lw	a1,128(s3)
    80003fa0:	0009a503          	lw	a0,0(s3)
    80003fa4:	00000097          	auipc	ra,0x0
    80003fa8:	862080e7          	jalr	-1950(ra) # 80003806 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003fac:	0809a023          	sw	zero,128(s3)
    80003fb0:	6a02                	ld	s4,0(sp)
    80003fb2:	bf49                	j	80003f44 <itrunc+0x3c>

0000000080003fb4 <iput>:
{
    80003fb4:	1101                	addi	sp,sp,-32
    80003fb6:	ec06                	sd	ra,24(sp)
    80003fb8:	e822                	sd	s0,16(sp)
    80003fba:	e426                	sd	s1,8(sp)
    80003fbc:	1000                	addi	s0,sp,32
    80003fbe:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003fc0:	00026517          	auipc	a0,0x26
    80003fc4:	da050513          	addi	a0,a0,-608 # 80029d60 <itable>
    80003fc8:	ffffd097          	auipc	ra,0xffffd
    80003fcc:	e58080e7          	jalr	-424(ra) # 80000e20 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003fd0:	4498                	lw	a4,8(s1)
    80003fd2:	4785                	li	a5,1
    80003fd4:	02f70263          	beq	a4,a5,80003ff8 <iput+0x44>
  ip->ref--;
    80003fd8:	449c                	lw	a5,8(s1)
    80003fda:	37fd                	addiw	a5,a5,-1
    80003fdc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003fde:	00026517          	auipc	a0,0x26
    80003fe2:	d8250513          	addi	a0,a0,-638 # 80029d60 <itable>
    80003fe6:	ffffd097          	auipc	ra,0xffffd
    80003fea:	eee080e7          	jalr	-274(ra) # 80000ed4 <release>
}
    80003fee:	60e2                	ld	ra,24(sp)
    80003ff0:	6442                	ld	s0,16(sp)
    80003ff2:	64a2                	ld	s1,8(sp)
    80003ff4:	6105                	addi	sp,sp,32
    80003ff6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ff8:	40bc                	lw	a5,64(s1)
    80003ffa:	dff9                	beqz	a5,80003fd8 <iput+0x24>
    80003ffc:	04a49783          	lh	a5,74(s1)
    80004000:	ffe1                	bnez	a5,80003fd8 <iput+0x24>
    80004002:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80004004:	01048913          	addi	s2,s1,16
    80004008:	854a                	mv	a0,s2
    8000400a:	00001097          	auipc	ra,0x1
    8000400e:	ab0080e7          	jalr	-1360(ra) # 80004aba <acquiresleep>
    release(&itable.lock);
    80004012:	00026517          	auipc	a0,0x26
    80004016:	d4e50513          	addi	a0,a0,-690 # 80029d60 <itable>
    8000401a:	ffffd097          	auipc	ra,0xffffd
    8000401e:	eba080e7          	jalr	-326(ra) # 80000ed4 <release>
    itrunc(ip);
    80004022:	8526                	mv	a0,s1
    80004024:	00000097          	auipc	ra,0x0
    80004028:	ee4080e7          	jalr	-284(ra) # 80003f08 <itrunc>
    ip->type = 0;
    8000402c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004030:	8526                	mv	a0,s1
    80004032:	00000097          	auipc	ra,0x0
    80004036:	cf8080e7          	jalr	-776(ra) # 80003d2a <iupdate>
    ip->valid = 0;
    8000403a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000403e:	854a                	mv	a0,s2
    80004040:	00001097          	auipc	ra,0x1
    80004044:	ad0080e7          	jalr	-1328(ra) # 80004b10 <releasesleep>
    acquire(&itable.lock);
    80004048:	00026517          	auipc	a0,0x26
    8000404c:	d1850513          	addi	a0,a0,-744 # 80029d60 <itable>
    80004050:	ffffd097          	auipc	ra,0xffffd
    80004054:	dd0080e7          	jalr	-560(ra) # 80000e20 <acquire>
    80004058:	6902                	ld	s2,0(sp)
    8000405a:	bfbd                	j	80003fd8 <iput+0x24>

000000008000405c <iunlockput>:
{
    8000405c:	1101                	addi	sp,sp,-32
    8000405e:	ec06                	sd	ra,24(sp)
    80004060:	e822                	sd	s0,16(sp)
    80004062:	e426                	sd	s1,8(sp)
    80004064:	1000                	addi	s0,sp,32
    80004066:	84aa                	mv	s1,a0
  iunlock(ip);
    80004068:	00000097          	auipc	ra,0x0
    8000406c:	e54080e7          	jalr	-428(ra) # 80003ebc <iunlock>
  iput(ip);
    80004070:	8526                	mv	a0,s1
    80004072:	00000097          	auipc	ra,0x0
    80004076:	f42080e7          	jalr	-190(ra) # 80003fb4 <iput>
}
    8000407a:	60e2                	ld	ra,24(sp)
    8000407c:	6442                	ld	s0,16(sp)
    8000407e:	64a2                	ld	s1,8(sp)
    80004080:	6105                	addi	sp,sp,32
    80004082:	8082                	ret

0000000080004084 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004084:	1141                	addi	sp,sp,-16
    80004086:	e422                	sd	s0,8(sp)
    80004088:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000408a:	411c                	lw	a5,0(a0)
    8000408c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000408e:	415c                	lw	a5,4(a0)
    80004090:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004092:	04451783          	lh	a5,68(a0)
    80004096:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000409a:	04a51783          	lh	a5,74(a0)
    8000409e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800040a2:	04c56783          	lwu	a5,76(a0)
    800040a6:	e99c                	sd	a5,16(a1)
}
    800040a8:	6422                	ld	s0,8(sp)
    800040aa:	0141                	addi	sp,sp,16
    800040ac:	8082                	ret

00000000800040ae <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040ae:	457c                	lw	a5,76(a0)
    800040b0:	10d7e563          	bltu	a5,a3,800041ba <readi+0x10c>
{
    800040b4:	7159                	addi	sp,sp,-112
    800040b6:	f486                	sd	ra,104(sp)
    800040b8:	f0a2                	sd	s0,96(sp)
    800040ba:	eca6                	sd	s1,88(sp)
    800040bc:	e0d2                	sd	s4,64(sp)
    800040be:	fc56                	sd	s5,56(sp)
    800040c0:	f85a                	sd	s6,48(sp)
    800040c2:	f45e                	sd	s7,40(sp)
    800040c4:	1880                	addi	s0,sp,112
    800040c6:	8b2a                	mv	s6,a0
    800040c8:	8bae                	mv	s7,a1
    800040ca:	8a32                	mv	s4,a2
    800040cc:	84b6                	mv	s1,a3
    800040ce:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800040d0:	9f35                	addw	a4,a4,a3
    return 0;
    800040d2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800040d4:	0cd76a63          	bltu	a4,a3,800041a8 <readi+0xfa>
    800040d8:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800040da:	00e7f463          	bgeu	a5,a4,800040e2 <readi+0x34>
    n = ip->size - off;
    800040de:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040e2:	0a0a8963          	beqz	s5,80004194 <readi+0xe6>
    800040e6:	e8ca                	sd	s2,80(sp)
    800040e8:	f062                	sd	s8,32(sp)
    800040ea:	ec66                	sd	s9,24(sp)
    800040ec:	e86a                	sd	s10,16(sp)
    800040ee:	e46e                	sd	s11,8(sp)
    800040f0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800040f2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800040f6:	5c7d                	li	s8,-1
    800040f8:	a82d                	j	80004132 <readi+0x84>
    800040fa:	020d1d93          	slli	s11,s10,0x20
    800040fe:	020ddd93          	srli	s11,s11,0x20
    80004102:	05890613          	addi	a2,s2,88
    80004106:	86ee                	mv	a3,s11
    80004108:	963a                	add	a2,a2,a4
    8000410a:	85d2                	mv	a1,s4
    8000410c:	855e                	mv	a0,s7
    8000410e:	ffffe097          	auipc	ra,0xffffe
    80004112:	7d0080e7          	jalr	2000(ra) # 800028de <either_copyout>
    80004116:	05850d63          	beq	a0,s8,80004170 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000411a:	854a                	mv	a0,s2
    8000411c:	fffff097          	auipc	ra,0xfffff
    80004120:	5d6080e7          	jalr	1494(ra) # 800036f2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004124:	013d09bb          	addw	s3,s10,s3
    80004128:	009d04bb          	addw	s1,s10,s1
    8000412c:	9a6e                	add	s4,s4,s11
    8000412e:	0559fd63          	bgeu	s3,s5,80004188 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80004132:	00a4d59b          	srliw	a1,s1,0xa
    80004136:	855a                	mv	a0,s6
    80004138:	00000097          	auipc	ra,0x0
    8000413c:	88e080e7          	jalr	-1906(ra) # 800039c6 <bmap>
    80004140:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004144:	c9b1                	beqz	a1,80004198 <readi+0xea>
    bp = bread(ip->dev, addr);
    80004146:	000b2503          	lw	a0,0(s6)
    8000414a:	fffff097          	auipc	ra,0xfffff
    8000414e:	478080e7          	jalr	1144(ra) # 800035c2 <bread>
    80004152:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004154:	3ff4f713          	andi	a4,s1,1023
    80004158:	40ec87bb          	subw	a5,s9,a4
    8000415c:	413a86bb          	subw	a3,s5,s3
    80004160:	8d3e                	mv	s10,a5
    80004162:	2781                	sext.w	a5,a5
    80004164:	0006861b          	sext.w	a2,a3
    80004168:	f8f679e3          	bgeu	a2,a5,800040fa <readi+0x4c>
    8000416c:	8d36                	mv	s10,a3
    8000416e:	b771                	j	800040fa <readi+0x4c>
      brelse(bp);
    80004170:	854a                	mv	a0,s2
    80004172:	fffff097          	auipc	ra,0xfffff
    80004176:	580080e7          	jalr	1408(ra) # 800036f2 <brelse>
      tot = -1;
    8000417a:	59fd                	li	s3,-1
      break;
    8000417c:	6946                	ld	s2,80(sp)
    8000417e:	7c02                	ld	s8,32(sp)
    80004180:	6ce2                	ld	s9,24(sp)
    80004182:	6d42                	ld	s10,16(sp)
    80004184:	6da2                	ld	s11,8(sp)
    80004186:	a831                	j	800041a2 <readi+0xf4>
    80004188:	6946                	ld	s2,80(sp)
    8000418a:	7c02                	ld	s8,32(sp)
    8000418c:	6ce2                	ld	s9,24(sp)
    8000418e:	6d42                	ld	s10,16(sp)
    80004190:	6da2                	ld	s11,8(sp)
    80004192:	a801                	j	800041a2 <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004194:	89d6                	mv	s3,s5
    80004196:	a031                	j	800041a2 <readi+0xf4>
    80004198:	6946                	ld	s2,80(sp)
    8000419a:	7c02                	ld	s8,32(sp)
    8000419c:	6ce2                	ld	s9,24(sp)
    8000419e:	6d42                	ld	s10,16(sp)
    800041a0:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800041a2:	0009851b          	sext.w	a0,s3
    800041a6:	69a6                	ld	s3,72(sp)
}
    800041a8:	70a6                	ld	ra,104(sp)
    800041aa:	7406                	ld	s0,96(sp)
    800041ac:	64e6                	ld	s1,88(sp)
    800041ae:	6a06                	ld	s4,64(sp)
    800041b0:	7ae2                	ld	s5,56(sp)
    800041b2:	7b42                	ld	s6,48(sp)
    800041b4:	7ba2                	ld	s7,40(sp)
    800041b6:	6165                	addi	sp,sp,112
    800041b8:	8082                	ret
    return 0;
    800041ba:	4501                	li	a0,0
}
    800041bc:	8082                	ret

00000000800041be <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800041be:	457c                	lw	a5,76(a0)
    800041c0:	10d7ee63          	bltu	a5,a3,800042dc <writei+0x11e>
{
    800041c4:	7159                	addi	sp,sp,-112
    800041c6:	f486                	sd	ra,104(sp)
    800041c8:	f0a2                	sd	s0,96(sp)
    800041ca:	e8ca                	sd	s2,80(sp)
    800041cc:	e0d2                	sd	s4,64(sp)
    800041ce:	fc56                	sd	s5,56(sp)
    800041d0:	f85a                	sd	s6,48(sp)
    800041d2:	f45e                	sd	s7,40(sp)
    800041d4:	1880                	addi	s0,sp,112
    800041d6:	8aaa                	mv	s5,a0
    800041d8:	8bae                	mv	s7,a1
    800041da:	8a32                	mv	s4,a2
    800041dc:	8936                	mv	s2,a3
    800041de:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800041e0:	00e687bb          	addw	a5,a3,a4
    800041e4:	0ed7ee63          	bltu	a5,a3,800042e0 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800041e8:	00043737          	lui	a4,0x43
    800041ec:	0ef76c63          	bltu	a4,a5,800042e4 <writei+0x126>
    800041f0:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041f2:	0c0b0d63          	beqz	s6,800042cc <writei+0x10e>
    800041f6:	eca6                	sd	s1,88(sp)
    800041f8:	f062                	sd	s8,32(sp)
    800041fa:	ec66                	sd	s9,24(sp)
    800041fc:	e86a                	sd	s10,16(sp)
    800041fe:	e46e                	sd	s11,8(sp)
    80004200:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004202:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004206:	5c7d                	li	s8,-1
    80004208:	a091                	j	8000424c <writei+0x8e>
    8000420a:	020d1d93          	slli	s11,s10,0x20
    8000420e:	020ddd93          	srli	s11,s11,0x20
    80004212:	05848513          	addi	a0,s1,88
    80004216:	86ee                	mv	a3,s11
    80004218:	8652                	mv	a2,s4
    8000421a:	85de                	mv	a1,s7
    8000421c:	953a                	add	a0,a0,a4
    8000421e:	ffffe097          	auipc	ra,0xffffe
    80004222:	716080e7          	jalr	1814(ra) # 80002934 <either_copyin>
    80004226:	07850263          	beq	a0,s8,8000428a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000422a:	8526                	mv	a0,s1
    8000422c:	00000097          	auipc	ra,0x0
    80004230:	770080e7          	jalr	1904(ra) # 8000499c <log_write>
    brelse(bp);
    80004234:	8526                	mv	a0,s1
    80004236:	fffff097          	auipc	ra,0xfffff
    8000423a:	4bc080e7          	jalr	1212(ra) # 800036f2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000423e:	013d09bb          	addw	s3,s10,s3
    80004242:	012d093b          	addw	s2,s10,s2
    80004246:	9a6e                	add	s4,s4,s11
    80004248:	0569f663          	bgeu	s3,s6,80004294 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000424c:	00a9559b          	srliw	a1,s2,0xa
    80004250:	8556                	mv	a0,s5
    80004252:	fffff097          	auipc	ra,0xfffff
    80004256:	774080e7          	jalr	1908(ra) # 800039c6 <bmap>
    8000425a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000425e:	c99d                	beqz	a1,80004294 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004260:	000aa503          	lw	a0,0(s5)
    80004264:	fffff097          	auipc	ra,0xfffff
    80004268:	35e080e7          	jalr	862(ra) # 800035c2 <bread>
    8000426c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000426e:	3ff97713          	andi	a4,s2,1023
    80004272:	40ec87bb          	subw	a5,s9,a4
    80004276:	413b06bb          	subw	a3,s6,s3
    8000427a:	8d3e                	mv	s10,a5
    8000427c:	2781                	sext.w	a5,a5
    8000427e:	0006861b          	sext.w	a2,a3
    80004282:	f8f674e3          	bgeu	a2,a5,8000420a <writei+0x4c>
    80004286:	8d36                	mv	s10,a3
    80004288:	b749                	j	8000420a <writei+0x4c>
      brelse(bp);
    8000428a:	8526                	mv	a0,s1
    8000428c:	fffff097          	auipc	ra,0xfffff
    80004290:	466080e7          	jalr	1126(ra) # 800036f2 <brelse>
  }

  if(off > ip->size)
    80004294:	04caa783          	lw	a5,76(s5)
    80004298:	0327fc63          	bgeu	a5,s2,800042d0 <writei+0x112>
    ip->size = off;
    8000429c:	052aa623          	sw	s2,76(s5)
    800042a0:	64e6                	ld	s1,88(sp)
    800042a2:	7c02                	ld	s8,32(sp)
    800042a4:	6ce2                	ld	s9,24(sp)
    800042a6:	6d42                	ld	s10,16(sp)
    800042a8:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800042aa:	8556                	mv	a0,s5
    800042ac:	00000097          	auipc	ra,0x0
    800042b0:	a7e080e7          	jalr	-1410(ra) # 80003d2a <iupdate>

  return tot;
    800042b4:	0009851b          	sext.w	a0,s3
    800042b8:	69a6                	ld	s3,72(sp)
}
    800042ba:	70a6                	ld	ra,104(sp)
    800042bc:	7406                	ld	s0,96(sp)
    800042be:	6946                	ld	s2,80(sp)
    800042c0:	6a06                	ld	s4,64(sp)
    800042c2:	7ae2                	ld	s5,56(sp)
    800042c4:	7b42                	ld	s6,48(sp)
    800042c6:	7ba2                	ld	s7,40(sp)
    800042c8:	6165                	addi	sp,sp,112
    800042ca:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800042cc:	89da                	mv	s3,s6
    800042ce:	bff1                	j	800042aa <writei+0xec>
    800042d0:	64e6                	ld	s1,88(sp)
    800042d2:	7c02                	ld	s8,32(sp)
    800042d4:	6ce2                	ld	s9,24(sp)
    800042d6:	6d42                	ld	s10,16(sp)
    800042d8:	6da2                	ld	s11,8(sp)
    800042da:	bfc1                	j	800042aa <writei+0xec>
    return -1;
    800042dc:	557d                	li	a0,-1
}
    800042de:	8082                	ret
    return -1;
    800042e0:	557d                	li	a0,-1
    800042e2:	bfe1                	j	800042ba <writei+0xfc>
    return -1;
    800042e4:	557d                	li	a0,-1
    800042e6:	bfd1                	j	800042ba <writei+0xfc>

00000000800042e8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800042e8:	1141                	addi	sp,sp,-16
    800042ea:	e406                	sd	ra,8(sp)
    800042ec:	e022                	sd	s0,0(sp)
    800042ee:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800042f0:	4639                	li	a2,14
    800042f2:	ffffd097          	auipc	ra,0xffffd
    800042f6:	cfa080e7          	jalr	-774(ra) # 80000fec <strncmp>
}
    800042fa:	60a2                	ld	ra,8(sp)
    800042fc:	6402                	ld	s0,0(sp)
    800042fe:	0141                	addi	sp,sp,16
    80004300:	8082                	ret

0000000080004302 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004302:	7139                	addi	sp,sp,-64
    80004304:	fc06                	sd	ra,56(sp)
    80004306:	f822                	sd	s0,48(sp)
    80004308:	f426                	sd	s1,40(sp)
    8000430a:	f04a                	sd	s2,32(sp)
    8000430c:	ec4e                	sd	s3,24(sp)
    8000430e:	e852                	sd	s4,16(sp)
    80004310:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004312:	04451703          	lh	a4,68(a0)
    80004316:	4785                	li	a5,1
    80004318:	00f71a63          	bne	a4,a5,8000432c <dirlookup+0x2a>
    8000431c:	892a                	mv	s2,a0
    8000431e:	89ae                	mv	s3,a1
    80004320:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004322:	457c                	lw	a5,76(a0)
    80004324:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004326:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004328:	e79d                	bnez	a5,80004356 <dirlookup+0x54>
    8000432a:	a8a5                	j	800043a2 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000432c:	00004517          	auipc	a0,0x4
    80004330:	2e450513          	addi	a0,a0,740 # 80008610 <__func__.1+0x608>
    80004334:	ffffc097          	auipc	ra,0xffffc
    80004338:	22c080e7          	jalr	556(ra) # 80000560 <panic>
      panic("dirlookup read");
    8000433c:	00004517          	auipc	a0,0x4
    80004340:	2ec50513          	addi	a0,a0,748 # 80008628 <__func__.1+0x620>
    80004344:	ffffc097          	auipc	ra,0xffffc
    80004348:	21c080e7          	jalr	540(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000434c:	24c1                	addiw	s1,s1,16
    8000434e:	04c92783          	lw	a5,76(s2)
    80004352:	04f4f763          	bgeu	s1,a5,800043a0 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004356:	4741                	li	a4,16
    80004358:	86a6                	mv	a3,s1
    8000435a:	fc040613          	addi	a2,s0,-64
    8000435e:	4581                	li	a1,0
    80004360:	854a                	mv	a0,s2
    80004362:	00000097          	auipc	ra,0x0
    80004366:	d4c080e7          	jalr	-692(ra) # 800040ae <readi>
    8000436a:	47c1                	li	a5,16
    8000436c:	fcf518e3          	bne	a0,a5,8000433c <dirlookup+0x3a>
    if(de.inum == 0)
    80004370:	fc045783          	lhu	a5,-64(s0)
    80004374:	dfe1                	beqz	a5,8000434c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004376:	fc240593          	addi	a1,s0,-62
    8000437a:	854e                	mv	a0,s3
    8000437c:	00000097          	auipc	ra,0x0
    80004380:	f6c080e7          	jalr	-148(ra) # 800042e8 <namecmp>
    80004384:	f561                	bnez	a0,8000434c <dirlookup+0x4a>
      if(poff)
    80004386:	000a0463          	beqz	s4,8000438e <dirlookup+0x8c>
        *poff = off;
    8000438a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000438e:	fc045583          	lhu	a1,-64(s0)
    80004392:	00092503          	lw	a0,0(s2)
    80004396:	fffff097          	auipc	ra,0xfffff
    8000439a:	720080e7          	jalr	1824(ra) # 80003ab6 <iget>
    8000439e:	a011                	j	800043a2 <dirlookup+0xa0>
  return 0;
    800043a0:	4501                	li	a0,0
}
    800043a2:	70e2                	ld	ra,56(sp)
    800043a4:	7442                	ld	s0,48(sp)
    800043a6:	74a2                	ld	s1,40(sp)
    800043a8:	7902                	ld	s2,32(sp)
    800043aa:	69e2                	ld	s3,24(sp)
    800043ac:	6a42                	ld	s4,16(sp)
    800043ae:	6121                	addi	sp,sp,64
    800043b0:	8082                	ret

00000000800043b2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800043b2:	711d                	addi	sp,sp,-96
    800043b4:	ec86                	sd	ra,88(sp)
    800043b6:	e8a2                	sd	s0,80(sp)
    800043b8:	e4a6                	sd	s1,72(sp)
    800043ba:	e0ca                	sd	s2,64(sp)
    800043bc:	fc4e                	sd	s3,56(sp)
    800043be:	f852                	sd	s4,48(sp)
    800043c0:	f456                	sd	s5,40(sp)
    800043c2:	f05a                	sd	s6,32(sp)
    800043c4:	ec5e                	sd	s7,24(sp)
    800043c6:	e862                	sd	s8,16(sp)
    800043c8:	e466                	sd	s9,8(sp)
    800043ca:	1080                	addi	s0,sp,96
    800043cc:	84aa                	mv	s1,a0
    800043ce:	8b2e                	mv	s6,a1
    800043d0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800043d2:	00054703          	lbu	a4,0(a0)
    800043d6:	02f00793          	li	a5,47
    800043da:	02f70263          	beq	a4,a5,800043fe <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800043de:	ffffe097          	auipc	ra,0xffffe
    800043e2:	946080e7          	jalr	-1722(ra) # 80001d24 <myproc>
    800043e6:	15053503          	ld	a0,336(a0)
    800043ea:	00000097          	auipc	ra,0x0
    800043ee:	9ce080e7          	jalr	-1586(ra) # 80003db8 <idup>
    800043f2:	8a2a                	mv	s4,a0
  while(*path == '/')
    800043f4:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800043f8:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800043fa:	4b85                	li	s7,1
    800043fc:	a875                	j	800044b8 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    800043fe:	4585                	li	a1,1
    80004400:	4505                	li	a0,1
    80004402:	fffff097          	auipc	ra,0xfffff
    80004406:	6b4080e7          	jalr	1716(ra) # 80003ab6 <iget>
    8000440a:	8a2a                	mv	s4,a0
    8000440c:	b7e5                	j	800043f4 <namex+0x42>
      iunlockput(ip);
    8000440e:	8552                	mv	a0,s4
    80004410:	00000097          	auipc	ra,0x0
    80004414:	c4c080e7          	jalr	-948(ra) # 8000405c <iunlockput>
      return 0;
    80004418:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000441a:	8552                	mv	a0,s4
    8000441c:	60e6                	ld	ra,88(sp)
    8000441e:	6446                	ld	s0,80(sp)
    80004420:	64a6                	ld	s1,72(sp)
    80004422:	6906                	ld	s2,64(sp)
    80004424:	79e2                	ld	s3,56(sp)
    80004426:	7a42                	ld	s4,48(sp)
    80004428:	7aa2                	ld	s5,40(sp)
    8000442a:	7b02                	ld	s6,32(sp)
    8000442c:	6be2                	ld	s7,24(sp)
    8000442e:	6c42                	ld	s8,16(sp)
    80004430:	6ca2                	ld	s9,8(sp)
    80004432:	6125                	addi	sp,sp,96
    80004434:	8082                	ret
      iunlock(ip);
    80004436:	8552                	mv	a0,s4
    80004438:	00000097          	auipc	ra,0x0
    8000443c:	a84080e7          	jalr	-1404(ra) # 80003ebc <iunlock>
      return ip;
    80004440:	bfe9                	j	8000441a <namex+0x68>
      iunlockput(ip);
    80004442:	8552                	mv	a0,s4
    80004444:	00000097          	auipc	ra,0x0
    80004448:	c18080e7          	jalr	-1000(ra) # 8000405c <iunlockput>
      return 0;
    8000444c:	8a4e                	mv	s4,s3
    8000444e:	b7f1                	j	8000441a <namex+0x68>
  len = path - s;
    80004450:	40998633          	sub	a2,s3,s1
    80004454:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004458:	099c5863          	bge	s8,s9,800044e8 <namex+0x136>
    memmove(name, s, DIRSIZ);
    8000445c:	4639                	li	a2,14
    8000445e:	85a6                	mv	a1,s1
    80004460:	8556                	mv	a0,s5
    80004462:	ffffd097          	auipc	ra,0xffffd
    80004466:	b16080e7          	jalr	-1258(ra) # 80000f78 <memmove>
    8000446a:	84ce                	mv	s1,s3
  while(*path == '/')
    8000446c:	0004c783          	lbu	a5,0(s1)
    80004470:	01279763          	bne	a5,s2,8000447e <namex+0xcc>
    path++;
    80004474:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004476:	0004c783          	lbu	a5,0(s1)
    8000447a:	ff278de3          	beq	a5,s2,80004474 <namex+0xc2>
    ilock(ip);
    8000447e:	8552                	mv	a0,s4
    80004480:	00000097          	auipc	ra,0x0
    80004484:	976080e7          	jalr	-1674(ra) # 80003df6 <ilock>
    if(ip->type != T_DIR){
    80004488:	044a1783          	lh	a5,68(s4)
    8000448c:	f97791e3          	bne	a5,s7,8000440e <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004490:	000b0563          	beqz	s6,8000449a <namex+0xe8>
    80004494:	0004c783          	lbu	a5,0(s1)
    80004498:	dfd9                	beqz	a5,80004436 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000449a:	4601                	li	a2,0
    8000449c:	85d6                	mv	a1,s5
    8000449e:	8552                	mv	a0,s4
    800044a0:	00000097          	auipc	ra,0x0
    800044a4:	e62080e7          	jalr	-414(ra) # 80004302 <dirlookup>
    800044a8:	89aa                	mv	s3,a0
    800044aa:	dd41                	beqz	a0,80004442 <namex+0x90>
    iunlockput(ip);
    800044ac:	8552                	mv	a0,s4
    800044ae:	00000097          	auipc	ra,0x0
    800044b2:	bae080e7          	jalr	-1106(ra) # 8000405c <iunlockput>
    ip = next;
    800044b6:	8a4e                	mv	s4,s3
  while(*path == '/')
    800044b8:	0004c783          	lbu	a5,0(s1)
    800044bc:	01279763          	bne	a5,s2,800044ca <namex+0x118>
    path++;
    800044c0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800044c2:	0004c783          	lbu	a5,0(s1)
    800044c6:	ff278de3          	beq	a5,s2,800044c0 <namex+0x10e>
  if(*path == 0)
    800044ca:	cb9d                	beqz	a5,80004500 <namex+0x14e>
  while(*path != '/' && *path != 0)
    800044cc:	0004c783          	lbu	a5,0(s1)
    800044d0:	89a6                	mv	s3,s1
  len = path - s;
    800044d2:	4c81                	li	s9,0
    800044d4:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800044d6:	01278963          	beq	a5,s2,800044e8 <namex+0x136>
    800044da:	dbbd                	beqz	a5,80004450 <namex+0x9e>
    path++;
    800044dc:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800044de:	0009c783          	lbu	a5,0(s3)
    800044e2:	ff279ce3          	bne	a5,s2,800044da <namex+0x128>
    800044e6:	b7ad                	j	80004450 <namex+0x9e>
    memmove(name, s, len);
    800044e8:	2601                	sext.w	a2,a2
    800044ea:	85a6                	mv	a1,s1
    800044ec:	8556                	mv	a0,s5
    800044ee:	ffffd097          	auipc	ra,0xffffd
    800044f2:	a8a080e7          	jalr	-1398(ra) # 80000f78 <memmove>
    name[len] = 0;
    800044f6:	9cd6                	add	s9,s9,s5
    800044f8:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800044fc:	84ce                	mv	s1,s3
    800044fe:	b7bd                	j	8000446c <namex+0xba>
  if(nameiparent){
    80004500:	f00b0de3          	beqz	s6,8000441a <namex+0x68>
    iput(ip);
    80004504:	8552                	mv	a0,s4
    80004506:	00000097          	auipc	ra,0x0
    8000450a:	aae080e7          	jalr	-1362(ra) # 80003fb4 <iput>
    return 0;
    8000450e:	4a01                	li	s4,0
    80004510:	b729                	j	8000441a <namex+0x68>

0000000080004512 <dirlink>:
{
    80004512:	7139                	addi	sp,sp,-64
    80004514:	fc06                	sd	ra,56(sp)
    80004516:	f822                	sd	s0,48(sp)
    80004518:	f04a                	sd	s2,32(sp)
    8000451a:	ec4e                	sd	s3,24(sp)
    8000451c:	e852                	sd	s4,16(sp)
    8000451e:	0080                	addi	s0,sp,64
    80004520:	892a                	mv	s2,a0
    80004522:	8a2e                	mv	s4,a1
    80004524:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004526:	4601                	li	a2,0
    80004528:	00000097          	auipc	ra,0x0
    8000452c:	dda080e7          	jalr	-550(ra) # 80004302 <dirlookup>
    80004530:	ed25                	bnez	a0,800045a8 <dirlink+0x96>
    80004532:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004534:	04c92483          	lw	s1,76(s2)
    80004538:	c49d                	beqz	s1,80004566 <dirlink+0x54>
    8000453a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000453c:	4741                	li	a4,16
    8000453e:	86a6                	mv	a3,s1
    80004540:	fc040613          	addi	a2,s0,-64
    80004544:	4581                	li	a1,0
    80004546:	854a                	mv	a0,s2
    80004548:	00000097          	auipc	ra,0x0
    8000454c:	b66080e7          	jalr	-1178(ra) # 800040ae <readi>
    80004550:	47c1                	li	a5,16
    80004552:	06f51163          	bne	a0,a5,800045b4 <dirlink+0xa2>
    if(de.inum == 0)
    80004556:	fc045783          	lhu	a5,-64(s0)
    8000455a:	c791                	beqz	a5,80004566 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000455c:	24c1                	addiw	s1,s1,16
    8000455e:	04c92783          	lw	a5,76(s2)
    80004562:	fcf4ede3          	bltu	s1,a5,8000453c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004566:	4639                	li	a2,14
    80004568:	85d2                	mv	a1,s4
    8000456a:	fc240513          	addi	a0,s0,-62
    8000456e:	ffffd097          	auipc	ra,0xffffd
    80004572:	ab4080e7          	jalr	-1356(ra) # 80001022 <strncpy>
  de.inum = inum;
    80004576:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000457a:	4741                	li	a4,16
    8000457c:	86a6                	mv	a3,s1
    8000457e:	fc040613          	addi	a2,s0,-64
    80004582:	4581                	li	a1,0
    80004584:	854a                	mv	a0,s2
    80004586:	00000097          	auipc	ra,0x0
    8000458a:	c38080e7          	jalr	-968(ra) # 800041be <writei>
    8000458e:	1541                	addi	a0,a0,-16
    80004590:	00a03533          	snez	a0,a0
    80004594:	40a00533          	neg	a0,a0
    80004598:	74a2                	ld	s1,40(sp)
}
    8000459a:	70e2                	ld	ra,56(sp)
    8000459c:	7442                	ld	s0,48(sp)
    8000459e:	7902                	ld	s2,32(sp)
    800045a0:	69e2                	ld	s3,24(sp)
    800045a2:	6a42                	ld	s4,16(sp)
    800045a4:	6121                	addi	sp,sp,64
    800045a6:	8082                	ret
    iput(ip);
    800045a8:	00000097          	auipc	ra,0x0
    800045ac:	a0c080e7          	jalr	-1524(ra) # 80003fb4 <iput>
    return -1;
    800045b0:	557d                	li	a0,-1
    800045b2:	b7e5                	j	8000459a <dirlink+0x88>
      panic("dirlink read");
    800045b4:	00004517          	auipc	a0,0x4
    800045b8:	08450513          	addi	a0,a0,132 # 80008638 <__func__.1+0x630>
    800045bc:	ffffc097          	auipc	ra,0xffffc
    800045c0:	fa4080e7          	jalr	-92(ra) # 80000560 <panic>

00000000800045c4 <namei>:

struct inode*
namei(char *path)
{
    800045c4:	1101                	addi	sp,sp,-32
    800045c6:	ec06                	sd	ra,24(sp)
    800045c8:	e822                	sd	s0,16(sp)
    800045ca:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800045cc:	fe040613          	addi	a2,s0,-32
    800045d0:	4581                	li	a1,0
    800045d2:	00000097          	auipc	ra,0x0
    800045d6:	de0080e7          	jalr	-544(ra) # 800043b2 <namex>
}
    800045da:	60e2                	ld	ra,24(sp)
    800045dc:	6442                	ld	s0,16(sp)
    800045de:	6105                	addi	sp,sp,32
    800045e0:	8082                	ret

00000000800045e2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800045e2:	1141                	addi	sp,sp,-16
    800045e4:	e406                	sd	ra,8(sp)
    800045e6:	e022                	sd	s0,0(sp)
    800045e8:	0800                	addi	s0,sp,16
    800045ea:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800045ec:	4585                	li	a1,1
    800045ee:	00000097          	auipc	ra,0x0
    800045f2:	dc4080e7          	jalr	-572(ra) # 800043b2 <namex>
}
    800045f6:	60a2                	ld	ra,8(sp)
    800045f8:	6402                	ld	s0,0(sp)
    800045fa:	0141                	addi	sp,sp,16
    800045fc:	8082                	ret

00000000800045fe <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800045fe:	1101                	addi	sp,sp,-32
    80004600:	ec06                	sd	ra,24(sp)
    80004602:	e822                	sd	s0,16(sp)
    80004604:	e426                	sd	s1,8(sp)
    80004606:	e04a                	sd	s2,0(sp)
    80004608:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000460a:	00027917          	auipc	s2,0x27
    8000460e:	1fe90913          	addi	s2,s2,510 # 8002b808 <log>
    80004612:	01892583          	lw	a1,24(s2)
    80004616:	02892503          	lw	a0,40(s2)
    8000461a:	fffff097          	auipc	ra,0xfffff
    8000461e:	fa8080e7          	jalr	-88(ra) # 800035c2 <bread>
    80004622:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004624:	02c92603          	lw	a2,44(s2)
    80004628:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000462a:	00c05f63          	blez	a2,80004648 <write_head+0x4a>
    8000462e:	00027717          	auipc	a4,0x27
    80004632:	20a70713          	addi	a4,a4,522 # 8002b838 <log+0x30>
    80004636:	87aa                	mv	a5,a0
    80004638:	060a                	slli	a2,a2,0x2
    8000463a:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000463c:	4314                	lw	a3,0(a4)
    8000463e:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004640:	0711                	addi	a4,a4,4
    80004642:	0791                	addi	a5,a5,4
    80004644:	fec79ce3          	bne	a5,a2,8000463c <write_head+0x3e>
  }
  bwrite(buf);
    80004648:	8526                	mv	a0,s1
    8000464a:	fffff097          	auipc	ra,0xfffff
    8000464e:	06a080e7          	jalr	106(ra) # 800036b4 <bwrite>
  brelse(buf);
    80004652:	8526                	mv	a0,s1
    80004654:	fffff097          	auipc	ra,0xfffff
    80004658:	09e080e7          	jalr	158(ra) # 800036f2 <brelse>
}
    8000465c:	60e2                	ld	ra,24(sp)
    8000465e:	6442                	ld	s0,16(sp)
    80004660:	64a2                	ld	s1,8(sp)
    80004662:	6902                	ld	s2,0(sp)
    80004664:	6105                	addi	sp,sp,32
    80004666:	8082                	ret

0000000080004668 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004668:	00027797          	auipc	a5,0x27
    8000466c:	1cc7a783          	lw	a5,460(a5) # 8002b834 <log+0x2c>
    80004670:	0af05d63          	blez	a5,8000472a <install_trans+0xc2>
{
    80004674:	7139                	addi	sp,sp,-64
    80004676:	fc06                	sd	ra,56(sp)
    80004678:	f822                	sd	s0,48(sp)
    8000467a:	f426                	sd	s1,40(sp)
    8000467c:	f04a                	sd	s2,32(sp)
    8000467e:	ec4e                	sd	s3,24(sp)
    80004680:	e852                	sd	s4,16(sp)
    80004682:	e456                	sd	s5,8(sp)
    80004684:	e05a                	sd	s6,0(sp)
    80004686:	0080                	addi	s0,sp,64
    80004688:	8b2a                	mv	s6,a0
    8000468a:	00027a97          	auipc	s5,0x27
    8000468e:	1aea8a93          	addi	s5,s5,430 # 8002b838 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004692:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004694:	00027997          	auipc	s3,0x27
    80004698:	17498993          	addi	s3,s3,372 # 8002b808 <log>
    8000469c:	a00d                	j	800046be <install_trans+0x56>
    brelse(lbuf);
    8000469e:	854a                	mv	a0,s2
    800046a0:	fffff097          	auipc	ra,0xfffff
    800046a4:	052080e7          	jalr	82(ra) # 800036f2 <brelse>
    brelse(dbuf);
    800046a8:	8526                	mv	a0,s1
    800046aa:	fffff097          	auipc	ra,0xfffff
    800046ae:	048080e7          	jalr	72(ra) # 800036f2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046b2:	2a05                	addiw	s4,s4,1
    800046b4:	0a91                	addi	s5,s5,4
    800046b6:	02c9a783          	lw	a5,44(s3)
    800046ba:	04fa5e63          	bge	s4,a5,80004716 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800046be:	0189a583          	lw	a1,24(s3)
    800046c2:	014585bb          	addw	a1,a1,s4
    800046c6:	2585                	addiw	a1,a1,1
    800046c8:	0289a503          	lw	a0,40(s3)
    800046cc:	fffff097          	auipc	ra,0xfffff
    800046d0:	ef6080e7          	jalr	-266(ra) # 800035c2 <bread>
    800046d4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800046d6:	000aa583          	lw	a1,0(s5)
    800046da:	0289a503          	lw	a0,40(s3)
    800046de:	fffff097          	auipc	ra,0xfffff
    800046e2:	ee4080e7          	jalr	-284(ra) # 800035c2 <bread>
    800046e6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800046e8:	40000613          	li	a2,1024
    800046ec:	05890593          	addi	a1,s2,88
    800046f0:	05850513          	addi	a0,a0,88
    800046f4:	ffffd097          	auipc	ra,0xffffd
    800046f8:	884080e7          	jalr	-1916(ra) # 80000f78 <memmove>
    bwrite(dbuf);  // write dst to disk
    800046fc:	8526                	mv	a0,s1
    800046fe:	fffff097          	auipc	ra,0xfffff
    80004702:	fb6080e7          	jalr	-74(ra) # 800036b4 <bwrite>
    if(recovering == 0)
    80004706:	f80b1ce3          	bnez	s6,8000469e <install_trans+0x36>
      bunpin(dbuf);
    8000470a:	8526                	mv	a0,s1
    8000470c:	fffff097          	auipc	ra,0xfffff
    80004710:	0be080e7          	jalr	190(ra) # 800037ca <bunpin>
    80004714:	b769                	j	8000469e <install_trans+0x36>
}
    80004716:	70e2                	ld	ra,56(sp)
    80004718:	7442                	ld	s0,48(sp)
    8000471a:	74a2                	ld	s1,40(sp)
    8000471c:	7902                	ld	s2,32(sp)
    8000471e:	69e2                	ld	s3,24(sp)
    80004720:	6a42                	ld	s4,16(sp)
    80004722:	6aa2                	ld	s5,8(sp)
    80004724:	6b02                	ld	s6,0(sp)
    80004726:	6121                	addi	sp,sp,64
    80004728:	8082                	ret
    8000472a:	8082                	ret

000000008000472c <initlog>:
{
    8000472c:	7179                	addi	sp,sp,-48
    8000472e:	f406                	sd	ra,40(sp)
    80004730:	f022                	sd	s0,32(sp)
    80004732:	ec26                	sd	s1,24(sp)
    80004734:	e84a                	sd	s2,16(sp)
    80004736:	e44e                	sd	s3,8(sp)
    80004738:	1800                	addi	s0,sp,48
    8000473a:	892a                	mv	s2,a0
    8000473c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000473e:	00027497          	auipc	s1,0x27
    80004742:	0ca48493          	addi	s1,s1,202 # 8002b808 <log>
    80004746:	00004597          	auipc	a1,0x4
    8000474a:	f0258593          	addi	a1,a1,-254 # 80008648 <__func__.1+0x640>
    8000474e:	8526                	mv	a0,s1
    80004750:	ffffc097          	auipc	ra,0xffffc
    80004754:	640080e7          	jalr	1600(ra) # 80000d90 <initlock>
  log.start = sb->logstart;
    80004758:	0149a583          	lw	a1,20(s3)
    8000475c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000475e:	0109a783          	lw	a5,16(s3)
    80004762:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004764:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004768:	854a                	mv	a0,s2
    8000476a:	fffff097          	auipc	ra,0xfffff
    8000476e:	e58080e7          	jalr	-424(ra) # 800035c2 <bread>
  log.lh.n = lh->n;
    80004772:	4d30                	lw	a2,88(a0)
    80004774:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004776:	00c05f63          	blez	a2,80004794 <initlog+0x68>
    8000477a:	87aa                	mv	a5,a0
    8000477c:	00027717          	auipc	a4,0x27
    80004780:	0bc70713          	addi	a4,a4,188 # 8002b838 <log+0x30>
    80004784:	060a                	slli	a2,a2,0x2
    80004786:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004788:	4ff4                	lw	a3,92(a5)
    8000478a:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000478c:	0791                	addi	a5,a5,4
    8000478e:	0711                	addi	a4,a4,4
    80004790:	fec79ce3          	bne	a5,a2,80004788 <initlog+0x5c>
  brelse(buf);
    80004794:	fffff097          	auipc	ra,0xfffff
    80004798:	f5e080e7          	jalr	-162(ra) # 800036f2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000479c:	4505                	li	a0,1
    8000479e:	00000097          	auipc	ra,0x0
    800047a2:	eca080e7          	jalr	-310(ra) # 80004668 <install_trans>
  log.lh.n = 0;
    800047a6:	00027797          	auipc	a5,0x27
    800047aa:	0807a723          	sw	zero,142(a5) # 8002b834 <log+0x2c>
  write_head(); // clear the log
    800047ae:	00000097          	auipc	ra,0x0
    800047b2:	e50080e7          	jalr	-432(ra) # 800045fe <write_head>
}
    800047b6:	70a2                	ld	ra,40(sp)
    800047b8:	7402                	ld	s0,32(sp)
    800047ba:	64e2                	ld	s1,24(sp)
    800047bc:	6942                	ld	s2,16(sp)
    800047be:	69a2                	ld	s3,8(sp)
    800047c0:	6145                	addi	sp,sp,48
    800047c2:	8082                	ret

00000000800047c4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800047c4:	1101                	addi	sp,sp,-32
    800047c6:	ec06                	sd	ra,24(sp)
    800047c8:	e822                	sd	s0,16(sp)
    800047ca:	e426                	sd	s1,8(sp)
    800047cc:	e04a                	sd	s2,0(sp)
    800047ce:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800047d0:	00027517          	auipc	a0,0x27
    800047d4:	03850513          	addi	a0,a0,56 # 8002b808 <log>
    800047d8:	ffffc097          	auipc	ra,0xffffc
    800047dc:	648080e7          	jalr	1608(ra) # 80000e20 <acquire>
  while(1){
    if(log.committing){
    800047e0:	00027497          	auipc	s1,0x27
    800047e4:	02848493          	addi	s1,s1,40 # 8002b808 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047e8:	4979                	li	s2,30
    800047ea:	a039                	j	800047f8 <begin_op+0x34>
      sleep(&log, &log.lock);
    800047ec:	85a6                	mv	a1,s1
    800047ee:	8526                	mv	a0,s1
    800047f0:	ffffe097          	auipc	ra,0xffffe
    800047f4:	ce6080e7          	jalr	-794(ra) # 800024d6 <sleep>
    if(log.committing){
    800047f8:	50dc                	lw	a5,36(s1)
    800047fa:	fbed                	bnez	a5,800047ec <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047fc:	5098                	lw	a4,32(s1)
    800047fe:	2705                	addiw	a4,a4,1
    80004800:	0027179b          	slliw	a5,a4,0x2
    80004804:	9fb9                	addw	a5,a5,a4
    80004806:	0017979b          	slliw	a5,a5,0x1
    8000480a:	54d4                	lw	a3,44(s1)
    8000480c:	9fb5                	addw	a5,a5,a3
    8000480e:	00f95963          	bge	s2,a5,80004820 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004812:	85a6                	mv	a1,s1
    80004814:	8526                	mv	a0,s1
    80004816:	ffffe097          	auipc	ra,0xffffe
    8000481a:	cc0080e7          	jalr	-832(ra) # 800024d6 <sleep>
    8000481e:	bfe9                	j	800047f8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004820:	00027517          	auipc	a0,0x27
    80004824:	fe850513          	addi	a0,a0,-24 # 8002b808 <log>
    80004828:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000482a:	ffffc097          	auipc	ra,0xffffc
    8000482e:	6aa080e7          	jalr	1706(ra) # 80000ed4 <release>
      break;
    }
  }
}
    80004832:	60e2                	ld	ra,24(sp)
    80004834:	6442                	ld	s0,16(sp)
    80004836:	64a2                	ld	s1,8(sp)
    80004838:	6902                	ld	s2,0(sp)
    8000483a:	6105                	addi	sp,sp,32
    8000483c:	8082                	ret

000000008000483e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000483e:	7139                	addi	sp,sp,-64
    80004840:	fc06                	sd	ra,56(sp)
    80004842:	f822                	sd	s0,48(sp)
    80004844:	f426                	sd	s1,40(sp)
    80004846:	f04a                	sd	s2,32(sp)
    80004848:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000484a:	00027497          	auipc	s1,0x27
    8000484e:	fbe48493          	addi	s1,s1,-66 # 8002b808 <log>
    80004852:	8526                	mv	a0,s1
    80004854:	ffffc097          	auipc	ra,0xffffc
    80004858:	5cc080e7          	jalr	1484(ra) # 80000e20 <acquire>
  log.outstanding -= 1;
    8000485c:	509c                	lw	a5,32(s1)
    8000485e:	37fd                	addiw	a5,a5,-1
    80004860:	0007891b          	sext.w	s2,a5
    80004864:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004866:	50dc                	lw	a5,36(s1)
    80004868:	e7b9                	bnez	a5,800048b6 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    8000486a:	06091163          	bnez	s2,800048cc <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000486e:	00027497          	auipc	s1,0x27
    80004872:	f9a48493          	addi	s1,s1,-102 # 8002b808 <log>
    80004876:	4785                	li	a5,1
    80004878:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000487a:	8526                	mv	a0,s1
    8000487c:	ffffc097          	auipc	ra,0xffffc
    80004880:	658080e7          	jalr	1624(ra) # 80000ed4 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004884:	54dc                	lw	a5,44(s1)
    80004886:	06f04763          	bgtz	a5,800048f4 <end_op+0xb6>
    acquire(&log.lock);
    8000488a:	00027497          	auipc	s1,0x27
    8000488e:	f7e48493          	addi	s1,s1,-130 # 8002b808 <log>
    80004892:	8526                	mv	a0,s1
    80004894:	ffffc097          	auipc	ra,0xffffc
    80004898:	58c080e7          	jalr	1420(ra) # 80000e20 <acquire>
    log.committing = 0;
    8000489c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800048a0:	8526                	mv	a0,s1
    800048a2:	ffffe097          	auipc	ra,0xffffe
    800048a6:	c98080e7          	jalr	-872(ra) # 8000253a <wakeup>
    release(&log.lock);
    800048aa:	8526                	mv	a0,s1
    800048ac:	ffffc097          	auipc	ra,0xffffc
    800048b0:	628080e7          	jalr	1576(ra) # 80000ed4 <release>
}
    800048b4:	a815                	j	800048e8 <end_op+0xaa>
    800048b6:	ec4e                	sd	s3,24(sp)
    800048b8:	e852                	sd	s4,16(sp)
    800048ba:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800048bc:	00004517          	auipc	a0,0x4
    800048c0:	d9450513          	addi	a0,a0,-620 # 80008650 <__func__.1+0x648>
    800048c4:	ffffc097          	auipc	ra,0xffffc
    800048c8:	c9c080e7          	jalr	-868(ra) # 80000560 <panic>
    wakeup(&log);
    800048cc:	00027497          	auipc	s1,0x27
    800048d0:	f3c48493          	addi	s1,s1,-196 # 8002b808 <log>
    800048d4:	8526                	mv	a0,s1
    800048d6:	ffffe097          	auipc	ra,0xffffe
    800048da:	c64080e7          	jalr	-924(ra) # 8000253a <wakeup>
  release(&log.lock);
    800048de:	8526                	mv	a0,s1
    800048e0:	ffffc097          	auipc	ra,0xffffc
    800048e4:	5f4080e7          	jalr	1524(ra) # 80000ed4 <release>
}
    800048e8:	70e2                	ld	ra,56(sp)
    800048ea:	7442                	ld	s0,48(sp)
    800048ec:	74a2                	ld	s1,40(sp)
    800048ee:	7902                	ld	s2,32(sp)
    800048f0:	6121                	addi	sp,sp,64
    800048f2:	8082                	ret
    800048f4:	ec4e                	sd	s3,24(sp)
    800048f6:	e852                	sd	s4,16(sp)
    800048f8:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800048fa:	00027a97          	auipc	s5,0x27
    800048fe:	f3ea8a93          	addi	s5,s5,-194 # 8002b838 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004902:	00027a17          	auipc	s4,0x27
    80004906:	f06a0a13          	addi	s4,s4,-250 # 8002b808 <log>
    8000490a:	018a2583          	lw	a1,24(s4)
    8000490e:	012585bb          	addw	a1,a1,s2
    80004912:	2585                	addiw	a1,a1,1
    80004914:	028a2503          	lw	a0,40(s4)
    80004918:	fffff097          	auipc	ra,0xfffff
    8000491c:	caa080e7          	jalr	-854(ra) # 800035c2 <bread>
    80004920:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004922:	000aa583          	lw	a1,0(s5)
    80004926:	028a2503          	lw	a0,40(s4)
    8000492a:	fffff097          	auipc	ra,0xfffff
    8000492e:	c98080e7          	jalr	-872(ra) # 800035c2 <bread>
    80004932:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004934:	40000613          	li	a2,1024
    80004938:	05850593          	addi	a1,a0,88
    8000493c:	05848513          	addi	a0,s1,88
    80004940:	ffffc097          	auipc	ra,0xffffc
    80004944:	638080e7          	jalr	1592(ra) # 80000f78 <memmove>
    bwrite(to);  // write the log
    80004948:	8526                	mv	a0,s1
    8000494a:	fffff097          	auipc	ra,0xfffff
    8000494e:	d6a080e7          	jalr	-662(ra) # 800036b4 <bwrite>
    brelse(from);
    80004952:	854e                	mv	a0,s3
    80004954:	fffff097          	auipc	ra,0xfffff
    80004958:	d9e080e7          	jalr	-610(ra) # 800036f2 <brelse>
    brelse(to);
    8000495c:	8526                	mv	a0,s1
    8000495e:	fffff097          	auipc	ra,0xfffff
    80004962:	d94080e7          	jalr	-620(ra) # 800036f2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004966:	2905                	addiw	s2,s2,1
    80004968:	0a91                	addi	s5,s5,4
    8000496a:	02ca2783          	lw	a5,44(s4)
    8000496e:	f8f94ee3          	blt	s2,a5,8000490a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004972:	00000097          	auipc	ra,0x0
    80004976:	c8c080e7          	jalr	-884(ra) # 800045fe <write_head>
    install_trans(0); // Now install writes to home locations
    8000497a:	4501                	li	a0,0
    8000497c:	00000097          	auipc	ra,0x0
    80004980:	cec080e7          	jalr	-788(ra) # 80004668 <install_trans>
    log.lh.n = 0;
    80004984:	00027797          	auipc	a5,0x27
    80004988:	ea07a823          	sw	zero,-336(a5) # 8002b834 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000498c:	00000097          	auipc	ra,0x0
    80004990:	c72080e7          	jalr	-910(ra) # 800045fe <write_head>
    80004994:	69e2                	ld	s3,24(sp)
    80004996:	6a42                	ld	s4,16(sp)
    80004998:	6aa2                	ld	s5,8(sp)
    8000499a:	bdc5                	j	8000488a <end_op+0x4c>

000000008000499c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000499c:	1101                	addi	sp,sp,-32
    8000499e:	ec06                	sd	ra,24(sp)
    800049a0:	e822                	sd	s0,16(sp)
    800049a2:	e426                	sd	s1,8(sp)
    800049a4:	e04a                	sd	s2,0(sp)
    800049a6:	1000                	addi	s0,sp,32
    800049a8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800049aa:	00027917          	auipc	s2,0x27
    800049ae:	e5e90913          	addi	s2,s2,-418 # 8002b808 <log>
    800049b2:	854a                	mv	a0,s2
    800049b4:	ffffc097          	auipc	ra,0xffffc
    800049b8:	46c080e7          	jalr	1132(ra) # 80000e20 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800049bc:	02c92603          	lw	a2,44(s2)
    800049c0:	47f5                	li	a5,29
    800049c2:	06c7c563          	blt	a5,a2,80004a2c <log_write+0x90>
    800049c6:	00027797          	auipc	a5,0x27
    800049ca:	e5e7a783          	lw	a5,-418(a5) # 8002b824 <log+0x1c>
    800049ce:	37fd                	addiw	a5,a5,-1
    800049d0:	04f65e63          	bge	a2,a5,80004a2c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800049d4:	00027797          	auipc	a5,0x27
    800049d8:	e547a783          	lw	a5,-428(a5) # 8002b828 <log+0x20>
    800049dc:	06f05063          	blez	a5,80004a3c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800049e0:	4781                	li	a5,0
    800049e2:	06c05563          	blez	a2,80004a4c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049e6:	44cc                	lw	a1,12(s1)
    800049e8:	00027717          	auipc	a4,0x27
    800049ec:	e5070713          	addi	a4,a4,-432 # 8002b838 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800049f0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049f2:	4314                	lw	a3,0(a4)
    800049f4:	04b68c63          	beq	a3,a1,80004a4c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800049f8:	2785                	addiw	a5,a5,1
    800049fa:	0711                	addi	a4,a4,4
    800049fc:	fef61be3          	bne	a2,a5,800049f2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004a00:	0621                	addi	a2,a2,8
    80004a02:	060a                	slli	a2,a2,0x2
    80004a04:	00027797          	auipc	a5,0x27
    80004a08:	e0478793          	addi	a5,a5,-508 # 8002b808 <log>
    80004a0c:	97b2                	add	a5,a5,a2
    80004a0e:	44d8                	lw	a4,12(s1)
    80004a10:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004a12:	8526                	mv	a0,s1
    80004a14:	fffff097          	auipc	ra,0xfffff
    80004a18:	d7a080e7          	jalr	-646(ra) # 8000378e <bpin>
    log.lh.n++;
    80004a1c:	00027717          	auipc	a4,0x27
    80004a20:	dec70713          	addi	a4,a4,-532 # 8002b808 <log>
    80004a24:	575c                	lw	a5,44(a4)
    80004a26:	2785                	addiw	a5,a5,1
    80004a28:	d75c                	sw	a5,44(a4)
    80004a2a:	a82d                	j	80004a64 <log_write+0xc8>
    panic("too big a transaction");
    80004a2c:	00004517          	auipc	a0,0x4
    80004a30:	c3450513          	addi	a0,a0,-972 # 80008660 <__func__.1+0x658>
    80004a34:	ffffc097          	auipc	ra,0xffffc
    80004a38:	b2c080e7          	jalr	-1236(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004a3c:	00004517          	auipc	a0,0x4
    80004a40:	c3c50513          	addi	a0,a0,-964 # 80008678 <__func__.1+0x670>
    80004a44:	ffffc097          	auipc	ra,0xffffc
    80004a48:	b1c080e7          	jalr	-1252(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004a4c:	00878693          	addi	a3,a5,8
    80004a50:	068a                	slli	a3,a3,0x2
    80004a52:	00027717          	auipc	a4,0x27
    80004a56:	db670713          	addi	a4,a4,-586 # 8002b808 <log>
    80004a5a:	9736                	add	a4,a4,a3
    80004a5c:	44d4                	lw	a3,12(s1)
    80004a5e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004a60:	faf609e3          	beq	a2,a5,80004a12 <log_write+0x76>
  }
  release(&log.lock);
    80004a64:	00027517          	auipc	a0,0x27
    80004a68:	da450513          	addi	a0,a0,-604 # 8002b808 <log>
    80004a6c:	ffffc097          	auipc	ra,0xffffc
    80004a70:	468080e7          	jalr	1128(ra) # 80000ed4 <release>
}
    80004a74:	60e2                	ld	ra,24(sp)
    80004a76:	6442                	ld	s0,16(sp)
    80004a78:	64a2                	ld	s1,8(sp)
    80004a7a:	6902                	ld	s2,0(sp)
    80004a7c:	6105                	addi	sp,sp,32
    80004a7e:	8082                	ret

0000000080004a80 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004a80:	1101                	addi	sp,sp,-32
    80004a82:	ec06                	sd	ra,24(sp)
    80004a84:	e822                	sd	s0,16(sp)
    80004a86:	e426                	sd	s1,8(sp)
    80004a88:	e04a                	sd	s2,0(sp)
    80004a8a:	1000                	addi	s0,sp,32
    80004a8c:	84aa                	mv	s1,a0
    80004a8e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004a90:	00004597          	auipc	a1,0x4
    80004a94:	c0858593          	addi	a1,a1,-1016 # 80008698 <__func__.1+0x690>
    80004a98:	0521                	addi	a0,a0,8
    80004a9a:	ffffc097          	auipc	ra,0xffffc
    80004a9e:	2f6080e7          	jalr	758(ra) # 80000d90 <initlock>
  lk->name = name;
    80004aa2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004aa6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004aaa:	0204a423          	sw	zero,40(s1)
}
    80004aae:	60e2                	ld	ra,24(sp)
    80004ab0:	6442                	ld	s0,16(sp)
    80004ab2:	64a2                	ld	s1,8(sp)
    80004ab4:	6902                	ld	s2,0(sp)
    80004ab6:	6105                	addi	sp,sp,32
    80004ab8:	8082                	ret

0000000080004aba <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004aba:	1101                	addi	sp,sp,-32
    80004abc:	ec06                	sd	ra,24(sp)
    80004abe:	e822                	sd	s0,16(sp)
    80004ac0:	e426                	sd	s1,8(sp)
    80004ac2:	e04a                	sd	s2,0(sp)
    80004ac4:	1000                	addi	s0,sp,32
    80004ac6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004ac8:	00850913          	addi	s2,a0,8
    80004acc:	854a                	mv	a0,s2
    80004ace:	ffffc097          	auipc	ra,0xffffc
    80004ad2:	352080e7          	jalr	850(ra) # 80000e20 <acquire>
  while (lk->locked) {
    80004ad6:	409c                	lw	a5,0(s1)
    80004ad8:	cb89                	beqz	a5,80004aea <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004ada:	85ca                	mv	a1,s2
    80004adc:	8526                	mv	a0,s1
    80004ade:	ffffe097          	auipc	ra,0xffffe
    80004ae2:	9f8080e7          	jalr	-1544(ra) # 800024d6 <sleep>
  while (lk->locked) {
    80004ae6:	409c                	lw	a5,0(s1)
    80004ae8:	fbed                	bnez	a5,80004ada <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004aea:	4785                	li	a5,1
    80004aec:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004aee:	ffffd097          	auipc	ra,0xffffd
    80004af2:	236080e7          	jalr	566(ra) # 80001d24 <myproc>
    80004af6:	591c                	lw	a5,48(a0)
    80004af8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004afa:	854a                	mv	a0,s2
    80004afc:	ffffc097          	auipc	ra,0xffffc
    80004b00:	3d8080e7          	jalr	984(ra) # 80000ed4 <release>
}
    80004b04:	60e2                	ld	ra,24(sp)
    80004b06:	6442                	ld	s0,16(sp)
    80004b08:	64a2                	ld	s1,8(sp)
    80004b0a:	6902                	ld	s2,0(sp)
    80004b0c:	6105                	addi	sp,sp,32
    80004b0e:	8082                	ret

0000000080004b10 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004b10:	1101                	addi	sp,sp,-32
    80004b12:	ec06                	sd	ra,24(sp)
    80004b14:	e822                	sd	s0,16(sp)
    80004b16:	e426                	sd	s1,8(sp)
    80004b18:	e04a                	sd	s2,0(sp)
    80004b1a:	1000                	addi	s0,sp,32
    80004b1c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b1e:	00850913          	addi	s2,a0,8
    80004b22:	854a                	mv	a0,s2
    80004b24:	ffffc097          	auipc	ra,0xffffc
    80004b28:	2fc080e7          	jalr	764(ra) # 80000e20 <acquire>
  lk->locked = 0;
    80004b2c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b30:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004b34:	8526                	mv	a0,s1
    80004b36:	ffffe097          	auipc	ra,0xffffe
    80004b3a:	a04080e7          	jalr	-1532(ra) # 8000253a <wakeup>
  release(&lk->lk);
    80004b3e:	854a                	mv	a0,s2
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	394080e7          	jalr	916(ra) # 80000ed4 <release>
}
    80004b48:	60e2                	ld	ra,24(sp)
    80004b4a:	6442                	ld	s0,16(sp)
    80004b4c:	64a2                	ld	s1,8(sp)
    80004b4e:	6902                	ld	s2,0(sp)
    80004b50:	6105                	addi	sp,sp,32
    80004b52:	8082                	ret

0000000080004b54 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004b54:	7179                	addi	sp,sp,-48
    80004b56:	f406                	sd	ra,40(sp)
    80004b58:	f022                	sd	s0,32(sp)
    80004b5a:	ec26                	sd	s1,24(sp)
    80004b5c:	e84a                	sd	s2,16(sp)
    80004b5e:	1800                	addi	s0,sp,48
    80004b60:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004b62:	00850913          	addi	s2,a0,8
    80004b66:	854a                	mv	a0,s2
    80004b68:	ffffc097          	auipc	ra,0xffffc
    80004b6c:	2b8080e7          	jalr	696(ra) # 80000e20 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b70:	409c                	lw	a5,0(s1)
    80004b72:	ef91                	bnez	a5,80004b8e <holdingsleep+0x3a>
    80004b74:	4481                	li	s1,0
  release(&lk->lk);
    80004b76:	854a                	mv	a0,s2
    80004b78:	ffffc097          	auipc	ra,0xffffc
    80004b7c:	35c080e7          	jalr	860(ra) # 80000ed4 <release>
  return r;
}
    80004b80:	8526                	mv	a0,s1
    80004b82:	70a2                	ld	ra,40(sp)
    80004b84:	7402                	ld	s0,32(sp)
    80004b86:	64e2                	ld	s1,24(sp)
    80004b88:	6942                	ld	s2,16(sp)
    80004b8a:	6145                	addi	sp,sp,48
    80004b8c:	8082                	ret
    80004b8e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b90:	0284a983          	lw	s3,40(s1)
    80004b94:	ffffd097          	auipc	ra,0xffffd
    80004b98:	190080e7          	jalr	400(ra) # 80001d24 <myproc>
    80004b9c:	5904                	lw	s1,48(a0)
    80004b9e:	413484b3          	sub	s1,s1,s3
    80004ba2:	0014b493          	seqz	s1,s1
    80004ba6:	69a2                	ld	s3,8(sp)
    80004ba8:	b7f9                	j	80004b76 <holdingsleep+0x22>

0000000080004baa <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004baa:	1141                	addi	sp,sp,-16
    80004bac:	e406                	sd	ra,8(sp)
    80004bae:	e022                	sd	s0,0(sp)
    80004bb0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004bb2:	00004597          	auipc	a1,0x4
    80004bb6:	af658593          	addi	a1,a1,-1290 # 800086a8 <__func__.1+0x6a0>
    80004bba:	00027517          	auipc	a0,0x27
    80004bbe:	d9650513          	addi	a0,a0,-618 # 8002b950 <ftable>
    80004bc2:	ffffc097          	auipc	ra,0xffffc
    80004bc6:	1ce080e7          	jalr	462(ra) # 80000d90 <initlock>
}
    80004bca:	60a2                	ld	ra,8(sp)
    80004bcc:	6402                	ld	s0,0(sp)
    80004bce:	0141                	addi	sp,sp,16
    80004bd0:	8082                	ret

0000000080004bd2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004bd2:	1101                	addi	sp,sp,-32
    80004bd4:	ec06                	sd	ra,24(sp)
    80004bd6:	e822                	sd	s0,16(sp)
    80004bd8:	e426                	sd	s1,8(sp)
    80004bda:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004bdc:	00027517          	auipc	a0,0x27
    80004be0:	d7450513          	addi	a0,a0,-652 # 8002b950 <ftable>
    80004be4:	ffffc097          	auipc	ra,0xffffc
    80004be8:	23c080e7          	jalr	572(ra) # 80000e20 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004bec:	00027497          	auipc	s1,0x27
    80004bf0:	d7c48493          	addi	s1,s1,-644 # 8002b968 <ftable+0x18>
    80004bf4:	00028717          	auipc	a4,0x28
    80004bf8:	d1470713          	addi	a4,a4,-748 # 8002c908 <disk>
    if(f->ref == 0){
    80004bfc:	40dc                	lw	a5,4(s1)
    80004bfe:	cf99                	beqz	a5,80004c1c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c00:	02848493          	addi	s1,s1,40
    80004c04:	fee49ce3          	bne	s1,a4,80004bfc <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004c08:	00027517          	auipc	a0,0x27
    80004c0c:	d4850513          	addi	a0,a0,-696 # 8002b950 <ftable>
    80004c10:	ffffc097          	auipc	ra,0xffffc
    80004c14:	2c4080e7          	jalr	708(ra) # 80000ed4 <release>
  return 0;
    80004c18:	4481                	li	s1,0
    80004c1a:	a819                	j	80004c30 <filealloc+0x5e>
      f->ref = 1;
    80004c1c:	4785                	li	a5,1
    80004c1e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004c20:	00027517          	auipc	a0,0x27
    80004c24:	d3050513          	addi	a0,a0,-720 # 8002b950 <ftable>
    80004c28:	ffffc097          	auipc	ra,0xffffc
    80004c2c:	2ac080e7          	jalr	684(ra) # 80000ed4 <release>
}
    80004c30:	8526                	mv	a0,s1
    80004c32:	60e2                	ld	ra,24(sp)
    80004c34:	6442                	ld	s0,16(sp)
    80004c36:	64a2                	ld	s1,8(sp)
    80004c38:	6105                	addi	sp,sp,32
    80004c3a:	8082                	ret

0000000080004c3c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004c3c:	1101                	addi	sp,sp,-32
    80004c3e:	ec06                	sd	ra,24(sp)
    80004c40:	e822                	sd	s0,16(sp)
    80004c42:	e426                	sd	s1,8(sp)
    80004c44:	1000                	addi	s0,sp,32
    80004c46:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004c48:	00027517          	auipc	a0,0x27
    80004c4c:	d0850513          	addi	a0,a0,-760 # 8002b950 <ftable>
    80004c50:	ffffc097          	auipc	ra,0xffffc
    80004c54:	1d0080e7          	jalr	464(ra) # 80000e20 <acquire>
  if(f->ref < 1)
    80004c58:	40dc                	lw	a5,4(s1)
    80004c5a:	02f05263          	blez	a5,80004c7e <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004c5e:	2785                	addiw	a5,a5,1
    80004c60:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004c62:	00027517          	auipc	a0,0x27
    80004c66:	cee50513          	addi	a0,a0,-786 # 8002b950 <ftable>
    80004c6a:	ffffc097          	auipc	ra,0xffffc
    80004c6e:	26a080e7          	jalr	618(ra) # 80000ed4 <release>
  return f;
}
    80004c72:	8526                	mv	a0,s1
    80004c74:	60e2                	ld	ra,24(sp)
    80004c76:	6442                	ld	s0,16(sp)
    80004c78:	64a2                	ld	s1,8(sp)
    80004c7a:	6105                	addi	sp,sp,32
    80004c7c:	8082                	ret
    panic("filedup");
    80004c7e:	00004517          	auipc	a0,0x4
    80004c82:	a3250513          	addi	a0,a0,-1486 # 800086b0 <__func__.1+0x6a8>
    80004c86:	ffffc097          	auipc	ra,0xffffc
    80004c8a:	8da080e7          	jalr	-1830(ra) # 80000560 <panic>

0000000080004c8e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004c8e:	7139                	addi	sp,sp,-64
    80004c90:	fc06                	sd	ra,56(sp)
    80004c92:	f822                	sd	s0,48(sp)
    80004c94:	f426                	sd	s1,40(sp)
    80004c96:	0080                	addi	s0,sp,64
    80004c98:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004c9a:	00027517          	auipc	a0,0x27
    80004c9e:	cb650513          	addi	a0,a0,-842 # 8002b950 <ftable>
    80004ca2:	ffffc097          	auipc	ra,0xffffc
    80004ca6:	17e080e7          	jalr	382(ra) # 80000e20 <acquire>
  if(f->ref < 1)
    80004caa:	40dc                	lw	a5,4(s1)
    80004cac:	04f05c63          	blez	a5,80004d04 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004cb0:	37fd                	addiw	a5,a5,-1
    80004cb2:	0007871b          	sext.w	a4,a5
    80004cb6:	c0dc                	sw	a5,4(s1)
    80004cb8:	06e04263          	bgtz	a4,80004d1c <fileclose+0x8e>
    80004cbc:	f04a                	sd	s2,32(sp)
    80004cbe:	ec4e                	sd	s3,24(sp)
    80004cc0:	e852                	sd	s4,16(sp)
    80004cc2:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004cc4:	0004a903          	lw	s2,0(s1)
    80004cc8:	0094ca83          	lbu	s5,9(s1)
    80004ccc:	0104ba03          	ld	s4,16(s1)
    80004cd0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004cd4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004cd8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004cdc:	00027517          	auipc	a0,0x27
    80004ce0:	c7450513          	addi	a0,a0,-908 # 8002b950 <ftable>
    80004ce4:	ffffc097          	auipc	ra,0xffffc
    80004ce8:	1f0080e7          	jalr	496(ra) # 80000ed4 <release>

  if(ff.type == FD_PIPE){
    80004cec:	4785                	li	a5,1
    80004cee:	04f90463          	beq	s2,a5,80004d36 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004cf2:	3979                	addiw	s2,s2,-2
    80004cf4:	4785                	li	a5,1
    80004cf6:	0527fb63          	bgeu	a5,s2,80004d4c <fileclose+0xbe>
    80004cfa:	7902                	ld	s2,32(sp)
    80004cfc:	69e2                	ld	s3,24(sp)
    80004cfe:	6a42                	ld	s4,16(sp)
    80004d00:	6aa2                	ld	s5,8(sp)
    80004d02:	a02d                	j	80004d2c <fileclose+0x9e>
    80004d04:	f04a                	sd	s2,32(sp)
    80004d06:	ec4e                	sd	s3,24(sp)
    80004d08:	e852                	sd	s4,16(sp)
    80004d0a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004d0c:	00004517          	auipc	a0,0x4
    80004d10:	9ac50513          	addi	a0,a0,-1620 # 800086b8 <__func__.1+0x6b0>
    80004d14:	ffffc097          	auipc	ra,0xffffc
    80004d18:	84c080e7          	jalr	-1972(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004d1c:	00027517          	auipc	a0,0x27
    80004d20:	c3450513          	addi	a0,a0,-972 # 8002b950 <ftable>
    80004d24:	ffffc097          	auipc	ra,0xffffc
    80004d28:	1b0080e7          	jalr	432(ra) # 80000ed4 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004d2c:	70e2                	ld	ra,56(sp)
    80004d2e:	7442                	ld	s0,48(sp)
    80004d30:	74a2                	ld	s1,40(sp)
    80004d32:	6121                	addi	sp,sp,64
    80004d34:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004d36:	85d6                	mv	a1,s5
    80004d38:	8552                	mv	a0,s4
    80004d3a:	00000097          	auipc	ra,0x0
    80004d3e:	3a2080e7          	jalr	930(ra) # 800050dc <pipeclose>
    80004d42:	7902                	ld	s2,32(sp)
    80004d44:	69e2                	ld	s3,24(sp)
    80004d46:	6a42                	ld	s4,16(sp)
    80004d48:	6aa2                	ld	s5,8(sp)
    80004d4a:	b7cd                	j	80004d2c <fileclose+0x9e>
    begin_op();
    80004d4c:	00000097          	auipc	ra,0x0
    80004d50:	a78080e7          	jalr	-1416(ra) # 800047c4 <begin_op>
    iput(ff.ip);
    80004d54:	854e                	mv	a0,s3
    80004d56:	fffff097          	auipc	ra,0xfffff
    80004d5a:	25e080e7          	jalr	606(ra) # 80003fb4 <iput>
    end_op();
    80004d5e:	00000097          	auipc	ra,0x0
    80004d62:	ae0080e7          	jalr	-1312(ra) # 8000483e <end_op>
    80004d66:	7902                	ld	s2,32(sp)
    80004d68:	69e2                	ld	s3,24(sp)
    80004d6a:	6a42                	ld	s4,16(sp)
    80004d6c:	6aa2                	ld	s5,8(sp)
    80004d6e:	bf7d                	j	80004d2c <fileclose+0x9e>

0000000080004d70 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004d70:	715d                	addi	sp,sp,-80
    80004d72:	e486                	sd	ra,72(sp)
    80004d74:	e0a2                	sd	s0,64(sp)
    80004d76:	fc26                	sd	s1,56(sp)
    80004d78:	f44e                	sd	s3,40(sp)
    80004d7a:	0880                	addi	s0,sp,80
    80004d7c:	84aa                	mv	s1,a0
    80004d7e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004d80:	ffffd097          	auipc	ra,0xffffd
    80004d84:	fa4080e7          	jalr	-92(ra) # 80001d24 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004d88:	409c                	lw	a5,0(s1)
    80004d8a:	37f9                	addiw	a5,a5,-2
    80004d8c:	4705                	li	a4,1
    80004d8e:	04f76863          	bltu	a4,a5,80004dde <filestat+0x6e>
    80004d92:	f84a                	sd	s2,48(sp)
    80004d94:	892a                	mv	s2,a0
    ilock(f->ip);
    80004d96:	6c88                	ld	a0,24(s1)
    80004d98:	fffff097          	auipc	ra,0xfffff
    80004d9c:	05e080e7          	jalr	94(ra) # 80003df6 <ilock>
    stati(f->ip, &st);
    80004da0:	fb840593          	addi	a1,s0,-72
    80004da4:	6c88                	ld	a0,24(s1)
    80004da6:	fffff097          	auipc	ra,0xfffff
    80004daa:	2de080e7          	jalr	734(ra) # 80004084 <stati>
    iunlock(f->ip);
    80004dae:	6c88                	ld	a0,24(s1)
    80004db0:	fffff097          	auipc	ra,0xfffff
    80004db4:	10c080e7          	jalr	268(ra) # 80003ebc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004db8:	46e1                	li	a3,24
    80004dba:	fb840613          	addi	a2,s0,-72
    80004dbe:	85ce                	mv	a1,s3
    80004dc0:	05093503          	ld	a0,80(s2)
    80004dc4:	ffffd097          	auipc	ra,0xffffd
    80004dc8:	b04080e7          	jalr	-1276(ra) # 800018c8 <copyout>
    80004dcc:	41f5551b          	sraiw	a0,a0,0x1f
    80004dd0:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004dd2:	60a6                	ld	ra,72(sp)
    80004dd4:	6406                	ld	s0,64(sp)
    80004dd6:	74e2                	ld	s1,56(sp)
    80004dd8:	79a2                	ld	s3,40(sp)
    80004dda:	6161                	addi	sp,sp,80
    80004ddc:	8082                	ret
  return -1;
    80004dde:	557d                	li	a0,-1
    80004de0:	bfcd                	j	80004dd2 <filestat+0x62>

0000000080004de2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004de2:	7179                	addi	sp,sp,-48
    80004de4:	f406                	sd	ra,40(sp)
    80004de6:	f022                	sd	s0,32(sp)
    80004de8:	e84a                	sd	s2,16(sp)
    80004dea:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004dec:	00854783          	lbu	a5,8(a0)
    80004df0:	cbc5                	beqz	a5,80004ea0 <fileread+0xbe>
    80004df2:	ec26                	sd	s1,24(sp)
    80004df4:	e44e                	sd	s3,8(sp)
    80004df6:	84aa                	mv	s1,a0
    80004df8:	89ae                	mv	s3,a1
    80004dfa:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004dfc:	411c                	lw	a5,0(a0)
    80004dfe:	4705                	li	a4,1
    80004e00:	04e78963          	beq	a5,a4,80004e52 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e04:	470d                	li	a4,3
    80004e06:	04e78f63          	beq	a5,a4,80004e64 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e0a:	4709                	li	a4,2
    80004e0c:	08e79263          	bne	a5,a4,80004e90 <fileread+0xae>
    ilock(f->ip);
    80004e10:	6d08                	ld	a0,24(a0)
    80004e12:	fffff097          	auipc	ra,0xfffff
    80004e16:	fe4080e7          	jalr	-28(ra) # 80003df6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004e1a:	874a                	mv	a4,s2
    80004e1c:	5094                	lw	a3,32(s1)
    80004e1e:	864e                	mv	a2,s3
    80004e20:	4585                	li	a1,1
    80004e22:	6c88                	ld	a0,24(s1)
    80004e24:	fffff097          	auipc	ra,0xfffff
    80004e28:	28a080e7          	jalr	650(ra) # 800040ae <readi>
    80004e2c:	892a                	mv	s2,a0
    80004e2e:	00a05563          	blez	a0,80004e38 <fileread+0x56>
      f->off += r;
    80004e32:	509c                	lw	a5,32(s1)
    80004e34:	9fa9                	addw	a5,a5,a0
    80004e36:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004e38:	6c88                	ld	a0,24(s1)
    80004e3a:	fffff097          	auipc	ra,0xfffff
    80004e3e:	082080e7          	jalr	130(ra) # 80003ebc <iunlock>
    80004e42:	64e2                	ld	s1,24(sp)
    80004e44:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004e46:	854a                	mv	a0,s2
    80004e48:	70a2                	ld	ra,40(sp)
    80004e4a:	7402                	ld	s0,32(sp)
    80004e4c:	6942                	ld	s2,16(sp)
    80004e4e:	6145                	addi	sp,sp,48
    80004e50:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004e52:	6908                	ld	a0,16(a0)
    80004e54:	00000097          	auipc	ra,0x0
    80004e58:	400080e7          	jalr	1024(ra) # 80005254 <piperead>
    80004e5c:	892a                	mv	s2,a0
    80004e5e:	64e2                	ld	s1,24(sp)
    80004e60:	69a2                	ld	s3,8(sp)
    80004e62:	b7d5                	j	80004e46 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004e64:	02451783          	lh	a5,36(a0)
    80004e68:	03079693          	slli	a3,a5,0x30
    80004e6c:	92c1                	srli	a3,a3,0x30
    80004e6e:	4725                	li	a4,9
    80004e70:	02d76a63          	bltu	a4,a3,80004ea4 <fileread+0xc2>
    80004e74:	0792                	slli	a5,a5,0x4
    80004e76:	00027717          	auipc	a4,0x27
    80004e7a:	a3a70713          	addi	a4,a4,-1478 # 8002b8b0 <devsw>
    80004e7e:	97ba                	add	a5,a5,a4
    80004e80:	639c                	ld	a5,0(a5)
    80004e82:	c78d                	beqz	a5,80004eac <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004e84:	4505                	li	a0,1
    80004e86:	9782                	jalr	a5
    80004e88:	892a                	mv	s2,a0
    80004e8a:	64e2                	ld	s1,24(sp)
    80004e8c:	69a2                	ld	s3,8(sp)
    80004e8e:	bf65                	j	80004e46 <fileread+0x64>
    panic("fileread");
    80004e90:	00004517          	auipc	a0,0x4
    80004e94:	83850513          	addi	a0,a0,-1992 # 800086c8 <__func__.1+0x6c0>
    80004e98:	ffffb097          	auipc	ra,0xffffb
    80004e9c:	6c8080e7          	jalr	1736(ra) # 80000560 <panic>
    return -1;
    80004ea0:	597d                	li	s2,-1
    80004ea2:	b755                	j	80004e46 <fileread+0x64>
      return -1;
    80004ea4:	597d                	li	s2,-1
    80004ea6:	64e2                	ld	s1,24(sp)
    80004ea8:	69a2                	ld	s3,8(sp)
    80004eaa:	bf71                	j	80004e46 <fileread+0x64>
    80004eac:	597d                	li	s2,-1
    80004eae:	64e2                	ld	s1,24(sp)
    80004eb0:	69a2                	ld	s3,8(sp)
    80004eb2:	bf51                	j	80004e46 <fileread+0x64>

0000000080004eb4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004eb4:	00954783          	lbu	a5,9(a0)
    80004eb8:	12078963          	beqz	a5,80004fea <filewrite+0x136>
{
    80004ebc:	715d                	addi	sp,sp,-80
    80004ebe:	e486                	sd	ra,72(sp)
    80004ec0:	e0a2                	sd	s0,64(sp)
    80004ec2:	f84a                	sd	s2,48(sp)
    80004ec4:	f052                	sd	s4,32(sp)
    80004ec6:	e85a                	sd	s6,16(sp)
    80004ec8:	0880                	addi	s0,sp,80
    80004eca:	892a                	mv	s2,a0
    80004ecc:	8b2e                	mv	s6,a1
    80004ece:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ed0:	411c                	lw	a5,0(a0)
    80004ed2:	4705                	li	a4,1
    80004ed4:	02e78763          	beq	a5,a4,80004f02 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ed8:	470d                	li	a4,3
    80004eda:	02e78a63          	beq	a5,a4,80004f0e <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ede:	4709                	li	a4,2
    80004ee0:	0ee79863          	bne	a5,a4,80004fd0 <filewrite+0x11c>
    80004ee4:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004ee6:	0cc05463          	blez	a2,80004fae <filewrite+0xfa>
    80004eea:	fc26                	sd	s1,56(sp)
    80004eec:	ec56                	sd	s5,24(sp)
    80004eee:	e45e                	sd	s7,8(sp)
    80004ef0:	e062                	sd	s8,0(sp)
    int i = 0;
    80004ef2:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004ef4:	6b85                	lui	s7,0x1
    80004ef6:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004efa:	6c05                	lui	s8,0x1
    80004efc:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004f00:	a851                	j	80004f94 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004f02:	6908                	ld	a0,16(a0)
    80004f04:	00000097          	auipc	ra,0x0
    80004f08:	248080e7          	jalr	584(ra) # 8000514c <pipewrite>
    80004f0c:	a85d                	j	80004fc2 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004f0e:	02451783          	lh	a5,36(a0)
    80004f12:	03079693          	slli	a3,a5,0x30
    80004f16:	92c1                	srli	a3,a3,0x30
    80004f18:	4725                	li	a4,9
    80004f1a:	0cd76a63          	bltu	a4,a3,80004fee <filewrite+0x13a>
    80004f1e:	0792                	slli	a5,a5,0x4
    80004f20:	00027717          	auipc	a4,0x27
    80004f24:	99070713          	addi	a4,a4,-1648 # 8002b8b0 <devsw>
    80004f28:	97ba                	add	a5,a5,a4
    80004f2a:	679c                	ld	a5,8(a5)
    80004f2c:	c3f9                	beqz	a5,80004ff2 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80004f2e:	4505                	li	a0,1
    80004f30:	9782                	jalr	a5
    80004f32:	a841                	j	80004fc2 <filewrite+0x10e>
      if(n1 > max)
    80004f34:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004f38:	00000097          	auipc	ra,0x0
    80004f3c:	88c080e7          	jalr	-1908(ra) # 800047c4 <begin_op>
      ilock(f->ip);
    80004f40:	01893503          	ld	a0,24(s2)
    80004f44:	fffff097          	auipc	ra,0xfffff
    80004f48:	eb2080e7          	jalr	-334(ra) # 80003df6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004f4c:	8756                	mv	a4,s5
    80004f4e:	02092683          	lw	a3,32(s2)
    80004f52:	01698633          	add	a2,s3,s6
    80004f56:	4585                	li	a1,1
    80004f58:	01893503          	ld	a0,24(s2)
    80004f5c:	fffff097          	auipc	ra,0xfffff
    80004f60:	262080e7          	jalr	610(ra) # 800041be <writei>
    80004f64:	84aa                	mv	s1,a0
    80004f66:	00a05763          	blez	a0,80004f74 <filewrite+0xc0>
        f->off += r;
    80004f6a:	02092783          	lw	a5,32(s2)
    80004f6e:	9fa9                	addw	a5,a5,a0
    80004f70:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004f74:	01893503          	ld	a0,24(s2)
    80004f78:	fffff097          	auipc	ra,0xfffff
    80004f7c:	f44080e7          	jalr	-188(ra) # 80003ebc <iunlock>
      end_op();
    80004f80:	00000097          	auipc	ra,0x0
    80004f84:	8be080e7          	jalr	-1858(ra) # 8000483e <end_op>

      if(r != n1){
    80004f88:	029a9563          	bne	s5,s1,80004fb2 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80004f8c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004f90:	0149da63          	bge	s3,s4,80004fa4 <filewrite+0xf0>
      int n1 = n - i;
    80004f94:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004f98:	0004879b          	sext.w	a5,s1
    80004f9c:	f8fbdce3          	bge	s7,a5,80004f34 <filewrite+0x80>
    80004fa0:	84e2                	mv	s1,s8
    80004fa2:	bf49                	j	80004f34 <filewrite+0x80>
    80004fa4:	74e2                	ld	s1,56(sp)
    80004fa6:	6ae2                	ld	s5,24(sp)
    80004fa8:	6ba2                	ld	s7,8(sp)
    80004faa:	6c02                	ld	s8,0(sp)
    80004fac:	a039                	j	80004fba <filewrite+0x106>
    int i = 0;
    80004fae:	4981                	li	s3,0
    80004fb0:	a029                	j	80004fba <filewrite+0x106>
    80004fb2:	74e2                	ld	s1,56(sp)
    80004fb4:	6ae2                	ld	s5,24(sp)
    80004fb6:	6ba2                	ld	s7,8(sp)
    80004fb8:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004fba:	033a1e63          	bne	s4,s3,80004ff6 <filewrite+0x142>
    80004fbe:	8552                	mv	a0,s4
    80004fc0:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004fc2:	60a6                	ld	ra,72(sp)
    80004fc4:	6406                	ld	s0,64(sp)
    80004fc6:	7942                	ld	s2,48(sp)
    80004fc8:	7a02                	ld	s4,32(sp)
    80004fca:	6b42                	ld	s6,16(sp)
    80004fcc:	6161                	addi	sp,sp,80
    80004fce:	8082                	ret
    80004fd0:	fc26                	sd	s1,56(sp)
    80004fd2:	f44e                	sd	s3,40(sp)
    80004fd4:	ec56                	sd	s5,24(sp)
    80004fd6:	e45e                	sd	s7,8(sp)
    80004fd8:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004fda:	00003517          	auipc	a0,0x3
    80004fde:	6fe50513          	addi	a0,a0,1790 # 800086d8 <__func__.1+0x6d0>
    80004fe2:	ffffb097          	auipc	ra,0xffffb
    80004fe6:	57e080e7          	jalr	1406(ra) # 80000560 <panic>
    return -1;
    80004fea:	557d                	li	a0,-1
}
    80004fec:	8082                	ret
      return -1;
    80004fee:	557d                	li	a0,-1
    80004ff0:	bfc9                	j	80004fc2 <filewrite+0x10e>
    80004ff2:	557d                	li	a0,-1
    80004ff4:	b7f9                	j	80004fc2 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004ff6:	557d                	li	a0,-1
    80004ff8:	79a2                	ld	s3,40(sp)
    80004ffa:	b7e1                	j	80004fc2 <filewrite+0x10e>

0000000080004ffc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ffc:	7179                	addi	sp,sp,-48
    80004ffe:	f406                	sd	ra,40(sp)
    80005000:	f022                	sd	s0,32(sp)
    80005002:	ec26                	sd	s1,24(sp)
    80005004:	e052                	sd	s4,0(sp)
    80005006:	1800                	addi	s0,sp,48
    80005008:	84aa                	mv	s1,a0
    8000500a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000500c:	0005b023          	sd	zero,0(a1)
    80005010:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005014:	00000097          	auipc	ra,0x0
    80005018:	bbe080e7          	jalr	-1090(ra) # 80004bd2 <filealloc>
    8000501c:	e088                	sd	a0,0(s1)
    8000501e:	cd49                	beqz	a0,800050b8 <pipealloc+0xbc>
    80005020:	00000097          	auipc	ra,0x0
    80005024:	bb2080e7          	jalr	-1102(ra) # 80004bd2 <filealloc>
    80005028:	00aa3023          	sd	a0,0(s4)
    8000502c:	c141                	beqz	a0,800050ac <pipealloc+0xb0>
    8000502e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005030:	ffffc097          	auipc	ra,0xffffc
    80005034:	c72080e7          	jalr	-910(ra) # 80000ca2 <kalloc>
    80005038:	892a                	mv	s2,a0
    8000503a:	c13d                	beqz	a0,800050a0 <pipealloc+0xa4>
    8000503c:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000503e:	4985                	li	s3,1
    80005040:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005044:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005048:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000504c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005050:	00003597          	auipc	a1,0x3
    80005054:	69858593          	addi	a1,a1,1688 # 800086e8 <__func__.1+0x6e0>
    80005058:	ffffc097          	auipc	ra,0xffffc
    8000505c:	d38080e7          	jalr	-712(ra) # 80000d90 <initlock>
  (*f0)->type = FD_PIPE;
    80005060:	609c                	ld	a5,0(s1)
    80005062:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005066:	609c                	ld	a5,0(s1)
    80005068:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000506c:	609c                	ld	a5,0(s1)
    8000506e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005072:	609c                	ld	a5,0(s1)
    80005074:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005078:	000a3783          	ld	a5,0(s4)
    8000507c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005080:	000a3783          	ld	a5,0(s4)
    80005084:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005088:	000a3783          	ld	a5,0(s4)
    8000508c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005090:	000a3783          	ld	a5,0(s4)
    80005094:	0127b823          	sd	s2,16(a5)
  return 0;
    80005098:	4501                	li	a0,0
    8000509a:	6942                	ld	s2,16(sp)
    8000509c:	69a2                	ld	s3,8(sp)
    8000509e:	a03d                	j	800050cc <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800050a0:	6088                	ld	a0,0(s1)
    800050a2:	c119                	beqz	a0,800050a8 <pipealloc+0xac>
    800050a4:	6942                	ld	s2,16(sp)
    800050a6:	a029                	j	800050b0 <pipealloc+0xb4>
    800050a8:	6942                	ld	s2,16(sp)
    800050aa:	a039                	j	800050b8 <pipealloc+0xbc>
    800050ac:	6088                	ld	a0,0(s1)
    800050ae:	c50d                	beqz	a0,800050d8 <pipealloc+0xdc>
    fileclose(*f0);
    800050b0:	00000097          	auipc	ra,0x0
    800050b4:	bde080e7          	jalr	-1058(ra) # 80004c8e <fileclose>
  if(*f1)
    800050b8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800050bc:	557d                	li	a0,-1
  if(*f1)
    800050be:	c799                	beqz	a5,800050cc <pipealloc+0xd0>
    fileclose(*f1);
    800050c0:	853e                	mv	a0,a5
    800050c2:	00000097          	auipc	ra,0x0
    800050c6:	bcc080e7          	jalr	-1076(ra) # 80004c8e <fileclose>
  return -1;
    800050ca:	557d                	li	a0,-1
}
    800050cc:	70a2                	ld	ra,40(sp)
    800050ce:	7402                	ld	s0,32(sp)
    800050d0:	64e2                	ld	s1,24(sp)
    800050d2:	6a02                	ld	s4,0(sp)
    800050d4:	6145                	addi	sp,sp,48
    800050d6:	8082                	ret
  return -1;
    800050d8:	557d                	li	a0,-1
    800050da:	bfcd                	j	800050cc <pipealloc+0xd0>

00000000800050dc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800050dc:	1101                	addi	sp,sp,-32
    800050de:	ec06                	sd	ra,24(sp)
    800050e0:	e822                	sd	s0,16(sp)
    800050e2:	e426                	sd	s1,8(sp)
    800050e4:	e04a                	sd	s2,0(sp)
    800050e6:	1000                	addi	s0,sp,32
    800050e8:	84aa                	mv	s1,a0
    800050ea:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800050ec:	ffffc097          	auipc	ra,0xffffc
    800050f0:	d34080e7          	jalr	-716(ra) # 80000e20 <acquire>
  if(writable){
    800050f4:	02090d63          	beqz	s2,8000512e <pipeclose+0x52>
    pi->writeopen = 0;
    800050f8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800050fc:	21848513          	addi	a0,s1,536
    80005100:	ffffd097          	auipc	ra,0xffffd
    80005104:	43a080e7          	jalr	1082(ra) # 8000253a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005108:	2204b783          	ld	a5,544(s1)
    8000510c:	eb95                	bnez	a5,80005140 <pipeclose+0x64>
    release(&pi->lock);
    8000510e:	8526                	mv	a0,s1
    80005110:	ffffc097          	auipc	ra,0xffffc
    80005114:	dc4080e7          	jalr	-572(ra) # 80000ed4 <release>
    kfree((char*)pi);
    80005118:	8526                	mv	a0,s1
    8000511a:	ffffc097          	auipc	ra,0xffffc
    8000511e:	994080e7          	jalr	-1644(ra) # 80000aae <kfree>
  } else
    release(&pi->lock);
}
    80005122:	60e2                	ld	ra,24(sp)
    80005124:	6442                	ld	s0,16(sp)
    80005126:	64a2                	ld	s1,8(sp)
    80005128:	6902                	ld	s2,0(sp)
    8000512a:	6105                	addi	sp,sp,32
    8000512c:	8082                	ret
    pi->readopen = 0;
    8000512e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005132:	21c48513          	addi	a0,s1,540
    80005136:	ffffd097          	auipc	ra,0xffffd
    8000513a:	404080e7          	jalr	1028(ra) # 8000253a <wakeup>
    8000513e:	b7e9                	j	80005108 <pipeclose+0x2c>
    release(&pi->lock);
    80005140:	8526                	mv	a0,s1
    80005142:	ffffc097          	auipc	ra,0xffffc
    80005146:	d92080e7          	jalr	-622(ra) # 80000ed4 <release>
}
    8000514a:	bfe1                	j	80005122 <pipeclose+0x46>

000000008000514c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000514c:	711d                	addi	sp,sp,-96
    8000514e:	ec86                	sd	ra,88(sp)
    80005150:	e8a2                	sd	s0,80(sp)
    80005152:	e4a6                	sd	s1,72(sp)
    80005154:	e0ca                	sd	s2,64(sp)
    80005156:	fc4e                	sd	s3,56(sp)
    80005158:	f852                	sd	s4,48(sp)
    8000515a:	f456                	sd	s5,40(sp)
    8000515c:	1080                	addi	s0,sp,96
    8000515e:	84aa                	mv	s1,a0
    80005160:	8aae                	mv	s5,a1
    80005162:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005164:	ffffd097          	auipc	ra,0xffffd
    80005168:	bc0080e7          	jalr	-1088(ra) # 80001d24 <myproc>
    8000516c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000516e:	8526                	mv	a0,s1
    80005170:	ffffc097          	auipc	ra,0xffffc
    80005174:	cb0080e7          	jalr	-848(ra) # 80000e20 <acquire>
  while(i < n){
    80005178:	0d405863          	blez	s4,80005248 <pipewrite+0xfc>
    8000517c:	f05a                	sd	s6,32(sp)
    8000517e:	ec5e                	sd	s7,24(sp)
    80005180:	e862                	sd	s8,16(sp)
  int i = 0;
    80005182:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005184:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005186:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000518a:	21c48b93          	addi	s7,s1,540
    8000518e:	a089                	j	800051d0 <pipewrite+0x84>
      release(&pi->lock);
    80005190:	8526                	mv	a0,s1
    80005192:	ffffc097          	auipc	ra,0xffffc
    80005196:	d42080e7          	jalr	-702(ra) # 80000ed4 <release>
      return -1;
    8000519a:	597d                	li	s2,-1
    8000519c:	7b02                	ld	s6,32(sp)
    8000519e:	6be2                	ld	s7,24(sp)
    800051a0:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800051a2:	854a                	mv	a0,s2
    800051a4:	60e6                	ld	ra,88(sp)
    800051a6:	6446                	ld	s0,80(sp)
    800051a8:	64a6                	ld	s1,72(sp)
    800051aa:	6906                	ld	s2,64(sp)
    800051ac:	79e2                	ld	s3,56(sp)
    800051ae:	7a42                	ld	s4,48(sp)
    800051b0:	7aa2                	ld	s5,40(sp)
    800051b2:	6125                	addi	sp,sp,96
    800051b4:	8082                	ret
      wakeup(&pi->nread);
    800051b6:	8562                	mv	a0,s8
    800051b8:	ffffd097          	auipc	ra,0xffffd
    800051bc:	382080e7          	jalr	898(ra) # 8000253a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800051c0:	85a6                	mv	a1,s1
    800051c2:	855e                	mv	a0,s7
    800051c4:	ffffd097          	auipc	ra,0xffffd
    800051c8:	312080e7          	jalr	786(ra) # 800024d6 <sleep>
  while(i < n){
    800051cc:	05495f63          	bge	s2,s4,8000522a <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    800051d0:	2204a783          	lw	a5,544(s1)
    800051d4:	dfd5                	beqz	a5,80005190 <pipewrite+0x44>
    800051d6:	854e                	mv	a0,s3
    800051d8:	ffffd097          	auipc	ra,0xffffd
    800051dc:	5a6080e7          	jalr	1446(ra) # 8000277e <killed>
    800051e0:	f945                	bnez	a0,80005190 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800051e2:	2184a783          	lw	a5,536(s1)
    800051e6:	21c4a703          	lw	a4,540(s1)
    800051ea:	2007879b          	addiw	a5,a5,512
    800051ee:	fcf704e3          	beq	a4,a5,800051b6 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800051f2:	4685                	li	a3,1
    800051f4:	01590633          	add	a2,s2,s5
    800051f8:	faf40593          	addi	a1,s0,-81
    800051fc:	0509b503          	ld	a0,80(s3)
    80005200:	ffffc097          	auipc	ra,0xffffc
    80005204:	754080e7          	jalr	1876(ra) # 80001954 <copyin>
    80005208:	05650263          	beq	a0,s6,8000524c <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000520c:	21c4a783          	lw	a5,540(s1)
    80005210:	0017871b          	addiw	a4,a5,1
    80005214:	20e4ae23          	sw	a4,540(s1)
    80005218:	1ff7f793          	andi	a5,a5,511
    8000521c:	97a6                	add	a5,a5,s1
    8000521e:	faf44703          	lbu	a4,-81(s0)
    80005222:	00e78c23          	sb	a4,24(a5)
      i++;
    80005226:	2905                	addiw	s2,s2,1
    80005228:	b755                	j	800051cc <pipewrite+0x80>
    8000522a:	7b02                	ld	s6,32(sp)
    8000522c:	6be2                	ld	s7,24(sp)
    8000522e:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80005230:	21848513          	addi	a0,s1,536
    80005234:	ffffd097          	auipc	ra,0xffffd
    80005238:	306080e7          	jalr	774(ra) # 8000253a <wakeup>
  release(&pi->lock);
    8000523c:	8526                	mv	a0,s1
    8000523e:	ffffc097          	auipc	ra,0xffffc
    80005242:	c96080e7          	jalr	-874(ra) # 80000ed4 <release>
  return i;
    80005246:	bfb1                	j	800051a2 <pipewrite+0x56>
  int i = 0;
    80005248:	4901                	li	s2,0
    8000524a:	b7dd                	j	80005230 <pipewrite+0xe4>
    8000524c:	7b02                	ld	s6,32(sp)
    8000524e:	6be2                	ld	s7,24(sp)
    80005250:	6c42                	ld	s8,16(sp)
    80005252:	bff9                	j	80005230 <pipewrite+0xe4>

0000000080005254 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005254:	715d                	addi	sp,sp,-80
    80005256:	e486                	sd	ra,72(sp)
    80005258:	e0a2                	sd	s0,64(sp)
    8000525a:	fc26                	sd	s1,56(sp)
    8000525c:	f84a                	sd	s2,48(sp)
    8000525e:	f44e                	sd	s3,40(sp)
    80005260:	f052                	sd	s4,32(sp)
    80005262:	ec56                	sd	s5,24(sp)
    80005264:	0880                	addi	s0,sp,80
    80005266:	84aa                	mv	s1,a0
    80005268:	892e                	mv	s2,a1
    8000526a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000526c:	ffffd097          	auipc	ra,0xffffd
    80005270:	ab8080e7          	jalr	-1352(ra) # 80001d24 <myproc>
    80005274:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005276:	8526                	mv	a0,s1
    80005278:	ffffc097          	auipc	ra,0xffffc
    8000527c:	ba8080e7          	jalr	-1112(ra) # 80000e20 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005280:	2184a703          	lw	a4,536(s1)
    80005284:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005288:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000528c:	02f71963          	bne	a4,a5,800052be <piperead+0x6a>
    80005290:	2244a783          	lw	a5,548(s1)
    80005294:	cf95                	beqz	a5,800052d0 <piperead+0x7c>
    if(killed(pr)){
    80005296:	8552                	mv	a0,s4
    80005298:	ffffd097          	auipc	ra,0xffffd
    8000529c:	4e6080e7          	jalr	1254(ra) # 8000277e <killed>
    800052a0:	e10d                	bnez	a0,800052c2 <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800052a2:	85a6                	mv	a1,s1
    800052a4:	854e                	mv	a0,s3
    800052a6:	ffffd097          	auipc	ra,0xffffd
    800052aa:	230080e7          	jalr	560(ra) # 800024d6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052ae:	2184a703          	lw	a4,536(s1)
    800052b2:	21c4a783          	lw	a5,540(s1)
    800052b6:	fcf70de3          	beq	a4,a5,80005290 <piperead+0x3c>
    800052ba:	e85a                	sd	s6,16(sp)
    800052bc:	a819                	j	800052d2 <piperead+0x7e>
    800052be:	e85a                	sd	s6,16(sp)
    800052c0:	a809                	j	800052d2 <piperead+0x7e>
      release(&pi->lock);
    800052c2:	8526                	mv	a0,s1
    800052c4:	ffffc097          	auipc	ra,0xffffc
    800052c8:	c10080e7          	jalr	-1008(ra) # 80000ed4 <release>
      return -1;
    800052cc:	59fd                	li	s3,-1
    800052ce:	a0a5                	j	80005336 <piperead+0xe2>
    800052d0:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800052d2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800052d4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800052d6:	05505463          	blez	s5,8000531e <piperead+0xca>
    if(pi->nread == pi->nwrite)
    800052da:	2184a783          	lw	a5,536(s1)
    800052de:	21c4a703          	lw	a4,540(s1)
    800052e2:	02f70e63          	beq	a4,a5,8000531e <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800052e6:	0017871b          	addiw	a4,a5,1
    800052ea:	20e4ac23          	sw	a4,536(s1)
    800052ee:	1ff7f793          	andi	a5,a5,511
    800052f2:	97a6                	add	a5,a5,s1
    800052f4:	0187c783          	lbu	a5,24(a5)
    800052f8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800052fc:	4685                	li	a3,1
    800052fe:	fbf40613          	addi	a2,s0,-65
    80005302:	85ca                	mv	a1,s2
    80005304:	050a3503          	ld	a0,80(s4)
    80005308:	ffffc097          	auipc	ra,0xffffc
    8000530c:	5c0080e7          	jalr	1472(ra) # 800018c8 <copyout>
    80005310:	01650763          	beq	a0,s6,8000531e <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005314:	2985                	addiw	s3,s3,1
    80005316:	0905                	addi	s2,s2,1
    80005318:	fd3a91e3          	bne	s5,s3,800052da <piperead+0x86>
    8000531c:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000531e:	21c48513          	addi	a0,s1,540
    80005322:	ffffd097          	auipc	ra,0xffffd
    80005326:	218080e7          	jalr	536(ra) # 8000253a <wakeup>
  release(&pi->lock);
    8000532a:	8526                	mv	a0,s1
    8000532c:	ffffc097          	auipc	ra,0xffffc
    80005330:	ba8080e7          	jalr	-1112(ra) # 80000ed4 <release>
    80005334:	6b42                	ld	s6,16(sp)
  return i;
}
    80005336:	854e                	mv	a0,s3
    80005338:	60a6                	ld	ra,72(sp)
    8000533a:	6406                	ld	s0,64(sp)
    8000533c:	74e2                	ld	s1,56(sp)
    8000533e:	7942                	ld	s2,48(sp)
    80005340:	79a2                	ld	s3,40(sp)
    80005342:	7a02                	ld	s4,32(sp)
    80005344:	6ae2                	ld	s5,24(sp)
    80005346:	6161                	addi	sp,sp,80
    80005348:	8082                	ret

000000008000534a <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000534a:	1141                	addi	sp,sp,-16
    8000534c:	e422                	sd	s0,8(sp)
    8000534e:	0800                	addi	s0,sp,16
    80005350:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005352:	8905                	andi	a0,a0,1
    80005354:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005356:	8b89                	andi	a5,a5,2
    80005358:	c399                	beqz	a5,8000535e <flags2perm+0x14>
      perm |= PTE_W;
    8000535a:	00456513          	ori	a0,a0,4
    return perm;
}
    8000535e:	6422                	ld	s0,8(sp)
    80005360:	0141                	addi	sp,sp,16
    80005362:	8082                	ret

0000000080005364 <exec>:

int
exec(char *path, char **argv)
{
    80005364:	df010113          	addi	sp,sp,-528
    80005368:	20113423          	sd	ra,520(sp)
    8000536c:	20813023          	sd	s0,512(sp)
    80005370:	ffa6                	sd	s1,504(sp)
    80005372:	fbca                	sd	s2,496(sp)
    80005374:	0c00                	addi	s0,sp,528
    80005376:	892a                	mv	s2,a0
    80005378:	dea43c23          	sd	a0,-520(s0)
    8000537c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005380:	ffffd097          	auipc	ra,0xffffd
    80005384:	9a4080e7          	jalr	-1628(ra) # 80001d24 <myproc>
    80005388:	84aa                	mv	s1,a0

  begin_op();
    8000538a:	fffff097          	auipc	ra,0xfffff
    8000538e:	43a080e7          	jalr	1082(ra) # 800047c4 <begin_op>

  if((ip = namei(path)) == 0){
    80005392:	854a                	mv	a0,s2
    80005394:	fffff097          	auipc	ra,0xfffff
    80005398:	230080e7          	jalr	560(ra) # 800045c4 <namei>
    8000539c:	c135                	beqz	a0,80005400 <exec+0x9c>
    8000539e:	f3d2                	sd	s4,480(sp)
    800053a0:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800053a2:	fffff097          	auipc	ra,0xfffff
    800053a6:	a54080e7          	jalr	-1452(ra) # 80003df6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800053aa:	04000713          	li	a4,64
    800053ae:	4681                	li	a3,0
    800053b0:	e5040613          	addi	a2,s0,-432
    800053b4:	4581                	li	a1,0
    800053b6:	8552                	mv	a0,s4
    800053b8:	fffff097          	auipc	ra,0xfffff
    800053bc:	cf6080e7          	jalr	-778(ra) # 800040ae <readi>
    800053c0:	04000793          	li	a5,64
    800053c4:	00f51a63          	bne	a0,a5,800053d8 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800053c8:	e5042703          	lw	a4,-432(s0)
    800053cc:	464c47b7          	lui	a5,0x464c4
    800053d0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800053d4:	02f70c63          	beq	a4,a5,8000540c <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800053d8:	8552                	mv	a0,s4
    800053da:	fffff097          	auipc	ra,0xfffff
    800053de:	c82080e7          	jalr	-894(ra) # 8000405c <iunlockput>
    end_op();
    800053e2:	fffff097          	auipc	ra,0xfffff
    800053e6:	45c080e7          	jalr	1116(ra) # 8000483e <end_op>
  }
  return -1;
    800053ea:	557d                	li	a0,-1
    800053ec:	7a1e                	ld	s4,480(sp)
}
    800053ee:	20813083          	ld	ra,520(sp)
    800053f2:	20013403          	ld	s0,512(sp)
    800053f6:	74fe                	ld	s1,504(sp)
    800053f8:	795e                	ld	s2,496(sp)
    800053fa:	21010113          	addi	sp,sp,528
    800053fe:	8082                	ret
    end_op();
    80005400:	fffff097          	auipc	ra,0xfffff
    80005404:	43e080e7          	jalr	1086(ra) # 8000483e <end_op>
    return -1;
    80005408:	557d                	li	a0,-1
    8000540a:	b7d5                	j	800053ee <exec+0x8a>
    8000540c:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000540e:	8526                	mv	a0,s1
    80005410:	ffffd097          	auipc	ra,0xffffd
    80005414:	9d8080e7          	jalr	-1576(ra) # 80001de8 <proc_pagetable>
    80005418:	8b2a                	mv	s6,a0
    8000541a:	30050f63          	beqz	a0,80005738 <exec+0x3d4>
    8000541e:	f7ce                	sd	s3,488(sp)
    80005420:	efd6                	sd	s5,472(sp)
    80005422:	e7de                	sd	s7,456(sp)
    80005424:	e3e2                	sd	s8,448(sp)
    80005426:	ff66                	sd	s9,440(sp)
    80005428:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000542a:	e7042d03          	lw	s10,-400(s0)
    8000542e:	e8845783          	lhu	a5,-376(s0)
    80005432:	14078d63          	beqz	a5,8000558c <exec+0x228>
    80005436:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005438:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000543a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    8000543c:	6c85                	lui	s9,0x1
    8000543e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005442:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005446:	6a85                	lui	s5,0x1
    80005448:	a0b5                	j	800054b4 <exec+0x150>
      panic("loadseg: address should exist");
    8000544a:	00003517          	auipc	a0,0x3
    8000544e:	2a650513          	addi	a0,a0,678 # 800086f0 <__func__.1+0x6e8>
    80005452:	ffffb097          	auipc	ra,0xffffb
    80005456:	10e080e7          	jalr	270(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    8000545a:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000545c:	8726                	mv	a4,s1
    8000545e:	012c06bb          	addw	a3,s8,s2
    80005462:	4581                	li	a1,0
    80005464:	8552                	mv	a0,s4
    80005466:	fffff097          	auipc	ra,0xfffff
    8000546a:	c48080e7          	jalr	-952(ra) # 800040ae <readi>
    8000546e:	2501                	sext.w	a0,a0
    80005470:	28a49863          	bne	s1,a0,80005700 <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    80005474:	012a893b          	addw	s2,s5,s2
    80005478:	03397563          	bgeu	s2,s3,800054a2 <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    8000547c:	02091593          	slli	a1,s2,0x20
    80005480:	9181                	srli	a1,a1,0x20
    80005482:	95de                	add	a1,a1,s7
    80005484:	855a                	mv	a0,s6
    80005486:	ffffc097          	auipc	ra,0xffffc
    8000548a:	e18080e7          	jalr	-488(ra) # 8000129e <walkaddr>
    8000548e:	862a                	mv	a2,a0
    if(pa == 0)
    80005490:	dd4d                	beqz	a0,8000544a <exec+0xe6>
    if(sz - i < PGSIZE)
    80005492:	412984bb          	subw	s1,s3,s2
    80005496:	0004879b          	sext.w	a5,s1
    8000549a:	fcfcf0e3          	bgeu	s9,a5,8000545a <exec+0xf6>
    8000549e:	84d6                	mv	s1,s5
    800054a0:	bf6d                	j	8000545a <exec+0xf6>
    sz = sz1;
    800054a2:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054a6:	2d85                	addiw	s11,s11,1
    800054a8:	038d0d1b          	addiw	s10,s10,56
    800054ac:	e8845783          	lhu	a5,-376(s0)
    800054b0:	08fdd663          	bge	s11,a5,8000553c <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800054b4:	2d01                	sext.w	s10,s10
    800054b6:	03800713          	li	a4,56
    800054ba:	86ea                	mv	a3,s10
    800054bc:	e1840613          	addi	a2,s0,-488
    800054c0:	4581                	li	a1,0
    800054c2:	8552                	mv	a0,s4
    800054c4:	fffff097          	auipc	ra,0xfffff
    800054c8:	bea080e7          	jalr	-1046(ra) # 800040ae <readi>
    800054cc:	03800793          	li	a5,56
    800054d0:	20f51063          	bne	a0,a5,800056d0 <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    800054d4:	e1842783          	lw	a5,-488(s0)
    800054d8:	4705                	li	a4,1
    800054da:	fce796e3          	bne	a5,a4,800054a6 <exec+0x142>
    if(ph.memsz < ph.filesz)
    800054de:	e4043483          	ld	s1,-448(s0)
    800054e2:	e3843783          	ld	a5,-456(s0)
    800054e6:	1ef4e963          	bltu	s1,a5,800056d8 <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800054ea:	e2843783          	ld	a5,-472(s0)
    800054ee:	94be                	add	s1,s1,a5
    800054f0:	1ef4e863          	bltu	s1,a5,800056e0 <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    800054f4:	df043703          	ld	a4,-528(s0)
    800054f8:	8ff9                	and	a5,a5,a4
    800054fa:	1e079763          	bnez	a5,800056e8 <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800054fe:	e1c42503          	lw	a0,-484(s0)
    80005502:	00000097          	auipc	ra,0x0
    80005506:	e48080e7          	jalr	-440(ra) # 8000534a <flags2perm>
    8000550a:	86aa                	mv	a3,a0
    8000550c:	8626                	mv	a2,s1
    8000550e:	85ca                	mv	a1,s2
    80005510:	855a                	mv	a0,s6
    80005512:	ffffc097          	auipc	ra,0xffffc
    80005516:	150080e7          	jalr	336(ra) # 80001662 <uvmalloc>
    8000551a:	e0a43423          	sd	a0,-504(s0)
    8000551e:	1c050963          	beqz	a0,800056f0 <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005522:	e2843b83          	ld	s7,-472(s0)
    80005526:	e2042c03          	lw	s8,-480(s0)
    8000552a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000552e:	00098463          	beqz	s3,80005536 <exec+0x1d2>
    80005532:	4901                	li	s2,0
    80005534:	b7a1                	j	8000547c <exec+0x118>
    sz = sz1;
    80005536:	e0843903          	ld	s2,-504(s0)
    8000553a:	b7b5                	j	800054a6 <exec+0x142>
    8000553c:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000553e:	8552                	mv	a0,s4
    80005540:	fffff097          	auipc	ra,0xfffff
    80005544:	b1c080e7          	jalr	-1252(ra) # 8000405c <iunlockput>
  end_op();
    80005548:	fffff097          	auipc	ra,0xfffff
    8000554c:	2f6080e7          	jalr	758(ra) # 8000483e <end_op>
  p = myproc();
    80005550:	ffffc097          	auipc	ra,0xffffc
    80005554:	7d4080e7          	jalr	2004(ra) # 80001d24 <myproc>
    80005558:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000555a:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000555e:	6985                	lui	s3,0x1
    80005560:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005562:	99ca                	add	s3,s3,s2
    80005564:	77fd                	lui	a5,0xfffff
    80005566:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000556a:	4691                	li	a3,4
    8000556c:	6609                	lui	a2,0x2
    8000556e:	964e                	add	a2,a2,s3
    80005570:	85ce                	mv	a1,s3
    80005572:	855a                	mv	a0,s6
    80005574:	ffffc097          	auipc	ra,0xffffc
    80005578:	0ee080e7          	jalr	238(ra) # 80001662 <uvmalloc>
    8000557c:	892a                	mv	s2,a0
    8000557e:	e0a43423          	sd	a0,-504(s0)
    80005582:	e519                	bnez	a0,80005590 <exec+0x22c>
  if(pagetable)
    80005584:	e1343423          	sd	s3,-504(s0)
    80005588:	4a01                	li	s4,0
    8000558a:	aaa5                	j	80005702 <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000558c:	4901                	li	s2,0
    8000558e:	bf45                	j	8000553e <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005590:	75f9                	lui	a1,0xffffe
    80005592:	95aa                	add	a1,a1,a0
    80005594:	855a                	mv	a0,s6
    80005596:	ffffc097          	auipc	ra,0xffffc
    8000559a:	300080e7          	jalr	768(ra) # 80001896 <uvmclear>
  stackbase = sp - PGSIZE;
    8000559e:	7bfd                	lui	s7,0xfffff
    800055a0:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800055a2:	e0043783          	ld	a5,-512(s0)
    800055a6:	6388                	ld	a0,0(a5)
    800055a8:	c52d                	beqz	a0,80005612 <exec+0x2ae>
    800055aa:	e9040993          	addi	s3,s0,-368
    800055ae:	f9040c13          	addi	s8,s0,-112
    800055b2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800055b4:	ffffc097          	auipc	ra,0xffffc
    800055b8:	adc080e7          	jalr	-1316(ra) # 80001090 <strlen>
    800055bc:	0015079b          	addiw	a5,a0,1
    800055c0:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800055c4:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800055c8:	13796863          	bltu	s2,s7,800056f8 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800055cc:	e0043d03          	ld	s10,-512(s0)
    800055d0:	000d3a03          	ld	s4,0(s10)
    800055d4:	8552                	mv	a0,s4
    800055d6:	ffffc097          	auipc	ra,0xffffc
    800055da:	aba080e7          	jalr	-1350(ra) # 80001090 <strlen>
    800055de:	0015069b          	addiw	a3,a0,1
    800055e2:	8652                	mv	a2,s4
    800055e4:	85ca                	mv	a1,s2
    800055e6:	855a                	mv	a0,s6
    800055e8:	ffffc097          	auipc	ra,0xffffc
    800055ec:	2e0080e7          	jalr	736(ra) # 800018c8 <copyout>
    800055f0:	10054663          	bltz	a0,800056fc <exec+0x398>
    ustack[argc] = sp;
    800055f4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800055f8:	0485                	addi	s1,s1,1
    800055fa:	008d0793          	addi	a5,s10,8
    800055fe:	e0f43023          	sd	a5,-512(s0)
    80005602:	008d3503          	ld	a0,8(s10)
    80005606:	c909                	beqz	a0,80005618 <exec+0x2b4>
    if(argc >= MAXARG)
    80005608:	09a1                	addi	s3,s3,8
    8000560a:	fb8995e3          	bne	s3,s8,800055b4 <exec+0x250>
  ip = 0;
    8000560e:	4a01                	li	s4,0
    80005610:	a8cd                	j	80005702 <exec+0x39e>
  sp = sz;
    80005612:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005616:	4481                	li	s1,0
  ustack[argc] = 0;
    80005618:	00349793          	slli	a5,s1,0x3
    8000561c:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd2548>
    80005620:	97a2                	add	a5,a5,s0
    80005622:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005626:	00148693          	addi	a3,s1,1
    8000562a:	068e                	slli	a3,a3,0x3
    8000562c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005630:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005634:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005638:	f57966e3          	bltu	s2,s7,80005584 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000563c:	e9040613          	addi	a2,s0,-368
    80005640:	85ca                	mv	a1,s2
    80005642:	855a                	mv	a0,s6
    80005644:	ffffc097          	auipc	ra,0xffffc
    80005648:	284080e7          	jalr	644(ra) # 800018c8 <copyout>
    8000564c:	0e054863          	bltz	a0,8000573c <exec+0x3d8>
  p->trapframe->a1 = sp;
    80005650:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005654:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005658:	df843783          	ld	a5,-520(s0)
    8000565c:	0007c703          	lbu	a4,0(a5)
    80005660:	cf11                	beqz	a4,8000567c <exec+0x318>
    80005662:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005664:	02f00693          	li	a3,47
    80005668:	a039                	j	80005676 <exec+0x312>
      last = s+1;
    8000566a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000566e:	0785                	addi	a5,a5,1
    80005670:	fff7c703          	lbu	a4,-1(a5)
    80005674:	c701                	beqz	a4,8000567c <exec+0x318>
    if(*s == '/')
    80005676:	fed71ce3          	bne	a4,a3,8000566e <exec+0x30a>
    8000567a:	bfc5                	j	8000566a <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    8000567c:	4641                	li	a2,16
    8000567e:	df843583          	ld	a1,-520(s0)
    80005682:	158a8513          	addi	a0,s5,344
    80005686:	ffffc097          	auipc	ra,0xffffc
    8000568a:	9d8080e7          	jalr	-1576(ra) # 8000105e <safestrcpy>
  oldpagetable = p->pagetable;
    8000568e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005692:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005696:	e0843783          	ld	a5,-504(s0)
    8000569a:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000569e:	058ab783          	ld	a5,88(s5)
    800056a2:	e6843703          	ld	a4,-408(s0)
    800056a6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800056a8:	058ab783          	ld	a5,88(s5)
    800056ac:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800056b0:	85e6                	mv	a1,s9
    800056b2:	ffffc097          	auipc	ra,0xffffc
    800056b6:	7d2080e7          	jalr	2002(ra) # 80001e84 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800056ba:	0004851b          	sext.w	a0,s1
    800056be:	79be                	ld	s3,488(sp)
    800056c0:	7a1e                	ld	s4,480(sp)
    800056c2:	6afe                	ld	s5,472(sp)
    800056c4:	6b5e                	ld	s6,464(sp)
    800056c6:	6bbe                	ld	s7,456(sp)
    800056c8:	6c1e                	ld	s8,448(sp)
    800056ca:	7cfa                	ld	s9,440(sp)
    800056cc:	7d5a                	ld	s10,432(sp)
    800056ce:	b305                	j	800053ee <exec+0x8a>
    800056d0:	e1243423          	sd	s2,-504(s0)
    800056d4:	7dba                	ld	s11,424(sp)
    800056d6:	a035                	j	80005702 <exec+0x39e>
    800056d8:	e1243423          	sd	s2,-504(s0)
    800056dc:	7dba                	ld	s11,424(sp)
    800056de:	a015                	j	80005702 <exec+0x39e>
    800056e0:	e1243423          	sd	s2,-504(s0)
    800056e4:	7dba                	ld	s11,424(sp)
    800056e6:	a831                	j	80005702 <exec+0x39e>
    800056e8:	e1243423          	sd	s2,-504(s0)
    800056ec:	7dba                	ld	s11,424(sp)
    800056ee:	a811                	j	80005702 <exec+0x39e>
    800056f0:	e1243423          	sd	s2,-504(s0)
    800056f4:	7dba                	ld	s11,424(sp)
    800056f6:	a031                	j	80005702 <exec+0x39e>
  ip = 0;
    800056f8:	4a01                	li	s4,0
    800056fa:	a021                	j	80005702 <exec+0x39e>
    800056fc:	4a01                	li	s4,0
  if(pagetable)
    800056fe:	a011                	j	80005702 <exec+0x39e>
    80005700:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005702:	e0843583          	ld	a1,-504(s0)
    80005706:	855a                	mv	a0,s6
    80005708:	ffffc097          	auipc	ra,0xffffc
    8000570c:	77c080e7          	jalr	1916(ra) # 80001e84 <proc_freepagetable>
  return -1;
    80005710:	557d                	li	a0,-1
  if(ip){
    80005712:	000a1b63          	bnez	s4,80005728 <exec+0x3c4>
    80005716:	79be                	ld	s3,488(sp)
    80005718:	7a1e                	ld	s4,480(sp)
    8000571a:	6afe                	ld	s5,472(sp)
    8000571c:	6b5e                	ld	s6,464(sp)
    8000571e:	6bbe                	ld	s7,456(sp)
    80005720:	6c1e                	ld	s8,448(sp)
    80005722:	7cfa                	ld	s9,440(sp)
    80005724:	7d5a                	ld	s10,432(sp)
    80005726:	b1e1                	j	800053ee <exec+0x8a>
    80005728:	79be                	ld	s3,488(sp)
    8000572a:	6afe                	ld	s5,472(sp)
    8000572c:	6b5e                	ld	s6,464(sp)
    8000572e:	6bbe                	ld	s7,456(sp)
    80005730:	6c1e                	ld	s8,448(sp)
    80005732:	7cfa                	ld	s9,440(sp)
    80005734:	7d5a                	ld	s10,432(sp)
    80005736:	b14d                	j	800053d8 <exec+0x74>
    80005738:	6b5e                	ld	s6,464(sp)
    8000573a:	b979                	j	800053d8 <exec+0x74>
  sz = sz1;
    8000573c:	e0843983          	ld	s3,-504(s0)
    80005740:	b591                	j	80005584 <exec+0x220>

0000000080005742 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005742:	7179                	addi	sp,sp,-48
    80005744:	f406                	sd	ra,40(sp)
    80005746:	f022                	sd	s0,32(sp)
    80005748:	ec26                	sd	s1,24(sp)
    8000574a:	e84a                	sd	s2,16(sp)
    8000574c:	1800                	addi	s0,sp,48
    8000574e:	892e                	mv	s2,a1
    80005750:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005752:	fdc40593          	addi	a1,s0,-36
    80005756:	ffffe097          	auipc	ra,0xffffe
    8000575a:	9b2080e7          	jalr	-1614(ra) # 80003108 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000575e:	fdc42703          	lw	a4,-36(s0)
    80005762:	47bd                	li	a5,15
    80005764:	02e7eb63          	bltu	a5,a4,8000579a <argfd+0x58>
    80005768:	ffffc097          	auipc	ra,0xffffc
    8000576c:	5bc080e7          	jalr	1468(ra) # 80001d24 <myproc>
    80005770:	fdc42703          	lw	a4,-36(s0)
    80005774:	01a70793          	addi	a5,a4,26
    80005778:	078e                	slli	a5,a5,0x3
    8000577a:	953e                	add	a0,a0,a5
    8000577c:	611c                	ld	a5,0(a0)
    8000577e:	c385                	beqz	a5,8000579e <argfd+0x5c>
    return -1;
  if(pfd)
    80005780:	00090463          	beqz	s2,80005788 <argfd+0x46>
    *pfd = fd;
    80005784:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005788:	4501                	li	a0,0
  if(pf)
    8000578a:	c091                	beqz	s1,8000578e <argfd+0x4c>
    *pf = f;
    8000578c:	e09c                	sd	a5,0(s1)
}
    8000578e:	70a2                	ld	ra,40(sp)
    80005790:	7402                	ld	s0,32(sp)
    80005792:	64e2                	ld	s1,24(sp)
    80005794:	6942                	ld	s2,16(sp)
    80005796:	6145                	addi	sp,sp,48
    80005798:	8082                	ret
    return -1;
    8000579a:	557d                	li	a0,-1
    8000579c:	bfcd                	j	8000578e <argfd+0x4c>
    8000579e:	557d                	li	a0,-1
    800057a0:	b7fd                	j	8000578e <argfd+0x4c>

00000000800057a2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800057a2:	1101                	addi	sp,sp,-32
    800057a4:	ec06                	sd	ra,24(sp)
    800057a6:	e822                	sd	s0,16(sp)
    800057a8:	e426                	sd	s1,8(sp)
    800057aa:	1000                	addi	s0,sp,32
    800057ac:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800057ae:	ffffc097          	auipc	ra,0xffffc
    800057b2:	576080e7          	jalr	1398(ra) # 80001d24 <myproc>
    800057b6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800057b8:	0d050793          	addi	a5,a0,208
    800057bc:	4501                	li	a0,0
    800057be:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800057c0:	6398                	ld	a4,0(a5)
    800057c2:	cb19                	beqz	a4,800057d8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800057c4:	2505                	addiw	a0,a0,1
    800057c6:	07a1                	addi	a5,a5,8
    800057c8:	fed51ce3          	bne	a0,a3,800057c0 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800057cc:	557d                	li	a0,-1
}
    800057ce:	60e2                	ld	ra,24(sp)
    800057d0:	6442                	ld	s0,16(sp)
    800057d2:	64a2                	ld	s1,8(sp)
    800057d4:	6105                	addi	sp,sp,32
    800057d6:	8082                	ret
      p->ofile[fd] = f;
    800057d8:	01a50793          	addi	a5,a0,26
    800057dc:	078e                	slli	a5,a5,0x3
    800057de:	963e                	add	a2,a2,a5
    800057e0:	e204                	sd	s1,0(a2)
      return fd;
    800057e2:	b7f5                	j	800057ce <fdalloc+0x2c>

00000000800057e4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800057e4:	715d                	addi	sp,sp,-80
    800057e6:	e486                	sd	ra,72(sp)
    800057e8:	e0a2                	sd	s0,64(sp)
    800057ea:	fc26                	sd	s1,56(sp)
    800057ec:	f84a                	sd	s2,48(sp)
    800057ee:	f44e                	sd	s3,40(sp)
    800057f0:	ec56                	sd	s5,24(sp)
    800057f2:	e85a                	sd	s6,16(sp)
    800057f4:	0880                	addi	s0,sp,80
    800057f6:	8b2e                	mv	s6,a1
    800057f8:	89b2                	mv	s3,a2
    800057fa:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800057fc:	fb040593          	addi	a1,s0,-80
    80005800:	fffff097          	auipc	ra,0xfffff
    80005804:	de2080e7          	jalr	-542(ra) # 800045e2 <nameiparent>
    80005808:	84aa                	mv	s1,a0
    8000580a:	14050e63          	beqz	a0,80005966 <create+0x182>
    return 0;

  ilock(dp);
    8000580e:	ffffe097          	auipc	ra,0xffffe
    80005812:	5e8080e7          	jalr	1512(ra) # 80003df6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005816:	4601                	li	a2,0
    80005818:	fb040593          	addi	a1,s0,-80
    8000581c:	8526                	mv	a0,s1
    8000581e:	fffff097          	auipc	ra,0xfffff
    80005822:	ae4080e7          	jalr	-1308(ra) # 80004302 <dirlookup>
    80005826:	8aaa                	mv	s5,a0
    80005828:	c539                	beqz	a0,80005876 <create+0x92>
    iunlockput(dp);
    8000582a:	8526                	mv	a0,s1
    8000582c:	fffff097          	auipc	ra,0xfffff
    80005830:	830080e7          	jalr	-2000(ra) # 8000405c <iunlockput>
    ilock(ip);
    80005834:	8556                	mv	a0,s5
    80005836:	ffffe097          	auipc	ra,0xffffe
    8000583a:	5c0080e7          	jalr	1472(ra) # 80003df6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000583e:	4789                	li	a5,2
    80005840:	02fb1463          	bne	s6,a5,80005868 <create+0x84>
    80005844:	044ad783          	lhu	a5,68(s5)
    80005848:	37f9                	addiw	a5,a5,-2
    8000584a:	17c2                	slli	a5,a5,0x30
    8000584c:	93c1                	srli	a5,a5,0x30
    8000584e:	4705                	li	a4,1
    80005850:	00f76c63          	bltu	a4,a5,80005868 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005854:	8556                	mv	a0,s5
    80005856:	60a6                	ld	ra,72(sp)
    80005858:	6406                	ld	s0,64(sp)
    8000585a:	74e2                	ld	s1,56(sp)
    8000585c:	7942                	ld	s2,48(sp)
    8000585e:	79a2                	ld	s3,40(sp)
    80005860:	6ae2                	ld	s5,24(sp)
    80005862:	6b42                	ld	s6,16(sp)
    80005864:	6161                	addi	sp,sp,80
    80005866:	8082                	ret
    iunlockput(ip);
    80005868:	8556                	mv	a0,s5
    8000586a:	ffffe097          	auipc	ra,0xffffe
    8000586e:	7f2080e7          	jalr	2034(ra) # 8000405c <iunlockput>
    return 0;
    80005872:	4a81                	li	s5,0
    80005874:	b7c5                	j	80005854 <create+0x70>
    80005876:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005878:	85da                	mv	a1,s6
    8000587a:	4088                	lw	a0,0(s1)
    8000587c:	ffffe097          	auipc	ra,0xffffe
    80005880:	3d6080e7          	jalr	982(ra) # 80003c52 <ialloc>
    80005884:	8a2a                	mv	s4,a0
    80005886:	c531                	beqz	a0,800058d2 <create+0xee>
  ilock(ip);
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	56e080e7          	jalr	1390(ra) # 80003df6 <ilock>
  ip->major = major;
    80005890:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005894:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005898:	4905                	li	s2,1
    8000589a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000589e:	8552                	mv	a0,s4
    800058a0:	ffffe097          	auipc	ra,0xffffe
    800058a4:	48a080e7          	jalr	1162(ra) # 80003d2a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800058a8:	032b0d63          	beq	s6,s2,800058e2 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800058ac:	004a2603          	lw	a2,4(s4)
    800058b0:	fb040593          	addi	a1,s0,-80
    800058b4:	8526                	mv	a0,s1
    800058b6:	fffff097          	auipc	ra,0xfffff
    800058ba:	c5c080e7          	jalr	-932(ra) # 80004512 <dirlink>
    800058be:	08054163          	bltz	a0,80005940 <create+0x15c>
  iunlockput(dp);
    800058c2:	8526                	mv	a0,s1
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	798080e7          	jalr	1944(ra) # 8000405c <iunlockput>
  return ip;
    800058cc:	8ad2                	mv	s5,s4
    800058ce:	7a02                	ld	s4,32(sp)
    800058d0:	b751                	j	80005854 <create+0x70>
    iunlockput(dp);
    800058d2:	8526                	mv	a0,s1
    800058d4:	ffffe097          	auipc	ra,0xffffe
    800058d8:	788080e7          	jalr	1928(ra) # 8000405c <iunlockput>
    return 0;
    800058dc:	8ad2                	mv	s5,s4
    800058de:	7a02                	ld	s4,32(sp)
    800058e0:	bf95                	j	80005854 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800058e2:	004a2603          	lw	a2,4(s4)
    800058e6:	00003597          	auipc	a1,0x3
    800058ea:	e2a58593          	addi	a1,a1,-470 # 80008710 <__func__.1+0x708>
    800058ee:	8552                	mv	a0,s4
    800058f0:	fffff097          	auipc	ra,0xfffff
    800058f4:	c22080e7          	jalr	-990(ra) # 80004512 <dirlink>
    800058f8:	04054463          	bltz	a0,80005940 <create+0x15c>
    800058fc:	40d0                	lw	a2,4(s1)
    800058fe:	00003597          	auipc	a1,0x3
    80005902:	e1a58593          	addi	a1,a1,-486 # 80008718 <__func__.1+0x710>
    80005906:	8552                	mv	a0,s4
    80005908:	fffff097          	auipc	ra,0xfffff
    8000590c:	c0a080e7          	jalr	-1014(ra) # 80004512 <dirlink>
    80005910:	02054863          	bltz	a0,80005940 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005914:	004a2603          	lw	a2,4(s4)
    80005918:	fb040593          	addi	a1,s0,-80
    8000591c:	8526                	mv	a0,s1
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	bf4080e7          	jalr	-1036(ra) # 80004512 <dirlink>
    80005926:	00054d63          	bltz	a0,80005940 <create+0x15c>
    dp->nlink++;  // for ".."
    8000592a:	04a4d783          	lhu	a5,74(s1)
    8000592e:	2785                	addiw	a5,a5,1
    80005930:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005934:	8526                	mv	a0,s1
    80005936:	ffffe097          	auipc	ra,0xffffe
    8000593a:	3f4080e7          	jalr	1012(ra) # 80003d2a <iupdate>
    8000593e:	b751                	j	800058c2 <create+0xde>
  ip->nlink = 0;
    80005940:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005944:	8552                	mv	a0,s4
    80005946:	ffffe097          	auipc	ra,0xffffe
    8000594a:	3e4080e7          	jalr	996(ra) # 80003d2a <iupdate>
  iunlockput(ip);
    8000594e:	8552                	mv	a0,s4
    80005950:	ffffe097          	auipc	ra,0xffffe
    80005954:	70c080e7          	jalr	1804(ra) # 8000405c <iunlockput>
  iunlockput(dp);
    80005958:	8526                	mv	a0,s1
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	702080e7          	jalr	1794(ra) # 8000405c <iunlockput>
  return 0;
    80005962:	7a02                	ld	s4,32(sp)
    80005964:	bdc5                	j	80005854 <create+0x70>
    return 0;
    80005966:	8aaa                	mv	s5,a0
    80005968:	b5f5                	j	80005854 <create+0x70>

000000008000596a <sys_dup>:
{
    8000596a:	7179                	addi	sp,sp,-48
    8000596c:	f406                	sd	ra,40(sp)
    8000596e:	f022                	sd	s0,32(sp)
    80005970:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005972:	fd840613          	addi	a2,s0,-40
    80005976:	4581                	li	a1,0
    80005978:	4501                	li	a0,0
    8000597a:	00000097          	auipc	ra,0x0
    8000597e:	dc8080e7          	jalr	-568(ra) # 80005742 <argfd>
    return -1;
    80005982:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005984:	02054763          	bltz	a0,800059b2 <sys_dup+0x48>
    80005988:	ec26                	sd	s1,24(sp)
    8000598a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000598c:	fd843903          	ld	s2,-40(s0)
    80005990:	854a                	mv	a0,s2
    80005992:	00000097          	auipc	ra,0x0
    80005996:	e10080e7          	jalr	-496(ra) # 800057a2 <fdalloc>
    8000599a:	84aa                	mv	s1,a0
    return -1;
    8000599c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000599e:	00054f63          	bltz	a0,800059bc <sys_dup+0x52>
  filedup(f);
    800059a2:	854a                	mv	a0,s2
    800059a4:	fffff097          	auipc	ra,0xfffff
    800059a8:	298080e7          	jalr	664(ra) # 80004c3c <filedup>
  return fd;
    800059ac:	87a6                	mv	a5,s1
    800059ae:	64e2                	ld	s1,24(sp)
    800059b0:	6942                	ld	s2,16(sp)
}
    800059b2:	853e                	mv	a0,a5
    800059b4:	70a2                	ld	ra,40(sp)
    800059b6:	7402                	ld	s0,32(sp)
    800059b8:	6145                	addi	sp,sp,48
    800059ba:	8082                	ret
    800059bc:	64e2                	ld	s1,24(sp)
    800059be:	6942                	ld	s2,16(sp)
    800059c0:	bfcd                	j	800059b2 <sys_dup+0x48>

00000000800059c2 <sys_read>:
{
    800059c2:	7179                	addi	sp,sp,-48
    800059c4:	f406                	sd	ra,40(sp)
    800059c6:	f022                	sd	s0,32(sp)
    800059c8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800059ca:	fd840593          	addi	a1,s0,-40
    800059ce:	4505                	li	a0,1
    800059d0:	ffffd097          	auipc	ra,0xffffd
    800059d4:	758080e7          	jalr	1880(ra) # 80003128 <argaddr>
  argint(2, &n);
    800059d8:	fe440593          	addi	a1,s0,-28
    800059dc:	4509                	li	a0,2
    800059de:	ffffd097          	auipc	ra,0xffffd
    800059e2:	72a080e7          	jalr	1834(ra) # 80003108 <argint>
  if(argfd(0, 0, &f) < 0)
    800059e6:	fe840613          	addi	a2,s0,-24
    800059ea:	4581                	li	a1,0
    800059ec:	4501                	li	a0,0
    800059ee:	00000097          	auipc	ra,0x0
    800059f2:	d54080e7          	jalr	-684(ra) # 80005742 <argfd>
    800059f6:	87aa                	mv	a5,a0
    return -1;
    800059f8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800059fa:	0007cc63          	bltz	a5,80005a12 <sys_read+0x50>
  return fileread(f, p, n);
    800059fe:	fe442603          	lw	a2,-28(s0)
    80005a02:	fd843583          	ld	a1,-40(s0)
    80005a06:	fe843503          	ld	a0,-24(s0)
    80005a0a:	fffff097          	auipc	ra,0xfffff
    80005a0e:	3d8080e7          	jalr	984(ra) # 80004de2 <fileread>
}
    80005a12:	70a2                	ld	ra,40(sp)
    80005a14:	7402                	ld	s0,32(sp)
    80005a16:	6145                	addi	sp,sp,48
    80005a18:	8082                	ret

0000000080005a1a <sys_write>:
{
    80005a1a:	7179                	addi	sp,sp,-48
    80005a1c:	f406                	sd	ra,40(sp)
    80005a1e:	f022                	sd	s0,32(sp)
    80005a20:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a22:	fd840593          	addi	a1,s0,-40
    80005a26:	4505                	li	a0,1
    80005a28:	ffffd097          	auipc	ra,0xffffd
    80005a2c:	700080e7          	jalr	1792(ra) # 80003128 <argaddr>
  argint(2, &n);
    80005a30:	fe440593          	addi	a1,s0,-28
    80005a34:	4509                	li	a0,2
    80005a36:	ffffd097          	auipc	ra,0xffffd
    80005a3a:	6d2080e7          	jalr	1746(ra) # 80003108 <argint>
  if(argfd(0, 0, &f) < 0)
    80005a3e:	fe840613          	addi	a2,s0,-24
    80005a42:	4581                	li	a1,0
    80005a44:	4501                	li	a0,0
    80005a46:	00000097          	auipc	ra,0x0
    80005a4a:	cfc080e7          	jalr	-772(ra) # 80005742 <argfd>
    80005a4e:	87aa                	mv	a5,a0
    return -1;
    80005a50:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a52:	0007cc63          	bltz	a5,80005a6a <sys_write+0x50>
  return filewrite(f, p, n);
    80005a56:	fe442603          	lw	a2,-28(s0)
    80005a5a:	fd843583          	ld	a1,-40(s0)
    80005a5e:	fe843503          	ld	a0,-24(s0)
    80005a62:	fffff097          	auipc	ra,0xfffff
    80005a66:	452080e7          	jalr	1106(ra) # 80004eb4 <filewrite>
}
    80005a6a:	70a2                	ld	ra,40(sp)
    80005a6c:	7402                	ld	s0,32(sp)
    80005a6e:	6145                	addi	sp,sp,48
    80005a70:	8082                	ret

0000000080005a72 <sys_close>:
{
    80005a72:	1101                	addi	sp,sp,-32
    80005a74:	ec06                	sd	ra,24(sp)
    80005a76:	e822                	sd	s0,16(sp)
    80005a78:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005a7a:	fe040613          	addi	a2,s0,-32
    80005a7e:	fec40593          	addi	a1,s0,-20
    80005a82:	4501                	li	a0,0
    80005a84:	00000097          	auipc	ra,0x0
    80005a88:	cbe080e7          	jalr	-834(ra) # 80005742 <argfd>
    return -1;
    80005a8c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005a8e:	02054463          	bltz	a0,80005ab6 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005a92:	ffffc097          	auipc	ra,0xffffc
    80005a96:	292080e7          	jalr	658(ra) # 80001d24 <myproc>
    80005a9a:	fec42783          	lw	a5,-20(s0)
    80005a9e:	07e9                	addi	a5,a5,26
    80005aa0:	078e                	slli	a5,a5,0x3
    80005aa2:	953e                	add	a0,a0,a5
    80005aa4:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005aa8:	fe043503          	ld	a0,-32(s0)
    80005aac:	fffff097          	auipc	ra,0xfffff
    80005ab0:	1e2080e7          	jalr	482(ra) # 80004c8e <fileclose>
  return 0;
    80005ab4:	4781                	li	a5,0
}
    80005ab6:	853e                	mv	a0,a5
    80005ab8:	60e2                	ld	ra,24(sp)
    80005aba:	6442                	ld	s0,16(sp)
    80005abc:	6105                	addi	sp,sp,32
    80005abe:	8082                	ret

0000000080005ac0 <sys_fstat>:
{
    80005ac0:	1101                	addi	sp,sp,-32
    80005ac2:	ec06                	sd	ra,24(sp)
    80005ac4:	e822                	sd	s0,16(sp)
    80005ac6:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005ac8:	fe040593          	addi	a1,s0,-32
    80005acc:	4505                	li	a0,1
    80005ace:	ffffd097          	auipc	ra,0xffffd
    80005ad2:	65a080e7          	jalr	1626(ra) # 80003128 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005ad6:	fe840613          	addi	a2,s0,-24
    80005ada:	4581                	li	a1,0
    80005adc:	4501                	li	a0,0
    80005ade:	00000097          	auipc	ra,0x0
    80005ae2:	c64080e7          	jalr	-924(ra) # 80005742 <argfd>
    80005ae6:	87aa                	mv	a5,a0
    return -1;
    80005ae8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005aea:	0007ca63          	bltz	a5,80005afe <sys_fstat+0x3e>
  return filestat(f, st);
    80005aee:	fe043583          	ld	a1,-32(s0)
    80005af2:	fe843503          	ld	a0,-24(s0)
    80005af6:	fffff097          	auipc	ra,0xfffff
    80005afa:	27a080e7          	jalr	634(ra) # 80004d70 <filestat>
}
    80005afe:	60e2                	ld	ra,24(sp)
    80005b00:	6442                	ld	s0,16(sp)
    80005b02:	6105                	addi	sp,sp,32
    80005b04:	8082                	ret

0000000080005b06 <sys_link>:
{
    80005b06:	7169                	addi	sp,sp,-304
    80005b08:	f606                	sd	ra,296(sp)
    80005b0a:	f222                	sd	s0,288(sp)
    80005b0c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b0e:	08000613          	li	a2,128
    80005b12:	ed040593          	addi	a1,s0,-304
    80005b16:	4501                	li	a0,0
    80005b18:	ffffd097          	auipc	ra,0xffffd
    80005b1c:	630080e7          	jalr	1584(ra) # 80003148 <argstr>
    return -1;
    80005b20:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b22:	12054663          	bltz	a0,80005c4e <sys_link+0x148>
    80005b26:	08000613          	li	a2,128
    80005b2a:	f5040593          	addi	a1,s0,-176
    80005b2e:	4505                	li	a0,1
    80005b30:	ffffd097          	auipc	ra,0xffffd
    80005b34:	618080e7          	jalr	1560(ra) # 80003148 <argstr>
    return -1;
    80005b38:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b3a:	10054a63          	bltz	a0,80005c4e <sys_link+0x148>
    80005b3e:	ee26                	sd	s1,280(sp)
  begin_op();
    80005b40:	fffff097          	auipc	ra,0xfffff
    80005b44:	c84080e7          	jalr	-892(ra) # 800047c4 <begin_op>
  if((ip = namei(old)) == 0){
    80005b48:	ed040513          	addi	a0,s0,-304
    80005b4c:	fffff097          	auipc	ra,0xfffff
    80005b50:	a78080e7          	jalr	-1416(ra) # 800045c4 <namei>
    80005b54:	84aa                	mv	s1,a0
    80005b56:	c949                	beqz	a0,80005be8 <sys_link+0xe2>
  ilock(ip);
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	29e080e7          	jalr	670(ra) # 80003df6 <ilock>
  if(ip->type == T_DIR){
    80005b60:	04449703          	lh	a4,68(s1)
    80005b64:	4785                	li	a5,1
    80005b66:	08f70863          	beq	a4,a5,80005bf6 <sys_link+0xf0>
    80005b6a:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005b6c:	04a4d783          	lhu	a5,74(s1)
    80005b70:	2785                	addiw	a5,a5,1
    80005b72:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b76:	8526                	mv	a0,s1
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	1b2080e7          	jalr	434(ra) # 80003d2a <iupdate>
  iunlock(ip);
    80005b80:	8526                	mv	a0,s1
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	33a080e7          	jalr	826(ra) # 80003ebc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005b8a:	fd040593          	addi	a1,s0,-48
    80005b8e:	f5040513          	addi	a0,s0,-176
    80005b92:	fffff097          	auipc	ra,0xfffff
    80005b96:	a50080e7          	jalr	-1456(ra) # 800045e2 <nameiparent>
    80005b9a:	892a                	mv	s2,a0
    80005b9c:	cd35                	beqz	a0,80005c18 <sys_link+0x112>
  ilock(dp);
    80005b9e:	ffffe097          	auipc	ra,0xffffe
    80005ba2:	258080e7          	jalr	600(ra) # 80003df6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005ba6:	00092703          	lw	a4,0(s2)
    80005baa:	409c                	lw	a5,0(s1)
    80005bac:	06f71163          	bne	a4,a5,80005c0e <sys_link+0x108>
    80005bb0:	40d0                	lw	a2,4(s1)
    80005bb2:	fd040593          	addi	a1,s0,-48
    80005bb6:	854a                	mv	a0,s2
    80005bb8:	fffff097          	auipc	ra,0xfffff
    80005bbc:	95a080e7          	jalr	-1702(ra) # 80004512 <dirlink>
    80005bc0:	04054763          	bltz	a0,80005c0e <sys_link+0x108>
  iunlockput(dp);
    80005bc4:	854a                	mv	a0,s2
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	496080e7          	jalr	1174(ra) # 8000405c <iunlockput>
  iput(ip);
    80005bce:	8526                	mv	a0,s1
    80005bd0:	ffffe097          	auipc	ra,0xffffe
    80005bd4:	3e4080e7          	jalr	996(ra) # 80003fb4 <iput>
  end_op();
    80005bd8:	fffff097          	auipc	ra,0xfffff
    80005bdc:	c66080e7          	jalr	-922(ra) # 8000483e <end_op>
  return 0;
    80005be0:	4781                	li	a5,0
    80005be2:	64f2                	ld	s1,280(sp)
    80005be4:	6952                	ld	s2,272(sp)
    80005be6:	a0a5                	j	80005c4e <sys_link+0x148>
    end_op();
    80005be8:	fffff097          	auipc	ra,0xfffff
    80005bec:	c56080e7          	jalr	-938(ra) # 8000483e <end_op>
    return -1;
    80005bf0:	57fd                	li	a5,-1
    80005bf2:	64f2                	ld	s1,280(sp)
    80005bf4:	a8a9                	j	80005c4e <sys_link+0x148>
    iunlockput(ip);
    80005bf6:	8526                	mv	a0,s1
    80005bf8:	ffffe097          	auipc	ra,0xffffe
    80005bfc:	464080e7          	jalr	1124(ra) # 8000405c <iunlockput>
    end_op();
    80005c00:	fffff097          	auipc	ra,0xfffff
    80005c04:	c3e080e7          	jalr	-962(ra) # 8000483e <end_op>
    return -1;
    80005c08:	57fd                	li	a5,-1
    80005c0a:	64f2                	ld	s1,280(sp)
    80005c0c:	a089                	j	80005c4e <sys_link+0x148>
    iunlockput(dp);
    80005c0e:	854a                	mv	a0,s2
    80005c10:	ffffe097          	auipc	ra,0xffffe
    80005c14:	44c080e7          	jalr	1100(ra) # 8000405c <iunlockput>
  ilock(ip);
    80005c18:	8526                	mv	a0,s1
    80005c1a:	ffffe097          	auipc	ra,0xffffe
    80005c1e:	1dc080e7          	jalr	476(ra) # 80003df6 <ilock>
  ip->nlink--;
    80005c22:	04a4d783          	lhu	a5,74(s1)
    80005c26:	37fd                	addiw	a5,a5,-1
    80005c28:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c2c:	8526                	mv	a0,s1
    80005c2e:	ffffe097          	auipc	ra,0xffffe
    80005c32:	0fc080e7          	jalr	252(ra) # 80003d2a <iupdate>
  iunlockput(ip);
    80005c36:	8526                	mv	a0,s1
    80005c38:	ffffe097          	auipc	ra,0xffffe
    80005c3c:	424080e7          	jalr	1060(ra) # 8000405c <iunlockput>
  end_op();
    80005c40:	fffff097          	auipc	ra,0xfffff
    80005c44:	bfe080e7          	jalr	-1026(ra) # 8000483e <end_op>
  return -1;
    80005c48:	57fd                	li	a5,-1
    80005c4a:	64f2                	ld	s1,280(sp)
    80005c4c:	6952                	ld	s2,272(sp)
}
    80005c4e:	853e                	mv	a0,a5
    80005c50:	70b2                	ld	ra,296(sp)
    80005c52:	7412                	ld	s0,288(sp)
    80005c54:	6155                	addi	sp,sp,304
    80005c56:	8082                	ret

0000000080005c58 <sys_unlink>:
{
    80005c58:	7151                	addi	sp,sp,-240
    80005c5a:	f586                	sd	ra,232(sp)
    80005c5c:	f1a2                	sd	s0,224(sp)
    80005c5e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005c60:	08000613          	li	a2,128
    80005c64:	f3040593          	addi	a1,s0,-208
    80005c68:	4501                	li	a0,0
    80005c6a:	ffffd097          	auipc	ra,0xffffd
    80005c6e:	4de080e7          	jalr	1246(ra) # 80003148 <argstr>
    80005c72:	1a054a63          	bltz	a0,80005e26 <sys_unlink+0x1ce>
    80005c76:	eda6                	sd	s1,216(sp)
  begin_op();
    80005c78:	fffff097          	auipc	ra,0xfffff
    80005c7c:	b4c080e7          	jalr	-1204(ra) # 800047c4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005c80:	fb040593          	addi	a1,s0,-80
    80005c84:	f3040513          	addi	a0,s0,-208
    80005c88:	fffff097          	auipc	ra,0xfffff
    80005c8c:	95a080e7          	jalr	-1702(ra) # 800045e2 <nameiparent>
    80005c90:	84aa                	mv	s1,a0
    80005c92:	cd71                	beqz	a0,80005d6e <sys_unlink+0x116>
  ilock(dp);
    80005c94:	ffffe097          	auipc	ra,0xffffe
    80005c98:	162080e7          	jalr	354(ra) # 80003df6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005c9c:	00003597          	auipc	a1,0x3
    80005ca0:	a7458593          	addi	a1,a1,-1420 # 80008710 <__func__.1+0x708>
    80005ca4:	fb040513          	addi	a0,s0,-80
    80005ca8:	ffffe097          	auipc	ra,0xffffe
    80005cac:	640080e7          	jalr	1600(ra) # 800042e8 <namecmp>
    80005cb0:	14050c63          	beqz	a0,80005e08 <sys_unlink+0x1b0>
    80005cb4:	00003597          	auipc	a1,0x3
    80005cb8:	a6458593          	addi	a1,a1,-1436 # 80008718 <__func__.1+0x710>
    80005cbc:	fb040513          	addi	a0,s0,-80
    80005cc0:	ffffe097          	auipc	ra,0xffffe
    80005cc4:	628080e7          	jalr	1576(ra) # 800042e8 <namecmp>
    80005cc8:	14050063          	beqz	a0,80005e08 <sys_unlink+0x1b0>
    80005ccc:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005cce:	f2c40613          	addi	a2,s0,-212
    80005cd2:	fb040593          	addi	a1,s0,-80
    80005cd6:	8526                	mv	a0,s1
    80005cd8:	ffffe097          	auipc	ra,0xffffe
    80005cdc:	62a080e7          	jalr	1578(ra) # 80004302 <dirlookup>
    80005ce0:	892a                	mv	s2,a0
    80005ce2:	12050263          	beqz	a0,80005e06 <sys_unlink+0x1ae>
  ilock(ip);
    80005ce6:	ffffe097          	auipc	ra,0xffffe
    80005cea:	110080e7          	jalr	272(ra) # 80003df6 <ilock>
  if(ip->nlink < 1)
    80005cee:	04a91783          	lh	a5,74(s2)
    80005cf2:	08f05563          	blez	a5,80005d7c <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005cf6:	04491703          	lh	a4,68(s2)
    80005cfa:	4785                	li	a5,1
    80005cfc:	08f70963          	beq	a4,a5,80005d8e <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005d00:	4641                	li	a2,16
    80005d02:	4581                	li	a1,0
    80005d04:	fc040513          	addi	a0,s0,-64
    80005d08:	ffffb097          	auipc	ra,0xffffb
    80005d0c:	214080e7          	jalr	532(ra) # 80000f1c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d10:	4741                	li	a4,16
    80005d12:	f2c42683          	lw	a3,-212(s0)
    80005d16:	fc040613          	addi	a2,s0,-64
    80005d1a:	4581                	li	a1,0
    80005d1c:	8526                	mv	a0,s1
    80005d1e:	ffffe097          	auipc	ra,0xffffe
    80005d22:	4a0080e7          	jalr	1184(ra) # 800041be <writei>
    80005d26:	47c1                	li	a5,16
    80005d28:	0af51b63          	bne	a0,a5,80005dde <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80005d2c:	04491703          	lh	a4,68(s2)
    80005d30:	4785                	li	a5,1
    80005d32:	0af70f63          	beq	a4,a5,80005df0 <sys_unlink+0x198>
  iunlockput(dp);
    80005d36:	8526                	mv	a0,s1
    80005d38:	ffffe097          	auipc	ra,0xffffe
    80005d3c:	324080e7          	jalr	804(ra) # 8000405c <iunlockput>
  ip->nlink--;
    80005d40:	04a95783          	lhu	a5,74(s2)
    80005d44:	37fd                	addiw	a5,a5,-1
    80005d46:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005d4a:	854a                	mv	a0,s2
    80005d4c:	ffffe097          	auipc	ra,0xffffe
    80005d50:	fde080e7          	jalr	-34(ra) # 80003d2a <iupdate>
  iunlockput(ip);
    80005d54:	854a                	mv	a0,s2
    80005d56:	ffffe097          	auipc	ra,0xffffe
    80005d5a:	306080e7          	jalr	774(ra) # 8000405c <iunlockput>
  end_op();
    80005d5e:	fffff097          	auipc	ra,0xfffff
    80005d62:	ae0080e7          	jalr	-1312(ra) # 8000483e <end_op>
  return 0;
    80005d66:	4501                	li	a0,0
    80005d68:	64ee                	ld	s1,216(sp)
    80005d6a:	694e                	ld	s2,208(sp)
    80005d6c:	a84d                	j	80005e1e <sys_unlink+0x1c6>
    end_op();
    80005d6e:	fffff097          	auipc	ra,0xfffff
    80005d72:	ad0080e7          	jalr	-1328(ra) # 8000483e <end_op>
    return -1;
    80005d76:	557d                	li	a0,-1
    80005d78:	64ee                	ld	s1,216(sp)
    80005d7a:	a055                	j	80005e1e <sys_unlink+0x1c6>
    80005d7c:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005d7e:	00003517          	auipc	a0,0x3
    80005d82:	9a250513          	addi	a0,a0,-1630 # 80008720 <__func__.1+0x718>
    80005d86:	ffffa097          	auipc	ra,0xffffa
    80005d8a:	7da080e7          	jalr	2010(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005d8e:	04c92703          	lw	a4,76(s2)
    80005d92:	02000793          	li	a5,32
    80005d96:	f6e7f5e3          	bgeu	a5,a4,80005d00 <sys_unlink+0xa8>
    80005d9a:	e5ce                	sd	s3,200(sp)
    80005d9c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005da0:	4741                	li	a4,16
    80005da2:	86ce                	mv	a3,s3
    80005da4:	f1840613          	addi	a2,s0,-232
    80005da8:	4581                	li	a1,0
    80005daa:	854a                	mv	a0,s2
    80005dac:	ffffe097          	auipc	ra,0xffffe
    80005db0:	302080e7          	jalr	770(ra) # 800040ae <readi>
    80005db4:	47c1                	li	a5,16
    80005db6:	00f51c63          	bne	a0,a5,80005dce <sys_unlink+0x176>
    if(de.inum != 0)
    80005dba:	f1845783          	lhu	a5,-232(s0)
    80005dbe:	e7b5                	bnez	a5,80005e2a <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005dc0:	29c1                	addiw	s3,s3,16
    80005dc2:	04c92783          	lw	a5,76(s2)
    80005dc6:	fcf9ede3          	bltu	s3,a5,80005da0 <sys_unlink+0x148>
    80005dca:	69ae                	ld	s3,200(sp)
    80005dcc:	bf15                	j	80005d00 <sys_unlink+0xa8>
      panic("isdirempty: readi");
    80005dce:	00003517          	auipc	a0,0x3
    80005dd2:	96a50513          	addi	a0,a0,-1686 # 80008738 <__func__.1+0x730>
    80005dd6:	ffffa097          	auipc	ra,0xffffa
    80005dda:	78a080e7          	jalr	1930(ra) # 80000560 <panic>
    80005dde:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005de0:	00003517          	auipc	a0,0x3
    80005de4:	97050513          	addi	a0,a0,-1680 # 80008750 <__func__.1+0x748>
    80005de8:	ffffa097          	auipc	ra,0xffffa
    80005dec:	778080e7          	jalr	1912(ra) # 80000560 <panic>
    dp->nlink--;
    80005df0:	04a4d783          	lhu	a5,74(s1)
    80005df4:	37fd                	addiw	a5,a5,-1
    80005df6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005dfa:	8526                	mv	a0,s1
    80005dfc:	ffffe097          	auipc	ra,0xffffe
    80005e00:	f2e080e7          	jalr	-210(ra) # 80003d2a <iupdate>
    80005e04:	bf0d                	j	80005d36 <sys_unlink+0xde>
    80005e06:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005e08:	8526                	mv	a0,s1
    80005e0a:	ffffe097          	auipc	ra,0xffffe
    80005e0e:	252080e7          	jalr	594(ra) # 8000405c <iunlockput>
  end_op();
    80005e12:	fffff097          	auipc	ra,0xfffff
    80005e16:	a2c080e7          	jalr	-1492(ra) # 8000483e <end_op>
  return -1;
    80005e1a:	557d                	li	a0,-1
    80005e1c:	64ee                	ld	s1,216(sp)
}
    80005e1e:	70ae                	ld	ra,232(sp)
    80005e20:	740e                	ld	s0,224(sp)
    80005e22:	616d                	addi	sp,sp,240
    80005e24:	8082                	ret
    return -1;
    80005e26:	557d                	li	a0,-1
    80005e28:	bfdd                	j	80005e1e <sys_unlink+0x1c6>
    iunlockput(ip);
    80005e2a:	854a                	mv	a0,s2
    80005e2c:	ffffe097          	auipc	ra,0xffffe
    80005e30:	230080e7          	jalr	560(ra) # 8000405c <iunlockput>
    goto bad;
    80005e34:	694e                	ld	s2,208(sp)
    80005e36:	69ae                	ld	s3,200(sp)
    80005e38:	bfc1                	j	80005e08 <sys_unlink+0x1b0>

0000000080005e3a <sys_open>:

uint64
sys_open(void)
{
    80005e3a:	7131                	addi	sp,sp,-192
    80005e3c:	fd06                	sd	ra,184(sp)
    80005e3e:	f922                	sd	s0,176(sp)
    80005e40:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005e42:	f4c40593          	addi	a1,s0,-180
    80005e46:	4505                	li	a0,1
    80005e48:	ffffd097          	auipc	ra,0xffffd
    80005e4c:	2c0080e7          	jalr	704(ra) # 80003108 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e50:	08000613          	li	a2,128
    80005e54:	f5040593          	addi	a1,s0,-176
    80005e58:	4501                	li	a0,0
    80005e5a:	ffffd097          	auipc	ra,0xffffd
    80005e5e:	2ee080e7          	jalr	750(ra) # 80003148 <argstr>
    80005e62:	87aa                	mv	a5,a0
    return -1;
    80005e64:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e66:	0a07ce63          	bltz	a5,80005f22 <sys_open+0xe8>
    80005e6a:	f526                	sd	s1,168(sp)

  begin_op();
    80005e6c:	fffff097          	auipc	ra,0xfffff
    80005e70:	958080e7          	jalr	-1704(ra) # 800047c4 <begin_op>

  if(omode & O_CREATE){
    80005e74:	f4c42783          	lw	a5,-180(s0)
    80005e78:	2007f793          	andi	a5,a5,512
    80005e7c:	cfd5                	beqz	a5,80005f38 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005e7e:	4681                	li	a3,0
    80005e80:	4601                	li	a2,0
    80005e82:	4589                	li	a1,2
    80005e84:	f5040513          	addi	a0,s0,-176
    80005e88:	00000097          	auipc	ra,0x0
    80005e8c:	95c080e7          	jalr	-1700(ra) # 800057e4 <create>
    80005e90:	84aa                	mv	s1,a0
    if(ip == 0){
    80005e92:	cd41                	beqz	a0,80005f2a <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005e94:	04449703          	lh	a4,68(s1)
    80005e98:	478d                	li	a5,3
    80005e9a:	00f71763          	bne	a4,a5,80005ea8 <sys_open+0x6e>
    80005e9e:	0464d703          	lhu	a4,70(s1)
    80005ea2:	47a5                	li	a5,9
    80005ea4:	0ee7e163          	bltu	a5,a4,80005f86 <sys_open+0x14c>
    80005ea8:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005eaa:	fffff097          	auipc	ra,0xfffff
    80005eae:	d28080e7          	jalr	-728(ra) # 80004bd2 <filealloc>
    80005eb2:	892a                	mv	s2,a0
    80005eb4:	c97d                	beqz	a0,80005faa <sys_open+0x170>
    80005eb6:	ed4e                	sd	s3,152(sp)
    80005eb8:	00000097          	auipc	ra,0x0
    80005ebc:	8ea080e7          	jalr	-1814(ra) # 800057a2 <fdalloc>
    80005ec0:	89aa                	mv	s3,a0
    80005ec2:	0c054e63          	bltz	a0,80005f9e <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ec6:	04449703          	lh	a4,68(s1)
    80005eca:	478d                	li	a5,3
    80005ecc:	0ef70c63          	beq	a4,a5,80005fc4 <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ed0:	4789                	li	a5,2
    80005ed2:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005ed6:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005eda:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005ede:	f4c42783          	lw	a5,-180(s0)
    80005ee2:	0017c713          	xori	a4,a5,1
    80005ee6:	8b05                	andi	a4,a4,1
    80005ee8:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005eec:	0037f713          	andi	a4,a5,3
    80005ef0:	00e03733          	snez	a4,a4
    80005ef4:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005ef8:	4007f793          	andi	a5,a5,1024
    80005efc:	c791                	beqz	a5,80005f08 <sys_open+0xce>
    80005efe:	04449703          	lh	a4,68(s1)
    80005f02:	4789                	li	a5,2
    80005f04:	0cf70763          	beq	a4,a5,80005fd2 <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80005f08:	8526                	mv	a0,s1
    80005f0a:	ffffe097          	auipc	ra,0xffffe
    80005f0e:	fb2080e7          	jalr	-78(ra) # 80003ebc <iunlock>
  end_op();
    80005f12:	fffff097          	auipc	ra,0xfffff
    80005f16:	92c080e7          	jalr	-1748(ra) # 8000483e <end_op>

  return fd;
    80005f1a:	854e                	mv	a0,s3
    80005f1c:	74aa                	ld	s1,168(sp)
    80005f1e:	790a                	ld	s2,160(sp)
    80005f20:	69ea                	ld	s3,152(sp)
}
    80005f22:	70ea                	ld	ra,184(sp)
    80005f24:	744a                	ld	s0,176(sp)
    80005f26:	6129                	addi	sp,sp,192
    80005f28:	8082                	ret
      end_op();
    80005f2a:	fffff097          	auipc	ra,0xfffff
    80005f2e:	914080e7          	jalr	-1772(ra) # 8000483e <end_op>
      return -1;
    80005f32:	557d                	li	a0,-1
    80005f34:	74aa                	ld	s1,168(sp)
    80005f36:	b7f5                	j	80005f22 <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80005f38:	f5040513          	addi	a0,s0,-176
    80005f3c:	ffffe097          	auipc	ra,0xffffe
    80005f40:	688080e7          	jalr	1672(ra) # 800045c4 <namei>
    80005f44:	84aa                	mv	s1,a0
    80005f46:	c90d                	beqz	a0,80005f78 <sys_open+0x13e>
    ilock(ip);
    80005f48:	ffffe097          	auipc	ra,0xffffe
    80005f4c:	eae080e7          	jalr	-338(ra) # 80003df6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005f50:	04449703          	lh	a4,68(s1)
    80005f54:	4785                	li	a5,1
    80005f56:	f2f71fe3          	bne	a4,a5,80005e94 <sys_open+0x5a>
    80005f5a:	f4c42783          	lw	a5,-180(s0)
    80005f5e:	d7a9                	beqz	a5,80005ea8 <sys_open+0x6e>
      iunlockput(ip);
    80005f60:	8526                	mv	a0,s1
    80005f62:	ffffe097          	auipc	ra,0xffffe
    80005f66:	0fa080e7          	jalr	250(ra) # 8000405c <iunlockput>
      end_op();
    80005f6a:	fffff097          	auipc	ra,0xfffff
    80005f6e:	8d4080e7          	jalr	-1836(ra) # 8000483e <end_op>
      return -1;
    80005f72:	557d                	li	a0,-1
    80005f74:	74aa                	ld	s1,168(sp)
    80005f76:	b775                	j	80005f22 <sys_open+0xe8>
      end_op();
    80005f78:	fffff097          	auipc	ra,0xfffff
    80005f7c:	8c6080e7          	jalr	-1850(ra) # 8000483e <end_op>
      return -1;
    80005f80:	557d                	li	a0,-1
    80005f82:	74aa                	ld	s1,168(sp)
    80005f84:	bf79                	j	80005f22 <sys_open+0xe8>
    iunlockput(ip);
    80005f86:	8526                	mv	a0,s1
    80005f88:	ffffe097          	auipc	ra,0xffffe
    80005f8c:	0d4080e7          	jalr	212(ra) # 8000405c <iunlockput>
    end_op();
    80005f90:	fffff097          	auipc	ra,0xfffff
    80005f94:	8ae080e7          	jalr	-1874(ra) # 8000483e <end_op>
    return -1;
    80005f98:	557d                	li	a0,-1
    80005f9a:	74aa                	ld	s1,168(sp)
    80005f9c:	b759                	j	80005f22 <sys_open+0xe8>
      fileclose(f);
    80005f9e:	854a                	mv	a0,s2
    80005fa0:	fffff097          	auipc	ra,0xfffff
    80005fa4:	cee080e7          	jalr	-786(ra) # 80004c8e <fileclose>
    80005fa8:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005faa:	8526                	mv	a0,s1
    80005fac:	ffffe097          	auipc	ra,0xffffe
    80005fb0:	0b0080e7          	jalr	176(ra) # 8000405c <iunlockput>
    end_op();
    80005fb4:	fffff097          	auipc	ra,0xfffff
    80005fb8:	88a080e7          	jalr	-1910(ra) # 8000483e <end_op>
    return -1;
    80005fbc:	557d                	li	a0,-1
    80005fbe:	74aa                	ld	s1,168(sp)
    80005fc0:	790a                	ld	s2,160(sp)
    80005fc2:	b785                	j	80005f22 <sys_open+0xe8>
    f->type = FD_DEVICE;
    80005fc4:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005fc8:	04649783          	lh	a5,70(s1)
    80005fcc:	02f91223          	sh	a5,36(s2)
    80005fd0:	b729                	j	80005eda <sys_open+0xa0>
    itrunc(ip);
    80005fd2:	8526                	mv	a0,s1
    80005fd4:	ffffe097          	auipc	ra,0xffffe
    80005fd8:	f34080e7          	jalr	-204(ra) # 80003f08 <itrunc>
    80005fdc:	b735                	j	80005f08 <sys_open+0xce>

0000000080005fde <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005fde:	7175                	addi	sp,sp,-144
    80005fe0:	e506                	sd	ra,136(sp)
    80005fe2:	e122                	sd	s0,128(sp)
    80005fe4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005fe6:	ffffe097          	auipc	ra,0xffffe
    80005fea:	7de080e7          	jalr	2014(ra) # 800047c4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005fee:	08000613          	li	a2,128
    80005ff2:	f7040593          	addi	a1,s0,-144
    80005ff6:	4501                	li	a0,0
    80005ff8:	ffffd097          	auipc	ra,0xffffd
    80005ffc:	150080e7          	jalr	336(ra) # 80003148 <argstr>
    80006000:	02054963          	bltz	a0,80006032 <sys_mkdir+0x54>
    80006004:	4681                	li	a3,0
    80006006:	4601                	li	a2,0
    80006008:	4585                	li	a1,1
    8000600a:	f7040513          	addi	a0,s0,-144
    8000600e:	fffff097          	auipc	ra,0xfffff
    80006012:	7d6080e7          	jalr	2006(ra) # 800057e4 <create>
    80006016:	cd11                	beqz	a0,80006032 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006018:	ffffe097          	auipc	ra,0xffffe
    8000601c:	044080e7          	jalr	68(ra) # 8000405c <iunlockput>
  end_op();
    80006020:	fffff097          	auipc	ra,0xfffff
    80006024:	81e080e7          	jalr	-2018(ra) # 8000483e <end_op>
  return 0;
    80006028:	4501                	li	a0,0
}
    8000602a:	60aa                	ld	ra,136(sp)
    8000602c:	640a                	ld	s0,128(sp)
    8000602e:	6149                	addi	sp,sp,144
    80006030:	8082                	ret
    end_op();
    80006032:	fffff097          	auipc	ra,0xfffff
    80006036:	80c080e7          	jalr	-2036(ra) # 8000483e <end_op>
    return -1;
    8000603a:	557d                	li	a0,-1
    8000603c:	b7fd                	j	8000602a <sys_mkdir+0x4c>

000000008000603e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000603e:	7135                	addi	sp,sp,-160
    80006040:	ed06                	sd	ra,152(sp)
    80006042:	e922                	sd	s0,144(sp)
    80006044:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006046:	ffffe097          	auipc	ra,0xffffe
    8000604a:	77e080e7          	jalr	1918(ra) # 800047c4 <begin_op>
  argint(1, &major);
    8000604e:	f6c40593          	addi	a1,s0,-148
    80006052:	4505                	li	a0,1
    80006054:	ffffd097          	auipc	ra,0xffffd
    80006058:	0b4080e7          	jalr	180(ra) # 80003108 <argint>
  argint(2, &minor);
    8000605c:	f6840593          	addi	a1,s0,-152
    80006060:	4509                	li	a0,2
    80006062:	ffffd097          	auipc	ra,0xffffd
    80006066:	0a6080e7          	jalr	166(ra) # 80003108 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000606a:	08000613          	li	a2,128
    8000606e:	f7040593          	addi	a1,s0,-144
    80006072:	4501                	li	a0,0
    80006074:	ffffd097          	auipc	ra,0xffffd
    80006078:	0d4080e7          	jalr	212(ra) # 80003148 <argstr>
    8000607c:	02054b63          	bltz	a0,800060b2 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006080:	f6841683          	lh	a3,-152(s0)
    80006084:	f6c41603          	lh	a2,-148(s0)
    80006088:	458d                	li	a1,3
    8000608a:	f7040513          	addi	a0,s0,-144
    8000608e:	fffff097          	auipc	ra,0xfffff
    80006092:	756080e7          	jalr	1878(ra) # 800057e4 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006096:	cd11                	beqz	a0,800060b2 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006098:	ffffe097          	auipc	ra,0xffffe
    8000609c:	fc4080e7          	jalr	-60(ra) # 8000405c <iunlockput>
  end_op();
    800060a0:	ffffe097          	auipc	ra,0xffffe
    800060a4:	79e080e7          	jalr	1950(ra) # 8000483e <end_op>
  return 0;
    800060a8:	4501                	li	a0,0
}
    800060aa:	60ea                	ld	ra,152(sp)
    800060ac:	644a                	ld	s0,144(sp)
    800060ae:	610d                	addi	sp,sp,160
    800060b0:	8082                	ret
    end_op();
    800060b2:	ffffe097          	auipc	ra,0xffffe
    800060b6:	78c080e7          	jalr	1932(ra) # 8000483e <end_op>
    return -1;
    800060ba:	557d                	li	a0,-1
    800060bc:	b7fd                	j	800060aa <sys_mknod+0x6c>

00000000800060be <sys_chdir>:

uint64
sys_chdir(void)
{
    800060be:	7135                	addi	sp,sp,-160
    800060c0:	ed06                	sd	ra,152(sp)
    800060c2:	e922                	sd	s0,144(sp)
    800060c4:	e14a                	sd	s2,128(sp)
    800060c6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800060c8:	ffffc097          	auipc	ra,0xffffc
    800060cc:	c5c080e7          	jalr	-932(ra) # 80001d24 <myproc>
    800060d0:	892a                	mv	s2,a0
  
  begin_op();
    800060d2:	ffffe097          	auipc	ra,0xffffe
    800060d6:	6f2080e7          	jalr	1778(ra) # 800047c4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800060da:	08000613          	li	a2,128
    800060de:	f6040593          	addi	a1,s0,-160
    800060e2:	4501                	li	a0,0
    800060e4:	ffffd097          	auipc	ra,0xffffd
    800060e8:	064080e7          	jalr	100(ra) # 80003148 <argstr>
    800060ec:	04054d63          	bltz	a0,80006146 <sys_chdir+0x88>
    800060f0:	e526                	sd	s1,136(sp)
    800060f2:	f6040513          	addi	a0,s0,-160
    800060f6:	ffffe097          	auipc	ra,0xffffe
    800060fa:	4ce080e7          	jalr	1230(ra) # 800045c4 <namei>
    800060fe:	84aa                	mv	s1,a0
    80006100:	c131                	beqz	a0,80006144 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006102:	ffffe097          	auipc	ra,0xffffe
    80006106:	cf4080e7          	jalr	-780(ra) # 80003df6 <ilock>
  if(ip->type != T_DIR){
    8000610a:	04449703          	lh	a4,68(s1)
    8000610e:	4785                	li	a5,1
    80006110:	04f71163          	bne	a4,a5,80006152 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006114:	8526                	mv	a0,s1
    80006116:	ffffe097          	auipc	ra,0xffffe
    8000611a:	da6080e7          	jalr	-602(ra) # 80003ebc <iunlock>
  iput(p->cwd);
    8000611e:	15093503          	ld	a0,336(s2)
    80006122:	ffffe097          	auipc	ra,0xffffe
    80006126:	e92080e7          	jalr	-366(ra) # 80003fb4 <iput>
  end_op();
    8000612a:	ffffe097          	auipc	ra,0xffffe
    8000612e:	714080e7          	jalr	1812(ra) # 8000483e <end_op>
  p->cwd = ip;
    80006132:	14993823          	sd	s1,336(s2)
  return 0;
    80006136:	4501                	li	a0,0
    80006138:	64aa                	ld	s1,136(sp)
}
    8000613a:	60ea                	ld	ra,152(sp)
    8000613c:	644a                	ld	s0,144(sp)
    8000613e:	690a                	ld	s2,128(sp)
    80006140:	610d                	addi	sp,sp,160
    80006142:	8082                	ret
    80006144:	64aa                	ld	s1,136(sp)
    end_op();
    80006146:	ffffe097          	auipc	ra,0xffffe
    8000614a:	6f8080e7          	jalr	1784(ra) # 8000483e <end_op>
    return -1;
    8000614e:	557d                	li	a0,-1
    80006150:	b7ed                	j	8000613a <sys_chdir+0x7c>
    iunlockput(ip);
    80006152:	8526                	mv	a0,s1
    80006154:	ffffe097          	auipc	ra,0xffffe
    80006158:	f08080e7          	jalr	-248(ra) # 8000405c <iunlockput>
    end_op();
    8000615c:	ffffe097          	auipc	ra,0xffffe
    80006160:	6e2080e7          	jalr	1762(ra) # 8000483e <end_op>
    return -1;
    80006164:	557d                	li	a0,-1
    80006166:	64aa                	ld	s1,136(sp)
    80006168:	bfc9                	j	8000613a <sys_chdir+0x7c>

000000008000616a <sys_exec>:

uint64
sys_exec(void)
{
    8000616a:	7121                	addi	sp,sp,-448
    8000616c:	ff06                	sd	ra,440(sp)
    8000616e:	fb22                	sd	s0,432(sp)
    80006170:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006172:	e4840593          	addi	a1,s0,-440
    80006176:	4505                	li	a0,1
    80006178:	ffffd097          	auipc	ra,0xffffd
    8000617c:	fb0080e7          	jalr	-80(ra) # 80003128 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006180:	08000613          	li	a2,128
    80006184:	f5040593          	addi	a1,s0,-176
    80006188:	4501                	li	a0,0
    8000618a:	ffffd097          	auipc	ra,0xffffd
    8000618e:	fbe080e7          	jalr	-66(ra) # 80003148 <argstr>
    80006192:	87aa                	mv	a5,a0
    return -1;
    80006194:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006196:	0e07c263          	bltz	a5,8000627a <sys_exec+0x110>
    8000619a:	f726                	sd	s1,424(sp)
    8000619c:	f34a                	sd	s2,416(sp)
    8000619e:	ef4e                	sd	s3,408(sp)
    800061a0:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800061a2:	10000613          	li	a2,256
    800061a6:	4581                	li	a1,0
    800061a8:	e5040513          	addi	a0,s0,-432
    800061ac:	ffffb097          	auipc	ra,0xffffb
    800061b0:	d70080e7          	jalr	-656(ra) # 80000f1c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800061b4:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800061b8:	89a6                	mv	s3,s1
    800061ba:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800061bc:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800061c0:	00391513          	slli	a0,s2,0x3
    800061c4:	e4040593          	addi	a1,s0,-448
    800061c8:	e4843783          	ld	a5,-440(s0)
    800061cc:	953e                	add	a0,a0,a5
    800061ce:	ffffd097          	auipc	ra,0xffffd
    800061d2:	e9c080e7          	jalr	-356(ra) # 8000306a <fetchaddr>
    800061d6:	02054a63          	bltz	a0,8000620a <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    800061da:	e4043783          	ld	a5,-448(s0)
    800061de:	c7b9                	beqz	a5,8000622c <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800061e0:	ffffb097          	auipc	ra,0xffffb
    800061e4:	ac2080e7          	jalr	-1342(ra) # 80000ca2 <kalloc>
    800061e8:	85aa                	mv	a1,a0
    800061ea:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800061ee:	cd11                	beqz	a0,8000620a <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800061f0:	6605                	lui	a2,0x1
    800061f2:	e4043503          	ld	a0,-448(s0)
    800061f6:	ffffd097          	auipc	ra,0xffffd
    800061fa:	ec6080e7          	jalr	-314(ra) # 800030bc <fetchstr>
    800061fe:	00054663          	bltz	a0,8000620a <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80006202:	0905                	addi	s2,s2,1
    80006204:	09a1                	addi	s3,s3,8
    80006206:	fb491de3          	bne	s2,s4,800061c0 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000620a:	f5040913          	addi	s2,s0,-176
    8000620e:	6088                	ld	a0,0(s1)
    80006210:	c125                	beqz	a0,80006270 <sys_exec+0x106>
    kfree(argv[i]);
    80006212:	ffffb097          	auipc	ra,0xffffb
    80006216:	89c080e7          	jalr	-1892(ra) # 80000aae <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000621a:	04a1                	addi	s1,s1,8
    8000621c:	ff2499e3          	bne	s1,s2,8000620e <sys_exec+0xa4>
  return -1;
    80006220:	557d                	li	a0,-1
    80006222:	74ba                	ld	s1,424(sp)
    80006224:	791a                	ld	s2,416(sp)
    80006226:	69fa                	ld	s3,408(sp)
    80006228:	6a5a                	ld	s4,400(sp)
    8000622a:	a881                	j	8000627a <sys_exec+0x110>
      argv[i] = 0;
    8000622c:	0009079b          	sext.w	a5,s2
    80006230:	078e                	slli	a5,a5,0x3
    80006232:	fd078793          	addi	a5,a5,-48
    80006236:	97a2                	add	a5,a5,s0
    80006238:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    8000623c:	e5040593          	addi	a1,s0,-432
    80006240:	f5040513          	addi	a0,s0,-176
    80006244:	fffff097          	auipc	ra,0xfffff
    80006248:	120080e7          	jalr	288(ra) # 80005364 <exec>
    8000624c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000624e:	f5040993          	addi	s3,s0,-176
    80006252:	6088                	ld	a0,0(s1)
    80006254:	c901                	beqz	a0,80006264 <sys_exec+0xfa>
    kfree(argv[i]);
    80006256:	ffffb097          	auipc	ra,0xffffb
    8000625a:	858080e7          	jalr	-1960(ra) # 80000aae <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000625e:	04a1                	addi	s1,s1,8
    80006260:	ff3499e3          	bne	s1,s3,80006252 <sys_exec+0xe8>
  return ret;
    80006264:	854a                	mv	a0,s2
    80006266:	74ba                	ld	s1,424(sp)
    80006268:	791a                	ld	s2,416(sp)
    8000626a:	69fa                	ld	s3,408(sp)
    8000626c:	6a5a                	ld	s4,400(sp)
    8000626e:	a031                	j	8000627a <sys_exec+0x110>
  return -1;
    80006270:	557d                	li	a0,-1
    80006272:	74ba                	ld	s1,424(sp)
    80006274:	791a                	ld	s2,416(sp)
    80006276:	69fa                	ld	s3,408(sp)
    80006278:	6a5a                	ld	s4,400(sp)
}
    8000627a:	70fa                	ld	ra,440(sp)
    8000627c:	745a                	ld	s0,432(sp)
    8000627e:	6139                	addi	sp,sp,448
    80006280:	8082                	ret

0000000080006282 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006282:	7139                	addi	sp,sp,-64
    80006284:	fc06                	sd	ra,56(sp)
    80006286:	f822                	sd	s0,48(sp)
    80006288:	f426                	sd	s1,40(sp)
    8000628a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000628c:	ffffc097          	auipc	ra,0xffffc
    80006290:	a98080e7          	jalr	-1384(ra) # 80001d24 <myproc>
    80006294:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006296:	fd840593          	addi	a1,s0,-40
    8000629a:	4501                	li	a0,0
    8000629c:	ffffd097          	auipc	ra,0xffffd
    800062a0:	e8c080e7          	jalr	-372(ra) # 80003128 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800062a4:	fc840593          	addi	a1,s0,-56
    800062a8:	fd040513          	addi	a0,s0,-48
    800062ac:	fffff097          	auipc	ra,0xfffff
    800062b0:	d50080e7          	jalr	-688(ra) # 80004ffc <pipealloc>
    return -1;
    800062b4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800062b6:	0c054463          	bltz	a0,8000637e <sys_pipe+0xfc>
  fd0 = -1;
    800062ba:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800062be:	fd043503          	ld	a0,-48(s0)
    800062c2:	fffff097          	auipc	ra,0xfffff
    800062c6:	4e0080e7          	jalr	1248(ra) # 800057a2 <fdalloc>
    800062ca:	fca42223          	sw	a0,-60(s0)
    800062ce:	08054b63          	bltz	a0,80006364 <sys_pipe+0xe2>
    800062d2:	fc843503          	ld	a0,-56(s0)
    800062d6:	fffff097          	auipc	ra,0xfffff
    800062da:	4cc080e7          	jalr	1228(ra) # 800057a2 <fdalloc>
    800062de:	fca42023          	sw	a0,-64(s0)
    800062e2:	06054863          	bltz	a0,80006352 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062e6:	4691                	li	a3,4
    800062e8:	fc440613          	addi	a2,s0,-60
    800062ec:	fd843583          	ld	a1,-40(s0)
    800062f0:	68a8                	ld	a0,80(s1)
    800062f2:	ffffb097          	auipc	ra,0xffffb
    800062f6:	5d6080e7          	jalr	1494(ra) # 800018c8 <copyout>
    800062fa:	02054063          	bltz	a0,8000631a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800062fe:	4691                	li	a3,4
    80006300:	fc040613          	addi	a2,s0,-64
    80006304:	fd843583          	ld	a1,-40(s0)
    80006308:	0591                	addi	a1,a1,4
    8000630a:	68a8                	ld	a0,80(s1)
    8000630c:	ffffb097          	auipc	ra,0xffffb
    80006310:	5bc080e7          	jalr	1468(ra) # 800018c8 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006314:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006316:	06055463          	bgez	a0,8000637e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000631a:	fc442783          	lw	a5,-60(s0)
    8000631e:	07e9                	addi	a5,a5,26
    80006320:	078e                	slli	a5,a5,0x3
    80006322:	97a6                	add	a5,a5,s1
    80006324:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006328:	fc042783          	lw	a5,-64(s0)
    8000632c:	07e9                	addi	a5,a5,26
    8000632e:	078e                	slli	a5,a5,0x3
    80006330:	94be                	add	s1,s1,a5
    80006332:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006336:	fd043503          	ld	a0,-48(s0)
    8000633a:	fffff097          	auipc	ra,0xfffff
    8000633e:	954080e7          	jalr	-1708(ra) # 80004c8e <fileclose>
    fileclose(wf);
    80006342:	fc843503          	ld	a0,-56(s0)
    80006346:	fffff097          	auipc	ra,0xfffff
    8000634a:	948080e7          	jalr	-1720(ra) # 80004c8e <fileclose>
    return -1;
    8000634e:	57fd                	li	a5,-1
    80006350:	a03d                	j	8000637e <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006352:	fc442783          	lw	a5,-60(s0)
    80006356:	0007c763          	bltz	a5,80006364 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000635a:	07e9                	addi	a5,a5,26
    8000635c:	078e                	slli	a5,a5,0x3
    8000635e:	97a6                	add	a5,a5,s1
    80006360:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006364:	fd043503          	ld	a0,-48(s0)
    80006368:	fffff097          	auipc	ra,0xfffff
    8000636c:	926080e7          	jalr	-1754(ra) # 80004c8e <fileclose>
    fileclose(wf);
    80006370:	fc843503          	ld	a0,-56(s0)
    80006374:	fffff097          	auipc	ra,0xfffff
    80006378:	91a080e7          	jalr	-1766(ra) # 80004c8e <fileclose>
    return -1;
    8000637c:	57fd                	li	a5,-1
}
    8000637e:	853e                	mv	a0,a5
    80006380:	70e2                	ld	ra,56(sp)
    80006382:	7442                	ld	s0,48(sp)
    80006384:	74a2                	ld	s1,40(sp)
    80006386:	6121                	addi	sp,sp,64
    80006388:	8082                	ret
    8000638a:	0000                	unimp
    8000638c:	0000                	unimp
	...

0000000080006390 <kernelvec>:
    80006390:	7111                	addi	sp,sp,-256
    80006392:	e006                	sd	ra,0(sp)
    80006394:	e40a                	sd	sp,8(sp)
    80006396:	e80e                	sd	gp,16(sp)
    80006398:	ec12                	sd	tp,24(sp)
    8000639a:	f016                	sd	t0,32(sp)
    8000639c:	f41a                	sd	t1,40(sp)
    8000639e:	f81e                	sd	t2,48(sp)
    800063a0:	fc22                	sd	s0,56(sp)
    800063a2:	e0a6                	sd	s1,64(sp)
    800063a4:	e4aa                	sd	a0,72(sp)
    800063a6:	e8ae                	sd	a1,80(sp)
    800063a8:	ecb2                	sd	a2,88(sp)
    800063aa:	f0b6                	sd	a3,96(sp)
    800063ac:	f4ba                	sd	a4,104(sp)
    800063ae:	f8be                	sd	a5,112(sp)
    800063b0:	fcc2                	sd	a6,120(sp)
    800063b2:	e146                	sd	a7,128(sp)
    800063b4:	e54a                	sd	s2,136(sp)
    800063b6:	e94e                	sd	s3,144(sp)
    800063b8:	ed52                	sd	s4,152(sp)
    800063ba:	f156                	sd	s5,160(sp)
    800063bc:	f55a                	sd	s6,168(sp)
    800063be:	f95e                	sd	s7,176(sp)
    800063c0:	fd62                	sd	s8,184(sp)
    800063c2:	e1e6                	sd	s9,192(sp)
    800063c4:	e5ea                	sd	s10,200(sp)
    800063c6:	e9ee                	sd	s11,208(sp)
    800063c8:	edf2                	sd	t3,216(sp)
    800063ca:	f1f6                	sd	t4,224(sp)
    800063cc:	f5fa                	sd	t5,232(sp)
    800063ce:	f9fe                	sd	t6,240(sp)
    800063d0:	b67fc0ef          	jal	80002f36 <kerneltrap>
    800063d4:	6082                	ld	ra,0(sp)
    800063d6:	6122                	ld	sp,8(sp)
    800063d8:	61c2                	ld	gp,16(sp)
    800063da:	7282                	ld	t0,32(sp)
    800063dc:	7322                	ld	t1,40(sp)
    800063de:	73c2                	ld	t2,48(sp)
    800063e0:	7462                	ld	s0,56(sp)
    800063e2:	6486                	ld	s1,64(sp)
    800063e4:	6526                	ld	a0,72(sp)
    800063e6:	65c6                	ld	a1,80(sp)
    800063e8:	6666                	ld	a2,88(sp)
    800063ea:	7686                	ld	a3,96(sp)
    800063ec:	7726                	ld	a4,104(sp)
    800063ee:	77c6                	ld	a5,112(sp)
    800063f0:	7866                	ld	a6,120(sp)
    800063f2:	688a                	ld	a7,128(sp)
    800063f4:	692a                	ld	s2,136(sp)
    800063f6:	69ca                	ld	s3,144(sp)
    800063f8:	6a6a                	ld	s4,152(sp)
    800063fa:	7a8a                	ld	s5,160(sp)
    800063fc:	7b2a                	ld	s6,168(sp)
    800063fe:	7bca                	ld	s7,176(sp)
    80006400:	7c6a                	ld	s8,184(sp)
    80006402:	6c8e                	ld	s9,192(sp)
    80006404:	6d2e                	ld	s10,200(sp)
    80006406:	6dce                	ld	s11,208(sp)
    80006408:	6e6e                	ld	t3,216(sp)
    8000640a:	7e8e                	ld	t4,224(sp)
    8000640c:	7f2e                	ld	t5,232(sp)
    8000640e:	7fce                	ld	t6,240(sp)
    80006410:	6111                	addi	sp,sp,256
    80006412:	10200073          	sret
    80006416:	00000013          	nop
    8000641a:	00000013          	nop
    8000641e:	0001                	nop

0000000080006420 <timervec>:
    80006420:	34051573          	csrrw	a0,mscratch,a0
    80006424:	e10c                	sd	a1,0(a0)
    80006426:	e510                	sd	a2,8(a0)
    80006428:	e914                	sd	a3,16(a0)
    8000642a:	6d0c                	ld	a1,24(a0)
    8000642c:	7110                	ld	a2,32(a0)
    8000642e:	6194                	ld	a3,0(a1)
    80006430:	96b2                	add	a3,a3,a2
    80006432:	e194                	sd	a3,0(a1)
    80006434:	4589                	li	a1,2
    80006436:	14459073          	csrw	sip,a1
    8000643a:	6914                	ld	a3,16(a0)
    8000643c:	6510                	ld	a2,8(a0)
    8000643e:	610c                	ld	a1,0(a0)
    80006440:	34051573          	csrrw	a0,mscratch,a0
    80006444:	30200073          	mret
	...

000000008000644a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000644a:	1141                	addi	sp,sp,-16
    8000644c:	e422                	sd	s0,8(sp)
    8000644e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006450:	0c0007b7          	lui	a5,0xc000
    80006454:	4705                	li	a4,1
    80006456:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006458:	0c0007b7          	lui	a5,0xc000
    8000645c:	c3d8                	sw	a4,4(a5)
}
    8000645e:	6422                	ld	s0,8(sp)
    80006460:	0141                	addi	sp,sp,16
    80006462:	8082                	ret

0000000080006464 <plicinithart>:

void
plicinithart(void)
{
    80006464:	1141                	addi	sp,sp,-16
    80006466:	e406                	sd	ra,8(sp)
    80006468:	e022                	sd	s0,0(sp)
    8000646a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000646c:	ffffc097          	auipc	ra,0xffffc
    80006470:	88c080e7          	jalr	-1908(ra) # 80001cf8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006474:	0085171b          	slliw	a4,a0,0x8
    80006478:	0c0027b7          	lui	a5,0xc002
    8000647c:	97ba                	add	a5,a5,a4
    8000647e:	40200713          	li	a4,1026
    80006482:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006486:	00d5151b          	slliw	a0,a0,0xd
    8000648a:	0c2017b7          	lui	a5,0xc201
    8000648e:	97aa                	add	a5,a5,a0
    80006490:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006494:	60a2                	ld	ra,8(sp)
    80006496:	6402                	ld	s0,0(sp)
    80006498:	0141                	addi	sp,sp,16
    8000649a:	8082                	ret

000000008000649c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000649c:	1141                	addi	sp,sp,-16
    8000649e:	e406                	sd	ra,8(sp)
    800064a0:	e022                	sd	s0,0(sp)
    800064a2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064a4:	ffffc097          	auipc	ra,0xffffc
    800064a8:	854080e7          	jalr	-1964(ra) # 80001cf8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800064ac:	00d5151b          	slliw	a0,a0,0xd
    800064b0:	0c2017b7          	lui	a5,0xc201
    800064b4:	97aa                	add	a5,a5,a0
  return irq;
}
    800064b6:	43c8                	lw	a0,4(a5)
    800064b8:	60a2                	ld	ra,8(sp)
    800064ba:	6402                	ld	s0,0(sp)
    800064bc:	0141                	addi	sp,sp,16
    800064be:	8082                	ret

00000000800064c0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800064c0:	1101                	addi	sp,sp,-32
    800064c2:	ec06                	sd	ra,24(sp)
    800064c4:	e822                	sd	s0,16(sp)
    800064c6:	e426                	sd	s1,8(sp)
    800064c8:	1000                	addi	s0,sp,32
    800064ca:	84aa                	mv	s1,a0
  int hart = cpuid();
    800064cc:	ffffc097          	auipc	ra,0xffffc
    800064d0:	82c080e7          	jalr	-2004(ra) # 80001cf8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800064d4:	00d5151b          	slliw	a0,a0,0xd
    800064d8:	0c2017b7          	lui	a5,0xc201
    800064dc:	97aa                	add	a5,a5,a0
    800064de:	c3c4                	sw	s1,4(a5)
}
    800064e0:	60e2                	ld	ra,24(sp)
    800064e2:	6442                	ld	s0,16(sp)
    800064e4:	64a2                	ld	s1,8(sp)
    800064e6:	6105                	addi	sp,sp,32
    800064e8:	8082                	ret

00000000800064ea <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800064ea:	1141                	addi	sp,sp,-16
    800064ec:	e406                	sd	ra,8(sp)
    800064ee:	e022                	sd	s0,0(sp)
    800064f0:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800064f2:	479d                	li	a5,7
    800064f4:	04a7cc63          	blt	a5,a0,8000654c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800064f8:	00026797          	auipc	a5,0x26
    800064fc:	41078793          	addi	a5,a5,1040 # 8002c908 <disk>
    80006500:	97aa                	add	a5,a5,a0
    80006502:	0187c783          	lbu	a5,24(a5)
    80006506:	ebb9                	bnez	a5,8000655c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006508:	00451693          	slli	a3,a0,0x4
    8000650c:	00026797          	auipc	a5,0x26
    80006510:	3fc78793          	addi	a5,a5,1020 # 8002c908 <disk>
    80006514:	6398                	ld	a4,0(a5)
    80006516:	9736                	add	a4,a4,a3
    80006518:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000651c:	6398                	ld	a4,0(a5)
    8000651e:	9736                	add	a4,a4,a3
    80006520:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006524:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006528:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000652c:	97aa                	add	a5,a5,a0
    8000652e:	4705                	li	a4,1
    80006530:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006534:	00026517          	auipc	a0,0x26
    80006538:	3ec50513          	addi	a0,a0,1004 # 8002c920 <disk+0x18>
    8000653c:	ffffc097          	auipc	ra,0xffffc
    80006540:	ffe080e7          	jalr	-2(ra) # 8000253a <wakeup>
}
    80006544:	60a2                	ld	ra,8(sp)
    80006546:	6402                	ld	s0,0(sp)
    80006548:	0141                	addi	sp,sp,16
    8000654a:	8082                	ret
    panic("free_desc 1");
    8000654c:	00002517          	auipc	a0,0x2
    80006550:	21450513          	addi	a0,a0,532 # 80008760 <__func__.1+0x758>
    80006554:	ffffa097          	auipc	ra,0xffffa
    80006558:	00c080e7          	jalr	12(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000655c:	00002517          	auipc	a0,0x2
    80006560:	21450513          	addi	a0,a0,532 # 80008770 <__func__.1+0x768>
    80006564:	ffffa097          	auipc	ra,0xffffa
    80006568:	ffc080e7          	jalr	-4(ra) # 80000560 <panic>

000000008000656c <virtio_disk_init>:
{
    8000656c:	1101                	addi	sp,sp,-32
    8000656e:	ec06                	sd	ra,24(sp)
    80006570:	e822                	sd	s0,16(sp)
    80006572:	e426                	sd	s1,8(sp)
    80006574:	e04a                	sd	s2,0(sp)
    80006576:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006578:	00002597          	auipc	a1,0x2
    8000657c:	20858593          	addi	a1,a1,520 # 80008780 <__func__.1+0x778>
    80006580:	00026517          	auipc	a0,0x26
    80006584:	4b050513          	addi	a0,a0,1200 # 8002ca30 <disk+0x128>
    80006588:	ffffb097          	auipc	ra,0xffffb
    8000658c:	808080e7          	jalr	-2040(ra) # 80000d90 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006590:	100017b7          	lui	a5,0x10001
    80006594:	4398                	lw	a4,0(a5)
    80006596:	2701                	sext.w	a4,a4
    80006598:	747277b7          	lui	a5,0x74727
    8000659c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800065a0:	18f71c63          	bne	a4,a5,80006738 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800065a4:	100017b7          	lui	a5,0x10001
    800065a8:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800065aa:	439c                	lw	a5,0(a5)
    800065ac:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065ae:	4709                	li	a4,2
    800065b0:	18e79463          	bne	a5,a4,80006738 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065b4:	100017b7          	lui	a5,0x10001
    800065b8:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800065ba:	439c                	lw	a5,0(a5)
    800065bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800065be:	16e79d63          	bne	a5,a4,80006738 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800065c2:	100017b7          	lui	a5,0x10001
    800065c6:	47d8                	lw	a4,12(a5)
    800065c8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065ca:	554d47b7          	lui	a5,0x554d4
    800065ce:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800065d2:	16f71363          	bne	a4,a5,80006738 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065d6:	100017b7          	lui	a5,0x10001
    800065da:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065de:	4705                	li	a4,1
    800065e0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065e2:	470d                	li	a4,3
    800065e4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800065e6:	10001737          	lui	a4,0x10001
    800065ea:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800065ec:	c7ffe737          	lui	a4,0xc7ffe
    800065f0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd1d17>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800065f4:	8ef9                	and	a3,a3,a4
    800065f6:	10001737          	lui	a4,0x10001
    800065fa:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065fc:	472d                	li	a4,11
    800065fe:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006600:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006604:	439c                	lw	a5,0(a5)
    80006606:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000660a:	8ba1                	andi	a5,a5,8
    8000660c:	12078e63          	beqz	a5,80006748 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006610:	100017b7          	lui	a5,0x10001
    80006614:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006618:	100017b7          	lui	a5,0x10001
    8000661c:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006620:	439c                	lw	a5,0(a5)
    80006622:	2781                	sext.w	a5,a5
    80006624:	12079a63          	bnez	a5,80006758 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006628:	100017b7          	lui	a5,0x10001
    8000662c:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006630:	439c                	lw	a5,0(a5)
    80006632:	2781                	sext.w	a5,a5
  if(max == 0)
    80006634:	12078a63          	beqz	a5,80006768 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80006638:	471d                	li	a4,7
    8000663a:	12f77f63          	bgeu	a4,a5,80006778 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    8000663e:	ffffa097          	auipc	ra,0xffffa
    80006642:	664080e7          	jalr	1636(ra) # 80000ca2 <kalloc>
    80006646:	00026497          	auipc	s1,0x26
    8000664a:	2c248493          	addi	s1,s1,706 # 8002c908 <disk>
    8000664e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006650:	ffffa097          	auipc	ra,0xffffa
    80006654:	652080e7          	jalr	1618(ra) # 80000ca2 <kalloc>
    80006658:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000665a:	ffffa097          	auipc	ra,0xffffa
    8000665e:	648080e7          	jalr	1608(ra) # 80000ca2 <kalloc>
    80006662:	87aa                	mv	a5,a0
    80006664:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006666:	6088                	ld	a0,0(s1)
    80006668:	12050063          	beqz	a0,80006788 <virtio_disk_init+0x21c>
    8000666c:	00026717          	auipc	a4,0x26
    80006670:	2a473703          	ld	a4,676(a4) # 8002c910 <disk+0x8>
    80006674:	10070a63          	beqz	a4,80006788 <virtio_disk_init+0x21c>
    80006678:	10078863          	beqz	a5,80006788 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    8000667c:	6605                	lui	a2,0x1
    8000667e:	4581                	li	a1,0
    80006680:	ffffb097          	auipc	ra,0xffffb
    80006684:	89c080e7          	jalr	-1892(ra) # 80000f1c <memset>
  memset(disk.avail, 0, PGSIZE);
    80006688:	00026497          	auipc	s1,0x26
    8000668c:	28048493          	addi	s1,s1,640 # 8002c908 <disk>
    80006690:	6605                	lui	a2,0x1
    80006692:	4581                	li	a1,0
    80006694:	6488                	ld	a0,8(s1)
    80006696:	ffffb097          	auipc	ra,0xffffb
    8000669a:	886080e7          	jalr	-1914(ra) # 80000f1c <memset>
  memset(disk.used, 0, PGSIZE);
    8000669e:	6605                	lui	a2,0x1
    800066a0:	4581                	li	a1,0
    800066a2:	6888                	ld	a0,16(s1)
    800066a4:	ffffb097          	auipc	ra,0xffffb
    800066a8:	878080e7          	jalr	-1928(ra) # 80000f1c <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800066ac:	100017b7          	lui	a5,0x10001
    800066b0:	4721                	li	a4,8
    800066b2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800066b4:	4098                	lw	a4,0(s1)
    800066b6:	100017b7          	lui	a5,0x10001
    800066ba:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800066be:	40d8                	lw	a4,4(s1)
    800066c0:	100017b7          	lui	a5,0x10001
    800066c4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800066c8:	649c                	ld	a5,8(s1)
    800066ca:	0007869b          	sext.w	a3,a5
    800066ce:	10001737          	lui	a4,0x10001
    800066d2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800066d6:	9781                	srai	a5,a5,0x20
    800066d8:	10001737          	lui	a4,0x10001
    800066dc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800066e0:	689c                	ld	a5,16(s1)
    800066e2:	0007869b          	sext.w	a3,a5
    800066e6:	10001737          	lui	a4,0x10001
    800066ea:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800066ee:	9781                	srai	a5,a5,0x20
    800066f0:	10001737          	lui	a4,0x10001
    800066f4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800066f8:	10001737          	lui	a4,0x10001
    800066fc:	4785                	li	a5,1
    800066fe:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006700:	00f48c23          	sb	a5,24(s1)
    80006704:	00f48ca3          	sb	a5,25(s1)
    80006708:	00f48d23          	sb	a5,26(s1)
    8000670c:	00f48da3          	sb	a5,27(s1)
    80006710:	00f48e23          	sb	a5,28(s1)
    80006714:	00f48ea3          	sb	a5,29(s1)
    80006718:	00f48f23          	sb	a5,30(s1)
    8000671c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006720:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006724:	100017b7          	lui	a5,0x10001
    80006728:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000672c:	60e2                	ld	ra,24(sp)
    8000672e:	6442                	ld	s0,16(sp)
    80006730:	64a2                	ld	s1,8(sp)
    80006732:	6902                	ld	s2,0(sp)
    80006734:	6105                	addi	sp,sp,32
    80006736:	8082                	ret
    panic("could not find virtio disk");
    80006738:	00002517          	auipc	a0,0x2
    8000673c:	05850513          	addi	a0,a0,88 # 80008790 <__func__.1+0x788>
    80006740:	ffffa097          	auipc	ra,0xffffa
    80006744:	e20080e7          	jalr	-480(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006748:	00002517          	auipc	a0,0x2
    8000674c:	06850513          	addi	a0,a0,104 # 800087b0 <__func__.1+0x7a8>
    80006750:	ffffa097          	auipc	ra,0xffffa
    80006754:	e10080e7          	jalr	-496(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006758:	00002517          	auipc	a0,0x2
    8000675c:	07850513          	addi	a0,a0,120 # 800087d0 <__func__.1+0x7c8>
    80006760:	ffffa097          	auipc	ra,0xffffa
    80006764:	e00080e7          	jalr	-512(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006768:	00002517          	auipc	a0,0x2
    8000676c:	08850513          	addi	a0,a0,136 # 800087f0 <__func__.1+0x7e8>
    80006770:	ffffa097          	auipc	ra,0xffffa
    80006774:	df0080e7          	jalr	-528(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006778:	00002517          	auipc	a0,0x2
    8000677c:	09850513          	addi	a0,a0,152 # 80008810 <__func__.1+0x808>
    80006780:	ffffa097          	auipc	ra,0xffffa
    80006784:	de0080e7          	jalr	-544(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006788:	00002517          	auipc	a0,0x2
    8000678c:	0a850513          	addi	a0,a0,168 # 80008830 <__func__.1+0x828>
    80006790:	ffffa097          	auipc	ra,0xffffa
    80006794:	dd0080e7          	jalr	-560(ra) # 80000560 <panic>

0000000080006798 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006798:	7159                	addi	sp,sp,-112
    8000679a:	f486                	sd	ra,104(sp)
    8000679c:	f0a2                	sd	s0,96(sp)
    8000679e:	eca6                	sd	s1,88(sp)
    800067a0:	e8ca                	sd	s2,80(sp)
    800067a2:	e4ce                	sd	s3,72(sp)
    800067a4:	e0d2                	sd	s4,64(sp)
    800067a6:	fc56                	sd	s5,56(sp)
    800067a8:	f85a                	sd	s6,48(sp)
    800067aa:	f45e                	sd	s7,40(sp)
    800067ac:	f062                	sd	s8,32(sp)
    800067ae:	ec66                	sd	s9,24(sp)
    800067b0:	1880                	addi	s0,sp,112
    800067b2:	8a2a                	mv	s4,a0
    800067b4:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800067b6:	00c52c83          	lw	s9,12(a0)
    800067ba:	001c9c9b          	slliw	s9,s9,0x1
    800067be:	1c82                	slli	s9,s9,0x20
    800067c0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800067c4:	00026517          	auipc	a0,0x26
    800067c8:	26c50513          	addi	a0,a0,620 # 8002ca30 <disk+0x128>
    800067cc:	ffffa097          	auipc	ra,0xffffa
    800067d0:	654080e7          	jalr	1620(ra) # 80000e20 <acquire>
  for(int i = 0; i < 3; i++){
    800067d4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800067d6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800067d8:	00026b17          	auipc	s6,0x26
    800067dc:	130b0b13          	addi	s6,s6,304 # 8002c908 <disk>
  for(int i = 0; i < 3; i++){
    800067e0:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800067e2:	00026c17          	auipc	s8,0x26
    800067e6:	24ec0c13          	addi	s8,s8,590 # 8002ca30 <disk+0x128>
    800067ea:	a0ad                	j	80006854 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    800067ec:	00fb0733          	add	a4,s6,a5
    800067f0:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800067f4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800067f6:	0207c563          	bltz	a5,80006820 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800067fa:	2905                	addiw	s2,s2,1
    800067fc:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800067fe:	05590f63          	beq	s2,s5,8000685c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006802:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006804:	00026717          	auipc	a4,0x26
    80006808:	10470713          	addi	a4,a4,260 # 8002c908 <disk>
    8000680c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000680e:	01874683          	lbu	a3,24(a4)
    80006812:	fee9                	bnez	a3,800067ec <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006814:	2785                	addiw	a5,a5,1
    80006816:	0705                	addi	a4,a4,1
    80006818:	fe979be3          	bne	a5,s1,8000680e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000681c:	57fd                	li	a5,-1
    8000681e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006820:	03205163          	blez	s2,80006842 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006824:	f9042503          	lw	a0,-112(s0)
    80006828:	00000097          	auipc	ra,0x0
    8000682c:	cc2080e7          	jalr	-830(ra) # 800064ea <free_desc>
      for(int j = 0; j < i; j++)
    80006830:	4785                	li	a5,1
    80006832:	0127d863          	bge	a5,s2,80006842 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006836:	f9442503          	lw	a0,-108(s0)
    8000683a:	00000097          	auipc	ra,0x0
    8000683e:	cb0080e7          	jalr	-848(ra) # 800064ea <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006842:	85e2                	mv	a1,s8
    80006844:	00026517          	auipc	a0,0x26
    80006848:	0dc50513          	addi	a0,a0,220 # 8002c920 <disk+0x18>
    8000684c:	ffffc097          	auipc	ra,0xffffc
    80006850:	c8a080e7          	jalr	-886(ra) # 800024d6 <sleep>
  for(int i = 0; i < 3; i++){
    80006854:	f9040613          	addi	a2,s0,-112
    80006858:	894e                	mv	s2,s3
    8000685a:	b765                	j	80006802 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000685c:	f9042503          	lw	a0,-112(s0)
    80006860:	00451693          	slli	a3,a0,0x4

  if(write)
    80006864:	00026797          	auipc	a5,0x26
    80006868:	0a478793          	addi	a5,a5,164 # 8002c908 <disk>
    8000686c:	00a50713          	addi	a4,a0,10
    80006870:	0712                	slli	a4,a4,0x4
    80006872:	973e                	add	a4,a4,a5
    80006874:	01703633          	snez	a2,s7
    80006878:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000687a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000687e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006882:	6398                	ld	a4,0(a5)
    80006884:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006886:	0a868613          	addi	a2,a3,168
    8000688a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000688c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000688e:	6390                	ld	a2,0(a5)
    80006890:	00d605b3          	add	a1,a2,a3
    80006894:	4741                	li	a4,16
    80006896:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006898:	4805                	li	a6,1
    8000689a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    8000689e:	f9442703          	lw	a4,-108(s0)
    800068a2:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800068a6:	0712                	slli	a4,a4,0x4
    800068a8:	963a                	add	a2,a2,a4
    800068aa:	058a0593          	addi	a1,s4,88
    800068ae:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800068b0:	0007b883          	ld	a7,0(a5)
    800068b4:	9746                	add	a4,a4,a7
    800068b6:	40000613          	li	a2,1024
    800068ba:	c710                	sw	a2,8(a4)
  if(write)
    800068bc:	001bb613          	seqz	a2,s7
    800068c0:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800068c4:	00166613          	ori	a2,a2,1
    800068c8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800068cc:	f9842583          	lw	a1,-104(s0)
    800068d0:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800068d4:	00250613          	addi	a2,a0,2
    800068d8:	0612                	slli	a2,a2,0x4
    800068da:	963e                	add	a2,a2,a5
    800068dc:	577d                	li	a4,-1
    800068de:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800068e2:	0592                	slli	a1,a1,0x4
    800068e4:	98ae                	add	a7,a7,a1
    800068e6:	03068713          	addi	a4,a3,48
    800068ea:	973e                	add	a4,a4,a5
    800068ec:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800068f0:	6398                	ld	a4,0(a5)
    800068f2:	972e                	add	a4,a4,a1
    800068f4:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800068f8:	4689                	li	a3,2
    800068fa:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800068fe:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006902:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006906:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000690a:	6794                	ld	a3,8(a5)
    8000690c:	0026d703          	lhu	a4,2(a3)
    80006910:	8b1d                	andi	a4,a4,7
    80006912:	0706                	slli	a4,a4,0x1
    80006914:	96ba                	add	a3,a3,a4
    80006916:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000691a:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000691e:	6798                	ld	a4,8(a5)
    80006920:	00275783          	lhu	a5,2(a4)
    80006924:	2785                	addiw	a5,a5,1
    80006926:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000692a:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000692e:	100017b7          	lui	a5,0x10001
    80006932:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006936:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    8000693a:	00026917          	auipc	s2,0x26
    8000693e:	0f690913          	addi	s2,s2,246 # 8002ca30 <disk+0x128>
  while(b->disk == 1) {
    80006942:	4485                	li	s1,1
    80006944:	01079c63          	bne	a5,a6,8000695c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006948:	85ca                	mv	a1,s2
    8000694a:	8552                	mv	a0,s4
    8000694c:	ffffc097          	auipc	ra,0xffffc
    80006950:	b8a080e7          	jalr	-1142(ra) # 800024d6 <sleep>
  while(b->disk == 1) {
    80006954:	004a2783          	lw	a5,4(s4)
    80006958:	fe9788e3          	beq	a5,s1,80006948 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000695c:	f9042903          	lw	s2,-112(s0)
    80006960:	00290713          	addi	a4,s2,2
    80006964:	0712                	slli	a4,a4,0x4
    80006966:	00026797          	auipc	a5,0x26
    8000696a:	fa278793          	addi	a5,a5,-94 # 8002c908 <disk>
    8000696e:	97ba                	add	a5,a5,a4
    80006970:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006974:	00026997          	auipc	s3,0x26
    80006978:	f9498993          	addi	s3,s3,-108 # 8002c908 <disk>
    8000697c:	00491713          	slli	a4,s2,0x4
    80006980:	0009b783          	ld	a5,0(s3)
    80006984:	97ba                	add	a5,a5,a4
    80006986:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000698a:	854a                	mv	a0,s2
    8000698c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006990:	00000097          	auipc	ra,0x0
    80006994:	b5a080e7          	jalr	-1190(ra) # 800064ea <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006998:	8885                	andi	s1,s1,1
    8000699a:	f0ed                	bnez	s1,8000697c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000699c:	00026517          	auipc	a0,0x26
    800069a0:	09450513          	addi	a0,a0,148 # 8002ca30 <disk+0x128>
    800069a4:	ffffa097          	auipc	ra,0xffffa
    800069a8:	530080e7          	jalr	1328(ra) # 80000ed4 <release>
}
    800069ac:	70a6                	ld	ra,104(sp)
    800069ae:	7406                	ld	s0,96(sp)
    800069b0:	64e6                	ld	s1,88(sp)
    800069b2:	6946                	ld	s2,80(sp)
    800069b4:	69a6                	ld	s3,72(sp)
    800069b6:	6a06                	ld	s4,64(sp)
    800069b8:	7ae2                	ld	s5,56(sp)
    800069ba:	7b42                	ld	s6,48(sp)
    800069bc:	7ba2                	ld	s7,40(sp)
    800069be:	7c02                	ld	s8,32(sp)
    800069c0:	6ce2                	ld	s9,24(sp)
    800069c2:	6165                	addi	sp,sp,112
    800069c4:	8082                	ret

00000000800069c6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800069c6:	1101                	addi	sp,sp,-32
    800069c8:	ec06                	sd	ra,24(sp)
    800069ca:	e822                	sd	s0,16(sp)
    800069cc:	e426                	sd	s1,8(sp)
    800069ce:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800069d0:	00026497          	auipc	s1,0x26
    800069d4:	f3848493          	addi	s1,s1,-200 # 8002c908 <disk>
    800069d8:	00026517          	auipc	a0,0x26
    800069dc:	05850513          	addi	a0,a0,88 # 8002ca30 <disk+0x128>
    800069e0:	ffffa097          	auipc	ra,0xffffa
    800069e4:	440080e7          	jalr	1088(ra) # 80000e20 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800069e8:	100017b7          	lui	a5,0x10001
    800069ec:	53b8                	lw	a4,96(a5)
    800069ee:	8b0d                	andi	a4,a4,3
    800069f0:	100017b7          	lui	a5,0x10001
    800069f4:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800069f6:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800069fa:	689c                	ld	a5,16(s1)
    800069fc:	0204d703          	lhu	a4,32(s1)
    80006a00:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006a04:	04f70863          	beq	a4,a5,80006a54 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006a08:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006a0c:	6898                	ld	a4,16(s1)
    80006a0e:	0204d783          	lhu	a5,32(s1)
    80006a12:	8b9d                	andi	a5,a5,7
    80006a14:	078e                	slli	a5,a5,0x3
    80006a16:	97ba                	add	a5,a5,a4
    80006a18:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006a1a:	00278713          	addi	a4,a5,2
    80006a1e:	0712                	slli	a4,a4,0x4
    80006a20:	9726                	add	a4,a4,s1
    80006a22:	01074703          	lbu	a4,16(a4)
    80006a26:	e721                	bnez	a4,80006a6e <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006a28:	0789                	addi	a5,a5,2
    80006a2a:	0792                	slli	a5,a5,0x4
    80006a2c:	97a6                	add	a5,a5,s1
    80006a2e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006a30:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006a34:	ffffc097          	auipc	ra,0xffffc
    80006a38:	b06080e7          	jalr	-1274(ra) # 8000253a <wakeup>

    disk.used_idx += 1;
    80006a3c:	0204d783          	lhu	a5,32(s1)
    80006a40:	2785                	addiw	a5,a5,1
    80006a42:	17c2                	slli	a5,a5,0x30
    80006a44:	93c1                	srli	a5,a5,0x30
    80006a46:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006a4a:	6898                	ld	a4,16(s1)
    80006a4c:	00275703          	lhu	a4,2(a4)
    80006a50:	faf71ce3          	bne	a4,a5,80006a08 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006a54:	00026517          	auipc	a0,0x26
    80006a58:	fdc50513          	addi	a0,a0,-36 # 8002ca30 <disk+0x128>
    80006a5c:	ffffa097          	auipc	ra,0xffffa
    80006a60:	478080e7          	jalr	1144(ra) # 80000ed4 <release>
}
    80006a64:	60e2                	ld	ra,24(sp)
    80006a66:	6442                	ld	s0,16(sp)
    80006a68:	64a2                	ld	s1,8(sp)
    80006a6a:	6105                	addi	sp,sp,32
    80006a6c:	8082                	ret
      panic("virtio_disk_intr status");
    80006a6e:	00002517          	auipc	a0,0x2
    80006a72:	dda50513          	addi	a0,a0,-550 # 80008848 <__func__.1+0x840>
    80006a76:	ffffa097          	auipc	ra,0xffffa
    80006a7a:	aea080e7          	jalr	-1302(ra) # 80000560 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
