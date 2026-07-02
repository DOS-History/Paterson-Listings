FOUT - Free-format numeric output                        Macro-86 %1(12)   1:1:36  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   FOUT - Free-format numeric output
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   VALTYP:BYTE, SIGN:BYTE, $AC:WORD, $DAC:WORD, $$SPSV:WORD
    6	 	 	 	 	
    7	 0000	 	 	 	DATA    ENDS
    8	 	 	 	 	
    9	 	 	 	 	DC      GROUP   DATA
   10	 	 	 	 	
   11	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   12	 	 	 	 	
   13	 	 	 	 	        PUBLIC  $FOUT, $FOUTBX, $STI, $STR, $STD
   14	 	 	 	 	
   15	 	 	 	 	        EXTRN   CONASC:NEAR, ASCRND:NEAR, $$CTS:NEAR
   16	 	 	 	 	
   17	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   18	 	 	 	 	
   19	 	 	 	 	
   20	 0000	 	 	 	STRF    PROC    FAR
   21	 	 	 	 	
   22	 	 	 	 	;***  $STI, $STR, $STD - STR$ function
   23	 	 	 	 	;
   24	 	 	 	 	; Inputs:
   25	 	 	 	 	;       BX = Integer ($STI only)
   26	 	 	 	 	;       BX = Address of number ($STR and $STD)
   27	 	 	 	 	; Function:
   28	 	 	 	 	;       Create a string representing the number in ASCII
   29	 	 	 	 	; Outputs:
   30	 	 	 	 	;       BX = Address of string descriptor
   31	 	 	 	 	; Registers:
   32	 	 	 	 	;       Only BX and F affected.
   33	 	 	 	 	
   34	 0000	 	 	 	$STI:
   35	 0000  C6 06 0000 E 02	 	        MOV     [VALTYP],2
   36	 0005  EB 0C	 	 	        JMP     SHORT STR$
   37	 	 	 	 	
   38	 0007	 	 	 	$STR:
   39	 0007  C6 06 0000 E 04	 	        MOV     [VALTYP],4
   40	 000C  EB 05	 	 	        JMP     SHORT STR$
   41	 	 	 	 	
   42	 000E	 	 	 	$STD:
   43	 000E  C6 06 0000 E 08	 	        MOV     [VALTYP],8
   44	 0013	 	 	 	STR$:
   45	 0013  89 26 0000 E	 	        MOV     [$$SPSV],SP
   46	 0017  FF 36 0000 E	 	        PUSH    [$DAC]          ;Save DAC
   47	 001B  FF 36 0002 E	 	        PUSH    [$DAC+2]
   48	 001F  FF 36 0004 E	 	        PUSH    [$DAC+4]
   49	 0023  FF 36 0006 E	 	        PUSH    [$DAC+6]
   50	 0027  50	 	 	        PUSH    AX
   51	 0028  51	 	 	        PUSH    CX
   52	 0029  52	 	 	        PUSH    DX
   53	 002A  56	 	 	        PUSH    SI
   54	 002B  57	 	 	        PUSH    DI


FOUT - Free-format numeric output                        Macro-86 %1(12)   1:1:36  13-Nov-81    Page 1-2



   55	 002C  55	 	 	        PUSH    BP
   56	 002D  E8 004D R	 	        CALL    $FOUTBX
   57	 0030  93	 	 	        XCHG    AX,BX           ;Get length in BX
   58	 0031  8B D6	 	 	        MOV     DX,SI           ;Get address in DX
   59	 0033  E8 0000 E	 	        CALL    $$CTS           ;Create temp string
   60	 0036  5D	 	 	        POP     BP
   61	 0037  5F	 	 	        POP     DI
   62	 0038  5E	 	 	        POP     SI
   63	 0039  5A	 	 	        POP     DX
   64	 003A  59	 	 	        POP     CX
   65	 003B  58	 	 	        POP     AX
   66	 003C  8F 06 0006 E	 	        POP     [$DAC+6]
   67	 0040  8F 06 0004 E	 	        POP     [$DAC+4]
   68	 0044  8F 06 0002 E	 	        POP     [$DAC+2]
   69	 0048  8F 06 0000 E	 	        POP     [$DAC]
   70	 004C  CB	 	 	        RET
   71	 	 	 	 	
   72	 004D	 	 	 	STRF    ENDP
   73	 	 	 	 	
   74	 	 	 	 	
   75	 	 	 	 	;***  $FOUT & $FOUTBX - Free-format numeric output
   76	 	 	 	 	;
   77	 	 	 	 	; Inputs:
   78	 	 	 	 	;       Number in FAC to be formatted for output ($FOUT only)
   79	 	 	 	 	;       BX = Number to be formatted ($FOUTBX only)
   80	 	 	 	 	;       [VALTYP] = 2 for integer, 4 for SP, 8 for DP
   81	 	 	 	 	; Function:
   82	 	 	 	 	;       Format number for printing, using BASIC's formatting rules.
   83	 	 	 	 	; Outputs:
   84	 	 	 	 	;       SI = Address of ASCII string, terminated by 00
   85	 	 	 	 	;       AX = Length of string (not including terminating 00)
   86	 	 	 	 	; Registers:
   87	 	 	 	 	;       All destroyed.
   88	 	 	 	 	
   89	 004D	 	 	 	$FOUTBX:
   90	 004D  A0 0000 E	 	        MOV     AL,[VALTYP]
   91	 0050  3C 02	 	 	        CMP     AL,2
   92	 0052  74 0F	 	 	        JZ      STOINT
   93	 0054  98	 	 	        CBW                     ;Number of bytes to move
   94	 0055  8B F3	 	 	        MOV     SI,BX
   95	 0057  BF 0004 E	 	        MOV     DI,OFFSET DC:$AC+4
   96	 005A  2B F8	 	 	        SUB     DI,AX           ;AC or DAC
   97	 005C  91	 	 	        XCHG    AX,CX
   98	 005D  D1 E9	 	 	        SHR     CX,1            ;Count of words
   99	 005F  F3/ A5	 	 	        REP     MOVSW
  100	 0061  EB 04	 	 	        JMP     SHORT $FOUT
  101	 0063	 	 	 	STOINT:
  102	 0063  89 1E 0000 E	 	        MOV     [$AC],BX
  103	 0067	 	 	 	$FOUT:
  104	 0067  E8 0000 E	 	        CALL    CONASC          ;Most of the work's done here
  105	 	 	 	 	
  106	 	 	 	 	;Number has been converted to ASCII and is sitting at buffer pointed to by DI.
  107	 	 	 	 	;       SI = address of result buffer
  108	 	 	 	 	;       CX = number of significant figures


FOUT - Free-format numeric output                        Macro-86 %1(12)   1:1:36  13-Nov-81    Page 1-3



  109	 	 	 	 	;       DL has the base 10 exponent of the right end of the digit string.
  110	 	 	 	 	
  111	 006A  BB F907	 	 	        MOV     BX,-700H+7      ;If SP, use 7 digits, but limit 7 to right
  112	 006D  80 3E 0000 E 04	 	        CMP     [VALTYP],4      ;What type?
  113	 0072  76 03	 	 	        JBE     RNDDIG          ;If integer or SP, use SP parameters
  114	 0074  BB F010	 	 	        MOV     BX,-1000H+16    ;For DP, use 16 digits, and limit 16 to right
  115	 0077	 	 	 	RNDDIG:
  116	 0077  8A C3	 	 	        MOV     AL,BL
  117	 0079  E8 0000 E	 	        CALL    ASCRND          ;Round to AL digits
  118	 007C  3A D7	 	 	        CMP     DL,BH           ;Too many digits to right of decimal point?
  119	 007E  7C 33	 	 	        JL      SCINOT          ;If so, use scientific notation
  120	 0080  8A C2	 	 	        MOV     AL,DL
  121	 0082  02 C1	 	 	        ADD     AL,CL           ;AL=number of digits to left of dec.pt.
  122	 0084  3A C3	 	 	        CMP     AL,BL           ;Too many?
  123	 0086  7F 2B	 	 	        JG      SCINOT          ;If so, use scientific notation
  124	 0088  98	 	 	        CBW
  125	 0089  91	 	 	        XCHG    AX,CX           ;CX has digits needed to left of dec. pt.
  126	 008A  93	 	 	        XCHG    AX,BX           ;BX has digits available from buffer
  127	 008B  0B C9	 	 	        OR      CX,CX           ;Any to left?
  128	 008D  7E 20	 	 	        JLE     LESS1           ;If not, start with decimal point
  129	 008F	 	 	 	LEFTDP:
  130	 008F  A4	 	 	        MOVSB                   ;Move digits to final buffer
  131	 0090  4B	 	 	        DEC     BX              ;Limit to available digits
  132	 0091  E0 FC	 	 	        LOOPNZ  LEFTDP
  133	 0093  B0 30	 	 	        MOV     AL,"0"
  134	 0095  F3/ AA	 	 	        REP     STOSB           ;Fill in with place-holding zeros if needed
  135	 0097  74 0B	 	 	        JZ      PUTEND          ;If out of digits, were done(flags from DEC BX)
  136	 0099	 	 	 	PUTDP:
  137	 0099  B0 2E	 	 	        MOV     AL,"."
  138	 009B  AA	 	 	        STOSB                   ;Put in decimal point
  139	 009C  B0 30	 	 	        MOV     AL,"0"          ;Used only if we came from LESS1
  140	 009E  F3/ AA	 	 	        REP     STOSB           ;Add leading zeros if a small number
  141	 00A0  8B CB	 	 	        MOV     CX,BX           ;Number of digits left
  142	 00A2  F3/ A4	 	 	        REP     MOVSB
  143	 00A4	 	 	 	PUTEND:
  144	 00A4  BE 0000 E	 	        MOV     SI,OFFSET DC:SIGN  ;Leave pointer to buffer
  145	 00A7  8B C7	 	 	        MOV     AX,DI
  146	 00A9  2B C6	 	 	        SUB     AX,SI           ;Length of string
  147	 00AB  C6 05 00	 	 	        MOV     BYTE PTR[DI],0  ;Put in terminating zero
  148	 00AE  C3	 	 	        RET
  149	 	 	 	 	
  150	 00AF	 	 	 	LESS1:
  151	 	 	 	 	;Come here if number is less than one and therefore has no digits to
  152	 	 	 	 	;left of the decimal point.
  153	 00AF  F7 D9	 	 	        NEG     CX              ;Number of place-holding zeros needed
  154	 00B1  EB E6	 	 	        JMP     PUTDP           ;   after the decimal point
  155	 	 	 	 	
  156	 00B3	 	 	 	SCINOT:
  157	 00B3  A4	 	 	        MOVSB                   ;Move first digit to final buffer
  158	 00B4  49	 	 	        DEC     CX              ;Account for digit already moved
  159	 00B5  74 07	 	 	        JZ      EXP             ;Skip decimal point if only one digit
  160	 00B7  B0 2E	 	 	        MOV     AL,"."
  161	 00B9  AA	 	 	        STOSB
  162	 00BA  02 D1	 	 	        ADD     DL,CL           ;Correct exponent for decimal point position


FOUT - Free-format numeric output                        Macro-86 %1(12)   1:1:36  13-Nov-81    Page 1-4



  163	 00BC  F3/ A4	 	 	        REP     MOVSB           ;All other digits go after decimal point
  164	 00BE	 	 	 	EXP:
  165	 00BE  B8 2B45	 	 	        MOV     AX,"+E"         ;Prepare "E+" if positive exponent
  166	 00C1  0A D2	 	 	        OR      DL,DL           ;Check exponent sign
  167	 00C3  79 04	 	 	        JNS     POSEXP
  168	 00C5  F6 DA	 	 	        NEG     DL              ;Force exponent positive
  169	 00C7  B4 2D	 	 	        MOV     AH,"-"
  170	 00C9	 	 	 	POSEXP:
  171	 00C9  AB	 	 	        STOSW
  172	 00CA  92	 	 	        XCHG    AX,DX           ;Get exponent in AL
  173	 00CB  D4 0A	 	 	        AAM                     ;Convert binary to unpacked BCD
  174	 00CD  86 C4	 	 	        XCHG    AL,AH
  175	 00CF  0D 3030	 	 	        OR      AX,"00"         ;Add ASCII bias
  176	 00D2  AB	 	 	        STOSW
  177	 00D3  EB CF	 	 	        JMP     PUTEND
  178	 	 	 	 	
  179	 00D5	 	 	 	CODE    ENDS
  180	 	 	 	 	
  181	 	 	 	 	        END





































FOUT - Free-format numeric output                        Macro-86 %1(12)   1:1:36  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	00D5	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ASCRND . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
CONASC . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
EXP. . . . . . . . . . . . . . .	L NEAR 	00BE	CODE
LEFTDP . . . . . . . . . . . . .	L NEAR 	008F	CODE
LESS1. . . . . . . . . . . . . .	L NEAR 	00AF	CODE
POSEXP . . . . . . . . . . . . .	L NEAR 	00C9	CODE
PUTDP. . . . . . . . . . . . . .	L NEAR 	0099	CODE
PUTEND . . . . . . . . . . . . .	L NEAR 	00A4	CODE
RNDDIG . . . . . . . . . . . . .	L NEAR 	0077	CODE
SCINOT . . . . . . . . . . . . .	L NEAR 	00B3	CODE
SIGN . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
STOINT . . . . . . . . . . . . .	L NEAR 	0063	CODE
STR$ . . . . . . . . . . . . . .	L NEAR 	0013	CODE
STRF . . . . . . . . . . . . . .	F PROC	0000	CODE	Length =004D
VALTYP . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$$CTS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$FOUT. . . . . . . . . . . . . .	L NEAR 	0067	CODE	Global
$FOUTBX. . . . . . . . . . . . .	L NEAR 	004D	CODE	Global
$STD . . . . . . . . . . . . . .	L NEAR 	000E	CODE	Global
$STI . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$STR . . . . . . . . . . . . . .	L NEAR 	0007	CODE	Global

Warning Severe
Errors	Errors 
0	0
















