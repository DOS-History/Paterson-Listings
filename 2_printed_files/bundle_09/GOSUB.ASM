GOSUB - GOSUB, RETURN, and computed GOSUB/GOTO           Macro-86 %1(12)   1:2:59  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   GOSUB - GOSUB, RETURN, and computed GOSUB/GOTO
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $$STKP:WORD
    6	 	 	 	 	
    7	 0000  ????	 	 	$$GCNT  DW      ?
    8	 	 	 	 	
    9	 0002	 	 	 	DATA    ENDS
   10	 	 	 	 	
   11	 	 	 	 	DC      GROUP   DATA
   12	 	 	 	 	
   13	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   14	 	 	 	 	
   15	 	 	 	 	        PUBLIC  $OGSA, $OGTA, $GOSA, $RELA, $RETA
   16	 	 	 	 	
   17	 	 	 	 	        EXTRN   $ERR_FC:NEAR, $ERR_RG:NEAR
   18	 	 	 	 	
   19	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   20	 	 	 	 	
   21	 0000	 	 	 	GOSUB   PROC    FAR             ;Set up long returns
   22	 	 	 	 	
   23	 	 	 	 	
   24	 	 	 	 	;***  $GOSA - GOSUB with error checking
   25	 	 	 	 	;
   26	 	 	 	 	; Inputs:
   27	 	 	 	 	;       Return address on top of stack points to address of target location
   28	 	 	 	 	; Function:
   29	 	 	 	 	;       Execute a near (relative user code) call to the target, saving
   30	 	 	 	 	;       a clean stack pointer value (for after the call) and bumping the
   31	 	 	 	 	;       nesting counter for "RETURN without GOSUB" detection.
   32	 	 	 	 	; Outputs:
   33	 	 	 	 	;       None.
   34	 	 	 	 	; Registers:
   35	 	 	 	 	;       Destroys all except BP.
   36	 	 	 	 	
   37	 0000	 	 	 	$GOSA:
   38	 0000  5E	 	 	        POP     SI
   39	 0001  89 26 0000 E	 	        MOV     [$$STKP],SP     ;Save clean stack value
   40	 0005  1F	 	 	        POP     DS              ;DS:SI point to target
   41	 0006  AD	 	 	        LODSW
   42	 0007  56	 	 	        PUSH    SI              ;Push return address
   43	 0008  1E	 	 	        PUSH    DS
   44	 0009  50	 	 	        PUSH    AX              ;DS:AX is target, now on top of stack
   45	 000A  06	 	 	        PUSH    ES
   46	 000B  1F	 	 	        POP     DS              ;Restore DS
   47	 000C  FF 06 0000 R	 	        INC     [$$GCNT]        ;Bump nesting level
   48	 0010  CB	 	 	        RET                     ;Long return to target
   49	 	 	 	 	
   50	 	 	 	 	
   51	 	 	 	 	;***  $RELA - RETURN line number address popper
   52	 	 	 	 	;
   53	 	 	 	 	; Inputs:
   54	 	 	 	 	;       None.


GOSUB - GOSUB, RETURN, and computed GOSUB/GOTO           Macro-86 %1(12)   1:2:59  13-Nov-81    Page 1-2



   55	 	 	 	 	; Function:
   56	 	 	 	 	;       Pop one entry off the stack and update GOSUB level
   57	 	 	 	 	; Outputs:
   58	 	 	 	 	;       None.
   59	 	 	 	 	; Registers:
   60	 	 	 	 	;       Destroys all except BP.
   61	 	 	 	 	
   62	 0011	 	 	 	$RELA:
   63	 0011  FF 0E 0000 R	 	        DEC     [$$GCNT]        ;Decrement count - error if < 0
   64	 0015  78 15	 	 	        JS      ERR_RG          ;RETURN without GOSUB error?
   65	 0017  5B	 	 	        POP     BX              ;IP for our return
   66	 0018  58	 	 	        POP     AX              ;CS of user code
   67	 0019  59	 	 	        POP     CX              ;Toss this address
   68	 001A  EB 09	 	 	        JMP     short reta1
   69	 	 	 	 	
   70	 	 	 	 	
   71	 	 	 	 	;***  $RETA - RETURN from GOSUB with error checking
   72	 	 	 	 	;
   73	 	 	 	 	; Inputs:
   74	 	 	 	 	;       None.
   75	 	 	 	 	; Function:
   76	 	 	 	 	;       Execute near (relative user code) return, checking nesting level to
   77	 	 	 	 	;       avoid RETURN without GOSUB, and saving post-return clean stack value.
   78	 	 	 	 	; Outputs:
   79	 	 	 	 	;       None.
   80	 	 	 	 	; Registers:
   81	 	 	 	 	;       Destroys all except BP.
   82	 	 	 	 	
   83	 001C	 	 	 	$RETA:
   84	 001C  FF 0E 0000 R	 	        DEC     [$$GCNT]        ;Decrement count - error if < 0
   85	 0020  78 0A	 	 	        JS      ERR_RG          ;RETURN without GOSUB error?
   86	 0022  58	 	 	        POP     AX              ;Dump IP for our return
   87	 0023  58	 	 	        POP     AX              ;CS of user code
   88	 0024  5B	 	 	        POP     BX              ;This is the local return address
   89	 	 	 	 	
   90	 0025  89 26 0000 E	 	reta1:  MOV     [$$STKP],SP     ;Save clean stack level
   91	 0029  50	 	 	        PUSH    AX              ;Push CS first
   92	 002A  53	 	 	        PUSH    BX
   93	 002B  CB	 	 	        RET                     ;Long return to user code
   94	 	 	 	 	
   95	 002C  E9 0000 E	 	ERR_RG: JMP     $ERR_RG
   96	 	 	 	 	
   97	 	 	 	 	
   98	 	 	 	 	;***  $OGSA and $OGTA - ON-GOSUB and ON-GOTO
   99	 	 	 	 	;
  100	 	 	 	 	; Inputs:
  101	 	 	 	 	;       BX = Index
  102	 	 	 	 	;       Return address on top of stack points to table:
  103	 	 	 	 	;               DB      <Number of entries>
  104	 	 	 	 	;               DW      <Target if index = 1>
  105	 	 	 	 	;               DW      <Target if index = 2>
  106	 	 	 	 	;               . . .
  107	 	 	 	 	;               DW      <Target if index = N>
  108	 	 	 	 	; Function:


GOSUB - GOSUB, RETURN, and computed GOSUB/GOTO           Macro-86 %1(12)   1:2:59  13-Nov-81    Page 1-3



  109	 	 	 	 	;       If index is negative or > 255, give argument error. If index is in
  110	 	 	 	 	;       range 1..N, jump to corresponding location. If index is not in this
  111	 	 	 	 	;       range, continue with next statement. If this is a GOSUB, then error
  112	 	 	 	 	;       checking (as in $GOSA, above) will be performed, along with pushing
  113	 	 	 	 	;       the return address.
  114	 	 	 	 	; Ouputs:
  115	 	 	 	 	;       None.
  116	 	 	 	 	; Registers:
  117	 	 	 	 	;       All except BP destroyed.
  118	 	 	 	 	
  119	 002F	 	 	 	$OGTA:
  120	 002F  B8	 	 	        DB      0B8H            ;MOV AX,(XOR AH,AH) - Insures AH non-zero
  121	 0030	 	 	 	$OGSA:
  122	 0030  32 E4	 	 	        XOR     AH,AH           ;Set flag for gosub
  123	 0032  0A FF	 	 	        OR      BH,BH
  124	 0034  75 28	 	 	        JNZ     ARGERR          ;In range 0-255?
  125	 0036  5E	 	 	        POP     SI
  126	 0037  1F	 	 	        POP     DS              ;DS:SI points to table
  127	 	 	 	 	        ASSUME  DS:NOTHING
  128	 0038  AC	 	 	        LODSB                   ;Get upper limit of index
  129	 0039  8A D0	 	 	        MOV     DL,AL
  130	 003B  B6 00	 	 	        MOV     DH,0
  131	 003D  D1 E2	 	 	        SHL     DX,1
  132	 003F  03 D6	 	 	        ADD     DX,SI           ;Compute first address after table
  133	 0041  4B	 	 	        DEC     BX              ;Index should be 0 to N-1
  134	 0042  3A C3	 	 	        CMP     AL,BL
  135	 0044  76 13	 	 	        JNA     ELSE1           ;If not in range, continue with next statement
  136	 0046  0A E4	 	 	        OR      AH,AH           ;Test flag
  137	 0048  75 0B	 	 	        JNZ     GETTARG         ;If GOTO, skip some work
  138	 004A  52	 	 	        PUSH    DX              ;Push return address
  139	 004B  26: 89 26 0000 E	 	        MOV     [$$STKP],SP     ;Save clean stack value
  140	 0050  26: FF 06 0000 R	 	        INC     [$$GCNT]        ;Bump nesting level
  141	 0055	 	 	 	GETTARG:
  142	 0055  D1 E3	 	 	        SHL     BX,1
  143	 0057  8B 10	 	 	        MOV     DX,[BX+SI]      ;Get target address in user segment
  144	 0059	 	 	 	ELSE1:
  145	 0059  1E	 	 	        PUSH    DS              ;Push user segment first
  146	 005A  52	 	 	        PUSH    DX
  147	 005B  06	 	 	        PUSH    ES
  148	 005C  1F	 	 	        POP     DS              ;Restore data segment
  149	 	 	 	 	        ASSUME  DS:DC
  150	 005D  CB	 	 	        RET                     ;Long return to target code
  151	 	 	 	 	
  152	 005E  E9 0000 E	 	ARGERR: JMP     $ERR_FC         ;Illegal Function Call if out of range
  153	 	 	 	 	
  154	 0061	 	 	 	GOSUB   ENDP
  155	 0061	 	 	 	CODE    ENDS
  156	 	 	 	 	        END








GOSUB - GOSUB, RETURN, and computed GOSUB/GOTO           Macro-86 %1(12)   1:2:59  13-Nov-81    Symbols-1




Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0061	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0002	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ARGERR . . . . . . . . . . . . .	L NEAR 	005E	CODE
ELSE1. . . . . . . . . . . . . .	L NEAR 	0059	CODE
ERR_RG . . . . . . . . . . . . .	L NEAR 	002C	CODE
GETTARG. . . . . . . . . . . . .	L NEAR 	0055	CODE
GOSUB. . . . . . . . . . . . . .	F PROC	0000	CODE	Length =0061
RETA1. . . . . . . . . . . . . .	L NEAR 	0025	CODE
$$GCNT . . . . . . . . . . . . .	L WORD 	0000	DATA
$$STKP . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ERR_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERR_RG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$GOSA. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$OGSA. . . . . . . . . . . . . .	L NEAR 	0030	CODE	Global
$OGTA. . . . . . . . . . . . . .	L NEAR 	002F	CODE	Global
$RELA. . . . . . . . . . . . . .	L NEAR 	0011	CODE	Global
$RETA. . . . . . . . . . . . . .	L NEAR 	001C	CODE	Global

Warning Severe
Errors	Errors 
0	0

























