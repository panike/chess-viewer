MPOST:=$(shell which mpost || /bin/false)
BASH:=$(shell which bash || /bin/false)
RM:=$(shell which rm || /bin/false)
SOURCES:=CVS Makefile chess-driver.mp chess-pieces.mp chess.mp create-png

all: wwp.png bwp.png wwr.png bwr.png wwn.png bwn.png wwb.png bwb.png wwq.png \
	bwq.png wwk.png bwk.png wbp.png bbp.png wbr.png bbr.png wbn.png bbn.png \
	wbb.png bbb.png wbq.png bbq.png wbk.png bbk.png ws.png bs.png

chess-pieces.1 chess-pieces.2 chess-pieces.3 chess-pieces.4 chess-pieces.5 \
chess-pieces.6 chess-pieces.7 chess-pieces.8 chess-pieces.9 chess-pieces.10 \
chess-pieces.11 chess-pieces.12 chess-pieces.13 chess-pieces.14 \
chess-pieces.15 chess-pieces.16 chess-pieces.17 chess-pieces.18 \
chess-pieces.19 chess-pieces.20 chess-pieces.21 chess-pieces.22 \
chess-pieces.23 chess-pieces.24 chess-pieces.25 chess-pieces.26: \
 chess-driver.mp chess-pieces.mp chess.mp
	$(MPOST) chess-pieces

%.png: %.eps
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pnggray -sOutputFile=$@ $<

wwp.eps: chess-pieces.1
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
bwp.eps: chess-pieces.2
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
wwr.eps: chess-pieces.3
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
bwr.eps: chess-pieces.4
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
wwn.eps: chess-pieces.5
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
bwn.eps: chess-pieces.6
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
wwb.eps: chess-pieces.7
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
bwb.eps: chess-pieces.8
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
wwq.eps: chess-pieces.9
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
bwq.eps: chess-pieces.10
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
wwk.eps: chess-pieces.11
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
bwk.eps: chess-pieces.12
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
wbp.eps: chess-pieces.13
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
bbp.eps: chess-pieces.14
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
wbr.eps: chess-pieces.15
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
bbr.eps: chess-pieces.16
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
wbn.eps: chess-pieces.17
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
bbn.eps: chess-pieces.18
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
wbb.eps: chess-pieces.19
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
bbb.eps: chess-pieces.20
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
wbq.eps: chess-pieces.21
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
bbq.eps: chess-pieces.22
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
wbk.eps: chess-pieces.23
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
bbk.eps: chess-pieces.24
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
ws.eps: chess-pieces.25
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<
bs.eps: chess-pieces.26
	gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=epswrite -sOutputFile=$@ $<

clean:
	$(RM) -f $(filter-out $(SOURCES),$(shell /bin/ls))
