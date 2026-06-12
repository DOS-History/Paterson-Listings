CHAIN - CHAIN and RUN statements                                 Macro-86 %1(12)   0:58:26  13-Nov-81   Page 1-1



    1	 	 	 	 	        TITLE   CHAIN - CHAIN and RUN statements
    2	 	 	 	 	
    3	 	 	 	 	;Loader for EXE files under 86-DOS
    4	 	 	 	 	
    5	 = 0009	 	 	 	PRINT   EQU     9
    6	 = 000F	 	 	 	OPEN    EQU     15
    7	 = 001A	 	 	 	SETDMA  EQU     26
    8	 = 0027	 	 	 	RDBLK   EQU     39
    9	 = 0029	 	 	 	PARSE   EQU     41
   10	 = 0021	 	 	 	RR      EQU     33
   11	 = 000E	 	 	 	RECLEN  EQU     14
   12	 	 	 	 	
   13	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
   14	 	 	 	 	        EXTRN   $EXITSEG:WORD
   15	 0000	 	 	 	DATA    ENDS
   16	 	 	 	 	
   17	 0000	 	 	 	RUN     SEGMENT 'DATA'          ;Must be on paragraph boundary
   18	 	 	 	 	
   19	 0000	 	 	 	RUNVAR  LABEL   BYTE            ;Start of RUN variables
   20	 0000  ????	 	 	RELPT   DW      ?
   21	 0002  ????	 	 	RELSEG  DW      ?
   22	 0004	 	 	 	SIZ     LABEL   WORD            ;Share these locations
   23	 0004  ????	 	 	PAGES   DW      ?
   24	 0006  ????	 	 	RELCNT  DW      ?
   25	 0008  ????	 	 	HEADSIZ DW      ?
   26	 000A  ????	 	 	        DW      ?
   27	 000C  ????	 	 	LOADLOW DW      ?
   28	 000E  ????	 	 	INITSS  DW      ?
   29	 0010  ????	 	 	INITSP  DW      ?
   30	 0012  ????	 	 	        DW      ?
   31	 0014  ????	 	 	INITIP  DW      ?
   32	 0016  ????	 	 	INITCS  DW      ?
   33	 0018  ????	 	 	RELTAB  DW      ?
   34	 = 001A	 	 	 	RUNVARSIZ       EQU     $-RUNVAR
   35	 001A	 	 	 	EXEFCBW LABEL   WORD
   36	 001A     25 [	 	 	EXEFCB  DB      37 DUP(?)
   37	                ??	 	
   38	                    ]	 	
   39	 	 	 	 	
   40	 = 0004	 	 	 	DATPARSIZ=     ($+13-RUNVAR)/16
   41	 	 	 	 	
   42	 003F	 	 	 	RUN     ENDS
   43	 	 	 	 	
   44	 	 	 	 	
   45	 	 	 	 	DC      GROUP   RUN,DATA
   46	 	 	 	 	
   47	 	 	 	 	
   48	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   49	 	 	 	 	
   50	 	 	 	 	        PUBLIC  $RUN,$CHN
   51	 	 	 	 	
   52	 	 	 	 	        EXTRN   $ERR_OM:NEAR, $ERR_FNF:NEAR, $ERR_BFN:NEAR, $$PUTZ:NEAR
   53	 	 	 	 	
   54	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC


CHAIN - CHAIN and RUN statements                                 Macro-86 %1(12)   0:58:26  13-Nov-81   Page 1-2



   55	 	 	 	 	
   56	 0000	 	 	 	CHAIN   PROC    FAR
   57	 	 	 	 	
   58	 0000  E9 0000 E	 	BADNAM: JMP     $ERR_BFN
   59	 0003  E9 0000 E	 	NOFILE: JMP     $ERR_FNF
   60	 	 	 	 	        IF1
   61	 	 	 	 	CODPARSIZ=      0       ;Sick kludge to save bytes (and generate good code)
   62	 	 	 	 	        ELSE
   63	 = 000B	 	 	 	CODPARSIZ=      (ENDCODE+15-LOAD)/16
   64	 	 	 	 	        ENDIF
   65	 	 	 	 	
   66	 0006	 	 	 	$CHN:
   67	 0006	 	 	 	$RUN:
   68	 0006  E8 0000 E	 	        CALL    $$PUTZ          ;Make string terminated by zero
   69	 0009  8B 77 02	 	 	        MOV     SI,[BX+2]       ;Get address of string data
   70	 000C  BF 001A R	 	        MOV     DI,OFFSET DC:EXEFCB     ;Place to put resulting FCB
   71	 000F  B0 01	 	 	        MOV     AL,1            ;Skip leading separators
   72	 0011  B4 29	 	 	        MOV     AH,PARSE
   73	 0013  CD 21	 	 	        INT     33              ;Parse file name
   74	 0015  0A C0	 	 	        OR      AL,AL           ;File name OK?
   75	 0017  75 E7	 	 	        JNZ     BADNAM
   76	 0019  80 3E 001B R 20	 	        CMP     [EXEFCB+1]," "  ;File name present?
   77	 001E  74 E0	 	 	        JZ      BADNAM
   78	 0020  80 3E 0023 R 20	 	        CMP     [EXEFCB+9]," "  ;Extension present?
   79	 0025  75 0B	 	 	        JNZ     OPENIT
   80	 0027  C7 06 0023 R 5845	        MOV     [EXEFCBW+9],"XE"
   81	 002D  C6 06 0025 R 45	 	        MOV     [EXEFCB+11],"E" ;If no extension, add default "EXE"
   82	 0032	 	 	 	OPENIT:
   83	 0032  B4 0F	 	 	        MOV     AH,OPEN
   84	 0034  BA 001A R	 	        MOV     DX,OFFSET DC:EXEFCB
   85	 0037  CD 21	 	 	        INT     33              ;Open file
   86	 0039  0A C0	 	 	        OR      AL,AL           ;File present?
   87	 003B  75 C6	 	 	        JNZ     NOFILE
   88	 003D  33 C0	 	 	        XOR     AX,AX
   89	 003F  A3 003B R	 	        MOV     [EXEFCBW+RR],AX ;Set Random Record field to zero
   90	 0042  A3 003D R	 	        MOV     [EXEFCBW+RR+2],AX
   91	 0045  40	 	 	        INC     AX
   92	 0046  A3 0028 R	 	        MOV     [EXEFCBW+RECLEN],AX
   93	 0049	 	 	 	EXELOAD:
   94	 0049  BA 0000 R	 	        MOV     DX,OFFSET DC:RUNVAR     ;Read header in here
   95	 004C  B4 1A	 	 	        MOV     AH,SETDMA
   96	 004E  CD 21	 	 	        INT     33
   97	 0050  B9 001A	 	 	        MOV     CX,RUNVARSIZ    ;Amount of header info we need
   98	 0053  BA 001A R	 	        MOV     DX,OFFSET DC:EXEFCB
   99	 0056  B4 27	 	 	        MOV     AH,RDBLK
  100	 0058  CD 21	 	 	        INT     33              ;Read in header
  101	 005A  A1 0008 R	 	        MOV     AX,[HEADSIZ]    ;Size of header in paragraphs
  102	 	 	 	 	;Convert header size to 512-byte pages by dividing by 32 & rounding up
  103	 005D  05 001F	 	 	        ADD     AX,31           ;Round up first
  104	 0060  B1 05	 	 	        MOV     CL,5
  105	 0062  D3 E8	 	 	        SHR     AX,CL           ;Divide by 32
  106	 0064  A3 003B R	 	        MOV     [EXEFCBW+RR],AX ;Position in file of program
  107	 0067  C7 06 0028 R 0200	        MOV     [EXEFCBW+RECLEN],512 ;Set record size
  108	 006D  8B 1E 0000 E	 	        MOV     BX,[$EXITSEG]


CHAIN - CHAIN and RUN statements                                 Macro-86 %1(12)   0:58:26  13-Nov-81   Page 1-3



  109	 0071  83 C3 10	 	 	        ADD     BX,10H          ;First paragraph above parameter area
  110	 0074  8B 16 0004 R	 	        MOV     DX,[PAGES]      ;Total size of file in 512-byte pages
  111	 0078  2B D0	 	 	        SUB     DX,AX           ;Size of program in pages
  112	 007A  89 16 0004 R	 	        MOV     [SIZ],DX
  113	 007E  D3 E2	 	 	        SHL     DX,CL           ;Convert pages back to paragraphs
  114	 0080  03 D3	 	 	        ADD     DX,BX           ;Size + start = minimum memory (paragr.)
  115	 0082  8C D1	 	 	        MOV     CX,SS           ;Use all memory below stack segment
  116	 0084  83 E9 0F	 	 	        SUB     CX,DATPARSIZ+CODPARSIZ
  117	 0087  3B D1	 	 	        CMP     DX,CX           ;Enough memory?
  118	 0089  77 26	 	 	        JA      OUTOFMEM
  119	 008B  8B EB	 	 	        MOV     BP,BX           ;Save load segment
  120	 	 	 	 	
  121	 	 	 	 	;Move loader code and data to high end of memory
  122	 	 	 	 	
  123	 008D  8E C1	 	 	        MOV     ES,CX
  124	 008F  1E	 	 	        PUSH    DS
  125	 0090  0E	 	 	        PUSH    CS
  126	 0091  1F	 	 	        POP     DS
  127	 0092  BE 00B4 R	 	        MOV     SI,OFFSET LOAD
  128	 0095  33 FF	 	 	        XOR     DI,DI
  129	 0097  B9 0058	 	 	        MOV     CX,CODPARSIZ*8  ;Size of code in words
  130	 009A  F3/ A5	 	 	        REP     MOVSW
  131	 009C  1F	 	 	        POP     DS
  132	 009D  BE 0000 R	 	        MOV     SI,OFFSET DC:RUNVAR
  133	 00A0  B9 0020	 	 	        MOV     CX,DATPARSIZ*8
  134	 00A3  F3/ A5	 	 	        REP     MOVSW
  135	 00A5  33 C0	 	 	        XOR     AX,AX
  136	 00A7  06	 	 	        PUSH    ES
  137	 00A8  50	 	 	        PUSH    AX              ;Fake a return address
  138	 00A9  8C C0	 	 	        MOV     AX,ES
  139	 00AB  05 000B	 	 	        ADD     AX,CODPARSIZ
  140	 00AE  8E D8	 	 	        MOV     DS,AX
  141	 00B0  CB	 	 	        RET                     ;Transfer control to loader at end of memory
  142	 	 	 	 	
  143	 00B1  E9 0000 E	 	OUTOFMEM:JMP    $ERR_OM
  144	 	 	 	 	
  145	 	 	 	 	        ASSUME  DS:RUN
  146	 	 	 	 	
  147	 00B4	 	 	 	LOAD:
  148	 00B4  1E	 	 	        PUSH    DS
  149	 00B5  8E DB	 	 	        MOV     DS,BX
  150	 00B7  33 D2	 	 	        XOR     DX,DX           ;Address 0 in segment
  151	 00B9  B4 1A	 	 	        MOV     AH,SETDMA
  152	 00BB  CD 21	 	 	        INT     33              ;Set load address
  153	 00BD  1F	 	 	        POP     DS
  154	 00BE  8B 0E 0004 R	 	        MOV     CX,[SIZ]        ;Maximum record count (512 bytes ea)
  155	 00C2  BA 001A R	 	        MOV     DX,OFFSET EXEFCB
  156	 00C5  B4 27	 	 	        MOV     AH,RDBLK
  157	 00C7  CD 21	 	 	        INT     33              ;Read in up to 64K
  158	 00C9  29 0E 0004 R	 	        SUB     [SIZ],CX        ;Decrement count by amount read
  159	 00CD  74 0A	 	 	        JZ      HAVEXE          ;Did weget it all?
  160	 00CF  A8 01	 	 	        TEST    AL,1            ;Check return code if not
  161	 00D1  75 66	 	 	        JNZ     BADEXE          ;Must be zero if more to come
  162	 00D3  81 C3 0FE0	 	        ADD     BX,1000H-20H    ;Bump data segment 64K


CHAIN - CHAIN and RUN statements                                 Macro-86 %1(12)   0:58:26  13-Nov-81   Page 1-4



  163	 00D7  EB DB	 	 	        JMP     LOAD            ;Get next 64K block
  164	 	 	 	 	
  165	 00D9	 	 	 	HAVEXE:
  166	 00D9  A1 0018 R	 	        MOV     AX,[RELTAB]     ;Get position of table
  167	 00DC  A3 003B R	 	        MOV     [EXEFCBW+RR],AX ;Set in random record field
  168	 00DF  C7 06 0028 R 0001	        MOV     [EXEFCBW+RECLEN],1  ;Set one-byte record
  169	 00E5  BA 0000 R	 	        MOV     DX,OFFSET RELPT ;4-byte buffer for relocation address
  170	 00E8  B4 1A	 	 	        MOV     AH,SETDMA
  171	 00EA  CD 21	 	 	        INT     33
  172	 00EC  83 3E 0006 R 00	 	        CMP     [RELCNT],0      ;Any fixups to do?
  173	 00F1  74 22	 	 	        JZ      NOREL
  174	 00F3	 	 	 	RELOC:
  175	 00F3  B4 27	 	 	        MOV     AH,RDBLK
  176	 00F5  BA 001A R	 	        MOV     DX,OFFSET EXEFCB
  177	 00F8  B9 0004	 	 	        MOV     CX,4
  178	 00FB  CD 21	 	 	        INT     33              ;Read in one relocation pointer
  179	 00FD  0A C0	 	 	        OR      AL,AL           ;Check return code
  180	 00FF  75 38	 	 	        JNZ     BADEXE
  181	 0101  8B 3E 0000 R	 	        MOV     DI,[RELPT]      ;Get offset of relocation pointer
  182	 0105  A1 0002 R	 	        MOV     AX,[RELSEG]     ;Get segment
  183	 0108  03 C5	 	 	        ADD     AX,BP           ;Bias segment with actual load segment
  184	 010A  8E C0	 	 	        MOV     ES,AX
  185	 010C  26: 01 2D	 	        ADD     ES:[DI],BP      ;Relocate
  186	 010F  FF 0E 0006 R	 	        DEC     [RELCNT]        ;Count off
  187	 0113  75 DE	 	 	        JNZ     RELOC
  188	 0115	 	 	 	NOREL:
  189	 0115  A1 000E R	 	        MOV     AX,[INITSS]
  190	 0118  03 C5	 	 	        ADD     AX,BP
  191	 011A  8E D0	 	 	        MOV     SS,AX           ;Initialize SS
  192	 011C  8B 26 0010 R	 	        MOV     SP,[INITSP]
  193	 0120  A1 0016 R	 	        MOV     AX,[INITCS]
  194	 0123  03 C5	 	 	        ADD     AX,BP
  195	 0125  50	 	 	        PUSH    AX
  196	 0126  FF 36 0014 R	 	        PUSH    [INITIP]
  197	 012A  83 ED 10	 	 	        SUB     BP,10H          ;Point back to parameter area
  198	 012D  8E C5	 	 	        MOV     ES,BP
  199	 012F  8E DD	 	 	        MOV     DS,BP           ;Set segment registers to point to it
  200	 0131  BA 0080	 	 	        MOV     DX,80H
  201	 0134  B4 1A	 	 	        MOV     AH,SETDMA
  202	 0136  CD 21	 	 	        INT     33              ;Set default disk transfer address
  203	 0138  CB	 	 	        RET
  204	 	 	 	 	
  205	 0139	 	 	 	BADEXE:
  206	 0139  0E	 	 	        PUSH    CS
  207	 013A  1F	 	 	        POP     DS
  208	 013B  BA 014A R	 	        MOV     DX,OFFSET EXEBAD
  209	 013E  B4 09	 	 	        MOV     AH,PRINT
  210	 0140  CD 21	 	 	        INT     33
  211	 0142  83 ED 10	 	 	        SUB     BP,10H
  212	 0145  55	 	 	        PUSH    BP
  213	 0146  33 C0	 	 	        XOR     AX,AX
  214	 0148  50	 	 	        PUSH    AX
  215	 0149  CB	 	 	        RET
  216	 	 	 	 	


CHAIN - CHAIN and RUN statements                                 Macro-86 %1(12)   0:58:26  13-Nov-81   Page 1-5



  217	 014A  0D 0A 45 72 72 6F	EXEBAD  DB      13,10,"Error in EXE file",13,10,"$"
  218	       72 20 69 6E 20 45	
  219	       58 45 20 66 69 6C	
  220	       65 0D 0A 24	 	
  221	 	 	 	 	
  222	 0160	 	 	 	ENDCODE:
  223	 	 	 	 	
  224	 0160	 	 	 	CHAIN   ENDP
  225	 0160	 	 	 	CODE    ENDS
  226	 	 	 	 	        END














































CHAIN - CHAIN and RUN statements                                 Macro-86 %1(12)   0:58:26  13-Nov-81   Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0160	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  RUN. . . . . . . . . . . . . . .	003F	PARA  	NONE	'DATA'
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

BADEXE . . . . . . . . . . . . .	L NEAR 	0139	CODE
BADNAM . . . . . . . . . . . . .	L NEAR 	0000	CODE
CHAIN. . . . . . . . . . . . . .	F PROC	0000	CODE	Length =0160
CODPARSIZ. . . . . . . . . . . .	Number	000B	
DATPARSIZ. . . . . . . . . . . .	Number	0004	
ENDCODE. . . . . . . . . . . . .	L NEAR 	0160	CODE
EXEBAD . . . . . . . . . . . . .	L BYTE 	014A	CODE
EXEFCB . . . . . . . . . . . . .	L BYTE 	001A	RUN	Length =0025
EXEFCBW. . . . . . . . . . . . .	L WORD 	001A	RUN
EXELOAD. . . . . . . . . . . . .	L NEAR 	0049	CODE
HAVEXE . . . . . . . . . . . . .	L NEAR 	00D9	CODE
HEADSIZ. . . . . . . . . . . . .	L WORD 	0008	RUN
INITCS . . . . . . . . . . . . .	L WORD 	0016	RUN
INITIP . . . . . . . . . . . . .	L WORD 	0014	RUN
INITSP . . . . . . . . . . . . .	L WORD 	0010	RUN
INITSS . . . . . . . . . . . . .	L WORD 	000E	RUN
LOAD . . . . . . . . . . . . . .	L NEAR 	00B4	CODE
LOADLOW. . . . . . . . . . . . .	L WORD 	000C	RUN
NOFILE . . . . . . . . . . . . .	L NEAR 	0003	CODE
NOREL. . . . . . . . . . . . . .	L NEAR 	0115	CODE
OPEN . . . . . . . . . . . . . .	Number	000F	
OPENIT . . . . . . . . . . . . .	L NEAR 	0032	CODE
OUTOFMEM . . . . . . . . . . . .	L NEAR 	00B1	CODE
PAGES. . . . . . . . . . . . . .	L WORD 	0004	RUN
PARSE. . . . . . . . . . . . . .	Number	0029	
PRINT. . . . . . . . . . . . . .	Number	0009	
RDBLK. . . . . . . . . . . . . .	Number	0027	
RECLEN . . . . . . . . . . . . .	Number	000E	
RELCNT . . . . . . . . . . . . .	L WORD 	0006	RUN
RELOC. . . . . . . . . . . . . .	L NEAR 	00F3	CODE
RELPT. . . . . . . . . . . . . .	L WORD 	0000	RUN
RELSEG . . . . . . . . . . . . .	L WORD 	0002	RUN
RELTAB . . . . . . . . . . . . .	L WORD 	0018	RUN
RR . . . . . . . . . . . . . . .	Number	0021	
RUNVAR . . . . . . . . . . . . .	L BYTE 	0000	RUN
RUNVARSIZ. . . . . . . . . . . .	Number	001A	
SETDMA . . . . . . . . . . . . .	Number	001A	
SIZ. . . . . . . . . . . . . . .	L WORD 	0004	RUN
$$PUTZ . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$CHN . . . . . . . . . . . . . .	L NEAR 	0006	CODE	Global
$ERR_BFN . . . . . . . . . . . .	L NEAR 	0000	CODE	External


CHAIN - CHAIN and RUN statements                                 Macro-86 %1(12)   0:58:26  13-Nov-81   Symbols-1



$ERR_FNF . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERR_OM. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$EXITSEG . . . . . . . . . . . .	V WORD 	0000	DATA	External
$RUN . . . . . . . . . . . . . .	L NEAR 	0006	CODE	Global

Warning Severe
Errors	Errors 
0	0
















































