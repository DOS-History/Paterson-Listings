PUFOUT - PRINT USING output formatter                    Macro-86 %1(12)   1:7:27  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   PUFOUT - PRINT USING output formatter
    2	 	 	 	 	
    3	 	 	 	 	;Definition of bits in flag byte
    4	 	 	 	 	
    5	 = 0040	 	 	 	COMMABIT=       40H             ;Commas every 3 digits in integer part
    6	 = 0020	 	 	 	STARBIT=        20H             ;Fill with leading "*" instead of blanks
    7	 = 0010	 	 	 	DOLLARBIT=      10H             ;Floating "$" in front of number
    8	 = 0008	 	 	 	PLUSBIT=        8               ;Force "+" in positive
    9	 = 0004	 	 	 	TRAILING=       4               ;Put sign at end of number
   10	 = 0001	 	 	 	SCIBIT=         1               ;Use scientific notation
   11	 	 	 	 	
   12	 	 	 	 	
   13	 0000	 	 	 	DATA    SEGMENT BYTE PUBLIC 'DATA'
   14	 	 	 	 	
   15	 	 	 	 	        EXTRN   $DIGCNT:BYTE,SIGN:BYTE,FOBUF:BYTE,$PUFLAG:BYTE
   16	 	 	 	 	
   17	 =	 	 	 	DECDIG  EQU     $DIGCNT         ;No. of digits to right of D.P.
   18	 =	 	 	 	INTDIG  EQU     $DIGCNT+1       ;No. of digits to left of D.P.
   19	 =	 	 	 	FLAG    EQU     $PUFLAG         ;Specification flags
   20	 	 	 	 	
   21	 0000  ??	 	 	EXP     DB      ?
   22	 	 	 	 	
   23	 0001	 	 	 	DATA    ENDS
   24	 	 	 	 	
   25	 	 	 	 	
   26	 	 	 	 	DC      GROUP   DATA
   27	 	 	 	 	
   28	 	 	 	 	
   29	 0000	 	 	 	CODE    SEGMENT WORD PUBLIC 'CODE'
   30	 	 	 	 	
   31	 	 	 	 	        PUBLIC  $PUFOUT
   32	 	 	 	 	
   33	 	 	 	 	        EXTRN   CONASC:NEAR, ASCRND:NEAR
   34	 	 	 	 	
   35	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   36	 	 	 	 	
   37	 	 	 	 	
   38	 	 	 	 	;***  $PUFOUT - PRINT USING output formatter
   39	 	 	 	 	;
   40	 	 	 	 	; Inputs:
   41	 	 	 	 	;       [$DIGCNT+1] = field width to left of decimal point
   42	 	 	 	 	;       [$DIGCNT] = field width to right & including decimal point
   43	 	 	 	 	;       [FLAG] = Formatting flags (see equates above)
   44	 	 	 	 	;       [VALTYP] = Type of number
   45	 	 	 	 	;       Number in FAC
   46	 	 	 	 	; Function:
   47	 	 	 	 	;       Format the number according to PRINT USING specifications. Leave in
   48	 	 	 	 	;       a buffer terminated with a zero.
   49	 	 	 	 	; Outputs:
   50	 	 	 	 	;       SI = Address of first character of formatted output
   51	 	 	 	 	;       AX = Count of characters (not including terminating zero)
   52	 	 	 	 	; Registers:
   53	 	 	 	 	;       All registers affected.
   54	 	 	 	 	


PUFOUT - PRINT USING output formatter                    Macro-86 %1(12)   1:7:27  13-Nov-81    Page 1-2



   55	 0000	 	 	 	$PUFOUT:
   56	 0000  E8 0000 E	 	        CALL    CONASC          ;Convert to ASCII digits
   57	 0003	 	 	 	PUFOUT:
   58	 0003  33 DB	 	 	        XOR     BX,BX           ;No position-eating symbols yet
   59	 0005  A0 0000 E	 	        MOV     AL,[FLAG]       ;Get PRINT USING flags
   60	 0008  A8 10	 	 	        TEST    AL,DOLLARBIT    ;Need floating dollar sign?
   61	 000A  74 01	 	 	        JZ      NODOL
   62	 000C  43	 	 	        INC     BX              ;Chalk up a position for the "$"
   63	 000D	 	 	 	NODOL:
   64	 000D  80 3E 0000 E 2D	 	        CMP     [SIGN],"-"      ;Is number negative?
   65	 0012  74 09	 	 	        JZ      HAVSGN          ;If so, leave sign alone
   66	 0014  A8 08	 	 	        TEST    AL,PLUSBIT      ;Do we force "+"?
   67	 0016  74 0B	 	 	        JZ      NOSGN           ;No - leave it a blank
   68	 0018  C6 06 0000 E 2B	 	        MOV     [SIGN],"+"
   69	 001D	 	 	 	HAVSGN:
   70	 001D  A8 04	 	 	        TEST    AL,TRAILING     ;Is it in front, eating a digit position?
   71	 001F  75 02	 	 	        JNZ     NOSGN
   72	 0021  FE C7	 	 	        INC     BH              ;Count one position for the sign
   73	 0023	 	 	 	NOSGN:
   74	 0023  A8 01	 	 	        TEST    AL,SCIBIT       ;Scientific notation?
   75	 0025  75 2C	 	 	        JNZ     SCILEN
   76	 0027  02 DF	 	 	        ADD     BL,BH           ;Sum positions needed for sign and "$"
   77	 0029  8A C2	 	 	        MOV     AL,DL           ;Power of 10 of digit string
   78	 002B  02 C1	 	 	        ADD     AL,CL           ;Plus count of digits gives number of digits
   79	 	 	 	 	                                ;to left of decimal point
   80	 002D  8A 26 0000 E	 	        MOV     AH,[DECDIG]     ;Number of digits requested to right of d.p.
   81	 0031  FE CC	 	 	        DEC     AH              ;Count off one for decimal point itself
   82	 0033  7C 02	 	 	        JL      ROUND           ;Any decimal digits?
   83	 0035  02 C4	 	 	        ADD     AL,AH           ;Add to count of digits needed
   84	 0037	 	 	 	ROUND:
   85	 0037  0A C0	 	 	        OR      AL,AL
   86	 0039  7C 03	 	 	        JL      NOROUND         ;Don't ask for negative digits
   87	 003B  E8 0000 E	 	        CALL    ASCRND          ;Round ASCII digits
   88	 003E	 	 	 	NOROUND:
   89	 003E  80 3C 30	 	 	        CMP     BYTE PTR [SI],"0"  ;Is number zero?
   90	 0041  75 02	 	 	        JNZ     NOTZERO
   91	 0043  B2 FF	 	 	        MOV     DL,-1           ;If so, set exponent to no integer part
   92	 0045	 	 	 	NOTZERO:
   93	 0045  8B C1	 	 	        MOV     AX,CX           ;Number of digits in number now
   94	 0047  02 C2	 	 	        ADD     AL,DL           ;New count of integer digits
   95	 0049  8A F0	 	 	        MOV     DH,AL           ;Save it for output loop
   96	 004B  B4 00	 	 	        MOV     AH,0
   97	 004D  7F 42	 	 	        JG      COMCHK          ;If we have integer digits, do comma check
   98	 004F  B0 00	 	 	        MOV     AL,0            ;No integer digits
   99	 0051  EB 4E	 	 	        JMP     SHORT GETFILL
  100	 	 	 	 	
  101	 0053	 	 	 	SCILEN:
  102	 	 	 	 	;Compute digit counts and round for scientific notation
  103	 0053  A0 0001 E	 	        MOV     AL,[INTDIG]
  104	 0056  2A C3	 	 	        SUB     AL,BL           ;Count a digit position if "$" needed
  105	 0058  02 DF	 	 	        ADD     BL,BH           ;Sum positions needed for "$" and sign
  106	 005A  FE C8	 	 	        DEC     AL              ;Always take one for the sign
  107	 005C  79 02	 	 	        JNS     SCI1            ;If there's room, that is
  108	 005E  32 C0	 	 	        XOR     AL,AL


PUFOUT - PRINT USING output formatter                    Macro-86 %1(12)   1:7:27  13-Nov-81    Page 1-3



  109	 0060	 	 	 	SCI1:
  110	 0060  8A F8	 	 	        MOV     BH,AL           ;Save count of digits to left of d.p.
  111	 0062  A0 0000 E	 	        MOV     AL,[DECDIG]
  112	 0065  FE C8	 	 	        DEC     AL              ;Count one position for d.p. itself
  113	 0067  79 02	 	 	        JNS     SCI2
  114	 0069  32 C0	 	 	        XOR     AL,AL
  115	 006B	 	 	 	SCI2:
  116	 006B  02 C7	 	 	        ADD     AL,BH           ;Sum total digits needed
  117	 006D  7F 03	 	 	        JG      SCI3            ;Need at least one
  118	 006F  40	 	 	        INC     AX              ;Request one digit
  119	 0070  FE C7	 	 	        INC     BH              ;And print it to left of d.p.
  120	 0072	 	 	 	SCI3:
  121	 0072  E8 0000 E	 	        CALL    ASCRND          ;Round to correct number of digits
  122	 0075  80 3C 30	 	 	        CMP     BYTE PTR [SI],"0"  ;Is result zero?
  123	 0078  75 08	 	 	        JNZ     FIGEXP          ;If not, we're OK - go figure exponent
  124	 007A  32 C0	 	 	        XOR     AL,AL           ;Set exponent to zero
  125	 007C  0A FF	 	 	        OR      BH,BH           ;Print digits to left of d.p.?
  126	 007E  74 08	 	 	        JZ      SAVEXP          ;If not, that's O.K.
  127	 0080  B7 01	 	 	        MOV     BH,1            ;If so, print at most 1
  128	 0082	 	 	 	FIGEXP:
  129	 0082  8B C1	 	 	        MOV     AX,CX
  130	 0084  02 C2	 	 	        ADD     AL,DL           ;AL = Number of integer digits
  131	 0086  2A C7	 	 	        SUB     AL,BH           ;Subtract number to be printed left of d.p.
  132	 0088	 	 	 	SAVEXP:
  133	 0088  A2 0000 R	 	        MOV     [EXP],AL        ;Exponent to be printed later
  134	 008B  8A C7	 	 	        MOV     AL,BH           ;Set up digit count
  135	 008D  8A F7	 	 	        MOV     DH,BH
  136	 008F  EB 10	 	 	        JMP     SHORT GETFILL
  137	 	 	 	 	
  138	 0091	 	 	 	COMCHK:
  139	 0091  F6 06 0000 E 40	 	        TEST    [FLAG],COMMABIT ;Need commas?
  140	 0096  74 09	 	 	        JZ      GETFILL
  141	 	 	 	 	
  142	 	 	 	 	;Perform comma computation. We need a comma every 3 digits, so we'll divide
  143	 	 	 	 	;the number of digits by 3 to see how many we need. Since we don't need the
  144	 	 	 	 	;first comma until we have 4 digits, the digit count is decremented before
  145	 	 	 	 	;the division. The remainder of the division represents the number of digits
  146	 	 	 	 	;to print before the first comma is needed.
  147	 	 	 	 	
  148	 0098  48	 	 	        DEC     AX
  149	 0099  B7 03	 	 	        MOV     BH,3
  150	 009B  F6 F7	 	 	        DIV     BH              ;AL=number of commas
  151	 009D  02 C6	 	 	        ADD     AL,DH           ;Add up number of positions needed
  152	 009F  FE C4	 	 	        INC     AH              ;Adjust delay to first comma to range 1-3
  153	 	 	 	 	
  154	 	 	 	 	;Let's see if all this stuff will fit. If so, compute amount of extra room
  155	 	 	 	 	;for leading filler. Otherwise, print a "%".
  156	 	 	 	 	
  157	 00A1	 	 	 	GETFILL:
  158	 00A1  F6 06 0000 E 02	 	        TEST    [FLAG],2        ;Already had field overflow?
  159	 00A6  74 04	 	 	        JZ      FITCHK
  160	 00A8  C6 05 25	 	 	        MOV     BYTE PTR [DI],"%"
  161	 00AB  47	 	 	        INC     DI
  162	 00AC	 	 	 	FITCHK:


PUFOUT - PRINT USING output formatter                    Macro-86 %1(12)   1:7:27  13-Nov-81    Page 1-4



  163	 00AC  02 C3	 	 	        ADD     AL,BL           ;Add digits needed by "$" and sign
  164	 00AE  2A 06 0001 E	 	        SUB     AL,[INTDIG]     ;Do we have enough room?
  165	 00B2  76 11	 	 	        JBE     FILCNT          ;AL is negative of amount of extra room
  166	 00B4  3C 04	 	 	        CMP     AL,4            ;Exceeding width by more that 4?
  167	 00B6  76 08	 	 	        JBE     OVERFIELD
  168	 00B8  80 0E 0000 E 03	 	        OR      [FLAG],SCIBIT+2 ;Use scientific notation and set field overflow
  169	 00BD  E9 0003 R	 	        JMP     PUFOUT          ;Try again
  170	 00C0	 	 	 	OVERFIELD:
  171	 00C0  B0 25	 	 	        MOV     AL,"%"          ;Didn't fit - print field overflow character
  172	 00C2  AA	 	 	        STOSB
  173	 00C3  32 C0	 	 	        XOR     AL,AL           ;Zero fill count
  174	 	 	 	 	
  175	 	 	 	 	;Leading-fill field with blanks or "*"s as requested
  176	 	 	 	 	
  177	 00C5	 	 	 	FILCNT:
  178	 00C5  8A D4	 	 	        MOV     DL,AH           ;Save delay to first comma (zero if no commas)
  179	 00C7  74 08	 	 	        JZ      GETCNT          ;Any filling necessary?
  180	 00C9  0A F6	 	 	        OR      DH,DH           ;And do we have integer digits to print?
  181	 00CB  7F 04	 	 	        JG      GETCNT          ;If not, we'll add a leading zero
  182	 00CD  FE C0	 	 	        INC     AL              ;Make room by reducing fill count
  183	 00CF  FE C5	 	 	        INC     CH              ;Set leading zero flag
  184	 00D1	 	 	 	GETCNT:
  185	 00D1  F6 D8	 	 	        NEG     AL              ;Make fill count positive
  186	 00D3  98	 	 	        CBW
  187	 00D4  91	 	 	        XCHG    AX,CX           ;Put count in CX
  188	 00D5  93	 	 	        XCHG    AX,BX           ;Save digit count (from CX) in BX
  189	 00D6  B0 20	 	 	        MOV     AL," "          ;Fill character
  190	 00D8  8A 26 0000 E	 	        MOV     AH,[FLAG]       ;Get flag byte
  191	 00DC  F6 C4 20	 	 	        TEST    AH,STARBIT      ;Fill with "*" instead?
  192	 00DF  74 02	 	 	        JZ      FILL
  193	 00E1  B0 2A	 	 	        MOV     AL,"*"
  194	 00E3	 	 	 	FILL:
  195	 00E3  F3/ AA	 	 	        REP     STOSB           ;Leading fill
  196	 	 	 	 	
  197	 	 	 	 	;Print leading sign, if needed
  198	 	 	 	 	
  199	 00E5  F6 C4 04	 	 	        TEST    AH,TRAILING     ;Leading or trailing sign?
  200	 00E8  75 08	 	 	        JNZ     DOLLARCHK
  201	 00EA  A0 0000 E	 	        MOV     AL,[SIGN]       ;Pick up leading sign
  202	 00ED  3C 20	 	 	        CMP     AL," "          ;If blank, already counted in fill count
  203	 00EF  74 01	 	 	        JZ      DOLLARCHK
  204	 00F1  AA	 	 	        STOSB                   ;Store sign
  205	 	 	 	 	
  206	 	 	 	 	;Print floating "$" if requested
  207	 	 	 	 	
  208	 00F2	 	 	 	DOLLARCHK:
  209	 00F2  F6 C4 10	 	 	        TEST    AH,DOLLARBIT    ;Floating "$"
  210	 00F5  74 03	 	 	        JZ      NODOLLAR
  211	 00F7  B0 24	 	 	        MOV     AL,"$"
  212	 00F9  AA	 	 	        STOSB
  213	 00FA	 	 	 	NODOLLAR:
  214	 	 	 	 	
  215	 	 	 	 	;Copy integer digits, if any
  216	 	 	 	 	


PUFOUT - PRINT USING output formatter                    Macro-86 %1(12)   1:7:27  13-Nov-81    Page 1-5



  217	 00FA  8A CE	 	 	        MOV     CL,DH           ;Count of digits to left of d.p.
  218	 00FC  F6 DE	 	 	        NEG     DH              ;Count of zeros to fill after d.p.
  219	 00FE  7C 12	 	 	        JL      NOCOM           ;Don't check for comma first time through
  220	 0100  FE CF	 	 	        DEC     BH              ;Force leading zero?
  221	 0102  75 18	 	 	        JNZ     DPCHK
  222	 0104  B0 30	 	 	        MOV     AL,"0"
  223	 0106  AA	 	 	        STOSB
  224	 0107  EB 13	 	 	        JMP     SHORT DPCHK
  225	 	 	 	 	
  226	 0109	 	 	 	INTDIGITS:
  227	 0109  FE CA	 	 	        DEC     DL              ;Need a comma yet?
  228	 010B  75 05	 	 	        JNZ     NOCOM
  229	 010D  B0 2C	 	 	        MOV     AL,","
  230	 010F  AA	 	 	        STOSB
  231	 0110  B2 03	 	 	        MOV     DL,3            ;Reset comma count down
  232	 0112	 	 	 	NOCOM:
  233	 0112  B0 30	 	 	        MOV     AL,"0"          ;In case we're out of digits, use trailing "0"
  234	 0114  FE CB	 	 	        DEC     BL              ;Any digits left?
  235	 0116  78 01	 	 	        JS      STOINTDIG       ;No - go store trailing zero
  236	 0118  AC	 	 	        LODSB                   ;Yes - get next digit
  237	 0119	 	 	 	STOINTDIG:
  238	 0119  AA	 	 	        STOSB
  239	 011A  E2 ED	 	 	        LOOP    INTDIGITS
  240	 	 	 	 	
  241	 	 	 	 	;Check for fraction part and print decimal point if so
  242	 	 	 	 	
  243	 011C	 	 	 	DPCHK:
  244	 011C  8A 0E 0000 E	 	        MOV     CL,[DECDIG]     ;Number of digits to right of d.p.
  245	 0120  49	 	 	        DEC     CX              ;Count off decimal point itself
  246	 0121  78 1F	 	 	        JS      SCICHK          ;No decimal point?
  247	 0123  B0 2E	 	 	        MOV     AL,"."
  248	 0125  AA	 	 	        STOSB
  249	 0126  74 1A	 	 	        JZ      SCICHK          ;A d.p., but no decimal digits?
  250	 	 	 	 	
  251	 	 	 	 	;Print the zeros, if any, between after the decimal point but before the MSD
  252	 	 	 	 	
  253	 0128  0A F6	 	 	        OR      DH,DH           ;Any fill zeros after d.p.?
  254	 012A  7E 07	 	 	        JLE     MOVFRAC
  255	 012C  B0 30	 	 	        MOV     AL,"0"
  256	 012E	 	 	 	AFTDP:
  257	 012E  AA	 	 	        STOSB
  258	 012F  FE CE	 	 	        DEC     DH              ;Limit to fill count
  259	 0131  E0 FB	 	 	        LOOPNZ  AFTDP           ;Limit to field width
  260	 	 	 	 	
  261	 	 	 	 	;Print the fraction digits, if any
  262	 	 	 	 	
  263	 0133	 	 	 	MOVFRAC:
  264	 0133  E3 0D	 	 	        JCXZ    SCICHK          ;Filled out field width?
  265	 0135  0A DB	 	 	        OR      BL,BL           ;Any digits left?
  266	 0137  7E 05	 	 	        JLE     POSTFILL
  267	 0139	 	 	 	MOVDECDIG:
  268	 0139  A4	 	 	        MOVSB                   ;Copy a digit
  269	 013A  FE CB	 	 	        DEC     BL              ;Limit to digits available
  270	 013C  E0 FB	 	 	        LOOPNZ  MOVDECDIG       ;Limit to field width


PUFOUT - PRINT USING output formatter                    Macro-86 %1(12)   1:7:27  13-Nov-81    Page 1-6



  271	 	 	 	 	
  272	 	 	 	 	;Fill out the field with zeros
  273	 	 	 	 	
  274	 013E	 	 	 	POSTFILL:
  275	 013E  B0 30	 	 	        MOV     AL,"0"
  276	 0140  F3/ AA	 	 	        REP     STOSB           ;Force fill with zeros
  277	 	 	 	 	
  278	 	 	 	 	;Print exponent if in scientific notation
  279	 	 	 	 	
  280	 0142	 	 	 	SCICHK:
  281	 0142  F6 C4 01	 	 	        TEST    AH,SCIBIT       ;Scientific notation?
  282	 0145  74 1C	 	 	        JZ      SIGNCHK
  283	 0147  B0 45	 	 	        MOV     AL,"E"
  284	 0149  AA	 	 	        STOSB
  285	 014A  8A 1E 0000 R	 	        MOV     BL,[EXP]        ;Get exponent
  286	 014E  B0 2B	 	 	        MOV     AL,"+"          ;Assume it's positive for now
  287	 0150  0A DB	 	 	        OR      BL,BL
  288	 0152  79 04	 	 	        JNS     EXPSGN
  289	 0154  F6 DB	 	 	        NEG     BL              ;Get magnitude of exponent
  290	 0156  B0 2D	 	 	        MOV     AL,"-"          ;Display sign
  291	 0158	 	 	 	EXPSGN:
  292	 0158  AA	 	 	        STOSB
  293	 0159  93	 	 	        XCHG    AX,BX
  294	 015A  D4 0A	 	 	        AAM                     ;Convert exponent to unpacked BCD
  295	 015C  0D 3030	 	 	        OR      AX,"00"         ;Add ASCII bias
  296	 015F  86 C4	 	 	        XCHG    AL,AH           ;MSD in AL
  297	 0161  AB	 	 	        STOSW                   ;Save both digits at once
  298	 0162  93	 	 	        XCHG    AX,BX           ;Restore flags to AH
  299	 	 	 	 	
  300	 	 	 	 	;Print trailing sign if needed
  301	 	 	 	 	
  302	 0163	 	 	 	SIGNCHK:
  303	 0163  F6 C4 04	 	 	        TEST    AH,TRAILING     ;AH still has flags
  304	 0166  74 04	 	 	        JZ      ENDNUM          ;Need a trailing sign?
  305	 0168  A0 0000 E	 	        MOV     AL,[SIGN]
  306	 016B  AA	 	 	        STOSB
  307	 	 	 	 	
  308	 	 	 	 	;Finish up with trailing 00 and compute line length
  309	 	 	 	 	
  310	 016C	 	 	 	ENDNUM:
  311	 016C  32 C0	 	 	        XOR     AL,AL           ;Terminating zero
  312	 016E  AA	 	 	        STOSB
  313	 016F  BE 0000 E	 	        MOV     SI,OFFSET DC:FOBUF
  314	 0172  97	 	 	        XCHG    AX,DI
  315	 0173  2B C6	 	 	        SUB     AX,SI           ;Length of string
  316	 0175  C3	 	 	        RET
  317	 	 	 	 	
  318	 0176	 	 	 	CODE    ENDS
  319	 	 	 	 	        END







PUFOUT - PRINT USING output formatter                    Macro-86 %1(12)   1:7:27  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0176	WORD  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0001	BYTE  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

AFTDP. . . . . . . . . . . . . .	L NEAR 	012E	CODE
ASCRND . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
COMCHK . . . . . . . . . . . . .	L NEAR 	0091	CODE
COMMABIT . . . . . . . . . . . .	Number	0040	
CONASC . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
DECDIG . . . . . . . . . . . . .	Alias	$DIGCNT	 	
DOLLARBIT. . . . . . . . . . . .	Number	0010	
DOLLARCHK. . . . . . . . . . . .	L NEAR 	00F2	CODE
DPCHK. . . . . . . . . . . . . .	L NEAR 	011C	CODE
ENDNUM . . . . . . . . . . . . .	L NEAR 	016C	CODE
EXP. . . . . . . . . . . . . . .	L BYTE 	0000	DATA
EXPSGN . . . . . . . . . . . . .	L NEAR 	0158	CODE
FIGEXP . . . . . . . . . . . . .	L NEAR 	0082	CODE
FILCNT . . . . . . . . . . . . .	L NEAR 	00C5	CODE
FILL . . . . . . . . . . . . . .	L NEAR 	00E3	CODE
FITCHK . . . . . . . . . . . . .	L NEAR 	00AC	CODE
FLAG . . . . . . . . . . . . . .	Alias	$PUFLAG	 	
FOBUF. . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
GETCNT . . . . . . . . . . . . .	L NEAR 	00D1	CODE
GETFILL. . . . . . . . . . . . .	L NEAR 	00A1	CODE
HAVSGN . . . . . . . . . . . . .	L NEAR 	001D	CODE
INTDIG . . . . . . . . . . . . .	Text	$DIGCNT+1       	 	
INTDIGITS. . . . . . . . . . . .	L NEAR 	0109	CODE
MOVDECDIG. . . . . . . . . . . .	L NEAR 	0139	CODE
MOVFRAC. . . . . . . . . . . . .	L NEAR 	0133	CODE
NOCOM. . . . . . . . . . . . . .	L NEAR 	0112	CODE
NODOL. . . . . . . . . . . . . .	L NEAR 	000D	CODE
NODOLLAR . . . . . . . . . . . .	L NEAR 	00FA	CODE
NOROUND. . . . . . . . . . . . .	L NEAR 	003E	CODE
NOSGN. . . . . . . . . . . . . .	L NEAR 	0023	CODE
NOTZERO. . . . . . . . . . . . .	L NEAR 	0045	CODE
OVERFIELD. . . . . . . . . . . .	L NEAR 	00C0	CODE
PLUSBIT. . . . . . . . . . . . .	Number	0008	
POSTFILL . . . . . . . . . . . .	L NEAR 	013E	CODE
PUFOUT . . . . . . . . . . . . .	L NEAR 	0003	CODE
ROUND. . . . . . . . . . . . . .	L NEAR 	0037	CODE
SAVEXP . . . . . . . . . . . . .	L NEAR 	0088	CODE
SCI1 . . . . . . . . . . . . . .	L NEAR 	0060	CODE
SCI2 . . . . . . . . . . . . . .	L NEAR 	006B	CODE
SCI3 . . . . . . . . . . . . . .	L NEAR 	0072	CODE
SCIBIT . . . . . . . . . . . . .	Number	0001	
SCICHK . . . . . . . . . . . . .	L NEAR 	0142	CODE


PUFOUT - PRINT USING output formatter                    Macro-86 %1(12)   1:7:27  13-Nov-81    Symbols-2



SCILEN . . . . . . . . . . . . .	L NEAR 	0053	CODE
SIGN . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
SIGNCHK. . . . . . . . . . . . .	L NEAR 	0163	CODE
STARBIT. . . . . . . . . . . . .	Number	0020	
STOINTDIG. . . . . . . . . . . .	L NEAR 	0119	CODE
TRAILING . . . . . . . . . . . .	Number	0004	
$DIGCNT. . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$PUFLAG. . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$PUFOUT. . . . . . . . . . . . .	L NEAR 	0000	CODE	Global

Warning Severe
Errors	Errors 
0	0











































