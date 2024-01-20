; Point scored
C_3:        EQU $0D07           ; note
C_3_FQ:     EQU $0082 / $10     ; 1/16s duration

; Paddle hit
C_4:        EQU $066E           ; note
C_4_FQ:     EQU $0105 / $10     ; duration

; Border
C_5:        EQU $0326
C_5_FQ:     EQU $020B / $10

BEEPER:     EQU $03B5           ; ROM routine: HL=note, DE=duration

; receives value in A: 1=point scored, 2=paddle, 3=border
PlaySound:
PUSH    DE
PUSH    HL
CP      $01                     ; see if it's a point scored
JR      Z, playSound_point
CP      $02                     ; paddle collision?
JR      Z, playSound_paddle
LD      HL, C_5                 ; must be the paddle then!
LD      DE, C_5_FQ
JR      beep

playSound_point:
LD      HL, C_3
LD      DE, C_3_FQ
JR      beep

playSound_paddle:
LD      HL, C_4
LD      DE, C_4_FQ

beep:
PUSH    AF
PUSH    BC
PUSH    IX
CALL    BEEPER
POP     IX
POP     BC
POP     AF
POP     HL
POP     DE
RET