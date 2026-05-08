00100           TITLE   CIRCLE graphics runtime routine
00200   
00300   
00400   
00500   DATA    SEGMENT WORD PUBLIC 'RT_DATA'
00600   
00700           EXTRN   $AC:WORD, $ARG:WORD
00800           EXTRN   $FAC:BYTE
00900           EXTRN   $GAC_X:WORD, $GAC_Y:WORD
01000   
01100   F_C_S           EQU     1               ;flag start angle spec
01200   F_C_E           EQU     2               ;flag end angle spec
01300   F_C_A           EQU     4               ;flag aspect ratio spec
01400   F_C_S_NEG       EQU     8               ;flag negative start angle
01500   F_C_E_NEG       EQU     16              ;flag negative end angle
01600   F_C_POLAR       EQU     32              ;flag polarity
01700   F_C_X_SCAL      EQU     64              ;flag X scaling
01800   
01900   A_END   DD      ?                       ;S.P. end angle spec
02000   A_START DD      ?                       ;S.P. start angle spec
02100   ASPECT  DD      ?                       ;S.P. aspect ratio spec
02200   C_ODD   DW      ?                       ;point count for odd octants
02300   C_POINT DW      ?                       ;point count for plot
02400   NO_PTS  DW      ?                       ;number of points per octant
02500   OFF_C_X DW      ?                       ;X offset save area
02600   OFF_C_Y DW      ?                       ;Y offset save area
02700   SUM_CIR DW      0                       ;circle algorithm sum
02800   
02900   F_CIR   DB      0                       ;circle flags byte
03000   
03100   DATA    ENDS
03200           PAGE
03300   CONST   SEGMENT WORD PUBLIC 'RT_DATA'
03400   
03500   
03600           EXTRN   $HALFSQR2:WORD, $ONE:WORD, $RECIP2PI:WORD
03700   
03800   CONST   ENDS
03900   
04000   DGROUP  GROUP   CONST,DATA
04100           PAGE
04200   CODE    SEGMENT WORD PUBLIC 'CODE'
04300   
04400   
04500           PUBLIC  $CI0,$CI1,$CI2,$CI3
04600   
04700           EXTRN   $CINFAC:FAR, $CISA:FAR
04800           EXTRN   $DRAW_LINE:NEAR
04900           EXTRN   $ERC_FC:NEAR
05000           EXTRN   $GTASPC:NEAR
05100           EXTRN   $MAPXYC:NEAR
05200           EXTRN   $PARMS:NEAR
05300           EXTRN   $SAVREG:NEAR, $SCALXY:NEAR, $SCMP:NEAR
05400           EXTRN   $SDIV:NEAR, $SETC:NEAR, $SMUL:NEAR
05500   
05600   
05700           ASSUME  CS:CODE,  DS:DGROUP,  ES:DGROUP
05800           PAGE
05900   CIR     PROC    FAR
06000   
06100   
06200   ;**     $CI1 - process optional start angle for CIRCLE statement
06300   ;
06400   ; Inputs:
06500   ;       BX = ptr to S.P. start angle in radians
06600   ; Function:
06700   ;       Process optional start angle for CIRCLE by saving it for later
06800   ; Outputs:
06900   ;       none
07000   ; Registers:
07100   ;       none
07200   
07300   $CI1:
07400           PUSH    AX
07500           PUSH    DI
07600           MOV     AL,F_C_S                ;note start angle spec flag
07700           MOV     DI,OFFSET DGROUP:A_START
07800           JMP     SHORT CIR_SAVE          ;save start angle and return
07900   
08000   
08100   ;**     CI2 - process optional end angle for CIRCLE statement
08200   ;
08300   ; Inputs:
08400   ;       BX = ptr to S.P. end angle in radians
08500   ; Function:
08600   ;       Process optional end angle for CIRCLE by saving it for later
08700   ; Outputs:
08800   ;       none
08900   ; Registers:
09000   ;       none
09100   
09200   $CI2:
09300           PUSH    AX
09400           PUSH    DI
09500           MOV     AL,F_C_E                ;note end angle spec flag
09600           MOV     DI,OFFSET DGROUP:A_END
09700           JMP     SHORT CIR_SAVE          ;save end angle and return
09800   
09900   
10000   ;**     CI3 - process optional aspect ratio for CIRCLE statement
10100   ;
10200   ; Inputs:
10300   ;       BX = ptr to S.P. aspect ratio
10400   ; Function:
10500   ;       Process optional aspect ratio for CIRCLE by saving it for later
10600   ;
10700   ; Outputs:
10800   ;       none
10900   ; Registers:
11000   ;       none
11100   
11200   $CI3:
11300           PUSH    AX
11400           PUSH    DI
11500           MOV     AL,F_C_A                ;note aspect ratio spec flag
11600           MOV     DI,OFFSET DGROUP:ASPECT ;drop thru to save aspect ratio
11700   CIR_SAVE:
11800           OR      [F_CIR],AL              ;set appropriate flag
11900           PUSH    SI
12000           MOV     SI,BX
12100           MOVSW
12200           MOVSW                           ;save specified parameter
12300           POP     SI
12400           POP     DI
12500           POP     AX                      ;restore regs
12600           RET
12700   
12800   CIR     ENDP
12900   
13000   
13100   ;**     CI0 - process the CIRCLE statement
13200   ;
13300   ; Inputs:
13400   ;       BX = x coordinate of center
13500   ;       DX = y coordinate of center
13600   ;       CX = radius
13700   ;       AX = color specification
13800   ; Function:
13900   ;       Draw the circle at the specified center coordinates with the
14000   ;       speicified radius and of the specified color.  Arcs may be
14100   ;       drawn by specifiying the start and end angles; segments may
14200   ;       be drawn by specifying these angles as negative.  The circle
14300   ;       may be scaled by specifying the aspect ratio.
14400   ; Outputs:
14500   ;       graphics accumulators set at center
14600   ; Registers:
14700   ;       none
14800   
14900   $CI0:
15000           CALL    $SAVREG                 ;save state
15100           PUSH    CX
15200           MOV     BP,CX                   ;save radius
15300           XCHG    AX,CX                   ;CX = color spec
15400           MOV     [$GAC_X],BX
15500           MOV     [$GAC_Y],DX             ;set for possible lines to cen
15600           CALL    $PARMS                  ;process center coords & color
15700           MOV     BX,BP
15800           CALL    $CISA                   ;convert radius to S.P.
15900           MOV     SI,OFFSET DGROUP:$AC
16000           MOV     DI,OFFSET DGROUP:$HALFSQR2
16100           CALL    $SMUL                   ;# points = radius * SQR(2)/2
16200           CALL    $CINFAC                 ;convert to integer
16300           MOV     [NO_PTS],BX
16400           XOR     BX,BX                   ;default start angle = 0
16500           TEST    [F_CIR],F_C_S           ;was start angle specified ?
16600           JZ      CIR_E_ANG               ;no, use default
16700           MOV     SI,OFFSET DGROUP:A_START ;yes, set ptr to angle
16800           MOV     AL,F_C_S_NEG            ;note negative start angle flag
16900           CALL    CIR_ANGLE               ;process angle spec
17000   CIR_E_ANG:
17100           PUSH    BX                      ;save integer start angle
17200           MOV     BX,-1                   ;default end angle = infinity
17300           TEST    [F_CIR],F_C_E           ;was end angle specified ?
17400           JZ      CIR_COMP                ;no, use default
17500           MOV     SI,OFFSET DGROUP:A_END  ;yes, set ptr to angle saved
17600           MOV     AL,F_C_E_NEG            ;note negative end angle flag
17700           CALL    CIR_ANGLE               ;process angle spec
17800   CIR_COMP:
17900           POP     AX                      ;fetch start angle
18000           CMP     AX,BX                   ;is start .LT. end ?
18100           JNA     CIR_ASPECT              ;yes, proceed
18200           XCHG    AX,BX                   ;no, referse start and end
18300           PUSH    AX
18400           MOV     AL,[F_CIR]
18500           OR      AL,F_C_POLAR            ;flag reverse polarity
18600           MOV     CL,AL
18700           AND     AL,F_C_S_NEG OR F_C_E_NEG ;was either angle negative?
18800           JZ      CIR_FLAG_A              ;no, continue
18900           XOR     AL,F_C_S_NEG OR F_C_E_NEG ;yes, were they both negative ?
19000           JZ      CIR_FLAG_A              ;yes, continue
19100           XOR     CL,F_C_S_NEG OR F_C_E_NEG ;no, reverse start and end flag
19200   CIR_FLAG_A:
19300           MOV     [F_CIR],CL              ;update flag byte
19400           POP     AX
19500   CIR_ASPECT:
19600           MOV     [A_START],AX
19700           MOV     [A_END],BX              ;save start and end angles
19800           TEST    [F_CIR],F_C_A           ;was aspect ratio speicified ?
19900           JNZ     CIR_A_CALC              ;yes, process it
20000           CALL    $GTASPC                 ;no, fetch default aspect ratio
20100           JMP     SHORT CIR_LOOP_SET
20200   CIR_A_CALC:
20300           MOV     SI,OFFSET DGROUP:ASPECT ;fetch ptr to saved ratio
20400           MOV     DI,OFFSET DGROUP:$AC
20500           MOVSW
20600           MOVSW                           ;aspect to $AC
20700           CMP     [$FAC],81H              ;is aspect ratio .GT. 1 ?
20800           JB      CIR_A_SET               ;no, process normally
20900           OR      [F_CIR],F_C_X_SCAL      ;yes, flag X scaling
21000           SUB     DI,4                    ;DI = ptr to $AC
21100           MOV     SI,OFFSET DGROUP:$ONE
21200           CALL    $SDIV                   ;compute 1/aspect ratio
21300   ;
21400   ;       Set up aspect * 256 for fixed point calculations
21500   ;
21600   CIR_A_SET:
21700           ADD     [$FAC],8                ;aspect = aspect * 256
21800           CALL    $CINFAC                 ;convert to integer
21900   ;
22000   ;       Algorithm used for circle is:
22100   ;
22200   ;       X = radius * 2 (rounded up)
22300   ;       Y = 0
22400   ;       SUM = 0
22500   ;       LOOP until EXIT
22600   ;               IF Y is even then
22700   ;                       REFLECT ((X+1)/2,(Y+1)/2)  /*plot 4 points*/
22800   ;                       IF X .LE. Y then EXIT
22900   ;               SUM = SUM + (2*X) + 1
23000   ;               Y = Y + 1
23100   ;               IF SUM .GT. 0 then
23200   ;                       SUM = SUM - (2*X) + 1
23300   ;                       X = X - 1
23400   ;
23500   CIR_LOOP_SET:
23600           MOV     [ASPECT],BX             ;set fixed point aspect ratio
23700           POP     AX                      ;retreive radius
23800           SAL     AX,1
23900           XCHG    AX,BP                   ;BP = Y = radius * 2
24000           XOR     AX,AX                   ;AX = Y = 0
24100   CIR_LOOP:
24200           TEST    AX,1
24300           JNZ     CIR_UPDATE              ;don't plot points if Y is odd
24400           PUSH    BP
24500           PUSH    AX                      ;save X and Y
24600           INC     AX                      ;round up
24700           SAR     AX,1                    ;AX = (Y+1)/2
24800           MOV     [C_POINT],AX            ;initial point count = Y
24900           CALL    CIR_SCALE               ;scale Y with aspect ratio
25000           MOV     [OFF_C_X],BX            ;X offset = Y
25100           NEG     AX
25200           XCHG    AX,DI                   ;DI = - scaled Y
25300           XCHG    AX,BP
25400           INC     AX                      ;round up
25500           SAR     AX,1                    ;AX = (X+1)/2
25600           CALL    CIR_SCALE               ;scale X with aspect ratio
25700           MOV     [OFF_C_Y],AX            ;Y offset = scaled X
25800           MOV     BP,BX                   ;BP = X
25900           MOV     [C_ODD],0               ;initial odd octant count = 0
26000           CALL    CIR_PLOT                ;plot 4 points
26100           MOV     AX,[NO_PTS]             ;fetch # points per octant
26200           MOV     [C_ODD],AX              ;set count for odd octants
26300           SUB     AX,[C_POINT]
26400           MOV     [C_POINT],AX            ;pnt count=pnts/oct-pnt count
26500           NEG     DI
26600           NEG     [OFF_C_X]               ;odd octants plotted backwards
26700           CALL    CIR_PLOT                ;plot 4 symmetric points
26800           POP     AX                      ;AX = Y
26900           POP     BP                      ;BP = X
27000           CMP     AX,BP                   ;aren't you finished yet ?
27100           JNB     CIR_RET                 ;yes, thank God
27200   CIR_UPDATE:
27300           MOV     DX,[SUM_CIR]            ;no, well, update SUM then
27400           INC     AX                      ;Y = Y + 1
27500           MOV     DI,AX                   ;save Y
27600           SAL     AX,1
27700           DEC     AX
27800           ADD     DX,AX                   ;calc SUM + (2*Y) + 1
27900           JS      CIR_NO_DEC
28000           MOV     AX,BP
28100           SAL     AX,1
28200           DEC     AX
28300           SUB     DX,AX                   ;calc SUM - (2*X) + 1
28400           DEC     BP                      ;X = X - 1
28500   CIR_NO_DEC:
28600           MOV     [SUM_CIR],DX            ;update SUM
28700           XCHG    AX,DI                   ;AX = Y
28800           JMP     CIR_LOOP
28900   CIR_RET:
29000           XOR     AX,AX                   ;clear all flags before going
29100           MOV     [SUM_CIR],AX
29200           MOV     [F_CIR],AL
29300           RET
29400           PAGE
29500   
29600   
29700   ;**     CIR_ANGLE - convert angle specification to integer point #
29800   ;
29900   ; Inputs:
30000   ;       AL = negative angle flag bit
30100   ;       SI = ptr to S.P. angle (in radians)
30200   ;       $$SVRS set since illegal angle spec detected
30300   ; Outputs:
30400   ;       BX = integer angle
30500   ; Registers:
30600   ;       ALL
30700   
30800   CIR_ANGLE:
30900           MOV     DI,OFFSET DGROUP:$AC
31000           MOV     BP,DI                   ;save ptr to $AC
31100           MOVSW
31200           MOVSW                           ;angle to $AC
31300           XOR     BX,BX
31400           CMP     [$FAC],BL               ;is angle zero ?
31500           JZ      CIR_A_RET               ;yes, that was easy
31600           TEST    [$FAC-1],80H            ;is angle negative ?
31700           JZ      CIR_A_POS               ;no, continue
31800           OR      [F_CIR],AL              ;yes, set appropriate flag
31900           XOR     [$FAC-1],80H            ;and make positive
32000   CIR_A_POS:
32100           MOV     SI,BP
32200           MOV     DI,OFFSET DGROUP:$RECIP2PI
32300           CALL    $SMUL                   ;calc angle / (2 * PI)
32400           MOV     SI,BP
32500           MOV     DI,OFFSET DGROUP:$ONE
32600           CALL    $SCMP                   ;is scaled angle .GT. 1 ?
32700           JA      CIR_A_ERROR             ;yes, too large, error
32800           MOV     SI,BP
32900           MOV     DI,OFFSET DGROUP:$ARG
33000           MOVSW
33100           MOVSW                           ;copy to ARG for temp save
33200           MOV     BX,[NO_PTS]
33300           SAL     BX,1
33400           SAL     BX,1
33500           SAL     BX,1                    ;*8 for true circumfrance
33600           CALL    $CISA                   ;convert # pts to S.P.
33700           MOV     SI,BP
33800           MOV     DI,OFFSET DGROUP:$ARG
33900           CALL    $SMUL                   ;calc # pts * (angle*PI/2)
34000           CALL    $CINFAC                 ;convert to integer
34100   CIR_A_RET:
34200           RET
34300   
34400   CIR_A_ERROR:
34500           JMP     $ERC_FC                 ;illegal function call
34600   
34700   
34800   ;**     CIR_PLOT - plot (+X,-SY),(-Y,-SX),(-X,+SY),(+Y,-SX)
34900   ;
35000   ; Inputs:
35100   ;       BP = X
35200   ;       DI = -Y
35300   ; Function:
35400   ;       Plot the 4 symmetric points on the circle.
35500   ; Outputs:
35600   ;       none
35700   ; Registers:
35800   ;       ALL
35900   
36000   ;
36100   CIR_PLOT:
36200           MOV     AX,4                    ;plot 4 points
36300   CIR_P_LOOP:
36400           PUSH    AX                      ;save count
36500           MOV     CX,BP
36600           MOV     DX,DI                   ;fetch X,Y
36700           ADD     CX,[$GAC_X]
36800           ADD     DX,[$GAC_Y]             ;CX,DX = screen coords
36900           MOV     BX,[C_ODD]              ;fetch # pts * octant * 8
37000           MOV     AX,[NO_PTS]
37100           SAL     AX,1
37200           ADD     AX,BX                   ;add SQR(2)*radius for next oct
37300           MOV     [C_ODD],AX
37400           MOV     AX,[C_POINT]
37500           ADD     AX,BX                   ;calc this point's point count
37600           CMP     AX,[A_START]            ;are we at start of arc ?
37700           JE      CIR_P_SC                ;yes, check for center line
37800           JB      CIR_P_NOT               ;no, not even between s and e
37900           CMP     AX,[A_END]              ;no, are we at end of arc ?
38000           MOV     AL,[F_CIR]
38100           JE      CIR_P_EC                ;yes, check for center line
38200           JB      CIR_P_BET               ;no, between start and end
38300   CIR_P_NOT:
38400           TEST    [F_CIR],F_C_POLAR       ;is polarity flag set ?
38500           JNZ     CIR_P                   ;yes, we're reversed, plot it
38600           JMP     SHORT CIR_P_FIN         ;no, ignore point
38700   CIR_P_SC:
38800           TEST    [F_CIR],F_C_S_NEG       ;was start spec negative ?
38900           JZ      CIR_P                   ;no, just plot start point
39000           MOV     AL,NOT F_C_S_NEG
39100           JMP     SHORT CIR_P_LIN         ;yes, draw line to center
39200   CIR_P_EC:
39300           TEST    AL,F_C_E_NEG            ;was end spec negative ?
39400           JZ      CIR_P                   ;no, just plot end point
39500           MOV     AL,NOT F_C_E_NEG
39600   CIR_P_LIN:
39700           AND     [F_CIR],AL              ;reset neg flag to avoid repeat
39800           CALL    $SCALXY                 ;check for point on screen
39900           JNC     CIR_P_FIN               ;off screen, ignore
40000           PUSH    BP
40100           PUSH    DI                      ;save X,Y
40200           CALL    $DRAW_LINE              ;draw line from point to center
40300           POP     DI
40400           POP     BP                      ;restore X,Y
40500           JMP     SHORT CIR_P_FIN
40600   CIR_P:
40700           CALL    $SCALXY                 ;check for point on screen
40800           JNC     CIR_P_FIN               ;off screen, ignore
40900           CALL    $MAPXYC                 ;map coords to point
41000           CALL    $SETC                   ;draw the point
41100           JMP     SHORT CIR_P_FIN
41200   CIR_P_BET:
41300           TEST    AL,F_C_POLAR            ;is polarity flag set ?
41400           JZ      CIR_P                   ;no, plot the point
41500   CIR_P_FIN:
41600           POP     AX                      ;fetch count
41700           DEC     AX
41800           JZ      CIR_P_RET               ;finished all 4 points, return
41900           XCHG    BP,[OFF_C_X]            ;new X offset = old X
42000           NEG     BP                      ;new X = - old X offset
42100           XCHG    DI,[OFF_C_Y]            ;new Y offset = old Y
42200           NEG     DI                      ;new Y = - old Y offset
42300           JMP     CIR_P_LOOP
42400   CIR_P_RET:
42500           RET
42600   
42700   
42800   ;**     CIR_SCALE - scale offset from center by aspect ratio
42900   ;
43000   ; Inputs:
43100   ;       AX = unscaled offset
43200   ; Function:
43300   ;       Multiply specified offset by aspect ratio.  Since 1 is a
43400   ;       common aspect ratio value, it is checked for explicitly.
43500   ; Outputs:
43600   ;       AX = scaled offset
43700   ;       BX = unscaled offset
43800   ; Registers:
43900   ;       DX
44000   
44100   CIR_SCALE:
44200           MOV     BX,AX
44300           MOV     DX,[ASPECT]
44400           OR      DH,DH                   ;is aspect ratio = 1 (*256) ?
44500           JNZ     CIR_S_RET               ;yes, just return offset
44600           MUL     DX                      ;no, calc offset * aspect ratio
44700           ADD     AX,128                  ;round up
44800           XCHG    AH,AL
44900           XCHG    AH,DL                   ;fixed point multiplication
45000           TEST    [F_CIR],F_C_X_SCAL      ;is X axis being scaled ?
45100           JZ      CIR_S_RET               ;no, return original in BX
45200           XCHG    AX,BX
45300   CIR_S_RET:
45400           RET
45500   
45600   CODE    ENDS
45700           END
