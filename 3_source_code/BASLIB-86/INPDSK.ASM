        TITLE   INPDSK - Handle input from disk

CR=     13
LF=     10

        .LIST

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FILBUF:WORD,$PTRFIL:WORD,$$SPSV:WORD,$INBUF:BYTE

DATA    ENDS


DC      GROUP   DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $IN0B

        EXTRN   $FBLOC:NEAR,$GETCHR:NEAR,$BAKCHR:NEAR
        EXTRN   $ERC_BFM:NEAR,$ERC_IFN:NEAR,$ERC_RPE:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC


;***  $IN0B - Prepare for disk input
;
; Inputs:
;       BX = File number
; Function:
;       Set up parameters so input will come from disk
; Outputs:
;       None.
; Registers:
;       All but BP destroyed.

$IN0B   PROC    FAR
        MOV     [$$SPSV],SP
        CALL    $FBLOC
        JZ      ARGERR
        CMP     [SI].FD_MODE,MD_SQO
        JE      BADMODE
        MOV     [$PTRFIL],SI
        MOV     [$FILBUF],OFFSET FILBUF
        RET
$IN0B   ENDP

ARGERR: JMP     $ERC_IFN        ;Illegal file number
BADMODE:JMP     $ERC_BFM        ;Bad file mode
EOFERR: JMP     $ERC_RPE

FILBUF:
        CALL    $GETCHR
        JC      EOFERR
        OR      DL,DL           ;Line input?
        JZ      NOSPC
        CMP     AL," "
        JZ      FILBUF
NOSPC:
        MOV     DI,OFFSET DC:$INBUF
        CMP     AL,'"'          ;Quoted string?
        JNZ     NOTQUOTE
        CMP     DL,","          ;Looking for a string?
        JNZ     NOTQUOTE
        MOV     DX,'""'         ;Set delimiters to '"'
        CALL    $GETCHR
        JC      QUIT            ;Null string?
NOTQUOTE:
        MOV     CL,255          ;Allow 255 characters
LOPCRS:
        CMP     DH,'"'          ;Getting a quoted string?
        JZ      SKPCHK
        CMP     AL,CR           ;End of line?
        JZ      ENDCR
        CMP     AL,LF
        JNZ     SKPCHK
;Have a linefeed and this is not a quoted string
        CMP     DL,","          ;Getting an unquoted string?
        JZ      NOSTO           ;Don't store linefeeds in unquoted strings
        CALL    STRCHR
NOSTO:
        CALL    $GETCHR
        CMP     AL,CR           ;Ignore CR after LF
        JNZ     SKPCHK
        CMP     DL," "          ;Looking for number?
        JZ      NEXCHR
        CMP     DL,","          ;Looking for unquoted string?
SKPCHK:
        OR      AL,AL
        JZ      NEXCHR          ;Ignore nulls
        CMP     AL,DH           ;Check for first terminator
        JZ      QUIT
        CMP     AL,DL           ;Check for second terminator
        JZ      QUIT
        CALL    STRCHR          ;Store the character
NEXCHR:
        CALL    $GETCHR
        JNC     LOPCRS
QUIT:
        CMP     AL,'"'          ;Finishing a quoted string?
        JZ      MORSPC
        CMP     AL," "
        JNZ     PUTZER
MORSPC:
        CALL    $GETCHR
        JC      PUTZER
        CMP     AL," "
        JZ      MORSPC
        CMP     AL,","          ;Eat comma separator
        JZ      PUTZER
        CMP     AL,CR
        JNZ     BACKUP
ENDCR:
        CALL    $GETCHR
        JC      PUTZER
        CMP     AL,LF
        JZ      PUTZER
BACKUP:
        CALL    $BAKCHR
PUTZER:
        XOR     AL,AL
        STOSB
        MOV     SI,OFFSET DC:$INBUF
RET:    RET

STRCHR:
        OR      AL,AL
        JZ      RET
        STOSB
        DEC     CL              ;Buffer full?
        JNZ     RET
        POP     CX              ;Dump a return address
        JMP     PUTZER          ;Quit if buffer full

CODE    ENDS
        END
