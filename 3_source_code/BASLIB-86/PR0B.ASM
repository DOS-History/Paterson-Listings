        TITLE   PR0B - Prepare for printing with PRINT USING

;        PR0A - PRINT, no USING, no #
;       *PR0B - PRINT USING
;        PR0C - PRINT #
;       *PR0D - PRINT USING #
;        PR0E - LPRINT
;       *PR0F - LPRINT USING
;        WRI - WRITE
;        WRD - WRITE #
; * Only these included in this module

.list

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $$PUFL:BYTE,$$WRFL:BYTE,$PTRFIL:WORD,$$SPSV:WORD

DATA    ENDS

CONST   SEGMENT WORD PUBLIC 'CONST'

        EXTRN   $LPTFDB:BYTE

CONST   ENDS

DC      GROUP   CONST,DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $PR0B,$PR0D,$PR0F

        EXTRN   $FBLOC:NEAR, $PRU:NEAR
        EXTRN   $ERC_IFN:NEAR,$ERC_BFM:NEAR

        ASSUME  CS:CODE,DS:DC,ES:DC


$PR0B:
        MOV     [$PTRFIL],0
PR1:
        MOV     [$$WRFL],0
        JMP     $PRU

$PR0D:
        MOV     [$$SPSV],SP
        PUSH    SI
        XCHG    BX,DX                  ;Swap file # into (BX)
        CALL    $FBLOC                 ;See if file exists
        JZ      ercifn
        CMP     [SI].FD_MODE,MD_SQI
        JE      ercbfm
        MOV     [$PTRFIL],SI
        XCHG    BX,DX                  ;Swap string desc back into (BX)
        POP     SI
        JMP     PR1

$PR0F:  MOV     [$PTRFIL],OFFSET DC:$LPTFDB
        JMP     PR1

ercifn: JMP     $ERC_IFN

ercbfm: JMP     $ERC_BFM

CODE    ENDS
        END
