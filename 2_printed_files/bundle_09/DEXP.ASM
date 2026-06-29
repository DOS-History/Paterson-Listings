DEXP - Double precision exponential function             Macro-86 %1(12)   0:59:20  13-Nov-81   Page 1-1



    1	 	 	 	 	        TITLE   DEXP - Double precision exponential function
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $FAC:BYTE, $DAC:WORD, $ARG:WORD, $TEMP:WORD
    6	 	 	 	 	
    7	 0000	 	 	 	DATA    ENDS
    8	 	 	 	 	
    9	 	 	 	 	
   10	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
   11	 	 	 	 	
   12	 	 	 	 	        EXTRN   $DBLONE:WORD, $DLOG2E:WORD
   13	 	 	 	 	
   14	 	 	 	 	;Coefficients for Hart's 1323, relative error 17.26, range [0,1/2].
   15	 	 	 	 	; 2^x = 1 + 2xP(x^2) / [Q(x^2) - xP(x^2)]
   16	 	 	 	 	; These constants have been checked with MuMath
   17	 	 	 	 	
   18	 0000  0002	 	 	PTAB    DW      2                                       ;Degree
   19	 0002  04 A3 E6 52 4D 30	        DB      004H,0A3H,0E6H,052H,04DH,030H,03DH,07BH ;+0.02309432127295385660455
   20	       3D 7B	 	 	
   21	 000A  B2 BB AB E4 14 9D	        DB      0B2H,0BBH,0ABH,0E4H,014H,09DH,021H,085H ;+20.20170000695312603946477
   22	       21 85	 	 	
   23	 0012  91 9E 3B 4E A7 3B	        DB      091H,09EH,03BH,04EH,0A7H,03BH,03DH,08BH ;+1513.86417304653561981057161
   24	       3D 8B	 	 	
   25	 	 	 	 	
   26	 001A  0002	 	 	QTAB    DW      2                                       ;Degree
   27	 001C  00 00 00 00 00 00	        DB      000H,000H,000H,000H,000H,000H,000H,081H ;+1
   28	       00 81	 	 	
   29	 0024  CB FE 9F 9D A0 2D	        DB      0CBH,0FEH,09FH,09DH,0A0H,02DH,069H,088H ;+233.17823205143103579679705
   30	       69 88	 	 	
   31	 002C  85 FD A6 98 B5 80	        DB      085H,0FDH,0A6H,098H,0B5H,080H,008H,08DH ;+4368.08867006741698646914202
   32	       08 8D	 	 	
   33	 	 	 	 	
   34	 0034	 	 	 	CONST   ENDS
   35	 	 	 	 	
   36	 	 	 	 	
   37	 	 	 	 	DC      GROUP   DATA,CONST
   38	 	 	 	 	
   39	 	 	 	 	
   40	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   41	 	 	 	 	
   42	 	 	 	 	        PUBLIC  $EXD,$DEXP
   43	 	 	 	 	
   44	 	 	 	 	        EXTRN   $DPOLY2:NEAR, $DPOLYX:NEAR, $SAVREG:NEAR
   45	 	 	 	 	        EXTRN   $DDIV:NEAR, $DADD:NEAR, $DMUL:NEAR, $DSUB:NEAR
   46	 	 	 	 	        EXTRN   $IND:FAR, $OVFL:NEAR, $PUT1D:NEAR
   47	 	 	 	 	
   48	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   49	 	 	 	 	
   50	 	 	 	 	
   51	 0000	 	 	 	ONE:
   52	 	 	 	 	;Argument is too small. Jam result to one.
   53	 0000  E9 0000 E	 	        JMP     $PUT1D
   54	 	 	 	 	


DEXP - Double precision exponential function             Macro-86 %1(12)   0:59:20  13-Nov-81   Page 1-2



   55	 0003	 	 	 	NOPOLY:
   56	 0003  E8 0000 E	 	        CALL    $PUT1D
   57	 0006  E9 00A8 R	 	        JMP     FIGEXP
   58	 	 	 	 	
   59	 0009  E9 00C1 R	 	OVERCHKJ:JMP    OVERCHK
   60	 	 	 	 	
   61	 	 	 	 	;***  $EXD - Exponential (base e) function
   62	 	 	 	 	;
   63	 	 	 	 	; Inputs:
   64	 	 	 	 	;       BX = Address of argument
   65	 	 	 	 	; Outputs:
   66	 	 	 	 	;       Result in FAC
   67	 	 	 	 	; Registers:
   68	 	 	 	 	;       Only F affected.
   69	 	 	 	 	
   70	 000C	 	 	 	$EXD:
   71	 000C  E8 0000 E	 	        CALL    $SAVREG
   72	 000F	 	 	 	$DEXP:
   73	 000F  8B F3	 	 	        MOV     SI,BX
   74	 0011  BF 0000 E	 	        MOV     DI,OFFSET DC:$DLOG2E    ;Log base 2 of e
   75	 0014  E8 0000 E	 	        CALL    $DMUL
   76	 0017  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   77	 001A  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
   78	 001D  A5	 	 	        MOVSW                   ;Move argument to ARG
   79	 001E  A5	 	 	        MOVSW
   80	 001F  A5	 	 	        MOVSW
   81	 0020  AD	 	 	        LODSW                   ;Get sign and exponent
   82	 0021  AB	 	 	        STOSW
   83	 0022  80 FC 88	 	 	        CMP     AH,88H          ;True exp. >= 8 means ABS(X) >= 128
   84	 0025  73 E2	 	 	        JAE     OVERCHKJ        ;   which could cause overflow
   85	 0027  80 FC 48	 	 	        CMP     AH,80H-56       ;True exp. < -56 means result is just 1
   86	 002A  72 D4	 	 	        JB      ONE             ;   since EXP(X)=1+X for X<<1
   87	 002C  BB 0000 E	 	        MOV     BX,OFFSET DC:$DAC
   88	 002F  9A 0000 ---- E	 	        CALL    $IND            ;Perform FLOOR function
   89	 0034  FF 36 0006 E	 	        PUSH    [$DAC+6]        ;Save so we can convert to 1-byte integer
   90	 0038  BE 0000 E	 	        MOV     SI,OFFSET DC:$ARG
   91	 003B  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   92	 003E  E8 0000 E	 	        CALL    $DSUB           ;FAC = X - INT(X)  --> FAC>=0
   93	 0041  A0 0000 E	 	        MOV     AL,[$FAC]
   94	 0044  2C 01	 	 	        SUB     AL,1            ;FAC = FAC/2, carry set if underflow
   95	 0046  76 BB	 	 	        JBE     NOPOLY
   96	 0048  A2 0000 E	 	        MOV     [$FAC],AL
   97	 004B  FF 36 0000 E	 	        PUSH    [$DAC]          ;Save reduced X (range [0,1/2])
   98	 004F  FF 36 0002 E	 	        PUSH    [$DAC+2]
   99	 0053  FF 36 0004 E	 	        PUSH    [$DAC+4]
  100	 0057  FF 36 0006 E	 	        PUSH    [$DAC+6]
  101	 005B  BB 0000 R	 	        MOV     BX,OFFSET DC:PTAB
  102	 005E  E8 0000 E	 	        CALL    $DPOLYX         ;Compute xP(x^2)
  103	 0061  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  104	 0064  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
  105	 0067  A5	 	 	        MOVSW
  106	 0068  A5	 	 	        MOVSW
  107	 0069  A5	 	 	        MOVSW
  108	 006A  A5	 	 	        MOVSW


DEXP - Double precision exponential function             Macro-86 %1(12)   0:59:20  13-Nov-81   Page 1-3



  109	 006B  8F 06 0006 E	 	        POP     [$DAC+6]
  110	 006F  8F 06 0004 E	 	        POP     [$DAC+4]
  111	 0073  8F 06 0002 E	 	        POP     [$DAC+2]
  112	 0077  8F 06 0000 E	 	        POP     [$DAC]
  113	 007B  BB 001A R	 	        MOV     BX,OFFSET DC:QTAB
  114	 007E  E8 0000 E	 	        CALL    $DPOLY2         ;Compute Q(x^2)
  115	 0081  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  116	 0084  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
  117	 0087  E8 0000 E	 	        CALL    $DSUB           ;DAC = Q(x^2) - xP(x^2)
  118	 008A  BE 0000 E	 	        MOV     SI,OFFSET DC:$TEMP
  119	 008D  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  120	 0090  E8 0000 E	 	        CALL    $DDIV           ;DAC = xP(x^2) / [Q(x^2) - xP(x^2)]
  121	 0093  FE 06 0000 E	 	        INC     [$FAC]          ;DAC = DAC*2 - overflow not possible
  122	 0097  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  123	 009A  BF 0000 E	 	        MOV     DI,OFFSET DC:$DBLONE
  124	 009D  E8 0000 E	 	        CALL    $DADD           ;DAC = DAC + 1
  125	 00A0  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  126	 00A3  8B FE	 	 	        MOV     DI,SI
  127	 00A5  E8 0000 E	 	        CALL    $DMUL           ;Square to account for divide by two above
  128	 00A8	 	 	 	FIGEXP:
  129	 00A8  58	 	 	        POP     AX              ;Recover INT(X)
  130	 00A9  0A E4	 	 	        OR      AH,AH           ;Was it zero?
  131	 00AB  74 26	 	 	        JZ      RET             ;If so, we're done
  132	 00AD  B1 88	 	 	        MOV     CL,88H
  133	 00AF  2A CC	 	 	        SUB     CL,AH           ;Amount to shift mantissa right to make int.
  134	 00B1  98	 	 	        CBW                     ;Remember sign
  135	 00B2  0C 80	 	 	        OR      AL,80H          ;Set implied bit
  136	 00B4  D2 E8	 	 	        SHR     AL,CL           ;AL now is INT(X)
  137	 00B6  0A E4	 	 	        OR      AH,AH           ;Check sign
  138	 00B8  75 0E	 	 	        JNZ     SUBEXP
  139	 00BA  00 06 0000 E	 	        ADD     [$FAC],AL       ;Add to exponent
  140	 00BE  72 05	 	 	        JC      OVER
  141	 00C0  C3	 	 	        RET
  142	 	 	 	 	
  143	 00C1	 	 	 	OVERCHK:
  144	 00C1  0A C0	 	 	        OR      AL,AL           ;Positive or negative argument?
  145	 00C3  78 09	 	 	        JS      ZERO
  146	 00C5  E9 0000 E	 	OVER:   JMP     $OVFL
  147	 	 	 	 	
  148	 00C8	 	 	 	SUBEXP:
  149	 00C8  28 06 0000 E	 	        SUB     [$FAC],AL
  150	 00CC  77 05	 	 	        JA      RET
  151	 00CE	 	 	 	ZERO:
  152	 00CE  C6 06 0000 E 00	 	        MOV     [$FAC],0        ;Underflow - force to zero
  153	 00D3  C3	 	 	RET:    RET
  154	 	 	 	 	
  155	 00D4	 	 	 	CODE    ENDS
  156	 	 	 	 	        END








DEXP - Double precision exponential function             Macro-86 %1(12)   0:59:20  13-Nov-81   Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	00D4	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'
  CONST. . . . . . . . . . . . . .	0034	WORD  	PUBLIC	'CONST'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

FIGEXP . . . . . . . . . . . . .	L NEAR 	00A8	CODE
NOPOLY . . . . . . . . . . . . .	L NEAR 	0003	CODE
ONE. . . . . . . . . . . . . . .	L NEAR 	0000	CODE
OVER . . . . . . . . . . . . . .	L NEAR 	00C5	CODE
OVERCHK. . . . . . . . . . . . .	L NEAR 	00C1	CODE
OVERCHKJ . . . . . . . . . . . .	L NEAR 	0009	CODE
PTAB . . . . . . . . . . . . . .	L WORD 	0000	CONST
QTAB . . . . . . . . . . . . . .	L WORD 	001A	CONST
RET. . . . . . . . . . . . . . .	L NEAR 	00D3	CODE
SUBEXP . . . . . . . . . . . . .	L NEAR 	00C8	CODE
ZERO . . . . . . . . . . . . . .	L NEAR 	00CE	CODE
$ARG . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DADD. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DBLONE. . . . . . . . . . . . .	V WORD 	0000	CONST	External
$DDIV. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DEXP. . . . . . . . . . . . . .	L NEAR 	000F	CODE	Global
$DLOG2E. . . . . . . . . . . . .	V WORD 	0000	CONST	External
$DMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DPOLY2. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DPOLYX. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DSUB. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$EXD . . . . . . . . . . . . . .	L NEAR 	000C	CODE	Global
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$IND . . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$OVFL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$PUT1D . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TEMP. . . . . . . . . . . . . .	V WORD 	0000	DATA	External

Warning Severe
Errors	Errors 
0	0










