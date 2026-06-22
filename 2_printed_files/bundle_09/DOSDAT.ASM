DOSDAT - MS-DOS DATE$ and TIME$ Support                  Macro-86 %1(12)   1:0:16  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   DOSDAT - MS-DOS DATE$ and TIME$ Support
    2	 	 	 	 	
    3	 	 	 	 	        .SALL
    4	 	 	 	 	
    5	                             C	        INCLUDE MSDOS.INC
    6	                             C	00100   ; MSDOS.INC - MS-DOS I/O Macro defns.
    7	                             C	00200   
    8	                             C	00300   ; VECTOR INTERRUPT EQUATES
    9	                             C	00400   
   10	 = 0021                      C	00500   I_DOSIO=        21H             ;MSDOS_IO
   11	                             C	00600   
   12	                             C	00700   
   13	                             C	00800   ; MS-DOS INTERRUPT CALL MACRO DEFNS
   14	                             C	00900   
   15	                             C	01000   DOSMAC  MACRO   NAM
   16	                             C	01100   NAM     MACRO   FUNC
   17	                             C	01200   IFNB    <FUNC>
   18	                             C	01300           MOV     AH,FUNC
   19	                             C	01400   ENDIF
   20	                             C	01500           INT     I_&NAM
   21	                             C	01600           ENDM
   22	                             C	01700           ENDM
   23	                             C	01800   
   24	                             C	01900   
   25	                             C	02000           DOSMAC  DOSIO           ;;MSDOS_IO
   26	                             C	02100   
   27	                             C	02200   
   28	 =                           C	02300   ENABLE  EQU     STI             ;Enable  Interrupts
   29	 =                           C	02400   DISABLE EQU     CLI             ;Disable Interrupts
   30	 	 	 	 	
   31	 	 	 	 	
   32	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
   33	 	 	 	 	
   34	 	 	 	 	        EXTRN   $$SPSV:WORD
   35	 	 	 	 	
   36	 0000	 	 	 	DATA    ENDS
   37	 	 	 	 	
   38	 	 	 	 	DC      GROUP   DATA
   39	 	 	 	 	
   40	 	 	 	 	
   41	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   42	 	 	 	 	
   43	 	 	 	 	        PUBLIC  $DAT, $DAF             ;DATE$
   44	 	 	 	 	        PUBLIC  $TIM, $TIF             ;TIME$
   45	 	 	 	 	
   46	 	 	 	 	        EXTRN   $$ATS:NEAR, $$DITS:NEAR
   47	 	 	 	 	        EXTRN   $ERC_FC:NEAR
   48	 	 	 	 	
   49	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   50	 	 	 	 	
   51	 = 002A	 	 	 	GETDAT= 42              ;Get Date Function
   52	 = 002B	 	 	 	SETDAT= 43              ;Set Date Function
   53	 = 002C	 	 	 	GETTIM= 44              ;Get Time Function
   54	 = 002D	 	 	 	SETTIM= 45              ;Set Time Function


DOSDAT - MS-DOS DATE$ and TIME$ Support                  Macro-86 %1(12)   1:0:16  13-Nov-81    Page 1-2



   55	 	 	 	 	
   56	 	 	 	 	
   57	 	 	 	 	        SUBTTL  $DAT - Set Date.





















































DOSDAT - MS-DOS DATE$ and TIME$ Support                  Macro-86 %1(12)   1:0:16  13-Nov-81    Page 2-1
$DAT - Set Date.


   58	 	 	 	 	
   59	 	 	 	 	;$DAT - Set Date.
   60	 	 	 	 	
   61	 0000	 	 	 	DOSDAT  PROC    FAR
   62	 	 	 	 	
   63	 0000	 	 	 	$DAT:
   64	 0000  89 26 0000 E	 	        MOV     [$$SPSV],SP
   65	 0004  50	 	 	        PUSH    AX
   66	 0005  51	 	 	        PUSH    CX
   67	 0006  52	 	 	        PUSH    DX
   68	 0007  56	 	 	        PUSH    SI
   69	 0008  53	 	 	        PUSH    BX
   70	 0009  8B 77 02	 	 	        MOV     SI,[BX+2]       ;[SI] has addr of string.
   71	 000C  8B 1F	 	 	        MOV     BX,[BX]         ;[BX] has string length
   72	 000E  0B DB	 	 	        OR      BX,BX           ;String must not be null
   73	 0010  74 7D	 	 	        JZ      DATE_ERROR      ;Brif null str
   74	 0012  E8 013B R	 	        CALL    GETNUM          ;Get 1 or 2 digit number
   75	 0015  8A F4	 	 	        MOV     DH,AH           ;[DH] = month
   76	 0017  E8 011B R	 	        CALL    DATSEP
   77	 001A  E8 013B R	 	        CALL    GETNUM
   78	 001D  8A D4	 	 	        MOV     DL,AH           ;[DL] = day
   79	 001F  E8 011B R	 	        CALL    DATSEP
   80	 0022  E8 013B R	 	        CALL    GETNUM
   81	 0025  B9 076C	 	 	        MOV     CX,1900         ;Bias in case only 2-digit year
   82	 0028  0B DB	 	 	        OR      BX,BX           ;End-of-string?
   83	 002A  74 09	 	 	        JZ      DATE2           ;Brif so.
   84	 002C  B0 64	 	 	        MOV     AL,100
   85	 002E  F6 E4	 	 	        MUL     AH              ;Mult decade by 100
   86	 0030  8B C8	 	 	        MOV     CX,AX           ;Save bias for year add
   87	 0032  E8 013B R	 	        CALL    GETNUM          ;Get year (digits 3 & 4).
   88	 0035	 	 	 	DATE2:
   89	 0035  8A C4	 	 	        MOV     AL,AH
   90	 0037  B4 00	 	 	        MOV     AH,0
   91	 0039  03 C8	 	 	        ADD     CX,AX           ;Add 2 digits of base to century
   92	 	 	 	 	        DOSIO   SETDAT          ;Give date to DOS.
   93	 003F	 	 	 	$TIM_RET:
   94	 003F  0A C0	 	 	        OR      AL,AL           ;Date (or Time) OK?
   95	 0041  75 4C	 	 	        JNZ     DATE_ERROR      ;Brif not.
   96	 0043  5B	 	 	        POP     BX
   97	 0044  E8 0000 E	 	        CALL    $$DITS          ;Delete the Temp
   98	 0047  53	 	 	        PUSH    BX
   99	 0048	 	 	 	$DAF_RET:
  100	 0048  5B	 	 	        POP     BX
  101	 0049  5E	 	 	        POP     SI
  102	 004A  5A	 	 	        POP     DX
  103	 004B  59	 	 	        POP     CX
  104	 004C  58	 	 	        POP     AX
  105	 004D  CB	 	 	        RET                     ;Exit.
  106	 004E	 	 	 	DOSDAT  ENDP
  107	 	 	 	 	
  108	 	 	 	 	
  109	 	 	 	 	        SUBTTL  $DAF - Get Date.




DOSDAT - MS-DOS DATE$ and TIME$ Support                  Macro-86 %1(12)   1:0:16  13-Nov-81    Page 3-1
$DAF - Get Date.


  110	 	 	 	 	
  111	 	 	 	 	;$DAF - Get Date.
  112	 	 	 	 	
  113	 004E	 	 	 	$DAF:
  114	 004E  50	 	 	        PUSH    AX
  115	 004F  51	 	 	        PUSH    CX
  116	 0050  52	 	 	        PUSH    DX
  117	 0051  56	 	 	        PUSH    SI
  118	 0052  BB 000A	 	 	        MOV     BX,10
  119	 0055  E8 0000 E	 	        CALL    $$ATS           ;Get space for 10 char string
  120	 0058  53	 	 	        PUSH    BX              ;Save String Descriptor
  121	 0059  52	 	 	        PUSH    DX              ;Save addr of string
  122	 	 	 	 	        DOSIO   GETDAT          ;Get Date from DOS
  123	 005E  5B	 	 	        POP     BX              ;Restore addr of String
  124	 005F  8A C6	 	 	        MOV     AL,DH
  125	 0061  E8 0160 R	 	        CALL    PUTCHR          ;Store ascii month
  126	 0064  B0 2D	 	 	        MOV     AL,"-"
  127	 0066  E8 016C R	 	        CALL    PUTCH2
  128	 0069  8A C2	 	 	        MOV     AL,DL
  129	 006B  E8 0160 R	 	        CALL    PUTCHR          ;Store ascii day
  130	 006E  B0 2D	 	 	        MOV     AL,"-"
  131	 0070  E8 016C R	 	        CALL    PUTCH2
  132	 0073  81 E9 076C	 	        SUB     CX,1900         ;Reduce year by two digits
  133	 0077  80 F9 64	 	 	        CMP     CL,100          ;See if in 20th century
  134	 007A  B5 13	 	 	        MOV     CH,19           ;Setup 20th century in case
  135	 007C  72 05	 	 	        JB      DATEF2          ;Brif so.
  136	 007E  80 D9 64	 	 	        SBB     CL,100          ;subtract into next century
  137	 0081  FE C5	 	 	        INC     CH              ;21st century
  138	 0083	 	 	 	DATEF2:
  139	 0083  8A C5	 	 	        MOV     AL,CH
  140	 0085  E8 0160 R	 	        CALL    PUTCHR          ;Store ascii century
  141	 0088  8A C1	 	 	        MOV     AL,CL
  142	 008A  E8 0160 R	 	        CALL    PUTCHR          ;Store ascii year.
  143	 	 	 	 	
  144	 008D  EB B9	 	 	        JMP     $DAF_RET        ;Return Date String (Desc on stack).
  145	 	 	 	 	
  146	 008F	 	 	 	DATE_ERROR:
  147	 008F  E9 0000 E	 	        JMP     $ERC_FC         ;Complain
  148	 	 	 	 	
  149	 	 	 	 	
  150	 	 	 	 	        SUBTTL  $TIM - Set Time.















DOSDAT - MS-DOS DATE$ and TIME$ Support                  Macro-86 %1(12)   1:0:16  13-Nov-81    Page 4-1
$TIM - Set Time.


  151	 	 	 	 	
  152	 	 	 	 	;$TIM - Set Time.
  153	 	 	 	 	
  154	 0092	 	 	 	$TIM:
  155	 0092  89 26 0000 E	 	        MOV     [$$SPSV],SP
  156	 0096  50	 	 	        PUSH    AX
  157	 0097  51	 	 	        PUSH    CX
  158	 0098  52	 	 	        PUSH    DX
  159	 0099  56	 	 	        PUSH    SI
  160	 009A  53	 	 	        PUSH    BX
  161	 009B  8B 77 02	 	 	        MOV     SI,[BX+2]       ;[SI] has addr of string.
  162	 009E  8B 1F	 	 	        MOV     BX,[BX]         ;[BX] has string length
  163	 00A0  0B DB	 	 	        OR      BX,BX           ;String must not be null
  164	 00A2  74 74	 	 	        JZ      TIME_ERROR      ;Brif null str
  165	 00A4  E8 013B R	 	        CALL    GETNUM          ;Get 1 or 2 digit number
  166	 00A7  8A EC	 	 	        MOV     CH,AH           ;[CH] = hours
  167	 00A9  E8 012B R	 	        CALL    TIMSEP
  168	 00AC  E8 013B R	 	        CALL    GETNUM
  169	 00AF  8A CC	 	 	        MOV     CL,AH           ;[CL] = minutes
  170	 00B1  E8 012B R	 	        CALL    TIMSEP
  171	 00B4  E8 013B R	 	        CALL    GETNUM
  172	 00B7  8A F4	 	 	        MOV     DH,AH           ;[DH] = seconds 
  173	 00B9  E8 012B R	 	        CALL    TIMSEP
  174	 00BC  E8 013B R	 	        CALL    GETNUM
  175	 00BF  8A D4	 	 	        MOV     DL,AH           ;[DL] = 100ths. 
  176	 	 	 	 	        DOSIO   SETTIM          ;Give Time to DOS.
  177	 00C5  E9 003F R	 	        JMP     $TIM_RET        ;Check Time OK & Exit.
  178	 	 	 	 	
  179	 	 	 	 	
  180	 	 	 	 	        SUBTTL  $TIF - Get Time.


























DOSDAT - MS-DOS DATE$ and TIME$ Support                  Macro-86 %1(12)   1:0:16  13-Nov-81    Page 5-1
$TIF - Get Time.


  181	 	 	 	 	
  182	 	 	 	 	;$TIF - Get Time.
  183	 	 	 	 	
  184	 00C8	 	 	 	$TIF:
  185	 00C8  50	 	 	        PUSH    AX
  186	 00C9  51	 	 	        PUSH    CX
  187	 00CA  52	 	 	        PUSH    DX
  188	 00CB  56	 	 	        PUSH    SI
  189	 00CC  BB 000B	 	 	        MOV     BX,11
  190	 00CF  E8 0000 E	 	        CALL    $$ATS           ;Get space for 11 char string
  191	 00D2  53	 	 	        PUSH    BX              ;Save String Descriptor
  192	 00D3  52	 	 	        PUSH    DX              ;Save addr of string
  193	 	 	 	 	        DOSIO   GETTIM          ;Get Time from DOS
  194	 00D8  80 FA 32	 	 	        CMP     DL,50
  195	 00DB  72 14	 	 	        JB      TIMEF2          ;Brif .lt. 1/2 sec
  196	 00DD  FE C6	 	 	        INC     DH              ;Bump secs.
  197	 00DF  80 FE 3C	 	 	        CMP     DH,60
  198	 00E2  72 0D	 	 	        JB      TIMEF2          ;Brif no ovf
  199	 00E4  B6 00	 	 	        MOV     DH,0
  200	 00E6  FE C1	 	 	        INC     CL              ;Bump mins.
  201	 00E8  80 F9 3C	 	 	        CMP     CL,60
  202	 00EB  72 04	 	 	        JB      TIMEF2          ;Brif no ovf
  203	 00ED  B1 00	 	 	        MOV     CL,0
  204	 00EF  FE C5	 	 	        INC     CH              ;Bump hrs.
  205	 00F1	 	 	 	TIMEF2:
  206	 00F1  5B	 	 	        POP     BX              ;Restore addr of String
  207	 00F2  8A C5	 	 	        MOV     AL,CH
  208	 00F4  E8 0160 R	 	        CALL    PUTCHR          ;Store ascii hours
  209	 00F7  B0 3A	 	 	        MOV     AL,":"
  210	 00F9  E8 016C R	 	        CALL    PUTCH2
  211	 00FC  8A C1	 	 	        MOV     AL,CL
  212	 00FE  E8 0160 R	 	        CALL    PUTCHR          ;Store ascii minutes
  213	 0101  B0 3A	 	 	        MOV     AL,":"
  214	 0103  E8 016C R	 	        CALL    PUTCH2
  215	 0106  8A C6	 	 	        MOV     AL,DH
  216	 0108  E8 0160 R	 	        CALL    PUTCHR          ;Store ascii seconds.
  217	 010B  B0 2E	 	 	        MOV     AL,"."
  218	 010D  E8 016C R	 	        CALL    PUTCH2
  219	 0110  8A C2	 	 	        MOV     AL,DL
  220	 0112  E8 0160 R	 	        CALL    PUTCHR          ;Store ascii 100ths.
  221	 	 	 	 	
  222	 0115  E9 0048 R	 	        JMP     $DAF_RET        ;Return Time String (Desc on stack).
  223	 	 	 	 	
  224	 0118	 	 	 	TIME_ERROR:
  225	 0118  E9 008F R	 	        JMP     DATE_ERROR      ;Complain
  226	 	 	 	 	
  227	 	 	 	 	
  228	 	 	 	 	        SUBTTL  $DATE and $TIME Utility Subroutines








DOSDAT - MS-DOS DATE$ and TIME$ Support                  Macro-86 %1(12)   1:0:16  13-Nov-81    Page 6-1
$DATE and $TIME Utility Subroutines


  229	 	 	 	 	
  230	 011B	 	 	 	DATSEP:
  231	 011B  0B DB	 	 	        OR      BX,BX
  232	 011D  74 F9	 	 	        JZ      TIME_ERROR      ;Error if string empty.
  233	 011F  4B	 	 	        DEC     BX              ;Length -1
  234	 0120  AC	 	 	        LODSB
  235	 0121  3C 2F	 	 	        CMP     AL,"/"
  236	 0123  74 26	 	 	        JZ      GETNUX
  237	 0125  3C 2D	 	 	        CMP     AL,"-"
  238	 0127  74 22	 	 	        JZ      GETNUX
  239	 0129  EB ED	 	 	        JMP     TIME_ERROR
  240	 	 	 	 	
  241	 	 	 	 	
  242	 012B	 	 	 	TIMSEP:
  243	 012B  0B DB	 	 	        OR      BX,BX
  244	 012D  74 1C	 	 	        JZ      GETNUX
  245	 012F  4B	 	 	        DEC     BX
  246	 0130  AC	 	 	        LODSB
  247	 0131  3C 3A	 	 	        CMP     AL,":"
  248	 0133  74 16	 	 	        JZ      GETNUX
  249	 0135  3C 2E	 	 	        CMP     AL,"."
  250	 0137  74 12	 	 	        JZ      GETNUX
  251	 0139  EB DD	 	 	        JMP     TIME_ERROR
  252	 	 	 	 	
  253	 013B	 	 	 	GETNUM:
  254	 013B  E8 014C R	 	        CALL    DIGIT
  255	 013E  72 D8	 	 	        JB      TIME_ERROR
  256	 0140  8A E0	 	 	        MOV     AH,AL
  257	 0142  E8 014C R	 	        CALL    DIGIT
  258	 0145  72 04	 	 	        JB      GETNUX
  259	 0147  D5 0A	 	 	        AAD                     ;Convert BCD to Binary
  260	 0149  8A E0	 	 	        MOV     AH,AL
  261	 014B	 	 	 	GETNUX:
  262	 014B  C3	 	 	        RET
  263	 014C	 	 	 	DIGIT:
  264	 014C  8A C3	 	 	        MOV     AL,BL           ;Init to 0 if string exhausted
  265	 014E  0B DB	 	 	        OR      BX,BX           ;End-of-string?
  266	 0150  74 F9	 	 	        JZ      GETNUX          ;Brif so, returns 0
  267	 0152  8A 04	 	 	        MOV     AL,[SI]
  268	 0154  1C 30	 	 	        SBB     AL,"0"
  269	 0156  72 F3	 	 	        JB      GETNUX
  270	 0158  3C 0A	 	 	        CMP     AL,10
  271	 015A  F5	 	 	        CMC
  272	 015B  72 EE	 	 	        JB      GETNUX
  273	 015D  4B	 	 	        DEC     BX              ;Length -1
  274	 015E  46	 	 	        INC     SI
  275	 015F  C3	 	 	        RET
  276	 	 	 	 	
  277	 	 	 	 	
  278	 0160	 	 	 	PUTCHR:
  279	 0160  D4 0A	 	 	        AAM                     ;Convert to unpacked BCD
  280	 0162  86 C4	 	 	        XCHG    AL,AH
  281	 0164  0D 3030	 	 	        OR      AX,"00"         ;Add "0" bias to both digits.
  282	 0167  E8 016C R	 	        CALL    PUTCH2


DOSDAT - MS-DOS DATE$ and TIME$ Support                  Macro-86 %1(12)   1:0:16  13-Nov-81    Page 6-2
$DATE and $TIME Utility Subroutines


  283	 016A  8A C4	 	 	        MOV     AL,AH
  284	 016C	 	 	 	PUTCH2:
  285	 016C  88 07	 	 	        MOV     [BX],AL         ;store char in string
  286	 016E  43	 	 	        INC     BX
  287	 016F  C3	 	 	        RET
  288	 	 	 	 	
  289	 	 	 	 	
  290	 0170	 	 	 	CODE    ENDS
  291	 	 	 	 	        END















































DOSDAT - MS-DOS DATE$ and TIME$ Support                  Macro-86 %1(12)   1:0:16  13-Nov-81    Symbols-1



Macros:

	 	N a m e  	 	Length

DOSIO. . . . . . . . . . . . . .	0002	
DOSMAC . . . . . . . . . . . . .	0002	

Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0170	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

DATE2. . . . . . . . . . . . . .	L NEAR 	0035	CODE
DATEF2 . . . . . . . . . . . . .	L NEAR 	0083	CODE
DATE_ERROR . . . . . . . . . . .	L NEAR 	008F	CODE
DATSEP . . . . . . . . . . . . .	L NEAR 	011B	CODE
DIGIT. . . . . . . . . . . . . .	L NEAR 	014C	CODE
DISABLE. . . . . . . . . . . . .	Opcode	 	
DOSDAT . . . . . . . . . . . . .	F PROC	0000	CODE	Length =004E
ENABLE . . . . . . . . . . . . .	Opcode	 	
GETDAT . . . . . . . . . . . . .	Number	002A	
GETNUM . . . . . . . . . . . . .	L NEAR 	013B	CODE
GETNUX . . . . . . . . . . . . .	L NEAR 	014B	CODE
GETTIM . . . . . . . . . . . . .	Number	002C	
I_DOSIO. . . . . . . . . . . . .	Number	0021	
PUTCH2 . . . . . . . . . . . . .	L NEAR 	016C	CODE
PUTCHR . . . . . . . . . . . . .	L NEAR 	0160	CODE
SETDAT . . . . . . . . . . . . .	Number	002B	
SETTIM . . . . . . . . . . . . .	Number	002D	
TIMEF2 . . . . . . . . . . . . .	L NEAR 	00F1	CODE
TIME_ERROR . . . . . . . . . . .	L NEAR 	0118	CODE
TIMSEP . . . . . . . . . . . . .	L NEAR 	012B	CODE
$$ATS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$DITS . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DAF . . . . . . . . . . . . . .	L NEAR 	004E	CODE	Global
$DAF_RET . . . . . . . . . . . .	L NEAR 	0048	CODE
$DAT . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TIF . . . . . . . . . . . . . .	L NEAR 	00C8	CODE	Global
$TIM . . . . . . . . . . . . . .	L NEAR 	0092	CODE	Global
$TIM_RET . . . . . . . . . . . .	L NEAR 	003F	CODE

Warning Severe
Errors	Errors 
0	0



