        TITLE   STRNUM - String to number and number to string conversions
; Code for CVI, CVS, CVD, MKI$, MKS$, and MKD$

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $AC:WORD, $DAC:WORD, $$SPSV:WORD

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $CVI,$CVS,$CVD,$MKI,$MKS,$MKD

        EXTRN   $$DITS:NEAR, $$ATS:NEAR, $$CTS:NEAR, $ERR_FC:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC

STRNUM  PROC    FAR             ;Set up long returns as default


;***  $CVI - Convert string to integer
;
; Inputs:
;       BX = Address of string descriptor
; Function:
;       Make sure string is at least 2 bytes long, then put the first 2 bytes
;       in BX as an integer.
; Outputs:
;       BX = number
; Registers:
;       Only BX and F affected

$CVI:
        CMP     BYTE PTR[BX],2  ;Make sure string is at least 2 long
        JB      ARGERR
        PUSH    DI
        MOV     DI,[BX+2]       ;Address of string data
        MOV     DI,[DI]         ;First 2 bytes of string
        CALL    $$DITS          ;Delete string if temp
        MOV     BX,DI           ;Put result in proper register
        POP     DI
        RET


;***  $CVS and $CVD - Convert string to single or double precision number
;
; Inputs:
;       BX = Address of string descriptor
; Function:
;       Convert the string to single or double precision number. Make sure
;       it's long enough first.
; Outputs:
;       Result number in FAC.
; Registers:
;       Only F affected.

$CVS:
        CMP     BYTE PTR[BX],4  ;See if string is long enough
        JB      ARGERR
        PUSH    SI
        PUSH    DI
        MOV     SI,[BX+2]       ;Get address of data area
        MOV     DI,OFFSET DC:$AC
MOVSNG:
        MOVSW
        MOVSW
        POP     DI
        POP     SI
        CALL    $$DITS          ;Delete string if temp
        RET

$CVD:
        CMP     BYTE PTR[BX],8  ;See if string is long enough
        JB      ARGERR
        PUSH    SI
        PUSH    DI
        MOV     SI,[BX+2]       ;Get address of string data
        MOV     DI,OFFSET DC:$DAC
        MOVSW
        MOVSW
        JMP     MOVSNG

ARGERR: JMP     $ERR_FC         ;Illegal function call


;***  $MKI, $MKS, and $MKD - Convert number to string
;
; Inputs:
;       BX = Integer to be converted (MKI)
;       BX = Address of real number to be converted (MKS, MKD)
; Function:
;       Create a 2-, 4-, or 8-byte temp string and put the number in it.
; Outputs:
;       BX = Address of string descriptor
; Registers:
;       Only BX and F affected.

$MKI:   ;Convert integer to string
        MOV     [$$SPSV],SP
        PUSH    DX
        PUSH    BX
        MOV     BX,2            ;Create a string of length 2
        CALL    $$ATS           ;Allocate the string
        XCHG    BX,DX           ;Get address of string data in BX
        POP     [BX]            ;Store integer into string
        MOV     BX,DX           ;Restore descriptor to BX
        POP     DX
        RET

$MKS:   ;Convert single precision to string
        MOV     [$$SPSV],SP
        PUSH    DX
        MOV     DX,4            ;4 Bytes in single precision number
NUMSTR:
        XCHG    BX,DX           ;Re-order parameters for CTS
        CALL    $$CTS           ;Allocate string and copy data in
        POP     DX
        RET

$MKD:   ;Convert double precision to string
        MOV     [$$SPSV],SP
        PUSH    DX
        MOV     DX,8            ;8 bytes in double precision number
        JMP     NUMSTR

STRNUM  ENDP
CODE    ENDS
        END
