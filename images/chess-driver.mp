input chess.mp

if unknown chess_h:
	chess_h=1/4in;
fi;

if unknown chess_w:
	chess_w=1/4in;
fi;
rook_height=3/4chess_h;
rook_base_width=1/2chess_w;
rook_top_width=7/8rook_base_width;
rook_notch_depth=1/3rook_top_height;
rook_neck_width=2/3rook_top_width;
rook_base_height=1/15rook_height;
rook_top_height=1/4rook_height;

pawn_neck_width=1/4pawn_collar_width;
pawn_base_width=1/2chess_w;
pawn_height=3/4chess_h;
pawn_collar_width=5/6pawn_base_width;
pawn_chest_width=1/2pawn_collar_width;
pawn_base_height=1/15pawn_height;
pawn_waist_offset=1/5pawn_height;
pawn_head_height=1/6pawn_height;
pawn_waist_width=4/5pawn_base_width;

king_height=3/4chess_h;
king_band_height=1/8king_height;
king_band_offset=3/5king_band_height;
king_band_width=1/2chess_w;
king_diadem_dimen=3/10king_band_width;
king_diadem_offset=11/20king_height;

queen_height=king_height;
queen_band_height=king_band_height;
queen_band_offset=king_band_offset;
queen_band_width=king_band_width;
queen_diadem_rad=1/18chess_w;
queen_top_width=8/5queen_band_width;

bishop_button_skew=1/3bishop_band_width;
bishop_band_width=1/3chess_w;
bishop_tassel_depth=1/8bishop_height;
bishop_tassel_width=4/5chess_w;
bishop_hat_skew=1/6bishop_hat_width;
bishop_band_height=1/8bishop_height;
bishop_hat_width=5/4bishop_band_width;
bishop_height=3/4chess_h;
bishop_diadem_rad=queen_diadem_rad;

knight_height=3/4chess_h;
knight_ear_height=1/5knight_height;
knight_base_width=1/2chess_w;
knight_nose_offset=1/4chess_w;
knight_ear_right_shift=1/6knight_base_width;

def White_Pawn = pawn(White) enddef;
def Black_Pawn = pawn(Black) enddef;
def White_Rook = rook(White) enddef;
def Black_Rook = rook(Black) enddef;
def White_Knight = knight(White) enddef;
def Black_Knight = knight(Black) enddef;
def White_Bishop = bishop(White) enddef;
def Black_Bishop = bishop(Black) enddef;
def White_Queen = queen(White) enddef;
def Black_Queen = queen(Black) enddef;
def White_King = king(White) enddef;
def Black_King = king(Black) enddef;

vardef white_pawn(expr p,q) =
	save currentpicture;
	picture currentpicture;
	currentpicture := nullpicture;
	draw White_Pawn shifted(p*chess_w,q*chess_h);
	currentpicture
enddef;

vardef white_rook(expr p,q) =
	save currentpicture;
	picture currentpicture;
	currentpicture := nullpicture;
	draw White_Rook shifted(p*chess_w,q*chess_h);
	currentpicture
enddef;

vardef white_knight(expr p,q) =
	save currentpicture;
	picture currentpicture;
	currentpicture := nullpicture;
	draw White_Knight shifted(p*chess_w,q*chess_h);
	currentpicture
enddef;

vardef white_bishop(expr p,q) =
	save currentpicture;
	picture currentpicture;
	currentpicture := nullpicture;
	draw White_Bishop shifted(p*chess_w,q*chess_h);
	currentpicture
enddef;

vardef white_queen(expr p,q) =
	save currentpicture;
	picture currentpicture;
	currentpicture := nullpicture;
	draw White_Queen shifted(p*chess_w,q*chess_h);
	currentpicture
enddef;

vardef white_king(expr p,q) =
	save currentpicture;
	picture currentpicture;
	currentpicture := nullpicture;
	draw White_King shifted(p*chess_w,q*chess_h);
	currentpicture
enddef;

vardef black_pawn(expr p,q) =
	save currentpicture;
	picture currentpicture;
	currentpicture := nullpicture;
	draw Black_Pawn shifted(p*chess_w,q*chess_h);
	currentpicture
enddef;

vardef black_rook(expr p,q) =
	save currentpicture;
	picture currentpicture;
	currentpicture := nullpicture;
	draw Black_Rook shifted(p*chess_w,q*chess_h);
	currentpicture
enddef;

vardef black_knight(expr p,q) =
	save currentpicture;
	picture currentpicture;
	currentpicture := nullpicture;
	draw Black_Knight shifted(p*chess_w,q*chess_h);
	currentpicture
enddef;

vardef black_bishop(expr p,q) =
	save currentpicture;
	picture currentpicture;
	currentpicture := nullpicture;
	draw Black_Bishop shifted(p*chess_w,q*chess_h);
	currentpicture
enddef;

vardef black_queen(expr p,q) =
	save currentpicture;
	picture currentpicture;
	currentpicture := nullpicture;
	draw Black_Queen shifted(p*chess_w,q*chess_h);
	currentpicture
enddef;

vardef black_king(expr p,q) =
	save currentpicture;
	picture currentpicture;
	currentpicture := nullpicture;
	draw Black_King shifted(p*chess_w,q*chess_h);
	currentpicture
enddef;

def begin_board =
	currentpicture := nullpicture;
	for i=0upto7:
		for j=0upto7:
			draw chess_square(i,j);
		endfor;
	endfor;
enddef;
	
numeric the_move;
the_move := 0;

def shipout_move = 
	charcode := the_move;
	the_move := the_move+1;
	shipout currentpicture;
enddef;
