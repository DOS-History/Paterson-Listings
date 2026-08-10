        TITLE   PUFOUT - PRINT USING output formatter

;Definition of bits in flag byte

COMMABIT=       40H             ;Commas every 3 digits in integer part
STARBIT=        20H             ;Fill with leading "*" instead of blanks
DOLLARBIT=      10H             ;Floating "$" in front of number
PLUSBIT=        8               ;Force "+" in positive
TRAILING=       4               ;Put sign at end of number
SCIBIT=         1               ;Use scientific notation


DATA    SEGMENT BYTE PUBLIC 'DATA'

        EXTRN   $DIGCNT:BYTE,SIGN:BYTE,FOBUF:BYTE,$PUFLAG:BYTE

DECDIG  EQU     $DIGCNT         ;No. of digits to right of D.P.
INTDIG  EQU     $DIGCNT+1       ;No. of digits to left of D.P.
FLAG    EQU     $PUFLAG         ;Specification flags

EXP     DB      ?

DATA    ENDS


DC      GROUP   DATA


CODE    SEGMENT WORD PUBLIC 'CODE'

        PUBLIC  $PUFOUT

        EXTRN   CONASC:NEAR, ASCRND:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;***  $PUFOUT - PRINT USING output formatter
;
; Inputs:
;       [$DIGCNT+1] = field width to left of decimal point
;       [$DIGCNT] = field width to right & including decimal point
;       [FLAG] = Formatting flags (see equates above)
;       [VALTYP] = Type of number
;       Number in FAC
; Function:
;       Format the number according to PRINT USING specifications. Leave in
;       a buffer terminated with a zero.
; Outputs:
;       SI = Address of first character of formatted output
;       AX = Count of characters (not including terminating zero)
; Registers:
;       All registers affected.

$PUFOUT:
        CALL    CONASC          ;Convert to ASCII digits
PUFOUT:
        XOR     BX,BX           ;No position-eating symbols yet
        MOV     AL,[FLAG]       ;Get PRINT USING flags
        TEST    AL,DOLLARBIT    ;Need floating dollar sign?
        JZ      NODOL
        INC     BX              ;Chalk up a position for the "$"
NODOL:
        CMP     [SIGN],"-"      ;Is number negative?
        JZ      HAVSGN          ;If so, leave sign alone
        TEST    AL,PLUSBIT      ;Do we force "+"?
        JZ      NOSGN           ;No - leave it a blank
        MOV     [SIGN],"+"
HAVSGN:
        TEST    AL,TRAILING     ;Is it in front, eating a digit position?
        JNZ     NOSGN
        INC     BH              ;Count one position for the sign
NOSGN:
        TEST    AL,SCIBIT       ;Scientific notation?
        JNZ     SCILEN
        ADD     BL,BH           ;Sum positions needed for sign and "$"
        MOV     AL,DL           ;Power of 10 of digit string
        ADD     AL,CL           ;Plus count of digits gives number of digits
                                ;to left of decimal point
        MOV     AH,[DECDIG]     ;Number of digits requested to right of d.p.
        DEC     AH              ;Count off one for decimal point itself
        JL      ROUND           ;Any decimal digits?
        ADD     AL,AH           ;Add to count of digits needed
ROUND:
        OR      AL,AL
        JL      NOROUND         ;Don't ask for negative digits
        CALL    ASCRND          ;Round ASCII digits
NOROUND:
        CMP     BYTE PTR [SI],"0"  ;Is number zero?
        JNZ     NOTZERO
        MOV     DL,-1           ;If so, set exponent to no integer part
NOTZERO:
        MOV     AX,CX           ;Number of digits in number now
        ADD     AL,DL           ;New count of integer digits
        MOV     DH,AL           ;Save it for output loop
        MOV     AH,0
        JG      COMCHK          ;If we have integer digits, do comma check
        MOV     AL,0            ;No integer digits
        JMP     SHORT GETFILL

SCILEN:
;Compute digit counts and round for scientific notation
        MOV     AL,[INTDIG]
        SUB     AL,BL           ;Count a digit position if "$" needed
        ADD     BL,BH           ;Sum positions needed for "$" and sign
        DEC     AL              ;Always take one for the sign
        JNS     SCI1            ;If there's room, that is
        XOR     AL,AL
SCI1:
        MOV     BH,AL           ;Save count of digits to left of d.p.
        MOV     AL,[DECDIG]
        DEC     AL              ;Count one position for d.p. itself
        JNS     SCI2
        XOR     AL,AL
SCI2:
        ADD     AL,BH           ;Sum total digits needed
        JG      SCI3            ;Need at least one
        INC     AX              ;Request one digit
        INC     BH              ;And print it to left of d.p.
SCI3:
        CALL    ASCRND          ;Round to correct number of digits
        CMP     BYTE PTR [SI],"0"  ;Is result zero?
        JNZ     FIGEXP          ;If not, we're OK - go figure exponent
        XOR     AL,AL           ;Set exponent to zero
        OR      BH,BH           ;Print digits to left of d.p.?
        JZ      SAVEXP          ;If not, that's O.K.
        MOV     BH,1            ;If so, print at most 1
FIGEXP:
        MOV     AX,CX
        ADD     AL,DL           ;AL = Number of integer digits
        SUB     AL,BH           ;Subtract number to be printed left of d.p.
SAVEXP:
        MOV     [EXP],AL        ;Exponent to be printed later
        MOV     AL,BH           ;Set up digit count
        MOV     DH,BH
        JMP     SHORT GETFILL

COMCHK:
        TEST    [FLAG],COMMABIT ;Need commas?
        JZ      GETFILL

;Perform comma computation. We need a comma every 3 digits, so we'll divide
;the number of digits by 3 to see how many we need. Since we don't need the
;first comma until we have 4 digits, the digit count is decremented before
;the division. The remainder of the division represents the number of digits
;to print before the first comma is needed.

        DEC     AX
        MOV     BH,3
        DIV     BH              ;AL=number of commas
        ADD     AL,DH           ;Add up number of positions needed
        INC     AH              ;Adjust delay to first comma to range 1-3

;Let's see if all this stuff will fit. If so, compute amount of extra room
;for leading filler. Otherwise, print a "%".

GETFILL:
        TEST    [FLAG],2        ;Already had field overflow?
        JZ      FITCHK
        MOV     BYTE PTR [DI],"%"
        INC     DI
FITCHK:
        ADD     AL,BL           ;Add digits needed by "$" and sign
        SUB     AL,[INTDIG]     ;Do we have enough room?
        JBE     FILCNT          ;AL is negative of amount of extra room
        CMP     AL,4            ;Exceeding width by more that 4?
        JBE     OVERFIELD
        OR      [FLAG],SCIBIT+2 ;Use scientific notation and set field overflow
        JMP     PUFOUT          ;Try again
OVERFIELD:
        MOV     AL,"%"          ;Didn't fit - print field overflow character
        STOSB
        XOR     AL,AL           ;Zero fill count

;Leading-fill field with blanks or "*"s as requested

FILCNT:
        MOV     DL,AH           ;Save delay to first comma (zero if no commas)
        JZ      GETCNT          ;Any filling necessary?
        OR      DH,DH           ;And do we have integer digits to print?
        JG      GETCNT          ;If not, we'll add a leading zero
        INC     AL              ;Make room by reducing fill count
        INC     CH              ;Set leading zero flag
GETCNT:
        NEG     AL              ;Make fill count positive
        CBW
        XCHG    AX,CX           ;Put count in CX
        XCHG    AX,BX           ;Save digit count (from CX) in BX
        MOV     AL," "          ;Fill character
        MOV     AH,[FLAG]       ;Get flag byte
        TEST    AH,STARBIT      ;Fill with "*" instead?
        JZ      FILL
        MOV     AL,"*"
FILL:
        REP     STOSB           ;Leading fill

;Print leading sign, if needed

        TEST    AH,TRAILING     ;Leading or trailing sign?
        JNZ     DOLLARCHK
        MOV     AL,[SIGN]       ;Pick up leading sign
        CMP     AL," "          ;If blank, already counted in fill count
        JZ      DOLLARCHK
        STOSB                   ;Store sign

;Print floating "$" if requested

DOLLARCHK:
        TEST    AH,DOLLARBIT    ;Floating "$"
        JZ      NODOLLAR
        MOV     AL,"$"
        STOSB
NODOLLAR:

;Copy integer digits, if any

        MOV     CL,DH           ;Count of digits to left of d.p.
        NEG     DH              ;Count of zeros to fill after d.p.
        JL      NOCOM           ;Don't check for comma first time through
        DEC     BH              ;Force leading zero?
        JNZ     DPCHK
        MOV     AL,"0"
        STOSB
        JMP     SHORT DPCHK

INTDIGITS:
        DEC     DL              ;Need a comma yet?
        JNZ     NOCOM
        MOV     AL,","
        STOSB
        MOV     DL,3            ;Reset comma count down
NOCOM:
        MOV     AL,"0"          ;In case we're out of digits, use trailing "0"
        DEC     BL              ;Any digits left?
        JS      STOINTDIG       ;No - go store trailing zero
        LODSB                   ;Yes - get next digit
STOINTDIG:
        STOSB
        LOOP    INTDIGITS

;Check for fraction part and print decimal point if so

DPCHK:
        MOV     CL,[DECDIG]     ;Number of digits to right of d.p.
        DEC     CX              ;Count off decimal point itself
        JS      SCICHK          ;No decimal point?
        MOV     AL,"."
        STOSB
        JZ      SCICHK          ;A d.p., but no decimal digits?

;Print the zeros, if any, between after the decimal point but before the MSD

        OR      DH,DH           ;Any fill zeros after d.p.?
        JLE     MOVFRAC
        MOV     AL,"0"
AFTDP:
        STOSB
        DEC     DH              ;Limit to fill count
        LOOPNZ  AFTDP           ;Limit to field width

;Print the fraction digits, if any

MOVFRAC:
        JCXZ    SCICHK          ;Filled out field width?
        OR      BL,BL           ;Any digits left?
        JLE     POSTFILL
MOVDECDIG:
        MOVSB                   ;Copy a digit
        DEC     BL              ;Limit to digits available
        LOOPNZ  MOVDECDIG       ;Limit to field width

;Fill out the field with zeros

POSTFILL:
        MOV     AL,"0"
        REP     STOSB           ;Force fill with zeros

;Print exponent if in scientific notation

SCICHK:
        TEST    AH,SCIBIT       ;Scientific notation?
        JZ      SIGNCHK
        MOV     AL,"E"
        STOSB
        MOV     BL,[EXP]        ;Get exponent
        MOV     AL,"+"          ;Assume it's positive for now
        OR      BL,BL
        JNS     EXPSGN
        NEG     BL              ;Get magnitude of exponent
        MOV     AL,"-"          ;Display sign
EXPSGN:
        STOSB
        XCHG    AX,BX
        AAM                     ;Convert exponent to unpacked BCD
        OR      AX,"00"         ;Add ASCII bias
        XCHG    AL,AH           ;MSD in AL
        STOSW                   ;Save both digits at once
        XCHG    AX,BX           ;Restore flags to AH

;Print trailing sign if needed

SIGNCHK:
        TEST    AH,TRAILING     ;AH still has flags
        JZ      ENDNUM          ;Need a trailing sign?
        MOV     AL,[SIGN]
        STOSB

;Finish up with trailing 00 and compute line length

ENDNUM:
        XOR     AL,AL           ;Terminating zero
        STOSB
        MOV     SI,OFFSET DC:FOBUF
        XCHG    AX,DI
        SUB     AX,SI           ;Length of string
        RET

CODE    ENDS
        END
