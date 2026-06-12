CONASC - Convert number to ASCII                                 Macro-86 %1(12)   0:58:40   13-Nov-81   Page 1-1


    1	 	 	 	 	        TITLE   CONASC - Convert number to ASCII
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        PUBLIC  SIGN,FOBUF
    6	 	 	 	 	
    7	 	 	 	 	        EXTRN   VALTYP:BYTE, $FAC:BYTE, $AC:BYTE, $DAC:BYTE
    8	 	 	 	 	
    9	 0000  ??	 	 	SIGN    DB      ?
   10	 0001     23 [	 	 	FOBUF   DB      35 DUP (?)      ;Numeric output buffer
   11	                ??	 	
   12	                    ]	 	
   13	 	 	 	 	
   14	 0024     14 [	 	 	BUF     DB      20 DUP (?)      ;ASCII conversion buffer
   15	                ??	 	
   16	                    ]	 	
   17	 	 	 	 	
   18	 	 	 	 	
   19	 0038	 	 	 	DATA    ENDS
   20	 	 	 	 	
   21	 	 	 	 	
   22	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
   23	 	 	 	 	
   24	 	 	 	 	        EXTRN   PWR10TAB:WORD
   25	 	 	 	 	
   26	 	 	 	 	; Table of integers 10^X, for X=18 down to 8, for converting DP numbers
   27	 	 	 	 	
   28	 0000	 	 	 	DPCON   LABEL   WORD
   29	 0000  0000 A764 B6B3 0DE0	        DW      0000H,0A764H,0B6B3H,0DE0H       ;10^18
   30	 0008  0000 5D8A 4578 0163	        DW      0000H,5D8AH,4578H,163H          ;10^17
   31	 0010  0000 6FC1 86F2 0023	        DW      0000H,6FC1H,86F2H,23H           ;10^16
   32	 0018  8000 A4C6 8D7E 0003	        DW      8000H,0A4C6H,8D7EH,3            ;10^15
   33	 0020  4000 107A 5AF3 0000	        DW      4000H,107AH,5AF3H,0             ;10^14
   34	 0028  A000 4E72 0918 0000	        DW      0A000H,4E72H,918H,0             ;10^13
   35	 0030  1000 D4A5 00E8 0000	        DW      1000H,0D4A5H,0E8H,0             ;10^12
   36	 0038  E800 4876 0017 0000	        DW      0E800H,4876H,17H,0              ;10^11
   37	 0040  E400 540B 0002 0000	        DW      0E400H,540BH,2,0                ;10^10
   38	 0048  CA00 3B9A 0000 0000	        DW      0CA00H,3B9AH,0,0                ;10^9
   39	 0050  E100 05F5 0000 0000	        DW      0E100H,5F5H,0,0                 ;10^8
   40	 	 	 	 	
   41	 	 	 	 	
   42	 	 	 	 	;EXPTAB - Lookup table for exponents
   43	 	 	 	 	;An actual base 2 exponent of 25 or 57 (for SP or DP, respectively) is needed
   44	 	 	 	 	;before a number may be converted from binary to decimal. This is because such
   45	 	 	 	 	;an exponent ensures the mantissa is just a big integer. The difference
   46	 	 	 	 	;between the desired exponent (25 or 57) and the present one is figured and
   47	 	 	 	 	;used as an index into this table. The entries in the table represent the
   48	 	 	 	 	;power of 10 to multiply by to get the needed exponent. The table covers
   49	 	 	 	 	;an exponent difference range of -102 [25-127] to +184 [57-(-127)].
   50	 	 	 	 	
   51	 0058  E2 E2 E2 E3 E3 E3	        DB      -30,-30,-30,-29,-29,-29         ;-102 to -97
   52	 005E  E4 E4 E4 E5 E5 E5	        DB      -28,-28,-28,-27,-27,-27,-27,-26 ;-96 to -89
   53	       E5 E6	 	 	
   54	 0066  E6 E6 E7 E7 E7 E8	        DB      -26,-26,-25,-25,-25,-24,-24,-24 ;-88 to -81


CONASC - Convert number to ASCII                                 Macro-86 %1(12)   0:58:40   13-Nov-81   Page 1-2



   55	       E8 E8	 	 	
   56	 006E  E8 E9 E9 E9 EA EA	        DB      -24,-23,-23,-23,-22,-22,-22,-21 ;-80 to -73
   57	       EA EB	 	 	
   58	 0076  EB EB EB EC EC EC	        DB      -21,-21,-21,-20,-20,-20,-19,-19 ;-72 to -65
   59	       ED ED	 	 	
   60	 007E  ED EE EE EE EE EF	        DB      -19,-18,-18,-18,-18,-17,-17,-17 ;-64 to -57
   61	       EF EF	 	 	
   62	 0086  F0 F0 F0 F1 F1 F1	        DB      -16,-16,-16,-15,-15,-15,-15,-14 ;-56 to -49
   63	       F1 F2	 	 	
   64	 008E  F2 F2 F3 F3 F3 F4	        DB      -14,-14,-13,-13,-13,-12,-12,-12 ;-48 to -41
   65	       F4 F4	 	 	
   66	 0096  F4 F5 F5 F5 F6 F6	        DB      -12,-11,-11,-11,-10,-10,-10,-9  ;-40 to -33
   67	       F6 F7	 	 	
   68	 009E  F7 F7 F7 F8 F8 F8	        DB      -9,-9,-9,-8,-8,-8,-7,-7         ;-32 to -25
   69	       F9 F9	 	 	
   70	 00A6  F9 FA FA FA FA FB	        DB      -7,-6,-6,-6,-6,-5,-5,-5         ;-24 to -17
   71	       FB FB	 	 	
   72	 00AE  FC FC FC FD FD FD	        DB      -4,-4,-4,-3,-3,-3,-3,-2         ;-16 to -9
   73	       FD FE	 	 	
   74	 00B6  FE FE FF FF FF 00	        DB      -2,-2,-1,-1,-1,0,0,0            ;-8 to -1
   75	       00 00	 	 	
   76	 00BE	 	 	 	EXPTAB  LABEL   BYTE    ;Table is centered on zero
   77	 00BE  00 01 01 01 02 02	        DB      0,1,1,1,2,2,2,3                 ;0 to 7
   78	       02 03	 	 	
   79	 00C6  03 03 04 04 04 04	        DB      3,3,4,4,4,4,5,5                 ;8 to 15
   80	       05 05	 	 	
   81	 00CE  05 06 06 06 07 07	        DB      5,6,6,6,7,7,7,7                 ;16 to 23
   82	       07 07	 	 	
   83	 00D6  08 08 08 09 09 09	        DB      8,8,8,9,9,9,10,10               ;24 to 31
   84	       0A 0A	 	 	
   85	 00DE  0A 0A 0B 0B 0B 0C	        DB      10,10,11,11,11,12,12,12         ;32 to 39
   86	       0C 0C	 	 	
   87	 00E6  0D 0D 0D 0D 0E 0E	        DB      13,13,13,13,14,14,14,15         ;40 to 47
   88	       0E 0F	 	 	
   89	 00EE  0F 0F 10 10 10 10	        DB      15,15,16,16,16,16,17,17         ;48 to 55
   90	       11 11	 	 	
   91	 00F6  11 12 12 12 13 13	        DB      17,18,18,18,19,19,19,19         ;56 to 63
   92	       13 13	 	 	
   93	 00FE  14 14 14 15 15 15	        DB      20,20,20,21,21,21,22,22         ;64 to 71
   94	       16 16	 	 	
   95	 0106  16 16 17 17 17 18	        DB      22,22,23,23,23,24,24,24         ;72 to 79
   96	       18 18	 	 	
   97	 010E  19 19 19 19 1A 1A	        DB      25,25,25,25,26,26,26,27         ;80 to 87
   98	       1A 1B	 	 	
   99	 0116  1B 1B 1C 1C 1C 1C	        DB      27,27,28,28,28,28,29,29         ;88 to 95
  100	       1D 1D	 	 	
  101	 011E  1D 1E 1E 1E 1F 1F	        DB      29,30,30,30,31,31,31,32         ;96 to 103
  102	       1F 20	 	 	
  103	 0126  20 20 20 21 21 21	        DB      32,32,32,33,33,33,34,34         ;104 to 111
  104	       22 22	 	 	
  105	 012E  22 23 23 23 23 24	        DB      34,35,35,35,35,36,36,36         ;112 to 119
  106	       24 24	 	 	
  107	 0136  25 25 25 26 26 26	        DB      37,37,37,38,38,38,38,39         ;120 to 127
  108	       26 27	 	 	


CONASC - Convert number to ASCII                                 Macro-86 %1(12)   0:58:40   13-Nov-81   Page 1-3



  109	 013E  27 27 28 28 28 29	        DB      39,39,40,40,40,41,41,41         ;128 to 135
  110	       29 29	 	 	
  111	 0146  29 2A 2A 2A 2B 2B	        DB      41,42,42,42,43,43,43,44         ;136 to 143
  112	       2B 2C	 	 	
  113	 014E  2C 2C 2C 2D 2D 2D	        DB      44,44,44,45,45,45,46,46         ;144 to 151
  114	       2E 2E	 	 	
  115	 0156  2E 2F 2F 2F 2F 30	        DB      46,47,47,47,47,48,48,48         ;152 to 159
  116	       30 30	 	 	
  117	 015E  31 31 31 32 32 32	        DB      49,49,49,50,50,50,50,51         ;160 to 167
  118	       32 33	 	 	
  119	 0166  33 33 34 34 34 35	        DB      51,51,52,52,52,53,53,53         ;168 to 175
  120	       35 35	 	 	
  121	 016E  35 36 36 36 37 37	        DB      53,54,54,54,55,55,55,56         ;176 to 183
  122	       37 38	 	 	
  123	 0176  38	 	 	        DB      56                              ;184
  124	 	 	 	 	
  125	 0177	 	 	 	CONST   ENDS
  126	 	 	 	 	
  127	 	 	 	 	DC      GROUP   CONST,DATA
  128	 	 	 	 	
  129	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
  130	 	 	 	 	
  131	 	 	 	 	        PUBLIC  CONASC, ASCRND, $TYPUI
  132	 	 	 	 	
  133	 	 	 	 	        EXTRN   PMULS:NEAR, PMULD:NEAR
  134	 	 	 	 	        EXTRN   $$WCHT:NEAR
  135	 	 	 	 	
  136	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
  137	 	 	 	 	
  138	 	 	 	 	
  139	 0000	 	 	 	OUTINT:         ;This is a continuation of CONASC, below
  140	 0000  BF 0024 R	 	        MOV     DI,OFFSET DC:BUF  ;Save digits in BUF
  141	 0003  A1 0000 E	 	        MOV     AX,WORD PTR[$AC]  ;Get integer to convert
  142	 0006  B2 20	 	 	        MOV     DL," "          ;In case sign is positive
  143	 0008  0B C0	 	 	        OR      AX,AX
  144	 000A  74 12	 	 	        JZ      ZERO
  145	 000C  79 04	 	 	        JNS     SAVSGN          ;Positive?
  146	 000E  F7 D8	 	 	        NEG     AX              ;Force in positive
  147	 0010  B2 2D	 	 	        MOV     DL,"-"
  148	 0012	 	 	 	SAVSGN:
  149	 0012  88 16 0000 R	 	        MOV     [SIGN],DL       ;Record the sign
  150	 0016  E8 0163 R	 	        CALL    ASCINT          ;Convert it to ASCII
  151	 0019  B2 00	 	 	        MOV     DL,0            ;Base 10 exponent is zero
  152	 001B  E9 00D7 R	 	        JMP     COUNTDIG
  153	 	 	 	 	
  154	 001E	 	 	 	ZERO:
  155	 001E  C6 06 0000 R 20	 	        MOV     [SIGN]," "      ;Show positive sign
  156	 0023  B9 0001	 	 	        MOV     CX,1            ;Only one digit
  157	 0026  B2 00	 	 	        MOV     DL,0            ;Zero base 10 exponent
  158	 0028  BE 0024 R	 	        MOV     SI,OFFSET DC:BUF
  159	 002B  C6 04 30	 	 	        MOV     BYTE PTR [SI],"0"
  160	 002E  C3	 	 	        RET
  161	 	 	 	 	
  162	 	 	 	 	


CONASC - Convert number to ASCII                                 Macro-86 %1(12)   0:58:40   13-Nov-81   Page 1-4



  163	 	 	 	 	;***  CONASC - Convert number to ASCII
  164	 	 	 	 	;
  165	 	 	 	 	; Inputs:
  166	 	 	 	 	;       $AC has integer or SP number OR $DAC has DP number
  167	 	 	 	 	;       VALTYP has type (2=integer, 4=SP, 8=DP)
  168	 	 	 	 	; Function:
  169	 	 	 	 	;       Convert number to a string of ASCII digits with no leading or
  170	 	 	 	 	;       trailing zeros. Return base 10 exponent and count of digits.
  171	 	 	 	 	; Outputs:
  172	 	 	 	 	;       CX = number of significant figures (decimal point to right)
  173	 	 	 	 	;       DL = base 10 exponent
  174	 	 	 	 	;       SI = Address of first digit (non-zero unless number is zero)
  175	 	 	 	 	;       [SIGN] has sign - blank if positive, "-" if negative
  176	 	 	 	 	; Registers:
  177	 	 	 	 	;       Uses all.
  178	 	 	 	 	
  179	 002F	 	 	 	CONASC:
  180	 002F  80 3E 0000 E 04	 	        CMP     [VALTYP],4      ;Check type of number
  181	 0034  72 CA	 	 	        JB      OUTINT
  182	 0036  BB 0099	 	 	        MOV     BX,25+128       ;Desired exponent for SP (plus bias)
  183	 0039  74 03	 	 	        JZ      FIGDIF          ;SP number?
  184	 003B  83 C3 20	 	 	        ADD     BX,32           ;32 bits more for DP
  185	 003E	 	 	 	FIGDIF:
  186	 003E  8A 16 0000 E	 	        MOV     DL,[$FAC]       ;Get exponent
  187	 0042  0A D2	 	 	        OR      DL,DL           ;Is number zero?
  188	 0044  74 D8	 	 	        JZ      ZERO            ;That was easy
  189	 0046  B6 00	 	 	        MOV     DH,0
  190	 0048  2B DA	 	 	        SUB     BX,DX           ;See what we have to do to get desired exp.
  191	 004A  B0 20	 	 	        MOV     AL," "          ;In case its positive
  192	 004C  F6 06 FFFF E 80	 	        TEST    [$FAC-1],80H    ;Check sign bit
  193	 0051  74 02	 	 	        JZ      SETSGN          ;Positive?
  194	 0053  B0 2D	 	 	        MOV     AL,"-"
  195	 0055	 	 	 	SETSGN:
  196	 0055  A2 0000 R	 	        MOV     [SIGN],AL
  197	 0058  8A 87 00BE R	 	        MOV     AL,OFFSET DC:EXPTAB[BX] ;What power of 10 will give us the right exp?
  198	 005C  98	 	 	        CBW
  199	 005D  8B F0	 	 	        MOV     SI,AX
  200	 005F  D1 E6	 	 	        SHL     SI,1            ;8 bytes per entry in power of 10 table
  201	 0061  D1 E6	 	 	        SHL     SI,1
  202	 0063  D1 E6	 	 	        SHL     SI,1
  203	 0065  81 C6 0000 E	 	        ADD     SI,OFFSET DC:PWR10TAB
  204	 0069  8A 64 07	 	 	        MOV     AH,[SI+7]       ;Get base 2 exponent of this power of 10
  205	 006C  02 E2	 	 	        ADD     AH,DL           ;Compute exponent resulting from multiply
  206	 006E  F6 D8	 	 	        NEG     AL              ;Take account of multiplying by power of 10
  207	 0070  50	 	 	        PUSH    AX              ;Save base 2 and base 10 exponents
  208	 0071  80 3E 0000 E 04	 	        CMP     [VALTYP],4      ;SP number?
  209	 0076  75 6F	 	 	        JNZ     OUTDBL          ;If not, go do double precision calculations
  210	 0078  8B 3E 0000 E	 	        MOV     DI,WORD PTR[$AC]  ;Load up number to convert
  211	 007C  8A 0E 0002 E	 	        MOV     CL,[$AC+2]
  212	 0080  8A 5C 06	 	 	        MOV     BL,[SI+6]       ;Load up power of 10
  213	 0083  8A 44 03	 	 	        MOV     AL,BYTE PTR[SI+3]  ;Get byte below least significant
  214	 0086  80 C9 80	 	 	        OR      CL,80H          ;Set im plied bit
  215	 0089  F6 E1	 	 	        MUL     CL              ;Compute least significant partial product
  216	 008B  8B 74 04	 	 	        MOV     SI,[SI+4]


CONASC - Convert number to ASCII                                 Macro-86 %1(12)   0:58:40   13-Nov-81   Page 1-5



  217	 008E  50	 	 	        PUSH    AX
  218	 008F  E8 0000 E	 	        CALL    PMULS           ;Multiply mantissas - result in AX:BX
  219	 0092  5A	 	 	        POP     DX              ;Retrieve least significant partial product
  220	 0093  02 DE	 	 	        ADD     BL,DH           ;Accumulate it
  221	 0095  80 D7 00	 	 	        ADC     BH,0
  222	 0098  15 0000	 	 	        ADC     AX,0
  223	 009B  B6 00	 	 	        MOV     DH,0            ;Shuffle to get result in DX:AL:BL
  224	 009D  8A D4	 	 	        MOV     DL,AH
  225	 009F  8A E0	 	 	        MOV     AH,AL
  226	 00A1  8A C7	 	 	        MOV     AL,BH
  227	 00A3  59	 	 	        POP     CX              ;Recover base 2 exponent
  228	 00A4  51	 	 	        PUSH    CX
  229	 00A5  86 CD	 	 	        XCHG    CL,CH           ;Base 2 exponent in CL
  230	 00A7  81 E1 0007	 	        AND     CX,7            ;We'll be within 4 of desired exponent
  231	 00AB  74 08	 	 	        JZ      RNDTST          ;Hit it exactly?
  232	 	 	 	 	;Exponent did not turn out to be exactly 24 - it could be as much as 29.
  233	 	 	 	 	;For every power of two larger, we must shift another bit into the mantissa,
  234	 	 	 	 	;so that when we're done we have the same number of bits as the exponent says.
  235	 00AD	 	 	 	SHFT:
  236	 00AD  D0 E3	 	 	        SHL     BL,1
  237	 00AF  D1 D0	 	 	        RCL     AX,1
  238	 00B1  D1 D2	 	 	        RCL     DX,1
  239	 00B3  E2 F8	 	 	        LOOP    SHFT
  240	 00B5	 	 	 	RNDTST:
  241	 00B5  BF 0024 R	 	        MOV     DI,OFFSET DC:BUF  ;Save characters in BUF
  242	 00B8  80 FB 80	 	 	        CMP     BL,80H          ;Do we need to round?
  243	 00BB  77 06	 	 	        JA      ROUND           ;Yes
  244	 00BD  72 0A	 	 	        JB      ASCSP           ;No
  245	 00BF  A8 01	 	 	        TEST    AL,1            ;Maybe - round even
  246	 00C1  74 06	 	 	        JZ      ASCSP
  247	 00C3	 	 	 	ROUND:
  248	 00C3  05 0001	 	 	        ADD     AX,1            ;Round up
  249	 00C6  83 D2 00	 	 	        ADC     DX,0            ;Propagate carry
  250	 00C9	 	 	 	ASCSP:
  251	 00C9  BB 2710	 	 	        MOV     BX,10000        ;Break number in to 2 manageable chunks
  252	 00CC  F7 F3	 	 	        DIV     BX
  253	 00CE  52	 	 	        PUSH    DX              ;Save low half for later
  254	 00CF  E8 0163 R	 	        CALL    ASCINT          ;Convert high 5 digits
  255	 00D2  5A	 	 	        POP     DX
  256	 00D3  E8 0173 R	 	        CALL    ASC10K          ;Convert last 4 digits
  257	 00D6  5A	 	 	        POP     DX              ;DL = base 10 exponent
  258	 00D7	 	 	 	COUNTDIG:
  259	 00D7  8B CF	 	 	        MOV     CX,DI
  260	 00D9  BF 0024 R	 	        MOV     DI,OFFSET DC:BUF
  261	 00DC  2B CF	 	 	        SUB     CX,DI           ;Number of digits converted
  262	 00DE  B0 30	 	 	        MOV     AL,"0"
  263	 00E0  F3/ AE	 	 	        REPE    SCASB           ;Scan off leading zeros
  264	 00E2  41	 	 	        INC     CX              ;Number of digits left
  265	 00E3  4F	 	 	        DEC     DI              ;Point to first digit
  266	 00E4  8B F7	 	 	        MOV     SI,DI
  267	 00E6  C3	 	 	        RET
  268	 	 	 	 	
  269	 00E7	 	 	 	OUTDBL:
  270	 00E7  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC


CONASC - Convert number to ASCII                                 Macro-86 %1(12)   0:58:40   13-Nov-81   Page 1-6



  271	 00EA  E8 0000 E	 	        CALL    PMULD           ;Result in DI:BX:CX:DX
  272	 00ED  8A C5	 	 	        MOV     AL,CH           ;Get result in BX:BP:DI:AX:DL
  273	 00EF  8A E3	 	 	        MOV     AH,BL
  274	 00F1  97	 	 	        XCHG    AX,DI
  275	 00F2  8A DC	 	 	        MOV     BL,AH
  276	 00F4  8A E0	 	 	        MOV     AH,AL
  277	 00F6  8A C7	 	 	        MOV     AL,BH
  278	 00F8  95	 	 	        XCHG    AX,BP
  279	 00F9  B7 00	 	 	        MOV     BH,0
  280	 00FB  8A C6	 	 	        MOV     AL,DH
  281	 00FD  8A E1	 	 	        MOV     AH,CL
  282	 00FF  59	 	 	        POP     CX              ;Recover base 2 exponent
  283	 0100  51	 	 	        PUSH    CX
  284	 0101  86 CD	 	 	        XCHG    CL,CH           ;Base 2 exponent in CL
  285	 0103  81 E1 0007	 	        AND     CX,7            ;We'll be within 4 of desired exponent
  286	 0107  74 0C	 	 	        JZ      DRNDTST         ;Hit it exactly?
  287	 	 	 	 	;Exponent did not turn out to be exactly 56 - it could be as much as 61.
  288	 	 	 	 	;For every power of two larger, we must shift another bit into the mantissa,
  289	 	 	 	 	;so that when we're done we have the sa me number of bits as the exponent says.
  290	 0109	 	 	 	DSHFT:
  291	 0109  D0 E2	 	 	        SHL     DL,1
  292	 010B  D1 D0	 	 	        RCL     AX,1
  293	 010D  D1 D7	 	 	        RCL     DI,1
  294	 010F  D1 D5	 	 	        RCL     BP,1
  295	 0111  D1 D3	 	 	        RCL     BX,1
  296	 0113  E2 F4	 	 	        LOOP    DSHFT
  297	 0115	 	 	 	DRNDTST:
  298	 0115  80 FA 80	 	 	        CMP     DL,80H          ;Need to round?
  299	 0118  77 06	 	 	        JA      DROUND          ;Yes
  300	 011A  72 10	 	 	        JB      DPCONV          ;No
  301	 011C  A8 01	 	 	        TEST    AL,1            ;Maybe - round even
  302	 011E  74 0C	 	 	        JZ      DPCONV
  303	 0120	 	 	 	DROUND:
  304	 0120  05 0001	 	 	        ADD     AX,1
  305	 0123  83 D7 00	 	 	        ADC     DI,0
  306	 0126  83 D5 00	 	 	        ADC     BP,0
  307	 0129  83 D3 00	 	 	        ADC     BX,0
  308	 012C	 	 	 	DPCONV:
  309	 012C  8B D7	 	 	        MOV     DX,DI           ;Number now in BX:BP:DX:AX
  310	 012E  BF 0024 R	 	        MOV     DI,OFFSET DC:BUF  ;Save characters in BUF
  311	 0131  B9 000B	 	 	        MOV     CX,11           ;19 digits - last 8 handled by SP converter
  312	 0134  BE 0000 R	 	        MOV     SI,OFFSET DC:DPCON      ;Table of powers of 10
  313	 0137	 	 	 	DPDIG:
  314	 0137  2B 04	 	 	        SUB     AX,[SI]         ;Subtract a power of 10
  315	 0139  1B 54 02	 	 	        SBB     DX,[SI+2]
  316	 013C  1B 6C 04	 	 	        SBB     BP,[SI+4]
  317	 013F  1B 5C 06	 	 	        SBB     BX,[SI+6]
  318	 0142  FE C5	 	 	        INC     CH              ;Count in case successful
  319	 0144  73 F1	 	 	        JNC     DPDIG           ;Divide by 10^X by repeat subtraction
  320	 	 	 	 	;We subtracted one too many, so restore
  321	 0146  03 04	 	 	        ADD     AX,[SI]
  322	 0148  13 54 02	 	 	        ADC     DX,[SI+2]
  323	 014B  13 6C 04	 	 	        ADC     BP,[SI+4]
  324	 014E  13 5C 06	 	 	        ADC     BX,[SI+6]


CONASC - Convert number to ASCII                                 Macro-86 %1(12)   0:58:40   13-Nov-81   Page 1-7



  325	 0151  FE CD	 	 	        DEC     CH
  326	 0153  83 C6 08	 	 	        ADD     SI,8            ;Bump up to next power of 10
  327	 0156  80 CD 30	 	 	        OR      CH,"0"
  328	 0159  88 2D	 	 	        MOV     [DI],CH         ;Store the digit
  329	 015B  47	 	 	        INC     DI
  330	 015C  B5 00	 	 	        MOV     CH,0            ;Initialize count for next power of 10
  331	 015E  E2 D7	 	 	        LOOP    DPDIG
  332	 	 	 	 	;What we have left now is a number in DX:AX < 10^8
  333	 0160  E9 00C9 R	 	        JMP     ASCSP
  334	 	 	 	 	
  335	 	 	 	 	
  336	 	 	 	 	;***  ASCINT = Convert 2-byte integer to ASCII
  337	 	 	 	 	;
  338	 	 	 	 	; Inputs:
  339	 	 	 	 	;       AX = integer
  340	 	 	 	 	;       DI = pointer to digit buffer
  341	 	 	 	 	; Function:
  342	 	 	 	 	;       Convert the integer to 5 unpacked BCD digits, stored at [DI].
  343	 	 	 	 	; Outputs:
  344	 	 	 	 	;       None.
  345	 	 	 	 	; Registers:
  346	 	 	 	 	;       All destroyed.
  347	 	 	 	 	
  348	 0163	 	 	 	ASCINT:
  349	 0163  33 D2	 	 	        XOR     DX,DX
  350	 0165  92	 	 	        XCHG    AX,DX
  351	 0166  BB 2710	 	 	        MOV     BX,10000
  352	 0169  3B D3	 	 	        CMP     DX,BX           ;Any 10000's digits?
  353	 016B  72 06	 	 	        JB      ASC10K          ;If not, skip division
  354	 016D  92	 	 	        XCHG    AX,DX
  355	 016E  F7 F3	 	 	        DIV     BX              ;Compute 10000's digit
  356	 0170  04 30	 	 	        ADD     AL,"0"
  357	 0172  AA	 	 	        STOSB
  358	 0173	 	 	 	ASC10K:
  359	 	 	 	 	; Convert integer in DX <10^4 to unpacked BCD
  360	 0173  33 C0	 	 	        XOR     AX,AX
  361	 0175  BB 0A64	 	 	        MOV     BX,10*100H+100  ;10 in BH, 100 in BL
  362	 0178  83 FA 64	 	 	        CMP     DX,100          ;Any 100's or 1000's digits?
  363	 017B  72 07	 	 	        JB      STO10           ;If not, skip division
  364	 017D  92	 	 	        XCHG    AX,DX
  365	 017E  F6 F3	 	 	        DIV     BL              ;Separate 100's and 1000's
  366	 0180  86 E2	 	 	        XCHG    AH,DL           ;Save remainder and extend with a zero
  367	 0182  F6 F7	 	 	        DIV     BH              ;Divide by 10 to get 100's and 1000's digits
  368	 0184	 	 	 	STO10:
  369	 0184  0D 3030	 	 	        OR      AX,"00"
  370	 0187  AB	 	 	        STOSW
  371	 0188  92	 	 	        XCHG    AX,DX
  372	 0189  F6 F7	 	 	        DIV     BH              ;Divide by 10 to get 1's and 10's digits
  373	 018B  0D 3030	 	 	        OR      AX,"00"
  374	 018E  AB	 	 	        STOSW
  375	 018F  C3	 	 	        RET
  376	 	 	 	 	
  377	 	 	 	 	
  378	 	 	 	 	;***    $TYPUI - Type unsigned integer


CONASC - Convert number to ASCII                                 Macro-86 %1(12)   0:58:40   13-Nov-81   Page 1-8



  379	 	 	 	 	;
  380	 	 	 	 	; Inputs:
  381	 	 	 	 	;       AX = number to print
  382	 	 	 	 	; Function:
  383	 	 	 	 	;       Print a 16-bit unsigned integer to console with zero suppression.
  384	 	 	 	 	; Registers:
  385	 	 	 	 	;       All destroyed
  386	 	 	 	 	
  387	 0190	 	 	 	$TYPUI:
  388	 0190  BF 0024 R	 	        MOV     DI,OFFSET DC:BUF        ;Try to use existing routines
  389	 0193  E8 0163 R	 	        CALL    ASCINT                  ;Convert to ASCII in BUF
  390	 0196  E8 00D7 R	 	        CALL    COUNTDIG                ;Skip leading zeroes
  391	 	 	 	 	
  392	 0199  AC	 	 	typlop: LODSB                           ;Get character
  393	 019A  E8 0000 E	 	        CALL    $$WCHT
  394	 019D  E2 FA	 	 	        LOOP    typlop                  ;Keep looping until CX=0
  395	 019F  C3	 	 	        RET
  396	 	 	 	 	
  397	 	 	 	 	
  398	 	 	 	 	;***  ASCRND - Round ASCII digits
  399	 	 	 	 	;
  400	 	 	 	 	; Inputs:
  401	 	 	 	 	;       AL = Number of digits wanted
  402	 	 	 	 	;       CX = Number of digits presently in number
  403	 	 	 	 	;       DL = Base 10 exponent (D.P. to right of digits)
  404	 	 	 	 	;       SI = Address of first digit
  405	 	 	 	 	; Function:
  406	 	 	 	 	;       Round number to the specified number of digits. Eliminate trailing
  407	 	 	 	 	;       zeros from digit count.
  408	 	 	 	 	; Outputs:
  409	 	 	 	 	;       CX = Number of digits now in number (always <= request)
  410	 	 	 	 	;       DL = Base 10 exponent of rounded number
  411	 	 	 	 	;       SI = Address of first digit of rounded number
  412	 	 	 	 	;       DI = Address of formatting buffer, FOBUF
  413	 	 	 	 	; Registers:
  414	 	 	 	 	;       Only BX, BP preserved.
  415	 	 	 	 	
  416	 01A0	 	 	 	ASCRND:
  417	 01A0  8B FE	 	 	        MOV     DI,SI
  418	 01A2  98	 	 	        CBW                     ;Zero AH (AL <= 18)
  419	 01A3  03 F9	 	 	        ADD     DI,CX           ;Point past last digit
  420	 01A5  3B C1	 	 	        CMP     AX,CX           ;Any extra digits?
  421	 01A7  73 22	 	 	        JAE     ZSCAN           ;If not, no rounding
  422	 01A9  91	 	 	        XCHG    AX,CX           ;Say we'll return number requested
  423	 01AA  2B C1	 	 	        SUB     AX,CX           ;See how many digits we're trimming
  424	 01AC  02 D0	 	 	        ADD     DL,AL           ;Increase exponent accordingly
  425	 01AE  2B F8	 	 	        SUB     DI,AX           ;Point to first extra digit
  426	 01B0  B0 30	 	 	        MOV     AL,"0"
  427	 01B2  86 05	 	 	        XCHG    AL,[DI]         ;Get rounding digit and replace it with zero
  428	 01B4  3C 35	 	 	        CMP     AL,"5"          ;Do we need to round?
  429	 01B6  72 13	 	 	        JB      ZSCAN
  430	 01B8  E3 0D	 	 	        JCXZ    RNDALL
  431	 01BA	 	 	 	RND:
  432	 01BA  4F	 	 	        DEC     DI              ;Point to digit to round


CONASC - Convert number to ASCII                                 Macro-86 %1(12)   0:58:40   13-Nov-81   Page 1-9



  433	 01BB  8A 05	 	 	        MOV     AL,[DI]         ;Get a digit that needs incrementing
  434	 01BD  FE C0	 	 	        INC     AL
  435	 01BF  3C 3A	 	 	        CMP     AL,"9"+1        ;Did we overflow this digit position?
  436	 01C1  72 07	 	 	        JB      STORND          ;If not, store it and we're done
  437	 01C3  FE C2	 	 	        INC     DL              ;Otherwise exponent must be adjusted
  438	 01C5  E2 F3	 	 	        LOOP    RND             ;We'll need to round next digit
  439	 01C7	 	 	 	RNDALL:
  440	 01C7  41	 	 	        INC     CX              ;Must have at least one digit
  441	 01C8  B0 31	 	 	        MOV     AL,"1"          ;If we rounded all digits, must be to 1
  442	 01CA	 	 	 	STORND:
  443	 01CA  AA	 	 	        STOSB                   ;Save rounded digit
  444	 01CB	 	 	 	ZSCAN:
  445	 	 	 	 	;DI points just past the digits we want. Check for trailing zeros.
  446	 01CB  4F	 	 	        DEC     DI              ;Point to last digit
  447	 01CC  8A E1	 	 	        MOV     AH,CL           ;Remember how many digits we started with
  448	 01CE  B0 30	 	 	        MOV     AL,"0"
  449	 01D0  FD	 	 	        STD                     ;Scan DOWN
  450	 01D1  F3/ AE	 	 	        REPE    SCASB           ;Scan for "0"s
  451	 01D3  FC	 	 	        CLD                     ;Restore direction UP
  452	 01D4  41	 	 	        INC     CX              ;Number of digits left
  453	 01D5  2A E1	 	 	        SUB     AH,CL           ;Number of digits skipped
  454	 01D7  02 D4	 	 	        ADD     DL,AH           ;Increase base 10 exponent accordingly
  455	 01D9  BF 0001 R	 	        MOV     DI,OFFSET DC:FOBUF
  456	 01DC  C3	 	 	        RET
  457	 	 	 	 	
  458	 01DD	 	 	 	CODE    ENDS
  459	 	 	 	 	        END





























CONASC - Convert number to ASCII                                 Macro-86 %1(12)   0:58:40   13-Nov-81   Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	01DD	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  CONST. . . . . . . . . . . . . .	0177	WORD  	PUBLIC	'CONST'
  DATA . . . . . . . . . . . . . .	0038	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ASC10K . . . . . . . . . . . . .	L NEAR 	0173	CODE
ASCINT . . . . . . . . . . . . .	L NEAR 	0163	CODE
ASCRND . . . . . . . . . . . . .	L NEAR 	01A0	CODE	Global
ASCSP. . . . . . . . . . . . . .	L NEAR 	00C9	CODE
BUF. . . . . . . . . . . . . . .	L BYTE 	0024	DATA	Length =0014
CONASC . . . . . . . . . . . . .	L NEAR 	002F	CODE	Global
COUNTDIG . . . . . . . . . . . .	L NEAR 	00D7	CODE
DPCON. . . . . . . . . . . . . .	L WORD 	0000	CONST
DPCONV . . . . . . . . . . . . .	L NEAR 	012C	CODE
DPDIG. . . . . . . . . . . . . .	L NEAR 	0137	CODE
DRNDTST. . . . . . . . . . . . .	L NEAR 	0115	CODE
DROUND . . . . . . . . . . . . .	L NEAR 	0120	CODE
DSHFT. . . . . . . . . . . . . .	L NEAR 	0109	CODE
EXPTAB . . . . . . . . . . . . .	L BYTE 	00BE	CONST
FIGDIF . . . . . . . . . . . . .	L NEAR 	003E	CODE
FOBUF. . . . . . . . . . . . . .	L BYTE 	0001	DATA	Global	Length =0023
OUTDBL . . . . . . . . . . . . .	L NEAR 	00E7	CODE
OUTINT . . . . . . . . . . . . .	L NEAR 	0000	CODE
PMULD. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
PMULS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
PWR10TAB . . . . . . . . . . . .	V WORD 	0000	CONST	External
RND. . . . . . . . . . . . . . .	L NEAR 	01BA	CODE
RNDALL . . . . . . . . . . . . .	L NEAR 	01C7	CODE
RNDTST . . . . . . . . . . . . .	L NEAR 	00B5	CODE
ROUND. . . . . . . . . . . . . .	L NEAR 	00C3	CODE
SAVSGN . . . . . . . . . . . . .	L NEAR 	0012	CODE
SETSGN . . . . . . . . . . . . .	L NEAR 	0055	CODE
SHFT . . . . . . . . . . . . . .	L NEAR 	00AD	CODE
SIGN . . . . . . . . . . . . . .	L BYTE 	0000	DATA	Global
STO10. . . . . . . . . . . . . .	L NEAR 	0184	CODE
STORND . . . . . . . . . . . . .	L NEAR 	01CA	CODE
TYPLOP . . . . . . . . . . . . .	L NEAR 	0199	CODE
VALTYP . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
ZERO . . . . . . . . . . . . . .	L NEAR 	001E	CODE
ZSCAN. . . . . . . . . . . . . .	L NEAR 	01CB	CODE
$$WCHT . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$AC. . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$DAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$TYPUI . . . . . . . . . . . . .	L NEAR 	0190	CODE	Global

Warning Severe
Errors	Errors 
0	0
