;       8086 Interrupt Handling Macros


SAVINT  MACRO   savloc,intloc,reg
IFB     <reg>
        SAVINT  savloc,intloc,AX
ELSE
        MOV     reg,intloc
        MOV     savloc,reg
        MOV     reg,intloc+2
        MOV     savloc+2,reg
ENDIF
        ENDM

RSTINT  MACRO   savloc,intloc,reg
IFB     <reg>
        SAVINT  savloc,intloc,AX
ELSE
        MOV     reg,intloc
        MOV     savloc,reg
        MOV     reg,intloc+2
        MOV     savloc+2,reg
ENDIF
        ENDM

MOVINT  MACRO   savloc,intloc,reg
IFB     <reg>
        SAVINT  savloc,intloc,AX
ELSE
        MOV     reg,intloc
        MOV     savloc,reg
        MOV     reg,intloc+2
        MOV     savloc+2,reg
ENDIF
        ENDM

SETINT  MACRO   intloc,loc
        MOV     word ptr intloc,offset loc
        MOV     word ptr intloc+2,CS
        ENDM

        PAGE
