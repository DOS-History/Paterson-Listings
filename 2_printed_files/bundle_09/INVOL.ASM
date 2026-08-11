INVOL - Involution operator                              Macro-86 %1(12)   1:7:38  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   INVOL - Involution operator
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $AC:WORD, $ARG:WORD, $FAC:BYTE, $TEMP:WORD
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
   18	 	 	 	 	        PUBLIC  $FEXA, $FEXC, $FEXE, $FEXG
   19	 	 	 	 	
   20	 	 	 	 	        EXTRN   $SAVREG:NEAR, $SMUL:NEAR, $GTMP:NEAR, $LOG2:NEAR, $EXP2:NEAR
   21	 	 	 	 	        EXTRN   $SDIV:NEAR, $SSUB:NEAR, $FIX:FAR, $DIV0:NEAR, $ERC_FC:NEAR
   22	 	 	 	 	
   23	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   24	 	 	 	 	
   25	 	 	 	 	; Suffix A means address of operands in SI and DI
   26	 	 	 	 	; Suffix C means first operand is FAC, second is at [DI] (SI smashed)
   27	 	 	 	 	; Suffix E means first operand is at [SI], second is FAC (DI smashed)
   28	 	 	 	 	; Suffix G means first operand is floating temp, second is FAC (SI and DI hit)
   29	 	 	 	 	
   30	 0000	 	 	 	$FEXC:
   31	 0000  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   32	 0003  EB 06	 	 	        JMP     SHORT $FEXA
   33	 0005	 	 	 	$FEXG:
   34	 0005  E8 0000 E	 	        CALL    $GTMP
   35	 0008	 	 	 	$FEXE:
   36	 0008  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   37	 000B	 	 	 	$FEXA:
   38	 000B  E8 0000 E	 	        CALL    $SAVREG
   39	 000E  33 C0	 	 	        XOR     AX,AX
   40	 0010  A2 0002 R	 	        MOV     [FLAG],AL       ;Set sign positive, no mul or div needed yet
   41	 0013  A3 0000 R	 	        MOV     [POWERCNT],AX
   42	 0016  8B 45 02	 	 	        MOV     AX,[DI+2]       ;Get sign and exponent of Y
   43	 0019  0A E4	 	 	        OR      AH,AH           ;Is Y zero?
   44	 001B  74 3D	 	 	        JZ      ONE
   45	 001D  8B 54 02	 	 	        MOV     DX,[SI+2]
   46	 0020  0A F6	 	 	        OR      DH,DH           ;Is X zero?
   47	 0022  74 43	 	 	        JZ      ZERCHK
   48	 0024  FF 34	 	 	        PUSH    [SI]            ;Save the rest of X
   49	 0026  8B 0D	 	 	        MOV     CX,[DI]         ;Get the rest of Y
   50	 0028  89 0E 0000 E	 	        MOV     [$TEMP],CX      ;Save Y in TEMP
   51	 002C  A3 0002 E	 	        MOV     [$TEMP+2],AX
   52	 002F  8B DF	 	 	        MOV     BX,DI
   53	 0031  9A 0000 ---- E	 	        CALL    $FIX
   54	 0036  80 FC 90	 	 	        CMP     AH,80H+16       ;ABS(Y) >= 2^16?


INVOL - Involution operator                              Macro-86 %1(12)   1:7:38  13-Nov-81    Page 1-2



   55	 0039  76 3B	 	 	        JBE     SMALLPOWER
   56	 003B  0A D2	 	 	        OR      DL,DL           ;X < 0?
   57	 003D  79 69	 	 	        JNS     LOGPOWER
   58	 003F  80 FC 98	 	 	        CMP     AH,80H+24       ;ABS(Y) >= 2^24?
   59	 0042  77 2F	 	 	        JA      ARGERR          ;If so, can't tell if odd - error!
   60	 0044  3A 0E FFFD E	 	        CMP     CL,[$FAC-3]     ;Does INT(Y) = Y? (Other 24 bits must be =)
   61	 0048  75 29	 	 	        JNZ     ARGERR
   62	 004A  80 EC 91	 	 	        SUB     AH,80H+17       ;Get shift count range 0-7
   63	 004D  86 CC	 	 	        XCHG    CL,AH
   64	 004F  D2 E4	 	 	        SHL     AH,CL           ;LSB of Y in bit 7, to tell us even or odd
   65	 0051  88 26 0002 R	 	        MOV     [FLAG],AH       ;Use it as sign of result
   66	 0055  80 E2 7F	 	 	        AND     DL,7FH          ;Make X positive
   67	 0058  EB 4E	 	 	        JMP     SHORT LOGPOWER
   68	 	 	 	 	
   69	 005A	 	 	 	ONE:
   70	 005A  C7 06 0000 E 0000	        MOV     [$AC],0
   71	 0060  C7 06 0002 E 8100	        MOV     [$AC+2],8100H   ;Jam floating one into FAC
   72	 0066  C3	 	 	RET:    RET
   73	 	 	 	 	
   74	 0067	 	 	 	ZERCHK:
   75	 0067  C6 06 0000 E 00	 	        MOV     [$FAC],0        ;Put a zero in FAC
   76	 006C  0A C0	 	 	        OR      AL,AL           ;Is power negative?
   77	 006E  79 F6	 	 	        JNS     RET
   78	 0070  E9 0000 E	 	        JMP     $DIV0           ;If so, that's 1/0 - divide zero error
   79	 	 	 	 	
   80	 0073  E9 0000 E	 	ARGERR: JMP     $ERC_FC         ;Illegal function call
   81	 	 	 	 	
   82	 0076	 	 	 	SMALLPOWER:
   83	 0076  80 FC 80	 	 	        CMP     AH,80H          ;Y < 1?
   84	 0079  76 1A	 	 	        JBE     ZEROPWR
   85	 007B  B1 90	 	 	        MOV     CL,80H+16
   86	 007D  2A CC	 	 	        SUB     CL,AH           ;Shift count to make Y integer
   87	 007F  8A F8	 	 	        MOV     BH,AL
   88	 0081  8A DD	 	 	        MOV     BL,CH           ;Mantissa of Y in BX
   89	 0083  80 CF 80	 	 	        OR      BH,80H          ;Set implied bit
   90	 0086  D3 EB	 	 	        SHR     BX,CL           ;BX = Y as integer
   91	 0088  89 1E 0000 R	 	        MOV     [POWERCNT],BX
   92	 008C  0A C0	 	 	        OR      AL,AL           ;Y < 0?
   93	 008E  79 05	 	 	        JNS     ZEROPWR
   94	 0090  80 0E 0002 R 02	 	        OR      [FLAG],2        ;Since power is negative, we'll need to invert
   95	 0095	 	 	 	ZEROPWR:
   96	 0095  52	 	 	        PUSH    DX              ;Save high half of X
   97	 0096  BE 0000 E	 	        MOV     SI,OFFSET DC:$TEMP
   98	 0099  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   99	 009C  E8 0000 E	 	        CALL    $SSUB           ;FAC = Y - INT(Y)
  100	 009F  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
  101	 00A2  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
  102	 00A5  A5	 	 	        MOVSW                   ;Move result back to TEMP
  103	 00A6  A5	 	 	        MOVSW
  104	 00A7  5A	 	 	        POP     DX
  105	 00A8	 	 	 	LOGPOWER:
  106	 00A8  58	 	 	        POP     AX              ;X now in DX:AX
  107	 00A9  80 3E 0003 E 00	 	        CMP     BYTE PTR [$TEMP+3],0  ;Is fraction part zero?
  108	 00AE  74 21	 	 	        JZ      MULPOWER


INVOL - Involution operator                              Macro-86 %1(12)   1:7:38  13-Nov-81    Page 1-3



  109	 00B0  50	 	 	        PUSH    AX
  110	 00B1  52	 	 	        PUSH    DX              ;Save X on stack
  111	 00B2  A3 0000 E	 	        MOV     [$AC],AX
  112	 00B5  89 16 0002 E	 	        MOV     [$AC+2],DX      ;And put in FAC for polynomial evaluation
  113	 00B9  E8 0000 E	 	        CALL    $LOG2           ;Take log base 2
  114	 00BC  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
  115	 00BF  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
  116	 00C2  E8 0000 E	 	        CALL    $SMUL           ;FAC = Y * LOG2(X)
  117	 00C5  E8 0000 E	 	        CALL    $EXP2           ;FAC = 2^(Y*LOG2(X))
  118	 00C8  5A	 	 	        POP     DX
  119	 00C9  58	 	 	        POP     AX              ;Restore X to DX:AX
  120	 00CA  80 0E 0002 R 01	 	        OR      [FLAG],1        ;Multiplication by integer part will be needed
  121	 00CF  EB 03	 	 	        JMP     SHORT MULCHK
  122	 	 	 	 	
  123	 00D1	 	 	 	MULPOWER:
  124	 00D1  E8 005A R	 	        CALL    ONE             ;Put a one in FAC as result of fraction part
  125	 00D4	 	 	 	MULCHK:
  126	 00D4  8B 0E 0000 R	 	        MOV     CX,[POWERCNT]
  127	 00D8  E3 2B	 	 	        JCXZ    SETSIGN
  128	 00DA  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
  129	 00DD  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
  130	 00E0  A5	 	 	        MOVSW                   ;Copy result of fraction part to TEMP
  131	 00E1  A5	 	 	        MOVSW
  132	 00E2  A3 0000 E	 	        MOV     [$ARG],AX
  133	 00E5  89 16 0002 E	 	        MOV     [$ARG+2],DX     ;Put X in ARG
  134	 00E9  E8 010F R	 	        CALL    XTON            ;Raise ARG to CX power
  135	 00EC  A0 0002 R	 	        MOV     AL,[FLAG]
  136	 00EF  A8 03	 	 	        TEST    AL,3            ;Need to multiply or divide?
  137	 00F1  74 12	 	 	        JZ      SETSIGN
  138	 00F3  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
  139	 00F6  BE 0000 E	 	        MOV     SI,OFFSET DC:$TEMP
  140	 00F9  A8 02	 	 	        TEST    AL,2            ;Need to divide?
  141	 00FB  75 05	 	 	        JNZ     POSTDIV
  142	 00FD  E8 0000 E	 	        CALL    $SMUL
  143	 0100  EB 03	 	 	        JMP     SHORT SETSIGN
  144	 	 	 	 	
  145	 0102	 	 	 	POSTDIV:
  146	 0102  E8 0000 E	 	        CALL    $SDIV
  147	 0105	 	 	 	SETSIGN:
  148	 0105  A0 0002 R	 	        MOV     AL,[FLAG]
  149	 0108  24 80	 	 	        AND     AL,80H          ;Mask to sign bit
  150	 010A  08 06 FFFF E	 	        OR      [$FAC-1],AL     ;Set sign of result
  151	 010E  C3	 	 	DONE:   RET
  152	 	 	 	 	
  153	 010F	 	 	 	XTON:   ;Raise $ARG to CX power by repeat multiplication
  154	 010F  E8 005A R	 	        CALL    ONE             ;Put 1 in FAC
  155	 0112	 	 	 	INTPWR:
  156	 0112  D1 E9	 	 	        SHR     CX,1            ;Need to multiply by this power?
  157	 0114  73 0B	 	 	        JNC     SQUARE
  158	 0116  51	 	 	        PUSH    CX
  159	 0117  BE 0000 E	 	        MOV     SI,OFFSET DC:$ARG
  160	 011A  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
  161	 011D  E8 0000 E	 	        CALL    $SMUL
  162	 0120  59	 	 	        POP     CX


INVOL - Involution operator                              Macro-86 %1(12)   1:7:38  13-Nov-81    Page 1-4



  163	 0121	 	 	 	SQUARE:
  164	 0121  E3 EB	 	 	        JCXZ    DONE
  165	 0123  51	 	 	        PUSH    CX
  166	 0124  FF 36 0000 E	 	        PUSH    [$AC]
  167	 0128  FF 36 0002 E	 	        PUSH    [$AC+2]
  168	 012C  BE 0000 E	 	        MOV     SI,OFFSET DC:$ARG
  169	 012F  8B FE	 	 	        MOV     DI,SI
  170	 0131  E8 0000 E	 	        CALL    $SMUL           ;Square argument
  171	 0134  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
  172	 0137  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
  173	 013A  A5	 	 	        MOVSW
  174	 013B  A5	 	 	        MOVSW                   ;And move it back to ARG
  175	 013C  8F 06 0002 E	 	        POP     [$AC+2]
  176	 0140  8F 06 0000 E	 	        POP     [$AC]           ;Restore power being built in FAC
  177	 0144  59	 	 	        POP     CX
  178	 0145  EB CB	 	 	        JMP     INTPWR
  179	 	 	 	 	
  180	 0147	 	 	 	CODE    ENDS
  181	 	 	 	 	        END





































INVOL - Involution operator                              Macro-86 %1(12)   1:7:38  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0147	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0003	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ARGERR . . . . . . . . . . . . .	L NEAR 	0073	CODE
DONE . . . . . . . . . . . . . .	L NEAR 	010E	CODE
FLAG . . . . . . . . . . . . . .	L BYTE 	0002	DATA
INTPWR . . . . . . . . . . . . .	L NEAR 	0112	CODE
LOGPOWER . . . . . . . . . . . .	L NEAR 	00A8	CODE
MULCHK . . . . . . . . . . . . .	L NEAR 	00D4	CODE
MULPOWER . . . . . . . . . . . .	L NEAR 	00D1	CODE
ONE. . . . . . . . . . . . . . .	L NEAR 	005A	CODE
POSTDIV. . . . . . . . . . . . .	L NEAR 	0102	CODE
POWERCNT . . . . . . . . . . . .	L WORD 	0000	DATA
RET. . . . . . . . . . . . . . .	L NEAR 	0066	CODE
SETSIGN. . . . . . . . . . . . .	L NEAR 	0105	CODE
SMALLPOWER . . . . . . . . . . .	L NEAR 	0076	CODE
SQUARE . . . . . . . . . . . . .	L NEAR 	0121	CODE
XTON . . . . . . . . . . . . . .	L NEAR 	010F	CODE
ZERCHK . . . . . . . . . . . . .	L NEAR 	0067	CODE
ZEROPWR. . . . . . . . . . . . .	L NEAR 	0095	CODE
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ARG . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DIV0. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$EXP2. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FEXA. . . . . . . . . . . . . .	L NEAR 	000B	CODE	Global
$FEXC. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$FEXE. . . . . . . . . . . . . .	L NEAR 	0008	CODE	Global
$FEXG. . . . . . . . . . . . . .	L NEAR 	0005	CODE	Global
$FIX . . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$GTMP. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$LOG2. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SDIV. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SSUB. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TEMP. . . . . . . . . . . . . .	V WORD 	0000	DATA	External

Warning Severe
Errors	Errors 
0	0





