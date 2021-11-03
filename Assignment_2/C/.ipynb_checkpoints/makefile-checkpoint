#makefile


CC=gcc
CLFAG=-Wall -g

all: libmem.a libmemtest

libmem.a: mem.o
	ar -rc libmem.a mem.o

libmemtest: libmemtest.o libmem.a
	$(CC) -static libmemtest.o -L. -lmem -o libmemtest

mem.o: mem.h mem.c

libmemtest.o: libmemtest.c

.PHONE: all clean

clean: 
	rm -rf *o *.a
	rm -rf libmemtest