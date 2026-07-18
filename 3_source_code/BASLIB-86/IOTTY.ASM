        TITLE   IOTTY  - Console driver for BASCOM-86
PAGE 60,132

        INCLUDE TABMAC.INC

        INCLUDE DEVDEF.INC

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FILMOD:BYTE

DATA    ENDS


CONST   SEGMENT WORD PUBLIC 'CONST'

        EXTRN   $TTYWID:BYTE

TTY_BAKCHR      DB      0
TTY_BAKFLG      DB      0               ;Initially no character

CONST   ENDS

DC      GROUP   CONST,DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        ASSUME  CS:CODE, DS:DC, ES:DC

;       Run-time entries

        PUBLIC  $WID,$POS
        PUBLIC  $D_KYBD,$I_KYBD,$C_KYBD,$W_KYBD
        PUBLIC  $D_SCRN,$I_SCRN,$C_SCRN,$W_SCRN
        PUBLIC  $TTY_BAKC,$TTY_SINP,$TTY_SOUT,$TTY_GPOS,$TTY_GWID

;       Run-time externals

        EXTRN   $TTYIN:NEAR,$TTYOT:NEAR,$LTTYPS:NEAR,$STTYPS:NEAR
        EXTRN   $$WCH:NEAR,$$WCLF:NEAR
        EXTRN   $DEVOPN:NEAR,$FRCSQO:NEAR
        EXTRN   $FBDEA:NEAR
        EXTRN   $ERC_FC:NEAR
;IF _IBM_
;        EXTRN   $SCNWID:NEAR
;ENDIF


;       Illegal Device Functions

KYBD_EOF        EQU     $ERC_FC
KYBD_LOC        EQU     $ERC_FC
KYBD_LOF        EQU     $ERC_FC
KYBD_WIDTH      EQU     $ERC_FC
KYBD_RANDIO     EQU     $ERC_FC
KYBD_SOUT       EQU     $ERC_FC
KYBD_GPOS       EQU     $ERC_FC
KYBD_GWID       EQU     $ERC_FC

SCRN_EOF        EQU     $ERC_FC
SCRN_LOC        EQU     $ERC_FC
SCRN_LOF        EQU     $ERC_FC
SCRN_RANDIO     EQU     $ERC_FC
SCRN_BAKC       EQU     $ERC_FC
SCRN_SINP       EQU     $ERC_FC


;       Devide Independent Console Interface

DSPMAC  MACRO   func
        DW      SCRN_&func
        ENDM

$D_SCRN:
        DSPNAM


DSPMAC  MACRO   func
        DW      KYBD_&func
        ENDM

$D_KYBD:
        DSPNAM

        PAGE

devio   PROC    NEAR

;       Keyboard routines

$I_KYBD:
$I_SCRN:
$C_KYBD:
$C_SCRN:
        RET

$W_KYBD:
        JMP     KYBD_WIDTH


KYBD_OPEN:
        PUSH    CX
        PUSH    DX
        PUSH    BX
        XOR     CX,CX                   ;(CX) = extra FDB size
        MOV     [TTY_BAKFLG],CL         ;Clear keyboard backup flag
        XOR     DX,DX                   ;(DX) = (position,width)
        MOV     AH,MD_SQI               ;Valid open modes

opndev: CALL    $DEVOPN                 ;Common routine
        MOV     AL,[$FILMOD]
        MOV     [SI].FD_MODE,AL         ;Set file mode
        POP     BX
        POP     DX
        POP     CX
        RET


$TTY_SINP:
KYBD_SINP:
        CMP     [TTY_BAKFLG],0
        JE      keyin

        MOV     [TTY_BAKFLG],0
        MOV     AL,[TTY_BAKCHR]
        CLC
        RET

keyin:  CALL    $TTYIN                  ;Get character
        CLC                             ;Clear carry
        RET


$TTY_BAKC:
KYBD_BAKC:
        MOV     [TTY_BAKFLG],1          ;Set flag
        MOV     [TTY_BAKCHR],AL
        RET

        PAGE

;       Screen routines

SCRN_OPEN:
        CALL    $FRCSQO                 ;Force sequential output
        PUSH    CX
        PUSH    DX
        PUSH    BX
        XOR     CX,CX                   ;(CX) = extra FDB size
        MOV     DL,[$TTYWID]            ;(DL) = position(ignored),width
        MOV     AH,MD_SQO               ;Set legal modes
        JMP     opndev                  ;Go to common routine


$W_SCRN:
SCRN_WIDTH:
;if      _IBM_
;        XCHG    DX,BX                   ;Switch for common call
;        CALL    $SCNWID                 ;Special for IBM
;        XCHG    DX,BX                   ;Switch back
;else
        MOV     [$TTYWID],DL
;endif
        RET


BS=             8                       ;Backspace
TAB=            9                       ;Tab
CR=             13                      ;Carriage return

$TTY_SOUT:
SCRN_SOUT:
        XOR     AH,AH
        CMP     AL,CR                   ;Check for CR
        JE      wch50

        CMP     AL,BS                   ;Check for backspace
        JNE     wch10

        CALL    $LTTYPS                 ;(AH) = position
        OR      AH,AH
        JZ      wch05                   ;  Already in 1st column
        DEC     AH                      ;Decrement column position
wch05:  CALL    $STTYPS                 ;Save new position
        JMP     SHORT wch               ;Output character

wch10:  CMP     AL,TAB                  ;Check for tab
        JNE     wch20

wch11:  MOV     AL,' '
        CALL    $$WCH                   ;Recursively tab
        CALL    $LTTYPS                 ;(AH) = position
        CMP     AH,255
        JE      wch15                   ;Stop counting at 255
        AND     AH,7
        JNZ     wch11                   ;More spacing to next column

wch15:  MOV     AL,TAB                  ;Restore tab character
        RET

wch20:  CMP     AL,' '                  ;Check for printing character
        JB      wch                     ;  Not printing

        CALL    $LTTYPS
        CMP     $TTYWID,255             ;Check for infinite width
        JE      wch25

        CMP     AH,$TTYWID              ;Check for last column
        JNE     wch25

        CALL    $$WCLF                  ;Yes - write CR/LF

wch25:  CMP     AH,255                  ;Stop counting at 255
        JE      wch

        INC     AH                      ;Bump position

wch50:  CALL    $STTYPS                 ;Set position

wch:    JMP     $TTYOT


$TTY_GPOS:
SCRN_GPOS:
        JMP     $LTTYPS                 ;Get console position


$TTY_GWID:
SCRN_GWID:
        MOV     AH,$TTYWID              ;(AH) = width
        RET

        PAGE

;       Device Close Routines

KYBD_CLOSE:
SCRN_CLOSE:
        CALL    $FBDEA                  ;Deallocate file block
        RET


devio   ENDP

Entries PROC    FAR

$WID:
;if      _IBM_
;        CALL    $SCHWID
;else
        MOV     [$TTYWID],BL            ;WIDTH Statement
;endif
        RET


$POS:   PUSH    AX                      ;POS Function
        CALL    $LTTYPS
        MOV     BL,AH
        XOR     BH,BH
        INC     BX                      ;Map Pos to Base 1
        POP     AX
        RET

Entries ENDP

CODE    ENDS

        END

