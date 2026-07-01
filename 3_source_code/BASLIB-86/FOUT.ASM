        TITLE   FOUT - Free-format numeric output

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   VALTYP:BYTE, SIGN:BYTE, $AC:WORD, $DAC:WORD, $$SPSV:WORD

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $FOUT, $FOUTBX, $STI, $STR, $STD

        EXTRN   CONASC:NEAR, ASCRND:NEAR, $$CTS:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


STRF    PROC    FAR

;***  $STI, $STR, $STD - STR$ function
;
; Inputs:
;       BX = Integer ($STI only)
;       BX = Address of number ($STR and $STD)
; Function:
;       Create a string representing the number in ASCII
; Outputs:
;       BX = Address of string descriptor
; Registers:
;       Only BX and F affected.

$STI:
        MOV     [VALTYP],2
        JMP     SHORT STR$

$STR:
        MOV     [VALTYP],4
        JMP     SHORT STR$

$STD:
        MOV     [VALTYP],8
STR$:
        MOV     [$$SPSV],SP
        PUSH    [$DAC]          ;Save DAC
        PUSH    [$DAC+2]
        PUSH    [$DAC+4]
        PUSH    [$DAC+6]
        PUSH    AX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI
        PUSH    BP
        CALL    $FOUTBX
        XCHG    AX,BX           ;Get length in BX
        MOV     DX,SI           ;Get address in DX
        CALL    $$CTS           ;Create temp string
        POP     BP
        POP     DI
        POP     SI
        POP     DX
        POP     CX
        POP     AX
        POP     [$DAC+6]
        POP     [$DAC+4]
        POP     [$DAC+2]
        POP     [$DAC]
        RET

STRF    ENDP


;***  $FOUT & $FOUTBX - Free-format numeric output
;
; Inputs:
;       Number in FAC to be formatted for output ($FOUT only)
;       BX = Number to be formatted ($FOUTBX only)
;       [VALTYP] = 2 for integer, 4 for SP, 8 for DP
; Function:
;       Format number for printing, using BASIC's formatting rules.
; Outputs:
;       SI = Address of ASCII string, terminated by 00
;       AX = Length of string (not including terminating 00)
; Registers:
;       All destroyed.

$FOUTBX:
        MOV     AL,[VALTYP]
        CMP     AL,2
        JZ      STOINT
        CBW                     ;Number of bytes to move
        MOV     SI,BX
        MOV     DI,OFFSET DC:$AC+4
        SUB     DI,AX           ;AC or DAC
        XCHG    AX,CX
        SHR     CX,1            ;Count of words
        REP     MOVSW
        JMP     SHORT $FOUT
STOINT:
        MOV     [$AC],BX
$FOUT:
        CALL    CONASC          ;Most of the work's done here

;Number has been converted to ASCII and is sitting at buffer pointed to by DI.
;       SI = address of result buffer
;       CX = number of significant figures
;       DL has the base 10 exponent of the right end of the digit string.

        MOV     BX,-700H+7      ;If SP, use 7 digits, but limit 7 to right
        CMP     [VALTYP],4      ;What type?
        JBE     RNDDIG          ;If integer or SP, use SP parameters
        MOV     BX,-1000H+16    ;For DP, use 16 digits, and limit 16 to right
RNDDIG:
        MOV     AL,BL
        CALL    ASCRND          ;Round to AL digits
        CMP     DL,BH           ;Too many digits to right of decimal point?
        JL      SCINOT          ;If so, use scientific notation
        MOV     AL,DL
        ADD     AL,CL           ;AL=number of digits to left of dec.pt.
        CMP     AL,BL           ;Too many?
        JG      SCINOT          ;If so, use scientific notation
        CBW
        XCHG    AX,CX           ;CX has digits needed to left of dec. pt.
        XCHG    AX,BX           ;BX has digits available from buffer
        OR      CX,CX           ;Any to left?
        JLE     LESS1           ;If not, start with decimal point
LEFTDP:
        MOVSB                   ;Move digits to final buffer
        DEC     BX              ;Limit to available digits
        LOOPNZ  LEFTDP
        MOV     AL,"0"
        REP     STOSB           ;Fill in with place-holding zeros if needed
        JZ      PUTEND          ;If out of digits, were done(flags from DEC BX)
PUTDP:
        MOV     AL,"."
        STOSB                   ;Put in decimal point
        MOV     AL,"0"          ;Used only if we came from LESS1
        REP     STOSB           ;Add leading zeros if a small number
        MOV     CX,BX           ;Number of digits left
        REP     MOVSB
PUTEND:
        MOV     SI,OFFSET DC:SIGN  ;Leave pointer to buffer
        MOV     AX,DI
        SUB     AX,SI           ;Length of string
        MOV     BYTE PTR[DI],0  ;Put in terminating zero
        RET

LESS1:
;Come here if number is less than one and therefore has no digits to
;left of the decimal point.
        NEG     CX              ;Number of place-holding zeros needed
        JMP     PUTDP           ;   after the decimal point

SCINOT:
        MOVSB                   ;Move first digit to final buffer
        DEC     CX              ;Account for digit already moved
        JZ      EXP             ;Skip decimal point if only one digit
        MOV     AL,"."
        STOSB
        ADD     DL,CL           ;Correct exponent for decimal point position
        REP     MOVSB           ;All other digits go after decimal point
EXP:
        MOV     AX,"+E"         ;Prepare "E+" if positive exponent
        OR      DL,DL           ;Check exponent sign
        JNS     POSEXP
        NEG     DL              ;Force exponent positive
        MOV     AH,"-"
POSEXP:
        STOSW
        XCHG    AX,DX           ;Get exponent in AL
        AAM                     ;Convert binary to unpacked BCD
        XCHG    AL,AH
        OR      AX,"00"         ;Add ASCII bias
        STOSW
        JMP     PUTEND

CODE    ENDS

        END
