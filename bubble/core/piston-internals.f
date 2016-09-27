\ piston internals

: poll  pollKB  pollJoys ;

_private

    : ?wpos  fs @ ?exit  display #0 #0 al_set_window_position ;
    : ?fs  display ALLEGRO_FULLSCREEN_WINDOW fs @ al_toggle_display_flag drop  ?wpos ;
    : break  true to breaking? ; ( -- )

    [defined] dev [if]
        : tick  poll  ['] sim catch simerr !  lag ++ ;
        : ren  me >r  ?fs  ['] render catch renerr !  al_flip_display  r> as ;
    [else]
        : tick  poll  sim  lag ++ ;
        : ren  me >r  ?fs  render  al_flip_display  r> as ;
    [then]

    : ?switch
      etype ALLEGRO_EVENT_DISPLAY_SWITCH_OUT = if  -timer  then
      etype ALLEGRO_EVENT_DISPLAY_SWITCH_IN = if  clearkb  +timer  false to alt?  then ;

    : ?close  etype ALLEGRO_EVENT_DISPLAY_CLOSE = -exit  bye ;

    : ?kb
      etype ALLEGRO_EVENT_KEY_DOWN = if
        e ALLEGRO_KEYBOARD_EVENT-keycode @ case
          <alt>    of  true to alt?  endof
          <altgr>  of  true to alt?  endof
          <enter>  of  alt? -exit  fs toggle  endof
          <f5>     of  refresh  endof
          <escape> of  break  endof
          <tilde>  of  alt? -exit  info toggle  endof
        endcase
      then
      etype ALLEGRO_EVENT_KEY_UP = if
        e ALLEGRO_KEYBOARD_EVENT-keycode @ case
          <alt>    of  false to alt?  endof
          <altgr>  of  false to alt?  endof
        endcase
      then ;

    : ?tick   etype ALLEGRO_EVENT_TIMER = -exit  tick  ;
    : update?  eventq al_is_event_queue_empty  lag @ 4 >= or ; ( -- flag )
    : wait  eventq e al_wait_for_event ;
    : meta  ?close ?switch ?kb ;
