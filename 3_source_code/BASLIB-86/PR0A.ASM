        TITLE   PR0A - Prepare for printing

;       *PR0A - PRINT, no USING, no #
;        PR0B - PRINT USING
;       *PR0C - PRINT #
;        PR0D - PRINT USING #
;       *PR0E - LPRINT
;        PR0F - LPRINT USING
;       *WRI - WRITE
;       *WRD - WRITE #
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

        PUBLIC  $PR0A,$PR0C,$PR0E,$WRI,$WRD

        EXTRN   $FBLOC:NEAR
        EXTRN   $ERC_IFN:NEAR,$ERC_BFM:NEAR

        ASSUME  CS:CODE,DS:DC,ES:DC

Entries PROC    FAR

$PR0A:  MOV     [$$WRFL],0

pr0:    MOV     [$PTRFIL],0

pr1:    MOV     [$$PUFL],0
        RET

$WRI:   MOV     [$$WRFL],1
        JMP     pr0

$PR0C:  CALL    pr0c
        JMP     pr3

$PR0E:  MOV     [$PTRFIL],OFFSET DC:$LPTFDB

pr3:    MOV     [$$WRFL],0
        JMP     pr1

$WRD:   CALL    pr0c
        MOV     [$$WRFL],1
        JMP     pr1

Entries ENDP

Locals  PROC    NEAR

pr0c:   MOV     [$$SPSV],SP
        ADD     [$$SPSV],2
        PUSH    SI
        CALL    $FBLOC                  ;See if file exists
        JZ      ercifn
        CMP     [SI].FD_MODE,MD_SQI
        JE      ercbfm
        MOV     [$PTRFIL],SI
        POP     SI
        RET

ercifn: JMP     $ERC_IFN

ercbfm: JMP     $ERC_BFM

Locals  ENDP

CODE    ENDS

        END
