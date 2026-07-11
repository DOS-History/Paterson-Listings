        TITLE   IODEV   - Device Independent I/O Drivers for BASCOM-86
PAGE 60,132

;       This module contains the device independent I/O drivers for the
;       8086 BASIC Compiler runtime.


        INCLUDE TABMAC.INC
        INCLUDE DEVDEF.INC


DATA    SEGMENT WORD PUBLIC 'DATA'

        PAGE

;       External Data Variables

        EXTRN   $PTRFIL:WORD, $FILPT:WORD
        EXTRN   $$SPSV:WORD


;       Local Data Definitions

DISPATCH_ADDR   DW      ?               ;Dispatch address


;       Public Data Variables

        PUBLIC  $FILNAM,$FILNM2,$FILMOD

$FILNAM         DB      FILNAML DUP (?) ;1st File name buffer
$FILNM2         DB      FILNAML DUP (?) ;2nd File name buffer
$FILMOD         DB      ?               ;File mode from OPEN statement

DATA    ENDS


DC      GROUP   DATA


CODE    SEGMENT WORD PUBLIC 'CODE'

        ASSUME  CS:CODE, DS:DC, ES:DC

;       Compiler generated entries

        PUBLIC  $EOF,$LOC,$LOF                  ;$POF
        PUBLIC  $DKC,$WDF,$DKN,$DKM,$DKO,$DCA
        PUBLIC  $GET,$RGT,$PUT,$RPT,$VPT
        PUBLIC  $WDD

;       Run-time entries

        PUBLIC  $INIDEV,$CLSDEV
        PUBLIC  $BAKCHR,$GETCHR,$PUTCHR,$GETPOS,$GETWID
        PUBLIC  $$BCH,$$RCH,$$WCH,$$POS,$$WID
        PUBLIC  $SCANF,$CLOSF,$FRCSQO,$DEVOPN
        PUBLIC  $DEVICE_TABLE

;       Run-time externals

        EXTRN   $$DITS:NEAR
        EXTRN   $ERC_BFM:NEAR
        EXTRN   $ERC_BFN:NEAR
        EXTRN   $ERC_DNA:NEAR
        EXTRN   $ERC_FAO:NEAR
        EXTRN   $ERC_IFN:NEAR

        EXTRN   $FBLOC:NEAR, $FBALC:NEAR, $FBDEA:NEAR
        EXTRN   $SAVREG:NEAR

        EXTRN   $TTY_BAKC:NEAR
        EXTRN   $TTY_SINP:NEAR
        EXTRN   $TTY_SOUT:NEAR
        EXTRN   $TTY_GPOS:NEAR
        EXTRN   $TTY_GWID:NEAR

;       Device Name Generator

DEVMAC  MACRO   ARG
        DB      '&ARG'
        DB      DN_&ARG
        ENDM

DEVICE_NAME_TABLE       LABEL   BYTE
        DEVNAM
        DB      0


;       Device Dispatch Address Generator

DEVMAC  MACRO   ARG
        EXTRN   $D_&ARG:NEAR
        DW      $D_&ARG
        ENDM

        EVEN                            ;Word align

$DEVICE_TABLE   LABEL   WORD

        DEVMAC  DISK                    ;Disks are treated as device type 0
        DEVNAM                          ;Rest of devices


;       Device initialization dispatch address generator

DEVMAC  MACRO   ARG
        EXTRN   $I_&ARG:NEAR
        DW      $I_&ARG
        ENDM

INIDEV_TABLE    LABEL   WORD

        DEVNAM                          ;Device initialization addresses

INIDEV_END      LABEL   WORD            ;End of table


;       Device close dispatch address generator

DEVMAC  MACRO   ARG
        EXTRN   $C_&ARG:NEAR
        DW      $C_&ARG
        ENDM

CLSDEV_TABLE    LABEL   WORD

        DEVNAM                          ;Device close addresses

CLSDEV_END      LABEL   WORD            ;End of table


;       Device width set dispatch address generator
;
;       Routine calling sequence:
;
;               Entry   (DX) = width

DEVMAC  MACRO   ARG
        EXTRN   $W_&ARG:NEAR
        DW      $W_&ARG
        ENDM

WIDTH_TABLE     LABEL   WORD

        DEVNAM                          ;Width set addresses



        SUBTTL  Compiler Generated Entry Points


;**     WIDTH "device" Statement
;
;       ENTRY    (BX) = device name string
;                (DX) = width

$WDD:   CALL     $SAVREG
        MOV      CX,[BX]                 ;(CX) = length
        MOV      SI,[BX+2]               ;(SI) = address
        CALL     PARSE_DEVICE            ;(AL) = device
        OR       AL,AL                   ;Test for no device
        JNZ      wdd1
        JMP      $ERC_BFN                ;Error - bad file name
wdd1:   CALL     $$DITS                  ;Delete if temporary string
        NOT      AL                      ;Convert to 0 and up
        CBW
        SAL      AX,1                    ;2 * (NOT device#)
        XCHG     AX,DI                   ;(DI) = offset
        JMP      CS:WIDTH_TABLE[DI]      ;Call width set routine - (DX) = width


Entries PROC     FAR

;**     VARPTR()  Functoin
;
;       ENTRY    (BX) = file number
;       EXIT     (BX) = address of file data block
;       USES     BX

$VPT:   MOV      [$$SPSV],SP
        PUSH     SI
        CALL     $FBLOC                  ;Find file block
        JNZ      vpt1
        JMP      ercifn                  ;Error - illegal file number
vpt1:   MOV      BX,SI                   ;Put address in (BX)
        POP      SI
        RET



;**     EOF() Function
;
;       ENTRY   (BX) = file number
;       EXIT    (BX) = 0 or -1 if end of file
;       USES    BX

$EOF:   PUSH    AX
        MOV     AH,DV_EOF               ;End of file function

comdsp: MOV     [$$SPSV],SP
        ADD     [$$SPSV],2              ;Current stack + 2 for PUSH AX

comds1: CALL    FILE_DISPATCH
        POP     AX
        RET



;**     LOC() Function
;
;       ENTRY   (BX) = file number
;       EXIT    (BX) = current record number
;       USES    BX

$LOC:   PUSH    AX
        MOV     AH,DV_LOC               ;LOC function
        JMP     comdsp



;**     LOF() Function
;
;       ENTRY   (BX) = file number
;       EXIT    (FAC) = length of file in bytes
;       USES    FAC

$LOF:   PUSH    AX
        MOV     AH,DV_LOF               ;LOF Function
        JMP     comdsp



;**     POS() Function                  ####  not implemented  ####
;
;       ENTRY   (BX) = file number
;       EXIT    (BX) = current position in sequential record
;       USES    BX

;$POF:  PUSH    AX
;       MOV     AH,DV_POS               ;POS Function
;       JMP     comdsp



;**     CLOSE statement
;
;       ENTRY   (BX) = file number
;       USES    NONE

$DKC:   MOV     [$$SPSV],SP

dkc1:   PUSH    SI
        CALL    $FBLOC                  ;Must check if file has been opened
        POP     SI
        JZ      dkcret                  ;  No - just return
        PUSH    AX
        MOV     AH,DV_CLOSE
        JMP     comds1


$DCA:   MOV     [$$SPSV],SP
        CALL    $CLOSF                  ;Close all files
dkcret: RET



;**     WIDTH   #fnum,width
;
;       ENTRY   (BX) = file number
;               (DX) = width
;       USES    NONE

$WDF:   PUSH    AX
        MOV     AH,DV_WIDTH             ;File width function
        JMP     comdsp

        PAGE

;**     $GET/$RGT/$PUT/$RPT - Random disk I/O
;
;       ENTRY   (BX) = file number
;               (DX) = record number for relative calls
;       USES    AH

PUTFLG  EQU     1                       ;PUT call
RELFLG  EQU     2                       ;Record number in (DX)

$GET:   PUSH    AX
        MOV     AL,0

rnddsp: MOV     AH,DV_RANDIO
        MOV     [$$SPSV],SP
        ADD     [$$SPSV],2
        PUSH    SI
        CALL    $FBLOC
        JZ      ercbfm                  ;This is garbage - inconsistent
        CMP     [SI].FD_MODE,MD_RND
        JNE     ercbfm                  ;Not random - bad file mode
        CALL    PTRFIL_DISPATCH
        POP     SI
        POP     AX
        RET

$RGT:   PUSH    AX
        MOV     AL,RELFLG
        JMP     rnddsp

$PUT:   PUSH    AX
        MOV     AL,PUTFLG
        JMP     rnddsp

$RPT:   PUSH    AX
        MOV     AL,PUTFLG+RELFLG
        JMP     rnddsp

        PAGE

;**     $DKN/$DKO/$DKM - OPEN statement
;
;       The OPEN statement generates one of two preambles depending upon
;       the form


;**     $DKN - Standard form of OPEN
;
;       ENTRY   (BX) = mode sdesc
;       EXIT    NONE
;       USES    NONE

$DKN:   MOV     [$$SPSV],SP
        PUSH    AX
        PUSH    BX
        CMP     WORD PTR [BX],0         ;Test for empty string
        JE      ercbfm
        MOV     BX,[BX+2]               ;(BX) = address of string
        MOV     BL,[BX]                 ;(BL) = first character
        AND     BL,-1-' '               ;Force to upper case

        MOV     AL,MD_SQI               ;Assume input
        CMP     BL,'I'
        JE      havmod

        MOV     AL,MD_SQO               ;Assume output
        CMP     BL,'O'
        JE      havmod

        MOV     AL,MD_FIL               ;Assume random
        CMP     BL,'R'
        JE      havmod

        MOV     AL,MD_APP               ;Assume append
        CMP     BL,'A'
        JNE     ercbfm                  ;error

havmod: MOV     [$FILMOD],AL            ;Save mode for $DKM call
        POP     BX
        CALL    $$DITS                  ;Delete temp string
        POP     AX
        RET

ercbfm: JMP     $ERC_BFM                ;Error - Bad file mode


;**     $DKO - SPCDSX form of OPEN statement
;
;       ENTRY   (BX) = file mode
;       USES    NONE

$DKO:   PUSH    CX
        PUSH    BX
        MOV     CL,BL                   ;(CL) = shift count
        MOV     BL,1                    ;Shifting 1
        SAL     BL,CL                   ;  (CL) bits
        MOV     [$FILMOD],BL            ;Save mode for $DKM call
        POP     BX
        POP     CX
        RET



;**     $DKM - OPEN statement processor
;
;       ENTRY   (BX) = file number
;               (DX) = file name sdesc
;               (CX) = variable record length
;       USES    NONE

$DKM:   MOV     [$$SPSV],SP
        PUSH    AX
        PUSH    SI

        PUSH    CX
        PUSH    DX
        PUSH    BX
        MOV     BX,DX                   ;(BX) = file name sdesc
        MOV     CX,[BX]                 ;(CX) = file name length
        MOV     SI,[BX+2]               ;(SI) = file name contents
        CALL    $SCANF                  ;(AL) = device #
        CALL    $$DITS                  ;Delete temp string
        POP     BX
        POP     DX
        POP     CX

        OR      BX,BX                   ;Test for 0 and neg
        JBE     ercifn
        CALL    $FBLOC                  ;Check if file open
        JNZ     ercfao                  ;  Already open

        MOV     AH,DV_OPEN
        CALL    OPEN_DISPATCH           ;Dispatch

        POP     SI
        POP     AX
        RET

ercfao: JMP     $ERC_FAO                ;Error - File already open

ercifn: JMP     $ERC_IFN                ;Error - Illegal file number


Entries ENDP


        SUBTTL  Runtime Internal routines

Locals  PROC    NEAR

;-----  Device Dispatch Routines  -----------------------------------------


;**     $INIDEV - Device initialization dispatcher
;
;       This routine calls initialization routines for each device
;       in the device table.

$INIDEV:
        MOV     BX,OFFSET INIDEV_TABLE-2        ;Adjust for no disk entry

devsub: MOV     DI,LAST_DEVICE_OFFSET-2 ;Use actual offset of last device

devlp:  PUSH    BX
        PUSH    DI
        CALL    WORD PTR CS:[BX+DI]     ;Dispatch to device routine
        POP     DI
        POP     BX
        DEC     DI
        DEC     DI
        JNZ     devlp                   ;Loop until device offset = 0
        RET



;**     $CLSDEV - Device close dispatcher
;
;       This routine calls close routines for each device
;       in the device table.

$CLSDEV:
        MOV     BX,OFFSET CLSDEV_TABLE-2        ;Adjust for no disk entry
        JMP     devsub

        PAGE
;_____  File Dispatch Routines  ------------------------------------------


;**     $BAKCHR - Backup character in (AL)
;
;       ENTRY   (AL) = character to backup
;               $PTRFIL = file data block pointer
;       USES    AH

$$BCH:
$BAKCHR:
        PUSH    SI
        MOV     SI,$PTRFIL
        OR      SI,SI
        JNZ     bakch1

        POP     SI
        JMP     $TTY_BAKC               ;Console backup

bakch1: MOV     AH,DV_BAKC

ptrdsp: CALL    PTRFIL_DISPATCH
        POP     SI
        RET



;**     $GETCHR - Input character into (AL)
;
;       ENTRY   none
;       EXIT    (AL) = character

$$RCH:
$GETCHR:
        PUSH    SI
        MOV     SI,$PTRFIL
        OR      SI,SI
        JNZ     getch1

        POP     SI
        JMP     $TTY_SINP              ;Console input

getch1: MOV     AH,DV_SINP
        JMP     ptrdsp



;**     $PUTCHR - Output character in (AL)
;
;       ENTRY   (AL) = character to output
;       EXIT    none
;       USES    AH

$$WCH:
$PUTCHR:
        PUSH    SI
        MOV     SI,$PTRFIL
        OR      SI,SI
        JNZ     putch1

        POP     SI
        JMP     $TTY_SOUT              ;Console output

putch1: MOV     AH,DV_SOUT
        JMP     ptrdsp



;**     $GETPOS - Get current file position
;
;       EXIT    (AH) = file position

$$POS:
$GETPOS:
        PUSH    SI
        MOV     SI,[$PTRFIL]
        OR      SI,SI
        JNZ     getps1

        POP     SI
        JMP     $TTY_GPOS              ;Get TTY position

getps1: MOV     AH,DV_GPOS             ;Get position
        JMP     ptrdsp



;**     $GETWID - Get current file width
;
;       EXIT    (AH) = file width

$$WID:
$GETWID:
        PUSH    SI
        MOV     SI,[$PTRFIL]
        OR      SI,SI
        JNZ     getwd1

        POP     SI
        JMP     $TTY_GWID

getwd1: MOV     AH,DV_GWID
        JMP     ptrdsp

        PAGE

;**     FILE_DISPATCH - File number to device dispatcher
;
;**     PTRFIL_DISPATCH - PTRFIL to device dispatcher
;
;**     OPEN_DISPATCH - OPEN file device dispatcher
;
;       The following information is passed to the routine:
;
;               (AL,CX,DX,BX) = parameters
;               (SI) = file block pointer
;               (DI) = device offset
;
;       Both the (SI) and (DI) registers can be used as temporaries since
;       they are not needed upon return.
;
;       FILE_DISPATCH and OPEN_DISPATCH
;
;               ENTRY   (BX) = file number
;                       (AL) = device number for OPEN_DISPATCH
;                       (AH) = function to dispatch on
;                       (AL,CX,DX) = other parameters
;               USES    AH,F
;
;       PTRFIL_DISPATCH
;
;               ENTRY   (AL) = character
;                       (SI) = FDB pointer
;               EXIT    (AL) = character
;               USES    AX,F

FILE_DISPATCH:
        PUSH    SI
        CALL    $FBLOC                  ;(SI) = file data block pointer
        JZ      ercifn                  ;Error - illegal file number
        CALL    PTRFIL_DISPATCH
        POP     SI
        RET

OPEN_DISPATCH:
        PUSH    DI
        PUSH    BX
        PUSH    AX
        JMP     SHORT opndsp

PTRFIL_DISPATCH:                        ;(SI) = file data block pointer
        PUSH    DI
        PUSH    BX
        PUSH    AX

        MOV     AL,[SI].FD_DEVICE       ;(AL) = device number
opndsp: OR      AL,AL
        JS      getdv1                  ;must be a special device
        XOR     AL,AL                   ;(AL) = 0 for disks
        JMP     SHORT getdv2
getdv1: NEG     AL                      ;(AL) = - device number for special
getdv2: CBW
        SAL     AX,1
        MOV     DI,AX                   ;(DI) = device offset
        MOV     BX,CS:$DEVICE_TABLE[DI]
        OR      BX,BX                   ;If entry is 0, then unavailable
        JZ      ercdna                  ;  Error
        POP     AX                      ;(AH) = function code
        PUSH    AX
        XCHG    AH,AL
        CBW
        ADD     BX,AX                   ;Add function code offset to dispatch
        MOV     BX,CS:[BX]              ;Get address of routine
        MOV     [DISPATCH_ADDR],BX      ;Save it for indirect call
        POP     AX                      ;Restore (AL)
        POP     BX                      ;Restore (BX)
        CALL    [DISPATCH_ADDR]         ;Execute routine
        POP     DI
        RET

ercdna: JMP     $ERC_DNA

        PAGE

;**     $CLOSF - Close all files
;
;       ENTRY   NONE
;       EXIT    NONE
;       USES    NONE

$CLOSF:
        PUSH    BX
        PUSH    SI

closf1: MOV     SI,[$FILPT]             ;Get address of next file block
        OR      SI,SI
        JZ      closf3                  ;Finished

        MOV     BL,[SI].FB_NUM          ;Get file #
        XOR     BH,BH
        CALL    FAR PTR dkc1            ;Close file in (BX)
        JMP     closf1                  ;Keep looping

closf3: POP     SI
        POP     BX
        RET

        PAGE

;**     $SCANF - Scan file name
;
;       ENTRY   (SI) = text pointer
;               (CX) = length
;       EXIT    (AL) = device #
;               FILNAM = (device # , filename.ext)
;       USES    CX,SI

$SCANF:
        CALL    PARSE_DEVICE            ;(AL) = device #
        MOV     [$FILNAM],AL            ;Save device #
        OR      AL,AL
        JS      _030
        XOR     AL,AL                   ;(AL) = 0 for disks
_030:   PUSH    AX
        PUSH    DX
        PUSH    DI
        MOV     DI,OFFSET DC:$FILNAM+1
        MOV     DX,FILNAM_LENGTH


scan1:  JCXZ    filspc                  ;End of string
        DEC     CX
        LODSB                           ;Get character
        CMP     AL,' '
        JAE     _040

ercbfn: JMP     $ERC_BFN

_040:   CMP     AL,'.'
        JE      fillnm
        STOSB                           ;Store character
        DEC     DX
        JNZ     scan1                   ;Keep looking for characters

gotnam: POP     DI
        POP     DX
        POP     AX
        RET

fillnm: CMP     DX,FILNAM_LENGTH
        JE      ercbfn                  ;Error - extension only !
        CMP     DX,3
        JB      ercbfn                  ;Error - 2nd dot
        JE      scan1                   ;Scan extension like filename
        MOV     AL,' '
        STOSB                           ;Fill with blank
        DEC     DX
        JMP     fillnm                  ;Keep filling

filspc: MOV     AL,' '                  ;Fill short name with spaces
        STOSB
        DEC     DX
        JNZ     filspc                  ;Keep filling
        JMP     gotnam                  ;Done with name

        PAGE

;**     PARSE_DEVICE - Parse device name from string
;
;       ENTRY   (CX) = length of string
;               (SI) = string address
;       EXIT    (AL) = device # (0 = default , - = special)
;               (CX) = remaining count
;               (SI) = address of remaining string

PARSE_DEVICE:
        PUSH    DX
        PUSH    DI
        PUSH    SI
        MOV     DX,CX                   ;(DX) = original length
        JCXZ    nodvnm                  ;If length = 0 , no device name

devscn: LODSB                           ;Get character
        CMP     AL,':'
        JE      devnm                   ;Found possible name
        LOOP    devscn

nodvnm: MOV     CX,DX                   ;No device name - restore everything
        POP     SI
        POP     DI
        POP     DX
        XOR     AL,AL                   ;Default device to 0
        RET

devnm:  POP     DI                      ;Restore old string pointer
        XCHG    SI,DI
        PUSH    DI                      ;Save new string pointer
        SUB     DX,CX                   ;(DX) = device name length
        JZ      ercbfn                  ;Length = 0 - bad file name
        DEC     CX                      ;Count off :
        CMP     DX,1
        JE      dsknam                  ;Length = 1 - must be disk name

        MOV     DI,OFFSET DEVICE_NAME_TABLE-1
devsrc: PUSH    SI
        PUSH    DX

devlop: INC     DI
        LODSB
        CALL    UPCASE                  ;Convert to upper case
        TEST    BYTE PTR CS:[DI],80H    ;Check to see if at device (long name)
        JNZ     nmtch2
        CMP     CS:[DI],AL
        JNE     nomtch
        DEC     DX
        JNZ     devlop

fnddev: INC     DI
        MOV     AL,CS:[DI]              ;Get device #
        OR      AL,AL
        JNS     nomtch                  ;Not a device #

        POP     SI
        POP     SI
devret: POP     SI                      ;(SI) = pointer after :
        POP     DI
        POP     DX
        RET                             ;(CX) = chars left , (AL) = device #

nmtch1: INC     DI
NOMTCH: TEST    BYTE PTR CS:[DI],80H    ;Check for device #
        JZ      nmtch1                  ;  No
nmtch2: POP     DX
        POP     SI
        CMP     BYTE PTR CS:[DI+1],0    ;End of table?
        JNE     devsrc                  ;  No - check next entry

_050:   JMP     ercbfn                  ;Error - bad filename (device name)

dsknam: LODSB                           ;Refetch character
        CALL    UPCASE
        SUB     AL,'A'-1                ;Convert letter to 1-26 (let @ be 0)
        JC      _050                    ;  Less than @
        CMP     AL,'Z' and 01FH
        JNC     _050                    ;  Greater than Z
        JMP     devret

UPCASE: CMP     AL,'a'                  ;Convert (AL) to upper case
        JB      upret
        CMP     AL,'z'
        JA      upret
        AND     AL,255-' '
upret:  RET

        PAGE

;**     $FRCSQO - Force MD_RND to MD_SQO

$FRCSQO:
        CMP     [$FILMOD],MD_RND
        JNE     frcret
        MOV     [$FILMOD],MD_SQO
frcret: RET



;**     $DEVOPN - Special device open common routine
;
;       ENTRY   (AL) = file device
;               (AH) = valid file modes
;               (CX) = buffer size (not including basic FDB size)
;               (DL) = file width
;               (DH) = initial file position
;               (BX) = file number
;       USES    CX,DI

$DEVOPN:
        TEST    [$FILMOD],AH            ;Check for valid file mode
        JZ      ercbfm1                 ;  Bad file mode

        XCHG    BX,CX
        ADD     BX,FD_BUFFER            ;(BX) = size of block to allocate
        CALL    $FBALC                  ;Allocate block
        XCHG    BX,CX                   ;(BX) = file number
        MOV     DI,[$FILPT]             ;Link in new file block
        MOV     [SI].BL_LNK,DI
        MOV     [$FILPT],SI             ;  right in front
        MOV     [SI].FB_NUM,BL          ;Set file number

        MOV     [SI].FD_DEVICE,AL       ;Set file device
        MOV     WORD PTR [SI].FD_WIDTH,DX  ;Set file width/position
        RET

ercbfm1:JMP     $ERC_BFM                ;Bad file mode


Locals  ENDP

CODE    ENDS

        END
