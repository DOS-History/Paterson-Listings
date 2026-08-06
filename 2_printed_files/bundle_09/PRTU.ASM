PRTU - PRINT USING Driver                                Macro-86 %1(12)   1:7:14  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   PRTU - PRINT USING Driver
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        PUBLIC  $PUFLAG, $DIGCNT
    6	 	 	 	 	
    7	 	 	 	 	        EXTRN   $$SPSV:WORD,VALTYP:BYTE,$$PUFL:BYTE,$$PUEN:WORD
    8	 	 	 	 	
    9	 0000  ???? ????	 	PUDS    DW      ?,?             ;Print Using string descriptor
   10	 0004  ????	 	 	PUSC    DW      ?               ;PRINT USING SCAN COUNT
   11	 0006  ????	 	 	$DIGCNT DW      ?               ;Count of digits before and after d.p.
   12	 0008  ??	 	 	PUVS    DB      ?               ;PRINT USING VALUE SEEN FLAG
   13	 0009	 	 	 	$PUFLAG LABEL   BYTE
   14	 0009  ??	 	 	FLAG    DB      ?               ;Flag byte
   15	 	 	 	 	;Bits of the flag byte are used as follows:
   16	 	 	 	 	;       0       0=Fixed format, 1=Scientific notation
   17	 	 	 	 	;       1       0=Print number, 1=Print string
   18	 	 	 	 	;       2       1=Place sign after number
   19	 	 	 	 	;       3       1=Print "+" for positive numbers
   20	 	 	 	 	;       4       1=Print "$" in front of number
   21	 	 	 	 	;       5       0=Pad with leading spaces; 1=Pad with leading "*"
   22	 	 	 	 	;       6       1=Put commas every three digits
   23	 	 	 	 	;       7       0=Free format output, 1=Print using output
   24	 	 	 	 	
   25	 000A	 	 	 	DATA    ENDS
   26	 	 	 	 	
   27	 	 	 	 	
   28	 	 	 	 	DC      GROUP   DATA
   29	 	 	 	 	
   30	 	 	 	 	
   31	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   32	 	 	 	 	
   33	 	 	 	 	        PUBLIC  $PRU
   34	 	 	 	 	
   35	 	 	 	 	        EXTRN   $$WCH:NEAR,$ERC_FC:NEAR,$ERC_TM:NEAR
   36	 	 	 	 	        EXTRN   $$DITS:NEAR,$SAS:FAR,$SAVREG:NEAR
   37	 	 	 	 	        EXTRN   $PUFOUT:NEAR,$TYPCNT:NEAR,$OUTCNT:NEAR
   38	 	 	 	 	
   39	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   40	 	 	 	 	
   41	 = 0024	 	 	 	CURNCY=         "$"             ;Currency symbol
   42	 = 005C	 	 	 	CSTRNG=         "\"             ;String USING symbol
   43	 	 	 	 	
   44	 = 0000	 	 	 	SD_LEN=         0               ;STRING DESCRIPTOR LENGTH OFFSET
   45	 = 0002	 	 	 	SD_ADR=         2               ;STRING DESCRIPTOR ADDRESS OFFSET
   46	 	 	 	 	
   47	 	 	 	 	
   48	 	 	 	 	;       ENTRY   (HL) = Pointer to using SDESC
   49	 	 	 	 	
   50	 	 	 	 	
   51	 0000	 	 	 	$PRU    PROC    FAR
   52	 0000  89 26 0000 E	 	        MOV     $$SPSV,SP       ;Save SP in case of error in SAS
   53	 0004  52	 	 	        PUSH    DX
   54	 0005  BA 0000 R	 	        MOV     DX,OFFSET DC:PUDS       ;Point to the destination descriptor


PRTU - PRINT USING Driver                                Macro-86 %1(12)   1:7:14  13-Nov-81    Page 1-2



   55	 0008  9A 0000 ---- E	 	        CALL    $SAS            ;** 5.2 **  Copy "using" string
   56	 000D  5A	 	 	        POP     DX
   57	 000E  C6 06 0000 E 01	 	        MOV     $$PUFL,1        ;SET PRINT USING FLAG
   58	 0013  C7 06 0000 E 0022 R	        MOV     $$PUEN,OFFSET $$PREN    ;SET PRINT ITEM ENTRY ADDRESS
   59	 0019  32 C0	 	 	        XOR     AL,AL           ;ZERO VALUE SEEN FLAG
   60	 001B  A2 0008 R	 	        MOV     PUVS,AL
   61	 001E  A2 0009 R	 	        MOV     FLAG,AL         ;SET TO NO TYPE PENDING
   62	 0021  CB	 	 	        RET
   63	 0022	 	 	 	$PRU    ENDP
   64	 	 	 	 	
   65	 	 	 	 	
   66	 	 	 	 	;       Entry point for printing numbers and strings
   67	 	 	 	 	
   68	 0022	 	 	 	$$PREN:
   69	 0022  A0 0009 R	 	        MOV     AL,FLAG         ;TEST IF TYPE PENDING
   70	 0025  0A C0	 	 	        OR      AL,AL
   71	 0027  75 08	 	 	        JNZ     PREN01          ;YES - PROCESS AS NORMAL
   72	 0029  53	 	 	        PUSH    BX              ;Save possible string descriptor
   73	 002A  E8 0072 R	 	        CALL    PUINIT          ;ZERO - SCAN STARTING AT BEGINNING
   74	 002D  5B	 	 	        POP     BX
   75	 002E  A0 0009 R	 	        MOV     AL,FLAG
   76	 0031	 	 	 	PREN01:
   77	 0031  A2 0008 R	 	        MOV     PUVS,AL         ;Must have found a value
   78	 0034  8B 0E 0006 R	 	        MOV     CX,$DIGCNT      ;LOAD [CH,CL]
   79	 0038  A8 02	 	 	        TEST    AL,2            ;Does the field define a string?
   80	 003A  75 10	 	 	        JNZ     PUSTR           ;PRINT STRING
   81	 003C  80 3E 0000 E 03	 	        CMP     VALTYP,3        ;IS IT A STRING?
   82	 0041  74 54	 	 	        JZ      TMER            ;ERROR - TYPE MISMATCH
   83	 0043  E8 0000 E	 	        CALL    $PUFOUT         ;FORMAT NUMBER
   84	 0046  91	 	 	        XCHG    AX,CX           ;Put count in CX
   85	 0047  E8 0000 E	 	        CALL    $OUTCNT
   86	 004A  EB 30	 	 	        JMP     SHORT PUSCAN
   87	 	 	 	 	
   88	 004C	 	 	 	PUSTR:
   89	 004C  80 3E 0000 E 03	 	        CMP     VALTYP,3        ;Type better be string
   90	 0051  75 44	 	 	        JNZ     TMER            ;ERROR - TYPE MISMATCH
   91	 0053  8B D1	 	 	        MOV     DX,CX           ;Put length of print field into DX
   92	 0055  8B 0F	 	 	        MOV     CX,[BX]         ;Get length of string
   93	 0057  2B D1	 	 	        SUB     DX,CX           ;DX = Padding count
   94	 	 	 	 	;Note that if we have a variable length string field, DX will be -1.
   95	 	 	 	 	;The result of the above subtraction will never carry (so we will take the
   96	 	 	 	 	;JAE below), but the number left in DX will always be negative. Thus when
   97	 	 	 	 	;we get to the padding check, no blanks will be added.
   98	 0059  73 02	 	 	        JAE     PRSTR           ;If field is big enough, proceed
   99	 005B  03 CA	 	 	        ADD     CX,DX           ;CX = CX + (DX-CX) = DX
  100	 005D	 	 	 	PRSTR:
  101	 005D  E8 0000 E	 	        CALL    $TYPCNT         ;Output CX bytes of string
  102	 0060  E8 0000 E	 	        CALL    $$DITS          ;DELETE IF TEMPORARY STRING
  103	 0063  8B CA	 	 	        MOV     CX,DX           ;Padding count
  104	 0065  0B C9	 	 	        OR      CX,CX
  105	 0067  7E 13	 	 	        JLE     PUSCAN          ;Any padding needed?
  106	 0069  B0 20	 	 	        MOV     AL," "          ;PAD OUT REMAINDER OF FIELD
  107	 006B	 	 	 	PUPAD:
  108	 006B  E8 0000 E	 	        CALL    $$WCH           ;PRINT SPACE


PRTU - PRINT USING Driver                                Macro-86 %1(12)   1:7:14  13-Nov-81    Page 1-3



  109	 006E  E2 FB	 	 	        LOOP    PUPAD           ;  CONTINUE PADDING
  110	 0070  EB 0A	 	 	        JMP     SHORT PUSCAN
  111	 	 	 	 	
  112	 0072	 	 	 	PUINIT:
  113	 0072  A1 0000 R	 	        MOV     AX,PUDS+SD_LEN  ;Get length of PRINT USING string
  114	 0075  A3 0004 R	 	        MOV     PUSC,AX         ;SAVE SCAN COUNT REMAINING
  115	 0078  0B C0	 	 	        OR      AX,AX           ;Null string?
  116	 007A  74 18	 	 	        JZ      FARG            ;If so, illegal function call
  117	 007C	 	 	 	PUSCAN:
  118	 007C  C6 06 0009 R 00	 	        MOV     FLAG,0
  119	 0081  8B 36 0002 R	 	        MOV     SI,PUDS+SD_ADR  ;Start of string (could change if G.C.!)
  120	 0085  A1 0000 R	 	        MOV     AX,PUDS+SD_LEN
  121	 0088  8B 0E 0004 R	 	        MOV     CX,PUSC         ;Get scan count
  122	 008C  2B C1	 	 	        SUB     AX,CX           ;Offset into string
  123	 008E  03 F0	 	 	        ADD     SI,AX
  124	 0090  E3 1C	 	 	        JCXZ    RET             ;At end of string?
  125	 0092  EB 58	 	 	        JMP     SHORT PRCCHR    ;If not, scan for next value (or EOS)
  126	 	 	 	 	
  127	 0094  E9 0000 E	 	FARG:   JMP     $ERC_FC         ;Illegal function call
  128	 	 	 	 	
  129	 0097  E9 0000 E	 	TMER:   JMP     $ERC_TM         ;Type mismatch
  130	 	 	 	 	
  131	 009A  E8 01BF R	 	REUSIN: CALL    PLSPRT          ;PRINT A "+" IF NECESSARY
  132	 009D  E8 0000 E	 	        CALL    $$WCH
  133	 00A0	 	 	 	REUSN1:
  134	 00A0  89 0E 0004 R	 	        MOV     PUSC,CX         ;Save scan count ( = 0 )
  135	 00A4  88 0E 0009 R	 	        MOV     FLAG,CL         ;SET NO TYPE PENDING
  136	 00A8  3A 0E 0008 R	 	        CMP     CL,PUVS         ;Any values seen in string?
  137	 00AC  74 E6	 	 	        JZ      FARG            ;If not, we'll never get anywhere
  138	 00AE  C3	 	 	RET:    RET
  139	 	 	 	 	
  140	 	 	 	 	; HERE TO HANDLE A LITERAL CHARACTER IN THE USING STRING PRECEDED
  141	 	 	 	 	; BY "_"
  142	 	 	 	 	;
  143	 00AF  E8 01BF R	 	LITCHR: CALL    PLSPRT          ;PRINT PREVIOUS "+" IF ANY
  144	 00B2  AC	 	 	        LODSB                   ;FETCH LITERAL CHARACTER
  145	 00B3  E8 0000 E	 	        CALL    $$WCH           ;OUTPUT LITERAL CHARACTER
  146	 00B6  E2 34	 	 	        LOOP    PRCCHR          ;DECREMENT COUNT FOR ACTUAL CHARACTER
  147	 00B8  EB E6	 	 	        JMP     SHORT REUSN1
  148	 	 	 	 	
  149	 	 	 	 	; HERE TO HANDLE VARIABLE LENGTH STRING FIELD SPECIFIED WITH "&"
  150	 	 	 	 	;
  151	 00BA	 	 	 	VARSTR:
  152	 00BA  BB FFFF	 	 	        MOV     BX,-1           ;SET LENGTH TO MAXIMUM POSSIBLE
  153	 00BD	 	 	 	ISSTRF:
  154	 00BD  49	 	 	        DEC     CX              ;DECREMENT THE "USING" STRING CHARACTER COUNT
  155	 00BE  E8 01BF R	 	        CALL    PLSPRT          ;PRINT A "+" IF ONE CAME BEFORE THE FIELD
  156	 00C1  89 0E 0004 R	 	        MOV     PUSC,CX         ;Save scan count
  157	 00C5  89 1E 0006 R	 	        MOV     $DIGCNT,BX      ;Save field width
  158	 00C9  C6 06 0009 R 02	 	        MOV     FLAG,2          ;Flag string type
  159	 00CE  C3	 	 	        RET
  160	 	 	 	 	
  161	 00CF  8B E9	 	 	BGSTRF: MOV     BP,CX           ;SAVE THE "USING" STRING CHARACTER COUNT
  162	 00D1  8B FE	 	 	        MOV     DI,SI           ;SAVE THE POINTER INTO THE "USING" STRING


PRTU - PRINT USING Driver                                Macro-86 %1(12)   1:7:14  13-Nov-81    Page 1-4



  163	 00D3  BB 0002	 	 	        MOV     BX,2            ;THE \\ STRING FIELD HAS 2 PLUS
  164	 	 	 	 	                                ;NUMBER OF ENCLOSED SPACES WIDTH
  165	 00D6	 	 	 	LPSTRF:
  166	 00D6  AC	 	 	        LODSB                   ;GET THE NEXT CHARACTER
  167	 00D7  3C 5C	 	 	        CMP     AL,CSTRNG       ;THE FIELD TERMINATOR?
  168	 00D9  74 E2	 	 	        JZ      ISSTRF          ;GO EVALUATE A STRING AND PRINT
  169	 00DB  43	 	 	        INC     BX              ;INCREMENT THE FIELD WIDTH
  170	 00DC  3C 20	 	 	        CMP     AL," "          ;A FIELD EXTENDER?
  171	 00DE  E1 F6	 	 	        LOOPZ   LPSTRF          ;KEEP SCANNING FOR THE FIELD TERMINATOR
  172	 	 	 	 	
  173	 	 	 	 	; SINCE  STRING FIELD WASN'T FOUND, THE "USING" STRING
  174	 	 	 	 	; CHARACTER COUNT AND THE POINTER INTO IT'S DATA MUST
  175	 	 	 	 	; BE RESTORED AND THE "\" PRINTED
  176	 	 	 	 	;
  177	 00E0  8B F7	 	 	NOSTRF: MOV     SI,DI           ;RESTORE THE POINTER INTO "USING" STRING'S DATA
  178	 00E2  8B CD	 	 	        MOV     CX,BP
  179	 00E4  B0 5C	 	 	        MOV     AL,CSTRNG       ;RESTORE THE CHARACTER
  180	 	 	 	 	;
  181	 	 	 	 	; HERE TO PRINT THE CHARACTER IN [AL] SINCE IT WASN'T PART OF ANY FIELD
  182	 	 	 	 	;
  183	 00E6  E8 01BF R	 	NEWUCH: CALL    PLSPRT          ;IF A "+" CAME BEFORE THIS CHARACTER
  184	 	 	 	 	                                ;MAKE SURE IT GETS PRINTED
  185	 00E9  E8 0000 E	 	        CALL    $$WCH           ;PRINT THE CHARACTER THAT WASN'T
  186	 	 	 	 	                                ;PART OF A FIELD
  187	 	 	 	 	
  188	 	 	 	 	;Here is the entry point to start scanning for the next value field.
  189	 	 	 	 	;Register usage:
  190	 	 	 	 	;       SI      Points to next byte in PRINT USING string
  191	 	 	 	 	;       CX      Count of characters left in PRINT USING string
  192	 	 	 	 	;       DH      Flag byte used by $PUFOUT (stored in FLAG - see above)
  193	 	 	 	 	;       BH      Number of digits to left of decimal point (numbers only)
  194	 	 	 	 	;       BL      Number of digits to right of decimal point (numbers only)
  195	 	 	 	 	;       BX      Length of string field (strings only)
  196	 	 	 	 	
  197	 00EC  32 C0	 	 	PRCCHR: XOR     AL,AL           ;SET [DH]=0 SO IF WE DISPATCH
  198	 00EE  8A F0	 	 	        MOV     DH,AL           ;DON'T PRINT "+" TWICE
  199	 00F0  E8 01BF R	 	PLSFIN: CALL    PLSPRT          ;ALLOW FOR MULTIPLE PLUSES
  200	 	 	 	 	                                ;IN A ROW
  201	 00F3  8A F0	 	 	        MOV     DH,AL           ;SET "+" FLAG
  202	 00F5  AC	 	 	        LODSB                   ;GET A NEW CHARACTER
  203	 00F6  3C 21	 	 	        CMP     AL,"!"          ;CHECK FOR A SINGLE CHARACTER
  204	 00F8  BB 0001	 	 	        MOV     BX,1            ;Set string length to 1
  205	 00FB  74 C0	 	 	        JZ      ISSTRF          ;STRING FIELD
  206	 00FD  3C 23	 	 	        CMP     AL,"#"          ;CHECK FOR THE START OF A NUMBERIC FIELD
  207	 00FF  74 40	 	 	        JZ      NUMNUM          ;GO SCAN IT
  208	 0101  3C 26	 	 	        CMP     AL,"&"          ;See if variable string field
  209	 0103  74 B5	 	 	        JZ      VARSTR          ;GO PRINT ENTIRE STRING
  210	 0105  49	 	 	        DEC     CX              ;ALL THE OTHER POSSIBILITIES
  211	 	 	 	 	                                ;REQUIRE AT LEAST 2 CHARACTERS
  212	 0106  74 92	 	 	        JZ      REUSIN          ;IF THE VALUE LIST IS NOT EXHAUSTED
  213	 	 	 	 	                                ;GO REUSE "USING" STRING
  214	 0108  3C 2B	 	 	        CMP     AL,"+"          ;A LEADING "+" ?
  215	 010A  B0 08	 	 	        MOV     AL,8            ;SET [DH] WITH THE PLUS-FLAG ON IN
  216	 010C  74 E2	 	 	        JZ      PLSFIN          ;CASE A NUMERIC FIELD STARTS


PRTU - PRINT USING Driver                                Macro-86 %1(12)   1:7:14  13-Nov-81    Page 1-5



  217	 010E  8A 44 FF	 	 	        MOV     AL,[SI-1]       ;GET BACK THE CURRENT CHARACTER
  218	 0111  3C 2E	 	 	        CMP     AL,"."          ;NUMERIC FIELD WITH TRAILING DIGITS
  219	 0113  74 45	 	 	        JZ      DOTNUM          ;IF SO GO SCAN WITH [BH]=
  220	 	 	 	 	                                ;NUMBER OF DIGITS BEFORE THE "."=0
  221	 0115  3C 5F	 	 	        CMP     AL,"_"          ;CHECK FOR LITERAL CHARACTER DECLARATION
  222	 0117  74 96	 	 	        JZ      LITCHR
  223	 0119  3C 5C	 	 	        CMP     AL,CSTRNG       ;CHECK FOR A BIG STRING FIELD STARTER
  224	 011B  74 B2	 	 	        JZ      BGSTRF          ;GO SEE IF IT REALLY IS A STRING FIELD
  225	 011D  3A 04	 	 	        CMP     AL,[SI]         ;SEE IF THE NEXT CHARACTER MATCHES THE
  226	 	 	 	 	                                ;CURRENT ONE
  227	 011F  75 C5	 	 	        JNZ     NEWUCH          ;IF NOT, CAN'T HAVE $$ OR ** SO ALL THE
  228	 	 	 	 	                                ;POSSIBILITIES ARE EXHAUSTED
  229	 0121  3C 24	 	 	        CMP     AL,CURNCY       ;IS IT $$ ?
  230	 0123  74 16	 	 	        JZ      DOLRNM          ;GO SET UP THE FLAG BIT
  231	 0125  3C 2A	 	 	        CMP     AL,"*"          ;IS IT ** ?
  232	 0127  75 BD	 	 	        JNZ     NEWUCH          ;IF NOT, ITS NOT PART
  233	 	 	 	 	                                ;OF A FIELD SINCE ALL THE POSSIBILITIES
  234	 	 	 	 	                                ;HAVE BEEN TRIED
  235	 0129  80 CE 20	 	 	        OR      DH,32           ;Set "*" bit
  236	 012C  46	 	 	        INC     SI
  237	 012D  83 F9 02	 	 	        CMP     CX,2            ;SEE IF THE "USING" STRING IS LONG
  238	 	 	 	 	                                ;ENOUGH FOR THE SPECIAL CASE OF
  239	 0130  72 0D	 	 	        JC      SPCNUM          ; **$
  240	 0132  8A 04	 	 	        MOV     AL,[SI]
  241	 0134  3C 24	 	 	        CMP     AL,CURNCY       ;IS THE NEXT CHARACTER $ ?
  242	 0136  75 07	 	 	        JNZ     SPCNUM          ;IF IT NOT THE SPECIAL CASE, DON'T
  243	 	 	 	 	                                ;SET THE DOLLAR SIGN FLAG
  244	 0138  49	 	 	        DEC     CX              ;DECREMENT THE "USING" STRING CHARACTER COUNT
  245	 	 	 	 	                                ;TO TAKE THE $ INTO CONSIDERATION
  246	 0139  FE C7	 	 	        INC     BH              ;INCREMENT THE FIELD WIDTH FOR THE
  247	 	 	 	 	                                ;FLOATING DOLLAR SIGN
  248	 013B	 	 	 	DOLRNM:
  249	 013B  80 CE 10	 	 	        OR      DH,16           ;SET BIT FOR FLOATING DOLLAR SIGN FLAG
  250	 013E  46	 	 	        INC     SI              ;POINT BEYOND THE SPECIAL CHARACTERS
  251	 013F  FE C7	 	 	SPCNUM: INC     BH              ;SINCE TWO CHARACTERS SPECIFY
  252	 	 	 	 	                                ;THE FIELD SIZE, INITIALIZE [BH]=1
  253	 0141  FE C7	 	 	NUMNUM: INC     BH              ;INCREMENT THE NUMBER OF DIGITS BEFORE
  254	 	 	 	 	                                ;THE DECIMAL POINT
  255	 0143  B3 00	 	 	        MOV     BL,0            ;SET THE NUMBER OF DIGITS AFTER
  256	 	 	 	 	                                ;THE DECIMAL POINT = 0
  257	 0145  49	 	 	        DEC     CX              ;SEE IF THERE ARE MORE CHARACTERS
  258	 0146  74 42	 	 	        JZ      NOTSCI          ;IF NOT, WE ARE DONE SCANNING THIS
  259	 	 	 	 	                                ;NUMERIC FIELD
  260	 0148  AC	 	 	        LODSB                   ;GET THE NEW CHARACTER
  261	 0149  3C 2E	 	 	        CMP     AL,"."          ;DO WE HAVE TRAILING DIGITS?
  262	 014B  74 18	 	 	        JZ      AFTDOT          ;IF SO, USE SPECIAL SCAN LOOP
  263	 014D  3C 23	 	 	        CMP     AL,"#"          ;MORE LEADING DIGITS ?
  264	 014F  74 F0	 	 	        JZ      NUMNUM          ;INCREMENT THE COUNT AND KEEP SCANNING
  265	 0151  3C 2C	 	 	        CMP     AL,","          ;DOES HE WANT A COMMA
  266	 	 	 	 	                                ;EVERY THREE DIGITS?
  267	 0153  75 1A	 	 	        JNZ     FINNUM          ;NO MORE LEADING DIGITS, CHECK FOR ^^^
  268	 0155  80 CE 40	 	 	        OR      DH,64           ;TURN ON THE COMMA BIT
  269	 0158  EB E7	 	 	        JMP     NUMNUM          ;GO SCAN SOME MORE
  270	 	 	 	 	;


PRTU - PRINT USING Driver                                Macro-86 %1(12)   1:7:14  13-Nov-81    Page 1-6



  271	 	 	 	 	; HERE WHEN A "." IS SEEN IN THE "USING" STRING
  272	 	 	 	 	; IT STARTS A NUMERIC FIELD IF AND ONLY IF
  273	 	 	 	 	; IT IS FOLLOWED BY A "#"
  274	 	 	 	 	;
  275	 015A  8A 04	 	 	DOTNUM: MOV     AL,[SI]         ;GET THE CHARACTER THAT FOLLOWS
  276	 015C  3C 23	 	 	        CMP     AL,"#"          ;IS THIS A NUMERIC FIELD?
  277	 015E  B0 2E	 	 	        MOV     AL,"."          ;IF NOT, GO BACK AND PRINT "."
  278	 0160  75 84	 	 	        JNZ     NEWUCH
  279	 0162  B3 01	 	 	        MOV     BL,1            ;INITIALIZE THE NUMBER OF
  280	 	 	 	 	                                ;DIGITS AFTER THE DECIMAL POINT
  281	 0164  46	 	 	        INC     SI
  282	 0165  FE C3	 	 	AFTDOT: INC     BL              ;INCREMENT THE NUMBER OF DIGITS
  283	 	 	 	 	                                ;AFTER THE DECIMAL POINT
  284	 0167  49	 	 	        DEC     CX              ;SEE IF THE "USING" STRING HAS MORE
  285	 0168  74 20	 	 	        JZ      NOTSCI          ;CHARACTERS, AND IF NOT, STOP SCANNING
  286	 016A  AC	 	 	        LODSB                   ;GET THE NEXT CHARACTER
  287	 016B  3C 23	 	 	        CMP     AL,"#"          ;MORE DIGITS AFTER THE DECIMAL POINT?
  288	 016D  74 F6	 	 	        JZ      AFTDOT          ;IF SO, INCREMENT THE COUNT AND KEEP
  289	 	 	 	 	                                ;SCANNING
  290	 	 	 	 	;
  291	 	 	 	 	; CHECK FOR THE "^^^^" THAT INDICATES SCIENTIFIC NOTATION
  292	 	 	 	 	;
  293	 016F	 	 	 	FINNUM:
  294	 016F  4E	 	 	        DEC     SI              ;Point back to current character
  295	 0170  81 3C 5E5E	 	        CMP     WORD PTR [SI],"^^"      ;Two "^"s in a row?
  296	 0174  75 14	 	 	        JNZ     NOTSCI
  297	 0176  81 7C 02 5E5E	 	        CMP     WORD PTR [SI+2],"^^"    ;Four "^"s in a row?
  298	 017B  75 0D	 	 	        JNZ     NOTSCI
  299	 017D  83 F9 04	 	 	        CMP     CX,4          	;WERE THERE ENOUGH CHARACTERS FOR "^^^^"?
  300	 0180  72 48	 	 	        JC      RT
  301	 0182  83 E9 04	 	 	        SUB     CX,4
  302	 0185  83 C6 04	 	 	        ADD     SI,4
  303	 0188  FE C6	 	 	        INC     DH              ;TURN ON THE SCIENTIFIC NOTATION FLAG
  304	 018A	 	 	 	NOTSCI:
  305	 018A  FE C7	 	 	        INC     BH              ;INCLUDE LEADING "+" IN NUMBER OF DIGITS
  306	 018C  F6 C6 08	 	 	        TEST    DH,8            ;DON'T CHECK FOR A TRAILING SIGN
  307	 018F  75 14	 	 	        JNZ     ENDNUM          ;ALL DONE WITH THE FIELD IF SO
  308	 	 	 	 	                                ;IF THERE IS A LEADING PLUS
  309	 0191  FE CF	 	 	        DEC     BH              ;NO LEADING PLUS SO DON'T INCREMENT THE
  310	 	 	 	 	                                ;NUMBER OF DIGITS BEFORE THE DECIMAL POINT
  311	 0193  E3 10	 	 	        JCXZ    ENDNUM          ;SEE IF THERE ARE MORE CHARACTERS
  312	 0195  AC	 	 	        LODSB                   ;GET THE CURRENT CHARACTER
  313	 0196  3C 2D	 	 	        CMP     AL,"-"          ;TRAIL MINUS?
  314	 0198  74 07	 	 	        JZ      SGNTRL          ;SET THE TRAILING SIGN FLAG
  315	 019A  3C 2D	 	 	        CMP     AL,"-"          ;A TRAILING PLUS?
  316	 019C  75 07	 	 	        JNZ     ENDNUM          ;IF NOT, WE ARE DONE SCANNING
  317	 019E  80 CE 08	 	 	        OR      DH,8            ;TURN ON THE POSITIVE="+" FLAG
  318	 01A1  80 CE 04	 	 	SGNTRL: OR      DH,4            ;TURN ON THE TRAILING SIGN FLAG
  319	 01A4  49	 	 	        DEC     CX              ;DECREMENT THE "USING" STRING CHARACTER
  320	 	 	 	 	                                ;COUNT TO ACCOUNT FOR THE TRAILING SIGN
  321	 01A5	 	 	 	ENDNUM:
  322	 01A5  89 0E 0004 R	 	        MOV     PUSC,CX         ;Save scan count
  323	 01A9  89 1E 0006 R	 	        MOV     $DIGCNT,BX
  324	 01AD  02 FB	 	 	        ADD     BH,BL           ;Digit count must not exceed 24


PRTU - PRINT USING Driver                                Macro-86 %1(12)   1:7:14  13-Nov-81    Page 1-7



  325	 01AF  80 FF 19	 	 	        CMP     BH,25
  326	 01B2  73 08	 	 	        JNC     ARGERR          ;IF SO, "ILLEGAL FUNCTION CALL"
  327	 01B4  80 CE 80	 	 	        OR      DH,80H          ;TURN ON THE "USING" BIT
  328	 01B7  88 36 0009 R	 	        MOV     FLAG,DH
  329	 01BB  C3	 	 	        RET                     ;GET OUT
  330	 	 	 	 	
  331	 01BC  E9 0000 E	 	ARGERR: JMP     $ERC_FC
  332	 	 	 	 	
  333	 	 	 	 	; WHEN A "+" IS DETECTED IN THE "USING" STRING
  334	 	 	 	 	; IF A NUMERIC FIELD FOLLOWS A BIT IN [DH] SHOULD
  335	 	 	 	 	; BE SET, OTHERWISE "+" SHOULD BE PRINTED.
  336	 	 	 	 	; SINCE DECIDING WHETHER A NUMERIC FIELD FOLLOWS IS VERY
  337	 	 	 	 	; DIFFICULT, THE BIT IS ALWAYS SET IN [DH].
  338	 	 	 	 	; AT THE POINT IT IS DECIDED A CHARACTER IS NOT PART
  339	 	 	 	 	; OF A NUMERIC FIELD, THIS ROUTINE IS CALLED TO SEE
  340	 	 	 	 	; IF THE BIT IN [DH] IS SET, WHICH MEANS
  341	 	 	 	 	; A PLUS PRECEDED THE CHARACTER AND SHOULD BE
  342	 	 	 	 	; PRINTED.
  343	 	 	 	 	;
  344	 01BF	 	 	 	PLSPRT:
  345	 01BF  0A F6	 	 	        OR      DH,DH           ;CHECK THE PLUS BIT
  346	 01C1  74 07	 	 	        JZ      RT
  347	 01C3  50	 	 	        PUSH    AX              ;SAVE THE CURRENT CHARACTER
  348	 01C4  B0 2B	 	 	        MOV     AL,"+"          ;SETUP TO PRINT THE PLUS
  349	 01C6  E8 0000 E	 	        CALL    $$WCH           ;PRINT IT IF THE BIT WAS SET
  350	 01C9  58	 	 	        POP     AX              ;GET BACK THE CURRENT CHARACTER
  351	 01CA  C3	 	 	RT:     RET
  352	 	 	 	 	
  353	 01CB	 	 	 	CODE    ENDS
  354	 	 	 	 	        END


























PRTU - PRINT USING Driver                                Macro-86 %1(12)   1:7:14  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	01CB	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	000A	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

AFTDOT . . . . . . . . . . . . .	L NEAR 	0165	CODE
ARGERR . . . . . . . . . . . . .	L NEAR 	01BC	CODE
BGSTRF . . . . . . . . . . . . .	L NEAR 	00CF	CODE
CSTRNG . . . . . . . . . . . . .	Number	005C	
CURNCY . . . . . . . . . . . . .	Number	0024	
DOLRNM . . . . . . . . . . . . .	L NEAR 	013B	CODE
DOTNUM . . . . . . . . . . . . .	L NEAR 	015A	CODE
ENDNUM . . . . . . . . . . . . .	L NEAR 	01A5	CODE
FARG . . . . . . . . . . . . . .	L NEAR 	0094	CODE
FINNUM . . . . . . . . . . . . .	L NEAR 	016F	CODE
FLAG . . . . . . . . . . . . . .	L BYTE 	0009	DATA
ISSTRF . . . . . . . . . . . . .	L NEAR 	00BD	CODE
LITCHR . . . . . . . . . . . . .	L NEAR 	00AF	CODE
LPSTRF . . . . . . . . . . . . .	L NEAR 	00D6	CODE
NEWUCH . . . . . . . . . . . . .	L NEAR 	00E6	CODE
NOSTRF . . . . . . . . . . . . .	L NEAR 	00E0	CODE
NOTSCI . . . . . . . . . . . . .	L NEAR 	018A	CODE
NUMNUM . . . . . . . . . . . . .	L NEAR 	0141	CODE
PLSFIN . . . . . . . . . . . . .	L NEAR 	00F0	CODE
PLSPRT . . . . . . . . . . . . .	L NEAR 	01BF	CODE
PRCCHR . . . . . . . . . . . . .	L NEAR 	00EC	CODE
PREN01 . . . . . . . . . . . . .	L NEAR 	0031	CODE
PRSTR. . . . . . . . . . . . . .	L NEAR 	005D	CODE
PUDS . . . . . . . . . . . . . .	L WORD 	0000	DATA
PUINIT . . . . . . . . . . . . .	L NEAR 	0072	CODE
PUPAD. . . . . . . . . . . . . .	L NEAR 	006B	CODE
PUSC . . . . . . . . . . . . . .	L WORD 	0004	DATA
PUSCAN . . . . . . . . . . . . .	L NEAR 	007C	CODE
PUSTR. . . . . . . . . . . . . .	L NEAR 	004C	CODE
PUVS . . . . . . . . . . . . . .	L BYTE 	0008	DATA
RET. . . . . . . . . . . . . . .	L NEAR 	00AE	CODE
REUSIN . . . . . . . . . . . . .	L NEAR 	009A	CODE
REUSN1 . . . . . . . . . . . . .	L NEAR 	00A0	CODE
RT . . . . . . . . . . . . . . .	L NEAR 	01CA	CODE
SD_ADR . . . . . . . . . . . . .	Number	0002	
SD_LEN . . . . . . . . . . . . .	Number	0000	
SGNTRL . . . . . . . . . . . . .	L NEAR 	01A1	CODE
SPCNUM . . . . . . . . . . . . .	L NEAR 	013F	CODE
TMER . . . . . . . . . . . . . .	L NEAR 	0097	CODE
VALTYP . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
VARSTR . . . . . . . . . . . . .	L NEAR 	00BA	CODE
$$DITS . . . . . . . . . . . . .	L NEAR 	0000	CODE	External


PRTU - PRINT USING Driver                                Macro-86 %1(12)   1:7:14  13-Nov-81    Symbols-2



$$PREN . . . . . . . . . . . . .	L NEAR 	0022	CODE
$$PUEN . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$PUFL . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$WCH. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DIGCNT. . . . . . . . . . . . .	L WORD 	0006	DATA	Global
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_TM. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$OUTCNT. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$PRU . . . . . . . . . . . . . .	F PROC	0000	CODE	Global	Length =0022
$PUFLAG. . . . . . . . . . . . .	L BYTE 	0009	DATA	Global
$PUFOUT. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SAS . . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TYPCNT. . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0





































