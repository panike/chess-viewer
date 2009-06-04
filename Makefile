clean:
	for i in compiler images lib server tools; \
	do \
		make -C $$i clean; \
	done

all:
	make -C images all
	make -C lib libchess.a
	make -C compiler compiler
	make -C tools db2html tagshtml
	make -C server server
	if [ ! -d bin ]; \
	then \
		mkdir bin; \
	fi
	cp ./compiler/compiler ./tools/db2html \
		./tools/tagshtml ./server/server ./bin
