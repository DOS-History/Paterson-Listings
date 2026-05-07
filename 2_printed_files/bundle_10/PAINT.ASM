00100           TITLE   PAINT graphics runtime routine
00200   
00300   
00400   DATA    SEGMENT WORD PUBLIC 'RT_DATA'
00500   
00600           EXTRN   $M_CUR:BYTE, $M_SAVE:BYTE
00700           EXTRN   $O_CUR:WORD, $O_SAVE:WORD
00800           EXTRN   $$SFPT:WORD
00900   
01000   C_SCAN  DW      ?                       ;scan count
01100   C_SKIP  DW      ?                       ;skip count
01200   DIRECT  DB      ?                       ;paint direction
01300   F_L_PAI DB      ?                       ;flag for left already painted
01400   F_R_PAI DB      ?                       ;flag for right already painted
01500   LEN_Q   DW      ?                       ;current queue length
01600   P_DEQ   DW      ?                       ;pointer to dequeue entry
01700   P_ENQ   DW      ?                       ;pointer to enqueue entry
01800   P_END_Q DW      ?                       ;pointer to end of queue area
01900   TOTAL_Q DW      ?                       ;total size available for queue
02000   
02100   DATA    ENDS
02200   
02300   
02400   CONST   SEGMENT WORD PUBLIC 'RT_DATA'
02500   
02600   SIZE_ENT EQU    6                       ;queue entry size
02700   
02800   SIZE_PAI EQU    4*1024                  ;minimal size required to be
02900                                           ;available in string space
03000                                           ;for PAINT queue, otherwise
03100                                           ;a major garbage collection
03200                                           ;is performed
03300   
03400   CONST   ENDS
03500   
03600   DGROUP  GROUP   CONST,DATA
03700           PAGE
03800   
03900   
04000   CODE    SEGMENT WORD PUBLIC 'CODE'
04100   
04200   
04300           PUBLIC  $PAI
04400   
04500           EXTRN   $ERC_FC:NEAR, $ERC_OM:NEAR
04600           EXTRN   $LEFTC:NEAR
04700           EXTRN   $MAPXYC:NEAR
04800           EXTRN   $PARMS:NEAR, $PNTINI:NEAR
04900           EXTRN   $SAVREG:NEAR, $SCANL:NEAR, $SCANR:NEAR
05000           EXTRN   $TDOWNC:NEAR, $TUPC:NEAR
05100           EXTRN   $$MAG:NEAR
05200   
05300   
05400           ASSUME  CS:CODE,  DS:DGROUP,  ES:DGROUP
05500           PAGE
05600   
05700   
05800   ;**     $PAI - process the PAINT statement
05900   ;
06000   ; Inputs:
06100   ;       BX = x coordinate of point in area to be painted
06200   ;       DX = y coordinate of point in area to be painted
06300   ;       CX = paint color specification
06400   ;       AX = border color specification
06500   ; Function:
06600   ;       Paint the figure containing the specified point and with
06700   ;       edges of the specified boundary color in the specified
06800   ;       paint color.
06900   ;       The algorithm used is copied from ADVGRP.MAC in the
07000   ;       Interpreter; a queue is used to save the skipped area
07100   ;       boundaries.  The space for the queue is obtained from the
07200   ;       compiler runtime string space.
07300   ; Outouts:
07400   ;       none
07500   ; Registers:
07600   ;       none
07700   
07800   $PAI:
07900           CALL    $SAVREG                 ;save state
08000           XCHG    AX,BP                   ;save border color spec
08100           CALL    $PARMS                  ;process coords and paint color
08200           XCHG    AX,BP                   ;retrieve border color spec
08300           MOV     BP,CX                   ;save scaled x coord
08400           CALL    $PNTINI                 ;initialize for paint
08500           JC      PAI_ERROR               ;error if invalid border color
08600           MOV     CX,BP                   ;retrieve x coord
08700           CALL    $MAPXYC                 ;map coords to screen position
08800           MOV     SI,[$$SFPT]             ;fetch ptr to next string area
08900           LODSW                           ;AX = size of area
09000           CMP     AX,SIZE_PAI             ;will size be adequate ?
09100           JNB     PAI_SIZE_SET            ;probably, continue
09200           CALL    $$MAG                   ;maybe not, grabage collect
09300           MOV     SI,[$$SFPT]
09400           LODSW                           ;now get ptr to area and size
09500   PAI_SIZE_SET:
09600           DEC     AX                      ;calculate # bytes left
09700           MOV     [TOTAL_Q],AX            ;save as total queue size
09800           MOV     [P_ENQ],SI
09900           MOV     [P_DEQ],SI              ;initialize queue ptrs
10000           ADD     AX,SI
10100           SUB     AX,SIZE_ENT-1
10200           MOV     [P_END_Q],AX            ;save ptr to end of queue
10300           MOV     [LEN_Q],0               ;initialize current queue len
10400           MOV     DX,1                    ;init skip cnt for skip no bord
10500           CALL    PAI_SCAN_R              ;scan right from initial pos
10600           JZ      PAI_RET                 ;we started on border, return
10700           PUSH    BX                      ;save right scan count
10800           CALL    PAI_SCAN_L              ;scan left from initial pos
10900           POP     DX
11000           ADD     DX,BX                   ;DX = left count + right count
11100           MOV     AL,64                   ;set up entry for going down
11200           CALL    PAI_ENTRY               ;enqueue entry
11300           MOV     AL,192                  ;init for painting up
11400           JMP     SHORT PAI_START
11401   PAI_RET:
11421           RET
11441   PAI_ERROR:
11461           JMP     $ERC_FC                 ;illegal function call
11500   ;
11600   ;       Main paint loop
11700   ;
11800   PAI_LOOP:
11900           CALL    PAI_DEQ                 ;fetch next entry from queue
12000           MOV     [$O_CUR],BX
12100           MOV     [$M_CUR],CL             ;and set as current state
12200   PAI_START:
12300           MOV     [DIRECT],AL             ;save direction
12400           OR      AL,AL
12500           JZ      PAI_RET                 ;zero direction, end of queue
12600           JNS     PAI_DOWN                ;positive direction, down
12700           CALL    $TUPC                   ;negative direction, test up
12800           JMP     SHORT PAI_CHECK
12900   PAI_DOWN:
13000           CALL    $TDOWNC                 ;test down
13100   PAI_CHECK:                              ;salary
13200           JC      PAI_LOOP                ;screen edge, get next entry
13300           CALL    PAI_SCAN_R              ;scan right up to skip cnt bord
13400           JZ      PAI_LOOP                ;nothing painted, get next ent
13500           CALL    PAI_SCAN_L              ;now scan left
13600           MOV     DX,BX                   ;save left scan count
13700           OR      AL,AL                   ;was line already painted ?
13800           JZ      PAI_ALREADY             ;yes, no overhang
13900           CMP     BX,1                    ;is left scan count .GT. 1 ?
14000           JLE     PAI_ALREADY             ;no, continue
14100           MOV     AL,[DIRECT]
14200           NEG     AL                      ;go in opposite direction
14300           CALL    PAI_ENTRY               ;put current state in queue
14400   PAI_ALREADY:
14500           ADD     DX,[C_SCAN]             ;DX = right count + left count
14700           MOV     AL,[F_L_PAI]
14800           OR      AL,[F_R_PAI]
14900           JZ      PAI_SAVE                ;don't enqueue if already paint
15000           MOV     AL,[DIRECT]
15100           CALL    PAI_ENTRY               ;enqueue entry
15200   ;
15300   ;       Set current location back to end of right scan
15400   ;
15500   PAI_SAVE:                               ;drugstore
15600           MOV     AX,[$O_SAVE]
15700           MOV     [$O_CUR],AX
15800           MOV     AL,[$M_SAVE]
15900           MOV     [$M_CUR],AL
16000   PAI_OH_L:
16100           MOV     AX,[C_SKIP]
16200           SUB     AX,[C_SCAN]             ;any more border to skip ?
16300           JZ      PAI_LOOP                ;no, end of this scan
16400           JC      PAI_OH_R                ;yes, but right overhang
16500           XCHG    AX,DX                   ;yes, scan right dif of counts
16600           CALL    PAI_SCAN_R
16700           JZ      PAI_LOOP                ;no more points, proceed
16800           OR      AL,AL
16900           JZ      PAI_OH_L                ;ignore if line already painted
17000           MOV     DX,BX                   ;save right scan count
17100           MOV     BX,[$O_SAVE]
17200           MOV     CL,[$M_SAVE]
17300           MOV     AL,[DIRECT]
17400           CALL    PAI_ENQ                 ;enqueue entry for right scanpt
17500           JMP     PAI_OH_L                ;contiue until skipcount .LE. 0
17600   PAI_OH_R:
17650           NEG     AX                      ;make new skipcount positive
17700           CMP     AX,1                    ;is (skipcnt-scancnt) .LT. -1 ?
17800           JLE     PAI_LOOP_REACH          ;no,overhang too small to enter
18000           DEC     AX
18050           MOV     CX,AX                   ;set up count
18100           XCHG    AX,DX                   ;save skipcount
18200   PAI_BACK:                               ;i.o.u.
18300           CALL    $LEFTC
18400           LOOP    PAI_BACK                ;move left -(skipcnt-scancnt)-1
18500           MOV     AL,[DIRECT]             ;no, make entry in opposite dir
18600           NEG     AL
18700           CALL    PAI_ENTRY               ;enqueue entry
18750   PAI_LOOP_REACH:
18800           JMP     PAI_LOOP                ;go to next entry
19300           PAGE
19400   
19500   
19600   ;**     PAI_DEQ - remove next entry from queue and return in registers
19700   ;
19800   ; Inputs:
19900   ;       none
20000   ; Outputs:
20100   ;       AL = direction flag  (0 if queue is empty)
20200   ;       BX = cursor screen offset
20300   ;       CL = screen mask
20400   ;       DX = scan count
20500   ; Registers:
20600   ;       AH,CH,SI
20700   
20800   PAI_DEQ:
20900           XOR     AL,AL                   ;set no entry flag
21000           SUB     [LEN_Q],SIZE_ENT        ;update current queue size
21100           JC      PAI_DEQ_RET             ;return flag if queue empty
21200           MOV     SI,[P_DEQ]              ;fetch ptr to current entry
21300           LODSW
21400           XCHG    AX,BX
21500           LODSW
21600           XCHG    AX,CX
21700           LODSW
21800           XCHG    AX,DX
21900           MOV     AL,CH                   ;fetch entry and set into regs
22000           CMP     SI,[P_END_Q]            ;are we at end of queue area ?
22100           JB      PAI_DEQ_SET             ;no, continue
22200           MOV     SI,[$$SFPT]             ;yes, wrap around
22300           INC     SI
22400           INC     SI
22500   PAI_DEQ_SET:
22600           MOV     [P_DEQ],SI              ;update ptr to next entry
22700   PAI_DEQ_RET:
22800           RET
22900   
23000   
23100   ;**     PAI_ENTRY - enqueue current scan state
23200   ;
23300   ; Inputs:
23400   ;       AL = direction flag
23500   ;       DX = scan count
23600   ;       $$SVRS set since queue overflow is detected
23700   ; Outputs:
23800   ;       none
23900   ; Registers:
24000   ;       AX,BX,CX,DI
24100   
24200   PAI_ENTRY:
24300           MOV     BX,[$O_CUR]
24400           MOV     CL,[$M_CUR]             ;fetch current offset and mask
24500   ;       now drop into enqueue
24600   
24700   
24800   ;**     PAI_ENQ - place specified entry into next queue location
24900   ;
25000   ; Inputs:
25100   ;       AL = direction flag
25200   ;       BX = cursor screen offset
25300   ;       CL = screen mask
25400   ;       DX = scan count
25500   ; Outputs:
25600   ;       none
25700   ; Registers:
25800   ;       AX,CH,DI
25900   
26000   PAI_ENQ:
26100           MOV     CH,AL
26200           MOV     AX,[LEN_Q]
26300           ADD     AX,SIZE_ENT             ;update length
26400           CMP     AX,[TOTAL_Q]            ;is queue area filled up ?
26500           JNB     PAI_ENQ_ERROR           ;yes, abort, no more room
26600           MOV     [LEN_Q],AX
26700           MOV     DI,[P_ENQ]              ;DI = ptr to next avail entry
26800           MOV     AX,BX
26900           STOSW
27000           MOV     AX,CX
27100           STOSW
27200           MOV     AX,DX
27300           STOSW                           ;enter into queue
27400           CMP     DI,[P_END_Q]            ;are we at end of queue area
27500           JB      PAI_ENQ_SET             ;no, continue
27600           MOV     DI,[$$SFPT]             ;yes, wrap around
27700           INC     DI
27800           INC     DI
27900   PAI_ENQ_SET:
28000           MOV     [P_ENQ],DI              ;update ptr to next queue entry
28100           RET
28200   PAI_ENQ_ERROR:
28300           JMP     $ERC_OM                 ;out of memory
28400   
28500   
28600   ;**     PAI_SCAN_L - scan left
28700   ;
28800   ; Inputs:
28900   ;       DX = skip count
29000   ; Function:
29100   ;       Save state where right scan stopped and reposition to saved
29200   ;       state, then scan left.
29300   ; Outputs:
29400   ;       AL = already painted flag
29500   ;       BX = scan count
29600   ;       Z set if scan count = 0, reset otherwise
29700   ; Registers:
29800   ;       ALL
29900   
30000   PAI_SCAN_L:
30100           MOV     AX,[$O_CUR]
30110           XCHG    AX,[$O_SAVE]
30120           MOV     [$O_CUR],AX
30200           MOV     AL,[$M_CUR]
30400           XCHG    AL,[$M_SAVE]
30410           MOV     [$M_CUR],AL             ;xchg current state with saved
30500           CALL    $SCANL                  ;scan left
30600           MOV     AL,CL
30700           MOV     [F_L_PAI],AL            ;save already painted flag
30800           OR      BX,BX                   ;set Z accordingly
30900           RET
31000   
31100   
31200   ;**     PAI_SCAN_R - scan right
31300   ;
31400   ; Inputs:
31500   ;       none
31600   ; Function:
31700   ;       Scan right the specified amount and save state when boundary
31800   ;       reached.
31900   ; Outputs:
32000   ;       AL = already painted flag
32100   ;       BX = scan count
32150   ;       DX = skip count
32200   ;       Z set if scan count = 0, reset otherwise
32300   ; Registers:
32400   ;       ALL
32500   
32600   PAI_SCAN_R:
32700           CALL    $SCANR                  ;scan right specified count
32800           MOV     [C_SCAN],BX
32900           MOV     [C_SKIP],DX             ;save updated counts
33000           MOV     AL,CL
33100           MOV     [F_R_PAI],AL            ;save already painted flag
33200           OR      BX,BX                   ;set Z accordingly
33300           RET
33400   
33500   
33600   CODE    ENDS
33700           END
