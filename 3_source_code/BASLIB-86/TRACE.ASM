        TITLE   TRACE - 8086 Basic Compiler Debug and Trace Routines

;       Debug trace routines for use with the /D switch in the compiler.

.list


DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $TRACE_SW:BYTE          ;Trace switch

if      _IBM_
        EXTRN   $CTRL_BRK:BYTE
endif

SAVELOC         DW      ?               ;Save location

EL_SIZE         DB      ?               ;Array element size
NUM_DIM         DB      ?               ;2 * number of dimensions

SUBERR          DB      ?               ;Subscript error flag

DATA     ENDS

DC       GROUP  DATA


CODE     SEGMENT BYTE PUBLIC 'CODE'

         ASSUME  CS:CODE, DS:DC, ES:DC

         PUBLIC  $AELA,$LINA,$TRN,$TRF

         EXTRN   $STP:NEAR,$$WCHT:NEAR
         EXTRN   $ERR_BS:NEAR
         EXTRN   $$FSFA:NEAR,$TYPUI:NEAR

if       _IBM_ eq 0
         EXTRN   $TTYIN:NEAR, $TTYST:NEAR
endif

Entries  PROC    FAR


;**      $AELA - Array subscript bounds check
;
;        This routine computes a byte index into an array.  The subscripts
;        are checked against the array bounds.
;
;        The subscripts are on the stack as follows:
;
;                ((SP)+4) = 1st subscript
;                ...
;                ((SP)+2*n+2) = nth subscript
;
;        The calling sequence is as follows:
;
;                CALL    $AELA
;                DB      element size            (2, 4, or 8)
;                DB      2 * #dimensions
;                DW      1st limit
;                ...
;                DW      nth limit
;
;        ENTRY   ((SP)) = return offset
;                ((SP)+2) = return segment
;                ((SP)+4) = 1st subscript
;                ((SP)+2*n+2) = nth subscript
;        EXIT    (AX) = byte index to element from array base
;        USES    AX,CX,SI

$AELA:   MOV     [SAVELOC],DX            ;Save (DX)

ASSUME   ES:NOTHING

         POP     SI                      ;(SI) = return offset (start of list)
         POP     ES                      ;(ES) = user code segment

         LODS    WORD PTR ES:[SI]        ;(AH,AL) = (2*dimensions,element size)
         MOV     WORD PTR [EL_SIZE],AX   ;Save it for later

         XOR     CX,CX                   ;(CX) = Accum for byte index
         MOV     [SUBERR],CL             ;Clear subscript error flag

;        For each subscript:
;
;        1.      Compare Subscript against Limit
;                If out of range, then bad subscript error
;        2.      Accum = Accum * Limit + Subscript

AEL1:    LODS    WORD PTR ES:[SI]        ;(AX) = Limit
         POP     DX                      ;(DX) = Subscript
         CMP     AX,DX                   ;Limit : Subscript
         JA      ael2                    ;  In range - Subscript must be less

         MOV     [SUBERR],1              ;Set subscript error flag
         JMP     SHORT ael3              ;Skip arithmetic for this subscript

ael2:    PUSH    DX                      ;Save Subscript during multiply
         MUL     CX                      ;(AX) = Limit * Old Accum
         POP     CX                      ;(CX) = Subscript
         ADD     CX,AX                   ;(CX) = Subscript + Limit * Old Accum

ael3:    SUB     [NUM_DIM],2             ;Count off 1 dimension
         JNZ     AEL1                    ;  Keep on looping

         XCHG    AX,CX                   ;(AX) = Accum
         MUL     WORD PTR [EL_SIZE]      ;(AX) = byte index (NUM_DIM = 0 !!!)

         PUSH    ES                      ;Save return segment
         PUSH    SI                      ;  and new offset past array bounds

         PUSH    DS                      ;Restore ES
         POP     ES

ASSUME   ES:DC

         MOV     DX,[SAVELOC]            ;Restore (DX)
         CMP     [SUBERR],0              ;Test for bad subscript
         JNZ     errbs

         RET                             ;Return with (AX)

errbs:   JMP     $ERR_BS                 ;Bad subscript

         PAGE

;**      $LINA - Print trace message

$LINA:
if       _IBM_
         CMP     $CTRL_BRK,0             ;Check for control-BREAK
         JE      lina1                   ;No
         JMP     $STP                    ;Yes - exit
lina1:
else
         PUSH    AX
         CALL    $TTYST                  ;Check for pending character
         JZ      lina1                   ;No
         CALL    $TTYIN                  ;Read character
         CMP     AL,3                    ;Is it control-C ?
         POP     AX
         JNZ     lina2                   ;No
         JMP     $STP                    ;Yes - exit
lina1:   POP     AX
LINA2:
endif
         CMP     $TRACE_SW,0             ;Check if trace is active
         JE      linret                  ;No

         POP     [SAVELOC]               ;Save offset
         PUSH    AX                      ;Save (AX)
         MOV     AL,'['
         CALL    $$WCHT                  ;Output [
         MOV     AX,[SAVELOC]            ;(AX) = return offset
         CALL    $$FSFA                  ;Find statement number from address
         CALL    $TYPUI                  ;Type line number in (AX)
         MOV     AL,']'
         CALL    $$WCHT                  ;Output ]
         POP     AX
         PUSH    [SAVELOC]               ;Restore return offset

linret:  RET


;**      $TRN/$TRF - Set and clear trace flag

$TRN:    MOV     $TRACE_SW,1
         RET

$TRF:    MOV     $TRACE_SW,0
         RET


Entries  ENDP

CODE     ENDS

         END
