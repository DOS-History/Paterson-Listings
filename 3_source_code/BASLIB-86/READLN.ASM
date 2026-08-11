        TITLE   READLN - Read a line into $INBUF from TTY

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $INBUF:BYTE,$BUFLEN:BYTE,$LINLEN:BYTE

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $RDLIN

        EXTRN   $TYPSTR:NEAR,$$WCH:NEAR,$INPOVF:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


$RDLIN  PROC    NEAR
        MOV     [$BUFLEN],255   ;Allow 255 character lines
        MOV     AH,10
        MOV     DX,OFFSET DC:$BUFLEN
        INT     33              ;Get input buffer
        MOV     BL,[$LINLEN]    ;Get length of line
        MOV     BH,0
        MOV     $INBUF[BX],BH   ;Put zero at end of line
        RET
$RDLIN  ENDP

CODE    ENDS
        END
