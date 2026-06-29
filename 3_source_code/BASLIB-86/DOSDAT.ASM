        TITLE   DOSDAT - MS-DOS DATE$ and TIME$ Support

        .SALL

        INCLUDE MSDOS.INC


DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $$SPSV:WORD

DATA    ENDS

DC      GROUP   DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $DAT, $DAF                      ;DATE$
        PUBLIC  $TIM, $TIF                      ;TIME$

        EXTRN   $$ATS:NEAR, $$DITS:NEAR
        EXTRN   $ERC_FC:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC

GETDAT= 42              ;Get Date Function
SETDAT= 43              ;Set Date Function
GETTIM= 44              ;Get Time Function
SETTIM= 45              ;Set Time Function


        SUBTTL  $DAT - Set Date.

;$DAT - Set Date.

DOSDAT  PROC    FAR

$DAT:
        MOV     [$$SPSV],SP
        PUSH    AX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    BX
        MOV     SI,[BX+2]       ;[SI] has addr of string.
        MOV     BX,[BX]         ;[BX] has string length
        OR      BX,BX           ;String must not be null
        JZ      DATE_ERROR      ;Brif null str
        CALL    GETNUM          ;Get 1 or 2 digit number
        MOV     DH,AH           ;[DH] = month
        CALL    DATSEP
        CALL    GETNUM
        MOV     DL,AH           ;[DL] = day
        CALL    DATSEP
        CALL    GETNUM
        MOV     CX,1900         ;Bias in case only 2-digit year
        OR      BX,BX           ;End-of-string?
        JZ      DATE2           ;Brif so.
        MOV     AL,100
        MUL     AH              ;Mult decade by 100
        MOV     CX,AX           ;Save bias for year add
        CALL    GETNUM          ;Get year (digits 3 & 4).
DATE2:
        MOV     AL,AH
        MOV     AH,0
        ADD     CX,AX           ;Add 2 digits of base to century
        DOSIO   SETDAT          ;Give date to DOS.
$TIM_RET:
        OR      AL,AL           ;Date (or Time) OK?
        JNZ     DATE_ERROR      ;Brif not.
        POP     BX
        CALL    $$DITS          ;Delete the Temp
        PUSH    BX
$DAF_RET:
        POP     BX
        POP     SI
        POP     DX
        POP     CX
        POP     AX
        RET                     ;Exit.
DOSDAT  ENDP


        SUBTTL  $DAF - Get Date.

;$DAF - Get Date.

$DAF:
        PUSH    AX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        MOV     BX,10
        CALL    $$ATS           ;Get space for 10 char string
        PUSH    BX              ;Save String Descriptor
        PUSH    DX              ;Save addr of string
        DOSIO   GETDAT          ;Get Date from DOS
        POP     BX              ;Restore addr of String
        MOV     AL,DH
        CALL    PUTCHR          ;Store ascii month
        MOV     AL,"-"
        CALL    PUTCH2
        MOV     AL,DL
        CALL    PUTCHR          ;Store ascii day
        MOV     AL,"-"
        CALL    PUTCH2
        SUB     CX,1900         ;Reduce  year by two digits
        CMP     CL,100          ;See if in 20th century
        MOV     CH,19           ;Setup 20th century in case
        JB      DATEF2          ;Brif so.
        SBB     CL,100          ;subtract into next century
        INC     CH              ;21st century
DATEF2:
        MOV     AL,CH
        CALL    PUTCHR          ;Store ascii century
        MOV     AL,CL
        CALL    PUTCHR          ;Store ascii year.

        JMP     $DAF_RET        ;Return Date String (Desc on stack).

DATE_ERROR:
        JMP     $ERC_FC         ;Complain


        SUBTTL  $TIM - Set Time.

;$TIM - Set Time.

$TIM:
        MOV     [$$SPSV],SP
        PUSH    AX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    BX
        MOV     SI,[BX+2]       ;[SI] has addr of string.
        MOV     BX,[BX]         ;[BX] has string length
        OR      BX,BX           ;String must not be null
        JZ      TIME_ERROR      ;Brif null str
        CALL    GETNUM          ;Get 1 or 2 digit number
        MOV     CH,AH           ;[CH] = hours
        CALL    TIMSEP
        CALL    GETNUM
        MOV     CL,AH           ;[CL] = minutes
        CALL    TIMSEP
        CALL    GETNUM
        MOV     DH,AH           ;[DH] = seconds 
        CALL    TIMSEP
        CALL    GETNUM
        MOV     DL,AH           ;[DL] = 100ths. 
        DOSIO   SETTIM          ;Give Time to DOS.
        JMP     $TIM_RET        ;Check Time OK & Exit.


        SUBTTL  $TIF - Get Time.

;$TIF - Get Time.

$TIF:
        PUSH    AX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        MOV     BX,11
        CALL    $$ATS           ;Get space for 11 char string
        PUSH    BX              ;Save String Descriptor
        PUSH    DX              ;Save addr of string
        DOSIO   GETTIM          ;Get Time from DOS
        CMP     DL,50
        JB      TIMEF2          ;Brif .lt. 1/2 sec
        INC     DH              ;Bump secs.
        CMP     DH,60
        JB      TIMEF2          ;Brif no ovf
        MOV     DH,0
        INC     CL              ;Bump mins.
        CMP     CL,60
        JB      TIMEF2          ;Brif no ovf
        MOV     CL,0
        INC     CH              ;Bump hrs.
TIMEF2:
        POP     BX              ;Restore addr of String
        MOV     AL,CH
        CALL    PUTCHR          ;Store ascii hours
        MOV     AL,":"
        CALL    PUTCH2
        MOV     AL,CL
        CALL    PUTCHR          ;Store ascii minutes
        MOV     AL,":"
        CALL    PUTCH2
        MOV     AL,DH
        CALL    PUTCHR          ;Store ascii seconds.
        MOV     AL,"."
        CALL    PUTCH2
        MOV     AL,DL
        CALL    PUTCHR          ;Store ascii 100ths.

        JMP     $DAF_RET        ;Return Time String (Desc on stack).

TIME_ERROR:
        JMP     DATE_ERROR      ;Complain


        SUBTTL  $DATE and $TIME Utility Subroutines

DATSEP:
        OR      BX,BX
        JZ      TIME_ERROR      ;Error if string empty.
        DEC     BX              ;Length -1
        LODSB
        CMP     AL,"/"
        JZ      GETNUX
        CMP     AL,"-"
        JZ      GETNUX
        JMP     TIME_ERROR


TIMSEP:
        OR      BX,BX
        JZ      GETNUX
        DEC     BX
        LODSB
        CMP     AL,":"
        JZ      GETNUX
        CMP     AL,"."
        JZ      GETNUX
        JMP     TIME_ERROR

GETNUM:
        CALL    DIGIT
        JB      TIME_ERROR
        MOV     AH,AL
        CALL    DIGIT
        JB      GETNUX
        AAD                     ;Convert BCD to Binary
        MOV     AH,AL
GETNUX:
        RET
DIGIT:
        MOV     AL,BL           ;Init to 0 if string exhausted
        OR      BX,BX           ;End-of-string?
        JZ      GETNUX          ;Brif so, returns 0
        MOV     AL,[SI]
        SBB     AL,"0"
        JB      GETNUX
        CMP     AL,10
        CMC
        JB      GETNUX
        DEC     BX              ;Length -1
        INC     SI
        RET


PUTCHR:
        AAM                     ;Convert to unpacked BCD
        XCHG    AL,AH
        OR      AX,"00"         ;Add "0" bias to both digits.
        CALL    PUTCH2
        MOV     AL,AH
PUTCH2:
        MOV     [BX],AL         ;store char in string
        INC     BX
        RET


CODE    ENDS
        END
