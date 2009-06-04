MPOST:=$(shell which mpost || /bin/false)
BASH:=$(shell which bash || /bin/false)
RM:=$(shell which rm || /bin/false)
SOURCES:=CVS Makefile chess-driver.mp chess-pieces.mp chess.mp create-gifs

all: chess-driver.mp chess-pieces.mp chess.mp
	$(MPOST) chess-pieces
	$(BASH) -v create-gifs	
	touch all

clean:
	$(RM) -f $(filter-out $(SOURCES),$(shell /bin/ls))
