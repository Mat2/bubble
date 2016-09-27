list stage
list backstage
\ : var  create dup , cell +  does> @ me + ;                                      ( total -- <name> total+cell )
: field  create over , + immediate does> @ " me ?lit + " evaluate ;             ( total -- <name> total+cell )
         \ faster but less debuggable version
: var  cell field ;

node super
  var vis  var x  var y    var vx  var vy
  var zdepth   \ not to be confused with z position - it's for drawing order.
  var 'act  var 'show  \ <-- internal
  var flags
  staticvar 'onStart  \ kick off script
  staticvar 'onInit   \ initialize any default vars that onStart expects.
                      \ We need this because loading from a map file
                      \ can override some default values.
class actor

#1
  bit persistent#
  bit restart#
  bit unload#
value actorBit

defer oneInit  ' noop is oneInit


: set?  flags @ and ;
: unset?  flags @ and 0= ;

: start  restart# flags not!  me class @ 'onStart @ execute ;
: draw  r> code> 'show !  vis on ;                                             ( -- <code> )
: ?draw  'show @ execute ;
: act   r> code> 'act ! ;                                                      ( -- <code> )
: ?act   restart# set? if  start  then  'act @ execute ;
: itterateActors  ( xt list -- )  ( ... -- ... )
  me >r
  first @  begin  dup while  dup next @ >r  over >r  as execute  r> r> repeat
  2drop
  r> as ;
: all>  ( n list -- )  ( n -- n )  r> code>  swap itterateActors  drop ;
: (recycle)  dup >r backstage popnode dup r> sizeof erase ;
: init  restart# flags or!  me class @ 'onInit @ execute ;
: one                                                                           ( class -- me=obj )
  backstage length @ if  (recycle)  else  here /actorslot /allot  then
  dup stage add
  as
  at@ x 2v!
  me class !  oneInit  init ;
: become  ( class -- )  me class !  init ;

: 's
  state @ if
    " me >r  as " evaluate  bl parse evaluate  " r> as" evaluate
  else
    " me swap as " evaluate  bl parse evaluate  " swap as" evaluate
  then
  ; immediate

: abandon  me dup parent @ remove ;
: sweep    0 stage all>  unload# set? -exit
           unload# flags not!
           abandon
           persistent# unset? if  me backstage add  then ;
: unload  unload# swap 's flags or! ;

\ clear everything from stage except persistent stuff.
: cleanup  backstage stage graft  0 backstage all>  persistent# set? -exit   me stage add ;  \ put persistent actors back onstage

\ clear everything from stage including persistent stuff.  persistent stuff is not sent to BACKSTAGE.
: clear  backstage stage graft  0 backstage all>  persistent# set? -exit  abandon ;  \ orphan persistent actors

: #actors  stage length @ ;

: script  ( adr c -- class )  \ load actor script if not loaded
  2dup forth-wordlist search-wordlist if  nip nip execute  else
  2dup " objpack-sc/" s[ +s " .f" +s ]s included  evaluate  then ;


