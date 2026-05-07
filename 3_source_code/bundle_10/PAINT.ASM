        TITLE   PAINT graphics runtime routine


DATA    SEGMENT WORD PUBLIC 'RT_DATA'

        EXTRN   $M_CUR:BYTE, $M_SAVE:BYTE
        EXTRN   $O_CUR:WORD, $O_SAVE:WORD
        EXTRN   $$SFPT:WORD

C_SCAN  DW      ?                       ;scan count
C_SKIP  DW      ?                       ;skip count
DIRECT  DB      ?                       ;paint direction
F_L_PAI DB      ?                       ;flag for left already painted
F_R_PAI DB      ?                       ;flag for right already painted
LEN_Q   DW      ?                       ;current queue length
P_DEQ   DW      ?                       ;pointer to dequeue entry
P_ENQ   DW      ?                       ;pointer to enqueue entry
P_END_Q DW      ?                       ;pointer to end of queue area
TOTAL_Q DW      ?                       ;total size available for queue

DATA    ENDS


CONST   SEGMENT WORD PUBLIC 'RT_DATA'

SIZE_ENT EQU    6                       ;queue entry size

SIZE_PAI EQU    4*1024                  ;minimal size required to be
                                        ;available in string space
                                        ;for PAINT queue, otherwise
                                        ;a major garbage collection
                                        ;is performed

CONST   ENDS

DGROUP  GROUP   CONST,DATA
        PAGE


CODE    SEGMENT WORD PUBLIC 'CODE'


        PUBLIC  $PAI

        EXTRN   $ERC_FC:NEAR, $ERC_OM:NEAR
        EXTRN   $LEFTC:NEAR
        EXTRN   $MAPXYC:NEAR
        EXTRN   $PARMS:NEAR, $PNTINI:NEAR
        EXTRN   $SAVREG:NEAR, $SCANL:NEAR, $SCANR:NEAR
        EXTRN   $TDOWNC:NEAR, $TUPC:NEAR
        EXTRN   $$MAG:NEAR


        ASSUME  CS:CODE,  DS:DGROUP,  ES:DGROUP
        PAGE


;**     $PAI - process the PAINT statement
;
; Inputs:
;       BX = x coordinate of point in area to be painted
;       DX = y coordinate of point in area to be painted
;       CX = paint color specification
;       AX = border color specification
; Function:
;       Paint the figure containing the specified point and with
;       edges of the specified boundary color in the specified
;       paint color.
;       The algorithm used is copied from ADVGRP.MAC in the
;       Interpreter; a queue is used to save the skipped area
;       boundaries.  The space for the queue is obtained from the
;       compiler runtime string space.
; Outouts:
;       none
; Registers:
;       none

$PAI:
        CALL    $SAVREG                 ;save state
        XCHG    AX,BP                   ;save border color spec
        CALL    $PARMS                  ;process coords and paint color
        XCHG    AX,BP                   ;retrieve border color spec
        MOV     BP,CX                   ;save scaled x coord
        CALL    $PNTINI                 ;initialize for paint
        JC      PAI_ERROR               ;error if invalid border color
        MOV     CX,BP                   ;retrieve x coord
        CALL    $MAPXYC                 ;map coords to screen position
        MOV     SI,[$$SFPT]             ;fetch ptr to next string area
        LODSW                           ;AX = size of area
        CMP     AX,SIZE_PAI             ;will size be adequate ?
        JNB     PAI_SIZE_SET            ;probably, continue
        CALL    $$MAG                   ;maybe not, grabage collect
        MOV     SI,[$$SFPT]
        LODSW                           ;now get ptr to area and size
PAI_SIZE_SET:
        DEC     AX                      ;calculate # bytes left
        MOV     [TOTAL_Q],AX            ;save as total queue size
        MOV     [P_ENQ],SI
        MOV     [P_DEQ],SI              ;initialize queue ptrs
        ADD     AX,SI
        SUB     AX,SIZE_ENT-1
        MOV     [P_END_Q],AX            ;save ptr to end of queue
        MOV     [LEN_Q],0               ;initialize current queue len
        MOV     DX,1                    ;init skip cnt for skip no bord
        CALL    PAI_SCAN_R              ;scan right from initial pos
        JZ      PAI_RET                 ;we started on border, return
        PUSH    BX                      ;save right scan count
        CALL    PAI_SCAN_L              ;scan left from initial pos
        POP     DX
        ADD     DX,BX                   ;DX = left count + right count
        MOV     AL,64                   ;set up entry for going down
        CALL    PAI_ENTRY               ;enqueue entry
        MOV     AL,192                  ;init for painting up
        JMP     SHORT PAI_START
PAI_RET:
        RET
PAI_ERROR:
        JMP     $ERC_FC                 ;illegal function call
;
;       Main paint loop
;
PAI_LOOP:
        CALL    PAI_DEQ                 ;fetch next entry from queue
        MOV     [$O_CUR],BX
        MOV     [$M_CUR],CL             ;and set as current state
PAI_START:
        MOV     [DIRECT],AL             ;save direction
        OR      AL,AL
        JZ      PAI_RET                 ;zero direction, end of queue
        JNS     PAI_DOWN                ;positive direction, down
        CALL    $TUPC                   ;negative direction, test up
        JMP     SHORT PAI_CHECK
PAI_DOWN:
        CALL    $TDOWNC                 ;test down
PAI_CHECK:                              ;salary
        JC      PAI_LOOP                ;screen edge, get next entry
        CALL    PAI_SCAN_R              ;scan right up to skip cnt bord
        JZ      PAI_LOOP                ;nothing painted, get next ent
        CALL    PAI_SCAN_L              ;now scan left
        MOV     DX,BX                   ;save left scan count
        OR      AL,AL                   ;was line already painted ?
        JZ      PAI_ALREADY             ;yes, no overhang
        CMP     BX,1                    ;is left scan count .GT. 1 ?
        JLE     PAI_ALREADY             ;no, continue
        MOV     AL,[DIRECT]
        NEG     AL                      ;go in opposite direction
        CALL    PAI_ENTRY               ;put current state in queue
PAI_ALREADY:
        ADD     DX,[C_SCAN]             ;DX = right count + left count
        MOV     AL,[F_L_PAI]
        OR      AL,[F_R_PAI]
        JZ      PAI_SAVE                ;don't enqueue if already paint
        MOV     AL,[DIRECT]
        CALL    PAI_ENTRY               ;enqueue entry
;
;       Set current location back to end of right scan
;
PAI_SAVE:                               ;drugstore
        MOV     AX,[$O_SAVE]
        MOV     [$O_CUR],AX
        MOV     AL,[$M_SAVE]
        MOV     [$M_CUR],AL
PAI_OH_L:
        MOV     AX,[C_SKIP]
        SUB     AX,[C_SCAN]             ;any more border to skip ?
        JZ      PAI_LOOP                ;no, end of this scan
        JC      PAI_OH_R                ;yes, but right overhang
        XCHG    AX,DX                   ;yes, scan right dif of counts
        CALL    PAI_SCAN_R
        JZ      PAI_LOOP                ;no more points, proceed
        OR      AL,AL
        JZ      PAI_OH_L                ;ignore if line already painted
        MOV     DX,BX                   ;save right scan count
        MOV     BX,[$O_SAVE]
        MOV     CL,[$M_SAVE]
        MOV     AL,[DIRECT]
        CALL    PAI_ENQ                 ;enqueue entry for right scanpt
        JMP     PAI_OH_L                ;contiue until skipcount .LE. 0
PAI_OH_R:
        NEG     AX                      ;make new skipcount positive
        CMP     AX,1                    ;is (skipcnt-scancnt) .LT. -1 ?
        JLE     PAI_LOOP_REACH          ;no,overhang too small to enter
        DEC     AX
        MOV     CX,AX                   ;set up count
        XCHG    AX,DX                   ;save skipcount
PAI_BACK:                               ;i.o.u.
        CALL    $LEFTC
        LOOP    PAI_BACK                ;move left -(skipcnt-scancnt)-1
        MOV     AL,[DIRECT]             ;no, make entry in opposite dir
        NEG     AL
        CALL    PAI_ENTRY               ;enqueue entry
PAI_LOOP_REACH:
        JMP     PAI_LOOP                ;go to next entry
        PAGE


;**     PAI_DEQ - remove next entry from queue and return in registers
;
; Inputs:
;       none
; Outputs:
;       AL = direction flag  (0 if queue is empty)
;       BX = cursor screen offset
;       CL = screen mask
;       DX = scan count
; Registers:
;       AH,CH,SI

PAI_DEQ:
        XOR     AL,AL                   ;set no entry flag
        SUB     [LEN_Q],SIZE_ENT        ;update current queue size
        JC      PAI_DEQ_RET             ;return flag if queue empty
        MOV     SI,[P_DEQ]              ;fetch ptr to current entry
        LODSW
        XCHG    AX,BX
        LODSW
        XCHG    AX,CX
        LODSW
        XCHG    AX,DX
        MOV     AL,CH                   ;fetch entry and set into regs
        CMP     SI,[P_END_Q]            ;are we at end of queue area ?
        JB      PAI_DEQ_SET             ;no, continue
        MOV     SI,[$$SFPT]             ;yes, wrap around
        INC     SI
        INC     SI
PAI_DEQ_SET:
        MOV     [P_DEQ],SI              ;update ptr to next entry
PAI_DEQ_RET:
        RET


;**     PAI_ENTRY - enqueue current scan state
;
; Inputs:
;       AL = direction flag
;       DX = scan count
;       $$SVRS set since queue overflow is detected
; Outputs:
;       none
; Registers:
;       AX,BX,CX,DI

PAI_ENTRY:
        MOV     BX,[$O_CUR]
        MOV     CL,[$M_CUR]             ;fetch current offset and mask
;       now drop into enqueue


;**     PAI_ENQ - place specified entry into next queue location
;
; Inputs:
;       AL = direction flag
;       BX = cursor screen offset
;       CL = screen mask
;       DX = scan count
; Outputs:
;       none
; Registers:
;       AX,CH,DI

PAI_ENQ:
        MOV     CH,AL
        MOV     AX,[LEN_Q]
        ADD     AX,SIZE_ENT             ;update length
        CMP     AX,[TOTAL_Q]            ;is queue area filled up ?
        JNB     PAI_ENQ_ERROR           ;yes, abort, no more room
        MOV     [LEN_Q],AX
        MOV     DI,[P_ENQ]              ;DI = ptr to next avail entry
        MOV     AX,BX
        STOSW
        MOV     AX,CX
        STOSW
        MOV     AX,DX
        STOSW                           ;enter into queue
        CMP     DI,[P_END_Q]            ;are we at end of queue area
        JB      PAI_ENQ_SET             ;no, continue
        MOV     DI,[$$SFPT]             ;yes, wrap around
        INC     DI
        INC     DI
PAI_ENQ_SET:
        MOV     [P_ENQ],DI              ;update ptr to next queue entry
        RET
PAI_ENQ_ERROR:
        JMP     $ERC_OM                 ;out of memory


;**     PAI_SCAN_L - scan left
;
; Inputs:
;       DX = skip count
; Function:
;       Save state where right scan stopped and reposition to saved
;       state, then scan left.
; Outputs:
;       AL = already painted flag
;       BX = scan count
;       Z set if scan count = 0, reset otherwise
; Registers:
;       ALL

PAI_SCAN_L:
        MOV     AX,[$O_CUR]
        XCHG    AX,[$O_SAVE]
        MOV     [$O_CUR],AX
        MOV     AL,[$M_CUR]
        XCHG    AL,[$M_SAVE]
        MOV     [$M_CUR],AL             ;xchg current state with saved
        CALL    $SCANL                  ;scan left
        MOV     AL,CL
        MOV     [F_L_PAI],AL            ;save already painted flag
        OR      BX,BX                   ;set Z accordingly
        RET


;**     PAI_SCAN_R - scan right
;
; Inputs:
;       none
; Function:
;       Scan right the specified amount and save state when boundary
;       reached.
; Outputs:
;       AL = already painted flag
;       BX = scan count
;       DX = skip count
;       Z set if scan count = 0, reset otherwise
; Registers:
;       ALL

PAI_SCAN_R:
        CALL    $SCANR                  ;scan right specified count
        MOV     [C_SCAN],BX
        MOV     [C_SKIP],DX             ;save updated counts
        MOV     AL,CL
        MOV     [F_R_PAI],AL            ;save already painted flag
        OR      BX,BX                   ;set Z accordingly
        RET


CODE    ENDS
        END
