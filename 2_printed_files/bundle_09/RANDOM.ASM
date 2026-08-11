RANDOM - Random number generator and RANDOMIZE           Macro-86 %1(12)   1:7:46  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   RANDOM - Random number generator and RANDOMIZE
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 0000	 	 	 	DATA    ENDS
    5	 	 	 	 	
    6	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
    7	 	 	 	 	
    8	 0000  43FD 0003	 	RNDA    DW      43FDH,3         ;   214,013
    9	 0004  9EC3 001A	 	RNDC    DW      9EC3H,26        ; 2,531,011
   10	 0008  0005 0000	 	RNDX    DW      5,0
   11	 000C  52 61 6E 64 6F 6D	PROMPT  DB      "Random Number Seed (-32768 to 32767)"
   12	       20 4E 75 6D 62 65	
   13	       72 20 53 65 65 64	
   14	       20 28 2D 33 32 37	
   15	       36 38 20 74 6F 20	
   16	       33 32 37 36 37 29	
   17	 	 	 	 	EVEN
   18	 0030  0024	 	 	RANDMES DW      $-PROMPT        ;String descriptor for prompt
   19	 0032  000C R	 	 	        DW      DC:PROMPT
   20	 	 	 	 	
   21	 0034	 	 	 	CONST   ENDS
   22	 	 	 	 	
   23	 	 	 	 	
   24	 	 	 	 	DC      GROUP   DATA,CONST
   25	 	 	 	 	
   26	 	 	 	 	
   27	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   28	 	 	 	 	
   29	 	 	 	 	        PUBLIC  $RAN,$RA0,$RZ0,$RZ1
   30	 	 	 	 	
   31	 	 	 	 	        EXTRN   $SNORM:NEAR, $SAVREG:NEAR
   32	 	 	 	 	        EXTRN   $IN0A:FAR, $IPUA:FAR, $IPUB:FAR
   33	 	 	 	 	
   34	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   35	 	 	 	 	
   36	 	 	 	 	
   37	 	 	 	 	;***  $RAN, $RA0 - RND function
   38	 	 	 	 	;
   39	 	 	 	 	; Inputs:
   40	 	 	 	 	;       BX = Address of argument ($RAN only)
   41	 	 	 	 	; Function:
   42	 	 	 	 	;       If argument is positive (or always for $RA0, which has no argument),
   43	 	 	 	 	;       return next random number in sequence. If argument is negative, start
   44	 	 	 	 	;       a new pseudo-random sequence. If argument is zero, retun previous
   45	 	 	 	 	;       value.
   46	 	 	 	 	; Outputs:
   47	 	 	 	 	;       Pseudo-random number range [0,1) in FAC.
   48	 	 	 	 	; Registers:
   49	 	 	 	 	;       No registers affected.
   50	 	 	 	 	
   51	 0000	 	 	 	$RA0:
   52	 0000  E8 0000 E	 	        CALL    $SAVREG
   53	 0003  EB 0F	 	 	        JMP     SHORT NEWRAND
   54	 	 	 	 	


RANDOM - Random number generator and RANDOMIZE           Macro-86 %1(12)   1:7:46  13-Nov-81    Page 1-2



   55	 0005	 	 	 	$RAN:
   56	 0005  E8 0000 E	 	        CALL    $SAVREG
   57	 0008  80 7F 03 00	 	        CMP     BYTE PTR[BX+3],0  ;Is number zero?
   58	 000C  74 3C	 	 	        JZ      SAMNUM          ;Return same result as last time
   59	 000E  F6 47 02 80	 	        TEST    BYTE PTR[BX+2],80H  ;Is number negative?
   60	 0012  78 40	 	 	        JS      NEWSEED         ;If so, start new sequence
   61	 0014	 	 	 	NEWRAND:
   62	 0014  A1 0008 R	 	        MOV     AX,[RNDX]       ;Low half of previous number
   63	 0017  8B 0E 0000 R	 	        MOV     CX,[RNDA]       ;Low half of A
   64	 001B  F7 E1	 	 	        MUL     CX
   65	 001D  97	 	 	        XCHG    AX,DI           ;Save low half in DI
   66	 001E  8B DA	 	 	        MOV     BX,DX           ;  high half in BX
   67	 0020  A1 000A R	 	        MOV     AX,[RNDX+2]     ;High half of previous
   68	 0023  F7 E1	 	 	        MUL     CX
   69	 0025  03 D8	 	 	        ADD     BX,AX           ;Sum partial products
   70	 0027  A1 0002 R	 	        MOV     AX,[RNDA+2]
   71	 002A  F7 26 0008 R	 	        MUL     [RNDX]
   72	 002E  03 D8	 	 	        ADD     BX,AX           ;Last partial product (since we're mod 2^24)
   73	 0030  03 3E 0004 R	 	        ADD     DI,[RNDC]       ;Add in constant C
   74	 0034  12 1E 0006 R	 	        ADC     BL,[RNDC+2]
   75	 0038  32 FF	 	 	        XOR     BH,BH           ;Extended 24-bit number to 32 bits for NORM
   76	 003A  8B D7	 	 	        MOV     DX,DI           ;Number in BX:DX
   77	 003C  89 16 0008 R	 	        MOV     [RNDX],DX       ;Save for next time
   78	 0040  89 1E 000A R	 	        MOV     [RNDX+2],BX
   79	 0044	 	 	 	MAKNUM:
   80	 0044  B8 8800	 	 	        MOV     AX,8800H        ;Positive sign, exponent of +8
   81	 0047  E9 0000 E	 	        JMP     $SNORM          ;Normalize to the FAC
   82	 	 	 	 	
   83	 004A	 	 	 	SAMNUM:
   84	 004A  8B 16 0008 R	 	        MOV     DX,[RNDX]       ;Get previous random number
   85	 004E  8B 1E 000A R	 	        MOV     BX,[RNDX+2]
   86	 0052  EB F0	 	 	        JMP     MAKNUM
   87	 	 	 	 	
   88	 0054	 	 	 	NEWSEED:
   89	 0054  8B 17	 	 	        MOV     DX,[BX]
   90	 0056  8B 47 02	 	 	        MOV     AX,[BX+2]
   91	 0059  02 D4	 	 	        ADD     DL,AH           ;Fold exponent into least significant byte
   92	 005B  80 D6 00	 	 	        ADC     DH,0
   93	 005E  14 00	 	 	        ADC     AL,0
   94	 0060  32 E4	 	 	        XOR     AH,AH           ;New seed in AX:DX
   95	 0062  89 16 0008 R	 	        MOV     [RNDX],DX
   96	 0066  A3 000A R	 	        MOV     [RNDX+2],AX
   97	 0069  EB A9	 	 	        JMP     NEWRAND
   98	 	 	 	 	
   99	 	 	 	 	
  100	 	 	 	 	;***  $RZ0 & $RZ1 - RANDOMIZE statements
  101	 	 	 	 	;
  102	 	 	 	 	; Inputs:
  103	 	 	 	 	;       BX = new seed value ($RZ1 only)
  104	 	 	 	 	; Function:
  105	 	 	 	 	;       Reseed the pseudo-random number generator. $RZ0 prompts for a value
  106	 	 	 	 	;       in range -32768 to 32767 as the seed; $RZ1 is passed the value in BX
  107	 	 	 	 	;       instead. The number is set into the middle word of the current random
  108	 	 	 	 	;       number as the seed for the next one.


RANDOM - Random number generator and RANDOMIZE           Macro-86 %1(12)   1:7:46  13-Nov-81    Page 1-3



  109	 	 	 	 	; Outputs:
  110	 	 	 	 	;       None.
  111	 	 	 	 	; Registers:
  112	 	 	 	 	;       Only F affected.
  113	 	 	 	 	
  114	 006B	 	 	 	$RZ0:
  115	 006B  E8 0000 E	 	        CALL    $SAVREG
  116	 006E  BB 0030 R	 	        MOV     BX,OFFSET DC:RANDMES
  117	 0071  9A 0000 ---- E	 	        CALL    $IN0A           ;Fake an INPUT statement
  118	 0076  00	 	 	        DB      0               ;Add "?" and CR/LF
  119	 0077  9A 0000 ---- E	 	        CALL    $IPUA
  120	 007C  01	 	 	        DB      1               ;One value
  121	 007D  04	 	 	        DB      4               ;Type integer
  122	 007E  BB 0009 R	 	        MOV     BX,OFFSET DC:RNDX+1
  123	 0081  9A 0000 ---- E	 	        CALL    $IPUB           ;Assign value to middle word of RNDX
  124	 0086  C3	 	 	        RET
  125	 	 	 	 	
  126	 0087	 	 	 	$RZ1    PROC    FAR
  127	 0087  89 1E 0009 R	 	        MOV     [RNDX+1],BX
  128	 008B  CB	 	 	        RET
  129	 008C	 	 	 	$RZ1    ENDP
  130	 	 	 	 	
  131	 008C	 	 	 	CODE    ENDS
  132	 	 	 	 	        END
































RANDOM - Random number generator and RANDOMIZE           Macro-86 %1(12)   1:7:46  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	008C	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'
  CONST. . . . . . . . . . . . . .	0034	WORD  	PUBLIC	'CONST'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

MAKNUM . . . . . . . . . . . . .	L NEAR 	0044	CODE
NEWRAND. . . . . . . . . . . . .	L NEAR 	0014	CODE
NEWSEED. . . . . . . . . . . . .	L NEAR 	0054	CODE
PROMPT . . . . . . . . . . . . .	L BYTE 	000C	CONST
RANDMES. . . . . . . . . . . . .	L WORD 	0030	CONST
RNDA . . . . . . . . . . . . . .	L WORD 	0000	CONST
RNDC . . . . . . . . . . . . . .	L WORD 	0004	CONST
RNDX . . . . . . . . . . . . . .	L WORD 	0008	CONST
SAMNUM . . . . . . . . . . . . .	L NEAR 	004A	CODE
$IN0A. . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$IPUA. . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$IPUB. . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$RA0 . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$RAN . . . . . . . . . . . . . .	L NEAR 	0005	CODE	Global
$RZ0 . . . . . . . . . . . . . .	L NEAR 	006B	CODE	Global
$RZ1 . . . . . . . . . . . . . .	F PROC	0087	CODE	Global	Length =0005
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SNORM . . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0





















