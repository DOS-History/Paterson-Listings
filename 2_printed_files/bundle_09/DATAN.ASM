DATAN - Double precision arc tangent                     Macro-86 %1(12)   0:59:12  13-Nov-81   Page 1-1


    1	 	 	 	 	        TITLE   DATAN - Double precision arc tangent
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $FAC:BYTE, $DAC:WORD, $ARG:WORD, $TEMP:WORD
    6	 	 	 	 	
    7	 0000	 	 	 	DATA    ENDS
    8	 	 	 	 	
    9	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
   10	 	 	 	 	
   11	 	 	 	 	        EXTRN   $DBLONE:WORD,$DHALFPI:WORD,$DSIXTHPI:WORD,$DSQRT3:WORD
   12	 	 	 	 	        EXTRN   $DTANTWELFTHPI:WORD
   13	 	 	 	 	
   14	 	 	 	 	;Coefficients for Hart's 4945. Relative error 16.82, range [0,TAN(PI/12)].
   15	 	 	 	 	;ATAN(x) = xP(x^2)
   16	 	 	 	 	; These constants have been checked with MuMath
   17	 	 	 	 	
   18	 0000  0008	 	 	ATANTAB DW      8                                       ;Degree
   19	 0002  18 E6 C0 E4 C7 D1	        DB      018H,0E6H,0C0H,0E4H,0C7H,0D1H,035H,07CH ;+0.0443895157187
   20	       35 7C	 	 	
   21	 000A  0B 01 08 08 9B C6	        DB      00BH,001H,008H,008H,09BH,0C6H,084H,07DH ;-0.06483193510303
   22	       84 7D	 	 	
   23	 0012  26 C5 6C 2E 02 46	        DB      026H,0C5H,06CH,02EH,002H,046H,01DH,07DH ;+0.0767936869066
   24	       1D 7D	 	 	
   25	 001A  98 6B 0A 9D B9 2B	        DB      098H,06BH,00AH,09DH,0B9H,02BH,0BAH,07DH ;-0.0909037114191074
   26	       BA 7D	 	 	
   27	 0022  01 2B 95 27 27 8E	        DB      001H,02BH,095H,027H,027H,08EH,063H,07DH ;+0.11111097898051048
   28	       63 7D	 	 	
   29	 002A  6A 9C DD 72 24 49	        DB      06AH,09CH,0DDH,072H,024H,049H,092H,07EH ;-0.142857141028255452
   30	       92 7E	 	 	
   31	 0032  A8 EB 94 CC CC CC	        DB      0A8H,0EBH,094H,0CCH,0CCH,0CCH,04CH,07EH ;+0.1999999999872944792
   32	       4C 7E	 	 	
   33	 003A  83 97 AA AA AA AA	        DB      083H,097H,0AAH,0AAH,0AAH,0AAH,0AAH,07FH ;-0.333333333333299308717
   34	       AA 7F	 	 	
   35	 0042  FF FF FF FF FF FF	        DB      0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,07FH,080H ;+0.9999999999999999849899
   36	       7F 80	 	 	
   37	 	 	 	 	
   38	 004A	 	 	 	CONST   ENDS
   39	 	 	 	 	
   40	 	 	 	 	
   41	 	 	 	 	DC      GROUP   DATA,CONST
   42	 	 	 	 	
   43	 	 	 	 	
   44	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   45	 	 	 	 	
   46	 	 	 	 	        PUBLIC  $ATD
   47	 	 	 	 	
   48	 	 	 	 	        EXTRN   $SAVREG:NEAR, $DPOLYX:NEAR
   49	 	 	 	 	        EXTRN   $DDIV:NEAR, $DMUL:NEAR, $DADD:NEAR, $DSUB:NEAR, $DCMP:NEAR
   50	 	 	 	 	
   51	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   52	 	 	 	 	
   53	 	 	 	 	
   54	 	 	 	 	;$ATD - Arc tangent


DATAN - Double precision arc tangent                     Macro-86 %1(12)   0:59:12  13-Nov-81   Page 1-2



   55	 	 	 	 	;
   56	 	 	 	 	; Inputs:
   57	 	 	 	 	;       BX = Address of argument
   58	 	 	 	 	; Outputs:
   59	 	 	 	 	;       Result in FAC
   60	 	 	 	 	; Registers:
   61	 	 	 	 	;       Only F affected.
   62	 	 	 	 	
   63	 0000	 	 	 	$ATD:
   64	 0000  E8 0000 E	 	        CALL    $SAVREG
   65	 0003  8B F3	 	 	        MOV     SI,BX
   66	 0005  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   67	 0008  A5	 	 	        MOVSW                   ;Put in FAC
   68	 0009  A5	 	 	        MOVSW
   69	 000A  A5	 	 	        MOVSW
   70	 000B  AD	 	 	        LODSW
   71	 000C  AB	 	 	        STOSW
   72	 000D  0A E4	 	 	        OR      AH,AH           ;Is it zero?
   73	 000F  74 11	 	 	        JZ      DONE            ;If so, result is too
   74	 0011  A8 80	 	 	        TEST    AL,80H          ;Check sign
   75	 0013  79 0E	 	 	        JNS     POSATAN
   76	 0015  24 7F	 	 	        AND     AL,7FH
   77	 0017  A2 FFFF E	 	        MOV     [$FAC-1],AL     ;Make it positive
   78	 001A  E8 0023 R	 	        CALL    POSATAN         ;Take arctan of positive number
   79	 001D  80 36 FFFF E 80	 	        XOR     [$FAC-1],80H    ;Invert sign back
   80	 0022  C3	 	 	DONE:   RET
   81	 	 	 	 	
   82	 0023	 	 	 	POSATAN:
   83	 0023  80 FC 81	 	 	        CMP     AH,81H          ;Is it >= 1?
   84	 0026  72 15	 	 	        JB      LESSTHAN1
   85	 0028  BE 0000 E	 	        MOV     SI,OFFSET DC:$DBLONE
   86	 002B  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   87	 002E  E8 0000 E	 	        CALL    $DDIV           ;It's reciprocal is < 1
   88	 0031  E8 003D R	 	        CALL    LESSTHAN1       ;Compute arc-cotan on number < 1
   89	 0034  BE 0000 E	 	        MOV     SI,OFFSET DC:$DHALFPI
   90	 0037  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   91	 003A  E9 0000 E	 	        JMP     $DSUB           ;Correct by subtracting from PI/2
   92	 	 	 	 	
   93	 003D	 	 	 	LESSTHAN1:
   94	 003D  BE 0000 E	 	        MOV     SI,OFFSET DC:$DTANTWELFTHPI
   95	 0040  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   96	 0043  E8 0000 E	 	        CALL    $DCMP           ;Compare argument to PI/12
   97	 0046  73 44	 	 	        JAE     DOATAN          ;Range reduction complete if <= PI/12
   98	 0048  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   99	 004B  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
  100	 004E  A5	 	 	        MOVSW                   ;Save X in ARG
  101	 004F  A5	 	 	        MOVSW
  102	 0050  A5	 	 	        MOVSW
  103	 0051  A5	 	 	        MOVSW
  104	 0052  BE 0000 E	 	        MOV     SI,OFFSET DC:$DSQRT3  ;Point to TAN(PI/6) (PI/6 = 30 degrees)
  105	 0055  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  106	 0058  E8 0000 E	 	        CALL    $DADD           ;FAC = X + TAN(PI/6)
  107	 005B  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  108	 005E  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP


DATAN - Double precision arc tangent                     Macro-86 %1(12)   0:59:12  13-Nov-81   Page 1-3



  109	 0061  A5	 	 	        MOVSW                   ;Save it in TEMP
  110	 0062  A5	 	 	        MOVSW
  111	 0063  A5	 	 	        MOVSW
  112	 0064  A5	 	 	        MOVSW
  113	 0065  BE 0000 E	 	        MOV     SI,OFFSET DC:$DSQRT3
  114	 0068  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
  115	 006B  E8 0000 E	 	        CALL    $DMUL           ;FAC = X * TAN(PI/6)
  116	 006E  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  117	 0071  BF 0000 E	 	        MOV     DI,OFFSET DC:$DBLONE
  118	 0074  E8 0000 E	 	        CALL    $DSUB           ;FAC = X * TAN(PI/6) - 1
  119	 0077  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  120	 007A  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
  121	 007D  E8 0000 E	 	        CALL    $DDIV           ;FAC = (X*TAN(PI/6) - 1)/(X + TAN(PI/6)
  122	 0080  E8 008C R	 	        CALL    DOATAN          ;Compute arctan on argument < PI/12
  123	 0083  BE 0000 E	 	        MOV     SI,OFFSET DC:$DSIXTHPI
  124	 0086  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  125	 0089  E9 0000 E	 	        JMP     $DADD           ;Correct for range reduction by adding PI/6
  126	 	 	 	 	
  127	 008C	 	 	 	DOATAN:
  128	 008C  BB 0000 R	 	        MOV     BX,OFFSET DC:ATANTAB
  129	 008F  E9 0000 E	 	        JMP     $DPOLYX
  130	 	 	 	 	
  131	 0092	 	 	 	CODE    ENDS
  132	 	 	 	 	        END
































DATAN - Double precision arc tangent                     Macro-86 %1(12)   0:59:12  13-Nov-81   Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0092	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'
  CONST. . . . . . . . . . . . . .	004A	WORD  	PUBLIC	'CONST'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ATANTAB. . . . . . . . . . . . .	L WORD 	0000	CONST
DOATAN . . . . . . . . . . . . .	L NEAR 	008C	CODE
DONE . . . . . . . . . . . . . .	L NEAR 	0022	CODE
LESSTHAN1. . . . . . . . . . . .	L NEAR 	003D	CODE
POSATAN. . . . . . . . . . . . .	L NEAR 	0023	CODE
$ARG . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ATD . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DADD. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DBLONE. . . . . . . . . . . . .	V WORD 	0000	CONST	External
$DCMP. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DDIV. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DHALFPI . . . . . . . . . . . .	V WORD 	0000	CONST	External
$DMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DPOLYX. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DSIXTHPI. . . . . . . . . . . .	V WORD 	0000	CONST	External
$DSQRT3. . . . . . . . . . . . .	V WORD 	0000	CONST	External
$DSUB. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DTANTWELFTHPI . . . . . . . . .	V WORD 	0000	CONST	External
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TEMP. . . . . . . . . . . . . .	V WORD 	0000	DATA	External

Warning Severe
Errors	Errors 
0	0

















