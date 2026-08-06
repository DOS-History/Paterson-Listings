        TITLE   PRTU - PRINT USING Driver

DATA    SEGMENT WORD PUBLIC 'DATA'

        PUBLIC  $PUFLAG, $DIGCNT

        EXTRN   $$SPSV:WORD,VALTYP:BYTE,$$PUFL:BYTE,$$PUEN:WORD

PUDS    DW      ?,?             ;Print Using string descriptor
PUSC    DW      ?               ;PRINT USING SCAN COUNT
$DIGCNT DW      ?               ;Count of digits before and after d.p.
PUVS    DB      ?               ;PRINT USING VALUE SEEN FLAG
$PUFLAG LABEL   BYTE
FLAG    DB      ?               ;Flag byte
;Bits of the flag byte are used as follows:
;       0       0=Fixed format, 1=Scientific notation
;       1       0=Print number, 1=Print string
;       2       1=Place sign after number
;       3       1=Print "+" for positive numbers
;       4       1=Print "$" in front of number
;       5       0=Pad with leading spaces; 1=Pad with leading "*"
;       6       1=Put commas every three digits
;       7       0=Free format output, 1=Print using output

DATA    ENDS


DC      GROUP   DATA


CODE    SEGMENT BYTE PUBLIC 'CODE'

        PUBLIC  $PRU

        EXTRN   $$WCH:NEAR,$ERC_FC:NEAR,$ERC_TM:NEAR
        EXTRN   $$DITS:NEAR,$SAS:FAR,$SAVREG:NEAR
        EXTRN   $PUFOUT:NEAR,$TYPCNT:NEAR,$OUTCNT:NEAR

        ASSUME  CS:CODE, DS:DC, ES:DC

CURNCY=         "$"             ;Currency symbol
CSTRNG=         "\"             ;String USING symbol

SD_LEN=         0               ;STRING DESCRIPTOR LENGTH OFFSET
SD_ADR=         2               ;STRING DESCRIPTOR ADDRESS OFFSET


;       ENTRY   (HL) = Pointer to using SDESC


$PRU    PROC    FAR
        MOV     $$SPSV,SP       ;Save SP in case of error in SAS
        PUSH    DX
        MOV     DX,OFFSET DC:PUDS       ;Point to the destination descriptor
        CALL    $SAS            ;** 5.2 **  Copy "using" string
        POP     DX
        MOV     $$PUFL,1        ;SET PRINT USING FLAG
        MOV     $$PUEN,OFFSET $$PREN    ;SET PRINT ITEM ENTRY ADDRESS
        XOR     AL,AL           ;ZERO VALUE SEEN FLAG
        MOV     PUVS,AL
        MOV     FLAG,AL         ;SET TO NO TYPE PENDING
        RET
$PRU    ENDP


;       Entry point for printing numbers and strings

$$PREN:
        MOV     AL,FLAG         ;TEST IF TYPE PENDING
        OR      AL,AL
        JNZ     PREN01          ;YES - PROCESS AS NORMAL
        PUSH    BX              ;Save possible string descriptor
        CALL    PUINIT          ;ZERO - SCAN STARTING AT BEGINNING
        POP     BX
        MOV     AL,FLAG
PREN01:
        MOV     PUVS,AL         ;Must have found a value
        MOV     CX,$DIGCNT      ;LOAD [CH,CL]
        TEST    AL,2            ;Does the field define a string?
        JNZ     PUSTR           ;PRINT STRING
        CMP     VALTYP,3        ;IS IT A STRING?
        JZ      TMER            ;ERROR - TYPE MISMATCH
        CALL    $PUFOUT         ;FORMAT NUMBER
        XCHG    AX,CX           ;Put count in CX
        CALL    $OUTCNT
        JMP     SHORT PUSCAN

PUSTR:
        CMP     VALTYP,3        ;Type better be string
        JNZ     TMER            ;ERROR - TYPE MISMATCH
        MOV     DX,CX           ;Put length of print field into DX
        MOV     CX,[BX]         ;Get length of string
        SUB     DX,CX           ;DX = Padding count
;Note that if we have a variable length string field, DX will be -1.
;The result of the above subtraction will never carry (so we will take the
;JAE below), but the number left in DX will always be negative. Thus when
;we get to the padding check, no blanks will be added.
        JAE     PRSTR           ;If field is big enough, proceed
        ADD     CX,DX           ;CX = CX + (DX-CX) = DX
PRSTR:
        CALL    $TYPCNT         ;Output CX bytes of string
        CALL    $$DITS          ;DELETE IF TEMPORARY STRING
        MOV     CX,DX           ;Padding count
        OR      CX,CX
        JLE     PUSCAN          ;Any padding needed?
        MOV     AL," "          ;PAD OUT REMAINDER OF FIELD
PUPAD:
        CALL    $$WCH           ;PRINT SPACE
        LOOP    PUPAD           ;  CONTINUE PADDING
        JMP     SHORT PUSCAN

PUINIT:
        MOV     AX,PUDS+SD_LEN  ;Get length of PRINT USING string
        MOV     PUSC,AX         ;SAVE SCAN COUNT REMAINING
        OR      AX,AX           ;Null string?
        JZ      FARG            ;If so, illegal function call
PUSCAN:
        MOV     FLAG,0
        MOV     SI,PUDS+SD_ADR  ;Start of string (could change if G.C.!)
        MOV     AX,PUDS+SD_LEN
        MOV     CX,PUSC         ;Get scan count
        SUB     AX,CX           ;Offset into string
        ADD     SI,AX
        JCXZ    RET             ;At end of string?
        JMP     SHORT PRCCHR    ;If not, scan for next value (or EOS)

FARG:   JMP     $ERC_FC         ;Illegal function call

TMER:   JMP     $ERC_TM         ;Type mismatch

REUSIN: CALL    PLSPRT          ;PRINT A "+" IF NECESSARY
        CALL    $$WCH
REUSN1:
        MOV     PUSC,CX         ;Save scan count ( = 0 )
        MOV     FLAG,CL         ;SET NO TYPE PENDING
        CMP     CL,PUVS         ;Any values seen in string?
        JZ      FARG            ;If not, we'll never get anywhere
RET:    RET

; HERE TO HANDLE A LITERAL CHARACTER IN THE USING STRING PRECEDED
; BY "_"
;
LITCHR: CALL    PLSPRT          ;PRINT PREVIOUS "+" IF ANY
        LODSB                   ;FETCH LITERAL CHARACTER
        CALL    $$WCH           ;OUTPUT LITERAL CHARACTER
        LOOP    PRCCHR          ;DECREMENT COUNT FOR ACTUAL CHARACTER
        JMP     SHORT REUSN1

; HERE TO HANDLE VARIABLE LENGTH STRING FIELD SPECIFIED WITH "&"
;
VARSTR:
        MOV     BX,-1           ;SET LENGTH TO MAXIMUM POSSIBLE
ISSTRF:
        DEC     CX              ;DECREMENT THE "USING" STRING CHARACTER COUNT
        CALL    PLSPRT          ;PRINT A "+" IF ONE CAME BEFORE THE FIELD
        MOV     PUSC,CX         ;Save scan count
        MOV     $DIGCNT,BX      ;Save field width
        MOV     FLAG,2          ;Flag string type
        RET

BGSTRF: MOV     BP,CX           ;SAVE THE "USING" STRING CHARACTER COUNT
        MOV     DI,SI           ;SAVE THE POINTER INTO THE "USING" STRING
        MOV     BX,2            ;THE \\ STRING FIELD HAS 2 PLUS
                                ;NUMBER OF ENCLOSED SPACES WIDTH
LPSTRF:
        LODSB                   ;GET THE NEXT CHARACTER
        CMP     AL,CSTRNG       ;THE FIELD TERMINATOR?
        JZ      ISSTRF          ;GO EVALUATE A STRING AND PRINT
        INC     BX              ;INCREMENT THE FIELD WIDTH
        CMP     AL," "          ;A FIELD EXTENDER?
        LOOPZ   LPSTRF          ;KEEP SCANNING FOR THE FIELD TERMINATOR

; SINCE  STRING FIELD WASN'T FOUND, THE "USING" STRING
; CHARACTER COUNT AND THE POINTER INTO IT'S DATA MUST
; BE RESTORED AND THE "\" PRINTED
;
NOSTRF: MOV     SI,DI           ;RESTORE THE POINTER INTO "USING" STRING'S DATA
        MOV     CX,BP
        MOV     AL,CSTRNG       ;RESTORE THE CHARACTER
;
; HERE TO PRINT THE CHARACTER IN [AL] SINCE IT WASN'T PART OF ANY FIELD
;
NEWUCH: CALL    PLSPRT          ;IF A "+" CAME BEFORE THIS CHARACTER
                                ;MAKE SURE IT GETS PRINTED
        CALL    $$WCH           ;PRINT THE CHARACTER THAT WASN'T
                                ;PART OF A FIELD

;Here is the entry point to start scanning for the next value field.
;Register usage:
;       SI      Points to next byte in PRINT USING string
;       CX      Count of characters left in PRINT USING string
;       DH      Flag byte used by $PUFOUT (stored in FLAG - see above)
;       BH      Number of digits to left of decimal point (numbers only)
;       BL      Number of digits to right of decimal point (numbers only)
;       BX      Length of string field (strings only)

PRCCHR: XOR     AL,AL           ;SET [DH]=0 SO IF WE DISPATCH
        MOV     DH,AL           ;DON'T PRINT "+" TWICE
PLSFIN: CALL    PLSPRT          ;ALLOW FOR MULTIPLE PLUSES
                                ;IN A ROW
        MOV     DH,AL           ;SET "+" FLAG
        LODSB                   ;GET A NEW CHARACTER
        CMP     AL,"!"          ;CHECK FOR A SINGLE CHARACTER
        MOV     BX,1            ;Set string length to 1
        JZ      ISSTRF          ;STRING FIELD
        CMP     AL,"#"          ;CHECK FOR THE START OF A NUMBERIC FIELD
        JZ      NUMNUM          ;GO SCAN IT
        CMP     AL,"&"          ;See if variable string field
        JZ      VARSTR          ;GO PRINT ENTIRE STRING
        DEC     CX              ;ALL THE OTHER POSSIBILITIES
                                ;REQUIRE AT LEAST 2 CHARACTERS
        JZ      REUSIN          ;IF THE VALUE LIST IS NOT EXHAUSTED
                                ;GO REUSE "USING" STRING
        CMP     AL,"+"          ;A LEADING "+" ?
        MOV     AL,8            ;SET [DH] WITH THE PLUS-FLAG ON IN
        JZ      PLSFIN          ;CASE A NUMERIC FIELD STARTS
        MOV     AL,[SI-1]       ;GET BACK THE CURRENT CHARACTER
        CMP     AL,"."          ;NUMERIC FIELD WITH TRAILING DIGITS
        JZ      DOTNUM          ;IF SO GO SCAN WITH [BH]=
                                ;NUMBER OF DIGITS BEFORE THE "."=0
        CMP     AL,"_"          ;CHECK FOR LITERAL CHARACTER DECLARATION
        JZ      LITCHR
        CMP     AL,CSTRNG       ;CHECK FOR A BIG STRING FIELD STARTER
        JZ      BGSTRF          ;GO SEE IF IT REALLY IS A STRING FIELD
        CMP     AL,[SI]         ;SEE IF THE NEXT CHARACTER MATCHES THE
                                ;CURRENT ONE
        JNZ     NEWUCH          ;IF NOT, CAN'T HAVE $$ OR ** SO ALL THE
                                ;POSSIBILITIES ARE EXHAUSTED
        CMP     AL,CURNCY       ;IS IT $$ ?
        JZ      DOLRNM          ;GO SET UP THE FLAG BIT
        CMP     AL,"*"          ;IS IT ** ?
        JNZ     NEWUCH          ;IF NOT, ITS NOT PART
                                ;OF A FIELD SINCE ALL THE POSSIBILITIES
                                ;HAVE BEEN TRIED
        OR      DH,32           ;Set "*" bit
        INC     SI
        CMP     CX,2            ;SEE IF THE "USING" STRING IS LONG
                                ;ENOUGH FOR THE SPECIAL CASE OF
        JC      SPCNUM          ; **$
        MOV     AL,[SI]
        CMP     AL,CURNCY       ;IS THE NEXT CHARACTER $ ?
        JNZ     SPCNUM          ;IF IT NOT THE SPECIAL CASE, DON'T
                                ;SET THE DOLLAR SIGN FLAG
        DEC     CX              ;DECREMENT THE "USING" STRING CHARACTER COUNT
                                ;TO TAKE THE $ INTO CONSIDERATION
        INC     BH              ;INCREMENT THE FIELD WIDTH FOR THE
                                ;FLOATING DOLLAR SIGN
DOLRNM:
        OR      DH,16           ;SET BIT FOR FLOATING DOLLAR SIGN FLAG
        INC     SI              ;POINT BEYOND THE SPECIAL CHARACTERS
SPCNUM: INC     BH              ;SINCE TWO CHARACTERS SPECIFY
                                ;THE FIELD SIZE, INITIALIZE [BH]=1
NUMNUM: INC     BH              ;INCREMENT THE NUMBER OF DIGITS BEFORE
                                ;THE DECIMAL POINT
        MOV     BL,0            ;SET THE NUMBER OF DIGITS AFTER
                                ;THE DECIMAL POINT = 0
        DEC     CX              ;SEE IF THERE ARE MORE CHARACTERS
        JZ      NOTSCI          ;IF NOT, WE ARE DONE SCANNING THIS
                                ;NUMERIC FIELD
        LODSB                   ;GET THE NEW CHARACTER
        CMP     AL,"."          ;DO WE HAVE TRAILING DIGITS?
        JZ      AFTDOT          ;IF SO, USE SPECIAL SCAN LOOP
        CMP     AL,"#"          ;MORE LEADING DIGITS ?
        JZ      NUMNUM          ;INCREMENT THE COUNT AND KEEP SCANNING
        CMP     AL,","          ;DOES HE WANT A COMMA
                                ;EVERY THREE DIGITS?
        JNZ     FINNUM          ;NO MORE LEADING DIGITS, CHECK FOR ^^^
        OR      DH,64           ;TURN ON THE COMMA BIT
        JMP     NUMNUM          ;GO SCAN SOME MORE
;
; HERE WHEN A "." IS SEEN IN THE "USING" STRING
; IT STARTS A NUMERIC FIELD IF AND ONLY IF
; IT IS FOLLOWED BY A "#"
;
DOTNUM: MOV     AL,[SI]         ;GET THE CHARACTER THAT FOLLOWS
        CMP     AL,"#"          ;IS THIS A NUMERIC FIELD?
        MOV     AL,"."          ;IF NOT, GO BACK AND PRINT "."
        JNZ     NEWUCH
        MOV     BL,1            ;INITIALIZE THE NUMBER OF
                                ;DIGITS AFTER THE DECIMAL POINT
        INC     SI
AFTDOT: INC     BL              ;INCREMENT THE NUMBER OF DIGITS
                                ;AFTER THE DECIMAL POINT
        DEC     CX              ;SEE IF THE "USING" STRING HAS MORE
        JZ      NOTSCI          ;CHARACTERS, AND IF NOT, STOP SCANNING
        LODSB                   ;GET THE NEXT CHARACTER
        CMP     AL,"#"          ;MORE DIGITS AFTER THE DECIMAL POINT?
        JZ      AFTDOT          ;IF SO, INCREMENT THE COUNT AND KEEP
                                ;SCANNING
;
; CHECK FOR THE "^^^^" THAT INDICATES SCIENTIFIC NOTATION
;
FINNUM:
        DEC     SI              ;Point back to current character
        CMP     WORD PTR [SI],"^^"      ;Two "^"s in a row?
        JNZ     NOTSCI
        CMP     WORD PTR [SI+2],"^^"    ;Four "^"s in a row?
        JNZ     NOTSCI
        CMP     CX,4          	;WERE THERE ENOUGH CHARACTERS FOR "^^^^"?
        JC      RT
        SUB     CX,4
        ADD     SI,4
        INC     DH              ;TURN ON THE SCIENTIFIC NOTATION FLAG
NOTSCI:
        INC     BH              ;INCLUDE LEADING "+" IN NUMBER OF DIGITS
        TEST    DH,8            ;DON'T CHECK FOR A TRAILING SIGN
        JNZ     ENDNUM          ;ALL DONE WITH THE FIELD IF SO
                                ;IF THERE IS A LEADING PLUS
        DEC     BH              ;NO LEADING PLUS SO DON'T INCREMENT THE
                                ;NUMBER OF DIGITS BEFORE THE DECIMAL POINT
        JCXZ    ENDNUM          ;SEE IF THERE ARE MORE CHARACTERS
        LODSB                   ;GET THE CURRENT CHARACTER
        CMP     AL,"-"          ;TRAIL MINUS?
        JZ      SGNTRL          ;SET THE TRAILING SIGN FLAG
        CMP     AL,"-"          ;A TRAILING PLUS?
        JNZ     ENDNUM          ;IF NOT, WE ARE DONE SCANNING
        OR      DH,8            ;TURN ON THE POSITIVE="+" FLAG
SGNTRL: OR      DH,4            ;TURN ON THE TRAILING SIGN FLAG
        DEC     CX              ;DECREMENT THE "USING" STRING CHARACTER
                                ;COUNT TO ACCOUNT FOR THE TRAILING SIGN
ENDNUM:
        MOV     PUSC,CX         ;Save scan count
        MOV     $DIGCNT,BX
        ADD     BH,BL           ;Digit count must not exceed 24
        CMP     BH,25
        JNC     ARGERR          ;IF SO, "ILLEGAL FUNCTION CALL"
        OR      DH,80H          ;TURN ON THE "USING" BIT
        MOV     FLAG,DH
        RET                     ;GET OUT

ARGERR: JMP     $ERC_FC

; WHEN A "+" IS DETECTED IN THE "USING" STRING
; IF A NUMERIC FIELD FOLLOWS A BIT IN [DH] SHOULD
; BE SET, OTHERWISE "+" SHOULD BE PRINTED.
; SINCE DECIDING WHETHER A NUMERIC FIELD FOLLOWS IS VERY
; DIFFICULT, THE BIT IS ALWAYS SET IN [DH].
; AT THE POINT IT IS DECIDED A CHARACTER IS NOT PART
; OF A NUMERIC FIELD, THIS ROUTINE IS CALLED TO SEE
; IF THE BIT IN [DH] IS SET, WHICH MEANS
; A PLUS PRECEDED THE CHARACTER AND SHOULD BE
; PRINTED.
;
PLSPRT:
        OR      DH,DH           ;CHECK THE PLUS BIT
        JZ      RT
        PUSH    AX              ;SAVE THE CURRENT CHARACTER
        MOV     AL,"+"          ;SETUP TO PRINT THE PLUS
        CALL    $$WCH           ;PRINT IT IF THE BIT WAS SET
        POP     AX              ;GET BACK THE CURRENT CHARACTER
RT:     RET

CODE    ENDS
        END
