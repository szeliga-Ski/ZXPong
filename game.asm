MoveBall:
LD   A, (ballSetting)
AND  $80                     ; bit 7 indicates whether ball is going up or down
JR   NZ, moveBall_down       ; bit 7 is set to 1 so ball is going down

moveBall_up:
LD   HL, (ballPos)
LD   A, BALL_TOP
CALL CheckTop
JR   Z, moveBall_upChg      ; ball is at the top of the screen already so change
                            ; the vertical direction of the ball
CALL MoveBallY              ; does Y-coord of ball need to change?
JR   NZ, moveBall_x         ; no so jump and do x-coord
CALL PreviousScan           ; not at the top of the screen so move ball up
LD   (ballPos), HL          ; store new ball coords
JR   moveBall_x             ; now need to check the horizontal offset

moveBall_upChg:
LD   A, $03                 ; set sound effect
CALL PlaySound              ; and play it
LD   A, (ballSetting)       ; set bit 7 of ballSetting to show ball is going
OR   $80                    ; down after hitting the top of the screen
LD   (ballSetting), A       ; and store the new value.
CALL NextScan               ; calculate the next vertical position of the ball
LD   (ballPos), HL          ; store new ball position
JR   moveBall_x             ; now need to check the horizontal offset

moveBall_down:
LD   HL, (ballPos)
LD   A, BALL_BOTTOM
CALL CheckBottom
JR   Z, moveBall_downChg
CALL MoveBallY              ; does Y-coord of ball need to change?
JR   NZ, moveBall_x         ; no so jump and do x-coord
CALL NextScan
LD   (ballPos), HL
JR   moveBall_x

moveBall_downChg:
LD   A, $03                 ; set sound effect
CALL PlaySound              ; and play it
LD   A, (ballSetting)       ; disable bit 7 to show that ball is now going up
AND  $7F                    ;
LD   (ballSetting), A       ;
CALL PreviousScan           ; calculate ball's new screen position and store
LD   (ballPos), HL          ;

moveBall_x:
LD   A, (ballSetting)       ; check bit 6 to see if the ball is moving left
AND  $40                    ;
JR   NZ, moveBall_left      ;

moveBall_right:
LD   A, (ballRotation)      ; see if we are at rotation #8, the last one.
CP   $08                    ;
JR   Z, moveBall_rightLast  ;
INC  A                      ; no, not the last one so increment the rotation
LD   (ballRotation), A      ; then store
;JR   moveBall_end           ; and jump to the end of the routine
RET

moveBall_rightLast:         
LD   A, (ballPos)           ; last rotation but need to see if the ball is at
AND  $1F                    ; the right border yet
CP   MARGIN_RIGHT           ;
JR   Z, moveBall_rightChg   ; yes, so jump and change ball's direction
LD   HL, ballPos            ; no, so set ball rotation to #1
INC  (HL)                   ;
LD   A, $01                 ;
LD   (ballRotation), A      ;
;JR   moveBall_end           ; and jump to the end of the routine
RET

moveBall_rightChg:
LD   A, $01                 ; set sound effect
CALL PlaySound              ; and play it
LD   HL, p1points           ; add 1 point to Player 1's score
inc  (HL)                   ;
CALL PrintPoints            ; and display
;LD   A, (ballSetting)       ; ball is moving right and hit the border
;OR   $40                    ; so we change the direction by setting bit 6 (left)
;LD   (ballSetting), A       ;
;LD   A, $FF                 ; and set the rotation value
;LD   (ballRotation), A      ;
CALL ClearBall              ; p.126 bottom
CALL SetBallLeft            ; p.126 bottom
;JR   moveBall_end           ; and jump to the end of the routine
LD   A, $03                 ; set sound effect
CALL PlaySound              ; and play it
RET

moveBall_left:
LD   A, (ballRotation)      ; see if we are at the last left rotation
CP   $F8                    ;
JR   Z, moveBall_leftLast   ; yes so jump
DEC  A                      ; no so decrement rotation value
LD   (ballRotation), A      ;
;JR   moveBall_end           ; and jump to the end of the routine
RET

moveBall_leftLast:
LD   A, (ballPos)           ; see if we have hit the left margin
AND  $1F                    ;
CP   MARGIN_LEFT            ;
JR   Z, moveBall_leftChg    ; yes so jump
LD   HL, ballPos            ; no so move left a column
DEC  (HL)                   ;
LD   A, $FF                 ; set the rotation value to -1
LD   (ballRotation), A      ;
;JR   moveBall_end           ; and jump to the end of the routine
RET

moveBall_leftChg:
LD   A, $01                 ; set sound effect
CALL PlaySound              ; and play it
LD   HL, p2points           ; add 1 to player 2's score...
INC  (HL)                   ;
CALL PrintPoints            ; and display
;LD   A, $01                 ; set ball rotation to 1
;LD   (ballRotation), A      ;
;LD   A, (ballSetting)       ; turn off bit 6 so that the ball moves right
;AND  $BF                    ;
;LD   (ballSetting), A       ;
CALL ClearBall              ; p.127 TOP
CALL SetBallRight           ; p.127 TOP
LD   A, $03                 ; set sound effect
CALL PlaySound              ; and play it
;moveBall_end:
RET

MovePaddle:                 ; control keystrokes are in D 
BIT  $00, D                 ; if bit 0 is not set (for moving up) then
JR   Z, movePaddle_1Down    ; jump to check whether to move paddle 1 down
LD   HL, (paddle1pos)       ; otherwise we move paddle 1 up as long as
LD   A, PADDLE_TOP          ; it is not already at the top of the screen
CALL CheckTop               ;
JR   Z, movePaddle_2Up      ; paddle1 is at the top so jump to check paddle2
CALL PreviousScan           ; paddle1 can be moved up so calculate new position
LD   (paddle1pos), HL       ; and store it in paddle1Pos
JR   movePaddle_2Up         ; then go and check paddle2

movePaddle_1Down:
BIT  $01, D                 ; see if paddle 1 "down" key is pressed
JR   Z, movePaddle_2Up      ; no, so check paddle2
LD   HL, (paddle1pos)       ; yes, so see if it is at the bottom of the screen
LD   A, PADDLE_BOTTOM       ;
CALL CheckBottom            ;
JR   Z, movePaddle_2Up      ; at the bottom and cannot move down so jump
CALL NextScan               ; there is room to move down so calc new position
LD   (paddle1pos), HL       ; and store new position

movePaddle_2Up:
BIT  $02, D                 ; if bit 2 is not set (for moving up) then
JR   Z, movePaddle_2Down    ; jump to check whether to move paddle 2 down
LD   HL, (paddle2pos)       ; otherwise we move paddle2 up as long as
LD   A, PADDLE_TOP          ; it is not already at the top of the screen
CALL CheckTop              ;
JR   Z, movePaddle_End      ; paddle2 is at the top so jump to the end
CALL PreviousScan           ; paddle2 can be moved up so calculate new position
LD   (paddle2pos), HL       ; and store it in paddle2Pos
JR   movePaddle_End         ; then jump to the end

movePaddle_2Down:
BIT  $03, D                 ; see if paddle 2 "down" key is pressed
JR   Z, movePaddle_End      ; no, so jump to the end
LD   HL, (paddle2pos)       ; yes, so see if it is at the bottom of the screen
LD   A, PADDLE_BOTTOM       ;
CALL CheckBottom            ;
JR   Z, movePaddle_End      ; at the bottom and cannot move down so jump to end
CALL NextScan               ; there is room to move down so calc new position
LD   (paddle2pos), HL       ; and store new position

movePaddle_End:
RET

MoveBallY:
LD   A, (ballSetting)       ; keep the slope setting of the ball
AND  $07                    ; i.e. the bottom 4 bits
LD   D, A                   ; and store it in D
LD   A, (ballMovCount)     ; Increment number of moves the ball has made
INC  A                      ;
LD   (ballMovCount), A     ;
CP   D                      ; compare number of moves with number of moves
                            ; needed to change Y position
RET  NZ                     ; they're not equal so exit
XOR  A                      ; Set Z flag so caller can change ball's Y position
LD   (ballMovCount), A      ; accumulated ball movements = 0
RET
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
CheckBallCross:
LD   A, (ballSetting)       ; x&y speeds and dir's
AND  $40                    ; see if going left (bit 6 set) or right
JR   NZ, checkBallCross_left  ; bit 6 set so check for collision with paddle1

checkBallCross_right:       ; check for collision with paddle2 on the right
LD   C, CROSS_RIGHT         ; check for collision in x-coords
CALL CheckCrossX            ;
RET  NZ                     ; no, so return
LD   HL, (paddle2pos)       ; check for collision in y-coords
CALL CheckCrossY            ;
RET  NZ                     ; no, so return
LD   A, $02                 ; set sound effect
CALL PlaySound              ; and play it
LD   A, (ballSetting)       ; to get here there must have been a collision
OR  $40                     ; Set status bit to make ball move left
LD  (ballSetting), A        ; store updated setting in variable
LD  A, CROSS_LEFT_ROT       ; change ball rotation to -1 (negative = left)
LD (ballRotation), A        ;
RET

checkBallCross_left:        ; check for collision with paddle1 on the left
LD   C, CROSS_LEFT         ; check for collision in x-coords
CALL CheckCrossX            ;
RET  NZ                     ; no, so return
LD   HL, (paddle1pos)       ; check for collision in y-coords
CALL CheckCrossY            ;
RET  NZ                     ; no, so return
LD   A, $02                 ; set sound effect
CALL PlaySound              ; and play it
LD   A, (ballSetting)       ; to get here there must have been a collision
AND  $BF                    ; Set status bit to make ball move right
LD  (ballSetting), A        ; store updated setting in variable
LD  A, CROSS_RIGHT_ROT      ; change ball rotation to +1 (positive = right)
LD (ballRotation), A        ;
RET

CheckCrossX:                ; check for collision on the x-axis
LD   A, (ballPos)
AND  $1F                    ; leave the column
CP   C                      ; compare with the collision column passed in C
RET                         ; Z flag has been set if the columns are the same

CheckCrossY:                ; check for collision on the y-axis
CALL GetPtrY                ; get y-coord of the PADDLE
INC  A                      ; first line of paddle is blank so move to the next
LD   C, A                   ; load that byte of the paddle into C
LD   HL, (ballPos)          ; load position of the BALL into HL
CALL GetPtrY                ; get y-coord of current ball position (TTLLLSSS)
LD   B, A                   ; and load into B
ADD  A, $04                 ; we want 2 point @ the penultimate scanline of ball
                            ; to see whether the bottom of the ball hits paddle
SUB  C                      ; subtract the y-coord of the paddle
RET  C                      ; if there's a CARRY then the ball is above the
                            ; paddle so return
LD   A, C                   ; Next see if the ball goes UNDER the paddle
                            ; A has y-coord of the PADDLE
ADD  A, $16                 ; Add 22 to point at last scanline of the paddle
LD   C, A                   ; store y-coord of last scanline of the paddle
LD   A, B                   ; Load y-coord of the BALL into A
INC  A                      ; move down past the first blank scanline
SUB  C                      ; subtract y-coord of the PADDLE from BALL's y-coord
JR   Z, checkCrossY_5_5     ; 0? collision in last scanline
RET  NC                     ; return if ball passes underneath paddle or if
                            ; if hits last scanline of the paddle (Zflag is set)
LD   A, C                   ; load penultimate scanline of ball
SUB  $15                    ; move up to its first scanline
LD   C, A                   ; and store
LD   A, B                   ; load ball position
ADD  A, $04                 ; find bottom of the ball
LD   B, A                   ; and store

checkCrossY_1_5:
LD   A, C                   ; vertical position of the paddle
ADD  A, $04                 ; go to last scanline
CP   B                      ; compare with ball position
JR   C, checkCrossY_2_5     ; carry, so ball is lower down
LD   A, (ballSetting)       ; no carry so ball collided
AND  $40                    ; leave horizontal direction (already calculated)
;OR   $21                    ; vertical speed=up, speed 3, semi-diagonal tilt
OR   $19
JR   checkCrossY_end        ; jump to end of routine

checkCrossY_2_5:            ; see if ball collided with 2nd part of paddle
LD   A, C                   ; vertical paddle position
ADD  A, $09                 ; last scanline of 2nd part
CP   B                      ; compare with ball position
JR   C, checkCrossY_3_5     ; carry => ball is lower
LD   A, (ballSetting)       ; no carry so ball collided
AND  $40                    ; leave horizontal direction (already calculated)
;OR   $1A                    ; vertical speed=up, speed 3, semi-diagonal tilt
OR   $12
JR   checkCrossY_end        ; jump to end of routine

checkCrossY_3_5:            ; see if ball collided with 3rd part of paddle
LD   A, C                   ; vertical paddle position
ADD  A, $0D                 ; last scanline of 3rd part
CP   B                      ; compare with ball position
JR   C, checkCrossY_4_5     ; carry => ball is lower
LD   A, (ballSetting)       ; no carry so ball collided
AND  $C0                    ; leave horizontal & vertical dir's (już calc'd)
;OR   $17                    ; speed 1, semi-flat tilt
OR   $0F
JR   checkCrossY_end        ; jump to end of routine

checkCrossY_4_5:            ; see if ball collided with 4th part of paddle
LD   A, C                   ; vertical paddle position
ADD  A, $11                 ; last scanline of 4th part
CP   B                      ; compare with ball position
JR   C, checkCrossY_5_5     ; carry => ball is lower
LD   A, (ballSetting)       ; no carry so ball collided
AND  $40                    ; leave horizontal dir's (already calc'd)
;OR   $9A                    ; down, speed 2, semi-flat tilt
OR   $92
JR   checkCrossY_end        ; jump to end of routine

checkCrossY_5_5:
LD   A, (ballSetting)
AND  $40                    ; keep horizontal direction
;OR   $A1                    ; vertical direction, speed 3, diagonal angle
OR   $99

; There is a collision
checkCrossY_end:
LD   (ballSetting), A       ; Set ball configuration
XOR  A                      ; Flags: Z=1, A=0
LD   (ballMovCount), A      ; Reset ball movement counter
RET                         ;



;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Ball speed and direction.
; bits 0 to 3: speed X: 1 to 4
; bits 4 to 5: speed Y: 0 to 3
; bit 6:       X direction: 0 right / 1 left
; bit 7:       Y direction: 0 up / 1 down
; ballSetting:    DW  $20     ; Y X yyy xxx

; Ball sprite: 1 line at 0, 4 lines 3c, 1 line at 0
; ballPos:        DW  $4870   ; 010T TSSS LLLC CCCC

SetBallLeft:                ; player 2 (on right) lost a point so p1 gets ball
LD   HL, $4D60              ; Set new ball position - left column, halfway down
LD   (ballPos), HL          ;
LD   A, $01                 ; set new ball rotation to 1, i.e. rotating right
LD   (ballRotation),  A     ;
LD   A, (ballSetting)       ; Load ball configuration
;AND  $BF                    ; Mask= 1011 1111 so that ball is going right
AND  $80                    ; keep y-dir
;OR   $21                    ; right, speed 3, diagonal tilt
OR   $19
LD   (ballSetting), A       ; store
LD   A, $00                 ; reset ball movement count
LD   (ballMovCount), A      ;


LD   HL, PADDLE1POS_INI     ; reset the paddle positions
LD   (paddle1pos), HL
LD   HL, PADDLE2POS_INI
LD   (paddle2pos), HL
CALL PrintPaddle 
CALL WaitSpace              ; WAIT FOR THE PLAYER TO SERVE
RET

SetBallRight:               ; player 1 (on left) lost a point so p2 gets ball
LD   HL, $4D7E              ; Set new ball position - right column, halfway down
LD   (ballPos), HL          ;
LD   A, $FF                 ; set new ball rotation to -1, i.e. rotating left
LD   (ballRotation),  A     ;
LD   A, (ballSetting)       ; Load ball configuration
;OR   $40                    ; Mask= 0100 0000 so that ball is going left
AND  $80                    ; keep y-dir
;OR   $61                    ; left, speed 3, diagonal tilt
OR   $59
LD   (ballSetting), A       ; store
LD   A, $00                 ; reset ball movement count
LD   (ballMovCount), A      ;

LD   HL, PADDLE1POS_INI     ; reset the paddle positions
LD   (paddle1pos), HL
LD   HL, PADDLE2POS_INI
LD   (paddle2pos), HL
CALL PrintPaddle 
CALL WaitSpace               ; WAIT FOR THE PLAYER TO SERVE
RET
;-------------------------------------------------------------------------------