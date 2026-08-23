TABSPC - TAB and SPC functions                           Macro-86 %1(12)   1:9:25  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   TABSPC - TAB and SPC functions
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 0000	 	 	 	DATA    ENDS
    5	 	 	 	 	
    6	 	 	 	 	DC      GROUP   DATA
    7	 	 	 	 	
    8	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
    9	 	 	 	 	
   10	 	 	 	 	        PUBLIC  $TABA,$TABB,$SPCA,$SPCB
   11	 	 	 	 	
   12	 	 	 	 	        EXTRN   $$WCH:NEAR, $$WCLF:NEAR, $$POS:NEAR, $$WID:NEAR
   13	 	 	 	 	
   14	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   15	 	 	 	 	
   16	 0000	 	 	 	TABSPC  PROC    FAR
   17	 	 	 	 	
   18	 	 	 	 	;***  $$SPCA, $SPCB - SPC function
   19	 	 	 	 	;
   20	 	 	 	 	; Inputs:
   21	 	 	 	 	;       BX = number of spaces
   22	 	 	 	 	; Function:
   23	 	 	 	 	;       Convert negative numbers to zero, then modulo it with line width.
   24	 	 	 	 	;       Then print that many spaces.
   25	 	 	 	 	; Outputs:
   26	 	 	 	 	;       None.
   27	 	 	 	 	; Registers:
   28	 	 	 	 	;       Only F affected.
   29	 	 	 	 	
   30	 0000	 	 	 	$SPCA:
   31	 0000	 	 	 	$SPCB:
   32	 0000  50	 	 	        PUSH    AX
   33	 0001  8B C3	 	 	        MOV     AX,BX
   34	 0003  E8 0029 R	 	        CALL    RNGCHK
   35	 0006	 	 	 	OUTSPC:
   36	 0006  50	 	 	        PUSH    AX
   37	 0007  B5 00	 	 	        MOV     CH,0
   38	 0009  E3 07	 	 	        JCXZ    NOSPC
   39	 000B	 	 	 	SPCLP:
   40	 000B  B0 20	 	 	        MOV     AL," "
   41	 000D  E8 0000 E	 	        CALL    $$WCH
   42	 0010  E2 F9	 	 	        LOOP    SPCLP
   43	 0012	 	 	 	NOSPC:
   44	 0012  59	 	 	        POP     CX
   45	 0013  58	 	 	        POP     AX
   46	 0014  CB	 	 	        RET
   47	 	 	 	 	
   48	 	 	 	 	;***  $TABA, $TABB - TAB function of PRINT statement
   49	 	 	 	 	;
   50	 	 	 	 	; Inputs:
   51	 	 	 	 	;       BX = position to tab to (1 is first)
   52	 	 	 	 	; Function:
   53	 	 	 	 	;       Convert arg<1 to 1, then modulo with line length.  Tab to position,
   54	 	 	 	 	;       send CR/LF if already beyond position.


TABSPC - TAB and SPC functions                           Macro-86 %1(12)   1:9:25  13-Nov-81    Page 1-2



   55	 	 	 	 	; Outputs:
   56	 	 	 	 	;       None.
   57	 	 	 	 	; Registers:
   58	 	 	 	 	;       Only F affected.
   59	 	 	 	 	
   60	 0015	 	 	 	$TABA:
   61	 0015	 	 	 	$TABB:
   62	 0015  50	 	 	        PUSH    AX
   63	 0016  8B C3	 	 	        MOV     AX,BX
   64	 0018  48	 	 	        DEC     AX
   65	 0019  E8 0029 R	 	        CALL    RNGCHK
   66	 001C  3A CD	 	 	        CMP     CL,CH           ;Check against current position
   67	 001E  73 05	 	 	        JAE     FIGSPC
   68	 0020  E8 0000 E	 	        CALL    $$WCLF          ;Output CR/LF if too far
   69	 0023  B5 00	 	 	        MOV     CH,0
   70	 0025	 	 	 	FIGSPC:
   71	 0025  2A CD	 	 	        SUB     CL,CH           ;Number of spaces needed
   72	 0027  EB DD	 	 	        JMP     OUTSPC
   73	 	 	 	 	
   74	 0029	 	 	 	TABSPC  ENDP
   75	 	 	 	 	
   76	 	 	 	 	
   77	 0029	 	 	 	RNGCHK:
   78	 0029  0B C0	 	 	        OR      AX,AX
   79	 002B  79 02	 	 	        JNS     NOTNEG          ;Make negative numbers zero
   80	 002D  33 C0	 	 	        XOR     AX,AX
   81	 002F	 	 	 	NOTNEG:
   82	 002F  52	 	 	        PUSH    DX
   83	 0030  53	 	 	        PUSH    BX
   84	 0031  93	 	 	        XCHG    AX,BX
   85	 0032  E8 0000 E	 	        CALL    $$WID
   86	 0035  86 C4	 	 	        XCHG    AL,AH
   87	 0037  B4 00	 	 	        MOV     AH,0
   88	 0039  93	 	 	        XCHG    AX,BX          ;(BX) = width
   89	 003A  33 D2	 	 	        XOR     DX,DX
   90	 003C  F7 F3	 	 	        DIV     BX
   91	 003E  8A C2	 	 	        MOV     AL,DL          ;Remainder is the answer
   92	 0040  E8 0000 E	 	        CALL    $$POS          ;(AH) = position
   93	 0043  91	 	 	        XCHG    AX,CX          ;(AX) = now has original (CX)
   94	 0044  5B	 	 	        POP     BX
   95	 0045  5A	 	 	        POP     DX
   96	 0046  C3	 	 	        RET
   97	 	 	 	 	
   98	 0047	 	 	 	CODE    ENDS
   99	 	 	 	 	        END











TABSPC - TAB and SPC functions                           Macro-86 %1(12)   1:9:25  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0047	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

FIGSPC . . . . . . . . . . . . .	L NEAR 	0025	CODE
NOSPC. . . . . . . . . . . . . .	L NEAR 	0012	CODE
NOTNEG . . . . . . . . . . . . .	L NEAR 	002F	CODE
OUTSPC . . . . . . . . . . . . .	L NEAR 	0006	CODE
RNGCHK . . . . . . . . . . . . .	L NEAR 	0029	CODE
SPCLP. . . . . . . . . . . . . .	L NEAR 	000B	CODE
TABSPC . . . . . . . . . . . . .	F PROC	0000	CODE	Length =0029
$$POS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$WCH. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$WCLF . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$WID. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SPCA. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$SPCB. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$TABA. . . . . . . . . . . . . .	L NEAR 	0015	CODE	Global
$TABB. . . . . . . . . . . . . .	L NEAR 	0015	CODE	Global

Warning Severe
Errors	Errors 
0	0

























