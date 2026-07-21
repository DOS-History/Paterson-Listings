MID - Left-hand MID$                                     Macro-86 %1(12)   1:6:11  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   MID - Left-hand MID$
    2	 	 	 	 	PAGE 60,132
    3	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
    4	 	 	 	 	
    5	 	 	 	 	        PUBLIC  $MD$A
    6	 	 	 	 	
    7	 	 	 	 	        EXTRN   $$DITS:NEAR, $ERR_FC:NEAR
    8	 	 	 	 	
    9	 	 	 	 	        ASSUME  CS:CODE
   10	 	 	 	 	
   11	 0000	 	 	 	$MD$A   PROC    FAR             ;Set up for long returns
   12	 	 	 	 	
   13	 	 	 	 	
   14	 	 	 	 	;***  $MD$A - MID$ statement
   15	 	 	 	 	;
   16	 	 	 	 	; Inputs:
   17	 	 	 	 	;       DX = Address of Destination string descriptor
   18	 	 	 	 	;       BX = Address of Source string descriptor
   19	 	 	 	 	;       CX = Starting offset in Destination
   20	 	 	 	 	;       AX = Max. length of copy
   21	 	 	 	 	; Function:
   22	 	 	 	 	;       Copy the source string into the destination string. Copying limited to
   23	 	 	 	 	;       present length of destination.
   24	 	 	 	 	; Outputs:
   25	 	 	 	 	;       None.
   26	 	 	 	 	; Registers:
   27	 	 	 	 	;       Only F affected.
   28	 	 	 	 	
   29	 0000  87 D3	 	 	        XCHG    DX,BX
   30	 0002  0B C9	 	 	        OR      CX,CX           ;Test for valid offset
   31	 0004  7E 36	 	 	        JLE     ARGERR          ;Must be greater than zero
   32	 0006  0B C0	 	 	        OR      AX,AX           ;Test for valid length
   33	 0008  7C 32	 	 	        JL      ARGERR          ;Must be zero or more
   34	 000A  3B 0F	 	 	        CMP     CX,[BX]         ;Compare offset to current length of string
   35	 000C  77 2E	 	 	        JA      ARGERR          ;Offset must not exceed string size
   36	 000E  56	 	 	        PUSH    SI
   37	 000F  57	 	 	        PUSH    DI
   38	 0010  51	 	 	        PUSH    CX
   39	 0011  8B 7F 02	 	 	        MOV     DI,[BX+2]       ;Pointer to destination data
   40	 0014  49	 	 	        DEC     CX              ;Need offset starting at 0, not 1
   41	 0015  03 F9	 	 	        ADD     DI,CX           ;Add in offset
   42	 0017  2B 0F	 	 	        SUB     CX,[BX]
   43	 0019  F7 D9	 	 	        NEG     CX              ;Length - Offset
   44	 001B  3B C8	 	 	        CMP     CX,AX           ;Take minimum of this and count parameter
   45	 001D  72 02	 	 	        JB      MIN1
   46	 001F  8B C8	 	 	        MOV     CX,AX           ;Count parameter was lower
   47	 0021	 	 	 	MIN1:
   48	 0021  8B F2	 	 	        MOV     SI,DX           ;Get source where we can address with it
   49	 0023  3B 0C	 	 	        CMP     CX,[SI]         ;Compare current move length to string length
   50	 0025  76 02	 	 	        JBE     MIN2
   51	 0027  8B 0C	 	 	        MOV     CX,[SI]         ;Source string was smaller
   52	 0029	 	 	 	MIN2:
   53	 0029  8B 74 02	 	 	        MOV     SI,[SI+2]       ;Get pointer to source data
   54	 002C  D1 E9	 	 	        SHR     CX,1            ;Convert byte count to word count


MID - Left-hand MID$                                     Macro-86 %1(12)   1:6:11  13-Nov-81    Page 1-2



   55	 002E  F3/ A5	 	 	        REP     MOVSW
   56	 0030  73 01	 	 	        JNC     EVENMOV         ;Was count odd?
   57	 0032  A4	 	 	        MOVSB                   ;Move that last byte
   58	 0033	 	 	 	EVENMOV:
   59	 0033  59	 	 	        POP     CX
   60	 0034  5F	 	 	        POP     DI
   61	 0035  5E	 	 	        POP     SI
   62	 0036  87 DA	 	 	        XCHG    BX,DX           ;Need source addr. in BX
   63	 0038  E8 0000 E	 	        CALL    $$DITS          ;Delete source if temp string
   64	 003B  CB	 	 	        RET
   65	 	 	 	 	
   66	 003C	 	 	 	ARGERR:
   67	 003C  E9 0000 E	 	        JMP     $ERR_FC         ;Illegal function call
   68	 	 	 	 	
   69	 003F	 	 	 	$MD$A   ENDP
   70	 003F	 	 	 	CODE    ENDS
   71	 	 	 	 	        END







































MID - Left-hand MID$                                     Macro-86 %1(12)   1:6:11  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	003F	BYTE  	PUBLIC	'CODE'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ARGERR . . . . . . . . . . . . .	L NEAR 	003C	CODE
EVENMOV. . . . . . . . . . . . .	L NEAR 	0033	CODE
MIN1 . . . . . . . . . . . . . .	L NEAR 	0021	CODE
MIN2 . . . . . . . . . . . . . .	L NEAR 	0029	CODE
$$DITS . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERR_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$MD$A. . . . . . . . . . . . . .	F PROC	0000	CODE	Global	Length =003F

Warning Severe
Errors	Errors 
0	0



































