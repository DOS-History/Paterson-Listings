STRFCN - String function package                                 Macro-86 %1(12)   1:8:33  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   STRFCN - String function package
    2	 	 	 	 	
    3	 	 	 	 	
    4	                             C	        INCLUDE SYSTEM.INC
    5	                             C	;       Operating System Selection
    6	                             C	
    7	 = 0000                      C	_IBM_=                  0
    8	                             C	
    9	 = 0001                      C	_MSDOS_=                1
   10	 = 0000                      C	_CPM_=                  0
   11	                             C	
   12	                             C	;       Overrides
   13	                             C	
   14	 = 0001                      C	_MSDOS_=                _MSDOS_ or _IBM_
   15	                             C	
   16	                             C	if1
   17	                             C	if      _CPM_
   18	                             C	        %OUT    !   CP/M-86 Version
   19	                             C	endif
   20	                             C	if      _MSDOS_
   21	                             C	        %OUT    !   MSDOS Version
   22	                             C	endif
   23	                             C	if      _IBM_
   24	                             C	        %OUT    !     IBM Personal Computer
   25	                             C	endif
   26	                             C	
   27	                             C	if      _MSDOS_+_CPM_ ne 1
   28	                             C	        %OUT    #####################  Error - Bad Operating System Selection
   29	                             C	
   30	                             C	        error
   31	                             C	endif
   32	                             C	endif
   33	                             C	
   34	 	 	 	 	
   35	 	 	 	 	
   36	 	 	 	 	; Includes code for LEN, ASC, CHR, FRE, INKEY, INSTR,
   37	 	 	 	 	; LEFT, RIGHT, MID, SPACE, STRING
   38	 	 	 	 	
   39	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
   40	 	 	 	 	
   41	 	 	 	 	        EXTRN   $$SPSV:WORD, $$SFPT:WORD, NULDES:WORD
   42	 	 	 	 	
   43	 0000	 	 	 	DATA    ENDS
   44	 	 	 	 	
   45	 	 	 	 	DC      GROUP   DATA
   46	 	 	 	 	
   47	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   48	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   49	 	 	 	 	
   50	 	 	 	 	        PUBLIC  $LENA,$LENB,$CHR,$FREA,$FR$A,$IST,$IS2,$LEF,$RIG,$MID,$MIDSTR
   51	 	 	 	 	        PUBLIC  $SP$,$ST$,$S2$,$INK
   52	 	 	 	 	
   53	 	 	 	 	        EXTRN   $$DITS:NEAR, $$ATS:NEAR, $$MAG:NEAR, $SNORM:NEAR
   54	 	 	 	 	        EXTRN   $$CTSD:NEAR, $TTYST:NEAR, $TTYIN:NEAR


STRFCN - String function package                                 Macro-86 %1(12)   1:8:33  13-Nov-81    Page 1-2



   55	 	 	 	 	        EXTRN   $ERR_FC:NEAR, $ERC_FC:NEAR
   56	 	 	 	 	
   57	 0000	 	 	 	STRFCN  PROC    FAR             ;Set up long returns as the default
   58	 	 	 	 	
   59	 	 	 	 	
   60	 	 	 	 	;***  $LENA and $LENB - Compute LEN and ASC functions
   61	 	 	 	 	;
   62	 	 	 	 	; Inputs:
   63	 	 	 	 	;       BX = Address of string descriptor
   64	 	 	 	 	; Outputs:
   65	 	 	 	 	;       BX = Value of LEN or ASC function
   66	 	 	 	 	; Registers:
   67	 	 	 	 	;       Only BX and F affected.
   68	 	 	 	 	
   69	 0000	 	 	 	$LENA:
   70	 0000  FF 37	 	 	        PUSH    [BX]            ;Put length on stack
   71	 0002  E8 0000 E	 	        CALL    $$DITS          ;Delete if temp string
   72	 0005  5B	 	 	        POP     BX
   73	 0006  CB	 	 	        RET
   74	 	 	 	 	
   75	 0007	 	 	 	$LENB:
   76	 0007  83 3F 00	 	 	        CMP     WORD PTR[BX],0  ;See if nul string
   77	 000A  74 60	 	 	        JZ      TLRG            ;If so, error
   78	 000C  56	 	 	        PUSH    SI
   79	 000D  8B 77 02	 	 	        MOV     SI,[BX+2]       ;Get pointer to string data
   80	 0010  8B 34	 	 	        MOV     SI,[SI]         ;Get first char of string
   81	 0012  E8 0000 E	 	        CALL    $$DITS          ;Delete if temp string
   82	 0015  8B DE	 	 	        MOV     BX,SI
   83	 0017  B7 00	 	 	        MOV     BH,0            ;Char in BL
   84	 0019  5E	 	 	        POP     SI
   85	 001A  CB	 	 	        RET
   86	 	 	 	 	
   87	 	 	 	 	
   88	 	 	 	 	;***  $INK - INKEY$ function
   89	 	 	 	 	;
   90	 	 	 	 	; Inputs:
   91	 	 	 	 	;       None.
   92	 	 	 	 	; Function:
   93	 	 	 	 	;       If a character is waiting at the console, return it in a 1-char temp
   94	 	 	 	 	;       string. Otherwise, return null string descriptor.
   95	 	 	 	 	; Outputs:
   96	 	 	 	 	;       BX = Address of string descriptor
   97	 	 	 	 	; Registers:
   98	 	 	 	 	;       Only BX and F affected.
   99	 	 	 	 	
  100	 001B	 	 	 	$INK:
  101	 001B  50	 	 	        PUSH    AX
  102	 001C  E8 0000 E	 	        CALL    $TTYST          ;See if anything out there
  103	 001F  74 20	 	 	        JZ      RETNUL
  104	 0021  E8 0000 E	 	        CALL    $TTYIN          ;Get the char
  105	 	 	 	 	if      _IBM_
  106	 	 	 	 	        JNZ     inknrm          ;Normal - return 1 character
  107	 	 	 	 	
  108	 	 	 	 	        XCHG    AX,BX           ;BX = (scan code,0)


STRFCN - String function package                                 Macro-86 %1(12)   1:8:33  13-Nov-81    Page 1-3



  109	 	 	 	 	        POP     AX              ;Restore AX
  110	 	 	 	 	        MOV     [$$SPSV],SP     ;Save stack
  111	 	 	 	 	        PUSH    DX
  112	 	 	 	 	        PUSH    BX              ;Save 2 characters
  113	 	 	 	 	        MOV     BX,2            ;Want a 2 character string
  114	 	 	 	 	        JMP     SHORT chrsub    ;Go to common code
  115	 	 	 	 	
  116	 	 	 	 	inknrm:
  117	 	 	 	 	endif
  118	 0024  8A D8	 	 	        MOV     BL,AL
  119	 0026  B7 00	 	 	        MOV     BH,0            ;All set up for CHR$ function
  120	 0028  58	 	 	        POP     AX
  121	 	 	 	 	
  122	 	 	 	 	;***  $CHR - CHR$ function
  123	 	 	 	 	;
  124	 	 	 	 	; Inputs:
  125	 	 	 	 	;       BX = Value, which will be checked to be sure it's valid ASCII (<256)
  126	 	 	 	 	; Function:
  127	 	 	 	 	;       Create a temp string 1 char. long with the given value.
  128	 	 	 	 	; Outputs:
  129	 	 	 	 	;       BX = Address of string descriptor
  130	 	 	 	 	; Registers:
  131	 	 	 	 	;       Only BX and F affected.
  132	 	 	 	 	
  133	 0029	 	 	 	$CHR:
  134	 0029  89 26 0000 E	 	        MOV     [$$SPSV],SP     ;Record stack in case of error in $$ATS
  135	 002D  0A FF	 	 	        OR      BH,BH           ;See if value OK (<256)
  136	 002F  75 3B	 	 	        JNZ     TLRG            ;If not, argument error
  137	 0031  52	 	 	        PUSH    DX
  138	 0032  53	 	 	        PUSH    BX
  139	 0033  BB 0001	 	 	        MOV     BX,1
  140	 	 	 	 	
  141	 0036  E8 0000 E	 	chrsub: CALL    $$ATS           ;Allocate a one-byte string
  142	 0039  87 DA	 	 	        XCHG    BX,DX           ;Get pointer to data in BX
  143	 003B  8F 07	 	 	        POP     [BX]            ;Put character in string
  144	 003D  8B DA	 	 	        MOV     BX,DX           ;Get descriptor address in BX
  145	 003F  5A	 	 	        POP     DX
  146	 0040  CB	 	 	        RET
  147	 	 	 	 	
  148	 0041	 	 	 	RETNUL:
  149	 0041  58	 	 	        POP     AX
  150	 0042  BB 0000 E	 	        MOV     BX,OFFSET DC:NULDES
  151	 0045  CB	 	 	        RET
  152	 	 	 	 	
  153	 	 	 	 	
  154	 	 	 	 	;***  $FREA and $FR$A - FREE function wtih numeric or string parameters
  155	 	 	 	 	;
  156	 	 	 	 	; Inputs:
  157	 	 	 	 	;       None.
  158	 	 	 	 	; Function:
  159	 	 	 	 	;       $FREA returns the size of the next free block. $FR$A performs a
  160	 	 	 	 	;       major garbage collection and returns the total free string space.
  161	 	 	 	 	; Outputs:
  162	 	 	 	 	;       $FAC has size of free space, single precision.


STRFCN - String function package                                 Macro-86 %1(12)   1:8:33  13-Nov-81    Page 1-4



  163	 	 	 	 	; Registers:
  164	 	 	 	 	;       Only F and $FAC affected.
  165	 	 	 	 	
  166	 0046	 	 	 	$FR$A:
  167	 0046  E8 0000 E	 	        CALL    $$MAG           ;Perform major garbage collection
  168	 0049	 	 	 	$FREA:
  169	 0049  53	 	 	        PUSH    BX
  170	 004A  52	 	 	        PUSH    DX
  171	 004B  50	 	 	        PUSH    AX
  172	 004C  8B 1E 0000 E	 	        MOV     BX,[$$SFPT]     ;Get pointer to free space header
  173	 0050  8B 17	 	 	        MOV     DX,[BX]         ;Get header word
  174	 0052  83 FA FF	 	 	        CMP     DX,-1           ;Check for end of string space
  175	 0055  74 05	 	 	        JZ      NOFREE
  176	 0057  F6 C2 01	 	 	        TEST    DL,1            ;Check if free
  177	 005A  75 03	 	 	        JNZ     TELFRE
  178	 005C	 	 	 	NOFREE:
  179	 005C  BA 0001	 	 	        MOV     DX,1            ;Free chunk of zero length
  180	 005F	 	 	 	TELFRE:
  181	 005F  4A	 	 	        DEC     DX              ;Reset LSB
  182	 0060  33 DB	 	 	        XOR     BX,BX
  183	 0062  B8 A000	 	 	        MOV     AX,0A000H       ;Positive sign, true exponent = 32
  184	 0065  E8 0000 E	 	        CALL    $SNORM
  185	 0068  58	 	 	        POP     AX
  186	 0069  5A	 	 	        POP     DX
  187	 006A  5B	 	 	        POP     BX
  188	 006B  CB	 	 	        RET
  189	 	 	 	 	
  190	 	 	 	 	
  191	 006C  E9 0000 E	 	TLRG:   JMP     $ERR_FC         ;Report illegal function call
  192	 	 	 	 	
  193	 	 	 	 	
  194	 	 	 	 	;***  $IST - INSTR function for three arguments
  195	 	 	 	 	;
  196	 	 	 	 	; Inputs:
  197	 	 	 	 	;       BX = Starting position in A$ of search (I)
  198	 	 	 	 	;       DX = Address of descriptor of string to be searched (A$)
  199	 	 	 	 	;       CX = Address of search string descriptor (B$)
  200	 	 	 	 	; Function:
  201	 	 	 	 	;       Perform INSTR(I,A$,B$).
  202	 	 	 	 	; Outputs:
  203	 	 	 	 	;       BX = Position of B$ in A$; zero if not found.
  204	 	 	 	 	; Registers:
  205	 	 	 	 	;       Only BX and F affected.
  206	 	 	 	 	
  207	 006F	 	 	 	$IST:
  208	 006F  0B DB	 	 	        OR      BX,BX
  209	 0071  7E F9	 	 	        JLE     TLRG            ;Arg error if I<=0
  210	 0073  50	 	 	        PUSH    AX
  211	 0074  51	 	 	        PUSH    CX
  212	 0075  52	 	 	        PUSH    DX
  213	 0076  56	 	 	        PUSH    SI
  214	 0077  57	 	 	        PUSH    DI
  215	 0078  8B FA	 	 	        MOV     DI,DX           ;Get A$ descriptor where we can address with it
  216	 007A  8B F1	 	 	        MOV     SI,CX           ;Get B$ descriptor where we can address with it


STRFCN - String function package                                 Macro-86 %1(12)   1:8:33  13-Nov-81    Page 1-5



  217	 007C  AD	 	 	        LODSW                   ;Length of B$
  218	 007D  48	 	 	        DEC     AX
  219	 007E  8B D0	 	 	        MOV     DX,AX           ;Length of B$-1 in DX
  220	 0080  8B 34	 	 	        MOV     SI,[SI]         ;Address of B$ data
  221	 0082  8B 0D	 	 	        MOV     CX,[DI]         ;Length of A$
  222	 0084  8B 7D 02	 	 	        MOV     DI,[DI+2]       ;Address of A$ data
  223	 0087  4B	 	 	        DEC     BX              ;Starting offset in A$
  224	 0088  03 FB	 	 	        ADD     DI,BX           ;Add in starting offset
  225	 008A  03 C3	 	 	        ADD     AX,BX           ;Starting offset + length of search string - 1
  226	 008C  8B D9	 	 	        MOV     BX,CX           ;Remember how long A$ is
  227	 008E  2B C8	 	 	        SUB     CX,AX           ;Reduce search length
  228	 0090  76 27	 	 	        JBE     NOTFND          ;If search string won't fit, say not found
  229	 0092  AC	 	 	        LODSB                   ;Get first character of search string
  230	 	 	 	 	
  231	 	 	 	 	; Top of search loop. The following conditions exist here:
  232	 	 	 	 	;       AL = First character of search string (B$).
  233	 	 	 	 	;       BX = True length of string being searched (A$).
  234	 	 	 	 	;       CX = Amount of A$ left for first-character scan.
  235	 	 	 	 	;       DX = Length of B$-1, used for string compares.
  236	 	 	 	 	;       SI = Address of B$+1, used for string compares.
  237	 	 	 	 	;       DI = Current position to scan in A$.
  238	 	 	 	 	
  239	 0093	 	 	 	SEARCH:
  240	 0093  E3 24	 	 	        JCXZ    NOTFND          ;If nothing left in A$, not found
  241	 0095  F2/ AE	 	 	        REPNE   SCASB           ;Scan for first letter
  242	 0097  75 20	 	 	        JNZ     NOTFND          ;Was first letter found?
  243	 	 	 	 	
  244	 	 	 	 	;Found a match in first letter. Do string compare on remaining letters
  245	 	 	 	 	
  246	 0099  51	 	 	        PUSH    CX              ;Save condition should compare be unsuccessful
  247	 009A  56	 	 	        PUSH    SI              ;  and we need to continue first-character
  248	 009B  57	 	 	        PUSH    DI              ;  search.
  249	 009C  8B CA	 	 	        MOV     CX,DX           ;Get length of B$-1 for string compare
  250	 009E  F3/ A6	 	 	        REPE    CMPSB
  251	 00A0  5F	 	 	        POP     DI
  252	 00A1  5E	 	 	        POP     SI
  253	 00A2  59	 	 	        POP     CX
  254	 00A3  75 EE	 	 	        JNZ     SEARCH          ;If it didn't match, just continue searching
  255	 00A5  2B D9	 	 	        SUB     BX,CX           ;Compute position of match from start of string
  256	 00A7	 	 	 	EXITFND:
  257	 00A7  5F	 	 	        POP     DI
  258	 00A8  5E	 	 	        POP     SI
  259	 00A9  59	 	 	        POP     CX              ;Pop these two in reverse order--they get
  260	 00AA  5A	 	 	        POP     DX              ;  interchanged below
  261	 00AB  58	 	 	        POP     AX
  262	 00AC  87 DA	 	 	        XCHG    BX,DX
  263	 00AE  E8 0000 E	 	        CALL    $$DITS          ;Get rid of temporary strings
  264	 00B1  87 D9	 	 	        XCHG    BX,CX
  265	 00B3  E8 0000 E	 	        CALL    $$DITS
  266	 00B6  87 DA	 	 	        XCHG    BX,DX           ;Get result back in BX
  267	 00B8  CB	 	 	        RET
  268	 	 	 	 	
  269	 00B9	 	 	 	NOTFND:
  270	 00B9  33 DB	 	 	        XOR     BX,BX


STRFCN - String function package                                 Macro-86 %1(12)   1:8:33  13-Nov-81    Page 1-6



  271	 00BB  EB EA	 	 	        JMP     EXITFND
  272	 	 	 	 	
  273	 	 	 	 	
  274	 	 	 	 	;***  $IS2 - INSTR function with 2 arguments
  275	 	 	 	 	;
  276	 	 	 	 	; Inputs:
  277	 	 	 	 	;       BX = Address of A$ descriptor
  278	 	 	 	 	;       DX = Address of B$ descriptor
  279	 	 	 	 	; Function:
  280	 	 	 	 	;       Perform INSTR(A$,B$).
  281	 	 	 	 	; Outputs:
  282	 	 	 	 	;       BX = Position of B$ within A$.
  283	 	 	 	 	; Registers:
  284	 	 	 	 	;       Only BX and F affected.
  285	 	 	 	 	
  286	 00BD	 	 	 	$IS2:
  287	 00BD  51	 	 	        PUSH    CX
  288	 00BE  8B CA	 	 	        MOV     CX,DX           ;Shuffle registers for $IST
  289	 00C0  8B D3	 	 	        MOV     DX,BX
  290	 00C2  BB 0001	 	 	        MOV     BX,1            ;Start with position 1
  291	 00C5  9A 006F ---- R	 	        CALL    FAR PTR $IST
  292	 00CA  8B D1	 	 	        MOV     DX,CX
  293	 00CC  59	 	 	        POP     CX
  294	 00CD  CB	 	 	        RET
  295	 	 	 	 	
  296	 	 	 	 	
  297	 	 	 	 	;***  $LEF and $RIG - Compute LEFT$ and RIGHT$ functions
  298	 	 	 	 	;
  299	 	 	 	 	; Inputs:
  300	 	 	 	 	;       BX = Address of string descriptor
  301	 	 	 	 	;       DX = Length of string wanted
  302	 	 	 	 	; Function:
  303	 	 	 	 	;       Return a string made up of the leftmost ($LEF) or rightmost ($RIG)
  304	 	 	 	 	;       characters of the source string. If the requested length is less than
  305	 	 	 	 	;       zero, then give error; if greater than the length of the source string,
  306	 	 	 	 	;       the source string itself is returned; otherwise, a temporary string
  307	 	 	 	 	;       is created.
  308	 	 	 	 	; Outputs:
  309	 	 	 	 	;       BX = Address of result string descriptor
  310	 	 	 	 	; Registers:
  311	 	 	 	 	;       Only BX and F affected.
  312	 	 	 	 	
  313	 00CE	 	 	 	$LEF:
  314	 00CE  89 26 0000 E	 	        MOV     [$$SPSV],SP
  315	 00D2  51	 	 	        PUSH    CX
  316	 00D3  33 C9	 	 	        XOR     CX,CX           ;Start at left end
  317	 00D5  E8 0164 R	 	        CALL    LEFRIG
  318	 00D8  59	 	 	        POP     CX
  319	 00D9  CB	 	 	        RET
  320	 	 	 	 	
  321	 00DA	 	 	 	$RIG:
  322	 00DA  89 26 0000 E	 	        MOV     [$$SPSV],SP
  323	 00DE  51	 	 	        PUSH    CX
  324	 00DF  8B 0F	 	 	        MOV     CX,[BX]         ;Get length


STRFCN - String function package                                 Macro-86 %1(12)   1:8:33  13-Nov-81    Page 1-7



  325	 00E1  2B CA	 	 	        SUB     CX,DX           ;Starting point (from left)
  326	 00E3  E8 0164 R	 	        CALL    LEFRIG
  327	 00E6  59	 	 	        POP     CX
  328	 00E7  CB	 	 	        RET
  329	 	 	 	 	
  330	 	 	 	 	
  331	 	 	 	 	
  332	 	 	 	 	;***  $MID - Compute MID$ function
  333	 	 	 	 	;
  334	 	 	 	 	; Inputs:
  335	 	 	 	 	;       BX = Address of string descriptor
  336	 	 	 	 	;       DX = Starting offset in string (1 is first)
  337	 	 	 	 	;       CX = Length of string desired
  338	 	 	 	 	; Function:
  339	 	 	 	 	;       If (DX < 1) or (CX < 0) then give error; if (DX = 1) and (CX >= length
  340	 	 	 	 	;       of source string) then return source string; otherwise create a temp
  341	 	 	 	 	;       string of length CX with the specified portion of the source string.
  342	 	 	 	 	; Outputs:
  343	 	 	 	 	;       BX = Address of result string descriptor
  344	 	 	 	 	; Registers:
  345	 	 	 	 	;       Only BX and F affected.
  346	 	 	 	 	
  347	 00E8	 	 	 	$MID:
  348	 00E8  89 26 0000 E	 	        MOV     [$$SPSV],SP
  349	 00EC	 	 	 	$MIDSTR:                        ;Callable from run-time
  350	 00EC  4A	 	 	        DEC     DX              ;Offset should start at zero, not 1
  351	 00ED  87 D1	 	 	        XCHG    DX,CX           ;Set up for future call
  352	 00EF  7C 70	 	 	        JL      ARGERR          ;Error if now negative
  353	 00F1  74 17	 	 	        JZ      MLEF            ;Offset of zero is same as LEFT$
  354	 00F3  52	 	 	        PUSH    DX
  355	 00F4  50	 	 	        PUSH    AX
  356	 00F5  8B 07	 	 	        MOV     AX,[BX]         ;Get length of string
  357	 00F7  2B C1	 	 	        SUB     AX,CX           ;Reduce length by the offset
  358	 00F9  76 14	 	 	        JBE     NULMID          ;Return null string if nothing left
  359	 00FB  3B C2	 	 	        CMP     AX,DX           ;Need smaller of request and amount remaining
  360	 00FD  73 02	 	 	        JAE     MIDLEN
  361	 00FF  8B D0	 	 	        MOV     DX,AX           ;Limited by length of string
  362	 0101	 	 	 	MIDLEN:
  363	 0101  E8 0000 E	 	        CALL    $$CTSD          ;Create temp string from descriptor
  364	 0104	 	 	 	MIDPOP:
  365	 0104  58	 	 	        POP     AX
  366	 0105  5A	 	 	        POP     DX
  367	 0106	 	 	 	MIDLV:
  368	 0106  87 CA	 	 	        XCHG    CX,DX           ;Restore original position
  369	 0108  42	 	 	        INC     DX              ;  and original value
  370	 0109  CB	 	 	        RET
  371	 	 	 	 	
  372	 010A	 	 	 	MLEF:
  373	 	 	 	 	;Offset into string is zero, so treat just like LEFT$
  374	 010A  E8 0164 R	 	        CALL    LEFRIG
  375	 010D  EB F7	 	 	        JMP     MIDLV
  376	 	 	 	 	
  377	 010F	 	 	 	NULMID:
  378	 	 	 	 	;Return null string for $MID


STRFCN - String function package                                 Macro-86 %1(12)   1:8:33  13-Nov-81    Page 1-8



  379	 010F  BB 0000 E	 	        MOV     BX,OFFSET DC:NULDES  ;Null string descriptor
  380	 0112  EB F0	 	 	        JMP     MIDPOP
  381	 	 	 	 	
  382	 	 	 	 	
  383	 	 	 	 	;***  $SP$, $ST$, and $S2$ - SPACE$ and STRING$ functions
  384	 	 	 	 	;
  385	 	 	 	 	; Inputs:
  386	 	 	 	 	;       BX = Length of string desired
  387	 	 	 	 	;       DL = Character to repeat ($ST$ only)
  388	 	 	 	 	;       DX = Descriptor of string with character to repeat ($S2$) only)
  389	 	 	 	 	; Function:
  390	 	 	 	 	;       Produce temporary string with a single character repeated BX times.
  391	 	 	 	 	;       $SP$ gives a string of blanks, $ST$ provides the character to be
  392	 	 	 	 	;       repeated, and $S2$ provides a string descriptor, the first character
  393	 	 	 	 	;       of which is to be repeated.
  394	 	 	 	 	; Outputs:
  395	 	 	 	 	;       BX = Address of result temp string descriptor
  396	 	 	 	 	; Registers:
  397	 	 	 	 	;       Only BX and F affected.
  398	 	 	 	 	
  399	 0114	 	 	 	$SP$:
  400	 0114  89 26 0000 E	 	        MOV     [$$SPSV],SP
  401	 0118  52	 	 	        PUSH    DX
  402	 0119  B2 20	 	 	        MOV     DL," "          ;Provide a space to be repeated
  403	 	 	 	 	
  404	 011B	 	 	 	STRING:
  405	 	 	 	 	;       DL = character to repeat
  406	 	 	 	 	;       BX = Repeat count
  407	 	 	 	 	; Creates a temporary string with DL repeated BX times. DX popped from stack.
  408	 	 	 	 	
  409	 011B  0B DB	 	 	        OR      BX,BX           ;Check character count
  410	 011D  74 3E	 	 	        JZ      NUL             ;Return null string if zero
  411	 011F  7C 40	 	 	        JL      ARGERR          ;Error if negative
  412	 0121  51	 	 	        PUSH    CX
  413	 0122  50	 	 	        PUSH    AX
  414	 0123  8B CB	 	 	        MOV     CX,BX           ;Put count in count register
  415	 0125  8A C2	 	 	        MOV     AL,DL           ;Character to copy
  416	 0127  8A E2	 	 	        MOV     AH,DL           ;Repeat it by words for speed
  417	 0129  E8 0000 E	 	        CALL    $$ATS           ;Allocate string
  418	 012C  87 FA	 	 	        XCHG    DI,DX           ;Get address of data in destination register
  419	 012E  41	 	 	        INC     CX              ;Round up to whole word if odd
  420	 012F  D1 E9	 	 	        SHR     CX,1            ;Divide byte count by 2 for word move
  421	 0131  F3/ AB	 	 	        REP     STOSW
  422	 0133  8B FA	 	 	        MOV     DI,DX           ;Restore DI
  423	 0135  58	 	 	        POP     AX
  424	 0136  59	 	 	        POP     CX
  425	 0137  5A	 	 	        POP     DX
  426	 0138  CB	 	 	        RET
  427	 	 	 	 	
  428	 0139	 	 	 	$ST$:
  429	 0139  89 26 0000 E	 	        MOV     [$$SPSV],SP
  430	 013D  52	 	 	        PUSH    DX
  431	 013E  EB DB	 	 	        JMP     STRING
  432	 	 	 	 	


STRFCN - String function package                                 Macro-86 %1(12)   1:8:33  13-Nov-81    Page 1-9



  433	 0140	 	 	 	$S2$:
  434	 0140  89 26 0000 E	 	        MOV     [$$SPSV],SP
  435	 0144  87 DA	 	 	        XCHG    BX,DX           ;Put descriptor where we can address with it
  436	 0146  83 3F 00	 	 	        CMP     WORD PTR[BX],0  ;Length of string must not be zero
  437	 0149  74 16	 	 	        JZ      ARGERR
  438	 014B  53	 	 	        PUSH    BX
  439	 014C  50	 	 	        PUSH    AX
  440	 014D  53	 	 	        PUSH    BX
  441	 014E  8B 5F 02	 	 	        MOV     BX,[BX+2]       ;Get address of string data
  442	 0151  8A 07	 	 	        MOV     AL,[BX]         ;Get first character
  443	 0153  5B	 	 	        POP     BX              ;Get descriptor back
  444	 0154  E8 0000 E	 	        CALL    $$DITS          ;Delete if temp string
  445	 0157  93	 	 	        XCHG    AX,BX           ;Put char to repeat in BL
  446	 0158  58	 	 	        POP     AX
  447	 0159  87 DA	 	 	        XCHG    BX,DX           ;Organize parameters
  448	 015B  EB BE	 	 	        JMP     STRING
  449	 	 	 	 	
  450	 015D	 	 	 	NUL:
  451	 015D  BB 0000 E	 	        MOV     BX,OFFSET DC:NULDES
  452	 0160  CB	 	 	        RET
  453	 	 	 	 	
  454	 0161  E9 0000 E	 	ARGERR: JMP     $ERC_FC         ;Clean stack and report illegal function call
  455	 	 	 	 	
  456	 0164	 	 	 	STRFCN  ENDP
  457	 	 	 	 	
  458	 	 	 	 	
  459	 0164	 	 	 	LEFRIG:
  460	 	 	 	 	
  461	 	 	 	 	; This subroutine is used for $LEF, $RIG, and some $MID.
  462	 	 	 	 	; Inputs:BX = Address of string descriptor
  463	 	 	 	 	;       DX = Length requested
  464	 	 	 	 	;       CX = Starting offset
  465	 	 	 	 	; First it does some checks on DX, then calls $$CTSD if necessary.
  466	 	 	 	 	
  467	 0164  0B D2	 	 	        OR      DX,DX           ;Test requested length
  468	 0166  7C F9	 	 	        JL      ARGERR          ;If negative, give error
  469	 0168  74 07	 	 	        JZ      STRNUL          ;If zero, return null string
  470	 016A  3B 17	 	 	        CMP     DX,[BX]         ;See if requested length is longer than string
  471	 016C  73 06	 	 	        JAE     NRET            ;If so, just return string
  472	 016E  E9 0000 E	 	        JMP     $$CTSD          ;Create temp from string descriptor
  473	 	 	 	 	
  474	 0171	 	 	 	STRNUL:
  475	 0171  BB 0000 E	 	        MOV     BX,OFFSET DC:NULDES  ;Point to null descriptor
  476	 0174  C3	 	 	NRET:   RET
  477	 	 	 	 	
  478	 0175	 	 	 	CODE    ENDS
  479	 	 	 	 	        END









STRFCN - String function package                                 Macro-86 %1(12)   1:8:33  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0175	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ARGERR . . . . . . . . . . . . .	L NEAR 	0161	CODE
CHRSUB . . . . . . . . . . . . .	L NEAR 	0036	CODE
EXITFND. . . . . . . . . . . . .	L NEAR 	00A7	CODE
LEFRIG . . . . . . . . . . . . .	L NEAR 	0164	CODE
MIDLEN . . . . . . . . . . . . .	L NEAR 	0101	CODE
MIDLV. . . . . . . . . . . . . .	L NEAR 	0106	CODE
MIDPOP . . . . . . . . . . . . .	L NEAR 	0104	CODE
MLEF . . . . . . . . . . . . . .	L NEAR 	010A	CODE
NOFREE . . . . . . . . . . . . .	L NEAR 	005C	CODE
NOTFND . . . . . . . . . . . . .	L NEAR 	00B9	CODE
NRET . . . . . . . . . . . . . .	L NEAR 	0174	CODE
NUL. . . . . . . . . . . . . . .	L NEAR 	015D	CODE
NULDES . . . . . . . . . . . . .	V WORD 	0000	DATA	External
NULMID . . . . . . . . . . . . .	L NEAR 	010F	CODE
RETNUL . . . . . . . . . . . . .	L NEAR 	0041	CODE
SEARCH . . . . . . . . . . . . .	L NEAR 	0093	CODE
STRFCN . . . . . . . . . . . . .	F PROC	0000	CODE	Length =0164
STRING . . . . . . . . . . . . .	L NEAR 	011B	CODE
STRNUL . . . . . . . . . . . . .	L NEAR 	0171	CODE
TELFRE . . . . . . . . . . . . .	L NEAR 	005F	CODE
TLRG . . . . . . . . . . . . . .	L NEAR 	006C	CODE
$$ATS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$CTSD . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$DITS . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$MAG. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$SFPT . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$CHR . . . . . . . . . . . . . .	L NEAR 	0029	CODE	Global
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERR_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FR$A. . . . . . . . . . . . . .	L NEAR 	0046	CODE	Global
$FREA. . . . . . . . . . . . . .	L NEAR 	0049	CODE	Global
$INK . . . . . . . . . . . . . .	L NEAR 	001B	CODE	Global
$IS2 . . . . . . . . . . . . . .	L NEAR 	00BD	CODE	Global
$IST . . . . . . . . . . . . . .	L NEAR 	006F	CODE	Global
$LEF . . . . . . . . . . . . . .	L NEAR 	00CE	CODE	Global
$LENA. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$LENB. . . . . . . . . . . . . .	L NEAR 	0007	CODE	Global
$MID . . . . . . . . . . . . . .	L NEAR 	00E8	CODE	Global
$MIDSTR. . . . . . . . . . . . .	L NEAR 	00EC	CODE	Global
$RIG . . . . . . . . . . . . . .	L NEAR 	00DA	CODE	Global
$S2$ . . . . . . . . . . . . . .	L NEAR 	0140	CODE	Global


STRFCN - String function package                                 Macro-86 %1(12)   1:8:33  13-Nov-81    Symbols-2



$SNORM . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SP$ . . . . . . . . . . . . . .	L NEAR 	0114	CODE	Global
$ST$ . . . . . . . . . . . . . .	L NEAR 	0139	CODE	Global
$TTYIN . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TTYST . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
_CPM_. . . . . . . . . . . . . .	Number	0000	
_IBM_. . . . . . . . . . . . . .	Number	0000	
_MSDOS_. . . . . . . . . . . . .	Number	0001	

Warning Severe
Errors	Errors 
0	0












































