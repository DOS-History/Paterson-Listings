FCOMP - Floating point compare                           Macro-86 %1(12)   1:1:0  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   FCOMP - Floating point compare
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $AC:WORD, $DAC:WORD
    6	 	 	 	 	
    7	 0000	 	 	 	DATA    ENDS
    8	 	 	 	 	
    9	 	 	 	 	DC      GROUP   DATA
   10	 	 	 	 	
   11	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   12	 	 	 	 	
   13	 	 	 	 	        PUBLIC  $FCMA,$FCMB,$FCMC,$FCMD,$FCME,$FCMF,$FCMG,$FCMH
   14	 	 	 	 	        PUBLIC  $SCMP, $DCMP
   15	 	 	 	 	
   16	 	 	 	 	        EXTRN   $SAVREG:NEAR, $GTMP:NEAR
   17	 	 	 	 	
   18	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   19	 	 	 	 	
   20	 	 	 	 	
   21	 0000	 	 	 	$FCMD:
   22	 0000  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   23	 0003  EB 06	 	 	        JMP     SHORT $FCMB
   24	 0005	 	 	 	$FCMH:
   25	 0005  E8 0000 E	 	        CALL    $GTMP
   26	 0008	 	 	 	$FCMF:
   27	 0008  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   28	 000B	 	 	 	$FCMB:
   29	 000B  E8 0000 E	 	        CALL    $SAVREG
   30	 	 	 	 	
   31	 	 	 	 	;***  $SCMP and $DCMP - Single and double precision comparison
   32	 	 	 	 	;
   33	 	 	 	 	; Inputs:
   34	 	 	 	 	;       SI = Address of first operand
   35	 	 	 	 	;       DI = Address of second operand
   36	 	 	 	 	; Function:
   37	 	 	 	 	;       Set Carry and Zero flags based on [SI] - [DI] :
   38	 	 	 	 	;       [SI] > [DI]     Carry and zero clear
   39	 	 	 	 	;       [SI] < [DI]     Carry set and zero clear
   40	 	 	 	 	;       [SI] = [DI]     Carry clear and zero set
   41	 	 	 	 	; Outputs:
   42	 	 	 	 	;       Zero and carry flags have result
   43	 	 	 	 	; Registers:
   44	 	 	 	 	;       Destroys all except BP.
   45	 	 	 	 	
   46	 000E	 	 	 	$DCMP:
   47	 000E  B9 0004	 	 	        MOV     CX,4            ;Compare up to 4 words
   48	 0011  83 C6 06	 	 	        ADD     SI,6            ;Point to high word of operands
   49	 0014  83 C7 06	 	 	        ADD     DI,6
   50	 0017  EB 15	 	 	        JMP     SHORT CMP
   51	 	 	 	 	
   52	 0019	 	 	 	$FCMC:
   53	 0019  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   54	 001C  EB 06	 	 	        JMP     SHORT $FCMA


FCOMP - Floating point compare                           Macro-86 %1(12)   1:1:0  13-Nov-81    Page 1-2



   55	 001E	 	 	 	$FCMG:
   56	 001E  E8 0000 E	 	        CALL    $GTMP
   57	 0021	 	 	 	$FCME:
   58	 0021  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   59	 0024	 	 	 	$FCMA:
   60	 0024  E8 0000 E	 	        CALL    $SAVREG
   61	 	 	 	 	
   62	 0027	 	 	 	$SCMP:
   63	 0027  B9 0002	 	 	        MOV     CX,2            ;Compare up to two words
   64	 002A  03 F1	 	 	        ADD     SI,CX           ;Point to high word of operands
   65	 002C  03 F9	 	 	        ADD     DI,CX
   66	 002E	 	 	 	CMP:
   67	 002E  8B 04	 	 	        MOV     AX,[SI]         ;Get exponent and sign of op1
   68	 0030  8B 1D	 	 	        MOV     BX,[DI]         ;And op2
   69	 0032  0A FF	 	 	        OR      BH,BH           ;Second operand zero?
   70	 0034  74 19	 	 	        JZ      Z2
   71	 0036  0A E4	 	 	        OR      AH,AH           ;First operand zero?
   72	 0038  74 0F	 	 	        JZ      Z1
   73	 003A  32 D8	 	 	        XOR     BL,AL           ;Are signs the same?
   74	 003C  D0 D0	 	 	        RCL     AL,1            ;Put sign of op1 in carry (doesn't change SF)
   75	 003E  78 15	 	 	        JS      RET             ;Exit if signs different
   76	 0040  73 02	 	 	        JNC     MAGCMP          ;Comparing positive numbers?
   77	 0042  87 F7	 	 	        XCHG    SI,DI           ;If not, look for smallest magnitude
   78	 0044	 	 	 	MAGCMP:
   79	 0044  FD	 	 	        STD
   80	 0045  F3/ A7	 	 	        REPE    CMPSW           ;Compare magnitudes
   81	 0047  FC	 	 	        CLD
   82	 0048  C3	 	 	        RET
   83	 	 	 	 	
   84	 0049	 	 	 	Z1:
   85	 	 	 	 	;First operand is zero
   86	 0049  0A FF	 	 	        OR      BH,BH           ;Insure zero flag not set
   87	 004B  D0 D3	 	 	        RCL     BL,1            ;Put sign bit in carry
   88	 004D  F5	 	 	        CMC
   89	 004E  C3	 	 	        RET
   90	 	 	 	 	
   91	 004F	 	 	 	Z2:
   92	 	 	 	 	;Second operand is zero
   93	 004F  0A E4	 	 	        OR      AH,AH           ;Is first operand zero too?
   94	 0051  74 02	 	 	        JZ      RET             ;If so, they're equal
   95	 0053  D0 D0	 	 	        RCL     AL,1            ;Put sign bit in carry
   96	 0055  C3	 	 	RET:    RET
   97	 	 	 	 	
   98	 0056	 	 	 	CODE    ENDS
   99	 	 	 	 	        END











FCOMP - Floating point compare                           Macro-86 %1(12)   1:1:0  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0056	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

CMP. . . . . . . . . . . . . . .	L NEAR 	002E	CODE
MAGCMP . . . . . . . . . . . . .	L NEAR 	0044	CODE
RET. . . . . . . . . . . . . . .	L NEAR 	0055	CODE
Z1 . . . . . . . . . . . . . . .	L NEAR 	0049	CODE
Z2 . . . . . . . . . . . . . . .	L NEAR 	004F	CODE
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DCMP. . . . . . . . . . . . . .	L NEAR 	000E	CODE	Global
$FCMA. . . . . . . . . . . . . .	L NEAR 	0024	CODE	Global
$FCMB. . . . . . . . . . . . . .	L NEAR 	000B	CODE	Global
$FCMC. . . . . . . . . . . . . .	L NEAR 	0019	CODE	Global
$FCMD. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$FCME. . . . . . . . . . . . . .	L NEAR 	0021	CODE	Global
$FCMF. . . . . . . . . . . . . .	L NEAR 	0008	CODE	Global
$FCMG. . . . . . . . . . . . . .	L NEAR 	001E	CODE	Global
$FCMH. . . . . . . . . . . . . .	L NEAR 	0005	CODE	Global
$GTMP. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SCMP. . . . . . . . . . . . . .	L NEAR 	0027	CODE	Global

Warning Severe
Errors	Errors 
0	0





















