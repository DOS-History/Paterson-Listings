        TITLE   IODISK - Disk I/O Drivers for BASCOM-86

;       This module contains the disk operating system interface
;       for the device I/O independent package.  It also includes
;       other operating system features of BASIC.

        INCLUDE TABMAC.INC

DATA    SEGMENT WORD PUBLIC 'DATA'

        INCLUDE DEVDEF.INC

        PAGE

;       Operating System Equates and Macros


;       MSDOS/CPM Operating System Function Codes

C_REST=         13
C_SDRV=         14
C_OPEN=         15
C_CLOS=         16
C_SEAR=         17
C_DELE=         19
C_READ=         20
C_WRIT=         21
C_MAKE=         22
C_RENA=         23
C_GDRV=         25
C_BUFF=         26
C_RNDR=         33
C_RNDW=         34


;       MSDOS/CPM File Control Block Offsets

FCB_FN=         1
FCB_FT=         9
FCB_EX=         12
FCB_RSIZ=       14                      ;MSDOS
FCB_RC=         15                      ;MSDOS
FCB_FSIZ=       16                      ;MSDOS
FCB_NR=         32
FCB_RN=         33


;       MSDOS Call Macro

if      _MSDOS_
CALLOS  MACRO   func
IFNB    <func>
        MOV     AH,func
ENDIF
        INT     33
        ENDM
endif

        PAGE

;       External Data Variables

        EXTRN   $FILNAM:BYTE, $FILNM2:BYTE, $FILMOD:BYTE
        EXTRN   $FILPT:WORD
        EXTRN   $$SPSV:WORD


;       Public Data Variables

if      _CPM_
        PUBLIC  $DIRTMP
$DIRTMP         DB      REC_LENGTH DUP (?)       ;Temporary buffer
endif


;       Local Data Variables

RECORD          DW      ?                        ;Current record number
LBUFF           DW      ?                        ;Logical buffer address
PBUFF           DW      ?                        ;Physical buffer address

DATA    ENDS

DC      GROUP   DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        ASSUME  CS:CODE, DS:DC, ES:DC

;       Compiler Generated Entries

        PUBLIC  $DKK,$DKR,$FL0,$FIL,$RS2,$ZZ1


;       Run-time entries

        PUBLIC  $D_DISK


;       Run-time externals

        EXTRN   $$DITS:NEAR, $SAVREG:NEAR
        EXTRN   $FBALC:NEAR, $FBDEA:NEAR
        EXTRN   $SCANF:NEAR, $CLOSF:NEAR, $DEVOPN:NEAR
        EXTRN   $$WCHT:NEAR, $$TCR:NEAR
        EXTRN   $TTY_GPOS:NEAR, $TTY_GWID:NEAR

        EXTRN   $ERC_FC:NEAR
        EXTRN   $ERC_BFM:NEAR
        EXTRN   $ERC_BFN:NEAR
        EXTRN   $ERC_BRN:NEAR
        EXTRN   $ERC_DFL:NEAR
        EXTRN   $ERC_FAE:NEAR
        EXTRN   $ERC_FAO:NEAR
        EXTRN   $ERC_FNF:NEAR
        EXTRN   $ERC_FOV:NEAR
        EXTRN   $ERC_IOE:NEAR
        EXTRN   $ERC_TMF:NEAR

if      _MSDOS_
        EXTRN   $DNORM:NEAR
endif

        PAGE

;       Device Independent Disk Interface

DSPMAC  MACRO   func
        DW      DISK_&func
        ENDM

$D_DISK:
        DSPNAM

        PAGE

devio_disk      PROC    NEAR


DISK_CLOSE:
        CMP     [SI].FD_MODE,MD_SQO
        JNE     noforc                  ;Don't dump buffer

        MOV     AL,EOFCHR
        CALL    DISK_SOUT               ;Write EOF character
        CMP     [SI].FD_ORNOFS,0
        JE      noforc                  ;Buffer already dumped

        CALL    WRITE_SECTOR            ;Write sector

noforc: PUSH    CX
        PUSH    DX
        LEA     DX,[SI].FD_FCB
        CALL    SETBUF                  ;Set buffer address
        CALLOS  C_CLOS                  ;Close file
        CALL    $FBDEA                  ;Deallocate file buffer
        POP     DX
        POP     CX
        RET



DISK_EOF:
        CMP     [SI].FD_MODE,MD_SQO
        JE      ercbfm                  ;Not for output files

ornchk: CMP     [SI].FD_ORNOFS,0
        JE      waseof

        XOR     BX,BX
        CMP     [SI].FD_MODE,MD_RND
        JE      eofret                  ;Not end of file

        CMP     [SI].FD_NMLOFS,BL       ;(BX) is 0
        JNE     chkctz                  ;Still characters in teh buffer

        CALL    READ_SECTOR             ;Read next sector
        JMP     ornchk

chkctz: MOV     BX,REC_LENGTH
        SUB     BL,[SI].FD_NMLOFS       ;(BX) = character offset
        CMP     [SI+BX].FD_BUFFER,EOFCHR

waseof: MOV     BX,0                    ;(BX) = not end of file
        JNE     eofret
        DEC     BX                      ;(BX) = -1 if end of file
eofret: RET

ercbfm: JMP     $ERC_BFM

DISK_LOC:
        CMP     [SI].FD_MODE,MD_RND
        MOV     BX,[SI].FD_CURLOC       ;Use CURLOC for sequential
        JNE     loc1
        MOV     BX,[SI].FR_LOGREC       ;Use LOGREC for random
loc1:   RET



DISK_LOF:
        PUSH    CX
        PUSH    DX
        PUSH    BX
        MOV     DX,WORD PTR [SI].FD_FCB+FCB_FSIZ ;Get length of file
        MOV     CX,WORD PTR [SI].FD_FCB+FCB_FSIZ+2
        XOR     BX,BX
        XOR     DI,DI
        MOV     AX,(64+80h)*100h                ;(AX) = (exp+128,sign)
        CALL    $DNORM                          ;Normalize as double
        POP     BX
        POP     DX
        POP     CX
        RET



DISK_POS:
        XOR     BX,BX
        MOV     BL,[SI].FD_OUTPOS       ;(BX) = current file position
        RET



DISK_WIDTH:
        MOV     [SI].FD_WIDTH,DL        ;Set file width
        RET

        PAGE

DISK_BAKC:
        INC     [SI].FD_NMLOFS          ;Backup 1 character
        RET



DISK_GPOS:
        MOV     AH,[SI].FD_OUTPOS       ;Get file output position
        RET



DISK_GWID:
        MOV     AH,[SI].FD_WIDTH        ;Get file width
        RET

        PAGE

DISK_SINPB:
        CMP     [SI].FD_MODE,MD_RND
        JNE     sinp1

        JMP     SINP_50                 ;Serial input from random

sinp1:  CMP     [SI].FD_NMLOFS,0
        JE      fillsq                  ;Sector is empty - get another

        PUSH    BX
        XOR     BX,BX
        MOV     BL,[SI].FD_ORNOFS
        SUB     BL,[SI].FD_NMLOFS
        DEC     [SI].FD_NMLOFS
        MOV     AL,[SI+BX].FD_BUFFER    ;(AL) = character
        POP     BX
        OR      AL,AL                   ;Clear carry
        RET

fillsq: CMP     [SI].FD_ORNOFS,0
        JE      fills1                  ;At end of file

        CALL    READ_SECTOR             ;Read next sector
        JNE     DISK_SINP               ;  Not at eof - try with new buffer

fills1: STC                             ;Set carry
        MOV     AL,EOFCHR               ;Return EOF character

sinret: RET

DISK_SINP:
        CALL    DISK_SINPB              ;Read binary character
        JC      sinret                  ;  End of file

        CMP     AL,EOFCHR               ;End of file character?
        CLC                             ;Assume not
        JNE     sinret                  ;  Return

        MOV     [SI].FD_ORNOFS,0        ;Clear these offsets
        MOV     [SI].FD_NMLOFS,0
        STC
        RET

SINP_50:                                ;Serial input from random file
        PUSH    BX
        CALL    FOVCHK                  ;Field overflow check
        MOV     AL,[SI+BX-1].FR_FIELD   ;Get character
        CLC                             ;Clear carry
        POP     BX
        RET


FOVCHK: MOV     BX,[SI].FR_OUTPOS       ;Get current position
        CMP     BX,[SI].FR_VRECL        ;Check for end of record
        JE      ercfov                  ;  Yes - field overflow
        INC     BX                      ;Bump pointer
        MOV     [SI].FR_OUTPOS,BX       ;Save  new position
        RET

ercfov: JMP     $ERC_FOV

        PAGE

CR=             13

DISK_SOUT:
        CMP     [SI].FD_MODE,MD_RND
        JNE     sout1

        JMP     SOUT_50                 ;Serial output to random

sout1:  CMP     [SI].FD_ORNOFS,REC_LENGTH
        JNE     sout2                   ;Not at end of sector

        PUSH    AX
        CALL    WRITE_SECTOR            ;Write previous sector
        POP     AX

sout2:  PUSH    BX
        XOR     BX,BX
        MOV     BL,[SI].FD_ORNOFS       ;(BX) = buffer offset
        MOV     [SI+BX].FD_BUFFER,AL    ;Stuff character
        POP     BX
        INC     [SI].FD_ORNOFS

soutps: CMP     AL,CR
        JNE     sout3

        MOV     [SI].FD_OUTPOS,0        ;Zero position
        RET

sout3:  CMP     AL,' '
        CMC
        ADC     [SI].FD_OUTPOS,0        ;Add 1 if printing character
        RET

SOUT_50:                                ;Serial output to random file
        PUSH    BX
        CALL    FOVCHK                  ;Check for field overflow
        MOV     [SI+BX-1].FR_FIELD,AL   ;Store character
        POP     BX
        JMP     soutps                  ;Update position

        PAGE

DISK_OPEN:
        PUSH    DX
        PUSH    CX

        CMP     [$FILMOD],MD_RND        ;See if random
        JNE     notrnd                  ;  No
        OR      CX,CX                   ;See if default record size
        JNE     notrnd                  ;  No
        MOV     CX,REC_LENGTH           ;Use record length as default
notrnd: PUSH    CX                      ;Save it for now
___TMP=         FR_FIELD-FD_BUFFER      ;Size beyond basic FDB
        ADD     CX,___TMP
        MOV     DX,255                  ;(DH,DL) = position,width
        MOV     AH,255                  ;(AH) = all file modes legal
        CALL    $DEVOPN                 ;Allocate file block, etc.
        POP     CX                      ;Get it back
        MOV     [SI].FR_VRECL,CX        ;Set random record length
        PUSH    SI
        LEA     DI,[SI].FD_FCB
        MOV     SI,OFFSET DC:$FILNAM
        MOV     CX,FILNAM_LENGTH+1      ;+1 for drive
        REP     MOVSB                   ;Move in name into file block
        POP     SI
        CALL    SETBUF                  ;Set buffer address

if      _MSDOS_
        CMP     [$FILMOD],MD_APP
        JNE     nochk
        CALL    CHKFOP                  ;See if open
nochk:
endif

        LEA     DX,[SI].FD_FCB          ;(DX) = FCB address
        CMP     [$FILMOD],MD_SQO
        JNE     opnfil                  ;Not sequential output

if      _MSDOS_
        CALL    CHKFOP                  ;Check if already open
endif

        CALLOS  C_DELE                  ;Delete existing file

makfil: CALLOS  C_MAKE                  ;Create new file
        INC     AL
        JNZ     opnset                  ;Continue with OPEN
        JMP     erctmf                  ;Directory full

opnfil: CALLOS  C_OPEN                  ;Open existing file
        INC     AL
        JNE     opnset                  ;Continue with OPEN

if      _MSDOS_
        CMP     [$FILMOD],MD_APP
        JNE     ntapnf

        MOV     [$FILMOD],MD_SQO        ;Default to sequential output
        JMP     makfil
ntapnf:
endif

        CMP     [$FILMOD],MD_RND
        JE      makfil                  ;Create file for random
        JMP     ercfnf

opnset: MOV     AL,[$FILMOD]
        MOV     [SI].FD_MODE,AL         ;Everything is OK - set file mode

if      _MSDOS_
        MOV     WORD PTR [SI].FD_FCB+FCB_RSIZ,REC_LENGTH
endif

        CMP     [SI].FD_MODE,MD_RND
        JE      opnret                  ;Done if random

if      _MSDOS_
        CMP     [SI].FD_MODE,MD_APP
        JE      appfin                  ;Special if append
endif

        CMP     [SI].FD_MODE,MD_SQI
        JNE     opnret                  ;Done if not input

        CALL    READ_SECTOR             ;Read 1st sector

opnret: POP     CX
        POP     DX
        RET

if      _MSDOS_

appfin:                                 ;Special code to find end of file

        CMP     WORD PTR [SI].FD_FCB+FCB_FSIZ,0 ;Test for empty file
        JNE     ntzrfl
        CMP     WORD PTR [SI].FD_FCB+FCB_FSIZ+2,0
        JNE     ntzrfl

        MOV     [SI].FD_MODE,MD_SQO     ;Set mode to output
        JMP     opnret                  ;  and return

ntzrfl: LEA     DI,[SI].FD_FCB+FCB_RN   ;Point to random record number
        PUSH    SI
        ADD     SI,FD_FCB+FCB_FSIZ      ;Point to file size
        TEST    BYTE PTR [SI],127       ;See if multiple of 128
        PUSHF                           ;  Save flags
        LODSB                           ;Get low order byte of file size
        SAL     AL,1                    ;Rotate high bit into carry
        LODSW                           ;Get middle word
        SAL     AX,1                    ;Rotate carry in and high bit out
        STOSW                           ;Save low word of file size
        LODSB                           ;Get high order byte
        MOV     AH,0                    ;Clear high byte of record number
        SAL     AX,1                    ;Rotate carry in
        STOSW                           ;Save high word of record number
        POPF                            ;Restore flags
        POP     SI                      ;Restore pointer to file data block
        JNZ     nomtrc                  ;Record is not empty

        CALL    BAKURN                  ;Backup record number

nomtrc: CALL    READ_SECTOR             ;Read record
        CALL    BAKURN                  ;Backup record number
        XOR     DX,DX                   ;Number of characters in buffer

redoef: CALL    DISK_SINPB              ;Read binary character
        JC      setsqm                  ;  Hit physical EOF

        CMP     AL,EOFCHR
        JE      setsqo                  ;Found end of file

        INC     DX
        JMP     redoef                  ;Keep looping

setsqm: XOR     DX,DX                   ;Start of record
        CALL    BAKURN                  ;Read 1 past

setsqo: MOV     [SI].FD_MODE,MD_SQO     ;Ready for sequential output now
        LEA     DI,[SI].FD_CURLOC       ;Point to current location
        XOR     AX,AX
        STOSW                           ;Clear current location
        MOV     [DI],DL                 ;Set number of bytes in buffer
        MOV     [SI].FD_OUTPOS,AL       ;Clear print position
        JMP     opnret                  ;Done with append

BAKURN: SUB     WORD PTR [SI].FD_FCB+FCB_RN,1 ;Decrement random record number
        JAE     bakret                  ;Done - no underflow
        DEC     WORD PTR [SI].FD_FCB+FCB_RN+2 ;Decrement high word
bakret: RET

endif

        PAGE

PUTFLG=         1                       ;on = PUT , off = GET
RELFLG=         2                       ;on = relative , off = sequential
DIRFLG=         4                       ;on = WRITE , off = READ

ercfc:  JMP     $ERC_FC
ercbrn: JMP     $ERC_BRN

DISK_RANDIO:
        PUSH    CX
        PUSH    DX
        PUSH    BX
        TEST    AL,RELFLG               ;Check for relative record number
        JNZ     rand1

        MOV     DX,[SI].FR_LOGREC       ;(DX) = current logical record
        INC     DX                      ;Bump by 1
        JMP     SHORT rand2

rand1:  OR      DX,DX                   ;Check for bad record number
        JLE     ercbrn                  ;  Error - 0 or negative

rand2:  MOV     [SI].FR_LOGREC,DX       ;Save next record number
        DEC     DX                      ;(DX) = current logical record number
        MOV     [SI].FR_OUTPOS,0        ;Clear output position
        MOV     BX,[SI].FR_VRECL        ;(BX) = logical record length
        PUSH    BX
        CMP     BX,REC_LENGTH           ;Check if logical size = physical
        JE      rand3

        XCHG    AX,BX                   ;Save (AL) for now
        MUL     DX                      ;(DX,AX) = record * size (byte offset)
        XCHG    AX,BX                   ;(DX,BX) = result
        ADD     BX,BX                   ;Offset * 2 (for /128)
        ADC     DX,DX
        OR      DH,DH                   ;Test for too big
        JNZ     ercfc                   ;  Yes
        MOV     DH,DL
        MOV     DL,BH                   ;(DX) = physical record number
        SHR     BL,1
        XOR     BH,BH                   ;(BX) = offset into physical record
        JMP     SHORT rand4

rand3:  XOR     BX,BX                   ;(BX) = 0 (offset)

;       (DX) = physical record number
;       (BX) = offset into physical record

rand4:  MOV     [RECORD],DX             ;Save record number
        LEA     CX,[SI].FR_FIELD        ;(CX) = logical buffer address
        MOV     [LBUFF],CX              ;Save as LBUFF
        POP     DX                      ;Get record length

;       (DX) = bytes left to transfer (initially record length)
;       (BX) = offset into current record

nxtopd: LEA     CX,[SI].FD_BUFFER       ;(CX) = physical buffer address
        ADD     CX,BX                   ;Add in offset
        MOV     [PBUFF],CX              ;Save in PBUFF
        MOV     CX,REC_LENGTH
        SUB     CX,BX                   ;(CX) = bytes left in sector
        CMP     CX,DX                   ;find smaller left (buffer : record)
        JB      datmof                  ;(CX) = left in buffer
        MOV     CX,DX                   ;(CX) = left in record
datmof: TEST    AL,PUTFLG               ;Check for read (GET)
        JZ      fivdrd                  ;  Yes

        CMP     CX,REC_LENGTH           ;Writing entire sector?
        JAE     nofvrd                  ;  Yes

        CALL    GETSUB                  ;Read current sector

nofvrd: PUSH    SI                      ;Move logical to physical
        PUSH    CX
        MOV     SI,[LBUFF]
        MOV     DI,[PBUFF]
        SHR     CX,1
        REP     MOVSW
        JNC     evenlp
        MOVSB
evenlp: POP     CX
        POP     SI

        CALL    PUTSUB                  ;Write through to current sector

nxfvbf: INC     [RECORD]                ;Bump current record number
        ADD     [LBUFF],CX              ;Bump logical buffer offset
        SUB     DX,CX                   ;Subtract bytes transferred
        XOR     BX,BX                   ;Zero offset into buffer
        OR      DX,DX                   ;Check for more to transfer
        JNZ     nxtopd                  ;  Yes - keep looping

        POP     BX
        POP     DX
        POP     CX
        RET

fivdrd: CALL    GETSUB                  ;Read current record

        PUSH    SI                      ;Transfer from physical to logical
        PUSH    CX
        MOV     SI,[PBUFF]
        MOV     DI,[LBUFF]
        SHR     CX,1
        REP     MOVSW
        JNC     evenpl
        MOVSB
evenpl: POP     CX
        POP     SI
        JMP     nxfvbf                  ;Go to common code

;       Sector I/O routines for random

PUTSUB: OR      AL,DIRFLG               ;Set write flag
        JMP     SHORT pgsub1

GETSUB: AND     AL,not DIRFLG           ;Clear write flag (read)

pgsub1: PUSH    AX
        PUSH    CX
        PUSH    DX
        PUSH    BX
        MOV     BX,[RECORD]             ;Get record number
        INC     BX
        CMP     BX,[SI].FR_PHYREC       ;Check if current record in buffer
        JNE     ntreds                  ;  No

        TEST    AL,DIRFLG               ;Check if read
        JZ      pgret                   ;  Yes - do not bother

ntreds: DEC     BX
        MOV     [SI].FD_CURLOC,BX       ;Set CURLOC to physical record
        MOV     [SI].FD_ORNOFS,REC_LENGTH
        MOV     [SI].FD_NMLOFS,REC_LENGTH
        MOV     WORD PTR [SI].FD_FCB+FCB_RN,BX  ;Set record number
        MOV     WORD PTR [SI].FD_FCB+FCB_RN+2,0

        TEST    AL,DIRFLG               ;Check if read
        JZ      get1                    ;  Yes - read

        CALL    WRITE_SECTOR            ;Write it
        JMP     SHORT pgret             ;Done

get1:   CALL    READ_SECTOR             ;Read it

pgret:  POP     BX
        POP     DX
        POP     CX
        POP     AX
        RET


devio_disk      ENDP


;       Utility routines for disk I/O


locals  PROC    NEAR


READ_SECTOR:
        INC     [SI].FD_CURLOC          ;Bump logical record number

        PUSH    CX
        PUSH    DI
        MOV     CX,REC_LENGTH/2
        XOR     AX,AX
        LEA     DI,[SI].FD_BUFFER
        REP     STOSW                   ;Clear buffer
        POP     DI
        POP     CX

        CALL    SETBUF                  ;Set buffer address
        MOV     AH,C_RNDR
        CALL    ACCFIL                  ;Read random
        OR      AL,AL
        MOV     AL,0                    ;Length = 0 for end of file
        JNZ     read1

        MOV     AL,REC_LENGTH           ;Length = sector size

read1:  MOV     [SI].FD_ORNOFS,AL       ;Set number bytes read
        MOV     [SI].FD_NMLOFS,AL       ;Set number of bytes left
        OR      AL,AL                   ;'Z' set if end of file
        RET



WRITE_SECTOR:
        MOV     [SI].FD_ORNOFS,0        ;Clear offset into buffer
        CALL    SETBUF                  ;Set buffer address
        MOV     AH,C_RNDW
        CALL    ACCFIL                  ;Random write
        CMP     AL,255
        JE      erctmf                  ;Too many files
        DEC     AL
        JZ      ercioe                  ;Error estending file
        DEC     AL
        JNZ     write1

        MOV     [SI].FD_MODE,AL         ;Clear mode - disk full
        LEA     DX,[SI].FD_FCB
        CALLOS  C_CLOS                  ;Close file
        JMP     $ERC_DFL                ;Disk full error

write1: INC     [SI].FD_CURLOC          ;Bump current location
        RET

erctmf: JMP     $ERC_TMF

ercioe: JMP     $ERC_IOE



SETBUF: PUSH    CX                      ;Set buffer address
        PUSH    DX
        LEA     DX,[SI].FD_BUFFER
        CALLOS  C_BUFF
        POP     DX
        POP     CX
        RET



ACCFIL: PUSH    CX                      ;Access file
        PUSH    DX
        LEA     DX,[SI].FD_FCB
        CALLOS                          ;Call operating system
        INC     WORD PTR [SI].FD_FCB+FCB_RN ;Bump record number
        JNZ     accfl1
        INC     WORD PTR [SI].FD_FCB+FCB_RN+2 ;Bump high order bytes
accfl1: CMP     AH,C_RNDW
        JNE     accfl2
        OR      AL,AL
        JZ      accret                  ;No error
        CMP     AL,5
        JE      erctmf                  ;5 - Too many files
        CMP     AL,3
        MOV     AL,1                    ;Map 3 to 1
        JE      accret
        INC     AL                      ;Disk space full
        JMP     SHORT accret

accfl2:
if      _MSDOS_
        CMP     AL,3                    ;Test for partial sector read
        JNE     accret
        XOR     AL,AL                   ;Map 3 to 0 (no error)
endif
accret: POP     DX
        POP     CX
        RET



NAMFIL: PUSH    AX
        PUSH    CX
        PUSH    SI
        MOV     CX,[BX]                 ;(CX) = string length
        MOV     SI,[BX+2]               ;(SI) = string address
        CALL    $SCANF                  ;Scan file name
        TEST    AL,80h                  ;Check for special devices
        JS      ercbfn                  ;Illegal device name (only disk)
        CALL    $$DITS                  ;Delete temporary strings
        POP     SI
        POP     CX
        POP     AX
        RET

ercbfn: JMP     $ERC_BFN



if      _MSDOS_
;**     CHKFOP - Check for file already open
;
;       ENTRY   (SI) = file data block pointer
;       USES    AX

CHKFOP: PUSH    DI
        CMP     [SI].FD_FCB,0           ;Default drive?
        JNE     ntcdrv                  ;  No

        CALLOS  C_GDRV                  ;Get drive number
        INC     AL                      ;  Convert to A=1, etc.
        MOV     [SI].FD_FCB,AL          ;Save drive number

ntcdrv: MOV     DI,OFFSET DC:$FILPT-BL_LNK  ;Must link through open file list

chklop: MOV     DI,[DI].BL_LNK          ;Chain to next entry
        OR      DI,DI                   ;Test for end of list
        JE      chkret                  ;  Done

        CMP     SI,DI                   ;Same file?
        JE      chklop                  ;  Yes - skip this one

        PUSH    SI
        PUSH    DI
        INC     SI                      ;Point to FCB's
        INC     DI
        MOV     CX,FILNAM_LENGTH+1      ;+1 for drive
        REPZ    CMPSB                   ;Compare strings
        POP     DI
        POP     SI
        JNE     chklop                  ;Not equal - keep going

        JMP     $ERC_FAO                ;File already open

chkret: POP     DI
        RET
endif


locals  ENDP


;       Compiler Generated Library Calls

entries PROC    NEAR


;**     $FL0 and $FIL - FILES statement

;**     $FL0
;
;       ENTRY   NONE
;       EXIT    NONE

$FL0:   CALL    $SAVREG
        MOV     BX,OFFSET DC:$FILNAM
        MOV     BYTE PTR [BX],0         ;Select default drive
        INC     BX
        MOV     CL,11
        CALL    FILQST                  ;Fill name with ?
        JMP     SHORT fil01             ;Go to common code


;**     $FIL
;
;       ENTRY   (BX) = filename sdesc
;       USES    NONE

$FIL:   CALL    $SAVREG
        CALL    NAMFIL                  ;Scan file name
fil01:
        MOV     BYTE PTR [$FILNAM+12],0 ;Clear extent byte
        MOV     BX,OFFSET DC:$FILNAM+1  ;Point to filename
        MOV     CL,8
        CALL    FILQS
        MOV     BX,OFFSET DC:$FILNAM+9  ;Point to extension
        MOV     CL,3
        CALL    FILQS
if      _MSDOS_
        MOV     DX,OFFSET DC:$FILNM2    ;For MSDOS
else
        MOV     DX,OFFSET DC:$DIRTMP    ;For CPM
endif
        CALLOS  C_BUFF                  ;Set buffer address
        MOV     DX,OFFSET DC:$FILNAM
        CALLOS  C_SEAR                  ;Search for filename
        CMP     AL,255                  ;Test for 1st occurence of file
        JZ      ercfnf                  ;  Not found

filnxt: MOV     SI,OFFSET DC:$FILNM2+1  ;Point to file name
        MOV     CX,11                   ;Characters in name

mornam: LODSB                           ;Get character
        CALL    $$WCHT                  ;Output it
        CMP     CX,4
        JNE     notext                  ;Not an extension break

        MOV     AL,[SI]                 ;Get 1st char of extension
        CMP     AL,' '
        JE      prispa                  ;Blank extension - print space

        MOV     AL,'.'                  ;Print .

prispa: CALL    $$WCHT                  ;Print blank or dot

notext: LOOP    mornam                  ;Loop until 11 characters

        CALL    $TTY_GPOS               ;Get TTY position
        XCHG    AL,AH
        ADD     AL,14-_IBM_             ;Position after next file name
        CALL    $TTY_GWID               ;Get TTY width
        CMP     AL,AH
        JAE     nwfiln                  ;Force CR/LF

        MOV     AL,' '
ife     _IBM_
        CALL    $$WCHT
endif
        CALL    $$WCHT
        JMP     SHORT nextfl

nwfiln: CALL    $$TCR                   ;Type CR/LF

nextfl: MOV     DX,OFFSET DC:$FILNAM
        CALLOS  C_SEAR+1
        CMP     AL,255
        JNE     filnxt                  ;Still more

nwfil2: RET



;**     $DKK - KILL filename
;
;       ENTRY   (BX) = filename sdesc
;       USES    NONE

$DKK:   CALL    $SAVREG
        CALL    NAMFIL                  ;Scan file name
if      _CPM_
        MOV     DX,OFFSET DC:$DIRTMP    ;Temporary buffer
        CALLOS  C_BUFF                  ;Set buffer address
endif
        MOV     DX,OFFSET DC:$FILNAM
        CALLOS  C_OPEN                  ;Open file
        INC     AL
        JZ      ercfnf                  ;File not found
        CALLOS  C_CLOS                  ;Close file
if      _MSDOS_
        MOV     SI,OFFSET DC:$FILNAM-1  ;Pretend we are FDB
        CALL    CHKFOP                  ;Check for conflict with open files
endif
        CALLOS  C_DELE                  ;Delete file
        RET

ercfnf: JMP     $ERC_FNF                ;File not found



;**     $DKR - NAME statement
;
;       ENTRY   (BX) = source name
;               (DX) = dest name
;       EXIT    NONE

$DKR:   CALL    $SAVREG
        PUSH    DX                      ;Save dest name
        CALL    NAMFIL                  ;Scan old file name
        MOV     DX,OFFSET DC:$FILNAM
        CALLOS  C_OPEN
        INC     AL
        JZ      ercfnf                  ;File not found
        MOV     SI,DX
        MOV     DI,OFFSET DC:$FILNM2
        MOV     CX,FILNAM_LENGTH+1      ;+1 for drive
        REP     MOVSB                   ;Move name
        POP     BX                      ;Pop dest name
        CALL    NAMFIL                  ;Scan new filename
        CALLOS  C_OPEN
        INC     AL
        JNZ     ercfae                  ;File already exists

if      _CPM_
        MOV     AL,[$FILNAM]            ;Test to see if drives match
        CMP     [$FILNM2],AL
        JE      drvsok
        JMP     $ERC_FC                 ;Illegal function call
drvsok:
endif

if      _MSDOS_
        MOV     SI,DX
        INC     SI                      ;(SI) = $FILNAM+1
        MOV     DI,OFFSET DC:$FILNM2+17 ;(DI) = dest for new file name
        MOV     CX,FILNAM_LENGTH        ;No drive code
        REP     MOVSB                   ;Move name
endif

        MOV     DX,OFFSET DC:$FILNM2    ;Point to 2nd FCB
        CALLOS  C_RENA                  ;Rename file
        RET

ercfae: JMP     $ERC_FAE                ;File already exists



;**     $RS2 - RESET statement;
;
;       ENTRY   NONE
;       EXIT    NONE

$ZZ1:
$RS2:   CALL    $SAVREG
        CALL    $CLOSF                  ;Close all files
        CALLOS  C_GDRV                  ;Get drive number
        PUSH    AX
        CALLOS  C_REST                  ;Restore
        POP     AX
        MOV     DL,AL
        CALLOS  C_SDRV                  ;Set drive number
        RET


entries ENDP

filprc  PROC    NEAR

filqs:  CMP     BYTE PTR [BX],'*'       ;Test for *
        JNE     filret

filqst: MOV     BYTE PTR [BX],'?'       ;Fill with ?
        INC     BX
        DEC     CL
        JNZ     filqst                  ;Keep looping

filret: RET

filprc  ENDP

CODE    ENDS

        END
