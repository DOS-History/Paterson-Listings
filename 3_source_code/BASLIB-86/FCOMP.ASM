        TITLE   FCOMP - Floating point compare

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $AC:WORD, $DAC:WORD

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $FCMA,$FCMB,$FCMC,$FCMD,$FCME,$FCMF,$FCMG,$FCMH
        PUBLIC  $SCMP, $DCMP

        EXTRN   $SAVREG:NEAR, $GTMP:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


$FCMD:
        MOV     SI,OFFSET DC:$DAC
        JMP     SHORT $FCMB
$FCMH:
        CALL    $GTMP
$FCMF:
        MOV     DI,OFFSET DC:$DAC
$FCMB:
        CALL    $SAVREG

;***  $SCMP and $DCMP - Single and double precision comparison
;
; Inputs:
;       SI = Address of first operand
;       DI = Address of second operand
; Function:
;       Set Carry and Zero flags based on [SI] - [DI] :
;       [SI] > [DI]     Carry and zero clear
;       [SI] < [DI]     Carry set and zero clear
;       [SI] = [DI]     Carry clear and zero set
; Outputs:
;       Zero and carry flags have result
; Registers:
;       Destroys all except BP.

$DCMP:
        MOV     CX,4            ;Compare up to 4 words
        ADD     SI,6            ;Point to high word of operands
        ADD     DI,6
        JMP     SHORT CMP

$FCMC:
        MOV     SI,OFFSET DC:$AC
        JMP     SHORT $FCMA
$FCMG:
        CALL    $GTMP
$FCME:
        MOV     DI,OFFSET DC:$AC
$FCMA:
        CALL    $SAVREG

$SCMP:
        MOV     CX,2            ;Compare up to two words
        ADD     SI,CX           ;Point to high word of operands
        ADD     DI,CX
CMP:
        MOV     AX,[SI]         ;Get exponent and sign of op1
        MOV     BX,[DI]         ;And op2
        OR      BH,BH           ;Second operand zero?
        JZ      Z2
        OR      AH,AH           ;First operand zero?
        JZ      Z1
        XOR     BL,AL           ;Are signs the same?
        RCL     AL,1            ;Put sign of op1 in carry (doesn't change SF)
        JS      RET             ;Exit if signs different
        JNC     MAGCMP          ;Comparing positive numbers?
        XCHG    SI,DI           ;If not, look for smallest magnitude
MAGCMP:
        STD
        REPE    CMPSW           ;Compare magnitudes
        CLD
        RET

Z1:
;First operand is zero
        OR      BH,BH           ;Insure zero flag not set
        RCL     BL,1            ;Put sign bit in carry
        CMC
        RET

Z2:
;Second operand is zero
        OR      AH,AH           ;Is first operand zero too?
        JZ      RET             ;If so, they're equal
        RCL     AL,1            ;Put sign bit in carry
RET:    RET

CODE    ENDS
        END
