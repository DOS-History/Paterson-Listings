OUT - Output utilities                                   Macro-86 %1(12)   1:6:27  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   OUT - Output utilities
    2	 	 	 	 	






















































OUT - Output utilities                                   Macro-86 %1(12)   1:6:27  13-Nov-81    Page 1-2



    3	 	 	 	 	.list
    4	 	 	 	 	
    5	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    6	 	 	 	 	
    7	 	 	 	 	        EXTRN   $PTRFIL:WORD,$$WRFL:BYTE
    8	 	 	 	 	
    9	 0000	 	 	 	DATA    ENDS
   10	 	 	 	 	
   11	 	 	 	 	DC      GROUP   DATA
   12	 	 	 	 	
   13	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   14	 	 	 	 	
   15	 	 	 	 	        PUBLIC  $$WCLF,$$THB,$TYTX,$TYPTX,$$TCR,$$WCHT
   16	 	 	 	 	        PUBLIC  $TYPSTR,$TYPCNT,$OUTCNT
   17	 	 	 	 	
   18	 	 	 	 	        EXTRN   $$WCH:NEAR
   19	 	 	 	 	        EXTRN   $TTYOT:NEAR
   20	 	 	 	 	
   21	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   22	 	 	 	 	
   23	 = 000D	 	 	 	CR      EQU     13
   24	 = 000A	 	 	 	LF      EQU     10
   25	 	 	 	 	
   26	 = 0002	 	 	 	CRLF_LEN=       2                       ;Length of CR/LF sequence on disk
   27	 	 	 	 	
   28	 	 	 	 	
   29	 	 	 	 	;**     $$WCLF - Write new line
   30	 	 	 	 	;
   31	 	 	 	 	;       USES    F
   32	 	 	 	 	
   33	 0000  50	 	 	$$WCLF: PUSH    AX                      ;Save (AX)
   34	 0001  53	 	 	        PUSH    BX
   35	 0002  56	 	 	        PUSH    SI
   36	 	 	 	 	
   37	 0003  8B 36 0000 E	 	        MOV     SI,[$PTRFIL]
   38	 0007  0B F6	 	 	        OR      SI,SI                   ;Check for standard output
   39	 0009  74 27	 	 	        JE      wcspec                  ;  Yes - do special CR/LF
   40	 000B  F6 44 2E 80	 	        TEST    [SI].FD_DEVICE,80h      ;Test for special device
   41	 000F  75 21	 	 	        JNZ     wcspec                  ;  Yes - do special CR/LF
   42	 0011  80 3C 04	 	 	        CMP     [SI].FD_MODE,MD_RND     ;Check for random
   43	 0014  75 1C	 	 	        JNE     wcdisk                  ;  No - do disk CR/LF
   44	 0016  80 3E 0000 E 00	 	        CMP     [$$WRFL],0              ;Test for WRITE statement
   45	 001B  74 15	 	 	        JE      wcdisk                  ;  No - just do disk CR/LF
   46	 	 	 	 	
   47	 001D  8B 9C 00B3	 	        MOV     BX,[SI].FR_VRECL        ;Get field length
   48	 0021  2B 9C 00BA	 	        SUB     BX,[SI].FR_OUTPOS       ;  Subtract off bytes already written
   49	 0025  83 EB 02	 	 	        SUB     BX,CRLF_LEN             ;    and two more for CR/LF
   50	 0028  B0 20	 	 	        MOV     AL,' '                  ;Write (BX) spaces
   51	 	 	 	 	
   52	 	 	 	 	;       This is tricky because DISK_SOUT will give FOV error if
   53	 	 	 	 	;       (BX) is negative.
   54	 	 	 	 	
   55	 002A  74 06	 	 	wspc:   JZ      wcdisk                  ;(BX) = 0 - done
   56	 002C  E8 0000 E	 	        CALL    $$WCH                   ;Write space


OUT - Output utilities                                   Macro-86 %1(12)   1:6:27  13-Nov-81    Page 1-3



   57	 002F  4B	 	 	        DEC     BX                      ;Decrement (BX)
   58	 0030  EB F8	 	 	        JMP     wspc                    ;Keep on looping until (BX) = 0
   59	 	 	 	 	
   60	 	 	 	 	if      _IBM_
   61	 	 	 	 	wcdisk: MOV     AL,CR
   62	 	 	 	 	        CALL    $$WCH                   ;Output CR
   63	 	 	 	 	        MOV     AL,LF
   64	 	 	 	 	        CALL    $$WCH                   ;Output LF
   65	 	 	 	 	        JMP     SHORT wclxt
   66	 	 	 	 	
   67	 	 	 	 	wcspec: MOV     AL,CR                   ;Output CR only
   68	 	 	 	 	        CALL    $$WCH
   69	 	 	 	 	else
   70	 0032	 	 	 	wcdisk:
   71	 0032  B0 0D	 	 	wcspec: MOV     AL,CR                   ;Output CR/LF
   72	 0034  E8 0000 E	 	        CALL    $$WCH
   73	 0037  B0 0A	 	 	        MOV     AL,LF
   74	 0039  E8 0000 E	 	        CALL    $$WCH
   75	 	 	 	 	endif
   76	 	 	 	 	
   77	 003C  5E	 	 	wclxt:  POP     SI
   78	 003D  5B	 	 	        POP     BX
   79	 003E  58	 	 	        POP     AX
   80	 003F  C3	 	 	        RET
   81	 	 	 	 	
   82	 	 	 	 	
   83	 	 	 	 	;***  $$TCR - Type CR/LF on console
   84	 	 	 	 	;
   85	 	 	 	 	; Uses F
   86	 	 	 	 	
   87	 0040	 	 	 	$$TCR:
   88	 0040  50	 	 	        PUSH    AX
   89	 0041  FF 36 0000 E	 	        PUSH    [$PTRFIL]
   90	 0045  C7 06 0000 E 0000	        MOV     [$PTRFIL],0
   91	 004B  E8 0000 R	 	        CALL    $$WCLF
   92	 004E  8F 06 0000 E	 	        POP     [$PTRFIL]
   93	 0052  58	 	 	        POP     AX
   94	 0053  C3	 	 	        RET
   95	 	 	 	 	
   96	 	 	 	 	
   97	 0054	 	 	 	$$WCHT:
   98	 0054  FF 36 0000 E	 	        PUSH    [$PTRFIL]       ;Save current output pointer
   99	 0058  C7 06 0000 E 0000	        MOV     [$PTRFIL],0     ;Set pointer to console output
  100	 005E  E8 0000 E	 	        CALL    $$WCH
  101	 0061  8F 06 0000 E	 	        POP     [$PTRFIL]       ;Restore pointer
  102	 0065  C3	 	 	RET:    RET
  103	 	 	 	 	
  104	 	 	 	 	
  105	 	 	 	 	
  106	 	 	 	 	;***  $$THB - Type hex byte
  107	 	 	 	 	;
  108	 	 	 	 	; Inputs:
  109	 	 	 	 	;       AL = Byte to output in hex
  110	 	 	 	 	; Outputs:


OUT - Output utilities                                   Macro-86 %1(12)   1:6:27  13-Nov-81    Page 1-4



  111	 	 	 	 	;       None.
  112	 	 	 	 	; Registers:
  113	 	 	 	 	;       Only AL and F affected.
  114	 	 	 	 	
  115	 0066	 	 	 	$$THB:
  116	 0066  50	 	 	        PUSH    AX
  117	 0067  D0 E8	 	 	        SHR     AL,1
  118	 0069  D0 E8	 	 	        SHR     AL,1
  119	 006B  D0 E8	 	 	        SHR     AL,1
  120	 006D  D0 E8	 	 	        SHR     AL,1
  121	 006F  E8 0073 R	 	        CALL    DIGIT
  122	 0072  58	 	 	        POP     AX
  123	 0073	 	 	 	DIGIT:
  124	 0073  24 0F	 	 	        AND     AL,0FH
  125	 0075  24 90	 	 	        AND     AL,90H
  126	 0077  27	 	 	        DAA
  127	 0078  14 40	 	 	        ADC     AL,40H
  128	 007A  27	 	 	        DAA
  129	 007B  EB D7	 	 	        JMP     $$WCHT
  130	 	 	 	 	
  131	 	 	 	 	
  132	 	 	 	 	;***  $TYTX - Type text
  133	 	 	 	 	;
  134	 	 	 	 	; Inputs:
  135	 	 	 	 	;       SI has pointer to text string in code segment
  136	 	 	 	 	; Function:
  137	 	 	 	 	;       Print string with bit 7 set in last character
  138	 	 	 	 	; Outputs:
  139	 	 	 	 	;       SI points past end of text.
  140	 	 	 	 	; Registers:
  141	 	 	 	 	;       SI, AX and F affected.
  142	 	 	 	 	
  143	 007D	 	 	 	$TYTX:
  144	 007D  2E: AC	 	 	        LODS    BYTE PTR CS:[SI]
  145	 007F  50	 	 	        PUSH    AX
  146	 0080  24 7F	 	 	        AND     AL,7FH
  147	 0082  E8 0054 R	 	        CALL    $$WCHT
  148	 0085  58	 	 	        POP     AX
  149	 0086  A8 80	 	 	        TEST    AL,80H
  150	 0088  74 F3	 	 	        JZ      $TYTX
  151	 008A  C3	 	 	        RET
  152	 	 	 	 	
  153	 	 	 	 	
  154	 	 	 	 	
  155	 	 	 	 	;***  $TYPTX - Print string pointed to by top of stack
  156	 	 	 	 	;
  157	 	 	 	 	; Inputs:
  158	 	 	 	 	;       Top of stack has address in code segment of text string terminated
  159	 	 	 	 	;       with bit 7 set.
  160	 	 	 	 	; Function:
  161	 	 	 	 	;       Print the string.
  162	 	 	 	 	; Outputs:
  163	 	 	 	 	;       None. Returns to first location after the string.
  164	 	 	 	 	; Registers:


OUT - Output utilities                                   Macro-86 %1(12)   1:6:27  13-Nov-81    Page 1-5



  165	 	 	 	 	;       Only AX and F affected.
  166	 	 	 	 	
  167	 008B	 	 	 	$TYPTX:
  168	 008B  58	 	 	        POP     AX
  169	 008C  56	 	 	        PUSH    SI
  170	 008D  8B F0	 	 	        MOV     SI,AX
  171	 008F  E8 007D R	 	        CALL    $TYTX
  172	 0092  8B C6	 	 	        MOV     AX,SI
  173	 0094  5E	 	 	        POP     SI
  174	 0095  FF E0	 	 	        JMP     AX
  175	 	 	 	 	
  176	 	 	 	 	
  177	 	 	 	 	
  178	 	 	 	 	;***  $TYPSTR - Type string given descriptor
  179	 	 	 	 	;
  180	 	 	 	 	; Inputs:
  181	 	 	 	 	;       BX = Address of string descriptor
  182	 	 	 	 	; Outputs:
  183	 	 	 	 	;       None.
  184	 	 	 	 	; Registers:
  185	 	 	 	 	;       CX,SI,AX,F destroyed.
  186	 	 	 	 	
  187	 0097	 	 	 	$TYPSTR:
  188	 0097  8B 0F	 	 	        MOV     CX,[BX]
  189	 0099	 	 	 	$TYPCNT:
  190	 0099  E3 CA	 	 	        JCXZ    RET
  191	 009B  8B 77 02	 	 	        MOV     SI,[BX+2]
  192	 009E	 	 	 	$OUTCNT:
  193	 009E  AC	 	 	        LODSB
  194	 009F  E8 0000 E	 	        CALL    $$WCH
  195	 00A2  E2 FA	 	 	        LOOP    $OUTCNT
  196	 00A4  C3	 	 	        RET
  197	 	 	 	 	
  198	 00A5	 	 	 	CODE    ENDS
  199	 	 	 	 	        END





















OUT - Output utilities                                   Macro-86 %1(12)   1:6:27  13-Nov-81    Symbols-1



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

CODE . . . . . . . . . . . . . .	00A5	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

BL_LEN . . . . . . . . . . . . .        Number  FFFC
BL_LNK . . . . . . . . . . . . .        Number  FFFE
BL_SIZE. . . . . . . . . . . . .        Number  FFFA
CR . . . . . . . . . . . . . . .	Number	000D	
CRLF_LEN . . . . . . . . . . . .	Number	0002	
DIGIT. . . . . . . . . . . . . .	L NEAR 	0073	CODE
DN_KYBD. . . . . . . . . . . . .        Number  FFFF
DN_LPT1. . . . . . . . . . . . .        Number  FFFD


OUT - Output utilities                                   Macro-86 %1(12)   1:6:27  13-Nov-81    Symbols-2



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
DV_WIDTH . . . . . . . . . . . .        Number  0008
EOFCHR . . . . . . . . . . . . .        Number  001A
FB_NUM . . . . . . . . . . . . .        Number  FFFB
FCB_LENGTH . . . . . . . . . . .        Number  0026
FILNAML. . . . . . . . . . . . .        Number  0026
FILNAM_LENGTH. . . . . . . . . .        Number  000B
LAST_DEVICE_OFFSET . . . . . . .        Number  0008
LF . . . . . . . . . . . . . . .	Number	000A	
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
RET. . . . . . . . . . . . . . .	L NEAR 	0065	CODE
WCDISK . . . . . . . . . . . . .	L NEAR 	0032	CODE
WCLXT. . . . . . . . . . . . . .	L NEAR 	003C	CODE
WCSPEC . . . . . . . . . . . . .	L NEAR 	0032	CODE
WSPC . . . . . . . . . . . . . .	L NEAR 	002A	CODE
$$TCR. . . . . . . . . . . . . .	L NEAR 	0040	CODE	Global
$$THB. . . . . . . . . . . . . .	L NEAR 	0066	CODE	Global
$$WCH. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$WCHT . . . . . . . . . . . . .	L NEAR 	0054	CODE	Global
$$WCLF . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$$WRFL . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$OUTCNT. . . . . . . . . . . . .	L NEAR 	009E	CODE	Global
$PTRFIL. . . . . . . . . . . . .	V WORD 	0000	DATA	External
$TTYOT . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TYPCNT. . . . . . . . . . . . .	L NEAR 	0099	CODE	Global
$TYPSTR. . . . . . . . . . . . .	L NEAR 	0097	CODE	Global
$TYPTX . . . . . . . . . . . . .	L NEAR 	008B	CODE	Global
$TYTX. . . . . . . . . . . . . .	L NEAR 	007D	CODE	Global
_CPM_. . . . . . . . . . . . . .        Number  0000
_IBM_. . . . . . . . . . . . . .        Number  0000
_MSDOS_. . . . . . . . . . . . .        Number  0001
___DEV . . . . . . . . . . . . .        Number  FFFC
___ZZZ . . . . . . . . . . . . .        Number  0018

OUT - Output utilities                                   Macro-86 %1(12)   1:6:27  13-Nov-81    Symbols-3



Warning Severe
Errors	Errors 
0	0




















































