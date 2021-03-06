\ better namespacing system

\ idioms have:
\  a parent idiom
\  accessory idioms
\  a private wordlist
\  a public wordlist

\ important words:
\   `idiom` <name>
\     creates a new idiom.  has different behavior depending on
\     if currently importing the current file.  if not importing, it creates a
\     new idiom, extending the current one (whatever it might be) so that that
\     idiom is included in the new one's search order, except for its private
\     words.  if importing, and the idiom is not already defined, it creates
\     a new idiom without extending the current one.  `import` adds it as
\     an accessory before restoring the current idiom.  if importing and the
\     idiom is already defined, compilation of the rest of the current file
\     being interpreted is cancelled.
\     the default "current" wordlist for defining words is the idiom's public
\     one.
\  `include` is extended to save and restore `idiom`, the current idiom.
\  `import` saves and restores `idiom` as well as a flag that `create-idiom`
\     uses to change its behavior.
\  `.idiom` prints info about the current idiom.  usually, idioms set the
\     search order themselves when executed.
\  `set-idiom` takes an idiom and sets the search order (it replaces it.)
\     the default "current" wordlist for defining words is the idiom's public
\     one.
\  `breadth` the variable that stores the maximum # of accesory idioms the next
\     idiom can have.  it is reset to 10 every time an idiom is created.
\  `public` - set current wordlist for defining to current idiom's "publics"
\  `private` - set current wordlist for defining to current idiom's "privates"

\ Cheatsheet:
\  Create:
\    `INCLUDE` a file that declares an idiom that isn't already defined in the current search order.
\  Enter:
\    Call the name of an idiom.  Its public and private words, predecessor's public words,
\    and imported public words, will be available.  This is the search order from first to last.
\      1) Idiom's publics
\      2) Idiom's privates
\      3) Imported idioms' publics
\      4) Predecessor idiom's publics
\  Public/Private:
\    Call `PUBLIC` and `PRIVATE` to switch between defining public and private words of the current
\    idiom.  Private words won't be available to any other idiom, unless you explicitly export them.
\  Exit:
\    There is no explicit word to "exit" an idiom.
\    Instead you enter a different idiom, or call `GLOBAL`, which turns idioms "off" and resets
\    the search order and current wordlist to `FORTH-WORDLIST`.
\  Debug:
\    Call `.IDIOM`.  The imported idioms and parents of the current idiom will be shown.
\  Inherit:
\    Declare or enter an idiom.
\    `INCLUDE` file that declares child idiom
\    This new idiom will "know" the public words of all of its predecessors.
\  Extend:
\    `INCLUDE` a file that declares an idiom that already exists in the current search order.
\     or
\    `INCLUDE` a file that at the top simply enters the idiom you want to extend.
\  Import:
\    `IMPORT` a file that declares an idiom.  If it's already defined in the current search order, it
\    will simply be imported, and the rest of the file will be skipped.
\  Isolate:
\    In a file, enter any "predecessor" idiom (or say `GLOBAL`) and then declare/extend an idiom.
\    If you `IMPORT` this file, it will be imported into the current idiom in the importing file.
\    If you `INCLUDE` this file, it will NOT be imported.
\    In both cases, the name of the isolated idiom will only be available in its parent.
\    Therefore, it can only be imported by "related" idioms.
\  Encapsulate:
\    The idioms imported by an idiom, and its parents, are NOT imported along with it
\    when impored into another idiom.  Only its public words.
\  Export:
\    The private or public wordlists of the current idiom can be given names that can
\    be automatically defined within the parent idiom or the Forth wordlist.
\    Use `@publics | @privates EXPORT-WORDLIST <name>  \ naming convention:  <idiomname>ing`
\    If for whatever reason both wordlists are desired, export the @privates and import or
\    extend the idiom.


variable 'idiom
variable breadth  8 breadth !
variable importing
variable declared

defer onSetIdiom  ' noop is onSetIdiom


: /idiom  5 cells breadth @ cells + ;
: @parent  'idiom @ @ ;
: @publics 'idiom @ cell+ @ ;
: >publics  ?dup if  cell+ @  ?dup ?exit  then  forth-wordlist ;
: @privates 'idiom @ cell+ cell+ @ ;
: others>  'idiom @ cell+ cell+ cell+ ;  \ count , idiom , idiom ....


: .name  body> >name count type space ;
: ?none  dup ?exit  ." NONE" ;
: .idiom
  cr
  'idiom @ 0= if  ." NO CURRENT IDIOM."  exit  then
  space ." IDIOM: " 'idiom @ .name
  \ space ." PARENT: " @parent ?dup if  .name  else  ." NONE " then
  space ." IMPORTS: "
  others> @+ ?none  0 ?do  @+ .name  loop
  drop
  @parent -exit
  'idiom @ >r
  @parent 'idiom ! recurse
  r> 'idiom ! ;

: _private  @privates set-current ;
: _public   @publics  set-current ;

: add-idiom  ( idiom idiom-target -- )
  'idiom @ >r   'idiom !
  others> @+ cells + !  1 others> +!
  r> 'idiom ! ;

: wordlists-  ( idiom -- )
  'idiom @ >r  'idiom !
  @publics -order
  others> @+ ?dup if  cells bounds do  i @ >publics -order  cell +loop
                  else  drop  then
  @parent ?dup if  recurse  then  \ remove parents' stuff!
  r> 'idiom ! ;

: wordlists+  ( idiom -- )
  'idiom @ >r  'idiom !
  @parent ?dup if  recurse  then  \ add parents' stuff first!
  others> @+ ?dup if  cells bounds swap cell- do  i @ >publics +order  -cell +loop
                  else  drop  then 
  @publics +order
  r> 'idiom ! ;

: get-idiom  'idiom @ ;

: global  only forth definitions  'idiom off ;

: unset-idiom  'idiom @ ?dup -exit  wordlists-  @privates -order  'idiom off ;

: set-idiom
  ?dup 0= if global exit then
  only forth
  'idiom !  'idiom @ wordlists+
  @publics -order  @privates +order  @publics +order
  onSetIdiom ;

: extend-idiom  'idiom @ swap ! ;

: (idiom)
  here  /idiom /allot  8 breadth !
  ( idiom )  dup extend-idiom  dup 'idiom !  declared !
  wordlist 'idiom @ cell+ !
  wordlist 'idiom @ cell+ cell+ !
  'idiom @ set-idiom  _public ;

: idiom
  >in @  defined  if   nip  >body  importing @ if  declared ! \\ exit              \ already defined, importing     => cancel compilation
                                               else  set-idiom  _public  exit  then \ already defined, not importing => enter / don't create
                  else  drop  >in !  then
  create  (idiom)  does>  set-idiom  _public ;                                      \ not defined, create


: strip-order  get-idiom >r unset-idiom forth-wordlist -order get-order forth-wordlist +order r> set-idiom ;


: +orders  dup >r  reverse  r>  0 ?do  +order  loop ;

: import
  'idiom @ 0= abort" Can't IMPORT while not inside an idiom!"
  declared @ >r  strip-order  get-current >r  get-idiom >r  importing @ >r  importing on  ['] include catch  r> importing !  throw  declared @ r@ add-idiom  r> set-idiom  r> set-current  +orders  r> declared ! ;
: include
  'idiom @ 0= if  include  exit then
  declared @ >r  strip-order  get-current >r  get-idiom >r  include  r> set-idiom r> set-current  +orders  r> declared ! ;


\ create an exposed wordlist out of @publics or @privates in the parent's public wordlist.
\ useful for creating wordlists that can be cherrypicked onto the search order in special cases.
: export-wordlist  ( wordlist -- <name> )
  get-current >r  @parent >publics set-current  constant
  r> set-current ;

: empty  global empty ;

\\
marker discard
  idiom i1
  i1
  import test/bear
  import test/fox
  .idiom
  idiom i2
  i2
  .idiom
discard

global

