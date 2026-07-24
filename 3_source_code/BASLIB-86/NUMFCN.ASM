        TITLE   NUMFCN - Arithmetic functions

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FAC:BYTE, $AC:WORD, $DAC:WORD

SISAVE  DW      ?

DATA    ENDS


CONST   SEGMENT WORD PUBLIC 'CONST'

FIXTAB  DB      0,80H,0C0H,0E0H,0F0H,0F8H,0FCH,0FEH

CONST   ENDS

DC      GROUP   CONST,DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $FUMA,$FUMB,$FUMC,$FUMD,$SGNA,$SGNB,$SGNC,$SGND
        PUBLIC  $FC0A,$FC0B,$FC0C,$FC0D,$CNZA,$CNZB,$CNZC,$CNZD
        PUBLIC  $FIX, $FID, $INT, $IND, $ABSA,$ABSB,$ABSC,$ABSD
        PUBLIC  $FSHA,$FSHB,$FSHC,$FSHD

        EXTRN   $OVFL:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC

NUMFCN  PROC    FAR             ;Set up long returns


;***  $FUM - Floating unary minus
;
; Inputs:
;       SI = Address of argument ($FUMA/$FUMB)
;       $FAC has argument ($FUMC/$FUMD)
; Function:
;       Invert sign
; Outputs:
;       Result in FAC.
; Registers:
;       Only F affected.

$FUMA:  ;Single precision
        CALL    PUTAC
$FUMC:
        XOR     [$FAC-1],80H
        RET

$FUMB:  ;Double precision
        CALL    PUTDAC
$FUMD:
        XOR     [$FAC-1],80H
        RET


;***  $SIGN - SGN function
;
; Inputs:
;       SI = Address of argument ($SGNA/$SGNB)
;       FAC has argument ($SGNC/$SGND)
; Function:
;       Return 1 if argument positive
;       Return 0 if argument zero
;       Return -1 if argument negative
; Outputs:
;       FAC has result, same type as argument
; Registers:
;       Only F affected.

$SGNA:  ;Single precision
        PUSH    AX
        MOV     AX,[SI+2]       ;Get sign and exponent
        JMP     SHORT SGN

$SGNC:
$SGND:
        PUSH    AX
        MOV     AX,[$AC+2]
SGN:
        OR      AH,AH           ;Check exponent for zero
        JZ      SAVSGN
        MOV     AH,81H          ;Set exponent for +1 or -1
        AND     AL,80H          ;Reduce to sign bit
SAVSGN:
        MOV     [$AC+2],AX
        XOR     AX,AX
        MOV     [$DAC],AX
        MOV     [$DAC+2],AX
        MOV     [$AC],AX
        POP     AX
        RET

$SGNB:  ;Double precision
        PUSH    AX
        MOV     AX,[SI+6]       ;Get sign and exponent
        JMP     SGN


;***  $FC0 - Floating compare for zero
;
; Inputs:
;       SI = Address of argument ($FC0A/$FC0B)
;       $FAC has argument ($FC0C/$FC0D)
; Function:
;       Compare the floating point number against zero, setting ZF and CF.
; Outputs:
;       Positive: ZF=0, CF=0, Zero: ZF=1, CF=0; Negative: ZF=0, CF=1.
; Registers:
;       Only F affected.

$FC0A:  ;Single precision
        PUSH    AX
        MOV     AX,[SI+2]
FC0:
        OR      AH,AH           ;Exponent zero?
        JZ      PRET
        RCL     AL,1            ;Rotate sign into carry
PRET:
        POP     AX
        RET

$FC0B:  ;Double precision
        PUSH    AX
        MOV     AX,[SI+6]
        JMP     FC0

$FC0C:
$FC0D:
        PUSH    AX
        MOV     AX,[$AC+2]
        JMP     FC0


;***  $CNZ - Compare for non-zero
;
; Inputs:
;       SI = Address of argument ($CNZA/$CNZB)
;       $FAC has argument ($CNZC/$CNZD)
; Function:
;       Return integer 0 if argument 0, integer -1 otherwise
; Outputs:
;       Result in BX
; Registers:
;       Only BX affected.

$CNZA:  ;Single precision
        XOR     BX,BX
        CMP     BYTE PTR[SI+3],0
        JZ      RET
        DEC     BX
        RET

$CNZB:  ;Double precision
        XOR     BX,BX
        CMP     BYTE PTR[SI+7],0
        JZ      RET
        DEC     BX
        RET

$CNZC:
$CNZD:
        XOR     BX,BX
        CMP     [$FAC],0
        JZ      RET
        DEC     BX
RET:    RET


;***  $ABS - Absolute value function
;
; Inputs:
;       SI = Address of argument  ($ABSA/$ABSC)
;       FAC = argument  ($ABSB/$ABSD)
; Outputs:
;       Absolute value in FAC
; Registers:
;       Only F affected.

$ABSA:  ;Single precision
        CALL    PUTAC
$ABSC:  AND     [$FAC-1],7FH    ;Force sign positive
        RET

$ABSB:  ;Double precision
        CALL    PUTDAC
$ABSD:  AND     [$FAC-1],7FH
        RET


;***  $FSH - Floating shift
;
; Inputs:
;       SI = Address of argument ($FSHA/$FSHB)
;       $FAC has argument ($FSHC/$FSHD)
;       Long return address on top of stack pointer to a byte.
; Function:
;       Add byte to exponent of floating point number.
; Outputs:
;       Result in FAC.
; Registers:
;       Only F affected.

$FSHA:  ;Single precision
        CALL    PUTAC
$FSHC:
$FSHD:
        MOV     [SISAVE],SI
        POP     SI
        POP     DS              ;Get pointer to power
        PUSH    AX
        LODSB
        ADD     [$FAC],AL       ;Add byte to exponent
        POP     AX
        PUSH    DS
        PUSH    SI
        PUSH    ES
        POP     DS              ;Restore DS
        MOV     SI,[SISAVE]
        JNC     RET
        JMP     $OVFL

$FSHB:
        CALL    PUTDAC
        JMP     $FSHD


;*** $FIX - Get integer part of argument, chopped toward zero
;
; Inputs:
;       BX = Address of argument
; Function:
;       Compute integer part, chopped toward zero (-12.5 -> -12).
;       $FIX is for single precision, $FID is for double precision.
; Outputs:
;       Result in $FAC, same type as argument (SP or DP)
; Registers:
;       Only F affected.

$FIX:   ;Single precision
        XCHG    SI,BX
        CALL    PUTAC
        XCHG    SI,BX
        PUSH    CX
        MOV     CX,2
DOFIX:
        CALL    FIX
        POP     CX
        RET

$FID:   ;Double precision
        XCHG    SI,BX
        CALL    PUTDAC
        XCHG    SI,BX
        PUSH    CX
        MOV     CX,6
        CALL    FIX
RETC:
        POP     CX
        RET


;*** $INT - Floor function
;
; Inputs:
;       BX = Address of argument
; Function:
;       Compute largest integer <= argument. Thus -12.5 -> -13.
;       $INT is for single precision, $IND is for double precision.
; Outputs:
;       Result in $FAC, same type as argument (SP or DP).
; Registers:
;       Only F affected.

$INT:
        XCHG    SI,BX
        CALL    PUTAC
        XCHG    SI,BX
        PUSH    CX
        MOV     CX,2
INT:
        CMP     [$FAC], 0       ;Is FAC zero?
        JZ      RETC            ;If so, done already
        TEST    [$FAC-1],80H    ;Check sign bit
        JZ      DOFIX           ;If positive, just do FIX
        PUSH    CX
        CALL    NEGATE          ;Use two's complement
        POP     CX
        PUSH    CX
        CALL    FIX
        POP     CX
        CMP     [$FAC],0        ;Was magnitude less than 1?
        JZ      MINUSONE
        CALL    NEGATE          ;Fix it back
        POP     CX
        JNZ     RET1            ;Did we overflow?
        MOV     [$FAC-1],80H    ;Yes - set sign bit
        INC     [$FAC]          ;Bump exponent
        JNZ     RET1
        JMP     $OVFL

MINUSONE:
        XOR     CX,CX
        MOV     [$DAC],CX       ;Force -1 as result
        MOV     [$DAC+2],CX
        MOV     [$AC],CX
        MOV     [$AC+2],8180H
        POP     CX
RET1:   RET


$IND:
        XCHG    SI,BX
        CALL    PUTDAC
        XCHG    SI,BX
        PUSH    CX
        MOV     CX,6
        JMP     INT

NUMFCN  ENDP

FIX:
        PUSH    AX
        PUSH    BX
        PUSH    DI
        MOV     AL,[$FAC]       ;Get exponent
        SUB     AL,80H
        JBE     ZERO
        MOV     DI,OFFSET DC:$FAC-1   ;Point to high mantissa byte
        MOV     BL,AL
        SHR     AL,1
        SHR     AL,1
        SHR     AL,1
        CBW                     ;Number of mantissa bytes in integer
        SUB     DI,AX
        SUB     CX,AX           ;Advance over full bytes
        JB      POPRET
        XCHG    BX,AX
        AND     AL,7            ;Bits in last byte
        MOV     BX,OFFSET DC:FIXTAB
        XLAT
        AND     [DI],AL         ;Reset fraction bits
        XOR     AL,AL
        DEC     DI
        STD                     ;Set direction DOWN
        REP     STOSB           ;Zero trailing bytes
        CLD                     ;Restore direction
POPRET:
        POP     DI
        POP     BX
        POP     AX
        RET

ZERO:
        MOV     [$FAC],0
        JMP     POPRET

NEGATE:
        PUSH    SI
        MOV     SI,OFFSET DC:$FAC-2
        SHR     CX,1            ;Do it by words
        PUSH    CX
NOTLP:
        NOT     WORD PTR [SI]
        DEC     SI
        DEC     SI
        LOOP    NOTLP
        POP     CX
        NEG     BYTE PTR [SI+1]
        JNZ     NO_INC
INCLP:
        INC     SI
        INC     SI
        INC     WORD PTR [SI]
        LOOPZ   INCLP
NO_INC:
        POP     SI
        RET

PUTAC:
        PUSH    DI
        MOV     DI,OFFSET DC:$AC
        MOVSW
        MOVSW
        POP     DI
        SUB     SI,4
        RET

PUTDAC:
        PUSH    DI
        MOV     DI,OFFSET DC:$DAC
        MOVSW
        MOVSW
        MOVSW
        MOVSW
        POP     DI
        SUB     SI,8
        RET

CODE    ENDS
        END
