        TITLE   SMATH - Single precision floating point arithmetic

; Single precision add, subtract, multiply and divide for the 8086.
;
; by Tim Paterson  July, 1981
;
; Each routine has four entry points:
;
; Suffix A means address of operands in SI and DI
; Suffix C means first operand is FAC, second is at [DI] (SI smashed)
; Suffix E means first operand is at [SI], second is FAC (DI smashed)
; Suffix G means first operand is floating temp, second is FAC (SI and DI hit)
;
; These entry points set up SI and DI to point to the least significant byte
; of the two operands in standard Microsoft floating point format, then fall
; into the arithmetic routine. Except for possible set up of SI or DI or both,
; all registers are preserved. The result is returned in the FAC.
;
; All operations are performed in 8086 registers. This means that either SI
; or DI or both may point to the result location ($AC). The operands in
; memory are not affected. No memory storage is used until the result is
; stored.
;
; These routines are completely accurate, rounded to 24 bit precision using
; IEEE floating point standard rounding rules. These rounding rules require
; maintaining a "sticky bit", which is set whenever insignificant bits are
; lost. If a result is exactly halfway between two representable values, we
; "round even"--so that the LSB of the result is zero. For this to happen,
; the sticky bit must be zero.

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $AC:WORD, $FAC:BYTE

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT WORD PUBLIC 'CODE'

        PUBLIC  $FADA,$FADC,$FADE,$FADG,$FSUA,$FSUC,$FSUE,$FSUG
        PUBLIC  $FMUA,$FMUC,$FMUE,$FMUG,$FDVA,$FDVC,$FDVE,$FDVG
        PUBLIC  $SADD,$SSUB,$SMUL,$SDIV,$SNORM,$SRND,PMULS

        EXTRN   $OVFL:NEAR,$DIV0:NEAR,$GTMP:NEAR,$SAVREG:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


$FSUC:
        MOV     SI,OFFSET DC:$AC
        JMP     SHORT $FSUA
$FSUG:
        CALL    $GTMP
$FSUE:
        MOV     DI,OFFSET DC:$AC
$FSUA:
        CALL    $SAVREG

;***  $SSUB and $SADD - Single precision subtraction and addition
;
; Inputs:
;       SI = Address of Minuend or Addend
;       DI = Address of Subtrahend Or Addend
; Function:
;       FAC = [SI] - [DI]  or  FAC = [SI] + [DI]
; Outputs:
;       Result in FAC.
; Registers:
;       All except BP destroyed.

$SSUB:
        MOV     AX,[DI+2]       ;Get sign & exponent on subtrahend
        XOR     AL,80H          ;Invert its sign
        JMP     SHORT DOADD     ;   and just add

$FADC:
        MOV     SI,OFFSET DC:$AC
        JMP     SHORT $FADA
$FADG:
        CALL    $GTMP
$FADE:
        MOV     DI,OFFSET DC:$AC
$FADA:
        CALL    $SAVREG

$SADD:
        MOV     AX,[DI+2]       ;Get sign & exponent of one operand
DOADD:
        MOV     BX,[DI+1]       ;Get most significant 16 bits of mantissa
        MOV     DH,[DI]         ;Get least significant bits
        MOV     DL,0            ;Extend to 32 bits
        OR      BH,80H          ;Set implied bit
        MOV     CX,[SI+2]       ;Get sign & exponent of other operand
        MOV     DI,[SI-1]       ;High byte is least significant bits
        MOV     SI,[SI+1]       ;Most significant 16 bits of mantissa
        AND     DI,0FF00H       ;Extend mantissa to 32 bits with zeros
        OR      SI,8000H        ;Set implied bit

; At this point, the mantissa of first number is in BX:DX, with exponent
; and sign in AX. Second number has mantissa in SI:DI, with exponent and sign
; in CX. Note that these mantissas have been extended to 32 bits with a byte
; of zero and have the implied first bit set.

        OR      CH,CH
        JZ      SAVJ            ;If one is zero, return other
        OR      AH,AH
        JZ      SAV2
        CMP     CH,AH           ;See which number is larger
        JAE     SIGNFIDDLE      ;See if difference is non-negative

;Swap operands so smaller is in BX:DX

        XCHG    SI,BX
        XCHG    DI,DX           ;Swap mantissas
        XCHG    AX,CX           ;Swap exponents/signs

SIGNFIDDLE:
        SUB     AH,CH           ;Subtract exponents ( <=0 )
        NEG     AH
        CMP     AH,24           ;Is smaller argument significant?
        JA      SAV2
        SHL     AL,1            ;Put sign of smaller into carry
        RCR     CL,1            ;Now pack it in next to sign of larger
        XCHG    AX,CX
        MOV     CL,CH
        MOV     CH,0

; Now things look like this:
;       BX:DX has mantissa of smaller
;       SI:DI has mantissa of larger
;       AL bit 7 has sign of smaller
;       AL bit 6 has sign of larger
;       CL has exponent difference ( 0 <= CL <= 24 )
;       CH is zero
;       AH has exponent of larger ( = tentative exponent of result)

        JCXZ    ALIGNED         ;Already aligned?
        CMP     CL,14           ;Word shift possible?
        JL      BYTSHF
        OR      DX,DX
        JZ      NSTK
        OR      BL,1
NSTK:
        MOV     DX,BX
        XOR     BX,BX
        SUB     CL,16
        JB      SHFLEF
        JZ      ALIGNED
BYTSHF:
        CMP     CL,5            ;Do shifts >5 bits by byte rotate
        JLE     BITSHFT         ;Just shift bits if alignment close
        OR      DL,DL           ;See if we're shifting something off the end
        JZ      NOSTIK
        OR      DH,1            ;Ensure sticky bit will be set
NOSTIK:
        MOV     DL,DH           ;Do byte shift
        MOV     DH,BL
        MOV     BL,BH
        MOV     BH,CH           ;CH=0
        SUB     CL,8            ;Counts for 8 bit shifts
        JA      BITSHFT         ;If not enough, try again
        JZ      ALIGNED         ;Hit it exactly?

;To get here, we must have used a byte shift when we needed to shift less than
;8 bits. Now we must correct by 1 or 2 left shifts.

SHFLEF:
        SHL     DX,1
        RCL     BX,1
        INC     CL
        JNZ     SHFLEF          ;Until CL is back to zero (from -1 or -2)
        JMP     SHORT ALIGNED

SAV2:
        MOV     BX,SI
        MOV     DX,DI           ;Move mantissa to rounding registers
        MOV     AX,CX
SAVJ:   JMP     SAVE

BITSHFT:
        TEST    DL,3FH          ;See if we're shifting stuff off the end
        JZ      SHFRIG
        OR      DL,20H          ;Set sticky bit if so
SHFRIG:
        SHR     BX,1
        RCR     DX,1
        LOOP    SHFRIG          ;Do 1 to 5 32-bit right shifts
ALIGNED:
        TEST    DL,3FH          ;Collapse LSBs into sticky bit
        JZ      GETSIGN
        OR      DL,20H          ;Set sticky bit
GETSIGN:
        SHL     AL,1            ;Shift sign bits out to test

;Now AL = sign of larger ( = tentative sign of result)
;Carry = sign of smaller.
;Overflow flag is set if these two are different.

        JO      SUBMAN          ;Subtract mantissas if signs are different
        ADD     DX,DI           ;Add mantissas since signs are the same
        ADC     BX,SI
        JNC     ROUND
;Have a carry, so result must be shifted right and exponent incremented
        RCR     BX,1
        RCR     DX,1
        INC     AH              ;Bump exponent
        JNZ     ROUND
        JMP     $OVFL

SUBMAN:
;Subtract mantissas since signs are different
        SUB     DI,DX
        SBB     SI,BX
        MOV     DX,DI
        MOV     BX,SI
        JNC     NORM
;OOPS! Number we thought was bigger wasn't. Now we have to negate result.
        NOT     BX
        NEG     DX              ;Sets carry if not zero
        CMC                     ;Carry now set if zero
        ADC     BX,0            ;Propagate carry from Complement and Increment
        NOT     AL              ;Flip sign bit

$SNORM:
;Single precision normalize and store in $AC

NORM:
        OR      BX,BX           ;See if any bits on in high word
        JNZ     HIBYT           ;If so, go check high byte for zero
        SUB     AH,16           ;Drop exponent by shift count
        JBE     ZERO
        XCHG    BX,DX           ;Shift left 16 bits
        OR      BX,BX           ;See if all zero
        JZ      ZERO
HIBYT:
        OR      BH,BH           ;See if we can shift 8 bits
        JNZ     NORMSHF
        SUB     AH,8            ;Drop exponent by shift amount
        JBE     ZERO
        MOV     BH,BL           ;Do byte shift
        MOV     BL,DH
        MOV     DH,DL
        MOV     DL,0
        OR      BH,BH           ;See if normalized yet
NORMSHF:
        JS      ROUND           ;Normalize complete?
NORMLP:
        DEC     AH              ;Account for shift in exponent
        JZ      ZERO
        SHL     DX,1
        RCL     BX,1
        JNO     NORMLP          ;Overflow will be set when sign bit changes

$SRND:
;Round single precision and store in $AC

ROUND:
        CMP     DL,80H          ;Check extended bits
        JA      ROUNDUP
        JB      SAVE
;Extended bits equal exactly one-half LSB, so round even
        TEST    DH,1            ;Already even?
        JZ      SAVE
ROUNDUP:
        ADD     DH,1
        ADC     BX,0            ;Propagate carry
        JNC     SAVE            ;Overflow?
;If we overflowed, BX:DH must now be zero, so we can leave it that way.
        INC     AH              ;Increment exponent
        JZ      OVERFLOW
SAVE:
        AND     AL,80H          ;Strip to sign bit
        AND     BH,7FH          ;Mask off implied bit
        OR      AL,BH           ;Combine sign with mantissa
        MOV     [$AC+2],AX
        MOV     AH,BL
        MOV     AL,DH
        MOV     [$AC],AX        ;Save lower part of mantissa
        RET

OVCHK:
        JNS     ZERO
OVERFLOW:
        JMP     $OVFL

ZERO:
        MOV     $FAC,0          ;Zero the exponent to return value of zero
        RET


$FMUC:
        MOV     SI,OFFSET DC:$AC
        JMP     SHORT $FMUA
$FMUG:
        CALL    $GTMP
$FMUE:
        MOV     DI,OFFSET DC:$AC
$FMUA:
        CALL    $SAVREG

;***  $SMUL - Single precision multiply
;
; Inputs:
;       SI = Address of one operand
;       DI = Address of other operand
; Function:
;       FAC = [SI] * [DI]
; Outputs:
;       Result in FAC.
; Registers:
;       All but BP destroyed.

$SMUL:
        LODSW                   ;Low part of op1
        MOV     SI,[SI]         ;High part of op1
        XCHG    AX,SI
        OR      AH,AH
        JZ      ZERO
        MOV     CX,[DI+2]       ;High part of op2
        OR      CH,CH
        JZ      ZERO
        MOV     DI,[DI]         ;Low part of op2
        MOV     BX,AX           ;Duplicate hight part of op1
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
        CALL    PMULS           ;Multiply mantissas
        MOV     DX,BX
        XCHG    AX,BX           ;Result in BX:DX
NORMCHK:
        POP     AX              ;Get exp. and sign back
        OR      BH,BH           ;See if normalized
        JS      INCEXP          ;Yes-increment exponent
        SHL     DX,1            ;Normalize
        RCL     BX,1
        OR      AH,AH           ;Is exponent zero?
        JNZ     ROUND
ZEROJ:  JMP     ZERO
INCEXP:
        INC     AH
        JZ      OVERFLOW
        JMP     ROUND


;***  PMULS - Partial SP multiply
;
; Inputs:
;       BL:SI has op1 mantissa
;       CL:DI has op2 mantissa (implied bit need NOT be set)
; Function:
;       Multiply mantissas and provide unrounded 32 bit result.
;       Last bit is sticky bit.
; Outputs:
;       Result is in AX:BX
; Registers:
;       All except BP used.

PMULS:
        MOV     BH,0           ;Extend high end of mantissa
        MOV     CH,BH          ;   for both operands
        OR      BL,80H         ;Set implied bit
        OR      CL,80H

;Multiply mantissas by summing partial products (using 16x16 multiply)
;       BX:SI has op1
;       CX:DI has op2
;Both are extended to 32 bits with leading zeros and have implied bit set

        PUSH    BX
        PUSH    BX             ;We'll need these later
        MOV     AX,SI          ;Low part of op1
        MUL     DI             ;Times low part of op2
        MOV     BX,DX          ;Save only high half
        OR      AX,AX          ;See if we're losing some bits
        POP     AX             ;Get high part of op1
        PUSHF                  ;Save flags indicating losing bits
        MUL     DI             ;Time low part of op2
        ADD     BX,AX          ;Sum partial products
        ADC     DX,0           ;Propogate carry
        MOV     DI,DX          ;Save high part of result
        MOV     AX,CX          ;High part of op2
        MUL     SI             ;Times low part of op1
        ADD     BX,AX          ;32-bit sum of partial products
        ADC     DI,DX
        POPF                   ;Did we drop some low order bits?
        JZ      NSTK2
        OR      BL,1           ;Set sticky bit if so
NSTK2:
        POP     AX             ;High part of op1 again
        MUL     CL             ;Finally! Most significant partial product
        ADD     AX,DI          ;Result now in AX:BX
        RET


$FDVC:
        MOV     SI,OFFSET DC:$AC
        JMP     SHORT $FDVA
$FDVG:
        CALL    $GTMP
$FDVE:
        MOV     DI,OFFSET DC:$AC
$FDVA:
        CALL    $SAVREG

;***  $SDIV - Single precision divide
;
; Inputs:
;       SI = Address of Dividend (Numerator)
;       DI = Address of Divisor (Denominator)
; Function:
;       FAC = [SI] / [DI]
; Outputs:
;       Result in FAC.
; Registers:
;       All except BP destroyed.

$SDIV:
        MOV     CX,[DI+2]       ;Exponent and sign of denominator
        MOV     AX,[SI+2]       ;Exponent and sign of numerator
        OR      CH,CH           ;Denominator zero?
        JZ      DIV0
        OR      AH,AH           ;Numerator zero?
        JZ      ZEROJ
        XOR     AL,CL           ;Compute sign
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
        OR      CL,80H          ;Set implied bit
        MOV     DX,[SI+1]       ;Most significant part of numerator mantissa
        MOV     AH,[SI]         ;Least significant part
        XOR     AL,AL           ;Extend with zero
        OR      DH,80H          ;And set implied bit
        MOV     BX,[DI+1]       ;Load denominator into BX:CX
        MOV     CH,[DI]
        XOR     CL,CL
        OR      BH,80H

;Now we have the following configuration:
;       Numerator in DX:AX
;       Denominator in BX:CX
; Both are extended to 32 bits with trailing zeros and have implied bit set
;       Result will go in BX:DX
;
;The algorithm used here is similar to Algorithm D, p.237, Knuth vol. 2.
;It is basically just ordinary long division, except the base is 2^16. This
;means we are dividing two 2-digit numbers, where each "digit" takes a whole
;word. We "guess" at a quotient digit, multiply it by the divisor, and subtract
;from the current dividend to get a remainder. This remainder could be
;negative, so we try a quotient digit one smaller.
;
;The "guess" at the quotient digit simply uses the 8086 DIV instruction.
;Computing the remainder takes advantage of the remainder from this divide. If
;the remainder comes out negative, new quotient digits are tried by repeated
;addition, rather than another multiply. Theorem B on p.237 of Knuth vol. 2
;guarantees that this repeated addition will happen no more than twice.

        SHR     DX,1
        RCR     AX,1            ;Ensure DX<BX so divide won't overflow
        CALL    DIV16           ;Get first 16 bits of quotient
        PUSH    SI              ;Save high half of quotient on stack
        CALL    CDIV16          ;Get second 16 bits of quotient
        OR      AX,DX           ;Remainder 0?
        MOV     DX,SI           ;Want low half of result in DX
        JZ      NSTK1
        OR      DL,1            ;Set sticky bit if remainder not zero
NSTK1:
        POP     BX              ;Recover high half of result
        JMP     NORMCHK

DIV0:   JMP     $DIV0

CDIV16:
        CMP     DX,BX           ;Will we overflow on divide?
        JAE     MAXQUO          ;Special code for maximum quotient
DIV16:
        DIV     BX              ;32 by 16 bit division
        XCHG    AX,SI           ;Put 16-bit quotient in SI
        XOR     AX,AX           ;DX:AX has remainder
        JCXZ    RETJ            ;Is this complete result?
        MOV     DI,DX           ;Save remainder while we multiply
        MOV     AX,SI
        MUL     CX              ;Low half of divisor times quotient
        NEG     AX              ;Subtract from remainder, whose low half is 0
        SBB     DI,DX
        MOV     DX,DI           ;Remainder again in DX:AX
        JNC     RETJ            ;If not negative, divide was good
RESTORE:
        DEC     SI              ;Quotient is too big
        ADD     AX,CX           ;And remainder too small (negative)
        ADC     DX,BX           ;So add divisor back in till positive
        JNC     RESTORE
RETJ:   RET

MAXQUO:
;Come here if divide instruction would overflow. This must mean that DX=BX,
;i.e., the high half of the divisor and dividend are equal. Assume a result
;of (2^16)-1, which will give us a remainder equal to divisor plus (low half
;of dividend minus low half of divisor, times 2^16).

        MOV     SI,-1           ;Quotient of (2^16)-1
        SUB     AX,CX           ;Dividend - divisor (always negative)
        ADD     DX,AX           ;Add to high half of divisor
        MOV     AX,CX
        JNC     RESTORE         ;Carry means it's not negative any more
        RET

CODE    ENDS
        END
