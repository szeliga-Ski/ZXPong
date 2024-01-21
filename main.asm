;ORG  $8000
;ORG  $5DAD      ; for 16K compatibility
ORG  $5E88      ; 16k and loading screen

Main:
LD   A, $00                 ; black border
OUT  ($FE), A               ;

CALL Cls                    ; Clear the screen
CALL PrintLine              ; Display the centre line/net
CALL PrintBorder            ; Display the top & bottom borders
CALL PrintPoints            ; Display score 0-0
;CALL WaitStart              ; Wait for '5' to be pressed to start the game
CALL WaitSpace
LD   A, ZERO                ; and reset player scores since we might be
LD   (p1points), A          ; here at the start of a new game at the end
LD   (p2points), A          ; of loop_continue
CALL PrintPoints            ; redisplay the 0-0 scoreline
LD   HL, BALLPOS_INI
LD   (ballPos), HL
LD   HL, PADDLE1POS_INI
LD   (paddle1pos), HL
LD   HL, PADDLE2POS_INI
LD   (paddle2pos), HL
LD   A, $03                 ; set sound effect
CALL PlaySound              ; and play it

Loop:
ld   a, (ballSetting)
;rrca
rrca
rrca
rrca
and  $07
ld   b, a
LD   A, (countLoopBall)     ; only move the ball once every 15 times
INC  A                      ;
LD   (countLoopBall), A     ;
CP   b                      ; originally CP $1C
JR   NZ, loop_paddle        ;
CALL MoveBall               ; calculate the ball's new coord's
XOR  A                      ; reset ball motion delay counter
LD   (countLoopBall), A     ;

loop_paddle:
LD   A, (countLoopPaddle)   ; Slow the paddles down by only moving them
INC  A                      ; every 3rd value of the countLoopPaddl
LD   (countLoopPaddle), A   ;
CP   $02                    ;
JR   NZ, loop_continue      ; Don't move the paddle since countLoopPaddle != 0

CALL ScanKeys               ; See if a player is pressing a control key
CALL MovePaddle             ; and move their paddle if so.
XOR  A                      ; Paddle has moved so reset its motion counter
LD   (countLoopPaddle), A   ;

loop_continue:
CALL CheckBallCross         ; check whether a ball has hit a paddle
CALL PrintBall              ; display the ball
CALL ReprintLine            ; repaint a cell of the centre line under the ball
CALL ReprintPoints          ; repaint the score
LD   HL, (paddle1pos)       ; display paddle 1
LD   C, PADDLE1
CALL PrintPaddle            ;
LD   HL, (paddle2pos)       ;
LD   C, PADDLE2
CALL PrintPaddle            ; display paddle 2
LD   A, (p1points)          ; the game ends once a player gets 15 points
CP   $40                    ; does player1 have 64 points?
JP   Z, Main                ; Yes, so start again
LD   A, (p2points)          ; Otherwise check player2's score
CP   $40                    ; does player2 have 64 points?
JP   Z, Main                ; Yes, so start again
JP   Loop                   ; otherwise keep going with the current game

include "controls.asm"
include "game.asm"
include "sound.asm"
include "sprite.asm"
include "video.asm"

countLoopBall:   DB $00     ; used to slow the ball down
countLoopPaddle: DB $00     ; used to slow the paddles down
p1points:        db $00     ; Player 1's score
p2points:        db $00     ; Player 2's score

;end  $8000
end  Main   ; 16k compatibility