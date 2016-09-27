\ {nodoc}
\ Copyright 2014 - Leon Konings - Konings Software.
\ Created for Roger Levy

\ SwiftForth-specific...
WIN32_FIND_DATA SUBCLASS _DIRTOOL

   MAX_PATH BUFFER: fullpath

   : IS-DIR  ( -- flag )
      FileAttributes @ FILE_ATTRIBUTE_DIRECTORY AND 0<> ;

   : IS-SUBDIR  ( -- flag )
      FileAttributes @ FILE_ATTRIBUTE_DIRECTORY AND
      FileName ZCOUNT S" ."  COMPARE 0<> AND
      FileName ZCOUNT S" .." COMPARE 0<> AND ;

   : SUBDIR/FILE  ( -- flag )
      FileName ZCOUNT S" ."  COMPARE 0<>
      FileName ZCOUNT S" .." COMPARE 0<> AND ;
   
   : FIRST  ( zstr -- addr flag )
      ADDR FindFirstFile
      DUP INVALID_HANDLE_VALUE <> ;

   : NEXT  ( addr -- flag )
      ADDR FindNextFile ;

   : CLOSE  ( addr -- n )
      FindClose ;

   : FULLNAME ( -- c-addr u )
      FileName MAX_PATH fullpath 0 GetFullPathName fullpath swap ;

END-CLASS

_dirtool builds dt

: nn  ( n -- addr u ) dup 0< (d.) ;

create error-buf 100 /allot

\ TODO: Not working well with signed numbers 
: strerror  ( errnum -- c-addr  u )
   z" Error with nr: " zcount 
   error-buf zplace
   z"  " zcount error-buf zappend
   0 nn error-buf zappend
   error-buf zcount ;

: @strerror  ( -- c-addr u )
   getlasterror strerror ; 

: ?strerror  ( -- )
   getlasterror ?dup if bright ." ERROR: " ( dup ) . ( strerror type ) normal cr then ;

500 constant path-length

create cwd-buf path-length /allot
create path-buf path-length /allot

: cwd  ( -- c-addr u ) cwd-buf path-length over GetCurrentDirectory   ;
   
\ x is not used in Windows version.
: .filename  ( x - z-addr ) drop  dt fullname path-buf zplace  path-buf ;

: dirfd  ( Dir  -- z-addr ) .filename ;

: fchdir  ( z-addr -- ) SetCurrentDirectory drop ;

: changedir ( z-addr -- ) fchdir ;

\ x is not used in Windows version.
: is-dir  ( x -- flag ) drop  dt is-dir ;
 
 \ x is not used in Windows version.
: is-sub-dir  ( x -- flag ) drop  dt is-subdir ;

: subdir/file  ( x -- flag ) drop  dt subdir/file ; 

false value isNext

: cd..  ( -- ) cwd -name path-buf zplace  path-buf fchdir ;

\ After closing the directory sets the present working directory.
\
: closedir  ( Dir  -- n )
   dt close  cd.. ;

 \ Dir is a address in Windows.
 : opendir  ( c-addr u -- Dir | 0 )
    false to isNext
    path-buf zplace
    path-buf dt first \ addr flag
    if
       0 .filename  fchdir  \ addr
       dt close drop
       z" *.*" dt first drop
    else
       zero
    then ;

\ Dir is an address in Windows.
\ The first readdir is done by first.
\ So the first time readdir can just pass on the result of opendir.
\ If readdir returns 0, there is nothing more to read.
: readdir  ( Dir -- Dir | 0 )
   isNext if dt next else true to isNext then ;
   
\ Linux way change a directory, doing nothing on Windows.
: linux-chdir ( Dir -- Dir ) ;

create zresult-buf path-length /allot

\ Windows is not case sensitive, so put the zfilename in zresult-buf.
: findrealfilename  ( dirent zfilename -- stop? )
   nip  zcount zresult-buf zplace  true ;
