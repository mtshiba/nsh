import strutils
import strformat
import ospaths
import algorithm

const version = "0.3.1"

using args: varargs[string]

type
    Error = object of Exception
    CLIstring = distinct string


let batDir = staticExec("where nsh").split("\n")[0].replace("\\bin\\nsh", "") & "\\pkgs\\nsh-" & version

proc staticWrite(str, fileName: string) =
    var repstr = str
    while repstr[^1] == '\n':
        repstr = str[0..^2]
    if existsFile(fileName):
        exec(fmt"rm {fileName}")
    for i in repstr.split("\n"):
        exec(fmt"""{batDir}\apd.bat {fileName} echo {i}""")
proc staticAppend(str, fileName: string) =
    var repstr = str
    while repstr[^1] == '\n':
        repstr = str[0..^2]
    for i in repstr.split("\n"):
        exec(fmt"""{batDir}\apd.bat {fileName} echo {i}""")


template raiseError(errc= -1) =
    raise newException(Error, "command failed with code " & $errc)
template joinArgs(args: varargs[string], sep: string): string =
    var s = ""
    for arg in args:
        s &= arg & sep
    s.delete(s.high-sep.len, s.high)
    s
template once(state: void): void = discard
template once[T: not void](arg: T): void =
    echo arg
template once(args: varargs[untyped]): void =
    echo args

proc `[]`*[T, U](s: CLIstring; x: HSlice[T, U]): CLIstring =
    CLIstring(string(s)[x])
proc `$`*(s: CLIstring): string {.borrow.}
proc split*(cliS: CLIstring, s: string): seq[string] = split($cliS, s)

proc toInt*(x: int): int = x

iterator items*(cliS: CLIstring): string =
    let lines = cliS.split("\n")
    for l in lines:
        yield l

proc addhist(com: string) =
    staticAppend(com, fmt"{getHomeDir()}nshcathe/hist.cfg")

proc getidx(): int =
    let res = staticRead(fmt"{getHomeDir()}nshcathe/hist.cfg").split("\n")
    return res[^2].split(" ")[0].replace("\"", "").parseInt

proc execute(cmdName: string, args): CLIstring =
    let cmd = cmdName & " " & args.join(" ")
    addhist(fmt""""{getidx()+1} {cmd}" """)
    exec(fmt"rm {getHomeDir()}nshcathe\res.txt")
    exec(fmt"{batDir}\apd.bat {getHomeDir()}\nshcathe\res.txt {cmd}")
    return CLIstring(staticRead(fmt"{getHomeDir()}\nshcathe\res.txt"))

# proc guess(s: string): string = discard
# proc cguess(s: cstring, buflen: cint): cstring  = discard


# `>` has already registered. This can't use generics.
template `>`*(x: string, fileName: untyped): untyped =
    staticWrite(x, astToStr(fileName))
template `>`*(x: CLIstring, fileName: untyped): untyped =
    staticWrite($x, astToStr(fileName))

template `>>`*[T: string or CLIstring](x: T, fileName: untyped): untyped =
    staticAppend($x, astToStr(fileName))

proc `!`*(idx: int): CLIstring =
    let f = staticRead(getHomeDir() & "/nshcathe/hist.cfg")
    var l = f.split("\n").reversed
    for line in l:
        if line.replace("\"", "").split(" ")[0] == $idx:
            addhist("\"" & $(getidx()+1) & " " & line.replace("\n", "").split(" ")[1..^1].join(" ") & "\"")
            exec(fmt"""{batDir}/apd.bat {getHomeDir()}/nshcathe/res.txt {line.split(" ")[1..^1].join(" ")}""")
            let res = staticRead(getHomeDir() & "/nshcathe/res.txt")
            return CLIstring(res)
proc `!`*(com: string): CLIstring =
    let f = staticRead(getHomeDir() & "/nshcathe/hist.cfg")
    var l = f.split("\n").reversed
    for line in l:
        if line.find(com) != -1:
            addhist("\"" & $(getidx()+1) & " " & line.replace("\"", "").split(" ")[1..^1].join(" ") & "\"")
            exec(fmt"""{batdir}/apd.bat {getHomeDir()}/nshcathe/res.txt {line.split(" ")[1..^1].join(" ")}""")
            let res = staticRead(getHomeDir() & "/nshcathe/res.txt")
            return CLIstring(res)



template `||`*(x, y: untyped) =
    try:
        x
    except:
        y

template `&&`*(x, y: untyped) =
    try:
        x
        y
    except:
        raiseError()


proc pwd*(): CLIstring =
    addhist(fmt"{getidx()+1} pwd" & "\n")
    return CLIstring(getCurrentDir())

proc rm*(args) =
    discard execute("rm", args)

proc ls*(args): CLIstring =
    execute("ls", args)

proc mkdir*(args) =
    discard execute("mkdir", args)

proc rmdir*(args) =
    echo execute("rmdir", args)

proc cp*(args) =
    echo execute("cp", args)

proc mv*(args) =
    echo execute("mv", args)

proc pushd*(args) =
    echo execute("pushd", args)

proc popd*() =
    echo execute("popd")

proc cat*(args): CLIstring =
    execute("cat", args)

proc touch*(args) =
    echo execute("touch", args)

proc file*(args): CLIstring =
    execute("file", args)

proc ffind*(args): CLIstring =
    execute("find", args)

proc locate*(args): CLIstring =
    execute("locate", args)

proc more*(args): CLIstring =
    {.hint: "this proc is different from the behavior at the terminal.".}
    execute("more", args)

proc less*(args): CLIstring =
    {.hint: "this proc is different from the behavior at the terminal.".}
    execute("less", args)

when not defined(windows):
    proc lv*(args): CLIstring =
        {.hint: "this proc is different from the behavior at the terminal.".}
        execute("lv", args)

proc head*(args): CLIstring =
    execute("head", args)

proc tail*(args): CLIstring =
    execute("tail", args)

proc grep*(args): CLIstring =
    execute("grep", args)
proc grep*(fileName: CLIstring, args): CLIstring =
    let argsStr = args.join(" ")
    addhist(fmt""""{getidx()+1} cat someFile | grep {argsStr}" """)
    staticWrite($fileName, getHomeDir() & "nshcathe\\log.txt")
    # Erase the command executed on the command line
    exec(fmt"""{batDir}\pipe.bat {getHomeDir()}nshcathe\res.txt {getHomeDir()}nshcathe\log.txt sed -e 's/\r//' grep {argsStr}""")
    return CLIstring(staticRead(fmt"{getHomeDir()}nshcathe\res.txt"))

proc wc*(args): CLIstring =
    execute("wc", args)
proc wc*(fileName: CLIstring, args): CLIstring =
    let argsStr = args.join(" ")
    addhist(fmt""""{getidx()+1} cat someFile | wc {argsStr}" """)
    staticWrite($fileName, getHomeDir() & "nshcathe\\log.txt")
    exec(fmt"""{batDir}\pipe.bat {getHomeDir()}nshcathe\res.txt {getHomeDir()}nshcathe\log.txt sed -e 's/\r//' wc {argsStr}""")
    return CLIstring(staticRead(fmt"{getHomeDir()}nshcathe\res.txt"))

proc sed*(args): CLIstring =
    execute("sed", args)
proc sed*(cliS: CLIstring, args): CLIstring =
    let argsStr = args.join(" ")
    addhist(fmt""""{getidx()+1} cat someFile | sed {argsStr}" """)
    staticWrite($cliS, getHomeDir() & "nshcathe\\log.txt")
    exec(fmt"""{batDir}\pipe.bat {getHomeDir()}nshcathe\res.txt {getHomeDir()}nshcathe\log.txt sed -e 's/\r//' sed {argsStr}""")
    return CLIstring(staticRead(fmt"{getHomeDir()}nshcathe\res.txt"))


proc tee*(args): CLIstring =
    execute("tee", args)
proc tee*(cliS: CLIstring, args): CLIstring =
    let argsStr = args.join(" ")
    addhist(fmt""""{getidx()+1} cat someFile | tee {argsStr}" """)
    staticWrite($cliS, getHomeDir() & "nshcathe\\log.txt")
    exec(fmt"""{batDir}\pipe.bat {getHomeDir()}nshcathe\res.txt {getHomeDir()}nshcathe\log.txt sed -e 's/\r//' tee {argsStr}""")
    return CLIstring(staticRead(fmt"{getHomeDir()}nshcathe\res.txt"))

proc fjoin*(args): CLIstring =
    execute("join", args)

proc diff*(args): CLIstring =
    execute("diff", args)

proc cut*(args): CLIstring =
    execute("cut", args)

proc uniq*(args): CLIstring =
    execute("uniq", args)

proc sort*(args): CLIstring =
    execute("sort", args)

proc nkf*(args): CLIstring = discard

proc history*(): CLIstring =
    addhist(fmt""""{getidx()+1} history" """)
    return CLIstring(staticRead(getHomeDir() & "nshcathe/hist.cfg").replace("\"", ""))

proc ps*(args): CLIstring =
    execute("ps", args)

proc jobs*(): CLIstring = discard

proc kill*[T: string or int](option: string, pid: T) =
    discard execute("kill", option, $pid)

proc lp*(option, fileName: string) =
    addhist(fmt"{getidx()+1} lp {option} {fileName}" & "\n")
    when defined(windows):
        var com = ""
        let ipconfig = option.split(" ").find("-S")
        if ipconfig != -1:
            com &= fmt"""open {option.split(" ")[ipconfig+1]}""" & "\n"
        com &= fmt"put {fileName}"
        staticWrite(com, getHomeDir() & "nshcathe/ftpcom.txt")
        exec(fmt"ftp -s:{getHomeDir()}nshcathe/ftpcom.txt")
    else:
        exec(fmt"lp {option} {fileName}")

proc lpstat*() =
    addhist(fmt"{getidx()+1} lpstat" & "\n")
    when defined(windows):
        staticWrite("status", getHomeDir() & "nshcathe/ftpcom.txt")
        exec(fmt"ftp -s:{getHomeDir()}nshcathe/ftpcom.txt")
    else:
        exec("lpstat")

proc cancel*() =
    when defined(windows):
        raise newException(Error, "this proc isn't available")
    else:
        addhist(fmt"{getidx()+1} cancel" & "\n")
        exec("cancel")

proc yppasswd*() = discard

proc chmod*(args) =
    when defined(windows):
        raise newException(Error, "this proc isn't available")
    else:
        discard execute("chmod", args)

proc xlock*(args) =
    when defined(windows):
        raise newException(Error, "this proc isn't available")
    else:
        discard execute("xlock", args)

proc last*() =
    when defined(windows):
        raise newException(Error, "this proc isn't available")
    else:
        discard execute("last")

proc du*(args): CLIstring =
    execute("du", args)

proc ln*(args) =
    discard execute("ln", args)

# TODO: implemention
proc telnet*(host: string) = discard

proc ssh*(host: string): CLIstring = discard

proc scp*(args): CLIstring = discard

proc sftp*(user_host: string): CLIstring = discard

proc man*(args): CLIstring =
    execute("man", args)

proc which*(args): CLIstring =
    execute("which", args)

proc tar*(args): CLIstring =
    execute("tar", args)

proc id*(args): CLIstring =
    execute("id", args)

proc gunzip*(args): CLIstring = discard

proc shutdown*(args) =
    discard execute("shutdown", args)

proc reboot*() =
    when defined(windows):
        exec("shutdown -r")
    else:
        execute("reboot")

proc hostname*(): CLIstring =
    execute("hostname")

proc groups*(): CLIstring =
    execute("groups")

proc chown*(args): CLIstring =
    execute("chown", args)

proc chgrp*(args): CLIstring =
    execute("chgrp", args)

proc useradd*(user: string) =
    when defined(windows):
        raiseError()
    else:
        discard execute(fmt"useradd {user}")

proc userdel*(user: string) =
    when defined(windows):
        raiseError()
    else:
        discard execute(fmt"userdel {user}")

proc groupadd*(user: string) =
    when defined(windows):
        raiseError()
    else:
        discard execute(fmt"groupadd {user}")

proc groupdel*(user: string) =
    when defined(windows):
        raiseError()
    else:
        discard execute(fmt"groupdel {user}")

proc who*(args): CLIstring =
    execute("who", args)

proc whoami*(args): CLIstring =
    execute("whoami", args)

proc vset*(args): CLIstring =
    execute("vset", args)

proc printenv*(args): CLIstring =
    execute("printenv", args)

proc vexport*(name: string) = discard
    #[let
        f = open("config/variables.cfg")
        vars = f.readAll().split("\n")
    for v in vars:
        if v.find(name) != -1:
            execProcess("set")]#
proc vexport*() = discard

proc watch*(args): CLIstring =
    execute("watch", args)

proc stty*(args): CLIstring =
    execute("stty", args)

proc date*(args): CLIstring =
    execute("date", args)

proc sleep*[T: not string](sec: T) =
    discard execute("sleep", $(sec*1000))
proc sleep*(sec: string) =
    if sec.find(".") == -1:
        discard execute("sleep", $(sec.parseInt*1000))
    else:
        discard execute("sleep", $((sec.parseFloat*1000).toInt))

template xargs*(input: CLIstring, cmd: untyped, args: varargs[string]): CLIstring =
    staticWrite($input, getHomeDir() & "nshcathe/log.txt")

    var cmdName = ""
    case astToStr(cmd)
    of "ffind":
        cmdName = "find"
    of "vset":
        cmdName = "set"
    of "vexport":
        cmdName = "export"
    else:
        cmdName = astToStr(cmd)

    var res: CLIstring
    if args.len == 0:
        addhist("\"" & `$`(getidx()+1) & " xargs " & cmdName & "\"")
        exec(batdir & "\\pipe.bat " & getHomeDir() & "nshcathe\\res.txt " & getHomeDir() & "nshcathe\\log.txt sed -e 's/\\r//' xargs " & cmdName)
        res = CLIstring(staticRead(getHomeDir() & "nshcathe\\res.txt"))
    else:
        addhist("\"" & `$`(getidx()+1) & " xargs " & cmdName & " " & args.join(" ") & "\"")
        exec(batdir & "\\pipe.bat " & getHomeDir() & "nshcathe\\res.txt " & getHomeDir() & "nshcathe\\log.txt sed -e 's/\\r//' xargs " & cmdName & " " & args.join(" "))
        res = CLIstring(staticRead(getHomeDir() & "nshcathe\\res.txt"))
    res
