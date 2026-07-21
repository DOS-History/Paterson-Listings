        TITLE   LOG - Natural and base 2 logarithm

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $AC:WORD, $FAC:BYTE, $ARG:WORD

DATA    ENDS


CONST   SEGMENT WORD PUBLIC 'CONST'

        EXTRN   $LN2:WORD

;Coefficient tables for Hart's 2524. Absolute error 8.32, range [1/2,1].
;LOG2(x) = P(x) / Q(x)
; These constants have been checked with MuMath

LOGPTAB DW      3                       ;Degree 3 polynomial
        DB      09AH,0F7H,019H,083H     ;+4.8114 74609 89
        DB      024H,063H,043H,083H     ;+6.1058 51990 15
        DB      075H,0CDH,08DH,084H     ;-8.8626 59939 1
        DB      0A9H,07FH,083H,082H     ;-2.0546 66719 51

LOGQTAB DW      3                       ;Degree 3 polynomial
        DB      000H,000H,000H,081H     ;+1
        DB      0E2H,0B0H,04DH,083H     ;+6.4278 42090 29
        DB      00AH,072H,011H,083H     ;+4.5451 70876 29
        DB      0F4H,004H,035H,07FH     ;+0.35355 34252 77

CONST   ENDS


DC      GROUP   DATA,CONST


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $LOG,$LOG2

        EXTRN   $SMUL:NEAR, $SPOLY:NEAR, $SADD:NEAR, $CISA:FAR
        EXTRN   $SAVREG:NEAR, $ERC_FC:NEAR, $SDIV:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;***  $LOG - LOG (base e) function
;
; Inputs:
;       BX = Address of operand
; Outputs:
;       Result in FAC
; Registers:
;       Only F affected.

$LOG:
        CALL    $SAVREG
        MOV     SI,BX
        MOV     DI,OFFSET DC:$AC
        MOVSW                   ;Put operand in FAC
        MOVSW
        CALL    $LOG2           ;Compute log base 2
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$LN2
        JMP     $SMUL


;***  $LOG2 - Log (base two)
;
; Inputs:
;       Number in FAC
; Function:
;       Compute Log base 2, using relation LOG2(X*2^Y) = LOG2(2^Y) + LOG2(X) =
;       Y + LOG2(X), 0.5 <= X < 1
; Outputs:
;       Result in FAC
; Registers:
;       All registers destroyed.

$LOG2:
        MOV     AX,[$AC+2]
        OR      AH,AH           ;Taking log of zero?
        JZ      ARGERR
        OR      AL,AL           ;Log of negative number?
        JS      ARGERR
        MOV     [$FAC],80H      ;Assign a zero exponent
        MOV     AL,AH           ;Convert exponent to 16-bit integer
        SUB     AL,80H          ;   Remove bias
        CBW
        PUSH    AX
        PUSH    [$AC]
        PUSH    [$AC+2]         ;Save FAC for figuring Q(x)
        MOV     BX,OFFSET DC:LOGPTAB
        CALL    $SPOLY          ;Compute P(x) polynomial on mantissa
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$ARG+4
        MOVSW
        MOVSW                   ;Hold P(x) in temp while we compute Q(x)
        POP     [$AC+2]
        POP     [$AC]
        MOV     BX,OFFSET DC:LOGQTAB
        CALL    $SPOLY          ;Compute Q(x)
        MOV     SI,OFFSET DC:$ARG+4
        MOV     DI,OFFSET DC:$AC
        CALL    $SDIV           ;LOG2(x) = P(x) / Q(x)
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$ARG
        MOVSW                   ;Set result aside in ARG
        MOVSW
        POP     BX              ;Recover exponent (as integer)
        CALL    $CISA           ;Convert it to S.P.
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$ARG
        JMP     $SADD

ARGERR: JMP     $ERC_FC

CODE    ENDS
        END
