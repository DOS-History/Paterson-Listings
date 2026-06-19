INVOLD - Double precision involution operator            Macro-86 %1(12)   0:59:33  13-Nov-81   Page 1-1



    1	 	 	 	 	        TITLE   INVOLD - Double precision involution operator
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $DAC:WORD, $ARG:WORD, $FAC:BYTE, $TEMP:WORD, $TEMP2:WORD
    6	 	 	 	 	
    7	 0000  ????	 	 	POWERCNT DW     ?
    8	 0002  ??	 	 	FLAG    DB      ?
    9	 	 	 	 	
   10	 0003	 	 	 	DATA    ENDS
   11	 	 	 	 	
   12	 	 	 	 	
   13	 	 	 	 	DC      GROUP   DATA
   14	 	 	 	 	
   15	 	 	 	 	
   16	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   17	 	 	 	 	
   18	 	 	 	 	        PUBLIC  $FEXB, $FEXD, $FEXF, $FEXH
   19	 	 	 	 	
   20	 	 	 	 	        EXTRN   $SAVREG:NEAR, $DMUL:NEAR, $GTMP:NEAR, $LOD:FAR, $DEXP:NEAR
   21	 	 	 	 	        EXTRN   $DDIV:NEAR, $DSUB:NEAR, $FID:FAR, $DIV0:NEAR, $ERC_FC:NEAR
   22	 	 	 	 	        EXTRN   $PUT1D:NEAR
   23	 	 	 	 	
   24	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   25	 	 	 	 	
   26	 	 	 	 	; Suffix B means address of operands in SI and DI
   27	 	 	 	 	; Suffix D means first operand is FAC, second is at [DI] (SI smashed)
   28	 	 	 	 	; Suffix F means first operand is at [SI], second is FAC (DI smashed)
   29	 	 	 	 	; Suffix H means first operand is floating temp, second is FAC (SI and DI hit)
   30	 	 	 	 	
   31	 0000	 	 	 	$FEXD:
   32	 0000  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   33	 0003  EB 06	 	 	        JMP     SHORT $FEXB
   34	 0005	 	 	 	$FEXH:
   35	 0005  E8 0000 E	 	        CALL    $GTMP
   36	 0008	 	 	 	$FEXF:
   37	 0008  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   38	 000B	 	 	 	$FEXB:
   39	 000B  E8 0000 E	 	        CALL    $SAVREG
   40	 000E  33 C0	 	 	        XOR     AX,AX
   41	 0010  A2 0002 R	 	        MOV     [FLAG],AL       ;Set sign positive, no mul or div needed yet
   42	 0013  A3 0000 R	 	        MOV     [POWERCNT],AX
   43	 0016  8B 45 06	 	 	        MOV     AX,[DI+6]       ;Get sign and exponent of Y
   44	 0019  0A E4	 	 	        OR      AH,AH           ;Is Y zero?
   45	 001B  74 5A	 	 	        JZ      ONE
   46	 001D  8B 54 06	 	 	        MOV     DX,[SI+6]
   47	 0020  0A F6	 	 	        OR      DH,DH           ;Is X zero?
   48	 0022  74 56	 	 	        JZ      ZERCHK
   49	 0024  8B DF	 	 	        MOV     BX,DI           ;Save address of Y
   50	 0026  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP2
   51	 0029  A5	 	 	        MOVSW                   ;Save X in TEMP2
   52	 002A  A5	 	 	        MOVSW
   53	 002B  A5	 	 	        MOVSW
   54	 002C  A5	 	 	        MOVSW


INVOLD - Double precision involution operator            Macro-86 %1(12)   0:59:33  13-Nov-81   Page 1-2



   55	 002D  8B F3	 	 	        MOV     SI,BX
   56	 002F  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
   57	 0032  A5	 	 	        MOVSW                   ;Move Y to TEMP
   58	 0033  A5	 	 	        MOVSW
   59	 0034  A5	 	 	        MOVSW
   60	 0035  AB	 	 	        STOSW                   ;AX already has high word
   61	 0036  9A 0000 ---- E	 	        CALL    $FID            ;FAC = INT(Y)
   62	 	 	 	 	;DAC has INT(Y), TEMP has Y, TEMP2 has X
   63	 003B  80 FC 90	 	 	        CMP     AH,80H+16       ;ABS(Y) >= 2^16?
   64	 003E  76 4A	 	 	        JBE     SMALLPOWER
   65	 	 	 	 	;At this point we have a power larger than 2^16. This is so large that
   66	 	 	 	 	;instead of doing repeat multiplies we will just use EXP(Y*LOG(X))
   67	 0040  0A D2	 	 	        OR      DL,DL           ;X < 0?
   68	 0042  79 31	 	 	        JNS     LOGPOWERJ
   69	 	 	 	 	;Using LOG and EXP is fine if the base is positive. We're here because the
   70	 	 	 	 	;the base is negative (which won't wash with LOG). Involution is defined
   71	 	 	 	 	;for negative base only if the power is integer. Then, if the integer is
   72	 	 	 	 	;odd, the result is -[abs(x)^y]; if even, it's abs(x)^y. If the number is
   73	 	 	 	 	;too large to include a 2^0 bit in its 56-bit mantissa, then we can't
   74	 	 	 	 	;determine even or odd and call this an error.
   75	 0044  80 FC B8	 	 	        CMP     AH,80H+56       ;ABS(Y) >= 2^56?
   76	 0047  77 3E	 	 	        JA      ARGERR          ;If so, can't tell if odd - error!
   77	 0049  BE 0000 E	 	        MOV     SI,OFFSET DC:$TEMP
   78	 004C  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   79	 004F  B9 0003	 	 	        MOV     CX,3
   80	 0052  F3/ A7	 	 	        REPE    CMPSW           ;Compare Y, INT(Y) to see if Y is integer
   81	 0054  75 31	 	 	        JNZ     ARGERR
   82	 	 	 	 	;It's going to work, now we just need that 2^0 bit for even/odd determination
   83	 0056  80 EC 81	 	 	        SUB     AH,80H+1        ;Get shift count range 16-55
   84	 0059  8A CC	 	 	        MOV     CL,AH
   85	 005B  80 E1 07	 	 	        AND     CL,7            ;Get bit within byte
   86	 005E  8A C4	 	 	        MOV     AL,AH
   87	 0060  D0 E8	 	 	        SHR     AL,1
   88	 0062  D0 E8	 	 	        SHR     AL,1
   89	 0064  D0 E8	 	 	        SHR     AL,1
   90	 0066  98	 	 	        CBW
   91	 0067  2B F8	 	 	        SUB     DI,AX           ;Points to byte with even/odd bit
   92	 0069  8A 05	 	 	        MOV     AL,[DI]
   93	 006B  D2 E0	 	 	        SHL     AL,CL           ;LSB of Y in bit 7, to tell us even or odd
   94	 006D  A2 0002 R	 	        MOV     [FLAG],AL       ;Use it as sign of result
   95	 0070  80 26 0006 E 7F	 	        AND     BYTE PTR [$TEMP2+6],7FH ;Make X positive
   96	 0075	 	 	 	LOGPOWERJ:
   97	 0075  EB 45	 	 	        JMP     SHORT LOGPOWER
   98	 	 	 	 	
   99	 0077  E9 0000 E	 	ONE:    JMP     $PUT1D
  100	 	 	 	 	
  101	 007A	 	 	 	ZERCHK:
  102	 007A  C6 06 0000 E 00	 	        MOV     [$FAC],0        ;Put a zero in FAC
  103	 007F  0A C0	 	 	        OR      AL,AL           ;Is power negative?
  104	 0081  79 03	 	 	        JNS     RET
  105	 0083  E9 0000 E	 	        JMP     $DIV0           ;If so, that's 1/0 - divide zero error
  106	 0086  C3	 	 	RET:    RET
  107	 	 	 	 	
  108	 0087  E9 0000 E	 	ARGERR: JMP     $ERC_FC         ;Illegal function call


INVOLD - Double precision involution operator            Macro-86 %1(12)   0:59:33  13-Nov-81   Page 1-3



  109	 	 	 	 	
  110	 008A	 	 	 	SMALLPOWER:
  111	 008A  80 FC 80	 	 	        CMP     AH,80H          ;Y < 1?
  112	 008D  76 1A	 	 	        JBE     ZEROPWR
  113	 008F  B1 90	 	 	        MOV     CL,80H+16
  114	 0091  2A CC	 	 	        SUB     CL,AH           ;Shift count to make Y integer
  115	 0093  8A F8	 	 	        MOV     BH,AL
  116	 0095  8A DD	 	 	        MOV     BL,CH           ;Mantissa of Y in BX
  117	 0097  80 CF 80	 	 	        OR      BH,80H          ;Set implied bit
  118	 009A  D3 EB	 	 	        SHR     BX,CL           ;BX = Y as integer
  119	 009C  89 1E 0000 R	 	        MOV     [POWERCNT],BX
  120	 00A0  0A C0	 	 	        OR      AL,AL           ;Y < 0?
  121	 00A2  79 05	 	 	        JNS     ZEROPWR
  122	 00A4  80 0E 0002 R 02	 	        OR      [FLAG],2        ;Since power is negative, we'll need to invert
  123	 00A9	 	 	 	ZEROPWR:
  124	 00A9  BE 0000 E	 	        MOV     SI,OFFSET DC:$TEMP
  125	 00AC  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  126	 00AF  E8 0000 E	 	        CALL    $DSUB           ;FAC = Y - INT(Y)
  127	 00B2  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  128	 00B5  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
  129	 00B8  A5	 	 	        MOVSW                   ;Move result back to TEMP
  130	 00B9  A5	 	 	        MOVSW
  131	 00BA  A5	 	 	        MOVSW
  132	 00BB  A5	 	 	        MOVSW
  133	 00BC	 	 	 	LOGPOWER:
  134	 	 	 	 	;TEMP has FRAC(Y), TEMP2 has X
  135	 00BC  80 3E 0007 E 00	 	        CMP     BYTE PTR [$TEMP+7],0  ;Is fraction part zero?
  136	 00C1  74 1E	 	 	        JZ      MULPOWER
  137	 00C3  BB 0000 E	 	        MOV     BX,OFFSET DC:$TEMP2
  138	 00C6  9A 0000 ---- E	 	        CALL    $LOD            ;Take log base e of X
  139	 00CB  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  140	 00CE  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
  141	 00D1  E8 0000 E	 	        CALL    $DMUL           ;FAC = Y * LN(X)
  142	 00D4  BB 0000 E	 	        MOV     BX,OFFSET DC:$DAC
  143	 00D7  E8 0000 E	 	        CALL    $DEXP           ;FAC = e^(Y*LN(X))
  144	 00DA  80 0E 0002 R 01	 	        OR      [FLAG],1        ;Multiplication by integer part will be needed
  145	 00DF  EB 03	 	 	        JMP     SHORT MULCHK
  146	 	 	 	 	
  147	 00E1	 	 	 	MULPOWER:
  148	 00E1  E8 0000 E	 	        CALL    $PUT1D          ;Put a one in FAC as result of fraction part
  149	 00E4	 	 	 	MULCHK:
  150	 00E4  8B 0E 0000 R	 	        MOV     CX,[POWERCNT]
  151	 00E8  E3 26	 	 	        JCXZ    SETSIGN
  152	 00EA  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  153	 00ED  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
  154	 00F0  A5	 	 	        MOVSW                   ;Copy result of fraction part to TEMP
  155	 00F1  A5	 	 	        MOVSW
  156	 00F2  A5	 	 	        MOVSW
  157	 00F3  A5	 	 	        MOVSW
  158	 00F4  E8 011A R	 	        CALL    XTON            ;Raise TEMP2 to CX power
  159	 00F7  A0 0002 R	 	        MOV     AL,[FLAG]
  160	 00FA  A8 03	 	 	        TEST    AL,3            ;Need to multiply or divide?
  161	 00FC  74 12	 	 	        JZ      SETSIGN
  162	 00FE  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC


INVOLD - Double precision involution operator            Macro-86 %1(12)   0:59:33  13-Nov-81   Page 1-4



  163	 0101  BE 0000 E	 	        MOV     SI,OFFSET DC:$TEMP
  164	 0104  A8 02	 	 	        TEST    AL,2            ;Need to divide?
  165	 0106  75 05	 	 	        JNZ     POSTDIV
  166	 0108  E8 0000 E	 	        CALL    $DMUL
  167	 010B  EB 03	 	 	        JMP     SHORT SETSIGN
  168	 	 	 	 	
  169	 010D	 	 	 	POSTDIV:
  170	 010D  E8 0000 E	 	        CALL    $DDIV
  171	 0110	 	 	 	SETSIGN:
  172	 0110  A0 0002 R	 	        MOV     AL,[FLAG]
  173	 0113  24 80	 	 	        AND     AL,80H          ;Mask to sign bit
  174	 0115  08 06 FFFF E	 	        OR      [$FAC-1],AL     ;Set sign of result
  175	 0119  C3	 	 	DONE:   RET
  176	 	 	 	 	
  177	 011A	 	 	 	XTON:   ;Raise $TEMP2 to CX power by repeat multiplication
  178	 011A  E8 0000 E	 	        CALL    $PUT1D          ;Put 1 in FAC
  179	 011D	 	 	 	INTPWR:
  180	 011D  D1 E9	 	 	        SHR     CX,1            ;Need to multiply by this power?
  181	 011F  73 0B	 	 	        JNC     SQUARE
  182	 0121  51	 	 	        PUSH    CX
  183	 0122  BE 0000 E	 	        MOV     SI,OFFSET DC:$TEMP2
  184	 0125  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  185	 0128  E8 0000 E	 	        CALL    $DMUL
  186	 012B  59	 	 	        POP     CX
  187	 012C	 	 	 	SQUARE:
  188	 012C  E3 EB	 	 	        JCXZ    DONE
  189	 012E  51	 	 	        PUSH    CX
  190	 012F  FF 36 0000 E	 	        PUSH    [$DAC]
  191	 0133  FF 36 0002 E	 	        PUSH    [$DAC+2]
  192	 0137  FF 36 0004 E	 	        PUSH    [$DAC+4]
  193	 013B  FF 36 0006 E	 	        PUSH    [$DAC+6]
  194	 013F  BE 0000 E	 	        MOV     SI,OFFSET DC:$TEMP2
  195	 0142  8B FE	 	 	        MOV     DI,SI
  196	 0144  E8 0000 E	 	        CALL    $DMUL           ;Square argument
  197	 0147  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  198	 014A  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP2
  199	 014D  A5	 	 	        MOVSW
  200	 014E  A5	 	 	        MOVSW
  201	 014F  A5	 	 	        MOVSW
  202	 0150  A5	 	 	        MOVSW                   ;And move it back to TEMP2
  203	 0151  8F 06 0006 E	 	        POP     [$DAC+6]
  204	 0155  8F 06 0004 E	 	        POP     [$DAC+4]
  205	 0159  8F 06 0002 E	 	        POP     [$DAC+2]
  206	 015D  8F 06 0000 E	 	        POP     [$DAC]          ;Restore power being built in FAC
  207	 0161  59	 	 	        POP     CX
  208	 0162  EB B9	 	 	        JMP     INTPWR
  209	 	 	 	 	
  210	 0164	 	 	 	CODE    ENDS
  211	 	 	 	 	        END







INVOLD - Double precision involution operator            Macro-86 %1(12)   0:59:33  13-Nov-81   Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0164	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0003	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ARGERR . . . . . . . . . . . . .	L NEAR 	0087	CODE
DONE . . . . . . . . . . . . . .	L NEAR 	0119	CODE
FLAG . . . . . . . . . . . . . .	L BYTE 	0002	DATA
INTPWR . . . . . . . . . . . . .	L NEAR 	011D	CODE
LOGPOWER . . . . . . . . . . . .	L NEAR 	00BC	CODE
LOGPOWERJ. . . . . . . . . . . .	L NEAR 	0075	CODE
MULCHK . . . . . . . . . . . . .	L NEAR 	00E4	CODE
MULPOWER . . . . . . . . . . . .	L NEAR 	00E1	CODE
ONE. . . . . . . . . . . . . . .	L NEAR 	0077	CODE
POSTDIV. . . . . . . . . . . . .	L NEAR 	010D	CODE
POWERCNT . . . . . . . . . . . .	L WORD 	0000	DATA
RET. . . . . . . . . . . . . . .	L NEAR 	0086	CODE
SETSIGN. . . . . . . . . . . . .	L NEAR 	0110	CODE
SMALLPOWER . . . . . . . . . . .	L NEAR 	008A	CODE
SQUARE . . . . . . . . . . . . .	L NEAR 	012C	CODE
XTON . . . . . . . . . . . . . .	L NEAR 	011A	CODE
ZERCHK . . . . . . . . . . . . .	L NEAR 	007A	CODE
ZEROPWR. . . . . . . . . . . . .	L NEAR 	00A9	CODE
$ARG . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DDIV. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DEXP. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DIV0. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DSUB. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FEXB. . . . . . . . . . . . . .	L NEAR 	000B	CODE	Global
$FEXD. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$FEXF. . . . . . . . . . . . . .	L NEAR 	0008	CODE	Global
$FEXH. . . . . . . . . . . . . .	L NEAR 	0005	CODE	Global
$FID . . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$GTMP. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$LOD . . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$PUT1D . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TEMP. . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$TEMP2 . . . . . . . . . . . . .	V WORD 	0000	DATA	External

Warning Severe
Errors	Errors 
0	0


