        TITLE   INPUT - INPUT statement

DATA    SEGMENT WORD PUBLIC 'DATA'

        PUBLIC  $FILBUF,$INBUF,$BUFLEN,$LINLEN

        EXTRN   VALTYP:BYTE,$$ERRV:WORD,$AC:WORD,$PTRFIL:WORD,$$SPSV:WORD

EOL     EQU     0

$FILBUF DW      ?
LONGRET LABEL   DWORD
RETOFF  LABEL   WORD
TYPLST  DW      ?               ;Share with return addr. offset
RETSEG  DW      ?
DATAPT  DW      ?
CLEAN   DW      ?
TYPCNT  DB      ?
VALCNT  DB      ?

$BUFLEN DB      ?
$LINLEN DB      ?
$INBUF  DB      256 DUP (?)

DATA    ENDS


CONST   SEGMENT BYTE PUBLIC 'CONST'

TYPTAB  DB      2,4,8,3

CONST   ENDS


DC      GROUP   DATA,CONST


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $IPUA,$IPUB,$INPOVF

        EXTRN   $TYPTX:NEAR,$FIN:NEAR,$GETCH:NEAR,$IN0A:NEAR,$REDO:FAR
        EXTRN   $CONT:NEAR,$$CTS:NEAR,$$TCR:NEAR,$SAS:FAR

        ASSUME  CS:CODE, DS:DC, ES:DC

INPUT   PROC    FAR             ;Set up long returns


;***  $IPUA - Get input line
;
; Inputs:
;       Return address on top of stack is long pointer to list of values to
;       input. First byte in list is number of values, following are types of
;       each value. Thus the calling sequence looks like this:
;
;               CALL    $IPUA
;               DB      <number of values, n>
;               DB      <type of first value>
;               DB      <type of second value>
;               . . .
;               DB      <type of nth value>
;               <return to here>
;
;       The type of values are:
;
;       4 = Integer
;       5 = Single precision
;       6 = Double precision
;       7 = String
;
; Function:
;       Prompt and read input line, and decode each value, checking to be
;       sure everything is OK and types match. If anything goes wrong, print
;       "?Redo from start" and start over. Values will be saved on stack, so
;       user code must not have anything saved on the stack when this is
;       called. Values will be read with $IPUB.
; Outputs:
;       None.
; Registers:
;       All except BP destroyed.

$IPUA:
        POP     DI
        POP     ES              ;ES:DI point to list of types
        MOV     AL,ES:[DI]      ;Get number of values to input
        INC     DI
        MOV     [RETSEG],ES
        MOV     [TYPLST],DI     ;If we have to restart, remember start of list
        MOV     [VALCNT],AL     ;Remember number of values
        MOV     [CLEAN],SP      ;Clean stack value
        MOV     [DATAPT],SP     ;Read values back from here
REDO:
        MOV     [TYPCNT],AL     ;Initialize count of values
        MOV     SI,OFFSET DC:$INBUF
EACHVAL:
        MOV     AL,ES:[DI]      ;Get next type
        INC     DI
        MOV     BX,OFFSET DC:TYPTAB-4  ;Convert type so FIN will understand
        XLAT
        CBW
        PUSH    AX              ;Put type on stack
        MOV     [VALTYP],AL
        PUSH    ES
        PUSH    DI
        MOV     [$$SPSV],SP     ;Save stack address here if error
        PUSH    DS
        POP     ES              ;ES = DS
        PUSH    BP
        MOV     DX,","*256+" "  ;Set up numeric delimiters
        CMP     AL,3            ;Is it string?
        JNZ     CALLBUF
        MOV     DL,DH           ;Make both delimiters ","
CALLBUF:
        CALL    [$FILBUF]       ;Get a buffer if disk I/O
        CALL    $FIN            ;Get number or string
        POP     BP
        POP     DI
        POP     ES
        CMP     [VALTYP],4      ;Set flags on type of value
        MOV     BX,OFFSET DC:$AC
        JB      PUSHAC          ;Don't do high word if integer or string
        PUSH    [BX+2]          ;Push highest word
PUSHAC:
        PUSH    [BX]
        JBE     NXTVAL          ;Only push low words if D.P.
        PUSH    [BX-2]
        PUSH    [BX-4]
NXTVAL:
        CMP     [$$ERRV],OFFSET $CONT   ;See if vector has been changed
        JZ      CNTDSK          ;If not, we're doing disk input
        CALL    $GETCH          ;Skip over blanks, etc.
        DEC     [TYPCNT]        ;Any values left?
        JZ      CHKEND
        CMP     AL,","          ;Values must be separated by ","
        JZ      EACHVAL
INPERR:
;Come here to restart if any error occured
        MOV     SP,[CLEAN]
        CALL    $TYPTX
        DB      "?Redo from star","t"+80H
        CALL    $$TCR           ;Output CR/LF
        CALL    $REDO           ;Get new input line
        MOV     AL,[VALCNT]     ;Re-initialize
        LES     DI,[LONGRET]
        JMP     REDO


CNTDSK:
        DEC     [TYPCNT]        ;Count the values
        JZ      donval          ;Can't make it all the way
        JMP     EACHVAL
donval:
        XOR     AL,AL           ;Flag that we reached the end
CHKEND:
        OR      AL,AL           ;Did we reach end of line?
        JNZ     INPERR
        MOV     [$$ERRV],OFFSET $CONT  ;Restore error vector
        PUSH    ES
        PUSH    DI              ;Put return address back on stack
        PUSH    DS
        POP     ES              ;Restore ES
RET:    RET

$INPOVF:
;Come here from error trap if overflow in FIN
        CALL    $TYPTX
        DB      "Overflo","w"+80H
        CALL    $$TCR           ;Output CR/LF
        JMP     INPERR


;***  $IPUB - Copy input values into variables
;
; Inputs:
;       BX = Address of variable
; Function:
;       Recover value input for that variable from the stack and copy it in.
;       When last variable has been assigned, recover stack space.
; Outputs:
;       None.
; Registers:
;       Only F affected.

$IPUB:
        PUSH    SI
        PUSH    DI
        PUSH    CX
        PUSH    DS
        MOV     SI,[DATAPT]     ;Get pointer to next value
        PUSH    SS
        POP     DS              ;Values stored in stack segment
        DEC     SI
        DEC     SI              ;Point to its type
        MOV     CX,[SI]         ;Type also equals length if numeric
        MOV     DI,CX
        AND     DI,NOT 1        ;Clear LSB so DI = length
        SUB     SI,DI           ;Point to its low end
        MOV     ES:[DATAPT],SI  ;For next call
        CMP     CL,3            ;Type STRING?
        JZ      ASSTRG          ;Go assign string
        MOV     DI,BX
        SHR     CX,1            ;Move by words
        REP     MOVSW           ;Assign variable
        POP     DS
ASSNXT:
        POP     CX
        POP     DI
        POP     SI
        DEC     [VALCNT]        ;Any more to go?
        JNZ     RET             ;If so, we'll wait for next call
;Clean up stack
        POP     [RETOFF]
        POP     [RETSEG]
        MOV     SP,[CLEAN]
        JMP     [LONGRET]

ASSTRG:
        MOV     SI,[SI]         ;Get pointer to string descriptor
        POP     DS
        XCHG    SI,DX
        XCHG    DX,BX           ;BX has source, DX has destination
        CALL    $SAS            ;Do string assign
        MOV     BX,DX
        MOV     DX,SI           ;Restore BX and DX
        JMP     ASSNXT

INPUT   ENDP
CODE    ENDS
        END
