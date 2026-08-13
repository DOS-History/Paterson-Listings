        TITLE   SINCOS - Sine and cosine functions

DATA    SEGMENT BYTE PUBLIC 'DATA'

        EXTRN   $AC:WORD, $ARG:WORD, $FAC:BYTE, $TEMP:WORD

SIGN    DB      ?

DATA    ENDS

CONST   SEGMENT WORD PUBLIC 'CONST'

        EXTRN   $ONEHALF:WORD,$ONE:WORD,$RECIP2PI:WORD,$HALFPI:WORD
        EXTRN   $ONE4TH:WORD

;Coefficients for Hart's #3341, relative precision 8.27
;       Hart's coefficients are intended to compute SIN(x*PI/2) = xP(x^2)
;       with x in range [0,1] (or [-1,1]). Instead, we compute
;       SIN(x*2*PI) = xP(x^2), x, in [-1/4,1/4]. Thus our x is 1/4 the
;       the size intended, so each coefficient is multiplied by the
;       needed power of 4 to correct for this.
; These constants have been checked with MuMath

SSINTAB DW      4                       ;4th degree
        DB      0FBH,0D7H,01EH,086H     ; +0.00015148 5129      * 4^9
        DB      065H,026H,099H,087H     ; -0.0046737 6661       * 4^7
        DB      058H,034H,023H,087H     ; +0.079689 67894 6     * 4^5
        DB      0E1H,05DH,0A5H,086H     ; -0.64596 37105 99     * 4^3
        DB      0DBH,00FH,049H,083H     ; +1.5707 96318 44      * 4^1

CONST   ENDS


DC      GROUP   CONST,DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $SIN, $COS, $TAN

        EXTRN   $SAVREG:NEAR, $FIX:FAR, $SPOLYX:NEAR
        EXTRN   $SSUB:NEAR, $SDIV:NEAR, $SMUL:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;***  $SIN, $COS - Sine and Cosine trig functions
;
; Inputs:
;       BX = Address of argument
; Outputs:
;       Result in FAC
; Registers:
;       No registers affected.

$TAN:
        CALL    $SAVREG
        PUSH    [BX]            ;Save value of argument
        PUSH    [BX+2]
        CALL    SINF            ;Compute sin(x)
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$TEMP
        MOVSW
        MOVSW
        POP     [$AC+2]         ;Restore argument to FAC
        POP     [$AC]
        MOV     SI,OFFSET DC:$AC
        CALL    COSF            ;Compute cos(x)
        MOV     SI,OFFSET DC:$TEMP
        MOV     DI,OFFSET DC:$AC
        JMP     $SDIV           ;Tan = sin/cos

$COS:   ;Single precision cosine
        CALL    $SAVREG
        MOV     SI,BX
COSF:
        MOV     DI,OFFSET DC:$RECIP2PI
        CALL    $SMUL
        AND     [$FAC-1],7FH    ;Take absolute value - COS(X) = COS(-X)
        MOV     DI,OFFSET DC:$AC
        MOV     SI,OFFSET DC:$ONE4TH
        CALL    $SSUB           ;Use COS(X)=SIN(PI/2-X)
        JMP     SHORT SINCOS

$SIN:   ;Single precision sine
        CALL    $SAVREG
SINF:
        MOV     SI,BX
        MOV     DI,OFFSET DC:$RECIP2PI
        CALL    $SMUL
SINCOS:
        MOV     AL,[$FAC-1]     ;Get sign
        MOV     [SIGN],AL
        AND     AL,7FH          ;Take absolute value
        MOV     [$FAC-1],AL
        MOV     SI,OFFSET DC:$AC
        MOV     DI,OFFSET DC:$ARG
        MOVSW                   ;Save X so far
        MOVSW
        MOV     BX,OFFSET DC:$AC
        CALL    $FIX            ;FAC=INT(X), X >= 0
        MOV     SI,OFFSET DC:$ARG
        MOV     DI,OFFSET DC:$AC
        CALL    $SSUB           ;FAC= X - INT(X) (always positive or zero)
        CMP     [$FAC],7FH      ;Is X < 1/4 ? (In first quadrant?)
        JB      FIGSIN          ;If so, go compute
        CMP     [$AC+2],8040H   ;Is X >= 3/4? (In fourth quadrant?)
        MOV     SI,OFFSET DC:$ONEHALF
        MOV     DI,OFFSET DC:$AC  ;Subtract from 1/2 if in II or III
        JB      SUB
        MOV     SI,DI
        MOV     DI,OFFSET DC:$ONE  ;Subtract 1 from it if in IV
SUB:
        CALL    $SSUB
FIGSIN:
        MOV     BX,OFFSET DC:SSINTAB
        CALL    $SPOLYX
        MOV     AL,[SIGN]
        AND     AL,80H          ;Reduce to sign bit
        XOR     [$FAC-1],AL     ;Flip sign if input was negative
        RET

CODE    ENDS
        END
