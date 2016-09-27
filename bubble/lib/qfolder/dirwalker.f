\ {nodoc}
\ Copyright 2014 - Leon Konings - Konings Software.
\ Created for Roger Levy

\
\ DIRECTORYWALKER, WALKING THROUGH ONE DIRECTORY
\

\ Starts recursive word (directorywalker) that works on one directory.

create zfolder path-length /allot

: (directorywalker)  ( c-addr u xt zstr -- Dir dirent ) ( dirent zstr -- stop? )
  locals| zstr xt |
  opendir
  dup dirfd fchdir
  begin \ Dir
    dup readdir dup 0<>
  while \ Dir dirent
    dup subdir/file
    \ cr ." subdir/file: " .
    if  zstr xt execute if  0 exit  then  else  drop  then
  repeat ;

: directorywalker  ( c-addr u xt zstr -- ) ( dirent zstr -- stop? )
  pushpath
  (directorywalker) drop  ?dup if  closedir drop  then
  poppath ;

\
\ WALKING FROM A START DIRECTORY THROUGH ALL SUBDIRECTORIES
\

\ Set continue-actions before starting dirStreamActions

true value continue-actions
false value dir-finished
0 value level
0 value opened-dirs
0 value closed-dirs

: initdirectorywalker
true to continue-actions
false to dir-finished
0 to level
0 to opened-dirs
0 to closed-dirs ;

\ DIRECTORIESWALKER1

\ Starts recursive word (directorieswalker1) that works on one directory.
\ When it encounters a subdirectory, it calls itself to open another directory stream.
\
\ The param can be used by the execution token file-xt.
\ When file-xt returns true, continue-actions is set to false,
\ and walking through the directory tree is stopped.
\ The opened directories on the stack are all closed.


: (directorieswalker1)  ( c-addr u file-xt param -- ) ( dirent zstr -- stop? )
  locals| param file-xt |
  \ cr ."  (directorieswalker1): " 2dup type .s cr cr
  opendir  \ Dir
  1 +to opened-dirs
  dup dirfd fchdir
  2 +to level
  false to dir-finished
  \ cr level spaces ." pwd: " pwd cr cr
  begin  \ Dir
    \ cr ." Dir: " .s
    dir-finished if  linux-chdir ( cr level spaces ." dir-finished, pwd: " pwd cr cr )  then
    dup readdir dup 0<>
    continue-actions and
  while  \ Dir dirent
    dup subdir/file
    if   \ Dir dirent
      \ file-xt  ( dirent param -- stop? )
      dup param file-xt execute
      if   \ Dir dirent
        \ cr ." Stopped: " .s
        false to continue-actions
        drop  ?dup if  closedir drop  then
        1 +to closed-dirs
        exit
      else  \ Dir dirent
        .filename dup
        is-sub-dir if  zcount file-xt param recurse  else  drop  then
      then
    else  drop  then
  repeat \ Dir x
  \ cr ." Closing: " .s
  drop  ?dup if  closedir drop  then
  1 +to closed-dirs
  -2 +to level
  true to dir-finished ;

: directorieswalker1  ( dirpath c file-xt param -- ) ( dirent param -- stop? )
  pushpath
  initdirectorywalker
   (directorieswalker1)
  poppath ;

\ DIRECTORIESWALKER2

\ Starts recursive word (directorieswalker1) that works on one directory.
\ When it encounters a subdirectory, it calls itself, to open another directory stream.
\
\ The param can be used by the execution token file-xt.
\ When file-xt returns true, continue-actions is set to false,
\ and walking through the directory tree is stopped.
\ The opened directories on the stack are all closed.
\
\ Folder-xt is a filter. When it returns false, the folder will not be entered,
\ so it is excluded from the walk-through.

\ folder-xt  ( zpath -- enter? )


: (directorieswalker2)  ( c-addr u file-xt param folder-xt -- )  ( dirent param -- stop? ) ( zpath -- enter? )
  locals| folder-xt param file-xt |
  \ cr ."  (directorieswalker2): " 2dup type .s cr cr
  opendir  \ Dir
  1 +to opened-dirs
  dup dirfd fchdir
  2 +to level
  false to dir-finished
  \ cr level spaces ." pwd: " pwd cr cr
  begin  \ Dir
    \ cr ." Dir: " .s
    dir-finished if  linux-chdir ( cr level spaces ." dir-finished, pwd: " pwd cr cr )  then
    dup readdir dup 0<>
    continue-actions and
  while  \ Dir dirent
    dup subdir/file
    if   \ Dir dirent
      \ folder-xt  ( zpath -- enter? )
      dup .filename folder-xt execute
      if   \ Dir dirent
        \ file-xt  ( dirent param -- stop? )
        dup param file-xt execute
        if   \ Dir dirent
          \ cr ." Stopped: " .s
          false to continue-actions
          drop  ?dup if  closedir drop  then
          1 +to closed-dirs
          exit
        else  \ Dir dirent
          .filename dup
          is-sub-dir if  zcount file-xt param folder-xt recurse  else  drop  then
        then
      else  \ Dir dirent
        drop
      then
     else  drop  then
  repeat \ Dir x
  \ cr ." Closing: " .s
  drop  ?dup if  closedir drop  then
  1 +to closed-dirs
  -2 +to level
  true to dir-finished ;

: directorieswalker2  ( c-addr u file-xt param folder-xt -- ) ( dirent param -- stop? ) ( zpath -- enter? )
  pushpath
  initdirectorywalker
  (directorieswalker2)
  poppath ;

\ DIRECTORIESWALKER3

\ Starts recursive word (directorieswalker1) that works on one directory.
\ When it encounters a subdirectory, it calls itself, to open another directory stream.
\
\ The param can be used by the execution token file-xt.
\ When file-xt returns true, continue-actions is set to false,
\ and walking through the directory tree is stopped.
\ The opened directories on the stack are all closed.
\
\ Folder1-xt is executed on the way down the directory tree, when a subdirectory is entered.
\
\ Folder2-xt is executed on the way up the directory tree, when a subdirectory is closed.

: (directorieswalker3)  ( c-addr u file-xt param folder1-xt folder2-xt -- ) ( dirent param -- stop? ) ( zpath -- enter? ) ( zpath -- enter? )
  locals| folder2-xt folder1-xt param file-xt |
  \ cr ."  (directorieswalker3): " 2dup type .s cr cr
  opendir  \ Dir
  1 +to opened-dirs
  dup dirfd fchdir
  2 +to level
  folder1-xt execute
  false to dir-finished
  \ cr level spaces ." pwd: " pwd cr cr
  begin  \ Dir
    \ cr ." Dir: " .s
    dir-finished if  linux-chdir ( cr level spaces ." dir-finished, pwd: " pwd cr cr )  then
    dup readdir dup 0<>
    continue-actions and
  while  \ Dir dirent
    dup subdir/file
      if   \ Dir dirent
      \ file-xt  ( dirent param -- stop? )
      dup param file-xt execute
      if   \ Dir dirent
        \ cr ." Stopped: " .s
        false to continue-actions
        drop  ?dup if  closedir drop  then
        1 +to closed-dirs
        exit
      else  \ Dir dirent
        .filename dup
        is-sub-dir if  zcount file-xt param folder1-xt folder2-xt recurse  else  drop  then
      then
     else  drop  then
  repeat \ Dir x
  \ cr ." Closing: " .s
  drop  ?dup if  closedir drop  then
  1 +to closed-dirs
  -2 +to level
  folder2-xt execute
  true to dir-finished ;

: directorieswalker3  ( c-addr u file-xt param folder1-xt folder2-xt -- ) ( dirent param -- stop? ) ( zpath -- enter? ) ( zpath -- enter? )
  pushpath
  initdirectorywalker
  (directorieswalker3)
  poppath ;

