        TITLE   INPUTF - INPUT$ function

        .list

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $$SPSV:WORD,$PTRFIL:WORD

DATA    ENDS


DC      GROUP   DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $IN$

        EXTRN   $GETCHR:NEAR,$FBLOC:NEAR,$$ATS:NEAR
        EXTRN   $ERC_BFM:NEAR,$ERC_IFN:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


$IN$    PROC    FAR

;***  $IN$ - INPUT$ function for TTY or disk
;
; Inputs:
;       BX = Number of characters wanted
;       DX = File number (32767 for TTY)
; Function:
;       Create a temp string of length BX, fill with characters from file or
;       from TTY without echo.
; Outputs:
;       BX = Address of string descriptor
; Registers:
;       Only BX and F affected.

        MOV     [$$SPSV],SP
        PUSH    CX
        PUSH    DX
        PUSH    SI
        XOR     SI,SI           ;In case TTY input
        MOV     CX,BX           ;Put count in CX
        MOV     BX,DX           ;File number in BX
        CMP     BL,255
        JZ      STOPNT
        CALL    $FBLOC
        JZ      BADNUM          ;Illegal file number
        CMP     [SI].FD_MODE,MD_SQO
        JE      BADMODE
STOPNT:
        MOV     [$PTRFIL],SI
        POP     SI
        MOV     BX,CX
        CALL    $$ATS           ;Allocate temp string
        JCXZ    INPOP
        XCHG    DI,DX           ;Put data pointer in DI
        PUSH    AX
RDSTR:
        CALL    $GETCHR         ;Read character
        STOSB                   ;Put in string
        LOOP    RDSTR           ;Repeat
        POP     AX
        MOV     DI,DX           ;Restore DI
INPOP:
        POP     DX
        POP     CX
        RET

BADNUM: JMP     $ERC_IFN
BADMODE:JMP     $ERC_BFM

$IN$    ENDP
CODE    ENDS
        END
