include ../global.mk

SOURCES:=$(shell /bin/ls *.w) CVS Makefile commands.vim

CHESS_SOURCES=color_square.c \
copy_board.c \
copy_string.c \
copy_tag_list_node.c \
destroy_game.c \
initialize_board.c \
lookup_on_board.c \
move_node_copy.c \
output_board.c \
piece_string.c \
read_four_bytes.c \
read_game.c \
read_move_text.c \
read_moves.c \
read_quoted_string.c \
read_tags.c \
reset_board.c \
reset_move.c \
tag_list_destroy.c \
update_board.c \
update_board_move.c

QUEUE_SOURCES=queue_allocate.c queue_destroy.c queue_destroy_data.c \
	queue_insert.c queue_iterate.c queue_len.c

$(CHESS_SOURCES): chess.c
$(QUEUE_SOURCES): queue.c

CSOURCES=$(CHESS_SOURCES) $(QUEUE_SOURCES)

%.o: %.c
	$(CC) $(CCOPTS) -o $@ -c $<

libchess.a: $(patsubst %.c,%.o,$(CSOURCES))
	ar rv $@ $?
