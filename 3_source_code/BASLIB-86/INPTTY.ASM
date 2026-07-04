        TITLE   INPTTY - Prepare for input from TTY

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $PTRFIL:WORD,$$ERRV:WORD,$INBUF:BYTE,$BUFLEN:BYTE,$LINELEN:BYTE
        EXTRN   $FILBUF:WORD

PROMPT  DW      ?
INFL    DB      ?

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $IN0A,$REDO

        EXTRN   $TYPSTR:NEAR,$$WCH:NEAR,$$WCLF:NEAR,$INPOVF:NEAR
        EXTRN   $RDLIN:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


INPUT   PROC    FAR

;***  $IN0A - Prepare for console input
;
; Inputs:
;       BX = Address of prompt string descriptor.
;       Return address on top of stack has long pointer to parameter byte.
;       If bit 1 is set in this byte, don't print "?" after prompt.
;       If bit 0 is set, don't echo CR/LF after getting input.
; Function:
;       Set up input from TTY and read input line.
; Outputs:
;       None.
; Registers:
;       All except BP destroyed.

$IN0A:
        POP     SI
        POP     DS              ;Point to parameter byte
        LODSB
        PUSH    DS
        PUSH    SI              ;Put return address back on stack
        PUSH    ES
        POP     DS              ;Restore DS
        MOV     [INFL],AL       ;Save parameter byte
        MOV     [PROMPT],BX     ;Save prompt string descriptor address
        MOV     [$PTRFIL],0     ;Set output to terminal
        MOV     [$$ERRV],OFFSET $INPOVF ;Trap all errors
        MOV     [$FILBUF],OFFSET RET  ;Don't get input from disk
$REDO:
;Enter here if error to re-prompt and re-read data
        MOV     BX,[PROMPT]
        CALL    $TYPSTR         ;Print string
        TEST    [INFL],2        ;Need a "?" after prompt?
        JNZ     GETLIN
        MOV     AL,"?"
        CALL    $$WCH
        MOV     AL," "
        CALL    $$WCH
GETLIN:
        CALL    $RDLIN          ;Get input line
        TEST    [INFL],1        ;Is it INPUT "semi-colon" ?
        JNZ     GETLIX          ;Yes, don't send <CR><LF>
        CALL    $$WCLF
GETLIX:
        RET

INPUT   ENDP


RET:    RET                     ;NEAR RET

CODE    ENDS
        END
