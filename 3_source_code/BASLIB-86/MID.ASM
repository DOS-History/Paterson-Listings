        TITLE   MID - Left-hand MID$

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $MD$A

        EXTRN   $$DITS:NEAR, $ERR_FC:NEAR

        ASSUME  CS:CODE

$MD$A   PROC    FAR             ;Set up for long returns


;***  $MD$A - MID$ statement
;
; Inputs:
;       DX = Address of Destination string descriptor
;       BX = Address of Source string descriptor
;       CX = Starting offset in Destination
;       AX = Max. length of copy
; Function:
;       Copy the source string into the destination string. Copying limited to
;       present length of destination.
; Outputs:
;       None.
; Registers:
;       Only F affected.

        XCHG    DX,BX
        OR      CX,CX           ;Test for valid offset
        JLE     ARGERR          ;Must be greater than zero
        OR      AX,AX           ;Test for valid length
        JL      ARGERR          ;Must be zero or more
        CMP     CX,[BX]         ;Compare offset to current length of string
        JA      ARGERR          ;Offset must not exceed string size
        PUSH    SI
        PUSH    DI
        PUSH    CX
        MOV     DI,[BX+2]       ;Pointer to destination data
        DEC     CX              ;Need offset starting at 0, not 1
        ADD     DI,CX           ;Add in offset
        SUB     CX,[BX]
        NEG     CX              ;Length - Offset
        CMP     CX,AX           ;Take minimum of this and count parameter
        JB      MIN1
        MOV     CX,AX           ;Count parameter was lower
MIN1:
        MOV     SI,DX           ;Get source where we can address with it
        CMP     CX,[SI]         ;Compare current move length to string length
        JBE     MIN2
        MOV     CX,[SI]         ;Source string was smaller
MIN2:
        MOV     SI,[SI+2]       ;Get pointer to source data
        SHR     CX,1            ;Convert byte count to word count
        REP     MOVSW
        JNC     EVENMOV         ;Was count odd?
        MOVSB                   ;Move that last byte
EVENMOV:
        POP     CX
        POP     DI
        POP     SI
        XCHG    BX,DX           ;Need source addr. in BX
        CALL    $$DITS          ;Delete source if temp string
        RET

ARGERR:
        JMP     $ERR_FC         ;Illegal function call

$MD$A   ENDP
CODE    ENDS
        END
