        TITLE   DEXP - Double precision exponential function

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FAC:BYTE, $DAC:WORD, $ARG:WORD, $TEMP:WORD

DATA    ENDS


CONST   SEGMENT WORD PUBLIC 'CONST'

        EXTRN   $DBLONE:WORD, $DLOG2E:WORD

;Coefficients for Hart's 1323, relative error 17.26, range [0,1/2].
; 2^x = 1 + 2xP(x^2) / [Q(x^2) - xP(x^2)]
; These constants have been checked with MuMath

PTAB    DW      2                                       ;Degree
        DB      004H,0A3H,0E6H,052H,04DH,030H,03DH,07BH ;+0.02309432127295385660455
        DB      0B2H,0BBH,0ABH,0E4H,014H,09DH,021H,085H ;+20.20170000695312603946477
        DB      091H,09EH,03BH,04EH,0A7H,03BH,03DH,08BH ;+1513.86417304653561981057161

QTAB    DW      2                                       ;Degree
        DB      000H,000H,000H,000H,000H,000H,000H,081H ;+1
        DB      0CBH,0FEH,09FH,09DH,0A0H,02DH,069H,088H ;+233.17823205143103579679705
        DB      085H,0FDH,0A6H,098H,0B5H,080H,008H,08DH ;+4368.08867006741698646914202

CONST   ENDS


DC      GROUP   DATA,CONST


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $EXD,$DEXP

        EXTRN   $DPOLY2:NEAR, $DPOLYX:NEAR, $SAVREG:NEAR
        EXTRN   $DDIV:NEAR, $DADD:NEAR, $DMUL:NEAR, $DSUB:NEAR
        EXTRN   $IND:FAR, $OVFL:NEAR, $PUT1D:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


ONE:
;Argument is too small. Jam result to one.
        JMP     $PUT1D

NOPOLY:
        CALL    $PUT1D
        JMP     FIGEXP

OVERCHKJ:JMP    OVERCHK

;***  $EXD - Exponential (base e) function
;
; Inputs:
;       BX = Address of argument
; Outputs:
;       Result in FAC
; Registers:
;       Only F affected.

$EXD:
        CALL    $SAVREG
$DEXP:
        MOV     SI,BX
        MOV     DI,OFFSET DC:$DLOG2E    ;Log base 2 of e
        CALL    $DMUL
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$ARG
        MOVSW                   ;Move argument to ARG
        MOVSW
        MOVSW
        LODSW                   ;Get sign and exponent
        STOSW
        CMP     AH,88H          ;True exp. >= 8 means ABS(X) >= 128
        JAE     OVERCHKJ        ;   which could cause overflow
        CMP     AH,80H-56       ;True exp. < -56 means result is just 1
        JB      ONE             ;   since EXP(X)=1+X for X<<1
        MOV     BX,OFFSET DC:$DAC
        CALL    $IND            ;Perform FLOOR function
        PUSH    [$DAC+6]        ;Save so we can convert to 1-byte integer
        MOV     SI,OFFSET DC:$ARG
        MOV     DI,OFFSET DC:$DAC
        CALL    $DSUB           ;FAC = X - INT(X)  --> FAC>=0
        MOV     AL,[$FAC]
        SUB     AL,1            ;FAC = FAC/2, carry set if underflow
        JBE     NOPOLY
        MOV     [$FAC],AL
        PUSH    [$DAC]          ;Save reduced X (range [0,1/2])
        PUSH    [$DAC+2]
        PUSH    [$DAC+4]
        PUSH    [$DAC+6]
        MOV     BX,OFFSET DC:PTAB
        CALL    $DPOLYX         ;Compute xP(x^2)
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$TEMP
        MOVSW
        MOVSW
        MOVSW
        MOVSW
        POP     [$DAC+6]
        POP     [$DAC+4]
        POP     [$DAC+2]
        POP     [$DAC]
        MOV     BX,OFFSET DC:QTAB
        CALL    $DPOLY2         ;Compute Q(x^2)
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$TEMP
        CALL    $DSUB           ;DAC = Q(x^2) - xP(x^2)
        MOV     SI,OFFSET DC:$TEMP
        MOV     DI,OFFSET DC:$DAC
        CALL    $DDIV           ;DAC = xP(x^2) / [Q(x^2) - xP(x^2)]
        INC     [$FAC]          ;DAC = DAC*2 - overflow not possible
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$DBLONE
        CALL    $DADD           ;DAC = DAC + 1
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,SI
        CALL    $DMUL           ;Square to account for divide by two above
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

SUBEXP:
        SUB     [$FAC],AL
        JA      RET
ZERO:
        MOV     [$FAC],0        ;Underflow - force to zero
RET:    RET

CODE    ENDS
        END
