POLY - Polynomial evaluator for transcendental functions         Macro-86 %1(12)   1:6:40  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   POLY - Polynomial evaluator for transcendental functions
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $AC:WORD, $DAC:WORD, $ARG:WORD
    6	 	 	 	 	
    7	 0000	 	 	 	DATA    ENDS
    8	 	 	 	 	
    9	 	 	 	 	
   10	 	 	 	 	DC      GROUP   DATA
   11	 	 	 	 	
   12	 	 	 	 	
   13	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   14	 	 	 	 	
   15	 	 	 	 	        PUBLIC  $SPOLY, $SPOLY2, $SPOLYX, $DPOLY, $DPOLY2, $DPOLYX
   16	 	 	 	 	
   17	 	 	 	 	        EXTRN   $SMUL:NEAR, $SADD:NEAR, $DMUL:NEAR, $DADD:NEAR
   18	 	 	 	 	
   19	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   20	 	 	 	 	
   21	 	 	 	 	
   22	 	 	 	 	;***  $SPOLY, $SPOLY2, & $SPOLYX - Evaluate SP polynomial
   23	 	 	 	 	;
   24	 	 	 	 	; Inputs:
   25	 	 	 	 	;       BX = Address of list of coefficients. First byte in list is nmber of
   26	 	 	 	 	;            coefficients, followed by the constants ordered from highest
   27	 	 	 	 	;            power to lowest.
   28	 	 	 	 	;       FAC = argument.
   29	 	 	 	 	; Function:
   30	 	 	 	 	;       Evaluate polynomial by Horner's method
   31	 	 	 	 	; Outputs:
   32	 	 	 	 	;       Result in FAC.
   33	 	 	 	 	; Registers:
   34	 	 	 	 	;       ALL destroyed.
   35	 	 	 	 	
   36	 0000	 	 	 	$SPOLY2:
   37	 	 	 	 	;Compute polynomial on square of argument
   38	 0000  53	 	 	        PUSH    BX
   39	 0001  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   40	 0004  8B FE	 	 	        MOV     DI,SI
   41	 0006  E8 0000 E	 	        CALL    $SMUL           ;Square the argument
   42	 0009  5B	 	 	        POP     BX
   43	 000A	 	 	 	$SPOLY:
   44	 000A  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   45	 000D  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG  ;Local stroage for argument
   46	 0010  A5	 	 	        MOVSW
   47	 0011  A5	 	 	        MOVSW                   ;Save argument
   48	 0012  8B F3	 	 	        MOV     SI,BX           ;Point to coefficient table
   49	 0014  AD	 	 	        LODSW                   ;Number of coefficients
   50	 0015  91	 	 	        XCHG    AX,CX           ;Count in CX
   51	 0016  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   52	 0019  A5	 	 	        MOVSW                   ;Move first coefficient into FAC
   53	 001A  A5	 	 	        MOVSW
   54	 001B	 	 	 	SPOLYLOOP:


POLY - Polynomial evaluator for transcendental functions         Macro-86 %1(12)   1:6:40  13-Nov-81    Page 1-2



   55	 001B  51	 	 	        PUSH    CX
   56	 001C  56	 	 	        PUSH    SI
   57	 001D  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   58	 0020  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
   59	 0023  E8 0000 E	 	        CALL    $SMUL           ;Multiply by argument
   60	 0026  5E	 	 	        POP     SI              ;Recover pointer to next coefficient
   61	 0027  56	 	 	        PUSH    SI
   62	 0028  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   63	 002B  E8 0000 E	 	        CALL    $SADD           ;Add coefficient
   64	 002E  5E	 	 	        POP     SI
   65	 002F  59	 	 	        POP     CX
   66	 0030  83 C6 04	 	 	        ADD     SI,4            ;Bump to next coefficient
   67	 0033  E2 E6	 	 	        LOOP    SPOLYLOOP
   68	 0035  C3	 	 	        RET
   69	 	 	 	 	
   70	 0036	 	 	 	$SPOLYX:
   71	 	 	 	 	;Same as $SPOLY2, but multiplies by original (unsquared) argument when done,
   72	 	 	 	 	;for computing odd-degree polynomials (like SIN).
   73	 0036  FF 36 0000 E	 	        PUSH    [$AC]
   74	 003A  FF 36 0002 E	 	        PUSH    [$AC+2]
   75	 003E  E8 0000 R	 	        CALL    $SPOLY2         ;Compute polynomial on square on argument
   76	 0041  BE 0000 E	 	        MOV     SI,OFFSET DC:$ARG
   77	 0044  8F 44 02	 	 	        POP     [SI+2]
   78	 0047  8F 04	 	 	        POP     [SI]
   79	 0049  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   80	 004C  E9 0000 E	 	        JMP     $SMUL           ;Multiply by original argument (unsquared)
   81	 	 	 	 	
   82	 	 	 	 	
   83	 	 	 	 	;***  $DPOLY & $DPOLY2 - Evaluate DP polynomial
   84	 	 	 	 	;
   85	 	 	 	 	; Inputs:
   86	 	 	 	 	;       BX = Address of list of coefficients. First byte in list is number of
   87	 	 	 	 	;            coefficients, followed by the constants ordered from highest
   88	 	 	 	 	;            power to lowest.
   89	 	 	 	 	;       FAC = argument.
   90	 	 	 	 	; Function:
   91	 	 	 	 	;       Evaluate polynomial by Horner's method
   92	 	 	 	 	; Outputs:
   93	 	 	 	 	;       Result in FAC.
   94	 	 	 	 	; Registers:
   95	 	 	 	 	;       ALL destroyed.
   96	 	 	 	 	
   97	 004F	 	 	 	$DPOLY2:
   98	 	 	 	 	;Compute polynomial on square of argument
   99	 004F  53	 	 	        PUSH    BX
  100	 0050  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  101	 0053  8B FE	 	 	        MOV     DI,SI
  102	 0055  E8 0000 E	 	        CALL    $DMUL           ;Square the argument
  103	 0058  5B	 	 	        POP     BX
  104	 0059	 	 	 	$DPOLY:
  105	 0059  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  106	 005C  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG  ;Local storage for argument
  107	 005F  A5	 	 	        MOVSW
  108	 0060  A5	 	 	        MOVSW


POLY - Polynomial evaluator for transcendental functions         Macro-86 %1(12)   1:6:40  13-Nov-81    Page 1-3



  109	 0061  A5	 	 	        MOVSW
  110	 0062  A5	 	 	        MOVSW                   ;Save argument
  111	 0063  8B F3	 	 	        MOV     SI,BX           ;Point to coefficient table
  112	 0065  AD	 	 	        LODSW                   ;Number of coefficients
  113	 0066  91	 	 	        XCHG    AX,CX           ;Count in CX
  114	 0067  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  115	 006A  A5	 	 	        MOVSW                   ;Move first coefficient into FAC
  116	 006B  A5	 	 	        MOVSW
  117	 006C  A5	 	 	        MOVSW
  118	 006D  A5	 	 	        MOVSW
  119	 006E	 	 	 	DPOLYLOOP:
  120	 006E  51	 	 	        PUSH    CX
  121	 006F  56	 	 	        PUSH    SI
  122	 0070  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  123	 0073  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
  124	 0076  E8 0000 E	 	        CALL    $DMUL           ;Multiply by argument
  125	 0079  5E	 	 	        POP     SI              ;Recover pointer to next coefficient
  126	 007A  56	 	 	        PUSH    SI
  127	 007B  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  128	 007E  E8 0000 E	 	        CALL    $DADD           ;Add coefficient
  129	 0081  5E	 	 	        POP     SI
  130	 0082  59	 	 	        POP     CX
  131	 0083  83 C6 08	 	 	        ADD     SI,8            ;Bump to next coefficient
  132	 0086  E2 E6	 	 	        LOOP    DPOLYLOOP
  133	 0088  C3	 	 	        RET
  134	 	 	 	 	
  135	 0089	 	 	 	$DPOLYX:
  136	 	 	 	 	;Same as $DPOLY2, but multiplies by original (unsquared) argument when done,
  137	 	 	 	 	;for computing odd-degree polynomials (like SIN).
  138	 0089  FF 36 0000 E	 	        PUSH    [$DAC]
  139	 008D  FF 36 0002 E	 	        PUSH    [$DAC+2]
  140	 0091  FF 36 0004 E	 	        PUSH    [$DAC+4]
  141	 0095  FF 36 0006 E	 	        PUSH    [$DAC+6]
  142	 0099  E8 004F R	 	        CALL    $DPOLY2         ;Compute polynomial on square on argument
  143	 009C  BE 0000 E	 	        MOV     SI,OFFSET DC:$ARG
  144	 009F  8F 44 06	 	 	        POP     [SI+6]
  145	 00A2  8F 44 04	 	 	        POP     [SI+4]
  146	 00A5  8F 44 02	 	 	        POP     [SI+2]
  147	 00A8  8F 04	 	 	        POP     [SI]
  148	 00AA  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  149	 00AD  E9 0000 E	 	        JMP     $DMUL           ;Multiply by original argument (unsquared)
  150	 	 	 	 	
  151	 00B0	 	 	 	CODE    ENDS
  152	 	 	 	 	        END












POLY - Polynomial evaluator for transcendental functions         Macro-86 %1(12)   1:6:40  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	00B0	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

DPOLYLOOP. . . . . . . . . . . .	L NEAR 	006E	CODE
SPOLYLOOP. . . . . . . . . . . .	L NEAR 	001B	CODE
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ARG . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DADD. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DPOLY . . . . . . . . . . . . .	L NEAR 	0059	CODE	Global
$DPOLY2. . . . . . . . . . . . .	L NEAR 	004F	CODE	Global
$DPOLYX. . . . . . . . . . . . .	L NEAR 	0089	CODE	Global
$SADD. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SPOLY . . . . . . . . . . . . .	L NEAR 	000A	CODE	Global
$SPOLY2. . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$SPOLYX. . . . . . . . . . . . .	L NEAR 	0036	CODE	Global

Warning Severe
Errors	Errors 
0	0

























