\ {nodoc}
\ Copyright 2014 - Leon Konings - Konings Software.
\ Created for Roger Levy

\ Current working directory

AS (strerror) FUNCTION: strerror  ( errnum  -- str )

: strerror  ( errnum -- c-addr  u)
  (strerror) zcount ;

: @strerror  ( -- c-addr u )
  errno @ strerror ;

: ?strerror  ( -- )
  errno @ ?dup if  bright ." ERROR: " dup . strerror type normal cr  then ;

500 constant path-length

create cwd-buf path-length /allot

: cwd  ( -- c-addr u )
  0 errno !
  cwd-buf path-length getcwd zcount ;

\ LINUX: man 2 stat

: get-stat  ( c-addr u -- buffer-with-state )
  R-BUF R@ ZPLACE  R@ DUP stat  R>  SWAP 0< -37 AND THROW ;

: .filename  ( dirent - z-addr ) 11 + ;

\ For IS-DIR see directory.f

: is-sub-dir  ( z-addr -- f )
  dup is-dir
  if  \ Isn't it the . or .. directory?
    zcount
    2dup 1 = swap c@ 46 = and -rot  \ directory . ?
    2dup 2 = swap c@ 46 = and -rot drop 1+ c@ 46 = and  \ directory .. ?
    or not
  else  zero  then ;

\ LIBRARY libc.so.6

\ LINUX: man 3 readdir

AS (opendir) FUNCTION: opendir ( *name  -- Dir )  \ Dir is the directory stream

: opendir  ( c-addr u -- Dir )
  0 errno !
  R-BUF
  R@ ZPLACE
  R> (opendir) ;

AS (readdir) FUNCTION: readdir ( Dir dirent-entry dirent-result  -- dirent )

\ LINUX: man 2 opendir

create dirent-buf path-length /allot
create dirent-result-buf path-length /allot

: readdir  ( Dir -- dirent | 0 )
  0 errno !
  dirent-buf dirent-result-buf
  (readdir) ;
  \ errno @ 0<> if  zero  then ;

\ LINUX: man 3 dirfd

FUNCTION: dirfd  ( Dir  -- fd )

\ LINUX: man 2 fchdir

AS (fchdir) FUNCTION: fchdir  ( fd  -- )

: fchdir  ( fd -- )
  0 errno !
  (fchdir) ?strerror ;

: changedir ( z-addr -- ) chdir drop ;

\ FUNCTION: telldir  ( Dir  -- n )
\ FUNCTION: seekdir  ( Dir n  -- )

FUNCTION: closedir  ( Dir  -- n )

\ Linux way to change a directory.
: linux-chdir ( Dir -- Dir )
  dup dirfd fchdir ;

: subdir/file  ( dirent -- flag )
  .filename zcount -path
  2dup S" ."  compare 0<>
  -rot S" .." compare 0<> and ;

create zresult-buf path-length /allot

\ To find directoryname in a case sensitive OS like Linux.
: findrealfilename  ( dirent zfilename -- stop? )
  swap .filename zcount 2dup 2>r
  rot zcount  pathcompare 0=
  if  2r> zresult-buf zplace  true
  else  2r> drop zero  then ;
