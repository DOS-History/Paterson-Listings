STRNUM - String to number and number to string conversions Macro-86 %1(12)   1:8:56  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   STRNUM - String to number and number to string conversions
    2	 	 	 	 	; Code for CVI, CVS, CVD, MKI$, MKS$, and MKD$
    3	 	 	 	 	
    4	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    5	 	 	 	 	
    6	 	 	 	 	        EXTRN   $AC:WORD, $DAC:WORD, $$SPSV:WORD
    7	 	 	 	 	
    8	 0000	 	 	 	DATA    ENDS
    9	 	 	 	 	
   10	 	 	 	 	DC      GROUP   DATA
   11	 	 	 	 	
   12	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   13	 	 	 	 	
   14	 	 	 	 	        PUBLIC  $CVI,$CVS,$CVD,$MKI,$MKS,$MKD
   15	 	 	 	 	
   16	 	 	 	 	        EXTRN   $$DITS:NEAR, $$ATS:NEAR, $$CTS:NEAR, $ERR_FC:NEAR
   17	 	 	 	 	
   18	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   19	 	 	 	 	
   20	 0000	 	 	 	STRNUM  PROC    FAR             ;Set up long returns as default
   21	 	 	 	 	
   22	 	 	 	 	
   23	 	 	 	 	;***  $CVI - Convert string to integer
   24	 	 	 	 	;
   25	 	 	 	 	; Inputs:
   26	 	 	 	 	;       BX = Address of string descriptor
   27	 	 	 	 	; Function:
   28	 	 	 	 	;       Make sure string is at least 2 bytes long, then put the first 2 bytes
   29	 	 	 	 	;       in BX as an integer.
   30	 	 	 	 	; Outputs:
   31	 	 	 	 	;       BX = number
   32	 	 	 	 	; Registers:
   33	 	 	 	 	;       Only BX and F affected
   34	 	 	 	 	
   35	 0000	 	 	 	$CVI:
   36	 0000  80 3F 02	 	 	        CMP     BYTE PTR[BX],2  ;Make sure string is at least 2 long
   37	 0003  72 33	 	 	        JB      ARGERR
   38	 0005  57	 	 	        PUSH    DI
   39	 0006  8B 7F 02	 	 	        MOV     DI,[BX+2]       ;Address of string data
   40	 0009  8B 3D	 	 	        MOV     DI,[DI]         ;First 2 bytes of string
   41	 000B  E8 0000 E	 	        CALL    $$DITS          ;Delete string if temp
   42	 000E  8B DF	 	 	        MOV     BX,DI           ;Put result in proper register
   43	 0010  5F	 	 	        POP     DI
   44	 0011  CB	 	 	        RET
   45	 	 	 	 	
   46	 	 	 	 	
   47	 	 	 	 	;***  $CVS and $CVD - Convert string to single or double precision number
   48	 	 	 	 	;
   49	 	 	 	 	; Inputs:
   50	 	 	 	 	;       BX = Address of string descriptor
   51	 	 	 	 	; Function:
   52	 	 	 	 	;       Convert the string to single or double precision number. Make sure
   53	 	 	 	 	;       it's long enough first.
   54	 	 	 	 	; Outputs:


STRNUM - String to number and number to string conversions Macro-86 %1(12)   1:8:56  13-Nov-81    Page 1-2



   55	 	 	 	 	;       Result number in FAC.
   56	 	 	 	 	; Registers:
   57	 	 	 	 	;       Only F affected.
   58	 	 	 	 	
   59	 0012	 	 	 	$CVS:
   60	 0012  80 3F 04	 	 	        CMP     BYTE PTR[BX],4  ;See if string is long enough
   61	 0015  72 21	 	 	        JB      ARGERR
   62	 0017  56	 	 	        PUSH    SI
   63	 0018  57	 	 	        PUSH    DI
   64	 0019  8B 77 02	 	 	        MOV     SI,[BX+2]       ;Get address of data area
   65	 001C  BF 0000 E	 	        MOV     DI,OFFSET DC:$AC
   66	 001F	 	 	 	MOVSNG:
   67	 001F  A5	 	 	        MOVSW
   68	 0020  A5	 	 	        MOVSW
   69	 0021  5F	 	 	        POP     DI
   70	 0022  5E	 	 	        POP     SI
   71	 0023  E8 0000 E	 	        CALL    $$DITS          ;Delete string if temp
   72	 0026  CB	 	 	        RET
   73	 	 	 	 	
   74	 0027	 	 	 	$CVD:
   75	 0027  80 3F 08	 	 	        CMP     BYTE PTR[BX],8  ;See if string is long enough
   76	 002A  72 0C	 	 	        JB      ARGERR
   77	 002C  56	 	 	        PUSH    SI
   78	 002D  57	 	 	        PUSH    DI
   79	 002E  8B 77 02	 	 	        MOV     SI,[BX+2]       ;Get address of string data
   80	 0031  BF 0000 E	 	        MOV     DI,OFFSET DC:$DAC
   81	 0034  A5	 	 	        MOVSW
   82	 0035  A5	 	 	        MOVSW
   83	 0036  EB E7	 	 	        JMP     MOVSNG
   84	 	 	 	 	
   85	 0038  E9 0000 E	 	ARGERR: JMP     $ERR_FC         ;Illegal function call
   86	 	 	 	 	
   87	 	 	 	 	
   88	 	 	 	 	;***  $MKI, $MKS, and $MKD - Convert number to string
   89	 	 	 	 	;
   90	 	 	 	 	; Inputs:
   91	 	 	 	 	;       BX = Integer to be converted (MKI)
   92	 	 	 	 	;       BX = Address of real number to be converted (MKS, MKD)
   93	 	 	 	 	; Function:
   94	 	 	 	 	;       Create a 2-, 4-, or 8-byte temp string and put the number in it.
   95	 	 	 	 	; Outputs:
   96	 	 	 	 	;       BX = Address of string descriptor
   97	 	 	 	 	; Registers:
   98	 	 	 	 	;       Only BX and F affected.
   99	 	 	 	 	
  100	 003B	 	 	 	$MKI:   ;Convert integer to string
  101	 003B  89 26 0000 E	 	        MOV     [$$SPSV],SP
  102	 003F  52	 	 	        PUSH    DX
  103	 0040  53	 	 	        PUSH    BX
  104	 0041  BB 0002	 	 	        MOV     BX,2            ;Create a string of length 2
  105	 0044  E8 0000 E	 	        CALL    $$ATS           ;Allocate the string
  106	 0047  87 DA	 	 	        XCHG    BX,DX           ;Get address of string data in BX
  107	 0049  8F 07	 	 	        POP     [BX]            ;Store integer into string
  108	 004B  8B DA	 	 	        MOV     BX,DX           ;Restore descriptor to BX


STRNUM - String to number and number to string conversions Macro-86 %1(12)   1:8:56  13-Nov-81    Page 1-3



  109	 004D  5A	 	 	        POP     DX
  110	 004E  CB	 	 	        RET
  111	 	 	 	 	
  112	 004F	 	 	 	$MKS:   ;Convert single precision to string
  113	 004F  89 26 0000 E	 	        MOV     [$$SPSV],SP
  114	 0053  52	 	 	        PUSH    DX
  115	 0054  BA 0004	 	 	        MOV     DX,4            ;4 Bytes in single precision number
  116	 0057	 	 	 	NUMSTR:
  117	 0057  87 DA	 	 	        XCHG    BX,DX           ;Re-order parameters for CTS
  118	 0059  E8 0000 E	 	        CALL    $$CTS           ;Allocate string and copy data in
  119	 005C  5A	 	 	        POP     DX
  120	 005D  CB	 	 	        RET
  121	 	 	 	 	
  122	 005E	 	 	 	$MKD:   ;Convert double precision to string
  123	 005E  89 26 0000 E	 	        MOV     [$$SPSV],SP
  124	 0062  52	 	 	        PUSH    DX
  125	 0063  BA 0008	 	 	        MOV     DX,8            ;8 bytes in double precision number
  126	 0066  EB EF	 	 	        JMP     NUMSTR
  127	 	 	 	 	
  128	 0068	 	 	 	STRNUM  ENDP
  129	 0068	 	 	 	CODE    ENDS
  130	 	 	 	 	        END


































STRNUM - String to number and number to string conversions Macro-86 %1(12)   1:8:56  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0068	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ARGERR . . . . . . . . . . . . .	L NEAR 	0038	CODE
MOVSNG . . . . . . . . . . . . .	L NEAR 	001F	CODE
NUMSTR . . . . . . . . . . . . .	L NEAR 	0057	CODE
STRNUM . . . . . . . . . . . . .	F PROC	0000	CODE	Length =0068
$$ATS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$CTS. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$DITS . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$AC. . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$CVD . . . . . . . . . . . . . .	L NEAR 	0027	CODE	Global
$CVI . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$CVS . . . . . . . . . . . . . .	L NEAR 	0012	CODE	Global
$DAC . . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ERR_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$MKD . . . . . . . . . . . . . .	L NEAR 	005E	CODE	Global
$MKI . . . . . . . . . . . . . .	L NEAR 	003B	CODE	Global
$MKS . . . . . . . . . . . . . .	L NEAR 	004F	CODE	Global

Warning Severe
Errors	Errors 
0	0























