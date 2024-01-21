BORDCR:     EQU $5C48       ; system variable for border colour

;--------------------------------------------------------------------
; Gets the corresponding sprite to paint on the marker.
; Input:  A  -> score.
; Output: HL -> address of the sprite to be painted.
; Alters the value of the AF, BC and HL registers.
;--------------------------------------------------------------------
GetPointSprite:
;ld   hl, Zero              ; HL = address sprite 0
;ld   bc, $04               ; Sprite is 4 bytes away from 
;                           ; the previous one
;inc  a                     ; Increment A, loop start != 0
;getPointSprite_loop:
;dec  a                     ; Decreasing A
;ret  z                     ; A = 0, end of routine
;add  hl, bc                ; Add 4 to sprite address
;jr   getPointSprite_loop   ; Loop until A = 0	
;
; the following works up to 61 points without changing the MARKER PRINT routine
LD   HL, Zero
ADD  A,A
ADD  A,A
LD   B, ZERO
LD   C, A
ADD  HL, BC
RET

; the following works up to 99 points without changing the MARKER PRINT routine
;LD   H, ZERO
;LD   L, a
;ADD  HL, HL
;ADD  HL, HL
;LD   BC, Zero
;ADD  HL, BC
;RET

;-------------------------------------------------------------------------------
; NextScan
; https://wiki.speccy.org/cursos/ensamblador/gfx2_direccionamiento
; Gets the memory location corresponding to the scanline.
; The next to the one indicated.
;     010T TSSS LLLC CCCC
; Input:  HL -> current scanline.
; Output: HL -> scanline next.
; Alters the value of the AF and HL registers.
;-------------------------------------------------------------------------------
NextScan:
INC  H               ; Increment H to increase the scanline
LD   A, H            ; Load the value in A
and  $07             ; Keeps the bits of the scanline
RET  NZ              ; If the value is not 0, end of routine  

; Calculate the following line
LD   A, L            ; Load the value in A
add  A, $20          ; Add one to the line (%0010 0000)
LD   L, A            ; Load the value in L
RET  C               ; If there is a carry-over, it has changed its position,
                     ; the top is already adjusted from above. End of routine.

; If you get here, you haven't changed your mind and you have to adjust 
; as the first INC H increased it.
LD   A, H            ; Load the value in A
SUB  $08             ; Subtract one third (%0000 1000)
LD   H, A            ; Load the value in H
ret

; ------------------------------------------------------------------------------
; PreviousScan
; https://wiki.speccy.org/cursos/ensamblador/gfx2_direccionamiento
; Gets the memory location corresponding to the scanline.
; The following is the first time this has been done; prior 
; to that indicated.
;     010T TSSS LLLC CCCC
; Input:  HL -> current scanline.	    
; Output: HL -> previous scanline.
; Alters the value of the AF, BC and HL registers.
;-------------------------------------------------------------------------------
PreviousScan:
LD   A, H                  ; Load the value in A
dec  H                     ; Decrements H to decrement the scanline
AND  $07                   ; Keeps the bits of the original scanline
RET  NZ                    ; If not at 0, end of routine

; Calculate the previous line
LD   A, L                  ; Load the value of L into A
SUB  $20                   ; Subtract one line
LD   L, A                  ; Load the value in L
RET  C                     ; If there is carry-over, end of routine

; If you arrive here, you have moved to scanline 7 of the previous line
; and subtracted a third, which we add up again
LD   A, H                  ; Load the value of H into A
ADD  A, $08                ; Returns the third to the way it was
LD   H, A                  ; Load the value in h
RET

; ------------------------------------------------------------------------------
ClearBall:                  ; ballPos: 010T TSSS LLLC CCCC
LD   HL, (ballPos)          ; we are going to erase the ball
LD   A, L                   ; keep just the column
AND  $1F                    ;
CP   $10                    ; see if it is column 16 (centre of the screen)
JR   C, clearBall_continue  ; Carry => it is on the left border so clear ball
INC  L                      ; No jump so we must be on the right hand border so
                            ; increment as ball is painted 1 column to the right
clearBall_continue:
LD   B, $06                 ; 6 scanlines for the ball
clearBall_loop:
LD   (HL), ZERO             ; clear a scanline of the ball
CALL NextScan               ; move to the next line of the ball
DJNZ clearBall_loop         ; loop
RET

; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
Cls:
LD   HL, $4000              ; start of screen display
LD   (HL), $00              ; empty byte
LD   DE, $4001              ; pointer to 2nd byte of screen display
LD   BC, $17ff              ; number of bytes to erase
LDIR                        ; clear the rest of the screen

;LD   HL, $5800              ; point to the 1st byte of the attribute area
LD   A, $07                 ; black paper, white ink
INC  HL                     ; optimised
LD   (HL), A; $07              ; white ink, black background
;LD   DE, $5801              ; 2nd byte of attribute file
INC  DE                     ; optimised
LD   BC, $2ff               ; size of attribute file - 1 byte (already in HL)
LDIR                        ; set all bytes in the attribute file
LD   (BORDCR), A
RET
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
PrintBorder:
LD   HL, $4100              ; address of third 0, line 0, scanline 1
LD   DE, $56E0              ; address of third 2, line 7, scanline 6
LD   B, $20                 ; 32 columns
LD   A, FILL                ; border sprite

printBorder_loop:
LD   (HL), A
LD   (DE), A
INC  L
INC  E
DJNZ printBorder_loop
RET
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
PrintLine:
LD   B, $18                 ; we will print the centre line on all 24 lines
LD   HL, $4010              ; and in column 16

printLine_loop:
LD   (HL), ZERO             ; the 1st scan line is blank
INC  H                      ; move to the next scan line (same third, same line)
PUSH BC                     ; store BC as B will be used later as a loop counter
LD   B, $06                 ; 6 more scanlines to draw
printLine_loop2:
LD   (HL), LINE             ; draw the next scanline
INC  H                      ; move to the next scanline
DJNZ printLine_loop2        ; loop round
POP  BC                     ; restore BC to continue with the 24 display lines
LD   (HL), ZERO             ; draw the last scanline
CALL NextScan               ; change line on the display
DJNZ printLine_loop         ; loop until B=0=24 lines
RET

ReprintLine:                ; reprints char of the centre line erased by ball
LD   HL, (ballPos) 
LD   A, L                   ; line and column in A
AND  $E0                    ; keep the line coord
OR   $10                    ; set the column coord to 16
LD   L, A                   ; store the coords of centre line cell just erased
LD   B, $06                 ; loop counter for 6 scanlines to redraw
reprintLine_loop:
LD   A, H                   ; the screen third + final scanline in A
AND  $07                    ; keep the scanline info
CP   $01                    ; if less than 1 (i.e. scanline 0) then jump
JR   C, reprintLine_loopCont;00      ;
CP   $07                    ; if it is scanline 7 then jump
JR   Z, reprintLine_loopCont;00      ;
;LD   C, LINE                ; otherwise we are looking at scanlines 1-6
;JR   reprintLine_loopCont   ; so jump & print the line sprite that is in C
;reprintLine_00:
;LD   C, ZERO                ; blank scanline sprite for top and bottom scanlines
LD   A, (HL)                ; load screen byte that has been erased by ball
OR   LINE;C                      ; add in the sprite data
LD   (HL), A                ; and write back out
reprintLine_loopCont:
call NextScan               ; calculate the address of the next scan line
DJNZ reprintLine_loop       ; and loop.
RET
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
PrintPaddle:
LD   (HL), ZERO             ; to print first scan line of the paddle
CALL NextScan               ; move to the next line
LD   B, $16                 ; paddle has 22 visible scan lines

printPaddle_loop:
LD   (HL), C           ; print paddle shape
CALL NextScan               ; move to the next line
DJNZ printPaddle_loop       ; loop for the rest of the visible paddle
LD   (HL), ZERO             ; blank line at the bottom of the paddle
RET
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
CheckBottom:
CALL checkVerticalLimit     ; see if we have hit a vertical limit
RET  C                      ; return if C is set to show we're above lower limit

checkBottom_bottom:
XOR  A                      ; we have hit the lower limit so set Z flag
RET                         ; and return

CheckTop:
CALL checkVerticalLimit
RET

checkVerticalLimit:         ; HL is current pos,  A is upper limit
LD   B, A                   ; need to convert the format in HL to format in A
    ;LD   A, H
    ;AND  $18                    ; extract the "third" bits
    ;RLCA                        ; put "third" into bits 6 and 7
    ;RLCA
    ;RLCA
    ;LD   C, A
    ;LD   A, H
    ;AND  $07
    ;OR   C
    ;LD   C, A
    ;LD   A, L
    ;AND  $e0
    ;RRCA
    ;RRCA
    ;OR   C
CALL GetPtrY                ; Y-coord (TTLLLSSS) of the current position
CP   B                      ; A=B?  B=value  A=vertical limit
RET
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
PrintBall:
LD  B, $00
LD  A, (ballRotation)
LD  C, A
CP  $00
LD  A, $00
JP  P, printBall_right
printBall_left:
LD  HL, ballLeft
SUB C
ADD A, A
LD  C, A
SBC HL, BC
JR  printBall_continue

printBall_right:
; Ball rotation is clockwise
ld   hl, ballRight         ; HL = address bytes ball
add  a, c                  ; A = A+C, ball rotation
add  a, a                  ; A = A+A, ball = two bytes
ld   c, a                  ; C = A
add  hl, bc                ; HL = HL+BC (ball offset)

printBall_continue:
; The address of the ball definition is loaded in DE.
ex   de, hl
ld   hl, (ballPos)         ; HL = ball position

; Paint the first line in white
ld   (hl), ZERO            ; Moves target to screen position
inc  l                     ; L = next column
ld   (hl), ZERO            ; Moves target to screen position
dec  l                     ; L = previous column
call NextScan              ; Next scanline

ld   b, $04                ; Paint ball in next 4 scanlines
printBall_loop:
ld   a, (de)               ; A = byte 1 definition ball
ld   (hl), a               ; Load ball definition on screen
inc  de                    ; DE = next byte definition ball
inc  l                     ; L = next column
ld   a, (de)               ; A = byte 2 definition ball
ld   (hl), a               ; Load ball definition on screen
dec  de                    ; DE = first byte definition ball
dec  l                     ; L = previous column
call NextScan              ; Next scanline
djnz printBall_loop        ; Until B = 0

; Paint the last blank line
ld   (hl), ZERO            ; Moves target to screen position
inc  l                     ; L = next column
ld   (hl), ZERO            ; Moves target to screen position

ret
; ------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Gets third, line and scanline of a memory location.
; Input:  HL -> Memory location of a screen address. (010T TSSS LLLC CCCC)
; Output: A  -> Third, line and scanline obtained (TTLLLSSS)
; Alters the value of the AF and E registers.
;-------------------------------------------------------------------------------
GetPtrY:
ld   a, h                  ; A = H (third and scanline in format 010T TSSS)
and  $18                   ; A = third
rlca
rlca
rlca                       ; Passes value of third to bits 6 and 7
ld   e, a                  ; E = A (TT00 0000)
ld   a, h                  ; A = H (third and scanline)
and  $07                   ; A = scanline (0000 0SSS)
or   e                     ; A OR E = Third and scanline (TT00 0SSS)
ld   e, a                  ; E = A = TT000SSS
ld   a, l                  ; A = L (row and column LLLC CCCC)
and  $e0                   ; A = line = LLL0 0000
rrca		
rrca                       ; Passes line value to bits 3 to 5 (00LL L000)
or   e                     ; A OR E = TTLLLLSSS

ret
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Paint the scoreboard.
; Each number is 1 byte wide by 16 bytes high.
; Alters the value of the AF, BC, DE and HL registers.
;--------------------------------------------------------------------
PrintPoints:
CALL printPoint_1_print
JR   printPoint_2_print
printPoint_1_print:
ld   a, (p1points)         ; A = points player 1
call GetPointSprite        ; Gets sprite to be painted in marker
; 1st digit of player 1
ld   e, (hl)               ; HL = low part 1st digit address
                           ; E = (HL)
inc  hl                    ; HL = high side address 1st digit
ld   d, (hl)               ; D = (HL)
push hl                    ; Preserves the value of HL
ld   hl, POINTS_P1         ; HL = memory address where to paint
                           ; points player 1
CALL PrintPoint
pop  hl                    ; Retrieves the value of HL

; 2nd digit of player 1
inc  hl			
ld   e, (hl)               ; E = (HL)
inc  hl                    ; HL = high side address 2nd digit
ld   d, (hl)               ; D = (HL)
;Spirax
LD   HL, POINTS_P1 + 1
CALL PrintPoint
RET

printPoint_2_print:
ld   a, (p2points)         ; A = points player 2
call GetPointSprite        ; Gets sprite to be painted in marker
; 1st digit of player 2
ld   e, (hl)               ; HL = low part 1st digit address
                           ; E = (HL)
inc  hl                    ; HL = high side address 1st digit
ld   d, (hl)               ; D = (HL)
push hl                    ; Preserves value of HL
ld   hl, POINTS_P2         ; HL = memory address where to paint
                           ; points player 2
CALL PrintPoint
pop  hl                    ; Retrieves the value of HL

; 2nd digit of player 2
inc  hl			
ld   e, (hl)               ; E = (HL)
inc  hl                    ; HL = high side address 2nd digit
ld   d, (hl)               ; D = (HL)
; Spirax
LD   HL, POINTS_P2 + 1

; Paint the second digit of player 2's marker.
PrintPoint:
ld   b, $10                ; Each digit: 1 byte x 16 (scanlines)

printPoint_printLoop:
ld   a, (de)               ; A = byte to be painted
ld   (hl), a               ; Paints the byte
inc  de                    ; DE = next byte
call NextScan              ; HL = next scanline
djnz printPoint_printLoop  ; Until B = 0

ret
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------

;--------------------------------------------------------------------
; Repaint the scoreboard.
; Each number is 1 byte wide by 16 bytes high.
; Alters the value of the AF, BC, DE and HL registers.
;--------------------------------------------------------------------
ReprintPoints:
LD   HL, (ballPos)
CALL GetPtrY
CP   POINTS_Y_B
RET  NC
LD   A, L
AND  $1F
CP   POINTS_X1_L
RET  C
JR   Z, printPoint_1_print
CP   POINTS_X2_R
JR   Z, printPoint_2_print
RET  NC
reprintPoint_1:
CP   POINTS_X1_R
JR   Z, printPoint_1_print
JR   C, printPoint_1_print

reprintPoint_2:
CP   POINTS_X2_L
RET  C

JR   printPoint_2_print

; ------------------------------------------------------------------------------