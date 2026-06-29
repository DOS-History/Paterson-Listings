        TITLE   CONST - Floating point constants

CONST   SEGMENT WORD PUBLIC 'CONST'

        PUBLIC  $HALFSQR2,$HALFPI,$RECIP2PI,$SIXTHPI,$SQRT3,$TANTWELFTHPI
        PUBLIC  $LOG2E,$LN2,$ONEHALF,$ONE4TH
        PUBLIC  $DLOG2E,$DHALFLN2,$DHALFSQR2,$DBLHALF,$DBL4TH
        PUBLIC  $DHALFPI,$DRECIP2PI,$DSIXTHPI,$DSQRT3,$DTANTWELFTHPI

;When a single precision constant does not need to be rounded up, the
;corresponding double precision constant will use it as its high 4 bytes.
; These constants have been checked with MuMath

$DHALFSQR2      DB      065H,0DEH,0F9H,033H
$HALFSQR2       DB      0F3H,004H,035H,080H     ;SQRT(2)/2

$DRECIP2PI      DB      015H,044H,04EH,06EH
$RECIP2PI       DB      083H,0F9H,022H,07EH     ;1/(2*PI)

$DHALFPI        DB      0C2H,068H,021H,0A2H,0DAH,00FH,049H,081H
$HALFPI         DB      0DBH,00FH,049H,081H     ;PI/2

$DSIXTHPI       DB      02CH,09BH,06BH,0C1H,091H,00AH,006H,080H
$SIXTHPI        DB      092H,00AH,006H,080H     ;PI/6

$DTANTWELFTHPI  DB      0B2H,06AH,0F6H,0F4H,0A2H,030H,009H,07FH
$TANTWELFTHPI   DB      0A3H,030H,009H,07FH     ;Tan(PI/12)

$DSQRT3         DB      054H,065H,0C2H,042H
$SQRT3          DB      0D7H,0B3H,05DH,081H     ;1/Tan(30 degrees) = SQRT(3)

$DLOG2E         DB      0F1H,017H,05CH,029H
$LOG2E          DB      03BH,0AAH,038H,081H     ;LOG base 2 of e

$DHALFLN2       DB      07AH,0CFH,0D1H,0F7H,017H,072H,031H,07FH
$LN2            DB      018H,072H,031H,080H     ;LN(2)

$DBLHALF        DB      0,0,0,0
$ONEHALF        DB      0,0,0,80H

$DBL4TH         DB      0,0,0,0
$ONE4TH         DB      0,0,0,7FH

CONST   ENDS

DATA    SEGMENT WORD PUBLIC 'DATA'

        PUBLIC  $ARG,$TEMP,$TEMP2

        EXTRN   $AC:WORD, $DAC:WORD

$ARG    DW      4 DUP(?)
$TEMP   DW      4 DUP(?)
$TEMP2  DW      4 DUP(?)

DATA    ENDS

DC      GROUP   DATA,CONST

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $PUT1, $PUT1D

        ASSUME  CS:CODE, DS:DC, ES:DC

$PUT1D:
        XOR     AX,AX
        MOV     [$DAC],AX
        MOV     [$DAC+2],AX
$PUT1:
        MOV     [$AC],0
        MOV     [$AC+2],8100H
        RET

CODE    ENDS
        END
