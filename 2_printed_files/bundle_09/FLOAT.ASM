FLOAT - Floating point entry points                      Macro-86 %1(12)   1:1:30  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   FLOAT - Floating point entry points
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $AC:WORD, $DAC:WORD, $FT:WORD, $$SPSV:WORD
    6	 	 	 	 	
    7	 0000  ????	 	 	SISAVE  DW      ?
    8	 0002  ????	 	 	DISAVE  DW      ?
    9	 0004  ????	 	 	POINTER DW      ?
   10	 	 	 	 	
   11	 0006	 	 	 	DATA    ENDS
   12	 	 	 	 	
   13	 	 	 	 	DC      GROUP   DATA
   14	 	 	 	 	
   15	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   16	 	 	 	 	
   17	 	 	 	 	        PUBLIC  $FASA, $FASB, $FASC, $FASD
   18	 	 	 	 	        PUBLIC  $STFA, $STFB, $LDFA, $LDFB
   19	 	 	 	 	        PUBLIC  $SAVREG, $GTMP
   20	 	 	 	 	
   21	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   22	 	 	 	 	
   23	 	 	 	 	
   24	 	 	 	 	; Floating point assignment
   25	 	 	 	 	
   26	 0000	 	 	 	FLTASS  PROC    FAR             ;Set up long returns
   27	 	 	 	 	
   28	 	 	 	 	; $FASA - Assign [SI] to [DI], single precision
   29	 	 	 	 	; $FASB - Assign [SI] to [DI], double precision
   30	 	 	 	 	; $FASC - Assign FAC to [DI], single precision
   31	 	 	 	 	; $FASD - Assign FAC to [DI], double precision
   32	 	 	 	 	; $STFA - Store FAC in temp, SP
   33	 	 	 	 	; $STFB - Store FAC in temp, DP
   34	 	 	 	 	; $LDFA - Load FAC from [SI], SP
   35	 	 	 	 	; $LDFB - Load FAC from [SI], DP
   36	 	 	 	 	
   37	 0000	 	 	 	$FASC:
   38	 0000  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   39	 0003	 	 	 	$FASA:
   40	 0003  A5	 	 	        MOVSW
   41	 0004  A5	 	 	        MOVSW
   42	 0005  83 EF 04	 	 	        SUB     DI,4
   43	 0008  83 EE 04	 	 	        SUB     SI,4
   44	 000B  CB	 	 	        RET
   45	 	 	 	 	
   46	 000C	 	 	 	$FASD:
   47	 000C  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   48	 000F	 	 	 	$FASB:
   49	 000F  A5	 	 	        MOVSW
   50	 0010  A5	 	 	        MOVSW
   51	 0011  A5	 	 	        MOVSW
   52	 0012  A5	 	 	        MOVSW
   53	 0013  83 EF 08	 	 	        SUB     DI,8
   54	 0016  83 EE 08	 	 	        SUB     SI,8


FLOAT - Floating point entry points                      Macro-86 %1(12)   1:1:30  13-Nov-81    Page 1-2



   55	 0019  CB	 	 	        RET
   56	 	 	 	 	
   57	 001A	 	 	 	$LDFA:
   58	 001A  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   59	 001D  A5	 	 	        MOVSW 
   60	 001E  A5	 	 	        MOVSW 
   61	 001F  83 EE 04	 	 	        SUB     SI,4
   62	 0022  CB	 	 	        RET
   63	 	 	 	 	
   64	 0023	 	 	 	$LDFB:
   65	 0023  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   66	 0026  A5	 	 	        MOVSW
   67	 0027  A5	 	 	        MOVSW
   68	 0028  A5	 	 	        MOVSW
   69	 0029  A5	 	 	        MOVSW
   70	 002A  83 EE 08	 	 	        SUB     SI,8
   71	 002D  CB	 	 	        RET
   72	 	 	 	 	
   73	 002E	 	 	 	$STFA:
   74	 002E  89 36 0000 R	 	        MOV     [SISAVE],SI
   75	 0032  89 3E 0002 R	 	        MOV     [DISAVE],DI
   76	 0036  E8 0062 R	 	        CALL    $GTMP
   77	 0039  BE 0000 E	 	        MOV     SI,OFFSET DC:$AC
   78	 003C  A5	 	 	        MOVSW
   79	 003D  A5	 	 	        MOVSW
   80	 003E  8B 36 0000 R	 	        MOV     SI,[SISAVE]
   81	 0042  8B 3E 0002 R	 	        MOV     DI,[DISAVE]
   82	 0046  CB	 	 	        RET
   83	 	 	 	 	
   84	 0047	 	 	 	$STFB:
   85	 0047  89 36 0000 R	 	        MOV     [SISAVE],SI
   86	 004B  89 3E 0002 R	 	        MOV     [DISAVE],DI
   87	 004F  E8 0062 R	 	        CALL    $GTMP
   88	 0052  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   89	 0055  A5	 	 	        MOVSW
   90	 0056  A5	 	 	        MOVSW
   91	 0057  A5	 	 	        MOVSW
   92	 0058  A5	 	 	        MOVSW
   93	 0059  8B 36 0000 R	 	        MOV     SI,[SISAVE]
   94	 005D  8B 3E 0002 R	 	        MOV     DI,[DISAVE]
   95	 0061  CB	 	 	        RET
   96	 	 	 	 	
   97	 0062	 	 	 	FLTASS  ENDP
   98	 	 	 	 	
   99	 0062	 	 	 	$GTMP:
  100	 	 	 	 	
  101	 	 	 	 	; Inputs:
  102	 	 	 	 	;       Long return address one level deep on stack points to temp number.
  103	 	 	 	 	; Function:
  104	 	 	 	 	;       Get address of temp.
  105	 	 	 	 	; Outputs:
  106	 	 	 	 	;       SI = DI = Address of floating temp.
  107	 	 	 	 	; Registers:
  108	 	 	 	 	;       Only SI, DI and F affected.


FLOAT - Floating point entry points                      Macro-86 %1(12)   1:1:30  13-Nov-81    Page 1-3



  109	 	 	 	 	
  110	 0062  8F 06 0004 R	 	        POP     [POINTER]
  111	 0066  5E	 	 	        POP     SI
  112	 0067  1F	 	 	        POP     DS
  113	 0068  97	 	 	        XCHG    AX,DI
  114	 0069  AC	 	 	        LODSB                   ;Get temp number
  115	 006A  D0 E0	 	 	        SHL     AL,1
  116	 006C  B4 00	 	 	        MOV     AH,0
  117	 006E  D1 E0	 	 	        SHL     AX,1
  118	 0070  D1 E0	 	 	        SHL     AX,1
  119	 0072  05 FFF8 E	 	        ADD     AX,OFFSET DC:$FT-8
  120	 0075  97	 	 	        XCHG    AX,DI
  121	 0076  1E	 	 	        PUSH    DS
  122	 0077  56	 	 	        PUSH    SI
  123	 0078  8B F7	 	 	        MOV     SI,DI
  124	 007A  06	 	 	        PUSH    ES
  125	 007B  1F	 	 	        POP     DS
  126	 007C  FF 26 0004 R	 	        JMP     [POINTER]
  127	 	 	 	 	
  128	 	 	 	 	
  129	 0080	 	 	 	$SAVREG PROC    FAR
  130	 	 	 	 	
  131	 	 	 	 	; This routine saves all registers on the stack. It returns with the top
  132	 	 	 	 	; of the stack containing a return address to a routine that restores the
  133	 	 	 	 	; registers and returns to user code. Flags set by the library are passed
  134	 	 	 	 	; back to the user program (so compares work).
  135	 	 	 	 	
  136	 0080  8F 06 0004 R	 	        POP     [POINTER]
  137	 0084  89 26 0000 E	 	        MOV     [$$SPSV],SP
  138	 0088  55	 	 	        PUSH    BP
  139	 0089  56	 	 	        PUSH    SI
  140	 008A  57	 	 	        PUSH    DI
  141	 008B  50	 	 	        PUSH    AX
  142	 008C  51	 	 	        PUSH    CX
  143	 008D  52	 	 	        PUSH    DX
  144	 008E  53	 	 	        PUSH    BX
  145	 008F  FF 16 0004 R	 	        CALL    [POINTER]
  146	 0093  5B	 	 	        POP     BX
  147	 0094  5A	 	 	        POP     DX
  148	 0095  59	 	 	        POP     CX
  149	 0096  58	 	 	        POP     AX
  150	 0097  5F	 	 	        POP     DI
  151	 0098  5E	 	 	        POP     SI
  152	 0099  5D	 	 	        POP     BP
  153	 009A  CB	 	 	        RET
  154	 	 	 	 	
  155	 009B	 	 	 	$SAVREG ENDP
  156	 009B	 	 	 	CODE    ENDS
  157	 	 	 	 	        END







FLOAT - Floating point entry points                      Macro-86 %1(12)   1:1:30  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	009B	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0006	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

DISAVE . . . . . . . . . . . . .	L WORD 	0002	DATA
FLTASS . . . . . . . . . . . . .	F PROC	0000	CODE	Length =0062
POINTER. . . . . . . . . . . . .	L WORD 	0004	DATA
SISAVE . . . . . . . . . . . . .	L WORD 	0000	DATA
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$FASA. . . . . . . . . . . . . .	L NEAR 	0003	CODE	Global
$FASB. . . . . . . . . . . . . .	L NEAR 	000F	CODE	Global
$FASC. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$FASD. . . . . . . . . . . . . .	L NEAR 	000C	CODE	Global
$FT. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$GTMP. . . . . . . . . . . . . .	L NEAR 	0062	CODE	Global
$LDFA. . . . . . . . . . . . . .	L NEAR 	001A	CODE	Global
$LDFB. . . . . . . . . . . . . .	L NEAR 	0023	CODE	Global
$SAVREG. . . . . . . . . . . . .	F PROC	0080	CODE	Global	Length =001B
$STFA. . . . . . . . . . . . . .	L NEAR 	002E	CODE	Global
$STFB. . . . . . . . . . . . . .	L NEAR 	0047	CODE	Global

Warning Severe
Errors	Errors 
0	0






















