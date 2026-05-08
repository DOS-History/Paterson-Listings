        TITLE   CIRCLE graphics runtime routine



DATA    SEGMENT WORD PUBLIC 'RT_DATA'

        EXTRN   $AC:WORD, $ARG:WORD
        EXTRN   $FAC:BYTE
        EXTRN   $GAC_X:WORD, $GAC_Y:WORD

F_C_S           EQU     1               ;flag start angle spec
F_C_E           EQU     2               ;flag end angle spec
F_C_A           EQU     4               ;flag aspect ratio spec
F_C_S_NEG       EQU     8               ;flag negative start angle
F_C_E_NEG       EQU     16              ;flag negative end angle
F_C_POLAR       EQU     32              ;flag polarity
F_C_X_SCAL      EQU     64              ;flag X scaling

A_END   DD      ?                       ;S.P. end angle spec
A_START DD      ?                       ;S.P. start angle spec
ASPECT  DD      ?                       ;S.P. aspect ratio spec
C_ODD   DW      ?                       ;point count for odd octants
C_POINT DW      ?                       ;point count for plot
NO_PTS  DW      ?                       ;number of points per octant
OFF_C_X DW      ?                       ;X offset save area
OFF_C_Y DW      ?                       ;Y offset save area
SUM_CIR DW      0                       ;circle algorithm sum

F_CIR   DB      0                       ;circle flags byte

DATA    ENDS
        PAGE
CONST   SEGMENT WORD PUBLIC 'RT_DATA'


        EXTRN   $HALFSQR2:WORD, $ONE:WORD, $RECIP2PI:WORD

CONST   ENDS

DGROUP  GROUP   CONST,DATA
        PAGE
CODE    SEGMENT WORD PUBLIC 'CODE'


        PUBLIC  $CI0,$CI1,$CI2,$CI3

        EXTRN   $CINFAC:FAR, $CISA:FAR
        EXTRN   $DRAW_LINE:NEAR
        EXTRN   $ERC_FC:NEAR
        EXTRN   $GTASPC:NEAR
        EXTRN   $MAPXYC:NEAR
        EXTRN   $PARMS:NEAR
        EXTRN   $SAVREG:NEAR, $SCALXY:NEAR, $SCMP:NEAR
        EXTRN   $SDIV:NEAR, $SETC:NEAR, $SMUL:NEAR


        ASSUME  CS:CODE,  DS:DGROUP,  ES:DGROUP
        PAGE
CIR     PROC    FAR


;**     $CI1 - process optional start angle for CIRCLE statement
;
; Inputs:
;       BX = ptr to S.P. start angle in radians
; Function:
;       Process optional start angle for CIRCLE by saving it for later
; Outputs:
;       none
; Registers:
;       none

$CI1:
        PUSH    AX
        PUSH    DI
        MOV     AL,F_C_S                ;note start angle spec flag
        MOV     DI,OFFSET DGROUP:A_START
        JMP     SHORT CIR_SAVE          ;save start angle and return


;**     CI2 - process optional end angle for CIRCLE statement
;
; Inputs:
;       BX = ptr to S.P. end angle in radians
; Function:
;       Process optional end angle for CIRCLE by saving it for later
; Outputs:
;       none
; Registers:
;       none

$CI2:
        PUSH    AX
        PUSH    DI
        MOV     AL,F_C_E                ;note end angle spec flag
        MOV     DI,OFFSET DGROUP:A_END
        JMP     SHORT CIR_SAVE          ;save end angle and return


;**     CI3 - process optional aspect ratio for CIRCLE statement
;
; Inputs:
;       BX = ptr to S.P. aspect ratio
; Function:
;       Process optional aspect ratio for CIRCLE by saving it for later
;
; Outputs:
;       none
; Registers:
;       none

$CI3:
        PUSH    AX
        PUSH    DI
        MOV     AL,F_C_A                ;note aspect ratio spec flag
        MOV     DI,OFFSET DGROUP:ASPECT ;drop thru to save aspect ratio
CIR_SAVE:
        OR      [F_CIR],AL              ;set appropriate flag
        PUSH    SI
        MOV     SI,BX
        MOVSW
        MOVSW                           ;save specified parameter
        POP     SI
        POP     DI
        POP     AX                      ;restore regs
        RET

CIR     ENDP


;**     CI0 - process the CIRCLE statement
;
; Inputs:
;       BX = x coordinate of center
;       DX = y coordinate of center
;       CX = radius
;       AX = color specification
; Function:
;       Draw the circle at the specified center coordinates with the
;       speicified radius and of the specified color.  Arcs may be
;       drawn by specifiying the start and end angles; segments may
;       be drawn by specifying these angles as negative.  The circle
;       may be scaled by specifying the aspect ratio.
; Outputs:
;       graphics accumulators set at center
; Registers:
;       none

$CI0:
        CALL    $SAVREG                 ;save state
        PUSH    CX
        MOV     BP,CX                   ;save radius
        XCHG    AX,CX                   ;CX = color spec
        MOV     [$GAC_X],BX
        MOV     [$GAC_Y],DX             ;set for possible lines to cen
        CALL    $PARMS                  ;process center coords & color
        MOV     BX,BP
        CALL    $CISA                   ;convert radius to S.P.
        MOV     SI,OFFSET DGROUP:$AC
        MOV     DI,OFFSET DGROUP:$HALFSQR2
        CALL    $SMUL                   ;# points = radius * SQR(2)/2
        CALL    $CINFAC                 ;convert to integer
        MOV     [NO_PTS],BX
        XOR     BX,BX                   ;default start angle = 0
        TEST    [F_CIR],F_C_S           ;was start angle specified ?
        JZ      CIR_E_ANG               ;no, use default
        MOV     SI,OFFSET DGROUP:A_START ;yes, set ptr to angle
        MOV     AL,F_C_S_NEG            ;note negative start angle flag
        CALL    CIR_ANGLE               ;process angle spec
CIR_E_ANG:
        PUSH    BX                      ;save integer start angle
        MOV     BX,-1                   ;default end angle = infinity
        TEST    [F_CIR],F_C_E           ;was end angle specified ?
        JZ      CIR_COMP                ;no, use default
        MOV     SI,OFFSET DGROUP:A_END  ;yes, set ptr to angle saved
        MOV     AL,F_C_E_NEG            ;note negative end angle flag
        CALL    CIR_ANGLE               ;process angle spec
CIR_COMP:
        POP     AX                      ;fetch start angle
        CMP     AX,BX                   ;is start .LT. end ?
        JNA     CIR_ASPECT              ;yes, proceed
        XCHG    AX,BX                   ;no, referse start and end
        PUSH    AX
        MOV     AL,[F_CIR]
        OR      AL,F_C_POLAR            ;flag reverse polarity
        MOV     CL,AL
        AND     AL,F_C_S_NEG OR F_C_E_NEG ;was either angle negative?
        JZ      CIR_FLAG_A              ;no, continue
        XOR     AL,F_C_S_NEG OR F_C_E_NEG ;yes, were they both negative ?
        JZ      CIR_FLAG_A              ;yes, continue
        XOR     CL,F_C_S_NEG OR F_C_E_NEG ;no, reverse start and end flag
CIR_FLAG_A:
        MOV     [F_CIR],CL              ;update flag byte
        POP     AX
CIR_ASPECT:
        MOV     [A_START],AX
        MOV     [A_END],BX              ;save start and end angles
        TEST    [F_CIR],F_C_A           ;was aspect ratio speicified ?
        JNZ     CIR_A_CALC              ;yes, process it
        CALL    $GTASPC                 ;no, fetch default aspect ratio
        JMP     SHORT CIR_LOOP_SET
CIR_A_CALC:
        MOV     SI,OFFSET DGROUP:ASPECT ;fetch ptr to saved ratio
        MOV     DI,OFFSET DGROUP:$AC
        MOVSW
        MOVSW                           ;aspect to $AC
        CMP     [$FAC],81H              ;is aspect ratio .GT. 1 ?
        JB      CIR_A_SET               ;no, process normally
        OR      [F_CIR],F_C_X_SCAL      ;yes, flag X scaling
        SUB     DI,4                    ;DI = ptr to $AC
        MOV     SI,OFFSET DGROUP:$ONE
        CALL    $SDIV                   ;compute 1/aspect ratio
;
;       Set up aspect * 256 for fixed point calculations
;
CIR_A_SET:
        ADD     [$FAC],8                ;aspect = aspect * 256
        CALL    $CINFAC                 ;convert to integer
;
;       Algorithm used for circle is:
;
;       X = radius * 2 (rounded up)
;       Y = 0
;       SUM = 0
;       LOOP until EXIT
;               IF Y is even then
;                       REFLECT ((X+1)/2,(Y+1)/2)  /*plot 4 points*/
;                       IF X .LE. Y then EXIT
;               SUM = SUM + (2*X) + 1
;               Y = Y + 1
;               IF SUM .GT. 0 then
;                       SUM = SUM - (2*X) + 1
;                       X = X - 1
;
CIR_LOOP_SET:
        MOV     [ASPECT],BX             ;set fixed point aspect ratio
        POP     AX                      ;retreive radius
        SAL     AX,1
        XCHG    AX,BP                   ;BP = Y = radius * 2
        XOR     AX,AX                   ;AX = Y = 0
CIR_LOOP:
        TEST    AX,1
        JNZ     CIR_UPDATE              ;don't plot points if Y is odd
        PUSH    BP
        PUSH    AX                      ;save X and Y
        INC     AX                      ;round up
        SAR     AX,1                    ;AX = (Y+1)/2
        MOV     [C_POINT],AX            ;initial point count = Y
        CALL    CIR_SCALE               ;scale Y with aspect ratio
        MOV     [OFF_C_X],BX            ;X offset = Y
        NEG     AX
        XCHG    AX,DI                   ;DI = - scaled Y
        XCHG    AX,BP
        INC     AX                      ;round up
        SAR     AX,1                    ;AX = (X+1)/2
        CALL    CIR_SCALE               ;scale X with aspect ratio
        MOV     [OFF_C_Y],AX            ;Y offset = scaled X
        MOV     BP,BX                   ;BP = X
        MOV     [C_ODD],0               ;initial odd octant count = 0
        CALL    CIR_PLOT                ;plot 4 points
        MOV     AX,[NO_PTS]             ;fetch # points per octant
        MOV     [C_ODD],AX              ;set count for odd octants
        SUB     AX,[C_POINT]
        MOV     [C_POINT],AX            ;pnt count=pnts/oct-pnt count
        NEG     DI
        NEG     [OFF_C_X]               ;odd octants plotted backwards
        CALL    CIR_PLOT                ;plot 4 symmetric points
        POP     AX                      ;AX = Y
        POP     BP                      ;BP = X
        CMP     AX,BP                   ;aren't you finished yet ?
        JNB     CIR_RET                 ;yes, thank God
CIR_UPDATE:
        MOV     DX,[SUM_CIR]            ;no, well, update SUM then
        INC     AX                      ;Y = Y + 1
        MOV     DI,AX                   ;save Y
        SAL     AX,1
        DEC     AX
        ADD     DX,AX                   ;calc SUM + (2*Y) + 1
        JS      CIR_NO_DEC
        MOV     AX,BP
        SAL     AX,1
        DEC     AX
        SUB     DX,AX                   ;calc SUM - (2*X) + 1
        DEC     BP                      ;X = X - 1
CIR_NO_DEC:
        MOV     [SUM_CIR],DX            ;update SUM
        XCHG    AX,DI                   ;AX = Y
        JMP     CIR_LOOP
CIR_RET:
        XOR     AX,AX                   ;clear all flags before going
        MOV     [SUM_CIR],AX
        MOV     [F_CIR],AL
        RET
        PAGE


;**     CIR_ANGLE - convert angle specification to integer point #
;
; Inputs:
;       AL = negative angle flag bit
;       SI = ptr to S.P. angle (in radians)
;       $$SVRS set since illegal angle spec detected
; Outputs:
;       BX = integer angle
; Registers:
;       ALL

CIR_ANGLE:
        MOV     DI,OFFSET DGROUP:$AC
        MOV     BP,DI                   ;save ptr to $AC
        MOVSW
        MOVSW                           ;angle to $AC
        XOR     BX,BX
        CMP     [$FAC],BL               ;is angle zero ?
        JZ      CIR_A_RET               ;yes, that was easy
        TEST    [$FAC-1],80H            ;is angle negative ?
        JZ      CIR_A_POS               ;no, continue
        OR      [F_CIR],AL              ;yes, set appropriate flag
        XOR     [$FAC-1],80H            ;and make positive
CIR_A_POS:
        MOV     SI,BP
        MOV     DI,OFFSET DGROUP:$RECIP2PI
        CALL    $SMUL                   ;calc angle / (2 * PI)
        MOV     SI,BP
        MOV     DI,OFFSET DGROUP:$ONE
        CALL    $SCMP                   ;is scaled angle .GT. 1 ?
        JA      CIR_A_ERROR             ;yes, too large, error
        MOV     SI,BP
        MOV     DI,OFFSET DGROUP:$ARG
        MOVSW
        MOVSW                           ;copy to ARG for temp save
        MOV     BX,[NO_PTS]
        SAL     BX,1
        SAL     BX,1
        SAL     BX,1                    ;*8 for true circumfrance
        CALL    $CISA                   ;convert # pts to S.P.
        MOV     SI,BP
        MOV     DI,OFFSET DGROUP:$ARG
        CALL    $SMUL                   ;calc # pts * (angle*PI/2)
        CALL    $CINFAC                 ;convert to integer
CIR_A_RET:
        RET

CIR_A_ERROR:
        JMP     $ERC_FC                 ;illegal function call


;**     CIR_PLOT - plot (+X,-SY),(-Y,-SX),(-X,+SY),(+Y,-SX)
;
; Inputs:
;       BP = X
;       DI = -Y
; Function:
;       Plot the 4 symmetric points on the circle.
; Outputs:
;       none
; Registers:
;       ALL

;
CIR_PLOT:
        MOV     AX,4                    ;plot 4 points
CIR_P_LOOP:
        PUSH    AX                      ;save count
        MOV     CX,BP
        MOV     DX,DI                   ;fetch X,Y
        ADD     CX,[$GAC_X]
        ADD     DX,[$GAC_Y]             ;CX,DX = screen coords
        MOV     BX,[C_ODD]              ;fetch # pts * octant * 8
        MOV     AX,[NO_PTS]
        SAL     AX,1
        ADD     AX,BX                   ;add SQR(2)*radius for next oct
        MOV     [C_ODD],AX
        MOV     AX,[C_POINT]
        ADD     AX,BX                   ;calc this point's point count
        CMP     AX,[A_START]            ;are we at start of arc ?
        JE      CIR_P_SC                ;yes, check for center line
        JB      CIR_P_NOT               ;no, not even between s and e
        CMP     AX,[A_END]              ;no, are we at end of arc ?
        MOV     AL,[F_CIR]
        JE      CIR_P_EC                ;yes, check for center line
        JB      CIR_P_BET               ;no, between start and end
CIR_P_NOT:
        TEST    [F_CIR],F_C_POLAR       ;is polarity flag set ?
        JNZ     CIR_P                   ;yes, we're reversed, plot it
        JMP     SHORT CIR_P_FIN         ;no, ignore point
CIR_P_SC:
        TEST    [F_CIR],F_C_S_NEG       ;was start spec negative ?
        JZ      CIR_P                   ;no, just plot start point
        MOV     AL,NOT F_C_S_NEG
        JMP     SHORT CIR_P_LIN         ;yes, draw line to center
CIR_P_EC:
        TEST    AL,F_C_E_NEG            ;was end spec negative ?
        JZ      CIR_P                   ;no, just plot end point
        MOV     AL,NOT F_C_E_NEG
CIR_P_LIN:
        AND     [F_CIR],AL              ;reset neg flag to avoid repeat
        CALL    $SCALXY                 ;check for point on screen
        JNC     CIR_P_FIN               ;off screen, ignore
        PUSH    BP
        PUSH    DI                      ;save X,Y
        CALL    $DRAW_LINE              ;draw line from point to center
        POP     DI
        POP     BP                      ;restore X,Y
        JMP     SHORT CIR_P_FIN
CIR_P:
        CALL    $SCALXY                 ;check for point on screen
        JNC     CIR_P_FIN               ;off screen, ignore
        CALL    $MAPXYC                 ;map coords to point
        CALL    $SETC                   ;draw the point
        JMP     SHORT CIR_P_FIN
CIR_P_BET:
        TEST    AL,F_C_POLAR            ;is polarity flag set ?
        JZ      CIR_P                   ;no, plot the point
CIR_P_FIN:
        POP     AX                      ;fetch count
        DEC     AX
        JZ      CIR_P_RET               ;finished all 4 points, return
        XCHG    BP,[OFF_C_X]            ;new X offset = old X
        NEG     BP                      ;new X = - old X offset
        XCHG    DI,[OFF_C_Y]            ;new Y offset = old Y
        NEG     DI                      ;new Y = - old Y offset
        JMP     CIR_P_LOOP
CIR_P_RET:
        RET


;**     CIR_SCALE - scale offset from center by aspect ratio
;
; Inputs:
;       AX = unscaled offset
; Function:
;       Multiply specified offset by aspect ratio.  Since 1 is a
;       common aspect ratio value, it is checked for explicitly.
; Outputs:
;       AX = scaled offset
;       BX = unscaled offset
; Registers:
;       DX

CIR_SCALE:
        MOV     BX,AX
        MOV     DX,[ASPECT]
        OR      DH,DH                   ;is aspect ratio = 1 (*256) ?
        JNZ     CIR_S_RET               ;yes, just return offset
        MUL     DX                      ;no, calc offset * aspect ratio
        ADD     AX,128                  ;round up
        XCHG    AH,AL
        XCHG    AH,DL                   ;fixed point multiplication
        TEST    [F_CIR],F_C_X_SCAL      ;is X axis being scaled ?
        JZ      CIR_S_RET               ;no, return original in BX
        XCHG    AX,BX
CIR_S_RET:
        RET

CODE    ENDS
        END
