
\ These components will be compiled into the EXE.
\ It looks like a lot but really we're just conditionally loading a few files,
\ since this file can be loaded multiple times in a programming session.

\ Forth Language-level Extensions

  [undefined] o [if]
    0 value o
    &of o constant &o
    : for>  ( val addr -- )  r>  -rot  dup dup >r @ >r  !  call  r> r> ! ;

    : reverse   ( ... count -- ... ) 1+ 1 max 1 ?do i 1- roll loop ;

  [then]

  [undefined] idiom [if]
    include bubble/lib/idiom
    : include  sp@ >r  include  r> sp@ cell+ <> ?dup if  .s abort" STACK DEPTH CHANGED" then ;
  [then]
  
  \ a directory scanner / file finder
  [undefined] qfolder [if]
    [defined] linux [if] true constant linux? [then]
    include bubble/lib/qfolder/qfolder
  [then]

  \ ffl DOM
  [UNDEFINED] ffl.version [IF]
  include bubble/lib/ffl-0.8.0/ffl
    pushpath
    cd bubble/lib/ffl-0.8.0
    [undefined] dom-create [if]
        global ffling +order
        include ffl/dom.fs
        include ffl/b64.fs
        ffling -order
    [then]
    poppath
  [THEN]

  \ floating point
  [undefined] f+ [if]
    +opt
    warning on
    order
    $ ls
\     requires fpmath
    cr .( loaded: fpmath)
  [then]

  
  \ Various extensions
  [undefined] 1sf [if]
    include bubble/lib/fpext
    cr .( loaded: fpext)
  [then]
  [undefined] rnd [if]
    requires rnd
  [then]
  [undefined] zstring [if]
    include bubble/lib/string-operations
  [then]
  [undefined] file@ [if]
    include bubble/lib/files
  [then]
  [undefined] fixedp [if]
    true constant fixedp
    include bubble/lib/fixedp
  [then]
  :noname [ is onSetIdiom ]  ints @ ?fixed ;

  [undefined] ALLEGRO_VERSION_INT [if]
    include bubble/lib/allegro-5.2/allegro-5.2.f
  [then]

  \ RLD
  [undefined] rld [if]

    \ Dev tool: reload from the top
    : rld  ( -- )  s" dev.f" included ;

    create null-personality
      4 cells , 19 , 0 , 0 ,
      ' noop , \ INVOKE    ( -- )
      ' noop , \ REVOKE    ( -- )
      ' noop , \ /INPUT    ( -- )
      ' drop ,  \ EMIT      ( char -- )
      ' 2drop , \ TYPE      ( addr len -- )
      ' 2drop , \ ?TYPE     ( addr len -- )
      ' noop , \ CR        ( -- )
      ' noop , \ PAGE      ( -- )
      ' drop , \ ATTRIBUTE ( n -- )
      ' dup , \ KEY       ( -- char )
      ' dup , \ KEY?      ( -- flag )
      ' dup , \ EKEY      ( -- echar )
      ' dup , \ EKEY?     ( -- flag )
      ' dup , \ AKEY      ( -- char )
      ' 2drop , \ PUSHTEXT  ( addr len -- )
      ' 2drop ,  \ AT-XY     ( x y -- )
      ' 2dup , \ GET-XY    ( -- x y )
      ' 2dup , \ GET-SIZE  ( -- x y )
      ' drop , \ ACCEPT    ( addr u1 -- u2)

    : game-starter  null-personality open-personality " include main ok bye" evaluate ;
    \ Turnkey starter

    : refresh  " eventq al_flush_event_queue  rld  ok" evaluate ;

    gild
  [then]

/RND


