        TITLE   EXP - Exponential function

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FAC:BYTE, $AC:WORD, $ARG:WORD

DATA    ENDS


CONST   SEGMENT WORD PUBLIC 'CONST'

        EXTRN   $LOG2E:WORD

;Constants for Hart's 1302, relative error 7.91
; 2^x = 1 + xP(x) = Q(x)
; These constants have been checked with MuMath

EXPTAB  DW      6                       ;Degree
        DB      07CH,088H,059H,074H     ; +0.00020745 57740 3
        DB      0E0H,097H,026H,077H     ; +0.0012710 05745 69
        DB      0C4H,01DH,01EH,07AH     ; +0.0096506 50932 02
        DB      05EH,050H,063H,07CH     ; +0.055496 56508 324
        DB      01AH,0FEH,075H,07EH     ; +0.24022 71381 7633
        DB      018H,072H,031H,080H     ; +0.69314 71721 3716
        DB      000H,000H,000H,081H     ; +1.0

CONST   ENDS


DC      GROUP   DATA,CONST


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $EXP, $EXP2

        EXTRN   $SPOLY:NEAR, $SAVREG:NEAR, $SMUL:NEAR, $SSUB:NEAR
        EXTRN   $INT:FAR, $OVFL:NEAR, $PUT1:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;***  $EXP - Exponential (base e) function
;
; Inputs:
;       BX = Address of argument
; Outputs:
;       Result in FAC
; Registers:
;       Only F affected.

$EXP:
        CALL    $SAVREG
        MOV     SI,BX
        MOV     DI,OFFSET DC:$LOG2E     ;Log base 2 of e
        CALL    $SMUL

;***  $EXP2 - Compute 2^(FAC)
;
; Inputs:
;       Argument in FAC
; Outputs:
;       Result in FAC
; Registers:
;       All registers destroyed

$EXP2:
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$ARG
        MOVSW                   ;Move argument to ARG
        LODSW                   ;Get sign and exponent
        STOSW
        CMP     AH,88H          ;True exp. >= 8 means ABS(X) >= 128
        JAE     OVERCHK         ;   which could cause overflow
        CMP     AH,80H-24       ;True exp. < -24 means result is just 1
        JB      ONE             ;   since EXP(X)=1+X for X<<1
        MOV     BX,OFFSET DC:$AC
        CALL    $INT            ;Perform FLOOR function
        PUSH    [$AC+2]         ;Save so we can convert to 1-byte integer
        MOV     SI,OFFSET DC:$ARG
        MOV     DI,OFFSET DC:$AC
        CALL    $SSUB           ;FAC = X - INT(X)  --> FAC >= 0
        CMP     [$FAC],0
        JZ      NOPOLY
        MOV     BX,OFFSET DC:EXPTAB
        CALL    $SPOLY
FIGEXP:
        POP     AX              ;Recover INT(X)
        OR      AH,AH           ;Was it zero?
        JZ      RET             ;If so, we're done
        MOV     CL,88H
        SUB     CL,AH           ;Amount to shift mantissa right to make int.
        CBW                     ;Remember sign
        OR      AL,80H          ;Set implied bit
        SHR     AL,CL           ;AL now is INT(X)
        OR      AH,AH           ;Check sign
        JNZ     SUBEXP
        ADD     [$FAC],AL       ;Add to exponent
        JC      OVER
        RET

OVERCHK:
        OR      AL,AL           ;Positive or negative argument?
        JS      ZERO
OVER:   JMP     $OVFL

NOPOLY:
        CALL    $PUT1
        JMP     FIGEXP

SUBEXP:
        SUB     [$FAC],AL
        JA      RET
ZERO:
        MOV     [$FAC],0        ;Underflow - force to zero
RET:    RET

ONE:
;Argument is too small. Jam result to one.
        JMP     $PUT1

CODE    ENDS
        END
