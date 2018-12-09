import os
import osproc
import strutils
import strformat

from nsh import newShell, delOnce

let varName = commandLineParams()[0]
var shell = newShell()


let f = open(getHomeDir() & "/nshcathe/repl.nim", fmRead)
shell.code = f.readAll()
shell.delOnce()
f.close

let fwrite = open(getHomeDir() & "/nshcathe/repl.nim", fmWrite)
fwrite.write(shell.code & "\nonce " & varName)
fwrite.close

var (outs, errc) = execCmdEx(fmt"nim c -r --cc:tcc --checks:off --hints:off --verbosity:0 {getHomeDir()}/nshcathe/repl")
if errc != 0:
    (outs, errc) = execCmdEx(fmt"nim c -r --hints:off --checks:off --verbosity:0 {getHomeDir()}/nshcathe/repl")

let f2 = open(getHomeDir() & "/nshcathe/repl.nim", fmRead)
var
    code = f2.readAll()
f2.close
shell.code = code
shell.delOnce()

let f2write = open(getHomeDir() & "/nshcathe/repl.nim", fmWrite)
f2write.write(shell.code)
f2write.close

echo outs

quit(errc)
