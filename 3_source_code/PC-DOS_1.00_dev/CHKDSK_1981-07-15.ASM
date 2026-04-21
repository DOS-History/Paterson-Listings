; CHKDSK	Version 1.0	03/10/81

; Verifies and repairs 86-DOS disk directory.

SETDRV:	EQU	14
GETDRV:	EQU	25
GETMAP:	EQU	27
OPEN:	EQU	15
CLOSE:	EQU	16
DELETE:	EQU	19
SETDMA:	EQU	26
SRCHFST:EQU	17
SRCHNXT:EQU	18
OUTCH:	EQU	2
BLKWRT:	EQU	40
PRINTBUF:EQU	9

	ORG	100H
	PUT	100H

CHKDSK:
	MOV	SP,STACK
	OR	AL,AL		;SEE IF INVALID DRIVE SPECIFIED
	JNZ	DRVERR		;IF SO JUST EXIT
	CMP	B,[5DH],20H	;MAKE SURE TYPED CORRECTLY
	JNZ	PRMERR		;IF NOT PARAMETER ERROR
	MOV	AH,GETDRV
	INT	21H
	MOV	[CURDRV],AL
	MOV	DL,[5CH]
	OR	DL,DL
	JZ	DRVMOV
	MOV	AH,SETDRV
	DEC	DL
	INT	21H
	CMP	AL,DL
	JA	DRVSET
DRVERR:	MOV	DX,BADDRV
ERROR:
	MOV	AH,PRINTBUF
	INT	33
	INT	32

PRMERR:	MOV	DX,INVPRM	;Invalid parameter
	JP	ERROR
BADDSK:
	MOV	AX,CS
	MOV	DS,AX
	MOV	AH,SETDRV
	MOV	DL,[CURDRV]
	INT	33
	MOV	DX,DIRBAD
	JP	ERROR
DRVMOV:	MOV	DL,AL		;Correct drive designator
DRVSET:
	MOV	B,[WRKDRV],DL	;Save drive indicator
	INC	DL		;FOR FCB SET
	MOV	B,[ALLDRV],DL	;FCB ok now
	DEC	DL
	CALL	DRVXCG		;Change drives and do map read
	CMP	B,[BX],0FEH	;Check for initialized disk
	JNE	BADDSK
	PUSH	DS
	PUSH	ES
	POP	DS
	MOV	[DSKSIZ],DX	;Number of allocation units
	MOV	[SECSIZ],CX	;Size of physical sector
	MOV	AH,0
	MOV	[CLUSSIZ],AX	;Sectors per cluster
	MOV	CX,DX
	MOV	DI,MAP
	XOR	AX,AX
	REP
	STOW			;Zero out allocation map
	MOV	CX,AX
	MOV	[ALLOC],AX	;Count of allocation units used
	MOV	[FILECNT],AX	;Number of files found
	MOV	[DELCNT],AX	;Number of files deleted due to error
	MOV	BP,DI
	MOV	[NAMTAB],BP	;First address of file list
	MOV	DX,DI
	MOV	AH,SETDMA
	INT	21H
	MOV	AH,SRCHFST
	MOV	DX,ALLFILE
	INT	21H
	INC	AL
	POP	ES		;ES:BX point to FAT
	JNZ	GETFILES
	JMP	COMPMAP
GETFILES:
	INC	CX		;Count number of files
	ADD	DI,44		;Separate in file in list by 44 bytes
	MOV	DX,DI
	MOV	AH,SETDMA
	INT	21H
	MOV	AH,SRCHNXT
	MOV	DX,ALLFILE
	INT	21H
	INC	AL
	JNZ	GETFILES	;Loop until all files are in list
	MOV	[FILECNT],CX
	MOV	CX,1		;File number (position in list)
	MOV	DX,[DSKSIZ]
	INC	DX		;Maximum cluster number
	MOV	[MAXCLUS],DX
	ADD	BP,34		;Point to "first cluster" entry
EACHFIL:
	XOR	AX,AX		;No. of clusters in file
	MOV	SI,[BP]		;First cluster of file
	CMP	SI,[MAXCLUS]	;Make sure it's legal
	MOV	DI,BADDIR
	JA	BADFIRST
	OR	SI,SI		;Check for zero-length file
	JZ	HAVENDJ
SCANFAT:
	MOV	DI,CX
	SHL	SI
	XCHG	DI,[SI+MAP-4]	;Xchange current map entry with file no.
	SHR	SI
	OR	DI,DI		;Should be zero for unallocated cluster
	JNZ	CROSSLINK
	INC	AX		;Count cluster as part of this file
	CALL	UNPACK
	JZ	FORCEND		;Make sure cluster knows it's allocated
	CMP	DI,0FF8H	;Bigger than this means End of File
HAVENDJ:JAE	HAVEND
	CMP	DI,[MAXCLUS]	;Make sure it's a legal value
	JA	FORCEND
	MOV	SI,DI
	JP	SCANFAT		;Visit each cluster allocated to file

BADFIRST:
	PUSH	AX		;Because FILERR will pop it later
	MOV	[BP+2],AX	;AX is zero
	MOV	[BP+4],AX	;Set size to zero so we won't change it
	MOV	AX,CX
	MOV	DX,44
	DEC	AX
	MUL	AX,DX		;Get position in file name table
	MOV	DX,AX
	ADD	DX,[NAMTAB]
	MOV	AH,DELETE
	INT	21H
	PUSH	DS
	PUSH	CX
	PUSH	AX
	CALL	DRVXCG		;Reset dirty bit to rewrite FAT
	POP	AX
	POP	CX
	POP	DS
	OR	AL,AL		;SEE IF WE HAVE A VALID DIRECTORY
	JZ	DISKOK
	JMP	BADDSK
DISKOK:
	INC	[DELCNT]	;Count one deleted file
	MOV	DX,BADDIR
	JP	FILERR

CROSSLINK:
	MOV	DX,LINKED
	PUSH	AX
	MOV	AH,PRINTBUF
	INT	21H
	MOV	AX,DI
	CALL	PRINTNAM
	MOV	DX,FILE2
	MOV	AH,PRINTBUF
	INT	33
	MOV	AX,CX
	CALL	PRINTNAM
	MOV	DX,CRLF
	MOV	AH,PRINTBUF
	INT	33
	POP	AX
	ADD	[ALLOC],AX
	JMP	SIZSET1

FORCEND:
; Come here if a cluster allocated to a file contained an illegal
; link--either a zero (meaning unallocated), or a value larger than
; the maximum cluster number, but not End of File. Put an End of File
; mark there so the FAT will at least be well-formed.
	MOV	DX,0FFFH
	CALL	PACK
	MOV	DX,BADCLUS
	PUSH	AX

FILERR:
	MOV	AH,PRINTBUF
	INT	21H
	MOV	AX,CX
	CALL	PRINTNAM
	MOV	DX,CRLF
	MOV	AH,PRINTBUF
	INT	21H
	POP	AX

HAVEND:
	ADD	[ALLOC],AX	;Total up allocated clusters
	MOV	SI,AX
	MOV	AX,[BP+2]
	MOV	DX,[BP+4]	;AX:DX now have file length
	PUSH	CX
	MOV	CX,[CLUSSIZ]
	DEC	CX
	ADD	AX,CX
	ADC	DX,0
	INC	CX
SCALE:
	SHR	CX
	JC	SCALED
	SHR	DX
	RCR	AX
	JP	SCALE
SCALED:
	DIV	AX,[SECSIZ]
	OR	DX,DX
	JZ	HAVSIZ
	INC	AX
HAVSIZ:
	CMP	AX,SI		;See if file size corresponds with allocation
	JZ	SIZSET
	XOR	DI,DI
	MOV	CX,[CLUSSIZ]
	CALL	UNSCALE
	MOV	[BP+6],SI
	MOV	[BP+8],DI
	MOV	DX,BP
	SUB	DX,34
	MOV	AH,OPEN
	INT	21H
	OR	AL,AL
	JZ	DISKOK2
	JMP	BADDSK
DISKOK2:
	MOV	AX,[SECSIZ]
	MOV	[BP-27+14],AX	;Make record size=sector size
	MOV	CX,0
	MOV	AH,BLKWRT
	INT	21H
	MOV	AH,CLOSE	;Write back corrected directory entry
	INT	21H
	PUSH	DS
	CALL	DRVXCG		;Change the drives and get the map
	POP	DS
	MOV	DX,BADSIZ
	MOV	AH,PRINTBUF
	INT	21H
	POP	AX
	PUSH	AX
	CALL	PRINTNAM
	MOV	DX,CRLF
	MOV	AH,PRINTBUF
	INT	21H
SIZSET:
	POP	CX
SIZSET1:
	ADD	BP,44		;Scan next file
	INC	CX
	CMP	CX,[FILECNT]
	JA	COMPMAP
	JMP	EACHFIL
; Now compare the allocation map we have made with the FAT. Any
; clusters not allocated in the map will be released.
COMPMAP:
	XOR	AX,AX		;Keep count of clusters released
	MOV	BP,MAP
	MOV	SI,2		;First usable cluster number
	MOV	CX,[DSKSIZ]
RELCLUS:
	TEST	[BP],-1		;Allocated in our map?
	JNZ	NXTCLUS		;If so, skip to next
	CALL	UNPACK
	JZ	NXTCLUS		;If not allocated, skip to next
	XOR	DX,DX
	CALL	PACK		;Change to "Free" status
	INC	AX		;Count clusters released
NXTCLUS:
	INC	BP
	INC	BP
	INC	SI
	LOOP	RELCLUS
	OR	AX,AX		;Any clusters released?
	JZ	REPORT		;If not, do final report
	MOV	BX,FREED
	CALL	DISPCLUS
REPORT:
; Make status report. Include no. of files, total disk space,
; free space on disk, total memory, and free memory.
	SEG	CS
	MOV	DL,[CURDRV]
	MOV	AH,SETDRV
	INT	21H
	MOV	SI,[FILECNT]
	SUB	SI,[DELCNT]
	XOR	DI,DI
	MOV	BX,NUMFIL
	CALL	DISP32BITS
	MOV	AX,[DSKSIZ]
	MOV	BX,DSKSPC
	CALL	DISPCLUS
	MOV	AX,[DSKSIZ]
	SUB	AX,[ALLOC]
	MOV	BX,FRESPC
	CALL	DISPCLUS
	MOV	AX,[2]
	MOV	DX,16
	MUL	AX,DX
	MOV	SI,AX
	MOV	DI,DX
	MOV	BX,TOTMEM
	CALL	DISP32BITS
	MOV	AX,[2]
	MOV	DX,CS
	SUB	AX,DX
	MOV	DX,16
	MUL	AX,DX
	MOV	SI,AX
	MOV	DI,DX
	MOV	BX,FREMEM
	CALL	DISP32BITS
	CALL	WRTFRC		;Force all writes and handle write
				;protect violation
	SEG	CS
	MOV	B,DL,[CURDRV]	;Get default
	MOV	AH,SETDRV	;And make it current again
	INT	21H
	INT	20H		;All done

WRTFRC:	;********************************************************
	;	This code forces all writes by performing a disk
	;	reset (function 13). When the attempt to write
	;	the allocation table fails in the case of a write-
	;	protected diskette, this logic determines if the
	;	allocation table had changed and if no changes were
	;	made a normal termination will be forced
	;*********************************************************
	MOV	AX,DS
	PUSH	DS		;Must first intercept INT 24H
	MOV	ES,AX
	XOR	AX,AX
	MOV	DS,AX
	MOV	SI,90H
	MOV	DI,INT24	;will move vector to local address
	MOV	CX,2
	CLD			;So move will increment
	REP
	MOVW			;Vector now locally stored
	MOV	AL,24H		;
	MOV	AH,37
	MOV	DX,WRTPRT	;
	POP	DS		;Get local segment
	INT	21H		;Interrupt vector now set
	MOV	AH,13
	INT	21H
	PUSH	ES		;Will now reset INT 24H vector
	XOR	AX,AX
	MOV	ES,AX
	CLD
	MOV	DI,90H
	MOV	SI,INT24
	MOV	CX,2
	REP
	MOVW
	POP	ES
	RET

WRTPRT:	;*********************************************************
	;	This logic is designed to handle the case where
	;	CHKDSK found no problems and upon rewriting the
	;	allocation table (by the DOS) the disk was write-
	;	protected and an error thus occured. With no problems
	;	this code will cause normal termination, otherwise
	;	normal error handling will occur.
	;*********************************************************
	EI		;Run with interrupts live
	AND	DI,0FFH		;See if write-protect
	JNZ	WRT100		;Do normal error handling
	CMP	AH,3		;File allocation write?
	JNZ	WRT100		;If not do normal handling
	SEG	CS
	CMP	[WRKDRV],AL	;Correct drive?
	JNZ	WRT100		;
	SEG	CS
	CMP	B,[CHGCLS],1	;Legitimate change?
	JZ	WRT100		;If so do normal handling
	XOR	AL,AL		;Ignore the error
	IRET
WRT100:	SEG	CS
	MOV	SI,AX		;Save AX
	PUSH	DX
	MOV	DL,[CURDRV]	;Fetch current drive
	MOV	AH,SETDRV
	INT	33		;Drive now ok
	POP	DX		;Restore DX
	MOV	AX,SI		;Restore AX
	SEG	CS
	JMP	L,[INT24]	;Do normal recovery


DRVXCG:
	;**********************************************
	;	WILL CHANGE DEFAULT TO WRKDRV READ THE FAT
	;	AND CHANGE THE DEFAULT BACK TO CURDRV
	;**********************************************
	SEG	CS
	MOV	DL,[WRKDRV]	;Will change the default to this
	MOV	AH,SETDRV
	INT	33		;Default now "WRKDRV"
	MOV	AH,GETMAP
	INT	33
	PUSH	DX
	PUSH	AX
	SEG	CS
	MOV	DL,[CURDRV]	;Get current drive
	MOV	AH,SETDRV
	INT	33
	POP	AX
	POP	DX
	RET


UNPACK:
	MOV	DI,SI
	SHR	DI
	ADD	DI,SI
	SEG	ES
	MOV	DI,[DI+BX]
	TEST	SI,1
	JZ	HAVCLUS
	SHR	DI
	SHR	DI
	SHR	DI
	SHR	DI
HAVCLUS:
	AND	DI,0FFFH
	RET

PACK:
;*************************************************************
;	ES:BX	POINTER TO THE BASE OF THE ALLOCATION TABLE
;	SI	CLUSTER NUMBER TO BE PACKED
;	DX	POINTER TO BE PLACED IN CLUSTER (SI)
;*************************************************************
	MOV	B,[CHGCLS],1	;INDICATE CLUSTER CHANGED
	PUSH	SI
	MOV	DI,SI
	SHR	SI
	ADD	SI,BX
	ADD	SI,DI
	SHR	DI
	SEG	ES
	MOV	DI,[SI]
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
	SEG	ES
	MOV	[SI],DI
	POP	SI
	RET

UNSCALE:
	SHR	CX
	JC	RET
	SHL	SI
	RCL	DI
	JP	UNSCALE

DISPCLUS:
	MUL	AX,[SECSIZ]
	MOV	CX,[CLUSSIZ]
	MOV	SI,AX
	MOV	DI,DX
	CALL	UNSCALE
DISP32BITS:
	PUSH	BX
	XOR	AX,AX
	MOV	BX,AX
	MOV	BP,AX
	MOV	CX,32
CONVLP:
	SHL	SI
	RCL	DI
	XCHG	AX,BP
	CALL	CONVWRD
	XCHG	AX,BP
	XCHG	AX,BX
	CALL	CONVWRD
	XCHG	AX,BX
	ADC	AL,0
	LOOP	CONVLP
; Conversion complete. Print 10-digit number with 2 leading blanks.
	MOV	CX,1B10H
	CALL	OUTWORD
	MOV	AX,BX
	CALL	OUTWORD
	MOV	AX,BP
	CALL	OUTWORD
	POP	DX
	MOV	AH,PRINTBUF
	INT	21H
	RET

OUTWORD:
	PUSH	AX
	MOV	DL,AH
	CALL	OUTBYTE
	POP	DX
OUTBYTE:
	MOV	DH,DL
	SHR	DL
	SHR	DL
	SHR	DL
	SHR	DL
	CALL	DIGIT
	MOV	DL,DH
DIGIT:
	AND	DL,0FH
	JZ	BLANKZER
	MOV	CL,0
BLANKZER:
	DEC	CH
	AND	CL,CH
	OR	DL,30H
	SUB	DL,CL
	MOV	AH,OUTCH
	INT	21H
	RET

CONVWRD:
	ADC	AL,AL
	DAA
	XCHG	AL,AH
	ADC	AL,AL
	DAA
	XCHG	AL,AH
	RET

PRINTNAM:
	PUSH	CX
	DEC	AX
	MOV	CX,44
	MUL	AX,CX
	MOV	SI,AX
	ADD	SI,[NAMTAB]
	ADD	SI,8
	MOV	CX,8
	MOV	AH,OUTCH
	CALL	PRINTCNT
	MOV	DL," "
	INT	21H
	MOV	CL,3
	CALL	PRINTCNT
	POP	CX
	RET

PRINTCNT:
	LODB
	MOV	DL,AL
	INT	21H
	LOOP	PRINTCNT
	RET

ALLFILE:DB	-1,0,0,0,0,0,6	;Extended FCB
ALLDRV:	DB	0,"???????????"
	DS	25

FILE2:	DB	"  and  $"
BADDRV:	DB	"Invalid drive specification$"
INVPRM:	DB	"Invalid parameter$"
BADCLUS:DB	"Allocation error for file $"
BADDIR:	DB	"Directory error-file :    $"
LINKED:	DB	"Files cross-linked: "
	DB	13,10
	DB	"     $"
BADSIZ:	DB	"File size error for file  $"
DIRBAD:	DB	"Diskette not initialized $"
FREED:	DB	" bytes disk space freed",13,10,13,10,"$"
NUMFIL:	DB	" disk files",13,10,"$"
DSKSPC:	DB	" bytes total disk space",13,10,"$"
FRESPC:	DB	" bytes remain available",13,10,13,10,"$"
TOTMEM:	DB	" bytes total memory",13,10,"$"
FREMEM:	DB	" bytes free"
CRLF:	DB	13,10,"$"

DSKSIZ:	DS	2
SECSIZ:	DS	2
CLUSSIZ:DS	2
CHGCLS:	DB	0		;IF RESET TO 1-ALLOCATION TABLE UPDATED
WRKDRV:	DB	0
INT24:	DS	4
FILECNT:DS	2
NAMTAB:	DS	2
ALLOC:	DS	2
MAXCLUS:DS	2
DELCNT:	DS	2
CURDRV:	DS	1
	DS	100H
STACK:

MAP:
