INPTTY - Prepare for input from TTY                      Macro-86 %1(12)   1:3:21  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   INPTTY - Prepare for input from TTY
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $PTRFIL:WORD,$$ERRV:WORD,$INBUF:BYTE,$BUFLEN:BYTE,$LINELEN:BYTE
    6	 	 	 	 	        EXTRN   $FILBUF:WORD
    7	 	 	 	 	
    8	 0000  ????	 	 	PROMPT  DW      ?
    9	 0002  ??	 	 	INFL    DB      ?
   10	 	 	 	 	
   11	 0003	 	 	 	DATA    ENDS
   12	 	 	 	 	
   13	 	 	 	 	DC      GROUP   DATA
   14	 	 	 	 	
   15	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   16	 	 	 	 	
   17	 	 	 	 	        PUBLIC  $IN0A,$REDO
   18	 	 	 	 	
   19	 	 	 	 	        EXTRN   $TYPSTR:NEAR,$$WCH:NEAR,$$WCLF:NEAR,$INPOVF:NEAR
   20	 	 	 	 	        EXTRN   $RDLIN:NEAR
   21	 	 	 	 	
   22	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   23	 	 	 	 	
   24	 	 	 	 	
   25	 0000	 	 	 	INPUT   PROC    FAR
   26	 	 	 	 	
   27	 	 	 	 	;***  $IN0A - Prepare for console input
   28	 	 	 	 	;
   29	 	 	 	 	; Inputs:
   30	 	 	 	 	;       BX = Address of prompt string descriptor.
   31	 	 	 	 	;       Return address on top of stack has long pointer to parameter byte.
   32	 	 	 	 	;       If bit 1 is set in this byte, don't print "?" after prompt.
   33	 	 	 	 	;       If bit 0 is set, don't echo CR/LF after getting input.
   34	 	 	 	 	; Function:
   35	 	 	 	 	;       Set up input from TTY and read input line.
   36	 	 	 	 	; Outputs:
   37	 	 	 	 	;       None.
   38	 	 	 	 	; Registers:
   39	 	 	 	 	;       All except BP destroyed.
   40	 	 	 	 	
   41	 0000	 	 	 	$IN0A:
   42	 0000  5E	 	 	        POP     SI
   43	 0001  1F	 	 	        POP     DS              ;Point to parameter byte
   44	 0002  AC	 	 	        LODSB
   45	 0003  1E	 	 	        PUSH    DS
   46	 0004  56	 	 	        PUSH    SI              ;Put return address back on stack
   47	 0005  06	 	 	        PUSH    ES
   48	 0006  1F	 	 	        POP     DS              ;Restore DS
   49	 0007  A2 0002 R	 	        MOV     [INFL],AL       ;Save parameter byte
   50	 000A  89 1E 0000 R	 	        MOV     [PROMPT],BX     ;Save prompt string descriptor address
   51	 000E  C7 06 0000 E 0000	        MOV     [$PTRFIL],0     ;Set output to terminal
   52	 0014  C7 06 0000 E 0000 E	        MOV     [$$ERRV],OFFSET $INPOVF ;Trap all errors
   53	 001A  C7 06 0000 E 0046 R	        MOV     [$FILBUF],OFFSET RET  ;Don't get input from disk
   54	 0020	 	 	 	$REDO:


INPTTY - Prepare for input from TTY                      Macro-86 %1(12)   1:3:21  13-Nov-81    Page 1-2



   55	 	 	 	 	;Enter here if error to re-prompt and re-read data
   56	 0020  8B 1E 0000 R	 	        MOV     BX,[PROMPT]
   57	 0024  E8 0000 E	 	        CALL    $TYPSTR         ;Print string
   58	 0027  F6 06 0002 R 02	 	        TEST    [INFL],2        ;Need a "?" after prompt?
   59	 002C  75 0A	 	 	        JNZ     GETLIN
   60	 002E  B0 3F	 	 	        MOV     AL,"?"
   61	 0030  E8 0000 E	 	        CALL    $$WCH
   62	 0033  B0 20	 	 	        MOV     AL," "
   63	 0035  E8 0000 E	 	        CALL    $$WCH
   64	 0038	 	 	 	GETLIN:
   65	 0038  E8 0000 E	 	        CALL    $RDLIN          ;Get input line
   66	 003B  F6 06 0002 R 01	 	        TEST    [INFL],1        ;Is it INPUT "semi-colon" ?
   67	 0040  75 03	 	 	        JNZ     GETLIX          ;Yes, don't send <CR><LF>
   68	 0042  E8 0000 E	 	        CALL    $$WCLF
   69	 0045	 	 	 	GETLIX:
   70	 0045  CB	 	 	        RET
   71	 	 	 	 	
   72	 0046	 	 	 	INPUT   ENDP
   73	 	 	 	 	
   74	 	 	 	 	
   75	 0046  C3	 	 	RET:    RET                     ;NEAR RET
   76	 	 	 	 	
   77	 0047	 	 	 	CODE    ENDS
   78	 	 	 	 	        END
































INPTTY - Prepare for input from TTY                      Macro-86 %1(12)   1:3:21  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0047	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0003	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

GETLIN . . . . . . . . . . . . .	L NEAR 	0038	CODE
GETLIX . . . . . . . . . . . . .	L NEAR 	0045	CODE
INFL . . . . . . . . . . . . . .	L BYTE 	0002	DATA
INPUT. . . . . . . . . . . . . .	F PROC	0000	CODE	Length =0046
PROMPT . . . . . . . . . . . . .	L WORD 	0000	DATA
RET. . . . . . . . . . . . . . .	L NEAR 	0046	CODE
$$ERRV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$WCH. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$WCLF . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$BUFLEN. . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FILBUF. . . . . . . . . . . . .	V WORD 	0000	DATA	External
$IN0A. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$INBUF . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$INPOVF. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$LINELEN . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$PTRFIL. . . . . . . . . . . . .	V WORD 	0000	DATA	External
$RDLIN . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$REDO. . . . . . . . . . . . . .	L NEAR 	0020	CODE	Global
$TYPSTR. . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0





















