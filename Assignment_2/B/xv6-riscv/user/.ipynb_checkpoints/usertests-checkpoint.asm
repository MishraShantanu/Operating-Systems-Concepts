
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00006097          	auipc	ra,0x6
      14:	888080e7          	jalr	-1912(ra) # 5898 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00006097          	auipc	ra,0x6
      26:	876080e7          	jalr	-1930(ra) # 5898 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	d3a50513          	addi	a0,a0,-710 # 5d78 <malloc+0xe6>
      46:	00006097          	auipc	ra,0x6
      4a:	b94080e7          	jalr	-1132(ra) # 5bda <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00006097          	auipc	ra,0x6
      54:	808080e7          	jalr	-2040(ra) # 5858 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	00009797          	auipc	a5,0x9
      5c:	6a878793          	addi	a5,a5,1704 # 9700 <uninit>
      60:	0000c697          	auipc	a3,0xc
      64:	db068693          	addi	a3,a3,-592 # be10 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	d1850513          	addi	a0,a0,-744 # 5d98 <malloc+0x106>
      88:	00006097          	auipc	ra,0x6
      8c:	b52080e7          	jalr	-1198(ra) # 5bda <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00005097          	auipc	ra,0x5
      96:	7c6080e7          	jalr	1990(ra) # 5858 <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	d0850513          	addi	a0,a0,-760 # 5db0 <malloc+0x11e>
      b0:	00005097          	auipc	ra,0x5
      b4:	7e8080e7          	jalr	2024(ra) # 5898 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00005097          	auipc	ra,0x5
      c0:	7c4080e7          	jalr	1988(ra) # 5880 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	d0a50513          	addi	a0,a0,-758 # 5dd0 <malloc+0x13e>
      ce:	00005097          	auipc	ra,0x5
      d2:	7ca080e7          	jalr	1994(ra) # 5898 <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	cd250513          	addi	a0,a0,-814 # 5db8 <malloc+0x126>
      ee:	00006097          	auipc	ra,0x6
      f2:	aec080e7          	jalr	-1300(ra) # 5bda <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00005097          	auipc	ra,0x5
      fc:	760080e7          	jalr	1888(ra) # 5858 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	cde50513          	addi	a0,a0,-802 # 5de0 <malloc+0x14e>
     10a:	00006097          	auipc	ra,0x6
     10e:	ad0080e7          	jalr	-1328(ra) # 5bda <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00005097          	auipc	ra,0x5
     118:	744080e7          	jalr	1860(ra) # 5858 <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	cdc50513          	addi	a0,a0,-804 # 5e08 <malloc+0x176>
     134:	00005097          	auipc	ra,0x5
     138:	774080e7          	jalr	1908(ra) # 58a8 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	cc850513          	addi	a0,a0,-824 # 5e08 <malloc+0x176>
     148:	00005097          	auipc	ra,0x5
     14c:	750080e7          	jalr	1872(ra) # 5898 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	cc458593          	addi	a1,a1,-828 # 5e18 <malloc+0x186>
     15c:	00005097          	auipc	ra,0x5
     160:	71c080e7          	jalr	1820(ra) # 5878 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	ca050513          	addi	a0,a0,-864 # 5e08 <malloc+0x176>
     170:	00005097          	auipc	ra,0x5
     174:	728080e7          	jalr	1832(ra) # 5898 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	ca458593          	addi	a1,a1,-860 # 5e20 <malloc+0x18e>
     184:	8526                	mv	a0,s1
     186:	00005097          	auipc	ra,0x5
     18a:	6f2080e7          	jalr	1778(ra) # 5878 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	c7450513          	addi	a0,a0,-908 # 5e08 <malloc+0x176>
     19c:	00005097          	auipc	ra,0x5
     1a0:	70c080e7          	jalr	1804(ra) # 58a8 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00005097          	auipc	ra,0x5
     1aa:	6da080e7          	jalr	1754(ra) # 5880 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00005097          	auipc	ra,0x5
     1b4:	6d0080e7          	jalr	1744(ra) # 5880 <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	c5e50513          	addi	a0,a0,-930 # 5e28 <malloc+0x196>
     1d2:	00006097          	auipc	ra,0x6
     1d6:	a08080e7          	jalr	-1528(ra) # 5bda <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00005097          	auipc	ra,0x5
     1e0:	67c080e7          	jalr	1660(ra) # 5858 <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f0:	06100793          	li	a5,97
     1f4:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1f8:	fc040d23          	sb	zero,-38(s0)
     1fc:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     200:	06400913          	li	s2,100
    name[1] = '0' + i;
     204:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     208:	20200593          	li	a1,514
     20c:	fd840513          	addi	a0,s0,-40
     210:	00005097          	auipc	ra,0x5
     214:	688080e7          	jalr	1672(ra) # 5898 <open>
    close(fd);
     218:	00005097          	auipc	ra,0x5
     21c:	668080e7          	jalr	1640(ra) # 5880 <close>
  for(i = 0; i < N; i++){
     220:	2485                	addiw	s1,s1,1
     222:	0ff4f493          	zext.b	s1,s1
     226:	fd249fe3          	bne	s1,s2,204 <createtest+0x20>
  name[0] = 'a';
     22a:	06100793          	li	a5,97
     22e:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     232:	fc040d23          	sb	zero,-38(s0)
     236:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     23a:	06400913          	li	s2,100
    name[1] = '0' + i;
     23e:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     242:	fd840513          	addi	a0,s0,-40
     246:	00005097          	auipc	ra,0x5
     24a:	662080e7          	jalr	1634(ra) # 58a8 <unlink>
  for(i = 0; i < N; i++){
     24e:	2485                	addiw	s1,s1,1
     250:	0ff4f493          	zext.b	s1,s1
     254:	ff2495e3          	bne	s1,s2,23e <createtest+0x5a>
}
     258:	70a2                	ld	ra,40(sp)
     25a:	7402                	ld	s0,32(sp)
     25c:	64e2                	ld	s1,24(sp)
     25e:	6942                	ld	s2,16(sp)
     260:	6145                	addi	sp,sp,48
     262:	8082                	ret

0000000000000264 <bigwrite>:
{
     264:	715d                	addi	sp,sp,-80
     266:	e486                	sd	ra,72(sp)
     268:	e0a2                	sd	s0,64(sp)
     26a:	fc26                	sd	s1,56(sp)
     26c:	f84a                	sd	s2,48(sp)
     26e:	f44e                	sd	s3,40(sp)
     270:	f052                	sd	s4,32(sp)
     272:	ec56                	sd	s5,24(sp)
     274:	e85a                	sd	s6,16(sp)
     276:	e45e                	sd	s7,8(sp)
     278:	0880                	addi	s0,sp,80
     27a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     27c:	00006517          	auipc	a0,0x6
     280:	bd450513          	addi	a0,a0,-1068 # 5e50 <malloc+0x1be>
     284:	00005097          	auipc	ra,0x5
     288:	624080e7          	jalr	1572(ra) # 58a8 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
     294:	bc0a8a93          	addi	s5,s5,-1088 # 5e50 <malloc+0x1be>
      int cc = write(fd, buf, sz);
     298:	0000ca17          	auipc	s4,0xc
     29c:	b78a0a13          	addi	s4,s4,-1160 # be10 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <dirtest+0x81>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00005097          	auipc	ra,0x5
     2b0:	5ec080e7          	jalr	1516(ra) # 5898 <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00005097          	auipc	ra,0x5
     2c2:	5ba080e7          	jalr	1466(ra) # 5878 <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49263          	bne	s1,a0,32c <bigwrite+0xc8>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00005097          	auipc	ra,0x5
     2d6:	5a6080e7          	jalr	1446(ra) # 5878 <write>
      if(cc != sz){
     2da:	04951a63          	bne	a0,s1,32e <bigwrite+0xca>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00005097          	auipc	ra,0x5
     2e4:	5a0080e7          	jalr	1440(ra) # 5880 <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00005097          	auipc	ra,0x5
     2ee:	5be080e7          	jalr	1470(ra) # 58a8 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2f2:	1d74849b          	addiw	s1,s1,471
     2f6:	fb6498e3          	bne	s1,s6,2a6 <bigwrite+0x42>
}
     2fa:	60a6                	ld	ra,72(sp)
     2fc:	6406                	ld	s0,64(sp)
     2fe:	74e2                	ld	s1,56(sp)
     300:	7942                	ld	s2,48(sp)
     302:	79a2                	ld	s3,40(sp)
     304:	7a02                	ld	s4,32(sp)
     306:	6ae2                	ld	s5,24(sp)
     308:	6b42                	ld	s6,16(sp)
     30a:	6ba2                	ld	s7,8(sp)
     30c:	6161                	addi	sp,sp,80
     30e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     310:	85de                	mv	a1,s7
     312:	00006517          	auipc	a0,0x6
     316:	b4e50513          	addi	a0,a0,-1202 # 5e60 <malloc+0x1ce>
     31a:	00006097          	auipc	ra,0x6
     31e:	8c0080e7          	jalr	-1856(ra) # 5bda <printf>
      exit(1);
     322:	4505                	li	a0,1
     324:	00005097          	auipc	ra,0x5
     328:	534080e7          	jalr	1332(ra) # 5858 <exit>
      if(cc != sz){
     32c:	89a6                	mv	s3,s1
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     32e:	86aa                	mv	a3,a0
     330:	864e                	mv	a2,s3
     332:	85de                	mv	a1,s7
     334:	00006517          	auipc	a0,0x6
     338:	b4c50513          	addi	a0,a0,-1204 # 5e80 <malloc+0x1ee>
     33c:	00006097          	auipc	ra,0x6
     340:	89e080e7          	jalr	-1890(ra) # 5bda <printf>
        exit(1);
     344:	4505                	li	a0,1
     346:	00005097          	auipc	ra,0x5
     34a:	512080e7          	jalr	1298(ra) # 5858 <exit>

000000000000034e <copyin>:
{
     34e:	715d                	addi	sp,sp,-80
     350:	e486                	sd	ra,72(sp)
     352:	e0a2                	sd	s0,64(sp)
     354:	fc26                	sd	s1,56(sp)
     356:	f84a                	sd	s2,48(sp)
     358:	f44e                	sd	s3,40(sp)
     35a:	f052                	sd	s4,32(sp)
     35c:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     35e:	4785                	li	a5,1
     360:	07fe                	slli	a5,a5,0x1f
     362:	fcf43023          	sd	a5,-64(s0)
     366:	57fd                	li	a5,-1
     368:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     36c:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     370:	00006a17          	auipc	s4,0x6
     374:	b28a0a13          	addi	s4,s4,-1240 # 5e98 <malloc+0x206>
    uint64 addr = addrs[ai];
     378:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     37c:	20100593          	li	a1,513
     380:	8552                	mv	a0,s4
     382:	00005097          	auipc	ra,0x5
     386:	516080e7          	jalr	1302(ra) # 5898 <open>
     38a:	84aa                	mv	s1,a0
    if(fd < 0){
     38c:	08054863          	bltz	a0,41c <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     390:	6609                	lui	a2,0x2
     392:	85ce                	mv	a1,s3
     394:	00005097          	auipc	ra,0x5
     398:	4e4080e7          	jalr	1252(ra) # 5878 <write>
    if(n >= 0){
     39c:	08055d63          	bgez	a0,436 <copyin+0xe8>
    close(fd);
     3a0:	8526                	mv	a0,s1
     3a2:	00005097          	auipc	ra,0x5
     3a6:	4de080e7          	jalr	1246(ra) # 5880 <close>
    unlink("copyin1");
     3aa:	8552                	mv	a0,s4
     3ac:	00005097          	auipc	ra,0x5
     3b0:	4fc080e7          	jalr	1276(ra) # 58a8 <unlink>
    n = write(1, (char*)addr, 8192);
     3b4:	6609                	lui	a2,0x2
     3b6:	85ce                	mv	a1,s3
     3b8:	4505                	li	a0,1
     3ba:	00005097          	auipc	ra,0x5
     3be:	4be080e7          	jalr	1214(ra) # 5878 <write>
    if(n > 0){
     3c2:	08a04963          	bgtz	a0,454 <copyin+0x106>
    if(pipe(fds) < 0){
     3c6:	fb840513          	addi	a0,s0,-72
     3ca:	00005097          	auipc	ra,0x5
     3ce:	49e080e7          	jalr	1182(ra) # 5868 <pipe>
     3d2:	0a054063          	bltz	a0,472 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     3d6:	6609                	lui	a2,0x2
     3d8:	85ce                	mv	a1,s3
     3da:	fbc42503          	lw	a0,-68(s0)
     3de:	00005097          	auipc	ra,0x5
     3e2:	49a080e7          	jalr	1178(ra) # 5878 <write>
    if(n > 0){
     3e6:	0aa04363          	bgtz	a0,48c <copyin+0x13e>
    close(fds[0]);
     3ea:	fb842503          	lw	a0,-72(s0)
     3ee:	00005097          	auipc	ra,0x5
     3f2:	492080e7          	jalr	1170(ra) # 5880 <close>
    close(fds[1]);
     3f6:	fbc42503          	lw	a0,-68(s0)
     3fa:	00005097          	auipc	ra,0x5
     3fe:	486080e7          	jalr	1158(ra) # 5880 <close>
  for(int ai = 0; ai < 2; ai++){
     402:	0921                	addi	s2,s2,8
     404:	fd040793          	addi	a5,s0,-48
     408:	f6f918e3          	bne	s2,a5,378 <copyin+0x2a>
}
     40c:	60a6                	ld	ra,72(sp)
     40e:	6406                	ld	s0,64(sp)
     410:	74e2                	ld	s1,56(sp)
     412:	7942                	ld	s2,48(sp)
     414:	79a2                	ld	s3,40(sp)
     416:	7a02                	ld	s4,32(sp)
     418:	6161                	addi	sp,sp,80
     41a:	8082                	ret
      printf("open(copyin1) failed\n");
     41c:	00006517          	auipc	a0,0x6
     420:	a8450513          	addi	a0,a0,-1404 # 5ea0 <malloc+0x20e>
     424:	00005097          	auipc	ra,0x5
     428:	7b6080e7          	jalr	1974(ra) # 5bda <printf>
      exit(1);
     42c:	4505                	li	a0,1
     42e:	00005097          	auipc	ra,0x5
     432:	42a080e7          	jalr	1066(ra) # 5858 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     436:	862a                	mv	a2,a0
     438:	85ce                	mv	a1,s3
     43a:	00006517          	auipc	a0,0x6
     43e:	a7e50513          	addi	a0,a0,-1410 # 5eb8 <malloc+0x226>
     442:	00005097          	auipc	ra,0x5
     446:	798080e7          	jalr	1944(ra) # 5bda <printf>
      exit(1);
     44a:	4505                	li	a0,1
     44c:	00005097          	auipc	ra,0x5
     450:	40c080e7          	jalr	1036(ra) # 5858 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     454:	862a                	mv	a2,a0
     456:	85ce                	mv	a1,s3
     458:	00006517          	auipc	a0,0x6
     45c:	a9050513          	addi	a0,a0,-1392 # 5ee8 <malloc+0x256>
     460:	00005097          	auipc	ra,0x5
     464:	77a080e7          	jalr	1914(ra) # 5bda <printf>
      exit(1);
     468:	4505                	li	a0,1
     46a:	00005097          	auipc	ra,0x5
     46e:	3ee080e7          	jalr	1006(ra) # 5858 <exit>
      printf("pipe() failed\n");
     472:	00006517          	auipc	a0,0x6
     476:	aa650513          	addi	a0,a0,-1370 # 5f18 <malloc+0x286>
     47a:	00005097          	auipc	ra,0x5
     47e:	760080e7          	jalr	1888(ra) # 5bda <printf>
      exit(1);
     482:	4505                	li	a0,1
     484:	00005097          	auipc	ra,0x5
     488:	3d4080e7          	jalr	980(ra) # 5858 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     48c:	862a                	mv	a2,a0
     48e:	85ce                	mv	a1,s3
     490:	00006517          	auipc	a0,0x6
     494:	a9850513          	addi	a0,a0,-1384 # 5f28 <malloc+0x296>
     498:	00005097          	auipc	ra,0x5
     49c:	742080e7          	jalr	1858(ra) # 5bda <printf>
      exit(1);
     4a0:	4505                	li	a0,1
     4a2:	00005097          	auipc	ra,0x5
     4a6:	3b6080e7          	jalr	950(ra) # 5858 <exit>

00000000000004aa <copyout>:
{
     4aa:	711d                	addi	sp,sp,-96
     4ac:	ec86                	sd	ra,88(sp)
     4ae:	e8a2                	sd	s0,80(sp)
     4b0:	e4a6                	sd	s1,72(sp)
     4b2:	e0ca                	sd	s2,64(sp)
     4b4:	fc4e                	sd	s3,56(sp)
     4b6:	f852                	sd	s4,48(sp)
     4b8:	f456                	sd	s5,40(sp)
     4ba:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4bc:	4785                	li	a5,1
     4be:	07fe                	slli	a5,a5,0x1f
     4c0:	faf43823          	sd	a5,-80(s0)
     4c4:	57fd                	li	a5,-1
     4c6:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     4ca:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     4ce:	00006a17          	auipc	s4,0x6
     4d2:	a8aa0a13          	addi	s4,s4,-1398 # 5f58 <malloc+0x2c6>
    n = write(fds[1], "x", 1);
     4d6:	00006a97          	auipc	s5,0x6
     4da:	94aa8a93          	addi	s5,s5,-1718 # 5e20 <malloc+0x18e>
    uint64 addr = addrs[ai];
     4de:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     4e2:	4581                	li	a1,0
     4e4:	8552                	mv	a0,s4
     4e6:	00005097          	auipc	ra,0x5
     4ea:	3b2080e7          	jalr	946(ra) # 5898 <open>
     4ee:	84aa                	mv	s1,a0
    if(fd < 0){
     4f0:	08054663          	bltz	a0,57c <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     4f4:	6609                	lui	a2,0x2
     4f6:	85ce                	mv	a1,s3
     4f8:	00005097          	auipc	ra,0x5
     4fc:	378080e7          	jalr	888(ra) # 5870 <read>
    if(n > 0){
     500:	08a04b63          	bgtz	a0,596 <copyout+0xec>
    close(fd);
     504:	8526                	mv	a0,s1
     506:	00005097          	auipc	ra,0x5
     50a:	37a080e7          	jalr	890(ra) # 5880 <close>
    if(pipe(fds) < 0){
     50e:	fa840513          	addi	a0,s0,-88
     512:	00005097          	auipc	ra,0x5
     516:	356080e7          	jalr	854(ra) # 5868 <pipe>
     51a:	08054d63          	bltz	a0,5b4 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     51e:	4605                	li	a2,1
     520:	85d6                	mv	a1,s5
     522:	fac42503          	lw	a0,-84(s0)
     526:	00005097          	auipc	ra,0x5
     52a:	352080e7          	jalr	850(ra) # 5878 <write>
    if(n != 1){
     52e:	4785                	li	a5,1
     530:	08f51f63          	bne	a0,a5,5ce <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     534:	6609                	lui	a2,0x2
     536:	85ce                	mv	a1,s3
     538:	fa842503          	lw	a0,-88(s0)
     53c:	00005097          	auipc	ra,0x5
     540:	334080e7          	jalr	820(ra) # 5870 <read>
    if(n > 0){
     544:	0aa04263          	bgtz	a0,5e8 <copyout+0x13e>
    close(fds[0]);
     548:	fa842503          	lw	a0,-88(s0)
     54c:	00005097          	auipc	ra,0x5
     550:	334080e7          	jalr	820(ra) # 5880 <close>
    close(fds[1]);
     554:	fac42503          	lw	a0,-84(s0)
     558:	00005097          	auipc	ra,0x5
     55c:	328080e7          	jalr	808(ra) # 5880 <close>
  for(int ai = 0; ai < 2; ai++){
     560:	0921                	addi	s2,s2,8
     562:	fc040793          	addi	a5,s0,-64
     566:	f6f91ce3          	bne	s2,a5,4de <copyout+0x34>
}
     56a:	60e6                	ld	ra,88(sp)
     56c:	6446                	ld	s0,80(sp)
     56e:	64a6                	ld	s1,72(sp)
     570:	6906                	ld	s2,64(sp)
     572:	79e2                	ld	s3,56(sp)
     574:	7a42                	ld	s4,48(sp)
     576:	7aa2                	ld	s5,40(sp)
     578:	6125                	addi	sp,sp,96
     57a:	8082                	ret
      printf("open(README) failed\n");
     57c:	00006517          	auipc	a0,0x6
     580:	9e450513          	addi	a0,a0,-1564 # 5f60 <malloc+0x2ce>
     584:	00005097          	auipc	ra,0x5
     588:	656080e7          	jalr	1622(ra) # 5bda <printf>
      exit(1);
     58c:	4505                	li	a0,1
     58e:	00005097          	auipc	ra,0x5
     592:	2ca080e7          	jalr	714(ra) # 5858 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     596:	862a                	mv	a2,a0
     598:	85ce                	mv	a1,s3
     59a:	00006517          	auipc	a0,0x6
     59e:	9de50513          	addi	a0,a0,-1570 # 5f78 <malloc+0x2e6>
     5a2:	00005097          	auipc	ra,0x5
     5a6:	638080e7          	jalr	1592(ra) # 5bda <printf>
      exit(1);
     5aa:	4505                	li	a0,1
     5ac:	00005097          	auipc	ra,0x5
     5b0:	2ac080e7          	jalr	684(ra) # 5858 <exit>
      printf("pipe() failed\n");
     5b4:	00006517          	auipc	a0,0x6
     5b8:	96450513          	addi	a0,a0,-1692 # 5f18 <malloc+0x286>
     5bc:	00005097          	auipc	ra,0x5
     5c0:	61e080e7          	jalr	1566(ra) # 5bda <printf>
      exit(1);
     5c4:	4505                	li	a0,1
     5c6:	00005097          	auipc	ra,0x5
     5ca:	292080e7          	jalr	658(ra) # 5858 <exit>
      printf("pipe write failed\n");
     5ce:	00006517          	auipc	a0,0x6
     5d2:	9da50513          	addi	a0,a0,-1574 # 5fa8 <malloc+0x316>
     5d6:	00005097          	auipc	ra,0x5
     5da:	604080e7          	jalr	1540(ra) # 5bda <printf>
      exit(1);
     5de:	4505                	li	a0,1
     5e0:	00005097          	auipc	ra,0x5
     5e4:	278080e7          	jalr	632(ra) # 5858 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5e8:	862a                	mv	a2,a0
     5ea:	85ce                	mv	a1,s3
     5ec:	00006517          	auipc	a0,0x6
     5f0:	9d450513          	addi	a0,a0,-1580 # 5fc0 <malloc+0x32e>
     5f4:	00005097          	auipc	ra,0x5
     5f8:	5e6080e7          	jalr	1510(ra) # 5bda <printf>
      exit(1);
     5fc:	4505                	li	a0,1
     5fe:	00005097          	auipc	ra,0x5
     602:	25a080e7          	jalr	602(ra) # 5858 <exit>

0000000000000606 <truncate1>:
{
     606:	711d                	addi	sp,sp,-96
     608:	ec86                	sd	ra,88(sp)
     60a:	e8a2                	sd	s0,80(sp)
     60c:	e4a6                	sd	s1,72(sp)
     60e:	e0ca                	sd	s2,64(sp)
     610:	fc4e                	sd	s3,56(sp)
     612:	f852                	sd	s4,48(sp)
     614:	f456                	sd	s5,40(sp)
     616:	1080                	addi	s0,sp,96
     618:	8aaa                	mv	s5,a0
  unlink("truncfile");
     61a:	00005517          	auipc	a0,0x5
     61e:	7ee50513          	addi	a0,a0,2030 # 5e08 <malloc+0x176>
     622:	00005097          	auipc	ra,0x5
     626:	286080e7          	jalr	646(ra) # 58a8 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     62a:	60100593          	li	a1,1537
     62e:	00005517          	auipc	a0,0x5
     632:	7da50513          	addi	a0,a0,2010 # 5e08 <malloc+0x176>
     636:	00005097          	auipc	ra,0x5
     63a:	262080e7          	jalr	610(ra) # 5898 <open>
     63e:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     640:	4611                	li	a2,4
     642:	00005597          	auipc	a1,0x5
     646:	7d658593          	addi	a1,a1,2006 # 5e18 <malloc+0x186>
     64a:	00005097          	auipc	ra,0x5
     64e:	22e080e7          	jalr	558(ra) # 5878 <write>
  close(fd1);
     652:	8526                	mv	a0,s1
     654:	00005097          	auipc	ra,0x5
     658:	22c080e7          	jalr	556(ra) # 5880 <close>
  int fd2 = open("truncfile", O_RDONLY);
     65c:	4581                	li	a1,0
     65e:	00005517          	auipc	a0,0x5
     662:	7aa50513          	addi	a0,a0,1962 # 5e08 <malloc+0x176>
     666:	00005097          	auipc	ra,0x5
     66a:	232080e7          	jalr	562(ra) # 5898 <open>
     66e:	84aa                	mv	s1,a0
  printf("*************%p**************\n",buf);
     670:	fa040593          	addi	a1,s0,-96
     674:	00006517          	auipc	a0,0x6
     678:	97c50513          	addi	a0,a0,-1668 # 5ff0 <malloc+0x35e>
     67c:	00005097          	auipc	ra,0x5
     680:	55e080e7          	jalr	1374(ra) # 5bda <printf>
  int n = read(fd2, buf, sizeof(buf));
     684:	02000613          	li	a2,32
     688:	fa040593          	addi	a1,s0,-96
     68c:	8526                	mv	a0,s1
     68e:	00005097          	auipc	ra,0x5
     692:	1e2080e7          	jalr	482(ra) # 5870 <read>
  if(n != 4){
     696:	4791                	li	a5,4
     698:	0cf51e63          	bne	a0,a5,774 <truncate1+0x16e>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     69c:	40100593          	li	a1,1025
     6a0:	00005517          	auipc	a0,0x5
     6a4:	76850513          	addi	a0,a0,1896 # 5e08 <malloc+0x176>
     6a8:	00005097          	auipc	ra,0x5
     6ac:	1f0080e7          	jalr	496(ra) # 5898 <open>
     6b0:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     6b2:	4581                	li	a1,0
     6b4:	00005517          	auipc	a0,0x5
     6b8:	75450513          	addi	a0,a0,1876 # 5e08 <malloc+0x176>
     6bc:	00005097          	auipc	ra,0x5
     6c0:	1dc080e7          	jalr	476(ra) # 5898 <open>
     6c4:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6c6:	02000613          	li	a2,32
     6ca:	fa040593          	addi	a1,s0,-96
     6ce:	00005097          	auipc	ra,0x5
     6d2:	1a2080e7          	jalr	418(ra) # 5870 <read>
     6d6:	8a2a                	mv	s4,a0
  if(n != 0){
     6d8:	ed4d                	bnez	a0,792 <truncate1+0x18c>
  n = read(fd2, buf, sizeof(buf));
     6da:	02000613          	li	a2,32
     6de:	fa040593          	addi	a1,s0,-96
     6e2:	8526                	mv	a0,s1
     6e4:	00005097          	auipc	ra,0x5
     6e8:	18c080e7          	jalr	396(ra) # 5870 <read>
     6ec:	8a2a                	mv	s4,a0
  if(n != 0){
     6ee:	e971                	bnez	a0,7c2 <truncate1+0x1bc>
  write(fd1, "abcdef", 6);
     6f0:	4619                	li	a2,6
     6f2:	00006597          	auipc	a1,0x6
     6f6:	97e58593          	addi	a1,a1,-1666 # 6070 <malloc+0x3de>
     6fa:	854e                	mv	a0,s3
     6fc:	00005097          	auipc	ra,0x5
     700:	17c080e7          	jalr	380(ra) # 5878 <write>
  n = read(fd3, buf, sizeof(buf));
     704:	02000613          	li	a2,32
     708:	fa040593          	addi	a1,s0,-96
     70c:	854a                	mv	a0,s2
     70e:	00005097          	auipc	ra,0x5
     712:	162080e7          	jalr	354(ra) # 5870 <read>
  if(n != 6){
     716:	4799                	li	a5,6
     718:	0cf51d63          	bne	a0,a5,7f2 <truncate1+0x1ec>
  n = read(fd2, buf, sizeof(buf));
     71c:	02000613          	li	a2,32
     720:	fa040593          	addi	a1,s0,-96
     724:	8526                	mv	a0,s1
     726:	00005097          	auipc	ra,0x5
     72a:	14a080e7          	jalr	330(ra) # 5870 <read>
  if(n != 2){
     72e:	4789                	li	a5,2
     730:	0ef51063          	bne	a0,a5,810 <truncate1+0x20a>
  unlink("truncfile");
     734:	00005517          	auipc	a0,0x5
     738:	6d450513          	addi	a0,a0,1748 # 5e08 <malloc+0x176>
     73c:	00005097          	auipc	ra,0x5
     740:	16c080e7          	jalr	364(ra) # 58a8 <unlink>
  close(fd1);
     744:	854e                	mv	a0,s3
     746:	00005097          	auipc	ra,0x5
     74a:	13a080e7          	jalr	314(ra) # 5880 <close>
  close(fd2);
     74e:	8526                	mv	a0,s1
     750:	00005097          	auipc	ra,0x5
     754:	130080e7          	jalr	304(ra) # 5880 <close>
  close(fd3);
     758:	854a                	mv	a0,s2
     75a:	00005097          	auipc	ra,0x5
     75e:	126080e7          	jalr	294(ra) # 5880 <close>
}
     762:	60e6                	ld	ra,88(sp)
     764:	6446                	ld	s0,80(sp)
     766:	64a6                	ld	s1,72(sp)
     768:	6906                	ld	s2,64(sp)
     76a:	79e2                	ld	s3,56(sp)
     76c:	7a42                	ld	s4,48(sp)
     76e:	7aa2                	ld	s5,40(sp)
     770:	6125                	addi	sp,sp,96
     772:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     774:	862a                	mv	a2,a0
     776:	85d6                	mv	a1,s5
     778:	00006517          	auipc	a0,0x6
     77c:	89850513          	addi	a0,a0,-1896 # 6010 <malloc+0x37e>
     780:	00005097          	auipc	ra,0x5
     784:	45a080e7          	jalr	1114(ra) # 5bda <printf>
    exit(1);
     788:	4505                	li	a0,1
     78a:	00005097          	auipc	ra,0x5
     78e:	0ce080e7          	jalr	206(ra) # 5858 <exit>
    printf("aaa fd3=%d\n", fd3);
     792:	85ca                	mv	a1,s2
     794:	00006517          	auipc	a0,0x6
     798:	89c50513          	addi	a0,a0,-1892 # 6030 <malloc+0x39e>
     79c:	00005097          	auipc	ra,0x5
     7a0:	43e080e7          	jalr	1086(ra) # 5bda <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7a4:	8652                	mv	a2,s4
     7a6:	85d6                	mv	a1,s5
     7a8:	00006517          	auipc	a0,0x6
     7ac:	89850513          	addi	a0,a0,-1896 # 6040 <malloc+0x3ae>
     7b0:	00005097          	auipc	ra,0x5
     7b4:	42a080e7          	jalr	1066(ra) # 5bda <printf>
    exit(1);
     7b8:	4505                	li	a0,1
     7ba:	00005097          	auipc	ra,0x5
     7be:	09e080e7          	jalr	158(ra) # 5858 <exit>
    printf("bbb fd2=%d\n", fd2);
     7c2:	85a6                	mv	a1,s1
     7c4:	00006517          	auipc	a0,0x6
     7c8:	89c50513          	addi	a0,a0,-1892 # 6060 <malloc+0x3ce>
     7cc:	00005097          	auipc	ra,0x5
     7d0:	40e080e7          	jalr	1038(ra) # 5bda <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7d4:	8652                	mv	a2,s4
     7d6:	85d6                	mv	a1,s5
     7d8:	00006517          	auipc	a0,0x6
     7dc:	86850513          	addi	a0,a0,-1944 # 6040 <malloc+0x3ae>
     7e0:	00005097          	auipc	ra,0x5
     7e4:	3fa080e7          	jalr	1018(ra) # 5bda <printf>
    exit(1);
     7e8:	4505                	li	a0,1
     7ea:	00005097          	auipc	ra,0x5
     7ee:	06e080e7          	jalr	110(ra) # 5858 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7f2:	862a                	mv	a2,a0
     7f4:	85d6                	mv	a1,s5
     7f6:	00006517          	auipc	a0,0x6
     7fa:	88250513          	addi	a0,a0,-1918 # 6078 <malloc+0x3e6>
     7fe:	00005097          	auipc	ra,0x5
     802:	3dc080e7          	jalr	988(ra) # 5bda <printf>
    exit(1);
     806:	4505                	li	a0,1
     808:	00005097          	auipc	ra,0x5
     80c:	050080e7          	jalr	80(ra) # 5858 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     810:	862a                	mv	a2,a0
     812:	85d6                	mv	a1,s5
     814:	00006517          	auipc	a0,0x6
     818:	88450513          	addi	a0,a0,-1916 # 6098 <malloc+0x406>
     81c:	00005097          	auipc	ra,0x5
     820:	3be080e7          	jalr	958(ra) # 5bda <printf>
    exit(1);
     824:	4505                	li	a0,1
     826:	00005097          	auipc	ra,0x5
     82a:	032080e7          	jalr	50(ra) # 5858 <exit>

000000000000082e <writetest>:
{
     82e:	7139                	addi	sp,sp,-64
     830:	fc06                	sd	ra,56(sp)
     832:	f822                	sd	s0,48(sp)
     834:	f426                	sd	s1,40(sp)
     836:	f04a                	sd	s2,32(sp)
     838:	ec4e                	sd	s3,24(sp)
     83a:	e852                	sd	s4,16(sp)
     83c:	e456                	sd	s5,8(sp)
     83e:	e05a                	sd	s6,0(sp)
     840:	0080                	addi	s0,sp,64
     842:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     844:	20200593          	li	a1,514
     848:	00006517          	auipc	a0,0x6
     84c:	87050513          	addi	a0,a0,-1936 # 60b8 <malloc+0x426>
     850:	00005097          	auipc	ra,0x5
     854:	048080e7          	jalr	72(ra) # 5898 <open>
  if(fd < 0){
     858:	0a054d63          	bltz	a0,912 <writetest+0xe4>
     85c:	892a                	mv	s2,a0
     85e:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     860:	00006997          	auipc	s3,0x6
     864:	88098993          	addi	s3,s3,-1920 # 60e0 <malloc+0x44e>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     868:	00006a97          	auipc	s5,0x6
     86c:	8b0a8a93          	addi	s5,s5,-1872 # 6118 <malloc+0x486>
  for(i = 0; i < N; i++){
     870:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     874:	4629                	li	a2,10
     876:	85ce                	mv	a1,s3
     878:	854a                	mv	a0,s2
     87a:	00005097          	auipc	ra,0x5
     87e:	ffe080e7          	jalr	-2(ra) # 5878 <write>
     882:	47a9                	li	a5,10
     884:	0af51563          	bne	a0,a5,92e <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     888:	4629                	li	a2,10
     88a:	85d6                	mv	a1,s5
     88c:	854a                	mv	a0,s2
     88e:	00005097          	auipc	ra,0x5
     892:	fea080e7          	jalr	-22(ra) # 5878 <write>
     896:	47a9                	li	a5,10
     898:	0af51a63          	bne	a0,a5,94c <writetest+0x11e>
  for(i = 0; i < N; i++){
     89c:	2485                	addiw	s1,s1,1
     89e:	fd449be3          	bne	s1,s4,874 <writetest+0x46>
  close(fd);
     8a2:	854a                	mv	a0,s2
     8a4:	00005097          	auipc	ra,0x5
     8a8:	fdc080e7          	jalr	-36(ra) # 5880 <close>
  fd = open("small", O_RDONLY);
     8ac:	4581                	li	a1,0
     8ae:	00006517          	auipc	a0,0x6
     8b2:	80a50513          	addi	a0,a0,-2038 # 60b8 <malloc+0x426>
     8b6:	00005097          	auipc	ra,0x5
     8ba:	fe2080e7          	jalr	-30(ra) # 5898 <open>
     8be:	84aa                	mv	s1,a0
  if(fd < 0){
     8c0:	0a054563          	bltz	a0,96a <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     8c4:	7d000613          	li	a2,2000
     8c8:	0000b597          	auipc	a1,0xb
     8cc:	54858593          	addi	a1,a1,1352 # be10 <buf>
     8d0:	00005097          	auipc	ra,0x5
     8d4:	fa0080e7          	jalr	-96(ra) # 5870 <read>
  if(i != N*SZ*2){
     8d8:	7d000793          	li	a5,2000
     8dc:	0af51563          	bne	a0,a5,986 <writetest+0x158>
  close(fd);
     8e0:	8526                	mv	a0,s1
     8e2:	00005097          	auipc	ra,0x5
     8e6:	f9e080e7          	jalr	-98(ra) # 5880 <close>
  if(unlink("small") < 0){
     8ea:	00005517          	auipc	a0,0x5
     8ee:	7ce50513          	addi	a0,a0,1998 # 60b8 <malloc+0x426>
     8f2:	00005097          	auipc	ra,0x5
     8f6:	fb6080e7          	jalr	-74(ra) # 58a8 <unlink>
     8fa:	0a054463          	bltz	a0,9a2 <writetest+0x174>
}
     8fe:	70e2                	ld	ra,56(sp)
     900:	7442                	ld	s0,48(sp)
     902:	74a2                	ld	s1,40(sp)
     904:	7902                	ld	s2,32(sp)
     906:	69e2                	ld	s3,24(sp)
     908:	6a42                	ld	s4,16(sp)
     90a:	6aa2                	ld	s5,8(sp)
     90c:	6b02                	ld	s6,0(sp)
     90e:	6121                	addi	sp,sp,64
     910:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     912:	85da                	mv	a1,s6
     914:	00005517          	auipc	a0,0x5
     918:	7ac50513          	addi	a0,a0,1964 # 60c0 <malloc+0x42e>
     91c:	00005097          	auipc	ra,0x5
     920:	2be080e7          	jalr	702(ra) # 5bda <printf>
    exit(1);
     924:	4505                	li	a0,1
     926:	00005097          	auipc	ra,0x5
     92a:	f32080e7          	jalr	-206(ra) # 5858 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     92e:	8626                	mv	a2,s1
     930:	85da                	mv	a1,s6
     932:	00005517          	auipc	a0,0x5
     936:	7be50513          	addi	a0,a0,1982 # 60f0 <malloc+0x45e>
     93a:	00005097          	auipc	ra,0x5
     93e:	2a0080e7          	jalr	672(ra) # 5bda <printf>
      exit(1);
     942:	4505                	li	a0,1
     944:	00005097          	auipc	ra,0x5
     948:	f14080e7          	jalr	-236(ra) # 5858 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     94c:	8626                	mv	a2,s1
     94e:	85da                	mv	a1,s6
     950:	00005517          	auipc	a0,0x5
     954:	7d850513          	addi	a0,a0,2008 # 6128 <malloc+0x496>
     958:	00005097          	auipc	ra,0x5
     95c:	282080e7          	jalr	642(ra) # 5bda <printf>
      exit(1);
     960:	4505                	li	a0,1
     962:	00005097          	auipc	ra,0x5
     966:	ef6080e7          	jalr	-266(ra) # 5858 <exit>
    printf("%s: error: open small failed!\n", s);
     96a:	85da                	mv	a1,s6
     96c:	00005517          	auipc	a0,0x5
     970:	7e450513          	addi	a0,a0,2020 # 6150 <malloc+0x4be>
     974:	00005097          	auipc	ra,0x5
     978:	266080e7          	jalr	614(ra) # 5bda <printf>
    exit(1);
     97c:	4505                	li	a0,1
     97e:	00005097          	auipc	ra,0x5
     982:	eda080e7          	jalr	-294(ra) # 5858 <exit>
    printf("%s: read failed\n", s);
     986:	85da                	mv	a1,s6
     988:	00005517          	auipc	a0,0x5
     98c:	7e850513          	addi	a0,a0,2024 # 6170 <malloc+0x4de>
     990:	00005097          	auipc	ra,0x5
     994:	24a080e7          	jalr	586(ra) # 5bda <printf>
    exit(1);
     998:	4505                	li	a0,1
     99a:	00005097          	auipc	ra,0x5
     99e:	ebe080e7          	jalr	-322(ra) # 5858 <exit>
    printf("%s: unlink small failed\n", s);
     9a2:	85da                	mv	a1,s6
     9a4:	00005517          	auipc	a0,0x5
     9a8:	7e450513          	addi	a0,a0,2020 # 6188 <malloc+0x4f6>
     9ac:	00005097          	auipc	ra,0x5
     9b0:	22e080e7          	jalr	558(ra) # 5bda <printf>
    exit(1);
     9b4:	4505                	li	a0,1
     9b6:	00005097          	auipc	ra,0x5
     9ba:	ea2080e7          	jalr	-350(ra) # 5858 <exit>

00000000000009be <writebig>:
{
     9be:	7139                	addi	sp,sp,-64
     9c0:	fc06                	sd	ra,56(sp)
     9c2:	f822                	sd	s0,48(sp)
     9c4:	f426                	sd	s1,40(sp)
     9c6:	f04a                	sd	s2,32(sp)
     9c8:	ec4e                	sd	s3,24(sp)
     9ca:	e852                	sd	s4,16(sp)
     9cc:	e456                	sd	s5,8(sp)
     9ce:	0080                	addi	s0,sp,64
     9d0:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9d2:	20200593          	li	a1,514
     9d6:	00005517          	auipc	a0,0x5
     9da:	7d250513          	addi	a0,a0,2002 # 61a8 <malloc+0x516>
     9de:	00005097          	auipc	ra,0x5
     9e2:	eba080e7          	jalr	-326(ra) # 5898 <open>
     9e6:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9e8:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9ea:	0000b917          	auipc	s2,0xb
     9ee:	42690913          	addi	s2,s2,1062 # be10 <buf>
  for(i = 0; i < MAXFILE; i++){
     9f2:	10c00a13          	li	s4,268
  if(fd < 0){
     9f6:	06054c63          	bltz	a0,a6e <writebig+0xb0>
    ((int*)buf)[0] = i;
     9fa:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9fe:	40000613          	li	a2,1024
     a02:	85ca                	mv	a1,s2
     a04:	854e                	mv	a0,s3
     a06:	00005097          	auipc	ra,0x5
     a0a:	e72080e7          	jalr	-398(ra) # 5878 <write>
     a0e:	40000793          	li	a5,1024
     a12:	06f51c63          	bne	a0,a5,a8a <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a16:	2485                	addiw	s1,s1,1
     a18:	ff4491e3          	bne	s1,s4,9fa <writebig+0x3c>
  close(fd);
     a1c:	854e                	mv	a0,s3
     a1e:	00005097          	auipc	ra,0x5
     a22:	e62080e7          	jalr	-414(ra) # 5880 <close>
  fd = open("big", O_RDONLY);
     a26:	4581                	li	a1,0
     a28:	00005517          	auipc	a0,0x5
     a2c:	78050513          	addi	a0,a0,1920 # 61a8 <malloc+0x516>
     a30:	00005097          	auipc	ra,0x5
     a34:	e68080e7          	jalr	-408(ra) # 5898 <open>
     a38:	89aa                	mv	s3,a0
  n = 0;
     a3a:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a3c:	0000b917          	auipc	s2,0xb
     a40:	3d490913          	addi	s2,s2,980 # be10 <buf>
  if(fd < 0){
     a44:	06054263          	bltz	a0,aa8 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     a48:	40000613          	li	a2,1024
     a4c:	85ca                	mv	a1,s2
     a4e:	854e                	mv	a0,s3
     a50:	00005097          	auipc	ra,0x5
     a54:	e20080e7          	jalr	-480(ra) # 5870 <read>
    if(i == 0){
     a58:	c535                	beqz	a0,ac4 <writebig+0x106>
    } else if(i != BSIZE){
     a5a:	40000793          	li	a5,1024
     a5e:	0af51f63          	bne	a0,a5,b1c <writebig+0x15e>
    if(((int*)buf)[0] != n){
     a62:	00092683          	lw	a3,0(s2)
     a66:	0c969a63          	bne	a3,s1,b3a <writebig+0x17c>
    n++;
     a6a:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a6c:	bff1                	j	a48 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a6e:	85d6                	mv	a1,s5
     a70:	00005517          	auipc	a0,0x5
     a74:	74050513          	addi	a0,a0,1856 # 61b0 <malloc+0x51e>
     a78:	00005097          	auipc	ra,0x5
     a7c:	162080e7          	jalr	354(ra) # 5bda <printf>
    exit(1);
     a80:	4505                	li	a0,1
     a82:	00005097          	auipc	ra,0x5
     a86:	dd6080e7          	jalr	-554(ra) # 5858 <exit>
      printf("%s: error: write big file failed\n", s, i);
     a8a:	8626                	mv	a2,s1
     a8c:	85d6                	mv	a1,s5
     a8e:	00005517          	auipc	a0,0x5
     a92:	74250513          	addi	a0,a0,1858 # 61d0 <malloc+0x53e>
     a96:	00005097          	auipc	ra,0x5
     a9a:	144080e7          	jalr	324(ra) # 5bda <printf>
      exit(1);
     a9e:	4505                	li	a0,1
     aa0:	00005097          	auipc	ra,0x5
     aa4:	db8080e7          	jalr	-584(ra) # 5858 <exit>
    printf("%s: error: open big failed!\n", s);
     aa8:	85d6                	mv	a1,s5
     aaa:	00005517          	auipc	a0,0x5
     aae:	74e50513          	addi	a0,a0,1870 # 61f8 <malloc+0x566>
     ab2:	00005097          	auipc	ra,0x5
     ab6:	128080e7          	jalr	296(ra) # 5bda <printf>
    exit(1);
     aba:	4505                	li	a0,1
     abc:	00005097          	auipc	ra,0x5
     ac0:	d9c080e7          	jalr	-612(ra) # 5858 <exit>
      if(n == MAXFILE - 1){
     ac4:	10b00793          	li	a5,267
     ac8:	02f48a63          	beq	s1,a5,afc <writebig+0x13e>
  close(fd);
     acc:	854e                	mv	a0,s3
     ace:	00005097          	auipc	ra,0x5
     ad2:	db2080e7          	jalr	-590(ra) # 5880 <close>
  if(unlink("big") < 0){
     ad6:	00005517          	auipc	a0,0x5
     ada:	6d250513          	addi	a0,a0,1746 # 61a8 <malloc+0x516>
     ade:	00005097          	auipc	ra,0x5
     ae2:	dca080e7          	jalr	-566(ra) # 58a8 <unlink>
     ae6:	06054963          	bltz	a0,b58 <writebig+0x19a>
}
     aea:	70e2                	ld	ra,56(sp)
     aec:	7442                	ld	s0,48(sp)
     aee:	74a2                	ld	s1,40(sp)
     af0:	7902                	ld	s2,32(sp)
     af2:	69e2                	ld	s3,24(sp)
     af4:	6a42                	ld	s4,16(sp)
     af6:	6aa2                	ld	s5,8(sp)
     af8:	6121                	addi	sp,sp,64
     afa:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     afc:	10b00613          	li	a2,267
     b00:	85d6                	mv	a1,s5
     b02:	00005517          	auipc	a0,0x5
     b06:	71650513          	addi	a0,a0,1814 # 6218 <malloc+0x586>
     b0a:	00005097          	auipc	ra,0x5
     b0e:	0d0080e7          	jalr	208(ra) # 5bda <printf>
        exit(1);
     b12:	4505                	li	a0,1
     b14:	00005097          	auipc	ra,0x5
     b18:	d44080e7          	jalr	-700(ra) # 5858 <exit>
      printf("%s: read failed %d\n", s, i);
     b1c:	862a                	mv	a2,a0
     b1e:	85d6                	mv	a1,s5
     b20:	00005517          	auipc	a0,0x5
     b24:	72050513          	addi	a0,a0,1824 # 6240 <malloc+0x5ae>
     b28:	00005097          	auipc	ra,0x5
     b2c:	0b2080e7          	jalr	178(ra) # 5bda <printf>
      exit(1);
     b30:	4505                	li	a0,1
     b32:	00005097          	auipc	ra,0x5
     b36:	d26080e7          	jalr	-730(ra) # 5858 <exit>
      printf("%s: read content of block %d is %d\n", s,
     b3a:	8626                	mv	a2,s1
     b3c:	85d6                	mv	a1,s5
     b3e:	00005517          	auipc	a0,0x5
     b42:	71a50513          	addi	a0,a0,1818 # 6258 <malloc+0x5c6>
     b46:	00005097          	auipc	ra,0x5
     b4a:	094080e7          	jalr	148(ra) # 5bda <printf>
      exit(1);
     b4e:	4505                	li	a0,1
     b50:	00005097          	auipc	ra,0x5
     b54:	d08080e7          	jalr	-760(ra) # 5858 <exit>
    printf("%s: unlink big failed\n", s);
     b58:	85d6                	mv	a1,s5
     b5a:	00005517          	auipc	a0,0x5
     b5e:	72650513          	addi	a0,a0,1830 # 6280 <malloc+0x5ee>
     b62:	00005097          	auipc	ra,0x5
     b66:	078080e7          	jalr	120(ra) # 5bda <printf>
    exit(1);
     b6a:	4505                	li	a0,1
     b6c:	00005097          	auipc	ra,0x5
     b70:	cec080e7          	jalr	-788(ra) # 5858 <exit>

0000000000000b74 <unlinkread>:
{
     b74:	7179                	addi	sp,sp,-48
     b76:	f406                	sd	ra,40(sp)
     b78:	f022                	sd	s0,32(sp)
     b7a:	ec26                	sd	s1,24(sp)
     b7c:	e84a                	sd	s2,16(sp)
     b7e:	e44e                	sd	s3,8(sp)
     b80:	1800                	addi	s0,sp,48
     b82:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b84:	20200593          	li	a1,514
     b88:	00005517          	auipc	a0,0x5
     b8c:	71050513          	addi	a0,a0,1808 # 6298 <malloc+0x606>
     b90:	00005097          	auipc	ra,0x5
     b94:	d08080e7          	jalr	-760(ra) # 5898 <open>
  if(fd < 0){
     b98:	0e054563          	bltz	a0,c82 <unlinkread+0x10e>
     b9c:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b9e:	4615                	li	a2,5
     ba0:	00005597          	auipc	a1,0x5
     ba4:	72858593          	addi	a1,a1,1832 # 62c8 <malloc+0x636>
     ba8:	00005097          	auipc	ra,0x5
     bac:	cd0080e7          	jalr	-816(ra) # 5878 <write>
  close(fd);
     bb0:	8526                	mv	a0,s1
     bb2:	00005097          	auipc	ra,0x5
     bb6:	cce080e7          	jalr	-818(ra) # 5880 <close>
  fd = open("unlinkread", O_RDWR);
     bba:	4589                	li	a1,2
     bbc:	00005517          	auipc	a0,0x5
     bc0:	6dc50513          	addi	a0,a0,1756 # 6298 <malloc+0x606>
     bc4:	00005097          	auipc	ra,0x5
     bc8:	cd4080e7          	jalr	-812(ra) # 5898 <open>
     bcc:	84aa                	mv	s1,a0
  if(fd < 0){
     bce:	0c054863          	bltz	a0,c9e <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bd2:	00005517          	auipc	a0,0x5
     bd6:	6c650513          	addi	a0,a0,1734 # 6298 <malloc+0x606>
     bda:	00005097          	auipc	ra,0x5
     bde:	cce080e7          	jalr	-818(ra) # 58a8 <unlink>
     be2:	ed61                	bnez	a0,cba <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     be4:	20200593          	li	a1,514
     be8:	00005517          	auipc	a0,0x5
     bec:	6b050513          	addi	a0,a0,1712 # 6298 <malloc+0x606>
     bf0:	00005097          	auipc	ra,0x5
     bf4:	ca8080e7          	jalr	-856(ra) # 5898 <open>
     bf8:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     bfa:	460d                	li	a2,3
     bfc:	00005597          	auipc	a1,0x5
     c00:	71458593          	addi	a1,a1,1812 # 6310 <malloc+0x67e>
     c04:	00005097          	auipc	ra,0x5
     c08:	c74080e7          	jalr	-908(ra) # 5878 <write>
  close(fd1);
     c0c:	854a                	mv	a0,s2
     c0e:	00005097          	auipc	ra,0x5
     c12:	c72080e7          	jalr	-910(ra) # 5880 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c16:	660d                	lui	a2,0x3
     c18:	0000b597          	auipc	a1,0xb
     c1c:	1f858593          	addi	a1,a1,504 # be10 <buf>
     c20:	8526                	mv	a0,s1
     c22:	00005097          	auipc	ra,0x5
     c26:	c4e080e7          	jalr	-946(ra) # 5870 <read>
     c2a:	4795                	li	a5,5
     c2c:	0af51563          	bne	a0,a5,cd6 <unlinkread+0x162>
  if(buf[0] != 'h'){
     c30:	0000b717          	auipc	a4,0xb
     c34:	1e074703          	lbu	a4,480(a4) # be10 <buf>
     c38:	06800793          	li	a5,104
     c3c:	0af71b63          	bne	a4,a5,cf2 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c40:	4629                	li	a2,10
     c42:	0000b597          	auipc	a1,0xb
     c46:	1ce58593          	addi	a1,a1,462 # be10 <buf>
     c4a:	8526                	mv	a0,s1
     c4c:	00005097          	auipc	ra,0x5
     c50:	c2c080e7          	jalr	-980(ra) # 5878 <write>
     c54:	47a9                	li	a5,10
     c56:	0af51c63          	bne	a0,a5,d0e <unlinkread+0x19a>
  close(fd);
     c5a:	8526                	mv	a0,s1
     c5c:	00005097          	auipc	ra,0x5
     c60:	c24080e7          	jalr	-988(ra) # 5880 <close>
  unlink("unlinkread");
     c64:	00005517          	auipc	a0,0x5
     c68:	63450513          	addi	a0,a0,1588 # 6298 <malloc+0x606>
     c6c:	00005097          	auipc	ra,0x5
     c70:	c3c080e7          	jalr	-964(ra) # 58a8 <unlink>
}
     c74:	70a2                	ld	ra,40(sp)
     c76:	7402                	ld	s0,32(sp)
     c78:	64e2                	ld	s1,24(sp)
     c7a:	6942                	ld	s2,16(sp)
     c7c:	69a2                	ld	s3,8(sp)
     c7e:	6145                	addi	sp,sp,48
     c80:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c82:	85ce                	mv	a1,s3
     c84:	00005517          	auipc	a0,0x5
     c88:	62450513          	addi	a0,a0,1572 # 62a8 <malloc+0x616>
     c8c:	00005097          	auipc	ra,0x5
     c90:	f4e080e7          	jalr	-178(ra) # 5bda <printf>
    exit(1);
     c94:	4505                	li	a0,1
     c96:	00005097          	auipc	ra,0x5
     c9a:	bc2080e7          	jalr	-1086(ra) # 5858 <exit>
    printf("%s: open unlinkread failed\n", s);
     c9e:	85ce                	mv	a1,s3
     ca0:	00005517          	auipc	a0,0x5
     ca4:	63050513          	addi	a0,a0,1584 # 62d0 <malloc+0x63e>
     ca8:	00005097          	auipc	ra,0x5
     cac:	f32080e7          	jalr	-206(ra) # 5bda <printf>
    exit(1);
     cb0:	4505                	li	a0,1
     cb2:	00005097          	auipc	ra,0x5
     cb6:	ba6080e7          	jalr	-1114(ra) # 5858 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     cba:	85ce                	mv	a1,s3
     cbc:	00005517          	auipc	a0,0x5
     cc0:	63450513          	addi	a0,a0,1588 # 62f0 <malloc+0x65e>
     cc4:	00005097          	auipc	ra,0x5
     cc8:	f16080e7          	jalr	-234(ra) # 5bda <printf>
    exit(1);
     ccc:	4505                	li	a0,1
     cce:	00005097          	auipc	ra,0x5
     cd2:	b8a080e7          	jalr	-1142(ra) # 5858 <exit>
    printf("%s: unlinkread read failed", s);
     cd6:	85ce                	mv	a1,s3
     cd8:	00005517          	auipc	a0,0x5
     cdc:	64050513          	addi	a0,a0,1600 # 6318 <malloc+0x686>
     ce0:	00005097          	auipc	ra,0x5
     ce4:	efa080e7          	jalr	-262(ra) # 5bda <printf>
    exit(1);
     ce8:	4505                	li	a0,1
     cea:	00005097          	auipc	ra,0x5
     cee:	b6e080e7          	jalr	-1170(ra) # 5858 <exit>
    printf("%s: unlinkread wrong data\n", s);
     cf2:	85ce                	mv	a1,s3
     cf4:	00005517          	auipc	a0,0x5
     cf8:	64450513          	addi	a0,a0,1604 # 6338 <malloc+0x6a6>
     cfc:	00005097          	auipc	ra,0x5
     d00:	ede080e7          	jalr	-290(ra) # 5bda <printf>
    exit(1);
     d04:	4505                	li	a0,1
     d06:	00005097          	auipc	ra,0x5
     d0a:	b52080e7          	jalr	-1198(ra) # 5858 <exit>
    printf("%s: unlinkread write failed\n", s);
     d0e:	85ce                	mv	a1,s3
     d10:	00005517          	auipc	a0,0x5
     d14:	64850513          	addi	a0,a0,1608 # 6358 <malloc+0x6c6>
     d18:	00005097          	auipc	ra,0x5
     d1c:	ec2080e7          	jalr	-318(ra) # 5bda <printf>
    exit(1);
     d20:	4505                	li	a0,1
     d22:	00005097          	auipc	ra,0x5
     d26:	b36080e7          	jalr	-1226(ra) # 5858 <exit>

0000000000000d2a <linktest>:
{
     d2a:	1101                	addi	sp,sp,-32
     d2c:	ec06                	sd	ra,24(sp)
     d2e:	e822                	sd	s0,16(sp)
     d30:	e426                	sd	s1,8(sp)
     d32:	e04a                	sd	s2,0(sp)
     d34:	1000                	addi	s0,sp,32
     d36:	892a                	mv	s2,a0
  unlink("lf1");
     d38:	00005517          	auipc	a0,0x5
     d3c:	64050513          	addi	a0,a0,1600 # 6378 <malloc+0x6e6>
     d40:	00005097          	auipc	ra,0x5
     d44:	b68080e7          	jalr	-1176(ra) # 58a8 <unlink>
  unlink("lf2");
     d48:	00005517          	auipc	a0,0x5
     d4c:	63850513          	addi	a0,a0,1592 # 6380 <malloc+0x6ee>
     d50:	00005097          	auipc	ra,0x5
     d54:	b58080e7          	jalr	-1192(ra) # 58a8 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d58:	20200593          	li	a1,514
     d5c:	00005517          	auipc	a0,0x5
     d60:	61c50513          	addi	a0,a0,1564 # 6378 <malloc+0x6e6>
     d64:	00005097          	auipc	ra,0x5
     d68:	b34080e7          	jalr	-1228(ra) # 5898 <open>
  if(fd < 0){
     d6c:	10054763          	bltz	a0,e7a <linktest+0x150>
     d70:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d72:	4615                	li	a2,5
     d74:	00005597          	auipc	a1,0x5
     d78:	55458593          	addi	a1,a1,1364 # 62c8 <malloc+0x636>
     d7c:	00005097          	auipc	ra,0x5
     d80:	afc080e7          	jalr	-1284(ra) # 5878 <write>
     d84:	4795                	li	a5,5
     d86:	10f51863          	bne	a0,a5,e96 <linktest+0x16c>
  close(fd);
     d8a:	8526                	mv	a0,s1
     d8c:	00005097          	auipc	ra,0x5
     d90:	af4080e7          	jalr	-1292(ra) # 5880 <close>
  if(link("lf1", "lf2") < 0){
     d94:	00005597          	auipc	a1,0x5
     d98:	5ec58593          	addi	a1,a1,1516 # 6380 <malloc+0x6ee>
     d9c:	00005517          	auipc	a0,0x5
     da0:	5dc50513          	addi	a0,a0,1500 # 6378 <malloc+0x6e6>
     da4:	00005097          	auipc	ra,0x5
     da8:	b14080e7          	jalr	-1260(ra) # 58b8 <link>
     dac:	10054363          	bltz	a0,eb2 <linktest+0x188>
  unlink("lf1");
     db0:	00005517          	auipc	a0,0x5
     db4:	5c850513          	addi	a0,a0,1480 # 6378 <malloc+0x6e6>
     db8:	00005097          	auipc	ra,0x5
     dbc:	af0080e7          	jalr	-1296(ra) # 58a8 <unlink>
  if(open("lf1", 0) >= 0){
     dc0:	4581                	li	a1,0
     dc2:	00005517          	auipc	a0,0x5
     dc6:	5b650513          	addi	a0,a0,1462 # 6378 <malloc+0x6e6>
     dca:	00005097          	auipc	ra,0x5
     dce:	ace080e7          	jalr	-1330(ra) # 5898 <open>
     dd2:	0e055e63          	bgez	a0,ece <linktest+0x1a4>
  fd = open("lf2", 0);
     dd6:	4581                	li	a1,0
     dd8:	00005517          	auipc	a0,0x5
     ddc:	5a850513          	addi	a0,a0,1448 # 6380 <malloc+0x6ee>
     de0:	00005097          	auipc	ra,0x5
     de4:	ab8080e7          	jalr	-1352(ra) # 5898 <open>
     de8:	84aa                	mv	s1,a0
  if(fd < 0){
     dea:	10054063          	bltz	a0,eea <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     dee:	660d                	lui	a2,0x3
     df0:	0000b597          	auipc	a1,0xb
     df4:	02058593          	addi	a1,a1,32 # be10 <buf>
     df8:	00005097          	auipc	ra,0x5
     dfc:	a78080e7          	jalr	-1416(ra) # 5870 <read>
     e00:	4795                	li	a5,5
     e02:	10f51263          	bne	a0,a5,f06 <linktest+0x1dc>
  close(fd);
     e06:	8526                	mv	a0,s1
     e08:	00005097          	auipc	ra,0x5
     e0c:	a78080e7          	jalr	-1416(ra) # 5880 <close>
  if(link("lf2", "lf2") >= 0){
     e10:	00005597          	auipc	a1,0x5
     e14:	57058593          	addi	a1,a1,1392 # 6380 <malloc+0x6ee>
     e18:	852e                	mv	a0,a1
     e1a:	00005097          	auipc	ra,0x5
     e1e:	a9e080e7          	jalr	-1378(ra) # 58b8 <link>
     e22:	10055063          	bgez	a0,f22 <linktest+0x1f8>
  unlink("lf2");
     e26:	00005517          	auipc	a0,0x5
     e2a:	55a50513          	addi	a0,a0,1370 # 6380 <malloc+0x6ee>
     e2e:	00005097          	auipc	ra,0x5
     e32:	a7a080e7          	jalr	-1414(ra) # 58a8 <unlink>
  if(link("lf2", "lf1") >= 0){
     e36:	00005597          	auipc	a1,0x5
     e3a:	54258593          	addi	a1,a1,1346 # 6378 <malloc+0x6e6>
     e3e:	00005517          	auipc	a0,0x5
     e42:	54250513          	addi	a0,a0,1346 # 6380 <malloc+0x6ee>
     e46:	00005097          	auipc	ra,0x5
     e4a:	a72080e7          	jalr	-1422(ra) # 58b8 <link>
     e4e:	0e055863          	bgez	a0,f3e <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e52:	00005597          	auipc	a1,0x5
     e56:	52658593          	addi	a1,a1,1318 # 6378 <malloc+0x6e6>
     e5a:	00005517          	auipc	a0,0x5
     e5e:	62e50513          	addi	a0,a0,1582 # 6488 <malloc+0x7f6>
     e62:	00005097          	auipc	ra,0x5
     e66:	a56080e7          	jalr	-1450(ra) # 58b8 <link>
     e6a:	0e055863          	bgez	a0,f5a <linktest+0x230>
}
     e6e:	60e2                	ld	ra,24(sp)
     e70:	6442                	ld	s0,16(sp)
     e72:	64a2                	ld	s1,8(sp)
     e74:	6902                	ld	s2,0(sp)
     e76:	6105                	addi	sp,sp,32
     e78:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e7a:	85ca                	mv	a1,s2
     e7c:	00005517          	auipc	a0,0x5
     e80:	50c50513          	addi	a0,a0,1292 # 6388 <malloc+0x6f6>
     e84:	00005097          	auipc	ra,0x5
     e88:	d56080e7          	jalr	-682(ra) # 5bda <printf>
    exit(1);
     e8c:	4505                	li	a0,1
     e8e:	00005097          	auipc	ra,0x5
     e92:	9ca080e7          	jalr	-1590(ra) # 5858 <exit>
    printf("%s: write lf1 failed\n", s);
     e96:	85ca                	mv	a1,s2
     e98:	00005517          	auipc	a0,0x5
     e9c:	50850513          	addi	a0,a0,1288 # 63a0 <malloc+0x70e>
     ea0:	00005097          	auipc	ra,0x5
     ea4:	d3a080e7          	jalr	-710(ra) # 5bda <printf>
    exit(1);
     ea8:	4505                	li	a0,1
     eaa:	00005097          	auipc	ra,0x5
     eae:	9ae080e7          	jalr	-1618(ra) # 5858 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     eb2:	85ca                	mv	a1,s2
     eb4:	00005517          	auipc	a0,0x5
     eb8:	50450513          	addi	a0,a0,1284 # 63b8 <malloc+0x726>
     ebc:	00005097          	auipc	ra,0x5
     ec0:	d1e080e7          	jalr	-738(ra) # 5bda <printf>
    exit(1);
     ec4:	4505                	li	a0,1
     ec6:	00005097          	auipc	ra,0x5
     eca:	992080e7          	jalr	-1646(ra) # 5858 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     ece:	85ca                	mv	a1,s2
     ed0:	00005517          	auipc	a0,0x5
     ed4:	50850513          	addi	a0,a0,1288 # 63d8 <malloc+0x746>
     ed8:	00005097          	auipc	ra,0x5
     edc:	d02080e7          	jalr	-766(ra) # 5bda <printf>
    exit(1);
     ee0:	4505                	li	a0,1
     ee2:	00005097          	auipc	ra,0x5
     ee6:	976080e7          	jalr	-1674(ra) # 5858 <exit>
    printf("%s: open lf2 failed\n", s);
     eea:	85ca                	mv	a1,s2
     eec:	00005517          	auipc	a0,0x5
     ef0:	51c50513          	addi	a0,a0,1308 # 6408 <malloc+0x776>
     ef4:	00005097          	auipc	ra,0x5
     ef8:	ce6080e7          	jalr	-794(ra) # 5bda <printf>
    exit(1);
     efc:	4505                	li	a0,1
     efe:	00005097          	auipc	ra,0x5
     f02:	95a080e7          	jalr	-1702(ra) # 5858 <exit>
    printf("%s: read lf2 failed\n", s);
     f06:	85ca                	mv	a1,s2
     f08:	00005517          	auipc	a0,0x5
     f0c:	51850513          	addi	a0,a0,1304 # 6420 <malloc+0x78e>
     f10:	00005097          	auipc	ra,0x5
     f14:	cca080e7          	jalr	-822(ra) # 5bda <printf>
    exit(1);
     f18:	4505                	li	a0,1
     f1a:	00005097          	auipc	ra,0x5
     f1e:	93e080e7          	jalr	-1730(ra) # 5858 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f22:	85ca                	mv	a1,s2
     f24:	00005517          	auipc	a0,0x5
     f28:	51450513          	addi	a0,a0,1300 # 6438 <malloc+0x7a6>
     f2c:	00005097          	auipc	ra,0x5
     f30:	cae080e7          	jalr	-850(ra) # 5bda <printf>
    exit(1);
     f34:	4505                	li	a0,1
     f36:	00005097          	auipc	ra,0x5
     f3a:	922080e7          	jalr	-1758(ra) # 5858 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
     f3e:	85ca                	mv	a1,s2
     f40:	00005517          	auipc	a0,0x5
     f44:	52050513          	addi	a0,a0,1312 # 6460 <malloc+0x7ce>
     f48:	00005097          	auipc	ra,0x5
     f4c:	c92080e7          	jalr	-878(ra) # 5bda <printf>
    exit(1);
     f50:	4505                	li	a0,1
     f52:	00005097          	auipc	ra,0x5
     f56:	906080e7          	jalr	-1786(ra) # 5858 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f5a:	85ca                	mv	a1,s2
     f5c:	00005517          	auipc	a0,0x5
     f60:	53450513          	addi	a0,a0,1332 # 6490 <malloc+0x7fe>
     f64:	00005097          	auipc	ra,0x5
     f68:	c76080e7          	jalr	-906(ra) # 5bda <printf>
    exit(1);
     f6c:	4505                	li	a0,1
     f6e:	00005097          	auipc	ra,0x5
     f72:	8ea080e7          	jalr	-1814(ra) # 5858 <exit>

0000000000000f76 <bigdir>:
{
     f76:	715d                	addi	sp,sp,-80
     f78:	e486                	sd	ra,72(sp)
     f7a:	e0a2                	sd	s0,64(sp)
     f7c:	fc26                	sd	s1,56(sp)
     f7e:	f84a                	sd	s2,48(sp)
     f80:	f44e                	sd	s3,40(sp)
     f82:	f052                	sd	s4,32(sp)
     f84:	ec56                	sd	s5,24(sp)
     f86:	e85a                	sd	s6,16(sp)
     f88:	0880                	addi	s0,sp,80
     f8a:	89aa                	mv	s3,a0
  unlink("bd");
     f8c:	00005517          	auipc	a0,0x5
     f90:	52450513          	addi	a0,a0,1316 # 64b0 <malloc+0x81e>
     f94:	00005097          	auipc	ra,0x5
     f98:	914080e7          	jalr	-1772(ra) # 58a8 <unlink>
  fd = open("bd", O_CREATE);
     f9c:	20000593          	li	a1,512
     fa0:	00005517          	auipc	a0,0x5
     fa4:	51050513          	addi	a0,a0,1296 # 64b0 <malloc+0x81e>
     fa8:	00005097          	auipc	ra,0x5
     fac:	8f0080e7          	jalr	-1808(ra) # 5898 <open>
  if(fd < 0){
     fb0:	0c054963          	bltz	a0,1082 <bigdir+0x10c>
  close(fd);
     fb4:	00005097          	auipc	ra,0x5
     fb8:	8cc080e7          	jalr	-1844(ra) # 5880 <close>
  for(i = 0; i < N; i++){
     fbc:	4901                	li	s2,0
    name[0] = 'x';
     fbe:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fc2:	00005a17          	auipc	s4,0x5
     fc6:	4eea0a13          	addi	s4,s4,1262 # 64b0 <malloc+0x81e>
  for(i = 0; i < N; i++){
     fca:	1f400b13          	li	s6,500
    name[0] = 'x';
     fce:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fd2:	41f9571b          	sraiw	a4,s2,0x1f
     fd6:	01a7571b          	srliw	a4,a4,0x1a
     fda:	012707bb          	addw	a5,a4,s2
     fde:	4067d69b          	sraiw	a3,a5,0x6
     fe2:	0306869b          	addiw	a3,a3,48
     fe6:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     fea:	03f7f793          	andi	a5,a5,63
     fee:	9f99                	subw	a5,a5,a4
     ff0:	0307879b          	addiw	a5,a5,48
     ff4:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     ff8:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     ffc:	fb040593          	addi	a1,s0,-80
    1000:	8552                	mv	a0,s4
    1002:	00005097          	auipc	ra,0x5
    1006:	8b6080e7          	jalr	-1866(ra) # 58b8 <link>
    100a:	84aa                	mv	s1,a0
    100c:	e949                	bnez	a0,109e <bigdir+0x128>
  for(i = 0; i < N; i++){
    100e:	2905                	addiw	s2,s2,1
    1010:	fb691fe3          	bne	s2,s6,fce <bigdir+0x58>
  unlink("bd");
    1014:	00005517          	auipc	a0,0x5
    1018:	49c50513          	addi	a0,a0,1180 # 64b0 <malloc+0x81e>
    101c:	00005097          	auipc	ra,0x5
    1020:	88c080e7          	jalr	-1908(ra) # 58a8 <unlink>
    name[0] = 'x';
    1024:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1028:	1f400a13          	li	s4,500
    name[0] = 'x';
    102c:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1030:	41f4d71b          	sraiw	a4,s1,0x1f
    1034:	01a7571b          	srliw	a4,a4,0x1a
    1038:	009707bb          	addw	a5,a4,s1
    103c:	4067d69b          	sraiw	a3,a5,0x6
    1040:	0306869b          	addiw	a3,a3,48
    1044:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1048:	03f7f793          	andi	a5,a5,63
    104c:	9f99                	subw	a5,a5,a4
    104e:	0307879b          	addiw	a5,a5,48
    1052:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1056:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    105a:	fb040513          	addi	a0,s0,-80
    105e:	00005097          	auipc	ra,0x5
    1062:	84a080e7          	jalr	-1974(ra) # 58a8 <unlink>
    1066:	ed21                	bnez	a0,10be <bigdir+0x148>
  for(i = 0; i < N; i++){
    1068:	2485                	addiw	s1,s1,1
    106a:	fd4491e3          	bne	s1,s4,102c <bigdir+0xb6>
}
    106e:	60a6                	ld	ra,72(sp)
    1070:	6406                	ld	s0,64(sp)
    1072:	74e2                	ld	s1,56(sp)
    1074:	7942                	ld	s2,48(sp)
    1076:	79a2                	ld	s3,40(sp)
    1078:	7a02                	ld	s4,32(sp)
    107a:	6ae2                	ld	s5,24(sp)
    107c:	6b42                	ld	s6,16(sp)
    107e:	6161                	addi	sp,sp,80
    1080:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    1082:	85ce                	mv	a1,s3
    1084:	00005517          	auipc	a0,0x5
    1088:	43450513          	addi	a0,a0,1076 # 64b8 <malloc+0x826>
    108c:	00005097          	auipc	ra,0x5
    1090:	b4e080e7          	jalr	-1202(ra) # 5bda <printf>
    exit(1);
    1094:	4505                	li	a0,1
    1096:	00004097          	auipc	ra,0x4
    109a:	7c2080e7          	jalr	1986(ra) # 5858 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    109e:	fb040613          	addi	a2,s0,-80
    10a2:	85ce                	mv	a1,s3
    10a4:	00005517          	auipc	a0,0x5
    10a8:	43450513          	addi	a0,a0,1076 # 64d8 <malloc+0x846>
    10ac:	00005097          	auipc	ra,0x5
    10b0:	b2e080e7          	jalr	-1234(ra) # 5bda <printf>
      exit(1);
    10b4:	4505                	li	a0,1
    10b6:	00004097          	auipc	ra,0x4
    10ba:	7a2080e7          	jalr	1954(ra) # 5858 <exit>
      printf("%s: bigdir unlink failed", s);
    10be:	85ce                	mv	a1,s3
    10c0:	00005517          	auipc	a0,0x5
    10c4:	43850513          	addi	a0,a0,1080 # 64f8 <malloc+0x866>
    10c8:	00005097          	auipc	ra,0x5
    10cc:	b12080e7          	jalr	-1262(ra) # 5bda <printf>
      exit(1);
    10d0:	4505                	li	a0,1
    10d2:	00004097          	auipc	ra,0x4
    10d6:	786080e7          	jalr	1926(ra) # 5858 <exit>

00000000000010da <validatetest>:
{
    10da:	7139                	addi	sp,sp,-64
    10dc:	fc06                	sd	ra,56(sp)
    10de:	f822                	sd	s0,48(sp)
    10e0:	f426                	sd	s1,40(sp)
    10e2:	f04a                	sd	s2,32(sp)
    10e4:	ec4e                	sd	s3,24(sp)
    10e6:	e852                	sd	s4,16(sp)
    10e8:	e456                	sd	s5,8(sp)
    10ea:	e05a                	sd	s6,0(sp)
    10ec:	0080                	addi	s0,sp,64
    10ee:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10f0:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10f2:	00005997          	auipc	s3,0x5
    10f6:	42698993          	addi	s3,s3,1062 # 6518 <malloc+0x886>
    10fa:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10fc:	6a85                	lui	s5,0x1
    10fe:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    1102:	85a6                	mv	a1,s1
    1104:	854e                	mv	a0,s3
    1106:	00004097          	auipc	ra,0x4
    110a:	7b2080e7          	jalr	1970(ra) # 58b8 <link>
    110e:	01251f63          	bne	a0,s2,112c <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1112:	94d6                	add	s1,s1,s5
    1114:	ff4497e3          	bne	s1,s4,1102 <validatetest+0x28>
}
    1118:	70e2                	ld	ra,56(sp)
    111a:	7442                	ld	s0,48(sp)
    111c:	74a2                	ld	s1,40(sp)
    111e:	7902                	ld	s2,32(sp)
    1120:	69e2                	ld	s3,24(sp)
    1122:	6a42                	ld	s4,16(sp)
    1124:	6aa2                	ld	s5,8(sp)
    1126:	6b02                	ld	s6,0(sp)
    1128:	6121                	addi	sp,sp,64
    112a:	8082                	ret
      printf("%s: link should not succeed\n", s);
    112c:	85da                	mv	a1,s6
    112e:	00005517          	auipc	a0,0x5
    1132:	3fa50513          	addi	a0,a0,1018 # 6528 <malloc+0x896>
    1136:	00005097          	auipc	ra,0x5
    113a:	aa4080e7          	jalr	-1372(ra) # 5bda <printf>
      exit(1);
    113e:	4505                	li	a0,1
    1140:	00004097          	auipc	ra,0x4
    1144:	718080e7          	jalr	1816(ra) # 5858 <exit>

0000000000001148 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    1148:	7179                	addi	sp,sp,-48
    114a:	f406                	sd	ra,40(sp)
    114c:	f022                	sd	s0,32(sp)
    114e:	ec26                	sd	s1,24(sp)
    1150:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    1152:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1156:	00007497          	auipc	s1,0x7
    115a:	4924b483          	ld	s1,1170(s1) # 85e8 <__SDATA_BEGIN__>
    115e:	fd840593          	addi	a1,s0,-40
    1162:	8526                	mv	a0,s1
    1164:	00004097          	auipc	ra,0x4
    1168:	72c080e7          	jalr	1836(ra) # 5890 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    116c:	8526                	mv	a0,s1
    116e:	00004097          	auipc	ra,0x4
    1172:	6fa080e7          	jalr	1786(ra) # 5868 <pipe>

  exit(0);
    1176:	4501                	li	a0,0
    1178:	00004097          	auipc	ra,0x4
    117c:	6e0080e7          	jalr	1760(ra) # 5858 <exit>

0000000000001180 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1180:	7139                	addi	sp,sp,-64
    1182:	fc06                	sd	ra,56(sp)
    1184:	f822                	sd	s0,48(sp)
    1186:	f426                	sd	s1,40(sp)
    1188:	f04a                	sd	s2,32(sp)
    118a:	ec4e                	sd	s3,24(sp)
    118c:	0080                	addi	s0,sp,64
    118e:	64b1                	lui	s1,0xc
    1190:	35048493          	addi	s1,s1,848 # c350 <buf+0x540>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1194:	597d                	li	s2,-1
    1196:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    119a:	00005997          	auipc	s3,0x5
    119e:	c1698993          	addi	s3,s3,-1002 # 5db0 <malloc+0x11e>
    argv[0] = (char*)0xffffffff;
    11a2:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    11a6:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    11aa:	fc040593          	addi	a1,s0,-64
    11ae:	854e                	mv	a0,s3
    11b0:	00004097          	auipc	ra,0x4
    11b4:	6e0080e7          	jalr	1760(ra) # 5890 <exec>
  for(int i = 0; i < 50000; i++){
    11b8:	34fd                	addiw	s1,s1,-1
    11ba:	f4e5                	bnez	s1,11a2 <badarg+0x22>
  }
  
  exit(0);
    11bc:	4501                	li	a0,0
    11be:	00004097          	auipc	ra,0x4
    11c2:	69a080e7          	jalr	1690(ra) # 5858 <exit>

00000000000011c6 <copyinstr2>:
{
    11c6:	7155                	addi	sp,sp,-208
    11c8:	e586                	sd	ra,200(sp)
    11ca:	e1a2                	sd	s0,192(sp)
    11cc:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11ce:	f6840793          	addi	a5,s0,-152
    11d2:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11d6:	07800713          	li	a4,120
    11da:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11de:	0785                	addi	a5,a5,1
    11e0:	fed79de3          	bne	a5,a3,11da <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11e4:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11e8:	f6840513          	addi	a0,s0,-152
    11ec:	00004097          	auipc	ra,0x4
    11f0:	6bc080e7          	jalr	1724(ra) # 58a8 <unlink>
  if(ret != -1){
    11f4:	57fd                	li	a5,-1
    11f6:	0ef51063          	bne	a0,a5,12d6 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    11fa:	20100593          	li	a1,513
    11fe:	f6840513          	addi	a0,s0,-152
    1202:	00004097          	auipc	ra,0x4
    1206:	696080e7          	jalr	1686(ra) # 5898 <open>
  if(fd != -1){
    120a:	57fd                	li	a5,-1
    120c:	0ef51563          	bne	a0,a5,12f6 <copyinstr2+0x130>
  ret = link(b, b);
    1210:	f6840593          	addi	a1,s0,-152
    1214:	852e                	mv	a0,a1
    1216:	00004097          	auipc	ra,0x4
    121a:	6a2080e7          	jalr	1698(ra) # 58b8 <link>
  if(ret != -1){
    121e:	57fd                	li	a5,-1
    1220:	0ef51b63          	bne	a0,a5,1316 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1224:	00006797          	auipc	a5,0x6
    1228:	4fc78793          	addi	a5,a5,1276 # 7720 <malloc+0x1a8e>
    122c:	f4f43c23          	sd	a5,-168(s0)
    1230:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1234:	f5840593          	addi	a1,s0,-168
    1238:	f6840513          	addi	a0,s0,-152
    123c:	00004097          	auipc	ra,0x4
    1240:	654080e7          	jalr	1620(ra) # 5890 <exec>
  if(ret != -1){
    1244:	57fd                	li	a5,-1
    1246:	0ef51963          	bne	a0,a5,1338 <copyinstr2+0x172>
  int pid = fork();
    124a:	00004097          	auipc	ra,0x4
    124e:	606080e7          	jalr	1542(ra) # 5850 <fork>
  if(pid < 0){
    1252:	10054363          	bltz	a0,1358 <copyinstr2+0x192>
  if(pid == 0){
    1256:	12051463          	bnez	a0,137e <copyinstr2+0x1b8>
    125a:	00007797          	auipc	a5,0x7
    125e:	49e78793          	addi	a5,a5,1182 # 86f8 <big.0>
    1262:	00008697          	auipc	a3,0x8
    1266:	49668693          	addi	a3,a3,1174 # 96f8 <__global_pointer$+0x910>
      big[i] = 'x';
    126a:	07800713          	li	a4,120
    126e:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1272:	0785                	addi	a5,a5,1
    1274:	fed79de3          	bne	a5,a3,126e <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1278:	00008797          	auipc	a5,0x8
    127c:	48078023          	sb	zero,1152(a5) # 96f8 <__global_pointer$+0x910>
    char *args2[] = { big, big, big, 0 };
    1280:	00007797          	auipc	a5,0x7
    1284:	ee078793          	addi	a5,a5,-288 # 8160 <malloc+0x24ce>
    1288:	6390                	ld	a2,0(a5)
    128a:	6794                	ld	a3,8(a5)
    128c:	6b98                	ld	a4,16(a5)
    128e:	6f9c                	ld	a5,24(a5)
    1290:	f2c43823          	sd	a2,-208(s0)
    1294:	f2d43c23          	sd	a3,-200(s0)
    1298:	f4e43023          	sd	a4,-192(s0)
    129c:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    12a0:	f3040593          	addi	a1,s0,-208
    12a4:	00005517          	auipc	a0,0x5
    12a8:	b0c50513          	addi	a0,a0,-1268 # 5db0 <malloc+0x11e>
    12ac:	00004097          	auipc	ra,0x4
    12b0:	5e4080e7          	jalr	1508(ra) # 5890 <exec>
    if(ret != -1){
    12b4:	57fd                	li	a5,-1
    12b6:	0af50e63          	beq	a0,a5,1372 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12ba:	55fd                	li	a1,-1
    12bc:	00005517          	auipc	a0,0x5
    12c0:	31450513          	addi	a0,a0,788 # 65d0 <malloc+0x93e>
    12c4:	00005097          	auipc	ra,0x5
    12c8:	916080e7          	jalr	-1770(ra) # 5bda <printf>
      exit(1);
    12cc:	4505                	li	a0,1
    12ce:	00004097          	auipc	ra,0x4
    12d2:	58a080e7          	jalr	1418(ra) # 5858 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12d6:	862a                	mv	a2,a0
    12d8:	f6840593          	addi	a1,s0,-152
    12dc:	00005517          	auipc	a0,0x5
    12e0:	26c50513          	addi	a0,a0,620 # 6548 <malloc+0x8b6>
    12e4:	00005097          	auipc	ra,0x5
    12e8:	8f6080e7          	jalr	-1802(ra) # 5bda <printf>
    exit(1);
    12ec:	4505                	li	a0,1
    12ee:	00004097          	auipc	ra,0x4
    12f2:	56a080e7          	jalr	1386(ra) # 5858 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12f6:	862a                	mv	a2,a0
    12f8:	f6840593          	addi	a1,s0,-152
    12fc:	00005517          	auipc	a0,0x5
    1300:	26c50513          	addi	a0,a0,620 # 6568 <malloc+0x8d6>
    1304:	00005097          	auipc	ra,0x5
    1308:	8d6080e7          	jalr	-1834(ra) # 5bda <printf>
    exit(1);
    130c:	4505                	li	a0,1
    130e:	00004097          	auipc	ra,0x4
    1312:	54a080e7          	jalr	1354(ra) # 5858 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1316:	86aa                	mv	a3,a0
    1318:	f6840613          	addi	a2,s0,-152
    131c:	85b2                	mv	a1,a2
    131e:	00005517          	auipc	a0,0x5
    1322:	26a50513          	addi	a0,a0,618 # 6588 <malloc+0x8f6>
    1326:	00005097          	auipc	ra,0x5
    132a:	8b4080e7          	jalr	-1868(ra) # 5bda <printf>
    exit(1);
    132e:	4505                	li	a0,1
    1330:	00004097          	auipc	ra,0x4
    1334:	528080e7          	jalr	1320(ra) # 5858 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1338:	567d                	li	a2,-1
    133a:	f6840593          	addi	a1,s0,-152
    133e:	00005517          	auipc	a0,0x5
    1342:	27250513          	addi	a0,a0,626 # 65b0 <malloc+0x91e>
    1346:	00005097          	auipc	ra,0x5
    134a:	894080e7          	jalr	-1900(ra) # 5bda <printf>
    exit(1);
    134e:	4505                	li	a0,1
    1350:	00004097          	auipc	ra,0x4
    1354:	508080e7          	jalr	1288(ra) # 5858 <exit>
    printf("fork failed\n");
    1358:	00005517          	auipc	a0,0x5
    135c:	6f050513          	addi	a0,a0,1776 # 6a48 <malloc+0xdb6>
    1360:	00005097          	auipc	ra,0x5
    1364:	87a080e7          	jalr	-1926(ra) # 5bda <printf>
    exit(1);
    1368:	4505                	li	a0,1
    136a:	00004097          	auipc	ra,0x4
    136e:	4ee080e7          	jalr	1262(ra) # 5858 <exit>
    exit(747); // OK
    1372:	2eb00513          	li	a0,747
    1376:	00004097          	auipc	ra,0x4
    137a:	4e2080e7          	jalr	1250(ra) # 5858 <exit>
  int st = 0;
    137e:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1382:	f5440513          	addi	a0,s0,-172
    1386:	00004097          	auipc	ra,0x4
    138a:	4da080e7          	jalr	1242(ra) # 5860 <wait>
  if(st != 747){
    138e:	f5442703          	lw	a4,-172(s0)
    1392:	2eb00793          	li	a5,747
    1396:	00f71663          	bne	a4,a5,13a2 <copyinstr2+0x1dc>
}
    139a:	60ae                	ld	ra,200(sp)
    139c:	640e                	ld	s0,192(sp)
    139e:	6169                	addi	sp,sp,208
    13a0:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    13a2:	00005517          	auipc	a0,0x5
    13a6:	25650513          	addi	a0,a0,598 # 65f8 <malloc+0x966>
    13aa:	00005097          	auipc	ra,0x5
    13ae:	830080e7          	jalr	-2000(ra) # 5bda <printf>
    exit(1);
    13b2:	4505                	li	a0,1
    13b4:	00004097          	auipc	ra,0x4
    13b8:	4a4080e7          	jalr	1188(ra) # 5858 <exit>

00000000000013bc <truncate3>:
{
    13bc:	7159                	addi	sp,sp,-112
    13be:	f486                	sd	ra,104(sp)
    13c0:	f0a2                	sd	s0,96(sp)
    13c2:	eca6                	sd	s1,88(sp)
    13c4:	e8ca                	sd	s2,80(sp)
    13c6:	e4ce                	sd	s3,72(sp)
    13c8:	e0d2                	sd	s4,64(sp)
    13ca:	fc56                	sd	s5,56(sp)
    13cc:	1880                	addi	s0,sp,112
    13ce:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13d0:	60100593          	li	a1,1537
    13d4:	00005517          	auipc	a0,0x5
    13d8:	a3450513          	addi	a0,a0,-1484 # 5e08 <malloc+0x176>
    13dc:	00004097          	auipc	ra,0x4
    13e0:	4bc080e7          	jalr	1212(ra) # 5898 <open>
    13e4:	00004097          	auipc	ra,0x4
    13e8:	49c080e7          	jalr	1180(ra) # 5880 <close>
  pid = fork();
    13ec:	00004097          	auipc	ra,0x4
    13f0:	464080e7          	jalr	1124(ra) # 5850 <fork>
  if(pid < 0){
    13f4:	08054063          	bltz	a0,1474 <truncate3+0xb8>
  if(pid == 0){
    13f8:	e969                	bnez	a0,14ca <truncate3+0x10e>
    13fa:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    13fe:	00005a17          	auipc	s4,0x5
    1402:	a0aa0a13          	addi	s4,s4,-1526 # 5e08 <malloc+0x176>
      int n = write(fd, "1234567890", 10);
    1406:	00005a97          	auipc	s5,0x5
    140a:	252a8a93          	addi	s5,s5,594 # 6658 <malloc+0x9c6>
      int fd = open("truncfile", O_WRONLY);
    140e:	4585                	li	a1,1
    1410:	8552                	mv	a0,s4
    1412:	00004097          	auipc	ra,0x4
    1416:	486080e7          	jalr	1158(ra) # 5898 <open>
    141a:	84aa                	mv	s1,a0
      if(fd < 0){
    141c:	06054a63          	bltz	a0,1490 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    1420:	4629                	li	a2,10
    1422:	85d6                	mv	a1,s5
    1424:	00004097          	auipc	ra,0x4
    1428:	454080e7          	jalr	1108(ra) # 5878 <write>
      if(n != 10){
    142c:	47a9                	li	a5,10
    142e:	06f51f63          	bne	a0,a5,14ac <truncate3+0xf0>
      close(fd);
    1432:	8526                	mv	a0,s1
    1434:	00004097          	auipc	ra,0x4
    1438:	44c080e7          	jalr	1100(ra) # 5880 <close>
      fd = open("truncfile", O_RDONLY);
    143c:	4581                	li	a1,0
    143e:	8552                	mv	a0,s4
    1440:	00004097          	auipc	ra,0x4
    1444:	458080e7          	jalr	1112(ra) # 5898 <open>
    1448:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    144a:	02000613          	li	a2,32
    144e:	f9840593          	addi	a1,s0,-104
    1452:	00004097          	auipc	ra,0x4
    1456:	41e080e7          	jalr	1054(ra) # 5870 <read>
      close(fd);
    145a:	8526                	mv	a0,s1
    145c:	00004097          	auipc	ra,0x4
    1460:	424080e7          	jalr	1060(ra) # 5880 <close>
    for(int i = 0; i < 100; i++){
    1464:	39fd                	addiw	s3,s3,-1
    1466:	fa0994e3          	bnez	s3,140e <truncate3+0x52>
    exit(0);
    146a:	4501                	li	a0,0
    146c:	00004097          	auipc	ra,0x4
    1470:	3ec080e7          	jalr	1004(ra) # 5858 <exit>
    printf("%s: fork failed\n", s);
    1474:	85ca                	mv	a1,s2
    1476:	00005517          	auipc	a0,0x5
    147a:	1b250513          	addi	a0,a0,434 # 6628 <malloc+0x996>
    147e:	00004097          	auipc	ra,0x4
    1482:	75c080e7          	jalr	1884(ra) # 5bda <printf>
    exit(1);
    1486:	4505                	li	a0,1
    1488:	00004097          	auipc	ra,0x4
    148c:	3d0080e7          	jalr	976(ra) # 5858 <exit>
        printf("%s: open failed\n", s);
    1490:	85ca                	mv	a1,s2
    1492:	00005517          	auipc	a0,0x5
    1496:	1ae50513          	addi	a0,a0,430 # 6640 <malloc+0x9ae>
    149a:	00004097          	auipc	ra,0x4
    149e:	740080e7          	jalr	1856(ra) # 5bda <printf>
        exit(1);
    14a2:	4505                	li	a0,1
    14a4:	00004097          	auipc	ra,0x4
    14a8:	3b4080e7          	jalr	948(ra) # 5858 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    14ac:	862a                	mv	a2,a0
    14ae:	85ca                	mv	a1,s2
    14b0:	00005517          	auipc	a0,0x5
    14b4:	1b850513          	addi	a0,a0,440 # 6668 <malloc+0x9d6>
    14b8:	00004097          	auipc	ra,0x4
    14bc:	722080e7          	jalr	1826(ra) # 5bda <printf>
        exit(1);
    14c0:	4505                	li	a0,1
    14c2:	00004097          	auipc	ra,0x4
    14c6:	396080e7          	jalr	918(ra) # 5858 <exit>
    14ca:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14ce:	00005a17          	auipc	s4,0x5
    14d2:	93aa0a13          	addi	s4,s4,-1734 # 5e08 <malloc+0x176>
    int n = write(fd, "xxx", 3);
    14d6:	00005a97          	auipc	s5,0x5
    14da:	1b2a8a93          	addi	s5,s5,434 # 6688 <malloc+0x9f6>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14de:	60100593          	li	a1,1537
    14e2:	8552                	mv	a0,s4
    14e4:	00004097          	auipc	ra,0x4
    14e8:	3b4080e7          	jalr	948(ra) # 5898 <open>
    14ec:	84aa                	mv	s1,a0
    if(fd < 0){
    14ee:	04054763          	bltz	a0,153c <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14f2:	460d                	li	a2,3
    14f4:	85d6                	mv	a1,s5
    14f6:	00004097          	auipc	ra,0x4
    14fa:	382080e7          	jalr	898(ra) # 5878 <write>
    if(n != 3){
    14fe:	478d                	li	a5,3
    1500:	04f51c63          	bne	a0,a5,1558 <truncate3+0x19c>
    close(fd);
    1504:	8526                	mv	a0,s1
    1506:	00004097          	auipc	ra,0x4
    150a:	37a080e7          	jalr	890(ra) # 5880 <close>
  for(int i = 0; i < 150; i++){
    150e:	39fd                	addiw	s3,s3,-1
    1510:	fc0997e3          	bnez	s3,14de <truncate3+0x122>
  wait(&xstatus);
    1514:	fbc40513          	addi	a0,s0,-68
    1518:	00004097          	auipc	ra,0x4
    151c:	348080e7          	jalr	840(ra) # 5860 <wait>
  unlink("truncfile");
    1520:	00005517          	auipc	a0,0x5
    1524:	8e850513          	addi	a0,a0,-1816 # 5e08 <malloc+0x176>
    1528:	00004097          	auipc	ra,0x4
    152c:	380080e7          	jalr	896(ra) # 58a8 <unlink>
  exit(xstatus);
    1530:	fbc42503          	lw	a0,-68(s0)
    1534:	00004097          	auipc	ra,0x4
    1538:	324080e7          	jalr	804(ra) # 5858 <exit>
      printf("%s: open failed\n", s);
    153c:	85ca                	mv	a1,s2
    153e:	00005517          	auipc	a0,0x5
    1542:	10250513          	addi	a0,a0,258 # 6640 <malloc+0x9ae>
    1546:	00004097          	auipc	ra,0x4
    154a:	694080e7          	jalr	1684(ra) # 5bda <printf>
      exit(1);
    154e:	4505                	li	a0,1
    1550:	00004097          	auipc	ra,0x4
    1554:	308080e7          	jalr	776(ra) # 5858 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1558:	862a                	mv	a2,a0
    155a:	85ca                	mv	a1,s2
    155c:	00005517          	auipc	a0,0x5
    1560:	13450513          	addi	a0,a0,308 # 6690 <malloc+0x9fe>
    1564:	00004097          	auipc	ra,0x4
    1568:	676080e7          	jalr	1654(ra) # 5bda <printf>
      exit(1);
    156c:	4505                	li	a0,1
    156e:	00004097          	auipc	ra,0x4
    1572:	2ea080e7          	jalr	746(ra) # 5858 <exit>

0000000000001576 <exectest>:
{
    1576:	715d                	addi	sp,sp,-80
    1578:	e486                	sd	ra,72(sp)
    157a:	e0a2                	sd	s0,64(sp)
    157c:	fc26                	sd	s1,56(sp)
    157e:	f84a                	sd	s2,48(sp)
    1580:	0880                	addi	s0,sp,80
    1582:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1584:	00005797          	auipc	a5,0x5
    1588:	82c78793          	addi	a5,a5,-2004 # 5db0 <malloc+0x11e>
    158c:	fcf43023          	sd	a5,-64(s0)
    1590:	00005797          	auipc	a5,0x5
    1594:	12078793          	addi	a5,a5,288 # 66b0 <malloc+0xa1e>
    1598:	fcf43423          	sd	a5,-56(s0)
    159c:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    15a0:	00005517          	auipc	a0,0x5
    15a4:	11850513          	addi	a0,a0,280 # 66b8 <malloc+0xa26>
    15a8:	00004097          	auipc	ra,0x4
    15ac:	300080e7          	jalr	768(ra) # 58a8 <unlink>
  pid = fork();
    15b0:	00004097          	auipc	ra,0x4
    15b4:	2a0080e7          	jalr	672(ra) # 5850 <fork>
  if(pid < 0) {
    15b8:	04054663          	bltz	a0,1604 <exectest+0x8e>
    15bc:	84aa                	mv	s1,a0
  if(pid == 0) {
    15be:	e959                	bnez	a0,1654 <exectest+0xde>
    close(1);
    15c0:	4505                	li	a0,1
    15c2:	00004097          	auipc	ra,0x4
    15c6:	2be080e7          	jalr	702(ra) # 5880 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15ca:	20100593          	li	a1,513
    15ce:	00005517          	auipc	a0,0x5
    15d2:	0ea50513          	addi	a0,a0,234 # 66b8 <malloc+0xa26>
    15d6:	00004097          	auipc	ra,0x4
    15da:	2c2080e7          	jalr	706(ra) # 5898 <open>
    if(fd < 0) {
    15de:	04054163          	bltz	a0,1620 <exectest+0xaa>
    if(fd != 1) {
    15e2:	4785                	li	a5,1
    15e4:	04f50c63          	beq	a0,a5,163c <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15e8:	85ca                	mv	a1,s2
    15ea:	00005517          	auipc	a0,0x5
    15ee:	0ee50513          	addi	a0,a0,238 # 66d8 <malloc+0xa46>
    15f2:	00004097          	auipc	ra,0x4
    15f6:	5e8080e7          	jalr	1512(ra) # 5bda <printf>
      exit(1);
    15fa:	4505                	li	a0,1
    15fc:	00004097          	auipc	ra,0x4
    1600:	25c080e7          	jalr	604(ra) # 5858 <exit>
     printf("%s: fork failed\n", s);
    1604:	85ca                	mv	a1,s2
    1606:	00005517          	auipc	a0,0x5
    160a:	02250513          	addi	a0,a0,34 # 6628 <malloc+0x996>
    160e:	00004097          	auipc	ra,0x4
    1612:	5cc080e7          	jalr	1484(ra) # 5bda <printf>
     exit(1);
    1616:	4505                	li	a0,1
    1618:	00004097          	auipc	ra,0x4
    161c:	240080e7          	jalr	576(ra) # 5858 <exit>
      printf("%s: create failed\n", s);
    1620:	85ca                	mv	a1,s2
    1622:	00005517          	auipc	a0,0x5
    1626:	09e50513          	addi	a0,a0,158 # 66c0 <malloc+0xa2e>
    162a:	00004097          	auipc	ra,0x4
    162e:	5b0080e7          	jalr	1456(ra) # 5bda <printf>
      exit(1);
    1632:	4505                	li	a0,1
    1634:	00004097          	auipc	ra,0x4
    1638:	224080e7          	jalr	548(ra) # 5858 <exit>
    if(exec("echo", echoargv) < 0){
    163c:	fc040593          	addi	a1,s0,-64
    1640:	00004517          	auipc	a0,0x4
    1644:	77050513          	addi	a0,a0,1904 # 5db0 <malloc+0x11e>
    1648:	00004097          	auipc	ra,0x4
    164c:	248080e7          	jalr	584(ra) # 5890 <exec>
    1650:	02054163          	bltz	a0,1672 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1654:	fdc40513          	addi	a0,s0,-36
    1658:	00004097          	auipc	ra,0x4
    165c:	208080e7          	jalr	520(ra) # 5860 <wait>
    1660:	02951763          	bne	a0,s1,168e <exectest+0x118>
  if(xstatus != 0)
    1664:	fdc42503          	lw	a0,-36(s0)
    1668:	cd0d                	beqz	a0,16a2 <exectest+0x12c>
    exit(xstatus);
    166a:	00004097          	auipc	ra,0x4
    166e:	1ee080e7          	jalr	494(ra) # 5858 <exit>
      printf("%s: exec echo failed\n", s);
    1672:	85ca                	mv	a1,s2
    1674:	00005517          	auipc	a0,0x5
    1678:	07450513          	addi	a0,a0,116 # 66e8 <malloc+0xa56>
    167c:	00004097          	auipc	ra,0x4
    1680:	55e080e7          	jalr	1374(ra) # 5bda <printf>
      exit(1);
    1684:	4505                	li	a0,1
    1686:	00004097          	auipc	ra,0x4
    168a:	1d2080e7          	jalr	466(ra) # 5858 <exit>
    printf("%s: wait failed!\n", s);
    168e:	85ca                	mv	a1,s2
    1690:	00005517          	auipc	a0,0x5
    1694:	07050513          	addi	a0,a0,112 # 6700 <malloc+0xa6e>
    1698:	00004097          	auipc	ra,0x4
    169c:	542080e7          	jalr	1346(ra) # 5bda <printf>
    16a0:	b7d1                	j	1664 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    16a2:	4581                	li	a1,0
    16a4:	00005517          	auipc	a0,0x5
    16a8:	01450513          	addi	a0,a0,20 # 66b8 <malloc+0xa26>
    16ac:	00004097          	auipc	ra,0x4
    16b0:	1ec080e7          	jalr	492(ra) # 5898 <open>
  if(fd < 0) {
    16b4:	02054a63          	bltz	a0,16e8 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16b8:	4609                	li	a2,2
    16ba:	fb840593          	addi	a1,s0,-72
    16be:	00004097          	auipc	ra,0x4
    16c2:	1b2080e7          	jalr	434(ra) # 5870 <read>
    16c6:	4789                	li	a5,2
    16c8:	02f50e63          	beq	a0,a5,1704 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16cc:	85ca                	mv	a1,s2
    16ce:	00005517          	auipc	a0,0x5
    16d2:	aa250513          	addi	a0,a0,-1374 # 6170 <malloc+0x4de>
    16d6:	00004097          	auipc	ra,0x4
    16da:	504080e7          	jalr	1284(ra) # 5bda <printf>
    exit(1);
    16de:	4505                	li	a0,1
    16e0:	00004097          	auipc	ra,0x4
    16e4:	178080e7          	jalr	376(ra) # 5858 <exit>
    printf("%s: open failed\n", s);
    16e8:	85ca                	mv	a1,s2
    16ea:	00005517          	auipc	a0,0x5
    16ee:	f5650513          	addi	a0,a0,-170 # 6640 <malloc+0x9ae>
    16f2:	00004097          	auipc	ra,0x4
    16f6:	4e8080e7          	jalr	1256(ra) # 5bda <printf>
    exit(1);
    16fa:	4505                	li	a0,1
    16fc:	00004097          	auipc	ra,0x4
    1700:	15c080e7          	jalr	348(ra) # 5858 <exit>
  unlink("echo-ok");
    1704:	00005517          	auipc	a0,0x5
    1708:	fb450513          	addi	a0,a0,-76 # 66b8 <malloc+0xa26>
    170c:	00004097          	auipc	ra,0x4
    1710:	19c080e7          	jalr	412(ra) # 58a8 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1714:	fb844703          	lbu	a4,-72(s0)
    1718:	04f00793          	li	a5,79
    171c:	00f71863          	bne	a4,a5,172c <exectest+0x1b6>
    1720:	fb944703          	lbu	a4,-71(s0)
    1724:	04b00793          	li	a5,75
    1728:	02f70063          	beq	a4,a5,1748 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    172c:	85ca                	mv	a1,s2
    172e:	00005517          	auipc	a0,0x5
    1732:	fea50513          	addi	a0,a0,-22 # 6718 <malloc+0xa86>
    1736:	00004097          	auipc	ra,0x4
    173a:	4a4080e7          	jalr	1188(ra) # 5bda <printf>
    exit(1);
    173e:	4505                	li	a0,1
    1740:	00004097          	auipc	ra,0x4
    1744:	118080e7          	jalr	280(ra) # 5858 <exit>
    exit(0);
    1748:	4501                	li	a0,0
    174a:	00004097          	auipc	ra,0x4
    174e:	10e080e7          	jalr	270(ra) # 5858 <exit>

0000000000001752 <pipe1>:
{
    1752:	711d                	addi	sp,sp,-96
    1754:	ec86                	sd	ra,88(sp)
    1756:	e8a2                	sd	s0,80(sp)
    1758:	e4a6                	sd	s1,72(sp)
    175a:	e0ca                	sd	s2,64(sp)
    175c:	fc4e                	sd	s3,56(sp)
    175e:	f852                	sd	s4,48(sp)
    1760:	f456                	sd	s5,40(sp)
    1762:	f05a                	sd	s6,32(sp)
    1764:	ec5e                	sd	s7,24(sp)
    1766:	1080                	addi	s0,sp,96
    1768:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    176a:	fa840513          	addi	a0,s0,-88
    176e:	00004097          	auipc	ra,0x4
    1772:	0fa080e7          	jalr	250(ra) # 5868 <pipe>
    1776:	e93d                	bnez	a0,17ec <pipe1+0x9a>
    1778:	84aa                	mv	s1,a0
  pid = fork();
    177a:	00004097          	auipc	ra,0x4
    177e:	0d6080e7          	jalr	214(ra) # 5850 <fork>
    1782:	8a2a                	mv	s4,a0
  if(pid == 0){
    1784:	c151                	beqz	a0,1808 <pipe1+0xb6>
  } else if(pid > 0){
    1786:	16a05d63          	blez	a0,1900 <pipe1+0x1ae>
    close(fds[1]);
    178a:	fac42503          	lw	a0,-84(s0)
    178e:	00004097          	auipc	ra,0x4
    1792:	0f2080e7          	jalr	242(ra) # 5880 <close>
    total = 0;
    1796:	8a26                	mv	s4,s1
    cc = 1;
    1798:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    179a:	0000aa97          	auipc	s5,0xa
    179e:	676a8a93          	addi	s5,s5,1654 # be10 <buf>
      if(cc > sizeof(buf))
    17a2:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    17a4:	864e                	mv	a2,s3
    17a6:	85d6                	mv	a1,s5
    17a8:	fa842503          	lw	a0,-88(s0)
    17ac:	00004097          	auipc	ra,0x4
    17b0:	0c4080e7          	jalr	196(ra) # 5870 <read>
    17b4:	10a05163          	blez	a0,18b6 <pipe1+0x164>
      for(i = 0; i < n; i++){
    17b8:	0000a717          	auipc	a4,0xa
    17bc:	65870713          	addi	a4,a4,1624 # be10 <buf>
    17c0:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17c4:	00074683          	lbu	a3,0(a4)
    17c8:	0ff4f793          	zext.b	a5,s1
    17cc:	2485                	addiw	s1,s1,1
    17ce:	0cf69063          	bne	a3,a5,188e <pipe1+0x13c>
      for(i = 0; i < n; i++){
    17d2:	0705                	addi	a4,a4,1
    17d4:	fec498e3          	bne	s1,a2,17c4 <pipe1+0x72>
      total += n;
    17d8:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    17dc:	0019979b          	slliw	a5,s3,0x1
    17e0:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    17e4:	fd3b70e3          	bgeu	s6,s3,17a4 <pipe1+0x52>
        cc = sizeof(buf);
    17e8:	89da                	mv	s3,s6
    17ea:	bf6d                	j	17a4 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    17ec:	85ca                	mv	a1,s2
    17ee:	00005517          	auipc	a0,0x5
    17f2:	f4250513          	addi	a0,a0,-190 # 6730 <malloc+0xa9e>
    17f6:	00004097          	auipc	ra,0x4
    17fa:	3e4080e7          	jalr	996(ra) # 5bda <printf>
    exit(1);
    17fe:	4505                	li	a0,1
    1800:	00004097          	auipc	ra,0x4
    1804:	058080e7          	jalr	88(ra) # 5858 <exit>
    close(fds[0]);
    1808:	fa842503          	lw	a0,-88(s0)
    180c:	00004097          	auipc	ra,0x4
    1810:	074080e7          	jalr	116(ra) # 5880 <close>
    for(n = 0; n < N; n++){
    1814:	0000ab17          	auipc	s6,0xa
    1818:	5fcb0b13          	addi	s6,s6,1532 # be10 <buf>
    181c:	416004bb          	negw	s1,s6
    1820:	0ff4f493          	zext.b	s1,s1
    1824:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1828:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    182a:	6a85                	lui	s5,0x1
    182c:	42da8a93          	addi	s5,s5,1069 # 142d <truncate3+0x71>
{
    1830:	87da                	mv	a5,s6
        buf[i] = seq++;
    1832:	0097873b          	addw	a4,a5,s1
    1836:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    183a:	0785                	addi	a5,a5,1
    183c:	fef99be3          	bne	s3,a5,1832 <pipe1+0xe0>
        buf[i] = seq++;
    1840:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1844:	40900613          	li	a2,1033
    1848:	85de                	mv	a1,s7
    184a:	fac42503          	lw	a0,-84(s0)
    184e:	00004097          	auipc	ra,0x4
    1852:	02a080e7          	jalr	42(ra) # 5878 <write>
    1856:	40900793          	li	a5,1033
    185a:	00f51c63          	bne	a0,a5,1872 <pipe1+0x120>
    for(n = 0; n < N; n++){
    185e:	24a5                	addiw	s1,s1,9
    1860:	0ff4f493          	zext.b	s1,s1
    1864:	fd5a16e3          	bne	s4,s5,1830 <pipe1+0xde>
    exit(0);
    1868:	4501                	li	a0,0
    186a:	00004097          	auipc	ra,0x4
    186e:	fee080e7          	jalr	-18(ra) # 5858 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1872:	85ca                	mv	a1,s2
    1874:	00005517          	auipc	a0,0x5
    1878:	ed450513          	addi	a0,a0,-300 # 6748 <malloc+0xab6>
    187c:	00004097          	auipc	ra,0x4
    1880:	35e080e7          	jalr	862(ra) # 5bda <printf>
        exit(1);
    1884:	4505                	li	a0,1
    1886:	00004097          	auipc	ra,0x4
    188a:	fd2080e7          	jalr	-46(ra) # 5858 <exit>
          printf("%s: pipe1 oops 2\n", s);
    188e:	85ca                	mv	a1,s2
    1890:	00005517          	auipc	a0,0x5
    1894:	ed050513          	addi	a0,a0,-304 # 6760 <malloc+0xace>
    1898:	00004097          	auipc	ra,0x4
    189c:	342080e7          	jalr	834(ra) # 5bda <printf>
}
    18a0:	60e6                	ld	ra,88(sp)
    18a2:	6446                	ld	s0,80(sp)
    18a4:	64a6                	ld	s1,72(sp)
    18a6:	6906                	ld	s2,64(sp)
    18a8:	79e2                	ld	s3,56(sp)
    18aa:	7a42                	ld	s4,48(sp)
    18ac:	7aa2                	ld	s5,40(sp)
    18ae:	7b02                	ld	s6,32(sp)
    18b0:	6be2                	ld	s7,24(sp)
    18b2:	6125                	addi	sp,sp,96
    18b4:	8082                	ret
    if(total != N * SZ){
    18b6:	6785                	lui	a5,0x1
    18b8:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x71>
    18bc:	02fa0063          	beq	s4,a5,18dc <pipe1+0x18a>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18c0:	85d2                	mv	a1,s4
    18c2:	00005517          	auipc	a0,0x5
    18c6:	eb650513          	addi	a0,a0,-330 # 6778 <malloc+0xae6>
    18ca:	00004097          	auipc	ra,0x4
    18ce:	310080e7          	jalr	784(ra) # 5bda <printf>
      exit(1);
    18d2:	4505                	li	a0,1
    18d4:	00004097          	auipc	ra,0x4
    18d8:	f84080e7          	jalr	-124(ra) # 5858 <exit>
    close(fds[0]);
    18dc:	fa842503          	lw	a0,-88(s0)
    18e0:	00004097          	auipc	ra,0x4
    18e4:	fa0080e7          	jalr	-96(ra) # 5880 <close>
    wait(&xstatus);
    18e8:	fa440513          	addi	a0,s0,-92
    18ec:	00004097          	auipc	ra,0x4
    18f0:	f74080e7          	jalr	-140(ra) # 5860 <wait>
    exit(xstatus);
    18f4:	fa442503          	lw	a0,-92(s0)
    18f8:	00004097          	auipc	ra,0x4
    18fc:	f60080e7          	jalr	-160(ra) # 5858 <exit>
    printf("%s: fork() failed\n", s);
    1900:	85ca                	mv	a1,s2
    1902:	00005517          	auipc	a0,0x5
    1906:	e9650513          	addi	a0,a0,-362 # 6798 <malloc+0xb06>
    190a:	00004097          	auipc	ra,0x4
    190e:	2d0080e7          	jalr	720(ra) # 5bda <printf>
    exit(1);
    1912:	4505                	li	a0,1
    1914:	00004097          	auipc	ra,0x4
    1918:	f44080e7          	jalr	-188(ra) # 5858 <exit>

000000000000191c <exitwait>:
{
    191c:	7139                	addi	sp,sp,-64
    191e:	fc06                	sd	ra,56(sp)
    1920:	f822                	sd	s0,48(sp)
    1922:	f426                	sd	s1,40(sp)
    1924:	f04a                	sd	s2,32(sp)
    1926:	ec4e                	sd	s3,24(sp)
    1928:	e852                	sd	s4,16(sp)
    192a:	0080                	addi	s0,sp,64
    192c:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    192e:	4901                	li	s2,0
    1930:	06400993          	li	s3,100
    pid = fork();
    1934:	00004097          	auipc	ra,0x4
    1938:	f1c080e7          	jalr	-228(ra) # 5850 <fork>
    193c:	84aa                	mv	s1,a0
    if(pid < 0){
    193e:	02054a63          	bltz	a0,1972 <exitwait+0x56>
    if(pid){
    1942:	c151                	beqz	a0,19c6 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1944:	fcc40513          	addi	a0,s0,-52
    1948:	00004097          	auipc	ra,0x4
    194c:	f18080e7          	jalr	-232(ra) # 5860 <wait>
    1950:	02951f63          	bne	a0,s1,198e <exitwait+0x72>
      if(i != xstate) {
    1954:	fcc42783          	lw	a5,-52(s0)
    1958:	05279963          	bne	a5,s2,19aa <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    195c:	2905                	addiw	s2,s2,1
    195e:	fd391be3          	bne	s2,s3,1934 <exitwait+0x18>
}
    1962:	70e2                	ld	ra,56(sp)
    1964:	7442                	ld	s0,48(sp)
    1966:	74a2                	ld	s1,40(sp)
    1968:	7902                	ld	s2,32(sp)
    196a:	69e2                	ld	s3,24(sp)
    196c:	6a42                	ld	s4,16(sp)
    196e:	6121                	addi	sp,sp,64
    1970:	8082                	ret
      printf("%s: fork failed\n", s);
    1972:	85d2                	mv	a1,s4
    1974:	00005517          	auipc	a0,0x5
    1978:	cb450513          	addi	a0,a0,-844 # 6628 <malloc+0x996>
    197c:	00004097          	auipc	ra,0x4
    1980:	25e080e7          	jalr	606(ra) # 5bda <printf>
      exit(1);
    1984:	4505                	li	a0,1
    1986:	00004097          	auipc	ra,0x4
    198a:	ed2080e7          	jalr	-302(ra) # 5858 <exit>
        printf("%s: wait wrong pid\n", s);
    198e:	85d2                	mv	a1,s4
    1990:	00005517          	auipc	a0,0x5
    1994:	e2050513          	addi	a0,a0,-480 # 67b0 <malloc+0xb1e>
    1998:	00004097          	auipc	ra,0x4
    199c:	242080e7          	jalr	578(ra) # 5bda <printf>
        exit(1);
    19a0:	4505                	li	a0,1
    19a2:	00004097          	auipc	ra,0x4
    19a6:	eb6080e7          	jalr	-330(ra) # 5858 <exit>
        printf("%s: wait wrong exit status\n", s);
    19aa:	85d2                	mv	a1,s4
    19ac:	00005517          	auipc	a0,0x5
    19b0:	e1c50513          	addi	a0,a0,-484 # 67c8 <malloc+0xb36>
    19b4:	00004097          	auipc	ra,0x4
    19b8:	226080e7          	jalr	550(ra) # 5bda <printf>
        exit(1);
    19bc:	4505                	li	a0,1
    19be:	00004097          	auipc	ra,0x4
    19c2:	e9a080e7          	jalr	-358(ra) # 5858 <exit>
      exit(i);
    19c6:	854a                	mv	a0,s2
    19c8:	00004097          	auipc	ra,0x4
    19cc:	e90080e7          	jalr	-368(ra) # 5858 <exit>

00000000000019d0 <twochildren>:
{
    19d0:	1101                	addi	sp,sp,-32
    19d2:	ec06                	sd	ra,24(sp)
    19d4:	e822                	sd	s0,16(sp)
    19d6:	e426                	sd	s1,8(sp)
    19d8:	e04a                	sd	s2,0(sp)
    19da:	1000                	addi	s0,sp,32
    19dc:	892a                	mv	s2,a0
    19de:	3e800493          	li	s1,1000
    int pid1 = fork();
    19e2:	00004097          	auipc	ra,0x4
    19e6:	e6e080e7          	jalr	-402(ra) # 5850 <fork>
    if(pid1 < 0){
    19ea:	02054c63          	bltz	a0,1a22 <twochildren+0x52>
    if(pid1 == 0){
    19ee:	c921                	beqz	a0,1a3e <twochildren+0x6e>
      int pid2 = fork();
    19f0:	00004097          	auipc	ra,0x4
    19f4:	e60080e7          	jalr	-416(ra) # 5850 <fork>
      if(pid2 < 0){
    19f8:	04054763          	bltz	a0,1a46 <twochildren+0x76>
      if(pid2 == 0){
    19fc:	c13d                	beqz	a0,1a62 <twochildren+0x92>
        wait(0);
    19fe:	4501                	li	a0,0
    1a00:	00004097          	auipc	ra,0x4
    1a04:	e60080e7          	jalr	-416(ra) # 5860 <wait>
        wait(0);
    1a08:	4501                	li	a0,0
    1a0a:	00004097          	auipc	ra,0x4
    1a0e:	e56080e7          	jalr	-426(ra) # 5860 <wait>
  for(int i = 0; i < 1000; i++){
    1a12:	34fd                	addiw	s1,s1,-1
    1a14:	f4f9                	bnez	s1,19e2 <twochildren+0x12>
}
    1a16:	60e2                	ld	ra,24(sp)
    1a18:	6442                	ld	s0,16(sp)
    1a1a:	64a2                	ld	s1,8(sp)
    1a1c:	6902                	ld	s2,0(sp)
    1a1e:	6105                	addi	sp,sp,32
    1a20:	8082                	ret
      printf("%s: fork failed\n", s);
    1a22:	85ca                	mv	a1,s2
    1a24:	00005517          	auipc	a0,0x5
    1a28:	c0450513          	addi	a0,a0,-1020 # 6628 <malloc+0x996>
    1a2c:	00004097          	auipc	ra,0x4
    1a30:	1ae080e7          	jalr	430(ra) # 5bda <printf>
      exit(1);
    1a34:	4505                	li	a0,1
    1a36:	00004097          	auipc	ra,0x4
    1a3a:	e22080e7          	jalr	-478(ra) # 5858 <exit>
      exit(0);
    1a3e:	00004097          	auipc	ra,0x4
    1a42:	e1a080e7          	jalr	-486(ra) # 5858 <exit>
        printf("%s: fork failed\n", s);
    1a46:	85ca                	mv	a1,s2
    1a48:	00005517          	auipc	a0,0x5
    1a4c:	be050513          	addi	a0,a0,-1056 # 6628 <malloc+0x996>
    1a50:	00004097          	auipc	ra,0x4
    1a54:	18a080e7          	jalr	394(ra) # 5bda <printf>
        exit(1);
    1a58:	4505                	li	a0,1
    1a5a:	00004097          	auipc	ra,0x4
    1a5e:	dfe080e7          	jalr	-514(ra) # 5858 <exit>
        exit(0);
    1a62:	00004097          	auipc	ra,0x4
    1a66:	df6080e7          	jalr	-522(ra) # 5858 <exit>

0000000000001a6a <forkfork>:
{
    1a6a:	7179                	addi	sp,sp,-48
    1a6c:	f406                	sd	ra,40(sp)
    1a6e:	f022                	sd	s0,32(sp)
    1a70:	ec26                	sd	s1,24(sp)
    1a72:	1800                	addi	s0,sp,48
    1a74:	84aa                	mv	s1,a0
    int pid = fork();
    1a76:	00004097          	auipc	ra,0x4
    1a7a:	dda080e7          	jalr	-550(ra) # 5850 <fork>
    if(pid < 0){
    1a7e:	04054163          	bltz	a0,1ac0 <forkfork+0x56>
    if(pid == 0){
    1a82:	cd29                	beqz	a0,1adc <forkfork+0x72>
    int pid = fork();
    1a84:	00004097          	auipc	ra,0x4
    1a88:	dcc080e7          	jalr	-564(ra) # 5850 <fork>
    if(pid < 0){
    1a8c:	02054a63          	bltz	a0,1ac0 <forkfork+0x56>
    if(pid == 0){
    1a90:	c531                	beqz	a0,1adc <forkfork+0x72>
    wait(&xstatus);
    1a92:	fdc40513          	addi	a0,s0,-36
    1a96:	00004097          	auipc	ra,0x4
    1a9a:	dca080e7          	jalr	-566(ra) # 5860 <wait>
    if(xstatus != 0) {
    1a9e:	fdc42783          	lw	a5,-36(s0)
    1aa2:	ebbd                	bnez	a5,1b18 <forkfork+0xae>
    wait(&xstatus);
    1aa4:	fdc40513          	addi	a0,s0,-36
    1aa8:	00004097          	auipc	ra,0x4
    1aac:	db8080e7          	jalr	-584(ra) # 5860 <wait>
    if(xstatus != 0) {
    1ab0:	fdc42783          	lw	a5,-36(s0)
    1ab4:	e3b5                	bnez	a5,1b18 <forkfork+0xae>
}
    1ab6:	70a2                	ld	ra,40(sp)
    1ab8:	7402                	ld	s0,32(sp)
    1aba:	64e2                	ld	s1,24(sp)
    1abc:	6145                	addi	sp,sp,48
    1abe:	8082                	ret
      printf("%s: fork failed", s);
    1ac0:	85a6                	mv	a1,s1
    1ac2:	00005517          	auipc	a0,0x5
    1ac6:	d2650513          	addi	a0,a0,-730 # 67e8 <malloc+0xb56>
    1aca:	00004097          	auipc	ra,0x4
    1ace:	110080e7          	jalr	272(ra) # 5bda <printf>
      exit(1);
    1ad2:	4505                	li	a0,1
    1ad4:	00004097          	auipc	ra,0x4
    1ad8:	d84080e7          	jalr	-636(ra) # 5858 <exit>
{
    1adc:	0c800493          	li	s1,200
        int pid1 = fork();
    1ae0:	00004097          	auipc	ra,0x4
    1ae4:	d70080e7          	jalr	-656(ra) # 5850 <fork>
        if(pid1 < 0){
    1ae8:	00054f63          	bltz	a0,1b06 <forkfork+0x9c>
        if(pid1 == 0){
    1aec:	c115                	beqz	a0,1b10 <forkfork+0xa6>
        wait(0);
    1aee:	4501                	li	a0,0
    1af0:	00004097          	auipc	ra,0x4
    1af4:	d70080e7          	jalr	-656(ra) # 5860 <wait>
      for(int j = 0; j < 200; j++){
    1af8:	34fd                	addiw	s1,s1,-1
    1afa:	f0fd                	bnez	s1,1ae0 <forkfork+0x76>
      exit(0);
    1afc:	4501                	li	a0,0
    1afe:	00004097          	auipc	ra,0x4
    1b02:	d5a080e7          	jalr	-678(ra) # 5858 <exit>
          exit(1);
    1b06:	4505                	li	a0,1
    1b08:	00004097          	auipc	ra,0x4
    1b0c:	d50080e7          	jalr	-688(ra) # 5858 <exit>
          exit(0);
    1b10:	00004097          	auipc	ra,0x4
    1b14:	d48080e7          	jalr	-696(ra) # 5858 <exit>
      printf("%s: fork in child failed", s);
    1b18:	85a6                	mv	a1,s1
    1b1a:	00005517          	auipc	a0,0x5
    1b1e:	cde50513          	addi	a0,a0,-802 # 67f8 <malloc+0xb66>
    1b22:	00004097          	auipc	ra,0x4
    1b26:	0b8080e7          	jalr	184(ra) # 5bda <printf>
      exit(1);
    1b2a:	4505                	li	a0,1
    1b2c:	00004097          	auipc	ra,0x4
    1b30:	d2c080e7          	jalr	-724(ra) # 5858 <exit>

0000000000001b34 <reparent2>:
{
    1b34:	1101                	addi	sp,sp,-32
    1b36:	ec06                	sd	ra,24(sp)
    1b38:	e822                	sd	s0,16(sp)
    1b3a:	e426                	sd	s1,8(sp)
    1b3c:	1000                	addi	s0,sp,32
    1b3e:	32000493          	li	s1,800
    int pid1 = fork();
    1b42:	00004097          	auipc	ra,0x4
    1b46:	d0e080e7          	jalr	-754(ra) # 5850 <fork>
    if(pid1 < 0){
    1b4a:	00054f63          	bltz	a0,1b68 <reparent2+0x34>
    if(pid1 == 0){
    1b4e:	c915                	beqz	a0,1b82 <reparent2+0x4e>
    wait(0);
    1b50:	4501                	li	a0,0
    1b52:	00004097          	auipc	ra,0x4
    1b56:	d0e080e7          	jalr	-754(ra) # 5860 <wait>
  for(int i = 0; i < 800; i++){
    1b5a:	34fd                	addiw	s1,s1,-1
    1b5c:	f0fd                	bnez	s1,1b42 <reparent2+0xe>
  exit(0);
    1b5e:	4501                	li	a0,0
    1b60:	00004097          	auipc	ra,0x4
    1b64:	cf8080e7          	jalr	-776(ra) # 5858 <exit>
      printf("fork failed\n");
    1b68:	00005517          	auipc	a0,0x5
    1b6c:	ee050513          	addi	a0,a0,-288 # 6a48 <malloc+0xdb6>
    1b70:	00004097          	auipc	ra,0x4
    1b74:	06a080e7          	jalr	106(ra) # 5bda <printf>
      exit(1);
    1b78:	4505                	li	a0,1
    1b7a:	00004097          	auipc	ra,0x4
    1b7e:	cde080e7          	jalr	-802(ra) # 5858 <exit>
      fork();
    1b82:	00004097          	auipc	ra,0x4
    1b86:	cce080e7          	jalr	-818(ra) # 5850 <fork>
      fork();
    1b8a:	00004097          	auipc	ra,0x4
    1b8e:	cc6080e7          	jalr	-826(ra) # 5850 <fork>
      exit(0);
    1b92:	4501                	li	a0,0
    1b94:	00004097          	auipc	ra,0x4
    1b98:	cc4080e7          	jalr	-828(ra) # 5858 <exit>

0000000000001b9c <createdelete>:
{
    1b9c:	7175                	addi	sp,sp,-144
    1b9e:	e506                	sd	ra,136(sp)
    1ba0:	e122                	sd	s0,128(sp)
    1ba2:	fca6                	sd	s1,120(sp)
    1ba4:	f8ca                	sd	s2,112(sp)
    1ba6:	f4ce                	sd	s3,104(sp)
    1ba8:	f0d2                	sd	s4,96(sp)
    1baa:	ecd6                	sd	s5,88(sp)
    1bac:	e8da                	sd	s6,80(sp)
    1bae:	e4de                	sd	s7,72(sp)
    1bb0:	e0e2                	sd	s8,64(sp)
    1bb2:	fc66                	sd	s9,56(sp)
    1bb4:	0900                	addi	s0,sp,144
    1bb6:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1bb8:	4901                	li	s2,0
    1bba:	4991                	li	s3,4
    pid = fork();
    1bbc:	00004097          	auipc	ra,0x4
    1bc0:	c94080e7          	jalr	-876(ra) # 5850 <fork>
    1bc4:	84aa                	mv	s1,a0
    if(pid < 0){
    1bc6:	02054f63          	bltz	a0,1c04 <createdelete+0x68>
    if(pid == 0){
    1bca:	c939                	beqz	a0,1c20 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1bcc:	2905                	addiw	s2,s2,1
    1bce:	ff3917e3          	bne	s2,s3,1bbc <createdelete+0x20>
    1bd2:	4491                	li	s1,4
    wait(&xstatus);
    1bd4:	f7c40513          	addi	a0,s0,-132
    1bd8:	00004097          	auipc	ra,0x4
    1bdc:	c88080e7          	jalr	-888(ra) # 5860 <wait>
    if(xstatus != 0)
    1be0:	f7c42903          	lw	s2,-132(s0)
    1be4:	0e091263          	bnez	s2,1cc8 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1be8:	34fd                	addiw	s1,s1,-1
    1bea:	f4ed                	bnez	s1,1bd4 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1bec:	f8040123          	sb	zero,-126(s0)
    1bf0:	03000993          	li	s3,48
    1bf4:	5a7d                	li	s4,-1
    1bf6:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1bfa:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1bfc:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1bfe:	07400a93          	li	s5,116
    1c02:	a29d                	j	1d68 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1c04:	85e6                	mv	a1,s9
    1c06:	00005517          	auipc	a0,0x5
    1c0a:	e4250513          	addi	a0,a0,-446 # 6a48 <malloc+0xdb6>
    1c0e:	00004097          	auipc	ra,0x4
    1c12:	fcc080e7          	jalr	-52(ra) # 5bda <printf>
      exit(1);
    1c16:	4505                	li	a0,1
    1c18:	00004097          	auipc	ra,0x4
    1c1c:	c40080e7          	jalr	-960(ra) # 5858 <exit>
      name[0] = 'p' + pi;
    1c20:	0709091b          	addiw	s2,s2,112
    1c24:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c28:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c2c:	4951                	li	s2,20
    1c2e:	a015                	j	1c52 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c30:	85e6                	mv	a1,s9
    1c32:	00005517          	auipc	a0,0x5
    1c36:	a8e50513          	addi	a0,a0,-1394 # 66c0 <malloc+0xa2e>
    1c3a:	00004097          	auipc	ra,0x4
    1c3e:	fa0080e7          	jalr	-96(ra) # 5bda <printf>
          exit(1);
    1c42:	4505                	li	a0,1
    1c44:	00004097          	auipc	ra,0x4
    1c48:	c14080e7          	jalr	-1004(ra) # 5858 <exit>
      for(i = 0; i < N; i++){
    1c4c:	2485                	addiw	s1,s1,1
    1c4e:	07248863          	beq	s1,s2,1cbe <createdelete+0x122>
        name[1] = '0' + i;
    1c52:	0304879b          	addiw	a5,s1,48
    1c56:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c5a:	20200593          	li	a1,514
    1c5e:	f8040513          	addi	a0,s0,-128
    1c62:	00004097          	auipc	ra,0x4
    1c66:	c36080e7          	jalr	-970(ra) # 5898 <open>
        if(fd < 0){
    1c6a:	fc0543e3          	bltz	a0,1c30 <createdelete+0x94>
        close(fd);
    1c6e:	00004097          	auipc	ra,0x4
    1c72:	c12080e7          	jalr	-1006(ra) # 5880 <close>
        if(i > 0 && (i % 2 ) == 0){
    1c76:	fc905be3          	blez	s1,1c4c <createdelete+0xb0>
    1c7a:	0014f793          	andi	a5,s1,1
    1c7e:	f7f9                	bnez	a5,1c4c <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c80:	01f4d79b          	srliw	a5,s1,0x1f
    1c84:	9fa5                	addw	a5,a5,s1
    1c86:	4017d79b          	sraiw	a5,a5,0x1
    1c8a:	0307879b          	addiw	a5,a5,48
    1c8e:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1c92:	f8040513          	addi	a0,s0,-128
    1c96:	00004097          	auipc	ra,0x4
    1c9a:	c12080e7          	jalr	-1006(ra) # 58a8 <unlink>
    1c9e:	fa0557e3          	bgez	a0,1c4c <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1ca2:	85e6                	mv	a1,s9
    1ca4:	00005517          	auipc	a0,0x5
    1ca8:	b7450513          	addi	a0,a0,-1164 # 6818 <malloc+0xb86>
    1cac:	00004097          	auipc	ra,0x4
    1cb0:	f2e080e7          	jalr	-210(ra) # 5bda <printf>
            exit(1);
    1cb4:	4505                	li	a0,1
    1cb6:	00004097          	auipc	ra,0x4
    1cba:	ba2080e7          	jalr	-1118(ra) # 5858 <exit>
      exit(0);
    1cbe:	4501                	li	a0,0
    1cc0:	00004097          	auipc	ra,0x4
    1cc4:	b98080e7          	jalr	-1128(ra) # 5858 <exit>
      exit(1);
    1cc8:	4505                	li	a0,1
    1cca:	00004097          	auipc	ra,0x4
    1cce:	b8e080e7          	jalr	-1138(ra) # 5858 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1cd2:	f8040613          	addi	a2,s0,-128
    1cd6:	85e6                	mv	a1,s9
    1cd8:	00005517          	auipc	a0,0x5
    1cdc:	b5850513          	addi	a0,a0,-1192 # 6830 <malloc+0xb9e>
    1ce0:	00004097          	auipc	ra,0x4
    1ce4:	efa080e7          	jalr	-262(ra) # 5bda <printf>
        exit(1);
    1ce8:	4505                	li	a0,1
    1cea:	00004097          	auipc	ra,0x4
    1cee:	b6e080e7          	jalr	-1170(ra) # 5858 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1cf2:	054b7163          	bgeu	s6,s4,1d34 <createdelete+0x198>
      if(fd >= 0)
    1cf6:	02055a63          	bgez	a0,1d2a <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1cfa:	2485                	addiw	s1,s1,1
    1cfc:	0ff4f493          	zext.b	s1,s1
    1d00:	05548c63          	beq	s1,s5,1d58 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1d04:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1d08:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1d0c:	4581                	li	a1,0
    1d0e:	f8040513          	addi	a0,s0,-128
    1d12:	00004097          	auipc	ra,0x4
    1d16:	b86080e7          	jalr	-1146(ra) # 5898 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d1a:	00090463          	beqz	s2,1d22 <createdelete+0x186>
    1d1e:	fd2bdae3          	bge	s7,s2,1cf2 <createdelete+0x156>
    1d22:	fa0548e3          	bltz	a0,1cd2 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d26:	014b7963          	bgeu	s6,s4,1d38 <createdelete+0x19c>
        close(fd);
    1d2a:	00004097          	auipc	ra,0x4
    1d2e:	b56080e7          	jalr	-1194(ra) # 5880 <close>
    1d32:	b7e1                	j	1cfa <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d34:	fc0543e3          	bltz	a0,1cfa <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d38:	f8040613          	addi	a2,s0,-128
    1d3c:	85e6                	mv	a1,s9
    1d3e:	00005517          	auipc	a0,0x5
    1d42:	b1a50513          	addi	a0,a0,-1254 # 6858 <malloc+0xbc6>
    1d46:	00004097          	auipc	ra,0x4
    1d4a:	e94080e7          	jalr	-364(ra) # 5bda <printf>
        exit(1);
    1d4e:	4505                	li	a0,1
    1d50:	00004097          	auipc	ra,0x4
    1d54:	b08080e7          	jalr	-1272(ra) # 5858 <exit>
  for(i = 0; i < N; i++){
    1d58:	2905                	addiw	s2,s2,1
    1d5a:	2a05                	addiw	s4,s4,1
    1d5c:	2985                	addiw	s3,s3,1
    1d5e:	0ff9f993          	zext.b	s3,s3
    1d62:	47d1                	li	a5,20
    1d64:	02f90a63          	beq	s2,a5,1d98 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d68:	84e2                	mv	s1,s8
    1d6a:	bf69                	j	1d04 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d6c:	2905                	addiw	s2,s2,1
    1d6e:	0ff97913          	zext.b	s2,s2
    1d72:	2985                	addiw	s3,s3,1
    1d74:	0ff9f993          	zext.b	s3,s3
    1d78:	03490863          	beq	s2,s4,1da8 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d7c:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d7e:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d82:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1d86:	f8040513          	addi	a0,s0,-128
    1d8a:	00004097          	auipc	ra,0x4
    1d8e:	b1e080e7          	jalr	-1250(ra) # 58a8 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1d92:	34fd                	addiw	s1,s1,-1
    1d94:	f4ed                	bnez	s1,1d7e <createdelete+0x1e2>
    1d96:	bfd9                	j	1d6c <createdelete+0x1d0>
    1d98:	03000993          	li	s3,48
    1d9c:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1da0:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1da2:	08400a13          	li	s4,132
    1da6:	bfd9                	j	1d7c <createdelete+0x1e0>
}
    1da8:	60aa                	ld	ra,136(sp)
    1daa:	640a                	ld	s0,128(sp)
    1dac:	74e6                	ld	s1,120(sp)
    1dae:	7946                	ld	s2,112(sp)
    1db0:	79a6                	ld	s3,104(sp)
    1db2:	7a06                	ld	s4,96(sp)
    1db4:	6ae6                	ld	s5,88(sp)
    1db6:	6b46                	ld	s6,80(sp)
    1db8:	6ba6                	ld	s7,72(sp)
    1dba:	6c06                	ld	s8,64(sp)
    1dbc:	7ce2                	ld	s9,56(sp)
    1dbe:	6149                	addi	sp,sp,144
    1dc0:	8082                	ret

0000000000001dc2 <linkunlink>:
{
    1dc2:	711d                	addi	sp,sp,-96
    1dc4:	ec86                	sd	ra,88(sp)
    1dc6:	e8a2                	sd	s0,80(sp)
    1dc8:	e4a6                	sd	s1,72(sp)
    1dca:	e0ca                	sd	s2,64(sp)
    1dcc:	fc4e                	sd	s3,56(sp)
    1dce:	f852                	sd	s4,48(sp)
    1dd0:	f456                	sd	s5,40(sp)
    1dd2:	f05a                	sd	s6,32(sp)
    1dd4:	ec5e                	sd	s7,24(sp)
    1dd6:	e862                	sd	s8,16(sp)
    1dd8:	e466                	sd	s9,8(sp)
    1dda:	1080                	addi	s0,sp,96
    1ddc:	84aa                	mv	s1,a0
  unlink("x");
    1dde:	00004517          	auipc	a0,0x4
    1de2:	04250513          	addi	a0,a0,66 # 5e20 <malloc+0x18e>
    1de6:	00004097          	auipc	ra,0x4
    1dea:	ac2080e7          	jalr	-1342(ra) # 58a8 <unlink>
  pid = fork();
    1dee:	00004097          	auipc	ra,0x4
    1df2:	a62080e7          	jalr	-1438(ra) # 5850 <fork>
  if(pid < 0){
    1df6:	02054b63          	bltz	a0,1e2c <linkunlink+0x6a>
    1dfa:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1dfc:	4c85                	li	s9,1
    1dfe:	e119                	bnez	a0,1e04 <linkunlink+0x42>
    1e00:	06100c93          	li	s9,97
    1e04:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1e08:	41c659b7          	lui	s3,0x41c65
    1e0c:	e6d9899b          	addiw	s3,s3,-403
    1e10:	690d                	lui	s2,0x3
    1e12:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e16:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e18:	4b05                	li	s6,1
      unlink("x");
    1e1a:	00004a97          	auipc	s5,0x4
    1e1e:	006a8a93          	addi	s5,s5,6 # 5e20 <malloc+0x18e>
      link("cat", "x");
    1e22:	00005b97          	auipc	s7,0x5
    1e26:	a5eb8b93          	addi	s7,s7,-1442 # 6880 <malloc+0xbee>
    1e2a:	a825                	j	1e62 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    1e2c:	85a6                	mv	a1,s1
    1e2e:	00004517          	auipc	a0,0x4
    1e32:	7fa50513          	addi	a0,a0,2042 # 6628 <malloc+0x996>
    1e36:	00004097          	auipc	ra,0x4
    1e3a:	da4080e7          	jalr	-604(ra) # 5bda <printf>
    exit(1);
    1e3e:	4505                	li	a0,1
    1e40:	00004097          	auipc	ra,0x4
    1e44:	a18080e7          	jalr	-1512(ra) # 5858 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e48:	20200593          	li	a1,514
    1e4c:	8556                	mv	a0,s5
    1e4e:	00004097          	auipc	ra,0x4
    1e52:	a4a080e7          	jalr	-1462(ra) # 5898 <open>
    1e56:	00004097          	auipc	ra,0x4
    1e5a:	a2a080e7          	jalr	-1494(ra) # 5880 <close>
  for(i = 0; i < 100; i++){
    1e5e:	34fd                	addiw	s1,s1,-1
    1e60:	c88d                	beqz	s1,1e92 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e62:	033c87bb          	mulw	a5,s9,s3
    1e66:	012787bb          	addw	a5,a5,s2
    1e6a:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e6e:	0347f7bb          	remuw	a5,a5,s4
    1e72:	dbf9                	beqz	a5,1e48 <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e74:	01678863          	beq	a5,s6,1e84 <linkunlink+0xc2>
      unlink("x");
    1e78:	8556                	mv	a0,s5
    1e7a:	00004097          	auipc	ra,0x4
    1e7e:	a2e080e7          	jalr	-1490(ra) # 58a8 <unlink>
    1e82:	bff1                	j	1e5e <linkunlink+0x9c>
      link("cat", "x");
    1e84:	85d6                	mv	a1,s5
    1e86:	855e                	mv	a0,s7
    1e88:	00004097          	auipc	ra,0x4
    1e8c:	a30080e7          	jalr	-1488(ra) # 58b8 <link>
    1e90:	b7f9                	j	1e5e <linkunlink+0x9c>
  if(pid)
    1e92:	020c0463          	beqz	s8,1eba <linkunlink+0xf8>
    wait(0);
    1e96:	4501                	li	a0,0
    1e98:	00004097          	auipc	ra,0x4
    1e9c:	9c8080e7          	jalr	-1592(ra) # 5860 <wait>
}
    1ea0:	60e6                	ld	ra,88(sp)
    1ea2:	6446                	ld	s0,80(sp)
    1ea4:	64a6                	ld	s1,72(sp)
    1ea6:	6906                	ld	s2,64(sp)
    1ea8:	79e2                	ld	s3,56(sp)
    1eaa:	7a42                	ld	s4,48(sp)
    1eac:	7aa2                	ld	s5,40(sp)
    1eae:	7b02                	ld	s6,32(sp)
    1eb0:	6be2                	ld	s7,24(sp)
    1eb2:	6c42                	ld	s8,16(sp)
    1eb4:	6ca2                	ld	s9,8(sp)
    1eb6:	6125                	addi	sp,sp,96
    1eb8:	8082                	ret
    exit(0);
    1eba:	4501                	li	a0,0
    1ebc:	00004097          	auipc	ra,0x4
    1ec0:	99c080e7          	jalr	-1636(ra) # 5858 <exit>

0000000000001ec4 <manywrites>:
{
    1ec4:	711d                	addi	sp,sp,-96
    1ec6:	ec86                	sd	ra,88(sp)
    1ec8:	e8a2                	sd	s0,80(sp)
    1eca:	e4a6                	sd	s1,72(sp)
    1ecc:	e0ca                	sd	s2,64(sp)
    1ece:	fc4e                	sd	s3,56(sp)
    1ed0:	f852                	sd	s4,48(sp)
    1ed2:	f456                	sd	s5,40(sp)
    1ed4:	f05a                	sd	s6,32(sp)
    1ed6:	ec5e                	sd	s7,24(sp)
    1ed8:	1080                	addi	s0,sp,96
    1eda:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    1edc:	4981                	li	s3,0
    1ede:	4911                	li	s2,4
    int pid = fork();
    1ee0:	00004097          	auipc	ra,0x4
    1ee4:	970080e7          	jalr	-1680(ra) # 5850 <fork>
    1ee8:	84aa                	mv	s1,a0
    if(pid < 0){
    1eea:	02054963          	bltz	a0,1f1c <manywrites+0x58>
    if(pid == 0){
    1eee:	c521                	beqz	a0,1f36 <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    1ef0:	2985                	addiw	s3,s3,1
    1ef2:	ff2997e3          	bne	s3,s2,1ee0 <manywrites+0x1c>
    1ef6:	4491                	li	s1,4
    int st = 0;
    1ef8:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    1efc:	fa840513          	addi	a0,s0,-88
    1f00:	00004097          	auipc	ra,0x4
    1f04:	960080e7          	jalr	-1696(ra) # 5860 <wait>
    if(st != 0)
    1f08:	fa842503          	lw	a0,-88(s0)
    1f0c:	ed6d                	bnez	a0,2006 <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    1f0e:	34fd                	addiw	s1,s1,-1
    1f10:	f4e5                	bnez	s1,1ef8 <manywrites+0x34>
  exit(0);
    1f12:	4501                	li	a0,0
    1f14:	00004097          	auipc	ra,0x4
    1f18:	944080e7          	jalr	-1724(ra) # 5858 <exit>
      printf("fork failed\n");
    1f1c:	00005517          	auipc	a0,0x5
    1f20:	b2c50513          	addi	a0,a0,-1236 # 6a48 <malloc+0xdb6>
    1f24:	00004097          	auipc	ra,0x4
    1f28:	cb6080e7          	jalr	-842(ra) # 5bda <printf>
      exit(1);
    1f2c:	4505                	li	a0,1
    1f2e:	00004097          	auipc	ra,0x4
    1f32:	92a080e7          	jalr	-1750(ra) # 5858 <exit>
      name[0] = 'b';
    1f36:	06200793          	li	a5,98
    1f3a:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    1f3e:	0619879b          	addiw	a5,s3,97
    1f42:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    1f46:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    1f4a:	fa840513          	addi	a0,s0,-88
    1f4e:	00004097          	auipc	ra,0x4
    1f52:	95a080e7          	jalr	-1702(ra) # 58a8 <unlink>
    1f56:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    1f58:	0000ab17          	auipc	s6,0xa
    1f5c:	eb8b0b13          	addi	s6,s6,-328 # be10 <buf>
        for(int i = 0; i < ci+1; i++){
    1f60:	8a26                	mv	s4,s1
    1f62:	0209ce63          	bltz	s3,1f9e <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    1f66:	20200593          	li	a1,514
    1f6a:	fa840513          	addi	a0,s0,-88
    1f6e:	00004097          	auipc	ra,0x4
    1f72:	92a080e7          	jalr	-1750(ra) # 5898 <open>
    1f76:	892a                	mv	s2,a0
          if(fd < 0){
    1f78:	04054763          	bltz	a0,1fc6 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    1f7c:	660d                	lui	a2,0x3
    1f7e:	85da                	mv	a1,s6
    1f80:	00004097          	auipc	ra,0x4
    1f84:	8f8080e7          	jalr	-1800(ra) # 5878 <write>
          if(cc != sz){
    1f88:	678d                	lui	a5,0x3
    1f8a:	04f51e63          	bne	a0,a5,1fe6 <manywrites+0x122>
          close(fd);
    1f8e:	854a                	mv	a0,s2
    1f90:	00004097          	auipc	ra,0x4
    1f94:	8f0080e7          	jalr	-1808(ra) # 5880 <close>
        for(int i = 0; i < ci+1; i++){
    1f98:	2a05                	addiw	s4,s4,1
    1f9a:	fd49d6e3          	bge	s3,s4,1f66 <manywrites+0xa2>
        unlink(name);
    1f9e:	fa840513          	addi	a0,s0,-88
    1fa2:	00004097          	auipc	ra,0x4
    1fa6:	906080e7          	jalr	-1786(ra) # 58a8 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    1faa:	3bfd                	addiw	s7,s7,-1
    1fac:	fa0b9ae3          	bnez	s7,1f60 <manywrites+0x9c>
      unlink(name);
    1fb0:	fa840513          	addi	a0,s0,-88
    1fb4:	00004097          	auipc	ra,0x4
    1fb8:	8f4080e7          	jalr	-1804(ra) # 58a8 <unlink>
      exit(0);
    1fbc:	4501                	li	a0,0
    1fbe:	00004097          	auipc	ra,0x4
    1fc2:	89a080e7          	jalr	-1894(ra) # 5858 <exit>
            printf("%s: cannot create %s\n", s, name);
    1fc6:	fa840613          	addi	a2,s0,-88
    1fca:	85d6                	mv	a1,s5
    1fcc:	00005517          	auipc	a0,0x5
    1fd0:	8bc50513          	addi	a0,a0,-1860 # 6888 <malloc+0xbf6>
    1fd4:	00004097          	auipc	ra,0x4
    1fd8:	c06080e7          	jalr	-1018(ra) # 5bda <printf>
            exit(1);
    1fdc:	4505                	li	a0,1
    1fde:	00004097          	auipc	ra,0x4
    1fe2:	87a080e7          	jalr	-1926(ra) # 5858 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1fe6:	86aa                	mv	a3,a0
    1fe8:	660d                	lui	a2,0x3
    1fea:	85d6                	mv	a1,s5
    1fec:	00004517          	auipc	a0,0x4
    1ff0:	e9450513          	addi	a0,a0,-364 # 5e80 <malloc+0x1ee>
    1ff4:	00004097          	auipc	ra,0x4
    1ff8:	be6080e7          	jalr	-1050(ra) # 5bda <printf>
            exit(1);
    1ffc:	4505                	li	a0,1
    1ffe:	00004097          	auipc	ra,0x4
    2002:	85a080e7          	jalr	-1958(ra) # 5858 <exit>
      exit(st);
    2006:	00004097          	auipc	ra,0x4
    200a:	852080e7          	jalr	-1966(ra) # 5858 <exit>

000000000000200e <forktest>:
{
    200e:	7179                	addi	sp,sp,-48
    2010:	f406                	sd	ra,40(sp)
    2012:	f022                	sd	s0,32(sp)
    2014:	ec26                	sd	s1,24(sp)
    2016:	e84a                	sd	s2,16(sp)
    2018:	e44e                	sd	s3,8(sp)
    201a:	1800                	addi	s0,sp,48
    201c:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    201e:	4481                	li	s1,0
    2020:	3e800913          	li	s2,1000
    pid = fork();
    2024:	00004097          	auipc	ra,0x4
    2028:	82c080e7          	jalr	-2004(ra) # 5850 <fork>
    if(pid < 0)
    202c:	02054863          	bltz	a0,205c <forktest+0x4e>
    if(pid == 0)
    2030:	c115                	beqz	a0,2054 <forktest+0x46>
  for(n=0; n<N; n++){
    2032:	2485                	addiw	s1,s1,1
    2034:	ff2498e3          	bne	s1,s2,2024 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    2038:	85ce                	mv	a1,s3
    203a:	00005517          	auipc	a0,0x5
    203e:	87e50513          	addi	a0,a0,-1922 # 68b8 <malloc+0xc26>
    2042:	00004097          	auipc	ra,0x4
    2046:	b98080e7          	jalr	-1128(ra) # 5bda <printf>
    exit(1);
    204a:	4505                	li	a0,1
    204c:	00004097          	auipc	ra,0x4
    2050:	80c080e7          	jalr	-2036(ra) # 5858 <exit>
      exit(0);
    2054:	00004097          	auipc	ra,0x4
    2058:	804080e7          	jalr	-2044(ra) # 5858 <exit>
  if (n == 0) {
    205c:	cc9d                	beqz	s1,209a <forktest+0x8c>
  if(n == N){
    205e:	3e800793          	li	a5,1000
    2062:	fcf48be3          	beq	s1,a5,2038 <forktest+0x2a>
  for(; n > 0; n--){
    2066:	00905b63          	blez	s1,207c <forktest+0x6e>
    if(wait(0) < 0){
    206a:	4501                	li	a0,0
    206c:	00003097          	auipc	ra,0x3
    2070:	7f4080e7          	jalr	2036(ra) # 5860 <wait>
    2074:	04054163          	bltz	a0,20b6 <forktest+0xa8>
  for(; n > 0; n--){
    2078:	34fd                	addiw	s1,s1,-1
    207a:	f8e5                	bnez	s1,206a <forktest+0x5c>
  if(wait(0) != -1){
    207c:	4501                	li	a0,0
    207e:	00003097          	auipc	ra,0x3
    2082:	7e2080e7          	jalr	2018(ra) # 5860 <wait>
    2086:	57fd                	li	a5,-1
    2088:	04f51563          	bne	a0,a5,20d2 <forktest+0xc4>
}
    208c:	70a2                	ld	ra,40(sp)
    208e:	7402                	ld	s0,32(sp)
    2090:	64e2                	ld	s1,24(sp)
    2092:	6942                	ld	s2,16(sp)
    2094:	69a2                	ld	s3,8(sp)
    2096:	6145                	addi	sp,sp,48
    2098:	8082                	ret
    printf("%s: no fork at all!\n", s);
    209a:	85ce                	mv	a1,s3
    209c:	00005517          	auipc	a0,0x5
    20a0:	80450513          	addi	a0,a0,-2044 # 68a0 <malloc+0xc0e>
    20a4:	00004097          	auipc	ra,0x4
    20a8:	b36080e7          	jalr	-1226(ra) # 5bda <printf>
    exit(1);
    20ac:	4505                	li	a0,1
    20ae:	00003097          	auipc	ra,0x3
    20b2:	7aa080e7          	jalr	1962(ra) # 5858 <exit>
      printf("%s: wait stopped early\n", s);
    20b6:	85ce                	mv	a1,s3
    20b8:	00005517          	auipc	a0,0x5
    20bc:	82850513          	addi	a0,a0,-2008 # 68e0 <malloc+0xc4e>
    20c0:	00004097          	auipc	ra,0x4
    20c4:	b1a080e7          	jalr	-1254(ra) # 5bda <printf>
      exit(1);
    20c8:	4505                	li	a0,1
    20ca:	00003097          	auipc	ra,0x3
    20ce:	78e080e7          	jalr	1934(ra) # 5858 <exit>
    printf("%s: wait got too many\n", s);
    20d2:	85ce                	mv	a1,s3
    20d4:	00005517          	auipc	a0,0x5
    20d8:	82450513          	addi	a0,a0,-2012 # 68f8 <malloc+0xc66>
    20dc:	00004097          	auipc	ra,0x4
    20e0:	afe080e7          	jalr	-1282(ra) # 5bda <printf>
    exit(1);
    20e4:	4505                	li	a0,1
    20e6:	00003097          	auipc	ra,0x3
    20ea:	772080e7          	jalr	1906(ra) # 5858 <exit>

00000000000020ee <kernmem>:
{
    20ee:	715d                	addi	sp,sp,-80
    20f0:	e486                	sd	ra,72(sp)
    20f2:	e0a2                	sd	s0,64(sp)
    20f4:	fc26                	sd	s1,56(sp)
    20f6:	f84a                	sd	s2,48(sp)
    20f8:	f44e                	sd	s3,40(sp)
    20fa:	f052                	sd	s4,32(sp)
    20fc:	ec56                	sd	s5,24(sp)
    20fe:	0880                	addi	s0,sp,80
    2100:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2102:	4485                	li	s1,1
    2104:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    2106:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2108:	69b1                	lui	s3,0xc
    210a:	35098993          	addi	s3,s3,848 # c350 <buf+0x540>
    210e:	1003d937          	lui	s2,0x1003d
    2112:	090e                	slli	s2,s2,0x3
    2114:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002e660>
    pid = fork();
    2118:	00003097          	auipc	ra,0x3
    211c:	738080e7          	jalr	1848(ra) # 5850 <fork>
    if(pid < 0){
    2120:	02054963          	bltz	a0,2152 <kernmem+0x64>
    if(pid == 0){
    2124:	c529                	beqz	a0,216e <kernmem+0x80>
    wait(&xstatus);
    2126:	fbc40513          	addi	a0,s0,-68
    212a:	00003097          	auipc	ra,0x3
    212e:	736080e7          	jalr	1846(ra) # 5860 <wait>
    if(xstatus != -1)  // did kernel kill child?
    2132:	fbc42783          	lw	a5,-68(s0)
    2136:	05579d63          	bne	a5,s5,2190 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    213a:	94ce                	add	s1,s1,s3
    213c:	fd249ee3          	bne	s1,s2,2118 <kernmem+0x2a>
}
    2140:	60a6                	ld	ra,72(sp)
    2142:	6406                	ld	s0,64(sp)
    2144:	74e2                	ld	s1,56(sp)
    2146:	7942                	ld	s2,48(sp)
    2148:	79a2                	ld	s3,40(sp)
    214a:	7a02                	ld	s4,32(sp)
    214c:	6ae2                	ld	s5,24(sp)
    214e:	6161                	addi	sp,sp,80
    2150:	8082                	ret
      printf("%s: fork failed\n", s);
    2152:	85d2                	mv	a1,s4
    2154:	00004517          	auipc	a0,0x4
    2158:	4d450513          	addi	a0,a0,1236 # 6628 <malloc+0x996>
    215c:	00004097          	auipc	ra,0x4
    2160:	a7e080e7          	jalr	-1410(ra) # 5bda <printf>
      exit(1);
    2164:	4505                	li	a0,1
    2166:	00003097          	auipc	ra,0x3
    216a:	6f2080e7          	jalr	1778(ra) # 5858 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    216e:	0004c683          	lbu	a3,0(s1)
    2172:	8626                	mv	a2,s1
    2174:	85d2                	mv	a1,s4
    2176:	00004517          	auipc	a0,0x4
    217a:	79a50513          	addi	a0,a0,1946 # 6910 <malloc+0xc7e>
    217e:	00004097          	auipc	ra,0x4
    2182:	a5c080e7          	jalr	-1444(ra) # 5bda <printf>
      exit(1);
    2186:	4505                	li	a0,1
    2188:	00003097          	auipc	ra,0x3
    218c:	6d0080e7          	jalr	1744(ra) # 5858 <exit>
      exit(1);
    2190:	4505                	li	a0,1
    2192:	00003097          	auipc	ra,0x3
    2196:	6c6080e7          	jalr	1734(ra) # 5858 <exit>

000000000000219a <MAXVAplus>:
{
    219a:	7179                	addi	sp,sp,-48
    219c:	f406                	sd	ra,40(sp)
    219e:	f022                	sd	s0,32(sp)
    21a0:	ec26                	sd	s1,24(sp)
    21a2:	e84a                	sd	s2,16(sp)
    21a4:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    21a6:	4785                	li	a5,1
    21a8:	179a                	slli	a5,a5,0x26
    21aa:	fcf43c23          	sd	a5,-40(s0)
  for( ; a != 0; a <<= 1){
    21ae:	fd843783          	ld	a5,-40(s0)
    21b2:	cf85                	beqz	a5,21ea <MAXVAplus+0x50>
    21b4:	892a                	mv	s2,a0
    if(xstatus != -1)  // did kernel kill child?
    21b6:	54fd                	li	s1,-1
    pid = fork();
    21b8:	00003097          	auipc	ra,0x3
    21bc:	698080e7          	jalr	1688(ra) # 5850 <fork>
    if(pid < 0){
    21c0:	02054b63          	bltz	a0,21f6 <MAXVAplus+0x5c>
    if(pid == 0){
    21c4:	c539                	beqz	a0,2212 <MAXVAplus+0x78>
    wait(&xstatus);
    21c6:	fd440513          	addi	a0,s0,-44
    21ca:	00003097          	auipc	ra,0x3
    21ce:	696080e7          	jalr	1686(ra) # 5860 <wait>
    if(xstatus != -1)  // did kernel kill child?
    21d2:	fd442783          	lw	a5,-44(s0)
    21d6:	06979463          	bne	a5,s1,223e <MAXVAplus+0xa4>
  for( ; a != 0; a <<= 1){
    21da:	fd843783          	ld	a5,-40(s0)
    21de:	0786                	slli	a5,a5,0x1
    21e0:	fcf43c23          	sd	a5,-40(s0)
    21e4:	fd843783          	ld	a5,-40(s0)
    21e8:	fbe1                	bnez	a5,21b8 <MAXVAplus+0x1e>
}
    21ea:	70a2                	ld	ra,40(sp)
    21ec:	7402                	ld	s0,32(sp)
    21ee:	64e2                	ld	s1,24(sp)
    21f0:	6942                	ld	s2,16(sp)
    21f2:	6145                	addi	sp,sp,48
    21f4:	8082                	ret
      printf("%s: fork failed\n", s);
    21f6:	85ca                	mv	a1,s2
    21f8:	00004517          	auipc	a0,0x4
    21fc:	43050513          	addi	a0,a0,1072 # 6628 <malloc+0x996>
    2200:	00004097          	auipc	ra,0x4
    2204:	9da080e7          	jalr	-1574(ra) # 5bda <printf>
      exit(1);
    2208:	4505                	li	a0,1
    220a:	00003097          	auipc	ra,0x3
    220e:	64e080e7          	jalr	1614(ra) # 5858 <exit>
      *(char*)a = 99;
    2212:	fd843783          	ld	a5,-40(s0)
    2216:	06300713          	li	a4,99
    221a:	00e78023          	sb	a4,0(a5) # 3000 <iputtest+0x76>
      printf("%s: oops wrote %x\n", s, a);
    221e:	fd843603          	ld	a2,-40(s0)
    2222:	85ca                	mv	a1,s2
    2224:	00004517          	auipc	a0,0x4
    2228:	70c50513          	addi	a0,a0,1804 # 6930 <malloc+0xc9e>
    222c:	00004097          	auipc	ra,0x4
    2230:	9ae080e7          	jalr	-1618(ra) # 5bda <printf>
      exit(1);
    2234:	4505                	li	a0,1
    2236:	00003097          	auipc	ra,0x3
    223a:	622080e7          	jalr	1570(ra) # 5858 <exit>
      exit(1);
    223e:	4505                	li	a0,1
    2240:	00003097          	auipc	ra,0x3
    2244:	618080e7          	jalr	1560(ra) # 5858 <exit>

0000000000002248 <bigargtest>:
{
    2248:	7179                	addi	sp,sp,-48
    224a:	f406                	sd	ra,40(sp)
    224c:	f022                	sd	s0,32(sp)
    224e:	ec26                	sd	s1,24(sp)
    2250:	1800                	addi	s0,sp,48
    2252:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    2254:	00004517          	auipc	a0,0x4
    2258:	6f450513          	addi	a0,a0,1780 # 6948 <malloc+0xcb6>
    225c:	00003097          	auipc	ra,0x3
    2260:	64c080e7          	jalr	1612(ra) # 58a8 <unlink>
  pid = fork();
    2264:	00003097          	auipc	ra,0x3
    2268:	5ec080e7          	jalr	1516(ra) # 5850 <fork>
  if(pid == 0){
    226c:	c121                	beqz	a0,22ac <bigargtest+0x64>
  } else if(pid < 0){
    226e:	0a054063          	bltz	a0,230e <bigargtest+0xc6>
  wait(&xstatus);
    2272:	fdc40513          	addi	a0,s0,-36
    2276:	00003097          	auipc	ra,0x3
    227a:	5ea080e7          	jalr	1514(ra) # 5860 <wait>
  if(xstatus != 0)
    227e:	fdc42503          	lw	a0,-36(s0)
    2282:	e545                	bnez	a0,232a <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    2284:	4581                	li	a1,0
    2286:	00004517          	auipc	a0,0x4
    228a:	6c250513          	addi	a0,a0,1730 # 6948 <malloc+0xcb6>
    228e:	00003097          	auipc	ra,0x3
    2292:	60a080e7          	jalr	1546(ra) # 5898 <open>
  if(fd < 0){
    2296:	08054e63          	bltz	a0,2332 <bigargtest+0xea>
  close(fd);
    229a:	00003097          	auipc	ra,0x3
    229e:	5e6080e7          	jalr	1510(ra) # 5880 <close>
}
    22a2:	70a2                	ld	ra,40(sp)
    22a4:	7402                	ld	s0,32(sp)
    22a6:	64e2                	ld	s1,24(sp)
    22a8:	6145                	addi	sp,sp,48
    22aa:	8082                	ret
    22ac:	00006797          	auipc	a5,0x6
    22b0:	34c78793          	addi	a5,a5,844 # 85f8 <args.1>
    22b4:	00006697          	auipc	a3,0x6
    22b8:	43c68693          	addi	a3,a3,1084 # 86f0 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    22bc:	00004717          	auipc	a4,0x4
    22c0:	69c70713          	addi	a4,a4,1692 # 6958 <malloc+0xcc6>
    22c4:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    22c6:	07a1                	addi	a5,a5,8
    22c8:	fed79ee3          	bne	a5,a3,22c4 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    22cc:	00006597          	auipc	a1,0x6
    22d0:	32c58593          	addi	a1,a1,812 # 85f8 <args.1>
    22d4:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    22d8:	00004517          	auipc	a0,0x4
    22dc:	ad850513          	addi	a0,a0,-1320 # 5db0 <malloc+0x11e>
    22e0:	00003097          	auipc	ra,0x3
    22e4:	5b0080e7          	jalr	1456(ra) # 5890 <exec>
    fd = open("bigarg-ok", O_CREATE);
    22e8:	20000593          	li	a1,512
    22ec:	00004517          	auipc	a0,0x4
    22f0:	65c50513          	addi	a0,a0,1628 # 6948 <malloc+0xcb6>
    22f4:	00003097          	auipc	ra,0x3
    22f8:	5a4080e7          	jalr	1444(ra) # 5898 <open>
    close(fd);
    22fc:	00003097          	auipc	ra,0x3
    2300:	584080e7          	jalr	1412(ra) # 5880 <close>
    exit(0);
    2304:	4501                	li	a0,0
    2306:	00003097          	auipc	ra,0x3
    230a:	552080e7          	jalr	1362(ra) # 5858 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    230e:	85a6                	mv	a1,s1
    2310:	00004517          	auipc	a0,0x4
    2314:	72850513          	addi	a0,a0,1832 # 6a38 <malloc+0xda6>
    2318:	00004097          	auipc	ra,0x4
    231c:	8c2080e7          	jalr	-1854(ra) # 5bda <printf>
    exit(1);
    2320:	4505                	li	a0,1
    2322:	00003097          	auipc	ra,0x3
    2326:	536080e7          	jalr	1334(ra) # 5858 <exit>
    exit(xstatus);
    232a:	00003097          	auipc	ra,0x3
    232e:	52e080e7          	jalr	1326(ra) # 5858 <exit>
    printf("%s: bigarg test failed!\n", s);
    2332:	85a6                	mv	a1,s1
    2334:	00004517          	auipc	a0,0x4
    2338:	72450513          	addi	a0,a0,1828 # 6a58 <malloc+0xdc6>
    233c:	00004097          	auipc	ra,0x4
    2340:	89e080e7          	jalr	-1890(ra) # 5bda <printf>
    exit(1);
    2344:	4505                	li	a0,1
    2346:	00003097          	auipc	ra,0x3
    234a:	512080e7          	jalr	1298(ra) # 5858 <exit>

000000000000234e <stacktest>:
{
    234e:	7179                	addi	sp,sp,-48
    2350:	f406                	sd	ra,40(sp)
    2352:	f022                	sd	s0,32(sp)
    2354:	ec26                	sd	s1,24(sp)
    2356:	1800                	addi	s0,sp,48
    2358:	84aa                	mv	s1,a0
  pid = fork();
    235a:	00003097          	auipc	ra,0x3
    235e:	4f6080e7          	jalr	1270(ra) # 5850 <fork>
  if(pid == 0) {
    2362:	c115                	beqz	a0,2386 <stacktest+0x38>
  } else if(pid < 0){
    2364:	04054463          	bltz	a0,23ac <stacktest+0x5e>
  wait(&xstatus);
    2368:	fdc40513          	addi	a0,s0,-36
    236c:	00003097          	auipc	ra,0x3
    2370:	4f4080e7          	jalr	1268(ra) # 5860 <wait>
  if(xstatus == -1)  // kernel killed child?
    2374:	fdc42503          	lw	a0,-36(s0)
    2378:	57fd                	li	a5,-1
    237a:	04f50763          	beq	a0,a5,23c8 <stacktest+0x7a>
    exit(xstatus);
    237e:	00003097          	auipc	ra,0x3
    2382:	4da080e7          	jalr	1242(ra) # 5858 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    2386:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    2388:	77fd                	lui	a5,0xfffff
    238a:	97ba                	add	a5,a5,a4
    238c:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff01e0>
    2390:	85a6                	mv	a1,s1
    2392:	00004517          	auipc	a0,0x4
    2396:	6e650513          	addi	a0,a0,1766 # 6a78 <malloc+0xde6>
    239a:	00004097          	auipc	ra,0x4
    239e:	840080e7          	jalr	-1984(ra) # 5bda <printf>
    exit(1);
    23a2:	4505                	li	a0,1
    23a4:	00003097          	auipc	ra,0x3
    23a8:	4b4080e7          	jalr	1204(ra) # 5858 <exit>
    printf("%s: fork failed\n", s);
    23ac:	85a6                	mv	a1,s1
    23ae:	00004517          	auipc	a0,0x4
    23b2:	27a50513          	addi	a0,a0,634 # 6628 <malloc+0x996>
    23b6:	00004097          	auipc	ra,0x4
    23ba:	824080e7          	jalr	-2012(ra) # 5bda <printf>
    exit(1);
    23be:	4505                	li	a0,1
    23c0:	00003097          	auipc	ra,0x3
    23c4:	498080e7          	jalr	1176(ra) # 5858 <exit>
    exit(0);
    23c8:	4501                	li	a0,0
    23ca:	00003097          	auipc	ra,0x3
    23ce:	48e080e7          	jalr	1166(ra) # 5858 <exit>

00000000000023d2 <copyinstr3>:
{
    23d2:	7179                	addi	sp,sp,-48
    23d4:	f406                	sd	ra,40(sp)
    23d6:	f022                	sd	s0,32(sp)
    23d8:	ec26                	sd	s1,24(sp)
    23da:	1800                	addi	s0,sp,48
  sbrk(8192);
    23dc:	6509                	lui	a0,0x2
    23de:	00003097          	auipc	ra,0x3
    23e2:	502080e7          	jalr	1282(ra) # 58e0 <sbrk>
  uint64 top = (uint64) sbrk(0);
    23e6:	4501                	li	a0,0
    23e8:	00003097          	auipc	ra,0x3
    23ec:	4f8080e7          	jalr	1272(ra) # 58e0 <sbrk>
  if((top % PGSIZE) != 0){
    23f0:	03451793          	slli	a5,a0,0x34
    23f4:	e3c9                	bnez	a5,2476 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    23f6:	4501                	li	a0,0
    23f8:	00003097          	auipc	ra,0x3
    23fc:	4e8080e7          	jalr	1256(ra) # 58e0 <sbrk>
  if(top % PGSIZE){
    2400:	03451793          	slli	a5,a0,0x34
    2404:	e3d9                	bnez	a5,248a <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2406:	fff50493          	addi	s1,a0,-1 # 1fff <manywrites+0x13b>
  *b = 'x';
    240a:	07800793          	li	a5,120
    240e:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2412:	8526                	mv	a0,s1
    2414:	00003097          	auipc	ra,0x3
    2418:	494080e7          	jalr	1172(ra) # 58a8 <unlink>
  if(ret != -1){
    241c:	57fd                	li	a5,-1
    241e:	08f51363          	bne	a0,a5,24a4 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    2422:	20100593          	li	a1,513
    2426:	8526                	mv	a0,s1
    2428:	00003097          	auipc	ra,0x3
    242c:	470080e7          	jalr	1136(ra) # 5898 <open>
  if(fd != -1){
    2430:	57fd                	li	a5,-1
    2432:	08f51863          	bne	a0,a5,24c2 <copyinstr3+0xf0>
  ret = link(b, b);
    2436:	85a6                	mv	a1,s1
    2438:	8526                	mv	a0,s1
    243a:	00003097          	auipc	ra,0x3
    243e:	47e080e7          	jalr	1150(ra) # 58b8 <link>
  if(ret != -1){
    2442:	57fd                	li	a5,-1
    2444:	08f51e63          	bne	a0,a5,24e0 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    2448:	00005797          	auipc	a5,0x5
    244c:	2d878793          	addi	a5,a5,728 # 7720 <malloc+0x1a8e>
    2450:	fcf43823          	sd	a5,-48(s0)
    2454:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2458:	fd040593          	addi	a1,s0,-48
    245c:	8526                	mv	a0,s1
    245e:	00003097          	auipc	ra,0x3
    2462:	432080e7          	jalr	1074(ra) # 5890 <exec>
  if(ret != -1){
    2466:	57fd                	li	a5,-1
    2468:	08f51c63          	bne	a0,a5,2500 <copyinstr3+0x12e>
}
    246c:	70a2                	ld	ra,40(sp)
    246e:	7402                	ld	s0,32(sp)
    2470:	64e2                	ld	s1,24(sp)
    2472:	6145                	addi	sp,sp,48
    2474:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2476:	0347d513          	srli	a0,a5,0x34
    247a:	6785                	lui	a5,0x1
    247c:	40a7853b          	subw	a0,a5,a0
    2480:	00003097          	auipc	ra,0x3
    2484:	460080e7          	jalr	1120(ra) # 58e0 <sbrk>
    2488:	b7bd                	j	23f6 <copyinstr3+0x24>
    printf("oops\n");
    248a:	00004517          	auipc	a0,0x4
    248e:	61650513          	addi	a0,a0,1558 # 6aa0 <malloc+0xe0e>
    2492:	00003097          	auipc	ra,0x3
    2496:	748080e7          	jalr	1864(ra) # 5bda <printf>
    exit(1);
    249a:	4505                	li	a0,1
    249c:	00003097          	auipc	ra,0x3
    24a0:	3bc080e7          	jalr	956(ra) # 5858 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    24a4:	862a                	mv	a2,a0
    24a6:	85a6                	mv	a1,s1
    24a8:	00004517          	auipc	a0,0x4
    24ac:	0a050513          	addi	a0,a0,160 # 6548 <malloc+0x8b6>
    24b0:	00003097          	auipc	ra,0x3
    24b4:	72a080e7          	jalr	1834(ra) # 5bda <printf>
    exit(1);
    24b8:	4505                	li	a0,1
    24ba:	00003097          	auipc	ra,0x3
    24be:	39e080e7          	jalr	926(ra) # 5858 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    24c2:	862a                	mv	a2,a0
    24c4:	85a6                	mv	a1,s1
    24c6:	00004517          	auipc	a0,0x4
    24ca:	0a250513          	addi	a0,a0,162 # 6568 <malloc+0x8d6>
    24ce:	00003097          	auipc	ra,0x3
    24d2:	70c080e7          	jalr	1804(ra) # 5bda <printf>
    exit(1);
    24d6:	4505                	li	a0,1
    24d8:	00003097          	auipc	ra,0x3
    24dc:	380080e7          	jalr	896(ra) # 5858 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    24e0:	86aa                	mv	a3,a0
    24e2:	8626                	mv	a2,s1
    24e4:	85a6                	mv	a1,s1
    24e6:	00004517          	auipc	a0,0x4
    24ea:	0a250513          	addi	a0,a0,162 # 6588 <malloc+0x8f6>
    24ee:	00003097          	auipc	ra,0x3
    24f2:	6ec080e7          	jalr	1772(ra) # 5bda <printf>
    exit(1);
    24f6:	4505                	li	a0,1
    24f8:	00003097          	auipc	ra,0x3
    24fc:	360080e7          	jalr	864(ra) # 5858 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2500:	567d                	li	a2,-1
    2502:	85a6                	mv	a1,s1
    2504:	00004517          	auipc	a0,0x4
    2508:	0ac50513          	addi	a0,a0,172 # 65b0 <malloc+0x91e>
    250c:	00003097          	auipc	ra,0x3
    2510:	6ce080e7          	jalr	1742(ra) # 5bda <printf>
    exit(1);
    2514:	4505                	li	a0,1
    2516:	00003097          	auipc	ra,0x3
    251a:	342080e7          	jalr	834(ra) # 5858 <exit>

000000000000251e <rwsbrk>:
{
    251e:	1101                	addi	sp,sp,-32
    2520:	ec06                	sd	ra,24(sp)
    2522:	e822                	sd	s0,16(sp)
    2524:	e426                	sd	s1,8(sp)
    2526:	e04a                	sd	s2,0(sp)
    2528:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    252a:	6509                	lui	a0,0x2
    252c:	00003097          	auipc	ra,0x3
    2530:	3b4080e7          	jalr	948(ra) # 58e0 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    2534:	57fd                	li	a5,-1
    2536:	06f50263          	beq	a0,a5,259a <rwsbrk+0x7c>
    253a:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    253c:	7579                	lui	a0,0xffffe
    253e:	00003097          	auipc	ra,0x3
    2542:	3a2080e7          	jalr	930(ra) # 58e0 <sbrk>
    2546:	57fd                	li	a5,-1
    2548:	06f50663          	beq	a0,a5,25b4 <rwsbrk+0x96>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    254c:	20100593          	li	a1,513
    2550:	00004517          	auipc	a0,0x4
    2554:	59050513          	addi	a0,a0,1424 # 6ae0 <malloc+0xe4e>
    2558:	00003097          	auipc	ra,0x3
    255c:	340080e7          	jalr	832(ra) # 5898 <open>
    2560:	892a                	mv	s2,a0
  if(fd < 0){
    2562:	06054663          	bltz	a0,25ce <rwsbrk+0xb0>
  n = write(fd, (void*)(a+4096), 1024);
    2566:	6785                	lui	a5,0x1
    2568:	94be                	add	s1,s1,a5
    256a:	40000613          	li	a2,1024
    256e:	85a6                	mv	a1,s1
    2570:	00003097          	auipc	ra,0x3
    2574:	308080e7          	jalr	776(ra) # 5878 <write>
    2578:	862a                	mv	a2,a0
  if(n >= 0){
    257a:	06054763          	bltz	a0,25e8 <rwsbrk+0xca>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    257e:	85a6                	mv	a1,s1
    2580:	00004517          	auipc	a0,0x4
    2584:	58050513          	addi	a0,a0,1408 # 6b00 <malloc+0xe6e>
    2588:	00003097          	auipc	ra,0x3
    258c:	652080e7          	jalr	1618(ra) # 5bda <printf>
    exit(1);
    2590:	4505                	li	a0,1
    2592:	00003097          	auipc	ra,0x3
    2596:	2c6080e7          	jalr	710(ra) # 5858 <exit>
    printf("sbrk(rwsbrk) failed\n");
    259a:	00004517          	auipc	a0,0x4
    259e:	50e50513          	addi	a0,a0,1294 # 6aa8 <malloc+0xe16>
    25a2:	00003097          	auipc	ra,0x3
    25a6:	638080e7          	jalr	1592(ra) # 5bda <printf>
    exit(1);
    25aa:	4505                	li	a0,1
    25ac:	00003097          	auipc	ra,0x3
    25b0:	2ac080e7          	jalr	684(ra) # 5858 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    25b4:	00004517          	auipc	a0,0x4
    25b8:	50c50513          	addi	a0,a0,1292 # 6ac0 <malloc+0xe2e>
    25bc:	00003097          	auipc	ra,0x3
    25c0:	61e080e7          	jalr	1566(ra) # 5bda <printf>
    exit(1);
    25c4:	4505                	li	a0,1
    25c6:	00003097          	auipc	ra,0x3
    25ca:	292080e7          	jalr	658(ra) # 5858 <exit>
    printf("open(rwsbrk) failed\n");
    25ce:	00004517          	auipc	a0,0x4
    25d2:	51a50513          	addi	a0,a0,1306 # 6ae8 <malloc+0xe56>
    25d6:	00003097          	auipc	ra,0x3
    25da:	604080e7          	jalr	1540(ra) # 5bda <printf>
    exit(1);
    25de:	4505                	li	a0,1
    25e0:	00003097          	auipc	ra,0x3
    25e4:	278080e7          	jalr	632(ra) # 5858 <exit>
  close(fd);
    25e8:	854a                	mv	a0,s2
    25ea:	00003097          	auipc	ra,0x3
    25ee:	296080e7          	jalr	662(ra) # 5880 <close>
  unlink("rwsbrk");
    25f2:	00004517          	auipc	a0,0x4
    25f6:	4ee50513          	addi	a0,a0,1262 # 6ae0 <malloc+0xe4e>
    25fa:	00003097          	auipc	ra,0x3
    25fe:	2ae080e7          	jalr	686(ra) # 58a8 <unlink>
  fd = open("README", O_RDONLY);
    2602:	4581                	li	a1,0
    2604:	00004517          	auipc	a0,0x4
    2608:	95450513          	addi	a0,a0,-1708 # 5f58 <malloc+0x2c6>
    260c:	00003097          	auipc	ra,0x3
    2610:	28c080e7          	jalr	652(ra) # 5898 <open>
    2614:	892a                	mv	s2,a0
  if(fd < 0){
    2616:	02054963          	bltz	a0,2648 <rwsbrk+0x12a>
  n = read(fd, (void*)(a+4096), 10);
    261a:	4629                	li	a2,10
    261c:	85a6                	mv	a1,s1
    261e:	00003097          	auipc	ra,0x3
    2622:	252080e7          	jalr	594(ra) # 5870 <read>
    2626:	862a                	mv	a2,a0
  if(n >= 0){
    2628:	02054d63          	bltz	a0,2662 <rwsbrk+0x144>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    262c:	85a6                	mv	a1,s1
    262e:	00004517          	auipc	a0,0x4
    2632:	50250513          	addi	a0,a0,1282 # 6b30 <malloc+0xe9e>
    2636:	00003097          	auipc	ra,0x3
    263a:	5a4080e7          	jalr	1444(ra) # 5bda <printf>
    exit(1);
    263e:	4505                	li	a0,1
    2640:	00003097          	auipc	ra,0x3
    2644:	218080e7          	jalr	536(ra) # 5858 <exit>
    printf("open(rwsbrk) failed\n");
    2648:	00004517          	auipc	a0,0x4
    264c:	4a050513          	addi	a0,a0,1184 # 6ae8 <malloc+0xe56>
    2650:	00003097          	auipc	ra,0x3
    2654:	58a080e7          	jalr	1418(ra) # 5bda <printf>
    exit(1);
    2658:	4505                	li	a0,1
    265a:	00003097          	auipc	ra,0x3
    265e:	1fe080e7          	jalr	510(ra) # 5858 <exit>
  close(fd);
    2662:	854a                	mv	a0,s2
    2664:	00003097          	auipc	ra,0x3
    2668:	21c080e7          	jalr	540(ra) # 5880 <close>
  exit(0);
    266c:	4501                	li	a0,0
    266e:	00003097          	auipc	ra,0x3
    2672:	1ea080e7          	jalr	490(ra) # 5858 <exit>

0000000000002676 <sbrkbasic>:
{
    2676:	7139                	addi	sp,sp,-64
    2678:	fc06                	sd	ra,56(sp)
    267a:	f822                	sd	s0,48(sp)
    267c:	f426                	sd	s1,40(sp)
    267e:	f04a                	sd	s2,32(sp)
    2680:	ec4e                	sd	s3,24(sp)
    2682:	e852                	sd	s4,16(sp)
    2684:	0080                	addi	s0,sp,64
    2686:	8a2a                	mv	s4,a0
  pid = fork();
    2688:	00003097          	auipc	ra,0x3
    268c:	1c8080e7          	jalr	456(ra) # 5850 <fork>
  if(pid < 0){
    2690:	02054c63          	bltz	a0,26c8 <sbrkbasic+0x52>
  if(pid == 0){
    2694:	ed21                	bnez	a0,26ec <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    2696:	40000537          	lui	a0,0x40000
    269a:	00003097          	auipc	ra,0x3
    269e:	246080e7          	jalr	582(ra) # 58e0 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    26a2:	57fd                	li	a5,-1
    26a4:	02f50f63          	beq	a0,a5,26e2 <sbrkbasic+0x6c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    26a8:	400007b7          	lui	a5,0x40000
    26ac:	97aa                	add	a5,a5,a0
      *b = 99;
    26ae:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    26b2:	6705                	lui	a4,0x1
      *b = 99;
    26b4:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff11e0>
    for(b = a; b < a+TOOMUCH; b += 4096){
    26b8:	953a                	add	a0,a0,a4
    26ba:	fef51de3          	bne	a0,a5,26b4 <sbrkbasic+0x3e>
    exit(1);
    26be:	4505                	li	a0,1
    26c0:	00003097          	auipc	ra,0x3
    26c4:	198080e7          	jalr	408(ra) # 5858 <exit>
    printf("fork failed in sbrkbasic\n");
    26c8:	00004517          	auipc	a0,0x4
    26cc:	49050513          	addi	a0,a0,1168 # 6b58 <malloc+0xec6>
    26d0:	00003097          	auipc	ra,0x3
    26d4:	50a080e7          	jalr	1290(ra) # 5bda <printf>
    exit(1);
    26d8:	4505                	li	a0,1
    26da:	00003097          	auipc	ra,0x3
    26de:	17e080e7          	jalr	382(ra) # 5858 <exit>
      exit(0);
    26e2:	4501                	li	a0,0
    26e4:	00003097          	auipc	ra,0x3
    26e8:	174080e7          	jalr	372(ra) # 5858 <exit>
  wait(&xstatus);
    26ec:	fcc40513          	addi	a0,s0,-52
    26f0:	00003097          	auipc	ra,0x3
    26f4:	170080e7          	jalr	368(ra) # 5860 <wait>
  if(xstatus == 1){
    26f8:	fcc42703          	lw	a4,-52(s0)
    26fc:	4785                	li	a5,1
    26fe:	00f70d63          	beq	a4,a5,2718 <sbrkbasic+0xa2>
  a = sbrk(0);
    2702:	4501                	li	a0,0
    2704:	00003097          	auipc	ra,0x3
    2708:	1dc080e7          	jalr	476(ra) # 58e0 <sbrk>
    270c:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    270e:	4901                	li	s2,0
    2710:	6985                	lui	s3,0x1
    2712:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1c2>
    2716:	a005                	j	2736 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    2718:	85d2                	mv	a1,s4
    271a:	00004517          	auipc	a0,0x4
    271e:	45e50513          	addi	a0,a0,1118 # 6b78 <malloc+0xee6>
    2722:	00003097          	auipc	ra,0x3
    2726:	4b8080e7          	jalr	1208(ra) # 5bda <printf>
    exit(1);
    272a:	4505                	li	a0,1
    272c:	00003097          	auipc	ra,0x3
    2730:	12c080e7          	jalr	300(ra) # 5858 <exit>
    a = b + 1;
    2734:	84be                	mv	s1,a5
    b = sbrk(1);
    2736:	4505                	li	a0,1
    2738:	00003097          	auipc	ra,0x3
    273c:	1a8080e7          	jalr	424(ra) # 58e0 <sbrk>
    if(b != a){
    2740:	04951c63          	bne	a0,s1,2798 <sbrkbasic+0x122>
    *b = 1;
    2744:	4785                	li	a5,1
    2746:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    274a:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    274e:	2905                	addiw	s2,s2,1
    2750:	ff3912e3          	bne	s2,s3,2734 <sbrkbasic+0xbe>
  pid = fork();
    2754:	00003097          	auipc	ra,0x3
    2758:	0fc080e7          	jalr	252(ra) # 5850 <fork>
    275c:	892a                	mv	s2,a0
  if(pid < 0){
    275e:	04054e63          	bltz	a0,27ba <sbrkbasic+0x144>
  c = sbrk(1);
    2762:	4505                	li	a0,1
    2764:	00003097          	auipc	ra,0x3
    2768:	17c080e7          	jalr	380(ra) # 58e0 <sbrk>
  c = sbrk(1);
    276c:	4505                	li	a0,1
    276e:	00003097          	auipc	ra,0x3
    2772:	172080e7          	jalr	370(ra) # 58e0 <sbrk>
  if(c != a + 1){
    2776:	0489                	addi	s1,s1,2
    2778:	04a48f63          	beq	s1,a0,27d6 <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    277c:	85d2                	mv	a1,s4
    277e:	00004517          	auipc	a0,0x4
    2782:	45a50513          	addi	a0,a0,1114 # 6bd8 <malloc+0xf46>
    2786:	00003097          	auipc	ra,0x3
    278a:	454080e7          	jalr	1108(ra) # 5bda <printf>
    exit(1);
    278e:	4505                	li	a0,1
    2790:	00003097          	auipc	ra,0x3
    2794:	0c8080e7          	jalr	200(ra) # 5858 <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    2798:	872a                	mv	a4,a0
    279a:	86a6                	mv	a3,s1
    279c:	864a                	mv	a2,s2
    279e:	85d2                	mv	a1,s4
    27a0:	00004517          	auipc	a0,0x4
    27a4:	3f850513          	addi	a0,a0,1016 # 6b98 <malloc+0xf06>
    27a8:	00003097          	auipc	ra,0x3
    27ac:	432080e7          	jalr	1074(ra) # 5bda <printf>
      exit(1);
    27b0:	4505                	li	a0,1
    27b2:	00003097          	auipc	ra,0x3
    27b6:	0a6080e7          	jalr	166(ra) # 5858 <exit>
    printf("%s: sbrk test fork failed\n", s);
    27ba:	85d2                	mv	a1,s4
    27bc:	00004517          	auipc	a0,0x4
    27c0:	3fc50513          	addi	a0,a0,1020 # 6bb8 <malloc+0xf26>
    27c4:	00003097          	auipc	ra,0x3
    27c8:	416080e7          	jalr	1046(ra) # 5bda <printf>
    exit(1);
    27cc:	4505                	li	a0,1
    27ce:	00003097          	auipc	ra,0x3
    27d2:	08a080e7          	jalr	138(ra) # 5858 <exit>
  if(pid == 0)
    27d6:	00091763          	bnez	s2,27e4 <sbrkbasic+0x16e>
    exit(0);
    27da:	4501                	li	a0,0
    27dc:	00003097          	auipc	ra,0x3
    27e0:	07c080e7          	jalr	124(ra) # 5858 <exit>
  wait(&xstatus);
    27e4:	fcc40513          	addi	a0,s0,-52
    27e8:	00003097          	auipc	ra,0x3
    27ec:	078080e7          	jalr	120(ra) # 5860 <wait>
  exit(xstatus);
    27f0:	fcc42503          	lw	a0,-52(s0)
    27f4:	00003097          	auipc	ra,0x3
    27f8:	064080e7          	jalr	100(ra) # 5858 <exit>

00000000000027fc <sbrkmuch>:
{
    27fc:	7179                	addi	sp,sp,-48
    27fe:	f406                	sd	ra,40(sp)
    2800:	f022                	sd	s0,32(sp)
    2802:	ec26                	sd	s1,24(sp)
    2804:	e84a                	sd	s2,16(sp)
    2806:	e44e                	sd	s3,8(sp)
    2808:	e052                	sd	s4,0(sp)
    280a:	1800                	addi	s0,sp,48
    280c:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    280e:	4501                	li	a0,0
    2810:	00003097          	auipc	ra,0x3
    2814:	0d0080e7          	jalr	208(ra) # 58e0 <sbrk>
    2818:	892a                	mv	s2,a0
  a = sbrk(0);
    281a:	4501                	li	a0,0
    281c:	00003097          	auipc	ra,0x3
    2820:	0c4080e7          	jalr	196(ra) # 58e0 <sbrk>
    2824:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2826:	06400537          	lui	a0,0x6400
    282a:	9d05                	subw	a0,a0,s1
    282c:	00003097          	auipc	ra,0x3
    2830:	0b4080e7          	jalr	180(ra) # 58e0 <sbrk>
  if (p != a) {
    2834:	0ca49863          	bne	s1,a0,2904 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2838:	4501                	li	a0,0
    283a:	00003097          	auipc	ra,0x3
    283e:	0a6080e7          	jalr	166(ra) # 58e0 <sbrk>
    2842:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2844:	00a4f963          	bgeu	s1,a0,2856 <sbrkmuch+0x5a>
    *pp = 1;
    2848:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    284a:	6705                	lui	a4,0x1
    *pp = 1;
    284c:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2850:	94ba                	add	s1,s1,a4
    2852:	fef4ede3          	bltu	s1,a5,284c <sbrkmuch+0x50>
  *lastaddr = 99;
    2856:	064007b7          	lui	a5,0x6400
    285a:	06300713          	li	a4,99
    285e:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f11df>
  a = sbrk(0);
    2862:	4501                	li	a0,0
    2864:	00003097          	auipc	ra,0x3
    2868:	07c080e7          	jalr	124(ra) # 58e0 <sbrk>
    286c:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    286e:	757d                	lui	a0,0xfffff
    2870:	00003097          	auipc	ra,0x3
    2874:	070080e7          	jalr	112(ra) # 58e0 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    2878:	57fd                	li	a5,-1
    287a:	0af50363          	beq	a0,a5,2920 <sbrkmuch+0x124>
  c = sbrk(0);
    287e:	4501                	li	a0,0
    2880:	00003097          	auipc	ra,0x3
    2884:	060080e7          	jalr	96(ra) # 58e0 <sbrk>
  if(c != a - PGSIZE){
    2888:	77fd                	lui	a5,0xfffff
    288a:	97a6                	add	a5,a5,s1
    288c:	0af51863          	bne	a0,a5,293c <sbrkmuch+0x140>
  a = sbrk(0);
    2890:	4501                	li	a0,0
    2892:	00003097          	auipc	ra,0x3
    2896:	04e080e7          	jalr	78(ra) # 58e0 <sbrk>
    289a:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    289c:	6505                	lui	a0,0x1
    289e:	00003097          	auipc	ra,0x3
    28a2:	042080e7          	jalr	66(ra) # 58e0 <sbrk>
    28a6:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    28a8:	0aa49a63          	bne	s1,a0,295c <sbrkmuch+0x160>
    28ac:	4501                	li	a0,0
    28ae:	00003097          	auipc	ra,0x3
    28b2:	032080e7          	jalr	50(ra) # 58e0 <sbrk>
    28b6:	6785                	lui	a5,0x1
    28b8:	97a6                	add	a5,a5,s1
    28ba:	0af51163          	bne	a0,a5,295c <sbrkmuch+0x160>
  if(*lastaddr == 99){
    28be:	064007b7          	lui	a5,0x6400
    28c2:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f11df>
    28c6:	06300793          	li	a5,99
    28ca:	0af70963          	beq	a4,a5,297c <sbrkmuch+0x180>
  a = sbrk(0);
    28ce:	4501                	li	a0,0
    28d0:	00003097          	auipc	ra,0x3
    28d4:	010080e7          	jalr	16(ra) # 58e0 <sbrk>
    28d8:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    28da:	4501                	li	a0,0
    28dc:	00003097          	auipc	ra,0x3
    28e0:	004080e7          	jalr	4(ra) # 58e0 <sbrk>
    28e4:	40a9053b          	subw	a0,s2,a0
    28e8:	00003097          	auipc	ra,0x3
    28ec:	ff8080e7          	jalr	-8(ra) # 58e0 <sbrk>
  if(c != a){
    28f0:	0aa49463          	bne	s1,a0,2998 <sbrkmuch+0x19c>
}
    28f4:	70a2                	ld	ra,40(sp)
    28f6:	7402                	ld	s0,32(sp)
    28f8:	64e2                	ld	s1,24(sp)
    28fa:	6942                	ld	s2,16(sp)
    28fc:	69a2                	ld	s3,8(sp)
    28fe:	6a02                	ld	s4,0(sp)
    2900:	6145                	addi	sp,sp,48
    2902:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2904:	85ce                	mv	a1,s3
    2906:	00004517          	auipc	a0,0x4
    290a:	2f250513          	addi	a0,a0,754 # 6bf8 <malloc+0xf66>
    290e:	00003097          	auipc	ra,0x3
    2912:	2cc080e7          	jalr	716(ra) # 5bda <printf>
    exit(1);
    2916:	4505                	li	a0,1
    2918:	00003097          	auipc	ra,0x3
    291c:	f40080e7          	jalr	-192(ra) # 5858 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2920:	85ce                	mv	a1,s3
    2922:	00004517          	auipc	a0,0x4
    2926:	31e50513          	addi	a0,a0,798 # 6c40 <malloc+0xfae>
    292a:	00003097          	auipc	ra,0x3
    292e:	2b0080e7          	jalr	688(ra) # 5bda <printf>
    exit(1);
    2932:	4505                	li	a0,1
    2934:	00003097          	auipc	ra,0x3
    2938:	f24080e7          	jalr	-220(ra) # 5858 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    293c:	86aa                	mv	a3,a0
    293e:	8626                	mv	a2,s1
    2940:	85ce                	mv	a1,s3
    2942:	00004517          	auipc	a0,0x4
    2946:	31e50513          	addi	a0,a0,798 # 6c60 <malloc+0xfce>
    294a:	00003097          	auipc	ra,0x3
    294e:	290080e7          	jalr	656(ra) # 5bda <printf>
    exit(1);
    2952:	4505                	li	a0,1
    2954:	00003097          	auipc	ra,0x3
    2958:	f04080e7          	jalr	-252(ra) # 5858 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    295c:	86d2                	mv	a3,s4
    295e:	8626                	mv	a2,s1
    2960:	85ce                	mv	a1,s3
    2962:	00004517          	auipc	a0,0x4
    2966:	33e50513          	addi	a0,a0,830 # 6ca0 <malloc+0x100e>
    296a:	00003097          	auipc	ra,0x3
    296e:	270080e7          	jalr	624(ra) # 5bda <printf>
    exit(1);
    2972:	4505                	li	a0,1
    2974:	00003097          	auipc	ra,0x3
    2978:	ee4080e7          	jalr	-284(ra) # 5858 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    297c:	85ce                	mv	a1,s3
    297e:	00004517          	auipc	a0,0x4
    2982:	35250513          	addi	a0,a0,850 # 6cd0 <malloc+0x103e>
    2986:	00003097          	auipc	ra,0x3
    298a:	254080e7          	jalr	596(ra) # 5bda <printf>
    exit(1);
    298e:	4505                	li	a0,1
    2990:	00003097          	auipc	ra,0x3
    2994:	ec8080e7          	jalr	-312(ra) # 5858 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2998:	86aa                	mv	a3,a0
    299a:	8626                	mv	a2,s1
    299c:	85ce                	mv	a1,s3
    299e:	00004517          	auipc	a0,0x4
    29a2:	36a50513          	addi	a0,a0,874 # 6d08 <malloc+0x1076>
    29a6:	00003097          	auipc	ra,0x3
    29aa:	234080e7          	jalr	564(ra) # 5bda <printf>
    exit(1);
    29ae:	4505                	li	a0,1
    29b0:	00003097          	auipc	ra,0x3
    29b4:	ea8080e7          	jalr	-344(ra) # 5858 <exit>

00000000000029b8 <sbrkarg>:
{
    29b8:	7179                	addi	sp,sp,-48
    29ba:	f406                	sd	ra,40(sp)
    29bc:	f022                	sd	s0,32(sp)
    29be:	ec26                	sd	s1,24(sp)
    29c0:	e84a                	sd	s2,16(sp)
    29c2:	e44e                	sd	s3,8(sp)
    29c4:	1800                	addi	s0,sp,48
    29c6:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    29c8:	6505                	lui	a0,0x1
    29ca:	00003097          	auipc	ra,0x3
    29ce:	f16080e7          	jalr	-234(ra) # 58e0 <sbrk>
    29d2:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    29d4:	20100593          	li	a1,513
    29d8:	00004517          	auipc	a0,0x4
    29dc:	35850513          	addi	a0,a0,856 # 6d30 <malloc+0x109e>
    29e0:	00003097          	auipc	ra,0x3
    29e4:	eb8080e7          	jalr	-328(ra) # 5898 <open>
    29e8:	84aa                	mv	s1,a0
  unlink("sbrk");
    29ea:	00004517          	auipc	a0,0x4
    29ee:	34650513          	addi	a0,a0,838 # 6d30 <malloc+0x109e>
    29f2:	00003097          	auipc	ra,0x3
    29f6:	eb6080e7          	jalr	-330(ra) # 58a8 <unlink>
  if(fd < 0)  {
    29fa:	0404c163          	bltz	s1,2a3c <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    29fe:	6605                	lui	a2,0x1
    2a00:	85ca                	mv	a1,s2
    2a02:	8526                	mv	a0,s1
    2a04:	00003097          	auipc	ra,0x3
    2a08:	e74080e7          	jalr	-396(ra) # 5878 <write>
    2a0c:	04054663          	bltz	a0,2a58 <sbrkarg+0xa0>
  close(fd);
    2a10:	8526                	mv	a0,s1
    2a12:	00003097          	auipc	ra,0x3
    2a16:	e6e080e7          	jalr	-402(ra) # 5880 <close>
  a = sbrk(PGSIZE);
    2a1a:	6505                	lui	a0,0x1
    2a1c:	00003097          	auipc	ra,0x3
    2a20:	ec4080e7          	jalr	-316(ra) # 58e0 <sbrk>
  if(pipe((int *) a) != 0){
    2a24:	00003097          	auipc	ra,0x3
    2a28:	e44080e7          	jalr	-444(ra) # 5868 <pipe>
    2a2c:	e521                	bnez	a0,2a74 <sbrkarg+0xbc>
}
    2a2e:	70a2                	ld	ra,40(sp)
    2a30:	7402                	ld	s0,32(sp)
    2a32:	64e2                	ld	s1,24(sp)
    2a34:	6942                	ld	s2,16(sp)
    2a36:	69a2                	ld	s3,8(sp)
    2a38:	6145                	addi	sp,sp,48
    2a3a:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2a3c:	85ce                	mv	a1,s3
    2a3e:	00004517          	auipc	a0,0x4
    2a42:	2fa50513          	addi	a0,a0,762 # 6d38 <malloc+0x10a6>
    2a46:	00003097          	auipc	ra,0x3
    2a4a:	194080e7          	jalr	404(ra) # 5bda <printf>
    exit(1);
    2a4e:	4505                	li	a0,1
    2a50:	00003097          	auipc	ra,0x3
    2a54:	e08080e7          	jalr	-504(ra) # 5858 <exit>
    printf("%s: write sbrk failed\n", s);
    2a58:	85ce                	mv	a1,s3
    2a5a:	00004517          	auipc	a0,0x4
    2a5e:	2f650513          	addi	a0,a0,758 # 6d50 <malloc+0x10be>
    2a62:	00003097          	auipc	ra,0x3
    2a66:	178080e7          	jalr	376(ra) # 5bda <printf>
    exit(1);
    2a6a:	4505                	li	a0,1
    2a6c:	00003097          	auipc	ra,0x3
    2a70:	dec080e7          	jalr	-532(ra) # 5858 <exit>
    printf("%s: pipe() failed\n", s);
    2a74:	85ce                	mv	a1,s3
    2a76:	00004517          	auipc	a0,0x4
    2a7a:	cba50513          	addi	a0,a0,-838 # 6730 <malloc+0xa9e>
    2a7e:	00003097          	auipc	ra,0x3
    2a82:	15c080e7          	jalr	348(ra) # 5bda <printf>
    exit(1);
    2a86:	4505                	li	a0,1
    2a88:	00003097          	auipc	ra,0x3
    2a8c:	dd0080e7          	jalr	-560(ra) # 5858 <exit>

0000000000002a90 <argptest>:
{
    2a90:	1101                	addi	sp,sp,-32
    2a92:	ec06                	sd	ra,24(sp)
    2a94:	e822                	sd	s0,16(sp)
    2a96:	e426                	sd	s1,8(sp)
    2a98:	e04a                	sd	s2,0(sp)
    2a9a:	1000                	addi	s0,sp,32
    2a9c:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2a9e:	4581                	li	a1,0
    2aa0:	00004517          	auipc	a0,0x4
    2aa4:	2c850513          	addi	a0,a0,712 # 6d68 <malloc+0x10d6>
    2aa8:	00003097          	auipc	ra,0x3
    2aac:	df0080e7          	jalr	-528(ra) # 5898 <open>
  if (fd < 0) {
    2ab0:	02054b63          	bltz	a0,2ae6 <argptest+0x56>
    2ab4:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2ab6:	4501                	li	a0,0
    2ab8:	00003097          	auipc	ra,0x3
    2abc:	e28080e7          	jalr	-472(ra) # 58e0 <sbrk>
    2ac0:	567d                	li	a2,-1
    2ac2:	fff50593          	addi	a1,a0,-1
    2ac6:	8526                	mv	a0,s1
    2ac8:	00003097          	auipc	ra,0x3
    2acc:	da8080e7          	jalr	-600(ra) # 5870 <read>
  close(fd);
    2ad0:	8526                	mv	a0,s1
    2ad2:	00003097          	auipc	ra,0x3
    2ad6:	dae080e7          	jalr	-594(ra) # 5880 <close>
}
    2ada:	60e2                	ld	ra,24(sp)
    2adc:	6442                	ld	s0,16(sp)
    2ade:	64a2                	ld	s1,8(sp)
    2ae0:	6902                	ld	s2,0(sp)
    2ae2:	6105                	addi	sp,sp,32
    2ae4:	8082                	ret
    printf("%s: open failed\n", s);
    2ae6:	85ca                	mv	a1,s2
    2ae8:	00004517          	auipc	a0,0x4
    2aec:	b5850513          	addi	a0,a0,-1192 # 6640 <malloc+0x9ae>
    2af0:	00003097          	auipc	ra,0x3
    2af4:	0ea080e7          	jalr	234(ra) # 5bda <printf>
    exit(1);
    2af8:	4505                	li	a0,1
    2afa:	00003097          	auipc	ra,0x3
    2afe:	d5e080e7          	jalr	-674(ra) # 5858 <exit>

0000000000002b02 <sbrkbugs>:
{
    2b02:	1141                	addi	sp,sp,-16
    2b04:	e406                	sd	ra,8(sp)
    2b06:	e022                	sd	s0,0(sp)
    2b08:	0800                	addi	s0,sp,16
  int pid = fork();
    2b0a:	00003097          	auipc	ra,0x3
    2b0e:	d46080e7          	jalr	-698(ra) # 5850 <fork>
  if(pid < 0){
    2b12:	02054263          	bltz	a0,2b36 <sbrkbugs+0x34>
  if(pid == 0){
    2b16:	ed0d                	bnez	a0,2b50 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2b18:	00003097          	auipc	ra,0x3
    2b1c:	dc8080e7          	jalr	-568(ra) # 58e0 <sbrk>
    sbrk(-sz);
    2b20:	40a0053b          	negw	a0,a0
    2b24:	00003097          	auipc	ra,0x3
    2b28:	dbc080e7          	jalr	-580(ra) # 58e0 <sbrk>
    exit(0);
    2b2c:	4501                	li	a0,0
    2b2e:	00003097          	auipc	ra,0x3
    2b32:	d2a080e7          	jalr	-726(ra) # 5858 <exit>
    printf("fork failed\n");
    2b36:	00004517          	auipc	a0,0x4
    2b3a:	f1250513          	addi	a0,a0,-238 # 6a48 <malloc+0xdb6>
    2b3e:	00003097          	auipc	ra,0x3
    2b42:	09c080e7          	jalr	156(ra) # 5bda <printf>
    exit(1);
    2b46:	4505                	li	a0,1
    2b48:	00003097          	auipc	ra,0x3
    2b4c:	d10080e7          	jalr	-752(ra) # 5858 <exit>
  wait(0);
    2b50:	4501                	li	a0,0
    2b52:	00003097          	auipc	ra,0x3
    2b56:	d0e080e7          	jalr	-754(ra) # 5860 <wait>
  pid = fork();
    2b5a:	00003097          	auipc	ra,0x3
    2b5e:	cf6080e7          	jalr	-778(ra) # 5850 <fork>
  if(pid < 0){
    2b62:	02054563          	bltz	a0,2b8c <sbrkbugs+0x8a>
  if(pid == 0){
    2b66:	e121                	bnez	a0,2ba6 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2b68:	00003097          	auipc	ra,0x3
    2b6c:	d78080e7          	jalr	-648(ra) # 58e0 <sbrk>
    sbrk(-(sz - 3500));
    2b70:	6785                	lui	a5,0x1
    2b72:	dac7879b          	addiw	a5,a5,-596
    2b76:	40a7853b          	subw	a0,a5,a0
    2b7a:	00003097          	auipc	ra,0x3
    2b7e:	d66080e7          	jalr	-666(ra) # 58e0 <sbrk>
    exit(0);
    2b82:	4501                	li	a0,0
    2b84:	00003097          	auipc	ra,0x3
    2b88:	cd4080e7          	jalr	-812(ra) # 5858 <exit>
    printf("fork failed\n");
    2b8c:	00004517          	auipc	a0,0x4
    2b90:	ebc50513          	addi	a0,a0,-324 # 6a48 <malloc+0xdb6>
    2b94:	00003097          	auipc	ra,0x3
    2b98:	046080e7          	jalr	70(ra) # 5bda <printf>
    exit(1);
    2b9c:	4505                	li	a0,1
    2b9e:	00003097          	auipc	ra,0x3
    2ba2:	cba080e7          	jalr	-838(ra) # 5858 <exit>
  wait(0);
    2ba6:	4501                	li	a0,0
    2ba8:	00003097          	auipc	ra,0x3
    2bac:	cb8080e7          	jalr	-840(ra) # 5860 <wait>
  pid = fork();
    2bb0:	00003097          	auipc	ra,0x3
    2bb4:	ca0080e7          	jalr	-864(ra) # 5850 <fork>
  if(pid < 0){
    2bb8:	02054a63          	bltz	a0,2bec <sbrkbugs+0xea>
  if(pid == 0){
    2bbc:	e529                	bnez	a0,2c06 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2bbe:	00003097          	auipc	ra,0x3
    2bc2:	d22080e7          	jalr	-734(ra) # 58e0 <sbrk>
    2bc6:	67ad                	lui	a5,0xb
    2bc8:	8007879b          	addiw	a5,a5,-2048
    2bcc:	40a7853b          	subw	a0,a5,a0
    2bd0:	00003097          	auipc	ra,0x3
    2bd4:	d10080e7          	jalr	-752(ra) # 58e0 <sbrk>
    sbrk(-10);
    2bd8:	5559                	li	a0,-10
    2bda:	00003097          	auipc	ra,0x3
    2bde:	d06080e7          	jalr	-762(ra) # 58e0 <sbrk>
    exit(0);
    2be2:	4501                	li	a0,0
    2be4:	00003097          	auipc	ra,0x3
    2be8:	c74080e7          	jalr	-908(ra) # 5858 <exit>
    printf("fork failed\n");
    2bec:	00004517          	auipc	a0,0x4
    2bf0:	e5c50513          	addi	a0,a0,-420 # 6a48 <malloc+0xdb6>
    2bf4:	00003097          	auipc	ra,0x3
    2bf8:	fe6080e7          	jalr	-26(ra) # 5bda <printf>
    exit(1);
    2bfc:	4505                	li	a0,1
    2bfe:	00003097          	auipc	ra,0x3
    2c02:	c5a080e7          	jalr	-934(ra) # 5858 <exit>
  wait(0);
    2c06:	4501                	li	a0,0
    2c08:	00003097          	auipc	ra,0x3
    2c0c:	c58080e7          	jalr	-936(ra) # 5860 <wait>
  exit(0);
    2c10:	4501                	li	a0,0
    2c12:	00003097          	auipc	ra,0x3
    2c16:	c46080e7          	jalr	-954(ra) # 5858 <exit>

0000000000002c1a <sbrklast>:
{
    2c1a:	7179                	addi	sp,sp,-48
    2c1c:	f406                	sd	ra,40(sp)
    2c1e:	f022                	sd	s0,32(sp)
    2c20:	ec26                	sd	s1,24(sp)
    2c22:	e84a                	sd	s2,16(sp)
    2c24:	e44e                	sd	s3,8(sp)
    2c26:	e052                	sd	s4,0(sp)
    2c28:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    2c2a:	4501                	li	a0,0
    2c2c:	00003097          	auipc	ra,0x3
    2c30:	cb4080e7          	jalr	-844(ra) # 58e0 <sbrk>
  if((top % 4096) != 0)
    2c34:	03451793          	slli	a5,a0,0x34
    2c38:	ebd9                	bnez	a5,2cce <sbrklast+0xb4>
  sbrk(4096);
    2c3a:	6505                	lui	a0,0x1
    2c3c:	00003097          	auipc	ra,0x3
    2c40:	ca4080e7          	jalr	-860(ra) # 58e0 <sbrk>
  sbrk(10);
    2c44:	4529                	li	a0,10
    2c46:	00003097          	auipc	ra,0x3
    2c4a:	c9a080e7          	jalr	-870(ra) # 58e0 <sbrk>
  sbrk(-20);
    2c4e:	5531                	li	a0,-20
    2c50:	00003097          	auipc	ra,0x3
    2c54:	c90080e7          	jalr	-880(ra) # 58e0 <sbrk>
  top = (uint64) sbrk(0);
    2c58:	4501                	li	a0,0
    2c5a:	00003097          	auipc	ra,0x3
    2c5e:	c86080e7          	jalr	-890(ra) # 58e0 <sbrk>
    2c62:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    2c64:	fc050913          	addi	s2,a0,-64 # fc0 <bigdir+0x4a>
  p[0] = 'x';
    2c68:	07800a13          	li	s4,120
    2c6c:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2c70:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2c74:	20200593          	li	a1,514
    2c78:	854a                	mv	a0,s2
    2c7a:	00003097          	auipc	ra,0x3
    2c7e:	c1e080e7          	jalr	-994(ra) # 5898 <open>
    2c82:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2c84:	4605                	li	a2,1
    2c86:	85ca                	mv	a1,s2
    2c88:	00003097          	auipc	ra,0x3
    2c8c:	bf0080e7          	jalr	-1040(ra) # 5878 <write>
  close(fd);
    2c90:	854e                	mv	a0,s3
    2c92:	00003097          	auipc	ra,0x3
    2c96:	bee080e7          	jalr	-1042(ra) # 5880 <close>
  fd = open(p, O_RDWR);
    2c9a:	4589                	li	a1,2
    2c9c:	854a                	mv	a0,s2
    2c9e:	00003097          	auipc	ra,0x3
    2ca2:	bfa080e7          	jalr	-1030(ra) # 5898 <open>
  p[0] = '\0';
    2ca6:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2caa:	4605                	li	a2,1
    2cac:	85ca                	mv	a1,s2
    2cae:	00003097          	auipc	ra,0x3
    2cb2:	bc2080e7          	jalr	-1086(ra) # 5870 <read>
  if(p[0] != 'x')
    2cb6:	fc04c783          	lbu	a5,-64(s1)
    2cba:	03479463          	bne	a5,s4,2ce2 <sbrklast+0xc8>
}
    2cbe:	70a2                	ld	ra,40(sp)
    2cc0:	7402                	ld	s0,32(sp)
    2cc2:	64e2                	ld	s1,24(sp)
    2cc4:	6942                	ld	s2,16(sp)
    2cc6:	69a2                	ld	s3,8(sp)
    2cc8:	6a02                	ld	s4,0(sp)
    2cca:	6145                	addi	sp,sp,48
    2ccc:	8082                	ret
    sbrk(4096 - (top % 4096));
    2cce:	0347d513          	srli	a0,a5,0x34
    2cd2:	6785                	lui	a5,0x1
    2cd4:	40a7853b          	subw	a0,a5,a0
    2cd8:	00003097          	auipc	ra,0x3
    2cdc:	c08080e7          	jalr	-1016(ra) # 58e0 <sbrk>
    2ce0:	bfa9                	j	2c3a <sbrklast+0x20>
    exit(1);
    2ce2:	4505                	li	a0,1
    2ce4:	00003097          	auipc	ra,0x3
    2ce8:	b74080e7          	jalr	-1164(ra) # 5858 <exit>

0000000000002cec <sbrk8000>:
{
    2cec:	1141                	addi	sp,sp,-16
    2cee:	e406                	sd	ra,8(sp)
    2cf0:	e022                	sd	s0,0(sp)
    2cf2:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    2cf4:	80000537          	lui	a0,0x80000
    2cf8:	0511                	addi	a0,a0,4
    2cfa:	00003097          	auipc	ra,0x3
    2cfe:	be6080e7          	jalr	-1050(ra) # 58e0 <sbrk>
  volatile char *top = sbrk(0);
    2d02:	4501                	li	a0,0
    2d04:	00003097          	auipc	ra,0x3
    2d08:	bdc080e7          	jalr	-1060(ra) # 58e0 <sbrk>
  *(top-1) = *(top-1) + 1;
    2d0c:	fff54783          	lbu	a5,-1(a0) # ffffffff7fffffff <__BSS_END__+0xffffffff7fff11df>
    2d10:	2785                	addiw	a5,a5,1
    2d12:	0ff7f793          	zext.b	a5,a5
    2d16:	fef50fa3          	sb	a5,-1(a0)
}
    2d1a:	60a2                	ld	ra,8(sp)
    2d1c:	6402                	ld	s0,0(sp)
    2d1e:	0141                	addi	sp,sp,16
    2d20:	8082                	ret

0000000000002d22 <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2d22:	715d                	addi	sp,sp,-80
    2d24:	e486                	sd	ra,72(sp)
    2d26:	e0a2                	sd	s0,64(sp)
    2d28:	fc26                	sd	s1,56(sp)
    2d2a:	f84a                	sd	s2,48(sp)
    2d2c:	f44e                	sd	s3,40(sp)
    2d2e:	f052                	sd	s4,32(sp)
    2d30:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2d32:	4901                	li	s2,0
    2d34:	49bd                	li	s3,15
    int pid = fork();
    2d36:	00003097          	auipc	ra,0x3
    2d3a:	b1a080e7          	jalr	-1254(ra) # 5850 <fork>
    2d3e:	84aa                	mv	s1,a0
    if(pid < 0){
    2d40:	02054063          	bltz	a0,2d60 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2d44:	c91d                	beqz	a0,2d7a <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2d46:	4501                	li	a0,0
    2d48:	00003097          	auipc	ra,0x3
    2d4c:	b18080e7          	jalr	-1256(ra) # 5860 <wait>
  for(int avail = 0; avail < 15; avail++){
    2d50:	2905                	addiw	s2,s2,1
    2d52:	ff3912e3          	bne	s2,s3,2d36 <execout+0x14>
    }
  }

  exit(0);
    2d56:	4501                	li	a0,0
    2d58:	00003097          	auipc	ra,0x3
    2d5c:	b00080e7          	jalr	-1280(ra) # 5858 <exit>
      printf("fork failed\n");
    2d60:	00004517          	auipc	a0,0x4
    2d64:	ce850513          	addi	a0,a0,-792 # 6a48 <malloc+0xdb6>
    2d68:	00003097          	auipc	ra,0x3
    2d6c:	e72080e7          	jalr	-398(ra) # 5bda <printf>
      exit(1);
    2d70:	4505                	li	a0,1
    2d72:	00003097          	auipc	ra,0x3
    2d76:	ae6080e7          	jalr	-1306(ra) # 5858 <exit>
        if(a == 0xffffffffffffffffLL)
    2d7a:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2d7c:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2d7e:	6505                	lui	a0,0x1
    2d80:	00003097          	auipc	ra,0x3
    2d84:	b60080e7          	jalr	-1184(ra) # 58e0 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2d88:	01350763          	beq	a0,s3,2d96 <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2d8c:	6785                	lui	a5,0x1
    2d8e:	97aa                	add	a5,a5,a0
    2d90:	ff478fa3          	sb	s4,-1(a5) # fff <bigdir+0x89>
      while(1){
    2d94:	b7ed                	j	2d7e <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2d96:	01205a63          	blez	s2,2daa <execout+0x88>
        sbrk(-4096);
    2d9a:	757d                	lui	a0,0xfffff
    2d9c:	00003097          	auipc	ra,0x3
    2da0:	b44080e7          	jalr	-1212(ra) # 58e0 <sbrk>
      for(int i = 0; i < avail; i++)
    2da4:	2485                	addiw	s1,s1,1
    2da6:	ff249ae3          	bne	s1,s2,2d9a <execout+0x78>
      close(1);
    2daa:	4505                	li	a0,1
    2dac:	00003097          	auipc	ra,0x3
    2db0:	ad4080e7          	jalr	-1324(ra) # 5880 <close>
      char *args[] = { "echo", "x", 0 };
    2db4:	00003517          	auipc	a0,0x3
    2db8:	ffc50513          	addi	a0,a0,-4 # 5db0 <malloc+0x11e>
    2dbc:	faa43c23          	sd	a0,-72(s0)
    2dc0:	00003797          	auipc	a5,0x3
    2dc4:	06078793          	addi	a5,a5,96 # 5e20 <malloc+0x18e>
    2dc8:	fcf43023          	sd	a5,-64(s0)
    2dcc:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2dd0:	fb840593          	addi	a1,s0,-72
    2dd4:	00003097          	auipc	ra,0x3
    2dd8:	abc080e7          	jalr	-1348(ra) # 5890 <exec>
      exit(0);
    2ddc:	4501                	li	a0,0
    2dde:	00003097          	auipc	ra,0x3
    2de2:	a7a080e7          	jalr	-1414(ra) # 5858 <exit>

0000000000002de6 <fourteen>:
{
    2de6:	1101                	addi	sp,sp,-32
    2de8:	ec06                	sd	ra,24(sp)
    2dea:	e822                	sd	s0,16(sp)
    2dec:	e426                	sd	s1,8(sp)
    2dee:	1000                	addi	s0,sp,32
    2df0:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2df2:	00004517          	auipc	a0,0x4
    2df6:	14e50513          	addi	a0,a0,334 # 6f40 <malloc+0x12ae>
    2dfa:	00003097          	auipc	ra,0x3
    2dfe:	ac6080e7          	jalr	-1338(ra) # 58c0 <mkdir>
    2e02:	e165                	bnez	a0,2ee2 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2e04:	00004517          	auipc	a0,0x4
    2e08:	f9450513          	addi	a0,a0,-108 # 6d98 <malloc+0x1106>
    2e0c:	00003097          	auipc	ra,0x3
    2e10:	ab4080e7          	jalr	-1356(ra) # 58c0 <mkdir>
    2e14:	e56d                	bnez	a0,2efe <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2e16:	20000593          	li	a1,512
    2e1a:	00004517          	auipc	a0,0x4
    2e1e:	fd650513          	addi	a0,a0,-42 # 6df0 <malloc+0x115e>
    2e22:	00003097          	auipc	ra,0x3
    2e26:	a76080e7          	jalr	-1418(ra) # 5898 <open>
  if(fd < 0){
    2e2a:	0e054863          	bltz	a0,2f1a <fourteen+0x134>
  close(fd);
    2e2e:	00003097          	auipc	ra,0x3
    2e32:	a52080e7          	jalr	-1454(ra) # 5880 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2e36:	4581                	li	a1,0
    2e38:	00004517          	auipc	a0,0x4
    2e3c:	03050513          	addi	a0,a0,48 # 6e68 <malloc+0x11d6>
    2e40:	00003097          	auipc	ra,0x3
    2e44:	a58080e7          	jalr	-1448(ra) # 5898 <open>
  if(fd < 0){
    2e48:	0e054763          	bltz	a0,2f36 <fourteen+0x150>
  close(fd);
    2e4c:	00003097          	auipc	ra,0x3
    2e50:	a34080e7          	jalr	-1484(ra) # 5880 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2e54:	00004517          	auipc	a0,0x4
    2e58:	08450513          	addi	a0,a0,132 # 6ed8 <malloc+0x1246>
    2e5c:	00003097          	auipc	ra,0x3
    2e60:	a64080e7          	jalr	-1436(ra) # 58c0 <mkdir>
    2e64:	c57d                	beqz	a0,2f52 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2e66:	00004517          	auipc	a0,0x4
    2e6a:	0ca50513          	addi	a0,a0,202 # 6f30 <malloc+0x129e>
    2e6e:	00003097          	auipc	ra,0x3
    2e72:	a52080e7          	jalr	-1454(ra) # 58c0 <mkdir>
    2e76:	cd65                	beqz	a0,2f6e <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2e78:	00004517          	auipc	a0,0x4
    2e7c:	0b850513          	addi	a0,a0,184 # 6f30 <malloc+0x129e>
    2e80:	00003097          	auipc	ra,0x3
    2e84:	a28080e7          	jalr	-1496(ra) # 58a8 <unlink>
  unlink("12345678901234/12345678901234");
    2e88:	00004517          	auipc	a0,0x4
    2e8c:	05050513          	addi	a0,a0,80 # 6ed8 <malloc+0x1246>
    2e90:	00003097          	auipc	ra,0x3
    2e94:	a18080e7          	jalr	-1512(ra) # 58a8 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2e98:	00004517          	auipc	a0,0x4
    2e9c:	fd050513          	addi	a0,a0,-48 # 6e68 <malloc+0x11d6>
    2ea0:	00003097          	auipc	ra,0x3
    2ea4:	a08080e7          	jalr	-1528(ra) # 58a8 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2ea8:	00004517          	auipc	a0,0x4
    2eac:	f4850513          	addi	a0,a0,-184 # 6df0 <malloc+0x115e>
    2eb0:	00003097          	auipc	ra,0x3
    2eb4:	9f8080e7          	jalr	-1544(ra) # 58a8 <unlink>
  unlink("12345678901234/123456789012345");
    2eb8:	00004517          	auipc	a0,0x4
    2ebc:	ee050513          	addi	a0,a0,-288 # 6d98 <malloc+0x1106>
    2ec0:	00003097          	auipc	ra,0x3
    2ec4:	9e8080e7          	jalr	-1560(ra) # 58a8 <unlink>
  unlink("12345678901234");
    2ec8:	00004517          	auipc	a0,0x4
    2ecc:	07850513          	addi	a0,a0,120 # 6f40 <malloc+0x12ae>
    2ed0:	00003097          	auipc	ra,0x3
    2ed4:	9d8080e7          	jalr	-1576(ra) # 58a8 <unlink>
}
    2ed8:	60e2                	ld	ra,24(sp)
    2eda:	6442                	ld	s0,16(sp)
    2edc:	64a2                	ld	s1,8(sp)
    2ede:	6105                	addi	sp,sp,32
    2ee0:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2ee2:	85a6                	mv	a1,s1
    2ee4:	00004517          	auipc	a0,0x4
    2ee8:	e8c50513          	addi	a0,a0,-372 # 6d70 <malloc+0x10de>
    2eec:	00003097          	auipc	ra,0x3
    2ef0:	cee080e7          	jalr	-786(ra) # 5bda <printf>
    exit(1);
    2ef4:	4505                	li	a0,1
    2ef6:	00003097          	auipc	ra,0x3
    2efa:	962080e7          	jalr	-1694(ra) # 5858 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2efe:	85a6                	mv	a1,s1
    2f00:	00004517          	auipc	a0,0x4
    2f04:	eb850513          	addi	a0,a0,-328 # 6db8 <malloc+0x1126>
    2f08:	00003097          	auipc	ra,0x3
    2f0c:	cd2080e7          	jalr	-814(ra) # 5bda <printf>
    exit(1);
    2f10:	4505                	li	a0,1
    2f12:	00003097          	auipc	ra,0x3
    2f16:	946080e7          	jalr	-1722(ra) # 5858 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2f1a:	85a6                	mv	a1,s1
    2f1c:	00004517          	auipc	a0,0x4
    2f20:	f0450513          	addi	a0,a0,-252 # 6e20 <malloc+0x118e>
    2f24:	00003097          	auipc	ra,0x3
    2f28:	cb6080e7          	jalr	-842(ra) # 5bda <printf>
    exit(1);
    2f2c:	4505                	li	a0,1
    2f2e:	00003097          	auipc	ra,0x3
    2f32:	92a080e7          	jalr	-1750(ra) # 5858 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2f36:	85a6                	mv	a1,s1
    2f38:	00004517          	auipc	a0,0x4
    2f3c:	f6050513          	addi	a0,a0,-160 # 6e98 <malloc+0x1206>
    2f40:	00003097          	auipc	ra,0x3
    2f44:	c9a080e7          	jalr	-870(ra) # 5bda <printf>
    exit(1);
    2f48:	4505                	li	a0,1
    2f4a:	00003097          	auipc	ra,0x3
    2f4e:	90e080e7          	jalr	-1778(ra) # 5858 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2f52:	85a6                	mv	a1,s1
    2f54:	00004517          	auipc	a0,0x4
    2f58:	fa450513          	addi	a0,a0,-92 # 6ef8 <malloc+0x1266>
    2f5c:	00003097          	auipc	ra,0x3
    2f60:	c7e080e7          	jalr	-898(ra) # 5bda <printf>
    exit(1);
    2f64:	4505                	li	a0,1
    2f66:	00003097          	auipc	ra,0x3
    2f6a:	8f2080e7          	jalr	-1806(ra) # 5858 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2f6e:	85a6                	mv	a1,s1
    2f70:	00004517          	auipc	a0,0x4
    2f74:	fe050513          	addi	a0,a0,-32 # 6f50 <malloc+0x12be>
    2f78:	00003097          	auipc	ra,0x3
    2f7c:	c62080e7          	jalr	-926(ra) # 5bda <printf>
    exit(1);
    2f80:	4505                	li	a0,1
    2f82:	00003097          	auipc	ra,0x3
    2f86:	8d6080e7          	jalr	-1834(ra) # 5858 <exit>

0000000000002f8a <iputtest>:
{
    2f8a:	1101                	addi	sp,sp,-32
    2f8c:	ec06                	sd	ra,24(sp)
    2f8e:	e822                	sd	s0,16(sp)
    2f90:	e426                	sd	s1,8(sp)
    2f92:	1000                	addi	s0,sp,32
    2f94:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2f96:	00004517          	auipc	a0,0x4
    2f9a:	ff250513          	addi	a0,a0,-14 # 6f88 <malloc+0x12f6>
    2f9e:	00003097          	auipc	ra,0x3
    2fa2:	922080e7          	jalr	-1758(ra) # 58c0 <mkdir>
    2fa6:	04054563          	bltz	a0,2ff0 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2faa:	00004517          	auipc	a0,0x4
    2fae:	fde50513          	addi	a0,a0,-34 # 6f88 <malloc+0x12f6>
    2fb2:	00003097          	auipc	ra,0x3
    2fb6:	916080e7          	jalr	-1770(ra) # 58c8 <chdir>
    2fba:	04054963          	bltz	a0,300c <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2fbe:	00004517          	auipc	a0,0x4
    2fc2:	00a50513          	addi	a0,a0,10 # 6fc8 <malloc+0x1336>
    2fc6:	00003097          	auipc	ra,0x3
    2fca:	8e2080e7          	jalr	-1822(ra) # 58a8 <unlink>
    2fce:	04054d63          	bltz	a0,3028 <iputtest+0x9e>
  if(chdir("/") < 0){
    2fd2:	00004517          	auipc	a0,0x4
    2fd6:	02650513          	addi	a0,a0,38 # 6ff8 <malloc+0x1366>
    2fda:	00003097          	auipc	ra,0x3
    2fde:	8ee080e7          	jalr	-1810(ra) # 58c8 <chdir>
    2fe2:	06054163          	bltz	a0,3044 <iputtest+0xba>
}
    2fe6:	60e2                	ld	ra,24(sp)
    2fe8:	6442                	ld	s0,16(sp)
    2fea:	64a2                	ld	s1,8(sp)
    2fec:	6105                	addi	sp,sp,32
    2fee:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2ff0:	85a6                	mv	a1,s1
    2ff2:	00004517          	auipc	a0,0x4
    2ff6:	f9e50513          	addi	a0,a0,-98 # 6f90 <malloc+0x12fe>
    2ffa:	00003097          	auipc	ra,0x3
    2ffe:	be0080e7          	jalr	-1056(ra) # 5bda <printf>
    exit(1);
    3002:	4505                	li	a0,1
    3004:	00003097          	auipc	ra,0x3
    3008:	854080e7          	jalr	-1964(ra) # 5858 <exit>
    printf("%s: chdir iputdir failed\n", s);
    300c:	85a6                	mv	a1,s1
    300e:	00004517          	auipc	a0,0x4
    3012:	f9a50513          	addi	a0,a0,-102 # 6fa8 <malloc+0x1316>
    3016:	00003097          	auipc	ra,0x3
    301a:	bc4080e7          	jalr	-1084(ra) # 5bda <printf>
    exit(1);
    301e:	4505                	li	a0,1
    3020:	00003097          	auipc	ra,0x3
    3024:	838080e7          	jalr	-1992(ra) # 5858 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    3028:	85a6                	mv	a1,s1
    302a:	00004517          	auipc	a0,0x4
    302e:	fae50513          	addi	a0,a0,-82 # 6fd8 <malloc+0x1346>
    3032:	00003097          	auipc	ra,0x3
    3036:	ba8080e7          	jalr	-1112(ra) # 5bda <printf>
    exit(1);
    303a:	4505                	li	a0,1
    303c:	00003097          	auipc	ra,0x3
    3040:	81c080e7          	jalr	-2020(ra) # 5858 <exit>
    printf("%s: chdir / failed\n", s);
    3044:	85a6                	mv	a1,s1
    3046:	00004517          	auipc	a0,0x4
    304a:	fba50513          	addi	a0,a0,-70 # 7000 <malloc+0x136e>
    304e:	00003097          	auipc	ra,0x3
    3052:	b8c080e7          	jalr	-1140(ra) # 5bda <printf>
    exit(1);
    3056:	4505                	li	a0,1
    3058:	00003097          	auipc	ra,0x3
    305c:	800080e7          	jalr	-2048(ra) # 5858 <exit>

0000000000003060 <exitiputtest>:
{
    3060:	7179                	addi	sp,sp,-48
    3062:	f406                	sd	ra,40(sp)
    3064:	f022                	sd	s0,32(sp)
    3066:	ec26                	sd	s1,24(sp)
    3068:	1800                	addi	s0,sp,48
    306a:	84aa                	mv	s1,a0
  pid = fork();
    306c:	00002097          	auipc	ra,0x2
    3070:	7e4080e7          	jalr	2020(ra) # 5850 <fork>
  if(pid < 0){
    3074:	04054663          	bltz	a0,30c0 <exitiputtest+0x60>
  if(pid == 0){
    3078:	ed45                	bnez	a0,3130 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    307a:	00004517          	auipc	a0,0x4
    307e:	f0e50513          	addi	a0,a0,-242 # 6f88 <malloc+0x12f6>
    3082:	00003097          	auipc	ra,0x3
    3086:	83e080e7          	jalr	-1986(ra) # 58c0 <mkdir>
    308a:	04054963          	bltz	a0,30dc <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    308e:	00004517          	auipc	a0,0x4
    3092:	efa50513          	addi	a0,a0,-262 # 6f88 <malloc+0x12f6>
    3096:	00003097          	auipc	ra,0x3
    309a:	832080e7          	jalr	-1998(ra) # 58c8 <chdir>
    309e:	04054d63          	bltz	a0,30f8 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    30a2:	00004517          	auipc	a0,0x4
    30a6:	f2650513          	addi	a0,a0,-218 # 6fc8 <malloc+0x1336>
    30aa:	00002097          	auipc	ra,0x2
    30ae:	7fe080e7          	jalr	2046(ra) # 58a8 <unlink>
    30b2:	06054163          	bltz	a0,3114 <exitiputtest+0xb4>
    exit(0);
    30b6:	4501                	li	a0,0
    30b8:	00002097          	auipc	ra,0x2
    30bc:	7a0080e7          	jalr	1952(ra) # 5858 <exit>
    printf("%s: fork failed\n", s);
    30c0:	85a6                	mv	a1,s1
    30c2:	00003517          	auipc	a0,0x3
    30c6:	56650513          	addi	a0,a0,1382 # 6628 <malloc+0x996>
    30ca:	00003097          	auipc	ra,0x3
    30ce:	b10080e7          	jalr	-1264(ra) # 5bda <printf>
    exit(1);
    30d2:	4505                	li	a0,1
    30d4:	00002097          	auipc	ra,0x2
    30d8:	784080e7          	jalr	1924(ra) # 5858 <exit>
      printf("%s: mkdir failed\n", s);
    30dc:	85a6                	mv	a1,s1
    30de:	00004517          	auipc	a0,0x4
    30e2:	eb250513          	addi	a0,a0,-334 # 6f90 <malloc+0x12fe>
    30e6:	00003097          	auipc	ra,0x3
    30ea:	af4080e7          	jalr	-1292(ra) # 5bda <printf>
      exit(1);
    30ee:	4505                	li	a0,1
    30f0:	00002097          	auipc	ra,0x2
    30f4:	768080e7          	jalr	1896(ra) # 5858 <exit>
      printf("%s: child chdir failed\n", s);
    30f8:	85a6                	mv	a1,s1
    30fa:	00004517          	auipc	a0,0x4
    30fe:	f1e50513          	addi	a0,a0,-226 # 7018 <malloc+0x1386>
    3102:	00003097          	auipc	ra,0x3
    3106:	ad8080e7          	jalr	-1320(ra) # 5bda <printf>
      exit(1);
    310a:	4505                	li	a0,1
    310c:	00002097          	auipc	ra,0x2
    3110:	74c080e7          	jalr	1868(ra) # 5858 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    3114:	85a6                	mv	a1,s1
    3116:	00004517          	auipc	a0,0x4
    311a:	ec250513          	addi	a0,a0,-318 # 6fd8 <malloc+0x1346>
    311e:	00003097          	auipc	ra,0x3
    3122:	abc080e7          	jalr	-1348(ra) # 5bda <printf>
      exit(1);
    3126:	4505                	li	a0,1
    3128:	00002097          	auipc	ra,0x2
    312c:	730080e7          	jalr	1840(ra) # 5858 <exit>
  wait(&xstatus);
    3130:	fdc40513          	addi	a0,s0,-36
    3134:	00002097          	auipc	ra,0x2
    3138:	72c080e7          	jalr	1836(ra) # 5860 <wait>
  exit(xstatus);
    313c:	fdc42503          	lw	a0,-36(s0)
    3140:	00002097          	auipc	ra,0x2
    3144:	718080e7          	jalr	1816(ra) # 5858 <exit>

0000000000003148 <dirtest>:
{
    3148:	1101                	addi	sp,sp,-32
    314a:	ec06                	sd	ra,24(sp)
    314c:	e822                	sd	s0,16(sp)
    314e:	e426                	sd	s1,8(sp)
    3150:	1000                	addi	s0,sp,32
    3152:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    3154:	00004517          	auipc	a0,0x4
    3158:	edc50513          	addi	a0,a0,-292 # 7030 <malloc+0x139e>
    315c:	00002097          	auipc	ra,0x2
    3160:	764080e7          	jalr	1892(ra) # 58c0 <mkdir>
    3164:	04054563          	bltz	a0,31ae <dirtest+0x66>
  if(chdir("dir0") < 0){
    3168:	00004517          	auipc	a0,0x4
    316c:	ec850513          	addi	a0,a0,-312 # 7030 <malloc+0x139e>
    3170:	00002097          	auipc	ra,0x2
    3174:	758080e7          	jalr	1880(ra) # 58c8 <chdir>
    3178:	04054963          	bltz	a0,31ca <dirtest+0x82>
  if(chdir("..") < 0){
    317c:	00004517          	auipc	a0,0x4
    3180:	ed450513          	addi	a0,a0,-300 # 7050 <malloc+0x13be>
    3184:	00002097          	auipc	ra,0x2
    3188:	744080e7          	jalr	1860(ra) # 58c8 <chdir>
    318c:	04054d63          	bltz	a0,31e6 <dirtest+0x9e>
  if(unlink("dir0") < 0){
    3190:	00004517          	auipc	a0,0x4
    3194:	ea050513          	addi	a0,a0,-352 # 7030 <malloc+0x139e>
    3198:	00002097          	auipc	ra,0x2
    319c:	710080e7          	jalr	1808(ra) # 58a8 <unlink>
    31a0:	06054163          	bltz	a0,3202 <dirtest+0xba>
}
    31a4:	60e2                	ld	ra,24(sp)
    31a6:	6442                	ld	s0,16(sp)
    31a8:	64a2                	ld	s1,8(sp)
    31aa:	6105                	addi	sp,sp,32
    31ac:	8082                	ret
    printf("%s: mkdir failed\n", s);
    31ae:	85a6                	mv	a1,s1
    31b0:	00004517          	auipc	a0,0x4
    31b4:	de050513          	addi	a0,a0,-544 # 6f90 <malloc+0x12fe>
    31b8:	00003097          	auipc	ra,0x3
    31bc:	a22080e7          	jalr	-1502(ra) # 5bda <printf>
    exit(1);
    31c0:	4505                	li	a0,1
    31c2:	00002097          	auipc	ra,0x2
    31c6:	696080e7          	jalr	1686(ra) # 5858 <exit>
    printf("%s: chdir dir0 failed\n", s);
    31ca:	85a6                	mv	a1,s1
    31cc:	00004517          	auipc	a0,0x4
    31d0:	e6c50513          	addi	a0,a0,-404 # 7038 <malloc+0x13a6>
    31d4:	00003097          	auipc	ra,0x3
    31d8:	a06080e7          	jalr	-1530(ra) # 5bda <printf>
    exit(1);
    31dc:	4505                	li	a0,1
    31de:	00002097          	auipc	ra,0x2
    31e2:	67a080e7          	jalr	1658(ra) # 5858 <exit>
    printf("%s: chdir .. failed\n", s);
    31e6:	85a6                	mv	a1,s1
    31e8:	00004517          	auipc	a0,0x4
    31ec:	e7050513          	addi	a0,a0,-400 # 7058 <malloc+0x13c6>
    31f0:	00003097          	auipc	ra,0x3
    31f4:	9ea080e7          	jalr	-1558(ra) # 5bda <printf>
    exit(1);
    31f8:	4505                	li	a0,1
    31fa:	00002097          	auipc	ra,0x2
    31fe:	65e080e7          	jalr	1630(ra) # 5858 <exit>
    printf("%s: unlink dir0 failed\n", s);
    3202:	85a6                	mv	a1,s1
    3204:	00004517          	auipc	a0,0x4
    3208:	e6c50513          	addi	a0,a0,-404 # 7070 <malloc+0x13de>
    320c:	00003097          	auipc	ra,0x3
    3210:	9ce080e7          	jalr	-1586(ra) # 5bda <printf>
    exit(1);
    3214:	4505                	li	a0,1
    3216:	00002097          	auipc	ra,0x2
    321a:	642080e7          	jalr	1602(ra) # 5858 <exit>

000000000000321e <subdir>:
{
    321e:	1101                	addi	sp,sp,-32
    3220:	ec06                	sd	ra,24(sp)
    3222:	e822                	sd	s0,16(sp)
    3224:	e426                	sd	s1,8(sp)
    3226:	e04a                	sd	s2,0(sp)
    3228:	1000                	addi	s0,sp,32
    322a:	892a                	mv	s2,a0
  unlink("ff");
    322c:	00004517          	auipc	a0,0x4
    3230:	f8c50513          	addi	a0,a0,-116 # 71b8 <malloc+0x1526>
    3234:	00002097          	auipc	ra,0x2
    3238:	674080e7          	jalr	1652(ra) # 58a8 <unlink>
  if(mkdir("dd") != 0){
    323c:	00004517          	auipc	a0,0x4
    3240:	e4c50513          	addi	a0,a0,-436 # 7088 <malloc+0x13f6>
    3244:	00002097          	auipc	ra,0x2
    3248:	67c080e7          	jalr	1660(ra) # 58c0 <mkdir>
    324c:	38051663          	bnez	a0,35d8 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    3250:	20200593          	li	a1,514
    3254:	00004517          	auipc	a0,0x4
    3258:	e5450513          	addi	a0,a0,-428 # 70a8 <malloc+0x1416>
    325c:	00002097          	auipc	ra,0x2
    3260:	63c080e7          	jalr	1596(ra) # 5898 <open>
    3264:	84aa                	mv	s1,a0
  if(fd < 0){
    3266:	38054763          	bltz	a0,35f4 <subdir+0x3d6>
  write(fd, "ff", 2);
    326a:	4609                	li	a2,2
    326c:	00004597          	auipc	a1,0x4
    3270:	f4c58593          	addi	a1,a1,-180 # 71b8 <malloc+0x1526>
    3274:	00002097          	auipc	ra,0x2
    3278:	604080e7          	jalr	1540(ra) # 5878 <write>
  close(fd);
    327c:	8526                	mv	a0,s1
    327e:	00002097          	auipc	ra,0x2
    3282:	602080e7          	jalr	1538(ra) # 5880 <close>
  if(unlink("dd") >= 0){
    3286:	00004517          	auipc	a0,0x4
    328a:	e0250513          	addi	a0,a0,-510 # 7088 <malloc+0x13f6>
    328e:	00002097          	auipc	ra,0x2
    3292:	61a080e7          	jalr	1562(ra) # 58a8 <unlink>
    3296:	36055d63          	bgez	a0,3610 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    329a:	00004517          	auipc	a0,0x4
    329e:	e6650513          	addi	a0,a0,-410 # 7100 <malloc+0x146e>
    32a2:	00002097          	auipc	ra,0x2
    32a6:	61e080e7          	jalr	1566(ra) # 58c0 <mkdir>
    32aa:	38051163          	bnez	a0,362c <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    32ae:	20200593          	li	a1,514
    32b2:	00004517          	auipc	a0,0x4
    32b6:	e7650513          	addi	a0,a0,-394 # 7128 <malloc+0x1496>
    32ba:	00002097          	auipc	ra,0x2
    32be:	5de080e7          	jalr	1502(ra) # 5898 <open>
    32c2:	84aa                	mv	s1,a0
  if(fd < 0){
    32c4:	38054263          	bltz	a0,3648 <subdir+0x42a>
  write(fd, "FF", 2);
    32c8:	4609                	li	a2,2
    32ca:	00004597          	auipc	a1,0x4
    32ce:	e8e58593          	addi	a1,a1,-370 # 7158 <malloc+0x14c6>
    32d2:	00002097          	auipc	ra,0x2
    32d6:	5a6080e7          	jalr	1446(ra) # 5878 <write>
  close(fd);
    32da:	8526                	mv	a0,s1
    32dc:	00002097          	auipc	ra,0x2
    32e0:	5a4080e7          	jalr	1444(ra) # 5880 <close>
  fd = open("dd/dd/../ff", 0);
    32e4:	4581                	li	a1,0
    32e6:	00004517          	auipc	a0,0x4
    32ea:	e7a50513          	addi	a0,a0,-390 # 7160 <malloc+0x14ce>
    32ee:	00002097          	auipc	ra,0x2
    32f2:	5aa080e7          	jalr	1450(ra) # 5898 <open>
    32f6:	84aa                	mv	s1,a0
  if(fd < 0){
    32f8:	36054663          	bltz	a0,3664 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    32fc:	660d                	lui	a2,0x3
    32fe:	00009597          	auipc	a1,0x9
    3302:	b1258593          	addi	a1,a1,-1262 # be10 <buf>
    3306:	00002097          	auipc	ra,0x2
    330a:	56a080e7          	jalr	1386(ra) # 5870 <read>
  if(cc != 2 || buf[0] != 'f'){
    330e:	4789                	li	a5,2
    3310:	36f51863          	bne	a0,a5,3680 <subdir+0x462>
    3314:	00009717          	auipc	a4,0x9
    3318:	afc74703          	lbu	a4,-1284(a4) # be10 <buf>
    331c:	06600793          	li	a5,102
    3320:	36f71063          	bne	a4,a5,3680 <subdir+0x462>
  close(fd);
    3324:	8526                	mv	a0,s1
    3326:	00002097          	auipc	ra,0x2
    332a:	55a080e7          	jalr	1370(ra) # 5880 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    332e:	00004597          	auipc	a1,0x4
    3332:	e8258593          	addi	a1,a1,-382 # 71b0 <malloc+0x151e>
    3336:	00004517          	auipc	a0,0x4
    333a:	df250513          	addi	a0,a0,-526 # 7128 <malloc+0x1496>
    333e:	00002097          	auipc	ra,0x2
    3342:	57a080e7          	jalr	1402(ra) # 58b8 <link>
    3346:	34051b63          	bnez	a0,369c <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    334a:	00004517          	auipc	a0,0x4
    334e:	dde50513          	addi	a0,a0,-546 # 7128 <malloc+0x1496>
    3352:	00002097          	auipc	ra,0x2
    3356:	556080e7          	jalr	1366(ra) # 58a8 <unlink>
    335a:	34051f63          	bnez	a0,36b8 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    335e:	4581                	li	a1,0
    3360:	00004517          	auipc	a0,0x4
    3364:	dc850513          	addi	a0,a0,-568 # 7128 <malloc+0x1496>
    3368:	00002097          	auipc	ra,0x2
    336c:	530080e7          	jalr	1328(ra) # 5898 <open>
    3370:	36055263          	bgez	a0,36d4 <subdir+0x4b6>
  if(chdir("dd") != 0){
    3374:	00004517          	auipc	a0,0x4
    3378:	d1450513          	addi	a0,a0,-748 # 7088 <malloc+0x13f6>
    337c:	00002097          	auipc	ra,0x2
    3380:	54c080e7          	jalr	1356(ra) # 58c8 <chdir>
    3384:	36051663          	bnez	a0,36f0 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    3388:	00004517          	auipc	a0,0x4
    338c:	ec050513          	addi	a0,a0,-320 # 7248 <malloc+0x15b6>
    3390:	00002097          	auipc	ra,0x2
    3394:	538080e7          	jalr	1336(ra) # 58c8 <chdir>
    3398:	36051a63          	bnez	a0,370c <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    339c:	00004517          	auipc	a0,0x4
    33a0:	edc50513          	addi	a0,a0,-292 # 7278 <malloc+0x15e6>
    33a4:	00002097          	auipc	ra,0x2
    33a8:	524080e7          	jalr	1316(ra) # 58c8 <chdir>
    33ac:	36051e63          	bnez	a0,3728 <subdir+0x50a>
  if(chdir("./..") != 0){
    33b0:	00004517          	auipc	a0,0x4
    33b4:	ef850513          	addi	a0,a0,-264 # 72a8 <malloc+0x1616>
    33b8:	00002097          	auipc	ra,0x2
    33bc:	510080e7          	jalr	1296(ra) # 58c8 <chdir>
    33c0:	38051263          	bnez	a0,3744 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    33c4:	4581                	li	a1,0
    33c6:	00004517          	auipc	a0,0x4
    33ca:	dea50513          	addi	a0,a0,-534 # 71b0 <malloc+0x151e>
    33ce:	00002097          	auipc	ra,0x2
    33d2:	4ca080e7          	jalr	1226(ra) # 5898 <open>
    33d6:	84aa                	mv	s1,a0
  if(fd < 0){
    33d8:	38054463          	bltz	a0,3760 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    33dc:	660d                	lui	a2,0x3
    33de:	00009597          	auipc	a1,0x9
    33e2:	a3258593          	addi	a1,a1,-1486 # be10 <buf>
    33e6:	00002097          	auipc	ra,0x2
    33ea:	48a080e7          	jalr	1162(ra) # 5870 <read>
    33ee:	4789                	li	a5,2
    33f0:	38f51663          	bne	a0,a5,377c <subdir+0x55e>
  close(fd);
    33f4:	8526                	mv	a0,s1
    33f6:	00002097          	auipc	ra,0x2
    33fa:	48a080e7          	jalr	1162(ra) # 5880 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    33fe:	4581                	li	a1,0
    3400:	00004517          	auipc	a0,0x4
    3404:	d2850513          	addi	a0,a0,-728 # 7128 <malloc+0x1496>
    3408:	00002097          	auipc	ra,0x2
    340c:	490080e7          	jalr	1168(ra) # 5898 <open>
    3410:	38055463          	bgez	a0,3798 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3414:	20200593          	li	a1,514
    3418:	00004517          	auipc	a0,0x4
    341c:	f2050513          	addi	a0,a0,-224 # 7338 <malloc+0x16a6>
    3420:	00002097          	auipc	ra,0x2
    3424:	478080e7          	jalr	1144(ra) # 5898 <open>
    3428:	38055663          	bgez	a0,37b4 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    342c:	20200593          	li	a1,514
    3430:	00004517          	auipc	a0,0x4
    3434:	f3850513          	addi	a0,a0,-200 # 7368 <malloc+0x16d6>
    3438:	00002097          	auipc	ra,0x2
    343c:	460080e7          	jalr	1120(ra) # 5898 <open>
    3440:	38055863          	bgez	a0,37d0 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3444:	20000593          	li	a1,512
    3448:	00004517          	auipc	a0,0x4
    344c:	c4050513          	addi	a0,a0,-960 # 7088 <malloc+0x13f6>
    3450:	00002097          	auipc	ra,0x2
    3454:	448080e7          	jalr	1096(ra) # 5898 <open>
    3458:	38055a63          	bgez	a0,37ec <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    345c:	4589                	li	a1,2
    345e:	00004517          	auipc	a0,0x4
    3462:	c2a50513          	addi	a0,a0,-982 # 7088 <malloc+0x13f6>
    3466:	00002097          	auipc	ra,0x2
    346a:	432080e7          	jalr	1074(ra) # 5898 <open>
    346e:	38055d63          	bgez	a0,3808 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    3472:	4585                	li	a1,1
    3474:	00004517          	auipc	a0,0x4
    3478:	c1450513          	addi	a0,a0,-1004 # 7088 <malloc+0x13f6>
    347c:	00002097          	auipc	ra,0x2
    3480:	41c080e7          	jalr	1052(ra) # 5898 <open>
    3484:	3a055063          	bgez	a0,3824 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    3488:	00004597          	auipc	a1,0x4
    348c:	f7058593          	addi	a1,a1,-144 # 73f8 <malloc+0x1766>
    3490:	00004517          	auipc	a0,0x4
    3494:	ea850513          	addi	a0,a0,-344 # 7338 <malloc+0x16a6>
    3498:	00002097          	auipc	ra,0x2
    349c:	420080e7          	jalr	1056(ra) # 58b8 <link>
    34a0:	3a050063          	beqz	a0,3840 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    34a4:	00004597          	auipc	a1,0x4
    34a8:	f5458593          	addi	a1,a1,-172 # 73f8 <malloc+0x1766>
    34ac:	00004517          	auipc	a0,0x4
    34b0:	ebc50513          	addi	a0,a0,-324 # 7368 <malloc+0x16d6>
    34b4:	00002097          	auipc	ra,0x2
    34b8:	404080e7          	jalr	1028(ra) # 58b8 <link>
    34bc:	3a050063          	beqz	a0,385c <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    34c0:	00004597          	auipc	a1,0x4
    34c4:	cf058593          	addi	a1,a1,-784 # 71b0 <malloc+0x151e>
    34c8:	00004517          	auipc	a0,0x4
    34cc:	be050513          	addi	a0,a0,-1056 # 70a8 <malloc+0x1416>
    34d0:	00002097          	auipc	ra,0x2
    34d4:	3e8080e7          	jalr	1000(ra) # 58b8 <link>
    34d8:	3a050063          	beqz	a0,3878 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    34dc:	00004517          	auipc	a0,0x4
    34e0:	e5c50513          	addi	a0,a0,-420 # 7338 <malloc+0x16a6>
    34e4:	00002097          	auipc	ra,0x2
    34e8:	3dc080e7          	jalr	988(ra) # 58c0 <mkdir>
    34ec:	3a050463          	beqz	a0,3894 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    34f0:	00004517          	auipc	a0,0x4
    34f4:	e7850513          	addi	a0,a0,-392 # 7368 <malloc+0x16d6>
    34f8:	00002097          	auipc	ra,0x2
    34fc:	3c8080e7          	jalr	968(ra) # 58c0 <mkdir>
    3500:	3a050863          	beqz	a0,38b0 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3504:	00004517          	auipc	a0,0x4
    3508:	cac50513          	addi	a0,a0,-852 # 71b0 <malloc+0x151e>
    350c:	00002097          	auipc	ra,0x2
    3510:	3b4080e7          	jalr	948(ra) # 58c0 <mkdir>
    3514:	3a050c63          	beqz	a0,38cc <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3518:	00004517          	auipc	a0,0x4
    351c:	e5050513          	addi	a0,a0,-432 # 7368 <malloc+0x16d6>
    3520:	00002097          	auipc	ra,0x2
    3524:	388080e7          	jalr	904(ra) # 58a8 <unlink>
    3528:	3c050063          	beqz	a0,38e8 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    352c:	00004517          	auipc	a0,0x4
    3530:	e0c50513          	addi	a0,a0,-500 # 7338 <malloc+0x16a6>
    3534:	00002097          	auipc	ra,0x2
    3538:	374080e7          	jalr	884(ra) # 58a8 <unlink>
    353c:	3c050463          	beqz	a0,3904 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3540:	00004517          	auipc	a0,0x4
    3544:	b6850513          	addi	a0,a0,-1176 # 70a8 <malloc+0x1416>
    3548:	00002097          	auipc	ra,0x2
    354c:	380080e7          	jalr	896(ra) # 58c8 <chdir>
    3550:	3c050863          	beqz	a0,3920 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3554:	00004517          	auipc	a0,0x4
    3558:	ff450513          	addi	a0,a0,-12 # 7548 <malloc+0x18b6>
    355c:	00002097          	auipc	ra,0x2
    3560:	36c080e7          	jalr	876(ra) # 58c8 <chdir>
    3564:	3c050c63          	beqz	a0,393c <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    3568:	00004517          	auipc	a0,0x4
    356c:	c4850513          	addi	a0,a0,-952 # 71b0 <malloc+0x151e>
    3570:	00002097          	auipc	ra,0x2
    3574:	338080e7          	jalr	824(ra) # 58a8 <unlink>
    3578:	3e051063          	bnez	a0,3958 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    357c:	00004517          	auipc	a0,0x4
    3580:	b2c50513          	addi	a0,a0,-1236 # 70a8 <malloc+0x1416>
    3584:	00002097          	auipc	ra,0x2
    3588:	324080e7          	jalr	804(ra) # 58a8 <unlink>
    358c:	3e051463          	bnez	a0,3974 <subdir+0x756>
  if(unlink("dd") == 0){
    3590:	00004517          	auipc	a0,0x4
    3594:	af850513          	addi	a0,a0,-1288 # 7088 <malloc+0x13f6>
    3598:	00002097          	auipc	ra,0x2
    359c:	310080e7          	jalr	784(ra) # 58a8 <unlink>
    35a0:	3e050863          	beqz	a0,3990 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    35a4:	00004517          	auipc	a0,0x4
    35a8:	01450513          	addi	a0,a0,20 # 75b8 <malloc+0x1926>
    35ac:	00002097          	auipc	ra,0x2
    35b0:	2fc080e7          	jalr	764(ra) # 58a8 <unlink>
    35b4:	3e054c63          	bltz	a0,39ac <subdir+0x78e>
  if(unlink("dd") < 0){
    35b8:	00004517          	auipc	a0,0x4
    35bc:	ad050513          	addi	a0,a0,-1328 # 7088 <malloc+0x13f6>
    35c0:	00002097          	auipc	ra,0x2
    35c4:	2e8080e7          	jalr	744(ra) # 58a8 <unlink>
    35c8:	40054063          	bltz	a0,39c8 <subdir+0x7aa>
}
    35cc:	60e2                	ld	ra,24(sp)
    35ce:	6442                	ld	s0,16(sp)
    35d0:	64a2                	ld	s1,8(sp)
    35d2:	6902                	ld	s2,0(sp)
    35d4:	6105                	addi	sp,sp,32
    35d6:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    35d8:	85ca                	mv	a1,s2
    35da:	00004517          	auipc	a0,0x4
    35de:	ab650513          	addi	a0,a0,-1354 # 7090 <malloc+0x13fe>
    35e2:	00002097          	auipc	ra,0x2
    35e6:	5f8080e7          	jalr	1528(ra) # 5bda <printf>
    exit(1);
    35ea:	4505                	li	a0,1
    35ec:	00002097          	auipc	ra,0x2
    35f0:	26c080e7          	jalr	620(ra) # 5858 <exit>
    printf("%s: create dd/ff failed\n", s);
    35f4:	85ca                	mv	a1,s2
    35f6:	00004517          	auipc	a0,0x4
    35fa:	aba50513          	addi	a0,a0,-1350 # 70b0 <malloc+0x141e>
    35fe:	00002097          	auipc	ra,0x2
    3602:	5dc080e7          	jalr	1500(ra) # 5bda <printf>
    exit(1);
    3606:	4505                	li	a0,1
    3608:	00002097          	auipc	ra,0x2
    360c:	250080e7          	jalr	592(ra) # 5858 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3610:	85ca                	mv	a1,s2
    3612:	00004517          	auipc	a0,0x4
    3616:	abe50513          	addi	a0,a0,-1346 # 70d0 <malloc+0x143e>
    361a:	00002097          	auipc	ra,0x2
    361e:	5c0080e7          	jalr	1472(ra) # 5bda <printf>
    exit(1);
    3622:	4505                	li	a0,1
    3624:	00002097          	auipc	ra,0x2
    3628:	234080e7          	jalr	564(ra) # 5858 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    362c:	85ca                	mv	a1,s2
    362e:	00004517          	auipc	a0,0x4
    3632:	ada50513          	addi	a0,a0,-1318 # 7108 <malloc+0x1476>
    3636:	00002097          	auipc	ra,0x2
    363a:	5a4080e7          	jalr	1444(ra) # 5bda <printf>
    exit(1);
    363e:	4505                	li	a0,1
    3640:	00002097          	auipc	ra,0x2
    3644:	218080e7          	jalr	536(ra) # 5858 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3648:	85ca                	mv	a1,s2
    364a:	00004517          	auipc	a0,0x4
    364e:	aee50513          	addi	a0,a0,-1298 # 7138 <malloc+0x14a6>
    3652:	00002097          	auipc	ra,0x2
    3656:	588080e7          	jalr	1416(ra) # 5bda <printf>
    exit(1);
    365a:	4505                	li	a0,1
    365c:	00002097          	auipc	ra,0x2
    3660:	1fc080e7          	jalr	508(ra) # 5858 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3664:	85ca                	mv	a1,s2
    3666:	00004517          	auipc	a0,0x4
    366a:	b0a50513          	addi	a0,a0,-1270 # 7170 <malloc+0x14de>
    366e:	00002097          	auipc	ra,0x2
    3672:	56c080e7          	jalr	1388(ra) # 5bda <printf>
    exit(1);
    3676:	4505                	li	a0,1
    3678:	00002097          	auipc	ra,0x2
    367c:	1e0080e7          	jalr	480(ra) # 5858 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3680:	85ca                	mv	a1,s2
    3682:	00004517          	auipc	a0,0x4
    3686:	b0e50513          	addi	a0,a0,-1266 # 7190 <malloc+0x14fe>
    368a:	00002097          	auipc	ra,0x2
    368e:	550080e7          	jalr	1360(ra) # 5bda <printf>
    exit(1);
    3692:	4505                	li	a0,1
    3694:	00002097          	auipc	ra,0x2
    3698:	1c4080e7          	jalr	452(ra) # 5858 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    369c:	85ca                	mv	a1,s2
    369e:	00004517          	auipc	a0,0x4
    36a2:	b2250513          	addi	a0,a0,-1246 # 71c0 <malloc+0x152e>
    36a6:	00002097          	auipc	ra,0x2
    36aa:	534080e7          	jalr	1332(ra) # 5bda <printf>
    exit(1);
    36ae:	4505                	li	a0,1
    36b0:	00002097          	auipc	ra,0x2
    36b4:	1a8080e7          	jalr	424(ra) # 5858 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    36b8:	85ca                	mv	a1,s2
    36ba:	00004517          	auipc	a0,0x4
    36be:	b2e50513          	addi	a0,a0,-1234 # 71e8 <malloc+0x1556>
    36c2:	00002097          	auipc	ra,0x2
    36c6:	518080e7          	jalr	1304(ra) # 5bda <printf>
    exit(1);
    36ca:	4505                	li	a0,1
    36cc:	00002097          	auipc	ra,0x2
    36d0:	18c080e7          	jalr	396(ra) # 5858 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    36d4:	85ca                	mv	a1,s2
    36d6:	00004517          	auipc	a0,0x4
    36da:	b3250513          	addi	a0,a0,-1230 # 7208 <malloc+0x1576>
    36de:	00002097          	auipc	ra,0x2
    36e2:	4fc080e7          	jalr	1276(ra) # 5bda <printf>
    exit(1);
    36e6:	4505                	li	a0,1
    36e8:	00002097          	auipc	ra,0x2
    36ec:	170080e7          	jalr	368(ra) # 5858 <exit>
    printf("%s: chdir dd failed\n", s);
    36f0:	85ca                	mv	a1,s2
    36f2:	00004517          	auipc	a0,0x4
    36f6:	b3e50513          	addi	a0,a0,-1218 # 7230 <malloc+0x159e>
    36fa:	00002097          	auipc	ra,0x2
    36fe:	4e0080e7          	jalr	1248(ra) # 5bda <printf>
    exit(1);
    3702:	4505                	li	a0,1
    3704:	00002097          	auipc	ra,0x2
    3708:	154080e7          	jalr	340(ra) # 5858 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    370c:	85ca                	mv	a1,s2
    370e:	00004517          	auipc	a0,0x4
    3712:	b4a50513          	addi	a0,a0,-1206 # 7258 <malloc+0x15c6>
    3716:	00002097          	auipc	ra,0x2
    371a:	4c4080e7          	jalr	1220(ra) # 5bda <printf>
    exit(1);
    371e:	4505                	li	a0,1
    3720:	00002097          	auipc	ra,0x2
    3724:	138080e7          	jalr	312(ra) # 5858 <exit>
    printf("chdir dd/../../dd failed\n", s);
    3728:	85ca                	mv	a1,s2
    372a:	00004517          	auipc	a0,0x4
    372e:	b5e50513          	addi	a0,a0,-1186 # 7288 <malloc+0x15f6>
    3732:	00002097          	auipc	ra,0x2
    3736:	4a8080e7          	jalr	1192(ra) # 5bda <printf>
    exit(1);
    373a:	4505                	li	a0,1
    373c:	00002097          	auipc	ra,0x2
    3740:	11c080e7          	jalr	284(ra) # 5858 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3744:	85ca                	mv	a1,s2
    3746:	00004517          	auipc	a0,0x4
    374a:	b6a50513          	addi	a0,a0,-1174 # 72b0 <malloc+0x161e>
    374e:	00002097          	auipc	ra,0x2
    3752:	48c080e7          	jalr	1164(ra) # 5bda <printf>
    exit(1);
    3756:	4505                	li	a0,1
    3758:	00002097          	auipc	ra,0x2
    375c:	100080e7          	jalr	256(ra) # 5858 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3760:	85ca                	mv	a1,s2
    3762:	00004517          	auipc	a0,0x4
    3766:	b6650513          	addi	a0,a0,-1178 # 72c8 <malloc+0x1636>
    376a:	00002097          	auipc	ra,0x2
    376e:	470080e7          	jalr	1136(ra) # 5bda <printf>
    exit(1);
    3772:	4505                	li	a0,1
    3774:	00002097          	auipc	ra,0x2
    3778:	0e4080e7          	jalr	228(ra) # 5858 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    377c:	85ca                	mv	a1,s2
    377e:	00004517          	auipc	a0,0x4
    3782:	b6a50513          	addi	a0,a0,-1174 # 72e8 <malloc+0x1656>
    3786:	00002097          	auipc	ra,0x2
    378a:	454080e7          	jalr	1108(ra) # 5bda <printf>
    exit(1);
    378e:	4505                	li	a0,1
    3790:	00002097          	auipc	ra,0x2
    3794:	0c8080e7          	jalr	200(ra) # 5858 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3798:	85ca                	mv	a1,s2
    379a:	00004517          	auipc	a0,0x4
    379e:	b6e50513          	addi	a0,a0,-1170 # 7308 <malloc+0x1676>
    37a2:	00002097          	auipc	ra,0x2
    37a6:	438080e7          	jalr	1080(ra) # 5bda <printf>
    exit(1);
    37aa:	4505                	li	a0,1
    37ac:	00002097          	auipc	ra,0x2
    37b0:	0ac080e7          	jalr	172(ra) # 5858 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    37b4:	85ca                	mv	a1,s2
    37b6:	00004517          	auipc	a0,0x4
    37ba:	b9250513          	addi	a0,a0,-1134 # 7348 <malloc+0x16b6>
    37be:	00002097          	auipc	ra,0x2
    37c2:	41c080e7          	jalr	1052(ra) # 5bda <printf>
    exit(1);
    37c6:	4505                	li	a0,1
    37c8:	00002097          	auipc	ra,0x2
    37cc:	090080e7          	jalr	144(ra) # 5858 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    37d0:	85ca                	mv	a1,s2
    37d2:	00004517          	auipc	a0,0x4
    37d6:	ba650513          	addi	a0,a0,-1114 # 7378 <malloc+0x16e6>
    37da:	00002097          	auipc	ra,0x2
    37de:	400080e7          	jalr	1024(ra) # 5bda <printf>
    exit(1);
    37e2:	4505                	li	a0,1
    37e4:	00002097          	auipc	ra,0x2
    37e8:	074080e7          	jalr	116(ra) # 5858 <exit>
    printf("%s: create dd succeeded!\n", s);
    37ec:	85ca                	mv	a1,s2
    37ee:	00004517          	auipc	a0,0x4
    37f2:	baa50513          	addi	a0,a0,-1110 # 7398 <malloc+0x1706>
    37f6:	00002097          	auipc	ra,0x2
    37fa:	3e4080e7          	jalr	996(ra) # 5bda <printf>
    exit(1);
    37fe:	4505                	li	a0,1
    3800:	00002097          	auipc	ra,0x2
    3804:	058080e7          	jalr	88(ra) # 5858 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3808:	85ca                	mv	a1,s2
    380a:	00004517          	auipc	a0,0x4
    380e:	bae50513          	addi	a0,a0,-1106 # 73b8 <malloc+0x1726>
    3812:	00002097          	auipc	ra,0x2
    3816:	3c8080e7          	jalr	968(ra) # 5bda <printf>
    exit(1);
    381a:	4505                	li	a0,1
    381c:	00002097          	auipc	ra,0x2
    3820:	03c080e7          	jalr	60(ra) # 5858 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3824:	85ca                	mv	a1,s2
    3826:	00004517          	auipc	a0,0x4
    382a:	bb250513          	addi	a0,a0,-1102 # 73d8 <malloc+0x1746>
    382e:	00002097          	auipc	ra,0x2
    3832:	3ac080e7          	jalr	940(ra) # 5bda <printf>
    exit(1);
    3836:	4505                	li	a0,1
    3838:	00002097          	auipc	ra,0x2
    383c:	020080e7          	jalr	32(ra) # 5858 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3840:	85ca                	mv	a1,s2
    3842:	00004517          	auipc	a0,0x4
    3846:	bc650513          	addi	a0,a0,-1082 # 7408 <malloc+0x1776>
    384a:	00002097          	auipc	ra,0x2
    384e:	390080e7          	jalr	912(ra) # 5bda <printf>
    exit(1);
    3852:	4505                	li	a0,1
    3854:	00002097          	auipc	ra,0x2
    3858:	004080e7          	jalr	4(ra) # 5858 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    385c:	85ca                	mv	a1,s2
    385e:	00004517          	auipc	a0,0x4
    3862:	bd250513          	addi	a0,a0,-1070 # 7430 <malloc+0x179e>
    3866:	00002097          	auipc	ra,0x2
    386a:	374080e7          	jalr	884(ra) # 5bda <printf>
    exit(1);
    386e:	4505                	li	a0,1
    3870:	00002097          	auipc	ra,0x2
    3874:	fe8080e7          	jalr	-24(ra) # 5858 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3878:	85ca                	mv	a1,s2
    387a:	00004517          	auipc	a0,0x4
    387e:	bde50513          	addi	a0,a0,-1058 # 7458 <malloc+0x17c6>
    3882:	00002097          	auipc	ra,0x2
    3886:	358080e7          	jalr	856(ra) # 5bda <printf>
    exit(1);
    388a:	4505                	li	a0,1
    388c:	00002097          	auipc	ra,0x2
    3890:	fcc080e7          	jalr	-52(ra) # 5858 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3894:	85ca                	mv	a1,s2
    3896:	00004517          	auipc	a0,0x4
    389a:	bea50513          	addi	a0,a0,-1046 # 7480 <malloc+0x17ee>
    389e:	00002097          	auipc	ra,0x2
    38a2:	33c080e7          	jalr	828(ra) # 5bda <printf>
    exit(1);
    38a6:	4505                	li	a0,1
    38a8:	00002097          	auipc	ra,0x2
    38ac:	fb0080e7          	jalr	-80(ra) # 5858 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    38b0:	85ca                	mv	a1,s2
    38b2:	00004517          	auipc	a0,0x4
    38b6:	bee50513          	addi	a0,a0,-1042 # 74a0 <malloc+0x180e>
    38ba:	00002097          	auipc	ra,0x2
    38be:	320080e7          	jalr	800(ra) # 5bda <printf>
    exit(1);
    38c2:	4505                	li	a0,1
    38c4:	00002097          	auipc	ra,0x2
    38c8:	f94080e7          	jalr	-108(ra) # 5858 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    38cc:	85ca                	mv	a1,s2
    38ce:	00004517          	auipc	a0,0x4
    38d2:	bf250513          	addi	a0,a0,-1038 # 74c0 <malloc+0x182e>
    38d6:	00002097          	auipc	ra,0x2
    38da:	304080e7          	jalr	772(ra) # 5bda <printf>
    exit(1);
    38de:	4505                	li	a0,1
    38e0:	00002097          	auipc	ra,0x2
    38e4:	f78080e7          	jalr	-136(ra) # 5858 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    38e8:	85ca                	mv	a1,s2
    38ea:	00004517          	auipc	a0,0x4
    38ee:	bfe50513          	addi	a0,a0,-1026 # 74e8 <malloc+0x1856>
    38f2:	00002097          	auipc	ra,0x2
    38f6:	2e8080e7          	jalr	744(ra) # 5bda <printf>
    exit(1);
    38fa:	4505                	li	a0,1
    38fc:	00002097          	auipc	ra,0x2
    3900:	f5c080e7          	jalr	-164(ra) # 5858 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3904:	85ca                	mv	a1,s2
    3906:	00004517          	auipc	a0,0x4
    390a:	c0250513          	addi	a0,a0,-1022 # 7508 <malloc+0x1876>
    390e:	00002097          	auipc	ra,0x2
    3912:	2cc080e7          	jalr	716(ra) # 5bda <printf>
    exit(1);
    3916:	4505                	li	a0,1
    3918:	00002097          	auipc	ra,0x2
    391c:	f40080e7          	jalr	-192(ra) # 5858 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3920:	85ca                	mv	a1,s2
    3922:	00004517          	auipc	a0,0x4
    3926:	c0650513          	addi	a0,a0,-1018 # 7528 <malloc+0x1896>
    392a:	00002097          	auipc	ra,0x2
    392e:	2b0080e7          	jalr	688(ra) # 5bda <printf>
    exit(1);
    3932:	4505                	li	a0,1
    3934:	00002097          	auipc	ra,0x2
    3938:	f24080e7          	jalr	-220(ra) # 5858 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    393c:	85ca                	mv	a1,s2
    393e:	00004517          	auipc	a0,0x4
    3942:	c1250513          	addi	a0,a0,-1006 # 7550 <malloc+0x18be>
    3946:	00002097          	auipc	ra,0x2
    394a:	294080e7          	jalr	660(ra) # 5bda <printf>
    exit(1);
    394e:	4505                	li	a0,1
    3950:	00002097          	auipc	ra,0x2
    3954:	f08080e7          	jalr	-248(ra) # 5858 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3958:	85ca                	mv	a1,s2
    395a:	00004517          	auipc	a0,0x4
    395e:	88e50513          	addi	a0,a0,-1906 # 71e8 <malloc+0x1556>
    3962:	00002097          	auipc	ra,0x2
    3966:	278080e7          	jalr	632(ra) # 5bda <printf>
    exit(1);
    396a:	4505                	li	a0,1
    396c:	00002097          	auipc	ra,0x2
    3970:	eec080e7          	jalr	-276(ra) # 5858 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3974:	85ca                	mv	a1,s2
    3976:	00004517          	auipc	a0,0x4
    397a:	bfa50513          	addi	a0,a0,-1030 # 7570 <malloc+0x18de>
    397e:	00002097          	auipc	ra,0x2
    3982:	25c080e7          	jalr	604(ra) # 5bda <printf>
    exit(1);
    3986:	4505                	li	a0,1
    3988:	00002097          	auipc	ra,0x2
    398c:	ed0080e7          	jalr	-304(ra) # 5858 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3990:	85ca                	mv	a1,s2
    3992:	00004517          	auipc	a0,0x4
    3996:	bfe50513          	addi	a0,a0,-1026 # 7590 <malloc+0x18fe>
    399a:	00002097          	auipc	ra,0x2
    399e:	240080e7          	jalr	576(ra) # 5bda <printf>
    exit(1);
    39a2:	4505                	li	a0,1
    39a4:	00002097          	auipc	ra,0x2
    39a8:	eb4080e7          	jalr	-332(ra) # 5858 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    39ac:	85ca                	mv	a1,s2
    39ae:	00004517          	auipc	a0,0x4
    39b2:	c1250513          	addi	a0,a0,-1006 # 75c0 <malloc+0x192e>
    39b6:	00002097          	auipc	ra,0x2
    39ba:	224080e7          	jalr	548(ra) # 5bda <printf>
    exit(1);
    39be:	4505                	li	a0,1
    39c0:	00002097          	auipc	ra,0x2
    39c4:	e98080e7          	jalr	-360(ra) # 5858 <exit>
    printf("%s: unlink dd failed\n", s);
    39c8:	85ca                	mv	a1,s2
    39ca:	00004517          	auipc	a0,0x4
    39ce:	c1650513          	addi	a0,a0,-1002 # 75e0 <malloc+0x194e>
    39d2:	00002097          	auipc	ra,0x2
    39d6:	208080e7          	jalr	520(ra) # 5bda <printf>
    exit(1);
    39da:	4505                	li	a0,1
    39dc:	00002097          	auipc	ra,0x2
    39e0:	e7c080e7          	jalr	-388(ra) # 5858 <exit>

00000000000039e4 <rmdot>:
{
    39e4:	1101                	addi	sp,sp,-32
    39e6:	ec06                	sd	ra,24(sp)
    39e8:	e822                	sd	s0,16(sp)
    39ea:	e426                	sd	s1,8(sp)
    39ec:	1000                	addi	s0,sp,32
    39ee:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    39f0:	00004517          	auipc	a0,0x4
    39f4:	c0850513          	addi	a0,a0,-1016 # 75f8 <malloc+0x1966>
    39f8:	00002097          	auipc	ra,0x2
    39fc:	ec8080e7          	jalr	-312(ra) # 58c0 <mkdir>
    3a00:	e549                	bnez	a0,3a8a <rmdot+0xa6>
  if(chdir("dots") != 0){
    3a02:	00004517          	auipc	a0,0x4
    3a06:	bf650513          	addi	a0,a0,-1034 # 75f8 <malloc+0x1966>
    3a0a:	00002097          	auipc	ra,0x2
    3a0e:	ebe080e7          	jalr	-322(ra) # 58c8 <chdir>
    3a12:	e951                	bnez	a0,3aa6 <rmdot+0xc2>
  if(unlink(".") == 0){
    3a14:	00003517          	auipc	a0,0x3
    3a18:	a7450513          	addi	a0,a0,-1420 # 6488 <malloc+0x7f6>
    3a1c:	00002097          	auipc	ra,0x2
    3a20:	e8c080e7          	jalr	-372(ra) # 58a8 <unlink>
    3a24:	cd59                	beqz	a0,3ac2 <rmdot+0xde>
  if(unlink("..") == 0){
    3a26:	00003517          	auipc	a0,0x3
    3a2a:	62a50513          	addi	a0,a0,1578 # 7050 <malloc+0x13be>
    3a2e:	00002097          	auipc	ra,0x2
    3a32:	e7a080e7          	jalr	-390(ra) # 58a8 <unlink>
    3a36:	c545                	beqz	a0,3ade <rmdot+0xfa>
  if(chdir("/") != 0){
    3a38:	00003517          	auipc	a0,0x3
    3a3c:	5c050513          	addi	a0,a0,1472 # 6ff8 <malloc+0x1366>
    3a40:	00002097          	auipc	ra,0x2
    3a44:	e88080e7          	jalr	-376(ra) # 58c8 <chdir>
    3a48:	e94d                	bnez	a0,3afa <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3a4a:	00004517          	auipc	a0,0x4
    3a4e:	c1650513          	addi	a0,a0,-1002 # 7660 <malloc+0x19ce>
    3a52:	00002097          	auipc	ra,0x2
    3a56:	e56080e7          	jalr	-426(ra) # 58a8 <unlink>
    3a5a:	cd55                	beqz	a0,3b16 <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3a5c:	00004517          	auipc	a0,0x4
    3a60:	c2c50513          	addi	a0,a0,-980 # 7688 <malloc+0x19f6>
    3a64:	00002097          	auipc	ra,0x2
    3a68:	e44080e7          	jalr	-444(ra) # 58a8 <unlink>
    3a6c:	c179                	beqz	a0,3b32 <rmdot+0x14e>
  if(unlink("dots") != 0){
    3a6e:	00004517          	auipc	a0,0x4
    3a72:	b8a50513          	addi	a0,a0,-1142 # 75f8 <malloc+0x1966>
    3a76:	00002097          	auipc	ra,0x2
    3a7a:	e32080e7          	jalr	-462(ra) # 58a8 <unlink>
    3a7e:	e961                	bnez	a0,3b4e <rmdot+0x16a>
}
    3a80:	60e2                	ld	ra,24(sp)
    3a82:	6442                	ld	s0,16(sp)
    3a84:	64a2                	ld	s1,8(sp)
    3a86:	6105                	addi	sp,sp,32
    3a88:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    3a8a:	85a6                	mv	a1,s1
    3a8c:	00004517          	auipc	a0,0x4
    3a90:	b7450513          	addi	a0,a0,-1164 # 7600 <malloc+0x196e>
    3a94:	00002097          	auipc	ra,0x2
    3a98:	146080e7          	jalr	326(ra) # 5bda <printf>
    exit(1);
    3a9c:	4505                	li	a0,1
    3a9e:	00002097          	auipc	ra,0x2
    3aa2:	dba080e7          	jalr	-582(ra) # 5858 <exit>
    printf("%s: chdir dots failed\n", s);
    3aa6:	85a6                	mv	a1,s1
    3aa8:	00004517          	auipc	a0,0x4
    3aac:	b7050513          	addi	a0,a0,-1168 # 7618 <malloc+0x1986>
    3ab0:	00002097          	auipc	ra,0x2
    3ab4:	12a080e7          	jalr	298(ra) # 5bda <printf>
    exit(1);
    3ab8:	4505                	li	a0,1
    3aba:	00002097          	auipc	ra,0x2
    3abe:	d9e080e7          	jalr	-610(ra) # 5858 <exit>
    printf("%s: rm . worked!\n", s);
    3ac2:	85a6                	mv	a1,s1
    3ac4:	00004517          	auipc	a0,0x4
    3ac8:	b6c50513          	addi	a0,a0,-1172 # 7630 <malloc+0x199e>
    3acc:	00002097          	auipc	ra,0x2
    3ad0:	10e080e7          	jalr	270(ra) # 5bda <printf>
    exit(1);
    3ad4:	4505                	li	a0,1
    3ad6:	00002097          	auipc	ra,0x2
    3ada:	d82080e7          	jalr	-638(ra) # 5858 <exit>
    printf("%s: rm .. worked!\n", s);
    3ade:	85a6                	mv	a1,s1
    3ae0:	00004517          	auipc	a0,0x4
    3ae4:	b6850513          	addi	a0,a0,-1176 # 7648 <malloc+0x19b6>
    3ae8:	00002097          	auipc	ra,0x2
    3aec:	0f2080e7          	jalr	242(ra) # 5bda <printf>
    exit(1);
    3af0:	4505                	li	a0,1
    3af2:	00002097          	auipc	ra,0x2
    3af6:	d66080e7          	jalr	-666(ra) # 5858 <exit>
    printf("%s: chdir / failed\n", s);
    3afa:	85a6                	mv	a1,s1
    3afc:	00003517          	auipc	a0,0x3
    3b00:	50450513          	addi	a0,a0,1284 # 7000 <malloc+0x136e>
    3b04:	00002097          	auipc	ra,0x2
    3b08:	0d6080e7          	jalr	214(ra) # 5bda <printf>
    exit(1);
    3b0c:	4505                	li	a0,1
    3b0e:	00002097          	auipc	ra,0x2
    3b12:	d4a080e7          	jalr	-694(ra) # 5858 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3b16:	85a6                	mv	a1,s1
    3b18:	00004517          	auipc	a0,0x4
    3b1c:	b5050513          	addi	a0,a0,-1200 # 7668 <malloc+0x19d6>
    3b20:	00002097          	auipc	ra,0x2
    3b24:	0ba080e7          	jalr	186(ra) # 5bda <printf>
    exit(1);
    3b28:	4505                	li	a0,1
    3b2a:	00002097          	auipc	ra,0x2
    3b2e:	d2e080e7          	jalr	-722(ra) # 5858 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3b32:	85a6                	mv	a1,s1
    3b34:	00004517          	auipc	a0,0x4
    3b38:	b5c50513          	addi	a0,a0,-1188 # 7690 <malloc+0x19fe>
    3b3c:	00002097          	auipc	ra,0x2
    3b40:	09e080e7          	jalr	158(ra) # 5bda <printf>
    exit(1);
    3b44:	4505                	li	a0,1
    3b46:	00002097          	auipc	ra,0x2
    3b4a:	d12080e7          	jalr	-750(ra) # 5858 <exit>
    printf("%s: unlink dots failed!\n", s);
    3b4e:	85a6                	mv	a1,s1
    3b50:	00004517          	auipc	a0,0x4
    3b54:	b6050513          	addi	a0,a0,-1184 # 76b0 <malloc+0x1a1e>
    3b58:	00002097          	auipc	ra,0x2
    3b5c:	082080e7          	jalr	130(ra) # 5bda <printf>
    exit(1);
    3b60:	4505                	li	a0,1
    3b62:	00002097          	auipc	ra,0x2
    3b66:	cf6080e7          	jalr	-778(ra) # 5858 <exit>

0000000000003b6a <dirfile>:
{
    3b6a:	1101                	addi	sp,sp,-32
    3b6c:	ec06                	sd	ra,24(sp)
    3b6e:	e822                	sd	s0,16(sp)
    3b70:	e426                	sd	s1,8(sp)
    3b72:	e04a                	sd	s2,0(sp)
    3b74:	1000                	addi	s0,sp,32
    3b76:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    3b78:	20000593          	li	a1,512
    3b7c:	00004517          	auipc	a0,0x4
    3b80:	b5450513          	addi	a0,a0,-1196 # 76d0 <malloc+0x1a3e>
    3b84:	00002097          	auipc	ra,0x2
    3b88:	d14080e7          	jalr	-748(ra) # 5898 <open>
  if(fd < 0){
    3b8c:	0e054d63          	bltz	a0,3c86 <dirfile+0x11c>
  close(fd);
    3b90:	00002097          	auipc	ra,0x2
    3b94:	cf0080e7          	jalr	-784(ra) # 5880 <close>
  if(chdir("dirfile") == 0){
    3b98:	00004517          	auipc	a0,0x4
    3b9c:	b3850513          	addi	a0,a0,-1224 # 76d0 <malloc+0x1a3e>
    3ba0:	00002097          	auipc	ra,0x2
    3ba4:	d28080e7          	jalr	-728(ra) # 58c8 <chdir>
    3ba8:	cd6d                	beqz	a0,3ca2 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    3baa:	4581                	li	a1,0
    3bac:	00004517          	auipc	a0,0x4
    3bb0:	b6c50513          	addi	a0,a0,-1172 # 7718 <malloc+0x1a86>
    3bb4:	00002097          	auipc	ra,0x2
    3bb8:	ce4080e7          	jalr	-796(ra) # 5898 <open>
  if(fd >= 0){
    3bbc:	10055163          	bgez	a0,3cbe <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    3bc0:	20000593          	li	a1,512
    3bc4:	00004517          	auipc	a0,0x4
    3bc8:	b5450513          	addi	a0,a0,-1196 # 7718 <malloc+0x1a86>
    3bcc:	00002097          	auipc	ra,0x2
    3bd0:	ccc080e7          	jalr	-820(ra) # 5898 <open>
  if(fd >= 0){
    3bd4:	10055363          	bgez	a0,3cda <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3bd8:	00004517          	auipc	a0,0x4
    3bdc:	b4050513          	addi	a0,a0,-1216 # 7718 <malloc+0x1a86>
    3be0:	00002097          	auipc	ra,0x2
    3be4:	ce0080e7          	jalr	-800(ra) # 58c0 <mkdir>
    3be8:	10050763          	beqz	a0,3cf6 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3bec:	00004517          	auipc	a0,0x4
    3bf0:	b2c50513          	addi	a0,a0,-1236 # 7718 <malloc+0x1a86>
    3bf4:	00002097          	auipc	ra,0x2
    3bf8:	cb4080e7          	jalr	-844(ra) # 58a8 <unlink>
    3bfc:	10050b63          	beqz	a0,3d12 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3c00:	00004597          	auipc	a1,0x4
    3c04:	b1858593          	addi	a1,a1,-1256 # 7718 <malloc+0x1a86>
    3c08:	00002517          	auipc	a0,0x2
    3c0c:	35050513          	addi	a0,a0,848 # 5f58 <malloc+0x2c6>
    3c10:	00002097          	auipc	ra,0x2
    3c14:	ca8080e7          	jalr	-856(ra) # 58b8 <link>
    3c18:	10050b63          	beqz	a0,3d2e <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3c1c:	00004517          	auipc	a0,0x4
    3c20:	ab450513          	addi	a0,a0,-1356 # 76d0 <malloc+0x1a3e>
    3c24:	00002097          	auipc	ra,0x2
    3c28:	c84080e7          	jalr	-892(ra) # 58a8 <unlink>
    3c2c:	10051f63          	bnez	a0,3d4a <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3c30:	4589                	li	a1,2
    3c32:	00003517          	auipc	a0,0x3
    3c36:	85650513          	addi	a0,a0,-1962 # 6488 <malloc+0x7f6>
    3c3a:	00002097          	auipc	ra,0x2
    3c3e:	c5e080e7          	jalr	-930(ra) # 5898 <open>
  if(fd >= 0){
    3c42:	12055263          	bgez	a0,3d66 <dirfile+0x1fc>
  fd = open(".", 0);
    3c46:	4581                	li	a1,0
    3c48:	00003517          	auipc	a0,0x3
    3c4c:	84050513          	addi	a0,a0,-1984 # 6488 <malloc+0x7f6>
    3c50:	00002097          	auipc	ra,0x2
    3c54:	c48080e7          	jalr	-952(ra) # 5898 <open>
    3c58:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3c5a:	4605                	li	a2,1
    3c5c:	00002597          	auipc	a1,0x2
    3c60:	1c458593          	addi	a1,a1,452 # 5e20 <malloc+0x18e>
    3c64:	00002097          	auipc	ra,0x2
    3c68:	c14080e7          	jalr	-1004(ra) # 5878 <write>
    3c6c:	10a04b63          	bgtz	a0,3d82 <dirfile+0x218>
  close(fd);
    3c70:	8526                	mv	a0,s1
    3c72:	00002097          	auipc	ra,0x2
    3c76:	c0e080e7          	jalr	-1010(ra) # 5880 <close>
}
    3c7a:	60e2                	ld	ra,24(sp)
    3c7c:	6442                	ld	s0,16(sp)
    3c7e:	64a2                	ld	s1,8(sp)
    3c80:	6902                	ld	s2,0(sp)
    3c82:	6105                	addi	sp,sp,32
    3c84:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3c86:	85ca                	mv	a1,s2
    3c88:	00004517          	auipc	a0,0x4
    3c8c:	a5050513          	addi	a0,a0,-1456 # 76d8 <malloc+0x1a46>
    3c90:	00002097          	auipc	ra,0x2
    3c94:	f4a080e7          	jalr	-182(ra) # 5bda <printf>
    exit(1);
    3c98:	4505                	li	a0,1
    3c9a:	00002097          	auipc	ra,0x2
    3c9e:	bbe080e7          	jalr	-1090(ra) # 5858 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3ca2:	85ca                	mv	a1,s2
    3ca4:	00004517          	auipc	a0,0x4
    3ca8:	a5450513          	addi	a0,a0,-1452 # 76f8 <malloc+0x1a66>
    3cac:	00002097          	auipc	ra,0x2
    3cb0:	f2e080e7          	jalr	-210(ra) # 5bda <printf>
    exit(1);
    3cb4:	4505                	li	a0,1
    3cb6:	00002097          	auipc	ra,0x2
    3cba:	ba2080e7          	jalr	-1118(ra) # 5858 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3cbe:	85ca                	mv	a1,s2
    3cc0:	00004517          	auipc	a0,0x4
    3cc4:	a6850513          	addi	a0,a0,-1432 # 7728 <malloc+0x1a96>
    3cc8:	00002097          	auipc	ra,0x2
    3ccc:	f12080e7          	jalr	-238(ra) # 5bda <printf>
    exit(1);
    3cd0:	4505                	li	a0,1
    3cd2:	00002097          	auipc	ra,0x2
    3cd6:	b86080e7          	jalr	-1146(ra) # 5858 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3cda:	85ca                	mv	a1,s2
    3cdc:	00004517          	auipc	a0,0x4
    3ce0:	a4c50513          	addi	a0,a0,-1460 # 7728 <malloc+0x1a96>
    3ce4:	00002097          	auipc	ra,0x2
    3ce8:	ef6080e7          	jalr	-266(ra) # 5bda <printf>
    exit(1);
    3cec:	4505                	li	a0,1
    3cee:	00002097          	auipc	ra,0x2
    3cf2:	b6a080e7          	jalr	-1174(ra) # 5858 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3cf6:	85ca                	mv	a1,s2
    3cf8:	00004517          	auipc	a0,0x4
    3cfc:	a5850513          	addi	a0,a0,-1448 # 7750 <malloc+0x1abe>
    3d00:	00002097          	auipc	ra,0x2
    3d04:	eda080e7          	jalr	-294(ra) # 5bda <printf>
    exit(1);
    3d08:	4505                	li	a0,1
    3d0a:	00002097          	auipc	ra,0x2
    3d0e:	b4e080e7          	jalr	-1202(ra) # 5858 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3d12:	85ca                	mv	a1,s2
    3d14:	00004517          	auipc	a0,0x4
    3d18:	a6450513          	addi	a0,a0,-1436 # 7778 <malloc+0x1ae6>
    3d1c:	00002097          	auipc	ra,0x2
    3d20:	ebe080e7          	jalr	-322(ra) # 5bda <printf>
    exit(1);
    3d24:	4505                	li	a0,1
    3d26:	00002097          	auipc	ra,0x2
    3d2a:	b32080e7          	jalr	-1230(ra) # 5858 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3d2e:	85ca                	mv	a1,s2
    3d30:	00004517          	auipc	a0,0x4
    3d34:	a7050513          	addi	a0,a0,-1424 # 77a0 <malloc+0x1b0e>
    3d38:	00002097          	auipc	ra,0x2
    3d3c:	ea2080e7          	jalr	-350(ra) # 5bda <printf>
    exit(1);
    3d40:	4505                	li	a0,1
    3d42:	00002097          	auipc	ra,0x2
    3d46:	b16080e7          	jalr	-1258(ra) # 5858 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3d4a:	85ca                	mv	a1,s2
    3d4c:	00004517          	auipc	a0,0x4
    3d50:	a7c50513          	addi	a0,a0,-1412 # 77c8 <malloc+0x1b36>
    3d54:	00002097          	auipc	ra,0x2
    3d58:	e86080e7          	jalr	-378(ra) # 5bda <printf>
    exit(1);
    3d5c:	4505                	li	a0,1
    3d5e:	00002097          	auipc	ra,0x2
    3d62:	afa080e7          	jalr	-1286(ra) # 5858 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3d66:	85ca                	mv	a1,s2
    3d68:	00004517          	auipc	a0,0x4
    3d6c:	a8050513          	addi	a0,a0,-1408 # 77e8 <malloc+0x1b56>
    3d70:	00002097          	auipc	ra,0x2
    3d74:	e6a080e7          	jalr	-406(ra) # 5bda <printf>
    exit(1);
    3d78:	4505                	li	a0,1
    3d7a:	00002097          	auipc	ra,0x2
    3d7e:	ade080e7          	jalr	-1314(ra) # 5858 <exit>
    printf("%s: write . succeeded!\n", s);
    3d82:	85ca                	mv	a1,s2
    3d84:	00004517          	auipc	a0,0x4
    3d88:	a8c50513          	addi	a0,a0,-1396 # 7810 <malloc+0x1b7e>
    3d8c:	00002097          	auipc	ra,0x2
    3d90:	e4e080e7          	jalr	-434(ra) # 5bda <printf>
    exit(1);
    3d94:	4505                	li	a0,1
    3d96:	00002097          	auipc	ra,0x2
    3d9a:	ac2080e7          	jalr	-1342(ra) # 5858 <exit>

0000000000003d9e <iref>:
{
    3d9e:	7139                	addi	sp,sp,-64
    3da0:	fc06                	sd	ra,56(sp)
    3da2:	f822                	sd	s0,48(sp)
    3da4:	f426                	sd	s1,40(sp)
    3da6:	f04a                	sd	s2,32(sp)
    3da8:	ec4e                	sd	s3,24(sp)
    3daa:	e852                	sd	s4,16(sp)
    3dac:	e456                	sd	s5,8(sp)
    3dae:	e05a                	sd	s6,0(sp)
    3db0:	0080                	addi	s0,sp,64
    3db2:	8b2a                	mv	s6,a0
    3db4:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3db8:	00004a17          	auipc	s4,0x4
    3dbc:	a70a0a13          	addi	s4,s4,-1424 # 7828 <malloc+0x1b96>
    mkdir("");
    3dc0:	00003497          	auipc	s1,0x3
    3dc4:	57048493          	addi	s1,s1,1392 # 7330 <malloc+0x169e>
    link("README", "");
    3dc8:	00002a97          	auipc	s5,0x2
    3dcc:	190a8a93          	addi	s5,s5,400 # 5f58 <malloc+0x2c6>
    fd = open("xx", O_CREATE);
    3dd0:	00004997          	auipc	s3,0x4
    3dd4:	95098993          	addi	s3,s3,-1712 # 7720 <malloc+0x1a8e>
    3dd8:	a891                	j	3e2c <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3dda:	85da                	mv	a1,s6
    3ddc:	00004517          	auipc	a0,0x4
    3de0:	a5450513          	addi	a0,a0,-1452 # 7830 <malloc+0x1b9e>
    3de4:	00002097          	auipc	ra,0x2
    3de8:	df6080e7          	jalr	-522(ra) # 5bda <printf>
      exit(1);
    3dec:	4505                	li	a0,1
    3dee:	00002097          	auipc	ra,0x2
    3df2:	a6a080e7          	jalr	-1430(ra) # 5858 <exit>
      printf("%s: chdir irefd failed\n", s);
    3df6:	85da                	mv	a1,s6
    3df8:	00004517          	auipc	a0,0x4
    3dfc:	a5050513          	addi	a0,a0,-1456 # 7848 <malloc+0x1bb6>
    3e00:	00002097          	auipc	ra,0x2
    3e04:	dda080e7          	jalr	-550(ra) # 5bda <printf>
      exit(1);
    3e08:	4505                	li	a0,1
    3e0a:	00002097          	auipc	ra,0x2
    3e0e:	a4e080e7          	jalr	-1458(ra) # 5858 <exit>
      close(fd);
    3e12:	00002097          	auipc	ra,0x2
    3e16:	a6e080e7          	jalr	-1426(ra) # 5880 <close>
    3e1a:	a889                	j	3e6c <iref+0xce>
    unlink("xx");
    3e1c:	854e                	mv	a0,s3
    3e1e:	00002097          	auipc	ra,0x2
    3e22:	a8a080e7          	jalr	-1398(ra) # 58a8 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3e26:	397d                	addiw	s2,s2,-1
    3e28:	06090063          	beqz	s2,3e88 <iref+0xea>
    if(mkdir("irefd") != 0){
    3e2c:	8552                	mv	a0,s4
    3e2e:	00002097          	auipc	ra,0x2
    3e32:	a92080e7          	jalr	-1390(ra) # 58c0 <mkdir>
    3e36:	f155                	bnez	a0,3dda <iref+0x3c>
    if(chdir("irefd") != 0){
    3e38:	8552                	mv	a0,s4
    3e3a:	00002097          	auipc	ra,0x2
    3e3e:	a8e080e7          	jalr	-1394(ra) # 58c8 <chdir>
    3e42:	f955                	bnez	a0,3df6 <iref+0x58>
    mkdir("");
    3e44:	8526                	mv	a0,s1
    3e46:	00002097          	auipc	ra,0x2
    3e4a:	a7a080e7          	jalr	-1414(ra) # 58c0 <mkdir>
    link("README", "");
    3e4e:	85a6                	mv	a1,s1
    3e50:	8556                	mv	a0,s5
    3e52:	00002097          	auipc	ra,0x2
    3e56:	a66080e7          	jalr	-1434(ra) # 58b8 <link>
    fd = open("", O_CREATE);
    3e5a:	20000593          	li	a1,512
    3e5e:	8526                	mv	a0,s1
    3e60:	00002097          	auipc	ra,0x2
    3e64:	a38080e7          	jalr	-1480(ra) # 5898 <open>
    if(fd >= 0)
    3e68:	fa0555e3          	bgez	a0,3e12 <iref+0x74>
    fd = open("xx", O_CREATE);
    3e6c:	20000593          	li	a1,512
    3e70:	854e                	mv	a0,s3
    3e72:	00002097          	auipc	ra,0x2
    3e76:	a26080e7          	jalr	-1498(ra) # 5898 <open>
    if(fd >= 0)
    3e7a:	fa0541e3          	bltz	a0,3e1c <iref+0x7e>
      close(fd);
    3e7e:	00002097          	auipc	ra,0x2
    3e82:	a02080e7          	jalr	-1534(ra) # 5880 <close>
    3e86:	bf59                	j	3e1c <iref+0x7e>
    3e88:	03300493          	li	s1,51
    chdir("..");
    3e8c:	00003997          	auipc	s3,0x3
    3e90:	1c498993          	addi	s3,s3,452 # 7050 <malloc+0x13be>
    unlink("irefd");
    3e94:	00004917          	auipc	s2,0x4
    3e98:	99490913          	addi	s2,s2,-1644 # 7828 <malloc+0x1b96>
    chdir("..");
    3e9c:	854e                	mv	a0,s3
    3e9e:	00002097          	auipc	ra,0x2
    3ea2:	a2a080e7          	jalr	-1494(ra) # 58c8 <chdir>
    unlink("irefd");
    3ea6:	854a                	mv	a0,s2
    3ea8:	00002097          	auipc	ra,0x2
    3eac:	a00080e7          	jalr	-1536(ra) # 58a8 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3eb0:	34fd                	addiw	s1,s1,-1
    3eb2:	f4ed                	bnez	s1,3e9c <iref+0xfe>
  chdir("/");
    3eb4:	00003517          	auipc	a0,0x3
    3eb8:	14450513          	addi	a0,a0,324 # 6ff8 <malloc+0x1366>
    3ebc:	00002097          	auipc	ra,0x2
    3ec0:	a0c080e7          	jalr	-1524(ra) # 58c8 <chdir>
}
    3ec4:	70e2                	ld	ra,56(sp)
    3ec6:	7442                	ld	s0,48(sp)
    3ec8:	74a2                	ld	s1,40(sp)
    3eca:	7902                	ld	s2,32(sp)
    3ecc:	69e2                	ld	s3,24(sp)
    3ece:	6a42                	ld	s4,16(sp)
    3ed0:	6aa2                	ld	s5,8(sp)
    3ed2:	6b02                	ld	s6,0(sp)
    3ed4:	6121                	addi	sp,sp,64
    3ed6:	8082                	ret

0000000000003ed8 <openiputtest>:
{
    3ed8:	7179                	addi	sp,sp,-48
    3eda:	f406                	sd	ra,40(sp)
    3edc:	f022                	sd	s0,32(sp)
    3ede:	ec26                	sd	s1,24(sp)
    3ee0:	1800                	addi	s0,sp,48
    3ee2:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3ee4:	00004517          	auipc	a0,0x4
    3ee8:	97c50513          	addi	a0,a0,-1668 # 7860 <malloc+0x1bce>
    3eec:	00002097          	auipc	ra,0x2
    3ef0:	9d4080e7          	jalr	-1580(ra) # 58c0 <mkdir>
    3ef4:	04054263          	bltz	a0,3f38 <openiputtest+0x60>
  pid = fork();
    3ef8:	00002097          	auipc	ra,0x2
    3efc:	958080e7          	jalr	-1704(ra) # 5850 <fork>
  if(pid < 0){
    3f00:	04054a63          	bltz	a0,3f54 <openiputtest+0x7c>
  if(pid == 0){
    3f04:	e93d                	bnez	a0,3f7a <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3f06:	4589                	li	a1,2
    3f08:	00004517          	auipc	a0,0x4
    3f0c:	95850513          	addi	a0,a0,-1704 # 7860 <malloc+0x1bce>
    3f10:	00002097          	auipc	ra,0x2
    3f14:	988080e7          	jalr	-1656(ra) # 5898 <open>
    if(fd >= 0){
    3f18:	04054c63          	bltz	a0,3f70 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3f1c:	85a6                	mv	a1,s1
    3f1e:	00004517          	auipc	a0,0x4
    3f22:	96250513          	addi	a0,a0,-1694 # 7880 <malloc+0x1bee>
    3f26:	00002097          	auipc	ra,0x2
    3f2a:	cb4080e7          	jalr	-844(ra) # 5bda <printf>
      exit(1);
    3f2e:	4505                	li	a0,1
    3f30:	00002097          	auipc	ra,0x2
    3f34:	928080e7          	jalr	-1752(ra) # 5858 <exit>
    printf("%s: mkdir oidir failed\n", s);
    3f38:	85a6                	mv	a1,s1
    3f3a:	00004517          	auipc	a0,0x4
    3f3e:	92e50513          	addi	a0,a0,-1746 # 7868 <malloc+0x1bd6>
    3f42:	00002097          	auipc	ra,0x2
    3f46:	c98080e7          	jalr	-872(ra) # 5bda <printf>
    exit(1);
    3f4a:	4505                	li	a0,1
    3f4c:	00002097          	auipc	ra,0x2
    3f50:	90c080e7          	jalr	-1780(ra) # 5858 <exit>
    printf("%s: fork failed\n", s);
    3f54:	85a6                	mv	a1,s1
    3f56:	00002517          	auipc	a0,0x2
    3f5a:	6d250513          	addi	a0,a0,1746 # 6628 <malloc+0x996>
    3f5e:	00002097          	auipc	ra,0x2
    3f62:	c7c080e7          	jalr	-900(ra) # 5bda <printf>
    exit(1);
    3f66:	4505                	li	a0,1
    3f68:	00002097          	auipc	ra,0x2
    3f6c:	8f0080e7          	jalr	-1808(ra) # 5858 <exit>
    exit(0);
    3f70:	4501                	li	a0,0
    3f72:	00002097          	auipc	ra,0x2
    3f76:	8e6080e7          	jalr	-1818(ra) # 5858 <exit>
  sleep(1);
    3f7a:	4505                	li	a0,1
    3f7c:	00002097          	auipc	ra,0x2
    3f80:	96c080e7          	jalr	-1684(ra) # 58e8 <sleep>
  if(unlink("oidir") != 0){
    3f84:	00004517          	auipc	a0,0x4
    3f88:	8dc50513          	addi	a0,a0,-1828 # 7860 <malloc+0x1bce>
    3f8c:	00002097          	auipc	ra,0x2
    3f90:	91c080e7          	jalr	-1764(ra) # 58a8 <unlink>
    3f94:	cd19                	beqz	a0,3fb2 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3f96:	85a6                	mv	a1,s1
    3f98:	00003517          	auipc	a0,0x3
    3f9c:	88050513          	addi	a0,a0,-1920 # 6818 <malloc+0xb86>
    3fa0:	00002097          	auipc	ra,0x2
    3fa4:	c3a080e7          	jalr	-966(ra) # 5bda <printf>
    exit(1);
    3fa8:	4505                	li	a0,1
    3faa:	00002097          	auipc	ra,0x2
    3fae:	8ae080e7          	jalr	-1874(ra) # 5858 <exit>
  wait(&xstatus);
    3fb2:	fdc40513          	addi	a0,s0,-36
    3fb6:	00002097          	auipc	ra,0x2
    3fba:	8aa080e7          	jalr	-1878(ra) # 5860 <wait>
  exit(xstatus);
    3fbe:	fdc42503          	lw	a0,-36(s0)
    3fc2:	00002097          	auipc	ra,0x2
    3fc6:	896080e7          	jalr	-1898(ra) # 5858 <exit>

0000000000003fca <forkforkfork>:
{
    3fca:	1101                	addi	sp,sp,-32
    3fcc:	ec06                	sd	ra,24(sp)
    3fce:	e822                	sd	s0,16(sp)
    3fd0:	e426                	sd	s1,8(sp)
    3fd2:	1000                	addi	s0,sp,32
    3fd4:	84aa                	mv	s1,a0
  unlink("stopforking");
    3fd6:	00004517          	auipc	a0,0x4
    3fda:	8d250513          	addi	a0,a0,-1838 # 78a8 <malloc+0x1c16>
    3fde:	00002097          	auipc	ra,0x2
    3fe2:	8ca080e7          	jalr	-1846(ra) # 58a8 <unlink>
  int pid = fork();
    3fe6:	00002097          	auipc	ra,0x2
    3fea:	86a080e7          	jalr	-1942(ra) # 5850 <fork>
  if(pid < 0){
    3fee:	04054563          	bltz	a0,4038 <forkforkfork+0x6e>
  if(pid == 0){
    3ff2:	c12d                	beqz	a0,4054 <forkforkfork+0x8a>
  sleep(20); // two seconds
    3ff4:	4551                	li	a0,20
    3ff6:	00002097          	auipc	ra,0x2
    3ffa:	8f2080e7          	jalr	-1806(ra) # 58e8 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3ffe:	20200593          	li	a1,514
    4002:	00004517          	auipc	a0,0x4
    4006:	8a650513          	addi	a0,a0,-1882 # 78a8 <malloc+0x1c16>
    400a:	00002097          	auipc	ra,0x2
    400e:	88e080e7          	jalr	-1906(ra) # 5898 <open>
    4012:	00002097          	auipc	ra,0x2
    4016:	86e080e7          	jalr	-1938(ra) # 5880 <close>
  wait(0);
    401a:	4501                	li	a0,0
    401c:	00002097          	auipc	ra,0x2
    4020:	844080e7          	jalr	-1980(ra) # 5860 <wait>
  sleep(10); // one second
    4024:	4529                	li	a0,10
    4026:	00002097          	auipc	ra,0x2
    402a:	8c2080e7          	jalr	-1854(ra) # 58e8 <sleep>
}
    402e:	60e2                	ld	ra,24(sp)
    4030:	6442                	ld	s0,16(sp)
    4032:	64a2                	ld	s1,8(sp)
    4034:	6105                	addi	sp,sp,32
    4036:	8082                	ret
    printf("%s: fork failed", s);
    4038:	85a6                	mv	a1,s1
    403a:	00002517          	auipc	a0,0x2
    403e:	7ae50513          	addi	a0,a0,1966 # 67e8 <malloc+0xb56>
    4042:	00002097          	auipc	ra,0x2
    4046:	b98080e7          	jalr	-1128(ra) # 5bda <printf>
    exit(1);
    404a:	4505                	li	a0,1
    404c:	00002097          	auipc	ra,0x2
    4050:	80c080e7          	jalr	-2036(ra) # 5858 <exit>
      int fd = open("stopforking", 0);
    4054:	00004497          	auipc	s1,0x4
    4058:	85448493          	addi	s1,s1,-1964 # 78a8 <malloc+0x1c16>
    405c:	4581                	li	a1,0
    405e:	8526                	mv	a0,s1
    4060:	00002097          	auipc	ra,0x2
    4064:	838080e7          	jalr	-1992(ra) # 5898 <open>
      if(fd >= 0){
    4068:	02055463          	bgez	a0,4090 <forkforkfork+0xc6>
      if(fork() < 0){
    406c:	00001097          	auipc	ra,0x1
    4070:	7e4080e7          	jalr	2020(ra) # 5850 <fork>
    4074:	fe0554e3          	bgez	a0,405c <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    4078:	20200593          	li	a1,514
    407c:	8526                	mv	a0,s1
    407e:	00002097          	auipc	ra,0x2
    4082:	81a080e7          	jalr	-2022(ra) # 5898 <open>
    4086:	00001097          	auipc	ra,0x1
    408a:	7fa080e7          	jalr	2042(ra) # 5880 <close>
    408e:	b7f9                	j	405c <forkforkfork+0x92>
        exit(0);
    4090:	4501                	li	a0,0
    4092:	00001097          	auipc	ra,0x1
    4096:	7c6080e7          	jalr	1990(ra) # 5858 <exit>

000000000000409a <killstatus>:
{
    409a:	7139                	addi	sp,sp,-64
    409c:	fc06                	sd	ra,56(sp)
    409e:	f822                	sd	s0,48(sp)
    40a0:	f426                	sd	s1,40(sp)
    40a2:	f04a                	sd	s2,32(sp)
    40a4:	ec4e                	sd	s3,24(sp)
    40a6:	e852                	sd	s4,16(sp)
    40a8:	0080                	addi	s0,sp,64
    40aa:	8a2a                	mv	s4,a0
    40ac:	06400913          	li	s2,100
    if(xst != -1) {
    40b0:	59fd                	li	s3,-1
    int pid1 = fork();
    40b2:	00001097          	auipc	ra,0x1
    40b6:	79e080e7          	jalr	1950(ra) # 5850 <fork>
    40ba:	84aa                	mv	s1,a0
    if(pid1 < 0){
    40bc:	02054f63          	bltz	a0,40fa <killstatus+0x60>
    if(pid1 == 0){
    40c0:	c939                	beqz	a0,4116 <killstatus+0x7c>
    sleep(1);
    40c2:	4505                	li	a0,1
    40c4:	00002097          	auipc	ra,0x2
    40c8:	824080e7          	jalr	-2012(ra) # 58e8 <sleep>
    kill(pid1);
    40cc:	8526                	mv	a0,s1
    40ce:	00001097          	auipc	ra,0x1
    40d2:	7ba080e7          	jalr	1978(ra) # 5888 <kill>
    wait(&xst);
    40d6:	fcc40513          	addi	a0,s0,-52
    40da:	00001097          	auipc	ra,0x1
    40de:	786080e7          	jalr	1926(ra) # 5860 <wait>
    if(xst != -1) {
    40e2:	fcc42783          	lw	a5,-52(s0)
    40e6:	03379d63          	bne	a5,s3,4120 <killstatus+0x86>
  for(int i = 0; i < 100; i++){
    40ea:	397d                	addiw	s2,s2,-1
    40ec:	fc0913e3          	bnez	s2,40b2 <killstatus+0x18>
  exit(0);
    40f0:	4501                	li	a0,0
    40f2:	00001097          	auipc	ra,0x1
    40f6:	766080e7          	jalr	1894(ra) # 5858 <exit>
      printf("%s: fork failed\n", s);
    40fa:	85d2                	mv	a1,s4
    40fc:	00002517          	auipc	a0,0x2
    4100:	52c50513          	addi	a0,a0,1324 # 6628 <malloc+0x996>
    4104:	00002097          	auipc	ra,0x2
    4108:	ad6080e7          	jalr	-1322(ra) # 5bda <printf>
      exit(1);
    410c:	4505                	li	a0,1
    410e:	00001097          	auipc	ra,0x1
    4112:	74a080e7          	jalr	1866(ra) # 5858 <exit>
        getpid();
    4116:	00001097          	auipc	ra,0x1
    411a:	7c2080e7          	jalr	1986(ra) # 58d8 <getpid>
      while(1) {
    411e:	bfe5                	j	4116 <killstatus+0x7c>
       printf("%s: status should be -1\n", s);
    4120:	85d2                	mv	a1,s4
    4122:	00003517          	auipc	a0,0x3
    4126:	79650513          	addi	a0,a0,1942 # 78b8 <malloc+0x1c26>
    412a:	00002097          	auipc	ra,0x2
    412e:	ab0080e7          	jalr	-1360(ra) # 5bda <printf>
       exit(1);
    4132:	4505                	li	a0,1
    4134:	00001097          	auipc	ra,0x1
    4138:	724080e7          	jalr	1828(ra) # 5858 <exit>

000000000000413c <preempt>:
{
    413c:	7139                	addi	sp,sp,-64
    413e:	fc06                	sd	ra,56(sp)
    4140:	f822                	sd	s0,48(sp)
    4142:	f426                	sd	s1,40(sp)
    4144:	f04a                	sd	s2,32(sp)
    4146:	ec4e                	sd	s3,24(sp)
    4148:	e852                	sd	s4,16(sp)
    414a:	0080                	addi	s0,sp,64
    414c:	892a                	mv	s2,a0
  pid1 = fork();
    414e:	00001097          	auipc	ra,0x1
    4152:	702080e7          	jalr	1794(ra) # 5850 <fork>
  if(pid1 < 0) {
    4156:	00054563          	bltz	a0,4160 <preempt+0x24>
    415a:	84aa                	mv	s1,a0
  if(pid1 == 0)
    415c:	e105                	bnez	a0,417c <preempt+0x40>
    for(;;)
    415e:	a001                	j	415e <preempt+0x22>
    printf("%s: fork failed", s);
    4160:	85ca                	mv	a1,s2
    4162:	00002517          	auipc	a0,0x2
    4166:	68650513          	addi	a0,a0,1670 # 67e8 <malloc+0xb56>
    416a:	00002097          	auipc	ra,0x2
    416e:	a70080e7          	jalr	-1424(ra) # 5bda <printf>
    exit(1);
    4172:	4505                	li	a0,1
    4174:	00001097          	auipc	ra,0x1
    4178:	6e4080e7          	jalr	1764(ra) # 5858 <exit>
  pid2 = fork();
    417c:	00001097          	auipc	ra,0x1
    4180:	6d4080e7          	jalr	1748(ra) # 5850 <fork>
    4184:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    4186:	00054463          	bltz	a0,418e <preempt+0x52>
  if(pid2 == 0)
    418a:	e105                	bnez	a0,41aa <preempt+0x6e>
    for(;;)
    418c:	a001                	j	418c <preempt+0x50>
    printf("%s: fork failed\n", s);
    418e:	85ca                	mv	a1,s2
    4190:	00002517          	auipc	a0,0x2
    4194:	49850513          	addi	a0,a0,1176 # 6628 <malloc+0x996>
    4198:	00002097          	auipc	ra,0x2
    419c:	a42080e7          	jalr	-1470(ra) # 5bda <printf>
    exit(1);
    41a0:	4505                	li	a0,1
    41a2:	00001097          	auipc	ra,0x1
    41a6:	6b6080e7          	jalr	1718(ra) # 5858 <exit>
  pipe(pfds);
    41aa:	fc840513          	addi	a0,s0,-56
    41ae:	00001097          	auipc	ra,0x1
    41b2:	6ba080e7          	jalr	1722(ra) # 5868 <pipe>
  pid3 = fork();
    41b6:	00001097          	auipc	ra,0x1
    41ba:	69a080e7          	jalr	1690(ra) # 5850 <fork>
    41be:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    41c0:	02054e63          	bltz	a0,41fc <preempt+0xc0>
  if(pid3 == 0){
    41c4:	e525                	bnez	a0,422c <preempt+0xf0>
    close(pfds[0]);
    41c6:	fc842503          	lw	a0,-56(s0)
    41ca:	00001097          	auipc	ra,0x1
    41ce:	6b6080e7          	jalr	1718(ra) # 5880 <close>
    if(write(pfds[1], "x", 1) != 1)
    41d2:	4605                	li	a2,1
    41d4:	00002597          	auipc	a1,0x2
    41d8:	c4c58593          	addi	a1,a1,-948 # 5e20 <malloc+0x18e>
    41dc:	fcc42503          	lw	a0,-52(s0)
    41e0:	00001097          	auipc	ra,0x1
    41e4:	698080e7          	jalr	1688(ra) # 5878 <write>
    41e8:	4785                	li	a5,1
    41ea:	02f51763          	bne	a0,a5,4218 <preempt+0xdc>
    close(pfds[1]);
    41ee:	fcc42503          	lw	a0,-52(s0)
    41f2:	00001097          	auipc	ra,0x1
    41f6:	68e080e7          	jalr	1678(ra) # 5880 <close>
    for(;;)
    41fa:	a001                	j	41fa <preempt+0xbe>
     printf("%s: fork failed\n", s);
    41fc:	85ca                	mv	a1,s2
    41fe:	00002517          	auipc	a0,0x2
    4202:	42a50513          	addi	a0,a0,1066 # 6628 <malloc+0x996>
    4206:	00002097          	auipc	ra,0x2
    420a:	9d4080e7          	jalr	-1580(ra) # 5bda <printf>
     exit(1);
    420e:	4505                	li	a0,1
    4210:	00001097          	auipc	ra,0x1
    4214:	648080e7          	jalr	1608(ra) # 5858 <exit>
      printf("%s: preempt write error", s);
    4218:	85ca                	mv	a1,s2
    421a:	00003517          	auipc	a0,0x3
    421e:	6be50513          	addi	a0,a0,1726 # 78d8 <malloc+0x1c46>
    4222:	00002097          	auipc	ra,0x2
    4226:	9b8080e7          	jalr	-1608(ra) # 5bda <printf>
    422a:	b7d1                	j	41ee <preempt+0xb2>
  close(pfds[1]);
    422c:	fcc42503          	lw	a0,-52(s0)
    4230:	00001097          	auipc	ra,0x1
    4234:	650080e7          	jalr	1616(ra) # 5880 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    4238:	660d                	lui	a2,0x3
    423a:	00008597          	auipc	a1,0x8
    423e:	bd658593          	addi	a1,a1,-1066 # be10 <buf>
    4242:	fc842503          	lw	a0,-56(s0)
    4246:	00001097          	auipc	ra,0x1
    424a:	62a080e7          	jalr	1578(ra) # 5870 <read>
    424e:	4785                	li	a5,1
    4250:	02f50363          	beq	a0,a5,4276 <preempt+0x13a>
    printf("%s: preempt read error", s);
    4254:	85ca                	mv	a1,s2
    4256:	00003517          	auipc	a0,0x3
    425a:	69a50513          	addi	a0,a0,1690 # 78f0 <malloc+0x1c5e>
    425e:	00002097          	auipc	ra,0x2
    4262:	97c080e7          	jalr	-1668(ra) # 5bda <printf>
}
    4266:	70e2                	ld	ra,56(sp)
    4268:	7442                	ld	s0,48(sp)
    426a:	74a2                	ld	s1,40(sp)
    426c:	7902                	ld	s2,32(sp)
    426e:	69e2                	ld	s3,24(sp)
    4270:	6a42                	ld	s4,16(sp)
    4272:	6121                	addi	sp,sp,64
    4274:	8082                	ret
  close(pfds[0]);
    4276:	fc842503          	lw	a0,-56(s0)
    427a:	00001097          	auipc	ra,0x1
    427e:	606080e7          	jalr	1542(ra) # 5880 <close>
  printf("kill... ");
    4282:	00003517          	auipc	a0,0x3
    4286:	68650513          	addi	a0,a0,1670 # 7908 <malloc+0x1c76>
    428a:	00002097          	auipc	ra,0x2
    428e:	950080e7          	jalr	-1712(ra) # 5bda <printf>
  kill(pid1);
    4292:	8526                	mv	a0,s1
    4294:	00001097          	auipc	ra,0x1
    4298:	5f4080e7          	jalr	1524(ra) # 5888 <kill>
  kill(pid2);
    429c:	854e                	mv	a0,s3
    429e:	00001097          	auipc	ra,0x1
    42a2:	5ea080e7          	jalr	1514(ra) # 5888 <kill>
  kill(pid3);
    42a6:	8552                	mv	a0,s4
    42a8:	00001097          	auipc	ra,0x1
    42ac:	5e0080e7          	jalr	1504(ra) # 5888 <kill>
  printf("wait... ");
    42b0:	00003517          	auipc	a0,0x3
    42b4:	66850513          	addi	a0,a0,1640 # 7918 <malloc+0x1c86>
    42b8:	00002097          	auipc	ra,0x2
    42bc:	922080e7          	jalr	-1758(ra) # 5bda <printf>
  wait(0);
    42c0:	4501                	li	a0,0
    42c2:	00001097          	auipc	ra,0x1
    42c6:	59e080e7          	jalr	1438(ra) # 5860 <wait>
  wait(0);
    42ca:	4501                	li	a0,0
    42cc:	00001097          	auipc	ra,0x1
    42d0:	594080e7          	jalr	1428(ra) # 5860 <wait>
  wait(0);
    42d4:	4501                	li	a0,0
    42d6:	00001097          	auipc	ra,0x1
    42da:	58a080e7          	jalr	1418(ra) # 5860 <wait>
    42de:	b761                	j	4266 <preempt+0x12a>

00000000000042e0 <reparent>:
{
    42e0:	7179                	addi	sp,sp,-48
    42e2:	f406                	sd	ra,40(sp)
    42e4:	f022                	sd	s0,32(sp)
    42e6:	ec26                	sd	s1,24(sp)
    42e8:	e84a                	sd	s2,16(sp)
    42ea:	e44e                	sd	s3,8(sp)
    42ec:	e052                	sd	s4,0(sp)
    42ee:	1800                	addi	s0,sp,48
    42f0:	89aa                	mv	s3,a0
  int master_pid = getpid();
    42f2:	00001097          	auipc	ra,0x1
    42f6:	5e6080e7          	jalr	1510(ra) # 58d8 <getpid>
    42fa:	8a2a                	mv	s4,a0
    42fc:	0c800913          	li	s2,200
    int pid = fork();
    4300:	00001097          	auipc	ra,0x1
    4304:	550080e7          	jalr	1360(ra) # 5850 <fork>
    4308:	84aa                	mv	s1,a0
    if(pid < 0){
    430a:	02054263          	bltz	a0,432e <reparent+0x4e>
    if(pid){
    430e:	cd21                	beqz	a0,4366 <reparent+0x86>
      if(wait(0) != pid){
    4310:	4501                	li	a0,0
    4312:	00001097          	auipc	ra,0x1
    4316:	54e080e7          	jalr	1358(ra) # 5860 <wait>
    431a:	02951863          	bne	a0,s1,434a <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    431e:	397d                	addiw	s2,s2,-1
    4320:	fe0910e3          	bnez	s2,4300 <reparent+0x20>
  exit(0);
    4324:	4501                	li	a0,0
    4326:	00001097          	auipc	ra,0x1
    432a:	532080e7          	jalr	1330(ra) # 5858 <exit>
      printf("%s: fork failed\n", s);
    432e:	85ce                	mv	a1,s3
    4330:	00002517          	auipc	a0,0x2
    4334:	2f850513          	addi	a0,a0,760 # 6628 <malloc+0x996>
    4338:	00002097          	auipc	ra,0x2
    433c:	8a2080e7          	jalr	-1886(ra) # 5bda <printf>
      exit(1);
    4340:	4505                	li	a0,1
    4342:	00001097          	auipc	ra,0x1
    4346:	516080e7          	jalr	1302(ra) # 5858 <exit>
        printf("%s: wait wrong pid\n", s);
    434a:	85ce                	mv	a1,s3
    434c:	00002517          	auipc	a0,0x2
    4350:	46450513          	addi	a0,a0,1124 # 67b0 <malloc+0xb1e>
    4354:	00002097          	auipc	ra,0x2
    4358:	886080e7          	jalr	-1914(ra) # 5bda <printf>
        exit(1);
    435c:	4505                	li	a0,1
    435e:	00001097          	auipc	ra,0x1
    4362:	4fa080e7          	jalr	1274(ra) # 5858 <exit>
      int pid2 = fork();
    4366:	00001097          	auipc	ra,0x1
    436a:	4ea080e7          	jalr	1258(ra) # 5850 <fork>
      if(pid2 < 0){
    436e:	00054763          	bltz	a0,437c <reparent+0x9c>
      exit(0);
    4372:	4501                	li	a0,0
    4374:	00001097          	auipc	ra,0x1
    4378:	4e4080e7          	jalr	1252(ra) # 5858 <exit>
        kill(master_pid);
    437c:	8552                	mv	a0,s4
    437e:	00001097          	auipc	ra,0x1
    4382:	50a080e7          	jalr	1290(ra) # 5888 <kill>
        exit(1);
    4386:	4505                	li	a0,1
    4388:	00001097          	auipc	ra,0x1
    438c:	4d0080e7          	jalr	1232(ra) # 5858 <exit>

0000000000004390 <sbrkfail>:
{
    4390:	7119                	addi	sp,sp,-128
    4392:	fc86                	sd	ra,120(sp)
    4394:	f8a2                	sd	s0,112(sp)
    4396:	f4a6                	sd	s1,104(sp)
    4398:	f0ca                	sd	s2,96(sp)
    439a:	ecce                	sd	s3,88(sp)
    439c:	e8d2                	sd	s4,80(sp)
    439e:	e4d6                	sd	s5,72(sp)
    43a0:	0100                	addi	s0,sp,128
    43a2:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    43a4:	fb040513          	addi	a0,s0,-80
    43a8:	00001097          	auipc	ra,0x1
    43ac:	4c0080e7          	jalr	1216(ra) # 5868 <pipe>
    43b0:	e901                	bnez	a0,43c0 <sbrkfail+0x30>
    43b2:	f8040493          	addi	s1,s0,-128
    43b6:	fa840993          	addi	s3,s0,-88
    43ba:	8926                	mv	s2,s1
    if(pids[i] != -1)
    43bc:	5a7d                	li	s4,-1
    43be:	a085                	j	441e <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    43c0:	85d6                	mv	a1,s5
    43c2:	00002517          	auipc	a0,0x2
    43c6:	36e50513          	addi	a0,a0,878 # 6730 <malloc+0xa9e>
    43ca:	00002097          	auipc	ra,0x2
    43ce:	810080e7          	jalr	-2032(ra) # 5bda <printf>
    exit(1);
    43d2:	4505                	li	a0,1
    43d4:	00001097          	auipc	ra,0x1
    43d8:	484080e7          	jalr	1156(ra) # 5858 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    43dc:	00001097          	auipc	ra,0x1
    43e0:	504080e7          	jalr	1284(ra) # 58e0 <sbrk>
    43e4:	064007b7          	lui	a5,0x6400
    43e8:	40a7853b          	subw	a0,a5,a0
    43ec:	00001097          	auipc	ra,0x1
    43f0:	4f4080e7          	jalr	1268(ra) # 58e0 <sbrk>
      write(fds[1], "x", 1);
    43f4:	4605                	li	a2,1
    43f6:	00002597          	auipc	a1,0x2
    43fa:	a2a58593          	addi	a1,a1,-1494 # 5e20 <malloc+0x18e>
    43fe:	fb442503          	lw	a0,-76(s0)
    4402:	00001097          	auipc	ra,0x1
    4406:	476080e7          	jalr	1142(ra) # 5878 <write>
      for(;;) sleep(1000);
    440a:	3e800513          	li	a0,1000
    440e:	00001097          	auipc	ra,0x1
    4412:	4da080e7          	jalr	1242(ra) # 58e8 <sleep>
    4416:	bfd5                	j	440a <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4418:	0911                	addi	s2,s2,4
    441a:	03390563          	beq	s2,s3,4444 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    441e:	00001097          	auipc	ra,0x1
    4422:	432080e7          	jalr	1074(ra) # 5850 <fork>
    4426:	00a92023          	sw	a0,0(s2)
    442a:	d94d                	beqz	a0,43dc <sbrkfail+0x4c>
    if(pids[i] != -1)
    442c:	ff4506e3          	beq	a0,s4,4418 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    4430:	4605                	li	a2,1
    4432:	faf40593          	addi	a1,s0,-81
    4436:	fb042503          	lw	a0,-80(s0)
    443a:	00001097          	auipc	ra,0x1
    443e:	436080e7          	jalr	1078(ra) # 5870 <read>
    4442:	bfd9                	j	4418 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    4444:	6505                	lui	a0,0x1
    4446:	00001097          	auipc	ra,0x1
    444a:	49a080e7          	jalr	1178(ra) # 58e0 <sbrk>
    444e:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    4450:	597d                	li	s2,-1
    4452:	a021                	j	445a <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4454:	0491                	addi	s1,s1,4
    4456:	01348f63          	beq	s1,s3,4474 <sbrkfail+0xe4>
    if(pids[i] == -1)
    445a:	4088                	lw	a0,0(s1)
    445c:	ff250ce3          	beq	a0,s2,4454 <sbrkfail+0xc4>
    kill(pids[i]);
    4460:	00001097          	auipc	ra,0x1
    4464:	428080e7          	jalr	1064(ra) # 5888 <kill>
    wait(0);
    4468:	4501                	li	a0,0
    446a:	00001097          	auipc	ra,0x1
    446e:	3f6080e7          	jalr	1014(ra) # 5860 <wait>
    4472:	b7cd                	j	4454 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    4474:	57fd                	li	a5,-1
    4476:	04fa0163          	beq	s4,a5,44b8 <sbrkfail+0x128>
  pid = fork();
    447a:	00001097          	auipc	ra,0x1
    447e:	3d6080e7          	jalr	982(ra) # 5850 <fork>
    4482:	84aa                	mv	s1,a0
  if(pid < 0){
    4484:	04054863          	bltz	a0,44d4 <sbrkfail+0x144>
  if(pid == 0){
    4488:	c525                	beqz	a0,44f0 <sbrkfail+0x160>
  wait(&xstatus);
    448a:	fbc40513          	addi	a0,s0,-68
    448e:	00001097          	auipc	ra,0x1
    4492:	3d2080e7          	jalr	978(ra) # 5860 <wait>
  if(xstatus != -1 && xstatus != 2)
    4496:	fbc42783          	lw	a5,-68(s0)
    449a:	577d                	li	a4,-1
    449c:	00e78563          	beq	a5,a4,44a6 <sbrkfail+0x116>
    44a0:	4709                	li	a4,2
    44a2:	08e79d63          	bne	a5,a4,453c <sbrkfail+0x1ac>
}
    44a6:	70e6                	ld	ra,120(sp)
    44a8:	7446                	ld	s0,112(sp)
    44aa:	74a6                	ld	s1,104(sp)
    44ac:	7906                	ld	s2,96(sp)
    44ae:	69e6                	ld	s3,88(sp)
    44b0:	6a46                	ld	s4,80(sp)
    44b2:	6aa6                	ld	s5,72(sp)
    44b4:	6109                	addi	sp,sp,128
    44b6:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    44b8:	85d6                	mv	a1,s5
    44ba:	00003517          	auipc	a0,0x3
    44be:	46e50513          	addi	a0,a0,1134 # 7928 <malloc+0x1c96>
    44c2:	00001097          	auipc	ra,0x1
    44c6:	718080e7          	jalr	1816(ra) # 5bda <printf>
    exit(1);
    44ca:	4505                	li	a0,1
    44cc:	00001097          	auipc	ra,0x1
    44d0:	38c080e7          	jalr	908(ra) # 5858 <exit>
    printf("%s: fork failed\n", s);
    44d4:	85d6                	mv	a1,s5
    44d6:	00002517          	auipc	a0,0x2
    44da:	15250513          	addi	a0,a0,338 # 6628 <malloc+0x996>
    44de:	00001097          	auipc	ra,0x1
    44e2:	6fc080e7          	jalr	1788(ra) # 5bda <printf>
    exit(1);
    44e6:	4505                	li	a0,1
    44e8:	00001097          	auipc	ra,0x1
    44ec:	370080e7          	jalr	880(ra) # 5858 <exit>
    a = sbrk(0);
    44f0:	4501                	li	a0,0
    44f2:	00001097          	auipc	ra,0x1
    44f6:	3ee080e7          	jalr	1006(ra) # 58e0 <sbrk>
    44fa:	892a                	mv	s2,a0
    sbrk(10*BIG);
    44fc:	3e800537          	lui	a0,0x3e800
    4500:	00001097          	auipc	ra,0x1
    4504:	3e0080e7          	jalr	992(ra) # 58e0 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4508:	87ca                	mv	a5,s2
    450a:	3e800737          	lui	a4,0x3e800
    450e:	993a                	add	s2,s2,a4
    4510:	6705                	lui	a4,0x1
      n += *(a+i);
    4512:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f11e0>
    4516:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4518:	97ba                	add	a5,a5,a4
    451a:	ff279ce3          	bne	a5,s2,4512 <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    451e:	8626                	mv	a2,s1
    4520:	85d6                	mv	a1,s5
    4522:	00003517          	auipc	a0,0x3
    4526:	42650513          	addi	a0,a0,1062 # 7948 <malloc+0x1cb6>
    452a:	00001097          	auipc	ra,0x1
    452e:	6b0080e7          	jalr	1712(ra) # 5bda <printf>
    exit(1);
    4532:	4505                	li	a0,1
    4534:	00001097          	auipc	ra,0x1
    4538:	324080e7          	jalr	804(ra) # 5858 <exit>
    exit(1);
    453c:	4505                	li	a0,1
    453e:	00001097          	auipc	ra,0x1
    4542:	31a080e7          	jalr	794(ra) # 5858 <exit>

0000000000004546 <mem>:
{
    4546:	7139                	addi	sp,sp,-64
    4548:	fc06                	sd	ra,56(sp)
    454a:	f822                	sd	s0,48(sp)
    454c:	f426                	sd	s1,40(sp)
    454e:	f04a                	sd	s2,32(sp)
    4550:	ec4e                	sd	s3,24(sp)
    4552:	0080                	addi	s0,sp,64
    4554:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    4556:	00001097          	auipc	ra,0x1
    455a:	2fa080e7          	jalr	762(ra) # 5850 <fork>
    m1 = 0;
    455e:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    4560:	6909                	lui	s2,0x2
    4562:	71190913          	addi	s2,s2,1809 # 2711 <sbrkbasic+0x9b>
  if((pid = fork()) == 0){
    4566:	c115                	beqz	a0,458a <mem+0x44>
    wait(&xstatus);
    4568:	fcc40513          	addi	a0,s0,-52
    456c:	00001097          	auipc	ra,0x1
    4570:	2f4080e7          	jalr	756(ra) # 5860 <wait>
    if(xstatus == -1){
    4574:	fcc42503          	lw	a0,-52(s0)
    4578:	57fd                	li	a5,-1
    457a:	06f50363          	beq	a0,a5,45e0 <mem+0x9a>
    exit(xstatus);
    457e:	00001097          	auipc	ra,0x1
    4582:	2da080e7          	jalr	730(ra) # 5858 <exit>
      *(char**)m2 = m1;
    4586:	e104                	sd	s1,0(a0)
      m1 = m2;
    4588:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    458a:	854a                	mv	a0,s2
    458c:	00001097          	auipc	ra,0x1
    4590:	706080e7          	jalr	1798(ra) # 5c92 <malloc>
    4594:	f96d                	bnez	a0,4586 <mem+0x40>
    while(m1){
    4596:	c881                	beqz	s1,45a6 <mem+0x60>
      m2 = *(char**)m1;
    4598:	8526                	mv	a0,s1
    459a:	6084                	ld	s1,0(s1)
      free(m1);
    459c:	00001097          	auipc	ra,0x1
    45a0:	674080e7          	jalr	1652(ra) # 5c10 <free>
    while(m1){
    45a4:	f8f5                	bnez	s1,4598 <mem+0x52>
    m1 = malloc(1024*20);
    45a6:	6515                	lui	a0,0x5
    45a8:	00001097          	auipc	ra,0x1
    45ac:	6ea080e7          	jalr	1770(ra) # 5c92 <malloc>
    if(m1 == 0){
    45b0:	c911                	beqz	a0,45c4 <mem+0x7e>
    free(m1);
    45b2:	00001097          	auipc	ra,0x1
    45b6:	65e080e7          	jalr	1630(ra) # 5c10 <free>
    exit(0);
    45ba:	4501                	li	a0,0
    45bc:	00001097          	auipc	ra,0x1
    45c0:	29c080e7          	jalr	668(ra) # 5858 <exit>
      printf("couldn't allocate mem?!!\n", s);
    45c4:	85ce                	mv	a1,s3
    45c6:	00003517          	auipc	a0,0x3
    45ca:	3b250513          	addi	a0,a0,946 # 7978 <malloc+0x1ce6>
    45ce:	00001097          	auipc	ra,0x1
    45d2:	60c080e7          	jalr	1548(ra) # 5bda <printf>
      exit(1);
    45d6:	4505                	li	a0,1
    45d8:	00001097          	auipc	ra,0x1
    45dc:	280080e7          	jalr	640(ra) # 5858 <exit>
      exit(0);
    45e0:	4501                	li	a0,0
    45e2:	00001097          	auipc	ra,0x1
    45e6:	276080e7          	jalr	630(ra) # 5858 <exit>

00000000000045ea <sharedfd>:
{
    45ea:	7159                	addi	sp,sp,-112
    45ec:	f486                	sd	ra,104(sp)
    45ee:	f0a2                	sd	s0,96(sp)
    45f0:	eca6                	sd	s1,88(sp)
    45f2:	e8ca                	sd	s2,80(sp)
    45f4:	e4ce                	sd	s3,72(sp)
    45f6:	e0d2                	sd	s4,64(sp)
    45f8:	fc56                	sd	s5,56(sp)
    45fa:	f85a                	sd	s6,48(sp)
    45fc:	f45e                	sd	s7,40(sp)
    45fe:	1880                	addi	s0,sp,112
    4600:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    4602:	00003517          	auipc	a0,0x3
    4606:	39650513          	addi	a0,a0,918 # 7998 <malloc+0x1d06>
    460a:	00001097          	auipc	ra,0x1
    460e:	29e080e7          	jalr	670(ra) # 58a8 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    4612:	20200593          	li	a1,514
    4616:	00003517          	auipc	a0,0x3
    461a:	38250513          	addi	a0,a0,898 # 7998 <malloc+0x1d06>
    461e:	00001097          	auipc	ra,0x1
    4622:	27a080e7          	jalr	634(ra) # 5898 <open>
  if(fd < 0){
    4626:	04054a63          	bltz	a0,467a <sharedfd+0x90>
    462a:	892a                	mv	s2,a0
  pid = fork();
    462c:	00001097          	auipc	ra,0x1
    4630:	224080e7          	jalr	548(ra) # 5850 <fork>
    4634:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    4636:	06300593          	li	a1,99
    463a:	c119                	beqz	a0,4640 <sharedfd+0x56>
    463c:	07000593          	li	a1,112
    4640:	4629                	li	a2,10
    4642:	fa040513          	addi	a0,s0,-96
    4646:	00001097          	auipc	ra,0x1
    464a:	018080e7          	jalr	24(ra) # 565e <memset>
    464e:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    4652:	4629                	li	a2,10
    4654:	fa040593          	addi	a1,s0,-96
    4658:	854a                	mv	a0,s2
    465a:	00001097          	auipc	ra,0x1
    465e:	21e080e7          	jalr	542(ra) # 5878 <write>
    4662:	47a9                	li	a5,10
    4664:	02f51963          	bne	a0,a5,4696 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    4668:	34fd                	addiw	s1,s1,-1
    466a:	f4e5                	bnez	s1,4652 <sharedfd+0x68>
  if(pid == 0) {
    466c:	04099363          	bnez	s3,46b2 <sharedfd+0xc8>
    exit(0);
    4670:	4501                	li	a0,0
    4672:	00001097          	auipc	ra,0x1
    4676:	1e6080e7          	jalr	486(ra) # 5858 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    467a:	85d2                	mv	a1,s4
    467c:	00003517          	auipc	a0,0x3
    4680:	32c50513          	addi	a0,a0,812 # 79a8 <malloc+0x1d16>
    4684:	00001097          	auipc	ra,0x1
    4688:	556080e7          	jalr	1366(ra) # 5bda <printf>
    exit(1);
    468c:	4505                	li	a0,1
    468e:	00001097          	auipc	ra,0x1
    4692:	1ca080e7          	jalr	458(ra) # 5858 <exit>
      printf("%s: write sharedfd failed\n", s);
    4696:	85d2                	mv	a1,s4
    4698:	00003517          	auipc	a0,0x3
    469c:	33850513          	addi	a0,a0,824 # 79d0 <malloc+0x1d3e>
    46a0:	00001097          	auipc	ra,0x1
    46a4:	53a080e7          	jalr	1338(ra) # 5bda <printf>
      exit(1);
    46a8:	4505                	li	a0,1
    46aa:	00001097          	auipc	ra,0x1
    46ae:	1ae080e7          	jalr	430(ra) # 5858 <exit>
    wait(&xstatus);
    46b2:	f9c40513          	addi	a0,s0,-100
    46b6:	00001097          	auipc	ra,0x1
    46ba:	1aa080e7          	jalr	426(ra) # 5860 <wait>
    if(xstatus != 0)
    46be:	f9c42983          	lw	s3,-100(s0)
    46c2:	00098763          	beqz	s3,46d0 <sharedfd+0xe6>
      exit(xstatus);
    46c6:	854e                	mv	a0,s3
    46c8:	00001097          	auipc	ra,0x1
    46cc:	190080e7          	jalr	400(ra) # 5858 <exit>
  close(fd);
    46d0:	854a                	mv	a0,s2
    46d2:	00001097          	auipc	ra,0x1
    46d6:	1ae080e7          	jalr	430(ra) # 5880 <close>
  fd = open("sharedfd", 0);
    46da:	4581                	li	a1,0
    46dc:	00003517          	auipc	a0,0x3
    46e0:	2bc50513          	addi	a0,a0,700 # 7998 <malloc+0x1d06>
    46e4:	00001097          	auipc	ra,0x1
    46e8:	1b4080e7          	jalr	436(ra) # 5898 <open>
    46ec:	8baa                	mv	s7,a0
  nc = np = 0;
    46ee:	8ace                	mv	s5,s3
  if(fd < 0){
    46f0:	02054563          	bltz	a0,471a <sharedfd+0x130>
    46f4:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    46f8:	06300493          	li	s1,99
      if(buf[i] == 'p')
    46fc:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4700:	4629                	li	a2,10
    4702:	fa040593          	addi	a1,s0,-96
    4706:	855e                	mv	a0,s7
    4708:	00001097          	auipc	ra,0x1
    470c:	168080e7          	jalr	360(ra) # 5870 <read>
    4710:	02a05f63          	blez	a0,474e <sharedfd+0x164>
    4714:	fa040793          	addi	a5,s0,-96
    4718:	a01d                	j	473e <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    471a:	85d2                	mv	a1,s4
    471c:	00003517          	auipc	a0,0x3
    4720:	2d450513          	addi	a0,a0,724 # 79f0 <malloc+0x1d5e>
    4724:	00001097          	auipc	ra,0x1
    4728:	4b6080e7          	jalr	1206(ra) # 5bda <printf>
    exit(1);
    472c:	4505                	li	a0,1
    472e:	00001097          	auipc	ra,0x1
    4732:	12a080e7          	jalr	298(ra) # 5858 <exit>
        nc++;
    4736:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    4738:	0785                	addi	a5,a5,1
    473a:	fd2783e3          	beq	a5,s2,4700 <sharedfd+0x116>
      if(buf[i] == 'c')
    473e:	0007c703          	lbu	a4,0(a5)
    4742:	fe970ae3          	beq	a4,s1,4736 <sharedfd+0x14c>
      if(buf[i] == 'p')
    4746:	ff6719e3          	bne	a4,s6,4738 <sharedfd+0x14e>
        np++;
    474a:	2a85                	addiw	s5,s5,1
    474c:	b7f5                	j	4738 <sharedfd+0x14e>
  close(fd);
    474e:	855e                	mv	a0,s7
    4750:	00001097          	auipc	ra,0x1
    4754:	130080e7          	jalr	304(ra) # 5880 <close>
  unlink("sharedfd");
    4758:	00003517          	auipc	a0,0x3
    475c:	24050513          	addi	a0,a0,576 # 7998 <malloc+0x1d06>
    4760:	00001097          	auipc	ra,0x1
    4764:	148080e7          	jalr	328(ra) # 58a8 <unlink>
  if(nc == N*SZ && np == N*SZ){
    4768:	6789                	lui	a5,0x2
    476a:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x9a>
    476e:	00f99763          	bne	s3,a5,477c <sharedfd+0x192>
    4772:	6789                	lui	a5,0x2
    4774:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x9a>
    4778:	02fa8063          	beq	s5,a5,4798 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    477c:	85d2                	mv	a1,s4
    477e:	00003517          	auipc	a0,0x3
    4782:	29a50513          	addi	a0,a0,666 # 7a18 <malloc+0x1d86>
    4786:	00001097          	auipc	ra,0x1
    478a:	454080e7          	jalr	1108(ra) # 5bda <printf>
    exit(1);
    478e:	4505                	li	a0,1
    4790:	00001097          	auipc	ra,0x1
    4794:	0c8080e7          	jalr	200(ra) # 5858 <exit>
    exit(0);
    4798:	4501                	li	a0,0
    479a:	00001097          	auipc	ra,0x1
    479e:	0be080e7          	jalr	190(ra) # 5858 <exit>

00000000000047a2 <fourfiles>:
{
    47a2:	7171                	addi	sp,sp,-176
    47a4:	f506                	sd	ra,168(sp)
    47a6:	f122                	sd	s0,160(sp)
    47a8:	ed26                	sd	s1,152(sp)
    47aa:	e94a                	sd	s2,144(sp)
    47ac:	e54e                	sd	s3,136(sp)
    47ae:	e152                	sd	s4,128(sp)
    47b0:	fcd6                	sd	s5,120(sp)
    47b2:	f8da                	sd	s6,112(sp)
    47b4:	f4de                	sd	s7,104(sp)
    47b6:	f0e2                	sd	s8,96(sp)
    47b8:	ece6                	sd	s9,88(sp)
    47ba:	e8ea                	sd	s10,80(sp)
    47bc:	e4ee                	sd	s11,72(sp)
    47be:	1900                	addi	s0,sp,176
    47c0:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    47c4:	00003797          	auipc	a5,0x3
    47c8:	26c78793          	addi	a5,a5,620 # 7a30 <malloc+0x1d9e>
    47cc:	f6f43823          	sd	a5,-144(s0)
    47d0:	00003797          	auipc	a5,0x3
    47d4:	26878793          	addi	a5,a5,616 # 7a38 <malloc+0x1da6>
    47d8:	f6f43c23          	sd	a5,-136(s0)
    47dc:	00003797          	auipc	a5,0x3
    47e0:	26478793          	addi	a5,a5,612 # 7a40 <malloc+0x1dae>
    47e4:	f8f43023          	sd	a5,-128(s0)
    47e8:	00003797          	auipc	a5,0x3
    47ec:	26078793          	addi	a5,a5,608 # 7a48 <malloc+0x1db6>
    47f0:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    47f4:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    47f8:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    47fa:	4481                	li	s1,0
    47fc:	4a11                	li	s4,4
    fname = names[pi];
    47fe:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4802:	854e                	mv	a0,s3
    4804:	00001097          	auipc	ra,0x1
    4808:	0a4080e7          	jalr	164(ra) # 58a8 <unlink>
    pid = fork();
    480c:	00001097          	auipc	ra,0x1
    4810:	044080e7          	jalr	68(ra) # 5850 <fork>
    if(pid < 0){
    4814:	04054463          	bltz	a0,485c <fourfiles+0xba>
    if(pid == 0){
    4818:	c12d                	beqz	a0,487a <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    481a:	2485                	addiw	s1,s1,1
    481c:	0921                	addi	s2,s2,8
    481e:	ff4490e3          	bne	s1,s4,47fe <fourfiles+0x5c>
    4822:	4491                	li	s1,4
    wait(&xstatus);
    4824:	f6c40513          	addi	a0,s0,-148
    4828:	00001097          	auipc	ra,0x1
    482c:	038080e7          	jalr	56(ra) # 5860 <wait>
    if(xstatus != 0)
    4830:	f6c42b03          	lw	s6,-148(s0)
    4834:	0c0b1e63          	bnez	s6,4910 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    4838:	34fd                	addiw	s1,s1,-1
    483a:	f4ed                	bnez	s1,4824 <fourfiles+0x82>
    483c:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4840:	00007a17          	auipc	s4,0x7
    4844:	5d0a0a13          	addi	s4,s4,1488 # be10 <buf>
    4848:	00007a97          	auipc	s5,0x7
    484c:	5c9a8a93          	addi	s5,s5,1481 # be11 <buf+0x1>
    if(total != N*SZ){
    4850:	6d85                	lui	s11,0x1
    4852:	770d8d93          	addi	s11,s11,1904 # 1770 <pipe1+0x1e>
  for(i = 0; i < NCHILD; i++){
    4856:	03400d13          	li	s10,52
    485a:	aa1d                	j	4990 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    485c:	f5843583          	ld	a1,-168(s0)
    4860:	00002517          	auipc	a0,0x2
    4864:	1e850513          	addi	a0,a0,488 # 6a48 <malloc+0xdb6>
    4868:	00001097          	auipc	ra,0x1
    486c:	372080e7          	jalr	882(ra) # 5bda <printf>
      exit(1);
    4870:	4505                	li	a0,1
    4872:	00001097          	auipc	ra,0x1
    4876:	fe6080e7          	jalr	-26(ra) # 5858 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    487a:	20200593          	li	a1,514
    487e:	854e                	mv	a0,s3
    4880:	00001097          	auipc	ra,0x1
    4884:	018080e7          	jalr	24(ra) # 5898 <open>
    4888:	892a                	mv	s2,a0
      if(fd < 0){
    488a:	04054763          	bltz	a0,48d8 <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    488e:	1f400613          	li	a2,500
    4892:	0304859b          	addiw	a1,s1,48
    4896:	00007517          	auipc	a0,0x7
    489a:	57a50513          	addi	a0,a0,1402 # be10 <buf>
    489e:	00001097          	auipc	ra,0x1
    48a2:	dc0080e7          	jalr	-576(ra) # 565e <memset>
    48a6:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    48a8:	00007997          	auipc	s3,0x7
    48ac:	56898993          	addi	s3,s3,1384 # be10 <buf>
    48b0:	1f400613          	li	a2,500
    48b4:	85ce                	mv	a1,s3
    48b6:	854a                	mv	a0,s2
    48b8:	00001097          	auipc	ra,0x1
    48bc:	fc0080e7          	jalr	-64(ra) # 5878 <write>
    48c0:	85aa                	mv	a1,a0
    48c2:	1f400793          	li	a5,500
    48c6:	02f51863          	bne	a0,a5,48f6 <fourfiles+0x154>
      for(i = 0; i < N; i++){
    48ca:	34fd                	addiw	s1,s1,-1
    48cc:	f0f5                	bnez	s1,48b0 <fourfiles+0x10e>
      exit(0);
    48ce:	4501                	li	a0,0
    48d0:	00001097          	auipc	ra,0x1
    48d4:	f88080e7          	jalr	-120(ra) # 5858 <exit>
        printf("create failed\n", s);
    48d8:	f5843583          	ld	a1,-168(s0)
    48dc:	00003517          	auipc	a0,0x3
    48e0:	17450513          	addi	a0,a0,372 # 7a50 <malloc+0x1dbe>
    48e4:	00001097          	auipc	ra,0x1
    48e8:	2f6080e7          	jalr	758(ra) # 5bda <printf>
        exit(1);
    48ec:	4505                	li	a0,1
    48ee:	00001097          	auipc	ra,0x1
    48f2:	f6a080e7          	jalr	-150(ra) # 5858 <exit>
          printf("write failed %d\n", n);
    48f6:	00003517          	auipc	a0,0x3
    48fa:	16a50513          	addi	a0,a0,362 # 7a60 <malloc+0x1dce>
    48fe:	00001097          	auipc	ra,0x1
    4902:	2dc080e7          	jalr	732(ra) # 5bda <printf>
          exit(1);
    4906:	4505                	li	a0,1
    4908:	00001097          	auipc	ra,0x1
    490c:	f50080e7          	jalr	-176(ra) # 5858 <exit>
      exit(xstatus);
    4910:	855a                	mv	a0,s6
    4912:	00001097          	auipc	ra,0x1
    4916:	f46080e7          	jalr	-186(ra) # 5858 <exit>
          printf("wrong char\n", s);
    491a:	f5843583          	ld	a1,-168(s0)
    491e:	00003517          	auipc	a0,0x3
    4922:	15a50513          	addi	a0,a0,346 # 7a78 <malloc+0x1de6>
    4926:	00001097          	auipc	ra,0x1
    492a:	2b4080e7          	jalr	692(ra) # 5bda <printf>
          exit(1);
    492e:	4505                	li	a0,1
    4930:	00001097          	auipc	ra,0x1
    4934:	f28080e7          	jalr	-216(ra) # 5858 <exit>
      total += n;
    4938:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    493c:	660d                	lui	a2,0x3
    493e:	85d2                	mv	a1,s4
    4940:	854e                	mv	a0,s3
    4942:	00001097          	auipc	ra,0x1
    4946:	f2e080e7          	jalr	-210(ra) # 5870 <read>
    494a:	02a05363          	blez	a0,4970 <fourfiles+0x1ce>
    494e:	00007797          	auipc	a5,0x7
    4952:	4c278793          	addi	a5,a5,1218 # be10 <buf>
    4956:	fff5069b          	addiw	a3,a0,-1
    495a:	1682                	slli	a3,a3,0x20
    495c:	9281                	srli	a3,a3,0x20
    495e:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    4960:	0007c703          	lbu	a4,0(a5)
    4964:	fa971be3          	bne	a4,s1,491a <fourfiles+0x178>
      for(j = 0; j < n; j++){
    4968:	0785                	addi	a5,a5,1
    496a:	fed79be3          	bne	a5,a3,4960 <fourfiles+0x1be>
    496e:	b7e9                	j	4938 <fourfiles+0x196>
    close(fd);
    4970:	854e                	mv	a0,s3
    4972:	00001097          	auipc	ra,0x1
    4976:	f0e080e7          	jalr	-242(ra) # 5880 <close>
    if(total != N*SZ){
    497a:	03b91863          	bne	s2,s11,49aa <fourfiles+0x208>
    unlink(fname);
    497e:	8566                	mv	a0,s9
    4980:	00001097          	auipc	ra,0x1
    4984:	f28080e7          	jalr	-216(ra) # 58a8 <unlink>
  for(i = 0; i < NCHILD; i++){
    4988:	0c21                	addi	s8,s8,8
    498a:	2b85                	addiw	s7,s7,1
    498c:	03ab8d63          	beq	s7,s10,49c6 <fourfiles+0x224>
    fname = names[i];
    4990:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    4994:	4581                	li	a1,0
    4996:	8566                	mv	a0,s9
    4998:	00001097          	auipc	ra,0x1
    499c:	f00080e7          	jalr	-256(ra) # 5898 <open>
    49a0:	89aa                	mv	s3,a0
    total = 0;
    49a2:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    49a4:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    49a8:	bf51                	j	493c <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    49aa:	85ca                	mv	a1,s2
    49ac:	00003517          	auipc	a0,0x3
    49b0:	0dc50513          	addi	a0,a0,220 # 7a88 <malloc+0x1df6>
    49b4:	00001097          	auipc	ra,0x1
    49b8:	226080e7          	jalr	550(ra) # 5bda <printf>
      exit(1);
    49bc:	4505                	li	a0,1
    49be:	00001097          	auipc	ra,0x1
    49c2:	e9a080e7          	jalr	-358(ra) # 5858 <exit>
}
    49c6:	70aa                	ld	ra,168(sp)
    49c8:	740a                	ld	s0,160(sp)
    49ca:	64ea                	ld	s1,152(sp)
    49cc:	694a                	ld	s2,144(sp)
    49ce:	69aa                	ld	s3,136(sp)
    49d0:	6a0a                	ld	s4,128(sp)
    49d2:	7ae6                	ld	s5,120(sp)
    49d4:	7b46                	ld	s6,112(sp)
    49d6:	7ba6                	ld	s7,104(sp)
    49d8:	7c06                	ld	s8,96(sp)
    49da:	6ce6                	ld	s9,88(sp)
    49dc:	6d46                	ld	s10,80(sp)
    49de:	6da6                	ld	s11,72(sp)
    49e0:	614d                	addi	sp,sp,176
    49e2:	8082                	ret

00000000000049e4 <concreate>:
{
    49e4:	7135                	addi	sp,sp,-160
    49e6:	ed06                	sd	ra,152(sp)
    49e8:	e922                	sd	s0,144(sp)
    49ea:	e526                	sd	s1,136(sp)
    49ec:	e14a                	sd	s2,128(sp)
    49ee:	fcce                	sd	s3,120(sp)
    49f0:	f8d2                	sd	s4,112(sp)
    49f2:	f4d6                	sd	s5,104(sp)
    49f4:	f0da                	sd	s6,96(sp)
    49f6:	ecde                	sd	s7,88(sp)
    49f8:	1100                	addi	s0,sp,160
    49fa:	89aa                	mv	s3,a0
  file[0] = 'C';
    49fc:	04300793          	li	a5,67
    4a00:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4a04:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4a08:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    4a0a:	4b0d                	li	s6,3
    4a0c:	4a85                	li	s5,1
      link("C0", file);
    4a0e:	00003b97          	auipc	s7,0x3
    4a12:	092b8b93          	addi	s7,s7,146 # 7aa0 <malloc+0x1e0e>
  for(i = 0; i < N; i++){
    4a16:	02800a13          	li	s4,40
    4a1a:	acc9                	j	4cec <concreate+0x308>
      link("C0", file);
    4a1c:	fa840593          	addi	a1,s0,-88
    4a20:	855e                	mv	a0,s7
    4a22:	00001097          	auipc	ra,0x1
    4a26:	e96080e7          	jalr	-362(ra) # 58b8 <link>
    if(pid == 0) {
    4a2a:	a465                	j	4cd2 <concreate+0x2ee>
    } else if(pid == 0 && (i % 5) == 1){
    4a2c:	4795                	li	a5,5
    4a2e:	02f9693b          	remw	s2,s2,a5
    4a32:	4785                	li	a5,1
    4a34:	02f90b63          	beq	s2,a5,4a6a <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    4a38:	20200593          	li	a1,514
    4a3c:	fa840513          	addi	a0,s0,-88
    4a40:	00001097          	auipc	ra,0x1
    4a44:	e58080e7          	jalr	-424(ra) # 5898 <open>
      if(fd < 0){
    4a48:	26055c63          	bgez	a0,4cc0 <concreate+0x2dc>
        printf("concreate create %s failed\n", file);
    4a4c:	fa840593          	addi	a1,s0,-88
    4a50:	00003517          	auipc	a0,0x3
    4a54:	05850513          	addi	a0,a0,88 # 7aa8 <malloc+0x1e16>
    4a58:	00001097          	auipc	ra,0x1
    4a5c:	182080e7          	jalr	386(ra) # 5bda <printf>
        exit(1);
    4a60:	4505                	li	a0,1
    4a62:	00001097          	auipc	ra,0x1
    4a66:	df6080e7          	jalr	-522(ra) # 5858 <exit>
      link("C0", file);
    4a6a:	fa840593          	addi	a1,s0,-88
    4a6e:	00003517          	auipc	a0,0x3
    4a72:	03250513          	addi	a0,a0,50 # 7aa0 <malloc+0x1e0e>
    4a76:	00001097          	auipc	ra,0x1
    4a7a:	e42080e7          	jalr	-446(ra) # 58b8 <link>
      exit(0);
    4a7e:	4501                	li	a0,0
    4a80:	00001097          	auipc	ra,0x1
    4a84:	dd8080e7          	jalr	-552(ra) # 5858 <exit>
        exit(1);
    4a88:	4505                	li	a0,1
    4a8a:	00001097          	auipc	ra,0x1
    4a8e:	dce080e7          	jalr	-562(ra) # 5858 <exit>
  memset(fa, 0, sizeof(fa));
    4a92:	02800613          	li	a2,40
    4a96:	4581                	li	a1,0
    4a98:	f8040513          	addi	a0,s0,-128
    4a9c:	00001097          	auipc	ra,0x1
    4aa0:	bc2080e7          	jalr	-1086(ra) # 565e <memset>
  fd = open(".", 0);
    4aa4:	4581                	li	a1,0
    4aa6:	00002517          	auipc	a0,0x2
    4aaa:	9e250513          	addi	a0,a0,-1566 # 6488 <malloc+0x7f6>
    4aae:	00001097          	auipc	ra,0x1
    4ab2:	dea080e7          	jalr	-534(ra) # 5898 <open>
    4ab6:	892a                	mv	s2,a0
  n = 0;
    4ab8:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4aba:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4abe:	02700b13          	li	s6,39
      fa[i] = 1;
    4ac2:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4ac4:	4641                	li	a2,16
    4ac6:	f7040593          	addi	a1,s0,-144
    4aca:	854a                	mv	a0,s2
    4acc:	00001097          	auipc	ra,0x1
    4ad0:	da4080e7          	jalr	-604(ra) # 5870 <read>
    4ad4:	08a05263          	blez	a0,4b58 <concreate+0x174>
    if(de.inum == 0)
    4ad8:	f7045783          	lhu	a5,-144(s0)
    4adc:	d7e5                	beqz	a5,4ac4 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4ade:	f7244783          	lbu	a5,-142(s0)
    4ae2:	ff4791e3          	bne	a5,s4,4ac4 <concreate+0xe0>
    4ae6:	f7444783          	lbu	a5,-140(s0)
    4aea:	ffe9                	bnez	a5,4ac4 <concreate+0xe0>
      i = de.name[1] - '0';
    4aec:	f7344783          	lbu	a5,-141(s0)
    4af0:	fd07879b          	addiw	a5,a5,-48
    4af4:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    4af8:	02eb6063          	bltu	s6,a4,4b18 <concreate+0x134>
      if(fa[i]){
    4afc:	fb070793          	addi	a5,a4,-80 # fb0 <bigdir+0x3a>
    4b00:	97a2                	add	a5,a5,s0
    4b02:	fd07c783          	lbu	a5,-48(a5)
    4b06:	eb8d                	bnez	a5,4b38 <concreate+0x154>
      fa[i] = 1;
    4b08:	fb070793          	addi	a5,a4,-80
    4b0c:	00878733          	add	a4,a5,s0
    4b10:	fd770823          	sb	s7,-48(a4)
      n++;
    4b14:	2a85                	addiw	s5,s5,1
    4b16:	b77d                	j	4ac4 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    4b18:	f7240613          	addi	a2,s0,-142
    4b1c:	85ce                	mv	a1,s3
    4b1e:	00003517          	auipc	a0,0x3
    4b22:	faa50513          	addi	a0,a0,-86 # 7ac8 <malloc+0x1e36>
    4b26:	00001097          	auipc	ra,0x1
    4b2a:	0b4080e7          	jalr	180(ra) # 5bda <printf>
        exit(1);
    4b2e:	4505                	li	a0,1
    4b30:	00001097          	auipc	ra,0x1
    4b34:	d28080e7          	jalr	-728(ra) # 5858 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4b38:	f7240613          	addi	a2,s0,-142
    4b3c:	85ce                	mv	a1,s3
    4b3e:	00003517          	auipc	a0,0x3
    4b42:	faa50513          	addi	a0,a0,-86 # 7ae8 <malloc+0x1e56>
    4b46:	00001097          	auipc	ra,0x1
    4b4a:	094080e7          	jalr	148(ra) # 5bda <printf>
        exit(1);
    4b4e:	4505                	li	a0,1
    4b50:	00001097          	auipc	ra,0x1
    4b54:	d08080e7          	jalr	-760(ra) # 5858 <exit>
  close(fd);
    4b58:	854a                	mv	a0,s2
    4b5a:	00001097          	auipc	ra,0x1
    4b5e:	d26080e7          	jalr	-730(ra) # 5880 <close>
  if(n != N){
    4b62:	02800793          	li	a5,40
    4b66:	00fa9763          	bne	s5,a5,4b74 <concreate+0x190>
    if(((i % 3) == 0 && pid == 0) ||
    4b6a:	4a8d                	li	s5,3
    4b6c:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    4b6e:	02800a13          	li	s4,40
    4b72:	a8c9                	j	4c44 <concreate+0x260>
    printf("%s: concreate not enough files in directory listing\n", s);
    4b74:	85ce                	mv	a1,s3
    4b76:	00003517          	auipc	a0,0x3
    4b7a:	f9a50513          	addi	a0,a0,-102 # 7b10 <malloc+0x1e7e>
    4b7e:	00001097          	auipc	ra,0x1
    4b82:	05c080e7          	jalr	92(ra) # 5bda <printf>
    exit(1);
    4b86:	4505                	li	a0,1
    4b88:	00001097          	auipc	ra,0x1
    4b8c:	cd0080e7          	jalr	-816(ra) # 5858 <exit>
      printf("%s: fork failed\n", s);
    4b90:	85ce                	mv	a1,s3
    4b92:	00002517          	auipc	a0,0x2
    4b96:	a9650513          	addi	a0,a0,-1386 # 6628 <malloc+0x996>
    4b9a:	00001097          	auipc	ra,0x1
    4b9e:	040080e7          	jalr	64(ra) # 5bda <printf>
      exit(1);
    4ba2:	4505                	li	a0,1
    4ba4:	00001097          	auipc	ra,0x1
    4ba8:	cb4080e7          	jalr	-844(ra) # 5858 <exit>
      close(open(file, 0));
    4bac:	4581                	li	a1,0
    4bae:	fa840513          	addi	a0,s0,-88
    4bb2:	00001097          	auipc	ra,0x1
    4bb6:	ce6080e7          	jalr	-794(ra) # 5898 <open>
    4bba:	00001097          	auipc	ra,0x1
    4bbe:	cc6080e7          	jalr	-826(ra) # 5880 <close>
      close(open(file, 0));
    4bc2:	4581                	li	a1,0
    4bc4:	fa840513          	addi	a0,s0,-88
    4bc8:	00001097          	auipc	ra,0x1
    4bcc:	cd0080e7          	jalr	-816(ra) # 5898 <open>
    4bd0:	00001097          	auipc	ra,0x1
    4bd4:	cb0080e7          	jalr	-848(ra) # 5880 <close>
      close(open(file, 0));
    4bd8:	4581                	li	a1,0
    4bda:	fa840513          	addi	a0,s0,-88
    4bde:	00001097          	auipc	ra,0x1
    4be2:	cba080e7          	jalr	-838(ra) # 5898 <open>
    4be6:	00001097          	auipc	ra,0x1
    4bea:	c9a080e7          	jalr	-870(ra) # 5880 <close>
      close(open(file, 0));
    4bee:	4581                	li	a1,0
    4bf0:	fa840513          	addi	a0,s0,-88
    4bf4:	00001097          	auipc	ra,0x1
    4bf8:	ca4080e7          	jalr	-860(ra) # 5898 <open>
    4bfc:	00001097          	auipc	ra,0x1
    4c00:	c84080e7          	jalr	-892(ra) # 5880 <close>
      close(open(file, 0));
    4c04:	4581                	li	a1,0
    4c06:	fa840513          	addi	a0,s0,-88
    4c0a:	00001097          	auipc	ra,0x1
    4c0e:	c8e080e7          	jalr	-882(ra) # 5898 <open>
    4c12:	00001097          	auipc	ra,0x1
    4c16:	c6e080e7          	jalr	-914(ra) # 5880 <close>
      close(open(file, 0));
    4c1a:	4581                	li	a1,0
    4c1c:	fa840513          	addi	a0,s0,-88
    4c20:	00001097          	auipc	ra,0x1
    4c24:	c78080e7          	jalr	-904(ra) # 5898 <open>
    4c28:	00001097          	auipc	ra,0x1
    4c2c:	c58080e7          	jalr	-936(ra) # 5880 <close>
    if(pid == 0)
    4c30:	08090363          	beqz	s2,4cb6 <concreate+0x2d2>
      wait(0);
    4c34:	4501                	li	a0,0
    4c36:	00001097          	auipc	ra,0x1
    4c3a:	c2a080e7          	jalr	-982(ra) # 5860 <wait>
  for(i = 0; i < N; i++){
    4c3e:	2485                	addiw	s1,s1,1
    4c40:	0f448563          	beq	s1,s4,4d2a <concreate+0x346>
    file[1] = '0' + i;
    4c44:	0304879b          	addiw	a5,s1,48
    4c48:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    4c4c:	00001097          	auipc	ra,0x1
    4c50:	c04080e7          	jalr	-1020(ra) # 5850 <fork>
    4c54:	892a                	mv	s2,a0
    if(pid < 0){
    4c56:	f2054de3          	bltz	a0,4b90 <concreate+0x1ac>
    if(((i % 3) == 0 && pid == 0) ||
    4c5a:	0354e73b          	remw	a4,s1,s5
    4c5e:	00a767b3          	or	a5,a4,a0
    4c62:	2781                	sext.w	a5,a5
    4c64:	d7a1                	beqz	a5,4bac <concreate+0x1c8>
    4c66:	01671363          	bne	a4,s6,4c6c <concreate+0x288>
       ((i % 3) == 1 && pid != 0)){
    4c6a:	f129                	bnez	a0,4bac <concreate+0x1c8>
      unlink(file);
    4c6c:	fa840513          	addi	a0,s0,-88
    4c70:	00001097          	auipc	ra,0x1
    4c74:	c38080e7          	jalr	-968(ra) # 58a8 <unlink>
      unlink(file);
    4c78:	fa840513          	addi	a0,s0,-88
    4c7c:	00001097          	auipc	ra,0x1
    4c80:	c2c080e7          	jalr	-980(ra) # 58a8 <unlink>
      unlink(file);
    4c84:	fa840513          	addi	a0,s0,-88
    4c88:	00001097          	auipc	ra,0x1
    4c8c:	c20080e7          	jalr	-992(ra) # 58a8 <unlink>
      unlink(file);
    4c90:	fa840513          	addi	a0,s0,-88
    4c94:	00001097          	auipc	ra,0x1
    4c98:	c14080e7          	jalr	-1004(ra) # 58a8 <unlink>
      unlink(file);
    4c9c:	fa840513          	addi	a0,s0,-88
    4ca0:	00001097          	auipc	ra,0x1
    4ca4:	c08080e7          	jalr	-1016(ra) # 58a8 <unlink>
      unlink(file);
    4ca8:	fa840513          	addi	a0,s0,-88
    4cac:	00001097          	auipc	ra,0x1
    4cb0:	bfc080e7          	jalr	-1028(ra) # 58a8 <unlink>
    4cb4:	bfb5                	j	4c30 <concreate+0x24c>
      exit(0);
    4cb6:	4501                	li	a0,0
    4cb8:	00001097          	auipc	ra,0x1
    4cbc:	ba0080e7          	jalr	-1120(ra) # 5858 <exit>
      close(fd);
    4cc0:	00001097          	auipc	ra,0x1
    4cc4:	bc0080e7          	jalr	-1088(ra) # 5880 <close>
    if(pid == 0) {
    4cc8:	bb5d                	j	4a7e <concreate+0x9a>
      close(fd);
    4cca:	00001097          	auipc	ra,0x1
    4cce:	bb6080e7          	jalr	-1098(ra) # 5880 <close>
      wait(&xstatus);
    4cd2:	f6c40513          	addi	a0,s0,-148
    4cd6:	00001097          	auipc	ra,0x1
    4cda:	b8a080e7          	jalr	-1142(ra) # 5860 <wait>
      if(xstatus != 0)
    4cde:	f6c42483          	lw	s1,-148(s0)
    4ce2:	da0493e3          	bnez	s1,4a88 <concreate+0xa4>
  for(i = 0; i < N; i++){
    4ce6:	2905                	addiw	s2,s2,1
    4ce8:	db4905e3          	beq	s2,s4,4a92 <concreate+0xae>
    file[1] = '0' + i;
    4cec:	0309079b          	addiw	a5,s2,48
    4cf0:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4cf4:	fa840513          	addi	a0,s0,-88
    4cf8:	00001097          	auipc	ra,0x1
    4cfc:	bb0080e7          	jalr	-1104(ra) # 58a8 <unlink>
    pid = fork();
    4d00:	00001097          	auipc	ra,0x1
    4d04:	b50080e7          	jalr	-1200(ra) # 5850 <fork>
    if(pid && (i % 3) == 1){
    4d08:	d20502e3          	beqz	a0,4a2c <concreate+0x48>
    4d0c:	036967bb          	remw	a5,s2,s6
    4d10:	d15786e3          	beq	a5,s5,4a1c <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4d14:	20200593          	li	a1,514
    4d18:	fa840513          	addi	a0,s0,-88
    4d1c:	00001097          	auipc	ra,0x1
    4d20:	b7c080e7          	jalr	-1156(ra) # 5898 <open>
      if(fd < 0){
    4d24:	fa0553e3          	bgez	a0,4cca <concreate+0x2e6>
    4d28:	b315                	j	4a4c <concreate+0x68>
}
    4d2a:	60ea                	ld	ra,152(sp)
    4d2c:	644a                	ld	s0,144(sp)
    4d2e:	64aa                	ld	s1,136(sp)
    4d30:	690a                	ld	s2,128(sp)
    4d32:	79e6                	ld	s3,120(sp)
    4d34:	7a46                	ld	s4,112(sp)
    4d36:	7aa6                	ld	s5,104(sp)
    4d38:	7b06                	ld	s6,96(sp)
    4d3a:	6be6                	ld	s7,88(sp)
    4d3c:	610d                	addi	sp,sp,160
    4d3e:	8082                	ret

0000000000004d40 <bigfile>:
{
    4d40:	7139                	addi	sp,sp,-64
    4d42:	fc06                	sd	ra,56(sp)
    4d44:	f822                	sd	s0,48(sp)
    4d46:	f426                	sd	s1,40(sp)
    4d48:	f04a                	sd	s2,32(sp)
    4d4a:	ec4e                	sd	s3,24(sp)
    4d4c:	e852                	sd	s4,16(sp)
    4d4e:	e456                	sd	s5,8(sp)
    4d50:	0080                	addi	s0,sp,64
    4d52:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    4d54:	00003517          	auipc	a0,0x3
    4d58:	df450513          	addi	a0,a0,-524 # 7b48 <malloc+0x1eb6>
    4d5c:	00001097          	auipc	ra,0x1
    4d60:	b4c080e7          	jalr	-1204(ra) # 58a8 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4d64:	20200593          	li	a1,514
    4d68:	00003517          	auipc	a0,0x3
    4d6c:	de050513          	addi	a0,a0,-544 # 7b48 <malloc+0x1eb6>
    4d70:	00001097          	auipc	ra,0x1
    4d74:	b28080e7          	jalr	-1240(ra) # 5898 <open>
    4d78:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    4d7a:	4481                	li	s1,0
    memset(buf, i, SZ);
    4d7c:	00007917          	auipc	s2,0x7
    4d80:	09490913          	addi	s2,s2,148 # be10 <buf>
  for(i = 0; i < N; i++){
    4d84:	4a51                	li	s4,20
  if(fd < 0){
    4d86:	0a054063          	bltz	a0,4e26 <bigfile+0xe6>
    memset(buf, i, SZ);
    4d8a:	25800613          	li	a2,600
    4d8e:	85a6                	mv	a1,s1
    4d90:	854a                	mv	a0,s2
    4d92:	00001097          	auipc	ra,0x1
    4d96:	8cc080e7          	jalr	-1844(ra) # 565e <memset>
    if(write(fd, buf, SZ) != SZ){
    4d9a:	25800613          	li	a2,600
    4d9e:	85ca                	mv	a1,s2
    4da0:	854e                	mv	a0,s3
    4da2:	00001097          	auipc	ra,0x1
    4da6:	ad6080e7          	jalr	-1322(ra) # 5878 <write>
    4daa:	25800793          	li	a5,600
    4dae:	08f51a63          	bne	a0,a5,4e42 <bigfile+0x102>
  for(i = 0; i < N; i++){
    4db2:	2485                	addiw	s1,s1,1
    4db4:	fd449be3          	bne	s1,s4,4d8a <bigfile+0x4a>
  close(fd);
    4db8:	854e                	mv	a0,s3
    4dba:	00001097          	auipc	ra,0x1
    4dbe:	ac6080e7          	jalr	-1338(ra) # 5880 <close>
  fd = open("bigfile.dat", 0);
    4dc2:	4581                	li	a1,0
    4dc4:	00003517          	auipc	a0,0x3
    4dc8:	d8450513          	addi	a0,a0,-636 # 7b48 <malloc+0x1eb6>
    4dcc:	00001097          	auipc	ra,0x1
    4dd0:	acc080e7          	jalr	-1332(ra) # 5898 <open>
    4dd4:	8a2a                	mv	s4,a0
  total = 0;
    4dd6:	4981                	li	s3,0
  for(i = 0; ; i++){
    4dd8:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4dda:	00007917          	auipc	s2,0x7
    4dde:	03690913          	addi	s2,s2,54 # be10 <buf>
  if(fd < 0){
    4de2:	06054e63          	bltz	a0,4e5e <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    4de6:	12c00613          	li	a2,300
    4dea:	85ca                	mv	a1,s2
    4dec:	8552                	mv	a0,s4
    4dee:	00001097          	auipc	ra,0x1
    4df2:	a82080e7          	jalr	-1406(ra) # 5870 <read>
    if(cc < 0){
    4df6:	08054263          	bltz	a0,4e7a <bigfile+0x13a>
    if(cc == 0)
    4dfa:	c971                	beqz	a0,4ece <bigfile+0x18e>
    if(cc != SZ/2){
    4dfc:	12c00793          	li	a5,300
    4e00:	08f51b63          	bne	a0,a5,4e96 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4e04:	01f4d79b          	srliw	a5,s1,0x1f
    4e08:	9fa5                	addw	a5,a5,s1
    4e0a:	4017d79b          	sraiw	a5,a5,0x1
    4e0e:	00094703          	lbu	a4,0(s2)
    4e12:	0af71063          	bne	a4,a5,4eb2 <bigfile+0x172>
    4e16:	12b94703          	lbu	a4,299(s2)
    4e1a:	08f71c63          	bne	a4,a5,4eb2 <bigfile+0x172>
    total += cc;
    4e1e:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4e22:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4e24:	b7c9                	j	4de6 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4e26:	85d6                	mv	a1,s5
    4e28:	00003517          	auipc	a0,0x3
    4e2c:	d3050513          	addi	a0,a0,-720 # 7b58 <malloc+0x1ec6>
    4e30:	00001097          	auipc	ra,0x1
    4e34:	daa080e7          	jalr	-598(ra) # 5bda <printf>
    exit(1);
    4e38:	4505                	li	a0,1
    4e3a:	00001097          	auipc	ra,0x1
    4e3e:	a1e080e7          	jalr	-1506(ra) # 5858 <exit>
      printf("%s: write bigfile failed\n", s);
    4e42:	85d6                	mv	a1,s5
    4e44:	00003517          	auipc	a0,0x3
    4e48:	d3450513          	addi	a0,a0,-716 # 7b78 <malloc+0x1ee6>
    4e4c:	00001097          	auipc	ra,0x1
    4e50:	d8e080e7          	jalr	-626(ra) # 5bda <printf>
      exit(1);
    4e54:	4505                	li	a0,1
    4e56:	00001097          	auipc	ra,0x1
    4e5a:	a02080e7          	jalr	-1534(ra) # 5858 <exit>
    printf("%s: cannot open bigfile\n", s);
    4e5e:	85d6                	mv	a1,s5
    4e60:	00003517          	auipc	a0,0x3
    4e64:	d3850513          	addi	a0,a0,-712 # 7b98 <malloc+0x1f06>
    4e68:	00001097          	auipc	ra,0x1
    4e6c:	d72080e7          	jalr	-654(ra) # 5bda <printf>
    exit(1);
    4e70:	4505                	li	a0,1
    4e72:	00001097          	auipc	ra,0x1
    4e76:	9e6080e7          	jalr	-1562(ra) # 5858 <exit>
      printf("%s: read bigfile failed\n", s);
    4e7a:	85d6                	mv	a1,s5
    4e7c:	00003517          	auipc	a0,0x3
    4e80:	d3c50513          	addi	a0,a0,-708 # 7bb8 <malloc+0x1f26>
    4e84:	00001097          	auipc	ra,0x1
    4e88:	d56080e7          	jalr	-682(ra) # 5bda <printf>
      exit(1);
    4e8c:	4505                	li	a0,1
    4e8e:	00001097          	auipc	ra,0x1
    4e92:	9ca080e7          	jalr	-1590(ra) # 5858 <exit>
      printf("%s: short read bigfile\n", s);
    4e96:	85d6                	mv	a1,s5
    4e98:	00003517          	auipc	a0,0x3
    4e9c:	d4050513          	addi	a0,a0,-704 # 7bd8 <malloc+0x1f46>
    4ea0:	00001097          	auipc	ra,0x1
    4ea4:	d3a080e7          	jalr	-710(ra) # 5bda <printf>
      exit(1);
    4ea8:	4505                	li	a0,1
    4eaa:	00001097          	auipc	ra,0x1
    4eae:	9ae080e7          	jalr	-1618(ra) # 5858 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4eb2:	85d6                	mv	a1,s5
    4eb4:	00003517          	auipc	a0,0x3
    4eb8:	d3c50513          	addi	a0,a0,-708 # 7bf0 <malloc+0x1f5e>
    4ebc:	00001097          	auipc	ra,0x1
    4ec0:	d1e080e7          	jalr	-738(ra) # 5bda <printf>
      exit(1);
    4ec4:	4505                	li	a0,1
    4ec6:	00001097          	auipc	ra,0x1
    4eca:	992080e7          	jalr	-1646(ra) # 5858 <exit>
  close(fd);
    4ece:	8552                	mv	a0,s4
    4ed0:	00001097          	auipc	ra,0x1
    4ed4:	9b0080e7          	jalr	-1616(ra) # 5880 <close>
  if(total != N*SZ){
    4ed8:	678d                	lui	a5,0x3
    4eda:	ee078793          	addi	a5,a5,-288 # 2ee0 <fourteen+0xfa>
    4ede:	02f99363          	bne	s3,a5,4f04 <bigfile+0x1c4>
  unlink("bigfile.dat");
    4ee2:	00003517          	auipc	a0,0x3
    4ee6:	c6650513          	addi	a0,a0,-922 # 7b48 <malloc+0x1eb6>
    4eea:	00001097          	auipc	ra,0x1
    4eee:	9be080e7          	jalr	-1602(ra) # 58a8 <unlink>
}
    4ef2:	70e2                	ld	ra,56(sp)
    4ef4:	7442                	ld	s0,48(sp)
    4ef6:	74a2                	ld	s1,40(sp)
    4ef8:	7902                	ld	s2,32(sp)
    4efa:	69e2                	ld	s3,24(sp)
    4efc:	6a42                	ld	s4,16(sp)
    4efe:	6aa2                	ld	s5,8(sp)
    4f00:	6121                	addi	sp,sp,64
    4f02:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4f04:	85d6                	mv	a1,s5
    4f06:	00003517          	auipc	a0,0x3
    4f0a:	d0a50513          	addi	a0,a0,-758 # 7c10 <malloc+0x1f7e>
    4f0e:	00001097          	auipc	ra,0x1
    4f12:	ccc080e7          	jalr	-820(ra) # 5bda <printf>
    exit(1);
    4f16:	4505                	li	a0,1
    4f18:	00001097          	auipc	ra,0x1
    4f1c:	940080e7          	jalr	-1728(ra) # 5858 <exit>

0000000000004f20 <fsfull>:
{
    4f20:	7171                	addi	sp,sp,-176
    4f22:	f506                	sd	ra,168(sp)
    4f24:	f122                	sd	s0,160(sp)
    4f26:	ed26                	sd	s1,152(sp)
    4f28:	e94a                	sd	s2,144(sp)
    4f2a:	e54e                	sd	s3,136(sp)
    4f2c:	e152                	sd	s4,128(sp)
    4f2e:	fcd6                	sd	s5,120(sp)
    4f30:	f8da                	sd	s6,112(sp)
    4f32:	f4de                	sd	s7,104(sp)
    4f34:	f0e2                	sd	s8,96(sp)
    4f36:	ece6                	sd	s9,88(sp)
    4f38:	e8ea                	sd	s10,80(sp)
    4f3a:	e4ee                	sd	s11,72(sp)
    4f3c:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4f3e:	00003517          	auipc	a0,0x3
    4f42:	cf250513          	addi	a0,a0,-782 # 7c30 <malloc+0x1f9e>
    4f46:	00001097          	auipc	ra,0x1
    4f4a:	c94080e7          	jalr	-876(ra) # 5bda <printf>
  for(nfiles = 0; ; nfiles++){
    4f4e:	4481                	li	s1,0
    name[0] = 'f';
    4f50:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4f54:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4f58:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4f5c:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4f5e:	00003c97          	auipc	s9,0x3
    4f62:	ce2c8c93          	addi	s9,s9,-798 # 7c40 <malloc+0x1fae>
    int total = 0;
    4f66:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4f68:	00007a17          	auipc	s4,0x7
    4f6c:	ea8a0a13          	addi	s4,s4,-344 # be10 <buf>
    name[0] = 'f';
    4f70:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4f74:	0384c7bb          	divw	a5,s1,s8
    4f78:	0307879b          	addiw	a5,a5,48
    4f7c:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4f80:	0384e7bb          	remw	a5,s1,s8
    4f84:	0377c7bb          	divw	a5,a5,s7
    4f88:	0307879b          	addiw	a5,a5,48
    4f8c:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4f90:	0374e7bb          	remw	a5,s1,s7
    4f94:	0367c7bb          	divw	a5,a5,s6
    4f98:	0307879b          	addiw	a5,a5,48
    4f9c:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4fa0:	0364e7bb          	remw	a5,s1,s6
    4fa4:	0307879b          	addiw	a5,a5,48
    4fa8:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4fac:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4fb0:	f5040593          	addi	a1,s0,-176
    4fb4:	8566                	mv	a0,s9
    4fb6:	00001097          	auipc	ra,0x1
    4fba:	c24080e7          	jalr	-988(ra) # 5bda <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4fbe:	20200593          	li	a1,514
    4fc2:	f5040513          	addi	a0,s0,-176
    4fc6:	00001097          	auipc	ra,0x1
    4fca:	8d2080e7          	jalr	-1838(ra) # 5898 <open>
    4fce:	892a                	mv	s2,a0
    if(fd < 0){
    4fd0:	0a055663          	bgez	a0,507c <fsfull+0x15c>
      printf("open %s failed\n", name);
    4fd4:	f5040593          	addi	a1,s0,-176
    4fd8:	00003517          	auipc	a0,0x3
    4fdc:	c7850513          	addi	a0,a0,-904 # 7c50 <malloc+0x1fbe>
    4fe0:	00001097          	auipc	ra,0x1
    4fe4:	bfa080e7          	jalr	-1030(ra) # 5bda <printf>
  while(nfiles >= 0){
    4fe8:	0604c363          	bltz	s1,504e <fsfull+0x12e>
    name[0] = 'f';
    4fec:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4ff0:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4ff4:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4ff8:	4929                	li	s2,10
  while(nfiles >= 0){
    4ffa:	5afd                	li	s5,-1
    name[0] = 'f';
    4ffc:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    5000:	0344c7bb          	divw	a5,s1,s4
    5004:	0307879b          	addiw	a5,a5,48
    5008:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    500c:	0344e7bb          	remw	a5,s1,s4
    5010:	0337c7bb          	divw	a5,a5,s3
    5014:	0307879b          	addiw	a5,a5,48
    5018:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    501c:	0334e7bb          	remw	a5,s1,s3
    5020:	0327c7bb          	divw	a5,a5,s2
    5024:	0307879b          	addiw	a5,a5,48
    5028:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    502c:	0324e7bb          	remw	a5,s1,s2
    5030:	0307879b          	addiw	a5,a5,48
    5034:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    5038:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    503c:	f5040513          	addi	a0,s0,-176
    5040:	00001097          	auipc	ra,0x1
    5044:	868080e7          	jalr	-1944(ra) # 58a8 <unlink>
    nfiles--;
    5048:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    504a:	fb5499e3          	bne	s1,s5,4ffc <fsfull+0xdc>
  printf("fsfull test finished\n");
    504e:	00003517          	auipc	a0,0x3
    5052:	c2250513          	addi	a0,a0,-990 # 7c70 <malloc+0x1fde>
    5056:	00001097          	auipc	ra,0x1
    505a:	b84080e7          	jalr	-1148(ra) # 5bda <printf>
}
    505e:	70aa                	ld	ra,168(sp)
    5060:	740a                	ld	s0,160(sp)
    5062:	64ea                	ld	s1,152(sp)
    5064:	694a                	ld	s2,144(sp)
    5066:	69aa                	ld	s3,136(sp)
    5068:	6a0a                	ld	s4,128(sp)
    506a:	7ae6                	ld	s5,120(sp)
    506c:	7b46                	ld	s6,112(sp)
    506e:	7ba6                	ld	s7,104(sp)
    5070:	7c06                	ld	s8,96(sp)
    5072:	6ce6                	ld	s9,88(sp)
    5074:	6d46                	ld	s10,80(sp)
    5076:	6da6                	ld	s11,72(sp)
    5078:	614d                	addi	sp,sp,176
    507a:	8082                	ret
    int total = 0;
    507c:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    507e:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    5082:	40000613          	li	a2,1024
    5086:	85d2                	mv	a1,s4
    5088:	854a                	mv	a0,s2
    508a:	00000097          	auipc	ra,0x0
    508e:	7ee080e7          	jalr	2030(ra) # 5878 <write>
      if(cc < BSIZE)
    5092:	00aad563          	bge	s5,a0,509c <fsfull+0x17c>
      total += cc;
    5096:	00a989bb          	addw	s3,s3,a0
    while(1){
    509a:	b7e5                	j	5082 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    509c:	85ce                	mv	a1,s3
    509e:	00003517          	auipc	a0,0x3
    50a2:	bc250513          	addi	a0,a0,-1086 # 7c60 <malloc+0x1fce>
    50a6:	00001097          	auipc	ra,0x1
    50aa:	b34080e7          	jalr	-1228(ra) # 5bda <printf>
    close(fd);
    50ae:	854a                	mv	a0,s2
    50b0:	00000097          	auipc	ra,0x0
    50b4:	7d0080e7          	jalr	2000(ra) # 5880 <close>
    if(total == 0)
    50b8:	f20988e3          	beqz	s3,4fe8 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    50bc:	2485                	addiw	s1,s1,1
    50be:	bd4d                	j	4f70 <fsfull+0x50>

00000000000050c0 <badwrite>:
{
    50c0:	7179                	addi	sp,sp,-48
    50c2:	f406                	sd	ra,40(sp)
    50c4:	f022                	sd	s0,32(sp)
    50c6:	ec26                	sd	s1,24(sp)
    50c8:	e84a                	sd	s2,16(sp)
    50ca:	e44e                	sd	s3,8(sp)
    50cc:	e052                	sd	s4,0(sp)
    50ce:	1800                	addi	s0,sp,48
  unlink("junk");
    50d0:	00003517          	auipc	a0,0x3
    50d4:	bb850513          	addi	a0,a0,-1096 # 7c88 <malloc+0x1ff6>
    50d8:	00000097          	auipc	ra,0x0
    50dc:	7d0080e7          	jalr	2000(ra) # 58a8 <unlink>
    50e0:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    50e4:	00003997          	auipc	s3,0x3
    50e8:	ba498993          	addi	s3,s3,-1116 # 7c88 <malloc+0x1ff6>
    write(fd, (char*)0xffffffffffL, 1);
    50ec:	5a7d                	li	s4,-1
    50ee:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    50f2:	20100593          	li	a1,513
    50f6:	854e                	mv	a0,s3
    50f8:	00000097          	auipc	ra,0x0
    50fc:	7a0080e7          	jalr	1952(ra) # 5898 <open>
    5100:	84aa                	mv	s1,a0
    if(fd < 0){
    5102:	06054b63          	bltz	a0,5178 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    5106:	4605                	li	a2,1
    5108:	85d2                	mv	a1,s4
    510a:	00000097          	auipc	ra,0x0
    510e:	76e080e7          	jalr	1902(ra) # 5878 <write>
    close(fd);
    5112:	8526                	mv	a0,s1
    5114:	00000097          	auipc	ra,0x0
    5118:	76c080e7          	jalr	1900(ra) # 5880 <close>
    unlink("junk");
    511c:	854e                	mv	a0,s3
    511e:	00000097          	auipc	ra,0x0
    5122:	78a080e7          	jalr	1930(ra) # 58a8 <unlink>
  for(int i = 0; i < assumed_free; i++){
    5126:	397d                	addiw	s2,s2,-1
    5128:	fc0915e3          	bnez	s2,50f2 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    512c:	20100593          	li	a1,513
    5130:	00003517          	auipc	a0,0x3
    5134:	b5850513          	addi	a0,a0,-1192 # 7c88 <malloc+0x1ff6>
    5138:	00000097          	auipc	ra,0x0
    513c:	760080e7          	jalr	1888(ra) # 5898 <open>
    5140:	84aa                	mv	s1,a0
  if(fd < 0){
    5142:	04054863          	bltz	a0,5192 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    5146:	4605                	li	a2,1
    5148:	00001597          	auipc	a1,0x1
    514c:	cd858593          	addi	a1,a1,-808 # 5e20 <malloc+0x18e>
    5150:	00000097          	auipc	ra,0x0
    5154:	728080e7          	jalr	1832(ra) # 5878 <write>
    5158:	4785                	li	a5,1
    515a:	04f50963          	beq	a0,a5,51ac <badwrite+0xec>
    printf("write failed\n");
    515e:	00003517          	auipc	a0,0x3
    5162:	b4a50513          	addi	a0,a0,-1206 # 7ca8 <malloc+0x2016>
    5166:	00001097          	auipc	ra,0x1
    516a:	a74080e7          	jalr	-1420(ra) # 5bda <printf>
    exit(1);
    516e:	4505                	li	a0,1
    5170:	00000097          	auipc	ra,0x0
    5174:	6e8080e7          	jalr	1768(ra) # 5858 <exit>
      printf("open junk failed\n");
    5178:	00003517          	auipc	a0,0x3
    517c:	b1850513          	addi	a0,a0,-1256 # 7c90 <malloc+0x1ffe>
    5180:	00001097          	auipc	ra,0x1
    5184:	a5a080e7          	jalr	-1446(ra) # 5bda <printf>
      exit(1);
    5188:	4505                	li	a0,1
    518a:	00000097          	auipc	ra,0x0
    518e:	6ce080e7          	jalr	1742(ra) # 5858 <exit>
    printf("open junk failed\n");
    5192:	00003517          	auipc	a0,0x3
    5196:	afe50513          	addi	a0,a0,-1282 # 7c90 <malloc+0x1ffe>
    519a:	00001097          	auipc	ra,0x1
    519e:	a40080e7          	jalr	-1472(ra) # 5bda <printf>
    exit(1);
    51a2:	4505                	li	a0,1
    51a4:	00000097          	auipc	ra,0x0
    51a8:	6b4080e7          	jalr	1716(ra) # 5858 <exit>
  close(fd);
    51ac:	8526                	mv	a0,s1
    51ae:	00000097          	auipc	ra,0x0
    51b2:	6d2080e7          	jalr	1746(ra) # 5880 <close>
  unlink("junk");
    51b6:	00003517          	auipc	a0,0x3
    51ba:	ad250513          	addi	a0,a0,-1326 # 7c88 <malloc+0x1ff6>
    51be:	00000097          	auipc	ra,0x0
    51c2:	6ea080e7          	jalr	1770(ra) # 58a8 <unlink>
  exit(0);
    51c6:	4501                	li	a0,0
    51c8:	00000097          	auipc	ra,0x0
    51cc:	690080e7          	jalr	1680(ra) # 5858 <exit>

00000000000051d0 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    51d0:	7139                	addi	sp,sp,-64
    51d2:	fc06                	sd	ra,56(sp)
    51d4:	f822                	sd	s0,48(sp)
    51d6:	f426                	sd	s1,40(sp)
    51d8:	f04a                	sd	s2,32(sp)
    51da:	ec4e                	sd	s3,24(sp)
    51dc:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    51de:	fc840513          	addi	a0,s0,-56
    51e2:	00000097          	auipc	ra,0x0
    51e6:	686080e7          	jalr	1670(ra) # 5868 <pipe>
    51ea:	06054763          	bltz	a0,5258 <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    51ee:	00000097          	auipc	ra,0x0
    51f2:	662080e7          	jalr	1634(ra) # 5850 <fork>

  if(pid < 0){
    51f6:	06054e63          	bltz	a0,5272 <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    51fa:	ed51                	bnez	a0,5296 <countfree+0xc6>
    close(fds[0]);
    51fc:	fc842503          	lw	a0,-56(s0)
    5200:	00000097          	auipc	ra,0x0
    5204:	680080e7          	jalr	1664(ra) # 5880 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    5208:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    520a:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    520c:	00001997          	auipc	s3,0x1
    5210:	c1498993          	addi	s3,s3,-1004 # 5e20 <malloc+0x18e>
      uint64 a = (uint64) sbrk(4096);
    5214:	6505                	lui	a0,0x1
    5216:	00000097          	auipc	ra,0x0
    521a:	6ca080e7          	jalr	1738(ra) # 58e0 <sbrk>
      if(a == 0xffffffffffffffff){
    521e:	07250763          	beq	a0,s2,528c <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    5222:	6785                	lui	a5,0x1
    5224:	97aa                	add	a5,a5,a0
    5226:	fe978fa3          	sb	s1,-1(a5) # fff <bigdir+0x89>
      if(write(fds[1], "x", 1) != 1){
    522a:	8626                	mv	a2,s1
    522c:	85ce                	mv	a1,s3
    522e:	fcc42503          	lw	a0,-52(s0)
    5232:	00000097          	auipc	ra,0x0
    5236:	646080e7          	jalr	1606(ra) # 5878 <write>
    523a:	fc950de3          	beq	a0,s1,5214 <countfree+0x44>
        printf("write() failed in countfree()\n");
    523e:	00003517          	auipc	a0,0x3
    5242:	aba50513          	addi	a0,a0,-1350 # 7cf8 <malloc+0x2066>
    5246:	00001097          	auipc	ra,0x1
    524a:	994080e7          	jalr	-1644(ra) # 5bda <printf>
        exit(1);
    524e:	4505                	li	a0,1
    5250:	00000097          	auipc	ra,0x0
    5254:	608080e7          	jalr	1544(ra) # 5858 <exit>
    printf("pipe() failed in countfree()\n");
    5258:	00003517          	auipc	a0,0x3
    525c:	a6050513          	addi	a0,a0,-1440 # 7cb8 <malloc+0x2026>
    5260:	00001097          	auipc	ra,0x1
    5264:	97a080e7          	jalr	-1670(ra) # 5bda <printf>
    exit(1);
    5268:	4505                	li	a0,1
    526a:	00000097          	auipc	ra,0x0
    526e:	5ee080e7          	jalr	1518(ra) # 5858 <exit>
    printf("fork failed in countfree()\n");
    5272:	00003517          	auipc	a0,0x3
    5276:	a6650513          	addi	a0,a0,-1434 # 7cd8 <malloc+0x2046>
    527a:	00001097          	auipc	ra,0x1
    527e:	960080e7          	jalr	-1696(ra) # 5bda <printf>
    exit(1);
    5282:	4505                	li	a0,1
    5284:	00000097          	auipc	ra,0x0
    5288:	5d4080e7          	jalr	1492(ra) # 5858 <exit>
      }
    }

    exit(0);
    528c:	4501                	li	a0,0
    528e:	00000097          	auipc	ra,0x0
    5292:	5ca080e7          	jalr	1482(ra) # 5858 <exit>
  }

  close(fds[1]);
    5296:	fcc42503          	lw	a0,-52(s0)
    529a:	00000097          	auipc	ra,0x0
    529e:	5e6080e7          	jalr	1510(ra) # 5880 <close>

  int n = 0;
    52a2:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    52a4:	4605                	li	a2,1
    52a6:	fc740593          	addi	a1,s0,-57
    52aa:	fc842503          	lw	a0,-56(s0)
    52ae:	00000097          	auipc	ra,0x0
    52b2:	5c2080e7          	jalr	1474(ra) # 5870 <read>
    if(cc < 0){
    52b6:	00054563          	bltz	a0,52c0 <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    52ba:	c105                	beqz	a0,52da <countfree+0x10a>
      break;
    n += 1;
    52bc:	2485                	addiw	s1,s1,1
  while(1){
    52be:	b7dd                	j	52a4 <countfree+0xd4>
      printf("read() failed in countfree()\n");
    52c0:	00003517          	auipc	a0,0x3
    52c4:	a5850513          	addi	a0,a0,-1448 # 7d18 <malloc+0x2086>
    52c8:	00001097          	auipc	ra,0x1
    52cc:	912080e7          	jalr	-1774(ra) # 5bda <printf>
      exit(1);
    52d0:	4505                	li	a0,1
    52d2:	00000097          	auipc	ra,0x0
    52d6:	586080e7          	jalr	1414(ra) # 5858 <exit>
  }

  close(fds[0]);
    52da:	fc842503          	lw	a0,-56(s0)
    52de:	00000097          	auipc	ra,0x0
    52e2:	5a2080e7          	jalr	1442(ra) # 5880 <close>
  wait((int*)0);
    52e6:	4501                	li	a0,0
    52e8:	00000097          	auipc	ra,0x0
    52ec:	578080e7          	jalr	1400(ra) # 5860 <wait>
  
  return n;
}
    52f0:	8526                	mv	a0,s1
    52f2:	70e2                	ld	ra,56(sp)
    52f4:	7442                	ld	s0,48(sp)
    52f6:	74a2                	ld	s1,40(sp)
    52f8:	7902                	ld	s2,32(sp)
    52fa:	69e2                	ld	s3,24(sp)
    52fc:	6121                	addi	sp,sp,64
    52fe:	8082                	ret

0000000000005300 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    5300:	7179                	addi	sp,sp,-48
    5302:	f406                	sd	ra,40(sp)
    5304:	f022                	sd	s0,32(sp)
    5306:	ec26                	sd	s1,24(sp)
    5308:	e84a                	sd	s2,16(sp)
    530a:	1800                	addi	s0,sp,48
    530c:	84aa                	mv	s1,a0
    530e:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    5310:	00003517          	auipc	a0,0x3
    5314:	a2850513          	addi	a0,a0,-1496 # 7d38 <malloc+0x20a6>
    5318:	00001097          	auipc	ra,0x1
    531c:	8c2080e7          	jalr	-1854(ra) # 5bda <printf>
  if((pid = fork()) < 0) {
    5320:	00000097          	auipc	ra,0x0
    5324:	530080e7          	jalr	1328(ra) # 5850 <fork>
    5328:	02054e63          	bltz	a0,5364 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    532c:	c929                	beqz	a0,537e <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    532e:	fdc40513          	addi	a0,s0,-36
    5332:	00000097          	auipc	ra,0x0
    5336:	52e080e7          	jalr	1326(ra) # 5860 <wait>
    if(xstatus != 0) 
    533a:	fdc42783          	lw	a5,-36(s0)
    533e:	c7b9                	beqz	a5,538c <run+0x8c>
      printf("FAILED\n");
    5340:	00003517          	auipc	a0,0x3
    5344:	a2050513          	addi	a0,a0,-1504 # 7d60 <malloc+0x20ce>
    5348:	00001097          	auipc	ra,0x1
    534c:	892080e7          	jalr	-1902(ra) # 5bda <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    5350:	fdc42503          	lw	a0,-36(s0)
  }
}
    5354:	00153513          	seqz	a0,a0
    5358:	70a2                	ld	ra,40(sp)
    535a:	7402                	ld	s0,32(sp)
    535c:	64e2                	ld	s1,24(sp)
    535e:	6942                	ld	s2,16(sp)
    5360:	6145                	addi	sp,sp,48
    5362:	8082                	ret
    printf("runtest: fork error\n");
    5364:	00003517          	auipc	a0,0x3
    5368:	9e450513          	addi	a0,a0,-1564 # 7d48 <malloc+0x20b6>
    536c:	00001097          	auipc	ra,0x1
    5370:	86e080e7          	jalr	-1938(ra) # 5bda <printf>
    exit(1);
    5374:	4505                	li	a0,1
    5376:	00000097          	auipc	ra,0x0
    537a:	4e2080e7          	jalr	1250(ra) # 5858 <exit>
    f(s);
    537e:	854a                	mv	a0,s2
    5380:	9482                	jalr	s1
    exit(0);
    5382:	4501                	li	a0,0
    5384:	00000097          	auipc	ra,0x0
    5388:	4d4080e7          	jalr	1236(ra) # 5858 <exit>
      printf("OK\n");
    538c:	00003517          	auipc	a0,0x3
    5390:	9dc50513          	addi	a0,a0,-1572 # 7d68 <malloc+0x20d6>
    5394:	00001097          	auipc	ra,0x1
    5398:	846080e7          	jalr	-1978(ra) # 5bda <printf>
    539c:	bf55                	j	5350 <run+0x50>

000000000000539e <main>:

int
main(int argc, char *argv[])
{
    539e:	bd010113          	addi	sp,sp,-1072
    53a2:	42113423          	sd	ra,1064(sp)
    53a6:	42813023          	sd	s0,1056(sp)
    53aa:	40913c23          	sd	s1,1048(sp)
    53ae:	41213823          	sd	s2,1040(sp)
    53b2:	41313423          	sd	s3,1032(sp)
    53b6:	41413023          	sd	s4,1024(sp)
    53ba:	3f513c23          	sd	s5,1016(sp)
    53be:	3f613823          	sd	s6,1008(sp)
    53c2:	43010413          	addi	s0,sp,1072
    53c6:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    53c8:	4789                	li	a5,2
    53ca:	08f50f63          	beq	a0,a5,5468 <main+0xca>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    53ce:	4785                	li	a5,1
  char *justone = 0;
    53d0:	4901                	li	s2,0
  } else if(argc > 1){
    53d2:	0ca7c963          	blt	a5,a0,54a4 <main+0x106>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    53d6:	00003797          	auipc	a5,0x3
    53da:	daa78793          	addi	a5,a5,-598 # 8180 <malloc+0x24ee>
    53de:	bd040713          	addi	a4,s0,-1072
    53e2:	00003317          	auipc	t1,0x3
    53e6:	18e30313          	addi	t1,t1,398 # 8570 <malloc+0x28de>
    53ea:	0007b883          	ld	a7,0(a5)
    53ee:	0087b803          	ld	a6,8(a5)
    53f2:	6b88                	ld	a0,16(a5)
    53f4:	6f8c                	ld	a1,24(a5)
    53f6:	7390                	ld	a2,32(a5)
    53f8:	7794                	ld	a3,40(a5)
    53fa:	01173023          	sd	a7,0(a4)
    53fe:	01073423          	sd	a6,8(a4)
    5402:	eb08                	sd	a0,16(a4)
    5404:	ef0c                	sd	a1,24(a4)
    5406:	f310                	sd	a2,32(a4)
    5408:	f714                	sd	a3,40(a4)
    540a:	03078793          	addi	a5,a5,48
    540e:	03070713          	addi	a4,a4,48
    5412:	fc679ce3          	bne	a5,t1,53ea <main+0x4c>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    5416:	00003517          	auipc	a0,0x3
    541a:	a0a50513          	addi	a0,a0,-1526 # 7e20 <malloc+0x218e>
    541e:	00000097          	auipc	ra,0x0
    5422:	7bc080e7          	jalr	1980(ra) # 5bda <printf>
  int free0 = countfree();
    5426:	00000097          	auipc	ra,0x0
    542a:	daa080e7          	jalr	-598(ra) # 51d0 <countfree>
    542e:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    5430:	bd843503          	ld	a0,-1064(s0)
    5434:	bd040493          	addi	s1,s0,-1072
  int fail = 0;
    5438:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    543a:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    543c:	e55d                	bnez	a0,54ea <main+0x14c>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    543e:	00000097          	auipc	ra,0x0
    5442:	d92080e7          	jalr	-622(ra) # 51d0 <countfree>
    5446:	85aa                	mv	a1,a0
    5448:	0f455163          	bge	a0,s4,552a <main+0x18c>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    544c:	8652                	mv	a2,s4
    544e:	00003517          	auipc	a0,0x3
    5452:	98a50513          	addi	a0,a0,-1654 # 7dd8 <malloc+0x2146>
    5456:	00000097          	auipc	ra,0x0
    545a:	784080e7          	jalr	1924(ra) # 5bda <printf>
    exit(1);
    545e:	4505                	li	a0,1
    5460:	00000097          	auipc	ra,0x0
    5464:	3f8080e7          	jalr	1016(ra) # 5858 <exit>
    5468:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    546a:	00003597          	auipc	a1,0x3
    546e:	90658593          	addi	a1,a1,-1786 # 7d70 <malloc+0x20de>
    5472:	6488                	ld	a0,8(s1)
    5474:	00000097          	auipc	ra,0x0
    5478:	194080e7          	jalr	404(ra) # 5608 <strcmp>
    547c:	10050563          	beqz	a0,5586 <main+0x1e8>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    5480:	00003597          	auipc	a1,0x3
    5484:	9d858593          	addi	a1,a1,-1576 # 7e58 <malloc+0x21c6>
    5488:	6488                	ld	a0,8(s1)
    548a:	00000097          	auipc	ra,0x0
    548e:	17e080e7          	jalr	382(ra) # 5608 <strcmp>
    5492:	c97d                	beqz	a0,5588 <main+0x1ea>
  } else if(argc == 2 && argv[1][0] != '-'){
    5494:	0084b903          	ld	s2,8(s1)
    5498:	00094703          	lbu	a4,0(s2)
    549c:	02d00793          	li	a5,45
    54a0:	f2f71be3          	bne	a4,a5,53d6 <main+0x38>
    printf("Usage: usertests [-c] [testname]\n");
    54a4:	00003517          	auipc	a0,0x3
    54a8:	8d450513          	addi	a0,a0,-1836 # 7d78 <malloc+0x20e6>
    54ac:	00000097          	auipc	ra,0x0
    54b0:	72e080e7          	jalr	1838(ra) # 5bda <printf>
    exit(1);
    54b4:	4505                	li	a0,1
    54b6:	00000097          	auipc	ra,0x0
    54ba:	3a2080e7          	jalr	930(ra) # 5858 <exit>
          exit(1);
    54be:	4505                	li	a0,1
    54c0:	00000097          	auipc	ra,0x0
    54c4:	398080e7          	jalr	920(ra) # 5858 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    54c8:	40a905bb          	subw	a1,s2,a0
    54cc:	855a                	mv	a0,s6
    54ce:	00000097          	auipc	ra,0x0
    54d2:	70c080e7          	jalr	1804(ra) # 5bda <printf>
        if(continuous != 2)
    54d6:	09498463          	beq	s3,s4,555e <main+0x1c0>
          exit(1);
    54da:	4505                	li	a0,1
    54dc:	00000097          	auipc	ra,0x0
    54e0:	37c080e7          	jalr	892(ra) # 5858 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    54e4:	04c1                	addi	s1,s1,16
    54e6:	6488                	ld	a0,8(s1)
    54e8:	c115                	beqz	a0,550c <main+0x16e>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    54ea:	00090863          	beqz	s2,54fa <main+0x15c>
    54ee:	85ca                	mv	a1,s2
    54f0:	00000097          	auipc	ra,0x0
    54f4:	118080e7          	jalr	280(ra) # 5608 <strcmp>
    54f8:	f575                	bnez	a0,54e4 <main+0x146>
      if(!run(t->f, t->s))
    54fa:	648c                	ld	a1,8(s1)
    54fc:	6088                	ld	a0,0(s1)
    54fe:	00000097          	auipc	ra,0x0
    5502:	e02080e7          	jalr	-510(ra) # 5300 <run>
    5506:	fd79                	bnez	a0,54e4 <main+0x146>
        fail = 1;
    5508:	89d6                	mv	s3,s5
    550a:	bfe9                	j	54e4 <main+0x146>
  if(fail){
    550c:	f20989e3          	beqz	s3,543e <main+0xa0>
    printf("SOME TESTS FAILED\n");
    5510:	00003517          	auipc	a0,0x3
    5514:	8b050513          	addi	a0,a0,-1872 # 7dc0 <malloc+0x212e>
    5518:	00000097          	auipc	ra,0x0
    551c:	6c2080e7          	jalr	1730(ra) # 5bda <printf>
    exit(1);
    5520:	4505                	li	a0,1
    5522:	00000097          	auipc	ra,0x0
    5526:	336080e7          	jalr	822(ra) # 5858 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    552a:	00003517          	auipc	a0,0x3
    552e:	8de50513          	addi	a0,a0,-1826 # 7e08 <malloc+0x2176>
    5532:	00000097          	auipc	ra,0x0
    5536:	6a8080e7          	jalr	1704(ra) # 5bda <printf>
    exit(0);
    553a:	4501                	li	a0,0
    553c:	00000097          	auipc	ra,0x0
    5540:	31c080e7          	jalr	796(ra) # 5858 <exit>
        printf("SOME TESTS FAILED\n");
    5544:	8556                	mv	a0,s5
    5546:	00000097          	auipc	ra,0x0
    554a:	694080e7          	jalr	1684(ra) # 5bda <printf>
        if(continuous != 2)
    554e:	f74998e3          	bne	s3,s4,54be <main+0x120>
      int free1 = countfree();
    5552:	00000097          	auipc	ra,0x0
    5556:	c7e080e7          	jalr	-898(ra) # 51d0 <countfree>
      if(free1 < free0){
    555a:	f72547e3          	blt	a0,s2,54c8 <main+0x12a>
      int free0 = countfree();
    555e:	00000097          	auipc	ra,0x0
    5562:	c72080e7          	jalr	-910(ra) # 51d0 <countfree>
    5566:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    5568:	bd843583          	ld	a1,-1064(s0)
    556c:	d1fd                	beqz	a1,5552 <main+0x1b4>
    556e:	bd040493          	addi	s1,s0,-1072
        if(!run(t->f, t->s)){
    5572:	6088                	ld	a0,0(s1)
    5574:	00000097          	auipc	ra,0x0
    5578:	d8c080e7          	jalr	-628(ra) # 5300 <run>
    557c:	d561                	beqz	a0,5544 <main+0x1a6>
      for (struct test *t = tests; t->s != 0; t++) {
    557e:	04c1                	addi	s1,s1,16
    5580:	648c                	ld	a1,8(s1)
    5582:	f9e5                	bnez	a1,5572 <main+0x1d4>
    5584:	b7f9                	j	5552 <main+0x1b4>
    continuous = 1;
    5586:	4985                	li	s3,1
  } tests[] = {
    5588:	00003797          	auipc	a5,0x3
    558c:	bf878793          	addi	a5,a5,-1032 # 8180 <malloc+0x24ee>
    5590:	bd040713          	addi	a4,s0,-1072
    5594:	00003317          	auipc	t1,0x3
    5598:	fdc30313          	addi	t1,t1,-36 # 8570 <malloc+0x28de>
    559c:	0007b883          	ld	a7,0(a5)
    55a0:	0087b803          	ld	a6,8(a5)
    55a4:	6b88                	ld	a0,16(a5)
    55a6:	6f8c                	ld	a1,24(a5)
    55a8:	7390                	ld	a2,32(a5)
    55aa:	7794                	ld	a3,40(a5)
    55ac:	01173023          	sd	a7,0(a4)
    55b0:	01073423          	sd	a6,8(a4)
    55b4:	eb08                	sd	a0,16(a4)
    55b6:	ef0c                	sd	a1,24(a4)
    55b8:	f310                	sd	a2,32(a4)
    55ba:	f714                	sd	a3,40(a4)
    55bc:	03078793          	addi	a5,a5,48
    55c0:	03070713          	addi	a4,a4,48
    55c4:	fc679ce3          	bne	a5,t1,559c <main+0x1fe>
    printf("continuous usertests starting\n");
    55c8:	00003517          	auipc	a0,0x3
    55cc:	87050513          	addi	a0,a0,-1936 # 7e38 <malloc+0x21a6>
    55d0:	00000097          	auipc	ra,0x0
    55d4:	60a080e7          	jalr	1546(ra) # 5bda <printf>
        printf("SOME TESTS FAILED\n");
    55d8:	00002a97          	auipc	s5,0x2
    55dc:	7e8a8a93          	addi	s5,s5,2024 # 7dc0 <malloc+0x212e>
        if(continuous != 2)
    55e0:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    55e2:	00002b17          	auipc	s6,0x2
    55e6:	7beb0b13          	addi	s6,s6,1982 # 7da0 <malloc+0x210e>
    55ea:	bf95                	j	555e <main+0x1c0>

00000000000055ec <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    55ec:	1141                	addi	sp,sp,-16
    55ee:	e422                	sd	s0,8(sp)
    55f0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    55f2:	87aa                	mv	a5,a0
    55f4:	0585                	addi	a1,a1,1
    55f6:	0785                	addi	a5,a5,1
    55f8:	fff5c703          	lbu	a4,-1(a1)
    55fc:	fee78fa3          	sb	a4,-1(a5)
    5600:	fb75                	bnez	a4,55f4 <strcpy+0x8>
    ;
  return os;
}
    5602:	6422                	ld	s0,8(sp)
    5604:	0141                	addi	sp,sp,16
    5606:	8082                	ret

0000000000005608 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5608:	1141                	addi	sp,sp,-16
    560a:	e422                	sd	s0,8(sp)
    560c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    560e:	00054783          	lbu	a5,0(a0)
    5612:	cb91                	beqz	a5,5626 <strcmp+0x1e>
    5614:	0005c703          	lbu	a4,0(a1)
    5618:	00f71763          	bne	a4,a5,5626 <strcmp+0x1e>
    p++, q++;
    561c:	0505                	addi	a0,a0,1
    561e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    5620:	00054783          	lbu	a5,0(a0)
    5624:	fbe5                	bnez	a5,5614 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    5626:	0005c503          	lbu	a0,0(a1)
}
    562a:	40a7853b          	subw	a0,a5,a0
    562e:	6422                	ld	s0,8(sp)
    5630:	0141                	addi	sp,sp,16
    5632:	8082                	ret

0000000000005634 <strlen>:

uint
strlen(const char *s)
{
    5634:	1141                	addi	sp,sp,-16
    5636:	e422                	sd	s0,8(sp)
    5638:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    563a:	00054783          	lbu	a5,0(a0)
    563e:	cf91                	beqz	a5,565a <strlen+0x26>
    5640:	0505                	addi	a0,a0,1
    5642:	87aa                	mv	a5,a0
    5644:	4685                	li	a3,1
    5646:	9e89                	subw	a3,a3,a0
    5648:	00f6853b          	addw	a0,a3,a5
    564c:	0785                	addi	a5,a5,1
    564e:	fff7c703          	lbu	a4,-1(a5)
    5652:	fb7d                	bnez	a4,5648 <strlen+0x14>
    ;
  return n;
}
    5654:	6422                	ld	s0,8(sp)
    5656:	0141                	addi	sp,sp,16
    5658:	8082                	ret
  for(n = 0; s[n]; n++)
    565a:	4501                	li	a0,0
    565c:	bfe5                	j	5654 <strlen+0x20>

000000000000565e <memset>:

void*
memset(void *dst, int c, uint n)
{
    565e:	1141                	addi	sp,sp,-16
    5660:	e422                	sd	s0,8(sp)
    5662:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    5664:	ca19                	beqz	a2,567a <memset+0x1c>
    5666:	87aa                	mv	a5,a0
    5668:	1602                	slli	a2,a2,0x20
    566a:	9201                	srli	a2,a2,0x20
    566c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    5670:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    5674:	0785                	addi	a5,a5,1
    5676:	fee79de3          	bne	a5,a4,5670 <memset+0x12>
  }
  return dst;
}
    567a:	6422                	ld	s0,8(sp)
    567c:	0141                	addi	sp,sp,16
    567e:	8082                	ret

0000000000005680 <strchr>:

char*
strchr(const char *s, char c)
{
    5680:	1141                	addi	sp,sp,-16
    5682:	e422                	sd	s0,8(sp)
    5684:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5686:	00054783          	lbu	a5,0(a0)
    568a:	cb99                	beqz	a5,56a0 <strchr+0x20>
    if(*s == c)
    568c:	00f58763          	beq	a1,a5,569a <strchr+0x1a>
  for(; *s; s++)
    5690:	0505                	addi	a0,a0,1
    5692:	00054783          	lbu	a5,0(a0)
    5696:	fbfd                	bnez	a5,568c <strchr+0xc>
      return (char*)s;
  return 0;
    5698:	4501                	li	a0,0
}
    569a:	6422                	ld	s0,8(sp)
    569c:	0141                	addi	sp,sp,16
    569e:	8082                	ret
  return 0;
    56a0:	4501                	li	a0,0
    56a2:	bfe5                	j	569a <strchr+0x1a>

00000000000056a4 <gets>:

char*
gets(char *buf, int max)
{
    56a4:	711d                	addi	sp,sp,-96
    56a6:	ec86                	sd	ra,88(sp)
    56a8:	e8a2                	sd	s0,80(sp)
    56aa:	e4a6                	sd	s1,72(sp)
    56ac:	e0ca                	sd	s2,64(sp)
    56ae:	fc4e                	sd	s3,56(sp)
    56b0:	f852                	sd	s4,48(sp)
    56b2:	f456                	sd	s5,40(sp)
    56b4:	f05a                	sd	s6,32(sp)
    56b6:	ec5e                	sd	s7,24(sp)
    56b8:	1080                	addi	s0,sp,96
    56ba:	8baa                	mv	s7,a0
    56bc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    56be:	892a                	mv	s2,a0
    56c0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    56c2:	4aa9                	li	s5,10
    56c4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    56c6:	89a6                	mv	s3,s1
    56c8:	2485                	addiw	s1,s1,1
    56ca:	0344d863          	bge	s1,s4,56fa <gets+0x56>
    cc = read(0, &c, 1);
    56ce:	4605                	li	a2,1
    56d0:	faf40593          	addi	a1,s0,-81
    56d4:	4501                	li	a0,0
    56d6:	00000097          	auipc	ra,0x0
    56da:	19a080e7          	jalr	410(ra) # 5870 <read>
    if(cc < 1)
    56de:	00a05e63          	blez	a0,56fa <gets+0x56>
    buf[i++] = c;
    56e2:	faf44783          	lbu	a5,-81(s0)
    56e6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    56ea:	01578763          	beq	a5,s5,56f8 <gets+0x54>
    56ee:	0905                	addi	s2,s2,1
    56f0:	fd679be3          	bne	a5,s6,56c6 <gets+0x22>
  for(i=0; i+1 < max; ){
    56f4:	89a6                	mv	s3,s1
    56f6:	a011                	j	56fa <gets+0x56>
    56f8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    56fa:	99de                	add	s3,s3,s7
    56fc:	00098023          	sb	zero,0(s3)
  return buf;
}
    5700:	855e                	mv	a0,s7
    5702:	60e6                	ld	ra,88(sp)
    5704:	6446                	ld	s0,80(sp)
    5706:	64a6                	ld	s1,72(sp)
    5708:	6906                	ld	s2,64(sp)
    570a:	79e2                	ld	s3,56(sp)
    570c:	7a42                	ld	s4,48(sp)
    570e:	7aa2                	ld	s5,40(sp)
    5710:	7b02                	ld	s6,32(sp)
    5712:	6be2                	ld	s7,24(sp)
    5714:	6125                	addi	sp,sp,96
    5716:	8082                	ret

0000000000005718 <stat>:

int
stat(const char *n, struct stat *st)
{
    5718:	1101                	addi	sp,sp,-32
    571a:	ec06                	sd	ra,24(sp)
    571c:	e822                	sd	s0,16(sp)
    571e:	e426                	sd	s1,8(sp)
    5720:	e04a                	sd	s2,0(sp)
    5722:	1000                	addi	s0,sp,32
    5724:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5726:	4581                	li	a1,0
    5728:	00000097          	auipc	ra,0x0
    572c:	170080e7          	jalr	368(ra) # 5898 <open>
  if(fd < 0)
    5730:	02054563          	bltz	a0,575a <stat+0x42>
    5734:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5736:	85ca                	mv	a1,s2
    5738:	00000097          	auipc	ra,0x0
    573c:	178080e7          	jalr	376(ra) # 58b0 <fstat>
    5740:	892a                	mv	s2,a0
  close(fd);
    5742:	8526                	mv	a0,s1
    5744:	00000097          	auipc	ra,0x0
    5748:	13c080e7          	jalr	316(ra) # 5880 <close>
  return r;
}
    574c:	854a                	mv	a0,s2
    574e:	60e2                	ld	ra,24(sp)
    5750:	6442                	ld	s0,16(sp)
    5752:	64a2                	ld	s1,8(sp)
    5754:	6902                	ld	s2,0(sp)
    5756:	6105                	addi	sp,sp,32
    5758:	8082                	ret
    return -1;
    575a:	597d                	li	s2,-1
    575c:	bfc5                	j	574c <stat+0x34>

000000000000575e <atoi>:

int
atoi(const char *s)
{
    575e:	1141                	addi	sp,sp,-16
    5760:	e422                	sd	s0,8(sp)
    5762:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    5764:	00054683          	lbu	a3,0(a0)
    5768:	fd06879b          	addiw	a5,a3,-48
    576c:	0ff7f793          	zext.b	a5,a5
    5770:	4625                	li	a2,9
    5772:	02f66863          	bltu	a2,a5,57a2 <atoi+0x44>
    5776:	872a                	mv	a4,a0
  n = 0;
    5778:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
    577a:	0705                	addi	a4,a4,1
    577c:	0025179b          	slliw	a5,a0,0x2
    5780:	9fa9                	addw	a5,a5,a0
    5782:	0017979b          	slliw	a5,a5,0x1
    5786:	9fb5                	addw	a5,a5,a3
    5788:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    578c:	00074683          	lbu	a3,0(a4)
    5790:	fd06879b          	addiw	a5,a3,-48
    5794:	0ff7f793          	zext.b	a5,a5
    5798:	fef671e3          	bgeu	a2,a5,577a <atoi+0x1c>
  return n;
}
    579c:	6422                	ld	s0,8(sp)
    579e:	0141                	addi	sp,sp,16
    57a0:	8082                	ret
  n = 0;
    57a2:	4501                	li	a0,0
    57a4:	bfe5                	j	579c <atoi+0x3e>

00000000000057a6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    57a6:	1141                	addi	sp,sp,-16
    57a8:	e422                	sd	s0,8(sp)
    57aa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    57ac:	02b57463          	bgeu	a0,a1,57d4 <memmove+0x2e>
    while(n-- > 0)
    57b0:	00c05f63          	blez	a2,57ce <memmove+0x28>
    57b4:	1602                	slli	a2,a2,0x20
    57b6:	9201                	srli	a2,a2,0x20
    57b8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    57bc:	872a                	mv	a4,a0
      *dst++ = *src++;
    57be:	0585                	addi	a1,a1,1
    57c0:	0705                	addi	a4,a4,1
    57c2:	fff5c683          	lbu	a3,-1(a1)
    57c6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    57ca:	fee79ae3          	bne	a5,a4,57be <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    57ce:	6422                	ld	s0,8(sp)
    57d0:	0141                	addi	sp,sp,16
    57d2:	8082                	ret
    dst += n;
    57d4:	00c50733          	add	a4,a0,a2
    src += n;
    57d8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    57da:	fec05ae3          	blez	a2,57ce <memmove+0x28>
    57de:	fff6079b          	addiw	a5,a2,-1
    57e2:	1782                	slli	a5,a5,0x20
    57e4:	9381                	srli	a5,a5,0x20
    57e6:	fff7c793          	not	a5,a5
    57ea:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    57ec:	15fd                	addi	a1,a1,-1
    57ee:	177d                	addi	a4,a4,-1
    57f0:	0005c683          	lbu	a3,0(a1)
    57f4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    57f8:	fee79ae3          	bne	a5,a4,57ec <memmove+0x46>
    57fc:	bfc9                	j	57ce <memmove+0x28>

00000000000057fe <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    57fe:	1141                	addi	sp,sp,-16
    5800:	e422                	sd	s0,8(sp)
    5802:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5804:	ca05                	beqz	a2,5834 <memcmp+0x36>
    5806:	fff6069b          	addiw	a3,a2,-1
    580a:	1682                	slli	a3,a3,0x20
    580c:	9281                	srli	a3,a3,0x20
    580e:	0685                	addi	a3,a3,1
    5810:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5812:	00054783          	lbu	a5,0(a0)
    5816:	0005c703          	lbu	a4,0(a1)
    581a:	00e79863          	bne	a5,a4,582a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    581e:	0505                	addi	a0,a0,1
    p2++;
    5820:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5822:	fed518e3          	bne	a0,a3,5812 <memcmp+0x14>
  }
  return 0;
    5826:	4501                	li	a0,0
    5828:	a019                	j	582e <memcmp+0x30>
      return *p1 - *p2;
    582a:	40e7853b          	subw	a0,a5,a4
}
    582e:	6422                	ld	s0,8(sp)
    5830:	0141                	addi	sp,sp,16
    5832:	8082                	ret
  return 0;
    5834:	4501                	li	a0,0
    5836:	bfe5                	j	582e <memcmp+0x30>

0000000000005838 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5838:	1141                	addi	sp,sp,-16
    583a:	e406                	sd	ra,8(sp)
    583c:	e022                	sd	s0,0(sp)
    583e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5840:	00000097          	auipc	ra,0x0
    5844:	f66080e7          	jalr	-154(ra) # 57a6 <memmove>
}
    5848:	60a2                	ld	ra,8(sp)
    584a:	6402                	ld	s0,0(sp)
    584c:	0141                	addi	sp,sp,16
    584e:	8082                	ret

0000000000005850 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5850:	4885                	li	a7,1
 ecall
    5852:	00000073          	ecall
 ret
    5856:	8082                	ret

0000000000005858 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5858:	4889                	li	a7,2
 ecall
    585a:	00000073          	ecall
 ret
    585e:	8082                	ret

0000000000005860 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5860:	488d                	li	a7,3
 ecall
    5862:	00000073          	ecall
 ret
    5866:	8082                	ret

0000000000005868 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5868:	4891                	li	a7,4
 ecall
    586a:	00000073          	ecall
 ret
    586e:	8082                	ret

0000000000005870 <read>:
.global read
read:
 li a7, SYS_read
    5870:	4895                	li	a7,5
 ecall
    5872:	00000073          	ecall
 ret
    5876:	8082                	ret

0000000000005878 <write>:
.global write
write:
 li a7, SYS_write
    5878:	48c1                	li	a7,16
 ecall
    587a:	00000073          	ecall
 ret
    587e:	8082                	ret

0000000000005880 <close>:
.global close
close:
 li a7, SYS_close
    5880:	48d5                	li	a7,21
 ecall
    5882:	00000073          	ecall
 ret
    5886:	8082                	ret

0000000000005888 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5888:	4899                	li	a7,6
 ecall
    588a:	00000073          	ecall
 ret
    588e:	8082                	ret

0000000000005890 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5890:	489d                	li	a7,7
 ecall
    5892:	00000073          	ecall
 ret
    5896:	8082                	ret

0000000000005898 <open>:
.global open
open:
 li a7, SYS_open
    5898:	48bd                	li	a7,15
 ecall
    589a:	00000073          	ecall
 ret
    589e:	8082                	ret

00000000000058a0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    58a0:	48c5                	li	a7,17
 ecall
    58a2:	00000073          	ecall
 ret
    58a6:	8082                	ret

00000000000058a8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    58a8:	48c9                	li	a7,18
 ecall
    58aa:	00000073          	ecall
 ret
    58ae:	8082                	ret

00000000000058b0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    58b0:	48a1                	li	a7,8
 ecall
    58b2:	00000073          	ecall
 ret
    58b6:	8082                	ret

00000000000058b8 <link>:
.global link
link:
 li a7, SYS_link
    58b8:	48cd                	li	a7,19
 ecall
    58ba:	00000073          	ecall
 ret
    58be:	8082                	ret

00000000000058c0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    58c0:	48d1                	li	a7,20
 ecall
    58c2:	00000073          	ecall
 ret
    58c6:	8082                	ret

00000000000058c8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    58c8:	48a5                	li	a7,9
 ecall
    58ca:	00000073          	ecall
 ret
    58ce:	8082                	ret

00000000000058d0 <dup>:
.global dup
dup:
 li a7, SYS_dup
    58d0:	48a9                	li	a7,10
 ecall
    58d2:	00000073          	ecall
 ret
    58d6:	8082                	ret

00000000000058d8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    58d8:	48ad                	li	a7,11
 ecall
    58da:	00000073          	ecall
 ret
    58de:	8082                	ret

00000000000058e0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    58e0:	48b1                	li	a7,12
 ecall
    58e2:	00000073          	ecall
 ret
    58e6:	8082                	ret

00000000000058e8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    58e8:	48b5                	li	a7,13
 ecall
    58ea:	00000073          	ecall
 ret
    58ee:	8082                	ret

00000000000058f0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    58f0:	48b9                	li	a7,14
 ecall
    58f2:	00000073          	ecall
 ret
    58f6:	8082                	ret

00000000000058f8 <waitstat>:
.global waitstat
waitstat:
 li a7, SYS_waitstat
    58f8:	48d9                	li	a7,22
 ecall
    58fa:	00000073          	ecall
 ret
    58fe:	8082                	ret

0000000000005900 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5900:	1101                	addi	sp,sp,-32
    5902:	ec06                	sd	ra,24(sp)
    5904:	e822                	sd	s0,16(sp)
    5906:	1000                	addi	s0,sp,32
    5908:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    590c:	4605                	li	a2,1
    590e:	fef40593          	addi	a1,s0,-17
    5912:	00000097          	auipc	ra,0x0
    5916:	f66080e7          	jalr	-154(ra) # 5878 <write>
}
    591a:	60e2                	ld	ra,24(sp)
    591c:	6442                	ld	s0,16(sp)
    591e:	6105                	addi	sp,sp,32
    5920:	8082                	ret

0000000000005922 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5922:	7139                	addi	sp,sp,-64
    5924:	fc06                	sd	ra,56(sp)
    5926:	f822                	sd	s0,48(sp)
    5928:	f426                	sd	s1,40(sp)
    592a:	f04a                	sd	s2,32(sp)
    592c:	ec4e                	sd	s3,24(sp)
    592e:	0080                	addi	s0,sp,64
    5930:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5932:	c299                	beqz	a3,5938 <printint+0x16>
    5934:	0805c963          	bltz	a1,59c6 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5938:	2581                	sext.w	a1,a1
  neg = 0;
    593a:	4881                	li	a7,0
    593c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5940:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5942:	2601                	sext.w	a2,a2
    5944:	00003517          	auipc	a0,0x3
    5948:	c8c50513          	addi	a0,a0,-884 # 85d0 <digits>
    594c:	883a                	mv	a6,a4
    594e:	2705                	addiw	a4,a4,1
    5950:	02c5f7bb          	remuw	a5,a1,a2
    5954:	1782                	slli	a5,a5,0x20
    5956:	9381                	srli	a5,a5,0x20
    5958:	97aa                	add	a5,a5,a0
    595a:	0007c783          	lbu	a5,0(a5)
    595e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5962:	0005879b          	sext.w	a5,a1
    5966:	02c5d5bb          	divuw	a1,a1,a2
    596a:	0685                	addi	a3,a3,1
    596c:	fec7f0e3          	bgeu	a5,a2,594c <printint+0x2a>
  if(neg)
    5970:	00088c63          	beqz	a7,5988 <printint+0x66>
    buf[i++] = '-';
    5974:	fd070793          	addi	a5,a4,-48
    5978:	00878733          	add	a4,a5,s0
    597c:	02d00793          	li	a5,45
    5980:	fef70823          	sb	a5,-16(a4)
    5984:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5988:	02e05863          	blez	a4,59b8 <printint+0x96>
    598c:	fc040793          	addi	a5,s0,-64
    5990:	00e78933          	add	s2,a5,a4
    5994:	fff78993          	addi	s3,a5,-1
    5998:	99ba                	add	s3,s3,a4
    599a:	377d                	addiw	a4,a4,-1
    599c:	1702                	slli	a4,a4,0x20
    599e:	9301                	srli	a4,a4,0x20
    59a0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    59a4:	fff94583          	lbu	a1,-1(s2)
    59a8:	8526                	mv	a0,s1
    59aa:	00000097          	auipc	ra,0x0
    59ae:	f56080e7          	jalr	-170(ra) # 5900 <putc>
  while(--i >= 0)
    59b2:	197d                	addi	s2,s2,-1
    59b4:	ff3918e3          	bne	s2,s3,59a4 <printint+0x82>
}
    59b8:	70e2                	ld	ra,56(sp)
    59ba:	7442                	ld	s0,48(sp)
    59bc:	74a2                	ld	s1,40(sp)
    59be:	7902                	ld	s2,32(sp)
    59c0:	69e2                	ld	s3,24(sp)
    59c2:	6121                	addi	sp,sp,64
    59c4:	8082                	ret
    x = -xx;
    59c6:	40b005bb          	negw	a1,a1
    neg = 1;
    59ca:	4885                	li	a7,1
    x = -xx;
    59cc:	bf85                	j	593c <printint+0x1a>

00000000000059ce <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    59ce:	7119                	addi	sp,sp,-128
    59d0:	fc86                	sd	ra,120(sp)
    59d2:	f8a2                	sd	s0,112(sp)
    59d4:	f4a6                	sd	s1,104(sp)
    59d6:	f0ca                	sd	s2,96(sp)
    59d8:	ecce                	sd	s3,88(sp)
    59da:	e8d2                	sd	s4,80(sp)
    59dc:	e4d6                	sd	s5,72(sp)
    59de:	e0da                	sd	s6,64(sp)
    59e0:	fc5e                	sd	s7,56(sp)
    59e2:	f862                	sd	s8,48(sp)
    59e4:	f466                	sd	s9,40(sp)
    59e6:	f06a                	sd	s10,32(sp)
    59e8:	ec6e                	sd	s11,24(sp)
    59ea:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    59ec:	0005c903          	lbu	s2,0(a1)
    59f0:	18090f63          	beqz	s2,5b8e <vprintf+0x1c0>
    59f4:	8aaa                	mv	s5,a0
    59f6:	8b32                	mv	s6,a2
    59f8:	00158493          	addi	s1,a1,1
  state = 0;
    59fc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    59fe:	02500a13          	li	s4,37
    5a02:	4c55                	li	s8,21
    5a04:	00003c97          	auipc	s9,0x3
    5a08:	b74c8c93          	addi	s9,s9,-1164 # 8578 <malloc+0x28e6>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    5a0c:	02800d93          	li	s11,40
  putc(fd, 'x');
    5a10:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5a12:	00003b97          	auipc	s7,0x3
    5a16:	bbeb8b93          	addi	s7,s7,-1090 # 85d0 <digits>
    5a1a:	a839                	j	5a38 <vprintf+0x6a>
        putc(fd, c);
    5a1c:	85ca                	mv	a1,s2
    5a1e:	8556                	mv	a0,s5
    5a20:	00000097          	auipc	ra,0x0
    5a24:	ee0080e7          	jalr	-288(ra) # 5900 <putc>
    5a28:	a019                	j	5a2e <vprintf+0x60>
    } else if(state == '%'){
    5a2a:	01498d63          	beq	s3,s4,5a44 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
    5a2e:	0485                	addi	s1,s1,1
    5a30:	fff4c903          	lbu	s2,-1(s1)
    5a34:	14090d63          	beqz	s2,5b8e <vprintf+0x1c0>
    if(state == 0){
    5a38:	fe0999e3          	bnez	s3,5a2a <vprintf+0x5c>
      if(c == '%'){
    5a3c:	ff4910e3          	bne	s2,s4,5a1c <vprintf+0x4e>
        state = '%';
    5a40:	89d2                	mv	s3,s4
    5a42:	b7f5                	j	5a2e <vprintf+0x60>
      if(c == 'd'){
    5a44:	11490c63          	beq	s2,s4,5b5c <vprintf+0x18e>
    5a48:	f9d9079b          	addiw	a5,s2,-99
    5a4c:	0ff7f793          	zext.b	a5,a5
    5a50:	10fc6e63          	bltu	s8,a5,5b6c <vprintf+0x19e>
    5a54:	f9d9079b          	addiw	a5,s2,-99
    5a58:	0ff7f713          	zext.b	a4,a5
    5a5c:	10ec6863          	bltu	s8,a4,5b6c <vprintf+0x19e>
    5a60:	00271793          	slli	a5,a4,0x2
    5a64:	97e6                	add	a5,a5,s9
    5a66:	439c                	lw	a5,0(a5)
    5a68:	97e6                	add	a5,a5,s9
    5a6a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    5a6c:	008b0913          	addi	s2,s6,8
    5a70:	4685                	li	a3,1
    5a72:	4629                	li	a2,10
    5a74:	000b2583          	lw	a1,0(s6)
    5a78:	8556                	mv	a0,s5
    5a7a:	00000097          	auipc	ra,0x0
    5a7e:	ea8080e7          	jalr	-344(ra) # 5922 <printint>
    5a82:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    5a84:	4981                	li	s3,0
    5a86:	b765                	j	5a2e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5a88:	008b0913          	addi	s2,s6,8
    5a8c:	4681                	li	a3,0
    5a8e:	4629                	li	a2,10
    5a90:	000b2583          	lw	a1,0(s6)
    5a94:	8556                	mv	a0,s5
    5a96:	00000097          	auipc	ra,0x0
    5a9a:	e8c080e7          	jalr	-372(ra) # 5922 <printint>
    5a9e:	8b4a                	mv	s6,s2
      state = 0;
    5aa0:	4981                	li	s3,0
    5aa2:	b771                	j	5a2e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5aa4:	008b0913          	addi	s2,s6,8
    5aa8:	4681                	li	a3,0
    5aaa:	866a                	mv	a2,s10
    5aac:	000b2583          	lw	a1,0(s6)
    5ab0:	8556                	mv	a0,s5
    5ab2:	00000097          	auipc	ra,0x0
    5ab6:	e70080e7          	jalr	-400(ra) # 5922 <printint>
    5aba:	8b4a                	mv	s6,s2
      state = 0;
    5abc:	4981                	li	s3,0
    5abe:	bf85                	j	5a2e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5ac0:	008b0793          	addi	a5,s6,8
    5ac4:	f8f43423          	sd	a5,-120(s0)
    5ac8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5acc:	03000593          	li	a1,48
    5ad0:	8556                	mv	a0,s5
    5ad2:	00000097          	auipc	ra,0x0
    5ad6:	e2e080e7          	jalr	-466(ra) # 5900 <putc>
  putc(fd, 'x');
    5ada:	07800593          	li	a1,120
    5ade:	8556                	mv	a0,s5
    5ae0:	00000097          	auipc	ra,0x0
    5ae4:	e20080e7          	jalr	-480(ra) # 5900 <putc>
    5ae8:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5aea:	03c9d793          	srli	a5,s3,0x3c
    5aee:	97de                	add	a5,a5,s7
    5af0:	0007c583          	lbu	a1,0(a5)
    5af4:	8556                	mv	a0,s5
    5af6:	00000097          	auipc	ra,0x0
    5afa:	e0a080e7          	jalr	-502(ra) # 5900 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5afe:	0992                	slli	s3,s3,0x4
    5b00:	397d                	addiw	s2,s2,-1
    5b02:	fe0914e3          	bnez	s2,5aea <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
    5b06:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5b0a:	4981                	li	s3,0
    5b0c:	b70d                	j	5a2e <vprintf+0x60>
        s = va_arg(ap, char*);
    5b0e:	008b0913          	addi	s2,s6,8
    5b12:	000b3983          	ld	s3,0(s6)
        if(s == 0)
    5b16:	02098163          	beqz	s3,5b38 <vprintf+0x16a>
        while(*s != 0){
    5b1a:	0009c583          	lbu	a1,0(s3)
    5b1e:	c5ad                	beqz	a1,5b88 <vprintf+0x1ba>
          putc(fd, *s);
    5b20:	8556                	mv	a0,s5
    5b22:	00000097          	auipc	ra,0x0
    5b26:	dde080e7          	jalr	-546(ra) # 5900 <putc>
          s++;
    5b2a:	0985                	addi	s3,s3,1
        while(*s != 0){
    5b2c:	0009c583          	lbu	a1,0(s3)
    5b30:	f9e5                	bnez	a1,5b20 <vprintf+0x152>
        s = va_arg(ap, char*);
    5b32:	8b4a                	mv	s6,s2
      state = 0;
    5b34:	4981                	li	s3,0
    5b36:	bde5                	j	5a2e <vprintf+0x60>
          s = "(null)";
    5b38:	00003997          	auipc	s3,0x3
    5b3c:	a3898993          	addi	s3,s3,-1480 # 8570 <malloc+0x28de>
        while(*s != 0){
    5b40:	85ee                	mv	a1,s11
    5b42:	bff9                	j	5b20 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
    5b44:	008b0913          	addi	s2,s6,8
    5b48:	000b4583          	lbu	a1,0(s6)
    5b4c:	8556                	mv	a0,s5
    5b4e:	00000097          	auipc	ra,0x0
    5b52:	db2080e7          	jalr	-590(ra) # 5900 <putc>
    5b56:	8b4a                	mv	s6,s2
      state = 0;
    5b58:	4981                	li	s3,0
    5b5a:	bdd1                	j	5a2e <vprintf+0x60>
        putc(fd, c);
    5b5c:	85d2                	mv	a1,s4
    5b5e:	8556                	mv	a0,s5
    5b60:	00000097          	auipc	ra,0x0
    5b64:	da0080e7          	jalr	-608(ra) # 5900 <putc>
      state = 0;
    5b68:	4981                	li	s3,0
    5b6a:	b5d1                	j	5a2e <vprintf+0x60>
        putc(fd, '%');
    5b6c:	85d2                	mv	a1,s4
    5b6e:	8556                	mv	a0,s5
    5b70:	00000097          	auipc	ra,0x0
    5b74:	d90080e7          	jalr	-624(ra) # 5900 <putc>
        putc(fd, c);
    5b78:	85ca                	mv	a1,s2
    5b7a:	8556                	mv	a0,s5
    5b7c:	00000097          	auipc	ra,0x0
    5b80:	d84080e7          	jalr	-636(ra) # 5900 <putc>
      state = 0;
    5b84:	4981                	li	s3,0
    5b86:	b565                	j	5a2e <vprintf+0x60>
        s = va_arg(ap, char*);
    5b88:	8b4a                	mv	s6,s2
      state = 0;
    5b8a:	4981                	li	s3,0
    5b8c:	b54d                	j	5a2e <vprintf+0x60>
    }
  }
}
    5b8e:	70e6                	ld	ra,120(sp)
    5b90:	7446                	ld	s0,112(sp)
    5b92:	74a6                	ld	s1,104(sp)
    5b94:	7906                	ld	s2,96(sp)
    5b96:	69e6                	ld	s3,88(sp)
    5b98:	6a46                	ld	s4,80(sp)
    5b9a:	6aa6                	ld	s5,72(sp)
    5b9c:	6b06                	ld	s6,64(sp)
    5b9e:	7be2                	ld	s7,56(sp)
    5ba0:	7c42                	ld	s8,48(sp)
    5ba2:	7ca2                	ld	s9,40(sp)
    5ba4:	7d02                	ld	s10,32(sp)
    5ba6:	6de2                	ld	s11,24(sp)
    5ba8:	6109                	addi	sp,sp,128
    5baa:	8082                	ret

0000000000005bac <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5bac:	715d                	addi	sp,sp,-80
    5bae:	ec06                	sd	ra,24(sp)
    5bb0:	e822                	sd	s0,16(sp)
    5bb2:	1000                	addi	s0,sp,32
    5bb4:	e010                	sd	a2,0(s0)
    5bb6:	e414                	sd	a3,8(s0)
    5bb8:	e818                	sd	a4,16(s0)
    5bba:	ec1c                	sd	a5,24(s0)
    5bbc:	03043023          	sd	a6,32(s0)
    5bc0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5bc4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5bc8:	8622                	mv	a2,s0
    5bca:	00000097          	auipc	ra,0x0
    5bce:	e04080e7          	jalr	-508(ra) # 59ce <vprintf>
}
    5bd2:	60e2                	ld	ra,24(sp)
    5bd4:	6442                	ld	s0,16(sp)
    5bd6:	6161                	addi	sp,sp,80
    5bd8:	8082                	ret

0000000000005bda <printf>:

void
printf(const char *fmt, ...)
{
    5bda:	711d                	addi	sp,sp,-96
    5bdc:	ec06                	sd	ra,24(sp)
    5bde:	e822                	sd	s0,16(sp)
    5be0:	1000                	addi	s0,sp,32
    5be2:	e40c                	sd	a1,8(s0)
    5be4:	e810                	sd	a2,16(s0)
    5be6:	ec14                	sd	a3,24(s0)
    5be8:	f018                	sd	a4,32(s0)
    5bea:	f41c                	sd	a5,40(s0)
    5bec:	03043823          	sd	a6,48(s0)
    5bf0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5bf4:	00840613          	addi	a2,s0,8
    5bf8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5bfc:	85aa                	mv	a1,a0
    5bfe:	4505                	li	a0,1
    5c00:	00000097          	auipc	ra,0x0
    5c04:	dce080e7          	jalr	-562(ra) # 59ce <vprintf>
}
    5c08:	60e2                	ld	ra,24(sp)
    5c0a:	6442                	ld	s0,16(sp)
    5c0c:	6125                	addi	sp,sp,96
    5c0e:	8082                	ret

0000000000005c10 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5c10:	1141                	addi	sp,sp,-16
    5c12:	e422                	sd	s0,8(sp)
    5c14:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5c16:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5c1a:	00003797          	auipc	a5,0x3
    5c1e:	9d67b783          	ld	a5,-1578(a5) # 85f0 <freep>
    5c22:	a02d                	j	5c4c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5c24:	4618                	lw	a4,8(a2)
    5c26:	9f2d                	addw	a4,a4,a1
    5c28:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5c2c:	6398                	ld	a4,0(a5)
    5c2e:	6310                	ld	a2,0(a4)
    5c30:	a83d                	j	5c6e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5c32:	ff852703          	lw	a4,-8(a0)
    5c36:	9f31                	addw	a4,a4,a2
    5c38:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    5c3a:	ff053683          	ld	a3,-16(a0)
    5c3e:	a091                	j	5c82 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5c40:	6398                	ld	a4,0(a5)
    5c42:	00e7e463          	bltu	a5,a4,5c4a <free+0x3a>
    5c46:	00e6ea63          	bltu	a3,a4,5c5a <free+0x4a>
{
    5c4a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5c4c:	fed7fae3          	bgeu	a5,a3,5c40 <free+0x30>
    5c50:	6398                	ld	a4,0(a5)
    5c52:	00e6e463          	bltu	a3,a4,5c5a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5c56:	fee7eae3          	bltu	a5,a4,5c4a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    5c5a:	ff852583          	lw	a1,-8(a0)
    5c5e:	6390                	ld	a2,0(a5)
    5c60:	02059813          	slli	a6,a1,0x20
    5c64:	01c85713          	srli	a4,a6,0x1c
    5c68:	9736                	add	a4,a4,a3
    5c6a:	fae60de3          	beq	a2,a4,5c24 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    5c6e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5c72:	4790                	lw	a2,8(a5)
    5c74:	02061593          	slli	a1,a2,0x20
    5c78:	01c5d713          	srli	a4,a1,0x1c
    5c7c:	973e                	add	a4,a4,a5
    5c7e:	fae68ae3          	beq	a3,a4,5c32 <free+0x22>
    p->s.ptr = bp->s.ptr;
    5c82:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    5c84:	00003717          	auipc	a4,0x3
    5c88:	96f73623          	sd	a5,-1684(a4) # 85f0 <freep>
}
    5c8c:	6422                	ld	s0,8(sp)
    5c8e:	0141                	addi	sp,sp,16
    5c90:	8082                	ret

0000000000005c92 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5c92:	7139                	addi	sp,sp,-64
    5c94:	fc06                	sd	ra,56(sp)
    5c96:	f822                	sd	s0,48(sp)
    5c98:	f426                	sd	s1,40(sp)
    5c9a:	f04a                	sd	s2,32(sp)
    5c9c:	ec4e                	sd	s3,24(sp)
    5c9e:	e852                	sd	s4,16(sp)
    5ca0:	e456                	sd	s5,8(sp)
    5ca2:	e05a                	sd	s6,0(sp)
    5ca4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5ca6:	02051493          	slli	s1,a0,0x20
    5caa:	9081                	srli	s1,s1,0x20
    5cac:	04bd                	addi	s1,s1,15
    5cae:	8091                	srli	s1,s1,0x4
    5cb0:	0014899b          	addiw	s3,s1,1
    5cb4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5cb6:	00003517          	auipc	a0,0x3
    5cba:	93a53503          	ld	a0,-1734(a0) # 85f0 <freep>
    5cbe:	c515                	beqz	a0,5cea <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5cc0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5cc2:	4798                	lw	a4,8(a5)
    5cc4:	02977f63          	bgeu	a4,s1,5d02 <malloc+0x70>
    5cc8:	8a4e                	mv	s4,s3
    5cca:	0009871b          	sext.w	a4,s3
    5cce:	6685                	lui	a3,0x1
    5cd0:	00d77363          	bgeu	a4,a3,5cd6 <malloc+0x44>
    5cd4:	6a05                	lui	s4,0x1
    5cd6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5cda:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5cde:	00003917          	auipc	s2,0x3
    5ce2:	91290913          	addi	s2,s2,-1774 # 85f0 <freep>
  if(p == (char*)-1)
    5ce6:	5afd                	li	s5,-1
    5ce8:	a895                	j	5d5c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    5cea:	00009797          	auipc	a5,0x9
    5cee:	12678793          	addi	a5,a5,294 # ee10 <base>
    5cf2:	00003717          	auipc	a4,0x3
    5cf6:	8ef73f23          	sd	a5,-1794(a4) # 85f0 <freep>
    5cfa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5cfc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5d00:	b7e1                	j	5cc8 <malloc+0x36>
      if(p->s.size == nunits)
    5d02:	02e48c63          	beq	s1,a4,5d3a <malloc+0xa8>
        p->s.size -= nunits;
    5d06:	4137073b          	subw	a4,a4,s3
    5d0a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5d0c:	02071693          	slli	a3,a4,0x20
    5d10:	01c6d713          	srli	a4,a3,0x1c
    5d14:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5d16:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5d1a:	00003717          	auipc	a4,0x3
    5d1e:	8ca73b23          	sd	a0,-1834(a4) # 85f0 <freep>
      return (void*)(p + 1);
    5d22:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5d26:	70e2                	ld	ra,56(sp)
    5d28:	7442                	ld	s0,48(sp)
    5d2a:	74a2                	ld	s1,40(sp)
    5d2c:	7902                	ld	s2,32(sp)
    5d2e:	69e2                	ld	s3,24(sp)
    5d30:	6a42                	ld	s4,16(sp)
    5d32:	6aa2                	ld	s5,8(sp)
    5d34:	6b02                	ld	s6,0(sp)
    5d36:	6121                	addi	sp,sp,64
    5d38:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5d3a:	6398                	ld	a4,0(a5)
    5d3c:	e118                	sd	a4,0(a0)
    5d3e:	bff1                	j	5d1a <malloc+0x88>
  hp->s.size = nu;
    5d40:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5d44:	0541                	addi	a0,a0,16
    5d46:	00000097          	auipc	ra,0x0
    5d4a:	eca080e7          	jalr	-310(ra) # 5c10 <free>
  return freep;
    5d4e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5d52:	d971                	beqz	a0,5d26 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5d54:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5d56:	4798                	lw	a4,8(a5)
    5d58:	fa9775e3          	bgeu	a4,s1,5d02 <malloc+0x70>
    if(p == freep)
    5d5c:	00093703          	ld	a4,0(s2)
    5d60:	853e                	mv	a0,a5
    5d62:	fef719e3          	bne	a4,a5,5d54 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    5d66:	8552                	mv	a0,s4
    5d68:	00000097          	auipc	ra,0x0
    5d6c:	b78080e7          	jalr	-1160(ra) # 58e0 <sbrk>
  if(p == (char*)-1)
    5d70:	fd5518e3          	bne	a0,s5,5d40 <malloc+0xae>
        return 0;
    5d74:	4501                	li	a0,0
    5d76:	bf45                	j	5d26 <malloc+0x94>
