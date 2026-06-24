DSQRT - Double precision square root                     Macro-86 %1(12)   1:0:45  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   DSQRT - Double precision square root
    2	 	 	 	 	
    3	 	 	 	 	;The method used here is to get a good estimate using single-precision square
    4	 	 	 	 	;root and then use two Newton-Raphson iterations.
    5	 	 	 	 	
    6	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    7	 	 	 	 	
    8	 	 	 	 	        EXTRN   $FAC:BYTE, $DAC:WORD, $TEMP:WORD, $ARG:WORD
    9	 	 	 	 	
   10	 0000	 	 	 	DATA    ENDS
   11	 	 	 	 	
   12	 	 	 	 	
   13	 	 	 	 	DC      GROUP   DATA
   14	 	 	 	 	
   15	 	 	 	 	
   16	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   17	 	 	 	 	
   18	 	 	 	 	        PUBLIC  $SQD
   19	 	 	 	 	
   20	 	 	 	 	        EXTRN   $SAVREG:NEAR, $SSQRT:NEAR, $DDIV:NEAR, $DADD:NEAR
   21	 	 	 	 	
   22	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   23	 	 	 	 	
   24	 	 	 	 	
   25	 	 	 	 	;*** $SQD - Double precision square root
   26	 	 	 	 	;
   27	 	 	 	 	; Inputs:
   28	 	 	 	 	;       BX = Address of operand
   29	 	 	 	 	; Outputs:
   30	 	 	 	 	;       Result in FAC
   31	 	 	 	 	; Registers:
   32	 	 	 	 	;       Only F affected.
   33	 	 	 	 	
   34	 0000	 	 	 	$SQD:
   35	 0000  E8 0000 E	 	        CALL    $SAVREG
   36	 0003  8B F3	 	 	        MOV     SI,BX
   37	 0005  BF 0000 E	 	        MOV     DI,OFFSET DC:$ARG
   38	 0008  A5	 	 	        MOVSW                   ;Move argument to ARG
   39	 0009  A5	 	 	        MOVSW
   40	 000A  A5	 	 	        MOVSW
   41	 000B  A5	 	 	        MOVSW
   42	 000C  83 C3 04	 	 	        ADD     BX,4            ;Pretend argument it single precision
   43	 000F  E8 0000 E	 	        CALL    $SSQRT          ;Get S.P. square root as first guess
   44	 0012  33 C0	 	 	        XOR     AX,AX
   45	 0014  A3 0000 E	 	        MOV     [$DAC],AX
   46	 0017  A3 0002 E	 	        MOV     [$DAC+2],AX     ;Zero extended part
   47	 001A  E8 001D R	 	        CALL    NEWTON
   48	 001D	 	 	 	NEWTON:
   49	 001D  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   50	 0020  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
   51	 0023  A5	 	 	        MOVSW
   52	 0024  A5	 	 	        MOVSW
   53	 0025  A5	 	 	        MOVSW
   54	 0026  A5	 	 	        MOVSW                   ;Copy guess to TEMP


DSQRT - Double precision square root                     Macro-86 %1(12)   1:0:45  13-Nov-81    Page 1-2



   55	 0027  BE 0000 E	 	        MOV     SI,OFFSET DC:$ARG
   56	 002A  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   57	 002D  E8 0000 E	 	        CALL    $DDIV           ;DAC = ARG/guess
   58	 0030  BE 0000 E	 	        MOV     SI,OFFSET DC:$DAC
   59	 0033  BF 0000 E	 	        MOV     DI,OFFSET DC:$TEMP
   60	 0036  E8 0000 E	 	        CALL    $DADD           ;DAC = guess + (ARG/guess)
   61	 0039  FE 0E 0000 E	 	        DEC     [$FAC]          ;DAC = [guess + (ARG/guess)] / 2
   62	 003D  C3	 	 	        RET
   63	 	 	 	 	
   64	 003E	 	 	 	CODE    ENDS
   65	 	 	 	 	        END













































DSQRT - Double precision square root                     Macro-86 %1(12)   1:0:45  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	003E	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

NEWTON . . . . . . . . . . . . .	L NEAR 	001D	CODE
$ARG . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$DADD. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DDIV. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SQD . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$SSQRT . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TEMP. . . . . . . . . . . . . .	V WORD 	0000	DATA	External

Warning Severe
Errors	Errors 
0	0






























