        TITLE   CHAIN - CHAIN and RUN statements

;Loader for EXE files under 86-DOS

PRINT   EQU     9
OPEN    EQU     15
SETDMA  EQU     26
RDBLK   EQU     39
PARSE   EQU     41
RR      EQU     33
RECLEN  EQU     14

DATA    SEGMENT WORD PUBLIC 'DATA'
        EXTRN   $EXITSEG:WORD
DATA    ENDS

RUN     SEGMENT 'DATA'          ;Must be on paragraph boundary

RUNVAR  LABEL   BYTE            ;Start of RUN variables
RELPT   DW      ?
RELSEG  DW      ?
SIZ     LABEL   WORD            ;Share these locations
PAGES   DW      ?
RELCNT  DW      ?
HEADSIZ DW      ?
        DW      ?
LOADLOW DW      ?
INITSS  DW      ?
INITSP  DW      ?
        DW      ?
INITIP  DW      ?
INITCS  DW      ?
RELTAB  DW      ?
RUNVARSIZ       EQU     $-RUNVAR
EXEFCBW LABEL   WORD
EXEFCB  DB      37 DUP(?)
DATPARSIZ=     ($+13-RUNVAR)/16

RUN     ENDS


DC      GROUP   RUN,DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $RUN,$CHN

        EXTRN   $ERR_OM:NEAR, $ERR_FNF:NEAR, $ERR_BFN:NEAR, $$PUTZ:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC

CHAIN   PROC    FAR

BADNAM: JMP     $ERR_BFN
NOFILE: JMP     $ERR_FNF
        IF1
CODPARSIZ=      0       ;Sick kludge to save bytes (and generate good code)
        ELSE
CODPARSIZ=      (ENDCODE+15-LOAD)/16
        ENDIF

$CHN:
$RUN:
        CALL    $$PUTZ          ;Make string terminated by zero
        MOV     SI,[BX+2]       ;Get address of string data
        MOV     DI,OFFSET DC:EXEFCB     ;Place to put resulting FCB
        MOV     AL,1            ;Skip leading separators
        MOV     AH,PARSE
        INT     33              ;Parse file name
        OR      AL,AL           ;File name OK?
        JNZ     BADNAM
        CMP     [EXEFCB+1]," "  ;File name present?
        JZ      BADNAM
        CMP     [EXEFCB+9]," "  ;Extension present?
        JNZ     OPENIT
        MOV     [EXEFCBW+9],"XE"
        MOV     [EXEFCB+11],"E" ;If no extension, add default "EXE"
OPENIT:
        MOV     AH,OPEN
        MOV     DX,OFFSET DC:EXEFCB
        INT     33              ;Open file
        OR      AL,AL           ;File present?
        JNZ     NOFILE
        XOR     AX,AX
        MOV     [EXEFCBW+RR],AX ;Set Random Record field to zero
        MOV     [EXEFCBW+RR+2],AX
        INC     AX
        MOV     [EXEFCBW+RECLEN],AX
EXELOAD:
        MOV     DX,OFFSET DC:RUNVAR     ;Read header in here
        MOV     AH,SETDMA
        INT     33
        MOV     CX,RUNVARSIZ    ;Amount of header info we need
        MOV     DX,OFFSET DC:EXEFCB
        MOV     AH,RDBLK
        INT     33              ;Read in header
        MOV     AX,[HEADSIZ]    ;Size of header in paragraphs
;Convert header size to 512-byte pages by dividing by 32 & rounding up
        ADD     AX,31           ;Round up first
        MOV     CL,5
        SHR     AX,CL           ;Divide by 32
        MOV     [EXEFCBW+RR],AX ;Position in file of program
        MOV     [EXEFCBW+RECLEN],512 ;Set record size
        MOV     BX,[$EXITSEG]
        ADD     BX,10H          ;First paragraph above parameter area
        MOV     DX,[PAGES]      ;Total size of file in 512-byte pages
        SUB     DX,AX           ;Size of program in pages
        MOV     [SIZ],DX
        SHL     DX,CL           ;Convert pages back to paragraphs
        ADD     DX,BX           ;Size + start = minimum memory (paragr.)
        MOV     CX,SS           ;Use all memory below stack segment
        SUB     CX,DATPARSIZ+CODPARSIZ
        CMP     DX,CX           ;Enough memory?
        JA      OUTOFMEM
        MOV     BP,BX           ;Save load segment

;Move loader code and data to high end of memory

        MOV     ES,CX
        PUSH    DS
        PUSH    CS
        POP     DS
        MOV     SI,OFFSET LOAD
        XOR     DI,DI
        MOV     CX,CODPARSIZ*8  ;Size of code in words
        REP     MOVSW
        POP     DS
        MOV     SI,OFFSET DC:RUNVAR
        MOV     CX,DATPARSIZ*8
        REP     MOVSW
        XOR     AX,AX
        PUSH    ES
        PUSH    AX              ;Fake a return address
        MOV     AX,ES
        ADD     AX,CODPARSIZ
        MOV     DS,AX
        RET                     ;Transfer control to loader at end of memory

OUTOFMEM:JMP    $ERR_OM

        ASSUME  DS:RUN

LOAD:
        PUSH    DS
        MOV     DS,BX
        XOR     DX,DX           ;Address 0 in segment
        MOV     AH,SETDMA
        INT     33              ;Set load address
        POP     DS
        MOV     CX,[SIZ]        ;Maximum record count (512 bytes ea)
        MOV     DX,OFFSET EXEFCB
        MOV     AH,RDBLK
        INT     33              ;Read in up to 64K
        SUB     [SIZ],CX        ;Decrement count by amount read
        JZ      HAVEXE          ;Did we get it all?
        TEST    AL,1            ;Check return code if not
        JNZ     BADEXE          ;Must be zero if more to come
        ADD     BX,1000H-20H    ;Bump data segment 64K
        JMP     LOAD            ;Get next 64K block

HAVEXE:
        MOV     AX,[RELTAB]     ;Get position of table
        MOV     [EXEFCBW+RR],AX ;Set in random record field
        MOV     [EXEFCBW+RECLEN],1  ;Set one-byte record
        MOV     DX,OFFSET RELPT ;4-byte buffer for relocation address
        MOV     AH,SETDMA
        INT     33
        CMP     [RELCNT],0      ;Any fixups to do?
        JZ      NOREL
RELOC:
        MOV     AH,RDBLK
        MOV     DX,OFFSET EXEFCB
        MOV     CX,4
        INT     33              ;Read in one relocation pointer
        OR      AL,AL           ;Check return code
        JNZ     BADEXE
        MOV     DI,[RELPT]      ;Get offset of relocation pointer
        MOV     AX,[RELSEG]     ;Get segment
        ADD     AX,BP           ;Bias segment with actual load segment
        MOV     ES,AX
        ADD     ES:[DI],BP      ;Relocate
        DEC     [RELCNT]        ;Count off
        JNZ     RELOC
NOREL:
        MOV     AX,[INITSS]
        ADD     AX,BP
        MOV     SS,AX           ;Initialize SS
        MOV     SP,[INITSP]
        MOV     AX,[INITCS]
        ADD     AX,BP
        PUSH    AX
        PUSH    [INITIP]
        SUB     BP,10H          ;Point back to parameter area
        MOV     ES,BP
        MOV     DS,BP           ;Set segment registers to point to it
        MOV     DX,80H
        MOV     AH,SETDMA
        INT     33              ;Set default disk transfer address
        RET

BADEXE:
        PUSH    CS
        POP     DS
        MOV     DX,OFFSET EXEBAD
        MOV     AH,PRINT
        INT     33
        SUB     BP,10H
        PUSH    BP
        XOR     AX,AX
        PUSH    AX
        RET

EXEBAD  DB      13,10,"Error in EXE file",13,10,"$"

ENDCODE:

CHAIN   ENDP
CODE    ENDS
        END
