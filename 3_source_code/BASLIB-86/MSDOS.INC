; MSDOS.INC - MS-DOS I/O Macro defns.

; VECTOR INTERRUPT EQUATES

I_DOSIO=        21H             ;MSDOS_IO


; MS-DOS INTERRUPT CALL MACRO DEFNS

DOSMAC  MACRO   NAM
NAM     MACRO   FUNC
IFNB    <FUNC>
        MOV     AH,FUNC
ENDIF
        INT     I_&NAM
        ENDM
        ENDM


        DOSMAC  DOSIO           ;;MSDOS_IO


ENABLE  EQU     STI             ;Enable  Interrupts
DISABLE EQU     CLI             ;Disable Interrupts
