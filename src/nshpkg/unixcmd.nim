import strformat
import strutils
import osproc
import os
import algorithm
import times

using args: varargs[string]

type
    Error = object of Exception
    CLIstring = distinct string

proc createRoot*() =
    if not existsDir(getHomeDir() & "/nshcathe"):
        createDir(getHomeDir() & "/nshcathe")
    if not existsFile(getHomeDir() & "/nshcathe/hist.cfg"):
        let f = open(getHomeDir() & "/nshcathe/hist.cfg", fmWrite)
        f.writeLine("0 start")
        f.close
    if not existsFile(getHomeDir() & "/nshcathe/rootDir.txt"):
        let f = open(getHomeDir() & "/nshcathe/rootDir.txt", fmWrite)
        f.writeLine(getCurrentDir())
        f.close

createRoot()

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
proc write*(f: File, s: CLIstring) {.borrow.}
proc split*(cliS: CLIstring, s: string): seq[string] = split($cliS, s)

proc toInt*(x: int): int = x

iterator items*(cliS: CLIstring): string =
    let lines = cliS.split("\n")
    for l in lines:
        yield l

proc addhist(com: string) =
    let hist = open(getHomeDir() & "/nshcathe/hist.cfg", fmAppend)
    hist.write(com)
    hist.close

proc getidx(): int =
    let histForRead = open(getHomeDir() & "/nshcathe/hist.cfg", fmRead)
    defer:
        histForRead.close
    # BUG: foo.readAll() will throw an error in tcc!
    var res = ""
    while not histForRead.endOfFile:
        res.add(histForRead.readLine() & "\n")
    return res.split("\n")[^2].split(" ")[0].parseInt()

proc exec(cmdName: string, args): CLIstring =
    let cmd = cmdName & " " & args.join(" ")
    addhist(fmt"{getidx()+1} {cmd}" & "\n")
    return CLIstring(execProcess(cmd))

proc guess(s: string): string = discard
proc cguess(s: cstring, buflen: cint): cstring {.used.} = discard

template `&&`*(x, y: untyped) =
    try:
        x
        y
    except:
        raiseError()

template `>`*(x: string, fileName: untyped): untyped =
    let f = open(astToStr(fileName), fmWrite)
    f.write(x)
    f.close()
template `>`*(x: CLIstring, fileName: untyped): untyped =
    let f = open(astToStr(fileName), fmWrite)
    f.write(x)
    f.close()

template `>>`*(x: string, fileName: untyped): untyped =
    let f = open(astToStr(fileName), fmAppend)
    f.write(x)
    f.close()
template `>>`*(x: CLIstring, fileName: untyped): untyped =
    let f = open(astToStr(fileName), fmAppend)
    f.write(x)
    f.close()

proc `!`*(idx: int): CLIstring =
    let f = open(getHomeDir() & "/nshcathe/hist.cfg", fmRead)
    while not f.endOfFile:
        let line = f.readLine()
        if line.find($idx) != -1:
            addhist($(getidx()+1) & " " & line.split(" ")[1] & "\n")
            let errc = execShellCmd(fmt"""{line.split(" ")[1]} > {getHomeDir()}/nshcathe/res.txt""")
            if errc != 0:
                raiseError(errc)
            let
                res = open(getHomeDir() & "/nshcathe/res.txt", fmRead)
                resall = res.readAll()
            res.close()
            return CLIstring(resall)
proc `!`*(com: string): CLIstring =
    let f = open(getHomeDir() & "/nshcathe/hist.cfg", fmRead)
    var l: seq[string] = @[]
    for i in f.readAll().split("\n"):
        l.add(i)
    l.reverse
    for line in l:
        if line.find(com) != -1:
            addhist($(getidx()+1) & " " & line.split(" ")[1] & "\n")
            let errc = execShellCmd(fmt"""{line.split(" ")[1]} > {getHomeDir()}/nshcathe/res.txt""")
            if errc != 0:
                raiseError(errc)
            let
                res = open(getHomeDir() & "/nshcathe/res.txt", fmRead)
                resall = res.readAll()
            res.close()
            return CLIstring(resall)

template `||`*(x, y: untyped) =
    try:
        x
    except:
        y


proc pwd*(): CLIstring =
    addhist(fmt"{getidx()+1} pwd" & "\n")
    return CLIstring(getCurrentDir())

proc cd*(dir: string) =
    addhist(fmt"{getidx()+1} pwd {dir}" & "\n")
    setCurrentDir(dir)

proc rm*(args) =
    echo exec("rm", args)

proc ls*(args): CLIstring =
    exec("ls", args)[0..^2]

proc mkdir*(args) {.inline.} =
    echo exec("mkdir", args)

proc rmdir*(args) =
    echo exec("rmdir", args)

proc cp*(args) =
    echo exec("cp", args)

proc mv*(args) =
    echo exec("mv", args)

proc pushd*(args) =
    echo exec("pushd", args)

proc popd*() =
    addhist(fmt"{getidx()+1} popd" & "\n")
    echo execProcess(fmt"popd")

proc cat*(args): CLIstring =
    exec("cat", args)

proc touch*(args) =
    echo exec("touch", args)

proc file*(args): CLIstring =
    exec("file", args)

proc ffind*(args): CLIstring =
    exec("find", args)

proc locate*(args): CLIstring =
    exec("locate", args)

proc more*(args): CLIstring =
    {.hint: "this proc is different from the behavior at the terminal.".}
    exec("more", args)

proc less*(args): CLIstring =
    {.hint: "this proc is different from the behavior at the terminal.".}
    exec("less", args)

when not defined(windows):
    proc lv*(args): CLIstring =
        {.hint: "this proc is different from the behavior at the terminal.".}
        exec("lv", args)

proc head*(args): CLIstring =
    exec("head", args)

proc tail*(args): CLIstring =
    exec("tail", args)

proc grep*(args): CLIstring =
    exec("grep", args)
proc grep*(fileName: CLIstring, args): CLIstring =
    let argsStr = args.join(" ")
    addhist(fmt"{getidx()+1} echo someFile | grep {argsStr}" & "\n")
    let f = open(getHomeDir() & "/nshcathe/log.txt", fmWrite)
    f.write(fileName)
    f.close()
    let errc = execShellCmd(fmt"cat {getHomeDir()}/nshcathe/log.txt | grep {argsStr} > {getHomeDir()}/nshcathe/res.txt")
    let
        res = open(getHomeDir() & "/nshcathe/res.txt", fmRead)
        outs = res.readAll()
    res.close
    return CLIstring(outs)

proc wc*(args): CLIstring =
    exec("wc", args)
proc wc*(cliS: CLIstring, args): CLIstring =
    let f = open(getHomeDir() & "/nshcathe/log.txt", fmWrite)
    f.write(cliS)
    f.close
    discard execShellCmd(fmt"cat {getHomeDir()}/nshcathe/log.txt | wc " & args.join(" ") & fmt" > {getHomeDir()}nshcathe/res.txt")
    let f2 = open(getHomeDir() & "/nshcathe/res.txt", fmRead)
    CLIstring(f2.readAll())

proc sed*(args): CLIstring =
    exec("sed", args)
proc sed*(cliS: CLIstring, args): CLIstring =
    let f = open(getHomeDir() & "/nshcathe/log.txt", fmWrite)
    f.write(cliS)
    f.close
    discard execShellCmd(fmt"cat {getHomeDir()}/nshcathe/log.txt | sed " & args.join(" ") & fmt" > {getHomeDir()}nshcathe/res.txt")
    let f2 = open(getHomeDir() & "/nshcathe/res.txt", fmRead)
    CLIstring(f2.readAll())

proc join*(args): CLIstring =
    exec("join", args)

proc diff*(args): CLIstring =
    exec("diff", args)

proc cut*(args): CLIstring =
    exec("cut", args)

proc uniq*(args): CLIstring =
    exec("uniq", args)

proc sort*(args): CLIstring =
    exec("sort", args)

proc nkf*(args): CLIstring =
    addhist(fmt"""{getidx()+1} nkf {args.join(" ")}""" & "\n")
    let f = args[^1].open(fmRead)
    defer:
        f.close
    if args[0..^2].join(" ").find("--guess") != -1:
        return CLIstring(f.readLine.guess)
    else:
        discard

proc history*(): CLIstring =
    addhist(fmt"{getidx()+1} history" & "\n")
    let
        hist = open(getHomeDir() & "/nshcathe/hist.cfg", fmRead)
        all = hist.readAll()
    hist.close
    return CLIstring(all)

proc ps*(args): CLIstring =
    addhist(fmt"""{getidx()+1} ps {args.join(" ")}""" & "\n")
    let errc = execShellCmd(fmt"""ps {args.join(" ")} > {getHomeDir()}/nshcathe/res.txt""")
    let
        res = open(getHomeDir() & "/nshcathe/res.txt", fmRead)
        outs = res.readAll()
    res.close
    return CLIstring(outs)

proc jobs*(): CLIstring = discard

proc kill*[T: string or int](option: string, pid: T) =
    addhist(fmt"{getidx()+1} kill {option} {$pid}" & "\n")
    discard execProcess(fmt"kill {option} {$pid}")

proc lp*(option, fileName: string) =
    addhist(fmt"{getidx()+1} lp {option} {fileName}" & "\n")
    when defined(windows):
        var com = ""
        let f = open(getHomeDir() & "/nshcathe/ftpcom.txt", fmWrite)
        let ipconfig = option.split(" ").find("-S")
        if ipconfig != -1:
            com &= fmt"""open {option.split(" ")[ipconfig+1]}""" & "\n"
        com &= fmt"put {fileName}"
        f.write(com)
        f.close()
        discard execProcess(fmt"ftp -s:{getHomeDir()}/nshcathe/ftpcom.txt")
    else:
        discard execProcess(fmt"lp {option} {fileName}")

proc lpstat*() =
    addhist(fmt"{getidx()+1} lpstat" & "\n")
    when defined(windows):
        let f = open(getHomeDir() & "/nshcathe/ftpcom.txt", fmWrite)
        f.write("status")
        f.close()
        discard execProcess(fmt"ftp -s:{getHomeDir()}/nshcathe/ftpcom.txt")
    else:
        discard execProcess("lpstat")

proc cancel*() =
    when defined(windows):
        raise newException(Error, "this proc isn't available")
    else:
        addhist(fmt"{getidx()+1} cancel" & "\n")
        discard execProcess("cancel")

proc yppasswd*() = discard

proc chmod*(args) =
    when defined(windows):
        raise newException(Error, "this proc isn't available")
    else:
        discard exec("chmod", args)

proc xlock*(args) =
    when defined(windows):
        raise newException(Error, "this proc isn't available")
    else:
        discard exec("xlock", args)

proc last*() =
    when defined(windows):
        raise newException(Error, "this proc isn't available")
    else:
        addhist(fmt"{getidx()+1} last" & "\n")
        discard execProcess("last")

proc du*(args): CLIstring =
    exec("du", args)

proc ln*(args) =
    discard exec("ln", args)

# TODO: implemention
proc telnet*(host: string) = discard

proc ssh*(host: string): CLIstring = discard

proc scp*(args): CLIstring = discard

proc sftp*(user_host: string): CLIstring = discard

proc man*(args): CLIstring =
    exec("man", args)

proc which*(args): CLIstring =
    exec("which", args)

proc tar*(args): CLIstring =
    exec("tar", args)

proc gunzip*(args): CLIstring = discard

proc su*() =
    when defined(windows):
        raiseError()
    else:
        addhist(fmt"{getidx()+1} su" & "\n")
        discard execProcess("su")

proc shutdown*(args) =
    discard exec("shutdown", args)

proc reboot*() =
    when defined(windows):
        discard execProcess("shutdown -r")
    else:
        addhist("{getidx()+1} reboot" & "\n")
        discard execProcess("reboot")

proc hostname*(): CLIstring =
    addhist(fmt"{getidx()+1} hostname" & "\n")
    return CLIstring(execProcess("hostname"))

proc groups*(): CLIstring =
    addhist(fmt"{getidx()+1} groups" & "\n")
    return CLIstring(execProcess("groups"))

proc chown*(args): CLIstring =
    exec("chown", args)

proc chgrp*(args): CLIstring =
    exec("chgrp", args)

proc useradd*(user: string) =
    when defined(windows):
        raiseError()
    else:
        addhist(fmt"{getidx()+1} useradd {user}" & "\n")
        discard execProcess(fmt"useradd {user}")

proc userdel*(user: string) =
    when defined(windows):
        raiseError()
    else:
        addhist(fmt"{getidx()+1} userdel {user}" & "\n")
        discard execProcess(fmt"userdel {user}")

proc groupadd*(user: string) =
    when defined(windows):
        raiseError()
    else:
        addhist(fmt"{getidx()+1} groupadd {user}" & "\n")
        discard execProcess(fmt"groupadd {user}")

proc groupdel*(user: string) =
    when defined(windows):
        raiseError()
    else:
        addhist(fmt"{getidx()+1} groupdel {user}" & "\n")
        discard execProcess(fmt"groupdel {user}")

proc who*(args): CLIstring =
    exec("who", args)

proc whoami*(args): CLIstring =
    exec("whoami", args)

proc vset*(args): CLIstring =
    exec("vset", args)

proc printenv*(args): CLIstring =
    exec("printenv", args)

proc vexport*(name: string) = discard
    #[let
        f = open("config/variables.cfg")
        vars = f.readAll().split("\n")
    for v in vars:
        if v.find(name) != -1:
            execProcess("set")]#
proc vexport*() = discard

proc watch*(args): CLIstring =
    exec("watch", args)

proc stty*(args): CLIstring =
    exec("stty", args)

proc date*(args): CLIstring =
    exec("date", args)

proc sleep*[T: not string](sec: T) =
    os.sleep((sec*1000).toInt)
proc sleep*(sec: string) =
    if sec.find(".") == -1:
        os.sleep(sec.parseInt*1000)
    else:
        os.sleep((sec.parseFloat*1000).toInt)

# 'user' and 'sys' have no meaning.
template time*(cmd: untyped): untyped =
    addhist($(getidx()+1) & " time\n")
    let start = now()
    once(cmd)
    let
        dura = now() - start
        tim = $dura.minutes & "m" & $dura.seconds & "." & $dura.milliseconds & "s"
    echo ""
    CListring("real    " & tim & "\nuser    " & tim & "\nsys     " & tim)

template xargs*(res: CLIstring, cmd: untyped, args: varargs[string]): CLIstring =
    let f = open(getHomeDir() & "/nshcathe/res.txt", fmWrite)
    f.write(res)
    f.close()

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

    if args.len == 0:
        addhist($(getidx()+1) & fmt" xargs " & cmdName & "\n")
        # cmdName is undeclared when this uses 'fmt'. it's fmt's bug?
        discard execShellCmd(fmt"cat {getHomeDir()}/nshcathe/res.txt | xargs " & cmdName & fmt" > {getHomeDir()}/nshcathe/out.txt")
    else:
        addhist($(getidx()+1) & fmt" xargs " & cmdName & " " & args.join(" ") & "\n")
        discard execShellCmd(fmt"cat {getHomeDir()}/nshcathe/res.txt | xargs " & cmdName & " " & args.join(" ") & fmt" > {getHomeDir()}/nshcathe/out.txt")
    let
        f2 = open(getHomeDir() & "/nshcathe/out.txt", fmRead)
        resall = f2.readAll()
    f.close()
    CLIstring(resall)


if isMainModule:
    echo time os.sleep(1000)
