SSQRT - Single precision square root                     Macro-86 %1(12)   1:8:28  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   SSQRT - Single precision square root
    2	 	 	 	 	
    3	 	 	 	 	; by Tim Paterson  7/17/81
    4	 	 	 	 	
    5	 	 	 	 	; The algorithm used here is several times faster than Netwon-Raphson
    6	 	 	 	 	; iteration. The only references I know of this algorithm are in the context
    7	 	 	 	 	; of hardware implementation, and do not discuss how it works. It is used,
    8	 	 	 	 	; for example, in the Intel 8087 math processor, which is why that chip
    9	 	 	 	 	; can square root faster than it divides.
   10	 	 	 	 	
   11	 	 	 	 	; The algorithm is similar to restoring division. The input argument would
   12	 	 	 	 	; be the dividend. A "guess" is made of a divisor bit, and if the corresponding
   13	 	 	 	 	; quotient bit is the same, the guess is correct. The divisor and quotient are
   14	 	 	 	 	; thus determined simultaneously, bit by bit. Since they are kept equal, they
   15	 	 	 	 	; represent the square root of the dividend.
   16	 	 	 	 	;
   17	 	 	 	 	; The trick is that when changes are made to the divisor, the present remainder
   18	 	 	 	 	; must be corrected as if the divisor had always had that value. Because we
   19	 	 	 	 	; are using binary numbers, this correction turns out to be very simple.
   20	 	 	 	 	
   21	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
   22	 	 	 	 	
   23	 	 	 	 	        EXTRN   $FAC:BYTE, $AC:BYTE
   24	 	 	 	 	
   25	 0000	 	 	 	DATA    ENDS
   26	 	 	 	 	
   27	 	 	 	 	DC      GROUP   DATA
   28	 	 	 	 	
   29	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   30	 	 	 	 	
   31	 	 	 	 	        PUBLIC  $SQR,$SSQRT
   32	 	 	 	 	
   33	 	 	 	 	        EXTRN   $ERC_FC:NEAR,$SAVREG:NEAR
   34	 	 	 	 	
   35	 	 	 	 	        ASSUME  CS:CODE, DS:DC
   36	 	 	 	 	
   37	 	 	 	 	
   38	 	 	 	 	;***  $SQR - Single precision square root
   39	 	 	 	 	;
   40	 	 	 	 	; Inputs:
   41	 	 	 	 	;       BX = Address of argument
   42	 	 	 	 	; Outputs:
   43	 	 	 	 	;       Result in the FAC
   44	 	 	 	 	; Registers:
   45	 	 	 	 	;       Only F affected
   46	 	 	 	 	
   47	 0000	 	 	 	$SQR:
   48	 0000  E8 0000 E	 	        CALL    $SAVREG
   49	 0003	 	 	 	$SSQRT:
   50	 0003  8B 57 01	 	 	        MOV     DX,[BX+1]       ;Get sign & high 15 mantissa bits
   51	 0006  0A F6	 	 	        OR      DH,DH           ;Test sign bit
   52	 0008  78 61	 	 	        JS      NEGNUM          ;No negative numbers
   53	 000A  8A 47 03	 	 	        MOV     AL,[BX+3]       ;Get exponent
   54	 000D  0A C0	 	 	        OR      AL,AL           ;Test for zero


SSQRT - Single precision square root                     Macro-86 %1(12)   1:8:28  13-Nov-81    Page 1-2



   55	 000F  74 5D	 	 	        JZ      ZERO            ;SQR(0)=0
   56	 0011  8A 3F	 	 	        MOV     BH,[BX]         ;Get low mantissa byte
   57	 0013  B3 00	 	 	        MOV     BL,0            ;Extend to 32 bits
   58	 0015  80 CE 80	 	 	        OR      DH,80H          ;Set implied bit
   59	 0018  D0 E8	 	 	        SHR     AL,1            ;Divide exponent by two
   60	 001A  73 05	 	 	        JNC     EVENEXP         ;Exponent odd?
   61	 001C  D1 EA	 	 	        SHR     DX,1            ;Half mantissa if exponent odd
   62	 001E  D1 DB	 	 	        RCR     BX,1
   63	 0020  F9	 	 	        STC                     ;Round up exponent
   64	 0021	 	 	 	EVENEXP:
   65	 0021  14 40	 	 	        ADC     AL,64           ;Add back half the bias
   66	 0023  A2 0000 E	 	        MOV     [$FAC],AL       ;Save final exponent
   67	 0026  B9 0019	 	 	        MOV     CX,25           ;24 bits plus one for rounding
   68	 0029  33 ED	 	 	        XOR     BP,BP           ;Clear registers
   69	 002B  8B F5	 	 	        MOV     SI,BP
   70	 002D  8B FD	 	 	        MOV     DI,BP
   71	 002F  8B C5	 	 	        MOV     AX,BP
   72	 0031	 	 	 	ROOTLP:
   73	 0031  D1 E3	 	 	        SHL     BX,1            ;64-bit left shift of input
   74	 0033  D1 D2	 	 	        RCL     DX,1
   75	 0035  D1 D7	 	 	        RCL     DI,1
   76	 0037  D1 D5	 	 	        RCL     BP,1
   77	 0039  D1 E3	 	 	        SHL     BX,1            ;Shift it twice
   78	 003B  D1 D2	 	 	        RCL     DX,1
   79	 003D  D1 D7	 	 	        RCL     DI,1
   80	 003F  D1 D5	 	 	        RCL     BP,1
   81	 0041  F9	 	 	        STC                     ;Set test bit
   82	 0042  D1 D6	 	 	        RCL     SI,1            ;Rotate it in to partial
   83	 0044  D1 D0	 	 	        RCL     AX,1
   84	 0046  2B FE	 	 	        SUB     DI,SI           ;See if test bit fits
   85	 0048  1B E8	 	 	        SBB     BP,AX
   86	 004A  73 28	 	 	        JNC     ROOTBIT
   87	 004C  03 FE	 	 	        ADD     DI,SI           ;Didn't fit - restore
   88	 004E  13 E8	 	 	        ADC     BP,AX
   89	 0050  4E	 	 	        DEC     SI              ;Reset test bit
   90	 0051  E2 DE	 	 	        LOOP    ROOTLP
   91	 0053	 	 	 	ROUND:
   92	 0053  D1 E8	 	 	        SHR     AX,1            ;Half to a 25-bit result
   93	 0055  D1 DE	 	 	        RCR     SI,1
   94	 0057  D1 E8	 	 	        SHR     AX,1            ;To a 24-bit result
   95	 0059  D1 DE	 	 	        RCR     SI,1
   96	 005B  83 D6 00	 	 	        ADC     SI,0            ;Round up if a 1 was shifted out
   97	 005E  15 0000	 	 	        ADC     AX,0            ;Propagate carry
   98	 0061  89 36 FFFD E	 	        MOV     WORD PTR[$FAC-3],SI
   99	 0065  24 7F	 	 	        AND     AL,7FH          ;Reset implied bit
  100	 0067  A2 FFFF E	 	        MOV     [$FAC-1],AL
  101	 006A  C3	 	 	DONE:   RET
  102	 	 	 	 	
  103	 006B  E9 0000 E	 	NEGNUM: JMP     $ERC_FC         ;Illegal function call if negative argument
  104	 	 	 	 	
  105	 006E  C6 06 0000 E 00	 	ZERO:   MOV     [$FAC],0
  106	 0073  C3	 	 	        RET
  107	 	 	 	 	
  108	 0074	 	 	 	ROOTBIT:


SSQRT - Single precision square root                     Macro-86 %1(12)   1:8:28  13-Nov-81    Page 1-3



  109	 0074  46	 	 	        INC     SI              ;Set real result bit
  110	 0075  E2 BA	 	 	        LOOP    ROOTLP
  111	 0077  EB DA	 	 	        JMP     ROUND
  112	 	 	 	 	
  113	 0079	 	 	 	CODE    ENDS
  114	 	 	 	 	        END


















































SSQRT - Single precision square root                     Macro-86 %1(12)   1:8:28  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0079	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

DONE . . . . . . . . . . . . . .	L NEAR 	006A	CODE
EVENEXP. . . . . . . . . . . . .	L NEAR 	0021	CODE
NEGNUM . . . . . . . . . . . . .	L NEAR 	006B	CODE
ROOTBIT. . . . . . . . . . . . .	L NEAR 	0074	CODE
ROOTLP . . . . . . . . . . . . .	L NEAR 	0031	CODE
ROUND. . . . . . . . . . . . . .	L NEAR 	0053	CODE
ZERO . . . . . . . . . . . . . .	L NEAR 	006E	CODE
$AC. . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FAC . . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SQR . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$SSQRT . . . . . . . . . . . . .	L NEAR 	0003	CODE	Global

Warning Severe
Errors	Errors 
0	0



























