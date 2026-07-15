IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 1-1



1	 	 	 	 	        TITLE   IODISK - Disk I/O Drivers for BASCOM-86
2	 	 	 	 	
3	 	 	 	 	;       This module contains the disk operating system interface
4	 	 	 	 	;       for the device I/O independent package.  It also includes
5	 	 	 	 	;       other operating system features of BASIC.
6	 	 	 	 	
7	                             C	        INCLUDE TABMAC.INC
8	                             C	;       Special Table Generation Macros
9	                             C	
10	                             C	ENTORG  MACRO   First_entry
11	                             C	        .XCREF
12	                             C	___ZZZ=         First_entry
13	                             C	        .CREF
14	                             C	        ENDM
15	                             C	
16	                             C	
17	                             C	ENT     MACRO   Lab,Incr
18	                             C	Lab=            ___ZZZ
19	                             C	        .XCREF
20	                             C	___ZZZ=         ___ZZZ+Incr
21	                             C	        .CREF
22	                             C	        ENDM
23	                             C	
24	                             C	
25	                             C	ENTI    MACRO   Incr
26	                             C	        .XCREF
27	                             C	___ZZZ=         ___ZZZ+Incr
28	                             C	        .CREF
29	                             C	        ENDM
30	                             C	
31	 	 	 	 	
32	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
33	 	 	 	 	
34	                             C	        INCLUDE DEVDEF.INC






















IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 1-2



35	                             C	        PAGE
36	                             C	
37	                             C	;       DEVDEF.INC - Device Independent I/O Definitions
38	                             C	
39	                             C	        INCLUDE SYSTEM.INC
40	                             C	;       Operating System Selection
41	                             C	
42	 = 0000                      C	_IBM_=                  0
43	                             C	
44	 = 0001                      C	_MSDOS_=                1
45	 = 0000                      C	_CPM_=                  0
46	                             C	
47	                             C	;       Overrides
48	                             C	
49	 = 0001                      C	_MSDOS_=                _MSDOS_ or _IBM_
50	                             C	
51	                             C	if1
52	                             C	if      _CPM_
53	                             C	        %OUT    !   CP/M-86 Version
54	                             C	endif
55	                             C	if      _MSDOS_
56	                             C	        %OUT    !   MSDOS Version
57	                             C	endif
58	                             C	if      _IBM_
59	                             C	        %OUT    !     IBM Personal Computer
60	                             C	endif
61	                             C	
62	                             C	if      _MSDOS_+_CPM_ ne 1
63	                             C	        %OUT    #####################  Error - Bad Operating System Selection
64	                             C	
65	                             C	        error
66	                             C	endif
67	                             C	endif
68	                             C	






















IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 1-3



69	                             C	        PAGE
70	                             C	
71	                             C	DEVNAM  MACRO
72	                             C	        DEVMAC  KYBD
73	                             C	        DEVMAC  SCRN
74	                             C	if      _IBM_
75	                             C	        DEVMAC  CAS1
76	                             C	        DEVMAC  COM1
77	                             C	        DEVMAC  COM2
78	                             C	endif
79	                             C	        DEVMAC  LPT1
80	                             C	if      _IBM_
81	                             C	        DEVMAC  LPT2
82	                             C	        DEVMAC  LPT3
83	                             C	endif
84	                             C	        ENDM
85	                             C	
86	 = FFFF                      C	___DEV=         -1
87	                             C	
88	                             C	DEVMAC  MACRO   ARG
89	                             C	DN_&ARG=        ___DEV
90	                             C	.xcref
91	                             C	___DEV=         ___DEV-1
92	                             C	.cref
93	                             C	        ENDM
94	                             C	
95	                             C	        DEVNAM
96	                             C	
97	 = 0008                      C	LAST_DEVICE_OFFSET=     -2*___DEV       ;All devices have lower offsets



























IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 1-4



98	                             C	        PAGE
99	                             C	
100	                             C	DSPNAM  MACRO
101	                             C	        DSPMAC  EOF                     ;EOF function
102	                             C	        DSPMAC  LOC                     ;LOC function
103	                             C	        DSPMAC  LOF                     ;LOF function
104	                             C	;       DSPMAC  POS                     ;POS function
105	                             C	        DSPMAC  CLOSE                   ;CLOSE statement
106	                             C	        DSPMAC  WIDTH                   ;WIDTH statement
107	                             C	        DSPMAC  RANDIO                  ;GET/PUT statements
108	                             C	        DSPMAC  OPEN                    ;OPEN statement
109	                             C	        DSPMAC  BAKC                    ;Backup character
110	                             C	        DSPMAC  SINP                    ;Serial input
111	                             C	        DSPMAC  SOUT                    ;Serial output
112	                             C	        DSPMAC  GPOS                    ;Get current position
113	                             C	        DSPMAC  GWID                    ;Get current width
114	                             C	        ENDM
115	                             C	
116	                             C	
117	                             C	;       Device Function Dispatch Table Offsets
118	                             C	
119	                             C	
120	                             C	DSPMAC  MACRO   func
121	                             C	ENT     DV_&func,2
122	                             C	        ENDM
123	                             C	
124	                             C	
125	                             C	ENTORG  0
126	                             C	        DSPNAM
127	                             C	ENT     DV_TABLEN,0
128	                             C	

























IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 1-5



129	                             C	        PAGE
130	                             C	
131	                             C	;       File Mode Definitions
132	                             C	
133	 = 0001                      C	MD_SQI          EQU     1
134	 = 0002                      C	MD_SQO          EQU     2
135	 = 0004                      C	MD_RND          EQU     4
136	 = 0004                      C	MD_FIL          EQU     4
137	 = 0008                      C	MD_APP          EQU     8
138	 = 0010                      C	MD_KIL          EQU     16
139	 = 0020                      C	MD_IBM          EQU     32
140	 = 0040                      C	MD_USR          EQU     64
141	 = 0080                      C	MD_BIN          EQU     128
142	                             C	
143	                             C	
144	                             C	;       Operating System dependent field sizes
145	                             C	
146	 = 001A                      C	EOFCHR=                 'Z' and 1fh
147	                             C	
148	 = 0026                      C	FILNAML=                38              ;Length of $FILNAM
149	 = 000B                      C	FILNAM_LENGTH=          11              ;Actual length of name (8+3)
150	                             C	
151	 = 0026                      C	FCB_LENGTH=             38              ;38 byte FCBs
152	 = 0080                      C	REC_LENGTH=             128             ;128 byte sectors
153	                             C	































IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 1-6



154	                             C	        PAGE
155	                             C	
156	                             C	;-----  Basic Interpreter style File Data Block  -----
157	                             C	
158	                             C	;       Link block offsets
159	                             C	
160	 = FFFA                      C	BL_SIZE=        -6                      ;Link block size (2 bytes of misc)
161	 = FFFB                      C	  FB_NUM=       -5                      ;  File number
162	 = FFFC                      C	BL_LEN=         -4                      ;Block size
163	 = FFFE                      C	BL_LNK=         -2                      ;Block link
164	                             C	
165	                             C	;       File Data Block offsets
166	                             C	
167	                             C	FILE_DATA_BLOCK STRUC
168	                             C	
169	 0000  ??                    C	  FD_MODE       DB      ?               ;File mode of open
170	 0001     26 [               C	  FD_FCB        DB      FCB_LENGTH DUP (?)  ;FCB area
171	                ??           C	
172	                    ]        C	
173	                             C	
174	 0027  ????                  C	  FD_CURLOC     DW      ?               ;Current record number
175	 0029  ??                    C	  FD_ORNOFS     DB      ?               ;Byte count in sector
176	 002A  ??                    C	  FD_NMLOFS     DB      ?               ;Bytes left in input buffer
177	 002B     03 [               C	                DB      3 DUP (?)       ;Unused
178	                ??           C	
179	                    ]        C	
180	                             C	
181	 002E  ??                    C	  FD_DEVICE     DB      ?               ;Device number
182	 002F  ??                    C	  FD_WIDTH      DB      ?               ;File width
183	 0030  ??                    C	  FD_POS        DB      ?               ;Current file position
184	 0031  ??                    C	  FD_FLAGS      DB      ?               ;Used for load and save
185	 0032  ??                    C	  FD_OUTPOS     DB      ?               ;Output position for tab expansion
186	 0033     80 [               C	  FD_BUFFER     DB      REC_LENGTH DUP (?)  ;File record buffer
187	                ??           C	
188	                    ]        C	
189	                             C	
190	                             C	
191	                             C	;       5.0 Variable Record Information
192	                             C	
193	 00B3  ????                  C	  FR_VRECL      DW      ?               ;Variable record length
194	 00B5  ????                  C	  FR_PHYREC     DW      ?               ;Current physical record number
195	 00B7  ????                  C	  FR_LOGREC     DW      ?               ;Current logical record number
196	 00B9  ??                    C	                DB      ?               ;Future use
197	 00BA  ????                  C	  FR_OUTPOS     DW      ?               ;Output position for sequential I/O
198	 00BC     01 [               C	  FR_FIELD      DB      1 DUP (?)       ;Field buffer
199	                ??           C	
200	                    ]        C	
201	                             C	
202	                             C	
203	 00BD                        C	FILE_DATA_BLOCK ENDS
204	                             C	
205	                             C	
206	                             C	;       End of DEVDEF.INC
207	 	 	 	 	


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 1-7



208	 	 	 	 	        PAGE
209	 	 	 	 	
210	 	 	 	 	;       Operating System Equates and Macros
211	 	 	 	 	
212	 	 	 	 	
213	 	 	 	 	;       MSDOS/CPM Operating System Function Codes
214	 	 	 	 	
215	 = 000D	 	 	 	C_REST=         13
216	 = 000E	 	 	 	C_SDRV=         14
217	 = 000F	 	 	 	C_OPEN=         15
218	 = 0010	 	 	 	C_CLOS=         16
219	 = 0011	 	 	 	C_SEAR=         17
220	 = 0013	 	 	 	C_DELE=         19
221	 = 0014	 	 	 	C_READ=         20
222	 = 0015	 	 	 	C_WRIT=         21
223	 = 0016	 	 	 	C_MAKE=         22
224	 = 0017	 	 	 	C_RENA=         23
225	 = 0019	 	 	 	C_GDRV=         25
226	 = 001A	 	 	 	C_BUFF=         26
227	 = 0021	 	 	 	C_RNDR=         33
228	 = 0022	 	 	 	C_RNDW=         34
229	 	 	 	 	
230	 	 	 	 	
231	 	 	 	 	;       MSDOS/CPM File Control Block Offsets
232	 	 	 	 	
233	 = 0001	 	 	 	FCB_FN=         1
234	 = 0009	 	 	 	FCB_FT=         9
235	 = 000C	 	 	 	FCB_EX=         12
236	 = 000E	 	 	 	FCB_RSIZ=       14                      ;MSDOS
237	 = 000F	 	 	 	FCB_RC=         15                      ;MSDOS
238	 = 0010	 	 	 	FCB_FSIZ=       16                      ;MSDOS
239	 = 0020	 	 	 	FCB_NR=         32
240	 = 0021	 	 	 	FCB_RN=         33
241	 	 	 	 	
242	 	 	 	 	
243	 	 	 	 	;       MSDOS Call Macro
244	 	 	 	 	
245	 	 	 	 	if      _MSDOS_
246	 	 	 	 	CALLOS  MACRO   func
247	 	 	 	 	IFNB    <func>
248	 	 	 	 	        MOV     AH,func
249	 	 	 	 	ENDIF
250	 	 	 	 	        INT     33
251	 	 	 	 	        ENDM
252	 	 	 	 	endif
253	 	 	 	 	










IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 1-8



254	 	 	 	 	        PAGE
255	 	 	 	 	
256	 	 	 	 	;       External Data Variables
257	 	 	 	 	
258	 	 	 	 	        EXTRN   $FILNAM:BYTE, $FILNM2:BYTE, $FILMOD:BYTE
259	 	 	 	 	        EXTRN   $FILPT:WORD
260	 	 	 	 	        EXTRN   $$SPSV:WORD
261	 	 	 	 	
262	 	 	 	 	
263	 	 	 	 	;       Public Data Variables
264	 	 	 	 	
265	 	 	 	 	if      _CPM_
266	 	 	 	 	        PUBLIC  $DIRTMP
267	 	 	 	 	$DIRTMP         DB      REC_LENGTH DUP (?)       ;Temporary buffer
268	 	 	 	 	endif
269	 	 	 	 	
270	 	 	 	 	
271	 	 	 	 	;       Local Data Variables
272	 	 	 	 	
273	 0000  ????	 	 	RECORD          DW      ?                        ;Current record number
274	 0002  ????	 	 	LBUFF           DW      ?                        ;Logical buffer address
275	 0004  ????	 	 	PBUFF           DW      ?                        ;Physical buffer address
276	 	 	 	 	
277	 0006	 	 	 	DATA    ENDS
278	 	 	 	 	
279	 	 	 	 	DC      GROUP   DATA






























IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-1



280	 	 	 	 	
281	 	 	 	 	
282	 0000	 	 	 	CODE    SEGMENT BYTE PUBLIC 'CODE'
283	 	 	 	 	
284	 	 	 	 	        ASSUME  CS:CODE, DS:DC, ES:DC
285	 	 	 	 	
286	 	 	 	 	;       Compiler Generated Entries
287	 	 	 	 	
288	 	 	 	 	        PUBLIC  $DKK,$DKR,$FL0,$FIL,$RS2,$ZZ1
289	 	 	 	 	
290	 	 	 	 	
291	 	 	 	 	;       Run-time entries
292	 	 	 	 	
293	 	 	 	 	        PUBLIC  $D_DISK
294	 	 	 	 	
295	 	 	 	 	
296	 	 	 	 	;       Run-time externals
297	 	 	 	 	
298	 	 	 	 	        EXTRN   $$DITS:NEAR, $SAVREG:NEAR
299	 	 	 	 	        EXTRN   $FBALC:NEAR, $FBDEA:NEAR
300	 	 	 	 	        EXTRN   $SCANF:NEAR, $CLOSF:NEAR, $DEVOPN:NEAR
301	 	 	 	 	        EXTRN   $$WCHT:NEAR, $$TCR:NEAR
302	 	 	 	 	        EXTRN   $TTY_GPOS:NEAR, $TTY_GWID:NEAR
303	 	 	 	 	
304	 	 	 	 	        EXTRN   $ERC_FC:NEAR
305	 	 	 	 	        EXTRN   $ERC_BFM:NEAR
306	 	 	 	 	        EXTRN   $ERC_BFN:NEAR
307	 	 	 	 	        EXTRN   $ERC_BRN:NEAR
308	 	 	 	 	        EXTRN   $ERC_DFL:NEAR
309	 	 	 	 	        EXTRN   $ERC_FAE:NEAR
310	 	 	 	 	        EXTRN   $ERC_FAO:NEAR
311	 	 	 	 	        EXTRN   $ERC_FNF:NEAR
312	 	 	 	 	        EXTRN   $ERC_FOV:NEAR
313	 	 	 	 	        EXTRN   $ERC_IOE:NEAR
314	 	 	 	 	        EXTRN   $ERC_TMF:NEAR
315	 	 	 	 	
316	 	 	 	 	if      _MSDOS_
317	 	 	 	 	        EXTRN   $DNORM:NEAR
318	 	 	 	 	endif
319	 	 	 	 	
















IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-2



320	 	 	 	 	        PAGE
321	 	 	 	 	
322	 	 	 	 	;       Device Independent Disk Interface
323	 	 	 	 	
324	 	 	 	 	DSPMAC  MACRO   func
325	 	 	 	 	        DW      DISK_&func
326	 	 	 	 	        ENDM
327	 	 	 	 	
328	 0000	 	 	 	$D_DISK:
329	 	 	 	 	        DSPNAM
330	 0000  003D R                 +	        DW      DISK_EOF
331	 0002  006D R                 +	        DW      DISK_LOC
332	 0004  007A R                 +	        DW      DISK_LOF
333	 0006  0018 R                 +	        DW      DISK_CLOSE
334	 0008  0097 R                 +	        DW      DISK_WIDTH
335	 000A  0245 R                 +	        DW      DISK_RANDIO
336	 000C  0145 R                 +	        DW      DISK_OPEN
337	 000E  009B R                 +	        DW      DISK_BAKC
338	 0010  00D7 R                 +	        DW      DISK_SINP
339	 0012  0109 R                 +	        DW      DISK_SOUT
340	 0014  009F R                 +	        DW      DISK_GPOS
341	 0016  00A3 R                 +	        DW      DISK_GWID
342	 	 	 	 	

































IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-3



343	 	 	 	 	        PAGE
344	 	 	 	 	
345	 0018	 	 	 	devio_disk      PROC    NEAR
346	 	 	 	 	
347	 	 	 	 	
348	 0018	 	 	 	DISK_CLOSE:
349	 0018  80 3C 02	 	 	        CMP     [SI].FD_MODE,MD_SQO
350	 001B  75 0E	 	 	        JNE     noforc                  ;Don't dump buffer
351	 	 	 	 	
352	 001D  B0 1A	 	 	        MOV     AL,EOFCHR
353	 001F  E8 0109 R	 	        CALL    DISK_SOUT               ;Write EOF character
354	 0022  80 7C 29 00	 	        CMP     [SI].FD_ORNOFS,0
355	 0026  74 03	 	 	        JE      noforc                  ;Buffer already dumped
356	 	 	 	 	
357	 0028  E8 035D R	 	        CALL    WRITE_SECTOR            ;Write sector
358	 	 	 	 	
359	 002B  51	 	 	noforc: PUSH    CX
360	 002C  52	 	 	        PUSH    DX
361	 002D  8D 54 01	 	 	        LEA     DX,[SI].FD_FCB
362	 0030  E8 038B R	 	        CALL    SETBUF                  ;Set buffer address
363	 	 	 	 	        CALLOS  C_CLOS                  ;Close file
364	 0033  B4 10                  +	        MOV     AH,C_CLOS
365	 0035  CD 21                  +	        INT     33
366	 0037  E8 0000 E	 	        CALL    $FBDEA                  ;Deallocate file buffer
367	 003A  5A	 	 	        POP     DX
368	 003B  59	 	 	        POP     CX
369	 003C  C3	 	 	        RET
370	 	 	 	 	
371	 	 	 	 	
372	 	 	 	 	
373	 003D	 	 	 	DISK_EOF:
374	 003D  80 3C 02	 	 	        CMP     [SI].FD_MODE,MD_SQO
375	 0040  74 28	 	 	        JE      ercbfm                  ;Not for output files
376	 	 	 	 	
377	 0042  80 7C 29 00	 	ornchk: CMP     [SI].FD_ORNOFS,0
378	 0046  74 1B	 	 	        JE      waseof
379	 	 	 	 	
380	 0048  33 DB	 	 	        XOR     BX,BX
381	 004A  80 3C 04	 	 	        CMP     [SI].FD_MODE,MD_RND
382	 004D  74 1A	 	 	        JE      eofret                  ;Not end of file
383	 	 	 	 	
384	 004F  38 5C 2A	 	 	        CMP     [SI].FD_NMLOFS,BL       ;(BX) is 0
385	 0052  75 05	 	 	        JNE     chkctz                  ;Still characters in teh buffer
386	 	 	 	 	
387	 0054  E8 0333 R	 	        CALL    READ_SECTOR             ;Read next sector
388	 0057  EB E9	 	 	        JMP     ornchk
389	 	 	 	 	
390	 0059  BB 0080	 	 	chkctz: MOV     BX,REC_LENGTH
391	 005C  2A 5C 2A	 	 	        SUB     BL,[SI].FD_NMLOFS       ;(BX) = character offset
392	 005F  80 78 33 1A	 	        CMP     [SI+BX].FD_BUFFER,EOFCHR
393	 	 	 	 	
394	 0063  BB 0000	 	 	waseof: MOV     BX,0                    ;(BX) = not end of file
395	 0066  75 01	 	 	        JNE     eofret
396	 0068  4B	 	 	        DEC     BX                      ;(BX) = -1 if end of file


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-4



397	 0069  C3	 	 	eofret: RET
398	 	 	 	 	
399	 006A  E9 0000 E	 	ercbfm: JMP     $ERC_BFM
400	 	 	 	 	
401	 006D	 	 	 	DISK_LOC:
402	 006D  80 3C 04	 	 	        CMP     [SI].FD_MODE,MD_RND
403	 0070  8B 5C 27	 	 	        MOV     BX,[SI].FD_CURLOC       ;Use CURLOC for sequential
404	 0073  75 04	 	 	        JNE     loc1
405	 0075  8B 9C 00B7	 	        MOV     BX,[SI].FR_LOGREC       ;Use LOGREC for random
406	 0079  C3	 	 	loc1:   RET
407	 	 	 	 	
408	 	 	 	 	
409	 	 	 	 	
410	 007A	 	 	 	DISK_LOF:
411	 007A  51	 	 	        PUSH    CX
412	 007B  52	 	 	        PUSH    DX
413	 007C  53	 	 	        PUSH    BX
414	 007D  8B 54 11	 	 	        MOV     DX,WORD PTR [SI].FD_FCB+FCB_FSIZ ;Get length of file
415	 0080  8B 4C 13	 	 	        MOV     CX,WORD PTR [SI].FD_FCB+FCB_FSIZ+2
416	 0083  33 DB	 	 	        XOR     BX,BX
417	 0085  33 FF	 	 	        XOR     DI,DI
418	 0087  B8 C000	 	 	        MOV     AX,(64+80h)*100h                ;(AX) = (exp+128,sign)
419	 008A  E8 0000 E	 	        CALL    $DNORM                          ;Normalize as double
420	 008D  5B	 	 	        POP     BX
421	 008E  5A	 	 	        POP     DX
422	 008F  59	 	 	        POP     CX
423	 0090  C3	 	 	        RET
424	 	 	 	 	
425	 	 	 	 	
426	 	 	 	 	
427	 0091	 	 	 	DISK_POS:
428	 0091  33 DB	 	 	        XOR     BX,BX
429	 0093  8A 5C 32	 	 	        MOV     BL,[SI].FD_OUTPOS       ;(BX) = current file position
430	 0096  C3	 	 	        RET
431	 	 	 	 	
432	 	 	 	 	
433	 	 	 	 	
434	 0097	 	 	 	DISK_WIDTH:
435	 0097  88 54 2F	 	 	        MOV     [SI].FD_WIDTH,DL        ;Set file width
436	 009A  C3	 	 	        RET
437	 	 	 	 	















IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-5



438	 	 	 	 	        PAGE
439	 	 	 	 	
440	 009B	 	 	 	DISK_BAKC:
441	 009B  FE 44 2A	 	 	        INC     [SI].FD_NMLOFS          ;Backup 1 character
442	 009E  C3	 	 	        RET
443	 	 	 	 	
444	 	 	 	 	
445	 	 	 	 	
446	 009F	 	 	 	DISK_GPOS:
447	 009F  8A 64 32	 	 	        MOV     AH,[SI].FD_OUTPOS       ;Get file output position
448	 00A2  C3	 	 	        RET
449	 	 	 	 	
450	 	 	 	 	
451	 	 	 	 	
452	 00A3	 	 	 	DISK_GWID:
453	 00A3  8A 64 2F	 	 	        MOV     AH,[SI].FD_WIDTH        ;Get file width
454	 00A6  C3	 	 	        RET
455	 	 	 	 	






































IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-6



456	 	 	 	 	        PAGE
457	 	 	 	 	
458	 00A7	 	 	 	DISK_SINPB:
459	 00A7  80 3C 04	 	 	        CMP     [SI].FD_MODE,MD_RND
460	 00AA  75 03	 	 	        JNE     sinp1
461	 	 	 	 	
462	 00AC  EB 3D 90	 	 	        JMP     SINP_50                 ;Serial input from random
463	 	 	 	 	
464	 00AF  80 7C 2A 00	 	sinp1:  CMP     [SI].FD_NMLOFS,0
465	 00B3  74 13	 	 	        JE      fillsq                  ;Sector is empty - get another
466	 	 	 	 	
467	 00B5  53	 	 	        PUSH    BX
468	 00B6  33 DB	 	 	        XOR     BX,BX
469	 00B8  8A 5C 29	 	 	        MOV     BL,[SI].FD_ORNOFS
470	 00BB  2A 5C 2A	 	 	        SUB     BL,[SI].FD_NMLOFS
471	 00BE  FE 4C 2A	 	 	        DEC     [SI].FD_NMLOFS
472	 00C1  8A 40 33	 	 	        MOV     AL,[SI+BX].FD_BUFFER    ;(AL) = character
473	 00C4  5B	 	 	        POP     BX
474	 00C5  0A C0	 	 	        OR      AL,AL                   ;Clear carry
475	 00C7  C3	 	 	        RET
476	 	 	 	 	
477	 00C8  80 7C 29 00	 	fillsq: CMP     [SI].FD_ORNOFS,0
478	 00CC  74 05	 	 	        JE      fills1                  ;At end of file
479	 	 	 	 	
480	 00CE  E8 0333 R	 	        CALL    READ_SECTOR             ;Read next sector
481	 00D1  75 04	 	 	        JNE     DISK_SINP               ;  Not at eof - try with new buffer
482	 	 	 	 	
483	 00D3  F9	 	 	fills1: STC                             ;Set carry
484	 00D4  B0 1A	 	 	        MOV     AL,EOFCHR               ;Return EOF character
485	 	 	 	 	
486	 00D6  C3	 	 	sinret: RET
487	 	 	 	 	
488	 00D7	 	 	 	DISK_SINP:
489	 00D7  E8 00A7 R	 	        CALL    DISK_SINPB              ;Read binary character
490	 00DA  72 FA	 	 	        JC      sinret                  ;  End of file
491	 	 	 	 	
492	 00DC  3C 1A	 	 	        CMP     AL,EOFCHR               ;End of file character?
493	 00DE  F8	 	 	        CLC                             ;Assume not
494	 00DF  75 F5	 	 	        JNE     sinret                  ;  Return
495	 	 	 	 	
496	 00E1  C6 44 29 00	 	        MOV     [SI].FD_ORNOFS,0        ;Clear these offsets
497	 00E5  C6 44 2A 00	 	        MOV     [SI].FD_NMLOFS,0
498	 00E9  F9	 	 	        STC
499	 00EA  C3	 	 	        RET
500	 	 	 	 	
501	 00EB	 	 	 	SINP_50:                                ;Serial input from random file
502	 00EB  53	 	 	        PUSH    BX
503	 00EC  E8 00F6 R	 	        CALL    FOVCHK                  ;Field overflow check
504	 00EF  8A 80 00BB	 	        MOV     AL,[SI+BX-1].FR_FIELD   ;Get character
505	 00F3  F8	 	 	        CLC                             ;Clear carry
506	 00F4  5B	 	 	        POP     BX
507	 00F5  C3	 	 	        RET
508	 	 	 	 	
509	 	 	 	 	


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-7



510	 00F6  8B 9C 00BA	 	FOVCHK: MOV     BX,[SI].FR_OUTPOS       ;Get current position
511	 00FA  3B 9C 00B3	 	        CMP     BX,[SI].FR_VRECL        ;Check for end of record
512	 00FE  74 06	 	 	        JE      ercfov                  ;  Yes - field overflow
513	 0100  43	 	 	        INC     BX                      ;Bump pointer
514	 0101  89 9C 00BA	 	        MOV     [SI].FR_OUTPOS,BX       ;Save  new position
515	 0105  C3	 	 	        RET
516	 	 	 	 	
517	 0106  E9 0000 E	 	ercfov: JMP     $ERC_FOV
518	 	 	 	 	















































IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-8



519	 	 	 	 	        PAGE
520	 	 	 	 	
521	 = 000D	 	 	 	CR=             13
522	 	 	 	 	
523	 0109	 	 	 	DISK_SOUT:
524	 0109  80 3C 04	 	 	        CMP     [SI].FD_MODE,MD_RND
525	 010C  75 03	 	 	        JNE     sout1
526	 	 	 	 	
527	 010E  EB 2A 90	 	 	        JMP     SOUT_50                 ;Serial output to random
528	 	 	 	 	
529	 0111  80 7C 29 80	 	sout1:  CMP     [SI].FD_ORNOFS,REC_LENGTH
530	 0115  75 05	 	 	        JNE     sout2                   ;Not at end of sector
531	 	 	 	 	
532	 0117  50	 	 	        PUSH    AX
533	 0118  E8 035D R	 	        CALL    WRITE_SECTOR            ;Write previous sector
534	 011B  58	 	 	        POP     AX
535	 	 	 	 	
536	 011C  53	 	 	sout2:  PUSH    BX
537	 011D  33 DB	 	 	        XOR     BX,BX
538	 011F  8A 5C 29	 	 	        MOV     BL,[SI].FD_ORNOFS       ;(BX) = buffer offset
539	 0122  88 40 33	 	 	        MOV     [SI+BX].FD_BUFFER,AL    ;Stuff character
540	 0125  5B	 	 	        POP     BX
541	 0126  FE 44 29	 	 	        INC     [SI].FD_ORNOFS
542	 	 	 	 	
543	 0129  3C 0D	 	 	soutps: CMP     AL,CR
544	 012B  75 05	 	 	        JNE     sout3
545	 	 	 	 	
546	 012D  C6 44 32 00	 	        MOV     [SI].FD_OUTPOS,0        ;Zero position
547	 0131  C3	 	 	        RET
548	 	 	 	 	
549	 0132  3C 20	 	 	sout3:  CMP     AL,' '
550	 0134  F5	 	 	        CMC
551	 0135  80 54 32 00	 	        ADC     [SI].FD_OUTPOS,0        ;Add 1 if printing character
552	 0139  C3	 	 	        RET
553	 	 	 	 	
554	 013A	 	 	 	SOUT_50:                                ;Serial output to random file
555	 013A  53	 	 	        PUSH    BX
556	 013B  E8 00F6 R	 	        CALL    FOVCHK                  ;Check for field overflow
557	 013E  88 80 00BB	 	        MOV     [SI+BX-1].FR_FIELD,AL   ;Store character
558	 0142  5B	 	 	        POP     BX
559	 0143  EB E4	 	 	        JMP     soutps                  ;Update position
560	 	 	 	 	














IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-9



561	 	 	 	 	        PAGE
562	 	 	 	 	
563	 0145	 	 	 	DISK_OPEN:
564	 0145  52	 	 	        PUSH    DX
565	 0146  51	 	 	        PUSH    CX
566	 	 	 	 	
567	 0147  80 3E 0000 E 04	 	        CMP     [$FILMOD],MD_RND        ;See if random
568	 014C  75 07	 	 	        JNE     notrnd                  ;  No
569	 014E  0B C9	 	 	        OR      CX,CX                   ;See if default record size
570	 0150  75 03	 	 	        JNE     notrnd                  ;  No
571	 0152  B9 0080	 	 	        MOV     CX,REC_LENGTH           ;Use record length as default
572	 0155  51	 	 	notrnd: PUSH    CX                      ;Save it for now
573	 = 0089	 	 	 	___TMP=         FR_FIELD-FD_BUFFER      ;Size beyond basic FDB
574	 0156  81 C1 0089	 	        ADD     CX,___TMP
575	 015A  BA 00FF	 	 	        MOV     DX,255                  ;(DH,DL) = position,width
576	 015D  B4 FF	 	 	        MOV     AH,255                  ;(AH) = all file modes legal
577	 015F  E8 0000 E	 	        CALL    $DEVOPN                 ;Allocate file block, etc.
578	 0162  59	 	 	        POP     CX                      ;Get it back
579	 0163  89 8C 00B3	 	        MOV     [SI].FR_VRECL,CX        ;Set random record length
580	 0167  56	 	 	        PUSH    SI
581	 0168  8D 7C 01	 	 	        LEA     DI,[SI].FD_FCB
582	 016B  BE 0000 E	 	        MOV     SI,OFFSET DC:$FILNAM
583	 016E  B9 000C	 	 	        MOV     CX,FILNAM_LENGTH+1      ;+1 for drive
584	 0171  F3/ A4	 	 	        REP     MOVSB                   ;Move in name into file block
585	 0173  5E	 	 	        POP     SI
586	 0174  E8 038B R	 	        CALL    SETBUF                  ;Set buffer address
587	 	 	 	 	
588	 	 	 	 	if      _MSDOS_
589	 0177  80 3E 0000 E 08	 	        CMP     [$FILMOD],MD_APP
590	 017C  75 03	 	 	        JNE     nochk
591	 017E  E8 03DF R	 	        CALL    CHKFOP                  ;See if open
592	 0181	 	 	 	nochk:
593	 	 	 	 	endif
594	 	 	 	 	
595	 0181  8D 54 01	 	 	        LEA     DX,[SI].FD_FCB          ;(DX) = FCB address
596	 0184  80 3E 0000 E 02	 	        CMP     [$FILMOD],MD_SQO
597	 0189  75 12	 	 	        JNE     opnfil                  ;Not sequential output
598	 	 	 	 	
599	 	 	 	 	if      _MSDOS_
600	 018B  E8 03DF R	 	        CALL    CHKFOP                  ;Check if already open
601	 	 	 	 	endif
602	 	 	 	 	
603	 	 	 	 	        CALLOS  C_DELE                  ;Delete existing file
604	 018E  B4 13                  +	        MOV     AH,C_DELE
605	 0190  CD 21                  +	        INT     33
606	 	 	 	 	
607	 0192	 	 	 	makfil: CALLOS  C_MAKE                  ;Create new file
608	 0192  B4 16                  +	        MOV     AH,C_MAKE
609	 0194  CD 21                  +	        INT     33
610	 0196  FE C0	 	 	        INC     AL
611	 0198  75 23	 	 	        JNZ     opnset                  ;Continue with OPEN
612	 019A  E9 0385 R	 	        JMP     erctmf                  ;Directory full
613	 	 	 	 	
614	 019D	 	 	 	opnfil: CALLOS  C_OPEN                  ;Open existing file


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-10



615	 019D  B4 0F                  +	        MOV     AH,C_OPEN
616	 019F  CD 21                  +	        INT     33
617	 01A1  FE C0	 	 	        INC     AL
618	 01A3  75 18	 	 	        JNE     opnset                  ;Continue with OPEN
619	 	 	 	 	
620	 	 	 	 	if      _MSDOS_
621	 01A5  80 3E 0000 E 08	 	        CMP     [$FILMOD],MD_APP
622	 01AA  75 07	 	 	        JNE     ntapnf
623	 	 	 	 	
624	 01AC  C6 06 0000 E 02	 	        MOV     [$FILMOD],MD_SQO        ;Default to sequential output
625	 01B1  EB DF	 	 	        JMP     makfil
626	 01B3	 	 	 	ntapnf:
627	 	 	 	 	endif
628	 	 	 	 	
629	 01B3  80 3E 0000 E 04	 	        CMP     [$FILMOD],MD_RND
630	 01B8  74 D8	 	 	        JE      makfil                  ;Create file for random
631	 01BA  E9 04B0 R	 	        JMP     ercfnf
632	 	 	 	 	
633	 01BD  A0 0000 E	 	opnset: MOV     AL,[$FILMOD]
634	 01C0  88 04	 	 	        MOV     [SI].FD_MODE,AL         ;Everything is OK - set file mode
635	 	 	 	 	
636	 	 	 	 	if      _MSDOS_
637	 01C2  C7 44 0F 0080	 	        MOV     WORD PTR [SI].FD_FCB+FCB_RSIZ,REC_LENGTH
638	 	 	 	 	endif
639	 	 	 	 	
640	 01C7  80 3C 04	 	 	        CMP     [SI].FD_MODE,MD_RND
641	 01CA  74 0D	 	 	        JE      opnret                  ;Done if random
642	 	 	 	 	
643	 	 	 	 	if      _MSDOS_
644	 01CC  80 3C 08	 	 	        CMP     [SI].FD_MODE,MD_APP
645	 01CF  74 0B	 	 	        JE      appfin                  ;Special if append
646	 	 	 	 	endif
647	 	 	 	 	
648	 01D1  80 3C 01	 	 	        CMP     [SI].FD_MODE,MD_SQI
649	 01D4  75 03	 	 	        JNE     opnret                  ;Done if not input
650	 	 	 	 	
651	 01D6  E8 0333 R	 	        CALL    READ_SECTOR             ;Read 1st sector
652	 	 	 	 	
653	 01D9  59	 	 	opnret: POP     CX
654	 01DA  5A	 	 	        POP     DX
655	 01DB  C3	 	 	        RET
656	 	 	 	 	
657	 	 	 	 	if      _MSDOS_
658	 	 	 	 	
659	 01DC	 	 	 	appfin:                                 ;Special code to find end of file
660	 	 	 	 	
661	 01DC  83 7C 11 00	 	        CMP     WORD PTR [SI].FD_FCB+FCB_FSIZ,0 ;Test for empty file
662	 01E0  75 0B	 	 	        JNE     ntzrfl
663	 01E2  83 7C 13 00	 	        CMP     WORD PTR [SI].FD_FCB+FCB_FSIZ+2,0
664	 01E6  75 05	 	 	        JNE     ntzrfl
665	 	 	 	 	
666	 01E8  C6 04 02	 	 	        MOV     [SI].FD_MODE,MD_SQO     ;Set mode to output
667	 01EB  EB EC	 	 	        JMP     opnret                  ;  and return
668	 	 	 	 	


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-11



669	 01ED  8D 7C 22	 	 	ntzrfl: LEA     DI,[SI].FD_FCB+FCB_RN   ;Point to random record number
670	 01F0  56	 	 	        PUSH    SI
671	 01F1  83 C6 11	 	 	        ADD     SI,FD_FCB+FCB_FSIZ      ;Point to file size
672	 01F4  F6 04 7F	 	 	        TEST    BYTE PTR [SI],127       ;See if multiple of 128
673	 01F7  9C	 	 	        PUSHF                           ;  Save flags
674	 01F8  AC	 	 	        LODSB                           ;Get low order byte of file size
675	 01F9  D0 E0	 	 	        SAL     AL,1                    ;Rotate high bit into carry
676	 01FB  AD	 	 	        LODSW                           ;Get middle word
677	 01FC  D1 E0	 	 	        SAL     AX,1                    ;Rotate carry in and high bit out
678	 01FE  AB	 	 	        STOSW                           ;Save low word of file size
679	 01FF  AC	 	 	        LODSB                           ;Get high order byte
680	 0200  B4 00	 	 	        MOV     AH,0                    ;Clear high byte of record number
681	 0202  D1 E0	 	 	        SAL     AX,1                    ;Rotate carry in
682	 0204  AB	 	 	        STOSW                           ;Save high word of record number
683	 0205  9D	 	 	        POPF                            ;Restore flags
684	 0206  5E	 	 	        POP     SI                      ;Restore pointer to file data block
685	 0207  75 03	 	 	        JNZ     nomtrc                  ;Record is not empty
686	 	 	 	 	
687	 0209  E8 0235 R	 	        CALL    BAKURN                  ;Backup record number
688	 	 	 	 	
689	 020C  E8 0333 R	 	nomtrc: CALL    READ_SECTOR             ;Read record
690	 020F  E8 0235 R	 	        CALL    BAKURN                  ;Backup record number
691	 0212  33 D2	 	 	        XOR     DX,DX                   ;Number of characters in buffer
692	 	 	 	 	
693	 0214  E8 00A7 R	 	redoef: CALL    DISK_SINPB              ;Read binary character
694	 0217  72 07	 	 	        JC      setsqm                  ;  Hit physical EOF
695	 	 	 	 	
696	 0219  3C 1A	 	 	        CMP     AL,EOFCHR
697	 021B  74 08	 	 	        JE      setsqo                  ;Found end of file
698	 	 	 	 	
699	 021D  42	 	 	        INC     DX
700	 021E  EB F4	 	 	        JMP     redoef                  ;Keep looping
701	 	 	 	 	
702	 0220  33 D2	 	 	setsqm: XOR     DX,DX                   ;Start of record
703	 0222  E8 0235 R	 	        CALL    BAKURN                  ;Read 1 past
704	 	 	 	 	
705	 0225  C6 04 02	 	 	setsqo: MOV     [SI].FD_MODE,MD_SQO     ;Ready for sequential output now
706	 0228  8D 7C 27	 	 	        LEA     DI,[SI].FD_CURLOC       ;Point to current location
707	 022B  33 C0	 	 	        XOR     AX,AX
708	 022D  AB	 	 	        STOSW                           ;Clear current location
709	 022E  88 15	 	 	        MOV     [DI],DL                 ;Set number of bytes in buffer
710	 0230  88 44 32	 	 	        MOV     [SI].FD_OUTPOS,AL       ;Clear print position
711	 0233  EB A4	 	 	        JMP     opnret                  ;Done with append
712	 	 	 	 	
713	 0235  83 6C 22 01	 	BAKURN: SUB     WORD PTR [SI].FD_FCB+FCB_RN,1 ;Decrement random record number
714	 0239  73 03	 	 	        JAE     bakret                  ;Done - no underflow
715	 023B  FF 4C 24	 	 	        DEC     WORD PTR [SI].FD_FCB+FCB_RN+2 ;Decrement high word
716	 023E  C3	 	 	bakret: RET
717	 	 	 	 	
718	 	 	 	 	endif
719	 	 	 	 	





IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-12



720	 	 	 	 	        PAGE
721	 	 	 	 	
722	 = 0001	 	 	 	PUTFLG=         1                       ;on = PUT , off = GET
723	 = 0002	 	 	 	RELFLG=         2                       ;on = relative , off = sequential
724	 = 0004	 	 	 	DIRFLG=         4                       ;on = WRITE , off = READ
725	 	 	 	 	
726	 023F  E9 0000 E	 	ercfc:  JMP     $ERC_FC
727	 0242  E9 0000 E	 	ercbrn: JMP     $ERC_BRN
728	 	 	 	 	
729	 0245	 	 	 	DISK_RANDIO:
730	 0245  51	 	 	        PUSH    CX
731	 0246  52	 	 	        PUSH    DX
732	 0247  53	 	 	        PUSH    BX
733	 0248  A8 02	 	 	        TEST    AL,RELFLG               ;Check for relative record number
734	 024A  75 07	 	 	        JNZ     rand1
735	 	 	 	 	
736	 024C  8B 94 00B7	 	        MOV     DX,[SI].FR_LOGREC       ;(DX) = current logical record
737	 0250  42	 	 	        INC     DX                      ;Bump by 1
738	 0251  EB 04	 	 	        JMP     SHORT rand2
739	 	 	 	 	
740	 0253  0B D2	 	 	rand1:  OR      DX,DX                   ;Check for bad record number
741	 0255  7E EB	 	 	        JLE     ercbrn                  ;  Error - 0 or negative
742	 	 	 	 	
743	 0257  89 94 00B7	 	rand2:  MOV     [SI].FR_LOGREC,DX       ;Save next record number
744	 025B  4A	 	 	        DEC     DX                      ;(DX) = current logical record number
745	 025C  C7 84 00BA 0000	 	        MOV     [SI].FR_OUTPOS,0        ;Clear output position
746	 0262  8B 9C 00B3	 	        MOV     BX,[SI].FR_VRECL        ;(BX) = logical record length
747	 0266  53	 	 	        PUSH    BX
748	 0267  81 FB 0080	 	        CMP     BX,REC_LENGTH           ;Check if logical size = physical
749	 026B  74 16	 	 	        JE      rand3
750	 	 	 	 	
751	 026D  93	 	 	        XCHG    AX,BX                   ;Save (AL) for now
752	 026E  F7 E2	 	 	        MUL     DX                      ;(DX,AX) = record * size (byte offset)
753	 0270  93	 	 	        XCHG    AX,BX                   ;(DX,BX) = result
754	 0271  03 DB	 	 	        ADD     BX,BX                   ;Offset * 2 (for /128)
755	 0273  13 D2	 	 	        ADC     DX,DX
756	 0275  0A F6	 	 	        OR      DH,DH                   ;Test for too big
757	 0277  75 C6	 	 	        JNZ     ercfc                   ;  Yes
758	 0279  8A F2	 	 	        MOV     DH,DL
759	 027B  8A D7	 	 	        MOV     DL,BH                   ;(DX) = physical record number
760	 027D  D0 EB	 	 	        SHR     BL,1
761	 027F  32 FF	 	 	        XOR     BH,BH                   ;(BX) = offset into physical record
762	 0281  EB 02	 	 	        JMP     SHORT rand4
763	 	 	 	 	
764	 0283  33 DB	 	 	rand3:  XOR     BX,BX                   ;(BX) = 0 (offset)
765	 	 	 	 	
766	 	 	 	 	;       (DX) = physical record number
767	 	 	 	 	;       (BX) = offset into physical record
768	 	 	 	 	
769	 0285  89 16 0000 R	 	rand4:  MOV     [RECORD],DX             ;Save record number
770	 0289  8D 8C 00BC	 	        LEA     CX,[SI].FR_FIELD        ;(CX) = logical buffer address
771	 028D  89 0E 0002 R	 	        MOV     [LBUFF],CX              ;Save as LBUFF
772	 0291  5A	 	 	        POP     DX                      ;Get record length
773	 	 	 	 	


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-13



774	 	 	 	 	;       (DX) = bytes left to transfer (initially record length)
775	 	 	 	 	;       (BX) = offset into current record
776	 	 	 	 	
777	 0292  8D 4C 33	 	 	nxtopd: LEA     CX,[SI].FD_BUFFER       ;(CX) = physical buffer address
778	 0295  03 CB	 	 	        ADD     CX,BX                   ;Add in offset
779	 0297  89 0E 0004 R	 	        MOV     [PBUFF],CX              ;Save in PBUFF
780	 029B  B9 0080	 	 	        MOV     CX,REC_LENGTH
781	 029E  2B CB	 	 	        SUB     CX,BX                   ;(CX) = bytes left in sector
782	 02A0  3B CA	 	 	        CMP     CX,DX                   ;find smaller left (buffer : record)
783	 02A2  72 02	 	 	        JB      datmof                  ;(CX) = left in buffer
784	 02A4  8B CA	 	 	        MOV     CX,DX                   ;(CX) = left in record
785	 02A6  A8 01	 	 	datmof: TEST    AL,PUTFLG               ;Check for read (GET)
786	 02A8  74 33	 	 	        JZ      fivdrd                  ;  Yes
787	 	 	 	 	
788	 02AA  81 F9 0080	 	        CMP     CX,REC_LENGTH           ;Writing entire sector?
789	 02AE  73 03	 	 	        JAE     nofvrd                  ;  Yes
790	 	 	 	 	
791	 02B0  E8 02F9 R	 	        CALL    GETSUB                  ;Read current sector
792	 	 	 	 	
793	 02B3  56	 	 	nofvrd: PUSH    SI                      ;Move logical to physical
794	 02B4  51	 	 	        PUSH    CX
795	 02B5  8B 36 0002 R	 	        MOV     SI,[LBUFF]
796	 02B9  8B 3E 0004 R	 	        MOV     DI,[PBUFF]
797	 02BD  D1 E9	 	 	        SHR     CX,1
798	 02BF  F3/ A5	 	 	        REP     MOVSW
799	 02C1  73 01	 	 	        JNC     evenlp
800	 02C3  A4	 	 	        MOVSB
801	 02C4  59	 	 	evenlp: POP     CX
802	 02C5  5E	 	 	        POP     SI
803	 	 	 	 	
804	 02C6  E8 02F5 R	 	        CALL    PUTSUB                  ;Write through to current sector
805	 	 	 	 	
806	 02C9  FF 06 0000 R	 	nxfvbf: INC     [RECORD]                ;Bump current record number
807	 02CD  01 0E 0002 R	 	        ADD     [LBUFF],CX              ;Bump logical buffer offset
808	 02D1  2B D1	 	 	        SUB     DX,CX                   ;Subtract bytes transferred
809	 02D3  33 DB	 	 	        XOR     BX,BX                   ;Zero offset into buffer
810	 02D5  0B D2	 	 	        OR      DX,DX                   ;Check for more to transfer
811	 02D7  75 B9	 	 	        JNZ     nxtopd                  ;  Yes - keep looping
812	 	 	 	 	
813	 02D9  5B	 	 	        POP     BX
814	 02DA  5A	 	 	        POP     DX
815	 02DB  59	 	 	        POP     CX
816	 02DC  C3	 	 	        RET
817	 	 	 	 	
818	 02DD  E8 02F9 R	 	fivdrd: CALL    GETSUB                  ;Read current record
819	 	 	 	 	
820	 02E0  56	 	 	        PUSH    SI                      ;Transfer from physical to logical
821	 02E1  51	 	 	        PUSH    CX
822	 02E2  8B 36 0004 R	 	        MOV     SI,[PBUFF]
823	 02E6  8B 3E 0002 R	 	        MOV     DI,[LBUFF]
824	 02EA  D1 E9	 	 	        SHR     CX,1
825	 02EC  F3/ A5	 	 	        REP     MOVSW
826	 02EE  73 01	 	 	        JNC     evenpl
827	 02F0  A4	 	 	        MOVSB


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 2-14



828	 02F1  59	 	 	evenpl: POP     CX
829	 02F2  5E	 	 	        POP     SI
830	 02F3  EB D4	 	 	        JMP     nxfvbf                  ;Go to common code
831	 	 	 	 	
832	 	 	 	 	;       Sector I/O routines for random
833	 	 	 	 	
834	 02F5  0C 04	 	 	PUTSUB: OR      AL,DIRFLG               ;Set write flag
835	 02F7  EB 02	 	 	        JMP     SHORT pgsub1
836	 	 	 	 	
837	 02F9  24 FB	 	 	GETSUB: AND     AL,not DIRFLG           ;Clear write flag (read)
838	 	 	 	 	
839	 02FB  50	 	 	pgsub1: PUSH    AX
840	 02FC  51	 	 	        PUSH    CX
841	 02FD  52	 	 	        PUSH    DX
842	 02FE  53	 	 	        PUSH    BX
843	 02FF  8B 1E 0000 R	 	        MOV     BX,[RECORD]             ;Get record number
844	 0303  43	 	 	        INC     BX
845	 0304  3B 9C 00B5	 	        CMP     BX,[SI].FR_PHYREC       ;Check if current record in buffer
846	 0308  75 04	 	 	        JNE     ntreds                  ;  No
847	 	 	 	 	
848	 030A  A8 04	 	 	        TEST    AL,DIRFLG               ;Check if read
849	 030C  74 20	 	 	        JZ      pgret                   ;  Yes - do not bother
850	 	 	 	 	
851	 030E  4B	 	 	ntreds: DEC     BX
852	 030F  89 5C 27	 	 	        MOV     [SI].FD_CURLOC,BX       ;Set CURLOC to physical record
853	 0312  C6 44 29 80	 	        MOV     [SI].FD_ORNOFS,REC_LENGTH
854	 0316  C6 44 2A 80	 	        MOV     [SI].FD_NMLOFS,REC_LENGTH
855	 031A  89 5C 22	 	 	        MOV     WORD PTR [SI].FD_FCB+FCB_RN,BX  ;Set record number
856	 031D  C7 44 24 0000	 	        MOV     WORD PTR [SI].FD_FCB+FCB_RN+2,0
857	 	 	 	 	
858	 0322  A8 04	 	 	        TEST    AL,DIRFLG               ;Check if read
859	 0324  74 05	 	 	        JZ      get1                    ;  Yes - read
860	 	 	 	 	
861	 0326  E8 035D R	 	        CALL    WRITE_SECTOR            ;Write it
862	 0329  EB 03	 	 	        JMP     SHORT pgret             ;Done
863	 	 	 	 	
864	 032B  E8 0333 R	 	get1:   CALL    READ_SECTOR             ;Read it
865	 	 	 	 	
866	 032E  5B	 	 	pgret:  POP     BX
867	 032F  5A	 	 	        POP     DX
868	 0330  59	 	 	        POP     CX
869	 0331  58	 	 	        POP     AX
870	 0332  C3	 	 	        RET
871	 	 	 	 	
872	 	 	 	 	
873	 0333	 	 	 	devio_disk      ENDP










IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 3-1



874	 	 	 	 	
875	 	 	 	 	
876	 	 	 	 	;       Utility routines for disk I/O
877	 	 	 	 	
878	 	 	 	 	
879	 0333	 	 	 	locals  PROC    NEAR
880	 	 	 	 	
881	 	 	 	 	
882	 0333	 	 	 	READ_SECTOR:
883	 0333  FF 44 27	 	 	        INC     [SI].FD_CURLOC          ;Bump logical record number
884	 	 	 	 	
885	 0336  51	 	 	        PUSH    CX
886	 0337  57	 	 	        PUSH    DI
887	 0338  B9 0040	 	 	        MOV     CX,REC_LENGTH/2
888	 033B  33 C0	 	 	        XOR     AX,AX
889	 033D  8D 7C 33	 	 	        LEA     DI,[SI].FD_BUFFER
890	 0340  F3/ AB	 	 	        REP     STOSW                   ;Clear buffer
891	 0342  5F	 	 	        POP     DI
892	 0343  59	 	 	        POP     CX
893	 	 	 	 	
894	 0344  E8 038B R	 	        CALL    SETBUF                  ;Set buffer address
895	 0347  B4 21	 	 	        MOV     AH,C_RNDR
896	 0349  E8 0397 R	 	        CALL    ACCFIL                  ;Read random
897	 034C  0A C0	 	 	        OR      AL,AL
898	 034E  B0 00	 	 	        MOV     AL,0                    ;Length = 0 for end of file
899	 0350  75 02	 	 	        JNZ     read1
900	 	 	 	 	
901	 0352  B0 80	 	 	        MOV     AL,REC_LENGTH           ;Length = sector size
902	 	 	 	 	
903	 0354  88 44 29	 	 	read1:  MOV     [SI].FD_ORNOFS,AL       ;Set number bytes read
904	 0357  88 44 2A	 	 	        MOV     [SI].FD_NMLOFS,AL       ;Set number of bytes left
905	 035A  0A C0	 	 	        OR      AL,AL                   ;'Z' set if end of file
906	 035C  C3	 	 	        RET
907	 	 	 	 	
908	 	 	 	 	
909	 	 	 	 	
910	 035D	 	 	 	WRITE_SECTOR:
911	 035D  C6 44 29 00	 	        MOV     [SI].FD_ORNOFS,0        ;Clear offset into buffer
912	 0361  E8 038B R	 	        CALL    SETBUF                  ;Set buffer address
913	 0364  B4 22	 	 	        MOV     AH,C_RNDW
914	 0366  E8 0397 R	 	        CALL    ACCFIL                  ;Random write
915	 0369  3C FF	 	 	        CMP     AL,255
916	 036B  74 18	 	 	        JE      erctmf                  ;Too many files
917	 036D  FE C8	 	 	        DEC     AL
918	 036F  74 17	 	 	        JZ      ercioe                  ;Error estending file
919	 0371  FE C8	 	 	        DEC     AL
920	 0373  75 0C	 	 	        JNZ     write1
921	 	 	 	 	
922	 0375  88 04	 	 	        MOV     [SI].FD_MODE,AL         ;Clear mode - disk full
923	 0377  8D 54 01	 	 	        LEA     DX,[SI].FD_FCB
924	 	 	 	 	        CALLOS  C_CLOS                  ;Close file
925	 037A  B4 10                  +	        MOV     AH,C_CLOS
926	 037C  CD 21                  +	        INT     33
927	 037E  E9 0000 E	 	        JMP     $ERC_DFL                ;Disk full error


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 3-2



928	 	 	 	 	
929	 0381  FF 44 27	 	 	write1: INC     [SI].FD_CURLOC          ;Bump current location
930	 0384  C3	 	 	        RET
931	 	 	 	 	
932	 0385  E9 0000 E	 	erctmf: JMP     $ERC_TMF
933	 	 	 	 	
934	 0388  E9 0000 E	 	ercioe: JMP     $ERC_IOE
935	 	 	 	 	
936	 	 	 	 	
937	 	 	 	 	
938	 038B  51	 	 	SETBUF: PUSH    CX                      ;Set buffer address
939	 038C  52	 	 	        PUSH    DX
940	 038D  8D 54 33	 	 	        LEA     DX,[SI].FD_BUFFER
941	 	 	 	 	        CALLOS  C_BUFF
942	 0390  B4 1A                  +	        MOV     AH,C_BUFF
943	 0392  CD 21                  +	        INT     33
944	 0394  5A	 	 	        POP     DX
945	 0395  59	 	 	        POP     CX
946	 0396  C3	 	 	        RET
947	 	 	 	 	
948	 	 	 	 	
949	 	 	 	 	
950	 0397  51	 	 	ACCFIL: PUSH    CX                      ;Access file
951	 0398  52	 	 	        PUSH    DX
952	 0399  8D 54 01	 	 	        LEA     DX,[SI].FD_FCB
953	 	 	 	 	        CALLOS                          ;Call operating system
954	 039C  CD 21                  +	        INT     33
955	 039E  FF 44 22	 	 	        INC     WORD PTR [SI].FD_FCB+FCB_RN ;Bump record number
956	 03A1  75 03	 	 	        JNZ     accfl1
957	 03A3  FF 44 24	 	 	        INC     WORD PTR [SI].FD_FCB+FCB_RN+2 ;Bump high order bytes
958	 03A6  80 FC 22	 	 	accfl1: CMP     AH,C_RNDW
959	 03A9  75 12	 	 	        JNE     accfl2
960	 03AB  0A C0	 	 	        OR      AL,AL
961	 03AD  74 14	 	 	        JZ      accret                  ;No error
962	 03AF  3C 05	 	 	        CMP     AL,5
963	 03B1  74 D2	 	 	        JE      erctmf                  ;5 - Too many files
964	 03B3  3C 03	 	 	        CMP     AL,3
965	 03B5  B0 01	 	 	        MOV     AL,1                    ;Map 3 to 1
966	 03B7  74 0A	 	 	        JE      accret
967	 03B9  FE C0	 	 	        INC     AL                      ;Disk space full
968	 03BB  EB 06	 	 	        JMP     SHORT accret
969	 	 	 	 	
970	 03BD	 	 	 	accfl2:
971	 	 	 	 	if      _MSDOS_
972	 03BD  3C 03	 	 	        CMP     AL,3                    ;Test for partial sector read
973	 03BF  75 02	 	 	        JNE     accret
974	 03C1  32 C0	 	 	        XOR     AL,AL                   ;Map 3 to 0 (no error)
975	 	 	 	 	endif
976	 03C3  5A	 	 	accret: POP     DX
977	 03C4  59	 	 	        POP     CX
978	 03C5  C3	 	 	        RET
979	 	 	 	 	
980	 	 	 	 	
981	 	 	 	 	


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 3-3



982	 03C6  50	 	 	NAMFIL: PUSH    AX
983	 03C7  51	 	 	        PUSH    CX
984	 03C8  56	 	 	        PUSH    SI
985	 03C9  8B 0F	 	 	        MOV     CX,[BX]                 ;(CX) = string length
986	 03CB  8B 77 02	 	 	        MOV     SI,[BX+2]               ;(SI) = string address
987	 03CE  E8 0000 E	 	        CALL    $SCANF                  ;Scan file name
988	 03D1  A8 80	 	 	        TEST    AL,80h                  ;Check for special devices
989	 03D3  78 07	 	 	        JS      ercbfn                  ;Illegal device name (only disk)
990	 03D5  E8 0000 E	 	        CALL    $$DITS                  ;Delete temporary strings
991	 03D8  5E	 	 	        POP     SI
992	 03D9  59	 	 	        POP     CX
993	 03DA  58	 	 	        POP     AX
994	 03DB  C3	 	 	        RET
995	 	 	 	 	
996	 03DC  E9 0000 E	 	ercbfn: JMP     $ERC_BFN
997	 	 	 	 	
998	 	 	 	 	
999	 	 	 	 	
1000	 	 	 	 	if      _MSDOS_
1001	 	 	 	 	;**     CHKFOP - Check for file already open
1002	 	 	 	 	;
1003	 	 	 	 	;       ENTRY   (SI) = file data block pointer
1004	 	 	 	 	;       USES    AX
1005	 	 	 	 	
1006	 03DF  57	 	 	CHKFOP: PUSH    DI
1007	 03E0  80 7C 01 00	 	        CMP     [SI].FD_FCB,0           ;Default drive?
1008	 03E4  75 09	 	 	        JNE     ntcdrv                  ;  No
1009	 	 	 	 	
1010	 	 	 	 	        CALLOS  C_GDRV                  ;Get drive number
1011	 03E6  B4 19                  +	        MOV     AH,C_GDRV
1012	 03E8  CD 21                  +	        INT     33
1013	 03EA  FE C0	 	 	        INC     AL                      ;  Convert to A=1, etc.
1014	 03EC  88 44 01	 	 	        MOV     [SI].FD_FCB,AL          ;Save drive number
1015	 	 	 	 	
1016	 03EF  BF 0002 E	 	ntcdrv: MOV     DI,OFFSET DC:$FILPT-BL_LNK  ;Must link through open file list
1017	 	 	 	 	
1018	 03F2  8B 7D FE	 	 	chklop: MOV     DI,[DI].BL_LNK          ;Chain to next entry
1019	 03F5  0B FF	 	 	        OR      DI,DI                   ;Test for end of list
1020	 03F7  74 14	 	 	        JE      chkret                  ;  Done
1021	 	 	 	 	
1022	 03F9  3B F7	 	 	        CMP     SI,DI                   ;Same file?
1023	 03FB  74 F5	 	 	        JE      chklop                  ;  Yes - skip this one
1024	 	 	 	 	
1025	 03FD  56	 	 	        PUSH    SI
1026	 03FE  57	 	 	        PUSH    DI
1027	 03FF  46	 	 	        INC     SI                      ;Point to FCB's
1028	 0400  47	 	 	        INC     DI
1029	 0401  B9 000C	 	 	        MOV     CX,FILNAM_LENGTH+1      ;+1 for drive
1030	 0404  F3/ A6	 	 	        REPZ    CMPSB                   ;Compare strings
1031	 0406  5F	 	 	        POP     DI
1032	 0407  5E	 	 	        POP     SI
1033	 0408  75 E8	 	 	        JNE     chklop                  ;Not equal - keep going
1034	 	 	 	 	
1035	 040A  E9 0000 E	 	        JMP     $ERC_FAO                ;File already open


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 3-4



1036	 	 	 	 	
1037	 040D  5F	 	 	chkret: POP     DI
1038	 040E  C3	 	 	        RET
1039	 	 	 	 	endif
1040	 	 	 	 	
1041	 	 	 	 	
1042	 040F	 	 	 	locals  ENDP

















































IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 4-1



1043	 	 	 	 	
1044	 	 	 	 	
1045	 	 	 	 	;       Compiler Generated Library Calls
1046	 	 	 	 	
1047	 040F	 	 	 	entries PROC    NEAR
1048	 	 	 	 	
1049	 	 	 	 	
1050	 	 	 	 	;**     $FL0 and $FIL - FILES statement
1051	 	 	 	 	
1052	 	 	 	 	;**     $FL0
1053	 	 	 	 	;
1054	 	 	 	 	;       ENTRY   NONE
1055	 	 	 	 	;       EXIT    NONE
1056	 	 	 	 	
1057	 040F  E8 0000 E	 	$FL0:   CALL    $SAVREG
1058	 0412  BB 0000 E	 	        MOV     BX,OFFSET DC:$FILNAM
1059	 0415  C6 07 00	 	 	        MOV     BYTE PTR [BX],0         ;Select default drive
1060	 0418  43	 	 	        INC     BX
1061	 0419  B1 0B	 	 	        MOV     CL,11
1062	 041B  E8 050D R	 	        CALL    FILQST                  ;Fill name with ?
1063	 041E  EB 06	 	 	        JMP     SHORT fil01             ;Go to common code
1064	 	 	 	 	
1065	 	 	 	 	
1066	 	 	 	 	;**     $FIL
1067	 	 	 	 	;
1068	 	 	 	 	;       ENTRY   (BX) = filename sdesc
1069	 	 	 	 	;       USES    NONE
1070	 	 	 	 	
1071	 0420  E8 0000 E	 	$FIL:   CALL    $SAVREG
1072	 0423  E8 03C6 R	 	        CALL    NAMFIL                  ;Scan file name
1073	 0426	 	 	 	fil01:
1074	 0426  C6 06 000C E 00	 	        MOV     BYTE PTR [$FILNAM+12],0 ;Clear extent byte
1075	 042B  BB 0001 E	 	        MOV     BX,OFFSET DC:$FILNAM+1  ;Point to filename
1076	 042E  B1 08	 	 	        MOV     CL,8
1077	 0430  E8 0508 R	 	        CALL    FILQS
1078	 0433  BB 0009 E	 	        MOV     BX,OFFSET DC:$FILNAM+9  ;Point to extension
1079	 0436  B1 03	 	 	        MOV     CL,3
1080	 0438  E8 0508 R	 	        CALL    FILQS
1081	 	 	 	 	if      _MSDOS_
1082	 043B  BA 0000 E	 	        MOV     DX,OFFSET DC:$FILNM2    ;For MSDOS
1083	 	 	 	 	else
1084	 	 	 	 	        MOV     DX,OFFSET DC:$DIRTMP    ;For CPM
1085	 	 	 	 	endif
1086	 	 	 	 	        CALLOS  C_BUFF                  ;Set buffer address
1087	 043E  B4 1A                  +	        MOV     AH,C_BUFF
1088	 0440  CD 21                  +	        INT     33
1089	 0442  BA 0000 E	 	        MOV     DX,OFFSET DC:$FILNAM
1090	 	 	 	 	        CALLOS  C_SEAR                  ;Search for filename
1091	 0445  B4 11                  +	        MOV     AH,C_SEAR
1092	 0447  CD 21                  +	        INT     33
1093	 0449  3C FF	 	 	        CMP     AL,255                  ;Test for 1st occurence of file
1094	 044B  74 63	 	 	        JZ      ercfnf                  ;  Not found
1095	 	 	 	 	
1096	 044D  BE 0001 E	 	filnxt: MOV     SI,OFFSET DC:$FILNM2+1  ;Point to file name


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 4-2



1097	 0450  B9 000B	 	 	        MOV     CX,11                   ;Characters in name
1098	 	 	 	 	
1099	 0453  AC	 	 	mornam: LODSB                           ;Get character
1100	 0454  E8 0000 E	 	        CALL    $$WCHT                  ;Output it
1101	 0457  83 F9 04	 	 	        CMP     CX,4
1102	 045A  75 0B	 	 	        JNE     notext                  ;Not an extension break
1103	 	 	 	 	
1104	 045C  8A 04	 	 	        MOV     AL,[SI]                 ;Get 1st char of extension
1105	 045E  3C 20	 	 	        CMP     AL,' '
1106	 0460  74 02	 	 	        JE      prispa                  ;Blank extension - print space
1107	 	 	 	 	
1108	 0462  B0 2E	 	 	        MOV     AL,'.'                  ;Print .
1109	 	 	 	 	
1110	 0464  E8 0000 E	 	prispa: CALL    $$WCHT                  ;Print blank or dot
1111	 	 	 	 	
1112	 0467  E2 EA	 	 	notext: LOOP    mornam                  ;Loop until 11 characters
1113	 	 	 	 	
1114	 0469  E8 0000 E	 	        CALL    $TTY_GPOS               ;Get TTY position
1115	 046C  86 C4	 	 	        XCHG    AL,AH
1116	 046E  04 0E	 	 	        ADD     AL,14-_IBM_             ;Position after next file name
1117	 0470  E8 0000 E	 	        CALL    $TTY_GWID               ;Get TTY width
1118	 0473  3A C4	 	 	        CMP     AL,AH
1119	 0475  73 0A	 	 	        JAE     nwfiln                  ;Force CR/LF
1120	 	 	 	 	
1121	 0477  B0 20	 	 	        MOV     AL,' '
1122	 	 	 	 	ife     _IBM_
1123	 0479  E8 0000 E	 	        CALL    $$WCHT
1124	 	 	 	 	endif
1125	 047C  E8 0000 E	 	        CALL    $$WCHT
1126	 047F  EB 03	 	 	        JMP     SHORT nextfl
1127	 	 	 	 	
1128	 0481  E8 0000 E	 	nwfiln: CALL    $$TCR                   ;Type CR/LF
1129	 	 	 	 	
1130	 0484  BA 0000 E	 	nextfl: MOV     DX,OFFSET DC:$FILNAM
1131	 	 	 	 	        CALLOS  C_SEAR+1
1132	 0487  B4 12                  +	        MOV     AH,C_SEAR+1
1133	 0489  CD 21                  +	        INT     33
1134	 048B  3C FF	 	 	        CMP     AL,255
1135	 048D  75 BE	 	 	        JNE     filnxt                  ;Still more
1136	 	 	 	 	
1137	 048F  C3	 	 	nwfil2: RET
1138	 	 	 	 	
1139	 	 	 	 	
1140	 	 	 	 	
1141	 	 	 	 	;**     $DKK - KILL filename
1142	 	 	 	 	;
1143	 	 	 	 	;       ENTRY   (BX) = filename sdesc
1144	 	 	 	 	;       USES    NONE
1145	 	 	 	 	
1146	 0490  E8 0000 E	 	$DKK:   CALL    $SAVREG
1147	 0493  E8 03C6 R	 	        CALL    NAMFIL                  ;Scan file name
1148	 	 	 	 	if      _CPM_
1149	 	 	 	 	        MOV     DX,OFFSET DC:$DIRTMP    ;Temporary buffer
1150	 	 	 	 	        CALLOS  C_BUFF                  ;Set buffer address


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 4-3



1151	 	 	 	 	endif
1152	 0496  BA 0000 E	 	        MOV     DX,OFFSET DC:$FILNAM
1153	 	 	 	 	        CALLOS  C_OPEN                  ;Open file
1154	 0499  B4 0F                  +	        MOV     AH,C_OPEN
1155	 049B  CD 21                  +	        INT     33
1156	 049D  FE C0	 	 	        INC     AL
1157	 049F  74 0F	 	 	        JZ      ercfnf                  ;File not found
1158	 	 	 	 	        CALLOS  C_CLOS                  ;Close file
1159	 04A1  B4 10                  +	        MOV     AH,C_CLOS
1160	 04A3  CD 21                  +	        INT     33
1161	 	 	 	 	if      _MSDOS_
1162	 04A5  BE FFFF E	 	        MOV     SI,OFFSET DC:$FILNAM-1  ;Pretend we are FDB
1163	 04A8  E8 03DF R	 	        CALL    CHKFOP                  ;Check for conflict with open files
1164	 	 	 	 	endif
1165	 	 	 	 	        CALLOS  C_DELE                  ;Delete file
1166	 04AB  B4 13                  +	        MOV     AH,C_DELE
1167	 04AD  CD 21                  +	        INT     33
1168	 04AF  C3	 	 	        RET
1169	 	 	 	 	
1170	 04B0  E9 0000 E	 	ercfnf: JMP     $ERC_FNF                ;File not found
1171	 	 	 	 	
1172	 	 	 	 	
1173	 	 	 	 	
1174	 	 	 	 	;**     $DKR - NAME statement
1175	 	 	 	 	;
1176	 	 	 	 	;       ENTRY   (BX) = source name
1177	 	 	 	 	;               (DX) = dest name
1178	 	 	 	 	;       EXIT    NONE
1179	 	 	 	 	
1180	 04B3  E8 0000 E	 	$DKR:   CALL    $SAVREG
1181	 04B6  52	 	 	        PUSH    DX                      ;Save dest name
1182	 04B7  E8 03C6 R	 	        CALL    NAMFIL                  ;Scan old file name
1183	 04BA  BA 0000 E	 	        MOV     DX,OFFSET DC:$FILNAM
1184	 	 	 	 	        CALLOS  C_OPEN
1185	 04BD  B4 0F                  +	        MOV     AH,C_OPEN
1186	 04BF  CD 21                  +	        INT     33
1187	 04C1  FE C0	 	 	        INC     AL
1188	 04C3  74 EB	 	 	        JZ      ercfnf                  ;File not found
1189	 04C5  8B F2	 	 	        MOV     SI,DX
1190	 04C7  BF 0000 E	 	        MOV     DI,OFFSET DC:$FILNM2
1191	 04CA  B9 000C	 	 	        MOV     CX,FILNAM_LENGTH+1      ;+1 for drive
1192	 04CD  F3/ A4	 	 	        REP     MOVSB                   ;Move name
1193	 04CF  5B	 	 	        POP     BX                      ;Pop dest name
1194	 04D0  E8 03C6 R	 	        CALL    NAMFIL                  ;Scan new filename
1195	 	 	 	 	        CALLOS  C_OPEN
1196	 04D3  B4 0F                  +	        MOV     AH,C_OPEN
1197	 04D5  CD 21                  +	        INT     33
1198	 04D7  FE C0	 	 	        INC     AL
1199	 04D9  75 13	 	 	        JNZ     ercfae                  ;File already exists
1200	 	 	 	 	
1201	 	 	 	 	;if      _CPM_
1202	 	 	 	 	;        MOV     AL,[$FILNAM]            ;Test to see if drives match
1203	 	 	 	 	;        CMP     [$FILNM2],AL
1204	 	 	 	 	;        JE      drvsok


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 4-4



1205	 	 	 	 	;        JMP     $ERC_FC                 ;Illegal function call
1206	 	 	 	 	;drvsok:
1207	 	 	 	 	;endif
1208	 	 	 	 	
1209	 	 	 	 	if      _MSDOS_
1210	 04DB  8B F2	 	 	        MOV     SI,DX
1211	 04DD  46	 	 	        INC     SI                      ;(SI) = $FILNAM+1
1212	 04DE  BF 0011 E	 	        MOV     DI,OFFSET DC:$FILNM2+17 ;(DI) = dest for new file name
1213	 04E1  B9 000B	 	 	        MOV     CX,FILNAM_LENGTH        ;No drive code
1214	 04E4  F3/ A4	 	 	        REP     MOVSB                   ;Move name
1215	 	 	 	 	endif
1216	 	 	 	 	
1217	 04E6  BA 0000 E	 	        MOV     DX,OFFSET DC:$FILNM2    ;Point to 2nd FCB
1218	 	 	 	 	        CALLOS  C_RENA                  ;Rename file
1219	 04E9  B4 17                  +	        MOV     AH,C_RENA
1220	 04EB  CD 21                  +	        INT     33
1221	 04ED  C3	 	 	        RET
1222	 	 	 	 	
1223	 04EE  E9 0000 E	 	ercfae: JMP     $ERC_FAE                ;File already exists
1224	 	 	 	 	
1225	 	 	 	 	
1226	 	 	 	 	
1227	 	 	 	 	;**     $RS2 - RESET statement;
1228	 	 	 	 	;
1229	 	 	 	 	;       ENTRY   NONE
1230	 	 	 	 	;       EXIT    NONE
1231	 	 	 	 	
1232	 04F1	 	 	 	$ZZ1:
1233	 04F1  E8 0000 E	 	$RS2:   CALL    $SAVREG
1234	 04F4  E8 0000 E	 	        CALL    $CLOSF                  ;Close all files
1235	 	 	 	 	        CALLOS  C_GDRV                  ;Get drive number
1236	 04F7  B4 19                  +	        MOV     AH,C_GDRV
1237	 04F9  CD 21                  +	        INT     33
1238	 04FB  50	 	 	        PUSH    AX
1239	 	 	 	 	        CALLOS  C_REST                  ;Restore
1240	 04FC  B4 0D                  +	        MOV     AH,C_REST
1241	 04FE  CD 21                  +	        INT     33
1242	 0500  58	 	 	        POP     AX
1243	 0501  8A D0	 	 	        MOV     DL,AL
1244	 	 	 	 	        CALLOS  C_SDRV                  ;Set drive number
1245	 0503  B4 0E                  +	        MOV     AH,C_SDRV
1246	 0505  CD 21                  +	        INT     33
1247	 0507  C3	 	 	        RET
1248	 	 	 	 	
1249	 	 	 	 	
1250	 0508	 	 	 	entries ENDP
1251	 	 	 	 	
1252	 0508	 	 	 	filprc  PROC    NEAR
1253	 	 	 	 	
1254	 0508  80 3F 2A	 	 	filqs:  CMP     BYTE PTR [BX],'*'       ;Test for *
1255	 050B  75 08	 	 	        JNE     filret
1256	 	 	 	 	
1257	 050D  C6 07 3F	 	 	filqst: MOV     BYTE PTR [BX],'?'       ;Fill with ?
1258	 0510  43	 	 	        INC     BX


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Page 4-5



1259	 0511  FE C9	 	 	        DEC     CL
1260	 0513  75 F8	 	 	        JNZ     filqst                  ;Keep looping
1261	 	 	 	 	
1262	 0515  C3	 	 	filret: RET
1263	 	 	 	 	
1264	 0516	 	 	 	filprc  ENDP
1265	 	 	 	 	
1266	 0516	 	 	 	CODE    ENDS
1267	 	 	 	 	
1268	 	 	 	 	        END














































IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Symbols-1



Macros:

	 	N a m e  	 	Length

CALLOS . . . . . . . . . . . . .	0002	
DEVMAC . . . . . . . . . . . . .	0002	
DEVNAM . . . . . . . . . . . . .	0005	
DSPMAC . . . . . . . . . . . . .	0001	
DSPNAM . . . . . . . . . . . . .	000E	
ENT. . . . . . . . . . . . . . .	0002	
ENTI . . . . . . . . . . . . . .	0002	
ENTORG . . . . . . . . . . . . .	0001	

Structures and records:

	 	N a m e	 	 	Width	# fields
	 	 	 	 	Shift	Width	Mask	Initial

FILE_DATA_BLOCK. . . . . . . . .	00BD	0012
  FD_MODE. . . . . . . . . . . . .	0000
  FD_FCB . . . . . . . . . . . . .	0001
  FD_CURLOC. . . . . . . . . . . .	0027
  FD_ORNOFS. . . . . . . . . . . .	0029
  FD_NMLOFS. . . . . . . . . . . .	002A
  FD_DEVICE. . . . . . . . . . . .	002E
  FD_WIDTH . . . . . . . . . . . .	002F
  FD_POS . . . . . . . . . . . . .	0030
  FD_FLAGS . . . . . . . . . . . .	0031
  FD_OUTPOS. . . . . . . . . . . .	0032
  FD_BUFFER. . . . . . . . . . . .	0033
  FR_VRECL . . . . . . . . . . . .	00B3
  FR_PHYREC. . . . . . . . . . . .	00B5
  FR_LOGREC. . . . . . . . . . . .	00B7
  FR_OUTPOS. . . . . . . . . . . .	00BA
  FR_FIELD . . . . . . . . . . . .	00BC

Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CODE . . . . . . . . . . . . . .	0516	BYTE  	PUBLIC	'CODE'
DC . . . . . . . . . . . . . . .	GROUP
  DATA . . . . . . . . . . . . . .	0006	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

ACCFIL . . . . . . . . . . . . .	L NEAR 	0397	CODE
ACCFL1 . . . . . . . . . . . . .	L NEAR 	03A6	CODE
ACCFL2 . . . . . . . . . . . . .	L NEAR 	03BD	CODE
ACCRET . . . . . . . . . . . . .	L NEAR 	03C3	CODE
APPFIN . . . . . . . . . . . . .	L NEAR 	01DC	CODE
BAKRET . . . . . . . . . . . . .	L NEAR 	023E	CODE
BAKURN . . . . . . . . . . . . .	L NEAR 	0235	CODE


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Symbols-2



BL_LEN . . . . . . . . . . . . .	Number	FFFC	
BL_LNK . . . . . . . . . . . . .	Number	FFFE	
BL_SIZE. . . . . . . . . . . . .	Number	FFFA	
CHKCTZ . . . . . . . . . . . . .	L NEAR 	0059	CODE
CHKFOP . . . . . . . . . . . . .	L NEAR 	03DF	CODE
CHKLOP . . . . . . . . . . . . .	L NEAR 	03F2	CODE
CHKRET . . . . . . . . . . . . .	L NEAR 	040D	CODE
CR . . . . . . . . . . . . . . .	Number	000D	
C_BUFF . . . . . . . . . . . . .	Number	001A	
C_CLOS . . . . . . . . . . . . .	Number	0010	
C_DELE . . . . . . . . . . . . .	Number	0013	
C_GDRV . . . . . . . . . . . . .	Number	0019	
C_MAKE . . . . . . . . . . . . .	Number	0016	
C_OPEN . . . . . . . . . . . . .	Number	000F	
C_READ . . . . . . . . . . . . .	Number	0014	
C_RENA . . . . . . . . . . . . .	Number	0017	
C_REST . . . . . . . . . . . . .	Number	000D	
C_RNDR . . . . . . . . . . . . .	Number	0021	
C_RNDW . . . . . . . . . . . . .	Number	0022	
C_SDRV . . . . . . . . . . . . .	Number	000E	
C_SEAR . . . . . . . . . . . . .	Number	0011	
C_WRIT . . . . . . . . . . . . .	Number	0015	
DATMOF . . . . . . . . . . . . .	L NEAR 	02A6	CODE
DEVIO_DISK . . . . . . . . . . .	N PROC	0018	CODE	Length =031B
DIRFLG . . . . . . . . . . . . .	Number	0004	
DISK_BAKC. . . . . . . . . . . .	L NEAR 	009B	CODE
DISK_CLOSE . . . . . . . . . . .	L NEAR 	0018	CODE
DISK_EOF . . . . . . . . . . . .	L NEAR 	003D	CODE
DISK_GPOS. . . . . . . . . . . .	L NEAR 	009F	CODE
DISK_GWID. . . . . . . . . . . .	L NEAR 	00A3	CODE
DISK_LOC . . . . . . . . . . . .	L NEAR 	006D	CODE
DISK_LOF . . . . . . . . . . . .	L NEAR 	007A	CODE
DISK_OPEN. . . . . . . . . . . .	L NEAR 	0145	CODE
DISK_POS . . . . . . . . . . . .	L NEAR 	0091	CODE
DISK_RANDIO. . . . . . . . . . .	L NEAR 	0245	CODE
DISK_SINP. . . . . . . . . . . .	L NEAR 	00D7	CODE
DISK_SINPB . . . . . . . . . . .	L NEAR 	00A7	CODE
DISK_SOUT. . . . . . . . . . . .	L NEAR 	0109	CODE
DISK_WIDTH . . . . . . . . . . .	L NEAR 	0097	CODE
DN_KYBD. . . . . . . . . . . . .	Number	FFFF	
DN_LPT1. . . . . . . . . . . . .	Number	FFFD	
DN_SCRN. . . . . . . . . . . . .	Number	FFFE 	
DV_BAKC. . . . . . . . . . . . .	Number	000E	
DV_CLOSE . . . . . . . . . . . .	Number	0006	
DV_EOF . . . . . . . . . . . . .	Number	0000	
DV_GPOS. . . . . . . . . . . . .	Number	0014	
DV_GWID. . . . . . . . . . . . .	Number	0016	
DV_LOC . . . . . . . . . . . . .	Number	0002	
DV_LOF . . . . . . . . . . . . .	Number	0004	
DV_OPEN. . . . . . . . . . . . .	Number	000C	
DV_RANDIO. . . . . . . . . . . .	Number	000A	
DV_SINP. . . . . . . . . . . . .	Number	0010	
DV_SOUT. . . . . . . . . . . . .	Number	0012	
DV_TABLEN. . . . . . . . . . . .	Number	0018	


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Symbols-3



DV_WIDTH . . . . . . . . . . . .	Number	0008	
ENTRIES. . . . . . . . . . . . .	N PROC	040F	CODE	Length =00F9
EOFCHR . . . . . . . . . . . . .	Number	001A	
EOFRET . . . . . . . . . . . . .	L NEAR 	0069	CODE
ERCBFM . . . . . . . . . . . . .	L NEAR 	006A	CODE
ERCBFN . . . . . . . . . . . . .	L NEAR 	03DC	CODE
ERCBRN . . . . . . . . . . . . .	L NEAR 	0242	CODE
ERCFAE . . . . . . . . . . . . .	L NEAR 	04EE	CODE
ERCFC. . . . . . . . . . . . . .	L NEAR 	023F	CODE
ERCFNF . . . . . . . . . . . . .	L NEAR 	04B0	CODE
ERCFOV . . . . . . . . . . . . .	L NEAR 	0106	CODE
ERCIOE . . . . . . . . . . . . .	L NEAR 	0388	CODE
ERCTMF . . . . . . . . . . . . .	L NEAR 	0385	CODE
EVENLP . . . . . . . . . . . . .	L NEAR 	02C4	CODE
EVENPL . . . . . . . . . . . . .	L NEAR 	02F1	CODE
FB_NUM . . . . . . . . . . . . .	Number	FFFB	
FCB_EX . . . . . . . . . . . . .	Number	000C	
FCB_FN . . . . . . . . . . . . .	Number	0001	
FCB_FSIZ . . . . . . . . . . . .	Number	0010	
FCB_FT . . . . . . . . . . . . .	Number	0009	
FCB_LENGTH . . . . . . . . . . .	Number	0026	
FCB_NR . . . . . . . . . . . . .	Number	0020	
FCB_RC . . . . . . . . . . . . .	Number	000F	
FCB_RN . . . . . . . . . . . . .	Number	0021	
FCB_RSIZ . . . . . . . . . . . .	Number	000E	
FIL01. . . . . . . . . . . . . .	L NEAR 	0426	CODE
FILLS1 . . . . . . . . . . . . .	L NEAR 	00D3	CODE
FILLSQ . . . . . . . . . . . . .	L NEAR 	00C8	CODE
FILNAML. . . . . . . . . . . . .	Number	0026	
FILNAM_LENGTH. . . . . . . . . .	Number	000B	
FILNXT . . . . . . . . . . . . .	L NEAR 	044D	CODE
FILPRC . . . . . . . . . . . . .	N PROC	0508	CODE	Length =000E
FILQS. . . . . . . . . . . . . .	L NEAR 	0508	CODE
FILQST . . . . . . . . . . . . .	L NEAR 	050D	CODE
FILRET . . . . . . . . . . . . .	L NEAR 	0515	CODE
FIVDRD . . . . . . . . . . . . .	L NEAR 	02DD	CODE
FOVCHK . . . . . . . . . . . . .	L NEAR 	00F6	CODE
GET1 . . . . . . . . . . . . . .	L NEAR 	032B	CODE
GETSUB . . . . . . . . . . . . .	L NEAR 	02F9	CODE
LAST_DEVICE_OFFSET . . . . . . .	Number	0008	
LBUFF. . . . . . . . . . . . . .	L WORD 	0002	DATA
LOC1 . . . . . . . . . . . . . .	L NEAR 	0079	CODE
LOCALS . . . . . . . . . . . . .	N PROC	0333	CODE	Length =00DC
MAKFIL . . . . . . . . . . . . .	L NEAR 	0192	CODE
MD_APP . . . . . . . . . . . . .	Number	0008	
MD_BIN . . . . . . . . . . . . .	Number	0080	
MD_FIL . . . . . . . . . . . . .	Number	0004	
MD_IBM . . . . . . . . . . . . .	Number	0020	
MD_KIL . . . . . . . . . . . . .	Number	0010	
MD_RND . . . . . . . . . . . . .	Number	0004	
MD_SQI . . . . . . . . . . . . .	Number	0001	
MD_SQO . . . . . . . . . . . . .	Number	0002	
MD_USR . . . . . . . . . . . . .	Number	0040	
MORNAM . . . . . . . . . . . . .	L NEAR 	0453	CODE


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Symbols-4



NAMFIL . . . . . . . . . . . . .	L NEAR 	03C6	CODE
NEXTFL . . . . . . . . . . . . .	L NEAR 	0484	CODE
NOCHK. . . . . . . . . . . . . .	L NEAR 	0181	CODE
NOFORC . . . . . . . . . . . . .	L NEAR 	002B	CODE
NOFVRD . . . . . . . . . . . . .	L NEAR 	02B3	CODE
NOMTRC . . . . . . . . . . . . .	L NEAR 	020C	CODE
NOTEXT . . . . . . . . . . . . .	L NEAR 	0467	CODE
NOTRND . . . . . . . . . . . . .	L NEAR 	0155	CODE
NTAPNF . . . . . . . . . . . . .	L NEAR 	01B3	CODE
NTCDRV . . . . . . . . . . . . .	L NEAR 	03EF	CODE
NTREDS . . . . . . . . . . . . .	L NEAR 	030E	CODE
NTZRFL . . . . . . . . . . . . .	L NEAR 	01ED	CODE
NWFIL2 . . . . . . . . . . . . .	L NEAR 	048F	CODE
NWFILN . . . . . . . . . . . . .	L NEAR 	0481	CODE
NXFVBF . . . . . . . . . . . . .	L NEAR 	02C9	CODE
NXTOPD . . . . . . . . . . . . .	L NEAR 	0292	CODE
OPNFIL . . . . . . . . . . . . .	L NEAR 	019D	CODE
OPNRET . . . . . . . . . . . . .	L NEAR 	01D9	CODE
OPNSET . . . . . . . . . . . . .	L NEAR 	01BD	CODE
ORNCHK . . . . . . . . . . . . .	L NEAR 	0042	CODE
PBUFF. . . . . . . . . . . . . .	L WORD 	0004	DATA
PGRET. . . . . . . . . . . . . .	L NEAR 	032E	CODE
PGSUB1 . . . . . . . . . . . . .	L NEAR 	02FB	CODE
PRISPA . . . . . . . . . . . . .	L NEAR 	0464	CODE
PUTFLG . . . . . . . . . . . . .	Number	0001	
PUTSUB . . . . . . . . . . . . .	L NEAR 	02F5	CODE
RAND1. . . . . . . . . . . . . .	L NEAR 	0253	CODE
RAND2. . . . . . . . . . . . . .	L NEAR 	0257	CODE
RAND3. . . . . . . . . . . . . .	L NEAR 	0283	CODE
RAND4. . . . . . . . . . . . . .	L NEAR 	0285	CODE
READ1. . . . . . . . . . . . . .	L NEAR 	0354	CODE
READ_SECTOR. . . . . . . . . . .	L NEAR 	0333	CODE
RECORD . . . . . . . . . . . . .	L WORD 	0000	DATA
REC_LENGTH . . . . . . . . . . .	Number	0080	
REDOEF . . . . . . . . . . . . .	L NEAR 	0214	CODE
RELFLG . . . . . . . . . . . . .	Number	0002	
SETBUF . . . . . . . . . . . . .	L NEAR 	038B	CODE
SETSQM . . . . . . . . . . . . .	L NEAR 	0220	CODE
SETSQO . . . . . . . . . . . . .	L NEAR 	0225	CODE
SINP1. . . . . . . . . . . . . .	L NEAR 	00AF	CODE
SINP_50. . . . . . . . . . . . .	L NEAR 	00EB	CODE
SINRET . . . . . . . . . . . . .	L NEAR 	00D6	CODE
SOUT1. . . . . . . . . . . . . .	L NEAR 	0111	CODE
SOUT2. . . . . . . . . . . . . .	L NEAR 	011C	CODE
SOUT3. . . . . . . . . . . . . .	L NEAR 	0132	CODE
SOUTPS . . . . . . . . . . . . .	L NEAR 	0129	CODE
SOUT_50. . . . . . . . . . . . .	L NEAR 	013A	CODE
WASEOF . . . . . . . . . . . . .	L NEAR 	0063	CODE
WRITE1 . . . . . . . . . . . . .	L NEAR 	0381	CODE
WRITE_SECTOR . . . . . . . . . .	L NEAR 	035D	CODE
$$DITS . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$SPSV . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$$TCR. . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$$WCHT . . . . . . . . . . . . .	L NEAR 	0000	CODE	External


IODISK - Disk I/O Drivers for BASCOM-86                  Macro-86 %1(12)   1:4:30  13-Nov-81    Symbols-5



$CLOSF . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DEVOPN. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$DKK . . . . . . . . . . . . . .	L NEAR 	0490	CODE	Global
$DKR . . . . . . . . . . . . . .	L NEAR 	04B3	CODE	Global
$DNORM . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$D_DISK. . . . . . . . . . . . .	L NEAR 	0000	CODE	Global
$ERC_BFM . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_BFN . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_BRN . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_DFL . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_FAE . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_FAO . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_FC. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_FNF . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_FOV . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_IOE . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ERC_TMF . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FBALC . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FBDEA . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$FIL . . . . . . . . . . . . . .	L NEAR 	0420	CODE	Global
$FILMOD. . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FILNAM. . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FILNM2. . . . . . . . . . . . .	V BYTE 	0000	DATA	External
$FILPT . . . . . . . . . . . . .	V WORD 	0000	DATA	External
$FL0 . . . . . . . . . . . . . .	L NEAR 	040F	CODE	Global
$RS2 . . . . . . . . . . . . . .	L NEAR 	04F1	CODE	Global
$SAVREG. . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$SCANF . . . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TTY_GPOS. . . . . . . . . . . .	L NEAR 	0000	CODE	External
$TTY_GWID. . . . . . . . . . . .	L NEAR 	0000	CODE	External
$ZZ1 . . . . . . . . . . . . . .	L NEAR 	04F1	CODE	Global
_CPM_. . . . . . . . . . . . . .	Number	0000	
_IBM_. . . . . . . . . . . . . .	Number	0000	
_MSDOS_. . . . . . . . . . . . .	Number	0001	
___DEV . . . . . . . . . . . . .	Number	FFFC	
___TMP . . . . . . . . . . . . .	Number	0089	
___ZZZ . . . . . . . . . . . . .	Number	0018	

Warning Severe
Errors	Errors 
0	0















