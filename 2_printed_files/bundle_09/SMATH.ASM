SMATH - Single precision floating point arithmetic       Macro-86 %1(12)   1:8:12  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   SMATH - Single precision floating point arithmetic
    2	 	 	 	 	
    3	 	 	 	 	; Single precision add, subtract, multiply and divide for the 8086.
    4	 	 	 	 	;
    5	 	 	 	 	; by Tim Paterson  July, 1981
    6	 	 	 	 	;
    7	 	 	 	 	; Each routine has four entry points:
    8	 	 	 	 	;
    9	 	 	 	 	; Suffix A means address of operands in SI and DI
   10	 	 	 	 	; Suffix C means first operand is FAC, second is at [DI] (SI smashed)
   11	 	 	 	 	; Suffix E means first operand is at [SI], second is FAC (DI smashed)
   12	 	 	 	 	; Suffix G means first operand is floating temp, second is FAC (SI and DI hit)
   13	 	 	 	 	;
   14	 	 	 	 	; These entry points set up SI and DI to point to the least significant byte
   15	 	 	 	 	; of the two operands in standard Microsoft floating point format, then fall
   16	 	 	 	 	; into the arithmetic routine. Except for possible set up of SI or DI or both,
   17	 	 	 	 	; all registers are preserved. The result is returned in the FAC.
   18	 	 	 	 	;
   19	 	 	 	 	; All operations are performed in 8086 registers. This means that either SI
   20	 	 	 	 	; or DI or both may point to the result location ($AC). The operands in
   21	 	 	 	 	; memory are not affected. No memory storage is used until the result is
   22	 	 	 	 	; stored.
   23	 	 	 	 	;
   24	 	 	 	 	; These routines are completely accurate, rounded to 24 bit precision using
   25	 	 	 	 	; IEEE floating point standard rounding rules. These rounding rules require
   26	 	 	 	 	; maintaining a "sticky bit", which is set whenever insignificant bits are
   27	 	 	 	 	; lost. If a result is exactly halfway between two representable values, we
   28	 	 	 	 	; "round even"--so that the LSB of the result is zero. For this to happen,
   29	 	 	 	 	; the sticky bit must be zero.
   30	 	 	 	 	
   31	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
   32	 	 	 	 	
   33	 	 	 	 	        EXTRN   $AC:WORD, $FAC:BYTE
   34	 	 	 	 	
   35	 0000	 	 	 	DATA    ENDS
   36	 	 	 	 	
   37	 	 	 	 	DC      GROUP   DATA
   38	 	 	 	 	
   39	 0000	 	 	 	CODE    SEGMENT WORD PUBLIC 'CODE'
   40	 	 	 	 	
   41	 	 	 	 	        PUBLIC  $FADA,$FADC,$FADE,$FADG,$FSUA,$FSUC,$FSUE,$FSUG
   42	 	 	 	 	        PUBLIC  $FMUA,$FMUC,$FMUE,$FMUG,$FDVA,$FDVC,$FDVE,$FDVG
   43	 	 	 	 	        PUBLIC  $SADD,$SSUB,$SMUL,$SDIV,$SNORM,$SRND,PMULS
   44	 	 	 	 	
   45	 	 	 	 	        EXTRN   $OVFL:NEAR,$DIV0:NEAR,$GTMP:NEAR,$SAVREG:NEAR
   46	 	 	 	 	
   47	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   48	 	 	 	 	
   49	 	 	 	 	
   50	 0000	 	 	 	$FSUC:
   51	 0000  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   52	 0003  EB 06	 	 	        JMP     SHORT $FSUA
   53	 0005	 	 	 	$FSUG:
   54	 0005  E8 0000 E	 	        CALL    $GTMP


SMATH - Single precision floating point arithmetic       Macro-86 %1(12)   1:8:12  13-Nov-81    Page 1-2



   55	 0008	 	 	 	$FSUE:
   56	 0008  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   57	 000B	 	 	 	$FSUA:
   58	 000B  E8 0000 E	 	        CALL    $SAVREG
   59	 	 	 	 	
   60	 	 	 	 	;***  $SSUB and $SADD - Single precision subtraction and addition
   61	 	 	 	 	;
   62	 	 	 	 	; Inputs:
   63	 	 	 	 	;       SI = Address of Minuend or Addend
   64	 	 	 	 	;       DI = Address of Subtrahend Or Addend
   65	 	 	 	 	; Function:
   66	 	 	 	 	;       FAC = [SI] - [DI]  or  FAC = [SI] + [DI]
   67	 	 	 	 	; Outputs:
   68	 	 	 	 	;       Result in FAC.
   69	 	 	 	 	; Registers:
   70	 	 	 	 	;       All except BP destroyed.
   71	 	 	 	 	
   72	 000E	 	 	 	$SSUB:
   73	 000E  8B 45 02	 	 	        MOV     AX,[DI+2]       ;Get sign & exponent on subtrahend
   74	 0011  34 80	 	 	        XOR     AL,80H          ;Invert its sign
   75	 0013  EB 11	 	 	        JMP     SHORT DOADD     ;   and just add
   76	 	 	 	 	
   77	 0015	 	 	 	$FADC:
   78	 0015  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   79	 0018  EB 06	 	 	        JMP     SHORT $FADA
   80	 001A	 	 	 	$FADG:
   81	 001A  E8 0000 E	 	        CALL    $GTMP
   82	 001D	 	 	 	$FADE:
   83	 001D  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   84	 0020	 	 	 	$FADA:
   85	 0020  E8 0000 E	 	        CALL    $SAVREG
   86	 	 	 	 	
   87	 0023	 	 	 	$SADD:
   88	 0023  8B 45 02	 	 	        MOV     AX,[DI+2]       ;Get sign & exponent of one operand
   89	 0026	 	 	 	DOADD:
   90	 0026  8B 5D 01	 	 	        MOV     BX,[DI+1]       ;Get most significant 16 bits of mantissa
   91	 0029  8A 35	 	 	        MOV     DH,[DI]         ;Get least significant bits
   92	 002B  B2 00	 	 	        MOV     DL,0            ;Extend to 32 bits
   93	 002D  80 CF 80	 	 	        OR      BH,80H          ;Set implied bit
   94	 0030  8B 4C 02	 	 	        MOV     CX,[SI+2]       ;Get sign & exponent of other operand
   95	 0033  8B 7C FF	 	 	        MOV     DI,[SI-1]       ;High byte is least significant bits
   96	 0036  8B 74 01	 	 	        MOV     SI,[SI+1]       ;Most significant 16 bits of mantissa
   97	 0039  81 E7 FF00	 	        AND     DI,0FF00H       ;Extend mantissa to 32 bits with zeros
   98	 003D  81 CE 8000	 	        OR      SI,8000H        ;Set implied bit
   99	 	 	 	 	
  100	 	 	 	 	; At this point, the mantissa of first number is in BX:DX, with exponent
  101	 	 	 	 	; and sign in AX. Second number has mantissa in SI:DI, with exponent and sign
  102	 	 	 	 	; in CX. Note that these mantissas have been extended to 32 bits with a byte
  103	 	 	 	 	; of zero and have the implied first bit set.
  104	 	 	 	 	
  105	 0041  0A ED	 	 	        OR      CH,CH
  106	 0043  74 63	 	 	        JZ      SAVJ            ;If one is zero, return other
  107	 0045  0A E4	 	 	        OR      AH,AH
  108	 0047  74 59	 	 	        JZ      SAV2


SMATH - Single precision floating point arithmetic       Macro-86 %1(12)   1:8:12  13-Nov-81    Page 1-3



  109	 0049  3A EC	 	 	        CMP     CH,AH           ;See which number is larger
  110	 004B  73 05	 	 	        JAE     SIGNFIDDLE      ;See if difference is non-negative
  111	 	 	 	 	
  112	 	 	 	 	;Swap operands so smaller is in BX:DX
  113	 	 	 	 	
  114	 004D  87 F3	 	 	        XCHG    SI,BX
  115	 004F  87 FA	 	 	        XCHG    DI,DX           ;Swap mantissas
  116	 0051  91	 	 	        XCHG    AX,CX           ;Swap exponents/signs
  117	 	 	 	 	
  118	 0052	 	 	 	SIGNFIDDLE:
  119	 0052  2A E5	 	 	        SUB     AH,CH           ;Subtract exponents ( <=0 )
  120	 0054  F6 DC	 	 	        NEG     AH
  121	 0056  80 FC 18	 	 	        CMP     AH,24           ;Is smaller argument significant?
  122	 0059  77 47	 	 	        JA      SAV2
  123	 005B  D0 E0	 	 	        SHL     AL,1            ;Put sign of smaller into carry
  124	 005D  D0 D9	 	 	        RCR     CL,1            ;Now pack it in next to sign of larger
  125	 005F  91	 	 	        XCHG    AX,CX
  126	 0060  8A CD	 	 	        MOV     CL,CH
  127	 0062  B5 00	 	 	        MOV     CH,0
  128	 	 	 	 	
  129	 	 	 	 	; Now things look like this:
  130	 	 	 	 	;       BX:DX has mantissa of smaller
  131	 	 	 	 	;       SI:DI has mantissa of larger
  132	 	 	 	 	;       AL bit 7 has sign of smaller
  133	 	 	 	 	;       AL bit 6 has sign of larger
  134	 	 	 	 	;       CL has exponent difference ( 0 <= CL <= 24 )
  135	 	 	 	 	;       CH is zero
  136	 	 	 	 	;       AH has exponent of larger ( = tentative exponent of result)
  137	 	 	 	 	
  138	 0064  E3 53	 	 	        JCXZ    ALIGNED         ;Already aligned?
  139	 0066  80 F9 0E	 	 	        CMP     CL,14           ;Word shift possible?
  140	 0069  7C 12	 	 	        JL      BYTSHF
  141	 006B  0B D2	 	 	        OR      DX,DX
  142	 006D  74 03	 	 	        JZ      NSTK
  143	 006F  80 CB 01	 	 	        OR      BL,1
  144	 0072	 	 	 	NSTK:
  145	 0072  8B D3	 	 	        MOV     DX,BX
  146	 0074  33 DB	 	 	        XOR     BX,BX
  147	 0076  80 E9 10	 	 	        SUB     CL,16
  148	 0079  72 1D	 	 	        JB      SHFLEF
  149	 007B  74 3C	 	 	        JZ      ALIGNED
  150	 007D	 	 	 	BYTSHF:
  151	 007D  80 F9 05	 	 	        CMP     CL,5            ;Do shifts >5 bits by byte rotate
  152	 0080  7E 29	 	 	        JLE     BITSHFT         ;Just shift bits if alignment close
  153	 0082  0A D2	 	 	        OR      DL,DL           ;See if we're shifting something off the end
  154	 0084  74 03	 	 	        JZ      NOSTIK
  155	 0086  80 CE 01	 	 	        OR      DH,1            ;Ensure sticky bit will be set
  156	 0089	 	 	 	NOSTIK:
  157	 0089  8A D6	 	 	        MOV     DL,DH           ;Do byte shift
  158	 008B  8A F3	 	 	        MOV     DH,BL
  159	 008D  8A DF	 	 	        MOV     BL,BH
  160	 008F  8A FD	 	 	        MOV     BH,CH           ;CH=0
  161	 0091  80 E9 08	 	 	        SUB     CL,8            ;Counts for 8 bit shifts
  162	 0094  77 15	 	 	        JA      BITSHFT         ;If not enough, try again


SMATH - Single precision floating point arithmetic       Macro-86 %1(12)   1:8:12  13-Nov-81    Page 1-4



  163	 0096  74 21	 	 	        JZ      ALIGNED         ;Hit it exactly?
  164	 	 	 	 	
  165	 	 	 	 	;To get here, we must have used a byte shift when we needed to shift less than
  166	 	 	 	 	;8 bits. Now we must correct by 1 or 2 left shifts.
  167	 	 	 	 	
  168	 0098	 	 	 	SHFLEF:
  169	 0098  D1 E2	 	 	        SHL     DX,1
  170	 009A  D1 D3	 	 	        RCL     BX,1
  171	 009C  FE C1	 	 	        INC     CL
  172	 009E  75 F8	 	 	        JNZ     SHFLEF          ;Until CL is back to zero (from -1 or -2)
  173	 00A0  EB 17	 	 	        JMP     SHORT ALIGNED
  174	 	 	 	 	
  175	 00A2	 	 	 	SAV2:
  176	 00A2  8B DE	 	 	        MOV     BX,SI
  177	 00A4  8B D7	 	 	        MOV     DX,DI           ;Move mantissa to rounding registers
  178	 00A6  8B C1	 	 	        MOV     AX,CX
  179	 00A8  E9 0130 R	 	SAVJ:   JMP     SAVE
  180	 	 	 	 	
  181	 00AB	 	 	 	BITSHFT:
  182	 00AB  F6 C2 3F	 	 	        TEST    DL,3FH          ;See if we're shifting stuff off the end
  183	 00AE  74 03	 	 	        JZ      SHFRIG
  184	 00B0  80 CA 20	 	 	        OR      DL,20H          ;Set sticky bit if so
  185	 00B3	 	 	 	SHFRIG:
  186	 00B3  D1 EB	 	 	        SHR     BX,1
  187	 00B5  D1 DA	 	 	        RCR     DX,1
  188	 00B7  E2 FA	 	 	        LOOP    SHFRIG          ;Do 1 to 5 32-bit right shifts
  189	 00B9	 	 	 	ALIGNED:
  190	 00B9  F6 C2 3F	 	 	        TEST    DL,3FH          ;Collapse LSBs into sticky bit
  191	 00BC  74 03	 	 	        JZ      GETSIGN
  192	 00BE  80 CA 20	 	 	        OR      DL,20H          ;Set sticky bit
  193	 00C1	 	 	 	GETSIGN:
  194	 00C1  D0 E0	 	 	        SHL     AL,1            ;Shift sign bits out to test
  195	 	 	 	 	
  196	 	 	 	 	;Now AL = sign of larger ( = tentative sign of result)
  197	 	 	 	 	;Carry = sign of smaller.
  198	 	 	 	 	;Overflow flag is set if these two are different.
  199	 	 	 	 	
  200	 00C3  70 11	 	 	        JO      SUBMAN          ;Subtract mantissas if signs are different
  201	 00C5  03 D7	 	 	        ADD     DX,DI           ;Add mantissas since signs are the same
  202	 00C7  13 DE	 	 	        ADC     BX,SI
  203	 00C9  73 4D	 	 	        JNC     ROUND
  204	 	 	 	 	;Have a carry, so result must be shifted right and exponent incremented
  205	 00CB  D1 DB	 	 	        RCR     BX,1
  206	 00CD  D1 DA	 	 	        RCR     DX,1
  207	 00CF  FE C4	 	 	        INC     AH              ;Bump exponent
  208	 00D1  75 45	 	 	        JNZ     ROUND
  209	 00D3  E9 0000 E	 	        JMP     $OVFL
  210	 	 	 	 	
  211	 00D6	 	 	 	SUBMAN:
  212	 	 	 	 	;Subtract mantissas since signs are different
  213	 00D6  2B FA	 	 	        SUB     DI,DX
  214	 00D8  1B F3	 	 	        SBB     SI,BX
  215	 00DA  8B D7	 	 	        MOV     DX,DI
  216	 00DC  8B DE	 	 	        MOV     BX,SI


SMATH - Single precision floating point arithmetic       Macro-86 %1(12)   1:8:12  13-Nov-81    Page 1-5



  217	 00DE  73 0A	 	 	        JNC     NORM
  218	 	 	 	 	;OOPS! Number we thought was bigger wasn't. Now we have to negate result.
  219	 00E0  F7 D3	 	 	        NOT     BX
  220	 00E2  F7 DA	 	 	        NEG     DX              ;Sets carry if not zero
  221	 00E4  F5	 	 	        CMC                     ;Carry now set if zero
  222	 00E5  83 D3 00	 	 	        ADC     BX,0            ;Propagate carry from Complement and Increment
  223	 00E8  F6 D0	 	 	        NOT     AL              ;Flip sign bit
  224	 	 	 	 	
  225	 00EA	 	 	 	$SNORM:
  226	 	 	 	 	;Single precision normalize and store in $AC
  227	 	 	 	 	
  228	 00EA	 	 	 	NORM:
  229	 00EA  0B DB	 	 	        OR      BX,BX           ;See if any bits on in high word
  230	 00EC  75 0B	 	 	        JNZ     HIBYT           ;If so, go check high byte for zero
  231	 00EE  80 EC 10	 	 	        SUB     AH,16           ;Drop exponent by shift count
  232	 00F1  76 54	 	 	        JBE     ZERO
  233	 00F3  87 DA	 	 	        XCHG    BX,DX           ;Shift left 16 bits
  234	 00F5  0B DB	 	 	        OR      BX,BX           ;See if all zero
  235	 00F7  74 4E	 	 	        JZ      ZERO
  236	 00F9	 	 	 	HIBYT:
  237	 00F9  0A FF	 	 	        OR      BH,BH           ;See if we can shift 8 bits
  238	 00FB  75 0F	 	 	        JNZ     NORMSHF
  239	 00FD  80 EC 08	 	 	        SUB     AH,8            ;Drop exponent by shift amount
  240	 0100  76 45	 	 	        JBE     ZERO
  241	 0102  8A FB	 	 	        MOV     BH,BL           ;Do byte shift
  242	 0104  8A DE	 	 	        MOV     BL,DH
  243	 0106  8A F2	 	 	        MOV     DH,DL
  244	 0108  B2 00	 	 	        MOV     DL,0
  245	 010A  0A FF	 	 	        OR      BH,BH           ;See if normalized yet
  246	 010C	 	 	 	NORMSHF:
  247	 010C  78 0A	 	 	        JS      ROUND           ;Normalize complete?
  248	 010E	 	 	 	NORMLP:
  249	 010E  FE CC	 	 	        DEC     AH              ;Account for shift in exponent
  250	 0110  74 35	 	 	        JZ      ZERO
  251	 0112  D1 E2	 	 	        SHL     DX,1
  252	 0114  D1 D3	 	 	        RCL     BX,1
  253	 0116  71 F6	 	 	        JNO     NORMLP          ;Overflow will be set when sign bit changes
  254	 	 	 	 	
  255	 0118	 	 	 	$SRND:
  256	 	 	 	 	;Round single precision and store in $AC
  257	 	 	 	 	
  258	 0118	 	 	 	ROUND:
  259	 0118  80 FA 80	 	 	        CMP     DL,80H          ;Check extended bits
  260	 011B  77 07	 	 	        JA      ROUNDUP
  261	 011D  72 11	 	 	        JB      SAVE
  262	 	 	 	 	;Extended bits equal exactly one-half LSB, so round even
  263	 011F  F6 C6 01	 	 	        TEST    DH,1            ;Already even?
  264	 0122  74 0C	 	 	        JZ      SAVE
  265	 0124	 	 	 	ROUNDUP:
  266	 0124  80 C6 01	 	 	        ADD     DH,1
  267	 0127  83 D3 00	 	 	        ADC     BX,0            ;Propagate carry
  268	 012A  73 04	 	 	        JNC     SAVE            ;Overflow?
  269	 	 	 	 	;If we overflowed, BX:DH must now be zero, so we can leave it that way.
  270	 012C  FE C4	 	 	        INC     AH              ;Increment exponent


SMATH - Single precision floating point arithmetic       Macro-86 %1(12)   1:8:12  13-Nov-81    Page 1-6



  271	 012E  74 14	 	 	        JZ      OVERFLOW
  272	 0130	 	 	 	SAVE:
  273	 0130  24 80	 	 	        AND     AL,80H          ;Strip to sign bit
  274	 0132  80 E7 7F	 	 	        AND     BH,7FH          ;Mask off implied bit
  275	 0135  0A C7	 	 	        OR      AL,BH           ;Combine sign with mantissa
  276	 0137  A3 0002 E	 	        MOV     [$AC+2],AX
  277	 013A  8A E3	 	 	        MOV     AH,BL
  278	 013C  8A C6	 	 	        MOV     AL,DH
  279	 013E  A3 0000 E	 	        MOV     [$AC],AX        ;Save lower part of mantissa
  280	 0141  C3	 	 	        RET
  281	 	 	 	 	
  282	 0142	 	 	 	OVCHK:
  283	 0142  79 03	 	 	        JNS     ZERO
  284	 0144	 	 	 	OVERFLOW:
  285	 0144  E9 0000 E	 	        JMP     $OVFL
  286	 	 	 	 	
  287	 0147	 	 	 	ZERO:
  288	 0147  C6 06 0000 E 00	 	        MOV     $FAC,0          ;Zero the exponent to return value of zero
  289	 014C  C3	 	 	        RET
  290	 	 	 	 	
  291	 	 	 	 	
  292	 014D	 	 	 	$FMUC:
  293	 014D  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
  294	 0150  EB 06	 	 	        JMP     SHORT $FMUA
  295	 0152	 	 	 	$FMUG:
  296	 0152  E8 0000 E	 	        CALL    $GTMP
  297	 0155	 	 	 	$FMUE:
  298	 0155  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
  299	 0158	 	 	 	$FMUA:
  300	 0158  E8 0000 E	 	        CALL    $SAVREG
  301	 	 	 	 	
  302	 	 	 	 	;***  $SMUL - Single precision multiply
  303	 	 	 	 	;
  304	 	 	 	 	; Inputs:
  305	 	 	 	 	;       SI = Address of one operand
  306	 	 	 	 	;       DI = Address of other operand
  307	 	 	 	 	; Function:
  308	 	 	 	 	;       FAC = [SI] * [DI]
  309	 	 	 	 	; Outputs:
  310	 	 	 	 	;       Result in FAC.
  311	 	 	 	 	; Registers:
  312	 	 	 	 	;       All but BP destroyed.
  313	 	 	 	 	
  314	 015B	 	 	 	$SMUL:
  315	 015B  AD	 	 	        LODSW                   ;Low part of op1
  316	 015C  8B 34	 	 	        MOV     SI,[SI]         ;High part of op1
  317	 015E  96	 	 	        XCHG    AX,SI
  318	 015F  0A E4	 	 	        OR      AH,AH
  319	 0161  74 E4	 	 	        JZ      ZERO
  320	 0163  8B 4D 02	 	 	        MOV     CX,[DI+2]       ;High part of op2
  321	 0166  0A ED	 	 	        OR      CH,CH
  322	 0168  74 DD	 	 	        JZ      ZERO
  323	 016A  8B 3D	 	 	        MOV     DI,[DI]         ;Low part of op2
  324	 016C  8B D8	 	 	        MOV     BX,AX           ;Duplicate hight part of op1


SMATH - Single precision floating point arithmetic       Macro-86 %1(12)   1:8:12  13-Nov-81    Page 1-7



  325	 016E  32 C1	 	 	        XOR     AL,CL           ;Compute sign
  326	 	 	 	 	
  327	 	 	 	 	;Exponent computation.
  328	 	 	 	 	;Compute sum of exponents minus one. The minus one is valid if the product
  329	 	 	 	 	;will need normalization by one bit. If it doesn't, one will be added to the
  330	 	 	 	 	;exponent. A zero exponent will temporarily be OK because of this possibility
  331	 	 	 	 	;of adding one later.
  332	 	 	 	 	
  333	 0170  80 EC 81	 	 	        SUB     AH,128+1        ;Subtract bias and extra "minus one"
  334	 0173  80 ED 80	 	 	        SUB     CH,128
  335	 0176  02 E5	 	 	        ADD     AH,CH           ;Add exponents
  336	 0178  70 C8	 	 	OVCHKJ: JO      OVCHK           ;If overflow, check whether up or down
  337	 017A  80 C4 80	 	 	        ADD     AH,128          ;Put bias back in
  338	 017D  50	 	 	        PUSH    AX              ;Save sign and tentative exponent
  339	 017E  E8 019A R	 	        CALL    PMULS           ;Multiply mantissas
  340	 0181  8B D3	 	 	        MOV     DX,BX
  341	 0183  93	 	 	        XCHG    AX,BX           ;Result in BX:DX
  342	 0184	 	 	 	NORMCHK:
  343	 0184  58	 	 	        POP     AX              ;Get exp. and sign back
  344	 0185  0A FF	 	 	        OR      BH,BH           ;See if normalized
  345	 0187  78 0A	 	 	        JS      INCEXP          ;Yes-increment exponent
  346	 0189  D1 E2	 	 	        SHL     DX,1            ;Normalize
  347	 018B  D1 D3	 	 	        RCL     BX,1
  348	 018D  0A E4	 	 	        OR      AH,AH           ;Is exponent zero?
  349	 018F  75 87	 	 	        JNZ     ROUND
  350	 0191  EB B4	 	 	ZEROJ:  JMP     ZERO
  351	 0193	 	 	 	INCEXP:
  352	 0193  FE C4	 	 	        INC     AH
  353	 0195  74 AD	 	 	        JZ      OVERFLOW
  354	 0197  E9 0118 R	 	        JMP     ROUND
  355	 	 	 	 	
  356	 	 	 	 	
  357	 	 	 	 	;***  PMULS - Partial SP multiply
  358	 	 	 	 	;
  359	 	 	 	 	; Inputs:
  360	 	 	 	 	;       BL:SI has op1 mantissa
  361	 	 	 	 	;       CL:DI has op2 mantissa (implied bit need NOT be set)
  362	 	 	 	 	; Function:
  363	 	 	 	 	;       Multiply mantissas and provide unrounded 32 bit result.
  364	 	 	 	 	;       Last bit is sticky bit.
  365	 	 	 	 	; Outputs:
  366	 	 	 	 	;       Result is in AX:BX
  367	 	 	 	 	; Registers:
  368	 	 	 	 	;       All except BP used.
  369	 	 	 	 	
  370	 019A	 	 	 	PMULS:
  371	 019A  B7 00	 	 	        MOV     BH,0           ;Extend high end of mantissa
  372	 019C  8A EF	 	 	        MOV     CH,BH          ;   for both operands
  373	 019E  80 CB 80	 	 	        OR      BL,80H         ;Set implied bit
  374	 01A1  80 C9 80	 	 	        OR      CL,80H
  375	 	 	 	 	
  376	 	 	 	 	;Multiply mantissas by summing partial products (using 16x16 multiply)
  377	 	 	 	 	;       BX:SI has op1
  378	 	 	 	 	;       CX:DI has op2


SMATH - Single precision floating point arithmetic       Macro-86 %1(12)   1:8:12  13-Nov-81    Page 1-8



  379	 	 	 	 	;Both are extended to 32 bits with leading zeros and have implied bit set
  380	 	 	 	 	
  381	 01A4  53	 	 	        PUSH    BX
  382	 01A5  53	 	 	        PUSH    BX             ;We'll need these later
  383	 01A6  8B C6	 	 	        MOV     AX,SI          ;Low part of op1
  384	 01A8  F7 E7	 	 	        MUL     DI             ;Times low part of op2
  385	 01AA  8B DA	 	 	        MOV     BX,DX          ;Save only high half
  386	 01AC  0B C0	 	 	        OR      AX,AX          ;See if we're losing some bits
  387	 01AE  58	 	 	        POP     AX             ;Get high part of op1
  388	 01AF  9C	 	 	        PUSHF                  ;Save flags indicating losing bits
  389	 01B0  F7 E7	 	 	        MUL     DI             ;Time low part of op2
  390	 01B2  03 D8	 	 	        ADD     BX,AX          ;Sum partial products
  391	 01B4  83 D2 00	 	 	        ADC     DX,0           ;Propogate carry
  392	 01B7  8B FA	 	 	        MOV     DI,DX          ;Save high part of result
  393	 01B9  8B C1	 	 	        MOV     AX,CX          ;High part of op2
  394	 01BB  F7 E6	 	 	        MUL     SI             ;Times low part of op1
  395	 01BD  03 D8	 	 	        ADD     BX,AX          ;32-bit sum of partial products
  396	 01BF  13 FA	 	 	        ADC     DI,DX
  397	 01C1  9D	 	 	        POPF                   ;Did we drop some low order bits?
  398	 01C2  74 03	 	 	        JZ      NSTK2
  399	 01C4  80 CB 01	 	 	        OR      BL,1           ;Set sticky bit if so
  400	 01C7	 	 	 	NSTK2:
  401	 01C7  58	 	 	        POP     AX             ;High part of op1 again
  402	 01C8  F6 E1	 	 	        MUL     CL             ;Finally! Most significant partial product
  403	 01CA  03 C7	 	 	        ADD     AX,DI          ;Result now in AX:BX
  404	 01CC  C3	 	 	        RET
  405	 	 	 	 	
  406	 	 	 	 	
  407	 01CD	 	 	 	$FDVC:
  408	 01CD  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
  409	 01D0  EB 06	 	 	        JMP     SHORT $FDVA
  410	 01D2	 	 	 	$FDVG:
  411	 01D2  E8 0000 E	 	        CALL    $GTMP
  412	 01D5	 	 	 	$FDVE:
  413	 01D5  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
  414	 01D8	 	 	 	$FDVA:
  415	 01D8  E8 0000 E	 	        CALL    $SAVREG
  416	 	 	 	 	
  417	 	 	 	 	;***  $SDIV - Single precision divide
  418	 	 	 	 	;
  419	 	 	 	 	; Inputs:
  420	 	 	 	 	;       SI = Address of Dividend (Numerator)
  421	 	 	 	 	;       DI = Address of Divisor (Denominator)
  422	 	 	 	 	; Function:
  423	 	 	 	 	;       FAC = [SI] / [DI]
  424	 	 	 	 	; Outputs:
  425	 	 	 	 	;       Result in FAC.
  426	 	 	 	 	; Registers:
  427	 	 	 	 	;       All except BP destroyed.
  428	 	 	 	 	
  429	 01DB	 	 	 	$SDIV:
  430	 01DB  8B 4D 02	 	 	        MOV     CX,[DI+2]       ;Exponent and sign of denominator
  431	 01DE  8B 44 02	 	 	        MOV     AX,[SI+2]       ;Exponent and sign of numerator
  432	 01E1  0A ED	 	 	        OR      CH,CH           ;Denominator zero?


SMATH - Single precision floating point arithmetic       Macro-86 %1(12)   1:8:12  13-Nov-81    Page 1-9



  433	 01E3  74 43	 	 	        JZ      DIV0
  434	 01E5  0A E4	 	 	        OR      AH,AH           ;Numerator zero?
  435	 01E7  74 A8	 	 	        JZ      ZEROJ
  436	 01E9  32 C1	 	 	        XOR     AL,CL           ;Compute sign
  437	 01EB  80 EC 80	 	 	        SUB     AH,128          ;Remove bias from exponents
  438	 01EE  80 ED 80	 	 	        SUB     CH,128
  439	 01F1  2A E5	 	 	        SUB     AH,CH           ;Compute result exponent
  440	 01F3  70 83	 	 	        JO      OVCHKJ
  441	 	 	 	 	
  442	 	 	 	 	;AH has the (tentative) true exponent of the result. It is correct if the
  443	 	 	 	 	;result needs normalizing one bit. If not, 1 will be added to it. A true
  444	 	 	 	 	;exponent of -128, not normally allowed except to represent zero, is OK
  445	 	 	 	 	;here because of this possible future incrementing.
  446	 	 	 	 	
  447	 01F5  80 C4 80	 	 	        ADD     AH,128          ;Put bias back
  448	 01F8  50	 	 	        PUSH    AX              ;Save sign and exponent
  449	 01F9  80 C9 80	 	 	        OR      CL,80H          ;Set implied bit
  450	 01FC  8B 54 01	 	 	        MOV     DX,[SI+1]       ;Most significant part of numerator mantissa
  451	 01FF  8A 24	 	 	        MOV     AH,[SI]         ;Least significant part
  452	 0201  32 C0	 	 	        XOR     AL,AL           ;Extend with zero
  453	 0203  80 CE 80	 	 	        OR      DH,80H          ;And set implied bit
  454	 0206  8B 5D 01	 	 	        MOV     BX,[DI+1]       ;Load denominator into BX:CX
  455	 0209  8A 2D	 	 	        MOV     CH,[DI]
  456	 020B  32 C9	 	 	        XOR     CL,CL
  457	 020D  80 CF 80	 	 	        OR      BH,80H
  458	 	 	 	 	
  459	 	 	 	 	;Now we have the following configuration:
  460	 	 	 	 	;       Numerator in DX:AX
  461	 	 	 	 	;       Denominator in BX:CX
  462	 	 	 	 	; Both are extended to 32 bits with trailing zeros and have implied bit set
  463	 	 	 	 	;       Result will go in BX:DX
  464	 	 	 	 	;
  465	 	 	 	 	;The algorithm used here is similar to Algorithm D, p.237, Knuth vol. 2.
  466	 	 	 	 	;It is basically just ordinary long division, except the base is 2^16. This
  467	 	 	 	 	;means we are dividing two 2-digit numbers, where each "digit" takes a whole
  468	 	 	 	 	;word. We "guess" at a quotient digit, multiply it by the divisor, and subtract
  469	 	 	 	 	;from the current dividend to get a remainder. This remainder could be
  470	 	 	 	 	;negative, so we try a quotient digit one smaller.
  471	 	 	 	 	;
  472	 	 	 	 	;The "guess" at the quotient digit simply uses the 8086 DIV instruction.
  473	 	 	 	 	;Computing the remainder takes advantage of the remainder from this divide. If
  474	 	 	 	 	;the remainder comes out negative, new quotient digits are tried by repeated
  475	 	 	 	 	;addition, rather than another multiply. Theorem B on p.237 of Knuth vol. 2
  476	 	 	 	 	;guarantees that this repeated addition will happen no more than twice.
  477	 	 	 	 	
  478	 0210  D1 EA	 	 	        SHR     DX,1
  479	 0212  D1 D8	 	 	        RCR     AX,1            ;Ensure DX<BX so divide won't overflow
  480	 0214  E8 022F R	 	        CALL    DIV16           ;Get first 16 bits of quotient
  481	 0217  56	 	 	        PUSH    SI              ;Save high half of quotient on stack
  482	 0218  E8 022B R	 	        CALL    CDIV16          ;Get second 16 bits of quotient
  483	 021B  0B C2	 	 	        OR      AX,DX           ;Remainder 0?
  484	 021D  8B D6	 	 	        MOV     DX,SI           ;Want low half of result in DX
  485	 021F  74 03	 	 	        JZ      NSTK1
  486	 0221  80 CA 01	 	 	        OR      DL,1            ;Set sticky bit if remainder not zero


SMATH - Single precision floating point arithmetic       Macro-86 %1(12)   1:8:12  13-Nov-81    Page 1-10



  487	 0224	 	 	 	NSTK1:
  488	 0224  5B	 	 	        POP     BX              ;Recover high half of result
  489	 0225  E9 0184 R	 	        JMP     NORMCHK
  490	 	 	 	 	
  491	 0228  E9 0000 E	 	DIV0:   JMP     $DIV0
  492	 	 	 	 	
  493	 022B	 	 	 	CDIV16:
  494	 022B  3B D3	 	 	        CMP     DX,BX           ;Will we overflow on divide?
  495	 022D  73 1D	 	 	        JAE     MAXQUO          ;Special code for maximum quotient
  496	 022F	 	 	 	DIV16:
  497	 022F  F7 F3	 	 	        DIV     BX              ;32 by 16 bit division
  498	 0231  96	 	 	        XCHG    AX,SI           ;Put 16-bit quotient in SI
  499	 0232  33 C0	 	 	        XOR     AX,AX           ;DX:AX has remainder
  500	 0234  E3 15	 	 	        JCXZ    RETJ            ;Is this complete result?
  501	 0236  8B FA	 	 	        MOV     DI,DX           ;Save remainder while we multiply
  502	 0238  8B C6	 	 	        MOV     AX,SI
  503	 023A  F7 E1	 	 	        MUL     CX              ;Low half of divisor times quotient
  504	 023C  F7 D8	 	 	        NEG     AX              ;Subtract from remainder, whose low half is 0
  505	 023E  1B FA	 	 	        SBB     DI,DX
  506	 0240  8B D7	 	 	        MOV     DX,DI           ;Remainder again in DX:AX
  507	 0242  73 07	 	 	        JNC     RETJ            ;If not negative, divide was good
  508	 0244	 	 	 	RESTORE:
  509	 0244  4E	 	 	        DEC     SI              ;Quotient is too big
  510	 0245  03 C1	 	 	        ADD     AX,CX           ;And remainder too small (negative)
  511	 0247  13 D3	 	 	        ADC     DX,BX           ;So add divisor back in till positive
  512	 0249  73 F9	 	 	        JNC     RESTORE
  513	 024B  C3	 	 	RETJ:   RET
  514	 	 	 	 	
  515	 024C	 	 	 	MAXQUO:
  516	 	 	 	 	;Come here if divide instruction would overflow. This must mean that DX=BX,
  517	 	 	 	 	;i.e., the high half of the divisor and dividend are equal. Assume a result
  518	 	 	 	 	;of (2^16)-1, which will give us a remainder equal to divisor plus (low half
  519	 	 	 	 	;of dividend minus low half of divisor, times 2^16).
  520	 	 	 	 	
  521	 024C  BE FFFF	 	 	        MOV     SI,-1           ;Quotient of (2^16)-1
  522	 024F  2B C1	 	 	        SUB     AX,CX           ;Dividend - divisor (always negative)
  523	 0251  03 D0	 	 	        ADD     DX,AX           ;Add to high half of divisor
  524	 0253  8B C1	 	 	        MOV     AX,CX
  525	 0255  73 ED	 	 	        JNC     RESTORE         ;Carry means it's not negative any more
  526	 0257  C3	 	 	        RET
  527	 	 	 	 	
  528	 0258	 	 	 	CODE    ENDS
  529	 	 	 	 	        END













SMATH - Single precision floating point arithmetic       Macro-86 %1(12)   1:8:12  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0258	WORD  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ALIGNED. . . . . . . . . . . . .	L NEAR 	00B9	CODE
BITSHFT. . . . . . . . . . . . .	L NEAR 	00AB	CODE
BYTSHF . . . . . . . . . . . . .	L NEAR 	007D	CODE
CDIV16 . . . . . . . . . . . . .	L NEAR 	022B	CODE
DIV0 . . . . . . . . . . . . . .	L NEAR 	0228	CODE
DIV16. . . . . . . . . . . . . .	L NEAR 	022F	CODE
DOADD. . . . . . . . . . . . . .	L NEAR 	0026	CODE
GETSIGN. . . . . . . . . . . . .	L NEAR 	00C1	CODE
HIBYT. . . . . . . . . . . . . .	L NEAR 	00F9	CODE
INCEXP . . . . . . . . . . . . .	L NEAR 	0193	CODE
MAXQUO . . . . . . . . . . . . .	L NEAR 	024C	CODE
NORM . . . . . . . . . . . . . .	L NEAR 	00EA	CODE
NORMCHK. . . . . . . . . . . . .	L NEAR 	0184	CODE
NORMLP . . . . . . . . . . . . .	L NEAR 	010E	CODE
NORMSHF. . . . . . . . . . . . .	L NEAR 	010C	CODE
NOSTIK . . . . . . . . . . . . .	L NEAR 	0089	CODE
NSTK . . . . . . . . . . . . . .	L NEAR 	0072	CODE
NSTK1. . . . . . . . . . . . . .	L NEAR 	0224	CODE
NSTK2. . . . . . . . . . . . . .	L NEAR 	01C7	CODE
OVCHK. . . . . . . . . . . . . .	L NEAR 	0142	CODE
OVCHKJ . . . . . . . . . . . . .	L NEAR 	0178	CODE
OVERFLOW . . . . . . . . . . . .	L NEAR 	0144	CODE
PMULS. . . . . . . . . . . . . .	L NEAR 	019A	CODE	Global
RESTORE. . . . . . . . . . . . .	L NEAR 	0244	CODE
RETJ . . . . . . . . . . . . . .	L NEAR 	024B	CODE
ROUND. . . . . . . . . . . . . .	L NEAR 	0118	CODE
ROUNDUP. . . . . . . . . . . . .	L NEAR 	0124	CODE
SAV2 . . . . . . . . . . . . . .	L NEAR 	00A2	CODE
SAVE . . . . . . . . . . . . . .	L NEAR 	0130	CODE
SAVJ . . . . . . . . . . . . . .	L NEAR 	00A8	CODE
SHFLEF . . . . . . . . . . . . .	L NEAR 	0098	CODE
SHFRIG . . . . . . . . . . . . .	L NEAR 	00B3	CODE
SIGNFIDDLE . . . . . . . . . . .	L NEAR 	0052	CODE
SUBMAN . . . . . . . . . . . . .	L NEAR 	00D6	CODE
ZERO . . . . . . . . . . . . . .	L NEAR 	0147	CODE
ZEROJ. . . . . . . . . . . . . .	L NEAR 	0191	CODE
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DIV0. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FADA. . . . . . . . . . . . . .	L NEAR 	0020	CODE	Global
$FADC. . . . . . . . . . . . . .	L NEAR 	0015	CODE	Global
$FADE. . . . . . . . . . . . . .	L NEAR 	001D	CODE	Global


SMATH - Single precision floating point arithmetic       Macro-86 %1(12)   1:8:12  13-Nov-81    Symbols-2



$FADG. . . . . . . . . . . . . .	L NEAR 	001A	CODE	Global
$FDVA. . . . . . . . . . . . . .	L NEAR 	01D8	CODE	Global
$FDVC. . . . . . . . . . . . . .	L NEAR 	01CD	CODE	Global
$FDVE. . . . . . . . . . . . . .	L NEAR 	01D5	CODE	Global
$FDVG. . . . . . . . . . . . . .	L NEAR 	01D2	CODE	Global
$FMUA. . . . . . . . . . . . . .	L NEAR 	0158	CODE	Global
$FMUC. . . . . . . . . . . . . .	L NEAR 	014D	CODE	Global
$FMUE. . . . . . . . . . . . . .	L NEAR 	0155	CODE	Global
$FMUG. . . . . . . . . . . . . .	L NEAR 	0152	CODE	Global
$FSUA. . . . . . . . . . . . . .	L NEAR 	000B	CODE	Global
$FSUC. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$FSUE. . . . . . . . . . . . . .	L NEAR 	0008	CODE	Global
$FSUG. . . . . . . . . . . . . .	L NEAR 	0005	CODE	Global
$GTMP. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$OVFL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SADD. . . . . . . . . . . . . .	L NEAR 	0023	CODE	Global
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SDIV. . . . . . . . . . . . . .	L NEAR 	01DB	CODE	Global
$SMUL. . . . . . . . . . . . . .	L NEAR 	015B	CODE	Global
$SNORM . . . . . . . . . . . . .	L NEAR 	00EA	CODE	Global
$SRND. . . . . . . . . . . . . .	L NEAR 	0118	CODE	Global
$SSUB. . . . . . . . . . . . . .	L NEAR 	000E	CODE	Global

Warning Severe
Errors	Errors 
0	0






























