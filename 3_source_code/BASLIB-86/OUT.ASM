        TITLE   OUT - Output utilities

.list

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $PTRFIL:WORD,$$WRFL:BYTE

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $$WCLF,$$THB,$TYTX,$TYPTX,$$TCR,$$WCHT
        PUBLIC  $TYPSTR,$TYPCNT,$OUTCNT

        EXTRN   $$WCH:NEAR
        EXTRN   $TTYOT:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC

CR      EQU     13
LF      EQU     10

CRLF_LEN=       2                       ;Length of CR/LF sequence on disk


;**     $$WCLF - Write new line
;
;       USES    F

$$WCLF: PUSH    AX                      ;Save (AX)
        PUSH    BX
        PUSH    SI

        MOV     SI,[$PTRFIL]
        OR      SI,SI                   ;Check for standard output
        JE      wcspec                  ;  Yes - do special CR/LF
        TEST    [SI].FD_DEVICE,80h      ;Test for special device
        JNZ     wcspec                  ;  Yes - do special CR/LF
        CMP     [SI].FD_MODE,MD_RND     ;Check for random
        JNE     wcdisk                  ;  No - do disk CR/LF
        CMP     [$$WRFL],0              ;Test for WRITE statement
        JE      wcdisk                  ;  No - just do disk CR/LF

        MOV     BX,[SI].FR_VRECL        ;Get field length
        SUB     BX,[SI].FR_OUTPOS       ;  Subtract off bytes already written
        SUB     BX,CRLF_LEN             ;    and two more for CR/LF
        MOV     AL,' '                  ;Write (BX) spaces

;       This is tricky because DISK_SOUT will give FOV error if
;       (BX) is negative.

wspc:   JZ      wcdisk                  ;(BX) = 0 - done
        CALL    $$WCH                   ;Write space
        DEC     BX                      ;Decrement (BX)
        JMP     wspc                    ;Keep on looping until (BX) = 0

if      _IBM_
wcdisk: MOV     AL,CR
        CALL    $$WCH                   ;Output CR
        MOV     AL,LF
        CALL    $$WCH                   ;Output LF
        JMP     SHORT wclxt

wcspec: MOV     AL,CR                   ;Output CR only
        CALL    $$WCH
else
wcdisk:
wcspec: MOV     AL,CR                   ;Output CR/LF
        CALL    $$WCH
        MOV     AL,LF
        CALL    $$WCH
endif

wclxt:  POP     SI
        POP     BX
        POP     AX
        RET


;***  $$TCR - Type CR/LF on console
;
; Uses F

$$TCR:
        PUSH    AX
        PUSH    [$PTRFIL]
        MOV     [$PTRFIL],0
        CALL    $$WCLF
        POP     [$PTRFIL]
        POP     AX
        RET


$$WCHT:
        PUSH    [$PTRFIL]       ;Save current output pointer
        MOV     [$PTRFIL],0     ;Set pointer to console output
        CALL    $$WCH
        POP     [$PTRFIL]       ;Restore pointer
RET:    RET



;***  $$THB - Type hex byte
;
; Inputs:
;       AL = Byte to output in hex
; Outputs:
;       None.
; Registers:
;       Only AL and F affected.

$$THB:
        PUSH    AX
        SHR     AL,1
        SHR     AL,1
        SHR     AL,1
        SHR     AL,1
        CALL    DIGIT
        POP     AX
DIGIT:
        AND     AL,0FH
        AND     AL,90H
        DAA
        ADC     AL,40H
        DAA
        JMP     $$WCHT


;***  $TYTX - Type text
;
; Inputs:
;       SI has pointer to text string in code segment
; Function:
;       Print string with bit 7 set in last character
; Outputs:
;       SI points past end of text.
; Registers:
;       SI, AX and F affected.

$TYTX:
        LODS    BYTE PTR CS:[SI]
        PUSH    AX
        AND     AL,7FH
        CALL    $$WCHT
        POP     AX
        TEST    AL,80H
        JZ      $TYTX
        RET



;***  $TYPTX - Print string pointed to by top of stack
;
; Inputs:
;       Top of stack has address in code segment of text string terminated
;       with bit 7 set.
; Function:
;       Print the string.
; Outputs:
;       None. Returns to first location after the string.
; Registers:
;       Only AX and F affected.

$TYPTX:
        POP     AX
        PUSH    SI
        MOV     SI,AX
        CALL    $TYTX
        MOV     AX,SI
        POP     SI
        JMP     AX



;***  $TYPSTR - Type string given descriptor
;
; Inputs:
;       BX = Address of string descriptor
; Outputs:
;       None.
; Registers:
;       CX,SI,AX,F destroyed.

$TYPSTR:
        MOV     CX,[BX]
$TYPCNT:
        JCXZ    RET
        MOV     SI,[BX+2]
$OUTCNT:
        LODSB
        CALL    $$WCH
        LOOP    $OUTCNT
        RET

CODE    ENDS
        END
