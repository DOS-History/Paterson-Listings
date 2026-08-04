        TITLE   POLY - Polynomial evaluator for transcendental functions

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $AC:WORD, $DAC:WORD, $ARG:WORD

DATA    ENDS


DC      GROUP   DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $SPOLY, $SPOLY2, $SPOLYX, $DPOLY, $DPOLY2, $DPOLYX

        EXTRN   $SMUL:NEAR, $SADD:NEAR, $DMUL:NEAR, $DADD:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;***  $SPOLY, $SPOLY2, & $SPOLYX - Evaluate SP polynomial
;
; Inputs:
;       BX = Address of list of coefficients. First byte in list is nmber of
;            coefficients, followed by the constants ordered from highest
;            power to lowest.
;       FAC = argument.
; Function:
;       Evaluate polynomial by Horner's method
; Outputs:
;       Result in FAC.
; Registers:
;       ALL destroyed.

$SPOLY2:
;Compute polynomial on square of argument
        PUSH    BX
        MOV     SI,OFFSET DC:$AC
        MOV     DI,SI
        CALL    $SMUL           ;Square the argument
        POP     BX
$SPOLY:
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$ARG  ;Local stroage for argument
        MOVSW
        MOVSW                   ;Save argument
        MOV     SI,BX           ;Point to coefficient table
        LODSW                   ;Number of coefficients
        XCHG    AX,CX           ;Count in CX
        MOV     DI,OFFSET DC:$AC
        MOVSW                   ;Move first coefficient into FAC
        MOVSW
SPOLYLOOP:
        PUSH    CX
        PUSH    SI
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$ARG
        CALL    $SMUL           ;Multiply by argument
        POP     SI              ;Recover pointer to next coefficient
        PUSH    SI
        MOV     DI,OFFSET DC:$AC
        CALL    $SADD           ;Add coefficient
        POP     SI
        POP     CX
        ADD     SI,4            ;Bump to next coefficient
        LOOP    SPOLYLOOP
        RET

$SPOLYX:
;Same as $SPOLY2, but multiplies by original (unsquared) argument when done,
;for computing odd-degree polynomials (like SIN).
        PUSH    [$AC]
        PUSH    [$AC+2]
        CALL    $SPOLY2         ;Compute polynomial on square on argument
        MOV     SI,OFFSET DC:$ARG
        POP     [SI+2]
        POP     [SI]
        MOV     DI,OFFSET DC:$AC
        JMP     $SMUL           ;Multiply by original argument (unsquared)


;***  $DPOLY & $DPOLY2 - Evaluate DP polynomial
;
; Inputs:
;       BX = Address of list of coefficients. First byte in list is number of
;            coefficients, followed by the constants ordered from highest
;            power to lowest.
;       FAC = argument.
; Function:
;       Evaluate polynomial by Horner's method
; Outputs:
;       Result in FAC.
; Registers:
;       ALL destroyed.

$DPOLY2:
;Compute polynomial on square of argument
        PUSH    BX
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,SI
        CALL    $DMUL           ;Square the argument
        POP     BX
$DPOLY:
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$ARG  ;Local storage for argument
        MOVSW
        MOVSW
        MOVSW
        MOVSW                   ;Save argument
        MOV     SI,BX           ;Point to coefficient table
        LODSW                   ;Number of coefficients
        XCHG    AX,CX           ;Count in CX
        MOV     DI,OFFSET DC:$DAC
        MOVSW                   ;Move first coefficient into FAC
        MOVSW
        MOVSW
        MOVSW
DPOLYLOOP:
        PUSH    CX
        PUSH    SI
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$ARG
        CALL    $DMUL           ;Multiply by argument
        POP     SI              ;Recover pointer to next coefficient
        PUSH    SI
        MOV     DI,OFFSET DC:$DAC
        CALL    $DADD           ;Add coefficient
        POP     SI
        POP     CX
        ADD     SI,8            ;Bump to next coefficient
        LOOP    DPOLYLOOP
        RET

$DPOLYX:
;Same as $DPOLY2, but multiplies by original (unsquared) argument when done,
;for computing odd-degree polynomials (like SIN).
        PUSH    [$DAC]
        PUSH    [$DAC+2]
        PUSH    [$DAC+4]
        PUSH    [$DAC+6]
        CALL    $DPOLY2         ;Compute polynomial on square on argument
        MOV     SI,OFFSET DC:$ARG
        POP     [SI+6]
        POP     [SI+4]
        POP     [SI+2]
        POP     [SI]
        MOV     DI,OFFSET DC:$DAC
        JMP     $DMUL           ;Multiply by original argument (unsquared)

CODE    ENDS
        END
