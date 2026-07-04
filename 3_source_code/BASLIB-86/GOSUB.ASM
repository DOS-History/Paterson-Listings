        TITLE   GOSUB - GOSUB, RETURN, and computed GOSUB/GOTO

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $$STKP:WORD

$$GCNT  DW      ?

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $OGSA, $OGTA, $GOSA, $RELA, $RETA

        EXTRN   $ERR_FC:NEAR, $ERR_RG:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC

GOSUB   PROC    FAR             ;Set up long returns


;***  $GOSA - GOSUB with error checking
;
; Inputs:
;       Return address on top of stack points to address of target location
; Function:
;       Execute a near (relative user code) call to the target, saving
;       a clean stack pointer value (for after the call) and bumping the
;       nesting counter for "RETURN without GOSUB" detection.
; Outputs:
;       None.
; Registers:
;       Destroys all except BP.

$GOSA:
        POP     SI
        MOV     [$$STKP],SP     ;Save clean stack value
        POP     DS              ;DS:SI point to target
        LODSW
        PUSH    SI              ;Push return address
        PUSH    DS
        PUSH    AX              ;DS:AX is target, now on top of stack
        PUSH    ES
        POP     DS              ;Restore DS
        INC     [$$GCNT]        ;Bump nesting level
        RET                     ;Long return to target


;***  $RELA - RETURN line number address popper
;
; Inputs:
;       None.
; Function:
;       Pop one entry off the stack and update GOSUB level
; Outputs:
;       None.
; Registers:
;       Destroys all except BP.

$RELA:
        DEC     [$$GCNT]        ;Decrement count - error if < 0
        JS      ERR_RG          ;RETURN without GOSUB error?
        POP     BX              ;IP for our return
        POP     AX              ;CS of user code
        POP     CX              ;Toss this address
        JMP     short reta1


;***  $RETA - RETURN from GOSUB with error checking
;
; Inputs:
;       None.
; Function:
;       Execute near (relative user code) return, checking nesting level to
;       avoid RETURN without GOSUB, and saving post-return clean stack value.
; Outputs:
;       None.
; Registers:
;       Destroys all except BP.

$RETA:
        DEC     [$$GCNT]        ;Decrement count - error if < 0
        JS      ERR_RG          ;RETURN without GOSUB error?
        POP     AX              ;Dump IP for our return
        POP     AX              ;CS of user code
        POP     BX              ;This is the local return address

reta1:  MOV     [$$STKP],SP     ;Save clean stack level
        PUSH    AX              ;Push CS first
        PUSH    BX
        RET                     ;Long return to user code

ERR_RG: JMP     $ERR_RG


;***  $OGSA and $OGTA - ON-GOSUB and ON-GOTO
;
; Inputs:
;       BX = Index
;       Return address on top of stack points to table:
;               DB      <Number of entries>
;               DW      <Target if index = 1>
;               DW      <Target if index = 2>
;               . . .
;               DW      <Target if index = N>
; Function:
;       If index is negative or > 255, give argument error. If index is in
;       range 1..N, jump to corresponding location. If index is not in this
;       range, continue with next statement. If this is a GOSUB, then error
;       checking (as in $GOSA, above) will be performed, along with pushing
;       the return address.
; Ouputs:
;       None.
; Registers:
;       All except BP destroyed.

$OGTA:
        DB      0B8H            ;MOV AX,(XOR AH,AH) - Insures AH non-zero
$OGSA:
        XOR     AH,AH           ;Set flag for gosub
        OR      BH,BH
        JNZ     ARGERR          ;In range 0-255?
        POP     SI
        POP     DS              ;DS:SI points to table
        ASSUME  DS:NOTHING
        LODSB                   ;Get upper limit of index
        MOV     DL,AL
        MOV     DH,0
        SHL     DX,1
        ADD     DX,SI           ;Compute first address after table
        DEC     BX              ;Index should be 0 to N-1
        CMP     AL,BL
        JNA     ELSE1           ;If not in range, continue with next statement
        OR      AH,AH           ;Test flag
        JNZ     GETTARG         ;If GOTO, skip some work
        PUSH    DX              ;Push return address
        MOV     [$$STKP],SP     ;Save clean stack value
        INC     [$$GCNT]        ;Bump nesting level
GETTARG:
        SHL     BX,1
        MOV     DX,[BX+SI]      ;Get target address in user segment
ELSE1:
        PUSH    DS              ;Push user segment first
        PUSH    DX
        PUSH    ES
        POP     DS              ;Restore data segment
        ASSUME  DS:DC
        RET                     ;Long return to target code

ARGERR: JMP     $ERR_FC         ;Illegal Function Call if out of range

GOSUB   ENDP
CODE    ENDS
        END
