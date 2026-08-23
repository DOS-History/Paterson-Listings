SWAP - Swap values                                       Macro-86 %1(12)   1:9:20  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   SWAP - Swap values
    2	 	 	 	 	
    3	 = 00B0	 	 	 	SKIP1=  0B0H            ;MOV    AL,immediate (to skip next one-byte instruc.)
    4	 	 	 	 	
    5	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    6	 	 	 	 	
    7	 	 	 	 	        EXTRN   $$SFWA:WORD, $$SLWA:WORD
    8	 	 	 	 	
    9	 0000	 	 	 	DATA    ENDS
   10	 	 	 	 	
   11	 	 	 	 	
   12	 	 	 	 	DC      GROUP   DATA
   13	 	 	 	 	
   14	 	 	 	 	
   15	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   16	 	 	 	 	
   17	 	 	 	 	        PUBLIC  $SWPA,$SWPB,$SWPC,$SWPD
   18	 	 	 	 	
   19	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   20	 	 	 	 	
   21	 	 	 	 	
   22	 0000	 	 	 	SWAP    PROC    FAR
   23	 	 	 	 	
   24	 	 	 	 	;***  $SWPx - Swap values
   25	 	 	 	 	;
   26	 	 	 	 	; Inputs:
   27	 	 	 	 	;       SI = Address of one operand
   28	 	 	 	 	;       DI = Address of other operand
   29	 	 	 	 	; Function:
   30	 	 	 	 	;       Interchange values. Note that strings must have backpointers reset.
   31	 	 	 	 	; Outputs:
   32	 	 	 	 	;       None.
   33	 	 	 	 	; Registers:
   34	 	 	 	 	;       Only F affected.
   35	 	 	 	 	
   36	 0000	 	 	 	$SWPB:  ;Double precision
   37	 0000  53	 	 	        PUSH    BX
   38	 0001  8B 5C 04	 	 	        MOV     BX,[SI+4]
   39	 0004  87 5D 04	 	 	        XCHG    BX,[DI+4]
   40	 0007  89 5C 04	 	 	        MOV     [SI+4],BX
   41	 000A  8B 5C 06	 	 	        MOV     BX,[SI+6]
   42	 000D  87 5D 06	 	 	        XCHG    BX,[DI+6]
   43	 0010  89 5C 06	 	 	        MOV     [SI+6],BX
   44	 0013  B0	 	 	        DB      SKIP1           ;Skip PUSH in $SWPA
   45	 0014	 	 	 	$SWPA:  ;Single precision
   46	 0014  53	 	 	        PUSH    BX
   47	 0015	 	 	 	SDSWP:
   48	 0015  8B 5C 02	 	 	        MOV     BX,[SI+2]
   49	 0018  87 5D 02	 	 	        XCHG    BX,[DI+2]
   50	 001B  89 5C 02	 	 	        MOV     [SI+2],BX
   51	 001E  B0	 	 	        DB      SKIP1           ;Skip PUSH in $SWPC
   52	 001F	 	 	 	$SWPC:  ;Integer
   53	 001F  53	 	 	        PUSH    BX
   54	 0020  8B 1C	 	 	        MOV     BX,[SI]


SWAP - Swap values                                       Macro-86 %1(12)   1:9:20  13-Nov-81    Page 1-2



   55	 0022  87 1D	 	 	        XCHG    BX,[DI]
   56	 0024  89 1C	 	 	        MOV     [SI],BX
   57	 0026  5B	 	 	        POP     BX
   58	 0027  CB	 	 	        RET
   59	 	 	 	 	
   60	 0028	 	 	 	$SWPD:  ;Strings
   61	 0028  53	 	 	        PUSH    BX
   62	 0029  8B 1C	 	 	        MOV     BX,[SI]
   63	 	 	 	 	;Check to see if it's in string space
   64	 002B  3B 1E 0000 E	 	        CMP     BX,[$$SFWA]
   65	 002F  72 0C	 	 	        JB      NOFIX
   66	 0031  3B 1E 0000 E	 	        CMP     BX,[$$SLWA]
   67	 0035  73 06	 	 	        JAE     NOFIX
   68	 0037  8B 5C 02	 	 	        MOV     BX,[SI+2]       ;Address of string data
   69	 003A  89 7F FE	 	 	        MOV     [BX-2],DI       ;Change a backpointer
   70	 003D	 	 	 	NOFIX:
   71	 003D  8B 1D	 	 	        MOV     BX,[DI]
   72	 	 	 	 	;Check to see if it's in string space
   73	 003F  3B 1E 0000 E	 	        CMP     BX,[$$SFWA]
   74	 0043  72 D0	 	 	        JB      SDSWP
   75	 0045  3B 1E 0000 E	 	        CMP     BX,[$$SLWA]
   76	 0049  73 CA	 	 	        JAE     SDSWP
   77	 004B  8B 5D 02	 	 	        MOV     BX,[DI+2]
   78	 004E  89 77 FE	 	 	        MOV     [BX-2],SI
   79	 0051  EB C2	 	 	        JMP     SDSWP           ;Now swap string descriptors
   80	 	 	 	 	
   81	 0053	 	 	 	SWAP    ENDP
   82	 0053	 	 	 	CODE    ENDS
   83	 	 	 	 	        END



























SWAP - Swap values                                       Macro-86 %1(12)   1:9:20  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0053	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

NOFIX. . . . . . . . . . . . . .	L NEAR 	003D	CODE
SDSWP. . . . . . . . . . . . . .	L NEAR 	0015	CODE
SKIP1. . . . . . . . . . . . . .	Number	00B0	
SWAP . . . . . . . . . . . . . .	F PROC	0000	CODE	Length =0053
$$SFWA . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$SLWA . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$SWPA. . . . . . . . . . . . . .	L NEAR 	0014	CODE	Global
$SWPB. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$SWPC. . . . . . . . . . . . . .	L NEAR 	001F	CODE	Global
$SWPD. . . . . . . . . . . . . .	L NEAR 	0028	CODE	Global

Warning Severe
Errors	Errors 
0	0






























