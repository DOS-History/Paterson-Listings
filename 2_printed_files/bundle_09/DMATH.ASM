DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-1



    1	 	 	 	 	        TITLE   DMATH - Double precision floating point arithmetic
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $FAC:BYTE,$DAC:WORD
    6	 	 	 	 	
    7	 0000  ????	 	 	OP1MAN  DW      ?
    8	 0002  ????	 	 	OP2MAN  DW      ?
    9	 	 	 	 	
   10	 0004	 	 	 	DATA    ENDS
   11	 	 	 	 	
   12	 	 	 	 	DC      GROUP   DATA
   13	 	 	 	 	
   14	 0000	 	 	 	CODE    SEGMENT WORD PUBLIC 'CODE'
   15	 	 	 	 	
   16	 	 	 	 	        PUBLIC  $FADB,$FADD,$FADF,$FADH,$FSUB,$FSUD,$FSUF,$FSUH
   17	 	 	 	 	        PUBLIC  $FMUB,$FMUD,$FMUF,$FMUH,$FDVB,$FDVD,$FDVF,$FDVH
   18	 	 	 	 	        PUBLIC  $DADD,$DSUB,$DMUL,$DDIV,PMULD,$DNORM,$DROUND
   19	 	 	 	 	
   20	 	 	 	 	        EXTRN   $OVFL:NEAR,$DIV0:NEAR,$SAVREG:NEAR,$GTMP:NEAR
   21	 	 	 	 	
   22	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   23	 	 	 	 	
   24	 	 	 	 	
   25	 0000	 	 	 	$FSUD:
   26	 0000  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   27	 0003  EB 06	 	 	        JMP     SHORT $FSUB
   28	 0005	 	 	 	$FSUH:
   29	 0005  E8 0000 E	 	        CALL    $GTMP
   30	 0008	 	 	 	$FSUF:
   31	 0008  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   32	 000B	 	 	 	$FSUB:
   33	 000B  E8 0000 E	 	        CALL    $SAVREG
   34	 	 	 	 	
   35	 	 	 	 	        SUBTTL  $DSUB and $DADD - Double precision subtraction and addition
   36	 	 	 	 	; Inputs:
   37	 	 	 	 	;       SI = Address Of Subtrahend Or Addend
   38	 	 	 	 	;       DI = Address of Minuend or Addend
   39	 	 	 	 	; Function:
   40	 	 	 	 	;       Subtract/Add the operands in double precision and leave result in
   41	 	 	 	 	;       $FAC. Performs rounding with sticky bit.
   42	 	 	 	 	; Outputs:
   43	 	 	 	 	;       Result in $FAC.
   44	 	 	 	 	; Registers:
   45	 	 	 	 	;       All except BP destroyed.
   46	 	 	 	 	
   47	 000E	 	 	 	$DSUB:
   48	 000E  8B 4D 06	 	 	        MOV     CX,[DI+6]       ;Get sign & exponent on subtrahend
   49	 0011  80 F1 80	 	 	        XOR     CL,80H          ;Invert its sign
   50	 0014  EB 1C	 	 	        JMP     SHORT DOADD     ;   and just add
   51	 	 	 	 	
   52	 0016	 	 	 	SAVDI:
   53	 0016  91	 	 	        XCHG    AX,CX
   54	 0017  8B F7	 	 	        MOV     SI,DI


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-2
$DSUB and $DADD - Double precision subtraction and addition


   55	 0019  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   56	 001C  A5	 	 	        MOVSW
   57	 001D  A5	 	 	        MOVSW
   58	 001E  A5	 	 	        MOVSW
   59	 001F  AB	 	 	        STOSW
   60	 0020  C3	 	 	        RET
   61	 	 	 	 	
   62	 0021	 	 	 	$FADD:
   63	 0021  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   64	 0024  EB 06	 	 	        JMP     SHORT $FADB
   65	 0026	 	 	 	$FADH:
   66	 0026  E8 0000 E	 	        CALL    $GTMP
   67	 0029	 	 	 	$FADF:
   68	 0029  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   69	 002C	 	 	 	$FADB:
   70	 002C  E8 0000 E	 	        CALL    $SAVREG
   71	 	 	 	 	
   72	 002F	 	 	 	$DADD:
   73	 002F  8B 4D 06	 	 	        MOV     CX,[DI+6]       ;Get sign & exponent of one operand
   74	 0032	 	 	 	DOADD:
   75	 0032  8B 44 06	 	 	        MOV     AX,[SI+6]       ;Get sign & exponent of other operand
   76	 0035  0A E4	 	 	        OR      AH,AH
   77	 0037  74 DD	 	 	        JZ      SAVDI
   78	 0039  3A EC	 	 	        CMP     CH,AH           ;See which number is larger
   79	 003B  77 07	 	 	        JA      SIGNFIDDLE      ;See if difference is positive
   80	 003D  87 F7	 	 	        XCHG    SI,DI           ;Swap pointers to operands
   81	 003F  91	 	 	        XCHG    AX,CX           ;Swap exponents/signs
   82	 0040  0A E4	 	 	        OR      AH,AH           ;See if smaller operand is zero
   83	 0042  74 D2	 	 	        JZ      SAVDI           ;If so, return larger
   84	 0044	 	 	 	SIGNFIDDLE:
   85	 0044  2A E5	 	 	        SUB     AH,CH           ;Subtract exponents ( <=0 )
   86	 0046  F6 DC	 	 	        NEG     AH
   87	 0048  80 FC 38	 	 	        CMP     AH,56           ;Is smaller argument significant?
   88	 004B  77 C9	 	 	        JA      SAVDI
   89	 004D  D0 E0	 	 	        SHL     AL,1            ;Put sign of smaller into carry
   90	 004F  D0 D9	 	 	        RCR     CL,1            ;Now pack it in next to sign of larger
   91	 0051  91	 	 	        XCHG    AX,CX
   92	 0052  8A CD	 	 	        MOV     CL,CH
   93	 0054  B5 00	 	 	        MOV     CH,0
   94	 	 	 	 	
   95	 	 	 	 	; Now things look like this:
   96	 	 	 	 	;       SI has pointer to smaller operand
   97	 	 	 	 	;       DI has pointer to larger operand
   98	 	 	 	 	;       AL bit 7 has sign of smaller
   99	 	 	 	 	;       AL bit 6 has sign of larger
  100	 	 	 	 	;       CL has exponent difference ( 0 <= CL <= 56 )
  101	 	 	 	 	;       CH is zero
  102	 	 	 	 	;       AH has exponent of larger ( = tentative exponent of result)
  103	 	 	 	 	
  104	 0056  50	 	 	        PUSH    AX
  105	 0057  57	 	 	        PUSH    DI              ;We'll need these later
  106	 0058  8B F9	 	 	        MOV     DI,CX           ;Need all 8-bit registers
  107	 	 	 	 	
  108	 	 	 	 	;Load smaller operand


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-3
$DSUB and $DADD - Double precision subtraction and addition


  109	 	 	 	 	
  110	 005A  AC	 	 	        LODSB
  111	 005B  8A E0	 	 	        MOV     AH,AL
  112	 005D  32 C0	 	 	        XOR     AL,AL           ;Extend operand to 64 bits with zeros
  113	 005F  92	 	 	        XCHG    AX,DX
  114	 0060  AD	 	 	        LODSW
  115	 0061  91	 	 	        XCHG    AX,CX
  116	 0062  AD	 	 	        LODSW
  117	 0063  93	 	 	        XCHG    AX,BX
  118	 0064  AD	 	 	        LODSW
  119	 0065  80 CC 80	 	 	        OR      AH,80H          ;Set implied bit
  120	 	 	 	 	
  121	 	 	 	 	;Smaller operand now in AX:BX:CX:DX with implied bit set
  122	 	 	 	 	
  123	 0068  0B FF	 	 	        OR      DI,DI
  124	 006A  74 63	 	 	        JZ      ALIGNED         ;Alignment operations necessary?
  125	 006C	 	 	 	CHKALN:
  126	 006C  83 FF 0E	 	 	        CMP     DI,14           ;Do shifts of 16 bits by word rotate
  127	 006F  7C 18	 	 	        JL      BYTSHFT         ;If not enough for word, go try byte
  128	 0071  0B D2	 	 	        OR      DX,DX           ;See if we're shifting something off the end
  129	 0073  74 03	 	 	        JZ      NOSTIK
  130	 0075  80 C9 01	 	 	        OR      CL,1            ;Ensure sticky bit will be set
  131	 0078	 	 	 	NOSTIK:
  132	 0078  8B D1	 	 	        MOV     DX,CX
  133	 007A  8B CB	 	 	        MOV     CX,BX
  134	 007C  8B D8	 	 	        MOV     BX,AX
  135	 007E  33 C0	 	 	        XOR     AX,AX
  136	 0080  83 EF 10	 	 	        SUB     DI,16           ;Counts for 16 bit shifts
  137	 0083  77 E7	 	 	        JA      CHKALN          ;If not enough, try again
  138	 0085  74 48	 	 	        JZ      ALIGNED         ;Hit it exactly?
  139	 0087  72 23	 	 	        JB      SHFLEF          ;Back up if too far
  140	 	 	 	 	
  141	 0089	 	 	 	BYTSHFT:
  142	 0089  83 FF 06	 	 	        CMP     DI,6            ;Can we do a byte shift?
  143	 008C  7C 2B	 	 	        JL      BITSHFT
  144	 008E  0A D2	 	 	        OR      DL,DL
  145	 0090  74 03	 	 	        JZ      NSTIK
  146	 0092  80 CE 01	 	 	        OR      DH,1
  147	 0095	 	 	 	NSTIK:
  148	 0095  8A D6	 	 	        MOV     DL,DH
  149	 0097  8A F1	 	 	        MOV     DH,CL
  150	 0099  8A CD	 	 	        MOV     CL,CH
  151	 009B  8A EB	 	 	        MOV     CH,BL
  152	 009D  8A DF	 	 	        MOV     BL,BH
  153	 009F  8A F8	 	 	        MOV     BH,AL
  154	 00A1  8A C4	 	 	        MOV     AL,AH
  155	 00A3  32 E4	 	 	        XOR     AH,AH
  156	 00A5  83 EF 08	 	 	        SUB     DI,8
  157	 00A8  77 0F	 	 	        JA      BITSHFT
  158	 00AA  74 23	 	 	        JZ      ALIGNED
  159	 	 	 	 	
  160	 	 	 	 	;To get here, we must have used a byte shift when we needed to shift less than
  161	 	 	 	 	;8 bits. Now we must correct by 1 or 2 left shifts.
  162	 	 	 	 	


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-4
$DSUB and $DADD - Double precision subtraction and addition


  163	 00AC	 	 	 	SHFLEF:
  164	 00AC  D1 E2	 	 	        SHL     DX,1
  165	 00AE  D1 D1	 	 	        RCL     CX,1
  166	 00B0  D1 D3	 	 	        RCL     BX,1
  167	 00B2  D1 D0	 	 	        RCL     AX,1
  168	 00B4  47	 	 	        INC     DI
  169	 00B5  75 F5	 	 	        JNZ     SHFLEF          ;Until DI is back to zero (from -1 or -2)
  170	 00B7  EB 16	 	 	        JMP     SHORT ALIGNED
  171	 	 	 	 	
  172	 00B9	 	 	 	BITSHFT:
  173	 00B9  87 CF	 	 	        XCHG    CX,DI
  174	 00BB  F6 C2 3F	 	 	        TEST    DL,3FH          ;See if we're shifting stuff off the end
  175	 00BE  74 03	 	 	        JZ      SHFRIG
  176	 00C0  80 CA 20	 	 	        OR      DL,20H          ;Set sticky bit if so
  177	 00C3	 	 	 	SHFRIG:
  178	 00C3  D1 E8	 	 	        SHR     AX,1
  179	 00C5  D1 DB	 	 	        RCR     BX,1
  180	 00C7  D1 DF	 	 	        RCR     DI,1
  181	 00C9  D1 DA	 	 	        RCR     DX,1
  182	 00CB  E2 F6	 	 	        LOOP    SHFRIG          ;Do 1 to 5 64-bit right shifts
  183	 00CD  87 CF	 	 	        XCHG    CX,DI
  184	 00CF	 	 	 	ALIGNED:
  185	 00CF  5E	 	 	        POP     SI              ;Address of larger operand
  186	 00D0  97	 	 	        XCHG    AX,DI
  187	 00D1  F6 C2 3F	 	 	        TEST    DL,3FH          ;Collapse LSBs into sticky bit
  188	 00D4  74 03	 	 	        JZ      GETSIGN
  189	 00D6  80 CA 20	 	 	        OR      DL,20H          ;Set sticky bit
  190	 00D9	 	 	 	GETSIGN:
  191	 00D9  58	 	 	        POP     AX              ;Recover sign and exponent
  192	 00DA  D0 E0	 	 	        SHL     AL,1            ;Shift sign bits out to test
  193	 	 	 	 	
  194	 	 	 	 	;Now AL = sign of larger ( = tentative sign of result)
  195	 	 	 	 	;Carry = sign of smaller.
  196	 	 	 	 	;Overflow flag is set if these two are different.
  197	 	 	 	 	
  198	 00DC  70 24	 	 	        JO      SUBMAN          ;Subtract mantissas if signs are different
  199	 00DE  02 34	 	 	        ADD     DH,[SI]
  200	 00E0  13 4C 01	 	 	        ADC     CX,[SI+1]
  201	 00E3  13 5C 03	 	 	        ADC     BX,[SI+3]
  202	 00E6  9C	 	 	        PUSHF                   ;Save carry flag
  203	 00E7  8B 74 05	 	 	        MOV     SI,[SI+5]
  204	 00EA  81 CE 8000	 	        OR      SI,8000H        ;Set implied bit
  205	 00EE  9D	 	 	        POPF
  206	 00EF  13 FE	 	 	        ADC     DI,SI
  207	 00F1  73 0A	 	 	        JNC     ROUNDJ
  208	 	 	 	 	;Have a carry, so result must be shifted right and exponent incremented
  209	 00F3  D1 DF	 	 	        RCR     DI,1 
  210	 00F5  D1 DB	 	 	        RCR     BX,1 
  211	 00F7  D1 D9	 	 	        RCR     CX,1 
  212	 00F9  D1 DA	 	 	        RCR     DX,1 
  213	 00FB  FE C4	 	 	        INC     AH              ;Bump exponent
  214	 00FD  75 75	 	 	ROUNDJ: JNZ     ROUND
  215	 00FF  E9 0000 E	 	        JMP     $OVFL
  216	 	 	 	 	


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-5
$DSUB and $DADD - Double precision subtraction and addition


  217	 0102	 	 	 	SUBMAN:
  218	 	 	 	 	;Subtract mantissas since signs are different. We'll be subtracting in larger
  219	 	 	 	 	;from smaller, so sign will be inverted first.
  220	 0102  F6 D0	 	 	        NOT     AL
  221	 0104  2A 34	 	 	        SUB     DH,[SI]
  222	 0106  1B 4C 01	 	 	        SBB     CX,[SI+1]
  223	 0109  1B 5C 03	 	 	        SBB     BX,[SI+3]
  224	 010C  9C	 	 	        PUSHF                   ;Save carry flag
  225	 010D  8B 74 05	 	 	        MOV     SI,[SI+5]
  226	 0110  81 CE 8000	 	        OR      SI,8000H        ;Set implied bit
  227	 0114  9D	 	 	        POPF
  228	 0115  1B FE	 	 	        SBB     DI,SI
  229	 0117  73 13	 	 	        JNC     NORM            ;Won't carry if we mixed up larger and smaller
  230	 	 	 	 	;As expected, we got a carry which means we must negate the result
  231	 0119  33 F6	 	 	        XOR     SI,SI           ;We'll need a zero
  232	 011B  F6 D0	 	 	        NOT     AL              ;Flip sign bit
  233	 011D  F7 D7	 	 	        NOT     DI
  234	 011F  F7 D3	 	 	        NOT     BX
  235	 0121  F7 D1	 	 	        NOT     CX
  236	 0123  F7 DA	 	 	        NEG     DX              ;Carry clear if zero
  237	 0125  F5	 	 	        CMC
  238	 0126  13 CE	 	 	        ADC     CX,SI
  239	 0128  13 DE	 	 	        ADC     BX,SI
  240	 012A  13 FE	 	 	        ADC     DI,SI
  241	 012C	 	 	 	$DNORM:
  242	 012C	 	 	 	NORM:
  243	 012C  BE 0004	 	 	        MOV     SI,4            ;Maximum of 4 word shifts
  244	 012F	 	 	 	DNOR:
  245	 012F  0B FF	 	 	        OR      DI,DI           ;See if any bits on in high word
  246	 0131  75 12	 	 	        JNZ     HIBYT           ;If so, go check high byte for zero
  247	 0133  80 EC 10	 	 	        SUB     AH,16           ;Drop exponent by shift count
  248	 0136  76 7C	 	 	        JBE     ZERO
  249	 0138  4E	 	 	        DEC     SI
  250	 0139  74 79	 	 	        JZ      ZERO
  251	 013B  8B FB	 	 	        MOV     DI,BX
  252	 013D  8B D9	 	 	        MOV     BX,CX
  253	 013F  8B CA	 	 	        MOV     CX,DX
  254	 0141  33 D2	 	 	        XOR     DX,DX
  255	 0143  EB EA	 	 	        JMP     DNOR
  256	 0145	 	 	 	HIBYT:
  257	 0145  F7 C7 FF00	 	        TEST    DI,0FF00H       ;See if high byte is zero
  258	 0149  75 19	 	 	        JNZ     NORMSHF
  259	 014B  80 EC 08	 	 	        SUB     AH,8            ;Drop exponent by shift amount
  260	 014E  76 64	 	 	        JBE     ZERO
  261	 0150  97	 	 	        XCHG    AX,DI
  262	 0151  8A E0	 	 	        MOV     AH,AL
  263	 0153  8A C7	 	 	        MOV     AL,BH
  264	 0155  8A FB	 	 	        MOV     BH,BL
  265	 0157  8A DD	 	 	        MOV     BL,CH
  266	 0159  8A E9	 	 	        MOV     CH,CL
  267	 015B  8A CE	 	 	        MOV     CL,DH
  268	 015D  8A F2	 	 	        MOV     DH,DL
  269	 015F  B2 00	 	 	        MOV     DL,0
  270	 0161  0A E4	 	 	        OR      AH,AH


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-6
$DSUB and $DADD - Double precision subtraction and addition


  271	 0163  97	 	 	        XCHG    AX,DI
  272	 0164	 	 	 	NORMSHF:
  273	 0164  78 0E	 	 	        JS      ROUND           ;Normalize complete?
  274	 0166	 	 	 	NORMLP:
  275	 0166  FE CC	 	 	        DEC     AH              ;Account for shift in exponent
  276	 0168  74 4A	 	 	        JZ      ZERO
  277	 016A  D1 E2	 	 	        SHL     DX,1
  278	 016C  D1 D1	 	 	        RCL     CX,1
  279	 016E  D1 D3	 	 	        RCL     BX,1
  280	 0170  D1 D7	 	 	        RCL     DI,1
  281	 0172  71 F2	 	 	        JNO     NORMLP          ;Overflow will be set when sign bit changes
  282	 	 	 	 	
  283	 0174	 	 	 	$DROUND:
  284	 0174	 	 	 	ROUND:
  285	 0174  80 FA 80	 	 	        CMP     DL,80H          ;Check extended bits
  286	 0177  77 07	 	 	        JA      ROUNDUP
  287	 0179  72 17	 	 	        JB      SAVE
  288	 	 	 	 	;Extended bits equal exactly one-half LSB, so round even
  289	 017B  F6 C6 01	 	 	        TEST    DH,1            ;Already even?
  290	 017E  74 12	 	 	        JZ      SAVE
  291	 0180	 	 	 	ROUNDUP:
  292	 0180  80 C6 01	 	 	        ADD     DH,1
  293	 0183  83 D1 00	 	 	        ADC     CX,0
  294	 0186  83 D3 00	 	 	        ADC     BX,0            ;Propagate carry
  295	 0189  83 D7 00	 	 	        ADC     DI,0
  296	 018C  73 04	 	 	        JNC     SAVE            ;Overflow?
  297	 	 	 	 	;If we overflowed, DI:BX:CX:DH must now be zero, so we can leave it that way.
  298	 018E  FE C4	 	 	        INC     AH              ;Increment exponent
  299	 0190  74 1F	 	 	        JZ      OVERFLOW
  300	 0192	 	 	 	SAVE:
  301	 0192  24 80	 	 	        AND     AL,80H          ;Strip to sign bit
  302	 0194  87 DF	 	 	        XCHG    BX,DI
  303	 0196  80 E7 7F	 	 	        AND     BH,7FH          ;Mask off implied bit
  304	 0199  0A C7	 	 	        OR      AL,BH           ;Combine sign with mantissa
  305	 019B  A3 0006 E	 	        MOV     [$DAC+6],AX
  306	 019E  88 1E FFFE E	 	        MOV     [$FAC-2],BL
  307	 01A2  8B DF	 	 	        MOV     BX,DI
  308	 01A4  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  309	 01A7  8A C6	 	 	        MOV     AL,DH
  310	 01A9  AA	 	 	        STOSB
  311	 01AA  91	 	 	        XCHG    AX,CX
  312	 01AB  AB	 	 	        STOSW
  313	 01AC  93	 	 	        XCHG    AX,BX
  314	 01AD  AB	 	 	        STOSW
  315	 01AE  C3	 	 	        RET
  316	 	 	 	 	
  317	 01AF	 	 	 	OVCHK:
  318	 01AF  79 03	 	 	        JNS     ZERO
  319	 01B1	 	 	 	OVERFLOW:
  320	 01B1  E9 0000 E	 	        JMP     $OVFL
  321	 	 	 	 	
  322	 01B4	 	 	 	ZERO:
  323	 01B4  C6 06 0000 E 00	 	        MOV     [$FAC],0
  324	 01B9  C3	 	 	        RET


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-7
$DSUB and $DADD - Double precision subtraction and addition


  325	 	 	 	 	
  326	 	 	 	 	
  327	 01BA	 	 	 	$FMUD:
  328	 01BA  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  329	 01BD  EB 06	 	 	        JMP     SHORT $FMUB
  330	 01BF	 	 	 	$FMUH:
  331	 01BF  E8 0000 E	 	        CALL    $GTMP
  332	 01C2	 	 	 	$FMUF:
  333	 01C2  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  334	 01C5	 	 	 	$FMUB:
  335	 01C5  E8 0000 E	 	        CALL    $SAVREG
  336	 	 	 	 	
  337	 	 	 	 	        SUBTTL  $DMUL - Double precision multiply
  338	 	 	 	 	; Inputs:
  339	 	 	 	 	;       SI = Address of one operand
  340	 	 	 	 	;       DI = Address of other operand
  341	 	 	 	 	; Function:
  342	 	 	 	 	;       Multiply with result in FAC.
  343	 	 	 	 	; Outputs:
  344	 	 	 	 	;       Result in FAC.
  345	 	 	 	 	; Registers:
  346	 	 	 	 	;       Uses ALL.
  347	 	 	 	 	
  348	 01C8	 	 	 	$DMUL:
  349	 01C8  8B 44 06	 	 	        MOV     AX,[SI+6]       ;High part of op1
  350	 01CB  0A E4	 	 	        OR      AH,AH
  351	 01CD  74 E5	 	 	        JZ      ZERO
  352	 01CF  8B 4D 06	 	 	        MOV     CX,[DI+6]       ;High part of op2
  353	 01D2  0A ED	 	 	        OR      CH,CH
  354	 01D4  74 DE	 	 	        JZ      ZERO
  355	 01D6  32 C1	 	 	        XOR     AL,CL           ;Compute sign
  356	 	 	 	 	
  357	 	 	 	 	;Exponent computation.
  358	 	 	 	 	;Compute sum of exponents minus one. The minus one is valid if the product
  359	 	 	 	 	;will need normalization by one bit. If it doesn't, one will be added to the
  360	 	 	 	 	;exponent. A zero exponent will temporarily be OK because of this possibility
  361	 	 	 	 	;of adding one later.
  362	 	 	 	 	
  363	 01D8  80 EC 81	 	 	        SUB     AH,128+1        ;Subtract bias and extra "minus one"
  364	 01DB  80 ED 80	 	 	        SUB     CH,128
  365	 01DE  02 E5	 	 	        ADD     AH,CH           ;Add exponents
  366	 01E0  70 CD	 	 	OVCHKJ: JO      OVCHK           ;If overflow, check whether up or down
  367	 01E2  80 C4 80	 	 	        ADD     AH,128          ;Put bias back in
  368	 01E5  50	 	 	        PUSH    AX              ;Save sign and tentative exponent
  369	 01E6  E8 030B R	 	        CALL    PMULD           ;Multiply mantissas
  370	 01E9  74 03	 	 	        JZ      NORMCHK         ;Need to set sticky bit?
  371	 01EB  80 CA 01	 	 	        OR      DL,1
  372	 01EE	 	 	 	NORMCHK:
  373	 01EE  58	 	 	        POP     AX              ;Get exp. and sign back
  374	 01EF  0B FF	 	 	        OR      DI,DI           ;See if normalized
  375	 01F1  78 0E	 	 	        JS      INCEXP          ;Yes - increment exponent
  376	 01F3  D1 E2	 	 	        SHL     DX,1            ;Normalize
  377	 01F5  D1 D1	 	 	        RCL     CX,1
  378	 01F7  D1 D3	 	 	        RCL     BX,1


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-8
$DMUL - Double precision multiply


  379	 01F9  D1 D7	 	 	        RCL     DI,1
  380	 01FB  0A E4	 	 	        OR      AH,AH           ;Is exponent zero?
  381	 01FD  75 06	 	 	        JNZ     RNDJMP
  382	 01FF  EB B3	 	 	        JMP     ZERO
  383	 	 	 	 	
  384	 0201	 	 	 	INCEXP:
  385	 0201  FE C4	 	 	        INC     AH
  386	 0203  74 AC	 	 	        JZ      OVERFLOW
  387	 0205  E9 0174 R	 	RNDJMP: JMP     ROUND
  388	 	 	 	 	
  389	 	 	 	 	
  390	 0208	 	 	 	$FDVD:
  391	 0208  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
  392	 020B  EB 06	 	 	        JMP     SHORT $FDVB
  393	 020D	 	 	 	$FDVH:
  394	 020D  E8 0000 E	 	        CALL    $GTMP
  395	 0210	 	 	 	$FDVF:
  396	 0210  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
  397	 0213	 	 	 	$FDVB:
  398	 0213  E8 0000 E	 	        CALL    $SAVREG
  399	 	 	 	 	
  400	 	 	 	 	        SUBTTL  $DDIV - Double precision divide
  401	 	 	 	 	; Inputs:
  402	 	 	 	 	;       SI = Address of Dividend (Numerator)
  403	 	 	 	 	;       DI = Address of Divisor (Denominator)
  404	 	 	 	 	; Function:
  405	 	 	 	 	;       Compute [SI] / [DI]
  406	 	 	 	 	; Outputs:
  407	 	 	 	 	;       Result in FAC.
  408	 	 	 	 	; Registers:
  409	 	 	 	 	;       All destroyed.
  410	 	 	 	 	
  411	 0216	 	 	 	$DDIV:
  412	 0216  8B 44 06	 	 	        MOV     AX,[SI+6]       ;High half of numerator
  413	 0219  8B 4D 06	 	 	        MOV     CX,[DI+6]       ;High half of denominator
  414	 021C  32 C1	 	 	        XOR     AL,CL           ;Compute sign
  415	 021E  0A ED	 	 	        OR      CH,CH           ;Denominator zero?
  416	 0220  74 62	 	 	        JZ      DIV0
  417	 0222  0A E4	 	 	        OR      AH,AH           ;Numerator zero?
  418	 0224  74 8E	 	 	        JZ      ZERO
  419	 0226  80 EC 80	 	 	        SUB     AH,128          ;Removebias from exponents
  420	 0229  80 ED 80	 	 	        SUB     CH,128
  421	 022C  2A E5	 	 	        SUB     AH,CH           ;Compute result exponent
  422	 022E  70 B0	 	 	        JO      OVCHKJ
  423	 	 	 	 	
  424	 	 	 	 	;AH has the (tentative) true exponent of the result. It is correct if the
  425	 	 	 	 	;result needs normalizing one bit. If not, 1 will be added to it. A true
  426	 	 	 	 	;exponent of -128, not normally allowed except to represent zero, is OK
  427	 	 	 	 	;here because of this possible future incrementing.
  428	 	 	 	 	
  429	 0230  80 C4 80	 	 	        ADD     AH,128          ;Put bias back
  430	 0233  50	 	 	        PUSH    AX              ;Save sign and exponent
  431	 0234  AC	 	 	        LODSB                   ;Load up dividend
  432	 0235  8A E8	 	 	        MOV     CH,AL


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-9
$DDIV - Double precision divide


  433	 0237  32 C9	 	 	        XOR     CL,CL
  434	 0239  AD	 	 	        LODSW
  435	 023A  93	 	 	        XCHG    AX,BX
  436	 023B  AD	 	 	        LODSW
  437	 023C  92	 	 	        XCHG    AX,DX
  438	 023D  AD	 	 	        LODSW
  439	 023E  80 CC 80	 	 	        OR      AH,80H          ;Set implied bit
  440	 0241  92	 	 	        XCHG    AX,DX           ;Divisor in DX:AX:BX:CX
  441	 	 	 	 	
  442	 	 	 	 	;Move divisor to FAC so we can get at it easily. More importantly, get it in
  443	 	 	 	 	;the necessary form - extended to 64 bits with zeros, implied bit set.
  444	 	 	 	 	;The form we want it in will have the mantissa MSB where the exponent usually
  445	 	 	 	 	;is, so by moving high to low we will not destroy the divisor even if it is
  446	 	 	 	 	;already in the FAC.
  447	 	 	 	 	
  448	 0242  8B F7	 	 	        MOV     SI,DI
  449	 0244  83 C6 05	 	 	        ADD     SI,5            ;Point to high end of divisor
  450	 0247  BF FFFF E	 	        MOV     DI,OFFSET DC:$FAC-1
  451	 024A  FD	 	 	        STD                     ;Direction DOWN
  452	 024B  A5	 	 	        MOVSW                   ;Move divisor to FAC
  453	 024C  A5	 	 	        MOVSW
  454	 024D  A5	 	 	        MOVSW
  455	 024E  46	 	 	        INC     SI
  456	 024F  47	 	 	        INC     DI
  457	 0250  A4	 	 	        MOVSB
  458	 0251  FC	 	 	        CLD                     ;Restore direction
  459	 0252  C6 05 00	 	 	        MOV     BYTE PTR[DI],0  ;Extend to 64 bits with a zero
  460	 0255  80 0E 0000 E 80	 	        OR      [$FAC],80H      ;Set implied bit
  461	 	 	 	 	
  462	 	 	 	 	;Now we're all set:
  463	 	 	 	 	;       DX:AX:BX:CX has dividend
  464	 	 	 	 	;       FAC has divisor (not in normal format)
  465	 	 	 	 	;Both are extended to 64 bits with zeros and have implied bit set.
  466	 	 	 	 	;Top of stack has sign and tentative exponent.
  467	 	 	 	 	
  468	 025A  D1 EA	 	 	        SHR     DX,1            ;Make sure dividend is smaller than divisor
  469	 025C  D1 D8	 	 	        RCR     AX,1            ;   by dividing it by two
  470	 025E  D1 DB	 	 	        RCR     BX,1
  471	 0260  D1 D9	 	 	        RCR     CX,1
  472	 0262  E8 0287 R	 	        CALL    DIV16           ;Get a quotient digit
  473	 0265  57	 	 	        PUSH    DI
  474	 0266  E8 0287 R	 	        CALL    DIV16
  475	 0269  57	 	 	        PUSH    DI
  476	 026A  E8 0287 R	 	        CALL    DIV16
  477	 026D  57	 	 	        PUSH    DI
  478	 026E  E8 0287 R	 	        CALL    DIV16
  479	 0271  0B C3	 	 	        OR      AX,BX           ;Remainder zero?
  480	 0273  0B C1	 	 	        OR      AX,CX
  481	 0275  0B C2	 	 	        OR      AX,DX
  482	 0277  8B D7	 	 	        MOV     DX,DI           ;Get lowest word in position
  483	 0279  74 03	 	 	        JZ      NSTK1
  484	 027B  80 CA 01	 	 	        OR      DL,1            ;Set sticky bit if not
  485	 027E	 	 	 	NSTK1:
  486	 027E  59	 	 	        POP     CX              ;Recover quotient digits


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-10
$DDIV - Double precision divide


  487	 027F  5B	 	 	        POP     BX
  488	 0280  5F	 	 	        POP     DI
  489	 0281  E9 01EE R	 	        JMP     NORMCHK
  490	 	 	 	 	
  491	 0284  E9 0000 E	 	DIV0:   JMP     $DIV0
  492	 	 	 	 	
  493	 0287	 	 	 	DIV16:
  494	 0287  8B 36 0006 E	 	        MOV     SI,[$DAC+6]     ;Get high word of divisor
  495	 028B  33 FF	 	 	        XOR     DI,DI           ;Initialize quotient digit to zero
  496	 028D  3B D6	 	 	        CMP     DX,SI           ;Will we overflow?
  497	 028F  73 5C	 	 	        JAE     MAXQUO          ;If so, go handle special
  498	 0291  0B D2	 	 	        OR      DX,DX           ;Is dividend small?
  499	 0293  75 04	 	 	        JNZ     DODIV
  500	 0295  3B F0	 	 	        CMP     SI,AX           ;Will divisor fit at all?
  501	 0297  77 3B	 	 	        JA      ZERQUO          ;No - quotient is zero
  502	 0299	 	 	 	DODIV:
  503	 0299  F7 F6	 	 	        DIV     SI              ;AX is our digit "guess"
  504	 029B  52	 	 	        PUSH    DX              ;Save remainder
  505	 029C  97	 	 	        XCHG    AX,DI           ;Quotient digit in DI
  506	 029D  33 ED	 	 	        XOR     BP,BP           ;Initialize quotient * divisor
  507	 029F  8B F5	 	 	        MOV     SI,BP
  508	 02A1  A1 0000 E	 	        MOV     AX,[$DAC]
  509	 02A4  0B C0	 	 	        OR      AX,AX           ;If zero, save multiply time
  510	 02A6  74 04	 	 	        JZ      REM2
  511	 02A8  F7 E7	 	 	        MUL     DI              ;Begin computing quotient * divisor
  512	 02AA  8B F2	 	 	        MOV     SI,DX
  513	 02AC	 	 	 	REM2:
  514	 02AC  50	 	 	        PUSH    AX              ;Save lowest word of quotient * divisor
  515	 02AD  A1 0002 E	 	        MOV     AX,[$DAC+2]
  516	 02B0  0B C0	 	 	        OR      AX,AX
  517	 02B2  74 06	 	 	        JZ      REM3
  518	 02B4  F7 E7	 	 	        MUL     DI
  519	 02B6  03 F0	 	 	        ADD     SI,AX
  520	 02B8  13 EA	 	 	        ADC     BP,DX
  521	 02BA	 	 	 	REM3:
  522	 02BA  A1 0004 E	 	        MOV     AX,[$DAC+4]
  523	 02BD  0B C0	 	 	        OR      AX,AX
  524	 02BF  74 08	 	 	        JZ      REM4
  525	 02C1  F7 E7	 	 	        MUL     DI
  526	 02C3  03 E8	 	 	        ADD     BP,AX
  527	 02C5  83 D2 00	 	 	        ADC     DX,0
  528	 02C8  92	 	 	        XCHG    AX,DX
  529	 02C9	 	 	 	REM4:                           ;Quotient * divisor in AX:BP:SI:[SP]
  530	 02C9  5A	 	 	        POP     DX              ;Recover lowest word of quotient * divisor
  531	 02CA  F7 DA	 	 	        NEG     DX              ;Subtract from dividend
  532	 02CC  1B CE	 	 	        SBB     CX,SI
  533	 02CE  1B DD	 	 	        SBB     BX,BP
  534	 02D0  5D	 	 	        POP     BP              ;Remainder from DIV
  535	 02D1  1B E8	 	 	        SBB     BP,AX
  536	 02D3  95	 	 	        XCHG    AX,BP
  537	 02D4	 	 	 	ZERQUO:                         ;Remainder in AX:BX:CX:DX
  538	 02D4  92	 	 	        XCHG    AX,DX
  539	 02D5  91	 	 	        XCHG    AX,CX
  540	 02D6  93	 	 	        XCHG    AX,BX


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-11
$DDIV - Double precision divide


  541	 02D7  73 13	 	 	        JNC     RET             ;Remainder in DX:AX:BX:CX
  542	 02D9	 	 	 	RESTORE:
  543	 02D9  4F	 	 	        DEC     DI              ;Drop quotient since it didn't fit
  544	 02DA  03 0E 0000 E	 	        ADD     CX,[$DAC]       ;Add divisor back in until remainder goes +
  545	 02DE  13 1E 0002 E	 	        ADC     BX,[$DAC+2]
  546	 02E2  13 06 0004 E	 	        ADC     AX,[$DAC+4]
  547	 02E6  13 16 0006 E	 	        ADC     DX,[$DAC+6]
  548	 02EA  73 ED	 	 	        JNC     RESTORE
  549	 02EC  C3	 	 	RET:    RET
  550	 	 	 	 	
  551	 02ED	 	 	 	MAXQUO:
  552	 02ED  4F	 	 	        DEC     DI              ;DI=FFFF=2**16-1
  553	 02EE  2B 0E 0000 E	 	        SUB     CX,[$DAC]
  554	 02F2  1B 1E 0002 E	 	        SBB     BX,[$DAC+2]
  555	 02F6  1B 06 0004 E	 	        SBB     AX,[$DAC+4]
  556	 02FA  03 0E 0002 E	 	        ADD     CX,[$DAC+2]
  557	 02FE  13 1E 0004 E	 	        ADC     BX,[$DAC+4]
  558	 0302  13 C2	 	 	        ADC     AX,DX
  559	 0304  8B 16 0000 E	 	        MOV     DX,[$DAC]
  560	 0308  F5	 	 	        CMC
  561	 0309  EB C9	 	 	        JMP     ZERQUO
  562	 	 	 	 	
  563	 	 	 	 	
  564	 	 	 	 	        SUBTTL  PMULD - Partial DP multiply
  565	 	 	 	 	
  566	 	 	 	 	; Inputs:
  567	 	 	 	 	;       SI = Address of multiplicand
  568	 	 	 	 	;       DI = Address of multiplier
  569	 	 	 	 	; Function:
  570	 	 	 	 	;       Multiply mantissas and provide unrounded 64 bit result.
  571	 	 	 	 	; Outputs:
  572	 	 	 	 	;       Result in DI:BX:CX:DX.
  573	 	 	 	 	;       SI is non-zero (flags set accordingly) if not exact result
  574	 	 	 	 	; Registers:
  575	 	 	 	 	;       Uses ALL.
  576	 	 	 	 	
  577	 030B	 	 	 	PMULD:
  578	 030B  8A 44 06	 	 	        MOV     AL,[SI+6]       ;Get most significant mantissa byte
  579	 030E  B4 00	 	 	        MOV     AH,0            ;Extend with a zero
  580	 0310  0C 80	 	 	        OR      AL,80H          ;Set implied bit
  581	 0312  A3 0000 R	 	        MOV     [OP1MAN],AX     ;Save for easy access
  582	 0315  8A 45 06	 	 	        MOV     AL,[DI+6]
  583	 0318  B4 00	 	 	        MOV     AH,0
  584	 031A  0C 80	 	 	        OR      AL,80H
  585	 031C  A3 0002 R	 	        MOV     [OP2MAN],AX     ;Second operand similarly prepared
  586	 	 	 	 	
  587	 	 	 	 	; Perform multiply by summing partial products of 16x16 hardware multiply.
  588	 	 	 	 	; Before each multiply, the operands are checked for zero to see if it can be
  589	 	 	 	 	; skipped, since it's a slow operation on the 8086. The sum is kept in
  590	 	 	 	 	; registers as much as possible. Any insignificant bits lost are ORed together
  591	 	 	 	 	; and kept in a word on the top of the stack. This can be used for sticky bit
  592	 	 	 	 	; rounding.
  593	 	 	 	 	
  594	 031F  33 DB	 	 	        XOR     BX,BX


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-12
PMULD - Partial DP multiply


  595	 0321  8B EB	 	 	        MOV     BP,BX
  596	 0323  8B 0C	 	 	        MOV     CX,[SI]
  597	 0325  E3 1A	 	 	        JCXZ    PROD3           ;Skip 2 multiplies if zero
  598	 0327  91	 	 	        XCHG    AX,CX
  599	 0328  8B 0D	 	 	        MOV     CX,[DI]
  600	 032A  E3 08	 	 	        JCXZ    PROD2
  601	 032C  F7 E1	 	 	        MUL     CX
  602	 032E  8B E8	 	 	        MOV     BP,AX           ;Save insignificant bits
  603	 0330  8B CA	 	 	        MOV     CX,DX
  604	 0332  8B 04	 	 	        MOV     AX,[SI]
  605	 0334	 	 	 	PROD2:                          ;Partial result in CX
  606	 0334  8B 55 02	 	 	        MOV     DX,[DI+2]
  607	 0337  0B D2	 	 	        OR      DX,DX
  608	 0339  74 06	 	 	        JZ      PROD3
  609	 033B  F7 E2	 	 	        MUL     DX
  610	 033D  03 C8	 	 	        ADD     CX,AX
  611	 033F  13 DA	 	 	        ADC     BX,DX
  612	 0341	 	 	 	PROD3:                          ;Partial result in BX:CX
  613	 0341  55	 	 	        PUSH    BP              ;Save insignificant bits on stack
  614	 0342  33 ED	 	 	        XOR     BP,BP
  615	 0344  8B 44 02	 	 	        MOV     AX,[SI+2]
  616	 0347  0B C0	 	 	        OR      AX,AX
  617	 0349  74 0E	 	 	        JZ      PROD4
  618	 034B  8B 15	 	 	        MOV     DX,[DI]
  619	 034D  0B D2	 	 	        OR      DX,DX
  620	 034F  74 08	 	 	        JZ      PROD4
  621	 0351  F7 E2	 	 	        MUL     DX
  622	 0353  03 C8	 	 	        ADD     CX,AX
  623	 0355  13 DA	 	 	        ADC     BX,DX
  624	 0357  D1 D5	 	 	        RCL     BP,1            ;Pick up carry
  625	 0359	 	 	 	PROD4:                          ;Partial result in BP:BX:CX
  626	 0359  58	 	 	        POP     AX
  627	 035A  0B C1	 	 	        OR      AX,CX           ;Record these bits before we throw them away
  628	 035C  50	 	 	        PUSH    AX
  629	 035D  8B 44 02	 	 	        MOV     AX,[SI+2]
  630	 0360  0B C0	 	 	        OR      AX,AX
  631	 0362  74 0D	 	 	        JZ      PROD5
  632	 0364  8B 55 02	 	 	        MOV     DX,[DI+2]
  633	 0367  0B D2	 	 	        OR      DX,DX
  634	 0369  74 06	 	 	        JZ      PROD5
  635	 036B  F7 E2	 	 	        MUL     DX
  636	 036D  03 D8	 	 	        ADD     BX,AX
  637	 036F  13 EA	 	 	        ADC     BP,DX
  638	 0371	 	 	 	PROD5:                          ;Partial result in BP:BX
  639	 0371  33 C9	 	 	        XOR     CX,CX
  640	 0373  8B 04	 	 	        MOV     AX,[SI]
  641	 0375  0B C0	 	 	        OR      AX,AX
  642	 0377  74 0F	 	 	        JZ      PROD6
  643	 0379  8B 55 04	 	 	        MOV     DX,[DI+4]
  644	 037C  0B D2	 	 	        OR      DX,DX
  645	 037E  74 08	 	 	        JZ      PROD6
  646	 0380  F7 E2	 	 	        MUL     DX
  647	 0382  03 D8	 	 	        ADD     BX,AX
  648	 0384  13 EA	 	 	        ADC     BP,DX


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-13
PMULD - Partial DP multiply


  649	 0386  D1 D1	 	 	        RCL     CX,1
  650	 0388	 	 	 	PROD6:                          ;Partial result in CX:BP:BX
  651	 0388  8B 44 04	 	 	        MOV     AX,[SI+4]
  652	 038B  0B C0	 	 	        OR      AX,AX
  653	 038D  74 0F	 	 	        JZ      PROD7
  654	 038F  8B 15	 	 	        MOV     DX,[DI]
  655	 0391  0B D2	 	 	        OR      DX,DX
  656	 0393  74 09	 	 	        JZ      PROD7
  657	 0395  F7 E2	 	 	        MUL     DX
  658	 0397  03 D8	 	 	        ADD     BX,AX
  659	 0399  13 EA	 	 	        ADC     BP,DX
  660	 039B  83 D1 00	 	 	        ADC     CX,0
  661	 039E	 	 	 	PROD7:                          ;Partial result in CX:BP:BX
  662	 039E  58	 	 	        POP     AX
  663	 039F  0B C3	 	 	        OR      AX,BX
  664	 03A1  50	 	 	        PUSH    AX
  665	 03A2  8B 04	 	 	        MOV     AX,[SI]
  666	 03A4  0B C0	 	 	        OR      AX,AX
  667	 03A6  74 08	 	 	        JZ      PROD8
  668	 03A8  F7 26 0002 R	 	        MUL     [OP2MAN]
  669	 03AC  03 E8	 	 	        ADD     BP,AX
  670	 03AE  13 CA	 	 	        ADC     CX,DX
  671	 03B0	 	 	 	PROD8:                          ;Partial result in CX:BP
  672	 03B0  8B 05	 	 	        MOV     AX,[DI]
  673	 03B2  0B C0	 	 	        OR      AX,AX
  674	 03B4  74 08	 	 	        JZ      PROD9
  675	 03B6  F7 26 0000 R	 	        MUL     [OP1MAN]
  676	 03BA  03 E8	 	 	        ADD     BP,AX
  677	 03BC  13 CA	 	 	        ADC     CX,DX
  678	 03BE	 	 	 	PROD9:                          ;Partial result in CX:BP
  679	 03BE  33 DB	 	 	        XOR     BX,BX
  680	 03C0  8B 44 02	 	 	        MOV     AX,[SI+2]
  681	 03C3  0B C0	 	 	        OR      AX,AX
  682	 03C5  74 0F	 	 	        JZ      PROD10
  683	 03C7  8B 55 04	 	 	        MOV     DX,[DI+4]
  684	 03CA  0B D2	 	 	        OR      DX,DX
  685	 03CC  74 08	 	 	        JZ      PROD10
  686	 03CE  F7 E2	 	 	        MUL     DX
  687	 03D0  03 E8	 	 	        ADD     BP,AX
  688	 03D2  13 CA	 	 	        ADC     CX,DX
  689	 03D4  D1 D3	 	 	        RCL     BX,1
  690	 03D6	 	 	 	PROD10:                         ;Partial result in BX:CX:BP
  691	 03D6  8B 44 04	 	 	        MOV     AX,[SI+4]
  692	 03D9  0B C0	 	 	        OR      AX,AX
  693	 03DB  74 10	 	 	        JZ      PROD11
  694	 03DD  8B 55 02	 	 	        MOV     DX,[DI+2]
  695	 03E0  0B D2	 	 	        OR      DX,DX
  696	 03E2  74 09	 	 	        JZ      PROD11
  697	 03E4  F7 E2	 	 	        MUL     DX
  698	 03E6  03 E8	 	 	        ADD     BP,AX
  699	 03E8  13 CA	 	 	        ADC     CX,DX
  700	 03EA  83 D3 00	 	 	        ADC     BX,0
  701	 03ED	 	 	 	PROD11:                         ;Partial result in BX:CX:BP
  702	 03ED  55	 	 	        PUSH    BP              ;Not enough registers to keep LSW


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Page 1-14
PMULD - Partial DP multiply


  703	 03EE  33 ED	 	 	        XOR     BP,BP
  704	 03F0  8B 45 02	 	 	        MOV     AX,[DI+2]
  705	 03F3  0B C0	 	 	        OR      AX,AX
  706	 03F5  74 08	 	 	        JZ      PROD12
  707	 03F7  F7 26 0000 R	 	        MUL     [OP1MAN]
  708	 03FB  03 C8	 	 	        ADD     CX,AX
  709	 03FD  13 DA	 	 	        ADC     BX,DX
  710	 03FF	 	 	 	PROD12:                         ;Partial result in BP:BX:CX
  711	 03FF  8B 44 02	 	 	        MOV     AX,[SI+2]
  712	 0402  0B C0	 	 	        OR      AX,AX
  713	 0404  74 08	 	 	        JZ      PROD13
  714	 0406  F7 26 0002 R	 	        MUL     [OP2MAN]
  715	 040A  03 C8	 	 	        ADD     CX,AX
  716	 040C  13 DA	 	 	        ADC     BX,DX
  717	 040E	 	 	 	PROD13:                         ;Partial result in BP:BX:CX
  718	 040E  8B 44 04	 	 	        MOV     AX,[SI+4]
  719	 0411  0B C0	 	 	        OR      AX,AX
  720	 0413  74 1A	 	 	        JZ      PROD15
  721	 0415  8B 55 04	 	 	        MOV     DX,[DI+4]
  722	 0418  0B D2	 	 	        OR      DX,DX
  723	 041A  74 0B	 	 	        JZ      PROD14
  724	 041C  F7 E2	 	 	        MUL     DX
  725	 041E  03 C8	 	 	        ADD     CX,AX
  726	 0420  13 DA	 	 	        ADC     BX,DX
  727	 0422  D1 D5	 	 	        RCL     BP,1
  728	 0424  8B 44 04	 	 	        MOV     AX,[SI+4]
  729	 0427	 	 	 	PROD14:                         ;Partial result in BP:BX:CX
  730	 0427  F7 26 0002 R	 	        MUL     [OP2MAN]
  731	 042B  03 D8	 	 	        ADD     BX,AX
  732	 042D  13 EA	 	 	        ADC     BP,DX
  733	 042F	 	 	 	PROD15:                         ;Partial result in BP:BX:CX
  734	 042F  8B 45 04	 	 	        MOV     AX,[DI+4]
  735	 0432  0B C0	 	 	        OR      AX,AX
  736	 0434  74 08	 	 	        JZ      PROD16
  737	 0436  F7 26 0000 R	 	        MUL     [OP1MAN]
  738	 043A  03 D8	 	 	        ADD     BX,AX
  739	 043C  13 EA	 	 	        ADC     BP,DX
  740	 043E	 	 	 	PROD16:                         ;Partial result in BP:BX:CX
  741	 043E  A0 0000 R	 	        MOV     AL,BYTE PTR[OP1MAN]
  742	 0441  F6 26 0002 R	 	        MUL     BYTE PTR[OP2MAN]
  743	 0445  03 C5	 	 	        ADD     AX,BP
  744	 0447  97	 	 	        XCHG    AX,DI
  745	 0448  5A	 	 	        POP     DX              ;Get least significant bits
  746	 0449  5E	 	 	        POP     SI              ;Get trimmed bits
  747	 044A  0B F6	 	 	        OR      SI,SI           ;Set flags
  748	 044C  C3	 	 	        RET
  749	 	 	 	 	
  750	 044D	 	 	 	CODE    ENDS
  751	 	 	 	 	        END







DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	044D	WORD  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0004	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ALIGNED. . . . . . . . . . . . .	L NEAR 	00CF	CODE
BITSHFT. . . . . . . . . . . . .	L NEAR 	00B9	CODE
BYTSHFT. . . . . . . . . . . . .	L NEAR 	0089	CODE
CHKALN . . . . . . . . . . . . .	L NEAR 	006C	CODE
DIV0 . . . . . . . . . . . . . .	L NEAR 	0284	CODE
DIV16. . . . . . . . . . . . . .	L NEAR 	0287	CODE
DNOR . . . . . . . . . . . . . .	L NEAR 	012F	CODE
DOADD. . . . . . . . . . . . . .	L NEAR 	0032	CODE
DODIV. . . . . . . . . . . . . .	L NEAR 	0299	CODE
GETSIGN. . . . . . . . . . . . .	L NEAR 	00D9	CODE
HIBYT. . . . . . . . . . . . . .	L NEAR 	0145	CODE
INCEXP . . . . . . . . . . . . .	L NEAR 	0201	CODE
MAXQUO . . . . . . . . . . . . .	L NEAR 	02ED	CODE
NORM . . . . . . . . . . . . . .	L NEAR 	012C	CODE
NORMCHK. . . . . . . . . . . . .	L NEAR 	01EE	CODE
NORMLP . . . . . . . . . . . . .	L NEAR 	0166	CODE
NORMSHF. . . . . . . . . . . . .	L NEAR 	0164	CODE
NOSTIK . . . . . . . . . . . . .	L NEAR 	0078	CODE
NSTIK. . . . . . . . . . . . . .	L NEAR 	0095	CODE
NSTK1. . . . . . . . . . . . . .	L NEAR 	027E	CODE
OP1MAN . . . . . . . . . . . . .	L WORD 	0000	DATA
OP2MAN . . . . . . . . . . . . .	L WORD 	0002	DATA
OVCHK. . . . . . . . . . . . . .	L NEAR 	01AF	CODE
OVCHKJ . . . . . . . . . . . . .	L NEAR 	01E0	CODE
OVERFLOW . . . . . . . . . . . .	L NEAR 	01B1	CODE
PMULD. . . . . . . . . . . . . .	L NEAR 	030B	CODE	Global
PROD10 . . . . . . . . . . . . .	L NEAR 	03D6	CODE
PROD11 . . . . . . . . . . . . .	L NEAR 	03ED	CODE
PROD12 . . . . . . . . . . . . .	L NEAR 	03FF	CODE
PROD13 . . . . . . . . . . . . .	L NEAR 	040E	CODE
PROD14 . . . . . . . . . . . . .	L NEAR 	0427	CODE
PROD15 . . . . . . . . . . . . .	L NEAR 	042F	CODE
PROD16 . . . . . . . . . . . . .	L NEAR 	043E	CODE
PROD2. . . . . . . . . . . . . .	L NEAR 	0334	CODE
PROD3. . . . . . . . . . . . . .	L NEAR 	0341	CODE
PROD4. . . . . . . . . . . . . .	L NEAR 	0359	CODE
PROD5. . . . . . . . . . . . . .	L NEAR 	0371	CODE
PROD6. . . . . . . . . . . . . .	L NEAR 	0388	CODE
PROD7. . . . . . . . . . . . . .	L NEAR 	039E	CODE
PROD8. . . . . . . . . . . . . .	L NEAR 	03B0	CODE
PROD9. . . . . . . . . . . . . .	L NEAR 	03BE	CODE
REM2 . . . . . . . . . . . . . .	L NEAR 	02AC	CODE


DMATH - Double precision floating point arithmetic       Macro-86 %1(12)   0:59:49  13-Nov-81   Symbols-2



REM3 . . . . . . . . . . . . . .	L NEAR 	02BA	CODE
REM4 . . . . . . . . . . . . . .	L NEAR 	02C9	CODE
RESTORE. . . . . . . . . . . . .	L NEAR 	02D9	CODE
RET. . . . . . . . . . . . . . .	L NEAR 	02EC	CODE
RNDJMP . . . . . . . . . . . . .	L NEAR 	0205	CODE
ROUND. . . . . . . . . . . . . .	L NEAR 	0174	CODE
ROUNDJ . . . . . . . . . . . . .	L NEAR 	00FD	CODE
ROUNDUP. . . . . . . . . . . . .	L NEAR 	0180	CODE
SAVDI. . . . . . . . . . . . . .	L NEAR 	0016	CODE
SAVE . . . . . . . . . . . . . .	L NEAR 	0192	CODE
SHFLEF . . . . . . . . . . . . .	L NEAR 	00AC	CODE
SHFRIG . . . . . . . . . . . . .	L NEAR 	00C3	CODE
SIGNFIDDLE . . . . . . . . . . .	L NEAR 	0044	CODE
SUBMAN . . . . . . . . . . . . .	L NEAR 	0102	CODE
ZERO . . . . . . . . . . . . . .	L NEAR 	01B4	CODE
ZERQUO . . . . . . . . . . . . .	L NEAR 	02D4	CODE
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DADD. . . . . . . . . . . . . .	L NEAR 	002F	CODE	Global
$DDIV. . . . . . . . . . . . . .	L NEAR 	0216	CODE	Global
$DIV0. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DMUL. . . . . . . . . . . . . .	L NEAR 	01C8	CODE	Global
$DNORM . . . . . . . . . . . . .	L NEAR 	012C	CODE	Global
$DROUND. . . . . . . . . . . . .	L NEAR 	0174	CODE	Global
$DSUB. . . . . . . . . . . . . .	L NEAR 	000E	CODE	Global
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FADB. . . . . . . . . . . . . .	L NEAR 	002C	CODE	Global
$FADD. . . . . . . . . . . . . .	L NEAR 	0021	CODE	Global
$FADF. . . . . . . . . . . . . .	L NEAR 	0029	CODE	Global
$FADH. . . . . . . . . . . . . .	L NEAR 	0026	CODE	Global
$FDVB. . . . . . . . . . . . . .	L NEAR 	0213	CODE	Global
$FDVD. . . . . . . . . . . . . .	L NEAR 	0208	CODE	Global
$FDVF. . . . . . . . . . . . . .	L NEAR 	0210	CODE	Global
$FDVH. . . . . . . . . . . . . .	L NEAR 	020D	CODE	Global
$FMUB. . . . . . . . . . . . . .	L NEAR 	01C5	CODE	Global
$FMUD. . . . . . . . . . . . . .	L NEAR 	01BA	CODE	Global
$FMUF. . . . . . . . . . . . . .	L NEAR 	01C2	CODE	Global
$FMUH. . . . . . . . . . . . . .	L NEAR 	01BF	CODE	Global
$FSUB. . . . . . . . . . . . . .	L NEAR 	000B	CODE	Global
$FSUD. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$FSUF. . . . . . . . . . . . . .	L NEAR 	0008	CODE	Global
$FSUH. . . . . . . . . . . . . .	L NEAR 	0005	CODE	Global
$GTMP. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$OVFL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0








