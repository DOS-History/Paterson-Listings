        TITLE   DMATH - Double precision floating point arithmetic

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FAC:BYTE,$DAC:WORD

OP1MAN  DW      ?
OP2MAN  DW      ?

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT WORD PUBLIC 'CODE'

        PUBLIC  $FADB,$FADD,$FADF,$FADH,$FSUB,$FSUD,$FSUF,$FSUH
        PUBLIC  $FMUB,$FMUD,$FMUF,$FMUH,$FDVB,$FDVD,$FDVF,$FDVH
        PUBLIC  $DADD,$DSUB,$DMUL,$DDIV,PMULD,$DNORM,$DROUND

        EXTRN   $OVFL:NEAR,$DIV0:NEAR,$SAVREG:NEAR,$GTMP:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


$FSUD:
        MOV     SI,OFFSET DC:$DAC
        JMP     SHORT $FSUB
$FSUH:
        CALL    $GTMP
$FSUF:
        MOV     DI,OFFSET DC:$DAC
$FSUB:
        CALL    $SAVREG

        SUBTTL  $DSUB and $DADD - Double precision subtraction and addition
; Inputs:
;       SI = Address Of Subtrahend Or Addend
;       DI = Address of Minuend or Addend
; Function:
;       Subtract/Add the operands in double precision and leave result in
;       $FAC. Performs rounding with sticky bit.
; Outputs:
;       Result in $FAC.
; Registers:
;       All except BP destroyed.

$DSUB:
        MOV     CX,[DI+6]       ;Get sign & exponent on subtrahend
        XOR     CL,80H          ;Invert its sign
        JMP     SHORT DOADD     ;   and just add

SAVDI:
        XCHG    AX,CX
        MOV     SI,DI
        MOV     DI,OFFSET DC:$DAC
        MOVSW
        MOVSW
        MOVSW
        STOSW
        RET

$FADD:
        MOV     SI,OFFSET DC:$DAC
        JMP     SHORT $FADB
$FADH:
        CALL    $GTMP
$FADF:
        MOV     DI,OFFSET DC:$DAC
$FADB:
        CALL    $SAVREG

$DADD:
        MOV     CX,[DI+6]       ;Get sign & exponent of one operand
DOADD:
        MOV     AX,[SI+6]       ;Get sign & exponent of other operand
        OR      AH,AH
        JZ      SAVDI
        CMP     CH,AH           ;See which number is larger
        JA      SIGNFIDDLE      ;See if difference is positive
        XCHG    SI,DI           ;Swap pointers to operands
        XCHG    AX,CX           ;Swap exponents/signs
        OR      AH,AH           ;See if smaller operand is zero
        JZ      SAVDI           ;If so, return larger
SIGNFIDDLE:
        SUB     AH,CH           ;Subtract exponents ( <=0 )
        NEG     AH
        CMP     AH,56           ;Is smaller argument significant?
        JA      SAVDI
        SHL     AL,1            ;Put sign of smaller into carry
        RCR     CL,1            ;Now pack it in next to sign of larger
        XCHG    AX,CX
        MOV     CL,CH
        MOV     CH,0

; Now things look like this:
;       SI has pointer to smaller operand
;       DI has pointer to larger operand
;       AL bit 7 has sign of smaller
;       AL bit 6 has sign of larger
;       CL has exponent difference ( 0 <= CL <= 56 )
;       CH is zero
;       AH has exponent of larger ( = tentative exponent of result)

        PUSH    AX
        PUSH    DI              ;We'll need these later
        MOV     DI,CX           ;Need all 8-bit registers

;Load smaller operand

        LODSB
        MOV     AH,AL
        XOR     AL,AL           ;Extend operand to 64 bits with zeros
        XCHG    AX,DX
        LODSW
        XCHG    AX,CX
        LODSW
        XCHG    AX,BX
        LODSW
        OR      AH,80H          ;Set implied bit

;Smaller operand now in AX:BX:CX:DX with implied bit set

        OR      DI,DI
        JZ      ALIGNED         ;Alignment operations necessary?
CHKALN:
        CMP     DI,14           ;Do shifts of 16 bits by word rotate
        JL      BYTSHFT         ;If not enough for word, go try byte
        OR      DX,DX           ;See if we're shifting something off the end
        JZ      NOSTIK
        OR      CL,1            ;Ensure sticky bit will be set
NOSTIK:
        MOV     DX,CX
        MOV     CX,BX
        MOV     BX,AX
        XOR     AX,AX
        SUB     DI,16           ;Counts for 16 bit shifts
        JA      CHKALN          ;If not enough, try again
        JZ      ALIGNED         ;Hit it exactly?
        JB      SHFLEF          ;Back up if too far

BYTSHFT:
        CMP     DI,6            ;Can we do a byte shift?
        JL      BITSHFT
        OR      DL,DL
        JZ      NSTIK
        OR      DH,1
NSTIK:
        MOV     DL,DH
        MOV     DH,CL
        MOV     CL,CH
        MOV     CH,BL
        MOV     BL,BH
        MOV     BH,AL
        MOV     AL,AH
        XOR     AH,AH
        SUB     DI,8
        JA      BITSHFT
        JZ      ALIGNED

;To get here, we must have used a byte shift when we needed to shift less than
;8 bits. Now we must correct by 1 or 2 left shifts.

SHFLEF:
        SHL     DX,1
        RCL     CX,1
        RCL     BX,1
        RCL     AX,1
        INC     DI
        JNZ     SHFLEF          ;Until DI is back to zero (from -1 or -2)
        JMP     SHORT ALIGNED

BITSHFT:
        XCHG    CX,DI
        TEST    DL,3FH          ;See if we're shifting stuff off the end
        JZ      SHFRIG
        OR      DL,20H          ;Set sticky bit if so
SHFRIG:
        SHR     AX,1
        RCR     BX,1
        RCR     DI,1
        RCR     DX,1
        LOOP    SHFRIG          ;Do 1 to 5 64-bit right shifts
        XCHG    CX,DI
ALIGNED:
        POP     SI              ;Address of larger operand
        XCHG    AX,DI
        TEST    DL,3FH          ;Collapse LSBs into sticky bit
        JZ      GETSIGN
        OR      DL,20H          ;Set sticky bit
GETSIGN:
        POP     AX              ;Recover sign and exponent
        SHL     AL,1            ;Shift sign bits out to test

;Now AL = sign of larger ( = tentative sign of result)
;Carry = sign of smaller.
;Overflow flag is set if these two are different.

        JO      SUBMAN          ;Subtract mantissas if signs are different
        ADD     DH,[SI]
        ADC     CX,[SI+1]
        ADC     BX,[SI+3]
        PUSHF                   ;Save carry flag
        MOV     SI,[SI+5]
        OR      SI,8000H        ;Set implied bit
        POPF
        ADC     DI,SI
        JNC     ROUNDJ
;Have a carry, so result must be shifted right and exponent incremented
        RCR     DI,1 
        RCR     BX,1 
        RCR     CX,1 
        RCR     DX,1 
        INC     AH              ;Bump exponent
ROUNDJ: JNZ     ROUND
        JMP     $OVFL

SUBMAN:
;Subtract mantissas since signs are different. We'll be subtracting in larger
;from smaller, so sign will be inverted first.
        NOT     AL
        SUB     DH,[SI]
        SBB     CX,[SI+1]
        SBB     BX,[SI+3]
        PUSHF                   ;Save carry flag
        MOV     SI,[SI+5]
        OR      SI,8000H        ;Set implied bit
        POPF
        SBB     DI,SI
        JNC     NORM            ;Won't carry if we mixed up larger and smaller
;As expected, we got a carry which means we must negate the result
        XOR     SI,SI           ;We'll need a zero
        NOT     AL              ;Flip sign bit
        NOT     DI
        NOT     BX
        NOT     CX
        NEG     DX              ;Carry clear if zero
        CMC
        ADC     CX,SI
        ADC     BX,SI
        ADC     DI,SI
$DNORM:
NORM:
        MOV     SI,4            ;Maximum of 4 word shifts
DNOR:
        OR      DI,DI           ;See if any bits on in high word
        JNZ     HIBYT           ;If so, go check high byte for zero
        SUB     AH,16           ;Drop exponent by shift count
        JBE     ZERO
        DEC     SI
        JZ      ZERO
        MOV     DI,BX
        MOV     BX,CX
        MOV     CX,DX
        XOR     DX,DX
        JMP     DNOR
HIBYT:
        TEST    DI,0FF00H       ;See if high byte is zero
        JNZ     NORMSHF
        SUB     AH,8            ;Drop exponent by shift amount
        JBE     ZERO
        XCHG    AX,DI
        MOV     AH,AL
        MOV     AL,BH
        MOV     BH,BL
        MOV     BL,CH
        MOV     CH,CL
        MOV     CL,DH
        MOV     DH,DL
        MOV     DL,0
        OR      AH,AH
        XCHG    AX,DI
NORMSHF:
        JS      ROUND           ;Normalize complete?
NORMLP:
        DEC     AH              ;Account for shift in exponent
        JZ      ZERO
        SHL     DX,1
        RCL     CX,1
        RCL     BX,1
        RCL     DI,1
        JNO     NORMLP          ;Overflow will be set when sign bit changes

$DROUND:
ROUND:
        CMP     DL,80H          ;Check extended bits
        JA      ROUNDUP
        JB      SAVE
;Extended bits equal exactly one-half LSB, so round even
        TEST    DH,1            ;Already even?
        JZ      SAVE
ROUNDUP:
        ADD     DH,1
        ADC     CX,0
        ADC     BX,0            ;Propagate carry
        ADC     DI,0
        JNC     SAVE            ;Overflow?
;If we overflowed, DI:BX:CX:DH must now be zero, so we can leave it that way.
        INC     AH              ;Increment exponent
        JZ      OVERFLOW
SAVE:
        AND     AL,80H          ;Strip to sign bit
        XCHG    BX,DI
        AND     BH,7FH          ;Mask off implied bit
        OR      AL,BH           ;Combine sign with mantissa
        MOV     [$DAC+6],AX
        MOV     [$FAC-2],BL
        MOV     BX,DI
        MOV     DI,OFFSET DC:$DAC
        MOV     AL,DH
        STOSB
        XCHG    AX,CX
        STOSW
        XCHG    AX,BX
        STOSW
        RET

OVCHK:
        JNS     ZERO
OVERFLOW:
        JMP     $OVFL

ZERO:
        MOV     [$FAC],0
        RET


$FMUD:
        MOV     SI,OFFSET DC:$DAC
        JMP     SHORT $FMUB
$FMUH:
        CALL    $GTMP
$FMUF:
        MOV     DI,OFFSET DC:$DAC
$FMUB:
        CALL    $SAVREG

        SUBTTL  $DMUL - Double precision multiply
; Inputs:
;       SI = Address of one operand
;       DI = Address of other operand
; Function:
;       Multiply with result in FAC.
; Outputs:
;       Result in FAC.
; Registers:
;       Uses ALL.

$DMUL:
        MOV     AX,[SI+6]       ;High part of op1
        OR      AH,AH
        JZ      ZERO
        MOV     CX,[DI+6]       ;High part of op2
        OR      CH,CH
        JZ      ZERO
        XOR     AL,CL           ;Compute sign

;Exponent computation.
;Compute sum of exponents minus one. The minus one is valid if the product
;will need normalization by one bit. If it doesn't, one will be added to the
;exponent. A zero exponent will temporarily be OK because of this possibility
;of adding one later.

        SUB     AH,128+1        ;Subtract bias and extra "minus one"
        SUB     CH,128
        ADD     AH,CH           ;Add exponents
OVCHKJ: JO      OVCHK           ;If overflow, check whether up or down
        ADD     AH,128          ;Put bias back in
        PUSH    AX              ;Save sign and tentative exponent
        CALL    PMULD           ;Multiply mantissas
        JZ      NORMCHK         ;Need to set sticky bit?
        OR      DL,1
NORMCHK:
        POP     AX              ;Get exp. and sign back
        OR      DI,DI           ;See if normalized
        JS      INCEXP          ;Yes - increment exponent
        SHL     DX,1            ;Normalize
        RCL     CX,1
        RCL     BX,1
        RCL     DI,1
        OR      AH,AH           ;Is exponent zero?
        JNZ     RNDJMP
        JMP     ZERO

INCEXP:
        INC     AH
        JZ      OVERFLOW
RNDJMP: JMP     ROUND


$FDVD:
        MOV     SI,OFFSET DC:$DAC
        JMP     SHORT $FDVB
$FDVH:
        CALL    $GTMP
$FDVF:
        MOV     DI,OFFSET DC:$DAC
$FDVB:
        CALL    $SAVREG

        SUBTTL  $DDIV - Double precision divide
; Inputs:
;       SI = Address of Dividend (Numerator)
;       DI = Address of Divisor (Denominator)
; Function:
;       Compute [SI] / [DI]
; Outputs:
;       Result in FAC.
; Registers:
;       All destroyed.

$DDIV:
        MOV     AX,[SI+6]       ;High half of numerator
        MOV     CX,[DI+6]       ;High half of denominator
        XOR     AL,CL           ;Compute sign
        OR      CH,CH           ;Denominator zero?
        JZ      DIV0
        OR      AH,AH           ;Numerator zero?
        JZ      ZERO
        SUB     AH,128          ;Remove bias from exponents
        SUB     CH,128
        SUB     AH,CH           ;Compute result exponent
        JO      OVCHKJ

;AH has the (tentative) true exponent of the result. It is correct if the
;result needs normalizing one bit. If not, 1 will be added to it. A true
;exponent of -128, not normally allowed except to represent zero, is OK
;here because of this possible future incrementing.

        ADD     AH,128          ;Put bias back
        PUSH    AX              ;Save sign and exponent
        LODSB                   ;Load up dividend
        MOV     CH,AL
        XOR     CL,CL
        LODSW
        XCHG    AX,BX
        LODSW
        XCHG    AX,DX
        LODSW
        OR      AH,80H          ;Set implied bit
        XCHG    AX,DX           ;Divisor in DX:AX:BX:CX

;Move divisor to FAC so we can get at it easily. More importantly, get it in
;the necessary form - extended to 64 bits with zeros, implied bit set.
;The form we want it in will have the mantissa MSB where the exponent usually
;is, so by moving high to low we will not destroy the divisor even if it is
;already in the FAC.

        MOV     SI,DI
        ADD     SI,5            ;Point to high end of divisor
        MOV     DI,OFFSET DC:$FAC-1
        STD                     ;Direction DOWN
        MOVSW                   ;Move divisor to FAC
        MOVSW
        MOVSW
        INC     SI
        INC     DI
        MOVSB
        CLD                     ;Restore direction
        MOV     BYTE PTR[DI],0  ;Extend to 64 bits with a zero
        OR      [$FAC],80H      ;Set implied bit

;Now we're all set:
;       DX:AX:BX:CX has dividend
;       FAC has divisor (not in normal format)
;Both are extended to 64 bits with zeros and have implied bit set.
;Top of stack has sign and tentative exponent.

        SHR     DX,1            ;Make sure dividend is smaller than divisor
        RCR     AX,1            ;   by dividing it by two
        RCR     BX,1
        RCR     CX,1
        CALL    DIV16           ;Get a quotient digit
        PUSH    DI
        CALL    DIV16
        PUSH    DI
        CALL    DIV16
        PUSH    DI
        CALL    DIV16
        OR      AX,BX           ;Remainder zero?
        OR      AX,CX
        OR      AX,DX
        MOV     DX,DI           ;Get lowest word in position
        JZ      NSTK1
        OR      DL,1            ;Set sticky bit if not
NSTK1:
        POP     CX              ;Recover quotient digits
        POP     BX
        POP     DI
        JMP     NORMCHK

DIV0:   JMP     $DIV0

DIV16:
        MOV     SI,[$DAC+6]     ;Get high word of divisor
        XOR     DI,DI           ;Initialize quotient digit to zero
        CMP     DX,SI           ;Will we overflow?
        JAE     MAXQUO          ;If so, go handle special
        OR      DX,DX           ;Is dividend small?
        JNZ     DODIV
        CMP     SI,AX           ;Will divisor fit at all?
        JA      ZERQUO          ;No - quotient is zero
DODIV:
        DIV     SI              ;AX is our digit "guess"
        PUSH    DX              ;Save remainder
        XCHG    AX,DI           ;Quotient digit in DI
        XOR     BP,BP           ;Initialize quotient * divisor
        MOV     SI,BP
        MOV     AX,[$DAC]
        OR      AX,AX           ;If zero, save multiply time
        JZ      REM2
        MUL     DI              ;Begin computing quotient * divisor
        MOV     SI,DX
REM2:
        PUSH    AX              ;Save lowest word of quotient * divisor
        MOV     AX,[$DAC+2]
        OR      AX,AX
        JZ      REM3
        MUL     DI
        ADD     SI,AX
        ADC     BP,DX
REM3:
        MOV     AX,[$DAC+4]
        OR      AX,AX
        JZ      REM4
        MUL     DI
        ADD     BP,AX
        ADC     DX,0
        XCHG    AX,DX
REM4:                           ;Quotient * divisor in AX:BP:SI:[SP]
        POP     DX              ;Recover lowest word of quotient * divisor
        NEG     DX              ;Subtract from dividend
        SBB     CX,SI
        SBB     BX,BP
        POP     BP              ;Remainder from DIV
        SBB     BP,AX
        XCHG    AX,BP
ZERQUO:                         ;Remainder in AX:BX:CX:DX
        XCHG    AX,DX
        XCHG    AX,CX
        XCHG    AX,BX
        JNC     RET             ;Remainder in DX:AX:BX:CX
RESTORE:
        DEC     DI              ;Drop quotient since it didn't fit
        ADD     CX,[$DAC]       ;Add divisor back in until remainder goes +
        ADC     BX,[$DAC+2]
        ADC     AX,[$DAC+4]
        ADC     DX,[$DAC+6]
        JNC     RESTORE
RET:    RET

MAXQUO:
        DEC     DI              ;DI=FFFF=2**16-1
        SUB     CX,[$DAC]
        SBB     BX,[$DAC+2]
        SBB     AX,[$DAC+4]
        ADD     CX,[$DAC+2]
        ADC     BX,[$DAC+4]
        ADC     AX,DX
        MOV     DX,[$DAC]
        CMC
        JMP     ZERQUO


        SUBTTL  PMULD - Partial DP multiply

; Inputs:
;       SI = Address of multiplicand
;       DI = Address of multiplier
; Function:
;       Multiply mantissas and provide unrounded 64 bit result.
; Outputs:
;       Result in DI:BX:CX:DX.
;       SI is non-zero (flags set accordingly) if not exact result
; Registers:
;       Uses ALL.

PMULD:
        MOV     AL,[SI+6]       ;Get most significant mantissa byte
        MOV     AH,0            ;Extend with a zero
        OR      AL,80H          ;Set implied bit
        MOV     [OP1MAN],AX     ;Save for easy access
        MOV     AL,[DI+6]
        MOV     AH,0
        OR      AL,80H
        MOV     [OP2MAN],AX     ;Second operand similarly prepared

; Perform multiply by summing partial products of 16x16 hardware multiply.
; Before each multiply, the operands are checked for zero to see if it can be
; skipped, since it's a slow operation on the 8086. The sum is kept in
; registers as much as possible. Any insignificant bits lost are ORed together
; and kept in a word on the top of the stack. This can be used for sticky bit
; rounding.

        XOR     BX,BX
        MOV     BP,BX
        MOV     CX,[SI]
        JCXZ    PROD3           ;Skip 2 multiplies if zero
        XCHG    AX,CX
        MOV     CX,[DI]
        JCXZ    PROD2
        MUL     CX
        MOV     BP,AX           ;Save insignificant bits
        MOV     CX,DX
        MOV     AX,[SI]
PROD2:                          ;Partial result in CX
        MOV     DX,[DI+2]
        OR      DX,DX
        JZ      PROD3
        MUL     DX
        ADD     CX,AX
        ADC     BX,DX
PROD3:                          ;Partial result in BX:CX
        PUSH    BP              ;Save insignificant bits on stack
        XOR     BP,BP
        MOV     AX,[SI+2]
        OR      AX,AX
        JZ      PROD4
        MOV     DX,[DI]
        OR      DX,DX
        JZ      PROD4
        MUL     DX
        ADD     CX,AX
        ADC     BX,DX
        RCL     BP,1            ;Pick up carry
PROD4:                          ;Partial result in BP:BX:CX
        POP     AX
        OR      AX,CX           ;Record these bits before we throw them away
        PUSH    AX
        MOV     AX,[SI+2]
        OR      AX,AX
        JZ      PROD5
        MOV     DX,[DI+2]
        OR      DX,DX
        JZ      PROD5
        MUL     DX
        ADD     BX,AX
        ADC     BP,DX
PROD5:                          ;Partial result in BP:BX
        XOR     CX,CX
        MOV     AX,[SI]
        OR      AX,AX
        JZ      PROD6
        MOV     DX,[DI+4]
        OR      DX,DX
        JZ      PROD6
        MUL     DX
        ADD     BX,AX
        ADC     BP,DX
        RCL     CX,1
PROD6:                          ;Partial result in CX:BP:BX
        MOV     AX,[SI+4]
        OR      AX,AX
        JZ      PROD7
        MOV     DX,[DI]
        OR      DX,DX
        JZ      PROD7
        MUL     DX
        ADD     BX,AX
        ADC     BP,DX
        ADC     CX,0
PROD7:                          ;Partial result in CX:BP:BX
        POP     AX
        OR      AX,BX
        PUSH    AX
        MOV     AX,[SI]
        OR      AX,AX
        JZ      PROD8
        MUL     [OP2MAN]
        ADD     BP,AX
        ADC     CX,DX
PROD8:                          ;Partial result in CX:BP
        MOV     AX,[DI]
        OR      AX,AX
        JZ      PROD9
        MUL     [OP1MAN]
        ADD     BP,AX
        ADC     CX,DX
PROD9:                          ;Partial result in CX:BP
        XOR     BX,BX
        MOV     AX,[SI+2]
        OR      AX,AX
        JZ      PROD10
        MOV     DX,[DI+4]
        OR      DX,DX
        JZ      PROD10
        MUL     DX
        ADD     BP,AX
        ADC     CX,DX
        RCL     BX,1
PROD10:                         ;Partial result in BX:CX:BP
        MOV     AX,[SI+4]
        OR      AX,AX
        JZ      PROD11
        MOV     DX,[DI+2]
        OR      DX,DX
        JZ      PROD11
        MUL     DX
        ADD     BP,AX
        ADC     CX,DX
        ADC     BX,0
PROD11:                         ;Partial result in BX:CX:BP
        PUSH    BP              ;Not enough registers to keep LSW
        XOR     BP,BP
        MOV     AX,[DI+2]
        OR      AX,AX
        JZ      PROD12
        MUL     [OP1MAN]
        ADD     CX,AX
        ADC     BX,DX
PROD12:                         ;Partial result in BP:BX:CX
        MOV     AX,[SI+2]
        OR      AX,AX
        JZ      PROD13
        MUL     [OP2MAN]
        ADD     CX,AX
        ADC     BX,DX
PROD13:                         ;Partial result in BP:BX:CX
        MOV     AX,[SI+4]
        OR      AX,AX
        JZ      PROD15
        MOV     DX,[DI+4]
        OR      DX,DX
        JZ      PROD14
        MUL     DX
        ADD     CX,AX
        ADC     BX,DX
        RCL     BP,1
        MOV     AX,[SI+4]
PROD14:                         ;Partial result in BP:BX:CX
        MUL     [OP2MAN]
        ADD     BX,AX
        ADC     BP,DX
PROD15:                         ;Partial result in BP:BX:CX
        MOV     AX,[DI+4]
        OR      AX,AX
        JZ      PROD16
        MUL     [OP1MAN]
        ADD     BX,AX
        ADC     BP,DX
PROD16:                         ;Partial result in BP:BX:CX
        MOV     AL,BYTE PTR[OP1MAN]
        MUL     BYTE PTR[OP2MAN]
        ADD     AX,BP
        XCHG    AX,DI
        POP     DX              ;Get least significant bits
        POP     SI              ;Get trimmed bits
        OR      SI,SI           ;Set flags
        RET

CODE    ENDS
        END
