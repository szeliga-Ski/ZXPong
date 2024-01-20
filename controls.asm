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
;ld   a, $f7                ; A = half-row 1-5
;in   a, ($fe)              ; Reads half-stack status
;bit  $00, a                ; 1 pressed?
;jr   nz, scanKeys_2        ; Not pressed, jumps
;; Pressed; changes the speed of ball 1 (fast)
;ld   a, (ballSetting)      ; A = configuration ball A
;and  $cf                   ; Set the speed bits to 0
;or   $10                   ; Sets the speed bits to 1
;ld   (ballSetting), a      ; Load value to memory
;jr   scanKeys_speed        ; Jump check controls
;scanKeys_2:
;bit  $01, a                ; 2 pressed?
;jr   nz, scanKeys_3        ; Not pressed, skips
;; Pressed; changes ball speed 2 (middle)
;ld   a, (ballSetting)      ; A = ball configuration
;and  $cf                   ; Set the speed bits to 0
;or   $20                   ; Sets the speed bits to 2
;ld   (ballSetting), a      ; Load value to memory
;jr   scanKeys_speed        ; Jump check controls
;scanKeys_3:
;bit  $02, a                ; 3 pressed?
;jr   nz, scanKeys_ctrl     ; Not pressed, skip
;; Pressed; changes the speed of the ball 3 (slow)
;ld   a, (ballSetting)      ; A configuration = ball
;or   $30                   ; Sets the speed bits to 3
;ld   (ballSetting), a      ; Load value to memory
;
;scanKeys_speed:
;xor  a                     ; A = 0
;ld   (countLoopBall), a    ; CountLoopBall iterations = 0
;
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

WaitStart:
LD   A, $F7                 ; A = keys half-row 1-5
IN   A, ($FE)               ; Read keyboard
BIT  $04, A                 ; 5 pressed?
JR   NZ, WaitStart          ; Not pressed, loop
RET