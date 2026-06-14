        TITLE   CONV - Conversions between single, double, and integer

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FAC:WORD, $AC:WORD, $DAC:WORD, $$SPSV:WORD

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT WORD PUBLIC 'CODE'

        PUBLIC  $CDPA,$CDPB,$CISA,$CIDA,$CSPA,$CSPB
	PUBLIC  $CINA,$CINB,$CINC,$CIND,$CINFAC
        PUBLIC  $C8IA,$C8IB,$C8IC,$C8ID
        PUBLIC  $ADCA,$ADCB,$ADC,$V8IA

        EXTRN   $SNORM:NEAR, $SRND:NEAR, $OVFL:NEAR, $ERR_FC:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC

CONV    PROC    FAR

$CDPA:
;Convert SP at [SI] to DP in FAC
        PUSH    DI
        MOV     DI,OFFSET DC:$AC
        MOVSW                   ;Copy to FAC
        MOVSW
        POP     DI
        SUB     SI,4
$CDPB:
;Convert SP in FAC to DP
        MOV     [$DAC],0
        MOV     [$DAC+2],0
        RET

$CISA:
;Convert integer in BX to SP
$CIDA:
;Convert integer in BX to DP
        PUSH    BX
        PUSH    DX
        PUSH    AX
        MOV     AX,9000H        ;Set exponent to 16
        OR      AL,BH           ;Get sign
        JNS     POS             ;Already positive
        NEG     BX              ;Need magnitude
POS:
        XOR     DX,DX
        CALL    $SNORM
        POP     AX
        POP     DX
        POP     BX
        JMP     $CDPB           ;Convert to DP just in case

$CSPA:
;Convert DP at [SI] to SP in FAC
        PUSH    DI
        MOV     DI,OFFSET $DAC
        MOVSW
        MOVSW
        MOVSW
        MOVSW
        POP     DI
        SUB     SI,8
$CSPB:
;Convert DP in FAC to SP
        PUSH    BX
        PUSH    DX
        PUSH    AX
        MOV     BX,[$FAC-2]
        OR      BH,80H          ;Set implied bit
        MOV     DX,[$FAC-4]
        MOV     AX,[$DAC]
        OR      AL,AH           ;OR together all insignificant bits
        OR      AL,[$DAC+2]
        JZ      NOSTICK
        OR      DL,1            ;Set sticky bit if any were one
NOSTICK:
        MOV     AX,[$FAC-1]     ;Get sign and exponent
        CALL    $SRND
        POP     AX
        POP     DX
        POP     BX
        RET


;***  CINT - Round real to integer
;
; Inputs:
;       Single or double precision number in FAC or at [SI]
; Function:
;       Convert by rounding to integer
; Outputs:
;       BX = FAC = rounded integer
; Registers:
;       Only BX and F affected.

$C8IA:
$CINA:  ;Single precision, operand at [SI]
        MOV     [$$SPSV],SP
        PUSH    AX
        PUSH    CX
        MOV     AX,[SI+2]       ;Get exponent
        MOV     CX,[SI]         ;Get mantissa
        JMP     SHORT CINT

$C8IB:
$CINB:  ;Double precision, operand at [SI]
        MOV     [$$SPSV],SP
        PUSH    AX
        PUSH    CX
        MOV     AX,[SI+6]       ;Get exponent
        MOV     CX,[SI+4]       ;Get mantissa
        JMP     SHORT CINT

$C8IC:
$C8ID:
$CINC:  ;Single precision, operand in FAC
$CIND:  ;Double precision uses same routine
        MOV     [$$SPSV],SP
$CINFAC:
        PUSH    AX
        PUSH    CX
        MOV     AX,[$AC+2]      ;Get exponent
        MOV     CX,[$AC]        ;Get mantissa
CINT:
        XOR     BX,BX           ;Set up zero result
        SUB     AH,80H          ;Take bias out of exponent
        JB      CXRET           ;Return zero if no integer part
        MOV     BH,AL           ;Highest byte of mantissa
        MOV     BL,CH
        XCHG    AX,CX
        MOV     CL,16
        SUB     CL,CH           ;Number of bits to shift mantissa right
        MOV     AH,BH           ;Save sign
        JB      OVERFLOW        ;If negative shift, it won't fit in 16 bits
        JZ      OVCHK           ;Only -32768 has 16 bits - go check for it
        OR      BH,80H          ;Set implied bit
        SHR     BX,CL           ;Position the integer
        ADC     BX,0            ;Perform rounding
        OR      AH,AH           ;Check sign now
        JNS     NOTNEG
        NEG     BX
NOTNEG:
        NOT     AH              ;Bit 7 set if positive
        AND     AH,BH           ;Bit 7 set if number positive, >=32768
        JS      OVERFLOW
CXRET:
        POP     CX
        POP     AX
        MOV     [$AC],BX        ;Result in both FAC and BX
        RET

OVCHK:
;Come here if no shift is needed on the number, i.e., it requires a full
;16 bits. Only -32768 (8000H) is allowed.
        CMP     BX,8000H        ;The 1 is sign bit (negative), not implied bit
        JNZ     OVERFLOW
        TEST    AL,80H          ;Should we be rounding up?
        JZ      CXRET           ;If so, that causes overflow
OVERFLOW:
        JMP     $OVFL


;***  $ADCA, $ADCB - Convert SP to address
;
; Inputs:
;       SI = Address of SP number ($ADCA only)
;       FAC = SP number ($ADCB only)
; Function:
;       Convert to 16-bit integer in range -32768 to +65535, with rounding.
; Outputs:
;       Result in BX.
; Registers:
;       Only BX and F affected.

$ADCA:
        MOV     [$$SPSV],SP
$ADC:
        PUSH    AX
        PUSH    CX
        MOV     AX,[SI+2]       ;Get exponent
        MOV     CX,[SI]         ;Get mantissa
        JMP     SHORT ADDR

$ADCB:
        MOV     [$$SPSV],SP
        PUSH    AX
        PUSH    CX
        MOV     AX,[$AC+2]      ;Get exponent
        MOV     CX,[$AC]        ;Get mantissa
ADDR:
        CMP     AH,90H          ;In range 32768-65535?
        JNZ     CINT            ;If not, CINT can do it
        OR      AL,AL           ;Is it negative?
        JS      CINT            ;If so, same as CINT
;Have a positive number range 32768-65536.
        OR      AL,80H          ;Set implied bit
        MOV     BH,AL
        MOV     BL,CH           ;Integer now in BX
        SHL     CL,1            ;Need to round up?
        ADC     BX,0
        JNC     CXRET
        JMP     $OVFL

$V8IA:
        OR      BH,BH
        JNZ     FARG
        RET
FARG:   JMP     $ERR_FC

CONV    ENDP
CODE    ENDS
        END
