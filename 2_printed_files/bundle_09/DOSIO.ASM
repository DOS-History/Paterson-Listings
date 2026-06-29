DOSIO - Basic I/O and initialization for 86-DOS and IBM  Macro-86 %1(12)   1:0:27  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   DOSIO - Basic I/O and initialization for 86-DOS and IBM
    2	 	 	 	 	
    3	 = 0200	 	 	 	STKSIZ  EQU     200H
    4	 	 	 	 	
    5	                             C	        INCLUDE INTMAC.INC
    6	                             C	;       8086 Interrupt Handling Macros
    7	                             C	
    8	                             C	
    9	                             C	SAVINT  MACRO   savloc,intloc,reg
   10	                             C	IFB     <reg>
   11	                             C	        SAVINT  savloc,intloc,AX
   12	                             C	ELSE
   13	                             C	        MOV     reg,intloc
   14	                             C	        MOV     savloc,reg
   15	                             C	        MOV     reg,intloc+2
   16	                             C	        MOV     savloc+2,reg
   17	                             C	ENDIF
   18	                             C	        ENDM
   19	                             C	
   20	                             C	RSTINT  MACRO   savloc,intloc,reg
   21	                             C	IFB     <reg>
   22	                             C	        SAVINT  savloc,intloc,AX
   23	                             C	ELSE
   24	                             C	        MOV     reg,intloc
   25	                             C	        MOV     savloc,reg
   26	                             C	        MOV     reg,intloc+2
   27	                             C	        MOV     savloc+2,reg
   28	                             C	ENDIF
   29	                             C	        ENDM
   30	                             C	
   31	                             C	MOVINT  MACRO   savloc,intloc,reg
   32	                             C	IFB     <reg>
   33	                             C	        SAVINT  savloc,intloc,AX
   34	                             C	ELSE
   35	                             C	        MOV     reg,intloc
   36	                             C	        MOV     savloc,reg
   37	                             C	        MOV     reg,intloc+2
   38	                             C	        MOV     savloc+2,reg
   39	                             C	ENDIF
   40	                             C	        ENDM
   41	                             C	
   42	                             C	SETINT  MACRO   intloc,loc
   43	                             C	        MOV     word ptr intloc,offset loc
   44	                             C	        MOV     word ptr intloc+2,CS
   45	                             C	        ENDM
   46	                             C	










DOSIO - Basic I/O and initialization for 86-DOS and IBM  Macro-86 %1(12)   1:0:27  13-Nov-81    Page 1-2



   47	                             C	        PAGE























































DOSIO - Basic I/O and initialization for 86-DOS and IBM  Macro-86 %1(12)   1:0:27  13-Nov-81    Page 1-3



   48	 	 	 	 	.list
   49	 	 	 	 	
   50	 =	 	 	 	DISABLE         EQU     CLI
   51	 =	 	 	 	ENABLE          EQU     STI
   52	 	 	 	 	
   53	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC'DATA'
   54	 	 	 	 	
   55	 	 	 	 	        EXTRN   $$SFWA:WORD, $$SLWA:WORD, $PTRFIL:WORD
   56	 	 	 	 	
   57	 0000     02 [	 	 	DIV0_SAVE       DW      2 DUP (?)
   58	                ????	 	
   59	                      ]	 	
   60	 	 	 	 	
   61	 0004     02 [	 	 	OVRF_SAVE       DW      2 DUP (?)
   62	                ????	 	
   63	                      ]	 	
   64	 	 	 	 	
   65	 0008     02 [	 	 	DSKE_SAVE       DW      2 DUP (?)      ;Disk Error Interrupt save
   66	                ????	 	
   67	                      ]	 	
   68	 	 	 	 	
   69	 	 	 	 	
   70	 000C	 	 	 	DATA    ENDS
   71	 	 	 	 	
   72	 	 	 	 	
   73	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
   74	 	 	 	 	
   75	 	 	 	 	        PUBLIC  $TTYWID,$TTYPOS,$EXITSEG
   76	 	 	 	 	
   77	 0000  0000	 	 	EXIT    DW      0
   78	 0002  0000	 	 	$EXITSEG        DW      0
   79	 	 	 	 	
   80	 0004  50	 	 	$TTYWID DB      80
   81	 0005  00	 	 	$TTYPOS DB      0
   82	 	 	 	 	
   83	 0006	 	 	 	CONST   ENDS
   84	 	 	 	 	
   85	 	 	 	 	
   86	 0000	 	 	 	MEMORY  SEGMENT WORD 'MEMORY'
   87	 	 	 	 	
   88	 0000	 	 	 	MEMRY   LABEL   BYTE
   89	 	 	 	 	
   90	 0000	 	 	 	MEMORY  ENDS
   91	 	 	 	 	
   92	 	 	 	 	
   93	 0000	 	 	 	STACK   SEGMENT WORD STACK 'STACK'
   94	 0000  0100 [	 	 	        DW      100H DUP(?)
   95	                ????	 	
   96	                      ]	 	
   97	 	 	 	 	
   98	 0200	 	 	 	STACK   ENDS
   99	 	 	 	 	
  100	 	 	 	 	
  101	 	 	 	 	DC      GROUP   CONST,DATA,MEMORY


DOSIO - Basic I/O and initialization for 86-DOS and IBM  Macro-86 %1(12)   1:0:27  13-Nov-81    Page 1-4



  102	 	 	 	 	
  103	 = 000B	 	 	 	STATUS  EQU     11
  104	 = 0008	 	 	 	INCHAR  EQU     8
  105	 = 0002	 	 	 	OUTCH   EQU     2
  106	 = 0005	 	 	 	LISTOUT EQU     5
  107	 	 	 	 	
  108	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
  109	 	 	 	 	
  110	 	 	 	 	        PUBLIC  $INI,$IOINI,$TTYOT,$LPTOT,$TTYIN,$TTYST,$OSEXT,$ABEND
  111	 	 	 	 	        PUBLIC  $LTTYPS,$STTYPS
  112	 	 	 	 	
  113	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
  114	 	 	 	 	
  115	 	 	 	 	        EXTRN   $DIV0_INT:NEAR,$OVRF_INT:NEAR
  116	 	 	 	 	
  117	 	 	 	 	        EXTRN   $INI0:NEAR
  118	 	 	 	 	        EXTRN   $$WCLF:NEAR
  119	 	 	 	 	        EXTRN   $ERC_DME:NEAR, $ERC_DNR:NEAR, $ERC_FWP:NEAR
  120	 	 	 	 	
  121	 	 	 	 	;***  $INI - Run-time initialization
  122	 	 	 	 	;
  123	 	 	 	 	
  124	 0000	 	 	 	$INI:
  125	 0000  5E	 	 	        POP     SI
  126	 0001  5F	 	 	        POP     DI              ;Get return address
  127	 0002  BA  ---- R	 	        MOV     DX,DC
  128	 0005  8E DA	 	 	        MOV     DS,DX           ;Get segment of data and constants
  129	 0007  8C 06 0002 R	 	        MOV     [$EXITSEG],ES   ;Save exit segment
  130	 000B  26: A1 0002	 	        MOV     AX,WORD PTR ES:2  ;Get memory size in paragraphs
  131	 000F  8E C2	 	 	        MOV     ES,DX
  132	 0011  2D 0020	 	 	        SUB     AX,(STKSIZ+15)/16  ;Allow room for stack
  133	 0014  8E D0	 	 	        MOV     SS,AX
  134	 0016  BC 0200	 	 	        MOV     SP,STKSIZ
  135	 0019  57	 	 	        PUSH    DI
  136	 001A  56	 	 	        PUSH    SI              ;Return address back on stack
  137	 001B  2B C2	 	 	        SUB     AX,DX           ;Size of data segment
  138	 001D  3D 0FFF	 	 	        CMP     AX,0FFFH        ;More than 64K in data segment?
  139	 0020  76 02	 	 	        JBE     FIGSIZ
  140	 0022  33 C0	 	 	        XOR     AX,AX
  141	 0024	 	 	 	FIGSIZ:
  142	 0024  B1 04	 	 	        MOV     CL,4
  143	 0026  D3 E0	 	 	        SHL     AX,CL           ;Multiply by 16 to get bytes
  144	 0028  48	 	 	        DEC     AX              ;Point to last available byte
  145	 0029  A3 0000 E	 	        MOV     [$$SLWA],AX
  146	 002C  C7 06 0000 E 0000 R	        MOV     [$$SFWA],OFFSET DC:MEMRY
  147	 	 	 	 	
  148	 	 	 	 	ASSUME  ES:NOTHING
  149	 	 	 	 	
  150	 0032  33 C0	 	 	        XOR     AX,AX           ;Clear segment
  151	 0034  06	 	 	        PUSH    ES              ;Save ES
  152	 0035  8E C0	 	 	        MOV     ES,AX           ;Set ES to 0:xxxx
  153	 0037  9C	 	 	        PUSHF                   ;Save interrupt status
  154	 0038  FA	 	 	        DISABLE                 ;Turn off interrupts
  155	 	 	 	 	        SAVINT  DIV0_SAVE,ES:(0*4)


DOSIO - Basic I/O and initialization for 86-DOS and IBM  Macro-86 %1(12)   1:0:27  13-Nov-81    Page 1-5



  156	 0039  26: A1 0000            +	        MOV     AX,ES:(0*4)
  157	 003D  A3 0000 R              +	        MOV     DIV0_SAVE,AX
  158	 0040  26: A1 0002            +	        MOV     AX,ES:(0*4)+2
  159	 0044  A3 0002 R              +	        MOV     DIV0_SAVE+2,AX
  160	 	 	 	 	        SAVINT  OVRF_SAVE,ES:(4*4)
  161	 0047  26: A1 0010            +	        MOV     AX,ES:(4*4)
  162	 004B  A3 0004 R              +	        MOV     OVRF_SAVE,AX
  163	 004E  26: A1 0012            +	        MOV     AX,ES:(4*4)+2
  164	 0052  A3 0006 R              +	        MOV     OVRF_SAVE+2,AX
  165	 	 	 	 	        SAVINT  DSKE_SAVE,ES:(36*4)
  166	 0055  26: A1 0090            +	        MOV     AX,ES:(36*4)
  167	 0059  A3 0008 R              +	        MOV     DSKE_SAVE,AX
  168	 005C  26: A1 0092            +	        MOV     AX,ES:(36*4)+2
  169	 0060  A3 000A R              +	        MOV     DSKE_SAVE+2,AX
  170	 	 	 	 	        SETINT  ES:(0*4),$DIV0_INT
  171	 0063  26: C7 06 0000 0000 E  +	        MOV     word ptr ES:(0*4),offset $DIV0_INT
  172	 006A  26: 8C 0E 0002         +	        MOV     word ptr ES:(0*4)+2,CS
  173	 	 	 	 	        SETINT  ES:(4*4),$OVRF_INT
  174	 006F  26: C7 06 0010 0000 E  +	        MOV     word ptr ES:(4*4),offset $OVRF_INT
  175	 0076  26: 8C 0E 0012         +	        MOV     word ptr ES:(4*4)+2,CS
  176	 	 	 	 	        SETINT  ES:(36*4),$DSKE_INT
  177	 007B  26: C7 06 0090 00B2 R  +	        MOV     word ptr ES:(36*4),offset $DSKE_INT
  178	 0082  26: 8C 0E 0092         +	        MOV     word ptr ES:(36*4)+2,CS
  179	 0087  9D	 	 	        POPF                    ;Restore interrupts
  180	 0088  07	 	 	        POP     ES
  181	 	 	 	 	
  182	 	 	 	 	ASSUME  ES:DC
  183	 	 	 	 	
  184	 0089  E9 0000 E	 	        JMP     $INI0
  185	 	 	 	 	
  186	 	 	 	 	
  187	 	 	 	 	;***  $IOINI - 86-DOS special I/O initialization
  188	 	 	 	 	;
  189	 	 	 	 	
  190	 008C	 	 	 	$IOINI:
  191	 008C  C3	 	 	        RET
  192	 	 	 	 	
  193	 	 	 	 	
  194	 	 	 	 	;***  $TTYST - TTY status
  195	 	 	 	 	;
  196	 	 	 	 	; Inputs:
  197	 	 	 	 	;       None.
  198	 	 	 	 	; Function:
  199	 	 	 	 	;       Check console for pending character.
  200	 	 	 	 	; Outputs:
  201	 	 	 	 	;       Zero flag clear if character waiting.
  202	 	 	 	 	;       Zero flag set if none.
  203	 	 	 	 	; Registers:
  204	 	 	 	 	;       Only AX and F affected.
  205	 	 	 	 	
  206	 008D	 	 	 	$TTYST:
  207	 008D  B4 0B	 	 	        MOV     AH,STATUS
  208	 008F  CD 21	 	 	        INT     33
  209	 0091  0A C0	 	 	        OR      AL,AL


DOSIO - Basic I/O and initialization for 86-DOS and IBM  Macro-86 %1(12)   1:0:27  13-Nov-81    Page 1-6



  210	 0093  C3	 	 	        RET
  211	 	 	 	 	
  212	 	 	 	 	
  213	 	 	 	 	;***  $TTYIN - TTY input
  214	 	 	 	 	;
  215	 	 	 	 	; Inputs:
  216	 	 	 	 	;       None.
  217	 	 	 	 	; Function:
  218	 	 	 	 	;       Get character from console keyboard
  219	 	 	 	 	; Outputs:
  220	 	 	 	 	;       AL = character
  221	 	 	 	 	; Registers:
  222	 	 	 	 	;       Only AX and F affected.
  223	 	 	 	 	
  224	 0094	 	 	 	$TTYIN:
  225	 0094  B4 08	 	 	        MOV     AH,INCHAR
  226	 0096  CD 21	 	 	        INT     33
  227	 0098  C3	 	 	        RET
  228	 	 	 	 	
  229	 	 	 	 	
  230	 	 	 	 	;***  $TTYOT and $LPTOT - Character output routines
  231	 	 	 	 	;
  232	 	 	 	 	; Inputs:
  233	 	 	 	 	;       AL = Character to output
  234	 	 	 	 	; Function:
  235	 	 	 	 	;       Send character to console video or to printer
  236	 	 	 	 	; Outputs:
  237	 	 	 	 	;       None.
  238	 	 	 	 	; Register:
  239	 	 	 	 	;       No registers or flags affected.
  240	 	 	 	 	
  241	 0099	 	 	 	$LPTOT:
  242	 0099  52	 	 	        PUSH    DX
  243	 009A  92	 	 	        XCHG    AX,DX
  244	 009B  B4 05	 	 	        MOV     AH,LISTOUT
  245	 009D  EB 04	 	 	        JMP     SHORT CHOUT
  246	 	 	 	 	
  247	 009F	 	 	 	$TTYOT:
  248	 009F  52	 	 	        PUSH    DX
  249	 00A0  92	 	 	        XCHG    AX,DX
  250	 00A1  B4 02	 	 	        MOV     AH,OUTCH
  251	 00A3	 	 	 	CHOUT:
  252	 00A3  CD 21	 	 	        INT     33
  253	 00A5  92	 	 	        XCHG    AX,DX
  254	 00A6  5A	 	 	        POP     DX
  255	 00A7  C3	 	 	        RET
  256	 	 	 	 	
  257	 	 	 	 	
  258	 	 	 	 	;**     $LTTYPS and $STTYPS - Load and store console position
  259	 	 	 	 	
  260	 00A8	 	 	 	$LTTYPS:
  261	 00A8  8A 26 0005 R	 	        MOV     AH,[$TTYPOS]
  262	 00AC  C3	 	 	        RET
  263	 	 	 	 	


DOSIO - Basic I/O and initialization for 86-DOS and IBM  Macro-86 %1(12)   1:0:27  13-Nov-81    Page 1-7



  264	 00AD	 	 	 	$STTYPS:
  265	 00AD  88 26 0005 R	 	        MOV     [$TTYPOS],AH
  266	 00B1  C3	 	 	        RET
  267	 	 	 	 	
  268	 	 	 	 	
  269	 	 	 	 	
  270	 	 	 	 	; $DSKE_INT -   Disk Errors vector here via Interrupt 36.
  271	 	 	 	 	;               [DI] has Error code as follows:
  272	 	 	 	 	;               00 - Disk Write Protected.
  273	 	 	 	 	;               02 - Disk Not Ready
  274	 	 	 	 	;               04 - Data Error
  275	 	 	 	 	;               06 - Seek Error
  276	 	 	 	 	;               08 - Sector not found
  277	 	 	 	 	;               10 - Write Fault (hard disks only)
  278	 	 	 	 	;               12 - Other error.
  279	 	 	 	 	
  280	 00B2	 	 	 	$DSKE_INT:
  281	 00B2  FB	 	 	        ENABLE
  282	 00B3  8B C7	 	 	        MOV     AX,DI           ;Get error code in [AL]
  283	 00B5  83 C4 14	 	 	        ADD     SP,20           ;Move stack for POP's
  284	 00B8  1F	 	 	        POP     DS              ;Get Runtime's DS
  285	 00B9  07	 	 	        POP     ES              ;Get Runtime's ES
  286	 00BA  0A C0	 	 	        OR      AL,AL
  287	 00BC  75 03	 	 	        JNZ     $DSKE_ER2
  288	 00BE  E9 0000 E	 	        JMP     $ERC_FWP        ;Brif "Disk Write Protected"
  289	 00C1	 	 	 	$DSKE_ER2:
  290	 00C1  3C 02	 	 	        CMP     AL,2
  291	 00C3  75 03	 	 	        JNZ     $DSKE_ER3
  292	 00C5  E9 0000 E	 	        JMP     $ERC_DNR        ;Brif "Disk not Ready"
  293	 00C8	 	 	 	$DSKE_ER3:
  294	 00C8  E9 0000 E	 	        JMP     $ERC_DME        ; ..else "Disk Media Error"
  295	 	 	 	 	
  296	 	 	 	 	
  297	 	 	 	 	
  298	 	 	 	 	;***  $OSEXT - Return to 86-DOS
  299	 	 	 	 	
  300	 00CB	 	 	 	$ABEND:                         ;Serious error
  301	 00CB	 	 	 	$OSEXT:                         ;'C' set on BASIC trapped error
  302	 	 	 	 	
  303	 	 	 	 	ASSUME  ES:NOTHING
  304	 	 	 	 	
  305	 00CB  33 C0	 	 	        XOR     AX,AX           ;Clear segment
  306	 00CD  06	 	 	        PUSH    ES              ;Save ES
  307	 00CE  8E C0	 	 	        MOV     ES,AX           ;Set ES to 0:xxxx
  308	 00D0  9C	 	 	        PUSHF                   ;Save interrupt status
  309	 00D1  FA	 	 	        DISABLE                 ;Turn off interrupts
  310	 	 	 	 	        RSTINT  ES:(0*4),DIV0_SAVE
  311	 00D2  A1 0000 R              +	        MOV     AX,DIV0_SAVE
  312	 00D5  26: A3 0000            +	        MOV     ES:(0*4),AX
  313	 00D9  A1 0002 R              +	        MOV     AX,DIV0_SAVE+2
  314	 00DC  26: A3 0002            +	        MOV     ES:(0*4)+2,AX
  315	 	 	 	 	        RSTINT  ES:(4*4),OVRF_SAVE
  316	 00E0  A1 0004 R              +	        MOV     AX,OVRF_SAVE
  317	 00E3  26: A3 0010            +	        MOV     ES:(4*4),AX


DOSIO - Basic I/O and initialization for 86-DOS and IBM  Macro-86 %1(12)   1:0:27  13-Nov-81    Page 1-8



  318	 00E7  A1 0006 R              +	        MOV     AX,OVRF_SAVE+2
  319	 00EA  26: A3 0012            +	        MOV     ES:(4*4)+2,AX
  320	 	 	 	 	        RSTINT  ES:(36*4),DSKE_SAVE
  321	 00EE  A1 0008 R              +	        MOV     AX,DSKE_SAVE
  322	 00F1  26: A3 0090            +	        MOV     ES:(36*4),AX
  323	 00F5  A1 000A R              +	        MOV     AX,DSKE_SAVE+2
  324	 00F8  26: A3 0092            +	        MOV     ES:(36*4)+2,AX
  325	 00FC  9D	 	 	        POPF                    ;Restore interrupts
  326	 00FD  07	 	 	        POP     ES              ;Restore ES
  327	 	 	 	 	
  328	 	 	 	 	ASSUME  ES:DC
  329	 	 	 	 	
  330	 00FE  FF 2E 0000 R	 	        JMP     DWORD PTR [EXIT]
  331	 	 	 	 	
  332	 0102	 	 	 	CODE    ENDS
  333	 	 	 	 	        END








































DOSIO - Basic I/O and initialization for 86-DOS and IBM  Macro-86 %1(12)   1:0:27  13-Nov-81    Symbols-1



Macros:

	 	N a m e  	 	Length

DEVMAC . . . . . . . . . . . . .	0002	
DEVNAM . . . . . . . . . . . . .	0005	
DSPMAC . . . . . . . . . . . . .	0001	
DSPNAM . . . . . . . . . . . . .	000E	
ENT. . . . . . . . . . . . . . .	0002	
ENTI . . . . . . . . . . . . . .	0002	
ENTORG . . . . . . . . . . . . .	0001	
MOVINT . . . . . . . . . . . . .	0003	
RSTINT . . . . . . . . . . . . .	0003	
SAVINT . . . . . . . . . . . . .	0003	
SETINT . . . . . . . . . . . . .	0002	

Structures and records:

	 	N a m e	 	 	Width	# fields
	 	       	 	 	Shift	Width	Mask	Initial

FILE_DATA_BLOCK. . . . . . . . .        00BD    0012
  FD_MODE. . . . . . . . . . . . .      0000
  FD_FCB . . . . . . . . . . . . .      0001
  FD_CURLOC. . . . . . . . . . . .      0027
  FD_ORNOFS. . . . . . . . . . . .      0029
  FD_NMLOFS. . . . . . . . . . . .      002A
  FD_DEVICE. . . . . . . . . . . .      002E
  FD_WIDTH . . . . . . . . . . . .      002F
  FD_POS . . . . . . . . . . . . .      0030
  FD_FLAGS . . . . . . . . . . . .      0031
  FD_OUTPOS . . .  . . . . . . . .      0032
  FD_BUFFER  . . . . . . . . . . .      0033
  FD_VRECL . . . . . . . . . . . .      00B3
  FD_PHYREC. . . . . . . . . . . .      00B5
  FD_LOGREC. . . . . . . . . . . .      00B7
  FD_OUTPOS. . . . . . . . . . . .      00BA
  FD_FIELD . . . . . . . . . . . .      00BC
    
Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0102	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  CONST. . . . . . . . . . . . . .	0006	WORD  	PUBLIC	'CONST'
  DATA . . . . . . . . . . . . . .	000C	WORD  	PUBLIC	'DATA'
MEMORY . . . . . . . . . . . . .	0000	WORD  	NONE	'MEMORY'
STACK. . . . . . . . . . . . . .	0200	WORD  	STACK 	'STACK'
 
Symbols:            
  
	 	N a m e	 	 	Type	Value	Attr         

BL_LEN . . . . . . . . . . . . .        Number  FFFC

DOSIO - Basic I/O and initialization for 86-DOS and IBM  Macro-86 %1(12)   1:0:27  13-Nov-81    Symbols-2



BL_LNK . . . . . . . . . . . . .        Number  FFFE
BL_SIZE. . . . . . . . . . . . .        Number  FFFA
CHOUT. . . . . . . . . . . . . .	L NEAR 	00A3	CODE
DISABLE. . . . . . . . . . . . .	Opcode	 	
DIV0_SAVE. . . . . . . . . . . .	L WORD 	0000	DATA	Length =0002
DN_KYBD. . . . . . . . . . . . .        Number  FFFF
DN_LPT1. . . . . . . . . . . . .        Number  FFFD
DN_SCRN. . . . . . . . . . . . .        Number  FFFE
DSKE_SAVE. . . . . . . . . . . .	L WORD 	0008	DATA	Length =0002
DV_BAKC. . . . . . . . . . . . .        Number  000E
DV_CLOSE . . . . . . . . . . . .        Number  0006
DV_EOF . . . . . . . . . . . . .        Number  0000
DV_GPOS. . . . . . . . . . . . .        Number  0014
DV_GWID. . . . . . . . . . . . .        Number  0016
DV_LOC . . . . . . . . . . . . .        Number  0002
DV_LOF . . . . . . . . . . . . .        Number  0004
DV_OPEN. . . . . . . . . . . . .        Number  000C
DV_RANDIO. . . . . . . . . . . .        Number  000A
DV_SINP. . . . . . . . . . . . .        Number  0010
DV_SOUT. . . . . . . . . . . . .        Number  0012
DV_TABLEN. . . . . . . . . . . .        Number  0018
DV_WIDTH . . . . . . . . . . . .        Number  0008
ENABLE . . . . . . . . . . . . .	Opcode	 	
EOFCHR . . . . . . . . . . . . .        Number  001A
EXIT . . . . . . . . . . . . . .	L WORD 	0000	CONST
FB_NUM . . . . . . . . . . . . .        Number  FFFB
FCB_LENGTH . . . . . . . . . . .        Number  0026
FIGSIZ . . . . . . . . . . . . .	L NEAR 	0024	CODE
FILNAML. . . . . . . . . . . . .        Number  0026
FILNAM_LENGTH. . . . . . . . . .        Number  000B
INCHAR . . . . . . . . . . . . .	Number	0008	
LAST_DEVICE_OFFSET . . . . . . .        Number  0008
LISTOUT. . . . . . . . . . . . .	Number	0005	
MD_APP . . . . . . . . . . . . .        Number  0008
MD_BIN . . . . . . . . . . . . .        Number  0080
MD_FIL . . . . . . . . . . . . .        Number  0004
MD_IBM . . . . . . . . . . . . .        Number  0020
MD_KIL . . . . . . . . . . . . .        Number  0010
MD_RND . . . . . . . . . . . . .        Number  0004
MD_SQI . . . . . . . . . . . . .        Number  0001
MD_SQO . . . . . . . . . . . . .        Number  0002
MD_USR . . . . . . . . . . . . .        Number  0040
MEMRY. . . . . . . . . . . . . .	L BYTE 	0000	MEMORY
OUTCH. . . . . . . . . . . . . .	Number	0002	
OVRF_SAVE. . . . . . . . . . . .	L WORD 	0004	DATA	Length =0002
REC_LENGTH . . . . . . . . . . .        Number  0080
STATUS . . . . . . . . . . . . .	Number	000B	
STKSIZ . . . . . . . . . . . . .	Number	0200	
$$SFWA . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$SLWA . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$WCLF . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ABEND . . . . . . . . . . . . .	L NEAR 	00CB	CODE	Global
$DIV0_INT. . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DSKE_ER2. . . . . . . . . . . .	L NEAR 	00C1	CODE


DOSIO - Basic I/O and initialization for 86-DOS and IBM  Macro-86 %1(12)   1:0:27  13-Nov-81    Symbols-3



$DSKE_ER3. . . . . . . . . . . .	L NEAR 	00C8	CODE
$DSKE_INT. . . . . . . . . . . .	L NEAR 	00B2	CODE
$ERC_DME . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_DNR . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_FWP . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$EXITSEG . . . . . . . . . . . .	L WORD 	0002	CONST	Global
$INI . . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$INI0. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$IOINI . . . . . . . . . . . . .	L NEAR 	008C	CODE	Global
$LPTOT . . . . . . . . . . . . .	L NEAR 	0099	CODE	Global
$LTTYPS. . . . . . . . . . . . .	L NEAR 	00A8	CODE	Global
$OSEXT . . . . . . . . . . . . .	L NEAR 	00CB	CODE	Global
$OVRF_INT. . . . . . . . . . . .	L NEAR 	0000	CODE	External
$PTRFIL. . . . . . . . . . . . .	V WORD 	0000	DATA	External
$STTYPS. . . . . . . . . . . . .	L NEAR 	00AD	CODE	Global
$TTYIN . . . . . . . . . . . . .	L NEAR 	0094	CODE	Global
$TTYOT . . . . . . . . . . . . .	L NEAR 	009F	CODE	Global
$TTYPOS. . . . . . . . . . . . .	L BYTE 	0005	CONST	Global
$TTYST . . . . . . . . . . . . .	L NEAR 	008D	CODE	Global
$TTYWID. . . . . . . . . . . . .	L BYTE 	0004	CONST	Global
_CPM_. . . . . . . . . . . . . .	Number	0000	
_IBM_. . . . . . . . . . . . . .	Number	0000	
_MSDOS_. . . . . . . . . . . . .	Number	0001	
___DEV . . . . . . . . . . . . .	Number	FFFC	
___ZZZ . . . . . . . . . . . . .	Number	0018	

Warning Severe
Errors	Errors 
0	0



























