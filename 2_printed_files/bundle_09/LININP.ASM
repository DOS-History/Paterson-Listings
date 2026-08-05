LININP - LINE INPUT statement                            Macro-86 %1(12)   1:6:2  13-Nov-18    Page 1-1



    1	 	 	 	 	        TITLE   LININP - LINE INPUT statement
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $FILBUF:WORD,$INBUF:BYTE,$$ERRV:WORD
    6	 	 	 	 	
    7	 0000	 	 	 	DATA    ENDS
    8	 	 	 	 	
    9	 	 	 	 	
   10	 	 	 	 	DC      GROUP   DATA
   11	 	 	 	 	
   12	 	 	 	 	
   13	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   14	 	 	 	 	
   15	 	 	 	 	        PUBLIC  $LIPA
   16	 	 	 	 	
   17	 	 	 	 	        EXTRN   $SAVREG:NEAR, $$CSL:NEAR, $$CTS:NEAR, $SAS:FAR, $CONT:NEAR
   18	 	 	 	 	
   19	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   20	 	 	 	 	
   21	 	 	 	 	
   22	 	 	 	 	;***  $LIPA - Assign LINE INPUT value
   23	 	 	 	 	;
   24	 	 	 	 	; Inputs:
   25	 	 	 	 	;       BX = Address of string variable to receive data
   26	 	 	 	 	; Function:
   27	 	 	 	 	;       Assign the input line to the string variable. Either $IN0A or $IN0B
   28	 	 	 	 	;       is called first to set up either terminal or disk I/O. If terminal
   29	 	 	 	 	;       I/O, then the line is already read into $INBUF and $FILBUF contains
   30	 	 	 	 	;       the address of a RET instruction. If disk I/O, line will be read
   31	 	 	 	 	;       from disk by routine at $FILBUF.
   32	 	 	 	 	; Outputs:
   33	 	 	 	 	;       None.
   34	 	 	 	 	; Registers:
   35	 	 	 	 	;       Only F affected.
   36	 	 	 	 	
   37	 0000	 	 	 	$LIPA:
   38	 0000  E8 0000 E	 	        CALL    $SAVREG
   39	 0003  C7 06 0000 E 0000 E	        MOV     [$$ERRV],OFFSET $CONT  ;Reset error vector to normal
   40	 0009  53	 	 	        PUSH    BX              ;Remember destination
   41	 000A  33 D2	 	 	        XOR     DX,DX           ;Init for FILBUF, if disk I/O
   42	 000C  FF 16 0000 E	 	        CALL    [$FILBUF]       ;Read in line if disk I/O
   43	 0010  BB 0000 E	 	        MOV     BX,OFFSET DC:$INBUF
   44	 0013  E8 0000 E	 	        CALL    $$CSL           ;Count length of line
   45	 0016  8B D3	 	 	        MOV     DX,BX
   46	 0018  93	 	 	        XCHG    AX,BX           ;Need length in BX, address in DX
   47	 0019  E8 0000 E	 	        CALL    $$CTS           ;Create temp string
   48	 001C  5A	 	 	        POP     DX              ;Recall destination address
   49	 001D  9A 0000 ---- E	 	        CALL    $SAS            ;Assign
   50	 0022  C3	 	 	        RET
   51	 	 	 	 	
   52	 0023	 	 	 	CODE    ENDS
   53	 	 	 	 	        END



LININP - LINE INPUT statement                            Macro-86 %1(12)   1:6:2  13-Nov-18    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0023	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

$$CSL. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$CTS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$ERRV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$CONT. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FILBUF. . . . . . . . . . . . .	V WORD 	0000	DATA	External
$INBUF . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$LIPA. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$SAS . . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0































