        TITLE   DLOG - Double precision natural logarithm

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $DAC:WORD, $FAC:BYTE, $ARG:WORD

DATA    ENDS


CONST   SEGMENT WORD PUBLIC 'CONST'

        EXTRN   $DBLONE:WORD, $DHALFLN2:WORD, $DHALFSQR2:WORD

;Coefficient tables for Hart's 2665. Absolute error 16.52,
;range [1/SQRT(2),SQRT(2)]. LOG(x) = zP(z^2), z=(x-1)/(x+1)
; These constants have been checked with MuMath

LOGTAB  DW      6                                       ;Degree 6 polynomial
        DB      0F8H,0F9H,076H,0DEH,0B8H,08CH,02DH,07EH ;+0.16948212488
        DB      04DH,09EH,0CEH,0BFH,0D9H,075H,039H,07EH ;+0.1811136267967
        DB      035H,0BBH,041H,060H,06BH,092H,063H,07EH ;+0.22223823332791
        DB      032H,066H,0C6H,00EH,01EH,049H,012H,07FH ;+0.2857140915904889
        DB      0FBH,0EBH,028H,0D7H,0CCH,0CCH,04CH,07FH ;+0.400000001206045365
        DB      0A3H,009H,0A7H,0AAH,0AAH,0AAH,02AH,080H ;+0.6666666666633660894
        DB      02FH,000H,000H,000H,000H,000H,000H,082H ;+2.00000000000000261007

CONST   ENDS


DC      GROUP DATA,CONST


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC $LOD,$DLOG

        EXTRN  $DMUL:NEAR, $DPOLYX:NEAR, $DADD:NEAR, $DSUB:NEAR, $DDIV:NEAR
        EXTRN  $SAVREG:NEAR, $ERC_FC:NEAR, $CIDA:FAR

        ASSUME CS:CODE, DS:DC, ES:DC


;***  $LOG - LOG (base e) function
;
; Inputs:
;       BX = Address of operand
; Outputs:
;       Result in FAC
; Registers:
;       Only F affected.

$LOD:
        CALL    $SAVREG
$DLOG:
        MOV     SI,BX
        MOV     DI,OFFSET DC:$DAC
        MOVSW                   ;Put operand in FAC
        MOVSW
        MOVSW
        LODSW
        STOSW
        OR      AH,AH           ;Taking log of zero?
        JZ      ARGERR
        OR      AL,AL           ;Log of negative number?
        JS      ARGERR
        MOV     [$FAC],81H      ;Assign true exponent of 1
        MOV     AL,AH           ;Convert exponent to 16-bit integer
        SUB     AL,80H          ;   Remove bias
        CBW
        PUSH    AX
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$DHALFSQR2
        CALL    $DMUL           ;X now in [1/SQRT(2),SQRT2)
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$DBLONE
        CALL    $DADD
        MOV     SI,OFFSET DC:$DBLONE
        MOV     DI,OFFSET DC:$DAC
        CALL    $DDIV           ;DAC = 1 / (Y+1)
        INC     [$FAC]          ;DAC = 2 / (Y+1)
        MOV     SI,OFFSET DC:$DBLONE
        MOV     DI,OFFSET DC:$DAC
        CALL    $DSUB           ;DAC = 1-[2/(Y+1)] = (Y-1)/(Y+1)
        MOV     BX,OFFSET DC:LOGTAB
        CALL    $DPOLYX
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$ARG
        MOVSW                   ;Copy partial result to ARG
        MOVSW
        MOVSW
        MOVSW
        POP     BX              ;Recover exponent (as integer)
        SHL     BX,1            ;Count by halves
        DEC     BX              ;Take out 1/2 because of SQRT(2) factor
        CALL    $CIDA           ;Convert it to D.P.
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$DHALFLN2
        CALL    $DMUL           ;Convert our LOG2 to LOGe
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$ARG
        JMP     $DADD

ARGERR: JMP     $ERC_FC

CODE    ENDS
        END
