        PAGE

;       DEVDEF.INC - Device Independent I/O Definitions

        INCLUDE SYSTEM.INC
        PAGE

DEVNAM  MACRO
        DEVMAC  KYBD
        DEVMAC  SCRN
if      _IBM_
        DEVMAC  CAS1
        DEVMAC  COM1
        DEVMAC  COM2
endif
        DEVMAC  LPT1
if      _IBM_
        DEVMAC  LPT2
        DEVMAC  LPT3
endif
        ENDM

___DEV=         -1

DEVMAC  MACRO   ARG
DN_&ARG=        ___DEV
.xcref
___DEV=         ___DEV-1
.cref
        ENDM

        DEVNAM

LAST_DEVICE_OFFSET=     -2*___DEV       ;All devices have lower offsets
        PAGE

DSPNAM  MACRO
        DSPMAC  EOF                     ;EOF function
        DSPMAC  LOC                     ;LOC function
        DSPMAC  LOF                     ;LOF function
;       DSPMAC  POS                     ;POS function
        DSPMAC  CLOSE                   ;CLOSE statement
        DSPMAC  WIDTH                   ;WIDTH statement
        DSPMAC  RANDIO                  ;GET/PUT statements
        DSPMAC  OPEN                    ;OPEN statement
        DSPMAC  BAKC                    ;Backup character
        DSPMAC  SINP                    ;Serial input
        DSPMAC  SOUT                    ;Serial output
        DSPMAC  GPOS                    ;Get current position
        DSPMAC  GWID                    ;Get current width
        ENDM


;       Device Function Dispatch Table Offsets


DSPMAC  MACRO   func
ENT     DV_&func,2
        ENDM


ENTORG  0
        DSPNAM
ENT     DV_TABLEN,0

        PAGE

;       File Mode Definitions

MD_SQI          EQU     1
MD_SQO          EQU     2
MD_RND          EQU     4
MD_FIL          EQU     4
MD_APP          EQU     8
MD_KIL          EQU     16
MD_IBM          EQU     32
MD_USR          EQU     64
MD_BIN          EQU     128


;       Operating System dependent field sizes

EOFCHR=                 'Z' and 1fh

FILNAML=                38              ;Length of $FILNAM
FILNAM_LENGTH=          11              ;Actual length of name (8+3)

FCB_LENGTH=             38              ;38 byte FCBs
REC_LENGTH=             128             ;128 byte sectors

        PAGE

;-----  Basic Interpreter style File Data Block  -----

;       Link block offsets

BL_SIZE=        -6                      ;Link block size (2 bytes of misc)
  FB_NUM=       -5                      ;  File number
BL_LEN=         -4                      ;Block size
BL_LNK=         -2                      ;Block link

;       File Data Block offsets

FILE_DATA_BLOCK STRUC

  FD_MODE       DB      ?               ;File mode of open
  FD_FCB        DB      FCB_LENGTH DUP (?)  ;FCB area
  FD_CURLOC     DW      ?               ;Current record number
  FD_ORNOFS     DB      ?               ;Byte count in sector
  FD_NMLOFS     DB      ?               ;Bytes left in input buffer
                DB      3 DUP (?)       ;Unused
  FD_DEVICE     DB      ?               ;Device number
  FD_WIDTH      DB      ?               ;File width
  FD_POS        DB      ?               ;Current file position
  FD_FLAGS      DB      ?               ;Used for load and save
  FD_OUTPOS     DB      ?               ;Output position for tab expansion
  FD_BUFFER     DB      REC_LENGTH DUP (?)  ;File record buffer

;       5.0 Variable Record Information

  FR_VRECL      DW      ?               ;Variable record length
  FR_PHYREC     DW      ?               ;Current physical record number
  FR_LOGREC     DW      ?               ;Current logical record number
                DB      ?               ;Future use
  FR_OUTPOS     DW      ?               ;Output position for sequential I/O
  FR_FIELD      DB      1 DUP (?)       ;Field buffer

FILE_DATA_BLOCK ENDS


;       End of DEVDEF.INC
