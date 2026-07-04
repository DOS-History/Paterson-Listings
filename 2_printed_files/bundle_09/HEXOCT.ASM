HEXOCT - OCT, HEX functions                              Macro-86 %1(12)   1:3:4  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   HEXOCT - OCT, HEX functions
    2	 	 	 	 	        
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        EXTRN   $$SPSV:WORD
    6	 	 	 	 	
    7	 0000     06 [	 	 	DBUF    DB      6 DUP(?)
    8	                ??	 	
    9	                    ]	 	
   10	 	 	 	 	
   11	 	 	 	 	
   12	 0006	 	 	 	DATA    ENDS
   13	 	 	 	 	
   14	 	 	 	 	DC      GROUP   DATA
   15	 	 	 	 	
   16	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   17	 	 	 	 	
   18	 	 	 	 	        PUBLIC  $HEX,$OCT,$HXF,$OCF
   19	 	 	 	 	
   20	 	 	 	 	        EXTRN   $$CTS:NEAR,$ADC:FAR
   21	 	 	 	 	
   22	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   23	 	 	 	 	
   24	 0000	 	 	 	OCTHEX  PROC    FAR             ;Set up for long returns
   25	 	 	 	 	
   26	 	 	 	 	
   27	 	 	 	 	;***  $HEX,$HXF,$OCT,$OCF - Convert number to hexadecimal or octal string
   28	 	 	 	 	;
   29	 	 	 	 	; Inputs:
   30	 	 	 	 	;       BX - Integer value to be converted ($OCT/$HEX)
   31	 	 	 	 	;       BX - Address of SP number ($OCF/$HXF)
   32	 	 	 	 	; Function:
   33	 	 	 	 	;       Create a string of minimum length (no leading zeros) that represents
   34	 	 	 	 	;       the value of the number in octal or hex.
   35	 	 	 	 	; Outputs:
   36	 	 	 	 	;       BX = Address of string descriptor
   37	 	 	 	 	; Registers:
   38	 	 	 	 	;       Only BX and F affected.
   39	 	 	 	 	
   40	 0000	 	 	 	$OCF:
   41	 0000  89 26 0000 E	 	        MOV     [$$SPSV],SP
   42	 0004  56	 	 	        PUSH    SI
   43	 0005  8B F3	 	 	        MOV     SI,BX           ;$ADC needs address in SI
   44	 0007  9A 0000 ---- E	 	        CALL    $ADC            ;Convert SP to address
   45	 000C  5E	 	 	        POP     SI
   46	 000D	 	 	 	$OCT:
   47	 000D  89 26 0000 E	 	        MOV     [$$SPSV],SP
   48	 0011  51	 	 	        PUSH    CX
   49	 0012  B9 0703	 	 	        MOV     CX,0703H        ;Shift count in CL, mask in CH
   50	 0015  EB 15	 	 	        JMP     SHORT HEXOCT
   51	 	 	 	 	
   52	 0017	 	 	 	$HXF:
   53	 0017  89 26 0000 E	 	        MOV     [$$SPSV],SP
   54	 001B  56	 	 	        PUSH    SI


HEXOCT - OCT, HEX functions                              Macro-86 %1(12)   1:3:4  13-Nov-81    Page 1-2



   55	 001C  8B F3	 	 	        MOV     SI,BX           ;$ADC needs address in SI
   56	 001E  9A 0000 ---- E	 	        CALL    $ADC            ;Convert SP to address
   57	 0023  5E	 	 	        POP     SI
   58	 0024	 	 	 	$HEX:
   59	 0024  89 26 0000 E	 	        MOV     [$$SPSV],SP
   60	 0028  51	 	 	        PUSH    CX
   61	 0029  B9 0F04	 	 	        MOV     CX,0F04H        ;Set mask (CH) and shift count (CL)
   62	 002C	 	 	 	HEXOCT:
   63	 002C  50	 	 	        PUSH    AX
   64	 002D  57	 	 	        PUSH    DI
   65	 002E  B4 00	 	 	        MOV     AH,0            ;Initialize digit count
   66	 0030  BF 0005 R	 	        MOV     DI,OFFSET DC:DBUF+5  ;Start from back end of digit buffer
   67	 0033  FD	 	 	        STD                     ;   and work down
   68	 	 	 	 	
   69	 	 	 	 	; At this point, the following conditions exist:
   70	 	 	 	 	;       AH = character count
   71	 	 	 	 	;       CX = Shift count and mask
   72	 	 	 	 	;       BX = Number to convert
   73	 	 	 	 	;       DI = Pointer into digit buffer
   74	 	 	 	 	
   75	 0034	 	 	 	CONV:
   76	 0034  8A C3	 	 	        MOV     AL,BL           ;Bring it to accumulator
   77	 0036  22 C5	 	 	        AND     AL,CH           ;Mask down to the bits that count
   78	 	 	 	 	;Trick 6-byte hex conversion
   79	 0038  04 90	 	 	        ADD     AL,90H
   80	 003A  27	 	 	        DAA
   81	 003B  14 40	 	 	        ADC     AL,40H
   82	 003D  27	 	 	        DAA                     ;Number in hex now
   83	 003E  AA	 	 	        STOSB                   ;Save in string
   84	 003F  FE C4	 	 	        INC     AH              ;Count the digits
   85	 0041  D3 EB	 	 	        SHR     BX,CL           ;Bring down next digit
   86	 0043  75 EF	 	 	        JNZ     CONV
   87	 0045  FC	 	 	        CLD                     ;Restore direction UP
   88	 0046  47	 	 	        INC     DI              ;Point to most significant digit
   89	 0047  8A DC	 	 	        MOV     BL,AH           ;Digit count in BX (BH already zero)
   90	 0049  87 FA	 	 	        XCHG    DI,DX           ;Save DX and put pointer there
   91	 004B  E8 0000 E	 	        CALL    $$CTS           ;Allocate string and copy data in
   92	 004E  8B D7	 	 	        MOV     DX,DI           ;Restore DX
   93	 0050  5F	 	 	        POP     DI
   94	 0051  58	 	 	        POP     AX
   95	 0052  59	 	 	        POP     CX
   96	 0053  CB	 	 	        RET
   97	 	 	 	 	
   98	 0054	 	 	 	OCTHEX  ENDP
   99	 0054	 	 	 	CODE    ENDS
  100	 	 	 	 	        END










HEXOCT - OCT, HEX functions                              Macro-86 %1(12)   1:3:4  13-Nov-81    Symbols-1




Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0054	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0006	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

CONV . . . . . . . . . . . . . .	L NEAR 	0034	CODE
DBUF . . . . . . . . . . . . . .	L BYTE 	0000	DATA	Length =0006
HEXOCT . . . . . . . . . . . . .	L NEAR 	002C	CODE
OCTHEX . . . . . . . . . . . . .	F PROC	0000	CODE	Length =0054
$$CTS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ADC . . . . . . . . . . . . . .	L FAR  	0000	CODE	External
$HEX . . . . . . . . . . . . . .	L NEAR 	0024	CODE	Global
$HXF . . . . . . . . . . . . . .	L NEAR 	0017	CODE	Global
$OCF . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$OCT . . . . . . . . . . . . . .	L NEAR 	000D	CODE	Global

Warning Severe
Errors	Errors 
0	0





























