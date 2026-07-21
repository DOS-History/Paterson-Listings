        TITLE   LININP - LINE INPUT statement

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FILBUF:WORD,$INBUF:BYTE,$$ERRV:WORD

DATA    ENDS


DC      GROUP   DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $LIPA

        EXTRN   $SAVREG:NEAR, $$CSL:NEAR, $$CTS:NEAR, $SAS:FAR, $CONT:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;***  $LIPA - Assign LINE INPUT value
;
; Inputs:
;       BX = Address of string variable to receive data
; Function:
;       Assign the input line to the string variable. Either $IN0A or $IN0B
;       is called first to set up either terminal or disk I/O. If terminal
;       I/O, then the line is already read into $INBUF and $FILBUF contains
;       the address of a RET instruction. If disk I/O, line will be read
;       from disk by routine at $FILBUF.
; Outputs:
;       None.
; Registers:
;       Only F affected.

$LIPA:
        CALL    $SAVREG
        MOV     [$$ERRV],OFFSET $CONT  ;Reset error vector to normal
        PUSH    BX              ;Remember destination
        XOR     DX,DX           ;Init for FILBUF, if disk I/O
        CALL    [$FILBUF]       ;Read in line if disk I/O
        MOV     BX,OFFSET DC:$INBUF
        CALL    $$CSL           ;Count length of line
        MOV     DX,BX
        XCHG    AX,BX           ;Need length in BX, address in DX
        CALL    $$CTS           ;Create temp string
        POP     DX              ;Recall destination address
        CALL    $SAS            ;Assign
        RET

CODE    ENDS
        END
