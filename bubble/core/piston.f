
0 value #frames
0 value breaking?
variable showerr
variable steperr
variable info  \ enables debugging mode display
variable fs    \ is fullscreen enabled?
0 value alt?  \ part of fix for alt-enter bug when game doesn't have focus
variable lag  \ completed ticks
0 value me
variable 'go
variable 'step

: poll  pollKB  pollJoys  [defined] dev [if] pause [then] ;
: break  true to breaking? ;
: -break  false to breaking? ;

[defined] dev [if]
    : try  dup -exit ['] call catch ;
[else]
    : try  dup -exit call 0 ;
[then]

_private
    \ : alt?  e ALLEGRO_KEYBOARD_EVENT-modifiers @ ALLEGRO_KEYMOD_ALT and ;
    : ?wpos  fs @ ?exit  display #0 #0 al_set_window_position ;
    : wait  eventq e al_wait_for_event ;
    : std
      etype ALLEGRO_EVENT_DISPLAY_SWITCH_OUT = if  -timer  then
      etype ALLEGRO_EVENT_DISPLAY_SWITCH_IN = if  clearkb  +timer false to alt?  then
      etype ALLEGRO_EVENT_DISPLAY_CLOSE = if  bye  then
      etype ALLEGRO_EVENT_KEY_DOWN = if
        e ALLEGRO_KEYBOARD_EVENT-keycode @ case
          <alt>    of  true to alt?  endof
          <altgr>  of  true to alt?  endof
          <enter>  of  alt? -exit  fs toggle  endof
          <f4>     of  alt? -exit  bye  endof
          <f5>     of  refresh  endof
          <f12>    of  break  endof
          <tilde>  of  alt? -exit  info toggle  endof
        endcase
      then
      etype ALLEGRO_EVENT_KEY_UP = if
        e ALLEGRO_KEYBOARD_EVENT-keycode @ case
          <alt>    of  false to alt?  endof
          <altgr>  of  false to alt?  endof
        endcase
      then ;
    : update?  lag @ dup -exit drop  eventq al_is_event_queue_empty  lag @ 4 >= or ;
_public

: ?fs  display ALLEGRO_FULLSCREEN_WINDOW fs @ al_toggle_display_flag drop  ?wpos ;
: show  r>  update? if  ?fs  try showerr !  al_flip_display  lag off  1 +to #frames  else  drop  then ; ( -- <code> )
: ?step  etype ALLEGRO_EVENT_TIMER = if  poll  lag ++  'step @ try steperr !  then ;
: step  r>  'step ! ;  ( -- <code> )  \ has to be done this way or display update will never fire

: ok
    resetkb  -break  >gfx  +timer
    begin
        wait  begin  std  'go @ ?dup if call then  ?step  eventq e al_get_next_event not  breaking? or  until
    breaking? until
    -timer >ide  -break ;

: go  r> 'go !  'step off ;

