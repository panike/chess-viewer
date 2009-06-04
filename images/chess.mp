if unknown chess_h:
	numeric chess_h;
fi;

if unknown chess_w:
	numeric chess_w;
fi;

def Black=(0,0,0),(1,1,1)enddef;
def White=(1,1,1),(0,0,0)enddef;

vardef chess_square(expr p,q)=
  save pp;
  save currentpicture;
  path pp;
  picture currentpicture;
  currentpicture := nullpicture;
  pp=((0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle) shifted
  (p*chess_w,q*chess_h);
  if odd (p+q):
    fill pp withcolor (1,1,1);
  else:
    fill pp withcolor (0.7,0.7,0.7);
  fi;
  draw pp;
  currentpicture
enddef;

def beginpiece =
  save pp,currentpicture;
  picture currentpicture;
  path pp[];

  currentpicture:=nullpicture;
%  pickup pencircle scaled3;
  begingroup
  save x,y,sz,z;
  vardef z@#=(x@#,y@#)enddef;

% This choice of "l" and "r" suffixes may be confusing to experienced
% users of METAFONT. Most of the chess piece representations are
% symmetric, and the "l" and "r" suffixes mean the left hand point
% and the right hand point.
  
  vardef sz@#(expr len) =
    x@#r-x@#l=len;
    x@#r+x@#l=chess_w;
    y@#r=y@#l=y@#;
    x@#=1/2chess_w;
  enddef;
enddef;

def endpiece =
endgroup
enddef;

save rook_height,rook_base_width,rook_top_width;
numeric rook_height,rook_base_width,rook_top_width,rook_notch_depth;
numeric rook_neck_width,rook_base_height,rook_top_height;

vardef rook(expr p,q) =
  beginpiece;
  y.top-y.bot=rook_height;
  y.top+y.bot=chess_h;
  sz.bot(rook_base_width);
  sz0(rook_base_width);
  sz1(rook_neck_width);
  sz2(rook_top_width);
  sz.top(rook_top_width);
  sz4(3/5rook_top_width);
  sz5(1/5rook_top_width);
  sz6(3/5rook_top_width);
  sz7(1/5rook_top_width);
  y6=y7=y.top-rook_notch_depth;
  y4=y5=y.top;
  y0-y.bot=rook_base_height;
  y.top-y2=rook_top_height;
  y1=y2;
  pp0=z.bot.l{right}..z.bot.r{right}..{left}z0r--z0l{left}..cycle;
  sz8(0); z8-z0l=whatever*dir 45;
  pp1=z0r{z8-z0r}..{up}z1r--z1l{down}..{z0l-z8}z0l--cycle;
  pp2=z1r{z2r-z1r}..{up}z.top.r--z4r--z6r--z7r--z5r--z5l--z7l--z6l--
  z4l--z.top.l{down}..{z1l-z2l}z1l--cycle;
  for i=0upto2:
    fill pp[i] withcolor p;
  endfor;
  for i=0upto2:
    draw pp[i] withcolor q;
  endfor;
  endpiece;
  currentpicture
enddef;

save pawn_neck_width, pawn_base_width,pawn_height,pawn_collar_width;
save pawn_chest_width, pawn_base_height, pawn_waist_offset,pawn_head_height;
save pawn_waist_width;
numeric pawn_neck_width, pawn_base_width,pawn_height,pawn_collar_width;
numeric pawn_chest_width, pawn_base_height, pawn_waist_offset,pawn_head_height;
numeric pawn_waist_width;

vardef pawn(expr p,q) =
  beginpiece;
  y.top-y.bot=pawn_height;
  y.top+y.bot=chess_h;
  sz.top(0);
  sz.bot(pawn_base_width);
  sz0(pawn_base_width); y0-y.bot=pawn_base_height;
  sz1(pawn_waist_width); y1=y0;
  sz2(pawn_neck_width); y2-y1=pawn_waist_offset;
  sz3(pawn_chest_width); y3=11/20[y2,y4];
  sz4(pawn_neck_width);
  sz5(pawn_collar_width); y5=y4;
  sz6(pawn_neck_width); y.top-y6=pawn_head_height;
  z6l-z5l=whatever*dir30;
  pp0=z.bot.r{right}..z0r{left}--z0l{left}..z.bot.l{right}--cycle;
  pp1=z0r{z1r-z0r}..z2r{up}..z3r{up}..{up}z4r--z4l{down}..z3l{down}..
  z2l{down}..{z0l-z1l}z0l--cycle;
  pp2=z5r--z6r..z.top{left}..z6l--z5l--cycle;
  for i=0upto2:
    fill pp[i] withcolor p;
  endfor;
  for i=0upto2:
    draw pp[i] withcolor q;
  endfor;
  endpiece;
  currentpicture
enddef;  

save king_height,king_band_height,king_band_offset,king_band_width;
save king_diadem_dimen, king_diadem_offset;
numeric king_height,king_band_height,king_band_offset,king_band_width;
numeric king_diadem_dimen, king_diadem_offset; 

vardef king(expr p,q)=
  beginpiece;
  sz.top(5/4king_band_width);
  sz.bot(king_band_width);
  y.top-y.bot=king_height; y.top+y.bot=chess_h;
  sz0(king_band_width); y0-y.bot=king_band_height;
  sz2(0); sz5(0); sz6(0);
  y5-y.bot=y.bot-y6=king_band_offset; y2-y5=king_band_height;
  sz1(x.top.r-x.top.l+4/3*(x0r-x0l)); y.top-y1=y2-y0;
  sz3(king_diadem_dimen); sz4(king_diadem_dimen);
  y3-y2=king_diadem_offset;
  y4-y3=x3r-x3l;
  pp0=(z.bot.r..z5{left}..z.bot.l);
  pp1=((z.bot.l..z6{right}..z.bot.r)&pp0)..cycle;
  pp2=(pp0&z.bot.l--z0l..z2{right}..z0r)--cycle;
  pp3=z2{up}..z3r{z.top.r-z2}..z.top.r{z1r-z.top.r}..{z0r-z1r}z0r{curl1}..
  {left}cycle;
  pp4=z2{up}..z3l{z.top.l-z2}..z.top.l{z1l-z.top.l}..{z0l-z1l}z0l{curl1}..
  {right}cycle;
  pp5=z3r--z4r--z4l--z3l--cycle;
  for i=1upto5:
    fill pp[i] withcolor p;
  endfor;
  for i=1upto5:
    draw pp[i] withcolor q;
  endfor;
  draw 4/5[z3r,z4l]--4/5[z4l,z3r] withcolor q;
  draw 4/5[z3l,z4r]--4/5[z4r,z3l] withcolor q;
  endpiece;
  currentpicture
enddef;

save queen_height,queen_band_height,queen_band_offset,queen_band_width;
save queen_diadem_rad, queen_top_width;
numeric queen_height,queen_band_height,queen_band_offset,queen_band_width;
numeric queen_diadem_rad, queen_top_width; 

% We use the following for the bishop and the queen.
% We just want little buttons on the top of the piece.

vardef circarc(expr p,c) =
  for i=0upto11:
    (p shifted -c rotated (30i) shifted c) ..
  endfor cycle
enddef;

def xshifted tertiary p =
  shifted (p,0)
enddef;

def yshifted tertiary p =
  shifted (0,p)
enddef;

vardef queen(expr p,q) =
  save i,j;
  numeric i,j;
  beginpiece;
  y.top-y.bot=queen_height;
  y.bot+y.top=chess_h;
  sz.bot(queen_band_width);
  sz.top(1/3queen_top_width);
  sz1(queen_top_width);
  sz6(0); sz5(0); sz2(0);
  sz0(queen_band_width);
  y6-y.bot=y.bot-y5=queen_band_offset;
  y0-y.bot=y2-y6=queen_band_height;
  sz8(0);
  y.top-y1=1/3*(y2-y0); y7r=y7=y7l; x7r+x7l=chess_w;
  y7=1/8[y2,y.top]; z7r=whatever[z2 yshifted -2queen_band_offset,z1r];
  y8-y7=1/4*(y7-y2);
  pp0=z.bot.l{curl1}..z5{right}..{curl1}z.bot.r--z0r{up}..z1r--z7r--
  z.top.r--z8--z.top.l--z7l--z1l..{down}z0l--cycle;
  fill pp0 withcolor p;
  draw pp0 withcolor (0,0,0);
  pp1=z.bot.l..z6{right}..z.bot.r;
  pp2=z0l..z2{right}..z0r;
  for i=1upto2: draw pp[i] withcolor q; endfor;
  j:=3;
  forsuffixes $=top,1:
    forsuffixes _=l,r:
      i:=-1+incr j;
      pp[i]=circarc(z$_ xshifted queen_diadem_rad,z$_);
    endfor;
  endfor;
  for $=3upto6:
    fill pp[$] withcolor p;
    draw pp[$] withcolor q;
  endfor;
  endpiece;
  currentpicture
enddef;

save bishop_button_skew, bishop_band_width, bishop_tassel_depth,
bishop_tassel_width,bishop_hat_skew,bishop_band_height,bishop_hat_width,
bishop_height, bishop_diadem_rad;
numeric  bishop_button_skew, bishop_band_width, bishop_tassel_depth,
bishop_tassel_width,bishop_hat_skew,bishop_band_height,bishop_hat_width,
bishop_height;

vardef bishop(expr p,q) =
  beginpiece;
  y.top-y.bot=bishop_height;
  y.top+y.bot=chess_h;
  sz.top(bishop_button_skew);
  sz.bot(bishop_tassel_width);
  sz5(bishop_hat_width);
  sz3(bishop_band_width); y3-y2=bishop_band_height;
  sz2(bishop_band_width); y2-y.bot=bishop_tassel_depth;
  sz4(2bishop_hat_skew-bishop_hat_width);
  sz1(1/2*(bishop_band_width+bishop_tassel_width));
  sz0(1/2*(bishop_band_width+bishop_tassel_width));
  y0-y.bot=y1-y0=y2-y1;
  sz6(0); y6=y2;
  y4=y5; y.top-y5=y5-y3;
  pp0=z2l..{left}z1l..{curl1}z.bot.l{curl1}..{right}z0l..{(1,1)}z6--cycle;
  pp1=z2r..{right}z1r..{curl1}z.bot.r{curl1}..{left}z0r..{(-1,1)}z6--cycle;
  pp2=z2l--z2r--z3r--z3l--cycle;
  pp3=z3r..z5r{up}..{curl1}z.top.r{curl1}..z4r{z3l-z.top.r}..z3l--cycle;
  pp4=z3r..z4l{z.top.l-z3r}..{curl1}z.top.l{curl1}..z5l{down}..z3l--cycle;
  pp5=circarc(z.top.r xshifted bishop_diadem_rad,z.top.r);
  pp6=circarc(z.top.l xshifted bishop_diadem_rad,z.top.l);
  for i=4,3,0,1,2,5,6:
    fill pp[i] withcolor p;
    draw pp[i] withcolor q;
  endfor;
  draw pp0 withcolor (0,0,0);
  draw pp1 withcolor (0,0,0);
  endpiece;
  currentpicture
enddef;

save knight_height, knight_ear_height, knight_base_width,knight_nose_offset,
     knight_ear_right_shift;
numeric knight_height, knight_ear_height, knight_base_width,knight_nose_offset,
     knight_ear_right_shift;

vardef knight(expr p,q) =
  save pp, currentpicture,z,x,y;
  path pp[];
  picture currentpicture;
  numeric x[],y[];
  vardef z@#=(x@#,y@#)enddef;
  
  currentpicture := nullpicture;
  y2-y0=knight_height; y2+y0=chess_h; y4=y2; y12=y0;
  x0-x12=knight_base_width; x12-x6=knight_nose_offset;
  x0+x6=chess_w;
  x9=x12; x5-x9=knight_ear_right_shift;
  y1=y3=y5=y2-knight_ear_height;
  x1-x2=x2-x3=x3-x4=x4-x5;x1-x5=1/3knight_base_width;
  2(y2-y6)=3(y6-y0);y9=y6;z7=1/3[z6,z12];
  pp0=z0{up}..{(-1,1)}z1--z2--z3--z4--z5{(z6-z1)yscaled1/3}..
	{z6-z1}3/20[z6,z1]..{z7-z6}z7{curl1}...{right}z9..
  {down}z12--cycle;
  fill pp0 withcolor p;
  draw pp0 withcolor (0,0,0);
  currentpicture
enddef;
