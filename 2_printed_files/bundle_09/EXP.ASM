EXP - Exponential function                               Macro-86 %1(12)   1:0:55  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   EXP - Exponential function
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $FAC:BYTE, $AC:WORD, $ARG:WORD
    6	 	 	 	 	
    7	 0000	 	 	 	DATA    ENDS
    8	 	 	 	 	
    9	 	 	 	 	
   10	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
   11	 	 	 	 	
   12	 	 	 	 	        EXTRN   $LOG2E:WORD
   13	 	 	 	 	
   14	 	 	 	 	;Constants for Hart's 1302, relative error 7.91
   15	 	 	 	 	; 2^x = 1 + xP(x) = Q(x)
   16	 	 	 	 	; These constants have been checked with MuMath
   17	 	 	 	 	
   18	 0000  0006	 	 	EXPTAB  DW      6                       ;Degree
   19	 0002  7C 88 59 74	 	        DB      07CH,088H,059H,074H     ; +0.00020745 57740 3
   20	 0006  E0 97 26 77	 	        DB      0E0H,097H,026H,077H     ; +0.0012710 05745 69
   21	 000A  C4 1D 1E 7A	 	        DB      0C4H,01DH,01EH,07AH     ; +0.0096506 50932 02
   22	 000E  5E 50 63 7C	 	        DB      05EH,050H,063H,07CH     ; +0.055496 56508 324
   23	 0012  1A FE 75 7E	 	        DB      01AH,0FEH,075H,07EH     ; +0.24022 71381 7633
   24	 0016  18 72 31 80	 	        DB      018H,072H,031H,080H     ; +0.69314 71721 3716
   25	 001A  00 00 00 81	 	        DB      000H,000H,000H,081H     ; +1.0
   26	 	 	 	 	
   27	 001E	 	 	 	CONST   ENDS
   28	 	 	 	 	
   29	 	 	 	 	
   30	 	 	 	 	DC      GROUP   DATA,CONST
   31	 	 	 	 	
   32	 	 	 	 	
   33	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   34	 	 	 	 	
   35	 	 	 	 	        PUBLIC  $EXP, $EXP2
   36	 	 	 	 	
   37	 	 	 	 	        EXTRN   $SPOLY:NEAR, $SAVREG:NEAR, $SMUL:NEAR, $SSUB:NEAR
   38	 	 	 	 	        EXTRN   $INT:FAR, $OVFL:NEAR, $PUT1:NEAR
   39	 	 	 	 	
   40	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   41	 	 	 	 	
   42	 	 	 	 	
   43	 	 	 	 	;***  $EXP - Exponential (base e) function
   44	 	 	 	 	;
   45	 	 	 	 	; Inputs:
   46	 	 	 	 	;       BX = Address of argument
   47	 	 	 	 	; Outputs:
   48	 	 	 	 	;       Result in FAC
   49	 	 	 	 	; Registers:
   50	 	 	 	 	;       Only F affected.
   51	 	 	 	 	
   52	 0000	 	 	 	$EXP:
   53	 0000  E8 0000 E	 	        CALL    $SAVREG
   54	 0003  8B F3	 	 	        MOV     SI,BX


EXP - Exponential function                               Macro-86 %1(12)   1:0:55  13-Nov-81    Page 1-2



   55	 0005  BF 0000 E	 	        MOV     DI,OFFSET DC:$LOG2E     ;Log base 2 of e
   56	 0008  E8 0000 E	 	        CALL    $SMUL
   57	 	 	 	 	
   58	 	 	 	 	;***  $EXP2 - Compute 2^(FAC)
   59	 	 	 	 	;
   60	 	 	 	 	; Inputs:
   61	 	 	 	 	;       Argument in FAC
   62	 	 	 	 	; Outputs:
   63	 	 	 	 	;       Result in FAC
   64	 	 	 	 	; Registers:
   65	 	 	 	 	;       All registers destroyed
   66	 	 	 	 	
   67	 000B	 	 	 	$EXP2:
   68	 000B  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   69	 000E  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
   70	 0011  A5	 	 	        MOVSW                   ;Move argument to ARG
   71	 0012  AD	 	 	        LODSW                   ;Get sign and exponent
   72	 0013  AB	 	 	        STOSW
   73	 0014  80 FC 88	 	 	        CMP     AH,88H          ;True exp. >= 8 means ABS(X) >= 128
   74	 0017  73 40	 	 	        JAE     OVERCHK         ;   which could cause overflow
   75	 0019  80 FC 68	 	 	        CMP     AH,80H-24       ;True exp. < -24 means result is just 1
   76	 001C  72 53	 	 	        JB      ONE             ;   since EXP(X)=1+X for X<<1
   77	 001E  BB 0000 E	 	        MOV     BX,OFFSET DC:$AC
   78	 0021  9A 0000 ---- E	 	        CALL    $INT            ;Perform FLOOR function
   79	 0026  FF 36 0002 E	 	        PUSH    [$AC+2]         ;Save so we can convert to 1-byte integer
   80	 002A  BE 0000 E	 	        MOV     SI,OFFSET DC:$ARG
   81	 002D  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   82	 0030  E8 0000 E	 	        CALL    $SSUB           ;FAC = X - INT(X)  --> FAC >= 0
   83	 0033  80 3E 0000 E 00	 	        CMP     [$FAC],0
   84	 0038  74 26	 	 	        JZ      NOPOLY
   85	 003A  BB 0000 R	 	        MOV     BX,OFFSET DC:EXPTAB
   86	 003D  E8 0000 E	 	        CALL    $SPOLY
   87	 0040	 	 	 	FIGEXP:
   88	 0040  58	 	 	        POP     AX              ;Recover INT(X)
   89	 0041  0A E4	 	 	        OR      AH,AH           ;Was it zero?
   90	 0043  74 2B	 	 	        JZ      RET             ;If so, we're done
   91	 0045  B1 88	 	 	        MOV     CL,88H
   92	 0047  2A CC	 	 	        SUB     CL,AH           ;Amount to shift mantissa right to make int.
   93	 0049  98	 	 	        CBW                     ;Remember sign
   94	 004A  0C 80	 	 	        OR      AL,80H          ;Set implied bit
   95	 004C  D2 E8	 	 	        SHR     AL,CL           ;AL now is INT(X)
   96	 004E  0A E4	 	 	        OR      AH,AH           ;Check sign
   97	 0050  75 13	 	 	        JNZ     SUBEXP
   98	 0052  00 06 0000 E	 	        ADD     [$FAC],AL       ;Add to exponent
   99	 0056  72 05	 	 	        JC      OVER
  100	 0058  C3	 	 	        RET
  101	 	 	 	 	
  102	 0059	 	 	 	OVERCHK:
  103	 0059  0A C0	 	 	        OR      AL,AL           ;Positive or negative argument?
  104	 005B  78 0E	 	 	        JS      ZERO
  105	 005D  E9 0000 E	 	OVER:   JMP     $OVFL
  106	 	 	 	 	
  107	 0060	 	 	 	NOPOLY:
  108	 0060  E8 0000 E	 	        CALL    $PUT1


EXP - Exponential function                               Macro-86 %1(12)   1:0:55  13-Nov-81    Page 1-3



  109	 0063  EB DB	 	 	        JMP     FIGEXP
  110	 	 	 	 	
  111	 0065	 	 	 	SUBEXP:
  112	 0065  28 06 0000 E	 	        SUB     [$FAC],AL
  113	 0069  77 05	 	 	        JA      RET
  114	 006B	 	 	 	ZERO:
  115	 006B  C6 06 0000 E 00	 	        MOV     [$FAC],0        ;Underflow - force to zero
  116	 0070  C3	 	 	RET:    RET
  117	 	 	 	 	
  118	 0071	 	 	 	ONE:
  119	 	 	 	 	;Argument is too small. Jam result to one.
  120	 0071  E9 0000 E	 	        JMP     $PUT1
  121	 	 	 	 	
  122	 0074	 	 	 	CODE    ENDS
  123	 	 	 	 	        END









































EXP - Exponential function                               Macro-86 %1(12)   1:0:55  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0074	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'
  CONST. . . . . . . . . . . . . .	001E	WORD  	PUBLIC	'CONST'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

EXPTAB . . . . . . . . . . . . .	L WORD 	0000	CONST
FIGEXP . . . . . . . . . . . . .	L NEAR 	0040	CODE
NOPOLY . . . . . . . . . . . . .	L NEAR 	0060	CODE
ONE. . . . . . . . . . . . . . .	L NEAR 	0071	CODE
OVER . . . . . . . . . . . . . .	L NEAR 	005D	CODE
OVERCHK. . . . . . . . . . . . .	L NEAR 	0059	CODE
RET. . . . . . . . . . . . . . .	L NEAR 	0070	CODE
SUBEXP . . . . . . . . . . . . .	L NEAR 	0065	CODE
ZERO . . . . . . . . . . . . . .	L NEAR 	006B	CODE
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ARG . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$EXP . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$EXP2. . . . . . . . . . . . . .	L NEAR 	000B	CODE	Global
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$INT . . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$LOG2E . . . . . . . . . . . . .	V WORD 	0000	CONST	External
$OVFL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$PUT1. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SPOLY . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SSUB. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0

















