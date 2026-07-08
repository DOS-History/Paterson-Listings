INPUTF - INPUT$ function                                Macro-86 %1(12)   1:3:34  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   INPUTF - INPUT$ function
    2	 	 	 	 	






















































INPUTF - INPUT$ function                                Macro-86 %1(12)   1:3:34  13-Nov-81    Page 1-2



    3	 	 	 	 	        .list
    4	 	 	 	 	
    5	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    6	 	 	 	 	
    7	 	 	 	 	        EXTRN   $$SPSV:WORD,$PTRFIL:WORD
    8	 	 	 	 	
    9	 0000	 	 	 	DATA    ENDS
   10	 	 	 	 	
   11	 	 	 	 	
   12	 	 	 	 	DC      GROUP   DATA
   13	 	 	 	 	
   14	 	 	 	 	
   15	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   16	 	 	 	 	
   17	 	 	 	 	        PUBLIC  $IN$
   18	 	 	 	 	
   19	 	 	 	 	        EXTRN   $GETCHR:NEAR,$FBLOC:NEAR,$$ATS:NEAR
   20	 	 	 	 	        EXTRN   $ERC_BFM:NEAR,$ERC_IFN:NEAR
   21	 	 	 	 	
   22	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   23	 	 	 	 	
   24	 	 	 	 	
   25	 0000	 	 	 	$IN$    PROC    FAR
   26	 	 	 	 	
   27	 	 	 	 	;***  $IN$ - INPUT$ function for TTY or disk
   28	 	 	 	 	;
   29	 	 	 	 	; Inputs:
   30	 	 	 	 	;       BX = Number of characters wanted
   31	 	 	 	 	;       DX = File number (32767 for TTY)
   32	 	 	 	 	; Function:
   33	 	 	 	 	;       Create a temp string of length BX, fill with characters from file or
   34	 	 	 	 	;       from TTY without echo.
   35	 	 	 	 	; Outputs:
   36	 	 	 	 	;       BX = Address of string descriptor
   37	 	 	 	 	; Registers:
   38	 	 	 	 	;       Only BX and F affected.
   39	 	 	 	 	
   40	 0000  89 26 0000 E	 	        MOV     [$$SPSV],SP
   41	 0004  51	 	 	        PUSH    CX
   42	 0005  52	 	 	        PUSH    DX
   43	 0006  56	 	 	        PUSH    SI
   44	 0007  33 F6	 	 	        XOR     SI,SI           ;In case TTY input
   45	 0009  8B CB	 	 	        MOV     CX,BX           ;Put count in CX
   46	 000B  8B DA	 	 	        MOV     BX,DX           ;File number in BX
   47	 000D  80 FB FF	 	 	        CMP     BL,255
   48	 0010  74 0A	 	 	        JZ      STOPNT
   49	 0012  E8 0000 E	 	        CALL    $FBLOC
   50	 0015  74 20	 	 	        JZ      BADNUM          ;Illegal file number
   51	 0017  80 3C 02	 	 	        CMP     [SI].FD_MODE,MD_SQO
   52	 001A  74 1E	 	 	        JE      BADMODE
   53	 001C	 	 	 	STOPNT:
   54	 001C  89 36 0000 E	 	        MOV     [$PTRFIL],SI
   55	 0020  5E	 	 	        POP     SI
   56	 0021  8B D9	 	 	        MOV     BX,CX


INPUTF - INPUT$ function                                Macro-86 %1(12)   1:3:34  13-Nov-81    Page 1-3



   57	 0023  E8 0000 E	 	        CALL    $$ATS           ;Allocate temp string
   58	 0026  E3 0C	 	 	        JCXZ    INPOP
   59	 0028  87 FA	 	 	        XCHG    DI,DX           ;Put data pointer in DI
   60	 002A  50	 	 	        PUSH    AX
   61	 002B	 	 	 	RDSTR:
   62	 002B  E8 0000 E	 	        CALL    $GETCHR         ;Read character
   63	 002E  AA	 	 	        STOSB                   ;Put in string
   64	 002F  E2 FA	 	 	        LOOP    RDSTR           ;Repeat
   65	 0031  58	 	 	        POP     AX
   66	 0032  8B FA	 	 	        MOV     DI,DX           ;Restore DI
   67	 0034	 	 	 	INPOP:
   68	 0034  5A	 	 	        POP     DX
   69	 0035  59	 	 	        POP     CX
   70	 0036  CB	 	 	        RET
   71	 	 	 	 	
   72	 0037  E9 0000 E	 	BADNUM: JMP     $ERC_IFN
   73	 003A  E9 0000 E	 	BADMODE:JMP     $ERC_BFM
   74	 	 	 	 	
   75	 003D	 	 	 	$IN$    ENDP
   76	 003D	 	 	 	CODE    ENDS
   77	 	 	 	 	        END



































INPUTF - INPUT$ function                                Macro-86 %1(12)   1:3:34  13-Nov-81    Symbols-1



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

CODE . . . . . . . . . . . . . .	003D	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

BADMODE. . . . . . . . . . . . .	L NEAR 	003A	CODE
BADNUM . . . . . . . . . . . . .	L NEAR 	0037	CODE
BL_LEN . . . . . . . . . . . . .        Number  FFFC
BL_LNK . . . . . . . . . . . . .        Number  FFFE
BL_SIZE. . . . . . . . . . . . .        Number  FFFA
DN_KYBD. . . . . . . . . . . . .        Number  FFFF
DN_LPT1. . . . . . . . . . . . .        Number  FFFD
DN_SCRN. . . . . . . . . . . . .        Number  FFFE


INPUTF - INPUT$ function                                Macro-86 %1(12)   1:3:34  13-Nov-81    Symbols-2



DV_BAKC. . . . . . . . . . . . .        Number  000E
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
DV_Width . . . . . . . . . . . .        Number  0008
EOFCHR . . . . . . . . . . . . .        Number  001A
FB_NUM . . . . . . . . . . . . .        Number  FFFB
FCB_LENGTH . . . . . . . . . . .        Number  0026
FILNAML. . . . . . . . . . . . .        Number  0026
FILNAM_LENGTH. . . . . . . . . .        Number  000B
INPOP. . . . . . . . . . . . . .	L NEAR 	0034	CODE
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
RDSTR. . . . . . . . . . . . . .	L NEAR 	002B	CODE
REC_LENGTH . . . . . . . . . . .        Number  0080
STOPNT . . . . . . . . . . . . .	L NEAR 	001C	CODE
$$ATS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ERC_BFM . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_IFN . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FBLOC . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$GETCHR. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$IN$ . . . . . . . . . . . . . .	F PROC	0000	CODE	Global	Length =003D
$PTRFIL. . . . . . . . . . . . .	V WORD 	0000	DATA	External
_CPM_. . . . . . . . . . . . . .        Number  0000
_IBM_. . . . . . . . . . . . . .        Number  0000
_MSDOS_. . . . . . . . . . . . .        Number  0001
___DEV . . . . . . . . . . . . .        Number  FFFC
___ZZZ . . . . . . . . . . . . .        Number  0018

Warning Severe
Errors	Errors 
0	0







