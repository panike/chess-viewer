CWEAVE:=$(shell which cweave)
CTANGLE:=$(shell which ctangle)
DVIPS:=$(shell which dvips)
CC:=$(shell which gcc)
TEX:=$(shell which tex)
PDFTEX:=$(shell which pdftex)
RM:=/bin/rm -f
CCOPTS:=-Wall -g
MPOST=$(shell which mpost)
DVIPDFM=$(shell which dvipdfm)
.SUFFIXES:

INCLUDE_DIRS=-I../lib
LIB_DIRS=-L../lib
LIBRARIES=-lchess

%.1: %.mp
	$(MPOST) $*

%: %.o
	make -C ../lib libchess.a
	$(CC) -o $@ $< $(LIB_DIRS) $(LIBRARIES)

%.o: %.c
	make -C ../lib chess.c queue.c
	$(CC) $(CCOPTS) -o $@ -c $< $(INCLUDE_DIRS)

%.c: %.w
	-$(CTANGLE) -bhp $*

%.pdf: %.tex
	$(PDFTEX) $*

%.tex: %.w
	-$(CWEAVE) -bhp $*

%.dvi: %.tex
	$(TEX) $*

%.ps: %.dvi
	$(DVIPS) $* -o

clean:
	$(RM) $(filter-out Makefile $(SOURCES),$(shell /bin/ls))
