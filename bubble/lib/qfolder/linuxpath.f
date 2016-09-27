\ {nodoc}
\ Copyright 2014 - Leon Konings - Konings Software.
\ Created for Roger Levy

\
\ LINUXPATH
\

\ Without extra buffer
\ Changes zpath in place.
: nextpart ( zpath -- c-addr/u/true | false )
  locals| zpath |
  zpath zcount [char] / skip
  2dup [char] / scan
  dup if
    2dup 2>r
    \ Save result in pad.
    nip - pad zplace
    \ scan and zplace seem to use the same buffer.
    2r> zpath zplace
    pad zcount true
  else  2drop drop zero  then ;

: zslashappend ( z-addr -- ) spathseparator count rot zappend ;

create zlinuxpathinput path-length /allot
create zlinuxpathoutput path-length /allot
create znextpartbuffer 80 /allot

0 value linuxpathlength

false value linuxpathneedsslash
false value linuxpathfound
false value linuxpathabsolute
false value linuxpathgetnext

: continue-with-part ( -- flag )
  linuxpathgetnext if
   false to linuxpathgetnext
   zlinuxpathinput nextpart dup>r if
    \ c-addr u
    \ cr ." continue-with-path: " 2dup type
    znextpartbuffer zplace
    then r>
  else  true  then ;

: linuxpath-init ( zpath -- )
  z-correctpath
  zcount  dup to linuxpathlength  zlinuxpathinput zplace
  zlinuxpathinput zslashappend
  0 zlinuxpathoutput c!
  0 znextpartbuffer c!
  zlinuxpathinput c@ [char] / =
  dup to linuxpathabsolute
    to linuxpathneedsslash
  true to linuxpathgetnext
  false to linuxpathfound ;

: linuxpath-zstartdirectory ( -- zstartdirectory )
  linuxpathabsolute
  if  z" /"  else  z" ."  then ; \ "

: linuxpath-folder ( zpath -- enter? )
  \ cr ." linuxpath-folder: " dup zcount type .s cr
  continue-with-part if  \ zpath
   \ cr ." linuxpath-folder continue --- " .s
    dup zcount ( .filename zcount -path )
    znextpartbuffer zcount
    uppcompare 0= if  \ zpath
      linuxpathneedsslash if  zlinuxpathoutput zslashappend  then
      zcount zlinuxpathoutput zappend
      true to linuxpathneedsslash
      true to linuxpathgetnext
      \ cr ." linuxpath-folder part found! " .s
      linuxpathlength zlinuxpathoutput zcount nip = to linuxpathfound
      true
    else  \ zpath
      zero
    then  \ flag
  else  \ zpath
    true to linuxpathfound
    zero
  then ;

: linuxpath-file ( dirent file-zstr -- stop? )
  2drop linuxpathfound ;

: (linuxpath)  ( zpath zstartdirectory -- zdirpath true | false )
  locals| zstartdirectory zpath |
  zstartdirectory zcount ['] linuxpath-file zpath ['] linuxpath-folder directorieswalker2
  continue-actions not if  zlinuxpathoutput  then
  continue-actions 0= ;

: zlinuxpath  ( zpath1 -- zpath2/true | false )
  pushpath
  dup zcount absolutepath-exists if  true exit  then
  linuxpath-init
  zlinuxpathinput linuxpath-zstartdirectory (linuxpath) if  true  else  false  then
  poppath ;

: linuxpath  ( c-path1 u -- c-path2/u/true | false )
  500 allocate abort" Allocate memory error in linuxpath"
  dup>r zplace r@ zlinuxpath if  zcount true  else  false  then
  r> free abort" Free memory error in linuxpath" ;

: zfileexists ( zpath1 -- zpath2/true | false )
  dup zcount file-exists dup not if  nip  then ;

: zcheckpath  ( zpath1 -- zpath2/true | false )
  [undefined] linux? [if] zfileexists  [else]  zlinuxpath  [then] ;

: fileexists ( c-path1 u -- c-path2/u/true | false )
  2dup file-exists dup not if  2drop zero  then ;

: checkpath  ( c-path1 u -- c-path2/u/true | false )
  [undefined] linux? [if]  fileexists  [else]  linuxpath  [then] ;
