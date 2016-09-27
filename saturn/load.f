create map  #256 allot
create dropPoint 0 , 0 ,

: /dropPoint  100 100 dropPoint 2v! ;

: cleanup  ( -- )  cleanup  boxGrid resetGrid  dynGrid resetGrid ;

: findmap  " data/maps/" s[  bl parse +s  " .tmx" +s  ]s ;

: load  ( -- <name> ) \ load a map.  no .tmx required
  /dropPoint  cleanup  findmap 2dup  loadtmx  map place  dropPoint 2v@ player put ;

: reload  cleanup  map count loadtmx ;
