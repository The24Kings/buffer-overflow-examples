CC=	gcc
CP=	cp
CPP=	cpp
MKDIR=	mkdir
RM=	rm
TAR=	tar

CFLAGS=		-std=c99 -fno-stack-protector -g
LDFLAGS=	-z execstack

TARGETS=	exploit1 exploit2 exploit3 exploit4 

.PHONY: clean dist

all: ${TARGETS}

clean:
	${RM} -f ${TARGETS}
	${RM} -f *~
