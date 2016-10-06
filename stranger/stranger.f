
\ require bubble/core/core.f
\ `require` doesn't work in swiftforth

idiom [stranger]
cd stranger

\ -------------------------------------------------------------------------------------------------

z" Sprite-0001.png" al_load_bitmap

: celltbl  create does> swap cells + @ ; \ todo: to change the table, we'll provide a special word...
celltbl gfx
dup , dup , dup , dup ,
dup , dup , dup , dup ,
dup , dup , dup , dup ,
dup , dup , dup ,     ,

\ -------------------------------------------------------------------------------------------------

: cls  clear-to-color ;

\ -------------------------------------------------------------------------------------------------

decimal
create sizes
16 , 16 ,   32 , 32 ,    64 , 64 ,    128 , 128 ,
16 , 32 ,   16 , 64 ,    32 , 64 ,    64 , 128 ,
32 , 16 ,   64 , 16 ,    64 , 32 ,    128 , 64 ,
48 , 48 ,   128 , 256 ,  256 , 128 ,  256 , 256 ,

: @size  2 cells * sizes + 2v@ ;

: iaf  s>f 1sf ;
: 2iaf  2s>f 2sf ;

: ic  ( gfxspec -- )  \ gfx = AARF SBII
    >r
    r@ $f00 and 8 rshift cells gfx \ source
    r@ $f and 4 lshift iaf \ sx
    r@ $f0 and         iaf \ sy
    r@ $f000 and 12 rshift @size 2iaf \ sw,sh
    at@ 2af \ dx,dy
    r> $30000 and 16 rshift
    al_draw_bitmap_region
;
fixed

\ -------------------------------------------------------------------------------------------------
: var  create dup , cell+ immediate does> @ " me ?lit + " evaluate ;             ( total -- <name> total+cell )

\ - con = constant data
\ - not sure about 'act; for now it will be executed AFTER the task.
\ - 5 cells left over
0 var x var y var vx var vy var con var flags var 'act var 'draw
  var rs 7 cells + var ds 7 cells +
  var rp var sp var zorder
value /ent


\ flags
#1
    bit en#
    bit vis#
    bit persist#
    bit unload#
    \ current animation frame (4 bits)
    \ current animation counter (4 bits)
drop

\ -------------------------------------------------------------------------------------------------

32 cells constant /slot
4096 constant #maxents
create pool  #maxents /slot * /allot
0 value whom  \ ID of me

: adr  dup 0 < over #maxents >= or abort" Illegal entity" /slot * pool + ;
: >id  pool - /slot / ;
: as  dup to whom  adr to me ; 0 as
\ : {   me >r  as ;
\ : }   r> dup to me  >id to whom ;
: me  me  >id ;
: nxt  whom 1 + 4095 and as ;
: flag?  flags @ and 0<> ;
: en?  en# flag? ;
: set  flags or! ;
: unset  flags not! ;
: draw  r> 'draw ! ;
: act   r> 'act ! ;
: init  en# vis# or flags !  0 0 vx 2v!  at@ x 2v!  act draw noop ;
: new  4096 0 do  en? 0= if init unloop exit then  nxt loop  -1 abort" Out of entities" ;
: single  new me constant  persist# set ;

\ -------------------------------------------------------------------------------------------------

single main

: perform ( n -- <code> )
    ds 7 cells + !
    ds 6 cells + sp !
    r> rs 7 cells + !
    rs 7 cells + rp !
;

\ important: this word must not CALL anything or use the return stack until the bottom part.
: yield
    \ save state
    dup \ ensure TOS is on stack
    sp@ sp !
    rp@ rp !
    \ look for next task/actor.  rp=0 means no task.  end of list = jump to main task and resume that
    begin  nxt  me main = if  rp @  else  main to me  true  then  until
    \ restore state
    rp @ rp!
    sp @ sp!
    drop \ ensure TOS is in TOS register
;

: end  0 rp! yield ;
: frames  0 do yield loop ;
: secs  60 * frames ;
: multi
    me >r
    dup
    stage first @ main next !
    sp@ main 's sp !
    rp@ main 's rp !
    main to me
    ['] yield catch
    ?dup if
        main to me
        rp @ rp!
        sp @ sp!
        drop
        throw
    then
    drop
    r> as
;
\ : :proc  actor single :noname 'act ! ;
\ : :task  actor single :noname 0 me perform ;

\ -------------------------------------------------------------------------------------------------





\ -------------------------------------------------------------------------------------------------

: ok  go  step  show  0 0 0 cls ;
ok
