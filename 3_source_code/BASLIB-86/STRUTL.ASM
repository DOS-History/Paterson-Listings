        TITLE   STRUTL - String utilities

CONST   SEGMENT WORD PUBLIC 'CONST'

        PUBLIC  NULDES

NULSTR  DW      DC:NULDES       ;Backpointer to descriptor
NULDES  DW      0,DC:NULSTR+2   ;Descriptor for zero-length string

CONST   ENDS


DATA    SEGMENT WORD PUBLIC 'DATA'

        PUBLIC  $$SFWA,$$SLWA,$$SFPT

TMPHDR  DW      ?
TMPL    LABEL   WORD
T1      DW      ?,?
T2      DW      ?,?
T3      DW      ?,?
T4      DW      ?,?
T5      DW      ?,?
T6      DW      ?,?
T7      DW      ?,?
T8      DW      ?,?
T9      DW      ?,?
T10     DW      ?,?
T11     DW      ?,?
T12     DW      ?,?
T13     DW      ?,?
T14     DW      ?,?
T15     DW      ?,?
TMPH    LABEL   WORD

ALCTRY  DB      ?              ;Allocation calls between garbage collections
$$SFPT  DW      ?              ;Scan for free string space from here
$$SFWA  LABEL   WORD
STRFWA  DW      ?              ;Bottom of string space
$$SLWA  LABEL   WORD
STRLWA  DW      ?              ;Top of string space

DATA    ENDS


DC      GROUP   CONST,DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'
        ASSUME  CS:CODE,DS:DC,ES:DC

        PUBLIC  $$GSTR,$$MAG,$$ATS,$$CFT,$$CSL,$$CTS,$$CTSD,$$DITS
        PUBLIC  $$DTS,$$FSS,$$FTH,$$RSS,$$STSU,$$PUTZ

        EXTRN   $TYPTX:NEAR, $ABEND:NEAR, $$TCR:NEAR
        EXTRN   $ERC_OS:NEAR, $ERC_OM:NEAR, $ERC_ST:NEAR

;***  $$GSTR - Get string space.
;
; Inputs:
;       BX = Length of string space required (may be odd).
; Function:
;       Find and allocate an appropriate chunk of string space. The requested
;       length will be rounded up if odd because allocation is by 16-bit words
;       only. An extra word is added to the front as required by the string
;       format for the backpointer. This backpointer is NOT set up by it must
;       be before any scan of string space is made (by $$GSTR, garbage
;       collectors, etc.)
; Outputs:
;       BX = Address of string. BX-2 is where backpointer goes.
; Registers:
;       Only BX and F affected.

$$GSTR:
        PUSH    AX
        PUSH    SI
        INC     BX              ;Round length up
        AND     BL,NOT 1        ;Then force down to even 16-bit words
        MOV     SI,OFFSET DC:ALCTRY  ;Address of count of allocation attempts
        INC     BYTE PTR [SI]   ;Count one more
        JNZ     LOOKSTR         ;Don't allow rollover to zero
        MOV     BYTE PTR[SI],-1 ;Just limit to 255
LOOKSTR:
        MOV     SI,[$$SFPT]     ;Where we left off looking for space
        XOR     AX,AX           ;Init to free string of zero length
FORWSTR:
        ADD     SI,AX           ;Jump over free string
CHKSTR:
;SI points to next string to check if free
;BX has length of free space needed (always even--whole words only)
        LODSW                   ;Get backpointer/length/tag
        TEST    AL,1            ;See if its a backpointer, meaning allocated
        JZ      NEXSTR          ;Yes--try next string
        CMP     AX,-1           ;See if end-of-space tag
        JZ      NONLEF
        DEC     AX              ;Must be free--zero MSB to get true length
        CMP     AX,BX           ;Is it big enough?
        JB      FORWSTR
;We have a string big enough
        ADD     SI,BX           ;Point to where next string will start
        MOV     [$$SFPT],SI     ;Here's where we'll start next time
        SUB     AX,BX           ;How much is left in this free chunk?
        JZ      EXACT           ;Don't touch next string if perfect fit
        DEC     AX              ;Set the free bit and account for header
        MOV     [SI],AX         ;Make a new header for the chunk that remains
EXACT:
        SUB     SI,BX           ;Point back to beginning of string area
        MOV     BX,SI           ;Leave this result in BX
        POP     SI
        POP     AX
        RET

NEXSTR:
;Skip over string in use. AX has backpointer
        XCHG    AX,BX           ;Save BX while putting backpointer there
        ADD     SI,[BX]         ;Add length of string to string space pointer
        INC     SI              ;Round up if length was odd
        AND     SI,NOT 1        ;Then force to word boundary
        XCHG    AX,BX           ;Restore BX
        JMP     CHKSTR

NEEDMAJ:
;Unable to find the needed space even after recent minor garbage collection
        CALL    $$MAG           ;Perform major garbage collection
        MOV     SI,[$$SFPT]     ;Point to beginning of free space
        CMP     BX,[SI]         ;See if we have enough now
        JBE     CHKSTR          ;Yes--try allocation again
        JMP     $ERC_OS         ;Clean stack and report out of string space

EXITMIG:
        POP     BX
        JMP     LOOKSTR

NONLEF:
;Couldn't find a free chunk in one pass so let's try garbage collection
        MOV     AL,0
        XCHG    AL,[ALCTRY]     ;Read and zero count of allocation attempts
        CMP     AL,6            ;Did we make at least 6 allocations?
        JB      NEEDMAJ         ;If not, time for major garbage collection

;Perform minor garbage collection. Simply runs through string space, merging
;adjacent free areas. Does no data movement.

        PUSH    BX              ;Save length of request while we fiddle around
        MOV     SI,[STRFWA]     ;First location in string space
        MOV     [$$SFPT],SI     ;We'll start over next attempt
SETUSED:
        MOV     BL,-1           ;Flag--previous string was not free
FRESTR:
        LODSW                   ;Get backpointer/length/tag
        CMP     AX,-1           ;See if end of string space
        JZ      EXITMIG         ;Terminate garbage collection if so
        TEST    AL,1            ;See if a backpointer
        JZ      USEDSTR         ;Yes--this space is allocated
;We have a free string. Attempt to combine with previous free string
        CMP     BL,-1           ;Was previous string free?
        JNZ     CATENATE        ;If so, put them together
        MOV     BX,SI           ;Save pointer to this free string
        ADD     SI,AX           ;Point to next string
        DEC     SI              ;Reset LSB
        JMP     FRESTR

CATENATE:
        ADD     SI,AX           ;Point to next string
        DEC     SI              ;Account for LSB set as a flag
        INC     AX              ;Include header in size
        ADD     [BX-2],AX       ;Adjust header of previous string
        JMP     FRESTR

USEDSTR:
;Skip over a string in use
        XCHG    AX,BX           ;Get backpointer in BX for addressing
        ADD     SI,[BX]         ;Add length of string to pointer
        INC     SI              ;Round up if odd
        AND     SI,NOT 1        ;And force to word boundary
        JMP     SETUSED


;***  $$MAG - Major garbage collection
;
; Inputs:
;       None.
; Function:
;       Compact all free space into one big (?) chunk. All strings in use are
;       copied down to the bottom of free space with the backpointers used to
;       find and correct their descriptors.
; Outputs:
;       None.
; Registers:
;       Only F affected.

$$MAG:
        PUSH    AX
        PUSH    BX
        PUSH    SI
        PUSH    DI
        MOV     AX,1            ;Initialization trick
        MOV     SI,[STRFWA]     ;Pointer to string scan
        MOV     DI,SI           ;Destination of string copies
MAGFRE:
        DEC     AX              ;Reset free flag in LSB
MAGNXT:
        ADD     SI,AX           ;Jump over free block
MAGSTR:
;SI points to next string in uncompacted string space
;DI points to free point in compacted string space
; (SI and DI are equal until a free string is encountered)
        LODSW                   ;Get backpointer/length/tag
        CMP     AX,-1           ;End-of-space tag?
        JZ      EXITMAG
        TEST    AL,1            ;Is it a free chunk?
        JNZ     MAGFRE          ;If so, skip over it
        STOSW                   ;Copy backpointer to compacted space
        XCHG    BX,AX           ;Put backpointer in base register
        MOV     AX,[BX]         ;Get length
        CMP     SI,[BX+2]       ;See if pointers match
        JNZ     MAGERR          ;If not, abort everything
;We have a string in use. Move it to compacted space.
        INC     AX              ;Increase byte length for whole words
        CMP     SI,DI           ;Copying to ourself? (no free string yet)
        JZ      INPLACE
        MOV     [BX+2],DI       ;Point descriptor to compacted space
        XCHG    AX,CX           ;Get count in CX while saving it
        SHR     CX,1            ;Move words
        REP     MOVSW           ;Compact the string
        XCHG    AX,CX           ;Restore CX
        JMP     MAGSTR

INPLACE:
;SI=DI so movement not necessary.
        AND     AL,NOT 1        ;Force to word boundary
        ADD     DI,AX           ;Skip over it in compacted space
        JMP     MAGNXT

EXITMAG:
;SI points to first word beyond end of string space
;DI points to first free word.
        SUB     SI,DI           ;Compute length of free space
        SUB     SI,4            ;Account for 2 headers
        JB      SAVSTRT         ;If we're full, no room for free space header
        INC     SI              ;Set free space bit
        MOV     [DI],SI         ;Header for new free space chunk
SAVSTRT:
        MOV     [$$SFPT],DI     ;Tell $$GSTR where free space starts
        POP     DI
        POP     SI
        POP     BX
        POP     AX
        RET

MAGERR:
        CALL    SSCERR          ;String Space Corrupt error
        CALL    $TYPTX
        DB      ' during G.C','.'+80H
        CALL    $$TCR
        JMP     $ABEND          ;Give it up

SSCERR: CALL    $$TCR
        CALL    $TYPTX
        DB      'Internal Error - String Space Corrup','t'+80H
        RET


;***  $$ATS - Allocate temporary string
;
; Inputs:
;       BX = Length of string
; Function:
;       Allocate the requested amount of free space and attach it to a temp
;       descriptor. Backpointer in string space set but data is not moved in.
; Outputs:
;       DX = Address of string data area.
;       BX = Address of temp string descriptor
; Registers:
;       Only BX, DX, F affected.

$$ATS:
        OR      BX,BX
        JZ      ATSNUL          ;Nul strings have special descriptor
        CMP     WORD PTR[TMPHDR],0  ;See if we have any temps left
        JZ      TEMPOV
        PUSH    SI
        PUSH    BX
        CALL    $$GSTR          ;Allocate the space
        MOV     SI,[TMPHDR]     ;Get the next temp
        MOV     DX,[SI]         ;Make the one after that
        MOV     [TMPHDR],DX     ;   the new "next temp"
        POP     [SI]            ;Set length in descriptor
        MOV     [BX-2],SI       ;Set backpointer
        MOV     [SI+2],BX       ;Set pointer in descriptor
        MOV     DX,BX           ;Put data pointer in DX
        MOV     BX,SI           ;Need temp descriptor in BX
        POP     SI
        RET

ATSNUL:
;Return pointer to nul string
        MOV     DX,OFFSET DC:NULSTR
        MOV     BX,OFFSET DC:NULDES
        RET

TEMPOV:
        JMP     $ERC_ST         ;Clean stack and report string temporary ovfl.

;***  $$CFT - Check for temporary string descriptor
;
; Inputs:
;       BX = Address of string descriptor
; Function:
;       Check to see if the string descriptor is a temporary.
; Outputs:
;       Carry flag set if a temp
;       Carry clear in not
; Registers:
;       Only F affected.

$$CFT:
        CMP     BX,OFFSET DC:TMPH
        JNC     RET             ;If above high end, not a temp
        CMP     BX,OFFSET DC:TMPL
        CMC
        RET


;***  $$CSL - Compute string length
;
; Inputs:
;       BX = address of a string terminated by 00
; Function:
;       Count the number of characters in the string.
; Outputs:
;       AX = Length of the line (not including 00)
; Registers:
;       Only AX and F affected.

$$CSL:
        PUSH    CX
        PUSH    DI
        MOV     CX,-1           ;Scan up to 65535 characters
        MOV     AL,0            ;Search for a zero
        MOV     DI,BX
        REPNE   SCASB           ;Scan for a 00
        MOV     AX,CX           ;Amount of the 65535 left
        NOT     AX
        DEC     AX
        POP     DI
        POP     CX
        RET


;***  $$CTS - Create temporary string
;
; Inputs:
;       BX = Length of string
;       DX = Address of string data
; Function:
;       Allocate a temporary string and move the string data into it.
; Outputs:
;       BX = Address of temp string descriptor
; Registers:
;       Only BX and F affected.

$$CTS:
        PUSH    CX
        MOV     CX,BX           ;Get length in CX
        PUSH    SI
        MOV     SI,DX           ;Point to source of string data
        CALL    $$ATS           ;Get a temporary string of the right length
        PUSH    DI
        MOV     DI,DX           ;String data destination
        MOV     DX,SI           ;Restore DX
        INC     CX              ;Round up if odd
        SHR     CX,1            ;Move by words
        REP     MOVSW
        POP     DI
        POP     SI
        POP     CX
        RET


;***  $$DTS - Delete all temporary strings
;
; Inputs:
;       None.
; Function:
;       Free all temporary strings and descriptors.
; Outputs:
;       None.
; Registers:
;       Only F affected.

$$DTS:
        PUSH    BX
        MOV     BX,OFFSET DC:T1 ;First string descriptor
DTSLOOP:
        CMP     WORD PTR[BX+2],-1  ;If pointer is -1, then its already free
        JZ      NEXTMP          ;Skip if free
        CALL    DELTMP          ;Delete if not
NEXTMP:
        ADD     BX,4            ;Next temp descriptor
        CMP     BX,OFFSET DC:TMPH       ;Done yet?
        JB      DTSLOOP
        POP     BX
RET:    RET


;***  $$DITS - Delete if temporary string
;
; Inputs:
;       BX = Address of string descriptor
; Function:
;       Check to see if the descriptor is a temporary. If so, delete it.
; Outputs:
;       None.
; Registers:
;       Only F affected.

$$DITS:
        CALL    $$CFT           ;See if temp string
        JNC     RET             ;If not, leave it
DELTMP:
        CALL    $$FSS           ;Free the space

;***  $$FTH - Free temp header
;
; Inputs:
;       BX = address of temporary string descriptor
; Function:
;       Attach the header to the list of free temp descriptors
; Outputs:
;       None.
; Registers:
;       Only F affected.

$$FTH:
        PUSH    AX
        MOV     AX,BX
        XCHG    AX,[TMPHDR]     ;Make this one the first free
        MOV     [BX],AX         ;Set link to former first one
        MOV     WORD PTR[BX+2],-1  ;Make it easy to see its free
        POP     AX
        RET


;***  $$RSS - Rob string space
;
; Inputs:
;       BX = length needed.
; Function:
;       Permanently allocate a chunk of free space. First a major garbage
;       collection is performed, then the back end of the free space is
;       taken away, never to be returned.
; Outputs:
;       BX = Address of allocated space
; Registers:
;       Only BX and F affected.

$$RSS:
        CALL    $$MAG           ;Compact string space
        PUSH    AX
        PUSH    DX
        INC     BX              ;Round up if odd
        AND     BL,NOT 1        ;And force to word boundary
        MOV     AX,[$$SFPT]     ;Get pointer to free space
        XCHG    AX,BX
        MOV     DX,[BX]         ;Get size of the free space chunk
        SUB     DX,AX           ;Allocate our space
        JB      INSUF           ;Have enough?
        MOV     [BX],DX         ;Reduce size of free chunk
        ADD     BX,DX           ;Point to end of free chunk
        INC     BX              ;Point to first byte after free chunk
        MOV     WORD PTR[BX],-1 ;Flag as end of string space
        INC     BX
        MOV     [STRLWA],BX     ;Save pointer to end
        INC     BX              ;Point to start of allocated space
        POP     DX
        POP     AX
        RET

INSUF:
;Not enough free space to satisfy request
        JMP     $ERC_OM         ;Clean stack and report out of memory


;***  $$CTSD - Create temp from string descriptor
;
; Inputs:
;       BX = Address of string descriptor
;       CX = Starting OFFSET DC:within string
;       DX =Length
; Function:
;       Create a temporary string and copy the specified portion of the given
;       string into it. The given string is deleted if it is a temp.
; Outputs:
;       BX = Address of temp string descriptor
; Registers:
;       Only BX and F affected.

$$CTSD:
        PUSH    DX
        PUSH    BX
        MOV     BX,[BX+2]       ;Get pointer to data
        ADD     BX,CX           ;Adjust with offset
        XCHG    BX,DX           ;Set up call
        CALL    $$CTS           ;Allocate space and move string in
        MOV     DX,BX           ;Save result momentarily
        POP     BX              ;Address of source string descriptor
        CALL    $$DITS          ;Delete if temp
        MOV     BX,DX           ;Get result back in BX
        POP     DX
        RET


;***  $$FSS - Free string space
;
; Inputs:
;       BX = Address of string descriptor
; Function:
;       Free the space pointed to by the string descriptor
; Outputs:
;       None.
; Registers:
;       Only F affected.

$$FSS:
        PUSH    AX
        PUSH    BX
        MOV     AX,[BX]         ;Get length of sting to free
        MOV     BX,[BX+2]       ;Get pointer to string data
;See if string is in the managed string area
        CMP     BX,[STRFWA]
        JB      NOFREE
        CMP     BX,[STRLWA]
        JA      NOFREE
;Free the space
        INC     AX              ;Round up if odd
        OR      AL,1            ;And set free bit
        XCHG    AX,[BX-2]       ;Get backpointer and set free length
        POP     BX
        CMP     AX,BX           ;Check backpointer
        JNZ     FSSERR          ;Scream if they don't match
        POP     AX
        RET

NOFREE:
;Not part of managed string space, so forget it. Ho hum.
        POP     BX
        POP     AX
        RET

FSSERR:
        CALL    SSCERR          ;String space corrupt error
        CALL    $$TCR
        JMP     $ABEND


;***  $$PUTZ - Put zero at end of string
;
; Inputs:
;       BX = Address of string descriptor
; Function:
;       Make into a string with a zero byte on the end. If length is presently
;       odd, just jam a zero into the extra byte. If even, create a temp
;       one byte longer and put the zero there.
; Outputs:
;       BX = Address of string descriptor
; Registers:
;       Only BX and F affected.

$$PUTZ:
        PUSH    DX
        MOV     DX,[BX]
        TEST    DL,1            ;Is string length odd?
        JNZ     PATCHEND        ;If so, no copying needed
        PUSH    CX
        XOR     CX,CX
        INC     DX
        CALL    $$CTSD
        DEC     DX
        POP     CX
PATCHEND:
        PUSH    BX
        MOV     BX,[BX+2]       ;Get pointer to data
        ADD     BX,DX
        MOV     BYTE PTR[BX],0
        POP     BX
        POP     DX
        RET


;***  $$STSU - Set up string space
;
; Inputs:
;       None.
; Function:
;       Initialize all conditions needed for strings
; Outputs:
;       None.
; Registers:
;       All destroyed.

$$STSU:
        MOV     DI,[$$SFWA]     ;Must be even
        MOV     [$$SFPT],DI
        MOV     AX,[$$SLWA]     ;Last available byte
        INC     AX
        AND     AL,NOT 1        ;Force to word boundary
        SUB     AX,DI           ;Length of free space, bytes
        SUB     AX,3            ;Set LSB to flag free
        STOSW                   ;Store header
        ADD     DI,AX
        MOV     WORD PTR[DI-1],-1  ;Put flag at end of free space
        MOV     CX,15           ;Number of string temporaries
        MOV     DI,OFFSET DC:T1 ;First temp
        MOV     [TMPHDR],DI
        MOV     BX,-1           ;Flag for each temp indicates free
        MOV     AX,OFFSET DC:T2
LINKTMP:
        STOSW                   ;Link to next temp
        XCHG    AX,BX
        STOSW                   ;Store free flag
        XCHG    AX,BX
        ADD     AX,4            ;4 bytes per temp
        LOOP    LINKTMP
        MOV     WORD PTR[DI-4],0 ;Last temp must point to nul
        MOV     [ALCTRY],0      ;No allocation attempts yet
        RET

CODE    ENDS
        END
