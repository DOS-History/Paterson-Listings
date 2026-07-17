IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   IOLPT  - Line printer Device Drivers
    2	 	 	 	 	        SUBTTL  Support for 1 line printers
    3	 	 	 	 	
    4	 	 	 	 	
    5	 	 	 	 	;       This module contains the device independent printer routines for
    6	 	 	 	 	;       the BASIC Compiler.  While this module is intended for use with
    7	 	 	 	 	;       the IBM Personal Computer, there is only a small amount which
    8	 	 	 	 	;       actually depends on this fact.
    9	 	 	 	 	
   10	 	 	 	 	;       Modified for 1 printer systems  (subset of IBM)
   11	 	 	 	 	
   12	 	 	 	 	
   13	 = 0084	 	 	 	iniwid=         132                     ;Initial printer width
   14	 	 	 	 	
   15	 = 000A	 	 	 	LF=             10
   16	 = 000D	 	 	 	CR=             13
   17	 	 	 	 	
   18	 	 	 	 	
   19	                             C	        INCLUDE TABMAC.INC
   20	                             C	;       Special Table Generation Macros
   21	                             C	
   22	                             C	ENTORG  MACRO   First_entry
   23	                             C	        .XCREF
   24	                             C	___ZZZ=         First_entry
   25	                             C	        .CREF
   26	                             C	        ENDM
   27	                             C	
   28	                             C	
   29	                             C	ENT     MACRO   Lab,Incr
   30	                             C	Lab=            ___ZZZ
   31	                             C	        .XCREF
   32	                             C	___ZZZ=         ___ZZZ+Incr
   33	                             C	        .CREF
   34	                             C	        ENDM
   35	                             C	
   36	                             C	
   37	                             C	ENTI    MACRO   Incr
   38	                             C	        .XCREF
   39	                             C	___ZZZ=         ___ZZZ+Incr
   40	                             C	        .CREF
   41	                             C	        ENDM
   42	                             C	
   43	 	 	 	 	
   44	                             C	        INCLUDE DEVDEF.INC












IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 1-2
Support for 1 line printers


   45	                             C	        PAGE
   46	                             C	
   47	                             C	;       DEVDEF.INC - Device Independent I/O Definitions
   48	                             C	
   49	                             C	        INCLUDE SYSTEM.INC
   50	                             C	;       Operating System Selection
   51	                             C	
   52	 = 0000                      C	_IBM_=                  0
   53	                             C	
   54	 = 0001                      C	_MSDOS_=                1
   55	 = 0000                      C	_CPM_=                  0
   56	                             C	
   57	                             C	;       Overrides
   58	                             C	
   59	 = 0001                      C	_MSDOS_=                _MSDOS_ or _IBM_
   60	                             C	
   61	                             C	if1
   62	                             C	if      _CPM_
   63	                             C	        %OUT    !   CP/M-86 Version
   64	                             C	endif
   65	                             C	if      _MSDOS_
   66	                             C	        %OUT    !   MSDOS Version
   67	                             C	endif
   68	                             C	if      _IBM_
   69	                             C	        %OUT    !     IBM Personal Computer
   70	                             C	endif
   71	                             C	
   72	                             C	if      _MSDOS_+_CPM_ ne 1
   73	                             C	        %OUT    #####################  Error - Bad Operating System Selection
   74	                             C	
   75	                             C	        error
   76	                             C	endif
   77	                             C	endif
   78	                             C	






















IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 1-3
Support for 1 line printers


   79	                             C	        PAGE
   80	                             C	
   81	                             C	DEVNAM  MACRO
   82	                             C	        DEVMAC  KYBD
   83	                             C	        DEVMAC  SCRN
   84	                             C	if      _IBM_
   85	                             C	        DEVMAC  CAS1
   86	                             C	        DEVMAC  COM1
   87	                             C	        DEVMAC  COM2
   88	                             C	endif
   89	                             C	        DEVMAC  LPT1
   90	                             C	if      _IBM_
   91	                             C	        DEVMAC  LPT2
   92	                             C	        DEVMAC  LPT3
   93	                             C	endif
   94	                             C	        ENDM
   95	                             C	
   96	 = FFFF                      C	___DEV=         -1
   97	                             C	
   98	                             C	DEVMAC  MACRO   ARG
   99	                             C	DN_&ARG=        ___DEV
  100	                             C	.xcref
  101	                             C	___DEV=         ___DEV-1
  102	                             C	.cref
  103	                             C	        ENDM
  104	                             C	
  105	                             C	        DEVNAM
  106	                             C	
  107	 = 0008                      C	LAST_DEVICE_OFFSET=     -2*___DEV       ;All devices have lower offsets



























IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 1-4
Support for 1 line printers


  108	                             C	        PAGE
  109	                             C	
  110	                             C	DSPNAM  MACRO
  111	                             C	        DSPMAC  EOF                     ;EOF function
  112	                             C	        DSPMAC  LOC                     ;LOC function
  113	                             C	        DSPMAC  LOF                     ;LOF function
  114	                             C	;       DSPMAC  POS                     ;POS function
  115	                             C	        DSPMAC  CLOSE                   ;CLOSE statement
  116	                             C	        DSPMAC  WIDTH                   ;WIDTH statement
  117	                             C	        DSPMAC  RANDIO                  ;GET/PUT statements
  118	                             C	        DSPMAC  OPEN                    ;OPEN statement
  119	                             C	        DSPMAC  BAKC                    ;Backup character
  120	                             C	        DSPMAC  SINP                    ;Serial input
  121	                             C	        DSPMAC  SOUT                    ;Serial output
  122	                             C	        DSPMAC  GPOS                    ;Get current position
  123	                             C	        DSPMAC  GWID                    ;Get current width
  124	                             C	        ENDM
  125	                             C	
  126	                             C	
  127	                             C	;       Device Function Dispatch Table Offsets
  128	                             C	
  129	                             C	
  130	                             C	DSPMAC  MACRO   func
  131	                             C	ENT     DV_&func,2
  132	                             C	        ENDM
  133	                             C	
  134	                             C	
  135	                             C	ENTORG  0
  136	                             C	        DSPNAM
  137	                             C	ENT     DV_TABLEN,0
  138	                             C	

























IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 1-5
Support for 1 line printers


  139	                             C	        PAGE
  140	                             C	
  141	                             C	;       File Mode Definitions
  142	                             C	
  143	 = 0001                      C	MD_SQI          EQU     1
  144	 = 0002                      C	MD_SQO          EQU     2
  145	 = 0004                      C	MD_RND          EQU     4
  146	 = 0004                      C	MD_FIL          EQU     4
  147	 = 0008                      C	MD_APP          EQU     8
  148	 = 0010                      C	MD_KIL          EQU     16
  149	 = 0020                      C	MD_IBM          EQU     32
  150	 = 0040                      C	MD_USR          EQU     64
  151	 = 0080                      C	MD_BIN          EQU     128
  152	                             C	
  153	                             C	
  154	                             C	;       Operating System dependent field sizes
  155	                             C	
  156	 = 001A                      C	EOFCHR=                 'Z' and 1fh
  157	                             C	
  158	 = 0026                      C	FILNAML=                38              ;Length of $FILNAM
  159	 = 000B                      C	FILNAM_LENGTH=          11              ;Actual length of name (8+3)
  160	                             C	
  161	 = 0026                      C	FCB_LENGTH=             38              ;38 byte FCBs
  162	 = 0080                      C	REC_LENGTH=             128             ;128 byte sectors
  163	                             C	































IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 1-6
Support for 1 line printers


  164	                             C	        PAGE
  165	                             C	
  166	                             C	;-----  Basic Interpreter style File Data Block  -----
  167	                             C	
  168	                             C	;       Link block offsets
  169	                             C	
  170	 =-0006                      C	BL_SIZE=        -6                      ;Link block size (2 bytes of misc)
  171	 =-0005                      C	  FB_NUM=       -5                      ;  File number
  172	 =-0004                      C	BL_LEN=         -4                      ;Block size
  173	 =-0002                      C	BL_LNK=         -2                      ;Block link
  174	                             C	
  175	                             C	;       File Data Block offsets
  176	                             C	
  177	                             C	FILE_DATA_BLOCK STRUC
  178	                             C	
  179	 0000  ??                    C	  FD_MODE       DB      ?               ;File mode of open
  180	 0001     26 [               C	  FD_FCB        DB      FCB_LENGTH DUP (?)  ;FCB area
  181	                ??           C	
  182	                    ]        C	
  183	                             C	
  184	 0027  ????                  C	  FD_CURLOC     DW      ?               ;Current record number
  185	 0029  ??                    C	  FD_ORNOFS     DB      ?               ;Byte count in sector
  186	 002A  ??                    C	  FD_NMLOFS     DB      ?               ;Bytes left in input buffer
  187	 002B     03 [               C	                DB      3 DUP (?)       ;Unused
  188	                ??           C	
  189	                    ]        C	
  190	                             C	
  191	 002E  ??                    C	  FD_DEVICE     DB      ?               ;Device number
  192	 002F  ??                    C	  FD_WIDTH      DB      ?               ;File width
  193	 0030  ??                    C	  FD_POS        DB      ?               ;Current file position
  194	 0031  ??                    C	  FD_FLAGS      DB      ?               ;Used for load and save
  195	 0032  ??                    C	  FD_OUTPOS     DB      ?               ;Output position for tab expansion
  196	 0033     80 [               C	  FD_BUFFER     DB      REC_LENGTH DUP (?)  ;File record buffer
  197	                ??           C	
  198	                    ]        C	
  199	                             C	
  200	                             C	
  201	                             C	;       5.0 Variable Record Information
  202	                             C	
  203	 00B3  ????                  C	  FR_VRECL      DW      ?               ;Variable record length
  204	 00B5  ????                  C	  FR_PHYREC     DW      ?               ;Current physical record number
  205	 00B7  ????                  C	  FR_LOGREC     DW      ?               ;Current logical record number
  206	 00B9  ??                    C	                DB      ?               ;Future use
  207	 00BA  ????                  C	  FR_OUTPOS     DW      ?               ;Output position for sequential I/O
  208	 00BC     01 [               C	  FR_FIELD      DB      1 DUP (?)       ;Field buffer
  209	                ??           C	
  210	                    ]        C	
  211	                             C	
  212	                             C	
  213	 00BD                        C	FILE_DATA_BLOCK ENDS
  214	                             C	
  215	                             C	
  216	                             C	;       End of DEVDEF.INC
  217	 	 	 	 	


IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 1-7
Support for 1 line printers


  218	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
  219	 	 	 	 	
  220	 	 	 	 	        EXTRN   $FILMOD:BYTE
  221	 	 	 	 	
  222	 0000	 	 	 	DATA    ENDS
  223	 	 	 	 	
  224	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
  225	 	 	 	 	
  226	 	 	 	 	        PUBLIC  $LPTFDB
  227	 	 	 	 	
  228	 0000  84	 	 	LPTWID          DB      iniwid                  ;width/initial position
  229	 0001  00	 	 	LPTPOS          DB      0
  230	 	 	 	 	
  231	 0002     33 [	 	 	$LPTFDB         DB      FD_BUFFER DUP (0)       ;LPRINT file data block
  232	                00	 	
  233	                    ]	 	
  234	 	 	 	 	
  235	 	 	 	 	
  236	 0035	 	 	 	CONST   ENDS
  237	 	 	 	 	
  238	 	 	 	 	DC      GROUP   CONST,DATA



































IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 2-1
Support for 1 line printers


  239	 	 	 	 	
  240	 	 	 	 	
  241	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
  242	 	 	 	 	
  243	 	 	 	 	        ASSUME CS:CODE, DS:DC, ES:DC
  244	 	 	 	 	
  245	 	 	 	 	
  246	 	 	 	 	;       Run-time Entries
  247	 	 	 	 	
  248	 	 	 	 	        PUBLIC  $D_LPT1,$I_LPT1,$W_LPT1,$C_LPT1
  249	 	 	 	 	
  250	 	 	 	 	        PUBLIC  $LPO,$LWI
  251	 	 	 	 	
  252	 	 	 	 	
  253	 	 	 	 	;       Run-time Externals
  254	 	 	 	 	
  255	 	 	 	 	        EXTRN   $LPTOT:NEAR
  256	 	 	 	 	        EXTRN   $$WCLF:NEAR
  257	 	 	 	 	        EXTRN   $DEVOPN:NEAR,$FRCSQO:NEAR,$FBDEA:NEAR
  258	 	 	 	 	        EXTRN   $ERC_FC:NEAR
  259	 	 	 	 	
  260	 	 	 	 	
  261	 	 	 	 	;       Illegal Device Functions
  262	 	 	 	 	
  263	 =	 	 	 	LPT_EOF         EQU     $ERC_FC
  264	 =	 	 	 	LPT_LOC         EQU     $ERC_FC
  265	 =	 	 	 	LPT_LOF         EQU     $ERC_FC
  266	 =	 	 	 	LPT_RANDIO      EQU     $ERC_FC
  267	 =	 	 	 	LPT_BAKC        EQU     $ERC_FC
  268	 =	 	 	 	LPT_SINP        EQU     $ERC_FC
  269	 	 	 	 	
  270	 	 	 	 	
  271	 	 	 	 	;       Device Independent Printer Interface
  272	 	 	 	 	
  273	 	 	 	 	DSPMAC  MACRO   func
  274	 	 	 	 	        DW      LPT_&func
  275	 	 	 	 	        ENDM
  276	 	 	 	 	
  277	 0000	 	 	 	$D_LPT1:
  278	 	 	 	 	        DSPNAM
  279	 0000  0000 E                 +	        DW      LPT_EOF
  280	 0002  0000 E                 +	        DW      LPT_LOC
  281	 0004  0000 E                 +	        DW      LPT_LOF
  282	 0006  0092 R                 +	        DW      LPT_CLOSE
  283	 0008  005D R                 +	        DW      LPT_WIDTH
  284	 000A  0000 E                 +	        DW      LPT_RANDIO
  285	 000C  0043 R                 +	        DW      LPT_OPEN
  286	 000E  0000 E                 +	        DW      LPT_BAKC
  287	 0010  0000 E                 +	        DW      LPT_SINP
  288	 0012  0061 R                 +	        DW      LPT_SOUT
  289	 0014  0089 R                 +	        DW      LPT_GPOS
  290	 0016  008E R                 +	        DW      LPT_GWID
  291	 	 	 	 	



IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 3-1
Support for 1 line printers


  292	 	 	 	 	
  293	 	 	 	 	
  294	 	 	 	 	;-----  Device Action Routines  ----------------------------------------------
  295	 	 	 	 	
  296	 	 	 	 	
  297	 	 	 	 	;       These routines are always called from special device dispatchers.
  298	 	 	 	 	;
  299	 	 	 	 	;       The registers are set up as follows:
  300	 	 	 	 	;
  301	 	 	 	 	;               (DI) = device offset
  302	 	 	 	 	;
  303	 	 	 	 	;       The remaining registers are used to pass parameters.
  304	 	 	 	 	
  305	 	 	 	 	
  306	 0018	 	 	 	devio   PROC    NEAR
  307	 	 	 	 	
  308	 	 	 	 	;       Device initialization routines
  309	 	 	 	 	;
  310	 	 	 	 	;       ENTRY   (DI) = Device offset
  311	 	 	 	 	;       USES    any but DI
  312	 	 	 	 	
  313	 0018	 	 	 	$I_LPT1:
  314	 0018  C6 06 0002 R 02	 	        MOV     $LPTFDB.FD_MODE,MD_SQO  ;Initialize LPRINT file data block
  315	 001D  C6 06 0030 R FD	 	        MOV     $LPTFDB.FD_DEVICE,DN_LPT1
  316	 0022  C6 06 0031 R 84	 	        MOV     $LPTFDB.FD_WIDTH,iniwid
  317	 0027  C3	 	 	        RET
  318	 	 	 	 	
  319	 	 	 	 	
  320	 	 	 	 	;       Device close routines
  321	 	 	 	 	;
  322	 	 	 	 	;       ENTRY   (DI) = Device offset
  323	 	 	 	 	;       USES    any but DI
  324	 	 	 	 	
  325	 0028	 	 	 	$C_LPT1:
  326	 0028  80 3E 0001 R 00	 	        CMP     LPTPOS,0
  327	 002D  74 0A	 	 	        JE      cret
  328	 002F  B0 0D	 	 	        MOV     AL,CR
  329	 0031  E8 0000 E	 	        CALL    $LPTOT
  330	 0034  B0 0A	 	 	        MOV     AL,LF
  331	 0036  E8 0000 E	 	        CALL    $LPTOT
  332	 	 	 	 	
  333	 0039  C3	 	 	cret:   RET
  334	 	 	 	 	
  335	 	 	 	 	
  336	 	 	 	 	;       Device width routines
  337	 	 	 	 	;
  338	 	 	 	 	;       ENTRY   (DL) = device width
  339	 	 	 	 	;               (DI) = Device offset
  340	 	 	 	 	;       USES    none
  341	 	 	 	 	
  342	 003A	 	 	 	$W_LPT1:
  343	 003A  88 16 0031 R	 	        MOV     $LPTFDB.FD_WIDTH,DL     ;Set LPRINT file width
  344	 003E  88 16 0000 R	 	        MOV     LPTWID,DL               ;Set new printer width
  345	 0042  C3	 	 	        RET


IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 3-2
Support for 1 line printers


  346	 	 	 	 	
  347	 0043	 	 	 	devio   ENDP






















































IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 4-1
Support for 1 line printers


  348	 	 	 	 	
  349	 	 	 	 	
  350	 	 	 	 	;-----  File Action Routines  -----------------------------------------------
  351	 	 	 	 	
  352	 	 	 	 	
  353	 	 	 	 	;       These routines are all called from the file dispatcher.
  354	 	 	 	 	;
  355	 	 	 	 	;       The registers are set up as follows:
  356	 	 	 	 	;
  357	 	 	 	 	;               (SI) = file data block address (points to file mode field)
  358	 	 	 	 	;               (DI) = device offset  (0 = disk , 2 = next , 4 = next , ...)
  359	 	 	 	 	;               (AH) = function code of routine
  360	 	 	 	 	;               (AL,CX,DX,BX) = parameters for each routine
  361	 	 	 	 	;
  362	 	 	 	 	;       These routines are free to use SI and DI as temporaries
  363	 	 	 	 	
  364	 	 	 	 	
  365	 0043	 	 	 	fileio  PROC
  366	 	 	 	 	
  367	 	 	 	 	;       OPEN statement
  368	 	 	 	 	;
  369	 	 	 	 	;       ENTRY   (BX) = file number
  370	 	 	 	 	;               (AL) = device number for OPEN
  371	 	 	 	 	;               (DX) = file name descriptor  (not used here)
  372	 	 	 	 	;               (CX) = variable record length  (not used here)
  373	 	 	 	 	
  374	 0043	 	 	 	LPT_OPEN:
  375	 0043  E8 0000 E	 	        CALL    $FRCSQO                 ;Change MD_RND to MD_SQO
  376	 0046  51	 	 	        PUSH    CX
  377	 0047  52	 	 	        PUSH    DX
  378	 0048  53	 	 	        PUSH    BX
  379	 0049  33 C9	 	 	        XOR     CX,CX                   ;(CX) = extra FDB size
  380	 004B  8B 16 0000 R	 	        MOV     DX,WORD PTR LPTWID      ;(DH,DL) = (position,width)
  381	 004F  B4 02	 	 	        MOV     AH,MD_SQO               ;Valid file modes
  382	 0051  E8 0000 E	 	        CALL    $DEVOPN                 ;Open file data block
  383	 0054  A0 0000 E	 	        MOV     AL,[$FILMOD]
  384	 0057  88 04	 	 	        MOV     [SI].FD_MODE,AL         ;Set file mode
  385	 0059  5B	 	 	        POP     BX
  386	 005A  5A	 	 	        POP     DX
  387	 005B  59	 	 	        POP     CX
  388	 005C  C3	 	 	        RET
  389	 	 	 	 	
  390	 	 	 	 	
  391	 	 	 	 	;       WIDTH file statement
  392	 	 	 	 	;
  393	 	 	 	 	;       ENTRY   (BX) = file number
  394	 	 	 	 	;               (DL) = file width
  395	 	 	 	 	
  396	 005D	 	 	 	LPT_WIDTH:
  397	 005D  88 54 2F	 	 	        MOV     [SI].FD_WIDTH,DL
  398	 0060  C3	 	 	        RET
  399	 	 	 	 	
  400	 	 	 	 	
  401	 	 	 	 	;       SOUT - Serial character output


IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 4-2
Support for 1 line printers


  402	 	 	 	 	;
  403	 	 	 	 	;       ENTRY   (AL) = character
  404	 	 	 	 	;       USES    AX,SI,DI
  405	 	 	 	 	
  406	 0061	 	 	 	LPT_SOUT:
  407	 0061  50	 	 	        PUSH    AX                      ;(AL) = character
  408	 0062  E8 0000 E	 	        CALL    $LPTOT                  ;Print character  (DI) = device offset
  409	 0065  58	 	 	        POP     AX
  410	 0066  3C 0D	 	 	        CMP     AL,CR                   ;Is CR?
  411	 0068  74 19	 	 	        JE      sout1                   ;  Yes
  412	 006A  3C 20	 	 	        CMP     AL,' '                  ;Is printing char?
  413	 006C  72 1A	 	 	        JB      sout2                   ;  No
  414	 	 	 	 	
  415	 006E  FE 06 0001 R	 	        INC     LPTPOS                  ;Bump position (device)
  416	 0072  8A 64 2F	 	 	        MOV     AH,[SI].FD_WIDTH        ;Get printer (file) width
  417	 0075  80 FC FF	 	 	        CMP     AH,255
  418	 0078  74 0E	 	 	        JE      sout2                   ;Infinite width
  419	 	 	 	 	
  420	 007A  3A 26 0001 R	 	        CMP     AH,LPTPOS               ;At end of line
  421	 007E  77 08	 	 	        JA      sout2
  422	 	 	 	 	
  423	 0080  E8 0000 E	 	        CALL    $$WCLF                  ;Write CR/LF to printer
  424	 	 	 	 	
  425	 0083  C6 06 0001 R 00	 	sout1:  MOV     LPTPOS,0                ;Set position (device) to 0
  426	 	 	 	 	
  427	 0088  C3	 	 	sout2:  RET
  428	 	 	 	 	
  429	 	 	 	 	
  430	 	 	 	 	;       GPOS - Get position
  431	 	 	 	 	;
  432	 	 	 	 	;       EXIT    (AH) = device position
  433	 	 	 	 	
  434	 0089	 	 	 	LPT_GPOS:
  435	 0089  8A 26 0001 R	 	        MOV     AH,LPTPOS               ;Get position (device)
  436	 008D  C3	 	 	        RET
  437	 	 	 	 	
  438	 	 	 	 	
  439	 	 	 	 	;       GWID - Get width
  440	 	 	 	 	;
  441	 	 	 	 	;       EXIT    (AH) = file width
  442	 	 	 	 	
  443	 008E	 	 	 	LPT_GWID:
  444	 008E  8A 64 2F	 	 	        MOV     AH,[SI].FD_WIDTH        ;Get printer (file) width
  445	 0091  C3	 	 	        RET
  446	 	 	 	 	
  447	 	 	 	 	
  448	 	 	 	 	;       CLOSE - Line printer file close
  449	 	 	 	 	;
  450	 	 	 	 	;       Deallocate file block
  451	 	 	 	 	
  452	 0092	 	 	 	LPT_CLOSE:
  453	 0092  E8 0000 E	 	        CALL    $FBDEA                  ;Deallocate buffer
  454	 0095  C3	 	 	        RET
  455	 	 	 	 	


IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 4-3
Support for 1 line printers


  456	 	 	 	 	
  457	 0096	 	 	 	fileio  ENDP






















































IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Page 5-1
Support for 1 line printers


  458	 	 	 	 	
  459	 	 	 	 	
  460	 0096	 	 	 	Entries PROC    FAR
  461	 	 	 	 	
  462	 	 	 	 	
  463	 	 	 	 	
  464	 	 	 	 	;**     $LPO - Line printer position
  465	 	 	 	 	;
  466	 	 	 	 	;       Get line printer position
  467	 	 	 	 	;
  468	 	 	 	 	;       ENTRY   NONE
  469	 	 	 	 	;       EXIT    (BX) = printer position
  470	 	 	 	 	
  471	 0096	 	 	 	$LPO:
  472	 0096  8A 1E 0001 R	 	        MOV     BL,LPTPOS               ;Get position for printer
  473	 009A  B7 00	 	 	        MOV     BH,0
  474	 009C  43	 	 	        INC     BX
  475	 009D  CB	 	 	        RET
  476	 	 	 	 	
  477	 	 	 	 	
  478	 	 	 	 	
  479	 	 	 	 	;       WIDTH LPRINT Statement
  480	 	 	 	 	;
  481	 	 	 	 	;       Sets the LPRINT file width and device width
  482	 	 	 	 	
  483	 009E	 	 	 	$LWI:
  484	 009E  88 1E 0031 R	 	        MOV     $LPTFDB.FD_WIDTH,BL     ;Set LPRINT file width
  485	 00A2  88 1E 0000 R	 	        MOV     LPTWID,BL               ;Set printer 1 width
  486	 00A6  CB	 	 	        RET
  487	 	 	 	 	
  488	 	 	 	 	
  489	 00A7	 	 	 	Entries ENDP
  490	 	 	 	 	
  491	 00A7	 	 	 	CODE    ENDS
  492	 	 	 	 	
  493	 	 	 	 	        END




















IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Symbols-1



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

CODE . . . . . . . . . . . . . .	00A7	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  CONST. . . . . . . . . . . . . .	0035	WORD  	PUBLIC	'CONST'
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

BL_LEN . . . . . . . . . . . . .	Number	FFFC	
BL_LNK . . . . . . . . . . . . .	Number	FFFE	
BL_SIZE. . . . . . . . . . . . .	Number	FFFA	
CR . . . . . . . . . . . . . . .	Number	000D	
CRET . . . . . . . . . . . . . .	L NEAR 	0039	CODE
DEVIO. . . . . . . . . . . . . .	N PROC	0018	CODE	Length =002B
DN_KYBD. . . . . . . . . . . . .	Number	FFFF	


IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Symbols-2



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
ENTRIES. . . . . . . . . . . . .	F PROC	0096	CODE	Length =0011
EOFCHR . . . . . . . . . . . . .	Number	001A	
FB_NUM . . . . . . . . . . . . .	Number	FFFB	
FCB_LENGTH . . . . . . . . . . .	Number	0026	
FILEIO . . . . . . . . . . . . .	N PROC	0043	CODE	Length =0053
FILNAML. . . . . . . . . . . . .	Number	0026	
FILNAM_LENGTH. . . . . . . . . .	Number	000B	
INIWID . . . . . . . . . . . . .	Number	0084	
LAST_DEVICE_OFFSET . . . . . . .	Number	0008	
LF . . . . . . . . . . . . . . .	Number	000A	
LPTPOS . . . . . . . . . . . . .	L BYTE 	0001	CONST
LPTWID . . . . . . . . . . . . .	L BYTE 	0000	CONST
LPT_BAKC . . . . . . . . . . . .	Alias	$ERC_FC	 	
LPT_CLOSE. . . . . . . . . . . .	L NEAR 	0092	CODE
LPT_EOF. . . . . . . . . . . . .	Alias	$ERC_FC	 	
LPT_GPOS . . . . . . . . . . . .	L NEAR 	0089	CODE
LPT_GWID . . . . . . . . . . . .	L NEAR 	008E	CODE
LPT_LOC. . . . . . . . . . . . .	Alias	$ERC_FC	 	
LPT_LOF. . . . . . . . . . . . .	Alias	$ERC_FC	 	
LPT_OPEN . . . . . . . . . . . .	L NEAR 	0043	CODE
LPT_RANDIO . . . . . . . . . . .	Alias	$ERC_FC	 	
LPT_SINP . . . . . . . . . . . .	Alias	$ERC_FC	 	
LPT_SOUT . . . . . . . . . . . .	L NEAR 	0061	CODE
LPT_WIDTH. . . . . . . . . . . .	L NEAR 	005D	CODE
MD_APP . . . . . . . . . . . . .	Number	0008	
MD_BIN . . . . . . . . . . . . .	Number	0080	
MD_FIL . . . . . . . . . . . . .	Number	0004	
MD_IBM . . . . . . . . . . . . .	Number	0020	
MD_KIL . . . . . . . . . . . . .	Number	0010	
MD_RND . . . . . . . . . . . . .	Number	0004	
MD_SQI . . . . . . . . . . . . .	Number	0001	
MD_SQO . . . . . . . . . . . . .	Number	0002	
MD_USR . . . . . . . . . . . . .	Number	0040	
REC_LENGTH . . . . . . . . . . .	Number	0080	
SOUT1. . . . . . . . . . . . . .	L NEAR 	0083	CODE
SOUT2. . . . . . . . . . . . . .	L NEAR 	0088	CODE
$$WCLF . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$C_LPT1. . . . . . . . . . . . .	L NEAR 	0028	CODE	Global
$DEVOPN. . . . . . . . . . . . .	L NEAR 	0000	CODE	External


IOLPT  - Line printer Device Drivers                     Macro-86 %1(12)   1:5:30  13-Nov-81    Symbols-3



$D_LPT1. . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FBDEA . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FILMOD. . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FRCSQO. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$I_LPT1. . . . . . . . . . . . .	L NEAR 	0018	CODE	Global
$LPO . . . . . . . . . . . . . .	L NEAR 	0096	CODE	Global
$LPTFDB. . . . . . . . . . . . .	L BYTE 	0002	CONST	Global	Length =0033
$LPTOT . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$LWI . . . . . . . . . . . . . .	L NEAR 	009E	CODE	Global
$W_LPT1. . . . . . . . . . . . .	L NEAR 	003A	CODE	Global
_CPM_. . . . . . . . . . . . . .	Number	0000	
_IBM_. . . . . . . . . . . . . .	Number	0000	
_MSDOS_. . . . . . . . . . . . .	Number	0001	
___DEV . . . . . . . . . . . . .	Number	FFFC	
___ZZZ . . . . . . . . . . . . .	Number	0018	

Warning Severe
Errors	Errors 
0	0




































