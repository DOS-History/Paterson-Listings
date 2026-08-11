        TITLE   RANDOM - Random number generator and RANDOMIZE

DATA    SEGMENT WORD PUBLIC 'DATA'
DATA    ENDS

CONST   SEGMENT WORD PUBLIC 'CONST'

RNDA    DW      43FDH,3         ;   214,013
RNDC    DW      9EC3H,26        ; 2,531,011
RNDX    DW      5,0
PROMPT  DB      "Random Number Seed (-32768 to 32767)"
EVEN
RANDMES DW      $-PROMPT        ;String descriptor for prompt
        DW      DC:PROMPT

CONST   ENDS


DC      GROUP   DATA,CONST


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $RAN,$RA0,$RZ0,$RZ1

        EXTRN   $SNORM:NEAR, $SAVREG:NEAR
        EXTRN   $IN0A:FAR, $IPUA:FAR, $IPUB:FAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;***  $RAN, $RA0 - RND function
;
; Inputs:
;       BX = Address of argument ($RAN only)
; Function:
;       If argument is positive (or always for $RA0, which has no argument),
;       return next random number in sequence. If argument is negative, start
;       a new pseudo-random sequence. If argument is zero, retun previous
;       value.
; Outputs:
;       Pseudo-random number range [0,1) in FAC.
; Registers:
;       No registers affected.

$RA0:
        CALL    $SAVREG
        JMP     SHORT NEWRAND

$RAN:
        CALL    $SAVREG
        CMP     BYTE PTR[BX+3],0  ;Is number zero?
        JZ      SAMNUM          ;Return same result as last time
        TEST    BYTE PTR[BX+2],80H  ;Is number negative?
        JS      NEWSEED         ;If so, start new sequence
NEWRAND:
        MOV     AX,[RNDX]       ;Low half of previous number
        MOV     CX,[RNDA]       ;Low half of A
        MUL     CX
        XCHG    AX,DI           ;Save low half in DI
        MOV     BX,DX           ;  high half in BX
        MOV     AX,[RNDX+2]     ;High half of previous
        MUL     CX
        ADD     BX,AX           ;Sum partial products
        MOV     AX,[RNDA+2]
        MUL     [RNDX]
        ADD     BX,AX           ;Last partial product (since we're mod 2^24)
        ADD     DI,[RNDC]       ;Add in constant C
        ADC     BL,[RNDC+2]
        XOR     BH,BH           ;Extended 24-bit number to 32 bits for NORM
        MOV     DX,DI           ;Number in BX:DX
        MOV     [RNDX],DX       ;Save for next time
        MOV     [RNDX+2],BX
MAKNUM:
        MOV     AX,8800H        ;Positive sign, exponent of +8
        JMP     $SNORM          ;Normalize to the FAC

SAMNUM:
        MOV     DX,[RNDX]       ;Get previous random number
        MOV     BX,[RNDX+2]
        JMP     MAKNUM

NEWSEED:
        MOV     DX,[BX]
        MOV     AX,[BX+2]
        ADD     DL,AH           ;Fold exponent into least significant byte
        ADC     DH,0
        ADC     AL,0
        XOR     AH,AH           ;New seed in AX:DX
        MOV     [RNDX],DX
        MOV     [RNDX+2],AX
        JMP     NEWRAND


;***  $RZ0 & $RZ1 - RANDOMIZE statements
;
; Inputs:
;       BX = new seed value ($RZ1 only)
; Function:
;       Reseed the pseudo-random number generator. $RZ0 prompts for a value
;       in range -32768 to 32767 as the seed; $RZ1 is passed the value in BX
;       instead. The number is set into the middle word of the current random
;       number as the seed for the next one.
; Outputs:
;       None.
; Registers:
;       Only F affected.

$RZ0:
        CALL    $SAVREG
        MOV     BX,OFFSET DC:RANDMES
        CALL    $IN0A           ;Fake an INPUT statement
        DB      0               ;Add "?" and CR/LF
        CALL    $IPUA
        DB      1               ;One value
        DB      4               ;Type integer
        MOV     BX,OFFSET DC:RNDX+1
        CALL    $IPUB           ;Assign value to middle word of RNDX
        RET

$RZ1    PROC    FAR
        MOV     [RNDX+1],BX
        RET
$RZ1    ENDP

CODE    ENDS
        END
