@ This is our server.  We will try to use as the minimal HTTP we need to
talk to clients. The program will take a request and send a response.
@c
@<Header inclusions@>@;
@<Global structure definitions@>@;
@<Global variable declarations@>@;
@<Global function declarations@>@;
@
@s sockaddr_in int
@s ags int
@s sockaddr int
@s stat int
@s rot int
@c
int main(int argc, char* argv[])
{
    struct rlimit rlim;
    char*port_no,*logfilename,*game_index;
    const char*alignment_option;
    unsigned char* game_toks[3],*toks[4],*send_buf,*send_header_buf;
    unsigned char*filebuf,*fileend,*p,*q,*modifier_string,
             *aux_modifier_string,*t_modifier_string;
    int modifier_count,modifier_put_counter;
    unsigned char*modifier_toks[10],**ms,*option_toks[2];
    int ii,port,filefd,numread,numlines,acceptfd,numgames;
    unsigned int acceptlen;
    int moveno,send_counter,send_buf_len,send_header_len;
    int send_header_counter,jj,kk,ll,do_instructional_mode;
    struct stat filestat;
    struct sockaddr_in s_in,r_in;
    ags thegame;
    rot rotation;
    int do_movie,movie_rate;

    logfile=stderr; /* |logfile| will point somewhere else later */
    @<Parse the command line@>@;
    @<Initialize the program@>@;
    @<Point |logfile| somewhere else@>@;
    @<Make ourselves into a daemon@>@;
    for(;;){
start_connection:
        acceptlen=sizeof(struct sockaddr_in);
        acceptfd=accept(listenfd,(struct sockaddr*)&r_in,&acceptlen);
        if(acceptfd<0){
            fprintf(logfile,"accept returned error.\n");
            break;
        }
        fprintf(logfile,"Received request from %d.%d.%d.%d\n",
                r_in.sin_addr.s_addr & 0xff,(r_in.sin_addr.s_addr >> 8) & 0xff,
                (r_in.sin_addr.s_addr >> 16) & 0xff,
                (r_in.sin_addr.s_addr >> 24) & 0xff);
        num_recv=0;
        while(num_recv<recv_buf_len)
            @<Read the request@>@;
finished_request:
        @<Format and send the response@>@;
        @<Close the connection@>@;
    }
shutdown_program:
    @<Clean up after ourselves@>@;
    return 0;
}
@ We have temporary buffers to hold request data.
@<Initialize the ...@>=
recv_buf_len=1<<17;
recv_buf=(unsigned char*)malloc(recv_buf_len);
if(!recv_buf){
    fprintf(logfile,"Could not get a receive buffer.\n");
    _exit(0);
}
aux_recv_buf=(unsigned char*)malloc(recv_buf_len);
if(!aux_recv_buf){
    fprintf(logfile,"Could not get a receive buffer.\n");
    _exit(0);
}
@ @<Clean up...@>=
free(recv_buf);
free(aux_recv_buf);
@ @<Close the conn...@>=
shutdown(acceptfd,SHUT_RDWR);
close(acceptfd);
num_recv=0;
@ @<Read the request@>={
    @<Read from the socket@>@;
    @<Report what we received from the client@>@;
    num_recv+=numread;
    @<Break up the request into lines@>@;
#if 0
    for(ii=0;ii<=numlines;++ii)
        fprintf(logfile,"Line %d: %s\n",ii,lines[ii]);
#endif
    for(ii=0;ii<=numlines;++ii)
        if(strlen((char*)lines[ii])==0) /* A blank line indicates we are
                                           finished */
            goto finished_request;
}
@ HTTP is a line oriented protocol in its header.
@<Break up the request into lines@>=
numlines=0;
lines[0]=aux_recv_buf;
q=aux_recv_buf;
for(p=recv_buf;p<&recv_buf[num_recv];++p)
    *q++=*p; /* Copy |recv_buf| to |aux_recv_buf| */
for(p=aux_recv_buf;p<&aux_recv_buf[num_recv];++p){
    if(numlines >= (MAX_NUM_LINES-1))
        break;
    if(*p=='\n') {
        *p='\0';
        if(*(p-1)=='\r')
            *(p-1)='\0';
        ++p;
        lines[++numlines]=p;
    }
}
*p='\0';
@ @<Report what we received from the client@>=
#if 0
    fprintf(logfile,"\nReceived from client:\n\n");
    p=&recv_buf[num_recv];
    for(ii=0;ii<numread;++ii)
        fwrite(&p[ii],1,1,logfile);
    fflush(logfile);
#endif
@ @<Read from the socket@>=
numread=read(acceptfd,&recv_buf[num_recv],recv_buf_len-num_recv);
if(numread<0){
    fprintf(logfile,"read from socket returned error.\n");
    close(acceptfd);
    goto start_connection;
}
if(numread==0){
    fprintf(logfile,"Connection closed by client.\n");
    close(acceptfd);
    goto start_connection;
}
@ First we log the first line in the request.
@<Format and send the response@>=
fprintf(logfile,"Request: %s\n",lines[0]);
fflush(logfile);
@ @<Format and send the response@>=
@<Find the game@>@;
@<Format the body@>@;@;
@<Format the header@>@;
@ We could write the response to |logfile| here.
@<Format and send the response@>=
p=&send_header_buf[send_header_counter];
for(ii=0;ii<send_counter;++ii)
    p[ii]=send_buf[ii];
send_header_counter += send_counter;
write(acceptfd,send_header_buf,send_header_counter);
@ @<Initialize the prog...@>=
send_buf_len=1<<17;
send_buf=(unsigned char*)malloc(send_buf_len);
if(!send_buf){
    fprintf(logfile,"Could not get memory for send_buf\n");
    fflush(logfile);
    _exit(0);
}
@ @<Clean up...@>=
free(send_buf);
@ @<Format the body@>=
@<Create the HTML header@>@;
@<Create the table@>@;
@<Create the tags that identify the game@>@;
@<Create the move text@>@;
@<Create the ``Previous'' and ``Next'' pointers@>@;
@<Modify other server behavior@>@;
@<Create the HTML trailer@>@;
@ We want the ability to stop a movie and such.
@<Modify other server behavior@>=
send_counter+=snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"<p><center>\n");
if(modifier_string)
    t_modifier_string=copy_string(modifier_string);
else t_modifier_string=copy_string((unsigned char*)"");
if(t_modifier_string)
    get_tokens(t_modifier_string,modifier_toks,10,'&');
@<User wants to start or stop movie@>@;
@<User wants to rotate the board@>@;
if(do_movie != 0){
    @<User wants to slow down the movie@>@;
    if(movie_rate>1){
        @<User wants to speed up the movie@>@;
    }
}
@<User wants to hide or show move text@>@;
@<User wants to change board alignment@>@;
send_counter+=snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"<a href=\"/shutdown\">Shutdown</a>\n");
send_counter+=snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"</center>\n");
@ @<User wants to start or stop movie@>=
send_counter += snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"<a href=\"/%s/%d",game_toks[0],moveno);
modifier_count=0;
for(ms=modifier_toks;*ms;++ms){
    if(strncmp((char*)*ms,"movie",5)!=0)
        ++modifier_count;
}
@ @<User wants to start or stop movie@>=
modifier_put_counter=0;
if(modifier_count>0){
    send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"?");
}
for(ms=modifier_toks;*ms;++ms){
    if(strncmp((char*)*ms,"movie",5)!=0){
        if(modifier_put_counter>0)
            send_counter += snprintf((char*)&send_buf[send_counter],
                send_buf_len-send_counter,"&");
        send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"%s",*ms);
        ++modifier_put_counter;
    }
}
@ @<User wants to start or stop movie@>=
if(modifier_count==0)
    send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"?movie=yes");
else if(modifier_put_counter>0){
    send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"&movie=yes");
}
send_counter += snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"\">%s movie</a>\n",
    (do_movie==0)?"Start":"Stop");
@ @<User wants to rotate the board@>=
send_counter += snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"<a href=\"/%s/%d",game_toks[0],moveno);
modifier_count=0;
for(ms=modifier_toks;*ms;++ms){
    if(strncmp((char*)*ms,"rotate",6)!=0)
        ++modifier_count;
}
@ @<User wants to rotate the board@>=
modifier_put_counter=0;
if(modifier_count>0){
    send_counter += snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"?");
    for(ms=modifier_toks;*ms;++ms){
        if(strncmp((char*)*ms,"rotate",6)!=0){
            if(modifier_put_counter>0)
                send_counter += snprintf((char*)&send_buf[send_counter],
                   send_buf_len-send_counter,"&");
            send_counter += snprintf((char*)&send_buf[send_counter],
               send_buf_len-send_counter,"%s",*ms);
            ++modifier_put_counter;
        }
    }
}
@ @<User wants to rotate the board@>=
if(modifier_count==0 && rotation != rotate270)
    send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"?");
else if(modifier_put_counter>0 && rotation != rotate270){
    send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"&");
}
@ @<User wants to rotate the board@>=
switch(rotation){
    case rotate0:
       send_counter += snprintf((char*)&send_buf[send_counter],
               send_buf_len-send_counter,"rotate=90"); break;
    case rotate90:
       send_counter += snprintf((char*)&send_buf[send_counter],
               send_buf_len-send_counter,"rotate=180"); break;
    case rotate180:
       send_counter += snprintf((char*)&send_buf[send_counter],
               send_buf_len-send_counter,"rotate=270"); break;
    default: break;
}
send_counter += snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"\">Rotate board</a>\n");
@ @<User wants to slow down the movie@>=
send_counter += snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"<a href=\"/%s/%d",game_toks[0],moveno);
modifier_count=0;
for(ms=modifier_toks;*ms;++ms){
    if(strncmp((char*)*ms,"rate",4)!=0)
        ++modifier_count;
}
@ @<User wants to slow down the movie@>=
modifier_put_counter=0;
if(modifier_count>0){
    send_counter += snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"?");
    for(ms=modifier_toks;*ms;++ms){
        if(strncmp((char*)*ms,"rate",4)!=0){
            if(modifier_put_counter>0)
                send_counter += snprintf((char*)&send_buf[send_counter],
                   send_buf_len-send_counter,"&");
            send_counter += snprintf((char*)&send_buf[send_counter],
               send_buf_len-send_counter,"%s",*ms);
            ++modifier_put_counter;
        }
    }
}
@ @<User wants to slow down the movie@>=
if(modifier_count==0)
    send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"?");
else if(modifier_put_counter>0){
    send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"&");
}
@ @<User wants to slow down the movie@>=
send_counter += snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"rate=%d",movie_rate+1);
send_counter += snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"\">Slow movie</a>\n");
@ @<User wants to speed up the movie@>=
send_counter += snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"<a href=\"/%s/%d",game_toks[0],moveno);
modifier_count=0;
for(ms=modifier_toks;*ms;++ms){
    if(strncmp((char*)*ms,"rate",4)!=0)
        ++modifier_count;
}
@ @<User wants to speed up the movie@>=
modifier_put_counter=0;
if(modifier_count>0){
    send_counter += snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"?");
    for(ms=modifier_toks;*ms;++ms){
        if(strncmp((char*)*ms,"rate",4)!=0){
            if(modifier_put_counter>0)
                send_counter += snprintf((char*)&send_buf[send_counter],
                   send_buf_len-send_counter,"&");
            send_counter += snprintf((char*)&send_buf[send_counter],
               send_buf_len-send_counter,"%s",*ms);
            ++modifier_put_counter;
        }
    }
}
@ @<User wants to speed up the movie@>=
if(modifier_count==0)
    send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"?");
else if(modifier_put_counter>0){
    send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"&");
}
@ @<User wants to speed up the movie@>=
send_counter += snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"rate=%d",movie_rate-1);
send_counter += snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"\">Speed up movie</a>\n");
@ @<User wants to hide or show move text@>=
send_counter += snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"<a href=\"/%s/%d",game_toks[0],moveno);
modifier_count=0;
for(ms=modifier_toks;*ms;++ms){
    if(strncmp((char*)*ms,"textmode",8)!=0)
        ++modifier_count;
}
@ @<User wants to hide or show move text@>=
modifier_put_counter=0;
if(modifier_count>0){
    send_counter += snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"?");
    for(ms=modifier_toks;*ms;++ms){
        if(strncmp((char*)*ms,"textmode",8)!=0){
            if(modifier_put_counter>0)
                send_counter += snprintf((char*)&send_buf[send_counter],
                   send_buf_len-send_counter,"&");
            send_counter += snprintf((char*)&send_buf[send_counter],
               send_buf_len-send_counter,"%s",*ms);
            ++modifier_put_counter;
        }
    }
}
@ @<User wants to hide or show move text@>=
if(modifier_count==0 && !do_instructional_mode)
    send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"?");
else if(modifier_put_counter>0 && !do_instructional_mode){
    send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"&");
}
@ @<User wants to hide or show move text@>=
if(!do_instructional_mode)
    send_counter += snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"textmode=instructional");
send_counter += snprintf((char*)&send_buf[send_counter]
    ,send_buf_len-send_counter,"\">%s movetext</a>\n",
    (do_instructional_mode)?"Show":"Hide");
@ @<User wants to change board alignment@>=
send_counter += snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"<a href=\"/%s/%d",game_toks[0],moveno);
modifier_count=0;
for(ms=modifier_toks;*ms;++ms){
    if(strncmp((char*)*ms,"align",5)!=0)
        ++modifier_count;
}
@ @<User wants to change board alignment@>=
modifier_put_counter=0;
if(modifier_count>0){
    send_counter += snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"?");
    for(ms=modifier_toks;*ms;++ms){
        if(strncmp((char*)*ms,"align",5)!=0){
            if(modifier_put_counter>0)
                send_counter += snprintf((char*)&send_buf[send_counter],
                   send_buf_len-send_counter,"&");
            send_counter += snprintf((char*)&send_buf[send_counter],
               send_buf_len-send_counter,"%s",*ms);
            ++modifier_put_counter;
        }
    }
}
@ @<User wants to change board alignment@>=
if(modifier_count==0 && strcmp(alignment_option,"left")==0)
    send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"?");
else if(modifier_put_counter>0 && strcmp(alignment_option,"left")==0){
    send_counter += snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"&");
}
@ @<User wants to change board alignment@>=
if(strcmp(alignment_option,"left") == 0)
    send_counter += snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"align=right");
send_counter += snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"\">Align board %s</a>\n",
        (strcmp(alignment_option,"left")==0)?"right":"left");
@ @<Create the ``Previous'' and ``Next'' pointers@>=
send_counter+=snprintf((char*)&send_buf[send_counter]
    ,send_buf_len-send_counter,"<p><center>\n");
if(moveno>0){
    send_counter+=snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter, "<a href=\"/%s/%d",game_toks[0],
        moveno-1);
    if(modifier_string)
        send_counter+=snprintf((char*)&send_buf[send_counter],
                send_buf_len-send_counter, "?%s",modifier_string);
    send_counter+=snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"\">&lt;&lt; Previous</a>");
}
@ @<Create the ``Previous'' and ``Next'' pointers@>=
if(moveno>0 && moveno<thegame.gme.nmoves-1)
    send_counter+=snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"&nbsp;&nbsp;");
if(moveno<thegame.gme.nmoves-1) {
    send_counter+=snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"<a href=\"/%s/%d",game_toks[0],
        moveno+1);
    if(modifier_string)
        send_counter+=snprintf((char*)&send_buf[send_counter],
                send_buf_len-send_counter, "?%s",modifier_string);
    send_counter+=snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"\">Next &gt;&gt;\n");
}
send_counter+=snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"</center>\n");
@ An option here is to write only the current move.
@^Formatting option@>
@<Create the move text@>=
if(!do_instructional_mode) {
    for(ii=0;ii<thegame.gme.ntmoves;++ii){
        if(ii<thegame.gme.nmoves && (ii & 0x1)==0)
            send_counter+=snprintf((char*)&send_buf[send_counter],
                    send_buf_len-send_counter,"%d. ",ii/2+1);
        if(ii<thegame.gme.nmoves && ii != moveno) {
            send_counter+=snprintf((char*)&send_buf[send_counter],
                    send_buf_len-send_counter,"<a href=\"/%s/%d",
                    game_toks[0],ii);
            if(modifier_string)
                send_counter+=snprintf((char*)&send_buf[send_counter],
                    send_buf_len-send_counter,"?%s",modifier_string);
            send_counter+=snprintf((char*)&send_buf[send_counter],
                    send_buf_len-send_counter,"\">");
        }
        send_counter+=snprintf((char*)&send_buf[send_counter],
                send_buf_len-send_counter,"%s",thegame.gme.tmoves[ii]);
        if(ii<thegame.gme.nmoves && ii != moveno)
            send_counter+=snprintf((char*)&send_buf[send_counter],
                    send_buf_len-send_counter,"</a>");
        send_counter+=snprintf((char*)&send_buf[send_counter],
                send_buf_len-send_counter,"\n");
    }
}@+else{
    send_counter+=snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"%d. ",moveno/2+1);
    if(moveno & 0x1)
        send_counter+=snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"... ");
    if(moveno >= thegame.gme.nmoves)
        moveno = thegame.gme.nmoves-1;
    send_counter+=snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"%s\n",thegame.gme.tmoves[moveno]);
}
@ @<Initialize the prog...@>=
do_instructional_mode=0;
@ @<Close the conn...@>=
do_instructional_mode=0;
@ The |option_toks| variable contains options that modify the
behavior of the server. The possible values of the options are
contained in the following table.
\smallskip
\halign{&\tt#\ \hfil\cr
textmode&instructional\cr
movie&yes\cr
rate&\rm$\langle\hbox{number}\rangle$\cr
align&right\cr
rotate&90,180,270\cr}

These option are independent, so a URL can look like
\smallskip\centerline{\tt http://server/game/23?textmode=instructional\char`\&%
align=right\char`\&rotate=90\rm.}\smallskip
@^Document options for URLs@>
@<We scan...@>=
if(option_toks[0] && strcmp((char*)option_toks[0],"textmode")==0
    && option_toks[1] && strcmp((char*)option_toks[1],"instructional")==0)
    do_instructional_mode=1;
@ @<Create the tags that identify the game@>=
for(ii=0;ii<thegame.gme.ntags;++ii) {
    if(ii != 0)
        send_counter+=snprintf((char*)&send_buf[send_counter],
                send_buf_len-send_counter,"<br>");
    send_counter+=snprintf((char*)&send_buf[send_counter],
            send_buf_len-send_counter,"<b>%s</b>: %s\n",
            thegame.gme.tags[ii].tagname,thegame.gme.tags[ii].tagvalue);
}
send_counter+=snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"<br>\n");
@ We do not do anything very sophisticated here.
@<Create the HTML header@>=
send_counter=0;
if(moveno < thegame.gme.nmoves-1 && do_movie){
    send_counter+=snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,
        "<meta http-equiv=\"refresh\" content=\"%d; "
        "url=/%s/%d",movie_rate,game_toks[0],moveno+1);
    if(modifier_string)
        send_counter+=snprintf((char*)&send_buf[send_counter],
                send_buf_len-send_counter,"?%s",(char*)modifier_string);
    send_counter+=snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"\">\n");
}
send_counter+=snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"<html>\n<head>\n<title>The game</title>\n"
        "</head>\n<body>\n");
@ @<We scan each option for relevant data@>=
if(option_toks[0] && strcmp((char*)option_toks[0],"movie")==0 &&
        option_toks[1] && strcmp((char*)option_toks[1],"yes")==0)
    do_movie=1;
@ @<Close the conn...@>=
do_movie=0;
@ @<Initialize the pr...@>=
do_movie=0;
@ @<We scan each...@>=
if(option_toks[0] && strcmp((char*)option_toks[0],"rate")==0 && option_toks[1])
    movie_rate=get_int(option_toks[1]);
if(movie_rate==0)
    movie_rate=1;
@ @<Close the conn...@>=
movie_rate=5;
@ @<Initialize the pr...@>=
movie_rate=5;
@ @<Parse m...@>=
if(aux_modifier_string) {
    get_tokens(aux_modifier_string,modifier_toks,10,'&');
#if 0
    for(ii=0;ii<10;++ii)
        if(modifier_toks[ii])
            fprintf(logfile,"Modifier token %d: %s\n",ii,modifier_toks[ii]);
#endif
    for(ms=modifier_toks;*ms;++ms){
        get_tokens(*ms,option_toks,2,'=');
        @<We scan each option for relevant data@>@;
    }
}
@ @<Create the HTML trailer@>=
send_counter+=snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"</body>\n</html>\n");
@ We write the board. First we move the pieces around on the board.
@<Create the table@>=
reset_board(theboard); /* Sets up the board in initial position */
for(ii=0;ii<=moveno && ii<thegame.gme.nmoves;++ii) {
    update_board_move(theboard,thegame.gme.cmoves[ii].move);
    if(thegame.gme.cmoves[ii].move2)
        update_board_move(theboard,thegame.gme.cmoves[ii].move2);
}
@ An option here is to move the table to the right.
@<Create the table@>=
@^Formatting option@>
send_counter+=snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,
    "<table align=\"%s\" cellspacing=\"0\" cellpadding=\"0\">\n",
    alignment_option);
@<Do each row of the table@>@;
send_counter+=snprintf((char*)&send_buf[send_counter],
    send_buf_len-send_counter,"</table>\n");
@ @<Initialize the pro...@>=
alignment_option="left";
@ @<Close the conn...@>=
alignment_option="left";
@ @<We scan each...@>=
if(option_toks[0] && strcmp((char*)option_toks[0],"align")==0 &&
        option_toks[1] && strcmp((char*)option_toks[1],"right")==0)
    alignment_option="right";
@ We use the default view of White on bottom. An option here is to rotate the
board.
@<Do each row of the table@>=
@^Formatting option@>
jj=BOARD_LENGTH;
while(jj>0){
    --jj;
    send_counter+=snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"<tr>\n");
    for(ii=0;ii<BOARD_WIDTH;++ii){
        switch(rotation){
            case rotate90: kk=7-jj;@+ll=ii;@+break;
            case rotate180: kk=7-ii;@+ll=7-jj;@+break;
            case rotate270: kk=jj;@+ll=7-ii;@+break;
            case rotate0: default: kk=ii;@+ll=jj;@+break;
        }
        send_counter+=snprintf((char*)&send_buf[send_counter],
                send_buf_len-send_counter,"<td><img src=\"%s/%c%s.png\">"
                "</td>\n",http_image_sources,color_square(kk,ll),
                piece_string(lookup_on_board(theboard,kk,ll)));
    }
    send_counter+=snprintf((char*)&send_buf[send_counter],
        send_buf_len-send_counter,"</tr>\n");
}
@ @<Initialize the ...@>=
rotation=rotate0;
@ @<Close the conn...@>=
rotation=rotate0;
@ @<We scan each...@>=
if(option_toks[0] && strcmp((char*)option_toks[0],"rotate")==0){
    if(option_toks[1] && strcmp((char*)option_toks[1],"90")==0)
        rotation=rotate90;
    if(option_toks[1] && strcmp((char*)option_toks[1],"180")==0)
        rotation=rotate180;
    if(option_toks[1] && strcmp((char*)option_toks[1],"270")==0)
        rotation=rotate270;
}
@ @<Global struct...@>=
typedef enum { rotate0,rotate90,rotate180,rotate270 } rot;
@
@s Board int
@<Initialize the program@>=
theboard=(Board*)malloc(sizeof(Board));
if(!theboard){
    fprintf(logfile,"Could not allocate a board.\n");
    fflush(logfile);
    _exit(0);
}
initialize_board(theboard);
@ @<Global vari...@>=
Board* theboard;
@ @<Clean up...@>=
free(theboard);
@ @<Initialize the program@>=
send_header_len=1<<16;
send_header_buf=(unsigned char*)malloc(send_header_len);
if(!send_header_buf){
    fprintf(logfile,"Could not allocate memory for send_header_buf.\n");
    fflush(logfile);
    _exit(0);
}
@ @<Clean up...@>=
free(send_header_buf);
@ The only thing that varies here is the content length field.
We should make this more robust and return better error messages to the
client.
@<Format the header@>=
send_header_counter=0;
send_header_counter+=snprintf((char*)&send_header_buf[send_header_counter],
        send_header_len-send_header_counter,
        "HTTP/1.1 200 OK\r\n");
send_header_counter+=snprintf((char*)&send_header_buf[send_header_counter],
        send_header_len-send_header_counter,
        "Content-Length: %d\r\n",send_counter);
send_header_counter+=snprintf((char*)&send_header_buf[send_header_counter],
        send_header_len-send_header_counter,
        "Content-Type: text/html; charset=ISO-8859-1\r\n");
send_header_counter+=snprintf((char*)&send_header_buf[send_header_counter],
        send_header_len-send_header_counter,
        "Connection: close\r\n");
send_header_counter+=snprintf((char*)&send_header_buf[send_header_counter],
        send_header_len-send_header_counter,
        "Cache-Control: no-cache\r\n\r\n");
@ @<Find the game@>=
if(get_tokens(lines[0],toks,4,' ')) {/* Split |lines[0]| into tokens */
    shutdown(acceptfd,SHUT_RDWR);
    close(acceptfd);
    fflush(logfile);
    goto start_connection;
}
#if 0
for(ii=0;ii<3;++ii)
    if(toks[ii])
        fprintf(logfile,"Token %d: \"%s\".\n",ii,toks[ii]);
fflush(logfile);
#endif
@ @<Find the game@>=
if(!toks[0] || (toks[0] && strcmp((char*)toks[0],"GET") != 0)){
    fprintf(logfile,"Bad request from client.\n");
    shutdown(acceptfd,SHUT_RDWR);
    close(acceptfd);
    fflush(logfile);
    goto start_connection;
}
@ We remove the `\.{/}' characters from the URL. Note the \.{shutdown} command
here. This command is alright because a game name will be 16 characters, and
this is only 8.  If we go to 8-character-long names, we will change this to
\.{shutdownnow} or something.
@<Find the game@>=
if(get_tokens(toks[1],game_toks,3,'/')) { /* Find the game name and options */
    shutdown(acceptfd,SHUT_RDWR);
    close(acceptfd);
    fflush(logfile);
    goto start_connection;
}
@ @<Find the game@>=
if(!game_toks[0]){
    fprintf(logfile,"Received null command from client.\n");
    shutdown(acceptfd,SHUT_RDWR);
    close(acceptfd);
    fflush(logfile);
    goto start_connection;
}
#if 0
for(ii=0;ii<3;++ii)
    if(game_toks[ii])
        fprintf(logfile,"Game Token %d: \"%s\".\n",ii,game_toks[ii]);
fflush(logfile);
#endif
@ @<Find the game@>=
@^Shutdown command@>
if(game_toks[0] && strcmp((char*)game_toks[0],"shutdown")==0){
    fprintf(logfile,"OK, leaving since we received a shutdown command.\n");
    fflush(logfile);
    shutdown(acceptfd,SHUT_RDWR);
    close(acceptfd);
    goto shutdown_program;
}
@ @<Find the game@>=
if(!search_for_game(game_toks[0],indices,numgames,&thegame)){
    fprintf(logfile,"Game \"%s\" not found.\n",game_toks[0]);
    fflush(logfile);
    shutdown(acceptfd,SHUT_RDWR);
    close(acceptfd);
    goto start_connection;
}
@ This will have options encoded in it eventually.
@<Find the game@>=
@^Formatting option@>
moveno=get_int(game_toks[1]);
if(game_toks[1])
    for(p=game_toks[1];*p;++p)
        if(*p=='?') {
            ++p;
            if(*p)
                modifier_string=copy_string(p);
            break;
        }
if(modifier_string)
    aux_modifier_string=copy_string(modifier_string);
@<Parse modifier string@>@;
@ @<Close the conn...@>=
if(modifier_string){
    free(modifier_string);
    modifier_string=((unsigned char*)0);
}
if(aux_modifier_string){
    free(aux_modifier_string);
    aux_modifier_string=((unsigned char*)0);
}
@ @<Initialize the pr...@>=
modifier_string=((unsigned char*)0);
aux_modifier_string=((unsigned char*)0);
@ @<Global func...@>=
int get_int(unsigned char*p)
{
    int ret;
    ret=0;
    while(p && *p>='0' && *p <= '9'){
        ret *= 10;
        ret += *p - '0';
        ++p;
    }
    if(ret<0)
        ret=0;
    return ret;
}
@ Now we do a binary search in |indices| to find the game.
@s game int
@s index_struct int
@<Global func...@>=
struct game* search_for_game(unsigned char*,struct index_struct*,int,ags*);
@ @<Global struc...@>=
typedef struct {
    unsigned char*fbuf;
    struct game gme;
} ags;
@ @c
struct game* search_for_game(unsigned char*name,struct index_struct*isp,
        int num, ags*gp)
{
    int lft,rgt,mid,filefd;
    struct stat filestat;
    int result,ii,numread;

    if(!name || !isp || !gp)
        return ((struct game*)0);
    @<Use the binary search algorithm to find the game named |name|@>@;
    if(strcmp((char*)name,(char*)isp[mid].gamename)!=0)
        return ((struct game*)0);
    @<Open and read the game library@>@;
    read_game(&gp->gme,&gp->fbuf[isp[mid].index],logfile);
    return &gp->gme;
}
@ @<Open and read the game library@>=
filefd=open((char*)isp[mid].filename,O_RDONLY);
if(filefd<0){
    fprintf(logfile,"Could not open file \"%s\".\n",isp[mid].filename);
    fflush(logfile);
    return ((struct game*)0);
}
@ @<Open and read the game library@>=
fstat(filefd,&filestat);
gp->fbuf=(unsigned char*)malloc(filestat.st_size);
if(!gp->fbuf){
    fprintf(logfile,"Could not get a buffer for"
            "\"%s\".\n",isp[mid].filename);
    fflush(logfile);
    return ((struct game*)0);
}
@ @<Open and read the game library@>=
for(ii=0;ii<filestat.st_size;ii+=numread){
    numread=read(filefd,&gp->fbuf[ii],filestat.st_size-ii);
    if(numread<0){
        fprintf(logfile,"Error reading from \"%s\".\n",isp[mid].filename);
        fflush(logfile);
        close(filefd);
        free(gp->fbuf);
        return ((struct game*)0);
    }
}
close(filefd);
@ @<Use the binary search algorithm to find the game named |name|@>=
    lft=0;
    rgt=num-1;
    mid=(lft+rgt)/2;
    while(rgt>=lft &&
            (result=strcmp((char*)name,(char*)isp[mid].gamename))!=0){
        if(result<0){
            rgt=mid-1;
            mid=(lft+rgt)/2;
        }@+else if(result>0) {
            lft=mid+1;
            mid=(lft+rgt)/2;
        }
    }
@ @<Close the connection@>=
destroy_game(&thegame.gme);
free(thegame.fbuf);
@ @<Global func...@>=
int get_tokens(unsigned char*s,unsigned char**tokens,int num_tokens,
        unsigned char sep);
@ @c
int get_tokens(unsigned char*s,unsigned char**tokens,int num_tokens,
        unsigned char sep)
{
    int ii;
    if(!tokens)
        return 1;
    for(ii=0;ii<num_tokens;++ii)
        tokens[ii]=(unsigned char*)0;
    if(!s)
        return 1;
    for(ii=0;ii<num_tokens;++ii){
        while(*s && *s==sep) ++s;
        if(*s)
            tokens[ii]=s;
        else break;
        while(*s && *s !=sep)
            ++s;
        if(ii<num_tokens-1 && *s) /* Do not break up the rest of the string */
            *s++='\0';
        else break;
    }
    return 0;
}
@ @<Parse the command line@>=
http_image_sources=port_no=logfilename=game_index=(char*)0;
daemonize=0;
for(ii=1;ii<argc;++ii){
    @<Scan through the command line options@>@;
}
if(!http_image_sources || !port_no || !logfilename || !game_index){
        @<Print a usage statement@>@;
}
@ @<Scan through the command line options@>=
    if(strcmp(argv[ii],"-images")==0){
        ++ii;
        http_image_sources=argv[ii];
    }
    if(strcmp(argv[ii],"-p")==0){
        ++ii;
        port_no=argv[ii];
    }
    if(strcmp(argv[ii],"-log")==0){
        ++ii;
        logfilename=argv[ii];
    }
    if(strcmp(argv[ii],"-idx")==0){
        ++ii;
        game_index=argv[ii];
    }
    if(strcmp(argv[ii],"-h")==0){
        @<Print a usage statement@>@;
    }
@ @<Print a usage statement@>=
fprintf(logfile,"Usage: %s <-images http_source>"
        " <-p port>"" <-log logfile> <-idx index> "" [-h] [-d]\n",argv[0]);
fprintf(logfile,"\n-d for a daemon.\n\n");
_exit(0);
@ @<Initialize the program@>=
port=atoi(port_no);
listenfd=socket(PF_INET,SOCK_STREAM,0);
if(listenfd<0){
    fprintf(logfile,"Could not open the socket.\n");
    _exit(0);
}
@
@s rlimit int
@<Make ourselves into a daemon@>=
if(daemonize)
{
    getrlimit(RLIMIT_NOFILE,&rlim);
    ioctl(fileno(stdin),TIOCNOTTY); /* Turn off the terminal */
    for(ii=0;ii<rlim.rlim_cur;++ii)
        if(ii != listenfd && ii != fileno(logfile))
            close(ii);
    if(fork())
        _exit(0);
}
@ @<Global vari...@>=
int daemonize;
@ @<Scan...@>=
if(strcmp(argv[ii],"-d")==0)
    daemonize=1;
@ @<Header incl...@>=
#include <sys/ioctl.h>
#include <termios.h>
#include <sys/time.h>
#include <sys/resource.h>
@ We want to not have a terminal.  Therefore we never write explicitly to
|stderr|.  Instead we write to |logfile|.  When we start, this is pointing to
|logfile|, but now we write to a file in the filesystem.
@<Point |log...@>=
logfile=fopen(logfilename,"a");
if(!logfile){
    logfile=stderr;
    fprintf(logfile,"Could not open \"%s\".\n",logfilename);
    _exit(0);
}
@ @<Initialize the program@>=
filefd=open(game_index,O_RDONLY);
if(filefd<0){
    fprintf(logfile,"Could not open file \"%s\".\n",game_index);
    _exit(0);
}
@ @<Initialize the program@>=
if(fstat(filefd,&filestat)){
    fprintf(logfile,"Error stating the file.\n");
    _exit(0);
}
@ @<Initialize the program@>=
filebuf=(unsigned char*)malloc(filestat.st_size);
if(!filebuf){
    fprintf(logfile,"Could not allocate space for the file.\n");
    _exit(0);
}
@ @<Clean up...@>=
free(filebuf);
@ @<Initialize the program@>=
for(ii=0;ii<filestat.st_size;ii+=numread){
    numread=read(filefd,&filebuf[ii],filestat.st_size-ii);
    if(numread < 0){
        fprintf(logfile,"Error reading the file.\n");
        _exit(0);
    }
    if(numread==0)
        break;
}
fileend=&filebuf[ii];
close(filefd);
@ @<Initialize the program@>=
numgames=0;
for(p=filebuf;p<fileend;++p)
    if(*p=='\n')
       ++numgames;
@ @<Global struct...@>=
struct index_struct {
    unsigned char*gamename;
    unsigned char*filename;
    int index;
};
@ @<Initialize the prog...@>=
indices=(struct index_struct*)malloc(numgames*sizeof(struct index_struct));
if(!indices){
    fprintf(logfile,"Could not get memory for the indices.\n");
    _exit(0);
}
p=filebuf;
for(ii=0;ii<numgames;++ii){
    indices[ii].gamename=read_quoted_string(&p,fileend);
    indices[ii].filename=read_quoted_string(&p,fileend);
    indices[ii].index=atoi((char*)read_quoted_string(&p,fileend));
}
@ @<Initialize the pro...@>=
s_in.sin_family=AF_INET;
s_in.sin_port=htons(port);
s_in.sin_addr.s_addr=INADDR_ANY;
if(bind(listenfd,(struct sockaddr*)&s_in,sizeof(struct sockaddr_in))){
    fprintf(logfile,"Could not bind the socket.\n");
    fflush(logfile);
    _exit(0);
}
if(listen(listenfd,10)){
    fprintf(logfile,"Listen failed.\n");
    fflush(logfile);
    _exit(0);
}
@ @<Clean up after ourselves@>=
free(indices);
fclose(logfile);
shutdown(listenfd,SHUT_RDWR);
close(listenfd);
@ @<Header inclusions@>=
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <chess.h>
@
@d MAX_NUM_LINES 64
@<Global variable declarations@>=
int listenfd;
char* http_image_sources;
FILE*logfile;
struct index_struct*indices;
int num_recv,recv_buf_len;
unsigned char*recv_buf,*aux_recv_buf;
unsigned char*lines[MAX_NUM_LINES];
