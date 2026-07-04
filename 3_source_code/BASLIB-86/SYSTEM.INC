;       Operating System Selection

_IBM_=                  0

_MSDOS_=                1
_CPM_=                  0

;       Overrides

_MSDOS_=                _MSDOS_ or _IBM_

if1
if      _CPM_
        %OUT    !   CP/M-86 Version
endif
if      _MSDOS_
        %OUT    !   MSDOS Version
endif
if      _IBM_
        %OUT    !     IBM Personal Computer
endif

if      _MSDOS_+_CPM_ ne 1
        %OUT    #####################  Error - Bad Operating System Selection

        error
endif
endif

