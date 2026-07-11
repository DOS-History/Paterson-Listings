IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 1-1



   1	 	 	 	 	        TITLE   IODEV   - Device Independent I/O Drivers for BASCOM-86
   2	 	 	 	 	
   3	 	 	 	 	
   4	 	 	 	 	;       This module contains the device independent I/O drivers for the
   5	 	 	 	 	;       8086 BASIC Compiler runtime.
   6	 	 	 	 	
   7	 	 	 	 	
   8	                             C	        INCLUDE TABMAC.INC
   9	                             C	;       Special Table Generation Macros
   10	                             C	
   11	                             C	ENTORG  MACRO   First_entry
   12	                             C	        .XCREF
   13	                             C	___ZZZ=         First_entry
   14	                             C	        .CREF
   15	                             C	        ENDM
   16	                             C	
   17	                             C	
   18	                             C	ENT     MACRO   Lab,Incr
   19	                             C	Lab=            ___ZZZ
   20	                             C	        .XCREF
   21	                             C	___ZZZ=         ___ZZZ+Incr
   22	                             C	        .CREF
   23	                             C	        ENDM
   24	                             C	
   25	                             C	
   26	                             C	ENTI    MACRO   Incr
   27	                             C	        .XCREF
   28	                             C	___ZZZ=         ___ZZZ+Incr
   29	                             C	        .CREF
   30	                             C	        ENDM
   31	                             C	
   32	                             C	        INCLUDE DEVDEF.INC
























IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 1-2



   33	                             C	        PAGE
   34	                             C	
   35	                             C	;       DEVDEF.INC - Device Independent I/O Definitions
   36	                             C	
   37	                             C	        INCLUDE SYSTEM.INC
   38	                             C	;       Operating System Selection
   39	                             C	
   40	 = 0000                      C	_IBM_=                  0
   41	                             C	
   42	 = 0001                      C	_MSDOS_=                1
   43	 = 0000                      C	_CPM_=                  0
   44	                             C	
   45	                             C	;       Overrides
   46	                             C	
   47	 = 0001                      C	_MSDOS_=                _MSDOS_ or _IBM_
   48	                             C	
   49	                             C	if1
   50	                             C	if      _CPM_
   51	                             C	        %OUT    !   CP/M-86 Version
   52	                             C	endif
   53	                             C	if      _MSDOS_
   54	                             C	        %OUT    !   MSDOS Version
   55	                             C	endif
   56	                             C	if      _IBM_
   57	                             C	        %OUT    !     IBM Personal Computer
   58	                             C	endif
   59	                             C	
   60	                             C	if      _MSDOS_+_CPM_ ne 1
   61	                             C	        %OUT    #####################  Error - Bad Operating System Selection
   62	                             C	
   63	                             C	        error
   64	                             C	endif
   65	                             C	endif
   66	                             C	






















IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 1-3



   67	                             C	        PAGE
   68	                             C	
   69	                             C	DEVNAM  MACRO
   70	                             C	        DEVMAC  KYBD
   71	                             C	        DEVMAC  SCRN
   72	                             C	if      _IBM_
   73	                             C	        DEVMAC  CAS1
   74	                             C	        DEVMAC  COM1
   75	                             C	        DEVMAC  COM2
   76	                             C	endif
   77	                             C	        DEVMAC  LPT1
   78	                             C	if      _IBM_
   79	                             C	        DEVMAC  LPT2
   80	                             C	        DEVMAC  LPT3
   81	                             C	endif
   82	                             C	        ENDM
   83	                             C	
   84	 = FFFF                      C	___DEV=         -1
   85	                             C	
   86	                             C	DEVMAC  MACRO   ARG
   87	                             C	DN_&ARG=        ___DEV
   88	                             C	.xcref
   89	                             C	___DEV=         ___DEV-1
   90	                             C	.cref
   91	                             C	        ENDM
   92	                             C	
   93	                             C	        DEVNAM
   94	                             C	
   95	 = 0008                      C	LAST_DEVICE_OFFSET=     -2*___DEV       ;All devices have lower offsets



























IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 1-4



   96	                             C	        PAGE
   97	                             C	
   98	                             C	DSPNAM  MACRO
   99	                             C	        DSPMAC  EOF                     ;EOF function
  100	                             C	        DSPMAC  LOC                     ;LOC function
  101	                             C	        DSPMAC  LOF                     ;LOF function
  102	                             C	;       DSPMAC  POS                     ;POS function
  103	                             C	        DSPMAC  CLOSE                   ;CLOSE statement
  104	                             C	        DSPMAC  WIDTH                   ;WIDTH statement
  105	                             C	        DSPMAC  RANDIO                  ;GET/PUT statements
  106	                             C	        DSPMAC  OPEN                    ;OPEN statement
  107	                             C	        DSPMAC  BAKC                    ;Backup character
  108	                             C	        DSPMAC  SINP                    ;Serial input
  109	                             C	        DSPMAC  SOUT                    ;Serial output
  110	                             C	        DSPMAC  GPOS                    ;Get current position
  111	                             C	        DSPMAC  GWID                    ;Get current width
  112	                             C	        ENDM
  113	                             C	
  114	                             C	
  115	                             C	;       Device Function Dispatch Table Offsets
  116	                             C	
  117	                             C	
  118	                             C	DSPMAC  MACRO   func
  119	                             C	ENT     DV_&func,2
  120	                             C	        ENDM
  121	                             C	
  122	                             C	
  123	                             C	ENTORG  0
  124	                             C	        DSPNAM
  125	                             C	ENT     DV_TABLEN,0
  126	                             C	

























IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 1-5



  127	                             C	        PAGE
  128	                             C	
  129	                             C	;       File Mode Definitions
  130	                             C	
  131	 = 0001                      C	MD_SQI          EQU     1
  132	 = 0002                      C	MD_SQO          EQU     2
  133	 = 0004                      C	MD_RND          EQU     4
  134	 = 0004                      C	MD_FIL          EQU     4
  135	 = 0008                      C	MD_APP          EQU     8
  136	 = 0010                      C	MD_KIL          EQU     16
  137	 = 0020                      C	MD_IBM          EQU     32
  138	 = 0040                      C	MD_USR          EQU     64
  139	 = 0080                      C	MD_BIN          EQU     128
  140	                             C	
  141	                             C	
  142	                             C	;       Operating System dependent field sizes
  143	                             C	
  144	 = 001A                      C	EOFCHR=                 'Z' and 1fh
  145	                             C	
  146	 = 0026                      C	FILNAML=                38              ;Length of $FILNAM
  147	 = 000B                      C	FILNAM_LENGTH=          11              ;Actual length of name (8+3)
  148	                             C	
  149	 = 0026                      C	FCB_LENGTH=             38              ;38 byte FCBs
  150	 = 0080                      C	REC_LENGTH=             128             ;128 byte sectors
  151	                             C	































IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 1-6



  152	                             C	        PAGE
  153	                             C	
  154	                             C	;-----  Basic Interpreter style File Data Block  -----
  155	                             C	
  156	                             C	;       Link block offsets
  157	                             C	
  158	 = FFFA                      C	BL_SIZE=        -6                      ;Link block size (2 bytes of misc)
  159	 = FFFB                      C	  FB_NUM=       -5                      ;  File number
  160	 = FFFC                      C	BL_LEN=         -4                      ;Block size
  161	 = FFFE                      C	BL_LNK=         -2                      ;Block link
  162	                             C	
  163	                             C	;       File Data Block offsets
  164	                             C	
  165	                             C	FILE_DATA_BLOCK STRUC
  166	                             C	
  167	 0000  ??                    C	  FD_MODE       DB      ?               ;File mode of open
  168	 0001     26 [               C	  FD_FCB        DB      FCB_LENGTH DUP (?)  ;FCB area
  169	                ??           C	
  170	                    ]        C	
  171	                             C	
  172	 0027  ????                  C	  FD_CURLOC     DW      ?               ;Current record number
  173	 0029  ??                    C	  FD_ORNOFS     DB      ?               ;Byte count in sector
  174	 002A  ??                    C	  FD_NMLOFS     DB      ?               ;Bytes left in input buffer
  175	 002B     03 [               C	                DB      3 DUP (?)       ;Unused
  176	                ??           C	
  177	                    ]        C	
  178	                             C	
  179	 002E  ??                    C	  FD_DEVICE     DB      ?               ;Device number
  180	 002F  ??                    C	  FD_WIDTH      DB      ?               ;File width
  181	 0030  ??                    C	  FD_POS        DB      ?               ;Current file position
  182	 0031  ??                    C	  FD_FLAGS      DB      ?               ;Used for load and save
  183	 0032  ??                    C	  FD_OUTPOS     DB      ?               ;Output position for tab expansion
  184	 0033     80 [               C	  FD_BUFFER     DB      REC_LENGTH DUP (?)  ;File record buffer
  185	                ??           C	
  186	                    ]        C	
  187	                             C	
  188	                             C	
  189	                             C	;       5.0 Variable Record Information
  190	                             C	
  191	 00B3  ????                  C	  FR_VRECL      DW      ?               ;Variable record length
  192	 00B5  ????                  C	  FR_PHYREC     DW      ?               ;Current physical record number
  193	 00B7  ????                  C	  FR_LOGREC     DW      ?               ;Current logical record number
  194	 00B9  ??                    C	                DB      ?               ;Future use
  195	 00BA  ????                  C	  FR_OUTPOS     DW      ?               ;Output position for sequential I/O
  196	 00BC     01 [               C	  FR_FIELD      DB      1 DUP (?)       ;Field buffer
  197	                ??           C	
  198	                    ]        C	
  199	                             C	
  200	                             C	
  201	 00BD                        C	FILE_DATA_BLOCK ENDS
  202	                             C	
  203	                             C	
  204	                             C	;       End of DEVDEF.INC
  205	 	 	 	 	


IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 1-7



  206
  207	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
  208	 	 	 	 	





















































IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 1-8



  209	 	 	 	 	        PAGE
  210	 	 	 	 	
  211	 	 	 	 	;       External Data Variables
  212	 	 	 	 	
  213	 	 	 	 	        EXTRN   $PTRFIL:WORD, $FILPT:WORD
  214	 	 	 	 	        EXTRN   $$SPSV:WORD
  215	 	 	 	 	
  216	 	 	 	 	
  217	 	 	 	 	;       Local Data Definitions
  218	 	 	 	 	
  219	 0000  ????	 	 	DISPATCH_ADDR   DW      ?               ;Dispatch address
  220	 	 	 	 	
  221	 	 	 	 	
  222	 	 	 	 	;       Public Data Variables
  223	 	 	 	 	
  224	 	 	 	 	        PUBLIC  $FILNAM,$FILNM2,$FILMOD
  225	 	 	 	 	
  226	 0002     26 [	 	 	$FILNAM         DB      FILNAML DUP (?) ;1st File name buffer
  227	                ??	 	
  228	                    ]	 	
  229	 	 	 	 	
  230	 0028     26 [	 	 	$FILNM2         DB      FILNAML DUP (?) ;2nd File name buffer
  231	                ??	 	
  232	                    ]	 	
  233	 	 	 	 	
  234	 004E  ??	 	 	$FILMOD         DB      ?               ;File mode from OPEN statement
  235	 	 	 	 	
  236	 004F	 	 	 	DATA    ENDS
  237	 	 	 	 	
  238	 	 	 	 	
  239	 	 	 	 	DC      GROUP   DATA
























IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 2-1



  240	 	 	 	 	
  241	 	 	 	 	
  242	 0000	 	 	 	CODE    SEGMENT WORD PUBLIC 'CODE'
  243	 	 	 	 	
  244	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
  245	 	 	 	 	
  246	 	 	 	 	;       Compiler generated entries
  247	 	 	 	 	
  248	 	 	 	 	        PUBLIC  $EOF,$LOC,$LOF                  ;$POF
  249	 	 	 	 	        PUBLIC  $DKC,$WDF,$DKN,$DKM,$DKO,$DCA
  250	 	 	 	 	        PUBLIC  $GET,$RGT,$PUT,$RPT,$VPT
  251	 	 	 	 	        PUBLIC  $WDD
  252	 	 	 	 	
  253	 	 	 	 	;       Run-time entries
  254	 	 	 	 	
  255	 	 	 	 	        PUBLIC  $INIDEV,$CLSDEV
  256	 	 	 	 	        PUBLIC  $BAKCHR,$GETCHR,$PUTCHR,$GETPOS,$GETWID
  257	 	 	 	 	        PUBLIC  $$BCH,$$RCH,$$WCH,$$POS,$$WID
  258	 	 	 	 	        PUBLIC  $SCANF,$CLOSF,$FRCSQO,$DEVOPN
  259	 	 	 	 	        PUBLIC  $DEVICE_TABLE
  260	 	 	 	 	
  261	 	 	 	 	;       Run-time externals
  262	 	 	 	 	
  263	 	 	 	 	        EXTRN   $$DITS:NEAR
  264	 	 	 	 	        EXTRN   $ERC_BFM:NEAR
  265	 	 	 	 	        EXTRN   $ERC_BFN:NEAR
  266	 	 	 	 	        EXTRN   $ERC_DNA:NEAR
  267	 	 	 	 	        EXTRN   $ERC_FAO:NEAR
  268	 	 	 	 	        EXTRN   $ERC_IFN:NEAR
  269	 	 	 	 	
  270	 	 	 	 	        EXTRN   $FBLOC:NEAR, $FBALC:NEAR, $FBDEA:NEAR
  271	 	 	 	 	        EXTRN   $SAVREG:NEAR
  272	 	 	 	 	
  273	 	 	 	 	        EXTRN   $TTY_BAKC:NEAR
  274	 	 	 	 	        EXTRN   $TTY_SINP:NEAR
  275	 	 	 	 	        EXTRN   $TTY_SOUT:NEAR
  276	 	 	 	 	        EXTRN   $TTY_GPOS:NEAR
  277	 	 	 	 	        EXTRN   $TTY_GWID:NEAR
  278	 	 	 	 	
  279	 	 	 	 	;       Device Name Generator
  280	 	 	 	 	
  281	 	 	 	 	DEVMAC  MACRO   ARG
  282	 	 	 	 	        DB      '&ARG'
  283	 	 	 	 	        DB      DN_&ARG
  284	 	 	 	 	        ENDM
  285	 	 	 	 	
  286	 0000	 	 	 	DEVICE_NAME_TABLE       LABEL   BYTE
  287	 	 	 	 	        DEVNAM
  288	 0000  4B 59 42 44            +	        DB      'KYBD'
  289	 0004  FF                     +	        DB      DN_KYBD
  290	 0005  53 43 52 4E            +	        DB      'SCRN'
  291	 0009  FE                     +	        DB      DN_SCRN
  292	 000A  4C 50 54 31            +	        DB      'LPT1'
  293	 000E  FD                     +	        DB      DN_LPT1


IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 2-2



  294	 000F  00	 	 	        DB      0
  295	 	 	 	 	
  296	 	 	 	 	
  297	 	 	 	 	;       Device Dispatch Address Generator
  298	 	 	 	 	
  299	 	 	 	 	DEVMAC  MACRO   ARG
  300	 	 	 	 	        EXTRN   $D_&ARG:NEAR
  301	 	 	 	 	        DW      $D_&ARG
  302	 	 	 	 	        ENDM
  303	 	 	 	 	
  304	 	 	 	 	        EVEN                            ;Word align
  305	 	 	 	 	
  306	 0010	 	 	 	$DEVICE_TABLE   LABEL   WORD
  307	 	 	 	 	
  308	 	 	 	 	        DEVMAC  DISK                    ;Disks are treated as device type 0
  309	 0010  0000 E                 +	        DW      $D_DISK
  310	 	 	 	 	        DEVNAM                          ;Rest of devices
  311	 0012  0000 E                 +	        DW      $D_KYBD
  312	 0014  0000 E                 +	        DW      $D_SCRN
  313	 0016  0000 E                 +	        DW      $D_LPT1
  314	 	 	 	 	
  315	 	 	 	 	
  316	 	 	 	 	;       Device initialization dispatch address generator
  317	 	 	 	 	
  318	 	 	 	 	DEVMAC  MACRO   ARG
  319	 	 	 	 	        EXTRN   $I_&ARG:NEAR
  320	 	 	 	 	        DW      $I_&ARG
  321	 	 	 	 	        ENDM
  322	 	 	 	 	
  323	 0018	 	 	 	INIDEV_TABLE    LABEL   WORD
  324	 	 	 	 	
  325	 	 	 	 	        DEVNAM                          ;Device initialization addresses
  326	 0018  0000 E                 +	        DW      $I_KYBD
  327	 001A  0000 E                 +	        DW      $I_SCRN
  328	 001C  0000 E                 +	        DW      $I_LPT1
  329	 	 	 	 	
  330	 001E	 	 	 	INIDEV_END      LABEL   WORD            ;End of table
  331	 	 	 	 	
  332	 	 	 	 	
  333	 	 	 	 	;       Device close dispatch address generator
  334	 	 	 	 	
  335	 	 	 	 	DEVMAC  MACRO   ARG
  336	 	 	 	 	        EXTRN   $C_&ARG:NEAR
  337	 	 	 	 	        DW      $C_&ARG
  338	 	 	 	 	        ENDM
  339	 	 	 	 	
  340	 001E	 	 	 	CLSDEV_TABLE    LABEL   WORD
  341	 	 	 	 	
  342	 	 	 	 	        DEVNAM                          ;Device close addresses
  343	 001E  0000 E                 +	        DW      $C_KYBD
  344	 0020  0000 E                 +	        DW      $C_SCRN
  345	 0022  0000 E                 +	        DW      $C_LPT1
  346	 	 	 	 	
  347	 0024	 	 	 	CLSDEV_END      LABEL   WORD            ;End of table


IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 2-3



  348	 	 	 	 	
  349	 	 	 	 	
  350	 	 	 	 	;       Device width set dispatch address generator
  351	 	 	 	 	;
  352	 	 	 	 	;       Routine calling sequence:
  353	 	 	 	 	;
  354	 	 	 	 	;               Entry   (DX) = width
  355	 	 	 	 	
  356	 	 	 	 	DEVMAC  MACRO   ARG
  357	 	 	 	 	        EXTRN   $W_&ARG:NEAR
  358	 	 	 	 	        DW      $W_&ARG
  359	 	 	 	 	        ENDM
  360	 	 	 	 	
  361	 0024	 	 	 	WIDTH_TABLE     LABEL   WORD
  362	 	 	 	 	
  363	 	 	 	 	        DEVNAM                          ;Width set addresses
  364	 0024  0000 E                 +	        DW      $W_KYBD
  365	 0026  0000 E                 +	        DW      $W_SCRN
  366	 0028  0000 E                 +	        DW      $W_LPT1
  367	 	 	 	 	




































IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 3-1



  368	 	 	 	 	
  369	 	 	 	 	
  370	 	 	 	 	        SUBTTL  Compiler Generated Entry Points
  371	 	 	 	 	
  372	 	 	 	 	
  373	 	 	 	 	;**     WIDTH "device" Statement
  374	 	 	 	 	;
  375	 	 	 	 	;       ENTRY    (BX) = device name string
  376	 	 	 	 	;                (DX) = width
  377	 	 	 	 	
  378	 002A  E8 0000 E	 	$WDD:   CALL     $SAVREG
  379	 002D  8B 0F	 	 	        MOV      CX,[BX]                 ;(CX) = length
  380	 002F  8B 77 02	 	 	        MOV      SI,[BX+2]               ;(SI) = address
  381	 0032  E8 0250 R	 	        CALL     PARSE_DEVICE            ;(AL) = device
  382	 0035  0A C0	 	 	        OR       AL,AL                   ;Test for no device
  383	 0037  75 03	 	 	        JNZ      wdd1
  384	 0039  E9 0000 E	 	        JMP      $ERC_BFN                ;Error - bad file name
  385	 003C  E8 0000 E	 	wdd1:   CALL     $$DITS                  ;Delete if temporary string
  386	 003F  F6 D0	 	 	        NOT      AL                      ;Convert to 0 and up
  387	 0041  98	 	 	        CBW
  388	 0042  D1 E0	 	 	        SAL      AX,1                    ;2 * (NOT device#)
  389	 0044  97	 	 	        XCHG     AX,DI                   ;(DI) = offset
  390	 0045  2E: FF A5 0024 R	 	        JMP      CS:WIDTH_TABLE[DI]      ;Call width set routine - (DX) = width
  391	 	 	 	 	
  392	 	 	 	 	
  393	 004A	 	 	 	Entries PROC     FAR
  394	 	 	 	 	
  395	 	 	 	 	;**     VARPTR()  Functoin
  396	 	 	 	 	;
  397	 	 	 	 	;       ENTRY    (BX) = file number
  398	 	 	 	 	;       EXIT     (BX) = address of file data block
  399	 	 	 	 	;       USES     BX
  400	 	 	 	 	
  401	 004A  89 26 0000 E	 	$VPT:   MOV      [$$SPSV],SP
  402	 004E  56	 	 	        PUSH     SI
  403	 004F  E8 0000 E	 	        CALL     $FBLOC                  ;Find file block
  404	 0052  75 03	 	 	        JNZ      vpt1
  405	 0054  E9 0138 R	 	        JMP      ercifn                  ;Error - illegal file number
  406	 0057  8B DE	 	 	vpt1:   MOV      BX,SI                   ;Put address in (BX)
  407	 0059  5E	 	 	        POP      SI
  408	 005A  CB	 	 	        RET
  409	 	 	 	 	
  410	 	 	 	 	
  411	 	 	 	 	
  412	 	 	 	 	;**     EOF() Function
  413	 	 	 	 	;
  414	 	 	 	 	;       ENTRY   (BX) = file number
  415	 	 	 	 	;       EXIT    (BX) = 0 or -1 if end of file
  416	 	 	 	 	;       USES    BX
  417	 	 	 	 	
  418	 005B  50	 	 	$EOF:   PUSH    AX
  419	 005C  B4 00	 	 	        MOV     AH,DV_EOF               ;End of file function
  420	 	 	 	 	
  421	 005E  89 26 0000 E	 	comdsp: MOV     [$$SPSV],SP


IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 3-2
Compiler Generated Entry Points


  422	 0062  83 06 0000 E 02	 	        ADD     [$$SPSV],2              ;Current stack + 2 for PUSH AX
  423	 	 	 	 	
  424	 0067  E8 01AA R	 	comds1: CALL    FILE_DISPATCH
  425	 006A  58	 	 	        POP     AX
  426	 006B  CB	 	 	        RET
  427	 	 	 	 	
  428	 	 	 	 	
  429	 	 	 	 	
  430	 	 	 	 	;**     LOC() Function
  431	 	 	 	 	;
  432	 	 	 	 	;       ENTRY   (BX) = file number
  433	 	 	 	 	;       EXIT    (BX) = current record number
  434	 	 	 	 	;       USES    BX
  435	 	 	 	 	
  436	 006C  50	 	 	$LOC:   PUSH    AX
  437	 006D  B4 02	 	 	        MOV     AH,DV_LOC               ;LOC function
  438	 006F  EB ED	 	 	        JMP     comdsp
  439	 	 	 	 	
  440	 	 	 	 	
  441	 	 	 	 	
  442	 	 	 	 	;**     LOF() Function
  443	 	 	 	 	;
  444	 	 	 	 	;       ENTRY   (BX) = file number
  445	 	 	 	 	;       EXIT    (FAC) = length of file in bytes
  446	 	 	 	 	;       USES    FAC
  447	 	 	 	 	
  448	 0071  50	 	 	$LOF:   PUSH    AX
  449	 0072  B4 04	 	 	        MOV     AH,DV_LOF               ;LOF Function
  450	 0074  EB E8	 	 	        JMP     comdsp
  451	 	 	 	 	
  452	 	 	 	 	
  453	 	 	 	 	
  454	 	 	 	 	;**     POS() Function                  ####  not implemented  ####
  455	 	 	 	 	;
  456	 	 	 	 	;       ENTRY   (BX) = file number
  457	 	 	 	 	;       EXIT    (BX) = current position in sequential record
  458	 	 	 	 	;       USES    BX
  459	 	 	 	 	
  460	 	 	 	 	;$POF:  PUSH    AX
  461	 	 	 	 	;       MOV     AH,DV_POS               ;POS Function
  462	 	 	 	 	;       JMP     comdsp
  463	 	 	 	 	
  464	 	 	 	 	
  465	 	 	 	 	
  466	 	 	 	 	;**     CLOSE statement
  467	 	 	 	 	;
  468	 	 	 	 	;       ENTRY   (BX) = file number
  469	 	 	 	 	;       USES    NONE
  470	 	 	 	 	
  471	 0076  89 26 0000 E	 	$DKC:   MOV     [$$SPSV],SP
  472	 	 	 	 	
  473	 007A  56	 	 	dkc1:   PUSH    SI
  474	 007B  E8 0000 E	 	        CALL    $FBLOC                  ;Must check if file has been opened
  475	 007E  5E	 	 	        POP     SI


IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 3-3
Compiler Generated Entry Points


  476	 007F  74 0C	 	 	        JZ      dkcret                  ;  No - just return
  477	 0081  50	 	 	        PUSH    AX
  478	 0082  B4 06	 	 	        MOV     AH,DV_CLOSE
  479	 0084  EB E1	 	 	        JMP     comds1
  480	 	 	 	 	
  481	 	 	 	 	
  482	 0086  89 26 0000 E	 	$DCA:   MOV     [$$SPSV],SP
  483	 008A  E8 01F1 R	 	        CALL    $CLOSF                  ;Close all files
  484	 008D  CB	 	 	dkcret: RET
  485	 	 	 	 	
  486	 	 	 	 	
  487	 	 	 	 	
  488	 	 	 	 	;**     WIDTH   #fnum,width
  489	 	 	 	 	;
  490	 	 	 	 	;       ENTRY   (BX) = file number
  491	 	 	 	 	;               (DX) = width
  492	 	 	 	 	;       USES    NONE
  493	 	 	 	 	
  494	 008E  50	 	 	$WDF:   PUSH    AX
  495	 008F  B4 08	 	 	        MOV     AH,DV_WIDTH             ;File width function
  496	 0091  EB CB	 	 	        JMP     comdsp
  497	 	 	 	 	


































IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 3-4
Compiler Generated Entry Points


  498	 	 	 	 	        PAGE
  499	 	 	 	 	
  500	 	 	 	 	;**     $GET/$RGT/$PUT/$RPT - Random disk I/O
  501	 	 	 	 	;
  502	 	 	 	 	;       ENTRY   (BX) = file number
  503	 	 	 	 	;               (DX) = record number for relative calls
  504	 	 	 	 	;       USES    AH
  505	 	 	 	 	
  506	 = 0001	 	 	 	PUTFLG  EQU     1                       ;PUT call
  507	 = 0002	 	 	 	RELFLG  EQU     2                       ;Record number in (DX)
  508	 	 	 	 	
  509	 0093  50	 	 	$GET:   PUSH    AX
  510	 0094  B0 00	 	 	        MOV     AL,0
  511	 	 	 	 	
  512	 0096  B4 0A	 	 	rnddsp: MOV     AH,DV_RANDIO
  513	 0098  89 26 0000 E	 	        MOV     [$$SPSV],SP
  514	 009C  83 06 0000 E 02	 	        ADD     [$$SPSV],2
  515	 00A1  56	 	 	        PUSH    SI
  516	 00A2  E8 0000 E	 	        CALL    $FBLOC
  517	 00A5  74 52	 	 	        JZ      ercbfm                  ;This is garbage - inconsistent
  518	 00A7  80 3C 04	 	 	        CMP     [SI].FD_MODE,MD_RND
  519	 00AA  75 4D	 	 	        JNE     ercbfm                  ;Not random - bad file mode
  520	 00AC  E8 01BA R	 	        CALL    PTRFIL_DISPATCH
  521	 00AF  5E	 	 	        POP     SI
  522	 00B0  58	 	 	        POP     AX
  523	 00B1  CB	 	 	        RET
  524	 	 	 	 	
  525	 00B2  50	 	 	$RGT:   PUSH    AX
  526	 00B3  B0 02	 	 	        MOV     AL,RELFLG
  527	 00B5  EB DF	 	 	        JMP     rnddsp
  528	 	 	 	 	
  529	 00B7  50	 	 	$PUT:   PUSH    AX
  530	 00B8  B0 01	 	 	        MOV     AL,PUTFLG
  531	 00BA  EB DA	 	 	        JMP     rnddsp
  532	 	 	 	 	
  533	 00BC  50	 	 	$RPT:   PUSH    AX
  534	 00BD  B0 03	 	 	        MOV     AL,PUTFLG+RELFLG
  535	 00BF  EB D5	 	 	        JMP     rnddsp
  536	 	 	 	 	

















IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 3-5
Compiler Generated Entry Points


  537	 	 	 	 	        PAGE
  538	 	 	 	 	
  539	 	 	 	 	;**     $DKN/$DKO/$DKM - OPEN statement
  540 	 	 	 	 	;
  541	 	 	 	 	;       The OPEN statement generates one of two preambles depending upon
  542	 	 	 	 	;       the form
  543	 	 	 	 	
  544	 	 	 	 	
  545	 	 	 	 	;**     $DKN - Standard form of OPEN
  546	 	 	 	 	;
  547	 	 	 	 	;       ENTRY   (BX) = mode sdesc
  548	 	 	 	 	;       EXIT    NONE
  549	 	 	 	 	;       USES    NONE
  550	 	 	 	 	
  551	 00C1  89 26 0000 E	 	$DKN:   MOV     [$$SPSV],SP
  552	 00C5  50	 	 	        PUSH    AX
  553	 00C6  53	 	 	        PUSH    BX
  554	 00C7  83 3F 00	 	 	        CMP     WORD PTR [BX],0         ;Test for empty string
  555	 00CA  74 2D	 	 	        JE      ercbfm
  556	 00CC  8B 5F 02	 	 	        MOV     BX,[BX+2]               ;(BX) = address of string
  557	 00CF  8A 1F	 	 	        MOV     BL,[BX]                 ;(BL) = first character
  558	 00D1  80 E3 DF	 	 	        AND     BL,-1-' '               ;Force to upper case
  559	 	 	 	 	
  560	 00D4  B0 01	 	 	        MOV     AL,MD_SQI               ;Assume input
  561	 00D6  80 FB 49	 	 	        CMP     BL,'I'
  562	 00D9  74 15	 	 	        JE      havmod
  563	 	 	 	 	
  564	 00DB  B0 02	 	 	        MOV     AL,MD_SQO               ;Assume output
  565	 00DD  80 FB 4F	 	 	        CMP     BL,'O'
  566	 00E0  74 0E	 	 	        JE      havmod
  567	 	 	 	 	
  568	 00E2  B0 04	 	 	        MOV     AL,MD_FIL               ;Assume random
  569	 00E4  80 FB 52	 	 	        CMP     BL,'R'
  570	 00E7  74 07	 	 	        JE      havmod
  571	 	 	 	 	
  572	 00E9  B0 08	 	 	        MOV     AL,MD_APP               ;Assume append
  573	 00EB  80 FB 41	 	 	        CMP     BL,'A'
  574	 00EE  75 09	 	 	        JNE     ercbfm                  ;error
  575	 	 	 	 	
  576	 00F0  A2 004E R	 	havmod: MOV     [$FILMOD],AL            ;Save mode for $DKM call
  577	 00F3  5B	 	 	        POP     BX
  578	 00F4  E8 0000 E	 	        CALL    $$DITS                  ;Delete temp string
  579	 00F7  58	 	 	        POP     AX
  580	 00F8  CB	 	 	        RET
  581	 	 	 	 	
  582	 00F9  E9 0000 E	 	ercbfm: JMP     $ERC_BFM                ;Error - Bad file mode
  583	 	 	 	 	
  584	 	 	 	 	
  585	 	 	 	 	;**     $DKO - SPCDSX form of OPEN statement
  586	 	 	 	 	;
  587	 	 	 	 	;       ENTRY   (BX) = file mode
  588	 	 	 	 	;       USES    NONE
  589	 	 	 	 	
  590	 00FC  51	 	 	$DKO:   PUSH    CX


IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 3-6
Compiler Generated Entry Points


  591	 00FD  53	 	 	        PUSH    BX
  592	 00FE  8A CB	 	 	        MOV     CL,BL                   ;(CL) = shift count
  593	 0100  B3 01	 	 	        MOV     BL,1                    ;Shifting 1
  594	 0102  D2 E3	 	 	        SAL     BL,CL                   ;  (CL) bits
  595	 0104  88 1E 004E R	 	        MOV     [$FILMOD],BL            ;Save mode for $DKM call
  596	 0108  5B	 	 	        POP     BX
  597	 0109  59	 	 	        POP     CX
  598	 010A  CB	 	 	        RET
  599	 	 	 	 	
  600	 	 	 	 	
  601	 	 	 	 	
  602	 	 	 	 	;**     $DKM - OPEN statement processor
  603	 	 	 	 	;
  604	 	 	 	 	;       ENTRY   (BX) = file number
  605	 	 	 	 	;               (DX) = file name sdesc
  606	 	 	 	 	;               (CX) = variable record length
  607	 	 	 	 	;       USES    NONE
  608	 	 	 	 	
  609	 010B  89 26 0000 E	 	$DKM:   MOV     [$$SPSV],SP
  610	 010F  50	 	 	        PUSH    AX
  611	 0110  56	 	 	        PUSH    SI
  612	 	 	 	 	
  613	 0111  51	 	 	        PUSH    CX
  614	 0112  52	 	 	        PUSH    DX
  615	 0113  53	 	 	        PUSH    BX
  616	 0114  8B DA	 	 	        MOV     BX,DX                   ;(BX) = file name sdesc
  617	 0116  8B 0F	 	 	        MOV     CX,[BX]                 ;(CX) = file name length
  618	 0118  8B 77 02	 	 	        MOV     SI,[BX+2]               ;(SI) = file name contents
  619	 011B  E8 020A R	 	        CALL    $SCANF                  ;(AL) = device #
  620	 011E  E8 0000 E	 	        CALL    $$DITS                  ;Delete temp string
  621	 0121  5B	 	 	        POP     BX
  622	 0122  5A	 	 	        POP     DX
  623	 0123  59	 	 	        POP     CX
  624	 	 	 	 	
  625	 0124  0B DB	 	 	        OR      BX,BX                   ;Test for 0 and neg
  626	 0126  76 10	 	 	        JBE     ercifn
  627	 0128  E8 0000 E	 	        CALL    $FBLOC                  ;Check if file open
  628	 012B  75 08	 	 	        JNZ     ercfao                  ;  Already open
  629	 	 	 	 	
  630	 012D  B4 0C	 	 	        MOV     AH,DV_OPEN
  631	 012F  E8 01B5 R	 	        CALL    OPEN_DISPATCH           ;Dispatch
  632	 	 	 	 	
  633	 0132  5E	 	 	        POP     SI
  634	 0133  58	 	 	        POP     AX
  635	 0134  CB	 	 	        RET
  636	 	 	 	 	
  637	 0135  E9 0000 E	 	ercfao: JMP     $ERC_FAO                ;Error - File already open
  638	 	 	 	 	
  639	 0138  E9 0000 E	 	ercifn: JMP     $ERC_IFN                ;Error - Illegal file number
  640	 	 	 	 	
  641	 	 	 	 	
  642	 013B	 	 	 	Entries ENDP




IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 4-1
Compiler Generated Entry Points


  643	 	 	 	 	
  644	 	 	 	 	
  645	 	 	 	 	        SUBTTL  Runtime Internal routines
  646	 	 	 	 	
  647	 013B	 	 	 	Locals  PROC    NEAR
  648	 	 	 	 	
  649	 	 	 	 	;-----  Device Dispatch Routines  -----------------------------------------
  650	 	 	 	 	
  651	 	 	 	 	
  652	 	 	 	 	;**     $INIDEV - Device initialization dispatcher
  653	 	 	 	 	;
  654	 	 	 	 	;       This routine calls initialization routines for each device
  655	 	 	 	 	;       in the device table.
  656	 	 	 	 	
  657	 013B	 	 	 	$INIDEV:
  658	 013B  BB 0016 R	 	        MOV     BX,OFFSET INIDEV_TABLE-2        ;Adjust for no disk entry
  659	 	 	 	 	
  660	 013E  BF 0006	 	 	devsub: MOV     DI,LAST_DEVICE_OFFSET-2 ;Use actual offset of last device
  661	 	 	 	 	
  662	 0141  53	 	 	devlp:  PUSH    BX
  663	 0142  57	 	 	        PUSH    DI
  664	 0143  2E: FF 11	 	        CALL    WORD PTR CS:[BX+DI]     ;Dispatch to device routine
  665	 0146  5F	 	 	        POP     DI
  666	 0147  5B	 	 	        POP     BX
  667	 0148  4F	 	 	        DEC     DI
  668	 0149  4F	 	 	        DEC     DI
  669	 014A  75 F5	 	 	        JNZ     devlp                   ;Loop until device offset = 0
  670	 014C  C3	 	 	        RET
  671	 	 	 	 	
  672	 	 	 	 	
  673	 	 	 	 	
  674	 	 	 	 	;**     $CLSDEV - Device close dispatcher
  675	 	 	 	 	;
  676	 	 	 	 	;       This routine calls close routines for each device
  677	 	 	 	 	;       in the device table.
  678	 	 	 	 	
  679	 014D	 	 	 	$CLSDEV:
  680	 014D  BB 001C R	 	        MOV     BX,OFFSET CLSDEV_TABLE-2        ;Adjust for no disk entry
  681	 0150  EB EC	 	 	        JMP     devsub
  682	 	 	 	 	
















IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 4-2
Runtime Internal routines


  683	 	 	 	 	        PAGE
  684	 	 	 	 	;_____  File Dispatch Routines  ------------------------------------------
  685	 	 	 	 	
  686	 	 	 	 	
  687	 	 	 	 	;**     $BAKCHR - Backup character in (AL)
  688	 	 	 	 	;
  689	 	 	 	 	;       ENTRY   (AL) = character to backup
  690	 	 	 	 	;               $PTRFIL = file data block pointer
  691	 	 	 	 	;       USES    AH
  692	 	 	 	 	
  693	 0152	 	 	 	$$BCH:
  694	 0152	 	 	 	$BAKCHR:
  695	 0152  56	 	 	        PUSH    SI
  696	 0153  8B 36 0000 E	 	        MOV     SI,$PTRFIL
  697	 0157  0B F6	 	 	        OR      SI,SI
  698	 0159  75 04	 	 	        JNZ     bakch1
  699	 	 	 	 	
  700	 015B  5E	 	 	        POP     SI
  701	 015C  E9 0000 E	 	        JMP     $TTY_BAKC               ;Console backup
  702	 	 	 	 	
  703	 015F  B4 0E	 	 	bakch1: MOV     AH,DV_BAKC
  704	 	 	 	 	
  705	 0161  E8 01BA R	 	ptrdsp: CALL    PTRFIL_DISPATCH
  706	 0164  5E	 	 	        POP     SI
  707	 0165  C3	 	 	        RET
  708	 	 	 	 	
  709	 	 	 	 	
  710	 	 	 	 	
  711	 	 	 	 	;**     $GETCHR - Input character into (AL)
  712	 	 	 	 	;
  713	 	 	 	 	;       ENTRY   none
  714	 	 	 	 	;       EXIT    (AL) = character
  715	 	 	 	 	
  716	 0166	 	 	 	$$RCH:
  717	 0166	 	 	 	$GETCHR:
  718	 0166  56	 	 	        PUSH    SI
  719	 0167  8B 36 0000 E	 	        MOV     SI,$PTRFIL
  720	 016B  0B F6	 	 	        OR      SI,SI
  721	 016D  75 04	 	 	        JNZ     getch1
  722	 	 	 	 	
  723	 016F  5E	 	 	        POP     SI
  724	 0170  E9 0000 E	 	        JMP     $TTY_SINP              ;Console input
  725	 	 	 	 	
  726	 0173  B4 10	 	 	getch1: MOV     AH,DV_SINP
  727	 0175  EB EA	 	 	        JMP     ptrdsp
  728	 	 	 	 	
  729	 	 	 	 	
  730	 	 	 	 	
  731	 	 	 	 	;**     $PUTCHR - Output character in (AL)
  732	 	 	 	 	;
  733	 	 	 	 	;       ENTRY   (AL) = character to output
  734	 	 	 	 	;       EXIT    none
  735	 	 	 	 	;       USES    AH
  736	 	 	 	 	


IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 4-3
Runtime Internal routines


  737	 0177	 	 	 	$$WCH:
  738	 0177	 	 	 	$PUTCHR:
  739	 0177  56	 	 	        PUSH    SI
  740	 0178  8B 36 0000 E	 	        MOV     SI,$PTRFIL
  741	 017C  0B F6	 	 	        OR      SI,SI
  742	 017E  75 04	 	 	        JNZ     putch1
  743	 	 	 	 	
  744	 0180  5E	 	 	        POP     SI
  745	 0181  E9 0000 E	 	        JMP     $TTY_SOUT              ;Console output
  746	 	 	 	 	
  747	 0184  B4 12	 	 	putch1: MOV     AH,DV_SOUT
  748	 0186  EB D9	 	 	        JMP     ptrdsp
  749	 	 	 	 	
  750	 	 	 	 	
  751	 	 	 	 	
  752	 	 	 	 	;**     $GETPOS - Get current file position
  753	 	 	 	 	;
  754	 	 	 	 	;       EXIT    (AH) = file position
  755	 	 	 	 	
  756	 0188	 	 	 	$$POS:
  757	 0188	 	 	 	$GETPOS:
  758	 0188  56	 	 	        PUSH    SI
  759	 0189  8B 36 0000 E	 	        MOV     SI,[$PTRFIL]
  760	 018D  0B F6	 	 	        OR      SI,SI
  761	 018F  75 04	 	 	        JNZ     getps1
  762	 	 	 	 	
  763	 0191  5E	 	 	        POP     SI
  764	 0192  E9 0000 E	 	        JMP     $TTY_GPOS              ;Get TTY position
  765	 	 	 	 	
  766	 0195  B4 14	 	 	getps1: MOV     AH,DV_GPOS             ;Get position
  767	 0197  EB C8	 	 	        JMP     ptrdsp
  768	 	 	 	 	
  769	 	 	 	 	
  770	 	 	 	 	
  771	 	 	 	 	;**     $GETWID - Get current file width
  772	 	 	 	 	;
  773	 	 	 	 	;       EXIT    (AH) = file width
  774	 	 	 	 	
  775	 0199	 	 	 	$$WID:
  776	 0199	 	 	 	$GETWID:
  777	 0199  56	 	 	        PUSH    SI
  778	 019A  8B 36 0000 E	 	        MOV     SI,[$PTRFIL]
  779	 019E  0B F6	 	 	        OR      SI,SI
  780	 01A0  75 04	 	 	        JNZ     getwd1
  781	 	 	 	 	
  782	 01A2  5E	 	 	        POP     SI
  783	 01A3  E9 0000 E	 	        JMP     $TTY_GWID
  784	 	 	 	 	
  785	 01A6  B4 16	 	 	getwd1: MOV     AH,DV_GWID
  786	 01A8  EB B7	 	 	        JMP     ptrdsp
  787	 	 	 	 	





IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 4-4
Runtime Internal routines


  788	 	 	 	 	        PAGE
  789	 	 	 	 	
  790	 	 	 	 	;**     FILE_DISPATCH - File number to device dispatcher
  791	 	 	 	 	;
  792	 	 	 	 	;**     PTRFIL_DISPATCH - PTRFIL to device dispatcher
  793	 	 	 	 	;
  794	 	 	 	 	;**     OPEN_DISPATCH - OPEN file device dispatcher
  795	 	 	 	 	;
  796	 	 	 	 	;       The following information is passed to the routine:
  797	 	 	 	 	;
  798	 	 	 	 	;               (AL,CX,DX,BX) = parameters
  799	 	 	 	 	;               (SI) = file block pointer
  800	 	 	 	 	;               (DI) = device offset
  801	 	 	 	 	;
  802	 	 	 	 	;       Both the (SI) and (DI) registers can be used as temporaries since
  803	 	 	 	 	;       they are not needed upon return.
  804	 	 	 	 	;
  805	 	 	 	 	;       FILE_DISPATCH and OPEN_DISPATCH
  806	 	 	 	 	;
  807	 	 	 	 	;               ENTRY   (BX) = file number
  808	 	 	 	 	;                       (AL) = device number for OPEN_DISPATCH
  809	 	 	 	 	;                       (AH) = function to dispatch on
  810	 	 	 	 	;                       (AL,CX,DX) = other parameters
  811	 	 	 	 	;               USES    AH,F
  812	 	 	 	 	;
  813	 	 	 	 	;       PTRFIL_DISPATCH
  814	 	 	 	 	;
  815	 	 	 	 	;               ENTRY   (AL) = character
  816	 	 	 	 	;                       (SI) = FDB pointer
  817	 	 	 	 	;               EXIT    (AL) = character
  818	 	 	 	 	;               USES    AX,F
  819	 	 	 	 	
  820	 01AA	 	 	 	FILE_DISPATCH:
  821	 01AA  56	 	 	        PUSH    SI
  822	 01AB  E8 0000 E	 	        CALL    $FBLOC                  ;(SI) = file data block pointer
  823	 01AE  74 88	 	 	        JZ      ercifn                  ;Error - illegal file number
  824	 01B0  E8 01BA R	 	        CALL    PTRFIL_DISPATCH
  825	 01B3  5E	 	 	        POP     SI
  826	 01B4  C3	 	 	        RET
  827	 	 	 	 	
  828	 01B5	 	 	 	OPEN_DISPATCH:
  829	 01B5  57	 	 	        PUSH    DI
  830	 01B6  53	 	 	        PUSH    BX
  831	 01B7  50	 	 	        PUSH    AX
  832	 01B8  EB 06	 	 	        JMP     SHORT opndsp
  833	 	 	 	 	
  834	 01BA	 	 	 	PTRFIL_DISPATCH:                        ;(SI) = file data block pointer
  835	 01BA  57	 	 	        PUSH    DI
  836	 01BB  53	 	 	        PUSH    BX
  837	 01BC  50	 	 	        PUSH    AX
  838	 	 	 	 	
  839	 01BD  8A 44 2E	 	 	        MOV     AL,[SI].FD_DEVICE       ;(AL) = device number
  840	 01C0  0A C0	 	 	opndsp: OR      AL,AL
  841	 01C2  78 04	 	 	        JS      getdv1                  ;must be a special device


IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 4-5
Runtime Internal routines


  842	 01C4  32 C0	 	 	        XOR     AL,AL                   ;(AL) = 0 for disks
  843	 01C6  EB 02	 	 	        JMP     SHORT getdv2
  844	 01C8  F6 D8	 	 	getdv1: NEG     AL                      ;(AL) = - device number for special
  845	 01CA  98	 	 	getdv2: CBW
  846	 01CB  D1 E0	 	 	        SAL     AX,1
  847	 01CD  8B F8	 	 	        MOV     DI,AX                   ;(DI) = device offset
  848	 01CF  2E: 8B 9D 0010 R	 	        MOV     BX,CS:$DEVICE_TABLE[DI]
  849	 01D4  0B DB	 	 	        OR      BX,BX                   ;If entry is 0, then unavailable
  850	 01D6  74 16	 	 	        JZ      ercdna                  ;  Error
  851	 01D8  58	 	 	        POP     AX                      ;(AH) = function code
  852	 01D9  50	 	 	        PUSH    AX
  853	 01DA  86 E0	 	 	        XCHG    AH,AL
  854	 01DC  98	 	 	        CBW
  855	 01DD  03 D8	 	 	        ADD     BX,AX                   ;Add function code offset to dispatch
  856	 01DF  2E: 8B 1F	 	        MOV     BX,CS:[BX]              ;Get address of routine
  857	 01E2  89 1E 0000 R	 	        MOV     [DISPATCH_ADDR],BX      ;Save it for indirect call
  858	 01E6  58	 	 	        POP     AX                      ;Restore (AL)
  859	 01E7  5B	 	 	        POP     BX                      ;Restore (BX)
  860	 01E8  FF 16 0000 R	 	        CALL    [DISPATCH_ADDR]         ;Execute routine
  861	 01EC  5F	 	 	        POP     DI
  862	 01ED  C3	 	 	        RET
  863	 	 	 	 	
  864	 01EE  E9 0000 E	 	ercdna: JMP     $ERC_DNA
  865	 	 	 	 	
































IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 4-6
Runtime Internal routines


  866	 	 	 	 	        PAGE
  867	 	 	 	 	
  868	 	 	 	 	;**     $CLOSF - Close all files
  869	 	 	 	 	;
  870	 	 	 	 	;       ENTRY   NONE
  871	 	 	 	 	;       EXIT    NONE
  872	 	 	 	 	;       USES    NONE
  873	 	 	 	 	
  874	 01F1	 	 	 	$CLOSF:
  875	 01F1  53	 	 	        PUSH    BX
  876	 01F2  56	 	 	        PUSH    SI
  877	 	 	 	 	
  878	 01F3  8B 36 0000 E	 	closf1: MOV     SI,[$FILPT]             ;Get address of next file block
  879	 01F7  0B F6	 	 	        OR      SI,SI
  880	 01F9  74 0C	 	 	        JZ      closf3                  ;Finished
  881	 	 	 	 	
  882	 01FB  8A 5C FB	 	 	        MOV     BL,[SI].FB_NUM          ;Get file #
  883	 01FE  32 FF	 	 	        XOR     BH,BH
  884	 0200  9A 007A ---- R	 	        CALL    FAR PTR dkc1            ;Close file in (BX)
  885	 0205  EB EC	 	 	        JMP     closf1                  ;Keep looping
  886	 	 	 	 	
  887	 0207  5E	 	 	closf3: POP     SI
  888	 0208  5B	 	 	        POP     BX
  889	 0209  C3	 	 	        RET
  890	 	 	 	 	































IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 4-7
Runtime Internal routines


  891	 	 	 	 	        PAGE
  892	 	 	 	 	
  893	 	 	 	 	;**     $SCANF - Scan file name
  894	 	 	 	 	;
  895	 	 	 	 	;       ENTRY   (SI) = text pointer
  896	 	 	 	 	;               (CX) = length
  897	 	 	 	 	;       EXIT    (AL) = device #
  898	 	 	 	 	;               FILNAM = (device # , filename.ext)
  899	 	 	 	 	;       USES    CX,SI
  900	 	 	 	 	
  901	 020A	 	 	 	$SCANF:
  902	 020A  E8 0250 R	 	        CALL    PARSE_DEVICE            ;(AL) = device #
  903	 020D  A2 0002 R	 	        MOV     [$FILNAM],AL            ;Save device #
  904	 0210  0A C0	 	 	        OR      AL,AL
  905	 0212  78 02	 	 	        JS      _030
  906	 0214  32 C0	 	 	        XOR     AL,AL                   ;(AL) = 0 for disks
  907	 0216  50	 	 	_030:   PUSH    AX
  908	 0217  52	 	 	        PUSH    DX
  909	 0218  57	 	 	        PUSH    DI
  910	 0219  BF 0003 R	 	        MOV     DI,OFFSET DC:$FILNAM+1
  911	 021C  BA 000B	 	 	        MOV     DX,FILNAM_LENGTH
  912	 	 	 	 	
  913	 	 	 	 	
  914	 021F  E3 27	 	 	scan1:  JCXZ    filspc                  ;End of string
  915	 0221  49	 	 	        DEC     CX
  916	 0222  AC	 	 	        LODSB                           ;Get character
  917	 0223  3C 20	 	 	        CMP     AL,' '
  918	 0225  73 03	 	 	        JAE     _040
  919	 	 	 	 	
  920	 0227  E9 0000 E	 	ercbfn: JMP     $ERC_BFN
  921	 	 	 	 	
  922	 022A  3C 2E	 	 	_040:   CMP     AL,'.'
  923	 022C  74 08	 	 	        JE      fillnm
  924	 022E  AA	 	 	        STOSB                           ;Store character
  925	 022F  4A	 	 	        DEC     DX
  926	 0230  75 ED	 	 	        JNZ     scan1                   ;Keep looking for characters
  927	 	 	 	 	
  928	 0232  5F	 	 	gotnam: POP     DI
  929	 0233  5A	 	 	        POP     DX
  930	 0234  58	 	 	        POP     AX
  931	 0235  C3	 	 	        RET
  932	 	 	 	 	
  933	 0236  83 FA 0B	 	 	fillnm: CMP     DX,FILNAM_LENGTH
  934	 0239  74 EC	 	 	        JE      ercbfn                  ;Error - extension only !
  935	 023B  83 FA 03	 	 	        CMP     DX,3
  936	 023E  72 E7	 	 	        JB      ercbfn                  ;Error - 2nd dot
  937	 0240  74 DD	 	 	        JE      scan1                   ;Scan extension like filename
  938	 0242  B0 20	 	 	        MOV     AL,' '
  939	 0244  AA	 	 	        STOSB                           ;Fill with blank
  940	 0245  4A	 	 	        DEC     DX
  941	 0246  EB EE	 	 	        JMP     fillnm                  ;Keep filling
  942	 	 	 	 	
  943	 0248  B0 20	 	 	filspc: MOV     AL,' '                  ;Fill short name with spaces
  944	 024A  AA	 	 	        STOSB


IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 4-8
Runtime Internal routines


  945	 024B  4A	 	 	        DEC     DX
  946	 024C  75 FA	 	 	        JNZ     filspc                  ;Keep filling
  947	 024E  EB E2	 	 	        JMP     gotnam                  ;Done with name
  948	 	 	 	 	




















































IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 4-9
Runtime Internal routines


  949	 	 	 	 	        PAGE
  950	 	 	 	 	
  951	 	 	 	 	;**     PARSE_DEVICE - Parse device name from string
  952	 	 	 	 	;
  953	 	 	 	 	;       ENTRY   (CX) = length of string
  954	 	 	 	 	;               (SI) = string address
  955	 	 	 	 	;       EXIT    (AL) = device # (0 = default , - = special)
  956	 	 	 	 	;               (CX) = remaining count
  957	 	 	 	 	;               (SI) = address of remaining string
  958	 	 	 	 	
  959	 0250	 	 	 	PARSE_DEVICE:
  960	 0250  52	 	 	        PUSH    DX
  961	 0251  57	 	 	        PUSH    DI
  962	 0252  56	 	 	        PUSH    SI
  963	 0253  8B D1	 	 	        MOV     DX,CX                   ;(DX) = original length
  964	 0255  E3 07	 	 	        JCXZ    nodvnm                  ;If length = 0 , no device name
  965	 	 	 	 	
  966	 0257  AC	 	 	devscn: LODSB                           ;Get character
  967	 0258  3C 3A	 	 	        CMP     AL,':'
  968	 025A  74 0A	 	 	        JE      devnm                   ;Found possible name
  969	 025C  E2 F9	 	 	        LOOP    devscn
  970	 	 	 	 	
  971	 025E  8B CA	 	 	nodvnm: MOV     CX,DX                   ;No device name - restore everything
  972	 0260  5E	 	 	        POP     SI
  973	 0261  5F	 	 	        POP     DI
  974	 0262  5A	 	 	        POP     DX
  975	 0263  32 C0	 	 	        XOR     AL,AL                   ;Default device to 0
  976	 0265  C3	 	 	        RET
  977	 	 	 	 	
  978	 0266  5F	 	 	devnm:  POP     DI                      ;Restore old string pointer
  979	 0267  87 F7	 	 	        XCHG    SI,DI
  980	 0269  57	 	 	        PUSH    DI                      ;Save new string pointer
  981	 026A  2B D1	 	 	        SUB     DX,CX                   ;(DX) = device name length
  982	 026C  74 B9	 	 	        JZ      ercbfn                  ;Length = 0 - bad file name
  983	 026E  49	 	 	        DEC     CX                      ;Count off :
  984	 026F  83 FA 01	 	 	        CMP     DX,1
  985	 0272  74 39	 	 	        JE      dsknam                  ;Length = 1 - must be disk name
  986	 	 	 	 	
  987	 0274  BF FFFF R	 	        MOV     DI,OFFSET DEVICE_NAME_TABLE-1
  988	 0277  56	 	 	devsrc: PUSH    SI
  989	 0278  52	 	 	        PUSH    DX
  990	 	 	 	 	
  991	 0279  47	 	 	devlop: INC     DI
  992	 027A  AC	 	 	        LODSB
  993	 027B  E8 02BB R	 	        CALL    UPCASE                  ;Convert to upper case
  994	 027E  2E: F6 05 80	 	        TEST    BYTE PTR CS:[DI],80H    ;Check to see if at device (long name)
  995	 0282  75 1D	 	 	        JNZ     nmtch2
  996	 0284  2E: 38 05	 	        CMP     CS:[DI],AL
  997	 0287  75 12	 	 	        JNE     nomtch
  998	 0289  4A	 	 	        DEC     DX
  999	 028A  75 ED	 	 	        JNZ     devlop
 1000	 	 	 	 	
 1001	 028C  47	 	 	fnddev: INC     DI
 1002	 028D  2E: 8A 05	 	        MOV     AL,CS:[DI]              ;Get device #


IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 4-10
Runtime Internal routines


 1003	 0290  0A C0	 	 	        OR      AL,AL
 1004	 0292  79 07	 	 	        JNS     nomtch                  ;Not a device #
 1005	 	 	 	 	
 1006	 0294  5E	 	 	        POP     SI
 1007	 0295  5E	 	 	        POP     SI
 1008	 0296  5E	 	 	devret: POP     SI                      ;(SI) = pointer after :
 1009	 0297  5F	 	 	        POP     DI
 1010	 0298  5A	 	 	        POP     DX
 1011	 0299  C3	 	 	        RET                             ;(CX) = chars left , (AL) = device #
 1012	 	 	 	 	
 1013	 029A  47	 	 	nmtch1: INC     DI
 1014	 029B  2E: F6 05 80	 	NOMTCH: TEST    BYTE PTR CS:[DI],80H    ;Check for device #
 1015	 029F  74 F9	 	 	        JZ      nmtch1                  ;  No
 1016	 02A1  5A	 	 	nmtch2: POP     DX
 1017	 02A2  5E	 	 	        POP     SI
 1018	 02A3  2E: 80 7D 01 00	 	        CMP     BYTE PTR CS:[DI+1],0    ;End of table?
 1019	 02A8  75 CD	 	 	        JNE     devsrc                  ;  No - check next entry
 1020	 	 	 	 	
 1021	 02AA  E9 0227 R	 	_050:   JMP     ercbfn                  ;Error - bad filename (device name)
 1022	 	 	 	 	
 1023	 02AD  AC	 	 	dsknam: LODSB                           ;Refetch character
 1024	 02AE  E8 02BB R	 	        CALL    UPCASE
 1025	 02B1  2C 40	 	 	        SUB     AL,'A'-1                ;Convert letter to 1-26 (let @ be 0)
 1026	 02B3  72 F5	 	 	        JC      _050                    ;  Less than @
 1027	 02B5  3C 1A	 	 	        CMP     AL,'Z' and 01FH
 1028	 02B7  73 F1	 	 	        JNC     _050                    ;  Greater than Z
 1029	 02B9  EB DB	 	 	        JMP     devret
 1030	 	 	 	 	
 1031	 02BB  3C 61	 	 	UPCASE: CMP     AL,'a'                  ;Convert (AL) to upper case
 1032	 02BD  72 06	 	 	        JB      upret
 1033	 02BF  3C 7A	 	 	        CMP     AL,'z'
 1034	 02C1  77 02	 	 	        JA      upret
 1035	 02C3  24 DF	 	 	        AND     AL,255-' '
 1036	 02C5  C3	 	 	upret:  RET
 1037	 	 	 	 	





















IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Page 4-11
Runtime Internal routines


 1038	 	 	 	 	        PAGE
 1039	 	 	 	 	
 1040	 	 	 	 	;**     $FRCSQO - Force MD_RND to MD_SQO
 1041	 	 	 	 	
 1042	 02C6	 	 	 	$FRCSQO:
 1043	 02C6  80 3E 004E R 04	 	        CMP     [$FILMOD],MD_RND
 1044	 02CB  75 05	 	 	        JNE     frcret
 1045	 02CD  C6 06 004E R 02	 	        MOV     [$FILMOD],MD_SQO
 1046	 02D2  C3	 	 	frcret: RET
 1047	 	 	 	 	
 1048	 	 	 	 	
 1049	 	 	 	 	
 1050	 	 	 	 	;**     $DEVOPN - Special device open common routine
 1051	 	 	 	 	;
 1052	 	 	 	 	;       ENTRY   (AL) = file device
 1053	 	 	 	 	;               (AH) = valid file modes
 1054	 	 	 	 	;               (CX) = buffer size (not including basic FDB size)
 1055	 	 	 	 	;               (DL) = file width
 1056	 	 	 	 	;               (DH) = initial file position
 1057	 	 	 	 	;               (BX) = file number
 1058	 	 	 	 	;       USES    CX,DI
 1059	 	 	 	 	
 1060	 02D3	 	 	 	$DEVOPN:
 1061	 02D3  84 26 004E R	 	        TEST    [$FILMOD],AH            ;Check for valid file mode
 1062	 02D7  74 1F	 	 	        JZ      ercbfm1                 ;  Bad file mode
 1063	 	 	 	 	
 1064	 02D9  87 D9	 	 	        XCHG    BX,CX
 1065	 02DB  83 C3 33	 	 	        ADD     BX,FD_BUFFER            ;(BX) = size of block to allocate
 1066	 02DE  E8 0000 E	 	        CALL    $FBALC                  ;Allocate block
 1067	 02E1  87 D9	 	 	        XCHG    BX,CX                   ;(BX) = file number
 1068	 02E3  8B 3E 0000 E	 	        MOV     DI,[$FILPT]             ;Link in new file block
 1069	 02E7  89 7C FE	 	 	        MOV     [SI].BL_LNK,DI
 1070	 02EA  89 36 0000 E	 	        MOV     [$FILPT],SI             ;  right in front
 1071	 02EE  88 5C FB	 	 	        MOV     [SI].FB_NUM,BL          ;Set file number
 1072	 	 	 	 	
 1073	 02F1  88 44 2E	 	 	        MOV     [SI].FD_DEVICE,AL       ;Set file device
 1074	 02F4  89 54 2F	 	 	        MOV     WORD PTR [SI].FD_WIDTH,DX  ;Set file width/position
 1075	 02F7  C3	 	 	        RET
 1076	 	 	 	 	
 1077	 02F8  E9 0000 E	 	ercbfm1:JMP     $ERC_BFM                ;Bad file mode
 1078	 	 	 	 	
 1079	 	 	 	 	
 1080	 02FB	 	 	 	Locals  ENDP
 1081	 	 	 	 	
 1082	 02FB	 	 	 	CODE    ENDS
 1083	 	 	 	 	
 1084	 	 	 	 	        END









IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Symbols-1



Macros:

	 	N a m e  	 	Length

DEVMAC . . . . . . . . . . . . .	0001	
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

CODE . . . . . . . . . . . . . .	02FB	WORD  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	004F	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

BAKCH1 . . . . . . . . . . . . .	L NEAR 	015F	CODE
BL_LEN . . . . . . . . . . . . .	Number	FFFC	
BL_LNK . . . . . . . . . . . . .	Number	FFFE	
BL_SIZE. . . . . . . . . . . . .	Number	FFFA	
CLOSF1 . . . . . . . . . . . . .	L NEAR 	01F3	CODE
CLOSF3 . . . . . . . . . . . . .	L NEAR 	0207	CODE
CLSDEV_END . . . . . . . . . . .	L WORD 	0024	CODE
CLSDEV_TABLE . . . . . . . . . .	L WORD 	001E	CODE

IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Symbols-2



COMDS1 . . . . . . . . . . . . .	L NEAR 	0067	CODE
COMDSP . . . . . . . . . . . . .	L NEAR 	005E	CODE
DEVICE_NAME_TABLE. . . . . . . .	L BYTE 	0000	CODE
DEVLOP . . . . . . . . . . . . .	L NEAR 	0279	CODE
DEVLP. . . . . . . . . . . . . .	L NEAR 	0141	CODE
DEVNM. . . . . . . . . . . . . .	L NEAR 	0266	CODE
DEVRET . . . . . . . . . . . . .	L NEAR 	0296	CODE
DEVSCN . . . . . . . . . . . . .	L NEAR 	0257	CODE
DEVSRC . . . . . . . . . . . . .	L NEAR 	0277	CODE
DEVSUB . . . . . . . . . . . . .	L NEAR 	013E	CODE
DISPATCH_ADDR. . . . . . . . . .	L WORD 	0000	DATA
DKC1 . . . . . . . . . . . . . .	L NEAR 	007A	CODE
DKCRET . . . . . . . . . . . . .	L NEAR 	008D	CODE
DN_KYBD. . . . . . . . . . . . .	Number	FFFF	
DN_LPT1. . . . . . . . . . . . .	Number	FFFD	
DN_SCRN. . . . . . . . . . . . .	Number	FFFE	
DSKNAM . . . . . . . . . . . . .	L NEAR 	02AD	CODE
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
ENTRIES. . . . . . . . . . . . .	F PROC	004A	CODE	Length =00F1
EOFCHR . . . . . . . . . . . . .	Number	001A	
ERCBFM . . . . . . . . . . . . .	L NEAR 	00F9	CODE
ERCBFM1. . . . . . . . . . . . .	L NEAR 	02F8	CODE
ERCBFN . . . . . . . . . . . . .	L NEAR 	0227	CODE
ERCDNA . . . . . . . . . . . . .	L NEAR 	01EE	CODE
ERCFAO . . . . . . . . . . . . .	L NEAR 	0135	CODE
ERCIFN . . . . . . . . . . . . .	L NEAR 	0138	CODE
FB_NUM . . . . . . . . . . . . .	Number	FFFB	
FCB_LENGTH . . . . . . . . . . .	Number	0026	
FILE_DISPATCH. . . . . . . . . .	L NEAR 	01AA	CODE
FILLNM . . . . . . . . . . . . .	L NEAR 	0236	CODE
FILNAML. . . . . . . . . . . . .	Number	0026	
FILNAM_LENGTH. . . . . . . . . .	Number	000B	
FILSPC . . . . . . . . . . . . .	L NEAR 	0248	CODE
FNDDEV . . . . . . . . . . . . .	L NEAR 	028C	CODE
FRCRET . . . . . . . . . . . . .	L NEAR 	02D2	CODE
GETCH1 . . . . . . . . . . . . .	L NEAR 	0173	CODE
GETDV1 . . . . . . . . . . . . .	L NEAR 	01C8	CODE
GETDV2 . . . . . . . . . . . . .	L NEAR 	01CA	CODE
GETPS1 . . . . . . . . . . . . .	L NEAR 	0195	CODE
GETWD1 . . . . . . . . . . . . .	L NEAR 	01A6	CODE
GOTNAM . . . . . . . . . . . . .	L NEAR 	0232	CODE
HAVMOD . . . . . . . . . . . . .	L NEAR 	00F0	CODE


IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Symbols-3



INIDEV_END . . . . . . . . . . .	L WORD 	001E	CODE
INIDEV_TABLE . . . . . . . . . .	L WORD 	0018	CODE
LAST_DEVICE_OFFSET . . . . . . .	Number	0008	
LOCALS . . . . . . . . . . . . .	N PROC	013B	CODE	Length =01C0
MD_APP . . . . . . . . . . . . .	Number	0008	
MD_BIN . . . . . . . . . . . . .	Number	0080	
MD_FIL . . . . . . . . . . . . .	Number	0004	
MD_IBM . . . . . . . . . . . . .	Number	0020	
MD_KIL . . . . . . . . . . . . .	Number	0010	
MD_RND . . . . . . . . . . . . .	Number	0004	
MD_SQI . . . . . . . . . . . . .	Number	0001	
MD_SQO . . . . . . . . . . . . .	Number	0002	
MD_USR . . . . . . . . . . . . .	Number	0040	
NMTCH1 . . . . . . . . . . . . .	L NEAR 	029A	CODE
NMTCH2 . . . . . . . . . . . . .	L NEAR 	02A1	CODE
NODVNM . . . . . . . . . . . . .	L NEAR 	025E	CODE
NOMTCH . . . . . . . . . . . . .	L NEAR 	029B	CODE
OPEN_DISPATCH. . . . . . . . . .	L NEAR 	01B5	CODE
OPNDSP . . . . . . . . . . . . .	L NEAR 	01C0	CODE
PARSE_DEVICE . . . . . . . . . .	L NEAR 	0250	CODE
PTRDSP . . . . . . . . . . . . .	L NEAR 	0161	CODE
PTRFIL_DISPATCH. . . . . . . . .	L NEAR 	01BA	CODE
PUTCH1 . . . . . . . . . . . . .	L NEAR 	0184	CODE
PUTFLG . . . . . . . . . . . . .	Number	0001	
REC_LENGTH . . . . . . . . . . .	Number	0080	
RELFLG . . . . . . . . . . . . .	Number	0002	
RNDDSP . . . . . . . . . . . . .	L NEAR 	0096	CODE
SCAN1. . . . . . . . . . . . . .	L NEAR 	021F	CODE
UPCASE . . . . . . . . . . . . .	L NEAR 	02BB	CODE
UPRET. . . . . . . . . . . . . .	L NEAR 	02C5	CODE
VPT1 . . . . . . . . . . . . . .	L NEAR 	0057	CODE
WDD1 . . . . . . . . . . . . . .	L NEAR 	003C	CODE
WIDTH_TABLE. . . . . . . . . . .	L WORD 	0024	CODE
$$BCH. . . . . . . . . . . . . .	L NEAR 	0152	CODE	Global
$$DITS . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$POS. . . . . . . . . . . . . .	L NEAR 	0188	CODE	Global
$$RCH. . . . . . . . . . . . . .	L NEAR 	0166	CODE	Global
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$WCH. . . . . . . . . . . . . .	L NEAR 	0177	CODE	Global
$$WID. . . . . . . . . . . . . .	L NEAR 	0199	CODE	Global
$BAKCHR. . . . . . . . . . . . .	L NEAR 	0152	CODE	Global
$CLOSF . . . . . . . . . . . . .	L NEAR 	01F1	CODE	Global
$CLSDEV. . . . . . . . . . . . .	L NEAR 	014D	CODE	Global
$C_KYBD. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$C_LPT1. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$C_SCRN. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DCA . . . . . . . . . . . . . .	L NEAR 	0086	CODE	Global
$DEVICE_TABLE. . . . . . . . . .	L WORD 	0010	CODE	Global
$DEVOPN. . . . . . . . . . . . .	L NEAR 	02D3	CODE	Global
$DKC . . . . . . . . . . . . . .	L NEAR 	0076	CODE	Global
$DKM . . . . . . . . . . . . . .	L NEAR 	010B	CODE	Global
$DKN . . . . . . . . . . . . . .	L NEAR 	00C1	CODE	Global
$DKO . . . . . . . . . . . . . .	L NEAR 	00FC	CODE	Global
$D_DISK. . . . . . . . . . . . .	L NEAR 	0000	CODE	External


IODEV   - Device Independent I/O Drivers for BASCOM-86   Macro-86 %1(12)   1:3:55  13-Nov-81    Symbols-4



$D_KYBD. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$D_LPT1. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$D_SCRN. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$EOF . . . . . . . . . . . . . .	L NEAR 	005B	CODE	Global
$ERC_BFM . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_BFN . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_DNA . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_FAO . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_IFN . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FBALC . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FBDEA . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FBLOC . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FILMOD. . . . . . . . . . . . .	L BYTE 	004E	DATA	Global
$FILNAM. . . . . . . . . . . . .	L BYTE 	0002	DATA	Global	Length =0026
$FILNM2. . . . . . . . . . . . .	L BYTE 	0028	DATA	Global	Length =0026
$FILPT . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$FRCSQO. . . . . . . . . . . . .	L NEAR 	02C6	CODE	Global
$GET . . . . . . . . . . . . . .	L NEAR 	0093	CODE	Global
$GETCHR. . . . . . . . . . . . .	L NEAR 	0166	CODE	Global
$GETPOS. . . . . . . . . . . . .	L NEAR 	0188	CODE	Global
$GETWID. . . . . . . . . . . . .	L NEAR 	0199	CODE	Global
$INIDEV. . . . . . . . . . . . .	L NEAR 	013B	CODE	Global
$I_KYBD. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$I_LPT1. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$I_SCRN. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$LOC . . . . . . . . . . . . . .	L NEAR 	006C	CODE	Global
$LOF . . . . . . . . . . . . . .	L NEAR 	0071	CODE	Global
$PTRFIL. . . . . . . . . . . . .	V WORD 	0000	DATA	External
$PUT . . . . . . . . . . . . . .	L NEAR 	00B7	CODE	Global
$PUTCHR. . . . . . . . . . . . .	L NEAR 	0177	CODE	Global
$RGT . . . . . . . . . . . . . .	L NEAR 	00B2	CODE	Global
$RPT . . . . . . . . . . . . . .	L NEAR 	00BC	CODE	Global
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SCANF . . . . . . . . . . . . .	L NEAR 	020A	CODE	Global
$TTY_BAKC. . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TTY_GPOS. . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TTY_GWID. . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TTY_SINP. . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TTY_SOUT. . . . . . . . . . . .	L NEAR 	0000	CODE	External
$VPT . . . . . . . . . . . . . .	L NEAR 	004A	CODE	Global
$WDD . . . . . . . . . . . . . .	L NEAR 	002A	CODE	Global
$WDF . . . . . . . . . . . . . .	L NEAR 	008E	CODE	Global
$W_KYBD. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$W_LPT1. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$W_SCRN. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
_030 . . . . . . . . . . . . . .	L NEAR 	0216	CODE
_040 . . . . . . . . . . . . . .	L NEAR 	022A	CODE
_050 . . . . . . . . . . . . . .	L NEAR 	02AA	CODE
_CPM_. . . . . . . . . . . . . .	Number	0000	
_IBM_. . . . . . . . . . . . . .	Number	0000	
_MSDOS_. . . . . . . . . . . . .	Number	0001	
___DEV . . . . . . . . . . . . .	Number	FFFC	
___ZZZ . . . . . . . . . . . . .	Number	0018	

Warning Severe
Errors	Errors 
0	0
