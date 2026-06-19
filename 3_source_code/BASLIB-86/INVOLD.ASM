        TITLE   INVOLD - Double precision involution operator

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $DAC:WORD, $ARG:WORD, $FAC:BYTE, $TEMP:WORD, $TEMP2:WORD

POWERCNT DW     ?
FLAG    DB      ?

DATA    ENDS


DC      GROUP   DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $FEXB, $FEXD, $FEXF, $FEXH

        EXTRN   $SAVREG:NEAR, $DMUL:NEAR, $GTMP:NEAR, $LOD:FAR, $DEXP:NEAR
        EXTRN   $DDIV:NEAR, $DSUB:NEAR, $FID:FAR, $DIV0:NEAR, $ERC_FC:NEAR
        EXTRN   $PUT1D:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC

; Suffix B means address of operands in SI and DI
; Suffix D means first operand is FAC, second is at [DI] (SI smashed)
; Suffix F means first operand is at [SI], second is FAC (DI smashed)
; Suffix H means first operand is floating temp, second is FAC (SI and DI hit)

$FEXD:
        MOV     SI,OFFSET DC:$DAC
        JMP     SHORT $FEXB
$FEXH:
        CALL    $GTMP
$FEXF:
        MOV     DI,OFFSET DC:$DAC
$FEXB:
        CALL    $SAVREG
        XOR     AX,AX
        MOV     [FLAG],AL       ;Set sign positive, no mul or div needed yet
        MOV     [POWERCNT],AX
        MOV     AX,[DI+6]       ;Get sign and exponent of Y
        OR      AH,AH           ;Is Y zero?
        JZ      ONE
        MOV     DX,[SI+6]
        OR      DH,DH           ;Is X zero?
        JZ      ZERCHK
        MOV     BX,DI           ;Save address of Y
        MOV     DI,OFFSET DC:$TEMP2
        MOVSW                   ;Save X in TEMP2
        MOVSW
        MOVSW
        MOVSW
        MOV     SI,BX
        MOV     DI,OFFSET DC:$TEMP
        MOVSW                   ;Move Y to TEMP
        MOVSW
        MOVSW
        STOSW                   ;AX already has high word
        CALL    $FID            ;FAC = INT(Y)
;DAC has INT(Y), TEMP has Y, TEMP2 has X
        CMP     AH,80H+16       ;ABS(Y) >= 2^16?
        JBE     SMALLPOWER
;At this point we have a power larger than 2^16. This is so large that
;instead of doing repeat multiplies we will just use EXP(Y*LOG(X))
        OR      DL,DL           ;X < 0?
        JNS     LOGPOWERJ
;Using LOG and EXP is fine if the base is positive. We're here because the
;the base is negative (which won't wash with LOG). Involution is defined
;for negative base only if the power is integer. Then, if the integer is
;odd, the result is -[abs(x)^y]; if even, it's abs(x)^y. If the number is
;too large to include a 2^0 bit in its 56-bit mantissa, then we can't
;determine even or odd and call this an error.
        CMP     AH,80H+56       ;ABS(Y) >= 2^56?
        JA      ARGERR          ;If so, can't tell if odd - error!
        MOV     SI,OFFSET DC:$TEMP
        MOV     DI,OFFSET DC:$DAC
        MOV     CX,3
        REPE    CMPSW           ;Compare Y, INT(Y) to see if Y is integer
        JNZ     ARGERR
;It's going to work, now we just need that 2^0 bit for even/odd determination
        SUB     AH,80H+1        ;Get shift count range 16-55
        MOV     CL,AH
        AND     CL,7            ;Get bit within byte
        MOV     AL,AH
        SHR     AL,1
        SHR     AL,1
        SHR     AL,1
        CBW
        SUB     DI,AX           ;Points to byte with even/odd bit
        MOV     AL,[DI]
        SHL     AL,CL           ;LSB of Y in bit 7, to tell us even or odd
        MOV     [FLAG],AL       ;Use it as sign of result
        AND     BYTE PTR [$TEMP2+6],7FH ;Make X positive
LOGPOWERJ:
        JMP     SHORT LOGPOWER

ONE:    JMP     $PUT1D

ZERCHK:
        MOV     [$FAC],0        ;Put a zero in FAC
        OR      AL,AL           ;Is power negative?
        JNS     RET
        JMP     $DIV0           ;If so, that's 1/0 - divide zero error
RET:    RET

ARGERR: JMP     $ERC_FC         ;Illegal function call

SMALLPOWER:
        CMP     AH,80H          ;Y < 1?
        JBE     ZEROPWR
        MOV     CL,80H+16
        SUB     CL,AH           ;Shift count to make Y integer
        MOV     BH,AL
        MOV     BL,CH           ;Mantissa of Y in BX
        OR      BH,80H          ;Set implied bit
        SHR     BX,CL           ;BX = Y as integer
        MOV     [POWERCNT],BX
        OR      AL,AL           ;Y < 0?
        JNS     ZEROPWR
        OR      [FLAG],2        ;Since power is negative, we'll need to invert
ZEROPWR:
        MOV     SI,OFFSET DC:$TEMP
        MOV     DI,OFFSET DC:$DAC
        CALL    $DSUB           ;FAC = Y - INT(Y)
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$TEMP
        MOVSW                   ;Move result back to TEMP
        MOVSW
        MOVSW
        MOVSW
LOGPOWER:
;TEMP has FRAC(Y), TEMP2 has X
        CMP     BYTE PTR [$TEMP+7],0  ;Is fraction part zero?
        JZ      MULPOWER
        MOV     BX,OFFSET DC:$TEMP2
        CALL    $LOD            ;Take log base e of X
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$TEMP
        CALL    $DMUL           ;FAC = Y * LN(X)
        MOV     BX,OFFSET DC:$DAC
        CALL    $DEXP           ;FAC = e^(Y*LN(X))
        OR      [FLAG],1        ;Multiplication by integer part will be needed
        JMP     SHORT MULCHK

MULPOWER:
        CALL    $PUT1D          ;Put a one in FAC as result of fraction part
MULCHK:
        MOV     CX,[POWERCNT]
        JCXZ    SETSIGN
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$TEMP
        MOVSW                   ;Copy result of fraction part to TEMP
        MOVSW
        MOVSW
        MOVSW
        CALL    XTON            ;Raise TEMP2 to CX power
        MOV     AL,[FLAG]
        TEST    AL,3            ;Need to multiply or divide?
        JZ      SETSIGN
        MOV     DI,OFFSET DC:$DAC
        MOV     SI,OFFSET DC:$TEMP
        TEST    AL,2            ;Need to divide?
        JNZ     POSTDIV
        CALL    $DMUL
        JMP     SHORT SETSIGN

POSTDIV:
        CALL    $DDIV
SETSIGN:
        MOV     AL,[FLAG]
        AND     AL,80H          ;Mask to sign bit
        OR      [$FAC-1],AL     ;Set sign of result
DONE:   RET

XTON:   ;Raise $TEMP2 to CX power by repeat multiplication
        CALL    $PUT1D          ;Put 1 in FAC
INTPWR:
        SHR     CX,1            ;Need to multiply by this power?
        JNC     SQUARE
        PUSH    CX
        MOV     SI,OFFSET DC:$TEMP2
        MOV     DI,OFFSET DC:$DAC
        CALL    $DMUL
        POP     CX
SQUARE:
        JCXZ    DONE
        PUSH    CX
        PUSH    [$DAC]
        PUSH    [$DAC+2]
        PUSH    [$DAC+4]
        PUSH    [$DAC+6]
        MOV     SI,OFFSET DC:$TEMP2
        MOV     DI,SI
        CALL    $DMUL           ;Square argument
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$TEMP2
        MOVSW
        MOVSW
        MOVSW
        MOVSW                   ;And move it back to TEMP2
        POP     [$DAC+6]
        POP     [$DAC+4]
        POP     [$DAC+2]
        POP     [$DAC]          ;Restore power being built in FAC
        POP     CX
        JMP     INTPWR

CODE    ENDS
        END
