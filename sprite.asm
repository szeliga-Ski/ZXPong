FILL:           EQU $FF
ZERO:           EQU $00
LINE:           EQU $80

;PADDLE:         EQU $3C     ; shape: 00111100
PADDLE1:        EQU $0F
PADDLE2:        EQU $F0
PADDLE1POS_INI: EQU $4861
PADDLE2POS_INI: EQU $487E
PADDLE_BOTTOM:  EQU $A6     ; TTLLLSSS - lower max position is third 2, line 5,
                            ; scanline 0 - the paddle extends 23 scanlines below

PADDLE_TOP:     EQU $02     ; TTLLLSSS - upper max position is
                            ; third 0, line 0, scanline 0

paddle1pos:     DW  $4861   ; 010T TSSS LLLC CCCC - position changes during play
                            ; starts at third 1, line 3, scanline 0, column 1
paddle2pos:     DW  $487E   ; 010T TSSS LLLC CCCC - position changes during play
                            ; starts at third 1, line 3, scanline 0, column 30

; Limits of the objects on the screen
BALL_BOTTOM:    EQU $B8     ; TTLLLSSS
BALL_TOP:       EQU $02     ; TTLLLSSS

; Ball sprite: 1 line at 0, 4 lines 3c, 1 line at 0
ballPos:        DW  $4870   ; 010T TSSS LLLC CCCC
BALLPOS_INI:    EQU $4850   ; initial ball position
ballMovCount:   db $00      ; used to change the tilt of the ball

; Ball speed and direction - see p.145 top
; bits 0 to 2: (slope info- see book)
; bits 3 to 5: ball speed
; bit 6:       X direction: 0 right / 1 left
; bit 7:       Y direction: 0 up / 1 down
ballSetting:    DW  $19;$21     ; Y X yyy xxx.  0010 0001=Right, upwards, slowly.
ballRotation:   DW  $F8     ; right positive, left negative

; Ball sprite:
;     1 line at 0, 4 lines 3c, 1 line at 0
ballRight:     ;  Right        Sprite         Left
db $3c, $00    ; +0/$00 00111100    00000000 -8/$f8
db $1e, $00    ; +1/$01 00011110    00000000 -7/$f9
db $0f, $00    ; +2/$02 00001111    00000000 -6/$fa
db $07, $80    ; +3/$03 00000111    10000000 -5/$fb
db $03, $c0    ; +4/$04 00000011    11000000 -4/$fc
db $01, $e0    ; +5/$05 00000001    11100000 -3/$fd
db $00, $f0    ; +6/$06 00000000    11110000 -2/$fe
db $00, $78    ; +7/$07 00000000    01111000 -1/$ff
ballLeft:
db $00, $3c    ; +8/$08 00000000    00111100 +0/$00

MARGIN_LEFT:     EQU $00
MARGIN_RIGHT:    EQU $1E

CROSS_LEFT:      EQU $01     ; column of paddle1
CROSS_RIGHT:     EQU $1d     ; column of paddle2
CROSS_LEFT_ROT:  EQU $FF     ; ball rotation when colliding with paddles
CROSS_RIGHT_ROT: EQU $01     ;

POINTS_P1:       EQU $450d
POINTS_P2:       EQU $4511
POINTS_X1_L:     EQU $0C
POINTS_X1_R:     EQU $0F
POINTS_X2_L:     EQU $10
POINTS_X2_R:     EQU $13
POINTS_Y_B:      EQU $14

White_sprite:
ds $10	; 16 spaces = 16 bytes at $00

Zero_sprite:
db $00, $7e, $7e, $66, $66, $66, $66, $66
db $66, $66, $66, $66, $66, $7e, $7e, $00

One_sprite:
db $00, $18, $18, $18, $18, $18, $18, $18
db $18, $18, $18, $18, $18, $18, $18, $00

Two_sprite:
db $00, $7e, $7e, $06, $06, $06, $06, $7e
db $7e, $60, $60, $60, $60, $7e, $7e, $00

Three_sprite:
db $00, $7e, $7e, $06, $06, $06, $06, $3e
db $3e, $06, $06, $06, $06, $7e, $7e, $00

Four_sprite:
db $00, $66, $66, $66, $66, $66, $66, $7e
db $7e, $06, $06, $06, $06, $06, $06, $00

Five_sprite:
db $00, $7e, $7e, $60, $60, $60, $60, $7e
db $7e, $06, $06, $06, $06, $7e, $7e, $00

Six_sprite:
db $00, $7e, $7e, $60, $60, $60, $60, $7e
db $7e, $66, $66, $66, $66, $7e, $7e, $00

Seven_sprite:
db $00, $7e, $7e, $06, $06, $06, $06, $06
db $06, $06, $06, $06, $06, $06, $06, $00

Eight_sprite:
db $00, $7e, $7e, $66, $66, $66, $66, $7e
db $7e, $66, $66, $66, $66, $7e, $7e, $00

Nine_sprite:
db $00, $7e, $7e, $66, $66, $66, $66, $7e
db $7e, $06, $06, $06, $06, $7e, $7e, $00

Zero:
dw White_sprite, Zero_sprite

One:
dw White_sprite, One_sprite

Two:
dw White_sprite, Two_sprite

Three:
dw White_sprite, Three_sprite

Four:
dw White_sprite, Four_sprite

Five:
dw White_sprite, Five_sprite

Six:
dw White_sprite, Six_sprite

Seven:
dw White_sprite, Seven_sprite

Eight:
dw White_sprite, Eight_sprite

Nine:
dw White_sprite, Nine_sprite

Ten:
dw One_sprite, Zero_sprite

Eleven:
dw One_sprite, One_sprite

Twelve:
dw One_sprite, Two_sprite

Thirteen:
dw One_sprite, Three_sprite

Fourteen:
dw One_sprite, Four_sprite

Fifteen:
dw One_sprite, Five_sprite

Sixteen:
dw One_sprite, Six_sprite

Seventeen:
dw One_sprite, Seven_sprite

Eighteen:
dw One_sprite, Eight_sprite

Nineteen:
dw One_sprite, Nine_sprite

Twenty:
dw Two_sprite, Zero_sprite

Twenty_One:
dw Two_sprite, One_sprite

Twenty_Two:
dw Two_sprite, Two_sprite

Twenty_Three:
dw Two_sprite, Three_sprite

Twenty_Four:
dw Two_sprite, Four_sprite

Twenty_Five:
dw Two_sprite, Five_sprite

Twenty_Six:
dw Two_sprite, Six_sprite

Twenty_Seven:
dw Two_sprite, Seven_sprite

Twenty_Eight:
dw Two_sprite, Eight_sprite

Twenty_Nine:
dw Two_sprite, Nine_sprite

Thirty:
dw Three_sprite, Zero_sprite

Thirty_One:
dw Three_sprite, One_sprite

Thirty_Two:
dw Three_sprite, Two_sprite

Thirty_Three:
dw Three_sprite, Three_sprite

Thirty_Four:
dw Three_sprite, Four_sprite

Thirty_Five:
dw Three_sprite, Five_sprite

Thirty_Six:
dw Three_sprite, Six_sprite

Thirty_Seven:
dw Three_sprite, Seven_sprite

Thirty_Eight:
dw Three_sprite, Eight_sprite

Thirty_Nine:
dw Three_sprite, Nine_sprite

Forty:
dw Four_sprite, Zero_sprite

Forty_One:
dw Four_sprite, One_sprite

Forty_Two:
dw Four_sprite, Two_sprite

Forty_Three:
dw Four_sprite, Three_sprite

Forty_Four:
dw Four_sprite, Four_sprite

Forty_Five:
dw Four_sprite, Five_sprite

Forty_Six:
dw Four_sprite, Six_sprite

Forty_Seven:
dw Four_sprite, Seven_sprite

Forty_Eight:
dw Four_sprite, Eight_sprite

Forty_Nine:
dw Four_sprite, Nine_sprite

Fifty:
dw Five_sprite, Zero_sprite

Fifty_One:
dw Five_sprite, One_sprite

Fifty_Two:
dw Five_sprite, Two_sprite

Fifty_Three:
dw Five_sprite, Three_sprite

Fifty_Four:
dw Five_sprite, Four_sprite

Fifty_Five:
dw Five_sprite, Five_sprite

Fifty_Six:
dw Five_sprite, Six_sprite

Fifty_Seven:
dw Five_sprite, Seven_sprite

Fifty_Eight:
dw Five_sprite, Eight_sprite

Fifty_Nine:
dw Five_sprite, Nine_sprite

Sixty:
dw Six_sprite, Zero_sprite

Sixty_One:
dw Six_sprite, One_sprite

Sixty_Two:
dw Six_sprite, Two_sprite

Sixty_Three:
dw Six_sprite, Three_sprite

Sixty_Foure:
dw Six_sprite, Four_sprite
