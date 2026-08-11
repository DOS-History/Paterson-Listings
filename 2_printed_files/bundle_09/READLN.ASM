READLN - Read a line into $INBUF from TTY                Macro-86 %1(12)   1:7:52  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   READLN - Read a line into $INBUF from TTY
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $INBUF:BYTE,$BUFLEN:BYTE,$LINLEN:BYTE
    6	 	 	 	 	
    7	 0000	 	 	 	DATA    ENDS
    8	 	 	 	 	
    9	 	 	 	 	DC      GROUP   DATA
   10	 	 	 	 	
   11	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   12	 	 	 	 	
   13	 	 	 	 	        PUBLIC  $RDLIN
   14	 	 	 	 	
   15	 	 	 	 	        EXTRN   $TYPSTR:NEAR,$$WCH:NEAR,$INPOVF:NEAR
   16	 	 	 	 	
   17	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   18	 	 	 	 	
   19	 	 	 	 	
   20	 0000	 	 	 	$RDLIN  PROC    NEAR
   21	 0000  C6 06 0000 E FF	 	        MOV     [$BUFLEN],255   ;Allow 255 character lines
   22	 0005  B4 0A	 	 	        MOV     AH,10
   23	 0007  BA 0000 E	 	        MOV     DX,OFFSET DC:$BUFLEN
   24	 000A  CD 21	 	 	        INT     33              ;Get input buffer
   25	 000C  8A 1E 0000 E	 	        MOV     BL,[$LINLEN]    ;Get length of line
   26	 0010  B7 00	 	 	        MOV     BH,0
   27	 0012  88 BF 0000 E	 	        MOV     $INBUF[BX],BH   ;Put zero at end of line
   28	 0016  C3	 	 	        RET
   29	 0017	 	 	 	$RDLIN  ENDP
   30	 	 	 	 	
   31	 0017	 	 	 	CODE    ENDS
   32	 	 	 	 	        END
























READLN - Read a line into $INBUF from TTY                Macro-86 %1(12)   1:7:52  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0017	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

$$WCH. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$BUFLEN. . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$INBUF . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$INPOVF. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$LINLEN. . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$RDLIN . . . . . . . . . . . . .	N PROC	0000	CODE	Global	Length =0017
$TYPSTR. . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0

































