        TITLE   INVOL - Involution operator

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $AC:WORD, $ARG:WORD, $FAC:BYTE, $TEMP:WORD

POWERCNT DW     ?
FLAG    DB      ?

DATA    ENDS


DC      GROUP   DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $FEXA, $FEXC, $FEXE, $FEXG

        EXTRN   $SAVREG:NEAR, $SMUL:NEAR, $GTMP:NEAR, $LOG2:NEAR, $EXP2:NEAR
        EXTRN   $SDIV:NEAR, $SSUB:NEAR, $FIX:FAR, $DIV0:NEAR, $ERC_FC:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC

; Suffix A means address of operands in SI and DI
; Suffix C means first operand is FAC, second is at [DI] (SI smashed)
; Suffix E means first operand is at [SI], second is FAC (DI smashed)
; Suffix G means first operand is floating temp, second is FAC (SI and DI hit)

$FEXC:
        MOV     SI,OFFSET DC:$AC
        JMP     SHORT $FEXA
$FEXG:
        CALL    $GTMP
$FEXE:
        MOV     DI,OFFSET DC:$AC
$FEXA:
        CALL    $SAVREG
        XOR     AX,AX
        MOV     [FLAG],AL       ;Set sign positive, no mul or div needed yet
        MOV     [POWERCNT],AX
        MOV     AX,[DI+2]       ;Get sign and exponent of Y
        OR      AH,AH           ;Is Y zero?
        JZ      ONE
        MOV     DX,[SI+2]
        OR      DH,DH           ;Is X zero?
        JZ      ZERCHK
        PUSH    [SI]            ;Save the rest of X
        MOV     CX,[DI]         ;Get the rest of Y
        MOV     [$TEMP],CX      ;Save Y in TEMP
        MOV     [$TEMP+2],AX
        MOV     BX,DI
        CALL    $FIX
        CMP     AH,80H+16       ;ABS(Y) >= 2^16?
        JBE     SMALLPOWER
        OR      DL,DL           ;X < 0?
        JNS     LOGPOWER
        CMP     AH,80H+24       ;ABS(Y) >= 2^24?
        JA      ARGERR          ;If so, can't tell if odd - error!
        CMP     CL,[$FAC-3]     ;Does INT(Y) = Y? (Other 24 bits must be =)
        JNZ     ARGERR
        SUB     AH,80H+17       ;Get shift count range 0-7
        XCHG    CL,AH
        SHL     AH,CL           ;LSB of Y in bit 7, to tell us even or odd
        MOV     [FLAG],AH       ;Use it as sign of result
        AND     DL,7FH          ;Make X positive
        JMP     SHORT LOGPOWER

ONE:
        MOV     [$AC],0
        MOV     [$AC+2],8100H   ;Jam floating one into FAC
RET:    RET

ZERCHK:
        MOV     [$FAC],0        ;Put a zero in FAC
        OR      AL,AL           ;Is power negative?
        JNS     RET
        JMP     $DIV0           ;If so, that's 1/0 - divide zero error

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
        PUSH    DX              ;Save high half of X
        MOV     SI,OFFSET DC:$TEMP
        MOV     DI,OFFSET DC:$AC
        CALL    $SSUB           ;FAC = Y - INT(Y)
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$TEMP
        MOVSW                   ;Move result back to TEMP
        MOVSW
        POP     DX
LOGPOWER:
        POP     AX              ;X now in DX:AX
        CMP     BYTE PTR [$TEMP+3],0  ;Is fraction part zero?
        JZ      MULPOWER
        PUSH    AX
        PUSH    DX              ;Save X on stack
        MOV     [$AC],AX
        MOV     [$AC+2],DX      ;And put in FAC for polynomial evaluation
        CALL    $LOG2           ;Take log base 2
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$TEMP
        CALL    $SMUL           ;FAC = Y * LOG2(X)
        CALL    $EXP2           ;FAC = 2^(Y*LOG2(X))
        POP     DX
        POP     AX              ;Restore X to DX:AX
        OR      [FLAG],1        ;Multiplication by integer part will be needed
        JMP     SHORT MULCHK

MULPOWER:
        CALL    ONE             ;Put a one in FAC as result of fraction part
MULCHK:
        MOV     CX,[POWERCNT]
        JCXZ    SETSIGN
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$TEMP
        MOVSW                   ;Copy result of fraction part to TEMP
        MOVSW
        MOV     [$ARG],AX
        MOV     [$ARG+2],DX     ;Put X in ARG
        CALL    XTON            ;Raise ARG to CX power
        MOV     AL,[FLAG]
        TEST    AL,3            ;Need to multiply or divide?
        JZ      SETSIGN
        MOV     DI,OFFSET DC:$AC
        MOV     SI,OFFSET DC:$TEMP
        TEST    AL,2            ;Need to divide?
        JNZ     POSTDIV
        CALL    $SMUL
        JMP     SHORT SETSIGN

POSTDIV:
        CALL    $SDIV
SETSIGN:
        MOV     AL,[FLAG]
        AND     AL,80H          ;Mask to sign bit
        OR      [$FAC-1],AL     ;Set sign of result
DONE:   RET

XTON:   ;Raise $ARG to CX power by repeat multiplication
        CALL    ONE             ;Put 1 in FAC
INTPWR:
        SHR     CX,1            ;Need to multiply by this power?
        JNC     SQUARE
        PUSH    CX
        MOV     SI,OFFSET DC:$ARG
        MOV     DI,OFFSET DC:$AC
        CALL    $SMUL
        POP     CX
SQUARE:
        JCXZ    DONE
        PUSH    CX
        PUSH    [$AC]
        PUSH    [$AC+2]
        MOV     SI,OFFSET DC:$ARG
        MOV     DI,SI
        CALL    $SMUL           ;Square argument
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$ARG
        MOVSW
        MOVSW                   ;And move it back to ARG
        POP     [$AC+2]
        POP     [$AC]           ;Restore power being built in FAC
        POP     CX
        JMP     INTPWR

CODE    ENDS
        END
