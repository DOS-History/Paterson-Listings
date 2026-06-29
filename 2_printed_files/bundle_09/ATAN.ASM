ATAN - Arc tangent                                       Macro-86 %1(12)   0:58:20  13-Nov-81   Page 1-1 



    1	 	 	 	 	        TITLE   ATAN - Arc tangent
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $FAC:BYTE, $AC:WORD, $ARG:WORD, $TEMP:WORD
    6	 	 	 	 	
    7	 0000	 	 	 	DATA    ENDS
    8	 	 	 	 	
    9	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
   10	 	 	 	 	
   11	 	 	 	 	        EXTRN   $ONE:WORD,$HALFPI:WORD,$SIXTHPI:WORD,$SQRT3:WORD
   12	 	 	 	 	        EXTRN	$TANTWELFTHPI:WORD
   13	 	 	 	 	
   14	 	 	 	 	;Coefficients for Hart 4940, relative error 7.69
   15	 	 	 	 	;ATAN(x) = xP(x^2)
   16	 	 	 	 	; These constants have been checked with MuMath
   17	 	 	 	 	
   18	 0000  0003	 	 	ATANTAB DW      3                       ;Degree
   19	 0002  62 35 83 7E	 	        DB      062H,035H,083H,07EH     ;-0.12813 3334
   20	 0006  50 24 4C 7E	 	        DB      050H,024H,04CH,07EH     ;+0.19935 72694
   21	 000A  79 A9 AA 7F	 	        DB      079H,0A9H,0AAH,07FH     ;-0.33332 42344 5
   22	 000E  00 00 00 81	 	        DB      000H,000H,000H,081H     ;+0.99999 99797 73
   23	 	 	 	 	
   24	 0012	 	 	 	CONST   ENDS
   25	 	 	 	 	
   26	 	 	 	 	
   27	 	 	 	 	DC      GROUP   DATA,CONST
   28	 	 	 	 	
   29	 	 	 	 	
   30	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   31	 	 	 	 	
   32	 	 	 	 	        PUBLIC  $ATN
   33	 	 	 	 	
   34	 	 	 	 	        EXTRN   $SAVREG:NEAR, $SPOLYX:NEAR
   35	 	 	 	 	        EXTRN   $SDIV:NEAR, $SMUL:NEAR, $SADD:NEAR, $SSUB:NEAR, $SCMP:NEAR
   36	 	 	 	 	
   37	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   38	 	 	 	 	
   39	 	 	 	 	
   40	 	 	 	 	;$ATN - Arc tangent
   41	 	 	 	 	;
   42	 	 	 	 	; Inputs:
   43	 	 	 	 	;       BX = Address of argument
   44	 	 	 	 	; Outputs:
   45	 	 	 	 	;       Result in FAC
   46	 	 	 	 	; Registers:
   47	 	 	 	 	;       Only F affected.
   48	 	 	 	 	
   49	 0000	 	 	 	$ATN:
   50	 0000  E8 0000 E	 	        CALL    $SAVREG
   51	 0003  8B F3	 	 	        MOV     SI,BX
   52	 0005  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   53	 0008  A5	 	 	        MOVSW                   ;Put in FAC
   54	 0009  AD	 	 	        LODSW


ATAN - Arc tangent                                       Macro-86 %1(12)   0:58:20  13-Nov-81   Page 1-2 



   55	 000A  AB	 	 	        STOSW
   56	 000B  0A E4	 	 	        OR      AH,AH           ;Is it zero?
   57	 000D  74 11	 	 	        JZ      DONE            ;If so, result is too
   58	 000F  A8 80	 	 	        TEST    AL,80H          ;Check sign
   59	 0011  79 0E	 	 	        JNS     POSATAN
   60	 0013  24 7F	 	 	        AND     AL,7FH
   61	 0015  A2 FFFF E	 	        MOV     [$FAC-1],AL     ;Make it positive
   62	 0018  E8 0021 R	 	        CALL    POSATAN         ;Take arctan of positive number
   63	 001B  80 36 FFFF E 80	 	        XOR     [$FAC-1],80H    ;Invert sign back
   64	 0020  C3	 	 	DONE:   RET
   65	 	 	 	 	
   66	 0021	 	 	 	POSATAN:
   67	 0021  80 FC 81	 	 	        CMP     AH,81H          ;Is it >= 1?
   68	 0024  72 15	 	 	        JB      LESSTHAN1
   69	 0026  BE 0000 E	 	        MOV     SI,OFFSET DC:$ONE
   70	 0029  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   71	 002C  E8 0000 E	 	        CALL    $SDIV           ;It's reciprocal is < 1
   72	 002F  E8 003B R	 	        CALL    LESSTHAN1       ;Compute arc-cotan on number < 1
   73	 0032  BE 0000 E	 	        MOV     SI,OFFSET DC:$HALFPI
   74	 0035  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   75	 0038  E9 0000 E	 	        JMP     $SSUB           ;Correct by subtracting from PI/2
   76	 	 	 	 	
   77	 003B	 	 	 	LESSTHAN1:
   78	 003B  BE 0000 E	 	        MOV     SI,OFFSET DC:$TANTWELFTHPI
   79	 003E  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   80	 0041  E8 0000 E	 	        CALL    $SCMP           ;Compare argument to PI/12
   81	 0044  73 40	 	 	        JAE     DOATAN          ;Range reduction complete if <= PI/12
   82	 0046  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   83	 0049  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
   84	 004C  A5	 	 	        MOVSW                   ;Save X in ARG
   85	 004D  A5	 	 	        MOVSW
   86	 004E  BE 0000 E	 	        MOV     SI,OFFSET DC:$SQRT3  ;Point to TAN(PI/6) (PI/6 = 30 degrees)
   87	 0051  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   88	 0054  E8 0000 E	 	        CALL    $SADD           ;FAC = X + TAN(PI/6)
   89	 0057  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   90	 005A  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
   91	 005D  A5	 	 	        MOVSW                   ;Save in TEMP
   92	 005E  A5	 	 	        MOVSW
   93	 005F  BE 0000 E	 	        MOV     SI,OFFSET DC:$SQRT3
   94	 0062  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
   95	 0065  E8 0000 E	 	        CALL    $SMUL           ;FAC = X * TAN(PI/6)
   96	 0068  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   97	 006B  BF 0000 E	 	        MOV     DI,OFFSET DC:$ONE
   98	 006E  E8 0000 E	 	        CALL    $SSUB           ;FAC = X * TAN(PI/6) - 1
   99	 0071  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
  100	 0074  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
  101	 0077  E8 0000 E	 	        CALL    $SDIV           ;FAC = (X*TAN(PI/6) - 1)/(X + TAN(PI/6)
  102	 007A  E8 0086 R	 	        CALL    DOATAN          ;Comput e arctan on argument < PI/12
  103	 007D  BE 0000 E	 	        MOV     SI,OFFSET DC:$SIXTHPI
  104	 0080  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
  105	 0083  E9 0000 E	 	        JMP     $SADD           ;Correct for range reduction by adding PI/6
  106	 	 	 	 	
  107	 0086	 	 	 	DOATAN:
  108	 0086  BB 0000 R	 	        MOV     BX,OFFSET DC:ATANTAB


ATAN - Arc tangent                                       Macro-86 %1(12)   0:58:20  13-Nov-81   Page 1-3 



  109	 0089  E9 0000 E	 	        JMP     $SPOLYX
  110	 	 	 	 	
  111	 008C	 	 	 	CODE    ENDS
  112	 	 	 	 	        END




















































ATAN - Arc tangent                                       Macro-86 %1(12)   0:58:20  13-Nov-81   Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	008C	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'
  CONST. . . . . . . . . . . . . .	0012	WORD  	PUBLIC	'CONST'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ATANTAB. . . . . . . . . . . . .	L WORD 	0000	CONST
DOATAN . . . . . . . . . . . . .	L NEAR 	0086	CODE
DONE . . . . . . . . . . . . . .	L NEAR 	0020	CODE
LESSTHAN1. . . . . . . . . . . .	L NEAR 	003B	CODE
POSATAN. . . . . . . . . . . . .	L NEAR 	0021	CODE
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ARG . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ATN . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$HALFPI. . . . . . . . . . . . .	V WORD 	0000	CONST	External
$ONE . . . . . . . . . . . . . .	V WORD 	0000	CONST	External
$SADD. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SCMP. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SDIV. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SIXTHPI . . . . . . . . . . . .	V WORD 	0000	CONST	External
$SMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SPOLYX. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SQRT3 . . . . . . . . . . . . .	V WORD 	0000	CONST	External
$SSUB. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TANTWELFTHPI. . . . . . . . . .	V WORD 	0000	CONST	External
$TEMP. . . . . . . . . . . . . .	V WORD 	0000	DATA	External

Warning Severe
Errors	Errors 
0	0

















