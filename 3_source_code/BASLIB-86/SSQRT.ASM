        TITLE   SSQRT - Single precision square root

; by Tim Paterson  7/17/81

; The algorithm used here is several times faster than Netwon-Raphson
; iteration. The only references I know of this algorithm are in the context
; of hardware implementation, and do not discuss how it works. It is used,
; for example, in the Intel 8087 math processor, which is why that chip
; can square root faster than it divides.

; The algorithm is similar to restoring division. The input argument would
; be the dividend. A "guess" is made of a divisor bit, and if the corresponding
; quotient bit is the same, the guess is correct. The divisor and quotient are
; thus determined simultaneously, bit by bit. Since they are kept equal, they
; represent the square root of the dividend.
;
; The trick is that when changes are made to the divisor, the present remainder
; must be corrected as if the divisor had always had that value. Because we
; are using binary numbers, this correction turns out to be very simple.

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FAC:BYTE, $AC:BYTE

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $SQR,$SSQRT

        EXTRN   $ERC_FC:NEAR,$SAVREG:NEAR

        ASSUME  CS:CODE, DS:DC


;***  $SQR - Single precision square root
;
; Inputs:
;       BX = Address of argument
; Outputs:
;       Result in the FAC
; Registers:
;       Only F affected

$SQR:
        CALL    $SAVREG
$SSQRT:
        MOV     DX,[BX+1]       ;Get sign & high 15 mantissa bits
        OR      DH,DH           ;Test sign bit
        JS      NEGNUM          ;No negative numbers
        MOV     AL,[BX+3]       ;Get exponent
        OR      AL,AL           ;Test for zero
        JZ      ZERO            ;SQR(0)=0
        MOV     BH,[BX]         ;Get low mantissa byte
        MOV     BL,0            ;Extend to 32 bits
        OR      DH,80H          ;Set implied bit
        SHR     AL,1            ;Divide exponent by two
        JNC     EVENEXP         ;Exponent odd?
        SHR     DX,1            ;Half mantissa if exponent odd
        RCR     BX,1
        STC                     ;Round up exponent
EVENEXP:
        ADC     AL,64           ;Add back half the bias
        MOV     [$FAC],AL       ;Save final exponent
        MOV     CX,25           ;24 bits plus one for rounding
        XOR     BP,BP           ;Clear registers
        MOV     SI,BP
        MOV     DI,BP
        MOV     AX,BP
ROOTLP:
        SHL     BX,1            ;64-bit left shift of input
        RCL     DX,1
        RCL     DI,1
        RCL     BP,1
        SHL     BX,1            ;Shift it twice
        RCL     DX,1
        RCL     DI,1
        RCL     BP,1
        STC                     ;Set test bit
        RCL     SI,1            ;Rotate it in to partial
        RCL     AX,1
        SUB     DI,SI           ;See if test bit fits
        SBB     BP,AX
        JNC     ROOTBIT
        ADD     DI,SI           ;Didn't fit - restore
        ADC     BP,AX
        DEC     SI              ;Reset test bit
        LOOP    ROOTLP
ROUND:
        SHR     AX,1            ;Half to a 25-bit result
        RCR     SI,1
        SHR     AX,1            ;To a 24-bit result
        RCR     SI,1
        ADC     SI,0            ;Round up if a 1 was shifted out
        ADC     AX,0            ;Propagate carry
        MOV     WORD PTR[$FAC-3],SI
        AND     AL,7FH          ;Reset implied bit
        MOV     [$FAC-1],AL
DONE:   RET

NEGNUM: JMP     $ERC_FC         ;Illegal function call if negative argument

ZERO:   MOV     [$FAC],0
        RET

ROOTBIT:
        INC     SI              ;Set real result bit
        LOOP    ROOTLP
        JMP     ROUND

CODE    ENDS
        END
