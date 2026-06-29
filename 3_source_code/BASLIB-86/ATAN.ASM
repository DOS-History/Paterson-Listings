        TITLE   ATAN - Arc tangent

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FAC:BYTE, $AC:WORD, $ARG:WORD, $TEMP:WORD

DATA    ENDS

CONST   SEGMENT WORD PUBLIC 'CONST'

        EXTRN   $ONE:WORD,$HALFPI:WORD,$SIXTHPI:WORD,$SQRT3:WORD
        EXTRN	$TANTWELFTHPI:WORD

;Coefficients for Hart 4940, relative error 7.69
;ATAN(x) = xP(x^2)
; These constants have been checked with MuMath

ATANTAB DW      3                       ;Degree
        DB      062H,035H,083H,07EH     ;-0.12813 3334
        DB      050H,024H,04CH,07EH     ;+0.19935 72694
        DB      079H,0A9H,0AAH,07FH     ;-0.33332 42344 5
        DB      000H,000H,000H,081H     ;+0.99999 99797 73

CONST   ENDS


DC      GROUP   DATA,CONST


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $ATN

        EXTRN   $SAVREG:NEAR, $SPOLYX:NEAR
        EXTRN   $SDIV:NEAR, $SMUL:NEAR, $SADD:NEAR, $SSUB:NEAR, $SCMP:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;$ATN - Arc tangent
;
; Inputs:
;       BX = Address of argument
; Outputs:
;       Result in FAC
; Registers:
;       Only F affected.

$ATN:
        CALL    $SAVREG
        MOV     SI,BX
        MOV     DI,OFFSET DC:$AC
        MOVSW                   ;Put in FAC
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
        MOV     SI,OFFSET DC:$ONE
        MOV     DI,OFFSET DC:$AC
        CALL    $SDIV           ;It's reciprocal is < 1
        CALL    LESSTHAN1       ;Compute arc-cotan on number < 1
        MOV     SI,OFFSET DC:$HALFPI
        MOV     DI,OFFSET DC:$AC
        JMP     $SSUB           ;Correct by subtracting from PI/2

LESSTHAN1:
        MOV     SI,OFFSET DC:$TANTWELFTHPI
        MOV     DI,OFFSET DC:$AC
        CALL    $SCMP           ;Compare argument to PI/12
        JAE     DOATAN          ;Range reduction complete if <= PI/12
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$ARG
        MOVSW                   ;Save X in ARG
        MOVSW
        MOV     SI,OFFSET DC:$SQRT3  ;Point to TAN(PI/6) (PI/6 = 30 degrees)
        MOV     DI,OFFSET DC:$AC
        CALL    $SADD           ;FAC = X + TAN(PI/6)
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$TEMP
        MOVSW                   ;Save in TEMP
        MOVSW
        MOV     SI,OFFSET DC:$SQRT3
        MOV     DI,OFFSET DC:$ARG
        CALL    $SMUL           ;FAC = X * TAN(PI/6)
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$ONE
        CALL    $SSUB           ;FAC = X * TAN(PI/6) - 1
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$TEMP
        CALL    $SDIV           ;FAC = (X*TAN(PI/6) - 1)/(X + TAN(PI/6)
        CALL    DOATAN          ;Compute arctan on argument < PI/12
        MOV     SI,OFFSET DC:$SIXTHPI
        MOV     DI,OFFSET DC:$AC
        JMP     $SADD           ;Correct for range reduction by adding PI/6

DOATAN:
        MOV     BX,OFFSET DC:ATANTAB
        JMP     $SPOLYX

CODE    ENDS
        END
