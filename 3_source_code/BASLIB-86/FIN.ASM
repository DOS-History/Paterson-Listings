        TITLE   FIN - String and numeric input

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   VALTYP:BYTE, CURTYP:BYTE, TYP:WORD, $AC:WORD, $FAC:BYTE
        EXTRN   PWR10TAB:WORD, $DAC:WORD

FIX10   EQU     128             ;Correction to out-of-range exponents
HIGH10  EQU     38              ;Largest power of 10 with correct exponent
MAX10   EQU     38              ;Largest power of 10 that won't overflow
MIN10   EQU     -55             ;Smallest power of 10 that won't underflow

PWRINC  DW      ?
HAVDP   DB      ?

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $FIN,$GETCH,$VAL

        EXTRN   $CISA:FAR, $CSPB:FAR, $CINFAC:FAR, $OVFL:NEAR, $$CTS:NEAR
        EXTRN   $SNORM:NEAR, $DNORM:NEAR, $SMUL:NEAR, $DMUL:NEAR
        EXTRN   $SAVREG:NEAR, $$PUTZ:NEAR, $$DITS:NEAR
        EXTRN   $SDIV:NEAR, $DDIV:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;***  $VAL - VAL function
;
; Inputs:
;       BX = Address of string descriptor
; Function:
;       Compute numeric equivalent of the string
; Outputs:
;       Double precision result in DAC
; Registers:
;       Only F affected.

$VAL:
        CALL    $SAVREG
        CALL    $$PUTZ
        MOV     [VALTYP],8      ;Force to double precision
        MOV     SI,[BX+2]       ;Get address of string data
        PUSH    BX              ;Save string descriptor address
        CALL    $FIN
        POP     BX
        JMP     $$DITS          ;Delete if temp string


GETSTR:
;Come here to get string from input line (continuation of $FIN, below)
        CALL    $GETCH
        MOV     AH,AL           ;In case first char is "
        CMP     AL,'"'          ;Is it?
        JZ      COUNTSTR
        MOV     AH,","          ;Terminate with comma if not quoted
        DEC     SI              ;Scan first char again
COUNTSTR:
        MOV     DX,SI           ;Save starting address of string data
        XOR     CX,CX           ;Character count
RDSTR:
        LODSB
        CMP     AL,AH           ;End of string?
        JZ      NEGCNT
        OR      AL,AL           ;End of line?
        LOOPNZ  RDSTR           ;Count char and loop if not EOL
        INC     CX              ;Don't count the EOL character
NEGCNT:
        NEG     CX              ;Make character count positive
        CMP     AH,','          ;Unquoted string?
        JNZ     MAKSTR
;Not a quoted string. Trim off trailing blanks.
        DEC     SI              ;Point back at termination character
        MOV     DI,SI
        DEC     DI              ;Point to last char of string
        MOV     AL," "
        CMP     AL,AL           ;Set zero flag in case CX=0
        STD                     ;Set direction DOWN
        REPE    SCASB           ;Scan of blanks backward
        CLD                     ;Restore direction
        JZ      MAKSTR          ;If null string, leave zero in CX
        INC     CX              ;Last char scanned not blank - count it
MAKSTR:
        MOV     BX,CX
        CALL    $$CTS           ;Create temp string
        MOV     [$AC],BX        ;Put address in AC for safekeeping
        RET

HEXOCT:
        MOV     [CURTYP],2      ;Set type to integer
        XOR     BX,BX           ;Initialize input to zero
        CALL    $GETCH          ;"&" followed by "O" or "H"?
        MOV     CX,15*100H+4    ;Prepare for hex input
        CMP     AL,"H"          ;Is it "&H"?
        JZ      OCTHEX
        MOV     CX,7*100H+3     ;Prepare for octal input
        CMP     AL,"O"          ;Is it "&O"?
        JNZ     OCTHEX1
OCTHEX:
        CALL    $GETCH          ;Eat the "H" or "O"
OCTHEX1:
        SUB     AL,"0"          ;Remove ASCII bias
        JB      LVHEX           ;If not a hex digit, quit
        CMP     AL,9
        JBE     OK
        SUB     AL,7            ;If "A" to "F", make 10-15
        CMP     AL,10
        JB      LVHEX
OK:
        CMP     AL,CH           ;CH has max value (7 for oct, 15 for hex)
        JA      LVHEX
        TEST    BH,0E0H         ;Highest 3 bits must be zero
        JNZ     OVERFLOW
        SHL     BX,CL           ;Make room for new digit
        JC      OVERFLOW
        OR      BL,AL           ;Combine new digit
        JMP     OCTHEX
LVHEX:
        DEC     SI              ;Back up to non-digit
        XOR     CX,CX           ;No power of 10
        JMP     SHORT SAVTYP


;***  $FIN - Floating point and string input
;
; Inputs:
;       [VALTYP] = Type of value required
;       SI = Address of character stream to analyze for the value
; Outputs:
;       AC has integer value ([VALTYP] = 2)
;       BX = Address of string descriptor ([VALTYP] = 3)
;       AC has S.P. value ([VALTYP] = 4)
;       DAC has D.P. value ([VALTYP] = 8)
; Registers:
;       Uses all.

$FIN:
        CMP     [VALTYP],3      ;Getting a string?
        JZ      GETSTR
        CALL    SIGN
        PUSHF                   ;Save sign in flags
        CALL    $GETCH
        CMP     AL,"&"          ;Hex or octal input?
        JZ      HEXOCT
        DEC     SI              ;Back up
        CALL    ASCNUM          ;Get ASCII digits, convert to integer
SAVTYP:
        MOV     AX,[TYP]        ;Get current type and requested type
        CMP     AH,4            ;Test current type
        JA      SAVEDP          ;Is it already double precision?
        CMP     AL,AH           ;Need to convert S.P. to D.P.?
        JBE     SAVSP
;Convert S.P. to D.P.
        MOV     [CURTYP],8      ;Record change in precision
        XOR     DI,DI
SAVEDP:
        POPF                    ;Get sign flag (zero=negative)
        PUSH    CX              ;Currently in DI:BP:BX:DX
        MOV     CX,BX           ;Get in DI:BX:CX:DX form
        MOV     BX,BP
        MOV     AX,192*100H     ;Set sign and exponent for positive integer
        JNZ     DPNORM          ;Is it positive or negative?
        MOV     AL,80H          ;Negative!
DPNORM:
        PUSH    SI
        CALL    $DNORM          ;Normalize and store in FAC
        POP     SI
        POP     CX
        JMP     SHORT HAVNUM    ;Go check for exponent

OVERFLOW:JMP    $OVFL

SAVSP:
        POPF
        MOV     AX,160*100H     ;Sign and exponent for positive integer
        JNZ     SPNORM          ;Positive?
        MOV     AL,80H          ;Force negative sign
SPNORM:
        CALL    $SNORM          ;Normalize and store in FAC

HAVNUM:

;Number is stored as integer in FAC with proper sign, CURTYP has its type,
;which is at least the precision requested by VALTYP. CX has current base 10
;exponent. Now we scan for type character ("%", "!", "#") or exponent field.

        CALL    $GETCH          ;Get last char again
;Ignore the special type symbols
        CMP     AL,"%"          ;Integer?
        JZ      MULEXP
        CMP     AL,"#"          ;Double?
        JZ      MULEXP
        CMP     AL,"!"          ;Single?
        JZ      MULEXP
;Check for exponent
        CMP     AL,"D"          ;Get D.P. exponent?
        JZ      GETEXP
        CMP     AL,"E"          ;S.P. exponent?
        JZ      GETEXP
        DEC     SI              ;If not recognized, ignore
        JMP     SHORT MULEXP

GETEXP:
        CALL    SIGN            ;Get sign, if any
        PUSHF                   ;Save it
        XOR     BX,BX
        MOV     [HAVDP],1       ;Don't allow a decimal point
        MOV     [PWRINC],BX     ;Don't change CX
        CALL    GETINT          ;Get integer in BX
        POPF                    ;Recover sign
        JNZ     NONEG           ;Positive?
        NEG     BX
NONEG:
        ADD     CX,BX

MULEXP:

;FAC has number as integer, CX has its power of 10. Use lookup table to find
;the double precision power of 10, and multiply or divide. Then coerce to lower
;precision, if necessary.

        JCXZ    COERCE          ;No multiplication needed?
        CMP     CX,MAX10
        JG      OVERFLOW        ;Power of 10 too big?
        CMP     CX,MIN10
        JL      ZERO            ;Too small?
        PUSH    SI              ;Save pointer to text
        MOV     DI,CX
        OR      DI,DI           ;Is exponent negative?
        JNS     HAVMAG
        NEG     DI              ;Get magnitude of exponent
HAVMAG:
        CMP     DI,HIGH10       ;Is power too large to be correct?
        JLE     NOFIX
        SUB     [$FAC],FIX10    ;Adjust our exponent to account for it
NOFIX:
        SHL     DI,1
        SHL     DI,1
        SHL     DI,1            ;Multiply by 8 for index into table
        CMP     [CURTYP],8      ;Presently double precision?
        JZ      DBLEXP          ;If so, do double precision multiply/divide
        ADD     DI,OFFSET DC:PWR10TAB+4 ;Point to S.P. version of constant
        MOV     SI,OFFSET DC:$AC
        CMP     WORD PTR[DI-2],8000H  ;See if we need to round it
        JB      SNGLEXP
        SUB     SI,4            ;Copy number to low half of $DAC
        XCHG    SI,DI           ;Set up to move
        MOVSW
        MOVSW
        MOV     SI,DI           ;OFFSET $AC
        MOV     DI,OFFSET DC:$DAC
        INC     WORD PTR[DI]    ;Round up
SNGLEXP:
        OR      CX,CX           ;Is exponent positive or negative?
        JNS     SNGPOS
        CALL    $SDIV           ;Divide by power of 10 if exponent negative
        JMP     SHORT MULDON
SNGPOS:
        CALL    $SMUL           ;Multiply by power of 10 if exponent positive
        JMP     SHORT MULDON

DBLEXP:
        ADD     DI,OFFSET DC:PWR10TAB
        MOV     SI,OFFSET DC:$DAC
        OR      CX,CX
        JNS     DBLPOS
        CALL    $DDIV
        JMP     SHORT MULDON
DBLPOS:
        CALL    $DMUL
MULDON:
        POP     SI              ;Recover pointer to text buffer
COERCE:
        MOV     AX,[TYP]
        CMP     AL,AH           ;Already the right type?
        JZ      DONE
        CMP     AL,2            ;Need integer? (have floating)
        JZ      CONVINT         ;Convert to integer whether SP or DP
        CALL    $CSPB           ;Convert DP to SP
        RET

ZERO:
        XOR     AX,AX
        MOV     [$AC],AX        ;Zero in case its integer
        MOV     [$FAC],AL       ;Zero in case its floating
        RET

CONVINT:
        CALL    $CINFAC         ;Convert floating to integer
        RET

SIGN:
        CALL    $GETCH
        CMP     AL,"-"          ;Negative?
        JZ      DONE
        CMP     AL,"+"
        JNZ     NOTZER
        INC     SI              ;Eat sign if present and
NOTZER: DEC     SI              ;Back up and clear zero flag
DONE:   RET

MAXINT:
        MOV     BX,32767        ;Force maximum integer (will overflow later)
GETINT:
        CALL    GETDIG
        CMP     BX,3276
        JA      MAXINT
        SHL     BX,1
        ADD     AX,BX
        SHL     BX,1
        SHL     BX,1
        ADD     BX,AX           ;BX = BX*10 + AX
        JS      MAXINT          ;Still OK as signed integer?
        JMP     GETINT

ASCNUM:
;Scan a string of ASCII digits with optional decimal point and return
;32-, or 64-bit integer in registers. On exit:
;       32-bit result: BX:DX            CURTYP = 4
;       64-bit result: DI:BP:BX:DX      CURTYP = 8
;       CX has power of 10 needed to put decimal point in right place.
;
;Sliding precision is used for speed. As the number of digits increases,
;requiring greater precision to maintain accuracy, the conversion shifts
;from to 32-bit to 64-bit calculations. If the number of digits
;exceeds 64-bit precision, these trailing digits are used to set a sticky
;bit (if non-zero), but are otherwise trimmed off.

        XOR     BX,BX           ;Current value is zero
        MOV     DX,BX
        MOV     BP,BX
        MOV     CX,BX           ;No power of 10 yet
        MOV     [PWRINC],BX     ;Don't increment power of 10 yet
        MOV     [CURTYP],4      ;Type integer so far
        MOV     [HAVDP],BL      ;Decimal point not seen yet
SNGLOOP:
        CALL    GETDIG
        SHL     DX,1
        RCL     BX,1
        ADD     AX,DX
        MOV     DI,BX
        ADC     DI,0            ;DI:AX = BX:DX*2 + AX
        SHL     DX,1
        RCL     BX,1
        SHL     DX,1
        RCL     BX,1
        ADD     DX,AX
        ADC     BX,DI           ;BX:DX = BX:DX*10 + AX
        OR      BH,BH           ;Still in 24 bits?
        JZ      SNGLOOP         ;If not, convert to double
        MOV     [CURTYP],8      ;Type now double precision
        XOR     DI,DI           ;Number in DI:BP:BX:DX
DBLLOOP:
        CALL    GETDIG
        PUSH    AX
        PUSH    DI
        PUSH    BP
        PUSH    BX
        PUSH    DX
        SHL     DX,1            ;Number=number*2
        RCL     BX,1
        RCL     BP,1
        RCL     DI,1
        SHL     DX,1            ;Number=number*4
        RCL     BX,1
        RCL     BP,1
        RCL     DI,1
        POP     AX
        ADD     DX,AX           ;Number=number*5
        POP     AX
        ADC     BX,AX
        POP     AX
        ADC     BP,AX
        POP     AX
        ADC     DI,AX
        SHL     DX,1            ;Number=number*10
        RCL     BX,1
        RCL     BP,1
        RCL     DI,1
        POP     AX              ;New digit to add in
        ADD     DX,AX
        ADC     BX,0
        ADC     BP,0
        ADC     DI,0
        CMP     DI,6553         ;If too many digits, ignore them
        JB      DBLLOOP
        INC     [PWRINC]        ;Count the digits as we ignore them
EATLOOP:
        CALL    GETDIG
        OR      AL,AL           ;Was digit zero?
        JZ      NEXTDIG
        OR      DL,1            ;Set sticky bit if non-zero digit
NEXTDIG:
        JMP     EATLOOP

GETDIG:
;This routine get the next digit and returns it (with ASCII bias removed)
;in AX (AH is always zero). For each digit returned, [PWRINC] is added to
;CX as a means to count digits so we'll get the power of 10 right. When the
;first decimal point is encountered, PWRINC is decremented one. This decimal
;point is skipped over and we look for the next digit. On return, the flags
;are set from a comparison with the largest number that can be multiplied by
;10 and not overflow BX.
;       Should a second decimal point or any other non-digit be encountered,
;we have reached the end of the number and the routine pops one return
;address off the stack and returns to the next level up.
        CALL    $GETCH          ;Get next ASCII character
        SUB     AL,"0"          ;Subtract ASCII bias
        JB      NOTNUM
        CMP     AL,9
        JA      NOTNUM
        CBW                     ;Zero AH
        ADD     CX,[PWRINC]     ;Count digits ignored or to right of dec. pt.
        RET                     ;Return with flags set
NOTNUM:
        CMP     AL,"."-"0"      ;Is it decimal point?
        JNZ     NOTDIG
        CMP     [HAVDP],0       ;Seen a dec.pt. before?
        JNZ     NOTDIG          ;If so, this one ends the number
        DEC     [PWRINC]        ;Count digits to right of dec.pt.
        JMP     GETDIG          ;Get a real digit
NOTDIG:
        DEC     SI              ;Point back at non-digit
        ADD     SP,2            ;Return to next level up
        RET

$GETCH:
;Get next byte, skipping blanks, tabs, and linefeeds
        LODSB                   ;Get next input byte
        CMP     AL," "          ;Ignore spaces
        JZ      $GETCH
        CMP     AL,9            ;Ignore tabs
        JZ      $GETCH
        CMP     AL,10           ;Ignore linefeeds
        JZ      $GETCH
        CMP     AL,"a"
        JB      RET
        CMP     AL,"z"
        JA      RET
        AND     AL,5FH          ;Convert lower to upper case
RET:    RET

CODE    ENDS
        END
