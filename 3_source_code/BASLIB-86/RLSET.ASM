        TITLE   RLSET - RSET and LSET statements

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $LSEA,$RSEA

        EXTRN   $$DITS:NEAR

        ASSUME  CS:CODE

RLSET   PROC    FAR             ;Set up for long returns


;***  $RSEA and $LSEA - RSET and LSET statements
;
; Inputs:
;       DX = Address of Destination string descriptor
;       BX = Address of Source string descriptor
; Function:
;       Copy source to destination. If destination is larger than source,
;       pad with blanks. RSET has leading blanks, LSET trailing blanks.
; Outputs:
;       None.
; Registers:
;       Only F affected.

$RSEA:
        PUSH    CX
        PUSH    DX
        PUSH    BX
        PUSH    AX
        CALL    PREP            ;Set up registers (source in SI, dest in DI)
        PUSH    AX              ;Save count of characters to copy
        SHR     CX,1            ;Convert count of blanks to pad to word count
        MOV     AX,"  "         ;2 blanks at a time
        REP     STOSW
        JNC     SKPSTO          ;See if we need an odd number
        STOSB                   ;Put in that last blank
SKPSTO:
        POP     CX              ;Count of characters to copy
        SHR     CX,1            ;Now count of words
        REP     MOVSW
        JNC     POPSET          ;Moving an odd number?
        MOVSB                   ;Move that last byte
POPSET:
        MOV     DI,DX           ;Restore DI
        MOV     SI,BX           ;Restore SI
        POP     AX
        POP     BX
        POP     DX
        POP     CX
        CALL    $$DITS          ;Delete source if a temp
        RET

$LSEA:
        PUSH    CX
        PUSH    DX
        PUSH    BX
        PUSH    AX
        CALL    PREP
        XCHG    AX,CX           ;Get move count in CX
        SHR     CX,1            ;Convert byte count to word count
        REP     MOVSW
        JNC     SKPMOV          ;See if an odd count
        MOVSB                   ;Move that last byte
SKPMOV:
        MOV     CX,AX           ;Get count of blanks to fill
        SHR     CX,1            ;Make byte count a word count
        MOV     AX,"  "         ;2 blanks at a time
        REP     STOSW
        JNC     POPSET          ;See if an odd count
        STOSB                   ;Do that last byte
        JMP     POPSET


PREP    PROC    NEAR

; This routine sets up the registers for LSET and RSET.
; Inputs:
;       BX = Source string descriptor
;       DX = Dest. string descriptor
; Outputs:
;       AX = Number of byte to move from source to dest.
;       BX = Saved SI
;       CX = Number of blanks to pad (zero if source size > dest size)
;       DX = Saved DI
;       DI = Destination data address
;       SI = Source data address

        XCHG    SI,BX
        XCHG    DI,DX
        LODSW                   ;Get size of source string
        MOV     CX,[DI]         ;Get size of dest string
        MOV     SI,[SI]         ;Get source data address (LODSW added 2 to SI)
        MOV     DI,[DI+2]       ;Get destination data address
        SUB     CX,AX           ;Number of blanks to pad with (dest - source)
        JAE     RET             ;If not negative, we're done
        ADD     AX,CX           ;Set move count to size of dest string
        XOR     CX,CX           ;Set blank fill to zero
RET:    RET

PREP    ENDP
RLSET   ENDP
CODE    ENDS
        END
