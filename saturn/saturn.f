defined [bub] not nip [if] include bubble/core/core [then]

64 16 + cells struct /actorslot
320 value gfxw  \ doesn't necessarily reflect the window size.
240 value gfxh


64 breadth ! [bub] idiom [saturn]

\ engine base
import bubble/modules/nodes
import bubble/modules/pen
include saturn/display
include saturn/keyboard
include saturn/joystick
include saturn/audio
include saturn/stage


import bubble/modules/image
import bubble/modules/rect
import bubble/modules/rsort
import bubble/modules/templist
import bubble/modules/fdrill


\ graphics services
include bubble/modules/swes/swes
import bubble/modules/swes/sprites

\ load other modules
import bubble/modules/stride2d
import bubble/modules/cgrid
import bubble/modules/gameutils
import bubble/modules/wallpaper

\ load engine specific stuff
import saturn/tiled
import saturn/scripting

\ constants
actor single cam
actor single player

\ variables
0 value you  \ for collisions
#1 value cbit  \ collision flag counter
variable 'dialog  \ for now this is just a flag.

\ data
include saturn/autodata
\ auto-load data

\ more engine specific stuff
include saturn/objects
import saturn/physics
import saturn/box
include saturn/load
include saturn/zones

\ ------------------------------------------------------------------------------


:noname [ is oneInit ]
  at@  startx 2v!
  1 1 1 1 !color
  csolid# cmask !
  32768 zdepth !
  ;


: ?pointcull
  x 2v@ 2dup  cam 's x 2v@ 80 80 2-  gfxw gfxh 160 160 2+  2over 2+
  overlap? ?exit  me unload ;

: cull  0 stage all>  me class @ 'cull @ execute ;

\ --------------------------- camera/rendering --------------------------------

transform baseline

: /baseline  ( -- )
  baseline  al_identity_transform
  baseline  factor @ dup 2af  al_scale_transform
  baseline  al_use_transform  ;


\ camera stuff

create m  16 cells /allot

: camTransform  ( -- matrix )
  m al_identity_transform
  m  cam 's x 2v@ 2pfloor 2negate 2af  al_translate_transform
  m ;

: track ( -- )
  player 's x 2v@  player 's w 2v@ 2halve  2+
  gfxw gfxh 2halve  2-  extents 2clamp  cam 's x 2v! ;

: camview
  camTransform  dup  factor @ dup 2af  al_scale_transform
  al_use_transform ;


\ depth sorting

: enqueue  me , ;
: showem  ( addr -- addr )  here over ?do  i @ as  ?draw  cell +loop ;
: @zdepth  [ zdepth me - ]# + @ ;
: sort  dup here over - cell/ s>p  ['] @zdepth rsort ;
: vfilter  0 stage all>  vis @ -exit  enqueue ;
: sorted  here  vfilter  sort  showem  reclaim ;


\ rendering

: para  ;
: batch  al_hold_bitmap_drawing ;
: cls  0 0 0 clear-to-color ;
: overlays  ;
: all  0 stage all>  ?draw ;
: boxes  info @ -exit  0 stage all>  showCbox ;
: camRender
  cls  /baseline
  para  track  camview
  1 batch  sorted  overlays  0 batch
  boxes ;


\ bring the logic together

0 value #frames
: ?reload  <f7> kpressed -exit  -timer reload +timer ;
: logic  0 stage all> act ;
: saturnSim  physics  zones  ?reload  logic  multi  cull  sweep  1 +to #frames ;


\ piston config

' camRender is render
' saturnSim is sim


[defined] dev [if]
    include saturn/dev/doubledip
[then]
