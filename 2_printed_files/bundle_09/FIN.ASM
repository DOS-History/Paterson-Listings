FIN - String and numeric input                           Macro-86 %1(12)   1:1:14  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   FIN - String and numeric input
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   VALTYP:BYTE, CURTYP:BYTE, TYP:WORD, $AC:WORD, $FAC:BYTE
    6	 	 	 	 	        EXTRN   PWR10TAB:WORD, $DAC:WORD
    7	 	 	 	 	
    8	 = 0080	 	 	 	FIX10   EQU     128             ;Correction to out-of-range exponents
    9	 = 0026	 	 	 	HIGH10  EQU     38              ;Largest power of 10 with correct exponent
   10	 = 0026	 	 	 	MAX10   EQU     38              ;Largest power of 10 that won't overflow
   11	 = FFC9	 	 	 	MIN10   EQU     -55             ;Smallest power of 10 that won't underflow
   12	 	 	 	 	
   13	 0000  ????	 	 	PWRINC  DW      ?
   14	 0002  ??	 	 	HAVDP   DB      ?
   15	 	 	 	 	
   16	 0003	 	 	 	DATA    ENDS
   17	 	 	 	 	
   18	 	 	 	 	DC      GROUP   DATA
   19	 	 	 	 	
   20	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   21	 	 	 	 	
   22	 	 	 	 	        PUBLIC  $FIN,$GETCH,$VAL
   23	 	 	 	 	
   24	 	 	 	 	        EXTRN   $CISA:FAR, $CSPB:FAR, $CINFAC:FAR, $OVFL:NEAR, $$CTS:NEAR
   25	 	 	 	 	        EXTRN   $SNORM:NEAR, $DNORM:NEAR, $SMUL:NEAR, $DMUL:NEAR
   26	 	 	 	 	        EXTRN   $SAVREG:NEAR, $$PUTZ:NEAR, $$DITS:NEAR
   27	 	 	 	 	        EXTRN   $SDIV:NEAR, $DDIV:NEAR
   28	 	 	 	 	
   29	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   30	 	 	 	 	
   31	 	 	 	 	
   32	 	 	 	 	;***  $VAL - VAL function
   33	 	 	 	 	;
   34	 	 	 	 	; Inputs:
   35	 	 	 	 	;       BX = Address of string descriptor
   36	 	 	 	 	; Function:
   37	 	 	 	 	;       Compute numeric equivalent of the string
   38	 	 	 	 	; Outputs:
   39	 	 	 	 	;       Double precision result in DAC
   40	 	 	 	 	; Registers:
   41	 	 	 	 	;       Only F affected.
   42	 	 	 	 	
   43	 0000	 	 	 	$VAL:
   44	 0000  E8 0000 E	 	        CALL    $SAVREG
   45	 0003  E8 0000 E	 	        CALL    $$PUTZ
   46	 0006  C6 06 0000 E 08	 	        MOV     [VALTYP],8      ;Force to double precision
   47	 000B  8B 77 02	 	 	        MOV     SI,[BX+2]       ;Get address of string data
   48	 000E  53	 	 	        PUSH    BX              ;Save string descriptor address
   49	 000F  E8 008F R	 	        CALL    $FIN
   50	 0012  5B	 	 	        POP     BX
   51	 0013  E9 0000 E	 	        JMP     $$DITS          ;Delete if temp string
   52	 	 	 	 	
   53	 	 	 	 	
   54	 0016	 	 	 	GETSTR:


FIN - String and numeric input                           Macro-86 %1(12)   1:1:14  13-Nov-81    Page 1-2



   55	 	 	 	 	;Come here to get string from input line (continuation of $FIN, below)
   56	 0016  E8 026F R	 	        CALL    $GETCH
   57	 0019  8A E0	 	 	        MOV     AH,AL           ;In case first char is "
   58	 001B  3C 22	 	 	        CMP     AL,'"'          ;Is it? 
   59	 001D  74 03	 	 	        JZ      COUNTSTR
   60	 001F  B4 2C	 	 	        MOV     AH,","          ;Terminate with comma if not quoted
   61	 0021  4E	 	 	        DEC     SI              ;Scan first char again
   62	 0022	 	 	 	COUNTSTR:
   63	 0022  8B D6	 	 	        MOV     DX,SI           ;Save starting address of string data
   64	 0024  33 C9	 	 	        XOR     CX,CX           ;Character count
   65	 0026	 	 	 	RDSTR:
   66	 0026  AC	 	 	        LODSB
   67	 0027  3A C4	 	 	        CMP     AL,AH           ;End of string?
   68	 0029  74 05	 	 	        JZ      NEGCNT
   69	 002B  0A C0	 	 	        OR      AL,AL           ;End of line?
   70	 002D  E0 F7	 	 	        LOOPNZ  RDSTR           ;Count char and loop if not EOL
   71	 002F  41	 	 	        INC     CX              ;Don't count the EOL character
   72	 0030	 	 	 	NEGCNT:
   73	 0030  F7 D9	 	 	        NEG     CX              ;Make character count positive
   74	 0032  80 FC 2C	 	 	        CMP     AH,','          ;Unquoted string?
   75	 0035  75 0F	 	 	        JNZ     MAKSTR
   76	 	 	 	 	;Not a quoted string. Trim off trailing blanks.
   77	 0037  4E	 	 	        DEC     SI              ;Point back at termination character
   78	 0038  8B FE	 	 	        MOV     DI,SI
   79	 003A  4F	 	 	        DEC     DI              ;Point to last char of string
   80	 003B  B0 20	 	 	        MOV     AL," "
   81	 003D  3A C0	 	 	        CMP     AL,AL           ;Set zero flag in case CX=0
   82	 003F  FD	 	 	        STD                     ;Set direction DOWN
   83	 0040  F3/ AE	 	 	        REPE    SCASB           ;Scan of blanks backward
   84	 0042  FC	 	 	        CLD                     ;Restore direction
   85	 0043  74 01	 	 	        JZ      MAKSTR          ;If null string, leave zero in CX
   86	 0045  41	 	 	        INC     CX              ;Last char scanned not blank - count it
   87	 0046	 	 	 	MAKSTR:
   88	 0046  8B D9	 	 	        MOV     BX,CX
   89	 0048  E8 0000 E	 	        CALL    $$CTS           ;Create temp string
   90	 004B  89 1E 0000 E	 	        MOV     [$AC],BX        ;Put address in AC for safekeeping
   91	 004F  C3	 	 	        RET
   92	 	 	 	 	
   93	 0050	 	 	 	HEXOCT:
   94	 0050  C6 06 0000 E 02	 	        MOV     [CURTYP],2      ;Set type to integer
   95	 0055  33 DB	 	 	        XOR     BX,BX           ;Initialize input to zero
   96	 0057  E8 026F R	 	        CALL    $GETCH          ;"&" followed by "O" or "H"?
   97	 005A  B9 0F04	 	 	        MOV     CX,15*100H+4    ;Prepare for hex input
   98	 005D  3C 48	 	 	        CMP     AL,"H"          ;Is it "&H"?
   99	 005F  74 07	 	 	        JZ      OCTHEX
  100	 0061  B9 0703	 	 	        MOV     CX,7*100H+3     ;Prepare for octal input
  101	 0064  3C 4F	 	 	        CMP     AL,"O"          ;Is it "&O"?
  102	 0066  75 03	 	 	        JNZ     OCTHEX1
  103	 0068	 	 	 	OCTHEX:
  104	 0068  E8 026F R	 	        CALL    $GETCH          ;Eat the "H" or "O"
  105	 006B	 	 	 	OCTHEX1:
  106	 006B  2C 30	 	 	        SUB     AL,"0"          ;Remove ASCII bias
  107	 006D  72 1B	 	 	        JB      LVHEX           ;If not a hex digit, quit
  108	 006F  3C 09	 	 	        CMP     AL,9


FIN - String and numeric input                           Macro-86 %1(12)   1:1:14  13-Nov-81    Page 1-3



  109	 0071  76 06	 	 	        JBE     OK
  110	 0073  2C 07	 	 	        SUB     AL,7            ;If "A" to "F", make 10-15
  111	 0075  3C 0A	 	 	        CMP     AL,10
  112	 0077  72 11	 	 	        JB      LVHEX
  113	 0079	 	 	 	OK:
  114	 0079  3A C5	 	 	        CMP     AL,CH           ;CH has max value (7 for oct, 15 for hex)
  115	 007B  77 0D	 	 	        JA      LVHEX
  116	 007D  F6 C7 E0	 	 	        TEST    BH,0E0H         ;Highest 3 bits must be zero
  117	 0080  75 4B	 	 	        JNZ     OVERFLOW
  118	 0082  D3 E3	 	 	        SHL     BX,CL           ;Make room for new digit
  119	 0084  72 47	 	 	        JC      OVERFLOW
  120	 0086  0A D8	 	 	        OR      BL,AL           ;Combine new digit
  121	 0088  EB DE	 	 	        JMP     OCTHEX
  122	 008A	 	 	 	LVHEX:
  123	 008A  4E	 	 	        DEC     SI              ;Back up to non-digit
  124	 008B  33 C9	 	 	        XOR     CX,CX           ;No power of 10
  125	 008D  EB 16	 	 	        JMP     SHORT SAVTYP
  126	 	 	 	 	
  127	 	 	 	 	
  128	 	 	 	 	;***  $FIN - Floating point and string input
  129	 	 	 	 	;
  130	 	 	 	 	; Inputs:
  131	 	 	 	 	;       [VALTYP] = Type of value required
  132	 	 	 	 	;       SI = Address of character stream to analyze for the value
  133	 	 	 	 	; Outputs:
  134	 	 	 	 	;       AC has integer value ([VALTYP] = 2)
  135	 	 	 	 	;       BX = Address of string descriptor ([VALTYP] = 3)
  136	 	 	 	 	;       AC has S.P. value ([VALTYP] = 4)
  137	 	 	 	 	;       DAC has D.P. value ([VALTYP] = 8)
  138	 	 	 	 	; Registers:
  139	 	 	 	 	;       Uses all.
  140	 	 	 	 	
  141	 008F	 	 	 	$FIN:
  142	 008F  80 3E 0000 E 03	 	        CMP     [VALTYP],3      ;Getting a string?
  143	 0094  74 80	 	 	        JZ      GETSTR
  144	 0096  E8 0198 R	 	        CALL    SIGN
  145	 0099  9C	 	 	        PUSHF                   ;Save sign in flags
  146	 009A  E8 026F R	 	        CALL    $GETCH
  147	 009D  3C 26	 	 	        CMP     AL,"&"          ;Hex or octal input?
  148	 009F  74 AF	 	 	        JZ      HEXOCT
  149	 00A1  4E	 	 	        DEC     SI              ;Back up
  150	 00A2  E8 01C0 R	 	        CALL    ASCNUM          ;Get ASCII digits, convert to integer
  151	 00A5	 	 	 	SAVTYP:
  152	 00A5  A1 0000 E	 	        MOV     AX,[TYP]        ;Get current type and requested type
  153	 00A8  80 FC 04	 	 	        CMP     AH,4            ;Test current type
  154	 00AB  77 0B	 	 	        JA      SAVEDP          ;Is it already double precision?
  155	 00AD  3A C4	 	 	        CMP     AL,AH           ;Need to convert S.P. to D.P.?
  156	 00AF  76 1F	 	 	        JBE     SAVSP
  157	 	 	 	 	;Convert S.P. to D.P.
  158	 00B1  C6 06 0000 E 08	 	        MOV     [CURTYP],8      ;Record change in precision
  159	 00B6  33 FF	 	 	        XOR     DI,DI
  160	 00B8	 	 	 	SAVEDP:
  161	 00B8  9D	 	 	        POPF                    ;Get sign flag (zero=negative)
  162	 00B9  51	 	 	        PUSH    CX              ;Currently in DI:BP:BX:DX


FIN - String and numeric input                           Macro-86 %1(12)   1:1:14  13-Nov-81    Page 1-4



  163	 00BA  8B CB	 	 	        MOV     CX,BX           ;Get in DI:BX:CX:DX form
  164	 00BC  8B DD	 	 	        MOV     BX,BP
  165	 00BE  B8 C000	 	 	        MOV     AX,192*100H     ;Set sign and exponent for positive integer
  166	 00C1  75 02	 	 	        JNZ     DPNORM          ;Is it positive or negative?
  167	 00C3  B0 80	 	 	        MOV     AL,80H          ;Negative!
  168	 00C5	 	 	 	DPNORM:
  169	 00C5  56	 	 	        PUSH    SI
  170	 00C6  E8 0000 E	 	        CALL    $DNORM          ;Normalize and store in FAC
  171	 00C9  5E	 	 	        POP     SI
  172	 00CA  59	 	 	        POP     CX
  173	 00CB  EB 0E	 	 	        JMP     SHORT HAVNUM    ;Go check for exponent
  174	 	 	 	 	
  175	 00CD  E9 0000 E	 	OVERFLOW:JMP    $OVFL
  176	 	 	 	 	
  177	 00D0	 	 	 	SAVSP:
  178	 00D0  9D	 	 	        POPF
  179	 00D1  B8 A000	 	 	        MOV     AX,160*100H     ;Sign and exponent for positive integer
  180	 00D4  75 02	 	 	        JNZ     SPNORM          ;Positive?
  181	 00D6  B0 80	 	 	        MOV     AL,80H          ;Force negative sign
  182	 00D8	 	 	 	SPNORM:
  183	 00D8  E8 0000 E	 	        CALL    $SNORM          ;Normalize and store in FAC
  184	 	 	 	 	
  185	 00DB	 	 	 	HAVNUM:
  186	 	 	 	 	
  187	 	 	 	 	;Number is stored as integer in FAC with proper sign, CURTYP has its type,
  188	 	 	 	 	;which is at least the precision requested by VALTYP. CX has current base 10
  189	 	 	 	 	;exponent. Now we scan for type character ("%", "!", "#") or exponent field.
  190	 	 	 	 	
  191	 00DB  E8 026F R	 	        CALL    $GETCH          ;Get last char again
  192	 	 	 	 	;Ignore the special type symbols
  193	 00DE  3C 25	 	 	        CMP     AL,"%"          ;Integer?
  194	 00E0  74 2C	 	 	        JZ      MULEXP
  195	 00E2  3C 23	 	 	        CMP     AL,"#"          ;Double?
  196	 00E4  74 28	 	 	        JZ      MULEXP
  197	 00E6  3C 21	 	 	        CMP     AL,"!"          ;Single?
  198	 00E8  74 24	 	 	        JZ      MULEXP
  199	 	 	 	 	;Check for exponent
  200	 00EA  3C 44	 	 	        CMP     AL,"D"          ;Get D.P. exponent?
  201	 00EC  74 07	 	 	        JZ      GETEXP
  202	 00EE  3C 45	 	 	        CMP     AL,"E"          ;S.P. exponent?
  203	 00F0  74 03	 	 	        JZ      GETEXP
  204	 00F2  4E	 	 	        DEC     SI              ;If not recognized, ignore
  205	 00F3  EB 19	 	 	        JMP     SHORT MULEXP
  206	 	 	 	 	
  207	 00F5	 	 	 	GETEXP:
  208	 00F5  E8 0198 R	 	        CALL    SIGN            ;Get sign, if any
  209	 00F8  9C	 	 	        PUSHF                   ;Save it
  210	 00F9  33 DB	 	 	        XOR     BX,BX
  211	 00FB  C6 06 0002 R 01	 	        MOV     [HAVDP],1       ;Don't allow a decimal point
  212	 0100  89 1E 0000 R	 	        MOV     [PWRINC],BX     ;Don't change CX
  213	 0104  E8 01A9 R	 	        CALL    GETINT          ;Get integer in BX
  214	 0107  9D	 	 	        POPF                    ;Recover sign
  215	 0108  75 02	 	 	        JNZ     NONEG           ;Positive?
  216	 010A  F7 DB	 	 	        NEG     BX


FIN - String and numeric input                           Macro-86 %1(12)   1:1:14  13-Nov-81    Page 1-5



  217	 010C	 	 	 	NONEG:
  218	 010C  03 CB	 	 	        ADD     CX,BX
  219	 	 	 	 	
  220	 010E	 	 	 	MULEXP:
  221	 	 	 	 	
  222	 	 	 	 	;FAC has number as integer, CX has its power of 10. Use lookup table to find
  223	 	 	 	 	;the double precision power of 10, and multiply or divide. Then coerce to lower
  224	 	 	 	 	;precision, if necessary.
  225	 	 	 	 	
  226	 010E  E3 68	 	 	        JCXZ    COERCE          ;No multiplication needed?
  227	 0110  83 F9 26	 	 	        CMP     CX,MAX10
  228	 0113  7F B8	 	 	        JG      OVERFLOW        ;Power of 10 too big?
  229	 0115  83 F9 C9	 	 	        CMP     CX,MIN10
  230	 0118  7C 6F	 	 	        JL      ZERO            ;Too small?
  231	 011A  56	 	 	        PUSH    SI              ;Save pointer to text
  232	 011B  8B F9	 	 	        MOV     DI,CX
  233	 011D  0B FF	 	 	        OR      DI,DI           ;Is exponent negative?
  234	 011F  79 02	 	 	        JNS     HAVMAG
  235	 0121  F7 DF	 	 	        NEG     DI              ;Get magnitude of exponent
  236	 0123	 	 	 	HAVMAG:
  237	 0123  83 FF 26	 	 	        CMP     DI,HIGH10       ;Is power too large to be correct?
  238	 0126  7E 05	 	 	        JLE     NOFIX
  239	 0128  80 2E 0000 E 80	 	        SUB     [$FAC],FIX10    ;Adjust our exponent to account for it
  240	 012D	 	 	 	NOFIX:
  241	 012D  D1 E7	 	 	        SHL     DI,1
  242	 012F  D1 E7	 	 	        SHL     DI,1
  243	 0131  D1 E7	 	 	        SHL     DI,1            ;Multiply by 8 for index into table
  244	 0133  80 3E 0000 E 08	 	        CMP     [CURTYP],8      ;Presently double precision?
  245	 0138  74 2A	 	 	        JZ      DBLEXP          ;If so, do double precision multiply/divide
  246	 013A  81 C7 0004 E	 	        ADD     DI,OFFSET DC:PWR10TAB+4 ;Point to S.P. version of constant
  247	 013E  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
  248	 0141  81 7D FE 8000	 	        CMP     WORD PTR[DI-2],8000H  ; See if we need to round it
  249	 0146  72 0E	 	 	        JB      SNGLEXP
  250	 0148  83 EE 04	 	 	        SUB     SI,4            ;Copy number to low half of $DAC
  251	 014B  87 F7	 	 	        XCHG    SI,DI           ;Set up to move
  252	 014D  A5	 	 	        MOVSW
  253	 014E  A5	 	 	        MOVSW
  254	 014F  8B F7	 	 	        MOV     SI,DI           ;OFFSET $AC
  255	 0151  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  256	 0154  FF 05	 	 	        INC     WORD PTR[DI]    ;Round up
  257	 0156	 	 	 	SNGLEXP:
  258	 0156  0B C9	 	 	        OR      CX,CX           ;Is exponent positive or negative?
  259	 0158  79 05	 	 	        JNS     SNGPOS
  260	 015A  E8 0000 E	 	        CALL    $SDIV           ;Divide by power of 10 if exponent negative
  261	 015D  EB 18	 	 	        JMP     SHORT MULDON
  262	 015F	 	 	 	SNGPOS:
  263	 015F  E8 0000 E	 	        CALL    $SMUL           ;Multiply by power of 10 if exponent positive
  264	 0162  EB 13	 	 	        JMP     SHORT MULDON
  265	 	 	 	 	
  266	 0164	 	 	 	DBLEXP:
  267	 0164  81 C7 0000 E	 	        ADD     DI,OFFSET DC:PWR10TAB
  268	 0168  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  269	 016B  0B C9	 	 	        OR      CX,CX
  270	 016D  79 05	 	 	        JNS     DBLPOS


FIN - String and numeric input                           Macro-86 %1(12)   1:1:14  13-Nov-81    Page 1-6



  271	 016F  E8 0000 E	 	        CALL    $DDIV
  272	 0172  EB 03	 	 	        JMP     SHORT MULDON
  273	 0174	 	 	 	DBLPOS:
  274	 0174  E8 0000 E	 	        CALL    $DMUL
  275	 0177	 	 	 	MULDON:
  276	 0177  5E	 	 	        POP     SI              ;Recover pointer to text buffer
  277	 0178	 	 	 	COERCE:
  278	 0178  A1 0000 E	 	        MOV     AX,[TYP]
  279	 017B  3A C4	 	 	        CMP     AL,AH           ;Already the right type?
  280	 017D  74 26	 	 	        JZ      DONE
  281	 017F  3C 02	 	 	        CMP     AL,2            ;Need integer? (have floating)
  282	 0181  74 0F	 	 	        JZ      CONVINT         ;Convert to integer whether SP or DP
  283	 0183  9A 0000 ---- E	 	        CALL    $CSPB           ;Convert DP to SP
  284	 0188  C3	 	 	        RET
  285	 	 	 	 	
  286	 0189	 	 	 	ZERO:
  287	 0189  33 C0	 	 	        XOR     AX,AX
  288	 018B  A3 0000 E	 	        MOV     [$AC],AX        ;Zero in case its integer
  289	 018E  A2 0000 E	 	        MOV     [$FAC],AL       ;Zero in case its floating
  290	 0191  C3	 	 	        RET
  291	 	 	 	 	
  292	 0192	 	 	 	CONVINT:
  293	 0192  9A 0000 ---- E	 	        CALL    $CINFAC         ;Convert floating to integer
  294	 0197  C3	 	 	        RET
  295	 	 	 	 	
  296	 0198	 	 	 	SIGN:
  297	 0198  E8 026F R	 	        CALL    $GETCH
  298	 019B  3C 2D	 	 	        CMP     AL,"-"          ;Negative?
  299	 019D  74 06	 	 	        JZ      DONE
  300	 019F  3C 2B	 	 	        CMP     AL,"+"
  301	 01A1  75 01	 	 	        JNZ     NOTZER
  302	 01A3  46	 	 	        INC     SI              ;Eat sign if present and
  303	 01A4  4E	 	 	NOTZER: DEC     SI              ;Back up and clear zero flag
  304	 01A5  C3	 	 	DONE:   RET
  305	 	 	 	 	
  306	 01A6	 	 	 	MAXINT:
  307	 01A6  BB 7FFF	 	 	        MOV     BX,32767        ;Force maximum integer (will overflow later)
  308	 01A9	 	 	 	GETINT:
  309	 01A9  E8 0248 R	 	        CALL    GETDIG
  310	 01AC  81 FB 0CCC	 	        CMP     BX,3276
  311	 01B0  77 F4	 	 	        JA      MAXINT
  312	 01B2  D1 E3	 	 	        SHL     BX,1
  313	 01B4  03 C3	 	 	        ADD     AX,BX
  314	 01B6  D1 E3	 	 	        SHL     BX,1
  315	 01B8  D1 E3	 	 	        SHL     BX,1
  316	 01BA  03 D8	 	 	        ADD     BX,AX           ;BX = BX*10 + AX
  317	 01BC  78 E8	 	 	        JS      MAXINT          ;Still OK as signed integer?
  318	 01BE  EB E9	 	 	        JMP     GETINT
  319	 	 	 	 	
  320	 01C0	 	 	 	ASCNUM:
  321	 	 	 	 	;Scan a string of ASCII digits with optional decimal point and return
  322	 	 	 	 	;32-, or 64-bit integer in registers. On exit:
  323	 	 	 	 	;       32-bit result: BX:DX            CURTYP = 4
  324	 	 	 	 	;       64-bit result: DI:BP:BX:DX      CURTYP = 8


FIN - String and numeric input                           Macro-86 %1(12)   1:1:14  13-Nov-81    Page 1-7



  325	 	 	 	 	;       CX has power of 10 needed to put decimal point in right place.
  326	 	 	 	 	;
  327	 	 	 	 	;Sliding precision is used for speed. As the number of digits increases,
  328	 	 	 	 	;requiring greater precision to maintain accuracy, the conversion shifts
  329	 	 	 	 	;from to 32-bit to 64-bit calculations. If the number of digits
  330	 	 	 	 	;exceeds 64-bit precision, these trailing digits are used to set a sticky
  331	 	 	 	 	;bit (if non-zero), but are otherwise trimmed off.
  332	 	 	 	 	
  333	 01C0  33 DB	 	 	        XOR     BX,BX           ;Current value is zero
  334	 01C2  8B D3	 	 	        MOV     DX,BX
  335	 01C4  8B EB	 	 	        MOV     BP,BX
  336	 01C6  8B CB	 	 	        MOV     CX,BX           ;No power of 10 yet
  337	 01C8  89 1E 0000 R	 	        MOV     [PWRINC],BX     ;Don't increment power of 10 yet
  338	 01CC  C6 06 0000 E 04	 	        MOV     [CURTYP],4      ;Type integer so far
  339	 01D1  88 1E 0002 R	 	        MOV     [HAVDP],BL      ;Decimal point not seen yet
  340	 01D5	 	 	 	SNGLOOP:
  341	 01D5  E8 0248 R	 	        CALL    GETDIG
  342	 01D8  D1 E2	 	 	        SHL     DX,1
  343	 01DA  D1 D3	 	 	        RCL     BX,1
  344	 01DC  03 C2	 	 	        ADD     AX,DX
  345	 01DE  8B FB	 	 	        MOV     DI,BX
  346	 01E0  83 D7 00	 	 	        ADC     DI,0            ;DI:AX = BX:DX*2 + AX
  347	 01E3  D1 E2	 	 	        SHL     DX,1
  348	 01E5  D1 D3	 	 	        RCL     BX,1
  349	 01E7  D1 E2	 	 	        SHL     DX,1
  350	 01E9  D1 D3	 	 	        RCL     BX,1
  351	 01EB  03 D0	 	 	        ADD     DX,AX
  352	 01ED  13 DF	 	 	        ADC     BX,DI           ;BX:DX = BX:DX*10 + AX
  353	 01EF  0A FF	 	 	        OR      BH,BH           ;Still in 24 bits?
  354	 01F1  74 E2	 	 	        JZ      SNGLOOP         ;If not, convert to double
  355	 01F3  C6 06 0000 E 08	 	        MOV     [CURTYP],8      ;Type now double precision
  356	 01F8  33 FF	 	 	        XOR     DI,DI           ;Number in DI:BP:BX:DX
  357	 01FA	 	 	 	DBLLOOP:
  358	 01FA  E8 0248 R	 	        CALL    GETDIG
  359	 01FD  50	 	 	        PUSH    AX
  360	 01FE  57	 	 	        PUSH    DI
  361	 01FF  55	 	 	        PUSH    BP
  362	 0200  53	 	 	        PUSH    BX
  363	 0201  52	 	 	        PUSH    DX
  364	 0202  D1 E2	 	 	        SHL     DX,1            ;Number=number*2
  365	 0204  D1 D3	 	 	        RCL     BX,1
  366	 0206  D1 D5	 	 	        RCL     BP,1
  367	 0208  D1 D7	 	 	        RCL     DI,1
  368	 020A  D1 E2	 	 	        SHL     DX,1            ;Number=number*4
  369	 020C  D1 D3	 	 	        RCL     BX,1
  370	 020E  D1 D5	 	 	        RCL     BP,1
  371	 0210  D1 D7	 	 	        RCL     DI,1
  372	 0212  58	 	 	        POP     AX
  373	 0213  03 D0	 	 	        ADD     DX,AX           ;Number=number*5
  374	 0215  58	 	 	        POP     AX
  375	 0216  13 D8	 	 	        ADC     BX,AX
  376	 0218  58	 	 	        POP     AX
  377	 0219  13 E8	 	 	        ADC     BP,AX
  378	 021B  58	 	 	        POP     AX


FIN - String and numeric input                           Macro-86 %1(12)   1:1:14  13-Nov-81    Page 1-8



  379	 021C  13 F8	 	 	        ADC     DI,AX
  380	 021E  D1 E2	 	 	        SHL     DX,1            ;Number=number*10
  381	 0220  D1 D3	 	 	        RCL     BX,1
  382	 0222  D1 D5	 	 	        RCL     BP,1
  383	 0224  D1 D7	 	 	        RCL     DI,1
  384	 0226  58	 	 	        POP     AX              ;New digit to add in
  385	 0227  03 D0	 	 	        ADD     DX,AX
  386	 0229  83 D3 00	 	 	        ADC     BX,0
  387	 022C  83 D5 00	 	 	        ADC     BP,0
  388	 022F  83 D7 00	 	 	        ADC     DI,0
  389	 0232  81 FF 1999	 	        CMP     DI,6553         ;If too many digits, ignore them
  390	 0236  72 C2	 	 	        JB      DBLLOOP
  391	 0238  FF 06 0000 R	 	        INC     [PWRINC]        ;Count the digits as we ignore them
  392	 023C	 	 	 	EATLOOP:
  393	 023C  E8 0248 R	 	        CALL    GETDIG
  394	 023F  0A C0	 	 	        OR      AL,AL           ;Was digit zero?
  395	 0241  74 03	 	 	        JZ      NEXTDIG
  396	 0243  80 CA 01	 	 	        OR      DL,1            ;Set sticky bit if non-zero digit
  397	 0246	 	 	 	NEXTDIG:
  398	 0246  EB F4	 	 	        JMP     EATLOOP
  399	 	 	 	 	
  400	 0248	 	 	 	GETDIG:
  401	 	 	 	 	;This routine get the next digit and returns it (with ASCII bias removed)
  402	 	 	 	 	;in AX (AH is always zero). For each digit returned, [PWRINC] is added to
  403	 	 	 	 	;CX as a means to count digits so we'll get the power of 10 right. When the
  404	 	 	 	 	;first decimal point is encountered, PWRINC is decremented one. This decimal
  405	 	 	 	 	;point is skipped over and we look for the next digit. On return, the flags
  406	 	 	 	 	;are set from a comparison with the largest number that can be multiplied by
  407	 	 	 	 	;10 and not overflow BX.
  408	 	 	 	 	;       Should a second decimal point or any other non-digit be encountered,
  409	 	 	 	 	;we have reached the end of the number and the routine pops one return
  410	 	 	 	 	;address off the stack and returns to the next level up.
  411	 0248  E8 026F R	 	        CALL    $GETCH          ;Get next ASCII character
  412	 024B  2C 30	 	 	        SUB     AL,"0"          ;Subtract ASCII bias
  413	 024D  72 0A	 	 	        JB      NOTNUM
  414	 024F  3C 09	 	 	        CMP     AL,9
  415	 0251  77 06	 	 	        JA      NOTNUM
  416	 0253  98	 	 	        CBW                     ;Zero AH
  417	 0254  03 0E 0000 R	 	        ADD     CX,[PWRINC]     ;Count digits ignored or to right of dec. pt.
  418	 0258  C3	 	 	        RET                     ;Return with flags set
  419	 0259	 	 	 	NOTNUM:
  420	 0259  3C FE	 	 	        CMP     AL,"."-"0"      ;Is it decimal point?
  421	 025B  75 0D	 	 	        JNZ     NOTDIG
  422	 025D  80 3E 0002 R 00	 	        CMP     [HAVDP],0       ;Seen a dec.pt. before?
  423	 0262  75 06	 	 	        JNZ     NOTDIG          ;If so, this one ends the number
  424	 0264  FF 0E 0000 R	 	        DEC     [PWRINC]        ;Count digits to right of dec.pt.
  425	 0268  EB DE	 	 	        JMP     GETDIG          ;Get a real digit
  426	 026A	 	 	 	NOTDIG:
  427	 026A  4E	 	 	        DEC     SI              ;Point back at non-digit
  428	 026B  83 C4 02	 	 	        ADD     SP,2            ;Return to next level up
  429	 026E  C3	 	 	        RET
  430	 	 	 	 	
  431	 026F	 	 	 	$GETCH:
  432	 	 	 	 	;Get next byte, skipping blanks, tabs, and linefeeds


FIN - String and numeric input                           Macro-86 %1(12)   1:1:14  13-Nov-81    Page 1-9



  433	 026F  AC	 	 	        LODSB                   ;Get next input byte
  434	 0270  3C 20	 	 	        CMP     AL," "          ;Ignore spaces
  435	 0272  74 FB	 	 	        JZ      $GETCH
  436	 0274  3C 09	 	 	        CMP     AL,9            ;Ignore tabs
  437	 0276  74 F7	 	 	        JZ      $GETCH
  438	 0278  3C 0A	 	 	        CMP     AL,10           ;Ignore linefeeds
  439	 027A  74 F3	 	 	        JZ      $GETCH
  440	 027C  3C 61	 	 	        CMP     AL,"a"
  441	 027E  72 06	 	 	        JB      RET
  442	 0280  3C 7A	 	 	        CMP     AL,"z"
  443	 0282  77 02	 	 	        JA      RET
  444	 0284  24 5F	 	 	        AND     AL,5FH          ;Convert lower to upper case
  445	 0286  C3	 	 	RET:    RET
  446	 	 	 	 	
  447	 0287	 	 	 	CODE    ENDS
  448	 	 	 	 	        END








































FIN - String and numeric input                           Macro-86 %1(12)   1:1:14  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0287	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0003	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ASCNUM . . . . . . . . . . . . .	L NEAR 	01C0	CODE
COERCE . . . . . . . . . . . . .	L NEAR 	0178	CODE
CONVINT. . . . . . . . . . . . .	L NEAR 	0192	CODE
COUNTSTR . . . . . . . . . . . .	L NEAR 	0022	CODE
CURTYP . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
DBLEXP . . . . . . . . . . . . .	L NEAR 	0164	CODE
DBLLOOP. . . . . . . . . . . . .	L NEAR 	01FA	CODE
DBLPOS . . . . . . . . . . . . .	L NEAR 	0174	CODE
DONE . . . . . . . . . . . . . .	L NEAR 	01A5	CODE
DPNORM . . . . . . . . . . . . .	L NEAR 	00C5	CODE
EATLOOP. . . . . . . . . . . . .	L NEAR 	023C	CODE
FIX10. . . . . . . . . . . . . .	Number	0080	
GETDIG . . . . . . . . . . . . .	L NEAR 	0248	CODE
GETEXP . . . . . . . . . . . . .	L NEAR 	00F5	CODE
GETINT . . . . . . . . . . . . .	L NEAR 	01A9	CODE
GETSTR . . . . . . . . . . . . .	L NEAR 	0016	CODE
HAVDP. . . . . . . . . . . . . .	L BYTE 	0002	DATA
HAVMAG . . . . . . . . . . . . .	L NEAR 	0123	CODE
HAVNUM . . . . . . . . . . . . .	L NEAR 	00DB	CODE
HEXOCT . . . . . . . . . . . . .	L NEAR 	0050	CODE
HIGH10 . . . . . . . . . . . . .	Number	0026	
LVHEX. . . . . . . . . . . . . .	L NEAR 	008A	CODE
MAKSTR . . . . . . . . . . . . .	L NEAR 	0046	CODE
MAX10. . . . . . . . . . . . . .	Number	0026	
MAXINT . . . . . . . . . . . . .	L NEAR 	01A6	CODE
MIN10. . . . . . . . . . . . . .	Number	FFC9	
MULDON . . . . . . . . . . . . .	L NEAR 	0177	CODE
MULEXP . . . . . . . . . . . . .	L NEAR 	010E	CODE
NEGCNT . . . . . . . . . . . . .	L NEAR 	0030	CODE
NEXTDIG. . . . . . . . . . . . .	L NEAR 	0246	CODE
NOFIX. . . . . . . . . . . . . .	L NEAR 	012D	CODE
NONEG. . . . . . . . . . . . . .	L NEAR 	010C	CODE
NOTDIG . . . . . . . . . . . . .	L NEAR 	026A	CODE
NOTNUM . . . . . . . . . . . . .	L NEAR 	0259	CODE
NOTZER . . . . . . . . . . . . .	L NEAR 	01A4	CODE
OCTHEX . . . . . . . . . . . . .	L NEAR 	0068	CODE
OCTHEX1. . . . . . . . . . . . .	L NEAR 	006B	CODE
OK . . . . . . . . . . . . . . .	L NEAR 	0079	CODE
OVERFLOW . . . . . . . . . . . .	L NEAR 	00CD	CODE
PWR10TAB . . . . . . . . . . . .	V WORD 	0000	DATA	External
PWRINC . . . . . . . . . . . . .	L WORD 	0000	DATA
RDSTR. . . . . . . . . . . . . .	L NEAR 	0026	CODE


FIN - String and numeric input                           Macro-86 %1(12)   1:1:14  13-Nov-81    Symbols-2



RET. . . . . . . . . . . . . . .	L NEAR 	0286	CODE
SAVEDP . . . . . . . . . . . . .	L NEAR 	00B8	CODE
SAVSP. . . . . . . . . . . . . .	L NEAR 	00D0	CODE
SAVTYP . . . . . . . . . . . . .	L NEAR 	00A5	CODE
SIGN . . . . . . . . . . . . . .	L NEAR 	0198	CODE
SNGLEXP. . . . . . . . . . . . .	L NEAR 	0156	CODE
SNGLOOP. . . . . . . . . . . . .	L NEAR 	01D5	CODE
SNGPOS . . . . . . . . . . . . .	L NEAR 	015F	CODE
SPNORM . . . . . . . . . . . . .	L NEAR 	00D8	CODE
TYP. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
VALTYP . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
ZERO . . . . . . . . . . . . . .	L NEAR 	0189	CODE
$$CTS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$DITS . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$PUTZ . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$CINFAC. . . . . . . . . . . . .	L FAR  	0000	CODE	External
$CISA. . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$CSPB. . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DDIV. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DNORM . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FIN . . . . . . . . . . . . . .	L NEAR 	008F	CODE	Global
$GETCH . . . . . . . . . . . . .	L NEAR 	026F	CODE	Global
$OVFL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SDIV. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SMUL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SNORM . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$VAL . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global

Warning Severe
Errors	Errors 
0	0




















