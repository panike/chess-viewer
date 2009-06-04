vardef circarc(expr c,p) =
    for i=0 upto11:
        (p shifted -c rotated (30i) shifted c) ..
    endfor cycle
enddef;

vardef midpoint(expr p,q) = 1/2[p,q] enddef;

vardef node@#(expr the_pic,where) =
    path @#pp;
    pair @#c;   
    @#c = where;
    draw the_pic shifted (-midpoint(urcorner the_pic,llcorner the_pic))
        shifted @#c;
    @#pp=circarc(where,(urcorner the_pic) shifted @#c);
    draw @#pp;
enddef;

def node_trans(suffix a,b)(expr the_pic,bend) =
    begingroup save p,midp;
        path p;
        pair midp;
        if bend = 0:
            midp = midpoint(a.c,b.c);
        else:
            midp = a.c+whatever*((b.c-a.c)rotated bend);
            midp = b.c+whatever*((b.c-a.c)rotated (-bend));
        fi
        p = a.c .. {(b.c-a.c)} midp .. b.c;
        drawarrow (p cutbefore a.pp) cutafter b.pp;
        draw the_pic transformed begingroup
            save rr,ss; numeric rr,ss;
            (rr,ss)=unitvector(b.c-a.c);
            if abs ss > 0.6: % Not going to turn
                if ss > 0:
                    if rr > 0:
                        identity shifted (-lrcorner the_pic) shifted midp
                    elseif rr<0:
                        identity shifted (-urcorner the_pic) shifted midp
                    else:
                        identity shifted
                            (-midpoint(lrcorner the_pic,urcorner the_pic))
                            shifted midp
                    fi
                elseif ss < 0:
                    if rr >= 0:
                        identity shifted (-llcorner the_pic) shifted midp
                    else:
                        identity shifted (-ulcorner the_pic) shifted midp
                    fi
                fi
            else:
                if rr > 0:
                    identity shifted (-midpoint(llcorner the_pic,
                        lrcorner the_pic)) zscaled(rr,ss) shifted midp
                else:
                    identity shifted (-midpoint(llcorner the_pic,
                        lrcorner the_pic)) zscaled(-rr,-ss) shifted midp
                fi
            fi endgroup;
    endgroup;
enddef;

beginfig(1);
save hdiff,vdiff;
pair hdiff,vdiff;
hdiff=(1in,0);
vdiff=(0,1in);
z0=(0,0);
z0-z16=vdiff;
z17-z16=z18-z17=z19-z18=hdiff; % Takes care of castling.
z1-z0=vdiff;
z4-z0=hdiff;
z2-z1=hdiff;
z3-z1=vdiff;
z5-z2=3/2hdiff+1/2vdiff;
z8-z3=hdiff;
z9-z4=1/2hdiff+1/2vdiff;
2z13=z12+z18;
z12-z4=hdiff;
z7-z5=2hdiff-vdiff;
z6-z19=hdiff;
z10-z9=1/2hdiff+1/2vdiff;
z11-z9=3/2hdiff;
z14-z12=7/5hdiff;
node.a(btex $0$ etex,z0);
node.b(btex $1$ etex,z1);
node.c(btex $2$ etex,z2);
node.d(btex $3$ etex,z3);
node.e(btex $4$ etex,z4);
node.f(btex $5$ etex,z5);
node.g(btex $6$ etex,z6);
node.h(btex $7$ etex,z7);
node.i(btex $8$ etex,z8);
node.j(btex $9$ etex,z9);
node.k(btex $10$ etex,z10);
node.l(btex $11$ etex,z11);
node.m(btex $12$ etex,z12);
node.n(btex $13$ etex,z13);
node.o(btex $14$ etex,z14);
% node.p(btex $15$ etex,z15);
node.q(btex $16$ etex,z16);
node.r(btex $17$ etex,z17);
node.s(btex $18$ etex,z18);
node.t(btex $19$ etex,z19);

node_trans(a,e)(btex {\tt [KQBNR]} etex,0);
node_trans(a,q)(btex {\tt O} etex,0);
node_trans(a,b)(btex {\tt [abcdefgh]} etex,0);
node_trans(b,c)(btex {\tt [12345678]} etex,0);
node_trans(b,d)(btex {\tt x} etex,0);
node_trans(c,h)(btex {\tt +} etex,30);
node_trans(c,f)(btex {\tt =} etex,0);
node_trans(d,i)(btex {\tt[abcdefgh]} etex,0);
node_trans(e,j)(btex {\tt[abcdefgh]} etex,0);
node_trans(e,n)(btex {\tt[12345678]} etex,0);
node_trans(e,m)(btex {\tt x} etex,0);
node_trans(f,g)(btex {\tt [QBNR]} etex,15);
node_trans(g,h)(btex {\tt +} etex,0);
node_trans(i,c)(btex {\tt [12345678]} etex,0);
node_trans(j,k)(btex {\tt [abcdefgh]} etex,0);
node_trans(j,l)(btex {\tt [12345678]} etex,0);
node_trans(j,m)(btex {\tt x} etex,0);
node_trans(k,g)(btex {\tt [12345678]} etex,0);
node_trans(l,m)(btex {\tt x} etex,0);
node_trans(l,k)(btex {\tt [abcdefgh]} etex,0);
node_trans(l,h)(btex {\tt+} etex,0);
node_trans(m,o)(btex {\tt [abcdefgh]} etex,0);
node_trans(n,m)(btex {\tt x} etex,0);
node_trans(n,o)(btex {\tt[abcdefgh]} etex,0);
node_trans(o,g)(btex {\tt [12345678]} etex,0);
node_trans(q,r)(btex {\tt-} etex,0);
node_trans(r,s)(btex {\tt O} etex,0);
node_trans(s,t)(btex {\tt-} etex,0);
node_trans(s,h)(btex {\tt+} etex,-10);
node_trans(t,g)(btex {\tt O} etex,0);
endfig;

beginfig(2);
save hdiff,vdiff;
pair hdiff,vdiff;
hdiff zscaled(0,1)=vdiff=(0,1in);
z0=(0,0);
z1-z0=vdiff+2hdiff;
z3-z2=z2-z1=hdiff;
z3-z4=vdiff;
x5=x6=1/3[x0,x3];
y5=midpoint(y4,y3);
z5-z6=vdiff;
node.aaa(btex $0$ etex,z0);
node.bbb(btex $1$ etex,z1);
node.ccc(btex $2$ etex,z2);
node.ddd(btex $3$ etex,z3);
node.eee(btex $4$ etex,z4);
node.fff(btex $5$ etex,z5);
node.ggg(btex $6$ etex,z6);
node_trans(aaa,bbb)(btex {\tt[} etex,15);
node_trans(bbb,ccc)(btex {\tt TAG} etex,0);
node_trans(ccc,ddd)(btex {\tt TAG} etex,0);
node_trans(ddd,eee)(btex {\tt]} etex,0);
node_trans(eee,bbb)(btex {\tt[} etex,0);
node_trans(eee,fff)(btex {\tt COMMENT} etex,0);
node_trans(eee,ggg)(btex {\tt MOVE} etex,0);
node_trans(fff,ggg)(btex {\tt MOVE} etex,30);
node_trans(fff,aaa)(btex {\tt TERMINATOR} etex,0);
node_trans(ggg,fff)(btex {\tt MOVE|NUMBER} etex,30);
node_trans(ggg,aaa)(btex {\tt TERMINATOR} etex,15);
endfig;
end
