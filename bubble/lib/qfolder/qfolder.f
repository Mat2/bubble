\ {nodoc}
\ Copyright 2014 - Leon Konings - Konings Software.
\ Created for Roger Levy

\ Note:  This library is intended to be ANS94 compatible.
\  If it isn't, then we need to take the steps to fix that.

true constant qfolder

include bubble/lib/qfolder/utilities
[undefined] linux?   [IF]   include bubble/lib/qfolder/windows
                     [ELSE] include bubble/lib/qfolder/linux
[THEN]
include bubble/lib/qfolder/dirwalker
include bubble/lib/qfolder/linuxpath
include bubble/lib/qfolder/main
