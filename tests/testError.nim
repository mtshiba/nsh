import nishpkg/unixcmd


proc err() =
    raise newException(OSError, "")

var a = 1
proc safe() =
    a += 1

safe() || err() && safe()
