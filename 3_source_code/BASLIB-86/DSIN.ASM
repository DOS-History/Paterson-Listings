        TITLE   DSIN - Double precision sine and cosine functions

DATA    SEGMENT BYTE PUBLIC 'DATA'

        EXTRN   $DAC:WORD, $ARG:WORD, $FAC:BYTE, $TEMP:WORD

SIGN    DB      ?

DATA    ENDS

CONST   SEGMENT WORD PUBLIC 'CONST'

        EXTRN   $DBLHALF:WORD,$DBLONE:WORD,$DRECIP2PI:WORD,$DBL4TH:WORD

;Coefficients for Hart's #3345, relative precision 18.59
;       Hart's coefficients are intended to compute SIN(x*PI/2) = xP(x^2)
;       with x in range [0,1] (or [-1,1]). Instead, we compute
;       SIN(x*2*PI) = xP(x^2), x in [-1/4,1/4]. Thus our x is 1/4 the
;       the size intended, so each coefficient is multiplied by the
;       needed power of 4 to correct for this.
; These constants have been checked with MuMath

SINTAB  DW      8                       ;8th degree
;+0.00000000000587061098171     * 4^17
        DB      0F2H,0CCH,0BFH,04AH,0C3H,08DH,04EH,07DH

;-0.00000000066843217206396     * 4^15
        DB      06BH,0A6H,02CH,086H,0BBH,0BCH,0B7H,080H

;+0.00000005692134872719023     * 4^13
        DB      0E2H,0D9H,0ACH,04EH,0AFH,079H,074H,082H

;-0.00000359884300720869272     * 4^11
        DB      00EH,0B8H,08EH,0EEH,0A6H,083H,0F1H,084H

;+0.0001604411847068220716      * 4^9
        DB      05AH,086H,08CH,042H,01AH,03CH,028H,086H

;-0.00468175413530264260121     * 4^7
        DB      014H,0AAH,013H,073H,066H,069H,099H,087H

;+0.07969262624616543562977     * 4^5
        DB      06FH,053H,0ADH,03BH,0E3H,035H,023H,087H

;-0.64596409750624619108547     * 4^3
        DB      091H,0F2H,02DH,031H,0E7H,05DH,0A5H,086H

;+1.5707963267948966188272      * 4^1
        DB      0C2H,068H,021H,0A2H,0DAH,00FH,049H,083H

CONST   ENDS


DC      GROUP   CONST,DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC $SID, $COD, $TAD

        EXTRN  $SAVREG:NEAR, $FID:FAR, $DPOLYX:NEAR
        EXTRN  $DSUB:NEAR, $DDIV:NEAR, $DMUL:NEAR

        ASSUME CS:CODE, DS:DC, ES:DC


;***  $SID, $COD - Sine and Cosine trig functions
;
; Inputs:
;       BX = Address of argument
; Outputs:
;       Result in FAC
; Registers:
;       No registers affected.

$TAD:
        CALL    $SAVREG
        PUSH    [BX]            ;Save value of argument
        PUSH    [BX+2]
        PUSH    [BX+4]
        PUSH    [BX+6]
        CALL    SINF            ;Compute sin(x)
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$TEMP
        MOVSW
        MOVSW
        MOVSW
        MOVSW
        POP     [$DAC+6]        ;Restore argument to FAC
        POP     [$DAC+4]
        POP     [$DAC+2]
        POP     [$DAC]
        MOV     SI,OFFSET DC:$DAC
        CALL    COSF            ;Compute cos(x)
        MOV     SI,OFFSET DC:$TEMP
        MOV     DI,OFFSET DC:$DAC
        JMP     $DDIV           ;Tan = sin/cos

$COD:   ;Double precision cosine
        CALL    $SAVREG
        MOV     SI,BX
COSF:
        MOV     DI,OFFSET DC:$DRECIP2PI
        CALL    $DMUL
        AND     [$FAC-1],7FH    ;Take absolute value - COS(X) = COS(-X)
        MOV     DI,OFFSET DC:$DAC
        MOV     SI,OFFSET DC:$DBL4TH
        CALL    $DSUB           ;Use COS(X)=SIN(PI/2-X)
        JMP     SHORT SINCOS

$SID:   ;Double precision sine
        CALL    $SAVREG
SINF:
        MOV     SI,BX
        MOV     DI,OFFSET DC:$DRECIP2PI
        CALL    $DMUL
SINCOS:
        MOV     AL,[$FAC-1]     ;Get sign
        MOV     [SIGN],AL
        AND     AL,7FH          ;Take absolute value
        MOV     [$FAC-1],AL
        MOV     SI,OFFSET DC:$DAC
        MOV     DI,OFFSET DC:$ARG
        MOVSW                   ;Save X so far
        MOVSW
        MOVSW
        MOVSW
        MOV     BX,OFFSET DC:$DAC
        CALL    $FID            ;FAC=INT(X), X >= 0
        MOV     SI,OFFSET DC:$ARG
        MOV     DI,OFFSET DC:$DAC
        CALL    $DSUB           ;FAC= X - INT(X) (always positive or zero)
        CMP     [$FAC],7FH      ;Is X < 1/4? (In first quadrant?)
        JB      FIGSIN          ;If so, go compute
        CMP     [$DAC+6],8040H  ;Is X >= 3/4? (In fourth quadrant?)
        MOV     SI,OFFSET DC:$DBLHALF
        MOV     DI,OFFSET DC:$DAC  ;Subtract from 1/2 if in II or III
        JB      SUB
        MOV     SI,DI
        MOV     DI,OFFSET DC:$DBLONE  ;Subtract 1 from it if in IV
SUB:
        CALL    $DSUB
FIGSIN:
        MOV     BX,OFFSET DC:SINTAB
        CALL    $DPOLYX
        MOV     AL,[SIGN]
        AND     AL,80H          ;Reduce to sign bit
        XOR     [$FAC-1],AL     ;Flip sign if input was negative
        RET

CODE    ENDS
        END
