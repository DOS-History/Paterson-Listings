        TITLE   IOFILM - File Manager for BASCOM-86

;       This module contains the dynamic file management routines for the
;       8086 BASIC Compiler runtime.

        INCLUDE TABMAC.INC


DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $FILPT:WORD             ;File block list head
        EXTRN   $FREPT:WORD             ;File block list head

        INCLUDE DEVDEF.INC

DATA    ENDS

DC      GROUP   DATA



CODE    SEGMENT WORD PUBLIC 'CODE'

        ASSUME  CS:CODE, DS:DC, ES:DC


;       Run-time entries

        PUBLIC  $BLALC,$BLDEA
        PUBLIC  $FBLOC,$FBALC,$FBDEA


;       Run-time externals

        EXTRN   $$RSS:NEAR

        EXTRN   $ERC_IOE:NEAR


Locals  PROC    NEAR

;**     $FBLOC - Locate file block for file number
;
;       ENTRY   (BX) = file number
;       EXIT    (SI) = File Data Block address
;               'Z' set if not present

$FBLOC:
        OR      BH,BH
        JNZ     lfbzro                  ;Error - illegal file number

        MOV     SI,OFFSET DC:$FILPT-BL_LNK  ;(SI) = address of file list pointer

lfb1:   MOV     SI,[SI].BL_LNK          ;Address of next file
        OR      SI,SI
        JZ      lfbret                  ;No more files - not open

        CMP     [SI].FB_NUM,BL          ;Compare file numbers
        JNZ     lfb1                    ;Not equal - try next one

        CMP     [SI].FD_MODE,0          ;Test if open
        JNZ     lfbret                  ;  Yes

        CALL    $FBDEA                  ;Deallocate block

lfbzro: XOR     SI,SI                   ;Set 'Z'

lfbret: RET                             ;  Must be non-zero




;**     $FBALC/$BLALC - Allocate file block
;
;       ENTRY   (BX) = desired block size (not including link area)
;       EXIT    (SI) = file data block address
;               Block is zeroed but not linked

$BLALC:
$FBALC:
        PUSH    AX
        PUSH    CX
        PUSH    DX
        PUSH    DI
        PUSH    BX
        MOV     SI,OFFSET DC:$FREPT-BL_LNK  ;(SI) = address of free block chain

afb1:   MOV     DI,SI                   ;Save previous link pointer
        MOV     SI,[SI].BL_LNK          ;(SI) = address of next free block
        OR      SI,SI
        JZ      afb2                    ;No more free entries - allocate new

        CMP     [SI].BL_LEN,BX          ;Check length
        JB      afb1                    ;  Not large enough

;       We found a large enough one

        MOV     AX,[SI].BL_LNK          ;Unlink (SI) block
        MOV     [DI].BL_LNK,AX
        MOV     CX,[SI].BL_LEN          ;(CX) = length
        JMP     SHORT afb3              ;Go to common code

;       We must allocate a new buffer

afb2:   MOV     CX,BX                   ;Save length
        ADD     BX,-BL_SIZE             ;Adjust for link block
        CALL    $$RSS                   ;Rob some string space
        LEA     SI,[BX-BL_SIZE]         ;Adjust for link block
        MOV     [SI].BL_LEN,CX          ;Set length of block

afb3:   MOV     DI,SI                   ;(DI) = block address
        XOR     AX,AX                   ;(AX) = 0
        SHR     CX,1                    ;Zero (CX) bytes
        REP     STOSW
        JNC     afb4
        STOSB
afb4:   POP     BX
        POP     DI
        POP     DX
        POP     CX
        POP     AX
        RET



;**     $BLDEA - Deallocate block
;
;       Entry   (SI) = block address to release
;       USES    NONE

$BLDEA: PUSH    DI
        JMP     SHORT dfb2



;**     $FBDEA - Deallocate file block
;
;       ENTRY   (SI) = block address to release
;       USES    NONE

$FBDEA:
        PUSH    DI
        PUSH    BX
        MOV     DI,OFFSET DC:$FILPT-BL_LNK  ;(DI) = start of file list

dfb1:   MOV     BX,DI                   ;Save previous block
        MOV     DI,[DI].BL_LNK          ;(DI) = next entry
        OR      DI,DI
        JZ      ercioe                  ;Not there !!!
        CMP     DI,SI
        JNE     dfb1                    ;  Try the next one

;       Found the block - unlink it from file list and add to free list

        MOV     DI,[SI].BL_LNK          ;Unlink (SI) block
        MOV     [BX].BL_LNK,DI
        POP     BX

dfb2:   MOV     DI,[$FREPT]             ;Add to front of free list
        MOV     [$FREPT],SI
        MOV     [SI].BL_LNK,DI          ;Link to previous head
        POP     DI
        RET

ercioe: JMP     $ERC_IOE                ;I/O error (any would do)


Locals  ENDP

CODE    ENDS

        END
