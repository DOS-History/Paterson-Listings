        TITLE   CONASC - Convert number to ASCII

DATA    SEGMENT WORD PUBLIC 'DATA'

        PUBLIC  SIGN,FOBUF

        EXTRN   VALTYP:BYTE, $FAC:BYTE, $AC:BYTE, $DAC:BYTE

SIGN    DB      ?
FOBUF   DB      35 DUP (?)      ;Numeric output buffer
BUF     DB      20 DUP (?)      ;ASCII conversion buffer

DATA    ENDS


CONST   SEGMENT WORD PUBLIC 'CONST'

        EXTRN   PWR10TAB:WORD

; Table of integers 10^X, for X=18 down to 8, for converting DP numbers

DPCON   LABEL   WORD
        DW      0000H,0A764H,0B6B3H,0DE0H       ;10^18
        DW      0000H,5D8AH,4578H,163H          ;10^17
        DW      0000H,6FC1H,86F2H,23H           ;10^16
        DW      8000H,0A4C6H,8D7EH,3            ;10^15
        DW      4000H,107AH,5AF3H,0             ;10^14
        DW      0A000H,4E72H,918H,0             ;10^13
        DW      1000H,0D4A5H,0E8H,0             ;10^12
        DW      0E800H,4876H,17H,0              ;10^11
        DW      0E400H,540BH,2,0                ;10^10
        DW      0CA00H,3B9AH,0,0                ;10^9
        DW      0E100H,5F5H,0,0                 ;10^8


;EXPTAB - Lookup table for exponents
;An actual base 2 exponent of 25 or 57 (for SP or DP, respectively) is needed
;before a number may be converted from binary to decimal. This is because such
;an exponent ensures the mantissa is just a big integer. The difference
;between the desired exponent (25 or 57) and the present one is figured and
;used as an index into this table. The entries in the table represent the
;power of 10 to multiply by to get the needed exponent. The table covers
;an exponent difference range of -102 [25-127] to +184 [57-(-127)].

        DB      -30,-30,-30,-29,-29,-29         ;-102 to -97
        DB      -28,-28,-28,-27,-27,-27,-27,-26 ;-96 to -89
        DB      -26,-26,-25,-25,-25,-24,-24,-24 ;-88 to -81
        DB      -24,-23,-23,-23,-22,-22,-22,-21 ;-80 to -73
        DB      -21,-21,-21,-20,-20,-20,-19,-19 ;-72 to -65
        DB      -19,-18,-18,-18,-18,-17,-17,-17 ;-64 to -57
        DB      -16,-16,-16,-15,-15,-15,-15,-14 ;-56 to -49
        DB      -14,-14,-13,-13,-13,-12,-12,-12 ;-48 to -41
        DB      -12,-11,-11,-11,-10,-10,-10,-9  ;-40 to -33
        DB      -9,-9,-9,-8,-8,-8,-7,-7         ;-32 to -25
        DB      -7,-6,-6,-6,-6,-5,-5,-5         ;-24 to -17
        DB      -4,-4,-4,-3,-3,-3,-3,-2         ;-16 to -9
        DB      -2,-2,-1,-1,-1,0,0,0            ;-8 to -1
EXPTAB  LABEL   BYTE    ;Table is centered on zero
        DB      0,1,1,1,2,2,2,3                 ;0 to 7
        DB      3,3,4,4,4,4,5,5                 ;8 to 15
        DB      5,6,6,6,7,7,7,7                 ;16 to 23
        DB      8,8,8,9,9,9,10,10               ;24 to 31
        DB      10,10,11,11,11,12,12,12         ;32 to 39
        DB      13,13,13,13,14,14,14,15         ;40 to 47
        DB      15,15,16,16,16,16,17,17         ;48 to 55
        DB      17,18,18,18,19,19,19,19         ;56 to 63
        DB      20,20,20,21,21,21,22,22         ;64 to 71
        DB      22,22,23,23,23,24,24,24         ;72 to 79
        DB      25,25,25,25,26,26,26,27         ;80 to 87
        DB      27,27,28,28,28,28,29,29         ;88 to 95
        DB      29,30,30,30,31,31,31,32         ;96 to 103
        DB      32,32,32,33,33,33,34,34         ;104 to 111
        DB      34,35,35,35,35,36,36,36         ;112 to 119
        DB      37,37,37,38,38,38,38,39         ;120 to 127
        DB      39,39,40,40,40,41,41,41         ;128 to 135
        DB      41,42,42,42,43,43,43,44         ;136 to 143
        DB      44,44,44,45,45,45,46,46         ;144 to 151
        DB      46,47,47,47,47,48,48,48         ;152 to 159
        DB      49,49,49,50,50,50,50,51         ;160 to 167
        DB      51,51,52,52,52,53,53,53         ;168 to 175
        DB      53,54,54,54,55,55,55,56         ;176 to 183
        DB      56                              ;184

CONST   ENDS

DC      GROUP   CONST,DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  CONASC, ASCRND, $TYPUI

        EXTRN   PMULS:NEAR, PMULD:NEAR
        EXTRN   $$WCHT:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


OUTINT:         ;This is a continuation of CONASC, below
        MOV     DI,OFFSET DC:BUF  ;Save digits in BUF
        MOV     AX,WORD PTR[$AC]  ;Get integer to convert
        MOV     DL," "          ;In case sign is positive
        OR      AX,AX
        JZ      ZERO
        JNS     SAVSGN          ;Positive?
        NEG     AX              ;Force in positive
        MOV     DL,"-"
SAVSGN:
        MOV     [SIGN],DL       ;Record the sign
        CALL    ASCINT          ;Convert it to ASCII
        MOV     DL,0            ;Base 10 exponent is zero
        JMP     COUNTDIG

ZERO:
        MOV     [SIGN]," "      ;Show positive sign
        MOV     CX,1            ;Only one digit
        MOV     DL,0            ;Zero base 10 exponent
        MOV     SI,OFFSET DC:BUF
        MOV     BYTE PTR [SI],"0"
        RET


;***  CONASC - Convert number to ASCII
;
; Inputs:
;       $AC has integer or SP number OR $DAC has DP number
;       VALTYP has type (2=integer, 4=SP, 8=DP)
; Function:
;       Convert number to a string of ASCII digits with no leading or
;       trailing zeros. Return base 10 exponent and count of digits.
; Outputs:
;       CX = number of significant figures (decimal point to right)
;       DL = base 10 exponent
;       SI = Address of first digit (non-zero unless number is zero)
;       [SIGN] has sign - blank if positive, "-" if negative
; Registers:
;       Uses all.

CONASC:
        CMP     [VALTYP],4      ;Check type of number
        JB      OUTINT
        MOV     BX,25+128       ;Desired exponent for SP (plus bias)
        JZ      FIGDIF          ;SP number?
        ADD     BX,32           ;32 bits more for DP
FIGDIF:
        MOV     DL,[$FAC]       ;Get exponent
        OR      DL,DL           ;Is number zero?
        JZ      ZERO            ;That was easy
        MOV     DH,0
        SUB     BX,DX           ;See what we have to do to get desired exp.
        MOV     AL," "          ;In case its positive
        TEST    [$FAC-1],80H    ;Check sign bit
        JZ      SETSGN          ;Positive?
        MOV     AL,"-"
SETSGN:
        MOV     [SIGN],AL
        MOV     AL,OFFSET DC:EXPTAB[BX] ;What power of 10 will give us the right exp?
        CBW
        MOV     SI,AX
        SHL     SI,1            ;8 bytes per entry in power of 10 table
        SHL     SI,1
        SHL     SI,1
        ADD     SI,OFFSET DC:PWR10TAB
        MOV     AH,[SI+7]       ;Get base 2 exponent of this power of 10
        ADD     AH,DL           ;Compute exponent resulting from multiply
        NEG     AL              ;Take account of multiplying by power of 10
        PUSH    AX              ;Save base 2 and base 10 exponents
        CMP     [VALTYP],4      ;SP number?
        JNZ     OUTDBL          ;If not, go do double precision calculations
        MOV     DI,WORD PTR[$AC]  ;Load up number to convert
        MOV     CL,[$AC+2]
        MOV     BL,[SI+6]       ;Load up power of 10
        MOV     AL,BYTE PTR[SI+3]  ;Get byte below least significant
        OR      CL,80H          ;Set implied bit
        MUL     CL              ;Compute least significant partial product
        MOV     SI,[SI+4]
        PUSH    AX
        CALL    PMULS           ;Multiply mantissas - result in AX:BX
        POP     DX              ;Retrieve least significant partial product
        ADD     BL,DH           ;Accumulate it
        ADC     BH,0
        ADC     AX,0
        MOV     DH,0            ;Shuffle to get result in DX:AL:BL
        MOV     DL,AH
        MOV     AH,AL
        MOV     AL,BH
        POP     CX              ;Recover base 2 exponent
        PUSH    CX
        XCHG    CL,CH           ;Base 2 exponent in CL
        AND     CX,7            ;We'll be within 4 of desired exponent
        JZ      RNDTST          ;Hit it exactly?
;Exponent did not turn out to be exactly 24 - it could be as much as 29.
;For every power of two larger, we must shift another bit into the mantissa,
;so that when we're done we have the same number of bits as the exponent says.
SHFT:
        SHL     BL,1
        RCL     AX,1
        RCL     DX,1
        LOOP    SHFT
RNDTST:
        MOV     DI,OFFSET DC:BUF  ;Save characters in BUF
        CMP     BL,80H          ;Do we need to round?
        JA      ROUND           ;Yes
        JB      ASCSP           ;No
        TEST    AL,1            ;Maybe - round even
        JZ      ASCSP
ROUND:
        ADD     AX,1            ;Round up
        ADC     DX,0            ;Propagate carry
ASCSP:
        MOV     BX,10000        ;Break number in to 2 manageable chunks
        DIV     BX
        PUSH    DX              ;Save low half for later
        CALL    ASCINT          ;Convert high 5 digits
        POP     DX
        CALL    ASC10K          ;Convert last 4 digits
        POP     DX              ;DL = base 10 exponent
COUNTDIG:
        MOV     CX,DI
        MOV     DI,OFFSET DC:BUF
        SUB     CX,DI           ;Number of digits converted
        MOV     AL,"0"
        REPE    SCASB           ;Scan off leading zeros
        INC     CX              ;Number of digits left
        DEC     DI              ;Point to first digit
        MOV     SI,DI
        RET

OUTDBL:
        MOV     DI,OFFSET DC:$DAC
        CALL    PMULD           ;Result in DI:BX:CX:DX
        MOV     AL,CH           ;Get result in BX:BP:DI:AX:DL
        MOV     AH,BL
        XCHG    AX,DI
        MOV     BL,AH
        MOV     AH,AL
        MOV     AL,BH
        XCHG    AX,BP
        MOV     BH,0
        MOV     AL,DH
        MOV     AH,CL
        POP     CX              ;Recover base 2 exponent
        PUSH    CX
        XCHG    CL,CH           ;Base 2 exponent in CL
        AND     CX,7            ;We'll be within 4 of desired exponent
        JZ      DRNDTST         ;Hit it exactly?
;Exponent did not turn out to be exactly 56 - it could be as much as 61.
;For every power of two larger, we must shift another bit into the mantissa,
;so that when we're done we have the same number of bits as the exponent says.
DSHFT:
        SHL     DL,1
        RCL     AX,1
        RCL     DI,1
        RCL     BP,1
        RCL     BX,1
        LOOP    DSHFT
DRNDTST:
        CMP     DL,80H          ;Need to round?
        JA      DROUND          ;Yes
        JB      DPCONV          ;No
        TEST    AL,1            ;Maybe - round even
        JZ      DPCONV
DROUND:
        ADD     AX,1
        ADC     DI,0
        ADC     BP,0
        ADC     BX,0
DPCONV:
        MOV     DX,DI           ;Number now in BX:BP:DX:AX
        MOV     DI,OFFSET DC:BUF  ;Save characters in BUF
        MOV     CX,11           ;19 digits - last 8 handled by SP converter
        MOV     SI,OFFSET DC:DPCON      ;Table of powers of 10
DPDIG:
        SUB     AX,[SI]         ;Subtract a power of 10
        SBB     DX,[SI+2]
        SBB     BP,[SI+4]
        SBB     BX,[SI+6]
        INC     CH              ;Count in case successful
        JNC     DPDIG           ;Divide by 10^X by repeat subtraction
;We subtracted one too many, so restore
        ADD     AX,[SI]
        ADC     DX,[SI+2]
        ADC     BP,[SI+4]
        ADC     BX,[SI+6]
        DEC     CH
        ADD     SI,8            ;Bump up to next power of 10
        OR      CH,"0"
        MOV     [DI],CH         ;Store the digit
        INC     DI
        MOV     CH,0            ;Initialize count for next power of 10
        LOOP    DPDIG
;What we have left now is a number in DX:AX < 10^8
        JMP     ASCSP


;***  ASCINT = Convert 2-byte integer to ASCII
;
; Inputs:
;       AX = integer
;       DI = pointer to digit buffer
; Function:
;       Convert the integer to 5 unpacked BCD digits, stored at [DI].
; Outputs:
;       None.
; Registers:
;       All destroyed.

ASCINT:
        XOR     DX,DX
        XCHG    AX,DX
        MOV     BX,10000
        CMP     DX,BX           ;Any 10000's digits?
        JB      ASC10K          ;If not, skip division
        XCHG    AX,DX
        DIV     BX              ;Compute 10000's digit
        ADD     AL,"0"
        STOSB
ASC10K:
; Convert integer in DX <10^4 to unpacked BCD
        XOR     AX,AX
        MOV     BX,10*100H+100  ;10 in BH, 100 in BL
        CMP     DX,100          ;Any 100's or 1000's digits?
        JB      STO10           ;If not, skip division
        XCHG    AX,DX
        DIV     BL              ;Separate 100's and 1000's
        XCHG    AH,DL           ;Save remainder and extend with a zero
        DIV     BH              ;Divide by 10 to get 100's and 1000's digits
STO10:
        OR      AX,"00"
        STOSW
        XCHG    AX,DX
        DIV     BH              ;Divide by 10 to get 1's and 10's digits
        OR      AX,"00"
        STOSW
        RET


;***    $TYPUI - Type unsigned integer
;
; Inputs:
;       AX = number to print
; Function:
;       Print a 16-bit unsigned integer to console with zero suppression.
; Registers:
;       All destroyed

$TYPUI:
        MOV     DI,OFFSET DC:BUF        ;Try to use existing routines
        CALL    ASCINT                  ;Convert to ASCII in BUF
        CALL    COUNTDIG                ;Skip leading zeroes

typlop: LODSB                           ;Get character
        CALL    $$WCHT
        LOOP    typlop                  ;Keep looping until CX=0
        RET


;***  ASCRND - Round ASCII digits
;
; Inputs:
;       AL = Number of digits wanted
;       CX = Number of digits presently in number
;       DL = Base 10 exponent (D.P. to right of digits)
;       SI = Address of first digit
; Function:
;       Round number to the specified number of digits. Eliminate trailing
;       zeros from digit count.
; Outputs:
;       CX = Number of digits now in number (always <= request)
;       DL = Base 10 exponent of rounded number
;       SI = Address of first digit of rounded number
;       DI = Address of formatting buffer, FOBUF
; Registers:
;       Only BX, BP preserved.

ASCRND:
        MOV     DI,SI
        CBW                     ;Zero AH (AL <= 18)
        ADD     DI,CX           ;Point past last digit
        CMP     AX,CX           ;Any extra digits?
        JAE     ZSCAN           ;If not, no rounding
        XCHG    AX,CX           ;Say we'll return number requested
        SUB     AX,CX           ;See how many digits we're trimming
        ADD     DL,AL           ;Increase exponent accordingly
        SUB     DI,AX           ;Point to first extra digit
        MOV     AL,"0"
        XCHG    AL,[DI]         ;Get rounding digit and replace it with zero
        CMP     AL,"5"          ;Do we need to round?
        JB      ZSCAN
        JCXZ    RNDALL
RND:
        DEC     DI              ;Point to digit to round
        MOV     AL,[DI]         ;Get a digit that needs incrementing
        INC     AL
        CMP     AL,"9"+1        ;Did we overflow this digit position?
        JB      STORND          ;If not, store it and we're done
        INC     DL              ;Otherwise exponent must be adjusted
        LOOP    RND             ;We'll need to round next digit
RNDALL:
        INC     CX              ;Must have at least one digit
        MOV     AL,"1"          ;If we rounded all digits, must be to 1
STORND:
        STOSB                   ;Save rounded digit
ZSCAN:
;DI points just past the digits we want. Check for trailing zeros.
        DEC     DI              ;Point to last digit
        MOV     AH,CL           ;Remember how many digits we started with
        MOV     AL,"0"
        STD                     ;Scan DOWN
        REPE    SCASB           ;Scan for "0"s
        CLD                     ;Restore direction UP
        INC     CX              ;Number of digits left
        SUB     AH,CL           ;Number of digits skipped
        ADD     DL,AH           ;Increase base 10 exponent accordingly
        MOV     DI,OFFSET DC:FOBUF
        RET

CODE    ENDS
        END
