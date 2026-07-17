        TITLE   IOLPT  - Line printer Device Drivers
        SUBTTL  Support for 1 line printers
PAGE 60,132

;       This module contains the device independent printer routines for
;       the BASIC Compiler.  While this module is intended for use with
;       the IBM Personal Computer, there is only a small amount which
;       actually depends on this fact.

;       Modified for 1 printer systems  (subset of IBM)


iniwid=         132                     ;Initial printer width

LF=             10
CR=             13


        INCLUDE TABMAC.INC

        INCLUDE DEVDEF.INC

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FILMOD:BYTE

DATA    ENDS

CONST   SEGMENT WORD PUBLIC 'CONST'

        PUBLIC  $LPTFDB

LPTWID          DB      iniwid                  ;width/initial position
LPTPOS          DB      0

$LPTFDB         DB      FD_BUFFER DUP (0)       ;LPRINT file data block

CONST   ENDS

DC      GROUP   CONST,DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        ASSUME CS:CODE, DS:DC, ES:DC


;       Run-time Entries

        PUBLIC  $D_LPT1,$I_LPT1,$W_LPT1,$C_LPT1

        PUBLIC  $LPO,$LWI


;       Run-time Externals

        EXTRN   $LPTOT:NEAR
        EXTRN   $$WCLF:NEAR
        EXTRN   $DEVOPN:NEAR,$FRCSQO:NEAR,$FBDEA:NEAR
        EXTRN   $ERC_FC:NEAR


;       Illegal Device Functions

LPT_EOF         EQU     $ERC_FC
LPT_LOC         EQU     $ERC_FC
LPT_LOF         EQU     $ERC_FC
LPT_RANDIO      EQU     $ERC_FC
LPT_BAKC        EQU     $ERC_FC
LPT_SINP        EQU     $ERC_FC


;       Device Independent Printer Interface

DSPMAC  MACRO   func
        DW      LPT_&func
        ENDM

$D_LPT1:
        DSPNAM



;-----  Device Action Routines  ----------------------------------------------


;       These routines are always called from special device dispatchers.
;
;       The registers are set up as follows:
;
;               (DI) = device offset
;
;       The remaining registers are used to pass parameters.


devio   PROC    NEAR

;       Device initialization routines
;
;       ENTRY   (DI) = Device offset
;       USES    any but DI

$I_LPT1:
        MOV     $LPTFDB.FD_MODE,MD_SQO  ;Initialize LPRINT file data block
        MOV     $LPTFDB.FD_DEVICE,DN_LPT1
        MOV     $LPTFDB.FD_WIDTH,iniwid
        RET


;       Device close routines
;
;       ENTRY   (DI) = Device offset
;       USES    any but DI

$C_LPT1:
        CMP     LPTPOS,0
        JE      cret
        MOV     AL,CR
        CALL    $LPTOT
        MOV     AL,LF
        CALL    $LPTOT

cret:   RET


;       Device width routines
;
;       ENTRY   (DL) = device width
;               (DI) = Device offset
;       USES    none

$W_LPT1:
        MOV     $LPTFDB.FD_WIDTH,DL     ;Set LPRINT file width
        MOV     LPTWID,DL               ;Set new printer width
        RET

devio   ENDP


;-----  File Action Routines  -----------------------------------------------


;       These routines are all called from the file dispatcher.
;
;       The registers are set up as follows:
;
;               (SI) = file data block address (points to file mode field)
;               (DI) = device offset  (0 = disk , 2 = next , 4 = next , ...)
;               (AH) = function code of routine
;               (AL,CX,DX,BX) = parameters for each routine
;
;       These routines are free to use SI and DI as temporaries


fileio  PROC

;       OPEN statement
;
;       ENTRY   (BX) = file number
;               (AL) = device number for OPEN
;               (DX) = file name descriptor  (not used here)
;               (CX) = variable record length  (not used here)

LPT_OPEN:
        CALL    $FRCSQO                 ;Change MD_RND to MD_SQO
        PUSH    CX
        PUSH    DX
        PUSH    BX
        XOR     CX,CX                   ;(CX) = extra FDB size
        MOV     DX,WORD PTR LPTWID      ;(DH,DL) = (position,width)
        MOV     AH,MD_SQO               ;Valid file modes
        CALL    $DEVOPN                 ;Open file data block
        MOV     AL,[$FILMOD]
        MOV     [SI].FD_MODE,AL         ;Set file mode
        POP     BX
        POP     DX
        POP     CX
        RET


;       WIDTH file statement
;
;       ENTRY   (BX) = file number
;               (DL) = file width

LPT_WIDTH:
        MOV     [SI].FD_WIDTH,DL
        RET


;       SOUT - Serial character output
;
;       ENTRY   (AL) = character
;       USES    AX,SI,DI

LPT_SOUT:
        PUSH    AX                      ;(AL) = character
        CALL    $LPTOT                  ;Print character  (DI) = device offset
        POP     AX
        CMP     AL,CR                   ;Is CR?
        JE      sout1                   ;  Yes
        CMP     AL,' '                  ;Is printing char?
        JB      sout2                   ;  No

        INC     LPTPOS                  ;Bump position (device)
        MOV     AH,[SI].FD_WIDTH        ;Get printer (file) width
        CMP     AH,255
        JE      sout2                   ;Infinite width

        CMP     AH,LPTPOS               ;At end of line
        JA      sout2

        CALL    $$WCLF                  ;Write CR/LF to printer

sout1:  MOV     LPTPOS,0                ;Set position (device) to 0

sout2:  RET


;       GPOS - Get position
;
;       EXIT    (AH) = device position

LPT_GPOS:
        MOV     AH,LPTPOS               ;Get position (device)
        RET


;       GWID - Get width
;
;       EXIT    (AH) = file width

LPT_GWID:
        MOV     AH,[SI].FD_WIDTH        ;Get printer (file) width
        RET


;       CLOSE - Line printer file close
;
;       Deallocate file block

LPT_CLOSE:
        CALL    $FBDEA                  ;Deallocate buffer
        RET


fileio  ENDP


Entries PROC    FAR



;**     $LPO - Line printer position
;
;       Get line printer position
;
;       ENTRY   NONE
;       EXIT    (BX) = printer position

$LPO:
        MOV     BL,LPTPOS               ;Get position for printer
        MOV     BH,0
        INC     BX
        RET



;       WIDTH LPRINT Statement
;
;       Sets the LPRINT file width and device width

$LWI:
        MOV     $LPTFDB.FD_WIDTH,BL     ;Set LPRINT file width
        MOV     LPTWID,BL               ;Set printer 1 width
        RET


Entries ENDP

CODE    ENDS

        END
