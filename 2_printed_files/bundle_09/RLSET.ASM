RLSET - RSET and LSET statements                                 Macro-86 %1(12)   1:8:1  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   RLSET - RSET and LSET statements
    2	 	 	 	 	
    3	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
    4	 	 	 	 	
    5	 	 	 	 	        PUBLIC  $LSEA,$RSEA
    6	 	 	 	 	
    7	 	 	 	 	        EXTRN   $$DITS:NEAR
    8	 	 	 	 	
    9	 	 	 	 	        ASSUME  CS:CODE
   10	 	 	 	 	
   11	 0000	 	 	 	RLSET   PROC    FAR             ;Set up for long returns
   12	 	 	 	 	
   13	 	 	 	 	
   14	 	 	 	 	;***  $RSEA and $LSEA - RSET and LSET statements
   15	 	 	 	 	;
   16	 	 	 	 	; Inputs:
   17	 	 	 	 	;       DX = Address of Destination string descriptor
   18	 	 	 	 	;       BX = Address of Source string descriptor
   19	 	 	 	 	; Function:
   20	 	 	 	 	;       Copy source to destination. If destination is larger than source,
   21	 	 	 	 	;       pad with blanks. RSET has leading blanks, LSET trailing blanks.
   22	 	 	 	 	; Outputs:
   23	 	 	 	 	;       None.
   24	 	 	 	 	; Registers:
   25	 	 	 	 	;       Only F affected.
   26	 	 	 	 	
   27	 0000	 	 	 	$RSEA:
   28	 0000  51	 	 	        PUSH    CX
   29	 0001  52	 	 	        PUSH    DX
   30	 0002  53	 	 	        PUSH    BX
   31	 0003  50	 	 	        PUSH    AX
   32	 0004  E8 0043 R	 	        CALL    PREP            ;Set up registers (source in SI, dest in DI)
   33	 0007  50	 	 	        PUSH    AX              ;Save count of characters to copy
   34	 0008  D1 E9	 	 	        SHR     CX,1            ;Convert count of blanks to pad to word count
   35	 000A  B8 2020	 	 	        MOV     AX,"  "         ;2 blanks at a time
   36	 000D  F3/ AB	 	 	        REP     STOSW
   37	 000F  73 01	 	 	        JNC     SKPSTO          ;See if we need an odd number
   38	 0011  AA	 	 	        STOSB                   ;Put in that last blank
   39	 0012	 	 	 	SKPSTO:
   40	 0012  59	 	 	        POP     CX              ;Count of characters to copy
   41	 0013  D1 E9	 	 	        SHR     CX,1            ;Now count of words
   42	 0015  F3/ A5	 	 	        REP     MOVSW
   43	 0017  73 01	 	 	        JNC     POPSET          ;Moving an odd number?
   44	 0019  A4	 	 	        MOVSB                   ;Move that last byte
   45	 001A	 	 	 	POPSET:
   46	 001A  8B FA	 	 	        MOV     DI,DX           ;Restore DI
   47	 001C  8B F3	 	 	        MOV     SI,BX           ;Restore SI
   48	 001E  58	 	 	        POP     AX
   49	 001F  5B	 	 	        POP     BX
   50	 0020  5A	 	 	        POP     DX
   51	 0021  59	 	 	        POP     CX
   52	 0022  E8 0000 E	 	        CALL    $$DITS          ;Delete source if a temp
   53	 0025  CB	 	 	        RET
   54	 	 	 	 	


RLSET - RSET and LSET statements                                 Macro-86 %1(12)   1:8:1  13-Nov-81    Page 1-2



   55	 0026	 	 	 	$LSEA:
   56	 0026  51	 	 	        PUSH    CX
   57	 0027  52	 	 	        PUSH    DX
   58	 0028  53	 	 	        PUSH    BX
   59	 0029  50	 	 	        PUSH    AX
   60	 002A  E8 0043 R	 	        CALL    PREP
   61	 002D  91	 	 	        XCHG    AX,CX           ;Get move count in CX
   62	 002E  D1 E9	 	 	        SHR     CX,1            ;Convert byte count to word count
   63	 0030  F3/ A5	 	 	        REP     MOVSW
   64	 0032  73 01	 	 	        JNC     SKPMOV          ;See if an odd count
   65	 0034  A4	 	 	        MOVSB                   ;Move that last byte
   66	 0035	 	 	 	SKPMOV:
   67	 0035  8B C8	 	 	        MOV     CX,AX           ;Get count of blanks to fill
   68	 0037  D1 E9	 	 	        SHR     CX,1            ;Make byte count a word count
   69	 0039  B8 2020	 	 	        MOV     AX,"  "         ;2 blanks at a time
   70	 003C  F3/ AB	 	 	        REP     STOSW
   71	 003E  73 DA	 	 	        JNC     POPSET          ;See if an odd count
   72	 0040  AA	 	 	        STOSB                   ;Do that last byte
   73	 0041  EB D7	 	 	        JMP     POPSET
   74	 	 	 	 	
   75	 	 	 	 	
   76	 0043	 	 	 	PREP    PROC    NEAR
   77	 	 	 	 	
   78	 	 	 	 	; This routine sets up the registers for LSET and RSET.
   79	 	 	 	 	; Inputs:
   80	 	 	 	 	;       BX = Source string descriptor
   81	 	 	 	 	;       DX = Dest. string descriptor
   82	 	 	 	 	; Outputs:
   83	 	 	 	 	;       AX = Number of byte to move from source to dest.
   84	 	 	 	 	;       BX = Saved SI
   85	 	 	 	 	;       CX = Number of blanks to pad (zero if source size > dest size)
   86	 	 	 	 	;       DX = Saved DI
   87	 	 	 	 	;       DI = Destination data address
   88	 	 	 	 	;       SI = Source data address
   89	 	 	 	 	
   90	 0043  87 F3	 	 	        XCHG    SI,BX
   91	 0045  87 FA	 	 	        XCHG    DI,DX
   92	 0047  AD	 	 	        LODSW                   ;Get size of source string
   93	 0048  8B 0D	 	 	        MOV     CX,[DI]         ;Get size of dest string
   94	 004A  8B 34	 	 	        MOV     SI,[SI]         ;Get source data address (LODSW added 2 to SI)
   95	 004C  8B 7D 02	 	 	        MOV     DI,[DI+2]       ;Get destination data address
   96	 004F  2B C8	 	 	        SUB     CX,AX           ;Number of blanks to pad with (dest - source)
   97	 0051  73 04	 	 	        JAE     RET             ;If not negative, we're done
   98	 0053  03 C1	 	 	        ADD     AX,CX           ;Set move count to size of dest string
   99	 0055  33 C9	 	 	        XOR     CX,CX           ;Set blank fill to zero
  100	 0057  C3	 	 	RET:    RET
  101	 	 	 	 	
  102	 0058	 	 	 	PREP    ENDP
  103	 0058	 	 	 	RLSET   ENDP
  104	 0058	 	 	 	CODE    ENDS
  105	 	 	 	 	        END





RLSET - RSET and LSET statements                                 Macro-86 %1(12)   1:8:1  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0058	BYTE  	PUBLIC	'CODE'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

POPSET . . . . . . . . . . . . .	L NEAR 	001A	CODE
PREP . . . . . . . . . . . . . .	N PROC	0043	CODE	Length =0015
RET. . . . . . . . . . . . . . .	L NEAR 	0057	CODE
RLSET. . . . . . . . . . . . . .	F PROC	0000	CODE	Length =0058
SKPMOV . . . . . . . . . . . . .	L NEAR 	0035	CODE
SKPSTO . . . . . . . . . . . . .	L NEAR 	0012	CODE
$$DITS . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$LSEA. . . . . . . . . . . . . .	L NEAR 	0026	CODE	Global
$RSEA. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global

Warning Severe
Errors	Errors 
0	0

































