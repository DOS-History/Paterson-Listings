        TITLE   READ - Read and Restore statements

        INCLUDE ADDR.INC

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   VALTYP:BYTE, $AC:WORD, $$RSTO:BYTE, $MAINBASE:WORD

DATAP   DW      ?

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $REAA,$REAB,$REAC,$READ,$RSTA,$RSTB

        EXTRN   $GETAD:NEAR, $FIN:NEAR, $GETCH:NEAR, $SAS:FAR
        EXTRN   $SAVREG:NEAR, $ERC_OD:NEAR, $ERC_SN:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;***  $RSTA & $RSTB - Restore statement
;
; Inputs:
;       $RSTA - None
;       $RSTB - BX = Address of statement to restore to
; Function:
;       Reset data pointers for RESTORE statement.
;       $RSTA is simple restore to beginning of data.
;       $RSTB restores to specified line number
; Outputs:
;       None.
; Registers:
;       Only F affected.

$RSTA   PROC    FAR
        PUSH    SI
        PUSH    AX
        CALL    $GETAD
        DB      STARTDATA
        MOV     [DATAP],AX
        MOV     [$$RSTO],1      ;Have done a restore
        POP     AX
        POP     SI
        RET

$RSTB:
        CALL    $RSTA           ;Find first data statement
        PUSH    AX
        PUSH    CX
        PUSH    BX
        SUB     BX,[$MAINBASE]  ;Subtract off program base offset
        PUSH    DI
        XOR     AX,AX
        MOV     DI,[DATAP]      ;Get pointer to first data
        DEC     DI
        DEC     DI              ;Point to first line number address
LOOKDATA:
        XCHG    AX,BX
        SCASW                   ;Compare requested address with this address
        XCHG    AX,BX
        JBE     RESTDONE        ;If this line is as big, use it
        MOV     CX,-1           ;Allow maximum search range
        REPNE   SCASB           ;Scan for zero, marking end of this statement
        JMP     LOOKDATA
RESTDONE:
        MOV     [DATAP],DI
        POP     DI
        POP     BX
        POP     CX
        POP     AX
        RET

$RSTA   ENDP


;***  $REAA,$REAB,$REAC,$READ - Read statements for SP, DP, integer, string
;
; Inputs:
;       BX = Destination address of read value
; Function:
;       If first read ever, perform Restore. Read next data item if present,
;       and advance data pointer. If item not present, report Out of Data
;       error.
; Outputs:
;       None.
; Registers:
;       Only F affected.

$REAA:  ;Single precision read
        MOV     [VALTYP],4
        JMP     SHORT READ

$REAB:  ;Double precision
        MOV     [VALTYP],8
        JMP     SHORT READ

$REAC:  ;Integer
        MOV     [VALTYP],2
        JMP     SHORT READ

$READ:  ;String
        MOV     [VALTYP],3

READ:
        CALL    $SAVREG         ;Save all registers on stack
        PUSH    BX              ;Save destination address
        CMP     [$$RSTO],0      ;Have we ever restored?
        JNZ     RDDAT
        CALL    $RSTA
RDDAT:
        MOV     SI,[DATAP]      ;Get pointer to next data item
        CALL    $GETCH          ;Skip over blanks
        CMP     AL,1            ;End of data list?
        JZ      DATOUT
        DEC     SI              ;Re-read first character
        CALL    $FIN            ;Get data item
        CALL    $GETCH          ;See if next char is comma or end of line
        CMP     AL,","          ;More values on this line?
        JZ      ASSIGN
        OR      AL,AL           ;Better be EOL (zero) if no more values
        JNZ     SYNERR
        INC     SI              ;Skip over line number
        INC     SI
ASSIGN:
        MOV     [DATAP],SI      ;Save pointer
        POP     DI              ;Get destination address
        MOV     AL,[VALTYP]
        CMP     AL,3            ;String assign?
        JZ      ASSTRG
        MOV     SI,OFFSET DC:$AC
        CBW
        XCHG    AX,CX
        SHR     CX,1
        CMP     CL,4            ;Double precision?
        JNZ     MOVE
        SUB     SI,4
MOVE:
        REP     MOVSW
        RET

ASSTRG:
        MOV     DX,DI           ;Destination in DX
        MOV     BX,[$AC]        ;Source in BX
        CALL    $SAS            ;Do string assignment
        RET

DATOUT: JMP     $ERC_OD         ;Out of Data
SYNERR: JMP     $ERC_SN         ;Syntax error in DATA

CODE    ENDS
        END
