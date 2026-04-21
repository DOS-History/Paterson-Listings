; 86-DOS  High-performance operating system for the 8086  version 1.00 04/28/81
;	by Tim Paterson

; ****************** Revision History *************************
;          >> EVERY change must noted below!! <<
;
; 0.34 12/29/80 General release, updating all past customers
; 0.42 02/25/81 32-byte directory entries added
; 0.56 03/23/81 Variable record and sector sizes
; 0.60 03/27/81 Ctrl-C exit changes, including register save on user stack
; 0.74 04/15/81 Recognize I/O devices with file names
; 0.75 04/17/81 Improve and correct buffer handling
; 0.76 04/23/81 Correct directory size when not 2^N entries
; 0.80 04/27/81 Add console input without echo, Functions 7 & 8
; 1.00 04/28/81 Renumber for general release
;
; *************************************************************

; Use the switch below to generate code to accept the old 16-byte
; directory entry as well as the new 32-byte entry.

SMALLDIR:	EQU	1	;1 to enable, 0 to disable


; Turn on switch below to allow testing disk code with DEBUG. It sets
; up a different stack for disk I/O (functions > 11) than that used for
; character I/O which effectively makes the DOS re-entrant.

DSKTEST:	EQU	0	;1 to enable, 0 to disable


; Interrupt Entry Points:

; INTBASE:	ABORT
; INTBASE+4:	COMMAND
; INTBASE+8:	BASE EXIT ADDRESS
; INTBASE+C:	CONTROL-C ABORT
; INTBASE+10H:	FATAL ERROR ABORT
; INTBASE+14H:	BIOS DISK READ
; INTBASE+18H:	BIOS DISK WRITE
; INTBASE+40H:	Long jump to CALL entry point


MAXCALL:EQU	36
MAXCOM:	EQU	41
ESCCH:	EQU	1BH
INTBASE:EQU	80H
INTTAB:	EQU	20H
ENTRYPOINTSEG:	EQU	0CH
ENTRYPOINT:	EQU	INTBASE+40H
CONTC:	EQU	INTTAB+3
EXIT:	EQU	INTBASE+8
LONGJUMP:EQU	0EAH
LONGCALL:EQU	9AH
MAXDIF:	EQU	0FFFH
SAVEXIT:EQU	10

; Field definition for FCBs

	ORG	0
	DS	12		;Drive code and name
EXTENT:	DS	2
RECSIZ:	DS	2		;Size of record (user settable)
FILSIZ:	DS	4		;Size of file in bytes
FDATE:	DS	2		;Date of last writing
FILDIRBLK:DS	2		;Location in directory
FIRCLUS:DS	2		;First cluster of file
LSTCLUS:DS	2		;Last cluster accessed
CLUSPOS:DS	2		;Position of last cluster accessed
DIRTYFIL:DS	1		;File has been written to if <>0
	ORG	32
NR:	DS	1		;Next record
RR:	DS	3		;Random record


; Description of 32-byte directory entry (same as returned by SEARCH FIRST
; and SEARCH NEXT, functions 17 and 18).
;
; Location	bytes	Description
;
;    0		11	File name and extension ( 0E5H if empty)
;   11		13	Zero field (for expansion)
;   24		 2	Date. Bits 0-4=day, bits 5-8=month, bits 9-15=year-1980
;   26		 2	First allocation unit ( < 4080 )
;   28		 4	File size, in bytes (LSB first, 30 bits max.)
;
; The File Allocation Table uses a 12-bit entry for each allocation unit on
; the disk. These entries are packed, two for every three bytes. The contents
; of entry number N is found by 1) multiplying N by 1.5; 2) adding the result
; to the base address of the Allocation Table; 3) fetching the 16-bit word at
; this address; 4) If N was odd (so that N*1.5 was not an integer), shift the
; word right four bits; 5) mask to 12 bits (AND with 0FFF hex). Entry number
; zero is used as an end-of-file trap in the OS and as a flag for directory
; entry size (if SMALLDIR selected). Entry 1 is reserved for future use. The
; first available allocation unit is assigned entry number two, and even
; though it is the first, is called cluster 2. Entries greater than 0FF8H are
; end of file marks; entries of zero are unallocated. Otherwise, the contents
; of a FAT entry is the number of the next cluster in the file.


; Field definition for Drive Parameter Block

	ORG	0
DRVNUM:	DS	1		;Drive number
SECSIZ:	DS	2		;Size of physical sector in bytes
CLUSMSK:DS	1		;Sectors/cluster - 1
CLUSSHFT:DS	1		;Log2 of sectors/cluster
FIRFAT:	DS	2		;Starting record of FATs
FATCNT:	DS	1		;Number of FATs for this drive
MAXENT:	DS	2		;Number of directory entries
DIRSEC:				;Number of dir. sectors (init temporary)
FIRREC:	DS	2		;First sector of first cluster
DSKSIZ:				;Size of disk (temp used during init only)
MAXCLUS:DS	2		;Number of clusters on drive + 1
FATSIZ:	DS	1		;Number of records occupied by FAT
FIRDIR:	DS	2		;Starting record of directory

	IF	SMALLDIR
FIRREC1:DS	2		;First data sector with 16-byte dir. entries
MAXCLUS1:DS	2		;No. of clusters + 1 with 16-byte dir. entries
FIRREC2:DS	2		;First data sector with 32-byte dir. entries
MAXCLUS2:DS	2		;No. of clusters + 1 with 32-byte dir entries
	ENDIF

DIRTYFAT:DS	1		;1=FAT has been changed, -1=never been read
FAT:				;Start of FAT
DIRSIZ:				;-1=small dir. entry, else large


; BIOS entry point defintions

BIOSSEG:	EQU	40H
		ORG	0
		DS	3
BIOSSTAT:	DS	3
BIOSIN:		DS	3
BIOSOUT:	DS	3
BIOSPRINT:	DS	3
BIOSAUXIN:	DS	3
BIOSAUXOUT:	DS	3
BIOSREAD:	DS	3
BIOSWRITE:	DS	3
BIOSDSKCHG:	DS	3


; Location of user registers relative user stack pointer

	ORG	0
AXSAVE:	DS	2
BXSAVE:	DS	2
CXSAVE:	DS	2
DXSAVE:	DS	2
SISAVE:	DS	2
DISAVE:	DS	2
BPSAVE:	DS	2
DSSAVE:	DS	2
ESSAVE:	DS	2
IPSAVE:	DS	2
CSSAVE:	DS	2
FSAVE:	DS	2


; Start of code

	ORG	0
	PUT	100H

	JMP	DOSINIT

ESCTAB:	
	DB	"SC"	;Copy one char
	DB	"VN"	;Skip one char
	DB	"TA"	;Copy to char
	DB	"WB"	;Skip to char
	DB	"UH"	;Copy line
	DB	"HH"	;Kill line (no change in template)
	DB	"RM"	;Reedit line (new template)
	DB	"DD"	;Backspace
	DB	"P@"	;Enter insert mode
	DB	"QL"	;Exit insert mode
	DB	ESCCH,ESCCH	;Escape character
	DB	ESCCH,ESCCH	;End of table

ESCTABLEN:EQU	$-ESCTAB

HEADER:	DB	13,10,"86-DOS version 1.00"

	IF	DSKTEST
	DB	"D"
	ENDIF

	DB	13,10
	DB	"Copyright 1980,81 Seattle Computer Products, Inc.",13,10,"$"

QUIT:
	MOV	AH,0
	JP	SAVREGS

COMMAND: ;Interrupt call entry point
	CMP	AH,MAXCOM
	JBE	SAVREGS
BADCALL:
	MOV	AL,0
IRET:	IRET

ENTRY:	;System call entry point and dispatcher
	POP	AX		;IP from the long call at 5
	POP	AX		;Segment from the long call at 5
	SEG	CS
	POP	[TEMP]		;IP from the CALL 5
	PUSHF			;Start re-ordering the stack
	DI
	PUSH	AX		;Save segment
	SEG	CS
	PUSH	[TEMP]		;Stack now ordered as if INT had been used
	CMP	CL,MAXCALL	;This entry point doesn't get as many calls
	JA	BADCALL
	MOV	AH,CL
SAVREGS:
	PUSH	ES
	PUSH	DS
	PUSH	BP
	PUSH	DI
	PUSH	SI
	PUSH	DX
	PUSH	CX
	PUSH	BX
	PUSH	AX

	IF	DSKTEST
	SEG	CS
	MOV	AX,[SPSAVE]
	SEG	CS
	MOV	[NSP],AX
	SEG	CS
	MOV	AX,[SSSAVE]
	SEG	CS
	MOV	[NSS],AX
	POP	AX
	PUSH	AX
	ENDIF

	SEG	CS
	MOV	[SPSAVE],SP
	SEG	CS
	MOV	[SSSAVE],SS
	MOV	BP,SP
	MOV	BX,[BP+CSSAVE]
	SEG	CS
	MOV	[CSLOC],BX
	MOV	SP,CS
	MOV	SS,SP
	MOV	SP,STACK
	EI			;Stack OK now
	SEG	CS
	MOV	[FUNC],AH
	MOV	BL,AH
	MOV	BH,0
	SHL	BX
	UP

	IF	DSKTEST
	CMP	AH,12
	JL	SAMSTK
	MOV	SP,TESTSTK
SAMSTK:
	ENDIF

	SEG	CS
	CALL	[BX+DISPATCH]
LEAVE:
	DI
	SEG	CS
	MOV	SP,[SPSAVE]
	SEG	CS
	MOV	SS,[SSSAVE]
	MOV	BP,SP
	MOV	[BP+AXSAVE],AL

	IF	DSKTEST
	SEG	CS
	MOV	AX,[NSP]
	SEG	CS
	MOV	[SPSAVE],AX
	SEG	CS
	MOV	AX,[NSS]
	SEG	CS
	MOV	[SSSAVE],AX
	ENDIF

	POP	AX
	POP	BX
	POP	CX
	POP	DX
	POP	SI
	POP	DI
	POP	BP
	POP	DS
	POP	ES
	IRET

DISPATCH:
; Standard Functions
	DW	ABORT		;0
	DW	CONIN
	DW	CONOUT
	DW	READER
	DW	PUNCH
	DW	LIST		;5
	DW	RAWIO
	DW	RAWINP
	DW	IN
	DW	PRTBUF
	DW	BUFIN		;10
	DW	CONSTAT
	DW	VERSION
	DW	DSKRESET
	DW	SELDSK
	DW	OPEN		;15
	DW	CLOSE
	DW	SRCHFRST
	DW	SRCHNXT
	DW	DELETE
	DW	SEQRD		;20
	DW	SEQWRT
	DW	CREATE
	DW	RENAME
	DW	INUSE
	DW	CURDRV		;25
	DW	SETDMA
	DW	GETFATPT
	DW	WRTPROT
	DW	GETRDONLY
	DW	SETATTRIB	;30
	DW	GETDSKPT
	DW	USERCODE
	DW	RNDRD
	DW	RNDWRT
	DW	FILESIZE	;35
	DW	SETRNDREC
; Extended Functions
	DW	SETVECT
	DW	NEWBASE
	DW	BLKRD
	DW	BLKWRT		;40
	DW	MAKEFCB

VERSION:
GETIO:
SETIO:
WRTPROT:
GETRDONLY:
SETATTRIB:
USERCODE:
	MOV	AL,0
	RET


READER:
	CALL	BIOSAUXIN,BIOSSEG
	RET

PUNCH:
	MOV	AL,DL
	CALL	BIOSAUXOUT,BIOSSEG
	RET


UNPACK:

; Inputs:
;	DS = CS
;	BX = Cluster number
;	BP = Base of drive parameters
;	SI = Pointer to drive FAT
; Outputs:
;	DI = Contents of FAT for given cluster
;	Zero set means DI=0 (free cluster)
; No other registers affected. Fatal error if cluster too big.

	CMP	BX,[BP+MAXCLUS]
	JA	HURTFAT
	LEA	DI,[SI+BX]
	SHR	BX
	MOV	DI,[DI+BX]
	JNC	HAVCLUS
	SHR	DI
	SHR	DI
	SHR	DI
	SHR	DI
	STC
HAVCLUS:
	RCL	BX
	AND	DI,0FFFH
	RET
HURTFAT:
	MOV	SI,BADMES
	CALL	OUTMES
	JMP	ERROR


PACK:

; Inputs:
;	DS = CS
;	BX = Cluster number
;	DX = Data
;	SI = Pointer to drive FAT
; Outputs:
;	The data is stored in the FAT at the given cluster.
;	BX,DX,DI all destroyed
;	No other registers affected

	MOV	DI,BX
	SHR	BX
	ADD	BX,SI
	ADD	BX,DI
	SHR	DI
	MOV	DI,[BX]
	JNC	ALIGNED
	SHL	DX
	SHL	DX
	SHL	DX
	SHL	DX
	AND	DI,0FH
	JP	PACKIN
ALIGNED:
	AND	DI,0F000H
PACKIN:
	OR	DI,DX
	MOV	[BX],DI
	RET

IOCHK:
	MOV	CX,5		;Check rest of name but not extension
	CMP	B,[DI],":"
	JNZ	NOCOL
	INC	DI		;Skip over colon
	DEC	CX
NOCOL:
	MOV	AL," "
	REPE
	SCAB			;Make sure rest of name is blanks
	JNZ	FILSRCH
	DEC	BL
	RET

GETFILE:

; Inputs:
;	DS,DX point to FCB
; Function:
;	Find file name in disk directory. First byte is
;	drive number (0=current disk). "?" matches any
;	character.
; Outputs:
;	Carry set if file not found
;	ELSE
;	BP = Base of drive parameters
;	DS = CS
;	ES = CS
;	BX = Pointer into directory buffer
;	SI = Pointer to First Cluster field in directory entry
;	[DIRBUF] has directory record with match
;	[NAME1] has file name
; All other registers destroyed.

	CALL	MOVNAME
	JC	RET		;Bad file name?
FINDNAME:
	MOV	AX,CS
	MOV	DS,AX
	MOV	SI,IONAME	;List of I/O devices with file names
	MOV	BX,0FF04H	;BL = number of devices
LOOKIO:
	MOV	DI,NAME1
	MOV	CX,3		;All device names are 3 letters
	REPE
	CMPB			;Check for name in list
	JZ	IOCHK		;If first 3 letters OK, check the rest
	ADD	SI,CX		;Point to next device name
	DEC	BL
	JNZ	LOOKIO
FILSRCH:			;Not a device name
	CALL	STARTSRCH
CONTSRCH:
	CALL	GETENTRY
	JC	RET
SRCH:
	CMP	B,[BX],0E5H
	JZ	NEXTENT
	MOV	SI,BX
	MOV	DI,NAME1
	MOV	CX,11
WILDCRD:
	REPE
	CMPB
	JZ	FOUND
	CMP	B,[DI-1],"?"
	JZ	WILDCRD
NEXTENT:
	CALL	NEXTENTRY
	JNC	SRCH
	RET

FOUND:
	IF	SMALLDIR
	CMP	B,[BP+DIRSIZ],-1
	JZ	RET
	ENDIF

	ADD	SI,15	
	RET


GETENTRY:

; Inputs:
;	[LASTENT] has previously searched directory entry
; Function:
;	Locates next sequential directory entry in preparation for search
; Outputs:
;	Carry set if none
;	ELSE
;	AL = Current directory block
;	BX = Pointer to next directory entry in [DIRBUF]
;	DX = Pointer to first byte after end of DIRBUF
;	[LASTENT] = New directory entry number

	MOV	AX,[LASTENT]
	INC	AX			;Start with next entry
	CMP	AX,[BP+MAXENT]
	JAE	NONE
	MOV	[LASTENT],AX
	MOV	CL,4
	SHL	AX,CL
	XOR	DX,DX

	IF	SMALLDIR
	CMP	B,[BP+DIRSIZ],-1
	JZ	SMALENT1
	ENDIF

	SHL	AX
	RCL	DX			;Account for overflow in last shift
SMALENT1:
	MOV	BX,[BP+SECSIZ]
	AND	BL,255-31		;Must be multiple of 32
	DIV	AX,BX
	MOV	BX,DX			;Position within sector
	MOV	AH,[BP+DRVNUM]		;AL=Directory sector no.
	CMP	AX,[DIRBUFID]
	JZ	HAVDIRBUF
	PUSH	BX
	CALL	DIRREAD
	POP	BX
HAVDIRBUF:
	MOV	DX,DIRBUF
	ADD	BX,DX
	ADD	DX,[BP+SECSIZ]
	RET

NEXTENTRY:

; Inputs:
;	Same as outputs of GETENTRY, above
; Function:
;	Update AL, BX, and [LASTENT] for next directory entry.
;	Carry set if no more.

	MOV	DI,[LASTENT]
	INC	DI
	CMP	DI,[BP+MAXENT]
	JAE	NONE
	MOV	[LASTENT],DI
	ADD	BX,32

	IF	SMALLDIR
	CMP	B,[BP+DIRSIZ],-1
	JNZ	BIGENT3
	SUB	BX,16
BIGENT3:
	ENDIF

	CMP	BX,DX
	JB	HAVIT
	INC	AL			;Next directory sector
	PUSH	DX			;Save limit
	CALL	DIRREAD
	POP	DX
	MOV	BX,DIRBUF
HAVIT:
	CLC
	RET

NONE:
	CALL	CHKDIRWRITE
	STC
	RET


DELETE:	; System call 19
	CALL	GETFILE
	JC	ERRET
	CMP	BH,-1		;Check if device name
	JZ	ERRET		;Can't delete I/O devices
DELFILE:
	MOV	B,[DIRTYDIR],-1
	MOV	B,[BX],0E5H
	MOV	BX,[SI]
	LEA	SI,[BP+FAT]
	OR	BX,BX
	JZ	DELNXT
	CMP	BX,[BP+MAXCLUS]
	JA	DELNXT
	CALL	RELEASE
DELNXT:
	CALL	CONTSRCH
	JNC	DELFILE
	CALL	FATWRT
	CALL	CHKDIRWRITE
	XOR	AL,AL
	RET


RENAME:	;System call 23
	CALL	MOVNAME
	JC	ERRET
	CMP	BH,-1		;Check if I/O device name
	JZ	ERRET		;If so, can't rename it
	ADD	SI,5
	MOV	DI,NAME2
	CALL	LODNAME
	CALL	FINDNAME
	JC	ERRET
RENFIL:
	MOV	B,[DIRTYDIR],-1
	MOV	DI,BX
	MOV	SI,NAME2
	MOV	CX,11
NEWNAM:
	LODB
	CMP	AL,"?"
	JZ	NOCHG
	MOV	[DI],AL
NOCHG:
	INC	DI
	LOOP	NEWNAM
	CALL	CONTSRCH
	JNC	RENFIL
	CALL	CHKDIRWRITE
	XOR	AL,AL
	RET

ERRET:
	MOV	AL,-1
	RET


MOVNAME:

; Inputs:
;	DS, DX point to FCB
; Outputs:
;	ES = CS
;	If file name OK:
;	BP has base of driver parameters
;	[NAME1] has name in upper case
; All registers except DX destroyed
; Carry set if bad file name or drive

	MOV	AX,CS
	MOV	ES,AX
	MOV	DI,NAME1
	MOV	SI,DX
	LODB
	CALL	GETBP
	JB	RET
LODNAME:
; This entry point copies a file name from DS,SI
; to ES,DI converting to upper case.
	MOV	CX,11
MOVCHK:
	LODB
	AND	AL,7FH
	CMP	AL,60H
	JLE	CASEOK
	AND	AL,5FH
CASEOK:
	CMP	AL,20H
	JC	RET
	STOB
	LOOP	MOVCHK
	RET

GETBP:
	SEG	CS
	CMP	[NUMDRV],AL
	JC	RET
	CBW
	XCHG	BP,AX
	SHL	BP
	MOV	BP,[BP+CURDRVPT]
	RET


OPEN:	;System call 15
	PUSH	DX
	PUSH	DS
	CALL	GETFILE
DOOPEN:
; Enter here to perform OPEN on file already found
; in directory. DS=ES=CS, BX points to directory
; entry in DIRBUF, SI points to First Cluster field, and
; the top of the stack has the address and segment
; of the FCB to be opened. This entry point is used
; by CREATE.
	POP	ES
	POP	DI
	JC	ERRET
	CMP	BH,-1		;Check if file is I/O device
	JZ	OPENDEV		;Special handler if so
	MOV	AL,[BP+DRVNUM]
	INC	AL
	STOB
	ADD	DI,11		;Point to extent field
	XOR	AX,AX
	STOW			;Set extent field to 0
	MOV	AX,128		;Default record size
	STOW			;Set record size
	LODW			;Get starting cluster
	MOV	DX,AX		;Save it for the moment
	MOVW			;Transfer size to FCB
	MOVW
	MOV	AX,[SI-8]	;Get date

	IF	SMALLDIR
	CMP	B,[BP+DIRSIZ],-1
	JNZ	BIGENT10
	SEG	ES
	MOV	[DI-1],0
	XOR	AX,AX		;Date not available in small entry
BIGENT10:
	ENDIF

	STOW			;Save date in FCB
	MOV	AX,[LASTENT]
	STOW			;directory location
	MOV	AX,DX		;Restore starting cluster
	STOW			; first cluster
	STOW			; last cluster accessed
	XOR	AX,AX
	STOW			; position of last cluster
	STOB			; dirty flag
	RET

OPENDEV:
	SEG	ES
	MOV	[DI+FILDIRBLK],BX ;Use dir. entry number as flag
	XOR	AL,AL
	RET


STARTSRCH:
	MOV	[LASTENT],-1
FATREAD:

; Inputs:
;	DS = CS
;	BP = Base of drive parameters
; Function:
;	If disk may have been changed, FAT is read in and buffers are
;	flagged invalid. If not, no action is taken.
; Outputs:
;	AL = 0
;	BP unchanged
; All other registers destroyed

	MOV	AL,[BP+DRVNUM]
	CALL	BIOSDSKCHG,BIOSSEG	;See what BIOS has to say
	MOV	AL,[BP+DRVNUM]
	OR	AH,[BP+DIRTYFAT]
	JS	NEWDSK		;If either say new disk, then it's so
	DEC	AH		;Check for AH=1 (disk not changed)
	JZ	RET
	MOV	AH,1
	CMP	AX,[BUFDRVNO]	;Does buffer have dirty sector of this drive?
	JZ	RET		;If so, disk has not been changed
NEWDSK:
	CMP	AL,[BUFDRVNO]	;See if buffer is for this drive
	JNZ	BUFOK		;If not, don't touch it
	MOV	[BUFSECNO],0	;Flag buffers invalid
	MOV	[BUFDRVNO],00FFH
BUFOK:
	MOV	[DIRBUFID],-1
	CALL	FIGFAT
NEXTFAT:
	PUSH	DX
	PUSH	CX
	PUSH	BX
	PUSH	AX
	CALL	DREAD
	OR	AL,AL
	POP	AX
	POP	BX
	POP	CX
	POP	DX
	JNZ	BADFAT

	IF	SMALLDIR
	MOV	DL,AL
	LEA	SI,[BP+FIRREC1]	;FIRREC and MAXCLUS for 16-byte dir entries
	CMP	B,[BP+DIRSIZ],-1
	JZ	SETSIZ
	ADD	SI,4		;FIRREC and MAXCLUS for 32-byte entries
SETSIZ:
	LODW
	MOV	[BP+FIRREC],AX
	LODW
	MOV	[BP+MAXCLUS],AX
	MOV	AL,DL
	ENDIF

	SUB	AL,[BP+FATCNT]
	JZ	RET
	NEG	AL
;{Insert error code here. AL=number of bad fats.
;Since one good FAT was read, should include option
;to rewrite all FATs.}
	JMP	FATWRT

BADFAT:
	ADD	DX,CX
	DEC	AL
	JNZ	NEXTFAT
	POP	BP
;{Insert error code here. All FATs on drive are bad.}
	MOV	SI,BADFATMES
	CALL	HARDERR
	JP	FATREAD

OKRET1:
	MOV	AL,0
	RET

CLOSE:	;System call 16
	MOV	DI,DX
	CMP	B,[DI+FILDIRBLK],-1  ;Check for I/O device
	JZ	OKRET1		;Can't close I/O device
	TEST	B,[DI+DIRTYFIL],-1
	JZ	OKRET1		;If not written to, do nothing
	MOV	AL,[DI]		;Get drive number
	CALL	GETBP		;Get base of drive parameters
	JC	BADCLOSEJ
	MOV	AL,[BP+DRVNUM]
	MOV	AH,1		;Look for dirty buffer
	SEG	CS
	CMP	AX,[BUFDRVNO]
	JNZ	FNDDIR
;Write back dirty buffer if on same drive
	PUSH	DX
	PUSH	DS
	PUSH	CS
	POP	DS
	MOV	B,[DIRTYBUF],0
	MOV	BX,[BUFFER]
	MOV	CX,1
	MOV	DX,[BUFSECNO]
	CALL	DWRITE
	POP	DS
	POP	DX
FNDDIR:
	PUSH	DX
	PUSH	DS
	CALL	GETFILE
	POP	ES
	POP	DI
BADCLOSEJ:
	JC	BADCLOSE
	MOV	AX,[LASTENT]
	SEG	ES
	CMP	AX,[DI+FILDIRBLK]
	JNZ	BADCLOSE
	SEG	ES
	MOV	CX,[DI+FIRCLUS]
	MOV	[SI],CX
	SEG	ES
	MOV	DX,[DI+FILSIZ]
	MOV	[SI+2],DX
	SEG	ES
	MOV	DX,[DI+FILSIZ+2]

	IF	SMALLDIR
	CMP	B,[BP+DIRSIZ],-1
	JNZ	BIGENT11
	MOV	[SI+4],DL
	JP	SMALLENT2
BIGENT11:
	ENDIF

	MOV	[SI+4],DX
	SEG	ES
	MOV	DX,[DI+FDATE]
	MOV	[SI-2],DX
SMALLENT2:
	CALL	DIRWRITE

CHKFATWRT:
; Do FATWRT only if FAT is dirty

	CMP	B,[BP+DIRTYFAT],1
	JNZ	OKRET

FATWRT:

; Inputs:
;	DS = CS
;	BP = Base of drive parameter table
; Function:
;	Write the FAT back to disk and reset FAT
;	dirty bit.
; Outputs:
;	AL = 0
;	BP unchanged
; All other registers destroyed

	MOV	B,[BP+DIRTYFAT],0
	CALL	FIGFAT
EACHFAT:
	PUSH	DX
	PUSH	CX
	PUSH	BX
	PUSH	AX
	CALL	DWRITE
	POP	AX
	POP	BX
	POP	CX
	POP	DX
	ADD	DX,CX
	DEC	AL
	JNZ	EACHFAT
OKRET:
	MOV	AL,0
	RET

BADCLOSE:
	MOV	B,[BP+DIRTYFAT],0
	MOV	AL,-1
	RET


FIGFAT:
; Loads registers with values needed to read or
; write a FAT.
	MOV	AL,[BP+FATCNT]
	LEA	BX,[BP+FAT]
	MOV	CL,[BP+FATSIZ]	;No. of records occupied by FAT
	MOV	CH,0
	MOV	DX,[BP+FIRFAT]	;Record number of start of FATs
	RET


DIRCOMP:
; Prepare registers for directory read or write
	CBW
	ADD	AX,[BP+FIRDIR]
	MOV	DX,AX
	MOV	BX,DIRBUF
	MOV	CX,1
	RET


CREATE:	;System call 22
	CALL	MOVNAME
	JC	ERRET3
	MOV	DI,NAME1
	MOV	CX,11
	MOV	AL,"?"
	REPNE
	SCAB
	JZ	ERRET3
	PUSH	DX
	PUSH	DS
	CALL	FINDNAME
	JNC	EXISTENT
	CALL	STARTSRCH
	CALL	GETENTRY
LOOKFRE:
	CMP	B,[BX],0E5H
	JZ	FREESPOT
	CALL	NEXTENTRY
	JNC	LOOKFRE
	POP	DS
	POP	DX
ERRET3:
	MOV	AL,-1
	RET

EXISTENT:
	CMP	BH,-1		;Check if file is I/O device
	JZ	OPENJMP		;If so, no action
	XOR	CX,CX
	MOV	[SI+2],CX
	MOV	AX,[DATE]

	IF	SMALLDIR
	MOV	[SI+4],CL
	CMP	B,[BP+DIRSIZ],-1
	JZ	SMLENT
	MOV	[SI+5],CL
	MOV	[SI-2],AX
SMLENT:
	ENDIF

	IF	1-SMALLDIR
	MOV	[SI+4],CX
	MOV	[SI-2],AX
	ENDIF

	XCHG	CX,[SI]
	PUSH	SI
	PUSH	BX
	JCXZ	WRTBACK
	CMP	CX,[BP+MAXCLUS]
	JA	WRTBACK
	MOV	BX,CX
	LEA	SI,[BP+FAT]
	CALL	RELEASE
	CALL	FATWRT
	JP	WRTBACK

FREESPOT:
	MOV	DI,BX
	MOV	SI,NAME1
	MOV	CX,5
	MOVB
	REP
	MOVW
	XOR	AX,AX

	IF	SMALLDIR
	CMP	B,[BP+DIRSIZ],-1
	JNZ	BIGENT4
	PUSH	DI
	MOV	CL,5
	JP	SMALLENT
BIGENT4:
	ENDIF

	MOV	CL,13
	REP
	STOB
	MOV	AX,[DATE]
	STOW
	XOR	AX,AX
	PUSH	DI
	MOV	CL,6
SMALLENT:
	REP
	STOB
	PUSH	BX
WRTBACK:
	CALL	DIRWRITE
	POP	BX
	POP	SI
OPENJMP:
	CLC			;Clear carry so OPEN won't fail
	JMP	DOOPEN


DIRREAD:

; Inputs:
;	DS = CS
;	AL = Directory block number
;	BP = Base of drive parameters
; Function:
;	Read the directory block into DIRBUF.
; Outputs:
;	AX,BP unchanged
; All other registers destroyed.

	PUSH	AX
	CALL	CHKDIRWRITE
	POP	AX
	PUSH	AX
	MOV	AH,[BP+DRVNUM]
	MOV	[DIRBUFID],AX
	CALL	DIRCOMP
	CALL	DREAD
	POP	AX
	RET


DREAD:

; Inputs:
;	BX,DS = Transfer address
;	CX = Number of sectors
;	DX = Absolute record number
;	BP = Base of drive parameters
; Function:
;	Calls BIOS to perform disk read. If BIOS reports
;	errors, will call HARDERR for further action.
; Outputs:
;	AL = 0 if no error, otherwise non-zero
; BP preserved. All other registers destroyed.

	MOV	AL,[BP+DRVNUM]
	PUSH	BP
	PUSH	BX
	PUSH	CX
	PUSH	DX
	CALL	BIOSREAD,BIOSSEG
	POP	DX
	POP	DI
	POP	BX
	POP	BP
	JC	HARDREAD
	XOR	AL,AL
	RET

HARDREAD:
	MOV	SI,RDERRMES
	CALL	HARDERR
	JP	DREAD


CHKDIRWRITE:
	TEST	B,[DIRTYDIR],-1
	JZ	RET

DIRWRITE:

; Inputs:
;	DS = CS
;	AL = Directory block number
;	BP = Base of drive parameters
; Function:
;	Write the directory block into DIRBUF.
; Outputs:
;	BP unchanged
; All other registers destroyed.

	MOV	B,[DIRTYDIR],0
	MOV	AL,[DIRBUFID]
	CALL	DIRCOMP


DWRITE:

; Inputs:
;	BX,DS = Transfer address
;	CX = Number of sectors
;	DX = Absolute record number
;	BP = Base of drive parameters
; Function:
;	Calls BIOS to perform disk write. If BIOS reports
;	errors, will call HARDERR for further action.
; Outputs:
;	AL = 0 if no error, otherwise non-zero
; BP preserved. All other registers destroyed.

	MOV	AL,[BP+DRVNUM]
WRTDRV:
	PUSH	AX
	PUSH	BP
	PUSH	BX
	PUSH	CX
	PUSH	DX
	CALL	BIOSWRITE,BIOSSEG
	POP	DX
	POP	DI
	POP	BX
	POP	BP
	POP	AX
	JC	HARDWRITE
	XOR	AL,AL
	RET
HARDWRITE:
	MOV	SI,WRTERRMES
	CALL	HARDERR
	JP	WRTDRV


HARDERR:
	SUB	DI,CX
	ADD	DX,DI
	CALL	SHFTDI7
	ADD	BX,DI
	MOV	AH,AL		;Save drive number
	CALL	OUTMES
GETINSTR:
	CALL	IN
	OR	AL,20H
	CMP	AL,"a"
	JZ	ERROR
	CMP	AL,"r"
	JZ	RETRY
	CMP	AL,"i"
	JZ	IGNORE
	CMP	AL,"c"
	JNZ	GETINSTR
CONTINUE:
	POP	AX
	MOV	AL,1
	RET
IGNORE:
	POP	AX
	MOV	AL,0
	RET
RETRY:
	MOV	AL,AH		;Restore drive number
	RET


ABORT:
	SEG	CS
	MOV	DS,[CSLOC]
	XOR	AX,AX
	MOV	ES,AX
	MOV	SI,SAVEXIT
	MOV	DI,EXIT
	MOVW
	MOVW
	MOVW
	MOVW
ERROR:
	MOV	AX,CS
	MOV	DS,AX
	MOV	ES,AX
	CALL	WRTFATS
	XOR	AX,AX
	DI
	MOV	SS,[SSSAVE]
	MOV	SP,[SPSAVE]
	MOV	DS,AX
	MOV	SI,EXIT
	MOV	DI,EXITHOLD
	MOVW
	MOVW
	POP	AX
	POP	BX
	POP	CX
	POP	DX
	POP	SI
	POP	DI
	POP	BP
	POP	DS
	POP	ES
	EI			;Stack OK now
	SEG	CS
	JMP	L,[EXITHOLD]


SEQRD:	;System call 20
	CALL	GETREC
	CALL	LOAD
	JP	FINSEQ

SEQWRT:	;System call 21
	CALL	GETREC
	CALL	STORE
FINSEQ:
	JCXZ	SETNREX
	ADD	AX,1
	ADC	DX,0
	JP	SETNREX

RNDRD:	;System call 33
	CALL	GETRRPOS1
	CALL	LOAD
	JP	FINRND

RNDWRT:	;System call 34
	CALL	GETRRPOS1
	CALL	STORE
	JP	FINRND

BLKRD:	;System call 39
	CALL	GETRRPOS
	CALL	LOAD
	JP	FINBLK

BLKWRT:	;System call 40
	CALL	GETRRPOS
	CALL	STORE
FINBLK:
	LDS	SI,[SPSAVE]
	MOV	[SI+CXSAVE],CX
	JCXZ	FINRND
	ADD	AX,1
	ADC	DX,0
FINRND:
	SEG	ES
	MOV	[DI+RR],AX
	SEG	ES
	MOV	[DI+RR+2],DL
	OR	DH,DH
	JZ	SETNREX
	SEG	ES
	MOV	[DI+RR+3],DH	;Save 4 byte of RECPOS only if significant
SETNREX:
	MOV	CX,AX
	AND	AL,7FH
	SEG	ES
	MOV	[DI+NR],AL
	AND	CL,80H
	SHL	CX
	RCL	DX
	MOV	AL,CH
	MOV	AH,DL
	SEG	ES
	MOV	[DI+EXTENT],AX
	SEG	CS
	MOV	AL,[DSKERR]
	RET

GETRRPOS1:
	MOV	CX,1
GETRRPOS:
	MOV	DI,DX
	MOV	AX,[DI+RR]
	MOV	DX,[DI+RR+2]
	RET

NOFILERR:
	XOR	CX,CX
	MOV	B,[DSKERR],-2
	POP	BX
	RET

SETUP:

; Inputs:
;	DS:DI point to FCB
;	DX:AX = Record position in file of disk transfer
;	CX = Record count
; Outputs:
;	DS = CS
;	ES:DI point to FCB
;	CX = No. of bytes to transfer
;	BP = Base of drive parameters
;	SI = FAT pointer
;	[RECCNT] = Record count
;	[RECPOS] = Record position in file
;	[FCB] = DI
;	[NEXTADD] = Displacement of disk transfer within segment
;	[SECPOS] = Position of first sector
;	[BYTPOS] = Byte position in file
;	[BYTSECPOS] = Byte position in first sector
;	[CLUSNUM] = First cluster
;	[SECCLUSPOS] = Sector within first cluster
;	[DSKERR] = 0 (no errors yet)
;	[TRANS] = 0 (No transfers yet)
; If SETUP detects no records will be transfered, it returns 1 level up 
; with CX = 0.

	PUSH	AX
	MOV	AL,[DI]
	MOV	SI,[DI+RECSIZ]
	OR	SI,SI
	JNZ	HAVRECSIZ
	MOV	SI,128
	MOV	[DI+RECSIZ],SI
HAVRECSIZ:
	MOV	BX,DS
	MOV	ES,BX
	MOV	BX,CS
	MOV	DS,BX
	CALL	GETBP
	POP	AX
	JC	NOFILERR
	CMP	SI,64		;Check if highest byte of RECPOS is significant
	JB	SMALREC
	MOV	DH,0		;Ignore MSB if record >= 64 bytes
SMALREC:
	MOV	[RECCNT],CX
	MOV	[RECPOS],AX
	MOV	[RECPOS+2],DX
	MOV	[FCB],DI
	MOV	BX,[DMAADD]
	MOV	[NEXTADD],BX
	MOV	B,[DSKERR],0
	MOV	B,[TRANS],0
	MOV	BX,DX
	MUL	AX,SI
	MOV	[BYTPOS],AX
	PUSH	DX
	MOV	AX,BX
	MUL	AX,SI
	POP	BX
	ADD	AX,BX
	ADC	DX,0		;Ripple carry
	JNZ	EOFERR
	MOV	[BYTPOS+2],AX
	MOV	DX,AX
	MOV	AX,[BYTPOS]
	DIV	AX,[BP+SECSIZ]
	MOV	[SECPOS],AX
	MOV	[BYTSECPOS],DX
	MOV	DX,AX
	AND	AL,[BP+CLUSMSK]
	MOV	[SECCLUSPOS],AL
	MOV	AX,CX		;Record count
	MOV	CL,[BP+CLUSSHFT]
	SHR	DX,CL
	MOV	[CLUSNUM],DX
	MUL	AX,SI		;Multiply by bytes per record
	MOV	CX,AX
	ADD	AX,[DMAADD]	;See if it will fit in one segment
	ADC	DX,0
	JZ	OK		;Must stay within 64K
	MOV	AX,[DMAADD]
	NEG	AX		;Amount of room left in segment
	XOR	DX,DX
	DIV	AX,SI		;How many records will fit?
	MUL	AX,SI		;Translate that back into bytes
	MOV	B,[DSKERR],2	;Flag that trimming took place
	MOV	CX,AX
	JCXZ	NOROOM
OK:
	LEA	SI,[BP+FAT]
	RET

EOFERR:
	MOV	B,[DSKERR],1
	XOR	CX,CX
NOROOM:
	POP	BX		;Kill return address
	RET

BREAKDOWN:

;Inputs:
;	DS = CS
;	CX = Length of disk transfer in bytes
;	BP = Base of drive parameters
;	[BYTSECPOS] = Byte position witin first sector
;Outputs:
;	[BYTCNT1] = Bytes to transfer in first sector
;	[SECCNT] = No. of whole sectors to transfer
;	[BYTCNT2] = Bytes to transfer in last sector
;AX, BX, DX destroyed. No other registers affected.

	MOV	AX,[BYTSECPOS]
	MOV	BX,CX
	OR	AX,AX
	JZ	SAVFIR		;Partial first sector?
	SUB	AX,[BP+SECSIZ]
	NEG	AX		;Max number of bytes left in first sector
	SUB	BX,AX		;Subtract from total length
	JAE	SAVFIR
	ADD	AX,BX		;Don't use all of the rest of the sector
	XOR	BX,BX		;And no bytes are left
SAVFIR:
	MOV	[BYTCNT1],AX
	MOV	AX,BX
	XOR	DX,DX
	DIV	AX,[BP+SECSIZ]	;How many whole sectors?
	MOV	[SECCNT],AX
	MOV	[BYTCNT2],DX	;Bytes remaining for last sector
	RET


FNDCLUS:

; Inputs:
;	DS = CS
;	CX = No. of clusters to skip
;	BP = Base of drive parameters
;	SI = FAT pointer
;	ES:DI point to FCB
; Outputs:
;	BX = Last cluster skipped to
;	CX = No. of clusters remaining (0 unless EOF)
;	DX = Position of last cluster
; DI destroyed. No other registers affected.

	SEG	ES
	MOV	BX,[DI+LSTCLUS]
	SEG	ES
	MOV	DX,[DI+CLUSPOS]
	OR	BX,BX
	JZ	NOCLUS
	SUB	CX,DX
	JNB	FINDIT
	ADD	CX,DX
	XOR	DX,DX
	SEG	ES
	MOV	BX,[DI+FIRCLUS]
FINDIT:
	JCXZ	RET
SKPCLP:
	CALL	UNPACK
	CMP	DI,0FF8H
	JAE	RET
	XCHG	BX,DI
	INC	DX
	LOOP	SKPCLP
	RET
NOCLUS:
	INC	CX
	DEC	DX
	RET


BUFSEC:
; Inputs:
;	AL = 0 if buffer must be read, 1 if no pre-read needed
;	BP = Base of drive parameters
;	[CLUSNUM] = Physical cluster number
;	[SECCLUSPOS] = Sector position of transfer within cluster
;	[BYTCNT1] = Size of transfer
; Function:
;	Insure specified sector is in buffer, flushing buffer before
;	read if necessary.
; Outputs:
;	SI = Pointer to buffer
;	DI = Pointer to transfer address
;	CX = Number of bytes
;	[NEXTADD] updated
;	[TRANS] set to indicate a transfer will occur

	MOV	DX,[CLUSNUM]
	MOV	BL,[SECCLUSPOS]
	CALL	FIGREC
	OR	AL,AL
	JNZ	SETBUF
	CMP	DX,[BUFSECNO]
	JNZ	GETSEC
	MOV	AL,[BUFDRVNO]
	CMP	AL,[BP+DRVNUM]
	JZ	FINBUF		;Already have it?
GETSEC:
	TEST	B,[DIRTYBUF],-1
	JZ	RDSEC
	PUSH	DX
	MOV	AL,[BUFDRVNO]
	MOV	BX,[BUFFER]
	MOV	CX,1
	MOV	DX,[BUFSECNO]
	CALL	WRTDRV
	POP	DX
RDSEC:
	MOV	BX,[BUFFER]
	MOV	CX,1
	PUSH	DX
	CALL	DREAD
	POP	DX
SETBUF:
	MOV	[BUFSECNO],DX
	MOV	AL,[BP+DRVNUM]
	MOV	AH,0
	MOV	[BUFDRVNO],AX
FINBUF:
	MOV	B,[TRANS],1	;A transfer is taking place
	MOV	DI,[NEXTADD]
	MOV	SI,DI
	MOV	CX,[BYTCNT1]
	ADD	SI,CX
	MOV	[NEXTADD],SI
	MOV	SI,[BUFFER]
	ADD	SI,[BYTSECPOS]
	RET

BUFRD:
	XOR	AL,AL		;Pre-read necessary
	CALL	BUFSEC
	PUSH	ES
	MOV	ES,[DMAADD+2]
	SHR	CX
	JNC	EVENRD
	MOVB
EVENRD:
	REP
	MOVW
	POP	ES
	RET

BUFWRT:
	MOV	AX,[SECPOS]
	INC	AX		;Set for next sector
	MOV	[SECPOS],AX
	CMP	AX,[VALSEC]	;Has sector been written before?
	MOV	AL,1
	JA	NOREAD		;Skip preread if SECPOS>VALSEC
	MOV	AL,0
NOREAD:
	CALL	BUFSEC
	XCHG	DI,SI
	PUSH	DS
	PUSH	ES
	PUSH	CS
	POP	ES
	MOV	DS,[DMAADD+2]
	SHR	CX
	JNC	EVENWRT
	MOVB
EVENWRT:
	REP
	MOVW
	POP	ES
	POP	DS
	MOV	B,[DIRTYBUF],1
	RET

NEXTSEC:
	TEST	B,[TRANS],-1
	JZ	CLRET
	MOV	AL,[SECCLUSPOS]
	INC	AL
	CMP	AL,[BP+CLUSMSK]
	JBE	SAVPOS
	MOV	BX,[CLUSNUM]
	CMP	BX,0FF8H
	JAE	NONEXT
	LEA	SI,[BP+FAT]
	CALL	UNPACK
	MOV	[CLUSNUM],DI
	INC	[LASTPOS]
	MOV	AL,0
SAVPOS:
	MOV	[SECCLUSPOS],AL
CLRET:
	CLC
	RET
NONEXT:
	STC
	RET

TRANBUF:
	LODB
	STOB
	CMP	AL,13		;Check for carriage return
	JNZ	NORMCH
	MOV	[SI],10
NORMCH:
	CMP	AL,10
	LOOPNZ	TRANBUF
	JNZ	ENDRDCON
	CALL	OUT		;Transmit linefeed
	XOR	SI,SI
	OR	CX,CX
	JNZ	GETBUF
	OR	AL,1		;Clear zero flag--not end of file
ENDRDCON:
	MOV	[CONTPOS],SI
ENDRDDEV:
	MOV	[NEXTADD],DI
	POP	ES
	JNZ	SETFCBJ		;Zero set if Ctrl-Z found in input
	MOV	DI,[FCB]
	SEG	ES
	OR	B,[DI+FILDIRBLK],80H	;Mark as no more data available
SETFCBJ:
	JMP	SETFCB

READDEV:
	PUSH	ES
	LES	DI,[DMAADD]
	OR	BL,BL
	JZ	READCON
	DEC	BL
	JNZ	ENDRDDEV
READAUX:
	CALL	BIOSAUXIN,BIOSSEG
	STOB
	CMP	AL,1AH
	LOOPNZ	READAUX
	JP	ENDRDDEV

READCON:
	PUSH	CS
	POP	DS
	MOV	SI,[CONTPOS]
	OR	SI,SI
	JNZ	TRANBUF
	CMP	B,[CONBUF],128
	JZ	GETBUF
	MOV	[CONBUF],0FF80H	;Set up 128-byte buffer with no template
GETBUF:
	PUSH	CX
	PUSH	ES
	PUSH	DI
	MOV	DX,CONBUF
	CALL	BUFIN		;Get input buffer
	POP	DI
	POP	ES
	POP	CX
	MOV	SI,CONBUF+2
	CMP	B,[SI],1AH	;Check for Ctrl-Z in first character
	JNZ	TRANBUF
	MOV	AL,1AH
	STOB
	MOV	AL,10
	CALL	OUT		;Send linefeed
	XOR	SI,SI
	JP	ENDRDCON

RDERR:
	XOR	CX,CX
	JMP	WRTERR

RDLASTJ:JMP	RDLAST

LOAD:

; Inputs:
;	DS:DI point to FCB
;	DX:AX = Position in file to read
;	CX = No. of records to read
; Outputs:
;	DX:AX = Position of last record read
;	CX = No. of bytes read
;	ES:DI point to FCB
;	LSTCLUS, CLUSPOS fields in FCB set

	CALL	SETUP
	SEG	ES
	MOV	BX,[DI+FILDIRBLK]
	CMP	BH,-1		;Check for named device I/O
	JZ	READDEV
	SEG	ES
	MOV	AX,[DI+FILSIZ]
	SEG	ES
	MOV	BX,[DI+FILSIZ+2]
	SUB	AX,[BYTPOS]
	SBC	BX,[BYTPOS+2]
	JB	RDERR
	JNZ	ENUF
	OR	AX,AX
	JZ	RDERR
	CMP	AX,CX
	JAE	ENUF
	MOV	CX,AX
ENUF:
	CALL	BREAKDOWN
	MOV	CX,[CLUSNUM]
	CALL	FNDCLUS
	OR	CX,CX
	JNZ	RDERR
	MOV	[LASTPOS],DX
	MOV	[CLUSNUM],BX
	CMP	[BYTCNT1],0
	JZ	RDMID
	CALL	BUFRD
RDMID:
	CMP	[SECCNT],0
	JZ	RDLASTJ
	CALL	NEXTSEC
	JC	SETFCB
	MOV	B,[TRANS],1	;A transfer is taking place
ONSEC:
	MOV	DL,[SECCLUSPOS]
	MOV	CX,[SECCNT]
	MOV	BX,[CLUSNUM]
RDLP:
	CALL	OPTIMIZE
	PUSH	DI
	PUSH	AX
	PUSH	DS
	MOV	DS,[DMAADD+2]
	CALL	DREAD
	POP	DS
	POP	CX
	POP	BX
	JCXZ	RDLAST
	CMP	BX,0FF8H
	JAE	SETFCB
	MOV	DL,0
	INC	[LASTPOS]	;We'll be using next cluster
	JP	RDLP

SETFCB:
	MOV	SI,[FCB]
	MOV	AX,[NEXTADD]
	MOV	DI,AX
	SUB	AX,[DMAADD]	;Number of bytes transfered
	XOR	DX,DX
	SEG	ES
	MOV	CX,[SI+RECSIZ]
	DIV	AX,CX		;Number of records
	CMP	AX,[RECCNT]	;Check if all records transferred
	JZ	FULLREC
	MOV	B,[DSKERR],1
	OR	DX,DX
	JZ	FULLREC		;If remainder 0, then full record transfered
	MOV	B,[DSKERR],3	;Flag partial last record
	SUB	CX,DX		;Bytes left in last record
	PUSH	ES
	MOV	ES,[DMAADD+2]
	XCHG	AX,BX		;Save the record count temporarily
	XOR	AX,AX		;Fill with zeros
	SHR	CX
	JNC	EVENFIL
	STOB
EVENFIL:
	REP
	STOW
	XCHG	AX,BX		;Restore record count to AX
	POP	ES
	INC	AX		;Add last (partial) record to total
FULLREC:
	MOV	CX,AX
	MOV	DI,SI		;ES:DI point to FCB
SETCLUS:
	MOV	AX,[CLUSNUM]
	SEG	ES
	MOV	[DI+LSTCLUS],AX
	MOV	AX,[LASTPOS]
	SEG	ES
	MOV	[DI+CLUSPOS],AX
ADDREC:
	MOV	AX,[RECPOS]
	MOV	DX,[RECPOS+2]
	DEC	CX
	ADD	AX,CX		;Update current record position
	ADC	DX,0
	INC	CX	
	RET

RDLAST:
	MOV	AX,[BYTCNT2]
	OR	AX,AX
	JZ	SETFCB
	MOV	[BYTCNT1],AX
	CALL	NEXTSEC
	JC	SETFCB
	MOV	[BYTSECPOS],0
	CALL	BUFRD
	JP	SETFCB

WRTDEV:
	PUSH	DS
	LDS	SI,[DMAADD]
	AND	BL,7FH
	OR	BL,BL
	JZ	WRTCON
	DEC	BL
	JZ	WRTAUX
WRTLST:
	LODB
	CMP	AL,1AH
	JZ	ENDWRDEV
	CALL	BIOSPRINT,BIOSSEG
	LOOP	WRTLST
	JP	ENDWRDEV

WRTAUX:
	LODB
	CALL	BIOSAUXOUT,BIOSSEG
	CMP	AL,1AH
	LOOPNZ	WRTAUX
	JP	ENDWRDEV

WRTCON:
	LODB
	CMP	AL,1AH
	JZ	ENDWRDEV
	CALL	OUT
	LOOP	WRTCON
ENDWRDEV:
	POP	DS
	MOV	CX,[RECCNT]
	MOV	DI,[FCB]
	JP	ADDREC

HAVSTART:
	MOV	CX,AX
	CALL	SKPCLP
	JCXZ	DOWRTJ
	CALL	ALLOCATE
	JNC	DOWRTJ
WRTERR:
	MOV	B,[DSKERR],1
LVDSK:
	MOV	AX,[RECPOS]
	MOV	DX,[RECPOS+2]
	MOV	DI,[FCB]
	RET

DOWRTJ:	JMP	DOWRT

WRTEOFJ:
	JMP	WRTEOF

STORE:

; Inputs:
;	DS:DI point to FCB
;	DX:AX = Position in file of disk transfer
;	CX = Record count
; Outputs:
;	DX:AX = Position of last record written
;	CX = No. of records written
;	ES:DI point to FCB
;	LSTCLUS, CLUSPOS fields in FCB set

	MOV	B,[DI+DIRTYFIL],1
	SEG	CS
	MOV	BX,[DATE]
	MOV	[DI+FDATE],BX
	CALL	SETUP
	SEG	ES
	MOV	BX,[DI+FILDIRBLK]
	CMP	BH,-1
	JZ	WRTDEV
	CALL	BREAKDOWN
	MOV	AX,[BYTPOS]
	MOV	DX,[BYTPOS+2]
	JCXZ	WRTEOFJ
	DEC	CX
	ADD	AX,CX
	ADC	DX,0		;AX:DX=last byte accessed
	DIV	AX,[BP+SECSIZ]	;AX=last sector accessed
	MOV	CL,[BP+CLUSSHFT]
	SHR	AX,CL		;Last cluster to be accessed
	PUSH	AX
	SEG	ES
	MOV	AX,[DI+FILSIZ]
	SEG	ES
	MOV	DX,[DI+FILSIZ]
	DIV	AX,[BP+SECSIZ]
	OR	DX,DX
	JZ	NORNDUP
	INC	AX		;Round up if any remainder
NORNDUP:
	MOV	[VALSEC],AX	;Number of sectors that have been written
	POP	AX
	MOV	CX,[CLUSNUM]	;First cluster accessed
	CALL	FNDCLUS
	MOV	[CLUSNUM],BX
	MOV	[LASTPOS],DX
	SUB	AX,DX		;Last cluster minus current cluster
	JZ	DOWRT		;If we have last clus, we must have first
	JCXZ	HAVSTART
	PUSH	CX		;No. of clusters short of first
	MOV	CX,AX
	CALL	ALLOCATE
	POP	AX
	JC	WRTERR
	MOV	CX,AX
	MOV	DX,[LASTPOS]
	INC	DX
	DEC	CX
	JZ	NOSKIP
	CALL	SKPCLP
NOSKIP:
	MOV	[CLUSNUM],BX
	MOV	[LASTPOS],DX
DOWRT:
	CMP	[BYTCNT1],0
	JZ	WRTMID
	MOV	BX,[CLUSNUM]
	CALL	BUFWRT	
WRTMID:
	MOV	AX,[SECCNT]
	OR	AX,AX
	JZ	WRTLAST
	ADD	[SECPOS],AX
	CALL	NEXTSEC
	MOV	B,[TRANS],1	;A transfer is taking place
	MOV	DL,[SECCLUSPOS]
	MOV	BX,[CLUSNUM]
	MOV	CX,[SECCNT]
WRTLP:
	CALL	OPTIMIZE
	PUSH	DI
	PUSH	AX
	PUSH	DS
	MOV	DS,[DMAADD+2]
	CALL	DWRITE
	POP	DS
	POP	CX
	POP	BX
	JCXZ	WRTLAST
	MOV	DL,0
	INC	[LASTPOS]	;We'll be using next cluster
	JP	WRTLP
WRTLAST:
	MOV	AX,[BYTCNT2]
	OR	AX,AX
	JZ	FINWRT
	MOV	[BYTCNT1],AX
	CALL	NEXTSEC
	MOV	[BYTSECPOS],0
	CALL	BUFWRT
FINWRT:
	MOV	AX,[NEXTADD]
	SUB	AX,[DMAADD]
	ADD	AX,[BYTPOS]
	MOV	DX,[BYTPOS+2]
	ADC	DX,0
	MOV	CX,DX
	MOV	DI,[FCB]
	SEG	ES
	CMP	AX,[DI+FILSIZ]
	SEG	ES
	SBB	CX,[DI+FILSIZ+2]
	JB	SAMSIZ
	SEG	ES
	MOV	[DI+FILSIZ],AX
	SEG	ES
	MOV	[DI+FILSIZ+2],DX
SAMSIZ:
	MOV	CX,[RECCNT]
	JMP	SETCLUS


WRTERRJ:JMP	WRTERR

WRTEOF:
	MOV	CX,AX
	OR	CX,DX
	JZ	KILLFIL
	SUB	AX,1
	SBC	DX,0
	DIV	AX,[BP+SECSIZ]
	MOV	CL,[BP+CLUSSHFT]
	SHR	AX,CL
	MOV	CX,AX
	CALL	FNDCLUS
	JCXZ	RELFILE
	CALL	ALLOCATE
	JC	WRTERRJ
UPDATE:
	MOV	DI,[FCB]
	MOV	AX,[BYTPOS]
	SEG	ES
	MOV	[DI+FILSIZ],AX
	MOV	AX,[BYTPOS+2]
	SEG	ES
	MOV	[DI+FILSIZ+2],AX
	XOR	CX,CX
	RET

RELFILE:
	MOV	DX,0FFFH
	CALL	RELBLKS
SETDIRT:
	MOV	B,[BP+DIRTYFAT],1
	JP	UPDATE

KILLFIL:
	XOR	BX,BX
	SEG	ES
	XCHG	BX,[DI+FIRCLUS]
	OR	BX,BX
	JZ	UPDATE
	CALL	RELEASE
	JP	SETDIRT


OPTIMIZE:

; Inputs:
;	DS = CS
;	BX = Physical cluster
;	CX = No. of records
;	DL = sector within cluster
;	BP = Base of drives parameters
;	[NEXTADD] = transfer address
; Outputs:
;	AX = No. of records remaining
;	BX = Transfer address
;	CX = No. or records to be transferred
;	DX = Physical sector address
;	DI = Next cluster
;	[CLUSNUM] = Last cluster accessed
;	[NEXTADD] updated
; BP unchanged. Note that segment of transfer not set.

	PUSH	DX
	PUSH	BX
	MOV	AL,[BP+CLUSMSK]
	INC	AL		;Number of sectors per cluster
	MOV	AH,AL
	SUB	AL,DL		;AL = Number of sectors left in first cluster
	MOV	DX,CX
	LEA	SI,[BP+FAT]
	MOV	CX,0
OPTCLUS:
;AL has number of sectors available in current cluster
;AH has number of sectors available in next cluster
;BX has current physical cluster
;CX has number of sequential sectors found so far
;DX has number of sectors left to transfer
;SI has FAT pointer
	CALL	UNPACK
	ADD	CL,AL
	ADC	CH,0
	CMP	CX,DX
	JAE	BLKDON
	MOV	AL,AH
	INC	BX
	CMP	DI,BX
	JZ	OPTCLUS
	DEC	BX
FINCLUS:
	MOV	[CLUSNUM],BX	;Last cluster accessed
	SUB	DX,CX		;Number of sectors still needed
	PUSH	DX
	MOV	AX,CX
	MUL	AX,[BP+SECSIZ]	;Number of sectors times sector size
	MOV	SI,[NEXTADD]
	ADD	AX,SI		;Adjust by size of transfer
	MOV	[NEXTADD],AX
	POP	AX		;Number of sectors still needed
	POP	DX		;Starting cluster
	SUB	BX,DX		;Number of new clusters accessed
	ADD	[LASTPOS],BX
	POP	BX		;BL = sector postion within cluster
	CALL	FIGREC
	MOV	BX,SI
	RET
BLKDON:
	SUB	CX,DX		;Number of sectors in cluster we don't want
	SUB	AH,CL		;Number of sectors in cluster we accepted
	DEC	AH		;Adjust to mean position within cluster
	MOV	[SECCLUSPOS],AH
	MOV	CX,DX		;Anyway, make the total equal to the request
	JP	FINCLUS


FIGREC:

;Inputs:
;	DX = Physical cluster number
;	BL = Sector postion within cluster
;	BP = Base of drive parameters
;Outputs:
;	DX = physical sector number
;No other registers affected.

	PUSH	CX
	MOV	CL,[BP+CLUSSHFT]
	DEC	DX
	DEC	DX
	SHL	DX,CL
	OR	DL,BL
	ADD	DX,[BP+FIRREC]
	POP	CX
	RET

GETREC:

; Inputs:
;	DS:DX point to FCB
; Outputs:
;	CX = 1
;	DX:AX = Record number determined by EXTENT and NR fields
;	DS:DI point to FCB
; No other registers affected.

	MOV	DI,DX
	MOV	CX,1
	MOV	AL,[DI+NR]
	MOV	DX,[DI+EXTENT]
	SHL	AL
	SHR	DX
	RCR	AL
	MOV	AH,DL
	MOV	DL,DH
	MOV	DH,0
	RET


ALLOCATE:

; Inputs:
;	DS = CS
;	ES = Segment of FCB
;	BX = Last cluster of file (0 if null file)
;	CX = No. of clusters to allocate
;	DX = Position of cluster BX
;	BP = Base of drive parameters
;	SI = FAT pointer
;	[FCB] = Displacement of FCB within segment
; Outputs:
;	IF insufficient space
;	  THEN
;	Carry set
;	CX = max. no. of records that could be added to file
;	  ELSE
;	Carry clear
;	BX = First cluster allocated
;	FAT is fully updated including dirty bit
;	FIRCLUS field of FCB set if file was null
; SI,BP unchanged. All other registers destroyed.

	PUSH	[SI]
	PUSH	DX
	PUSH	CX
	PUSH	BX
	MOV	AX,BX
ALLOC:
	MOV	DX,BX
FINDFRE:
	INC	BX
	CMP	BX,[BP+MAXCLUS]
	JLE	TRYOUT
	CMP	AX,1
	JG	TRYIN
	POP	BX
	MOV	DX,0FFFH
	CALL	RELBLKS
	POP	AX		;No. of clusters requested
	SUB	AX,CX		;AX=No. of clusters allocated
	POP	DX
	POP	[SI]
	INC	DX		;Position of first cluster allocated
	ADD	AX,DX		;AX=max no. of cluster in file
	MOV	DL,[BP+CLUSMSK]
	MOV	DH,0
	INC	DX		;DX=records/cluster
	MUL	AX,DX		;AX=max no. of records in file
	MOV	CX,AX
	SUB	CX,[RECPOS]	;CX=max no. of records that could be written
	JA	MAXREC
	XOR	CX,CX		;If CX was negative, zero it
MAXREC:
	STC
	RET

TRYOUT:
	CALL	UNPACK
	JZ	HAVFRE
TRYIN:
	DEC	AX
	JLE	FINDFRE
	XCHG	AX,BX
	CALL	UNPACK
	JZ	HAVFRE
	XCHG	AX,BX
	JP	FINDFRE
HAVFRE:
	XCHG	BX,DX
	MOV	AX,DX
	CALL	PACK
	MOV	BX,AX
	LOOP	ALLOC
	MOV	DX,0FFFH
	CALL	PACK
	MOV	B,[BP+DIRTYFAT],1
	POP	BX
	POP	CX		;Don't need this stuff since we're successful
	POP	DX
	CALL	UNPACK
	POP	[SI]
	XCHG	BX,DI
	OR	DI,DI
	JNZ	RET
	MOV	DI,[FCB]
	SEG	ES
	MOV	[DI+FIRCLUS],BX
	RET


RELEASE:

; Inputs:
;	DS = CS
;	BX = Cluster in file
;	SI = FAT pointer
;	BP = Base of drive parameters
; Function:
;	Frees cluster chain starting with [BX]
; AX,BX,DX,DI all destroyed. Other registers unchanged.

	XOR	DX,DX
RELBLKS:
; Enter here with DX=0FFFH to put an end-of-file mark
; in the first cluster and free the rest in the chain.
	CALL	UNPACK
	JZ	RET
	MOV	AX,DI
	CALL	PACK
	CMP	AX,0FF8H
	MOV	BX,AX
	JB	RELEASE
	RET


GETEOF:

; Inputs:
;	BX = Cluster in a file
;	SI = Base of drive FAT
;	DS = CS
; Outputs:
;	BX = Last cluster in the file
; DI destroyed. No other registers affected.

	CALL	UNPACK
	CMP	DI,0FF8H
	JAE	RET
	MOV	BX,DI
	JP	GETEOF


SRCHFRST: ;System call 17
	PUSH	DX
	PUSH	DS
	CALL	GETFILE
SAVPLCE:
; Search-for-next enters here to save place and report
; findings.
	POP	ES
	POP	DI
	JC	KILLSRCH
	CMP	BH,-1
	JZ	SRCHDEV
	MOV	AX,[LASTENT]
	SEG	ES
	MOV	[DI+FILDIRBLK],AX
;Information in directory entry must be copied into the first
; 33 bytes starting at the disk transfer address.
	MOV	SI,BX
	LES	DI,[DMAADD]
	MOV	AL,[BP+DRVNUM]
	INC	AL
	STOB		;Set drive number
	MOVB		;Copy first character of name
	MOV	CX,5
	REP
	MOVW		;Copy remaining 10 characters of name
	XOR	AX,AX

	IF	SMALLDIR
	CMP	B,[BP+DIRSIZ],-1
	JNZ	BIGENT5
	STOB		;Zero out unused portion
	MOV	CX,7
	REP
	STOW		;Zero a total of 15 bytes
	MOVW		;Copy first cluster pointer
	MOVW		;Copy low word of length
	MOVB		;Copy 3rd byte of length
	STOB		;4th byte of length must be zero
	RET
BIGENT5:
	ENDIF

	MOV	CX,10
	REP
	MOVW
	MOVB
	RET

KILLSRCH:
	SEG	ES
KILLSRCH1:
	MOV	[DI+FILDIRBLK],-2
	MOV	AL,-1
	RET

SRCHDEV:
	SEG	ES
	MOV	[DI+FILDIRBLK],BX
	LES	DI,[DMAADD]
	XOR	AX,AX
	STOB			;Zero drive byte
	SUB	SI,3		;Point to device name
	MOVW
	MOVB
	MOV	AX,2020H
	MOV	CX,4
	REP
	STOW			;Fill with 8 blanks
	XOR	AX,AX
	MOV	CX,10
	REP
	STOW
	STOB
	RET

SRCHNXT: ;System call 18
	CALL	MOVNAME
	MOV	DI,DX
	JC	KILLSRCH1
	PUSH	DX
	PUSH	DS
	MOV	AX,[DI+FILDIRBLK]
	PUSH	CS
	POP	DS
	MOV	[LASTENT],AX
	CALL	CONTSRCH
	JMP	SAVPLCE


FILESIZE: ;System call 35
	PUSH	DS
	PUSH	DX
	CALL	GETFILE
	POP	DI
	POP	ES
	MOV	AL,-1
	JC	RET
	ADD	DI,33		;Write size in RR field
	SEG	ES
	MOV	CX,[DI-33+RECSIZ]
	OR	CX,CX
	JNZ	RECOK
	MOV	CX,128
RECOK:
	XOR	AX,AX
	XOR	DX,DX		;Intialize size to zero
	CMP	BH,-1		;Check for named I/O device
	JZ	DEVSIZ
	INC	SI
	INC	SI		;Point to length field
	MOV	AX,[SI+2]	;Get high word of size

	IF	SMALLDIR
	CMP	B,[BP+DIRSIZ],-1
	JNZ	BIGSIZ
	MOV	AH,0
BIGSIZ:
	ENDIF

	DIV	AX,CX
	PUSH	AX		;Save high part of result
	LODW			;Get low word of size
	DIV	AX,CX
	OR	DX,DX		;Check for zero remainder
	POP	DX
	JZ	DEVSIZ
	INC	AX		;Round up for partial record
	JNZ	DEVSIZ		;Propagate carry?
	INC	DX
DEVSIZ:
	STOW
	MOV	AX,DX
	STOB
	MOV	AL,0
	CMP	CX,64
	JAE	RET		;Only 3-byte field if RECSIZ >= 64
	SEG	ES
	MOV	[DI],AH
	RET


SETDMA:	;System call 26
	SEG	CS
	MOV	[DMAADD],DX
	SEG	CS
	MOV	[DMAADD+2],DS
	RET


GETFATPT: ;System call 27
	MOV	AX,CS
	MOV	DS,AX
	MOV	BP,[CURDRVPT]
	CALL	FATREAD
	LEA	BX,[BP+FAT]
	MOV	AL,[BP+CLUSMSK]
	INC	AL
	MOV	DX,[BP+MAXCLUS]
	DEC	DX
	MOV	B,[BP+DIRTYFAT],1
	MOV	CX,[BP+SECSIZ]
	LDS	SI,[SPSAVE]
	MOV	[SI+BXSAVE],BX
	MOV	[SI+DXSAVE],DX
	MOV	[SI+CXSAVE],CX
	MOV	[SI+DSSAVE],CS
	RET


GETDSKPT: ;System call 31
	SEG	CS
	MOV	BX,[CURDRVPT]
	SEG	CS
	LDS	SI,[SPSAVE]
	MOV	[SI+BXSAVE],BX
	MOV	[SI+DSSAVE],CS
	RET


DSKRESET: ;System call 13
	SEG	CS
	MOV	[DMAADD+2],DS
	MOV	AX,CS
	MOV	DS,AX
	MOV	[DMAADD],80H
	MOV	AX,[CURDRVPT+2]
	MOV	[CURDRVPT],AX
WRTFATS:
; DS=CS. Writes back all dirty FATs. All registers destroyed.
	MOV	CL,[NUMDRV]
	MOV	CH,0
	MOV	SI,CURDRVPT+2
WRTFAT:
	LODW
	PUSH	CX
	PUSH	SI
	MOV	BP,AX
	CALL	CHKFATWRT
	POP	SI
	POP	CX
	LOOP	WRTFAT
	MOV	AX,[BUFDRVNO]
	OR	AH,AH
	JZ	RET
	CBW
	MOV	BX,AX
	SHL	BX
	MOV	BP,[BX+DRVTAB]
	MOV	B,[DIRTYBUF],0
	MOV	DX,[BUFSECNO]
	MOV	BX,BUFFER
	MOV	CX,1
	JMP	DWRITE


CURDRV:	;System call 25
	SEG	CS
	MOV	BP,[CURDRVPT]
	MOV	AL,[BP+DRVNUM]
	RET


INUSE:	;System call 24
	MOV	AX,CS
	MOV	DS,AX
	MOV	CL,[NUMDRV]
	MOV	CH,0
	MOV	SI,CX
	SHL	SI
	ADD	SI,CURDRVPT
	MOV	BX,0
	DOWN
CHKUSE:
	LODW
	MOV	BP,AX
	CMP	B,[BP+DIRTYFAT],-1	;Carry set if not equal
	RCL	BX
	LOOP	CHKUSE
	MOV	AL,BL
	RET


SETRNDREC: ;System call 36
	CALL	GETREC
	MOV	[DI+33],AX
	MOV	[DI+35],DL
	RET


SELDSK:	;System call 14
	MOV	DH,0
	MOV	BX,DX
	PUSH	CS
	POP	DS
	MOV	AL,[NUMDRV]
	CMP	BL,AL
	JNB	RET
	SHL	BX
	MOV	DX,[BX+CURDRVPT+2]
	MOV	[CURDRVPT],DX
	RET


BUFIN:	;System call 10
	MOV	AX,CS
	MOV	ES,AX
	MOV	SI,DX
	MOV	CH,0
	LODW
	OR	AL,AL
	JZ	RET
	MOV	BL,AH
	MOV	BH,CH
	CMP	AL,BL
	JBE	NOEDIT
	CMP	B,[BX+SI],0DH
	JZ	EDITON
NOEDIT:
	MOV	BL,CH
EDITON:
	MOV	DL,AL
	DEC	DX
NEWLIN:
	SEG	CS
	MOV	AL,[CARPOS]
	SEG	CS
	MOV	[STARTPOS],AL
	PUSH	SI
	MOV	DI,INBUF
	MOV	AH,CH
	MOV	BH,CH
	MOV	DH,CH
GETCH:
	CALL	IN
	CMP	AL,7FH
	JZ	BACKSP
	CMP	AL,8
	JZ	BACKSP
	CMP	AL,13
	JZ	ENDLIN
	CMP	AL,10
	JZ	PHYCRLF
	CMP	AL,"X"-"@"
	JZ	KILNEW
	CMP	AL,ESCCH
	JZ	ESC
SAVCH:
	CMP	DH,DL
	JAE	GETCH
	STOB
	INC	DH
	CALL	BUFOUT
	OR	AH,AH
	JNZ	GETCH
	CMP	BH,BL
	JAE	GETCH
	INC	SI
	INC	BH
	JP	GETCH

ESC:
	CALL	IN
	MOV	CL,ESCTABLEN
	PUSH	DI
	MOV	DI,ESCTAB
	REPNE
	SCAB
	POP	DI
	AND	CL,0FEH
	MOV	BP,CX
	SEG	CS		;To work in init
	JMP	[BP+ESCFUNC]

ENDLIN:
	STOB
	CALL	OUT
	POP	DI
	MOV	[DI-1],DH
	INC	DH
COPYNEW:
	MOV	BP,ES
	MOV	BX,DS
	MOV	ES,BX
	MOV	DS,BP
	MOV	SI,INBUF
	MOV	CL,DH
	REP
	MOVB
	RET
CRLF:
	MOV	AL,13
	CALL	OUT
	MOV	AL,10
	JMP	OUT

PHYCRLF:
	CALL	CRLF
	JP	GETCH

KILNEW:
	MOV	AL,"\"
	CALL	OUT
	POP	SI
PUTNEW:
	CALL	CRLF
	SEG	CS
	MOV	AL,[STARTPOS]
	CALL	TAB
	JMP	NEWLIN

BACKSP:
	OR	DH,DH
	JZ	OLDBAK
	CALL	BACKUP
	SEG	ES
	MOV	AL,[DI]
	CMP	AL," "
	JAE	OLDBAK
	CMP	AL,9
	JZ	BAKTAB
	CALL	BACKMES
OLDBAK:
	OR	AH,AH
	JNZ	GETCH1
	OR	BH,BH
	JZ	GETCH1
	DEC	BH
	DEC	SI
GETCH1:
	JMP	GETCH
BAKTAB:
	PUSH	DI
	DEC	DI
	DOWN
	MOV	CL,DH
	MOV	AL," "
	PUSH	BX
	MOV	BL,7
	JCXZ	FIGTAB
FNDPOS:
	SCAB
	JNA	CHKCNT
	SEG	ES
	CMP	B,[DI+1],9
	JZ	HAVTAB
	DEC	BL
CHKCNT:
	LOOP	FNDPOS
FIGTAB:
	SEG	CS
	SUB	BL,[STARTPOS]
HAVTAB:
	SUB	BL,DH
	ADD	CL,BL
	AND	CL,7
	UP
	POP	BX
	POP	DI
	JZ	OLDBAK
TABBAK:
	CALL	BACKMES
	LOOP	TABBAK
	JP	OLDBAK
BACKUP:
	DEC	DH
	DEC	DI
BACKMES:
	MOV	AL,8
	CALL	OUT
	MOV	AL," "
	CALL	OUT
	MOV	AL,8
	JMP	OUT

TWOESC:
	MOV	AL,ESCCH
	JMP	SAVCH

COPYLIN:
	MOV	CL,BL
	SUB	CL,BH
	JP	COPYEACH

COPYSTR:
	CALL	FINDOLD
	JP	COPYEACH

COPYONE:
	MOV	CL,1
COPYEACH:
	CMP	DH,DL
	JZ	GETCH2
	CMP	BH,BL
	JZ	GETCH2
	LODB
	STOB
	CALL	BUFOUT
	INC	BH
	INC	DH
	LOOP	COPYEACH
GETCH2:
	JMP	GETCH

SKIPONE:
	CMP	BH,BL
	JZ	GETCH2
	INC	BH
	INC	SI
	JMP	GETCH

SKIPSTR:
	CALL	FINDOLD
	ADD	SI,CX
	ADD	BH,CL
	JMP	GETCH

FINDOLD:
	CALL	IN
	MOV	CL,BL
	SUB	CL,BH
	JZ	NOTFND
	DEC	CX
	JZ	NOTFND
	PUSH	ES
	PUSH	DS
	POP	ES
	PUSH	DI
	MOV	DI,SI
	INC	DI
	REPNE
	SCAB
	POP	DI
	POP	ES
	JNZ	NOTFND
	NOT	CL
	ADD	CL,BL
	SUB	CL,BH
	RET
NOTFND:
	POP	BP
	JMP	GETCH

REEDIT:
	MOV	AL,"@"
	CALL	OUT
	POP	DI
	PUSH	DI
	PUSH	ES
	PUSH	DS
	CALL	COPYNEW
	POP	DS
	POP	ES
	POP	SI
	MOV	BL,DH
	JMP	PUTNEW

ENTERINS:
	MOV	AH,-1
	JMP	GETCH

EXITINS:
	MOV	AH,0
	JMP	GETCH

ESCFUNC:
	DW	GETCH
	DW	TWOESC
	DW	EXITINS
	DW	ENTERINS
	DW	BACKSP
	DW	REEDIT
	DW	KILNEW
	DW	COPYLIN
	DW	SKIPSTR
	DW	COPYSTR
	DW	SKIPONE
	DW	COPYONE

BUFOUT:
	CMP	AL," "
	JAE	OUT
	CMP	AL,9
	JZ	OUT
	PUSH	AX
	MOV	AL,"^"
	CALL	OUT
	POP	AX
	OR	AL,40H
	JP	OUT

CONOUT:	;System call 2
	MOV	AL,DL
OUT:
	CMP	AL,20H
	JB	CTRLOUT
	CMP	AL,7FH
	JZ	OUTCH
	SEG	CS
	INC	B,[CARPOS]
OUTCH:
	CALL	BIOSOUT,BIOSSEG
	SEG	CS
	TEST	B,[PFLAG],-1
	JZ	STATCHK
	CALL	BIOSPRINT,BIOSSEG
STATCHK:
	CALL	BIOSSTAT,BIOSSEG
	JZ	RET
INCHK:
	CALL	BIOSIN,BIOSSEG
	CMP	AL,'S'-'@'
	JNZ	NOSTOP
	CALL	BIOSIN,BIOSSEG
NOSTOP:
	CMP	AL,'P'-'@'
	JZ	PRINTON
	CMP	AL,'N'-'@'
	JZ	PRINTOFF
	CMP	AL,'C'-'@'
	JNZ	RET
; Ctrl-C handler.
; If function 9 or 10 was in progress, a backslash, CR, and LF are printed
; to show line is canceled. Then the user registers are restored and the
; user CTRL-C handler is executed. At this point the top of the stack has
; 1) the interrupt return address should the user CTRL-C handler wish to
; allow processing to continue; 2) the original interrupt return address
; to the code that performed the function call in the first place. If the
; user CTRL-C handler wishes to continue, it must leave all registers
; unchanged and IRET. The function that was interrupted will simply be
; repeated, except for console output (function 2), which has already output
; its character before the interrupt.
	SEG	CS
	MOV	AL,[FUNC]	;Get currently executing function
	CMP	AL,10		;Check if buffered line input
	JZ	CANLIN
	CMP	AL,9		;Check if buffered line output
	JNZ	RESTREG
CANLIN:
	MOV	AL,"\"		;Display cancel line symbol
	CALL	OUT
	CALL	CRLF
RESTREG:
	DI			;Prepare to play with stack
	SEG	CS
	MOV	SS,[SSSAVE]
	SEG	CS
	MOV	SP,[SPSAVE]	;User stack now restored
	POP	AX
	POP	BX
	POP	CX
	POP	DX
	POP	SI
	POP	DI
	POP	BP
	POP	DS
	POP	ES		;User registers now restored
	INT	CONTC		;Execute user Ctrl-C handler
	CMP	AH,2		;Check if function was console output
	JZ	SETAL
	JMP	COMMAND		;Repeat command otherwise
SETAL:
	MOV	AL,DL
	IRET			;Return to user program

PRINTON:
	SEG	CS
	MOV	B,[PFLAG],1
	RET
PRINTOFF:
	SEG	CS
	MOV	B,[PFLAG],0
	RET
CTRLOUT:
	CMP	AL,13
	JZ	ZERPOS
	CMP	AL,8
	JZ	BACKPOS
	CMP	AL,9
	JNZ	OUTCHJ
	SEG	CS
	MOV	AL,[CARPOS]
	OR	AL,0F8H
	NEG	AL
TAB:
	PUSH	CX
	MOV	CL,AL
	MOV	CH,0
TABLP:
	MOV	AL," "
	CALL	OUT
	LOOP	TABLP
	POP	CX
	RET

ZERPOS:
	SEG	CS
	MOV	B,[CARPOS],0
OUTCHJ:	JMP	OUTCH

BACKPOS:
	SEG	CS
	DEC	B,[CARPOS]
	JMP	OUTCH


CONSTAT: ;System call 11
	CALL	BIOSSTAT,BIOSSEG
	JZ	RET
	OR	AL,-1
	RET


CONIN:	;System call 1
	CALL	IN
	PUSH	AX
	CALL	OUT
	POP	AX
	RET


IN:	;Internal input routine
	CALL	INCHK
	JZ	IN
	RET

RAWIO:	;System call 6
	MOV	AL,DL
	CMP	AL,-1
	JNZ	RAWOUT
	CALL	BIOSSTAT,BIOSSEG
	JZ	RET
RAWINP:	;System call 7
	CALL	BIOSIN,BIOSSEG
	RET
RAWOUT:
	CALL	BIOSOUT,BIOSSEG
	RET

LIST:	;System call 5
	MOV	AL,DL
	CALL	BIOSPRINT,BIOSSEG
	RET

PRTBUF:	;System call 9
	MOV	SI,DX
OUTSTR:
	LODB
	CMP	AL,"$"
	JZ	RET
	CALL	OUT
	JP	OUTSTR

OUTMES:	;String output for internal messages
	SEG	CS
	LODB
	CMP	AL,"$"
	JZ	RET
	CALL	OUT
	JP	OUTMES


MAKEFCB: ;Interrupt call 41
	MOV	DL,0		;Flag--not ambiguous file name
	OR	AL,AL		;Scan off separators if not zero
	JZ	NOSCAN
SCAN:
	CALL	GETLET
	JZ	SCAN		;Get rid of leading separators (e.g., blanks)
	DEC	SI		;Point back to first non-separator
NOSCAN:
	CMP	B,[SI+1],":"	;Check for potential drive specifier
	JNZ	DEFAULT
	CALL	GETLET
	SUB	AL,"@"		;Convert drive letter to binary drive number
	JZ	NODRV		;Valid drive numbers are 1-15
	INC	SI
	CMP	AL,15
	JBE	HAVDRV
	DEC	SI
NODRV:
	DEC	SI		;Invalid drive specifier--back up pointer
DEFAULT:
	XOR	AL,AL
HAVDRV:
	STOB			;Put drive specifier in first byte
	MOV	CX,8
	CALL	GETWORD		;Get 8-letter file name
	CMP	B,[SI],"."
	JNZ	NODOT
	INC	SI		;Skip over dot if present
NODOT:
	MOV	CX,3		;Get 3-letter extension
	CALL	GETWORD
	SEG	CS
	LDS	BX,[SPSAVE]
	MOV	[BX+SISAVE],SI
	XOR	AX,AX
	STOW
	STOW
	MOV	AL,DL
	RET

GETWORD:
	CALL	GETLET
	JZ	FILLNAM		;Exit if invalid character
	CMP	AL," "
	JBE	FILLNAM
	CMP	AL,"*"		;Check for ambiguous file specifier
	JNZ	NOSTAR
	MOV	AL,"?"
	DEC	CX
	REP
	STOB			;Fill rest of word with "?"
	INC	CX
NOSTAR:
	STOB
	CMP	AL,"?"
	JNZ	NOTQ
	MOV	DL,1		;Flag ambiguous file name
NOTQ:
	LOOP	GETWORD
	INC	SI		;Point to "termination" character
FILLNAM:
	MOV	AL," "
	REP
	STOB
	DEC	SI
	RET

GETLET:
	LODB
	CMP	AL,"a"
	JB	CHK
	CMP	AL,"z"
	JA	CHK
	SUB	AL,20H		;Convert to upper case
CHK:
	CMP	AL," "
	JZ	RET
	CMP	AL,"="
	JZ	RET
	CMP	AL,","
	JZ	RET
	CMP	AL,";"
	JZ	RET
	CMP	AL,"."
	JZ	RET
	CMP	AL,":"
	JZ	RET
	CMP	AL,9		;Filter out TABs too
	RET


SETVECT: ; Interrupt call 37
	XOR	BX,BX
	MOV	ES,BX
	MOV	BL,AL
	SHL	BX
	SHL	BX
	SEG	ES
	MOV	[BX],DX
	SEG	ES
	MOV	[BX+2],DS
	RET


NEWBASE: ; Interrupt call 38
	MOV	ES,DX
	SEG	CS
	MOV	DS,[CSLOC]
	XOR	SI,SI
	MOV	DI,SI
	MOV	CX,80H
	REP
	MOVW

SETMEM:

; Inputs:
;	DX = Segment
; Function:
;	Completely prepares a program base at the 
;	specified segment.
; Outputs:
;	DS = DX
;	ES = DX
;	[0] has INT 20H
;	[2] = First unavailable segment ([ENDMEM])
;	[5] to [9] form a long call to the entry point
;	[10] to [13] have exit address (from INT 22H)
;	[14] to [17] have ctrl-C exit address (from INT 23H)
; AX,DX,BP unchanged. All other registers destroyed.

	XOR	CX,CX
	MOV	DS,CX
	MOV	ES,DX
	MOV	SI,EXIT
	MOV	DI,SAVEXIT
	MOVW
	MOVW
	MOVW
	MOVW
	SEG	CS
	MOV	CX,[ENDMEM]
	SEG	ES
	MOV	[2],CX
	SUB	CX,DX
	CMP	CX,MAXDIF
	JBE	HAVDIF
	MOV	CX,MAXDIF
HAVDIF:
	MOV	BX,ENTRYPOINTSEG
	SUB	BX,CX
	SHL	CX
	SHL	CX
	SHL	CX
	SHL	CX
	MOV	DS,DX
	MOV	[6],CX
	MOV	[8],BX
	MOV	[0],20CDH	;"INT INTTAB"
	MOV	B,[5],LONGCALL
	RET


SHFTDI7:
	SHL	DI
	SHL	DI
	SHL	DI
	SHL	DI
	SHL	DI
	SHL	DI
	SHL	DI
	RET


; Default handler for division overflow trap
DIVOV:
	XOR	DX,DX		;Say no remainder
	MOV	AX,-1		;But large quotient
	IRET


;***** DATA AREA *****

BADMES:	DB	13,10,"Bad FAT",13,10,"$"
BADFATMES:DB	13,10,"All FATs on disk are bad",13,10,"$"
RDERRMES:DB	13,10,"Disk read error",13,10,"$"
WRTERRMES:DB	13,10,"Disk write error",13,10,"$"
IONAME:	DB	"PRN","LST","AUX","CON"

CARPOS:	DB	0
STARTPOS:DB	0
PFLAG:	DB	0
DIRTYDIR:DB	0	;Dirty buffer flag
NUMDRV:	DS	1	;Number of drives
CONTPOS:DW	0
DMAADD:	DW	80H	;User's disk transfer address (disp/seg)
	DS	2
ENDMEM:	DS	2
MAXSEC:	DW	0
BUFFER:	DS	2
BUFSECNO:DW	0
BUFDRVNO:DB	-1
DIRTYBUF:DB	0
DIRBUFID:DW	-1
DATE:	DS	2
CURDRVPT:DS	2
DRVTAB:	DS	30	;Enough for 15 drives
INBUF:	DS	15	;Only the first part

; Init code overlaps with data area below

INITCODE:

	DS	128-15	;More of INBUF
CONBUF:	DS	130	;The rest of INBUF and console buffer
FUNC:	DS	1	;Currently executing function code
LASTENT:DS	2
EXITHOLD:DS	4
FATBASE:DS	2
NAME1:	DS	11	;File name buffer
NAME2:	DS	11
TEMP:
CSLOC:	DS	2
SPSAVE:	DS	2
SSSAVE:	DS	2
SECCLUSPOS:DS	1	;Position of first sector within cluster
DSKERR:	DS	1
TRANS:	DS	1

	ALIGN
FCB:	DS	2	;Address of user FCB
NEXTADD:DS	2
RECPOS:	DS	4
RECCNT:	DS	2
LASTPOS:DS	2
CLUSNUM:DS	2
SECPOS:	DS	2		;Position of first sector accessed
VALSEC:	DS	2		;Number of valid (previously written) sectors
BYTSECPOS:DS	2	;Position of first byte within sector
BYTPOS:	DS	4		;Byte position in file of access
BYTCNT1:DS	2		;No. of bytes in first sector
BYTCNT2:DS	2		;No. of bytes in last sector
SECCNT:	DS	2		;No. of whole sectors

	DS	60	;Stack space
STACK:

	IF	DSKTEST
NSS:	DS	2
NSP:	DS	2
	DS	60
TESTSTK:
	ENDIF

DIRBUF:

;Init code below overlaps with data area above

	ORG	INITCODE
	PUT	$+100H

MOVFAT:
;This section of code is safe from being overwritten by block move
	SEG	ES
	REP
	MOVB
	UP
FININIT:
	CALL	SETMEM		;Set up segment
	RET	L

DOSINIT:
	DI
	UP
	PUSH	CS
	POP	ES
	LODB
	SEG	ES
	MOV	[NUMDRV],AL
	MOV	BX,DRVTAB
	MOV	DI,MEMSTRT
PERDRV:
	SEG	ES
	MOV	[BX],DI
	MOV	BP,DI
	INC	BX
	INC	BX
	SEG	ES
	MOV	AL,[DRVCNT]
	STOB			;DRVNUM
	LODW			;Pointer to DPT
	PUSH	SI
	MOV	SI,AX
	LODW
	STOW			;SECSIZ
	MOV	DX,AX
	SEG	ES
	CMP	AX,[MAXSEC]
	JBE	NOTMAX
	SEG	ES
	MOV	[MAXSEC],AX
NOTMAX:
	LODB
	DEC	AL
	STOB			;CLUSMSK
	JZ	HAVSHFT
	CBW
FIGSHFT:
	INC	AH
	SAR	AL
	JNZ	FIGSHFT
	MOV	AL,AH
HAVSHFT:
	STOB			;CLUSSHFT
	MOVW			;FIRFAT (= number of reserved sectors)
	MOVB			;FATCNT
	MOVW			;MAXENT
	MOV	AX,DX		;SECSIZ again
	MOV	CL,5
	SHR	AX,CL
	MOV	CX,AX		;Directory entries per sector
	DEC	AX
	SEG	ES
	ADD	AX,[BP+MAXENT]
	XOR	DX,DX
	DIV	AX,CX
	STOW			;DIRSEC (temporarily)
	SHR	AX		;Divide by two
	ADC	AX,0		;Round up
	SEG	ES
	MOV	[SDIRSEC],AX	;Number of directory records for small entries
	MOVW			;DSKSIZ (temporarily)
FNDFATSIZ:
	MOV	AL,1
	MOV	DX,1
GETFATSIZ:
	PUSH	DX
	CALL	FIGFATSIZ
	POP	DX
	CMP	AL,DL		;Compare newly computed FAT size with trial
	JZ	HAVFATSIZ	;Has sequence converged?
	CMP	AL,DH		;Compare with previous trial
	MOV	DH,DL
	MOV	DL,AL		;Shuffle trials
	JNZ	GETFATSIZ	;Continue iterations if not oscillating
	SEG	ES
	DEC	[BP+DSKSIZ]	;Damp those oscillations
	JP	FNDFATSIZ	;Try again
HAVFATSIZ:
	STOB			;FATSIZ
	SEG	ES
	MUL	AL,[BP+FATCNT]	;Space occupied by all FATs
	SEG	ES
	ADD	AX,[BP+FIRFAT]
	STOW			;FIRDIR

	IF	SMALLDIR-1
	SEG	ES
	ADD	AX,[BP+DIRSEC]
	SEG	ES
	MOV	[BP+FIRREC],AX	;Destroys DIRSEC
	CALL	FIGMAX
	SEG	ES
	MOV	[BP+MAXCLUS],CX
	ENDIF

	IF	SMALLDIR
	MOV	DX,AX		;Save FIRDIR momentarily
	SEG	ES
	ADD	AX,[SDIRSEC]	;Add number of dir. sectors for 16-byte entry
	STOW			;FIRREC1
	XCHG	AX,CX		;Previously computed MAXCLUS
	STOW			;MAXCLUS1
	XCHG	DX,AX
	SEG	ES
	ADD	AX,[BP+DIRSEC]	;Add number of dir. sectores for 32-byte entry
	STOW			;FIRREC2
	CALL	FIGMAX
	XCHG	AX,CX
	STOW			;MAXCLUS2
	ENDIF

	MOV	AX,0FFH
	STOB			;DIRTYFAT
	SEG	ES
	MOV	AL,[BP+FATSIZ]
	SEG	ES
	MUL	AX,[BP+SECSIZ]
	ADD	DI,AX		;Allocate FAT
	POP	SI		;Restore pointer to init. table
	SEG	ES
	MOV	AL,[DRVCNT]
	INC	AL
	SEG	ES
	MOV	[DRVCNT],AL
	SEG	ES
	CMP	AL,[NUMDRV]
	JAE	CONTINIT
	JMP	PERDRV	
CONTINIT:
	LODW			;Max. buffer size
	SEG	ES
	MOV	BX,[MAXSEC]
	MOV	AX,DIRBUF
	ADD	AX,BX
	SEG	ES
	MOV	[BUFFER],AX	;Start of buffer
	PUSH	DI		;Save ending location
	ADD	DI,BX		;Allocate directory buffer
	ADD	DI,BX		;Allocate buffer space
	ADD	DI,ADJFAC+15	;True start of free space
	MOV	CL,4
	SHR	DI,CL		;First free segment
	MOV	BP,DI
	XOR	AX,AX
	MOV	DS,AX
	MOV	ES,AX
	MOV	DI,INTBASE
	MOV	AX,QUIT
	STOW			;Set abort address--displacement
	MOV	AX,CS
	MOV	B,[ENTRYPOINT],LONGJUMP
	MOV	[ENTRYPOINT+1],ENTRY
	MOV	[ENTRYPOINT+3],AX
	MOV	[0],DIVOV	;Set default divide trap address
	MOV	[2],AX
	MOV	CX,9
	REP
	STOW				;Set 5 segments (skip 2 between each)
	MOV	[INTBASE+4],COMMAND
	MOV	[INTBASE+12],IRET	;CTRL-C exit
	MOV	[INTBASE+16],IRET	;Fatal error exit
	MOV	AX,BIOSREAD
	STOW
	MOV	AX,BIOSSEG
	STOW
	STOW	;Add 2 to DI
	STOW
	MOV	[INTBASE+18H],BIOSWRITE
	MOV	DX,CS
	MOV	DS,DX
	ADD	DX,BP
	MOV	[DMAADD],80H
	MOV	[DMAADD+2],DX
	MOV	AX,[DRVTAB]
	MOV	[CURDRVPT],AX
	MOV	CX,DX
	MOV	BX,0FH
MEMSCAN:
	INC	CX
	JZ	HAVMEM
	MOV	DS,CX
	MOV	AL,[BX]
	NOT	AL
	MOV	[BX],AL
	CMP	AL,[BX]
	NOT	AL
	MOV	[BX],AL
	JZ	MEMSCAN
HAVMEM:
	SEG	CS
	MOV	[ENDMEM],CX
	XOR	CX,CX
	MOV	DS,CX
	MOV	[EXIT],100H
	MOV	[EXIT+2],DX
	MOV	SI,HEADER
	CALL	OUTMES
	PUSH	CS
	POP	DS
	PUSH	CS
	POP	ES
	PUSH	DX
GETDAT:
	MOV	SI,DATMES
	CALL	OUTMES
	MOV	DX,DATBUF
	CALL	BUFIN
	CALL	CRLF
	MOV	SI,DATBUF+2
	MOV	DX,12
	CALL	MYD
	JC	GETDAT
	MOV	CL,5
	SHL	AX,CL
	MOV	[DATE],AX
	MOV	DX,31
	CALL	MYD
	JC	GETDAT
	OR	[DATE],AL
	MOV	DX,2100
	CALL	MYD
	JC	GETDAT
	SUB	AX,80
	JC	GETDAT
	CMP	AX,19
	JBE	SAVYR
	SUB	AX,1900
	JC	GETDAT
SAVYR:
	SHL	AL
	OR	[DATE+1],AL
;Move the FATs into position and adjust the drive pointer table
	POP	DX
	POP	SI
	MOV	AX,[MAXSEC]
	SHL	AX		;Allocate two buffers
	ADD	AX,ADJFAC
	JZ	FINJMP
	MOV	DI,DRVTAB
	MOV	CX,15
ADJLP:
	ADD	[DI],AX
	INC	DI
	INC	DI
	LOOP	ADJLP
	MOV	CX,SI
	MOV	SI,MEMSTRT	;Place to move FATs from
	SUB	CX,SI		;Total length of FATs
	MOV	DI,AX
	ADD	DI,SI		;Place to move FATs to
	OR	AX,AX
	JS	MOVJMP
	DEC	CX
	ADD	DI,CX
	ADD	SI,CX
	INC	CX
	DOWN
MOVJMP:
	JMP	MOVFAT
FINJMP:	JMP	FININIT

FIGFATSIZ:
	SEG	ES
	MUL	AL,[BP+FATCNT]
	SEG	ES
	ADD	AX,[BP+FIRFAT]
	SEG	ES
	ADD	AX,[SDIRSEC]	;Use small dir. entry to figure FAT size
FIGMAX:
;AX has equivalent of FIRREC
	SEG	ES
	SUB	AX,[BP+DSKSIZ]
	NEG	AX
	SEG	ES
	MOV	CL,[BP+CLUSSHFT]
	SHR	AX,CL
	INC	AX
	MOV	CX,AX		;MAXCLUS
	INC	AX
	MOV	DX,AX
	SHR	DX
	ADC	AX,DX		;Size of FAT in bytes
	SEG	ES
	MOV	SI,[BP+SECSIZ]
	ADD	AX,SI
	DEC	AX
	XOR	DX,DX
	DIV	AX,SI
	RET

MYD:
;SI points to input buffer. Get decimal number < DX and return it
;in AX. Carry set on error.
	XOR	BX,BX
	MOV	AH,0
GETDIG:
	LODB
	SUB	AL,"0"
	JC	CHKRET
	CMP	AL,10
	JNC	CHKRET
	SHL	BX
	MOV	CX,BX
	SHL	BX
	SHL	BX
	ADD	BX,CX
	ADD	BX,AX
	JP	GETDIG
CHKRET:
	MOV	AX,BX
	OR	AX,AX
	STC
	JZ	RET
	CMP	DX,AX
	RET

DRVCNT:	DB	0

DATMES:	DB	"Enter today's date (m-d-y): $"
DATBUF:	DB	12,8,"04-28-81",13
	DS	5

SDIRSEC:DS	2

MEMSTRT:
ADJFAC:	EQU	DIRBUF-MEMSTRT
