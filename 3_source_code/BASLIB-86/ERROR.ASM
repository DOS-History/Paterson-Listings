        TITLE   ERROR - Error trapping for 8086 Basic Compiler


;       This module contains the run-time support for error trapping
;       in addition to the routines in GOSTOP.


        INCLUDE ADDR.INC


DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $$AOER:WORD, $$OEIP:BYTE
        EXTRN   $ERRADR:WORD,$ERRNUM:WORD,$ERRLIN:WORD
        EXTRN   $MAINBASE:WORD

DATA    ENDS

DC      GROUP   DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        ASSUME  CS:CODE, DS:DC, ES:DC

        PUBLIC  $RESA,$RSN,$RS0
        PUBLIC  $OEGA,$ON0
        PUBLIC  $ERL,$ERN

        EXTRN   $ERR_RE:NEAR
        EXTRN   $$FSFA:NEAR, $FOE:NEAR, $FSERR:NEAR, $GETAD:NEAR
        EXTRN   $SNORM:NEAR


Entries PROC    FAR


;**     $OEGA - ON ERROR GOTO line number
;
;       ENTRY   (BX) = line number address

$OEGA:  MOV     [$$AOER],BX             ;Set error vector
onret:  RET


;**     $ON0 - ON ERROR GOTO 0
;
;       ENTRY   none

$ON0:   MOV     [$$AOER],0              ;Clear error vector
        CMP     [$$OEIP],0              ;Test if error in progress
        JE      onret                   ;  No - just return

;       In error handling routine, must pretend we just had last error

        POP     BX                      ;Toss $ON0 return offset
        PUSH    [$ERRADR]               ;Use error offset as return address
        MOV     BX,[$ERRNUM]            ;Get error number
        JMP     $FOE                    ;Process error


;**     $RESA - RESUME line number
;
;       ENTRY   (BX) = line number address

$RESA:  CMP     [$$OEIP],0              ;Test if error is in progress
        JE      errre                   ;  No - RESUME without error

        MOV     [$$OEIP],0              ;Clear error in progress flag
        POP     AX                      ;Throw away return offset
        PUSH    BX                      ;Save line number as offset
rsnret: RET                             ;Return to specified line number

errre:  JMP     $ERR_RE                 ;Give error


;**     $RS0 - RESUME [0]
;
;       ENTRY   none

$RS0:   CMP     [$$OEIP],0              ;Test if error is in progress
        JE      errre                   ;  No - RESUME without error

        MOV     [$$OEIP],0              ;Clear error in progress flag
        POP     AX                      ;Toss return offset
        MOV     AX,[$ERRADR]            ;Get error address
        CALL    $$FSFA                  ;(BX) = address of start of statement
        PUSH    BX                      ;Save as offset
        RET                             ;Return to start of statement


;**     $RSN - RESUME NEXT
;
;       ENTRY   none

$RSN:   CMP     [$$OEIP],0              ;Test if error is in progress
        JE      errre                   ;  No - RESUME without error

        MOV     [$$OEIP],0              ;Clear errr in progress flag
        MOV     CX,[$ERRADR]            ;Get return offset
        CALL    $GETAD                  ;Get statement number address table
        DB      O_STA
        XCHG    AX,SI
        MOV     DS,[$MAINBASE+2]        ;Get main program CS
        MOV     BX,-1                   ;Start out with maximum address

rsnlop: LODSW                           ;(AX) = next address to check
        OR      AX,AX                   ;Check if end of table
        JZ      rsnend                  ;  Yes

        CMP     AX,CX                   ;Are we less than original address
        JB      rsnnxt                  ;  Yes - skip this one
        CMP     AX,BX                   ;Are we less than current closest
        JAE     rsnnxt                  ;  No - skip this one

        XCHG    AX,BX                   ;Save address in (BX) as new closest

rsnnxt: INC     SI                      ;Skip line number entry
        INC     SI
        JMP     rsnlop                  ;Keep looping

rsnend: PUSH    ES                      ;Restore DS
        POP     DS
        POP     AX                      ;Toss RESUME NEXT return offset
        PUSH    BX                      ;Save address for return
        INC     BX                      ;Bump by 1 to map -1 to 0 (maybe)
        JNZ     rsnret                  ;  Not 0 - return to user program
        JMP     $FSERR                  ;Error - no line number found



;**     $ERN - ERR function
;
;       EXIT    (BX) = error number

$ERN:   MOV     BX,[$ERRNUM]            ;Get error number
        RET


;**     $ERL - ERL function
;
;       EXIT    (FAC) = error line number

$ERL:   PUSH    AX
        PUSH    DX
        PUSH    BX
        MOV     AX,(128+16)*100H        ;(AX) = (exponent,sign)
        XOR     DX,DX
        MOV     BX,[$ERRLIN]            ;(BX,DX) = (line number,0)
        CALL    $SNORM                  ;Normalize it into $AC
        POP     BX
        POP     DX
        POP     AX
        RET


Entries ENDP

CODE    ENDS

        END
