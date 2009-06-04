include ../global.mk

SOURCES:=$(shell /bin/ls *.w *.mp) CVS Makefile commands.vim

compiler.dvi: lexer.1

compiler.pdf: compiler.dvi
	$(TEX) "\let\pdf+ \input compiler"
	$(DVIPDFM) compiler
