ERROR - Error trapping for 8086 Basic Compiler           Macro-86 %1(12)   1:0:48  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   ERROR - Error trapping for 8086 Basic Compiler
    2	 	 	 	 	
    3	 	 	 	 	
    4	 	 	 	 	;       This module contains the run-time support for error trapping
    5	 	 	 	 	;       in addition to the routines in GOSTOP.
    6	 	 	 	 	
    7	 	 	 	 	
    8	                             C	        INCLUDE ADDR.INC
    9	 = 0000                      C	O_STA           EQU     0               ;Statement address/number table
   10	 = 0002                      C	STARTDATA       EQU     2               ;Start of data statements
   11	 = 0006                      C	O_RAM           EQU     6               ;Start of user RAM
   12	 = 000C                      C	O_RAL           EQU     0CH             ;End of user RAM + 1
   13	 	 	 	 	
   14	 	 	 	 	
   15	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
   16	 	 	 	 	
   17	 	 	 	 	        EXTRN   $$AOER:WORD, $$OEIP:BYTE
   18	 	 	 	 	        EXTRN   $ERRADR:WORD,$ERRNUM:WORD,$ERRLIN:WORD
   19	 	 	 	 	        EXTRN   $MAINBASE:WORD
   20	 	 	 	 	
   21	 0000	 	 	 	DATA    ENDS
   22	 	 	 	 	
   23	 	 	 	 	DC      GROUP   DATA
   24	 	 	 	 	
   25	 	 	 	 	
   26	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   27	 	 	 	 	
   28	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
   29	 	 	 	 	
   30	 	 	 	 	        PUBLIC  $RESA,$RSN,$RS0
   31	 	 	 	 	        PUBLIC  $OEGA,$ON0
   32	 	 	 	 	        PUBLIC  $ERL,$ERN
   33	 	 	 	 	
   34	 	 	 	 	        EXTRN   $ERR_RE:NEAR
   35	 	 	 	 	        EXTRN   $$FSFA:NEAR, $FOE:NEAR, $FSERR:NEAR, $GETAD:NEAR
   36	 	 	 	 	        EXTRN   $SNORM:NEAR
   37	 	 	 	 	
   38	 	 	 	 	
   39	 0000	 	 	 	Entries PROC    FAR
   40	 	 	 	 	
   41	 	 	 	 	
   42	 	 	 	 	;**     $OEGA - ON ERROR GOTO line number
   43	 	 	 	 	;
   44	 	 	 	 	;       ENTRY   (BX) = line number address
   45	 	 	 	 	
   46	 0000  89 1E 0000 E	 	$OEGA:  MOV     [$$AOER],BX             ;Set error vector
   47	 0004  CB	 	 	onret:  RET
   48	 	 	 	 	
   49	 	 	 	 	
   50	 	 	 	 	;**     $ON0 - ON ERROR GOTO 0
   51	 	 	 	 	;
   52	 	 	 	 	;       ENTRY   none
   53	 	 	 	 	
   54	 0005  C7 06 0000 E 0000	$ON0:   MOV     [$$AOER],0              ;Clear error vector


ERROR - Error trapping for 8086 Basic Compiler           Macro-86 %1(12)   1:0:48  13-Nov-81    Page 1-2



   55	 000B  80 3E 0000 E 00	 	        CMP     [$$OEIP],0              ;Test if error in progress
   56	 0010  74 F2	 	 	        JE      onret                   ;  No - just return
   57	 	 	 	 	
   58	 	 	 	 	;       In error handling routine, must pretend we just had last error
   59	 	 	 	 	
   60	 0012  5B	 	 	        POP     BX                      ;Toss $ON0 return offset
   61	 0013  FF 36 0000 E	 	        PUSH    [$ERRADR]               ;Use error offset as return address
   62	 0017  8B 1E 0000 E	 	        MOV     BX,[$ERRNUM]            ;Get error number
   63	 001B  E9 0000 E	 	        JMP     $FOE                    ;Process error
   64	 	 	 	 	
   65	 	 	 	 	
   66	 	 	 	 	;**     $RESA - RESUME line number
   67	 	 	 	 	;
   68	 	 	 	 	;       ENTRY   (BX) = line number address
   69	 	 	 	 	
   70	 001E  80 3E 0000 E 00	 	$RESA:  CMP     [$$OEIP],0              ;Test if error is in progress
   71	 0023  74 08	 	 	        JE      errre                   ;  No - RESUME without error
   72	 	 	 	 	
   73	 0025  C6 06 0000 E 00	 	        MOV     [$$OEIP],0              ;Clear error in progress flag
   74	 002A  58	 	 	        POP     AX                      ;Throw away return offset
   75	 002B  53	 	 	        PUSH    BX                      ;Save line number as offset
   76	 002C  CB	 	 	rsnret: RET                             ;Return to specified line number
   77	 	 	 	 	
   78	 002D  E9 0000 E	 	errre:  JMP     $ERR_RE                 ;Give error
   79	 	 	 	 	
   80	 	 	 	 	
   81	 	 	 	 	;**     $RS0 - RESUME [0]
   82	 	 	 	 	;
   83	 	 	 	 	;       ENTRY   none
   84	 	 	 	 	
   85	 0030  80 3E 0000 E 00	 	$RS0:   CMP     [$$OEIP],0              ;Test if error is in progress
   86	 0035  74 F6	 	 	        JE      errre                   ;  No - RESUME without error
   87	 	 	 	 	
   88	 0037  C6 06 0000 E 00	 	        MOV     [$$OEIP],0              ;Clear error in progress flag
   89	 003C  58	 	 	        POP     AX                      ;Toss return offset
   90	 003D  A1 0000 E	 	        MOV     AX,[$ERRADR]            ;Get error address
   91	 0040  E8 0000 E	 	        CALL    $$FSFA                  ;(BX) = address of start of statement
   92	 0043  53	 	 	        PUSH    BX                      ;Save as offset
   93	 0044  CB	 	 	        RET                             ;Return to start of statement
   94	 	 	 	 	
   95	 	 	 	 	
   96	 	 	 	 	;**     $RSN - RESUME NEXT
   97	 	 	 	 	;
   98	 	 	 	 	;       ENTRY   none
   99	 	 	 	 	
  100	 0045  80 3E 0000 E 00	 	$RSN:   CMP     [$$OEIP],0              ;Test if error is in progress
  101	 004A  74 E1	 	 	        JE      errre                   ;  No - RESUME without error
  102	 	 	 	 	
  103	 004C  C6 06 0000 E 00	 	        MOV     [$$OEIP],0              ;Clear errr in progress flag
  104	 0051  8B 0E 0000 E	 	        MOV     CX,[$ERRADR]            ;Get return offset
  105	 0055  E8 0000 E	 	        CALL    $GETAD                  ;Get statement number address table
  106	 0058  00	 	 	        DB      O_STA
  107	 0059  96	 	 	        XCHG    AX,SI
  108	 005A  8E 1E 0002 E	 	        MOV     DS,[$MAINBASE+2]        ;Get main program CS


ERROR - Error trapping for 8086 Basic Compiler           Macro-86 %1(12)   1:0:48  13-Nov-81    Page 1-3



  109	 005E  BB FFFF	 	 	        MOV     BX,-1                   ;Start out with maximum address
  110	 	 	 	 	
  111	 0061  AD	 	 	rsnlop: LODSW                           ;(AX) = next address to check
  112	 0062  0B C0	 	 	        OR      AX,AX                   ;Check if end of table
  113	 0064  74 0D	 	 	        JZ      rsnend                  ;  Yes
  114	 	 	 	 	
  115	 0066  3B C1	 	 	        CMP     AX,CX                   ;Are we less than original address
  116	 0068  72 05	 	 	        JB      rsnnxt                  ;  Yes - skip this one
  117	 006A  3B C3	 	 	        CMP     AX,BX                   ;Are we less than current closest
  118	 006C  73 01	 	 	        JAE     rsnnxt                  ;  No - skip this one
  119	 	 	 	 	
  120	 006E  93	 	 	        XCHG    AX,BX                   ;Save address in (BX) as new closest
  121	 	 	 	 	
  122	 006F  46	 	 	rsnnxt: INC     SI                      ;Skip line number entry
  123	 0070  46	 	 	        INC     SI
  124	 0071  EB EE	 	 	        JMP     rsnlop                  ;Keep looping
  125	 	 	 	 	
  126	 0073  06	 	 	rsnend: PUSH    ES                      ;Restore DS
  127	 0074  1F	 	 	        POP     DS
  128	 0075  58	 	 	        POP     AX                      ;Toss RESUME NEXT return offset
  129	 0076  53	 	 	        PUSH    BX                      ;Save address for return
  130	 0077  43	 	 	        INC     BX                      ;Bump by 1 to map -1 to 0 (maybe)
  131	 0078  75 B2	 	 	        JNZ     rsnret                  ;  Not 0 - return to user program
  132	 007A  E9 0000 E	 	        JMP     $FSERR                  ;Error - no line number found
  133	 	 	 	 	
  134	 	 	 	 	
  135	 	 	 	 	
  136	 	 	 	 	;**     $ERN - ERR function
  137	 	 	 	 	;
  138	 	 	 	 	;       EXIT    (BX) = error number
  139	 	 	 	 	
  140	 007D  8B 1E 0000 E	 	$ERN:   MOV     BX,[$ERRNUM]            ;Get error number
  141	 0081  CB	 	 	        RET
  142	 	 	 	 	
  143	 	 	 	 	
  144	 	 	 	 	;**     $ERL - ERL function
  145	 	 	 	 	;
  146	 	 	 	 	;       EXIT    (FAC) = error line number
  147	 	 	 	 	
  148	 0082  50	 	 	$ERL:   PUSH    AX
  149	 0083  52	 	 	        PUSH    DX
  150	 0084  53	 	 	        PUSH    BX
  151	 0085  B8 9000	 	 	        MOV     AX,(128+16)*100H        ;(AX) = (exponent,sign)
  152	 0088  33 D2	 	 	        XOR     DX,DX
  153	 008A  8B 1E 0000 E	 	        MOV     BX,[$ERRLIN]            ;(BX,DX) = (line number,0)
  154	 008E  E8 0000 E	 	        CALL    $SNORM                  ;Normalize it into $AC
  155	 0091  5B	 	 	        POP     BX
  156	 0092  5A	 	 	        POP     DX
  157	 0093  58	 	 	        POP     AX
  158	 0094  CB	 	 	        RET
  159	 	 	 	 	
  160	 	 	 	 	
  161	 0095	 	 	 	Entries ENDP
  162	 	 	 	 	


ERROR - Error trapping for 8086 Basic Compiler           Macro-86 %1(12)   1:0:48  13-Nov-81    Page 1-4



  163	 0095	 	 	 	CODE    ENDS
  164	 	 	 	 	
  165	 	 	 	 	        END





















































ERROR - Error trapping for 8086 Basic Compiler           Macro-86 %1(12)   1:0:48  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0095	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0000	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ENTRIES. . . . . . . . . . . . .	F PROC	0000	CODE	Length =0095
ERRRE. . . . . . . . . . . . . .	L NEAR 	002D	CODE
ONRET. . . . . . . . . . . . . .	L NEAR 	0004	CODE
O_RAL. . . . . . . . . . . . . .	Number	000C	
O_RAM. . . . . . . . . . . . . .	Number	0006	
O_STA. . . . . . . . . . . . . .	Number	0000	
RSNEND . . . . . . . . . . . . .	L NEAR 	0073	CODE
RSNLOP . . . . . . . . . . . . .	L NEAR 	0061	CODE
RSNNXT . . . . . . . . . . . . .	L NEAR 	006F	CODE
RSNRET . . . . . . . . . . . . .	L NEAR 	002C	CODE
STARTDATA. . . . . . . . . . . .	Number	0002	
$$AOER . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$FSFA . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$OEIP . . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$ERL . . . . . . . . . . . . . .	L NEAR 	0082	CODE	Global
$ERN . . . . . . . . . . . . . .	L NEAR 	007D	CODE	Global
$ERRADR. . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ERRLIN. . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ERRNUM. . . . . . . . . . . . .	V WORD 	0000	DATA	External
$ERR_RE. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FOE . . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FSERR . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$GETAD . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$MAINBASE. . . . . . . . . . . .	V WORD 	0000	DATA	External
$OEGA. . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$ON0 . . . . . . . . . . . . . .	L NEAR 	0005	CODE	Global
$RESA. . . . . . . . . . . . . .	L NEAR 	001E	CODE	Global
$RS0 . . . . . . . . . . . . . .	L NEAR 	0030	CODE	Global
$RSN . . . . . . . . . . . . . .	L NEAR 	0045	CODE	Global
$SNORM . . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0










