empty



[undefined] dev [if] 
    s" envconfig.f" file-exists [if]
        include envconfig.f
    [then]
    true constant dev gild 
[then]

\ include bubble/core/core
\ include saturn/saturn
\ include bubble/dev/ide  [ide] focus on
include dumbtest/main
