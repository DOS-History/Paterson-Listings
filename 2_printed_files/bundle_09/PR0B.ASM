PR0B - Prepare for printing with PRINT USING             Macro-86 %1(12)   1:6:56  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   PR0B - Prepare for printing with PRINT USING
    2	 	 	 	 	
    3	 	 	 	 	;        PR0A - PRINT, no USING, no #
    4	 	 	 	 	;       *PR0B - PRINT USING
    5	 	 	 	 	;        PR0C - PRINT #
    6	 	 	 	 	;       *PR0D - PRINT USING #
    7	 	 	 	 	;        PR0E - LPRINT
    8	 	 	 	 	;       *PR0F - LPRINT USING
    9	 	 	 	 	;        WRI - WRITE
   10	 	 	 	 	;        WRD - WRITE #
   11	 	 	 	 	; * Only these included in this module
   12	 	 	 	 	












































PR0B - Prepare for printing with PRINT USING             Macro-86 %1(12)   1:6:56  13-Nov-81    Page 1-2



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
   31	 	 	 	 	        PUBLIC  $PR0B,$PR0D,$PR0F
   32	 	 	 	 	
   33	 	 	 	 	        EXTRN   $FBLOC:NEAR, $PRU:NEAR
   34	 	 	 	 	        EXTRN   $ERC_IFN:NEAR,$ERC_BFM:NEAR
   35	 	 	 	 	
   36	 	 	 	 	        ASSUME  CS:CODE,DS:DC,ES:DC
   37	 	 	 	 	
   38	 	 	 	 	
   39	 0000	 	 	 	$PR0B:
   40	 0000  C7 06 0000 E 0000	        MOV     [$PTRFIL],0
   41	 0006	 	 	 	PR1:
   42	 0006  C6 06 0000 E 00	 	        MOV     [$$WRFL],0
   43	 000B  E9 0000 E	 	        JMP     $PRU
   44	 	 	 	 	
   45	 000E	 	 	 	$PR0D:
   46	 000E  89 26 0000 E	 	        MOV     [$$SPSV],SP
   47	 0012  56	 	 	        PUSH    SI
   48	 0013  87 DA	 	 	        XCHG    BX,DX                  ;Swap file # into (BX)
   49	 0015  E8 0000 E	 	        CALL    $FBLOC                 ;See if file exists
   50	 0018  74 16	 	 	        JZ      ercifn
   51	 001A  80 3C 01	 	 	        CMP     [SI].FD_MODE,MD_SQI
   52	 001D  74 14	 	 	        JE      ercbfm
   53	 001F  89 36 0000 E	 	        MOV     [$PTRFIL],SI
   54	 0023  87 DA	 	 	        XCHG    BX,DX                  ;Swap string desc back into (BX)
   55	 0025  5E	 	 	        POP     SI
   56	 0026  EB DE	 	 	        JMP     PR1
   57	 	 	 	 	
   58	 0028  C7 06 0000 E 0000 E	$PR0F:  MOV     [$PTRFIL],OFFSET DC:$LPTFDB
   59	 002E  EB D6	 	 	        JMP     PR1
   60	 	 	 	 	
   61	 0030  E9 0000 E	 	ercifn: JMP     $ERC_IFN
   62	 	 	 	 	
   63	 0033  E9 0000 E	 	ercbfm: JMP     $ERC_BFM
   64	 	 	 	 	
   65	 0036	 	 	 	CODE    ENDS
   66	 	 	 	 	        END


PR0B - Prepare for printing with PRINT USING             Macro-86 %1(12)   1:6:56  13-Nov-81    Symbols-1



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

CODE . . . . . . . . . . . . . .	0036	BYTE  	PUBLIC	'CODE'
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


PR0B - Prepare for printing with PRINT USING             Macro-86 %1(12)   1:6:56  13-Nov-81    Symbols-2



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
EOFCHR . . . . . . . . . . . . .        Number  001A
ERCBFM . . . . . . . . . . . . .	L NEAR 	0033	CODE
ERCIFN . . . . . . . . . . . . .	L NEAR 	0030	CODE
FB_NUM . . . . . . . . . . . . .        Number  FFFB
FCB_LENGTH . . . . . . . . . . .        Number  0026
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
PR1. . . . . . . . . . . . . . .	L NEAR 	0006	CODE
REC_LENGTH . . . . . . . . . . .        Number  0080
$$PUFL . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$WRFL . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$ERC_BFM . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_IFN . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FBLOC . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$LPTFDB. . . . . . . . . . . . .	V BYTE 	0000	CONST	External
$PR0B. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$PR0D. . . . . . . . . . . . . .	L NEAR 	000E	CODE	Global
$PR0F. . . . . . . . . . . . . .	L NEAR 	0028	CODE	Global
$PRU . . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$PTRFIL. . . . . . . . . . . . .	V WORD 	0000	DATA	External
_CPM_. . . . . . . . . . . . . .        Number  0000
_IBM_. . . . . . . . . . . . . .        Number  0000
_MSDOS_. . . . . . . . . . . . .        Number  0001
___DEV . . . . . . . . . . . . .        Number  FFFC
___ZZZ . . . . . . . . . . . . .        Number  0018

Warning Severe
Errors	Errors 
0	0




