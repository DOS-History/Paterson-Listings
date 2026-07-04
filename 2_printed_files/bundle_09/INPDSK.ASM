INPDSK - Handle input from disk                          Macro-86 %1(12)   1:3:9  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   INPDSK - Handle input from disk
    2	 	 	 	 	
    3	 = 000D	 	 	 	CR=     13
    4	 = 000A	 	 	 	LF=     10
    5	 	 	 	 	



















































INPDSK - Handle input from disk                          Macro-86 %1(12)   1:3:9  13-Nov-81    Page 1-2



    6	 	 	 	 	        .LIST
    7	 	 	 	 	
    8	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    9	 	 	 	 	
   10	 	 	 	 	        EXTRN   $FILBUF:WORD,$PTRFIL:WORD,$$SPSV:WORD,$INBUF:BYTE
   11	 	 	 	 	
   12	 0000	 	 	 	DATA    ENDS
   13	 	 	 	 	
   14	 	 	 	 	
   15	 	 	 	 	DC      GROUP   DATA
   16	 	 	 	 	
   17	 	 	 	 	
   18	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   19	 	 	 	 	
   20	 	 	 	 	        PUBLIC  $IN0B
   21	 	 	 	 	
   22	 	 	 	 	        EXTRN   $FBLOC:NEAR,$GETCHR:NEAR,$BAKCHR:NEAR
   23	 	 	 	 	        EXTRN   $ERC_BFM:NEAR,$ERC_IFN:NEAR,$ERC_RPE:NEAR
   24	 	 	 	 	
   25	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   26	 	 	 	 	
   27	 	 	 	 	
   28	 	 	 	 	;***  $IN0B - Prepare for disk input
   29	 	 	 	 	;
   30	 	 	 	 	; Inputs:
   31	 	 	 	 	;       BX = File number
   32	 	 	 	 	; Function:
   33	 	 	 	 	;       Set up parameters so input will come from disk
   34	 	 	 	 	; Outputs:
   35	 	 	 	 	;       None.
   36	 	 	 	 	; Registers:
   37	 	 	 	 	;       All but BP destroyed.
   38	 	 	 	 	
   39	 0000	 	 	 	$IN0B   PROC    FAR
   40	 0000  89 26 0000 E	 	        MOV     [$$SPSV],SP
   41	 0004  E8 0000 E	 	        CALL    $FBLOC
   42	 0007  74 10	 	 	        JZ      ARGERR
   43	 0009  80 3C 02	 	 	        CMP     [SI].FD_MODE,MD_SQO
   44	 000C  74 0E	 	 	        JE      BADMODE
   45	 000E  89 36 0000 E	 	        MOV     [$PTRFIL],SI
   46	 0012  C7 06 0000 E 0022 R	        MOV     [$FILBUF],OFFSET FILBUF
   47	 0018  CB	 	 	        RET
   48	 0019	 	 	 	$IN0B   ENDP
   49	 	 	 	 	
   50	 0019  E9 0000 E	 	ARGERR: JMP     $ERC_IFN        ;Illegal file number
   51	 001C  E9 0000 E	 	BADMODE:JMP     $ERC_BFM        ;Bad file mode
   52	 001F  E9 0000 E	 	EOFERR: JMP     $ERC_RPE
   53	 	 	 	 	
   54	 0022	 	 	 	FILBUF:
   55	 0022  E8 0000 E	 	        CALL    $GETCHR
   56	 0025  72 F8	 	 	        JC      EOFERR
   57	 0027  0A D2	 	 	        OR      DL,DL           ;Line input?
   58	 0029  74 04	 	 	        JZ      NOSPC
   59	 002B  3C 20	 	 	        CMP     AL," "


INPDSK - Handle input from disk                          Macro-86 %1(12)   1:3:9  13-Nov-81    Page 1-3



   60	 002D  74 F3	 	 	        JZ      FILBUF
   61	 002F	 	 	 	NOSPC:
   62	 002F  BF 0000 E	 	        MOV     DI,OFFSET DC:$INBUF
   63	 0032  3C 22	 	 	        CMP     AL,'"'          ;Quoted string?
   64	 0034  75 0D	 	 	        JNZ     NOTQUOTE
   65	 0036  80 FA 2C	 	 	        CMP     DL,","          ;Looking for a string?
   66	 0039  75 08	 	 	        JNZ     NOTQUOTE
   67	 003B  BA 2222	 	 	        MOV     DX,'""'         ;Set delimiters to '"'
   68	 003E  E8 0000 E	 	        CALL    $GETCHR
   69	 0041  72 3A	 	 	        JC      QUIT            ;Null string?
   70	 0043	 	 	 	NOTQUOTE:
   71	 0043  B1 FF	 	 	        MOV     CL,255          ;Allow 255 characters
   72	 0045	 	 	 	LOPCRS:
   73	 0045  80 FE 22	 	 	        CMP     DH,'"'          ;Getting a quoted string?
   74	 0048  74 1F	 	 	        JZ      SKPCHK
   75	 004A  3C 0D	 	 	        CMP     AL,CR           ;End of line?
   76	 004C  74 48	 	 	        JZ      ENDCR
   77	 004E  3C 0A	 	 	        CMP     AL,LF
   78	 0050  75 17	 	 	        JNZ     SKPCHK
   79	 	 	 	 	;Have a linefeed and this is not a quoted string
   80	 0052  80 FA 2C	 	 	        CMP     DL,","          ;Getting an unquoted string?
   81	 0055  74 03	 	 	        JZ      NOSTO           ;Don't store linefeeds in unquoted strings
   82	 0057  E8 00A9 R	 	        CALL    STRCHR
   83	 005A	 	 	 	NOSTO:
   84	 005A  E8 0000 E	 	        CALL    $GETCHR
   85	 005D  3C 0D	 	 	        CMP     AL,CR           ;Ignore CR after LF
   86	 005F  75 08	 	 	        JNZ     SKPCHK
   87	 0061  80 FA 20	 	 	        CMP     DL," "          ;Looking for number?
   88	 0064  74 12	 	 	        JZ      NEXCHR
   89	 0066  80 FA 2C	 	 	        CMP     DL,","          ;Looking for unquoted string?
   90	 0069	 	 	 	SKPCHK:
   91	 0069  0A C0	 	 	        OR      AL,AL
   92	 006B  74 0B	 	 	        JZ      NEXCHR          ;Ignore nulls
   93	 006D  3A C6	 	 	        CMP     AL,DH           ;Check for first terminator
   94	 006F  74 0C	 	 	        JZ      QUIT
   95	 0071  3A C2	 	 	        CMP     AL,DL           ;Check for second terminator
   96	 0073  74 08	 	 	        JZ      QUIT
   97	 0075  E8 00A9 R	 	        CALL    STRCHR          ;Store the character
   98	 0078	 	 	 	NEXCHR:
   99	 0078  E8 0000 E	 	        CALL    $GETCHR
  100	 007B  73 C8	 	 	        JNC     LOPCRS
  101	 007D	 	 	 	QUIT:
  102	 007D  3C 22	 	 	        CMP     AL,'"'          ;Finishing a quoted string?
  103	 007F  74 04	 	 	        JZ      MORSPC
  104	 0081  3C 20	 	 	        CMP     AL," "
  105	 0083  75 1D	 	 	        JNZ     PUTZER
  106	 0085	 	 	 	MORSPC:
  107	 0085  E8 0000 E	 	        CALL    $GETCHR
  108	 0088  72 18	 	 	        JC      PUTZER
  109	 008A  3C 20	 	 	        CMP     AL," "
  110	 008C  74 F7	 	 	        JZ      MORSPC
  111	 008E  3C 2C	 	 	        CMP     AL,","          ;Eat comma separator
  112	 0090  74 10	 	 	        JZ      PUTZER
  113	 0092  3C 0D	 	 	        CMP     AL,CR


INPDSK - Handle input from disk                          Macro-86 %1(12)   1:3:9  13-Nov-81    Page 1-4



  114	 0094  75 09	 	 	        JNZ     BACKUP
  115	 0096	 	 	 	ENDCR:
  116	 0096  E8 0000 E	 	        CALL    $GETCHR
  117	 0099  72 07	 	 	        JC      PUTZER
  118	 009B  3C 0A	 	 	        CMP     AL,LF
  119	 009D  74 03	 	 	        JZ      PUTZER
  120	 009F	 	 	 	BACKUP:
  121	 009F  E8 0000 E	 	        CALL    $BAKCHR
  122	 00A2	 	 	 	PUTZER:
  123	 00A2  32 C0	 	 	        XOR     AL,AL
  124	 00A4  AA	 	 	        STOSB
  125	 00A5  BE 0000 E	 	        MOV     SI,OFFSET DC:$INBUF
  126	 00A8  C3	 	 	RET:    RET
  127	 	 	 	 	
  128	 00A9	 	 	 	STRCHR:
  129	 00A9  0A C0	 	 	        OR      AL,AL
  130	 00AB  74 FB	 	 	        JZ      RET
  131	 00AD  AA	 	 	        STOSB
  132	 00AE  FE C9	 	 	        DEC     CL              ;Buffer full?
  133	 00B0  75 F6	 	 	        JNZ     RET
  134	 00B2  59	 	 	        POP     CX              ;Dump a return address
  135	 00B3  EB ED	 	 	        JMP     PUTZER          ;Quit if buffer full
  136	 	 	 	 	
  137	 00B5	 	 	 	CODE    ENDS
  138	 	 	 	 	        END































INPDSK - Handle input from disk                          Macro-86 %1(12)   1:3:9  13-Nov-81    Symbols-1



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

CODE . . . . . . . . . . . . . .	00B5	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ARGERR . . . . . . . . . . . . .	L NEAR 	0019	CODE
BACKUP . . . . . . . . . . . . .	L NEAR 	009F	CODE
BADMODE. . . . . . . . . . . . .	L NEAR 	001C	CODE
BL_LEN . . . . . . . . . . . . .        Number  FFFC
BL_LNK . . . . . . . . . . . . .        Number  FFFE
BL_SIZE. . . . . . . . . . . . .        Number  FFFA
CR . . . . . . . . . . . . . . .	Number	000D	
DN_KYBD. . . . . . . . . . . . .        Number  FFFF


INPDSK - Handle input from disk                          Macro-86 %1(12)   1:3:9  13-Nov-81    Symbols-2



DN_LPT1. . . . . . . . . . . . .        Number  FFFD
DN_SCRN. . . . . . . . . . . . .        Number  FFFE
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
ENDCR. . . . . . . . . . . . . .	L NEAR 	0096	CODE
EOFCHR . . . . . . . . . . . . .        Number  001A
EOFERR . . . . . . . . . . . . .	L NEAR 	001F	CODE
FB_NUM . . . . . . . . . . . . .        Number  FFFB
FCB_LENGTH . . . . . . . . . . .        Number  0026
FILBUF . . . . . . . . . . . . .	L NEAR 	0022	CODE
FILNAML. . . . . . . . . . . . .        Number  0026
FILNAM_LENGTH. . . . . . . . . .        Number  000B
LAST_DEVICE_OFFSET . . . . . . .        Number  0008
LF . . . . . . . . . . . . . . .	Number	000A	
LOPCRS . . . . . . . . . . . . .	L NEAR 	0045	CODE
MD_APP . . . . . . . . . . . . .        Number  0008
MD_BIN . . . . . . . . . . . . .        Number  0080
MD_FIL . . . . . . . . . . . . .        Number  0004
MD_IBM . . . . . . . . . . . . .        Number  0020
MD_KIL . . . . . . . . . . . . .        Number  0010
MD_RND . . . . . . . . . . . . .        Number  0004
MD_SQI . . . . . . . . . . . . .        Number  0001
MD_SQO . . . . . . . . . . . . .        Number  0002
MD_USR . . . . . . . . . . . . .        Number  0040
MORSPC . . . . . . . . . . . . .	L NEAR 	0085	CODE
NEXCHR . . . . . . . . . . . . .	L NEAR 	0078	CODE
NOSPC. . . . . . . . . . . . . .	L NEAR 	002F	CODE
NOSTO. . . . . . . . . . . . . .	L NEAR 	005A	CODE
NOTQUOTE . . . . . . . . . . . .	L NEAR 	0043	CODE
PUTZER . . . . . . . . . . . . .	L NEAR 	00A2	CODE
QUIT . . . . . . . . . . . . . .	L NEAR 	007D	CODE
REC_LENGTH . . . . . . . . . . .        Number  0080
RET. . . . . . . . . . . . . . .	L NEAR 	00A8	CODE
SKPCHK . . . . . . . . . . . . .	L NEAR 	0069	CODE
STRCHR . . . . . . . . . . . . .	L NEAR 	00A9	CODE
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$BAKCHR. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_BFM . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_IFN . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_RPE . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FBLOC . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FILBUF. . . . . . . . . . . . .	V WORD 	0000	DATA	External
$GETCHR. . . . . . . . . . . . .	L NEAR 	0000	CODE	External


INPDSK - Handle input from disk                          Macro-86 %1(12)   1:3:9  13-Nov-81    Symbols-3



$IN0B. . . . . . . . . . . . . .	F PROC	0000	CODE	Global	Length =0019
$INBUF . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$PTRFIL. . . . . . . . . . . . .	V WORD 	0000	DATA	External
_CPM_. . . . . . . . . . . . . .        Number  0000
_IBM_. . . . . . . . . . . . . .        Number  0000
_MSDOS_. . . . . . . . . . . . .        Number  0001
___DEV . . . . . . . . . . . . .        Number  FFFC
___ZZZ . . . . . . . . . . . . .        Number  0018

Warning Severe
Errors	Errors 
0	0












































