        TITLE   DOSIO - Basic I/O and initialization for 86-DOS and IBM

STKSIZ  EQU     200H

        INCLUDE INTMAC.INC
.list

DISABLE         EQU     CLI
ENABLE          EQU     STI

DATA    SEGMENT WORD PUBLIC'DATA'

        EXTRN   $$SFWA:WORD, $$SLWA:WORD, $PTRFIL:WORD

DIV0_SAVE       DW      2 DUP (?)
OVRF_SAVE       DW      2 DUP (?)
DSKE_SAVE       DW      2 DUP (?)       ;Disk Error Interrupt save

DATA    ENDS


CONST   SEGMENT WORD PUBLIC 'CONST'

        PUBLIC  $TTYWID,$TTYPOS,$EXITSEG

EXIT    DW      0
$EXITSEG        DW      0

$TTYWID DB      80
$TTYPOS DB      0

CONST   ENDS


MEMORY  SEGMENT WORD 'MEMORY'

MEMRY   LABEL   BYTE

MEMORY  ENDS


STACK   SEGMENT WORD STACK 'STACK'
        DW      100H DUP(?)
STACK   ENDS


DC      GROUP   CONST,DATA,MEMORY

STATUS  EQU     11
INCHAR  EQU     8
OUTCH   EQU     2
LISTOUT EQU     5

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $INI,$IOINI,$TTYOT,$LPTOT,$TTYIN,$TTYST,$OSEXT,$ABEND
        PUBLIC  $LTTYPS,$STTYPS

        ASSUME  CS:CODE, DS:DC, ES:DC

        EXTRN   $DIV0_INT:NEAR,$OVRF_INT:NEAR

        EXTRN   $INI0:NEAR
        EXTRN   $$WCLF:NEAR
        EXTRN   $ERC_DME:NEAR, $ERC_DNR:NEAR, $ERC_FWP:NEAR

;***  $INI - Run-time initialization
;

$INI:
        POP     SI
        POP     DI              ;Get return address
        MOV     DX,DC
        MOV     DS,DX           ;Get segment of data and constants
        MOV     [$EXITSEG],ES   ;Save exit segment
        MOV     AX,WORD PTR ES:2  ;Get memory size in paragraphs
        MOV     ES,DX
        SUB     AX,(STKSIZ+15)/16  ;Allow room for stack
        MOV     SS,AX
        MOV     SP,STKSIZ
        PUSH    DI
        PUSH    SI              ;Return address back on stack
        SUB     AX,DX           ;Size of data segment
        CMP     AX,0FFFH        ;More than 64K in data segment?
        JBE     FIGSIZ
        XOR     AX,AX
FIGSIZ:
        MOV     CL,4
        SHL     AX,CL           ;Multiply by 16 to get bytes
        DEC     AX              ;Point to last available byte
        MOV     [$$SLWA],AX
        MOV     [$$SFWA],OFFSET DC:MEMRY

ASSUME  ES:NOTHING

        XOR     AX,AX           ;Clear segment
        PUSH    ES              ;Save ES
        MOV     ES,AX           ;Set ES to 0:xxxx
        PUSHF                   ;Save interrupt status
        DISABLE                 ;Turn off interrupts
        SAVINT  DIV0_SAVE,ES:(0*4)
        SAVINT  OVRF_SAVE,ES:(4*4)
        SAVINT  DSKE_SAVE,ES:(36*4)
        SETINT  ES:(0*4),$DIV0_INT
        SETINT  ES:(4*4),$OVRF_INT
        SETINT  ES:(36*4),$DSKE_INT
        POPF                    ;Restore interrupts
        POP     ES

ASSUME  ES:DC

        JMP     $INI0


;***  $IOINI - 86-DOS special I/O initialization
;

$IOINI:
        RET


;***  $TTYST - TTY status
;
; Inputs:
;       None.
; Function:
;       Check console for pending character.
; Outputs:
;       Zero flag clear if character waiting.
;       Zero flag set if none.
; Registers:
;       Only AX and F affected.

$TTYST:
        MOV     AH,STATUS
        INT     33
        OR      AL,AL
        RET


;***  $TTYIN - TTY input
;
; Inputs:
;       None.
; Function:
;       Get character from console keyboard
; Outputs:
;       AL = character
; Registers:
;       Only AX and F affected.

$TTYIN:
        MOV     AH,INCHAR
        INT     33
        RET


;***  $TTYOT and $LPTOT - Character output routines
;
; Inputs:
;       AL = Character to output
; Function:
;       Send character to console video or to printer
; Outputs:
;       None.
; Register:
;       No registers or flags affected.

$LPTOT:
        PUSH    DX
        XCHG    AX,DX
        MOV     AH,LISTOUT
        JMP     SHORT CHOUT

$TTYOT:
        PUSH    DX
        XCHG    AX,DX
        MOV     AH,OUTCH
CHOUT:
        INT     33
        XCHG    AX,DX
        POP     DX
        RET


;**     $LTTYPS and $STTYPS - Load and store console position

$LTTYPS:
        MOV     AH,[$TTYPOS]
        RET

$STTYPS:
        MOV     [$TTYPOS],AH
        RET



; $DSKE_INT -   Disk Errors vector here via Interrupt 36.
;               [DI] has Error code as follows:
;               00 - Disk Write Protected.
;               02 - Disk Not Ready
;               04 - Data Error
;               06 - Seek Error
;               08 - Sector not found
;               10 - Write Fault (hard disks only)
;               12 - Other error.

$DSKE_INT:
        ENABLE
        MOV     AX,DI           ;Get error code in [AL]
        ADD     SP,20           ;Move stack for POP's
        POP     DS              ;Get Runtime's DS
        POP     ES              ;Get Runtime's ES
        OR      AL,AL
        JNZ     $DSKE_ER2
        JMP     $ERC_FWP        ;Brif "Disk Write Protected"
$DSKE_ER2:
        CMP     AL,2
        JNZ     $DSKE_ER3
        JMP     $ERC_DNR        ;Brif "Disk not Ready"
$DSKE_ER3:
        JMP     $ERC_DME        ; ..else "Disk Media Error"



;***  $OSEXT - Return to 86-DOS

$ABEND:                         ;Serious error
$OSEXT:                         ;'C' set on BASIC trapped error

ASSUME  ES:NOTHING

        XOR     AX,AX           ;Clear segment
        PUSH    ES              ;Save ES
        MOV     ES,AX           ;Set ES to 0:xxxx
        PUSHF                   ;Save interrupt status
        DISABLE                 ;Turn off interrupts
        RSTINT  ES:(0*4),DIV0_SAVE
        RSTINT  ES:(4*4),OVRF_SAVE
        RSTINT  ES:(36*4),DSKE_SAVE
        POPF                    ;Restore interrupts
        POP     ES              ;Restore ES

ASSUME  ES:DC

        JMP     DWORD PTR [EXIT]

CODE    ENDS
        END
