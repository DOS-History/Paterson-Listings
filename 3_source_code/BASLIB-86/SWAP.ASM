        TITLE   SWAP - Swap values

SKIP1=  0B0H            ;MOV    AL,immediate (to skip next one-byte instruc.)

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $$SFWA:WORD, $$SLWA:WORD

DATA    ENDS


DC      GROUP   DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $SWPA,$SWPB,$SWPC,$SWPD

        ASSUME  CS:CODE, DS:DC, ES:DC


SWAP    PROC    FAR

;***  $SWPx - Swap values
;
; Inputs:
;       SI = Address of one operand
;       DI = Address of other operand
; Function:
;       Interchange values. Note that strings must have backpointers reset.
; Outputs:
;       None.
; Registers:
;       Only F affected.

$SWPB:  ;Double precision
        PUSH    BX
        MOV     BX,[SI+4]
        XCHG    BX,[DI+4]
        MOV     [SI+4],BX
        MOV     BX,[SI+6]
        XCHG    BX,[DI+6]
        MOV     [SI+6],BX
        DB      SKIP1           ;Skip PUSH in $SWPA
$SWPA:  ;Single precision
        PUSH    BX
SDSWP:
        MOV     BX,[SI+2]
        XCHG    BX,[DI+2]
        MOV     [SI+2],BX
        DB      SKIP1           ;Skip PUSH in $SWPC
$SWPC:  ;Integer
        PUSH    BX
        MOV     BX,[SI]
        XCHG    BX,[DI]
        MOV     [SI],BX
        POP     BX
        RET

$SWPD:  ;Strings
        PUSH    BX
        MOV     BX,[SI]
;Check to see if it's in string space
        CMP     BX,[$$SFWA]
        JB      NOFIX
        CMP     BX,[$$SLWA]
        JAE     NOFIX
        MOV     BX,[SI+2]       ;Address of string data
        MOV     [BX-2],DI       ;Change a backpointer
NOFIX:
        MOV     BX,[DI]
;Check to see if it's in string space
        CMP     BX,[$$SFWA]
        JB      SDSWP
        CMP     BX,[$$SLWA]
        JAE     SDSWP
        MOV     BX,[DI+2]
        MOV     [BX-2],SI
        JMP     SDSWP           ;Now swap string descriptors

SWAP    ENDP
CODE    ENDS
        END
