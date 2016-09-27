
: *image  ( poth count -- )
    " image " s[ 2dup -ext -path +s " .image " +s +s ]s cr 2dup type evaluate ;

: *sound  ( path count -- )
    " sfx *" s[ 2dup -ext -path +s " * " +s +s ]s cr 2dup type evaluate ;

: (image)  >filename *image ;
: (sound)  >filename *sound ;

: auto-load ( -- <path> )
    pushpath cd
    " images" ['] (image) fdrill
    " sounds" ['] (sound) fdrill
    poppath ;

