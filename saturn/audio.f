al_install_audio not [if] " Allegro: Couldn't initialize audio." alert -1 abort [then]
al_init_acodec_addon not [if] " Allegro: Couldn't initialize audio codec addon." alert -1 abort [then]
16 al_reserve_samples not [if] " Allegro: Error reserving samples." alert -1 abort [then]
al_restore_default_mixer  al_get_default_mixer value mixer

: sfx  ( -- <name> <path> )
  create  <zfilespec> al_load_sample ,
  does> @ 1 0 1 3af ALLEGRO_PLAYMODE_ONCE 0 al_play_sample ;
