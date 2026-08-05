        TITLE   PRNVAL - Print values

DATA    SEGMENT WORD PUBLIC 'DATA'

        PUBLIC  $$WRFL,$$PUFL,$$PUEN

        EXTRN   $$SPSV:WORD,$FAC:BYTE,$AC:WORD
        EXTRN   TYP:WORD,VALTYP:BYTE,CURTYP:BYTE

$$WRFL  DB      ?
$$PUFL  DB      ?
$$PUEN  DW      ?

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $PV0A,$PV0B,$PV0C,$PV0D
        PUBLIC  $PV1A,$PV1B,$PV1C,$PV1D
        PUBLIC  $PV2A,$PV2B,$PV2C,$PV2D

        EXTRN   $$WCH:NEAR,$$WCLF:NEAR,$$DITS:NEAR,$FOUT:NEAR
        EXTRN   $TYPSTR:NEAR,$SAVREG:NEAR
        EXTRN   $$POS:NEAR,$$WID:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;***  PVnx - Print values
;
;   n = 0 - follow with "," processing
;       1 - follow with ";" processing
;       2 - follow with CR/LF
;
;   x = A - Single precision (pointer to value in BX)
;       B - Double precision (pointer to value in BX)
;       C - Integer (value in BX)
;       D - String (Address of descriptor in BX)

CLMWID  EQU     14
SNGL    EQU     4
DBL     EQU     8
INT     EQU     2
STRING  EQU     3
COMMA   EQU     0
SEMI    EQU     1
CRLF    EQU     2

$PV0A:
        CALL    PRINT
        DB      SNGL,COMMA

$PV0B:
        CALL    PRINT
        DB      DBL,COMMA

$PV0C:
        CALL    PRINT
        DB      INT,COMMA

$PV0D:
        CALL    PRINT
        DB      STRING,COMMA

$PV1A:
        CALL    PRINT
        DB      SNGL,SEMI

$PV1B:
        CALL    PRINT
        DB      DBL,SEMI

$PV1C:
        CALL    PRINT
        DB      INT,SEMI

$PV1D:
        CALL    PRINT
        DB      STRING,SEMI

$PV2A:
        CALL    PRINT
        DB      SNGL,CRLF

$PV2B:
        CALL    PRINT
        DB      DBL,CRLF

$PV2C:  
        CALL    PRINT
        DB      INT,CRLF

$PV2D:
        CALL    PRINT
        DB      STRING,CRLF

PRINT:
        POP     [TYP]           ;Get pointer to flags
        CALL    $SAVREG
        MOV     SI,[TYP]
        LODS    WORD PTR CS:[SI]
        MOV     [TYP],AX        ;Set VALTYP and CURTYP flags
        CMP     AL,STRING
        JZ      PSTRG           ;Handle strings separately
        CMP     AL,INT
        JZ      STOINT
        CBW
        MOV     SI,BX
        MOV     DI,OFFSET DC:$FAC+1
        SUB     DI,AX           ;Point to DAC or AC, as appropriate
        MOV     CX,AX
        SHR     CX,1            ;Move by words
        REP     MOVSW           ;Number to print in FAC
        JMP     SHORT TSTPRUS
STOINT:
        MOV     [$AC],BX        ;Number to print in FAC
TSTPRUS:
        CMP     [$$PUFL],0      ;Print using on?
        JNZ     PUEN            ;Yes--go do it
        CALL    $FOUT           ;Convert it to ASCII
        CMP     [$$WRFL],0      ;WRITE statement?
        JNZ     WRVAL           ;Yes--handle special
        INC     AX              ;Add 1 for the following space
        MOV     CL,0            ;Not special comma test
        CALL    PRTCHK          ;Make it fit on line (give CR/LF if necessary)
PRVAL:
        LODSB
        OR      AL,AL           ;End of string?
        JZ      WRTSPC
        CALL    $$WCH           ;Write character
        JMP     PRVAL
WRTSPC:
        MOV     AL," "
CHKEND:
        CMP     [CURTYP],SEMI   ;What do we finish with?
        JZ      WRTJMP
STREND:
        JB      CMA             ;Comma processing?
ENDLIN: JMP     $$WCLF

WRTJMP: JMP     $$WCH

PUEN:   CALL    [$$PUEN]
        CMP     [CURTYP],CRLF
        JZ      ENDLIN
        RET

PSTRG:
        CMP     [$$PUFL],0      ;Check for PRINT USING
        JNZ     PUEN
        CMP     [$$WRFL],0      ;WRITE?
        JNZ     WRTSTR
        MOV     AX,[BX]         ;Get length in AX
        MOV     CL,0            ;No special comma test
        CALL    PRTCHK          ;Try to make it fit on the line
        CALL    $TYPSTR         ;Output the string
        CALL    $$DITS          ;Delete it if temporary string
        CMP     [CURTYP],SEMI   ;What do we finish with?
        JNZ     STREND
        RET

WRTSTR:
        MOV     AL,'"'
        CALL    $$WCH
        CALL    $TYPSTR
        CALL    $$DITS
        MOV     AL,'"'
        CALL    $$WCH
        JMP     SHORT WRTTST

WRVAL:
        CMP     BYTE PTR[SI]," "  ;Is first letter a blank?
        JNZ     WRTVAL
        INC     SI
WRTVAL:
        LODSB
        OR      AL,AL
        JZ      WRTTST
        CALL    $$WCH
        JMP     WRTVAL
WRTTST:
        MOV     AL,","
        JMP     CHKEND

CMA:
        CALL    $$POS
        MOV     AL,AH
        MOV     AH,0
        MOV     CL,CLMWID
        DIV     CL              ;Remainder is position in this column
        SUB     CL,AH           ;Amount left in this column
        MOV     AL,CL
        CBW                     ;Amount to print is 16-bit number
        ADD     AX,CLMWID       ;Account for width of next column
        CALL    PRTCHK          ;Will another column fit?
        SUB     AX,CLMWID
        JBE     RET
        XCHG    AX,CX
TAB:
        MOV     AL," "
        CALL    $$WCH
        LOOP    TAB
        RET


PRTCHK:
;Check for enough space remaining on line to print AX characters. If not
;enough, start new line.

        PUSH    AX
        CALL    $$WID
        MOV     CH,AH
        CMP     CH,255
        POP     AX
        JZ      RET
        OR      AH,AH           ;More than 255 char to print?
        JNZ     FORCE
        PUSH    AX
        CALL    $$POS
        SUB     CH,AH           ;Amount left on line
        POP     AX
        JB      FORCE           ;If no room on line, need new line
        CMP     AL,CH           ;Will amount requested fit?
        JBE     RET
FORCE:
        CALL    $$WCLF          ;Force the CR/LF
        XOR     AX,AX
RET:    RET

CODE    ENDS
        END
