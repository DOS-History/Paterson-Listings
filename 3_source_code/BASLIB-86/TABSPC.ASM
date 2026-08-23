        TITLE   TABSPC - TAB and SPC functions

DATA    SEGMENT WORD PUBLIC 'DATA'
DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $TABA,$TABB,$SPCA,$SPCB

        EXTRN   $$WCH:NEAR, $$WCLF:NEAR, $$POS:NEAR, $$WID:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC

TABSPC  PROC    FAR

;***  $$SPCA, $SPCB - SPC function
;
; Inputs:
;       BX = number of spaces
; Function:
;       Convert negative numbers to zero, then modulo it with line width.
;       Then print that many spaces.
; Outputs:
;       None.
; Registers:
;       Only F affected.

$SPCA:
$SPCB:
        PUSH    AX
        MOV     AX,BX
        CALL    RNGCHK
OUTSPC:
        PUSH    AX
        MOV     CH,0
        JCXZ    NOSPC
SPCLP:
        MOV     AL," "
        CALL    $$WCH
        LOOP    SPCLP
NOSPC:
        POP     CX
        POP     AX
        RET

;***  $TABA, $TABB - TAB function of PRINT statement
;
; Inputs:
;       BX = position to tab to (1 is first)
; Function:
;       Convert arg<1 to 1, then modulo with line length.  Tab to position,
;       send CR/LF if already beyond position.
; Outputs:
;       None.
; Registers:
;       Only F affected.

$TABA:
$TABB:
        PUSH    AX
        MOV     AX,BX
        DEC     AX
        CALL    RNGCHK
        CMP     CL,CH           ;Check against current position
        JAE     FIGSPC
        CALL    $$WCLF          ;Output CR/LF if too far
        MOV     CH,0
FIGSPC:
        SUB     CL,CH           ;Number of spaces needed
        JMP     OUTSPC

TABSPC  ENDP


RNGCHK:
        OR      AX,AX
        JNS     NOTNEG          ;Make negative numbers zero
        XOR     AX,AX
NOTNEG:
        PUSH    DX
        PUSH    BX
        XCHG    AX,BX
        CALL    $$WID
        XCHG    AL,AH
        MOV     AH,0
        XCHG    AX,BX          ;(BX) = width
        XOR     DX,DX
        DIV     BX
        MOV     AL,DL          ;Remainder is the answer
        CALL    $$POS          ;(AH) = position
        XCHG    AX,CX          ;(AX) = now has original (CX)
        POP     BX
        POP     DX
        RET

CODE    ENDS
        END
