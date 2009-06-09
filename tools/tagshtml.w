@ @c
@<Header inclusions@>@;
@h
char outfilename[256];
@ @c
int main(int argc,char*argv[])
{
    char*filename,*http_server_name;
    int ii,filefd,numread;
    struct stat filestat;
    unsigned char* filebuf,*fileend;
    unsigned char*old_tagname,*old_tagvalue;
    unsigned char*p; 
    unsigned char*new_tagname,*new_tagvalue,*key;
    FILE*outfile;
        
    @<Parse the command line@>@;
    @<Initialize the program@>@;
    @<Read the file@>@;
    @<Write out the files@>@;
    @<Clean up after ourselves@>@;
    return 0;
}
@ @<Write out the files@>=
old_tagname=old_tagvalue=(unsigned char*)0;
p=filebuf;
while(p<fileend) {
    new_tagname=read_quoted_string(&p,fileend);
    new_tagvalue=read_quoted_string(&p,fileend);
    key=read_quoted_string(&p,fileend);
    @<Check |new_tagname| against |old_tagname|@>@; 
    @<Check |new_tagvalue| against |old_tagvalue|@>@;
    @<Write the information@>@;
    old_tagname=new_tagname;
    old_tagvalue=new_tagvalue;
}
@ @<Find the tags and game@>=
@ @<Check |new_tagv...@>=
if(!old_tagvalue || strcmp((char*)old_tagvalue,(char*)new_tagvalue) != 0) {
    fprintf(outfile,"\n<br>%s: ",new_tagvalue);
}
@ @<Write the info...@>=
fprintf(outfile,"<a href=\"%s/%s/\">%s</a> ",http_server_name,key,key);
@ @<Check |new_tagname| against |old_tagname|@>=
if(!old_tagname || strcmp((char*)new_tagname,(char*)old_tagname) != 0){
    @<Open a new file@>@;
    @<Write the header@>@;
    old_tagvalue=(unsigned char*)0;
}
@ @<Write the header@>=
fprintf(outfile,"<html>\n<head>\n<title>%s</title>\n</head>\n",new_tagname);
fprintf(outfile,"<body>\n");
@ @<Open a new file@>=
sprintf(outfilename,"%s.html",new_tagname);
@<Append a trailer and close |outfile|@>@;
outfile=fopen(outfilename,"a");
if(!outfile){
    fprintf(stderr,"Could not open file \"%s\" for writing.\n",outfilename);
    _exit(0);
}
@ @<Append a trailer and close |outfile|@>=
if(outfile) {
    fprintf(outfile,"\n</body>\n</html>\n");
    fclose(outfile);
}
@ @<Clean up...@>=
@<Append a trail...@>@;
@ @<Initialize the program@>=
outfile=(FILE*)0;
@ @<Read the file@>=
filefd=open(filename,O_RDONLY);
if(filefd<0){
    fprintf(stderr,"Could not open file \"%s\".\n",filename);
    _exit(0);
}
@ @<Clean up...@>=
close(filefd);
@ @<Read the file@>=
if(fstat(filefd,&filestat)){
    fprintf(stderr,"Error stating the file.\n");
    _exit(0);
}
@ @<Read the file@>=
filebuf=(unsigned char*)malloc(filestat.st_size);
if(!filebuf){
    fprintf(stderr,"Could not allocate space for the file.\n");
    _exit(0);
}
@ @<Clean up...@>=
free(filebuf);
@ @<Read the file@>=
for(ii=0;ii<filestat.st_size;ii+=numread){
    numread=read(filefd,&filebuf[ii],filestat.st_size-ii);
    if(numread < 0){
        fprintf(stderr,"Error reading the file.\n"); 
        _exit(0);
    }
    if(numread==0)
        break;
}
fileend=&filebuf[ii];
@ @<Parse the command line@>=
filename=http_server_name=(char*)0;
for(ii=1;ii<argc;++ii){
    if(strcmp(argv[ii],"-f")==0){
        ++ii;
       filename=argv[ii]; 
    }
    if(strcmp(argv[ii],"-http")==0){
        ++ii;
        http_server_name=argv[ii]; 
    }
    if(strcmp(argv[ii],"-h")==0){
        @<Print a us...@>@; 
    }
}
if(!filename || !http_server_name){
    @<Print a usage statement@>@;
}
@ @<Print a us...@>=
fprintf(stderr,"Usage: %s <-f filename> <-http server> [-h]\n",argv[0]);
_exit(0);
@ @<Header incl...@>=
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <chess.h>
