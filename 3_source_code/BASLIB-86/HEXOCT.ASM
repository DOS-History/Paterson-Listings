        TITLE   HEXOCT - OCT, HEX functions

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $$SPSV:WORD

DBUF    DB      6 DUP(?)

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $HEX,$OCT,$HXF,$OCF

        EXTRN   $$CTS:NEAR,$ADC:FAR

        ASSUME  CS:CODE, DS:DC, ES:DC

OCTHEX  PROC    FAR             ;Set up for long returns


;***  $HEX,$HXF,$OCT,$OCF - Convert number to hexadecimal or octal string
;
; Inputs:
;       BX - Integer value to be converted ($OCT/$HEX)
;       BX - Address of SP number ($OCF/$HXF)
; Function:
;       Create a string of minimum length (no leading zeros) that represents
;       the value of the number in octal or hex.
; Outputs:
;       BX = Address of string descriptor
; Registers:
;       Only BX and F affected.

$OCF:
        MOV     [$$SPSV],SP
        PUSH    SI
        MOV     SI,BX           ;$ADC needs address in SI
        CALL    $ADC            ;Convert SP to address
        POP     SI
$OCT:
        MOV     [$$SPSV],SP
        PUSH    CX
        MOV     CX,0703H        ;Shift count in CL, mask in CH
        JMP     SHORT HEXOCT

$HXF:
        MOV     [$$SPSV],SP
        PUSH    SI
        MOV     SI,BX           ;$ADC needs address in SI
        CALL    $ADC            ;Convert SP to address
        POP     SI
$HEX:
        MOV     [$$SPSV],SP
        PUSH    CX
        MOV     CX,0F04H        ;Set mask (CH) and shift count (CL)
HEXOCT:
        PUSH    AX
        PUSH    DI
        MOV     AH,0            ;Initialize digit count
        MOV     DI,OFFSET DC:DBUF+5  ;Start from back end of digit buffer
        STD                     ;   and work down

; At this point, the following conditions exist:
;       AH = character count
;       CX = Shift count and mask
;       BX = Number to convert
;       DI = Pointer into digit buffer

CONV:
        MOV     AL,BL           ;Bring it to accumulator
        AND     AL,CH           ;Mask down to the bits that count
;Trick 6-byte hex conversion
        ADD     AL,90H
        DAA
        ADC     AL,40H
        DAA                     ;Number in hex now
        STOSB                   ;Save in string
        INC     AH              ;Count the digits
        SHR     BX,CL           ;Bring down next digit
        JNZ     CONV
        CLD                     ;Restore direction UP
        INC     DI              ;Point to most significant digit
        MOV     BL,AH           ;Digit count in BX (BH already zero)
        XCHG    DI,DX           ;Save DX and put pointer there
        CALL    $$CTS           ;Allocate string and copy data in
        MOV     DX,DI           ;Restore DX
        POP     DI
        POP     AX
        POP     CX
        RET

OCTHEX  ENDP
CODE    ENDS
        END
