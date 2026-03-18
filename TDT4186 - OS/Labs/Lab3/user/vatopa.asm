
user/_vatopa:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
    if (argc < 2 || argc > 3) {
   8:	ffe5071b          	addiw	a4,a0,-2
   c:	4785                	li	a5,1
   e:	02e7f263          	bgeu	a5,a4,32 <main+0x32>
  12:	ec26                	sd	s1,24(sp)
  14:	e84a                	sd	s2,16(sp)
  16:	e44e                	sd	s3,8(sp)
        printf("Usage: vatopa virtual_address [pid]\n");
  18:	00001517          	auipc	a0,0x1
  1c:	84850513          	addi	a0,a0,-1976 # 860 <malloc+0x10a>
  20:	00000097          	auipc	ra,0x0
  24:	67e080e7          	jalr	1662(ra) # 69e <printf>
        exit(1);
  28:	4505                	li	a0,1
  2a:	00000097          	auipc	ra,0x0
  2e:	2e4080e7          	jalr	740(ra) # 30e <exit>
  32:	ec26                	sd	s1,24(sp)
  34:	e84a                	sd	s2,16(sp)
  36:	e44e                	sd	s3,8(sp)
  38:	84aa                	mv	s1,a0
  3a:	892e                	mv	s2,a1
    }

    uint64 va = (uint64)atoi(argv[1]);
  3c:	6588                	ld	a0,8(a1)
  3e:	00000097          	auipc	ra,0x0
  42:	1d6080e7          	jalr	470(ra) # 214 <atoi>
  46:	89aa                	mv	s3,a0
    int pid = (argc == 3) ? atoi(argv[2]) : 0;
  48:	478d                	li	a5,3
  4a:	4581                	li	a1,0
  4c:	02f48663          	beq	s1,a5,78 <main+0x78>

    uint64 pa = va2pa(va, pid);
  50:	854e                	mv	a0,s3
  52:	00000097          	auipc	ra,0x0
  56:	374080e7          	jalr	884(ra) # 3c6 <va2pa>
    printf("0x%x\n", (uint)pa);
  5a:	0005059b          	sext.w	a1,a0
  5e:	00001517          	auipc	a0,0x1
  62:	82a50513          	addi	a0,a0,-2006 # 888 <malloc+0x132>
  66:	00000097          	auipc	ra,0x0
  6a:	638080e7          	jalr	1592(ra) # 69e <printf>
    exit(0);
  6e:	4501                	li	a0,0
  70:	00000097          	auipc	ra,0x0
  74:	29e080e7          	jalr	670(ra) # 30e <exit>
    int pid = (argc == 3) ? atoi(argv[2]) : 0;
  78:	01093503          	ld	a0,16(s2)
  7c:	00000097          	auipc	ra,0x0
  80:	198080e7          	jalr	408(ra) # 214 <atoi>
  84:	85aa                	mv	a1,a0
  86:	b7e9                	j	50 <main+0x50>

0000000000000088 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  88:	1141                	addi	sp,sp,-16
  8a:	e406                	sd	ra,8(sp)
  8c:	e022                	sd	s0,0(sp)
  8e:	0800                	addi	s0,sp,16
  extern int main();
  main();
  90:	00000097          	auipc	ra,0x0
  94:	f70080e7          	jalr	-144(ra) # 0 <main>
  exit(0);
  98:	4501                	li	a0,0
  9a:	00000097          	auipc	ra,0x0
  9e:	274080e7          	jalr	628(ra) # 30e <exit>

00000000000000a2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a2:	1141                	addi	sp,sp,-16
  a4:	e422                	sd	s0,8(sp)
  a6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a8:	87aa                	mv	a5,a0
  aa:	0585                	addi	a1,a1,1
  ac:	0785                	addi	a5,a5,1
  ae:	fff5c703          	lbu	a4,-1(a1)
  b2:	fee78fa3          	sb	a4,-1(a5)
  b6:	fb75                	bnez	a4,aa <strcpy+0x8>
    ;
  return os;
}
  b8:	6422                	ld	s0,8(sp)
  ba:	0141                	addi	sp,sp,16
  bc:	8082                	ret

00000000000000be <strcmp>:

int
strcmp(const char *p, const char *q)
{
  be:	1141                	addi	sp,sp,-16
  c0:	e422                	sd	s0,8(sp)
  c2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  c4:	00054783          	lbu	a5,0(a0)
  c8:	cb91                	beqz	a5,dc <strcmp+0x1e>
  ca:	0005c703          	lbu	a4,0(a1)
  ce:	00f71763          	bne	a4,a5,dc <strcmp+0x1e>
    p++, q++;
  d2:	0505                	addi	a0,a0,1
  d4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  d6:	00054783          	lbu	a5,0(a0)
  da:	fbe5                	bnez	a5,ca <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  dc:	0005c503          	lbu	a0,0(a1)
}
  e0:	40a7853b          	subw	a0,a5,a0
  e4:	6422                	ld	s0,8(sp)
  e6:	0141                	addi	sp,sp,16
  e8:	8082                	ret

00000000000000ea <strlen>:

uint
strlen(const char *s)
{
  ea:	1141                	addi	sp,sp,-16
  ec:	e422                	sd	s0,8(sp)
  ee:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f0:	00054783          	lbu	a5,0(a0)
  f4:	cf91                	beqz	a5,110 <strlen+0x26>
  f6:	0505                	addi	a0,a0,1
  f8:	87aa                	mv	a5,a0
  fa:	86be                	mv	a3,a5
  fc:	0785                	addi	a5,a5,1
  fe:	fff7c703          	lbu	a4,-1(a5)
 102:	ff65                	bnez	a4,fa <strlen+0x10>
 104:	40a6853b          	subw	a0,a3,a0
 108:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 10a:	6422                	ld	s0,8(sp)
 10c:	0141                	addi	sp,sp,16
 10e:	8082                	ret
  for(n = 0; s[n]; n++)
 110:	4501                	li	a0,0
 112:	bfe5                	j	10a <strlen+0x20>

0000000000000114 <memset>:

void*
memset(void *dst, int c, uint n)
{
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 11a:	ca19                	beqz	a2,130 <memset+0x1c>
 11c:	87aa                	mv	a5,a0
 11e:	1602                	slli	a2,a2,0x20
 120:	9201                	srli	a2,a2,0x20
 122:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 126:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 12a:	0785                	addi	a5,a5,1
 12c:	fee79de3          	bne	a5,a4,126 <memset+0x12>
  }
  return dst;
}
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret

0000000000000136 <strchr>:

char*
strchr(const char *s, char c)
{
 136:	1141                	addi	sp,sp,-16
 138:	e422                	sd	s0,8(sp)
 13a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 13c:	00054783          	lbu	a5,0(a0)
 140:	cb99                	beqz	a5,156 <strchr+0x20>
    if(*s == c)
 142:	00f58763          	beq	a1,a5,150 <strchr+0x1a>
  for(; *s; s++)
 146:	0505                	addi	a0,a0,1
 148:	00054783          	lbu	a5,0(a0)
 14c:	fbfd                	bnez	a5,142 <strchr+0xc>
      return (char*)s;
  return 0;
 14e:	4501                	li	a0,0
}
 150:	6422                	ld	s0,8(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret
  return 0;
 156:	4501                	li	a0,0
 158:	bfe5                	j	150 <strchr+0x1a>

000000000000015a <gets>:

char*
gets(char *buf, int max)
{
 15a:	711d                	addi	sp,sp,-96
 15c:	ec86                	sd	ra,88(sp)
 15e:	e8a2                	sd	s0,80(sp)
 160:	e4a6                	sd	s1,72(sp)
 162:	e0ca                	sd	s2,64(sp)
 164:	fc4e                	sd	s3,56(sp)
 166:	f852                	sd	s4,48(sp)
 168:	f456                	sd	s5,40(sp)
 16a:	f05a                	sd	s6,32(sp)
 16c:	ec5e                	sd	s7,24(sp)
 16e:	1080                	addi	s0,sp,96
 170:	8baa                	mv	s7,a0
 172:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 174:	892a                	mv	s2,a0
 176:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 178:	4aa9                	li	s5,10
 17a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 17c:	89a6                	mv	s3,s1
 17e:	2485                	addiw	s1,s1,1
 180:	0344d863          	bge	s1,s4,1b0 <gets+0x56>
    cc = read(0, &c, 1);
 184:	4605                	li	a2,1
 186:	faf40593          	addi	a1,s0,-81
 18a:	4501                	li	a0,0
 18c:	00000097          	auipc	ra,0x0
 190:	19a080e7          	jalr	410(ra) # 326 <read>
    if(cc < 1)
 194:	00a05e63          	blez	a0,1b0 <gets+0x56>
    buf[i++] = c;
 198:	faf44783          	lbu	a5,-81(s0)
 19c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a0:	01578763          	beq	a5,s5,1ae <gets+0x54>
 1a4:	0905                	addi	s2,s2,1
 1a6:	fd679be3          	bne	a5,s6,17c <gets+0x22>
    buf[i++] = c;
 1aa:	89a6                	mv	s3,s1
 1ac:	a011                	j	1b0 <gets+0x56>
 1ae:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1b0:	99de                	add	s3,s3,s7
 1b2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1b6:	855e                	mv	a0,s7
 1b8:	60e6                	ld	ra,88(sp)
 1ba:	6446                	ld	s0,80(sp)
 1bc:	64a6                	ld	s1,72(sp)
 1be:	6906                	ld	s2,64(sp)
 1c0:	79e2                	ld	s3,56(sp)
 1c2:	7a42                	ld	s4,48(sp)
 1c4:	7aa2                	ld	s5,40(sp)
 1c6:	7b02                	ld	s6,32(sp)
 1c8:	6be2                	ld	s7,24(sp)
 1ca:	6125                	addi	sp,sp,96
 1cc:	8082                	ret

00000000000001ce <stat>:

int
stat(const char *n, struct stat *st)
{
 1ce:	1101                	addi	sp,sp,-32
 1d0:	ec06                	sd	ra,24(sp)
 1d2:	e822                	sd	s0,16(sp)
 1d4:	e04a                	sd	s2,0(sp)
 1d6:	1000                	addi	s0,sp,32
 1d8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1da:	4581                	li	a1,0
 1dc:	00000097          	auipc	ra,0x0
 1e0:	172080e7          	jalr	370(ra) # 34e <open>
  if(fd < 0)
 1e4:	02054663          	bltz	a0,210 <stat+0x42>
 1e8:	e426                	sd	s1,8(sp)
 1ea:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ec:	85ca                	mv	a1,s2
 1ee:	00000097          	auipc	ra,0x0
 1f2:	178080e7          	jalr	376(ra) # 366 <fstat>
 1f6:	892a                	mv	s2,a0
  close(fd);
 1f8:	8526                	mv	a0,s1
 1fa:	00000097          	auipc	ra,0x0
 1fe:	13c080e7          	jalr	316(ra) # 336 <close>
  return r;
 202:	64a2                	ld	s1,8(sp)
}
 204:	854a                	mv	a0,s2
 206:	60e2                	ld	ra,24(sp)
 208:	6442                	ld	s0,16(sp)
 20a:	6902                	ld	s2,0(sp)
 20c:	6105                	addi	sp,sp,32
 20e:	8082                	ret
    return -1;
 210:	597d                	li	s2,-1
 212:	bfcd                	j	204 <stat+0x36>

0000000000000214 <atoi>:

int
atoi(const char *s)
{
 214:	1141                	addi	sp,sp,-16
 216:	e422                	sd	s0,8(sp)
 218:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21a:	00054683          	lbu	a3,0(a0)
 21e:	fd06879b          	addiw	a5,a3,-48
 222:	0ff7f793          	zext.b	a5,a5
 226:	4625                	li	a2,9
 228:	02f66863          	bltu	a2,a5,258 <atoi+0x44>
 22c:	872a                	mv	a4,a0
  n = 0;
 22e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 230:	0705                	addi	a4,a4,1
 232:	0025179b          	slliw	a5,a0,0x2
 236:	9fa9                	addw	a5,a5,a0
 238:	0017979b          	slliw	a5,a5,0x1
 23c:	9fb5                	addw	a5,a5,a3
 23e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 242:	00074683          	lbu	a3,0(a4)
 246:	fd06879b          	addiw	a5,a3,-48
 24a:	0ff7f793          	zext.b	a5,a5
 24e:	fef671e3          	bgeu	a2,a5,230 <atoi+0x1c>
  return n;
}
 252:	6422                	ld	s0,8(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret
  n = 0;
 258:	4501                	li	a0,0
 25a:	bfe5                	j	252 <atoi+0x3e>

000000000000025c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e422                	sd	s0,8(sp)
 260:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 262:	02b57463          	bgeu	a0,a1,28a <memmove+0x2e>
    while(n-- > 0)
 266:	00c05f63          	blez	a2,284 <memmove+0x28>
 26a:	1602                	slli	a2,a2,0x20
 26c:	9201                	srli	a2,a2,0x20
 26e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 272:	872a                	mv	a4,a0
      *dst++ = *src++;
 274:	0585                	addi	a1,a1,1
 276:	0705                	addi	a4,a4,1
 278:	fff5c683          	lbu	a3,-1(a1)
 27c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 280:	fef71ae3          	bne	a4,a5,274 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 284:	6422                	ld	s0,8(sp)
 286:	0141                	addi	sp,sp,16
 288:	8082                	ret
    dst += n;
 28a:	00c50733          	add	a4,a0,a2
    src += n;
 28e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 290:	fec05ae3          	blez	a2,284 <memmove+0x28>
 294:	fff6079b          	addiw	a5,a2,-1
 298:	1782                	slli	a5,a5,0x20
 29a:	9381                	srli	a5,a5,0x20
 29c:	fff7c793          	not	a5,a5
 2a0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a2:	15fd                	addi	a1,a1,-1
 2a4:	177d                	addi	a4,a4,-1
 2a6:	0005c683          	lbu	a3,0(a1)
 2aa:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ae:	fee79ae3          	bne	a5,a4,2a2 <memmove+0x46>
 2b2:	bfc9                	j	284 <memmove+0x28>

00000000000002b4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e422                	sd	s0,8(sp)
 2b8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ba:	ca05                	beqz	a2,2ea <memcmp+0x36>
 2bc:	fff6069b          	addiw	a3,a2,-1
 2c0:	1682                	slli	a3,a3,0x20
 2c2:	9281                	srli	a3,a3,0x20
 2c4:	0685                	addi	a3,a3,1
 2c6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2c8:	00054783          	lbu	a5,0(a0)
 2cc:	0005c703          	lbu	a4,0(a1)
 2d0:	00e79863          	bne	a5,a4,2e0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2d4:	0505                	addi	a0,a0,1
    p2++;
 2d6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2d8:	fed518e3          	bne	a0,a3,2c8 <memcmp+0x14>
  }
  return 0;
 2dc:	4501                	li	a0,0
 2de:	a019                	j	2e4 <memcmp+0x30>
      return *p1 - *p2;
 2e0:	40e7853b          	subw	a0,a5,a4
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret
  return 0;
 2ea:	4501                	li	a0,0
 2ec:	bfe5                	j	2e4 <memcmp+0x30>

00000000000002ee <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e406                	sd	ra,8(sp)
 2f2:	e022                	sd	s0,0(sp)
 2f4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2f6:	00000097          	auipc	ra,0x0
 2fa:	f66080e7          	jalr	-154(ra) # 25c <memmove>
}
 2fe:	60a2                	ld	ra,8(sp)
 300:	6402                	ld	s0,0(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret

0000000000000306 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 306:	4885                	li	a7,1
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <exit>:
.global exit
exit:
 li a7, SYS_exit
 30e:	4889                	li	a7,2
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <wait>:
.global wait
wait:
 li a7, SYS_wait
 316:	488d                	li	a7,3
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 31e:	4891                	li	a7,4
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <read>:
.global read
read:
 li a7, SYS_read
 326:	4895                	li	a7,5
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <write>:
.global write
write:
 li a7, SYS_write
 32e:	48c1                	li	a7,16
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <close>:
.global close
close:
 li a7, SYS_close
 336:	48d5                	li	a7,21
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <kill>:
.global kill
kill:
 li a7, SYS_kill
 33e:	4899                	li	a7,6
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <exec>:
.global exec
exec:
 li a7, SYS_exec
 346:	489d                	li	a7,7
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <open>:
.global open
open:
 li a7, SYS_open
 34e:	48bd                	li	a7,15
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 356:	48c5                	li	a7,17
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 35e:	48c9                	li	a7,18
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 366:	48a1                	li	a7,8
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <link>:
.global link
link:
 li a7, SYS_link
 36e:	48cd                	li	a7,19
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 376:	48d1                	li	a7,20
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 37e:	48a5                	li	a7,9
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <dup>:
.global dup
dup:
 li a7, SYS_dup
 386:	48a9                	li	a7,10
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 38e:	48ad                	li	a7,11
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 396:	48b1                	li	a7,12
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 39e:	48b5                	li	a7,13
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3a6:	48b9                	li	a7,14
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <ps>:
.global ps
ps:
 li a7, SYS_ps
 3ae:	48d9                	li	a7,22
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 3b6:	48dd                	li	a7,23
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 3be:	48e1                	li	a7,24
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 3c6:	48e9                	li	a7,26
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 3ce:	48e5                	li	a7,25
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3d6:	1101                	addi	sp,sp,-32
 3d8:	ec06                	sd	ra,24(sp)
 3da:	e822                	sd	s0,16(sp)
 3dc:	1000                	addi	s0,sp,32
 3de:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3e2:	4605                	li	a2,1
 3e4:	fef40593          	addi	a1,s0,-17
 3e8:	00000097          	auipc	ra,0x0
 3ec:	f46080e7          	jalr	-186(ra) # 32e <write>
}
 3f0:	60e2                	ld	ra,24(sp)
 3f2:	6442                	ld	s0,16(sp)
 3f4:	6105                	addi	sp,sp,32
 3f6:	8082                	ret

00000000000003f8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3f8:	7139                	addi	sp,sp,-64
 3fa:	fc06                	sd	ra,56(sp)
 3fc:	f822                	sd	s0,48(sp)
 3fe:	f426                	sd	s1,40(sp)
 400:	0080                	addi	s0,sp,64
 402:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 404:	c299                	beqz	a3,40a <printint+0x12>
 406:	0805cb63          	bltz	a1,49c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 40a:	2581                	sext.w	a1,a1
  neg = 0;
 40c:	4881                	li	a7,0
 40e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 412:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 414:	2601                	sext.w	a2,a2
 416:	00000517          	auipc	a0,0x0
 41a:	4da50513          	addi	a0,a0,1242 # 8f0 <digits>
 41e:	883a                	mv	a6,a4
 420:	2705                	addiw	a4,a4,1
 422:	02c5f7bb          	remuw	a5,a1,a2
 426:	1782                	slli	a5,a5,0x20
 428:	9381                	srli	a5,a5,0x20
 42a:	97aa                	add	a5,a5,a0
 42c:	0007c783          	lbu	a5,0(a5)
 430:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 434:	0005879b          	sext.w	a5,a1
 438:	02c5d5bb          	divuw	a1,a1,a2
 43c:	0685                	addi	a3,a3,1
 43e:	fec7f0e3          	bgeu	a5,a2,41e <printint+0x26>
  if(neg)
 442:	00088c63          	beqz	a7,45a <printint+0x62>
    buf[i++] = '-';
 446:	fd070793          	addi	a5,a4,-48
 44a:	00878733          	add	a4,a5,s0
 44e:	02d00793          	li	a5,45
 452:	fef70823          	sb	a5,-16(a4)
 456:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 45a:	02e05c63          	blez	a4,492 <printint+0x9a>
 45e:	f04a                	sd	s2,32(sp)
 460:	ec4e                	sd	s3,24(sp)
 462:	fc040793          	addi	a5,s0,-64
 466:	00e78933          	add	s2,a5,a4
 46a:	fff78993          	addi	s3,a5,-1
 46e:	99ba                	add	s3,s3,a4
 470:	377d                	addiw	a4,a4,-1
 472:	1702                	slli	a4,a4,0x20
 474:	9301                	srli	a4,a4,0x20
 476:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 47a:	fff94583          	lbu	a1,-1(s2)
 47e:	8526                	mv	a0,s1
 480:	00000097          	auipc	ra,0x0
 484:	f56080e7          	jalr	-170(ra) # 3d6 <putc>
  while(--i >= 0)
 488:	197d                	addi	s2,s2,-1
 48a:	ff3918e3          	bne	s2,s3,47a <printint+0x82>
 48e:	7902                	ld	s2,32(sp)
 490:	69e2                	ld	s3,24(sp)
}
 492:	70e2                	ld	ra,56(sp)
 494:	7442                	ld	s0,48(sp)
 496:	74a2                	ld	s1,40(sp)
 498:	6121                	addi	sp,sp,64
 49a:	8082                	ret
    x = -xx;
 49c:	40b005bb          	negw	a1,a1
    neg = 1;
 4a0:	4885                	li	a7,1
    x = -xx;
 4a2:	b7b5                	j	40e <printint+0x16>

00000000000004a4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a4:	715d                	addi	sp,sp,-80
 4a6:	e486                	sd	ra,72(sp)
 4a8:	e0a2                	sd	s0,64(sp)
 4aa:	f84a                	sd	s2,48(sp)
 4ac:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ae:	0005c903          	lbu	s2,0(a1)
 4b2:	1a090a63          	beqz	s2,666 <vprintf+0x1c2>
 4b6:	fc26                	sd	s1,56(sp)
 4b8:	f44e                	sd	s3,40(sp)
 4ba:	f052                	sd	s4,32(sp)
 4bc:	ec56                	sd	s5,24(sp)
 4be:	e85a                	sd	s6,16(sp)
 4c0:	e45e                	sd	s7,8(sp)
 4c2:	8aaa                	mv	s5,a0
 4c4:	8bb2                	mv	s7,a2
 4c6:	00158493          	addi	s1,a1,1
  state = 0;
 4ca:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4cc:	02500a13          	li	s4,37
 4d0:	4b55                	li	s6,21
 4d2:	a839                	j	4f0 <vprintf+0x4c>
        putc(fd, c);
 4d4:	85ca                	mv	a1,s2
 4d6:	8556                	mv	a0,s5
 4d8:	00000097          	auipc	ra,0x0
 4dc:	efe080e7          	jalr	-258(ra) # 3d6 <putc>
 4e0:	a019                	j	4e6 <vprintf+0x42>
    } else if(state == '%'){
 4e2:	01498d63          	beq	s3,s4,4fc <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4e6:	0485                	addi	s1,s1,1
 4e8:	fff4c903          	lbu	s2,-1(s1)
 4ec:	16090763          	beqz	s2,65a <vprintf+0x1b6>
    if(state == 0){
 4f0:	fe0999e3          	bnez	s3,4e2 <vprintf+0x3e>
      if(c == '%'){
 4f4:	ff4910e3          	bne	s2,s4,4d4 <vprintf+0x30>
        state = '%';
 4f8:	89d2                	mv	s3,s4
 4fa:	b7f5                	j	4e6 <vprintf+0x42>
      if(c == 'd'){
 4fc:	13490463          	beq	s2,s4,624 <vprintf+0x180>
 500:	f9d9079b          	addiw	a5,s2,-99
 504:	0ff7f793          	zext.b	a5,a5
 508:	12fb6763          	bltu	s6,a5,636 <vprintf+0x192>
 50c:	f9d9079b          	addiw	a5,s2,-99
 510:	0ff7f713          	zext.b	a4,a5
 514:	12eb6163          	bltu	s6,a4,636 <vprintf+0x192>
 518:	00271793          	slli	a5,a4,0x2
 51c:	00000717          	auipc	a4,0x0
 520:	37c70713          	addi	a4,a4,892 # 898 <malloc+0x142>
 524:	97ba                	add	a5,a5,a4
 526:	439c                	lw	a5,0(a5)
 528:	97ba                	add	a5,a5,a4
 52a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 52c:	008b8913          	addi	s2,s7,8
 530:	4685                	li	a3,1
 532:	4629                	li	a2,10
 534:	000ba583          	lw	a1,0(s7)
 538:	8556                	mv	a0,s5
 53a:	00000097          	auipc	ra,0x0
 53e:	ebe080e7          	jalr	-322(ra) # 3f8 <printint>
 542:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 544:	4981                	li	s3,0
 546:	b745                	j	4e6 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 548:	008b8913          	addi	s2,s7,8
 54c:	4681                	li	a3,0
 54e:	4629                	li	a2,10
 550:	000ba583          	lw	a1,0(s7)
 554:	8556                	mv	a0,s5
 556:	00000097          	auipc	ra,0x0
 55a:	ea2080e7          	jalr	-350(ra) # 3f8 <printint>
 55e:	8bca                	mv	s7,s2
      state = 0;
 560:	4981                	li	s3,0
 562:	b751                	j	4e6 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 564:	008b8913          	addi	s2,s7,8
 568:	4681                	li	a3,0
 56a:	4641                	li	a2,16
 56c:	000ba583          	lw	a1,0(s7)
 570:	8556                	mv	a0,s5
 572:	00000097          	auipc	ra,0x0
 576:	e86080e7          	jalr	-378(ra) # 3f8 <printint>
 57a:	8bca                	mv	s7,s2
      state = 0;
 57c:	4981                	li	s3,0
 57e:	b7a5                	j	4e6 <vprintf+0x42>
 580:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 582:	008b8c13          	addi	s8,s7,8
 586:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 58a:	03000593          	li	a1,48
 58e:	8556                	mv	a0,s5
 590:	00000097          	auipc	ra,0x0
 594:	e46080e7          	jalr	-442(ra) # 3d6 <putc>
  putc(fd, 'x');
 598:	07800593          	li	a1,120
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	e38080e7          	jalr	-456(ra) # 3d6 <putc>
 5a6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a8:	00000b97          	auipc	s7,0x0
 5ac:	348b8b93          	addi	s7,s7,840 # 8f0 <digits>
 5b0:	03c9d793          	srli	a5,s3,0x3c
 5b4:	97de                	add	a5,a5,s7
 5b6:	0007c583          	lbu	a1,0(a5)
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	e1a080e7          	jalr	-486(ra) # 3d6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5c4:	0992                	slli	s3,s3,0x4
 5c6:	397d                	addiw	s2,s2,-1
 5c8:	fe0914e3          	bnez	s2,5b0 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5cc:	8be2                	mv	s7,s8
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	6c02                	ld	s8,0(sp)
 5d2:	bf11                	j	4e6 <vprintf+0x42>
        s = va_arg(ap, char*);
 5d4:	008b8993          	addi	s3,s7,8
 5d8:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5dc:	02090163          	beqz	s2,5fe <vprintf+0x15a>
        while(*s != 0){
 5e0:	00094583          	lbu	a1,0(s2)
 5e4:	c9a5                	beqz	a1,654 <vprintf+0x1b0>
          putc(fd, *s);
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	dee080e7          	jalr	-530(ra) # 3d6 <putc>
          s++;
 5f0:	0905                	addi	s2,s2,1
        while(*s != 0){
 5f2:	00094583          	lbu	a1,0(s2)
 5f6:	f9e5                	bnez	a1,5e6 <vprintf+0x142>
        s = va_arg(ap, char*);
 5f8:	8bce                	mv	s7,s3
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	b5ed                	j	4e6 <vprintf+0x42>
          s = "(null)";
 5fe:	00000917          	auipc	s2,0x0
 602:	29290913          	addi	s2,s2,658 # 890 <malloc+0x13a>
        while(*s != 0){
 606:	02800593          	li	a1,40
 60a:	bff1                	j	5e6 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 60c:	008b8913          	addi	s2,s7,8
 610:	000bc583          	lbu	a1,0(s7)
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	dc0080e7          	jalr	-576(ra) # 3d6 <putc>
 61e:	8bca                	mv	s7,s2
      state = 0;
 620:	4981                	li	s3,0
 622:	b5d1                	j	4e6 <vprintf+0x42>
        putc(fd, c);
 624:	02500593          	li	a1,37
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	dac080e7          	jalr	-596(ra) # 3d6 <putc>
      state = 0;
 632:	4981                	li	s3,0
 634:	bd4d                	j	4e6 <vprintf+0x42>
        putc(fd, '%');
 636:	02500593          	li	a1,37
 63a:	8556                	mv	a0,s5
 63c:	00000097          	auipc	ra,0x0
 640:	d9a080e7          	jalr	-614(ra) # 3d6 <putc>
        putc(fd, c);
 644:	85ca                	mv	a1,s2
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	d8e080e7          	jalr	-626(ra) # 3d6 <putc>
      state = 0;
 650:	4981                	li	s3,0
 652:	bd51                	j	4e6 <vprintf+0x42>
        s = va_arg(ap, char*);
 654:	8bce                	mv	s7,s3
      state = 0;
 656:	4981                	li	s3,0
 658:	b579                	j	4e6 <vprintf+0x42>
 65a:	74e2                	ld	s1,56(sp)
 65c:	79a2                	ld	s3,40(sp)
 65e:	7a02                	ld	s4,32(sp)
 660:	6ae2                	ld	s5,24(sp)
 662:	6b42                	ld	s6,16(sp)
 664:	6ba2                	ld	s7,8(sp)
    }
  }
}
 666:	60a6                	ld	ra,72(sp)
 668:	6406                	ld	s0,64(sp)
 66a:	7942                	ld	s2,48(sp)
 66c:	6161                	addi	sp,sp,80
 66e:	8082                	ret

0000000000000670 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 670:	715d                	addi	sp,sp,-80
 672:	ec06                	sd	ra,24(sp)
 674:	e822                	sd	s0,16(sp)
 676:	1000                	addi	s0,sp,32
 678:	e010                	sd	a2,0(s0)
 67a:	e414                	sd	a3,8(s0)
 67c:	e818                	sd	a4,16(s0)
 67e:	ec1c                	sd	a5,24(s0)
 680:	03043023          	sd	a6,32(s0)
 684:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 688:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 68c:	8622                	mv	a2,s0
 68e:	00000097          	auipc	ra,0x0
 692:	e16080e7          	jalr	-490(ra) # 4a4 <vprintf>
}
 696:	60e2                	ld	ra,24(sp)
 698:	6442                	ld	s0,16(sp)
 69a:	6161                	addi	sp,sp,80
 69c:	8082                	ret

000000000000069e <printf>:

void
printf(const char *fmt, ...)
{
 69e:	711d                	addi	sp,sp,-96
 6a0:	ec06                	sd	ra,24(sp)
 6a2:	e822                	sd	s0,16(sp)
 6a4:	1000                	addi	s0,sp,32
 6a6:	e40c                	sd	a1,8(s0)
 6a8:	e810                	sd	a2,16(s0)
 6aa:	ec14                	sd	a3,24(s0)
 6ac:	f018                	sd	a4,32(s0)
 6ae:	f41c                	sd	a5,40(s0)
 6b0:	03043823          	sd	a6,48(s0)
 6b4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6b8:	00840613          	addi	a2,s0,8
 6bc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6c0:	85aa                	mv	a1,a0
 6c2:	4505                	li	a0,1
 6c4:	00000097          	auipc	ra,0x0
 6c8:	de0080e7          	jalr	-544(ra) # 4a4 <vprintf>
}
 6cc:	60e2                	ld	ra,24(sp)
 6ce:	6442                	ld	s0,16(sp)
 6d0:	6125                	addi	sp,sp,96
 6d2:	8082                	ret

00000000000006d4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6d4:	1141                	addi	sp,sp,-16
 6d6:	e422                	sd	s0,8(sp)
 6d8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6da:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6de:	00001797          	auipc	a5,0x1
 6e2:	d127b783          	ld	a5,-750(a5) # 13f0 <freep>
 6e6:	a02d                	j	710 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6e8:	4618                	lw	a4,8(a2)
 6ea:	9f2d                	addw	a4,a4,a1
 6ec:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f0:	6398                	ld	a4,0(a5)
 6f2:	6310                	ld	a2,0(a4)
 6f4:	a83d                	j	732 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6f6:	ff852703          	lw	a4,-8(a0)
 6fa:	9f31                	addw	a4,a4,a2
 6fc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6fe:	ff053683          	ld	a3,-16(a0)
 702:	a091                	j	746 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 704:	6398                	ld	a4,0(a5)
 706:	00e7e463          	bltu	a5,a4,70e <free+0x3a>
 70a:	00e6ea63          	bltu	a3,a4,71e <free+0x4a>
{
 70e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 710:	fed7fae3          	bgeu	a5,a3,704 <free+0x30>
 714:	6398                	ld	a4,0(a5)
 716:	00e6e463          	bltu	a3,a4,71e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 71a:	fee7eae3          	bltu	a5,a4,70e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 71e:	ff852583          	lw	a1,-8(a0)
 722:	6390                	ld	a2,0(a5)
 724:	02059813          	slli	a6,a1,0x20
 728:	01c85713          	srli	a4,a6,0x1c
 72c:	9736                	add	a4,a4,a3
 72e:	fae60de3          	beq	a2,a4,6e8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 732:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 736:	4790                	lw	a2,8(a5)
 738:	02061593          	slli	a1,a2,0x20
 73c:	01c5d713          	srli	a4,a1,0x1c
 740:	973e                	add	a4,a4,a5
 742:	fae68ae3          	beq	a3,a4,6f6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 746:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 748:	00001717          	auipc	a4,0x1
 74c:	caf73423          	sd	a5,-856(a4) # 13f0 <freep>
}
 750:	6422                	ld	s0,8(sp)
 752:	0141                	addi	sp,sp,16
 754:	8082                	ret

0000000000000756 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 756:	7139                	addi	sp,sp,-64
 758:	fc06                	sd	ra,56(sp)
 75a:	f822                	sd	s0,48(sp)
 75c:	f426                	sd	s1,40(sp)
 75e:	ec4e                	sd	s3,24(sp)
 760:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 762:	02051493          	slli	s1,a0,0x20
 766:	9081                	srli	s1,s1,0x20
 768:	04bd                	addi	s1,s1,15
 76a:	8091                	srli	s1,s1,0x4
 76c:	0014899b          	addiw	s3,s1,1
 770:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 772:	00001517          	auipc	a0,0x1
 776:	c7e53503          	ld	a0,-898(a0) # 13f0 <freep>
 77a:	c915                	beqz	a0,7ae <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 77c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 77e:	4798                	lw	a4,8(a5)
 780:	08977e63          	bgeu	a4,s1,81c <malloc+0xc6>
 784:	f04a                	sd	s2,32(sp)
 786:	e852                	sd	s4,16(sp)
 788:	e456                	sd	s5,8(sp)
 78a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 78c:	8a4e                	mv	s4,s3
 78e:	0009871b          	sext.w	a4,s3
 792:	6685                	lui	a3,0x1
 794:	00d77363          	bgeu	a4,a3,79a <malloc+0x44>
 798:	6a05                	lui	s4,0x1
 79a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 79e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7a2:	00001917          	auipc	s2,0x1
 7a6:	c4e90913          	addi	s2,s2,-946 # 13f0 <freep>
  if(p == (char*)-1)
 7aa:	5afd                	li	s5,-1
 7ac:	a091                	j	7f0 <malloc+0x9a>
 7ae:	f04a                	sd	s2,32(sp)
 7b0:	e852                	sd	s4,16(sp)
 7b2:	e456                	sd	s5,8(sp)
 7b4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7b6:	00001797          	auipc	a5,0x1
 7ba:	c4a78793          	addi	a5,a5,-950 # 1400 <base>
 7be:	00001717          	auipc	a4,0x1
 7c2:	c2f73923          	sd	a5,-974(a4) # 13f0 <freep>
 7c6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7c8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7cc:	b7c1                	j	78c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7ce:	6398                	ld	a4,0(a5)
 7d0:	e118                	sd	a4,0(a0)
 7d2:	a08d                	j	834 <malloc+0xde>
  hp->s.size = nu;
 7d4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7d8:	0541                	addi	a0,a0,16
 7da:	00000097          	auipc	ra,0x0
 7de:	efa080e7          	jalr	-262(ra) # 6d4 <free>
  return freep;
 7e2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7e6:	c13d                	beqz	a0,84c <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7e8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ea:	4798                	lw	a4,8(a5)
 7ec:	02977463          	bgeu	a4,s1,814 <malloc+0xbe>
    if(p == freep)
 7f0:	00093703          	ld	a4,0(s2)
 7f4:	853e                	mv	a0,a5
 7f6:	fef719e3          	bne	a4,a5,7e8 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7fa:	8552                	mv	a0,s4
 7fc:	00000097          	auipc	ra,0x0
 800:	b9a080e7          	jalr	-1126(ra) # 396 <sbrk>
  if(p == (char*)-1)
 804:	fd5518e3          	bne	a0,s5,7d4 <malloc+0x7e>
        return 0;
 808:	4501                	li	a0,0
 80a:	7902                	ld	s2,32(sp)
 80c:	6a42                	ld	s4,16(sp)
 80e:	6aa2                	ld	s5,8(sp)
 810:	6b02                	ld	s6,0(sp)
 812:	a03d                	j	840 <malloc+0xea>
 814:	7902                	ld	s2,32(sp)
 816:	6a42                	ld	s4,16(sp)
 818:	6aa2                	ld	s5,8(sp)
 81a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 81c:	fae489e3          	beq	s1,a4,7ce <malloc+0x78>
        p->s.size -= nunits;
 820:	4137073b          	subw	a4,a4,s3
 824:	c798                	sw	a4,8(a5)
        p += p->s.size;
 826:	02071693          	slli	a3,a4,0x20
 82a:	01c6d713          	srli	a4,a3,0x1c
 82e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 830:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 834:	00001717          	auipc	a4,0x1
 838:	baa73e23          	sd	a0,-1092(a4) # 13f0 <freep>
      return (void*)(p + 1);
 83c:	01078513          	addi	a0,a5,16
  }
}
 840:	70e2                	ld	ra,56(sp)
 842:	7442                	ld	s0,48(sp)
 844:	74a2                	ld	s1,40(sp)
 846:	69e2                	ld	s3,24(sp)
 848:	6121                	addi	sp,sp,64
 84a:	8082                	ret
 84c:	7902                	ld	s2,32(sp)
 84e:	6a42                	ld	s4,16(sp)
 850:	6aa2                	ld	s5,8(sp)
 852:	6b02                	ld	s6,0(sp)
 854:	b7f5                	j	840 <malloc+0xea>
