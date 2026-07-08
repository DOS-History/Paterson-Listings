INPUT - INPUT statement                                  Macro-86 %1(12)   1:3:25  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   INPUT - INPUT statement
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        PUBLIC  $FILBUF,$INBUF,$BUFLEN,$LINLEN
    6	 	 	 	 	
    7	 	 	 	 	        EXTRN   VALTYP:BYTE,$$ERRV:WORD,$AC:WORD,$PTRFIL:WORD,$$SPSV:WORD
    8	 	 	 	 	
    9	 = 0000	 	 	 	EOL     EQU     0
   10	 	 	 	 	
   11	 0000  ????	 	 	$FILBUF DW      ?
   12	 0002	 	 	 	LONGRET LABEL   DWORD
   13	 0002	 	 	 	RETOFF  LABEL   WORD
   14	 0002  ????	 	 	TYPLST  DW      ?               ;Share with return addr. offset
   15	 0004  ????	 	 	RETSEG  DW      ?
   16	 0006  ????	 	 	DATAPT  DW      ?
   17	 0008  ????	 	 	CLEAN   DW      ?
   18	 000A  ??	 	 	TYPCNT  DB      ?
   19	 000B  ??	 	 	VALCNT  DB      ?
   20	 	 	 	 	
   21	 000C  ??	 	 	$BUFLEN DB      ?
   22	 000D  ??	 	 	$LINLEN DB      ?
   23	 000E  0100 [	 	 	$INBUF  DB      256 DUP (?)
   24	                ??	 	
   25	                    ]	 	
   26	 	 	 	 	
   27	 	 	 	 	
   28	 010E	 	 	 	DATA    ENDS
   29	 	 	 	 	
   30	 	 	 	 	
   31	 0000	 	 	 	CONST   SEGMENT BYTE PUBLIC 'CONST'
   32	 	 	 	 	
   33	 0000  02 04 08 03	 	TYPTAB  DB      2,4,8,3
   34	 	 	 	 	
   35	 0004	 	 	 	CONST   ENDS
   36	 	 	 	 	
   37	 	 	 	 	
   38	 	 	 	 	DC      GROUP   DATA,CONST
   39	 	 	 	 	
   40	 	 	 	 	
   41	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   42	 	 	 	 	
   43	 	 	 	 	        PUBLIC  $IPUA,$IPUB,$INPOVF
   44	 	 	 	 	
   45	 	 	 	 	        EXTRN   $TYPTX:NEAR,$FIN:NEAR,$GETCH:NEAR,$IN0A:NEAR,$REDO:FAR
   46	 	 	 	 	        EXTRN   $CONT:NEAR,$$CTS:NEAR,$$TCR:NEAR,$SAS:FAR
   47	 	 	 	 	
   48	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   49	 	 	 	 	
   50	 0000	 	 	 	INPUT   PROC    FAR             ;Set up long returns
   51	 	 	 	 	
   52	 	 	 	 	
   53	 	 	 	 	;***  $IPUA - Get input line
   54	 	 	 	 	;


INPUT - INPUT statement                                  Macro-86 %1(12)   1:3:25  13-Nov-81    Page 1-2



   55	 	 	 	 	; Inputs:
   56	 	 	 	 	;       Return address on top of stack is long pointer to list of values to
   57	 	 	 	 	;       input. First byte in list is number of values, following are types of
   58	 	 	 	 	;       each value. Thus the calling sequence looks like this:
   59	 	 	 	 	;
   60	 	 	 	 	;               CALL    $IPUA
   61	 	 	 	 	;               DB      <number of values, n>
   62	 	 	 	 	;               DB      <type of first value>
   63	 	 	 	 	;               DB      <type of second value>
   64	 	 	 	 	;               . . .
   65	 	 	 	 	;               DB      <type of nth value>
   66	 	 	 	 	;               <return to here>
   67	 	 	 	 	;
   68	 	 	 	 	;       The type of values are:
   69	 	 	 	 	;
   70	 	 	 	 	;       4 = Integer
   71	 	 	 	 	;       5 = Single precision
   72	 	 	 	 	;       6 = Double precision
   73	 	 	 	 	;       7 = String
   74	 	 	 	 	;
   75	 	 	 	 	; Function:
   76	 	 	 	 	;       Prompt and read input line, and decode each value, checking to be
   77	 	 	 	 	;       sure everything is OK and types match. If anything goes wrong, print
   78	 	 	 	 	;       "?Redo from start" and start over. Values will be saved on stack, so
   79	 	 	 	 	;       user code must not have anything saved on the stack when this is
   80	 	 	 	 	;       called. Values will be read with $IPUB.
   81	 	 	 	 	; Outputs:
   82	 	 	 	 	;       None.
   83	 	 	 	 	; Registers:
   84	 	 	 	 	;       All except BP destroyed.
   85	 	 	 	 	
   86	 0000	 	 	 	$IPUA:
   87	 0000  5F	 	 	        POP     DI
   88	 0001  07	 	 	        POP     ES              ;ES:DI point to list of types
   89	 0002  26: 8A 05	 	        MOV     AL,ES:[DI]      ;Get number of values to input
   90	 0005  47	 	 	        INC     DI
   91	 0006  8C 06 0004 R	 	        MOV     [RETSEG],ES
   92	 000A  89 3E 0002 R	 	        MOV     [TYPLST],DI     ;If we have to restart, remember start of list
   93	 000E  A2 000B R	 	        MOV     [VALCNT],AL     ;Remember number of values
   94	 0011  89 26 0008 R	 	        MOV     [CLEAN],SP      ;Clean stack value
   95	 0015  89 26 0006 R	 	        MOV     [DATAPT],SP     ;Read values back from here
   96	 0019	 	 	 	REDO:
   97	 0019  A2 000A R	 	        MOV     [TYPCNT],AL     ;Initialize count of values
   98	 001C  BE 000E R	 	        MOV     SI,OFFSET DC:$INBUF
   99	 001F	 	 	 	EACHVAL:
  100	 001F  26: 8A 05	 	        MOV     AL,ES:[DI]      ;Get next type
  101	 0022  47	 	 	        INC     DI
  102	 0023  BB FFFC R	 	        MOV     BX,OFFSET DC:TYPTAB-4  ;Convert type so FIN will understand
  103	 0026  D7	 	 	        XLAT
  104	 0027  98	 	 	        CBW
  105	 0028  50	 	 	        PUSH    AX              ;Put type on stack
  106	 0029  A2 0000 E	 	        MOV     [VALTYP],AL
  107	 002C  06	 	 	        PUSH    ES
  108	 002D  57	 	 	        PUSH    DI


INPUT - INPUT statement                                  Macro-86 %1(12)   1:3:25  13-Nov-81    Page 1-3



  109	 002E  89 26 0000 E	 	        MOV     [$$SPSV],SP     ;Save stack address here if error
  110	 0032  1E	 	 	        PUSH    DS
  111	 0033  07	 	 	        POP     ES              ;ES = DS
  112	 0034  55	 	 	        PUSH    BP
  113	 0035  BA 2C20	 	 	        MOV     DX,","*256+" "  ;Set up numeric delimiters
  114	 0038  3C 03	 	 	        CMP     AL,3            ;Is it string?
  115	 003A  75 02	 	 	        JNZ     CALLBUF
  116	 003C  8A D6	 	 	        MOV     DL,DH           ;Make both delimiters ","
  117	 003E	 	 	 	CALLBUF:
  118	 003E  FF 16 0000 R	 	        CALL    [$FILBUF]       ;Get a buffer if disk I/O
  119	 0042  E8 0000 E	 	        CALL    $FIN            ;Get number or string
  120	 0045  5D	 	 	        POP     BP
  121	 0046  5F	 	 	        POP     DI
  122	 0047  07	 	 	        POP     ES
  123	 0048  80 3E 0000 E 04	 	        CMP     [VALTYP],4      ;Set flags on type of value
  124	 004D  BB 0000 E	 	        MOV     BX,OFFSET DC:$AC
  125	 0050  72 03	 	 	        JB      PUSHAC          ;Don't do high word if integer or string
  126	 0052  FF 77 02	 	 	        PUSH    [BX+2]          ;Push highest word
  127	 0055	 	 	 	PUSHAC:
  128	 0055  FF 37	 	 	        PUSH    [BX]
  129	 0057  76 06	 	 	        JBE     NXTVAL          ;Only push low words if D.P.
  130	 0059  FF 77 FE	 	 	        PUSH    [BX-2]
  131	 005C  FF 77 FC	 	 	        PUSH    [BX-4]
  132	 005F	 	 	 	NXTVAL:
  133	 005F  81 3E 0000 E 0000 E	        CMP     [$$ERRV],OFFSET $CONT   ;See if vector has been changed
  134	 0065  74 36	 	 	        JZ      CNTDSK          ;If not, we're doing disk input
  135	 0067  E8 0000 E	 	        CALL    $GETCH          ;Skip over blanks, etc.
  136	 006A  FE 0E 000A R	 	        DEC     [TYPCNT]        ;Any values left?
  137	 006E  74 38	 	 	        JZ      CHKEND
  138	 0070  3C 2C	 	 	        CMP     AL,","          ;Values must be separated by ","
  139	 0072  74 AB	 	 	        JZ      EACHVAL
  140	 0074	 	 	 	INPERR:
  141	 	 	 	 	;Come here to restart if any error occured
  142	 0074  8B 26 0008 R	 	        MOV     SP,[CLEAN]
  143	 0078  E8 0000 E	 	        CALL    $TYPTX
  144	 007B  3F 52 65 64 6F 20	        DB      "?Redo from star","t"+80H
  145	       66 72 6F 6D 20 73	
  146	       74 61 72 F4	 	
  147	 008B  E8 0000 E	 	        CALL    $$TCR           ;Output CR/LF
  148	 008E  9A 0000 ---- E	 	        CALL    $REDO           ;Get new input line
  149	 0093  A0 000B R	 	        MOV     AL,[VALCNT]     ;Re-initialize
  150	 0096  C4 3E 0002 R	 	        LES     DI,[LONGRET]
  151	 009A  E9 0019 R	 	        JMP     REDO
  152	 	 	 	 	
  153	 	 	 	 	
  154	 009D	 	 	 	CNTDSK:
  155	 009D  FE 0E 000A R	 	        DEC     [TYPCNT]        ;Count the values
  156	 00A1  74 03	 	 	        JZ      donval          ;Can't make it all the way
  157	 00A3  E9 001F R	 	        JMP     EACHVAL
  158	 00A6	 	 	 	donval:
  159	 00A6  32 C0	 	 	        XOR     AL,AL           ;Flag that we reached the end
  160	 00A8	 	 	 	CHKEND:
  161	 00A8  0A C0	 	 	        OR      AL,AL           ;Did we reach end of line?
  162	 00AA  75 C8	 	 	        JNZ     INPERR


INPUT - INPUT statement                                  Macro-86 %1(12)   1:3:25  13-Nov-81    Page 1-4



  163	 00AC  C7 06 0000 E 0000 E	        MOV     [$$ERRV],OFFSET $CONT  ;Restore error vector
  164	 00B2  06	 	 	        PUSH    ES
  165	 00B3  57	 	 	        PUSH    DI              ;Put return address back on stack
  166	 00B4  1E	 	 	        PUSH    DS
  167	 00B5  07	 	 	        POP     ES              ;Restore ES
  168	 00B6  CB	 	 	RET:    RET
  169	 	 	 	 	
  170	 00B7	 	 	 	$INPOVF:
  171	 	 	 	 	;Come here from error trap if overflow in FIN
  172	 00B7  E8 0000 E	 	        CALL    $TYPTX
  173	 00BA  4F 76 65 72 66 6C	        DB      "Overflo","w"+80H
  174	       6F F7	 	 	
  175	 00C2  E8 0000 E	 	        CALL    $$TCR           ;Output CR/LF
  176	 00C5  EB AD	 	 	        JMP     INPERR
  177	 	 	 	 	
  178	 	 	 	 	
  179	 	 	 	 	;***  $IPUB - Copy input values into variables
  180	 	 	 	 	;
  181	 	 	 	 	; Inputs:
  182	 	 	 	 	;       BX = Address of variable
  183	 	 	 	 	; Function:
  184	 	 	 	 	;       Recover value input for that variable from the stack and copy it in.
  185	 	 	 	 	;       When last variable has been assigned, recover stack space.
  186	 	 	 	 	; Outputs:
  187	 	 	 	 	;       None.
  188	 	 	 	 	; Registers:
  189	 	 	 	 	;       Only F affected.
  190	 	 	 	 	
  191	 00C7	 	 	 	$IPUB:
  192	 00C7  56	 	 	        PUSH    SI
  193	 00C8  57	 	 	        PUSH    DI
  194	 00C9  51	 	 	        PUSH    CX
  195	 00CA  1E	 	 	        PUSH    DS
  196	 00CB  8B 36 0006 R	 	        MOV     SI,[DATAPT]     ;Get pointer to next value
  197	 00CF  16	 	 	        PUSH    SS
  198	 00D0  1F	 	 	        POP     DS              ;Values stored in stack segment
  199	 00D1  4E	 	 	        DEC     SI
  200	 00D2  4E	 	 	        DEC     SI              ;Point to its type
  201	 00D3  8B 0C	 	 	        MOV     CX,[SI]         ;Type also equals length if numeric
  202	 00D5  8B F9	 	 	        MOV     DI,CX
  203	 00D7  81 E7 FFFE	 	        AND     DI,NOT 1        ;Clear LSB so DI = length
  204	 00DB  2B F7	 	 	        SUB     SI,DI           ;Point to its low end
  205	 00DD  26: 89 36 0006 R	 	        MOV     ES:[DATAPT],SI  ;For next call
  206	 00E2  80 F9 03	 	 	        CMP     CL,3            ;Type STRING?
  207	 00E5  74 20	 	 	        JZ      ASSTRG          ;Go assign string
  208	 00E7  8B FB	 	 	        MOV     DI,BX
  209	 00E9  D1 E9	 	 	        SHR     CX,1            ;Move by words
  210	 00EB  F3/ A5	 	 	        REP     MOVSW           ;Assign variable
  211	 00ED  1F	 	 	        POP     DS
  212	 00EE	 	 	 	ASSNXT:
  213	 00EE  59	 	 	        POP     CX
  214	 00EF  5F	 	 	        POP     DI
  215	 00F0  5E	 	 	        POP     SI
  216	 00F1  FE 0E 000B R	 	        DEC     [VALCNT]        ;Any more to go?


INPUT - INPUT statement                                  Macro-86 %1(12)   1:3:25  13-Nov-81    Page 1-5



  217	 00F5  75 BF	 	 	        JNZ     RET             ;If so, we'll wait for next call
  218	 	 	 	 	;Clean up stack
  219	 00F7  8F 06 0002 R	 	        POP     [RETOFF]
  220	 00FB  8F 06 0004 R	 	        POP     [RETSEG]
  221	 00FF  8B 26 0008 R	 	        MOV     SP,[CLEAN]
  222	 0103  FF 2E 0002 R	 	        JMP     [LONGRET]
  223	 	 	 	 	
  224	 0107	 	 	 	ASSTRG:
  225	 0107  8B 34	 	 	        MOV     SI,[SI]         ;Get pointer to string descriptor
  226	 0109  1F	 	 	        POP     DS
  227	 010A  87 F2	 	 	        XCHG    SI,DX
  228	 010C  87 D3	 	 	        XCHG    DX,BX           ;BX has source, DX has destination
  229	 010E  9A 0000 ---- E	 	        CALL    $SAS            ;Do string assign
  230	 0113  8B DA	 	 	        MOV     BX,DX
  231	 0115  8B D6	 	 	        MOV     DX,SI           ;Restore BX and DX
  232	 0117  EB D5	 	 	        JMP     ASSNXT
  233	 	 	 	 	
  234	 0119	 	 	 	INPUT   ENDP
  235	 0119	 	 	 	CODE    ENDS
  236	 	 	 	 	        END




































INPUT - INPUT statement                                  Macro-86 %1(12)   1:3:25  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0119	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	010E	WORD  	PUBLIC	'DATA'
  CONST. . . . . . . . . . . . . .	0004	BYTE  	PUBLIC	'CONST'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ASSNXT . . . . . . . . . . . . .	L NEAR 	00EE	CODE
ASSTRG . . . . . . . . . . . . .	L NEAR 	0107	CODE
CALLBUF. . . . . . . . . . . . .	L NEAR 	003E	CODE
CHKEND . . . . . . . . . . . . .	L NEAR 	00A8	CODE
CLEAN. . . . . . . . . . . . . .	L WORD 	0008	DATA
CNTDSK . . . . . . . . . . . . .	L NEAR 	009D	CODE
DATAPT . . . . . . . . . . . . .	L WORD 	0006	DATA
DONVAL . . . . . . . . . . . . .	L NEAR 	00A6	CODE
EACHVAL. . . . . . . . . . . . .	L NEAR 	001F	CODE
EOL. . . . . . . . . . . . . . .	Number	0000	
INPERR . . . . . . . . . . . . .	L NEAR 	0074	CODE
INPUT. . . . . . . . . . . . . .	F PROC	0000	CODE	Length =0119
LONGRET. . . . . . . . . . . . .	L DWORD	0002	DATA
NXTVAL . . . . . . . . . . . . .	L NEAR 	005F	CODE
PUSHAC . . . . . . . . . . . . .	L NEAR 	0055	CODE
REDO . . . . . . . . . . . . . .	L NEAR 	0019	CODE
RET. . . . . . . . . . . . . . .	L NEAR 	00B6	CODE
RETOFF . . . . . . . . . . . . .	L WORD 	0002	DATA
RETSEG . . . . . . . . . . . . .	L WORD 	0004	DATA
TYPCNT . . . . . . . . . . . . .	L BYTE 	000A	DATA
TYPLST . . . . . . . . . . . . .	L WORD 	0002	DATA
TYPTAB . . . . . . . . . . . . .	L BYTE 	0000	CONST
VALCNT . . . . . . . . . . . . .	L BYTE 	000B	DATA
VALTYP . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$$CTS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$ERRV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$TCR. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$BUFLEN. . . . . . . . . . . . .	L BYTE 	000C	DATA	Global
$CONT. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FILBUF. . . . . . . . . . . . .	L WORD 	0000	DATA	Global
$FIN . . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$GETCH . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$IN0A. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$INBUF . . . . . . . . . . . . .	L BYTE 	000E	DATA	Global	Length =0100
$INPOVF. . . . . . . . . . . . .	L NEAR 	00B7	CODE	Global
$IPUA. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$IPUB. . . . . . . . . . . . . .	L NEAR 	00C7	CODE	Global
$LINLEN. . . . . . . . . . . . .	L BYTE 	000D	DATA	Global
$PTRFIL. . . . . . . . . . . . .	V WORD 	0000	DATA	External


INPUT - INPUT statement                                  Macro-86 %1(12)   1:3:25  13-Nov-81    Symbols-2



$REDO. . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$SAS . . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$TYPTX . . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0

















































