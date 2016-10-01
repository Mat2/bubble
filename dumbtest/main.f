include bubble/core/core

[bub] idiom [dumb]
include dumbtest/words


: riser  create 0 , does> dup push +! pop @ ;
riser r
riser b

: logic  ; 
: dumb  go  logic  show  0.004 r 0 0.014 b clear-to-color ;

dumb ok
