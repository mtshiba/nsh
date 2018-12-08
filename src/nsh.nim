import strformat
import strutils
import osproc
import nre
import os
import terminal
import colors

import nshpkg/unixcmd

{.push checks:off, optimization: speed.}


const
    version = "0.1.5"
    date = "Dec 8 2018, 23:35:00"
    message = fmt"""
Nsh {version} (default, {date}) [{hostOS}, {hostCPU}]
    nsh [-tcc]
    -tcc          : using tcc compiler for compiling. you can change later.

    :back         : clear last line.
    :clear        : clear all lines.
    :quit|exit    : quit this program.
    :show         : display history.
    :tcc on|off   : switch compiler to tcc/default.
"""
    initcode = """
import nshpkg/unixcmd

template on_ce(state: void): void = discard
template on_ce[T: not void](arg: T): void =
    echo arg
template on_ce(args: varargs[untyped]): void =
    echo args
"""

    keywords = [
        "import", "from", "using", "macro", "template", "return", "discard", "once"
    ]
    blockKey = [
        "case"
    ]
    assnKey = [
        "var", "let", "const", "proc", "type"
    ]

type BlockKind = enum
    Main
    Proc
    Temp
    Macro
    For
    If
    Elif
    Else
    Case
    Of
    While
    Block
    Assn
    Type
    Other

type NshRunTimeError = object of Exception

type Shell = object of RootObj
    nowblock: seq[BlockKind]
    pastblock: seq[BlockKind]
    code: string
    errc: int

var useTcc = ""
if commandLineParams().len != 0:
    useTcc = if commandLineParams()[0].find("-tcc") != -1: "--cc:tcc" else: ""

proc showprefix(sh: Shell) =
    echo ""
    stdout.styledWrite(fgGreen, execProcess("whoami").replace("\n", "") & ": ")
    stdout.styledWrite(fgCyan, getCurrentDir())
    resetAttributes()
    if sh.errc == 0:
        stdout.write("\n$ ")
    else:
        stdout.styledWrite(fgRed, "\n$ ")
    resetAttributes()

proc escape(s: var string) =
    s = s.replace(re".\[D", "").replace("[", "")

proc save(self: Shell) =
    let f = open(fmt"{rootDir}/nshcathe/repl.nim", fmWrite)
    f.write(self.code)
    f.close()

proc canContainEcho(blockkind: seq[BlockKind]): bool =
    if blockkind.len() == 1:
        return false

    if blockkind[1] == Proc or blockkind[1] == Temp or blockkind[1] == Macro:
        return true
    else:
        return false

proc `*`(a: string, times: int): string  =
    result = ""
    if times == 0:
        return result
    for i in countup(1, times):
        result = result & a

proc delLine(self: var Shell) =
    var codelines = self.code.split("\n")
    codelines.del(codelines.high-1)
    self.code = codelines.join("\n") & "\n"

proc delOnce(self: var Shell) =
    self.code = self.code.replace(re"once.*", "")
    self.code = self.code.replace(re"case.*\n\n", "\n")
    self.code = self.code.replace(re"\n\nelse:\n( .*)*\n", "\n\n")
    var rep = self.code.replace(re".*:\n *\n", "\n")
    while self.code != rep:
        self.code = rep
        rep = self.code.replace(re".*:\n *\n", "\n")

proc isContinueBlock(blockkind: seq[BlockKind]): bool =
    if blockkind.find(If) != -1 or blockkind.find(Elif) != -1 or blockkind.find(Case) != -1:
        return true
    return false

proc orderType(self: Shell, order: string): string =
    if order.match(re"\{\..*\.\}").isSome:
        return "pragma"
    elif blockKey.find(order.split(" ")[0]) != -1:
        return "case"
    elif order.split(" ")[0] == "of":
        return "of"
    elif assnKey.find(order) != -1:
        return "assnblock"
    elif keywords.find(order.split(" ")[0]) != -1:
        return "keystatement"
    elif order.endsWith(":"):
        if order == "else:" and self.nowblock.find(Case) != -1:
            return "caseelse"
        else:
            return "block"
    elif order.endsWith("="):
        return "statement"
    elif assnKey.find(order.split(" ")[0]) != -1:
        return "expression"
    elif order.match(re".*=.*").isSome:
        return "expression"
    else:
        if self.nowblock.find(Proc) != -1 or self.nowblock.find(Assn) != -1 or self.nowblock.find(Type) != -1:
            return "expression"
        # onceが必要なのはこれだけ
        else:
            return "oncecall"

proc newShell(): Shell =
    result.nowblock = @[Main]
    result.pastblock = @[Main]
    result.code = initcode
    return result

proc main() =
    var sh = newShell()

    echo message

    while true:
        if sh.nowblock.len > 1:
            stdout.write("...")
            for i in countup(1, sh.nowblock.len-1):
                stdout.write("    ")
        else:
            if sh.pastblock.isContinueBlock():
                stdout.write("...")
            else:
                sh.showprefix()
        stdout.flushFile()

        var order = stdin.readline()


        # Change directory action must run on this file.
        if order.startsWith("cd ") or order.startswith("cd("):
            try:
                cd order.multireplace(("cd ", ""), ("\"", ""), ("cd(", ""), (")", ""))
                sh.errc = 0
            except:
                stdout.styledWrite(fgRed, "Error: ")
                stdout.write("Directory not found")
                stdout.flushFile()
                sh.errc = -1
            continue

        # At first, execute as shell command.
        if sh.nowblock == @[Main]:
            try:
                when defined(windows):
                    sh.errc = execCmd(order)
                    if sh.errc != 0:
                        raise newException(NshRunTimeError, "")
                    else:
                        continue
                else:
                    var outs = ""
                    (outs, sh.errc) = execCmdEx(order)
                    if sh.errc != 0:
                        raise newException(NshRunTimeError, "")
                    else:
                        echo outs
                        continue
            except NshRunTimeError:
                # If this failed, execute as nim code.
                discard
            except:
                discard


        case order
        of ":quit":
            break
        of ":exit":
            break
        of ":show":
            echo "block: ", sh.nowblock
            echo "code:\n", sh.code.replace(initcode, "")
            continue
        of ":clear":
            sh.nowblock = @[Main]
            sh.pastblock = @[Main]
            sh.code = initcode
            continue
        of ":back":
            sh.delLine()
            sh.nowblock = sh.pastblock
            continue
        of ":tcc on":
            useTcc = "--cc:tcc"
        of ":tcc off":
            useTcc = ""
        # for debuging
        of ":save":
            sh.save()
            continue
        of "":
            if sh.nowblock[^1] == Of:
                discard sh.nowblock.pop
                continue
            if sh.nowblock != @[Main]:
                discard sh.nowblock.pop
            if sh.nowblock.len == 1 and not sh.pastblock.isContinueBlock():
                let (outs, errc) = execCmdEx(fmt"nim c -r {useTcc} --checks:off --hints:off --opt:none --verbosity:0 {rootDir}/nshcathe/repl.nim")
                if errc == 0:
                    echo outs
                    sh.errc = 0
                    let pastcode = sh.code.split("\n")[^2].replace(" ", "")
                    if not sh.pastblock.canContainEcho():
                        sh.delOnce()
                else:
                    stdout.styledWrite(fgRed, "Error: ")
                    stdout.write(outs.replace(re"repl.nim\(.*\) Error: ", ""))
                    stdout.flushFile()
                    sh.errc = -1
                    sh.delLine()
                    sh.nowblock = sh.pastblock
            continue
        else:
            sh.pastblock = sh.nowblock
            case orderType(sh, order)
            of "oncecall":
                order = fmt"once({order})"
            of "case":
                sh.code &= "  " * (sh.nowblock.len() - 1) & order & "\n"
                sh.code.escape()
                sh.save()
                continue
            of "of":
                sh.code &= "  " * (sh.nowblock.len() - 1) & order & "\n"
                sh.code.escape()
                sh.save()
                sh.nowblock.add(Of)
                continue
            of "caseelse":
                sh.nowblock = @[Main, Else]
                sh.code &= order & "\n"
                sh.code.escape()
                sh.save()
                continue
            else:
                discard

            sh.code &= "  " * (sh.nowblock.len() - 1) & order & "\n"
            sh.code.escape()
            sh.save()

            if order.endsWith(":") or order.endsWith("="):
                case order.split(" ")[0]
                of "proc":
                    sh.nowblock.add(Proc)
                of "template":
                    sh.nowblock.add(Temp)
                of "macro":
                    sh.nowblock.add(Macro)
                of "for":
                    sh.nowblock.add(For)
                of "if":
                    sh.nowblock.add(If)
                of "elif":
                    sh.nowblock.add(Elif)
                of "else":
                    sh.nowblock.add(Else)
                of "while":
                    sh.nowblock.add(Elif)
                of "block":
                    sh.nowblock.add(Block)
                of "var":
                    sh.nowblock.add(Assn)
                of "let":
                    sh.nowblock.add(Assn)
                of "const":
                    sh.nowblock.add(Assn)
                of "type":
                    sh.nowblock.add(Type)
                else:
                    sh.nowblock.add(Other)

            if sh.nowblock.len() == 1 and not sh.pastblock.isContinueBlock():
                let (outs, errc) = execCmdEx(fmt"nim c -r {useTcc} --checks:off --hints:off --opt:none --verbosity:0 {rootDir}/nshcathe/repl.nim")
                if errc == 0:
                    echo outs
                    sh.errc = 0
                    sh.delOnce()
                else:
                    stdout.styledWrite(fgRed, "Error: ")
                    stdout.write(outs.replace(re"repl.nim\(.*\) Error: ", ""))
                    stdout.flushFile()
                    sh.errc = -1
                    sh.delLine()
                    sh.nowblock = sh.pastblock


if isMainModule:
    main()
