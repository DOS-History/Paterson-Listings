LOG - Natural and base 2 logarithm                       Macro-86 %1(12)   1:6:6  13-Nov-81     Page 1-1



    1	 	 	 	 	        TITLE   LOG - Natural and base 2 logarithm
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $AC:WORD, $FAC:BYTE, $ARG:WORD
    6	 	 	 	 	
    7	 0000	 	 	 	DATA    ENDS
    8	 	 	 	 	
    9	 	 	 	 	
   10	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
   11	 	 	 	 	
   12	 	 	 	 	        EXTRN   $LN2:WORD
   13	 	 	 	 	
   14	 	 	 	 	;Coefficient tables for Hart's 2524. Absolute error 8.32, range [1/2,1].
   15	 	 	 	 	;LOG2(x) = P(x) / Q(x)
   16	 	 	 	 	; These constants have been checked with MuMath
   17	 	 	 	 	
   18	 0000  0003	 	 	LOGPTAB DW      3                       ;Degree 3 polynomial
   19	 0002  9A F7 19 83	 	        DB      09AH,0F7H,019H,083H     ;+4.8114 74609 89
   20	 0006  24 63 43 83	 	        DB      024H,063H,043H,083H     ;+6.1058 51990 15
   21	 000A  75 CD 8D 84	 	        DB      075H,0CDH,08DH,084H     ;-8.8626 59939 1
   22	 000E  A9 7F 83 82	 	        DB      0A9H,07FH,083H,082H     ;-2.0546 66719 51
   23	 	 	 	 	
   24	 0012  0003	 	 	LOGQTAB DW      3                       ;Degree 3 polynomial
   25	 0014  00 00 00 81	 	        DB      000H,000H,000H,081H     ;+1
   26	 0018  E2 B0 4D 83	 	        DB      0E2H,0B0H,04DH,083H     ;+6.4278 42090 29
   27	 001C  0A 72 11 83	 	        DB      00AH,072H,011H,083H     ;+4.5451 70876 29
   28	 0020  F4 04 35 7F	 	        DB      0F4H,004H,035H,07FH     ;+0.35355 34252 77
   29	 	 	 	 	
   30	 0024	 	 	 	CONST   ENDS
   31	 	 	 	 	
   32	 	 	 	 	
   33	 	 	 	 	DC      GROUP   DATA,CONST
   34	 	 	 	 	
   35	 	 	 	 	
   36	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   37	 	 	 	 	
   38	 	 	 	 	        PUBLIC  $LOG,$LOG2
   39	 	 	 	 	
   40	 	 	 	 	        EXTRN   $SMUL:NEAR, $SPOLY:NEAR, $SADD:NEAR, $CISA:FAR
   41	 	 	 	 	        EXTRN   $SAVREG:NEAR, $ERC_FC:NEAR, $SDIV:NEAR
   42	 	 	 	 	
   43	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   44	 	 	 	 	
   45	 	 	 	 	
   46	 	 	 	 	;***  $LOG - LOG (base e) function
   47	 	 	 	 	;
   48	 	 	 	 	; Inputs:
   49	 	 	 	 	;       BX = Address of operand
   50	 	 	 	 	; Outputs:
   51	 	 	 	 	;       Result in FAC
   52	 	 	 	 	; Registers:
   53	 	 	 	 	;       Only F affected.
   54	 	 	 	 	


LOG - Natural and base 2 logarithm                       Macro-86 %1(12)   1:6:6  13-Nov-81     Page 1-2



   55	 0000	 	 	 	$LOG:
   56	 0000  E8 0000 E	 	        CALL    $SAVREG
   57	 0003  8B F3	 	 	        MOV     SI,BX
   58	 0005  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   59	 0008  A5	 	 	        MOVSW                   ;Put operand in FAC
   60	 0009  A5	 	 	        MOVSW
   61	 000A  E8 0016 R	 	        CALL    $LOG2           ;Compute log base 2
   62	 000D  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   63	 0010  BF 0000 E	 	        MOV     DI,OFFSET DC:$LN2
   64	 0013  E9 0000 E	 	        JMP     $SMUL
   65	 	 	 	 	
   66	 	 	 	 	
   67	 	 	 	 	;***  $LOG2 - Log (base two)
   68	 	 	 	 	;
   69	 	 	 	 	; Inputs:
   70	 	 	 	 	;       Number in FAC
   71	 	 	 	 	; Function:
   72	 	 	 	 	;       Compute Log base 2, using relation LOG2(X*2^Y) = LOG2(2^Y) + LOG2(X) =
   73	 	 	 	 	;       Y + LOG2(X), 0.5 <= X < 1
   74	 	 	 	 	; Outputs:
   75	 	 	 	 	;       Result in FAC
   76	 	 	 	 	; Registers:
   77	 	 	 	 	;       All registers destroyed.
   78	 	 	 	 	
   79	 0016	 	 	 	$LOG2:
   80	 0016  A1 0002 E	 	        MOV     AX,[$AC+2]
   81	 0019  0A E4	 	 	        OR      AH,AH           ;Taking log of zero?
   82	 001B  74 53	 	 	        JZ      ARGERR
   83	 001D  0A C0	 	 	        OR      AL,AL           ;Log of negative number?
   84	 001F  78 4F	 	 	        JS      ARGERR
   85	 0021  C6 06 0000 E 80	 	        MOV     [$FAC],80H      ;Assign a zero exponent
   86	 0026  8A C4	 	 	        MOV     AL,AH           ;Convert exponent to 16-bit integer
   87	 0028  2C 80	 	 	        SUB     AL,80H          ;   Remove bias
   88	 002A  98	 	 	        CBW
   89	 002B  50	 	 	        PUSH    AX
   90	 002C  FF 36 0000 E	 	        PUSH    [$AC]
   91	 0030  FF 36 0002 E	 	        PUSH    [$AC+2]         ;Save FAC for figuring Q(x)
   92	 0034  BB 0000 R	 	        MOV     BX,OFFSET DC:LOGPTAB
   93	 0037  E8 0000 E	 	        CALL    $SPOLY          ;Compute P(x) polynomial on mantissa
   94	 003A  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   95	 003D  BF 0004 E	 	        MOV     DI,OFFSET DC:$ARG+4
   96	 0040  A5	 	 	        MOVSW
   97	 0041  A5	 	 	        MOVSW                   ;Hold P(x) in temp while we compute Q(x)
   98	 0042  8F 06 0002 E	 	        POP     [$AC+2]
   99	 0046  8F 06 0000 E	 	        POP     [$AC]
  100	 004A  BB 0012 R	 	        MOV     BX,OFFSET DC:LOGQTAB
  101	 004D  E8 0000 E	 	        CALL    $SPOLY          ;Compute Q(x)
  102	 0050  BE 0004 E	 	        MOV     SI,OFFSET DC:$ARG+4
  103	 0053  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
  104	 0056  E8 0000 E	 	        CALL    $SDIV           ;LOG2(x) = P(x) / Q(x)
  105	 0059  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
  106	 005C  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
  107	 005F  A5	 	 	        MOVSW                   ;Set result aside in ARG
  108	 0060  A5	 	 	        MOVSW


LOG - Natural and base 2 logarithm                       Macro-86 %1(12)   1:6:6  13-Nov-81     Page 1-3



  109	 0061  5B	 	 	        POP     BX              ;Recover exponent (as integer)
  110	 0062  9A 0000 ---- E	 	        CALL    $CISA           ;Convert it to S.P.
  111	 0067  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
  112	 006A  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
  113	 006D  E9 0000 E	 	        JMP     $SADD
  114	 	 	 	 	
  115	 0070  E9 0000 E	 	ARGERR: JMP     $ERC_FC
  116	 	 	 	 	
  117	 0073	 	 	 	CODE    ENDS
  118	 	 	 	 	        END














































LOG - Natural and base 2 logarithm                       Macro-86 %1(12)   1:6:6  13-Nov-81     Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0073	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'
  CONST. . . . . . . . . . . . . .	0024	WORD  	PUBLIC	'CONST'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ARGERR . . . . . . . . . . . . .	L NEAR 	0070	CODE
LOGPTAB. . . . . . . . . . . . .	L WORD 	0000	CONST
LOGQTAB. . . . . . . . . . . . .	L WORD 	0012	CONST
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ARG . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$CISA. . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$LN2 . . . . . . . . . . . . . .	V WORD 	0000	CONST	External
$LOG . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$LOG2. . . . . . . . . . . . . .	L NEAR 	0016	CODE	Global
$SADD. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SDIV. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SPOLY . . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0























