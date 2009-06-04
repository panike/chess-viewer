\input epsf
\def\move#1{move_{#1}}
\def\Nothing{{\tt Nothing}}
\def\King{{\tt King}}
\def\Queen{{\tt Queen}}
\def\Bishop{{\tt Bishop}}
\def\Knight{{\tt Knight}}
\def\Rook{{\tt Rook}}
\def\Pawn{{\tt Pawn}}
\def\WhiteKing{{\tt WhiteKing}}
\def\WhiteQueen{{\tt WhiteQueen}}
\def\WhiteBishop{{\tt WhiteBishop}}
\def\WhiteKnight{{\tt WhiteKnight}}
\def\WhiteRook{{\tt WhiteRook}}
\def\WhitePawn{{\tt WhitePawn}}
\def\BlackKing{{\tt BlackKing}}
\def\BlackQueen{{\tt BlackQueen}}
\def\BlackBishop{{\tt BlackBishop}}
\def\BlackKnight{{\tt BlackKnight}}
\def\BlackRook{{\tt BlackRook}}
\def\BlackPawn{{\tt BlackPawn}}
\def\Unknown{{\tt Unknown}}
\def\chessBlack{{\tt Black}}
@s move2 TeX
@s Nothing TeX
@s King TeX
@s Queen TeX
@s Bishop TeX
@s Knight TeX
@s Rook TeX
@s Pawn TeX
@s WhiteKing TeX
@s WhiteQueen TeX
@s WhiteBishop TeX
@s WhiteKnight TeX
@s WhiteRook TeX
@s WhitePawn TeX
@s BlackKing TeX
@s BlackQueen TeX
@s BlackBishop TeX
@s BlackKnight TeX
@s BlackRook TeX
@s BlackPawn TeX
@s chessBlack TeX
@s Unknown TeX
@*Introduction. We write a compiler for the chess server.  The idea is to take
a PGN file, which may have many games in it, and produce a set of ``compiled''
files that will be easy for a server to read and produce a representation of
the chess game.
@c 
@<Header inclusions@>@;
@h
@<Global structure definitions@>@;
@<Global variable declarations@>@;
@<Global function declarations@>@;
@
@s stat int
@s tag_list_node int
@s move_node int
@c int main(int argc, char* argv[])
{
    int ii;
    struct stat filestat,outstat;
    unsigned char* filendp;
    int filefd;
    int numread;
    unsigned char* filp;
    int token_code;
    int parser_state;
    struct move_node chess_move;
    unsigned char ch;

    @<Check for help request@>@;
    @<Initialize the program@>@;
    @<Parse the command line@>@;
    @<Read the file@>@;
    @<Open the database file@>@;	
    filp=filebuf;
    filendp=filebuf+filestat.st_size;
    parser_state=0;
    for(;;) @<The big parsing loop@>@;
    @<Clean up after ourselves@>@;
    return 0;
}
@ @<Print out debugging information@>=
#if 0
fprintf(stdout,"parser_state is %d.\n",parser_state);
fprintf(stdout,"Got token \"%s\".\n",token);
fprintf(stdout,"file offset is %d.\n",filp-filebuf);
@<Print out the current line number@>@;
#endif
@*1Parser implementation. This is the heart of the program. We read tokens,
which we use to decide how to modify |parser_state| and internal tables.
Here is a diagram of the parser.
$$\epsfbox{lexer.2}$$
@<The big parsing loop@>={
    if((token_code=get_token(&filp,filendp,token,MAX_TAG_LENGTH))==END_OF_FILE)
        break;
    @<Print out debugging information@>@;
    switch(parser_state){
        case 0: @<Do cases for state 0@>@;@+break;
        case 1: @<Do cases for state 1@>@;@+break;
        case 2: @<Do cases for state 2@>@;@+break;
        case 3: @<Do cases for state 3@>@;@+break;
        case 4: @<Do cases for state 4@>@;@+break;
        case 5: @<Do cases for state 5@>@;@+break;
        case 6: @<Do cases for state 6@>@;@+break;
        default:
                fprintf(stdout,"Parser implementation error.\n");
                myexit(0);
                break;
    }
}
@ Here I expect to see a left bracket.
@<Do cases for state 0@>=
switch(token_code){
    case LEFT_BRACKET:
        parser_state=1; break;
    case ORDINARY_TOKEN:
        parser_state=0; break;
    default:
        fprintf(stdout,"Syntax error.\n");
        myexit(0);
        break;
}
@ @<Do cases for state 1@>=
if(token_code != ORDINARY_TOKEN){
    fprintf(stdout,"Expected ORDINARY_TOKEN in state 1.\n");
    myexit(0);
}
strcpy(tagname,token);
parser_state=2;
@ We use these as temporary buffers to hold the value of tags.  In PGN, tags
are the metadata associated to the game. The PGN standard says tags can be at
most 255 characters long.
@d MAX_TAG_LENGTH 256
@<Global vari...@>=
unsigned char tagname[MAX_TAG_LENGTH];
unsigned char tagvalue[MAX_TAG_LENGTH];
struct tag_list_node current_tag_list_node = {
    @[.tagname@] = tagname,
    @[.tagvalue@]= tagvalue
};
@ @<Do cases for state 2@>=
if(token_code != QUOTED_STRING){
    fprintf(stdout,"Expected QUOTED_STRING in state 2.\n");
    myexit(0);
}
strcpy(tagvalue,token);
parser_state=3;
@ @<Do cases for state 3@>=
if(token_code != RIGHT_BRACKET){
    fprintf(stdout,"Expected RIGHT_BRACKET in state 3.\n");
    myexit(0);
}
if(!queue_insert(current_tag_list,&current_tag_list_node)){
    fprintf(stdout,"Error inserting the tag list.\n");
    myexit(0);
}
parser_state=4;
@ @<Do cases for state 4@>=
switch(token_code){
    case LEFT_BRACKET:
        parser_state=1; break;
    case GAME_COMMENT:
        queue_insert(move_text,token);
        parser_state=5;
        break;
    @<Handle the subcases of state 4@>@;
    default: fprintf(stdout,"I expected to see either a LEFT_BRACKET or "
                     "a ORDINARY_TOKEN in state 4.");
             fprintf(stdout,"token_code is %d.\n",token_code);
             myexit(0);
             break;
}
@ Now the interesting part begins.  We have reached the end of the tags 
section, and the movetext is about to begin.
 @<Handle the subcases of state 4@>=
case ORDINARY_TOKEN:
switch(lex_token(token,&chess_move)) {
    case NUMBER:
	parser_state=5;@+break;
    case CASTLING: /* Cannot do this */
	fprintf(stdout,"There is an obvious problem: "
		"Castling should not be here.\n");
	myexit(0);
	break;
    case REGULAR_MOVE:
	if(analyze_move(board,&chess_move)){
	    fprintf(stdout,"There is a problem with the move.\n");
	    myexit(0);
	}
	@<Insert the move into que...@>@;
	parser_state=6;
	break;
    case TERMINATOR:
	@<Handle the terminator@>@;@+break;
    default:
    	fprintf(stdout,"Unexpected token \"%s\"\n",token);
	myexit(0);
}
break;
@ @<Initialize the...@>=
reset_move(&chess_move);
@ We expect to see \.{White} move here.
@<Do cases for state 5@>=
if(token_code == ORDINARY_TOKEN) {
        switch(lex_token(token,&chess_move)) {
            case CASTLING:
            case REGULAR_MOVE:
                if(analyze_move(board,&chess_move)){
                    fprintf(stdout,"We cannot get this move.\n"); 
                    myexit(0);
                }
                @<Insert the move into queues and reset |chess_move|@>@;
                parser_state=6;
            case NUMBER:@+break;
            case TERMINATOR:
                @<Handle the terminator@>@;@+break;
            default:
                fprintf(stdout,"This does not seem to be a legitimate move.\n");
                myexit(0);
        }
}@+else if(token_code == GAME_COMMENT)
    queue_insert(move_text,token);
else  {
        fprintf(stdout,"We should have seen a terminator and transferred"
                " to state 0.\n");
        myexit(0);
}
@ @<Insert the move into queues and reset |chess_move|@>=
queue_insert(move_text,token);
queue_insert(move_list,&chess_move);
reset_move(&chess_move);
@ @<Handle the terminator@>=
queue_insert(move_text,token);
write_out_game();
reset_board(board);
parser_state=0;
@ We should see a move by \.{Black} here. This code is almost like the code for
|@<Do cases for state 5@>| except here we ``turn the board around.'' so that we
use the same code for \.{Black} moves as we do for \.{White} moves.
@<Do cases for state 6@>=
if(token_code==ORDINARY_TOKEN){
        switch(lex_token(token,&chess_move)) {
            case CASTLING:
            case REGULAR_MOVE: /* |analyze_move| expects to move White pieces */
                swap_sides(board,&chess_move);
                if(analyze_move(board,&chess_move)){
                    fprintf(stdout,"We cannot get this move.\n"); 
                    myexit(0);
                }
                swap_compressed_move(&chess_move);
                swap_sides(board,&chess_move);
                @<Insert the move into queues and reset |chess_move|@>@;
                parser_state=5;
                break;
            case NUMBER:
                fprintf(stdout,"Did not expect to see a number in state 6.\n");
                myexit(0);
                break;
            case TERMINATOR:
                @<Handle the terminator@>@;@+break;
            default:
                fprintf(stdout,"This does not seem to be a legitimate move.\n");
                myexit(0);
        }
}@+else if(token_code == GAME_COMMENT)
    queue_insert(move_text,token);
else {
    fprintf(stdout,"We should have seen a terminator in state 6.\n");
    myexit(0);
}
@*1Getting the tokens. We have to get tokens and try to understand them.  Here
we get the tokens.  The lexer is responsible for understanding the tokens.
@<Global func...@>=
int is_terminator(unsigned char* tok)
{
    return (strcmp(tok,"1-0")==0 ||
        strcmp(tok,"0-1")==0 ||
        strcmp(tok,"1/2-1/2") == 0 ||
        strcmp(tok,"*")==0);
}
@ @<Global vari...@>=
unsigned char* filebuf;
unsigned char token[256];
@ @<Global funct...@>=
int get_token(unsigned char**filp,unsigned char*fend,unsigned char*tok,
        int toklen);
@ We define some token values that will be used in the parser.
@^Defining tokens@>
@d END_OF_FILE (257)
@d SPACE (258)
@d LEFT_BRACKET (259)
@d RIGHT_BRACKET (260)
@d QUOTE (261)
@d QUOTED_STRING (262)
@d CHARACTER (263)
@d ORDINARY_TOKEN (264)
@d GAME_COMMENT (279)
@d LEFT_BRACE (280)
@d RIGHT_BRACE (281)
@c int get_token(unsigned char**filp,unsigned char*fend,unsigned char*tok,
        int toklen)
{
    int ii;
    if(!filp || !*filp || !fend){
        fprintf(stdout,"There is a problem here in get_token.\n"); 
        myexit(0);
    }
    @<Clear out the spaces@>@;
    @<If we are out of bounds we are done@>@;
    @<If we have a bracket, we are done@>@;
    @<If we have a quoted string we have some thing to do@>@;
    @<A token delimited by braces@>@;
    @<We read characters until the next non-character@>@;
    return ORDINARY_TOKEN; /* Default case */
}
@ @<Global vari...@>=
int lineno; /* Current line number */
@ @<Initialize the...@>=
lineno=1;
@ @<Print out the current line number@>=
fprintf(stdout,"Current line number is %d.\n",lineno);
@ @<Clear out the spaces@>=
while(*filp<fend && char_code[(int)**filp]==SPACE) {
    if(**filp == '\n')
        ++lineno;
    ++*filp; 
}
@ @<If we are out of bounds we are done@>=
    if(*filp>=fend)
        return END_OF_FILE; 
@ @<If we have a bracket, we are done@>=
    if(**filp=='['){
        *tok=**filp;
        *++tok='\0';
        ++*filp;
        return LEFT_BRACKET;
    }
    if(**filp==']'){
        *tok=**filp;
        *++tok='\0';
        ++*filp;
        return RIGHT_BRACKET;
    }
@ @<If we have a quoted string we have some thing to do@>=
    if(char_code[(int)**filp]==QUOTE){
        ++*filp;
        ii=0;
        --toklen;
        while(ii<toklen && *filp<fend && char_code[(int)**filp]!=QUOTE){
            tok[ii]=**filp; 
            ++*filp;
            ++ii;
        }
        if(char_code[(int)**filp]==QUOTE)
            ++*filp;
        else {
            fprintf(stdout,"Quoted string did not end.\n"); 
            myexit(0);
        }
        tok[ii]='\0';
        return QUOTED_STRING;
    }
@ I am not sure what this is supposed to signify.
@<A token delim...@>=
if(char_code[(int)**filp]==LEFT_BRACE){
    ii=0;
    --toklen;
    while(ii<toklen && *filp<fend && char_code[(int)**filp] != RIGHT_BRACE){
        tok[ii]=**filp;
        ++*filp;
        ++ii;
    }
    if(char_code[(int)**filp]==RIGHT_BRACE) {
        tok[ii]=**filp;
        ++*filp;
        ++ii;
    }@+else {
        fprintf(stdout,"Quoted string did not end.\n");
        myexit(0);
    }
    tok[ii]='\0';
    return GAME_COMMENT;
}
@ @<We read characters until the next non-character@>=
ii=0;
--toklen;
while(ii<toklen && *filp<fend && char_code[(int)**filp]==CHARACTER)
    tok[ii++]=*((*filp)++); 
tok[ii]='\0';
@ @<Global vari...@>=
int char_code[256];
@ @<Initialize...@>=
for(ii=0;ii<256;++ii)
    char_code[ii]=SPACE;
for(ii=0;ii<127;++ii)
    if(isgraph(ii))
        char_code[ii]=CHARACTER;
char_code[(int)'"']=QUOTE;
char_code['[']=LEFT_BRACKET;
char_code[']']=RIGHT_BRACKET;
char_code['}']=RIGHT_BRACE;
char_code['{']=LEFT_BRACE;
@*1 Reading the PGN file.  The PGN file drives the program.  We slurp it up all
at once.
@<Read the file@>=
if((filefd=open(filename,O_RDONLY))<0){
    fprintf(stdout,"Could not read file \"%s\".\n",filename);
    myexit(0);
}
@ @<Clean up...@>=
close(filefd);
@ @<Read the file@>=
if(fstat(filefd,&filestat)) {
    fprintf(stdout,"Could not stat file \"%s\".\n",filename);
    myexit(0);
}
@ @<Read the file@>=
if((filebuf=(unsigned char*)malloc(filestat.st_size+1))==(unsigned char*)0){
    fprintf(stdout,"Could not allocate buffer to hold the file.\n");
    myexit(0);
}
@ @<Clean up...@>=
free(filebuf);
@ At the end, we make sure the file ends with a newline. 
@<Read the file@>=
for(ii=0;ii<filestat.st_size;ii+=numread){
    if((numread=read(filefd,&filebuf[ii],filestat.st_size-ii))<0){
        fprintf(stdout,"Error reading from the file.\n"); 
        myexit(0);
    }
    if(numread==0)
        break;
}
filebuf[ii]=(unsigned char)'\n';
@
@d STRING_NULL ((char*)0)
@<Parse the command line@>=
for(ii=1;ii<argc;++ii){
   if(strcmp("-f",argv[ii])==0) {
       ++ii;
       filename=argv[ii];
   }
}
@ @<Global vari...@>=
char* filename;
@ @<Initialize the prog...@>=
filename=STRING_NULL;
@ @<Parse the command line@>=
if(filename==STRING_NULL) {
    fprintf(stdout,"You did not specify a file to compile.");
    @<Print usage statement@>@;
}
@ @<Print usage statement@>=
fprintf(stdout,"\n\nUsage: %s <-f file> <-o outfilename>"
        " [-db dbfile] [-h]\n\n",argv[0]);
myexit(0);
@ This is the first thing we do.  If the user is asking for help, we
just want to print out the usage statement and exit.
@<Check for help request@>=
for(ii=1;ii<argc;++ii)
    if(strcmp("-h",argv[ii])==0){
        @<Print us...@>@;
    }
@ @<Header inclusions@>=
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <ctype.h>
@ Now we write code to decide what the move is.
@^Defining tokens@>
@s Piece int
@d NUMBER (265)
@d CASTLING (266)
@d REGULAR_MOVE (267)
@d TERMINATOR (268)
@ @<Header inclusions@>=
#include <chess.h>
#include <queue.h>
@*1 Utilities. We have some data structures and functions that carry some of
the load for us.
@s Board int
@s Queue int
@<Global vari...@>=
Board* board,*aux_board;
Queue* move_text,*move_list,*current_tag_list;
struct queue_fcns move_list_fcns = {
    @[.copy@]=(queue_copyfn)&move_node_copy,
    @[.destroy@]=free
};
@ @<Global vari...@>=
struct queue_fcns move_text_fcns = {
    @[.copy@]=(queue_copyfn)&copy_string,
    @[.destroy@]=free
};
@ @<Global vari...@>=
struct queue_fcns tag_list_fcns = {
    @[.copy@]=(queue_copyfn)&copy_tag_list_node,
    @[.destroy@]=(queue_destroyfn)&tag_list_destroy
};
@ @<Initialize the...@>=
move_text=queue_allocate(&move_text_fcns);
move_list=queue_allocate(&move_list_fcns);
current_tag_list=queue_allocate(&tag_list_fcns);
if(!move_text || !move_list || !current_tag_list){
    fprintf(stdout,"Failure to get a queue.\n");
    myexit(0);
}
@ @<Initialize the program@>=
board = (Board*)malloc(sizeof(Board));
if(initialize_board(board)){
    fprintf(stdout,"Could not allocate space for a board.\n");
    myexit(0);
}
aux_board = (Board*)malloc(sizeof(Board));
if(initialize_board(aux_board)){
    fprintf(stdout,"Could not allocate space for a aux_board.\n");
    myexit(0);
}
@ @<Clean up...@>=
free(board);
free(aux_board);
queue_destroy(move_text);
queue_destroy(move_list);
queue_destroy(current_tag_list);
@ @<Global func...@>=
void swap_sides(Board*brd,struct move_node*mnode);
void swap_compressed_move(struct move_node*mnode);
@
@d chessBlack Black
@c
void swap_sides(Board*brd,struct move_node*mnode)
{
    Piece tmp;
    int ii,jj,kk;
    for(ii=0;ii<8;++ii){
        jj=0;kk=7;
        while(kk>jj){ /* We use low-level commands here */
            tmp=brd->files[ii][jj];
            brd->files[ii][jj]=brd->files[ii][kk];
            brd->files[ii][kk]=tmp;
            --kk;
            ++jj;
        }
    }
    for(ii=0;ii<8;++ii)
        for(jj=0;jj<8;++jj)
            if(brd->files[ii][jj] != Nothing)
                brd->files[ii][jj] ^= chessBlack;
    if(mnode->source_rank != Unknown)
        mnode->source_rank = 7-mnode->source_rank;
    if(mnode->dest_rank != Unknown)
        mnode->dest_rank = 7-mnode->dest_rank;
}
@
@d COMPRESSED_MOVE_MASK (((0x7)<<6)|(0x7))
@c
void swap_compressed_move(struct move_node*mnode)
{
    mnode->move ^= COMPRESSED_MOVE_MASK;
    if(mnode->move2 != 0)
        mnode->move2 ^= COMPRESSED_MOVE_MASK;
}
@*Lexer.  The lexer is reached when we think we have a move, and we try
to understand what it is trying to tell us.  Note that we work very closely
with |analyze_move|. At the end of |lex_token|, we should have that the
following fields in a |struct move_node| are initialized: |piece|, |dest_file|,
and |dest_rank|. Below is a diagram of the lexer
$$\epsfbox{lexer.1}$$
@<Global func...@>=
int lex_token(unsigned char*,struct move_node*);
@ @<Global func...@>=
int is_castling(unsigned char*tok,struct move_node*mnode)
{
    if(strcmp(tok,"O-O")==0){
        mnode->piece=King;
        mnode->source_file='e'-'a';
        mnode->dest_file='g'-'a';
        return 1;
    } else if(strcmp(tok,"O-O-O")==0){
        mnode->piece=King;
        mnode->source_file='e'-'a';
        mnode->dest_file='c'-'a';
        return 1;
    }
    return 0;
}
@ The lexer is probably the most complicated thing in the program, since we
have to deal with so many cases.
@c int lex_token(unsigned char*tok,struct move_node*mnode)
{
    int lex_state;

    if(!tok || !mnode){
        fprintf(stdout,"Null arguments in lex_token.\n"); 
        myexit(0);
    }
    if(is_terminator(tok))
        return TERMINATOR;
    if(is_castling(tok,mnode))
        return CASTLING;
    if(lex_char_codes[*tok]==DIGIT || lex_char_codes[*tok]==CHESS_RANK)
        return NUMBER;
    lex_state=0;
    while(*tok){
        switch(lex_state){
            case 0: @<The lexer is in state 0@>@;@+break;
            case 1: @<The lexer is in state 1@>@;@+break;
            case 2: @<The lexer is in state 2@>@;@+break;
            case 3: @<The lexer is in state 3@>@;@+break;
            case 4: @<The lexer is in state 4@>@;@+break;
            case 5: @<The lexer is in state 5@>@;@+break;
            case 6: @<The lexer is in state 6@>@;@+break;
            case 7: @<The lexer is in state 7@>@;@+break;
            case 8: @<The lexer is in state 8@>@;@+break;
            case 9: @<The lexer is in state 9@>@;@+break;
            case 10: @<Handle lexer state 10@>@;@+break;
            case 11: @<Handle lexer state 11@>@;@+break;
            case 12: @<Handle lexer state 12@>@;@+break;
            case 13: @<Handle lexer state 13@>@;@+break;
            case 14: @<Handle lexer state 14@>@;@+break;
            case 15: @<Handle lexer state 15@>@;@+break;
            case 16: @<Handle lexer state 16@>@;@+break;
            case 17: @<Handle lexer state 17@>@;@+break;
            case 18: @<Handle lexer state 18@>@;@+break;
            case 19: @<Handle lexer state 19@>@;@+break;
            default: 
                fprintf(stdout,"There is an error in the lexer.\n");
                myexit(0);
        } 
        ++tok;
    }
    return REGULAR_MOVE;
}
@ @^Defining tokens@>
@d CHESS_RANK (269)
@d CHESS_FILE (270)
@d CHESS_PIECE (271)
@d DIGIT (272)
@d CHESS_CHECK (273)    
@d CHESS_LEXER_NULL (274)
@d CHESS_TAKES (275)
@d CHESS_CASTLES (276)
@d CHESS_CASTLES_SEPARATOR (277)
@d CHESS_PROMOTION (278)
@<Global vari...@>=
int lex_char_codes[256];
@ @<Initialize the...@>=
for(ii=0;ii<256;++ii)
    lex_char_codes[ii]=CHESS_LEXER_NULL;
lex_char_codes['=']=CHESS_PROMOTION;
lex_char_codes['a']=CHESS_FILE;
lex_char_codes['b']=CHESS_FILE;
lex_char_codes['c']=CHESS_FILE;
lex_char_codes['d']=CHESS_FILE;
lex_char_codes['e']=CHESS_FILE;
lex_char_codes['f']=CHESS_FILE;
lex_char_codes['g']=CHESS_FILE;
lex_char_codes['h']=CHESS_FILE;
@ @<Initialize the...@>=
lex_char_codes['1']=CHESS_RANK;
lex_char_codes['2']=CHESS_RANK;
lex_char_codes['3']=CHESS_RANK;
lex_char_codes['4']=CHESS_RANK;
lex_char_codes['5']=CHESS_RANK;
lex_char_codes['6']=CHESS_RANK;
lex_char_codes['7']=CHESS_RANK;
lex_char_codes['8']=CHESS_RANK;
@ @<Initialize the...@>=
lex_char_codes['0']=lex_char_codes['9']=DIGIT;
lex_char_codes['x']=CHESS_TAKES;
lex_char_codes['K']=CHESS_PIECE;
lex_char_codes['Q']=CHESS_PIECE;
lex_char_codes['B']=CHESS_PIECE;
lex_char_codes['N']=CHESS_PIECE;
lex_char_codes['R']=CHESS_PIECE;
lex_char_codes['P']=CHESS_PIECE;
lex_char_codes['+']=CHESS_CHECK;
lex_char_codes['#']=CHESS_CHECK;
lex_char_codes['O']=CHESS_CASTLES;
lex_char_codes['-']=CHESS_CASTLES_SEPARATOR;
@ @<The lexer is in state 0@>=
switch(lex_char_codes[*tok]){
    case CHESS_FILE:
        mnode->piece=Pawn;
        mnode->dest_file=*tok-'a';
        lex_state=1;
        break;
    case CHESS_PIECE:
        switch(*tok){
            case 'K': mnode->piece=King;@+break;
            case 'Q': mnode->piece=Queen;@+break;
            case 'B': mnode->piece=Bishop;@+break;
            case 'N': mnode->piece=Knight;@+break;
            case 'R': mnode->piece=Rook;@+break;
            case 'P': mnode->piece=Pawn;@+break;
            default: fprintf(stdout,"Check the lexer, something is broken.\n");
                     myexit(0);
        }
        lex_state=4;@+break;
    case CHESS_CASTLES:
        lex_state=16;@+break;
    default:
        fprintf(stdout,"Lexing error.\n");
        myexit(0);@+ break;
}
@ @<The lexer is in state 1@>=
switch(lex_char_codes[*tok]){
    case CHESS_RANK:
        mnode->dest_rank=*tok-'1';
        mnode->source_file=mnode->dest_file;
        lex_state=2;@+break;
    case CHESS_TAKES:
        mnode->source_file=mnode->dest_file;
        mnode->dest_file=Unknown;
        lex_state=3;@+break;
    default:
        fprintf(stdout,"Lexing error in lex state 1.\n");
        myexit(0);@+break;
}
@ @<The lexer is in state 2@>=
switch(lex_char_codes[*tok]){
    case CHESS_CHECK:
        lex_state=7;@+break;
    case CHESS_PROMOTION:
        lex_state=5;@+break;
    default: fprintf(stdout,"Lexing error in lex state 2.\n");
             myexit(0);@+break;
}
@ @<The lexer is in state 3@>=
if(lex_char_codes[*tok] == CHESS_FILE){
   mnode->dest_file=*tok-'a'; 
   lex_state=8;
}@+else{
    fprintf(stdout,"In lex state 3, I am confused.\n");
    myexit(0);
}
@ @<The lexer is in state 4@>=
switch(lex_char_codes[*tok]){
    case CHESS_FILE:
        mnode->dest_file=*tok-'a';
        lex_state=9;@+break;
    case CHESS_RANK:
        mnode->source_rank=*tok-'1';
        lex_state=13;@+break;
    case CHESS_TAKES:
        lex_state=12;@+break; 
    default:
        fprintf(stdout,"In lex state 4, I am confused.\n");
        myexit(0);
}
@ @<The lexer is in state 5@>=
if(lex_char_codes[*tok] == CHESS_PIECE){
    switch(*tok){
        case 'Q': mnode->move |= QUEEN_PROMOTION;@+break;
        case 'B': mnode->move |= BISHOP_PROMOTION;@+break;
        case 'N': mnode->move |= KNIGHT_PROMOTION;@+break;
        case 'R': mnode->move |= ROOK_PROMOTION;@+break;
        default:
          fprintf(stdout,"That pawn promotion is not going to work.\n");
          myexit(0);
    }
    lex_state=6;
}@+else {
    fprintf(stdout,"Unexpected token in state 5.\n"); 
    myexit(0);
}
@ @<The lexer is in state 6@>=
if(lex_char_codes[*tok]!=CHESS_CHECK){
    fprintf(stdout,"Somehow got to lex state 6 unexpectedly.\n");
    myexit(0);
}
lex_state=7;
@ This is a historical artifact. State $7$ is never used.
@<The lexer is in state 7@>=
fprintf(stdout,"The lexer saw an unexpected character in state 7.\n");
return GAME_COMMENT;
@ @<The lexer is in state 8@>=
if(lex_char_codes[*tok]==CHESS_RANK){
    mnode->dest_rank=*tok-'1';
    lex_state=2;
}@+else {
    fprintf(stdout,"I am confused in lex state 8.\n");
    myexit(0);
}
@ @<The lexer is in state 9@>=
switch(lex_char_codes[*tok]){
    case CHESS_FILE:
        mnode->source_file=mnode->dest_file;
        mnode->dest_file=*tok-'a';
        lex_state=10;@+break;
    case CHESS_RANK:
        mnode->dest_rank=*tok-'1';
        lex_state=11;@+break;
    case CHESS_TAKES:
        mnode->source_file=mnode->dest_file;
        mnode->dest_file=Unknown;
        lex_state=12;@+break;
    default:
        fprintf(stdout,"I am confused in state 9.\n");
        myexit(0);@+break;
}
@ @<Handle lexer state 10@>=
if(lex_char_codes[*tok]==CHESS_RANK){
    mnode->dest_rank=*tok-'1';
    lex_state=6;@+break;
}@+else{
    fprintf(stdout,"I am confused in lex state 10.\n");
    myexit(0);
}
@ @<Handle lexer state 11@>=
switch(lex_char_codes[*tok]){
    case CHESS_TAKES:
        mnode->source_file=mnode->dest_file;
        mnode->source_rank=mnode->dest_rank;
        mnode->dest_file=Unknown;
        mnode->dest_rank=Unknown;
        lex_state=12;@+break;
    case CHESS_FILE:
        mnode->source_file=mnode->dest_file;
        mnode->source_rank=mnode->dest_rank;
        mnode->dest_file=*tok-'a';
        mnode->dest_rank=Unknown;
        lex_state=10;@+break;
    case CHESS_CHECK:
        lex_state=7;@+break;
    default:
        fprintf(stdout,"I am confused in lex state 11.\n");
        myexit(0);
}
@ @<Handle lexer state 12@>=
if(lex_char_codes[*tok]==CHESS_FILE){
    mnode->dest_file=*tok-'a';
    lex_state=14;@+break;
}@+else{
    fprintf(stdout,"I am confused in lex state 12.\n");
    myexit(0);
}
@ @<Handle lexer state 13@>=
switch(lex_char_codes[*tok]){
    case CHESS_TAKES:
        lex_state=12;@+break;
    case CHESS_FILE:
        mnode->dest_file=*tok-'a';
        lex_state=14;@+break;
    default:
        fprintf(stdout,"I am confused in lex state 13.\n");
        myexit(0);
}
@ @<Handle lexer state 14@>=
if(lex_char_codes[*tok]==CHESS_RANK){
    mnode->dest_rank=*tok-'1';
    lex_state=6;@+break;
}@+else{
    fprintf(stdout,"I am confused in lex state 14.\n");
    myexit(0);
}
@ @<Handle lexer state 15@>=
fprintf(stdout,"You should not get to lex state 15.\n");
myexit(0);
@ @<Handle lexer state 16@>=
if(lex_char_codes[*tok]==CHESS_CASTLES_SEPARATOR)
    lex_state=17;
else {
    fprintf(stdout,"I am confused in lex state 16.\n");
    myexit(0);
}
@ @<Handle lexer state 17@>=
if(lex_char_codes[*tok]==CHESS_CASTLES)
    lex_state=18;
else {
    fprintf(stdout,"I am confused in lex state 17.\n");
    myexit(0);
}
@ @<Handle lexer state 18@>=
switch(lex_char_codes[*tok]){
    case CHESS_CASTLES_SEPARATOR:
       lex_state=19;@+break; 
    case CHESS_CHECK:
       mnode->piece=King;
       mnode->source_file='e'-'a';
       mnode->dest_file='g'-'a';
       lex_state=7;
       return CASTLING;
    default: 
        fprintf(stdout,"I am confused in lex state 18.\n");
        myexit(0);
}
@ @<Handle lexer state 19@>=
if(lex_char_codes[*tok]==CHESS_CASTLES){
   mnode->piece=King;
   mnode->source_file='e'-'a';
   mnode->dest_file='c'-'a';
   lex_state=6;
}@+else{
    fprintf(stdout,"I am confused in lex state 18.\n");
    myexit(0);
    
}
@*1 Analyze the move.  This subroutine works in tandem with |lex_token| to
finally decide what the correct move is based on the text and the current state
of the board.
@<Global func...@>=
int analyze_move(Board*,struct move_node*);
@ @c
int analyze_move(Board*brd,struct move_node*mnode)
{
    int promotion;
    int ret;
    @<First we check for castling@>@;
    @<Then we check for {\it en passant} capture@>@;
    @<Check for pawn promotion@>@;
    ret=(*do_piece_move[mnode->piece & 0xf])(brd,mnode);
print_out_results: 
    return ret;
}
@ @<Global vari...@>=
int @[@] (*do_piece_move[16])(Board*,struct move_node*);
@ @<Global func...@>=
int default_piece_move(Board*p,struct move_node*mnp)
{
    return 1;
}
@ @<Initialize the p...@>=
for(ii=0;ii<16;++ii)
    do_piece_move[ii]=default_piece_move;
do_piece_move[King]=do_king_move;@+do_piece_move[Queen]=do_queen_move;
do_piece_move[Rook]=do_rook_move;@+do_piece_move[Bishop]=do_bishop_move;
do_piece_move[Knight]=do_knight_move;@+do_piece_move[Pawn]=do_pawn_move;
@ We encode the move in bits.
@<Global func...@>=
int move_encode(int sf,int sr,int df,int dr)
{
    int ret;
    ret=0;
    sf &= 0x7;@+sr &= 0x7;@+df &= 0x7;@+dr &= 0x7;
    ret |= sf << 9;@+ret |= sr << 6;@+ret |= df << 3;@+ret |= dr;
    return ret;
}
@ @<First we check for castling@>=
if(mnode->piece==King && mnode->source_file==4 && mnode->dest_file==6){
    mnode->source_rank=0;
    mnode->dest_rank=0;
    mnode->move = move_encode(4,0,6,0);
    mnode->move2= move_encode(7,0,5,0);
    update_board(brd,4,0,6,0);
    update_board(brd,7,0,5,0);
    ret=0;
    goto print_out_results;
}
@ @<First we check for castling@>=
if(mnode->piece==King && mnode->source_file==4 && mnode->dest_file==2){
    mnode->source_rank=0;
    mnode->dest_rank=0;
    mnode->move = move_encode(4,0,2,0);
    mnode->move2= move_encode(0,0,3,0);
    update_board(brd,4,0,2,0);
    update_board(brd,0,0,3,0);
    ret=0;
    goto print_out_results;
}
@ This code is in error @<Then we check for...@>=
if(mnode->piece==Pawn && mnode->source_file != mnode->dest_file &&
        mnode->dest_rank == 5 &&
        lookup_on_board(brd,mnode->dest_file,mnode->dest_rank)==Nothing){
                mnode->source_rank=4;
                mnode->move =
                    move_encode(mnode->dest_file,4,mnode->dest_file,5); 
                mnode->move2 =
                    move_encode(mnode->source_file,4,mnode->dest_file,5);
                update_board(brd,mnode->dest_file,4,mnode->dest_file,5);
                update_board(brd,mnode->source_file,4,mnode->dest_file,5);
                ret=0;
                goto print_out_results;
            }
@ @<Global func...@>=    
int do_king_move(Board*brd,struct move_node*mnode);
int do_queen_move(Board*brd,struct move_node*mnode);
int do_bishop_move(Board*brd,struct move_node*mnode);
int do_knight_move(Board*brd,struct move_node*mnode);
int do_rook_move(Board*brd,struct move_node*mnode);
int do_pawn_move(Board*brd,struct move_node*mnode);
@ Let us define a macro to make our intention clear.
@d REACHED_EIGHTH_RANK(p) ((p) & ((0x7)<<12))
@<Check for pawn...@>=
if(mnode->piece == Pawn && REACHED_EIGHTH_RANK(mnode->move)){
    promotion = mnode->move & PROMOTION_MASK;
    mnode->source_rank=6;
    mnode->move=move_encode(mnode->source_file,6,mnode->dest_file,7);
    mnode->move |= promotion;
    update_board(brd,mnode->source_file,6,mnode->dest_file,7);
    switch(promotion){
        case QUEEN_PROMOTION: brd->files[mnode->dest_file][7]=Queen;@+break; 
        case BISHOP_PROMOTION: brd->files[mnode->dest_file][7]=Bishop;@+break; 
        case KNIGHT_PROMOTION: brd->files[mnode->dest_file][7]=Knight;@+break; 
        case ROOK_PROMOTION: brd->files[mnode->dest_file][7]=Rook;@+break; 
    }
    ret=0;
    goto print_out_results;
}
@ @c
int do_king_move(Board*brd,struct move_node*mnode)
{
    int ii,jj;
    int sf,sr;       

    for(ii=0;ii<8;++ii)
        for(jj=0;jj<8;++jj) 
            if(lookup_on_board(brd,ii,jj)==King) {
                mnode->source_rank=jj;
                mnode->source_file=ii;
                sf=mnode->dest_file-mnode->source_file;
                sr=mnode->dest_rank-mnode->source_rank;
                if(imax(iabs(sf),iabs(sr))!=1)
                    return 1;
                else goto do_the_move;
            }
    if(ii>=8 || jj >= 8 || lookup_on_board(brd,ii,jj)!=King)
        return 1;
do_the_move:
    mnode->move=move_encode(mnode->source_file,mnode->source_rank,
            mnode->dest_file,mnode->dest_rank);
    update_board(brd,mnode->source_file,mnode->source_rank,
            mnode->dest_file, mnode->dest_rank);
    return 0;
}
@ We check that move does not result in check..
@<See if this is the correct queen@>=
    if(check_source_conditions(mnode,ii,jj) &&
        (check_bishop_conditions(mnode,ii,jj) ||
        check_rook_conditions(mnode,ii,jj)) && 
        check_queen_move(brd,mnode,ii,jj)==0)
            goto do_the_move;
@ @<Global func...@>=
int check_source_conditions(struct move_node*mnode,int ii,int jj);
@ @c
int check_source_conditions(struct move_node*mnode,int ii,int jj)
{
    return ((mnode->source_file != Unknown && mnode->source_file==ii)
    || (mnode->source_rank != Unknown && mnode->source_rank == jj)
    || (mnode->source_rank == Unknown && mnode->source_file == Unknown));
}
@ @c
int do_queen_move(Board*brd,struct move_node*mnode)
{
    int ii,jj;
    if(mnode->source_file != Unknown && mnode->source_rank != Unknown){
        ii=mnode->source_file;
        jj=mnode->source_rank;
    }@+else 
        for(ii=0;ii<8;++ii)
            for(jj=0;jj<8;++jj)
                if(lookup_on_board(brd,ii,jj)==Queen)
                    @<See if this is the correct queen@>@;
do_the_move:
    if(ii>=8 || jj>= 8 || lookup_on_board(brd,ii,jj) != Queen)
        return 1;
    mnode->move=move_encode(ii,jj,mnode->dest_file,mnode->dest_rank);
    update_board(brd,ii,jj,mnode->dest_file,mnode->dest_rank);
    return 0;
}
@ It turns out we can use the same code for these.
@d check_rook_move check_queen_move
@d check_bishop_move check_queen_move
@<Global func...@>=
int check_queen_move(Board*brd,struct move_node*mnode,int sf,int sr);
@ @c
int check_queen_move(Board*brd,struct move_node*mnode,int sf,int sr)
{
    int hm,vm;
    int hp,vp;
    hm=mnode->dest_file-sf;
    vm=mnode->dest_rank-sr;
    @<Normalize |h...@>@;
    while(hp != mnode->dest_file || vp != mnode->dest_rank)
        @<Iterate |hp| and |vp| until done@>@;
    if(check_for_exposed_king(brd,mnode,sf,sr))
        return 1;
    if(mnode->source_file == Unknown) mnode->source_file=sf;
    if(mnode->source_rank == Unknown) mnode->source_rank=sr;
    return 0;
}
@ @<Normalize |hm| and |vm|@>=
if(hm<0) hm=-1;
if(hm>0) hm=1;
if(vm<0) vm=-1;
if(vm>0) vm=1;
if(hm==0 && vm==0){
    fprintf(stdout,"I am not moving the piece???\n"); 
    myexit(0);
}
hp=sf+hm;
vp=sr+vm;
@ @<Iterate |hp| and |vp| until done@>= {
    if(hp < 0 || hp >= BOARD_WIDTH || vp < 0 || vp >= BOARD_LENGTH)
        return 1;
    if(lookup_on_board(brd,hp,vp) != Nothing)
        return 1;
    hp += hm;
    vp += vm;
    if(hp < 0 || hp >= BOARD_WIDTH || vp < 0 || vp >= BOARD_LENGTH)
        return 1;
}
@ @<Global func...@>=
int check_for_exposed_king(Board*brd,struct move_node*mnode,
        int sf,int sr);
@ We only need to check queens, bishops and rooks as they are the only
pieces that can pin others.
@c int check_for_exposed_king(Board*brd,struct move_node*mnode,
        int sf,int sr)
{
    int kf,kr,kk,ll;
    Piece piece;
    struct move_node hostile;
    @<Find the |King|@>@;
found_king:
    for(kk=0;kk<BOARD_WIDTH;++kk)
        for(ll=0;ll<BOARD_LENGTH;++ll)
            @<Find a |BlackRook|, |BlackQueen|, or |BlackBishop|@>@;
    return 0;
}
@ @<Find a |BlackRook|, |BlackQueen|, or |BlackBishop|@>={
    piece=lookup_on_board(brd,kk,ll); 
    if((piece==BlackRook || piece==BlackQueen || piece==BlackBishop) &&
            (kk != mnode->dest_file || ll != mnode->dest_rank)) {
        @<Set up |aux_board|@>@;
        @<Set up |hostile|@>@;
        switch(piece){
            @<For each piece, see if it can attack the king@>@;
            default:
                fprintf(stdout,"No way we should be here.\n");
                myexit(0);
        }
    }
}
@ @<For each piece, see if it can attack the king@>=
case BlackRook:
    if(check_rook_conditions(&hostile,kk,ll) &&
            check_queen_mve_nc(aux_board,kk,ll,kf,kr)==0)
        return 1;
    break;
@ @<For each piece, see if it can attack the king@>=
case BlackQueen:
    if((check_rook_conditions(&hostile,kk,ll) ||
                check_bishop_conditions(&hostile,kk,ll)) &&
            check_queen_mve_nc(aux_board,kk,ll,kf,kr)==0)
        return 1;
    break;
@ @<For each piece, see if it can attack the king@>=
case BlackBishop:
    if(check_bishop_conditions(&hostile,kk,ll) &&
            check_queen_mve_nc(aux_board,kk,ll,kf,kr)==0)
        return 1;
    break;
@ @<Set up |hostile|@>=
hostile.piece=piece;
hostile.source_file=Unknown;
hostile.source_rank=Unknown;
hostile.dest_file=kf;
hostile.dest_rank=kr;
@ We do all our calculations on |aux_board| so we do not mess up
our original board.
@<Set up |aux_board|@>=
copy_board(aux_board,brd);
update_board(aux_board,sf,sr,mnode->dest_file,mnode->dest_rank);
@ This finds the White king.
@<Find the |K...@>=
for(kf=0;kf<BOARD_WIDTH;++kf)
    for(kr=0;kr<BOARD_LENGTH;++kr)
        if(lookup_on_board(brd,kf,kr)==King)
            goto found_king;
@ @<Global func...@>=
int check_queen_mve_nc(Board*brd,int sf,int sr,int df,int dr);
@ @c
int check_queen_mve_nc(Board*brd,int sf,int sr,int df,int dr)
{
    int hm,vm;
    int hp,vp;

    hm=df-sf;
    vm=dr-sr;
    @<Normalize |h...@>@;
    while(hp != df || vp != dr)
        @<Iterate |hp| and |vp| until done@>@;
    return 0;
}
@ @<Global func...@>=
int iabs(int n)
{
    return (n>0)?(n):(-n);
}
@ @c
int do_bishop_move(Board*brd,struct move_node*mnode)
{
   int ii,jj; 
    if(mnode->source_file != Unknown && mnode->source_rank != Unknown){
        ii=mnode->source_file;
        jj=mnode->source_rank;
    }@+else 
        for(ii=0;ii<8;++ii)
            for(jj=0;jj<8;++jj)
                if(lookup_on_board(brd,ii,jj)==Bishop)
                    @<See if this is the correct bishop@>@;
do_the_move:
    if(ii>=8 || jj >= 8 || lookup_on_board(brd,ii,jj) != Bishop)
        return 1;
    mnode->move=move_encode(ii,jj,mnode->dest_file,mnode->dest_rank);
    update_board(brd,ii,jj,mnode->dest_file,mnode->dest_rank);
    return 0;
}
@ @<See if this is the correct bishop@>=
    if(check_source_conditions(mnode,ii,jj) &&
        check_bishop_conditions(mnode,ii,jj) &&
        check_bishop_move(brd,mnode,ii,jj)==0)
        goto do_the_move;
@ @c
int do_rook_move(Board*brd,struct move_node*mnode)
{
    int ii,jj;
    if(mnode->source_file != Unknown && mnode->source_rank != Unknown){
        ii=mnode->source_file;
        jj=mnode->source_rank;
    }@+else 
        for(ii=0;ii<BOARD_WIDTH;++ii)
            for(jj=0;jj<BOARD_LENGTH;++jj)
                if(lookup_on_board(brd,ii,jj)==Rook)
                    @<See if this is the correct rook@>@;
do_the_move:
    if(ii>=8 || jj>= 8 || lookup_on_board(brd,ii,jj) != Rook)
        return 1;
    mnode->move=move_encode(ii,jj,mnode->dest_file,mnode->dest_rank);
    update_board(brd,ii,jj,mnode->dest_file,mnode->dest_rank);
    return 0;
}
@ @<See if this is the correct rook@>=
    if(check_source_conditions(mnode,ii,jj) &&
       check_rook_conditions(mnode,ii,jj) &&
       check_rook_move(brd,mnode,ii,jj)==0)
           goto do_the_move;
@ @<Global funct...@>=
int check_rook_conditions(struct move_node*mnode,int ii,int jj);
int check_bishop_conditions(struct move_node*mnode,int ii,int jj);
@ @c
int check_rook_conditions(struct move_node*mnode,int ii,int jj)
{
   return (ii==mnode->dest_file || jj==mnode->dest_rank);
}
@ @c
int check_bishop_conditions(struct move_node*mnode,int ii,int jj)
{
    int ret;
    ii -= mnode->dest_file;
    jj -= mnode->dest_rank;
    ret=(iabs(ii)==iabs(jj));
    return ret;
}
@ @<Global func...@>=
int imax(int x,int y)
{
    return (x>y)?x:y;
}
@ @<Global func...@>=
int imin(int x,int y)
{
    return (x<y)?x:y;
}
@ @c
int do_knight_move(Board*brd,struct move_node*mnode)
{
    int ii,jj,kk,ll;
    if(mnode->source_file != Unknown && mnode->source_rank != Unknown){
        ii=mnode->source_file;
        jj=mnode->source_rank;
    }@+else 
        for(ii=0;ii<8;++ii)
            for(jj=0;jj<8;++jj)
                if(lookup_on_board(brd,ii,jj)==Knight) 
                    @<See if this is the correct knight@>@;
do_the_move:
        if(ii>=BOARD_WIDTH || jj>=BOARD_WIDTH
            || lookup_on_board(brd,ii,jj) != Knight)
        return 1;
    mnode->move=move_encode(ii,jj,mnode->dest_file,mnode->dest_rank);
    update_board(brd,ii,jj,mnode->dest_file,mnode->dest_rank);
    if(mnode->source_file==Unknown)
        mnode->source_file=ii;
    if(mnode->source_rank==Unknown)
        mnode->source_rank=jj;
    return 0;
}
@ @<See if this is the correct knight@>=
if(check_source_conditions(mnode,ii,jj)) {
    kk=iabs(ii-mnode->dest_file);
    ll=iabs(jj-mnode->dest_rank);
    if(imin(kk,ll)==1 && imax(kk,ll)==2) 
        if(check_for_exposed_king(brd,mnode,ii,jj)==0)
           goto do_the_move;
}
@ @c
int do_pawn_move(Board*brd,struct move_node*mnode)
{
    if(mnode->source_file!=mnode->dest_file){
        mnode->source_rank=mnode->dest_rank-1; 
        mnode->move=move_encode(mnode->source_file,
                mnode->source_rank,mnode->dest_file,mnode->dest_rank);
        update_board(brd,mnode->source_file,mnode->source_rank,
                mnode->dest_file,mnode->dest_rank);
        return 0;
    }
    if(mnode->dest_rank==3) {
        if(lookup_on_board(brd,mnode->source_file,2) == Nothing)
            mnode->source_rank=1; 
        else mnode->source_rank=2;
    }@+else
        mnode->source_rank=mnode->dest_rank-1;
    if(lookup_on_board(brd,mnode->source_file,mnode->source_rank) != Pawn)
        return 1;
    mnode->move=move_encode(mnode->source_file,
            mnode->source_rank,mnode->dest_file,mnode->dest_rank);
    update_board(brd,mnode->source_file,mnode->source_rank,
            mnode->dest_file,mnode->dest_rank);
    return 0;
}
@*Output. We output our results to various files.
@<Global func...@>=
void write_out_game(void);
@ @c
void write_out_game(void)
{
    unsigned char* gamename;
    unsigned char ch;
    unsigned int game_index;
    gamename=get_random_word();
    ch = CHESS_OUTPUT_GAME;
    game_index = wout.fcount;
    queue_insert(game_indices,(void*)game_index);
    wout.fcount += fwrite(&ch,1,1,wout.fp);
    write_four_bytes(wout.fp,queue_len(move_list));
    write_four_bytes(wout.fp,queue_len(current_tag_list));
    write_four_bytes(wout.fp,queue_len(move_text));
    wout.fcount +=12; /* 12 bytes for the indices we just wrote */
    queue_iterate(move_list,(queue_iterator)&write_move,&wout);
    queue_iterate(current_tag_list,(queue_iterator)&write_header,&wout);
    queue_iterate(move_text,(queue_iterator)&write_move_text,&wout);
    queue_iterate(current_tag_list,(queue_iterator)&dump_game_list,gamename);
    fprintf(game_index_db,"\"%s\",\"%s\",\"%d\"\n",gamename,outfilename,
            game_index);
    @<Reset all our information@>
}
@ @<Global vari...@>=
static struct write_out wout;
static Queue* game_indices;
static void* copy_int(unsigned int p)
{
    unsigned int* q;
    q=(unsigned int*)malloc(sizeof(unsigned int));
    if(!q)
        return q;
    *q=p;
    return q;
}
static struct queue_fcns game_index_fcns = {
    @[.copy@]=(queue_copyfn)&copy_int,
    @[.destroy@]=free
};
FILE* game_index_db;
char* outfilename;
@ @<Initialize the...@>=
game_indices=queue_allocate(&game_index_fcns);
if(!game_indices){
    fprintf(stdout,"Could not allocate game_indices.\n");
    myexit(0);
}
game_index_db=fopen("game_index.db","a");
if(!game_index_db){
    fprintf(stdout,"Could not create \"game_index.db\".\n");
    myexit(0);
}
outfilename=STRING_NULL;
@ @<Clean up...@>=
fclose(game_index_db);
wout.fcount=align_on_boundaries(wout.fp,wout.fcount);
ch=0xff;
for(ii=0;ii<4;++ii) wout.fcount += fwrite(&ch,1,1,wout.fp);
queue_iterate(game_indices,(queue_iterator)&print_int,&wout);
write_four_bytes(wout.fp,queue_len(game_indices));
queue_destroy(game_indices);
fclose(wout.fp);
@ @<Global func...@>=
static void print_int(unsigned int*p,struct write_out* wt);
@ @c
static void print_int(unsigned int*p,struct write_out* wt)
{
    write_four_bytes(wt->fp,*p);
}
@ @<Parse the command line@>=
for(ii=1;ii<argc;++ii)
    if(strcmp(argv[ii],"-o")==0){
        ++ii; 
        outfilename=argv[ii];
    }
@ @<Parse the command line@>=
if(!outfilename) {
    fprintf(stdout,"You did not specify an output file.\n");
    @<Print us...@>@;
}
if(stat(outfilename,&outstat)==0){
    fprintf(stdout,"\"%s\" already exists.  Try choosing another name.\n",
            outfilename);
    myexit(0);
}
@ @<Parse the command line@>=
wout.fp=fopen(outfilename,"w");
if(!wout.fp){
    fprintf(stdout,"Could not open \"%s\" for writing.\n",outfilename);
    myexit(0);
}
wout.fcount=0;
@ @<Global func...@>=
void dump_game_list(struct tag_list_node*p,unsigned char*gname);
@ @c
void dump_game_list(struct tag_list_node*p,unsigned char*gname)
{
    fprintf(db,"\"%s\",\"%s\",\"%s\"\n",p->tagname,p->tagvalue,gname);
}
@ @<Global vari...@>=
FILE* db;
const char* dbfilename;
@ @<Parse the...@>=
dbfilename="dbfile";
for(ii=1;ii<argc;++ii)
    if(strcmp("-db",argv[ii])==0){
        ++ii;
        dbfilename=argv[ii];
    }
@ We open a ``database'' for our PGN file.  This is used to create HTML
files that index the games.
@<Open the database file@>=
db=fopen(dbfilename,"a");
if(!db){
    fprintf(stdout,"Could not open database file.\n");
    myexit(0);
}
@ @<Clean up...@>=
fclose(db);
@ We will have occasion to get random words. We will take them in 5-bit chunks.
@<Global function...@>=
unsigned char* get_random_word(void);
@
@d RANDOM_WORD_LENGTH (10)
@d RANDOM_BIT_LENGTH (8*RANDOM_WORD_LENGTH)
@d BITS_PER_CHAR (5)
@d RANDOM_STRING_LENGTH (RANDOM_BIT_LENGTH/BITS_PER_CHAR)
@<Global vari...@>=
int randomfd;
unsigned char randbuf[RANDOM_WORD_LENGTH];
unsigned char* random_char_lookup="abcdefghijklmnop"
                        "qrstuvwxyz123456";
unsigned char rand_bit_buf[RANDOM_BIT_LENGTH];
@ @<Initialize the program@>=
randomfd=open("/dev/urandom",O_RDONLY);
if(randomfd<0){
    fprintf(stdout,"Could not open the urandom device.\n");
    myexit(0);
}
@ @<Clean up...@>=
close(randomfd);
@ @c
unsigned char* get_random_word(void)
{
    int kk,ii,jj,ll;
    unsigned char* ret;
    ret=(unsigned char*)0;
    read(randomfd,&randbuf[0],RANDOM_WORD_LENGTH); 
    ret = (unsigned char*)malloc(RANDOM_STRING_LENGTH+1);
    if(ret==((unsigned char*)0))
        return ret;
    @<Convert the bytes to bits@>@;
    @<Convert the bits to characters@>@;
    ret[RANDOM_STRING_LENGTH]='\0';
    return ret;
}
@ @<Convert the bits to characters@>=
ll=0;
for(ii=0;ii<RANDOM_STRING_LENGTH;++ii){
    kk=0;
    for(jj=0;jj<BITS_PER_CHAR;++jj){
        kk <<= 1;
        kk |= rand_bit_buf[ll] & 0x1;
        ++ll;
    } 
    ret[ii]=random_char_lookup[kk];
}
@ @<Convert the bytes to bits@>=
kk=0;
for(ii=0;ii<RANDOM_WORD_LENGTH;++ii)
    for(jj=0;jj<8;++jj){ /* Number of bits in an octet */
        if(randbuf[ii] & (1<<jj))
            rand_bit_buf[kk]=1; 
        else
            rand_bit_buf[kk]=0;
        ++kk;
    }
@ This structure is used for |queue_iterate|.
@<Global struct...@>=
struct write_out {
    FILE*fp;
    unsigned int fcount;
};
@ @<Reset all...@>=
queue_destroy_data(current_tag_list);
queue_destroy_data(move_list);
queue_destroy_data(move_text);
@ @<Global func...@>=
void write_move_text(unsigned char*s,struct write_out* wt);
@ @c
void write_move_text(unsigned char*s,struct write_out* wt)
{
    unsigned char ch;
    ch=CHESS_OUTPUT_STRING;
    wt->fcount+=fwrite(&ch,1,1,wt->fp);
    do 
        wt->fcount += fwrite(s,1,1,wt->fp);
    while(*s++);
}
@ @<Global func...@>=
void write_header(struct tag_list_node*p,struct write_out*wt);
@ @c
void write_header(struct tag_list_node*p,struct write_out*wt)
{
    unsigned char ch;
    ch=CHESS_OUTPUT_TAG;
    wt->fcount += fwrite(&ch,1,1,wt->fp); 
    write_move_text(p->tagname,wt);
    write_move_text(p->tagvalue,wt);
}
@ @<Global func...@>=
void write_move(struct move_node*mnp,struct write_out*wt);
@ @c
void write_move(struct move_node*mnp,struct write_out*wt)
{
    unsigned char ch;
    if(mnp->move2==0)
        ch=CHESS_OUTPUT_MOVE1;
    else 
        ch=CHESS_OUTPUT_MOVE2;
    wt->fcount += fwrite(&ch,1,1,wt->fp);
    ch=(mnp->move >>8) & 0xff;
    wt->fcount += fwrite(&ch,1,1,wt->fp);
    ch=mnp->move & 0xff;
    wt->fcount += fwrite(&ch,1,1,wt->fp);
    if(mnp->move2){
        ch=(mnp->move2 >>8) & 0xff;
        wt->fcount += fwrite(&ch,1,1,wt->fp);
        ch=mnp->move2 & 0xff;
        wt->fcount += fwrite(&ch,1,1,wt->fp);
    }
}
@ @<Global func...@>=
void write_four_bytes(FILE*fp,unsigned int np)
{
    unsigned char ch;
    ch=(np >> 24) & 0xff;
    fwrite(&ch,1,1,fp);
    ch=(np >> 16) & 0xff;
    fwrite(&ch,1,1,fp);
    ch=(np >> 8) & 0xff;
    fwrite(&ch,1,1,fp);
    ch=np & 0xff;
    fwrite(&ch,1,1,fp);
}
@ @<Global func...@>=
unsigned int align_on_boundaries(FILE*fp,unsigned int hp)
{
    unsigned int cp;
    unsigned char ch;
    cp = hp;
    hp += 3;
    hp &= ~0x3;
    ch =CHESS_OUTPUT_NOOP;
    while(cp<hp) cp+=fwrite(&ch,1,1,fp);
    return hp;
}
@ @<Reset all our...@>=
free(gamename);
@ @<Global func...@>=
void myexit(int c){
    fprintf(stdout,"Current line number is %d.\n",lineno);
    fflush(stdout);
    _exit(0);
}
