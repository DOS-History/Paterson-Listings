STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   STRUTL - String utilities
    2	 	 	 	 	
    3	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
    4	 	 	 	 	
    5	 	 	 	 	        PUBLIC  NULDES
    6	 	 	 	 	
    7	 0000  0002 R	 	 	NULSTR  DW      DC:NULDES       ;Backpointer to descriptor
    8	 0002  0000 0002 R	 	NULDES  DW      0,DC:NULSTR+2   ;Descriptor for zero-length string
    9	 	 	 	 	
   10	 0006	 	 	 	CONST   ENDS
   11	 	 	 	 	
   12	 	 	 	 	
   13	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
   14	 	 	 	 	
   15	 	 	 	 	        PUBLIC  $$SFWA,$$SLWA,$$SFPT
   16	 	 	 	 	
   17	 0000  ????	 	 	TMPHDR  DW      ?
   18	 0002	 	 	 	TMPL    LABEL   WORD
   19	 0002  ???? ????	 	T1      DW      ?,?
   20	 0006  ???? ????	 	T2      DW      ?,?
   21	 000A  ???? ????	 	T3      DW      ?,?
   22	 000E  ???? ????	 	T4      DW      ?,?
   23	 0012  ???? ????	 	T5      DW      ?,?
   24	 0016  ???? ????	 	T6      DW      ?,?
   25	 001A  ???? ????	 	T7      DW      ?,?
   26	 001E  ???? ????	 	T8      DW      ?,?
   27	 0022  ???? ????	 	T9      DW      ?,?
   28	 0026  ???? ????	 	T10     DW      ?,?
   29	 002A  ???? ????	 	T11     DW      ?,?
   30	 002E  ???? ????	 	T12     DW      ?,?
   31	 0032  ???? ????	 	T13     DW      ?,?
   32	 0036  ???? ????	 	T14     DW      ?,?
   33	 003A  ???? ????	 	T15     DW      ?,?
   34	 003E	 	 	 	TMPH    LABEL   WORD
   35	 	 	 	 	
   36	 003E  ??	 	 	ALCTRY  DB      ?              ;Allocation calls between garbage collections
   37	 003F  ????	 	 	$$SFPT  DW      ?              ;Scan for free string space from here
   38	 0041	 	 	 	$$SFWA  LABEL   WORD
   39	 0041  ????	 	 	STRFWA  DW      ?              ;Bottom of string space
   40	 0043	 	 	 	$$SLWA  LABEL   WORD
   41	 0043  ????	 	 	STRLWA  DW      ?              ;Top of string space
   42	 	 	 	 	
   43	 0045	 	 	 	DATA    ENDS
   44	 	 	 	 	
   45	 	 	 	 	
   46	 	 	 	 	DC      GROUP   CONST,DATA
   47	 	 	 	 	
   48	 	 	 	 	
   49	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
   50	 	 	 	 	        ASSUME  CS:CODE,DS:DC,ES:DC
   51	 	 	 	 	
   52	 	 	 	 	        PUBLIC  $$GSTR,$$MAG,$$ATS,$$CFT,$$CSL,$$CTS,$$CTSD,$$DITS
   53	 	 	 	 	        PUBLIC  $$DTS,$$FSS,$$FTH,$$RSS,$$STSU,$$PUTZ
   54	 	 	 	 	


STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Page 1-2



   55	 	 	 	 	        EXTRN   $TYPTX:NEAR, $ABEND:NEAR, $$TCR:NEAR
   56	 	 	 	 	        EXTRN   $ERC_OS:NEAR, $ERC_OM:NEAR, $ERC_ST:NEAR
   57	 	 	 	 	
   58	 	 	 	 	;***  $$GSTR - Get string space.
   59	 	 	 	 	;
   60	 	 	 	 	; Inputs:
   61	 	 	 	 	;       BX = Length of string space required (may be odd).
   62	 	 	 	 	; Function:
   63	 	 	 	 	;       Find and allocate an appropriate chunk of string space. The requested
   64	 	 	 	 	;       length will be rounded up if odd because allocation is by 16-bit words
   65	 	 	 	 	;       only. An extra word is added to the front as required by teh string
   66	 	 	 	 	;       format for the backpointer. This backpointer is NOT set up by it must
   67	 	 	 	 	;       be before any scan of string space is made (by $$GSTR, garbage
   68	 	 	 	 	;       collectors, etc.)
   69	 	 	 	 	; Outputs:
   70	 	 	 	 	;       BX = Address of string. BX-2 is where backpointer goes.
   71	 	 	 	 	; Registers:
   72	 	 	 	 	;       Only BX and F affected.
   73	 	 	 	 	
   74	 0000	 	 	 	$$GSTR:
   75	 0000  50	 	 	        PUSH    AX
   76	 0001  56	 	 	        PUSH    SI
   77	 0002  43	 	 	        INC     BX              ;Round length up
   78	 0003  80 E3 FE	 	 	        AND     BL,NOT 1        ;Then force down to even 16-bit words
   79	 0006  BE 003E R	 	        MOV     SI,OFFSET DC:ALCTRY  ;Address of count of allocation attempts
   80	 0009  FE 04	 	 	        INC     BYTE PTR [SI]   ;Count one more
   81	 000B  75 03	 	 	        JNZ     LOOKSTR         ;Don't allow rollover to zero
   82	 000D  C6 04 FF	 	 	        MOV     BYTE PTR[SI],-1 ;Just limit to 255
   83	 0010	 	 	 	LOOKSTR:
   84	 0010  8B 36 003F R	 	        MOV     SI,[$$SFPT]     ;Where we left off looking for space
   85	 0014  33 C0	 	 	        XOR     AX,AX           ;Init to free string of zero length
   86	 0016	 	 	 	FORWSTR:
   87	 0016  03 F0	 	 	        ADD     SI,AX           ;Jump over free string
   88	 0018	 	 	 	CHKSTR:
   89	 	 	 	 	;SI points to next string to check if free
   90	 	 	 	 	;BX has length of free space needed (always even--whole words only)
   91	 0018  AD	 	 	        LODSW                   ;Get backpointer/length/tag
   92	 0019  A8 01	 	 	        TEST    AL,1            ;See if its a backpointer, meaning allocated
   93	 001B  74 1E	 	 	        JZ      NEXSTR          ;Yes--try next string
   94	 001D  3D FFFF	 	 	        CMP     AX,-1           ;See if end-of-space tag
   95	 0020  74 35	 	 	        JZ      NONLEF
   96	 0022  48	 	 	        DEC     AX              ;Must be free--zero MSB to get true length
   97	 0023  3B C3	 	 	        CMP     AX,BX           ;Is it big enough?
   98	 0025  72 EF	 	 	        JB      FORWSTR
   99	 	 	 	 	;We have a string big enough
  100	 0027  03 F3	 	 	        ADD     SI,BX           ;Point to where next string will start
  101	 0029  89 36 003F R	 	        MOV     [$$SFPT],SI     ;Here's where we'll start next time
  102	 002D  2B C3	 	 	        SUB     AX,BX           ;How much is left in this free chunk?
  103	 002F  74 03	 	 	        JZ      EXACT           ;Don't touch next string if perfect fit
  104	 0031  48	 	 	        DEC     AX              ;Set the free bit and account for header
  105	 0032  89 04	 	 	        MOV     [SI],AX         ;Make a new header for the chunk that remains
  106	 0034	 	 	 	EXACT:
  107	 0034  2B F3	 	 	        SUB     SI,BX           ;Point back to beginning of string area
  108	 0036  8B DE	 	 	        MOV     BX,SI           ;Leave this result in BX


STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Page 1-3



  109	 0038  5E	 	 	        POP     SI
  110	 0039  58	 	 	        POP     AX
  111	 003A  C3	 	 	        RET
  112	 	 	 	 	
  113	 003B	 	 	 	NEXSTR:
  114	 	 	 	 	;Skip over string in use. AX has backpointer
  115	 003B  93	 	 	        XCHG    AX,BX           ;Save BX while putting backpointer there
  116	 003C  03 37	 	 	        ADD     SI,[BX]         ;Add length of string to string space pointer
  117	 003E  46	 	 	        INC     SI              ;Round up if length was odd
  118	 003F  81 E6 FFFE	 	        AND     SI,NOT 1        ;Then force to word boundary
  119	 0043  93	 	 	        XCHG    AX,BX           ;Restore BX
  120	 0044  EB D2	 	 	        JMP     CHKSTR
  121	 	 	 	 	
  122	 0046	 	 	 	NEEDMAJ:
  123	 	 	 	 	;Unable to find the needed space even after recent minor garbage collection
  124	 0046  E8 0095 R	 	        CALL    $$MAG           ;Perform major garbage collection
  125	 0049  8B 36 003F R	 	        MOV     SI,[$$SFPT]     ;Point to beginning of free space
  126	 004D  3B 1C	 	 	        CMP     BX,[SI]         ;See if we have enough now
  127	 004F  76 C7	 	 	        JBE     CHKSTR          ;Yes--try allocation again
  128	 0051  E9 0000 E	 	        JMP     $ERC_OS         ;Clean stack and report out of string space
  129	 	 	 	 	
  130	 0054	 	 	 	EXITMIG:
  131	 0054  5B	 	 	        POP     BX
  132	 0055  EB B9	 	 	        JMP     LOOKSTR
  133	 	 	 	 	
  134	 0057	 	 	 	NONLEF:
  135	 	 	 	 	;Couldn't find a free chunk in one pass so let's try garbage collection
  136	 0057  B0 00	 	 	        MOV     AL,0
  137	 0059  86 06 003E R	 	        XCHG    AL,[ALCTRY]     ;Read and zero count of allocation attempts
  138	 005D  3C 06	 	 	        CMP     AL,6            ;Did we make at least 6 allocations?
  139	 005F  72 E5	 	 	        JB      NEEDMAJ         ;If not, time for major garbage collection
  140	 	 	 	 	
  141	 	 	 	 	;Perform minor garbage collection. Simply runs through string space, merging
  142	 	 	 	 	;adjacent free areas. Does no data movement.
  143	 	 	 	 	
  144	 0061  53	 	 	        PUSH    BX              ;Save length of request while we fiddle around
  145	 0062  8B 36 0041 R	 	        MOV     SI,[STRFWA]     ;First location in string space
  146	 0066  89 36 003F R	 	        MOV     [$$SFPT],SI     ;We'll start over next attempt
  147	 006A	 	 	 	SETUSED:
  148	 006A  B3 FF	 	 	        MOV     BL,-1           ;Flag--previous string was not free
  149	 006C	 	 	 	FRESTR:
  150	 006C  AD	 	 	        LODSW                   ;Get backpointer/length/tag
  151	 006D  3D FFFF	 	 	        CMP     AX,-1           ;See if end of string space
  152	 0070  74 E2	 	 	        JZ      EXITMIG         ;Terminate garbage collection if so
  153	 0072  A8 01	 	 	        TEST    AL,1            ;See if a backpointer
  154	 0074  74 15	 	 	        JZ      USEDSTR         ;Yes--this space is allocated
  155	 	 	 	 	;We have a free string. Attempt to combine with previous free string
  156	 0076  80 FB FF	 	 	        CMP     BL,-1           ;Was previous string free?
  157	 0079  75 07	 	 	        JNZ     CATENATE        ;If so, put them together
  158	 007B  8B DE	 	 	        MOV     BX,SI           ;Save pointer to this free string
  159	 007D  03 F0	 	 	        ADD     SI,AX           ;Point to next string
  160	 007F  4E	 	 	        DEC     SI              ;Reset LSB
  161	 0080  EB EA	 	 	        JMP     FRESTR
  162	 	 	 	 	


STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Page 1-4



  163	 0082	 	 	 	CATENATE:
  164	 0082  03 F0	 	 	        ADD     SI,AX           ;Point to next string
  165	 0084  4E	 	 	        DEC     SI              ;Account for LSB set as a flag
  166	 0085  40	 	 	        INC     AX              ;Include header in size
  167	 0086  01 47 FE	 	 	        ADD     [BX-2],AX       ;Adjust header of previous string
  168	 0089  EB E1	 	 	        JMP     FRESTR
  169	 	 	 	 	
  170	 008B	 	 	 	USEDSTR:
  171	 	 	 	 	;Skip over a string in use
  172	 008B  93	 	 	        XCHG    AX,BX           ;Get backpointer in BX for addressing
  173	 008C  03 37	 	 	        ADD     SI,[BX]         ;Add length of string to pointer
  174	 008E  46	 	 	        INC     SI              ;Round up if odd
  175	 008F  81 E6 FFFE	 	        AND     SI,NOT 1        ;And force to word boundary
  176	 0093  EB D5	 	 	        JMP     SETUSED
  177	 	 	 	 	
  178	 	 	 	 	
  179	 	 	 	 	;***  $$MAG - Major garbage collection
  180	 	 	 	 	;
  181	 	 	 	 	; Inputs:
  182	 	 	 	 	;       None.
  183	 	 	 	 	; Function:
  184	 	 	 	 	;       Compact all free space into one big (?) chunk. All strings in use are
  185	 	 	 	 	;       copied down to the bottom of free space with the backpointers used to
  186	 	 	 	 	;       find and correct their descriptors.
  187	 	 	 	 	; Outputs:
  188	 	 	 	 	;       None.
  189	 	 	 	 	; Registers:
  190	 	 	 	 	;       Only F affected.
  191	 	 	 	 	
  192	 0095	 	 	 	$$MAG:
  193	 0095  50	 	 	        PUSH    AX
  194	 0096  53	 	 	        PUSH    BX
  195	 0097  56	 	 	        PUSH    SI
  196	 0098  57	 	 	        PUSH    DI
  197	 0099  B8 0001	 	 	        MOV     AX,1            ;Initialization trick
  198	 009C  8B 36 0041 R	 	        MOV     SI,[STRFWA]     ;Pointer to string scan
  199	 00A0  8B FE	 	 	        MOV     DI,SI           ;Destination of string copies
  200	 00A2	 	 	 	MAGFRE:
  201	 00A2  48	 	 	        DEC     AX              ;Reset free flag in LSB
  202	 00A3	 	 	 	MAGNXT:
  203	 00A3  03 F0	 	 	        ADD     SI,AX           ;Jump over free block
  204	 00A5	 	 	 	MAGSTR:
  205	 	 	 	 	;SI points to next string in uncompacted string space
  206	 	 	 	 	;DI points to free point in compacted string space
  207	 	 	 	 	; (SI and DI are equal until a free string is encountered)
  208	 00A5  AD	 	 	        LODSW                   ;Get backpointer/length/tag
  209	 00A6  3D FFFF	 	 	        CMP     AX,-1           ;End-of-space tag?
  210	 00A9  74 23	 	 	        JZ      EXITMAG
  211	 00AB  A8 01	 	 	        TEST    AL,1            ;Is it a free chunk?
  212	 00AD  75 F3	 	 	        JNZ     MAGFRE          ;If so, skip over it
  213	 00AF  AB	 	 	        STOSW                   ;Copy backpointer to compacted space
  214	 00B0  93	 	 	        XCHG    BX,AX           ;Put backpointer in base register
  215	 00B1  8B 07	 	 	        MOV     AX,[BX]         ;Get length
  216	 00B3  3B 77 02	 	 	        CMP     SI,[BX+2]       ;See if pointers match


STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Page 1-5



  217	 00B6  75 29	 	 	        JNZ     MAGERR          ;If not, abort everything
  218	 	 	 	 	;We have a string in use. Move it to compacted space.
  219	 00B8  40	 	 	        INC     AX              ;Increase byte length for whole words
  220	 00B9  3B F7	 	 	        CMP     SI,DI           ;Copying to ourself? (no free string yet)
  221	 00BB  74 0B	 	 	        JZ      INPLACE
  222	 00BD  89 7F 02	 	 	        MOV     [BX+2],DI       ;Point descriptor to compacted space
  223	 00C0  91	 	 	        XCHG    AX,CX           ;Get count in CX while saving it
  224	 00C1  D1 E9	 	 	        SHR     CX,1            ;Move words
  225	 00C3  F3/ A5	 	 	        REP     MOVSW           ;Compact the string
  226	 00C5  91	 	 	        XCHG    AX,CX           ;Restore CX
  227	 00C6  EB DD	 	 	        JMP     MAGSTR
  228	 	 	 	 	
  229	 00C8	 	 	 	INPLACE:
  230	 	 	 	 	;SI=DI so movement not necessary.
  231	 00C8  24 FE	 	 	        AND     AL,NOT 1        ;Force to word boundary
  232	 00CA  03 F8	 	 	        ADD     DI,AX           ;Skip over it in compacted space
  233	 00CC  EB D5	 	 	        JMP     MAGNXT
  234	 	 	 	 	
  235	 00CE	 	 	 	EXITMAG:
  236	 	 	 	 	;SI points to first word beyond end of string space
  237	 	 	 	 	;DI points to first free word.
  238	 00CE  2B F7	 	 	        SUB     SI,DI           ;Compute length of free space
  239	 00D0  83 EE 04	 	 	        SUB     SI,4            ;Account for 2 headers
  240	 00D3  72 03	 	 	        JB      SAVSTRT         ;If we're full, no room for free space header
  241	 00D5  46	 	 	        INC     SI              ;Set free space bit
  242	 00D6  89 35	 	 	        MOV     [DI],SI         ;Header for new free space chunk
  243	 00D8	 	 	 	SAVSTRT:
  244	 00D8  89 3E 003F R	 	        MOV     [$$SFPT],DI     ;Tell $$GSTR where free space starts
  245	 00DC  5F	 	 	        POP     DI
  246	 00DD  5E	 	 	        POP     SI
  247	 00DE  5B	 	 	        POP     BX
  248	 00DF  58	 	 	        POP     AX
  249	 00E0  C3	 	 	        RET
  250	 	 	 	 	
  251	 00E1	 	 	 	MAGERR:
  252	 00E1  E8 00F9 R	 	        CALL    SSCERR          ;String Space Corrupt error
  253	 00E4  E8 0000 E	 	        CALL    $TYPTX
  254	 00E7  20 64 75 72 69 6E	        DB      ' during G.C','.'+80H
  255	       67 20 47 2E 43 AE	
  256	 00F3  E8 0000 E	 	        CALL    $$TCR
  257	 00F6  E9 0000 E	 	        JMP     $ABEND          ;Give it up
  258	 	 	 	 	
  259	 00F9  E8 0000 E	 	SSCERR: CALL    $$TCR
  260	 00FC  E8 0000 E	 	        CALL    $TYPTX
  261	 00FF  49 6E 74 65 72 6E	        DB      'Internal Error - String Space Corrup','t'+80H
  262	       61 6C 20 45 72 72	
  263	       6F 72 20 2D 20 53	
  264	       74 72 69 6E 67 20	
  265	       53 70 61 63 65 20	
  266	       43 6F 72 72 75 70	
  267	       F4	 	 	
  268	 0124  C3	 	 	        RET
  269	 	 	 	 	
  270	 	 	 	 	


STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Page 1-6



  271	 	 	 	 	;***  $$ATS - Allocate temporary string
  272	 	 	 	 	;
  273	 	 	 	 	; Inputs:
  274	 	 	 	 	;       BX = Length of string
  275	 	 	 	 	; Function:
  276	 	 	 	 	;       Allocate the requested amount of free space and attach it to a temp
  277	 	 	 	 	;       descriptor. Backpointer in string space set but data is not moved in.
  278	 	 	 	 	; Outputs:
  279	 	 	 	 	;       DX = Address of string data area.
  280	 	 	 	 	;       BX = Address of temp string descriptor
  281	 	 	 	 	; Registers:
  282	 	 	 	 	;       Only BX, DX, F affected.
  283	 	 	 	 	
  284	 0125	 	 	 	$$ATS:
  285	 0125  0B DB	 	 	        OR      BX,BX
  286	 0127  74 24	 	 	        JZ      ATSNUL          ;Nul strings have special descriptor
  287	 0129  83 3E 0000 R 00	 	        CMP     WORD PTR[TMPHDR],0  ;See if we have any temps left
  288	 012E  74 24	 	 	        JZ      TEMPOV
  289	 0130  56	 	 	        PUSH    SI
  290	 0131  53	 	 	        PUSH    BX
  291	 0132  E8 0000 R	 	        CALL    $$GSTR          ;Allocate the space
  292	 0135  8B 36 0000 R	 	        MOV     SI,[TMPHDR]     ;Get the next temp
  293	 0139  8B 14	 	 	        MOV     DX,[SI]         ;Make the one after that
  294	 013B  89 16 0000 R	 	        MOV     [TMPHDR],DX     ;   the new "next temp"
  295	 013F  8F 04	 	 	        POP     [SI]            ;Set length in descriptor
  296	 0141  89 77 FE	 	 	        MOV     [BX-2],SI       ;Set backpointer
  297	 0144  89 5C 02	 	 	        MOV     [SI+2],BX       ;Set pointer in descriptor
  298	 0147  8B D3	 	 	        MOV     DX,BX           ;Put data pointer in DX
  299	 0149  8B DE	 	 	        MOV     BX,SI           ;Need temp descriptor in BX
  300	 014B  5E	 	 	        POP     SI
  301	 014C  C3	 	 	        RET
  302	 	 	 	 	
  303	 014D	 	 	 	ATSNUL:
  304	 	 	 	 	;Return pointer to nul string
  305	 014D  BA 0000 R	 	        MOV     DX,OFFSET DC:NULSTR
  306	 0150  BB 0002 R	 	        MOV     BX,OFFSET DC:NULDES
  307	 0153  C3	 	 	        RET
  308	 	 	 	 	
  309	 0154	 	 	 	TEMPOV:
  310	 0154  E9 0000 E	 	        JMP     $ERC_ST         ;Clean stack and report string temporary ovfl.
  311	 	 	 	 	
  312	 	 	 	 	;***  $$CFT - Check for temporary string descriptor
  313	 	 	 	 	;
  314	 	 	 	 	; Inputs:
  315	 	 	 	 	;       BX = Address of string descriptor
  316	 	 	 	 	; Function:
  317	 	 	 	 	;       Check to see if the string descriptor is a temporary.
  318	 	 	 	 	; Outputs:
  319	 	 	 	 	;       Carry flag set if a temp
  320	 	 	 	 	;       Carry clear in not
  321	 	 	 	 	; Registers:
  322	 	 	 	 	;       Only F affected.
  323	 	 	 	 	
  324	 0157	 	 	 	$$CFT:


STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Page 1-7



  325	 0157  81 FB 003E R	 	        CMP     BX,OFFSET DC:TMPH
  326	 015B  73 47	 	 	        JNC     RET             ;If above high end, not a temp
  327	 015D  81 FB 0002 R	 	        CMP     BX,OFFSET DC:TMPL
  328	 0161  F5	 	 	        CMC
  329	 0162  C3	 	 	        RET
  330	 	 	 	 	
  331	 	 	 	 	
  332	 	 	 	 	;***  $$CSL - Compute string length
  333	 	 	 	 	;
  334	 	 	 	 	; Inputs:
  335	 	 	 	 	;       BX = address of a string terminated by 00
  336	 	 	 	 	; Function:
  337	 	 	 	 	;       Count the number of characters in the string.
  338	 	 	 	 	; Outputs:
  339	 	 	 	 	;       AX = Length of the line (not including 00)
  340	 	 	 	 	; Registers:
  341	 	 	 	 	;       Only AX and F affected.
  342	 	 	 	 	
  343	 0163	 	 	 	$$CSL:
  344	 0163  51	 	 	        PUSH    CX
  345	 0164  57	 	 	        PUSH    DI
  346	 0165  B9 FFFF	 	 	        MOV     CX,-1           ;Scan up to 65535 characters
  347	 0168  B0 00	 	 	        MOV     AL,0            ;Search for a zero
  348	 016A  8B FB	 	 	        MOV     DI,BX
  349	 016C  F2/ AE	 	 	        REPNE   SCASB           ;Scan for a 00
  350	 016E  8B C1	 	 	        MOV     AX,CX           ;Amount of the 65535 left
  351	 0170  F7 D0	 	 	        NOT     AX
  352	 0172  48	 	 	        DEC     AX
  353	 0173  5F	 	 	        POP     DI
  354	 0174  59	 	 	        POP     CX
  355	 0175  C3	 	 	        RET
  356	 	 	 	 	
  357	 	 	 	 	
  358	 	 	 	 	;***  $$CTS - Create temporary string
  359	 	 	 	 	;
  360	 	 	 	 	; Inputs:
  361	 	 	 	 	;       BX = Length of string
  362	 	 	 	 	;       DX = Address of string data
  363	 	 	 	 	; Function:
  364	 	 	 	 	;       Allocate a temporary string and move the string data into it.
  365	 	 	 	 	; Outputs:
  366	 	 	 	 	;       BX = Address of temp string descriptor
  367	 	 	 	 	; Registers:
  368	 	 	 	 	;       Only BX and F affected.
  369	 	 	 	 	
  370	 0176	 	 	 	$$CTS:
  371	 0176  51	 	 	        PUSH    CX
  372	 0177  8B CB	 	 	        MOV     CX,BX           ;Get length in CX
  373	 0179  56	 	 	        PUSH    SI
  374	 017A  8B F2	 	 	        MOV     SI,DX           ;Point to source of string data
  375	 017C  E8 0125 R	 	        CALL    $$ATS           ;Get a temporary string of the right length
  376	 017F  57	 	 	        PUSH    DI
  377	 0180  8B FA	 	 	        MOV     DI,DX           ;String data destination
  378	 0182  8B D6	 	 	        MOV     DX,SI           ;Restore DX


STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Page 1-8



  379	 0184  41	 	 	        INC     CX              ;Round up if odd
  380	 0185  D1 E9	 	 	        SHR     CX,1            ;Move by words
  381	 0187  F3/ A5	 	 	        REP     MOVSW
  382	 0189  5F	 	 	        POP     DI
  383	 018A  5E	 	 	        POP     SI
  384	 018B  59	 	 	        POP     CX
  385	 018C  C3	 	 	        RET
  386	 	 	 	 	
  387	 	 	 	 	
  388	 	 	 	 	;***  $$DTS - Delete all temporary strings
  389	 	 	 	 	;
  390	 	 	 	 	; Inputs:
  391	 	 	 	 	;       None.
  392	 	 	 	 	; Function:
  393	 	 	 	 	;       Free all temporary strings and descriptors.
  394	 	 	 	 	; Outputs:
  395	 	 	 	 	;       None.
  396	 	 	 	 	; Registers:
  397	 	 	 	 	;       Only F affected.
  398	 	 	 	 	
  399	 018D	 	 	 	$$DTS:
  400	 018D  53	 	 	        PUSH    BX
  401	 018E  BB 0002 R	 	        MOV     BX,OFFSET DC:T1 ;First string descriptor
  402	 0191	 	 	 	DTSLOOP:
  403	 0191  83 7F 02 FF	 	        CMP     WORD PTR[BX+2],-1  ;If pointer is -1, then its already free
  404	 0195  74 03	 	 	        JZ      NEXTMP          ;Skip if free
  405	 0197  E8 01AA R	 	        CALL    DELTMP          ;Delete if not
  406	 019A	 	 	 	NEXTMP:
  407	 019A  83 C3 04	 	 	        ADD     BX,4            ;Next temp descriptor
  408	 019D  81 FB 003E R	 	        CMP     BX,OFFSET DC:TMPH       ;Done yet?
  409	 01A1  72 EE	 	 	        JB      DTSLOOP
  410	 01A3  5B	 	 	        POP     BX
  411	 01A4  C3	 	 	RET:    RET
  412	 	 	 	 	
  413	 	 	 	 	
  414	 	 	 	 	;***  $$DITS - Delete if temporary string
  415	 	 	 	 	;
  416	 	 	 	 	; Inputs:
  417	 	 	 	 	;       BX = Address of string descriptor
  418	 	 	 	 	; Function:
  419	 	 	 	 	;       Check to see if the descriptor is a temporary. If so, delete it.
  420	 	 	 	 	; Outputs:
  421	 	 	 	 	;       None.
  422	 	 	 	 	; Registers:
  423	 	 	 	 	;       Only F affected.
  424	 	 	 	 	
  425	 01A5	 	 	 	$$DITS:
  426	 01A5  E8 0157 R	 	        CALL    $$CFT           ;See if temp string
  427	 01A8  73 FA	 	 	        JNC     RET             ;If not, leave it
  428	 01AA	 	 	 	DELTMP:
  429	 01AA  E8 01FB R	 	        CALL    $$FSS           ;Free the space
  430	 	 	 	 	
  431	 	 	 	 	;***  $$FTH - Free temp header
  432	 	 	 	 	;


STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Page 1-9



  433	 	 	 	 	; Inputs:
  434	 	 	 	 	;       BX = address of temporary string descriptor
  435	 	 	 	 	; Function:
  436	 	 	 	 	;       Attach the header to the list of free temp descriptors
  437	 	 	 	 	; Outputs:
  438	 	 	 	 	;       None.
  439	 	 	 	 	; Registers:
  440	 	 	 	 	;       Only F affected.
  441	 	 	 	 	
  442	 01AD	 	 	 	$$FTH:
  443	 01AD  50	 	 	        PUSH    AX
  444	 01AE  8B C3	 	 	        MOV     AX,BX
  445	 01B0  87 06 0000 R	 	        XCHG    AX,[TMPHDR]     ;Make this one the first free
  446	 01B4  89 07	 	 	        MOV     [BX],AX         ;Set link to former first one
  447	 01B6  C7 47 02 FFFF	 	        MOV     WORD PTR[BX+2],-1  ;Make it easy to see its free
  448	 01BB  58	 	 	        POP     AX
  449	 01BC  C3	 	 	        RET
  450	 	 	 	 	
  451	 	 	 	 	
  452	 	 	 	 	;***  $$RSS - Rob string space
  453	 	 	 	 	;
  454	 	 	 	 	; Inputs:
  455	 	 	 	 	;       BX = length needed.
  456	 	 	 	 	; Function:
  457	 	 	 	 	;       Permanently allocate a chunk of free space. First a major garbage
  458	 	 	 	 	;       collection is performed, then the back end of the free space is
  459	 	 	 	 	;       taken away, never to be returned.
  460	 	 	 	 	; Outputs:
  461	 	 	 	 	;       BX = Address of allocated space
  462	 	 	 	 	; Registers:
  463	 	 	 	 	;       Only BX and F affected.
  464	 	 	 	 	
  465	 01BD	 	 	 	$$RSS:
  466	 01BD  E8 0095 R	 	        CALL    $$MAG           ;Compact string space
  467	 01C0  50	 	 	        PUSH    AX
  468	 01C1  52	 	 	        PUSH    DX
  469	 01C2  43	 	 	        INC     BX              ;Round up if odd
  470	 01C3  80 E3 FE	 	 	        AND     BL,NOT 1        ;And force to word boundary
  471	 01C6  A1 003F R	 	        MOV     AX,[$$SFPT]     ;Get pointer to free space
  472	 01C9  93	 	 	        XCHG    AX,BX
  473	 01CA  8B 17	 	 	        MOV     DX,[BX]         ;Get size of the free space chunk
  474	 01CC  2B D0	 	 	        SUB     DX,AX           ;Allocate our space
  475	 01CE  72 12	 	 	        JB      INSUF           ;Have enough?
  476	 01D0  89 17	 	 	        MOV     [BX],DX         ;Reduce size of free chunk
  477	 01D2  03 DA	 	 	        ADD     BX,DX           ;Point to end of free chunk
  478	 01D4  43	 	 	        INC     BX              ;Point to first byte after free chunk
  479	 01D5  C7 07 FFFF	 	        MOV     WORD PTR[BX],-1 ;Flag as end of string space
  480	 01D9  43	 	 	        INC     BX
  481	 01DA  89 1E 0043 R	 	        MOV     [STRLWA],BX     ;Save pointer to end
  482	 01DE  43	 	 	        INC     BX              ;Point to start of allocated space
  483	 01DF  5A	 	 	        POP     DX
  484	 01E0  58	 	 	        POP     AX
  485	 01E1  C3	 	 	        RET
  486	 	 	 	 	


STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Page 1-10



  487	 01E2	 	 	 	INSUF:
  488	 	 	 	 	;Not enough free space to satisfy request
  489	 01E2  E9 0000 E	 	        JMP     $ERC_OM         ;Clean stack and report out of memory
  490	 	 	 	 	
  491	 	 	 	 	
  492	 	 	 	 	;***  $$CTSD - Create temp from string descriptor
  493	 	 	 	 	;
  494	 	 	 	 	; Inputs:
  495	 	 	 	 	;       BX = Address of string descriptor
  496	 	 	 	 	;       CX = Starting OFFSET DC:within string
  497	 	 	 	 	;       DX =Length
  498	 	 	 	 	; Function:
  499	 	 	 	 	;       Create a temporary string and copy the specified portion of the given
  500	 	 	 	 	;       string into it. The given string is deleted if it is a temp.
  501	 	 	 	 	; Outputs:
  502	 	 	 	 	;       BX = Address of temp string descriptor
  503	 	 	 	 	; Registers:
  504	 	 	 	 	;       Only BX and F affected.
  505	 	 	 	 	
  506	 01E5	 	 	 	$$CTSD:
  507	 01E5  52	 	 	        PUSH    DX
  508	 01E6  53	 	 	        PUSH    BX
  509	 01E7  8B 5F 02	 	 	        MOV     BX,[BX+2]       ;Get pointer to data
  510	 01EA  03 D9	 	 	        ADD     BX,CX           ;Adjust with offset
  511	 01EC  87 DA	 	 	        XCHG    BX,DX           ;Set up call
  512	 01EE  E8 0176 R	 	        CALL    $$CTS           ;Allocate space and move string in
  513	 01F1  8B D3	 	 	        MOV     DX,BX           ;Save result momentarily
  514	 01F3  5B	 	 	        POP     BX              ;Address of source string descriptor
  515	 01F4  E8 01A5 R	 	        CALL    $$DITS          ;Delete if temp
  516	 01F7  8B DA	 	 	        MOV     BX,DX           ;Get result back in BX
  517	 01F9  5A	 	 	        POP     DX
  518	 01FA  C3	 	 	        RET
  519	 	 	 	 	
  520	 	 	 	 	
  521	 	 	 	 	;***  $$FSS - Free string space
  522	 	 	 	 	;
  523	 	 	 	 	; Inputs:
  524	 	 	 	 	;       BX = Address of string descriptor
  525	 	 	 	 	; Function:
  526	 	 	 	 	;       Free the space pointed to by the string descriptor
  527	 	 	 	 	; Outputs:
  528	 	 	 	 	;       None.
  529	 	 	 	 	; Registers:
  530	 	 	 	 	;       Only F affected.
  531	 	 	 	 	
  532	 01FB	 	 	 	$$FSS:
  533	 01FB  50	 	 	        PUSH    AX
  534	 01FC  53	 	 	        PUSH    BX
  535	 01FD  8B 07	 	 	        MOV     AX,[BX]         ;Get length of sting to free
  536	 01FF  8B 5F 02	 	 	        MOV     BX,[BX+2]       ;Get pointer to string data
  537	 	 	 	 	;See if string is in the managed string area
  538	 0202  3B 1E 0041 R	 	        CMP     BX,[STRFWA]
  539	 0206  72 13	 	 	        JB      NOFREE
  540	 0208  3B 1E 0043 R	 	        CMP     BX,[STRLWA]


STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Page 1-11



  541	 020C  77 0D	 	 	        JA      NOFREE
  542	 	 	 	 	;Free the space
  543	 020E  40	 	 	        INC     AX              ;Round up if odd
  544	 020F  0C 01	 	 	        OR      AL,1            ;And set free bit
  545	 0211  87 47 FE	 	 	        XCHG    AX,[BX-2]       ;Get backpointer and set free length
  546	 0214  5B	 	 	        POP     BX
  547	 0215  3B C3	 	 	        CMP     AX,BX           ;Check backpointer
  548	 0217  75 05	 	 	        JNZ     FSSERR          ;Scream if they don't match
  549	 0219  58	 	 	        POP     AX
  550	 021A  C3	 	 	        RET
  551	 	 	 	 	
  552	 021B	 	 	 	NOFREE:
  553	 	 	 	 	;Not part of managed string space, so forget it. Ho hum.
  554	 021B  5B	 	 	        POP     BX
  555	 021C  58	 	 	        POP     AX
  556	 021D  C3	 	 	        RET
  557	 	 	 	 	
  558	 021E	 	 	 	FSSERR:
  559	 021E  E8 00F9 R	 	        CALL    SSCERR          ;String space corrupt error
  560	 0221  E8 0000 E	 	        CALL    $$TCR
  561	 0224  E9 0000 E	 	        JMP     $ABEND
  562	 	 	 	 	
  563	 	 	 	 	
  564	 	 	 	 	;***  $$PUTZ - Put zero at end of string
  565	 	 	 	 	;
  566	 	 	 	 	; Inputs:
  567	 	 	 	 	;       BX = Address of string descriptor
  568	 	 	 	 	; Function:
  569	 	 	 	 	;       Make into a string with a zero byte on the end. If length is presently
  570	 	 	 	 	;       odd, just jam a zero into the extra byte. If even, create a temp
  571	 	 	 	 	;       one byte longer and put the zero there.
  572	 	 	 	 	; Outputs:
  573	 	 	 	 	;       BX = Address of string descriptor
  574	 	 	 	 	; Registers:
  575	 	 	 	 	;       Only BX and F affected.
  576	 	 	 	 	
  577	 0227	 	 	 	$$PUTZ:
  578	 0227  52	 	 	        PUSH    DX
  579	 0228  8B 17	 	 	        MOV     DX,[BX]
  580	 022A  F6 C2 01	 	 	        TEST    DL,1            ;Is string length odd?
  581	 022D  75 09	 	 	        JNZ     PATCHEND        ;If so, no copying needed
  582	 022F  51	 	 	        PUSH    CX
  583	 0230  33 C9	 	 	        XOR     CX,CX
  584	 0232  42	 	 	        INC     DX
  585	 0233  E8 01E5 R	 	        CALL    $$CTSD
  586	 0236  4A	 	 	        DEC     DX
  587	 0237  59	 	 	        POP     CX
  588	 0238	 	 	 	PATCHEND:
  589	 0238  53	 	 	        PUSH    BX
  590	 0239  8B 5F 02	 	 	        MOV     BX,[BX+2]       ;Get pointer to data
  591	 023C  03 DA	 	 	        ADD     BX,DX
  592	 023E  C6 07 00	 	 	        MOV     BYTE PTR[BX],0
  593	 0241  5B	 	 	        POP     BX
  594	 0242  5A	 	 	        POP     DX


STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Page 1-12



  595	 0243  C3	 	 	        RET
  596	 	 	 	 	
  597	 	 	 	 	
  598	 	 	 	 	;***  $$STSU - Set up string space
  599	 	 	 	 	;
  600	 	 	 	 	; Inputs:
  601	 	 	 	 	;       None.
  602	 	 	 	 	; Function:
  603	 	 	 	 	;       Initialize all conditions needed for strings
  604	 	 	 	 	; Outputs:
  605	 	 	 	 	;       None.
  606	 	 	 	 	; Registers:
  607	 	 	 	 	;       All destroyed.
  608	 	 	 	 	
  609	 0244	 	 	 	$$STSU:
  610	 0244  8B 3E 0041 R	 	        MOV     DI,[$$SFWA]     ;Must be even
  611	 0248  89 3E 003F R	 	        MOV     [$$SFPT],DI
  612	 024C  A1 0043 R	 	        MOV     AX,[$$SLWA]     ;Last available byte
  613	 024F  40	 	 	        INC     AX
  614	 0250  24 FE	 	 	        AND     AL,NOT 1        ;Force to word boundary
  615	 0252  2B C7	 	 	        SUB     AX,DI           ;Length of free space, bytes
  616	 0254  2D 0003	 	 	        SUB     AX,3            ;Set LSB to flag free
  617	 0257  AB	 	 	        STOSW                   ;Store header
  618	 0258  03 F8	 	 	        ADD     DI,AX
  619	 025A  C7 45 FF FFFF	 	        MOV     WORD PTR[DI-1],-1  ;Put flag at end of free space
  620	 025F  B9 000F	 	 	        MOV     CX,15           ;Number of string temporaries
  621	 0262  BF 0002 R	 	        MOV     DI,OFFSET DC:T1 ;First temp
  622	 0265  89 3E 0000 R	 	        MOV     [TMPHDR],DI
  623	 0269  BB FFFF	 	 	        MOV     BX,-1           ;Flag for each temp indicates free
  624	 026C  B8 0006 R	 	        MOV     AX,OFFSET DC:T2
  625	 026F	 	 	 	LINKTMP:
  626	 026F  AB	 	 	        STOSW                   ;Link to next temp
  627	 0270  93	 	 	        XCHG    AX,BX
  628	 0271  AB	 	 	        STOSW                   ;Store free flag
  629	 0272  93	 	 	        XCHG    AX,BX
  630	 0273  05 0004	 	 	        ADD     AX,4            ;4 bytes per temp
  631	 0276  E2 F7	 	 	        LOOP    LINKTMP
  632	 0278  C7 45 FC 0000	 	        MOV     WORD PTR[DI-4],0 ;Last temp must point to nul
  633	 027D  C6 06 003E R 00	 	        MOV     [ALCTRY],0      ;No allocation attempts yet
  634	 0282  C3	 	 	        RET
  635	 	 	 	 	
  636	 0283	 	 	 	CODE    ENDS
  637	 	 	 	 	        END













STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0283	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  CONST. . . . . . . . . . . . . .	0006	WORD  	PUBLIC	'CONST'
  DATA . . . . . . . . . . . . . .	0045	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ALCTRY . . . . . . . . . . . . .	L BYTE 	003E	DATA
ATSNUL . . . . . . . . . . . . .	L NEAR 	014D	CODE
CATENATE . . . . . . . . . . . .	L NEAR 	0082	CODE
CHKSTR . . . . . . . . . . . . .	L NEAR 	0018	CODE
DELTMP . . . . . . . . . . . . .	L NEAR 	01AA	CODE
DTSLOOP. . . . . . . . . . . . .	L NEAR 	0191	CODE
EXACT. . . . . . . . . . . . . .	L NEAR 	0034	CODE
EXITMAG. . . . . . . . . . . . .	L NEAR 	00CE	CODE
EXITMIG. . . . . . . . . . . . .	L NEAR 	0054	CODE
FORWSTR. . . . . . . . . . . . .	L NEAR 	0016	CODE
FRESTR . . . . . . . . . . . . .	L NEAR 	006C	CODE
FSSERR . . . . . . . . . . . . .	L NEAR 	021E	CODE
INPLACE. . . . . . . . . . . . .	L NEAR 	00C8	CODE
INSUF. . . . . . . . . . . . . .	L NEAR 	01E2	CODE
LINKTMP. . . . . . . . . . . . .	L NEAR 	026F	CODE
LOOKSTR. . . . . . . . . . . . .	L NEAR 	0010	CODE
MAGERR . . . . . . . . . . . . .	L NEAR 	00E1	CODE
MAGFRE . . . . . . . . . . . . .	L NEAR 	00A2	CODE
MAGNXT . . . . . . . . . . . . .	L NEAR 	00A3	CODE
MAGSTR . . . . . . . . . . . . .	L NEAR 	00A5	CODE
NEEDMAJ. . . . . . . . . . . . .	L NEAR 	0046	CODE
NEXSTR . . . . . . . . . . . . .	L NEAR 	003B	CODE
NEXTMP . . . . . . . . . . . . .	L NEAR 	019A	CODE
NOFREE . . . . . . . . . . . . .	L NEAR 	021B	CODE
NONLEF . . . . . . . . . . . . .	L NEAR 	0057	CODE
NULDES . . . . . . . . . . . . .	L WORD 	0002	CONST	Global
NULSTR . . . . . . . . . . . . .	L WORD 	0000	CONST
PATCHEND . . . . . . . . . . . .	L NEAR 	0238	CODE
RET. . . . . . . . . . . . . . .	L NEAR 	01A4	CODE
SAVSTRT. . . . . . . . . . . . .	L NEAR 	00D8	CODE
SETUSED. . . . . . . . . . . . .	L NEAR 	006A	CODE
SSCERR . . . . . . . . . . . . .	L NEAR 	00F9	CODE
STRFWA . . . . . . . . . . . . .	L WORD 	0041	DATA
STRLWA . . . . . . . . . . . . .	L WORD 	0043	DATA
T1 . . . . . . . . . . . . . . .	L WORD 	0002	DATA
T10. . . . . . . . . . . . . . .	L WORD 	0026	DATA
T11. . . . . . . . . . . . . . .	L WORD 	002A	DATA
T12. . . . . . . . . . . . . . .	L WORD 	002E	DATA
T13. . . . . . . . . . . . . . .	L WORD 	0032	DATA
T14. . . . . . . . . . . . . . .	L WORD 	0036	DATA
T15. . . . . . . . . . . . . . .	L WORD 	003A	DATA


STRUTL - String utilities                                Macro-86 %1(12)   1:9:2  13-Nov-81    Symbols-2



T2 . . . . . . . . . . . . . . .	L WORD 	0006	DATA
T3 . . . . . . . . . . . . . . .	L WORD 	000A	DATA
T4 . . . . . . . . . . . . . . .	L WORD 	000E	DATA
T5 . . . . . . . . . . . . . . .	L WORD 	0012	DATA
T6 . . . . . . . . . . . . . . .	L WORD 	0016	DATA
T7 . . . . . . . . . . . . . . .	L WORD 	001A	DATA
T8 . . . . . . . . . . . . . . .	L WORD 	001E	DATA
T9 . . . . . . . . . . . . . . .	L WORD 	0022	DATA
TEMPOV . . . . . . . . . . . . .	L NEAR 	0154	CODE
TMPH . . . . . . . . . . . . . .	L WORD 	003E	DATA
TMPHDR . . . . . . . . . . . . .	L WORD 	0000	DATA
TMPL . . . . . . . . . . . . . .	L WORD 	0002	DATA
USEDSTR. . . . . . . . . . . . .	L NEAR 	008B	CODE
$$ATS. . . . . . . . . . . . . .	L NEAR 	0125	CODE	Global
$$CFT. . . . . . . . . . . . . .	L NEAR 	0157	CODE	Global
$$CSL. . . . . . . . . . . . . .	L NEAR 	0163	CODE	Global
$$CTS. . . . . . . . . . . . . .	L NEAR 	0176	CODE	Global
$$CTSD . . . . . . . . . . . . .	L NEAR 	01E5	CODE	Global
$$DITS . . . . . . . . . . . . .	L NEAR 	01A5	CODE	Global
$$DTS. . . . . . . . . . . . . .	L NEAR 	018D	CODE	Global
$$FSS. . . . . . . . . . . . . .	L NEAR 	01FB	CODE	Global
$$FTH. . . . . . . . . . . . . .	L NEAR 	01AD	CODE	Global
$$GSTR . . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$$MAG. . . . . . . . . . . . . .	L NEAR 	0095	CODE	Global
$$PUTZ . . . . . . . . . . . . .	L NEAR 	0227	CODE	Global
$$RSS. . . . . . . . . . . . . .	L NEAR 	01BD	CODE	Global
$$SFPT . . . . . . . . . . . . .	L WORD 	003F	DATA	Global
$$SFWA . . . . . . . . . . . . .	L WORD 	0041	DATA	Global
$$SLWA . . . . . . . . . . . . .	L WORD 	0043	DATA	Global
$$STSU . . . . . . . . . . . . .	L NEAR 	0244	CODE	Global
$$TCR. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ABEND . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_OM. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_OS. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_ST. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TYPTX . . . . . . . . . . . . .	L NEAR 	0000	CODE	External

Warning Severe
Errors	Errors 
0	0
















