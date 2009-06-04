save chess_w, chess_h;
numeric chess_w,chess_h;
chess_w=chess_h=1/2in;
input chess-driver

beginfig(1);
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw white_pawn(0,0); endfig;
beginfig(2);
	fill (0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle
	withcolor (0.7,0.7,0.7); 
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw white_pawn(0,0); endfig;
beginfig(3);
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw white_rook(0,0); endfig;
beginfig(4);
	fill (0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle
	withcolor (0.7,0.7,0.7); 
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw white_rook(0,0); endfig;
beginfig(5);
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw white_knight(0,0); endfig;
beginfig(6);
	fill (0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle
	withcolor (0.7,0.7,0.7); 
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw white_knight(0,0); endfig;
beginfig(7);
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw white_bishop(0,0); endfig;
beginfig(8);
	fill (0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle
	withcolor (0.7,0.7,0.7); 
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw white_bishop(0,0); endfig;
beginfig(9);
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw white_queen(0,0); endfig;
beginfig(10);
	fill (0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle
	withcolor (0.7,0.7,0.7); 
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw white_queen(0,0); endfig;
beginfig(11);
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw white_king(0,0); endfig;
beginfig(12);
	fill (0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle
	withcolor (0.7,0.7,0.7); 
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw white_king(0,0); endfig;
beginfig(13);
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw black_pawn(0,0); endfig;
beginfig(14);
	fill (0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle
	withcolor (0.7,0.7,0.7); 
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw black_pawn(0,0); endfig;
beginfig(15);
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw black_rook(0,0); endfig;
beginfig(16);
	fill (0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle
	withcolor (0.7,0.7,0.7); 
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw black_rook(0,0); endfig;
beginfig(17);
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw black_knight(0,0); endfig;
beginfig(18);
	fill (0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle
	withcolor (0.7,0.7,0.7); 
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw black_knight(0,0); endfig;
beginfig(19);
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw black_bishop(0,0); endfig;
beginfig(20);
	fill (0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle
	withcolor (0.7,0.7,0.7); 
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw black_bishop(0,0); endfig;
beginfig(21);
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw black_queen(0,0); endfig;
beginfig(22);
	fill (0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle
	withcolor (0.7,0.7,0.7); 
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw black_queen(0,0); endfig;
beginfig(23);
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw black_king(0,0); endfig;
beginfig(24);
	fill (0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle
	withcolor (0.7,0.7,0.7); 
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
	draw black_king(0,0); endfig;
beginfig(25);
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
endfig;
beginfig(26);
	fill (0,0)--(chess_w,0)--(chess_w,chess_h)--(0,chess_h)--cycle
	withcolor (0.7,0.7,0.7); 
	draw (0,1)--(chess_w,1)--(chess_w,chess_h)--(0,chess_h)--cycle withpen pencircle scaled 1pt;
endfig;
end
