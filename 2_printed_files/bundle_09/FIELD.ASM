FIELD  - FIELD Statement Processors                      Macro-86 %1(12)   1:1:4  13-Nov-81     Page 1-1



    1	 	 	 	 	        TITLE   FIELD  - FIELD Statement Processors
    2	 	 	 	 	























































FIELD  - FIELD Statement Processors                      Macro-86 %1(12)   1:1:4  13-Nov-81     Page 1-2



   3	 	 	 	 	.list
   4	 	 	 	 	
   5	 	 	 	 	
   6	 0000	 	 	 	DATA    SEGMENT PUBLIC WORD 'DATA'
   7	 	 	 	 	
   8	 	 	 	 	        EXTRN   $$SPSV:WORD
   9	 	 	 	 	
   10	 0000  ????	 	 	FIELD_LEFT      DW      ?               ;Bytes left in field buffer
   11	 0002  ????	 	 	FIELD_POS       DW      ?               ;Current field position
   12	 	 	 	 	
   13	 0004	 	 	 	DATA    ENDS
   14	 	 	 	 	
   15	 	 	 	 	DC      GROUP   DATA
   16	 	 	 	 	
   17	 	 	 	 	
   18	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   19	 	 	 	 	
   20	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   21	 	 	 	 	
   22	 	 	 	 	
   23	 	 	 	 	;       Run-time entries
   24	 	 	 	 	
   25	 	 	 	 	        PUBLIC  $FLDA,$FLDB
   26	 	 	 	 	
   27	 	 	 	 	;       Externals
   28	 	 	 	 	
   29	 	 	 	 	        EXTRN   $FBLOC:NEAR, $$FSS:NEAR
   30	 	 	 	 	
   31	 	 	 	 	        EXTRN   $ERC_IFN:NEAR
   32	 	 	 	 	        EXTRN   $ERC_BFM:NEAR
   33	 	 	 	 	        EXTRN   $ERC_FOV:NEAR
   34	 	 	 	 	        EXTRN   $ERC_FC:NEAR
   35	 	 	 	 	
   36	 	 	 	 	
   37	 0000	 	 	 	Entries PROC    FAR
   38	 	 	 	 	
   39	 	 	 	 	;**     $FLDA - Field statement preamble
   40	 	 	 	 	;
   41	 	 	 	 	;       ENTRY   (BX) = file number
   42	 	 	 	 	
   43	 0000  89 26 0000 E	 	$FLDA:  MOV     [$$SPSV],SP             ;Record stack pointer
   44	 0004  50	 	 	        PUSH    AX
   45	 0005  56	 	 	        PUSH    SI
   46	 0006  E8 0000 E	 	        CALL    $FBLOC                  ;Find FDB
   47	 0009  74 37	 	 	        JZ      ercifn                  ;  Not found
   48	 000B  80 3C 04	 	 	        CMP     [SI].FD_MODE,MD_RND
   49	 000E  75 35	 	 	        JNE     ercbfm
   50	 	 	 	 	
   51	 0010  8B 84 00B3	 	        MOV     AX,[SI].FR_VRECL
   52	 0014  A3 0000 R	 	        MOV     [FIELD_LEFT],AX         ;Save field length
   53	 0017  81 C6 00BC	 	        ADD     SI,FR_FIELD             ;(SI) = field buffer address
   54	 001B  89 36 0002 R	 	        MOV     [FIELD_POS],SI          ;Save address
   55	 001F  5E	 	 	        POP     SI
   56	 0020  58	 	 	        POP     AX


FIELD  - FIELD Statement Processors                      Macro-86 %1(12)   1:1:4  13-Nov-81     Page 1-3



   57	 0021  CB	 	 	        RET
   58	 	 	 	 	
   59	 	 	 	 	
   60	 	 	 	 	
   61	 	 	 	 	;**     $FLDB - Field assignment
   62	 	 	 	 	;
   63	 	 	 	 	;       ENTRY   (BX) = String descriptor
   64	 	 	 	 	;               (DX) = field length
   65	 	 	 	 	
   66	 0022  89 26 0000 E	 	$FLDB:  MOV     [$$SPSV],SP
   67	 0026  0B D2	 	 	        OR      DX,DX
   68	 0028  78 1E	 	 	        JS      ercfc                   ;Can't have negative field length
   69	 002A  50	 	 	        PUSH    AX
   70	 002B  29 16 0000 R	 	        SUB     [FIELD_LEFT],DX         ;Count off current field
   71	 002F  72 1A	 	 	        JB      ercfov                  ;  Too big
   72	 0031  E8 0000 E	 	        CALL    $$FSS                   ;Free string space
   73	 0034  A1 0002 R	 	        MOV     AX,[FIELD_POS]          ;Get current field position
   74	 0037  89 17	 	 	        MOV     [BX],DX                 ;Set new string length
   75	 0039  89 47 02	 	 	        MOV     [BX+2],AX               ;Set new string address
   76	 003C  01 16 0002 R	 	        ADD     [FIELD_POS],DX          ;Bump to next field position
   77	 0040  58	 	 	        POP     AX
   78	 0041  CB	 	 	        RET
   79	 	 	 	 	
   80	 	 	 	 	
   81	 0042  E9 0000 E	 	ercifn: JMP     $ERC_IFN
   82	 0045  E9 0000 E	 	ercbfm: JMP     $ERC_BFM
   83	 0048  E9 0000 E	 	ercfc:  JMP     $ERC_FC
   84	 004B  E9 0000 E	 	ercfov: JMP     $ERC_FOV
   85	 	 	 	 	
   86	 004E	 	 	 	Entries ENDP
   87	 	 	 	 	
   88	 004E	 	 	 	CODE    ENDS
   89	 	 	 	 	
   90	 	 	 	 	        END






















FIELD  - FIELD Statement Processors                      Macro-86 %1(12)   1:1:4  13-Nov-81     Symbols-1



Macros:

	 	N a m e	 	 	Length

DEVMAC . . . . . . . . . . . . .        0002
DEVNAM . . . . . . . . . . . . .        0005
DSPMAC . . . . . . . . . . . . .        0001
DSPNAM . . . . . . . . . . . . .        000E
ENT. . . . . . . . . . . . . . .        0002
ENTI . . . . . . . . . . . . . .        0002
ENTORG . . . . . . . . . . . . .        0001

Structures and records:

   	 	N a m e	 	 	Width	# fields
	 	       	 	 	Shift	Width	Mask	Initial

FILE_DATA_BLOCK. . . . . . . . .        00BD    0012
  FD_MODE. . . . . . . . . . . . .      0000
  FD_FCB . . . . . . . . . . . . .      0001
  FD_CURLOC. . . . . . . . . . . .      0027
  FD_ORNOFS. . . . . . . . . . . .      0029
  FD_NMLOFS. . . . . . . . . . . .      002A
  FD_DEVICE. . . . . . . . . . . .      002E
  FD_WIDTH . . . . . . . . . . . .      002F
  FD_POS . . . . . . . . . . . . .      0030
  FD_FLAGS . . . . . . . . . . . .      0031
  FD_OUTPOS. . . . . . . . . . . .      0032
  FD_BUFFER. . . . . . . . . . . .      0033
  FR_VRECL . . . . . . . . . . . .      00B3
  FR_PHYREC. . . . . . . . . . . .      00B5
  FR_LOGREC. . . . . . . . . . . .      00B7
  FR_OUTPOS. . . . . . . . . . . .      00BA
  FR_FIELD . . . . . . . . . . . .      00BC

Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	004E	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0004	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

BL_LEN . . . . . . . . . . . . .        Number  FFFC
BL_LNK . . . . . . . . . . . . .        Number  FFFE
BL_SIZE. . . . . . . . . . . . .        Number  FFFA
DN_KYBD. . . . . . . . . . . . .        Number  FFFF
DN_LPT1. . . . . . . . . . . . .        Number  FFFD
DN_SCRN. . . . . . . . . . . . .        Number  FFFE
DV_BAKC. . . . . . . . . . . . .        Number  000E
DV_CLOSE . . . . . . . . . . . .        Number  0006


FIELD  - FIELD Statement Processors                      Macro-86 %1(12)   1:1:4  13-Nov-81     Symbols-2



DV_EOF . . . . . . . . . . . . .        Number  0000
DV_GPOS. . . . . . . . . . . . .        Number  0014
DV_GWID. . . . . . . . . . . . .        Number  0016
DV_LOC . . . . . . . . . . . . .        Number  0002
DV_LOF . . . . . . . . . . . . .        Number  0004
DV_OPEN. . . . . . . . . . . . .        Number  000C
DV_RANDIO. . . . . . . . . . . .        Number  000A
DV_SINP. . . . . . . . . . . . .        Number  0010
DV_SOUT. . . . . . . . . . . . .        Number  0012
DV_TABLEN. . . . . . . . . . . .        Number  0018
DV_Width . . . . . . . . . . . .        Number  0008
ENTRIES. . . . . . . . . . . . .	F PROC	0000	CODE	Length =004E
EOFCHR . . . . . . . . . . . . .        Number  001A
ERCBFM . . . . . . . . . . . . .	L NEAR 	0045	CODE
ERCFC. . . . . . . . . . . . . .	L NEAR 	0048	CODE
ERCFOV . . . . . . . . . . . . .	L NEAR 	004B	CODE
ERCIFN . . . . . . . . . . . . .	L NEAR 	0042	CODE
FB_NUM . . . . . . . . . . . . .        Number  FFFB
FCB_LENGTH . . . . . . . . . . .        Number  0026
FIELD_LEFT . . . . . . . . . . .	L WORD 	0000	DATA
FIELD_POS. . . . . . . . . . . .	L WORD 	0002	DATA
FILNAML. . . . . . . . . . . . .        Number  0026
FILNAM_LENGTH. . . . . . . . . .        Number  000B
LAST_DEVICE_OFFSET . . . . . . .        Number  0008
MD_APP . . . . . . . . . . . . .        Number  0008
MD_BIN . . . . . . . . . . . . .        Number  0080
MD_FIL . . . . . . . . . . . . .        Number  0004
MD_IBM . . . . . . . . . . . . .        Number  0020
MD_KIL . . . . . . . . . . . . .        Number  0010
MD_RND . . . . . . . . . . . . .        Number  0004
MD_SQI . . . . . . . . . . . . .        Number  0001
MD_SQO . . . . . . . . . . . . .        Number  0002
MD_USR . . . . . . . . . . . . .        Number  0040
REC_LENGTH . . . . . . . . . . .        Number  0080
$$FSS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ERC_BFM . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_FOV . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_IFN . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FBLOC . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FLDA. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$FLDB. . . . . . . . . . . . . .	L NEAR 	0022	CODE	Global
_CPM_. . . . . . . . . . . . . .        Number  0000
_IBM_. . . . . . . . . . . . . .        Number  0000
_MSDOS_. . . . . . . . . . . . .        Number  0001
___DEV . . . . . . . . . . . . .        Number  FFFC
___ZZZ . . . . . . . . . . . . .        Number  0018

Warning Severe
Errors	Errors 
0	0




