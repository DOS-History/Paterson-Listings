READ - Read and Restore statements                       Macro-86 %1(12)   1:7:55  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   READ - Read and Restore statements
    2	 	 	 	 	
    3	                             C	        INCLUDE ADDR.INC
    4	 = 0000                      C	O_STA           EQU     0               ;Statement address/number table
    5	 = 0002                      C	STARTDATA       EQU     2               ;Start of data statements
    6	 = 0006                      C	O_RAM           EQU     6               ;Start of user RAM
    7	 = 000C                      C	O_RAL           EQU     0CH             ;End of user RAM + 1
    8	 	 	 	 	
    9	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
   10	 	 	 	 	
   11	 	 	 	 	        EXTRN   VALTYP:BYTE, $AC:WORD, $$RSTO:BYTE, $MAINBASE:WORD
   12	 	 	 	 	
   13	 0000  ????	 	 	DATAP   DW      ?
   14	 	 	 	 	
   15	 0002	 	 	 	DATA    ENDS
   16	 	 	 	 	
   17	 	 	 	 	DC      GROUP   DATA
   18	 	 	 	 	
   19	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   20	 	 	 	 	
   21	 	 	 	 	        PUBLIC  $REAA,$REAB,$REAC,$READ,$RSTA,$RSTB
   22	 	 	 	 	
   23	 	 	 	 	        EXTRN   $GETAD:NEAR, $FIN:NEAR, $GETCH:NEAR, $SAS:FAR
   24	 	 	 	 	        EXTRN   $SAVREG:NEAR, $ERC_OD:NEAR, $ERC_SN:NEAR
   25	 	 	 	 	
   26	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   27	 	 	 	 	
   28	 	 	 	 	
   29	 	 	 	 	;***  $RSTA & $RSTB - Restore statement
   30	 	 	 	 	;
   31	 	 	 	 	; Inputs:
   32	 	 	 	 	;       $RSTA - None
   33	 	 	 	 	;       $RSTB - BX = Address of statement to restore to
   34	 	 	 	 	; Function:
   35	 	 	 	 	;       Reset data pointers for RESTORE statement.
   36	 	 	 	 	;       $RSTA is simple restore to beginning of data.
   37	 	 	 	 	;       $RSTB restores to specified line number
   38	 	 	 	 	; Outputs:
   39	 	 	 	 	;       None.
   40	 	 	 	 	; Registers:
   41	 	 	 	 	;       Only F affected.
   42	 	 	 	 	
   43	 0000	 	 	 	$RSTA   PROC    FAR
   44	 0000  56	 	 	        PUSH    SI
   45	 0001  50	 	 	        PUSH    AX
   46	 0002  E8 0000 E	 	        CALL    $GETAD
   47	 0005  02	 	 	        DB      STARTDATA
   48	 0006  A3 0000 R	 	        MOV     [DATAP],AX
   49	 0009  C6 06 0000 E 01	 	        MOV     [$$RSTO],1      ;Have done a restore
   50	 000E  58	 	 	        POP     AX
   51	 000F  5E	 	 	        POP     SI
   52	 0010  CB	 	 	        RET
   53	 	 	 	 	
   54	 0011	 	 	 	$RSTB:


READ - Read and Restore statements                       Macro-86 %1(12)   1:7:55  13-Nov-81    Page 1-2



   55	 0011  9A 0000 ---- R	 	        CALL    $RSTA           ;Find first data statement
   56	 0016  50	 	 	        PUSH    AX
   57	 0017  51	 	 	        PUSH    CX
   58	 0018  53	 	 	        PUSH    BX
   59	 0019  2B 1E 0000 E	 	        SUB     BX,[$MAINBASE]  ;Subtract off program base offset
   60	 001D  57	 	 	        PUSH    DI
   61	 001E  33 C0	 	 	        XOR     AX,AX
   62	 0020  8B 3E 0000 R	 	        MOV     DI,[DATAP]      ;Get pointer to first data
   63	 0024  4F	 	 	        DEC     DI
   64	 0025  4F	 	 	        DEC     DI              ;Point to first line number address
   65	 0026	 	 	 	LOOKDATA:
   66	 0026  93	 	 	        XCHG    AX,BX
   67	 0027  AF	 	 	        SCASW                   ;Compare requested address with this address
   68	 0028  93	 	 	        XCHG    AX,BX
   69	 0029  76 07	 	 	        JBE     RESTDONE        ;If this line is as big, use it
   70	 002B  B9 FFFF	 	 	        MOV     CX,-1           ;Allow maximum search range
   71	 002E  F2/ AE	 	 	        REPNE   SCASB           ;Scan for zero, marking end of this statement
   72	 0030  EB F4	 	 	        JMP     LOOKDATA
   73	 0032	 	 	 	RESTDONE:
   74	 0032  89 3E 0000 R	 	        MOV     [DATAP],DI
   75	 0036  5F	 	 	        POP     DI
   76	 0037  5B	 	 	        POP     BX
   77	 0038  59	 	 	        POP     CX
   78	 0039  58	 	 	        POP     AX
   79	 003A  CB	 	 	        RET
   80	 	 	 	 	
   81	 003B	 	 	 	$RSTA   ENDP
   82	 	 	 	 	
   83	 	 	 	 	
   84	 	 	 	 	;***  $REAA,$REAB,$REAC,$READ - Read statements for SP, DP, integer, string
   85	 	 	 	 	;
   86	 	 	 	 	; Inputs:
   87	 	 	 	 	;       BX = Destination address of read value
   88	 	 	 	 	; Function:
   89	 	 	 	 	;       If first read ever, perform Restore. Read next data item if present,
   90	 	 	 	 	;       and advance data pointer. If item not present, report Out of Data
   91	 	 	 	 	;       error.
   92	 	 	 	 	; Outputs:
   93	 	 	 	 	;       None.
   94	 	 	 	 	; Registers:
   95	 	 	 	 	;       Only F affected.
   96	 	 	 	 	
   97	 003B	 	 	 	$REAA:  ;Single precision read
   98	 003B  C6 06 0000 E 04	 	        MOV     [VALTYP],4
   99	 0040  EB 13	 	 	        JMP     SHORT READ
  100	 	 	 	 	
  101	 0042	 	 	 	$REAB:  ;Double precision
  102	 0042  C6 06 0000 E 08	 	        MOV     [VALTYP],8
  103	 0047  EB 0C	 	 	        JMP     SHORT READ
  104	 	 	 	 	
  105	 0049	 	 	 	$REAC:  ;Integer
  106	 0049  C6 06 0000 E 02	 	        MOV     [VALTYP],2
  107	 004E  EB 05	 	 	        JMP     SHORT READ
  108	 	 	 	 	


READ - Read and Restore statements                       Macro-86 %1(12)   1:7:55  13-Nov-81    Page 1-3



  109	 0050	 	 	 	$READ:  ;String
  110	 0050  C6 06 0000 E 03	 	        MOV     [VALTYP],3
  111	 	 	 	 	
  112	 0055	 	 	 	READ:
  113	 0055  E8 0000 E	 	        CALL    $SAVREG         ;Save all registers on stack
  114	 0058  53	 	 	        PUSH    BX              ;Save destination address
  115	 0059  80 3E 0000 E 00	 	        CMP     [$$RSTO],0      ;Have we ever restored?
  116	 005E  75 05	 	 	        JNZ     RDDAT
  117	 0060  9A 0000 ---- R	 	        CALL    $RSTA
  118	 0065	 	 	 	RDDAT:
  119	 0065  8B 36 0000 R	 	        MOV     SI,[DATAP]      ;Get pointer to next data item
  120	 0069  E8 0000 E	 	        CALL    $GETCH          ;Skip over blanks
  121	 006C  3C 01	 	 	        CMP     AL,1            ;End of data list?
  122	 006E  74 3B	 	 	        JZ      DATOUT
  123	 0070  4E	 	 	        DEC     SI              ;Re-read first character
  124	 0071  E8 0000 E	 	        CALL    $FIN            ;Get data item
  125	 0074  E8 0000 E	 	        CALL    $GETCH          ;See if next char is comma or end of line
  126	 0077  3C 2C	 	 	        CMP     AL,","          ;More values on this line?
  127	 0079  74 06	 	 	        JZ      ASSIGN
  128	 007B  0A C0	 	 	        OR      AL,AL           ;Better be EOL (zero) if no more values
  129	 007D  75 2F	 	 	        JNZ     SYNERR
  130	 007F  46	 	 	        INC     SI              ;Skip over line number
  131	 0080  46	 	 	        INC     SI
  132	 0081	 	 	 	ASSIGN:
  133	 0081  89 36 0000 R	 	        MOV     [DATAP],SI      ;Save pointer
  134	 0085  5F	 	 	        POP     DI              ;Get destination address
  135	 0086  A0 0000 E	 	        MOV     AL,[VALTYP]
  136	 0089  3C 03	 	 	        CMP     AL,3            ;String assign?
  137	 008B  74 12	 	 	        JZ      ASSTRG
  138	 008D  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
  139	 0090  98	 	 	        CBW
  140	 0091  91	 	 	        XCHG    AX,CX
  141	 0092  D1 E9	 	 	        SHR     CX,1
  142	 0094  80 F9 04	 	 	        CMP     CL,4            ;Double precision?
  143	 0097  75 03	 	 	        JNZ     MOVE
  144	 0099  83 EE 04	 	 	        SUB     SI,4
  145	 009C	 	 	 	MOVE:
  146	 009C  F3/ A5	 	 	        REP     MOVSW
  147	 009E  C3	 	 	        RET
  148	 	 	 	 	
  149	 009F	 	 	 	ASSTRG:
  150	 009F  8B D7	 	 	        MOV     DX,DI           ;Destination in DX
  151	 00A1  8B 1E 0000 E	 	        MOV     BX,[$AC]        ;Source in BX
  152	 00A5  9A 0000 ---- E	 	        CALL    $SAS            ;Do string assignment
  153	 00AA  C3	 	 	        RET
  154	 	 	 	 	
  155	 00AB  E9 0000 E	 	DATOUT: JMP     $ERC_OD         ;Out of Data
  156	 00AE  E9 0000 E	 	SYNERR: JMP     $ERC_SN         ;Syntax error in DATA
  157	 	 	 	 	
  158	 00B1	 	 	 	CODE    ENDS
  159	 	 	 	 	        END





READ - Read and Restore statements                       Macro-86 %1(12)   1:7:55  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	00B1	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0002	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ASSIGN . . . . . . . . . . . . .	L NEAR 	0081	CODE
ASSTRG . . . . . . . . . . . . .	L NEAR 	009F	CODE
DATAP. . . . . . . . . . . . . .	L WORD 	0000	DATA
DATOUT . . . . . . . . . . . . .	L NEAR 	00AB	CODE
LOOKDATA . . . . . . . . . . . .	L NEAR 	0026	CODE
MOVE . . . . . . . . . . . . . .	L NEAR 	009C	CODE
O_RAL. . . . . . . . . . . . . .	Number	000C	
O_RAM. . . . . . . . . . . . . .	Number	0006	
O_STA. . . . . . . . . . . . . .	Number	0000	
RDDAT. . . . . . . . . . . . . .	L NEAR 	0065	CODE
READ . . . . . . . . . . . . . .	L NEAR 	0055	CODE
RESTDONE . . . . . . . . . . . .	L NEAR 	0032	CODE
STARTDATA. . . . . . . . . . . .	Number	0002	
SYNERR . . . . . . . . . . . . .	L NEAR 	00AE	CODE
VALTYP . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$$RSTO . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ERC_OD. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_SN. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FIN . . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$GETAD . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$GETCH . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$MAINBASE. . . . . . . . . . . .	V WORD 	0000	DATA	External
$REAA. . . . . . . . . . . . . .	L NEAR 	003B	CODE	Global
$REAB. . . . . . . . . . . . . .	L NEAR 	0042	CODE	Global
$REAC. . . . . . . . . . . . . .	L NEAR 	0049	CODE	Global
$READ. . . . . . . . . . . . . .	L NEAR 	0050	CODE	Global
$RSTA. . . . . . . . . . . . . .	F PROC	0000	CODE	Global	Length =003B
$RSTB. . . . . . . . . . . . . .	L NEAR 	0011	CODE	Global
$SAS . . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0









