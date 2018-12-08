template `>`(s, file: string) =
    static:
        discard staticExec("")

template cd*(dir: string) =
    static:
        discard staticExec("cd " & dir)

template ls*(): string =
    static:
        let res = staticExec("ls")
    res
template ls*(dir: string): string =
    static:
        let res = staticExec("ls " & dir)
    res

template rm*(fileOrDir: string) =
    static:
        discard staticExec("rm " & fileOrDir)
