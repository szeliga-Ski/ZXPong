;-------------------------------------------------------------------------------
; ScanKeys
; Scans the control keys and returns the pressed keys.
; Output: D -> Keys pressed.
;         Bit 0 -> A pressed 0/1.
;         Bit 1 -> Z pressed 0/1.
;         Bit 2 -> 0 pressed 0/1.
;         Bit 3 -> O pressed 0/1.
; Alters the value of the AF and D registers.
;-------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Player 1 uses keys A and Z
; Player 2 uses keys 0 and O
;
; Keys have a status of 1 if not pressed, and 0 if they have been pressed
; ------------------------------------------------------------------------------

ScanKeys:
;scanKeys_ctrl:
LD   D, $00                 ; reset D register as no key pressed yet

scanKeys_A:
LD   A, $FD                 ; look at half-row of keys A-G
IN   A, ($FE)               ; read keyboard status using port $FE into A
BIT  $00, A                 ; see if bit 0 is 0 to show key A was pressed
JR   NZ, scanKeys_Z         ; key A not pressed so jump to check for key Z
SET  $00, D                 ; set bit 0 of D to 1 to show A was pressed

scanKeys_Z:
LD   A, $FE                 ; look at half-row of keys CAPS-V
IN   A, ($FE)               ; read keyboard status using port $FE into A
BIT  $01, A                 ; see if bit 1 is 0 to show key Z was pressed
JR   NZ, scanKeys_0         ; key A not pressed so jump to check for key Z
SET  $01, D                 ; set bit 0 of D to 1 to show Z was pressed

; Check that two keys have not been pressed
LD   A, D                   ; if both A and Z are pressed then do nothing
SUB  $03                    ; D=$03 if both scanKeys_A and scanKeys_Z ran
JR   NZ, scanKeys_0         ; only 1 key pressed so jump to check for player 2
LD   D, A                   ; both keys pressed and A=0 so store in D

scanKeys_0:
LD   A, $EF                 ; look at keys 0-6
IN   A, ($FE)               ; read status of the half-row
BIT  $00, A                 ; see if 0 was pressed
JR   NZ, scanKeys_O         ; if not pressed then skip
SET  $02, D                 ; set corresponding bit to show that 0 was pressed

scanKeys_O:
LD   A, $CF                 ; load the P-Y half-row
IN   A, ($FE)               ; read status of the half-row
BIT  $01, A                 ; check if O was pressed
RET  NZ                     ; return if not pressed
SET  $03, D                 ; set the bit corresponding to O to 1

; Check that player 2 is not pressing both their keys
LD   A, D                   ; load D into A
AND  $0C                    ; keep the bits for 0 and O
CP   $0C                    ; check whether the two keys are pressed
RET  NZ                     ; return if they are not both pressed
LD   A, D                   ; Both pressed so load D into A
AND  $03                    ; mask off the bits for keys A and Z
LD   D, A                   ; store in D

RET

;WaitStart:
;LD   A, $F7                 ; A = keys half-row 1-5
;IN   A, ($FE)               ; Read keyboard
;BIT  $04, A                 ; 5 pressed?
;JR   NZ, WaitStart          ; Not pressed, loop
;RET

; the original code from the game gets the player to press 5 to start
; but then every time they win a point the ball gets served automatically
; so I am going to change it from using key 5 to SPACE & use it to "serve|
WaitSpace:
    LD A, $7F               ; the half-row containing the SPACE key
    in a, ($FE)            ; read keyboard
    BIT  $00, A                 ; SPACE pressed?
    jr nz, WaitSpace        ; if not SPACE, loop
    ret                     ; if SPACE, return