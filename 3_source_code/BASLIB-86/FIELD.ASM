        TITLE   FIELD  - FIELD Statement Processors

.list


DATA    SEGMENT PUBLIC WORD 'DATA'

        EXTRN   $$SPSV:WORD

FIELD_LEFT      DW      ?               ;Bytes left in field buffer
FIELD_POS       DW      ?               ;Current field position

DATA    ENDS

DC      GROUP   DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        ASSUME  CS:CODE, DS:DC, ES:DC


;       Run-time entries

        PUBLIC  $FLDA,$FLDB

;       Externals

        EXTRN   $FBLOC:NEAR, $$FSS:NEAR

        EXTRN   $ERC_IFN:NEAR
        EXTRN   $ERC_BFM:NEAR
        EXTRN   $ERC_FOV:NEAR
        EXTRN   $ERC_FC:NEAR


Entries PROC    FAR

;**     $FLDA - Field statement preamble
;
;       ENTRY   (BX) = file number

$FLDA:  MOV     [$$SPSV],SP             ;Record stack pointer
        PUSH    AX
        PUSH    SI
        CALL    $FBLOC                  ;Find FDB
        JZ      ercifn                  ;  Not found
        CMP     [SI].FD_MODE,MD_RND
        JNE     ercbfm

        MOV     AX,[SI].FR_VRECL
        MOV     [FIELD_LEFT],AX         ;Save field length
        ADD     SI,FR_FIELD             ;(SI) = field buffer address
        MOV     [FIELD_POS],SI          ;Save address
        POP     SI
        POP     AX
        RET



;**     $FLDB - Field assignment
;
;       ENTRY   (BX) = String descriptor
;               (DX) = field length

$FLDB:  MOV     [$$SPSV],SP
        OR      DX,DX
        JS      ercfc                   ;Can't have negative field length
        PUSH    AX
        SUB     [FIELD_LEFT],DX         ;Count off current field
        JB      ercfov                  ;  Too big
        CALL    $$FSS                   ;Free string space
        MOV     AX,[FIELD_POS]          ;Get current field position
        MOV     [BX],DX                 ;Set new string length
        MOV     [BX+2],AX               ;Set new string address
        ADD     [FIELD_POS],DX          ;Bump to next field position
        POP     AX
        RET


ercifn: JMP     $ERC_IFN
ercbfm: JMP     $ERC_BFM
ercfc:  JMP     $ERC_FC
ercfov: JMP     $ERC_FOV

Entries ENDP

CODE    ENDS

        END
