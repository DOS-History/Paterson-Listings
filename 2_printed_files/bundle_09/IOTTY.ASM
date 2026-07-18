IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   IOTTY  - Console driver for BASCOM-86
    2	 	 	 	 	
    3	 	 	 	 	
    4	                             C	        INCLUDE TABMAC.INC
    5	                             C	;       Special Table Generation Macros
    6	                             C	
    7	                             C	ENTORG  MACRO   First_entry
    8	                             C	        .XCREF
    9	                             C	___ZZZ=         First_entry
   10	                             C	        .CREF
   11	                             C	        ENDM
   12	                             C	
   13	                             C	
   14	                             C	ENT     MACRO   Lab,Incr
   15	                             C	Lab=            ___ZZZ
   16	                             C	        .XCREF
   17	                             C	___ZZZ=         ___ZZZ+Incr
   18	                             C	        .CREF
   19	                             C	        ENDM
   20	                             C	
   21	                             C	
   22	                             C	ENTI    MACRO   Incr
   23	                             C	        .XCREF
   24	                             C	___ZZZ=         ___ZZZ+Incr
   25	                             C	        .CREF
   26	                             C	        ENDM
   27	                             C	
   28	 	 	 	 	
   29	                             C	        INCLUDE DEVDEF.INC



























IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 1-2



   30	                             C	        PAGE
   31	                             C	
   32	                             C	;       DEVDEF.INC - Device Independent I/O Definitions
   33	                             C	
   34	                             C	        INCLUDE SYSTEM.INC
   35	                             C	;       Operating System Selection
   36	                             C	
   37	 = 0000                      C	_IBM_=                  0
   38	                             C	
   39	 = 0001                      C	_MSDOS_=                1
   40	 = 0000                      C	_CPM_=                  0
   41	                             C	
   42	                             C	;       Overrides
   43	                             C	
   44	 = 0001                      C	_MSDOS_=                _MSDOS_ or _IBM_
   45	                             C	
   46	                             C	if1
   47	                             C	if      _CPM_
   48	                             C	        %OUT    !   CP/M-86 Version
   49	                             C	endif
   50	                             C	if      _MSDOS_
   51	                             C	        %OUT    !   MSDOS Version
   52	                             C	endif
   53	                             C	if      _IBM_
   54	                             C	        %OUT    !     IBM Personal Computer
   55	                             C	endif
   56	                             C	
   57	                             C	if      _MSDOS_+_CPM_ ne 1
   58	                             C	        %OUT    #####################  Error - Bad Operating System Selection
   59	                             C	
   60	                             C	        error
   61	                             C	endif
   62	                             C	endif
   63	                             C	






















IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 1-3



   64	                             C	        PAGE
   65	                             C	
   66	                             C	DEVNAM  MACRO
   67	                             C	        DEVMAC  KYBD
   68	                             C	        DEVMAC  SCRN
   69	                             C	if      _IBM_
   70	                             C	        DEVMAC  CAS1
   71	                             C	        DEVMAC  COM1
   72	                             C	        DEVMAC  COM2
   73	                             C	endif
   74	                             C	        DEVMAC  LPT1
   75	                             C	if      _IBM_
   76	                             C	        DEVMAC  LPT2
   77	                             C	        DEVMAC  LPT3
   78	                             C	endif
   79	                             C	        ENDM
   80	                             C	
   81	 = FFFF                      C	___DEV=         -1
   82	                             C	
   83	                             C	DEVMAC  MACRO   ARG
   84	                             C	DN_&ARG=        ___DEV
   85	                             C	.xcref
   86	                             C	___DEV=         ___DEV-1
   87	                             C	.cref
   88	                             C	        ENDM
   89	                             C	
   90	                             C	        DEVNAM
   91	                             C	
   92	 = 0008                      C	LAST_DEVICE_OFFSET=     -2*___DEV       ;All devices have lower offsets



























IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 1-4



   93	                             C	        PAGE
   94	                             C	
   95	                             C	DSPNAM  MACRO
   96	                             C	        DSPMAC  EOF                     ;EOF function
   97	                             C	        DSPMAC  LOC                     ;LOC function
   98	                             C	        DSPMAC  LOF                     ;LOF function
   99	                             C	;       DSPMAC  POS                     ;POS function
  100	                             C	        DSPMAC  CLOSE                   ;CLOSE statement
  101	                             C	        DSPMAC  WIDTH                   ;WIDTH statement
  102	                             C	        DSPMAC  RANDIO                  ;GET/PUT statements
  103	                             C	        DSPMAC  OPEN                    ;OPEN statement
  104	                             C	        DSPMAC  BAKC                    ;Backup character
  105	                             C	        DSPMAC  SINP                    ;Serial input
  106	                             C	        DSPMAC  SOUT                    ;Serial output
  107	                             C	        DSPMAC  GPOS                    ;Get current position
  108	                             C	        DSPMAC  GWID                    ;Get current width
  109	                             C	        ENDM
  110	                             C	
  111	                             C	
  112	                             C	;       Device Function Dispatch Table Offsets
  113	                             C	
  114	                             C	
  115	                             C	DSPMAC  MACRO   func
  116	                             C	ENT     DV_&func,2
  117	                             C	        ENDM
  118	                             C	
  119	                             C	
  120	                             C	ENTORG  0
  121	                             C	        DSPNAM
  122	                             C	ENT     DV_TABLEN,0
  123	                             C	

























IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 1-5



  124	                             C	        PAGE
  125	                             C	
  126	                             C	;       File Mode Definitions
  127	                             C	
  128	 = 0001                      C	MD_SQI          EQU     1
  129	 = 0002                      C	MD_SQO          EQU     2
  130	 = 0004                      C	MD_RND          EQU     4
  131	 = 0004                      C	MD_FIL          EQU     4
  132	 = 0008                      C	MD_APP          EQU     8
  133	 = 0010                      C	MD_KIL          EQU     16
  134	 = 0020                      C	MD_IBM          EQU     32
  135	 = 0040                      C	MD_USR          EQU     64
  136	 = 0080                      C	MD_BIN          EQU     128
  137	                             C	
  138	                             C	
  139	                             C	;       Operating System dependent field sizes
  140	                             C	
  141	 = 001A                      C	EOFCHR=                 'Z' and 1fh
  142	                             C	
  143	 = 0026                      C	FILNAML=                38              ;Length of $FILNAM
  144	 = 000B                      C	FILNAM_LENGTH=          11              ;Actual length of name (8+3)
  145	                             C	
  146	 = 0026                      C	FCB_LENGTH=             38              ;38 byte FCBs
  147	 = 0080                      C	REC_LENGTH=             128             ;128 byte sectors
  148	                             C	































IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 1-6



  149	                             C	        PAGE
  150	                             C	
  151	                             C	;-----  Basic Interpreter style File Data Block  -----
  152	                             C	
  153	                             C	;       Link block offsets
  154	                             C	
  155	 =-0006                      C	BL_SIZE=        -6                      ;Link block size (2 bytes of misc)
  156	 =-0005                      C	  FB_NUM=       -5                      ;  File number
  157	 =-0004                      C	BL_LEN=         -4                      ;Block size
  158	 =-0002                      C	BL_LNK=         -2                      ;Block link
  159	                             C	
  160	                             C	;       File Data Block offsets
  161	                             C	
  162	                             C	FILE_DATA_BLOCK STRUC
  163	                             C	
  164	 0000  ??                    C	  FD_MODE       DB      ?               ;File mode of open
  165	 0001     26 [               C	  FD_FCB        DB      FCB_LENGTH DUP (?)  ;FCB area
  166	                ??           C	
  167	                    ]        C	
  168	                             C	
  169	 0027  ????                  C	  FD_CURLOC     DW      ?               ;Current record number
  170	 0029  ??                    C	  FD_ORNOFS     DB      ?               ;Byte count in sector
  171	 002A  ??                    C	  FD_NMLOFS     DB      ?               ;Bytes left in input buffer
  172	 002B     03 [               C	                DB      3 DUP (?)       ;Unused
  173	                ??           C	
  174	                    ]        C	
  175	                             C	
  176	 002E  ??                    C	  FD_DEVICE     DB      ?               ;Device number
  177	 002F  ??                    C	  FD_WIDTH      DB      ?               ;File width
  178	 0030  ??                    C	  FD_POS        DB      ?               ;Current file position
  179	 0031  ??                    C	  FD_FLAGS      DB      ?               ;Used for load and save
  180	 0032  ??                    C	  FD_OUTPOS     DB      ?               ;Output position for tab expansion
  181	 0033     80 [               C	  FD_BUFFER     DB      REC_LENGTH DUP (?)  ;File record buffer
  182	                ??           C	
  183	                    ]        C	
  184	                             C	
  185	                             C	
  186	                             C	;       5.0 Variable Record Information
  187	                             C	
  188	 00B3  ????                  C	  FR_VRECL      DW      ?               ;Variable record length
  189	 00B5  ????                  C	  FR_PHYREC     DW      ?               ;Current physical record number
  190	 00B7  ????                  C	  FR_LOGREC     DW      ?               ;Current logical record number
  191	 00B9  ??                    C	                DB      ?               ;Future use
  192	 00BA  ????                  C	  FR_OUTPOS     DW      ?               ;Output position for sequential I/O
  193	 00BC     01 [               C	  FR_FIELD      DB      1 DUP (?)       ;Field buffer
  194	                ??           C	
  195	                    ]        C	
  196	                             C	
  197	                             C	
  198	 00BD                        C	FILE_DATA_BLOCK ENDS
  199	                             C	
  200	                             C	
  201	                             C	;       End of DEVDEF.INC
  202	 	 	 	 	


IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 1-7



  203	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
  204	 	 	 	 	
  205	 	 	 	 	        EXTRN   $FILMOD:BYTE
  206	 	 	 	 	
  207	 0000	 	 	 	DATA    ENDS
  208	 	 	 	 	
  209	 	 	 	 	
  210	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
  211	 	 	 	 	
  212	 	 	 	 	        EXTRN   $TTYWID:BYTE
  213	 	 	 	 	
  214	 0000  00	 	 	TTY_BAKCHR      DB      0
  215	 0001  00	 	 	TTY_BAKFLG      DB      0               ;Initially no character
  216	 	 	 	 	
  217	 0002	 	 	 	CONST   ENDS
  218	 	 	 	 	
  219	 	 	 	 	DC      GROUP   CONST,DATA







































IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 2-1



  220	 	 	 	 	
  221	 	 	 	 	
  222	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
  223	 	 	 	 	
  224	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
  225	 	 	 	 	
  226	 	 	 	 	;       Run-time entries
  227	 	 	 	 	
  228	 	 	 	 	        PUBLIC  $WID,$POS
  229	 	 	 	 	        PUBLIC  $D_KYBD,$I_KYBD,$C_KYBD,$W_KYBD
  230	 	 	 	 	        PUBLIC  $D_SCRN,$I_SCRN,$C_SCRN,$W_SCRN
  231	 	 	 	 	        PUBLIC  $TTY_BAKC,$TTY_SINP,$TTY_SOUT,$TTY_GPOS,$TTY_GWID
  232	 	 	 	 	
  233	 	 	 	 	;       Run-time externals
  234	 	 	 	 	
  235	 	 	 	 	        EXTRN   $TTYIN:NEAR,$TTYOT:NEAR,$LTTYPS:NEAR,$STTYPS:NEAR
  236	 	 	 	 	        EXTRN   $$WCH:NEAR,$$WCLF:NEAR
  237	 	 	 	 	        EXTRN   $DEVOPN:NEAR,$FRCSQO:NEAR
  238	 	 	 	 	        EXTRN   $FBDEA:NEAR
  239	 	 	 	 	        EXTRN   $ERC_FC:NEAR
  240	 	 	 	 	IF _IBM_
  241	 	 	 	 	        EXTRN   $SCNWID:NEAR
  242	 	 	 	 	ENDIF
  243	 	 	 	 	
  244	 	 	 	 	
  245	 	 	 	 	;       Illegal Device Functions
  246	 	 	 	 	
  247	 =	 	 	 	KYBD_EOF        EQU     $ERC_FC
  248	 =	 	 	 	KYBD_LOC        EQU     $ERC_FC
  249	 =	 	 	 	KYBD_LOF        EQU     $ERC_FC
  250	 =	 	 	 	KYBD_WIDTH      EQU     $ERC_FC
  251	 =	 	 	 	KYBD_RANDIO     EQU     $ERC_FC
  252	 =	 	 	 	KYBD_SOUT       EQU     $ERC_FC
  253	 =	 	 	 	KYBD_GPOS       EQU     $ERC_FC
  254	 =	 	 	 	KYBD_GWID       EQU     $ERC_FC
  255	 	 	 	 	
  256	 =	 	 	 	SCRN_EOF        EQU     $ERC_FC
  257	 =	 	 	 	SCRN_LOC        EQU     $ERC_FC
  258	 =	 	 	 	SCRN_LOF        EQU     $ERC_FC
  259	 =	 	 	 	SCRN_RANDIO     EQU     $ERC_FC
  260	 =	 	 	 	SCRN_BAKC       EQU     $ERC_FC
  261	 =	 	 	 	SCRN_SINP       EQU     $ERC_FC
  262	 	 	 	 	
  263	 	 	 	 	
  264	 	 	 	 	;       Devide Independent Console Interface
  265	 	 	 	 	
  266	 	 	 	 	DSPMAC  MACRO   func
  267	 	 	 	 	        DW      SCRN_&func
  268	 	 	 	 	        ENDM
  269	 	 	 	 	
  270	 0000	 	 	 	$D_SCRN:
  271	 	 	 	 	        DSPNAM
  272	 0000  0000 E                 +	        DW      SCRN_EOF
  273	 0002  0000 E                 +	        DW      SCRN_LOC


IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 2-2



  274	 0004  0000 E                 +	        DW      SCRN_LOF
  275	 0006  00DE R                 +	        DW      SCRN_CLOSE
  276	 0008  007C R                 +	        DW      SCRN_WIDTH
  277	 000A  0000 E                 +	        DW      SCRN_RANDIO
  278	 000C  006C R                 +	        DW      SCRN_OPEN
  279	 000E  0000 E                 +	        DW      SCRN_BAKC
  280	 0010  0000 E                 +	        DW      SCRN_SINP
  281	 0012  0081 R                 +	        DW      SCRN_SOUT
  282	 0014  00D6 R                 +	        DW      SCRN_GPOS
  283	 0016  00D9 R                 +	        DW      SCRN_GWID
  284	 	 	 	 	
  285	 	 	 	 	
  286	 	 	 	 	DSPMAC  MACRO   func
  287	 	 	 	 	        DW      KYBD_&func
  288	 	 	 	 	        ENDM
  289	 	 	 	 	
  290	 0018	 	 	 	$D_KYBD:
  291	 	 	 	 	        DSPNAM
  292	 0018  0000 E                 +	        DW      KYBD_EOF
  293	 001A  0000 E                 +	        DW      KYBD_LOC
  294	 001C  0000 E                 +	        DW      KYBD_LOF
  295	 001E  00DE R                 +	        DW      KYBD_CLOSE
  296	 0020  0000 E                 +	        DW      KYBD_WIDTH
  297	 0022  0000 E                 +	        DW      KYBD_RANDIO
  298	 0024  0034 R                 +	        DW      KYBD_OPEN
  299	 0026  0063 R                 +	        DW      KYBD_BAKC
  300	 0028  004D R                 +	        DW      KYBD_SINP
  301	 002A  0000 E                 +	        DW      KYBD_SOUT
  302	 002C  0000 E                 +	        DW      KYBD_GPOS
  303	 002E  0000 E                 +	        DW      KYBD_GWID
  304	 	 	 	 	

























IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 2-3



  305	 	 	 	 	        PAGE
  306	 	 	 	 	
  307	 0030	 	 	 	devio   PROC    NEAR
  308	 	 	 	 	
  309	 	 	 	 	;       Keyboard routines
  310	 	 	 	 	
  311	 0030	 	 	 	$I_KYBD:
  312	 0030	 	 	 	$I_SCRN:
  313	 0030	 	 	 	$C_KYBD:
  314	 0030	 	 	 	$C_SCRN:
  315	 0030  C3	 	 	        RET
  316	 	 	 	 	
  317	 0031	 	 	 	$W_KYBD:
  318	 0031  E9 0000 E	 	        JMP     KYBD_WIDTH
  319	 	 	 	 	
  320	 	 	 	 	
  321	 0034	 	 	 	KYBD_OPEN:
  322	 0034  51	 	 	        PUSH    CX
  323	 0035  52	 	 	        PUSH    DX
  324	 0036  53	 	 	        PUSH    BX
  325	 0037  33 C9	 	 	        XOR     CX,CX                   ;(CX) = extra FDB size
  326	 0039  88 0E 0001 R	 	        MOV     [TTY_BAKFLG],CL         ;Clear keyboard backup flag
  327	 003D  33 D2	 	 	        XOR     DX,DX                   ;(DX) = (position,width)
  328	 003F  B4 01	 	 	        MOV     AH,MD_SQI               ;Valid open modes
  329	 	 	 	 	
  330	 0041  E8 0000 E	 	opndev: CALL    $DEVOPN                 ;Common routine
  331	 0044  A0 0000 E	 	        MOV     AL,[$FILMOD]
  332	 0047  88 04	 	 	        MOV     [SI].FD_MODE,AL         ;Set file mode
  333	 0049  5B	 	 	        POP     BX
  334	 004A  5A	 	 	        POP     DX
  335	 004B  59	 	 	        POP     CX
  336	 004C  C3	 	 	        RET
  337	 	 	 	 	
  338	 	 	 	 	
  339	 004D	 	 	 	$TTY_SINP:
  340	 004D	 	 	 	KYBD_SINP:
  341	 004D  80 3E 0001 R 00	 	        CMP     [TTY_BAKFLG],0
  342	 0052  74 0A	 	 	        JE      keyin
  343	 	 	 	 	
  344	 0054  C6 06 0001 R 00	 	        MOV     [TTY_BAKFLG],0
  345	 0059  A0 0000 R	 	        MOV     AL,[TTY_BAKCHR]
  346	 005C  F8	 	 	        CLC
  347	 005D  C3	 	 	        RET
  348	 	 	 	 	
  349	 005E  E8 0000 E	 	keyin:  CALL    $TTYIN                  ;Get character
  350	 0061  F8	 	 	        CLC                             ;Clear carry
  351	 0062  C3	 	 	        RET
  352	 	 	 	 	
  353	 	 	 	 	
  354	 0063	 	 	 	$TTY_BAKC:
  355	 0063	 	 	 	KYBD_BAKC:
  356	 0063  C6 06 0001 R 01	 	        MOV     [TTY_BAKFLG],1          ;Set flag
  357	 0068  A2 0000 R	 	        MOV     [TTY_BAKCHR],AL
  358	 006B  C3	 	 	        RET


IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 2-4



  359	 	 	 	 	























































IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 2-5



  360	 	 	 	 	        PAGE
  361	 	 	 	 	
  362	 	 	 	 	;       Screen routines
  363	 	 	 	 	
  364	 006C	 	 	 	SCRN_OPEN:
  365	 006C  E8 0000 E	 	        CALL    $FRCSQO                 ;Force sequential output
  366	 006F  51	 	 	        PUSH    CX
  367	 0070  52	 	 	        PUSH    DX
  368	 0071  53	 	 	        PUSH    BX
  369	 0072  33 C9	 	 	        XOR     CX,CX                   ;(CX) = extra FDB size
  370	 0074  8A 16 0000 E	 	        MOV     DL,[$TTYWID]            ;(DL) = position(ignored),width
  371	 0078  B4 02	 	 	        MOV     AH,MD_SQO               ;Set legal modes
  372	 007A  EB C5	 	 	        JMP     opndev                  ;Go to common routine
  373	 	 	 	 	
  374	 	 	 	 	
  375	 007C	 	 	 	$W_SCRN:
  376	 007C	 	 	 	SCRN_WIDTH:
  377	 	 	 	 	if      _IBM_
  378	 	 	 	 	        XCHG    DX,BX                   ;Switch for common call
  379	 	 	 	 	        CALL    $SCNWID                 ;Special for IBM
  380	 	 	 	 	        XCHG    DX,BX                   ;Switch back
  381	 	 	 	 	else
  382	 007C  88 16 0000 E	 	        MOV     [$TTYWID],DL
  383	 	 	 	 	endif
  384	 0080  C3	 	 	        RET
  385	 	 	 	 	
  386	 	 	 	 	
  387	 = 0008	 	 	 	BS=             8                       ;Backspace
  388	 = 0009	 	 	 	TAB=            9                       ;Tab
  389	 = 000D	 	 	 	CR=             13                      ;Carriage return
  390	 	 	 	 	
  391	 0081	 	 	 	$TTY_SOUT:
  392	 0081	 	 	 	SCRN_SOUT:
  393	 0081  32 E4	 	 	        XOR     AH,AH
  394	 0083  3C 0D	 	 	        CMP     AL,CR                   ;Check for CR
  395	 0085  74 49	 	 	        JE      wch50
  396	 	 	 	 	
  397	 0087  3C 08	 	 	        CMP     AL,BS                   ;Check for backspace
  398	 0089  75 0E	 	 	        JNE     wch10
  399	 	 	 	 	
  400	 008B  E8 0000 E	 	        CALL    $LTTYPS                 ;(AH) = position
  401	 008E  0A E4	 	 	        OR      AH,AH
  402	 0090  74 02	 	 	        JZ      wch05                   ;  Already in 1st column
  403	 0092  FE CC	 	 	        DEC     AH                      ;Decrement column position
  404	 0094  E8 0000 E	 	wch05:  CALL    $STTYPS                 ;Save new position
  405	 0097  EB 3A	 	 	        JMP     SHORT wch               ;Output character
  406	 	 	 	 	
  407	 0099  3C 09	 	 	wch10:  CMP     AL,TAB                  ;Check for tab
  408	 009B  75 15	 	 	        JNE     wch20
  409	 	 	 	 	
  410	 009D  B0 20	 	 	wch11:  MOV     AL,' '
  411	 009F  E8 0000 E	 	        CALL    $$WCH                   ;Recursively tab
  412	 00A2  E8 0000 E	 	        CALL    $LTTYPS                 ;(AH) = position
  413	 00A5  80 FC FF	 	 	        CMP     AH,255


IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 2-6



  414	 00A8  74 05	 	 	        JE      wch15                   ;Stop counting at 255
  415	 00AA  80 E4 07	 	 	        AND     AH,7
  416	 00AD  75 EE	 	 	        JNZ     wch11                   ;More spacing to next column
  417	 	 	 	 	
  418	 00AF  B0 09	 	 	wch15:  MOV     AL,TAB                  ;Restore tab character
  419	 00B1  C3	 	 	        RET
  420	 	 	 	 	
  421	 00B2  3C 20	 	 	wch20:  CMP     AL,' '                  ;Check for printing character
  422	 00B4  72 1D	 	 	        JB      wch                     ;  Not printing
  423	 	 	 	 	
  424	 00B6  E8 0000 E	 	        CALL    $LTTYPS
  425	 00B9  80 3E 0000 E FF	 	        CMP     $TTYWID,255             ;Check for infinite width
  426	 00BE  74 09	 	 	        JE      wch25
  427	 	 	 	 	
  428	 00C0  3A 26 0000 E	 	        CMP     AH,$TTYWID              ;Check for last column
  429	 00C4  75 03	 	 	        JNE     wch25
  430	 	 	 	 	
  431	 00C6  E8 0000 E	 	        CALL    $$WCLF                  ;Yes - write CR/LF
  432	 	 	 	 	
  433	 00C9  80 FC FF	 	 	wch25:  CMP     AH,255                  ;Stop counting at 255
  434	 00CC  74 05	 	 	        JE      wch
  435	 	 	 	 	
  436	 00CE  FE C4	 	 	        INC     AH                      ;Bump position
  437	 	 	 	 	
  438	 00D0  E8 0000 E	 	wch50:  CALL    $STTYPS                 ;Set position
  439	 	 	 	 	
  440	 00D3  E9 0000 E	 	wch:    JMP     $TTYOT
  441	 	 	 	 	
  442	 	 	 	 	
  443	 00D6	 	 	 	$TTY_GPOS:
  444	 00D6	 	 	 	SCRN_GPOS:
  445	 00D6  E9 0000 E	 	        JMP     $LTTYPS                 ;Get console position
  446	 	 	 	 	
  447	 	 	 	 	
  448	 00D9	 	 	 	$TTY_GWID:
  449	 00D9	 	 	 	SCRN_GWID:
  450	 00D9  8A 26 0000 E	 	        MOV     AH,$TTYWID              ;(AH) = width
  451	 00DD  C3	 	 	        RET
  452	 	 	 	 	

















IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Page 2-7



  453	 	 	 	 	        PAGE
  454	 	 	 	 	
  455	 	 	 	 	;       Device Close Routines
  456	 	 	 	 	
  457	 00DE	 	 	 	KYBD_CLOSE:
  458	 00DE	 	 	 	SCRN_CLOSE:
  459	 00DE  E8 0000 E	 	        CALL    $FBDEA                  ;Deallocate file block
  460	 00E1  C3	 	 	        RET
  461	 	 	 	 	
  462	 	 	 	 	
  463	 00E2	 	 	 	devio   ENDP
  464	 	 	 	 	
  465	 00E2	 	 	 	Entries PROC    FAR
  466	 	 	 	 	
  467	 00E2	 	 	 	$WID:
  468	 	 	 	 	if      _IBM_
  469	 	 	 	 	        CALL    $SCHWID
  470	 	 	 	 	else
  471	 00E2  88 1E 0000 E	 	        MOV     [$TTYWID],BL            ;WIDTH Statement
  472	 	 	 	 	endif
  473	 00E6  CB	 	 	        RET
  474	 	 	 	 	
  475	 	 	 	 	
  476	 00E7  50	 	 	$POS:   PUSH    AX                      ;POS Function
  477	 00E8  E8 0000 E	 	        CALL    $LTTYPS
  478	 00EB  8A DC	 	 	        MOV     BL,AH
  479	 00ED  32 FF	 	 	        XOR     BH,BH
  480	 00EF  43	 	 	        INC     BX                      ;Map Pos to Base 1
  481	 00F0  58	 	 	        POP     AX
  482	 00F1  CB	 	 	        RET
  483	 	 	 	 	
  484	 00F2	 	 	 	Entries ENDP
  485	 	 	 	 	
  486	 00F2	 	 	 	CODE    ENDS
  487	 	 	 	 	
  488	 	 	 	 	        END




















IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Symbols-1



Macros:

	 	N a m e  	 	Length

DEVMAC . . . . . . . . . . . . .	0002	
DEVNAM . . . . . . . . . . . . .	0005	
DSPMAC . . . . . . . . . . . . .	0001	
DSPNAM . . . . . . . . . . . . .	000E	
ENT. . . . . . . . . . . . . . .	0002	
ENTI . . . . . . . . . . . . . .	0002	
ENTORG . . . . . . . . . . . . .	0001	

Structures and records:

	 	N a m e	 	 	Width	# fields
	 	 	 	 	Shift	Width	Mask	Initial

FILE_DATA_BLOCK. . . . . . . . .	00BD	0012
  FD_MODE. . . . . . . . . . . . .	0000
  FD_FCB . . . . . . . . . . . . .	0001
  FD_CURLOC. . . . . . . . . . . .	0027
  FD_ORNOFS. . . . . . . . . . . .	0029
  FD_NMLOFS. . . . . . . . . . . .	002A
  FD_DEVICE. . . . . . . . . . . .	002E
  FD_WIDTH . . . . . . . . . . . .	002F
  FD_POS . . . . . . . . . . . . .	0030
  FD_FLAGS . . . . . . . . . . . .	0031
  FD_OUTPOS. . . . . . . . . . . .	0032
  FD_BUFFER. . . . . . . . . . . .	0033
  FR_VRECL . . . . . . . . . . . .	00B3
  FR_PHYREC. . . . . . . . . . . .	00B5
  FR_LOGREC. . . . . . . . . . . .	00B7
  FR_OUTPOS. . . . . . . . . . . .	00BA
  FR_FIELD . . . . . . . . . . . .	00BC

Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	00F2	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  CONST. . . . . . . . . . . . . .	0002	WORD  	PUBLIC	'CONST'
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

BL_LEN . . . . . . . . . . . . .	Number	FFFC	
BL_LNK . . . . . . . . . . . . .	Number	FFFE	
BL_SIZE. . . . . . . . . . . . .	Number	FFFA	
BS . . . . . . . . . . . . . . .	Number	0008	
CR . . . . . . . . . . . . . . .	Number	000D	
DEVIO. . . . . . . . . . . . . .	N PROC	0030	CODE	Length =00B2
DN_KYBD. . . . . . . . . . . . .	Number	FFFF	


IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Symbols-2



DN_LPT1. . . . . . . . . . . . .	Number	FFFD	
DN_SCRN. . . . . . . . . . . . .	Number	FFFE	
DV_BAKC. . . . . . . . . . . . .	Number	000E	
DV_CLOSE . . . . . . . . . . . .	Number	0006	
DV_EOF . . . . . . . . . . . . .	Number	0000	
DV_GPOS. . . . . . . . . . . . .	Number	0014	
DV_GWID. . . . . . . . . . . . .	Number	0016	
DV_LOC . . . . . . . . . . . . .	Number	0002	
DV_LOF . . . . . . . . . . . . .	Number	0004	
DV_OPEN. . . . . . . . . . . . .	Number	000C	
DV_RANDIO. . . . . . . . . . . .	Number	000A	
DV_SINP. . . . . . . . . . . . .	Number	0010	
DV_SOUT. . . . . . . . . . . . .	Number	0012	
DV_TABLEN. . . . . . . . . . . .	Number	0018	
DV_WIDTH . . . . . . . . . . . .	Number	0008	
ENTRIES. . . . . . . . . . . . .	F PROC	00E2	CODE	Length =0010
EOFCHR . . . . . . . . . . . . .	Number	001A	
FB_NUM . . . . . . . . . . . . .	Number	FFFB	
FCB_LENGTH . . . . . . . . . . .	Number	0026	
FILNAML. . . . . . . . . . . . .	Number	0026	
FILNAM_LENGTH. . . . . . . . . .	Number	000B	
KEYIN. . . . . . . . . . . . . .	L NEAR 	005E	CODE
KYBD_BAKC. . . . . . . . . . . .	L NEAR 	0063	CODE
KYBD_CLOSE . . . . . . . . . . .	L NEAR 	00DE	CODE
KYBD_EOF . . . . . . . . . . . .	Alias	$ERC_FC	 	
KYBD_GPOS. . . . . . . . . . . .	Alias	$ERC_FC	 	
KYBD_GWID. . . . . . . . . . . .	Alias	$ERC_FC	 	
KYBD_LOC . . . . . . . . . . . .	Alias	$ERC_FC	 	
KYBD_LOF . . . . . . . . . . . .	Alias	$ERC_FC	 	
KYBD_OPEN. . . . . . . . . . . .	L NEAR 	0034	CODE
KYBD_RANDIO. . . . . . . . . . .	Alias	$ERC_FC	 	
KYBD_SINP. . . . . . . . . . . .	L NEAR 	004D	CODE
KYBD_SOUT. . . . . . . . . . . .	Alias	$ERC_FC	 	
KYBD_WIDTH . . . . . . . . . . .	Alias	$ERC_FC	 	
LAST_DEVICE_OFFSET . . . . . . .	Number	0008	
MD_APP . . . . . . . . . . . . .	Number	0008	
MD_BIN . . . . . . . . . . . . .	Number	0080	
MD_FIL . . . . . . . . . . . . .	Number	0004	
MD_IBM . . . . . . . . . . . . .	Number	0020	
MD_KIL . . . . . . . . . . . . .	Number	0010	
MD_RND . . . . . . . . . . . . .	Number	0004	
MD_SQI . . . . . . . . . . . . .	Number	0001	
MD_SQO . . . . . . . . . . . . .	Number	0002	
MD_USR . . . . . . . . . . . . .	Number	0040	
OPNDEV . . . . . . . . . . . . .	L NEAR 	0041	CODE
REC_LENGTH . . . . . . . . . . .	Number	0080	
SCRN_BAKC. . . . . . . . . . . .	Alias	$ERC_FC	 	
SCRN_CLOSE . . . . . . . . . . .	L NEAR 	00DE	CODE
SCRN_EOF . . . . . . . . . . . .	Alias	$ERC_FC	 	
SCRN_GPOS. . . . . . . . . . . .	L NEAR 	00D6	CODE
SCRN_GWID. . . . . . . . . . . .	L NEAR 	00D9	CODE
SCRN_LOC . . . . . . . . . . . .	Alias	$ERC_FC	 	
SCRN_LOF . . . . . . . . . . . .	Alias	$ERC_FC	 	
SCRN_OPEN. . . . . . . . . . . .	L NEAR 	006C	CODE


IOTTY  - Console driver for BASCOM-86                    Macro-86 %1(12)   1:5:45  13-Nov-81    Symbols-3



SCRN_RANDIO. . . . . . . . . . .	Alias	$ERC_FC	 	
SCRN_SINP. . . . . . . . . . . .	Alias	$ERC_FC	 	
SCRN_SOUT. . . . . . . . . . . .	L NEAR 	0081	CODE
SCRN_WIDTH . . . . . . . . . . .	L NEAR 	007C	CODE
TAB. . . . . . . . . . . . . . .	Number	0009	
TTY_BAKCHR . . . . . . . . . . .	L BYTE 	0000	CONST
TTY_BAKFLG . . . . . . . . . . .	L BYTE 	0001	CONST
WCH. . . . . . . . . . . . . . .	L NEAR 	00D3	CODE
WCH05. . . . . . . . . . . . . .	L NEAR 	0094	CODE
WCH10. . . . . . . . . . . . . .	L NEAR 	0099	CODE
WCH11. . . . . . . . . . . . . .	L NEAR 	009D	CODE
WCH15. . . . . . . . . . . . . .	L NEAR 	00AF	CODE
WCH20. . . . . . . . . . . . . .	L NEAR 	00B2	CODE
WCH25. . . . . . . . . . . . . .	L NEAR 	00C9	CODE
WCH50. . . . . . . . . . . . . .	L NEAR 	00D0	CODE
$$WCH. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$WCLF . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$C_KYBD. . . . . . . . . . . . .	L NEAR 	0030	CODE	Global
$C_SCRN. . . . . . . . . . . . .	L NEAR 	0030	CODE	Global
$DEVOPN. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$D_KYBD. . . . . . . . . . . . .	L NEAR 	0018	CODE	Global
$D_SCRN. . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FBDEA . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FILMOD. . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FRCSQO. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$I_KYBD. . . . . . . . . . . . .	L NEAR 	0030	CODE	Global
$I_SCRN. . . . . . . . . . . . .	L NEAR 	0030	CODE	Global
$LTTYPS. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$POS . . . . . . . . . . . . . .	L NEAR 	00E7	CODE	Global
$STTYPS. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TTYIN . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TTYOT . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TTYWID. . . . . . . . . . . . .	V BYTE 	0000	CONST	External
$TTY_BAKC. . . . . . . . . . . .	L NEAR 	0063	CODE	Global
$TTY_GPOS. . . . . . . . . . . .	L NEAR 	00D6	CODE	Global
$TTY_GWID. . . . . . . . . . . .	L NEAR 	00D9	CODE	Global
$TTY_SINP. . . . . . . . . . . .	L NEAR 	004D	CODE	Global
$TTY_SOUT. . . . . . . . . . . .	L NEAR 	0081	CODE	Global
$WID . . . . . . . . . . . . . .	L NEAR 	00E2	CODE	Global
$W_KYBD. . . . . . . . . . . . .	L NEAR 	0031	CODE	Global
$W_SCRN. . . . . . . . . . . . .	L NEAR 	007C	CODE	Global
_CPM_. . . . . . . . . . . . . .	Number	0000	
_IBM_. . . . . . . . . . . . . .	Number	0000	
_MSDOS_. . . . . . . . . . . . .	Number	0001	
___DEV . . . . . . . . . . . . .	Number	FFFC	
___ZZZ . . . . . . . . . . . . .	Number	0018	

Warning Severe
Errors	Errors 
0	0





