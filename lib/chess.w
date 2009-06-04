@ This have various routines for manipulating the board and so on.
@(chess.h@>=
#ifndef _PANIKE_CHESS_H_
#define _PANIKE_CHESS_H_
#include <stdio.h>
@h
@<Defined constants@>@;
@<Structure definitions@>@;
@<Function declarations@>@;
#endif
@ We define the pieces.
@<Defined cons...@>=
#define Nothing (0x0)
#define King (0x1)
#define Queen (0x2)
#define Bishop (0x3)
#define Knight (0x4)
#define Rook (0x5)
#define Pawn (0x6)
#define Black (0x8)
#define WhiteKing (King)
#define WhiteQueen (Queen)
#define WhiteBishop (Bishop)
#define WhiteKnight (Knight)
#define WhiteRook (Rook)
#define WhitePawn (Pawn)
#define BlackKing (Black|King)
#define BlackQueen (Black|Queen)
#define BlackBishop (Black|Bishop)
#define BlackKnight (Black|Knight)
#define BlackRook (Black|Rook)
#define BlackPawn (Black|Pawn)
#define Unknown (-1)
#define is_white_piece(p) ((p) && (((p) & Black)==0))
#define is_black_piece(p) ((p) && !is_white_piece(p))
@ We define what is a piece.
@<Struct...@>=
typedef int Piece;
@ We define what a board is.
@d BOARD_WIDTH (8)
@d BOARD_LENGTH (8)
@d BOARD_SQUARES (BOARD_WIDTH*BOARD_LENGTH)
@<Struc...@>=
typedef struct {
    unsigned char squares[BOARD_SQUARES];
    unsigned char* files[BOARD_WIDTH];
} Board;
@ @<Func...@>=
int initialize_board(Board*brd);
int reset_board(Board*brd);
Board*copy_board(Board*t,Board*s);
int update_board(Board*brd,int sf,int sr,int df,int dr);
Piece lookup_on_board(Board*brd,int file,int rank);
void output_board(Board*brd,FILE*fp);
@ @(initialize_board.c@>=
#include "chess.h"
int initialize_board(Board*brd)
{
    int ii,jj;
    if(!brd)
        return 1;
    jj=0;
    for(ii=0;ii<BOARD_WIDTH;++ii){
        brd->files[ii]=&brd->squares[jj]; 
        jj+=BOARD_LENGTH;
    }
    return reset_board(brd);
}
@ We set the board.
@(reset_board.c@>=
#include "chess.h"
int reset_board(Board*brd)
{
    int ii,jj;

    if(!brd)
        return 1;
    for(ii=0;ii<BOARD_WIDTH;++ii)
        for(jj=0;jj<BOARD_LENGTH;++jj)
           brd->files[ii][jj]=Nothing; 
    for(ii=0;ii<8;++ii){
        brd->files[ii][1]=WhitePawn;
        brd->files[ii][6]=BlackPawn;
    }
    brd->files[0][0]=brd->files[7][0]=WhiteRook;
    brd->files[1][0]=brd->files[6][0]=WhiteKnight;
    brd->files[2][0]=brd->files[5][0]=WhiteBishop;
    brd->files[3][0]=WhiteQueen;
    brd->files[4][0]=WhiteKing;
    brd->files[0][7]=brd->files[7][7]=BlackRook;
    brd->files[1][7]=brd->files[6][7]=BlackKnight;
    brd->files[2][7]=brd->files[5][7]=BlackBishop;
    brd->files[3][7]=BlackQueen;
    brd->files[4][7]=BlackKing;
    return 0;
}
@ @(copy_board.c@>=
#include "chess.h"
Board* copy_board(Board*t,Board*s)
{
    int ii;
    if(!t || !s)
        return ((Board*)0);
    for(ii=0;ii<BOARD_SQUARES;++ii)
        t->squares[ii]=s->squares[ii];         
    return t;
}
@ @(update_board.c@>=
#include "chess.h"
int update_board(Board*brd,int sf,int sr,int df,int dr)
{
    if(!brd || df < 0 || df >= BOARD_WIDTH || dr < 0 || dr >= BOARD_LENGTH
        || sf < 0 || sf >= BOARD_WIDTH || sr < 0 || sr >= BOARD_LENGTH)
        return 1; 
    brd->files[df][dr]=brd->files[sf][sr];
    brd->files[sf][sr]=Nothing;
    return 0;
}
@ @(lookup_on_board.c@>=
#include "chess.h"
Piece lookup_on_board(Board*brd,int file,int rank)
{
    if(file<0 || file >= BOARD_WIDTH || rank <0 || rank >= BOARD_WIDTH)
        return Unknown;
    return brd->files[file][rank];
}
@ @(output_board.c@>=
#include "chess.h"
void output_board(Board*brd,FILE*fp)
{
    int ii,jj;
    char p;
    p=' ';
    fprintf(fp,"\n\n");
    ii=BOARD_LENGTH;
    do{
        for(jj=0;jj<BOARD_WIDTH;++jj) fprintf(fp,"--");
        fprintf(fp,"\n");
        --ii;
        for(jj=0;jj<BOARD_WIDTH;++jj){
            fprintf(fp,"|");
            switch(brd->files[jj][ii]){
                case WhitePawn: p='P';@+break;
                case WhiteRook: p='R';@+break;
                case WhiteKnight: p='N';@+break;
                case WhiteBishop: p='B';@+break;
                case WhiteQueen: p='Q';@+break;
                case WhiteKing: p='K';@+break;
                case BlackPawn: p='p';@+break;
                case BlackRook: p='r';@+break;
                case BlackKnight: p='n';@+break;
                case BlackBishop: p='b';@+break;
                case BlackQueen: p='q';@+break;
                case BlackKing: p='k';@+break;
                case Nothing:
                default:
                    p=' ';@+break;
            } 
        }
        fprintf(fp,"%c|\n",p);
    }while(ii>0);
    for(jj=0;jj<BOARD_WIDTH;++jj) fprintf(fp,"--");
    fprintf(fp,"\n\n");
}
@ @<Struct...@>=
struct move_node {
    Piece piece;
    int source_file;
    int source_rank;
    int dest_file;
    int dest_rank;
    unsigned int move;
    unsigned int move2; /* For castling and en passant capture */
};
@ @<Struct...@>=
struct tag_list_node {
    unsigned char* tagname;
    unsigned char* tagvalue;
};
@ @<Func...@>=
struct tag_list_node* copy_tag_list_node(struct tag_list_node*p);
@ @(copy_tag_list_node.c@>=
#include "chess.h"
#include <stdlib.h>
struct tag_list_node* copy_tag_list_node(struct tag_list_node*p)
{
    struct tag_list_node*ret;
    if(!p)
        return p;
    ret=(struct tag_list_node*)malloc(sizeof(struct tag_list_node));
    if(ret==(struct tag_list_node*)0)
        return ret;
    ret->tagname=copy_string(p->tagname);
    if(!ret->tagname){
        free(ret);
        return ((struct tag_list_node*)0);
    }
    ret->tagvalue=copy_string(p->tagvalue);    
    if(!ret->tagvalue){
        free(ret->tagname);
        free(ret);
        return ((struct tag_list_node*)0);
    }
    return ret;
}
@ @<Funct...@>=
void tag_list_destroy(struct tag_list_node*p);
@ @(tag_list_destroy.c@>=
#include "chess.h"
#include <stdlib.h>
void tag_list_destroy(struct tag_list_node*p)
{
    free(p->tagname);
    free(p->tagvalue);
    free(p);
}
@ @<Func...@>=
struct move_node* move_node_copy(struct move_node*mnp);
@ @(move_node_copy.c@>=
#include "chess.h"
#include <stdlib.h>
#include <string.h>
struct move_node* move_node_copy(struct move_node*mnp)
{
    struct move_node* ret;

    ret=(struct move_node*)malloc(sizeof(struct move_node));
    if(ret)
        return memcpy(ret,mnp,sizeof(struct move_node));
    return ret;
}
@ @<Func...@>=
unsigned char* copy_string(unsigned char* s);
@ @(copy_string.c@>=
#include <string.h>
#include <stdlib.h>
unsigned char* copy_string(unsigned char* s)
{
    unsigned char* ret;
    int len;

    len=strlen(s)+1;
    ret=(unsigned char*)malloc(len*sizeof(unsigned char));
    if(ret)
        return memcpy(ret,s,len);
    return ret;
}
@ @<Func...@>=
void reset_move(struct move_node*mnode);
@ @(reset_move.c@>=
#include "chess.h"
void reset_move(struct move_node*mnode)
{
    mnode->piece=Unknown;
    mnode->source_rank=Unknown;
    mnode->source_file=Unknown;
    mnode->dest_file=Unknown;
    mnode->dest_rank=Unknown;
    mnode->move=0;
    mnode->move2=0;
}
@ We define the output codes.
@<Defined...@>=
#define CHESS_OUTPUT_NOOP (0x0)
#define CHESS_OUTPUT_MOVE1 (0x1)
#define CHESS_OUTPUT_MOVE2 (0x2)   
#define CHESS_OUTPUT_STRING (0x4)
#define CHESS_OUTPUT_TAG (0x5)
#define CHESS_OUTPUT_GAME (0x6)
@ We have to have the promotion codes.
@<Defined...@>=
#define QUEEN_PROMOTION (1<<12)
#define BISHOP_PROMOTION (2<<12)
#define KNIGHT_PROMOTION (3<<12)
#define ROOK_PROMOTION (4<<12)
#define PROMOTION_MASK (0x7<<12)
@ @<Function dec...@>=
unsigned char* read_quoted_string(unsigned char**p,unsigned char*end);
@ @(read_quoted_string.c@>=
#include "chess.h"
unsigned char* read_quoted_string(unsigned char**p,unsigned char*end)
{
    unsigned char* ret,*s;
    
    if(!p || !*p || !end || *p >= end)
        return ((unsigned char*)0);
    s=*p; 
    ret=((unsigned char*)0);
    while(s < end && *s != '"')
        ++s;
    if(s<end)
        ret = ++s;
    else {
        *p=s;
        return ret;
    }
    while(s < end && *s != '"')
        ++s;
    if(s>=end)
        s=end-1;
    *s++='\0'; 
    while(s<end && *s != '"')
        ++s;
    *p=s;
    return ret;
}
@ @<Funct...@>=
void update_board_move(Board*board,int move);
@ @(update_board_move.c@>=
#include "chess.h"
void update_board_move(Board*board,int move)
{
    int sf,sr,df,dr;
    int prom;
    @<Break up the move into its parts@>@;
    update_board(board,sf,sr,df,dr);
    prom=move&PROMOTION_MASK;
    @<Handle the case when White gets a pawn promotion@>@;
    @<Handle the case when Black gets a pawn promotion@>@;
}
@ We need the coordinates of where we are moving the piece.
@<Break up the move into its parts@>=
    sf=(move >> 9) & 0x7;
    sr=(move >> 6) & 0x7;
    df=(move >> 3) & 0x7;
    dr=move & 0x7;
@ @<Handle the case when White gets a pawn promotion@>=
if(prom != 0 && dr==7)
    switch(prom){
        case QUEEN_PROMOTION: board->files[df][dr]=WhiteQueen;@+break;
        case ROOK_PROMOTION: board->files[df][dr]=WhiteRook;@+break;
        case BISHOP_PROMOTION: board->files[df][dr]=WhiteBishop;@+break;
        case KNIGHT_PROMOTION: board->files[df][dr]=WhiteKnight;@+break;
        default:@+break;
    }
@ @<Handle the case when Black gets a pawn promotion@>=
else if(prom != 0 && dr==0)
    switch(prom){
        case QUEEN_PROMOTION: board->files[df][dr]=BlackQueen;@+break;
        case ROOK_PROMOTION: board->files[df][dr]=BlackRook;@+break;
        case BISHOP_PROMOTION: board->files[df][dr]=BlackBishop;@+break;
        case KNIGHT_PROMOTION: board->files[df][dr]=BlackKnight;@+break;
        default:@+break;
    }
@ @<Struct...@>=
struct game {
    struct move_node*cmoves;
    int nmoves;
    struct tag_list_node* tags;
    int ntags;
    unsigned char**tmoves;
    int ntmoves;
};
@ @<Func...@>=
void read_game(struct game*cgame,unsigned char*buf,FILE*fp);
@ @(read_game.c@>=
#include "chess.h"
#include <unistd.h>
#include <stdlib.h>
void read_game(struct game*cgame,unsigned char*p,FILE*fp)
{
    unsigned char* buf;
    buf=p;
    if(!buf || *buf != CHESS_OUTPUT_GAME){
        fprintf(fp,"Expected to see CHESS_OUTPUT_GAME here.\n");
    fflush(fp);
        _exit(0);
    }
    ++buf;
    cgame->nmoves=read_four_bytes(buf);
    buf+=4;
    cgame->ntags=read_four_bytes(buf);
    buf+=4;
    cgame->ntmoves=read_four_bytes(buf);
    buf+=4;
    cgame->cmoves=
        (struct move_node*)malloc(cgame->nmoves*sizeof(struct move_node));
    cgame->tags = (struct tag_list_node*)malloc(cgame->ntags *
                                      sizeof(struct tag_list_node));
    cgame->tmoves=(unsigned char**)malloc(cgame->ntmoves *
            sizeof(unsigned char*));
    if(!cgame->cmoves || !cgame->tags || ! cgame->tmoves){
        fprintf(fp,"Failed to allocate memory.\n");
    fflush(fp);
        _exit(0);
    }
    read_moves(&buf,cgame->cmoves,cgame->nmoves);
    read_tags(&buf,cgame->tags,cgame->ntags);
    read_move_text(&buf,cgame->tmoves,cgame->ntmoves); 
}
@ @<Func...@>=
void destroy_game(struct game*cgame);
@ @(destroy_game.c@>=
#include "chess.h"
#include <stdlib.h>
void destroy_game(struct game*cgame)
{
    free(cgame->cmoves);
    free(cgame->tags);
    free(cgame->tmoves);
}
@ @<Func...@>=
unsigned int read_four_bytes(unsigned char*p);
@ @(read_four_bytes.c@>=
#include "chess.h"
#include <unistd.h>
unsigned int read_four_bytes(unsigned char*p)
{
    unsigned int ret;
    int ii;
    ret=0;
    if(!p)
        _exit(0);
    for(ii=0;ii<4;++ii){
        ret <<= 8;
        ret |= *p;
        ++p; 
    }
    return ret;
}
@ Let us allocate space for the game.
@s move_node int
@s tag_list_node int
@ @<Func...@>=
void read_move_text(unsigned char**p,unsigned char**tmoves,int nmoves);
@ @(read_move_text.c@>=
#include "chess.h"
#include <stdio.h>
#include <unistd.h>
void read_move_text(unsigned char**p,unsigned char**tmoves,int nmoves)
{
    int ii;
    unsigned char*s;

    s=*p;
    for(ii=0;ii<nmoves;++ii)
        if(*s==CHESS_OUTPUT_STRING){
            ++s;
            tmoves[ii]=s; 
            while(*s)
                ++s;
            ++s;
        } else _exit(0);
    *p=s;
}
@ @<Func...@>=
void read_tags(unsigned char**p,struct tag_list_node*tln,int ntags);
@ @(read_tags.c@>=
#include "chess.h"
#include <unistd.h>
void read_tags(unsigned char**p,struct tag_list_node*tln,int ntags)
{
    int ii;
    unsigned char*buf;
    buf=*p;
    for(ii=0;ii<ntags;++ii){
        if(*buf==CHESS_OUTPUT_TAG){
            ++buf;
            if(*buf != CHESS_OUTPUT_STRING){
                _exit(0);
            } 
            ++buf;
            tln[ii].tagname=buf;
            while(*buf)
                ++buf; /* Gets to 0 byte */
            ++buf; /* |CHESS_OUTPUT_STRING| */
            ++buf;
            tln[ii].tagvalue=buf;
            while(*buf)
                ++buf;
            ++buf;
        }@+else _exit(0);
    }
    *p=buf;
}
@ @<Func...@>=
void read_moves(unsigned char**p,struct move_node*mnp,int nmoves);
@ @(read_moves.c@>=
#include "chess.h"
#include <unistd.h>
void read_moves(unsigned char**p,struct move_node*mnp,int nmoves)
{
    int ii;
    unsigned char*buf;
    buf=*p;
    for(ii=0;ii<nmoves;++ii){
        if(*buf==CHESS_OUTPUT_MOVE1){
            ++buf;
            mnp[ii].move=*buf; 
            ++buf;
            mnp[ii].move <<= 8;
            mnp[ii].move |= *buf;
            mnp[ii].move2 = 0;
            ++buf;
        }@+else if(*buf==CHESS_OUTPUT_MOVE2){
            ++buf;     
            mnp[ii].move=*buf; 
            ++buf;
            mnp[ii].move <<= 8;
            mnp[ii].move |= *buf;
            ++buf;
            mnp[ii].move2=*buf; 
            ++buf;
            mnp[ii].move2 <<= 8;
            mnp[ii].move2 |= *buf;
            ++buf;
        }@+else if(*buf==CHESS_OUTPUT_NOOP)
            ++buf;
        else _exit(0);
    }
    *p=buf;
}
@ The bottom left square is black, which corresponds to $(0,0)$ on our grid.
Thus the square is black if $\\{file}+\\{rank}$ is even.
@<Func...@>=
char color_square(int file,int rank);
@ @(color_square.c@>=
char color_square(int file,int rank)
{
    file+=rank;
    file &= 0x1;
    return (file==0)?'b':'w';
}
@ @<Func...@>=
char*piece_string(Piece p);
@ @(piece_string.c@>=
#include "chess.h"
char*piece_string(Piece p)
{
    char*s;
    switch(p) {
    case WhiteKing: s="wk";@+break;
    case WhiteQueen: s="wq";@+break;
    case WhiteBishop: s="wb";@+break;
    case WhiteKnight: s="wn";@+break;
    case WhiteRook: s="wr";@+break;
    case WhitePawn: s="wp";@+break;
    case BlackKing: s="bk";@+break;
    case BlackQueen: s="bq";@+break;
    case BlackBishop: s="bb";@+break;
    case BlackKnight: s="bn";@+break;
    case BlackRook: s="br";@+break;
    case BlackPawn: s="bp";@+break;
    case Nothing:
    default: s="s";@+break;
    }
    return s;
}
