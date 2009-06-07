MPOST:=$(shell which mpost || /bin/false)
BASH:=$(shell which bash || /bin/false)
RM:=$(shell which rm || /bin/false)
GS:=$(shell which gs || /bin/false) -q -dSAFER -dBATCH -dNOPAUSE

SOURCES:=CVS Makefile chess-driver.mp chess-pieces.mp chess.mp create-png

all: wwp.png bwp.png wwr.png bwr.png wwn.png bwn.png wwb.png bwb.png \
	wwq.png bwq.png wwk.png bwk.png wbp.png bbp.png wbr.png bbr.png \
	wbn.png bbn.png wbb.png bbb.png wbq.png bbq.png wbk.png bbk.png \
	ws.png bs.png

chess-pieces.1 chess-pieces.2 chess-pieces.3 chess-pieces.4 chess-pieces.5 \
chess-pieces.6 chess-pieces.7 chess-pieces.8 chess-pieces.9 chess-pieces.10 \
chess-pieces.11 chess-pieces.12 chess-pieces.13 chess-pieces.14 \
chess-pieces.15 chess-pieces.16 chess-pieces.17 chess-pieces.18 \
chess-pieces.19 chess-pieces.20 chess-pieces.21 chess-pieces.22 \
chess-pieces.23 chess-pieces.24 chess-pieces.25 chess-pieces.26: \
 chess-driver.mp chess-pieces.mp chess.mp
	$(MPOST) chess-pieces

create-eps=$(GS) -dEPSCrop -sDEVICE=epswrite -sOutputFile=$(1) $(2)

%.png: %.eps
	$(GS) -dEPSCrop -sDEVICE=pnggray -sOutputFile=$@ $<

wwp.eps: chess-pieces.1
	$(call create-eps,$@,$<)
bwp.eps: chess-pieces.2
	$(call create-eps,$@,$<)
wwr.eps: chess-pieces.3
	$(call create-eps,$@,$<)
bwr.eps: chess-pieces.4
	$(call create-eps,$@,$<)
wwn.eps: chess-pieces.5
	$(call create-eps,$@,$<)
bwn.eps: chess-pieces.6
	$(call create-eps,$@,$<)
wwb.eps: chess-pieces.7
	$(call create-eps,$@,$<)
bwb.eps: chess-pieces.8
	$(call create-eps,$@,$<)
wwq.eps: chess-pieces.9
	$(call create-eps,$@,$<)
bwq.eps: chess-pieces.10
	$(call create-eps,$@,$<)
wwk.eps: chess-pieces.11
	$(call create-eps,$@,$<)
bwk.eps: chess-pieces.12
	$(call create-eps,$@,$<)
wbp.eps: chess-pieces.13
	$(call create-eps,$@,$<)
bbp.eps: chess-pieces.14
	$(call create-eps,$@,$<)
wbr.eps: chess-pieces.15
	$(call create-eps,$@,$<)
bbr.eps: chess-pieces.16
	$(call create-eps,$@,$<)
wbn.eps: chess-pieces.17
	$(call create-eps,$@,$<)
bbn.eps: chess-pieces.18
	$(call create-eps,$@,$<)
wbb.eps: chess-pieces.19
	$(call create-eps,$@,$<)
bbb.eps: chess-pieces.20
	$(call create-eps,$@,$<)
wbq.eps: chess-pieces.21
	$(call create-eps,$@,$<)
bbq.eps: chess-pieces.22
	$(call create-eps,$@,$<)
wbk.eps: chess-pieces.23
	$(call create-eps,$@,$<)
bbk.eps: chess-pieces.24
	$(call create-eps,$@,$<)
ws.eps: chess-pieces.25
	$(call create-eps,$@,$<)
bs.eps: chess-pieces.26
	$(call create-eps,$@,$<)

clean:
	$(RM) -f $(filter-out $(SOURCES),$(shell /bin/ls))
