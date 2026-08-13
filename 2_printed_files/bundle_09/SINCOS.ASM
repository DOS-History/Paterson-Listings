SINCOS - Sine and cosine functions                       Macro-86 %1(12)   1:8:6  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   SINCOS - Sine and cosine functions
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT BYTE PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $AC:WORD, $ARG:WORD, $FAC:BYTE, $TEMP:WORD
    6	 	 	 	 	
    7	 0000  ??	 	 	SIGN    DB      ?
    8	 	 	 	 	
    9	 0001	 	 	 	DATA    ENDS
   10	 	 	 	 	
   11	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
   12	 	 	 	 	
   13	 	 	 	 	        EXTRN   $ONEHALF:WORD,$ONE:WORD,$RECIP2PI:WORD,$HALFPI:WORD
   14	 	 	 	 	        EXTRN   $ONE4TH:WORD
   15	 	 	 	 	
   16	 	 	 	 	;Coefficients for Hart's #3341, relative precision 8.27
   17	 	 	 	 	;       Hart's coefficients are intended to compute SIN(x*PI/2) = xP(x^2)
   18	 	 	 	 	;       with x in range [0,1] (or [-1,1]). Instead, we compute
   19	 	 	 	 	;       SIN(x*2*PI) = xP(x^2), x, in [-1/4,1/4]. Thus our x is 1/4 the
   20	 	 	 	 	;       the size intended, so each coefficient is multiplied by the
   21	 	 	 	 	;       needed power of 4 to correct for this.
   22	 	 	 	 	; These constants have been checked with MuMath
   23	 	 	 	 	
   24	 0000  0004	 	 	SSINTAB DW      4                       ;4th degree
   25	 0002  FB D7 1E 86	 	        DB      0FBH,0D7H,01EH,086H     ; +0.00015148 5129      * 4^9
   26	 0006  65 26 99 87	 	        DB      065H,026H,099H,087H     ; -0.0046737 6661       * 4^7
   27	 000A  58 34 23 87	 	        DB      058H,034H,023H,087H     ; +0.079689 67894 6     * 4^5
   28	 000E  E1 5D A5 86	 	        DB      0E1H,05DH,0A5H,086H     ; -0.64596 37105 99     * 4^3
   29	 0012  DB 0F 49 83	 	        DB      0DBH,00FH,049H,083H     ; +1.5707 96318 44      * 4^1
   30	 	 	 	 	
   31	 0016	 	 	 	CONST   ENDS
   32	 	 	 	 	
   33	 	 	 	 	
   34	 	 	 	 	DC      GROUP   CONST,DATA
   35	 	 	 	 	
   36	 	 	 	 	
   37	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   38	 	 	 	 	
   39	 	 	 	 	        PUBLIC  $SIN, $COS, $TAN
   40	 	 	 	 	
   41	 	 	 	 	        EXTRN   $SAVREG:NEAR, $FIX:FAR, $SPOLYX:NEAR
   42	 	 	 	 	        EXTRN   $SSUB:NEAR, $SDIV:NEAR, $SMUL:NEAR
   43	 	 	 	 	
   44	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   45	 	 	 	 	
   46	 	 	 	 	
   47	 	 	 	 	;***  $SIN, $COS - Sine and Cosine trig functions
   48	 	 	 	 	;
   49	 	 	 	 	; Inputs:
   50	 	 	 	 	;       BX = Address of argument
   51	 	 	 	 	; Outputs:
   52	 	 	 	 	;       Result in FAC
   53	 	 	 	 	; Registers:
   54	 	 	 	 	;       No registers affected.


SINCOS - Sine and cosine functions                       Macro-86 %1(12)   1:8:6  13-Nov-81    Page 1-2



   55	 	 	 	 	
   56	 0000	 	 	 	$TAN:
   57	 0000  E8 0000 E	 	        CALL    $SAVREG
   58	 0003  FF 37	 	 	        PUSH    [BX]            ;Save value of argument
   59	 0005  FF 77 02	 	 	        PUSH    [BX+2]
   60	 0008  E8 0048 R	 	        CALL    SINF            ;Compute sin(x)
   61	 000B  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   62	 000E  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
   63	 0011  A5	 	 	        MOVSW
   64	 0012  A5	 	 	        MOVSW
   65	 0013  8F 06 0002 E	 	        POP     [$AC+2]         ;Restore argument to FAC
   66	 0017  8F 06 0000 E	 	        POP     [$AC]
   67	 001B  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   68	 001E  E8 002F R	 	        CALL    COSF            ;Compute cos(x)
   69	 0021  BE 0000 E	 	        MOV     SI,OFFSET DC:$TEMP
   70	 0024  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   71	 0027  E9 0000 E	 	        JMP     $SDIV           ;Tan = sin/cos
   72	 	 	 	 	
   73	 002A	 	 	 	$COS:   ;Single precision cosine
   74	 002A  E8 0000 E	 	        CALL    $SAVREG
   75	 002D  8B F3	 	 	        MOV     SI,BX
   76	 002F	 	 	 	COSF:
   77	 002F  BF 0000 E	 	        MOV     DI,OFFSET DC:$RECIP2PI
   78	 0032  E8 0000 E	 	        CALL    $SMUL
   79	 0035  80 26 FFFF E 7F	 	        AND     [$FAC-1],7FH    ;Take absolute value - COS(X) = COS(-X)
   80	 003A  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   81	 003D  BE 0000 E	 	        MOV     SI,OFFSET DC:$ONE4TH
   82	 0040  E8 0000 E	 	        CALL    $SSUB           ;Use COS(X)=SIN(PI/2-X)
   83	 0043  EB 0B	 	 	        JMP     SHORT SINCOS
   84	 	 	 	 	
   85	 0045	 	 	 	$SIN:   ;Single precision sine
   86	 0045  E8 0000 E	 	        CALL    $SAVREG
   87	 0048	 	 	 	SINF:
   88	 0048  8B F3	 	 	        MOV     SI,BX
   89	 004A  BF 0000 E	 	        MOV     DI,OFFSET DC:$RECIP2PI
   90	 004D  E8 0000 E	 	        CALL    $SMUL
   91	 0050	 	 	 	SINCOS:
   92	 0050  A0 FFFF E	 	        MOV     AL,[$FAC-1]     ;Get sign
   93	 0053  A2 0000 R	 	        MOV     [SIGN],AL
   94	 0056  24 7F	 	 	        AND     AL,7FH          ;Take absolute value
   95	 0058  A2 FFFF E	 	        MOV     [$FAC-1],AL
   96	 005B  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   97	 005E  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
   98	 0061  A5	 	 	        MOVSW                   ;Save X so far
   99	 0062  A5	 	 	        MOVSW
  100	 0063  BB 0000 E	 	        MOV     BX,OFFSET DC:$AC
  101	 0066  9A 0000 ---- E	 	        CALL    $FIX            ;FAC=INT(X), X >= 0
  102	 006B  BE 0000 E	 	        MOV     SI,OFFSET DC:$ARG
  103	 006E  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
  104	 0071  E8 0000 E	 	        CALL    $SSUB           ;FAC= X - INT(X) (always positive or zero)
  105	 0074  80 3E 0000 E 7F	 	        CMP     [$FAC],7FH      ;Is X < 1/4 ? (In first quadrant?)
  106	 0079  72 16	 	 	        JB      FIGSIN          ;If so, go compute
  107	 007B  81 3E 0002 E 8040	        CMP     [$AC+2],8040H   ;Is X >= 3/4? (In fourth quadrant?)
  108	 0081  BE 0000 E	 	        MOV     SI,OFFSET DC:$ONEHALF


SINCOS - Sine and cosine functions                       Macro-86 %1(12)   1:8:6  13-Nov-81    Page 1-3



  109	 0084  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC  ;Subtract from 1/2 if in II or III
  110	 0087  72 05	 	 	        JB      SUB
  111	 0089  8B F7	 	 	        MOV     SI,DI
  112	 008B  BF 0000 E	 	        MOV     DI,OFFSET DC:$ONE  ;Subtract 1 from it if in IV
  113	 008E	 	 	 	SUB:
  114	 008E  E8 0000 E	 	        CALL    $SSUB
  115	 0091	 	 	 	FIGSIN:
  116	 0091  BB 0000 R	 	        MOV     BX,OFFSET DC:SSINTAB
  117	 0094  E8 0000 E	 	        CALL    $SPOLYX
  118	 0097  A0 0000 R	 	        MOV     AL,[SIGN]
  119	 009A  24 80	 	 	        AND     AL,80H          ;Reduce to sign bit
  120	 009C  30 06 FFFF E	 	        XOR     [$FAC-1],AL     ;Flip sign if input was negative
  121	 00A0  C3	 	 	        RET
  122	 	 	 	 	
  123	 00A1	 	 	 	CODE    ENDS
  124	 	 	 	 	        END








































SINCOS - Sine and cosine functions                       Macro-86 %1(12)   1:8:6  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	00A1	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  CONST. . . . . . . . . . . . . .	0016	WORD  	PUBLIC	'CONST'
  DATA . . . . . . . . . . . . . .	0001	BYTE  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

COSF . . . . . . . . . . . . . .	L NEAR 	002F	CODE
FIGSIN . . . . . . . . . . . . .	L NEAR 	0091	CODE
SIGN . . . . . . . . . . . . . .	L BYTE 	0000	DATA
SINCOS . . . . . . . . . . . . .	L NEAR 	0050	CODE
SINF . . . . . . . . . . . . . .	L NEAR 	0048	CODE
SSINTAB. . . . . . . . . . . . .	L WORD 	0000	CONST
SUB. . . . . . . . . . . . . . .	L NEAR 	008E	CODE
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ARG . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$COS . . . . . . . . . . . . . .	L NEAR 	002A	CODE	Global
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FIX . . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$HALFPI. . . . . . . . . . . . .	V WORD 	0000	CONST	External
$ONE . . . . . . . . . . . . . .	V WORD 	0000	CONST	External
$ONE4TH. . . . . . . . . . . . .	V WORD 	0000	CONST	External
$ONEHALF . . . . . . . . . . . .	V WORD 	0000	CONST	External
$RECIP2PI. . . . . . . . . . . .	V WORD 	0000	CONST	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SDIV. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SIN . . . . . . . . . . . . . .	L NEAR 	0045	CODE	Global
$SMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SPOLYX. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SSUB. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TAN . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$TEMP. . . . . . . . . . . . . .	V WORD 	0000	DATA	External

Warning Severe
Errors	Errors 
0	0














