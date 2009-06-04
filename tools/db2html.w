@ We read a file that we created with \.{compiler} and we write out a 
bunch of HTML files. This is a dry run for the server, so we can understand 
the issues in creating HTML in a static situation, which will give us insight
into the dynamic situation.
@c
@<Header inclusions@>@;
@h
@
@s Board int
@s game int
@s stat int
@s Piece int
@c
int main(int argc,char* argv[])
{
    char*filename,*http_sources,*game_index;
    char outfilename[256];
    int ii,filefd,numread,jj,chess_rank,chess_file;
    Board*board;
    struct stat filestat;
    unsigned char*filebuf,*fileend;
    unsigned int filelen,ngames,gindex;
    unsigned char*game_index_char_buf,*thegame;
    unsigned int*game_index_buf;
    struct game cgame;
    FILE*outfile;
    Piece piece;

@<Parse the command line@>@;
@<Initialize the program@>@;
@<Read the file@>@;
@<Create the html@>@;
@<Clean up after ourselves@>@;
        return 0;
}
@ We write out the header.
@<Write out the html@>=
fprintf(outfile,"<html>\n");
fprintf(outfile,"<head>\n<title>The game</title>\n</head>\n");
@ Now we start the body.
@<Write out the html@>=
fprintf(outfile,"<body>\n<table align=\"left\" cellspacing=\"0\""
" cellpadding=\"0\">\n");
@<Write the table, which is the board@>@;
fprintf(outfile,"</table>\n");
@ Now we write out the tags, or the meta information about the game.
@<Write out the html@>=
for(jj=0;jj<cgame.ntags;++jj){
    if(jj !=0)
        fprintf(outfile,"<br>");
    fprintf(outfile,"<b>%s</b>: %s\n",cgame.tags[jj].tagname,
            cgame.tags[jj].tagvalue);
}
fprintf(outfile,"<br><br>\n");
@ Now we write out the movetext.  The move where we are at now does not have a
link associated to it, but the rest of the moves do.  This is so a user can
click on a move and go directly to an interesting part if he so desires.
@<Write out the html@>=
for(jj=0;jj<cgame.ntmoves;++jj) {
    if(jj < cgame.nmoves && (jj & 0x1)==0)
        fprintf(outfile,"%d. ",jj/2+1);
    if(jj < cgame.nmoves && jj != ii)    
        fprintf(outfile,"<a href=\"%d.html\">",jj);
    fprintf(outfile,"%s",cgame.tmoves[jj]);
    if(jj < cgame.nmoves && jj != ii)    
        fprintf(outfile,"</a>");
    fprintf(outfile,"\n");
}
@ The last thing we write is the previous and next links so that the user can
click through move-by-move. Finally, we close the file with a proper html
postamble.
@<Write out the html@>=
fprintf(outfile,"<p><center>\n");
if(ii>0)
    fprintf(outfile,"<a href=\"%d.html\">&lt;&lt; Previous</a>\n",ii-1);
if(ii<cgame.nmoves-1)
    fprintf(outfile,"&nbsp;&nbsp;<a href=\"%d.html\">Next &gt;&gt;</a>",ii+1);
fprintf(outfile,"</body></html>\n");
/* Write a proper closing for the html file */
@ Each square as an associated image. We have to decide which piece 
is occupying the square and what color the square is.
@<Write the table, which is the board@>=
for(chess_rank=BOARD_LENGTH-1;chess_rank>=0;--chess_rank) {
    fprintf(outfile,"<tr>\n");
    for(chess_file=0;chess_file<BOARD_WIDTH;++chess_file) {
        piece=lookup_on_board(board,chess_file,chess_rank);
        fprintf(outfile,"<td><img src=\"%s/%c%s.gif\"></td>\n",
           http_sources,color_square(chess_file,chess_rank),
            piece_string(piece)); 
    }
    fprintf(outfile,"</tr>\n");
}
@ @<Create the html@>=
for(ii=0;ii<cgame.nmoves;++ii){
    sprintf(outfilename,"%d.html",ii);
    outfile=fopen(outfilename,"w");
    if(!outfile){
        fprintf(stderr,"Could not open \"%s\".\n",outfilename); 
        _exit(0);
    }
    update_board_move(board,cgame.cmoves[ii].move);
    if(cgame.cmoves[ii].move2)
        update_board_move(board,cgame.cmoves[ii].move2);
    @<Write out the html@>@;
    fclose(outfile);
}
@ @<Read the file@>=
if(fstat(filefd,&filestat)){
    fprintf(stderr,"Could not stat the file.n");
    _exit(0);
}
filebuf=(unsigned char*)malloc(filestat.st_size);
if(!filebuf){
    fprintf(stderr,"Could not allocate space for the file.\n");
    _exit(0);
}
@ @<Read the file@>=
for(ii=0;ii<filestat.st_size;ii+=numread){
    numread=read(filefd,&filebuf[ii],filestat.st_size-ii);
    if(numread < 0) {
        fprintf(stderr,"Error reading from the file.\n"); 
        _exit(0);
    }
    if(numread==0)
        break;
}
fileend=filebuf+ii;
filelen=ii;
@ @<Read the file@>=
ngames=read_four_bytes(&filebuf[filelen-4]);
gindex=atoi(game_index);
if(gindex<0 || gindex>ngames){
    fprintf(stderr,"game_index out of bounds.\n");
    _exit(0);
}
@ @<Read the file@>=
game_index_char_buf=&filebuf[filelen-8-ngames*4];
for(ii=0;ii<4;++ii)
    if(game_index_char_buf[ii] != 0xff){
        fprintf(stderr,"File format is messed up. Not enough 0xff's.\n"); 
        _exit(0);
    }
@ @<Read the file@>=
game_index_buf=(unsigned int*)&game_index_char_buf[4];
game_index_char_buf +=4;
for(ii=0;ii<4;++ii)
    fprintf(stderr,"%02x ", game_index_char_buf[ii]);
fprintf(stderr,"\n");
fprintf(stderr,"gindex=%d.\n",gindex);
game_index_char_buf += 4*gindex;
gindex=read_four_bytes(game_index_char_buf);
fprintf(stderr,"Starting at %d.\n",gindex);
thegame=&filebuf[gindex];
for(ii=0;ii<4;++ii)
    fprintf(stderr,"%02x ",thegame[ii]);
fprintf(stderr,"\n");
read_game(&cgame,thegame,stderr);
@ Let us allocate space for the game.
@s move_node int
@s tag_list_node int
@ @<Clean up...@>=
free(filebuf);
@ @<Initialize the program@>=
board=(Board*)malloc(sizeof(Board));
initialize_board(board);
filefd=open(filename,O_RDONLY);
if(filefd<0){
    fprintf(stderr,"Could not open \"%s\".\n",filename);
    _exit(0);
}
@ @<Clean up...@>=
free(board);
close(filefd);
@ @<Parse the command line@>=
game_index=filename=http_sources=((char*)0);
for(ii=1;ii<argc;++ii){
    if(strcmp(argv[ii],"-f")==0){
        ++ii;
        filename=argv[ii]; 
    }
    if(strcmp(argv[ii],"-http")==0){
        ++ii;
        http_sources=argv[ii];
    }
    if(strcmp(argv[ii],"-idx")==0){
   	++ii;
	game_index=argv[ii];
    }
    if(strcmp(argv[ii],"-h")==0)
        @<Print usage message@>@;
}
if(!filename || !http_sources || !game_index)
    @<Print usage message@>@;
@ @<Print usage...@>={
    fprintf(stderr,"Usage: %s <-f file> <-http http-prefix> "
	    "<-idx game_index> [-h].\n",argv[0]);
    _exit(0);
}
@ @<Header inclusions@>=
#include <chess.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
