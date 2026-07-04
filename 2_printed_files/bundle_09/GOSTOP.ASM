GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   GOSTOP - Initialization, STOP, END, and error processing
    2	 	 	 	 	
    3	 	 	 	 	.sall
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
   34	                             C	        INCLUDE ADDR.INC
   35	 = 0000                      C	O_STA           EQU     0               ;Statement address/number table
   36	 = 0002                      C	STARTDATA       EQU     2               ;Start of data statements
   37	 = 0006                      C	O_RAM           EQU     6               ;Start of user RAM
   38	 = 000C                      C	O_RAL           EQU     0CH             ;End of user RAM + 1
   39	 	 	 	 	
   40	 	 	 	 	
   41	 	 	 	 	ERRMSG  MACRO   Errnum,Errtxt
   42	 	 	 	 	        .xcref
   43	 	 	 	 	__Pchr  =       0
   44	 	 	 	 	        DB      Errnum
   45	 	 	 	 	        IRPC    chr,<Errtxt>
   46	 	 	 	 	IF      __Pchr
   47	 	 	 	 	        DB      &__Pchr
   48	 	 	 	 	        ENDIF
   49	 	 	 	 	__Pchr  =       "&chr"
   50	 	 	 	 	        ENDM
   51	 	 	 	 	        DB      __Pchr+128
   52	 	 	 	 	        .cref
   53	 	 	 	 	        ENDM
   54	 	 	 	 	


GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 1-2



   55	 	 	 	 	TYPMSG  MACRO   Txt
   56	 	 	 	 	__Pchr  =       0
   57	 	 	 	 	        CALL    $TYPTX          ;;Print Following string to CON
   58	 	 	 	 	        IRPC    chr,<Txt>
   59	 	 	 	 	IF      __Pchr
   60	 	 	 	 	        DB      &__Pchr
   61	 	 	 	 	        ENDIF
   62	 	 	 	 	__Pchr  =       "&chr"
   63	 	 	 	 	        ENDM
   64	 	 	 	 	        DB      __Pchr+128
   65	 	 	 	 	        ENDM
   66	 	 	 	 	
   67	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
   68	 	 	 	 	
   69	 	 	 	 	        PUBLIC  $SEG,$USR
   70	 	 	 	 	
   71	 	 	 	 	        PUBLIC  $DAC,$AC,$FAC
   72	 	 	 	 	        PUBLIC  $$ERRV,$$SPSV,$$STKP,$MAINBASE
   73	 	 	 	 	
   74	 0000  ????	 	 	$SEG    DW      ?
   75	 0002     0A [	 	 	$USR    DW      10 DUP (?)
   76	                ????	 	
   77	                      ]	 	
   78	 	 	 	 	
   79	 	 	 	 	
   80	 0016     04 [	 	 	$DAC    DB      4 DUP(?)
   81	                ??	 	
   82	                    ]	 	
   83	 	 	 	 	
   84	 001A     03 [	 	 	$AC     DB      3 DUP(?)
   85	                ??	 	
   86	                    ]	 	
   87	 	 	 	 	
   88	 001D  ??	 	 	$FAC    DB      ?
   89	 	 	 	 	
   90	 001E  ????	 	 	$$ERRV  DW      ?               ;Special error handler address
   91	 0020  ????	 	 	$$SPSV  DW      ?               ;Save stack here
   92	 0022  ????	 	 	$$STKP  DW      ?
   93	 	 	 	 	
   94	 0024	 	 	 	CBASE   LABEL   DWORD
   95	 0024  ????	 	 	$MAINBASE DW    ?               ;Starting offset of main
   96	 0026  ????	 	 	MAINCS  DW      ?               ;CS of main program
   97	 	 	 	 	
   98	 0028	 	 	 	DATA    ENDS
   99	 	 	 	 	
  100	 0028	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
  101	 	 	 	 	
  102	 	 	 	 	;This data area is zeroed on initialization and each CLEAR
  103	 	 	 	 	
  104	 	 	 	 	        PUBLIC  $FREPT,$FILPT,$PTRFIL,$$AOER,$$OEIP,$$RSTO
  105	 	 	 	 	        PUBLIC  $ERRNUM,$ERRLIN,$ERRADR,$$GCNT
  106	 	 	 	 	        PUBLIC  $TRACE_SW
  107	 	 	 	 	
  108	 0028	 	 	 	STARTZERO       LABEL   BYTE


GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 1-3



  109	 	 	 	 	
  110	 0028  ????	 	 	$ERRADR DW      ?               ;Error address
  111	 002A  ????	 	 	$ERRNUM DW      ?               ;Error number
  112	 002C  ????	 	 	$ERRLIN DW      ?               ;Error line
  113	 	 	 	 	
  114	 002E  ????	 	 	$FREPT  DW      ?               ;File block free list
  115	 0030  ????	 	 	$FILPT  DW      ?               ;Active file list
  116	 0032  ????	 	 	$PTRFIL DW      ?               ;Current file pointer
  117	 0034  ????	 	 	$$AOER  DW      ?               ;ON ERROR address
  118	 0036  ????	 	 	$$GCNT  DW      ?               ;GOSUB count
  119	 0038  ??	 	 	$$RSTO  DB      ?               ;Has RESTORE occurred yet?
  120	 0039  ??	 	 	$$OEIP  DB      ?               ;ON ERROR in progress
  121	 003A  ??	 	 	$TRACE_SW DB    ?               ;Trace switch
  122	 	 	 	 	
  123	 003B	 	 	 	STOPZERO        LABEL   BYTE
  124	 	 	 	 	
  125	 003B	 	 	 	DATA    ENDS
  126	 	 	 	 	
  127	 	 	 	 	
  128	 0000	 	 	 	BC_CN   SEGMENT WORD PUBLIC 'DATA'
  129	 0000	 	 	 	END_CN  LABEL   BYTE
  130	 0000	 	 	 	BC_CN   ENDS
  131	 	 	 	 	
  132	 0000	 	 	 	BC_DS   SEGMENT BYTE PUBLIC 'DATA'
  133	 0000	 	 	 	END_DS  LABEL   BYTE
  134	 0000	 	 	 	BC_DS   ENDS
  135	 	 	 	 	
  136	 	 	 	 	DC      GROUP   BC_CN,BC_DS,DATA
  137	 	 	 	 	
  138	 	 	 	 	
  139	 0000	 	 	 	BC_ICN  SEGMENT WORD PUBLIC 'INIT'
  140	 0000	 	 	 	END_ICN LABEL   BYTE
  141	 0000	 	 	 	BC_ICN  ENDS
  142	 	 	 	 	
  143	 0000	 	 	 	BC_IDS  SEGMENT BYTE PUBLIC 'INIT'
  144	 0000	 	 	 	END_IDS LABEL   BYTE
  145	 0000	 	 	 	BC_IDS  ENDS
  146	 	 	 	 	


















GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 2-1



  147	 	 	 	 	
  148	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
  149	 	 	 	 	
  150	 0000	 	 	 	ERRTAB  LABEL   BYTE
  151	 	 	 	 	        ERRMSG  2,<Syntax Error in DATA>
  152	 	 	 	 	        ERRMSG  3,<RETURN without GOSUB>
  153	 	 	 	 	        ERRMSG  4,<Out of Data>
  154	 	 	 	 	        ERRMSG  5,<Illegal Function Call>
  155	 	 	 	 	        ERRMSG  6,<Overflow>
  156	 	 	 	 	        ERRMSG  7,<Out of Memory>
  157	 	 	 	 	        ERRMSG  9,<Subscript Out of Range>
  158	 	 	 	 	        ERRMSG  11,<Division by Zero>
  159	 	 	 	 	        ERRMSG  14,<Out of String Space>
  160	 	 	 	 	        ERRMSG  16,<String Formula Too Complex>
  161	 	 	 	 	        ERRMSG  19,<No RESUME>
  162	 	 	 	 	        ERRMSG  20,<RESUME without Error>
  163	 	 	 	 	IF _IBM_
  164	 	 	 	 	        ERRMSG  24,<Device Timeout>
  165	 	 	 	 	        ERRMSG  25,<Device Fault>
  166	 	 	 	 	        ERRMSG  27,<Out of Paper>
  167	 	 	 	 	ENDIF
  168	 	 	 	 	        ERRMSG  50,<Field Overflow>
  169	 	 	 	 	        ERRMSG  51,<Internal Error>
  170	 	 	 	 	        ERRMSG  52,<Bad File Number>
  171	 	 	 	 	        ERRMSG  53,<File Not Found>
  172	 	 	 	 	        ERRMSG  54,<Bad File Mode>
  173	 	 	 	 	        ERRMSG  55,<File Already Open>
  174	 	 	 	 	        ERRMSG  57,<Device I/O Error>
  175	 	 	 	 	        ERRMSG  58,<File Already Exists>
  176	 	 	 	 	        ERRMSG  61,<Disk Full>
  177	 	 	 	 	        ERRMSG  62,<Input Past End>
  178	 	 	 	 	        ERRMSG  63,<Bad Record Number>
  179	 	 	 	 	        ERRMSG  64,<Bad File Name>
  180	 	 	 	 	        ERRMSG  67,<Too Many Files>
  181	 	 	 	 	        ERRMSG  68,<Device Unavailable>
  182	 	 	 	 	IF _MSDOS_
  183	 	 	 	 	  IF _IBM_
  184	 	 	 	 	        ERRMSG  69,<Communication Buffer overflow>
  185	 	 	 	 	  ENDIF
  186	 	 	 	 	        ERRMSG  70,<Disk Write Protect>
  187	 	 	 	 	        ERRMSG  71,<Disk not Ready>
  188	 	 	 	 	        ERRMSG  72,<Disk Media Error>
  189	 	 	 	 	ENDIF
  190	 	 	 	 	        ERRMSG  255,<Unprintable Error>
  191	 	 	 	 	
  192	 01FB	 	 	 	CODE    ENDS










GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 3-1



  193	 	 	 	 	
  194	 	 	 	 	
  195	 01FB	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
  196	 	 	 	 	
  197	 	 	 	 	        PUBLIC  $DS0,$DS1,$USRA
  198	 	 	 	 	        PUBLIC  $DIV0_INT,$OVRF_INT
  199	 	 	 	 	
  200	 	 	 	 	        PUBLIC  $CLR,$CLX
  201	 	 	 	 	        PUBLIC  $FOE,$RTE,$CONT,$ERRPR,$INI0,$431,$531,$RET,$NUL
  202	 	 	 	 	        PUBLIC  $STP,$BREAK,$END,$$PLNM,$GETAD,$ENP
  203	 	 	 	 	        PUBLIC  $$FSFA,$FSERR
  204	 	 	 	 	
  205	 	 	 	 	        PUBLIC  $ERR_RG, $ERR_TM, $ERR_BS, $ERR_RE, $ERR_OS, $ERR_ST
  206	 	 	 	 	        PUBLIC  $ERR_OV, $ERR_FC, $ERR_OD, $ERR_OM, $ERR_SN
  207	 	 	 	 	        PUBLIC  $ERC_RG, $ERC_TM, $ERC_BS, $ERC_RE, $ERC_OS, $ERC_ST
  208	 	 	 	 	        PUBLIC  $ERC_OV, $ERC_FC, $ERC_OD, $ERC_OM, $ERC_SN
  209	 	 	 	 	
  210	 	 	 	 	        PUBLIC  $OVFL, $DIV0    ;****************  Temporary entry points
  211	 	 	 	 	
  212	 	 	 	 	        PUBLIC  $ERR_FOV, $ERR_INT, $ERR_IFN, $ERR_FNF, $ERR_BFM
  213	 	 	 	 	        PUBLIC  $ERR_FAO, $ERR_IOE, $ERR_FAE, $ERR_DFL, $ERR_RPE
  214	 	 	 	 	        PUBLIC  $ERR_BRN, $ERR_BFN, $ERR_TMF
  215	 	 	 	 	        PUBLIC  $ERC_FOV, $ERC_INT, $ERC_IFN, $ERC_FNF, $ERC_BFM
  216	 	 	 	 	        PUBLIC  $ERC_FAO, $ERC_IOE, $ERC_FAE, $ERC_DFL, $ERC_RPE
  217	 	 	 	 	        PUBLIC  $ERC_BRN, $ERC_BFN, $ERC_TMF
  218	 	 	 	 	        PUBLIC  $ERC_DNA, $ERR_DNA
  219	 	 	 	 	
  220	 	 	 	 	IF _MSDOS_
  221	 	 	 	 	IF _IBM_
  222	 	 	 	 	        PUBLIC  $ERC_DTO, $ERC_DVF, $ERC_OTP
  223	 	 	 	 	        PUBLIC  $ERC_CBO
  224	 	 	 	 	        PUBLIC  $ERR_DTO, $ERR_DVF, $ERR_OTP
  225	 	 	 	 	        PUBLIC  $ERR_CBO
  226	 	 	 	 	ENDIF
  227	 	 	 	 	        PUBLIC  $ERR_FWP, $ERR_DNR, $ERR_DME
  228	 	 	 	 	        PUBLIC  $ERC_FWP, $ERC_DNR, $ERC_DME
  229	 	 	 	 	ENDIF
  230	 	 	 	 	
  231	 	 	 	 	        EXTRN   $ABEND:NEAR
  232	 	 	 	 	        EXTRN   $$DTS:NEAR, $OSEXT:NEAR, $$WCHT:NEAR, $$STSU:NEAR
  233	 	 	 	 	        EXTRN   $TYPTX:NEAR, $TYTX:NEAR, $$TCR:NEAR, $$THB:NEAR
  234	 	 	 	 	        EXTRN   $IOINI:NEAR, $TYPUI:NEAR
  235	 	 	 	 	        EXTRN   $INIDEV:NEAR, $CLSDEV:NEAR, $CLOSF:NEAR
  236	 	 	 	 	
  237	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
  238	 	 	 	 	
  239	                             C	        INCLUDE LIBMAC.LIB
  240	                             C	; BASLIB-86 helper macros
  241	                             C	
  242	 = 0001                      C	LXIOK   EQU     1               ;1 to allow LXI tricks, 0 to avoid them
  243	                             C	
  244	                             C	SKIP    MACRO   LENGTH
  245	                             C	
  246	                             C	        IF      LXIOK           ;;OK to use LXI trick?


GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 3-2



  247	                             C	        IF      LENGTH EQ 1     ;;Is length 1?
  248	                             C	        DB      0B0H            ;MOV AL,immediate
  249	                             C	        ENDIF
  250	                             C	        IF      LENGTH EQ 2     ;;Is length 2?
  251	                             C	        DB      0B8H            ;MOV AX,immediate
  252	                             C	        ENDIF
  253	                             C	        IF      LENGTH GT 2
  254	                             C	        ILLEGAL SKIP LENGTH     ;Cause an error
  255	                             C	        ENDIF
  256	                             C	        ELSE                    ;Don't use LXI tricks
  257	                             C	        JMP     SHORT $+LENGTH+2
  258	                             C	
  259	                             C	        ENDIF
  260	                             C	
  261	                             C	        ENDM
  262	                             C	
  263	 	 	 	 	







































GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 3-3



  264	 	 	 	 	        PAGE
  265	 	 	 	 	
  266	 	 	 	 	;***  $INI0 - Initialize run-time system
  267	 	 	 	 	;
  268	 	 	 	 	
  269	 01FB	 	 	 	$INI0   PROC    FAR
  270	 01FB  58	 	 	        POP     AX
  271	 01FC  5B	 	 	        POP     BX              ;Recover segment of main program
  272	 01FD  89 26 0022 R	 	        MOV     [$$STKP],SP
  273	 0201  53	 	 	        PUSH    BX
  274	 0202  50	 	 	        PUSH    AX
  275	 0203  89 1E 0026 R	 	        MOV     [MAINCS],BX
  276	 0207  2D 0013	 	 	        SUB     AX,14+5         ;Size of table and init call
  277	 020A  A3 0024 R	 	        MOV     [$MAINBASE],AX
  278	 020D  C7 06 001E R 0340 R	        MOV     [$$ERRV],OFFSET $CONT
  279	 	 	 	 	
  280	 	 	 	 	;       Clear user data variables
  281	 	 	 	 	
  282	 0213  E8 0269 R	 	        CALL    $GETAD
  283	 0216  06	 	 	        DB      O_RAM
  284	 0217  97	 	 	        XCHG    AX,DI
  285	 0218  E8 0269 R	 	        CALL    $GETAD
  286	 021B  0C	 	 	        DB      O_RAL
  287	 021C  91	 	 	        XCHG    AX,CX
  288	 021D  2B CF	 	 	        SUB     CX,DI
  289	 021F  33 C0	 	 	        XOR     AX,AX
  290	 0221  F3/ AA	 	 	        REP     STOSB
  291	 	 	 	 	
  292	 0223  BF 0028 R	 	        MOV     DI,OFFSET DC:STARTZERO
  293	 0226  B9 0013	 	 	        MOV     CX,STOPZERO-STARTZERO
  294	 0229  F3/ AA	 	 	        REP     STOSB           ;Zero library variables
  295	 	 	 	 	
  296	 022B  48	 	 	        DEC     AX              ;(AX) = -1
  297	 022C  B9 000A	 	 	        MOV     CX,10
  298	 022F  BF 0002 R	 	        MOV     DI,OFFSET DC:$USR
  299	 0232  F3/ AB	 	 	        REP     STOSW           ;Initialize $USR address vectors
  300	 	 	 	 	
  301	 	 	 	 	;       Move constants and data statements from INIT to DATA
  302	 	 	 	 	
  303	 0234  1E	 	 	        PUSH    DS
  304	 0235  06	 	 	        PUSH    ES
  305	 0236  B8  ---- R	 	        MOV     AX,BC_ICN       ;Get base segment addresses
  306	 0239  8E D8	 	 	        MOV     DS,AX
  307	 023B  B8  ---- R	 	        MOV     AX,BC_CN
  308	 023E  8E C0	 	 	        MOV     ES,AX
  309	 0240  B9 0000 R	 	        MOV     CX,(OFFSET END_ICN)
  310	 0243  BB 0000 R	 	        MOV     BX,(OFFSET END_IDS)
  311	 0246  03 CB	 	 	        ADD     CX,BX
  312	 0248  33 F6	 	 	        XOR     SI,SI
  313	 024A  33 FF	 	 	        XOR     DI,DI
  314	 024C  F3/ A4	 	 	        REP     MOVSB
  315	 024E  07	 	 	        POP     ES
  316	 024F  1F	 	 	        POP     DS
  317	 	 	 	 	


GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 3-4



  318	 0250  E8 0000 E	 	        CALL    $$STSU          ;Set up string space
  319	 0253  E8 0000 E	 	        CALL    $IOINI          ;I/O init
  320	 0256  E8 0000 E	 	        CALL    $INIDEV         ;Initialize devices
  321	 	 	 	 	
  322	 	 	 	 	;**     $DS0 - Set BASIC Segment Address to Data Segment
  323	 	 	 	 	
  324	 0259  8C 1E 0000 R	 	$DS0:   MOV     $SEG,DS         ;Save initial data seg
  325	 	 	 	 	
  326	 025D	 	 	 	$CLR:                           ;**************  For now  **************
  327	 025D	 	 	 	$CLX:                           ;**************           **************
  328	 025D	 	 	 	$NUL:                           ;**************  For now  **************
  329	 025D	 	 	 	$RET:
  330	 025D	 	 	 	$431:
  331	 025D  CB	 	 	$531:   RET
  332	 	 	 	 	
  333	 	 	 	 	
  334	 	 	 	 	;**     $DS1 - Set BASIC Segment Address
  335	 	 	 	 	;
  336	 	 	 	 	;       ENTRY   (BX) = new segment address
  337	 	 	 	 	
  338	 025E  89 1E 0000 R	 	$DS1:   MOV     $SEG,BX         ;Save new $SEG value
  339	 0262  CB	 	 	        RET
  340	 	 	 	 	
  341	 	 	 	 	
  342	 	 	 	 	;**     $USRA - Call user defined routine
  343	 	 	 	 	;
  344	 	 	 	 	;       ENTRY   (BX) = offset address of user routine
  345	 	 	 	 	
  346	 0263  FF 36 0000 R	 	$USRA:  PUSH    [$SEG]          ;Save $SEG value
  347	 0267  53	 	 	        PUSH    BX              ;Save offset address
  348	 0268  CB	 	 	        RET                     ;Call by long RET
  349	 	 	 	 	
  350	 0269	 	 	 	$INI0   ENDP
  351	 	 	 	 	
  352	 	 	 	 	
  353	 0269	 	 	 	$GETAD:
  354	 0269  5E	 	 	        POP     SI
  355	 026A  2E: AC	 	 	        LODS    BYTE PTR CS:[SI]  ;Get byte indicating which address
  356	 026C  98	 	 	        CBW
  357	 026D  56	 	 	        PUSH    SI
  358	 026E  1E	 	 	        PUSH    DS
  359	 026F  C5 36 0024 R	 	        LDS     SI,[CBASE]
  360	 0273  03 F0	 	 	        ADD     SI,AX
  361	 0275  AD	 	 	        LODSW
  362	 0276  1F	 	 	        POP     DS
  363	 0277  C3	 	 	        RET










GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 4-1



  364	 	 	 	 	
  365	 	 	 	 	
  366	 	 	 	 	;**     8086 Error interrupt vector
  367	 	 	 	 	
  368	 0278	 	 	 	$DIV0_INT:
  369	 0278  58	 	 	        POP     AX
  370	 0279  5B	 	 	        POP     BX
  371	 027A  9D	 	 	        POPF                            ;Restore interrupt status
  372	 027B  53	 	 	        PUSH    BX
  373	 027C  50	 	 	        PUSH    AX
  374	 027D  EB 79 90	 	 	        JMP     $ERR_DV0                ;Divide by 0 error
  375	 	 	 	 	
  376	 0280	 	 	 	$OVRF_INT:
  377	 0280  58	 	 	        POP     AX
  378	 0281  5B	 	 	        POP     BX
  379	 0282  9D	 	 	        POPF                            ;Restore interrupt status
  380	 0283  53	 	 	        PUSH    BX
  381	 0284  50	 	 	        PUSH    AX
  382	 0285  EB 68 90	 	 	        JMP     $ERR_OV                 ;Overflow error
  383	 	 	 	 	
  384	 	 	 	 	
  385	 	 	 	 	;***  Error entry points
  386	 	 	 	 	
  387	 	 	 	 	; This group assumes a clean stack value has been saved in $$SPSV. This saved
  388	 	 	 	 	; value is restored.
  389	 	 	 	 	
  390	 	 	 	 	
  391	 	 	 	 	ERRMAC  MACRO   func,noskip
  392	 	 	 	 	        MOV     BL,func
  393	 	 	 	 	ifb     <noskip>
  394	 	 	 	 	        SKIP    2
  395	 	 	 	 	endif
  396	 	 	 	 	        ENDM
  397	 	 	 	 	
  398	 	 	 	 	
  399	 	 	 	 	
  400	 0288	 	 	 	$ERC_SN:        ERRMAC  2
  401	 028B	 	 	 	$ERC_RG:        ERRMAC  3
  402	 028E	 	 	 	$ERC_OD:        ERRMAC  4
  403	 0291	 	 	 	$ERC_FC:        ERRMAC  5
  404	 0294	 	 	 	$OVFL:                                  ;;Temporary entry point
  405	 0294	 	 	 	$ERC_OV:        ERRMAC  6
  406	 0297	 	 	 	$ERC_OM:        ERRMAC  7
  407	 029A	 	 	 	$ERC_BS:        ERRMAC  9
  408	 029D	 	 	 	$DIV0:          ERRMAC  11              ;;Temporary entry point
  409	 02A0	 	 	 	$ERC_TM:        ERRMAC  13
  410	 02A3	 	 	 	$ERC_OS:        ERRMAC  14
  411	 02A6	 	 	 	$ERC_ST:        ERRMAC  16
  412	 02A9	 	 	 	$ERC_RE:        ERRMAC  20
  413	 	 	 	 	IF _IBM_
  414	 	 	 	 	  $ERC_DTO:     ERRMAC  24
  415	 	 	 	 	  $ERC_DVF:     ERRMAC  25
  416	 	 	 	 	  $ERC_OTP:     ERRMAC  27
  417	 	 	 	 	ENDIF


GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 4-2



  418	 	 	 	 	
  419	 02AC	 	 	 	$ERC_FOV:       ERRMAC  50
  420	 02AF	 	 	 	$ERC_INT:       ERRMAC  51
  421	 02B2	 	 	 	$ERC_IFN:       ERRMAC  52
  422	 02B5	 	 	 	$ERC_FNF:       ERRMAC  53
  423	 02B8	 	 	 	$ERC_BFM:       ERRMAC  54
  424	 02BB	 	 	 	$ERC_FAO:       ERRMAC  55
  425	 02BE	 	 	 	$ERC_IOE:       ERRMAC  57
  426	 02C1	 	 	 	$ERC_FAE:       ERRMAC  58
  427	 02C4	 	 	 	$ERC_DFL:       ERRMAC  61
  428	 02C7	 	 	 	$ERC_RPE:       ERRMAC  62
  429	 02CA	 	 	 	$ERC_BRN:       ERRMAC  63
  430	 02CD	 	 	 	$ERC_BFN:       ERRMAC  64
  431	 02D0	 	 	 	$ERC_TMF:       ERRMAC  67
  432	 	 	 	 	IF _MSDOS_
  433	 	 	 	 	  IF _IBM_
  434	 	 	 	 	    $ERC_CBO:   ERRMAC  69
  435	 	 	 	 	  ENDIF
  436	 02D3	 	 	 	  $ERC_FWP:     ERRMAC  70
  437	 02D6	 	 	 	  $ERC_DNR:     ERRMAC  71
  438	 02D9	 	 	 	  $ERC_DME:     ERRMAC  72
  439	 	 	 	 	ENDIF
  440	 02DC	 	 	 	$ERC_DNA:       ERRMAC  68,noskip       ;last in chain
  441	 	 	 	 	
  442	 02DE	 	 	 	CLNSTK:
  443	 02DE  8B 26 0020 R	 	         MOV    SP,[$$SPSV]     ;Restore a clean stack
  444	 	 	 	 	         SKIP   2
  445	 	 	 	 	
  446	 	 	 	 	; This group has all the same entry points as above, but it assumes stack
  447	 	 	 	 	; is at proper level upon entry
  448	 	 	 	 	
  449	 02E3	 	 	 	$ERR_SN:        ERRMAC  2
  450	 02E6	 	 	 	$ERR_RG:        ERRMAC  3
  451	 02E9	 	 	 	$ERR_OD:        ERRMAC  4
  452	 02EC	 	 	 	$ERR_FC:        ERRMAC  5
  453	 02EF	 	 	 	$ERR_OV:        ERRMAC  6
  454	 02F2	 	 	 	$ERR_OM:        ERRMAC  7
  455	 02F5	 	 	 	$ERR_BS:        ERRMAC  9
  456	 02F8	 	 	 	$ERR_DV0:       ERRMAC  11
  457	 02FB	 	 	 	$ERR_TM:        ERRMAC  13
  458	 02FE	 	 	 	$ERR_OS:        ERRMAC  14
  459	 0301	 	 	 	$ERR_ST:        ERRMAC  16
  460	 0304	 	 	 	$ERR_RE:        ERRMAC  20
  461	 	 	 	 	IF _IBM_
  462	 	 	 	 	  $ERR_DTO:     ERRMAC  24
  463	 	 	 	 	  $ERR_DVF:     ERRMAC  25
  464	 	 	 	 	  $ERR_OTP:     ERRMAC  27
  465	 	 	 	 	ENDIF
  466	 	 	 	 	
  467	 0307	 	 	 	$ERR_FOV:       ERRMAC  50
  468	 030A	 	 	 	$ERR_INT:       ERRMAC  51
  469	 030D	 	 	 	$ERR_IFN:       ERRMAC  52
  470	 0310	 	 	 	$ERR_FNF:       ERRMAC  53
  471	 0313	 	 	 	$ERR_BFM:       ERRMAC  54


GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 4-3



  472	 0316	 	 	 	$ERR_FAO:       ERRMAC  55
  473	 0319	 	 	 	$ERR_IOE:       ERRMAC  57
  474	 031C	 	 	 	$ERR_FAE:       ERRMAC  58
  475	 031F	 	 	 	$ERR_DFL:       ERRMAC  61
  476	 0322	 	 	 	$ERR_RPE:       ERRMAC  62
  477	 0325	 	 	 	$ERR_BRN:       ERRMAC  63
  478	 0328	 	 	 	$ERR_BFN:       ERRMAC  64
  479	 032B	 	 	 	$ERR_TMF:       ERRMAC  67
  480	 	 	 	 	IF _MSDOS_
  481	 	 	 	 	  IF _IBM_
  482	 	 	 	 	    $ERR_CBO:   ERRMAC  69
  483	 	 	 	 	  ENDIF
  484	 032E	 	 	 	  $ERR_FWP:     ERRMAC  70
  485	 0331	 	 	 	  $ERR_DNR:     ERRMAC  71
  486	 0334	 	 	 	  $ERR_DME:     ERRMAC  72
  487	 	 	 	 	ENDIF
  488	 0337	 	 	 	$ERR_DNA:       ERRMAC  68,noskip       ;last in chain
  489	 	 	 	 	






































GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 4-4



  490	 	 	 	 	        PAGE
  491	 	 	 	 	
  492	 	 	 	 	;***  $FOE/$RTE - Process Run-Time Error
  493	 	 	 	 	;
  494	 	 	 	 	; Inputs:
  495	 	 	 	 	;       BL = Error code
  496	 	 	 	 	;       Top of stack has address in compiled code
  497	 	 	 	 	; Function:
  498	 	 	 	 	;       If special error handling is needed, a jump to the address in $$ERRV
  499	 	 	 	 	;       will be made; otherwise, if ON ERROR GOTO has been specified but is not
  500	 	 	 	 	;       currently processing an error, it will be activated; otherwise, bitch
  501	 	 	 	 	;       and exit.
  502	 	 	 	 	; Outputs:
  503	 	 	 	 	;       None. Does not return, but will jump to [$$ERRV], ON ERROR, or exit.
  504	 	 	 	 	; Registers:
  505	 	 	 	 	;       All registers trashed.
  506	 	 	 	 	
  507	 0339	 	 	 	Error_trap      PROC    FAR
  508	 	 	 	 	
  509	 0339	 	 	 	$FOE:
  510	 0339	 	 	 	$RTE:
  511	 0339  E8 0000 E	 	        CALL    $$DTS           ;Delete all temp strings
  512	 	 	 	 	;Execute special error handling if needed. If it is not needed, $$ERRV must
  513	 	 	 	 	;contain $CONT so that normal processing will just continue.
  514	 033C  FF 26 001E R	 	        JMP     [$$ERRV]
  515	 0340	 	 	 	$CONT:
  516	 0340  80 3E 0039 R 00	 	        CMP     [$$OEIP],0      ;ON ERROR in process?
  517	 0345  75 27	 	 	        JNZ     RUNERR          ;No second chances--report error and exit
  518	 0347  83 3E 0034 R 00	 	        CMP     [$$AOER],0      ;ON ERROR set?
  519	 034C  74 20	 	 	        JZ      RUNERR          ;If not, quit
  520	 	 	 	 	
  521	 	 	 	 	; Activate ON ERROR GOTO
  522	 	 	 	 	
  523	 034E  32 FF	 	 	        XOR     BH,BH           ;Clear high byte
  524	 0350  89 1E 002A R	 	        MOV     [$ERRNUM],BX    ;Save error number
  525	 0354  58	 	 	        POP     AX              ;Get error offset
  526	 0355  A3 0028 R	 	        MOV     [$ERRADR],AX    ;Save error address
  527	 0358  E8 040F R	 	        CALL    $$FSFA          ;Get statement number of error
  528	 035B  A3 002C R	 	        MOV     [$ERRLIN],AX    ;Save statement number of error
  529	 035E  C6 06 0039 R 01	 	        MOV     [$$OEIP],1      ;Mark ON ERROR in progress
  530	 0363  5E	 	 	        POP     SI              ;Get error segment
  531	 0364  8B 26 0022 R	 	        MOV     SP,[$$STKP]     ;Reset stack to proper level
  532	 0368  56	 	 	        PUSH    SI              ;Set error segment
  533	 0369  FF 36 0034 R	 	        PUSH    [$$AOER]        ;Set error vector as offset
  534	 036D  CB	 	 	        RET                     ;Transfer to error routine
  535	 036E	 	 	 	RUNERR:
  536	 036E  E8 03E9 R	 	        CALL    $ERRPR          ;Print error
  537	 0371  EB 0A	 	 	        JMP     SHORT STOP1
  538	 	 	 	 	
  539	 0373	 	 	 	Error_trap      ENDP
  540	 	 	 	 	
  541	 	 	 	 	
  542	 	 	 	 	;***  $STP and $END
  543	 	 	 	 	;


GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 4-5



  544	 	 	 	 	; Print message (STOP only), close files, and exit
  545	 	 	 	 	
  546	 0373  E8 0000 E	 	$STP:   CALL    $$TCR
  547	 	 	 	 	        TYPMSG  <STOP>
  548	 037D	 	 	 	STOP1:
  549	 037D  E8 039B R	 	        CALL    $$PLNM          ;Print line number of stop
  550	 0380	 	 	 	$BREAK:
  551	 0380  F9	 	 	        STC
  552	 0381  EB 0A	 	 	        JMP     SHORT end1
  553	 	 	 	 	
  554	 	 	 	 	;**     $ENP - End of program
  555	 	 	 	 	
  556	 0383	 	 	 	$ENP:
  557	 0383  B3 13	 	 	        MOV     BL,19           ;Assume No RESUME error
  558	 0385  80 3E 0039 R 00	 	        CMP     [$$OEIP],0      ;Is error in progress?
  559	 038A  75 E2	 	 	        JNZ     RUNERR          ;Yes - give error - No RESUME
  560	 	 	 	 	
  561	 038C	 	 	 	$END:
  562	 038C  F8	 	 	        CLC
  563	 	 	 	 	
  564	 038D  9C	 	 	end1:   PUSHF
  565	 038E  E8 0000 E	 	        CALL    $$TCR           ;Print CR/LF
  566	 0391  E8 0000 E	 	        CALL    $CLOSF          ;Close all files
  567	 0394  E8 0000 E	 	        CALL    $CLSDEV         ;Close all devices
  568	 0397  9D	 	 	        POPF
  569	 0398  E9 0000 E	 	        JMP     $OSEXT          ;Exit back to O.S.






























GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 5-1



  570	 	 	 	 	
  571	 	 	 	 	
  572	 	 	 	 	;***  $$PLNM - Print line number message
  573	 	 	 	 	;
  574	 	 	 	 	; Inputs:
  575	 	 	 	 	;       Top of stack has return address, then IP and CS to print.
  576	 	 	 	 	; Function:
  577	 	 	 	 	;       Print address in hex, after " at address ".
  578	 	 	 	 	; Outputs:
  579	 	 	 	 	;       None.
  580	 	 	 	 	; Registers:
  581	 	 	 	 	;       All registers destroyed.
  582	 	 	 	 	
  583	 039B	 	 	 	$$PLNM:
  584	 039B  E8 0269 R	 	        CALL    $GETAD          ;Get address of statement address/number table
  585	 039E  00	 	 	        DB      O_STA
  586	 039F  0B C0	 	 	        OR      AX,AX
  587	 03A1  74 19	 	 	        JZ      plnm5           ;No table
  588	 	 	 	 	
  589	 	 	 	 	        TYPMSG  < in line >
  590	 03AF  5D	 	 	        POP     BP              ;Return address
  591	 03B0  58	 	 	        POP     AX              ;IP
  592	 03B1  5A	 	 	        POP     DX              ;CS
  593	 03B2  55	 	 	        PUSH    BP
  594	 03B3  E8 040F R	 	        CALL    $$FSFA          ;Find line number for address (AX)
  595	 03B6  E8 0000 E	 	        CALL    $TYPUI          ;Print it to console
  596	 03B9  E9 0000 E	 	        JMP     $$TCR           ;Output CR/LF
  597	 	 	 	 	
  598	 03BC	 	 	 	plnm5:  TYPMSG  < at address >
  599	 03CB  5D	 	 	        POP     BP              ;Return address
  600	 03CC  5F	 	 	        POP     DI              ;IP
  601	 03CD  5A	 	 	        POP     DX              ;CS
  602	 03CE  55	 	 	        PUSH    BP              ;Return address back on stack
  603	 03CF  E8 03DF R	 	        CALL    HEXWORD
  604	 03D2  B0 3A	 	 	        MOV     AL,":"          ;Separate segment and offset
  605	 03D4  E8 0000 E	 	        CALL    $$WCHT
  606	 03D7  8B D7	 	 	        MOV     DX,DI
  607	 03D9  E8 03DF R	 	        CALL    HEXWORD
  608	 03DC  E9 0000 E	 	        JMP     $$TCR
  609	 	 	 	 	
  610	 03DF	 	 	 	HEXWORD:
  611	 03DF  8A C6	 	 	        MOV     AL,DH
  612	 03E1  E8 0000 E	 	        CALL    $$THB           ;Print hex byte
  613	 03E4  8A C2	 	 	        MOV     AL,DL
  614	 03E6  E9 0000 E	 	        JMP     $$THB
  615	 	 	 	 	
  616	 03E9	 	 	 	$ERRPR:
  617	 	 	 	 	;Print error message given standard error code in BL
  618	 03E9  E8 0000 E	 	        CALL    $$TCR           ;Print CR/LF
  619	 03EC  06	 	 	        PUSH    ES
  620	 03ED  0E	 	 	        PUSH    CS
  621	 03EE  07	 	 	        POP     ES              ;Set ES to code segment
  622	 03EF  BF 0000 R	 	        MOV     DI, OFFSET ERRTAB
  623	 03F2  8A C3	 	 	        MOV     AL,BL


GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 5-2



  624	 03F4  B4 80	 	 	        MOV     AH,80H
  625	 03F6	 	 	 	CHKERR:
  626	 03F6  26: 80 3D FF	 	        CMP     BYTE PTR ES:[DI],-1     ;See if end of list
  627	 03FA  74 0C	 	 	        JZ      PRNERR1
  628	 03FC  AE	 	 	        SCASB                   ;Compare error code byte
  629	 03FD  74 0A	 	 	        JZ      PRNERR
  630	 03FF  86 C4	 	 	        XCHG    AL,AH           ;Scan for code >=80H
  631	 0401	 	 	 	EATMES:
  632	 0401  AE	 	 	        SCASB
  633	 0402  73 FD	 	 	        JAE     EATMES
  634	 0404  86 C4	 	 	        XCHG    AL,AH
  635	 0406  EB EE	 	 	        JMP     CHKERR
  636	 	 	 	 	
  637	 0408	 	 	 	PRNERR1:
  638	 0408  47	 	 	        INC     DI
  639	 0409	 	 	 	PRNERR:
  640	 0409  07	 	 	        POP     ES
  641	 040A  8B F7	 	 	        MOV     SI,DI
  642	 040C  E9 0000 E	 	        JMP     $TYTX
  643	 	 	 	 	
  644	 	 	 	 	
  645	 	 	 	 	;***    $$FSFA - Find statement number from address
  646	 	 	 	 	;
  647	 	 	 	 	; Inputs:
  648	 	 	 	 	;       AX = return address into user program
  649	 	 	 	 	; Outputs:
  650	 	 	 	 	;       AX = Statement number
  651	 	 	 	 	;       BX = Address of start of statement
  652	 	 	 	 	; Registers:
  653	 	 	 	 	;       All destroyed
  654	 	 	 	 	
  655	 040F	 	 	 	$$FSFA:                         ;Find statement number from address in (AX)
  656	 040F  91	 	 	        XCHG    AX,CX           ;(CX) = original return address
  657	 0410  E8 0269 R	 	        CALL    $GETAD          ;Get statement number address table
  658	 0413  00	 	 	        DB      O_STA
  659	 0414  96	 	 	        XCHG    AX,SI           ;(SI) = statement address table
  660	 0415  8E 1E 0026 R	 	        MOV     DS,[MAINCS]     ;(DS) = user program segment
  661	 0419  33 DB	 	 	        XOR     BX,BX           ;(BX) = 0 (current closest address)
  662	 	 	 	 	
  663	 041B  AD	 	 	fsfalp: LODSW                   ;(AX) = next address to check
  664	 041C  0B C0	 	 	        OR      AX,AX           ;Check if end of table
  665	 041E  74 11	 	 	        JZ      fsfend          ;  Yes
  666	 	 	 	 	
  667	 0420  3B C1	 	 	        CMP     AX,CX           ;Are we less than original address
  668	 0422  73 09	 	 	        JAE     fsfnxt          ;  No - skip this one
  669	 0424  3B C3	 	 	        CMP     AX,BX           ;Are we above the current closest address
  670	 0426  72 05	 	 	        JB      fsfnxt          ;  No - skip this one
  671	 	 	 	 	
  672	 0428  93	 	 	        XCHG    AX,BX           ;(BX) = new closest address
  673	 0429  AD	 	 	        LODSW                   ;Get statement number
  674	 042A  92	 	 	        XCHG    AX,DX           ;Save it in (DX)
  675	 042B  EB EE	 	 	        JMP     fsfalp          ;Keep looping
  676	 	 	 	 	
  677	 042D  46	 	 	fsfnxt: INC     SI              ;Skip statement number


GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Page 5-3



  678	 042E  46	 	 	        INC     SI
  679	 042F  EB EA	 	 	        JMP     fsfalp          ;Keep looping
  680	 	 	 	 	
  681	 0431  06	 	 	fsfend: PUSH    ES              ;Restore DS
  682	 0432  1F	 	 	        POP     DS
  683	 0433  0B DB	 	 	        OR      BX,BX           ;Test if line number found
  684	 0435  74 02	 	 	        JE      $FSERR          ;  No
  685	 0437  92	 	 	        XCHG    Ax,DX           ;(AX) = statement number
  686	 0438  C3	 	 	        RET
  687	 	 	 	 	
  688	 0439	 	 	 	$FSERR:                         ;Have an internal error
  689	 	 	 	 	        TYPMSG  <Internal Error - No Line Number>
  690	 045B  E8 0000 E	 	        CALL    $$TCR           ;Output CR/LF
  691	 045E  E9 0000 E	 	        JMP     $ABEND          ;Just die
  692	 	 	 	 	
  693	 	 	 	 	
  694	 0461	 	 	 	CODE    ENDS
  695	 	 	 	 	
  696	 	 	 	 	        END





































GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Symbols-1




Macros:

	 	N a m e  	 	Length

ERRMAC . . . . . . . . . . . . .	0002	
ERRMSG . . . . . . . . . . . . .	0004	
SKIP . . . . . . . . . . . . . .	0006	
TYPMSG . . . . . . . . . . . . .	0004	

Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

BC_ICN . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'INIT'
BC_IDS . . . . . . . . . . . . .	0000	BYTE  	PUBLIC	'INIT'
CODE . . . . . . . . . . . . . .	0461	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  BC_CN. . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'
  BC_DS. . . . . . . . . . . . . .	0000	BYTE  	PUBLIC	'DATA'
  DATA . . . . . . . . . . . . . .	003B	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

CBASE. . . . . . . . . . . . . .	L DWORD	0024	DATA
CHKERR . . . . . . . . . . . . .	L NEAR 	03F6	CODE
CLNSTK . . . . . . . . . . . . .	L NEAR 	02DE	CODE
EATMES . . . . . . . . . . . . .	L NEAR 	0401	CODE
END1 . . . . . . . . . . . . . .	L NEAR 	038D	CODE
END_CN . . . . . . . . . . . . .	L BYTE 	0000	BC_CN
END_DS . . . . . . . . . . . . .	L BYTE 	0000	BC_DS
END_ICN. . . . . . . . . . . . .	L BYTE 	0000	BC_ICN
END_IDS. . . . . . . . . . . . .	L BYTE 	0000	BC_IDS
ERROR_TRAP . . . . . . . . . . .	F PROC	0339	CODE	Length =003A
ERRTAB . . . . . . . . . . . . .	L BYTE 	0000	CODE
FSFALP . . . . . . . . . . . . .	L NEAR 	041B	CODE
FSFEND . . . . . . . . . . . . .	L NEAR 	0431	CODE
FSFNXT . . . . . . . . . . . . .	L NEAR 	042D	CODE
HEXWORD. . . . . . . . . . . . .	L NEAR 	03DF	CODE
LXIOK. . . . . . . . . . . . . .	Number	0001	
MAINCS . . . . . . . . . . . . .	L WORD 	0026	DATA
O_RAL. . . . . . . . . . . . . .	Number	000C	
O_RAM. . . . . . . . . . . . . .	Number	0006	
O_STA. . . . . . . . . . . . . .	Number	0000	
PLNM5. . . . . . . . . . . . . .	L NEAR 	03BC	CODE
PRNERR . . . . . . . . . . . . .	L NEAR 	0409	CODE
PRNERR1. . . . . . . . . . . . .	L NEAR 	0408	CODE
RUNERR . . . . . . . . . . . . .	L NEAR 	036E	CODE
STARTDATA. . . . . . . . . . . .	Number	0002	
STARTZERO. . . . . . . . . . . .	L BYTE 	0028	DATA
STOP1. . . . . . . . . . . . . .	L NEAR 	037D	CODE
STOPZERO . . . . . . . . . . . .	L BYTE 	003B	DATA
$$AOER . . . . . . . . . . . . .	L WORD 	0034	DATA	Global


GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Symbols-2



$$DTS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$ERRV . . . . . . . . . . . . .	L WORD 	001E	DATA	Global
$$FSFA . . . . . . . . . . . . .	L NEAR 	040F	CODE	Global
$$GCNT . . . . . . . . . . . . .	L WORD 	0036	DATA	Global
$$OEIP . . . . . . . . . . . . .	L BYTE 	0039	DATA	Global
$$PLNM . . . . . . . . . . . . .	L NEAR 	039B	CODE	Global
$$RSTO . . . . . . . . . . . . .	L BYTE 	0038	DATA	Global
$$SPSV . . . . . . . . . . . . .	L WORD 	0020	DATA	Global
$$STKP . . . . . . . . . . . . .	L WORD 	0022	DATA	Global
$$STSU . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$TCR. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$THB. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$WCHT . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$431 . . . . . . . . . . . . . .	L NEAR 	025D	CODE	Global
$531 . . . . . . . . . . . . . .	L NEAR 	025D	CODE	Global
$ABEND . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$AC. . . . . . . . . . . . . . .	L BYTE 	001A	DATA	Global	Length =0003
$BREAK . . . . . . . . . . . . .	L NEAR 	0380	CODE	Global
$CLOSF . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$CLR . . . . . . . . . . . . . .	L NEAR 	025D	CODE	Global
$CLSDEV. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$CLX . . . . . . . . . . . . . .	L NEAR 	025D	CODE	Global
$CONT. . . . . . . . . . . . . .	L NEAR 	0340	CODE	Global
$DAC . . . . . . . . . . . . . .	L BYTE 	0016	DATA	Global	Length =0004
$DIV0. . . . . . . . . . . . . .	L NEAR 	029D	CODE	Global
$DIV0_INT. . . . . . . . . . . .	L NEAR 	0278	CODE	Global
$DS0 . . . . . . . . . . . . . .	L NEAR 	0259	CODE	Global
$DS1 . . . . . . . . . . . . . .	L NEAR 	025E	CODE	Global
$END . . . . . . . . . . . . . .	L NEAR 	038C	CODE	Global
$ENP . . . . . . . . . . . . . .	L NEAR 	0383	CODE	Global
$ERC_BFM . . . . . . . . . . . .	L NEAR 	02B8	CODE	Global
$ERC_BFN . . . . . . . . . . . .	L NEAR 	02CD	CODE	Global
$ERC_BRN . . . . . . . . . . . .	L NEAR 	02CA	CODE	Global
$ERC_BS. . . . . . . . . . . . .	L NEAR 	029A	CODE	Global
$ERC_DFL . . . . . . . . . . . .	L NEAR 	02C4	CODE	Global
$ERC_DME . . . . . . . . . . . .	L NEAR 	02D9	CODE	Global
$ERC_DNA . . . . . . . . . . . .	L NEAR 	02DC	CODE	Global
$ERC_DNR . . . . . . . . . . . .	L NEAR 	02D6	CODE	Global
$ERC_FAE . . . . . . . . . . . .	L NEAR 	02C1	CODE	Global
$ERC_FAO . . . . . . . . . . . .	L NEAR 	02BB	CODE	Global
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0291	CODE	Global
$ERC_FNF . . . . . . . . . . . .	L NEAR 	02B5	CODE	Global
$ERC_FOV . . . . . . . . . . . .	L NEAR 	02AC	CODE	Global
$ERC_FWP . . . . . . . . . . . .	L NEAR 	02D3	CODE	Global
$ERC_IFN . . . . . . . . . . . .	L NEAR 	02B2	CODE	Global
$ERC_INT . . . . . . . . . . . .	L NEAR 	02AF	CODE	Global
$ERC_IOE . . . . . . . . . . . .	L NEAR 	02BE	CODE	Global
$ERC_OD. . . . . . . . . . . . .	L NEAR 	028E	CODE	Global
$ERC_OM. . . . . . . . . . . . .	L NEAR 	0297	CODE	Global
$ERC_OS. . . . . . . . . . . . .	L NEAR 	02A3	CODE	Global
$ERC_OV. . . . . . . . . . . . .	L NEAR 	0294	CODE	Global
$ERC_RE. . . . . . . . . . . . .	L NEAR 	02A9	CODE	Global
$ERC_RG. . . . . . . . . . . . .	L NEAR 	028B	CODE	Global
$ERC_RPE . . . . . . . . . . . .	L NEAR 	02C7	CODE	Global


GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Symbols-3



$ERC_SN. . . . . . . . . . . . .	L NEAR 	0288	CODE	Global
$ERC_ST. . . . . . . . . . . . .	L NEAR 	02A6	CODE	Global
$ERC_TM. . . . . . . . . . . . .	L NEAR 	02A0	CODE	Global
$ERC_TMF . . . . . . . . . . . .	L NEAR 	02D0	CODE	Global
$ERRADR. . . . . . . . . . . . .	L WORD 	0028	DATA	Global
$ERRLIN. . . . . . . . . . . . .	L WORD 	002C	DATA	Global
$ERRNUM. . . . . . . . . . . . .	L WORD 	002A	DATA	Global
$ERRPR . . . . . . . . . . . . .	L NEAR 	03E9	CODE	Global
$ERR_BFM . . . . . . . . . . . .	L NEAR 	0313	CODE	Global
$ERR_BFN . . . . . . . . . . . .	L NEAR 	0328	CODE	Global
$ERR_BRN . . . . . . . . . . . .	L NEAR 	0325	CODE	Global
$ERR_BS. . . . . . . . . . . . .	L NEAR 	02F5	CODE	Global
$ERR_DFL . . . . . . . . . . . .	L NEAR 	031F	CODE	Global
$ERR_DME . . . . . . . . . . . .	L NEAR 	0334	CODE	Global
$ERR_DNA . . . . . . . . . . . .	L NEAR 	0337	CODE	Global
$ERR_DNR . . . . . . . . . . . .	L NEAR 	0331	CODE	Global
$ERR_DV0 . . . . . . . . . . . .	L NEAR 	02F8	CODE
$ERR_FAE . . . . . . . . . . . .	L NEAR 	031C	CODE	Global
$ERR_FAO . . . . . . . . . . . .	L NEAR 	0316	CODE	Global
$ERR_FC. . . . . . . . . . . . .	L NEAR 	02EC	CODE	Global
$ERR_FNF . . . . . . . . . . . .	L NEAR 	0310	CODE	Global
$ERR_FOV . . . . . . . . . . . .	L NEAR 	0307	CODE	Global
$ERR_FWP . . . . . . . . . . . .	L NEAR 	032E	CODE	Global
$ERR_IFN . . . . . . . . . . . .	L NEAR 	030D	CODE	Global
$ERR_INT . . . . . . . . . . . .	L NEAR 	030A	CODE	Global
$ERR_IOE . . . . . . . . . . . .	L NEAR 	0319	CODE	Global
$ERR_OD. . . . . . . . . . . . .	L NEAR 	02E9	CODE	Global
$ERR_OM. . . . . . . . . . . . .	L NEAR 	02F2	CODE	Global
$ERR_OS. . . . . . . . . . . . .	L NEAR 	02FE	CODE	Global
$ERR_OV. . . . . . . . . . . . .	L NEAR 	02EF	CODE	Global
$ERR_RE. . . . . . . . . . . . .	L NEAR 	0304	CODE	Global
$ERR_RG. . . . . . . . . . . . .	L NEAR 	02E6	CODE	Global
$ERR_RPE . . . . . . . . . . . .	L NEAR 	0322	CODE	Global
$ERR_SN. . . . . . . . . . . . .	L NEAR 	02E3	CODE	Global
$ERR_ST. . . . . . . . . . . . .	L NEAR 	0301	CODE	Global
$ERR_TM. . . . . . . . . . . . .	L NEAR 	02FB	CODE	Global
$ERR_TMF . . . . . . . . . . . .	L NEAR 	032B	CODE	Global
$FAC . . . . . . . . . . . . . .	L BYTE 	001D	DATA	Global
$FILPT . . . . . . . . . . . . .	L WORD 	0030	DATA	Global
$FOE . . . . . . . . . . . . . .	L NEAR 	0339	CODE	Global
$FREPT . . . . . . . . . . . . .	L WORD 	002E	DATA	Global
$FSERR . . . . . . . . . . . . .	L NEAR 	0439	CODE	Global
$GETAD . . . . . . . . . . . . .	L NEAR 	0269	CODE	Global
$INI0. . . . . . . . . . . . . .	F PROC	01FB	CODE	Global	Length =006E
$INIDEV. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$IOINI . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$MAINBASE. . . . . . . . . . . .	L WORD 	0024	DATA	Global
$NUL . . . . . . . . . . . . . .	L NEAR 	025D	CODE	Global
$OSEXT . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$OVFL. . . . . . . . . . . . . .	L NEAR 	0294	CODE	Global
$OVRF_INT. . . . . . . . . . . .	L NEAR 	0280	CODE	Global
$PTRFIL. . . . . . . . . . . . .	L WORD 	0032	DATA	Global
$RET . . . . . . . . . . . . . .	L NEAR 	025D	CODE	Global
$RTE . . . . . . . . . . . . . .	L NEAR 	0339	CODE	Global


GOSTOP - Initialization, STOP, END, and error processing         Macro-86 %1(12)   1:1:43  13-Nov-81    Symbols-4



$SEG . . . . . . . . . . . . . .	L WORD 	0000	DATA	Global
$STP . . . . . . . . . . . . . .	L NEAR 	0373	CODE	Global
$TRACE_SW. . . . . . . . . . . .	L BYTE 	003A	DATA	Global
$TYPTX . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TYPUI . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TYTX. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$USR . . . . . . . . . . . . . .	L WORD 	0002	DATA	Global	Length =000A
$USRA. . . . . . . . . . . . . .	L NEAR 	0263	CODE	Global
_CPM_. . . . . . . . . . . . . .	Number	0000	
_IBM_. . . . . . . . . . . . . .	Number	0000	
_MSDOS_. . . . . . . . . . . . .	Number	0001	
__PCHR . . . . . . . . . . . . .	Number	0072	

Warning Severe
Errors	Errors 
0	0








































