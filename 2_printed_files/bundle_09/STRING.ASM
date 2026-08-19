STRING - String assignment, concatenate, compare                 Macro-86 %1(12)   1:8:49  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   STRING - String assignment, concatenate, compare
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $$SPSV:WORD
    6	 	 	 	 	
    7	 0000	 	 	 	DATA    ENDS
    8	 	 	 	 	
    9	 	 	 	 	DC      GROUP   DATA
   10	 	 	 	 	
   11	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   12	 	 	 	 	
   13	 	 	 	 	        PUBLIC  $SASA,$AD$A,$SCMA,$SAS
   14	 	 	 	 	
   15	 	 	 	 	        EXTRN   $$ATS:NEAR, $$DITS:NEAR, $ERC_FC:NEAR
   16	 	 	 	 	        EXTRN   $$CFT:NEAR, $$CTS:NEAR, $$FSS:NEAR, $$FTH:NEAR
   17	 	 	 	 	
   18	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   19	 	 	 	 	
   20	 	 	 	 	
   21	 0000	 	 	 	$SASA   PROC    FAR
   22	 	 	 	 	
   23	 	 	 	 	;***  $SASA - String assignment
   24	 	 	 	 	;
   25	 	 	 	 	; Inputs:
   26	 	 	 	 	;       BX = Address of Source string descriptor
   27	 	 	 	 	;       DX = Address of Destination string descriptor
   28	 	 	 	 	; Function:
   29	 	 	 	 	;       1. Copy the source string into a temp, if it wasn't already.
   30	 	 	 	 	;       2. Free any string data space of the destination
   31	 	 	 	 	;       3. Copy the source descriptor to the destination descriptor
   32	 	 	 	 	;       4. Reset the backpointer (unless it's a null string)
   33	 	 	 	 	;       5. Free the (temporary) source descriptor
   34	 	 	 	 	; Outputs:
   35	 	 	 	 	;       None.
   36	 	 	 	 	; Registers:
   37	 	 	 	 	;       Only F affected
   38	 	 	 	 	
   39	 0000  89 26 0000 E	 	        MOV     [$$SPSV],SP
   40	 0004	 	 	 	$SAS:   ;Entry point that doesn't save stack
   41	 0004  53	 	 	        PUSH    BX
   42	 0005  E8 0000 E	 	        CALL    $$CFT           ;See if source is a temp
   43	 0008  72 0A	 	 	        JC      HAVTEMP         ;Save some work if so
   44	 	 	 	 	;Copy the source string into a temp
   45	 000A  52	 	 	        PUSH    DX
   46	 000B  8B 57 02	 	 	        MOV     DX,[BX+2]       ;Get pointer to string data
   47	 000E  8B 1F	 	 	        MOV     BX,[BX]         ;Get length
   48	 0010  E8 0000 E	 	        CALL    $$CTS           ;Create temp string and copy in data
   49	 0013  5A	 	 	        POP     DX
   50	 0014	 	 	 	HAVTEMP:
   51	 0014  87 DA	 	 	        XCHG    BX,DX           ;Need destination string in BX
   52	 0016  E8 0000 E	 	        CALL    $$FSS           ;Free source string, if any
   53	 	 	 	 	;Copy the descriptor
   54	 0019  56	 	 	        PUSH    SI


STRING - String assignment, concatenate, compare                 Macro-86 %1(12)   1:8:49  13-Nov-81    Page 1-2



   55	 001A  57	 	 	        PUSH    DI
   56	 001B  8B FB	 	 	        MOV     DI,BX
   57	 001D  8B F2	 	 	        MOV     SI,DX
   58	 001F  A5	 	 	        MOVSW                   ;Move length
   59	 0020  A5	 	 	        MOVSW                   ;Move data pointer
   60	 0021  87 DA	 	 	        XCHG    BX,DX           ;Need source (temp) string in BX
   61	 0023  83 3F 00	 	 	        CMP     WORD PTR[BX],0  ;See if null string
   62	 0026  74 09	 	 	        JZ      NOBACK          ;Don't fix backpointer if so
   63	 0028  8B 7F 02	 	 	        MOV     DI,[BX+2]       ;Get pointer to data again
   64	 002B  89 55 FE	 	 	        MOV     [DI-2],DX       ;Set backpointer
   65	 002E  E8 0000 E	 	        CALL    $$FTH           ;Free temp header
   66	 0031	 	 	 	NOBACK:
   67	 0031  5F	 	 	        POP     DI
   68	 0032  5E	 	 	        POP     SI
   69	 0033  5B	 	 	        POP     BX
   70	 0034  CB	 	 	        RET
   71	 	 	 	 	
   72	 0035	 	 	 	$SASA   ENDP
   73	 	 	 	 	
   74	 	 	 	 	
   75	 0035	 	 	 	$AD$A   PROC    FAR
   76	 	 	 	 	
   77	 	 	 	 	;***  $AD$A - Concatenate strings
   78	 	 	 	 	;
   79	 	 	 	 	; Inputs:
   80	 	 	 	 	;       AX = Address of left string descriptor
   81	 	 	 	 	;       BX = Address of right string descriptor
   82	 	 	 	 	; Function:
   83	 	 	 	 	;       Create a string containing the concatenation of the two given strings.
   84	 	 	 	 	; Outputs:
   85	 	 	 	 	;       BX = Address of result string descriptor
   86	 	 	 	 	; Registers:
   87	 	 	 	 	;       Only BX and F affected.
   88	 	 	 	 	
   89	 0035  89 26 0000 E	 	        MOV     [$$SPSV],SP
   90	 0039  51	 	 	        PUSH    CX
   91	 003A  52	 	 	        PUSH    DX
   92	 003B  56	 	 	        PUSH    SI
   93	 003C  57	 	 	        PUSH    DI
   94	 003D  8B F0	 	 	        MOV     SI,AX           ;First string to move
   95	 003F  8B FB	 	 	        MOV     DI,BX           ;Save second string
   96	 0041  8B 1C	 	 	        MOV     BX,[SI]         ;Get length of first string
   97	 0043  03 1D	 	 	        ADD     BX,[DI]         ;Sum is length of result string
   98	 0045  70 25	 	 	        JO      ARGERR          ;Make sure no overflow
   99	 0047  E8 0000 E	 	        CALL    $$ATS           ;Allocate temp string
  100	 004A  87 FA	 	 	        XCHG    DI,DX           ;Put data address in DI, save second string
  101	 004C  53	 	 	        PUSH    BX              ;Save result string descriptor address
  102	 004D  E8 005B R	 	        CALL    MOVSTR          ;Move first string into temp
  103	 0050  8B F2	 	 	        MOV     SI,DX
  104	 0052  E8 005B R	 	        CALL    MOVSTR          ;Move second string in
  105	 0055  5B	 	 	        POP     BX              ;Restore result
  106	 0056  5F	 	 	        POP     DI
  107	 0057  5E	 	 	        POP     SI
  108	 0058  5A	 	 	        POP     DX


STRING - String assignment, concatenate, compare                 Macro-86 %1(12)   1:8:49  13-Nov-81    Page 1-3



  109	 0059  59	 	 	        POP     CX
  110	 005A  CB	 	 	        RET
  111	 	 	 	 	
  112	 005B	 	 	 	MOVSTR:
  113	 005B  8B DE	 	 	        MOV     BX,SI           ;Need descriptor address here for DITS
  114	 005D  8B 0C	 	 	        MOV     CX,[SI]         ;Length of string
  115	 005F  8B 74 02	 	 	        MOV     SI,[SI+2]       ;Address of data
  116	 0062  D1 E9	 	 	        SHR     CX,1            ;Convert to word count
  117	 0064  F3/ A5	 	 	        REP     MOVSW
  118	 0066  73 01	 	 	        JNC     DITS            ;Is it odd?
  119	 0068  A4	 	 	        MOVSB                   ;Move last byte if odd
  120	 0069	 	 	 	DITS:
  121	 0069  E9 0000 E	 	        JMP     $$DITS          ;Delete source string if temp
  122	 	 	 	 	
  123	 006C  E9 0000 E	 	ARGERR: JMP     $ERC_FC
  124	 	 	 	 	
  125	 006F	 	 	 	$AD$A   ENDP
  126	 	 	 	 	
  127	 	 	 	 	
  128	 006F	 	 	 	$SCMA   PROC    FAR
  129	 	 	 	 	
  130	 	 	 	 	;***  $SCMA - String comparison
  131	 	 	 	 	;
  132	 	 	 	 	; Inputs:
  133	 	 	 	 	;       AX = Address of left operand string descriptor
  134	 	 	 	 	;       BX = Address of right operand string descriptor
  135	 	 	 	 	; Function:
  136	 	 	 	 	;       Compare strings and set flags. For each byte of the strings, the flags
  137	 	 	 	 	;       are set based on [left operand] - [right operand] until inequality is
  138	 	 	 	 	;       found or one the strings end. If the end a string is reached, the
  139	 	 	 	 	;       flags are set with [LEN(left operand)] - [LEN(right operand)].
  140	 	 	 	 	; Outputs:
  141	 	 	 	 	;       Result is flags, as noted above.
  142	 	 	 	 	; Registers:
  143	 	 	 	 	;       Only F affected.
  144	 	 	 	 	
  145	 006F  51	 	 	        PUSH    CX
  146	 0070  56	 	 	        PUSH    SI
  147	 0071  57	 	 	        PUSH    DI
  148	 0072  8B 7F 02	 	 	        MOV     DI,[BX+2]       ;Pointer to right side data
  149	 0075  8B 0F	 	 	        MOV     CX,[BX]         ;Length of right string
  150	 0077  93	 	 	        XCHG    AX,BX
  151	 0078  8B 77 02	 	 	        MOV     SI,[BX+2]       ;Pointer to left side data
  152	 007B  3B 0F	 	 	        CMP     CX,[BX]         ;See which string is shorter
  153	 007D  76 02	 	 	        JBE     HAVLEN
  154	 007F  8B 0F	 	 	        MOV     CX,[BX]         ;Use whichever length is shortest
  155	 0081	 	 	 	HAVLEN:
  156	 0081  3B C0	 	 	        CMP     AX,AX           ;Set zero flag in case CX=0
  157	 0083  F3/ A6	 	 	        REPE    CMPSB           ;String compare
  158	 0085  5F	 	 	        POP     DI
  159	 0086  5E	 	 	        POP     SI
  160	 0087  75 06	 	 	        JNZ     NOTEQ           ;Strings equal so far?
  161	 0089  8B 0F	 	 	        MOV     CX,[BX]         ;String data equal, so get lengths again
  162	 008B  93	 	 	        XCHG    AX,BX


STRING - String assignment, concatenate, compare                 Macro-86 %1(12)   1:8:49  13-Nov-81    Page 1-4



  163	 008C  3B 0F	 	 	        CMP     CX,[BX]         ;Longer string is larger
  164	 008E  93	 	 	        XCHG    AX,BX
  165	 008F	 	 	 	NOTEQ:
  166	 008F  9C	 	 	        PUSHF                   ;Save comparison flags
  167	 0090  E8 0000 E	 	        CALL    $$DITS          ;Free up temp strings
  168	 0093  93	 	 	        XCHG    AX,BX
  169	 0094  E8 0000 E	 	        CALL    $$DITS
  170	 0097  9D	 	 	        POPF                    ;Restore flags
  171	 0098  59	 	 	        POP     CX
  172	 0099  CB	 	 	        RET
  173	 	 	 	 	
  174	 009A	 	 	 	$SCMA   ENDP
  175	 009A	 	 	 	CODE    ENDS
  176	 	 	 	 	        END










































STRING - String assignment, concatenate, compare                 Macro-86 %1(12)   1:8:49  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	009A	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ARGERR . . . . . . . . . . . . .	L NEAR 	006C	CODE
DITS . . . . . . . . . . . . . .	L NEAR 	0069	CODE
HAVLEN . . . . . . . . . . . . .	L NEAR 	0081	CODE
HAVTEMP. . . . . . . . . . . . .	L NEAR 	0014	CODE
MOVSTR . . . . . . . . . . . . .	L NEAR 	005B	CODE
NOBACK . . . . . . . . . . . . .	L NEAR 	0031	CODE
NOTEQ. . . . . . . . . . . . . .	L NEAR 	008F	CODE
$$ATS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$CFT. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$CTS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$DITS . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$FSS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$FTH. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$AD$A. . . . . . . . . . . . . .	F PROC	0035	CODE	Global	Length =003A
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SAS . . . . . . . . . . . . . .	L NEAR 	0004	CODE	Global
$SASA. . . . . . . . . . . . . .	F PROC	0000	CODE	Global	Length =0035
$SCMA. . . . . . . . . . . . . .	F PROC	006F	CODE	Global	Length =002B

Warning Severe
Errors	Errors 
0	0





















