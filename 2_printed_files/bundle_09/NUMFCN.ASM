NUMFCN - Arithmetic functions                            Macro-86 %1(12)   1:6:14  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   NUMFCN - Arithmetic functions
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $FAC:BYTE, $AC:WORD, $DAC:WORD
    6	 	 	 	 	
    7	 0000  ????	 	 	SISAVE  DW      ?
    8	 	 	 	 	
    9	 0002	 	 	 	DATA    ENDS
   10	 	 	 	 	
   11	 	 	 	 	
   12	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
   13	 	 	 	 	
   14	 0000  00 80 C0 E0 F0 F8	FIXTAB  DB      0,80H,0C0H,0E0H,0F0H,0F8H,0FCH,0FEH
   15	       FC FE	 	 	
   16	 	 	 	 	
   17	 0008	 	 	 	CONST   ENDS
   18	 	 	 	 	
   19	 	 	 	 	DC      GROUP   CONST,DATA
   20	 	 	 	 	
   21	 	 	 	 	
   22	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   23	 	 	 	 	
   24	 	 	 	 	        PUBLIC  $FUMA,$FUMB,$FUMC,$FUMD,$SGNA,$SGNB,$SGNC,$SGND
   25	 	 	 	 	        PUBLIC  $FC0A,$FC0B,$FC0C,$FC0D,$CNZA,$CNZB,$CNZC,$CNZD
   26	 	 	 	 	        PUBLIC  $FIX, $FID, $INT, $IND, $ABSA,$ABSB,$ABSC,$ABSD
   27	 	 	 	 	        PUBLIC  $FSHA,$FSHB,$FSHC,$FSHD
   28	 	 	 	 	
   29	 	 	 	 	        EXTRN   $OVFL:NEAR
   30	 	 	 	 	
   31	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   32	 	 	 	 	
   33	 0000	 	 	 	NUMFCN  PROC    FAR             ;Set up long returns
   34	 	 	 	 	
   35	 	 	 	 	
   36	 	 	 	 	;***  $FUM - Floating unary minus
   37	 	 	 	 	;
   38	 	 	 	 	; Inputs:
   39	 	 	 	 	;       SI = Address of argument ($FUMA/$FUMB)
   40	 	 	 	 	;       $FAC has argument ($FUMC/$FUMD)
   41	 	 	 	 	; Function:
   42	 	 	 	 	;       Invert sign
   43	 	 	 	 	; Outputs:
   44	 	 	 	 	;       Result in FAC.
   45	 	 	 	 	; Registers:
   46	 	 	 	 	;       Only F affected.
   47	 	 	 	 	
   48	 0000	 	 	 	$FUMA:  ;Single precision
   49	 0000  E8 0178 R	 	        CALL    PUTAC
   50	 0003	 	 	 	$FUMC:
   51	 0003  80 36 FFFF E 80	 	        XOR     [$FAC-1],80H
   52	 0008  CB	 	 	        RET
   53	 	 	 	 	
   54	 0009	 	 	 	$FUMB:  ;Double precision


NUMFCN - Arithmetic functions                            Macro-86 %1(12)   1:6:14  13-Nov-81    Page 1-2



   55	 0009  E8 0183 R	 	        CALL    PUTDAC
   56	 000C	 	 	 	$FUMD:
   57	 000C  80 36 FFFF E 80	 	        XOR     [$FAC-1],80H
   58	 0011  CB	 	 	        RET
   59	 	 	 	 	
   60	 	 	 	 	
   61	 	 	 	 	;***  $SIGN - SGN function
   62	 	 	 	 	;
   63	 	 	 	 	; Inputs:
   64	 	 	 	 	;       SI = Address of argument ($SGNA/$SGNB)
   65	 	 	 	 	;       FAC has argument ($SGNC/$SGND)
   66	 	 	 	 	; Function:
   67	 	 	 	 	;       Return 1 if argument positive
   68	 	 	 	 	;       Return 0 if argument zero
   69	 	 	 	 	;       Return -1 if argument negative
   70	 	 	 	 	; Outputs:
   71	 	 	 	 	;       FAC has result, same type as argument
   72	 	 	 	 	; Registers:
   73	 	 	 	 	;       Only F affected.
   74	 	 	 	 	
   75	 0012	 	 	 	$SGNA:  ;Single precision
   76	 0012  50	 	 	        PUSH    AX
   77	 0013  8B 44 02	 	 	        MOV     AX,[SI+2]       ;Get sign and exponent
   78	 0016  EB 04	 	 	        JMP     SHORT SGN
   79	 	 	 	 	
   80	 0018	 	 	 	$SGNC:
   81	 0018	 	 	 	$SGND:
   82	 0018  50	 	 	        PUSH    AX
   83	 0019  A1 0002 E	 	        MOV     AX,[$AC+2]
   84	 001C	 	 	 	SGN:
   85	 001C  0A E4	 	 	        OR      AH,AH           ;Check exponent for zero
   86	 001E  74 04	 	 	        JZ      SAVSGN
   87	 0020  B4 81	 	 	        MOV     AH,81H          ;Set exponent for +1 or -1
   88	 0022  24 80	 	 	        AND     AL,80H          ;Reduce to sign bit
   89	 0024	 	 	 	SAVSGN:
   90	 0024  A3 0002 E	 	        MOV     [$AC+2],AX
   91	 0027  33 C0	 	 	        XOR     AX,AX
   92	 0029  A3 0000 E	 	        MOV     [$DAC],AX
   93	 002C  A3 0002 E	 	        MOV     [$DAC+2],AX
   94	 002F  A3 0000 E	 	        MOV     [$AC],AX
   95	 0032  58	 	 	        POP     AX
   96	 0033  CB	 	 	        RET
   97	 	 	 	 	
   98	 0034	 	 	 	$SGNB:  ;Double precision
   99	 0034  50	 	 	        PUSH    AX
  100	 0035  8B 44 06	 	 	        MOV     AX,[SI+6]       ;Get sign and exponent
  101	 0038  EB E2	 	 	        JMP     SGN
  102	 	 	 	 	
  103	 	 	 	 	
  104	 	 	 	 	;***  $FC0 - Floating compare for zero
  105	 	 	 	 	;
  106	 	 	 	 	; Inputs:
  107	 	 	 	 	;       SI = Address of argument ($FC0A/$FC0B)
  108	 	 	 	 	;       $FAC has argument ($FC0C/$FC0D)


NUMFCN - Arithmetic functions                            Macro-86 %1(12)   1:6:14  13-Nov-81    Page 1-3



  109	 	 	 	 	; Function:
  110	 	 	 	 	;       Compare the floating point number against zero, setting ZF and CF.
  111	 	 	 	 	; Outputs:
  112	 	 	 	 	;       Positive: ZF=0, CF=0, Zero: ZF=1, CF=0; Negative: ZF=0, CF=1.
  113	 	 	 	 	; Registers:
  114	 	 	 	 	;       Only F affected.
  115	 	 	 	 	
  116	 003A	 	 	 	$FC0A:  ;Single precision
  117	 003A  50	 	 	        PUSH    AX
  118	 003B  8B 44 02	 	 	        MOV     AX,[SI+2]
  119	 003E	 	 	 	FC0:
  120	 003E  0A E4	 	 	        OR      AH,AH           ;Exponent zero?
  121	 0040  74 02	 	 	        JZ      PRET
  122	 0042  D0 D0	 	 	        RCL     AL,1            ;Rotate sign into carry
  123	 0044	 	 	 	PRET:
  124	 0044  58	 	 	        POP     AX
  125	 0045  CB	 	 	        RET
  126	 	 	 	 	
  127	 0046	 	 	 	$FC0B:  ;Double precision
  128	 0046  50	 	 	        PUSH    AX
  129	 0047  8B 44 06	 	 	        MOV     AX,[SI+6]
  130	 004A  EB F2	 	 	        JMP     FC0
  131	 	 	 	 	
  132	 004C	 	 	 	$FC0C:
  133	 004C	 	 	 	$FC0D:
  134	 004C  50	 	 	        PUSH    AX
  135	 004D  A1 0002 E	 	        MOV     AX,[$AC+2]
  136	 0050  EB EC	 	 	        JMP     FC0
  137	 	 	 	 	
  138	 	 	 	 	
  139	 	 	 	 	;***  $CNZ - Compare for non-zero
  140	 	 	 	 	;
  141	 	 	 	 	; Inputs:
  142	 	 	 	 	;       SI = Address of argument ($CNZA/$CNZB)
  143	 	 	 	 	;       $FAC has argument ($CNZC/$CNZD)
  144	 	 	 	 	; Function:
  145	 	 	 	 	;       Return integer 0 if argument 0, integer -1 otherwise
  146	 	 	 	 	; Outputs:
  147	 	 	 	 	;       Result in BX
  148	 	 	 	 	; Registers:
  149	 	 	 	 	;       Only BX affected.
  150	 	 	 	 	
  151	 0052	 	 	 	$CNZA:  ;Single precision
  152	 0052  33 DB	 	 	        XOR     BX,BX
  153	 0054  80 7C 03 00	 	        CMP     BYTE PTR[SI+3],0
  154	 0058  74 16	 	 	        JZ      RET
  155	 005A  4B	 	 	        DEC     BX
  156	 005B  CB	 	 	        RET
  157	 	 	 	 	
  158	 005C	 	 	 	$CNZB:  ;Double precision
  159	 005C  33 DB	 	 	        XOR     BX,BX
  160	 005E  80 7C 07 00	 	        CMP     BYTE PTR[SI+7],0
  161	 0062  74 0C	 	 	        JZ      RET
  162	 0064  4B	 	 	        DEC     BX


NUMFCN - Arithmetic functions                            Macro-86 %1(12)   1:6:14  13-Nov-81    Page 1-4



  163	 0065  CB	 	 	        RET
  164	 	 	 	 	
  165	 0066	 	 	 	$CNZC:
  166	 0066	 	 	 	$CNZD:
  167	 0066  33 DB	 	 	        XOR     BX,BX
  168	 0068  80 3E 0000 E 00	 	        CMP     [$FAC],0
  169	 006D  74 01	 	 	        JZ      RET
  170	 006F  4B	 	 	        DEC     BX
  171	 0070  CB	 	 	RET:    RET
  172	 	 	 	 	
  173	 	 	 	 	
  174	 	 	 	 	;***  $ABS - Absolute value function
  175	 	 	 	 	;
  176	 	 	 	 	; Inputs:
  177	 	 	 	 	;       SI = Address of argument  ($ABSA/$ABSC)
  178	 	 	 	 	;       FAC = argument  ($ABSB/$ABSD)
  179	 	 	 	 	; Outputs:
  180	 	 	 	 	;       Absolute value in FAC
  181	 	 	 	 	; Registers:
  182	 	 	 	 	;       Only F affected.
  183	 	 	 	 	
  184	 0071	 	 	 	$ABSA:  ;Single precision
  185	 0071  E8 0178 R	 	        CALL    PUTAC
  186	 0074  80 26 FFFF E 7F	 	$ABSC:  AND     [$FAC-1],7FH    ;Force sign positive
  187	 0079  CB	 	 	        RET
  188	 	 	 	 	
  189	 007A	 	 	 	$ABSB:  ;Double precision
  190	 007A  E8 0183 R	 	        CALL    PUTDAC
  191	 007D  80 26 FFFF E 7F	 	$ABSD:  AND     [$FAC-1],7FH
  192	 0082  CB	 	 	        RET
  193	 	 	 	 	
  194	 	 	 	 	
  195	 	 	 	 	;***  $FSH - Floating shift
  196	 	 	 	 	;
  197	 	 	 	 	; Inputs:
  198	 	 	 	 	;       SI = Address of argument ($FSHA/$FSHB)
  199	 	 	 	 	;       $FAC has argument ($FSHC/$FSHD)
  200	 	 	 	 	;       Long return address on top of stack pointer to a byte.
  201	 	 	 	 	; Function:
  202	 	 	 	 	;       Add byte to exponent of floating point number.
  203	 	 	 	 	; Outputs:
  204	 	 	 	 	;       Result in FAC.
  205	 	 	 	 	; Registers:
  206	 	 	 	 	;       Only F affected.
  207	 	 	 	 	
  208	 0083	 	 	 	$FSHA:  ;Single precision
  209	 0083  E8 0178 R	 	        CALL    PUTAC
  210	 0086	 	 	 	$FSHC:
  211	 0086	 	 	 	$FSHD:
  212	 0086  89 36 0000 R	 	        MOV     [SISAVE],SI
  213	 008A  5E	 	 	        POP     SI
  214	 008B  1F	 	 	        POP     DS              ;Get pointer to power
  215	 008C  50	 	 	        PUSH    AX
  216	 008D  AC	 	 	        LODSB


NUMFCN - Arithmetic functions                            Macro-86 %1(12)   1:6:14  13-Nov-81    Page 1-5



  217	 008E  00 06 0000 E	 	        ADD     [$FAC],AL       ;Add byte to exponent
  218	 0092  58	 	 	        POP     AX
  219	 0093  1E	 	 	        PUSH    DS
  220	 0094  56	 	 	        PUSH    SI
  221	 0095  06	 	 	        PUSH    ES
  222	 0096  1F	 	 	        POP     DS              ;Restore DS
  223	 0097  8B 36 0000 R	 	        MOV     SI,[SISAVE]
  224	 009B  73 D3	 	 	        JNC     RET
  225	 009D  E9 0000 E	 	        JMP     $OVFL
  226	 	 	 	 	
  227	 00A0	 	 	 	$FSHB:
  228	 00A0  E8 0183 R	 	        CALL    PUTDAC
  229	 00A3  EB E1	 	 	        JMP     $FSHD
  230	 	 	 	 	
  231	 	 	 	 	
  232	 	 	 	 	;*** $FIX - Get integer part of argument, chopped toward zero
  233	 	 	 	 	;
  234	 	 	 	 	; Inputs:
  235	 	 	 	 	;       BX = Address of argument
  236	 	 	 	 	; Function:
  237	 	 	 	 	;       Compute integer part, chopped toward zero (-12.5 -> -12).
  238	 	 	 	 	;       $FIX is for single precision, $FID is for double precision.
  239	 	 	 	 	; Outputs:
  240	 	 	 	 	;       Result in $FAC, same type as argument (SP or DP)
  241	 	 	 	 	; Registers:
  242	 	 	 	 	;       Only F affected.
  243	 	 	 	 	
  244	 00A5	 	 	 	$FIX:   ;Single precision
  245	 00A5  87 F3	 	 	        XCHG    SI,BX
  246	 00A7  E8 0178 R	 	        CALL    PUTAC
  247	 00AA  87 F3	 	 	        XCHG    SI,BX
  248	 00AC  51	 	 	        PUSH    CX
  249	 00AD  B9 0002	 	 	        MOV     CX,2
  250	 00B0	 	 	 	DOFIX:
  251	 00B0  E8 0126 R	 	        CALL    FIX
  252	 00B3  59	 	 	        POP     CX
  253	 00B4  CB	 	 	        RET
  254	 	 	 	 	
  255	 00B5	 	 	 	$FID:   ;Double precision
  256	 00B5  87 F3	 	 	        XCHG    SI,BX
  257	 00B7  E8 0183 R	 	        CALL    PUTDAC
  258	 00BA  87 F3	 	 	        XCHG    SI,BX
  259	 00BC  51	 	 	        PUSH    CX
  260	 00BD  B9 0006	 	 	        MOV     CX,6
  261	 00C0  E8 0126 R	 	        CALL    FIX
  262	 00C3	 	 	 	RETC:
  263	 00C3  59	 	 	        POP     CX
  264	 00C4  CB	 	 	        RET
  265	 	 	 	 	
  266	 	 	 	 	
  267	 	 	 	 	;*** $INT - Floor function
  268	 	 	 	 	;
  269	 	 	 	 	; Inputs:
  270	 	 	 	 	;       BX = Address of argument


NUMFCN - Arithmetic functions                            Macro-86 %1(12)   1:6:14  13-Nov-81    Page 1-6



  271	 	 	 	 	; Function:
  272	 	 	 	 	;       Compute largest integer <= argument. Thus -12.5 -> -13.
  273	 	 	 	 	;       $INT is for single precision, $IND is for double precision.
  274	 	 	 	 	; Outputs:
  275	 	 	 	 	;       Result in $FAC, same type as argument (SP or DP).
  276	 	 	 	 	; Registers:
  277	 	 	 	 	;       Only F affected.
  278	 	 	 	 	
  279	 00C5	 	 	 	$INT:
  280	 00C5  87 F3	 	 	        XCHG    SI,BX
  281	 00C7  E8 0178 R	 	        CALL    PUTAC
  282	 00CA  87 F3	 	 	        XCHG    SI,BX
  283	 00CC  51	 	 	        PUSH    CX
  284	 00CD  B9 0002	 	 	        MOV     CX,2
  285	 00D0	 	 	 	INT:
  286	 00D0  80 3E 0000 E 00	 	        CMP     [$FAC], 0       ;Is FAC zero?
  287	 00D5  74 EC	 	 	        JZ      RETC            ;If so, done already
  288	 00D7  F6 06 FFFF E 80	 	        TEST    [$FAC-1],80H    ;Check sign bit
  289	 00DC  74 D2	 	 	        JZ      DOFIX           ;If positive, just do FIX
  290	 00DE  51	 	 	        PUSH    CX
  291	 00DF  E8 015D R	 	        CALL    NEGATE          ;Use two's complement
  292	 00E2  59	 	 	        POP     CX
  293	 00E3  51	 	 	        PUSH    CX
  294	 00E4  E8 0126 R	 	        CALL    FIX
  295	 00E7  59	 	 	        POP     CX
  296	 00E8  80 3E 0000 E 00	 	        CMP     [$FAC],0        ;Was magnitude less than 1?
  297	 00ED  74 14	 	 	        JZ      MINUSONE
  298	 00EF  E8 015D R	 	        CALL    NEGATE          ;Fix it back
  299	 00F2  59	 	 	        POP     CX
  300	 00F3  75 23	 	 	        JNZ     RET1            ;Did we overflow?
  301	 00F5  C6 06 FFFF E 80	 	        MOV     [$FAC-1],80H    ;Yes - set sign bit
  302	 00FA  FE 06 0000 E	 	        INC     [$FAC]          ;Bump exponent
  303	 00FE  75 18	 	 	        JNZ     RET1
  304	 0100  E9 0000 E	 	        JMP     $OVFL
  305	 	 	 	 	
  306	 0103	 	 	 	MINUSONE:
  307	 0103  33 C9	 	 	        XOR     CX,CX
  308	 0105  89 0E 0000 E	 	        MOV     [$DAC],CX       ;Force -1 as result
  309	 0109  89 0E 0002 E	 	        MOV     [$DAC+2],CX
  310	 010D  89 0E 0000 E	 	        MOV     [$AC],CX
  311	 0111  C7 06 0002 E 8180	        MOV     [$AC+2],8180H
  312	 0117  59	 	 	        POP     CX
  313	 0118  CB	 	 	RET1:   RET
  314	 	 	 	 	
  315	 	 	 	 	
  316	 0119	 	 	 	$IND:
  317	 0119  87 F3	 	 	        XCHG    SI,BX
  318	 011B  E8 0183 R	 	        CALL    PUTDAC
  319	 011E  87 F3	 	 	        XCHG    SI,BX
  320	 0120  51	 	 	        PUSH    CX
  321	 0121  B9 0006	 	 	        MOV     CX,6
  322	 0124  EB AA	 	 	        JMP     INT
  323	 	 	 	 	
  324	 0126	 	 	 	NUMFCN  ENDP


NUMFCN - Arithmetic functions                            Macro-86 %1(12)   1:6:14  13-Nov-81    Page 1-7



  325	 	 	 	 	
  326	 0126	 	 	 	FIX:
  327	 0126  50	 	 	        PUSH    AX
  328	 0127  53	 	 	        PUSH    BX
  329	 0128  57	 	 	        PUSH    DI
  330	 0129  A0 0000 E	 	        MOV     AL,[$FAC]       ;Get exponent
  331	 012C  2C 80	 	 	        SUB     AL,80H
  332	 012E  76 26	 	 	        JBE     ZERO
  333	 0130  BF FFFF E	 	        MOV     DI,OFFSET DC:$FAC-1   ;Point to high mantissa byte
  334	 0133  8A D8	 	 	        MOV     BL,AL
  335	 0135  D0 E8	 	 	        SHR     AL,1
  336	 0137  D0 E8	 	 	        SHR     AL,1
  337	 0139  D0 E8	 	 	        SHR     AL,1
  338	 013B  98	 	 	        CBW                     ;Number of mantissa bytes in integer
  339	 013C  2B F8	 	 	        SUB     DI,AX
  340	 013E  2B C8	 	 	        SUB     CX,AX           ;Advance over full bytes
  341	 0140  72 10	 	 	        JB      POPRET
  342	 0142  93	 	 	        XCHG    BX,AX
  343	 0143  24 07	 	 	        AND     AL,7            ;Bits in last byte
  344	 0145  BB 0000 R	 	        MOV     BX,OFFSET DC:FIXTAB
  345	 0148  D7	 	 	        XLAT
  346	 0149  20 05	 	 	        AND     [DI],AL         ;Reset fraction bits
  347	 014B  32 C0	 	 	        XOR     AL,AL
  348	 014D  4F	 	 	        DEC     DI
  349	 014E  FD	 	 	        STD                     ;Set direction DOWN
  350	 014F  F3/ AA	 	 	        REP     STOSB           ;Zero trailing bytes
  351	 0151  FC	 	 	        CLD                     ;Restore direction
  352	 0152	 	 	 	POPRET:
  353	 0152  5F	 	 	        POP     DI
  354	 0153  5B	 	 	        POP     BX
  355	 0154  58	 	 	        POP     AX
  356	 0155  C3	 	 	        RET
  357	 	 	 	 	
  358	 0156	 	 	 	ZERO:
  359	 0156  C6 06 0000 E 00	 	        MOV     [$FAC],0
  360	 015B  EB F5	 	 	        JMP     POPRET
  361	 	 	 	 	
  362	 015D	 	 	 	NEGATE:
  363	 015D  56	 	 	        PUSH    SI
  364	 015E  BE FFFE E	 	        MOV     SI,OFFSET DC:$FAC-2
  365	 0161  D1 E9	 	 	        SHR     CX,1            ;Do it by words
  366	 0163  51	 	 	        PUSH    CX
  367	 0164	 	 	 	NOTLP:
  368	 0164  F7 14	 	 	        NOT     WORD PTR [SI]
  369	 0166  4E	 	 	        DEC     SI
  370	 0167  4E	 	 	        DEC     SI
  371	 0168  E2 FA	 	 	        LOOP    NOTLP
  372	 016A  59	 	 	        POP     CX
  373	 016B  F6 5C 01	 	 	        NEG     BYTE PTR [SI+1]
  374	 016E  75 06	 	 	        JNZ     NO_INC
  375	 0170	 	 	 	INCLP:
  376	 0170  46	 	 	        INC     SI
  377	 0171  46	 	 	        INC     SI
  378	 0172  FF 04	 	 	        INC     WORD PTR [SI]


NUMFCN - Arithmetic functions                            Macro-86 %1(12)   1:6:14  13-Nov-81    Page 1-8



  379	 0174  E1 FA	 	 	        LOOPZ   INCLP
  380	 0176	 	 	 	NO_INC:
  381	 0176  5E	 	 	        POP     SI
  382	 0177  C3	 	 	        RET
  383	 	 	 	 	
  384	 0178	 	 	 	PUTAC:
  385	 0178  57	 	 	        PUSH    DI
  386	 0179  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
  387	 017C  A5	 	 	        MOVSW
  388	 017D  A5	 	 	        MOVSW
  389	 017E  5F	 	 	        POP     DI
  390	 017F  83 EE 04	 	 	        SUB     SI,4
  391	 0182  C3	 	 	        RET
  392	 	 	 	 	
  393	 0183	 	 	 	PUTDAC:
  394	 0183  57	 	 	        PUSH    DI
  395	 0184  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  396	 0187  A5	 	 	        MOVSW
  397	 0188  A5	 	 	        MOVSW
  398	 0189  A5	 	 	        MOVSW
  399	 018A  A5	 	 	        MOVSW
  400	 018B  5F	 	 	        POP     DI
  401	 018C  83 EE 08	 	 	        SUB     SI,8
  402	 018F  C3	 	 	        RET
  403	 	 	 	 	
  404	 0190	 	 	 	CODE    ENDS
  405	 	 	 	 	        END





























NUMFCN - Arithmetic functions                            Macro-86 %1(12)   1:6:14  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0190	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  CONST. . . . . . . . . . . . . .	0008	WORD  	PUBLIC	'CONST'
  DATA . . . . . . . . . . . . . .	0002	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

DOFIX. . . . . . . . . . . . . .	L NEAR 	00B0	CODE
FC0. . . . . . . . . . . . . . .	L NEAR 	003E	CODE
FIX. . . . . . . . . . . . . . .	L NEAR 	0126	CODE
FIXTAB . . . . . . . . . . . . .	L BYTE 	0000	CONST
INCLP. . . . . . . . . . . . . .	L NEAR 	0170	CODE
INT. . . . . . . . . . . . . . .	L NEAR 	00D0	CODE
MINUSONE . . . . . . . . . . . .	L NEAR 	0103	CODE
NEGATE . . . . . . . . . . . . .	L NEAR 	015D	CODE
NOTLP. . . . . . . . . . . . . .	L NEAR 	0164	CODE
NO_INC . . . . . . . . . . . . .	L NEAR 	0176	CODE
NUMFCN . . . . . . . . . . . . .	F PROC	0000	CODE	Length =0126
POPRET . . . . . . . . . . . . .	L NEAR 	0152	CODE
PRET . . . . . . . . . . . . . .	L NEAR 	0044	CODE
PUTAC. . . . . . . . . . . . . .	L NEAR 	0178	CODE
PUTDAC . . . . . . . . . . . . .	L NEAR 	0183	CODE
RET. . . . . . . . . . . . . . .	L NEAR 	0070	CODE
RET1 . . . . . . . . . . . . . .	L NEAR 	0118	CODE
RETC . . . . . . . . . . . . . .	L NEAR 	00C3	CODE
SAVSGN . . . . . . . . . . . . .	L NEAR 	0024	CODE
SGN. . . . . . . . . . . . . . .	L NEAR 	001C	CODE
SISAVE . . . . . . . . . . . . .	L WORD 	0000	DATA
ZERO . . . . . . . . . . . . . .	L NEAR 	0156	CODE
$ABSA. . . . . . . . . . . . . .	L NEAR 	0071	CODE	Global
$ABSB. . . . . . . . . . . . . .	L NEAR 	007A	CODE	Global
$ABSC. . . . . . . . . . . . . .	L NEAR 	0074	CODE	Global
$ABSD. . . . . . . . . . . . . .	L NEAR 	007D	CODE	Global
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$CNZA. . . . . . . . . . . . . .	L NEAR 	0052	CODE	Global
$CNZB. . . . . . . . . . . . . .	L NEAR 	005C	CODE	Global
$CNZC. . . . . . . . . . . . . .	L NEAR 	0066	CODE	Global
$CNZD. . . . . . . . . . . . . .	L NEAR 	0066	CODE	Global
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FC0A. . . . . . . . . . . . . .	L NEAR 	003A	CODE	Global
$FC0B. . . . . . . . . . . . . .	L NEAR 	0046	CODE	Global
$FC0C. . . . . . . . . . . . . .	L NEAR 	004C	CODE	Global
$FC0D. . . . . . . . . . . . . .	L NEAR 	004C	CODE	Global
$FID . . . . . . . . . . . . . .	L NEAR 	00B5	CODE	Global
$FIX . . . . . . . . . . . . . .	L NEAR 	00A5	CODE	Global
$FSHA. . . . . . . . . . . . . .	L NEAR 	0083	CODE	Global
$FSHB. . . . . . . . . . . . . .	L NEAR 	00A0	CODE	Global


NUMFCN - Arithmetic functions                            Macro-86 %1(12)   1:6:14  13-Nov-81    Symbols-2



$FSHC. . . . . . . . . . . . . .	L NEAR 	0086	CODE	Global
$FSHD. . . . . . . . . . . . . .	L NEAR 	0086	CODE	Global
$FUMA. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$FUMB. . . . . . . . . . . . . .	L NEAR 	0009	CODE	Global
$FUMC. . . . . . . . . . . . . .	L NEAR 	0003	CODE	Global
$FUMD. . . . . . . . . . . . . .	L NEAR 	000C	CODE	Global
$IND . . . . . . . . . . . . . .	L NEAR 	0119	CODE	Global
$INT . . . . . . . . . . . . . .	L NEAR 	00C5	CODE	Global
$OVFL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SGNA. . . . . . . . . . . . . .	L NEAR 	0012	CODE	Global
$SGNB. . . . . . . . . . . . . .	L NEAR 	0034	CODE	Global
$SGNC. . . . . . . . . . . . . .	L NEAR 	0018	CODE	Global
$SGND. . . . . . . . . . . . . .	L NEAR 	0018	CODE	Global

Warning Severe
Errors	Errors 
0	0







































