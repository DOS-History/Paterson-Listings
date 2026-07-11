;       Special Table Generation Macros

ENTORG  MACRO   First_entry
        .XCREF
___ZZZ=         First_entry
        .CREF
        ENDM


ENT     MACRO   Lab,Incr
Lab=            ___ZZZ
        .XCREF
___ZZZ=         ___ZZZ+Incr
        .CREF
        ENDM


ENTI    MACRO   Incr
        .XCREF
___ZZZ=         ___ZZZ+Incr
        .CREF
        ENDM

