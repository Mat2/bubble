
0 value breaking?

defer render        \ render frame of the game
defer sim           \ run one step of the simulation of the game

variable simerr
variable renerr
variable info  \ enables debugging mode display
variable fs    \ is fullscreen enabled?
0 value alt?  \ part of fix for alt-enter bug when game doesn't have focus
variable lag  \ completed ticks

0 value me
: as  " to me" evaluate ; immediate

    include bubble/core/piston-internals

: ?redraw  lag @ -exit  update? -exit  ren  0 lag ! ; ( -- )
: show  r> code> is render  ?redraw ;
: break  true to breaking? ;
: -break  false to breaking?  clearkb ;
: go
    -break  >gfx +timer
    r> code> is sim
    begin
        wait  begin  meta  ?tick  eventq e al_get_next_event not  until
    breaking? until
    -timer >ide  -break ;

\ : ok  go  ... ;       \ simplest loop.  everything after go is executed over and over at 60hz
\ : ok  go  ... show  ... ; \ loop with fixed render that can't be overridden

