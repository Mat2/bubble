\ display
\   need only one
\   if in the future we need more ... i don't think there's much kus from supporting them

0 value defaultFont
0 value displaytimer
0 value fps
0 value allegro?
0 value eventq
0 value display

\ --------------------------- initializing allegro ----------------------------

: assertAllegro
  allegro? ?exit
  true to allegro?
  al_init
  not if  " INIT-ALLEGRO: Couldn't initialize Allegro." alert     -1 abort then
  al_init_image_addon
  not if  " Allegro: Couldn't initialize image addon." alert      -1 abort then
  al_init_primitives_addon
  not if  " Allegro: Couldn't initialize primitives addon." alert -1 abort then
  al_init_font_addon
  not if  " Allegro: Couldn't initialize font addon." alert       -1 abort then
  al_install_mouse
  not if  " Allegro: Couldn't initialize mouse." alert            -1 abort then
  al_install_keyboard
  not if  " Allegro: Couldn't initialize keyboard." alert         -1 abort then
  al_install_joystick
  not if  " Allegro: Couldn't initialize joystick." alert         -1 abort then

  al_create_event_queue  to eventq
;

assertAllegro

\ -------------------- starting/stopping the frame timer ----------------------

: +timer  displaytimer al_start_timer ;
: -timer  displaytimer al_stop_timer ;

\ ----------------------- initializing the display ----------------------------

: initDisplay  ( w h -- )
  assertAllegro
  ALLEGRO_VSYNC #1 ALLEGRO_SUGGEST  al_set_new_display_option
  #0 #40 al_set_new_window_position

  0
    ALLEGRO_WINDOWED or
    ALLEGRO_RESIZABLE or
    ALLEGRO_OPENGL_3_0 or
    al_set_new_display_flags

  2i  al_create_display  to display
  al_create_builtin_font to defaultFont
  eventq  display       al_get_display_event_source  al_register_event_source

  displaytimer not if
    1e
      display al_get_display_refresh_rate s>p
      ?dup 0= if 60 then
      dup to fps
      f f/ 1df al_create_timer
        to displaytimer
      eventq  displaytimer  al_get_timer_event_source    al_register_event_source
      eventq                al_get_mouse_event_source    al_register_event_source
      eventq                al_get_keyboard_event_source al_register_event_source
  then
  ;

: valid?  ['] @ catch nip 0 = ;

fixed
: +display  display valid? ?exit  640 480 initDisplay ;
: -display  display valid? if  display al_destroy_display  then  0 to display ;


\ ------------------------ words for switching windows ------------------------
: focus  ( winapi-window - )                                                    \ force window via handle to be the active window
  dup #1 ShowWindow drop  dup BringWindowToTop drop  SetForegroundWindow drop ;
: >gfx  ( - )  display al_get_win_window_handle focus ;                         \ force allegro display window to take focus
: >ide  ( - )  HWND focus ;                                                     \ force the Forth prompt to take focus
>ide






\ some meta-compilation systems management stuff
: teardown  -display ; \ al_uninstall_system ;
: empty   teardown only forth empty ;



create native  /ALLEGRO_DISPLAY_MODE /allot
  al_get_num_display_modes #1 -  native  al_get_display_mode

: nativew   native x@ s>p ;
: nativeh   native y@ s>p ;
: displayw  display al_get_display_width s>p ;
: displayh  display al_get_display_height s>p ;


+display


