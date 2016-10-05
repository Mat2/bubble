
\ requires bubble/core/core.f
\ doesn't work according to forth2012?

idiom [stranger]


cd stranger
z" Sprite-0001.png" al_load_bitmap

: celltbl  create does> swap cells + @ ; \ todo: to change the table, we'll provide a special word...
celltbl gfx
dup , dup , dup , dup ,
dup , dup , dup , dup ,
dup , dup , dup , dup ,
dup , dup , dup ,     ,


: cls  clear-to-color ;


decimal
create sizes
16 , 16 ,   16 , 32 ,   32 , 32 ,   16 , 16 ,
16 , 16 ,   16 , 32 ,   32 , 32 ,   16 , 16 ,
16 , 16 ,   16 , 32 ,   32 , 32 ,   16 , 16 ,
16 , 16 ,   16 , 32 ,   32 , 32 ,   16 , 16 ,

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

: var  create dup , cell+ immediate does> @ " me ?lit + " evaluate ;             ( total -- <name> total+cell )

\ - con = constant data
\ - not sure about 'act; for now it will be executed AFTER the task.
\ - 5 cells left over
0 var x var y var vx var vy var con var flags var 'act var 'draw
  var rs 7 cells + var ds 7 cells +
  var rsp var sp var zorder
constant /ent


\ flags
#1
    bit en#
    bit persist#
    bit unload#
    \ current animation frame (4 bits)
    \ current animation counter (4 bits)
drop

32 cells constant /slot
4096 constant #maxents
create pool  #maxents /slot * /allot
0 value whom  \ ID of me

: adr  dup #maxents >= abort" Illegal entity" /slot * pool + ;
: >id  pool - /slot / ;
: as  dup to whom  adr to me ;
: {   me >r  as ;
: }   r> dup to me  >id to whom ;
: me  me  >id ;

0 as

: flag?  flags @ and 0<> ;
: en?  en# flag? ;


: ent  ;


: ok  go  step  show  0 0 0 cls ;
ok
