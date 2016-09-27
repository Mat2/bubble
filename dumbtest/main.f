include bubble/core/core

[bub] idiom [dumb]


: push " >r" evaluate ; immediate
: pop  " r>" evaluate ; immediate


: riser  create 0 , does> dup push +! pop @ ;
riser r
riser b

: ok  go  show  0.004 r 0 0.014 b clear-to-color ;

ok
