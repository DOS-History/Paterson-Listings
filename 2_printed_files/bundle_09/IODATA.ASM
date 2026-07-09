IODATA - Common data for input and output                Macro-86 %1(12)   1:3:45  13-Nov-81    Page 1-1



    1	 	 	 	 	        TITLE   IODATA - Common data for input and output
    2	 	 	 	 	
    3	 0000	 	 	 	DATA    SEGMENT WORD PUBLIC 'DATA'
    4	 	 	 	 	
    5	 	 	 	 	        PUBLIC  VALTYP,CURTYP,TYP
    6	 	 	 	 	
    7	 0000	 	 	 	TYP     LABEL   WORD
    8	 0000  ??	 	 	VALTYP  DB      ?
    9	 0001  ??	 	 	CURTYP  DB      ?
   10	 	 	 	 	
   11	 0002	 	 	 	DATA    ENDS
   12	 	 	 	 	
   13	 0000	 	 	 	CONST   SEGMENT WORD PUBLIC 'CONST'
   14	 	 	 	 	
   15	 	 	 	 	        PUBLIC  PWR10TAB,$ONE,$DBLONE
   16	 	 	 	 	
   17	 	 	 	 	;PWR10TAB - Double precision table of powers of 10
   18	 	 	 	 	
   19	 	 	 	 	;       DB      018H,0C4H,0B6H,07BH,073H,0EDH,01CH,04AH          ;1E-55
   20	 	 	 	 	;       DB      01EH,075H,0A4H,05AH,0D0H,028H,044H,04DH          ;1E-54
   21	 	 	 	 	;       DB      065H,092H,04DH,071H,004H,033H,075H,050H          ;1E-53
   22	 	 	 	 	;       DB      07FH,07BH,0D0H,0C6H,0E2H,03FH,019H,054H          ;1E-52
   23	 	 	 	 	;       DB      05FH,09AH,084H,078H,0DBH,08FH,03FH,057H          ;1E-51
   24	 	 	 	 	;       DB      0F7H,0C0H,0A5H,056H,0D2H,073H,06FH,05AH          ;1E-50
   25	 	 	 	 	;       DB      09AH,098H,027H,076H,063H,0A8H,015H,05EH          ;1E-49
   26	 	 	 	 	;       DB      0C1H,07EH,0B1H,053H,07CH,012H,03BH,061H          ;1E-48
   27	 	 	 	 	;       DB      071H,0DEH,09DH,068H,01BH,0D7H,069H,064H          ;1E-47
   28	 	 	 	 	;       DB      007H,0ABH,062H,021H,071H,026H,012H,068H          ;1E-46
   29	 	 	 	 	;       DB      0C9H,055H,0BBH,069H,00DH,0B0H,036H,06BH          ;1E-45
   30	 	 	 	 	;       DB      03BH,02BH,02AH,0C4H,010H,05CH,064H,06EH          ;1E-44
   31	 	 	 	 	;       DB      005H,05BH,09AH,07AH,08AH,0B9H,00EH,072H          ;1E-43
   32	 	 	 	 	;       DB      0C6H,0F1H,040H,019H,0EDH,067H,032H,075H          ;1E-42
   33	 	 	 	 	;       DB      037H,02EH,091H,05FH,0E8H,001H,05FH,078H          ;1E-41
   34	 	 	 	 	;       DB      0E3H,0BCH,0BAH,03BH,031H,061H,00BH,07CH          ;1E-40
   35	 	 	 	 	;       DB      01BH,06CH,0A9H,08AH,07DH,039H,02EH,07FH          ;1E-39
   36	 	 	 	 	
   37	 	 	 	 	; The powers of 10 below have been checked with MuMath
   38	 	 	 	 	
   39	 	 	 	 	;       DB      022H,0C7H,053H,0EDH,0DCH,0C7H,059H,002H          ;1E-38
   40	 	 	 	 	;       DB      075H,05CH,054H,014H,0EAH,01CH,008H,006H          ;1E-37
   41	 	 	 	 	;       DB      093H,073H,069H,099H,024H,024H,02AH,009H          ;1E-36
   42	 	 	 	 	;       DB      078H,0D0H,0C3H,0BFH,02DH,0ADH,054H,00CH          ;1E-35
   43	 	 	 	 	;       DB      04BH,062H,0DAH,097H,03CH,0ECH,004H,010H          ;1E-34
   44	 	 	 	 	;       DB      0DDH,0FAH,0D0H,0BDH,04BH,027H,026H,013H          ;1E-33
   45	 	 	 	 	;       DB      095H,039H,045H,0ADH,01EH,0B1H,04FH,016H          ;1E-32
   46	 	 	 	 	;       DB      0FDH,043H,04BH,02CH,0B3H,0CEH,001H,01AH          ;1E-31
   47	 0000  FC 14 5E F7 5F 42	        DB      0FCH,014H,05EH,0F7H,05FH,042H,022H,01DH          ;1E-30
   48	       22 1D	 	 	
   49	 0008  3B 9A 35 F5 F7 D2	        DB      03BH,09AH,035H,0F5H,0F7H,0D2H,04AH,020H          ;1E-29
   50	       4A 20	 	 	
   51	 0010  CA 00 83 F2 B5 87	        DB      0CAH,000H,083H,0F2H,0B5H,087H,07DH,023H          ;1E-28
   52	       7D 23	 	 	
   53	 0018  7E E0 91 B7 D1 74	        DB      07EH,0E0H,091H,0B7H,0D1H,074H,01EH,027H          ;1E-27
   54	       1E 27	 	 	


IODATA - Common data for input and output                Macro-86 %1(12)   1:3:45  13-Nov-81    Page 1-2



   55	 0020  9E 58 76 25 06 12	        DB      09EH,058H,076H,025H,006H,012H,046H,02AH          ;1E-26
   56	       46 2A	 	 	
   57	 0028  C5 EE D3 AE 87 96	        DB      0C5H,0EEH,0D3H,0AEH,087H,096H,077H,02DH          ;1E-25
   58	       77 2D	 	 	
   59	 0030  3B 75 44 CD 14 BE	        DB      03BH,075H,044H,0CDH,014H,0BEH,01AH,031H          ;1E-24
   60	       1A 31	 	 	
   61	 0038  8A 92 95 00 9A 6D	        DB      08AH,092H,095H,000H,09AH,06DH,041H,034H          ;1E-23
   62	       41 34	 	 	
   63	 0040  2D F7 BA 80 00 C9	        DB      02DH,0F7H,0BAH,080H,000H,0C9H,071H,037H          ;1E-22
   64	       71 37	 	 	
   65	 0048  7C DA 74 50 A0 1D	        DB      07CH,0DAH,074H,050H,0A0H,01DH,017H,03BH          ;1E-21
   66	       17 3B	 	 	
   67	 0050  1B 11 92 64 08 E5	        DB      01BH,011H,092H,064H,008H,0E5H,03CH,03EH          ;1E-20
   68	       3C 3E	 	 	
   69	 0058  62 95 B6 7D 4A 1E	        DB      062H,095H,0B6H,07DH,04AH,01EH,06CH,041H          ;1E-19
   70	       6C 41	 	 	
   71	 0060  5D 1D 92 8E EE 92	        DB      05DH,01DH,092H,08EH,0EEH,092H,013H,045H          ;1E-18
   72	       13 45	 	 	
   73	 0068  B4 A4 36 32 AA 77	        DB      0B4H,0A4H,036H,032H,0AAH,077H,038H,048H          ;1E-17
   74	       38 48	 	 	
   75	 0070  E1 4D C4 BE 94 95	        DB      0E1H,04DH,0C4H,0BEH,094H,095H,066H,04BH          ;1E-16
   76	       66 4B	 	 	
   77	 0078  AD B0 3A F7 7C 1D	        DB      0ADH,0B0H,03AH,0F7H,07CH,01DH,010H,04FH          ;1E-15
   78	       10 4F	 	 	
   79	 0080  D8 5C 09 35 DC 24	        DB      0D8H,05CH,009H,035H,0DCH,024H,034H,052H          ;1E-14
   80	       34 52	 	 	
   81	 0088  0E B4 4B 42 13 2E	        DB      00EH,0B4H,04BH,042H,013H,02EH,061H,055H          ;1E-13
   82	       61 55	 	 	
   83	 0090  89 50 6F 09 CC BC	        DB      089H,050H,06FH,009H,0CCH,0BCH,00CH,059H          ;1E-12
   84	       0C 59	 	 	
   85	 0098  AB 24 CB 0B FF EB	        DB      0ABH,024H,0CBH,00BH,0FFH,0EBH,02FH,05CH          ;1E-11
   86	       2F 5C	 	 	
   87	 00A0  D6 ED BD CE FE E6	        DB      0D6H,0EDH,0BDH,0CEH,0FEH,0E6H,05BH,05FH          ;1E-10
   88	       5B 5F	 	 	
   89	 00A8  A6 B4 36 41 5F 70	        DB      0A6H,0B4H,036H,041H,05FH,070H,009H,063H          ;1E-9
   90	       09 63	 	 	
   91	 00B0  CF 61 84 11 77 CC	        DB      0CFH,061H,084H,011H,077H,0CCH,02BH,066H          ;1E-8
   92	       2B 66	 	 	
   93	 00B8  43 7A E5 D5 94 BF	        DB      043H,07AH,0E5H,0D5H,094H,0BFH,056H,069H          ;1E-7
   94	       56 69	 	 	
   95	 00C0  6A 6C AF 05 BD 37	        DB      06AH,06CH,0AFH,005H,0BDH,037H,006H,06DH          ;1E-6
   96	       06 6D	 	 	
   97	 00C8  84 47 1B 47 AC C5	        DB      084H,047H,01BH,047H,0ACH,0C5H,027H,070H          ;1E-5
   98	       27 70	 	 	
   99	 00D0  65 19 E2 58 17 B7	        DB      065H,019H,0E2H,058H,017H,0B7H,051H,073H          ;1E-4
  100	       51 73	 	 	
  101	 00D8  DF 4F 8D 97 6E 12	        DB      0DFH,04FH,08DH,097H,06EH,012H,003H,077H          ;1E-3
  102	       03 77	 	 	
  103	 00E0  D7 A3 70 3D 0A D7	        DB      0D7H,0A3H,070H,03DH,00AH,0D7H,023H,07AH          ;1E-2
  104	       23 7A	 	 	
  105	 00E8  CD CC CC CC CC CC	        DB      0CDH,0CCH,0CCH,0CCH,0CCH,0CCH,04CH,07DH          ;1E-1
  106	       4C 7D	 	 	
  107	 00F0	 	 	 	PWR10TAB LABEL  BYTE
  108	 00F0  00 00 00 00	 	$DBLONE DB      000H,000H,000H,000H


IODATA - Common data for input and output                Macro-86 %1(12)   1:3:45  13-Nov-81    Page 1-3



  109	 00F4  00 00 00 00	 	$ONE    DB      000H,000H,000H,000H                              ;1E0
  110	 00F8  00 00 00 00 00 00	        DB      000H,000H,000H,000H,000H,000H,020H,084H          ;1E1
  111	       20 84	 	 	
  112	 0100  00 00 00 00 00 00	        DB      000H,000H,000H,000H,000H,000H,048H,087H          ;1E2
  113	       48 87	 	 	
  114	 0108  00 00 00 00 00 00	        DB      000H,000H,000H,000H,000H,000H,07AH,08AH          ;1E3
  115	       7A 8A	 	 	
  116	 0110  00 00 00 00 00 40	        DB      000H,000H,000H,000H,000H,040H,01CH,08EH          ;1E4
  117	       1C 8E	 	 	
  118	 0118  00 00 00 00 00 50	        DB      000H,000H,000H,000H,000H,050H,043H,091H          ;1E5
  119	       43 91	 	 	
  120	 0120  00 00 00 00 00 24	        DB      000H,000H,000H,000H,000H,024H,074H,094H          ;1E6
  121	       74 94	 	 	
  122	 0128  00 00 00 00 80 96	        DB      000H,000H,000H,000H,080H,096H,018H,098H          ;1E7
  123	       18 98	 	 	
  124	 0130  00 00 00 00 20 BC	        DB      000H,000H,000H,000H,020H,0BCH,03EH,09BH          ;1E8
  125	       3E 9B	 	 	
  126	 0138  00 00 00 00 28 6B	        DB      000H,000H,000H,000H,028H,06BH,06EH,09EH          ;1E9
  127	       6E 9E	 	 	
  128	 0140  00 00 00 00 F9 02	        DB      000H,000H,000H,000H,0F9H,002H,015H,0A2H          ;1E10
  129	       15 A2	 	 	
  130	 0148  00 00 00 40 B7 43	        DB      000H,000H,000H,040H,0B7H,043H,03AH,0A5H          ;1E11
  131	       3A A5	 	 	
  132	 0150  00 00 00 10 A5 D4	        DB      000H,000H,000H,010H,0A5H,0D4H,068H,0A8H          ;1E12
  133	       68 A8	 	 	
  134	 0158  00 00 00 2A E7 84	        DB      000H,000H,000H,02AH,0E7H,084H,011H,0ACH          ;1E13
  135	       11 AC	 	 	
  136	 0160  00 00 80 F4 20 E6	        DB      000H,000H,080H,0F4H,020H,0E6H,035H,0AFH          ;1E14
  137	       35 AF	 	 	
  138	 0168  00 00 A0 31 A9 5F	        DB      000H,000H,0A0H,031H,0A9H,05FH,063H,0B2H          ;1E15
  139	       63 B2	 	 	
  140	 0170  00 00 04 BF C9 1B	        DB      000H,000H,004H,0BFH,0C9H,01BH,00EH,0B6H          ;1E16
  141	       0E B6	 	 	
  142	 0178  00 00 C5 2E BC A2	        DB      000H,000H,0C5H,02EH,0BCH,0A2H,031H,0B9H          ;1E17
  143	       31 B9	 	 	
  144	 0180  00 40 76 3A 6B 0B	        DB      000H,040H,076H,03AH,06BH,00BH,05EH,0BCH          ;1E18
  145	       5E BC	 	 	
  146	 0188  00 E8 89 04 23 C7	        DB      000H,0E8H,089H,004H,023H,0C7H,00AH,0C0H          ;1E19
  147	       0A C0	 	 	
  148	 0190  00 62 AC C5 EB 78	        DB      000H,062H,0ACH,0C5H,0EBH,078H,02DH,0C3H          ;1E20
  149	       2D C3	 	 	
  150	 0198  80 7A 17 B7 26 D7	        DB      080H,07AH,017H,0B7H,026H,0D7H,058H,0C6H          ;1E21
  151	       58 C6	 	 	
  152	 01A0  90 AC 6E 32 78 86	        DB      090H,0ACH,06EH,032H,078H,086H,007H,0CAH          ;1E22
  153	       07 CA	 	 	
  154	 01A8  B4 57 0A 3F 16 68	        DB      0B4H,057H,00AH,03FH,016H,068H,029H,0CDH          ;1E23
  155	       29 CD	 	 	
  156	 01B0  A1 ED CC CE 1B C2	        DB      0A1H,0EDH,0CCH,0CEH,01BH,0C2H,053H,0D0H          ;1E24
  157	       53 D0	 	 	
  158	 01B8  85 14 40 61 51 59	        DB      085H,014H,040H,061H,051H,059H,004H,0D4H          ;1E25
  159	       04 D4	 	 	
  160	 01C0  A6 19 90 B9 A5 6F	        DB      0A6H,019H,090H,0B9H,0A5H,06FH,025H,0D7H          ;1E26
  161	       25 D7	 	 	
  162	 01C8  0F 20 F4 27 8F CB	        DB      00FH,020H,0F4H,027H,08FH,0CBH,04EH,0DAH          ;1E27


IODATA - Common data for input and output                Macro-86 %1(12)   1:3:45  13-Nov-81    Page 1-4



  163	       4E DA	 	 	
  164	 01D0  0A 94 F8 78 39 3F	        DB      00AH,094H,0F8H,078H,039H,03FH,001H,0DEH          ;1E28
  165	       01 DE	 	 	
  166	 01D8  0C B9 36 D7 07 8F	        DB      00CH,0B9H,036H,0D7H,007H,08FH,021H,0E1H          ;1E29
  167	       21 E1	 	 	
  168	 01E0  4F 67 04 CD C9 F2	        DB      04FH,067H,004H,0CDH,0C9H,0F2H,049H,0E4H          ;1E30
  169	       49 E4	 	 	
  170	 01E8  23 81 45 40 7C 6F	        DB      023H,081H,045H,040H,07CH,06FH,07CH,0E7H          ;1E31
  171	       7C E7	 	 	
  172	 01F0  B6 70 2B A8 AD C5	        DB      0B6H,070H,02BH,0A8H,0ADH,0C5H,01DH,0EBH          ;1E32
  173	       1D EB	 	 	
  174	 01F8  E3 4C 36 12 19 37	        DB      0E3H,04CH,036H,012H,019H,037H,045H,0EEH          ;1E33
  175	       45 EE	 	 	
  176	 0200  1C E0 C3 56 DF 84	        DB      01CH,0E0H,0C3H,056H,0DFH,084H,076H,0F1H          ;1E34
  177	       76 F1	 	 	
  178	 0208  11 6C 3A 96 0B 13	        DB      011H,06CH,03AH,096H,00BH,013H,01AH,0F5H          ;1E35
  179	       1A F5	 	 	
  180	 0210  16 07 C9 7B CE 97	        DB      016H,007H,0C9H,07BH,0CEH,097H,040H,0F8H          ;1E36
  181	       40 F8	 	 	
  182	 0218  DB 48 BB 1A C2 BD	        DB      0DBH,048H,0BBH,01AH,0C2H,0BDH,070H,0FBH          ;1E37
  183	       70 FB	 	 	
  184	 0220  89 0D B5 50 99 76	        DB      089H,00DH,0B5H,050H,099H,076H,016H,0FFH          ;1E38
  185	       16 FF	 	 	
  186	 0228  EB 50 E2 A4 3F 14	        DB      0EBH,050H,0E2H,0A4H,03FH,014H,03CH,082H          ;1E39
  187	       3C 82	 	 	
  188	 0230  26 E5 1A 8E 4F 19	        DB      026H,0E5H,01AH,08EH,04FH,019H,06BH,085H          ;1E40
  189	       6B 85	 	 	
  190	 0238  38 CF D0 B8 D1 EF	        DB      038H,0CFH,0D0H,0B8H,0D1H,0EFH,012H,089H          ;1E41
  191	       12 89	 	 	
  192	 0240  06 03 05 27 C6 AB	        DB      006H,003H,005H,027H,0C6H,0ABH,037H,08CH          ;1E42
  193	       37 8C	 	 	
  194	 0248  C7 43 C6 B0 B7 96	        DB      0C7H,043H,0C6H,0B0H,0B7H,096H,065H,08FH          ;1E43
  195	       65 8F	 	 	
  196	 0250  5C EA 7B CE 32 7E	        DB      05CH,0EAH,07BH,0CEH,032H,07EH,00FH,093H          ;1E44
  197	       0F 93	 	 	
  198	 0258  F4 E4 1A 82 BF 5D	        DB      0F4H,0E4H,01AH,082H,0BFH,05DH,033H,096H          ;1E45
  199	       33 96	 	 	
  200	 0260  30 9E A1 62 2F 35	        DB      030H,09EH,0A1H,062H,02FH,035H,060H,099H          ;1E46
  201	       60 99	 	 	
  202	 0268  DE 02 A5 9D 3D 21	        DB      0DEH,002H,0A5H,09DH,03DH,021H,00CH,09DH          ;1E47
  203	       0C 9D	 	 	
  204	 0270  96 43 0E 05 8D 29	        DB      096H,043H,00EH,005H,08DH,029H,02FH,0A0H          ;1E48
  205	       2F A0	 	 	
  206	 0278  7B D4 51 46 F0 F3	        DB      07BH,0D4H,051H,046H,0F0H,0F3H,05AH,0A3H          ;1E49
  207	       5A A3	 	 	
  208	 0280  CD 24 F3 2B 76 D8	        DB      0CDH,024H,0F3H,02BH,076H,0D8H,008H,0A7H          ;1E50
  209	       08 A7	 	 	
  210	 0288  00 EE EF B6 93 0E	        DB      000H,0EEH,0EFH,0B6H,093H,00EH,02BH,0AAH          ;1E51
  211	       2B AA	 	 	
  212	 0290  80 E9 AB A4 38 D2	        DB      080H,0E9H,0ABH,0A4H,038H,0D2H,055H,0ADH          ;1E52
  213	       55 AD	 	 	
  214	 0298  F0 71 EB 66 63 A3	        DB      0F0H,071H,0EBH,066H,063H,0A3H,005H,0B1H          ;1E53
  215	       05 B1	 	 	
  216	 02A0  6C 4E A6 40 3C 0C	        DB      06CH,04EH,0A6H,040H,03CH,00CH,027H,0B4H          ;1E54


IODATA - Common data for input and output                Macro-86 %1(12)   1:3:45  13-Nov-81    Page 1-5



  217	       27 B4	 	 	
  218	 02A8  07 E2 CF 50 4B CF	        DB      007H,0E2H,0CFH,050H,04BH,0CFH,050H,0B7H          ;1E55
  219	       50 B7	 	 	
  220	 02B0  45 ED 81 12 8F 81	        DB      045H,0EDH,081H,012H,08FH,081H,002H,0BBH          ;1E56
  221	       02 BB	 	 	
  222	 	 	 	 	
  223	 02B8	 	 	 	CONST   ENDS
  224	 	 	 	 	
  225	 	 	 	 	        END















































IODATA - Common data for input and output                Macro-86 %1(12)   1:3:45  13-Nov-81    Symbols-1



Segments and groups:

	 	N a m e	 	 	Size	align	combine	class

CONST. . . . . . . . . . . . . .	02B8	WORD  	PUBLIC	'CONST'
DATA . . . . . . . . . . . . . .	0002	WORD  	PUBLIC	'DATA'

Symbols:            

	 	N a m e	 	 	Type	Value	Attr         

CURTYP . . . . . . . . . . . . .	L BYTE 	0001	DATA	Global
PWR10TAB . . . . . . . . . . . .	L BYTE 	00F0	CONST	Global
TYP. . . . . . . . . . . . . . .	L WORD 	0000	DATA	Global
VALTYP . . . . . . . . . . . . .	L BYTE 	0000	DATA	Global
$DBLONE. . . . . . . . . . . . .	L BYTE 	00F0	CONST	Global
$ONE . . . . . . . . . . . . . .	L BYTE 	00F4	CONST	Global

Warning Severe
Errors	Errors 
0	0



































