PR0A - Prepare for printing                              Macro-86 %1(12)   1:6:45  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   PR0A - Prepare for printing
    2	 	 	 	 	
    3	 	 	 	 	;       *PR0A - PRINT, no USING, no #
    4	 	 	 	 	;        PR0B - PRINT USING
    5	 	 	 	 	;       *PR0C - PRINT #
    6	 	 	 	 	;        PR0D - PRINT USING #
    7	 	 	 	 	;       *PR0E - LPRINT
    8	 	 	 	 	;        PR0F - LPRINT USING
    9	 	 	 	 	;       *WRI - WRITE
   10	 	 	 	 	;       *WRD - WRITE #
   11	 	 	 	 	; * Only these included in this module
   12	 	 	 	 	












































PR0A - Prepare for printing                              Macro-86 %1(12)   1:6:45  13-Nov-81    Page 1-2



   13	 	 	 	 	.list
   14	 	 	 	 	
   15	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
   16	 	 	 	 	
   17	 	 	 	 	        EXTRN   $$PUFL:BYTE,$$WRFL:BYTE,$PTRFIL:WORD,$$SPSV:WORD
   18	 	 	 	 	
   19	 0000	 	 	 	DATA    ENDS
   20	 	 	 	 	
   21	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
   22	 	 	 	 	
   23	 	 	 	 	        EXTRN   $LPTFDB:BYTE
   24	 	 	 	 	
   25	 0000	 	 	 	CONST   ENDS
   26	 	 	 	 	
   27	 	 	 	 	DC      GROUP   CONST,DATA
   28	 	 	 	 	
   29	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   30	 	 	 	 	
   31	 	 	 	 	        PUBLIC  $PR0A,$PR0C,$PR0E,$WRI,$WRD
   32	 	 	 	 	
   33	 	 	 	 	        EXTRN   $FBLOC:NEAR
   34	 	 	 	 	        EXTRN   $ERC_IFN:NEAR,$ERC_BFM:NEAR
   35	 	 	 	 	
   36	 	 	 	 	        ASSUME  CS:CODE,DS:DC,ES:DC
   37	 	 	 	 	
   38	 0000	 	 	 	Entries PROC    FAR
   39	 	 	 	 	
   40	 0000  C6 06 0000 E 00	 	$PR0A:  MOV     [$$WRFL],0
   41	 	 	 	 	
   42	 0005  C7 06 0000 E 0000	pr0:    MOV     [$PTRFIL],0
   43	 	 	 	 	
   44	 000B  C6 06 0000 E 00	 	pr1:    MOV     [$$PUFL],0
   45	 0010  CB	 	 	        RET
   46	 	 	 	 	
   47	 0011  C6 06 0000 E 01	 	$WRI:   MOV     [$$WRFL],1
   48	 0016  EB ED	 	 	        JMP     pr0
   49	 	 	 	 	
   50	 0018  E8 0035 R	 	$PR0C:  CALL    pr0c
   51	 001B  EB 07 90	 	 	        JMP     pr3
   52	 	 	 	 	
   53	 001E  C7 06 0000 E 0000 E	$PR0E:  MOV     [$PTRFIL],OFFSET DC:$LPTFDB
   54	 	 	 	 	
   55	 0024  C6 06 0000 E 00	 	pr3:    MOV     [$$WRFL],0
   56	 0029  EB E0	 	 	        JMP     pr1
   57	 	 	 	 	
   58	 002B  E8 0035 R	 	$WRD:   CALL    pr0c
   59	 002E  C6 06 0000 E 01	 	        MOV     [$$WRFL],1
   60	 0033  EB D6	 	 	        JMP     pr1
   61	 	 	 	 	
   62	 0035	 	 	 	Entries ENDP
   63	 	 	 	 	
   64	 0035	 	 	 	Locals  PROC    NEAR
   65	 	 	 	 	
   66	 0035  89 26 0000 E	 	pr0c:   MOV     [$$SPSV],SP


PR0A - Prepare for printing                              Macro-86 %1(12)   1:6:45  13-Nov-81    Page 1-3



   67	 0039  83 06 0000 E 02	 	        ADD     [$$SPSV],2
   68	 003E  56	 	 	        PUSH    SI
   69	 003F  E8 0000 E	 	        CALL    $FBLOC                  ;See if file exists
   70	 0042  74 0B	 	 	        JZ      ercifn
   71	 0044  80 3C 01	 	 	        CMP     [SI].FD_MODE,MD_SQI
   72	 0047  74 09	 	 	        JE      ercbfm
   73	 0049  89 36 0000 E	 	        MOV     [$PTRFIL],SI
   74	 004D  5E	 	 	        POP     SI
   75	 004E  C3	 	 	        RET
   76	 	 	 	 	
   77	 004F  E9 0000 E	 	ercifn: JMP     $ERC_IFN
   78	 	 	 	 	
   79	 0052  E9 0000 E	 	ercbfm: JMP     $ERC_BFM
   80	 	 	 	 	
   81	 0055	 	 	 	Locals  ENDP
   82	 	 	 	 	
   83	 0055	 	 	 	CODE    ENDS
   84	 	 	 	 	
   85	 	 	 	 	        END





































PR0A - Prepare for printing                              Macro-86 %1(12)   1:6:45  13-Nov-81    Symbols-1



Macros:

                N a m e                 Length

DEVMAC . . . . . . . . . . . . .        0002    
DEVNAM . . . . . . . . . . . . .        0005    
DSPMAC . . . . . . . . . . . . .        0001    
DSPNAM . . . . . . . . . . . . .        000E    
ENT. . . . . . . . . . . . . . .        0002    
ENTI . . . . . . . . . . . . . .        0002    
ENTORG . . . . . . . . . . . . .        0001    

Structures and records:

                N a m e                 Width   # fields
                                        Shift   Width   Mask    Initial

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

CODE . . . . . . . . . . . . . .	0055	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  CONST. . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'CONST'
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

BL_LEN . . . . . . . . . . . . .        Number  FFFC
BL_LNK . . . . . . . . . . . . .        Number  FFFE
BL_SIZE. . . . . . . . . . . . .        Number  FFFA
DN_KYBD. . . . . . . . . . . . .        Number  FFFF
DN_LPT1. . . . . . . . . . . . .        Number  FFFD
DN_SCRN. . . . . . . . . . . . .        Number  FFFE
DV_BAKC. . . . . . . . . . . . .        Number  000E


PR0A - Prepare for printing                              Macro-86 %1(12)   1:6:45  13-Nov-81    Symbols-2



DV_CLOSE . . . . . . . . . . . .        Number  0006
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
DV_WIDTH . . . . . . . . . . . .        Number  0008
ENTRIES. . . . . . . . . . . . .	F PROC	0000	CODE	Length =0035
EOFCHR . . . . . . . . . . . . .        Number  001A
ERCBFM . . . . . . . . . . . . .	L NEAR 	0052	CODE
ERCIFN . . . . . . . . . . . . .	L NEAR 	004F	CODE
FB_NUM . . . . . . . . . . . . .        Number  FFFB
FCB_LENGTH . . . . . . . . . . .        Number  0026
FILNAML. . . . . . . . . . . . .        Number  0026
FILNAM_LENGTH. . . . . . . . . .        Number  000B
LAST_DEVICE_OFFSET . . . . . . .        Number  0008
LOCALS . . . . . . . . . . . . .	N PROC	0035	CODE	Length =0020
MD_APP . . . . . . . . . . . . .        Number  0008
MD_BIN . . . . . . . . . . . . .        Number  0080
MD_FIL . . . . . . . . . . . . .        Number  0004
MD_IBM . . . . . . . . . . . . .        Number  0020
MD_KIL . . . . . . . . . . . . .        Number  0010
MD_RND . . . . . . . . . . . . .        Number  0004
MD_SQI . . . . . . . . . . . . .        Number  0001
MD_SQO . . . . . . . . . . . . .        Number  0002
MD_USR . . . . . . . . . . . . .        Number  0040
PR0. . . . . . . . . . . . . . .	L NEAR 	0005	CODE
PR0C . . . . . . . . . . . . . .	L NEAR 	0035	CODE
PR1. . . . . . . . . . . . . . .	L NEAR 	000B	CODE
PR3. . . . . . . . . . . . . . .	L NEAR 	0024	CODE
REC_LENGTH . . . . . . . . . . .        Number  0080
$$PUFL . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$WRFL . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$ERC_BFM . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_IFN . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FBLOC . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$LPTFDB. . . . . . . . . . . . .	V BYTE 	0000	CONST	External
$PR0A. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$PR0C. . . . . . . . . . . . . .	L NEAR 	0018	CODE	Global
$PR0E. . . . . . . . . . . . . .	L NEAR 	001E	CODE	Global
$PTRFIL. . . . . . . . . . . . .	V WORD 	0000	DATA	External
$WRD . . . . . . . . . . . . . .	L NEAR 	002B	CODE	Global
$WRI . . . . . . . . . . . . . .	L NEAR 	0011	CODE	Global
_CPM_. . . . . . . . . . . . . .        Number  0000
_IBM_. . . . . . . . . . . . . .        Number  0000
_MSDOS_. . . . . . . . . . . . .        Number  0001
___DEV . . . . . . . . . . . . .        Number  FFFC
___ZZZ . . . . . . . . . . . . .        Number  0018


PR0A - Prepare for printing                              Macro-86 %1(12)   1:6:45  13-Nov-81    Symbols-3




Warning Severe
Errors	Errors 
0	0




















































