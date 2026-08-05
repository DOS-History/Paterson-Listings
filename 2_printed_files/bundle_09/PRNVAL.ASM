PRNVAL - Print values                                    Macro-86 %1(12)   1:7:5  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   PRNVAL - Print values
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        PUBLIC  $$WRFL,$$PUFL,$$PUEN
    6	 	 	 	 	
    7	 	 	 	 	        EXTRN   $$SPSV:WORD,$FAC:BYTE,$AC:WORD
    8	 	 	 	 	        EXTRN   TYP:WORD,VALTYP:BYTE,CURTYP:BYTE
    9	 	 	 	 	
   10	 0000  ??	 	 	$$WRFL  DB      ?
   11	 0001  ??	 	 	$$PUFL  DB      ?
   12	 0002  ????	 	 	$$PUEN  DW      ?
   13	 	 	 	 	
   14	 0004	 	 	 	DATA    ENDS
   15	 	 	 	 	
   16	 	 	 	 	DC      GROUP   DATA
   17	 	 	 	 	
   18	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   19	 	 	 	 	
   20	 	 	 	 	        PUBLIC  $PV0A,$PV0B,$PV0C,$PV0D
   21	 	 	 	 	        PUBLIC  $PV1A,$PV1B,$PV1C,$PV1D
   22	 	 	 	 	        PUBLIC  $PV2A,$PV2B,$PV2C,$PV2D
   23	 	 	 	 	
   24	 	 	 	 	        EXTRN   $$WCH:NEAR,$$WCLF:NEAR,$$DITS:NEAR,$FOUT:NEAR
   25	 	 	 	 	        EXTRN   $TYPSTR:NEAR,$SAVREG:NEAR
   26	 	 	 	 	        EXTRN   $$POS:NEAR,$$WID:NEAR
   27	 	 	 	 	
   28	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   29	 	 	 	 	
   30	 	 	 	 	
   31	 	 	 	 	;***  PVnx - Print values
   32	 	 	 	 	;
   33	 	 	 	 	;   n = 0 - follow with "," processing
   34	 	 	 	 	;       1 - follow with ";" processing
   35	 	 	 	 	;       2 - follow with CR/LF
   36	 	 	 	 	;
   37	 	 	 	 	;   x = A - Single precision (pointer to value in BX)
   38	 	 	 	 	;       B - Double precision (pointer to value in BX)
   39	 	 	 	 	;       C - Integer (value in BX)
   40	 	 	 	 	;       D - String (Address of descriptor in BX)
   41	 	 	 	 	
   42	 = 000E	 	 	 	CLMWID  EQU     14
   43	 = 0004	 	 	 	SNGL    EQU     4
   44	 = 0008	 	 	 	DBL     EQU     8
   45	 = 0002	 	 	 	INT     EQU     2
   46	 = 0003	 	 	 	STRING  EQU     3
   47	 = 0000	 	 	 	COMMA   EQU     0
   48	 = 0001	 	 	 	SEMI    EQU     1
   49	 = 0002	 	 	 	CRLF    EQU     2
   50	 	 	 	 	
   51	 0000	 	 	 	$PV0A:
   52	 0000  E8 003C R	 	        CALL    PRINT
   53	 0003  04 00	 	 	        DB      SNGL,COMMA
   54	 	 	 	 	


PRNVAL - Print values                                    Macro-86 %1(12)   1:7:5  13-Nov-81    Page 1-2



   55	 0005	 	 	 	$PV0B:
   56	 0005  E8 003C R	 	        CALL    PRINT
   57	 0008  08 00	 	 	        DB      DBL,COMMA
   58	 	 	 	 	
   59	 000A	 	 	 	$PV0C:
   60	 000A  E8 003C R	 	        CALL    PRINT
   61	 000D  02 00	 	 	        DB      INT,COMMA
   62	 	 	 	 	
   63	 000F	 	 	 	$PV0D:
   64	 000F  E8 003C R	 	        CALL    PRINT
   65	 0012  03 00	 	 	        DB      STRING,COMMA
   66	 	 	 	 	
   67	 0014	 	 	 	$PV1A:
   68	 0014  E8 003C R	 	        CALL    PRINT
   69	 0017  04 01	 	 	        DB      SNGL,SEMI
   70	 	 	 	 	
   71	 0019	 	 	 	$PV1B:
   72	 0019  E8 003C R	 	        CALL    PRINT
   73	 001C  08 01	 	 	        DB      DBL,SEMI
   74	 	 	 	 	
   75	 001E	 	 	 	$PV1C:
   76	 001E  E8 003C R	 	        CALL    PRINT
   77	 0021  02 01	 	 	        DB      INT,SEMI
   78	 	 	 	 	
   79	 0023	 	 	 	$PV1D:
   80	 0023  E8 003C R	 	        CALL    PRINT
   81	 0026  03 01	 	 	        DB      STRING,SEMI
   82	 	 	 	 	
   83	 0028	 	 	 	$PV2A:
   84	 0028  E8 003C R	 	        CALL    PRINT
   85	 002B  04 02	 	 	        DB      SNGL,CRLF
   86	 	 	 	 	
   87	 002D	 	 	 	$PV2B:
   88	 002D  E8 003C R	 	        CALL    PRINT
   89	 0030  08 02	 	 	        DB      DBL,CRLF
   90	 	 	 	 	
   91	 0032	 	 	 	$PV2C:  
   92	 0032  E8 003C R	 	        CALL    PRINT
   93	 0035  02 02	 	 	        DB      INT,CRLF
   94	 	 	 	 	
   95	 0037	 	 	 	$PV2D:
   96	 0037  E8 003C R	 	        CALL    PRINT
   97	 003A  03 02	 	 	        DB      STRING,CRLF
   98	 	 	 	 	
   99	 003C	 	 	 	PRINT:
  100	 003C  8F 06 0000 E	 	        POP     [TYP]           ;Get pointer to flags
  101	 0040  E8 0000 E	 	        CALL    $SAVREG
  102	 0043  8B 36 0000 E	 	        MOV     SI,[TYP]
  103	 0047  2E: AD	 	 	        LODS    WORD PTR CS:[SI]
  104	 0049  A3 0000 E	 	        MOV     [TYP],AX        ;Set VALTYP and CURTYP flags
  105	 004C  3C 03	 	 	        CMP     AL,STRING
  106	 004E  74 56	 	 	        JZ      PSTRG           ;Handle strings separately
  107	 0050  3C 02	 	 	        CMP     AL,INT
  108	 0052  74 10	 	 	        JZ      STOINT


PRNVAL - Print values                                    Macro-86 %1(12)   1:7:5  13-Nov-81    Page 1-3



  109	 0054  98	 	 	        CBW
  110	 0055  8B F3	 	 	        MOV     SI,BX
  111	 0057  BF 0001 E	 	        MOV     DI,OFFSET DC:$FAC+1
  112	 005A  2B F8	 	 	        SUB     DI,AX           ;Point to DAC or AC, as appropriate
  113	 005C  8B C8	 	 	        MOV     CX,AX
  114	 005E  D1 E9	 	 	        SHR     CX,1            ;Move by words
  115	 0060  F3/ A5	 	 	        REP     MOVSW           ;Number to print in FAC
  116	 0062  EB 04	 	 	        JMP     SHORT TSTPRUS
  117	 0064	 	 	 	STOINT:
  118	 0064  89 1E 0000 E	 	        MOV     [$AC],BX        ;Number to print in FAC
  119	 0068	 	 	 	TSTPRUS:
  120	 0068  80 3E 0001 R 00	 	        CMP     [$$PUFL],0      ;Print using on?
  121	 006D  75 2B	 	 	        JNZ     PUEN            ;Yes--go do it
  122	 006F  E8 0000 E	 	        CALL    $FOUT           ;Convert it to ASCII
  123	 0072  80 3E 0000 R 00	 	        CMP     [$$WRFL],0      ;WRITE statement?
  124	 0077  75 62	 	 	        JNZ     WRVAL           ;Yes--handle special
  125	 0079  40	 	 	        INC     AX              ;Add 1 for the following space
  126	 007A  B1 00	 	 	        MOV     CL,0            ;Not special comma test
  127	 007C  E8 0113 R	 	        CALL    PRTCHK          ;Make it fit on line (give CR/LF if necessary)
  128	 007F	 	 	 	PRVAL:
  129	 007F  AC	 	 	        LODSB
  130	 0080  0A C0	 	 	        OR      AL,AL           ;End of string?
  131	 0082  74 05	 	 	        JZ      WRTSPC
  132	 0084  E8 0000 E	 	        CALL    $$WCH           ;Write character
  133	 0087  EB F6	 	 	        JMP     PRVAL
  134	 0089	 	 	 	WRTSPC:
  135	 0089  B0 20	 	 	        MOV     AL," "
  136	 008B	 	 	 	CHKEND:
  137	 008B  80 3E 0000 E 01	 	        CMP     [CURTYP],SEMI   ;What do we finish with?
  138	 0090  74 05	 	 	        JZ      WRTJMP
  139	 0092	 	 	 	STREND:
  140	 0092  72 5B	 	 	        JB      CMA             ;Comma processing?
  141	 0094  E9 0000 E	 	ENDLIN: JMP     $$WCLF
  142	 	 	 	 	
  143	 0097  E9 0000 E	 	WRTJMP: JMP     $$WCH
  144	 	 	 	 	
  145	 009A  FF 16 0002 R	 	PUEN:   CALL    [$$PUEN]
  146	 009E  80 3E 0000 E 02	 	        CMP     [CURTYP],CRLF
  147	 00A3  74 EF	 	 	        JZ      ENDLIN
  148	 00A5  C3	 	 	        RET
  149	 	 	 	 	
  150	 00A6	 	 	 	PSTRG:
  151	 00A6  80 3E 0001 R 00	 	        CMP     [$$PUFL],0      ;Check for PRINT USING
  152	 00AB  75 ED	 	 	        JNZ     PUEN
  153	 00AD  80 3E 0000 R 00	 	        CMP     [$$WRFL],0      ;WRITE?
  154	 00B2  75 15	 	 	        JNZ     WRTSTR
  155	 00B4  8B 07	 	 	        MOV     AX,[BX]         ;Get length in AX
  156	 00B6  B1 00	 	 	        MOV     CL,0            ;No special comma test
  157	 00B8  E8 0113 R	 	        CALL    PRTCHK          ;Try to make it fit on the line
  158	 00BB  E8 0000 E	 	        CALL    $TYPSTR         ;Output the string
  159	 00BE  E8 0000 E	 	        CALL    $$DITS          ;Delete it if temporary string
  160	 00C1  80 3E 0000 E 01	 	        CMP     [CURTYP],SEMI   ;What do we finish with?
  161	 00C6  75 CA	 	 	        JNZ     STREND
  162	 00C8  C3	 	 	        RET


PRNVAL - Print values                                    Macro-86 %1(12)   1:7:5  13-Nov-81    Page 1-4



  163	 	 	 	 	
  164	 00C9	 	 	 	WRTSTR:
  165	 00C9  B0 22	 	 	        MOV     AL,'"'
  166	 00CB  E8 0000 E	 	        CALL    $$WCH
  167	 00CE  E8 0000 E	 	        CALL    $TYPSTR
  168	 00D1  E8 0000 E	 	        CALL    $$DITS
  169	 00D4  B0 22	 	 	        MOV     AL,'"'
  170	 00D6  E8 0000 E	 	        CALL    $$WCH
  171	 00D9  EB 10	 	 	        JMP     SHORT WRTTST
  172	 	 	 	 	
  173	 00DB	 	 	 	WRVAL:
  174	 00DB  80 3C 20	 	 	        CMP     BYTE PTR[SI]," "  ;Is first letter a blank?
  175	 00DE  75 01	 	 	        JNZ     WRTVAL
  176	 00E0  46	 	 	        INC     SI
  177	 00E1	 	 	 	WRTVAL:
  178	 00E1  AC	 	 	        LODSB
  179	 00E2  0A C0	 	 	        OR      AL,AL
  180	 00E4  74 05	 	 	        JZ      WRTTST
  181	 00E6  E8 0000 E	 	        CALL    $$WCH
  182	 00E9  EB F6	 	 	        JMP     WRTVAL
  183	 00EB	 	 	 	WRTTST:
  184	 00EB  B0 2C	 	 	        MOV     AL,","
  185	 00ED  EB 9C	 	 	        JMP     CHKEND
  186	 	 	 	 	
  187	 00EF	 	 	 	CMA:
  188	 00EF  E8 0000 E	 	        CALL    $$POS
  189	 00F2  8A C4	 	 	        MOV     AL,AH
  190	 00F4  B4 00	 	 	        MOV     AH,0
  191	 00F6  B1 0E	 	 	        MOV     CL,CLMWID
  192	 00F8  F6 F1	 	 	        DIV     CL              ;Remainder is position in this column
  193	 00FA  2A CC	 	 	        SUB     CL,AH           ;Amount left in this column
  194	 00FC  8A C1	 	 	        MOV     AL,CL
  195	 00FE  98	 	 	        CBW                     ;Amount to print is 16-bit number
  196	 00FF  05 000E	 	 	        ADD     AX,CLMWID       ;Account for width of next column
  197	 0102  E8 0113 R	 	        CALL    PRTCHK          ;Will another column fit?
  198	 0105  2D 000E	 	 	        SUB     AX,CLMWID
  199	 0108  76 2B	 	 	        JBE     RET
  200	 010A  91	 	 	        XCHG    AX,CX
  201	 010B	 	 	 	TAB:
  202	 010B  B0 20	 	 	        MOV     AL," "
  203	 010D  E8 0000 E	 	        CALL    $$WCH
  204	 0110  E2 F9	 	 	        LOOP    TAB
  205	 0112  C3	 	 	        RET
  206	 	 	 	 	
  207	 	 	 	 	
  208	 0113	 	 	 	PRTCHK:
  209	 	 	 	 	;Check for enough space remaining on line to print AX characters. If not
  210	 	 	 	 	;enough, start new line.
  211	 	 	 	 	
  212	 0113  50	 	 	        PUSH    AX
  213	 0114  E8 0000 E	 	        CALL    $$WID
  214	 0117  8A EC	 	 	        MOV     CH,AH
  215	 0119  80 FD FF	 	 	        CMP     CH,255
  216	 011C  58	 	 	        POP     AX


PRNVAL - Print values                                    Macro-86 %1(12)   1:7:5  13-Nov-81    Page 1-5



  217	 011D  74 16	 	 	        JZ      RET
  218	 011F  0A E4	 	 	        OR      AH,AH           ;More than 255 char to print?
  219	 0121  75 0D	 	 	        JNZ     FORCE
  220	 0123  50	 	 	        PUSH    AX
  221	 0124  E8 0000 E	 	        CALL    $$POS
  222	 0127  2A EC	 	 	        SUB     CH,AH           ;Amount left on line
  223	 0129  58	 	 	        POP     AX
  224	 012A  72 04	 	 	        JB      FORCE           ;If no room on line, need new line
  225	 012C  3A C5	 	 	        CMP     AL,CH           ;Will amount requested fit?
  226	 012E  76 05	 	 	        JBE     RET
  227	 0130	 	 	 	FORCE:
  228	 0130  E8 0000 E	 	        CALL    $$WCLF          ;Force the CR/LF
  229	 0133  33 C0	 	 	        XOR     AX,AX
  230	 0135  C3	 	 	RET:    RET
  231	 	 	 	 	
  232	 0136	 	 	 	CODE    ENDS
  233	 	 	 	 	        END







































PRNVAL - Print values                                    Macro-86 %1(12)   1:7:5  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0136	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0004	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

CHKEND . . . . . . . . . . . . .	L NEAR 	008B	CODE
CLMWID . . . . . . . . . . . . .	Number	000E	
CMA. . . . . . . . . . . . . . .	L NEAR 	00EF	CODE
COMMA. . . . . . . . . . . . . .	Number	0000	
CRLF . . . . . . . . . . . . . .	Number	0002	
CURTYP . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
DBL. . . . . . . . . . . . . . .	Number	0008	
ENDLIN . . . . . . . . . . . . .	L NEAR 	0094	CODE
FORCE. . . . . . . . . . . . . .	L NEAR 	0130	CODE
INT. . . . . . . . . . . . . . .	Number	0002	
PRINT. . . . . . . . . . . . . .	L NEAR 	003C	CODE
PRTCHK . . . . . . . . . . . . .	L NEAR 	0113	CODE
PRVAL. . . . . . . . . . . . . .	L NEAR 	007F	CODE
PSTRG. . . . . . . . . . . . . .	L NEAR 	00A6	CODE
PUEN . . . . . . . . . . . . . .	L NEAR 	009A	CODE
RET. . . . . . . . . . . . . . .	L NEAR 	0135	CODE
SEMI . . . . . . . . . . . . . .	Number	0001	
SNGL . . . . . . . . . . . . . .	Number	0004	
STOINT . . . . . . . . . . . . .	L NEAR 	0064	CODE
STREND . . . . . . . . . . . . .	L NEAR 	0092	CODE
STRING . . . . . . . . . . . . .	Number	0003	
TAB. . . . . . . . . . . . . . .	L NEAR 	010B	CODE
TSTPRUS. . . . . . . . . . . . .	L NEAR 	0068	CODE
TYP. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
VALTYP . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
WRTJMP . . . . . . . . . . . . .	L NEAR 	0097	CODE
WRTSPC . . . . . . . . . . . . .	L NEAR 	0089	CODE
WRTSTR . . . . . . . . . . . . .	L NEAR 	00C9	CODE
WRTTST . . . . . . . . . . . . .	L NEAR 	00EB	CODE
WRTVAL . . . . . . . . . . . . .	L NEAR 	00E1	CODE
WRVAL. . . . . . . . . . . . . .	L NEAR 	00DB	CODE
$$DITS . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$POS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$PUEN . . . . . . . . . . . . .	L WORD 	0002	DATA	Global
$$PUFL . . . . . . . . . . . . .	L BYTE 	0001	DATA	Global
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$WCH. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$WCLF . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$WID. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$WRFL . . . . . . . . . . . . .	L BYTE 	0000	DATA	Global
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External


PRNVAL - Print values                                    Macro-86 %1(12)   1:7:5  13-Nov-81    Symbols-2



$FOUT. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$PV0A. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$PV0B. . . . . . . . . . . . . .	L NEAR 	0005	CODE	Global
$PV0C. . . . . . . . . . . . . .	L NEAR 	000A	CODE	Global
$PV0D. . . . . . . . . . . . . .	L NEAR 	000F	CODE	Global
$PV1A. . . . . . . . . . . . . .	L NEAR 	0014	CODE	Global
$PV1B. . . . . . . . . . . . . .	L NEAR 	0019	CODE	Global
$PV1C. . . . . . . . . . . . . .	L NEAR 	001E	CODE	Global
$PV1D. . . . . . . . . . . . . .	L NEAR 	0023	CODE	Global
$PV2A. . . . . . . . . . . . . .	L NEAR 	0028	CODE	Global
$PV2B. . . . . . . . . . . . . .	L NEAR 	002D	CODE	Global
$PV2C. . . . . . . . . . . . . .	L NEAR 	0032	CODE	Global
$PV2D. . . . . . . . . . . . . .	L NEAR 	0037	CODE	Global
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TYPSTR. . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0





































