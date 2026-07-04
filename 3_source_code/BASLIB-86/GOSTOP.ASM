        TITLE   GOSTOP - Initialization, STOP, END, and error processing

.sall
        INCLUDE SYSTEM.INC
        INCLUDE ADDR.INC


ERRMSG  MACRO   Errnum,Errtxt
        .xcref
__Pchr  =       0
        DB      Errnum
        IRPC    chr,<Errtxt>
IF      __Pchr
        DB      &__Pchr
        ENDIF
__Pchr  =       "&chr"
        ENDM
        DB      __Pchr+128
        .cref
        ENDM

TYPMSG  MACRO   Txt
__Pchr  =       0
        CALL    $TYPTX          ;;Print Following string to CON
        IRPC    chr,<Txt>
IF      __Pchr
        DB      &__Pchr
        ENDIF
__Pchr  =       "&chr"
        ENDM
        DB      __Pchr+128
        ENDM

DATA    SEGMENT WORD PUBLIC 'DATA'

        PUBLIC  $SEG,$USR

        PUBLIC  $DAC,$AC,$FAC
        PUBLIC  $$ERRV,$$SPSV,$$STKP,$MAINBASE

$SEG    DW      ?
$USR    DW      10 DUP (?)

$DAC    DB      4 DUP(?)
$AC     DB      3 DUP(?)
$FAC    DB      ?

$$ERRV  DW      ?               ;Special error handler address
$$SPSV  DW      ?               ;Save stack here
$$STKP  DW      ?

CBASE   LABEL   DWORD
$MAINBASE DW    ?               ;Starting offset of main
MAINCS  DW      ?               ;CS of main program

DATA    ENDS

DATA    SEGMENT WORD PUBLIC 'DATA'

;This data area is zeroed on initialization and each CLEAR

        PUBLIC  $FREPT,$FILPT,$PTRFIL,$$AOER,$$OEIP,$$RSTO
        PUBLIC  $ERRNUM,$ERRLIN,$ERRADR,$$GCNT
        PUBLIC  $TRACE_SW

STARTZERO       LABEL   BYTE

$ERRADR DW      ?               ;Error address
$ERRNUM DW      ?               ;Error number
$ERRLIN DW      ?               ;Error line

$FREPT  DW      ?               ;File block free list
$FILPT  DW      ?               ;Active file list
$PTRFIL DW      ?               ;Current file pointer
$$AOER  DW      ?               ;ON ERROR address
$$GCNT  DW      ?               ;GOSUB count
$$RSTO  DB      ?               ;Has RESTORE occurred yet?
$$OEIP  DB      ?               ;ON ERROR in progress
$TRACE_SW DB    ?               ;Trace switch

STOPZERO        LABEL   BYTE

DATA    ENDS


BC_CN   SEGMENT WORD PUBLIC 'DATA'
END_CN  LABEL   BYTE
BC_CN   ENDS

BC_DS   SEGMENT BYTE PUBLIC 'DATA'
END_DS  LABEL   BYTE
BC_DS   ENDS

DC      GROUP   BC_CN,BC_DS,DATA


BC_ICN  SEGMENT WORD PUBLIC 'INIT'
END_ICN LABEL   BYTE
BC_ICN  ENDS

BC_IDS  SEGMENT BYTE PUBLIC 'INIT'
END_IDS LABEL   BYTE
BC_IDS  ENDS


CODE    SEGMENT BYTE PUBLIC 'CODE'

ERRTAB  LABEL   BYTE
        ERRMSG  2,<Syntax Error in DATA>
        ERRMSG  3,<RETURN without GOSUB>
        ERRMSG  4,<Out of Data>
        ERRMSG  5,<Illegal Function Call>
        ERRMSG  6,<Overflow>
        ERRMSG  7,<Out of Memory>
        ERRMSG  9,<Subscript Out of Range>
        ERRMSG  11,<Division by Zero>
        ERRMSG  14,<Out of String Space>
        ERRMSG  16,<String Formula Too Complex>
        ERRMSG  19,<No RESUME>
        ERRMSG  20,<RESUME without Error>
IF _IBM_
        ERRMSG  24,<Device Timeout>
        ERRMSG  25,<Device Fault>
        ERRMSG  27,<Out of Paper>
ENDIF
        ERRMSG  50,<Field Overflow>
        ERRMSG  51,<Internal Error>
        ERRMSG  52,<Bad File Number>
        ERRMSG  53,<File Not Found>
        ERRMSG  54,<Bad File Mode>
        ERRMSG  55,<File Already Open>
        ERRMSG  57,<Device I/O Error>
        ERRMSG  58,<File Already Exists>
        ERRMSG  61,<Disk Full>
        ERRMSG  62,<Input Past End>
        ERRMSG  63,<Bad Record Number>
        ERRMSG  64,<Bad File Name>
        ERRMSG  67,<Too Many Files>
        ERRMSG  68,<Device Unavailable>
IF _MSDOS_
  IF _IBM_
        ERRMSG  69,<Communication Buffer overflow>
  ENDIF
        ERRMSG  70,<Disk Write Protect>
        ERRMSG  71,<Disk not Ready>
        ERRMSG  72,<Disk Media Error>
ENDIF
        ERRMSG  255,<Unprintable Error>

CODE    ENDS


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $DS0,$DS1,$USRA
        PUBLIC  $DIV0_INT,$OVRF_INT

        PUBLIC  $CLR,$CLX
        PUBLIC  $FOE,$RTE,$CONT,$ERRPR,$INI0,$431,$531,$RET,$NUL
        PUBLIC  $STP,$BREAK,$END,$$PLNM,$GETAD,$ENP
        PUBLIC  $$FSFA,$FSERR

        PUBLIC  $ERR_RG, $ERR_TM, $ERR_BS, $ERR_RE, $ERR_OS, $ERR_ST
        PUBLIC  $ERR_OV, $ERR_FC, $ERR_OD, $ERR_OM, $ERR_SN
        PUBLIC  $ERC_RG, $ERC_TM, $ERC_BS, $ERC_RE, $ERC_OS, $ERC_ST
        PUBLIC  $ERC_OV, $ERC_FC, $ERC_OD, $ERC_OM, $ERC_SN

        PUBLIC  $OVFL, $DIV0    ;****************  Temporary entry points

        PUBLIC  $ERR_FOV, $ERR_INT, $ERR_IFN, $ERR_FNF, $ERR_BFM
        PUBLIC  $ERR_FAO, $ERR_IOE, $ERR_FAE, $ERR_DFL, $ERR_RPE
        PUBLIC  $ERR_BRN, $ERR_BFN, $ERR_TMF
        PUBLIC  $ERC_FOV, $ERC_INT, $ERC_IFN, $ERC_FNF, $ERC_BFM
        PUBLIC  $ERC_FAO, $ERC_IOE, $ERC_FAE, $ERC_DFL, $ERC_RPE
        PUBLIC  $ERC_BRN, $ERC_BFN, $ERC_TMF
        PUBLIC  $ERC_DNA, $ERR_DNA

IF _MSDOS_
IF _IBM_
        PUBLIC  $ERC_DTO, $ERC_DVF, $ERC_OTP
        PUBLIC  $ERC_CBO
        PUBLIC  $ERR_DTO, $ERR_DVF, $ERR_OTP
        PUBLIC  $ERR_CBO
ENDIF
        PUBLIC  $ERR_FWP, $ERR_DNR, $ERR_DME
        PUBLIC  $ERC_FWP, $ERC_DNR, $ERC_DME
ENDIF

        EXTRN   $ABEND:NEAR
        EXTRN   $$DTS:NEAR, $OSEXT:NEAR, $$WCHT:NEAR, $$STSU:NEAR
        EXTRN   $TYPTX:NEAR, $TYTX:NEAR, $$TCR:NEAR, $$THB:NEAR
        EXTRN   $IOINI:NEAR, $TYPUI:NEAR
        EXTRN   $INIDEV:NEAR, $CLSDEV:NEAR, $CLOSF:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC

        INCLUDE LIBMAC.LIB

        PAGE

;***  $INI0 - Initialize run-time system
;

$INI0   PROC    FAR
        POP     AX
        POP     BX              ;Recover segment of main program
        MOV     [$$STKP],SP
        PUSH    BX
        PUSH    AX
        MOV     [MAINCS],BX
        SUB     AX,14+5         ;Size of table and init call
        MOV     [$MAINBASE],AX
        MOV     [$$ERRV],OFFSET $CONT

;       Clear user data variables

        CALL    $GETAD
        DB      O_RAM
        XCHG    AX,DI
        CALL    $GETAD
        DB      O_RAL
        XCHG    AX,CX
        SUB     CX,DI
        XOR     AX,AX
        REP     STOSB

        MOV     DI,OFFSET DC:STARTZERO
        MOV     CX,STOPZERO-STARTZERO
        REP     STOSB           ;Zero library variables

        DEC     AX              ;(AX) = -1
        MOV     CX,10
        MOV     DI,OFFSET DC:$USR
        REP     STOSW           ;Initialize $USR address vectors

;       Move constants and data statements from INIT to DATA

        PUSH    DS
        PUSH    ES
        MOV     AX,BC_ICN       ;Get base segment addresses
        MOV     DS,AX
        MOV     AX,BC_CN
        MOV     ES,AX
        MOV     CX,(OFFSET END_ICN)
        MOV     BX,(OFFSET END_IDS)
        ADD     CX,BX
        XOR     SI,SI
        XOR     DI,DI
        REP     MOVSB
        POP     ES
        POP     DS

        CALL    $$STSU          ;Set up string space
        CALL    $IOINI          ;I/O init
        CALL    $INIDEV         ;Initialize devices

;**     $DS0 - Set BASIC Segment Address to Data Segment

$DS0:   MOV     $SEG,DS         ;Save initial data seg

$CLR:                           ;**************  For now  **************
$CLX:                           ;**************           **************
$NUL:                           ;**************  For now  **************
$RET:
$431:
$531:   RET


;**     $DS1 - Set BASIC Segment Address
;
;       ENTRY   (BX) = new segment address

$DS1:   MOV     $SEG,BX         ;Save new $SEG value
        RET


;**     $USRA - Call user defined routine
;
;       ENTRY   (BX) = offset address of user routine

$USRA:  PUSH    [$SEG]          ;Save $SEG value
        PUSH    BX              ;Save offset address
        RET                     ;Call by long RET

$INI0   ENDP


$GETAD:
        POP     SI
        LODS    BYTE PTR CS:[SI]  ;Get byte indicating which address
        CBW
        PUSH    SI
        PUSH    DS
        LDS     SI,[CBASE]
        ADD     SI,AX
        LODSW
        POP     DS
        RET


;**     8086 Error interrupt vector

$DIV0_INT:
        POP     AX
        POP     BX
        POPF                            ;Restore interrupt status
        PUSH    BX
        PUSH    AX
        JMP     $ERR_DV0                ;Divide by 0 error

$OVRF_INT:
        POP     AX
        POP     BX
        POPF                            ;Restore interrupt status
        PUSH    BX
        PUSH    AX
        JMP     $ERR_OV                 ;Overflow error


;***  Error entry points

; This group assumes a clean stack value has been saved in $$SPSV. This saved
; value is restored.


ERRMAC  MACRO   func,noskip
        MOV     BL,func
ifb     <noskip>
        SKIP    2
endif
        ENDM



$ERC_SN:        ERRMAC  2
$ERC_RG:        ERRMAC  3
$ERC_OD:        ERRMAC  4
$ERC_FC:        ERRMAC  5
$OVFL:                                  ;;Temporary entry point
$ERC_OV:        ERRMAC  6
$ERC_OM:        ERRMAC  7
$ERC_BS:        ERRMAC  9
$DIV0:          ERRMAC  11              ;;Temporary entry point
$ERC_TM:        ERRMAC  13
$ERC_OS:        ERRMAC  14
$ERC_ST:        ERRMAC  16
$ERC_RE:        ERRMAC  20
IF _IBM_
  $ERC_DTO:     ERRMAC  24
  $ERC_DVF:     ERRMAC  25
  $ERC_OTP:     ERRMAC  27
ENDIF

$ERC_FOV:       ERRMAC  50
$ERC_INT:       ERRMAC  51
$ERC_IFN:       ERRMAC  52
$ERC_FNF:       ERRMAC  53
$ERC_BFM:       ERRMAC  54
$ERC_FAO:       ERRMAC  55
$ERC_IOE:       ERRMAC  57
$ERC_FAE:       ERRMAC  58
$ERC_DFL:       ERRMAC  61
$ERC_RPE:       ERRMAC  62
$ERC_BRN:       ERRMAC  63
$ERC_BFN:       ERRMAC  64
$ERC_TMF:       ERRMAC  67
IF _MSDOS_
  IF _IBM_
    $ERC_CBO:   ERRMAC  69
  ENDIF
  $ERC_FWP:     ERRMAC  70
  $ERC_DNR:     ERRMAC  71
  $ERC_DME:     ERRMAC  72
ENDIF
$ERC_DNA:       ERRMAC  68,noskip       ;last in chain

CLNSTK:
         MOV    SP,[$$SPSV]     ;Restore a clean stack
         SKIP   2

; This group has all the same entry points as above, but it assumes stack
; is at proper level upon entry

$ERR_SN:        ERRMAC  2
$ERR_RG:        ERRMAC  3
$ERR_OD:        ERRMAC  4
$ERR_FC:        ERRMAC  5
$ERR_OV:        ERRMAC  6
$ERR_OM:        ERRMAC  7
$ERR_BS:        ERRMAC  9
$ERR_DV0:       ERRMAC  11
$ERR_TM:        ERRMAC  13
$ERR_OS:        ERRMAC  14
$ERR_ST:        ERRMAC  16
$ERR_RE:        ERRMAC  20
IF _IBM_
  $ERR_DTO:     ERRMAC  24
  $ERR_DVF:     ERRMAC  25
  $ERR_OTP:     ERRMAC  27
ENDIF

$ERR_FOV:       ERRMAC  50
$ERR_INT:       ERRMAC  51
$ERR_IFN:       ERRMAC  52
$ERR_FNF:       ERRMAC  53
$ERR_BFM:       ERRMAC  54
$ERR_FAO:       ERRMAC  55
$ERR_IOE:       ERRMAC  57
$ERR_FAE:       ERRMAC  58
$ERR_DFL:       ERRMAC  61
$ERR_RPE:       ERRMAC  62
$ERR_BRN:       ERRMAC  63
$ERR_BFN:       ERRMAC  64
$ERR_TMF:       ERRMAC  67
IF _MSDOS_
  IF _IBM_
    $ERR_CBO:   ERRMAC  69
  ENDIF
  $ERR_FWP:     ERRMAC  70
  $ERR_DNR:     ERRMAC  71
  $ERR_DME:     ERRMAC  72
ENDIF
$ERR_DNA:       ERRMAC  68,noskip       ;last in chain

        PAGE

;***  $FOE/$RTE - Process Run-Time Error
;
; Inputs:
;       BL = Error code
;       Top of stack has address in compiled code
; Function:
;       If special error handling is needed, a jump to the address in $$ERRV
;       will be made; otherwise, if ON ERROR GOTO has been specified but is not
;       currently processing an error, it will be activated; otherwise, bitch
;       and exit.
; Outputs:
;       None. Does not return, but will jump to [$$ERRV], ON ERROR, or exit.
; Registers:
;       All registers trashed.

Error_trap      PROC    FAR

$FOE:
$RTE:
        CALL    $$DTS           ;Delete all temp strings
;Execute special error handling if needed. If it is not needed, $$ERRV must
;contain $CONT so that normal processing will just continue.
        JMP     [$$ERRV]
$CONT:
        CMP     [$$OEIP],0      ;ON ERROR in process?
        JNZ     RUNERR          ;No second chances--report error and exit
        CMP     [$$AOER],0      ;ON ERROR set?
        JZ      RUNERR          ;If not, quit

; Activate ON ERROR GOTO

        XOR     BH,BH           ;Clear high byte
        MOV     [$ERRNUM],BX    ;Save error number
        POP     AX              ;Get error offset
        MOV     [$ERRADR],AX    ;Save error address
        CALL    $$FSFA          ;Get statement number of error
        MOV     [$ERRLIN],AX    ;Save statement number of error
        MOV     [$$OEIP],1      ;Mark ON ERROR in progress
        POP     SI              ;Get error segment
        MOV     SP,[$$STKP]     ;Reset stack to proper level
        PUSH    SI              ;Set error segment
        PUSH    [$$AOER]        ;Set error vector as offset
        RET                     ;Transfer to error routine
RUNERR:
        CALL    $ERRPR          ;Print error
        JMP     SHORT STOP1

Error_trap      ENDP


;***  $STP and $END
;
; Print message (STOP only), close files, and exit

$STP:   CALL    $$TCR
        TYPMSG  <STOP>
STOP1:
        CALL    $$PLNM          ;Print line number of stop
$BREAK:
        STC
        JMP     SHORT end1

;**     $ENP - End of program

$ENP:
        MOV     BL,19           ;Assume No RESUME error
        CMP     [$$OEIP],0      ;Is error in progress?
        JNZ     RUNERR          ;Yes - give error - No RESUME

$END:
        CLC

end1:   PUSHF
        CALL    $$TCR           ;Print CR/LF
        CALL    $CLOSF          ;Close all files
        CALL    $CLSDEV         ;Close all devices
        POPF
        JMP     $OSEXT          ;Exit back to O.S.


;***  $$PLNM - Print line number message
;
; Inputs:
;       Top of stack has return address, then IP and CS to print.
; Function:
;       Print address in hex, after " at address ".
; Outputs:
;       None.
; Registers:
;       All registers destroyed.

$$PLNM:
        CALL    $GETAD          ;Get address of statement address/number table
        DB      O_STA
        OR      AX,AX
        JZ      plnm5           ;No table

        TYPMSG  < in line >
        POP     BP              ;Return address
        POP     AX              ;IP
        POP     DX              ;CS
        PUSH    BP
        CALL    $$FSFA          ;Find line number for address (AX)
        CALL    $TYPUI          ;Print it to console
        JMP     $$TCR           ;Output CR/LF

plnm5:  TYPMSG  < at address >
        POP     BP              ;Return address
        POP     DI              ;IP
        POP     DX              ;CS
        PUSH    BP              ;Return address back on stack
        CALL    HEXWORD
        MOV     AL,":"          ;Separate segment and offset
        CALL    $$WCHT
        MOV     DX,DI
        CALL    HEXWORD
        JMP     $$TCR

HEXWORD:
        MOV     AL,DH
        CALL    $$THB           ;Print hex byte
        MOV     AL,DL
        JMP     $$THB

$ERRPR:
;Print error message given standard error code in BL
        CALL    $$TCR           ;Print CR/LF
        PUSH    ES
        PUSH    CS
        POP     ES              ;Set ES to code segment
        MOV     DI, OFFSET ERRTAB
        MOV     AL,BL
        MOV     AH,80H
CHKERR:
        CMP     BYTE PTR ES:[DI],-1     ;See if end of list
        JZ      PRNERR1
        SCASB                   ;Compare error code byte
        JZ      PRNERR
        XCHG    AL,AH           ;Scan for code >=80H
EATMES:
        SCASB
        JAE     EATMES
        XCHG    AL,AH
        JMP     CHKERR

PRNERR1:
        INC     DI
PRNERR:
        POP     ES
        MOV     SI,DI
        JMP     $TYTX


;***    $$FSFA - Find statement number from address
;
; Inputs:
;       AX = return address into user program
; Outputs:
;       AX = Statement number
;       BX = Address of start of statement
; Registers:
;       All destroyed

$$FSFA:                         ;Find statement number from address in (AX)
        XCHG    AX,CX           ;(CX) = original return address
        CALL    $GETAD          ;Get statement number address table
        DB      O_STA
        XCHG    AX,SI           ;(SI) = statement address table
        MOV     DS,[MAINCS]     ;(DS) = user program segment
        XOR     BX,BX           ;(BX) = 0 (current closest address)

fsfalp: LODSW                   ;(AX) = next address to check
        OR      AX,AX           ;Check if end of table
        JZ      fsfend          ;  Yes

        CMP     AX,CX           ;Are we less than original address
        JAE     fsfnxt          ;  No - skip this one
        CMP     AX,BX           ;Are we above the current closest address
        JB      fsfnxt          ;  No - skip this one

        XCHG    AX,BX           ;(BX) = new closest address
        LODSW                   ;Get statement number
        XCHG    AX,DX           ;Save it in (DX)
        JMP     fsfalp          ;Keep looping

fsfnxt: INC     SI              ;Skip statement number
        INC     SI
        JMP     fsfalp          ;Keep looping

fsfend: PUSH    ES              ;Restore DS
        POP     DS
        OR      BX,BX           ;Test if line number found
        JE      $FSERR          ;  No
        XCHG    Ax,DX           ;(AX) = statement number
        RET

$FSERR:                         ;Have an internal error
        TYPMSG  <Internal Error - No Line Number>
        CALL    $$TCR           ;Output CR/LF
        JMP     $ABEND          ;Just die


CODE    ENDS

        END
