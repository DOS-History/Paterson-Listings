        TITLE   FLOAT - Floating point entry points

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $AC:WORD, $DAC:WORD, $FT:WORD, $$SPSV:WORD

SISAVE  DW      ?
DISAVE  DW      ?
POINTER DW      ?

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $FASA, $FASB, $FASC, $FASD
        PUBLIC  $STFA, $STFB, $LDFA, $LDFB
        PUBLIC  $SAVREG, $GTMP

        ASSUME  CS:CODE, DS:DC, ES:DC


; Floating point assignment

FLTASS  PROC    FAR             ;Set up long returns

; $FASA - Assign [SI] to [DI], single precision
; $FASB - Assign [SI] to [DI], double precision
; $FASC - Assign FAC to [DI], single precision
; $FASD - Assign FAC to [DI], double precision
; $STFA - Store FAC in temp, SP
; $STFB - Store FAC in temp, DP
; $LDFA - Load FAC from [SI], SP
; $LDFB - Load FAC from [SI], DP

$FASC:
        MOV     SI,OFFSET DC:$AC
$FASA:
        MOVSW
        MOVSW
        SUB     DI,4
        SUB     SI,4
        RET

$FASD:
        MOV     SI,OFFSET DC:$DAC
$FASB:
        MOVSW
        MOVSW
        MOVSW
        MOVSW
        SUB     DI,8
        SUB     SI,8
        RET

$LDFA:
        MOV     DI,OFFSET DC:$AC
        MOVSW 
        MOVSW 
        SUB     SI,4
        RET

$LDFB:
        MOV     DI,OFFSET DC:$DAC
        MOVSW
        MOVSW
        MOVSW
        MOVSW
        SUB     SI,8
        RET

$STFA:
        MOV     [SISAVE],SI
        MOV     [DISAVE],DI
        CALL    $GTMP
        MOV     SI,OFFSET DC:$AC
        MOVSW
        MOVSW
        MOV     SI,[SISAVE]
        MOV     DI,[DISAVE]
        RET

$STFB:
        MOV     [SISAVE],SI
        MOV     [DISAVE],DI
        CALL    $GTMP
        MOV     SI,OFFSET DC:$DAC
        MOVSW
        MOVSW
        MOVSW
        MOVSW
        MOV     SI,[SISAVE]
        MOV     DI,[DISAVE]
        RET

FLTASS  ENDP

$GTMP:

; Inputs:
;       Long return address one level deep on stack points to temp number.
; Function:
;       Get address of temp.
; Outputs:
;       SI = DI = Address of floating temp.
; Registers:
;       Only SI, DI and F affected.

        POP     [POINTER]
        POP     SI
        POP     DS
        XCHG    AX,DI
        LODSB                   ;Get temp number
        SHL     AL,1
        MOV     AH,0
        SHL     AX,1
        SHL     AX,1
        ADD     AX,OFFSET DC:$FT-8
        XCHG    AX,DI
        PUSH    DS
        PUSH    SI
        MOV     SI,DI
        PUSH    ES
        POP     DS
        JMP     [POINTER]


$SAVREG PROC    FAR

; This routine saves all registers on the stack. It returns with the top
; of the stack containing a return address to a routine that restores the
; registers and returns to user code. Flags set by the library are passed
; back to the user program (so compares work).

        POP     [POINTER]
        MOV     [$$SPSV],SP
        PUSH    BP
        PUSH    SI
        PUSH    DI
        PUSH    AX
        PUSH    CX
        PUSH    DX
        PUSH    BX
        CALL    [POINTER]
        POP     BX
        POP     DX
        POP     CX
        POP     AX
        POP     DI
        POP     SI
        POP     BP
        RET

$SAVREG ENDP
CODE    ENDS
        END
