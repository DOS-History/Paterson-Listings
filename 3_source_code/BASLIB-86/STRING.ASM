        TITLE   STRING - String assignment, concatenate, compare

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $$SPSV:WORD

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $SASA,$AD$A,$SCMA,$SAS

        EXTRN   $$ATS:NEAR, $$DITS:NEAR, $ERC_FC:NEAR
        EXTRN   $$CFT:NEAR, $$CTS:NEAR, $$FSS:NEAR, $$FTH:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


$SASA   PROC    FAR

;***  $SASA - String assignment
;
; Inputs:
;       BX = Address of Source string descriptor
;       DX = Address of Destination string descriptor
; Function:
;       1. Copy the source string into a temp, if it wasn't already.
;       2. Free any string data space of the destination
;       3. Copy the source descriptor to the destination descriptor
;       4. Reset the backpointer (unless it's a null string)
;       5. Free the (temporary) source descriptor
; Outputs:
;       None.
; Registers:
;       Only F affected

        MOV     [$$SPSV],SP
$SAS:   ;Entry point that doesn't save stack
        PUSH    BX
        CALL    $$CFT           ;See if source is a temp
        JC      HAVTEMP         ;Save some work if so
;Copy the source string into a temp
        PUSH    DX
        MOV     DX,[BX+2]       ;Get pointer to string data
        MOV     BX,[BX]         ;Get length
        CALL    $$CTS           ;Create temp string and copy in data
        POP     DX
HAVTEMP:
        XCHG    BX,DX           ;Need destination string in BX
        CALL    $$FSS           ;Free source string, if any
;Copy the descriptor
        PUSH    SI
        PUSH    DI
        MOV     DI,BX
        MOV     SI,DX
        MOVSW                   ;Move length
        MOVSW                   ;Move data pointer
        XCHG    BX,DX           ;Need source (temp) string in BX
        CMP     WORD PTR[BX],0  ;See if null string
        JZ      NOBACK          ;Don't fix backpointer if so
        MOV     DI,[BX+2]       ;Get pointer to data again
        MOV     [DI-2],DX       ;Set backpointer
        CALL    $$FTH           ;Free temp header
NOBACK:
        POP     DI
        POP     SI
        POP     BX
        RET

$SASA   ENDP


$AD$A   PROC    FAR

;***  $AD$A - Concatenate strings
;
; Inputs:
;       AX = Address of left string descriptor
;       BX = Address of right string descriptor
; Function:
;       Create a string containing the concatenation of the two given strings.
; Outputs:
;       BX = Address of result string descriptor
; Registers:
;       Only BX and F affected.

        MOV     [$$SPSV],SP
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI
        MOV     SI,AX           ;First string to move
        MOV     DI,BX           ;Save second string
        MOV     BX,[SI]         ;Get length of first string
        ADD     BX,[DI]         ;Sum is length of result string
        JO      ARGERR          ;Make sure no overflow
        CALL    $$ATS           ;Allocate temp string
        XCHG    DI,DX           ;Put data address in DI, save second string
        PUSH    BX              ;Save result string descriptor address
        CALL    MOVSTR          ;Move first string into temp
        MOV     SI,DX
        CALL    MOVSTR          ;Move second string in
        POP     BX              ;Restore result
        POP     DI
        POP     SI
        POP     DX
        POP     CX
        RET

MOVSTR:
        MOV     BX,SI           ;Need descriptor address here for DITS
        MOV     CX,[SI]         ;Length of string
        MOV     SI,[SI+2]       ;Address of data
        SHR     CX,1            ;Convert to word count
        REP     MOVSW
        JNC     DITS            ;Is it odd?
        MOVSB                   ;Move last byte if odd
DITS:
        JMP     $$DITS          ;Delete source string if temp

ARGERR: JMP     $ERC_FC

$AD$A   ENDP


$SCMA   PROC    FAR

;***  $SCMA - String comparison
;
; Inputs:
;       AX = Address of left operand string descriptor
;       BX = Address of right operand string descriptor
; Function:
;       Compare strings and set flags. For each byte of the strings, the flags
;       are set based on [left operand] - [right operand] until inequality is
;       found or one the strings end. If the end a string is reached, the
;       flags are set with [LEN(left operand)] - [LEN(right operand)].
; Outputs:
;       Result is flags, as noted above.
; Registers:
;       Only F affected.

        PUSH    CX
        PUSH    SI
        PUSH    DI
        MOV     DI,[BX+2]       ;Pointer to right side data
        MOV     CX,[BX]         ;Length of right string
        XCHG    AX,BX
        MOV     SI,[BX+2]       ;Pointer to left side data
        CMP     CX,[BX]         ;See which string is shorter
        JBE     HAVLEN
        MOV     CX,[BX]         ;Use whichever length is shortest
HAVLEN:
        CMP     AX,AX           ;Set zero flag in case CX=0
        REPE    CMPSB           ;String compare
        POP     DI
        POP     SI
        JNZ     NOTEQ           ;Strings equal so far?
        MOV     CX,[BX]         ;String data equal, so get lengths again
        XCHG    AX,BX
        CMP     CX,[BX]         ;Longer string is larger
        XCHG    AX,BX
NOTEQ:
        PUSHF                   ;Save comparison flags
        CALL    $$DITS          ;Free up temp strings
        XCHG    AX,BX
        CALL    $$DITS
        POPF                    ;Restore flags
        POP     CX
        RET

$SCMA   ENDP
CODE    ENDS
        END
