requires bubble/core/core.f

[bub] idiom [ide]
import bubble/modules/pen
include dev/ide/blend

[defined] linux [if]

[else]
    requires bubble/lib/win-clipboard.f
[then]

z" dev/data/consolas16.png" al_load_bitmap_font constant consolas

consolas constant sysfont
8 constant fw
16 constant fh

_private
    0  xvar x  xvar y  4 cells xfield color  struct /cursor
    variable cx variable cy variable cw variable ch
_public

variable 'go     \ game
variable 'show   \ game
variable 'step   \ game
variable pause
variable focus   \ true = CLI has focus
create testbuffer #256 /allot
create history  #256 /allot
create ch  0 c, 0 c,
\ margins
320 value lm
: rm  displayw 2 / ;
: bm  displayh 2 / fh 2 * - ;
create cursor  cursor /allot  lm cursor x !
1 1 1 1 cursor color ~!+ ~!+ ~!+ ~!+ drop
nativew nativeh 2i al_create_bitmap value output
variable scrolling  scrolling on
transform baseline



: ?call  ?dup -exit call ;
: ?.catch  ?dup -exit .catch ;


: recall  history count testbuffer place ;
: store   testbuffer count history place ;
: typechar  testbuffer count + c!  #1 testbuffer c+! ;
: interp    testbuffer count 2dup type space  evaluate ;
: rub       testbuffer c@  #-1 +  0 max  testbuffer c! ;
: obey     store  ['] interp catch ?.catch cr testbuffer off  ;
: paste     clpb testbuffer append ;


\ doesn't seem to function in fullscreen.  (Allegro bug?)
: ?paused  pause @ if  -timer  else  +timer  then ;

: keycode  e ALLEGRO_KEYBOARD_EVENT-keycode @ ;
: unichar  e ALLEGRO_KEYBOARD_EVENT-unichar @ ;

: special
  case
    [char] v of  paste  endof
    [char] p of  pause toggle  endof
  endcase ;

_private
  : ctrl?  e ALLEGRO_KEYBOARD_EVENT-modifiers @ ALLEGRO_KEYMOD_CTRL and ;
  : alt?  e ALLEGRO_KEYBOARD_EVENT-modifiers @ ALLEGRO_KEYMOD_ALT and ;
_public

: idekeys
  etype case
    ALLEGRO_EVENT_KEY_DOWN of
      keycode dup #37 < if  drop exit  then
      case
        <tab> of  focus toggle  endof
      endcase
    endof
    ALLEGRO_EVENT_KEY_CHAR of
      ctrl? if
          unichar $60 + special
      else
        focus @ -exit
        unichar #32 >= unichar #126 <= and if
            unichar typechar  exit
        then
        keycode case
          <up> of  recall  endof
          <down> of  testbuffer off  endof
          <enter> of  alt? ?exit  obey  endof
          <backspace> of  rub  endof
        endcase
      then
    endof
  endcase
;

\ ----------------------------- console output --------------------------------

: ?half  focus @ if 1 else 0.5 then ;
: console  output  1 1 1 ?half  4af  at@ 2af  0  al_draw_tinted_bitmap ;
: console-get-xy  ( -- #col #row )  cursor x 2v@ fw fh 2/ 2i ;
: console-at-xy   ( #col #row -- )  2s>p fw fh 2* cursor x 2v! ;

: onto  r>  al_get_target_bitmap >r  swap al_set_target_bitmap call  r> al_set_target_bitmap ;

: clear  ( x y w h )
  write-rgba blend
  output onto  2over 2+ 1 1 2+ 4af   0 1af dup dup dup  al_draw_filled_rectangle
;

: outputw  displayw 2 / ;
: outputh  displayh 2 / ;


: stack
  lm  outputh fh - fh -   rm lm - fh   clear
    scrolling off
        get-xy 2>r  0 outputh fh / 2 - 2i at-xy  .s  2r> at-xy
    scrolling on ;

: scroll
  lm  outputh fh - fh - 4 +   rm lm - fh   clear
  write-rgba blend
  output onto  output 0 fh negate 2af 0 al_draw_bitmap
  fh negate cursor y +!
;

: console-cr
    lm cursor x !
    fh cursor y +!
    scrolling @ -exit
    cursor y @ bm >= if  scroll  then
;

: 4@af  @+ swap @+ swap @+ swap @+ nip 4af ;

: (emit)
  ch c!  0 ch #1 + c!
    sysfont  cursor color 4@af  cursor x 2v@ 2af  0  ch al_draw_text
    fw cursor x +!
    cursor x @ rm >= if  console-cr  then
;

: console-emit  output onto  (emit) ;

decimal
: console-type  bounds  do  i @ console-emit  loop ;
fixed

create colors
  1 , 1 , 1 , 1 ,
  0 , 0 , 0 , 1 ,
  0.3 , 1 , 0.3 , 1 ,
  1 , 1 , 0.3 , 1 ,
: (attribute)  s>p 4 cells * colors +  cursor color  4 cells move ;


create console-personality
  4 cells , #19 , 0 , 0 ,
  ' noop , \ INVOKE    ( -- )
  ' noop , \ REVOKE    ( -- )
  ' noop , \ /INPUT    ( -- )
  ' console-emit , \ EMIT      ( char -- )
  ' console-type , \ TYPE      ( addr len -- )
  ' console-type , \ ?TYPE     ( addr len -- )
  ' console-cr , \ CR        ( -- )
  ' noop , \ PAGE      ( -- )
  ' (attribute) , \ ATTRIBUTE ( n -- )
  ' dup , \ KEY       ( -- char )
  ' dup , \ KEY?      ( -- flag )
  ' dup , \ EKEY      ( -- echar )
  ' dup , \ EKEY?     ( -- flag )
  ' dup , \ AKEY      ( -- char )
  ' 2drop , \ PUSHTEXT  ( addr len -- )
  ' console-at-xy ,  \ AT-XY     ( x y -- )
  ' console-get-xy , \ GET-XY    ( -- x y )
  ' 2dup , \ GET-SIZE  ( -- x y )
  ' drop , \ ACCEPT    ( addr u1 -- u2)

\ -------------------------------- IDE display --------------------------------

: framed
  cx cy cw ch al_get_clipping_rectangle
  0 0 #640 #480 al_set_clipping_rectangle   r> call
  cx @ cy @ cw @ ch @ al_set_clipping_rectangle ;  ( -- <code> )

: much  if 0.8 else 0.4 then ;
: ?focusbg  steperr @ much  0.4  showerr @ much ;
: cls  focus @ if  ?focusbg  else  0 0.3 0  then clear-to-color ;

\ : ?show
\   pause @ if
\     'show @ ?call
\   else
\     lag @ -exit  update? -exit  'show @ ?call  0 lag !
\   then ;

: /baseline
  baseline  al_identity_transform
  baseline  factor @ dup 2af  al_scale_transform
  baseline  al_use_transform  ;

: ?_  focus @ -exit  #frames 16 and -exit  s[ [char] _ c+s ]s ;

: commandline
\  write-rgba blend
  sysfont  ?half dup dup 1 4af  at@ 2af  0  testbuffer count ?_ zstring  al_draw_text ;

: ui
  /baseline
  0 0 at  console
  320  nativeh 2 / fh -  at  commandline
  stack
;

\ filter out mouse, joy, keyboard events when focused
: thru?  focus @ if  etype ALLEGRO_EVENT_TIMER >=  else  true  then ;
: ?clearkb  focus @ if clearkb then ;

: ide-step  step  ?clearkb  'step @ ?call ;
: ide-events  thru? if  'go @ ?call  then  idekeys ;
: game  framed  'show @ ?call ;
: ide-show  show  cls  game  ui ;

: big  ( display #1280 #960 al_resize_display drop ) fs on ;
: little  fs off  ?fs  display #640 #480 al_resize_display drop  ;
: /ide  big  console-personality open-personality  focus on  go  ( ?paused )  ide-events  ide-step  ide-show ;
: ide/  little  close-personality  ;
: ide  /ide  ok  ide/ ;  

\ redefine all the things
: ok  ;
: go  r> 'go ! ;
: show  r> 'show ! ;
: step  r> 'step ! ;
: empty  close-personality  empty ;

ide
