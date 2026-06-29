DSIN - Double precision sine and cosine functions        Macro-86 %1(12)   0:59:42  13-Nov-81   Page 1-1



    1	 	 	 	 	        TITLE   DSIN - Double precision sine and cosine functions
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT BYTE PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $DAC:WORD, $ARG:WORD, $FAC:BYTE, $TEMP:WORD
    6	 	 	 	 	
    7	 0000  ??	 	 	SIGN    DB      ?
    8	 	 	 	 	
    9	 0001	 	 	 	DATA    ENDS
   10	 	 	 	 	
   11	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
   12	 	 	 	 	
   13	 	 	 	 	        EXTRN   $DBLHALF:WORD,$DBLONE:WORD,$DRECIP2PI:WORD,$DBL4TH:WORD
   14	 	 	 	 	
   15	 	 	 	 	;Coefficients for Hart's #3345, relative precision 18.59
   16	 	 	 	 	;       Hart's coefficients are intended to compute SIN(x*PI/2) = xP(x^2)
   17	 	 	 	 	;       with x in range [0,1] (or [-1,1]). Instead, we compute
   18	 	 	 	 	;       SIN(x*2*PI) = xP(x^2), x in [-1/4,1/4]. Thus our x is 1/4 the
   19	 	 	 	 	;       the size intended, so each coefficient is multiplied by the
   20	 	 	 	 	;       needed power of 4 to correct for this.
   21	 	 	 	 	; These constants have been checked with MuMath
   22	 	 	 	 	
   23	 0000  0008	 	 	SINTAB  DW      8                       ;8th degree
   24	 	 	 	 	;+0.00000000000587061098171     * 4^17
   25	 0002  F2 CC BF 4A C3 8D	        DB      0F2H,0CCH,0BFH,04AH,0C3H,08DH,04EH,07DH
   26	       4E 7D	 	 	
   27	 	 	 	 	
   28	 	 	 	 	;-0.00000000066843217206396     * 4^15
   29	 000A  6B A6 2C 86 BB BC	        DB      06BH,0A6H,02CH,086H,0BBH,0BCH,0B7H,080H
   30	       B7 80	 	 	
   31	 	 	 	 	
   32	 	 	 	 	;+0.00000005692134872719023     * 4^13
   33	 0012  E2 D9 AC 4E AF 79	        DB      0E2H,0D9H,0ACH,04EH,0AFH,079H,074H,082H
   34	       74 82	 	 	
   35	 	 	 	 	
   36	 	 	 	 	;-0.00000359884300720869272     * 4^11
   37	 001A  0E B8 8E EE A6 83	        DB      00EH,0B8H,08EH,0EEH,0A6H,083H,0F1H,084H
   38	       F1 84	 	 	
   39	 	 	 	 	
   40	 	 	 	 	;+0.0001604411847068220716      * 4^9
   41	 0022  5A 86 8C 42 1A 3C	        DB      05AH,086H,08CH,042H,01AH,03CH,028H,086H
   42	       28 86	 	 	
   43	 	 	 	 	
   44	 	 	 	 	;-0.00468175413530264260121     * 4^7
   45	 002A  14 AA 13 73 66 69	        DB      014H,0AAH,013H,073H,066H,069H,099H,087H
   46	       99 87	 	 	
   47	 	 	 	 	
   48	 	 	 	 	;+0.07969262624616543562977     * 4^5
   49	 0032  6F 53 AD 3B E3 35	        DB      06FH,053H,0ADH,03BH,0E3H,035H,023H,087H
   50	       23 87	 	 	
   51	 	 	 	 	
   52	 	 	 	 	;-0.64596409750624619108547     * 4^3
   53	 003A  91 F2 2D 31 E7 5D	        DB      091H,0F2H,02DH,031H,0E7H,05DH,0A5H,086H
   54	       A5 86	 	 	


DSIN - Double precision sine and cosine functions        Macro-86 %1(12)   0:59:42  13-Nov-81   Page 1-2



   55	 	 	 	 	
   56	 	 	 	 	;+1.5707963267948966188272      * 4^1
   57	 0042  C2 68 21 A2 DA 0F	        DB      0C2H,068H,021H,0A2H,0DAH,00FH,049H,083H
   58	       49 83	 	 	
   59	 	 	 	 	
   60	 004A	 	 	 	CONST   ENDS
   61	 	 	 	 	
   62	 	 	 	 	
   63	 	 	 	 	DC      GROUP   CONST,DATA
   64	 	 	 	 	
   65	 	 	 	 	
   66	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   67	 	 	 	 	
   68	 	 	 	 	        PUBLIC $SID, $COD, $TAD
   69	 	 	 	 	
   70	 	 	 	 	        EXTRN  $SAVREG:NEAR, $FID:FAR, $DPOLYX:NEAR
   71	 	 	 	 	        EXTRN  $DSUB:NEAR, $DDIV:NEAR, $DMUL:NEAR
   72	 	 	 	 	
   73	 	 	 	 	        ASSUME CS:CODE, DS:DC, ES:DC
   74	 	 	 	 	
   75	 	 	 	 	
   76	 	 	 	 	;***  $SID, $COD - Sine and Cosine trig functions
   77	 	 	 	 	;
   78	 	 	 	 	; Inputs:
   79	 	 	 	 	;       BX = Address of argument
   80	 	 	 	 	; Outputs:
   81	 	 	 	 	;       Result in FAC
   82	 	 	 	 	; Registers:
   83	 	 	 	 	;       No registers affected.
   84	 	 	 	 	
   85	 0000	 	 	 	$TAD:
   86	 0000  E8 0000 E	 	        CALL    $SAVREG
   87	 0003  FF 37	 	 	        PUSH    [BX]            ;Save value of argument
   88	 0005  FF 77 02	 	 	        PUSH    [BX+2]
   89	 0008  FF 77 04	 	 	        PUSH    [BX+4]
   90	 000B  FF 77 06	 	 	        PUSH    [BX+6]
   91	 000E  E8 0058 R	 	        CALL    SINF            ;Compute sin(x)
   92	 0011  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   93	 0014  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
   94	 0017  A5	 	 	        MOVSW
   95	 0018  A5	 	 	        MOVSW
   96	 0019  A5	 	 	        MOVSW
   97	 001A  A5	 	 	        MOVSW
   98	 001B  8F 06 0006 E	 	        POP     [$DAC+6]        ;Restore argument to FAC
   99	 001F  8F 06 0004 E	 	        POP     [$DAC+4]
  100	 0023  8F 06 0002 E	 	        POP     [$DAC+2]
  101	 0027  8F 06 0000 E	 	        POP     [$DAC]
  102	 002B  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  103	 002E  E8 003F R	 	        CALL    COSF            ;Compute cos(x)
  104	 0031  BE 0000 E	 	        MOV     SI,OFFSET DC:$TEMP
  105	 0034  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  106	 0037  E9 0000 E	 	        JMP     $DDIV           ;Tan = sin/cos
  107	 	 	 	 	
  108	 003A	 	 	 	$COD:   ;Double precision cosine


DSIN - Double precision sine and cosine functions        Macro-86 %1(12)   0:59:42  13-Nov-81   Page 1-3



  109	 003A  E8 0000 E	 	        CALL    $SAVREG
  110	 003D  8B F3	 	 	        MOV     SI,BX
  111	 003F	 	 	 	COSF:
  112	 003F  BF 0000 E	 	        MOV     DI,OFFSET DC:$DRECIP2PI
  113	 0042  E8 0000 E	 	        CALL    $DMUL
  114	 0045  80 26 FFFF E 7F	 	        AND     [$FAC-1],7FH    ;Take absolute value - COS(X) = COS(-X)
  115	 004A  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  116	 004D  BE 0000 E	 	        MOV     SI,OFFSET DC:$DBL4TH
  117	 0050  E8 0000 E	 	        CALL    $DSUB           ;Use COS(X)=SIN(PI/2-X)
  118	 0053  EB 0B	 	 	        JMP     SHORT SINCOS
  119	 	 	 	 	
  120	 0055	 	 	 	$SID:   ;Double precision sine
  121	 0055  E8 0000 E	 	        CALL    $SAVREG
  122	 0058	 	 	 	SINF:
  123	 0058  8B F3	 	 	        MOV     SI,BX
  124	 005A  BF 0000 E	 	        MOV     DI,OFFSET DC:$DRECIP2PI
  125	 005D  E8 0000 E	 	        CALL    $DMUL
  126	 0060	 	 	 	SINCOS:
  127	 0060  A0 FFFF E	 	        MOV     AL,[$FAC-1]     ;Get sign
  128	 0063  A2 0000 R	 	        MOV     [SIGN],AL
  129	 0066  24 7F	 	 	        AND     AL,7FH          ;Take absolute value
  130	 0068  A2 FFFF E	 	        MOV     [$FAC-1],AL
  131	 006B  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  132	 006E  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
  133	 0071  A5	 	 	        MOVSW                   ;Save X so far
  134	 0072  A5	 	 	        MOVSW
  135	 0073  A5	 	 	        MOVSW
  136	 0074  A5	 	 	        MOVSW
  137	 0075  BB 0000 E	 	        MOV     BX,OFFSET DC:$DAC
  138	 0078  9A 0000 ---- E	 	        CALL    $FID            ;FAC=INT(X), X >= 0
  139	 007D  BE 0000 E	 	        MOV     SI,OFFSET DC:$ARG
  140	 0080  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  141	 0083  E8 0000 E	 	        CALL    $DSUB           ;FAC= X - INT(X) (always positive or zero)
  142	 0086  80 3E 0000 E 7F	 	        CMP     [$FAC],7FH      ;Is X < 1/4? (In first quadrant?)
  143	 008B  72 16	 	 	        JB      FIGSIN          ;If so, go compute
  144	 008D  81 3E 0006 E 8040	        CMP     [$DAC+6],8040H  ;Is X > = 3/4? (In fourth quadrant?)
  145	 0093  BE 0000 E	 	        MOV     SI,OFFSET DC:$DBLHALF
  146	 0096  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC  ;Subtract from 1/2 if in II or III
  147	 0099  72 05	 	 	        JB      SUB
  148	 009B  8B F7	 	 	        MOV     SI,DI
  149	 009D  BF 0000 E	 	        MOV     DI,OFFSET DC:$DBLONE  ;Subtract 1 from it if in IV
  150	 00A0	 	 	 	SUB:
  151	 00A0  E8 0000 E	 	        CALL    $DSUB
  152	 00A3	 	 	 	FIGSIN:
  153	 00A3  BB 0000 R	 	        MOV     BX,OFFSET DC:SINTAB
  154	 00A6  E8 0000 E	 	        CALL    $DPOLYX
  155	 00A9  A0 0000 R	 	        MOV     AL,[SIGN]
  156	 00AC  24 80	 	 	        AND     AL,80H          ;Reduce to sign bit
  157	 00AE  30 06 FFFF E	 	        XOR     [$FAC-1],AL     ;Flip sign if input was negative
  158	 00B2  C3	 	 	        RET
  159	 	 	 	 	
  160	 00B3	 	 	 	CODE    ENDS
  161	 	 	 	 	        END



DSIN - Double precision sine and cosine functions        Macro-86 %1(12)   0:59:42  13-Nov-81   Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	00B3	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  CONST. . . . . . . . . . . . . .	004A	WORD  	PUBLIC	'CONST'
  DATA . . . . . . . . . . . . . .	0001	BYTE  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

COSF . . . . . . . . . . . . . .	L NEAR 	003F	CODE
FIGSIN . . . . . . . . . . . . .	L NEAR 	00A3	CODE
SIGN . . . . . . . . . . . . . .	L BYTE 	0000	DATA
SINCOS . . . . . . . . . . . . .	L NEAR 	0060	CODE
SINF . . . . . . . . . . . . . .	L NEAR 	0058	CODE
SINTAB . . . . . . . . . . . . .	L WORD 	0000	CONST
SUB. . . . . . . . . . . . . . .	L NEAR 	00A0	CODE
$ARG . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$COD . . . . . . . . . . . . . .	L NEAR 	003A	CODE	Global
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DBL4TH. . . . . . . . . . . . .	V WORD 	0000	CONST	External
$DBLHALF . . . . . . . . . . . .	V WORD 	0000	CONST	External
$DBLONE. . . . . . . . . . . . .	V WORD 	0000	CONST	External
$DDIV. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DPOLYX. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DRECIP2PI . . . . . . . . . . .	V WORD 	0000	CONST	External
$DSUB. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FID . . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SID . . . . . . . . . . . . . .	L NEAR 	0055	CODE	Global
$TAD . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$TEMP. . . . . . . . . . . . . .	V WORD 	0000	DATA	External

Warning Severe
Errors	Errors 
0	0















