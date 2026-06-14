CONST - Floating point constants                                 Macro-86 %1(12)   0:58:58   13-Nov-81   Page 1-1



    1	 	 	 	 	        TITLE   CONST - Floating point constants
    2	 	 	 	 	
    3	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
    4	 	 	 	 	
    5	 	 	 	 	        PUBLIC  $HALFSQR2,$HALFPI,$RECIP2PI,$SIXTHPI,$SQRT3,$TANTWELFTHPI
    6	 	 	 	 	        PUBLIC  $LOG2E,$LN2,$ONEHALF,$ONE4TH
    7	 	 	 	 	        PUBLIC  $DLOG2E,$DHALFLN2,$DHALFSQR2,$DBLHALF,$DBL4TH
    8	 	 	 	 	        PUBLIC  $DHALFPI,$DRECIP2PI,$DSIXTHPI,$DSQRT3,$DTANTWELFTHPI
    9	 	 	 	 	
   10	 	 	 	 	;When a single precision constant does not need to be rounded up, the
   11	 	 	 	 	;corresponding double precision constant will use it as its high 4 bytes.
   12	 	 	 	 	; These constants have been checked with MuMath
   13	 	 	 	 	
   14	 0000  65 DE F9 33	 	$DHALFSQR2      DB      065H,0DEH,0F9H,033H
   15	 0004  F3 04 35 80	 	$HALFSQR2       DB      0F3H,004H,035H,080H     ;SQRT(2)/2
   16	 	 	 	 	
   17	 0008  15 44 4E 6E	 	$DRECIP2PI      DB      015H,044H,04EH,06EH
   18	 000C  83 F9 22 7E	 	$RECIP2PI       DB      083H,0F9H,022H,07EH     ;1/(2*PI)
   19	 	 	 	 	
   20	 0010  C2 68 21 A2 DA 0F	$DHALFPI        DB      0C2H,068H,021H,0A2H,0DAH,00FH,049H,081H
   21	       49 81	 	 	
   22	 0018  DB 0F 49 81	 	$HALFPI         DB      0DBH,00FH,049H,081H     ;PI/2
   23	 	 	 	 	
   24	 001C  2C 9B 6B C1 91 0A	$DSIXTHPI       DB      02CH,09BH,06BH,0C1H,091H,00AH,006H,080H
   25	       06 80	 	 	
   26	 0024  92 0A 06 80	 	$SIXTHPI        DB      092H,00AH,006H,080H     ;PI/6
   27	 	 	 	 	
   28	 0028  B2 6A F6 F4 A2 30	$DTANTWELFTHPI  DB      0B2H,06AH,0F6H,0F4H,0A2H,030H,009H,07FH
   29	       09 7F	 	 	
   30	 0030  A3 30 09 7F	 	$TANTWELFTHPI   DB      0A3H,030H,009H,07FH     ;Tan(PI/12)
   31	 	 	 	 	
   32	 0034  54 65 C2 42	 	$DSQRT3         DB      054H,065H,0C2H,042H
   33	 0038  D7 B3 5D 81	 	$SQRT3          DB      0D7H,0B3H,05DH,081H     ;1/Tan(30 degrees) = SQRT(3)
   34	 	 	 	 	
   35	 003C  F1 17 5C 29	 	$DLOG2E         DB      0F1H,017H,05CH,029H
   36	 0040  3B AA 38 81	 	$LOG2E          DB      03BH,0AAH,038H,081H     ;LOG base 2 of e
   37	 	 	 	 	
   38	 0044  7A CF D1 F7 17 72	$DHALFLN2       DB      07AH,0CFH,0D1H,0F7H,017H,072H,031H,07FH
   39	       31 7F	 	 	
   40	 004C  18 72 31 80	 	$LN2            DB      018H,072H,031H,080H     ;LN(2)
   41	 	 	 	 	
   42	 0050  00 00 00 00	 	$DBLHALF        DB      0,0,0,0
   43	 0054  00 00 00 80	 	$ONEHALF        DB      0,0,0,80H
   44	 	 	 	 	
   45	 0058  00 00 00 00	 	$DBL4TH         DB      0,0,0,0
   46	 005C  00 00 00 7F	 	$ONE4TH         DB      0,0,0,7FH
   47	 	 	 	 	
   48	 0060	 	 	 	CONST   ENDS
   49	 	 	 	 	
   50	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
   51	 	 	 	 	
   52	 	 	 	 	        PUBLIC  $ARG,$TEMP,$TEMP2
   53	 	 	 	 	
   54	 	 	 	 	        EXTRN   $AC:WORD, $DAC:WORD


CONST - Floating point constants                                 Macro-86 %1(12)   0:58:58   13-Nov-81   Page 1-2



   55	 	 	 	 	
   56	 0000     04 [	 	 	$ARG    DW      4 DUP(?)
   57	                ????	 	
   58	                      ]	 	
   59	 	 	 	 	
   60	 0008     04 [	 	 	$TEMP   DW      4 DUP(?)
   61	                ????	 	
   62	                      ]	 	
   63	 	 	 	 	
   64	 0010     04 [	 	 	$TEMP2  DW      4 DUP(?)
   65	                ????	 	
   66	                      ]	 	
   67	 	 	 	 	
   68	 	 	 	 	
   69	 0018	 	 	 	DATA    ENDS
   70	 	 	 	 	
   71	 	 	 	 	DC      GROUP   DATA,CONST
   72	 	 	 	 	
   73	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   74	 	 	 	 	
   75	 	 	 	 	        PUBLIC  $PUT1, $PUT1D
   76	 	 	 	 	
   77	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   78	 	 	 	 	
   79	 0000	 	 	 	$PUT1D:
   80	 0000  33 C0	 	 	        XOR     AX,AX
   81	 0002  A3 0000 E	 	        MOV     [$DAC],AX
   82	 0005  A3 0002 E	 	        MOV     [$DAC+2],AX
   83	 0008	 	 	 	$PUT1:
   84	 0008  C7 06 0000 E 0000	        MOV     [$AC],0
   85	 000E  C7 06 0002 E 8100	        MOV     [$AC+2],8100H
   86	 0014  C3	 	 	        RET
   87	 	 	 	 	
   88	 0015	 	 	 	CODE    ENDS
   89	 	 	 	 	        END





















CONST - Floating point constants                                 Macro-86 %1(12)   0:58:58   13-Nov-81   Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0015	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0018	WORD  	PUBLIC	'DATA'
  CONST. . . . . . . . . . . . . .	0060	WORD  	PUBLIC	'CONST'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ARG . . . . . . . . . . . . . .	L WORD 	0000	DATA	Global	Length =0004
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DBL4TH. . . . . . . . . . . . .	L BYTE 	0058	CONST	Global
$DBLHALF . . . . . . . . . . . .	L BYTE 	0050	CONST	Global
$DHALFLN2. . . . . . . . . . . .	L BYTE 	0044	CONST	Global
$DHALFPI . . . . . . . . . . . .	L BYTE 	0010	CONST	Global
$DHALFSQR2 . . . . . . . . . . .	L BYTE 	0000	CONST	Global
$DLOG2E. . . . . . . . . . . . .	L BYTE 	003C	CONST	Global
$DRECIP2PI . . . . . . . . . . .	L BYTE 	0008	CONST	Global
$DSIXTHPI. . . . . . . . . . . .	L BYTE 	001C	CONST	Global
$DSQRT3. . . . . . . . . . . . .	L BYTE 	0034	CONST	Global
$DTANTWELFTHPI . . . . . . . . .	L BYTE 	0028	CONST	Global
$HALFPI. . . . . . . . . . . . .	L BYTE 	0018	CONST	Global
$HALFSQR2. . . . . . . . . . . .	L BYTE 	0004	CONST	Global
$LN2 . . . . . . . . . . . . . .	L BYTE 	004C	CONST	Global
$LOG2E . . . . . . . . . . . . .	L BYTE 	0040	CONST	Global
$ONE4TH. . . . . . . . . . . . .	L BYTE 	005C	CONST	Global
$ONEHALF . . . . . . . . . . . .	L BYTE 	0054	CONST	Global
$PUT1. . . . . . . . . . . . . .	L NEAR 	0008	CODE	Global
$PUT1D . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$RECIP2PI. . . . . . . . . . . .	L BYTE 	000C	CONST	Global
$SIXTHPI . . . . . . . . . . . .	L BYTE 	0024	CONST	Global
$SQRT3 . . . . . . . . . . . . .	L BYTE 	0038	CONST	Global
$TANTWELFTHPI. . . . . . . . . .	L BYTE 	0030	CONST	Global
$TEMP. . . . . . . . . . . . . .	L WORD 	0008	DATA	Global	Length =0004
$TEMP2 . . . . . . . . . . . . .	L WORD 	0010	DATA	Global	Length =0004

Warning Severe
Errors	Errors 
0	0












