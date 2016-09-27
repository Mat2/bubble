include bubble/core/preamble         \ base dependencies, incl. Allegro, loaded once per session

global
64 breadth !  idiom [bub]

include bubble/core/2016             \ entitlements
include bubble/core/fixext           \ fixed point extensions
include bubble/core/display          \ basic display management
include bubble/core/border
include bubble/core/input            \ allegro input support words
include bubble/core/piston           \ the main loop
include bubble/core/gfx

: load  include ;
