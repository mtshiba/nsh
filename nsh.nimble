# Installing external compiler (tcc)

when defined(Windows):
    # when defined(amd64):
    #    exec "installwin64.bat"
    # when defined(x86):
    #    exec "installwin32.bat"
    discard
elif defined(MacOSX) or defined(MacOS):
    exec "brew install tcc"
elif defined(Linux):
    try:
        exec "apt-get install tcc"
    # or
    except:
        exec "yum install tcc"

# Package

version       = "0.1.5"
author        = "gmshiba"
description   = "nsh: Nim SHell(cross platform)"
license       = "MIT"
binDir        = "bin"
srcDir        = "src"
installDirs   = @["nshpkg"]
bin           = @["nsh"]

# Dependencies

requires "nim >= 0.18.0"
# requires "unixcmd >= 0.1.0"
