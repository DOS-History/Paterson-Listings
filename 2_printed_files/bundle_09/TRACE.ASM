TRACE - 8086 Basic Compiler Debug and Trace Routines     Macro-86 %1(12)   1:9:29  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   TRACE - 8086 Basic Compiler Debug and Trace Routines
    2	 	 	 	 	
    3	 	 	 	 	;       Debug trace routines for use with the /D switch in the compiler.
    4	 	 	 	 	
    5	 	 	 	 	.list
    6	 	 	 	 	
    7	 	 	 	 	
    8	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    9	 	 	 	 	
   10	 	 	 	 	        EXTRN   $TRACE_SW:BYTE          ;Trace switch
   11	 	 	 	 	
   12	 	 	 	 	;if      _IBM_
   13	 	 	 	 	;        EXTRN   $CTRL_BRK:BYTE
   14	 	 	 	 	;endif
   15	 	 	 	 	
   16	 0000  ????	 	 	SAVELOC         DW      ?               ;Save location
   17	 	 	 	 	
   18	 0002  ??	 	 	EL_SIZE         DB      ?               ;Array element size
   19	 0003  ??	 	 	NUM_DIM         DB      ?               ;2 * number of dimensions
   20	 	 	 	 	
   21	 0004  ??	 	 	SUBERR          DB      ?               ;Subscript error flag
   22	 	 	 	 	
   23	 0005	 	 	 	DATA     ENDS
   24	 	 	 	 	
   25	 	 	 	 	DC       GROUP  DATA
   26	 	 	 	 	
   27	 	 	 	 	
   28	 0000	 	 	 	CODE     SEGMENT BYTE PUBLIC 'CODE'
   29	 	 	 	 	
   30	 	 	 	 	         ASSUME  CS:CODE, DS:DC, ES:DC
   31	 	 	 	 	
   32	 	 	 	 	         PUBLIC  $AELA,$LINA,$TRN,$TRF
   33	 	 	 	 	
   34	 	 	 	 	         EXTRN   $STP:NEAR,$$WCHT:NEAR
   35	 	 	 	 	         EXTRN   $ERR_BS:NEAR
   36	 	 	 	 	         EXTRN   $$FSFA:NEAR,$TYPUI:NEAR
   37	 	 	 	 	
   38	 	 	 	 	;if       _IBM_ eq 0
   39	 	 	 	 	         EXTRN   $TTYIN:NEAR, $TTYST:NEAR
   40	 	 	 	 	;endif
   41	 	 	 	 	
   42	 0000	 	 	 	Entries  PROC    FAR
   43	 	 	 	 	
   44	 	 	 	 	
   45	 	 	 	 	;**      $AELA - Array subscript bounds check
   46	 	 	 	 	;
   47	 	 	 	 	;        This routine computes a byte index into an array.  The subscripts
   48	 	 	 	 	;        are checked against the array bounds.
   49	 	 	 	 	;
   50	 	 	 	 	;        The subscripts are on the stack as follows:
   51	 	 	 	 	;
   52	 	 	 	 	;                ((SP)+4) = 1st subscript
   53	 	 	 	 	;                ...
   54	 	 	 	 	;                ((SP)+2*n+2) = nth subscript


TRACE - 8086 Basic Compiler Debug and Trace Routines     Macro-86 %1(12)   1:9:29  13-Nov-81    Page 1-2



   55	 	 	 	 	;
   56	 	 	 	 	;        The calling sequence is as follows:
   57	 	 	 	 	;
   58	 	 	 	 	;                CALL    $AELA
   59	 	 	 	 	;                DB      element size            (2, 4, or 8)
   60	 	 	 	 	;                DB      2 * #dimensions
   61	 	 	 	 	;                DW      1st limit
   62	 	 	 	 	;                ...
   63	 	 	 	 	;                DW      nth limit
   64	 	 	 	 	;
   65	 	 	 	 	;        ENTRY   ((SP)) = return offset
   66	 	 	 	 	;                ((SP)+2) = return segment
   67	 	 	 	 	;                ((SP)+4) = 1st subscript
   68	 	 	 	 	;                ((SP)+2*n+2) = nth subscript
   69	 	 	 	 	;        EXIT    (AX) = byte index to element from array base
   70	 	 	 	 	;        USES    AX,CX,SI
   71	 	 	 	 	
   72	 0000  89 16 0000 R	 	$AELA:   MOV     [SAVELOC],DX            ;Save (DX)
   73	 	 	 	 	
   74	 	 	 	 	ASSUME   ES:NOTHING
   75	 	 	 	 	
   76	 0004  5E	 	 	         POP     SI                      ;(SI) = return offset (start of list)
   77	 0005  07	 	 	         POP     ES                      ;(ES) = user code segment
   78	 	 	 	 	
   79	 0006  26: AD	 	 	         LODS    WORD PTR ES:[SI]        ;(AH,AL) = (2*dimensions,element size)
   80	 0008  A3 0002 R	 	         MOV     WORD PTR [EL_SIZE],AX   ;Save it for later
   81	 	 	 	 	
   82	 000B  33 C9	 	 	         XOR     CX,CX                   ;(CX) = Accum for byte index
   83	 000D  88 0E 0004 R	 	         MOV     [SUBERR],CL             ;Clear subscript error flag
   84	 	 	 	 	
   85	 	 	 	 	;        For each subscript:
   86	 	 	 	 	;
   87	 	 	 	 	;        1.      Compare Subscript against Limit
   88	 	 	 	 	;                If out of range, then bad subscript error
   89	 	 	 	 	;        2.      Accum = Accum * Limit + Subscript
   90	 	 	 	 	
   91	 0011  26: AD	 	 	AEL1:    LODS    WORD PTR ES:[SI]        ;(AX) = Limit
   92	 0013  5A	 	 	         POP     DX                      ;(DX) = Subscript
   93	 0014  3B C2	 	 	         CMP     AX,DX                   ;Limit : Subscript
   94	 0016  77 07	 	 	         JA      ael2                    ;  In range - Subscript must be less
   95	 	 	 	 	
   96	 0018  C6 06 0004 R 01	 	         MOV     [SUBERR],1              ;Set subscript error flag
   97	 001D  EB 06	 	 	         JMP     SHORT ael3              ;Skip arithmetic for this subscript
   98	 	 	 	 	
   99	 001F  52	 	 	ael2:    PUSH    DX                      ;Save Subscript during multiply
  100	 0020  F7 E1	 	 	         MUL     CX                      ;(AX) = Limit * Old Accum
  101	 0022  59	 	 	         POP     CX                      ;(CX) = Subscript
  102	 0023  03 C8	 	 	         ADD     CX,AX                   ;(CX) = Subscript + Limit * Old Accum
  103	 	 	 	 	
  104	 0025  80 2E 0003 R 02	 	ael3:    SUB     [NUM_DIM],2             ;Count off 1 dimension
  105	 002A  75 E5	 	 	         JNZ     AEL1                    ;  Keep on looping
  106	 	 	 	 	
  107	 002C  91	 	 	         XCHG    AX,CX                   ;(AX) = Accum
  108	 002D  F7 26 0002 R	 	         MUL     WORD PTR [EL_SIZE]      ;(AX) = byte index (NUM_DIM = 0 !!!)


TRACE - 8086 Basic Compiler Debug and Trace Routines     Macro-86 %1(12)   1:9:29  13-Nov-81    Page 1-3



  109	 	 	 	 	
  110	 0031  06	 	 	         PUSH    ES                      ;Save return segment
  111	 0032  56	 	 	         PUSH    SI                      ;  and new offset past array bounds
  112	 	 	 	 	
  113	 0033  1E	 	 	         PUSH    DS                      ;Restore ES
  114	 0034  07	 	 	         POP     ES
  115	 	 	 	 	
  116	 	 	 	 	ASSUME   ES:DC
  117	 	 	 	 	
  118	 0035  8B 16 0000 R	 	         MOV     DX,[SAVELOC]            ;Restore (DX)
  119	 0039  80 3E 0004 R 00	 	         CMP     [SUBERR],0              ;Test for bad subscript
  120	 003E  75 01	 	 	         JNZ     errbs
  121	 	 	 	 	
  122	 0040  CB	 	 	         RET                             ;Return with (AX)
  123	 	 	 	 	
  124	 0041  E9 0000 E	 	errbs:   JMP     $ERR_BS                 ;Bad subscript
  125	 	 	 	 	







































TRACE - 8086 Basic Compiler Debug and Trace Routines     Macro-86 %1(12)   1:9:29  13-Nov-81    Page 1-4



  126	 	 	 	 	         PAGE
  127	 	 	 	 	
  128	 	 	 	 	;**      $LINA - Print trace message
  129	 	 	 	 	
  130	 0044	 	 	 	$LINA:
  131	 	 	 	 	if       _IBM_
  132	 	 	 	 	         CMP     $CTRL_BRK,0             ;Check for control-BREAK
  133	 	 	 	 	         JE      lina1                   ;No
  134	 	 	 	 	         JMP     $STP                    ;Yes - exit
  135	 	 	 	 	lina1:
  136	 	 	 	 	else
  137	 0044  50	 	 	         PUSH    AX
  138	 0045  E8 0000 E	 	         CALL    $TTYST                  ;Check for pending character
  139	 0048  74 0B	 	 	         JZ      lina1                   ;No
  140	 004A  E8 0000 E	 	         CALL    $TTYIN                  ;Read character
  141	 004D  3C 03	 	 	         CMP     AL,3                    ;Is it control-C ?
  142	 004F  58	 	 	         POP     AX
  143	 0050  75 04	 	 	         JNZ     lina2                   ;No
  144	 0052  E9 0000 E	 	         JMP     $STP                    ;Yes - exit
  145	 0055  58	 	 	lina1:   POP     AX
  146	 0056	 	 	 	LINA2:
  147	 	 	 	 	endif
  148	 0056  80 3E 0000 E 00	 	         CMP     $TRACE_SW,0             ;Check if trace is active
  149	 005B  74 1D	 	 	         JE      linret                  ;No
  150	 	 	 	 	
  151	 005D  8F 06 0000 R	 	         POP     [SAVELOC]               ;Save offset
  152	 0061  50	 	 	         PUSH    AX                      ;Save (AX)
  153	 0062  B0 5B	 	 	         MOV     AL,'['
  154	 0064  E8 0000 E	 	         CALL    $$WCHT                  ;Output [
  155	 0067  A1 0000 R	 	         MOV     AX,[SAVELOC]            ;(AX) = return offset
  156	 006A  E8 0000 E	 	         CALL    $$FSFA                  ;Find statement number from address
  157	 006D  E8 0000 E	 	         CALL    $TYPUI                  ;Type line number in (AX)
  158	 0070  B0 5D	 	 	         MOV     AL,']'
  159	 0072  E8 0000 E	 	         CALL    $$WCHT                  ;Output ]
  160	 0075  58	 	 	         POP     AX
  161	 0076  FF 36 0000 R	 	         PUSH    [SAVELOC]               ;Restore return offset
  162	 	 	 	 	
  163	 007A  CB	 	 	linret:  RET
  164	 	 	 	 	
  165	 	 	 	 	
  166	 	 	 	 	;**      $TRN/$TRF - Set and clear trace flag
  167	 	 	 	 	
  168	 007B  C6 06 0000 E 01	 	$TRN:    MOV     $TRACE_SW,1
  169	 0080  CB	 	 	         RET
  170	 	 	 	 	
  171	 0081  C6 06 0000 E 00	 	$TRF:    MOV     $TRACE_SW,0
  172	 0086  CB	 	 	         RET
  173	 	 	 	 	
  174	 	 	 	 	
  175	 0087	 	 	 	Entries  ENDP
  176	 	 	 	 	
  177	 0087	 	 	 	CODE     ENDS
  178	 	 	 	 	
  179	 	 	 	 	         END
