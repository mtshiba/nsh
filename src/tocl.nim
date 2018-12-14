import os
import osproc
import strutils
import strformat

from nsh import newShell, delOnce

let varName = commandLineParams()[0]
var shell = newShell()


let f = open(getHomeDir() & "/nshcathe/repl.nims", fmRead)
shell.code = f.readAll()
shell.delOnce()
f.close

let fwrite = open(getHomeDir() & "/nshcathe/repl.nims", fmWrite)
fwrite.write(shell.code & "\nonce " & varName)
fwrite.close

var errc = execCmd(fmt"nim e -r --checks:off --hints:off --verbosity:0 {getHomeDir()}/nshcathe/repl.nims")

let f2 = open(getHomeDir() & "/nshcathe/repl.nims", fmRead)
var
    code = f2.readAll()
f2.close
shell.code = code
shell.delOnce()

let f2write = open(getHomeDir() & "/nshcathe/repl.nims", fmWrite)
f2write.write(shell.code)
f2write.close

quit(errc)
