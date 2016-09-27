\ {nodoc}
\ Copyright 2014 - Leon Konings - Konings Software.
\ Created for Roger Levy


\
\ FIND FILE IN DIRECTORY TREE
\

\
\ ?FOLDER1
\

\ Using directorieswalker1 searches the entire directory tree for zfile,
\ which is a path. if  a filename is encountered once,
\ the file that is closest to the start directory is returned.
\
\ file-xt  ( dirent file-zstr -- stop? )
\
\ Word findclosest is the file-xt for directorieswalker1.

12345 value closestlevel  \ magic number: do not change
0 value filefound

: (search-closest-file)  ( dirent zstr -- stop? )
  zcount rot .filename zcount -path pathcompare 0=
  if
    level closestlevel < if
      cwd zresult-buf zplace
      level to closestlevel
      true to filefound
    then
   then
  false ;

: findclosest  ( zfile zstartdirectory -- zdirpath true | false )
  locals| zstartdirectory zfile |
  12345 to closestlevel
  false to filefound
  zstartdirectory zcount ['] (search-closest-file) zfile directorieswalker1
  filefound if  zresult-buf true  else  false  then ;

: ?folder1  ( zfile -- folderpath/u/true | false )
  pushpath
  dup zcount absolutepath-exists if  zcount true exit  then
  zfolder zcheckpath
  if  findclosest if  zcount true  else  false  then
  else  zero  then
  poppath ;

\ ALIAS:
: ?folder  ( zfile -- folderpath/u/true | false ) ?folder1 ;

\
\ ?FOLDER-FAST1
\

\ Using directorieswalker1 searches directory tree for zfile, which is a path.
\ Searches the tree, Until a filename is encountered.
\
\ if  a filename exists more than once, a random file is returned.
\
\ file-xt  ( dirent file-zstr -- stop? )
\
\ Word findfirst is the file-xt for directorieswalker1.

create zfile-buf path-length /allot

\ Word findfirst used as xt in directorieswalker.
\ stop? is true when zfilename is encountered, and searching is  then stopped.
\ All open directorystreams are closed.
: (findfirst)  ( dirent zfilename -- stop? )
  zcount rot .filename zcount -path pathcompare 0=
  dup if  cwd zresult-buf zplace  then ;

: findfirst  ( zfile zstartdirectory -- zdirpath true | false )
  locals| zstartdirectory zfile |
  zstartdirectory zcount ['] (findfirst) zfile directorieswalker1
  continue-actions not if  zresult-buf  then
  continue-actions 0= ;

: ?folder-fast1  ( zfile -- folderpath/u/true | false )
  \ cr ." ?folder-fast1: " dup zcount type
  pushpath
  dup zcount absolutepath-exists if  zcount true exit  then
  zfolder zcheckpath
  if  findfirst if  zcount true  else  false  then
  else  zero  then
  poppath ;

\
\ FIND FIRST FILE IN DIRECTORY TREE
\ DO NOT SEARCH IN CERTAIN FOLDERS
\

\
\ ?FOLDER2
\

\ Using directorieswalker2 searches entire the directory tree for zfile,
\ which is a path. if  a filename is encountered once,
\ the file that is closest to the start directory is returned.
\
\ file-xt  ( dirent file-zstr -- stop? )
\
\ Word findclosest is the file-xt for directorieswalker2.
\
\ folder-xt ( zfolderpath -- enter? )
\
\ Folder-xt is a filter. When it returns false, the folder will not be entered,
\ so it is excluded from the walk-through.

: findclosest2  ( zfile folder-xt zstartdirectory -- zdirpath true | false )
  locals| zstartdirectory folder-xt zfile |
  12345 to closestlevel
  false to filefound
  zstartdirectory zcount ['] (search-closest-file) zfile folder-xt directorieswalker2
  filefound if  zresult-buf true  else  false  then ;

: ?folder2  ( zfile folder-xt -- folderpath/u/true | false )
  pushpath
  over zcount absolutepath-exists if  drop zcount true exit  then
  zfolder zcheckpath
  if  findclosest2 if  zcount true  else  false  then
  else  drop zero  then
  poppath ;

\
\ ?FOLDER-FAST2
\

\ Using directorieswalker2 searches directory tree for zfile, which is a path.
\ Searches the tree, Until a filename is encountered.
\
\ if  a filename exists more than once, a random file is returned.
\
\ file-xt  ( dirent file-zstr -- stop? )
\
\ Word findfirst is the file-xt for directorieswalker2.
\
\ folder-xt ( zfolderpath -- enter? )
\
\ Folder-xt is a filter. When it returns false, the folder will not be entered,
\ so it is excluded from the walk-through.

: (?folder-fast2)  ( zfile folder-xt zstartdirectory -- zdirpath true | false )
  locals| zstartdirectory folder-xt zfile |
  zstartdirectory zcount ['] (findfirst) zfile folder-xt directorieswalker2
  continue-actions not if  zresult-buf  then
  continue-actions 0= ;

: ?folder-fast2  ( zfile folder-xt -- folderpath/u/true | false )
  \ cr ." ?folder-fast2: " over zcount type
  pushpath
  over zcount absolutepath-exists if  drop zcount true exit  then
  zfolder zcheckpath
  if  (?folder-fast2) if  zcount true  else  false  then
  else  drop zero  then
  poppath ;

\
\ RELATIVE-TO
\

\ Returns the closest relative path to filepath starting at directory folderpath.
\
\ if  filepath is not a absolute path directorieswalker3 searches the entire
\ directory tree for filepath. if  a filename is encountered more than once,
\ the file that is closest to the start directory is returned.

create zrelativepath-buf path-length /allot

: (updaterelativepath)  ( -- )
  continue-actions if
    zresult-buf zcount nip if  spathseparator count zresult-buf zappend  then
    cwd -path  zresult-buf zappend
    \ cr ." update: " zresult-buf zcount type
   then ;

: (reducerelativepath)  ( -- )
  continue-actions if
    zresult-buf zcount dup if  -name  zresult-buf zplace  else  2drop  then
    \ cr ." reduce: " zresult-buf zcount type
   then ;

: handle-absolutepath  ( folderpath c -- )
  absolutepath? if  2dup -name  zfile-buf zplace  zfile-buf changedir  then ;

: (rfind-closest-file)  ( dirent zstr -- stop? )
  zcount rot .filename zcount -path pathcompare 0= if
    level closestlevel < if
      zresult-buf zcount zrelativepath-buf zplace
      \ cr ." zresult-buf: " zresult-buf zcount type
      level to closestlevel
      true to filefound
    then
   then
  false ;

: findclosestrelativepath  ( zfile zstartdirectory -- )
  swap >r  zcount ['] (rfind-closest-file) r> ['] (updaterelativepath) ['] (reducerelativepath) directorieswalker3 ;

: relative-to  ( filepath c folderpath c -- filepath/c | false )
  pushpath
  2dup handle-absolutepath
  zfolder zplace
  -path zfile-buf zplace
  0 zresult-buf c!
  12345 to closestlevel
  false to filefound
  \ cr cr ." relative-to: " .s
  zfile-buf zfolder zcheckpath if
    findclosestrelativepath
    \ cr ." relative-to." .s cr
    filefound if
      spathseparator count zrelativepath-buf zappend
      zfile-buf zcount zrelativepath-buf zappend
      zrelativepath-buf zcount
    else  false  then
  else  zero  then
  poppath ;

\
\ RELATIVE-TO-FAST
\

: (rfindfirst)  ( dirent zfilename -- stop? )
  zcount rot .filename zcount -path pathcompare 0= ;

: findrelativepath  ( zfile zstartdirectory -- )
  swap >r  zcount ['] (rfindfirst) r> ['] (updaterelativepath) ['] (reducerelativepath) directorieswalker3 ;

: relative-to-fast  ( filepath c folderpath c -- filepath/c | false )
  pushpath
  2dup handle-absolutepath
  zfolder zplace
  -path zfile-buf zplace
  0 zresult-buf c!
  \ cr cr ." relative-to-fast: " .s
  zfile-buf zfolder zcheckpath
  if  findrelativepath
    \ cr ." relative-to-fast." .s cr
    zresult-buf zcount nip if  spathseparator count zresult-buf zappend  then
    zfile-buf zcount zresult-buf zappend
    continue-actions if  false  else  zresult-buf zcount  then
    else  zero  then
  poppath ;
