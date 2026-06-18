DLOG - Double precision natural logarithm                Macro-86 %1(12)   0:59:27  13-Nov-81   Page 1-1



    1	 	 	 	 	        TITLE   DLOG - Double precision natural logarithm
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $DAC:WORD, $FAC:BYTE, $ARG:WORD
    6	 	 	 	 	
    7	 0000	 	 	 	DATA    ENDS
    8	 	 	 	 	
    9	 	 	 	 	
   10	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
   11	 	 	 	 	
   12	 	 	 	 	        EXTRN   $DBLONE:WORD, $DHALFLN2:WORD, $DHALFSQR2:WORD
   13	 	 	 	 	
   14	 	 	 	 	;Coefficient tables for Hart's 2665. Absolute error 16.52,
   15	 	 	 	 	;range [1/SQRT(2),SQRT(2)]. LOG(x) = zP(z^2), z=(x-1)/(x+1)
   16	 	 	 	 	; These constants have been checked with MuMath
   17	 	 	 	 	
   18	 0000  0006	 	 	LOGTAB  DW      6                                       ;Degree 6 polynomial
   19	 0002  F8 F9 76 DE B8 8C	        DB      0F8H,0F9H,076H,0DEH,0B8H,08CH,02DH,07EH ;+0.16948212488
   20	       2D 7E	 	 	
   21	 000A  4D 9E CE BF D9 75	        DB      04DH,09EH,0CEH,0BFH,0D9H,075H,039H,07EH ;+0.1811136267967
   22	       39 7E	 	 	
   23	 0012  35 BB 41 60 6B 92	        DB      035H,0BBH,041H,060H,06BH,092H,063H,07EH ;+0.22223823332791
   24	       63 7E	 	 	
   25	 001A  32 66 C6 0E 1E 49	        DB      032H,066H,0C6H,00EH,01EH,049H,012H,07FH ;+0.2857140915904889
   26	       12 7F	 	 	
   27	 0022  FB EB 28 D7 CC CC	        DB      0FBH,0EBH,028H,0D7H,0CCH,0CCH,04CH,07FH ;+0.400000001206045365
   28	       4C 7F	 	 	
   29	 002A  A3 09 A7 AA AA AA	        DB      0A3H,009H,0A7H,0AAH,0AAH,0AAH,02AH,080H ;+0.6666666666633660894
   30	       2A 80	 	 	
   31	 0032  2F 00 00 00 00 00	        DB      02FH,000H,000H,000H,000H,000H,000H,082H ;+2.00000000000000261007
   32	       00 82	 	 	
   33	 	 	 	 	
   34	 003A	 	 	 	CONST   ENDS
   35	 	 	 	 	
   36	 	 	 	 	
   37	 	 	 	 	DC      GROUP DATA,CONST
   38	 	 	 	 	
   39	 	 	 	 	
   40	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   41	 	 	 	 	
   42	 	 	 	 	        PUBLIC $LOD,$DLOG
   43	 	 	 	 	
   44	 	 	 	 	        EXTRN  $DMUL:NEAR, $DPOLYX:NEAR, $DADD:NEAR, $DSUB:NEAR, $DDIV:NEAR
   45	 	 	 	 	        EXTRN  $SAVREG:NEAR, $ERC_FC:NEAR, $CIDA:FAR
   46	 	 	 	 	
   47	 	 	 	 	        ASSUME CS:CODE, DS:DC, ES:DC
   48	 	 	 	 	
   49	 	 	 	 	
   50	 	 	 	 	;***  $LOG - LOG (base e) function
   51	 	 	 	 	;
   52	 	 	 	 	; Inputs:
   53	 	 	 	 	;       BX = Address of operand
   54	 	 	 	 	; Outputs:


DLOG - Double precision natural logarithm                Macro-86 %1(12)   0:59:27  13-Nov-81   Page 1-2



   55	 	 	 	 	;       Result in FAC
   56	 	 	 	 	; Registers:
   57	 	 	 	 	;       Only F affected.
   58	 	 	 	 	
   59	 0000	 	 	 	$LOD:
   60	 0000  E8 0000 E	 	        CALL    $SAVREG
   61	 0003	 	 	 	$DLOG:
   62	 0003  8B F3	 	 	        MOV     SI,BX
   63	 0005  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   64	 0008  A5	 	 	        MOVSW                   ;Put operand in FAC
   65	 0009  A5	 	 	        MOVSW
   66	 000A  A5	 	 	        MOVSW
   67	 000B  AD	 	 	        LODSW
   68	 000C  AB	 	 	        STOSW
   69	 000D  0A E4	 	 	        OR      AH,AH           ;Taking log of zero?
   70	 000F  74 62	 	 	        JZ      ARGERR
   71	 0011  0A C0	 	 	        OR      AL,AL           ;Log of negative number?
   72	 0013  78 5E	 	 	        JS      ARGERR
   73	 0015  C6 06 0000 E 81	 	        MOV     [$FAC],81H      ;Assign true exponent of 1
   74	 001A  8A C4	 	 	        MOV     AL,AH           ;Convert exponent to 16-bit integer
   75	 001C  2C 80	 	 	        SUB     AL,80H          ;   Remove bias
   76	 001E  98	 	 	        CBW
   77	 001F  50	 	 	        PUSH    AX
   78	 0020  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   79	 0023  BF 0000 E	 	        MOV     DI,OFFSET DC:$DHALFSQR2
   80	 0026  E8 0000 E	 	        CALL    $DMUL           ;X now in [1/SQRT(2),SQRT2)
   81	 0029  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   82	 002C  BF 0000 E	 	        MOV     DI,OFFSET DC:$DBLONE
   83	 002F  E8 0000 E	 	        CALL    $DADD
   84	 0032  BE 0000 E	 	        MOV     SI,OFFSET DC:$DBLONE
   85	 0035  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   86	 0038  E8 0000 E	 	        CALL    $DDIV           ;DAC = 1 / (Y+1)
   87	 003B  FE 06 0000 E	 	        INC     [$FAC]          ;DAC = 2 / (Y+1)
   88	 003F  BE 0000 E	 	        MOV     SI,OFFSET DC:$DBLONE
   89	 0042  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   90	 0045  E8 0000 E	 	        CALL    $DSUB           ;DAC = 1-[2/(Y+1)] = (Y-1)/(Y+1)
   91	 0048  BB 0000 R	 	        MOV     BX,OFFSET DC:LOGTAB
   92	 004B  E8 0000 E	 	        CALL    $DPOLYX
   93	 004E  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   94	 0051  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
   95	 0054  A5	 	 	        MOVSW                   ;Copy partial result to ARG
   96	 0055  A5	 	 	        MOVSW
   97	 0056  A5	 	 	        MOVSW
   98	 0057  A5	 	 	        MOVSW
   99	 0058  5B	 	 	        POP     BX              ;Recover exponent (as integer)
  100	 0059  D1 E3	 	 	        SHL     BX,1            ;Count by halves
  101	 005B  4B	 	 	        DEC     BX              ;Take out 1/2 because of SQRT(2) factor
  102	 005C  9A 0000 ---- E	 	        CALL    $CIDA           ;Convert it to D.P.
  103	 0061  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  104	 0064  BF 0000 E	 	        MOV     DI,OFFSET DC:$DHALFLN2
  105	 0067  E8 0000 E	 	        CALL    $DMUL           ;Convert our LOG2 to LOGe
  106	 006A  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  107	 006D  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
  108	 0070  E9 0000 E	 	        JMP     $DADD


DLOG - Double precision natural logarithm                Macro-86 %1(12)   0:59:27  13-Nov-81   Page 1-3



  109	 	 	 	 	
  110	 0073  E9 0000 E	 	ARGERR: JMP     $ERC_FC
  111	 	 	 	 	
  112	 0076	 	 	 	CODE    ENDS
  113	 	 	 	 	        END



















































DLOG - Double precision natural logarithm                Macro-86 %1(12)   0:59:27  13-Nov-81   Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0076	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'
  CONST. . . . . . . . . . . . . .	003A	WORD  	PUBLIC	'CONST'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ARGERR . . . . . . . . . . . . .	L NEAR 	0073	CODE
LOGTAB . . . . . . . . . . . . .	L WORD 	0000	CONST
$ARG . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$CIDA. . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DADD. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DBLONE. . . . . . . . . . . . .	V WORD 	0000	CONST	External
$DDIV. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DHALFLN2. . . . . . . . . . . .	V WORD 	0000	CONST	External
$DHALFSQR2 . . . . . . . . . . .	V WORD 	0000	CONST	External
$DLOG. . . . . . . . . . . . . .	L NEAR 	0003	CODE	Global
$DMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DPOLYX. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DSUB. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$LOD . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0





















