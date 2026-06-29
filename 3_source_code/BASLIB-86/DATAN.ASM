        TITLE   DATAN - Double precision arc tangent

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FAC:BYTE, $DAC:WORD, $ARG:WORD, $TEMP:WORD

DATA    ENDS

CONST   SEGMENT WORD PUBLIC 'CONST'

        EXTRN   $DBLONE:WORD,$DHALFPI:WORD,$DSIXTHPI:WORD,$DSQRT3:WORD
        EXTRN   $DTANTWELFTHPI:WORD

;Coefficients for Hart's 4945. Relative error 16.82, range [0,TAN(PI/12)].
;ATAN(x) = xP(x^2)
; These constants have been checked with MuMath

ATANTAB DW      8                                       ;Degree
        DB      018H,0E6H,0C0H,0E4H,0C7H,0D1H,035H,07CH ;+0.0443895157187
        DB      00BH,001H,008H,008H,09BH,0C6H,084H,07DH ;-0.06483193510303
        DB      026H,0C5H,06CH,02EH,002H,046H,01DH,07DH ;+0.0767936869066
        DB      098H,06BH,00AH,09DH,0B9H,02BH,0BAH,07DH ;-0.0909037114191074
        DB      001H,02BH,095H,027H,027H,08EH,063H,07DH ;+0.11111097898051048
        DB      06AH,09CH,0DDH,072H,024H,049H,092H,07EH ;-0.142857141028255452
        DB      0A8H,0EBH,094H,0CCH,0CCH,0CCH,04CH,07EH ;+0.1999999999872944792
        DB      083H,097H,0AAH,0AAH,0AAH,0AAH,0AAH,07FH ;-0.333333333333299308717
        DB      0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,07FH,080H ;+0.9999999999999999849899

CONST   ENDS


DC      GROUP   DATA,CONST


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $ATD

        EXTRN   $SAVREG:NEAR, $DPOLYX:NEAR
        EXTRN   $DDIV:NEAR, $DMUL:NEAR, $DADD:NEAR, $DSUB:NEAR, $DCMP:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;$ATD - Arc tangent
;
; Inputs:
;       BX = Address of argument
; Outputs:
;       Result in FAC
; Registers:
;       Only F affected.

$ATD:
        CALL    $SAVREG
        MOV     SI,BX
        MOV     DI,OFFSET DC:$DAC
        MOVSW                   ;Put in FAC
        MOVSW
        MOVSW
        LODSW
        STOSW
        OR      AH,AH           ;Is it zero?
        JZ      DONE            ;If so, result is too
        TEST    AL,80H          ;Check sign
        JNS     POSATAN
        AND     AL,7FH
        MOV     [$FAC-1],AL     ;Make it positive
        CALL    POSATAN         ;Take arctan of positive number
        XOR     [$FAC-1],80H    ;Invert sign back
DONE:   RET

POSATAN:
        CMP     AH,81H          ;Is it >= 1?
        JB      LESSTHAN1
        MOV     SI,OFFSET DC:$DBLONE
        MOV     DI,OFFSET DC:$DAC
        CALL    $DDIV           ;It's reciprocal is < 1
        CALL    LESSTHAN1       ;Compute arc-cotan on number < 1
        MOV     SI,OFFSET DC:$DHALFPI
        MOV     DI,OFFSET DC:$DAC
        JMP     $DSUB           ;Correct by subtracting from PI/2

LESSTHAN1:
        MOV     SI,OFFSET DC:$DTANTWELFTHPI
        MOV     DI,OFFSET DC:$DAC
        CALL    $DCMP           ;Compare argument to PI/12
        JAE     DOATAN          ;Range reduction complete if <= PI/12
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$ARG
        MOVSW                   ;Save X in ARG
        MOVSW
        MOVSW
        MOVSW
        MOV     SI,OFFSET DC:$DSQRT3  ;Point to TAN(PI/6) (PI/6 = 30 degrees)
        MOV     DI,OFFSET DC:$DAC
        CALL    $DADD           ;FAC = X + TAN(PI/6)
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$TEMP
        MOVSW                   ;Save it in TEMP
        MOVSW
        MOVSW
        MOVSW
        MOV     SI,OFFSET DC:$DSQRT3
        MOV     DI,OFFSET DC:$ARG
        CALL    $DMUL           ;FAC = X * TAN(PI/6)
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$DBLONE
        CALL    $DSUB           ;FAC = X * TAN(PI/6) - 1
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$TEMP
        CALL    $DDIV           ;FAC = (X*TAN(PI/6) - 1)/(X + TAN(PI/6)
        CALL    DOATAN          ;Compute arctan on argument < PI/12
        MOV     SI,OFFSET DC:$DSIXTHPI
        MOV     DI,OFFSET DC:$DAC
        JMP     $DADD           ;Correct for range reduction by adding PI/6

DOATAN:
        MOV     BX,OFFSET DC:ATANTAB
        JMP     $DPOLYX

CODE    ENDS
        END
