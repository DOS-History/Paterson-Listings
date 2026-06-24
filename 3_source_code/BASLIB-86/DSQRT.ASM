        TITLE   DSQRT - Double precision square root

;The method used here is to get a good estimate using single-precision square
;root and then use two Newton-Raphson iterations.

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FAC:BYTE, $DAC:WORD, $TEMP:WORD, $ARG:WORD

DATA    ENDS


DC      GROUP   DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $SQD

        EXTRN   $SAVREG:NEAR, $SSQRT:NEAR, $DDIV:NEAR, $DADD:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;*** $SQD - Double precision square root
;
; Inputs:
;       BX = Address of operand
; Outputs:
;       Result in FAC
; Registers:
;       Only F affected.

$SQD:
        CALL    $SAVREG
        MOV     SI,BX
        MOV     DI,OFFSET DC:$ARG
        MOVSW                   ;Move argument to ARG
        MOVSW
        MOVSW
        MOVSW
        ADD     BX,4            ;Pretend argument it single precision
        CALL    $SSQRT          ;Get S.P. square root as first guess
        XOR     AX,AX
        MOV     [$DAC],AX
        MOV     [$DAC+2],AX     ;Zero extended part
        CALL    NEWTON
NEWTON:
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$TEMP
        MOVSW
        MOVSW
        MOVSW
        MOVSW                   ;Copy guess to TEMP
        MOV     SI,OFFSET DC:$ARG
        MOV     DI,OFFSET DC:$DAC
        CALL    $DDIV           ;DAC = ARG/guess
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$TEMP
        CALL    $DADD           ;DAC = guess + (ARG/guess)
        DEC     [$FAC]          ;DAC = [guess + (ARG/guess)] / 2
        RET

CODE    ENDS
        END
