IOFILM - File Manager for BASCOM-86                      Macro-86 %1(12)   1:5:17  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   IOFILM - File Manager for BASCOM-86
    2	 	 	 	 	
    3	 	 	 	 	;       This module contains the dynamic file management routines for the
    4	 	 	 	 	;       8086 BASIC Compiler runtime.
    5	 	 	 	 	
    6	                             C	        INCLUDE TABMAC.INC
    7	                             C	;       Special Table Generation Macros
    8	                             C	
    9	                             C	ENTORG  MACRO   First_entry
   10	                             C	        .XCREF
   11	                             C	___ZZZ=         First_entry
   12	                             C	        .CREF
   13	                             C	        ENDM
   14	                             C	
   15	                             C	
   16	                             C	ENT     MACRO   Lab,Incr
   17	                             C	Lab=            ___ZZZ
   18	                             C	        .XCREF
   19	                             C	___ZZZ=         ___ZZZ+Incr
   20	                             C	        .CREF
   21	                             C	        ENDM
   22	                             C	
   23	                             C	
   24	                             C	ENTI    MACRO   Incr
   25	                             C	        .XCREF
   26	                             C	___ZZZ=         ___ZZZ+Incr
   27	                             C	        .CREF
   28	                             C	        ENDM
   29	                             C	
   30	 	 	 	 	
   31	 	 	 	 	
   32	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
   33	 	 	 	 	
   34	 	 	 	 	        EXTRN   $FILPT:WORD             ;File block list head
   35	 	 	 	 	        EXTRN   $FREPT:WORD             ;File block list head
   36	 	 	 	 	
   37	                             C	        INCLUDE DEVDEF.INC



















IOFILM - File Manager for BASCOM-86                      Macro-86 %1(12)   1:5:17  13-Nov-81    Page 1-2



   38	                             C	        PAGE
   39	                             C	
   40	                             C	;       DEVDEF.INC - Device Independent I/O Definitions
   41	                             C	
   42	                             C	        INCLUDE SYSTEM.INC
   43	                             C	;       Operating System Selection
   44	                             C	
   45	 = 0000                      C	_IBM_=                  0
   46	                             C	
   47	 = 0001                      C	_MSDOS_=                1
   48	 = 0000                      C	_CPM_=                  0
   49	                             C	
   50	                             C	;       Overrides
   51	                             C	
   52	 = 0001                      C	_MSDOS_=                _MSDOS_ or _IBM_
   53	                             C	
   54	                             C	if1
   55	                             C	if      _CPM_
   56	                             C	        %OUT    !   CP/M-86 Version
   57	                             C	endif
   58	                             C	if      _MSDOS_
   59	                             C	        %OUT    !   MSDOS Version
   60	                             C	endif
   61	                             C	if      _IBM_
   62	                             C	        %OUT    !     IBM Personal Computer
   63	                             C	endif
   64	                             C	
   65	                             C	if      _MSDOS_+_CPM_ ne 1
   66	                             C	        %OUT    #####################  Error - Bad Operating System Selection
   67	                             C	
   68	                             C	        error
   69	                             C	endif
   70	                             C	endif
   71	                             C	






















IOFILM - File Manager for BASCOM-86                      Macro-86 %1(12)   1:5:17  13-Nov-81    Page 1-3



   72	                             C	        PAGE
   73	                             C	
   74	                             C	DEVNAM  MACRO
   75	                             C	        DEVMAC  KYBD
   76	                             C	        DEVMAC  SCRN
   77	                             C	if      _IBM_
   78	                             C	        DEVMAC  CAS1
   79	                             C	        DEVMAC  COM1
   80	                             C	        DEVMAC  COM2
   81	                             C	endif
   82	                             C	        DEVMAC  LPT1
   83	                             C	if      _IBM_
   84	                             C	        DEVMAC  LPT2
   85	                             C	        DEVMAC  LPT3
   86	                             C	endif
   87	                             C	        ENDM
   88	                             C	
   89	 = FFFF                      C	___DEV=         -1
   90	                             C	
   91	                             C	DEVMAC  MACRO   ARG
   92	                             C	DN_&ARG=        ___DEV
   93	                             C	.xcref
   94	                             C	___DEV=         ___DEV-1
   95	                             C	.cref
   96	                             C	        ENDM
   97	                             C	
   98	                             C	        DEVNAM
   99	                             C	
  100	 = 0008                      C	LAST_DEVICE_OFFSET=     -2*___DEV       ;All devices have lower offsets



























IOFILM - File Manager for BASCOM-86                      Macro-86 %1(12)   1:5:17  13-Nov-81    Page 1-4



  101	                             C	        PAGE
  102	                             C	
  103	                             C	DSPNAM  MACRO
  104	                             C	        DSPMAC  EOF                     ;EOF function
  105	                             C	        DSPMAC  LOC                     ;LOC function
  106	                             C	        DSPMAC  LOF                     ;LOF function
  107	                             C	;       DSPMAC  POS                     ;POS function
  108	                             C	        DSPMAC  CLOSE                   ;CLOSE statement
  109	                             C	        DSPMAC  WIDTH                   ;WIDTH statement
  110	                             C	        DSPMAC  RANDIO                  ;GET/PUT statements
  111	                             C	        DSPMAC  OPEN                    ;OPEN statement
  112	                             C	        DSPMAC  BAKC                    ;Backup character
  113	                             C	        DSPMAC  SINP                    ;Serial input
  114	                             C	        DSPMAC  SOUT                    ;Serial output
  115	                             C	        DSPMAC  GPOS                    ;Get current position
  116	                             C	        DSPMAC  GWID                    ;Get current width
  117	                             C	        ENDM
  118	                             C	
  119	                             C	
  120	                             C	;       Device Function Dispatch Table Offsets
  121	                             C	
  122	                             C	
  123	                             C	DSPMAC  MACRO   func
  124	                             C	ENT     DV_&func,2
  125	                             C	        ENDM
  126	                             C	
  127	                             C	
  128	                             C	ENTORG  0
  129	                             C	        DSPNAM
  130	                             C	ENT     DV_TABLEN,0
  131	                             C	

























IOFILM - File Manager for BASCOM-86                      Macro-86 %1(12)   1:5:17  13-Nov-81    Page 1-5



  132	                             C	        PAGE
  133	                             C	
  134	                             C	;       File Mode Definitions
  135	                             C	
  136	 = 0001                      C	MD_SQI          EQU     1
  137	 = 0002                      C	MD_SQO          EQU     2
  138	 = 0004                      C	MD_RND          EQU     4
  139	 = 0004                      C	MD_FIL          EQU     4
  140	 = 0008                      C	MD_APP          EQU     8
  141	 = 0010                      C	MD_KIL          EQU     16
  142	 = 0020                      C	MD_IBM          EQU     32
  143	 = 0040                      C	MD_USR          EQU     64
  144	 = 0080                      C	MD_BIN          EQU     128
  145	                             C	
  146	                             C	
  147	                             C	;       Operating System dependent field sizes
  148	                             C	
  149	 = 001A                      C	EOFCHR=                 'Z' and 1fh
  150	                             C	
  151	 = 0026                      C	FILNAML=                38              ;Length of $FILNAM
  152	 = 000B                      C	FILNAM_LENGTH=          11              ;Actual length of name (8+3)
  153	                             C	
  154	 = 0026                      C	FCB_LENGTH=             38              ;38 byte FCBs
  155	 = 0080                      C	REC_LENGTH=             128             ;128 byte sectors
  156	                             C	































IOFILM - File Manager for BASCOM-86                      Macro-86 %1(12)   1:5:17  13-Nov-81    Page 1-6



  157	                             C	        PAGE
  158	                             C	
  159	                             C	;-----  Basic Interpreter style File Data Block  -----
  160	                             C	
  161	                             C	;       Link block offsets
  162	                             C	
  163	 =-0006                      C	BL_SIZE=        -6                      ;Link block size (2 bytes of misc)
  164	 =-0005                      C	  FB_NUM=       -5                      ;  File number
  165	 =-0004                      C	BL_LEN=         -4                      ;Block size
  166	 =-0002                      C	BL_LNK=         -2                      ;Block link
  167	                             C	
  168	                             C	;       File Data Block offsets
  169	                             C	
  170	                             C	FILE_DATA_BLOCK STRUC
  171	                             C	
  172	 0000  ??                    C	  FD_MODE       DB      ?               ;File mode of open
  173	 0001     26 [               C	  FD_FCB        DB      FCB_LENGTH DUP (?)  ;FCB area
  174	                ??           C	
  175	                    ]        C	
  176	                             C	
  177	 0027  ????                  C	  FD_CURLOC     DW      ?               ;Current record number
  178	 0029  ??                    C	  FD_ORNOFS     DB      ?               ;Byte count in sector
  179	 002A  ??                    C	  FD_NMLOFS     DB      ?               ;Bytes left in input buffer
  180	 002B     03 [               C	                DB      3 DUP (?)       ;Unused
  181	                ??           C	
  182	                    ]        C	
  183	                             C	
  184	 002E  ??                    C	  FD_DEVICE     DB      ?               ;Device number
  185	 002F  ??                    C	  FD_WIDTH      DB      ?               ;File width
  186	 0030  ??                    C	  FD_POS        DB      ?               ;Current file position
  187	 0031  ??                    C	  FD_FLAGS      DB      ?               ;Used for load and save
  188	 0032  ??                    C	  FD_OUTPOS     DB      ?               ;Output position for tab expansion
  189	 0033     80 [               C	  FD_BUFFER     DB      REC_LENGTH DUP (?)  ;File record buffer
  190	                ??           C	
  191	                    ]        C	
  192	                             C	
  193	                             C	
  194	                             C	;       5.0 Variable Record Information
  195	                             C	
  196	 00B3  ????                  C	  FR_VRECL      DW      ?               ;Variable record length
  197	 00B5  ????                  C	  FR_PHYREC     DW      ?               ;Current physical record number
  198	 00B7  ????                  C	  FR_LOGREC     DW      ?               ;Current logical record number
  199	 00B9  ??                    C	                DB      ?               ;Future use
  200	 00BA  ????                  C	  FR_OUTPOS     DW      ?               ;Output position for sequential I/O
  201	 00BC     01 [               C	  FR_FIELD      DB      1 DUP (?)       ;Field buffer
  202	                ??           C	
  203	                    ]        C	
  204	                             C	
  205	                             C	
  206	 00BD                        C	FILE_DATA_BLOCK ENDS
  207	                             C	
  208	                             C	
  209	                             C	;       End of DEVDEF.INC
  210	 	 	 	 	


IOFILM - File Manager for BASCOM-86                      Macro-86 %1(12)   1:5:17  13-Nov-81    Page 1-7



  211	 0000	 	 	 	DATA    ENDS
  212	 	 	 	 	
  213	 	 	 	 	DC      GROUP   DATA
  214	 	 	 	 	




















































IOFILM - File Manager for BASCOM-86                      Macro-86 %1(12)   1:5:17  13-Nov-81    Page 2-1



  215	 	 	 	 	
  216	 	 	 	 	
  217	 0000	 	 	 	CODE    SEGMENT WORD PUBLIC 'CODE'
  218	 	 	 	 	
  219	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
  220	 	 	 	 	
  221	 	 	 	 	
  222	 	 	 	 	;       Run-time entries
  223	 	 	 	 	
  224	 	 	 	 	        PUBLIC  $BLALC,$BLDEA
  225	 	 	 	 	        PUBLIC  $FBLOC,$FBALC,$FBDEA
  226	 	 	 	 	
  227	 	 	 	 	
  228	 	 	 	 	;       Run-time externals
  229	 	 	 	 	
  230	 	 	 	 	        EXTRN   $$RSS:NEAR
  231	 	 	 	 	
  232	 	 	 	 	        EXTRN   $ERC_IOE:NEAR
  233	 	 	 	 	
  234	 	 	 	 	
  235	 0000	 	 	 	Locals  PROC    NEAR
  236	 	 	 	 	
  237	 	 	 	 	;**     $FBLOC - Locate file block for file number
  238	 	 	 	 	;
  239	 	 	 	 	;       ENTRY   (BX) = file number
  240	 	 	 	 	;       EXIT    (SI) = File Data Block address
  241	 	 	 	 	;               'Z' set if not present
  242	 	 	 	 	
  243	 0000	 	 	 	$FBLOC:
  244	 0000  0A FF	 	 	        OR      BH,BH
  245	 0002  75 17	 	 	        JNZ     lfbzro                  ;Error - illegal file number
  246	 	 	 	 	
  247	 0004  BE 0002 E	 	        MOV     SI,OFFSET DC:$FILPT-BL_LNK  ;(SI) = address of file list pointer
  248	 	 	 	 	
  249	 0007  8B 74 FE	 	 	lfb1:   MOV     SI,[SI].BL_LNK          ;Address of next file
  250	 000A  0B F6	 	 	        OR      SI,SI
  251	 000C  74 0F	 	 	        JZ      lfbret                  ;No more files - not open
  252	 	 	 	 	
  253	 000E  38 5C FB	 	 	        CMP     [SI].FB_NUM,BL          ;Compare file numbers
  254	 0011  75 F4	 	 	        JNZ     lfb1                    ;Not equal - try next one
  255	 	 	 	 	
  256	 0013  80 3C 00	 	 	        CMP     [SI].FD_MODE,0          ;Test if open
  257	 0016  75 05	 	 	        JNZ     lfbret                  ;  Yes
  258	 	 	 	 	
  259	 0018  E8 0061 R	 	        CALL    $FBDEA                  ;Deallocate block
  260	 	 	 	 	
  261	 001B  33 F6	 	 	lfbzro: XOR     SI,SI                   ;Set 'Z'
  262	 	 	 	 	
  263	 001D  C3	 	 	lfbret: RET                             ;  Must be non-zero
  264	 	 	 	 	
  265	 	 	 	 	
  266	 	 	 	 	
  267	 	 	 	 	
  268	 	 	 	 	;**     $FBALC/$BLALC - Allocate file block


IOFILM - File Manager for BASCOM-86                      Macro-86 %1(12)   1:5:17  13-Nov-81    Page 2-2



  269	 	 	 	 	;
  270	 	 	 	 	;       ENTRY   (BX) = desired block size (not including link area)
  271	 	 	 	 	;       EXIT    (SI) = file data block address
  272	 	 	 	 	;               Block is zeroed but not linked
  273	 	 	 	 	
  274	 001E	 	 	 	$BLALC:
  275	 001E	 	 	 	$FBALC:
  276	 001E  50	 	 	        PUSH    AX
  277	 001F  51	 	 	        PUSH    CX
  278	 0020  52	 	 	        PUSH    DX
  279	 0021  57	 	 	        PUSH    DI
  280	 0022  53	 	 	        PUSH    BX
  281	 0023  BE 0002 E	 	        MOV     SI,OFFSET DC:$FREPT-BL_LNK  ;(SI) = address of free block chain
  282	 	 	 	 	
  283	 0026  8B FE	 	 	afb1:   MOV     DI,SI                   ;Save previous link pointer
  284	 0028  8B 74 FE	 	 	        MOV     SI,[SI].BL_LNK          ;(SI) = address of next free block
  285	 002B  0B F6	 	 	        OR      SI,SI
  286	 002D  74 10	 	 	        JZ      afb2                    ;No more free entries - allocate new
  287	 	 	 	 	
  288	 002F  39 5C FC	 	 	        CMP     [SI].BL_LEN,BX          ;Check length
  289	 0032  72 F2	 	 	        JB      afb1                    ;  Not large enough
  290	 	 	 	 	
  291	 	 	 	 	;       We found a large enough one
  292	 	 	 	 	
  293	 0034  8B 44 FE	 	 	        MOV     AX,[SI].BL_LNK          ;Unlink (SI) block
  294	 0037  89 45 FE	 	 	        MOV     [DI].BL_LNK,AX
  295	 003A  8B 4C FC	 	 	        MOV     CX,[SI].BL_LEN          ;(CX) = length
  296	 003D  EB 0E	 	 	        JMP     SHORT afb3              ;Go to common code
  297	 	 	 	 	
  298	 	 	 	 	;       We must allocate a new buffer
  299	 	 	 	 	
  300	 003F  8B CB	 	 	afb2:   MOV     CX,BX                   ;Save length
  301	 0041  83 C3 06	 	 	        ADD     BX,-BL_SIZE             ;Adjust for link block
  302	 0044  E8 0000 E	 	        CALL    $$RSS                   ;Rob some string space
  303	 0047  8D 77 06	 	 	        LEA     SI,[BX-BL_SIZE]         ;Adjust for link block
  304	 004A  89 4C FC	 	 	        MOV     [SI].BL_LEN,CX          ;Set length of block
  305	 	 	 	 	
  306	 004D  8B FE	 	 	afb3:   MOV     DI,SI                   ;(DI) = block address
  307	 004F  33 C0	 	 	        XOR     AX,AX                   ;(AX) = 0
  308	 0051  D1 E9	 	 	        SHR     CX,1                    ;Zero (CX) bytes
  309	 0053  F3/ AB	 	 	        REP     STOSW
  310	 0055  73 01	 	 	        JNC     afb4
  311	 0057  AA	 	 	        STOSB
  312	 0058  5B	 	 	afb4:   POP     BX
  313	 0059  5F	 	 	        POP     DI
  314	 005A  5A	 	 	        POP     DX
  315	 005B  59	 	 	        POP     CX
  316	 005C  58	 	 	        POP     AX
  317	 005D  C3	 	 	        RET
  318	 	 	 	 	
  319	 	 	 	 	
  320	 	 	 	 	
  321	 	 	 	 	;**     $BLDEA - Deallocate block
  322	 	 	 	 	;


IOFILM - File Manager for BASCOM-86                      Macro-86 %1(12)   1:5:17  13-Nov-81    Page 2-3



  323	 	 	 	 	;       Entry   (SI) = block address to release
  324	 	 	 	 	;       USES    NONE
  325	 	 	 	 	
  326	 005E  57	 	 	$BLDEA: PUSH    DI
  327	 005F  EB 19	 	 	        JMP     SHORT dfb2
  328	 	 	 	 	
  329	 	 	 	 	
  330	 	 	 	 	
  331	 	 	 	 	;**     $FBDEA - Deallocate file block
  332	 	 	 	 	;
  333	 	 	 	 	;       ENTRY   (SI) = block address to release
  334	 	 	 	 	;       USES    NONE
  335	 	 	 	 	
  336	 0061	 	 	 	$FBDEA:
  337	 0061  57	 	 	        PUSH    DI
  338	 0062  53	 	 	        PUSH    BX
  339	 0063  BF 0002 E	 	        MOV     DI,OFFSET DC:$FILPT-BL_LNK  ;(DI) = start of file list
  340	 	 	 	 	
  341	 0066  8B DF	 	 	dfb1:   MOV     BX,DI                   ;Save previous block
  342	 0068  8B 7D FE	 	 	        MOV     DI,[DI].BL_LNK          ;(DI) = next entry
  343	 006B  0B FF	 	 	        OR      DI,DI
  344	 006D  74 18	 	 	        JZ      ercioe                  ;Not there !!!
  345	 006F  3B FE	 	 	        CMP     DI,SI
  346	 0071  75 F3	 	 	        JNE     dfb1                    ;  Try the next one
  347	 	 	 	 	
  348	 	 	 	 	;       Found the block - unlink it from file list and add to free list
  349	 	 	 	 	
  350	 0073  8B 7C FE	 	 	        MOV     DI,[SI].BL_LNK          ;Unlink (SI) block
  351	 0076  89 7F FE	 	 	        MOV     [BX].BL_LNK,DI
  352	 0079  5B	 	 	        POP     BX
  353	 	 	 	 	
  354	 007A  8B 3E 0000 E	 	dfb2:   MOV     DI,[$FREPT]             ;Add to front of free list
  355	 007E  89 36 0000 E	 	        MOV     [$FREPT],SI
  356	 0082  89 7C FE	 	 	        MOV     [SI].BL_LNK,DI          ;Link to previous head
  357	 0085  5F	 	 	        POP     DI
  358	 0086  C3	 	 	        RET
  359	 	 	 	 	
  360	 0087  E9 0000 E	 	ercioe: JMP     $ERC_IOE                ;I/O error (any would do)
  361	 	 	 	 	
  362	 	 	 	 	
  363	 008A	 	 	 	Locals  ENDP
  364	 	 	 	 	
  365	 008A	 	 	 	CODE    ENDS
  366	 	 	 	 	
  367	 	 	 	 	        END











IOFILM - File Manager for BASCOM-86                      Macro-86 %1(12)   1:5:17  13-Nov-81    Symbols-1



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

CODE . . . . . . . . . . . . . .	008A	WORD  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

AFB1 . . . . . . . . . . . . . .	L NEAR 	0026	CODE
AFB2 . . . . . . . . . . . . . .	L NEAR 	003F	CODE
AFB3 . . . . . . . . . . . . . .	L NEAR 	004D	CODE
AFB4 . . . . . . . . . . . . . .	L NEAR 	0058	CODE
BL_LEN . . . . . . . . . . . . .	Number	FFFC	
BL_LNK . . . . . . . . . . . . .	Number	FFFE	
BL_SIZE. . . . . . . . . . . . .	Number	FFFA	
DFB1 . . . . . . . . . . . . . .	L NEAR 	0066	CODE

IOFILM - File Manager for BASCOM-86                      Macro-86 %1(12)   1:5:17  13-Nov-81    Symbols-2



DFB2 . . . . . . . . . . . . . .	L NEAR 	007A	CODE
DN_KYBD. . . . . . . . . . . . .	Number	FFFF	
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
EOFCHR . . . . . . . . . . . . .	Number	001A	
ERCIOE . . . . . . . . . . . . .	L NEAR 	0087	CODE
FB_NUM . . . . . . . . . . . . .	Number	FFFB	
FCB_LENGTH . . . . . . . . . . .	Number	0026	
FILNAML. . . . . . . . . . . . .	Number	0026	
FILNAM_LENGTH. . . . . . . . . .	Number	000B	
LAST_DEVICE_OFFSET . . . . . . .	Number	0008	
LFB1 . . . . . . . . . . . . . .	L NEAR 	0007	CODE
LFBRET . . . . . . . . . . . . .	L NEAR 	001D	CODE
LFBZRO . . . . . . . . . . . . .	L NEAR 	001B	CODE
LOCALS . . . . . . . . . . . . .	N PROC	0000	CODE	Length =008A
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
$$RSS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$BLALC . . . . . . . . . . . . .	L NEAR 	001E	CODE	Global
$BLDEA . . . . . . . . . . . . .	L NEAR 	005E	CODE	Global
$ERC_IOE . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FBALC . . . . . . . . . . . . .	L NEAR 	001E	CODE	Global
$FBDEA . . . . . . . . . . . . .	L NEAR 	0061	CODE	Global
$FBLOC . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$FILPT . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$FREPT . . . . . . . . . . . . .	V WORD 	0000	DATA	External
_CPM_. . . . . . . . . . . . . .	Number	0000	
_IBM_. . . . . . . . . . . . . .	Number	0000	
_MSDOS_. . . . . . . . . . . . .	Number	0001	
___DEV . . . . . . . . . . . . .	Number	FFFC	
___ZZZ . . . . . . . . . . . . .	Number	0018	

Warning Severe
Errors	Errors 
0	0
