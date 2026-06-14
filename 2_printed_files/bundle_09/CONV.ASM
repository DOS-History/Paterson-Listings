CONV - Conversions between single, double, and integer   Macro-86 %1(12)   0:59:2  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   CONV - Conversions between single, double, and integer
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $FAC:WORD, $AC:WORD, $DAC:WORD, $$SPSV:WORD
    6	 	 	 	 	
    7	 0000	 	 	 	DATA    ENDS
    8	 	 	 	 	
    9	 	 	 	 	DC      GROUP   DATA
   10	 	 	 	 	
   11	 0000	 	 	 	CODE    SEGMENT WORD PUBLIC 'CODE'
   12	 	 	 	 	
   13	 	 	 	 	        PUBLIC  $CDPA,$CDPB,$CISA,$CIDA,$CSPA,$CSPB
   14	 	 	 	 	 	PUBLIC  $CINA,$CINB,$CINC,$CIND,$CINFAC
   15	 	 	 	 	        PUBLIC  $C8IA,$C8IB,$C8IC,$C8ID
   16	 	 	 	 	        PUBLIC  $ADCA,$ADCB,$ADC,$V8IA
   17	 	 	 	 	
   18	 	 	 	 	        EXTRN   $SNORM:NEAR, $SRND:NEAR, $OVFL:NEAR, $ERR_FC:NEAR
   19	 	 	 	 	
   20	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   21	 	 	 	 	
   22	 0000	 	 	 	CONV    PROC    FAR
   23	 	 	 	 	
   24	 0000	 	 	 	$CDPA:
   25	 	 	 	 	;Convert SP at [SI] to DP in FAC
   26	 0000  57	 	 	        PUSH    DI
   27	 0001  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   28	 0004  A5	 	 	        MOVSW                   ;Copy to FAC
   29	 0005  A5	 	 	        MOVSW
   30	 0006  5F	 	 	        POP     DI
   31	 0007  83 EE 04	 	 	        SUB     SI,4
   32	 000A	 	 	 	$CDPB:
   33	 	 	 	 	;Convert SP in FAC to DP
   34	 000A  C7 06 0000 E 0000	        MOV     [$DAC],0
   35	 0010  C7 06 0002 E 0000	        MOV     [$DAC+2],0
   36	 0016  CB	 	 	        RET
   37	 	 	 	 	
   38	 0017	 	 	 	$CISA:
   39	 	 	 	 	;Convert integer in BX to SP
   40	 0017	 	 	 	$CIDA:
   41	 	 	 	 	;Convert integer in BX to DP
   42	 0017  53	 	 	        PUSH    BX
   43	 0018  52	 	 	        PUSH    DX
   44	 0019  50	 	 	        PUSH    AX
   45	 001A  B8 9000	 	 	        MOV     AX,9000H        ;Set exponent to 16
   46	 001D  0A C7	 	 	        OR      AL,BH           ;Get sign
   47	 001F  79 02	 	 	        JNS     POS             ;Already positive
   48	 0021  F7 DB	 	 	        NEG     BX              ;Need magnitude
   49	 0023	 	 	 	POS:
   50	 0023  33 D2	 	 	        XOR     DX,DX
   51	 0025  E8 0000 E	 	        CALL    $SNORM
   52	 0028  58	 	 	        POP     AX
   53	 0029  5A	 	 	        POP     DX
   54	 002A  5B	 	 	        POP     BX


CONV - Conversions between single, double, and integer   Macro-86 %1(12)   0:59:2  13-Nov-81    Page 1-2



   55	 002B  EB DD	 	 	        JMP     $CDPB           ;Convert to DP just in case
   56	 	 	 	 	
   57	 002D	 	 	 	$CSPA:
   58	 	 	 	 	;Convert DP at [SI] to SP in FAC
   59	 002D  57	 	 	        PUSH    DI
   60	 002E  BF 0000 E	 	        MOV     DI,OFFSET $DAC
   61	 0031  A5	 	 	        MOVSW
   62	 0032  A5	 	 	        MOVSW
   63	 0033  A5	 	 	        MOVSW
   64	 0034  A5	 	 	        MOVSW
   65	 0035  5F	 	 	        POP     DI
   66	 0036  83 EE 08	 	 	        SUB     SI,8
   67	 0039	 	 	 	$CSPB:
   68	 	 	 	 	;Convert DP in FAC to SP
   69	 0039  53	 	 	        PUSH    BX
   70	 003A  52	 	 	        PUSH    DX
   71	 003B  50	 	 	        PUSH    AX
   72	 003C  8B 1E FFFE E	 	        MOV     BX,[$FAC-2]
   73	 0040  80 CF 80	 	 	        OR      BH,80H          ;Set implied bit
   74	 0043  8B 16 FFFC E	 	        MOV     DX,[$FAC-4]
   75	 0047  A1 0000 E	 	        MOV     AX,[$DAC]
   76	 004A  0A C4	 	 	        OR      AL,AH           ;OR together all insignificant bits
   77	 004C  0A 06 0002 E	 	        OR      AL,[$DAC+2]
   78	 0050  74 03	 	 	        JZ      NOSTICK
   79	 0052  80 CA 01	 	 	        OR      DL,1            ;Set sticky bit if any were one
   80	 0055	 	 	 	NOSTICK:
   81	 0055  A1 FFFF E	 	        MOV     AX,[$FAC-1]     ;Get sign and exponent
   82	 0058  E8 0000 E	 	        CALL    $SRND
   83	 005B  58	 	 	        POP     AX
   84	 005C  5A	 	 	        POP     DX
   85	 005D  5B	 	 	        POP     BX
   86	 005E  CB	 	 	        RET
   87	 	 	 	 	
   88	 	 	 	 	
   89	 	 	 	 	;***  CINT - Round real to integer
   90	 	 	 	 	;
   91	 	 	 	 	; Inputs:
   92	 	 	 	 	;       Single or double precision number in FAC or at [SI]
   93	 	 	 	 	; Function:
   94	 	 	 	 	;       Convert by rounding to integer
   95	 	 	 	 	; Outputs:
   96	 	 	 	 	;       BX = FAC = rounded integer
   97	 	 	 	 	; Registers:
   98	 	 	 	 	;       Only BX and F affected.
   99	 	 	 	 	
  100	 005F	 	 	 	$C8IA:
  101	 005F	 	 	 	$CINA:  ;Single precision, operand at [SI]
  102	 005F  89 26 0000 E	 	        MOV     [$$SPSV],SP
  103	 0063  50	 	 	        PUSH    AX
  104	 0064  51	 	 	        PUSH    CX
  105	 0065  8B 44 02	 	 	        MOV     AX,[SI+2]       ;Get exponent
  106	 0068  8B 0C	 	 	        MOV     CX,[SI]         ;Get mantissa
  107	 006A  EB 1B	 	 	        JMP     SHORT CINT
  108	 	 	 	 	


CONV - Conversions between single, double, and integer   Macro-86 %1(12)   0:59:2  13-Nov-81    Page 1-3



  109	 006C	 	 	 	$C8IB:
  110	 006C	 	 	 	$CINB:  ;Double precision, operand at [SI]
  111	 006C  89 26 0000 E	 	        MOV     [$$SPSV],SP
  112	 0070  50	 	 	        PUSH    AX
  113	 0071  51	 	 	        PUSH    CX
  114	 0072  8B 44 06	 	 	        MOV     AX,[SI+6]       ;Get exponent
  115	 0075  8B 4C 04	 	 	        MOV     CX,[SI+4]       ;Get mantissa
  116	 0078  EB 0D	 	 	        JMP     SHORT CINT
  117	 	 	 	 	
  118	 007A	 	 	 	$C8IC:
  119	 007A	 	 	 	$C8ID:
  120	 007A	 	 	 	$CINC:  ;Single precision, operand in FAC
  121	 007A	 	 	 	$CIND:  ;Double precision uses same routine
  122	 007A  89 26 0000 E	 	        MOV     [$$SPSV],SP
  123	 007E	 	 	 	$CINFAC:
  124	 007E  50	 	 	        PUSH    AX
  125	 007F  51	 	 	        PUSH    CX
  126	 0080  A1 0002 E	 	        MOV     AX,[$AC+2]      ;Get exponent
  127	 0083  8B 0E 0000 E	 	        MOV     CX,[$AC]        ;Get mantissa
  128	 0087	 	 	 	CINT:
  129	 0087  33 DB	 	 	        XOR     BX,BX           ;Set up zero result
  130	 0089  80 EC 80	 	 	        SUB     AH,80H          ;Take bias out of exponent
  131	 008C  72 23	 	 	        JB      CXRET           ;Return zero if no integer part
  132	 008E  8A F8	 	 	        MOV     BH,AL           ;Highest byte of mantissa
  133	 0090  8A DD	 	 	        MOV     BL,CH
  134	 0092  91	 	 	        XCHG    AX,CX
  135	 0093  B1 10	 	 	        MOV     CL,16
  136	 0095  2A CD	 	 	        SUB     CL,CH           ;Number of bits to shift mantissa right
  137	 0097  8A E7	 	 	        MOV     AH,BH           ;Save sign
  138	 0099  72 27	 	 	        JB      OVERFLOW        ;If negative shift, it won't fit in 16 bits
  139	 009B  74 1B	 	 	        JZ      OVCHK           ;Only -32768 has 16 bits - go check for it
  140	 009D  80 CF 80	 	 	        OR      BH,80H          ;Set implied bit
  141	 00A0  D3 EB	 	 	        SHR     BX,CL           ;Position the integer
  142	 00A2  83 D3 00	 	 	        ADC     BX,0            ;Perform rounding
  143	 00A5  0A E4	 	 	        OR      AH,AH           ;Check sign now
  144	 00A7  79 02	 	 	        JNS     NOTNEG
  145	 00A9  F7 DB	 	 	        NEG     BX
  146	 00AB	 	 	 	NOTNEG:
  147	 00AB  F6 D4	 	 	        NOT     AH              ;Bit 7 set if positive
  148	 00AD  22 E7	 	 	        AND     AH,BH           ;Bit 7 set if number positive, >=32768
  149	 00AF  78 11	 	 	        JS      OVERFLOW
  150	 00B1	 	 	 	CXRET:
  151	 00B1  59	 	 	        POP     CX
  152	 00B2  58	 	 	        POP     AX
  153	 00B3  89 1E 0000 E	 	        MOV     [$AC],BX        ;Result in both FAC and BX
  154	 00B7  CB	 	 	        RET
  155	 	 	 	 	
  156	 00B8	 	 	 	OVCHK:
  157	 	 	 	 	;Come here if no shift is needed on the number, i.e., it requires a full
  158	 	 	 	 	;16 bits. Only -32768 (8000H) is allowed.
  159	 00B8  81 FB 8000	 	        CMP     BX,8000H        ;The 1 is sign bit (negative), not implied bit
  160	 00BC  75 04	 	 	        JNZ     OVERFLOW
  161	 00BE  A8 80	 	 	        TEST    AL,80H          ;Should we be rounding up?
  162	 00C0  74 EF	 	 	        JZ      CXRET           ;If so, that causes overflow


CONV - Conversions between single, double, and integer   Macro-86 %1(12)   0:59:2  13-Nov-81    Page 1-4



  163	 00C2	 	 	 	OVERFLOW:
  164	 00C2  E9 0000 E	 	        JMP     $OVFL
  165	 	 	 	 	
  166	 	 	 	 	
  167	 	 	 	 	;***  $ADCA, $ADCB - Convert SP to address
  168	 	 	 	 	;
  169	 	 	 	 	; Inputs:
  170	 	 	 	 	;       SI = Address of SP number ($ADCA only)
  171	 	 	 	 	;       FAC = SP number ($ADCB only)
  172	 	 	 	 	; Function:
  173	 	 	 	 	;       Convert to 16-bit integer in range -32768 to +65535, with rounding.
  174	 	 	 	 	; Outputs:
  175	 	 	 	 	;       Result in BX.
  176	 	 	 	 	; Registers:
  177	 	 	 	 	;       Only BX and F affected.
  178	 	 	 	 	
  179	 00C5	 	 	 	$ADCA:
  180	 00C5  89 26 0000 E	 	        MOV     [$$SPSV],SP
  181	 00C9	 	 	 	$ADC:
  182	 00C9  50	 	 	        PUSH    AX
  183	 00CA  51	 	 	        PUSH    CX
  184	 00CB  8B 44 02	 	 	        MOV     AX,[SI+2]       ;Get exponent
  185	 00CE  8B 0C	 	 	        MOV     CX,[SI]         ;Get mantissa
  186	 00D0  EB 0D	 	 	        JMP     SHORT ADDR
  187	 	 	 	 	
  188	 00D2	 	 	 	$ADCB:
  189	 00D2  89 26 0000 E	 	        MOV     [$$SPSV],SP
  190	 00D6  50	 	 	        PUSH    AX
  191	 00D7  51	 	 	        PUSH    CX
  192	 00D8  A1 0002 E	 	        MOV     AX,[$AC+2]      ;Get exponent
  193	 00DB  8B 0E 0000 E	 	        MOV     CX,[$AC]        ;Get mantissa
  194	 00DF	 	 	 	ADDR:
  195	 00DF  80 FC 90	 	 	        CMP     AH,90H          ;In range 32768-65535?
  196	 00E2  75 A3	 	 	        JNZ     CINT            ;If not, CINT can do it
  197	 00E4  0A C0	 	 	        OR      AL,AL           ;Is it negative?
  198	 00E6  78 9F	 	 	        JS      CINT            ;If so, same as CINT
  199	 	 	 	 	;Have a positive number range 32768-65536.
  200	 00E8  0C 80	 	 	        OR      AL,80H          ;Set implied bit
  201	 00EA  8A F8	 	 	        MOV     BH,AL
  202	 00EC  8A DD	 	 	        MOV     BL,CH           ;Integer now in BX
  203	 00EE  D0 E1	 	 	        SHL     CL,1            ;Need to round up?
  204	 00F0  83 D3 00	 	 	        ADC     BX,0
  205	 00F3  73 BC	 	 	        JNC     CXRET
  206	 00F5  E9 0000 E	 	        JMP     $OVFL
  207	 	 	 	 	
  208	 00F8	 	 	 	$V8IA:
  209	 00F8  0A FF	 	 	        OR      BH,BH
  210	 00FA  75 01	 	 	        JNZ     FARG
  211	 00FC  CB	 	 	        RET
  212	 00FD  E9 0000 E	 	FARG:   JMP     $ERR_FC
  213	 	 	 	 	
  214	 0100	 	 	 	CONV    ENDP
  215	 0100	 	 	 	CODE    ENDS
  216	 	 	 	 	        END


CONV - Conversions between single, double, and integer   Macro-86 %1(12)   0:59:2  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0100	WORD  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ADDR . . . . . . . . . . . . . .	L NEAR 	00DF	CODE
CINT . . . . . . . . . . . . . .	L NEAR 	0087	CODE
CONV . . . . . . . . . . . . . .	F PROC	0000	CODE	Length =0100
CXRET. . . . . . . . . . . . . .	L NEAR 	00B1	CODE
FARG . . . . . . . . . . . . . .	L NEAR 	00FD	CODE
NOSTICK. . . . . . . . . . . . .	L NEAR 	0055	CODE
NOTNEG . . . . . . . . . . . . .	L NEAR 	00AB	CODE
OVCHK. . . . . . . . . . . . . .	L NEAR 	00B8	CODE
OVERFLOW . . . . . . . . . . . .	L NEAR 	00C2	CODE
POS. . . . . . . . . . . . . . .	L NEAR 	0023	CODE
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ADC . . . . . . . . . . . . . .	L NEAR 	00C9	CODE	Global
$ADCA. . . . . . . . . . . . . .	L NEAR 	00C5	CODE	Global
$ADCB. . . . . . . . . . . . . .	L NEAR 	00D2	CODE	Global
$C8IA. . . . . . . . . . . . . .	L NEAR 	005F	CODE	Global
$C8IB. . . . . . . . . . . . . .	L NEAR 	006C	CODE	Global
$C8IC. . . . . . . . . . . . . .	L NEAR 	007A	CODE	Global
$C8ID. . . . . . . . . . . . . .	L NEAR 	007A	CODE	Global
$CDPA. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$CDPB. . . . . . . . . . . . . .	L NEAR 	000A	CODE	Global
$CIDA. . . . . . . . . . . . . .	L NEAR 	0017	CODE	Global
$CINA. . . . . . . . . . . . . .	L NEAR 	005F	CODE	Global
$CINB. . . . . . . . . . . . . .	L NEAR 	006C	CODE	Global
$CINC. . . . . . . . . . . . . .	L NEAR 	007A	CODE	Global
$CIND. . . . . . . . . . . . . .	L NEAR 	007A	CODE	Global
$CINFAC. . . . . . . . . . . . .	L NEAR 	007E	CODE	Global
$CISA. . . . . . . . . . . . . .	L NEAR 	0017	CODE	Global
$CSPA. . . . . . . . . . . . . .	L NEAR 	002D	CODE	Global
$CSPB. . . . . . . . . . . . . .	L NEAR 	0039	CODE	Global
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ERR_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$OVFL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SNORM . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SRND. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$V8IA. . . . . . . . . . . . . .	L NEAR 	00F8	CODE	Global

Warning Severe
Errors	Errors 
0	0



