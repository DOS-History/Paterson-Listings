        TITLE   STRFCN - String function package


        INCLUDE SYSTEM.INC


; Includes code for LEN, ASC, CHR, FRE, INKEY, INSTR,
; LEFT, RIGHT, MID, SPACE, STRING

DATA    SEGMENT WORD PUBLIC 'DATA'

        EXTRN   $$SPSV:WORD, $$SFPT:WORD, NULDES:WORD

DATA    ENDS

DC      GROUP   DATA

CODE    SEGMENT BYTE PUBLIC 'CODE'
        ASSUME  CS:CODE, DS:DC, ES:DC

        PUBLIC  $LENA,$LENB,$CHR,$FREA,$FR$A,$IST,$IS2,$LEF,$RIG,$MID,$MIDSTR
        PUBLIC  $SP$,$ST$,$S2$,$INK

        EXTRN   $$DITS:NEAR, $$ATS:NEAR, $$MAG:NEAR, $SNORM:NEAR
        EXTRN   $$CTSD:NEAR, $TTYST:NEAR, $TTYIN:NEAR
        EXTRN   $ERR_FC:NEAR, $ERC_FC:NEAR

STRFCN  PROC    FAR             ;Set up long returns as the default


;***  $LENA and $LENB - Compute LEN and ASC functions
;
; Inputs:
;       BX = Address of string descriptor
; Outputs:
;       BX = Value of LEN or ASC function
; Registers:
;       Only BX and F affected.

$LENA:
        PUSH    [BX]            ;Put length on stack
        CALL    $$DITS          ;Delete if temp string
        POP     BX
        RET

$LENB:
        CMP     WORD PTR[BX],0  ;See if nul string
        JZ      TLRG            ;If so, error
        PUSH    SI
        MOV     SI,[BX+2]       ;Get pointer to string data
        MOV     SI,[SI]         ;Get first char of string
        CALL    $$DITS          ;Delete if temp string
        MOV     BX,SI
        MOV     BH,0            ;Char in BL
        POP     SI
        RET


;***  $INK - INKEY$ function
;
; Inputs:
;       None.
; Function:
;       If a character is waiting at the console, return it in a 1-char temp
;       string. Otherwise, return null string descriptor.
; Outputs:
;       BX = Address of string descriptor
; Registers:
;       Only BX and F affected.

$INK:
        PUSH    AX
        CALL    $TTYST          ;See if anything out there
        JZ      RETNUL
        CALL    $TTYIN          ;Get the char
if      _IBM_
        JNZ     inknrm          ;Normal - return 1 character

        XCHG    AX,BX           ;BX = (scan code,0)
        POP     AX              ;Restore AX
        MOV     [$$SPSV],SP     ;Save stack
        PUSH    DX
        PUSH    BX              ;Save 2 characters
        MOV     BX,2            ;Want a 2 character string
        JMP     SHORT chrsub    ;Go to common code

inknrm:
endif
        MOV     BL,AL
        MOV     BH,0            ;All set up for CHR$ function
        POP     AX

;***  $CHR - CHR$ function
;
; Inputs:
;       BX = Value, which will be checked to be sure it's valid ASCII (<256)
; Function:
;       Create a temp string 1 char. long with the given value.
; Outputs:
;       BX = Address of string descriptor
; Registers:
;       Only BX and F affected.

$CHR:
        MOV     [$$SPSV],SP     ;Record stack in case of error in $$ATS
        OR      BH,BH           ;See if value OK (<256)
        JNZ     TLRG            ;If not, argument error
        PUSH    DX
        PUSH    BX
        MOV     BX,1

chrsub: CALL    $$ATS           ;Allocate a one-byte string
        XCHG    BX,DX           ;Get pointer to data in BX
        POP     [BX]            ;Put character in string
        MOV     BX,DX           ;Get descriptor address in BX
        POP     DX
        RET

RETNUL:
        POP     AX
        MOV     BX,OFFSET DC:NULDES
        RET


;***  $FREA and $FR$A - FREE function wtih numeric or string parameters
;
; Inputs:
;       None.
; Function:
;       $FREA returns the size of the next free block. $FR$A performs a
;       major garbage collection and returns the total free string space.
; Outputs:
;       $FAC has size of free space, single precision.
; Registers:
;       Only F and $FAC affected.

$FR$A:
        CALL    $$MAG           ;Perform major garbage collection
$FREA:
        PUSH    BX
        PUSH    DX
        PUSH    AX
        MOV     BX,[$$SFPT]     ;Get pointer to free space header
        MOV     DX,[BX]         ;Get header word
        CMP     DX,-1           ;Check for end of string space
        JZ      NOFREE
        TEST    DL,1            ;Check if free
        JNZ     TELFRE
NOFREE:
        MOV     DX,1            ;Free chunk of zero length
TELFRE:
        DEC     DX              ;Reset LSB
        XOR     BX,BX
        MOV     AX,0A000H       ;Positive sign, true exponent = 32
        CALL    $SNORM
        POP     AX
        POP     DX
        POP     BX
        RET


TLRG:   JMP     $ERR_FC         ;Report illegal function call


;***  $IST - INSTR function for three arguments
;
; Inputs:
;       BX = Starting position in A$ of search (I)
;       DX = Address of descriptor of string to be searched (A$)
;       CX = Address of search string descriptor (B$)
; Function:
;       Perform INSTR(I,A$,B$).
; Outputs:
;       BX = Position of B$ in A$; zero if not found.
; Registers:
;       Only BX and F affected.

$IST:
        OR      BX,BX
        JLE     TLRG            ;Arg error if I<=0
        PUSH    AX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI
        MOV     DI,DX           ;Get A$ descriptor where we can address with it
        MOV     SI,CX           ;Get B$ descriptor where we can address with it
        LODSW                   ;Length of B$
        DEC     AX
        MOV     DX,AX           ;Length of B$-1 in DX
        MOV     SI,[SI]         ;Address of B$ data
        MOV     CX,[DI]         ;Length of A$
        MOV     DI,[DI+2]       ;Address of A$ data
        DEC     BX              ;Starting offset in A$
        ADD     DI,BX           ;Add in starting offset
        ADD     AX,BX           ;Starting offset + length of search string - 1
        MOV     BX,CX           ;Remember how long A$ is
        SUB     CX,AX           ;Reduce search length
        JBE     NOTFND          ;If search string won't fit, say not found
        LODSB                   ;Get first character of search string

; Top of search loop. The following conditions exist here:
;       AL = First character of search string (B$).
;       BX = True length of string being searched (A$).
;       CX = Amount of A$ left for first-character scan.
;       DX = Length of B$-1, used for string compares.
;       SI = Address of B$+1, used for string compares.
;       DI = Current position to scan in A$.

SEARCH:
        JCXZ    NOTFND          ;If nothing left in A$, not found
        REPNE   SCASB           ;Scan for first letter
        JNZ     NOTFND          ;Was first letter found?

;Found a match in first letter. Do string compare on remaining letters

        PUSH    CX              ;Save condition should compare be unsuccessful
        PUSH    SI              ;  and we need to continue first-character
        PUSH    DI              ;  search.
        MOV     CX,DX           ;Get length of B$-1 for string compare
        REPE    CMPSB
        POP     DI
        POP     SI
        POP     CX
        JNZ     SEARCH          ;If it didn't match, just continue searching
        SUB     BX,CX           ;Compute position of match from start of string
EXITFND:
        POP     DI
        POP     SI
        POP     CX              ;Pop these two in reverse order--they get
        POP     DX              ;  interchanged below
        POP     AX
        XCHG    BX,DX
        CALL    $$DITS          ;Get rid of temporary strings
        XCHG    BX,CX
        CALL    $$DITS
        XCHG    BX,DX           ;Get result back in BX
        RET

NOTFND:
        XOR     BX,BX
        JMP     EXITFND


;***  $IS2 - INSTR function with 2 arguments
;
; Inputs:
;       BX = Address of A$ descriptor
;       DX = Address of B$ descriptor
; Function:
;       Perform INSTR(A$,B$).
; Outputs:
;       BX = Position of B$ within A$.
; Registers:
;       Only BX and F affected.

$IS2:
        PUSH    CX
        MOV     CX,DX           ;Shuffle registers for $IST
        MOV     DX,BX
        MOV     BX,1            ;Start with position 1
        CALL    FAR PTR $IST
        MOV     DX,CX
        POP     CX
        RET


;***  $LEF and $RIG - Compute LEFT$ and RIGHT$ functions
;
; Inputs:
;       BX = Address of string descriptor
;       DX = Length of string wanted
; Function:
;       Return a string made up of the leftmost ($LEF) or rightmost ($RIG)
;       characters of the source string. If the requested length is less than
;       zero, then give error; if greater than the length of the source string,
;       the source string itself is returned; otherwise, a temporary string
;       is created.
; Outputs:
;       BX = Address of result string descriptor
; Registers:
;       Only BX and F affected.

$LEF:
        MOV     [$$SPSV],SP
        PUSH    CX
        XOR     CX,CX           ;Start at left end
        CALL    LEFRIG
        POP     CX
        RET

$RIG:
        MOV     [$$SPSV],SP
        PUSH    CX
        MOV     CX,[BX]         ;Get length
        SUB     CX,DX           ;Starting point (from left)
        CALL    LEFRIG
        POP     CX
        RET



;***  $MID - Compute MID$ function
;
; Inputs:
;       BX = Address of string descriptor
;       DX = Starting offset in string (1 is first)
;       CX = Length of string desired
; Function:
;       If (DX < 1) or (CX < 0) then give error; if (DX = 1) and (CX >= length
;       of source string) then return source string; otherwise create a temp
;       string of length CX with the specified portion of the source string.
; Outputs:
;       BX = Address of result string descriptor
; Registers:
;       Only BX and F affected.

$MID:
        MOV     [$$SPSV],SP
$MIDSTR:                        ;Callable from run-time
        DEC     DX              ;Offset should start at zero, not 1
        XCHG    DX,CX           ;Set up for future call
        JL      ARGERR          ;Error if now negative
        JZ      MLEF            ;Offset of zero is same as LEFT$
        PUSH    DX
        PUSH    AX
        MOV     AX,[BX]         ;Get length of string
        SUB     AX,CX           ;Reduce length by the offset
        JBE     NULMID          ;Return null string if nothing left
        CMP     AX,DX           ;Need smaller of request and amount remaining
        JAE     MIDLEN
        MOV     DX,AX           ;Limited by length of string
MIDLEN:
        CALL    $$CTSD          ;Create temp string from descriptor
MIDPOP:
        POP     AX
        POP     DX
MIDLV:
        XCHG    CX,DX           ;Restore original position
        INC     DX              ;  and original value
        RET

MLEF:
;Offset into string is zero, so treat just like LEFT$
        CALL    LEFRIG
        JMP     MIDLV

NULMID:
;Return null string for $MID
        MOV     BX,OFFSET DC:NULDES  ;Null string descriptor
        JMP     MIDPOP


;***  $SP$, $ST$, and $S2$ - SPACE$ and STRING$ functions
;
; Inputs:
;       BX = Length of string desired
;       DL = Character to repeat ($ST$ only)
;       DX = Descriptor of string with character to repeat ($S2$) only)
; Function:
;       Produce temporary string with a single character repeated BX times.
;       $SP$ gives a string of blanks, $ST$ provides the character to be
;       repeated, and $S2$ provides a string descriptor, the first character
;       of which is to be repeated.
; Outputs:
;       BX = Address of result temp string descriptor
; Registers:
;       Only BX and F affected.

$SP$:
        MOV     [$$SPSV],SP
        PUSH    DX
        MOV     DL," "          ;Provide a space to be repeated

STRING:
;       DL = character to repeat
;       BX = Repeat count
; Creates a temporary string with DL repeated BX times. DX popped from stack.

        OR      BX,BX           ;Check character count
        JZ      NUL             ;Return null string if zero
        JL      ARGERR          ;Error if negative
        PUSH    CX
        PUSH    AX
        MOV     CX,BX           ;Put count in count register
        MOV     AL,DL           ;Character to copy
        MOV     AH,DL           ;Repeat it by words for speed
        CALL    $$ATS           ;Allocate string
        XCHG    DI,DX           ;Get address of data in destination register
        INC     CX              ;Round up to whole word if odd
        SHR     CX,1            ;Divide byte count by 2 for word move
        REP     STOSW
        MOV     DI,DX           ;Restore DI
        POP     AX
        POP     CX
        POP     DX
        RET

$ST$:
        MOV     [$$SPSV],SP
        PUSH    DX
        JMP     STRING

$S2$:
        MOV     [$$SPSV],SP
        XCHG    BX,DX           ;Put descriptor where we can address with it
        CMP     WORD PTR[BX],0  ;Length of string must not be zero
        JZ      ARGERR
        PUSH    BX
        PUSH    AX
        PUSH    BX
        MOV     BX,[BX+2]       ;Get address of string data
        MOV     AL,[BX]         ;Get first character
        POP     BX              ;Get descriptor back
        CALL    $$DITS          ;Delete if temp string
        XCHG    AX,BX           ;Put char to repeat in BL
        POP     AX
        XCHG    BX,DX           ;Organize parameters
        JMP     STRING

NUL:
        MOV     BX,OFFSET DC:NULDES
        RET

ARGERR: JMP     $ERC_FC         ;Clean stack and report illegal function call

STRFCN  ENDP


LEFRIG:

; This subroutine is used for $LEF, $RIG, and some $MID.
; Inputs:BX = Address of string descriptor
;       DX = Length requested
;       CX = Starting offset
; First it does some checks on DX, then calls $$CTSD if necessary.

        OR      DX,DX           ;Test requested length
        JL      ARGERR          ;If negative, give error
        JZ      STRNUL          ;If zero, return null string
        CMP     DX,[BX]         ;See if requested length is longer than string
        JAE     NRET            ;If so, just return string
        JMP     $$CTSD          ;Create temp from string descriptor

STRNUL:
        MOV     BX,OFFSET DC:NULDES  ;Point to null descriptor
NRET:   RET

CODE    ENDS
        END
